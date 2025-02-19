-- =============================================
-- Author:		<Mehul>
-- Create date: <29/07/2021>
-- Description:	<Sp for Bill Type Master>
-- =============================================
CREATE PROCEDURE [dbo].[P0050_Bill_Type_Master] 
 @Bill_ID numeric(18,0)
	,@Cmp_ID numeric(18,0)
	,@Bill_Name varchar(50)
	,@Bill_Fieldtype_id varchar(50) 
	,@System_Date Datetime = ''
	,@TransId Char = ''	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

declare @OldValue as varchar(MAx)
declare @OldBill_Name as varchar(100)
set @OldBill_Name =''

    
If @TransId ='I' 
		begin
		
			If exists (Select @Bill_ID  from T0050_Bill_Type_Master WITH (NOLOCK) Where Bill_Name = @Bill_Name 
								and Cmp_ID = @Cmp_ID) 
					begin
						set @Bill_ID = 0
						return  
					end
			
					select @Bill_ID = isnull(max(Bill_ID),0) + 1  from T0050_Bill_Type_Master WITH (NOLOCK)
					
					INSERT INTO T0050_Bill_Type_Master
					                      ( Cmp_ID, Bill_Name,Bill_Fieldtype_Id,System_Date)
					VALUES     (@Cmp_ID,@Bill_Name,@Bill_Fieldtype_id,getdate())
					
					set @OldValue = 'New Value' + '#'+ 'Bill Name :' +ISNULL( @Bill_Name,'') 
					
		end 

		Else If @TransId ='U' 
		begin
			if exists (Select Bill_Id  from T0050_Bill_Type_Master WITH (NOLOCK) Where Bill_Name = @Bill_Name and Cmp_ID = @cmp_Id 
								and Bill_ID <> @Bill_ID) 
				begin
					set @Bill_ID = 0
					return
				end			
				select @OldBill_Name  =ISNULL(Bill_Name,'')  From dbo.T0050_Bill_Type_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Bill_Id = @Bill_Id		

					UPDATE    T0050_Bill_Type_Master SET Bill_Name = @Bill_Name,Bill_Fieldtype_Id=@Bill_Fieldtype_id
					WHERE     Bill_Id = @Bill_Id
					
					set @OldValue = 'old Value' + '#'+ 'Bill Name :' +ISNULL( @OldBill_Name,'') 
                                  + 'New Value' + '#'+ 'Bill Name :' +ISNULL( @Bill_Name,'') 
 
		end	

			Else If @TransId ='D'
		Begin
		
		select @OldBill_Name  =ISNULL(Bill_Name,'')  From dbo.T0050_Bill_Type_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Bill_ID = @Bill_ID		
		
			DELETE FROM T0050_Bill_Type_Master 	WHERE  Bill_ID = @Bill_ID
			
			set @OldValue = 'old Value' + '#'+ 'Bill Name :' +ISNULL( @OldBill_Name,'')
		end

	RETURN	

	End
