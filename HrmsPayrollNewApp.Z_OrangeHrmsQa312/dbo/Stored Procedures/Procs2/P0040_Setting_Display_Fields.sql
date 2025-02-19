-- =============================================
-- Author:		MUKTI CHAUHAN
-- Create date: 10-07-2020
-- Description:	Display Fields 
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0040_Setting_Display_Fields]
	@Tran_ID Numeric,
	@Cmp_ID Numeric,
	@Module_Name Varchar(100),
	@Field_Name Varchar(150),
	@Control_Type Varchar(50),
	@Control_Display_Name Varchar(250),	
	@Is_Display bit,
	@Sorting_No int,	
	@Modify_By INT = 0,
	@IP_Address Varchar(50) = ''
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	IF Not Exists(Select 1 From T0040_Setting_Display_Fields WITH (NOLOCK) Where Cmp_ID = @Cmp_ID AND Module_Name = @Module_Name AND Field_Name = @Field_Name)
		Begin
			Select @Tran_ID = Isnull(Max(Tran_ID),0) + 1 From T0040_Setting_Display_Fields WITH (NOLOCK)
			INSERT INTO T0040_Setting_Display_Fields(Tran_ID,Cmp_ID,Module_Name,Field_Name,Control_Type,Control_Display_Name,Is_Display,Sorting_No)
			VALUES(@Tran_ID,@Cmp_ID,@Module_Name,@Field_Name,@Control_Type,@Control_Display_Name,@Is_Display,@Sorting_No)
		End
	Else
		Begin
			Update T0040_Setting_Display_Fields	
				SET Is_Display = @Is_Display,
					Sorting_No=@Sorting_No,
					Modify_Date = GetDate(),
					Modify_By = @Modify_By,
					IP_Address = @IP_Address
			 WHERE Cmp_ID = @Cmp_ID AND Module_Name = @Module_Name AND Field_Name = @Field_Name and Tran_ID = @Tran_ID
		End
END

