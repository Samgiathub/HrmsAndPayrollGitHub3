CREATE PROCEDURE [dbo].[P0201_MONTHLY_SALARY_SETT_DELETE]
	@S_SAL_TRAN_ID		NUMERIC ,
	@EMP_ID				NUMERIC,
	@CMP_ID				NUMERIC,
	@From_Date 	datetime,
	@to_date	Datetime,
	@ErrString	varchar(500) output,
	@User_Id numeric(18,0) = 0,		-- Added for audit trail By Ali 17102013
	@IP_Address varchar(30)= ''		-- Added for audit trail By Ali 17102013
	
AS

	SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

									-- Added for audit trail by Ali 17102013 -- start

									Declare @Old_Emp_Id as numeric
									Declare @OldValue as varchar(max)
									Declare @Old_Emp_Name as varchar(200)
									Declare @Old_sal_Tran_ID as numeric
									Declare @Old_Increment_ID as numeric 
									Declare @Old_S_Month_St_Date as datetime
									Declare @Old_s_Month_End_Date as datetime
									Declare @Old_S_Sal_Generate_Date as datetime
									Declare @Old_Sal_cal_Days as numeric 
									Declare @Old_Working_Days as numeric
									Declare @Old_Outof_Days as numeric
									Declare @Old_Shift_Day_Sec as numeric
									Declare @Old_Shift_Day_Hour as varchar(20)
									Declare @Old_S_Basic_Salary as numeric
									Declare @Old_Day_Salary as numeric
									Declare @Old_Hour_Salary as numeric
									Declare @Old_S_Salary_Amount as numeric
									Declare @Old_Allow_Amount as numeric
									Declare @Old_OT_Amount as numeric
									Declare @Old_Other_Allow_Amount as numeric
									Declare @Old_S_Gross_Salary as numeric
									Declare @Old_Dedu_Amount as numeric
									Declare @Old_Loan_Amount as numeric
									Declare @Old_Loan_Intrest_Amount as numeric
									Declare @Old_Advance_Amount as numeric
									Declare @Old_Other_Dedu_Amount as numeric 
									Declare @Old_Total_Dedu_Amount as numeric
									Declare @Old_Due_Loan_Amount as numeric
									Declare @Old_Net_Amount as numeric 
									Declare @Old_S_PT_Amount as numeric
									Declare @Old_PT_Calculated_Amount as numeric
									Declare @Old_Total_Claim_Amount as numeric
									Declare @Old_M_OT_Hours as numeric
									Declare @Old_M_IT_Tax as numeric
									Declare @Old_M_Loan_Amount as numeric
									Declare @Old_M_Adv_Amount as numeric 
									Declare @Old_LWF_Amount as numeric
									Declare @Old_Revenue_Amount as numeric
									Declare @Old_PT_F_T_LIMIT as varchar(20)
									Declare @Old_S_Gross_Salary_ProRata as numeric
									Declare @Old_S_Sal_Type as varchar(20)
									Declare @Old_S_EFF_DATE as date
									Declare @Eff_Date as datetime
									Declare @Effect_On_Salary as tinyint ---Hardik 07/10/2020 for Unison as they are using Not effect on Salary so salary settlement was not deleting

									Set @Effect_On_Salary = 0

									Set @Old_Emp_Id = 0
									Set @OldValue = ''
									Set @Old_Emp_Name =''
									Set @Old_sal_Tran_ID = 0
									Set @Old_Increment_ID = 0 
									Set @Old_S_Month_St_Date = NULL
									Set @Old_s_Month_End_Date = NULL
									Set @Old_S_Sal_Generate_Date = NULL
									Set @Old_Sal_cal_Days = 0 
									Set @Old_Working_Days = 0
									Set @Old_Outof_Days = 0
									Set @Old_Shift_Day_Sec = 0
									Set @Old_Shift_Day_Hour = ''
									Set @Old_S_Basic_Salary = 0
									Set @Old_Day_Salary = 0
									Set @Old_Hour_Salary = 0
									Set @Old_S_Salary_Amount = 0
									Set @Old_Allow_Amount = 0
									Set @Old_OT_Amount = 0
									Set @Old_Other_Allow_Amount = 0
									Set @Old_S_Gross_Salary = 0
									Set @Old_Dedu_Amount = 0
									Set @Old_Loan_Amount = 0
									Set @Old_Loan_Intrest_Amount = 0
									Set @Old_Advance_Amount = 0
									Set @Old_Other_Dedu_Amount = 0 
									Set @Old_Total_Dedu_Amount = 0
									Set @Old_Due_Loan_Amount = 0
									Set @Old_Net_Amount = 0 
									Set @Old_S_PT_Amount = 0
									Set @Old_PT_Calculated_Amount = 0
									Set @Old_Total_Claim_Amount = 0
									Set @Old_M_OT_Hours = 0
									Set @Old_M_IT_Tax = 0
									Set @Old_M_Loan_Amount = 0
									Set @Old_M_Adv_Amount = 0 
									Set @Old_LWF_Amount = 0
									Set @Old_Revenue_Amount = 0
									Set @Old_PT_F_T_LIMIT = ''
									Set @Old_S_Gross_Salary_ProRata = 0
									Set @Old_S_Sal_Type = ''
									Set @Old_S_EFF_DATE = NULL
								-- Added for audit trail by Ali 17102013 -- start
	 
	
	select 	@Eff_Date=S_Eff_Date, @Effect_On_Salary = Effect_On_Salary FROM  T0201_MONTHLY_SALARY_SETT WITH (NOLOCK) WHERE EMP_ID =@EMP_ID and S_Sal_Tran_ID=@S_SAL_TRAN_ID and Cmp_ID=@CMP_ID

	IF EXISTS(SELECT EMP_ID FROM  T0201_MONTHLY_SALARY_SETT WITH (NOLOCK) WHERE EMP_ID =@EMP_ID AND  S_Month_St_Date >= @To_Date and ( MONTH(S_Eff_Date) = MONTH(@Eff_Date) AND YEAR(S_Eff_Date) = YEAR(@Eff_Date) ) )	--@Eff_Date : Condition For Twice Sattl. in A month	--Ankit 22122015
		Begin
			Raiserror('Next Months salary Exists',16,2)
			return -1
		End

--added by Mukti 12062014(Start) 
	
	IF @Effect_On_Salary = 1 And EXISTS(SELECT EMP_ID FROM  T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE EMP_ID =@EMP_ID and Cmp_ID=@CMP_ID AND  datepart(MM,Month_end_Date)= datepart(MM,@Eff_Date) and datepart(YY,Month_end_Date)= datepart(YY,@Eff_Date))
		Begin
			Raiserror('You cannot Delete, Salary Exists for Effective Month',16,2)
			return -1
		End
--added by Mukti 12062014(End)
		
--	DELETE FROM T0210_PAYSLIP_DATA	WHERE S_SAL_TRAN_ID = @S_SAL_TRAN_ID

											-- Added for audit trail by Ali 17102013 -- Start
												Select 
												  @Old_sal_Tran_ID = Sal_Tran_ID,
												  @Old_Increment_ID = Increment_ID, 
												  @Old_S_Month_St_Date = S_Month_St_Date, 
												  @Old_s_Month_End_Date = S_Month_End_Date, 
												  @Old_S_Sal_Generate_Date = S_Sal_Generate_Date, 
												  @Old_Sal_cal_Days = S_Sal_Cal_Days, 
												  @Old_Working_Days = S_Working_Days, 
												  @Old_Outof_Days = S_Outof_Days, 
												  @Old_Shift_Day_Sec = S_Shift_Day_Sec, 
												  @Old_Shift_Day_Hour = S_Shift_Day_Hour, 
												  @Old_S_Basic_Salary = S_Basic_Salary, 
												  @Old_Day_Salary = S_Day_Salary, 
												  @Old_Hour_Salary = s_Hour_Salary, 
												  @Old_s_Salary_Amount = s_Salary_Amount, 
												  @Old_Allow_Amount = s_Allow_Amount, 
												  @Old_OT_Amount = s_OT_Amount, 
												  @Old_Other_Allow_Amount = s_Other_Allow_Amount, 
												  @Old_s_Gross_Salary = s_Gross_Salary, 
												  @Old_Dedu_Amount = s_Dedu_Amount, 
												  @Old_Loan_Amount = S_Loan_Amount, 
												  @Old_Loan_Intrest_Amount = s_Loan_Intrest_Amount, 
												  @Old_Advance_Amount = s_Advance_Amount, 
												  @Old_Other_Dedu_Amount = s_Other_Dedu_Amount, 
												  @Old_Total_Dedu_Amount = s_Total_Dedu_Amount, 
												  @Old_Due_Loan_Amount = s_Due_Loan_Amount, 
												  @Old_Net_Amount = s_Net_Amount ,
												  @Old_s_PT_Amount = s_PT_Amount,
												  @Old_PT_Calculated_Amount = s_PT_Calculated_Amount ,
												  @Old_Total_Claim_Amount = s_Total_Claim_Amount,
												  @Old_M_OT_Hours = s_M_OT_Hours , 
												  @Old_M_IT_Tax = s_M_IT_Tax , 
												  @Old_M_Loan_Amount = s_M_Loan_Amount ,
												  @Old_M_Adv_Amount = s_M_Adv_Amount,
												  @Old_LWF_Amount = s_LWF_Amount , 
												  @Old_Revenue_Amount = s_Revenue_Amount ,
												  @Old_PT_F_T_LIMIT = s_PT_F_T_LIMIT,
												  @Old_S_Gross_Salary_ProRata = s_Actually_Gross_Salary,
												  @Old_S_Sal_Type =S_Sal_Type ,
												  @Old_S_EFF_DATE = S_EFF_DATE		
												From T0201_MONTHLY_SALARY_SETT WITH (NOLOCK)
												WHERE S_Sal_Tran_ID =@S_Sal_Tran_ID AND EMP_ID = @EMP_ID
												
												
												Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'')   from T0080_EMP_MASTER Where Emp_ID = @Emp_ID)
									
												set @OldValue = 'old Value' 
													+ '#' + 'Employee Name :' + ISNULL(@Old_Emp_Name,'')
													+ '#' + 'Increment ID :' + CONVERT(nvarchar(100),ISNULL(@Old_Increment_ID,0))													
													+ '#' + 'Month Start Date :' + cast(ISNULL(@Old_S_Month_St_Date,'') as nvarchar(11))
													+ '#' + 'Month End Date :' + cast(ISNULL(@Old_s_Month_End_Date,'') as nvarchar(11))
													+ '#' + 'Salary Generate Date :' + cast(ISNULL(@Old_S_Sal_Generate_Date,'') as nvarchar(11))
													+ '#' + 'Salary Cal Days :' + CONVERT(nvarchar(100),ISNULL(@Old_Sal_cal_Days,0))
													+ '#' + 'Working Days :' + CONVERT(nvarchar(100),ISNULL(@Old_Working_Days,0))
													+ '#' + 'Outof Days :' + CONVERT(nvarchar(100),ISNULL(@Old_Outof_Days,0))
													+ '#' + 'Shift Day In Sec :' + CONVERT(nvarchar(100),ISNULL(@Old_Shift_Day_Sec,0))
													+ '#' + 'Shift Day In Hour :' + ISNULL(@Old_Shift_Day_Hour,'')
													+ '#' + 'Basic Salary :' + CONVERT(nvarchar(100),ISNULL(@Old_S_Basic_Salary,0))
													+ '#' + 'Day Salary :' + CONVERT(nvarchar(100),ISNULL(@Old_Day_Salary,0))
													+ '#' + 'Hour Salary :' + CONVERT(nvarchar(100),ISNULL(@Old_Hour_Salary,0))
													+ '#' + 'Salary Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_S_Salary_Amount,0))
													+ '#' + 'Total Hours :' + CONVERT(nvarchar(100),ISNULL(@Old_S_Salary_Amount,0))
													+ '#' + 'Allow Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_Allow_Amount,0))
													+ '#' + 'OT Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_OT_Amount,0))
													+ '#' + 'Other Allow Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_Other_Allow_Amount,0))
													+ '#' + 'Gross Salary :' + CONVERT(nvarchar(100),ISNULL(@Old_S_Gross_Salary,0))
													+ '#' + 'Dedu Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_Dedu_Amount,0))
													+ '#' + 'Loan Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_Loan_Amount,0))
													+ '#' + 'Loan Intrest Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_Loan_Intrest_Amount,0))
													+ '#' + 'Advance Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_Advance_Amount,0))
													+ '#' + 'Other Dedu Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_Other_Dedu_Amount,0))
													+ '#' + 'Total Dedu Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_Total_Dedu_Amount,0))
													+ '#' + 'Due Loan Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_Due_Loan_Amount,0))
													+ '#' + 'Net Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_Net_Amount,0))
													+ '#' + 'PT Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_S_PT_Amount,0))
													+ '#' + 'PT Calculated Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_PT_Calculated_Amount,0))
													+ '#' + 'Total Claim Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_Total_Claim_Amount,0))
													+ '#' + 'OT Hours :' + CONVERT(nvarchar(100),ISNULL(@Old_M_OT_Hours,0))
													+ '#' + 'IT Tax :' + CONVERT(nvarchar(100),ISNULL(@Old_M_IT_Tax,0))
													+ '#' + 'Loan Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_M_Loan_Amount,0))
													+ '#' + 'Adv Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_M_Adv_Amount,0))
													+ '#' + 'LWF Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_LWF_Amount,0))
													+ '#' + 'Revenue Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_Revenue_Amount,0))
													+ '#' + 'PT F T LIMIT :' + ISNULL(@Old_PT_F_T_LIMIT,0)
													+ '#' + 'Gross Salary ProRata :' + CONVERT(nvarchar(100),ISNULL(@Old_S_Gross_Salary_ProRata,0))
													+ '#' + 'Salary Type :' + ISNULL(@Old_S_Sal_Type,0)
													+ '#' + 'Effective DATE :' + cast(ISNULL(@Old_S_EFF_DATE,'') as nvarchar(11))
																											
												exec P9999_Audit_Trail @Cmp_ID,'D','Salary Settlement',@Oldvalue,@Emp_ID,@User_Id,@IP_Address,1
												
											-- Added for audit trail by Ali 17102013 -- End	
	
	DELETE FROM T0210_MONTHLY_LOAN_PAYMENT WHERE S_SAL_TRAN_ID = @S_SAL_TRAN_ID 


	DELETE FROM T0210_MONTHLY_AD_DETAIL WHERE S_SAL_TRAN_ID = @S_SAL_TRAN_ID AND EMP_ID =@EMP_id 
	
	DELETE FROM T0201_MONTHLY_SALARY_SETT WHERE S_SAL_TRAN_ID = @S_SAL_TRAN_ID AND EMP_ID =@EMP_id 
	
	RETURN










