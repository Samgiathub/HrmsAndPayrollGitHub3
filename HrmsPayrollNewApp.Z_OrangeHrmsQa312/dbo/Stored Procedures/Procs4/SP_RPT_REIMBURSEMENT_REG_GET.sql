



-- =============================================
-- Author:		Nimesh Parmar
-- Create date: 26-May-2015
-- Description:	For customized Reimbursement Report
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_REIMBURSEMENT_REG_GET] 
	@Cmp_ID		numeric  
	,@From_Date		datetime
	,@To_Date 		datetime
	,@Branch_ID		varchar(max) = ''
	,@Grd_ID 		varchar(max) = ''
	,@Type_ID 		varchar(max) = ''
	,@Dept_ID 		varchar(max) = ''
	,@Desig_ID 		varchar(max) = ''
	,@Emp_ID 		numeric = 0
	,@Constraint	varchar(max) = ''
	,@Cat_ID        varchar(max) = ''
	,@mode			numeric(18,0) = 0
	,@Order_By   varchar(MAX) = 'Code' --Added by Jimit 29/09/2015 (To sort by Code/Name/Enroll No)

AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

	BEGIN TRY
		If OBJECT_ID('tempdb..#Emp_Cons') is not NULL	
			BEGIN
				Drop TABLE #Emp_Cons
			END
		CREATE table #Emp_Cons 
		(      
			Emp_ID NUMERIC ,     
			Branch_ID NUMERIC,
			Increment_ID NUMERIC
		)		
		exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@Constraint,0,0,'','','','',0,0,0,'0',0,0	
		
		if IsNull(@Constraint,'') = ''
			BEGIN
				SET @Constraint = NULL;
				Select @Constraint = COALESCE(@Constraint + '#', '') + Cast(Emp_ID As Varchar(10)) FROM #Emp_Cons;
			END
		
		IF (OBJECT_ID('tempdb..#TMP') IS NOT NULL)	
			DROP Table #TMP;
			
		create table #TMP
		(
			Reim_Tran_ID Numeric,
			Emp_ID  Numeric,
			AD_Name Varchar(max),
			Reim_Opening Numeric(18,2),
			Reim_Credit Numeric(18,2),
			Reim_Debit Numeric(18,2),
			Reim_Closing Numeric(18,2),
			For_Date DateTime,
			Emp_Full_Name Varchar(max),
			Emp_Code Varchar(max),
			Alpha_Emp_Code Varchar(max),
			Emp_First_Name Varchar(max),
			Left_Date DateTime,
			Comp_Name Varchar(max),
			Branch_Address Varchar(max),
			Left_Reason Varchar(max),
			Dept_Name Varchar(max),
			Desig_Name Varchar(max),
			[Type_Name] Varchar(max),
			Grd_Name Varchar(max),
			Branch_Name Varchar(max),
			Date_of_Join DateTime,
			Gender Varchar(10),
			From_Date DateTime,
			To_Date DateTime,
			Cmp_Name Varchar(max),
			Cmp_Address Varchar(max),
			Present_Street Varchar(max),
			Present_State Varchar(max),
			Present_City Varchar(max),
			Present_Post_Box Varchar(max),
			Left_reason1 Varchar(max),
			Branch_Id numeric(18,0),
			Desig_dis_No    numeric(18,0) DEFAULT 0,  --added jimit 29/09/2015
			Enroll_No       VARCHAR(50)	DEFAULT ''		 --added jimit 29/09/2015
		);
		
		IF (ISNULL(@Constraint,'') <> '') BEGIN
			Insert Into #TMP
			exec SP_RPT_EMP_ReimTransacation_RECORD_GET @Cmp_ID=@Cmp_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0,@Constraint=@Constraint,@RC_ID=0
		END 
		
		
		
		DELETE FROM #TMP WHERE IsNull(Reim_Credit,0)=0;
		
		IF (@mode = 1) BEGIN --Retreving Employee List
		
	
			Select DISTINCT			
			 T.Emp_ID,T.Emp_Code, T.Alpha_Emp_Code,T.Emp_Full_Name,V.Branch_ID,V.mobile_no,T.Enroll_No,isnull(T.Desig_dis_No,0) as Desig_dis_No
			 ,(CASE WHEN  @Order_By = 'Enroll_No' THEN T.Enroll_No  
							WHEN @Order_By = 'Name' THEN T.Emp_Full_Name 
							When @Order_By = 'Designation' then (CASE WHEN T.Desig_dis_No  = 0 THEN T.Dept_Name ELSE RIGHT(REPLICATE('0',21) + CAST(T.Desig_dis_No AS VARCHAR), 21)   END) 
							--ELSE RIGHT(REPLICATE(N' ', 500) + T.Alpha_Emp_Code, 500) 
						End ) as Order_By,(Case When IsNumeric(Replace(Replace(T.Alpha_Emp_Code,'="',''),'"','')) = 1 then Right(Replicate('0',21) + Replace(Replace(T.Alpha_Emp_Code,'="',''),'"',''), 20)
								 When IsNumeric(Replace(Replace(T.Alpha_Emp_Code,'="',''),'"','')) = 0 then Left(Replace(Replace(T.Alpha_Emp_Code,'="',''),'"','') + Replicate('',21), 20)
								 Else Replace(Replace(T.Alpha_Emp_Code,'="',''),'"','') End) as Order_By1
								 ,V.Vertical_ID,V.SubVertical_ID,V.Dept_ID   --Added By Jaina 7-10-2015
			 FROM	#TMP T INNER JOIN V0080_Employee_Master V ON T.Emp_ID=V.Emp_ID
			WHERE	V.Cmp_ID=@Cmp_ID 
			--ORDER By T.Enroll_No			
			ORDER BY Order_By--,Order_By1
			--RIGHT(REPLICATE(N' ', 500) + T.Alpha_Emp_Code, 500)		
			
			
			RETURN;
		END 
		
		DECLARE @SQL NVARCHAR(MAX);
		DECLARE @COLUMNS NVARCHAR(MAX);
		
		SELECT	@COLUMNS = COALESCE(@COLUMNS + ',' , '') + '[' + T.AD_Name + ']' 
		FROM	#TMP T
		GROUP BY T.AD_Name;
		SET @COLUMNS = REPLACE(@COLUMNS, ' ', '_');
		
		DECLARE @TOP VARCHAR(20);
		SET @TOP = ''
		
		IF (@mode = 2) --Retreving Column List
			SET @TOP = ' TOP 0'
		
		DECLARE @SUM_COLS VARCHAR(MAX);
		SET @SUM_COLS = 'IsNull(' + REPLACE(@COLUMNS, ',', ',0) + IsNull(') + ',0)';

		if @Order_By = 'Code' 
			set @Order_By = 'Case When IsNumeric(Replace(Replace(Emp_Code,''="'',''''),''"'','''')) = 1 then Right(Replicate(''0'',21) + Replace(Replace(Emp_Code,''="'',''''),''"'',''''), 20)
								 When IsNumeric(Replace(Replace(Emp_Code,''="'',''''),''"'','''')) = 0 then Left(Replace(Replace(Emp_Code,''="'',''''),''"'','''') + Replicate('''',21), 20)
								 Else Replace(Replace(Emp_Code,''="'',''''),''"'','''') End	'
		ELSE IF @Order_By = 'Enroll_No'
			set @Order_by = 'RIGHT(REPLICATE(''0'',21) + CAST(Enroll_No AS VARCHAR), 21)'
		ELSE IF @Order_By = 'Designation'
			Set @Order_By = '(CASE WHEN Desig_dis_No  = 0 THEN Designation ELSE RIGHT(REPLICATE(''0'',21) + CAST(Desig_dis_No AS VARCHAR), 21)   END) 
							'
				
		SET @SQL = ';WITH TEMP(Emp_ID,Emp_Code,Employee_Name,Branch_ID,Branch,Designation,Department,Grade,[Type],Date_Of_Join,Basic,Gross,' + @COLUMNS  + ',Desig_dis_No,Enroll_No) AS
		(
			Select ' + @TOP + ' Emp_ID,Emp_Code,Employee_Name,Branch_ID,Branch,Designation,Department,Grade,[Type],Date_Of_Join,Basic,Gross,' + @COLUMNS  + ',Desig_dis_No,Enroll_No
			FROM	(
						SELECT	T.Emp_ID,(''="'' + Alpha_Emp_Code + ''"'') As Emp_Code,Emp_Full_Name As Employee_Name,Branch_ID,Branch_Name As Branch,Desig_Name As Designation,Dept_Name As Department,Grd_Name As Grade,[Type_Name] As Type,REPLACE(convert(VARCHAR(20), Date_Of_Join, 106), '' '', ''/'') AS Date_Of_Join,S.Basic_Salary As Basic,S.Gross_Salary As Gross,REPLACE(AD_Name, '' '', ''_'') As AD_Name,Reim_Credit,Desig_dis_No,Enroll_No  
						FROM	#TMP T INNER JOIN dbo.T0200_MONTHLY_SALARY S ON T.Emp_ID=S.Emp_ID
						WHERE	S.Cmp_ID=' +  CAST(@Cmp_ID As Varchar(10)) + '
								AND MONTH(S.Month_St_Date)= ' + Cast(MONTH(@TO_Date) As Varchar(10)) + ' 
								AND YEAR(S.Month_St_Date)=' + Cast(YEAR(@TO_Date) As Varchar(10)) + ' 
					 ) AS ST
					 PIVOT
					 (
						SUM(Reim_CREDIT)
						FOR Ad_Name IN (' + @COLUMNS + ')
					 ) AS PT
		)
		Select	* 
		INTO	##REIMB
		FROM	TEMP Order By ' + @Order_By + ''

	print @SQL
		EXECUTE (@SQL);
			
		
		SET @SQL =	'SELECT	*, ( ' + @SUM_COLS + ' ) As Total FROM	##REIMB';
		
		
		EXECUTE (@SQL);
		
		
		SET @SQL = 'DROP TABLE ##REIMB;';		

		EXECUTE (@SQL);
		
	END TRY
	BEGIN CATCH 
		print ERROR_MESSAGE();
	END CATCH 
END

