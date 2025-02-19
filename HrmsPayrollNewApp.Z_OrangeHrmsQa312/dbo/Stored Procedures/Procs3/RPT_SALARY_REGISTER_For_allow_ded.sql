CREATE PROCEDURE [dbo].[RPT_SALARY_REGISTER_For_allow_ded]
	-- ADD THE PARAMETERS FOR THE STORED PROCEDURE HERE
	 @CMP_ID NUMERIC(18,0),
	 @FROM_DATE DATETIME,
	 @TO_DATE DATETIME,
	 @BRANCH_ID NUMERIC(18,0),
	 @CAT_ID NUMERIC(18,0) = 0,
	 @GRD_ID NUMERIC(18,0) = 0,
	 @TYPE_ID NUMERIC(18,0) = 0,
	 @DEPT_ID NUMERIC(18,0) = 0,
	 @DESIG_ID NUMERIC(18,0) = 0,
	 @EMP_ID NUMERIC(18,0) = 0,
	 @CONSTRAINT NVARCHAR(MAX)='',
	 @SAL_TYPE NUMERIC(18,0) = 0,
	 @SALARY_CYCLE_ID NUMERIC(18,0)=0,
	 @SEGMENT_ID NUMERIC(18,0)=0,
	 @VERTICAL_ID NUMERIC(18,0)=0,
	 @SUBVERTICAL_ID NUMERIC(18,0)=0,
	 @SUBBRANCH_ID NUMERIC(18,0)=0,
	 @PBRANCH_ID VARCHAR(MAX)= '0',   --changed by jimit 27012017
	 @Show_Hidden_Allowance  bit = 0   --Added by Jaina 16-05-2017
	,@Group_Name	integer = 0		----- Add jignesh Patel 25 10 2021 for Chiripal
	,@Summary_Option  Int = -1  --- Add by Jignesh Patel 30-Sep-2021---- For Chiripal (1  For Summary)
AS
BEGIN
	-- SET NOCOUNT ON ADDED TO PREVENT EXTRA RESULT SETS FROM
	-- INTERFERING WITH SELECT STATEMENTS.
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON

	------ Add by Jignesh Patel 04-10-2021---- For Chiripal (1  For Summary)
	--If Isnull(@Show_Hidden_Allowance,0) = 0
	--	Begin
	--		SET @Summary_Option =1
	--	ENd
	If Isnull(@Summary_Option,0)=8
	Begin
		SET @Summary_Option =0
	End
	Else
	Begin
		SET @Summary_Option =@Summary_Option+1
	ENd
	----------------- END --------------------
	

	set @Show_Hidden_Allowance = 0
	
	IF @SALARY_CYCLE_ID = 0
		SET @SALARY_CYCLE_ID = NULL		
	IF @SEGMENT_ID = 0 
		SET @SEGMENT_ID = NULL
	IF @VERTICAL_ID = 0 
		SET @VERTICAL_ID = NULL
	IF @SUBVERTICAL_ID = 0 
		SET @SUBVERTICAL_ID  = NULL
	IF @SUBBRANCH_ID = 0
		SET @SUBBRANCH_ID = NULL

	DROP INDEX IF EXISTS IX_EMP_CONS_EMPID ON tempdb.#EMP_CONS
	
	CREATE TABLE #EMP_CONS 
	 (      
		EMP_ID		 NUMERIC ,     
		BRANCH_ID	 NUMERIC,
		INCREMENT_ID NUMERIC
	 )      
	
	EXEC SP_RPT_FILL_EMP_CONS  @CMP_ID,@FROM_DATE,@TO_DATE,@BRANCH_ID,@CAT_ID,@GRD_ID,@TYPE_ID,@DEPT_ID,@DESIG_ID ,@EMP_ID ,@CONSTRAINT ,0 ,0 ,0,0,0,0,0,0,0,0,0,0	
	
	IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name='IX_EMP_CONS_EMPID')
	begin
		CREATE INDEX IX_EMP_CONS_EMPID ON #EMP_CONS (EMP_ID);	
	end
	
	DECLARE @MONTH NUMERIC(18,0)
	DECLARE @YEAR NUMERIC(18,0)
	DECLARE @CUR_EMP_ID NUMERIC(18,0)
	DECLARE @CUR_SAL_TRAN_ID NUMERIC(18,0)
	DECLARE @CUR_ALPHA_EMP_CODE NVARCHAR(50)
	DECLARE @CUR_UANNO NVARCHAR(50)
	DECLARE @CUR_EMP_FULL_NAME NVARCHAR(250)
	DECLARE @CUR_DESIGNATION NVARCHAR(50)
	DECLARE @CUR_ESIC_NO NVARCHAR(20)
	
	SET @MONTH = MONTH(@TO_DATE)
	SET @YEAR = YEAR(@TO_DATE)
	
	CREATE TABLE #EMP_DETAILS
	(
		EMP_ID NUMERIC(18,0),
		SAL_TRAN_ID NUMERIC(18,0),
		UANNO	NVARCHAR(100),
		GROSS_SALARY NUMERIC(18,2),
		GROSS_DEDUCTION NUMERIC(18,2),
		PF_WAGES	NUMERIC(18,2),
		PF_WAGES_Arrear	NUMERIC(18,2),--added by mansi 
		ESI_WAGES	NUMERIC(18,2),
		CTC NUMERIC(18,2),
		Sal_Cal_Day NUMERIC(18,2), --Mukti(06032017)		
		ESIC_NO     NVARCHAR(20)  --Added By Jimit 28122017
		
	)
	CREATE TABLE #WORKING_DETAILS
	(
		EMP_ID		NUMERIC(18,0),
		SAL_TRAN_ID NUMERIC(18,0),
		PARA_NAME	NVARCHAR(25),
		DAYS		NUMERIC(18,2),
		PARA_TYPE	TINYINT
		
	)
	CREATE TABLE #RATEOFWAGES
	(
		EMP_ID           NUMERIC(18,0),
		SAL_TRAN_ID      NUMERIC(18,0),
		ALLOWANCE_NAME   NVARCHAR(100),
		RATE_TYPE		 NVARCHAR(10),
		ALLOWANCE_AMOUNT NUMERIC(18,2),
		ALLOWANCE_TYPE	 CHAR(1)
		
	)



	--added by mansi start
	  declare @PF_LIMIT	as numeric
	  DECLARE @PF_DEF_ID	as numeric
	  SET @PF_LIMIT = 15000
	  SET @PF_DEF_ID = 2
	  declare @Format  tinyint = 8 

	  If Object_ID('tempdb..#EMP_SALARY') is NOT Null
		begin
			drop table #EMP_SALARY
		end
	
		CREATE table #EMP_SALARY 
			(
				EMP_ID					NUMERIC,
				MONTH					NUMERIC,
				YEAR					NUMERIC,
				SALARY_AMOUNT			NUMERIC,
				OTHER_PF_SALARY			NUMERIC,
				MONTH_ST_DATE			DATETIME,
				MONTH_END_DATE			DATETIME,
				PF_SALARY_AMOUNT		NUMERIC,
				PF_LIMIT				numeric,
				Sal_Cal_Day				Numeric(18,2), -- Added by Falak on 09-MAY-2011
				Absent_days				NUMERIC,
				Is_Sett                 TinyINt Default 0,    --Nikunj 25-04-2011
				Sal_Effec_Date          DateTime Default GetDate(), --Nikunj 25-04-2011
				Arrear_Wages			Numeric --Hardik 17/04/2012
				
			 )
			
		
			DECLARE @String as varchar(max)
								   
		    INSERT INTO #EMP_SALARY
		    
			
		    SELECT  
			SG.EMP_ID,MONTH(MONTH_ST_DATe),YEAR(MONTH_ST_DATE),SG.Salary_Amount 
				 ,0 ,sg.Month_st_Date,SG.Month_End_date,
			
				case	when @Format IN (8) then
							Case When (Arear_Basic  + case when OAB.basic_salary < @PF_Limit then  Isnull(Qr_1.M_AREAR_AMOUNT1,0) else 0 end + Arear_M_AD_Calculated_Amount) < @PF_LIMIT then
								Arear_Basic  + case when OAB.basic_salary < @PF_Limit then  Isnull(Qr_1.M_AREAR_AMOUNT1,0) else 0 end  
							Else
								Case When Arear_M_AD_Calculated_Amount < @PF_Limit And OAB.Basic_Salary < @PF_LIMIT  Then 
									@PF_LIMIT - Arear_M_AD_Calculated_Amount 
								Else Arear_Basic  + case when OAB.basic_salary < @PF_Limit then  Isnull(Qr_1.M_AREAR_AMOUNT1,0) else 0 end  
								End
							End 							

						when @Format in (4,5,10,2) then  m_ad_Calculated_Amount + case when sg.basic_salary < @PF_Limit then  Isnull(Qr_1.M_AREAR_AMOUNT1,0) else 0 end 
				else  m_ad_Calculated_Amount end as m_ad_Calculated_Amount ,
				 @PF_Limit
				 ,SG.Sal_Cal_Days,0,0,NULL,
				 case when @Format in (3,8,4,10,2) then 
					Case When (Arear_Basic  + case when OAB.basic_salary < @PF_Limit then  Isnull(Qr_1.M_AREAR_AMOUNT1,0) else 0 end + Arear_M_AD_Calculated_Amount) < @PF_LIMIT then
								Arear_Basic  + case when OAB.basic_salary < @PF_Limit then  Isnull(Qr_1.M_AREAR_AMOUNT1,0) else 0 end  
							Else
								Case When Arear_M_AD_Calculated_Amount < @PF_Limit And OAB.Basic_Salary < @PF_LIMIT  Then 
									@PF_LIMIT - Arear_M_AD_Calculated_Amount 
								Else Arear_Basic  + case when OAB.basic_salary < @PF_Limit then  Isnull(Qr_1.M_AREAR_AMOUNT1,0) else 0 end  
								End
							End 
				else (Isnull(Arear_Basic,0))  end  as Arear_Basic 
				

				FROM    T0200_MONTHLY_SALARY  SG  WITH (NOLOCK) INNER JOIN 
				(Select ad.Emp_ID , m_ad_Percentage as PF_PER ,
						(m_ad_Amount + isnull(M_AREAR_AMOUNT_Cutoff,0)) as PF_Amount,(isnull(M_AREAR_AMOUNT,0) ) as M_AREAR_AMOUNT 
						 ,m_ad_Calculated_Amount + Case When @Format in (4,5,2) then ISNULL(Arear_Basic,0) Else 0 end + (case when isnull(ad.M_AREAR_AMOUNT_Cutoff,0)=0 then 0 else MS.Basic_Salary_Arear_cutoff end) as m_ad_Calculated_Amount ,ad.SAL_tRAN_ID 
				 ,M_AREAR_AMOUNT_Cutoff
				 from T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID 
				 inner join t0200_monthly_salary MS WITH (NOLOCK) on AD.sal_tran_id = ms.sal_tran_id
				 where ad_DEF_id = @PF_DEF_ID  And ad_not_effect_salary <> 1 and sal_type<>1
						and AD.CMP_ID = @CMP_ID 
				)MAD on SG.Emp_ID = MAD.Emp_ID  
						AND SG.SAL_tRAN_ID = MAD.SAL_TRAN_ID INNER JOIN
						T0080_EMP_MASTER E WITH (NOLOCK) ON SG.EMP_ID = E.EMP_ID inner join
						t0095_increment inc WITH (NOLOCK) on Sg.increment_id = inc.increment_id inner join
						#EMP_CONS E_S on E.Emp_ID = E_S.Emp_ID
				left outer join
				 (Select Emp_ID,
				M_AD_Amount AS VPF, isnull(M_AREAR_AMOUNT,0) + isnull(M_AREAR_AMOUNT_Cutoff,0) as VPF_Arear,
				SAL_tRAN_ID,AD.M_AD_Percentage as VPF_PER  
				 from T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID 
				 where ad_DEF_id = 4  And ad_not_effect_salary <> 1 and sal_type<>1
				      and AD.CMP_ID = @CMP_ID
				 ) CMD on SG.Emp_ID= CMD.Emp_ID AND SG.SAL_tRAN_ID = CMD.SAL_TRAN_ID				
				left outer join  -- Added by rohit on 05102015
				(Select Emp_ID,(isnull(M_AREAR_AMOUNT,0) + isnull(M_AREAR_AMOUNT_Cutoff,0)) as Other_PF_Calculate ,SAL_tRAN_ID 
				 from T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID  
				 where AD.ad_id = (SELECT  TOP 1 EAM.AD_ID  FROM dbo.T0060_EFFECT_AD_MASTER EAM WITH (NOLOCK)  --Added By Jaina 5-11-2015 (Top 1)
														 inner join T0050_AD_MASTER AM WITH (NOLOCK) on EAM.Effect_AD_ID = AM.AD_ID and EAM.CMP_ID = AM.CMP_ID
								   WHERE AM.AD_DEF_ID  = @PF_DEF_ID AND Am.Cmp_ID  = @Cmp_ID
								  )And ad_not_effect_salary <> 1 and sal_type<>1
					and AD.CMP_ID = @CMP_ID
				) CMD_new on SG.Emp_ID= CMD_new.Emp_ID AND SG.SAL_tRAN_ID = CMD_new.SAL_TRAN_ID							
				LEFT OUTER JOIN	--Get Arear Calculated Amount --Ankit 06042016
				( SELECT MAD1.Emp_ID , m_ad_Amount AS arear_m_ad_Amount , m_ad_Calculated_Amount AS arear_m_ad_Calculated_Amount,
						MAD1.For_Date,MAD1.To_date
				  FROM	T0210_MONTHLY_AD_DETAIL MAD1 WITH (NOLOCK) INNER JOIN
						T0050_AD_MASTER AM WITH (NOLOCK) ON MAD1.AD_ID = AM.AD_ID  INNER JOIN
						#EMP_CONS Qry1 on MAD1.Emp_ID = Qry1.Emp_ID
				  WHERE ad_DEF_id = @PF_DEF_ID  AND ad_not_effect_salary <> 1 AND sal_type<>1
				)  Qry_arear ON Qry_arear.Emp_ID = SG.Emp_ID 
						AND Qry_arear.For_Date >= CASE WHEN SG.Arear_Month <> 0 THEN dbo.GET_MONTH_ST_DATE(SG.Arear_Month,SG.Arear_Year) ELSE dbo.GET_MONTH_ST_DATE(NULL,NULL) END
						AND Qry_arear.to_date <= CASE WHEN SG.Arear_Month <> 0 THEN dbo.GET_MONTH_END_DATE(SG.Arear_Month,SG.Arear_Year) ELSE dbo.GET_MONTH_END_DATE(NULL,NULL) END						
				LEFT OUTER JOIN
					(Select MS.Emp_ID, Sum(MS.Arear_Basic) As Other_Arear_Basic, MS.Arear_Month, MS.Arear_Year,basic_salary
						From T0200_MONTHLY_SALARY MS WITH (NOLOCK) INNER JOIN
							 #EMP_CONS EC1 on MS.Emp_ID = EC1.Emp_ID
						WHERE Isnull(MS.Arear_Month,0) <> 0 And Isnull(MS.Arear_Year,0) <> 0 And MS.Month_End_Date <=@To_Date
						GROUP BY MS.Emp_ID, MS.Arear_Month, MS.Arear_Year,basic_salary
					)OAB On SG.Emp_ID=OAB.Emp_ID And SG.Arear_Month=OAB.Arear_Month And SG.Arear_Year=OAB.Arear_Year 
				
				LEFT OUTER JOIN(
									SELECT	MAD1.EMP_ID,ISNULL(SUM(M_AREAR_AMOUNT),0) + ISNULL(SUM(M_AREAR_AMOUNT_Cutoff),0) as M_AREAR_AMOUNT1,MONTH(MAD1.To_DATE) as monthArrear,Year(MAD1.To_DATE) as YearArrear
									FROM	T0210_MONTHLY_AD_DETAIL MAD1 WITH (NOLOCK) INNER JOIN
											T0050_AD_MASTER AM WITH (NOLOCK) ON MAD1.AD_ID = AM.AD_ID  INNER JOIN
											#EMP_CONS Qry1 on MAD1.Emp_ID = Qry1.Emp_ID
									WHERE	MONTH(MAD1.To_DATE) = MONTH(@TO_DATE) And YEAR(MAD1.To_DATE) = YEAR(@To_Date)
											AND ad_not_effect_salary = 0 and AD_FLAG = 'I' --and M_AREAR_AMOUNT <> 0 -- Commented by Hardik 07/08/2020 for WHFL Case, cutoff Allowance minus amounts not adding in PF Wages
											and AM.ad_id in (SELECT  EAM.AD_ID  
															FROM	dbo.T0060_EFFECT_AD_MASTER EAM WITH (NOLOCK) 
																	inner join T0050_AD_MASTER AM WITH (NOLOCK) on EAM.Effect_AD_ID = AM.AD_ID and EAM.CMP_ID = AM.CMP_ID
															WHERE	AM.AD_DEF_ID  = @PF_DEF_ID AND Am.Cmp_ID  = @Cmp_ID
															)
									GROUP BY MAD1.Emp_ID,Mad1.To_date
								)Qr_1 ON Qr_1.EMP_ID = SG.Emp_id --and SG.Arear_Month=Qr_1.monthArrear And SG.Arear_Year=Qr_1.YearArrear
				
		WHERE   e.CMP_ID = @CMP_ID --changed by Falak on 04-JAN-2010 due error in condition and more than one record for same emp binds.
 				and SG.Month_St_Date >=@From_Date  and SG.Month_End_Date <= @To_Date  

				If Exists(Select S_Sal_Tran_Id From dbo.T0201_monthly_salary_sett WITH (NOLOCK) where S_Eff_Date Between @From_Date And @To_Date And Cmp_Id=@Cmp_Id)

				
	Begin 
	   print 222---mansi
	    
				INSERT INTO #EMP_SALARY
				SELECT  SG.EMP_ID,MONTH(S_MONTH_ST_DATe),YEAR(S_MONTH_ST_DATE),SG.s_Salary_Amount,0,sg.S_Month_st_Date,SG.S_Month_End_date
					 --,MAD.PF_PER,MAD.PF_AMOUNT
					, m_ad_Calculated_Amount ,@PF_Limit,
					 --SG.S_Sal_Cal_Days,0,1,SG.S_Eff_date,0,0,0,VPF, -- Added by Falak on 09-MAY-2011
					 SG.S_Sal_Cal_Days,0,1,SG.S_Eff_date,
					 0
					 
					FROM t0201_monthly_salary_sett  SG  WITH (NOLOCK) INNER JOIN 
					( select Emp_ID , m_ad_Percentage as PF_PER , --(m_ad_Amount + isnull(M_AREAR_AMOUNT,0)) as PF_Amount
						m_ad_Amount as PF_Amount,(isnull(M_AREAR_AMOUNT,0) + isnull(M_AREAR_AMOUNT_Cutoff,0)) as M_AREAR_AMOUNT,
						m_ad_Calculated_Amount ,S_SAL_tRAN_ID from 
						T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID  
						where ad_DEF_id = @PF_DEF_ID And ad_not_effect_salary <> 1 And ad.sal_type=1
						and AD.CMP_ID = @CMP_ID AND m_ad_Amount <> 0 ---- Greter Than Zero Condition --Ankit 06062016
					) MAD on SG.Emp_ID = MAD.Emp_ID 
						AND SG.S_SAL_tRAN_ID = MAD.S_SAL_TRAN_ID INNER JOIN
						T0080_EMP_MASTER E WITH (NOLOCK) ON SG.EMP_ID = E.EMP_ID inner join
						t0095_increment inc WITH (NOLOCK) on Sg.increment_id = inc.increment_id inner join
					#EMP_CONS E_S on E.Emp_ID = E_S.Emp_ID	
					left outer join
					--Change Condition from Sal_Tran_Id to S_Sal_Tran_Id by Hardik 03/12/2016 for Wonder case for Twice Salary Settlement
					--(Select Emp_ID,(m_ad_Amount + isnull(M_AREAR_AMOUNT,0) + isnull(M_AREAR_AMOUNT_Cutoff,0)) as VPF,SAL_tRAN_ID  from 
					(Select Emp_ID,(m_ad_Amount + isnull(M_AREAR_AMOUNT,0) + isnull(M_AREAR_AMOUNT_Cutoff,0)) as VPF_Arear,AD.S_Sal_Tran_ID,AD.M_AD_Percentage as VPF_PER  from 
						T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID  where ad_DEF_id = 4  And ad_not_effect_salary <> 1 and sal_type=1
						and AD.CMP_ID = @CMP_ID) CMD on SG.Emp_ID= CMD.Emp_ID AND SG.S_Sal_Tran_ID = CMD.S_Sal_Tran_ID
					LEFT OUTER JOIN	--Get Arear Calculated Amount --Ankit 06042016
					( SELECT MAD1.Emp_ID , m_ad_Amount AS arear_m_ad_Amount , m_ad_Calculated_Amount AS arear_m_ad_Calculated_Amount,MAD1.For_Date,MAD1.To_date,Sal_Tran_ID
					  FROM	T0210_MONTHLY_AD_DETAIL MAD1 WITH (NOLOCK) INNER JOIN 
							T0050_AD_MASTER AM WITH (NOLOCK) ON MAD1.AD_ID = AM.AD_ID  INNER JOIN
							#EMP_CONS Qry1 on MAD1.Emp_ID = Qry1.Emp_ID
					  WHERE ad_DEF_id = @PF_DEF_ID  AND ad_not_effect_salary <> 1 AND sal_type<>1
					)  Qry_arear ON Qry_arear.Emp_ID = SG.Emp_ID AND SG.Sal_Tran_ID = Qry_arear.Sal_Tran_ID 
			WHERE   e.CMP_ID = @CMP_ID 
						And S_Eff_Date Between @From_Date And @To_Date
 					--and SG.s_Month_St_Date >=@From_Date  and SG.s_Month_End_Date <= @To_Date 
 					
 			
				Update #EMP_SALARY Set 
				Arrear_Wages= Isnull(Arrear_Wages,0) + Isnull(Qry.PF_Salary_Amount,0),
				is_sett=2
				From 
				#EMP_SALARY As ES INNER JOIN
				(Select SUM(Salary_Amount) As Salary_Amount,--SUM(PF_Amount) As PF_Amount,
				SUM(PF_Salary_Amount) As PF_Salary_Amount,
				Emp_Id,Sal_Effec_Date 
				 
				From #EMP_SALARY where Is_Sett=1 Group By Emp_Id,Sal_Effec_Date ) As Qry ON ES.Emp_Id=Qry.Emp_ID And ES.Month=Month(Qry.Sal_Effec_Date) And ES.Year=Year(Qry.Sal_Effec_Date)

				Delete From #EMP_SALARY where Is_Sett=1
	End	
					
	  
	--added by mansi end
	--added by mansi start
		Declare @Ar_Salary_Amt_Basic as numeric (22,2)
			declare @temp_emp_Id as numeric
						set @temp_emp_Id=0
						declare @tmp_PF_wages as numeric (22,2)
						declare @tmp_PF_wages_arrear as numeric (22,2)
						declare @tmp_ESI_wages as numeric (22,2)
						--set @tmp_M_AD_Calculated_Amount=0
						Declare @Basic_Amt as numeric (22,2)
			           declare @tmp_emp_Id as numeric
						set @tmp_emp_Id=0
						declare @Total_Earning_Amt as numeric (22,2)
						declare @Total_Deduction_Amt as numeric (22,2)
						declare @CTC as numeric (22,2)
	--added by mansi end

	
	--added by mansi 04-10-22 start
				 IF OBJECT_ID(N'tempdb..#TmpArrear_Amount') IS NOT NULL
					BEGIN
					DROP TABLE #TmpArrear_Amount
					END
						 

				 Select  mad.Emp_ID as Emp_ID,mad.Cmp_ID as Cmp_ID,0 as Transaction_ID,@month as Month,@Year as Year,MAD.AD_ID,AD_NAME,
					 mad.M_AD_Flag,(AD_SORT_NAME+'_Arrear')as AD_SORT_NAME,Isnull(SUM(M_AD_Amount),0)as M_Arrear_Amt  
						,'' as Value_String,0 as INCOME_TAX_ID,AD_DEF_ID
						into #TmpArrear_Amount 
						From t0210_monthly_ad_detail MAD WITH (NOLOCK) inner join
						         #EMP_CONS ec on ec.EMP_ID=mad.Emp_ID inner join
									T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK) on MSS.S_Sal_Tran_ID = MAD.S_Sal_Tran_ID inner join -- Added by Nilesh Patel on 11-08-2017 For Salary Settelment ID 
									--MAD.Sal_Tran_ID=MSS.Sal_Tran_ID inner join Comment by nilesh patel on 11-08-2017 For get issue when Same month Settelment in twice
									T0050_AD_MASTER WITH (NOLOCK) on MAD.Ad_Id = T0050_AD_MASTER.Ad_ID
									and MAD.Cmp_ID = T0050_AD_MASTER.Cmp_Id
									--and MAD.Emp_ID  = @Emp_ID
								where MAD.Cmp_ID = @Cmp_ID and month(MSS.S_Eff_Date) =  MONTH(@To_Date) and Year(MSS.S_Eff_Date) = YEAR(@To_Date)
									and (isnull(mad.M_AD_NOT_EFFECT_SALARY,0) = 0 Or  (M_AD_NOT_EFFECT_SALARY = 1 and MAD.reimShow= 1))
									and Ad_Active = 1 
									--and AD_Flag = 'D' --Comment B'cos Sett Amount display in Arear amount column - AIA - Ankit  03062016
									And Sal_Type = 1 and Isnull(MSS.Effect_On_Salary,0) = 1	--Condition Added by Nilesh (If not effect in salary option is selected during settlement then the component should not be displayed in payslip) 17-07-2017
								Group By AD_SORT_NAME,MAD.AD_ID,MSS.Emp_ID,mad.M_AD_Flag,AD_NAME,AD_DEF_ID,mad.Emp_ID,mad.Cmp_ID
             
					IF OBJECT_ID(N'tempdb..#tmp_Basic_Arrear') IS NOT NULL
					BEGIN
					DROP TABLE #tmp_Basic_Arrear
					END


                	select  ms.Emp_ID,ms.Cmp_ID,0 as Transaction_Id,@month as Month,@year as Year,0 as AD_ID,''as AD_NAME,'I' as M_AD_Flag,'Basic_Arrear' as AD_SORT_NAME,
			isnull(sum(ms.S_Salary_Amount),0)as M_Arrear_Amt,'' as Value_String,0 as INCOME_TAX_ID,0 as AD_DEF_ID
			into #tmp_Basic_Arrear
				FROM T0201_MONTHLY_SALARY_SETT ms WITH (NOLOCK) 
				INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID      
				where ms.Emp_ID in(SELECT  ms.Emp_ID FROM T0200_Monthly_Salary  ms WITH (NOLOCK) 
				INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID         
									where MONTH(Month_End_Date) = MONTH(@To_Date) AND YEAR(Month_End_Date) = YEAR(@To_Date))
										and Isnull(ms.Effect_On_Salary,0) = 1 	
                                        and  S_Eff_Date=(@FROM_DATE)

										--Condition Added by Nilesh (If not effect in salary option is selected during settlement then the component should not be displayed in payslip) 17-07-2017
				GROUP BY ms.Emp_ID,S_Eff_Date ,ms.Cmp_ID	
				
				
			--added by mansi 04-10-22 end
	DECLARE CUR_EMP CURSOR FOR
	SELECT	SG.EMP_ID ,SG.SAL_TRAN_ID,E.UAN_No,E.SIN_No 
	FROM	DBO.T0200_MONTHLY_SALARY SG WITH (NOLOCK)
			INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON SG.EMP_ID =E.EMP_ID 
			INNER JOIN #EMP_CONS EC ON E.EMP_ID = EC.EMP_ID 
	WHERE	SG.CMP_ID = @CMP_ID AND MONTH(SG.MONTH_END_DATE) = @MONTH 
			AND YEAR(SG.MONTH_END_DATE) = @YEAR AND ISNULL(SG.IS_FNF,0)=0

	OPEN  CUR_EMP
	FETCH NEXT FROM CUR_EMP INTO @EMP_ID ,@CUR_SAL_TRAN_ID,@CUR_UANNO,@CUR_ESIC_NO
	WHILE @@FETCH_STATUS = 0
		BEGIN
		   --added by mansi start
		   	SELECT @Ar_Salary_Amt_Basic= SUM(ms.S_Salary_Amount),@temp_emp_Id=ms.Emp_ID
				FROM T0201_MONTHLY_SALARY_SETT ms WITH (NOLOCK) 
				where ms.Emp_ID in(SELECT  ms.Emp_ID FROM T0200_Monthly_Salary  ms WITH (NOLOCK) --INNER JOIN #Emp_Cons ec ON ms.Emp_ID = ec.emp_ID         
									where MONTH(Month_End_Date) = @Month AND YEAR(Month_End_Date) = @Year
									and Emp_ID=@Emp_ID)
										and Isnull(ms.Effect_On_Salary,0) = 1	--Condition Added by Nilesh (If not effect in salary option is selected during settlement then the component should not be displayed in payslip) 17-07-2017
				GROUP BY ms.Emp_ID,S_Eff_Date

       
			select @Basic_Amt=Salary_Amount + Isnull(Basic_Salary_Arear_cutoff,0)
           from dbo.T0200_MONTHLY_SALARY WITH (NOLOCK)
		   where Emp_ID = @EMP_ID and Month(Month_End_Date) = @MONTH and Year(Month_End_Date) = @YEAR 
		   --added 080422 start
				 IF OBJECT_ID(N'tempdb..#TmpAmount') IS NOT NULL
					BEGIN
					DROP TABLE #TmpAmount
					END
						 --added 080422 end

			
				Select  @Emp_ID as Emp_ID,@Cmp_ID as Cmp_ID,0 as Transaction_ID,@month as Month,@Year as Year,MAD.AD_ID,AD_NAME,
					   mad.M_AD_Flag,(AD_SORT_NAME)as AD_SORT_NAME,Isnull(SUM(M_AD_Amount),0)as M_Arrear_Amt
					   	,'' as Value_String,0 as INCOME_TAX_ID,AD_DEF_ID
						--sum(M_AD_Amount)as M_AD_Amount
						into #TmpAmount
						From t0210_monthly_ad_detail MAD WITH (NOLOCK) 
						--inner join T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK) on MSS.S_Sal_Tran_ID = MAD.S_Sal_Tran_ID 
						inner join T0050_AD_MASTER WITH (NOLOCK) on MAD.Ad_Id = T0050_AD_MASTER.Ad_ID
						and MAD.Cmp_ID = T0050_AD_MASTER.Cmp_Id and MAD.Emp_ID  = @Emp_ID
								where MAD.Cmp_ID = @Cmp_ID and month(mad.To_date) =  MONTH(@To_Date) and Year(mad.To_date) = YEAR(@To_Date)
									and (isnull(mad.M_AD_NOT_EFFECT_SALARY,0) = 0 Or  (M_AD_NOT_EFFECT_SALARY = 1 and MAD.reimShow= 1))
									and Ad_Active = 1 and MAD.M_AD_Amount > 0--and M_AD_Flag='I'
										Group By AD_SORT_NAME,MAD.AD_ID,mad.M_AD_Flag,AD_NAME,AD_DEF_ID

							
				insert into #TmpAmount(Emp_ID,Cmp_ID,Transaction_ID,Month,Year,AD_ID,AD_NAME,M_AD_Flag,AD_SORT_NAME,M_Arrear_Amt,Value_String,INCOME_TAX_ID,AD_DEF_ID) 
										                 values(@Emp_ID,@Cmp_ID,0,@month,@Year,0,'','I','Basic',@Basic_Amt,'',0,0)		  
			

			 --Added by ronakk 16022023   
				insert into #TmpAmount(Emp_ID,Cmp_ID,Transaction_ID,Month,Year,AD_ID,AD_NAME,M_AD_Flag,AD_SORT_NAME,M_Arrear_Amt,Value_String,INCOME_TAX_ID,AD_DEF_ID)
				select @Emp_ID,@Cmp_ID,0,@month,@Year,0,'','D','PT',PT_Amount,'',0,0 from T0200_MONTHLY_SALARY 
				where Cmp_ID= @CMP_ID and Emp_ID=@EMP_ID and MONTH(Month_End_Date) = @month and year(Month_End_Date) = @Year
				--End by ronakk 16022023  
			


		--		--		--commented by mansi 04-10-22 start
		--		 IF OBJECT_ID(N'tempdb..#TmpArrear_Amount') IS NOT NULL
		--			BEGIN
		--			DROP TABLE #TmpArrear_Amount
		--			END
		--				 --added 080422 end

		--		 Select  @Emp_ID as Emp_ID,@Cmp_ID as Cmp_ID,0 as Transaction_ID,@month as Month,@Year as Year,MAD.AD_ID,AD_NAME,
		--			 mad.M_AD_Flag,(AD_SORT_NAME+'_Arrear')as AD_SORT_NAME,Isnull(SUM(M_AD_Amount),0)as M_Arrear_Amt  
		--				,'' as Value_String,0 as INCOME_TAX_ID,AD_DEF_ID
		--				into #TmpArrear_Amount 
		--				From t0210_monthly_ad_detail MAD WITH (NOLOCK) inner join
		--							T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK) on MSS.S_Sal_Tran_ID = MAD.S_Sal_Tran_ID inner join -- Added by Nilesh Patel on 11-08-2017 For Salary Settelment ID 
		--							--MAD.Sal_Tran_ID=MSS.Sal_Tran_ID inner join Comment by nilesh patel on 11-08-2017 For get issue when Same month Settelment in twice
		--							T0050_AD_MASTER WITH (NOLOCK) on MAD.Ad_Id = T0050_AD_MASTER.Ad_ID
		--							and MAD.Cmp_ID = T0050_AD_MASTER.Cmp_Id
		--							and MAD.Emp_ID  = @Emp_ID
		--						where MAD.Cmp_ID = @Cmp_ID and month(MSS.S_Eff_Date) =  MONTH(@To_Date) and Year(MSS.S_Eff_Date) = YEAR(@To_Date)
		--							and (isnull(mad.M_AD_NOT_EFFECT_SALARY,0) = 0 Or  (M_AD_NOT_EFFECT_SALARY = 1 and MAD.reimShow= 1))
		--							and Ad_Active = 1 
		--							--and AD_Flag = 'D' --Comment B'cos Sett Amount display in Arear amount column - AIA - Ankit  03062016
		--							And Sal_Type = 1 and Isnull(MSS.Effect_On_Salary,0) = 1	--Condition Added by Nilesh (If not effect in salary option is selected during settlement then the component should not be displayed in payslip) 17-07-2017
		--						Group By AD_SORT_NAME,MAD.AD_ID,MSS.Emp_ID,mad.M_AD_Flag,AD_NAME,AD_DEF_ID
             
				
		--insert into #TmpArrear_Amount(Emp_ID,Cmp_ID,Transaction_ID,Month,Year,AD_ID,AD_NAME,M_AD_Flag,AD_SORT_NAME,M_Arrear_Amt,Value_String,INCOME_TAX_ID,AD_DEF_ID) 
		--								                 values(@Emp_ID,@Cmp_ID,0,@month,@Year,0,'','I','Basic+_Arrear'
		--												 ,ISNULL(@Ar_Salary_Amt_Basic,0)
		--												 ,'',0,0)		  
		--		--	--commented by mansi 04-10-22 end

			 SELECT @tmp_PF_wages=SUM(M_AD_Calculated_Amount) FROM 
			--SELECT Emp_ID,AD_NAME,SUM(M_AD_Calculated_Amount)AS M_AD_Calculated_Amount FROM 
			   (SELECT  AD.AD_DEF_ID,Emp_ID,Ad.Cmp_ID,Ad.AD_ID,ad.AD_NAME,M_AD_Flag,ad.AD_SORT_NAME,MAD.M_AD_Calculated_Amount,mad.M_AD_Amount
					FROM	T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK)
							INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON MAD.AD_ID = AD.AD_ID
					WHERE	MAD.SAL_TRAN_ID = @CUR_SAL_TRAN_ID AND AD.AD_DEF_ID = 2 and MAD.M_AD_Amount > 0
					
					--union 
					--Select  AD_DEF_ID,mad.Emp_ID,mad.Cmp_ID,MAD.AD_ID,AD_NAME,mad.M_AD_Flag,AD_SORT_NAME,M_AD_Calculated_Amount, Isnull(SUM(M_AD_Amount),0)as M_AD_Amount 
					--From t0210_monthly_ad_detail MAD WITH (NOLOCK) inner join
					--		T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK) on MSS.S_Sal_Tran_ID = MAD.S_Sal_Tran_ID inner join -- Added by Nilesh Patel on 11-08-2017 For Salary Settelment ID 
					--		--MAD.Sal_Tran_ID=MSS.Sal_Tran_ID inner join Comment by nilesh patel on 11-08-2017 For get issue when Same month Settelment in twice
					--		T0050_AD_MASTER WITH (NOLOCK) on MAD.Ad_Id = T0050_AD_MASTER.Ad_ID
					--		and MAD.Cmp_ID = T0050_AD_MASTER.Cmp_Id
					--		and MAD.Emp_ID  = @EMP_ID
					--	where MAD.Cmp_ID = @CMP_ID and month(MSS.S_Eff_Date) =  MONTH(@TO_DATE) and Year(MSS.S_Eff_Date) = YEAR(@TO_DATE)
					--		and (isnull(mad.M_AD_NOT_EFFECT_SALARY,0) = 0 Or  (M_AD_NOT_EFFECT_SALARY = 1 and MAD.reimShow= 1))
					--		and Ad_Active = 1 and AD_DEF_ID=2
					--		--and AD_Flag = 'D' --Comment B'cos Sett Amount display in Arear amount column - AIA - Ankit  03062016
					--		And Sal_Type = 1 and Isnull(MSS.Effect_On_Salary,0) = 1	--Condition Added by Nilesh (If not effect in salary option is selected during settlement then the component should not be displayed in payslip) 17-07-2017
					--	Group By MAD.AD_ID,MSS.Emp_ID,mad.M_AD_Flag,AD_NAME,AD_DEF_ID ,mad.Emp_ID,mad.Cmp_ID,AD_SORT_NAME,M_AD_Calculated_Amount
						)AS t GROUP BY Emp_ID,AD_NAME

						
				
					select @tmp_PF_wages_arrear=isnull(sum(Arrear_Wages),0) from #EMP_SALARY	Where EMP_ID = @EMP_ID
					
					


			    set @tmp_ESI_wages =0 --Added by ronakk 16022023
				SELECT @tmp_ESI_wages=SUM(M_AD_Calculated_Amount) FROM 
				--SELECT Emp_ID,AD_NAME,SUM(M_AD_Calculated_Amount)AS M_AD_Calculated_Amount FROM 
			   (SELECT  AD.AD_DEF_ID,Emp_ID,Ad.Cmp_ID,Ad.AD_ID,ad.AD_NAME,M_AD_Flag,ad.AD_SORT_NAME,MAD.M_AD_Calculated_Amount,mad.M_AD_Amount
				FROM	T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK)
						INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON MAD.AD_ID = AD.AD_ID
				WHERE	MAD.SAL_TRAN_ID = @CUR_SAL_TRAN_ID AND AD.AD_DEF_ID = 3 and MAD.M_AD_Amount > 0
					--union 
					--Select  AD_DEF_ID,mad.Emp_ID,mad.Cmp_ID,MAD.AD_ID,AD_NAME,mad.M_AD_Flag,AD_SORT_NAME,M_AD_Calculated_Amount, Isnull(SUM(M_AD_Amount),0)as M_AD_Amount 
					--From t0210_monthly_ad_detail MAD WITH (NOLOCK) inner join
					--		T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK) on MSS.S_Sal_Tran_ID = MAD.S_Sal_Tran_ID inner join -- Added by Nilesh Patel on 11-08-2017 For Salary Settelment ID 
					--		--MAD.Sal_Tran_ID=MSS.Sal_Tran_ID inner join Comment by nilesh patel on 11-08-2017 For get issue when Same month Settelment in twice
					--		T0050_AD_MASTER WITH (NOLOCK) on MAD.Ad_Id = T0050_AD_MASTER.Ad_ID
					--		and MAD.Cmp_ID = T0050_AD_MASTER.Cmp_Id
					--		and MAD.Emp_ID  = @EMP_ID
					--	where MAD.Cmp_ID = @CMP_ID and month(MSS.S_Eff_Date) =  MONTH(@TO_DATE) and Year(MSS.S_Eff_Date) = YEAR(@TO_DATE)
					--		and (isnull(mad.M_AD_NOT_EFFECT_SALARY,0) = 0 Or  (M_AD_NOT_EFFECT_SALARY = 1 and MAD.reimShow= 1))
					--		and Ad_Active = 1 and AD_DEF_ID=3
					--		--and AD_Flag = 'D' --Comment B'cos Sett Amount display in Arear amount column - AIA - Ankit  03062016
					--		And Sal_Type = 1 and Isnull(MSS.Effect_On_Salary,0) = 1	--Condition Added by Nilesh (If not effect in salary option is selected during settlement then the component should not be displayed in payslip) 17-07-2017
					--	Group By MAD.AD_ID,MSS.Emp_ID,mad.M_AD_Flag,AD_NAME,AD_DEF_ID ,mad.Emp_ID,mad.Cmp_ID,AD_SORT_NAME,M_AD_Calculated_Amount
				)AS t GROUP BY Emp_ID,AD_NAME
									
							
		--added 080422 start
				 IF OBJECT_ID(N'tempdb..#FinalTmpAmt') IS NOT NULL
					BEGIN
					DROP TABLE #FinalTmpAmt
					END
						 --added 080422 end

					select * into #FinalTmpAmt from
					(select * from #TmpAmount
					union 
					select * from #TmpArrear_Amount
					union --added on 04-10-22 mansi
					select * from #tmp_Basic_Arrear --added on 04-10-22 mansi
					)as T
					
					--Select * From #TmpAmount
					--Select * From #TmpArrear_Amount
					--RETURN
					--
					
						
						select @Total_Earning_Amt=sum(M_Arrear_Amt) from #FinalTmpAmt where M_AD_Flag='I' and Emp_ID=@EMP_ID

						select @Total_Deduction_Amt=sum(M_Arrear_Amt) from #FinalTmpAmt where M_AD_Flag='D' and Emp_ID=@EMP_ID
						--print @Total_Earning_Amt
						--print @Total_Deduction_Amt
						--set @CTC=@Total_Earning_Amt-@Total_Deduction_Amt
						--print @CTC
		   --added by mansi end
		  --Select @Total_Earning_Amt, @EMP_ID

			INSERT	INTO #EMP_DETAILS(EMP_ID,SAL_TRAN_ID,UANNO,GROSS_SALARY,GROSS_DEDUCTION,CTC,Sal_Cal_Day,ESIC_NO)
			SELECT	@EMP_ID ,@CUR_SAL_TRAN_ID,@CUR_UANNO,GROSS_SALARY,TOTAL_DEDU_AMOUNT,NET_AMOUNT,Sal_Cal_Days,@CUR_ESIC_NO
			FROM	DBO.T0200_MONTHLY_SALARY WITH (NOLOCK) 
			WHERE	EMP_ID = @EMP_ID AND MONTH(MONTH_END_DATE) = @MONTH AND YEAR(MONTH_END_DATE) = @YEAR 

			

			--UPDATE #EMP_DETAILS SET GROSS_SALARY=@Total_Earning_Amt WHERE EMP_ID = @EMP_ID AND SAL_TRAN_ID=@CUR_SAL_TRAN_ID --Deepal commented the line which change the amount of gross_salary to @Total_Earning_Amt on line no 537 and OT amount was not getting  DT :- 16122022 Redmine ticket - 19964 
			UPDATE #EMP_DETAILS SET GROSS_DEDUCTION=@Total_Deduction_Amt WHERE EMP_ID = @EMP_ID AND SAL_TRAN_ID=@CUR_SAL_TRAN_ID
							
			UPDATE	#EMP_DETAILS 
			SET		PF_WAGES = ISNULL(QRY.M_AD_Calculated_Amount,0) 
			FROM	(
					SELECT  MAD.M_AD_Calculated_Amount
					FROM	T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK)
							INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON MAD.AD_ID = AD.AD_ID
					WHERE	MAD.SAL_TRAN_ID = @CUR_SAL_TRAN_ID AND AD.AD_DEF_ID = 2 and MAD.M_AD_Amount > 0								
					)QRY
			WHERE 	#EMP_DETAILS.SAL_TRAN_ID = @CUR_SAL_TRAN_ID					
			
	
	
			UPDATE	#EMP_DETAILS 
			SET		ESI_WAGES = ISNULL(QRY.M_AD_Calculated_Amount,0) 
			FROM	(
					SELECT  MAD.M_AD_Calculated_Amount 
					FROM	T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK)
							INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON MAD.AD_ID = AD.AD_ID
					WHERE	MAD.SAL_TRAN_ID = @CUR_SAL_TRAN_ID AND AD.AD_DEF_ID = 3 and MAD.M_AD_Amount > 0
					)QRY					
			WHERE 	#EMP_DETAILS.SAL_TRAN_ID = @CUR_SAL_TRAN_ID
				
			--SS	
			--added by mansi start	
				UPDATE	#EMP_DETAILS set GROSS_SALARY=GROSS_SALARY,GROSS_DEDUCTION=GROSS_DEDUCTION
				,PF_WAGES=@tmp_PF_wages,ESI_WAGES=@tmp_ESI_wages,PF_WAGES_Arrear=@tmp_PF_wages_arrear
				where EMP_ID = @EMP_ID AND @CMP_ID = @CMP_ID
			--added by mansi end

			
			

			INSERT	INTO #WORKING_DETAILS(EMP_ID,SAL_TRAN_ID,PARA_NAME,DAYS,PARA_TYPE)
			SELECT	@EMP_ID ,@CUR_SAL_TRAN_ID,'P',PRESENT_DAYS,1
			FROM	DBO.T0200_MONTHLY_SALARY WITH (NOLOCK)
			WHERE	EMP_ID = @EMP_ID AND MONTH(MONTH_END_DATE) = @MONTH AND YEAR(MONTH_END_DATE) = @YEAR  
			
			UNION ALL
			
			SELECT	@EMP_ID ,@CUR_SAL_TRAN_ID,'WO',WEEKOFF_DAYS,1
			FROM	DBO.T0200_MONTHLY_SALARY WITH (NOLOCK)
			WHERE	EMP_ID = @EMP_ID AND MONTH(MONTH_END_DATE) = @MONTH AND YEAR(MONTH_END_DATE) = @YEAR 
			
			UNION ALL 
			
			SELECT	@EMP_ID ,@CUR_SAL_TRAN_ID,'HO',Holiday_Days,1
			FROM	DBO.T0200_MONTHLY_SALARY WITH (NOLOCK)
			WHERE	EMP_ID = @EMP_ID AND MONTH(MONTH_END_DATE) = @MONTH AND YEAR(MONTH_END_DATE) = @YEAR  
			
			UNION ALL
			
			SELECT	@EMP_ID ,@CUR_SAL_TRAN_ID,'AB',Absent_Days,1
			FROM	DBO.T0200_MONTHLY_SALARY WITH (NOLOCK)
			WHERE	EMP_ID = @EMP_ID AND MONTH(MONTH_END_DATE) = @MONTH AND YEAR(MONTH_END_DATE) = @YEAR  

			UNION ALL
			
			SELECT	@EMP_ID ,@CUR_SAL_TRAN_ID,'PD',Sal_Cal_Days,1
			FROM	DBO.T0200_MONTHLY_SALARY WITH (NOLOCK)
			WHERE	EMP_ID = @EMP_ID AND MONTH(MONTH_END_DATE) = @MONTH AND YEAR(MONTH_END_DATE) = @YEAR  	

		
			UNION ALL
			
			SELECT	@EMP_ID ,@CUR_SAL_TRAN_ID,
			---'OT Hrs.', Isnull(M_OT_Hours,0) + Isnull(M_HO_OT_Hours,0) + Isnull(M_WO_OT_Hours,0) ,1
			'OT Hrs.', 
			case when is_Monthly_Salary = 1 then Isnull(OT_Hours,0)  else 0  end +    ---- Add by Jignesh Patel 09-08-2021
			Isnull(M_OT_Hours,0)+ Isnull(M_HO_OT_Hours,0) + Isnull(M_WO_OT_Hours,0) ,1

			FROM	DBO.T0200_MONTHLY_SALARY WITH (NOLOCK)
			WHERE	EMP_ID = @EMP_ID AND MONTH(MONTH_END_DATE) = @MONTH AND YEAR(MONTH_END_DATE) = @YEAR  
				
				
			
			--commented by Krushna for daily wages employee basic comes wrong 27-12-2018 
			----SALARY STRUCTURE 0712016
			--INSERT	INTO #RATEOFWAGES(EMP_ID,SAL_TRAN_ID,ALLOWANCE_NAME,RATE_TYPE,ALLOWANCE_AMOUNT,ALLOWANCE_TYPE)
			--SELECT	MS.Emp_ID,MS.Sal_Tran_ID,'Basic','AMT',MS.Basic_Salary,'I' from T0200_MONTHLY_SALARY MS 
			--WHERE	EMP_ID = @EMP_ID AND MONTH(MONTH_END_DATE) = @MONTH AND YEAR(MONTH_END_DATE) = @YEAR
			
			INSERT	INTO #RATEOFWAGES(EMP_ID,SAL_TRAN_ID,ALLOWANCE_NAME,RATE_TYPE,ALLOWANCE_AMOUNT,ALLOWANCE_TYPE)
			SELECT	MS.Emp_ID,MS.Sal_Tran_ID,'Basic','AMT',I.Basic_Salary,'I'  
			from	T0200_MONTHLY_SALARY MS WITH (NOLOCK)
					INNER JOIN T0095_INCREMENT I WITH (NOLOCK) on MS.Increment_ID = I.Increment_ID
					INNER JOIN (
									SELECT	MAX(I1.INCREMENT_ID) AS INCREMENT_ID,I1.EMP_ID 
									FROM	T0095_INCREMENT I1  WITH (NOLOCK) 					
											INNER JOIN (
															SELECT	max(Increment_Effective_Date) as For_Date,Emp_ID
															from	T0095_INCREMENT WITH (NOLOCK)
															where	CMP_ID = @CMP_ID AND EMP_ID = @EMP_ID AND Increment_Effective_Date <= @TO_dATE
															and Increment_Type <> 'Transfer'
															GROUP BY EMP_ID		
														)INN_QRY ON INN_QRY.For_Date = I1.Increment_Effective_Date AND INN_QRY.Emp_ID = I1.Emp_ID
									GROUP BY I1.EMP_ID 
								)INN_QRY1 ON I.Emp_ID = INN_QRY1.Emp_ID AND I.Increment_ID = INN_QRY1.INCREMENT_ID
			WHERE	MS.EMP_ID = @EMP_ID AND MONTH(MONTH_END_DATE) = @MONTH AND YEAR(MONTH_END_DATE) = @YEAR  
				
			UNION
			
			SELECT	EE.EMP_ID,@CUR_SAL_TRAN_ID,AM.AD_SORT_NAME,E_AD_MODE, E_AD_AMOUNT ,E_AD_FLAG 
			FROM	T0100_EMP_EARN_DEDUCTION EE WITH (NOLOCK)
					INNER JOIN (
								SELECT	MAX(INCREMENT_ID) AS INCREMENT_ID,EED.EMP_ID 
								FROM	T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK)  
										INNER JOIN(
													SELECT	MAX(FOR_DATE)AS FOR_DATE,EED.EMP_ID 
													FROM	T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK)
													WHERE	CMP_ID = @CMP_ID AND EED.EMP_ID = @EMP_ID AND FOR_DATE <= @TO_dATE		
													GROUP BY EED.EMP_ID,EED.FOR_DATE
												  ) INN_QRY ON INN_QRY.FOR_DATE = EED.FOR_DATE AND  INN_QRY.EMP_ID = EED.EMP_ID
								WHERE	CMP_ID = @CMP_ID AND EED.EMP_ID = @EMP_ID AND EED.FOR_DATE <= @TO_dATE	
								GROUP BY EED.EMP_ID
								)QRY ON QRY.EMP_ID = EE.EMP_ID AND QRY.INCREMENT_ID =EE.INCREMENT_ID
					INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AM.AD_ID = EE.AD_ID
			WHERE 	EE.E_AD_AMOUNT > 0	
					AND (CASE WHEN @SHOW_HIDDEN_ALLOWANCE = 0 AND am.Hide_In_Reports = 1  THEN 0 ELSE 1 END) = 1 --Added by Jaina 24-12-2016
					AND AM.AD_NOT_EFFECT_SALARY = 0 --added by Krushna 28-12-2018
				
	
			INSERT	INTO #WORKING_DETAILS(EMP_ID,SAL_TRAN_ID,PARA_NAME,DAYS,PARA_TYPE)
			SELECT	@EMP_ID,@CUR_SAL_TRAN_ID,LM.LEAVE_CODE,QRY.LEAVE_USED,2 
			FROM	T0040_LEAVE_MASTER LM WITH (NOLOCK)
					INNER JOIN (SELECT	EMP_ID,LEAVE_ID, SUM((ISNULL(LEAVE_USED,0) + ISNULL(COMPOFF_USED,0))) AS LEAVE_USED
								FROM	T0140_LEAVE_TRANSACTION LT	WITH (NOLOCK)
								WHERE	(FOR_DATE BETWEEN @FROM_DATE AND @TO_DATE) AND EMP_ID = @EMP_ID AND (ISNULL(LEAVE_USED,0) + ISNULL(COMPOFF_USED,0)) > 0
								GROUP BY LT.EMP_ID,LT.LEAVE_ID
								)QRY ON QRY.EMP_ID = @EMP_ID AND QRY.LEAVE_ID = LM.LEAVE_ID


			
			
			FETCH NEXT FROM CUR_EMP INTO @EMP_ID ,@CUR_SAL_TRAN_ID,@CUR_UANNO,@CUR_ESIC_NO
		END
	CLOSE CUR_EMP
	DEALLOCATE CUR_EMP

	--Deepal  Revised allowance Updated 24102024


	UPDATE R1
	set R1.ALLOWANCE_AMOUNT = A.E_AD_AMOUNT
	from #RATEOFWAGES R1 
	inner join (
		select Er.E_AD_AMOUNT,R.ALLOWANCE_NAME,R.EMP_ID from #RATEOFWAGES R inner join  T0050_AD_MASTER A on R.ALLOWANCE_NAME = A.AD_SORT_NAME
		inner Join T0110_EMP_EARN_DEDUCTION_REVISED ER on R.EMP_ID = ER.EMP_ID and ER.AD_ID = A.AD_ID
	) a on r1.ALLOWANCE_NAME = a.ALLOWANCE_NAME and R1.EMP_ID = a.Emp_Id
	--Deepal  Revised allowance Updated 24102024

	----------- @Dept_Summary Add By Jignesh Patel 30-Sep-2021----------- For Chiripal
	If @Summary_Option = 0
	Begin
		SELECT * FROM #RATEOFWAGES
		SELECT * FROM #WORKING_DETAILS
		SELECT  * FROM #EMP_DETAILS	
		select Para_Name,count(Para_name) from  #WORKING_DETAILS Group by Para_name
	END
									
	If @Summary_Option > 0
	Begin
		
				SET @Summary_Option =@Summary_Option-1
		
				Declare @sSql as Varchar(max)
				Declare @sSqlSummaryOn as Varchar(5000)

				Select @sSqlSummaryOn = Case When @Summary_Option= 0 then 'Grd_ID' 
										Else Case When @Summary_Option= 1 then 'Type_ID' 
										Else Case When @Summary_Option= 2 then 'Dept_ID' 
										Else Case When @Summary_Option= 3 then 'Desig_Id' 
										Else Case When @Summary_Option= 4 then 'Branch_ID' 
										Else Case When @Summary_Option= 5 then 'Vertical_ID' 
										Else Case When @Summary_Option= 6 then 'SubVertical_ID' 
										Else Case When @Summary_Option= 7 then 'subBranch_ID' 
										end end End end end End end end


			   SET @sSql = 'SELECT 
				--RW.*,
				isnull(' + @sSqlSummaryOn +',0)  as EMP_ID, isnull( '+ @sSqlSummaryOn +',0) as SAL_TRAN_ID ,ALLOWANCE_NAME,RATE_TYPE,Sum(ALLOWANCE_AMOUNT) as ALLOWANCE_AMOUNT,ALLOWANCE_TYPE
				FROM #RATEOFWAGES AS RW
				 Inner Join (
				 SELECT EC.EMP_ID , I.' + @sSqlSummaryOn +'  from #EMP_CONS as EC INNER JOIN T0095_INCREMENT as I
				 On I.Increment_ID = EC.INCREMENT_ID
				) as IC On RW.EMP_ID = IC.EMP_ID 
				GROUP BY '+ @sSqlSummaryOn +' ,ALLOWANCE_NAME,RATE_TYPE,ALLOWANCE_TYPE'

				exec(@sSql)
	
				SET @sSql= ''
	
				SET @sSql= 'SELECT  
				---WD.*,IC.Dept_ID 
				isnull(' + @sSqlSummaryOn +',0) as EMP_ID, isnull(' + @sSqlSummaryOn +',0) as SAL_TRAN_ID,PARA_NAME,Sum(DAYS) as Days,PARA_TYPE	
				FROM #WORKING_DETAILS as WD
				Inner Join (
				 SELECT EC.EMP_ID , I.' + @sSqlSummaryOn +'  from #EMP_CONS as EC INNER JOIN T0095_INCREMENT as I
				 On I.Increment_ID = EC.INCREMENT_ID
				) as IC On WD.EMP_ID = IC.EMP_ID 
				Group By  ' + @sSqlSummaryOn +',PARA_NAME,PARA_TYPE'

	
				exec(@sSql)
	
				SET @sSql= ''
	
				SET @sSql= 'SELECT 
				---ED.*,IC.Dept_ID 
				isnull(' + @sSqlSummaryOn +',0) AS EMP_ID,isnull(' + @sSqlSummaryOn +',0) AS SAL_TRAN_ID,'''' AS UANNO,SUM(GROSS_SALARY) AS GROSS_SALARY,SUM(GROSS_DEDUCTION) AS GROSS_DEDUCTION
				,SUM(PF_WAGES) as PF_WAGES,	SUM(ESI_WAGES) as ESI_WAGES,SUM(CTC) AS CTC,SUM(Sal_Cal_Day) as Sal_Cal_Day,''''as ESIC_NO	
				FROM #EMP_DETAILS as ED
				Inner Join (
				 SELECT EC.EMP_ID , I.' + @sSqlSummaryOn +'  from #EMP_CONS as EC INNER JOIN T0095_INCREMENT as I
				 On I.Increment_ID = EC.INCREMENT_ID
				) as IC On ED.EMP_ID = IC.EMP_ID 
				Group By ' + @sSqlSummaryOn +' '
	
	
				exec(@sSql)
				SET @sSql= ''

	END

	

END


