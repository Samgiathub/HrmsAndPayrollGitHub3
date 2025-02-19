    
    
    
    
CREATE PROCEDURE [dbo].[P0040_LICENSE_MASTER]    
 @Lic_ID AS NUMERIC output,    
 @CMP_ID AS NUMERIC,    
 @Lic_Name AS VARCHAR(50),    
 @Lic_Comments AS VARCHAR(250),    
 @tran_type as varchar(1)    
 ,@User_Id numeric(18,0) = 0    
    ,@IP_Address varchar(30)= '' --Add By Paras 19-10-2012    
AS    
    
        SET NOCOUNT ON     
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
  SET ARITHABORT ON    
    
declare @OldValue as varchar(Max)    
declare @OldLic_Name as varchar(50)    
declare @OldLic_Comments as varchar(50)    
    
set @OldLic_Name = ''    
set @OldLic_Comments = ''    
    set @Lic_Name = dbo.fnc_ReverseHTMLTags(@Lic_Name)  --added by Ronak 081021  
	 set @Lic_Comments = dbo.fnc_ReverseHTMLTags(@Lic_Comments)  --added by Ronak 081021  
 If @tran_type  = 'I'    
  Begin    
   if exists(select Lic_ID from T0040_LICENSE_MASTER WITH (NOLOCK) where upper(Lic_Name) = upper(@Lic_Name) and Cmp_ID = @Cmp_ID)    
    begin    
     set @Lic_ID = 0    
     Return     
    end    
    
    select @Lic_ID = Isnull(max(Lic_ID),0) + 1  From T0040_LICENSE_MASTER WITH (NOLOCK)    
        
    INSERT INTO T0040_LICENSE_MASTER    
                          (Lic_ID, Cmp_ID, Lic_Name,Lic_Comments)    
    VALUES     (@Lic_ID, @Cmp_ID, @Lic_Name,@Lic_Comments)    
        
    set @OldValue = 'New Value' + '#'+ 'Lic Name :' +ISNULL( @Lic_Name,'') + '#' + 'Lic Comments :' + ISNULL( @Lic_Comments,'')     
        
        
  End    
 Else if @Tran_Type = 'U'    
    
  begin    
    If exists(select Lic_ID from T0040_LICENSE_MASTER WITH (NOLOCK) where upper(Lic_Name) = upper(@Lic_Name) and Lic_ID <> @Lic_ID    
        and Cmp_ID = @Cmp_ID )    
     begin    
      set @Lic_ID = 0    
      Return     
     end    
         
     select @OldLic_Name  =ISNULL(Lic_Name,'') ,@OldLic_Comments =ISNULL(Lic_Comments,'') From dbo.T0040_LICENSE_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Lic_ID = @Lic_ID    
         
    Update T0040_LICENSE_MASTER    
    set Lic_Name = @Lic_Name ,Lic_Comments = @Lic_Comments    
    where Lic_ID = @Lic_ID    
        
    set @OldValue = 'old Value' + '#'+ 'Lic Name :' + @OldLic_Name  + '#' + 'Lic Comments :' + @OldLic_Comments  +    
                              + 'New Value' + '#'+ 'Lic Name :' +ISNULL( @Lic_Name,'') + '#' + 'Lic Comments:' + ISNULL( @Lic_Comments,'')     
      
  End    
 Else if @Tran_Type = 'D'    
  begin    
  select @OldLic_Name  =ISNULL(Lic_Name,'') ,@OldLic_Comments =ISNULL(Lic_Comments,'') From dbo.T0040_LICENSE_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Lic_ID = @Lic_ID    
    Delete From T0040_LICENSE_MASTER Where Lic_ID = @Lic_ID    
    set @OldValue = 'old Value' + '#'+ 'Lic Name :' + @OldLic_Name  + '#' + 'Lic Comments :' + @OldLic_Comments      
  end    
  exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'License Master',@OldValue,@Lic_ID,@User_Id,@IP_Address    
    
 RETURN    
    
    
    