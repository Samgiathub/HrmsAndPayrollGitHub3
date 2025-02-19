
CREATE PROCEDURE [dbo].[RPT_DAILY_MANPOWER]  
	 @CMP_ID	NUMERIC  
	,@FROM_DATE		DATETIME
	,@TO_DATE 		DATETIME
	,@BRANCH_ID		NUMERIC	
	,@GRD_ID 		NUMERIC
	,@TYPE_ID 		NUMERIC
	,@DEPT_ID 		NUMERIC
	,@DESIG_ID 		NUMERIC
	,@EMP_ID 		NUMERIC
	,@CONSTRAINT	VARCHAR(MAX)
	,@CAT_ID        NUMERIC = 0
	--,@IS_COLUMN		TINYINT = 0
	--,@SALARY_CYCLE_ID  NUMERIC  = 0
	--,@SEGMENT_ID	NUMERIC = 0 
	--,@VERTICAL		NUMERIC = 0 
	--,@SUBVERTICAL	NUMERIC = 0 
	--,@SUBBRANCH		NUMERIC = 0 
	,@SUMMARY		VARCHAR(MAX)=''
	,@SUMMARY2		VARCHAR(MAX)=''
	,@SUMMARY3		VARCHAR(MAX)=''
	,@TYPE			VARCHAR(100) = '0'
	,@ORDER_BY		VARCHAR(30) = 'CODE'
	,@SUMMARY4		VARCHAR(MAX)=''
	--,@SHOW_HIDDEN_ALLOWANCE  BIT = 1  
AS  
	SET NOCOUNT ON		
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
	
	CREATE TABLE #EMP_CONS 
	(
		EMP_ID	NUMERIC ,     
		BRANCH_ID NUMERIC,
		INCREMENT_ID NUMERIC 
	)
	
	EXEC SP_RPT_FILL_EMP_CONS @CMP_ID,@FROM_DATE,@TO_DATE,@BRANCH_ID,@CAT_ID,@GRD_ID,@TYPE_ID,@DEPT_ID,@DESIG_ID,@EMP_ID,
								@CONSTRAINT,0,0,0,0,0,0,0,0,0,0,0,0   
	
	CREATE TABLE #MANPOWER
	(		
	    CMP_ID			NUMERIC(18,0)
	   ,EMP_ID			NUMERIC(18,0) PRIMARY KEY
	   ,EMP_CODE		NUMERIC(18,0)	   
	   ,ALPHA_EMP_CODE	VARCHAR(50)
	   ,EMP_FULL_NAME	VARCHAR(250)	   
	   ,DEPARTMENT		NVARCHAR(100)	   
	   ,BRANCH_ID       NUMERIC(18,0)
	   ,BRANCH		    VARCHAR(250)	   
	   ,DESIGNATION		NVARCHAR(100)
	   ,GRADE			NVARCHAR(100)
	   ,TYPENAME		NVARCHAR(100)
	   ,CATEGORY		NVARCHAR(100)
	   ,DIVISION		NVARCHAR(100)
	   ,SUB_VERTICAL	NVARCHAR(100)
	   ,SUB_BRANCH		NVARCHAR(100)
	   ,SEGMENT_NAME	NVARCHAR(100)
	   ,CENTER_CODE		NVARCHAR(100)
	)
	
	

	INSERT INTO #MANPOWER 
	SELECT	Distinct E.CMP_ID,E.EMP_ID,E.EMP_CODE,E.ALPHA_EMP_CODE,(E.ALPHA_EMP_CODE + ' - ' + E.EMP_FULL_NAME) EMP_FULL_NAME,
				DM.DEPT_NAME,BM.BRANCH_ID,BM.BRANCH_NAME,
				DNM.DESIG_NAME,GA.GRD_NAME,TM.TYPE_NAME,CT.CAT_NAME AS CATEGORY,VT.VERTICAL_NAME,ST.SUBVERTICAL_NAME,SB.SUBBRANCH_NAME,
				BSG.SEGMENT_NAME,CC.CENTER_CODE
	FROM		T0080_EMP_MASTER E	WITH (NOLOCK) INNER JOIN
				( 
					SELECT	I.EMP_ID,I.BASIC_SALARY,I.CTC,I.INC_BANK_AC_NO,PAYMENT_MODE,I.BRANCH_ID,I.GRD_ID,I.DEPT_ID,
							I.DESIG_ID,I.TYPE_ID,I.CAT_ID,I.VERTICAL_ID,I.SUBVERTICAL_ID,I.SUBBRANCH_ID,I.SEGMENT_ID,I.CENTER_ID 
					FROM	T0095_INCREMENT I WITH (NOLOCK) INNER JOIN 
							( 
								SELECT	MAX(INCREMENT_ID) AS INCREMENT_ID , EMP_ID 
								FROM	T0095_INCREMENT WITH (NOLOCK)
								WHERE	INCREMENT_EFFECTIVE_DATE <= @TO_DATE AND CMP_ID = @CMP_ID
								GROUP BY EMP_ID 
							 ) QRY ON	I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID 
				 )INC_QRY ON E.EMP_ID = INC_QRY.EMP_ID INNER JOIN 
				 #EMP_CONS EC ON E.EMP_ID = EC.EMP_ID LEFT OUTER JOIN 
				 T0030_BRANCH_MASTER BM WITH (NOLOCK) ON INC_QRY.BRANCH_ID = BM.BRANCH_ID	LEFT OUTER JOIN 
				 T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON INC_QRY.DEPT_ID = DM.DEPT_ID	left outer join 
				 T0040_DESIGNATION_MASTER dnm WITH (NOLOCK) on Inc_Qry.Desig_Id = dnm.Desig_ID left outer join 
				 T0040_TYPE_MASTER tm WITH (NOLOCK) on Inc_Qry.Type_ID = tm.Type_ID LEFT OUTER JOIN 
				 T0030_CATEGORY_MASTER CT WITH (NOLOCK) on CT.Cat_ID=Inc_Qry.Cat_Id LEFT OUTER JOIN 
				 T0040_VERTICAL_SEGMENT VT WITH (NOLOCK) ON VT.VERTICAL_ID=INC_QRY.VERTICAL_ID LEFT OUTER JOIN 
				 T0050_SUBVERTICAL ST WITH (NOLOCK) ON ST.SUBVERTICAL_ID=INC_QRY.SUBVERTICAL_ID LEFT OUTER JOIN 
				 T0050_SUBBRANCH SB WITH (NOLOCK) ON SB.SUBBRANCH_ID=INC_QRY.SUBBRANCH_ID LEFT OUTER JOIN 
				 T0040_BUSINESS_SEGMENT BSG WITH (NOLOCK) ON BSG.SEGMENT_ID=INC_QRY.SEGMENT_ID LEFT OUTER JOIN 
				 T0040_COST_CENTER_MASTER CC WITH (NOLOCK) ON CC.CENTER_ID = INC_QRY.CENTER_ID LEFT OUTER JOIN 
				 T0040_GRADE_MASTER GA WITH (NOLOCK) ON INC_QRY.GRD_ID = GA.GRD_ID
				 
				--select * from #MANPOWER  --mansi 
				 
				DECLARE @VAL NVARCHAR(MAX)
				SET @VAL = ''
				 
							
				
				SET @Val = ''
				SET @VAL = @VAL + ' ALTER TABLE  #MANPOWER ADD PRESENCE NUMERIC(18,2) DEFAULT 0;
									ALTER TABLE  #MANPOWER ADD ABSENT NUMERIC(18,2) DEFAULT 0;
									ALTER TABLE  #MANPOWER ADD TOTAL NUMERIC(18,2) DEFAULT 0;
									ALTER TABLE  #MANPOWER ADD STATUS VARCHAR(5) DEFAULT '''';
									ALTER TABLE  #MANPOWER ADD FOR_DATE DATETIME DEFAULT ''1900-01-01'';'	
				EXEC(@VAL)
										
				 	print 200   --mansi
				
				--CREATE NONCLUSTERED INDEX IX_DATA ON DBO.#ATT_MUSTER_EXCEL
				--	(	EMP_ID,EMP_CODE,ROW_ID ) 
				
		  
				--EXEC SP_RPT_EMP_ATTENDANCE_MUSTER_GET	@CMP_ID=@CMP_ID,@FROM_DATE=@FROM_DATE,@TO_DATE=@TO_DATE,@BRANCH_ID=@BRANCH_ID,@CAT_ID=@CAT_ID,
				--										@GRD_ID=@GRD_ID,@TYPE_ID=@TYPE_ID,@DEPT_ID=@DEPT_ID,@DESIG_ID=@DESIG_ID,@EMP_ID=0,@CONSTRAINT=@CONSTRAINT,
				--										@REPORT_FOR='',@EXPORT_TYPE='EXCEL'
			
				
				
					CREATE TABLE #PRESENT
					(  
						EMP_ID   NUMERIC,  
						EMP_CODE  varchar(100),  
						EMP_FULL_NAME VARCHAR(100),  
						IN_TIME   DATETIME,
						OUT_TIME   DATETIME, 
						Design_Name Varchar(500), 
						STATUS   CHAR(2),						
						Late_Come Varchar(10), 
						Early_Goes Varchar(10) 
					)  


				CREATE TABLE #Data         
					(         
						Emp_Id   numeric ,         
						For_date datetime,        
						Duration_in_sec numeric,        
						Shift_ID numeric ,        
						Shift_Type numeric ,        
						Emp_OT  numeric ,        
						Emp_OT_min_Limit numeric,        
						Emp_OT_max_Limit numeric,        
						P_days  numeric(12,3) default 0,        
						OT_Sec  numeric default 0  ,
						In_Time datetime,
						Shift_Start_Time datetime,
						OT_Start_Time numeric default 0,
						Shift_Change tinyint default 0,
						Flag int default 0,
						Weekoff_OT_Sec  numeric default 0,
						Holiday_OT_Sec  numeric default 0,
						Chk_By_Superior numeric default 0,
						IO_Tran_Id	   numeric default 0, 
						OUT_Time datetime,
						Shift_End_Time datetime,		
						OT_End_Time numeric default 0,	
						Working_Hrs_St_Time tinyint default 0, 
						Working_Hrs_End_Time tinyint default 0, 
						GatePass_Deduct_Days numeric(18,2) default 0 
					)    

					EXEC P_GET_EMP_INOUT @CMP_Id,@TO_DATE,@TO_DATE,1  


					INSERT INTO #PRESENT (EMP_ID,EMP_CODE,EMP_FULL_NAME,IN_TIME,OUT_TIME,Design_Name,STATUS)   
					(SELECT Distinct eir.Emp_ID,CAST(EM.Alpha_Emp_Code  AS varchar(100))   AS EMP_CODE, em.EMP_FULL_NAME  AS Emp_Full_Name
							,d.In_Time,d.OUT_Time,DM.Desig_Name,'P' 
					FROM t0150_emp_inout_record eir WITH (NOLOCK)
					INNER JOIN #Data D on eir.Emp_ID = d.Emp_ID AND eir.For_Date  = d.For_Date 
					inner join t0080_emp_master em  WITH (NOLOCK) on eir.emp_id=em.emp_id 
					INNER JOIN #Emp_Cons EC ON EC.Emp_ID = em.Emp_ID  
					INNER JOIN T0095_INCREMENT AS I WITH (NOLOCK) ON EC.INCREMENT_ID=I.INCREMENT_ID 
					INNER JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on DM.Desig_ID = I.Desig_Id 					
					WHERE month(eir.in_time)   = month(@TO_DATE) and Year(eir.in_time) = year(@TO_DATE) 
					and day(eir.in_time)   = day(@TO_DATE) AND I.CMP_ID = @Cmp_Id --)
					AND NOT EXISTS (SELECT	For_Date 
									FROM	T0140_LEAVE_TRANSACTION LT   WITH (NOLOCK)
									WHERE	eir.Emp_ID = LT.Emp_ID AND eir.For_Date = LT.For_Date AND 
												(LT.Leave_Used <> 0 OR LT.CompOff_Used <> 0) )   
					)					


					INSERT INTO #PRESENT (EMP_ID,EMP_CODE,EMP_FULL_NAME,Design_Name,STATUS)  
					SELECT  la.Emp_ID, CAST(EM.Alpha_Emp_Code  AS varchar(100))  AS EMP_CODE,( em.EMP_FULL_NAME ) AS Emp_Full_Name,DM.Desig_Name,'L'
					FROM	t0120_leave_approval AS la WITH (NOLOCK) inner join 
							t0080_emp_master AS em WITH (NOLOCK) on la.emp_id=em.emp_ID inner JOIN 
							#Emp_Cons EC ON EC.Emp_ID = em.Emp_ID INNER JOIN 
							T0095_INCREMENT AS I WITH (NOLOCK) ON EC.INCREMENT_ID = I.INCREMENT_ID inner JOIN 
							T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON DM.Desig_ID = I.Desig_Id	left outer join 
							t0130_leave_approval_detail AS lad WITH (NOLOCK) on la.leave_approval_ID=lad.leave_approval_ID Inner join 
							t0040_leave_master TLM WITH (NOLOCK) on lad.Leave_ID=TLM.Leave_ID Left Outer Join 
							T0150_LEAVE_CANCELLATION AS LC WITH (NOLOCK) On lad.Leave_Approval_ID =Lc.Leave_Approval_ID 
					WHERE	lad.from_Date < = @TO_DATE and lad.To_Date >= @TO_DATE
							and la.approval_status='A' AND  I.CMP_ID=@Cmp_Id And Leave_TYpe <> 'Company Purpose'
							and isnull(LC.Is_Approve,0) =0 


				  
					INSERT INTO #PRESENT (EMP_ID,EMP_CODE,EMP_FULL_NAME,Design_Name,STATUS)  
					SELECT	la.Emp_ID, CAST(EM.Alpha_Emp_Code  AS varchar(100))   AS EMP_CODE,( em.EMP_FULL_NAME ) AS Emp_Full_Name,
							DM.Desig_Name,'OD'
					FROM	t0120_leave_approval AS la WITH (NOLOCK) inner join 
							t0080_emp_master AS em WITH (NOLOCK) on la.emp_id=em.emp_ID INNER JOIN 
							#Emp_Cons EC ON EC.Emp_ID = em.Emp_ID inner JOIN 
							T0095_INCREMENT AS I WITH (NOLOCK) ON EC.INCREMENT_ID = I.INCREMENT_ID inner JOIN 
							T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON DM.Desig_ID = I.Desig_Id left outer join  
							t0130_leave_approval_detail AS lad WITH (NOLOCK) on la.leave_approval_ID=lad.leave_approval_ID Inner join 
							t0040_leave_master TLM WITH (NOLOCK) on lad.Leave_ID=TLM.Leave_ID 					
					WHERE	lad.from_Date < = @TO_DATE and lad.To_Date >= @TO_DATE and la.approval_status='A' AND isnull(I.BRANCH_ID,0)=isnull(0,isnull(I.Branch_ID,0)) 
							AND I.CMP_ID=@Cmp_Id And Leave_TYpe = 'Company Purpose'  
							AND NOT EXISTS ( SELECT Leave_Approval_ID FROM T0150_LEAVE_CANCELLATION WITH (NOLOCK)
												WHERE CMP_ID=@Cmp_Id AND Is_Approve = 1 AND Leave_Approval_ID = lad.Leave_Approval_ID )	



					INSERT INTO #PRESENT (EMP_ID,EMP_CODE,EMP_FULL_NAME,Design_Name,STATUS)  
					SELECT	em.Emp_ID , CAST(EM.Alpha_EMP_CODE  AS varchar(100))   AS EMP_CODE,( em.EMP_FULL_NAME ) AS Emp_Full_Name,
							DM.Desig_Name,'A'
					FROM	t0080_emp_master em WITH (NOLOCK) inner join
							#Emp_Cons EC ON EC.Emp_ID = em.Emp_ID inner JOIN 
							T0095_INCREMENT I WITH (NOLOCK) ON I.Increment_ID = EC.Increment_ID	inner JOIN 
							T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON DM.Desig_ID = I.Desig_Id	left outer join 
							t0040_type_master TM WITH (NOLOCK) on I.type_id=tm.type_id
					WHERE	em.emp_id not in (SELECT emp_id FROM #PRESENT) AND em.CMP_ID=@Cmp_Id  
					
					
					CREATE TABLE #EMP_WEEKOFF
					(
						Row_ID			NUMERIC,
						Emp_ID			NUMERIC,
						For_Date		DATETIME,
						Weekoff_day		VARCHAR(10),
						W_Day			numeric(4,1),
						Is_Cancel		BIT
					)
					CREATE CLUSTERED INDEX IX_Emp_WeekOff_EmpID_ForDate ON #EMP_WEEKOFF(Emp_ID, For_Date)		
					
					
					SELECT	@CONSTRAINT = COALESCE(@CONSTRAINT + '#','') + CAST(EMP_ID AS VARCHAR(10))
					FROM	(SELECT DISTINCT EMP_ID FROM #PRESENT) T

					EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@To_date, @TO_DATE=@To_date, @All_Weekoff = 0, @Exec_Mode=1		

					UPDATE	P 
					SET		STATUS='WO'							
					FROM	#PRESENT P 
							INNER JOIN #EMP_WEEKOFF WO ON P.EMP_ID=WO.Emp_ID AND WO.For_Date=CONVERT(DATETIME, CONVERT(CHAR(10), GETDATE(), 103), 103)
					WHERE	STATUS = 'A'
								
					
					
					UPDATE	MP
					SET		PRESENCE = ISNULL(Q.EMP_COUNT_PRESENT,0),
							STATUS = 'P'
							--,[ABSENT] = ISNULL(Q.EMP_COUNT_ABSENT,0),
							--TOTAL	 = ISNULL(Q.EMP_COUNT_PRESENT,0) + 	ISNULL(Q.EMP_COUNT_ABSENT,0)
					FROM	#MANPOWER MP INNER JOIN
							(
								SELECT  P.EMP_ID,IsNULL(COUNT(distinct(P.EMP_ID)),0) AS EMP_COUNT_PRESENT										
								FROM	#PRESENT P inner join 
										t0080_emp_master AS em WITH (NOLOCK) on p.Emp_ID = em.emp_id inner join  
										#Emp_Cons E on e.Emp_id = p.Emp_id										
								WHERE	em.emp_left='N' AND status='P' 							
								GROUP BY P.EMP_ID
						)Q ON Q.EMP_ID = MP.EMP_ID
					
					UPDATE	MP
					SET		[ABSENT] = ISNULL(Q.EMP_COUNT_ABSENT,0),
							TOTAL	 = ISNULL(PRESENCE,0) + ISNULL(Q.EMP_COUNT_ABSENT,0),
							STATUS = 'A'
					FROM	#MANPOWER MP INNER JOIN
							(
								SELECT  P.EMP_ID,IsNULL(COUNT(distinct(P.EMP_ID)),0) AS EMP_COUNT_ABSENT										
								FROM	#PRESENT P inner join 
										t0080_emp_master AS em WITH (NOLOCK) on p.Emp_ID = em.emp_id inner join  
										#Emp_Cons E on e.Emp_id = p.Emp_id										
								WHERE	em.emp_left='N' AND status='A'						
								GROUP BY P.EMP_ID
						)Q ON Q.EMP_ID = MP.EMP_ID
					
					
					--UPDATE	MP
					--SET		STATUS = Q.STATUS,
					--		FOR_DATE = Q.FOR_DATE
					--FROM	#MANPOWER MP INNER JOIN
					--		(
					--			SELECT  STATUS,FOR_DATE,EMP_ID															
					--			FROM	#ATT_MUSTER_EXCEL 															
					--	)Q ON Q.EMP_ID = MP.EMP_ID
					
					UPDATE	#MANPOWER
					SET		PRESENCE = 0
					WHERE	PRESENCE IS NULL
					
					UPDATE	#MANPOWER
					SET		[ABSENT] = 0
					WHERE	[ABSENT] IS NULL
					
				
					
					DECLARE @STRING AS VARCHAR(MAX)
					SET @STRING=''
					
					DECLARE @STRING_2 AS VARCHAR(MAX)
					SET @STRING_2=''
					
					DECLARE @STRING_3 AS VARCHAR(MAX)
					SET @STRING_3=''
					
					
					DECLARE @STRING_4 AS VARCHAR(MAX)
					SET @STRING_4=''
					
					DECLARE @STRING_5 AS VARCHAR(MAX)
					SET @STRING_5=''
					IF @SUMMARY2 = '' OR @SUMMARY2 = '-1'
					SET @SUMMARY2 = NULL
		
					IF @SUMMARY3 = '' OR @SUMMARY3 = '-1'
					SET @SUMMARY3 = NULL
					
					IF @SUMMARY4 = '' OR @SUMMARY4 = '-1'
					SET @SUMMARY4 = NULL
					
					DECLARE @STRING_1 VARCHAR(MAX)
					SET @STRING_1 = ''
					IF EXISTS (SELECT 1 FROM SYS.OBJECTS WHERE NAME = 'TEMPGROUP2')
						DROP TABLE TEMPGROUP2
					
					IF EXISTS (SELECT 1 FROM SYS.OBJECTS WHERE NAME = 'TEMPGROUP3')
						DROP TABLE TEMPGROUP3
						
					IF EXISTS (SELECT 1 FROM SYS.OBJECTS WHERE NAME = 'TEMPGROUP4')
						DROP TABLE TEMPGROUP4
						
					IF @SUMMARY2 IS NOT NULL
						BEGIN
							SET @STRING_2 = 'SELECT (CASE WHEN '+ @SUMMARY2 +'=''0'' THEN ''MP.BRANCH_NAME'' WHEN '+ @SUMMARY2 +' =''1'' THEN ''MP.GRADE'' WHEN '+ @SUMMARY2 +' =''2'' THEN ''MP.CATEGORY'' WHEN '+ @SUMMARY2 +' =''3'' THEN ''DEPARTMENT'' WHEN '+ @SUMMARY2 +' =''4'' THEN ''DESIGNATION'' WHEN '+ @SUMMARY2 +' =''5'' THEN ''TYPENAME'' WHEN '+ @SUMMARY2 +' =''6'' THEN ''DIVISION'' WHEN '+ @SUMMARY2 +' =''7'' THEN ''SUB_VERTICAL'' WHEN '+ @SUMMARY2 +' =''8'' THEN ''SUB_BRANCH'' WHEN '+ @SUMMARY2 +' =''9'' THEN ''SEGMENT_NAME'' WHEN '+ @SUMMARY2 +' =''10'' THEN ''CENTER_CODE'' END ) AS DESCRIPTION INTO TEMPGROUP2'
							EXEC(@STRING_2)
							SELECT @STRING_2 = DESCRIPTION FROM TEMPGROUP2
							SET @STRING_5 = @STRING_2
							SET @STRING_2 = ','+ @STRING_2
						END 
						
					IF @SUMMARY3 IS NOT NULL
						BEGIN
							SET @STRING_3 = 'SELECT (CASE WHEN '+ @SUMMARY3 +'=''0'' THEN ''MP.BRANCH_NAME'' WHEN '+ @SUMMARY3 +' =''1'' THEN ''MP.GRADE'' WHEN '+ @SUMMARY3 +' =''2'' THEN ''MP.CATEGORY'' WHEN '+ @SUMMARY3 +' =''3'' THEN ''DEPARTMENT'' WHEN '+ @SUMMARY3 +' =''4'' THEN ''DESIGNATION'' WHEN '+ @SUMMARY3 +' =''5'' THEN ''TYPENAME'' WHEN '+ @SUMMARY3 +' =''6'' THEN ''DIVISION'' WHEN '+ @SUMMARY3 +' =''7'' THEN ''SUB_VERTICAL'' WHEN '+ @SUMMARY3 +' =''8'' THEN ''SUB_BRANCH'' WHEN '+ @SUMMARY3 +' =''9'' THEN ''SEGMENT_NAME'' WHEN '+ @SUMMARY3 +' =''10'' THEN ''CENTER_CODE'' END ) AS DESCRIPTION INTO TEMPGROUP3'
							EXEC(@STRING_3)
							SELECT @STRING_3 = DESCRIPTION FROM TEMPGROUP3
							SET @STRING_3 = ','+ @STRING_3
						END
							
					IF @SUMMARY4 IS NOT NULL
						BEGIN
							SET @STRING_4 = 'SELECT (CASE WHEN '+ @SUMMARY4 +'=''0'' THEN ''MP.BRANCH_NAME'' WHEN '+ @SUMMARY4 +' =''1'' THEN ''MP.GRADE'' WHEN '+ @SUMMARY4 +' =''2'' THEN ''MP.CATEGORY'' WHEN '+ @SUMMARY4 +' =''3'' THEN ''DEPARTMENT'' WHEN '+ @SUMMARY4 +' =''4'' THEN ''DESIGNATION'' WHEN '+ @SUMMARY4 +' =''5'' THEN ''TYPENAME'' WHEN '+ @SUMMARY4 +' =''6'' THEN ''DIVISION'' WHEN '+ @SUMMARY4 +' =''7'' THEN ''SUB_VERTICAL'' WHEN '+ @SUMMARY4 +' =''8'' THEN ''SUB_BRANCH'' WHEN '+ @SUMMARY4 +' =''9'' THEN ''SEGMENT_NAME'' WHEN '+ @SUMMARY4 +' =''10'' THEN ''CENTER_CODE'' END ) AS DESCRIPTION INTO TEMPGROUP4'
							EXEC(@STRING_4)
							SELECT @STRING_4 = DESCRIPTION FROM TEMPGROUP4
							SET @STRING_4 = ','+ @STRING_4
						END	
					
					
						Print @TYPE---mansi
				IF @TYPE = 0
					BEGIN
				 
							IF @SUMMARY='0'
								BEGIN 
							
									--set @String = ' select 0 as Flag, ROW_NUMBER() OVER (Order by CM.Branch) As Row_ID,CM.Branch as Branch_Name'+ @String_2 +''+ @String_3 +',Count(Emp_ID) As Total_Emp,
									--Round((Count(Emp_ID) / '  + cast(@Avg_Emp as varchar(10)) +' ),0)AS Avg_Emp ,SUM(CM.Basic_Salary) as Basic_Salary '+ @sum_of_allownaces_earning +',SUM(CM.Production_Bonus) as Production_Bonus,SUM(CM.Leave_Encash_Amount) as Leave_Encash_Amount,SUM(CM.Uniform_Refund_Amount) as Uniform_Refund_Amount,Sum(Total_Earning) As Total_Earning,Sum(Basic_Arrear) As Basic_Arrear'
									--+ @sum_of_allownaces_earning_Arear +',Sum(Total_Earning_Arrear) as Total_Earning_Arrear, SUM(CM.Other_Allow)as Other_Allowance, SUM(CM.Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CM.Actual_CTC) as CTC,SUM(cm.advance_amount)as Advance_Amount,SUM(CM.PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(cm.ot_rate)as OT_Rate,SUM(cm.ot_hours)as OT_Hours,SUM(cm.ot_amount)as OT_Amount,sum(cm.M_HO_OT_Hours)as Holiday_OT_Hours,sum(cm.M_HO_OT_Amount)as Holiday_OT_Amount,sum(cm.M_WO_OT_Hours)as Weekoff_OT_Hours,sum(cm.M_WO_OT_Amount)as Weekoff_OT_Amount,SUM(cm.WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(cm.revenue_amount) as Revenue_Amount,SUM(cm.lwf_amount)as LWF_Amount,SUM(isnull(cm.Gate_Pass_Amount,0)) as Gate_Pass_Amount,SUM(isnull(cm.Asset_Installment_Amount,0)) as Asset_Installment_Amount,SUM(isnull(cm.Uniform_Dedu_Amount,0)) as Uniform_Installment_Amount,SUM(ISNULL(Cm.Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction ' 
									--+ @sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(cm.net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,(SUM(Net_Round) + SUM(CM.Gross_Salary) '+ @Sum_Of_Allownaces_Earning_CTC_Total +') AS Total_Amount,
									--SUM(CM.Present_Day) as Present_Days,SUM(CM.Arear_Day) as Arear_Days,SUM(CM.Absent_Day) as Absent_Day,SUM(CM.Holiday_Day)as Holiday_day,SUM(CM.WeekOff_Day)as Week_Off_Days,SUM(CM.Sal_Cal_Day)as Sal_cal_Day,SUM(cm.total_leave_days)as Total_leave_Days,SUM(CM.total_paid_leave_days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' '
									
									set @String = ' select  ROW_NUMBER() OVER (Order by MP.BRANCH) As SR_No,MP.BRANCH as Branch_Name'+ @String_2 +''+ @String_3 +''+ @String_4 +',Count(Emp_ID) As Total_Emp,
																		SUM(PRESENCE) AS PRESENCE,SUM(ABSENT) AS ABSENT,SUM(TOTAL) AS TOTAL'

									
									set @String = @String + ' INTO ##BRANCH from #MANPOWER MP  group By BRANCH'+ @String_2 +''+ @String_3 +''+ @String_4 +''
									
									exec(@String)
									
									if @String_2 <> '' and @String_3 <> '' and @String_4 <> ''
										Begin
											Set @String_2 = ',' + ''''' as ' + Replace(Replace(@String_2,',MP.',''),',','') + ',' + ''''' as ' + Replace(Replace(@String_3,',MP.',''),',','') + '' + ',' + ''''' as ' + Replace(Replace(@String_4,',MP.',''),',','') + ''
										End
									Else if @String_2 <> ''
										Begin
											Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_2,',MP.',''),',','') +''
										End 
									Else if @String_3 <> ''
										Begin
											Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_3,',MP.',''),',','') + ''
										End
									Else if @String_4 <> ''
										Begin
											Set @String_4 =  ',' +''''' as ' + Replace(Replace(@String_4,',MP.',''),',','') + ''
										End
									
									--set @String = 'Insert into ##BRANCH Select 0 as Flag,(IsNull(Max(Row_ID),0)+1),''Total'''+ @String_2 +', Sum(Total_Emp),Round((Sum(Total_Emp)/'  + cast(@Avg_Emp as varchar(10)) +'),0) ,Sum(Basic_Salary) ' + @sum_of_allownaces_earning + ',SUM(Production_Bonus) as Production_Bonus,SUM(Leave_Encash_Amount) as Leave_Encash_Amount,SUM(Uniform_Refund_Amount) as Uniform_Refund_Amount,Sum(Total_Earning) As Total_Earning, Sum(Basic_Arrear) As Basic_Arrear'
									--+ @sum_of_allownaces_earning_Arear + ',Sum(Total_Earning_Arrear) as Total_Earning_Arrear,SUM(Other_Allowance)as Other_Allowance,SUM(Gross_Salary)as Gross_Salary '+ @sum_of_allownaces_deduct +',SUM(CTC) as CTC,SUM(Advance_Amount)as Advance_Amount,SUM(PT_Amount)as PT_Amount'+ @sum_of_Loan_Amount_Str + ',SUM(ot_rate)as OT_Rate,SUM(ot_hours)as OT_Hours,SUM(ot_amount)as OT_Amount,sum(Holiday_OT_Hours)as Holiday_OT_Hours,sum(Holiday_OT_Amount)as Holiday_OT_Amount,sum(Weekoff_OT_Hours)as Weekoff_OT_Hours,sum(Weekoff_OT_Amount)as Weekoff_OT_Amount,SUM(WO_HO_Fix_OT_Rate) as WO_HO_Fix_OT_Rate,SUM(Revenue_Amount) as Revenue_Amount,SUM(LWF_Amount)as LWF_Amount,SUM(Gate_Pass_Amount) as Gate_Pass_Amount,SUM(Asset_Installment_Amount) as Asset_Installment_Amount,SUM(isnull(Uniform_Installment_Amount,0)) as Uniform_Installment_Amount,SUM(ISNULL(Late_Deduction_Amount,0)) as Late_Deduction_Amount,SUM(ISNULL(Total_Deduction,0)) as Total_Deduction'
									--+@sum_of_allownaces_deduct_Arear + ',Sum(Arear_Deduction) As Arear_Deduction,Sum(Net_Total_Deduction) as Net_Total_Deduction, SUM(net_amount)as Net_Amount,SUM(Net_Round) As Net_Round, Sum(Total_Net) As Total_Net '+ @Sum_Of_Allownaces_Earning_CTC +' ,Sum(Total_Amount) AS Total_Amount,
									--SUM(Present_Days) as Present_Days,SUM(Arear_Days) as Arear_Days,SUM(Absent_Day) as Absent_Day,SUM(Holiday_day)as Holiday_day,SUM(Week_Off_Days)as Week_Off_Days,SUM(Sal_Cal_Day)as Sal_cal_Day,SUM(total_leave_days)as Total_leave_Days,SUM(Total_Paid_Leave_Days)as Total_Paid_Leave_Days '+ @sum_of_allownaces_earning_reim +' FROM ##BRANCH';
									
									set @String = 'Insert into ##BRANCH Select (IsNull(Max(SR_No),0)+1),''Total'''+ @String_2 +', Sum(Total_Emp),
												   SUM(PRESENCE) AS PRESENCE,SUM(ABSENT) AS ABSENT,SUM(TOTAL) AS TOTAL
												   FROM ##BRANCH';

									
									print @String
									exec(@String)
									
									set @String = 'Select * FROM ##BRANCH Order By SR_No';
									
									exec(@String)
									
									
									set @String = 'DROP TABLE ##BRANCH';	
									
									exec(@String)		
							END
						
							ELSE IF @SUMMARY='1'
								BEGIN 
							
									set @String = ' select ROW_NUMBER() OVER (Order by MP.GRADE) As SR_No,MP.GRADE as GRADE'+ @String_2 +''+ @String_3 +''+ @String_4 +',Count(Emp_ID) As Total_Emp,
													SUM(PRESENCE) AS PRESENCE,SUM(ABSENT) AS ABSENT,SUM(TOTAL) AS TOTAL'

									
									set @String = @String + ' INTO ##GRADE from #MANPOWER MP  group By GRADE'+ @String_2 +''+ @String_3 +''+ @String_4 +''
									
									exec(@String)
									
									if @String_2 <> '' and @String_3 <> '' and @String_4 <> ''
										Begin
											Set @String_2 = ',' + ''''' as ' + Replace(Replace(@String_2,',MP.',''),',','') + ',' + ''''' as ' + Replace(Replace(@String_3,',MP.',''),',','') + '' + ',' + ''''' as ' + Replace(Replace(@String_4,',MP.',''),',','') + ''
										End
									Else if @String_2 <> ''
										Begin
											Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_2,',MP.',''),',','') +''
										End 
									Else if @String_3 <> ''
										Begin
											Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_3,',MP.',''),',','') + ''
										End
									Else if @String_4 <> ''
										Begin
											Set @String_4 =  ',' +''''' as ' + Replace(Replace(@String_4,',MP.',''),',','') + ''
										End
									
									
									set @String = 'Insert into ##GRADE Select (IsNull(Max(SR_No),0)+1),''Total'''+ @String_2 +', Sum(Total_Emp),
												   SUM(PRESENCE) AS PRESENCE,SUM(ABSENT) AS ABSENT,SUM(TOTAL) AS TOTAL
												   FROM ##GRADE';

									
									
									exec(@String)
									
									set @String = 'Select * FROM ##GRADE Order By SR_No';
									
									exec(@String)
									
									set @String = 'DROP TABLE ##GRADE';	
									
									exec(@String)		
							END
							
							ELSE IF @SUMMARY='2'
								BEGIN 
							
									
									set @String = ' select  ROW_NUMBER() OVER (Order by MP.CATEGORY) As SR_No,MP.CATEGORY as CATEGORY'+ @String_2 +''+ @String_3 +''+ @String_4 +',Count(Emp_ID) As Total_Emp,
																		SUM(PRESENCE) AS PRESENCE,SUM(ABSENT) AS ABSENT,SUM(TOTAL) AS TOTAL'

									
									set @String = @String + ' INTO ##CATEGORY from #MANPOWER MP  group By CATEGORY'+ @String_2 +''+ @String_3 +''+ @String_4 +''
									
									exec(@String)
									
									if @String_2 <> '' and @String_3 <> '' and @String_4 <> ''
										Begin
											Set @String_2 = ',' + ''''' as ' + Replace(Replace(@String_2,',MP.',''),',','') + ',' + ''''' as ' + Replace(Replace(@String_3,',MP.',''),',','') + '' + ',' + ''''' as ' + Replace(Replace(@String_4,',MP.',''),',','') + ''
										End
									Else if @String_2 <> ''
										Begin
											Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_2,',MP.',''),',','') +''
										End 
									Else if @String_3 <> ''
										Begin
											Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_3,',MP.',''),',','') + ''
										End
									Else if @String_4 <> ''
										Begin
											Set @String_4 =  ',' +''''' as ' + Replace(Replace(@String_4,',MP.',''),',','') + ''
										End
									
									
									set @String = 'Insert into ##CATEGORY Select (IsNull(Max(SR_No),0)+1),''Total'''+ @String_2 +', Sum(Total_Emp),
												   SUM(PRESENCE) AS PRESENCE,SUM(ABSENT) AS ABSENT,SUM(TOTAL) AS TOTAL
												   FROM ##CATEGORY';

									
									
									exec(@String)
									
									set @String = 'Select * FROM ##CATEGORY Order By SR_No';
									
									exec(@String)
									
									set @String = 'DROP TABLE ##CATEGORY';	
									
									exec(@String)		
							END
							
							ELSE IF @SUMMARY='3'
								BEGIN 
							
									
									set @String = ' select  ROW_NUMBER() OVER (Order by MP.DEPARTMENT) As SR_No,MP.DEPARTMENT as DEPARTMENT'+ @String_2 +''+ @String_3 +''+ @String_4 +',Count(Emp_ID) As Total_Emp,
																		SUM(PRESENCE) AS PRESENCE,SUM(ABSENT) AS ABSENT,SUM(TOTAL) AS TOTAL'

									
									set @String = @String + ' INTO ##DEPARTMENT from #MANPOWER MP  group By DEPARTMENT'+ @String_2 +''+ @String_3 +''+ @String_4 +''
									
									exec(@String)
									
									if @String_2 <> '' and @String_3 <> '' and @String_4 <> ''
										Begin
											Set @String_2 = ',' + ''''' as ' + Replace(Replace(@String_2,',MP.',''),',','') + ',' + ''''' as ' + Replace(Replace(@String_3,',MP.',''),',','') + '' + ',' + ''''' as ' + Replace(Replace(@String_4,',MP.',''),',','') + ''
										End
									Else if @String_2 <> ''
										Begin
											Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_2,',MP.',''),',','') +''
										End 
									Else if @String_3 <> ''
										Begin
											Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_3,',MP.',''),',','') + ''
										End
									Else if @String_4 <> ''
										Begin
											Set @String_4 =  ',' +''''' as ' + Replace(Replace(@String_4,',MP.',''),',','') + ''
										End
									
									
									
									set @String = 'Insert into ##DEPARTMENT Select (IsNull(Max(SR_No),0)+1),''Total'''+ @String_2 +', Sum(Total_Emp),
												   SUM(PRESENCE) AS PRESENCE,SUM(ABSENT) AS ABSENT,SUM(TOTAL) AS TOTAL
												   FROM ##DEPARTMENT';

									
									
									exec(@String)
									
									set @String = 'Select * FROM ##DEPARTMENT Order By SR_No';
									
									exec(@String)
									
									set @String = 'DROP TABLE ##DEPARTMENT';	
									
									exec(@String)		
							END
						
							ELSE IF @SUMMARY='4'
								BEGIN 
							
									
									set @String = ' select  ROW_NUMBER() OVER (Order by MP.DESIGNATION) As SR_No,MP.DESIGNATION as DESIGNATION'+ @String_2 +''+ @String_3 +''+ @String_4 +',Count(Emp_ID) As Total_Emp,
																		SUM(PRESENCE) AS PRESENCE,SUM(ABSENT) AS ABSENT,SUM(TOTAL) AS TOTAL'

									
									set @String = @String + ' INTO ##DESIGNATION from #MANPOWER MP  group By DESIGNATION'+ @String_2 +''+ @String_3 +''+ @String_4 +''
									
									exec(@String)
									
									if @String_2 <> '' and @String_3 <> '' and @String_4 <> ''
										Begin
											Set @String_2 = ',' + ''''' as ' + Replace(Replace(@String_2,',MP.',''),',','') + ',' + ''''' as ' + Replace(Replace(@String_3,',MP.',''),',','') + '' + ',' + ''''' as ' + Replace(Replace(@String_4,',MP.',''),',','') + ''
										End
									Else if @String_2 <> ''
										Begin
											Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_2,',MP.',''),',','') +''
										End 
									Else if @String_3 <> ''
										Begin
											Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_3,',MP.',''),',','') + ''
										End
									Else if @String_4 <> ''
										Begin
											Set @String_4 =  ',' +''''' as ' + Replace(Replace(@String_4,',MP.',''),',','') + ''
										End
									
									
									set @String = 'Insert into ##DESIGNATION Select (IsNull(Max(SR_No),0)+1),''Total'''+ @String_2 +', Sum(Total_Emp),
												   SUM(PRESENCE) AS PRESENCE,SUM(ABSENT) AS ABSENT,SUM(TOTAL) AS TOTAL
												   FROM ##DESIGNATION';

									
									
									exec(@String)
									
									set @String = 'Select * FROM ##DESIGNATION Order By SR_No';
									
									exec(@String)
									
									set @String = 'DROP TABLE ##DESIGNATION';	
									
									exec(@String)		
							END
							
							ELSE IF @SUMMARY='5'
								BEGIN 
							
									set @String = ' select  ROW_NUMBER() OVER (Order by MP.TYPENAME) As SR_No,MP.TYPENAME as TYPENAME'+ @String_2 +''+ @String_3 +''+ @String_4 +',Count(Emp_ID) As Total_Emp,
																		SUM(PRESENCE) AS PRESENCE,SUM(ABSENT) AS ABSENT,SUM(TOTAL) AS TOTAL'

									
									set @String = @String + ' INTO ##TYPENAME from #MANPOWER MP  group By TYPENAME'+ @String_2 +''+ @String_3 +''+ @String_4 +''
									
									exec(@String)
									
									if @String_2 <> '' and @String_3 <> '' and @String_4 <> ''
										Begin
											Set @String_2 = ',' + ''''' as ' + Replace(Replace(@String_2,',MP.',''),',','') + ',' + ''''' as ' + Replace(Replace(@String_3,',MP.',''),',','') + '' + ',' + ''''' as ' + Replace(Replace(@String_4,',MP.',''),',','') + ''
										End
									Else if @String_2 <> ''
										Begin
											Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_2,',MP.',''),',','') +''
										End 
									Else if @String_3 <> ''
										Begin
											Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_3,',MP.',''),',','') + ''
										End
									Else if @String_4 <> ''
										Begin
											Set @String_4 =  ',' +''''' as ' + Replace(Replace(@String_4,',MP.',''),',','') + ''
										End
									
									
									
									set @String = 'Insert into ##TYPENAME Select (IsNull(Max(SR_No),0)+1),''Total'''+ @String_2 +', Sum(Total_Emp),
												   SUM(PRESENCE) AS PRESENCE,SUM(ABSENT) AS ABSENT,SUM(TOTAL) AS TOTAL
												   FROM ##TYPENAME';

									
									
									exec(@String)
									
									set @String = 'Select * FROM ##TYPENAME Order By SR_No';
									
									exec(@String)
									
									set @String = 'DROP TABLE ##TYPENAME';	
									
									exec(@String)		
							END
							
							
							ELSE IF @SUMMARY='6'
								BEGIN 
							
									
									set @String = ' select  ROW_NUMBER() OVER (Order by MP.Division) As SR_No,MP.Division as Division'+ @String_2 +''+ @String_3 +''+ @String_4 +',Count(Emp_ID) As Total_Emp,
																		SUM(PRESENCE) AS PRESENCE,SUM(ABSENT) AS ABSENT,SUM(TOTAL) AS TOTAL'

									
									set @String = @String + ' INTO ##Division from #MANPOWER MP  group By Division'+ @String_2 +''+ @String_3 +''+ @String_4 +''
									
									exec(@String)
									
									if @String_2 <> '' and @String_3 <> '' and @String_4 <> ''
										Begin
											Set @String_2 = ',' + ''''' as ' + Replace(Replace(@String_2,',MP.',''),',','') + ',' + ''''' as ' + Replace(Replace(@String_3,',MP.',''),',','') + '' + ',' + ''''' as ' + Replace(Replace(@String_4,',MP.',''),',','') + ''
										End
									Else if @String_2 <> ''
										Begin
											Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_2,',MP.',''),',','') +''
										End 
									Else if @String_3 <> ''
										Begin
											Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_3,',MP.',''),',','') + ''
										End
									Else if @String_4 <> ''
										Begin
											Set @String_4 =  ',' +''''' as ' + Replace(Replace(@String_4,',MP.',''),',','') + ''
										End
									
									
									
									set @String = 'Insert into ##Division Select (IsNull(Max(SR_No),0)+1),''Total'''+ @String_2 +', Sum(Total_Emp),
												   SUM(PRESENCE) AS PRESENCE,SUM(ABSENT) AS ABSENT,SUM(TOTAL) AS TOTAL
												   FROM ##Division';

									
									
									exec(@String)
									
									set @String = 'Select * FROM ##Division Order By SR_No';
									
									exec(@String)
									
									set @String = 'DROP TABLE ##Division';	
									
									exec(@String)		
							END
							
							ELSE IF @SUMMARY='7'
								BEGIN 
							
									
									set @String = ' select  ROW_NUMBER() OVER (Order by MP.sub_vertical) As SR_No,MP.sub_vertical as sub_vertical'+ @String_2 +''+ @String_3 +''+ @String_4 +',Count(Emp_ID) As Total_Emp,
																		SUM(PRESENCE) AS PRESENCE,SUM(ABSENT) AS ABSENT,SUM(TOTAL) AS TOTAL'

									
									set @String = @String + ' INTO ##sub_vertical from #MANPOWER MP  group By BRANCH_NAME'+ @String_2 +''+ @String_3 +''+ @String_4 +''
									
									exec(@String)
									
									if @String_2 <> '' and @String_3 <> '' and @String_4 <> ''
										Begin
											Set @String_2 = ',' + ''''' as ' + Replace(Replace(@String_2,',MP.',''),',','') + ',' + ''''' as ' + Replace(Replace(@String_3,',MP.',''),',','') + '' + ',' + ''''' as ' + Replace(Replace(@String_4,',MP.',''),',','') + ''
										End
									Else if @String_2 <> ''
										Begin
											Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_2,',MP.',''),',','') +''
										End 
									Else if @String_3 <> ''
										Begin
											Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_3,',MP.',''),',','') + ''
										End
									Else if @String_4 <> ''
										Begin
											Set @String_4 =  ',' +''''' as ' + Replace(Replace(@String_4,',MP.',''),',','') + ''
										End
									
									
									set @String = 'Insert into ##sub_vertical Select (IsNull(Max(SR_No),0)+1),''Total'''+ @String_2 +', Sum(Total_Emp),
												   SUM(PRESENCE) AS PRESENCE,SUM(ABSENT) AS ABSENT,SUM(TOTAL) AS TOTAL
												   FROM ##sub_vertical';

									
									
									exec(@String)
									
									set @String = 'Select * FROM ##sub_vertical Order By SR_No';
									
									exec(@String)
									
									set @String = 'DROP TABLE ##sub_vertical';	
									
									exec(@String)		
							END
							
							
							ELSE IF @SUMMARY='8'
								BEGIN 
							
									
									set @String = ' select  ROW_NUMBER() OVER (Order by MP.Sub_Branch) As SR_No,MP.Sub_Branch as Sub_Branch'+ @String_2 +''+ @String_3 +''+ @String_4 +',Count(Emp_ID) As Total_Emp,
																		SUM(PRESENCE) AS PRESENCE,SUM(ABSENT) AS ABSENT,SUM(TOTAL) AS TOTAL'

									
									set @String = @String + ' INTO ##Sub_Branch from #MANPOWER MP  group By Sub_Branch'+ @String_2 +''+ @String_3 +''+ @String_4 +''
									
									exec(@String)
									
									if @String_2 <> '' and @String_3 <> '' and @String_4 <> ''
										Begin
											Set @String_2 = ',' + ''''' as ' + Replace(Replace(@String_2,',MP.',''),',','') + ',' + ''''' as ' + Replace(Replace(@String_3,',MP.',''),',','') + '' + ',' + ''''' as ' + Replace(Replace(@String_4,',MP.',''),',','') + ''
										End
									Else if @String_2 <> ''
										Begin
											Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_2,',MP.',''),',','') +''
										End 
									Else if @String_3 <> ''
										Begin
											Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_3,',MP.',''),',','') + ''
										End
									Else if @String_4 <> ''
										Begin
											Set @String_4 =  ',' +''''' as ' + Replace(Replace(@String_4,',MP.',''),',','') + ''
										End
									
									
									
									set @String = 'Insert into ##Sub_Branch Select (IsNull(Max(SR_No),0)+1),''Total'''+ @String_2 +', Sum(Total_Emp),
												   SUM(PRESENCE) AS PRESENCE,SUM(ABSENT) AS ABSENT,SUM(TOTAL) AS TOTAL
												   FROM ##Sub_Branch';

									
									
									exec(@String)
									
									set @String = 'Select * FROM ##Sub_Branch Order By SR_No';
									
									exec(@String)
									
									set @String = 'DROP TABLE ##Sub_Branch';	
									
									exec(@String)		
							END
							
							
							ELSE IF @SUMMARY='9'
								BEGIN 
							
									
									set @String = ' select  ROW_NUMBER() OVER (Order by MP.Segment_Name) As SR_No,MP.Segment_Name as Segment_Name'+ @String_2 +''+ @String_3 +''+ @String_4 +',Count(Emp_ID) As Total_Emp,
																		SUM(PRESENCE) AS PRESENCE,SUM(ABSENT) AS ABSENT,SUM(TOTAL) AS TOTAL'

									
									set @String = @String + ' INTO ##Segment_Name from #MANPOWER MP  group By Segment_Name'+ @String_2 +''+ @String_3 +''+ @String_4 +''
									
									exec(@String)
									
									if @String_2 <> '' and @String_3 <> '' and @String_4 <> ''
										Begin
											Set @String_2 = ',' + ''''' as ' + Replace(Replace(@String_2,',MP.',''),',','') + ',' + ''''' as ' + Replace(Replace(@String_3,',MP.',''),',','') + '' + ',' + ''''' as ' + Replace(Replace(@String_4,',MP.',''),',','') + ''
										End
									Else if @String_2 <> ''
										Begin
											Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_2,',MP.',''),',','') +''
										End 
									Else if @String_3 <> ''
										Begin
											Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_3,',MP.',''),',','') + ''
										End
									Else if @String_4 <> ''
										Begin
											Set @String_4 =  ',' +''''' as ' + Replace(Replace(@String_4,',MP.',''),',','') + ''
										End
									
									
									
									set @String = 'Insert into ##Segment_Name Select (IsNull(Max(SR_No),0)+1),''Total'''+ @String_2 +', Sum(Total_Emp),
												   SUM(PRESENCE) AS PRESENCE,SUM(ABSENT) AS ABSENT,SUM(TOTAL) AS TOTAL
												   FROM ##Segment_Name';

									
									
									exec(@String)
									
									set @String = 'Select * FROM ##Segment_Name Order By SR_No';
									
									exec(@String)
									
									set @String = 'DROP TABLE ##Segment_Name';	
									
									exec(@String)		
							END	
							
							
							ELSE IF @SUMMARY='10'
								BEGIN 
							
									
									set @String = ' select  ROW_NUMBER() OVER (Order by MP.Center_Code) As SR_No,MP.Center_Code as Center_Code'+ @String_2 +''+ @String_3 +''+ @String_4 +',Count(Emp_ID) As Total_Emp,
																		SUM(PRESENCE) AS PRESENCE,SUM(ABSENT) AS ABSENT,SUM(TOTAL) AS TOTAL'

									
									set @String = @String + ' INTO ##Center_Code from #MANPOWER MP  group By Center_Code'+ @String_2 +''+ @String_3 +''+ @String_4 +''
									
									exec(@String)
									
									if @String_2 <> '' and @String_3 <> '' and @String_4 <> ''
										Begin
											Set @String_2 = ',' + ''''' as ' + Replace(Replace(@String_2,',MP.',''),',','') + ',' + ''''' as ' + Replace(Replace(@String_3,',MP.',''),',','') + '' + ',' + ''''' as ' + Replace(Replace(@String_4,',MP.',''),',','') + ''
										End
									Else if @String_2 <> ''
										Begin
											Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_2,',MP.',''),',','') +''
										End 
									Else if @String_3 <> ''
										Begin
											Set @String_2 =  ',' +''''' as ' + Replace(Replace(@String_3,',MP.',''),',','') + ''
										End
									Else if @String_4 <> ''
										Begin
											Set @String_4 =  ',' +''''' as ' + Replace(Replace(@String_4,',MP.',''),',','') + ''
										End
									
									
									
									set @String = 'Insert into ##Center_Code Select (IsNull(Max(SR_No),0)+1),''Total'''+ @String_2 +', Sum(Total_Emp),
												   SUM(PRESENCE) AS PRESENCE,SUM(ABSENT) AS ABSENT,SUM(TOTAL) AS TOTAL
												   FROM ##Center_Code';

									
									
									exec(@String)
									
									set @String = 'Select * FROM ##Center_Code Order By SR_No';
									
									exec(@String)
									
									set @String = 'DROP TABLE ##Center_Code';	
									
									exec(@String)		
							END	
											
					END			
				ELSE IF @TYPE = 1
					BEGIN
						
							DECLARE @SQL VARCHAR(MAX)
							DECLARE @COLS VARCHAR(MAX)
										
							IF @SUMMARY='0'
								BEGIN
							
										
										SELECT	@COLS = COALESCE(@COLS + ',','')  + '[' + REPLACE(PL.BRANCH,' ','_') + ']' 
										FROM	(
													SELECT	DISTINCT BRANCH
													FROM	#MANPOWER
												) PL
										--ORDER BY EMP_FULL_NAME					
										
										
										
									  SET @SQL = '	SELECT	*
													FROM	 
														(								
															SELECT	REPLACE(BRANCH,'' '',''_'') [BRANCH],EMP_FULL_NAME
																	,ROW_NUMBER() OVER (Order by EMP_FULL_NAME) As SR_No,P.[STATUS]
															FROM	#MANPOWER P
															WHERE	P.[STATUS] =''A''
															
														) YS 
														PIVOT 
														(
															Max(EMP_FULL_NAME) FOR BRANCH IN (' + @COLS + ')
														) PVT
														Order By SR_No'
									  
									PRINT @SQL
									EXEC (@SQL)
								END
							ELSE IF @SUMMARY='1'
								BEGIN
										
										
										SELECT	@COLS = COALESCE(@COLS + ',','')  + '[' + REPLACE(ISNULL(PL.GRADE,''),' ','_') + ']'
										FROM	(
													SELECT	DISTINCT GRADE
													FROM	#MANPOWER
												) PL
										--ORDER BY EMP_FULL_NAME					
													
										
									  SET @SQL = '	SELECT	*
													FROM	 
														(								
															SELECT	REPLACE(ISNULL(PL.GRADE,''''),'' '',''_'') [GRADE],EMP_FULL_NAME
																	,ROW_NUMBER() OVER (Order by EMP_FULL_NAME) As SR_No,P.[STATUS]
															FROM	#MANPOWER P
															WHERE	P.[STATUS] =''A''
														) YS 
														PIVOT 
														(
															Max(EMP_FULL_NAME) FOR GRADE IN (' + @COLS + ')
														) PVT Order By SR_No'
									  
									EXEC (@SQL)
								END
							ELSE IF @SUMMARY='2'
								BEGIN
										
										
										SELECT	@COLS = COALESCE(@COLS + ',','')  + '[' + REPLACE(ISNULL(PL.CATEGORY,''),' ','_') + ']'
										FROM	(
													SELECT	DISTINCT CATEGORY
													FROM	#MANPOWER
												) PL
																				
									  SET @SQL = '	SELECT	*
													FROM	 
														(								
															SELECT	REPLACE(ISNULL(CATEGORY,''''),'' '',''_'')  [CATEGORY],EMP_FULL_NAME
																	,ROW_NUMBER() OVER (Order by EMP_FULL_NAME) As SR_No,P.[STATUS]
															FROM	#MANPOWER P
															WHERE	P.[STATUS] =''A''
														) YS 
														PIVOT 
														(
															Max(EMP_FULL_NAME) FOR CATEGORY IN (' + @COLS + ')
														) PVT Order By SR_No'
									  
									EXEC (@SQL)
								END	
							ELSE IF @SUMMARY='3'
								BEGIN
										
										
										SELECT	@COLS = COALESCE(@COLS + ',','')  + '[' + REPLACE(ISNULL(PL.DEPARTMENT,''),' ','_') + ']'
										FROM	(
													SELECT	DISTINCT DEPARTMENT
													FROM	#MANPOWER
												) PL
																				
									  SET @SQL = '	SELECT	*
													FROM	 
														(								
															SELECT	REPLACE(ISNULL(DEPARTMENT,''''),'' '',''_'')   [DEPARTMENT],EMP_FULL_NAME
																	,ROW_NUMBER() OVER (Order by EMP_FULL_NAME) As SR_No,P.[STATUS]
															FROM	#MANPOWER P
															WHERE	P.[STATUS] =''A''
														) YS 
														PIVOT 
														(
															Max(EMP_FULL_NAME) FOR DEPARTMENT IN (' + @COLS + ')
														) PVT Order By SR_No'
									  
									EXEC (@SQL)
								END	
							ELSE IF @SUMMARY='4'
								BEGIN
										
										
										SELECT	@COLS = COALESCE(@COLS + ',','')  + '[' + REPLACE(ISNULL(PL.DESIGNATION,''),' ','_') + ']'
										FROM	(
													SELECT	DISTINCT DESIGNATION
													FROM	#MANPOWER
												) PL
																				
									  SET @SQL = '	SELECT	*
													FROM	 
														(								
															SELECT	REPLACE(ISNULL(DESIGNATION,''''),'' '',''_'') [DESIGNATION],EMP_FULL_NAME
																	,ROW_NUMBER() OVER (Order by EMP_FULL_NAME) As SR_No,P.[STATUS]
															FROM	#MANPOWER P
															WHERE	P.[STATUS] =''A''
														) YS 
														PIVOT 
														(
															Max(EMP_FULL_NAME) FOR DESIGNATION IN (' + @COLS + ')
														) PVT Order By SR_No'
									  
									EXEC (@SQL)
								END
							ELSE IF @SUMMARY='5'
								BEGIN
										
										
										SELECT	@COLS = COALESCE(@COLS + ',','')  + '[' + REPLACE(ISNULL(PL.TYPENAME,''),' ','_') + ']'
										FROM	(
													SELECT	DISTINCT TYPENAME
													FROM	#MANPOWER
												) PL
										--ORDER BY EMP_FULL_NAME					
													
										
									  SET @SQL = '	SELECT	*
													FROM	 
														(								
															SELECT	REPLACE(ISNULL(TYPENAME,''''),'' '',''_'')  [TYPENAME],EMP_FULL_NAME
																	,ROW_NUMBER() OVER (Order by EMP_FULL_NAME) As SR_No,P.[STATUS]
															FROM	#MANPOWER P
															WHERE	P.[STATUS] =''A''
														) YS 
														PIVOT 
														(
															Max(EMP_FULL_NAME) FOR TYPENAME IN (' + @COLS + ')
														) PVT Order By SR_No'
									  
									EXEC (@SQL)
								END
							ELSE IF @SUMMARY='6'
								BEGIN
										
										
										SELECT	@COLS = COALESCE(@COLS + ',','')  + '[' + REPLACE(ISNULL(PL.DIVISION,''),' ','_') + ']'
										FROM	(
													SELECT	DISTINCT DIVISION
													FROM	#MANPOWER
												) PL
																				
									  SET @SQL = '	SELECT	*
													FROM	 
														(								
															SELECT	 REPLACE(ISNULL(DIVISION,''''),'' '',''_'')  [DIVISION],EMP_FULL_NAME
																	,ROW_NUMBER() OVER (Order by EMP_FULL_NAME) As SR_No,P.[STATUS]
															FROM	#MANPOWER P
															WHERE	P.[STATUS] =''A''
														) YS 
														PIVOT 
														(
															Max(EMP_FULL_NAME) FOR DIVISION IN (' + @COLS + ')
														) PVT Order By SR_No'
									  
									EXEC (@SQL)
								END	
							ELSE IF @SUMMARY='7'
								BEGIN
										
										
										SELECT	@COLS = COALESCE(@COLS + ',','')  + '[' + REPLACE(ISNULL(PL.SUB_VERTICAL,''),' ','_') + ']'
										FROM	(
													SELECT	DISTINCT SUB_VERTICAL
													FROM	#MANPOWER
												) PL
																				
									  SET @SQL = '	SELECT	*
													FROM	 
														(								
															SELECT	REPLACE(ISNULL(SUB_VERTICAL,''''),'' '',''_'')  [SUB_VERTICAL],EMP_FULL_NAME
																	,ROW_NUMBER() OVER (Order by EMP_FULL_NAME) As SR_No,P.[STATUS]
															FROM	#MANPOWER P
															WHERE	P.[STATUS] =''A''
														) YS 
														PIVOT 
														(
															Max(EMP_FULL_NAME) FOR SUB_VERTICAL IN (' + @COLS + ')
														) PVT Order By SR_No'
									  
									EXEC (@SQL)
								END	
							ELSE IF @SUMMARY='8'
								BEGIN
										
										
										SELECT	@COLS = COALESCE(@COLS + ',','')  + '[' + REPLACE(ISNULL(PL.SUB_BRANCH,''),' ','_') + ']'
										FROM	(
													SELECT	DISTINCT SUB_BRANCH
													FROM	#MANPOWER
												) PL
																				
									  SET @SQL = '	SELECT	*
													FROM	 
														(								
															SELECT	REPLACE(ISNULL(SUB_BRANCH,''''),'' '',''_'')  [SUB_BRANCH],EMP_FULL_NAME
																	,ROW_NUMBER() OVER (Order by EMP_FULL_NAME) As SR_No,P.[STATUS]
															FROM	#MANPOWER P
															WHERE	P.[STATUS] =''A''
														) YS 
														PIVOT 
														(
															Max(EMP_FULL_NAME) FOR SUB_BRANCH IN (' + @COLS + ')
														) PVT Order By SR_No' 
									  
									EXEC (@SQL)
								END
							ELSE IF @SUMMARY='9'
								BEGIN
										
										
										SELECT	@COLS = COALESCE(@COLS + ',','')  + '[' + REPLACE(ISNULL(PL.SEGMENT_NAME,''),' ','_') + ']'
										FROM	(
													SELECT	DISTINCT SEGMENT_NAME
													FROM	#MANPOWER
												) PL
																				
									  SET @SQL = '	SELECT	*
													FROM	 
														(								
															SELECT	REPLACE(ISNULL(SEGMENT_NAME,''''),'' '',''_'')  [SEGMENT_NAME],EMP_FULL_NAME
																	,ROW_NUMBER() OVER (Order by EMP_FULL_NAME) As SR_No,P.[STATUS]
															FROM	#MANPOWER P
															WHERE	P.[STATUS] =''A''
														) YS 
														PIVOT 
														(
															Max(EMP_FULL_NAME) FOR SEGMENT_NAME IN (' + @COLS + ')
														) PVT Order By SR_No'
									  
									EXEC (@SQL)
								END	
							ELSE IF @SUMMARY='10'
								BEGIN
										
										
										SELECT	@COLS = COALESCE(@COLS + ',','')  + '[' + REPLACE(ISNULL(PL.CENTER_CODE,''),' ','_') + ']'
										FROM	(
													SELECT	DISTINCT CENTER_CODE
													FROM	#MANPOWER
												) PL
										
										
																		
									  SET @SQL = '	SELECT	*
													FROM	 
														(								
															SELECT	REPLACE(ISNULL(CENTER_CODE,''''),'' '',''_'') [CENTER_CODE],EMP_FULL_NAME
																	,ROW_NUMBER() OVER (Order by EMP_FULL_NAME) As SR_No,P.[STATUS]
															FROM	#MANPOWER P
															WHERE	P.[STATUS] =''A''
														) YS 
														PIVOT 
														(
															Max(EMP_FULL_NAME) FOR CENTER_CODE IN (' + @COLS + ')
														) PVT Order By SR_No'
									  
									EXEC (@SQL)
								END		
										
												
					END	
				ELSE If @TYPE = 2
					BEGIN
						
							If exists (Select 1 from sys.objects where name = 'tempgroup')
								drop TABLE tempgroup
					
							DECLARE @STRING1 AS VARCHAR(MAX)

							IF @SUMMARY IS NOT NULL
								BEGIN
									SET @STRING1 = 'SELECT (CASE WHEN '+ @SUMMARY +'=''0'' THEN ''BRANCH'' WHEN '+ @SUMMARY +' =''1'' THEN ''GRADE'' WHEN '+ @SUMMARY +' =''2'' THEN ''CATEGORY'' WHEN '+ @SUMMARY +' =''3'' THEN ''DEPARTMENT'' WHEN '+ @SUMMARY +' =''4'' THEN ''DESIGNATION'' WHEN '+ @SUMMARY +' =''5'' THEN ''TYPENAME'' WHEN '+ @SUMMARY +' =''6'' THEN ''DIVISION'' WHEN '+ @SUMMARY +' =''7'' THEN ''SUB_VERTICAL'' WHEN '+ @SUMMARY +' =''8'' THEN ''SUB_BRANCH'' WHEN '+ @SUMMARY +' =''9'' THEN ''SEGMENT_NAME'' WHEN '+ @SUMMARY +' =''10'' THEN ''CENTER_CODE'' END ) AS DESCRIPTION INTO TEMPGROUP'
									EXEC(@STRING1)
									SELECT @STRING1 = DESCRIPTION FROM TEMPGROUP											
								END 


							DECLARE @GROUP_1 VARCHAR(64) 
							DECLARE @GROUP_2 VARCHAR(64) 
							DECLARE @COLUMN_NAME VARCHAR(MAX)
							DECLARE @SUMMONTHCOL VARCHAR(MAX)
							SET @GROUP_2 = @STRING_5
							SET @GROUP_1 = @STRING1

							CREATE TABLE #ROWDATA
							(
								EMP_ID	NUMERIC,
								GROUP1	VARCHAR(64),
								GROUP2	VARCHAR(64),
								GROUPVALUE NUMERIC(18,4)
							)

							CREATE TABLE #GROUPDATA
							(
								ROW_ID	    INT,
								GROUPLABEL	VARCHAR(64),
								LABEL	    VARCHAR(64),						
								LABELVALUE  NUMERIC(18,4)
							)		


							DECLARE @SQL1 AS NVARCHAR(MAX)
							SET @SQL1 = 'INSERT	INTO #ROWDATA(EMP_ID, GROUP1, GROUP2, GROUPVALUE)
										SELECT	MP.EMP_ID,' + @GROUP_1 + ',ISNULL(' + @GROUP_2 + ',''.Not Assigned''),MP.[PRESENCE] 
										FROM	#MANPOWER MP'										
						
							EXEC SP_EXECUTESQL @SQL1 

							

							INSERT INTO #GROUPDATA (ROW_ID,GROUPLABEL, LABEL, LABELVALUE)
							SELECT	ROW_NUMBER() OVER(ORDER BY GROUP1,GROUP2,ID) AS ROW_ID,GROUP1, LABEL, LABELVALUE
							FROM	(SELECT	1 AS ID,GROUP1 ,  GROUP2 + '#Present Count' AS LABEL, SUM(GROUPVALUE) AS LABELVALUE ,GROUP2
							
									 FROM #ROWDATA 
									 GROUP BY GROUP1,GROUP2
									 --UNION ALL
									 --SELECT 2 AS ID,GROUP1,  GROUP2 + '#NO OF EMPLOYEE' AS LABEL, COUNT(1) AS LABELVALUE ,GROUP2
									 --FROM #ROWDATA 
									 --GROUP BY GROUP1,GROUP2
									) T
							 											
					
					
							DECLARE @SUMCOL VARCHAR(MAX)
							SELECT	@COLS = COALESCE(@COLS + ',','')  + '[' + ISNULL(PL.LABEL,'')  + ']'
							FROM	(
										SELECT		distinct LABEL
										FROM		#GROUPDATA									
									) PL
							ORDER BY LABEL

							SELECT	@SUMCOL = COALESCE(@SUMCOL + ',','')  + 'SUM(' + ISNULL('[' + PL.LABEL + ']','')  + ')'
							FROM	(
										SELECT		distinct LABEL
										FROM		#GROUPDATA									
									) PL
							ORDER BY LABEL
														
																	
							SET @STRING = '	SELECT  ROW_NUMBER() OVER (ORDER BY GROUPLABEL) AS SR_NO,*											 
											INTO	##EMPLOYEE_FINAL
											FROM	(
														SELECT  GROUPLABEL,LABEL,LABELVALUE
														FROM	#GROUPDATA
													) T
													PIVOT (
														MAX(LABELVALUE) FOR LABEL IN (' + @COLS + ')
													) PVT'				
																		
							EXEC (@STRING)
							
							SET @SQL1 = 'INSERT INTO ##EMPLOYEE_FINAL
									SELECT MAX(SR_NO) + 1,''GRAND TOTAL'',' + @SUMCOL + ',' + @SUMMONTHCOL + '
									FROM  ##EMPLOYEE_FINAL'
					

						--PRINT @SQL
						EXEC SP_EXECUTESQL @SQL1

						SET @SQL1 = 'EXEC tempdb..sp_rename ''dbo.##EMPLOYEE_FINAL.[GROUPLABEL]'',''' + @GROUP_1 + ''',''COLUMN'''
						--PRINT @SQL
						EXEC SP_EXECUTESQL @SQL1

						
						
						SELECT * FROM ##EMPLOYEE_FINAL
						Order By SR_NO
						

						DROp TABLE ##EMPLOYEE_FINAL

					

					END
				--SELECT * FROM #MANPOWER	
			
				
		

