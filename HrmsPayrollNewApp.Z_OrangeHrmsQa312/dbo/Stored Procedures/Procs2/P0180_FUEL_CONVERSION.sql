-- =============================================
-- Author:		<Mehul>
-- Create date: <10/08/2021>
-- Description:	<SP for Fuel Conversion>
-- =============================================
CREATE PROCEDURE [dbo].[P0180_FUEL_CONVERSION]
 @Fuel_ID numeric(18,0)
	,@Cmp_ID numeric(18,0)
	,@Fuel_Rate varchar(50)
	,@Fuel_type varchar(50) 
	,@For_Date Datetime 
	,@TransId Char = ''	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

declare @OldValue as varchar(MAx)
declare @OldFuel_Rate as varchar(100)
set @OldFuel_Rate =''

    
If @TransId ='I' 
		begin
		
			If exists (Select @Fuel_ID  from T0180_FUEL_CONVERSION WITH (NOLOCK) Where Fuel_Rate = @Fuel_Rate 
								and Cmp_ID = @Cmp_ID) 
					begin
						set @Fuel_ID = 0
						return  
					end
					select @Fuel_ID = isnull(max(Fuel_ID),0) + 1  from T0180_FUEL_CONVERSION WITH (NOLOCK)
		
					INSERT INTO T0180_FUEL_CONVERSION
					                      ( Cmp_ID, Fuel_Rate,Fuel_type,For_Date)
					VALUES     (@Cmp_ID,@Fuel_Rate,@Fuel_type,@For_Date)
					
					--set @OldValue = 'New Value' + '#'+ 'Fuel Rate :' +ISNULL( @Fuel_Rate,'') 
					
		end 

		Else If @TransId ='U' 
		begin
			if exists (Select Fuel_Id  from T0180_FUEL_CONVERSION WITH (NOLOCK) Where Fuel_Rate = @Fuel_Rate and Cmp_ID = @cmp_Id 
								and Fuel_Id <> @Fuel_Id) 
				begin
					set @Fuel_Id = 0
					return
				end			
				--select @OldFuel_Rate  =ISNULL(Fuel_Rate,'')  From dbo.T0180_FUEL_CONVERSION WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Fuel_Id = @Fuel_Id		
					
				UPDATE    T0180_FUEL_CONVERSION SET 
				Fuel_Rate = @Fuel_Rate,
				Fuel_type=@Fuel_type,
				FOR_DATE = @For_Date
				WHERE     Fuel_Id = @Fuel_Id and CMP_ID = @Cmp_ID
					
				--set @OldValue = 'old Value' + '#'+ 'Fuel Rate :' +ISNULL( @OldFuel_Rate,'') + 'New Value' + '#'+ 'Fuel Rate :' +ISNULL( @Fuel_Rate,'') 
 
		end	

			Else If @TransId ='D'
		Begin
		
		--select @OldFuel_Rate  =ISNULL(Fuel_Rate,'')  From dbo.T0180_FUEL_CONVERSION WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Fuel_ID = @Fuel_ID		
		
			DELETE FROM T0180_FUEL_CONVERSION 	WHERE  Fuel_ID = @Fuel_ID and CMP_ID = @Cmp_ID
			
			--set @OldValue = 'old Value' + '#'+ 'Fuel Rate :' +ISNULL( @OldFuel_Rate,'')
		end

	RETURN	

	End
