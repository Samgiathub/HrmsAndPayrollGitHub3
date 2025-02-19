




-- =============================================
-- Author:		<Jaymin A. Soneji>
-- ALTER  date: <13 12 2008>
-- Description:	<To Import All Ledger Names From Tally Ledger XML File>
---12/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0040_Tally_Led_Master_Insert]
@Tally_led_ID as numeric output,
@Cmp_Id As Numeric,
@Tally_Led_Name As Varchar(100),
@Parent_Tally_Led_Name as varchar(100),
@Trans_type as char(1)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
if @Trans_type = 'I'
   begin
   
  select @Tally_led_ID = isnull(max(Tally_Led_ID),0) + 1 from T0040_Tally_Led_Master WITH (NOLOCK)
   
	If Not Exists(Select Tally_Led_Name From T0040_Tally_Led_Master WITH (NOLOCK) Where Cmp_Id = @Cmp_Id And 
						Tally_Led_Name = @Tally_Led_Name)
						
					
						
		Begin
			Insert Into T0040_Tally_Led_Master (Tally_Led_ID,Cmp_Id, Tally_Led_Name,Parent_Tally_Led_Name)
			Values(@Tally_led_ID,@Cmp_Id, @Tally_Led_Name,@Parent_Tally_Led_Name)
		End
	end
else if @Trans_type = 'D'
	begin
	
		if exists (select 1 from T0080_EMP_MASTER WITH (NOLOCK) where Tally_Led_ID = @Tally_led_ID)
			BEGIN
				RAISERROR('@@ Reference Esits @@',16,2)
				RETURN
			END
		ELSE
			BEGIN
				delete from T0040_Tally_Led_Master where  Tally_Led_ID=@Tally_led_ID
			END
		
	end
END




