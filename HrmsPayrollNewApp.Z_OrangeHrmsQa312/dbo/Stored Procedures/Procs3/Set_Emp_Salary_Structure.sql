

-- =============================================
-- Author:		<Author,,Falak>
-- ALTER date: <ALTER Date,,24-JAN-2011>
-- Description:	<Description,,Emp_Salary_Structure>
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Set_Emp_Salary_Structure] 
 @CMP_ID		NUMERIC
,@FROM_DATE		DATETIME
,@TO_DATE		DATETIME 
,@BRANCH_ID		NUMERIC   = 0
,@CAT_ID		NUMERIC  = 0
,@GRD_ID		NUMERIC = 0
,@TYPE_ID		NUMERIC  = 0
,@DEPT_ID		NUMERIC  = 0
,@DESIG_ID		NUMERIC = 0
,@EMP_ID		NUMERIC  = 0
,@CONSTRAINT	VARCHAR(MAX) = ''
,@REPORT_FOR    VARCHAR(50) = ''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	DECLARE @PAYEMENT VARCHAR(50) 
	DECLARE @TRANSACTION_ID NUMERIC
	
	SET @PAYEMENT = ''
	SET @TRANSACTION_ID=0
	
	 IF ISNULL(@PAYEMENT,'') = ''
		SET  @PAYEMENT = ''
	DECLARE @ROW_ID AS NUMERIC
	DECLARE @LABEL_NAME AS VARCHAR(100)
	DECLARE @TOTAL_ALLOWANCE AS NUMERIC(22,2) 
	DECLARE @IS_SEARCH AS VARCHAR(30)
	DECLARE @BASIC_SALARY AS NUMERIC(22,2)
	DECLARE @TOTAL_ALLOW AS NUMERIC (22,2)
	DECLARE @VALUE_STRING AS VARCHAR(250)
	DECLARE @AMOUNT AS NUMERIC (22,2)

	DECLARE @OTHER_ALLOW AS NUMERIC(22,2)
	DECLARE @CO_AMOUNT AS NUMERIC(22,2)
	DECLARE @TOTAL_DEDUCTION AS NUMERIC(22,2)
	DECLARE @OTHER_DEDU AS NUMERIC(22,2)
	DECLARE @LOAN AS NUMERIC(22,2)
	DECLARE @ADVANCE AS NUMERIC(22,2)
	DECLARE @NET_SALARY AS NUMERIC(22,2)
	DECLARE @REVENUE_AMT NUMERIC(10)
	DECLARE @LWF_AMT NUMERIC(10)
	DECLARE @PT AS NUMERIC(22,2)
	DECLARE @LWF AS NUMERIC(22,2)
	DECLARE @REVENUE AS NUMERIC(22,2)
	DECLARE @ALLOW_NAME AS VARCHAR(100)
	DECLARE @P_DAYS AS NUMERIC(22,2)
	DECLARE @A_DAYS AS NUMERIC(22,2)
	DECLARE @ACT_GROSS_SALARY AS NUMERIC(18,2)
	DECLARE @MONTH AS NUMERIC(18,0)
	DECLARE @YEAR AS NUMERIC(18,0)
	DECLARE @TDS NUMERIC(18,2)
	DECLARE @SETTL NUMERIC(22,2)
	--DECLARE @INCREMENT_ID NUMERIC
	
	CREATE table #TEMP_REPORT_LABEL
	(
		ROW_ID  NUMERIC(18, 0) NOT NULL,
		LABEL_NAME  VARCHAR(200) NOT NULL,
		INCOME_TAX_ID NUMERIC(18, 0) NULL,
		IS_ACTIVE	VARCHAR(1) NULL
	)
	
	CREATE table #TEMP_REPORT_LABEL_N
	(
		ROW_ID  NUMERIC(18, 0) NOT NULL,
		LABEL_NAME  VARCHAR(200) NOT NULL,
		INCOME_TAX_ID NUMERIC(18, 0) NULL,
		IS_ACTIVE	VARCHAR(1) NULL
	)
		
	CREATE table #TEMP_SALARY_MUSTER_REPORT		
	(
		EMP_ID NUMERIC(18, 0) NOT NULL,
		CMP_ID NUMERIC(18, 0) NOT NULL,
		BRANCH_ID NUMERIC(18,0),
		INCREMENT_ID NUMERIC(18,0), 
		TRANSACTION_ID NUMERIC(18, 0) NOT NULL,
		--MONTH NUMERIC(18, 0) NOT NULL,
		--YEAR NUMERIC(18, 0) NOT NULL,
		LABEL_NAME VARCHAR(200) NOT NULL,
		AMOUNT NUMERIC(22, 2) NULL,
		VALUE_STRING VARCHAR(250) NOT NULL,
		INCOME_TAX_ID NUMERIC(18, 0)  DEFAULT 0,
		ROW_ID NUMERIC(18, 0) NULL
	
	)
	
	CREATE NONCLUSTERED INDEX IX_SMR ON DBO.#TEMP_SALARY_MUSTER_REPORT
	(
		EMP_ID,CMP_ID,BRANCH_ID,INCREMENT_ID
	)
		
	IF @BRANCH_ID = 0
		SET @BRANCH_ID = NULL
	IF @CAT_ID = 0
		SET @CAT_ID = NULL	 
	IF @TYPE_ID = 0
		SET @TYPE_ID = NULL
	IF @DEPT_ID = 0
		SET @DEPT_ID = NULL
	IF @GRD_ID = 0
		SET @GRD_ID = NULL
	IF @EMP_ID = 0
		SET @EMP_ID = NULL
	IF @DESIG_ID = 0
		SET @DESIG_ID = NULL
		
		
	SET @MONTH = MONTH(@FROM_DATE)
	SET @YEAR = YEAR(@FROM_DATE)
	EXEC SET_EMP_SALARY_STRUCTURE_LABEL @CMP_ID,@FROM_DATE  ,@TO_DATE --@MONTH , @YEAR
	
	IF @REPORT_FOR = 'Label Record'
	BEGIN	
		SELECT * FROM #TEMP_REPORT_LABEL_N
		RETURN
	END
	
	CREATE table #EMP_CONS 
	 (      
		EMP_ID NUMERIC ,     
		BRANCH_ID NUMERIC,
		INCREMENT_ID NUMERIC
	 )     
	 
	EXEC SP_RPT_FILL_EMP_CONS  @CMP_ID,@FROM_DATE,@TO_DATE,@BRANCH_ID,@CAT_ID,@GRD_ID,@TYPE_ID,@DEPT_ID,@DESIG_ID ,@EMP_ID ,@CONSTRAINT ,0 ,0 ,0,0,0,0,0,0,3,0,0,0
	
	CREATE NONCLUSTERED INDEX IX_EMP_CONS_EMPID ON #Emp_Cons (EMP_ID);
	
	--Declare @Emp_Cons Table
	--	(
	--		Emp_ID	numeric
	--	)
	
	--if @Constraint <> ''
	--	begin
	--		Insert Into @Emp_Cons
	--		select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
	--	end
	--else 
	--	begin
	--		Insert Into @Emp_Cons

	--		select I.Emp_Id from T0095_Increment I inner join 
	--				( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment
	--				where Increment_Effective_date <= @To_Date
	--				and Cmp_ID = @Cmp_ID
	--				group by emp_ID  ) Qry on
	--				I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID
	--		Where Cmp_ID = @Cmp_ID 
	--		and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
	--		and Branch_ID = isnull(@Branch_ID ,Branch_ID)
	--		and Grd_ID = isnull(@Grd_ID ,Grd_ID)
	--		and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
	--		and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
	--		and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
	--		and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
	--		and I.Emp_ID in 
	--			( select Emp_Id from
	--			(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
	--			where cmp_ID = @Cmp_ID   and  
	--			(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
	--			or ( @To_Date  >= join_Date  and @To_Date <= left_date )
	--			or Left_date is null and @To_Date >= Join_Date)
	--			or @To_Date >= left_date  and  @From_Date <= left_date ) 
	--	end
	Declare @Cur_Emp_ID as numeric(18,0)
	Declare @Cur_Branch_ID as numeric(18,0)
	Declare @Cur_Increment_ID as numeric(18,0)
	set @Cur_Emp_ID = 0
	
	
	--DECLARE CUR_EMP CURSOR FOR
	--SELECT E.EMP_ID  FROM --T0100_Emp_Earn_Deduction SG INNER JOIN
	--T0080_EMP_MASTER E --ON sg.EMP_ID =e.EMP_ID 
	--INNER JOIN /*	EMP_OTHER_DETAIL eod ON e.EMP_ID = eod.EMP_ID Inner join*/ @Emp_Cons ec on E.Emp_ID = Ec.Emp_ID 
	--Inner join ( select T0095_Increment.Emp_Id ,Type_ID ,Grd_ID,Dept_ID,Desig_Id,Branch_ID,Cat_ID,Payment_Mode,Qry.Increment_ID from t0095_Increment inner join 
	--								( select max(Increment_ID) as Increment_ID , Emp_ID from t0095_Increment
	--								where Increment_Effective_date <= @To_Date
	--								and Cmp_ID = @Cmp_ID
	--								group by emp_ID  ) Qry
	--								on t0095_Increment.Emp_ID = Qry.Emp_ID and
	--								t0095_Increment.Increment_ID   = Qry.Increment_ID	
	--						where Cmp_ID = @Cmp_ID ) I_Q on 
	--				e.Emp_ID = I_Q.Emp_ID --and I_Q.For_Date = SG.For_Date
	--WHERE  E.Cmp_ID = @Cmp_ID 
	----AND Month(sg.Month_St_Date) = @MONTH AND Year(sg.Month_St_Date) = @YEAR And isnull(sg.is_FNF,0)=0
	--	--AND Payment_Mode LIKE isnull(@PAYEMENT,Payment_Mode)
	
	DECLARE CUR_EMP CURSOR FOR
			SELECT EC.EMP_ID,EC.BRANCH_ID,EC.INCREMENT_ID,IE.BASIC_SALARY,IE.GROSS_SALARY FROM #EMP_CONS EC 
			INNER JOIN T0095_INCREMENT IE WITH (NOLOCK) ON EC.INCREMENT_ID = IE.INCREMENT_ID
			INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.EMP_ID = EC.EMP_ID
	OPEN  CUR_EMP
	FETCH NEXT FROM CUR_EMP INTO @CUR_EMP_ID,@CUR_BRANCH_ID,@CUR_INCREMENT_ID,@BASIC_SALARY,@ACT_GROSS_SALARY
	WHILE @@FETCH_STATUS = 0
		BEGIN
						
						SET @ALLOW_NAME = ''
						SET @ROW_ID  = 0
						SET @LABEL_NAME  = ''
						SET @TOTAL_ALLOWANCE = 0
						SET @IS_SEARCH = ''
						--SET @BASIC_SALARY = 0
						SET @TOTAL_ALLOW = 0
						SET @VALUE_STRING = ''
						SET @AMOUNT = 0 
						SET @OTHER_ALLOW =0
						SET @CO_AMOUNT = 0
						SET @TOTAL_DEDUCTION =0
						SET @OTHER_DEDU =0
						SET @LOAN =0
						SET @ADVANCE =0
						SET @NET_SALARY =0
						SET @PT =0
						SET @LWF =0
						SET @REVENUE = 0
						SET @P_DAYS = 0
						SET @A_DAYS=0
						SET @REVENUE_AMT =0
						SET @LWF_AMT  =0
						--SET @ACT_GROSS_SALARY = 0
						SET @TDS=0
						SET @SETTL=0
						
					--select @P_Days = Present_Days + Holiday_Days , @Basic_Salary = Salary_Amount from Salary_Generation where Emp_ID = @Emp_ID and Month = @Month and Year = @Year
					--select @P_Days = isnull(Present_Days,0) ,@A_Days = isnull(Absent_Days,0),@TDS=isnull(M_IT_TAX,0), @Basic_Salary = Salary_Amount, 
					--@Act_Gross_salary = Actually_Gross_salary,@Settl = Settelement_Amount,@OTher_Allow = ISNULL(Other_Allow_Amount,0) 
					--from T0200_MONTHLY_SALARY where Emp_ID = @Emp_ID and Month(Month_st_date) = @Month and Year(Month_st_date) = @Year
					
					--select @Basic_salary = Basic_Salary,@Act_Gross_salary = Gross_Salary  from T0095_INCREMENT where Emp_ID = @Emp_ID and 
					--	Increment_Effective_Date = (select MAX(Increment_Effective_Date) from T0095_INCREMENT where Emp_ID = @Emp_ID )
					
					--select @Basic_salary = Basic_Salary,@Act_Gross_salary = Gross_Salary, @increment_id = t0095_Increment.Increment_ID From t0095_Increment inner join 
					--				( select max(Increment_ID) as Increment_ID , Emp_ID from t0095_Increment
					--				where Increment_Effective_date <= @To_Date
					--				and Cmp_ID = @Cmp_ID And Emp_ID = @Emp_ID
					--				group by emp_ID  ) Qry
					--				on t0095_Increment.Emp_ID = Qry.Emp_ID and
					--				t0095_Increment.Increment_ID   = Qry.Increment_ID	
					--		where Cmp_ID = @Cmp_ID And qry.Emp_ID  = @Emp_ID
					
					/*INSERT INTO #Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'P Days', @P_Days,'',2)
					INSERT INTO #Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'A Days', @A_Days,'',3)
					*/
				/*	INSERT INTO #Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Gross', @Act_Gross_salary,'',4)*/

					INSERT INTO #TEMP_SALARY_MUSTER_REPORT
					(EMP_ID, CMP_ID,BRANCH_ID,INCREMENT_ID, TRANSACTION_ID,  LABEL_NAME, AMOUNT, VALUE_STRING,ROW_ID)
					VALUES     (@CUR_EMP_ID, @CMP_ID,@CUR_BRANCH_ID,@CUR_INCREMENT_ID, @TRANSACTION_ID,  'Basic', @BASIC_SALARY,'',5)
					/*
					INSERT INTO #Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Settl', @Settl,'',6)
					
					
					INSERT INTO #Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Other', @OTher_Allow,'',7)
					*/
					DECLARE CUR_LABEL CURSOR FOR 
						SELECT LABEL_NAME ,ROW_ID FROM #TEMP_REPORT_LABEL WHERE ROW_ID > 4
					OPEN CUR_LABEL
								FETCH NEXT FROM CUR_LABEL INTO @LABEL_NAME ,@ROW_ID
							WHILE @@FETCH_STATUS = 0
							BEGIN
							
								INSERT INTO #TEMP_SALARY_MUSTER_REPORT
								(EMP_ID, CMP_ID,BRANCH_ID,INCREMENT_ID, TRANSACTION_ID, LABEL_NAME, AMOUNT, VALUE_STRING,ROW_ID)
								VALUES     (@CUR_EMP_ID, @CMP_ID,@CUR_BRANCH_ID,@CUR_INCREMENT_ID, @TRANSACTION_ID, @LABEL_NAME, 0,'',@ROW_ID)
							
								FETCH NEXT FROM CUR_LABEL INTO @LABEL_NAME,@ROW_ID
							END
					CLOSE CUR_LABEL
					DEALLOCATE CUR_LABEL
		
					SET @LABEL_NAME  = ''
					

					DECLARE CUR_ALLOW   CURSOR FOR
						SELECT AD_SORT_NAME ,E_AD_AMOUNT FROM T0100_EMP_EARN_DEDUCTION EAD WITH (NOLOCK) INNER JOIN
							T0050_AD_MASTER WITH (NOLOCK) ON EAD.AD_ID = T0050_AD_MASTER.AD_ID
							AND EAD.CMP_ID = T0050_AD_MASTER.CMP_ID
							AND EAD.EMP_ID  = @CUR_EMP_ID
						WHERE 
						EAD.CMP_ID = @CMP_ID 
						AND  EAD.INCREMENT_ID = @Cur_Increment_ID --@INCREMENT_ID comment by chetan 300916
						--AND MONTH(EAD.FOR_DATE) =  @MONTH AND YEAR(MAD.FOR_DATE) = @YEAR
						AND ISNULL(T0050_AD_MASTER.AD_NOT_EFFECT_SALARY,0) = 0 AND AD_ACTIVE = 1 AND AD_FLAG = 'I'
					OPEN CUR_ALLOW
								FETCH NEXT FROM CUR_ALLOW  INTO @ALLOW_NAME ,@AMOUNT
							WHILE @@FETCH_STATUS = 0
							BEGIN
								SELECT @ROW_ID = ROW_ID FROM #TEMP_REPORT_LABEL WHERE LABEL_NAME LIKE @ALLOW_NAME 
 								UPDATE    #TEMP_SALARY_MUSTER_REPORT
 								SET         EMP_ID = @CUR_EMP_ID, CMP_ID = @CMP_ID, 
 											BRANCH_ID = @CUR_BRANCH_ID,
 											INCREMENT_ID = @CUR_INCREMENT_ID,
 											TRANSACTION_ID = @TRANSACTION_ID,-- MONTH = @MONTH, YEAR = @YEAR, 
 											AMOUNT = @AMOUNT, VALUE_STRING = ''
 								WHERE   LABEL_NAME = @ALLOW_NAME AND ROW_ID = @ROW_ID                  
 									AND EMP_ID = @CUR_EMP_ID  
								FETCH NEXT FROM CUR_ALLOW  INTO @ALLOW_NAME,@AMOUNT
							END
					CLOSE CUR_ALLOW
					DEALLOCATE CUR_ALLOW
				
					
					
					DECLARE CUR_REIMB   CURSOR FOR
 						SELECT DISTINCT RIMB_NAME FROM T0100_RIMBURSEMENT_DETAIL WITH (NOLOCK) INNER JOIN
						T0055_REIMBURSEMENT WITH (NOLOCK) ON T0055_REIMBURSEMENT.RIMB_ID = T0100_RIMBURSEMENT_DETAIL.RIMB_ID AND
						T0055_REIMBURSEMENT.CMP_ID = T0055_REIMBURSEMENT.CMP_ID
						WHERE T0100_RIMBURSEMENT_DETAIL.CMP_ID =@CMP_ID
						AND MONTH(T0100_RIMBURSEMENT_DETAIL.FOR_DATE) = @MONTH
						AND YEAR(T0100_RIMBURSEMENT_DETAIL.FOR_DATE) = @YEAR
						AND T0100_RIMBURSEMENT_DETAIL.EMP_ID = @CUR_EMP_ID
					OPEN CUR_REIMB
							FETCH NEXT FROM CUR_REIMB INTO @ALLOW_NAME
						WHILE @@FETCH_STATUS = 0
						BEGIN	
						
							SELECT @ROW_ID = ROW_ID FROM #TEMP_REPORT_LABEL WHERE LABEL_NAME LIKE @ALLOW_NAME 
							UPDATE    #TEMP_SALARY_MUSTER_REPORT
							SET              EMP_ID = @CUR_EMP_ID, CMP_ID = @CMP_ID,BRANCH_ID = @CUR_BRANCH_ID,INCREMENT_ID = @CUR_INCREMENT_ID,
											  TRANSACTION_ID = @TRANSACTION_ID, --MONTH = @MONTH, YEAR = @YEAR, 
											 AMOUNT = @AMOUNT, VALUE_STRING = '' 
							WHERE   LABEL_NAME = @ALLOW_NAME AND ROW_ID = @ROW_ID                    
									AND EMP_ID = @CUR_EMP_ID
									
							FETCH NEXT FROM CUR_REIMB INTO @ALLOW_NAME
						END
					 CLOSE CUR_REIMB
					 DEALLOCATE CUR_REIMB
					
						
/*
						select @Total_Allowance = Allow_Amount   
							--@CO_Amount = isnull(Extra_Days_Amount,0)
						from T0200_Monthly_salary where Emp_ID = @Emp_ID and Month(MOnth_St_Date) = @Month and Year(MOnth_St_Date) = @Year
					 	

						/*select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'Oth A'		

						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year,
											   Amount = @Other_Allow, Value_String = ''
						where   Label_Name = 'Oth A' and Row_id = @row_Id                    
								and Emp_ID = @Emp_ID*/

						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'CO A'		

						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year,
											   Amount = @CO_Amount, Value_String = ''
						where   Label_Name = 'CO A' and Row_id = @row_Id                    
								and Emp_ID = @Emp_ID
*/								
						SELECT @ROW_ID = ROW_ID FROM #TEMP_REPORT_LABEL WHERE LABEL_NAME LIKE 'GROSS'

						UPDATE    #TEMP_SALARY_MUSTER_REPORT
							SET          EMP_ID = @CUR_EMP_ID, 
										 CMP_ID = @CMP_ID,
										 BRANCH_ID= @CUR_BRANCH_ID,
										 INCREMENT_ID = @CUR_INCREMENT_ID, 
										 TRANSACTION_ID = @TRANSACTION_ID,-- MONTH = @MONTH, YEAR = @YEAR, 
										 AMOUNT = @ACT_GROSS_SALARY--@TOTAL_ALLOWANCE+@BASIC_SALARY+ISNULL(@SETTL,0)+ISNULL(@OTHER_ALLOW,0)+ISNULL(@CO_AMOUNT,0), VALUE_STRING = ''
						WHERE     (LABEL_NAME = 'GROSS') AND (ROW_ID = @ROW_ID) AND EMP_ID = @CUR_EMP_ID

						/*select @Amount = M_Ad_Calculated_Amount From t0210_monthly_ad_detail where Emp_Id =@Emp_ID and Month(For_Date)=  @month and YEar(For_Date) = @Year and Ad_ID =2
						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'PF Salary'	*/	
					
						
						/*UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year,
											   Amount = @Amount, Value_String = ''
						where   Label_Name = 'PF Salary' and Row_id = @row_Id                
								and Emp_ID = @Emp_ID
								*/
						set @Amount =0

						/*select @Amount = M_AD_Calculated_Amount From t0210_monthly_ad_detail where Emp_Id = @Emp_ID and Month(For_Date)=  @month and YEar(For_Date) = @Year and Ad_ID =3 and M_Ad_Amount >0
						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'ESIC Salary'
						
						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year,
											   Amount = @Amount, Value_String = ''
						where   Label_Name = 'ESIC Salary' and Row_id = @row_Id                    
								and Emp_ID = @Emp_ID*/		
							
													
					DECLARE CUR_DEDU   CURSOR FOR
						SELECT AD_SORT_NAME ,E_AD_AMOUNT FROM T0100_EMP_EARN_DEDUCTION MAD WITH (NOLOCK)
						INNER JOIN T0050_AD_MASTER ADM WITH (NOLOCK) ON MAD.AD_ID = ADM.AD_ID	AND MAD.CMP_ID = ADM.CMP_ID
							AND MAD.EMP_ID  = @CUR_EMP_ID
						WHERE 
						MAD.CMP_ID = @CMP_ID AND MAD.INCREMENT_ID = @CUR_INCREMENT_ID --AND MONTH(MAD.FOR_DATE) =  @MONTH AND YEAR(MAD.FOR_DATE) = @YEAR
						AND AD_ACTIVE = 1 
						AND AD_FLAG = 'D' 
						AND ISNULL(ADM.AD_NOT_EFFECT_SALARY,0)=0
					OPEN CUR_DEDU
								FETCH NEXT FROM CUR_DEDU  INTO @ALLOW_NAME ,@AMOUNT
							WHILE @@FETCH_STATUS = 0
							BEGIN
								SELECT @ROW_ID = ROW_ID FROM #TEMP_REPORT_LABEL WHERE LABEL_NAME LIKE @ALLOW_NAME 
									UPDATE    #TEMP_SALARY_MUSTER_REPORT
										SET  EMP_ID = @CUR_EMP_ID, 
											 CMP_ID = @CMP_ID, 
											 BRANCH_ID = @CUR_BRANCH_ID,
											 INCREMENT_ID = @CUR_INCREMENT_ID, 
											 TRANSACTION_ID = @TRANSACTION_ID,-- MONTH = @MONTH, YEAR = @YEAR, 
											 AMOUNT = @AMOUNT, 
											 VALUE_STRING = ''
									WHERE     (LABEL_NAME = @ALLOW_NAME) AND (ROW_ID = @ROW_ID) AND EMP_ID = @CUR_EMP_ID
									
								FETCH NEXT FROM CUR_DEDU INTO @ALLOW_NAME,@AMOUNT
							END
					CLOSE CUR_DEDU
					DEALLOCATE CUR_DEDU		

						--select @Total_Deduction = Total_Dedu_Amount ,@PT = PT_Amount ,@Loan =  ( Loan_Amount + Loan_Intrest_Amount ) 
						--		,@Advance =  Advance_Amount ,@Net_Salary = Net_Amount ,@Revenue_Amt =Revenue_amount,@LWF_Amt =LWF_Amount,@Other_Dedu=Other_Dedu_Amount
						--from T0200_Monthly_salary where Emp_ID = @Emp_ID and Month(Month_St_Date) = @Month and Year(Month_St_Date) = @Year
						--Select @Other_Dedu  = 0
						
					--	set @Loan = @Loan + @Advance

		--				select @Row_ID = Row_ID from Temp_report_label where Label_Name like 'Other Dedu'

		--				INSERT INTO Temp_Salary_Muster_Report


		--						   (Emp_ID, Company_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id)
		--				VALUES     (@Emp_ID, @Company_ID, @Transaction_ID, @Month, @Year, 'Other Dedu', @Other_Dedu,'',@Row_ID)
						/*
						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'PT'
						
						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @PT, 
											  Value_String = ''
						WHERE     (Label_Name = 'PT') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
								
						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'Loan'
						
						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Loan, 
											  Value_String = ''
						WHERE     (Label_Name = 'Loan') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
								
								
								select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'Advnc'
						
						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Advance, 
											  Value_String = ''
						WHERE     (Label_Name = 'Advnc') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
						
						
						if @Revenue_Amt >0
							begin
								select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'Revenue'
								
								UPDATE    #Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Revenue_Amt, 
													  Value_String = ''
								WHERE     (Label_Name = 'Revenue') AND (Row_id = @Row_ID)
										and Emp_ID = @Emp_ID
							end
						if @LWF_amt > 0
							begin
								select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'LWF'
								
								UPDATE    #Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @lwf_Amt, 
													  Value_String = ''
								WHERE     (Label_Name = 'LWF') AND (Row_id = @Row_ID)
										and Emp_ID = @Emp_ID
							end							
								
					
						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'TDS'
						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @TDS, 
											  Value_String = ''
						WHERE     (Label_Name = 'TDS') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
						
						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'Oth De'
						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Other_Dedu, 
											  Value_String = ''
						WHERE     (Label_Name = 'Oth De') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
						
						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'Dedu'
						
						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
											  Amount = @Total_Deduction, Value_String = ''
						WHERE     (Label_Name = 'Dedu') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID	
						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'Net'
						
						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Net_Salary, 
											  Value_String = ''
						WHERE     (Label_Name = 'Net') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
						*/
			FETCH NEXT FROM CUR_EMP INTO @CUR_EMP_ID,@CUR_BRANCH_ID,@CUR_INCREMENT_ID,@BASIC_SALARY,@ACT_GROSS_SALARY
		END
	CLOSE CUR_EMP
	DEALLOCATE CUR_EMP	
	
	
	-- Changed By Ali 22112013 EmpName_Alias
	SELECT TSMR.* ,ISNULL(E.EMPNAME_ALIAS_SALARY,E.EMP_FULL_NAME) AS EMP_FULL_NAME,E.EMP_CODE/*CAST( E.EMP_CODE AS VARCHAR) + ' - '+E.EMP_FULL_NAME AS EMP_FULL_NAME*/, IE.DEPT_ID,CMP_NAME,CMP_ADDRESS,
	IE.INC_BANK_AC_NO,GRD_NAME,E.DATE_OF_JOIN ,DESIG_NAME ,DEPT_NAME ,BRANCH_NAME ,TYPE_NAME,COMP_NAME ,BRANCH_ADDRESS ,IE.BRANCH_ID AS BRANCH_ID 
	,E.ALPHA_EMP_CODE,E.EMP_FIRST_NAME   --ADDED JIMIT 30052015
		FROM #TEMP_SALARY_MUSTER_REPORT TSMR 
		INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON TSMR.EMP_ID = E.EMP_ID 
		INNER JOIN T0095_INCREMENT IE WITH (NOLOCK) ON IE.INCREMENT_ID = TSMR.INCREMENT_ID
		INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID=CM.CMP_ID
		--( select I.Emp_Id ,Grd_ID,DEsig_ID ,Dept_ID,Inc_Bank_Ac_no from t0095_Increment I inner join 
		--			( select max(Increment_ID) as Increment_ID, Emp_ID from t0095_Increment
		--			where Increment_Effective_date <= @To_Date
		--			and Cmp_ID = @Cmp_ID
		--			group by emp_ID  ) Qry on
		--			I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID )Inc_Qry on 
		--E.Emp_ID = Inc_Qry.Emp_ID 
		LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON IE.DEPT_ID = DM.DEPT_ID  
		LEFT OUTER JOIN T0040_DESIGNATION_MASTER DSM WITH (NOLOCK) ON IE .DESIG_ID = DSM.DESIG_ID 
		LEFT OUTER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON IE .GRD_ID = GM.GRD_ID 
		LEFT OUTER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON IE.BRANCH_ID = BM.BRANCH_ID 
		LEFT OUTER JOIN T0040_TYPE_MASTER TM WITH (NOLOCK) ON IE.TYPE_ID = TM.TYPE_ID 
		
		ORDER BY TSMR.ROW_ID 
	
	
	
	RETURN




