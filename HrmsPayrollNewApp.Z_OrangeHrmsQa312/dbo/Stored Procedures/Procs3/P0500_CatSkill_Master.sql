
CREATE PROCEDURE [dbo].[P0500_CatSkill_Master]
@Cat_Id numeric(18,0) OUTPUT, 
@Cmp_Id numeric,
@Cat_Name varchar(2000) ,
@Cat_Code varchar(2000) = '',
@Is_Man Numeric,
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




					IF Exists(Select Cat_Id  from T0500_CatSkill_Master WITH (NOLOCK) Where upper(Cat_Name)=upper(@Cat_Name) 
																			and upper(Cat_Code) = upper(@Cat_Code) and Cmp_Id =@Cmp_Id)  
					Begin  
						set @Cat_Id = 0  
					Return   
					End  
				
					select @Cat_Id = isnull(max(Cat_Id),0) + 1  from T0500_CatSkill_Master WITH (NOLOCK)
					
					INSERT INTO T0500_CatSkill_Master 
					(Cat_ID,Cmp_id,Cat_Name,Cat_Code,Is_Man,Sorting_No,Record_Date,Created_By)
					VALUES(@Cat_Id,@Cmp_Id,@Cat_Name,@Cat_Code,@Is_Man,@Sorting_No,GETDATE(),@Created_By)
					
		end 

	Else if @TransId = 'U'   
		begin
			
					IF  NOT Exists(Select Cat_Id  from T0500_CatSkill_Master WITH (NOLOCK) Where  
																			 Cat_Id=@Cat_Id and Cmp_Id =@Cmp_Id)  
					Begin  
						set @Cat_Id = 0
					Return   
					End  
					
					UPDATE    T0500_CatSkill_Master SET 
					Cmp_id = @Cmp_Id,
					Cat_Name = @Cat_Name,
					Cat_Code = @Cat_Code,
					Is_Man = @Is_Man,
					Sorting_No = @Sorting_No,
					Created_By=@Created_By
					WHERE     Cat_Id = @Cat_Id

		end	

	Else if @TransId = 'D'  
		Begin
		
		IF not Exists(select ISNULL(Cat_Id,0)  From dbo.T0500_CatSkill_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Cat_Id = @Cat_Id	)
		Begin
				set @Cat_Id = 0  
					Return  
		end
	    
		if Exists (select 1 from T0500_SubCatSkill_Master where  Cat_Id = @Cat_Id)
		Begin
				set @Cat_Id = 0  
				Return  
		end
		
				
		
			DELETE FROM T0500_CatSkill_Master 	WHERE  Cat_Id = @Cat_Id
			
		end

	RETURN	

	End