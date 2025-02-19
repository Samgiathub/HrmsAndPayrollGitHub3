  
  
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0130_Asset_Approval_Det]  
 @Asset_Approval_ID numeric  
 ,@Cmp_ID numeric  
 ,@Asset_ID numeric  
 ,@Brand_Id numeric  
 ,@Model_Name varchar(50)  
 ,@Serial_No varchar(50)  
 ,@Purchase_date datetime  
 ,@LoginId numeric  
 ,@AssetM_ID numeric  
 ,@Asset_Code varchar(50)   
 ,@Tran_type CHAR(1)  
 ,@IP_Address varchar(30)= ''  
 ,@Return_date datetime  
 ,@Asset_Status varchar(2)  
 ,@Allocation_date datetime  
 ,@App_Type numeric  
 ,@apr_id numeric  
 ,@Status char(1)  
 ,@Installment_date datetime  
 ,@Installment_Amount numeric(18,2)  
 ,@Issue_Amount numeric(18,2)  
 ,@Sal_Tran_Id numeric  
 ,@Deduction_type varchar(15)= ''  
 
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
 declare @Asset_ApprDet_ID numeric  
 declare @Asset_Application_ID numeric    
 declare @Emp_ID numeric  
 declare @Asset_Tran_ID numeric  
 declare @Asset_Closing as numeric(18,2)  
 declare @Asset_Closing1 as numeric(18,2)  
 declare @Emp_ID2 as numeric  
 declare @Branch_ID1 as numeric  
 declare @Dept_ID1 as numeric  
 declare @Receiver_ID1 as numeric  
 declare @Applied_by1 as numeric  
 declare @Asset_Approval_Date1 as datetime  
 declare @Comments1 as varchar(max)  
 declare @Asset_Approval_ID1 as numeric  
 declare @Transfer_ID as numeric  
   
-- Add By Mukti 11072016(start)  
 declare @OldValue as  varchar(max)  
 Declare @String_val as varchar(max)  
 set @String_val=''  
 set @OldValue =''  
-- Add By Mukti 11072016(end)  
      
 --declare @applType numeric  
 if @apr_id=0  
	set @apr_id=null  
 if @AssetM_ID=0  
	set @AssetM_ID=null  
 if @Sal_Tran_Id=0  
	set @Sal_Tran_Id=null  
 --if @Brand_Id=0  
 -- set @Brand_Id=null  
   
	IF @Tran_type = 'I'  
	BEGIN  
		select @Asset_ApprDet_ID = isnull(max(Asset_ApprDet_ID),0) + 1  from T0130_Asset_Approval_Det WITH (NOLOCK)  
       
		IF @Asset_Status = ''  
		 BEGIN  
			set @Asset_Status='W'  
		END  
      
		declare @tmpalloc_date as datetime  
		 IF exists(select 1 from T0130_Asset_Approval_Det where allocation_date <@Return_date and asset_code=@asset_code and Asset_ApprDet_ID > @Asset_ApprDet_ID)  
		BEGIN  
			select @tmpalloc_date=allocation_date from T0130_Asset_Approval_Det where allocation_date <@Return_date and Asset_ApprDet_ID > @Asset_ApprDet_ID  
			--set @Asset_ApprDet_ID =0   
			set @Return_date=@tmpalloc_date  
			RETURN  
		END  
  
		insert into T0130_Asset_Approval_Det
		(Asset_ApprDet_ID,Asset_Approval_ID,Cmp_ID,Asset_ID,Brand_Id,Model_Name,Serial_No,Purchase_date,LoginId,System_date,AssetM_ID,Asset_Code,Asset_status,Return_date,Application_Type,
		Allocation_date,Return_asset_approval_id,Approval_status,Installment_date,Installment_Amount,Issue_Amount,Sal_Tran_Id,Deduction_type)  
		values(@Asset_ApprDet_ID,@Asset_Approval_ID,@Cmp_ID,@Asset_ID,@Brand_Id,@Model_Name,@Serial_No,@Purchase_date,@LoginId,GETDATE(),@AssetM_ID,@Asset_Code,@Asset_Status,@Return_date,
		@App_Type,@Allocation_date,@apr_id,@status,@Installment_date,@Installment_Amount,@Issue_Amount,@Sal_Tran_Id,@Deduction_type)  
		 
		IF @Installment_Amount > 0 and @Issue_Amount > 0  
		BEGIN  
			select @Emp_ID = Emp_ID  from T0120_Asset_Approval WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Asset_Approval_ID=@Asset_Approval_ID  
     
			select @Asset_Tran_ID = isnull(max(Asset_Tran_ID),0) + 1  from T0140_Asset_Transaction WITH (NOLOCK)  
      
			insert into T0140_Asset_Transaction(Asset_Tran_ID,Asset_Approval_ID,Cmp_ID,Emp_Id,AssetM_ID,Asset_Opening,Issue_Amount,Receive_Amount,Asset_Closing,For_Date)  
			values(@Asset_Tran_ID,@Asset_Approval_ID,@Cmp_ID,@Emp_ID,@AssetM_ID,0,@Issue_Amount,0,@Issue_Amount,@Installment_date)  
		END  
     
		 IF @Asset_Code <> '' and @Status <> 'R'  
		 BEGIN  
			IF @App_Type=1   
			BEGIN  
				update T0040_Asset_Details  
				set allocation=0,Asset_Status=@Asset_Status  
				where Cmp_ID=@Cmp_ID and AssetM_ID=@AssetM_ID   
			END  
		ELSE  
		BEGIN  
			update T0040_Asset_Details  
			set allocation=1,Asset_Status=@Asset_Status  
			where Cmp_ID=@Cmp_ID and AssetM_ID=@AssetM_ID  
		END  
		END  
      
		select @Asset_Application_ID = Asset_Application_ID  from T0120_Asset_Approval WITH (NOLOCK) where Asset_Approval_ID=@Asset_Approval_ID  
          
		update T0110_Asset_Application_Details  
		set [status]=@Status,AssetM_ID=@AssetM_ID  
		where Asset_Application_ID=@Asset_Application_ID and Cmp_ID=@Cmp_ID and Asset_ID=@Asset_ID  
     
		-- Add By Mukti 11072016(start)  
		 exec P9999_Audit_get @table = 'T0130_Asset_Approval_Det' ,@key_column='Asset_ApprDet_ID',@key_Values=@Asset_ApprDet_ID,@String=@String_val output  
		 set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))    
		-- Add By Mukti 11072016(end)      
     
 END    
ELSE IF @Tran_type = 'U'  
 BEGIN
	
	IF @Asset_Status = ''  
    BEGIN  
		set @Asset_Status='W'  
    END  
     
	IF exists(select * from T0130_Asset_Approval_Det WITH (NOLOCK) where cmp_id=@cmp_id and Asset_Approval_ID=@Asset_Approval_ID and AssetM_ID=@AssetM_ID)   
	BEGIN
		-- Add By Mukti 11072016(start)  
		exec P9999_Audit_get @table='T0130_Asset_Approval_Det' ,@key_column='Asset_Approval_ID',@key_Values=@Asset_Approval_ID,@String=@String_val output  
		set @OldValue = @OldValue + 'old Value' + '#' + cast(@String_val as varchar(max))  
		-- Add By Mukti 11072016(end)  
	
		update  T0130_Asset_Approval_Det  
		set Cmp_ID=@Cmp_ID,  
		AssetM_ID=@AssetM_ID,  
		Asset_ID=@Asset_ID,  
		Brand_Id=@Brand_Id,  
		Model_Name=@Model_Name,  
		Serial_No=@Serial_No,  
		Purchase_date=@Purchase_date,  
		System_date=GETDATE(),  
		LoginId=@LoginId,  
		Asset_Code=@Asset_Code,  
		Allocation_Date=@Allocation_Date,  
		--application_type=@App_Type,  
		Return_date=@Return_date,  
		 asset_status=@asset_status,  
		Approval_status=@status,  
		Installment_date=@Installment_date,  
		Installment_Amount=@Installment_Amount,  
		Issue_Amount=@Issue_Amount,  
		Sal_Tran_Id=@Sal_Tran_Id,  
		Deduction_type=@Deduction_type  
		where cmp_id=@cmp_id and Asset_Approval_ID=@Asset_Approval_ID and AssetM_ID=@AssetM_ID  
		   
		-- Add By Mukti 11072016(start)  
		 exec P9999_Audit_get @table = 'T0130_Asset_Approval_Det' ,@key_column='Asset_Approval_ID',@key_Values=@Asset_Approval_ID,@String=@String_val output  
		 set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))  
		-- Add By Mukti 11072016(end)    
     END  
    ELSE  
     BEGIN  
		select @Asset_ApprDet_ID = isnull(max(Asset_ApprDet_ID),0) + 1  from T0130_Asset_Approval_Det WITH (NOLOCK)  
		insert into T0130_Asset_Approval_Det(Asset_ApprDet_ID,Asset_Approval_ID,Cmp_ID,Asset_ID,Brand_Id,Model_Name,Serial_No,Purchase_date,LoginId,System_date,AssetM_ID,Asset_Code,Asset_status,Return_date,Application_Type,Allocation_date,Return_asset_approval_id,Approval_status,Installment_date,Installment_Amount,Issue_Amount,Sal_Tran_Id,Deduction_type)  
		values(@Asset_ApprDet_ID,@Asset_Approval_ID,@Cmp_ID,@Asset_ID,@Brand_Id,@Model_Name,@Serial_No,@Purchase_date,@LoginId,GETDATE(),@AssetM_ID,@Asset_Code,@Asset_Status,@Return_date,@App_Type,@Allocation_date,@apr_id,@status,@Installment_date,@Installment_Amount,@Issue_Amount,@Sal_Tran_Id,@Deduction_type)  
       
		-- Add By Mukti 11072016(start)  
		 exec P9999_Audit_get @table = 'T0130_Asset_Approval_Det' ,@key_column='Asset_ApprDet_ID',@key_Values=@Asset_ApprDet_ID,@String=@String_val output  
		 set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))    
		-- Add By Mukti 11072016(end)      
     END  

     declare @emp_id1 as numeric(18,0)  
     declare @Receive_amount as numeric(18,2)  
      
    IF @Installment_Amount > 0 and @Issue_Amount > 0  
    BEGIN  
      
		select @emp_id1=emp_id from T0140_Asset_Transaction WITH (NOLOCK) where cmp_id=@cmp_id and Asset_Approval_ID=@Asset_Approval_ID and AssetM_ID=@AssetM_ID  
		  
		SELECT @Receive_amount = ISNULL(SUM(Receive_amount),0) from dbo.t0140_Asset_transaction  AT WITH (NOLOCK) INNER JOIN         
		(SELECT MAX(FOR_DATE) AS FOR_dATE , AssetM_ID ,EMP_ID from dbo.t0140_Asset_transaction  WITH (NOLOCK) WHERE  CMP_ID = @CMP_ID        
		AND FOR_DATE <= getdate() and AssetM_Id = @AssetM_Id and Emp_Id=@emp_id1  
		GROUP BY EMP_id ,AssetM_ID ) AS QRY  ON QRY.AssetM_ID  = AT.AssetM_ID        
		AND QRY.FOR_DATE = AT.FOR_DATE         
		AND QRY.EMP_ID = AT.EMP_ID and AT.Emp_ID=@emp_id1 and AT.assetM_Id=@AssetM_ID   
		and isnull(sal_tran_id,0)>0  
		IF @Receive_amount = 0  
		BEGIN  
			delete from T0140_Asset_Transaction where emp_id=@emp_id1 and cmp_id=@cmp_id and sal_tran_id is null  
			select @Emp_ID = Emp_ID  from T0120_Asset_Approval WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Asset_Approval_ID=@Asset_Approval_ID  
          
			select @Asset_Tran_ID = isnull(max(Asset_Tran_ID),0) + 1  from T0140_Asset_Transaction WITH (NOLOCK)  
			insert into T0140_Asset_Transaction(Asset_Tran_ID,Asset_Approval_ID,Cmp_ID,Emp_Id,AssetM_ID,Asset_Opening,Issue_Amount,Receive_Amount,Asset_Closing,For_Date)  
			values(@Asset_Tran_ID,@Asset_Approval_ID,@Cmp_ID,@Emp_ID,@AssetM_ID,0,@Issue_Amount,0,@Issue_Amount,@Installment_date)  
          
		END  
    END  
      
    IF @Asset_Code <> '' and @Status <> 'R'  
    BEGIN  
		IF @App_Type=1 --for return  
		BEGIN  
			update T0040_Asset_Details  
			set allocation=0,Asset_Status=@Asset_Status  
			where Cmp_ID=@Cmp_ID and AssetM_ID=@AssetM_ID  
		END  
     else  
      begin  
        update T0040_Asset_Details  
        set allocation=1,Asset_Status=@Asset_Status  
        where Cmp_ID=@Cmp_ID and AssetM_ID=@AssetM_ID  
      end  
    END  
      
    select @Asset_Application_ID = Asset_Application_ID  from T0120_Asset_Approval WITH (NOLOCK) where Asset_Approval_ID=@Asset_Approval_ID  
      
    update T0110_Asset_Application_Details  
    set [status]=@Status,AssetM_ID=@AssetM_ID  
    where Asset_Application_ID=@Asset_Application_ID and Cmp_ID=@Cmp_ID and Asset_ID=@Asset_ID  
  END    
  
	exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Asset Approval Details',@OldValue,@Asset_ApprDet_ID,@LoginId,@IP_Address  
  
RETURN  
  
  
  
  