  
  
  
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0040_ASSET_MASTER]  
 @Asset_ID  NUMERIC OUTPUT  
,@Cmp_ID  NUMERIC  
,@Asset_Name VARCHAR(50)  
,@Asset_Desc VARCHAR(150)  
,@Tran_type CHAR(1)  
,@User_Id numeric(18,0) = 0  
,@IP_Address varchar(30)= ''  
,@Asset_Code VARCHAR(10)  
  
  
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
declare @OldValue as  varchar(max)  
declare @OldAsset_Name as varchar(50)  
declare @OldAsser_Desc as varchar(150)  
  
set @OldAsset_Name=''  
set @OldAsser_Desc =''  
  
  set @Asset_Name = dbo.fnc_ReverseHTMLTags(@Asset_Name) --Ronak_070121    
   set @Asset_Desc = dbo.fnc_ReverseHTMLTags(@Asset_Desc) --Ronak_070121    
      set @Asset_Code = dbo.fnc_ReverseHTMLTags(@Asset_Code) --Ronak_070121 
IF @Tran_type = 'I'  
 BEGIN  
  if exists(select Asset_ID from t0040_Asset_master WITH (NOLOCK) where upper(Asset_Name) = upper(@Asset_name) and Cmp_id = @Cmp_id )  
   Begin  
    Set @Asset_ID = 0  
    return  
   End  
  if exists(select Asset_ID from t0040_Asset_master WITH (NOLOCK) where upper(Code) = upper(@Asset_Code) and Cmp_id = @Cmp_id)  
   Begin  
    Set @Asset_ID = 0  
    RAISERROR ('Already Exist Asset Code', 16, 2)  
    return  
   End  
  select @Asset_ID = isnull(max(Asset_ID),0) + 1  from t0040_Asset_Master WITH (NOLOCK)  
   
    
  insert into T0040_ASSET_MASTER (Asset_ID,Cmp_ID,Asset_Name,Asset_Desc,Code)  
    Values(@Asset_ID,@Cmp_ID,@Asset_Name,@Asset_Desc,@Asset_Code)  
    --Add By Paras 12-10-2012  
    set @OldValue = 'New Value' + '#'+ 'Asset Name :' +ISNULL( @Asset_Name,'') + '#' + 'Asset Discrition :' + ISNULL( @Asset_Desc,'') + '#'      
   --  
 END    
else if @Tran_type = 'U'  
 Begin   
  if exists(select Asset_ID  from  T0040_ASSET_MASTER WITH (NOLOCK) where UPPER(Asset_Name)= UPPER(@Asset_Name) and Cmp_ID=@Cmp_ID and Asset_ID <> @Asset_ID)      
  --Change By Paras 03-09-2012  
   Begin  
              set @Asset_ID = 0  
              return  
         End  
     
   if exists(select Asset_ID  from  T0040_ASSET_MASTER WITH (NOLOCK) where upper(Code) = upper(@Asset_Code) and Cmp_ID=@Cmp_ID and Asset_ID <> @Asset_ID)      
   Begin  
             Set @Asset_ID = 0  
    RAISERROR ('Already Exist Asset Code', 16, 2)  
    return  
         End  
           
   --Add by PAras 12-10-2012  
    select @OldAsset_Name  =ISNULL(Asset_Name,'') ,@OldAsser_Desc  =ISNULL(Asset_Desc,'') From dbo.T0040_ASSET_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Asset_ID = @Asset_ID  
      update t0040_Asset_Master   
   set Asset_Name = @Asset_Name,  
   Asset_Desc = @Asset_Desc,  
   Code=@Asset_Code  
   where Asset_ID = @Asset_ID And Cmp_ID = @Cmp_Id  
     
    set @OldValue = 'old Value' + '#'+ 'Asset Name :' + @OldAsset_Name  + '#' + 'Asset Description :' + @OldAsser_Desc  + '#' +   
                            + 'New Value' + '#'+ 'Asset Name :' +ISNULL( @Asset_Name,'') + '#' + 'Asset Discription :' + ISNULL( @Asset_Desc,'') + '#'   
                              
                            ------  
  
 End  
Else if @Tran_Type = 'D'      
 Begin  
 --Add by PAras 12-10-2012  
  select @OldAsset_Name  = Asset_Name ,@OldAsser_Desc  = Asset_Desc From dbo.t0040_Asset_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Asset_ID = @Asset_ID  
   Delete from t0040_Asset_Master where Asset_ID = @Asset_ID  
    set @OldValue = 'old Value' + '#'+ 'Asset Name :' + @OldAsset_Name   + '#' + 'Asset Discription :' + @OldAsser_Desc     
     
 End     
 exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Asset Master',@OldValue,@Asset_ID,@User_Id,@IP_Address  
  
RETURN  
  
  
  
  