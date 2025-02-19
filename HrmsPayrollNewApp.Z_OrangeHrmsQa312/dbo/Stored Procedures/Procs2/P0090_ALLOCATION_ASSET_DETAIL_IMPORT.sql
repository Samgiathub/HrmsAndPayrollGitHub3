CREATE PROCEDURE [dbo].[P0090_ALLOCATION_ASSET_DETAIL_IMPORT]	
	  @Asset_Approval_ID numeric(18) output
	 ,@Cmp_ID numeric
	 ,@Asset_Code	varchar(100)
     ,@Asset_Category	varchar(100) 
	 ,@Type	varchar(10)
	 ,@Allocation_for varchar(10)
	 ,@Alpha_Emp_Code varchar(100)
	 ,@Branch_Name varchar(100)
	 ,@Allocation_Date datetime
	 ,@Return_Date datetime
	 ,@Asset_Status varchar(10) 
     ,@Tran_Type varchar(1)	 
	 ,@User_Id numeric
	 ,@Dept_Name varchar(100)
	 ,@IP_Address varchar(50)= ''
	 ,@Log_Status Int = 0 Output
	 ,@Row_No int
	 ,@installment_date datetime
	 ,@Recover_amt numeric(18,2)
	 ,@installment_amt numeric(18,2)
	 ,@Branch_For_Dept varchar(200)
	 ,@GUID			   Varchar(2000) = '' --Added by nilesh patel on 16062016
	 ,@Comments		varchar(Max)=''
 AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	declare @OldValue as  varchar(max)
	DECLARE @Emp_id numeric
	declare @Branch_For_Dept_ID as int
	set @Emp_id=0
 
 
 declare @apr_id numeric
 SET @apr_id =0	
 
 		If @Asset_Code = ''
				BEGIN
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Asset Code is not Properly Inserted',0,'Enter Proper Asset Code',GetDate(),'Admin Asset Approval',@GUID)						
					Set @Log_Status=1
					Return
				END
		If @Asset_Category = ''
				BEGIN
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Asset Category is not Properly Inserted',0,'Enter Proper Asset Category',GetDate(),'Admin Asset Approval',@GUID)						
					Set @Log_Status=1
					Return
				END
				
		if @Allocation_for=''
				BEGIN
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Asset Allocation for is not Properly Inserted',0,'Enter Proper Allocation_For',GetDate(),'Admin Asset Approval',@GUID)						
					Set @Log_Status=1
					Return
				END
		if @Allocation_for='Employee' and @Alpha_Emp_Code=''
				BEGIN
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Asset Allocation for Alpha_Emp_Code is not Properly Inserted',0,'Enter Proper Alpha_Emp_Code',GetDate(),'Admin Asset Approval',@GUID)						
					Set @Log_Status=1
					Return
				END
		if @Allocation_for='Branch' and @Branch_Name=''
				BEGIN
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Asset Allocation for Branch_Name  is not Properly Inserted',0,'Enter Proper Branch_Name',GetDate(),'Admin Asset Approval',@GUID)						
					Set @Log_Status=1
					Return
				END
		if @Allocation_for='Department' and @Dept_Name=''
				BEGIN
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Asset Allocation for Department is not Properly Inserted',0,'Enter Proper Department Name',GetDate(),'Admin Asset Approval',@GUID)						
					Set @Log_Status=1
					Return
				END
		IF @Allocation_for='Department' and @Branch_For_Dept=''
				BEGIN
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Required Branch for Department for department allocation',0,'Enter Proper Branch for Department',GetDate(),'Admin Asset Approval',@GUID)						
					Set @Log_Status=1
					Return
				END
		ELSE
			BEGIN
				select @Branch_For_Dept_ID = Branch_ID  from T0030_branch_master where Branch_Name= @Branch_For_Dept  and Cmp_ID = @cmp_id
			END
			
		if @Asset_Status=''
				BEGIN
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Asset Asset_Status is not Properly Inserted',0,'Enter Proper Asset_Status',GetDate(),'Admin Asset Approval',@GUID)						
					Set @Log_Status=1
					Return
				END
				
		if @Type=''
				BEGIN
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Asset Type is not Properly Inserted',0,'Enter Proper Asset Type',GetDate(),'Admin Asset Approval',@GUID)						
					Set @Log_Status=1
					Return
				END
		else if @Type='Allocation'
				begin
				DECLARE @LAST_RETURN_DATE AS DATETIME

					if @Allocation_Date=''
						begin 
							Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Allocation Date of asset is not Properly Inserted',0,'Allocation Date of asset is not Properly Inserted',GetDate(),'Admin Asset Approval',@GUID)						
							Set @Log_Status=1
							Return
						end

						SELECT @LAST_RETURN_DATE =RETURN_DATE FROM T0130_Asset_Approval_Det WHERE Asset_Code=@Asset_Code ORDER BY RETURN_DATE DESC
						IF @LAST_RETURN_DATE > @Allocation_Date
						begin 
							Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Allocation Date is less than Return Date',0,'Allocation Date of asset is not Properly Inserted',GetDate(),'Admin Asset Approval',@GUID)						
							Set @Log_Status=1
							Return
						end

						if NOT(YEAR(@installment_date)='1900')
							BEGIN							
								if @Allocation_Date > @installment_date --and @Recover_amt > 0
								begin 
									Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Installment Date must be greater than Asset Allocation Date.',0,'Installment Date must be greater than Asset Allocation Date.',GetDate(),'Admin Asset Approval',@GUID)						
									Set @Log_Status=1
									Return
								end
							END
							
						if @Asset_Status='Damage'
						begin 
							Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Damage Asset cannot be allocated.',0,'Damage Asset cannot be allocated.',GetDate(),'Admin Asset Approval',@GUID)						
							Set @Log_Status=1
							Return
						end
						
				end
		else if @Type='Return'
				begin
					if @Return_Date=''
						begin 
							Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Return_Date of Asset is not Properly Inserted',0,'Return_Date of Asset is not Properly Inserted',GetDate(),'Admin Asset Approval',@GUID)						
							Set @Log_Status=1
							Return
						end
					if @Allocation_Date > @Return_Date
						begin 
							Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Allocation Date cannot be greater than Return_Date',0,'Allocation Date cannot be greater than Return_Date',GetDate(),'Admin Asset Approval',@GUID)						
							Set @Log_Status=1
							Return
						end
				end
					
declare @Asset_ApprDet_ID numeric	
DECLARE @Branch_ID numeric
DECLARE @Dept_Id numeric
Declare @Asset_ID numeric
Declare @AssetM_ID numeric 
declare @status varchar(5)
declare @Brand_Id numeric
declare @Model_Name varchar(50)
declare @Serial_No varchar(50)
declare @Purchase_date Date
declare @asset_Type numeric
declare @Return_Date1 Date
declare @Asset_Tran_ID numeric
DECLARE @application_type INT

SET @AssetM_ID =0
SET @Brand_Id =0

	select @Asset_ID = Asset_ID from T0040_Asset_Master WITH (NOLOCK) where Asset_Name=@Asset_Category and Cmp_ID=@Cmp_ID 
	
if @Dept_Name <> '' and @Allocation_for='Department'
	begin
		select @Dept_Id = Dept_Id from T0040_Department_Master WITH (NOLOCK) where Dept_Name= @Dept_Name  and Cmp_ID = @cmp_id
		set @Emp_id=0
		set @Branch_ID=0
	end
else if @Branch_Name <> '' and @Allocation_for='Branch'
	begin
		select @Branch_ID = Branch_ID  from T0030_branch_master WITH (NOLOCK) where Branch_Name= @Branch_Name  and Cmp_ID = @cmp_id
		set @Emp_id=0
		set @Dept_Id=0
	end
else
	begin
		select @Emp_id = emp_id  from T0080_EMP_MASTER WITH (NOLOCK) where Alpha_Emp_Code = @Alpha_Emp_Code  and Cmp_ID = @cmp_id
		
		if @Emp_id =0
			begin
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Employee does not exist',0,'Employee does not exist',GetDate(),'Admin Asset Approval',@GUID)						
				Set @Log_Status=1
				Return	
			end
			
		if 	@Type<>'Return'
			begin
				if @Emp_id >0
					begin
						if exists(select * from t0120_Asset_approval ap WITH (NOLOCK) inner join 
					      T0130_Asset_Approval_Det apd WITH (NOLOCK) on ap.Asset_Approval_ID=apd.Asset_Approval_ID and ap.cmp_id=apd.cmp_id 
						  where ap.emp_id=@emp_id and apd.allocation_date=@allocation_date and Asset_ID=@Asset_ID and Asset_Code=@Asset_Code)
							begin
								Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Asset already allocated for this Employee in same date',0,'Asset already allocated for this Employee in same date',GetDate(),'Admin Asset Approval',@GUID)						
								Set @Log_Status=1
								Return	
							end
					end
				end
		set @Branch_ID=0
		set @Dept_Id=0
	end

	if 	@Type<>'Return'
	begin
		if exists(select * from t0040_Asset_details WITH (NOLOCK) where Asset_Code=@Asset_Code and Asset_ID=@Asset_ID and Cmp_ID=@Cmp_ID and allocation=1)
			begin
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Asset already allocated.',0,'Asset already allocated.',GetDate(),'Admin Asset Approval',@GUID)						
				Set @Log_Status=1
				Return
			end
	end
	
	if @Type<>'Return'
	begin
		if exists(select * from t0040_Asset_details WITH (NOLOCK) where Asset_Code=@Asset_Code and Asset_ID=@Asset_ID and Cmp_ID=@Cmp_ID and Asset_Status='D')
			begin
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Damage Asset cannot be allocated.',0,'Damage Asset cannot be allocated.',GetDate(),'Admin Asset Approval',@GUID)						
				Set @Log_Status=1
				Return
			end
	end
	
	if @Type = 'Return'
		set @application_type=1
	ELSE	
		set @application_type=0
		
	select @AssetM_ID = AssetM_ID,@Brand_Id=Brand_Id,@Model_Name=Model,@Serial_No=SerialNo,@Purchase_date=Purchase_date from t0040_Asset_details WITH (NOLOCK) where Asset_Code=@Asset_Code and Asset_ID=@Asset_ID and Cmp_ID=@Cmp_ID 
		
	if @AssetM_ID = 0
		begin
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Not any Asset details available for this Asset Category.',0,'Not any Asset details available for this Asset Category.',GetDate(),'Admin Asset Approval',@GUID)						
			Set @Log_Status=1
			Return
		end
		
	if @Brand_Id = 0
		begin
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Not any Brand available for this Asset Category.',0,'Not any Brand available for this Asset Category.',GetDate(),'Admin Asset Approval',@GUID)						
			Set @Log_Status=1
			Return
		end

IF @Tran_Type ='I'
	BEGIN 
				if @Asset_Status='Working'
					begin
						set @status='W'
					end
				else if @Asset_Status='Damage'
					begin
						set @status='D'
					end
					
				if 	@Branch_ID > 0 or @Emp_id > 0  or @Dept_Id > 0 
					begin	
						select @Return_Date1=MAX(Return_Date) from T0130_Asset_Approval_Det WITH (NOLOCK) where Asset_Code=@Asset_Code and Application_Type=1 and Cmp_Id=@Cmp_Id
						--if  convert(varchar(10),@Allocation_Date,105) < convert(varchar(10),@Return_Date1,105)
					if 	@Type <> 'Return'
						begin
							if @Allocation_Date < @Return_Date1
								begin
									Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Enter Proper Allocation Date',0,'Enter Proper Allocation Date',GetDate(),'Admin Asset Approval',@GUID)						
									Set @Log_Status=1
									Return
							end	
						end
						
						if 	@Type='Return'
							begin
								set @asset_Type=1
								if @Branch_Name <> ''
									begin
										select @apr_id=ap.Asset_Approval_ID,@Allocation_Date=apd.Allocation_Date from T0120_Asset_Approval ap WITH (NOLOCK)
										inner join  T0130_Asset_Approval_Det apd WITH (NOLOCK) on ap.Asset_Approval_ID=apd.Asset_Approval_ID and ap.cmp_id=apd.cmp_id
										inner join t0040_asset_details ad WITH (NOLOCK) on ad.assetm_id=apd.assetm_id and ad.cmp_id=apd.cmp_id
										where ad.asset_code=@asset_code  and ap.Branch_ID=@Branch_ID and apd.Application_Type=0
										--and apd.Allocation_date=@Allocation_date
									end
								else if @Dept_Name <> ''
									begin
										select @apr_id=ap.Asset_Approval_ID,@Allocation_Date=apd.Allocation_Date from T0120_Asset_Approval ap WITH (NOLOCK)
										inner join  T0130_Asset_Approval_Det apd WITH (NOLOCK) on ap.Asset_Approval_ID=apd.Asset_Approval_ID and ap.cmp_id=apd.cmp_id
										inner join t0040_asset_details ad WITH (NOLOCK) on ad.assetm_id=apd.assetm_id and ad.cmp_id=apd.cmp_id
										where ad.asset_code=@asset_code  and ap.Dept_ID=@Dept_ID and apd.Application_Type=0
										--and apd.Allocation_date=@Allocation_date
									end
								else
									begin
										--print @Asset_Approval_ID
										--print @Allocation_date
										--print @asset_code
										--print @Emp_ID
											select @apr_id=ap.Asset_Approval_ID,@Allocation_Date=apd.Allocation_Date from T0120_Asset_Approval ap WITH (NOLOCK)
											inner join  T0130_Asset_Approval_Det apd WITH (NOLOCK) on ap.Asset_Approval_ID=apd.Asset_Approval_ID and ap.cmp_id=apd.cmp_id
											inner join t0040_asset_details ad WITH (NOLOCK) on ad.assetm_id=apd.assetm_id and ad.cmp_id=apd.cmp_id
											where ad.asset_code=@asset_code  and ap.Emp_ID=@Emp_ID and apd.Application_Type=0
											--and apd.Allocation_date=@Allocation_date
											
											--select @apr_id=MAX(ap.Asset_Approval_ID) from T0120_Asset_Approval ap
											--inner join  T0130_Asset_Approval_Det apd on ap.Asset_Approval_ID=apd.Asset_Approval_ID and ap.cmp_id=apd.cmp_id
											--where apd.asset_code=@asset_code  and ap.Emp_ID=@Emp_ID and apd.Application_Type=0
										--print @apr_id
										end
							end
						else
							begin
								set @asset_Type=0
								set @apr_id	=null	
								set @Return_date='01/01/1900'
							end
					
						if @apr_id=0 and @Type='Return'
							begin
								Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Not any allocation details available',0,'Not any allocation details available',GetDate(),'Admin Asset Approval',@GUID)						
								Set @Log_Status=1
								Return
							end
							
						if 	@apr_id >0 and 	@Type='Return'
							begin
								if exists(select 1 from T0130_Asset_Approval_Det WITH (NOLOCK) where Allocation_date=@Allocation_date and return_asset_approval_id=@apr_id and AssetM_ID=@AssetM_ID and application_type=1)
								begin
									Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Asset already returned.',0,'Asset already returned.',GetDate(),'Admin Asset Approval',@GUID)						
									Set @Log_Status=1
									Return
								end
							end
									
						select @Asset_Approval_ID = isnull(max(Asset_Approval_ID),0) + 1  from T0120_Asset_Approval WITH (NOLOCK)
							begin
								insert into T0120_Asset_Approval(Asset_Approval_ID,Asset_Application_ID,Cmp_ID,Emp_ID,Branch_ID,Receiver_ID,Comments,[Status],LoginId,System_date,asset_approval_date,Allocation_Date,Applied_by,Dept_Id,Transfer_Emp_Id,Transfer_Branch_Id,Transfer_Dept_Id,Application_Type,Branch_For_Dept)
								values(@Asset_Approval_ID,0,@Cmp_ID,@Emp_ID,@Branch_ID,0,@Comments,'A',@User_Id,GETDATE(),Getdate(),'01/01/1900',0,@Dept_Id,null,null,null,@application_type,@Branch_For_Dept_ID)
							end
							
							
						select @Asset_ApprDet_ID = isnull(max(Asset_ApprDet_ID),0) + 1  from T0130_Asset_Approval_Det WITH (NOLOCK)
											
						insert into T0130_Asset_Approval_Det(Asset_ApprDet_ID,Asset_Approval_ID,Cmp_ID,Asset_ID,Brand_Id,Model_Name,Serial_No,Purchase_date,LoginId,System_date,AssetM_ID,Asset_Code,Asset_status,Return_date,Application_Type,Allocation_date,Return_asset_approval_id,Approval_status,Installment_date,Installment_Amount,Issue_Amount,Sal_Tran_Id)
						values(@Asset_ApprDet_ID,@Asset_Approval_ID,@Cmp_ID,@Asset_ID,@Brand_Id,@Model_Name,@Serial_No,@Purchase_date,@User_Id,GETDATE(),@AssetM_ID,@Asset_Code,@status,@Return_date,@asset_Type,@Allocation_date,@apr_id,'A',@installment_date,@installment_amt,@Recover_amt,null)
					
						if @asset_Type=1
							begin
								update T0040_Asset_Details
								set allocation=0,Asset_Status=@status
								where Cmp_ID=@Cmp_ID and AssetM_ID=@AssetM_ID
							end
						else
							begin
									update T0040_Asset_Details
									set allocation=1,Asset_Status=@status
									where Cmp_ID=@Cmp_ID and AssetM_ID=@AssetM_ID
							end
												
						if @Recover_amt > 0 and @Type='Allocation'
							begin
								select @Emp_ID = Emp_ID  from T0120_Asset_Approval WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Asset_Approval_ID=@Asset_Approval_ID
						
								select @Asset_Tran_ID = isnull(max(Asset_Tran_ID),0) + 1  from T0140_Asset_Transaction WITH (NOLOCK)
							
								insert into T0140_Asset_Transaction(Asset_Tran_ID,Asset_Approval_ID,Cmp_ID,Emp_Id,AssetM_ID,Asset_Opening,Issue_Amount,Receive_Amount,Asset_Closing,For_Date)
								values(@Asset_Tran_ID,@Asset_Approval_ID,@Cmp_ID,@Emp_ID,@AssetM_ID,0,@Recover_amt,0,@Recover_amt,@installment_date)
							end
				
					--set @OldValue = 'New Value' 
					--+ '#' + 'Emp Id :' + CONVERT(nvarchar(20),ISNULL( @Emp_ID,0))
					--+ '#' + 'Branch Id :' + CONVERT(nvarchar(20),ISNULL( @Branch_ID,0))
					--+ '#' + 'Department Id :' + CONVERT(nvarchar(20),ISNULL( @Dept_Id,0))
					--+ '#' + 'Status :' + CONVERT(nvarchar(20),ISNULL( @Status,''))
					--+ '#' + 'Asset Approval Date :' + Getdate() + '#' 
					
					--exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Home Import Data for Asset Allocation',@OldValue,@Asset_Approval_ID,@User_Id,@IP_Address
			end
		END
		
RETURN




