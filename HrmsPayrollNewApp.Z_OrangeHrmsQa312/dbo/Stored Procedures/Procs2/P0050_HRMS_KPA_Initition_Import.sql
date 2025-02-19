---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0050_HRMS_KPA_Initition_Import]
	   @Cmp_ID				numeric(18,0)
      ,@Emp_code			varchar(500)
      ,@KPA_Startdate		datetime    
      ,@KPA_Enddate			datetime	
      ,@Evaluation_Type    varchar(15) --0 for interim process and 1 for Final
      ,@Duration_FromMonth	varchar(15)='January'
	  ,@Duration_ToMonth	varchar(15)='December'
	  ,@Is_Rm_Required			Char(1)
      ,@HOD_code			varchar(500)	
	  ,@GH_code				varchar(500)	 
	  ,@User_Id numeric(18,0) = 0
      ,@IP_Address varchar(30)= ''
      ,@Row_No int
      ,@Log_Status Int = 0 Output    
      ,@GUID Varchar(2000) = ''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
    
	declare @Emp_id Numeric(18,0)
	declare @is_left char(2)
	declare @Overall_Status int
	declare @HOD_id Numeric(18,0)
	declare @GH_id Numeric(18,0)
	declare @Date_Of_Join as DATETIME
	DECLARE @JoiningDate_Limit as INT
	DECLARE @SendToHOD as int
	DECLARE @Financial_Year as varchar(10)
	declare	@InitiateId as INT
	DECLARE @Final_Evaluation as INT
	DECLARE @Rm_Required as INT	
	DECLARE @dept_id as Numeric(18,0)		
	DECLARE @KPA_InitiateId as INT
	DECLARE @Initiate_Status as INT
	DECLARE @Emp_Superior as INT
	
	set @Emp_id=0
	set @Financial_Year = YEAR(@KPA_Startdate)
	set @SendToHOD = 0
	set @HOD_id = 0
	set @GH_id = 0
	set @dept_id=0
	set @Emp_Superior=0
	
	if ISNULL(@KPA_Startdate,'') = ''
		BEGIN
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_code,'Start Date is required',0,'Start Date is required',GetDate(),'KRA Initiation Import',@GUID)						
			Set @Log_Status=1
			return
		end	
			
	if ISNULL(@KPA_Enddate,'') = ''
		BEGIN
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_code,'End Date is required',0,'End Date is required',GetDate(),'KRA Initiation Import',@GUID)						
			Set @Log_Status=1
			return
		end				
	
	if @Evaluation_Type = ''
		BEGIN
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_code,'Evaluation Type is required',0,'Evaluation Type is required',GetDate(),'KRA Initiation Import',@GUID)						
			Set @Log_Status=1
			return
		end			
	ELSE
		BEGIN
			if @Evaluation_Type='Interim'
				set @Final_Evaluation = 0
			ELSE
				set @Final_Evaluation = 1
		END	
		
	if @Is_Rm_Required = 'Y'
		BEGIN
			set @Rm_Required=1
		END
	ELSE
		BEGIN
			set @Rm_Required=0
		END
		
	if @Is_Rm_Required='N' and @HOD_code='' and @GH_code=''
		BEGIN		
			Set @Emp_id = 0
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_code,'Required atleast 1 level for appraisal process',0,'Atleast 1 level required',GetDate(),'KRA Initiation Import',@GUID)						
			Set @Log_Status=1
			return
		end				
		
	select @Emp_id = emp_id,@is_left=Emp_Left,@Date_Of_Join=Date_Of_Join  from T0080_EMP_MASTER WITH (NOLOCK) where Alpha_Emp_Code = @Emp_code  and Cmp_ID = @cmp_id
	if @Emp_id=0
		begin
			Set @Emp_id = 0
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_code,'Enter proper Employee code',0,'Enter proper Employee code',GetDate(),'KRA Initiation Import',@GUID)						
			Set @Log_Status=1
			return
		end	 
	
	if @is_left='Y'
		begin
			Set @Emp_id = 0
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_code,'Employee already left',0,'Employee already left',GetDate(),'KRA Initiation Import',@GUID)						
			Set @Log_Status=1
			return
		end	
		PRINT @Emp_id
	if exists(select 1 from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where emp_id=@Emp_id and Cmp_ID=@cmp_id)
	BEGIN
		SELECT @Overall_Status=isnull(A.Overall_Status,0)
		FROM T0050_HRMS_InitiateAppraisal A WITH (NOLOCK) INNER JOIN
				(SELECT max(SA_Startdate) Effective_Date,Emp_Id from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where Cmp_ID=@cmp_id
				 and SA_Startdate <= @KPA_Startdate and emp_id=@Emp_id GROUP by Emp_Id)B on B.emp_id= A.emp_id 
		WHERE a.Cmp_ID=@cmp_id and a.emp_id=@Emp_id
	
		if @Overall_Status <> 5
			begin
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_code,'Previous appraisal process not completed',0,'Appraisal process incomlete',GetDate(),'KRA Initiation Import',@GUID)						
				Set @Log_Status=1
				return
			end	
	END	
	
	if exists(select 1 from T0055_Hrms_Initiate_KPASetting WITH (NOLOCK) where emp_id=@Emp_id and Cmp_ID=@cmp_id)
	BEGIN
		SELECT @Initiate_Status=isnull(A.Initiate_Status,0)
		FROM T0055_Hrms_Initiate_KPASetting A WITH (NOLOCK) INNER JOIN
				(SELECT max(KPA_StartDate) Effective_Date,Emp_Id from T0055_Hrms_Initiate_KPASetting WITH (NOLOCK) where Cmp_ID=@cmp_id
				 and KPA_StartDate <= @KPA_Startdate and emp_id=@Emp_id GROUP by Emp_Id)B on B.emp_id= A.emp_id 
		WHERE a.Cmp_ID=@cmp_id and a.emp_id=@Emp_id
	
		if @Initiate_Status <> 1
			begin
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_code,'Previous KRA process not completed',0,'KRA process incomlete',GetDate(),'KRA Initiation Import',@GUID)						
				Set @Log_Status=1
				return
			end	
	END	
	
	SELECT @JoiningDate_Limit=isnull(A.JoiningDate_Limit,0)
	FROM T0050_AppraisalLimit_Setting A WITH (NOLOCK) INNER JOIN
			(SELECT isnull(max(effective_date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) Effective_Date 
			 from T0050_AppraisalLimit_Setting WITH (NOLOCK) where Cmp_ID=@cmp_id
			 and isnull(Effective_Date,(SELECT From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id))<=@KPA_Startdate
			 )B on B.effective_date= A.effective_date 
	WHERE a.Cmp_ID=@cmp_id
	
	--select @JoiningDate_Limit,@KPA_Startdate,@Date_Of_Join, DATEDIFF(MONTH,@Date_Of_Join,getdate())
	if (DATEDIFF(MONTH,@Date_Of_Join,@KPA_Startdate)) < @JoiningDate_Limit
		begin
		--PRINT 'k'
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_code,'Employee not eligible for appraisal process',0,'Employee not eligible for appraisal process',GetDate(),'KRA Initiation Import',@GUID)						
			Set @Log_Status=1
			return
		end	
		
	if @HOD_code <> ''
		BEGIN
			select @HOD_id = emp_id,@is_left=Emp_Left  from T0080_EMP_MASTER WITH (NOLOCK) where Alpha_Emp_Code = @HOD_code  and Cmp_ID = @cmp_id
			
			if @HOD_id=0
				begin
					set @SendToHOD = 0
					Set @HOD_id = 0
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@HOD_code,'Enter proper Second Level code',0,'Enter proper Second Level code',GetDate(),'KRA Initiation Import',@GUID)						
					Set @Log_Status=1
					return
				end	 
			ELSE
				BEGIN					
					set @SendToHOD = 1
				END
				
			if @is_left='Y'
				begin
					Set @HOD_id = 0
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_code,'Second Level Employee already left',0,'Second Level Employee already left',GetDate(),'KRA Initiation Import',@GUID)						
					Set @Log_Status=1
					return
				end	
		END

	if @GH_code <> ''
		BEGIN	
			select @GH_id = emp_id,@is_left=Emp_Left  from T0080_EMP_MASTER WITH (NOLOCK) where Alpha_Emp_Code = @GH_code  and Cmp_ID = @cmp_id
			if @GH_id=0
				begin
					Set @GH_id = 0
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@GH_code,'Enter proper Third Level code',0,'Enter proper Third Level code',GetDate(),'KRA Initiation Import',@GUID)						
					Set @Log_Status=1
					return
				end	
				PRINT @is_left
			if @is_left='Y'
				begin
					Set @GH_id = 0
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_code,'Third Level Employee already left',0,'Third Level Employee already left',GetDate(),'KRA Initiation Import',@GUID)						
					Set @Log_Status=1
					return
				end	
		END 
	
	select @dept_id=ISNULL(Dept_ID,0),@Emp_Superior=ISNULL(Emp_Superior,0) from V0080_EMP_MASTER_INCREMENT_GET where Emp_ID=@Emp_id and Cmp_ID=@cmp_id --and Increment_Effective_Date < =@KPA_Startdate
	--select @Superior=ISNULL(Superior,'') from V0095_INCREMENT where Emp_id=@Emp_id and Cmp_ID=@cmp_id
	
	if @dept_id = 0
		BEGIN			
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_code,'Department not assigned to employee',0,'Department not assigned to employee',GetDate(),'KRA Initiation Import',@GUID)						
			Set @Log_Status=1
			return
		END
	
	if @Emp_Superior = 0 and @Is_Rm_Required='Y'
		BEGIN			
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_code,'Reporting Manager not assigned to employee',0,'Reporting Manager not assigned to employee',GetDate(),'KRA Initiation Import',@GUID)						
			Set @Log_Status=1
			return
		END
		
		if @HOD_id =0 
			set @HOD_id=NULL
		if @GH_id= 0
			set @GH_id=NULL
			
				SELECT @KPA_InitiateId = isnull(MAX(KPA_InitiateId),0)+1 FROM T0055_Hrms_Initiate_KPASetting WITH (NOLOCK)
				PRINT @KPA_InitiateId
				INSERT INTO T0055_Hrms_Initiate_KPASetting
			(
				KPA_InitiateId
			   ,Cmp_Id
			   ,Emp_Id
			   ,KPA_StartDate
			   ,KPA_EndDate
			   ,Initiate_Status
			   ,[Year]
			   ,RM_Required
			   ,Hod_Id
			   ,GH_Id
			   ,Emp_ApprovedDate
			   ,Rm_ApprovedDate
			   ,HOD_ApprovedDate
			   ,GH_ApprovedDate
			   ,Emp_Comment
			   ,RM_Comment
			   ,HOD_Comment
			   ,GH_Comment
			   ,Duration_FromMonth
			   ,Duration_ToMonth
			)VALUES
			(
				@KPA_InitiateId
			   ,@Cmp_Id
			   ,@Emp_Id
			   ,@KPA_StartDate
			   ,@KPA_EndDate
			   ,4
			   ,0
			   ,@RM_Required
			   ,@Hod_Id
			   ,@GH_Id
			   ,''
			   ,''
			   ,''
			   ,''
			   ,''
			   ,''
			   ,''
			   ,''
			   ,@Duration_FromMonth
			   ,@Duration_ToMonth
			)		

END

