

    
    
    
    
CREATE PROCEDURE [dbo].[P0040_SKILL_MASTER]    
 @Skill_ID AS NUMERIC output,    
 @Skill_Name AS VARCHAR(300),    
 @CMP_ID AS NUMERIC,    
 @Description as varchar(max),     
 @tran_type varchar(1)    
 ,@User_Id numeric(18,0) = 0    
    ,@IP_Address varchar(30)= '' --Add By Paras 19-10-2012    
AS    
    
  SET NOCOUNT ON     
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
  SET ARITHABORT ON    
    
declare @OldValue as  varchar(max)    
declare @OldSkill_Name as varchar(50)    
declare @OldDescription as varchar(100)    
    
set @OldSkill_Name =''    
set @OldDescription = ''    
    
    set @Skill_Name = dbo.fnc_ReverseHTMLTags(@Skill_Name)  --added by Ronak 011022  
	 set @Description = dbo.fnc_ReverseHTMLTags(@Description)  --added by Ronak 011022    
 If @tran_type  = 'I'    
  Begin    
    If Exists(Select Skill_Id From T0040_Skill_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and upper(Skill_Name) = upper(@Skill_Name)) -- Modified by Mitesh 04/08/2011 for different collation db.    
     begin       
      set @Skill_Id = 0    
      Return     
     end    
        
    select @Skill_Id= Isnull(max(Skill_Id),0) + 1  From T0040_Skill_Master WITH (NOLOCK)    
        
               
    if @Skill_Name  <> ''    
      Begin     
        
    INSERT INTO T0040_Skill_Master    
                          (Skill_Id, Cmp_ID, Skill_Name,Description)    
    VALUES     (@Skill_Id, @Cmp_ID,@Skill_Name,@Description)    
        
     End      
     set @OldValue = 'New Value' + '#'+ 'Skill Name :' +ISNULL( @Skill_Name,'') + '#' + 'Description :' + ISNULL( @Description,'') + '#'     
        
        
  End    
 Else if @Tran_Type = 'U'    
  begin    
    If Exists(Select Skill_Id From T0040_Skill_Master WITH (NOLOCK)  Where Cmp_ID = @Cmp_ID and Skill_Id <> @Skill_Id and upper(Skill_Name) = upper(@Skill_Name)) -- Modified by Mitesh 04/08/2011 for different collation db.    
     begin    
      set @Skill_Id = 0    
      Return     
     end    
         
                 select @OldSkill_Name  =ISNULL(Skill_Name,'') ,@OldDescription  =ISNULL(Description,'') From dbo.T0040_Skill_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Skill_Id = @Skill_Id    
              
    Update T0040_Skill_Master    
    set Skill_Name=@Skill_Name    
        ,Description=@Description            
    where Skill_Id = @Skill_Id    
        
    set @OldValue = 'old Value' + '#'+ 'Skill Name :' + @OldSkill_Name  + '#' + 'Description:' + @OldDescription      
               + 'New Value' + '#'+ 'SkillName :' +ISNULL( @Skill_Name,'') + '#' + 'Grd Discription :' + ISNULL( @Description,'')     
        
  end    
 Else if @Tran_Type = 'D'    
  begin    
      
   select @OldSkill_Name  =ISNULL(Skill_Name,'') ,@OldDescription  =ISNULL(Description,'') From dbo.T0040_Skill_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Skill_Id = @Skill_Id    
    Delete From T0040_Skill_Master Where Skill_Id= @Skill_Id    
    set @OldValue = 'old Value' + '#'+ 'Skill Name :' + @OldSkill_Name  + '#' + 'Description:' + @OldDescription      
  end    
           exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Skill Master',@OldValue,@Skill_ID,@User_Id,@IP_Address    
 RETURN    
    
    
    