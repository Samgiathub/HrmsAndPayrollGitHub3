
CREATE PROCEDURE [dbo].[P0500_SubCatSkill_Master]
@SubCat_Id numeric(18,0) OUTPUT, 
@Cmp_Id numeric,
@SubCat_Name varchar(2000) = '',
@SubCat_Code varchar(2000) = '',
@Cat_Id numeric,
@Created_By numeric,
@TransId Char = ''

AS
Begin

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If @TransId = 'I'
		Begin 
					IF Exists(Select SubCat_Id  from T0500_SubCatSkill_Master WITH (NOLOCK) Where upper(SubCat_Name) = upper(@SubCat_Name) AND Cat_Id = @Cat_Id and Cmp_ID = @Cmp_ID )  
					Begin  
						set @SubCat_Id = 0  
					Return   
					End  
				
					select @SubCat_Id = isnull(max(SubCat_Id),0) + 1  from T0500_SubCatSkill_Master WITH (NOLOCK)
					
					INSERT INTO T0500_SubCatSkill_Master 
					(SubCat_ID,Cmp_id,SubCat_Name,SubCat_Code,Cat_Id,Record_Date,Created_By)
					VALUES(@SubCat_Id,@Cmp_Id,@SubCat_Name,@SubCat_Code,@Cat_Id,GETDATE(),@Created_By)
					
		end 

	Else if @TransId = 'U'   
		begin
			
					IF NOT Exists(Select SubCat_Id  from T0500_SubCatSkill_Master WITH (NOLOCK) Where Cat_Id = @Cat_Id and Cmp_ID = @Cmp_ID )  
					Begin  
						set @SubCat_Id = 0  
					Return   
					End  

					
					
					UPDATE    T0500_SubCatSkill_Master SET 
					Cmp_id = @Cmp_Id,
					SubCat_Name = @SubCat_Name,
					SubCat_Code = @SubCat_Code,
					Cat_Id = @Cat_Id,
					Created_By=@Created_By
					WHERE     SubCat_Id = @SubCat_Id

		end	

	Else if @TransId = 'D'  
		Begin
		
					IF not Exists(Select SubCat_Id  from T0500_SubCatSkill_Master WITH (NOLOCK) Where SubCat_Id = @SubCat_Id and Cmp_ID = @Cmp_ID)  
					Begin  
						set @SubCat_Id = 0  
						Return   
					End  
				

					IF Exists(select SubCat_Id from T0500_Certificateskill_Master where  SubCat_Id = @SubCat_Id)  
					Begin  
						set @SubCat_Id = 0  
						Return   
					End

					DELETE FROM T0500_SubCatSkill_Master 	WHERE  SubCat_Id = @SubCat_Id
			
		end

	RETURN	

	End