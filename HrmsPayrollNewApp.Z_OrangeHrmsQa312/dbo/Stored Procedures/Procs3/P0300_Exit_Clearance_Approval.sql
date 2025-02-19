

-- =============================================
-- Author:		<Jaina>
-- Create date: <03-06-2016>
-- Description:	<Exit Clearance Approval>
-- =============================================
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0300_Exit_Clearance_Approval]
	@Approval_Id as numeric(18,0)output,
	@Cmp_id as numeric(18,0),
	@Request_date as Datetime,
	@Approval_date as Datetime,
	@Emp_id as numeric(18,0),
	@Exit_id as  numeric(18,0),
	@Hod_id as numeric(18,0),
	@Noc_status as varchar(1),
	@Remarks as varchar(max),
	@Dept_id as numeric(18,0),
	@Trantype as varchar(1),
	@User_Id numeric(18,0) = 0,
    @IP_Address varchar(30)= '',
    @Updated_By as numeric(18,0),
    @Center_id as numeric(18,0) --Mukti(02082018)
    
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


BEGIN


DECLARE @OldApproval_id As numeric(18,0)
DECLARE @OldRequest_date As Datetime
Declare @OldApproval_date As Datetime
Declare @NewEmp_Name As varchar(100)
Declare @OldEmp_Name As varchar(100)
Declare @OldExit_id As numeric(18,0)
Declare @NewHod_name As varchar(100)
Declare @OldHod_name As varchar(100)
Declare @OldNoc_status As varchar(10)
Declare @OldRemarks As varchar(max)
Declare @OldValue As varchar(max)
Declare @OldUpdated_By as numeric(18,0)

set @OldApproval_date = NULL
set @OldApproval_id = 0
set @OldEmp_Name = ''
set @OldExit_id = 0
set @OldHod_name = ''
set @OldNoc_status = ''
set @OldRemarks = ''
set @OldRequest_date  = NULL
set @OldValue = ''
set @NewEmp_Name = ''
set @NewHod_name = '' 

if @Dept_id=0
	set @Dept_id= NULL
	
if @Center_id=0
	set @Center_id= NULL


CREATE TABLE #EMP_NAME
(
	EMP_ID NUMERIC(18,0),
	EMP_FULL_NAME NVARCHAR(250)
)
	
 IF  UPPER(@TRANTYPE) ='I' 
 BEGIN
	--IF EXISTS (SELECT APPROVAL_ID  FROM T0300_EXIT_CLEARANCE_APPROVAL WHERE EXIT_ID = @EXIT_ID AND CMP_ID = @CMP_ID) 
	--BEGIN
	--		SET @APPROVAL_ID = 0
	--		RETURN 
	--END
	
					
	SELECT @APPROVAL_ID = ISNULL(MAX(APPROVAL_ID),0)+ 1 FROM T0300_EXIT_CLEARANCE_APPROVAL WITH (NOLOCK)

	INSERT INTO T0300_EXIT_CLEARANCE_APPROVAL (APPROVAL_ID,CMP_ID,REQUEST_DATE,APPROVAL_DATE,EMP_ID,EXIT_ID,HOD_ID,NOC_STATUS,REMARKS,Dept_id,Updated_By,Center_id)	
			VALUES (@APPROVAL_ID,@CMP_ID,@REQUEST_DATE,@APPROVAL_DATE,@EMP_ID,@EXIT_ID,@HOD_ID,@NOC_STATUS,@REMARKS,@Dept_id,@Updated_By,@Center_id)
			
				
	INSERT INTO #EMP_NAME(EMP_ID,EMP_FULL_NAME)
		SELECT EMP_ID,ALPHA_EMP_CODE + '-' + EMP_FULL_NAME  FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE EMP_ID IN (@EMP_ID,@HOD_ID)
	
	SELECT @NEWEMP_NAME = EMP_FULL_NAME FROM #EMP_NAME WHERE EMP_ID = @EMP_ID
	SELECT @NEWHOD_NAME = EMP_FULL_NAME FROM  #EMP_NAME WHERE EMP_ID = @HOD_ID	
	
	
	set @OldValue = 'New Value' + '#'+ 'Approval ID :' + cast(ISNULL( @Approval_Id,0)AS varchar(10)) + 
								  '#'+ 'Request Date :' + cast(@Request_date AS varchar(20)) + 
								  '#'+ 'Approval Date :' + cast(@Approval_date AS varchar(20)) + 
								  '#'+ 'Employee Name :' + ISNULL(@NewEmp_Name,'')+ 
								  '#'+ 'Exit ID :' + cast(ISNULL(@Exit_id,0) AS varchar(10))+ 
								  '#'+ 'HOD Name :' + ISNULL(@NewHod_name,'')+
								  '#'+ 'NOC Status :' + ISNULL(@Noc_status,'')+
								  '#'+ 'Remarks :' + ISNULL(@Remarks,'') +
								  '#'+ 'Updated By :'+ CAST(ISNULL(@Updated_By,0) As varchar(10))
			
END

IF UPPER(@TRANTYPE)='U'
BEGIN
	
	SELECT @OLDAPPROVAL_ID = APPROVAL_ID,
		   @OLDREQUEST_DATE = REQUEST_DATE,
		   @OLDAPPROVAL_DATE = APPROVAL_DATE,
		   @OLDEMP_NAME = (SELECT ALPHA_EMP_CODE + '-' + EMP_FULL_NAME  FROM T0080_EMP_MASTER  E WITH (NOLOCK) WHERE E.EMP_ID = EC.EMP_ID ),
		   @OLDEXIT_ID = EXIT_ID,
		   @OLDHOD_NAME = (SELECT ALPHA_EMP_CODE + '-' + EMP_FULL_NAME  FROM T0080_EMP_MASTER  E WITH (NOLOCK) WHERE E.EMP_ID = EC.HOD_ID),
		   @OLDNOC_STATUS = NOC_STATUS,
		   @OLDREMARKS = REMARKS,
		   @OLDUPDATED_BY = UPDATED_BY	
	FROM T0300_EXIT_CLEARANCE_APPROVAL EC WITH (NOLOCK)
	WHERE APPROVAL_ID = @APPROVAL_ID AND HOD_ID=@HOD_ID AND CMP_ID = @CMP_ID
	
	UPDATE T0300_EXIT_CLEARANCE_APPROVAL 
		SET APPROVAL_DATE = @APPROVAL_DATE,
			NOC_STATUS = @NOC_STATUS,
			REMARKS = @REMARKS,
			UPDATED_BY = @UPDATED_BY
	WHERE APPROVAL_ID = @APPROVAL_ID AND HOD_ID=@HOD_ID AND CMP_ID = @CMP_ID
	
					
	INSERT INTO #EMP_NAME(EMP_ID,EMP_FULL_NAME)
		SELECT EMP_ID,ALPHA_EMP_CODE + '-' + EMP_FULL_NAME  FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE EMP_ID IN (@EMP_ID,@HOD_ID)
	
	SELECT @NEWEMP_NAME = EMP_FULL_NAME FROM #EMP_NAME WHERE EMP_ID = @EMP_ID
	SELECT @NEWHOD_NAME = EMP_FULL_NAME FROM  #EMP_NAME WHERE EMP_ID = @HOD_ID	
	
	set @OldValue = 'Old Value' + '#'+ 'Approval ID :' + cast(ISNULL(@OldApproval_id,0)AS varchar(10)) + 
								  '#'+ 'Request Date :' + cast(@OldRequest_date AS varchar(20)) + 
								  '#'+ 'Approval Date :' + cast(@OldApproval_date AS varchar(20)) + 
								  '#'+ 'Employee Name :' + ISNULL(@OldEmp_Name,'')+ 
								  '#'+ 'Exit ID :' + cast(ISNULL(@OldExit_id,0) AS varchar(10))+ 
								  '#'+ 'HOD Name :' + ISNULL(@OldHod_name,'')+
								  '#'+ 'NOC Status :' + ISNULL(@OldNoc_status,'')+
								  '#'+ 'Remarks :' + ISNULL(@OldRemarks,'')+
								  '#'+ 'Updated By :'+ CAST(ISNULL(@OldUpdated_By,0) As varchar(10))+
					'New Value' + '#'+ 'Approval ID :' + cast(ISNULL( @Approval_Id,0)AS varchar(10)) + 
								  '#'+ 'Request Date :' + cast(@Request_date AS varchar(20)) + 
								  '#'+ 'Approval Date :' + cast(@Approval_date AS varchar(20)) + 
								  '#'+ 'Employee Name :' + ISNULL(@NewEmp_Name,'')+ 
								  '#'+ 'Exit ID :' + cast(ISNULL(@Exit_id,0) AS varchar(10))+ 
								  '#'+ 'HOD Name :' + ISNULL(@NewHod_name,'')+
								  '#'+ 'NOC Status :' + ISNULL(@Noc_status,'')+
								  '#'+ 'Remarks :' + ISNULL(@Remarks,'')+
								  '#'+ 'Updated By :'+ CAST(ISNULL(@Updated_By,0) As varchar(10))
End

IF UPPER(@TRANTYPE)='D'
BEGIN
	
	IF exists(SELECT exit_id FROM T0200_Emp_ExitApplication WITH (NOLOCK) WHERE CMP_ID=@CMP_ID AND EXIT_ID = @EXIT_ID AND SUP_ACK='A')
	BEGIN
			
			RAISERROR ('Cannot Delete Application, Noc is approved.', 16, 2) 
			return
	END
				
	SELECT @OLDAPPROVAL_ID = APPROVAL_ID,
		   @OLDREQUEST_DATE = REQUEST_DATE,
		   @OLDAPPROVAL_DATE = APPROVAL_DATE,
		   @OLDEMP_NAME = (SELECT ALPHA_EMP_CODE + '-' + EMP_FULL_NAME  FROM T0080_EMP_MASTER  E WITH (NOLOCK) WHERE E.EMP_ID = EC.EMP_ID ),
		   @OLDEXIT_ID = EXIT_ID,
		   @OLDHOD_NAME = (SELECT ALPHA_EMP_CODE + '-' + EMP_FULL_NAME  FROM T0080_EMP_MASTER  E WITH (NOLOCK) WHERE E.EMP_ID = EC.HOD_ID),
		   @OLDNOC_STATUS = NOC_STATUS,
		   @OLDREMARKS = REMARKS,
		   @OLDUPDATED_BY = UPDATED_BY		
	FROM T0300_EXIT_CLEARANCE_APPROVAL EC WITH (NOLOCK)
	WHERE APPROVAL_ID = @APPROVAL_ID AND HOD_ID=@HOD_ID AND CMP_ID = @CMP_ID

	
	UPDATE T0300_EXIT_CLEARANCE_APPROVAL 
		SET NOC_STATUS = @NOC_STATUS,
			REMARKS = ''
	WHERE APPROVAL_ID = @APPROVAL_ID AND HOD_ID=@HOD_ID AND CMP_ID = @CMP_ID 
	

	DELETE FROM T0350_EXIT_CLEARANCE_APPROVAL_DETAIL WHERE CMP_ID=@CMP_ID AND APPROVAL_ID=@APPROVAL_ID
	
		
	set @OldValue = 'Old Value' + '#'+ 'Approval ID :' + cast(ISNULL(@OldApproval_id,0)AS varchar(10)) + 
								  '#'+ 'Request Date :' + cast(@OldRequest_date AS varchar(20)) + 
								  '#'+ 'Approval Date :' + cast(@OldApproval_date AS varchar(20)) + 
								  '#'+ 'Employee Name :' + ISNULL(@OldEmp_Name,'')+ 
								  '#'+ 'Exit ID :' + cast(ISNULL(@OldExit_id,0) AS varchar(10))+ 
								  '#'+ 'HOD Name :' + ISNULL(@OldHod_name,'')+
								  '#'+ 'NOC Status :' + ISNULL(@OldNoc_status,'')+
								  '#'+ 'Remarks :' + ISNULL(@OldRemarks,'')+
								  '#'+ 'Updated By :'+ CAST(ISNULL(@OldUpdated_By,0) As varchar(10))
					
								  
	
End
EXEC P9999_AUDIT_TRAIL @CMP_ID,@TRANTYPE,'EXIT CLEARANCE APPROVAL',@OLDVALUE,@APPROVAL_ID,@USER_ID,@IP_ADDRESS	

END

