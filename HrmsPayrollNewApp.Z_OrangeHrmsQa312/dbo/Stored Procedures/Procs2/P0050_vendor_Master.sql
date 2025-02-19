

-- Created By rohit for Vendor master Entry
--Created Date 30122015
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[P0050_vendor_Master]
	 
	  @Vendor_Id numeric(18,0) output
	 ,@Vendor_Name varchar(5000)
	 ,@Cmp_ID numeric(18,0)
	 ,@Vendor_Address varchar(Max)=''
	 ,@Vendor_Contact_No varchar(max)=''
	 ,@Vendor_Company_Website varchar(max)=''
	 ,@Account_Holder_Name varchar(max)=''
	 ,@bank_Name varchar(max)=''
	 ,@Branch_Name varchar(max)=''
	 ,@Account_No varchar(max)=''
	 ,@IIFC_Code varchar(max)=''
	 ,@Remarks varchar(max)=''
	 ,@tran_type char
	 ,@User_Id numeric(18,0) = 0 
     ,@IP_Address varchar(30)= '' 
     ,@VendorCode varchar(100)=''
     
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
SET ANSI_WARNINGS OFF;

declare @OldValue as  varchar(max)
Declare @String as varchar(max)
set @String=''
set @OldValue =''
------
	if Upper(@tran_type) ='I' 
		begin
		
			if exists (Select vendor_id  from t0050_vendor_Master WITH (NOLOCK) Where Upper(Vendor_Name) = Upper(@Vendor_Name) and Cmp_ID = @Cmp_ID) 
				begin
					set @vendor_id=0
					RETURN 
				end
						
					insert into t0050_vendor_Master(Cmp_Id,Vendor_Name,Vendor_Address,Vendor_Contact_No,Vendor_Company_Website,Account_Holder_Name,bank_Name,Branch_Name,Account_No,IIFC_Code,Remarks,Vendor_Code)
					values(@Cmp_Id,@Vendor_Name,@Vendor_Address,@Vendor_Contact_No,@Vendor_Company_Website,@Account_Holder_Name,@bank_Name,@Branch_Name,@Account_No,@IIFC_Code,@Remarks,@VendorCode)
					
					
					Select @vendor_id = vendor_id  from t0050_vendor_Master WITH (NOLOCK) Where Upper(Vendor_Name) = Upper(@Vendor_Name) and Cmp_ID = @Cmp_ID
					
					exec P9999_Audit_get @table = 't0050_vendor_Master' ,@key_column='vendor_id',@key_Values=@vendor_id,@String=@String output
					set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
					--

		end 
	else if upper(@tran_type) ='U' 
		begin
		
		if exists (Select vendor_id  from t0050_vendor_Master WITH (NOLOCK) Where Upper(Vendor_Name) = Upper(@Vendor_Name) and Cmp_ID = @Cmp_ID and  Vendor_id <> @Vendor_Id) 
				begin
					set @Vendor_Id=0
					RETURN 
				end
			   
			   	exec P9999_Audit_get @table='t0050_vendor_Master' ,@key_column='vendor_id',@key_Values=@vendor_id,@String=@String output
				set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
			    
				Update t0050_vendor_Master 
				Set Vendor_Name = @Vendor_Name, Vendor_Address=@Vendor_Address ,Vendor_Contact_No = @Vendor_Contact_No,
				Vendor_Company_Website = @Vendor_Company_Website,Account_Holder_Name = @Account_Holder_Name,bank_Name = @bank_Name,
				Branch_Name = @Branch_Name,Account_No = @Account_No,IIFC_Code = @IIFC_Code,
				Remarks = @Remarks,modify_date=getdate()
				,Vendor_Code=@VendorCode
				where vendor_Id = @Vendor_id
				
				exec P9999_Audit_get @table = 't0050_vendor_Master' ,@key_column='vendor_id',@key_Values=@vendor_id,@String=@String output
					set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))
			   	
			
		end	
	else if upper(@tran_type) ='D'
		begin
			if Exists(select Vendor_ID from T0140_Travel_Vendor_Expense_Request WITH (NOLOCK) where Cmp_ID=@CMP_ID and Vendor_ID=@Vendor_Id)
					begin
						RAISERROR('@@ Reference Exists @@',16,2)
						RETURN	
					end
		
				exec P9999_Audit_get @table='t0050_vendor_Master' ,@key_column='vendor_id',@key_Values=@vendor_id,@String=@String output
				set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
			    
				
			     delete  from t0050_vendor_Master where vendor_id = @Vendor_Id
					
			end
			exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Vendor Master',@OldValue,@Vendor_Id,@User_Id,@IP_Address
		
	RETURN




