
--exec InsertDefaultReminder
-- Created By Rohit on 12032015 for Insert Default Reminder List.
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- ===============================================================
CREATE PROCEDURE [dbo].[InsertDefaultReminder] 
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


		Declare @Reminder_Mail Table(Reminder_Id  numeric,Reminder_Name varchar(MAX),Reminder_Sp varchar(MAX),Discription varchar(MAX))

		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (1,'Daily Absent Reminder Branch Wise','SP_Employee_Daily_Absent_Reminder_Branch_Wise','Send Auto Daily Absent Mail Branch Wise to Manager')
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (2,'Pending Attendance Regularization Reminder to Manager','SP_Employee_Attendance_regularization_reminder','Send Auto Pending Attendance Regularization Reminder to Manager')
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (3,'Contract Employee Reminder to Hr','SP_Employee_Contract_Reminder','Send Auto Contract Employee Reminder to Hr')
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (4,'Daily Absent Employee Reminder to HR','SP_Employee_Daily_Absent_Reminder','Send Auto Daily Absent Employee Reminder to HR')
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (5,'Daily Absent Employee In Current Shift To HR','SP_Employee_Daily_Absent_Reminder_Shift_Wise','Send Auto Daily Absent Employee In Current Shift To HR')
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (6,'Daily Absent Employee In Current Shift To Manager and HR','SP_Employee_Daily_Absent_Reminder_Shift_Wise_ToManager','Send Auto Daily Absent Employee In Current Shift To Manager and HR')
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (7,'Daily Attendance to HR','SP_Employee_Daily_Attendance_Reminder','Send Auto Daily Attendance to HR')
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (8,'Daily Present Employee in Current Shift to Manager','SP_Employee_Daily_present_Reminder_Shift_Wise_ToManager','Send Auto Daily Present Employee in Current Shift to Manager')
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (9,'Daily Attendance In Current Shift to Manager','SP_Employee_Daily_Reminder_Shift_Wise_ToManager','Send Auto Daily Attendance In Current Shift to Manager')
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (10,'Pending Official Email Id to HR','SP_Employee_Email_ID_Reminder','Send Auto Pending Official Email Id to HR')
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (11,'Employee Increment to HR','SP_Employee_Increment_reminder','Send Auto Employee Increment to HR')
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (12,'Employee Monthly In Out Report To Employee','SP_Employee_Inout_Reminder','Send Auto Employee Monthly In Out Report To Employee')
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (13,'Employee Join Left On Yesterday','SP_Employee_Join_Left_Reminder','Send Auto Employee Join Left On Yesterday')
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (14,'Pending Leave Application Reminder to Manager and HR','SP_Employee_Leave_Reminder','Send Auto Pending Leave Application Reminder to Manager and HR')
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (15,'Probation Employee Detail to HR','SP_Employee_Probation_Reminder','Send Auto Probation Employee  Detail to HR')
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (16,'BirthDay mail to HR','SP_Employee_BirthDay_Reminder','Send Auto birthday Detail to HR')
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (17,'Auto Leave Carry Forward','CF_Auto_Utility_sp','Auto Leave Carry Forward Company Wise')
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (18,'Appraisal Approval Reminders','Appraisal_ApprovalReminder','Send Auto Reminders to Manager,HOD,GH') ---added on 03 Mar 2016 sneha
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (19,'Auto Database Backup','P_DB_BackUp_Reminder','Auto Database Backup')
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (20,'Continuous Absent Mail','P_Continous_Absent_Reminder','Auto mail for Continuous Absent')
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (21,'Odd Shift Details Mail','SP_RPT_ODD_SHIFT_REMINDER','Auto mail for Odd Shift Details')
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (22,'Resend Email Failed mail','SP_Send_Fail_Email_Job','Resend Email failed mail')
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (23,'Birthday SMS Notification','P_Birthday_Sms_reminder','Send Birthday Sms Notification to Employee.')
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (24,'Late Early detail to HR(Yesterday)','SP_Employee_Yesterday_Late_mark_reminder','Send late Employee detail to Hr(Yesterday)')
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (25,'Customized Inout Detail','P_Inout_Reminder_Consolidated','Send Customized Inout Detail')
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (26,'Last Absentieesm Reminder','LAST_ABSENTISM_REMINDER','To Send Reminder Email to HR and Employees who are Absent from Particular Days')
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (27,'Absconding Reminder','SP_ABSCONDING_REMINDER','To Send 3 Reminder Emails and then Left the Employee if Employee is Absent from Particular Days')
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (28,'Retirement Employee Detail Mail','SP_Employee_Retirement_Reminder','Send Retirement Employee Reminder Emails')  --Added by Jaina 20-06-2017
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (29,'Miss Punch Email Monthly','Monthly_Miss_Punch_Reminder','Send Email Miss Punch Email To Employee - Monthly')  --Added by Nilesh Patel 25072017
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (30,'Miss Punch Email Weekly','Weekly_Miss_Punch_Reminder','Send Email Miss Punch Email To Employee - Weekly')  --Added by Nilesh Patel 25072017
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (31,'Employee Wise Late Mark Adjust again Leave without Salary generation','SP_Late_Mark_Scenario_Adj_Leave','Employee Wise Late Mark Adjust again Leave without Salary generation')  --Added by Nilesh Patel 25072017
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (32,'Reminder for Document Expiry','SP_Document_Expiry_Reminder','To Send Reminder for Passprt/Visa/Licence Expiry details')  --Added by Mukti(17012018)
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (33,'Daily Absent Present Reminder Department Wise','SP_Employee_Daily_Absent_Reminder_Department_Wise','Send Auto Daily Absent Present Mail Department Wise to Manager')  --Added by Rajput on 05032018
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (34,'Appraisal Initition Reminder','SP_Appraisal_Initiate_Reminder','Send Auto Daily Reminder To Employee')  --Added by Mukti(21052018)
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (35,'Employee Experience Reminder','SP_Email_Notification_Experince_Wise','Remainder Employee Experience Wise')  --Added by Nilesh 
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (36,'Exit Clearance Reminder','P_Exit_Clearance_Reminder','Send Exit Clearance Reminder to Managers')  --Added by Mukti(09082018) 
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (37,'Self Assessment for Probation Reminder','P_Self_Assessment_Probation_Reminder','Send Self Assessment for Probation Reminder to Employee')--Added by Mukti(13092018) 
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (38,'Reminder for Interview Schedule','P_Interview_Schedule_Reminder','Send Reminder for Interview Schedule to Interviewer') --Mukti(14022019) 
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (39,'Send email notification to HR auto credited comp-off balance with employee details','AUTO_COMP_UTILITY_SP','if week-off and holiday on same date.Send email notification to HR auto credited comp-off balance with employee details') --Added By Nilesh Patel on 04-10-2019
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (40,'Employee Trainee Over Reminder','SP_Employee_Trainee_Reminder','Employee Trainee Over Reminder Details') --Added by Mukti(26082019)
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (41,'Exit Approval Escalation','P_Employee_Exit_Escalation','Employee Exit Approval Escalation') --Added by Mukti(30122019)
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (42,'Reminder for Recruitment Request Approval','P_Recruitment_Request_Approval_Reminder','Send Reminder for Recruitment Request Approval to scheme level manager') --Added by Mukti(02012020)
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (44,'Timesheet Reminder','SP_Timesheet_Reminder_OTL','To Send Timesheet Reminder to Employees') --Added by Mr.Mehul on 13022023
		insert into @Reminder_Mail (Reminder_Id,Reminder_Name,Reminder_Sp,Discription) values (45,'Employees Birthday','SP_Employee_BirthDay_Email','To Send Birthda Reminder to Employees') --Added by Mr.yogesh on 20022023
		
		
		DECLARE @Reminder_Name Nvarchar(max), 
				@Reminder_Sp NVARCHAR(MAX),
				@Discription Nvarchar(MAX)
				
		
		DECLARE L_Master CURSOR FOR SELECT Reminder_Name,Reminder_Sp,Discription FROM @Reminder_Mail
		OPEN L_Master
		FETCH NEXT FROM L_Master INTO @Reminder_Name,@Reminder_Sp,@Discription
		WHILE @@FETCH_STATUS = 0
		BEGIN

			DECLARE @CNT as int
			SET @CNT = 0
			SET @CNT = (Select COUNT(*) from t0298_reminder_Mail WITH (NOLOCK) WHERE UPPER(Reminder_Sp) = UPPER(@Reminder_Sp))
			IF @CNT = 0
			BEGIN
			   INSERT INTO t0298_reminder_Mail (Reminder_Name,Reminder_Sp,Discription) VALUES (@Reminder_Name, @Reminder_Sp,@Discription)
			END
		   FETCH NEXT FROM L_Master INTO @Reminder_Name, @Reminder_Sp,@Discription
		END

		CLOSE L_Master
		DEALLOCATE L_Master
END



