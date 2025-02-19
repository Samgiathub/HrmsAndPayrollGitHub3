  
  
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0040_Asset_Details]  
 @AssetM_ID numeric OUTPUT  
 ,@Cmp_ID numeric  
 ,@Asset_CategoryID numeric  
 ,@Description varchar(max)  
 ,@Type_of_Asset varchar(50)  
 ,@SerialNo varchar(50)  
 ,@Brand_ID numeric  
 ,@Model varchar(50)  
 ,@Vendor varchar(50)  
 ,@Status varchar(10)  
 ,@Branch numeric  
 ,@Assign_To_Emp numeric  
 ,@Purchase_date datetime  
 ,@Warranty_Starts datetime  
 ,@Warranty_Ends datetime  
 ,@Asset_Code varchar(50)  
 ,@Image varchar(50)  
 ,@Tran_type CHAR(1)  
 ,@User_Id numeric  
 ,@IP_Address varchar(30)= ''  
 ,@Allocation_Date datetime  
 ,@Asset_Status varchar(25)  
 ,@Inv_No varchar(50)  
 ,@Inv_amt float  
 ,@Return_date datetime  
 ,@Attach_Doc nvarchar(max)=''  
 ,@Vendor_Address varchar(max)   
 ,@Invoice_Date Datetime  
 ,@PONO varchar(100)  
 ,@pono_Date datetime  
 ,@city  varchar(100)  
 ,@contact_person varchar(250)  
 ,@contact_no varchar(250)  
 ,@Dispose_date datetime  
 ,@Vendor_id numeric =0  
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
  
declare @Asset_Approval_ID as numeric  
declare @Asset_ApprDet_ID as numeric  
declare @allocation as numeric  
declare @Assign_To_Branch1 as numeric  
declare @Assign_To_Emp1 as numeric  
declare @RecID numeric  
declare @Asset_Approval_ID1 as numeric  
declare @alloc_date datetime  
--declare @Status1 varchar(5)  
  
if @Vendor_id = 0  
 set @Vendor_id=NULL  

   set @Description = dbo.fnc_ReverseHTMLTags(@Description)  --added by Ronak 021121     
   set @SerialNo = dbo.fnc_ReverseHTMLTags(@SerialNo)  --added by Ronak 021121   
   set @Model = dbo.fnc_ReverseHTMLTags(@Model)  --added by Ronak 021121  
   set @Vendor_Address = dbo.fnc_ReverseHTMLTags(@Vendor_Address)  --added by Ronak 021121  
    set @Inv_No = dbo.fnc_ReverseHTMLTags(@Inv_No)  --added by Ronak 021121  
	 set @PONO = dbo.fnc_ReverseHTMLTags(@PONO)  --added by Ronak 021121  
	 set @Vendor = dbo.fnc_ReverseHTMLTags(@Vendor)  --added by Ronak 021121  

IF @Tran_type = 'I'  
 BEGIN  
  if exists(select Asset_Code from T0040_Asset_details WITH (NOLOCK) where upper(Asset_Code) = upper(@Asset_Code) and Cmp_id = @Cmp_id)  
   Begin  
    Set @AssetM_ID = 0  
    return  
   End  
     
   if exists(select SerialNo from T0040_Asset_details WITH (NOLOCK) where upper(SerialNo) = upper(@SerialNo) and Cmp_id = @Cmp_id)  
   Begin  
    Set @SerialNo = 0  
    RAISERROR ('Already Exist Serial No.', 16, 2)  
    return  
   End  
     
   --if exists(select Asset_Code from T0040_Asset_details where upper(Asset_Code) = upper(@Asset_Code) and Cmp_id = @Cmp_id)  
   --Begin  
   -- Set @Asset_Code = ''  
   -- RAISERROR ('Already Exist Asset Code', 16, 2)  
   -- return  
   --End  
     
   select @AssetM_ID = isnull(max(AssetM_ID),0) + 1  from T0040_Asset_details WITH (NOLOCK)  
    
    insert into T0040_Asset_details (AssetM_ID,Cmp_ID,asset_id,[Description],Type_of_Asset,SerialNo,BRAND_ID,Model,Vendor,[Status],Purchase_date,Warranty_Starts,Warranty_Ends,[Image],Asset_Code,allocation,Asset_Status,Invoice_No,Invoice_Amount,Attach_Doc,
Vendor_Address,Invoice_Date,PONO,pono_Date,city,contact_person,contact_no,Dispose_date,Vendor_id,Branch_ID)  
    Values(@AssetM_ID,@Cmp_ID,@Asset_CategoryID,@Description,@Type_of_Asset,@SerialNo,@Brand_ID,@Model,@Vendor,@Status,@Purchase_date,@Warranty_Starts,@Warranty_Ends,@Image,@Asset_Code,0,@Asset_Status,@Inv_No,@Inv_amt,@Attach_Doc,@Vendor_Address,@Invoice_Date,@PONO,@pono_Date,@city,@contact_person,@contact_no,@Dispose_date,@Vendor_id,@Branch)  
    
  -- Add By Mukti 11072016(start)  
   exec P9999_Audit_get @table = 'T0040_Asset_details' ,@key_column='AssetM_ID',@key_Values=@AssetM_ID,@String=@String_val output  
   set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))    
  -- Add By Mukti 11072016(end)   
     
 END    
else if @Tran_type = 'U'  
 Begin   
  if exists(select AssetM_ID from T0040_Asset_details WITH (NOLOCK) where UPPER(Asset_Code)= UPPER(@Asset_Code) and Cmp_ID=@Cmp_ID and AssetM_ID <> @AssetM_ID)      
   Begin  
              set @AssetM_ID = 0  
              return  
        End  
          
        if exists(select AssetM_ID from T0040_Asset_details WITH (NOLOCK) where UPPER(SerialNo)= UPPER(@SerialNo) and Cmp_ID=@Cmp_ID and AssetM_ID <> @AssetM_ID)      
   Begin  
             Set @SerialNo = 0  
    RAISERROR ('Already Exist Serial No.', 16, 2)  
    return  
        End  
          
      -- Add By Mukti 11072016(start)  
     exec P9999_Audit_get @table='T0040_Asset_details' ,@key_column='AssetM_ID',@key_Values=@AssetM_ID,@String=@String_val output  
     set @OldValue = @OldValue + 'old Value' + '#' + cast(@String_val as varchar(max))  
   -- Add By Mukti 11072016(end)  
     
      update T0040_Asset_details   
   set asset_id=@Asset_CategoryID,  
   [Description]=@Description,  
   Type_of_Asset=@Type_of_Asset,  
   SerialNo=@SerialNo,  
   BRAND_ID=@Brand_ID,  
   Model=@Model,  
   Vendor=@Vendor,  
   [Status]=@Status,  
   Purchase_date=@Purchase_date,  
   Warranty_Starts=@Warranty_Starts,  
   Warranty_Ends=@Warranty_Ends,  
   [Image]=@Image,  
   Asset_Code=@Asset_Code,  
   --allocation=@allocation,  
   Asset_Status=@Asset_Status,  
   Invoice_No=@Inv_No,  
   Invoice_Amount=@Inv_amt,  
   Attach_Doc=@Attach_Doc,  
   Vendor_Address=@Vendor_Address,  
   Invoice_Date=@Invoice_Date,  
   PONO=@PONO,  
   pono_Date=@pono_Date,  
   city=@city ,  
   contact_person=@contact_person,  
   contact_no =@contact_no,  
   Dispose_date=@Dispose_date,  
   Vendor_id=@Vendor_id,  
   Branch_ID=@Branch  
   where AssetM_ID = @AssetM_ID And Cmp_ID = @Cmp_Id  
    
  -- Add By Mukti 11072016(start)  
    exec P9999_Audit_get @table = 'T0040_Asset_details' ,@key_column='AssetM_ID',@key_Values=@AssetM_ID,@String=@String_val output  
    set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))  
  -- Add By Mukti 11072016(end)   
 End  
Else if @Tran_Type = 'D'      
 Begin  
   -- Add By Mukti 11072016(start)  
   exec P9999_Audit_get @table='T0040_Asset_details' ,@key_column='AssetM_ID',@key_Values=@AssetM_ID,@String=@String_val output  
   set @OldValue = @OldValue + 'old Value' + '#' + cast(@String_val as varchar(max))  
  -- Add By Mukti 11072016(end)  
    
  delete from T0110_Asset_Title_Details where AssetM_ID = @AssetM_ID  
  Delete from T0040_Asset_details where AssetM_ID = @AssetM_ID  
 End      
 exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Asset Details',@OldValue,@AssetM_ID,@User_Id,@IP_Address  
RETURN  
  
  
  
  