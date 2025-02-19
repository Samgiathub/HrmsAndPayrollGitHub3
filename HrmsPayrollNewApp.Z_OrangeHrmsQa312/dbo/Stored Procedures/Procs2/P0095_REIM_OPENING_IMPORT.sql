


-- =============================================
-- Author:		Ripal Patel
-- Create date: 31 Dec 2013
-- Description:	<Description,,>
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0095_REIM_OPENING_IMPORT]
	  @Reim_Op_ID as numeric output 
	 ,@Emp_Code  as varchar(255)
	 ,@CMP_Id as numeric
	 ,@AD_SORT_NAME as varchar(10)
	 ,@Reim_Opening_Amount as numeric(18,2)
	 ,@for_date  as datetime
	 ,@Log_Status Int = 0 Output  --Added by Jaina 23-02-2017
	 ,@Row_No as Int --Added by Jaina 23-02-2017
	 ,@GUID as Varchar(2000) = '' --Added by Jaina 23-02-2017
	 ,@User_Id as numeric
	 
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @Emp_ID  as numeric(18,0)
	Declare @RC_ID   as numeric(18,0)
	set @Emp_ID = 0
	set @RC_ID = 0
	set @Reim_Op_ID = 0
	
	--Added by Jaina 23-02-2017 Start
	If @Emp_Code = ''
	BEGIN
		Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Employee Code is not Properly Inserted',0,'Enter Proper Employee Code',GetDate(),'Reimbursement Opening Import',@GUID)						
		SET @LOG_STATUS=1			
		RETURN
	END
	
	If @AD_SORT_NAME = ''
	BEGIN
		Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Allowance Short Name is not Properly Inserted',0,'Enter Proper Allowance Short Name',GetDate(),'Reimbursement Opening Import',@GUID)						
		SET @LOG_STATUS=1			
		RETURN
	END
	
	If @for_date = ''
	BEGIN
		Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'For Date is not Properly Inserted',0,'Enter Proper For Date',GetDate(),'Reimbursement Opening Import',@GUID)						
		SET @LOG_STATUS=1			
		RETURN
	END
	
	--If @Reim_Opening_Amount = 0
	--BEGIN
	--	Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,0,'Opening Amount is not Properly Inserted',0,'Enter Proper Opening Amount',GetDate(),'Reimbursement Opening Import',@GUID)						
	--	SET @LOG_STATUS=1			
	--	RETURN
	--END
	--Added by Jaina 23-02-2017 End
	
	--Added by Jaina 15-03-2017
		
	IF NOT EXISTS (select 1 from T0080_EMP_MASTER WITH (NOLOCK) where Alpha_Emp_Code = @Emp_Code and Cmp_ID = @CMP_Id)
	BEGIN
			
			INSERT INTO DBO.T0080_IMPORT_LOG VALUES (@ROW_NO,@CMP_ID,0,'Employee Code Not Exists',0,'Enter Proper Employee Code',GETDATE(),'Reimbursement Opening Import',@GUID)						
			SET @LOG_STATUS=1			
			RETURN
	END
	IF NOT EXISTS (select 1 from T0050_AD_MASTER WITH (NOLOCK) where AD_SORT_NAME = @AD_SORT_NAME and Cmp_ID = @CMP_Id)
	BEGIN
			
			INSERT INTO DBO.T0080_IMPORT_LOG VALUES (@ROW_NO,@CMP_ID,0,'Allowance Name Not Exists',0,'Enter Proper Allowance Name',GETDATE(),'Reimbursement Opening Import',@GUID)						
			SET @LOG_STATUS=1			
			RETURN
	END
	
	if @Emp_Code <> '' and @AD_SORT_NAME <> ''
		Begin
			select @Emp_ID = Emp_ID from T0080_EMP_MASTER WITH (NOLOCK) where Alpha_Emp_Code = @Emp_Code and Cmp_ID = @CMP_Id


			select @RC_ID = AD_ID from T0050_AD_MASTER WITH (NOLOCK) where AD_SORT_NAME = @AD_SORT_NAME and Cmp_ID = @CMP_Id
			
			
			if @Emp_ID <> 0 and @RC_ID <> 0
				Begin
					If NOT Exists(select Emp_ID From Dbo.T0095_Reim_Opening WITH (NOLOCK) Where Emp_ID= @Emp_ID and RC_ID =@RC_ID And For_Date = @For_Date)
						Begin
							
							exec P0095_REIM_OPENING @Reim_Op_ID output,@Emp_ID,@CMP_Id,@RC_ID,@Reim_Opening_Amount,@for_date,'I',@User_Id	
						End
					ELSE
						BEGIN
							exec P0095_REIM_OPENING @Reim_Op_ID output,@Emp_ID,@CMP_Id,@RC_ID,@Reim_Opening_Amount,@for_date,'U',@User_Id
						END
					
				end
		End
	Else
		Begin
			set @Reim_Op_ID = 0
			--Raiserror('Enter Employee Code and AD Sort Name.',16,2)
		End
		
END

