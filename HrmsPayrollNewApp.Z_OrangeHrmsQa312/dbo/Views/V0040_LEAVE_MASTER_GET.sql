










CREATE VIEW [dbo].[V0040_LEAVE_MASTER_GET]
AS
	SELECT	Leave_ID,Leave_Code, Leave_Name, Leave_Type, Leave_Count, Leave_Paid_Unpaid, Leave_Min, Leave_Max,Leave_Min_Bal, Leave_Max_Bal,Leave_Min_Encash, 
			Leave_Max_Encash, Leave_Notice_Period, Leave_Applicable, Leave_CF_Type, Leave_PDays, Leave_Get_Against_PDays,Leave_Bal_Reset_Month,Leave_negative_Allow,
			Leave_Auto_Generation,Leave_cf_Month,isnull(Salary_On_Leave,0) as Salary_On_Leave,isnull(Is_Late_Adj,0) as Is_Late_Adj,Isnull(Is_Ho_Wo,0) As Is_Ho_Wo , 
			isnull(Weekoff_as_leave,0) as Weekoff_as_leave , isnull(Holiday_as_leave,0) as Holiday_as_leave , isnull(Leave_Sorting_No,0) as Leave_Sorting_No , 
			isnull(No_Days_To_Cancel_WOHO,0) as No_Days_To_Cancel_WOHO , isnull(Display_leave_balance,1) Display_leave_balance, isnull(is_Leave_CF_Rounding,0) is_Leave_CF_Rounding, 
			isnull(is_Leave_CF_Prorata,0) is_Leave_CF_Prorata, isnull(is_Leave_Clubbed,0) is_Leave_Clubbed,isnull(Can_Apply_Fraction,1) Can_Apply_Fraction,
			isnull(Is_CF_On_Sal_Days,0) Is_CF_On_Sal_Days,isnull(Days_As_Per_Sal_Days,0) Days_As_Per_Sal_Days,isnull(Max_Accumulate_Balance,0) Max_Accumulate_Balance,
			isnull(Min_Present_Days,0) Min_Present_Days,isnull(Max_No_Of_Application,0) Max_No_Of_Application,
			isnull(L_Enc_Percentage_Of_Current_Balance,0) L_Enc_Percentage_Of_Current_Balance,isnull(Encashment_After_Months,0) Encashment_After_Months,
			isnull(leave_Status,0) leave_Status, isnull(InActive_Effective_Date,getdate()) as InActive_Effective_Date,isnull(leave_club_with,0) as leave_club_with,
			isnull(is_Document_Required,0) is_Document_Required, isnull(Effect_Of_LTA,0) Effect_Of_LTA,Apply_Hourly,BalanceToSalary,AllowNightHalt,isnull(Attachment_Days,0)Attachment_Days, 
			Half_Paid,leave_negative_max_limit,MinPdays_Type,Trans_Leave_ID,Including_Holiday,Including_WeekOff,Including_Leave_Type,Lv_Encase_Calculation_Day,
			isnull(Multi_Branch_ID,'') as Multi_Branch_ID, Medical_Leave,Leave_EncashDay_Half_Payment,ISNULL(Max_CF_From_Last_Yr_Balance,0) as Max_CF_From_Last_Yr_Balance,
			ISNULL(Punch_Required,0) as Punch_Required,ISNULL(PunchBoth_Required,0) as PunchBoth_Required,ISNULL(Is_Advance_Leave_Balance,0) as Is_Advance_Leave_Balance,Is_InOut_Show_In_Email,Effect_Salary_Cycle,Monthly_Max_Leave,
			NoticePeriod_Type,Working_Days,Consecutive_Days,Min_Leave_Not_Mandatory,Consecutive_Club_Days,Working_Club_Days,Calculate_on_Previous_Month,No_Of_Allowed_Leave_CF_Yrs,
			Paternity_Leave_Balance,Paternity_Leave_Validity, IsNull(Allowed_CF_Join_After_Day,0) As Allowed_CF_Join_After_Day
			,First_Min_Bal_then_Percent_Curr_Balance ,Add_In_Working_Hour,Restrict_LeaveAfter_ExitNotice,Adv_Balance_Round_off,Adv_Balance_Round_off_Type
			,Max_Leave_Lifetime,ISNULL(Is_Auto_Leave_From_Salary,0) as Is_Auto_Leave_From_Salary,ISNULL(IsDoubleDeduct,0) as IsDoubleDeduct,isnull(Multi_Allowance_ID,'') as Multi_Allowance_ID,ISNULL(Count_WeekOff_Notice_Period,0) AS Count_WeekOff_Notice_Period,ISNULL(Leave_Continuity,0) as Leave_Continuity
	FROM	dbo.T0040_LEAVE_MASTER WITH (NOLOCK)






