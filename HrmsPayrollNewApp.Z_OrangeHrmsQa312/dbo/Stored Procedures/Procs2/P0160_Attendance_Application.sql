

-- =============================================
-- Author:		Nilesh Patel
-- Create date: 12/07/2018
-- Description:	Attendance Adjust against previouse Month OT 
-- =============================================
CREATE PROCEDURE [dbo].[P0160_Attendance_Application]
	-- Add the parameters for the stored procedure here
	@Att_App_ID Numeric(18,0) output,
	@Cmp_ID Numeric(18,0),
	@Emp_ID Numeric(18,0),
	@For_Date Datetime,
	@Shift_Dur Varchar(10),
	@P_Days Numeric(5,2),
	@Tran_Type Char(1),
	@Modify_By Varchar(10),
	@Ip_Address Varchar(20)
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	
	
	if @Tran_Type = 'I'
		Begin
			
			IF Exists(Select 1 From T0160_Attendance_Application WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and For_Date = @For_Date)
				Begin
					RAISERROR('@@Same Date Request is Exists.. @@',16,2)
					return
				End

			Select @Att_App_ID = Isnull(Max(Att_App_ID),0) + 1 From T0160_Attendance_Application WITH (NOLOCK)

			IF Exists(Select 1 From T0200_Monthly_Salary WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and @For_Date Between Month_St_Date and (Case When Cutoff_Date is not null Then Cutoff_Date Else Month_End_Date END))
				Begin
					RAISERROR('@@Salary is Exists for this period@@',16,2)
					return
				End
			
			Declare @Shift_Dur_Sec Numeric(18,0)

			if @P_Days = 1 
				Set @Shift_Dur_Sec = dbo.F_Return_Sec(@Shift_Dur)
			Else if @P_Days = 0.50
				Set @Shift_Dur_Sec = dbo.F_Return_Sec(@Shift_Dur)/2
			Else 
				Set @Shift_Dur_Sec = 0

			Insert into T0160_Attendance_Application(Att_App_ID,Cmp_ID,Emp_ID,For_Date,Shift_Sec,P_Days,Modify_By,Modify_Date,Ip_Address)
			Values(@Att_App_ID,@Cmp_ID,@Emp_ID,@For_Date,@Shift_Dur_Sec,@P_Days,@Modify_By,Getdate(),@Ip_Address)
		End
	Else if @Tran_Type = 'D'
		Begin
			If Exists(Select 1 from T0165_Attendance_Approval WITH (NOLOCK) Where Att_App_ID = @Att_App_ID)
				Begin
					Set @Att_App_ID = 0
					return 
				End
			Delete From T0160_Attendance_Application Where Att_App_ID = @Att_App_ID
		End
END

