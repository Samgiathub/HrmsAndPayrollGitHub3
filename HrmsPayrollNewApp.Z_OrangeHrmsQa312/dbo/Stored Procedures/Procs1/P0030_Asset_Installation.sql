  
  
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0030_Asset_Installation]  
 @Installation_id  NUMERIC OUTPUT  
,@Cmp_ID  NUMERIC  
,@Asset_Id NUMERIC  
,@Installation_Name VARCHAR(500)  
,@Type char(1)  
,@Tran_type CHAR(1)  
,@User_Id numeric(18,0) = 0 -- Add By Mukti 11072016  
,@IP_Address varchar(30)= '' -- Add By Mukti 11072016  
  
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
-- Add By Mukti 11072016(start)  
 declare @OldValue as  varchar(max)  
 Declare @String_val as varchar(max)  
 set @String_val=''  
 set @OldValue =''  
-- Add By Mukti 11072016(end)   
   set @Installation_Name = dbo.fnc_ReverseHTMLTags(@Installation_Name) --Ronak_070121    

IF @Tran_type = 'I'  
 BEGIN  
  if exists(select Asset_Installation_ID from T0030_Asset_Installation where upper(Installation_Name) = upper(@Installation_Name)  and Asset_Id = @Asset_Id and Cmp_id = @Cmp_id and Installation_Type = @type)  
   Begin  
    Set @Installation_id = 0  
    return  
   End  
  select @Installation_id = isnull(max(Asset_Installation_ID),0) + 1  from T0030_Asset_Installation WITH (NOLOCK)   
    
  insert into T0030_Asset_Installation (Asset_Installation_ID,Cmp_ID,Asset_Id,Installation_Name,Installation_Type)  
  Values(@Installation_id,@Cmp_ID,@Asset_Id,@Installation_Name,@type)  
     
  -- Add By Mukti 11072016(start)  
   exec P9999_Audit_get @table = 'T0030_Asset_Installation' ,@key_column='Asset_Installation_ID',@key_Values=@Installation_id,@String=@String_val output  
   set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))    
  -- Add By Mukti 11072016(end)    
 END    
else if @Tran_type = 'U'  
 Begin   
  --if exists(select Asset_ID  from  T0030_Asset_Insatallation where UPPER(Asset_Name)= UPPER(@Asset_Name) and Cmp_ID=@Cmp_ID and Asset_ID <> @Asset_ID)      
  -- Begin  
  --            set @Asset_ID = 0  
  --            return  
  --       End  
     
   -- Add By Mukti 11072016(start)  
     exec P9999_Audit_get @table='T0030_Asset_Installation' ,@key_column='Asset_Installation_ID',@key_Values=@Installation_id,@String=@String_val output  
     set @OldValue = @OldValue + 'old Value' + '#' + cast(@String_val as varchar(max))  
   -- Add By Mukti 11072016(end)  
     
      update T0030_Asset_Installation   
   set Asset_Id = @Asset_Id,  
   Installation_Name = @Installation_Name,  
   Installation_Type=@type  
   where Asset_Installation_id = @Installation_id And Cmp_ID = @Cmp_Id  
     
   -- Add By Mukti 11072016(start)  
    exec P9999_Audit_get @table = 'T0030_Asset_Installation' ,@key_column='Asset_Installation_ID',@key_Values=@Installation_id,@String=@String_val output  
    set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))  
   -- Add By Mukti 11072016(end)   
     
 End  
Else if @Tran_Type = 'D'      
 Begin  
  -- Add By Mukti 11072016(start)  
   exec P9999_Audit_get @table='T0030_Asset_Installation' ,@key_column='Asset_Installation_ID',@key_Values=@Installation_id,@String=@String_val output  
   set @OldValue = @OldValue + 'old Value' + '#' + cast(@String_val as varchar(max))  
  -- Add By Mukti 11072016(end)  
    
   Delete from T0030_Asset_Installation where Asset_Installation_ID = @Installation_id and cmp_id=@cmp_id     
 End     
  exec P9999_Audit_Trail @CMP_ID,@Tran_Type,'Asset Installation',@OldValue,@Installation_id,@User_Id,@IP_Address  
RETURN  
  
  
  
  