
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_Employee_Exit_Escalation]
	@cmp_id_Pass NUMERIC(18,0) = 0,
	@CC_Email NVARCHAR(max) = ''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN 
 

	DECLARE @Esclation_Date DATETIME   
	DECLARE @Approval_day AS NUMERIC    
	DECLARE @ReminderTemplate AS NVARCHAR(4000)
	DECLARE @Emp_ID AS INT
	DECLARE @Escalation_Days INT
	DECLARE @resignation_date DATETIME
	DECLARE @Left_Date DATETIME
	DECLARE @Cmp_ID as INT
	DECLARE @Max_Level INT
	DECLARE @Exit_ID AS INT
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
	DECLARE @Asset_Name VARCHAR(100)
	DECLARE @Asset_Code VARCHAR(100)
	DECLARE @Brand_name VARCHAR(100)
	DECLARE @Model_Name VARCHAR(100)
	DECLARE @Serial_NO VARCHAR(100)
	DECLARE @Allocation_Date VARCHAR(25)
	DECLARE @Return_date VARCHAR(25)
	DECLARE @Approval_status VARCHAR(15)
	DECLARE @Asset_Status VARCHAR(15)
	DECLARE	@Leave_Name VARCHAR(250)
	DECLARE @Leave_Closing VARCHAR(15)
	DECLARE @For_Date DATETIME
	DECLARE @Adv_Amount VARCHAR(15)
	DECLARE @Emp_Full_Name varchar(Max)
	DECLARE @Loan_Name varchar(350)
	DECLARE @Loan_Issue VARCHAR(15)
	DECLARE @Loan_Return VARCHAR(15)
	DECLARE @Loan_Closing VARCHAR(15)
	DECLARE @Guarantor varchar(350)	
	DECLARE @Loan_Apr_Date DATETIME
	DECLARE @Loan_Apr_Amount VARCHAR(15)
	DECLARE @Loan_Apr_Pending_Amount VARCHAR(15)
	DECLARE @Loan_Apr_Status VARCHAR(25)
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
   
   IF OBJECT_ID('tempdb..#Leave_Detail') IS NULL 
	BEGIN			
		CREATE table #Leave_Detail
		(
			Leave_Opening numeric(18,2),
			Leave_Used numeric(18,2),
			Leave_Closing numeric(18,2),
			Leave_Code varchar(10),
			Leave_Name varchar(250),
			Leave_ID numeric(18,0),
			Leave_Type varchar(10)
		)
	END	
		
	CREATE TABLE #Guarantor_Detail
		(
			Cmp_id			NUMERIC,
			emp_id			NUMERIC,
			Loan_apr_ID		NUMERIC,
			Loan_ID			NUMERIC,
			Loan_Issue		NUMERIC,
			Loan_Return		NUMERIC,
			Loan_Closing	NUMERIC,
			For_Date		Datetime,
			Loan_Status		VARCHAR(20),
			Emp_Full_Name   VARCHAR(max),
			Guarantor       VARCHAR(50),
			Loan_Name		VARCHAR(150)
		)	
		
    DECLARE @From_date	DATETIME 
	SET @From_date = GETDATE()
	
	SELECT DISTINCT ex.Cmp_ID,es.Emp_ID,es.Scheme_ID,sm.Scheme_Name,sm.Scheme_Type,ISNULL(sd.Leave_Days ,0)Escalation_Days,ex.resignation_date,
		   EL.Left_Date,ex.exit_id,EM.Emp_Full_Name,EM.Dept_Name,RM.Reason_Name,ex.last_date,'' as Manager_Email,
		   '' as HR_Email,'' as ACC_Email
	INTO #ExitAppRrd
	FROM T0200_Emp_ExitApplication ex WITH (NOLOCK)
	INNER JOIN T0095_EMP_SCHEME es WITH (NOLOCK) on ex.emp_id=es.Emp_ID
	INNER JOIN T0040_Scheme_Master sm WITH (NOLOCK) on sm.Scheme_Id=es.Scheme_ID
	INNER JOIN T0050_Scheme_Detail sd WITH (NOLOCK) on sd.Scheme_Id=sm.Scheme_Id
	INNER JOIN V0080_EMP_MASTER_INCREMENT_GET EM ON EM.Emp_ID=EX.emp_id
	LEFT JOIN T0100_LEFT_EMP EL WITH (NOLOCK) ON EL.Emp_ID=EX.emp_id
	INNER JOIN T0040_Reason_Master RM WITH (NOLOCK) ON RM.Res_Id=EX.reason
	WHERE ex.[status] IN('H') AND sm.Scheme_Type='Exit' AND ISNULL(sd.Leave_Days,0) > 0 AND ex.cmp_id=ISNULL(@cmp_id_Pass,ex.Cmp_ID)
	
	Select @To_Manager=To_Manager, @To_Hr=To_Hr, @To_Account=To_Account, @Other_Email=Other_Email, 
		   @Is_Manager_CC=Is_Manager_CC, @Is_HR_CC=Is_HR_CC, @Is_Account_CC=Is_Account_CC
	From T0040_EMAIL_NOTIFICATION_CONFIG WITH (NOLOCK) Where CMP_ID = ISNULL(@cmp_id_Pass,Cmp_ID) And EMAIL_TYPE_NAME ='Exit Approval'
		
	--IF @Other_Email<>''
	--	BEGIN
	--		UPDATE #Temp SET Other_Email =@Other_Email						 
	--	END 
				
	DECLARE CurrExit CURSOR FOR		
		SELECT Cmp_ID,Emp_ID,Escalation_Days,resignation_date,Left_Date,Exit_ID,Emp_Full_Name,Dept_Name,Reason_Name,last_date
		FROM #ExitAppRrd 
	OPEN CurrExit	
	FETCH NEXT FROM CurrExit INTO @Cmp_ID,@Emp_ID,@Escalation_Days,@resignation_date,@Left_Date,@Exit_ID,@EMP_NAME,@DEPARTMENT,@REASON_FOR_RESIGNATION,@LAST_WORKING_DATE
		WHILE @@FETCH_STATUS = 0
			BEGIN
				INSERT INTO #Scheme_Table
				EXEC SP_RPT_SCHEME_DETAILS_ESS_GET @Cmp_ID=@Cmp_ID,@From_Date=@From_date,@To_Date=@From_date,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=@Emp_Id,@Constraint=@Emp_Id,@Report_Type = 'Exit'
				
				SELECT @Max_Level=ISNULL(MAX(RPT_Level),0),@Approval_Date=Approval_date 
				FROM T0300_Emp_Exit_Approval_Level WITH (NOLOCK) WHERE Emp_id=@Emp_ID GROUP by Approval_date
					
				IF ISNULL(@Max_Level,0)=0
					BEGIN
						SELECT @Sup_Alpha_Emp_Code=LEFT(Rpt_Mgr_1,CHARINDEX('-',Rpt_Mgr_1)-1) FROM #Scheme_Table 
						SELECT @Sup_Email_Alpha_Emp_Code=LEFT(Rpt_Mgr_2,CHARINDEX('-',Rpt_Mgr_2)-1) FROM #Scheme_Table 	
						SET @Esclation_Date	=DATEADD(DAY,@Escalation_Days,@resignation_date)	
						SET @STATUS='First Level Approved'								
					END	
				ELSE IF ISNULL(@Max_Level,0)=1
					BEGIN
						SELECT @Sup_Alpha_Emp_Code=LEFT(Rpt_Mgr_2,CHARINDEX('-',Rpt_Mgr_2)-1) FROM #Scheme_Table 
						SELECT @Sup_Email_Alpha_Emp_Code=LEFT(Rpt_Mgr_3,CHARINDEX('-',Rpt_Mgr_3)-1) FROM #Scheme_Table 		
						SET @Esclation_Date	=DATEADD(DAY,@Escalation_Days,@Approval_Date)	
						SET @STATUS='First Level Approved'											
					END
				ELSE IF ISNULL(@Max_Level,0)=2
					BEGIN
						SELECT @Sup_Alpha_Emp_Code=LEFT(Rpt_Mgr_3,CHARINDEX('-',Rpt_Mgr_3)-1) FROM #Scheme_Table 
						SELECT @Sup_Email_Alpha_Emp_Code=LEFT(Rpt_Mgr_4,CHARINDEX('-',Rpt_Mgr_4)-1) FROM #Scheme_Table 				
						SET @Esclation_Date	=DATEADD(DAY,@Escalation_Days,@Approval_Date)	
						SET @STATUS='Second Level Approved'									
					END
				ELSE IF ISNULL(@Max_Level,0)=3
					BEGIN
						SELECT @Sup_Alpha_Emp_Code=LEFT(Rpt_Mgr_4,CHARINDEX('-',Rpt_Mgr_4)-1) FROM #Scheme_Table 
						SELECT @Sup_Email_Alpha_Emp_Code=LEFT(Rpt_Mgr_5,CHARINDEX('-',Rpt_Mgr_5)-1) FROM #Scheme_Table 								
						SET @Esclation_Date	=DATEADD(DAY,@Escalation_Days,@Approval_Date)	
						SET @STATUS='Third Level Approved'						
					END
				ELSE IF ISNULL(@Max_Level,0)=4
					BEGIN
						SELECT @Sup_Alpha_Emp_Code=LEFT(Rpt_Mgr_5,CHARINDEX('-',Rpt_Mgr_5)-1) FROM #Scheme_Table 
						SET @Esclation_Date	=DATEADD(DAY,@Escalation_Days,@Approval_Date)		
						SET @STATUS='Forth Level Approved'								
					END
				print @Esclation_Date
				IF GETDATE() <= @Esclation_Date 
					BEGIN			
						SET @Max_Level=ISNULL(@Max_Level,0)+1
						SELECT @Max_Rpt_Level=Max_Level FROM #Scheme_Table WHERE Emp_id=@Emp_ID	
						IF @Max_Level=@Max_Rpt_Level
							SET @final_Approval=1
							
						SELECT @Sup_id=Emp_ID FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Alpha_Emp_Code=@Sup_Alpha_Emp_Code							
						SELECT @Manager_Email_ID=Work_Email FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Alpha_Emp_Code=@Sup_Email_Alpha_Emp_Code							
						
						SELECT @TRAN_ID = ISNULL(MAX(TRAN_ID),0) + 1 FROM T0300_EMP_EXIT_APPROVAL_LEVEL WITH (NOLOCK)
						INSERT INTO T0300_EMP_EXIT_APPROVAL_LEVEL(
							TRAN_ID,
							EXIT_ID,
							EMP_ID,
							CMP_ID,
							BRANCH_ID,
							DESIG_ID,
							RESIGNATION_DATE,
							LAST_DATE,
							REASON,
							COMMENTS,
							STATUS,
							IS_REHIRABLE ,
							S_EMP_ID,
							FEEDBACK,
							SUP_ACK,
							INTERVIEW_DATE,
							INTERVIEW_TIME,
							IS_PROCESS,
							EMAIL_FORWARDTO,
							DRIVEDATA_FORWARDTO,
							RPT_MNG_ID,
							RPT_LEVEL,
							FINAL_APPROVAL,
							IS_FWD_REJECT,
							Application_date,  
							Approval_date, 
							Clearance_ManagerID
						)						
						SELECT @TRAN_ID,@Exit_ID,@Emp_ID,@Cmp_ID,branch_id,desig_id,resignation_date,last_date,reason,
							   '','P',0,@Sup_id,'','P','1900-01-01','','Y','','',0,@Max_Level,
							   @final_Approval,@final_Approval,Application_date,
							   CASE WHEN @final_Approval=1 THEN GETDATE() ELSE @Esclation_Date END,''
						FROM T0200_Emp_ExitApplication WITH (NOLOCK) WHERE emp_id=@Emp_ID AND exit_id=@Exit_ID	
						
						if @final_Approval=1
							UPDATE T0200_Emp_ExitApplication set [status]='P',s_emp_id=@Sup_id
							WHERE emp_id=@Emp_ID AND exit_id=@Exit_ID
------------------------------------------------Send Email----------------------------------------------------------------
						If @To_Hr = 1 or @Is_HR_CC = 1 
							Begin						
								SELECT @HR_EMAIL= L.Email_ID
								FROM	#ExitAppRrd R
										CROSS APPLY  (SELECT	EMP_ID, L.Email_ID
													  FROM		T0011_LOGIN  L WITH (NOLOCK)
													  WHERE		L.Cmp_ID=isnull(@cmp_id_Pass,Cmp_ID) AND CHARINDEX(',' + CAST(R.Branch_ID AS varchar(5)) + ',', ',' + L.Branch_ID_Multi + ',') >= 0
																and IS_HR = 1 AND IS_ACTIVE=1 ) L 
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
				
						SELECT @email_format=Email_Signature FROM T0010_Email_Format_Setting WITH (NOLOCK) WHERE Cmp_ID=@Cmp_Id and Email_Type = 'Exit Approval'
						
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
						
						SET @email_format = REPLACE(@email_format, '#message#', 'Exit Approval')
						SET @email_format = REPLACE(@email_format, '#EmployeeName#', @EMP_NAME)
						SET @email_format = REPLACE(@email_format, '#Department#', @DEPARTMENT)
						SET @email_format = REPLACE(@email_format, '#DateofResignation#', Convert(nvarchar(11),@resignation_date,113))
						SET @email_format = REPLACE(@email_format, '#LastWorkingDate#', Convert(nvarchar(11),@LAST_WORKING_DATE,113))
						SET @email_format = REPLACE(@email_format, '#ReasonforResignation#', @REASON_FOR_RESIGNATION)
						SET @email_format = REPLACE(@email_format, '#Status#', @STATUS)	
						SET @email_format = REPLACE(@email_format, '#Signature#', '')
--------------------------------------------------Asset Details-------------------------------------------	
						IF EXISTS(SELECT 1 from V0040_Asset_Allocation WHERE Emp_ID=@Emp_ID and Cmp_ID =@CMP_ID)
						BEGIN					
								SET @HTML_TABLE='<tr>
											<td colspan=''7'' height=''25'' align=''center'' valign=''middle'' style=''font-family: Open Sans, Helvetica, Arial, sans-serif;
												font-size: 10pt; color: #fff; text-align: center; text-decoration: none;''>
												<b>Asset Details </b>
											</td>
											</tr>
											<tr>
											<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: Center; text-decoration: none;
												width: 80px;color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
												Asset
											</td>
											<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: Center; text-decoration: none;
												width: 100px;color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
												Asset Code
											</td>
											<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: center;  text-decoration: none;
												width: 100px;color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
												Brand
											</td>
											<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: center; text-decoration: none;
												width: 100px;color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
												Model
											</td>
											<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: center; text-decoration: none;
												width: 100px;color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
												Serial No
											</td>							
											<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: center; text-decoration: none;
												width: 100px;color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
												Allocation Date
											</td>							
										</tr>'
					

							DECLARE EMAIL_FORMAT_DETAILS CURSOR FOR
								SELECT Asset_Name,Asset_Code,Brand_Name,Model_Name,Serial_No,Allocation_Date from V0040_Asset_Allocation			
								WHERE Emp_ID=@Emp_ID and Cmp_ID =@CMP_ID  ORDER BY Asset_Name
							OPEN EMAIL_FORMAT_DETAILS
							FETCH NEXT FROM EMAIL_FORMAT_DETAILS into @Asset_Name,@Asset_Code,@Brand_name,@Model_Name,@Serial_NO,@Allocation_Date
							while @@fetch_status = 0
								Begin	
									IF ISNULL(@Asset_Name,'') <>''
										BEGIN
											set @HTML_TABLE = @HTML_TABLE + '<tr>
																<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
																	' + @Asset_Name + '
																</td>
																<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
																	' + @Asset_Code + '
																</td>
																<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
																	' + @Brand_name + '
																</td>											
																<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
																	' + @Model_Name + '
																</td>
																<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
																	' + @Serial_NO + '
																</td>											
																<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
																	' + @Allocation_Date + '
																</td>										
														   </tr>'						
										END				
									FETCH NEXT FROM EMAIL_FORMAT_DETAILS into @Asset_Name,@Asset_Code,@Brand_name,@Model_Name,@Serial_NO,@Allocation_Date
								End
							close EMAIL_FORMAT_DETAILS 
							deallocate EMAIL_FORMAT_DETAILS
					END
				ELSE
					BEGIN 
						set @HTML_TABLE = @HTML_TABLE + '<tr>
									<td colspan=''7'' height=''25'' align=''center'' valign=''middle'' style=''font-family: Open Sans, Helvetica, Arial, sans-serif;
										font-size: 10pt; color: #fff; text-align: center; text-decoration: none;''>
										<b>No Asset Details </b>
									</td></tr>'
					END
				
		SET @email_format = REPLACE(@email_format, '#AssetDetails#', @HTML_TABLE)
-----------------------------------------------------Loan Details--------------------------------------------------	
		set @HTML_TABLE=''	
		IF EXISTS(SELECT 1 from V0120_LOAN_APPROVAL WHERE Emp_ID=@Emp_ID and Cmp_ID =@Cmp_ID)
			BEGIN
				SET @HTML_TABLE='<tr>
										<td colspan=''7'' height=''25'' align=''center'' valign=''middle'' style=''font-family: Open Sans, Helvetica, Arial, sans-serif;
											font-size: 10pt; color: #fff; text-align: center; text-decoration: none;''>
											<b>Loan Details </b>
										</td>
										</tr>
										<tr>
										<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: Center; text-decoration: none;
											width: 80px;color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
											Loan Name
										</td>
										<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: Center; text-decoration: none;
											width: 100px;color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
											Approval Date
										</td>
										<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: center;  text-decoration: none;
											width: 100px;color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
											Loan Amount
										</td>
										<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: center; text-decoration: none;
											width: 100px;color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
											Loan Pending
										</td>
										<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: center; text-decoration: none;
											width: 100px;color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
											Status
										</td>				
									</tr>'
				

				DECLARE EMAIL_FORMAT_DETAILS CURSOR FOR
					SELECT Loan_Name,Loan_Apr_Date,Loan_Apr_Amount,Loan_Apr_Pending_Amount,case when Loan_Apr_Status='A' then 'Approved' else 'Rejected' end Loan_Apr_Status from V0120_LOAN_APPROVAL
					WHERE Emp_ID=@Emp_ID and Cmp_ID =@CMP_ID  ORDER BY Loan_Name
				OPEN EMAIL_FORMAT_DETAILS
				FETCH NEXT FROM EMAIL_FORMAT_DETAILS into @Loan_Name,@Loan_Apr_Date,@Loan_Apr_Amount,@Loan_Apr_Pending_Amount,@Loan_Apr_Status
				while @@fetch_status = 0
					Begin	
						IF ISNULL(@Asset_Name,'') <>''
							BEGIN
								set @HTML_TABLE = @HTML_TABLE + '<tr>
													<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
														' + @Loan_Name + '
													</td>
													<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
														' + @Loan_Apr_Date + '
													</td>
													<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
														' + @Loan_Apr_Amount + '
													</td>											
													<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
														' + @Loan_Apr_Pending_Amount + '
													</td>
													<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
														' + @Loan_Apr_Status + '
													</td>						
											   </tr>'						
							END				
						FETCH NEXT FROM EMAIL_FORMAT_DETAILS into @Loan_Name,@Loan_Apr_Date,@Loan_Apr_Amount,@Loan_Apr_Pending_Amount,@Loan_Apr_Status
					End
				close EMAIL_FORMAT_DETAILS 
				deallocate EMAIL_FORMAT_DETAILS
				END	
			ELSE
				BEGIN 
					set @HTML_TABLE = @HTML_TABLE + '<tr>
								<td colspan=''7'' height=''25'' align=''center'' valign=''middle'' style=''font-family: Open Sans, Helvetica, Arial, sans-serif;
                                    font-size: 10pt; color: #fff; text-align: center; text-decoration: none;''>
                                    <b>No Loan Details </b>
                                </td>
								</tr>'
				END
			SET @email_format = REPLACE(@email_format, '#LoanDetails#', @HTML_TABLE)
-------------------------------------------------Leave Details--------------------------------------------------
			SET @HTML_TABLE=''						
			EXEC SP_LEAVE_CLOSING_AS_ON_DATE @Cmp_ID,@Emp_ID,''			
			IF EXISTS(SELECT 1 FROM #Leave_Detail)
				BEGIN
					SET @HTML_TABLE='<tr>
											<td colspan=''7'' height=''25'' align=''center'' valign=''middle'' style=''font-family: Open Sans, Helvetica, Arial, sans-serif;
												font-size: 10pt; color: #fff; text-align: center; text-decoration: none;''>
												<b>Leave Details </b>
											</td>
											</tr>
											<tr>
											<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: Center; text-decoration: none;
												color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
												Leave
											</td>
											<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: Center; text-decoration: none;
												color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
												Balance
											</td>												
										</tr>'
					

					DECLARE EMAIL_FORMAT_DETAILS CURSOR FOR
						SELECT Leave_Name,Leave_Closing from #Leave_Detail 
					OPEN EMAIL_FORMAT_DETAILS
					FETCH NEXT FROM EMAIL_FORMAT_DETAILS into @Leave_Name,@Leave_Closing
					while @@fetch_status = 0
						Begin							
							set @HTML_TABLE = @HTML_TABLE + '<tr>
												<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
													' + @Leave_Name + '
												</td>
												<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
													' + @Leave_Closing + '
												</td>														
										   </tr>'
							FETCH NEXT FROM EMAIL_FORMAT_DETAILS into @Leave_Name,@Leave_Closing
						End
					close EMAIL_FORMAT_DETAILS 
					deallocate EMAIL_FORMAT_DETAILS
					END	
				ELSE
					BEGIN 
						set @HTML_TABLE = @HTML_TABLE + '<tr>
									<td colspan=''7'' height=''25'' align=''center'' valign=''middle'' style=''font-family: Open Sans, Helvetica, Arial, sans-serif;
										font-size: 10pt; color: #fff; text-align: center; text-decoration: none;''>
										<b>No Leave Details </b>
									</td>
									</tr>'
					END
				SET @email_format = REPLACE(@email_format, '#LeaveDetails#', @HTML_TABLE)
-------------------------------------------------Advance Details--------------------------------------------------	
			SET @HTML_TABLE=''					
			IF EXISTS(SELECT 1 FROM V0100_ADVANCE_PAYMENT WHERE Cmp_ID = @Cmp_ID and Emp_ID = @Emp_Id)
				BEGIN
					SET @HTML_TABLE='<tr>
											<td colspan=''7'' height=''25'' align=''center'' valign=''middle'' style=''font-family: Open Sans, Helvetica, Arial, sans-serif;
												font-size: 10pt; color: #fff; text-align: center; text-decoration: none;''>
												<b>Advance Details </b>
											</td>
											</tr>
											<tr>
											<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: Center; text-decoration: none;
												width: 80px;color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
												Effective Date
											</td>
											<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: Center; text-decoration: none;
												width: 100px;color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
												Advance Amount
											</td>												
										</tr>'
					

					DECLARE EMAIL_FORMAT_DETAILS CURSOR FOR
						SELECT For_Date,Adv_Amount FROM V0100_ADVANCE_PAYMENT WHERE Cmp_ID = @Cmp_ID and Emp_ID = @Emp_Id 
					OPEN EMAIL_FORMAT_DETAILS
					FETCH NEXT FROM EMAIL_FORMAT_DETAILS INTO @For_Date,@Adv_Amount
					WHILE @@fetch_status = 0
						BEGIN
							SET @HTML_TABLE = @HTML_TABLE + '<tr>
														<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
															' + @For_Date + '
														</td>
														<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
															' + @Adv_Amount + '
														</td>														
												   </tr>'	
							FETCH NEXT FROM EMAIL_FORMAT_DETAILS into @For_Date,@Adv_Amount
						End
					CLOSE EMAIL_FORMAT_DETAILS 
					DEALLOCATE EMAIL_FORMAT_DETAILS
					END	
				ELSE
					BEGIN 
						set @HTML_TABLE = @HTML_TABLE + '<tr>
									<td colspan=''7'' height=''25'' align=''center'' valign=''middle'' style=''font-family: Open Sans, Helvetica, Arial, sans-serif;
										font-size: 10pt; color: #fff; text-align: center; text-decoration: none;''>
										<b>No Advance Details </b>
									</td>
									</tr>'
					END
				SET @email_format = REPLACE(@email_format, '#AdvanceDetails#', @HTML_TABLE)			
-------------------------------------------------Guarantor Details--------------------------------------------------	
			SET @HTML_TABLE=''					
			INSERT INTO #Guarantor_Detail
			EXEC GET_LOAN_GUARANTOR_FOR_EXIT @Cmp_ID,@resignation_date,0,0,0,0,0,0,@Emp_ID,''
				SELECT * FROM #Guarantor_Detail
			IF EXISTS(SELECT 1 FROM #Guarantor_Detail)
				BEGIN
					SET @HTML_TABLE='<tr>
										<td colspan=''7'' height=''25'' align=''center'' valign=''middle'' style=''font-family: Open Sans, Helvetica, Arial, sans-serif;
											font-size: 10pt; color: #fff; text-align: center; text-decoration: none;''>
											<b>Guarantored Employee Pending Amount Details </b>
										</td>
									</tr>
									<tr>
										<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: Center; text-decoration: none;
											width: 80px;color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
											Employee Name
										</td>
										<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: Center; text-decoration: none;
											width: 100px;color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
											Loan
										</td>												
										<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: Center; text-decoration: none;
											width: 100px;color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
											Issue
										</td>	
										<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: Center; text-decoration: none;
											width: 100px;color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
											Return
										</td>	
										<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: Center; text-decoration: none;
											width: 100px;color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
											Pending
										</td>	
										<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: Center; text-decoration: none;
											width: 100px;color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
											Guarantor
										</td>	
									</tr>'
					

					DECLARE EMAIL_FORMAT_DETAILS CURSOR FOR
						SELECT Emp_Full_Name,Loan_Name,Loan_Issue,Loan_Return,Loan_Closing,Guarantor from #Guarantor_Detail WHERE Emp_ID=@Emp_ID and Cmp_ID =@CMP_ID 
					OPEN EMAIL_FORMAT_DETAILS
					FETCH NEXT FROM EMAIL_FORMAT_DETAILS into @Emp_Full_Name,@Loan_Name,@Loan_Issue,@Loan_Return,@Loan_Closing,@Guarantor
					while @@fetch_status = 0
						Begin
							set @HTML_TABLE = @HTML_TABLE + '<tr>
														<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
															' + @Emp_Full_Name + '
														</td>
														<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
															' + @Loan_Name + '
														</td>														
														<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
															' + @Loan_Issue + '
														</td>			
														<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
															' + @Loan_Return + '
														</td>			
														<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
															' + @Loan_Closing + '
														</td>			
														<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;color: #ffffff;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
															' + @Guarantor + '
														</td>	
												   </tr>'	
							FETCH NEXT FROM EMAIL_FORMAT_DETAILS into @Emp_Full_Name,@Loan_Name,@Loan_Issue,@Loan_Return,@Loan_Closing,@Guarantor
						End
					close EMAIL_FORMAT_DETAILS 
					deallocate EMAIL_FORMAT_DETAILS
					END	
				ELSE
					BEGIN 
						set @HTML_TABLE = @HTML_TABLE + '<tr>
										<td colspan=''7'' height=''25'' align=''center'' valign=''middle'' style=''font-family: Open Sans, Helvetica, Arial, sans-serif;
											font-size: 10pt; color: #fff; text-align: center; text-decoration: none;''>
											<b>No Guarantored Employee loan details</b>
										</td>
										</tr>'
					END
				SET @email_format = REPLACE(@email_format, '#GuarantoredDetails#', @HTML_TABLE)				
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
					
						select @email_format,@Manager_Email_ID
						EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @TO_EMAIL_DETAIL, @subject = 'Exit Approval', @body = @email_format, @body_format = 'HTML',@copy_recipients = @CC_EMAIL_DETAIL
					END
				
				
			FETCH NEXT FROM CurrExit INTO @Cmp_ID,@Emp_ID,@Escalation_Days,@resignation_date,@Left_Date,@Exit_ID,@EMP_NAME,@DEPARTMENT,@REASON_FOR_RESIGNATION,@LAST_WORKING_DATE
	END
	CLOSE CurrExit	
	DEALLOCATE CurrExit
	
    SELECT * FROM #ExitAppRrd   
END



