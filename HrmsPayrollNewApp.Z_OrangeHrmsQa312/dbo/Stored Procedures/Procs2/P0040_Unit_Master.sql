-- =============================================
-- Author:		<Mehul>
-- Create date: <26/07/2021>
-- Description:	<Sp for Unit Master>
-- =============================================
CREATE PROCEDURE [dbo].[P0040_Unit_Master]
	 @Unit_ID numeric(18,0)
	,@Cmp_ID numeric(18,0)
	,@Unit_Name varchar(50)
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

 --   Select Unit_ID,Unit_Name,Unit_Type_Id,System_date 
	--From T0040_Units_Master where Cmp_Id = @Cmp_Id
	--declare @Result as  varchar(500)
	--if @TransId = 'I'
	--Begin 
	--	Insert into T0040_Units_Master
	--	(Cmp_Id,Unit_Type_Id,Unit_Name,System_Date)
	--	values (@Cmp_Id,@Unit_Type_Id,@Unit_Name,getdate())

	--	set @Result = 'Inserted successfully'
	--end
	--else if @TransId = 'U'
	--Begin 
	--	Update T0040_Units_Master set Unit_Name = @Unit_Name 
	--	where Unit_Id = @Unit_Id
	--ENd
	--else if @TransId = 'D'
	--Begin 
	--	Delete T0040_Units_Master 
	--	where Unit_Id = @Unit_Id
	--ENd
	--Select @Result
	--return

	If @TransId ='I' 
		begin
		
				If exists (Select @Unit_ID  from T0040_Units_Master WITH (NOLOCK) Where Unit_Name = @Unit_Name 
								and Cmp_ID = @Cmp_ID) 
					begin
						set @Unit_ID = 0
						return  
					end
			
					select @Unit_ID = isnull(max(Unit_ID),0) + 1  from T0040_Units_Master WITH (NOLOCK)
					
					INSERT INTO T0040_Units_Master
					                      ( Cmp_ID, Unit_Name,Unit_Type_Id,System_Date)
					VALUES     (@Cmp_ID,@Unit_Name,@Unit_Type_Id,getdate())
					
					set @OldValue = 'New Value' + '#'+ 'Unit Name :' +ISNULL( @Unit_Name,'') 
					
		end 

		Else If @TransId ='U' 
		begin
			if exists (Select Unit_Id  from T0040_Units_Master WITH (NOLOCK) Where Unit_Name = @Unit_Name and Cmp_ID = @cmp_Id 
								and Unit_ID <> @Unit_ID) 
				begin
					set @Unit_ID = 0
					return
				end			
				select @OldUnit_Name  =ISNULL(Unit_Name,'')  From dbo.T0040_Units_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Unit_ID = @Unit_ID		

					UPDATE    T0040_Units_Master SET Unit_Name = @Unit_Name,Unit_Type_Id=@Unit_Type_Id
					WHERE     Unit_ID = @Unit_ID
					
					set @OldValue = 'old Value' + '#'+ 'Unit Name :' +ISNULL( @OldUnit_Name,'') 
                                  + 'New Value' + '#'+ 'Unit Name :' +ISNULL( @Unit_Name,'') 
 
		end	

			Else If @TransId ='D'
		Begin
		
		select @OldUnit_Name  =ISNULL(Unit_Name,'')  From dbo.T0040_Units_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Unit_ID = @Unit_ID		
		
			DELETE FROM T0040_Units_Master 	WHERE  Unit_ID = @Unit_ID
			
			set @OldValue = 'old Value' + '#'+ 'Unit Name :' +ISNULL( @OldUnit_Name,'')
		end

	RETURN	

	End