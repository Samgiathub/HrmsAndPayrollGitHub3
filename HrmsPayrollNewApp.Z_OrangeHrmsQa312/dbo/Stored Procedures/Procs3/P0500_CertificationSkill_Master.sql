
CREATE PROCEDURE [dbo].[P0500_CertificationSkill_Master]
@Certi_Id numeric(18,0) OUTPUT,
@Cmp_Id numeric,
@Certi_Name varchar(2000) = '',
@Certi_Code varchar(2000) = '',
@Cat_Id numeric(18,0), 
@SubCat_Id Numeric,
@Sorting_No varchar(2000) = '',
@Created_By numeric,
@TransId Char = ''

AS
Begin

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If @TransId = 'I'
		Begin 
					IF Exists(Select Certi_Id  from T0500_Certificateskill_Master WITH (NOLOCK) Where Certi_Id = @Certi_Id)  
					Begin  
						set @Certi_Id = 0  
					Return   
					End  

					if exists (Select Certi_Id   from T0500_Certificateskill_Master WITH (NOLOCK) Where Certificate_Name = @Certi_Name and Cmp_ID=@Cmp_ID )   
			        begin  
			         set @Certi_Id = 0  
			         Return  
			        end  
				
					select @Certi_Id = isnull(max(Certi_Id),0) + 1  from T0500_Certificateskill_Master WITH (NOLOCK)
					
					INSERT INTO T0500_Certificateskill_Master 
					(Certi_Id,Cmp_id,Certificate_Name,Certificate_Code,Cat_ID,SubCat_Id,Created_By,Sorting_No,Created_Date)
					VALUES(@Certi_Id,@Cmp_Id,@Certi_Name,@Certi_Code,@Cat_ID,@SubCat_Id,@Created_By,@Sorting_No,GETDATE())
					
		end 

	Else if @TransId = 'U'   
		begin
			
					IF not Exists(Select Certi_Id  from T0500_Certificateskill_Master WITH (NOLOCK) Where Certi_Id = @Certi_Id)  
					Begin  
						set @Certi_Id = 0  
					Return   
					End  
					if exists (Select Certi_Id  from T0500_Certificateskill_Master WITH (NOLOCK) Where Certi_Id <> @Certi_Id and Certificate_Name = @Certi_Name and Cmp_ID=@Cmp_ID )   
					 begin  
					  set @Certi_Id = 0  
					  Return  
					 end 
										
										UPDATE    T0500_Certificateskill_Master SET 
										Cmp_id = @Cmp_Id,
										Certificate_Name = @Certi_Name,
										Certificate_Code = @Certi_Code,
										Cat_Id=@Cat_Id,
										SubCat_Id=@SubCat_Id,
									    Created_By=@Created_By,
										Sorting_No = @Sorting_No
										WHERE    Certi_Id = @Certi_Id

		end	

	Else if @TransId = 'D'  
		Begin
		

					IF Not Exists(select Certi_Id  From dbo.T0500_Certificateskill_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Certi_Id = @Certi_Id)  
					Begin  
						set @Certi_Id = 0  
						Return   
					End  
					
					if exists (select Certi_Id from T0500_Certificateskill_Details where Certi_Id = @Certi_Id)   
					begin  
					  set @Certi_Id = 0  
					  Return  
					end 

			DELETE FROM T0500_Certificateskill_Master 	WHERE  Certi_Id = @Certi_Id	
			
		end

	RETURN	

	End