

---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0050_HRMS_InitiateAppraisal_Import]
	   @Cmp_ID				numeric(18,0)
      ,@Emp_code			varchar(500)
      ,@SA_Startdate		datetime    
      ,@SA_Enddate			datetime	
      ,@Evaluation_Type    varchar(15) --0 for interim process and 1 for Final
      ,@Duration_FromMonth	int	= 1 
	  ,@Duration_ToMonth	int	= 12 
	  ,@Is_Rm_Required			Char(1)
      ,@HOD_code			varchar(500)	
	  ,@GH_code				varchar(500)
	  ,@Send_To_RM			Char(1)
	  ,@Send_To_PA			Char(1)
	  ,@User_Id numeric(18,0) = 0
      ,@IP_Address varchar(30)= ''
      ,@Row_No int
      ,@Log_Status Int = 0 Output    
      ,@GUID Varchar(2000) = ''
	  ,@Send_directly_Performance_Assessment int
	  ,@SA_Status			int	= null

AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
    
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
	DECLARE @Emp_Superior as INT
	DECLARE @Overall_KPA_Status as INT
	
	set @Emp_id=0
	set @Financial_Year = YEAR(@SA_Startdate)
	set @SendToHOD = 0
	set @HOD_id = 0
	set @GH_id = 0
	set @dept_id=0
	set @Emp_Superior=0
	
	--select  @dept_id=IE.Dept_ID,
	--from T0080_EMP_MASTER em
	--INNER JOIN	
	--(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Cat_ID,I.Dept_ID,I.
	--FROM T0095_INCREMENT I INNER JOIN
	--	(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
	--	 FROM T0095_INCREMENT Inner JOIN
	--		(
	--			SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
	--			FROM T0095_INCREMENT WHERE CMP_ID = @cmp_id GROUP BY EMP_ID
	--		) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
	--	 WHERE CMP_ID = @cmp_id
	--	 GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID
	--where I.Cmp_ID= @cmp_id
	--)IE on ie.Emp_ID = em.Emp_ID
	--where em.cmp_id=@cmp_id  and em.Emp_Left<>'Y' and em.Emp_ID=@emp_id
			
	--if @dept_id=0
	--	BEGIN
			
	--	END
		
	
	if ISNULL(@SA_Startdate,'') = ''
		BEGIN
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_code,'Start Date is required',0,'Start Date is required',GetDate(),'Appraisal Initiation Import',@GUID)						
			Set @Log_Status=1
			return
		end	
			
	if ISNULL(@SA_Enddate,'') = ''
		BEGIN
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_code,'End Date is required',0,'End Date is required',GetDate(),'Appraisal Initiation Import',@GUID)						
			Set @Log_Status=1
			return
		end				
	
	if @Evaluation_Type = ''
		BEGIN
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_code,'Evaluation Type is required',0,'Evaluation Type is required',GetDate(),'Appraisal Initiation Import',@GUID)						
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
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_code,'Required atleast 1 level for appraisal process',0,'Atleast 1 level required',GetDate(),'Appraisal Initiation Import',@GUID)						
			Set @Log_Status=1
			return
		end				
		
	select @Emp_id = emp_id,@is_left=Emp_Left,@Date_Of_Join=Date_Of_Join  from T0080_EMP_MASTER WITH (NOLOCK) where Alpha_Emp_Code = @Emp_code  and Cmp_ID = @cmp_id
	if @Emp_id=0
		begin
			Set @Emp_id = 0
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_code,'Enter proper Employee code',0,'Enter proper Employee code',GetDate(),'Appraisal Initiation Import',@GUID)						
			Set @Log_Status=1
			return
		end	 
	
	if @is_left='Y'
		begin
			Set @Emp_id = 0
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_code,'Employee already left',0,'Employee already left',GetDate(),'Appraisal Initiation Import',@GUID)						
			Set @Log_Status=1
			return
		end	
		PRINT @Emp_id
	if exists(select 1 from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where emp_id=@Emp_id and Cmp_ID=@cmp_id)
	BEGIN
		SELECT @Overall_Status=isnull(A.Overall_Status,0)
		FROM T0050_HRMS_InitiateAppraisal A WITH (NOLOCK) INNER JOIN
				(SELECT max(SA_Startdate) Effective_Date,Emp_Id from T0050_HRMS_InitiateAppraisal WITH (NOLOCK) where Cmp_ID=@cmp_id
				 and SA_Startdate <= @SA_Startdate and emp_id=@Emp_id GROUP by Emp_Id)B on B.emp_id= A.emp_id 
		WHERE a.Cmp_ID=@cmp_id and a.emp_id=@Emp_id
	
		if @Overall_Status <> 5
			begin
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_code,'Previous appraisal process not completed',0,'Appraisal process incomlete',GetDate(),'Appraisal Initiation Import',@GUID)						
				Set @Log_Status=1
				return
			end	
	END	
	
	if EXISTS(SELECT 1 from T0055_Hrms_Initiate_KPASetting WITH (NOLOCK) where emp_id=@Emp_id and Cmp_ID=@cmp_id)
	BEGIN
		SELECT @Overall_KPA_Status=isnull(A.Initiate_Status,0)
		FROM T0055_Hrms_Initiate_KPASetting A WITH (NOLOCK) INNER JOIN
				(SELECT max(KPA_StartDate) Effective_Date,Emp_Id from T0055_Hrms_Initiate_KPASetting WITH (NOLOCK) where Cmp_ID=@cmp_id
				 and KPA_StartDate <= @SA_Startdate and emp_id=@Emp_id GROUP by Emp_Id)B on B.emp_id= A.emp_id 
		WHERE a.Cmp_ID=@cmp_id and a.emp_id=@Emp_id
	
		if @Overall_KPA_Status <> 5
			begin
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_code,'KRA Initiated process not completed',0,'KRA Initiated process incomlete',GetDate(),'Appraisal Initiation Import',@GUID)						
				Set @Log_Status=1
				return
			end	
	END	
	
	SELECT @JoiningDate_Limit=isnull(A.JoiningDate_Limit,0)
	FROM T0050_AppraisalLimit_Setting A WITH (NOLOCK) INNER JOIN
			(SELECT isnull(max(effective_date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) Effective_Date 
			 from T0050_AppraisalLimit_Setting WITH (NOLOCK) where Cmp_ID=@cmp_id
			 and isnull(Effective_Date,(SELECT From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id))<=@SA_Startdate
			 )B on B.effective_date= A.effective_date 
	WHERE a.Cmp_ID=@cmp_id
	
	--select @JoiningDate_Limit,@SA_Startdate,@Date_Of_Join, DATEDIFF(MONTH,@Date_Of_Join,getdate())
	if (DATEDIFF(MONTH,@Date_Of_Join,@SA_Startdate)) < @JoiningDate_Limit
		begin
		--PRINT 'k'
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_code,'Employee not eligible for appraisal process',0,'Employee not eligible for appraisal process',GetDate(),'Appraisal Initiation Import',@GUID)						
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
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@HOD_code,'Enter proper Second Level code',0,'Enter proper Second Level code',GetDate(),'Appraisal Initiation Import',@GUID)						
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
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_code,'Second Level Employee already left',0,'Second Level Employee already left',GetDate(),'Appraisal Initiation Import',@GUID)						
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
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@GH_code,'Enter proper Third Level code',0,'Enter proper Third Level code',GetDate(),'Appraisal Initiation Import',@GUID)						
					Set @Log_Status=1
					return
				end	
				PRINT @is_left
			if @is_left='Y'
				begin
					Set @GH_id = 0
					Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_code,'Third Level Employee already left',0,'Third Level Employee already left',GetDate(),'Appraisal Initiation Import',@GUID)						
					Set @Log_Status=1
					return
				end	
		END 
	
	if @Send_To_RM = 'Y' and @Send_To_PA ='Y'
		BEGIN
			Set @GH_id = 0
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_code,'Send to Reporting Manager & Send Directly to Performance Assessment both step cannot be performed',0,'only one step is required to proceed',GetDate(),'Appraisal Initiation Import',@GUID)						
			Set @Log_Status=1
			return
		END
	
	select @dept_id=ISNULL(Dept_ID,0),@Emp_Superior=ISNULL(Emp_Superior,0) from V0080_EMP_MASTER_INCREMENT_GET where Emp_ID=@Emp_id and Cmp_ID=@cmp_id --and Increment_Effective_Date < =@SA_Startdate
	--select @Superior=ISNULL(Superior,'') from V0050_Initiate_EmpDetail where Emp_id=@Emp_id and Cmp_ID=@cmp_id
	
	if @dept_id = 0
		BEGIN			
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_code,'Department not assigned to employee',0,'Department not assigned to employee',GetDate(),'Appraisal Initiation Import',@GUID)						
			Set @Log_Status=1
			return
		END
	
	if @Emp_Superior = 0 and @Is_Rm_Required='Y'
		BEGIN			
			Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Emp_code,'Reporting Manager not assigned to employee',0,'Reporting Manager not assigned to employee',GetDate(),'Appraisal Initiation Import',@GUID)						
			Set @Log_Status=1
			return
		END
				select @InitiateId = isnull(max(InitiateId),0) + 1 from T0050_HRMS_InitiateAppraisal WITH (NOLOCK)	
				PRINT @InitiateId
				Insert Into T0050_HRMS_InitiateAppraisal 
				(
					 InitiateId
					,Cmp_ID
					,Emp_Id
					,AppraiserId
					,SA_Startdate
					,SA_Enddate
					,SA_EmpComments
					,SA_AppComments
					,SA_Status
					,SA_SendToRM
					,SendToHOD
					,HOD_Id 
					,DirectScore	
					,Final_Evaluation 
					,Financial_Year	
					,Duration_FromMonth	
					,Duration_ToMonth	
					,GH_Id				
					,Rm_Required
					,Send_directly_Performance_Assessment
				)
				VALUES  
				(
					 @InitiateId
					,@Cmp_ID
					,@Emp_Id
					,0
					,@SA_Startdate
					,@SA_Enddate
					,''
					,''
					,@SA_Status
					,0
					,@SendToHOD
					,@HOD_Id 
					,0	
					,@Final_Evaluation 
					,@Financial_Year	
					,@Duration_FromMonth
					,@Duration_ToMonth	
					,@GH_Id			
					,@Rm_Required
					,@Send_directly_Performance_Assessment
				)			
			
		if @Send_To_RM = 'Y'
			BEGIN
				update T0050_HRMS_InitiateAppraisal set SA_Status=4,SA_SendToRM=1
				where Emp_Id=@Emp_Id and InitiateId=@InitiateId
			END
			
		if @Send_To_PA = 'Y'
			BEGIN
				update T0050_HRMS_InitiateAppraisal set SA_Status=1,Overall_Status=NULL
				where Emp_Id=@Emp_Id and InitiateId=@InitiateId
			END	

			--added by mehul 06072021
		if @SA_Status = 1
			BEGIN
				update T0050_HRMS_InitiateAppraisal set Overall_Status=0
				where Emp_Id=@Emp_Id and InitiateId=@InitiateId
			END	
END

