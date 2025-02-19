
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_Recruitment_Request_Approval_Reminder]
	@cmp_id_Pass NUMERIC(18,0) = 0,
	@CC_Email NVARCHAR(max) = ''
AS 
BEGIN 

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	DECLARE @Esclation_Date DATETIME   
	DECLARE @Approval_day AS NUMERIC    
	DECLARE @ReminderTemplate AS NVARCHAR(4000)
	DECLARE @Emp_ID AS INT
	DECLARE @Rec_App_Date VARCHAR(20)
	DECLARE @Cmp_ID as INT
	DECLARE @Max_Level INT
	DECLARE @Rec_Req_ID AS INT
	DECLARE @Sup_Alpha_Emp_Code VARCHAR(50)
	DECLARE @TRAN_ID INT
	DECLARE @Sup_id INT
	DECLARE @Max_Rpt_Level INT
	DECLARE @final_Approval	INT
	DECLARE @Approval_Date DATETIME
	DECLARE @email_format AS VARCHAR(MAX)
	DECLARE @Manager_Email_ID as VARCHAR(MAX)	
	Declare @HREmail_ID	nvarchar(4000)
	Declare @HR_Name as varchar(255)
	DECLARE @DATE_OF_RESIGNATION AS VARCHAR(50)
	DECLARE @LAST_WORKING_DATE AS VARCHAR(50)
	DECLARE @REASON_FOR_RESIGNATION AS VARCHAR(MAX)
	DECLARE @EMP_NAME AS VARCHAR(500)
	DECLARE @DEPARTMENT AS VARCHAR(500)
	DECLARE @HTML_TABLE VARCHAR(MAX)
	DECLARE @Approval_status VARCHAR(15)
	DECLARE @Emp_Full_Name varchar(Max)	
	DECLARE @STATUS VARCHAR(150)
	DECLARE @Sup_Email_Alpha_Emp_Code VARCHAR(150)
	Declare @To_Manager AS Tinyint
	Declare @To_Hr As Tinyint
	Declare @To_Account As Tinyint
	Declare @Other_Email As Varchar(max)
	Declare @Is_Manager_CC As Tinyint
	Declare @Is_HR_CC As Tinyint
	Declare @Is_Account_CC  As Tinyint
	DECLARE @HR_EMAIL VARCHAR(MAX)
	DECLARE @ACC_EMAIL VARCHAR(MAX)
	DECLARE @O_EMAIL VARCHAR(MAX)
	DECLARE @TO_EMAIL_DETAIL VARCHAR(MAX)
	DECLARE @CC_EMAIL_DETAIL VARCHAR(MAX)
	DECLARE @Branch_Name VARCHAR(500)
	DECLARE @Desig_Name	VARCHAR(500)
	DECLARE @Job_Title VARCHAR(500)	
	
	IF @cmp_id_Pass = 0
		SET @cmp_id_Pass = null
             
    IF OBJECT_ID('tempdb..#Temp') IS NOT NULL 
        BEGIN
            DROP TABLE #Temp
        END       
   
     CREATE TABLE #Scheme_Table
    (
		Emp_id		NUMERIC		DEFAULT 0,
		Rpt_Mgr_1	Varchar(500) DEFAULT NUll,
		Rpt_Mgr_2	Varchar(200) DEFAULT NUll,
		Rpt_Mgr_3	Varchar(200) DEFAULT NUll,
		Rpt_Mgr_4	Varchar(200) DEFAULT NUll,
		Rpt_Mgr_5	Varchar(200) DEFAULT NUll,
		Max_Level	int	
    )   
		
    DECLARE @From_date	DATETIME 
	SET @From_date = GETDATE()
	
	SELECT DISTINCT HR.Cmp_ID,HR.S_Emp_ID,es.Scheme_ID,sm.Scheme_Name,sm.Scheme_Type,HR.System_Date as Rec_App_Date,
		   HR.Job_Title,EM.Alpha_Emp_Code,RA.Approved_Date,RA.Rpt_Level,HR.Rec_Req_ID,(EM.Alpha_Emp_Code +'-'+ EM.Emp_Full_Name) as Emp_Full_Name,
		   EM.Branch_Name,EM.Desig_Name,EM.Dept_Name,'' as Manager_Email,'' as HR_Email,'' as ACC_Email,EM.Branch_ID
	INTO #RecruitmentAppRrd
	FROM T0050_HRMS_Recruitment_Request HR WITH (NOLOCK)
	LEFT JOIN T0052_Hrms_RecruitmentRequest_Approval RA WITH (NOLOCK) ON HR.Rec_Req_ID=RA.Rec_Req_ID AND Is_Final=0
	INNER JOIN T0095_EMP_SCHEME es WITH (NOLOCK) on HR.S_Emp_ID=es.Emp_ID
	INNER JOIN T0040_Scheme_Master sm WITH (NOLOCK) on sm.Scheme_Id=es.Scheme_ID
	INNER JOIN T0050_Scheme_Detail sd WITH (NOLOCK) on sd.Scheme_Id=sm.Scheme_Id
	INNER JOIN V0080_EMP_MASTER_INCREMENT_GET EM ON EM.Emp_ID=HR.S_Emp_ID
	WHERE  sm.Scheme_Type='Recruitment Request' AND HR.cmp_id=ISNULL(@cmp_id_Pass,HR.Cmp_ID)
	
	--SELECT * FROM #RecruitmentAppRrd
	Select @To_Manager=To_Manager, @To_Hr=To_Hr, @To_Account=To_Account, @Other_Email=Other_Email, 
		   @Is_Manager_CC=Is_Manager_CC, @Is_HR_CC=Is_HR_CC, @Is_Account_CC=Is_Account_CC
	From T0040_EMAIL_NOTIFICATION_CONFIG WITH (NOLOCK) Where CMP_ID = ISNULL(@cmp_id_Pass,Cmp_ID) And EMAIL_TYPE_NAME ='Recruitment Approval Level'
	
	DECLARE CurrExit CURSOR FOR		
		SELECT Cmp_ID,S_Emp_ID,Rec_Req_ID,CONVERT(VARCHAR(15),Rec_App_Date,103),Emp_Full_Name,Branch_Name,Desig_Name,Job_Title
		FROM #RecruitmentAppRrd where rec_req_id=211
	OPEN CurrExit	
	FETCH NEXT FROM CurrExit INTO @Cmp_ID,@Emp_ID,@Rec_Req_ID,@Rec_App_Date,@Emp_Full_Name,@Branch_Name,@Desig_Name,@Job_Title
		WHILE @@FETCH_STATUS = 0
			BEGIN
				INSERT INTO #Scheme_Table
				EXEC SP_RPT_SCHEME_DETAILS_ESS_GET @Cmp_ID=@Cmp_ID,@From_Date=@From_date,@To_Date=@From_date,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=@Emp_Id,@Constraint=@Emp_Id,@Report_Type = 'Recruitment Request'
				--select * from #Scheme_Table				
				
				SELECT @Max_Level=ISNULL(MAX(RPT_Level),0),@Approval_Date=Approved_Date
				FROM T0052_Hrms_RecruitmentRequest_Approval WITH (NOLOCK) WHERE Rec_Req_ID=@Rec_Req_ID GROUP by Approved_Date
				
				--SELECT LEFT(Rpt_Mgr_2,CHARINDEX('-',Rpt_Mgr_2)-1) FROM #Scheme_Table WHERE Rpt_Mgr_2 <>''
				--SELECT @Cmp_ID,@Emp_ID,@Rec_Req_ID,@Max_Level
				--select * FROM #RecruitmentAppRrd where rec_req_id=211
				--select * from #Scheme_Table
			--SELECT LEFT(Rpt_Mgr_2,CHARINDEX('-',Rpt_Mgr_2)-1) FROM #Scheme_Table 	
				IF ISNULL(@Max_Level,0)=0
					BEGIN
						SELECT @Sup_Alpha_Emp_Code=LEFT(Rpt_Mgr_1,CHARINDEX('-',Rpt_Mgr_1)-1) FROM #Scheme_Table WHERE Rpt_Mgr_1 <>''
						--SELECT @Sup_Email_Alpha_Emp_Code=LEFT(Rpt_Mgr_2,CHARINDEX('-',Rpt_Mgr_2)-1) FROM #Scheme_Table WHERE Rpt_Mgr_2 <>''	
						SET @Esclation_Date	=DATEADD(DAY,3,@Rec_App_Date)	
						SET @STATUS='Pending First Level Approval'								
					END	
				ELSE IF ISNULL(@Max_Level,0)=1
					BEGIN
						SELECT @Sup_Alpha_Emp_Code=LEFT(Rpt_Mgr_2,CHARINDEX('-',Rpt_Mgr_2)-1) FROM #Scheme_Table WHERE Rpt_Mgr_2 <>''
						--SELECT @Sup_Email_Alpha_Emp_Code=LEFT(Rpt_Mgr_3,CHARINDEX('-',Rpt_Mgr_3)-1) FROM #Scheme_Table WHERE Rpt_Mgr_3 <>''		
						SET @Esclation_Date	=DATEADD(DAY,3,@Approval_Date)	
						SET @STATUS='Pending Second Level Approval'											
					END
				ELSE IF ISNULL(@Max_Level,0)=2
					BEGIN
						SELECT @Sup_Alpha_Emp_Code=LEFT(Rpt_Mgr_3,CHARINDEX('-',Rpt_Mgr_3)-1) FROM #Scheme_Table WHERE Rpt_Mgr_3 <>''
						--SELECT @Sup_Email_Alpha_Emp_Code=LEFT(Rpt_Mgr_4,CHARINDEX('-',Rpt_Mgr_4)-1) FROM #Scheme_Table WHERE Rpt_Mgr_4 <>''			
						SET @Esclation_Date	=DATEADD(DAY,3,@Approval_Date)	
						SET @STATUS='Pending Third Level Approval'									
					END
				ELSE IF ISNULL(@Max_Level,0)=3
					BEGIN
						SELECT @Sup_Alpha_Emp_Code=LEFT(Rpt_Mgr_4,CHARINDEX('-',Rpt_Mgr_4)-1) FROM #Scheme_Table WHERE Rpt_Mgr_4 <>''
						--SELECT @Sup_Email_Alpha_Emp_Code=LEFT(Rpt_Mgr_5,CHARINDEX('-',Rpt_Mgr_5)-1) FROM #Scheme_Table 	WHERE Rpt_Mgr_5 <>''							
						SET @Esclation_Date	=DATEADD(DAY,3,@Approval_Date)	
						SET @STATUS='Pending Forth Level Approval'						
					END
				ELSE IF ISNULL(@Max_Level,0)=4
					BEGIN
						SELECT @Sup_Alpha_Emp_Code=LEFT(Rpt_Mgr_5,CHARINDEX('-',Rpt_Mgr_5)-1) FROM #Scheme_Table WHERE Rpt_Mgr_5 <>''
						SET @Esclation_Date	=DATEADD(DAY,3,@Approval_Date)		
						SET @STATUS='Pending Fifth Level Approval'								
					END
				
				IF GETDATE() >= @Esclation_Date 
					BEGIN
						SET @Max_Level=ISNULL(@Max_Level,0)+1
						SELECT @Max_Rpt_Level=Max_Level FROM #Scheme_Table WHERE Emp_id=@Emp_ID	
						IF @Max_Level=@Max_Rpt_Level
							SET @final_Approval=1
						
						IF @Sup_Alpha_Emp_Code <> ''	
							SELECT @Manager_Email_ID=Work_Email FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Alpha_Emp_Code=@Sup_Alpha_Emp_Code							
						
						--IF @Sup_Email_Alpha_Emp_Code <> ''
						--	SELECT @Manager_Email_ID=Work_Email FROM T0080_EMP_MASTER WHERE Alpha_Emp_Code=@Sup_Email_Alpha_Emp_Code							
						
						--SELECT @TRAN_ID = ISNULL(MAX(TRAN_ID),0) + 1 FROM T0300_EMP_EXIT_APPROVAL_LEVEL
						--INSERT INTO T0300_EMP_EXIT_APPROVAL_LEVEL(
						--	TRAN_ID,
						--	EXIT_ID,
						--	EMP_ID,
						--	CMP_ID,
						--	BRANCH_ID,
						--	DESIG_ID,
						--	RESIGNATION_DATE,
						--	LAST_DATE,
						--	REASON,
						--	COMMENTS,
						--	STATUS,
						--	IS_REHIRABLE ,
						--	S_EMP_ID,
						--	FEEDBACK,
						--	SUP_ACK,
						--	INTERVIEW_DATE,
						--	INTERVIEW_TIME,
						--	IS_PROCESS,
						--	EMAIL_FORWARDTO,
						--	DRIVEDATA_FORWARDTO,
						--	RPT_MNG_ID,
						--	RPT_LEVEL,
						--	FINAL_APPROVAL,
						--	IS_FWD_REJECT,
						--	Application_date,  
						--	Approval_date, 
						--	Clearance_ManagerID
						--)						
						--SELECT @TRAN_ID,@Exit_ID,@Emp_ID,@Cmp_ID,branch_id,desig_id,resignation_date,last_date,reason,
						--	   '','P',0,@Sup_id,'','P','1900-01-01','','Y','','',0,@Max_Level,
						--	   @final_Approval,@final_Approval,Application_date,
						--	   CASE WHEN @final_Approval=1 THEN GETDATE() ELSE @Esclation_Date END,''
						--FROM T0200_Emp_ExitApplication WHERE emp_id=@Emp_ID AND exit_id=@Exit_ID	
						
						--if @final_Approval=1
						--	UPDATE T0200_Emp_ExitApplication set [status]='P',s_emp_id=@Sup_id
						--	WHERE emp_id=@Emp_ID AND exit_id=@Exit_ID
------------------------------------------------Send Email----------------------------------------------------------------

						If @To_Hr = 1 or @Is_HR_CC = 1 
							Begin	
							
								SELECT @HR_EMAIL=LN.Email_ID from #RecruitmentAppRrd RA 
									LEFT JOIN T0011_LOGIN LN WITH (NOLOCK) ON RA.CMP_ID=LN.Cmp_ID
										where Is_HR = 1 and RA.cmp_id=@cmp_id AND  ISNULL(branch_id_multi,'') <> '' AND
										RA.BRANCH_ID	 IN (SELECT     cast(data AS numeric(18, 0))
												 FROM          dbo.Split(ISNULL(branch_id_multi, ''), '#')
												 WHERE      data <> '')						
								END								
						If @To_Account = 1	or @Is_Account_CC = 1
							Begin
									
								SELECT @ACC_EMAIL=L.Email_ID_accou
								FROM	#ExitAppRrd R
										CROSS APPLY  (SELECT	EMP_ID, L.Email_ID_accou
													  FROM		T0011_LOGIN  L WITH (NOLOCK)
													  WHERE		L.Cmp_ID=isnull(@cmp_id_Pass,Cmp_ID) AND CHARINDEX(',' + CAST(R.Branch_ID AS varchar(5)) + ',', ',' + L.Branch_ID_Multi + ',') >= 0
																And Is_Accou = 1 and Is_Active =1 ) L 
							END						
						SELECT @email_format=Email_Signature FROM T0010_Email_Format_Setting WITH (NOLOCK) WHERE Cmp_ID=@Cmp_Id and Email_Type = 'Recruitment Approval Level'
						
						select @email_format,@Cmp_Id
						Declare @profile as varchar(50)
						SET @profile = ''
						  
						SELECT @profile = isnull(DB_Mail_Profile_Name,'') FROM t9999_Reminder_Mail_Profile WITH (NOLOCK) WHERE cmp_id = @Cmp_Id
						  
						IF isnull(@profile,'') = ''
						  BEGIN
							SELECT @profile = isnull(DB_Mail_Profile_Name,'') FROM t9999_Reminder_Mail_Profile WITH (NOLOCK) WHERE cmp_id = 0
						  END
       					
						SELECT TOP 1 @HREmail_ID = Email_ID, @HR_Name = Emp_Full_Name
						FROM T0011_LOGIN L WITH (NOLOCK) LEFT OUTER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON L.Emp_ID = E.Emp_ID
						WHERE L.Cmp_ID=@Cmp_ID AND Is_HR = 1	
						
						IF isnull(@HREmail_ID,'')='' 
							BEGIN
								SELECT @HREmail_ID = (SELECT TOP 1 Email_ID FROM T0011_LOGIN WITH (NOLOCK) WHERE Is_HR = 1)
							END						
						
						SET @email_format = REPLACE(@email_format, '#message#', 'Recruitment Approval Level')
						SET @email_format = REPLACE(@email_format, '#Date#', @Rec_App_Date)
						SET @email_format = REPLACE(@email_format, '#Employee#', @Emp_Full_Name)						
						SET @email_format = REPLACE(@email_format, '#Branch#', @Branch_Name)
						SET @email_format = REPLACE(@email_format, '#Designation#', @Desig_Name)	
						SET @email_format = REPLACE(@email_format, '#JobTitle#', @Job_Title)	
						SET @email_format = REPLACE(@email_format, '#level#', @Max_Level)	
						SET @email_format = REPLACE(@email_format, '#ApproveEmp#', '')
						SET @email_format = REPLACE(@email_format, '#status#', @STATUS)
						SET @email_format = REPLACE(@email_format, '#Approve#', '')
						SET @email_format = REPLACE(@email_format, '#Reject#', '')

				SET @TO_EMAIL_DETAIL = NULL;
				SET @CC_EMAIL_DETAIL = NULL;
								
				IF @To_Manager = 1 
					BEGIN
						SET @TO_EMAIL_DETAIL = ISNULL(@TO_EMAIL_DETAIL + ';', '') + isnull(@Manager_Email_ID,'')
					END
				ELSE IF @Is_Manager_CC = 1
					SET @CC_EMAIL_DETAIL = ISNULL(@CC_EMAIL_DETAIL + ';', '') + isnull(@Manager_Email_ID,'')
					
				if @To_Manager=0
					BEGIN
						SET @TO_EMAIL_DETAIL = ISNULL(@TO_EMAIL_DETAIL + ';', '') + isnull(@Manager_Email_ID,'')
					END
								
				IF @To_Hr =1 or @IS_HR_CC = 1 
					SET @CC_EMAIL_DETAIL = ISNULL(@CC_EMAIL_DETAIL + ';', '') + isnull(@HR_EMAIL,'')
				ELSE IF @TO_HR = 1
					BEGIN
						select @TO_EMAIL_DETAIL as to_email
						SET @TO_EMAIL_DETAIL = ISNULL(@TO_EMAIL_DETAIL + ';', '') + isnull(@HR_EMAIL,'')
					end	
				
				IF @To_Account=1 or @Is_Account_CC = 1
					SET @CC_EMAIL_DETAIL = ISNULL(@CC_EMAIL_DETAIL + ';', '') + isnull(@ACC_EMAIL,'')
				ELSE
					SET @TO_EMAIL_DETAIL = ISNULL(@TO_EMAIL_DETAIL + ';', '') + isnull(@ACC_EMAIL,'')
					
												
				IF @Other_Email <> ''
					SET @CC_EMAIL_DETAIL = ISNULL(@CC_EMAIL_DETAIL + ';', '') + isnull(@Other_Email,'') 
					
						--select @email_format,@Manager_Email_ID
						EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @TO_EMAIL_DETAIL, @subject = 'Recruitment Request Status', @body = @email_format, @body_format = 'HTML',@copy_recipients = @CC_EMAIL_DETAIL
					END
				
				SELECT @TO_EMAIL_DETAIL,@CC_EMAIL_DETAIL,@Other_Email
			FETCH NEXT FROM CurrExit INTO @Cmp_ID,@Emp_ID,@Rec_Req_ID,@Rec_App_Date,@Emp_Full_Name,@Branch_Name,@Desig_Name,@Job_Title
	END
	CLOSE CurrExit	
	DEALLOCATE CurrExit
END



