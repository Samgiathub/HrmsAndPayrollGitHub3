


-- exec  [dbo].[SP_EMP_SALARY_RECORD_GET1] 121,'10/1/2022','10/31/2022',0,'','',0,'','',26749,'','All',0,'','','','','',0
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_EMP_SALARY_RECORD_GET2]
	 @Cmp_ID		NUMERIC
	,@From_Date		DATETIME
	,@To_Date		DATETIME 
	,@Branch_ID		NUMERIC   = 0
	,@Cat_ID		VARCHAR(MAX) = '' --  Added by nilesh on 01-Nov-2014 For Multiselection Category 
	,@Grd_ID		VARCHAR(MAX) = '' --  Added by nilesh on 26-Aug-2014 For Multiselection Grade
	,@Type_ID		VARCHAR(MAX) = ''
	,@Dept_ID		VARCHAR(MAX) = '' --  Added by nilesh on 26-Aug-2014 For Multiselection Dept
	,@Desig_ID		VARCHAR(MAX) = '' --  Added by nilesh on 26-Aug-2014 For Multiselection Desig
	,@Emp_ID		NUMERIC  = 0
	,@Constraint	VARCHAR(MAX) = ''
	,@Salary_Status	VARCHAR(10)='All'
	,@Salary_Cycle_id  NUMERIC  = 0
	,@Branch_Constraint VARCHAR(MAX) = '' -- Added By Gadriwala Muslim on july 16 2013
	,@Segment_ID VARCHAR(MAX) = '' -- Added By nilesh on 03-Nov-2014
	,@Vertical VARCHAR(MAX) = '' -- Added By nilesh on 03-Nov-2014
	,@SubVertical VARCHAR(MAX) = '' -- Added By nilesh on 03-Nov-2014
	,@subBranch VARCHAR(MAX) = '' -- Added By nilesh on 03-Nov-2014
	,@FilterType Numeric(2,0) = 0
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	DECLARE @Date_Diff NUMERIC 
	
	SET @Date_Diff = DATEDIFF(d,@From_Date,@To_date) + 1
	
		-- Added by rohit Fin Start Date on 27082014
	Declare @Fin_Start_Date as Datetime

	if MONTH(@To_Date) > 3
		begin
			set @Fin_Start_Date = '01-apr-'  + Convert(nvarchar,YEAR(@To_Date)) 
		end
	else
		begin
			set @Fin_Start_Date = '01-apr-' + Convert(nvarchar,(YEAR(@To_Date) - 1))
		end
	

	
	DECLARE @Show_Left_Employee_for_Salary AS TINYINT
	SET @Show_Left_Employee_for_Salary = 0
  
	SELECT @Show_Left_Employee_for_Salary = ISNULL(Setting_Value,0) 
		FROM T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Setting_Name LIKE 'Show Left Employee for Salary'
		
		

	DECLARE @Emp_Pt_Setting AS TINYINT
	SET @Emp_Pt_Setting = 0
	
	SELECT @Emp_Pt_Setting = ISNULL(Setting_Value,0) 
		FROM T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Setting_Name LIKE 'Show list of employees whose PT settings are pending during Salary Process'
		
	DECLARE @Pending_Leave_Setting AS TINYINT
	SET @Pending_Leave_Setting = 0
	
	SELECT @Pending_Leave_Setting = ISNULL(Setting_Value,0) 
		FROM T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Setting_Name LIKE 'Leave not Approval Popup in Salary'
	
	
	CREATE table #Emp_Cons 
	(      
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC    
	)      
	--select  @Cmp_ID, @From_Date, @To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID	,@Desig_ID,@Emp_ID,@Salary_Cycle_id ,@Branch_Constraint,@Segment_ID,@Vertical,@SubVertical,@subBranch,@Constraint
	-- Create New Sp by nilesh patel on 28-Aug-2014
	--select  @Cmp_ID, @From_Date, @To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@Salary_Cycle_id ,@Branch_Constraint,@Segment_ID,@Vertical,@SubVertical,@subBranch,@Constraint	-- Changed By Gadriwala 11092013
	EXEC SP_EMP_SALARY_Constraint @Cmp_ID, @From_Date, @To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID	,@Desig_ID,@Emp_ID,@Salary_Cycle_id ,@Branch_Constraint,@Segment_ID,@Vertical,@SubVertical,@subBranch,@Constraint	-- Changed By Gadriwala 11092013
	--exec  [dbo].[SP_EMP_SALARY_Constraint] @Cmp_ID, @From_Date, @To_Date,@Branch_ID,@Cat_ID,@Grd_ID,'',@Dept_ID,@Desig_ID,@Emp_ID,@Salary_Cycle_id ,@Branch_Constraint,@Segment_ID,@Vertical,@SubVertical,@subBranch,@Constraint
	
	
	-- exec  [dbo].[SP_EMP_SALARY_RECORD_GET1] 121,'10/1/2022','10/31/2022',0,'','',0,'','',26749,'','All',0,'','','','','',0
	-- exec  [dbo].[SP_EMP_SALARY_Constraint] '121','2022-10-01 00:00:00.000','2022-10-31 00:00:00.000',0,'','','','','',26749,0,'','','','','',''
	DECLARE @TEMP_CONSTRAINT VARCHAR(MAX)
	SELECT	@TEMP_CONSTRAINT = COALESCE(@TEMP_CONSTRAINT + '#', '')  + CAST(EMP_ID AS VARCHAR(12))
	FROM	#Emp_Cons

	CREATE TABLE #EMP_SAL_PERIOD(EMP_ID NUMERIC, Branch_ID NUMERIC, Sal_St_Date DATETIME, Sal_End_Date DATETIME, Manual_Salary_Period TINYINT, Is_CutOff TinyInt, NormalSalCycle BIT, NoOfDays int);
	EXEC [P_GET_SAL_PERIOD] @TEMP_CONSTRAINT, @To_Date

	IF EXISTS(SELECT 1 FROM #EMP_SAL_PERIOD)
	BEGIN
			DELETE	EC 
			FROM	#Emp_Cons EC						
					INNER JOIN #EMP_SAL_PERIOD SAL ON EC.Emp_ID=SAL.EMP_ID			
					INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EC.Emp_ID=EM.Emp_ID  AND (EM.Date_Of_Join > SAL.Sal_End_Date OR ISNULL(EM.Emp_Left_Date, SAL.Sal_End_Date) < SAL.Sal_St_Date )			
			where sal.NoOfDays >= 28
	END

	If OBJECT_ID('tempdb..##Att_Muster1') IS NOT NULL 
		Begin
			DROP TABLE ##Att_Muster1
		end
		
	-- Color Flag Description
	/*
		1 For  No PAN Card / No Document 
		2 For Previouse month Salary on hold 	
		3 For Both No PAN Card & Previous month salary on hold
	*/
	
	--Added by nilesh patel on 18042017 
    IF Object_ID('tempdb..#Emp_Doc') is not null
		Begin
			Drop TABLE #Emp_Doc
		End
  
	SELECT	DISTINCT T.Emp_ID Into #Emp_Doc
	FROM	(
				SELECT	E.EMP_ID, DOC_ID 
				FROM	T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN #Emp_Cons EC ON EC.Emp_ID = E.Emp_ID
						CROSS JOIN (SELECT DOC_ID FROM T0040_DOCUMENT_MASTER DM WITH (NOLOCK) WHERE DM.Cmp_ID= @Cmp_ID AND Doc_Required = 1) DM
				WHERE	E.Cmp_ID = @Cmp_ID
			)T 
	WHERE	NOT EXISTS(SELECT 1 FROM T0090_EMP_DOC_DETAIL EDM WITH (NOLOCK) WHERE T.Emp_ID=EDM.Emp_ID AND T.Doc_ID=EDM.Doc_ID AND EDM.Cmp_ID = @Cmp_ID )
  --Added by nillesh patel on 18042017
	
	
 --Added by nilesh patel on 20042017 
  IF Object_ID('tempdb..#Emp_Salary_On_Hold') is not null
		Begin
			Drop TABLE #Emp_Salary_On_Hold
		End
		
	  Select EC.EMP_ID Into #Emp_Salary_On_Hold
	  From #Emp_Cons EC Inner Join T0090_Change_Request_Approval CRA WITH (NOLOCK)
	  ON EC.Emp_ID = CRA.Emp_ID
	  Where CRA.Loan_Month = MONTH(@From_Date) and CRA.Loan_Year = YEAR(@From_Date) 
	  and CRA.Request_Type_id = 19 and CRA.Request_status = 'A'
  --Added by nilesh patel on 20042017 
	
	CREATE table ##Att_Muster1
	(
		Emp_Id NUMERIC , 
		Cmp_ID NUMERIC,
		Leave_Count NUMERIC(5,1) DEFAULT 0,
		WO NUMERIC(5,1) DEFAULT 0,
		HO NUMERIC(5,1) DEFAULT 0,
		Total_cycle_days NUMERIC(18,0),
		Total_Present NUMERIC(18,2)			
	)
	
	CREATE TABLE #Salary_Temp
	(
		Sal_tran_ID NUMERIC , 
		Emp_ID NUMERIC,
		Pan_No Varchar(100),
		Comp_Name Varchar(500),
		Cmp_Name Varchar(500),
		Cmp_Address Varchar(500),
		Branch_Name Varchar(500),
		Emp_Full_Name Varchar(500),
		[Status] Varchar(100),
		Branch_ID  NUMERIC(18,0),
		Vertical_ID  NUMERIC(18,0),
		SubVertical_ID  NUMERIC(18,0),
		Dept_ID Numeric(18,0),  --Added By Jaina 29-09-2015
		Dept_Name Varchar(500),  --Tejas
		Segment_Name Varchar(500),  --Tejas
		Center_Name Varchar(500),  --Tejas
		Color_flag NUMERIC(1,0),
		Emp_Left	VARCHAR(1) DEFAULT '', --Ankit 27062016
		Emp_Fix_Salary Tinyint,   --Added By Jaina 07-09-2016
		Emp_Exit Tinyint  --Added by Mukti(19122019)
	)
	--INSERT INTO ##Att_Muster1 
	-- added by mitesh for actual days present in manual salary on 16012013
	-- EXEC SP_RPT_EMP_ATTENDANCE_MANUAL_SALARY_DAYS @Cmp_ID, @From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID	,@Desig_ID,@Emp_ID,@Constraint,'','',@Branch_Constraint	-- Changed By Gadriwala 11092013
	-- Comment by nilesh patel on 1-Sept-2014 as per discussion with hardik bhai (Calculate Days)	 
	IF @Salary_Status = 'Done'
		BEGIN		
			IF @Show_Left_Employee_for_Salary = 0 
				BEGIN
					Insert into #Salary_Temp
					SELECT Sal_tran_ID, e.Emp_Id, Pan_No, BM.Comp_Name, CM.Cmp_Name, Cm.Cmp_Address, BM.Branch_address
							,CAST(E.Alpha_Emp_Code AS VARCHAR) + ' - '+E.Emp_Full_Name AS Emp_Full_Name,M_IT_Tax
							,CASE WHEN M_OT_Hours > 0 THEN M_OT_Hours ELSE Over_Time END AS M_OT_Hours
							,Other_Dedu_Amount, M_LOAN_AMOUNT, IsNull(Advance_Amount,M_ADV_AMOUNT) As M_ADV_AMOUNT, Other_Allow_Amount
							,am1.total_present As Month_days, ISNULL(ISNULL(Present_Days,P_DAYS), am1.total_present)Present_Days
							--,CASE WHEN NOT Sal_Tran_ID IS NULL THEN 'Done' ELSE	'' END Status
							--,SG.Salary_Status AS Status
							,(Case When Isnull(SH.Emp_ID,0) <> 0 Then 'Hold' Else SG.Salary_Status END) AS Status
							,P_DAYS,I_Q.Branch_ID, I_Q.Vertical_ID,I_Q.SubVertical_ID,I_Q.Dept_ID,MSP.Salary_Status as PMonth_Status -- add by Gadriwala 16102013 E.Vertical_ID,E.SubVertical_ID  Added By Jaina 29-09-2015 Dept_id
							,(case when MSP.Salary_Status = 'Hold' and Pan_No = '' then 3 when MSP.Salary_Status = 'Hold' then 2  when Pan_No = '' OR Isnull(Doc.Emp_ID,0) <> 0 then 1 else 0 end) as Color_flag,0,0,0
							,E.Emp_Left--Ankit 27062016
							,I_Q.Emp_Fix_Salary,CASE WHEN EA.exit_id > 0 then 1 else 0 end  --Jaina 07-09-2016
						FROM T0080_EMP_MASTER E WITH (NOLOCK)
							LEFT OUTER JOIN ##Att_Muster1 am1 ON am1.emp_id = E.Emp_ID 
							LEFT OUTER JOIN (SELECT I.Emp_Id, Grd_ID, Branch_ID, Cat_ID, Desig_ID, Dept_ID, TYPE_ID ,Vertical_ID,SubVertical_ID,I.Emp_Fix_Salary
												FROM T0095_Increment I WITH (NOLOCK)
													INNER JOIN (SELECT MAX(Increment_ID) AS Increment_ID, Emp_ID 
																	FROM T0095_Increment WITH (NOLOCK)
																	WHERE Increment_Effective_date <= @To_Date AND Cmp_ID = @Cmp_ID
																	GROUP BY emp_ID 
																) Qry ON I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID	 
											) I_Q ON E.Emp_ID = I_Q.Emp_ID  
							INNER JOIN #Emp_Cons EC ON E.Emp_ID = EC.Emp_ID							
							-- INNER JOIN T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID 
							-- LEFT OUTER JOIN T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID 
							-- LEFT OUTER JOINT0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id
							-- LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id 
							INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
							(select Emp_ID,Salary_Status from T0200_MONTHLY_SALARY WITH (NOLOCK) where Month_St_Date <= DateAdd(m,-1,@From_Date) and Month_End_Date >= DateAdd(m,-1,@To_Date))MSP ON
								E.Emp_ID = MSP.Emp_ID  -- Added by nilesh patel on 04112014 for pan & hold indication
							INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID
							LEFT OUTER JOIN (SELECT MS.EMP_ID,Present_Days, Sal_Tran_ID, M_OT_Hours, M_Loan_Amount, M_IT_Tax, Other_Dedu_Amount
													,Other_Allow_Amount, IT_M_ED_Cess_Amount, IT_M_Surcharge_Amount ,Salary_Status, Advance_Amount
												FROM T0200_MONTHLY_SALARY MS WITH (NOLOCK)
													INNER JOIN #Emp_Cons EC ON MS.EMP_ID = EC.EMP_ID 
												WHERE CMP_ID = @CMP_ID AND MONTH_END_DATE >=@FROM_DATE AND MONTH_END_DATE <=@TO_DATE
											 )SG ON E.EMP_ID = SG.EMP_ID 
							LEFT OUTER JOIN (SELECT MPI.EMP_ID, P_DAYS, Over_Time 
												FROM T0190_MONTHLY_PRESENT_IMPORT MPI WITH (NOLOCK)
													INNER JOIN #Emp_Cons EC ON MPI.EMP_ID = EC.EMP_ID 
												WHERE CMP_ID = @CMP_ID AND MPI.month = MONTH(@to_date) AND mpi.year = YEAR(@to_date)
											 )Q_MPI	ON E.EMP_ID =Q_MPI.EMP_ID  
							LEFT OUTER JOIN (SELECT Adv_Closing AS M_ADV_AMOUNT,ADVT.Emp_ID  FROM T0140_Advance_Transaction ADVT WITH (NOLOCK) INNER JOIN 
													( SELECT MAX(For_Date) AS For_Date , Emp_ID FROM T0140_Advance_Transaction WITH (NOLOCK)
														WHERE For_Date <= @To_Date AND Cmp_ID = @Cmp_ID GROUP BY emp_ID  ) Qry ON ADVT.Emp_ID = Qry.Emp_ID AND ADVT.For_Date = Qry.For_Date	
												) I_Q1 ON E.Emp_ID = I_Q1.Emp_ID INNER JOIN     
							T0011_Login LO WITH (NOLOCK) ON LO.Emp_Id = E.Emp_Id	
							Left OUTER JOIN 
							(
								SELECT Emp_ID FROM #Emp_Doc
							) as Doc ON Doc.Emp_ID = E.Emp_Id
							Left Outer JOIN
								(
								   Select Emp_ID From #Emp_Salary_On_Hold
								) as SH ON SH.Emp_ID = E.Emp_Id	
							LEFT OUTER JOIN T0200_Emp_ExitApplication EA WITH (NOLOCK) ON EA.emp_id=E.Emp_ID and EA.[status]<>'R'  --Mukti(19122019)
						WHERE E.Cmp_ID = @Cmp_Id and LO.Is_Active =1 
							AND ((@From_Date < E.Emp_LEft_Date AND @To_Date < E.Emp_LEft_Date) OR E.Emp_LEft_Date IS NULL)	
							--and Tp.for_Date>= @FROM_DATE and Tp.for_Date<=@To_Date
							AND E.Emp_ID IN (SELECT Emp_ID FROM #Emp_Cons) 
							AND Sal_Tran_ID IS NOT NULL		--Alpesh 2-Jun-2012				
						ORDER BY  Emp_Code ASC
						
				END
			ELSE
				BEGIN
					
					Insert into #Salary_Temp
					SELECT Sal_tran_ID, e.Emp_Id, Pan_No, BM.Comp_Name, CM.Cmp_Name, Cm.Cmp_Address, BM.Branch_Name
							,CAST( E.Alpha_Emp_Code AS VARCHAR) + ' - '+E.Emp_Full_Name AS Emp_Full_Name
							,CASE WHEN NOT Sal_Tran_ID IS NULL THEN 'Done' ELSE '' END Status
							,I_Q.Branch_ID, I_Q.Vertical_ID,I_Q.SubVertical_ID,I_Q.Dept_ID,DM.Dept_Name -- add by Gadriwala 16102013 E.Vertical_ID,E.SubVertical_ID
							,BS.Segment_Name,CS.Center_Name
							,(case when MSP.Salary_Status = 'Hold' and Pan_No = '' then 3 when MSP.Salary_Status = 'Hold' then 2  when Pan_No = '' OR Isnull(Doc.Emp_ID,0) <> 0 then 1 else 0 end) as Color_flag
							,E.Emp_Left--Ankit 27062016
							,I_Q.Emp_Fix_Salary,case when EA.exit_id > 0 then 1 else 0 end  --Jaina 07-09-2016
						FROM T0080_EMP_MASTER E WITH (NOLOCK)
							LEFT OUTER JOIN ##Att_Muster1 am1 ON am1.emp_id = E.Emp_ID 
							LEFT OUTER JOIN (SELECT I.Emp_Id, Grd_ID, Branch_ID, Cat_ID, Desig_ID, Dept_ID, TYPE_ID ,Vertical_ID,SubVertical_ID,I.Emp_Fix_Salary
													,I.Segment_ID,I.Center_ID
												FROM T0095_Increment I WITH (NOLOCK)
													INNER JOIN (SELECT MAX(Increment_ID) AS Increment_ID, Emp_ID 
																	FROM T0095_Increment WITH (NOLOCK)
																	WHERE Increment_Effective_date <= @To_Date AND Cmp_ID = @Cmp_ID
																	GROUP BY emp_ID
																) Qry ON I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID
											) I_Q ON E.Emp_ID = I_Q.Emp_ID 
							INNER JOIN #Emp_Cons EC ON E.Emp_ID = EC.Emp_ID 	
							LEFT JOIN (select Emp_ID from T0210_MONTHLY_Sal_POS_DETAIL Where Post__Date = @From_Date and  R_Post_Req_ID IS NULL group by EMP_ID) ES ON ES.EMP_ID = EC.Emp_ID
							-- INNER JOIN T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID 
							-- LEFT OUTER JOIN T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID 
							-- LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id 
							 LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id 
							INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 
							INNER JOIN T0040_Business_Segment BS ON BS.Cmp_id  = @Cmp_ID AND BS.Segment_ID = I_Q.Segment_ID
							INNER JOIN T0040_COST_CENTER_MASTER CS ON CS.Cmp_ID =  @Cmp_ID AND CS.Center_ID = I_Q.Center_ID
							LEFT OUTER JOIN
							(select Emp_ID,Salary_Status from T0200_MONTHLY_SALARY WITH (NOLOCK) where Month_St_Date <= DateAdd(m,-1,@From_Date) and Month_End_Date >= DateAdd(m,-1,@To_Date))MSP ON
								E.Emp_ID = MSP.Emp_ID  -- Added by nilesh patel on 04112014 for pan & hold indication
							INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID 
							LEFT OUTER JOIN (SELECT MS.EMP_ID, Present_Days, Sal_Tran_ID, M_OT_Hours, M_Loan_Amount, M_IT_Tax, Other_Dedu_Amount
													,Other_Allow_Amount, IT_M_ED_Cess_Amount, IT_M_Surcharge_Amount,Salary_Status 
												FROM T0200_MONTHLY_SALARY MS WITH (NOLOCK)
													INNER JOIN #Emp_Cons EC ON MS.EMP_ID = EC.EMP_ID 
												WHERE CMP_ID = @CMP_ID AND MONTH_END_DATE >= @FROM_DATE AND MONTH_END_DATE <= @TO_DATE
											 )SG ON E.EMP_ID  =SG.EMP_ID 
							LEFT OUTER JOIN (SELECT MPI.EMP_ID, P_DAYS, Over_Time 
												FROM T0190_MONTHLY_PRESENT_IMPORT MPI WITH (NOLOCK)
													INNER JOIN #Emp_Cons EC ON MPI.EMP_ID = EC.EMP_ID 
												WHERE CMP_ID = @CMP_ID AND MPI.month = MONTH(@to_date) AND mpi.year = YEAR(@to_date) 
											 )Q_MPI	ON E.EMP_ID =Q_MPI.EMP_ID 
							LEFT OUTER JOIN (SELECT Adv_Closing AS M_ADV_AMOUNT,ADVT.Emp_ID  FROM T0140_Advance_Transaction ADVT WITH (NOLOCK) INNER JOIN 
													( SELECT MAX(For_Date) AS For_Date , Emp_ID FROM T0140_Advance_Transaction WITH (NOLOCK)
														WHERE For_Date <= @To_Date AND Cmp_ID = @Cmp_ID GROUP BY emp_ID  ) Qry ON ADVT.Emp_ID = Qry.Emp_ID AND ADVT.For_Date = Qry.For_Date	
												) I_Q1 ON E.Emp_ID = I_Q1.Emp_ID 
												INNER JOIN     
							T0011_Login LO  WITH (NOLOCK) ON LO.Emp_Id = E.Emp_Id	
							Left OUTER JOIN 
							(
								SELECT Emp_ID FROM #Emp_Doc
							) as Doc ON Doc.Emp_ID = E.Emp_Id
							LEFT OUTER JOIN T0200_Emp_ExitApplication EA WITH (NOLOCK) ON EA.emp_id=E.Emp_ID and EA.[status]<>'R' --Mukti(19122019)
						WHERE E.Cmp_ID = @Cmp_Id  and LO.Is_Active =1 AND ES.EMP_ID  IS NULL
							--And ((@From_Date < E.Emp_LEft_Date And @To_Date > E.Emp_LEft_Date) or E.Emp_LEft_Date is null)	
							--and Tp.for_Date>= @FROM_DATE and Tp.for_Date<=@To_Date
							AND E.Emp_ID IN (SELECT Emp_ID FROM #Emp_Cons) 
							AND Sal_Tran_ID IS NOT NULL		--Alpesh 2-Jun-2012				
						ORDER BY  Emp_Code ASC
						
				END
		END	
	ELSE IF @Salary_Status = 'Pending'
		BEGIN
			
			IF @Show_Left_Employee_for_Salary = 0
				BEGIN
					Insert into #Salary_Temp
					SELECT	Sal_tran_ID,e.Emp_Id,Pan_No,BM.Comp_Name,CM.Cmp_Name,Cm.Cmp_Address,BM.Branch_address,CAST( E.Alpha_Emp_Code AS VARCHAR) + ' - '+E.Emp_Full_Name AS Emp_Full_Name,M_IT_Tax,
							CASE WHEN M_OT_Hours > 0 THEN
							M_OT_Hours ELSE Over_Time END AS M_OT_Hours,Other_Dedu_Amount,M_LOAN_AMOUNT,M_ADV_AMOUNT,Other_Allow_Amount
							--,@Date_Diff	Month_days	, Isnull(isnull(Present_Days,P_DAYS),@Date_Diff)Present_Days ,
							,am1.total_present  	Month_days	, ISNULL(ISNULL(Present_Days,P_DAYS),am1.total_present  )Present_Days ,
							--CASE WHEN NOT Sal_Tran_ID IS NULL THEN
							--	'Done'
							--ELSE
							--	''
							--END Status
							--SG.Salary_Status AS Status
							(Case When Isnull(SH.Emp_ID,0) <> 0 Then 'Hold' Else SG.Salary_Status END) AS Status
							,P_DAYS,I_Q.Branch_ID, I_Q.Vertical_ID,I_Q.SubVertical_ID,I_Q.Dept_ID,MSP.Salary_Status as PMonth_Status -- add by Gadriwala 16102013 E.Vertical_ID,E.SubVertical_ID Added By Jaina 29-09-2015 Dept_id
							,(case when MSP.Salary_Status = 'Hold' and Pan_No = '' then 3 when MSP.Salary_Status = 'Hold' then 2  when Pan_No = '' OR Isnull(Doc.Emp_ID,0) <> 0 then 1 else 0 end) as Color_flag,0,0,0
							,E.Emp_Left--Ankit 27062016
							,I_Q.Emp_Fix_Salary,case when EA.exit_id > 0 then 1 else 0 end  --Jaina 07-09-2016							
					FROM	T0080_EMP_MASTER E WITH (NOLOCK)
							INNER JOIN #Emp_Cons EC ON E.Emp_ID=EC.Emp_ID
							INNER JOIN T0095_Increment I_Q WITH (NOLOCK) ON EC.Increment_ID=I_Q.Increment_ID
							INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID 
							LEFT OUTER JOIN ##Att_Muster1 am1 ON am1.emp_id = E.Emp_ID 
							--LEFT OUTER JOIN (SELECT I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,TYPE_ID,Vertical_ID,SubVertical_ID,I.Emp_Fix_Salary  
							--				FROM	T0095_Increment I 
							--						INNER JOIN ( SELECT MAX(Increment_ID) AS Increment_ID , Emp_ID FROM T0095_Increment
							--									WHERE Increment_Effective_date <= @To_Date
							--											AND Cmp_ID = @Cmp_ID
							--									GROUP BY emp_ID  ) Qry ON
							--	I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID	 ) I_Q ON E.Emp_ID = I_Q.Emp_ID 
							INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  
							--T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
								--T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
								--T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
								--T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
							LEFT OUTER JOIN (SELECT Emp_ID,Salary_Status 
											FROM	T0200_MONTHLY_SALARY WITH (NOLOCK)
											WHERE	Month_St_Date <= DateAdd(m,-1,@From_Date) and Month_End_Date >= DateAdd(m,-1,@To_Date))MSP ON E.Emp_ID = MSP.Emp_ID  -- Added by nilesh patel on 04112014 for pan & hold indication 
							LEFT OUTER JOIN (SELECT MS.EMP_ID,Present_Days ,Sal_Tran_ID,M_OT_Hours,M_Loan_Amount,M_IT_Tax,Other_Dedu_Amount,Other_Allow_Amount,IT_M_ED_Cess_Amount,IT_M_Surcharge_Amount ,Salary_Status
											 FROM 	T0200_MONTHLY_SALARY MS  WITH (NOLOCK)
													INNER JOIN #Emp_Cons EC ON MS.EMP_ID = EC.EMP_ID 
											 WHERE	CMP_ID = @CMP_ID AND MONTH_END_DATE >=@FROM_DATE AND MONTH_END_DATE <=@TO_DATE
											 )SG ON E.EMP_ID  =SG.EMP_ID 
							LEFT OUTER JOIN (SELECT MPI.EMP_ID,P_DAYS,Over_Time 
											 FROM 	T0190_MONTHLY_PRESENT_IMPORT MPI  WITH (NOLOCK)
													INNER JOIN #Emp_Cons EC ON MPI.EMP_ID = EC.EMP_ID 
											 WHERE	CMP_ID = @CMP_ID  AND MPI.month = MONTH(@to_date) AND mpi.year = YEAR(@to_date) 
											 )Q_MPI	ON E.EMP_ID =Q_MPI.EMP_ID --AND FOR_DATE >=@FROM_DATE AND FOR_DATE <=@TO_DATE
							LEFT OUTER JOIN (SELECT Adv_Closing AS M_ADV_AMOUNT,ADVT.Emp_ID  
											 FROM	T0140_Advance_Transaction ADVT WITH (NOLOCK)
													INNER JOIN (SELECT	MAX(For_Date) AS For_Date , Emp_ID 
																FROM	T0140_Advance_Transaction WITH (NOLOCK)
																WHERE	For_Date <= @To_Date AND Cmp_ID = @Cmp_ID 
																GROUP BY emp_ID) Qry ON ADVT.Emp_ID = Qry.Emp_ID AND ADVT.For_Date = Qry.For_Date	
																) I_Q1 ON E.Emp_ID = I_Q1.Emp_ID 
							INNER JOIN T0011_Login LO  WITH (NOLOCK) ON LO.Emp_Id = E.Emp_Id
							Left OUTER JOIN #Emp_Doc Doc ON Doc.Emp_ID = E.Emp_Id
							Left Outer JOIN #Emp_Salary_On_Hold SH ON SH.Emp_ID = E.Emp_Id
							LEFT OUTER JOIN T0200_Emp_ExitApplication EA WITH (NOLOCK) ON EA.emp_id=E.Emp_ID and EA.[status]<>'R' --Mukti(19122019)
					WHERE	E.Cmp_ID = @Cmp_Id  and LO.Is_Active =1
							AND ((@From_Date < E.Emp_LEft_Date AND @To_Date < E.Emp_LEft_Date) OR E.Emp_LEft_Date IS NULL)	
							--and Tp.for_Date>= @FROM_DATE and Tp.for_Date<=@To_Date
							--AND E.Emp_ID IN (SELECT Emp_ID FROM #Emp_Cons) 
							AND Sal_Tran_ID IS NULL					
					ORDER BY  e.Emp_Code ASC
					
				END
			ELSE
				BEGIN
					
					Insert into #Salary_Temp
					SELECT Sal_tran_ID,e.Emp_Id,Pan_No,BM.Comp_Name,CM.Cmp_Name,Cm.Cmp_Address,BM.Branch_Name,CAST( E.Alpha_Emp_Code AS VARCHAR) + ' - '+E.Emp_Full_Name AS Emp_Full_Name,
							Case When Isnull(SH.Emp_ID,0) <> 0 Then 'Hold' Else SG.Salary_Status END AS 'Status'
							,I_Q.Branch_ID, I_Q.Vertical_ID,I_Q.SubVertical_ID,I_Q.Dept_ID,DM.Dept_Name,
							(case when MSP.Salary_Status = 'Hold' and Pan_No = '' then 3 when MSP.Salary_Status = 'Hold' then 2  when Pan_No = '' OR Isnull(Doc.Emp_ID,0) <> 0 then 1 else 0 end) as Color_flag
							,E.Emp_Left,I_Q.Emp_Fix_Salary,case when EA.exit_id > 0 then 1 else 0 end as Emp_Exit --Jaina 07-09-2016
					FROM T0080_EMP_MASTER E WITH (NOLOCK) LEFT OUTER JOIN 
						##Att_Muster1 am1 ON am1.emp_id = E.Emp_ID LEFT OUTER JOIN 
						( SELECT I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,TYPE_ID,Vertical_ID,SubVertical_ID,I.Emp_Fix_Salary  FROM T0095_Increment I  WITH (NOLOCK) INNER JOIN 
								( SELECT MAX(Increment_ID) AS Increment_ID , Emp_ID FROM T0095_Increment WITH (NOLOCK)
								WHERE Increment_Effective_date <= @To_Date
								AND Cmp_ID = @Cmp_ID
								GROUP BY emp_ID  ) Qry ON
								I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID	 ) I_Q 
							ON E.Emp_ID = I_Q.Emp_ID  INNER JOIN
								#Emp_Cons EC ON E.Emp_ID = EC.Emp_ID 
								LEFT JOIN (select Emp_ID from T0210_MONTHLY_Sal_POS_DETAIL Where Post__Date = @From_Date group by EMP_ID) ES ON ES.EMP_ID = EC.Emp_ID
								INNER JOIN
								--T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
								--T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
								--T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
								T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
								T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  LEFT OUTER JOIN
							   (select Emp_ID,Salary_Status from T0200_MONTHLY_SALARY WITH (NOLOCK) where Month_St_Date <= DateAdd(m,-1,@From_Date) and Month_End_Date >= DateAdd(m,-1,@To_Date))MSP ON
								E.Emp_ID = MSP.Emp_ID  -- Added by nilesh patel on 04112014 for pan & hold indication
								INNER JOIN 
								T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID LEFT OUTER JOIN 
								( SELECT MS.EMP_ID,Present_Days ,Sal_Tran_ID,M_OT_Hours,M_Loan_Amount,M_IT_Tax,Other_Dedu_Amount,Other_Allow_Amount,IT_M_ED_Cess_Amount,IT_M_Surcharge_Amount ,Salary_Status
									FROM 	T0200_MONTHLY_SALARY MS WITH (NOLOCK)  INNER JOIN 
									#Emp_Cons EC ON MS.EMP_ID = EC.EMP_ID 
									WHERE CMP_ID = @CMP_ID AND MONTH_END_DATE >=@FROM_DATE AND MONTH_END_DATE <=@TO_DATE )SG ON 
									E.EMP_ID  =SG.EMP_ID 
									LEFT OUTER JOIN
								--(SELECT MPI.EMP_ID,P_DAYS,Over_Time FROM 	T0190_MONTHLY_PRESENT_IMPORT MPI  WITH (NOLOCK) INNER JOIN 
								--	#Emp_Cons EC ON MPI.EMP_ID = EC.EMP_ID 
								--	WHERE CMP_ID = @CMP_ID  AND MPI.month = MONTH(@to_date) AND mpi.year = YEAR(@to_date) )Q_MPI	ON E.EMP_ID =Q_MPI.EMP_ID LEFT OUTER JOIN --AND FOR_DATE >=@FROM_DATE AND FOR_DATE <=@TO_DATE
								(SELECT Adv_Closing AS M_ADV_AMOUNT,ADVT.Emp_ID  FROM T0140_Advance_Transaction ADVT WITH (NOLOCK) INNER JOIN 
													( SELECT MAX(For_Date) AS For_Date , Emp_ID FROM T0140_Advance_Transaction WITH (NOLOCK)
														WHERE For_Date <= @To_Date AND Cmp_ID = @Cmp_ID GROUP BY emp_ID  ) Qry ON ADVT.Emp_ID = Qry.Emp_ID AND ADVT.For_Date = Qry.For_Date	
												) I_Q1 ON E.Emp_ID = I_Q1.Emp_ID 
								INNER JOIN T0011_Login LO WITH (NOLOCK) ON LO.Emp_Id = E.Emp_Id
								Left OUTER JOIN 
								(
									SELECT Emp_ID FROM #Emp_Doc
								) as Doc ON Doc.Emp_ID = E.Emp_Id
								Left Outer JOIN
								(
								   Select Emp_ID From #Emp_Salary_On_Hold
								) as SH ON SH.Emp_ID = E.Emp_Id
								LEFT OUTER JOIN T0200_Emp_ExitApplication EA WITH (NOLOCK) ON EA.emp_id=E.Emp_ID and EA.[status]<>'R' --Mukti(19122019)
						WHERE E.Cmp_ID = @Cmp_Id and LO.Is_Active =1 --And ((@From_Date < E.Emp_LEft_Date And @To_Date > E.Emp_LEft_Date) or E.Emp_LEft_Date is null)	--and Tp.for_Date>= @FROM_DATE and Tp.for_Date<=@To_Date
							AND E.Emp_ID IN (SELECT Emp_ID FROM #Emp_Cons) 
							AND Sal_Tran_ID IS NULL	AND ES.EMP_ID IS NULL				
							ORDER BY  Emp_Code ASC
					
					END
	END
	ELSE 
		BEGIN
			IF @Show_Left_Employee_for_Salary = 0
				BEGIN
					INSERT	INTO #Salary_Temp
					SELECT	Sal_tran_ID,e.Emp_Id,Pan_No,BM.Comp_Name,CM.Cmp_Name,Cm.Cmp_Address,BM.Branch_address,CAST( E.Alpha_Emp_Code AS VARCHAR) + ' - '+E.Emp_Full_Name AS Emp_Full_Name,M_IT_Tax,
							CASE WHEN M_OT_Hours > 0 THEN
									M_OT_Hours 
								ELSE 
									Over_Time 
								END AS M_OT_Hours,Other_Dedu_Amount,M_LOAN_AMOUNT,IsNull(Advance_Amount, M_ADV_AMOUNT) As M_ADV_AMOUNT,Other_Allow_Amount,
							SG.Salary_Status AS Status
							,P_DAYS,I_Q.Branch_ID, I_Q.Vertical_ID,I_Q.SubVertical_ID,I_Q.Dept_ID,MSP.Salary_Status as PMonth_Status -- add by Gadriwala 16102013 E.Vertical_ID,E.SubVertical_ID Added By Jaina 29-09-2015 Dept_Id
							,(case when MSP.Salary_Status = 'Hold' and Pan_No = '' then 3 when MSP.Salary_Status = 'Hold' then 2  when Pan_No = '' OR Isnull(Doc.Emp_ID,0) <> 0 then 1 else 0 end) as Color_flag,0,0,0
							,E.Emp_Left--Ankit 27062016
							,I_Q.Emp_Fix_Salary,case when EA.exit_id > 0 then 1 else 0 end  --Jaina 07-09-2016
					FROM	T0080_EMP_MASTER E WITH (NOLOCK)
							LEFT OUTER JOIN  ##Att_Muster1 am1 ON am1.emp_id = E.Emp_ID 
							LEFT OUTER JOIN  (SELECT	I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,TYPE_ID,Vertical_ID,SubVertical_ID,I.Emp_Fix_Salary  
											 FROM		T0095_Increment I WITH (NOLOCK)
														INNER JOIN (SELECT	MAX(Increment_ID) AS Increment_ID , Emp_ID 
																	FROM	T0095_Increment WITH (NOLOCK)
																	WHERE	Increment_Effective_date <= @To_Date AND Cmp_ID = @Cmp_ID
																	GROUP BY emp_ID  ) Qry ON I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID	 
											 ) I_Q  ON E.Emp_ID = I_Q.Emp_ID  
							INNER JOIN #Emp_Cons EC ON E.Emp_ID = EC.Emp_ID 
							INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  
							LEFT OUTER JOIN (SELECT		Emp_ID,Salary_Status
											from		T0200_MONTHLY_SALARY WITH (NOLOCK)
											where		Month_St_Date <= DateAdd(m,-1,@From_Date) 
														and Month_End_Date >= DateAdd(m,-1,@To_Date)) MSP ON E.Emp_ID = MSP.Emp_ID  -- Added by nilesh patel on 04112014 for pan & hold indication
							INNER JOIN  T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID 
							LEFT OUTER JOIN (SELECT MS.EMP_ID,Present_Days ,Sal_Tran_ID,M_OT_Hours,M_Loan_Amount,M_IT_Tax,Other_Dedu_Amount,Other_Allow_Amount,IT_M_ED_Cess_Amount,IT_M_Surcharge_Amount ,Salary_Status, Advance_Amount
											 FROM 	T0200_MONTHLY_SALARY MS  WITH (NOLOCK)
													INNER JOIN #Emp_Cons EC ON MS.EMP_ID = EC.EMP_ID 
											 WHERE	CMP_ID = @CMP_ID AND MONTH_END_DATE >=@FROM_DATE 
													AND MONTH_END_DATE <=@TO_DATE) SG ON  E.EMP_ID  =SG.EMP_ID 
							LEFT OUTER JOIN (SELECT MPI.EMP_ID,P_DAYS,Over_Time 
											 FROM 	T0190_MONTHLY_PRESENT_IMPORT MPI  WITH (NOLOCK)
													INNER JOIN #Emp_Cons EC ON MPI.EMP_ID = EC.EMP_ID 
											 WHERE	CMP_ID = @CMP_ID AND MPI.month = MONTH(@to_date) 
													AND mpi.year = YEAR(@to_date)) Q_MPI	ON E.EMP_ID =Q_MPI.EMP_ID  
							LEFT OUTER JOIN (SELECT	Adv_Closing AS M_ADV_AMOUNT,ADVT.Emp_ID  
											 FROM	T0140_Advance_Transaction ADVT WITH (NOLOCK)
													INNER JOIN (SELECT	MAX(For_Date) AS For_Date, Emp_ID 
																FROM	T0140_Advance_Transaction WITH (NOLOCK)
																WHERE	For_Date <= @To_Date AND Cmp_ID = @Cmp_ID 
																GROUP BY emp_ID) Qry ON ADVT.Emp_ID = Qry.Emp_ID AND ADVT.For_Date = Qry.For_Date	
											) I_Q1 ON E.Emp_ID = I_Q1.Emp_ID 
							INNER JOIN T0011_Login LO WITH (NOLOCK) ON LO.Emp_Id = E.Emp_Id 
							LEFT OUTER JOIN (SELECT Emp_ID FROM #Emp_Doc) as Doc ON Doc.Emp_ID = E.Emp_Id	
							LEFT OUTER JOIN T0200_Emp_ExitApplication EA WITH (NOLOCK) ON EA.emp_id=E.Emp_ID and EA.[status]<>'R' --Mukti(19122019)
					WHERE	E.Cmp_ID = @Cmp_Id and LO.Is_Active =1
							AND	 ((@From_Date < E.Emp_LEft_Date AND @To_Date < E.Emp_LEft_Date) OR E.Emp_LEft_Date IS NULL)	
							--AND E.Emp_ID IN (SELECT Emp_ID FROM #Emp_Cons)
					ORDER BY  Emp_Code ASC
						
				END
			ELSE
				BEGIN	
				--	select EC.* from #Emp_Cons EC
				--LEFT JOIN (select Emp_ID from T0210_MONTHLY_Sal_POS_DETAIL Where Post__Date = @From_Date group by EMP_ID) ES ON ES.EMP_ID = EC.Emp_ID
				--where ES.EMP_ID = NULL
				
					INSERT INTO #Salary_Temp
					SELECT	Sal_tran_ID,e.Emp_Id,Pan_No,BM.Comp_Name,CM.Cmp_Name,Cm.Cmp_Address,BM.Branch_Name,CAST( E.Alpha_Emp_Code AS VARCHAR) + ' - '+E.Emp_Full_Name AS Emp_Full_Name,
							(Case When Isnull(SH.Emp_ID,0) <> 0 Then 'Hold' Else SG.Salary_Status END) AS Status,
							I_Q.Branch_ID, I_Q.Vertical_ID,I_Q.SubVertical_ID,I_Q.Dept_ID,DM.Dept_Name,
							(case when MSP.Salary_Status = 'Hold' and Pan_No = '' then 3 when MSP.Salary_Status = 'Hold' then 2  when Pan_No = '' OR Isnull(Doc.Emp_ID,0) <> 0 then 1 else 0 end) as Color_flag,
							E.Emp_Left,I_Q.Emp_Fix_Salary,case when EA.exit_id > 0 then 1 else 0 end  --Jaina 07-09-2016
					FROM	T0080_EMP_MASTER E WITH (NOLOCK)
							--LEFT OUTER JOIN ##Att_Muster1 am1 ON am1.emp_id = E.Emp_ID 
							LEFT OUTER JOIN (SELECT I.Emp_Id,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,TYPE_ID,Vertical_ID,SubVertical_ID,I.Emp_Fix_Salary  
											 FROM	T0095_Increment I WITH (NOLOCK)
													INNER JOIN (SELECT	MAX(Increment_ID) AS Increment_ID, Emp_ID 
																FROM	T0095_Increment WITH (NOLOCK)
																WHERE	Increment_Effective_date <= @To_Date AND Cmp_ID = @Cmp_ID
																GROUP BY emp_ID) Qry ON I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID
											) I_Q  ON E.Emp_ID = I_Q.Emp_ID  
							INNER JOIN #Emp_Cons EC ON E.Emp_ID = EC.Emp_ID 
							LEFT JOIN (select Emp_ID from T0210_MONTHLY_Sal_POS_DETAIL Where Post__Date = @From_Date group by EMP_ID) ES ON ES.EMP_ID = EC.Emp_ID
							INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 
							INNER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.dept_id = DM.Dept_ID
							INNER JOIN (SELECT Emp_ID,Salary_Status
											 FROM	T0200_MONTHLY_SALARY WITH (NOLOCK)
											 WHERE	Month_St_Date = @From_Date 
													AND Month_End_Date = @To_Date) MSP ON E.Emp_ID = MSP.Emp_ID  -- Added by nilesh patel on 04112014 for pan & hold indication
							INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID 
							INNER JOIN (SELECT	MS.EMP_ID,Present_Days ,Sal_Tran_ID,M_OT_Hours,M_Loan_Amount,M_IT_Tax,Other_Dedu_Amount,Other_Allow_Amount,IT_M_ED_Cess_Amount,IT_M_Surcharge_Amount ,Salary_Status,Advance_Amount
											 FROM 	T0200_MONTHLY_SALARY MS  WITH (NOLOCK)
													INNER JOIN #Emp_Cons EC ON MS.EMP_ID = EC.EMP_ID 
											 WHERE	CMP_ID = @CMP_ID AND MONTH_END_DATE >=@FROM_DATE 
													AND MONTH_END_DATE <=@TO_DATE) SG ON E.EMP_ID  =SG.EMP_ID 
							--LEFT OUTER JOIN (SELECT	MPI.EMP_ID,P_DAYS,Over_Time 
							--				 FROM 	T0190_MONTHLY_PRESENT_IMPORT MPI WITH (NOLOCK)
							--						INNER JOIN #Emp_Cons EC ON MPI.EMP_ID = EC.EMP_ID 
							--				 WHERE	CMP_ID = @CMP_ID AND MPI.month = MONTH(@to_date) 
							--						AND MPI.YEAR = YEAR(@to_date)) Q_MPI ON E.EMP_ID =Q_MPI.EMP_ID  
							LEFT OUTER JOIN (SELECT Adv_Closing AS M_ADV_AMOUNT,ADVT.Emp_ID  
											 FROM	T0140_Advance_Transaction ADVT WITH (NOLOCK) INNER JOIN 
														( SELECT MAX(For_Date) AS For_Date , Emp_ID FROM T0140_Advance_Transaction WITH (NOLOCK)
															WHERE For_Date <= @To_Date AND Cmp_ID = @Cmp_ID GROUP BY emp_ID  ) Qry ON ADVT.Emp_ID = Qry.Emp_ID AND ADVT.For_Date = Qry.For_Date	
													) I_Q1 ON E.Emp_ID = I_Q1.Emp_ID 
							INNER JOIN T0011_Login LO WITH (NOLOCK) ON LO.Emp_Id = E.Emp_Id
							Left OUTER JOIN (SELECT Emp_ID FROM #Emp_Doc) as Doc ON Doc.Emp_ID = E.Emp_Id
							Left Outer JOIN (Select Emp_ID From #Emp_Salary_On_Hold) as SH ON SH.Emp_ID = E.Emp_Id
							LEFT OUTER JOIN T0200_Emp_ExitApplication EA WITH (NOLOCK) ON EA.emp_id=E.Emp_ID and EA.[status]<>'R' --Mukti(19122019)
					WHERE	E.Cmp_ID = @Cmp_Id and LO.Is_Active = 1	AND ES.EMP_ID IS NULL														
					ORDER BY  Emp_Code ASC
					--	select * from #Emp_Cons --where Emp_ID=14486 --Yogesh
						
				END
				
		END
-- Changed By rohit on 27082014
	--SELECT * FROM T0190_Tax_Planning TP INNER JOIN #Emp_Cons E ON TP.Emp_ID = E.Emp_ID WHERE Cmp_ID=@Cmp_ID AND Tp.for_Date>= @FROM_DATE AND Tp.for_Date<=@To_Date
	--if exists(select TP.emp_id from T0190_Tax_Planning TP WITH (NOLOCK) INNER JOIN #Emp_Cons E ON TP.Emp_ID = E.Emp_ID WHERE Cmp_ID=@Cmp_ID AND Tp.for_Date>= @FROM_DATE AND Tp.for_Date<=@To_Date)
	--	begin
	--		--SELECT * FROM T0190_Tax_Planning TP INNER JOIN #Emp_Cons E ON TP.Emp_ID = E.Emp_ID WHERE Cmp_ID=@Cmp_ID AND Tp.for_Date>= @FROM_DATE AND Tp.for_Date<=@To_Date
	--		UPDATE ST
	--			SET IT_M_Amount = TP.IT_M_Amount,
	--				IT_M_ED_Cess_Amount = TP.IT_M_ED_Cess_Amount,
	--				IT_M_Surcharge_Amount = TP.IT_M_Surcharge_Amount
	--		From	T0190_Tax_Planning TP 
	--				Inner JOIN #Salary_Temp ST ON TP.Emp_Id = ST.Emp_ID
	--		WHERE Cmp_ID=@Cmp_ID AND Tp.for_Date>= @FROM_DATE AND Tp.for_Date<=@To_Date
	--	end
	--else
	--	Begin
	--		--select * FROM T0190_Tax_Planning TP INNER JOIN (SELECT max(tp.for_date) as for_date,tp.emp_id FROM T0190_Tax_Planning TP INNER JOIN #Emp_Cons E ON TP.Emp_ID = E.Emp_ID WHERE Cmp_ID=@Cmp_ID AND  Tp.for_Date<=@To_Date and tp.for_date >= @Fin_Start_Date and isnull(is_repeat,0) = 1 group by tp.emp_id) qry on TP.emp_id = Qry.emp_id and Tp.For_date = qry.For_Date 
	--		UPDATE	ST
	--			SET IT_M_Amount = TP.IT_M_Amount,
	--				IT_M_ED_Cess_Amount = TP.IT_M_ED_Cess_Amount,
	--				IT_M_Surcharge_Amount = TP.IT_M_Surcharge_Amount
	--		FROM	T0190_Tax_Planning TP 
	--				INNER JOIN (SELECT	max(tp.for_date) as for_date,tp.emp_id 
	--							FROM	T0190_Tax_Planning TP WITH (NOLOCK)
	--									INNER JOIN #Salary_Temp ST ON TP.Emp_Id = ST.Emp_ID 
	--							WHERE	Cmp_ID=@Cmp_ID AND  Tp.for_Date<=@To_Date 
	--									and tp.for_date >= @Fin_Start_Date and isnull(is_repeat,0) = 1 
	--							group by tp.emp_id) qry on TP.emp_id = Qry.emp_id and Tp.For_date = qry.For_Date
	--				INNER JOIN #Salary_Temp ST ON TP.Emp_Id = ST.Emp_ID
		
	--	end
	
	
			--AND ( E.Pan_No  = (Case When @FilterType = 1 Then '' Else E.Pan_No END) OR Isnull(Doc.Emp_ID,0) = (Case When @FilterType = 1 Then 0 Else Doc.Emp_ID END))
						--AND MSP.Salary_Status  = (Case When @FilterType = 2 Then 'Hold' Else MSP.Salary_Status END)
	
						--AND Isnull(I_Q.Emp_Fix_Salary,0)  = (Case When @FilterType = 3 Then 1 Else I_Q.Emp_Fix_Salary  END)
	Declare @W_Str Varchar(500)
	Set @W_Str = ''
	
	IF @FILTERTYPE = 0
		BEGIN
			SELECT * FROM #SALARY_TEMP
		END
	IF @FILTERTYPE = 1 
		BEGIN
			SELECT * FROM #SALARY_TEMP WHERE COLOR_FLAG = 1	
		END
	ELSE IF @FILTERTYPE = 2
		BEGIN
			SELECT * FROM #SALARY_TEMP WHERE COLOR_FLAG = 2	
		END
	ELSE IF @FILTERTYPE = 3
		BEGIN
			SELECT * FROM #SALARY_TEMP WHERE EMP_FIX_SALARY = 1	
		END
	ELSE IF @FILTERTYPE = 4
		BEGIN
			SELECT * FROM #SALARY_TEMP WHERE COLOR_FLAG = 3
		END
	
	
	-- Ended by rohit
	If @Pending_Leave_Setting = 1
	BEGIN
	-- Added By Zishanali 30092013
	Select Distinct Alpha_Emp_Code AS Emp_Code, Emp_Full_Name,EM.Emp_ID,B_T.Branch_ID,BM.Branch_Name from T0100_Leave_Application as LA  WITH (NOLOCK)
		Inner join T0110_LEAVE_APPLICATION_DETAIL as LAD WITH (NOLOCK) on LA.Leave_Application_ID = LAD.Leave_Application_ID
		Inner join T0080_EMP_MASTER as EM WITH (NOLOCK) on  LA.Emp_ID = Em.Emp_ID 		
		Inner join ( SELECT I.Emp_Id , Branch_ID FROM T0095_Increment I WITH (NOLOCK) INNER JOIN 
							( SELECT MAX(Increment_ID) AS Increment_ID , Emp_ID FROM T0095_Increment WITH (NOLOCK)
							WHERE Increment_Effective_date <= @To_Date
							AND Cmp_ID = @Cmp_ID GROUP BY emp_ID  ) Qry ON
							I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID	 ) as B_T
		ON B_T.Emp_ID = EM.Emp_ID
		Inner Join T0030_BRANCH_MASTER BM WITH (NOLOCK) ON BM.Branch_ID = B_T.Branch_ID		
		where  (LA.Application_Status = 'P' or LA.Application_Status = 'F') and LAD.Cmp_ID = @Cmp_ID
		and (Lad.From_Date >= @From_Date and LAD.To_Date <= @To_Date )
	-- Added By Zishanali 30092013
	END
	ELSE
	BEGIN
		--update by chetan 170517
		select 0 As Emp_Code,'' As Emp_Full_Name ,0 As Emp_ID,0 As Branch_ID ,'' As Branch_Name
	end
	
	

	if @Emp_Pt_Setting = 1
	BEGIN
		-- Added by rohit on 04-apr-2014
		
		IF @Branch_ID = 0	--Ankit 24022015
			SET @Branch_ID = NULL
		
		 Select Distinct Alpha_Emp_Code AS Emp_Code, Emp_Full_Name,EM.Emp_ID,B_T.Branch_ID,BM.Branch_Name 
		from T0080_EMP_MASTER as EM WITH (NOLOCK)
		inner join #Emp_Cons as EC on Em.emp_id =EC.emp_id
			Inner join ( SELECT I.Emp_Id , Branch_ID,Emp_PT FROM T0095_Increment I WITH (NOLOCK) INNER JOIN 
							( SELECT MAX(Increment_ID) AS Increment_ID , Emp_ID FROM T0095_Increment WITH (NOLOCK)
							WHERE Increment_Effective_date <= @To_Date
							AND Cmp_ID = @Cmp_ID GROUP BY emp_ID  ) Qry ON
							I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID	 ) as B_T
			ON B_T.Emp_ID = EM.Emp_ID
			Inner Join T0030_BRANCH_MASTER BM WITH (NOLOCK) ON BM.Branch_ID = B_T.Branch_ID
			Inner Join T0040_GENERAL_SETTING GS WITH (NOLOCK) on BM.Branch_ID = GS.Branch_ID
			where GS.IS_PT = 1 and B_T.Emp_PT=0
			and GS.For_Date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID 
			and Branch_ID = Isnull(@branch_id,B_T.Branch_ID))  --Modified By Ramiz on 17092014
	END
	
	ELSE
	BEGIN
		--update by chetan 170517
		select 0 As Emp_Code,'' As Emp_Full_Name,0 As Emp_ID,0 As Branch_ID,'' As Branch_Name
	END
	-- Ended by rohit on 04-apr-2014


	--Start Added by Niraj (09062022)
		--IF @Salary_Status = 'All' AND @Salary_Cycle_id = 0 AND @FilterType = 0
		--BEGIN
		--	insert into Salary_Temp_Table
		--	Select ISNULL(Sal_tran_ID,0),ISNULL(Emp_ID,0), 0 FROM #Salary_Temp
		--	WHERE Sal_tran_ID > 0
		--END
	--End Added by Niraj (09062022)
	
	DROP TABLE ##Att_Muster1
		  
	RETURN

