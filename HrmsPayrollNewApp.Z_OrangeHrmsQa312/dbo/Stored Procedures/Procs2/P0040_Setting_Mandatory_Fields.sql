

-- =============================================
-- Author:		Nilesh Patel
-- Create date: 29-03-2019
-- Description:	Mandatory Fields 
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0040_Setting_Mandatory_Fields]
	@Tran_ID Numeric,
	@Cmp_ID Numeric,
	@Module_Name Varchar(100),
	@Fields_Name Varchar(100),
	@Is_Mandatory bit,
	@Control_Display_Name Varchar(200),
	@DB_Control_ID Varchar(100),
	@Modify_By Numeric = 0,
	@IP_Address Varchar(20) = ''
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	IF Not Exists(Select 1 From T0040_Setting_Mandatory_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID AND Module_Name = @Module_Name AND Fields_Name = @Fields_Name)
		Begin
			Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Mandatory_Fields WITH (NOLOCK)
			INSERT INTO T0040_Setting_Mandatory_Fields(Tran_ID,Cmp_ID,Module_Name,Fields_Name,Is_Mandatory,Control_Display_Name,DB_Control_ID)
			VALUES(@Tran_ID,@Cmp_ID,@Module_Name,@Fields_Name,@Is_Mandatory,@Control_Display_Name,@DB_Control_ID)
		End
	Else
		Begin
			Update T0040_Setting_Mandatory_Fields	
				SET Is_Mandatory = @Is_Mandatory,
					Modify_Date = GetDate(),
					Modify_By = @Modify_By,
					IP_Address = @IP_Address
			 WHERE Cmp_ID = @Cmp_ID AND Module_Name = @Module_Name AND Fields_Name = @Fields_Name and Tran_ID = @Tran_ID
		End
END


