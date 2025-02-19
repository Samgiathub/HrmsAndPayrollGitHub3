

-- Created by rohit For Employee Probation Over Reminder to Hr Email on 20112013
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Employee_Probation_Reminder]
	@cmp_id_Pass Numeric(18,0) = 0,
	@CC_Email Nvarchar(max) = ''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	BEGIN   

		DECLARE @DATE VARCHAR(20)   
		DECLARE @Approval_day AS NUMERIC    
		DECLARE @ReminderTemplate AS NVARCHAR(MAX)
		SET @DATE = RIGHT(CAST(GETDATE() AS DATETIME), 5)      

		IF @cmp_id_Pass = 0
			SET @cmp_id_Pass = null
       
       
      
		IF OBJECT_ID('tempdb..#Temp') IS NOT NULL 
			BEGIN
				DROP TABLE #Temp
			END
       
		CREATE table #Temp
		( 
			CON INT IDENTITY(1, 1),
			Cmp_ID NUMERIC(18, 0),
			Emp_ID NUMERIC(18, 0),
			Emp_code VARCHAR(255),
			Emp_name VARCHAR(255),
			Branch_Name Varchar(255),
			Date_of_join Datetime,
			Probation_Period varchar(10),
			Probation_Date Datetime,
			New_Probation_Period Varchar(10),        
			New_probation_Date Datetime,
			BRANCH_ID INT,
			Manager_Email VARCHAR(MAX),	
			HR_Email VARCHAR(MAX),		
			ACC_Email VARCHAR(MAX),
			Other_Email VARCHAR(MAX)       
		)   
      
		CREATE table #HR_Email
		( 
			Row_Id INT IDENTITY(1, 1),
			Cmp_ID NUMERIC(18, 0)
		)   

		DECLARE @FROM_DATE AS DATETIME
		DECLARE @TO_DATE AS DATETIME
		Declare @EMAIL_NTF_SENT AS Numeric(1,0)
		Declare @To_Manager AS Tinyint
		Declare @To_Hr As Tinyint
		Declare @To_Account As Tinyint
		Declare @Other_Email As Varchar(max)
		Declare @Is_Manager_CC As Tinyint
		Declare @Is_HR_CC As Tinyint
		Declare @Is_Account_CC  As Tinyint
	
		SET @FROM_DATE = GETDATE()
		SET @TO_DATE = DATEADD(D, -1, DATEADD(M,1,@FROM_DATE))
		
		DECLARE @NO_OF_DAYS AS INT
		SELECT	@NO_OF_DAYS = Cast(IsNull(SETTING_VALUE,0) As Numeric) FROM T0040_SETTING WITH (NOLOCK)
		WHERE	SETTING_NAME = 'Enter No of Days for Employee Probation Over Reminder Email Scheduler'
				AND CMP_ID=ISNULL(@cmp_id_Pass,Cmp_ID) 
		
		--SET @NO_OF_DAYS =45
		IF @NO_OF_DAYS > 0
			BEGIN 
				SET @FROM_DATE  = GETDATE();
				SET @TO_DATE = DATEADD(D, @NO_OF_DAYS, GETDATE());
			END
          
		INSERT INTO #Temp( 
			Cmp_ID,
			Emp_ID,
			Emp_code,
			Emp_name,
			Branch_Name,
			Date_of_join,
			Probation_Period,
			Probation_Date,
			New_Probation_Period,
			New_probation_Date,
			BRANCH_ID,
			Manager_Email,	
			HR_Email,		
			ACC_Email,
			Other_Email                   
		)                
		SELECT	Cmp_ID,
				Emp_ID,
				Alpha_Emp_Code,
				Emp_Full_Name,
				Branch_Name,
				Date_Of_Join,
				probation,
				probation_date,
				New_Prob_period,
				New_Probation_EndDate,
				Branch_ID,
				'','','',''                
		From V0080_EMP_PROBATION_GET 
		Where Emp_Left <> 'Y' and cmp_id = isnull(@cmp_id_Pass,Cmp_ID) and 
					(
						(probation_date >= @FROM_DATE and probation_date <= @TO_DATE) 
						OR (probation_date <= @FROM_DATE AND Is_On_Probation = 1 ) 
					)  
					  
		
			Select @To_Manager=To_Manager, @To_Hr=To_Hr, @To_Account=To_Account, @Other_Email=Other_Email, 
				   @Is_Manager_CC=Is_Manager_CC, @Is_HR_CC=Is_HR_CC, @Is_Account_CC=Is_Account_CC
			From T0040_EMAIL_NOTIFICATION_CONFIG WITH (NOLOCK) Where CMP_ID = ISNULL(@cmp_id_Pass,Cmp_ID)  And EMAIL_TYPE_NAME ='Auto Mail of Probation Over'

			IF @To_Manager = 1 or @Is_Manager_CC = 1
			BEGIN
				UPDATE	R
					SET		Manager_Email = E.Work_Email
					FROM	#Temp R 
					INNER JOIN T0090_EMP_REPORTING_DETAIL RM on RM.Emp_ID = R.Emp_Id AND						
						Effect_Date=(select max(effect_date) 
						from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) where emp_id=R.Emp_ID)	
					INNER JOIN T0080_EMP_MASTER E on E.Emp_ID = RM.R_Emp_ID 
			END
			
			If @To_Hr = 1 or @Is_HR_CC = 1 
				Begin						
					UPDATE	R
					SET		HR_Email = L.Email_ID
					FROM	#Temp R
							CROSS APPLY  (SELECT	EMP_ID, L.Email_ID
										  FROM		T0011_LOGIN  L WITH (NOLOCK)
										  WHERE		L.Cmp_ID=isnull(@cmp_id_Pass,Cmp_ID) AND CHARINDEX(',' + CAST(R.Branch_ID AS varchar(5)) + ',', ',' + L.Branch_ID_Multi + ',') >= 0
													and IS_HR = 1 AND IS_ACTIVE=1 ) L 
					END								
			If @To_Account = 1	or @Is_Account_CC = 1
				Begin
						
					UPDATE	R
					SET		ACC_Email = L.Email_ID_accou
					FROM	#Temp R
							CROSS APPLY  (SELECT	EMP_ID, L.Email_ID_accou
										  FROM		T0011_LOGIN  L WITH (NOLOCK)
										  WHERE		L.Cmp_ID=isnull(@cmp_id_Pass,Cmp_ID) AND CHARINDEX(',' + CAST(R.Branch_ID AS varchar(5)) + ',', ',' + L.Branch_ID_Multi + ',') >= 0
													And Is_Accou = 1 and Is_Active =1 ) L 
				END
				
			IF @Other_Email<>''
				BEGIN
					UPDATE #Temp SET	Other_Email =@Other_Email						 
				END 
			--Insert Into #HR_Email (Cmp_ID)
			--Select Cmp_Id From #Temp Group by Cmp_ID
			--SELECT * FROM #Temp
			
		Declare @HREmail_ID	nvarchar(MAX)
		Declare @Cmp_Id as numeric
		Declare @HR_Name as varchar(255)
		Declare @ECount as numeric
		DECLARE @MANAGER_EMAIL VARCHAR(MAX)
		DECLARE @HR_EMAIL VARCHAR(MAX)
		DECLARE @ACC_EMAIL VARCHAR(MAX)
		DECLARE @O_EMAIL VARCHAR(MAX)
		DECLARE @TO_EMAIL_DETAIL VARCHAR(MAX)
		DECLARE @CC_EMAIL_DETAIL VARCHAR(MAX)
--SELECT	Manager_Email,HR_Email,ACC_Email,Other_Email,Cmp_ID,@IS_HR_CC,555 
--				FROM	#Temp 
--				GROUP BY Manager_Email,HR_Email,ACC_Email,Other_Email,Cmp_ID 		
		
		
		
		DECLARE Cur_Company CURSOR FOR                    		
				SELECT	Manager_Email,HR_Email,ACC_Email,Other_Email,Cmp_ID 
				FROM	#Temp 
				GROUP BY Manager_Email,HR_Email,ACC_Email,Other_Email,Cmp_ID 		
		OPEN Cur_Company                      
		FETCH NEXT FROM Cur_Company into @MANAGER_EMAIL,@HR_EMAIL,@ACC_EMAIL,@O_EMAIL,@Cmp_ID
		WHILE @@fetch_status = 0                    
			BEGIN     
				SET @TO_EMAIL_DETAIL = NULL;
				SET @CC_EMAIL_DETAIL = NULL;
								
				IF @To_Manager = 1 
					BEGIN
						SET @TO_EMAIL_DETAIL = ISNULL(@TO_EMAIL_DETAIL + ';', '') + isnull(@MANAGER_EMAIL,'')
					END
				ELSE IF @Is_Manager_CC = 1
					SET @CC_EMAIL_DETAIL = ISNULL(@CC_EMAIL_DETAIL + ';', '') + isnull(@MANAGER_EMAIL,'')
								
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
					SET @CC_EMAIL_DETAIL = ISNULL(@CC_EMAIL_DETAIL + ';', '') + isnull(@O_EMAIL,'') 
				
				SELECT TOP 1 @HREmail_ID = Email_ID, @HR_Name = Emp_Full_Name
				FROM T0011_LOGIN L Left Outer Join T0080_EMP_MASTER E on L.Emp_ID = E.Emp_ID
				WHERE L.Cmp_ID=@Cmp_ID AND Is_HR = 1

				SELECT @ECount = COUNT(Emp_Id) From #Temp 
				WHERE   Cmp_ID = @Cmp_Id AND
				isnull(MANAGER_EMAIL,'') =  COALESCE(@MANAGER_EMAIL,MANAGER_EMAIL,'')
				AND IsNull(HR_EMAIL,'') =  COALESCE(@HR_EMAIL,HR_EMAIL, '')
				AND ISNULL(ACC_EMAIL,'') = COALESCE(@ACC_EMAIL,ACC_EMAIL,'')
				AND ISNULL(Other_Email,'') = COALESCE(@O_Email,Other_Email,'')

				--Select @HR_Name
				--RETURN
				---ALTER dynamic template for Employee.				
				DECLARE @TableHead varchar(max),
						@TableTail varchar(max)   
           		SET @TableHead = '<html><head>' +
								  '<style>' +
								  'td {border: solid black 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:8pt;} ' +
								  '</style>' +
								  '</head>' +
								  '<body>
								  <div style=" font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">
								  Dear ' + @HR_Name + ' </div>	<br/>					
								  
								  <table width="800" border="0" align="center" cellpadding="0" cellspacing="0" style="border:1px solid #cacaca; border-radius: 10px 10px 10px 10px;" >
								  <tr>
									 <td align="center" valign="middle"><table width="800" border="0" cellspacing="0" cellpadding="0">
										<tr>
										<td height="9" align="center" valign="middle" ></td>
										</tr>
									  <tr>
										<td width="800" height="24" align="center" valign="middle" style="background:#0b0505; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">Employee Probation Over Reminder</td>
									  </tr>
										  <tr>
											<td height="4" align="center" valign="middle"></td>
										  </tr>
										  <tr>
											<td width="800" align="center" valign="middle" style="border:1px solid #cacaca; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#000000;  text-decoration:none; text-align:center; font-size:12px;">No Of Employee Probation Over : [ ' + CAST(@ECount AS VARCHAR(255)) + ' ] </td>
										  </tr>
										  <tr>
											<td height="8" align="center" valign="middle"></td>
										  </tr>
								  </table>
                                    
								  <table border="1" width="800" height="24" align="center" valign="middle" style="background: #FFFFF;border-color:solid black;
									border-radius: 10px 10px 10px 10px; font-family: Arial, Helvetica, sans-serif;
									color: #000000; text-decoration: none; font-weight: normal; text-align: left;
									font-size: 12px;">' +
										  '<tr border="1"><td align=center><span style="font-size:small"><b>Code</b></span></td>' +
										  '<td align=center><b><span style="font-size:small">Employee Name</span></b></td>' +
										  '<td align=center><b><span style="font-size:small">Branch Name</span></b></td>' +
										  '<td align=center><b><span style="font-size:small">Date of join</span></b></td>' +
										  '<td align=center><b><span style="font-size:small">Probation Period</span></b></td>' +
										  '<td align=center><b><span style="font-size:small">Probation End Date</span></b></td>' 
										 
										                                     
                  SET @TableTail = '</table></body></html>';                  	
                  DECLARE @Body AS VARCHAR(MAX)
                  SET @Body = ( SELECT  
										emp_Code  as [TD],
										Emp_name  as [TD],
										Isnull(Branch_Name,'-') as [TD],
										Left(Convert(varchar(25), Date_of_join,113),11) As [TD],
										Isnull(Probation_Period,'-') as [TD],
										Left(Convert(varchar(25), Probation_Date,113),11) As [TD]										
                                FROM    #Temp
                                WHERE   Cmp_ID = @Cmp_Id AND
										isnull(MANAGER_EMAIL,'') =  COALESCE(@MANAGER_EMAIL,MANAGER_EMAIL,'')
										AND IsNull(HR_EMAIL,'') =  COALESCE(@HR_EMAIL,HR_EMAIL, '')
										AND ISNULL(ACC_EMAIL,'') = COALESCE(@ACC_EMAIL,ACC_EMAIL,'')
										AND ISNULL(Other_Email,'') = COALESCE(@O_Email,Other_Email,'')
								 ORDER BY  RIGHT(REPLICATE(N' ', 500) + emp_Code, 500) For XML raw('tr'), ELEMENTS) 
                       
                  --select * from #Temp
                       --if (@HREmail_ID <> '')
                       -- BEGIN
                       --    EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Orange', @recipients = @HREmail_ID,  @subject = 'Leave Approval Reminder', @body = @Body, @body_format = 'HTML'                               
                           
                       -- END
					
           		--SELECT	@Body
				
           		  SELECT  @Body = @TableHead + @Body + @TableTail              		 	           			              
           		 --Select @Body
           		     Declare @profile as varchar(50)
       					  set @profile = ''
       					  
       					  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = @Cmp_Id
       					  
       					  if isnull(@profile,'') = ''
       					  begin
       					  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = 0
       					  end  	
--PRINT @CC_EMAIL_DETAIL
--PRINT @CC_EMAIL_DETAIL
--Print @TO_EMAIL_DETAIL
				EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @TO_EMAIL_DETAIL, @subject = 'Employee Probation Over ', @body = @Body, @body_format = 'HTML',@copy_recipients = @CC_EMAIL_DETAIL
				--EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Orange', @recipients = 'rohit@orangewebtech.com', @subject = 'Today''s Attendance', @body = @Body, @body_format = 'HTML',@copy_recipients = 'rohit@orangewebtech.com'
				
				--Set @HREmail_ID = ''
				Set @HR_Name = ''
				Set @ECount = 0
				
			fetch next from Cur_Company into @MANAGER_EMAIL,@HR_EMAIL,@ACC_EMAIL,@O_EMAIL,@Cmp_ID
		end                    
	close Cur_Company                    
	deallocate Cur_Company         

End


