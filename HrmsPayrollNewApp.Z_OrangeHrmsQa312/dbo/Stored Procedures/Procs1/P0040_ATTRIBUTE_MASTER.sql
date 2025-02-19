  
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0040_ATTRIBUTE_MASTER]  
 @Attribute_ID AS NUMERIC output,  
 @Attribute_Name AS VARCHAR(300),  
 @CMP_ID AS NUMERIC,  
 @Description as varchar(max),   
 @tran_type varchar(1),  
 @User_Id numeric(18,0) = 0,  
    @IP_Address varchar(30)= ''   
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
   
declare @OldValue as  varchar(max)  
declare @OldAttribute_Name as varchar(50)  
declare @OldDescription as varchar(100)  
  
set @OldAttribute_Name =''  
set @OldDescription = ''  
  
   set @Attribute_Name = dbo.fnc_ReverseHTMLTags(@Attribute_Name)  --added by Ronak 011022  
	set @Description = dbo.fnc_ReverseHTMLTags(@Description)  --added by Ronak 011022    
  
 If @tran_type  = 'I'  
  Begin  
    If Exists(Select Attribute_ID From T0040_ATTRIBUTE_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and upper(Attribute_Name) = upper(@Attribute_Name))  
     begin     
      set @Attribute_ID = 0  
      Return   
     end  
      
    select @Attribute_ID= Isnull(max(Attribute_ID),0) + 1  From T0040_ATTRIBUTE_MASTER WITH (NOLOCK)  
      
             
    if @Attribute_Name  <> ''  
      Begin   
      
    INSERT INTO T0040_ATTRIBUTE_MASTER  
                          (Attribute_ID, Cmp_ID, Attribute_Name,Description)  
    VALUES     (@Attribute_ID, @Cmp_ID,@Attribute_Name,@Description)  
      
     End    
     set @OldValue = 'New Value' + '#'+ 'Attribute Name :' +ISNULL( @Attribute_Name,'') + '#' + 'Description :' + ISNULL( @Description,'') + '#'   
      
      
  End  
 Else if @Tran_Type = 'U'  
  begin  
    If Exists(Select Attribute_ID From T0040_ATTRIBUTE_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Attribute_ID <> @Attribute_ID and upper(Attribute_Name) = upper(@Attribute_Name))  
     begin  
      set @Attribute_ID = 0  
      Return   
     end  
       
                 select @OldAttribute_Name  =ISNULL(Attribute_Name,'') ,@OldDescription  =ISNULL(Description,'') From dbo.T0040_ATTRIBUTE_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Attribute_ID = @Attribute_ID  
            
    Update T0040_ATTRIBUTE_MASTER  
    set Attribute_Name=@Attribute_Name  
        ,Description=@Description          
    where Attribute_ID = @Attribute_ID  
      
    set @OldValue = 'old Value' + '#'+ 'Attribute Name :' + @OldAttribute_Name  + '#' + 'Description:' + @OldDescription    
               + 'New Value' + '#'+ 'AttributeName :' +ISNULL( @Attribute_Name,'') + '#' + 'Description :' + ISNULL( @Description,'')   
      
  end  
 Else if @Tran_Type = 'D'  
  begin  
    
   select @OldAttribute_Name  =ISNULL(Attribute_Name,'') ,@OldDescription  =ISNULL(Description,'') From dbo.T0040_ATTRIBUTE_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Attribute_ID = @Attribute_ID  
    Delete From T0040_ATTRIBUTE_MASTER Where Attribute_ID = @Attribute_ID  
    set @OldValue = 'old Value' + '#'+ 'Attribute Name :' + @OldAttribute_Name  + '#' + 'Description:' + @OldDescription    
  end  
           exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Attribute Master',@OldValue,@Attribute_ID,@User_Id,@IP_Address  
 RETURN  
  
  
  
  