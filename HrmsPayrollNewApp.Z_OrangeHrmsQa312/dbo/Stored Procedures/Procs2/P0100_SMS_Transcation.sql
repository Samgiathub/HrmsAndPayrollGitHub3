
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P0100_SMS_Transcation]
	@Tran_ID Numeric,
	@Cmp_ID Numeric,
	@Emp_ID Numeric,
	@Module_Name Varchar(200),
	@SMS_Text Varchar(1000)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
	
	if Exists(Select 1 From T0100_SMS_Transcation WITH (NOLOCK)	Where Emp_ID = @Emp_ID and Module_Name = @Module_Name and Cmp_ID = @Cmp_ID and CONVERT(DATE,For_Date) = CONVERT(DATE,GETDATE()))
		BEGIN
			Update T0100_SMS_Transcation
				Set SMS_Text = @SMS_Text,
					For_Date = GetDate()
			Where Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID and Module_Name = @Module_Name and Send_Flag = 0 and CONVERT(DATE,For_Date) = CONVERT(DATE,GETDATE())
		End
	ELSE
		BEGIN
			Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0100_SMS_Transcation WITH (NOLOCK)
			Insert into T0100_SMS_Transcation(Tran_ID,Cmp_ID,Emp_ID,For_Date,Module_Name,SMS_Text,Send_Flag,SMS_Send_Date)
			Values(@Tran_ID,@Cmp_ID,@Emp_ID,GETDATE(),@Module_Name,@SMS_Text,0,NULL)
		End
END

