

CREATE PROCEDURE [dbo].[P0040_Country_Category_Master]
	@Cmp_ID numeric(18,0),
	@Country_Cat_ID numeric(18,0) output,
	@Country_Cat_name varchar(200),
	@Remarks varchar(500),
	@tran_type varchar(1)
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	--declare @max_id as numeric(18,0)
	
	If @tran_type  = 'I'
		Begin
				if Exists(select 1 from t0040_Loc_Cat_Master WITH (NOLOCK) where upper(Category_name)=upper(@Country_Cat_name))
					Begin
						set @Country_Cat_ID=0
						return -1
			
					End
				select @Country_Cat_ID=ISNULL(max(Loc_cat_id),0)+1 from t0040_Loc_Cat_Master WITH (NOLOCK)
				INSERT INTO t0040_Loc_Cat_Master
				                      (Loc_Cat_ID,Category_name,Remarks)
				VALUES     (@Country_Cat_ID,@Country_Cat_name,@Remarks)	
					
		End
	Else if @Tran_Type = 'U'
		begin
				If Exists(Select Loc_cat_id From t0040_Loc_Cat_Master WITH (NOLOCK) Where upper(Category_name) = upper(@Country_Cat_name) AND Loc_Cat_ID <> @Country_Cat_ID) 
					begin
						set @Country_Cat_ID = 0
						Return 
					end
					
              
				Update t0040_Loc_Cat_Master
				set Category_name = @Country_Cat_name,				    
				    Remarks=@remarks				    				    
				where Loc_Cat_ID = @Country_Cat_ID --and Cmp_ID=@Cmp_ID
				
		end
	Else if @Tran_Type = 'D'
		begin
		
				--if Exists(select city_cat_id from T0050_EXPENSE_TYPE_MAX_LIMIT where Cmp_ID=@CMP_ID and City_Cat_ID=@City_Cat_ID)
				--	begin
				--		RAISERROR('@@ Reference Esits @@',16,2)
				--		RETURN	
				--	end
				if Exists(select Loc_cat_id from T0001_LOCATION_MASTER WITH (NOLOCK) where Loc_Cat_ID=@Country_Cat_ID)
					Begin
						RAISERROR('@@ Reference Esits @@',16,2)
						RETURN	
					End
				Delete From t0040_Loc_Cat_Master Where Loc_cat_id=@Country_Cat_ID --and Cmp_ID=@CMP_ID	
				--Delete From T0040_City_Category_Master Where City_Cat_ID=@City_Cat_ID and Cmp_ID=@CMP_ID				
				
		end	
	return
END


