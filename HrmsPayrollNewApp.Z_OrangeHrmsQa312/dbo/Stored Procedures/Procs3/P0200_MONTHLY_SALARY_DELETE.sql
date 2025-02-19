---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0200_MONTHLY_SALARY_DELETE]
	@SAL_TRAN_ID		NUMERIC ,
	@EMP_ID				NUMERIC,
	@CMP_ID				NUMERIC,
	@From_Date 	datetime,
	@to_date	Datetime,
	@ErrString	varchar(500) output,
	@User_Id numeric(18,0) = 0,	-- Added for audit trail By Ali 17102013
	@IP_Address varchar(30)= ''	-- Added for audit trail By Ali 17102013
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	--Added for audit trail By Ali 16102013 -- Start
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
	Declare @Old_mid_Net_Round_Diff_Amount as numeric(18,2) -- Added by Gadriwala Muslim 08102014
	declare @Receive_Amount as numeric(18,2) --Mukti 24032015
	declare @AssetM_Id  as numeric(18,0) --Mukti 24032015
	declare @Asset_Approval_ID as numeric(18,0) --Mukti 24032015
	Declare @Old_Bond_Amount as numeric(18,2) -- Added by Rajput on 04102018
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
	set @Old_mid_Net_Round_Diff_Amount = 0
	set @Old_Bond_Amount = 0 -- Added by rajput on 04102018
	--Added for audit trail By Ali 16102013 -- End
	SET NOCOUNT ON 
	
	declare @Branch_ID as numeric(18,0)
	
	set @Branch_ID = 0
	
	declare @sal_date datetime	
	declare @sal_end_date datetime	
	
	SELECT 	@SAL_DATE = MONTH_ST_DATE , @sal_end_date = Month_End_Date  FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE SAL_TRAN_ID = @SAL_TRAN_ID

	select  @Branch_ID = Branch_ID
				From T0095_Increment I WITH (NOLOCK) inner join     
				 ( select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK)    --Changed by Hardik 10/09/2014 for Same Date Increment  
				 where Increment_Effective_date <= @sal_end_date    
				 and Cmp_ID = @Cmp_ID And Emp_ID = @Emp_ID
				 group by emp_ID ) Qry on    
				 I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id    
			  Where I.Emp_ID = @Emp_ID  

	--Hardik 28/02/2013
	
	
	Declare @manual_salary_period as numeric(18,0) 

	If @Branch_ID is null
		Begin 
			select Top 1 @Manual_salary_period=isnull(Manual_Salary_Period ,0) 
			from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
			and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@to_date and Cmp_ID = @Cmp_ID)    
		End
	Else
		Begin
			select @Manual_salary_period=isnull(Manual_Salary_Period ,0) 
			from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
			and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@to_date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
		End 

			  
	IF EXISTS(SELECT 1 FROM  T0250_MONTHLY_LOCK_INFORMATION WITH (NOLOCK) WHERE MONTH =  MONTH(@sal_end_date) and YEAR =  year(@sal_end_date) and Cmp_ID = @CMP_ID and (Branch_ID = isnull(@Branch_ID,0) or Branch_ID = 0))
		Begin
			Raiserror('@@This month salary is locked by admin.@@',16,2)
			return -1			
		End
			  
	
	
	IF EXISTS(SELECT EMP_ID FROM  T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE EMP_ID =@EMP_ID AND  Month_St_Date >= @To_Date)
		Begin
			Raiserror('@@Salary already exist for the next month. Delete the next month salary first.@@',16,2)
			return -1
		End
	
	
	If Exists(Select Pf_Challan_Id From dbo.T0220_Pf_Challan WITH (NOLOCK) Where Cmp_Id=@Cmp_Id And Month=Month(@To_Date) And Year = Year(@To_Date) And CHARINDEX('#'+ Cast(@Branch_ID As VARCHAR(18)) +'','#' + Branch_ID_Multi) > 0)
		Begin
				RAISERROR ('@@PF Challan is generated for this month salary. Delete the challan first.@@', -- Message text.
									16, -- Severity.
									1   -- State.
									);
				RETURN
		End
    If Exists(Select Esic_Challan_Id From dbo.T0220_ESIC_Challan WITH (NOLOCK) Where Cmp_Id=@Cmp_Id And Month=Month(@To_Date) And Year = Year(@To_Date) And CHARINDEX('#'+ Cast(@Branch_ID As VARCHAR(18)) +'','#' + Branch_ID_Multi) > 0)
		Begin
				RAISERROR ('@@ESIC Challan is generated for this month salary. Delete the challan first.@@', -- Message text.
									16, -- Severity.
									1   -- State.
									);
				RETURN
		End
		--Added By Jaina 28-09-2015 Start
	If Exists(Select Challan_Id  From dbo.T0220_PT_CHALLAN WITH (NOLOCK) Where Cmp_Id=@Cmp_Id And Month=Month(@To_Date) And Year = Year(@To_Date) And CHARINDEX('#'+ Cast(@Branch_ID As VARCHAR(18)) +'','#' + Branch_ID_Multi) > 0)
		Begin
				RAISERROR ('@@PT Challan is generated for this month salary. Delete the challan first.@@', -- Message text.
									16, -- Severity.
									1   -- State.
									);
				RETURN
		End
	--added by chetan 27122017
			If Exists(Select  Challan_Id From dbo.T0220_TDS_CHALLAN WITH (NOLOCK) Where Cmp_Id=@Cmp_Id And Month=Month(@To_Date) And Year = Year(@To_Date))
				Begin
					RAISERROR ('@@TDS Challan is generated for this month salary. Delete the challan first.@@', -- Message text.
								16, -- Severity.
								1   -- State.
								);
					RETURN
				End
		--Added By Jaina 28-09-2015 Start
	IF EXISTS(SELECT EMP_ID FROM  T0201_MONTHLY_SALARY_SETT WITH (NOLOCK) WHERE Cmp_Id=@Cmp_Id And Emp_Id=@Emp_id And S_Month_St_Date>=@From_Date and S_Month_End_Date<=@to_date )
		Begin
			Raiserror('@@This Month Salary Settlement Exists.@@',16,2)
			return -1
		End
		
		-- changed by rohit for salary delete if Allowance payment is calculate on imported value.
	--IF EXISTS(SELECT EMP_ID FROM  MONTHLY_EMP_BANK_PAYMENT WHERE EMP_ID=@EMP_ID AND month(for_date)=Month(@To_Date) and Year(for_date)=Year(@To_Date) )
	--		Begin	
	--			Raiserror('@@Payment Process Exists for this month@@',16,2)
	--			return -1	
	--		end	
	
	IF EXISTS(SELECT EMP_ID from MONTHLY_EMP_BANK_PAYMENT MEB
			 left join (select * from T0050_AD_MASTER WITH (NOLOCK) where Is_Calculated_On_Imported_Value =0)  AM on MEB.Ad_Id = AM.AD_ID 
			 WHERE MEB.EMP_ID=@EMP_ID AND month(MEB.for_date)=Month(@To_Date) and Year(MEB.for_date)=Year(@To_Date) and (MEB.Process_Type ='Salary' or isnull(Am.Ad_id,0)> 0 ) )
			 
			Begin	
				Raiserror('@@Payment Process Exists for this month@@',16,2)
				return -1	
			end	
		
	IF EXISTS(SELECT EMP_ID from T0302_Process_Detail MEB WITH (NOLOCK)
			 left join (select AD_ID from T0050_AD_MASTER WITH (NOLOCK) where Is_Calculated_On_Imported_Value =0 and isnull(Allowance_Type,'A')='A')  AM on MEB.Ad_Id = AM.AD_ID 
			 WHERE MEB.EMP_ID=@EMP_ID AND month(MEB.for_date)=Month(@To_Date) and Year(MEB.for_date)=Year(@To_Date) and isnull(AM.Ad_id,0)> 0 and  meb.payment_process_id > 0  )
			 
			Begin	
				Raiserror('@@Payment Detail Exists for this month@@',16,2)
				return -1	
			end	
		
	--ADDED BY RAMIZ ON 05/10/2018 FOR BOND MODULE-- (IF PAYMENT PROCESS IS ALREADY DONE , THEN SALARY CANNOT BE DELETED )
	IF EXISTS(SELECT MEB.EMP_ID FROM MONTHLY_EMP_BANK_PAYMENT MEB
				INNER JOIN T0120_BOND_APPROVAL BA WITH (NOLOCK) ON BA.Emp_Id = MEB.Emp_ID AND BA.Payment_Process_ID = MEB.payment_process_id
				WHERE MEB.Process_Type ='Bond' and MEB.EMP_ID=@EMP_ID and Bond_Return_Date >= @From_Date )
		BEGIN	
			RAISERROR('@@Bond Payment Process Exists for this month@@',16,2)
			RETURN -1	
		END	
					
											-- Added for audit trail by Ali 16102013 -- Start
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
														, @Old_mid_Net_Round_Diff_Amount = Net_Salary_Round_Diff_Amount --Added by Gadriwala Muslim 08102014
														, @Old_Bond_Amount = Bond_Amount -- Added by Rajput on 04102018
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
													+ '#' + 'Salary Calculate Days :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Sal_Cal_Days,0))
													+ '#' + 'Present Days :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Present_Days,0))
													+ '#' + 'Absent Days :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Absent_Days,0))
													+ '#' + 'Holiday Days :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Holiday_Days,0))
													+ '#' + 'Weekoff Days :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Weekoff_Days,0))
													+ '#' + 'Cancel Holiday :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Cancel_Holiday,0))
													+ '#' + 'Cancel Weekoff :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Cancel_Weekoff,0))													
													+ '#' + 'Outof Days :' + CONVERT(nvarchar(100),ISNULL(@Old_Outof_Days,0))
													+ '#' + 'Paid Leave Days :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Paid_Leave_Days,0))
													+ '#' + 'Actual Working Hours :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Actual_Working_Hours,0))
													+ '#' + 'Working Hours :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Working_Hours,0))
													+ '#' + 'Outof Hours :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Outof_Hours,0))
													+ '#' + 'Employee OT Hours :' + CONVERT(nvarchar(100),ISNULL(@Old_Emp_OT_Hours_Num,0))
													+ '#' + 'On Duty Leave Days :' + CONVERT(nvarchar(100),ISNULL(@Old_Mid_OD_leave_Days,0))
													+ '#' + 'Shift Day In Sec :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Shift_Day_Sec,0))
													+ '#' + 'Shift Day In Hour :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Shift_Day_Hour,0))
													+ '#' + 'Early Sec :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Early_Sec,0))
													+ '#' + 'Early Days :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Early_Days,0))
													+ '#' + 'Late Sec :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Late_Sec,0))
													+ '#' + 'Late Days :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Late_Days,0))
													+ '#' + 'Late Early Penalty days :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Late_Early_Penalty_days,0))
													+ '#' + 'Total Leave Days :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Total_Leave_Days,0))
													+ '#' + 'Working Days :' + CONVERT(nvarchar(100),ISNULL(@Old_Working_Days,0))
													+ '#' + 'Total Hours :' + ISNULL(@Old_Total_Hours,'')
													+ '#' + 'PT LIMIT :' + ISNULL(@Old_mid_PT_F_T_LIMIT,'')
													+ '#' + 'basic Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_basic_Amount,0))
													+ '#' + 'Day Salary :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Day_Salary,0))
													+ '#' + 'Hour Salary :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Hour_Salary,0))
													+ '#' + 'Salary Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_salary_Amount,0))
													+ '#' + 'Allowance Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Allow_Amount,0))
													+ '#' + 'Other Allowance Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Other_Allow_Amount,0))
													+ '#' + 'OT Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_OT_Amount,0))
													+ '#' + 'Leave Salary Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Leave_Salary_Amount,0))
													+ '#' + 'Bonus Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Bonus_Amount,0))
													+ '#' + 'WeekOff OT Hours :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_M_WO_OT_Hours,0))
													+ '#' + 'WeekOff OT Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_M_WO_OT_Amount,0))
													+ '#' + 'Holiday OT Hours :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_M_HO_OT_Hours,0))
													+ '#' + 'Holiday OT Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_M_HO_OT_Amount,0))
													+ '#' + 'Salary Amount Arear :' + CONVERT(nvarchar(100),ISNULL(@Old_Salary_amount_Arear,0))
													+ '#' + 'Gross Salary Arear :' + CONVERT(nvarchar(100),ISNULL(@Old_Gross_Salary_Arear,0))
													+ '#' + 'Arear Day :' + CONVERT(nvarchar(100),ISNULL(@Old_Arear_Day,0))
													+ '#' + 'Total Earning Fraction :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Total_Earning_Fraction,0))
													+ '#' + 'Gross Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_gross_Amount,0))
													+ '#' + 'Deduction Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Dedu_Amount,0))
													+ '#' + 'Loan Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Loan_Amount,0))
													+ '#' + 'Loan Intrest Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Loan_Intrest_Amount,0))
													+ '#' + 'Bond Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_Bond_Amount,0)) --Added by Rajput on 40102018
													+ '#' + 'Advance Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Advance_Amount,0))
													+ '#' + 'Other Deduction Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Other_Dedu_Amount,0))
													+ '#' + 'Due Loan Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Due_Loan_Amount,0))
													+ '#' + 'PT Calculated Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_PT_Calculated_Amount,0))
													+ '#' + 'PT Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_PT_Amount,0))
													+ '#' + 'Total Claim Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Total_Claim_Amount,0))
													+ '#' + 'IT Tax :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_M_IT_Tax,0))
													+ '#' + 'ADVANCE Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_M_ADv_Amount,0))
													+ '#' + 'Loan Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_M_Loan_Amount,0))
													+ '#' + 'OT Hours :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_M_OT_Hours,0))
													+ '#' + 'LWF Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_LWF_Amount,0))
													+ '#' + 'Revenue Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_REvenue_Amount,0))
													+ '#' + 'Late Deduction Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Late_Dedu_Amount,0))
													+ '#' + 'Extra Late Deduction :' + CONVERT(nvarchar(100),ISNULL(@Old_Extra_Late_Deduction,0))
													+ '#' + 'Extra Absent Days :' + CONVERT(nvarchar(100),ISNULL(@Old_Extra_AB_Days,0))
													+ '#' + 'Extra Absent Rate :' + CONVERT(nvarchar(100),ISNULL(@Old_Extra_AB_Rate,0))
													+ '#' + 'Extra Absent Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_Extra_AB_Amount,0))	
													+ '#' + 'Early Deduction Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Early_Dedu_Amount,0))
													+ '#' + 'Early Extra Deduction Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Early_Extra_Dedu_Amount,0))
													+ '#' + 'IT ED Cess Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_IT_M_ED_Cess_Amount,0))
													+ '#' + 'IT Surcharge Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_IT_M_Surcharge_Amount,0))
													+ '#' + 'Total Deduction Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Total_Dedu_Amount,0))
													+ '#' + 'Gross Salary ProRata :' + CONVERT(nvarchar(100),ISNULL(@Old_Gross_Salary_ProRata,0))		
													+ '#' + 'Settlement Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_Settelement_Amount,0))
													+ '#' + 'Net Round Diff Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Net_Round_Diff_Amount,0))
													+ '#' + 'Net Amount :' + CONVERT(nvarchar(100),ISNULL(@Old_mid_Net_Amount,0))
													+ '#' + 'Status :' + CONVERT(nvarchar(100),ISNULL(@Old_Status,0))																							
												exec P9999_Audit_Trail @Cmp_ID,'D','Salary Monthly/Manually',@Oldvalue,@Emp_ID,@User_Id,@IP_Address,1				
											-- Added for audit trail by Ali 16102013 -- End	
	DELETE FROM T0210_Monthly_Salary_Slip_Gradecount where Sal_tran_Id=@SAL_TRAN_ID and emp_id=@EMP_ID --Added by Ramiz 23112015										
	DELETE FROM T0210_PAYSLIP_DATA	WHERE SAL_TRAN_ID = @SAL_TRAN_ID	
	DELETE FROM T0210_MONTHLY_LOAN_PAYMENT WHERE SAL_TRAN_ID = @SAL_TRAN_ID 
	--DELETE FROM T0210_MONTHLY_CLAIM_PAYMENT WHERE SAL_TRAN_ID = @SAL_TRAN_ID
	exec SP_CALCULATE_CLAIM_TRANSACTION @Cmp_ID,@EMP_ID,@From_Date,0,@From_Date,@to_date,0,'D'
	DELETE FROM T0210_MONTHLY_AD_DETAIL WHERE SAL_TRAN_ID = @SAL_TRAN_ID AND EMP_ID =@EMP_id 	
	DELETE FROM T0210_MONTHLY_LEAVE_DETAIL WHERE SAL_TRAN_ID = @SAL_TRAN_ID AND EMP_ID =@EMP_id 
	DELETE FROM T0210_LWP_Considered_Same_Salary_Cutoff WHERE SAL_TRAN_ID = @SAL_TRAN_ID AND EMP_ID =@EMP_id 
	
	-- Added Cutoff Condition by Nilesh patel on 29-12-2018 -- Late Mark Case occur in Monarch Client
	Declare @curleave_ID numeric(18,0)
	Declare @CutOff_Date DATETIME
	Select @CutOff_Date = Cutoff_Date From T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE SAL_TRAN_ID = @SAL_TRAN_ID AND EMP_ID =@EMP_id  
	
	IF @CutOff_Date is NULL	
		BEGIN
			set @curleave_ID = 0
			Declare curLateApproval cursor for	                  
			Select leave_id from T0160_late_Approval WITH (NOLOCK) where emp_id=@EMP_ID and For_date = @sal_end_date
			Open curLateApproval                      
					Fetch next from curLateApproval into @curleave_ID 
						While @@fetch_status = 0                    
							Begin
								delete from T0160_late_Approval where emp_id = @EMP_ID and For_date = @sal_end_date and leave_id = @curleave_ID
								fetch next from curLateApproval into @curleave_ID
							end                    
			close curLateApproval                    
			deallocate curLateApproval
		END
	Else
		BEGIN
			set @curleave_ID = 0
			Declare curLateApproval cursor for	                  
			Select leave_id from T0160_late_Approval WITH (NOLOCK) where emp_id=@EMP_ID and For_date = @CutOff_Date
			Open curLateApproval                      
				Fetch next from curLateApproval into @curleave_ID 
					While @@fetch_status = 0                    
						Begin  
							delete from T0160_late_Approval where emp_id = @EMP_ID and For_date = @CutOff_Date and leave_id = @curleave_ID
							fetch next from curLateApproval into @curleave_ID
						end                    
			close curLateApproval    
			deallocate curLateApproval
		END

	DELETE FROM T0200_MONTHLY_SALARY WHERE SAL_TRAN_ID = @SAL_TRAN_ID AND EMP_ID =@EMP_id 
	DELETE FROM t0100_Anual_bonus WHERE SAL_TRAN_ID = @SAL_TRAN_ID AND EMP_ID =@EMP_id 
	DELETE FROM T0210_MONTHLY_AD_DETAIL WHERE isnull(SAL_TRAN_ID,0) = 0 AND EMP_ID =@EMP_id
	DELETE FROM MONTHLY_EMP_BANK_PAYMENT WHERE EMP_ID = @EMP_ID AND FOR_DATE = @SAL_END_DATE and (Process_Type ='Salary' or isnull(Ad_id,0)> 0)  
	Delete from T0200_MONTHLY_SALARY_LEAVE where  sal_tran_ID=@SAL_TRAN_ID   AND EMP_ID =@EMP_id 
	DELETE from T0210_Monthly_Reim_Detail where  sal_tran_ID=@SAL_TRAN_ID   AND EMP_ID =@EMP_id 
	DELETE from t0200_salary_leave_Encashment where Sal_tran_Id=@SAL_TRAN_ID and emp_id=@EMP_ID 
	DELETE FROM T0100_LEAVE_CF_DETAIL WHERE CF_FOR_DATE BETWEEN @FROM_DATE AND @TO_DATE AND EMP_ID = @EMP_ID AND UPPER(CF_TYPE) = 'AUTO_COPH'  

	
	Declare @For_Date as datetime
	Set @For_Date = DATEADD(d,1, @sal_end_date)
	If Exists(Select Emp_ID from T0100_ADVANCE_PAYMENT WITH (NOLOCK) Where Emp_ID=@EMP_ID and Cmp_ID=@CMP_ID and For_Date = @For_Date
	and Adv_Comments like '%Due to Negative Salary%') --Mihir Trivedi on 27/07/2012 for delete negative salary advance
	BEGIN
		Delete From T0100_ADVANCE_PAYMENT where Emp_ID = @EMP_ID and Cmp_ID = @CMP_ID and For_Date = @For_Date
	END
		
--added By Mukti(start)18032015 
if exists(select 1 from T0140_Asset_Transaction WITH (NOLOCK) where Emp_ID = @EMP_ID and Cmp_ID = @CMP_ID and sal_tran_ID=@SAL_TRAN_ID  and For_Date = @sal_end_date)
		begin	
			delete from T0140_Asset_Transaction where Emp_ID = @EMP_ID and Cmp_ID = @CMP_ID and For_Date = @sal_end_date and sal_tran_ID=@SAL_TRAN_ID
		end
	if exists(select 1 from T0140_Asset_Transaction WITH (NOLOCK) where Emp_ID = @EMP_ID and Cmp_ID = @CMP_ID)
		begin	
		   	declare curDel cursor for
				select Cmp_ID ,AssetM_Id,Asset_Approval_ID from T0140_Asset_Transaction  WITH (NOLOCK) 
				where Emp_ID = @EMP_ID and Cmp_ID = @CMP_ID and for_date > @sal_end_date
			open curDel
			fetch next from curDel into @Cmp_ID, @AssetM_Id , @Asset_Approval_ID
			while @@fetch_status = 0
			begin 
					
				select @Receive_Amount=apd.Installment_Amount from T0120_Asset_Approval AP  WITH (NOLOCK)
				inner join T0130_Asset_Approval_Det APD WITH (NOLOCK) on ap.Asset_Approval_ID=apd.Asset_Approval_ID and ap.cmp_id=apd.cmp_id
				where AP.Emp_ID=@Emp_ID and AP.Cmp_ID=@cmp_id and APD.AssetM_Id=@AssetM_Id and ap.Asset_Approval_ID=@Asset_Approval_ID
							
				update T0140_Asset_Transaction set Asset_Opening = Asset_Opening + @Receive_Amount
					,Asset_closing = Asset_closing + @Receive_Amount
				where emp_id = @emp_id and for_date > @sal_end_date and AssetM_Id=@AssetM_Id and cmp_ID = @cmp_ID	
				
				fetch next from curDel into @Cmp_ID, @AssetM_Id ,@Asset_Approval_ID
			end				
			close curDel
			deallocate curDel
		end	    
	DELETE FROM T0210_Uniform_Monthly_Payment WHERE SAL_TRAN_ID = @SAL_TRAN_ID 
	DELETE FROM T0140_MONTHLY_LATEMARK_TRANSACTION WHERE SAL_TRAN_ID = @SAL_TRAN_ID 
	DELETE FROM T0140_MONTHLY_LATEMARK_DESIGNATION WHERE SAL_TRAN_ID = @SAL_TRAN_ID 
	DELETE FROM T0160_Late_Early_Validation WHERE SAL_TRAN_ID = @SAL_TRAN_ID
	DELETE FROM T0140_MONTHLY_EARLYMARK_TRANSACTION WHERE SAL_TRAN_ID = @SAL_TRAN_ID 
--added By Mukti(start)18032015
------- ADDED BY RAJPUT ON 10102018 FOR BOND MODULE (SAMARTH CLIENT) --------
	DELETE MBP
	FROM T0210_MONTHLY_BOND_PAYMENT MBP
	INNER JOIN T0120_BOND_APPROVAL BA ON BA.BOND_APR_ID = MBP.BOND_APR_ID
	WHERE MBP.SAL_TRAN_ID = @SAL_TRAN_ID AND BA.EMP_ID = @EMP_ID AND BA.CMP_ID = @CMP_ID
	
	DECLARE @BOND_RETURN_MONTH AS INT
	DECLARE @BOND_RETURN_YEAR AS INT
	
	SELECT	@BOND_RETURN_MONTH = BOND_RETURN_MONTH,
			@BOND_RETURN_YEAR = BOND_RETURN_YEAR
	FROM	T0120_BOND_APPROVAL BA WITH (NOLOCK)
	WHERE	BA.CMP_ID = @CMP_ID AND EMP_ID = @EMP_ID AND BOND_RETURN_MODE = 'S' AND ISNULL(BOND_APR_PENDING_AMOUNT,0) = 0 AND
			ISNULL(BOND_RETURN_STATUS,'Yes') = 'Yes'
	
	UPDATE	B
	SET		BOND_RETURN_STATUS = 'No',
			BOND_RETURN_DATE = NULL
	FROM	T0120_BOND_APPROVAL B
	WHERE	CMP_ID = @CMP_ID AND EMP_ID = @EMP_ID AND BOND_RETURN_MODE = 'S' AND ISNULL(BOND_APR_PENDING_AMOUNT,0) = 0 AND
			MONTH(@TO_DATE) >= @BOND_RETURN_MONTH AND YEAR(@TO_DATE) >= @BOND_RETURN_YEAR
	
	--DELETE FROM T0210_MONTHLY_BOND_PAYMENT WHERE SAL_TRAN_ID = @SAL_TRAN_ID 
	
	
	--added by Krushna 15-04-2020
	declare @Leave_Approval_ID NUMERIC(18,0)
	declare @Approval_Date datetime
	declare @Cur_Date datetime
	set @Cur_Date = getdate()
	declare curDelLeave cursor for
		Select	LA.Leave_Approval_ID,LA.Approval_Date
		from	T0120_LEAVE_APPROVAL LA WITH (NOLOCK)
				inner join T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) on LA.Leave_Approval_ID = LAD.Leave_Approval_ID
		where	La.Emp_ID = @EMP_ID and La.Cmp_ID = @CMP_ID and La.Is_Auto_Leave_From_Salary = 1 and LAD.from_date >= @SAL_DATE and LAD.To_Date <= @sal_end_date
	open curDelLeave
	fetch next from curDelLeave into @Leave_Approval_ID,@Approval_Date
	while @@fetch_status = 0
	begin 
		-- ADDED BY HARDIK 02/12/2020 AS NO NEED TO CHECK VALIDATIONS FOR AUTO LEAVE FROM SALARY OPTION..
		DELETE T0130_LEAVE_APPROVAL_DETAIL WHERE Leave_Approval_ID = @Leave_Approval_ID
		DELETE T0120_LEAVE_APPROVAL WHERE Leave_Approval_ID = @Leave_Approval_ID

		-- COMMENTED BY HARDIK 02/12/2020 AS NO NEED TO CHECK VALIDATIONS FOR AUTO LEAVE FROM SALARY OPTION..
		--exec P0120_LEAVE_APPROVAL @Leave_Approval_ID=@Leave_Approval_ID,@Leave_Application_ID=0,@Cmp_ID=0,@Emp_ID=0,@S_Emp_ID=0,@Approval_Date=@Approval_Date,@Approval_Status=''
		--	,@Approval_Comments='',@Login_ID=0,@System_Date=@Cur_Date,@tran_type='Delete',@User_Id=@User_Id,@IP_Address='',@Is_Backdated_App=0 	
		
		fetch next from curDelLeave into @Leave_Approval_ID,@Approval_Date
	end				
	close curDelLeave
	deallocate curDelLeave
	--End by Krushna 15-04-2020
	
	--------- END ---------------
RETURN