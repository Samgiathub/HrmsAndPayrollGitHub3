
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_EMP_CONF_RECORD_GET]
	 --@Cmp_ID		numeric
	 @Cmp_ID		VARCHAR(MAX) = ''       --added jimit 27052015
	,@From_Date		DATETIME
	,@To_Date		DATETIME 
	--,@Branch_ID   numeric  = 0
	--,@Cat_ID		numeric  = 0
	--,@Grd_ID		numeric  = 0
	--,@Type_ID		numeric  = 0
	--,@Dept_ID		numeric  = 0
	--,@Desig_ID    numeric  = 0
	--,@Emp_ID		numeric  = 0
	,@Branch_ID		VARCHAR(MAX) = ''		--added jimit 27052015
	,@Cat_ID		VARCHAR(MAX) = ''		--added jimit 27052015
	,@Grd_ID		VARCHAR(MAX) = ''		--added jimit 27052015
	,@Type_ID		VARCHAR(MAX) = ''		--added jimit 27052015
	,@Dept_ID		VARCHAR(MAX) = ''		--added jimit 27052015
	,@Desig_ID		VARCHAR(MAX) = ''		--added jimit 27052015		
	,@Emp_ID		VARCHAR(MAX) = ''		--added jimit 27052015
	,@Constraint	VARCHAR(MAX) = ''
	,@New_Join_emp	NUMERIC = 0 
	,@Left_Emp		NUMERIC = 0
	,@Vertical_Id 	VARCHAR(MAX)= '' --Added By Jaina 07-10-2015
	,@SubVertical_ID	VARCHAR(MAX)= '' --Added By Jaina 07-10-2015
	,@Format_Type	VARCHAR(50) = ''
	
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	

	
	IF @Branch_ID ='0' OR @Branch_ID=''  --Change By Jaina 7-10-2015
		SET @Branch_ID = NULL
	IF @Cat_ID = 0
		SET @Cat_ID = NULL
		 
	IF @Type_ID = 0
		SET @Type_ID = NULL
	IF @Dept_ID ='0' OR @Dept_ID=''  --Change By Jaina 7-10-2015
		SET @Dept_ID = NULL
	IF @Grd_ID = 0
		SET @Grd_ID = NULL
	IF @Emp_ID = 0
		SET @Emp_ID = NULL
		
	IF @Desig_ID = 0
		SET @Desig_ID = NULL
		
	
	IF @Vertical_ID='0' OR @Vertical_ID=''		--Added By Jaina 07-10-2015
		SET @Vertical_ID = NULL

	IF @SubVertical_ID='0' OR @SubVertical_ID =''	--Added By Jaina 07-10-2015
		SET @SubVertical_ID = NULL
	IF @Constraint='0' OR @Constraint=''		--Added By Jaina 07-10-2015
		SET @Constraint = NULL

		
	--Added By Jaina 16-10-2015 Start		
	IF @Branch_ID IS NULL
	BEGIN	
		SELECT   @Branch_ID = COALESCE(@Branch_ID + '#', '') + CAST(Branch_ID AS NVARCHAR(5))  FROM T0030_BRANCH_MASTER WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID 
		SET @Branch_ID = @Branch_ID + '#0'
	END
	
	IF @Vertical_ID IS NULL
	BEGIN	
		SELECT   @Vertical_ID = COALESCE(@Vertical_ID + '#', '') + CAST(Vertical_ID AS NVARCHAR(5))  FROM T0040_Vertical_Segment WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID 
		
		IF @Vertical_ID IS NULL
			SET @Vertical_ID = '0';
		ELSE
			SET @Vertical_ID = @Vertical_ID + '#0'		
	END
	IF @subVertical_ID IS NULL
	BEGIN	
		SELECT   @subVertical_ID = COALESCE(@subVertical_ID + '#', '') + CAST(subVertical_ID AS NVARCHAR(5))  FROM T0050_SubVertical WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID 
		
		IF @subVertical_ID IS NULL
			SET @subVertical_ID = '0';
		ELSE
			SET @subVertical_ID = @subVertical_ID + '#0'
	END
	
	IF @Dept_ID IS NULL
	BEGIN		
		SELECT   @Dept_ID = COALESCE(@Dept_ID + '#', '') + CAST(Dept_ID AS NVARCHAR(5))  FROM T0040_DEPARTMENT_MASTER WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID 		
		
		IF @Dept_ID IS NULL
			SET @Dept_ID = '0';
		ELSE
			SET @Dept_ID = @Dept_ID + '#0'
	END
	--Added By Jaina 16-10-2015 End
	
	
	DECLARE @Emp_Cons TABLE
		(
			Emp_ID	NUMERIC
		)
	
	
	IF @Constraint IS NOT NULL
		BEGIN			
			INSERT INTO @Emp_Cons
			SELECT  CAST(DATA  AS NUMERIC) FROM dbo.Split (@Constraint,'#') 			
		END
	ELSE 
		BEGIN
			INSERT INTO @Emp_Cons			
			SELECT I.Emp_Id FROM T0095_Increment I WITH (NOLOCK) INNER JOIN 
			  ( SELECT MAX(Increment_ID) AS Increment_ID , Emp_ID FROM T0095_Increment WITH (NOLOCK)
				WHERE Increment_Effective_date <= @To_Date AND Cmp_ID = @Cmp_ID GROUP BY emp_ID  
			  ) Qry ON I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID
			WHERE Cmp_ID = @Cmp_ID 
			AND ISNULL(Cat_ID,0) = ISNULL(@Cat_ID ,ISNULL(Cat_ID,0))
			--and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			AND Grd_ID = ISNULL(@Grd_ID ,Grd_ID)
			--and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			AND ISNULL(TYPE_ID,0) = ISNULL(@Type_ID ,ISNULL(TYPE_ID,0))
			AND ISNULL(Desig_ID,0) = ISNULL(@Desig_ID ,ISNULL(Desig_ID,0))
			--Added By Jaina 7-10-2015 Start
			--and EXISTS (select Data from dbo.Split(@Branch_ID, '#') B Where cast(B.data as numeric)=Isnull(I.Branch_ID,0))
			--and EXISTS (select Data from dbo.Split(@Vertical_ID, '#') V Where cast(v.data as numeric)=Isnull(I.Vertical_ID,0))
			--and EXISTS (select Data from dbo.Split(@subVertical_ID, '#') S Where cast(S.data as numeric)=Isnull(I.SubVertical_ID,0))
			--and EXISTS (select Data from dbo.Split(@Dept_ID, '#') D Where cast(D.data as numeric)=Isnull(I.Dept_ID,0)) 
			--Added By Jaina 7-10-2015 End
			
			AND I.Emp_ID = ISNULL(@Emp_ID ,I.Emp_ID) 
			AND I.Emp_ID IN 
				( SELECT Emp_Id FROM
				(SELECT emp_id, cmp_ID, join_Date, ISNULL(left_Date, @To_date) AS left_Date FROM T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
				WHERE cmp_ID = @Cmp_ID   AND  
				(( @From_Date  >= join_Date  AND  @From_Date <= left_date ) 
				OR ( @To_Date  >= join_Date  AND @To_Date <= left_date )
				OR Left_date IS NULL AND @To_Date >= Join_Date)
				OR @To_Date >= left_date AND  @From_Date <= left_date ) 
			
		END
		
		DECLARE @Employee_Flag	VARCHAR(25)
		DECLARE @Employee_Status	NUMERIC 
		SET @Employee_Flag = 'Probation'
		SET @Employee_Status = 0
		
		IF @Format_Type = 'Training To Confirmation' OR @Format_Type = 'Performance Evaluation Form Training'
			Or @Format_Type = 'Training Agreement With Bond' OR @Format_Type =  'Training Agreement Without Bond'
			Or @Format_Type = 'Training Confirmation With Bond' OR @Format_Type =  'Training Confirmation Without Bond'
			BEGIN
				SET @Employee_Flag = 'Trainee'
				SET @Employee_Status = 0
			END
		ELSE IF @Format_Type = 'Probation To Confirmation' OR @Format_Type = 'Performance Evaluation Form Probation'
			BEGIN
				SET @Employee_Flag = 'Probation'
				SET @Employee_Status = 0
			END	
		ELSE IF @Format_Type = 'Training To Probation'
			BEGIN
				SET @Employee_Flag = 'Trainee'
				SET @Employee_Status = 2
			END	
		ELSE IF @Format_Type = 'Training To Extended'
			BEGIN
				SET @Employee_Flag = 'Trainee'
				SET @Employee_Status = 1
			END
		ELSE IF @Format_Type = 'Probation To Extended'
			BEGIN
				SET @Employee_Flag = 'Probation'
				SET @Employee_Status = 1
			END
		
		IF @Format_Type ='Confirmation'
			BEGIN
				SELECT I_Q.* ,E.Emp_Full_Name,E.Emp_Code,E.Alpha_Emp_Code,E.Initial,E.Emp_First_Name,E.Emp_Last_Name,Left_Date,BM.Comp_Name,BM.Branch_Address,Left_Reason
						,Dept_Name,Desig_Name,TYPE_NAME,Grd_Name,Branch_Name,Date_of_Join,Gender,@From_Date AS From_Date ,@To_Date AS To_Date
						,Cmp_Name,Cmp_Address,Present_Street,Present_State,Present_City,Present_Post_Box,l.left_reason
						,CM.Cmp_City,E.Father_name,ELR.Reference_No,ELR.Issue_Date		 --added jimit 04082016	
						,CM.Cmp_HR_Manager,CM.Cmp_HR_Manager_Desig		-- added Rudra 23042018
				FROM T0080_EMP_MASTER E WITH (NOLOCK) LEFT OUTER JOIN T0100_Left_Emp l WITH (NOLOCK) ON E.Emp_ID =  l.Emp_ID INNER JOIN
						( SELECT I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,TYPE_ID FROM T0095_Increment I WITH (NOLOCK) INNER JOIN 
							( SELECT MAX(Increment_ID) AS Increment_ID , Emp_ID FROM T0095_Increment WITH (NOLOCK)
							  WHERE Increment_Effective_date <= @To_Date AND Cmp_ID = @Cmp_ID GROUP BY emp_ID  
							) Qry ON I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID	 
						 ) I_Q  ON E.Emp_ID = I_Q.Emp_ID  INNER JOIN
						T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
						T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
						T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
						T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
						T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  INNER JOIN 
						T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID	left join 
						T0081_Emp_LetterRef_Details ELR WITH (NOLOCK) on ELR.Emp_Id = e.Emp_ID and ELR.Letter_Name='Confirmation Letter-'+ @Format_Type--Mukti(06012017) 	 							 
				WHERE E.Cmp_ID = @Cmp_Id AND E.emp_ID IN 
						(SELECT Emp_ID FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE 
						--E.EMP_CONFIRM_DATE <= @TO_DATE AND E.EMP_CONFIRM_DATE >= @FROM_DATE)
						(MONTH(E.EMP_CONFIRM_DATE) = MONTH(@FROM_DATE)) and (Year(E.EMP_CONFIRM_DATE) = Year(@FROM_DATE))) 
						AND E.Emp_ID IN (SELECT Emp_ID FROM @Emp_Cons)
				ORDER BY RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) 
			END	
		
		IF @Format_Type <> ''
			BEGIN
				
				SELECT	I_Q.* ,E.Emp_Full_Name,E.Emp_Code,E.Alpha_Emp_Code,E.Initial,E.Emp_First_Name,E.Emp_Last_Name,Left_Date,BM.Comp_Name,BM.Branch_Address,Left_Reason
						,Dept_Name,Desig_Name,TYPE_NAME,Grd_Name,Branch_Name,Date_of_Join,Gender,@From_Date AS From_Date ,@To_Date AS To_Date
						,Cmp_Name,Cmp_Address,Present_Street,Present_State,Present_City,Present_Post_Box,l.left_reason
						, CASE WHEN EP_Q.Flag = 'Probation' THEN 'Probation' ELSE 'Training' END AS Flag,EP_Q.Probation_Status,EP_Q.Evaluation_Date,EP_Q.Extend_Period,EP_Q.New_Probation_EndDate AS New_Probation_EndDate
						,EP_Q.Old_Probation_Period,EP_Q.Old_Probation_EndDate
						--,CASE WHEN @Employee_Flag = 'Probation' THEN E.Probation ELSE E.Traning END 
						,CONVERT( NUMERIC,( ( CASE WHEN EP_Q.Old_Probation_Period = 0 THEN DATEDIFF(DAY,EP_Q.Old_Probation_Period,EP_Q.New_Probation_EndDate) 
												ELSE EP_Q.Old_Probation_Period END % 365) / 30 )
								 )  AS Probation_Training_Month
						,(Select top 1 E.EMP_FULL_NAME From T0080_EMP_MASTER E WITH (NOLOCK)  --added jimit 22072016
							INNER JOIN  T0011_LOGIN DM WITH (NOLOCK) ON E.Emp_ID=DM.Emp_id
					  WHERE  DM.Cmp_ID=I_Q.Cmp_ID and DM.Is_HR =1 
			) As HR	
				,LM.Loc_name,E.Emp_Notice_Period			--added jimit 25072016		
				,CM.Cmp_City,E.Father_name		                    --added jimit 04082016	
				,dbo.F_Number_TO_Word(isnull(I_Q.CTC * 12,0)) as CTC_In_Word, --Per Annum For Outline Client Sumit 08082016
				ELR.Reference_No,ELR.Issue_Date
				,CM.Cmp_HR_Manager,CM.Cmp_HR_Manager_Desig,Confirmation_date		-- added Rudra 23042018
				FROM	T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN
						@Emp_Cons EC ON E.Emp_ID = EC.Emp_ID LEFT OUTER JOIN 
						T0100_Left_Emp l WITH (NOLOCK) ON E.Emp_ID =  l.Emp_ID INNER JOIN
						( SELECT I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,TYPE_ID,I.Cmp_ID,I.CTC FROM T0095_Increment I WITH (NOLOCK) INNER JOIN 
							( SELECT MAX(Increment_ID) AS Increment_ID , Emp_ID FROM T0095_Increment WITH (NOLOCK)
							  WHERE Increment_Effective_date <= @To_Date AND Cmp_ID = @Cmp_ID GROUP BY emp_ID  
							) Qry ON I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID	 
						 ) I_Q  ON E.Emp_ID = I_Q.Emp_ID  INNER JOIN
						T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
						T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
						T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
						T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
						T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  INNER JOIN 
						T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID INNER JOIN
						( SELECT EP.Emp_Id ,Probation_Status,Evaluation_Date,Extend_Period,EP.New_Probation_EndDate AS New_Probation_EndDate,Flag ,EP.Old_Probation_Period,EP.Old_Probation_EndDate,Confirmation_date
						  FROM T0095_EMP_PROBATION_MASTER EP WITH (NOLOCK) INNER JOIN
							@Emp_Cons EC1 ON EP.Emp_ID = EC1.Emp_ID INNER JOIN 
							( SELECT MAX(New_Probation_EndDate) AS New_Probation_EndDate , EP2.Emp_ID FROM T0095_EMP_PROBATION_MASTER EP2 WITH (NOLOCK) INNER JOIN @Emp_Cons EC2 ON EP2.Emp_ID = EC2.Emp_ID 
							  WHERE (New_Probation_EndDate <= @To_Date OR EP2.Evaluation_Date <= @To_Date) AND Cmp_ID = @Cmp_ID AND Probation_Status = @Employee_Status 
								AND Flag = @Employee_Flag GROUP BY EP2.emp_ID  
							) Qry1 ON EP.Emp_ID = Qry1.Emp_ID AND EP.New_Probation_EndDate = Qry1.New_Probation_EndDate	 
						 ) EP_Q  ON E.Emp_ID = EP_Q.Emp_ID Left Outer JOIN
						 T0001_LOCATION_MASTER LM WITH (NOLOCK) ON Lm.Loc_ID = E.Loc_ID left join 
						 T0081_Emp_LetterRef_Details ELR WITH (NOLOCK) on ELR.Emp_Id = e.Emp_ID and ELR.Letter_Name='Confirmation Letter-'+ @Format_Type--Mukti(06012017) 	 							 
				WHERE E.Cmp_ID = @Cmp_Id 
					AND EP_Q.Probation_Status = @Employee_Status AND EP_Q.Flag = @Employee_Flag
					AND ( (EP_Q.Evaluation_Date <= @TO_DATE AND EP_Q.Evaluation_Date >= @FROM_DATE)
							OR (EP_Q.New_Probation_EndDate <= @TO_DATE AND EP_Q.New_Probation_EndDate >= @FROM_DATE ))
				
				ORDER BY RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500)
			END
		ELSE
			BEGIN
				SELECT I_Q.* ,E.Emp_Full_Name,E.Emp_Code,E.Alpha_Emp_Code,E.Initial,E.Emp_First_Name,E.Emp_Last_Name,Left_Date,BM.Comp_Name,BM.Branch_Address,Left_Reason
						,Dept_Name,Desig_Name,TYPE_NAME,Grd_Name,Branch_Name,Date_of_Join,Gender,@From_Date AS From_Date ,@To_Date AS To_Date
						,Cmp_Name,Cmp_Address,Present_Street,Present_State,Present_City,Present_Post_Box,l.left_reason
						,CM.Cmp_City,E.Father_name,ELR.Reference_No,ELR.Issue_Date		 --added jimit 04082016	
						,CM.Cmp_HR_Manager,CM.Cmp_HR_Manager_Desig    -- added Rudra 23042018
				FROM T0080_EMP_MASTER E WITH (NOLOCK) LEFT OUTER JOIN T0100_Left_Emp l WITH (NOLOCK) ON E.Emp_ID =  l.Emp_ID INNER JOIN
						( SELECT I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,TYPE_ID FROM T0095_Increment I WITH (NOLOCK) INNER JOIN 
							( SELECT MAX(Increment_ID) AS Increment_ID , Emp_ID FROM T0095_Increment WITH (NOLOCK)
							  WHERE Increment_Effective_date <= @To_Date AND Cmp_ID = @Cmp_ID GROUP BY emp_ID  
							) Qry ON I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID	 
						 ) I_Q  ON E.Emp_ID = I_Q.Emp_ID  INNER JOIN
						T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
						T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
						T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
						T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
						T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  INNER JOIN 
						T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID	left join 
						T0081_Emp_LetterRef_Details ELR WITH (NOLOCK) on ELR.Emp_Id = e.Emp_ID and ELR.Letter_Name='Confirmation Letter-'+ @Format_Type--Mukti(06012017) 	 							 
				WHERE E.Cmp_ID = @Cmp_Id AND E.emp_ID IN 
						(SELECT Emp_ID FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE E.EMP_CONFIRM_DATE <= @TO_DATE AND E.EMP_CONFIRM_DATE >= @FROM_DATE) 
						AND E.Emp_ID IN (SELECT Emp_ID FROM @Emp_Cons)
				ORDER BY RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) 
	
	
			END	
		
		
		
	
		
	RETURN
















