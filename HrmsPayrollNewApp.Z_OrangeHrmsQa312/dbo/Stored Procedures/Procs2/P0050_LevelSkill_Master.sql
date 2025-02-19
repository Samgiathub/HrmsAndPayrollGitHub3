
CREATE PROCEDURE [dbo].[P0050_LevelSkill_Master]
@Lvlskl_Id numeric(18,0) OUTPUT, 
@Cmp_Id numeric,
@level_Name varchar(500) = '',
@level_Desc varchar(2000) = '',
@Created_By numeric,
@TransId Char = ''

AS
Begin

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If @TransId = 'I'
		Begin 
					IF Exists(Select Lvlskl_Id  from T0050_LevelSkill_Master WITH (NOLOCK) Where Cmp_Id = @Cmp_Id and upper(level_Name) = upper(@level_Name))  
					Begin  
						set @Lvlskl_Id = 0  
					Return   
					End  
				
					select @Lvlskl_Id = isnull(max(Lvlskl_Id),0) + 1  from T0050_LevelSkill_Master WITH (NOLOCK)
					
					INSERT INTO T0050_LevelSkill_Master 
					(Lvlskl_Id,Cmp_id,level_Name,level_Desc,Record_Date,Created_By)
					VALUES(@Lvlskl_Id,@Cmp_Id,@level_Name,@level_Desc,GETDATE(),@Created_By)
					
		end 

	Else if @TransId = 'U'   
		begin
			
					IF Exists(Select Lvlskl_Id  from T0050_LevelSkill_Master WITH (NOLOCK) Where Cmp_Id = @Cmp_Id and upper(level_Name) = upper(@level_Name))  
					Begin  
						set @Lvlskl_Id = 0  
					Return   
					End  
					
					UPDATE    T0050_LevelSkill_Master SET 
					Cmp_id = @Cmp_Id,
					level_Name = @level_Name,
					level_Desc = @level_Desc,
					Created_By=@Created_By
					WHERE     Lvlskl_Id = @Lvlskl_Id

		end	

	Else if @TransId = 'D'  
		Begin
		
					IF not Exists(select ISNULL(Lvlskl_Id,0)  From dbo.T0050_LevelSkill_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Lvlskl_Id = @Lvlskl_Id)  
					Begin  
						set @Lvlskl_Id = 0  
					Return   
					End  

					IF Exists(select 1 from T0500_Certificateskill_Details where Cmp_Id=@Cmp_Id and upper(Skill_Level) = upper(@level_Name))  
					Begin  
						set @Lvlskl_Id = 0  
					Return   
					End  
		
			DELETE FROM T0050_LevelSkill_Master 	WHERE  Lvlskl_Id = @Lvlskl_Id
			
		end

	RETURN	

	End