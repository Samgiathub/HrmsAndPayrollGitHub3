CREATE TABLE [dbo].[T9999_DEVICE_INOUT_DETAIL] (
    [IO_Tran_ID]  NUMERIC (18) NOT NULL,
    [Cmp_ID]      NUMERIC (18) NULL,
    [Enroll_No]   NUMERIC (18) NOT NULL,
    [IO_DateTime] DATETIME     NOT NULL,
    [IP_Address]  VARCHAR (50) NULL,
    [In_Out_flag] CHAR (10)    NULL,
    [Is_Verify]   INT          CONSTRAINT [DF_T9999_DEVICE_INOUT_DETAIL_Is_Verify] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_T9999_DEVICE_INOUT_DETAIL] PRIMARY KEY CLUSTERED ([IO_Tran_ID] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [IX_T9999_DEVICE_INOUT_DETAIL]
    ON [dbo].[T9999_DEVICE_INOUT_DETAIL]([Enroll_No] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [IX_T9999_DEVICE_INOUT_DETAIL_1]
    ON [dbo].[T9999_DEVICE_INOUT_DETAIL]([IO_DateTime] ASC) WITH (FILLFACTOR = 80);


GO
-- =============================================
-- Author:		<Niraj Parmar>
-- Create date: <20052022>
-- Description:	<Triger for SMS SP calling while in and out of employees>
-- =============================================
CREATE TRIGGER [dbo].[Tri_T9999_DEVICE_INOUT_DETAIL]
   ON  [dbo].[T9999_DEVICE_INOUT_DETAIL]
   AFTER INSERT,UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	-- Start Added by Niraj (20052022)
	Declare @IO_TRAN_ID Numeric(18,0)
	Declare @Enroll_No Varchar(50)
	Declare @Emp_Id Numeric(18,0)
	Declare @Cmp_Id Numeric(18,0)
	Declare @MobileNo varchar(12)  
	Declare @In_Out_Time datetime = null


	-- End Added by Niraj (20052022)

	select @IO_TRAN_ID = IO_TRAN_ID, @Enroll_No = Enroll_No, @Cmp_Id = Cmp_Id, @In_Out_Time = IO_DateTime from inserted ins	
	Select @MobileNo = Mobile_No, @Emp_Id = Emp_ID From T0080_EMP_MASTER Where Enroll_No = @Enroll_No and Cmp_ID = @Cmp_Id
    -- Insert statements for trigger here

	IF EXISTS(Select 1 from T9999_DEVICE_INOUT_DETAIL 
	where IO_Tran_ID = @IO_TRAN_ID and DATEPART(HOUR, IO_DateTime) Between 9 and 10)
	Begin
		exec Parwani_SMSAPI_Integration @Emp_Id, @Cmp_Id, @MobileNo, @In_Out_Time, 0
	End

	IF EXISTS(Select 1 from T9999_DEVICE_INOUT_DETAIL 
	where IO_Tran_ID = @IO_TRAN_ID and DATEPART(HOUR, IO_DateTime) Between 17 and 21)
	Begin
		exec Parwani_SMSAPI_Integration @Emp_Id, @Cmp_Id, @MobileNo, @In_Out_Time, 1
	End

END
