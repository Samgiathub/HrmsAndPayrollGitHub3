---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[CALCULATE_AD_AMOUNT_Formula_WISE_Salary]

	@Cmp_ID	NUMERIC ,
	@EMP_ID NUMERIC ,	
	@AD_ID Numeric(18,0),
	@For_date Datetime,
	@Earning_Gross numeric(18,2),
	@Salary_Cal_Day numeric(18,2),
	@Out_Of_Days numeric(18,2),	
	@Formula_amount NUMERIC(18,2)OUTPUT,
	@Earning_Basic numeric(18,2) = 0,
	@Present_Days numeric(18,2) = 0,
	@arrear_Day Numeric(18,2)=0,
	@absent_days Numeric(18,2)=0,--Added by nilesh patel on 25112015
	@Salary_Settlement_Flag Numeric(5,0) = 0,
	@PASSED_FROM Varchar(50) = '',
	@PASSED_AMOUNT numeric(18,2) = 0,
	@To_Date Datetime = Null,	
	@Calculate_Arrear   TinyInt = 1, -- Added by Rajput 06032018
	@Night_Shift_Count Numeric = 0 -- Added by nilesh on 01082018 -- For Enpay Client -- Nightshift Count Calculation 
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	BEGIN Try
	
		Declare @Ad_Formula as nvarchar(Max)
		Declare @Out_Formula as nvarchar(Max)
		Declare @Actual_OutPut as nvarchar(Max)
		Declare @AD_Rounding  INT	
		DECLARE @Salary_Exists as TINYINT,@settingval as numeric = 0
		SET @Salary_Exists = 0
		Select @settingval = Setting_Value from T0040_SETTING where Cmp_ID = @Cmp_ID and Setting_Name = 'Present On Holiday And Weekoff Calculate On Shift Master Slab Wise.'
		
		select @Ad_Formula = Actual_AD_Formula from T0040_AD_Formula_Setting WITH (NOLOCK) where Cmp_Id=@cmp_Id and AD_ID=@AD_ID

		if Isnull(@Ad_Formula,'') = ''
			RETURN
		
		Declare @From_Slab	Numeric(27,0)
		Declare @To_Slab	Numeric(27,0)
		Declare @AD_Amt		Numeric(27,0)
		Declare @Calc_Type	Varchar(20)
		Declare @Prorata_Basic_Sal	Numeric(18,2)
		Declare @Prorata_Gross_Sal	Numeric(18,2)
		Declare @Prorata_CTC_Sal	Numeric(18,2)	
		Declare @Salary_Depens_On_Prodcution Numeric(18,2)
		Declare @Absent_Day_Calc Numeric(18,2)
		Declare @Production_Based TINYINT
		Declare @GradeWise_Salary TINYINT
		
		Set @From_Slab = 0
		Set @To_Slab = 0
		Set @AD_Amt = 0 
		Set @Calc_Type = ''
		Set @Prorata_Basic_Sal = 0
		Set @Prorata_Gross_Sal = 0
		Set @Prorata_CTC_Sal = 0
		Set @Absent_Day_Calc = 0
		SET @AD_Rounding = 0
		SET @Production_Based = 0
		SET @GradeWise_Salary = 0
		
		-- Ankit 18052016 --[ AIA Client ] 
		DECLARE @Production_Allowance VARCHAR(50)
		DECLARE @AD_DEF_ID NUMERIC
		SET @AD_DEF_ID = 0
		SET @Production_Allowance = ''
		
		SELECT @AD_DEF_ID = AD_DEF_ID , @Production_Allowance = AD_NAME FROM T0050_AD_MASTER WITH (NOLOCK) WHERE AD_ID = @Ad_ID AND Cmp_ID = @Cmp_ID
		
		----
		
		Select @Absent_Day_Calc  = ISNULL(Setting_Value,0) From T0040_SETTING WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Setting_Name='Show absent days in salary slip when calaculate salary on fix day'
		Select @Production_Based = ISNULL(Setting_Value,0) From T0040_SETTING WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Setting_Name='Calculate Salary Base on Production Details'
		Select @GradeWise_Salary = ISNULL(Setting_Value,0) From T0040_SETTING WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Setting_Name='Show Gradewise Salary Textbox in Grade Master'

		DECLARE @Gr_Days as numeric(18,2)
		DECLARE @Gr_Salary_amount as  numeric(18,2)
		DECLARE @Xdays as  numeric(18,2)
		Declare @Grd_Id as numeric
		
		SET @Gr_Days =0
		SET @Gr_Salary_amount =0	
		SET @Xdays = 0
		SET @Grd_Id = 0
		
		--DECLARE @to_date AS DATETIME   
		If @To_Date Is NULL
			SET @to_date= DATEADD(d,@Out_Of_Days - 1,@for_date) --Added By Ramiz on 27/05/2016 as per discussion with Hardik bhai
		
		---Added by Hardik 04/07/2016
		DECLARE @From_Date_Pre_Month AS DATETIME
		DECLARE @To_Date_Pre_Month	AS DATETIME
		SET @From_Date_Pre_Month = NULL
		SET @To_Date_Pre_Month = NULL


		   
	DECLARE @Required_Execution BIT;
	SET @Required_Execution = 0;
 
	
		IF EXISTS(SELECT 1 FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND MONTH(Month_End_Date)=MONTH(DATEADD(MONTH,-1,@to_date)) AND YEAR(Month_End_Date)=YEAR(DATEADD(MONTH,-1,@to_date)))
			BEGIN
				SET @Salary_Exists = 1
				
				SELECT @From_Date_Pre_Month = Month_St_Date, @To_Date_Pre_Month = Month_End_Date
				FROM T0200_MONTHLY_SALARY WITH (NOLOCK)
				WHERE Emp_ID = @Emp_ID AND MONTH(Month_End_Date)=MONTH(DATEADD(MONTH,-1,@to_date)) AND YEAR(Month_End_Date)=YEAR(DATEADD(MONTH,-1,@to_date))
			END			
		
		IF @From_Date_Pre_Month IS NULL
			SET @From_Date_Pre_Month = @for_date
		IF @To_Date_Pre_Month IS NULL
			SET @To_Date_Pre_Month = @to_date
		------
		
			---Added by Rohit On 27032015
		DECLARE @NightHaltDays as numeric(18,2)
		SET @NightHaltDays = 0
		select @NightHaltDays = sum(isnull(t2.Approve_Days,0)) 
		from T0120_NIGHT_HALT_APPROVAL T2 WITH (NOLOCK)
		where T2.Emp_ID = @EMP_ID and Eff_Month = MONTH(@For_date) and Eff_Year = year(@For_date) and Is_Effect_Sal = 1   
	-- Ended by rohit on 27032015
		
		--Commented by hardik 17/08/2016 As Kitch client has this case-- if Basic and Gross are same and only allocated New allowance then below condition will not work.
		--if @Salary_Settlement_Flag <> 1 -- Added by nilesh patel on 25112015 For Calculate Diff Basic Salary at time of Salary Settlemnet
			Begin
				select @Prorata_Basic_Sal = Basic_Salary,@Prorata_Gross_Sal= Gross_Salary,@Prorata_CTC_Sal = CTC,@Grd_Id=I.Grd_ID
				From T0095_Increment I WITH (NOLOCK) inner join     
					 ( select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK)   --Changed by Hardik 10/09/2014 for Same Date Increment  
					 where Increment_Effective_date <= @to_date  and Emp_Id=@EMP_ID 
					 and Cmp_ID = @Cmp_ID    
					 group by emp_ID) Qry on    
					 I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id    
				Where I.Emp_ID = @Emp_ID	
			End 
		--Else
		--	Begin
		--		;with cte aS
		--		(
		--			SELECT ROW_NUMBER() over(ORDER BY Increment_ID DESC) as Row_id,Emp_ID ,Basic_Salary,Increment_ID,Gross_Salary,CTC,Grd_ID From T0095_Increment 
		--			Where Increment_Effective_date <= @to_date  and Emp_Id=@EMP_ID and Cmp_ID = @Cmp_ID and Increment_Type <> 'Transfer'  
		--		)
		--		Select @Prorata_Basic_Sal = (t2.Basic_salary - t1.Basic_salary), 
		--			   @Prorata_Gross_Sal = (t2.Gross_Salary - t1.Gross_Salary),
		--			   @Prorata_CTC_Sal	  = (t2.CTC - t1.CTC),	
		--			   @Grd_Id = t2.Grd_ID	
		--		FROM cte t1 LEFT OUTER JOIN cte t2 
		--		 on t1.Row_id = t2.Row_id + 1 AND t1.Emp_ID = t2.Emp_ID
		--		WHERE isnull(t2.Row_id,0) <> 0 and t1.Row_id <=2
				
		--	End 
			
		
	  
	 /***** ADDED BY RAMIZ ON 08/05/2017**********************************
	 
		THIS PORTION IS ONLY EXECUTED FOR SAMARTH. . .PLZ DO NOT CHANGE THIS.		
		
		REASON:- THE EARNING GROSS CHANGES EVERY TIME , WHENEVER NEW ALLOWANCE IS ADDED IN GROSS , SO HERE I HAVE
				 ADDED A FORMULA FOR BOTH EARNED AND PRORATA GROSS. 
	 *****/
	 
	  IF ISNULL(@PRODUCTION_BASED,0) = 1
		  BEGIN
			  SELECT @SALARY_DEPENS_ON_PRODCUTION = ISNULL(SALARY_DEPENDS_ON_PRODUCTION ,0) FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE EMP_ID = @EMP_ID  AND CMP_ID = @CMP_ID 
			
				IF  ISNULL(@SALARY_DEPENS_ON_PRODCUTION,0) = 1
				   BEGIN
						SELECT @EARNING_GROSS = ISNULL(GROSS_AMOUNT,0) FROM T0050_PRODUCTION_DETAILS_IMPORT WITH (NOLOCK)	--AS CLIENT WILL UPLOAD EARNING GROSS ONLY	
						WHERE EMPLOYEE_ID = @EMP_ID AND CMP_ID = @CMP_ID AND PRODUCTION_MONTH = MONTH(@FOR_DATE) AND PRODUCTION_YEAR = YEAR(@FOR_DATE)

						IF ISNULL(@PRORATA_BASIC_SAL,0) = 0 
							BEGIN
		  						 DECLARE @BASIC_PERCENTAGE AS NUMERIC(18,2)
								 DECLARE @BASIC_CALC_ON AS VARCHAR(50)
								 
								 SELECT @BASIC_PERCENTAGE = BASIC_PERCENTAGE, @BASIC_CALC_ON = BASIC_CALC_ON FROM T0040_GRADE_MASTER WITH (NOLOCK) WHERE GRD_ID=@GRD_ID
								
								 IF @BASIC_PERCENTAGE > 0 AND @EARNING_GROSS > 0 AND @BASIC_CALC_ON = 'Gross' 
								  BEGIN
									SET @PRORATA_BASIC_SAL = @EARNING_GROSS * @BASIC_PERCENTAGE / 100
									SET @EARNING_BASIC = ROUND(@PRORATA_BASIC_SAL * @SALARY_CAL_DAY/@OUT_OF_DAYS,0)
								  END
							 END
				   END
				ELSE
				   BEGIN	
					 SET  @EARNING_GROSS = ROUND(@PRORATA_GROSS_SAL * @SALARY_CAL_DAY/@OUT_OF_DAYS,0) --IF SALARY IS NOT DEPENDEDNT ON PRODUCTION THEN IT WILL TAKE GROSS SALARY FROM MASTER AND THE IT WILL BE USED IN FORMULA
				   END
		   END
		/************ ENDED BY RAMIZ ON 08/05/2017 **************/
		
		/* This is Mafatlals Code of Recess Allowance only applicable for Asst. Tackler. Added By Ramiz on 10/04/2018. */ 
		 IF ISNULL(@GradeWise_Salary,0) = 1
			BEGIN
				IF OBJECT_ID('tempdb..#EFFICIENCY_SALARY') IS NOT NULL
					SELECT @Xdays = ISNULL(SUM(Days_Count),0) FROM #EFFICIENCY_SALARY WHERE WORKED_IN = 'AT'
				
				DECLARE @Worked_in_Master_Grd as numeric
				IF OBJECT_ID('tempdb..#DA_Allowance') IS NOT NULL
					SELECT @Worked_in_Master_Grd = ISNULL(SUM(Grd_Count),0) FROM #DA_Allowance WHERE Is_Master_Grd = 1
			END
		 ELSE
			BEGIN
				SELECT @Xdays = isnull(Days,0) from T0195_allowance_days WITH (NOLOCK) where ad_id = @ad_id and cmp_id = @Cmp_ID and month = month(@For_date) and year = year(@for_date)	---added by hasmukh 26062014
			END
		
		--SELECT @Ad_Formula = Actual_AD_Formula from T0040_AD_Formula_Setting WITH (NOLOCK) where Cmp_Id=@cmp_Id and AD_ID=@AD_ID

		
		CREATE TABLE #Tbl_Formula
		(
			Formula_Id numeric,
			Formula_Name nvarchar(max),
			Formula_Value nvarchar(max)		
		)
		
		set @Ad_Formula = REPLACE(@Ad_Formula,' ','') --Added by nilesh patel on 09032015
		
		Insert into #Tbl_Formula
			select Row_Id,items ,items from Split2 (@Ad_Formula,'#')
		
		
		Declare @items as nvarchar(max)
		Declare @M_AD_Calculated_Amount as numeric(18,2)
		
		---check Formula for 123(adc+qwe) --
		Declare @Chk_Row_Id as numeric
		Declare @Chk_Tmp_Row_Id as numeric
		Declare @Chk_Formula_Value as nvarchar(10)
		Declare @Chk_val as nvarchar(10)
		declare @weekoff_ot_rate as numeric(18,0) = 0, @holiday_ot_rate as numeric(18,0) = 0
		
		DECLARE Chk_Formula_error CURSOR FAST_FORWARD FOR
				select Formula_Id,Formula_Value from #Tbl_Formula where Formula_Value ='(' or Formula_Value =')'
			OPEN Chk_Formula_error
				fetch next from Chk_Formula_error into @Chk_Row_Id,@Chk_val
				while @@fetch_status = 0
					Begin
					
						if @Chk_val ='('
							Begin
							  Set @Chk_Tmp_Row_Id=@Chk_Row_Id-1								
							End
						Else
							Begin
								Set @Chk_Tmp_Row_Id=@Chk_Row_Id+1
							End
						select @Chk_Formula_Value=isnull(Formula_Value,'0') from #Tbl_Formula where  Formula_Id =@Chk_Tmp_Row_Id
						
						
						
						if @Chk_Formula_Value <> '+' and @Chk_Formula_Value <> '-' and @Chk_Formula_Value <> '*' and @Chk_Formula_Value <> '/' and @Chk_Formula_Value <> '('  and @Chk_Formula_Value <> ')' and @Chk_Formula_Value <> 'else' and @Chk_Formula_Value <> 'when' and @Chk_Formula_Value <> 'case' and @Chk_Formula_Value <> 'end' and @Chk_Formula_Value <> 'then' and @Chk_Formula_Value <> '<' and @Chk_Formula_Value <> '>' and @Chk_Formula_Value <> '&'
							Begin						
							
								Update #Tbl_Formula set Formula_Id=Formula_Id+1 where Formula_Id > @Chk_Tmp_Row_Id
								Insert Into #Tbl_Formula values (@Chk_Row_Id,'*','*')

							End

					fetch next from Chk_Formula_error into @Chk_Row_Id,@Chk_val	 
					End
		close Chk_Formula_error	
		deallocate Chk_Formula_error

		set @Ad_Formula=''
		SELECT @Ad_Formula = COALESCE(@Ad_Formula+'#', '') + Formula_Value from #Tbl_Formula order by Formula_Id 
		
		Delete From #Tbl_Formula
		
		
		Insert into #Tbl_Formula
			select Row_Id,LTrim(items) ,LTrim(items) from Split2 (@Ad_Formula,'#') --Added by nilesh patel on 09032015 Added  LTrim
	
		---End check Formula for 123(adc+qwe) --
		
--Here New Condition is Added By Ramiz on 21/04/2016--

	IF @PASSED_FROM = 'EARN_DEDUCTION'
		BEGIN
		
				DECLARE Cal_Formula_Val CURSOR FAST_FORWARD FOR
						select Formula_Value from #Tbl_Formula
					OPEN Cal_Formula_Val
						FETCH NEXT FROM Cal_Formula_Val into @items
						WHILE @@FETCH_STATUS = 0
							Begin
								
								if ISNUMERIC(Replace(Replace(@items,'}',''),'{','')) = 1 --Added by nilesh patel on 09032015
								begin
									if CHARINDEX('{',@items) >0 or CHARINDEX('}',@items) >0 
										Begin
											Set @items=REPLACE(@items,'{','')
											Set @items=REPLACE(@items,'}','')
											
											If exists(select ad_id from T0050_Ad_master WITH (NOLOCK) where CMP_ID=@Cmp_ID  and ad_id =cast(@items as numeric))
												Begin								
													set @M_AD_Calculated_Amount = 0	
													
													IF @PASSED_AMOUNT > 0 and @GradeWise_Salary = 1	--ADDED BY RAMIZ ON 31/08/2017. If Amount is Assigned during Salary Structure Assigning , No Need to Check Formula , Directly Insert in Employee's Structure. ( As of Now Only for Mafatlals )
														BEGIN

															SET @Formula_amount = isnull(@PASSED_AMOUNT,0)
														
															RETURN
														END
													ELSE
														BEGIN
														
															SELECT @M_AD_Calculated_Amount=isnull(E_AD_AMOUNT,0)  
															FROM T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) 
															WHERE Emp_ID=@emp_id and Cmp_ID=@cmp_id and For_Date =@For_date 
															and AD_ID=cast(@items as numeric)	
															
															--deepal 04092024 --taking the latest amount of revised allowance 31183 
															Select distinct  @M_AD_Calculated_Amount=isnull(E_AD_AMOUNT,0)  
															from T0110_EMP_EARN_DEDUCTION_REVISED T
															inner join (
																select Max(FOR_DATE) as For_date,AD_ID from T0110_EMP_EARN_DEDUCTION_REVISED 
																where FOR_DATE <= @To_Date and EMP_ID = @EMP_ID and AD_id = cast(@items as numeric)
																group by AD_ID
															)   as T1 on t.FOR_DATE = T1.For_date and T.AD_ID = T1.AD_ID
															and T.AD_ID=cast(@items as numeric)
															WHERE EMP_ID = @EMP_ID 
															--deepal 04092024	

														END					
													
																																					
													Update #Tbl_Formula set Formula_Value=@M_AD_Calculated_Amount where Formula_Value  ='{'+@items+'}'
												End						
										End
								End 	
							fetch next from Cal_Formula_Val into @items	 
							End
				CLOSE Cal_Formula_Val	
				DEALLOCATE Cal_Formula_Val
		END
	ELSE
		BEGIN
		
			DECLARE Cal_Formula_Val CURSOR FAST_FORWARD FOR
					select Formula_Value from #Tbl_Formula
				OPEN Cal_Formula_Val
					FETCH NEXT FROM Cal_Formula_Val into @items
					WHILE @@FETCH_STATUS = 0
						Begin
							
							if ISNUMERIC(Replace(Replace(@items,'}',''),'{','')) = 1 --Added by nilesh patel on 09032015
							begin
							
								if CHARINDEX('{',@items) >0 or CHARINDEX('}',@items) >0 
									Begin
									
										Set @items=REPLACE(@items,'{','')
										Set @items=REPLACE(@items,'}','')
										
										If exists(select ad_id from T0050_Ad_master WITH (NOLOCK) where CMP_ID=@Cmp_ID  and ad_id = cast(@items as numeric))
											Begin	
											
												SET @M_AD_Calculated_Amount=0						
											IF @PASSED_AMOUNT > 0 and @AD_ID = cast(@items as numeric) and @GradeWise_Salary = 1 --New Provision Added By Ramiz on 31/08/2017. If the same Allowance is Coming in its Formula then it will take amount from its Salary Structure.
													BEGIN
														SET @M_AD_Calculated_Amount = ISNULL(@PASSED_AMOUNT,0)
														
													END
												ELSE
													BEGIN
													
													

													Select @weekoff_ot_rate = isnull(Emp_WeekOff_OT_Rate,0),@holiday_ot_rate = isnull(Emp_Holiday_OT_Rate,0) 
													From T0095_INCREMENT Where EMP_ID=@EMP_ID and Cmp_ID = @Cmp_ID

													if @weekoff_ot_rate = 0 
													begin 
													
														IF EXISTS(SELECT 1 FROM #Tbl_Formula where Formula_Value='{Present_On_Weekoff}')
														begin
															SELECT @M_AD_Calculated_Amount=isnull(E_AD_AMOUNT,0)  
															FROM T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) 
															WHERE Emp_ID=@emp_id and Cmp_ID=@cmp_id and For_Date =(SELECT mAX(FOR_DATE) FROM T0100_EMP_EARN_DEDUCTION WHERE EMP_ID = @EMP_ID AND CMP_ID = @Cmp_ID) 
															and AD_ID=cast(@items as numeric)
														end
														else
														begin
																SELECT  @M_AD_Calculated_Amount=ISNULL(M_AD_Amount,0) --COMMENTED BY MR.MEHUL AFTER DISCUSSING WITH DEEPAL 03082022 (CENTURY)
																FROM T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)
																WHERE Emp_ID=@emp_id and Cmp_ID=@cmp_id 
																and For_Date =cast(@For_date as date) 
																and AD_ID=cast(@items as numeric)	 -- 1
																AND S_SAL_TRAN_ID IS NULL -- S_SAL_TRAN_ID IS NULL ADDED ON 06062018 BY RAJPUT ( INDUCTOTHERM CLIENT - SETTLEMENT ISSUE )
														end
													end

													if @holiday_ot_rate = 0
													begin 
															IF EXISTS(SELECT 1 FROM #Tbl_Formula where Formula_Value='{Present_On_Holiday}')
														begin
															SELECT @M_AD_Calculated_Amount=isnull(E_AD_AMOUNT,0)  
															FROM T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) 
															WHERE Emp_ID=@emp_id and Cmp_ID=@cmp_id and For_Date =(SELECT mAX(FOR_DATE) FROM T0100_EMP_EARN_DEDUCTION WHERE EMP_ID = @EMP_ID AND CMP_ID = @Cmp_ID) 
															and AD_ID=cast(@items as numeric)
														end
														else
														begin
																SELECT  @M_AD_Calculated_Amount=ISNULL(M_AD_Amount,0) --COMMENTED BY MR.MEHUL AFTER DISCUSSING WITH DEEPAL 03082022 (CENTURY)
																FROM T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)
																WHERE Emp_ID=@emp_id and Cmp_ID=@cmp_id 
																and For_Date =cast(@For_date as date) 
																and AD_ID=cast(@items as numeric)	 -- 1
																AND S_SAL_TRAN_ID IS NULL -- S_SAL_TRAN_ID IS NULL ADDED ON 06062018 BY RAJPUT ( INDUCTOTHERM CLIENT - SETTLEMENT ISSUE )
														end
														
													end

														--IF EXISTS(SELECT 1 FROM #Tbl_Formula where Formula_Value='{Present_On_Holiday}')
														--begin
														--	SELECT @M_AD_Calculated_Amount=isnull(E_AD_AMOUNT,0)  
														--	FROM T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) 
														--	WHERE Emp_ID=@emp_id and Cmp_ID=@cmp_id and For_Date =(SELECT mAX(FOR_DATE) FROM T0100_EMP_EARN_DEDUCTION WHERE EMP_ID = @EMP_ID AND CMP_ID = @Cmp_ID) 
														--	and AD_ID=cast(@items as numeric)
														--end
														--IF EXISTS(SELECT 1 FROM #Tbl_Formula where Formula_Value='{Present_On_Weekoff}')
														--begin
														--	SELECT @M_AD_Calculated_Amount=isnull(E_AD_AMOUNT,0)  
														--	FROM T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) 
														--	WHERE Emp_ID=@emp_id and Cmp_ID=@cmp_id and For_Date =(SELECT mAX(FOR_DATE) FROM T0100_EMP_EARN_DEDUCTION WHERE EMP_ID = @EMP_ID AND CMP_ID = @Cmp_ID) 
														--	and AD_ID=cast(@items as numeric)
														--end
														--else
														--begin
														--		SELECT  @M_AD_Calculated_Amount=ISNULL(M_AD_Amount,0) --COMMENTED BY MR.MEHUL AFTER DISCUSSING WITH DEEPAL 03082022 (CENTURY)
														--		FROM T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)
														--		WHERE Emp_ID=@emp_id and Cmp_ID=@cmp_id 
														--		and For_Date =cast(@For_date as date) 
														--		and AD_ID=cast(@items as numeric)	 -- 1
														--		AND S_SAL_TRAN_ID IS NULL -- S_SAL_TRAN_ID IS NULL ADDED ON 06062018 BY RAJPUT ( INDUCTOTHERM CLIENT - SETTLEMENT ISSUE )
														--end
														--SELECT  @M_AD_Calculated_Amount=ISNULL(M_AD_Amount,0) 
														--COMMENTED BY MR.MEHUL AFTER DISCUSSING WITH DEEPAL 03082022 (CENTURY)
														--FROM T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)
														--WHERE Emp_ID=@emp_id and Cmp_ID=@cmp_id 
														--and For_Date =cast(@For_date as date) 
														--and AD_ID=cast(@items as numeric)
														-- 1
														--AND S_SAL_TRAN_ID IS NULL 
														-- S_SAL_TRAN_ID IS NULL ADDED ON 06062018 BY RAJPUT ( INDUCTOTHERM CLIENT - SETTLEMENT ISSUE )
														
														--SELECT @M_AD_Calculated_Amount=isnull(E_AD_AMOUNT,0)  
														--	FROM T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) 
														--	WHERE Emp_ID=@emp_id and Cmp_ID=@cmp_id and For_Date =(SELECT mAX(FOR_DATE) FROM T0100_EMP_EARN_DEDUCTION WHERE EMP_ID = @EMP_ID AND CMP_ID = @Cmp_ID) 
														--	and AD_ID=cast(@items as numeric)	
															
													END
												
												IF @Ad_Def_ID = 20  --Production Bonus [ AIA Client ] --Ankit 18052016
													BEGIN
														SET @M_AD_Calculated_Amount = 0
														SELECT @M_AD_Calculated_Amount = Amount_Perc FROM T0190_Production_Bonus_Variable_Import WITH (NOLOCK) 
														WHERE Cmp_ID=@cmp_id AND [MONTH] = MONTH(@to_date) AND [YEAR] = YEAR(@to_date) AND AD_ID = CAST(@items AS NUMERIC)	
														
														SELECT	@Absent_Days = Absent_Days ,@Out_Of_Days = Outof_Days , @Salary_Cal_Day = Sal_Cal_Days
														FROM T0200_MONTHLY_SALARY WITH (NOLOCK)
														WHERE	Cmp_ID=@cmp_id AND Emp_ID = @Emp_ID AND Month_End_Date = @To_Date_Pre_Month
														
													END
													
												IF @Ad_Def_ID = 21  --Production Variable [ AIA Client ] --Ankit 18052016
													BEGIN
														DECLARE @AD_Import_Per	NUMERIC(9,5)
														DECLARE @Allow_Amount	NUMERIC(18,2)
														--DECLARE @Absent_Days_Previous NUMERIC(18,2)
														
														SET @AD_Import_Per = 0
														SET @Allow_Amount =0
														--SET @Absent_Days_Previous = 0
														
														SELECT	@AD_Import_Per = Amount_Perc FROM T0190_Production_Bonus_Variable_Import WITH (NOLOCK)
														WHERE	Cmp_ID=@cmp_id AND [MONTH] = MONTH(@to_date) AND [YEAR] = YEAR(@to_date) AND AD_ID = CAST(@items AS NUMERIC)	
														
														SELECT	@Allow_Amount = Salary_Amount,@Absent_Days = Absent_Days ,@Out_Of_Days = Outof_Days , @Salary_Cal_Day = Sal_Cal_Days
														FROM T0200_MONTHLY_SALARY WITH (NOLOCK)
														WHERE	Cmp_ID=@cmp_id AND Emp_ID = @Emp_ID AND Month_End_Date = @To_Date_Pre_Month
													
														SELECT  @Allow_Amount = @Allow_Amount + ISNULL(SUM(M_AD_amount),0)
														FROM	dbo.T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) INNER JOIN 
																dbo.T0060_EFFECT_AD_MASTER  EAD WITH (NOLOCK) ON MAD.AD_ID=EAD.AD_ID AND mad.Cmp_ID= ead.CMP_ID	
														WHERE	MAD.Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID AND For_Date = @From_Date_Pre_Month
																AND EAD.EFFECT_AD_ID = CAST(@items AS NUMERIC)
														
														SET @M_AD_Calculated_Amount = ( (@Allow_Amount * @AD_Import_Per) / 100 )
														
													END	
													
												IF @Ad_Def_ID = 28  --Average Salary of Mafatlals Nadiad.
													BEGIN

														DECLARE @Pre_Month_Avg	NUMERIC(18,2)
														SET @Pre_Month_Avg =0
														
														IF @Salary_Exists = 1 --If Last Month Salary Exists , then Check Value from last month Salary only
																BEGIN
																	SELECT  @Pre_Month_Avg = ISNULL(M_AD_amount,0)
																	FROM	dbo.T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
																	WHERE	MAD.Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID AND For_Date = @From_Date_Pre_Month
																			AND MAD.AD_ID = CAST(@items AS NUMERIC)
																END
														ELSE if @Salary_Exists = 0 --If Last Month Salary Not Exists , then Check if Value is Imported in Same Month on which we are Generating Salary.
															BEGIN
																SELECT  @Pre_Month_Avg = ISNULL(SUM(M_AD_amount),0)
																FROM	dbo.T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
																		INNER JOIN T0050_AD_MASTER ADM WITH (NOLOCK) ON MAD.AD_ID = ADM.AD_ID
																WHERE	MAD.Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID AND MAD.For_Date = @For_date
																		AND ADM.AD_DEF_ID = @Ad_Def_ID and AD_CALCULATE_ON = 'Import'
															END
																
															
														SET @M_AD_Calculated_Amount = @Pre_Month_Avg
														
													END	
																																				
												Update #Tbl_Formula set Formula_Value=@M_AD_Calculated_Amount where Formula_Value  ='{'+@items+'}'
											End						
									End
							End 	
						fetch next from Cal_Formula_Val into @items	 
						End
			CLOSE Cal_Formula_Val	
			DEALLOCATE Cal_Formula_Val
		END
--Here New Condition is Ended By Ramiz on 21/04/2016--	
		 
	 Declare @Is_Cancel_weekoff as Numeric(18,0)  
	 Declare @Is_Cancel_Holiday as Numeric(18,0)  
	 declare @emp_Branch as numeric(18,0)  
	 declare @Holiday_days as numeric(18,2)  
	 declare @Weekoff_Days as numeric(18,2)  
	 declare @PresOnHoliday_Days as numeric(18,2)   = 0
	 declare @NightShift_Count as numeric(18,2)   = 0
	 set @Holiday_days =0  
	 set @Weekoff_Days =0  
	 set @PresOnHoliday_Days = 0
	 set @NightShift_Count = 0

	 declare @PresOnWeekoff_Days as numeric(18,2)   = 0

	 select @emp_Branch  = Branch_id from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@EMP_ID  
	   
	 Select @Is_Cancel_weekoff = Is_Cancel_weekoff   
	  ,@Is_Cancel_Holiday = Is_Cancel_Holiday , @AD_Rounding = AD_Rounding   
	  From dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @emp_Branch      
	  and For_Date = ( select max(For_Date) from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Branch_ID = @emp_Branch and Cmp_ID = @Cmp_ID)      
	   
	   
		 	IF	EXISTS(SELECT 1 FROM #Tbl_Formula where Formula_Value='{Holiday}')  
				OR EXISTS(SELECT 1 FROM #Tbl_Formula where Formula_Value='{WeekOff}')  
				OR EXISTS(SELECT 1 FROM #Tbl_Formula where Formula_Value='{Present_On_Holiday}')  
				OR EXISTS(SELECT 1 FROM #Tbl_Formula where Formula_Value='{Present_On_Weekoff}')  
				BEGIN
				
					/*************************************************************************
					Added by Nimesh: 17/Nov/2015 
					(To get holiday/weekoff data for all employees in seperate table)
					*************************************************************************/
	
					IF OBJECT_ID('tempdb..#Emp_WeekOff') IS NOT NULL
						DROP TABLE #EMP_WEEKOFF

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
	
					IF OBJECT_ID('tempdb..#Emp_Holiday') IS NOT NULL
						DROP TABLE #Emp_Holiday
						 
					CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));
					CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);

	
					DECLARE @CONSTRAINT VARCHAR(100)  	
					SET @CONSTRAINT = CAST(@EMP_ID AS VARCHAR(10));					
					IF OBJECT_ID('tempdb..#EMP_WEEKOFF_SAL') IS NUll
						EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@FOR_DATE, @TO_DATE=@TO_DATE, @All_Weekoff = 0, @Exec_Mode=0		 --@Exec_Mode = 1 FOR ONLY WEEKOFF
					ELSE
						BEGIN
							TRUNCATE TABLE #EMP_WEEKOFF
							INSERT INTO #EMP_WEEKOFF
							SELECT * FROM #EMP_WEEKOFF_SAL WHERE EMP_ID=@EMP_ID
							
							TRUNCATE TABLE #EMP_HOLIDAY
							INSERT INTO #EMP_HOLIDAY
							SELECT * FROM #EMP_HOLIDAY_SAL WHERE EMP_ID=@EMP_ID
						END
					
					
				END


				IF OBJECT_ID('tempdb..#EMP_ATTENDANCE') IS NOT NULL
					DROP TABLE #EMP_ATTENDANCE
					
					CREATE TABLE #EMP_ATTENDANCE
					(
						Emp_ID NUMERIC,
						Cmp_ID NUMERIC,
						For_Date DATETIME,
						In_Time DATETIME,
						Out_Time DATETIME,
						Night_Shift_Count Bit
					)

				

		DECLARE @Left_date as datetime	                    
		SELECT @Left_date=Emp_Left_Date FROM dbo.t0080_emp_master WITH (NOLOCK) WHERE emp_ID =@Emp_ID  
				
		IF @Left_date < @To_Date
			Set @To_Date = @Left_date -- Added by nilesh on 13082018 After Left date week count is consider here 
			
		IF EXISTS(SELECT 1 FROM #Tbl_Formula where Formula_Value='{Holiday}')  
			Begin
				If Exists(Select 1 from T0170_EMP_ATTENDANCE_IMPORT WITH (NOLOCK) where Emp_ID=@EMP_ID And [Month]=Month(@For_date) And [Year]=Year(@For_date)) --Added Condition by Hardik 21/11/2016 for Amazon
					Begin
						
						Select @Holiday_days = Isnull(Holiday,0) from T0170_EMP_ATTENDANCE_IMPORT WITH (NOLOCK) where Emp_ID=@EMP_ID And [Month]=Month(@For_date) And [Year]=Year(@For_date)					
					End
				Else
					Begin						
						--Exec dbo.SP_EMP_HOLIDAY_DATE_GET @emp_id,@Cmp_ID,@For_date,@To_Date,null,null,@Is_Cancel_Holiday,'' ,@Holiday_days output,0,1,0,''  						
						SELECT @Holiday_days = COUNT(1) FROM #Emp_Holiday Where FOR_DATE >= @For_Date And FOR_DATE <= @To_Date and Is_Cancel=0						
					End
			End


		IF EXISTS(SELECT 1 FROM #Tbl_Formula where Formula_Value='{WeekOff}')
			Begin
				If Exists(Select 1 from T0170_EMP_ATTENDANCE_IMPORT WITH (NOLOCK) where Emp_ID=@EMP_ID And [Month]=Month(@For_date) And [Year]=Year(@For_date))
					Begin
						Select @Weekoff_Days = Isnull(WeeklyOff,0) from T0170_EMP_ATTENDANCE_IMPORT WITH (NOLOCK) where Emp_ID=@EMP_ID And [Month]=Month(@For_date) And [Year]=Year(@For_date)					
					End
				Else
					begin
						SELECT @Weekoff_Days = COUNT(1) FROM #EMP_WEEKOFF Where FOR_DATE >= @For_Date And FOR_DATE <= @To_Date AND Is_Cancel=0						
 					End
 			End	

			
		IF EXISTS(SELECT 1 FROM #Tbl_Formula where Formula_Value='{Present_On_Holiday}')
		Begin
			SELECT @PresOnHoliday_Days = count(1) from Emp_PresentOnHoliday	
		End	
		
		IF EXISTS(SELECT 1 FROM #Tbl_Formula where Formula_Value='{Present_On_Weekoff}') --Added by Mehul 08-05-2022
		Begin
			SELECT @PresOnWeekoff_Days = count(1) from Emp_PresentOnWeekoff	
		End	
		
		IF EXISTS(SELECT 1 FROM #Tbl_Formula where Formula_Value='{NightShiftCount}') --Added by Mehul 27-07-2022
		Begin
		
			Insert into #EMP_ATTENDANCE
			
			Select Emp_ID,Cmp_id,For_Date,In_Time  ,Out_Time,
			(select 
				case when 
				In_Time >= convert(varchar,For_Date, 23)+' ' +'23:30:00' and In_Time <= convert(varchar,DATEADD(DAY, 1, For_Date), 23)+' '+'06:30:00'
				then 1 
				when
				In_Time <= convert(varchar,For_Date, 23)+' ' +'23:30:00' and Out_Time >= convert(varchar,For_Date, 23)+' ' +'23:30:00'
			then 1 
			else 0 End ) as Emp_Att_Count
			from T0150_EMP_INOUT_RECORD where emp_id = @EMP_ID and Cmp_ID = @Cmp_ID 
			and FOR_DATE >= @For_Date And FOR_DATE <= @To_Date

			select @NightShift_Count = Count(Night_Shift_Count) from #EMP_ATTENDANCE where Night_Shift_Count = 1
			
 		End	

		--Select * from T0150_EMP_INOUT_RECORD where emp_id = @EMP_ID and Cmp_ID = @Cmp_ID 
		--	and FOR_DATE >= @For_Date And FOR_DATE <= @To_Date
		
		--{NightShiftCount}
		--IF EXISTS(SELECT 1 FROM #Tbl_Formula where Formula_Value='{WeekOff}')
		--	Begin
		--		If Exists(Select 1 from T0170_EMP_ATTENDANCE_IMPORT where Emp_ID=@EMP_ID And [Month]=Month(@For_date) And [Year]=Year(@For_date))
		--			Begin
		--				Select @Weekoff_Days = Isnull(WeeklyOff,0) from T0170_EMP_ATTENDANCE_IMPORT where Emp_ID=@EMP_ID And [Month]=Month(@For_date) And [Year]=Year(@For_date)					
		--			End
		--		Else
		--			begin
 	--					Exec dbo.SP_EMP_WEEKOFF_DATE_GET @emp_id,@Cmp_ID,@For_date,@To_Date,null,null,@Is_Cancel_weekoff,'','',@Weekoff_Days output ,0     
 	--				End
 	--		End	
	  
	  
		
		---------BELOW CODE ADDED BY SUMIT AS PER DISCUSSION WITH HARDIK SIR TO GET CANCEL WEEKOFF AND CANCEL HOLIDAY-------------------------------------------------------------------------------------------------
		
		IF EXISTS(SELECT 1 FROM T0190_MONTHLY_PRESENT_IMPORT WITH (NOLOCK) WHERE EMP_ID=@EMP_ID AND CMP_ID=@CMP_ID AND MONTH(FOR_DATE)=MONTH(@FOR_DATE) AND YEAR(FOR_DATE)=YEAR(@FOR_DATE))
			BEGIN
				DECLARE @CANCELWEEKOFF AS NUMERIC(18,0)
				DECLARE @CANCELHOLIDAY AS NUMERIC(18,0)
				SET @CANCELWEEKOFF=0
				SET @CANCELHOLIDAY=0
				
				SELECT @CANCELWEEKOFF=CANCEL_WEEKOFF_DAY,@CANCELHOLIDAY=CANCEL_HOLIDAY FROM T0190_MONTHLY_PRESENT_IMPORT WITH (NOLOCK) WHERE EMP_ID=@EMP_ID AND CMP_ID=@CMP_ID AND MONTH(FOR_DATE)=MONTH(@FOR_DATE) AND YEAR(FOR_DATE)=YEAR(@FOR_DATE)
				IF (@WEEKOFF_DAYS >= ISNULL(@CANCELWEEKOFF,0))
				BEGIN
					SET @WEEKOFF_DAYS = @WEEKOFF_DAYS - ISNULL(@CANCELWEEKOFF,0)
				END	
				IF (@HOLIDAY_DAYS >= ISNULL(@CANCELHOLIDAY,0) )
				BEGIN
					SET @HOLIDAY_DAYS=@HOLIDAY_DAYS - ISNULL(@CANCELHOLIDAY,0) 
				END		
			END
		
		-----------------------------------------------------------------------------------------------------------
		
	IF @PASSED_FROM = 'EARN_DEDUCTION'		--Added By Ramiz on 20/07/2016 to Replace all Leave With 0 , so that During Assigning structure it should not check Leave
		BEGIN			
				UPDATE #Tbl_Formula set Formula_Value = 0 
				FROM #Tbl_Formula tfe inner join
				(
					select lm.leave_code as leave_code from t0040_leave_master lm WITH (NOLOCK) where lm.cmp_id = @cmp_id 
				)	as tbl on tfe.Formula_Name COLLATE SQL_Latin1_General_CP1_CI_AS = '{' + tbl.Leave_Code COLLATE SQL_Latin1_General_CP1_CI_AS + '}'

		END
	ELSE
		BEGIN	
			IF @AD_DEF_ID = 21 OR @AD_DEF_ID = 20	--Production Variable -- Ankit 18052016
				BEGIN
					UPDATE #Tbl_Formula SET Formula_Value = ISNULL(tbl.Leave_Days,0)
					FROM #Tbl_Formula tfe INNER JOIN
					(
						SELECT lm.leave_code, ( SELECT ISNULL(SUM(leave_days),0) FROM T0210_MONTHLY_LEAVE_DETAIL mld WITH (NOLOCK) 
												WHERE mld.cmp_id = @cmp_id AND mld.emp_id = @emp_id AND mld.leave_id = lm.leave_id 
													AND mld.For_Date between @From_Date_Pre_Month and @To_Date_Pre_Month and mld.Temp_Sal_Tran_ID IS NULL /* Not Include Current Month leave While Sal Cycle 26 to 25 */
											   )  AS Leave_days
						FROM t0040_leave_master lm WITH (NOLOCK)	 
						WHERE lm.cmp_id = @cmp_id 
					)	AS tbl ON tfe.Formula_Name COLLATE SQL_Latin1_General_CP1_CI_AS = '{' + tbl.Leave_Code COLLATE SQL_Latin1_General_CP1_CI_AS + '}'
				
				
						update #Tbl_Formula set Formula_Value = Formula_Value + isnull(tbl.Leave_Days,0)
							from #Tbl_Formula tfe inner join
							(
								select SUM(isnull(LT.leave_Adj_L_Mark,0)) as Leave_Days,Leave_Code 
								from T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) Inner Join T0040_LEAVE_MASTER LM WITH (NOLOCK) On LT.Leave_ID = LM.Leave_Id and LT.Cmp_ID = LM.Cmp_ID
											where  For_Date BETWEEN @From_Date_Pre_Month AND @To_Date_Pre_Month 
											and LT.Cmp_ID = @cmp_id and LT.Emp_ID = @emp_id Group by Leave_Code
						
							) as tbl on tfe.Formula_Name COLLATE SQL_Latin1_General_CP1_CI_AS = '{' + tbl.Leave_Code COLLATE SQL_Latin1_General_CP1_CI_AS + '}'				
				
				END
			ELSE
				BEGIN
					update #Tbl_Formula set Formula_Value = isnull(tbl.Leave_Days,0)
					from #Tbl_Formula tfe inner join
					(
						select lm.leave_code, (select isnull(sum(leave_days),0) from T0210_MONTHLY_LEAVE_DETAIL mld WITH (NOLOCK)
						where mld.cmp_id = @cmp_id and mld.emp_id = @emp_id and mld.leave_id = lm.leave_id and for_date = @for_date)  as Leave_days
						from t0040_leave_master lm WITH (NOLOCK) 	 
							where lm.cmp_id = @cmp_id 
					)	as tbl on tfe.Formula_Name COLLATE SQL_Latin1_General_CP1_CI_AS = '{' + tbl.Leave_Code COLLATE SQL_Latin1_General_CP1_CI_AS + '}'

				END
		END
			
		--update #Tbl_Formula set Formula_Value = isnull(tbl.Leave_Days,0)
		--from #Tbl_Formula tfe inner join
		--(
		--	select lm.leave_code, (select isnull(sum(leave_days),0) from T0210_MONTHLY_LEAVE_DETAIL mld 
		--	where mld.cmp_id = @cmp_id and mld.emp_id = @emp_id and mld.leave_id = lm.leave_id and for_date = @for_date)  as Leave_days
		--	from t0040_leave_master lm 	 
		--		where lm.cmp_id = @cmp_id 
		--)	as tbl on tfe.Formula_Name COLLATE SQL_Latin1_General_CP1_CI_AS = '{' + tbl.Leave_Code COLLATE SQL_Latin1_General_CP1_CI_AS + '}'



		--Added by Nilesh on 17112015 -start
		if Exists(Select 1 From #Tbl_Formula where Formula_Value ='{Half_Paid_Leave}')
			BEGIN
				Update #Tbl_Formula set Formula_Value = 0 where Formula_Value ='{Half_Paid_Leave}'
				update #Tbl_Formula set Formula_Value = isnull(tbl.Leave_Days,0)
				from #Tbl_Formula tfe inner join
				(
					SELECT  Sum(isnull(Leave_Used,0)) as Leave_Days,'Half_Paid_Leave' as Leave_Code
					From dbo.T0140_leave_Transaction LT WITH (NOLOCK)
					Inner join dbo.T0040_Leave_Master LM WITH (NOLOCK) on LT.Leave_ID = LM.Leave_ID and (isnull(eff_in_salary,0) <> 1 
							or (isnull(eff_in_salary,0) = 1 and isnull(Leave_encash_days,0) <= 0) 
							or (isnull(eff_in_salary,0) = 1 and isnull(Leave_encash_days,0) >= 0 and (isnull(Leave_Used,0) > 0))) and isnull(LM.Default_Short_Name,'') <> 'COMP' 
					WHERE Emp_ID = @emp_id and LT.Cmp_ID = @cmp_id and For_Date BETWEEN @For_Date AND @to_date
					and LM.Leave_Paid_Unpaid = 'P' and LM.Half_Paid = 1 and Isnull(LM.Apply_Hourly,0) = 0 and LT.Half_Payment_Days = 0
					GROUP BY Emp_ID,LT.Leave_ID
				) as tbl on tfe.Formula_Name COLLATE SQL_Latin1_General_CP1_CI_AS = '{' + tbl.Leave_Code COLLATE SQL_Latin1_General_CP1_CI_AS + '}'
			END
		--Added By Nilesh on 17112015 -End 
		
		--Added by Nilesh on 17112015 -start
		if Exists(Select 1 From #Tbl_Formula where Formula_Value ='{Full_Paid_Leave}')
			BEGIN
				-- Set Zero value of Full paid leave if any Full Paid leave is not available 
				Update #Tbl_Formula set Formula_Value = 0 where Formula_Value ='{Full_Paid_Leave}'
				
				update #Tbl_Formula set Formula_Value = isnull(tbl.Leave_Days,0)
				from #Tbl_Formula tfe inner join
				(
					SELECT  Sum(isnull(Leave_Used,0)) as Leave_Days,'Full_Paid_Leave' as Leave_Code
					From dbo.T0140_leave_Transaction LT WITH (NOLOCK)
					Inner join dbo.T0040_Leave_Master LM WITH (NOLOCK) on LT.Leave_ID = LM.Leave_ID and (isnull(eff_in_salary,0) <> 1 
							or (isnull(eff_in_salary,0) = 1 and isnull(Leave_encash_days,0) <= 0) 
							or (isnull(eff_in_salary,0) = 1 and isnull(Leave_encash_days,0) >= 0 and (isnull(Leave_Used,0) > 0))) and isnull(LM.Default_Short_Name,'') <> 'COMP' 
					WHERE Emp_ID = @emp_id and LT.Cmp_ID = @cmp_id and For_Date BETWEEN @For_Date AND @to_date 
					and LM.Leave_Paid_Unpaid = 'P' and LM.Half_Paid = 1 and Isnull(LM.Apply_Hourly,0) = 0 and LT.Half_Payment_Days = 1
					GROUP BY Emp_ID,LT.Leave_ID
				) as tbl on tfe.Formula_Name COLLATE SQL_Latin1_General_CP1_CI_AS = '{' + tbl.Leave_Code COLLATE SQL_Latin1_General_CP1_CI_AS + '}'
			END
		--Added By Nilesh on 17112015 -End 
		
		--Added by Nilesh on 05112015 -start
		if Exists(Select 1 From #Tbl_Formula where Formula_Value ='{Half_Payment_Leave}')
			BEGIN 
			
				Update #Tbl_Formula set Formula_Value = 0 where Formula_Value ='{Half_Payment_Leave}'
				
				update #Tbl_Formula set Formula_Value = isnull(tbl.Leave_Days,0)
				from #Tbl_Formula tfe inner join
				(
					select SUM(isnull(Leave_Used,0)) as Leave_Days,'Half_Payment_Leave' as Leave_Code from T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
								inner join T0040_LEAVE_MASTER LM WITH (NOLOCK) on LT.Leave_ID = LM.Leave_ID 
								where  LM.Half_Paid = 1 and LT.Half_Payment_Days = 0
								and For_Date BETWEEN @For_Date AND @to_date 
								and LT.Cmp_ID = @cmp_id and LT.Emp_ID = @emp_id
						
				) as tbl on tfe.Formula_Name COLLATE SQL_Latin1_General_CP1_CI_AS = '{' + tbl.Leave_Code COLLATE SQL_Latin1_General_CP1_CI_AS + '}'
			 End
		
		--Added by Nilesh on 05112015 -End
		
		--Added by Nilesh on 03052016 -start
		if Exists(Select 1 From #Tbl_Formula where Formula_Value ='{Late_Early_Penalty_Leave_Count}')
			BEGIN 
			
				Update #Tbl_Formula set Formula_Value = 0 where Formula_Value ='{Late_Early_Penalty_Leave_Count}'
				
				update #Tbl_Formula set Formula_Value = isnull(tbl.Leave_Days,0)
				from #Tbl_Formula tfe inner join
				(
					select SUM(isnull(LT.leave_Adj_L_Mark,0)) as Leave_Days,'Late_Early_Penalty_Leave_Count' as Leave_Code from T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
								where  For_Date BETWEEN @For_Date AND @to_date 
								and LT.Cmp_ID = @cmp_id and LT.Emp_ID = @emp_id
						
				) as tbl on tfe.Formula_Name COLLATE SQL_Latin1_General_CP1_CI_AS = '{' + tbl.Leave_Code COLLATE SQL_Latin1_General_CP1_CI_AS + '}'
			 End
		
		--Added by Nilesh on 03052016 -End
		
		-- Added by nilesh patel on 09032015 -Start
		Update #Tbl_Formula set Formula_Value=isnull(@Prorata_Basic_Sal,0) where Formula_Value ='{BasicSalary}'	
		Update #Tbl_Formula set Formula_Value=isnull(@Prorata_Gross_Sal,0) where Formula_Value='{GrossSalary}'
		Update #Tbl_Formula set Formula_Value=isnull(@Prorata_CTC_Sal,0) where Formula_Value='{CTC}'
		Update #Tbl_Formula set Formula_Value = @absent_days where Formula_Value='{AbsentDays}'		--Commented Below Portion of Absent Days and Passed Value in Variable.(Ramiz 06/11/2017)
		Update #Tbl_Formula set Formula_Value = Isnull(@Night_Shift_Count,0) where Formula_Value='{Night_Shift_Count}'			

		--if @Absent_Day_Calc = 1 
		--	Begin
		--		Update #Tbl_Formula set Formula_Value = @absent_days where Formula_Value='{AbsentDays}'	
		--	End 
		--Else
		--	Begin
		--		if @Salary_Settlement_Flag = 1 
		--			Update #Tbl_Formula set Formula_Value=@absent_days where Formula_Value='{AbsentDays}'	
		--		Else
		--			Update #Tbl_Formula set Formula_Value=@Out_Of_Days - @Salary_Cal_Day where Formula_Value='{AbsentDays}'	
		--	End

		If @PASSED_FROM = 'EARN_DEDUCTION'
			Update #Tbl_Formula set Formula_Value=1
			where 	Formula_Value in ('{PresentDays}', '{SalaryCalculateDays}', '{MonthDays}')

		Update #Tbl_Formula set Formula_Value=@Present_Days where Formula_Value='{PresentDays}'
		Update #Tbl_Formula set Formula_Value=@Salary_Cal_Day where Formula_Value='{SalaryCalculateDays}'
		Update #Tbl_Formula set Formula_Value=@Earning_Gross where Formula_Value='{ActualGross}'
	
		

		--Changed By Ramiz on 26/04/2016 for AIA
		If @PASSED_FROM = 'EARN_DEDUCTION'
			BEGIN
				Update #Tbl_Formula set Formula_Value=isnull(@Prorata_Basic_Sal,0) where Formula_Value='{ActualBasic}'
			END
		Else If @Salary_Settlement_Flag = 1 -- Added by Hardik 02/07/2018 for AIA
			BEGIN
				Update #Tbl_Formula set Formula_Value=isnull(ROUND(@Prorata_Basic_Sal * @Salary_Cal_Day/@Out_Of_Days,0),0) where Formula_Value='{ActualBasic}'
			END
		ELSE
			BEGIN
				Update #Tbl_Formula set Formula_Value=isnull(@Earning_Basic,0) where Formula_Value='{ActualBasic}'
			END
		--Update #Tbl_Formula set Formula_Value=isnull(@Earning_Basic,0) where Formula_Value='{ActualBasic}'
		
		Update #Tbl_Formula set Formula_Value=isnull(@Xdays,0) where Formula_Value='{XDays}'

		Update #Tbl_Formula Set Formula_Value=ISNULL(@NightHaltDays,0) where Formula_Value='{NightHaltCount}' ---Added by Sid 27062014
		Update #Tbl_Formula Set Formula_Value=ISNULL(@Out_Of_Days,0) where Formula_Value='{MonthDays}' -- Added By rohit on 25112014
		
		Update #Tbl_Formula Set Formula_Value=ISNULL(@Weekoff_Days,0) where Formula_Value='{WeekOff}' -- Added By rohit on 27032015  
		Update #Tbl_Formula Set Formula_Value=ISNULL(@Holiday_days,0) where Formula_Value='{Holiday}' -- Added By rohit on 27032015  

	if @settingval = 0 
		begin
			Update #Tbl_Formula Set Formula_Value=ISNULL(@PresOnHoliday_Days,0) where Formula_Value='{Present_On_Holiday}' -- Added By rohit on 27032015  
			Update #Tbl_Formula Set Formula_Value=ISNULL(@PresOnWeekoff_Days,0) where Formula_Value='{Present_On_Weekoff}' -- Added By mehul on 08052023
		end
		else
		begin
			--Select * from T0100_EMP_SHIFT_DETAIL
			Declare @holiday_dys as numeric(18,1),
			@weekday_dys as numeric(18,1),
			@shifttran_weekoff as numeric,
			@shifttran_holiday as numeric,
			@duration_weekoff as numeric(18,2),
			@duration_holiday as numeric(18,2),
			@durationinhrsweekoff as numeric(18,1),
			@durationinhrsholiday as numeric(18,1),
			@totaldayscalweek as numeric(18,2) = 0,
			@totaldayscalholi as numeric(18,2) = 0,
			@countweek as numeric = 0,
			@countholi as numeric = 0,
			@whileweek as numeric = 1,
			@whileholi as numeric = 1
			
			CREATE TABLE #WEEKOFF (
			ROW_ID NUMERIC
			,EMP_ID NUMERIC
			,FOR_DATE DATETIME
			,DURATION NUMERIC
			,SHIFT_ID NUMERIC
			,DURATIONHRS NUMERIC
			,CNT NUMERIC
			,CALCULATE_DAYS NUMERIC(18,2)
			)

			CREATE TABLE #HOLIDAY (
			ROW_ID NUMERIC
			,EMP_ID NUMERIC
			,FOR_DATE DATETIME
			,DURATION NUMERIC
			,SHIFT_ID NUMERIC
			,DURATIONHRS NUMERIC
			,CNT NUMERIC
			,CALCULATE_DAYS NUMERIC(18,2)
			)

			--select @countholi = Count(1) from T0040_CALCULATION_HOLIDAY_SLABWISE
			--select @countweek = Count(1) from T0040_CALCULATION_WEEKOFF_SLABWISE

			--while @whileweek <= @countweek
			--begin
				
			--			SELECT @duration_weekoff = DURATION FROM (
			--			SELECT ROW_NUMBER() OVER (ORDER BY for_date ASC) AS rownumber,
			--			ISNULL(DURATION,0) AS DURATION FROM T0040_CALCULATION_WEEKOFF_SLABWISE) AS foo
			--			WHERE rownumber = @whileweek
						
			--			set @durationinhrsweekoff = @duration_weekoff / 3600
						
			--			select @shifttran_weekoff = Shift_Tran_ID from T0050_SHIFT_DETAIL 
			--			where (@durationinhrsweekoff between From_Hour and To_Hour) 
			--			and Shift_ID = (select Distinct Shift_Id from T0040_CALCULATION_WEEKOFF_SLABWISE)

			--			select @weekday_dys = isnull(Calculate_Days,0) from T0050_SHIFT_DETAIL where Cmp_ID = @Cmp_ID and Shift_Tran_ID = @shifttran_weekoff

			--			set @totaldayscalweek= @totaldayscalweek + @weekday_dys

			--			set @whileweek  = @whileweek + 1
			--end

			--while @whileholi <= @countholi
			--begin
				
			--			SELECT @duration_holiday = DURATION FROM (
			--			SELECT ROW_NUMBER() OVER (ORDER BY for_date ASC) AS rownumber,
			--			ISNULL(DURATION,0) AS DURATION FROM T0040_CALCULATION_HOLIDAY_SLABWISE) AS foo
			--			WHERE rownumber = @whileholi


			--			set @durationinhrsholiday = @duration_holiday / 3600
						
			--			select @shifttran_holiday = Shift_Tran_ID from T0050_SHIFT_DETAIL 
			--			where (@durationinhrsholiday between From_Hour and To_Hour) and 
			--			Shift_ID = (select Distinct Shift_Id from T0040_CALCULATION_HOLIDAY_SLABWISE)
						
			--			select @holiday_dys = isnull(Calculate_Days,0) from T0050_SHIFT_DETAIL where Cmp_ID = @Cmp_ID and Shift_Tran_ID = @shifttran_holiday
						

			--			set @totaldayscalholi= @totaldayscalholi + @holiday_dys
						
			--			set @whileholi  = @whileholi + 1
			--end


			;WITH CTE( Row_ID,Emp_ID,For_Date,Duration,Shift_ID,Durationinhrs,Cnt)
						AS (
						select ROW_ID,EMP_ID,FOR_DATE,DURATION,SHIFT_ID, DURATION / 3600 as Durationinhrs,
						ROW_NUMBER() OVER(PARTITION BY  emp_id order by DURATION) as Cnt 
								from T0040_CALCULATION_HOLIDAY_SLABWISE
			)
			Insert into #HOLIDAY
			select Row_ID,CTE.Emp_ID,CTE.For_Date,CTE.Duration,CTE.Shift_ID,Durationinhrs,Cnt,
			Case when Chk_By_Superior = 0 then Calculate_Days 
			when Chk_By_Superior = 1 and Half_Full_Day = 'Full Day' then 1 
			when Chk_By_Superior = 1 and Half_Full_Day = 'Second Half' then 0.5
			when Chk_By_Superior = 1 and Half_Full_Day = 'First Half' then 0.5
			end as Calculate_Days
			from CTE
			inner join T0050_SHIFT_DETAIL sd on CTE.Shift_ID = sd.Shift_ID
			inner join T0150_EMP_INOUT_RECORD EMPIR on EMPIR.emp_id  = CTE.emp_id and CTE.for_Date = EMPIR.for_date
			where Durationinhrs between From_Hour and To_Hour


			;WITH CTM( Row_ID,Emp_ID,For_Date,Duration,Shift_ID,Durationinhrs,Cnt)
						AS (
						select ROW_ID,EMP_ID,FOR_DATE,DURATION,SHIFT_ID, DURATION / 3600 as Durationinhrs,
						ROW_NUMBER() OVER(PARTITION BY  emp_id order by DURATION) as Cnt 
								from T0040_CALCULATION_WEEKOFF_SLABWISE
			)

			Insert into #WEEKOFF
			select Row_ID,CTM.Emp_ID,CTM.For_Date,CTM.Duration,CTM.Shift_ID,Durationinhrs,Cnt,
			Case when Chk_By_Superior = 0 then Calculate_Days 
			when Chk_By_Superior = 1 and Half_Full_Day = 'Full Day' then 1 
			when Chk_By_Superior = 1 and Half_Full_Day = 'Second Half' then 0.5
			when Chk_By_Superior = 1 and Half_Full_Day = 'First Half' then 0.5
			end as Calculate_Days
			from CTM
			inner join T0050_SHIFT_DETAIL sd on CTM.Shift_ID = sd.Shift_ID
			inner join T0150_EMP_INOUT_RECORD EMPIR on EMPIR.emp_id  = CTM.emp_id and CTM.for_Date = EMPIR.for_date
			where Durationinhrs between From_Hour and To_Hour 


			--Update #Tbl_Formula Set Formula_Value=ISNULL(@totaldayscalholi,0) where Formula_Value='{Present_On_Holiday}' -- Added By mehul on 08052023  
			--Update #Tbl_Formula Set Formula_Value=ISNULL(@totaldayscalweek,0) where Formula_Value='{Present_On_Weekoff}' -- Added By mehul on 08052023
			
			Update #Tbl_Formula Set Formula_Value=(Select SUM(CALCULATE_DAYS) from #HOLIDAY where EMP_ID = @EMP_ID) where Formula_Value='{Present_On_Holiday}' -- Added By mehul on 08052023  
			Update #Tbl_Formula Set Formula_Value=(Select SUM(CALCULATE_DAYS) from #WEEKOFF where EMP_ID = @EMP_ID) where Formula_Value='{Present_On_Weekoff}' -- Added By mehul on 08052023

			--SELECT * FROM #Tbl_Formula

			DROP TABLE #WEEKOFF
			DROP TABLE #HOLIDAY

		end
		

		--Update #Tbl_Formula Set Formula_Value=ISNULL(@PresOnHoliday_Days,0) where Formula_Value='{Present_On_Holiday}' -- Added By rohit on 27032015  

		Update #Tbl_Formula Set Formula_Value=ISNULL(@NightShift_Count,0) where Formula_Value='{NightShiftCount}' --Added by Mehul 27-07-2022

		Update #Tbl_Formula set Formula_Value=@arrear_Day where Formula_Value='{ArrearDays}' 
		Update #Tbl_Formula set Formula_Value=@Calculate_Arrear where Formula_Value='{CalculateArrear}'  -- Added by Rajput on 06032018 For CERA CLIENT Based On Formula Based Allowance Arear Time Flag
		
		

		-- Added by nilesh patel on 09032015 -End
/*
Commented By Ramiz on 19/10/2016 , After Rohit bhai Suggestion. . .AS we are already Catching the Error. And that Allowance Should not be Provided if Error is Coming

		Declare @Row_Id as numeric
		Declare @Temp_Row_Id as numeric
		--Declare @Temp_Formula_Value as numeric(18,2)
		Declare @Temp_Formula_Value as varchar(10) -- commneted and added by rohit for if next value is counse "(" then create error on 26092016
		
		DECLARE Chk_Devide_By_Zero CURSOR FAST_FORWARD FOR
				select Formula_Id from #Tbl_Formula where Formula_Value ='/'
			OPEN Chk_Devide_By_Zero
				fetch next from Chk_Devide_By_Zero into @Row_Id
				while @@fetch_status = 0
					Begin
						Set @Temp_Row_Id=@Row_Id+1					
						select @Temp_Formula_Value=isnull(Formula_Value,'0') from #Tbl_Formula where  Formula_Id =@Temp_Row_Id
						if @Temp_Formula_Value = '0'
							Begin						
								Update #Tbl_Formula set Formula_Value=1 where Formula_Id =@Temp_Row_Id
							End
						 				
					fetch next from Chk_Devide_By_Zero into @Row_Id	 
					End
		close Chk_Devide_By_Zero	
		deallocate Chk_Devide_By_Zero
*/

		DECLARE @StrSQl as nvarchar(max)
		CREATE TABLE #Result
		( 
			Result numeric(18,2)
		)
				
		SET @StrSQl=''
		SELECT @StrSQl = COALESCE(@StrSQl+' ', ' ') + replace(Replace(Replace(Formula_Value,'}',''),'{',''),'&',' and ') from #Tbl_Formula	 order by Formula_Id --Added by nilesh patel on 09032015 	


PRINT @StrSQL
		
Declare @sSql as varchar(2000)
SET @sSql='
		BEGIN TRY
			SELECT '+ @StrSQL +' 
		END TRY

		BEGIN CATCH 
			SELECT 0
		END CATCH
		'

		insert into #Result 
		----modify  By Jignesh 28-02-2020-----
		---exec('Select '+ @StrSQL)
		exec(@sSql)
		---------- End -----------------
		
		select @Formula_amount=Result from #Result
		

		--Added By Ramiz on 30042016
		If @AD_Rounding = 1
		BEGIN
			SET @Formula_amount = ROUND(@Formula_amount,0)
		END
		--Ended By Ramiz on 30042016
		
		Drop table #Tbl_Formula
		Drop table #Result
		
		RETURN
		
	END Try
	Begin Catch
		DECLARE @AD_NAME AS VARCHAR(32)
		SELECT @AD_NAME= AD_NAME FROM T0050_AD_MASTER WITH (NOLOCK) WHERE AD_ID=@AD_ID
		PRINT	'Error in Calculating Formula Value for "' + @AD_NAME + '" : ' + ERROR_MESSAGE ( )   
		set @Formula_amount = 0
	End Catch


