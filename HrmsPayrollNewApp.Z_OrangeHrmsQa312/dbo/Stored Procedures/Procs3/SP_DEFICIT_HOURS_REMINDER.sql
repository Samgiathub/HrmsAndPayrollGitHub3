


-- =============================================
-- Author:		SHAIKH RAMIZ
-- Create date: 06/12/2017
-- Description: SEND EMAIL TO THOSE EMPLOYEES WHOSE 8 HOURS ARE NOT COMPLETED
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_DEFICIT_HOURS_REMINDER]
	@CMP_ID				NUMERIC,
	@BEFORE_DAYS		TINYINT,		-- 1 for Previous Day , 2 for before 2 days , likewise. . .
	@MIN_HOURS_REQUIRED	VARCHAR(10) = '08:00',
	@LUNCH_HOURS		VARCHAR(10) = '00:30',	-- 00:30 for 30 Minutes , 
	@CC_EMAIL		VARCHAR(500) = ''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

    
	DECLARE @FOR_DATE DATETIME
	SET @FOR_DATE = CONVERT(DATE , GETDATE() - @BEFORE_DAYS , 103)
	
	DECLARE @LUNCH_SEC NUMERIC
	SET @LUNCH_SEC = dbo.F_Return_Sec(@LUNCH_HOURS)
	
	DECLARE @SHIFT_SEC NUMERIC
	SET @SHIFT_SEC = dbo.F_Return_Sec(@MIN_HOURS_REQUIRED)
	
	iF OBJECT_ID('tempdb..#DATA') IS NULL
	BEGIN
		CREATE TABLE #Data         
		(         
		   Emp_Id   numeric ,         
		   For_date datetime,        
		   Duration_in_sec numeric,        
		   Shift_ID numeric ,        
		   Shift_Type numeric ,        
		   Emp_OT  numeric ,        
		   Emp_OT_min_Limit numeric,        
		   Emp_OT_max_Limit numeric,        
		   P_days  numeric(12,3) default 0,        
		   OT_Sec  numeric default 0  ,
		   In_Time datetime,
		   Shift_Start_Time datetime,
		   OT_Start_Time numeric default 0,
		   Shift_Change tinyint default 0,
		   Flag int default 0,
		   Weekoff_OT_Sec  numeric default 0,
		   Holiday_OT_Sec  numeric default 0,
		   Chk_By_Superior numeric default 0,
		   IO_Tran_Id	   numeric default 0, -- io_tran_id is used for is_cmp_purpose (t0150_emp_inout)
		   OUT_Time datetime,
		   Shift_End_Time datetime,			--Ankit 16112013
		   OT_End_Time numeric default 0,	--Ankit 16112013
		   Working_Hrs_St_Time tinyint default 0, --Hardik 14/02/2014
		   Working_Hrs_End_Time tinyint default 0, --Hardik 14/02/2014
		   GatePass_Deduct_Days numeric(18,2) default 0 -- Add by Gadriwala Muslim 05012014
		)    
	END

	iF OBJECT_ID('tempdb..#Emp_Cons') is null
		BEGIN
			CREATE table #Emp_Cons 
			(      
				Emp_ID numeric ,     
				Branch_ID numeric,
				Increment_ID numeric    
			)  
		END
	
	iF OBJECT_ID('tempdb..#LESS_WORKED_EMPLOYEES') is null
		BEGIN
			CREATE TABLE #LESS_WORKED_EMPLOYEES
			(
				EMP_ID			NUMERIC,
				ALPHA_EMP_CODE	VARCHAR(50),
				EMP_FULL_NAME	VARCHAR(100),
				WORK_EMAIL		VARCHAR(50),
				FOR_DATE		DATETIME,
				IN_TIME			DATETIME,
				OUT_TIME		DATETIME,
				WORKING_HOURS	VARCHAR(20),
				
			)
		END
		
	INSERT INTO #EMP_CONS (EMP_ID,BRANCH_ID,INCREMENT_ID)
	SELECT	E.EMP_ID,I.BRANCH_ID,I.INCREMENT_ID
	FROM	T0080_EMP_MASTER E WITH (NOLOCK)
			INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON E.EMP_ID=I.EMP_ID
			INNER JOIN (SELECT	MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
						  FROM	T0095_INCREMENT I2 WITH (NOLOCK)
								INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
											FROM	T0095_INCREMENT I3 WITH (NOLOCK)
											WHERE	I3.Increment_Effective_Date <= @FOR_DATE
											GROUP BY I3.Emp_ID
											) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
						  GROUP BY I2.Emp_ID
						) I2 ON I.Emp_ID=I2.Emp_ID AND I.Increment_ID=I2.INCREMENT_ID
	WHERE	E.Cmp_ID = @CMP_ID
	
	EXEC P_GET_EMP_INOUT @CMP_ID, @FOR_DATE, @FOR_DATE
	
	INSERT INTO #LESS_WORKED_EMPLOYEES
	SELECT E.EMP_ID , E.ALPHA_EMP_CODE,E.EMP_FULL_NAME, E.WORK_EMAIL , @FOR_DATE as For_date , In_Time , Out_Time , 
	dbo.F_Return_Hours(Duration_in_sec - @LUNCH_SEC) as Working_Hours
	FROM #Data d
	INNER JOIN  T0080_EMP_MASTER E WITH (NOLOCK) ON D.EMP_ID=E.EMP_ID 
	WHERE d.Chk_By_Superior = 0  and (d.Duration_in_sec - @LUNCH_SEC ) < @SHIFT_SEC -- 8 Hours
	
	
	--NOW WE WILL CHECK LEAVE OF THOSE EMPLOYEE WHOSE 8 HOURS ARE NOT COMPLETED
	DELETE FROM #LESS_WORKED_EMPLOYEES
	WHERE 
		EXISTS  ( 
				SELECT EMP_ID 
				FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK)
				WHERE T0140_LEAVE_TRANSACTION.EMP_ID = #LESS_WORKED_EMPLOYEES.EMP_ID 
				AND FOR_DATE = @FOR_DATE
				)

	DECLARE @EMP_CODE AS VARCHAR(100)
	DECLARE @EMPL_NAME AS VARCHAR(100)
	DECLARE @EMPL_EMAIL_ID AS VARCHAR(100) 
	DECLARE @WORKING_HOURS AS VARCHAR(100) 
	DECLARE @INTIME AS DATETIME
	DECLARE @OUTTIME AS DATETIME
	declare @CUR_FOR_DATE as DATETIME
	DECLARE @Body AS VARCHAR(MAX) = ''
	
	DECLARE @PROFILE AS VARCHAR(50)
	SET @PROFILE = ''
	DECLARE @TABLE_TEMPLATE AS  VARCHAR(MAX) = ''
    Declare  @TableHead AS varchar(max)
	DECLARE  @TableTail  AS varchar(max)   
       		  
     	  
	--THIS CURSOR WILL SEND EMAIL TO PARTICULAR EMPLOYEES
	DECLARE CUR_EMPLOYEE CURSOR FOR                    
		SELECT TOP 1 ALPHA_EMP_CODE,	EMP_FULL_NAME,	WORK_EMAIL,	FOR_DATE,	IN_TIME,	OUT_TIME,	WORKING_HOURS
		FROM #LESS_WORKED_EMPLOYEES  ORDER BY EMP_ID
	OPEN CUR_EMPLOYEE                      
		FETCH NEXT FROM CUR_EMPLOYEE INTO @EMP_CODE , @EMPL_NAME , @EMPL_EMAIL_ID , @CUR_FOR_DATE , @INTIME , @OUTTIME , @WORKING_HOURS
		WHILE @@FETCH_STATUS = 0
			BEGIN
			
			
					SET @TableHead = '<html><head>' +
									  '</head>' +
									  '<body>
									  <div>
									  Dear <b>' + @EMPL_NAME + '</b>,<br />
										E-Code :- <b>'+ @EMP_CODE +'</b><br />
									  </div>
									  '
					 SET @Body = '	<p>
										Your Working Hours of  <b>'+ REPLACE(CONVERT(VARCHAR, @FOR_DATE, 106) , ' ' , '-') +'</b> is less than ' + @MIN_HOURS_REQUIRED + ' Hours.
									<p>
									<p>
										Your In-Time was :- <b>'+ REPLACE(REPLACE(CONVERT(varchar(15), CAST(@INTIME AS TIME), 100), 'P', ' P'), 'A', ' A')  +'</b>.
									<p>
									<p>
										Your Out-Time was :- <b>'+ REPLACE(REPLACE(CONVERT(varchar(15), CAST(@OUTTIME AS TIME), 100), 'P', ' P'), 'A', ' A')  +'</b>.
									<p>
									<p>
										Your Total Working Hours was :- <b>'+ @WORKING_HOURS +'</b> Hours. Kindly Regularize.
									<p>
									</body>
									</html>
									'				 
					SELECT  @BODY = @TABLEHEAD + @BODY
	
		
			IF ISNULL(@PROFILE,'') = ''
			  BEGIN
				SELECT @PROFILE = ISNULL(DB_MAIL_PROFILE_NAME,'') FROM T9999_REMINDER_MAIL_PROFILE WITH (NOLOCK) WHERE CMP_ID = ISNULL(@CMP_ID,0)
			  END
			  
			  
				 IF @EMPL_EMAIL_ID <>''
					BEGIN
						--EXEC msdb.dbo.sp_send_dbmail @profile_name = @PROFILE, @recipients = @EMPL_EMAIL_ID, @subject = 'Less Working Reminder', @body = @Body, @body_format = 'HTML' , @copy_recipients = 'ramiz@orangewebtech.com'
						EXEC msdb.dbo.sp_send_dbmail @profile_name = @PROFILE, @recipients = 'ramiz@orangewebtech.com', @subject = 'Less Working Reminder', @body = @Body, @body_format = 'HTML' , @copy_recipients = 'ramiz@orangewebtech.com'
					END
						
						Set @EMPL_EMAIL_ID = ''
		
			
			FETCH NEXT FROM CUR_EMPLOYEE INTO @EMP_CODE , @EMPL_NAME , @EMPL_EMAIL_ID , @FOR_DATE , @INTIME , @OUTTIME , @WORKING_HOURS
			END
	CLOSE CUR_EMPLOYEE                    
	DEALLOCATE CUR_EMPLOYEE
	
	
END

