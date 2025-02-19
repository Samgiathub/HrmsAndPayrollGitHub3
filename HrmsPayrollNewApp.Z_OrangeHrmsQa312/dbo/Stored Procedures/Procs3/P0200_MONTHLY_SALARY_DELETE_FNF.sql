
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0200_MONTHLY_SALARY_DELETE_FNF]
	@SAL_TRAN_ID		NUMERIC ,
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
SET ANSI_WARNINGS OFF;
									--Added for audit trail By Ali 17102013 -- Start
										Declare @Old_Emp_Id as numeric
										Declare @Old_Emp_Name as varchar(150)
										Declare @Old_Sal_Receipt_No numeric
										Declare @OldValue as varchar(max)
										
										Declare @Old_Increment_ID as numeric
										Declare @Old_tmp_Month_St_Date as datetime
										Declare @Old_tmp_Month_End_Date as datetime
										Declare @Old_Sal_Generate_Date as datetime
										Declare @Old_mid_Sal_Cal_Days as numeric
										Declare @Old_mid_Present_Days as numeric
										Declare @Old_mid_Absent_Days as numeric
										Declare @Old_mid_Holiday_Days as numeric
										Declare @Old_mid_Weekoff_Days as numeric
										Declare @Old_mid_Cancel_Holiday as numeric
										Declare @Old_mid_Cancel_Weekoff as numeric
										Declare @Old_Working_Days as numeric
										Declare @Old_Outof_Days as numeric
										Declare @Old_mid_Total_Leave_Days as numeric
										Declare @Old_mid_Paid_Leave_Days as numeric
										Declare @Old_mid_Actual_Working_Hours as varchar(150)
										Declare @Old_mid_Working_Hours as varchar(150)
										Declare @Old_mid_Outof_Hours as varchar(150)
										Declare @Old_Emp_OT_Hours_Num as numeric
										Declare @Old_Total_Hours as varchar(100)
										Declare @Old_mid_Shift_Day_Sec  as varchar(100)
										Declare @Old_mid_Shift_Day_Hour as varchar(100)
										Declare @Old_mid_basic_Amount as numeric
										Declare @Old_mid_Day_Salary as numeric
										Declare @Old_mid_Hour_Salary as numeric
										Declare @Old_mid_Salary_Amount as numeric
										Declare @Old_mid_Allow_Amount as numeric
										Declare @Old_mid_OT_Amount as numeric
										Declare @Old_mid_Other_Allow_Amount as numeric
										Declare @Old_mid_gross_Amount as numeric
										Declare @Old_mid_Dedu_Amount as numeric
										Declare @Old_mid_Loan_Amount as numeric
										Declare @Old_mid_Loan_Intrest_Amount as numeric
										Declare @Old_mid_Advance_Amount as numeric
										Declare @Old_mid_Other_Dedu_Amount as numeric
										Declare @Old_mid_Total_Dedu_Amount as numeric
										Declare @Old_mid_Due_Loan_Amount as numeric
										Declare @Old_mid_Net_Amount as numeric
										Declare @Old_mid_PT_Calculated_Amount as numeric
										Declare @Old_mid_PT_Amount as numeric
										Declare @Old_mid_Total_Claim_Amount as numeric
										Declare @Old_mid_M_IT_Tax as numeric
										Declare @Old_mid_M_ADv_Amount as numeric
										Declare @Old_mid_M_Loan_Amount as numeric
										Declare @Old_mid_M_OT_Hours as numeric
										Declare @Old_mid_LWF_Amount as numeric
										Declare @Old_mid_REvenue_Amount as numeric
										Declare @Old_mid_PT_F_T_LIMIT as varchar(100)
										Declare @Old_Gross_Salary_ProRata as numeric
										Declare @Old_mid_Leave_Salary_Amount as numeric
										Declare @Old_mid_Late_Sec as numeric
										Declare @Old_mid_Late_Dedu_Amount as numeric
										Declare @Old_Extra_Late_Deduction as numeric
										Declare @Old_mid_Late_Days as numeric
										Declare @Old_Status as varchar(100)
										Declare @Old_mid_Bonus_Amount as numeric
										Declare @Old_mid_IT_M_ED_Cess_Amount as numeric
										Declare @Old_mid_IT_M_Surcharge_Amount as numeric
										Declare @Old_mid_Early_Sec as numeric
										Declare @Old_mid_Early_Dedu_Amount as numeric
										Declare @Old_mid_Early_Extra_Dedu_Amount as numeric
										Declare @Old_mid_Early_Days as numeric
										Declare @Old_mid_Total_Earning_Fraction as numeric
										Declare @Old_mid_Late_Early_Penalty_days as numeric
										Declare @Old_mid_M_WO_OT_Hours as numeric
										Declare @Old_mid_M_WO_OT_Amount as numeric
										Declare @Old_mid_M_HO_OT_Hours as numeric
										Declare @Old_mid_M_HO_OT_Amount as numeric
										Declare @Old_Salary_amount_Arear as numeric
										Declare @Old_Gross_Salary_Arear as numeric
										Declare @Old_Arear_Day as numeric
										Declare @Old_Mid_OD_leave_Days as numeric
										Declare @Old_Extra_AB_Days as numeric
										Declare @Old_Extra_AB_Rate as numeric
										Declare @Old_Extra_AB_Amount as numeric
										Declare @Old_Settelement_Amount as numeric
										declare @Asset_Approval_ID as numeric --Mukti 20032015
										declare @AssetM_ID as numeric --Mukti 20032015
										
										Set @Old_Emp_Id = 0
										Set @Old_Emp_Name = ''
										Set @Old_Sal_Receipt_No = 0
										Set @OldValue = ''
										Set @Old_Increment_ID = 0
										Set @Old_tmp_Month_St_Date = null
										Set @Old_tmp_Month_End_Date = null
										Set @Old_Sal_Generate_Date = null
										Set @Old_mid_Sal_Cal_Days = 0
										Set @Old_mid_Present_Days = 0
										Set @Old_mid_Absent_Days = 0
										Set @Old_mid_Holiday_Days = 0
										Set @Old_mid_Weekoff_Days = 0
										Set @Old_mid_Cancel_Holiday = 0
										Set @Old_mid_Cancel_Weekoff = 0
										Set @Old_Working_Days = 0
										Set @Old_Outof_Days = 0
										Set @Old_mid_Total_Leave_Days = 0
										Set @Old_mid_Paid_Leave_Days = 0
										Set @Old_mid_Actual_Working_Hours = ''
										Set @Old_mid_Working_Hours = ''
										Set @Old_mid_Outof_Hours = ''
										Set @Old_Emp_OT_Hours_Num = 0
										Set @Old_Total_Hours = ''
										Set @Old_mid_Shift_Day_Sec  = ''
										Set @Old_mid_Shift_Day_Hour = ''
										Set @Old_mid_basic_Amount = 0
										Set @Old_mid_Day_Salary = 0
										Set @Old_mid_Hour_Salary = 0
										Set @Old_mid_Salary_Amount = 0
										Set @Old_mid_Allow_Amount = 0
										Set @Old_mid_OT_Amount = 0
										Set @Old_mid_Other_Allow_Amount = 0
										Set @Old_mid_gross_Amount = 0
										Set @Old_mid_Dedu_Amount = 0
										Set @Old_mid_Loan_Amount = 0
										Set @Old_mid_Loan_Intrest_Amount = 0
										Set @Old_mid_Advance_Amount = 0
										Set @Old_mid_Other_Dedu_Amount = 0
										Set @Old_mid_Total_Dedu_Amount = 0
										Set @Old_mid_Due_Loan_Amount = 0
										Set @Old_mid_Net_Amount = 0
										Set @Old_mid_PT_Calculated_Amount = 0
										Set @Old_mid_PT_Amount = 0
										Set @Old_mid_Total_Claim_Amount = 0
										Set @Old_mid_M_IT_Tax = 0
										Set @Old_mid_M_ADv_Amount = 0
										Set @Old_mid_M_Loan_Amount = 0
										Set @Old_mid_M_OT_Hours = 0
										Set @Old_mid_LWF_Amount = 0
										Set @Old_mid_REvenue_Amount = 0
										Set @Old_mid_PT_F_T_LIMIT = ''
										Set @Old_Gross_Salary_ProRata = 0
										Set @Old_mid_Leave_Salary_Amount = 0
										Set @Old_mid_Late_Sec = 0
										Set @Old_mid_Late_Dedu_Amount = 0
										Set @Old_Extra_Late_Deduction = 0
										Set @Old_mid_Late_Days = 0
										Set @Old_Status = ''
										Set @Old_mid_Bonus_Amount = 0
										Set @Old_mid_IT_M_ED_Cess_Amount = 0
										Set @Old_mid_IT_M_Surcharge_Amount = 0
										Set @Old_mid_Early_Sec = 0
										Set @Old_mid_Early_Dedu_Amount = 0
										Set @Old_mid_Early_Extra_Dedu_Amount = 0
										Set @Old_mid_Early_Days = 0
										Set @Old_mid_Total_Earning_Fraction = 0
										Set @Old_mid_Late_Early_Penalty_days = 0
										Set @Old_mid_M_WO_OT_Hours = 0
										Set @Old_mid_M_WO_OT_Amount = 0
										Set @Old_mid_M_HO_OT_Hours = 0
										Set @Old_mid_M_HO_OT_Amount = 0
										Set @Old_Salary_amount_Arear = 0
										Set @Old_Gross_Salary_Arear = 0
										Set @Old_Arear_Day = 0
										Set @Old_Mid_OD_leave_Days = 0
										Set @Old_Extra_AB_Days = 0
										Set @Old_Extra_AB_Rate = 0
										Set @Old_Extra_AB_Amount = 0
										Set @Old_Settelement_Amount = 0

									--Added for audit trail By Ali 17102013 -- End
	
	
--	IF EXISTS(SELECT EMP_ID FROM  T0200_MONTHLY_SALARY WHERE EMP_ID =@EMP_ID AND  Month_St_Date >= @To_Date )
--		Begin
--			Raiserror('Next Months salary Exists',16,2)
--			return -1
--		End
	
	/* Ankit 05092016 */
	Declare @Branch_ID Numeric
	Set @Branch_ID = 0
	
	select  @Branch_ID = Branch_ID
	From T0095_Increment I WITH (NOLOCK) inner join  
		( select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK)   --Changed by Hardik 10/09/2014 for Same Date Increment  
		  where Increment_Effective_date <= @To_Date    
		  and Cmp_ID = @Cmp_ID And Emp_ID = @Emp_ID group by emp_ID 
		) Qry on  I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id    
	Where I.Emp_ID = @Emp_ID  
  
	If Exists(Select Pf_Challan_Id From dbo.T0220_Pf_Challan WITH (NOLOCK) Where Cmp_Id=@Cmp_Id And Month=Month(@To_Date) And Year = Year(@To_Date) And CHARINDEX('#'+ Cast(@Branch_ID As VARCHAR(18)) +'','#' + Branch_ID_Multi) > 0)
		Begin
				RAISERROR ('PF Challan Exists', -- Message text.
									16, -- Severity.
									1   -- State.
									);
				RETURN
		End
    If Exists(Select Esic_Challan_Id From dbo.T0220_ESIC_Challan WITH (NOLOCK) Where Cmp_Id=@Cmp_Id And Month=Month(@To_Date) And Year = Year(@To_Date) And CHARINDEX('#'+ Cast(@Branch_ID As VARCHAR(18)) +'','#' + Branch_ID_Multi) > 0)
		Begin
				RAISERROR ('ESIC Challan Exists', -- Message text.
									16, -- Severity.
									1   -- State.
									);
				RETURN
		End
		--Added By Jaina 28-09-2015 Start
		
	If Exists(Select Challan_Id  From dbo.T0220_PT_CHALLAN WITH (NOLOCK) Where Cmp_Id=@Cmp_Id And Month=Month(@To_Date) And Year = Year(@To_Date) And CHARINDEX('#'+ Cast(@Branch_ID As VARCHAR(18)) +'','#' + Branch_ID_Multi) > 0)
		Begin
				RAISERROR ('PT Challan Exists', -- Message text.
									16, -- Severity.
									1   -- State.
									);
				RETURN
		End
		
	IF EXISTS(SELECT 1 FROM  T0250_MONTHLY_LOCK_INFORMATION WITH (NOLOCK) WHERE MONTH =  MONTH(@To_Date) and YEAR =  year(@To_Date) and Cmp_ID = @CMP_ID and (Branch_ID = isnull(@Branch_ID,0) or Branch_ID = 0))
		Begin
			Raiserror('Month Lock',16,2)
			return -1
		End	
	/* Ankit 05092016 */
	
	
	If exists(select Emp_ID From T0200_MONTHLY_SALARY WITH (NOLOCK) Where Emp_ID=@Emp_ID and Sal_Tran_ID =@Sal_Tran_ID and 
					isnull(is_FNF,0) = 1 )
		begin
				
											-- Added for audit trail by Ali 17102013 -- Start
												Select	@Old_Increment_ID = Increment_ID
														,@Old_Sal_Receipt_No = Sal_Receipt_No
														, @Old_tmp_Month_St_Date = Month_St_Date
														, @Old_tmp_Month_End_Date = Month_End_Date
														, @Old_Sal_Generate_Date = Sal_Generate_Date
														, @Old_mid_Sal_Cal_Days = Sal_cal_Days
														, @Old_mid_Present_Days = Present_Days
														, @Old_mid_Absent_Days = Absent_Days
														, @Old_mid_Holiday_Days = Holiday_Days
														, @Old_mid_Weekoff_Days = WeekOff_Days
														, @Old_mid_Cancel_Holiday = Cancel_Holiday
														, @Old_mid_Cancel_Weekoff = Cancel_Weekoff
														, @Old_Working_Days = Working_Days
														, @Old_Outof_Days = Outof_Days
														, @Old_mid_Total_Leave_Days = Total_Leave_Days
														, @Old_mid_Paid_Leave_Days = Paid_Leave_Days
														, @Old_mid_Actual_Working_Hours = Actual_Working_Hours
														, @Old_mid_Working_Hours = Working_Hours
														, @Old_mid_Outof_Hours = Outof_Hours
														, @Old_Emp_OT_Hours_Num = OT_Hours
														, @Old_Total_Hours = Total_Hours
														, @Old_mid_Shift_Day_Sec = Shift_Day_Sec
														, @Old_mid_Shift_Day_Hour = Shift_Day_Hour
														, @Old_mid_basic_Amount = Basic_Salary
														, @Old_mid_Day_Salary = Day_Salary
														, @Old_mid_Hour_Salary = Hour_Salary
														, @Old_mid_Salary_Amount = Salary_Amount
														, @Old_mid_Allow_Amount = Allow_Amount
														, @Old_mid_OT_Amount = OT_Amount
														, @Old_mid_Other_Allow_Amount = Other_Allow_Amount
														, @Old_mid_gross_Amount = Gross_Salary
														, @Old_mid_Dedu_Amount = Dedu_Amount
														, @Old_mid_Loan_Amount = Loan_Amount
														, @Old_mid_Loan_Intrest_Amount = Loan_Intrest_Amount
														, @Old_mid_Advance_Amount = Advance_Amount
														, @Old_mid_Other_Dedu_Amount = Other_Dedu_Amount
														, @Old_mid_Total_Dedu_Amount = Total_Dedu_Amount
														, @Old_mid_Due_Loan_Amount = Due_Loan_Amount
														, @Old_mid_Net_Amount = Net_Amount
														, @Old_mid_PT_Amount = PT_Amount
														, @Old_mid_PT_Calculated_Amount = PT_Calculated_Amount
														, @Old_mid_Total_Claim_Amount = Total_Claim_Amount
														, @Old_mid_M_OT_Hours = M_OT_Hours
														, @Old_mid_M_IT_Tax = M_IT_Tax
														, @Old_mid_M_Loan_Amount = M_Loan_Amount
														, @Old_mid_M_ADv_Amount = M_Adv_Amount
														, @Old_mid_LWF_Amount = LWF_Amount
														, @Old_mid_REvenue_Amount = Revenue_Amount
														, @Old_mid_PT_F_T_LIMIT = PT_F_T_Limit
														, @Old_Gross_Salary_ProRata = Actually_Gross_Salary
														, @Old_mid_Late_Sec = Late_Sec
														, @Old_mid_Late_Dedu_Amount = Late_Dedu_Amount
														, @Old_Extra_Late_Deduction = Late_Extra_Dedu_Amount
														, @Old_mid_Late_Days = Late_Days
														, @Old_Status = Salary_Status  
														, @Old_mid_Bonus_Amount = Bonus_Amount 
														, @Old_mid_Leave_Salary_Amount =  Leave_Salary_Amount  
														, @Old_mid_Early_Sec = Early_Sec
														, @Old_mid_Early_Dedu_Amount = Early_Dedu_Amount
														, @Old_mid_Early_Extra_Dedu_Amount = Early_Extra_Dedu_Amount
														, @Old_mid_Early_Days = Early_Days
														, @Old_mid_Total_Earning_Fraction =  Total_Earning_Fraction 
														, @Old_Salary_amount_Arear = Arear_Basic
														, @Old_Gross_Salary_Arear = Arear_Gross
														, @Old_Arear_Day = Arear_Day
														, @Old_mid_Late_Early_Penalty_days = Late_Early_Penalty_days
														, @Old_Mid_OD_leave_Days = OD_leave_Days
														, @Old_Extra_AB_Days= Extra_AB_Days
														, @Old_Extra_AB_Rate= Extra_AB_Rate
														, @Old_Extra_AB_Amount = Extra_AB_Amount
														, @Old_Settelement_Amount =  Settelement_Amount
												FROM T0200_MONTHLY_SALARY WITH (NOLOCK)	  
												WHERE (Sal_Tran_ID = @SAL_TRAN_ID) AND (Emp_ID = @EMP_ID)    
																						
												Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'')   from T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_ID)
												
												set @OldValue = 'old Value' 
													+ '#' + 'Employee Name :' + ISNULL(@Old_Emp_Name,'')
													+ '#' + 'Salary Receipt No :' + CONVERT(nvarchar(100),ISNULL(@Old_Sal_Receipt_No,0))
													+ '#' + 'Increment ID :' + CONVERT(nvarchar(100),ISNULL(@Old_Increment_ID,0))
													+ '#' + 'Month Start Date :' + cast(ISNULL(@Old_tmp_Month_St_Date,'') as nvarchar(11))
													+ '#' + 'Month End Date :' + cast(ISNULL(@Old_tmp_Month_End_Date,'') as nvarchar(11))
													+ '#' + 'Salary Generate Date :' + cast(ISNULL(@Old_Sal_Generate_Date,'') as nvarchar(11))
													+ '#' + 'Salary Cal Days :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Sal_Cal_Days,0))
													+ '#' + 'Present Days :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Present_Days,0))
													+ '#' + 'Absent Days :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Absent_Days,0))
													+ '#' + 'Holiday Days :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Holiday_Days,0))
													+ '#' + 'Weekoff Days :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Weekoff_Days,0))
													+ '#' + 'Cancel Holiday :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Cancel_Holiday,0))
													+ '#' + 'Cancel Weekoff :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Cancel_Weekoff,0))													
													+ '#' + 'Working Days :' + CONVERT(nvarchar(100),ISNULL(@Old_Working_days,0))
													+ '#' + 'Outof Days :' + CONVERT(nvarchar(100),ISNULL(@Old_OutOf_Days,0))
													+ '#' + 'Total Leave Days :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Total_leave_Days,0))
													+ '#' + 'Paid Leave Days :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Paid_leave_Days,0))
													+ '#' + 'Actual Working Hours :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Actual_Working_Hours,0))
													+ '#' + 'Working Hours :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Working_Hours,0))
													+ '#' + 'Outof Hours :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Outof_Hours,0))
													+ '#' + 'Employee OT Hours :' + CONVERT(nvarchar(100),ISNULL(@Old_Emp_OT_Hours_Num,0))
													+ '#' + 'Total Hours :' + ISNULL(@Old_Total_Hours,'')
													+ '#' + 'Shift Day In Sec :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Shift_Day_Sec,0))
													+ '#' + 'Shift Day In Hour :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Shift_Day_Hour,0))
													+ '#' + 'Basic Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_basic_Amount,0))
													+ '#' + 'Day Salary :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Day_Salary,0))
													+ '#' + 'Hour Salary :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Hour_Salary,0))
													+ '#' + 'Salary Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Salary_amount,0))
													+ '#' + 'Allow Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Allow_Amount,0))
													+ '#' + 'Bonus Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Bonus_Amount,0))
													+ '#' + 'WO OT Hours :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_M_WO_OT_Hours,0))
													+ '#' + 'WO OT Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_M_WO_OT_Amount,0))
													+ '#' + 'HO OT Hours :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_M_HO_OT_Hours,0))
													+ '#' + 'HO OT Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_M_HO_OT_Amount,0))
													+ '#' + 'OT Hours :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_M_OT_Hours,0))
													+ '#' + 'OT Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_OT_Amount,0))
													+ '#' + 'Other Allow Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Other_allow_Amount,0))
													+ '#' + 'Gross Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_gross_Amount,0))
													+ '#' + 'Dedu Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Dedu_Amount,0))
													+ '#' + 'Loan Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Loan_Amount,0))
													+ '#' + 'Loan Intrest Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Loan_Intrest_Amount,0))
													+ '#' + 'Advance Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Advance_Amount,0))
													+ '#' + 'PT Calculated Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_PT_Calculated_Amount,0))
													+ '#' + 'PT Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_PT_Amount,0))
													+ '#' + 'Total Claim Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Total_Claim_Amount,0))
													+ '#' + 'IT Tax :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_M_IT_Tax,0))
													+ '#' + 'ADV Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_M_ADv_Amount,0))
													+ '#' + 'Loan Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_M_Loan_Amount,0))
													+ '#' + 'Other Dedu Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Other_Dedu_Amount,0))
													+ '#' + 'LWF Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_LWF_Amount,0))
													+ '#' + 'REvenue Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_REvenue_Amount,0))
													+ '#' + 'Due Loan Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Due_Loan_Amount,0))
													+ '#' + 'Late Sec :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Late_Sec,0))
													+ '#' + 'Late Days :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Late_Days,0))
													+ '#' + 'Late Dedu Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Late_Dedu_Amount,0))
													+ '#' + 'Extra Late Deduction :' + CONVERT(nvarchar(100),ISNULL(@Old_Extra_Late_Deduction,0))
													+ '#' + 'Total Dedu Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Total_Dedu_Amount,0))
													+ '#' + 'PT F T LIMIT :' + ISNULL(@Old_mid_PT_F_T_LIMIT,'')
													+ '#' + 'Gross Salary ProRata :' + CONVERT(nvarchar(100),ISNULL(@Old_Gross_Salary_ProRata,0))
													+ '#' + 'Settelement Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_Settelement_Amount,0))
													+ '#' + 'Net Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Net_Amount,0))
													+ '#' + 'Status :' + CONVERT(nvarchar(100),ISNULL('Done',0))																
												exec P9999_Audit_Trail @Cmp_ID,'D','Full and Final Settlement',@Oldvalue,@Emp_ID,@User_Id,@IP_Address,1
																													
											
											-- Added for audit trail by Ali 17102013 -- End	
				
													
				DELETE FROM T0210_PAYSLIP_DATA	WHERE SAL_TRAN_ID = @SAL_TRAN_ID
				
				DELETE FROM T0210_MONTHLY_LOAN_PAYMENT WHERE SAL_TRAN_ID = @SAL_TRAN_ID 
				--DELETE FROM T0210_MONTHLY_CLAIM_PAYMENT WHERE SAL_TRAN_ID = @SAL_TRAN_ID
				exec SP_CALCULATE_CLAIM_TRANSACTION @Cmp_ID,@EMP_ID,@From_Date,0,@From_Date,@to_date,0,'D'
				
				--DELETE FROM T0190_BONUS_DETAIL WHERE  EMP_ID =@EMP_ID AND Isnull(IS_FNF,0) =1
				
				DELETE FROM T0190_BONUS_DETAIL WHERE	 Bonus_ID IN 
						(SELECT Bonus_ID FROM T0180_BONUS WITH (NOLOCK) WHERE EMP_ID =@EMP_id  AND IS_FNF =1)
				
				
				DELETE FROM T0180_BONUS WHERE  EMP_ID =@EMP_ID AND Isnull(IS_FNF,0) =1
				DELETE FROM T0210_MONTHLY_AD_DETAIL WHERE SAL_TRAN_ID = @SAL_TRAN_ID AND EMP_ID = @EMP_id 
				
				DELETE FROM T0210_MONTHLY_LEAVE_DETAIL WHERE SAL_TRAN_ID = @SAL_TRAN_ID AND EMP_ID =@EMP_id 
			
				DELETE FROM T0120_Leave_Encash_Approval WHERE EMP_ID =@EMP_ID AND IS_FNF =1
				DELETE from t0200_salary_leave_Encashment where Emp_id=@Emp_Id And Sal_Tran_Id=@SAL_TRAN_ID
				
				DELETE FROM T0210_MONTHLY_AD_DETAIL WHERE	 EMP_ID =@EMP_id  AND L_SAL_TRAN_ID IN 
						(SELECT L_SAL_tRAN_ID FROM T0200_MONTHLY_SALARY_LEAVE WITH (NOLOCK) WHERE EMP_ID =@EMP_id  AND IS_FNF =1)
						
				DELETE FROM T0200_MONTHLY_SALARY_LEAVE WHERE EMP_ID =@EMP_id  AND IS_FNF =1

				-- Ankit 10082016 --
				DELETE FROM T0210_Monthly_Reim_Detail WHERE	 EMP_ID =@EMP_id  AND Temp_Sal_tran_ID = @SAL_TRAN_ID
				
				DELETE FROM T0200_MONTHLY_SALARY WHERE SAL_TRAN_ID = @SAL_TRAN_ID AND EMP_ID =@EMP_id 
				
				
				DELETE FROM T0110_GRATUITY_DETAIL WHERE	 Gr_ID IN 
						(SELECT Gr_ID FROM T0100_GRATUITY WITH (NOLOCK) WHERE EMP_ID =@EMP_id  AND Gr_FNF=1)
				
				Delete from T0100_GRATUITY where EMP_ID = @Emp_ID and Gr_FNF=1
				Delete from EMP_FNF_ALLOWANCE_DETAILS where Emp_ID=@Emp_ID
				
				Delete from EMP_FOR_FNF_ALLOWANCE where Emp_ID = @Emp_ID and For_Date = @From_Date
				
				Update T0080_Emp_master set IS_Emp_FNF = 0 where Emp_ID=@Emp_ID
				DELETE FROM T0210_MONTHLY_AD_DETAIL WHERE isnull(SAL_TRAN_ID,0) = 0 
				
				DELETE FROM T0100_LEAVE_CF_DETAIL WHERE Emp_ID= @EMP_ID and is_fnf = 1-- Added by rohit on 30052015 for Deete Carry forwarded Leave
				
				
				delete from T0200_Hold_Sal_FNF WHERE SAL_TRAN_ID_effect = @SAL_TRAN_ID and cmp_ID = @CMP_ID -- Added By Gadriwala Muslim 10072014
				DELETE FROM T0200_TRAINING_BOND_RECOVER WHERE EMP_ID = @EMP_ID -- ADDED BY GADRIWALA MUSLIM 01122016
				
--added By Mukti(start)18032015 
	if exists(select 1 from T0140_Asset_Transaction WITH (NOLOCK) where Emp_ID = @EMP_ID and Cmp_ID = @CMP_ID and SAL_TRAN_ID = @SAL_TRAN_ID)
		begin
			delete from T0140_Asset_Transaction where Emp_ID = @EMP_ID and Cmp_ID = @CMP_ID and SAL_TRAN_ID = @SAL_TRAN_ID
		end
		
	if exists(select Asset_Approval_ID from T0130_Asset_Approval_Det WITH (NOLOCK) where Cmp_ID = @CMP_ID and SAL_TRAN_ID = @SAL_TRAN_ID)
		begin
			select @Asset_Approval_ID=Asset_Approval_ID,@assetm_id=assetm_id from T0130_Asset_Approval_Det WITH (NOLOCK) where Cmp_ID = @CMP_ID and SAL_TRAN_ID = @SAL_TRAN_ID
			
			UPDATE ad SET ad.allocation=1
			FROM T0040_Asset_Details ad
			JOIN T0130_Asset_Approval_Det aa ON aa.AssetM_ID = ad.AssetM_ID
			where aa.Asset_Approval_ID=@Asset_Approval_ID and aa.Cmp_ID=@Cmp_ID and ad.assetm_id=@AssetM_ID 
			
			delete from T0130_Asset_Approval_Det where Asset_Approval_ID = @Asset_Approval_ID and Cmp_ID = @CMP_ID and SAL_TRAN_ID = @SAL_TRAN_ID
			delete from T0120_Asset_Approval where Emp_ID = @EMP_ID and Cmp_ID = @CMP_ID and Asset_Approval_ID = @Asset_Approval_ID
					
		end
		Delete FROM T0020_Interest_Deduction_FNF where Cmp_ID = @Cmp_ID and Emp_ID = @EMP_ID
--added By Mukti(start)18032015

		Delete from T0210_Uniform_Monthly_Payment where Cmp_ID = @Cmp_ID and Emp_ID = @EMP_ID and SAL_TRAN_ID = @SAL_TRAN_ID --Mukti(12052017)
		Delete from T0140_MONTHLY_LATEMARK_TRANSACTION where Cmp_ID = @Cmp_ID and Emp_ID = @EMP_ID and SAL_TRAN_ID = @SAL_TRAN_ID
		DELETE FROM T0140_MONTHLY_LATEMARK_DESIGNATION WHERE Cmp_ID = @Cmp_ID and Emp_ID = @EMP_ID and SAL_TRAN_ID = @SAL_TRAN_ID
		end
	RETURN




