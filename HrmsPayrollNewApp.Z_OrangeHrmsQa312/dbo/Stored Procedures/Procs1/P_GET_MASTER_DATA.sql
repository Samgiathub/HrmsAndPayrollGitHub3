
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_GET_MASTER_DATA]
	@Cmp_ID		VARCHAR(512),
	@Property	Varchar(32),
	@For_Date	DateTime = NULL,	
	@Fields		Varchar(Max) = NULL,
	@Filter		Varchar(Max) = '',
	@Login_ID	Numeric = 0
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	SET @For_Date = IsNull(@For_Date, GETDATE());
	BEGIN
		DECLARE @SQL NVARCHAR(MAX)
		DECLARE @ORDER NVARCHAR(128) = 'Order By Name'

		IF CHARINDEX('And', LTRIM(@Filter)) <> 1 AND LEN(LTRIM(@Filter)) > 0
			SET @Filter = ' And ' + @Filter

		IF CHARINDEX('^^', @Filter) > 0
			SET @Filter = REPLACE(@Filter, '^^', ',')
		IF IsNull(@Fields, '') <> '' AND @Property NOT IN ('Employee')
			AND CHARINDEX(',', LTRIM(@Fields)) <> 1
			SET @Fields = ',' + @Fields 
		ELSE IF @Fields IS NULL
			SET @Fields = ''
		
		DECLARE @Where AS NVARCHAR(MAX)
		IF (CHARINDEX(',', @Cmp_ID) > 0)
			SET	@Where = 'Where Cmp_ID IN (@Cmp_ID)' 
		ELSE
			SET	@Where = 'Where Cmp_ID = @Cmp_ID ' 



		DECLARE @Emp_Search_Type VARCHAR(128)
		SELECT	@Emp_Search_Type=Emp_Search_Type  
		FROM	T0011_Login WITH (NOLOCK)
		WHERE	Login_ID=@Login_ID

		SET	@Emp_Search_Type = CASE IsNull(@Emp_Search_Type , '0') -- Default Alpha_Emp_Code + Emp_Full_Name (i.e. A0001 - Miss. Nita Sahebrao Jichkar)
									WHEN '0'
										THEN ',E.Alpha_Emp_Code + '' - '' + E.Emp_Full_Name'
									WHEN '1'
										THEN ',E.Alpha_Emp_Code + '' - '' + RTRIM(RTRIM(E.Emp_First_Name + SPACE(1) + E.Emp_Second_Name) + E.Emp_Last_Name)'
									WHEN '2'
										THEN ',E.Alpha_Emp_Code'												
									WHEN '3'
										THEN ',E.Initial + SPACE(1) + RTRIM(Emp_First_Name + SPACE(1) + RTRIM(E.Emp_Second_Name + SPACE(1) + E.Emp_Last_Name))'												
									WHEN '4'	
										THEN ',RTRIM(Emp_First_Name + SPACE(1) + RTRIM(E.Emp_Second_Name + SPACE(1) + E.Emp_Last_Name)) + ''-'' + E.Alpha_Emp_Code'																								
								END + ' AS Name'

		--select @Fields,@Filter
		IF @Property = 'Branch'
			SET @SQL = 'SELECT Branch_ID As ID, Branch_Name As Name' + @Fields + ' FROM T0030_BRANCH_MASTER WITH (NOLOCK) '
		ELSE IF @Property = 'Sub Branch'
			SET @SQL = 'SELECT SubBranch_ID As ID, SubBranch_Name As Name, Branch_ID' + @Fields + '  FROM T0050_SUBBRANCH WITH (NOLOCK)'
		ELSE IF @Property = 'Department'
			SET @SQL = 'SELECT Dept_ID As ID, Dept_Name As Name' + @Fields + '  FROM T0040_DEPARTMENT_MASTER WITH (NOLOCK)'
		ELSE IF @Property = 'Designation'
			SET @SQL = 'SELECT Desig_ID As ID, Desig_Name As Name' + @Fields + '  FROM T0040_DESIGNATION_MASTER WITH (NOLOCK)'
		ELSE IF @Property = 'Vertical'
			SET @SQL = 'SELECT Vertical_ID As ID, Vertical_Name As Name' + @Fields + '  FROM T0040_Vertical_Segment WITH (NOLOCK)'
		ELSE IF @Property = 'Sub Vertical'
			SET @SQL = 'SELECT SubVertical_ID As ID, SubVertical_Name As Name, Vertical_ID' + @Fields + '   FROM T0050_SubVertical WITH (NOLOCK)'
		ELSE IF @Property = 'Business Segment'
			SET @SQL = 'SELECT Segment_ID As ID, Segment_Name As Name' + @Fields + '  FROM T0040_Business_Segment WITH (NOLOCK)'
		ELSE IF @Property = 'Grade'
			SET @SQL = 'SELECT Grd_ID As ID, Grd_Name As Name' + @Fields + '  FROM T0040_GRADE_MASTER WITH (NOLOCK)'
		ELSE IF @Property = 'Employee Type'
			SET @SQL = 'SELECT Type_ID As ID, Type_Name As Name' + @Fields + '  FROM T0040_TYPE_MASTER WITH (NOLOCK)'
		ELSE IF @Property = 'Salary Cycle'
			SET @SQL = 'SELECT Tran_Id ID, Name' + @Fields + '  from T0040_Salary_Cycle_Master WITH (NOLOCK)'
		ELSE IF @Property = 'Gender'
			BEGIN
				SET @Where = ''
				SET @Filter = ''
				SET @SQL = 'SELECT ''M'' As ID, ''Male'' As Name	
							UNION ALL
							SELECT ''F'' As ID, ''Female'' As Name	'
			END
		ELSE IF @Property = 'Company'
			BEGIN
				DECLARE @Is_GroupOfCompany BIT
				SET @SQL = 'Select TOP 1 @Is_GroupOfCompany = Is_GroupOfCmp From T0010_COMPANY_MASTER WITH (NOLOCK) Where Cmp_Id IN (' + @Cmp_ID + ')'
				exec sp_executesql @SQL, N'@Is_GroupOfCompany BIT output', @Is_GroupOfCompany output				
				SET @SQL = 'SELECT Cmp_ID As ID, Cmp_Name As Name' + @Fields + '  from T0010_COMPANY_MASTER WITH (NOLOCK)'
				IF @Is_GroupOfCompany = 1
					SET @Where = 'Where Is_GroupOfCmp=1'									
			END
		ELSE IF @Property = 'Reporting Manager'
			BEGIN
				
				SET @ORDER  = 'Order By Emp_ID'
				SET @SQL = 'Select	Emp_ID As ID, Name, Emp_ID, Cmp_ID
							FROM	(SELECT DISTINCT I.*,E.Date_Of_Join,IsNull(E.Emp_Left_Date, GetDate()+1) As Emp_Left_Date,
											E.Alpha_Emp_Code,E.Emp_First_Name,E.Emp_Second_Name,E.Emp_Last_Name,E.Emp_Full_Name,E.Emp_Code
											' + @Emp_Search_Type + ',
											R.R_Emp_ID
									 FROM	T0080_EMP_MASTER E WITH (NOLOCK)
											INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON E.Emp_ID=I.Emp_ID
											INNER JOIN (SELECT	Max(Increment_ID) As Increment_ID, I1.Emp_ID
														FROM	T0095_INCREMENT I1 WITH (NOLOCK)
																INNER JOIN (SELECT	Max(I2.Increment_Effective_Date) As Increment_Effective_Date, I2.Emp_ID
																			FROM	T0095_INCREMENT I2 WITH (NOLOCK)
																			WHERE	Increment_Effective_Date <= ''' + Cast(@For_Date As Varchar(11)) + '''
																			GROUP BY I2.Emp_ID
																			) I2 ON I1.Emp_ID=I2.Emp_ID AND I2.Increment_Effective_Date=I1.Increment_Effective_Date
														GROUP BY I1.Emp_ID) I1 ON I.Emp_ID=I1.Emp_ID AND I.Increment_ID=I1.Increment_ID
											INNER JOIN T0090_EMP_REPORTING_DETAIL R WITH (NOLOCK) ON E.Emp_ID=R.R_Emp_ID
											INNER JOIN (SELECT	Max(R1.Row_ID) As Row_ID, R1.Emp_ID
															 FROM	T0090_EMP_REPORTING_DETAIL R1 WITH (NOLOCK)
																	INNER JOIN (SELECT	Max(R2.Effect_Date) As Effect_Date, R2.Emp_ID
																				FROM	T0090_EMP_REPORTING_DETAIL R2 WITH (NOLOCK)
																				WHERE	R2.Effect_Date <= ''' + Cast(@For_Date As Varchar(11)) + '''
																				GROUP BY R2.Emp_ID
																				) R2 ON R1.Emp_ID=R2.Emp_ID AND R2.Effect_Date=R1.Effect_Date
															 GROUP BY R1.Emp_ID) R1 ON R.Emp_ID=R1.Emp_ID AND R.Row_ID=R1.Row_ID
									) T'
			END
		ELSE IF @Property = 'Employee'
			BEGIN				
				--IF CHARINDEX(',', @Cmp_ID) > 0
				SET	@Where = 'Where Cmp_ID IN (@Cmp_ID) ' 
				--ELSE IF LEN(RTRIM(@Filter)) > 0 AND CHARINDEX(',', @Cmp_ID) = 0	--If the Filter is supplied then Company ID Should not be checked
				--	SET	@Where = 'Where ' + CAST(@Cmp_ID AS VARCHAR(10)) + ' = @Cmp_ID ' 
				

				IF @Fields = ''
					SET @Fields =	'Emp_ID As ID, Name, Alpha_Emp_Code, Emp_First_Name, Emp_Second_Name, Emp_Last_Name, Emp_Full_Name, Emp_Code,
									Date_Of_Join, Emp_Left_Date, R_Emp_ID, Branch_ID, Dept_ID, Desig_ID, Grd_ID, Type_ID, Vertical_ID, SubVertical_ID, 
									Segment_ID,SubBranch_ID,Emp_Left'				
				
				SET @ORDER  = 'Order By Emp_ID'
				SET @SQL = 'Select	' + @Fields + '
							FROM	(SELECT I.*,E.Date_Of_Join,IsNull(E.Emp_Left_Date, GetDate()+1) As Emp_Left_Date,Emp_Left,
											E.Alpha_Emp_Code,E.Emp_First_Name,E.Emp_Second_Name,E.Emp_Last_Name,E.Emp_Full_Name,E.Emp_Code
											' + @Emp_Search_Type + ',
											R.R_Emp_ID,Pan_No,Aadhar_Card_No,Mobile_No,Gender
									 FROM	T0080_EMP_MASTER E WITH (NOLOCK)
											INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON E.Emp_ID=I.Emp_ID
											INNER JOIN (SELECT	Max(Increment_ID) As Increment_ID, I1.Emp_ID
														FROM	T0095_INCREMENT I1 WITH (NOLOCK)
																INNER JOIN (SELECT	Max(I2.Increment_Effective_Date) As Increment_Effective_Date, I2.Emp_ID
																			FROM	T0095_INCREMENT I2 WITH (NOLOCK)
																			WHERE	Increment_Effective_Date <= ''' + Cast(@For_Date As Varchar(11)) + '''
																			GROUP BY I2.Emp_ID
																			) I2 ON I1.Emp_ID=I2.Emp_ID AND I2.Increment_Effective_Date=I1.Increment_Effective_Date
														GROUP BY I1.Emp_ID) I1 ON I.Emp_ID=I1.Emp_ID AND I.Increment_ID=I1.Increment_ID
											LEFT OUTER JOIN (SELECT	R.EMP_ID, R_EMP_ID
															 FROM	T0090_EMP_REPORTING_DETAIL R WITH (NOLOCK)
																	INNER JOIN (SELECT	Max(R1.Row_ID) As Row_ID, R1.Emp_ID
																				FROM	T0090_EMP_REPORTING_DETAIL R1 WITH (NOLOCK)
																					INNER JOIN (SELECT	Max(R2.Effect_Date) As Effect_Date, R2.Emp_ID
																								FROM	T0090_EMP_REPORTING_DETAIL R2 WITH (NOLOCK)
																								WHERE	R2.Effect_Date <= ''' + Cast(@For_Date As Varchar(11)) + '''
																								GROUP BY R2.Emp_ID
																								) R2 ON R1.Emp_ID=R2.Emp_ID AND R2.Effect_Date=R1.Effect_Date
																				GROUP BY R1.Emp_ID) R1 ON R.Emp_ID=R1.Emp_ID AND R.Row_ID=R1.Row_ID
															) R ON E.Emp_ID=R.Emp_ID
									) T'
			END

		
		IF @SQL  IS NOT NULL
			BEGIN				
				SET @SQL = @SQL + '
						' + @Where + @Filter + ' 
						' + @ORDER
				print @SQL
				SET @SQL = REPLACE(@SQL , '@Cmp_ID', @Cmp_ID)
				EXEC(@SQL);
				--exec sp_executesql @SQL , N'@Cmp_ID As Varchar(512)', @Cmp_ID
			END
	END

RETURN 

