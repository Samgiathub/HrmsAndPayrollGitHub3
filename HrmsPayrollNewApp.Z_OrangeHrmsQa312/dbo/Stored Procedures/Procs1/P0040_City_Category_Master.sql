

CREATE PROCEDURE [dbo].[P0040_City_Category_Master]
	@City_Cat_ID AS NUMERIC output,
	@CMP_ID AS NUMERIC(18,0),
	@City_ID as numeric(18,0),
	@City_Cat_NAME AS VARCHAR(100),
	@Remarks as varchar(250),
	@tran_type varchar(1)
	
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

	
	If @tran_type  = 'I'
		Begin
				If Exists(Select City_Cat_ID From T0040_City_Category_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and upper(City_Cat_Name) = upper(@City_Cat_NAME) AND City_ID = @City_ID) -- Modified by Mitesh 04/08/2011 for different collation db.
					begin
						set @City_Cat_ID = 0
						Return 
					end
				
				select @City_Cat_ID = Isnull(max(City_Cat_id),0) + 1 	From T0040_City_Category_Master WITH (NOLOCK)
							
				  
				INSERT INTO T0040_City_Category_Master
				                      (City_Cat_ID,City_ID,City_Cat_Name,Cmp_ID,Remarks)
				VALUES     (@City_Cat_ID,@City_ID,@City_Cat_NAME,@CMP_ID,@Remarks)
				
				
				
		End
	Else if @Tran_Type = 'U'
		begin
				If Exists(Select City_Cat_ID From T0040_City_Category_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and upper(City_Cat_Name) = upper(@City_Cat_NAME) AND City_id = @City_ID  and City_Cat_ID <> @City_Cat_ID) -- Modified by Mitesh 04/08/2011 for different collation db.
					begin
						set @City_Cat_ID = 0
						Return 
					end
					
              
				Update T0040_City_Category_Master
				set City_Cat_Name = @City_Cat_NAME,
					City_ID=@City_ID,
				    Cmp_ID = @Cmp_ID,
				    Remarks=@remarks				    				    
				where City_Cat_ID = @City_Cat_ID and Cmp_ID=@Cmp_ID
				
		end
	Else if @Tran_Type = 'D'
		begin
		
				if Exists(select city_cat_id from T0050_EXPENSE_TYPE_MAX_LIMIT WITH (NOLOCK) where Cmp_ID=@CMP_ID and City_Cat_ID=@City_Cat_ID)
					begin
						RAISERROR('@@ Reference Esits @@',16,2)
						RETURN	
					end
				if Exists(select city_cat_id from T0030_CITY_MASTER WITH (NOLOCK) where Cmp_ID=@CMP_ID and City_Cat_ID=@City_Cat_ID)
					Begin
						RAISERROR('@@ Reference Esits @@',16,2)
						RETURN	
					End
				Delete From T0040_City_Category_Master Where City_Cat_ID=@City_Cat_ID and Cmp_ID=@CMP_ID	
				--Delete From T0040_City_Category_Master Where City_Cat_ID=@City_Cat_ID and Cmp_ID=@CMP_ID				
				
		end	

	RETURN
