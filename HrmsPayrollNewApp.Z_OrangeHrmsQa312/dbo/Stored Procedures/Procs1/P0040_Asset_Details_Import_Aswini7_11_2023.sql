
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
create PROCEDURE [dbo].[P0040_Asset_Details_Import_Aswini7/11/2023]
	@AssetM_ID numeric OUTPUT
	,@Cmp_ID numeric
	,@Asset_Category varchar(150)
	,@Description varchar(max)
	,@Type_of_Asset varchar(50)
	,@SerialNo varchar(50)
	,@Brand varchar(50)
	,@Model varchar(50)
	,@Vendor varchar(50)
	,@Status varchar(10)
	,@Assign_To_Branch numeric
	,@Assign_To_Emp numeric
	,@Purchase_date datetime
	,@Warranty_Starts datetime
	,@Warranty_Ends datetime
	--,@Asset_Code varchar(50)
	,@Image varchar(50)
	,@Tran_type	CHAR(1)
	,@User_Id numeric
	,@IP_Address varchar(30)= ''
	,@Allocation_Date datetime
	,@Asset_Status varchar(5)
	,@Inv_No varchar(50)
	,@Inv_amt float
	--,@Vendor_Address varchar(max) 
	,@Invoice_Date Datetime
	,@PONO varchar(100)
	,@pono_Date datetime
	,@Branch_Name varchar(500)
	,@Log_Status Int = 0 Output
	,@Row_No int
	,@GUID Varchar(2000)

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

declare @OldValue as  varchar(max)
declare @OldAsset_CategoryID numeric
declare @OldDescription varchar(max)
declare @OldType_of_Asset varchar(50)
declare	@OldSerialNo varchar(50)
declare @OldBrand_ID numeric
declare @OldModel varchar(50)
declare	@OldVendor varchar(50)
declare	@OldStatus varchar(10)
declare @OldAssign_To_Branch numeric
declare @OldAssign_To_Emp numeric
declare @OldPurchase_date datetime
declare @OldWarranty_Starts datetime
declare @OldWarranty_Ends datetime
declare @OldAsset_Code varchar(50)
declare @OldImage varchar(50)
declare @OldAllocation varchar(50)
declare	@OldAllocation_Date datetime

declare @Asset_CategoryID as numeric
declare @Asset_ID1 as numeric
declare @Brand_ID1 as numeric
declare @Brand_ID as numeric
declare @allocation as numeric
declare @Assign_To_Branch1 as numeric
declare @Assign_To_Emp1 as numeric
declare @RecID numeric
declare @Asset_Code varchar(50)
DECLARE @Branch_ID as INT
--declare @Status1 varchar(5)


IF @Tran_type = 'I'
	BEGIN
	   
		--If @Asset_Code = ''
		--		BEGIN
		--			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Asset Code is not Properly Inserted',0,'Enter Proper Asset Code',GetDate(),'Asset Details')						
		--			Set @Log_Status=1
		--			Return
		--		END
		If @Asset_Category = ''
				BEGIN
				
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Asset Category is not Properly Inserted',0,'Enter Proper Asset Category',GetDate(),'Asset Details',@GUID)						
					Set @Log_Status=1
					Return
				END
		If @Type_of_Asset = ''
				BEGIN
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Type_of_Asset of Asset is not Properly Inserted',0,'Enter Proper Type_of_Asset',GetDate(),'Asset Details',@GUID)						
					Set @Log_Status=1
					Return
				END
		--else if @Type_of_Asset <> 'Fix Assets' or @Type_of_Asset <> 'Operational Assets' or @Type_of_Asset <> 'Software and Application' 
		--		BEGIN
		--			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Type_of_Asset of Asset is not Properly Inserted',0,'Enter Proper Type_of_Asset',GetDate(),'Asset Details')						
		--			Set @Log_Status=1
		--			Return
		--		END
				
		If @SerialNo = ''
				BEGIN
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Asset Serial No is not Properly Inserted',0,'Enter Proper Asset SerialNo',GetDate(),'Asset Details',@GUID)						
					Set @Log_Status=1
					Return
				END
				
		If @Brand = ''
				BEGIN
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Asset Brand is not Properly Inserted',0,'Enter Proper Asset Brand',GetDate(),'Asset Details',@GUID)						
					Set @Log_Status=1
					Return
				END
		If @Model = ''
				BEGIN
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Asset Model is not Properly Inserted',0,'Enter Proper Asset Model',GetDate(),'Asset Details',@GUID)						
					Set @Log_Status=1
					Return
				END
				
		If @Branch_Name = ''
				BEGIN
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Branch Name is required',0,'Enter Branch Name',GetDate(),'Asset Details',@GUID)						
					Set @Log_Status=1
					Return
				END

              







			
		if exists(select SerialNo from T0040_Asset_details WITH (NOLOCK) where SerialNo = @SerialNo and Cmp_id = @Cmp_id)
			Begin
			
				Set @SerialNo = 0
			--	RAISERROR ('Already Exist Serial No.', 16, 2)
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Already Exist Serial No.',0,'Already Exist Serial No.',GetDate(),'Asset Details',@GUID)						
				Set @Log_Status=1
				return
			End
			declare @Code as varchar(25)
			declare @Code1 as varchar(25)
			--declare @Code2 as varchar(25)
		select @AssetM_ID = isnull(max(AssetM_ID),0) + 1  from T0040_Asset_details WITH (NOLOCK)
		

		if @Asset_Category<>''
		begin 
		set @Asset_Category =  REPLACE(@Asset_Category,'&','')
		if exists(select  Asset_ID  from T0040_ASSET_MASTER WITH (NOLOCK) where upper(Asset_Name) = upper(@Asset_Category)  and Cmp_ID = @cmp_id)
			begin 
				select  @Asset_CategoryID = Asset_ID,@Code=isnull(upper(Code),'') from T0040_ASSET_MASTER WITH (NOLOCK) where upper(Asset_Name) = upper(@Asset_Category)  and Cmp_ID = @cmp_id
				if @Code <> ''
					begin
						select top 1 @Code1=isnull(Asset_Code,'') from T0040_Asset_details WITH (NOLOCK) where Asset_ID = upper(@Asset_CategoryID)  and Cmp_ID = @cmp_id order by  AssetM_ID desc
						--select @Code2=RIGHT(@Code1, CHARINDEX('/', REVERSE(@Code1)) - 1) 
						print @Code1
						if @Code1 <> ''
							begin
								set @Asset_Code=@Code + '/0' + cast(cast(RIGHT(@Code1, CHARINDEX('/', REVERSE(@Code1)) - 1) as numeric) + 1 as varchar(5))
							end
						else
							begin
								set @Asset_Code=@Code + '/01' 
							end
					end
				else
					begin
						Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'First enter Asset Code in Asset Master',0,'First enter Asset Code in Asset Master',GetDate(),'Asset Details',@GUID)						
						Set @Log_Status=1
						return
					end				
			end
		else
			begin 
				select @Asset_ID1 = isnull(max(Asset_ID),0) + 1  from t0040_Asset_Master WITH (NOLOCK)	
				insert into T0040_ASSET_MASTER (Asset_ID,Cmp_ID,Asset_Name,Asset_Desc)Values(@Asset_ID1,@Cmp_ID,@Asset_Category,'')
				select  @Asset_CategoryID = Asset_ID   from T0040_ASSET_MASTER WITH (NOLOCK) where Asset_Name = upper(@Asset_Category)  and Cmp_ID = @cmp_id
			end
			end
  --    
		if exists(select 1 from T0030_BRANCH_MASTER WITH (NOLOCK) where Branch_Name=@Branch_Name and Cmp_ID=@Cmp_ID)
			begin 
				select @Branch_ID = Branch_ID from T0030_BRANCH_MASTER WITH (NOLOCK) where Branch_Name=@Branch_Name and Cmp_ID=@Cmp_ID
			end
		else
			begin 				
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Enter proper branch',0,'Branch Name not exist',GetDate(),'Asset Details',@GUID)						
				Set @Log_Status=1
				return					
			end
			
    
	
		if exists(select BRAND_ID from T0040_BRAND_MASTER WITH (NOLOCK) where BRAND_Name=@Brand and Cmp_ID=@Cmp_ID)
			begin 
				select @Brand_ID = BRAND_ID from T0040_BRAND_MASTER WITH (NOLOCK) where BRAND_Name=@Brand and Cmp_ID=@Cmp_ID
			end
		else
			begin 
					select @Brand_ID1 = isnull(max(Brand_ID),0) + 1  from t0040_Brand_Master WITH (NOLOCK)		
					insert into T0040_Brand_MASTER (Brand_ID,Cmp_ID,Brand_Name,Brand_Desc)Values(@Brand_ID1,@Cmp_ID,@Brand,'')
					select @Brand_ID = BRAND_ID from T0040_BRAND_MASTER WITH (NOLOCK) where BRAND_Name=@Brand and Cmp_ID=@Cmp_ID
			end
		


			declare @Vendor_id as numeric
			if @Vendor <>''
			begin
	
			
				if exists(select Vendor_ID from T0040_Vendor_MASTER WITH (NOLOCK) where Vendor_Name=@Vendor and Cmp_ID=@Cmp_ID)
					begin
						select @Vendor_id = Vendor_ID from T0040_Vendor_MASTER WITH (NOLOCK) where Vendor_Name=@Vendor and Cmp_ID=@Cmp_ID
					end
				else
					begin
						Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Vendor name not exist',0,'Vendor name not exist in Vendor Master',GetDate(),'Asset Details',@GUID)						
						Set @Log_Status=1
						Return
					end
					
			end
			
			if not(@Assign_To_Branch > 0 or @Assign_To_Emp > 0)
				begin
					set @allocation = 0
					set @Allocation_Date='01/01/1900'
				end
			else
				set @allocation = 1
				
			if CONVERT(VARCHAR,@Purchase_date,103) <> '01/01/1900' and CONVERT(VARCHAR,@Warranty_Starts,103) = '01/01/1900'
				BEGIN
					set @Warranty_Starts = @Purchase_date
					set @Warranty_Ends = DATEADD(yy,1,@Purchase_date)
				END
			if CONVERT(VARCHAR,@Purchase_date,103) <> '01/01/1900' and CONVERT(VARCHAR,@Warranty_Starts,103) <> '01/01/1900' and CONVERT(VARCHAR,@Warranty_Ends,103) = '01/01/1900'
				BEGIN					
					set @Warranty_Ends = DATEADD(yy,1,@Warranty_Starts)
				END

			--exec P0040_Asset_details @AssetM_ID,@Cmp_ID,@Asset_CategoryID,@Description,@Type_of_Asset,@SerialNo,@Brand_ID,@Model,@Vendor,@Status,0,0,@Purchase_date,@Warranty_Starts,@Warranty_Ends,@Asset_Code,@Image,'I',@User_Id,@IP_Address,'01/01/1900',@allocation,@Asset_Status,@Inv_No,@Inv_amt,'I'
	
			--exec P0040_Asset_Details_Import @AssetM_ID,@Cmp_ID,@Asset_CategoryID,@Description,@Type_of_Asset,@SerialNo,@Brand_ID,@Model,@Vendor,@Status,@Assign_To_Branch,@Assign_To_Emp,@Purchase_date,@Warranty_Starts,@Warranty_Ends,@Asset_Code,@Image,'I',@User_Id,@IP_Address,@Allocation_Date,@Asset_Status,@Inv_No,@Inv_amt,'01/01/1900'
			
			--if exists(select * from T0040_Asset_details where upper(Asset_Code) = upper(@Asset_Code) and asset_id=@Asset_CategoryID  and Cmp_id = @Cmp_id)
			if exists(select * from T0040_Asset_details WITH (NOLOCK) where upper(Asset_Code) = upper(@Asset_Code) and Cmp_id = @Cmp_id)
				BEGIN
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Asset Code already exist',0,'Asset Code already exist',GetDate(),'Asset Details',@GUID)						
					Set @Log_Status=1
					Return
				END
				
			if exists(select SerialNo from T0040_Asset_details WITH (NOLOCK) where upper(SerialNo) = upper(@SerialNo) and Cmp_id = @Cmp_id)
			Begin
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Asset Serial No already exist',0,'Asset Serial No already exist',GetDate(),'Asset Details',@GUID)						
				Set @Log_Status=1
				Return
			End
				
			Begin
				--insert into T0040_Asset_details (AssetM_ID,Cmp_ID,asset_id,[Description],Type_of_Asset,SerialNo,BRAND_ID,Model,Vendor,[Status],Purchase_date,Warranty_Starts,Warranty_Ends,[Image],Asset_Code,allocation,Asset_Status,Invoice_No,Invoice_Amount)
				--Values(@AssetM_ID,@Cmp_ID,@Asset_CategoryID,@Description,@Type_of_Asset,@SerialNo,@Brand_ID,@Model,@Vendor,@Status,@Purchase_date,@Warranty_Starts,@Warranty_Ends,@Image,@Asset_Code,@allocation,@Asset_Status,@Inv_No,@Inv_amt)
	
				insert into T0040_Asset_details (AssetM_ID,Cmp_ID,asset_id,[Description],Type_of_Asset,SerialNo,BRAND_ID,Model,Vendor,[Status],Purchase_date,Warranty_Starts,Warranty_Ends,[Image],Asset_Code,allocation,Asset_Status,Invoice_No,Invoice_Amount,Attach_Doc,Vendor_Address,Invoice_Date,PONO,pono_Date,city,contact_person,contact_no,Dispose_Date,Vendor_id,BRANCH_id)
				Values(@AssetM_ID,@Cmp_ID,@Asset_CategoryID,@Description,@Type_of_Asset,@SerialNo,@Brand_ID,@Model,'',@Status,@Purchase_date,@Warranty_Starts,@Warranty_Ends,@Image,@Asset_Code,@allocation,@Asset_Status,@Inv_No,@Inv_amt,'','',@Invoice_Date,@PONO,@pono_Date,'','','','01/01/1900',@Vendor_id,@Branch_ID)
				
					set @OldValue = 'New Value' + '#'+ 'Asset Category :' + CONVERT(nvarchar(20),ISNULL( @Asset_CategoryID,''))
					+ '#' + 'Description :' + CONVERT(nvarchar(20),ISNULL( @Description,'')) 
					+ '#' + 'Type Of Asset :' + CONVERT(nvarchar(20),ISNULL( @Type_of_Asset,''))
					+ '#' + 'Serial No. :' + CONVERT(nvarchar(20),ISNULL( @SerialNo,''))
					+ '#' + 'BrandID :' + CONVERT(nvarchar(20),ISNULL( @Brand_ID,0)) 
					+ '#' + 'Model :' + CONVERT(nvarchar(20),ISNULL( @Model,'')) 
					+ '#' + 'Vendor :' + CONVERT(nvarchar(20),ISNULL( @Vendor,'')) 
					+ '#' + 'Status :' + CONVERT(nvarchar(20),ISNULL( @Status,'')) 
					+ '#'  + 'Purchase Date :' + CONVERT(nvarchar(20),ISNULL( @Purchase_date,'')) 
					+ '#' + 'Warranty Starts :' + CONVERT(nvarchar(20),ISNULL( @Warranty_Starts,'')) 
					+ '#' + 'Warranty Ends :' + CONVERT(nvarchar(20),ISNULL( @Warranty_Ends,'') )
					+ '#' + 'Asset Code :' + ISNULL( @Asset_Code,'') 
					+ '#'+ 'Allocation Date :' + CONVERT(nvarchar(20),ISNULL( @Allocation_Date,''))			
					+ '#'+ 'Image :' + ISNULL( @Image,'') + '#' 	
			end	
			
	END		

	exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Asset Details',@OldValue,@AssetM_ID,@User_Id,@IP_Address

RETURN




