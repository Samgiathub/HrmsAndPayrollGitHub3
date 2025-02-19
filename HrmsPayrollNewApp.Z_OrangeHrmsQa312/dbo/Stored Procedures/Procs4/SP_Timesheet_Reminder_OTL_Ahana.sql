--EXEC [SP_Timesheet_Reminder_OTL] 120,'ronak.k@orangewebtech.com'

CREATE PROCEDURE [dbo].[SP_Timesheet_Reminder_OTL_Ahana]

@CMP_ID NUMERIC(18,0) = 0,
@CC_EMAIL NVARCHAR(MAX) = ''

AS

DECLARE @PROFILE_CMP_ID AS INT
SET @PROFILE_CMP_ID=0

	DECLARE @DATE AS VARCHAR(MAX) = ''	
	IF @DATE = ''
	 SET @DATE = GETDATE()

     IF OBJECT_ID('TEMPDB..#TBL_EMP_DATA') IS NOT NULL 
         BEGIN
               DROP TABLE #TBL_EMP_DATA
         END
         
	SELECT EMP_FULL_NAME,WORK_EMAIL,BRANCH_NAME,Desig_Name,
			CONVERT(VARCHAR(7), CASE WHEN ISNULL(ACTUAL_DATE_OF_BIRTH,'') = '' THEN  DATE_OF_BIRTH ELSE ACTUAL_DATE_OF_BIRTH END , 6)AS DATE_OF_BIRTH1
	INTO #TBL_EMP_DATA
	FROM T0080_EMP_MASTER EM 
	INNER JOIN T0095_INCREMENT I ON EM.INCREMENT_ID = I.INCREMENT_ID 
	LEFT JOIN T0030_BRANCH_MASTER BM ON I.BRANCH_ID = BM.BRANCH_ID 
	LEFT JOIN T0040_DESIGNATION_MASTER DSM ON I.DESIG_ID = DSM.DESIG_ID 
	WHERE 
		1 = (CASE WHEN ACTUAL_DATE_OF_BIRTH IS NOT NULL AND MONTH(ACTUAL_DATE_OF_BIRTH)= MONTH(@DATE) AND DAY(ACTUAL_DATE_OF_BIRTH) = DAY(@DATE) AND ACTUAL_DATE_OF_BIRTH <> '1900-01-01 00:00:00.000'
				  THEN 1 
				  WHEN  DATE_OF_BIRTH IS NOT NULL AND MONTH(DATE_OF_BIRTH)=MONTH(@DATE) AND DAY(DATE_OF_BIRTH) = DAY(@DATE) AND ACTUAL_DATE_OF_BIRTH IS NULL AND DATE_OF_BIRTH <> '1900-01-01 00:00:00.000'
				  THEN 1 
				  ELSE 0 
			  END
			 )
	AND 
	(ISNULL(EMP_LEFT,'N') <> 'Y' OR EM.EMP_LEFT_DATE IS NULL) 	
   AND EM.CMP_ID =@CMP_ID
   --and Em.emp_id = 24530

   
DECLARE @EMP_NAME AS VARCHAR(200)	
DECLARE @WORK_EMAIL AS VARCHAR(200)
DECLARE @BRANCH_NAME AS VARCHAR(200)
DECLARE @DESIG_NAME AS VARCHAR(200)

DECLARE CUR_EMPLOYEE CURSOR FOR     
	SELECT EMP_FULL_NAME,WORK_EMAIL,Branch_Name,Desig_Name FROM #TBL_EMP_DATA ORDER BY EMP_FULL_NAME
	
	OPEN CUR_EMPLOYEE                      
	FETCH NEXT FROM CUR_EMPLOYEE INTO @EMP_NAME,@WORK_EMAIL,@BRANCH_NAME,@DESIG_NAME
	WHILE @@FETCH_STATUS = 0                    
		BEGIN
			

		      DECLARE  @TABLEHEAD VARCHAR(MAX),
					   @TABLETAIL VARCHAR(MAX)   
           		  SET @TABLEHEAD = '
					<!DOCTYPE html>       
					<html>       
					<head>       
					<style>
					a:link, a:visited {
						background-color: white;
						color: black;
						border: 2px solid green;
						padding: 10px 20px;
						text-align: center;
						text-decoration: none;
						display: inline-block;
					}
					a:hover, a:active {
						background-color: green;
						color: white;
					}
					</style>
					<title>Page Title</title>       
					</head>       
					<body>   
					<div style="width: 680px;padding: 10px;border: 5px solid gray;margin: 0">
					<h3 style="color:red;margin: 0;">TIMESHEET REMINDER !!!</h3>       
					<h3 >  </h3>   
					<h3 >Dear '+ isnull(@Emp_Name,'') + ' ,</h1>	
					<h3 >  </h3>                
					<p style="margin: 0;">If you have Missed to fill your Timesheet for this week,Kindly Fill It Using Our HRMS Employee Portal.</p> 
					<h3 >  </h3>                
					<h3 style="margin: 0;"> <a href="https://hrms.ahana.co.in/" target="_blank">Click Here</a> </h3> 
					<h3 >  </h3>                
					<h3 style="color:red;margin: 0;">NOTE :- If you have already filled your Timesheet, Kindly ignore this email.</h3> 
					<h3 >  </h3>                
					<p>May you have a Wonderful Day Ahead.</p>       
					<h3 >  </h3>                
					<p style="color:#000000;margin: 0;">Regards</p>       <p style="color:#000000;margin: 0;">HR Team</p>
					</div>'
					SET @TABLETAIL = '</BODY></HTML>';        
					          	
                  DECLARE @BODY AS VARCHAR(MAX)
                  SELECT  @BODY = @TABLEHEAD + ISNULL(@BODY,'') + @TABLETAIL  
           		  
           		
           		  DECLARE @SUBJECT AS VARCHAR(100)           
           		  SET @SUBJECT = 'TIMESHEET REMINDER FROM OTL'
			
				    DECLARE @PROFILE AS VARCHAR(50)
       					  SET @PROFILE = ''
						  SELECT @PROFILE = ISNULL(DB_MAIL_PROFILE_NAME,'') FROM T9999_REMINDER_MAIL_PROFILE WHERE CMP_ID = @PROFILE_CMP_ID
						  --SELECT @PROFILE = ISNULL(DB_MAIL_PROFILE_NAME,'') FROM T9999_REMINDER_MAIL_PROFILE WHERE  DB_Mail_Profile_Id = 11
       					  
			  IF ISNULL(@PROFILE,'') = ''
			   IF ISNULL(@PROFILE,'') = ''
			  BEGIN
				SELECT @PROFILE = ISNULL(DB_MAIL_PROFILE_NAME,'') FROM T9999_REMINDER_MAIL_PROFILE WHERE  CMP_ID = @CMP_ID --DB_Mail_Profile_Id = 11 -- AND
			  END
			
			  IF ISNULL(@PROFILE,'') <> ''
			  BEGIN
				 EXEC MSDB.DBO.SP_SEND_DBMAIL @PROFILE_NAME = @PROFILE, @RECIPIENTS = @WORK_EMAIL, @SUBJECT = @SUBJECT, @BODY = @BODY, @BODY_FORMAT = 'HTML',@COPY_RECIPIENTS = @CC_EMAIL
			  END
				 

			SET @EMP_NAME = ''
			SET @WORK_EMAIL = ''
			SET @BRANCH_NAME = ''
			SET @DESIG_NAME = ''
			SET @BODY =''
			SET @TABLEHEAD =''
			SET @TABLETAIL= ''
			SET @SUBJECT= ''

		 FETCH NEXT FROM CUR_EMPLOYEE INTO @EMP_NAME,@WORK_EMAIL,@BRANCH_NAME,@DESIG_NAME
	   END                    
	CLOSE CUR_EMPLOYEE                    
	DEALLOCATE CUR_EMPLOYEE    
	
	