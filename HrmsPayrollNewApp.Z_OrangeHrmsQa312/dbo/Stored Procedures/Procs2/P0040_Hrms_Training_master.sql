  
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE  PROCEDURE [dbo].[P0040_Hrms_Training_master]   
  @Training_id   Numeric(18,0) output  
 ,@Training_name   varchar(200)  
 ,@Training_description varchar(250)    
 ,@Cmp_Id             Numeric(18,0)  
 ,@Trans_Type             char(1)  
 ,@Training_Category_Id  Numeric(18,0)  
 ,@Training_MCP   Numeric(18,2) =0--added on 05082015 sneha  
 ,@User_Id numeric(18,0) = 0 -- added By Mukti 14082015  
    ,@IP_Address varchar(30)= '' -- added By Mukti 14082015  
    ,@Training_Cordinator varchar(250) = '' --Mukti(06072017)  
    ,@Training_Director varchar(250) = '' --Mukti(06072017)  
    ,@Training_Type  Numeric(18,0)=0--Mukti(17072018)  
AS  
  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
--Added By Mukti 14082015(start)  
 declare @OldValue as varchar(max)  
 declare @OldTraining_name as varchar(200)  
 declare @OldTraining_description as varchar(250)    
 declare @OldTraining_Category_Id as  varchar(50)  
 declare @OldTraining_MCP as varchar(5)  
 declare @OldCmp_id as varchar(5)  
 declare @OldTraining_Cordinator as varchar(250)  
 declare @oldTraining_Director as varchar(250)  
--Added By Mukti 14082015(end)   
 if @Training_Type=0  
  set @Training_Type=NULL  
    set @Training_name = dbo.fnc_ReverseHTMLTags(@Training_name)  --added by Ronak 221021
	 set @Training_description = dbo.fnc_ReverseHTMLTags(@Training_description)  --added by Ronak 221021
	  set @Training_Cordinator = dbo.fnc_ReverseHTMLTags(@Training_Cordinator)  --added by Ronak 221021
	  set @Training_Director = dbo.fnc_ReverseHTMLTags(@Training_Director)  --added by Ronak 221021
 If @Trans_Type  = 'I'   
  Begin  
      
    If Exists(select Training_id From T0040_Hrms_Training_master WITH (NOLOCK)  Where (Training_name = @Training_name OR Training_name='' or Training_name='Other') and Cmp_Id = @Cmp_Id)  
      Begin  
       set @Training_id = 0  
       return   
      End  
        
    select @Training_id = Isnull(max(Training_id),0) + 1  From T0040_Hrms_Training_master WITH (NOLOCK)  
     
     if @Training_name <>''  
       Begin   
     
     INSERT INTO T0040_Hrms_Training_master  
       (Training_id,Training_name,Training_description,Cmp_Id,Training_Category_Id,Training_MCP,Training_Cordinator,Training_Director,Training_Type)      
        VALUES(@Training_id,@Training_name,@Training_description,@Cmp_Id,@Training_Category_Id,@Training_MCP,@Training_Cordinator,@Training_Director,@Training_Type)     --added mcp on 05082015 sneha     
      
     --Added By Mukti 14082015(start)  
        set @OldValue = 'New Value' + '#'+ 'Training name :' + @Training_name + '#' +   
      'Training Description :' + @Training_description + '#' +   
      'Training Category Id :' + cast(ISNULL(@Training_Category_Id,0)as varchar(5)) + '#' +   
      'Training MCP :' + Cast(ISNULL(@Training_MCP,0)as varchar(5))  + '#' +   
      'Company Id  :' + Cast(ISNULL(@Cmp_Id,0)as varchar(5)) + '#' +   
      'Training Coordinator :' + @Training_Cordinator + '#' +   
      'Training Director :' + @Training_Director  
     --Added By Mukti 14082015(end)               
    End    
  End  
    
 Else if @Trans_Type = 'U'  
   begin  
   If Exists(select Training_id From T0040_Hrms_Training_master WITH (NOLOCK) Where (Training_name = @Training_name OR Training_name='' or Training_name='Other')  and Cmp_Id = @Cmp_Id  
           and Training_id <> @Training_id )  
    begin  
     set @Training_id = 0  
     return   
    end  
      
     --Added By Mukti 14082015(start)  
     select @OldTraining_name=Training_name,@OldTraining_description = Training_description,  
       @OldTraining_Category_Id=Training_Category_Id,@OldTraining_MCP =Training_MCP,  
       @OldTraining_Cordinator=Training_Cordinator,@oldTraining_Director=Training_Director  
     from T0040_Hrms_Training_master WITH (NOLOCK) where Training_id = @Training_id  
     --Added By Mukti 14082015(end)   
       
    UPDATE    T0040_Hrms_Training_master  
    SET            
       Training_name=@Training_name    
       ,Training_description = @Training_description  
       ,Training_Category_Id=@Training_Category_Id  
       ,Training_MCP =@Training_MCP  --added on 05082015 sneha  
       ,Training_Cordinator=@Training_Cordinator  
       ,Training_Director=@Training_Director  
       ,Training_Type=@Training_Type  
    where Training_id = @Training_id  
      
     --Added By Mukti 14082015(start)  
        set @OldValue = 'Old Value' + '#'+ 'Training name :' + @OldTraining_name + '#' +   
          'Training Description :' + @OldTraining_description + '#' +   
          'Training Category Id :' + cast(ISNULL(@OldTraining_Category_Id,'')as varchar(5)) + '#' +   
          'Training MCP :' + Cast(ISNULL(@OldTraining_MCP,'')as varchar(5))+ '#' +    
          'Company Id  :' + Cast(ISNULL(@Cmp_Id,0)as varchar(5))+ '#' +  
          'Training Coordinator :' + @OldTraining_Cordinator + '#' +  
          'Training Director :' + @OldTraining_Director + '#' +  
         'New Value' + '#'+ 'Training name :' + @Training_name + '#' +   
          'Training Description :' + @Training_description + '#' +   
          'Training Category Id :' + cast(ISNULL(@Training_Category_Id,0)as varchar(5)) + '#' +   
          'Training MCP :' + Cast(ISNULL(@Training_MCP,0)as varchar(5)) + '#' +   
          'Company Id  :' + Cast(ISNULL(@Cmp_Id,0)as varchar(5)) + '#' +  
          'Training Coordinator :' + @Training_Cordinator + '#' +   
          'Training Director :' + @Training_Director  
     --Added By Mukti 14082015(end)   
  end  
 Else If @Trans_Type = 'D'  
  begin  
    --Added By Mukti 14082015(start)  
     select @OldTraining_name=Training_name,@OldTraining_description = Training_description,  
       @OldTraining_Category_Id=Training_Category_Id,@OldTraining_MCP =Training_MCP  
     from T0040_Hrms_Training_master WITH (NOLOCK) where Training_id = @Training_id  
     --Added By Mukti 14082015(end)   
    
    Delete From T0040_Hrms_Training_master Where Training_id = @Training_id  
      
     --Added By Mukti 14082015(start)  
        set @OldValue = 'Old Value' + '#'+ 'Training name :' + @OldTraining_name + '#' +   
         'Training Description :' + @OldTraining_description + '#' +   
         'Training Category Id :' + cast(ISNULL(@OldTraining_Category_Id,'')as varchar(5)) + '#' +   
         'Training MCP :' + Cast(ISNULL(@OldTraining_MCP,'')as varchar(5))+ '#' +   
         'Company Id  :' + Cast(ISNULL(@Cmp_Id,0)as varchar(5)) + '#' +  
         'Training Coordinator :' + @OldTraining_Cordinator + '#' +  
         'Training Director :' + @OldTraining_Director   
     --Added By Mukti 14082015(end)   
  end  
   
 exec P9999_Audit_Trail @Cmp_ID,@Trans_Type,'Training Master',@OldValue,@Training_id,@User_Id,@IP_Address --Mukti 14082015  
  
RETURN  