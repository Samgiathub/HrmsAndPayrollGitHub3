



---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[IMPORT_EXPORT_DETAIL]
@IO_Tran_ID NUMERIC(18,0),
@Cmp_ID     NUMERIC(18,0),
@Enroll_No  NUMERIC(18,0),
@IO_Datetime DATETIME,
@Ip_Address VARCHAR(20)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		If Not Exists(select IO_Tran_ID from T9999_DEVICE_INOUT_DETAIL WITH (NOLOCK) where Enroll_no = @Enroll_No And IO_Datetime=@IO_Datetime )
		Begin
				SELECT @IO_Tran_ID = Isnull(max(IO_Tran_ID),0) + 1  FROM T9999_DEVICE_INOUT_DETAIL WITH (NOLOCK)
		
				INSERT INTO T9999_DEVICE_INOUT_DETAIL(IO_Tran_ID,Cmp_ID,Enroll_No,IO_Datetime,Ip_Address) 
				Values(@IO_Tran_ID,@Cmp_ID,@Enroll_No,@IO_Datetime,@Ip_Address)
		End		

RETURN




