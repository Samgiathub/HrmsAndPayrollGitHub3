-- =============================================
-- Author:		<Mehul>
-- Create date: <26/07/2021>
-- Description:	<Sp for Unit Type Master>
-- =============================================
CREATE PROCEDURE [dbo].[P0050_Unit_Type_Master] 
	 @Cmp_ID numeric(18,0)
	,@Unit_Type_Name varchar(50)
	,@Unit_Type_Id numeric(18,0) 
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
		
				If exists (Select @Unit_Type_Id  from T0040_Unit_Type_Master WITH (NOLOCK) Where Unit_Type_Name = @Unit_Type_Name 
								and Cmp_ID = @Cmp_ID) 
					begin
						set @Unit_Type_Id = 0
						return  
					end
			
					select @Unit_Type_Id = isnull(max(Unit_Type_Id),0) + 1  from T0040_Unit_Type_Master WITH (NOLOCK)
					
					INSERT INTO T0040_Unit_Type_Master
					                      ( Cmp_ID,Unit_Type_Name,System_Date)
					VALUES     (@Cmp_ID,@Unit_Type_Name,getdate())
					
					set @OldValue = 'New Value' + '#'+ 'Unit Type Name :' +ISNULL( @Unit_Type_Name,'') 
					
		end 

		Else If @TransId ='U' 
		begin
			if exists (Select Unit_Type_Id  from T0040_Unit_Type_Master WITH (NOLOCK) Where Unit_Type_Name = @Unit_Type_Name and Cmp_ID = @cmp_Id
			and Unit_Type_Id <> @Unit_Type_Id) 
				begin
					set @Unit_Type_Id = 0
					return
				end			
				select @OldUnit_Name  =ISNULL(Unit_Type_Name,'')  From dbo.T0040_Unit_Type_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Unit_Type_Id = Unit_Type_Id		

					UPDATE    T0040_Unit_Type_Master SET Unit_Type_Name = @Unit_Type_Name
					WHERE     Unit_Type_Id = @Unit_Type_Id
					
					set @OldValue = 'old Value' + '#'+ 'Unit Type Name :' +ISNULL( @OldUnit_Name,'') 
                                  + 'New Value' + '#'+ 'Unit Type Name :' +ISNULL( @Unit_Type_Name,'') 
 
		end	

			Else If @TransId ='D'
		Begin
		
		select @OldUnit_Name  =ISNULL(Unit_Type_Name,'')  From dbo.T0040_Unit_Type_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Unit_Type_Id = @Unit_Type_Id		
		
			DELETE FROM T0040_Unit_Type_Master 	WHERE  Unit_Type_Id = @Unit_Type_Id
			
			set @OldValue = 'old Value' + '#'+ 'Unit Type Name :' +ISNULL( @OldUnit_Name,'')
		end

	RETURN	


End