


-- =============================================
-- Author:		Nilesh Patel
-- Create date: 12/07/2018
-- Description:	Attendance Adjust against previouse Month OT 
-- =============================================
CREATE PROCEDURE [dbo].[P0165_Attendance_Approval]
	@Att_Apr_ID Numeric(18,0) output,
	@Att_App_ID Numeric(18,0),
	@Cmp_ID Numeric(18,0),
	@Emp_ID Numeric(18,0),
	@For_Date Datetime,
	@Shift_Sec Numeric(18,0),
	@P_Days Numeric(5,2),
	@Att_Status Char(1),
	@Approver_Emp_ID Numeric(18,0),
	@Remarks Varchar(500),
	@Tran_Type Char(1),
	@Modify_By Varchar(10),
	@Ip_Address Varchar(20),
	@Shift_Sec_Dur Varchar(20) = '' -- Added by nilesh for 14-02-2019
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

    -- Insert statements for procedure here
	If @Tran_Type = 'I'
		Begin
		
			Select @Cmp_ID = Cmp_ID From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_ID 

			IF Exists(Select 1 From T0200_Monthly_Salary WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and @For_Date Between Month_St_Date and (Case When Cutoff_Date is not null Then Cutoff_Date Else Month_End_Date END))
				Begin
					RAISERROR('@@Salary is Exists for this period @@',16,2)
					return
				End

			IF Exists(Select 1 From T0160_OT_APPROVAL WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and For_Date = DateAdd(Day,-1,@For_Date))
				Begin
					RAISERROR('@@OT Approval process is Exists @@',16,2)
					return
				End

			IF Exists(Select 1 From T0165_Attendance_Approval WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and For_Date = @For_Date)
				Begin
					RAISERROR('@@Same Date Request is Exists.. @@',16,2)
					return
				End

			Select @Att_Apr_ID = Isnull(Max(Att_Apr_ID),0) + 1 From T0165_Attendance_Approval WITH (NOLOCK)

			Declare @Shift_Dur_Sec Numeric(18,0)
			
			IF @Shift_Sec_Dur <> ''
				Set @Shift_Dur_Sec = dbo.F_Return_Sec(@Shift_Sec_Dur)
			Else
				Begin
					if @P_Days = 1 
						Set @Shift_Dur_Sec = @Shift_Sec
					Else if @P_Days = 0.50
						Set @Shift_Dur_Sec = @Shift_Sec/2
					Else 
						Set @Shift_Dur_Sec = 0
				End

			Insert into T0165_Attendance_Approval
			(Att_Apr_ID ,Att_App_ID,Cmp_ID,Emp_ID,For_Date,Shift_Sec,P_Days,Att_Status,Approver_Emp_ID,Remarks,Modify_By,Modify_Date,Ip_Address)
			VALUES
			(@Att_Apr_ID,@Att_App_ID,@Cmp_ID,@Emp_ID,@For_Date,@Shift_Dur_Sec,@P_Days,@Att_Status,@Approver_Emp_ID,@Remarks,@Modify_By,GetDate(),@Ip_Address)
		End
	Else if @Tran_Type = 'D'
		Begin
			Select @Emp_ID = Emp_ID From T0165_Attendance_Approval WITH (NOLOCK) Where Att_Apr_ID = @Att_Apr_ID
			IF Exists(Select 1 From T0200_Monthly_Salary WITH (NOLOCK) Where Emp_ID = @Emp_ID and @For_Date Between Month_St_Date and Month_End_Date)
				Begin
					RAISERROR('@@Salary is Exists for this period @@',16,2)
					return
				End
			Delete From T0165_Attendance_Approval Where Att_Apr_ID = @Att_Apr_ID
		End
END

