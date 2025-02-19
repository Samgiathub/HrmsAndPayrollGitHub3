


-- =============================================
-- Author:		<Author,,Zishanali Tailor>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0030_Thana_Master] 
	@Thana_Id AS NUMERIC output,
	@Cmp_Id AS NUMERIC,
	@Thana_Name AS VARCHAR(100),
	@tran_type varchar(1)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	If @tran_type  = 'I'
		Begin
				If Exists(Select Thana_Id From T0030_Thana_Master WITH (NOLOCK)  Where Cmp_ID = @Cmp_ID and upper(Thananame) = upper(@Thana_Name)) 
					begin
						set @Thana_Id = 0
					Return 
				end
				
				select @Thana_Id = Isnull(max(Thana_Id),0) + 1 	From T0030_Thana_Master WITH (NOLOCK)
							
				  
				INSERT INTO T0030_Thana_Master
				           (Thana_Id, Cmp_ID, ThanaName)
				VALUES     (@Thana_Id, @Cmp_ID, @Thana_Name)
				
		End
	Else if @Tran_Type = 'U'
		begin
				If Exists(Select Thana_Id From T0030_Thana_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and upper(Thananame) = upper(@Thana_Name)) 
					begin
						set @Thana_Id = 0
						Return 
				end
              
				Update T0030_Thana_Master
				set Thananame = @Thana_Name
				where Thana_Id = @Thana_Id
			 
		end
	Else if @Tran_Type = 'D'
		begin
				Delete From T0030_Thana_Master Where Thana_Id = @Thana_Id
		end
END


