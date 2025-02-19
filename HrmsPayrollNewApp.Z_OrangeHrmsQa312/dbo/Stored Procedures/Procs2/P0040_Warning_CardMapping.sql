

-- =============================================
-- Author:		<Jaina>
-- Create date: <09-03-2018>
-- Description:	<Warning Level Card Mapping>
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0040_Warning_CardMapping]
	@Cmp_Id as Numeric(18,0),
	@Level_Id as Numeric(18,0) output,
	@Level_Name as varchar(50),
	@No_Of_Card numeric(18,0),
	@Card_Color varchar(50),
	@Login_Id numeric(18,0),
	@Tran_Type char(1)	
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	declare @OldValue as  varchar(max) 
	Declare @String as varchar(max)
	
	set @String =''
	set @OldValue = ''	
	
    IF @Tran_Type = 'I'
    BEgin
		if exists(select Level_Id from T0040_Warning_CardMapping WITH (NOLOCK) where Cmp_id = @Cmp_Id and Level_Id = @Level_Id)
		BEGIN
			set @Level_Id = 0
			Return 
		END
		
		Insert INTO T0040_Warning_CardMapping (Cmp_Id,Level_ID,Level_Name, No_Of_Card,Card_Color,Login_Id,System_Date)
		VALUES (@Cmp_Id,@Level_Id,@Level_Name,@No_Of_Card,@Card_Color,@Login_Id,GETDATE())
		
		exec P9999_Audit_get @table = 'T0040_Warning_CardMapping' ,@key_column='Level_ID',@key_Values=@Level_ID ,@String=@String output
		set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
    End
    IF @Tran_Type = 'U'
    BEGIN
		update T0040_Warning_CardMapping 
		SET Level_Name = @Level_Name,
			No_Of_Card = @No_OF_Card,
			Card_Color = @Card_Color
		where Cmp_Id = @Cmp_Id and 
			Level_Id = @Level_Id	
			
			
    end	
    IF @Tran_Type = 'D'
    BEGIN
		IF exists (SELECT 1 FROM T0040_WARNING_MASTER W WITH (NOLOCK) LEFT OUTER JOIN T0040_Warning_CardMapping C WITH (NOLOCK) ON W.Cmp_ID = C.Cmp_Id AND W.Level_Id = C.Level_Id
					WHERE C.Cmp_Id = @Cmp_Id AND C.Level_Id = @Level_Id)
		BEGIN
			set @Level_Id = 0
			Return 
		END
		DELETE FROM T0040_Warning_CardMapping where Cmp_Id=@Cmp_Id and Level_Id = @Level_ID
    end	
    
	
END

