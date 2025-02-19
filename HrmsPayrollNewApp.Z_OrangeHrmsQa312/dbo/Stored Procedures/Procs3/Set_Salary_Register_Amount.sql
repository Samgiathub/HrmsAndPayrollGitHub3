



--Created By Girish On 07-AUG-2009
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[Set_Salary_Register_Amount]
 @Cmp_ID		numeric
,@From_Date		datetime
,@To_Date		datetime 
,@Branch_ID		numeric   = 0
,@Cat_ID		numeric  = 0
,@Grd_ID		numeric = 0
,@Type_ID		numeric  = 0
,@Dept_ID		numeric  = 0
,@Desig_ID		numeric = 0
,@Emp_ID		numeric  = 0
,@Constraint	varchar(MAX) = ''
,@Sal_Type    numeric
,@Salary_Cycle_id numeric = 0
,@Segment_ID Numeric = 0 -- Added By gadriwala 21082013
,@Vertical_ID Numeric = 0 -- Added By gadriwala 21082013
,@SubVertical_ID Numeric = 0 -- Added By gadriwala 21082013
,@subBranch_ID Numeric = 0 -- Added By gadriwala 21082013

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	Declare @Payement varchar(50) 
	Declare @Transaction_ID Numeric
	
	set @Payement = ''
	set @Transaction_ID=0
	
	 if isnull(@Payement,'') = ''
		set  @Payement = ''
	Declare @Row_id as numeric
	Declare @Label_Name as varchar(100)
	Declare @Total_Allowance as numeric(22,2) 
	Declare @Gross_Salary as numeric(22,2) 
	Declare @Is_Search as varchar(30)
	Declare @Basic_salary as numeric(22,2)
	Declare @Total_Allow as numeric (22,2)
	declare @Value_String as varchar(250)
	Declare @Amount as numeric (22,2)

	Declare @OTher_Allow as numeric(22,2)
	Declare @CO_Amount as numeric(22,2)
	Declare @Leave_Amount as numeric(22,2)
	Declare @Total_Deduction as numeric(22,2)
	Declare @Other_Dedu as numeric(22,2)
	Declare @Late_Deduction as numeric(22,2)
	Declare @Loan as numeric(22,2)
	Declare @Advance as numeric(22,2)
	Declare @Net_Salary as numeric(22,2)
	Declare @Revenue_amt numeric(10)
	Declare @Lwf_amt numeric(10)
	Declare @PT as numeric(22,2)
	Declare @LWF as numeric(22,2)
	Declare @Revenue as numeric(22,2)
	Declare @Allow_Name as varchar(100)
	Declare @P_Days as numeric(22,2)
	Declare @A_Days as numeric(22,2)
	Declare @Act_Gross_salary as numeric(18,2)
	DEclare @month as numeric(18,0)
	Declare @Year as numeric(18,0)
	DEclare @TDS numeric(18,2)
	Declare @Settl numeric(22,2)
	Declare @Actual_CTC_Amount as numeric(22,2) --Hardik 20/09/2011
	Declare @Temp_month Numeric (2,0)
	Declare @Temp_Year Numeric (4,0)
	Declare @Deficit_Amt Numeric(18,2) -- Added by Hardik 14/11/2013 for Pakistan
	Declare @Uniform_Installment as numeric(18,2)
	Declare @Uniform_Refund_Installment as numeric(18,2)
	
	set @Actual_CTC_Amount = 0
	
	CREATE table #Temp_report_Label
	(
	Row_ID  numeric(18, 0) NOt null,
	Label_Name  varchar(200) not null,
	Income_Tax_ID numeric(18, 0) null,
	Is_Active	varchar(1) null
	)
		
	CREATE table #Temp_Salary_Muster_Report		
	(
	Emp_ID numeric(18, 0) Not Null,
	Cmp_ID numeric(18, 0) Not Null,
	Transaction_ID numeric(18, 0) Not Null,
	Month numeric(18, 0) Not Null,
	Year numeric(18, 0) Not Null,
	Label_Name varchar(200) Not Null,
	Amount numeric(18, 2) null,
	Value_String varchar(250) Not Null,
	INCOME_TAX_ID numeric(18, 0)  Default 0,
	Row_id numeric(18, 0) Null
	
	)
		
	if @Branch_ID = 0
		set @Branch_ID = null
	if @Cat_ID = 0
		set @Cat_ID = null
		 
	if @Type_ID = 0
		set @Type_ID = null
	if @Dept_ID = 0
		set @Dept_ID = null
	if @Grd_ID = 0
		set @Grd_ID = null
	if @Emp_ID = 0
		set @Emp_ID = null
		
	If @Desig_ID = 0
		set @Desig_ID = null
		--Added By Gadriwala Muslim 21-8-2013 - Start
		if @Salary_Cycle_id = 0
		set @Salary_Cycle_id = NULL
		
	IF @Segment_ID = 0 
		SET @Segment_ID = Null
	IF @Vertical_ID = 0 
		SEt @Vertical_ID = Null
	IF @SubVertical_ID = 0 
		Set @SubVertical_ID  = Null
	if @subBranch_ID = 0
		set @subBranch_ID = Null
	
	--Added By Gadriwala Muslim 21-8-2013 - End
	Declare @Sal_St_Date   Datetime    
	Declare @Sal_end_Date   Datetime  
    
       
    CREATE TABLE #Emp_Cons 
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )   
	 
	 EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,@Sal_Type ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id ,0,0,@SalScyle_Flag = 1
	
	
		SELECT TOP 1 @Sal_St_Date  = Sal_st_Date 
		FROM T0040_GENERAL_SETTING GS WITH (NOLOCK)
			INNER JOIN #Emp_Cons EC ON GS.Branch_ID = EC.Branch_ID
		WHERE cmp_ID = @cmp_ID    
		  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING GSE WITH (NOLOCK) INNER JOIN #Emp_Cons ECS ON GSE.Branch_ID = ECS.Branch_ID where For_Date <=@to_date and Cmp_ID = @Cmp_ID)   
							
 if isnull(@Sal_St_Date,'') = ''    
	begin    
	   set @From_Date  = @From_Date     
	   set @To_Date = @To_Date    
	end     
 else if day(@Sal_St_Date) = 1 --and month(@Sal_St_Date)=1    
	begin    
	   set @From_Date  = @From_Date     
	   set @To_Date = @To_Date    
	end     
 else if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1    
	begin    
	   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
	   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))
	   set @From_Date = @Sal_St_Date
	   Set @To_Date = @Sal_end_Date   
	End 	
		
	set @Temp_month = month(@To_Date)
	set @Temp_Year = Year(@To_Date)
	
	set @month = month(@from_date)
	set @Year = Year(@From_date)
	
	
	--ADJUSTING LABLES IN SALARY REGISTER  
	EXEC Set_Salary_Register_Lable @Cmp_ID ,@Temp_month , @Temp_Year
	
		Declare @GatePass_Deduct_Days numeric(18,2) -- Added by Gadriwala Muslim 09012015
		Declare @GatePass_Amount numeric(18,2) -- Added by Gadriwala Muslim 09012015
	
	DECLARE CUR_EMP CURSOR FOR
		--COMMENTED BY RAMIZ ON LABH-PANCHAM 2018--
		/*
		SELECT sg.EMP_ID  
		FROM T0200_MONTHLY_SALARY SG
			INNER JOIN	T0080_EMP_MASTER E ON sg.EMP_ID =e.EMP_ID 
			 /*	EMP_OTHER_DETAIL eod ON e.EMP_ID = eod.EMP_ID Inner join*/
			INNER JOIN #Emp_Cons ec on E.Emp_ID = Ec.Emp_ID 
			INNER JOIN ( select T0095_Increment.Emp_Id ,Type_ID ,Grd_ID,Dept_ID,Desig_Id,Branch_ID,Cat_ID,Payment_Mode
						 from t0095_Increment 
							inner join 
									( 
										select max(Increment_ID) as Increment_ID , Emp_ID from t0095_Increment
										where Increment_Effective_date <= @To_Date
										and Cmp_ID = @Cmp_ID
										group by emp_ID
									) Qry on t0095_Increment.Emp_ID = Qry.Emp_ID and t0095_Increment.Increment_ID = Qry.Increment_ID	
						where Cmp_ID = @Cmp_ID 
						) I_Q on e.Emp_ID = I_Q.Emp_ID
		WHERE  sg.Cmp_ID = @Cmp_ID AND Month(sg.Month_St_Date) = @MONTH AND Year(sg.Month_St_Date) = @YEAR And isnull(sg.is_FNF,0)=0
			--AND Payment_Mode LIKE isnull(@PAYEMENT,Payment_Mode)
			*/
		--SO BIG QUERY , BUT WHY ??? 	--
		
		SELECT MS.EMP_ID  
		FROM T0200_MONTHLY_SALARY MS WITH (NOLOCK)
			INNER JOIN #Emp_Cons ec on EC.Emp_ID = MS.Emp_ID
		WHERE  MS.Cmp_ID = @Cmp_ID AND Month(MS.Month_St_Date) = @MONTH AND Year(MS.Month_St_Date) = @YEAR And isnull(MS.is_FNF,0)=0
			
	OPEN  CUR_EMP
	FETCH NEXT FROM CUR_EMP INTO @EMP_ID
	WHILE @@FETCH_STATUS = 0
		BEGIN
						
						SET @Allow_Name = ''
						SET @Row_id  = 0
						SET @Label_Name  = ''
						SET @Total_Allowance = 0
						set @Gross_Salary=0
						SET @Is_Search = ''
						SET @Basic_salary = 0
						SET @Total_Allow = 0
						SET @Value_String = ''
						SET @Amount = 0 
						SET @OTher_Allow =0
						set @CO_Amount = 0
						set @Leave_Amount = 0
						SET @Total_Deduction =0
						SET @Other_Dedu =0
						SET @Late_Deduction = 0
						SET @Loan =0
						SET @Advance =0
						SET @Net_Salary =0
						SET @PT =0
						SET @LWF =0
						SET @Revenue = 0
						set @P_Days = 0
						Set @A_Days=0
						set @Revenue_amt =0
						set @Lwf_amt  =0
						set @Act_Gross_salary = 0
						set @TDS=0
						set @Settl=0
						Set @Deficit_Amt = 0
						set @GatePass_Deduct_Days = 0
						set @GatePass_Amount = 0
						set @Uniform_Installment = 0
						set @Uniform_Refund_Installment = 0 
					
					If @Sal_Type = 0	
						Begin
							--select @P_Days = Present_Days + Holiday_Days , @Basic_Salary = Salary_Amount from Salary_Generation where Emp_ID = @Emp_ID and Month = @Month and Year = @Year
							select @P_Days = isnull(Present_Days,0) ,@A_Days = isnull(Absent_Days,0),@TDS=isnull(M_IT_TAX,0), @Basic_Salary = (isnull(Salary_Amount,0) + isnull(Arear_Basic,0) + isnull(Basic_Salary_Arear_cutoff,0)) , @Act_Gross_salary = Actually_Gross_salary,@Settl = Settelement_Amount,@OTher_Allow = ISNULL(Other_Allow_Amount,0), @Total_Allowance = Allow_Amount, @Gross_Salary = Gross_Salary, @Leave_Amount = Leave_Salary_Amount ,@GatePass_Deduct_Days = ISNULL(GatePass_Deduct_Days,0),@GatePass_Amount = ISNULL(GatePass_Amount,0) -- Added by Gadriwala Muslim 10112014  
							from T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID = @Emp_ID and Month(Month_st_date) = @Month and Year(Month_st_date) = @Year
							
						End
					Else
						Begin
							select @P_Days = isnull(S_Sal_Cal_Days,0) ,@A_Days = 0,@TDS=isnull(S_M_IT_TAX,0), @Basic_Salary = S_Salary_Amount, @Act_Gross_salary = S_Actually_Gross_salary,@Settl = 0,@OTher_Allow = ISNULL(S_Other_Allow_Amount,0),@Total_Allowance = S_Allow_Amount, @Leave_Amount = 0 
							from dbo.T0201_MONTHLY_SALARY_SETT WITH (NOLOCK) where Emp_ID = @Emp_ID and Month(S_Month_st_date) = @Month and Year(S_Month_st_date) = @Year 
						End

					 select @Actual_CTC_Amount = Isnull(CTC,0) from t0095_Increment WITH (NOLOCK) inner join 
									( select max(Increment_ID) as Increment_ID , Emp_ID from t0095_Increment WITH (NOLOCK)
									where Increment_Effective_date <= @To_Date
									and Cmp_ID = @Cmp_ID And Emp_ID = @Emp_ID
									group by emp_ID  ) Qry
									on t0095_Increment.Emp_ID = Qry.Emp_ID and
									t0095_Increment.Increment_ID   = Qry.Increment_ID	
							where Cmp_ID = @Cmp_ID And qry.Emp_ID  = @Emp_ID
										
					INSERT INTO #Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Temp_month, @Temp_Year, 'P Days', @P_Days,'',2)
					INSERT INTO #Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Temp_month, @Temp_Year, 'A Days', @A_Days,'',3)
					
				/*	INSERT INTO #Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Gross', @Act_Gross_salary,'',4)*/

					

		--Hardik 20/09/2011
		--Actual CTC column added for Jhaveri version.. Whenever give version to jhaveri remove the below comments
		
					/*INSERT INTO #Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'CTC', @Actual_CTC_Amount,'',4)*/

					INSERT INTO #Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Temp_month, @Temp_Year, 'Basic', @Basic_Salary,'',5)
					
					INSERT INTO #Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Temp_month, @Temp_Year, 'Settl', @Settl,'',6)
					
					
					INSERT INTO #Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Temp_month, @Temp_Year, 'Other', @OTher_Allow,'',7)


					Declare Cur_Label cursor for 
					SELECT Label_Name ,Row_ID FROM #TEMP_REPORT_LABEL where Row_ID > 7
					open Cur_label
					fetch next from Cur_label into @Label_Name ,@Row_ID
					while @@fetch_Status = 0
						begin
							INSERT INTO #Temp_Salary_Muster_Report
							(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id)
							VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Temp_month, @Temp_Year, @Label_Name, 0,'',@Row_ID)
							fetch next from Cur_label into @Label_Name,@Row_ID
						end
					close Cur_Label
					deallocate Cur_Label


					set @Label_Name  = ''
					
					

					declare Cur_Allow   cursor for
						select Ad_Sort_Name ,(isnull(M_Ad_Amount,0) + isnull(M_Arear_Amount,0) + isnull(M_Arear_Amount_cutoff,0)) as M_Ad_Amount  
						from t0210_monthly_ad_detail MAD WITH (NOLOCK) inner join
							t0050_ad_master WITH (NOLOCK) on MAD.Ad_Id = t0050_ad_master.Ad_ID
							and MAD.Cmp_ID = t0050_ad_master.Cmp_Id
							and MAD.Emp_ID  = @Emp_ID 
						where 
						MAD.Cmp_ID = @Cmp_ID and month(MAD.For_Date) =  @Month and Year(MAD.For_Date) = @Year
						and isnull(t0050_ad_master.Ad_Not_Effect_Salary,0) = 0 and Ad_Active = 1 and AD_Flag = 'I'
						and Sal_Type = @Sal_Type
					open cur_allow
					fetch next from cur_allow  into @Allow_Name ,@Amount
					while @@fetch_status = 0
						begin
							
							select @Row_ID = Row_ID from #Temp_report_label where Label_Name like @Allow_Name 

 							UPDATE    #Temp_Salary_Muster_Report
 							SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Temp_month, Year = @Temp_Year, 
 												  Amount = @Amount, Value_String = ''
 							where   Label_Name = @Allow_Name and Row_id = @row_Id                  
 									and Emp_ID = @Emp_ID  
							fetch next from cur_allow  into @Allow_Name,@Amount
							
						end
					close cur_Allow
					deallocate Cur_Allow
					
					
					
					declare CUR_REIMB   cursor for
 						SELECT DISTINCT RIMB_NAME FROM T0100_RIMBURSEMENT_DETAIL WITH (NOLOCK) INNER JOIN
						T0055_REIMBURSEMENT WITH (NOLOCK) ON T0055_REIMBURSEMENT.RIMB_ID = T0100_RIMBURSEMENT_DETAIL.RIMB_ID AND
						T0055_REIMBURSEMENT.Cmp_ID = T0055_REIMBURSEMENT.Cmp_ID
						WHERE T0100_RIMBURSEMENT_DETAIL.Cmp_ID =@Cmp_ID
						AND month(T0100_RIMBURSEMENT_DETAIL.For_Date) = @MONTH
						AND year(T0100_RIMBURSEMENT_DETAIL.For_Date) = @YEAR
						AND T0100_RIMBURSEMENT_DETAIL.EMP_ID = @EMP_ID
					open CUR_REIMB
					fetch next from CUR_REIMB into @Allow_Name
					while @@fetch_status = 0
						begin
							
							select @Row_ID = Row_ID from #Temp_report_label where Label_Name like @Allow_Name 

							UPDATE    #Temp_Salary_Muster_Report
							SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Temp_month, Year = @Temp_Year, 
											 Amount = @Amount, Value_String = '' 
							where   Label_Name = @Allow_Name and Row_id = @row_Id                    
									and Emp_ID = @Emp_ID
							fetch next from CUR_REIMB into @Allow_Name,@AMOUNT
						end
					close CUR_REIMB
					deallocate CUR_REIMB
						

					 	
						/*select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'Oth A'		

						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year,
											   Amount = @Other_Allow, Value_String = ''
						where   Label_Name = 'Oth A' and Row_id = @row_Id                    
								and Emp_ID = @Emp_ID*/

						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'CO A'								

						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Temp_month, Year = @Temp_Year,
											   Amount = @CO_Amount, Value_String = ''
						where   Label_Name = 'CO A' and Row_id = @row_Id                    
								and Emp_ID = @Emp_ID
					-------add by hasmukh for leave salary amount 20042012--------------	
						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'Leave Amt'		
						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Temp_month, Year = @Temp_Year,
											   Amount = @Leave_Amount, Value_String = ''
						where   Label_Name = 'Leave Amt' and Row_id = @row_Id                    
								and Emp_ID = @Emp_ID
					-------------End hasmukh 20042012
								
						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'Gross'

						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Temp_month, Year = @Temp_Year, 
											 -- Amount = @Total_Allowance+@Basic_Salary+isnull(@Settl,0)+ISNULL(@OTher_Allow,0)+isnull(@CO_Amount,0) + isnull(@Leave_Amount,0)
											  Amount = case when @Sal_Type =0 then  @Gross_Salary else @Total_Allowance+@Basic_Salary+isnull(@Settl,0)+ISNULL(@OTher_Allow,0)+isnull(@CO_Amount,0) + isnull(@Leave_Amount,0) end
											  , Value_String = ''
						WHERE     (Label_Name = 'Gross') AND (Row_id = @Row_ID)
								  and Emp_ID = @Emp_ID

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

								
					declare Cur_Dedu   cursor for
						select Ad_Sort_Name ,(isnull(M_Ad_Amount,0) + isnull(M_Arear_Amount,0) + isnull(M_Arear_Amount_cutoff,0)) as M_Ad_Amount from t0210_monthly_ad_detail MAD WITH (NOLOCK) inner join
							t0050_ad_master WITH (NOLOCK) on MAD.Ad_Id = t0050_ad_master.Ad_ID
							and MAD.Cmp_ID = t0050_ad_master.Cmp_Id
							and MAD.Emp_ID  = @Emp_ID
						where 
						MAD.Cmp_ID = @Cmp_ID and Month(MAD.For_Date) =  @Month and Year(MAD.For_Date) = @Year
						and Ad_Active = 1 and AD_Flag = 'D' and isnull(t0050_ad_master.Ad_Not_Effect_Salary,0)=0
						and Sal_Type = @Sal_Type
					open Cur_Dedu
					fetch next from cur_DEDU  into @Allow_Name ,@Amount
					while @@fetch_status = 0
						begin
							select @Row_ID = Row_ID from #Temp_report_label where Label_Name like @Allow_Name 
							
							UPDATE    #Temp_Salary_Muster_Report
							SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Temp_month, Year = @Temp_Year, Amount = @Amount, 
												  Value_String = ''
							WHERE     (Label_Name = @Allow_Name) AND (Row_id = @Row_ID)
									and Emp_ID = @Emp_ID
							fetch next from Cur_Dedu into @Allow_Name,@Amount
						
						end
					close Cur_Dedu
					deallocate Cur_Dedu

						If @Sal_Type = 0
							select @Total_Deduction = Total_Dedu_Amount ,@PT = PT_Amount ,@Loan =  ( Loan_Amount + Loan_Intrest_Amount ) 
									,@Advance =  Advance_Amount ,@Net_Salary = Net_Amount ,@Revenue_Amt =Revenue_amount,@LWF_Amt =LWF_Amount,@Other_Dedu=Other_Dedu_Amount,
									@Deficit_Amt = Isnull(Deficit_Dedu_Amount,0),@Uniform_Installment=Uniform_Dedu_Amount,@Uniform_Refund_Installment=Uniform_Refund_Amount
									,@Late_Deduction = Late_Dedu_Amount 
							from T0200_Monthly_salary WITH (NOLOCK) where Emp_ID = @Emp_ID and Month(Month_St_Date) = @Month and Year(Month_St_Date) = @Year
						Else
							select @Total_Deduction = S_Total_Dedu_Amount ,@PT = S_PT_Amount ,@Loan =  (S_Loan_Amount + S_Loan_Intrest_Amount ) 
									,@Advance =  S_Advance_Amount ,@Net_Salary = S_Net_Amount ,@Revenue_Amt =S_Revenue_Amount,@LWF_Amt =S_LWF_Amount,@Other_Dedu=S_Other_Dedu_Amount									
							from T0201_MONTHLY_SALARY_SETT WITH (NOLOCK) where Emp_ID = @Emp_ID and Month(S_Month_St_Date) = @Month and Year(S_Month_St_Date) = @Year
						
						--Select @Other_Dedu  = 0
						
					--	set @Loan = @Loan + @Advance

		--				select @Row_ID = Row_ID from Temp_report_label where Label_Name like 'Other Dedu'

		--				INSERT INTO Temp_Salary_Muster_Report


		--						   (Emp_ID, Company_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id)
		--				VALUES     (@Emp_ID, @Company_ID, @Transaction_ID, @Month, @Year, 'Other Dedu', @Other_Dedu,'',@Row_ID)
				
				--start Ankit for Credit Amount	on 13052013
					declare Cur_Credit   cursor for
						select Ad_Sort_Name ,(isnull(M_Ad_Amount,0) + isnull(M_Arear_Amount,0) + isnull(M_Arear_Amount_cutoff,0)) as M_Ad_Amount from t0210_monthly_ad_detail MAD WITH (NOLOCK) inner join
							t0050_ad_master WITH (NOLOCK) on MAD.Ad_Id = t0050_ad_master.Ad_ID
							and MAD.Cmp_ID = t0050_ad_master.Cmp_Id
							and MAD.Emp_ID  = @Emp_ID
						where 
						MAD.Cmp_ID = @Cmp_ID and Month(MAD.For_Date) =  @Month and Year(MAD.For_Date) = @Year
						and Ad_Active = 1 and Effect_Net_Salary=1 and Ad_Not_Effect_Salary=1
						and Sal_Type = @Sal_Type
					open Cur_Credit
					fetch next from Cur_Credit  into @Allow_Name ,@Amount
					while @@fetch_status = 0
						begin
							select @Row_ID = Row_ID from #Temp_report_label where Label_Name like @Allow_Name 
							
							UPDATE    #Temp_Salary_Muster_Report
							SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Temp_month, Year = @Temp_Year, Amount = @Amount, 
												  Value_String = ''
							WHERE     (Label_Name = @Allow_Name) AND (Row_id = @Row_ID)
									and Emp_ID = @Emp_ID
							fetch next from Cur_Credit into @Allow_Name,@Amount
						end
					close Cur_Credit
					deallocate Cur_Credit
				--end Ankit for credit amount	
						
						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'PT'
						
						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Temp_month, Year = @Temp_Year, Amount = @PT, 
											  Value_String = ''
						WHERE     (Label_Name = 'PT') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
								
						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'Loan'
						
						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Temp_month, Year = @Temp_Year, Amount = @Loan, 
											  Value_String = ''
						WHERE     (Label_Name = 'Loan') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
								
								
								select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'Advnc'
						
						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Temp_month, Year = @Temp_Year, Amount = @Advance, 
											  Value_String = ''
						WHERE     (Label_Name = 'Advnc') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
						
						
						if @Revenue_Amt >0
							begin
								select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'Revenue'
								
								UPDATE    #Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Temp_month, Year = @Temp_Year, Amount = @Revenue_Amt, 
													  Value_String = ''
								WHERE     (Label_Name = 'Revenue') AND (Row_id = @Row_ID)
										and Emp_ID = @Emp_ID
							end
						if @LWF_amt > 0
							begin
								select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'LWF'
								
								UPDATE    #Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Temp_month, Year = @Temp_Year, Amount = @lwf_Amt, 
													  Value_String = ''
								WHERE     (Label_Name = 'LWF') AND (Row_id = @Row_ID)
										and Emp_ID = @Emp_ID
							end							
								
					
						--select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'TDS'
						--UPDATE    #Temp_Salary_Muster_Report
						--SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @TDS, 
						--					  Value_String = ''
						--WHERE     (Label_Name = 'TDS') AND (Row_id = @Row_ID)
						--		and Emp_ID = @Emp_ID
						
						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'Oth De'
						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Temp_month, Year = @Temp_Year, Amount = @Other_Dedu, 
											  Value_String = ''
						WHERE     (Label_Name = 'Oth De') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
						
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Gate Pass'
								UPDATE    dbo.#Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @GatePass_Amount, 
											  Value_String = ''
								WHERE     (Label_Name = 'Gate Pass') AND (Row_id = @Row_ID)
									and Emp_ID = @Emp_ID
									
						
						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'Deficit Amt'
						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Temp_month, Year = @Temp_Year, Amount = @Deficit_Amt, 
											  Value_String = ''
						WHERE     (Label_Name = 'Deficit Amt') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
						
						--Added By Mukti(start)23052017
						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'Uni.Inst.'						
						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Temp_month, Year = @Temp_Year, Amount = @Uniform_Installment, 
											  Value_String = ''
						WHERE     (Label_Name = 'Uni.Inst.') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
								
						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'Uni.Refund Inst.'						
						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Temp_month, Year = @Temp_Year, Amount = @Uniform_Refund_Installment, 
											  Value_String = ''
						WHERE     (Label_Name = 'Uni.Refund Inst.') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID		
						--Added By Mukti(start)23052017	
						
						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'Dedu'
						
						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Temp_month, Year = @Temp_Year, 
											  Amount = @Total_Deduction, Value_String = ''
						WHERE     (Label_Name = 'Dedu') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID	
				
						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'Net'
						
						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Temp_month, Year = @Temp_Year, Amount = @Net_Salary, 
											  Value_String = ''
						WHERE     (Label_Name = 'Net') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
								
								
						--added by jimit 28072017
						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'Late Dedu.'
						
						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
											  Amount = @Late_Deduction, Value_String = ''
						WHERE     (Label_Name = 'Late Dedu.') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID	
								
						--ended		
								
						
			FETCH NEXT FROM CUR_EMP INTO @EMP_ID
		END
	Close Cur_Emp
	Deallocate Cur_emp	
	
	print 1011
	
	--(cast(Emp_Code as varchar(10)) + ' - ' + Emp_Full_Name) as
	-- Changed By Ali 22112013 EmpName_Alias
	Select * From (
	select Distinct
	DENSE_RANK() OVER ( Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End) as Sr_No
	 ,#Temp_Salary_Muster_Report.* , E.Emp_Code, E.Alpha_Emp_Code, E.Emp_First_Name,
	 --,(cast(Emp_Code as varchar(10)) + ' - ' + Emp_Full_Name) as Emp_Full_Name 
	 Case When EmpName_Alias_Salary Is null then (cast(Emp_code as varchar(10)) + ' - ' + Emp_Full_Name) Else (cast(Emp_code as varchar(10)) + ' - ' + EmpName_Alias_Salary) End as Emp_Full_Name,
	 --,ISNULL(EmpName_Alias_Salary,(cast(Emp_code as varchar(10)) + ' - ' + Emp_Full_Name)) as Emp_Full_Name
	 Case When EmpName_Alias_Salary Is null then (cast(Alpha_Emp_Code as varchar(10)) + ' - ' + Emp_Full_Name) Else (cast(Alpha_Emp_Code as varchar(10)) + ' - ' + EmpName_Alias_Salary) End as Emp_Full_Name_With_AlphaCdoe
	 , E.Dept_ID,Cmp_Name,Cmp_Address,Inc_Qry.Inc_Bank_Ac_no 
		,Inc_Qry.Branch_ID 
		,DGM.Desig_Dis_No                --added jimit 24082015
		from #Temp_Salary_Muster_Report Inner join 
		T0080_Emp_Master E WITH (NOLOCK) on #Temp_Salary_Muster_Report.Emp_Id = E.Emp_ID inner join
		( select I.Emp_Id ,Grd_ID,DEsig_ID ,Dept_ID,Inc_Bank_Ac_no,Branch_ID from t0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID, Emp_ID from t0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID )Inc_Qry on 
		E.Emp_ID = Inc_Qry.Emp_ID left outer join t0040_department_Master WITH (NOLOCK)
		on Inc_Qry.dept_ID = t0040_department_Master.Dept_ID 
		left outer join T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) on Inc_Qry.Desig_Id = DGM.Desig_ID 
		 inner join 
			t0010_company_master CM WITH (NOLOCK) on E.cmp_id=CM.cmp_id Inner Join
			(Select Cmp_ID,MONTH,YEAR,Label_Name,Row_id from #Temp_Salary_Muster_Report 
				Where Amount>0 group by Cmp_ID,MONTH,YEAR,Label_Name,Row_id ) Qry On #Temp_Salary_Muster_Report.Label_Name = qry.Label_Name
		--order by Row_ID
		) Qry2 Order by Case When IsNumeric(Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + Alpha_Emp_Code, 20)
			When IsNumeric(Alpha_Emp_Code) = 0 then Left(Alpha_Emp_Code + Replicate('',21), 20)
				Else Alpha_Emp_Code
			End --ORDER BY RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500)
		,Row_ID
		
	
	RETURN




