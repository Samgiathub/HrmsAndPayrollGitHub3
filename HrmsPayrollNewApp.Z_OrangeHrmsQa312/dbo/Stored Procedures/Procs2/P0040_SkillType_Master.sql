  
  
  
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
  
CREATE PROCEDURE [dbo].[P0040_SkillType_Master]  
 @SkillType_ID AS NUMERIC output,  
 @CMP_ID AS NUMERIC,  
 @SkillType_Name AS VARCHAR(50),  
 @SkillType_Description as varchar(Max),   
 @tran_type varchar(1)  
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
    set @SkillType_Name = dbo.fnc_ReverseHTMLTags(@SkillType_Name)  --added by Ronak 081021
	 set @SkillType_Description = dbo.fnc_ReverseHTMLTags(@SkillType_Description)  --added by Ronak 081021
 If @tran_type  = 'I'  
  Begin  
    If Exists(Select SkillType_ID From T0040_SkillType_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID  and upper(Skill_Name) = upper(@SkillType_Name))   
     begin  
      set @SkillType_ID = 0  
      Return   
     end  
      
    select @SkillType_ID = Isnull(max(SkillType_ID),0) + 1  From T0040_SkillType_Master WITH (NOLOCK)  
      
    INSERT INTO T0040_SkillType_Master(SkillType_ID,cmp_ID,Skill_Name,Description)  
                            
    VALUES     (@SkillType_ID,@CMP_ID,@SkillType_Name,@SkillType_Description)  
  End  
 Else if @Tran_Type = 'U'  
  begin  
     select @CMP_ID,@SkillType_ID,@SkillType_Name  
    If Exists(Select SkillType_ID From T0040_SkillType_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and SkillType_ID <> @SkillType_ID and upper(Skill_Name) = upper(@SkillType_Name))   
     begin  
      set @SkillType_ID = 0  
      Return   
     end  
  
    Update T0040_SkillType_Master  
    set Skill_Name=@SkillType_Name  
        ,Description=@SkillType_Description          
    where SkillType_ID = @SkillType_ID  
      
  end  
 Else if @Tran_Type = 'D'  
  begin  
    if exists(select skillType_ID from T0050_Minimum_Wages_Master WITH (NOLOCK) where cmp_Id = @CMP_ID and SkillType_ID = @SkillType_ID)  
    begin  
     set @SkillType_ID = 0  
     return  
    end   
    Delete From T0040_SkillType_Master Where SkillType_Id= @SkillType_ID  
  end  
  
 RETURN  
  
  
  
  