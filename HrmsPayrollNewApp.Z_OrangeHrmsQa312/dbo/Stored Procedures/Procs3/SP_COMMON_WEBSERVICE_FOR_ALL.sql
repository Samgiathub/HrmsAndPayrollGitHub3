

---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_COMMON_WEBSERVICE_FOR_ALL]
/* ===========PLZ DONT DELETE THIS PORTION==================================

AUTHOR		: SHAIKH RAMIZ
CREATE DATE	: 10-MAY-2017
DESCRIPTION	: THIS WEBSERVICE WAS ACTUALLY CREATED FOR TRADEBULLS. THIS SINGLE SP WILL BE USED FOR CALLING MULTIPLE WEBSERVICE.
			  ALL THE PARAMETERS OF ALL SERVICES ARE PASSED HERE ALTOGETHER , WHICHEVER IS REQUIRED WILL BE UTILIZED.
			  
			  ***CMP_ID , ALPHA_EMP_CODE AND WEBSERVICE_TYPE ARE MANDATORY FIELDS***
===========PLZ DONT DELETE THIS PORTION==================================*/
@CMP_ID				NUMERIC,
@ALPHA_EMP_CODE		VARCHAR(20),
@FROM_DATE			DATETIME	= '1900-01-01',
@TO_DATE 			DATETIME	= '1900-01-01',
@LEFT_DATE 			DATETIME	= '1900-01-01',
@REG_ACCEPT_DATE	DATETIME	= '1900-01-01',
@LEFT_REASON		VARCHAR(50) = 'Other',
@IS_TERMINATE		BIT		= 0,
@UNIFORM_RETURN		BIT		= 0,
@EXIT_INTERVIEW		BIT		= 0,
@NOTICE_PERIOD		BIT		= 0,
@IS_DEATH			BIT		= 0,
@NEW_SUP_CODE		VARCHAR(100)= '',
@MANAGER_CMP_NAME	VARCHAR(100) = NULL,
@EFFECT_DATE		DATETIME	= '1900-01-01', 
@IN_TIME			DATETIME = NULL,
@OUT_TIME			DATETIME = NULL,
@IN_DATETIME		DATETIME = NULL,
@OUT_DATETIME		DATETIME = NULL,
@TYPE				VARCHAR(100)= 'Transfer',
@BRANCH				VARCHAR(100)= '',
@DEPARTMENT			VARCHAR(100)= '',
@CATEGORY			VARCHAR(100)= '',
@EMP_MANAGER_CODE	VARCHAR(100)= '',
@VERTICAL			VARCHAR(100)= '',
@SUB_VERTICAL		VARCHAR(100)= '',
@WEBSERVICE_TYPE	VARCHAR(25)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

	DECLARE @EMP_ID AS NUMERIC
	SET @EMP_ID = 0
	
	DECLARE @ENROLL_NO AS NUMERIC
	SET @ENROLL_NO = 0

	SELECT @EMP_ID = ISNULL(EMP_ID,0) , @ENROLL_NO = ENROLL_NO FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE ALPHA_EMP_CODE = @ALPHA_EMP_CODE AND CMP_ID = @CMP_ID AND EMP_LEFT <> 'Y'

	
	IF @EMP_ID = 0 or @WEBSERVICE_TYPE = ''
		BEGIN
			RETURN
		END

IF @WEBSERVICE_TYPE = 'VIEW_ATTENDANCE'
	BEGIN
	/*	***TESTING PROFILER***
		EXEC SP_COMMON_WEBSERVICE_FOR_ALL @CMP_ID = 41 , @ALPHA_EMP_CODE = '08012' , @FROM_DATE = '01-May-2017',@TO_DATE = '08-May-2017', @WEBSERVICE_TYPE = 'ATTENDANCE'
	*/
		EXEC SP_RPT_EMP_IN_OUT_MUSTER_HOME_GET	@CMP_ID			= @CMP_ID,
												@FROM_DATE		= @FROM_DATE,
												@TO_DATE		= @TO_DATE,
												@BRANCH_ID		= 0,
												@CAT_ID			= 0,
												@GRD_ID			= 0,
												@TYPE_ID		= 0,
												@DEPT_ID		= 0,
												@DESIG_ID		= 0,
												@EMP_ID			= @EMP_ID,
												@CONSTRAINT		= '',
												@REPORT_FOR		= 'WEB-SERVICE'
	END
ELSE IF @WEBSERVICE_TYPE = 'LEFT_EMPLOYEE'
	BEGIN
	/*	***TESTING PROFILER***
		EXEC SP_COMMON_WEBSERVICE_FOR_ALL @CMP_ID = 41 , @ALPHA_EMP_CODE = '08012' , @LEFT_DATE = '08-May-2017',@REG_ACCEPT_DATE = '08-May-2017' , @LEFT_REASON = 'Other' , @IS_TERMINATE = 0 , @UNIFORM_RETURN = 0 , @EXIT_INTERVIEW = 0 ,@NOTICE_PERIOD = 0 , @IS_DEATH = 0 , @WEBSERVICE_TYPE = 'ATTENDANCE'
	*/
		DECLARE @LEFT_ID AS NUMERIC
		SET @LEFT_ID = 0
		EXEC P0100_LEFT_EMP_IMPORT	@LEFT_ID = @LEFT_ID OUTPUT,
									@CMP_ID = @CMP_ID,
									@EMP_CODE = @ALPHA_EMP_CODE,
									@LEFT_DATE = @LEFT_DATE,
									@REG_ACCEPT_DATE = @REG_ACCEPT_DATE,
									@LEFT_REASON = @LEFT_REASON,
									@NEW_EMPLOYER = '',
									@IS_TERMINATE = @IS_TERMINATE,
									@TRAN_TYPE = 'I',
									@UNIFORM_RETURN = @UNIFORM_RETURN,
									@EXIT_INTERVIEW = @EXIT_INTERVIEW,
									@NOTICE_PERIOD = @NOTICE_PERIOD,
									@IS_DEATH = @IS_DEATH,
									@RPTMANAGER_CODE = '',
									@GUID = ''
									
		SELECT @LEFT_ID							
	END
ELSE IF @WEBSERVICE_TYPE = 'REPORTING_MANAGER'
	BEGIN
	/*	***TESTING PROFILER***
		EXEC SP_COMMON_WEBSERVICE_FOR_ALL @CMP_ID = 41,@ALPHA_EMP_CODE = '08012',@NEW_SUP_CODE = '0002',@MANAGER_CMP_NAME = '',@EFFECT_DATE = '01-Mar-2017',@WEBSERVICE_TYPE = 'REPORTING_MANAGER'
	*/
		EXEC P0080_UPDATE_REPORTING_MANAGER	@CMP_ID = @CMP_ID,
												@ALPHA_EMP_CODE = @ALPHA_EMP_CODE,
												@CURRENT_SUP_CODE = '',
												@NEW_SUP_CODE = @NEW_SUP_CODE,
												@COMPANY_NAME_OF_NEW_MANAGER = @MANAGER_CMP_NAME,
												@EFFECT_DATE = @EFFECT_DATE,
												@GUID = ''
		
		
	END
ELSE IF @WEBSERVICE_TYPE = 'INSERT_ATTENDANCE'
	BEGIN
	/*	***TESTING PROFILER***
		EXEC SP_COMMON_WEBSERVICE_FOR_ALL @ALPHA_EMP_CODE = '08012',@CMP_ID = 41,@EFFECT_DATE = '11-Aug-2017' , @IN_TIME = '09:00:05' , @OUT_TIME = '18:25:27' , @WEBSERVICE_TYPE = 'INSERT_ATTENDANCE'
	*/
		
		--EXEC P0150_EMP_INOUT_RECORDS_IMPORT	@EMP_CODE = @ALPHA_EMP_CODE,
		--									@CMP_ID = @CMP_ID,
		--									@FOR_DATE = @EFFECT_DATE,
		--									@IN_TIME = @IN_TIME,
		--									@OUT_TIME = @OUT_TIME,
		--									@IN_DATETIME = @IN_DATETIME,
		--									@OUT_DATETIME = @OUT_DATETIME
		
	
		
	DECLARE @IO_TRAN_ID		NUMERIC 
	DECLARE @DURATION		VARCHAR(20)
	DECLARE @DURATION_SEC	NUMERIC 
	
	SELECT @IO_Tran_Id = ISNULL(MAX(IO_TRAN_ID),0) + 1  FROM T0150_EMP_INOUT_RECORD WITH (NOLOCK)
	


	IF ISNULL(@Emp_ID ,0)=0
		BEGIN
			RAISERROR('Employee Code Does not exists.' , 16 ,1)
			RETURN
		END
		
	IF @EFFECT_DATE IS NULL
		BEGIN
			RAISERROR('For Date not Exists' , 16 ,1)
			RETURN
		END
		
	IF @IN_TIME Is NULL AND @OUT_TIME IS NULL
		BEGIN
			RAISERROR('In Time and Out Time Both Does not Exists.' , 16 ,1)
			RETURN
		END  
	
	IF @ENROLL_NO <> 0	--IF ENROLL NUMBER IS PROVIDED , THEN IT WILL TAKE ATTENDANCE FROM BIOMETRIC , NOT FROM WEBSERVICE.
		RETURN
		
	IF ISNULL(@IN_TIME,'')= '' and ISNULL(@OUT_TIME,'')= '' and ISNULL(@OUT_DATETIME,'')= '' and ISNULL(@IN_DATETIME,'')= ''
		RETURN
		
		
--Converting DateTime to Time Only for WebService
 IF @IN_TIME = '1900-01-01 00:00:00.000'
	set @IN_TIME = NULL

 IF @OUT_TIME = '1900-01-01 00:00:00.000'
	set @OUT_TIME = NULL
	

	SET @IN_TIME = CONVERT(varchar(12) , @IN_TIME , 108)
	SET @OUT_TIME = CONVERT(varchar(12) , @OUT_TIME, 108)


	IF ISNULL(@IN_DATETIME,'') = '' 
		BEGIN
		
			if len(@IN_TIME ) < 15  and isnull(@IN_TIME,'') <> '' 
				begin
					SET  @IN_DATETIME  =cast ( cast(@EFFECT_DATE as varchar(11)) + ' ' + cast(cast(datepart(hh,(CAST(@IN_TIME AS SMALLDATETIME))) as varchar(3))  + ':'  + cast(datepart(mi,(CAST(@IN_TIME AS SMALLDATETIME))) as varchar(2))  as datetime) as datetime)
				end
			else if year(@IN_TIME ) <= 1900
				begin
					set @IN_TIME = dbo.F_Return_HHMM(@IN_TIME)
					set  @IN_DATETIME  =cast ( cast(@EFFECT_DATE as varchar(11)) + ' ' + cast(cast(datepart(hh,(CAST(@IN_TIME AS SMALLDATETIME))) as varchar(3))  + ':'  + cast(datepart(mi,(CAST(@IN_TIME AS SMALLDATETIME))) as varchar(2))  as datetime) as datetime)
				end
			else if isdate(@IN_TIME) = 1
				begin
					set @IN_DATETIME = @IN_TIME
				end
		END 

	IF isnull(@OUT_DATETIME,'') ='' 
		BEGIN
			if len(@OUT_TIME ) < 20 and isnull(@OUT_TIME,'') <> '' 
				begin
					set  @OUT_DATETIME  = cast ( cast(@EFFECT_DATE as varchar(11)) + ' ' + cast(cast(datepart(hh,(CAST(@OUT_TIME AS SMALLDATETIME))) as varchar(3))  + ':'  + cast(datepart(mi,(CAST(@OUT_TIME AS SMALLDATETIME))) as varchar(2))  as datetime) as datetime)
				end
			else if year(@OUT_TIME ) <= 1900
				begin
					set @OUT_TIME = dbo.F_Return_HHMM(@OUT_TIME)
					set  @OUT_DATETIME  = cast ( cast(@EFFECT_DATE as varchar(11)) + ' ' + cast(cast(datepart(hh,(CAST(@OUT_TIME AS SMALLDATETIME))) as varchar(3))  + ':'  + cast(datepart(mi,(CAST(@OUT_TIME AS SMALLDATETIME))) as varchar(2))  as datetime) as datetime)
				end		
			else if isdate(@OUT_TIME) = 1
				begin
					set @OUT_DATETIME = @OUT_TIME
				end						
		END
	

	IF isnull(@IN_DATETIME ,'') = '' and isnull(@OUT_DATETIME ,'') = '' 
		begin
			return 
		end
	ELSE if isnull(@IN_DATETIME ,'') <> '' and isnull(@OUT_DATETIME ,'') <> '' 
		begin
			if @IN_DATETIME > @OUT_DATETIME
				set @OUT_DATETIME =dateadd(d,1,@OUT_DATETIME)
		end


	if @Emp_ID > 0
		BEGIN
			--IF EXISTS(SELECT Emp_ID from T0150_EMP_INOUT_RECORD where Emp_ID = @Emp_ID and In_Time = @IN_DATETIME and isnull(@IN_DATETIME,'') <> '' )
			--	BEGIN
			--		RETURN
			--	END
			--ELSE IF EXISTS(SELECT Emp_ID from T0150_EMP_INOUT_RECORD where Emp_ID = @Emp_ID and Out_Time = @OUT_DATETIME and isnull(@OUT_DATETIME,'') <> '' )
			--	BEGIN
			--		RETURN
			--	END		
			--			
			IF EXISTS(SELECT Emp_ID from T0150_EMP_INOUT_RECORD WITH (NOLOCK) where Emp_ID = @Emp_ID and In_Time = @IN_DATETIME and isnull(@IN_DATETIME,'') <> '' )
				BEGIN
					IF EXISTS(SELECT Emp_ID from T0150_EMP_INOUT_RECORD WITH (NOLOCK) where Emp_ID = @Emp_ID and Out_Time = @OUT_DATETIME and isnull(@OUT_DATETIME,'') <> '' )
				       BEGIN
					     RETURN
				       END	
				END
				
			
			IF isnull(@IN_DATETIME ,'') <> '' and isnull(@OUT_DATETIME ,'') <> ''
				BEGIN
					SET @Duration_Sec =isnull(datediff(s,@IN_DATETIME,@OUT_DATETIME),0)
					SET @Duration = dbo.F_Return_Hours(@Duration_Sec)
				END
			
			IF EXISTS ( SELECT Emp_ID from T0150_EMP_INOUT_RECORD WITH (NOLOCK)
						WHERE Emp_ID = @Emp_ID AND For_date = @EFFECT_DATE and In_Time = @IN_DATETIME)
				BEGIN
					UPDATE T0150_EMP_INOUT_RECORD
					SET Out_Time = @OUT_DATETIME , Duration = @Duration
					WHERE  Emp_ID = @Emp_ID AND For_date = @EFFECT_DATE and In_Time = @IN_DATETIME
				END
			ELSE
				BEGIN			
					INSERT INTO T0150_EMP_INOUT_RECORD
						(IO_Tran_Id,Emp_ID,Cmp_ID,For_Date,In_Time,Out_Time,Duration,Reason,Ip_Address,ManualEntryFlag)
					VALUES
						(@IO_Tran_Id,@Emp_ID,@Cmp_ID,@EFFECT_DATE,@IN_DATETIME,@OUT_DATETIME,@Duration,NULL,'WebService','New')
				END
		END		
	END
ELSE IF @WEBSERVICE_TYPE = 'EMPLOYEE_TRANSFER'
	BEGIN
		Declare @Inc_ID as NUMERIC
		SET @Inc_ID = 0
		
		Declare @Log_S as NUMERIC
		SET @Log_S = 0
		
		declare @row_ID as Numeric
		Select @row_ID = MAX(Row_No) + 1 from T0080_IMPORT_LOG WITH (NOLOCK)
		
		EXEC SP_Import_Employee_Transfer	@CMP_ID = @CMP_ID , @EMP_ID = @EMP_ID , @Effective_Date = @EFFECT_DATE , @Type = @TYPE , @Grade = '' , @Branch = @BRANCH ,
											@Designation = '' , @Emp_Type = '' , @Department = @DEPARTMENT , @Category = @CATEGORY , @Emp_Manager_Code = @EMP_MANAGER_CODE ,
											@Business_Segment = '' , @Vertical = @VERTICAL , @Sub_Vertical = @SUB_VERTICAL , @Sub_Branch = '' , @Salary_Cycle = '' , @Increment_Id = @Inc_ID output , 
											@Row_No = @row_ID , @Log_Status = @Log_S output , @Customer_Audit = 0 , @Sales_Code = '' , @Cost_Center = ''
		
		If @Log_S = 1
			BEGIN
				SELECT * FROM T0080_IMPORT_LOG WITH (NOLOCK) WHERE Row_No = @row_ID
				DELETE FROM T0080_IMPORT_LOG WHERE Row_No = @row_ID
			END
			
	END

END
