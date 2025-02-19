



---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0020_SKILL_MASTER]
	@Skill_ID AS NUMERIC output,
	@Skill_Name AS VARCHAR(50),
	@CMP_ID AS NUMERIC,
	@Description as varchar(100),	
	@Year as numeric(18,1),
	@tran_type varchar(1)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	If @tran_type  = 'I'
		Begin
				--If Exists(Select Skill_Id From T0020_Skill_Master  Where Cmp_ID = @Cmp_ID and Skill_Name = @Skill_Name)
					--begin
						--set @Skill_Id = 0
						--Return 
					--end
				
				select @Skill_Id= Isnull(max(Skill_Id),0) + 1 	From T0020_Skill_Master WITH (NOLOCK)
				
				INSERT INTO T0020_Skill_Master
				                      (Skill_Id, Cmp_ID, Skill_Name,Description,year_1)
				VALUES     (@Skill_Id, @Cmp_ID,@Skill_Name,@Description,@Year)
		End
	Else if @Tran_Type = 'U'
		begin
				If Exists(Select Skill_Id From T0020_Skill_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Skill_Id <> @Skill_Id and upper(Skill_Name) = upper(@Skill_Name)) -- Modified by Mitesh on 04/08/2011 for different collation db
					begin
						set @Skill_Id = 0
						Return 
					end

				Update T0020_Skill_Master
				set Skill_Name=@Skill_Name
				    ,Description=@Description			
				    ,Year_1=@year	    
				where Skill_Id = @Skill_Id
				
		end
	Else if @Tran_Type = 'D'
		begin
				Delete From T0020_Skill_Master Where Skill_Id= @Skill_Id
		end

	RETURN




