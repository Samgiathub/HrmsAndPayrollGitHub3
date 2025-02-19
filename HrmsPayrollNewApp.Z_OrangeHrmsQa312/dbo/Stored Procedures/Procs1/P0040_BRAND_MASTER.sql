  
  
  
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0040_BRAND_MASTER]  
 @Brand_ID  NUMERIC OUTPUT  
,@Cmp_ID  NUMERIC  
,@Brand_Name VARCHAR(50)  
,@Brand_Desc VARCHAR(150)  
,@Tran_type CHAR(1)  
,@User_Id numeric(18,0) = 0  
,@IP_Address varchar(30)= ''  
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
declare @OldValue as  varchar(max)  
declare @OldBrand_Name as varchar(50)  
declare @OldBrand_Desc as varchar(150)  
  
set @OldBrand_Name=''  
set @OldBrand_Desc =''  
  
       set @Brand_Name = dbo.fnc_ReverseHTMLTags(@Brand_Name)  --added by mansi 061021  
	    set @Brand_Desc = dbo.fnc_ReverseHTMLTags(@Brand_Desc)  --added by Ronak 021121  
IF @Tran_type = 'I'  
 BEGIN  
  if exists(select Brand_ID from t0040_Brand_master WITH (NOLOCK) where upper(Brand_Name) = upper(@Brand_name) and Cmp_id = @Cmp_id )  
   Begin  
    Set @Brand_ID = 0  
   return  
   End  
  select @Brand_ID = isnull(max(Brand_ID),0) + 1  from t0040_Brand_Master WITH (NOLOCK)   
   
    
  insert into T0040_Brand_MASTER (Brand_ID,Cmp_ID,Brand_Name,Brand_Desc)  
    Values(@Brand_ID,@Cmp_ID,@Brand_Name,@Brand_Desc)  
    --Add By Paras 12-10-2012  
    set @OldValue = 'New Value' + '#'+ 'Brand Name :' +ISNULL( @Brand_Name,'') + '#' + 'Brand Description :' + ISNULL( @Brand_Desc,'') + '#'      
   --  
 END    
else if @Tran_type = 'U'  
 Begin   
  if exists(select Brand_ID  from  T0040_Brand_MASTER WITH (NOLOCK) where UPPER(Brand_Name)= UPPER(@Brand_Name) and Cmp_ID=@Cmp_ID and Brand_ID <> @Brand_ID)      
  --Change By Paras 03-09-2012  
   Begin  
              set @Brand_ID = 0  
              return  
             
   End  
   --Add by PAras 12-10-2012  
    select @OldBrand_Name  =ISNULL(Brand_Name,'') ,@OldBrand_Desc  =ISNULL(Brand_Desc,'') From dbo.T0040_Brand_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Brand_ID = @Brand_ID  
      update t0040_Brand_Master   
   set Brand_Name = @Brand_Name,  
   Brand_Desc = @Brand_Desc  
   where Brand_ID = @Brand_ID And Cmp_ID = @Cmp_Id  
     
    set @OldValue = 'old Value' + '#'+ 'Brand Name :' + @OldBrand_Name  + '#' + 'Brand Description :' + @OldBrand_Desc  + '#' +   
                            + 'New Value' + '#'+ 'Brand Name :' +ISNULL( @Brand_Name,'') + '#' + 'Brand Description :' + ISNULL( @Brand_Desc,'') + '#'   
                              
                            ------  
  
 End  
Else if @Tran_Type = 'D'      
 Begin  
 --Add by PAras 12-10-2012  
  select @OldBrand_Name  = Brand_Name ,@OldBrand_Desc  = Brand_Desc From dbo.t0040_Brand_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Brand_ID = @Brand_ID  
   Delete from t0040_Brand_Master where Brand_ID = @Brand_ID  
    set @OldValue = 'old Value' + '#'+ 'Brand Name :' + @OldBrand_Name   + '#' + 'Brand Description :' + @OldBrand_Desc     
     
 End     
 exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Brand Master',@OldValue,@Brand_ID,@User_Id,@IP_Address  
  
RETURN  
  
  
  
  