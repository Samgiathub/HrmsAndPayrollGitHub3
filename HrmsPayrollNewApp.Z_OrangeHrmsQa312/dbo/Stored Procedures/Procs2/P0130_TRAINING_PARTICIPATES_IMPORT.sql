
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0130_TRAINING_PARTICIPATES_IMPORT] 
	 @cmp_id				numeric(18, 0)	
	,@Training_App_ID		numeric(18, 0) 
	,@Training_Apr_ID		numeric(18, 0)
	,@Alpha_Emp_Code		varchar(250)
	--,@Actual_Training_code  varchar(250)
	,@Training_code		    varchar(250)
	,@User_Id numeric(18,0) = 0
    ,@IP_Address varchar(30)= ''
    ,@Row_No int
    ,@Log_Status Int = 0 Output    
    ,@GUID Varchar(2000) = ''
AS

	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
	SET ANSI_WARNINGS OFF;

begin	
	
	DECLARE @Tran_emp_Detail_ID AS NUMERIC(18,0)
	declare @Emp_id Numeric(18,0)
	declare @Emp_name varchar(250)
	declare @is_left char(2)
	set @Emp_id=0
	declare @Training_id Numeric(18,0)
	set @Training_id=0
	
	--CREATE table #Import_Data
	--(
	-- Emp_ID  Numeric(18,0),
	-- Training_id Numeric(18,0),
	-- Alpha_Emp_Code varchar(250),
	-- Emp_name varchar(500),
	-- [Status] int 	 
	-- )	
	 
  --if @Training_App_ID = 0
  --set @Training_App_ID = null
  
  --if @Training_Apr_ID = 0
  --set @Training_Apr_ID = null
 
	   select @Emp_id = emp_id,@Emp_name=Emp_Full_Name,@is_left=Emp_Left from T0080_EMP_MASTER WITH (NOLOCK) where Alpha_Emp_Code = @Alpha_Emp_Code  and Cmp_ID = @cmp_id
	   select @Training_id = isnull(Training_id,0),@Training_App_ID=isnull(training_app_id,0),@Training_Apr_ID=isnull(training_apr_id,0) 
	   from T0120_HRMS_TRAINING_APPROVAL WITH (NOLOCK) where REPLACE(Training_Code,' ','') = @Training_Code and Cmp_ID = @cmp_id 
	   	
	   if @Emp_id=0
		begin
			Set @Emp_id = 0
			Insert Into dbo.T0080_Import_Log (Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
			Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Enter proper Employee code',0,'Enter proper Employee code',GetDate(),'Training Participants Import',@GUID)						
			Set @Log_Status=1
			return
		end	
		
		if @is_left='Y'
		begin
			Set @Emp_id = 0
			Insert Into dbo.T0080_Import_Log (Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
			Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Employee already left',0,'Employee already left',GetDate(),'Training Participants Import',@GUID)						
			Set @Log_Status=1
			return
		end	
		
		if @Training_id=0
			begin
				Set @Training_id = 0
				Insert Into dbo.T0080_Import_Log (Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
				Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Enter proper Training code',0,'Enter proper Training code',GetDate(),'Training Participants Import',@GUID)						
				Set @Log_Status=1
				return
			end	 	
		
		if exists(select  Tran_emp_Detail_ID from T0130_HRMS_TRAINING_EMPLOYEE_DETAIL WITH (NOLOCK) where Emp_ID = @Emp_ID and Training_Apr_ID=@Training_Apr_ID and Cmp_ID = @cmp_id)
			begin
				Insert Into dbo.T0080_Import_Log (Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
				Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Already exist Participant for this Training-' + @Training_code,0,'This Participant already exist for this Training',GetDate(),'Training Participants Import',@GUID)						
				Set @Log_Status=1
				return
			end	 	
		
		--if @Actual_Training_code <> @Training_code
		--	begin
		--		Insert Into dbo.T0080_Import_Log (Row_No,Cmp_Id,Emp_Code,Error_Desc,Actual_Value,Suggestion,For_Date,Import_type,KeyGUID)
		--		Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Mismatch Training Code',0,'Enter proper Training code',GetDate(),'Training Participants Import',@GUID)						
		--		Set @Log_Status=1
		--		return
		--	end	 	
		--insert into #Import_Data(Emp_ID,Training_id,Alpha_Emp_Code,Emp_name,[Status]) 
		--VALUES(@Emp_id1,@Training_id,@Alpha_Emp_Code,@Emp_name,@Log_Status)
		--select * from #Import_Data
		
		select @Tran_emp_Detail_ID = Isnull(max(Tran_emp_Detail_ID),0) + 1  From T0130_HRMS_TRAINING_EMPLOYEE_DETAIL  WITH (NOLOCK)
		INSERT INTO T0130_HRMS_TRAINING_EMPLOYEE_DETAIL  
                        (  Tran_emp_Detail_ID
							,Training_App_ID
							,Training_Apr_ID
							,Emp_ID
							,Emp_tran_status
							,cmp_id
							)  
         		VALUES     (
         					@Tran_emp_Detail_ID
							,@Training_App_ID
							,@Training_Apr_ID
							,@Emp_ID
							,1
							,@cmp_id
							)
	END	
RETURN
  
  


