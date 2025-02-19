


-- =============================================
-- Author:		<Jaina>
-- Create date: <02-06-2016>
-- Description:	<Exit Clearance Department Wise>
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0095_Exit_Clearance]
	@TRAN_ID NUMERIC(9)
	,@CMP_ID   NUMERIC(9)  
	,@DEPT_ID  NUMERIC(9)  
	,@Center_Id NUMERIC(9)
	,@EFFECTIVE_DATE DATETIME	
	,@EMP_ID NUMERIC(9)
	,@Branch_Id  numeric(9)
	,@TRANSTYPE  VARCHAR(1) 
	,@User_Id numeric(18,0) = 0
    ,@IP_Address varchar(30)= '' 
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	Declare @DEPARTMENT_NAME varchar(250)
	Declare @EMPLOYEE_NAME varchar(250)
	DECLARE @OLDEFFECTIVE_DATE DATETIME
	DECLARE @OLDVALUE AS VARCHAR(MAX)
	DECLARE @Center_Name varchar(250)
	DECLARE @Branch_Name varchar(250)
	
	set @DEPARTMENT_NAME = ''
	SET @EMPLOYEE_NAME = ''
	set @Branch_Name = ''
	SET @OLDEFFECTIVE_DATE = NULL
	SET @OLDVALUE = ''
	
	IF @DEPT_ID=0
		SET @DEPT_ID=NULL
	IF @Center_Id=0
		SET @Center_Id=NULL
	if @Branch_Id =0
		set @Branch_Id=NULL

	DECLARE @ExitCostCenterWise as INT
			set @ExitCostCenterWise= 0
	Select @ExitCostCenterWise = Isnull(Setting_Value,0) From T0040_SETTING WITH (NOLOCK) Where Cmp_ID = @Cmp_Id and Setting_Name ='Enable Exit Clearance Process Cost Center Wise'   				
				
	IF @TRANSTYPE  = 'I'
	BEGIN
		 --Added by Jaina 06-08-2019
		if @ExitCostCenterWise=0 and @DEPT_ID IS NULL
		BEGIN
			RAISERROR ('Please select Department', 16, 2) 			
			RETURN 
		END
		
		if @ExitCostCenterWise=1 and @Center_Id IS NULL
		BEGIN
			RAISERROR ('Please select Cost center', 16, 2) 
			RETURN 
		END
				
	
		SELECT @TRAN_ID = ISNULL(MAX(TRAN_ID),0) + 1 FROM T0095_EXIT_CLEARANCE WITH (NOLOCK)
		
		INSERT INTO T0095_EXIT_CLEARANCE (TRAN_ID,CMP_ID,EMP_ID,DEPT_ID,EFFECTIVE_DATE,Center_Id,branch_id) 
		VALUES (@TRAN_ID,@CMP_ID,@EMP_ID,@DEPT_ID,@EFFECTIVE_DATE,@Center_Id,@Branch_Id)
		
		SELECT @DEPARTMENT_NAME = DEPT_NAME FROM T0040_DEPARTMENT_MASTER WITH (NOLOCK) WHERE DEPT_ID = @DEPT_ID
		SELECT @Center_Name = Center_Name FROM T0040_COST_CENTER_MASTER WITH (NOLOCK) WHERE Center_ID = @Center_Id
		Select @Branch_Name = Branch_Name from T0030_BRANCH_MASTER WITH (NOLOCK) WHERE Branch_ID = @Branch_Id
		SELECT @EMPLOYEE_NAME = ALPHA_EMP_CODE + '-' + EMP_FULL_NAME FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE EMP_ID = @EMP_ID
		
		SET @OLDVALUE = 'NEW VALUE' + '#'+ 'DEPARTMENT :' + ISNULL( @DEPARTMENT_NAME,'') + 
								  '#'+ 'EMPLOYEE :' + ISNULL(@EMPLOYEE_NAME,'') + 
								  '#'+ 'EFFECTIVE DATE :' + CAST(@EFFECTIVE_DATE AS VARCHAR(20))+
								  '#'+ 'COST CENTER NAME :' + ISNULL(@Center_Name,'')+
								  '#'+ 'BRANCH NAME :' + ISNULL(@Branch_Name,'')
	END
	ELSE IF @TRANSTYPE  = 'D'
	BEGIN
		

		if @ExitCostCenterWise=1
			BEGIN
				IF EXISTS (SELECT 1 FROM T0095_Exit_Clearance E WITH (NOLOCK) INNER JOIN T0300_Exit_Clearance_Approval EA WITH (NOLOCK) ON E.Emp_id = EA.Hod_ID WHERE E.Tran_id = @Tran_id and ISNULL(EA.Center_ID,0) >0)
				BEGIN
					RAISERROR ('Cannot Delete as Reference Exists', 16, 2) 
					RETURN 
				END
			END
		else	
			BEGIN		
				IF EXISTS (SELECT 1 FROM T0095_Exit_Clearance E WITH (NOLOCK) INNER JOIN T0300_Exit_Clearance_Approval EA WITH (NOLOCK) ON E.Emp_id = EA.Hod_ID WHERE E.Tran_id = @Tran_id and ISNULL(EA.Dept_id,0) >0)
				BEGIN
					RAISERROR ('Cannot Delete as Reference Exists', 16, 2) 
					RETURN 
				END
			END
		
		SELECT @DEPARTMENT_NAME = (SELECT DEPT_NAME FROM T0040_DEPARTMENT_MASTER D WITH (NOLOCK) WHERE D.DEPT_ID = E.DEPT_ID),
			   @EMPLOYEE_NAME = (SELECT ALPHA_EMP_CODE + '-' + EMP_FULL_NAME FROM T0080_EMP_MASTER EM WITH (NOLOCK) WHERE EM.EMP_ID = E.EMP_ID),
			   @OLDEFFECTIVE_DATE = E.EFFECTIVE_DATE,
			   @Center_Name = (SELECT Center_Name FROM T0040_COST_CENTER_MASTER C WITH (NOLOCK) WHERE C.Center_ID = E.Center_ID),
			   @Branch_Name = (Select Branch_Name from T0030_BRANCH_MASTER WITH (NOLOCK) WHERE Branch_ID = @Branch_Id)
		FROM T0095_EXIT_CLEARANCE E WITH (NOLOCK) WHERE TRAN_ID = @TRAN_ID AND CMP_ID = @CMP_ID
	
		DELETE FROM T0095_EXIT_CLEARANCE WHERE TRAN_ID = @TRAN_ID AND CMP_ID = @CMP_ID
		
		SET @OLDVALUE = 'OLD VALUE' + '#'+ 'DEPARTMENT :' + ISNULL( @DEPARTMENT_NAME,'') + 
								  '#'+ 'EMPLOYEE :' + ISNULL(@EMPLOYEE_NAME,'') + 
								  '#'+ 'EFFECTIVE DATE :' + CAST(@OLDEFFECTIVE_DATE AS VARCHAR(20))+
								  '#'+ 'COST CENTER NAME :' + ISNULL(@Center_Name,'') +
								  '#'+ 'BRANCH NAME :' + ISNULL(@Branch_Name,'')
	
	END
	
	EXEC P9999_AUDIT_TRAIL @CMP_ID,@TRANSTYPE,'EXIT CLEARANCE',@OLDVALUE,@TRAN_ID,@USER_ID,@IP_ADDRESS	
	
END


