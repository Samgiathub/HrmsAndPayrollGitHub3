


---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P9999_Mac_Master] 
	 @Tran_id as numeric(18) output
	,@Cmp_id as numeric(18) 
	,@Is_Enable as numeric(18) 
	,@Deny_Mac as numeric(18) 
	,@Tran_Type as Varchar(1)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	declare @Last_Modified as datetime
	set @Last_Modified = getdate()
	
	if @Tran_Type = 'I'
		begin
			
			--SELECT @TRAN_ID = ISNULL(MAX(TRAN_ID),0) + 1 FROM T9999_MAC_MASTER 

			INSERT INTO T9999_MAC_MASTER
							  (Cmp_id, Is_Enable, Deny_Mac, Last_Modified)
			VALUES     (@Cmp_id,@Is_Enable,@Deny_Mac,@Last_Modified)
			
			set @Tran_id = @@identity
			
		end
	else if @Tran_type = 'U'
		begin
		
				UPDATE  T9999_MAC_MASTER
				SET     Is_Enable = @Is_Enable, 
						Deny_Mac = @Deny_Mac, 
						Last_Modified = @Last_Modified							
				Where	Tran_id = @Tran_id and Cmp_id = @Cmp_id
				
		end
END


