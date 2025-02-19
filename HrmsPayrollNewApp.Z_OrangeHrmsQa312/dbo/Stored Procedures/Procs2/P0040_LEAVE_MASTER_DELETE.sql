
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_LEAVE_MASTER_DELETE]
	@Leave_ID  numeric(9,0) output,
	@Cmp_ID numeric(9,0),
	@User_Id numeric(18,0) = 0,
	@IP_Address varchar(30)= ''
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	DECLARE @CarryForwardHours numeric
	SET @CarryForwardHours = 0
	
	Declare @Old_Leave_Name  varchar(50)
	Declare @Old_Leave_Code  varchar(5)
	Declare @Old_Leave_Applicable numeric(18,0)
	Declare @Old_Leave_Type varchar(50)
	Declare @Old_Leave_Sorting_No numeric(18,0)
	Declare @Old_Leave_Paid_Unpaid char(1)
	Declare @Old_Is_Adj_Late  tinyint
	Declare @Old_Is_Leave_CF_Prorata tinyint
	Declare @Old_Is_Leave_Clubbed tinyint 
	Declare @Old_Can_Apply_Fraction tinyint
	Declare @Old_Is_Leave_CF_Rounding tinyint
	Declare @Old_Leave_Negative_Allow numeric
	Declare @Old_Holiday_as_leave tinyint
	Declare @Old_Display_leave_balance tinyint
	Declare @Old_Weekoff_as_leave tinyint 
	Declare @Old_Leave_Status numeric(18, 2)
	Declare @OldValue as varchar(max)
	Declare @Old_Leave_Min_Bal numeric(18,1)
	Declare @Old_Leave_Min_Encash numeric(18,1)
	Declare @Old_Leave_Max_Encash numeric(18,1)
	Declare @Old_Max_No_Of_Application	numeric(18, 0)
	Declare @Old_L_Enc_Percentage_Of_Current_Balance numeric(18, 2)
	Declare @Old_Encashment_After_Months numeric(18, 2)
	Declare @Old_Document_required tinyint  -- Added by rohit on 13122013
	Declare @Old_Effect_Of_LTA int --Added by Ripal 16Jan2014
	Declare @OldApply_Hourly int ------Added by Sid 07022014
	Declare @OldCarryForwardHours varchar(5) ------Added by Sid 07022014
	Declare @OldBalanceToSalary int			 ------Added by Sid 07022014
	Declare @OldAllowNightHalt int
	Declare @OldHalf_Paid int
	Declare @OldNeg_Max_limit numeric(18,2)
	Declare @OldMinPDay_Type tinyint -- Added by Gadriwala Muslim 10022015
	Declare @OldLeave_Trans_ID numeric(18,0) -- Added by Gadriwala Muslim 16022015
	Declare @OldIncluding_Holiday numeric(1,0) --Added by nilesh Patel on 27032015 
	Declare @OldIncluding_WeekOff numeric(1,0) --Added by nilesh Patel on 27032015 
	Declare @OldLv_Encase_Calculation_Day numeric(18,2)
	Declare @OldMulti_Branch_ID nvarchar(max)  -- Added by Gadriwala Muslim 06072015
	Declare @OldMedical_Leave tinyint -- Added by Gadriwala Muslim 14092015
	Declare @OldLeave_EncashDay_Half_Payment tinyint
	DECLARE @OldMax_Leave_Carry_Forward_From_Last_Year NUMERIC(18,1)
	DECLARE @OldPunch_Required INT  --Mukti(18-05-2016)
	Declare @OldAdvance_Leave_Balance tinyint -- Added by Nilesh Patel on 03022016
	Declare	@OldIs_InOut_Show_In_Email tinyint --added by jimit 06102016
	Declare @Old_Effect_Salary_Cycle tinyint   --Added by Jaina 18-03-2017
	Declare @Old_Monthly_Max_Leave numeric(18,1)  --Added by Jaina 27-03-2017
	Declare @Old_NoticePeriod_Type tinyint --Added by  Jaina 15-04-2017
	Declare @Old_Working_Days numeric(18,2)
	Declare @Old_Consecutive_Days numeric(18,2)
	Declare @Old_Min_Leave_Not_Mandatory numeric(18,2) 
	Declare @Old_Consecutive_Club_Days numeric(18,2)
	Declare @Old_Working_Club_Days numeric(18,2)
	Declare @Old_Calculate_on_Previous_Month numeric(18,2)
	Declare @Old_No_Of_Allowed_Leave_CF_Yrs TinyInt
	Declare @Old_Paternity_Leave_Balance numeric(18,2)
	Declare @Old_Paternity_Leave_Validity numeric(18,2)
	Declare @Old_Allowed_CF_Join_After_Day As Varchar(10)
	Declare @Old_First_Min_Bal_then_Percent_Curr_Balance As Varchar(10)
	declare @Old_Restrict_LeaveAfter_ExitNotice as varchar(10)
	declare @Old_Max_Leave_Lifetime as varchar(10)
	
	SET @OldNeg_Max_limit =0
	SET @OldLv_Encase_Calculation_Day =0
	SET @Old_Leave_Name = ''
	SET @Old_Leave_Code  = ''
	SET @Old_Leave_Applicable = 0
	SET @Old_Leave_Type = ''
	SET @Old_Leave_Sorting_No = 0
	SET @Old_Leave_Paid_Unpaid = ''
	SET @Old_Is_Adj_Late  = 0
	SET @Old_Is_Leave_CF_Prorata  = 0
	SET @Old_Is_Leave_Clubbed  = 1
	SET @Old_Can_Apply_Fraction = 1
	SET @Old_Is_Leave_CF_Rounding = 0
	SET @Old_Leave_Negative_Allow = 0
	SET @Old_Holiday_as_leave = 0
	SET @Old_Display_leave_balance = 1
	SET @Old_Weekoff_as_leave = 0
	SET @Old_Leave_Status = 0
	SET @OldValue = ''
	SET @Old_Leave_Min_Bal = 0
	SET @Old_Leave_Min_Encash = 0
	SET @Old_Leave_Max_Encash = 0
	SET @Old_Max_No_Of_Application = 0
	SET @Old_L_Enc_Percentage_Of_Current_Balance = 0
	SET @Old_Encashment_After_Months = 0
	SET @Old_Document_required = 0  -- Added by rohit on 13122013
	SET @Old_Effect_Of_LTA = 0 -- Added By Ripal 16Jan2014
	SET @OldApply_Hourly = 0		-----Added by Sid 07022014
	SET @OldCarryForwardHours = 0	-----Added by Sid 07022014
	SET @OldBalanceToSalary = 0		-----Added by Sid 07022014
	SET @OldAllowNightHalt = 0
	SET @OldHalf_Paid = 0
	SET @OldMinPDay_Type = 0
	SET @OldLeave_Trans_ID = 0 -- Added by Gadriwala Muslim 16022015
	SET @OldIncluding_Holiday  = 0 -- Added by Nilesh Patel on 27032015
	SET @OldIncluding_WeekOff = 0 -- Added by Nilesh Patel on 27032015
	SET @OldMulti_Branch_ID = ''
	SET @OldMedical_Leave = 0 -- Added by Gadriwala Muslim 14092015
	SET @OldLeave_EncashDay_Half_Payment = 0
	SET @OldMax_Leave_Carry_Forward_From_Last_Year = 0
	SET @OldPunch_Required = 0 --Mukti(18-05-2016)
	SET @OldAdvance_Leave_Balance = 0
	SET @Old_Effect_Salary_Cycle = 0
	SET @Old_Monthly_Max_Leave = 0
	SET @Old_NoticePeriod_Type = 0
	SET @Old_Working_Days = 0
	SET @Old_Consecutive_Days = 0
	SET @Old_Min_Leave_Not_Mandatory = 0
	SET @Old_Consecutive_Club_Days = 0
	SET @Old_Working_Club_Days = 0
	SET @OldIs_InOut_Show_In_Email = 0  --added by jimit 06102016
	SET @Old_Calculate_on_Previous_Month = 0 --Mukti(24082017)
	
	SET @Old_Paternity_Leave_Balance = 0
	SET @Old_Paternity_Leave_Validity = 0
	
	SET @Old_Allowed_CF_Join_After_Day = '0'
	
	SET @Old_First_Min_Bal_then_Percent_Curr_Balance = 0
	set @Old_Restrict_LeaveAfter_ExitNotice = '0'
	set @Old_Max_Leave_Lifetime = '0'
	
	Select	@OldValue = 'old Value' 
				+ '#Leave Name :' + ISNULL(Leave_Name,'') 
		From	T0040_LEAVE_MASTER WITH (NOLOCK) Where Leave_ID = @Leave_ID
		
				
		BEGIN TRY							
			--EXEC P0050_Leave_Cf_Monthly_Setting 0,@Leave_ID,'1-jan-2000',@Cmp_ID,0,'D',NULL,NULL
			EXEC P0050_Leave_Cf_Monthly_Setting @Leave_Tran_ID=0,@Leave_ID=@Leave_ID,@For_Date = NULL,@Cmp_ID=@Cmp_ID,@CF_M_Days=0,@CF_M_DaysAfterJoining=0,@tran_type='D',@Effective_Date=NULL,@Type_ID=NULL
			
			DELETE FROM T0050_CF_EMP_TYPE_DETAIL where Cmp_ID=@Cmp_ID and Leave_ID=@Leave_ID    -- Added By Gadriwala 25022015
			DELETE FROM dbo.T0040_LEAVE_MASTER where Leave_ID = @Leave_ID					
			DELETE FROM dbo.T0050_LEAVE_DETAIL where Leave_ID = @Leave_ID and Cmp_ID = @Cmp_ID
			DELETE FROM dbo.T0050_LEAVE_CF_SLAB  where Leave_ID = @Leave_ID	 and Cmp_ID = @Cmp_ID	-- Added by nilesh Patel on 01042015
			DELETE FROM dbo.T0050_LEAVE_CF_Present_Day  where Leave_ID = @Leave_ID	 and Cmp_ID = @Cmp_ID -- Added by nilesh Patel on 01042015				
			DELETE FROM T0045_LEAVE_APP_NOTICE_SLAB WHERE CMP_ID=@CMP_ID AND LEAVE_ID=@LEAVE_ID   --Added by Jaina 20-04-2017
			DELETE FROM T0045_Leave_Shutdown_Period WHERE CMP_ID=@CMP_ID AND LEAVE_ID=@LEAVE_ID   --Added by Jaina 03-05-2017
		END TRY
		BEGIN CATCH
			DECLARE @Message Varchar(Max)
			SET @Message = ERROR_MESSAGE();
			IF CHARINDEX('DELETE statement conflicted with the REFERENCE constraint',@Message) > 0					
				SET @Message = '@@Reference Already Exist!@@'						
								
			RAISERROR(@Message,16,2)
		END CATCH
		
	
	EXEC P9999_Audit_Trail @Cmp_ID,1,'Leave Master',@OldValue,@Leave_ID,@User_Id,@IP_Address			
	RETURN




