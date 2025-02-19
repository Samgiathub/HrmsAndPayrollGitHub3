-- =============================================
-- Author:		<Mehul>
-- Create date: <26/07/2021>
-- Description:	<Sp for Unit Type Master>
-- =============================================
Create PROCEDURE [dbo].[P0050_Claim_Group_Master] 
	 @Cmp_ID numeric(18,0)
	,@Claim_Group_Name varchar(50)
	,@Claim_Group_Id numeric(18,0) 
	,@System_Date Datetime = ''
	,@TransId Char = ''	

AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

declare @OldValue as varchar(MAx)
declare @OldUnit_Name as varchar(100)
set @OldUnit_Name =''


If @TransId ='I' 
		begin
		
				If exists (Select @Claim_Group_Id  from T0040_Claim_Group_Master WITH (NOLOCK) Where Claim_Group_Name = @Claim_Group_Name 
								and Cmp_ID = @Cmp_ID) 
					begin
						set @Claim_Group_Id = 0
						return  
					end
			
					select @Claim_Group_Id = isnull(max(Claim_Group_Id),0) + 1  from T0040_Claim_Group_Master WITH (NOLOCK)
					
					INSERT INTO T0040_Claim_Group_Master
					                      ( Cmp_ID,Claim_Group_Name,System_Date)
					VALUES     (@Cmp_ID,@Claim_Group_Name,getdate())
					
					set @OldValue = 'New Value' + '#'+ 'Unit Type Name :' +ISNULL( @Claim_Group_Name,'') 
					
		end 

		Else If @TransId ='U' 
		begin
			if exists (Select Claim_Group_Id  from T0040_Claim_Group_Master WITH (NOLOCK) Where Claim_Group_Name = @Claim_Group_Name and Cmp_ID = @cmp_Id
			and Claim_Group_Id <> @Claim_Group_Id) 
				begin
					set @Claim_Group_Id = 0
					return
				end			
				select @OldUnit_Name  =ISNULL(Claim_Group_Name,'')  From dbo.T0040_Claim_Group_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Claim_Group_Id = Claim_Group_Id		

					UPDATE    T0040_Claim_Group_Master SET Claim_Group_Name = @Claim_Group_Name
					WHERE     Claim_Group_Id = @Claim_Group_Id
					
					set @OldValue = 'old Value' + '#'+ 'Unit Type Name :' +ISNULL( @OldUnit_Name,'') 
                                  + 'New Value' + '#'+ 'Unit Type Name :' +ISNULL( @Claim_Group_Name,'') 
 
		end	

			Else If @TransId ='D'
		Begin
		
		select @OldUnit_Name  =ISNULL(Claim_Group_Name,'')  From dbo.T0040_Claim_Group_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Claim_Group_Id = @Claim_Group_Id		
		
			DELETE FROM T0040_Claim_Group_Master 	WHERE  Claim_Group_Id = @Claim_Group_Id
			
			set @OldValue = 'old Value' + '#'+ 'Unit Type Name :' +ISNULL( @OldUnit_Name,'')
		end

	RETURN	


End