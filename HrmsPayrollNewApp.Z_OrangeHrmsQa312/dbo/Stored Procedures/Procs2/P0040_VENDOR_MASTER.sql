  
  
CREATE PROCEDURE [dbo].[P0040_VENDOR_MASTER]  
 @Vendor_Id  NUMERIC OUTPUT  
,@Cmp_ID  NUMERIC  
,@Vendor_Name VARCHAR(50)  
,@Address VARCHAR(150)  
,@City VARCHAR(150)  
,@Contact_Person VARCHAR(150)  
,@Contact_Number VARCHAR(150)  
,@Tran_type CHAR(1)  
,@User_Id numeric(18,0) = 0  
,@IP_Address varchar(30)= ''  
,@Branch_id numeric
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
   set @Vendor_Name = dbo.fnc_ReverseHTMLTags(@Vendor_Name) --Ronak_060121    
   set @Address = dbo.fnc_ReverseHTMLTags(@Address) --Ronak_060121    
IF @Tran_type = 'I'  
 BEGIN  
  if exists(select Vendor_Id from t0040_vendor_master WITH (NOLOCK) where upper(Vendor_Name) = upper(@Vendor_Name) and Cmp_id = @Cmp_id )  
   Begin  
    Set @Vendor_Id = 0  
   return  
   End  
  select @Vendor_Id = isnull(max(Vendor_Id),0) + 1  from t0040_vendor_master WITH (NOLOCK)   
   
  insert into t0040_vendor_master (Vendor_Id,Vendor_Name,[Address],City,Contact_Person,Contact_Number,Cmp_ID,Branch_ID)  
  Values(@Vendor_Id,@Vendor_Name,@Address,@City,@Contact_Person,@Contact_Number,@Cmp_ID,@Branch_id)  
    
  -- Add By Mukti 11072016(start)  
   exec P9999_Audit_get @table = 't0040_vendor_master' ,@key_column='Vendor_Id',@key_Values=@Vendor_Id,@String=@String_val output  
   set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))    
  -- Add By Mukti 11072016(end)     
 END    
else if @Tran_type = 'U'  
 Begin   
  if exists(select Vendor_Id  from  t0040_vendor_master WITH (NOLOCK) where UPPER(Vendor_Name)= UPPER(@Vendor_Name) and Cmp_ID=@Cmp_ID and Vendor_Id <> @Vendor_Id)      
   Begin  
              set @Vendor_Id = 0  
              return  
         End  
     
   -- Add By Mukti 11072016(start)  
     exec P9999_Audit_get @table='t0040_vendor_master' ,@key_column='Vendor_Id',@key_Values=@Vendor_Id,@String=@String_val output  
     set @OldValue = @OldValue + 'old Value' + '#' + cast(@String_val as varchar(max))  
   -- Add By Mukti 11072016(end)  
     
   update t0040_vendor_master   
   set Vendor_Name = @Vendor_Name,  
   [Address] = @Address,     
   City=@City,  
   Contact_Person=@Contact_Person,  
   Contact_Number=@Contact_Number,
   Branch_ID = @Branch_id
   where Vendor_Id = @Vendor_Id And Cmp_ID = @Cmp_Id  
     
   -- Add By Mukti 11072016(start)  
    exec P9999_Audit_get @table = 't0040_vendor_master' ,@key_column='Vendor_Id',@key_Values=@Vendor_Id,@String=@String_val output  
    set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))  
   -- Add By Mukti 11072016(end)   
 End  
Else if @Tran_Type = 'D'      
 Begin  
   -- Add By Mukti 11072016(start)  
     exec P9999_Audit_get @table='t0040_vendor_master' ,@key_column='Vendor_Id',@key_Values=@Vendor_Id,@String=@String_val output  
     set @OldValue = @OldValue + 'old Value' + '#' + cast(@String_val as varchar(max))  
   -- Add By Mukti 11072016(end)  
     
  Delete from t0040_vendor_master where Vendor_Id = @Vendor_Id  
 End    
  exec P9999_Audit_Trail @CMP_ID,@Tran_Type,'Vendor Master',@OldValue,@Vendor_Id,@User_Id,@IP_Address   
RETURN  
  
  
  
  