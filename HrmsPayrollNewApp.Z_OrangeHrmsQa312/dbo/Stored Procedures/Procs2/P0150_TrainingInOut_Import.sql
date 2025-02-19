

---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[P0150_TrainingInOut_Import] 
	@Alpha_Emp_Code	varchar(100)
	,@Training_Code varchar(100)
	,@Cmp_Id    Numeric(18,0)
    ,@Training_date	datetime= NULL
    ,@Out_Time	datetime= NULL
    ,@In_Time	datetime= NULL
    ,@Row_No int
    ,@Log_Status Int = 0 Output
	,@User_Id numeric(18,0) = 0 -- added By Mukti 19082015
    ,@IP_Address varchar(30)= '' -- added By Mukti 19082015
    ,@GUID Varchar(2000) = ''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

--Added By Mukti 19082015(start)
	declare @OldValue as varchar(max)
--Added By Mukti 19082015(end)
	declare @Hours varchar(25)
	set @Hours =''
	declare @Emp_id Numeric(18,0)
	set @Emp_id=0
	DECLARE @Tran_Id Numeric(18,0)
	declare @Training_id Numeric(18,0)
	set @Training_id=0
	declare @Training_Apr_id Numeric(18,0)
	set @Training_Apr_id=0
	declare @Tran_emp_detail_id Numeric(18,0)
	set @Tran_emp_detail_id =0
	declare @is_left char(2)
	
	   select @Emp_id = emp_id,@is_left=Emp_Left  from T0080_EMP_MASTER WITH (NOLOCK) where Alpha_Emp_Code = @Alpha_Emp_Code  and Cmp_ID = @cmp_id
	   select @Training_id = isnull(Training_id,0) from T0120_HRMS_TRAINING_APPROVAL WITH (NOLOCK) where Training_Code = @Training_Code and Cmp_ID = @cmp_id 
	   select @Training_Apr_id=isnull(Training_Apr_id,0) from V0120_HRMS_TRAINING_APPROVAL where Training_Code = @Training_Code and Cmp_ID = @cmp_id and @Training_date >= Training_date and @Training_date <= Training_End_date
	  
	  if @Emp_id=0
		begin
			Set @Emp_id = 0
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Enter proper Employee code',0,'Enter proper Employee code',GetDate(),'Training In Out Import',@GUID)						
			Set @Log_Status=1
			return
		end	 
	  
	  if @is_left='Y'
		begin
			Set @Emp_id = 0
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Employee already left',0,'Employee already left',GetDate(),'Training In Out Import',@GUID)						
			Set @Log_Status=1
			return
		end	
		 
	  if @In_Time is not null and @Out_Time is not null
		begin
			if @In_Time > @Out_Time
			begin
				Set @Training_id = 0
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Enter proper In Time',0,'Enter proper In Time',GetDate(),'Training In Out Import',@GUID)						
				Set @Log_Status=1
				return
			end
			
			set @Hours= dbo.F_Return_Hours (datediff(s,@In_Time,@Out_Time)) 
		End
			 
	   if @Training_id = 0
		begin
			Set @Training_id = 0
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Enter proper Training Code',0,'Enter proper Training Code',GetDate(),'Training In Out Import',@GUID)						
			Set @Log_Status=1
			return
		end 	 
	  	   
	   if @Training_Apr_id > 0
		  begin
			select @Tran_emp_detail_id=isnull(Tran_emp_detail_id,0) from T0130_HRMS_TRAINING_EMPLOYEE_DETAIL WITH (NOLOCK) where Emp_id=@Emp_id and Training_Apr_id=@Training_Apr_id
			
			if @Tran_emp_detail_id = 0
				begin
					Set @Tran_emp_detail_id = 0
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Invalid participate',0,'Invalid participate',GetDate(),'Training In Out Import',@GUID)						
					Set @Log_Status=1
					return
				end
		  end	
		else if @Training_Apr_id = 0
		  begin
			Set @Training_Apr_id = 0
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Invalid Training Date',0,'Invalid Training Date',GetDate(),'Training In Out Import',@GUID)						
			Set @Log_Status=1
			return
		  end

	  if (@Emp_id > 0) and (@Training_id > 0)
		begin
			--exec P0150_EMP_Training_INOUT_RECORD 0,@cmp_id,@Emp_id,@Training_date,@Out_Time1,@In_Time1,'',I
		  Select @Tran_Id= isnull(max(Tran_Id),0) + 1  from dbo.T0150_EMP_Training_INOUT_RECORD WITH (NOLOCK)
		  	  	  
		  insert into T0150_EMP_Training_INOUT_RECORD (Tran_Id,cmp_Id,emp_id,For_date,Out_Time,In_Time,Hours,IP_Address,Training_Apr_Id)   
		  Values(@Tran_Id,@cmp_Id,@emp_id,@Training_date,@Out_Time,@In_Time,@Hours,'',@Training_Apr_id) 
		  
		  	--Added By Mukti 19082015(start)
			    set @OldValue = 'New Value' + '#'+ 'Employee Id:' + cast(Isnull(@emp_id,0) as varchar(25)) + '#' + 
													'Company Id:' + cast(Isnull(@Cmp_Id,0) as varchar(25)) + '#' + 
													'For Date:' + cast(Isnull(@Training_date,'') as varchar(30)) + '#' + 
													'In Time:' + cast(Isnull(@In_Time,'') as varchar(25)) + '#' + 
													'Out Time:' + cast(Isnull(@Out_Time,'') as varchar(25)) + '#' + 
													'Hours:' + cast(Isnull(@Hours,'') as varchar(25)) + '#' + 
													'Training Apr id:' + cast(Isnull(@Training_Apr_id,0) as varchar(25)) 
			--Added By Mukti 19082015(end)
		end
	exec P9999_Audit_Trail @Cmp_ID,'I','Training In-Out Import',@OldValue,@Tran_Id,@User_Id,@IP_Address
RETURN




