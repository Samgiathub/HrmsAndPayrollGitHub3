

--exec P0000_Default_Form_New 1
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0000_Default_Form_New_test]
  @ver_update as tinyint = 0
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON --Added by sumit as per nimesh bhai guideline



	-- pass @ver_update = 2 when you update version after this '17-sep-2013' date First time  else Pass parameter @ver_update = 1
	-- Created by rohit for Dynamic Menu from table on 17092013
	-- if you have any Query in add menu then please contact rohit
	-----Change the menu icon with passing Perameter by Sumit 19012015-------------------------------------------------------------------------------
	declare @Report_Img as varchar(50)
	set @Report_Img=N'menu/reports.gif'
	declare @Control_Pnl_Img as varchar(50)
	set @Control_Pnl_Img=N'menu/Control_Panel.gif'
	declare @Masters_Img as varchar(50)
	set @Masters_Img=N'menu/master.gif'
	declare @Employee_Img as varchar(50)
	set @Employee_Img=N'menu/employee.gif'
	declare @Leave_Img as varchar(50)
	set @Leave_Img=N'menu/leave.gif'
	declare @Loan_Claim_Img as varchar(50)
	--set @Loan_Claim_Img=N'menu/loan_claim.png'
	
	set @Loan_Claim_Img=N'menu/loan-claim.gif'
	--menu/loan-claim.gif
	declare @Salary_Img as varchar(50)
	set @Salary_Img=N'menu/salary.gif'
	declare @HR_Img as varchar(50)
	set @HR_Img=N'menu/hr.gif'
	declare @timesheet_img as varchar(50)
	set @timesheet_img=N'menu/timesheet.gif'
	declare @Recruitment_img as varchar(50)  --added on 3 fEB 2016 (start)
	set @Recruitment_img=N'menu/Recruitement.png'
	declare @Training_img as varchar(50)
	set @Training_img=N'menu/fix.gif'
	declare @Appraisal_img as varchar(50)
	set @Appraisal_img=N'menu/company_structure.gif'
	declare @HRDoc_img as varchar(50)
	set @HRDoc_img=N'menu/leave_management.gif'
	declare @Organogram_img as varchar(50)
	set @Organogram_img=N'menu/desig.png' --added on 3 FEB 2016 (end)
	DECLARE @SubmenuId numeric(18,0) -- added by Prakash Patel 03122015
	declare @Emp_Img as varchar(50)
	set @Emp_Img=N'menu/emp.png'
	


	---------Ended by sumit 19012015------------------------------------------------------------------------------------
	if @ver_update = 1
		begin
		
			declare @currDate as datetime
			Declare @Version_Id as numeric
			Declare @Version_No as nvarchar(30)
			declare @Database_Name as nvarchar(30)
			declare @Server_Name as nvarchar(30)
			
			select @Database_Name = DB_NAME()
			select @currDate = GETDATE()
			select @Server_Name = @@SERVERNAME
			SELECT @VERSION_ID  = ISNULL(MAX(VERSION_ID),0) + 1 FROM T0000_VERSION_INFO WITH (NOLOCK)
			--set @Version_No  = 'v1.' + cast(right(YEAR(@currDate),2) as nvarchar(2)) + '.' + cast(MONTH(@currDate) as nvarchar(2)) + '.0.' + cast(DAY(@currDate) as nvarchar(2))
			set @Version_No  = 'v1.20.0.03.20' -- V.1.Year.0.Month.Date
			
			
			
			INSERT INTO T0000_VERSION_INFO
								  (Version_Id, Version_No, Last_Update, Database_Name, Server_Name)
			VALUES     (@Version_Id,@Version_No,@currDate,@Database_Name,@Server_Name)	
			
			--- ADDED BY RAJPUT ON 24052019
			IF	EXISTS(	SELECT	1
						FROM	T0000_DEFAULT_FORM  WITH (NOLOCK)
						WHERE	FORM_NAME = 'IT Declaration' AND PAGE_FLAG = 'AP')
				BEGIN
				
					UPDATE 	T0000_DEFAULT_FORM
					SET		FORM_URL = '../admin_associates/IT_Declaration_With_Detail.aspx'
					WHERE	FORM_NAME = 'IT Declaration' AND PAGE_FLAG = 'AP'
					
				END
				
			IF	EXISTS(	SELECT	1
						FROM	T0000_DEFAULT_FORM WITH (NOLOCK)
						WHERE	FORM_NAME = 'IT Declaration Form' AND PAGE_FLAG = 'EP')
				BEGIN
				
					UPDATE 	T0000_DEFAULT_FORM
					SET		FORM_URL = 'IT_Declaration_User_With_Detail.aspx'
					WHERE	FORM_NAME = 'IT Declaration Form' AND PAGE_FLAG = 'EP'
					
				END
			--- END
		END

	
	if not exists (select res_id from t0040_reason_master WITH (NOLOCK) ) -- Changed By Gadriwala 09062014
		begin
		
			DELETE FROM T0040_REASON_MASTER 
			Insert into T0040_Reason_Master(Res_Id,Reason_Name,Type,isActive) values (1,'Forget To Punch/Sign In','R',1)
			Insert into T0040_Reason_Master(Res_Id,Reason_Name,Type,isActive) values (2,'Was In Training','R',1)
			Insert into T0040_Reason_Master(Res_Id,Reason_Name,Type,isActive) values (3,'Travel On Duty','R',1)
			Insert into T0040_Reason_Master(Res_Id,Reason_Name,Type,isActive) values (4,'Could Not Sign In','R',1)
			Insert into T0040_Reason_Master(Res_Id,Reason_Name,Type,isActive) values (5,'System Is Down/Networking','R',1)
			Insert into T0040_Reason_Master(Res_Id,Reason_Name,Type,isActive) values (6,'Working from Home (Temp)','R',1)
			Insert into T0040_Reason_Master(Res_Id,Reason_Name,Type,isActive) values (7,'Due employee Resigned','OT',1)	-- Added by Gadriwala 09052014
			Insert into T0040_Reason_Master(Res_Id,Reason_Name,Type,isActive) values (8,'Due to on leave','OT',1)	-- Added by Gadriwala 09052014

		end
		update T0040_REASON_MASTER set Type='R' where TYPE is null
		
		if not exists (select res_id from T0040_Reason_Master WITH (NOLOCK) where Reason_Name ='Due employee Resigned' and type='OT')
		begin 
			declare @type_Id_Max as integer
			select @type_Id_Max = MAX(isnull(res_id,0)) +1 from T0040_Reason_Master WITH (NOLOCK)
			Insert into T0040_Reason_Master(Res_Id,Reason_Name,Type,isActive) values (@type_Id_Max,'Due employee Resigned','OT',1)	-- Added by Gadriwala 09052014
				
		end
		if not exists (select res_id from T0040_Reason_Master WITH (NOLOCK) where Reason_Name ='Due to on leave' and type='OT')
		begin 
			declare @type_Id_Max1 as integer
			select @type_Id_Max1= MAX(isnull(res_id,0)) +1 from T0040_Reason_Master WITH (NOLOCK)
			Insert into T0040_Reason_Master(Res_Id,Reason_Name,Type,isActive) values (@type_Id_Max1,'Due to on leave','OT',1)	-- Added by Gadriwala 09052014
				
		end
	if exists (SELECT State_ID  FROM T0020_STATE_MASTER WITH (NOLOCK) WHERE Loc_ID IS NULL ) -- Added By Prakash Patel 12012015
		begin      
			update T0020_STATE_MASTER SET Loc_ID = 1 WHERE Loc_ID IS NULL 
		end
		---- Alpesh 10-May-2012
		Delete from T0040_CF_TYPE_MASTER

		Insert Into T0040_CF_TYPE_MASTER(CF_TYPE_ID,CF_TYPE_NAME,Status) values (1,'Present',1)
		Insert Into T0040_CF_TYPE_MASTER(CF_TYPE_ID,CF_TYPE_NAME,Status) values (2,'Fix',1)
		Insert Into T0040_CF_TYPE_MASTER(CF_TYPE_ID,CF_TYPE_NAME,Status) values (3,'Slab',1)
		Insert Into T0040_CF_TYPE_MASTER(CF_TYPE_ID,CF_TYPE_NAME,Status) values (4,'Flat',1)
		---- End ----


		-- Added by rohit on 12032015		
		-- Insert Default Locations in Location Master
		EXEC InsertDefaultLocations
		Exec P0030_InsertDocumentTypeMaster
		Exec P0030_InsertSourceTypeMaster
		EXEC InsertDefaultReminder
		Exec DefaultPayment_Process_Type
		-- Ended by rohit on 18032014
		EXEC InsertDefaultScheme --Mukti 02012016
		EXEC P0020_STATE_MASTER_DEFAULT 0 --Added By Mukti 21012016 passed 0 value for cmp_id to insert default entry for State 
		EXEC InsertDefault_perquisites  --Mukti 29032016
if @ver_update=2 
begin 
	DELETE FROM T0000_DEFAULT_FORM WHERE FORM_ID > 6000
	
--	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
--	-- Admin Side panel  form id between 6000 to 6500
--	VALUES (6001, N'Control Panel', -1, 1, 1, N'Home.aspx', N'menu/setting.gif', 1, N'Control Panel'),
--	(6002, N'Company Information', 6001, 2, 1, N'Home_Company_Update.aspx', N'menu/company_updates.gif', 1, N'Company Information'),
--	(6003, N'Change Password', 6001, 3, 1, N'Home_Change_Password.aspx', N'menu/general_setting.gif', 1, N'Change Password'),
--	(6004, N'Company General Setting', 6001, 4, 1, N'Home_General_Setting.aspx', N'menu/general_setting.gif', 1, N'Company General Setting'),
--	(6005, N'Professional Tax Setting', 6001, 5, 1, N'Home_PT_Master.aspx', N'menu/PT_Master.gif', 1, N'Professional Tax Setting'),
--	(6006, N'Privilege Master', 6001, 6, 1, N'Master_Privilege.aspx', N'menu/admin_rights.gif', 1, N'Privilege Master'),
--	(6007, N'Imports Data', 6001, 7, 1, N'Home_Import_Data.aspx', N'menu/import_master.gif', 1, N'Imports Data'),
--	(6008, N'Email Notification Setting', 6001, 8, 1, N'Home_Email_Notification.aspx', N'menu/email.gif', 0, N'Email Notification Setting'),
--	(6009, N'IP Address Master', 6001, 9, 1, N'Home_IP_Master.aspx', N'menu/IP_Master.gif', 1, N'IP Address Master'),
--	(6010, N'SMS Setting', 6001, 10, 1, N'Home_Sms_Setting.aspx', N'menu/IP_Master.gif', 1, N'SMS Setting'),
--	(6011, N'Scheme', 6001, 11, 0, N'#', N'menu/company_updates.gif', 1, N'Scheme'),
--	(6164, N'Scheme Master', 6011, 12, 0, N'Master_Scheme.aspx', N'menu/company_updates.gif', 1, N'Scheme Master'),
--	(6165, N'Scheme Detail', 6011, 13, 0, N'Scheme_Detail.aspx', N'menu/company_updates.gif', 1, N'Scheme Detail'),
	
--	(6012, N'Masters', -1, 15, 1, N'Home.aspx', N'menu/fix.gif', 1, N'Masters'),
--	(6013, N'Job Master', 6012, 16, 0, N'Home.aspx', N'menu/job_master.gif', 1, N'Job Master'),
--	(6014, N'Branch master', 6013, 20, 1, N'Master_Branch.aspx', N'menu/job_master.gif', 1, N'Branch Master'),
--	(6015, N'Grade Master', 6013, 18, 1, N'Master_Grade.aspx', N'menu/job_master.gif', 1, N'Grade Master'),
--	(6016, N'Department Master', 6013, 19, 1, N'Master_Department.aspx', N'menu/job_master.gif', 1, N'Department Master'),
--	(6017, N'Designation Master', 6013, 23, 1, N'Master_Designation.aspx', N'menu/job_master.gif', 1, N'Designation Master'),
--	(6018, N'Country Master', 6013, 21, 1, N'Master_Location.aspx', N'menu/job_master.gif', 1, N'Country Master'),
--	(6019, N'Shift Master', 6013, 22, 1, N'Master_Shift.aspx', N'menu/job_master.gif', 1, N'Shift Master'),
--	(6020, N'Project Master', 6013, 23, 1, N'Master_Project.aspx', N'menu/job_master.gif', 1, N'Project Master'),
--	(6021, N'State Master', 6013, 24, 1, N'Master_State.aspx', N'menu/job_master.gif', 1, N'State Master'),
--	(6022, N'Asset Master', 6013, 25, 1, N'Master_Asset.aspx', N'menu/job_master.gif', 1, N'Asset Master'),
--	(6023, N'Insurance Master', 6013, 26, 1, N'Master_Insurance.aspx', N'menu/job_master.gif', 1, N'Insurance Master'),
--	(6024, N'Category Master', 6013, 27, 1, N'Master_Category.aspx', N'menu/job_master.gif', 1, N'Category Master'),
--	(6025, N'Employee Type Master', 6013, 28, 1, N'Master_Employee_Status.aspx', N'menu/job_master.gif', 1, N'Employee Type Master'),
--	(6026, N'Cost Center Master', 6013, 29, 1, N'Master_CostCenter.aspx', N'menu/job_master.gif', 1, N'Cost Center Master'),
--	(6027, N'Company Structure', 6012, 35, 0, N'Home.aspx', N'menu/company_structure.gif', 1, N'Company Structure'),
--	(6028, N'Allowance Deduction Master', 6027, 36, 1, N'Master_Allowance_Deduction.aspx', N'menu/company_structure.gif', 1, N'Allowance Deduction Master'),
--	(6029, N'Present Late Scenario', 6027, 37, 1, N'Master_Present_Late_Scenario.aspx', N'menu/company_structure.gif', 1, N'Present Late Scenario'),
--	(6030, N'AD Slab Settings', 6027, 38, 1, N'AD_Slab_Setting.aspx', N'menu/company_structure.gif', 1, N'AD Slab Settings'),
--	(6031, N'Performance Master', 6027, 39, 1, N'Master_Performance_Incentive.aspx', N'menu/company_structure.gif', 1, N'Performance Master'),
--	(6032, N'Holiday Master', 6027, 40, 1, N'Master_Holiday.aspx', N'menu/company_structure.gif', 1, N'Holiday Master'),
--	(6033, N'WeekOff  Master', 6027, 41, 1, N'Master_Weekoff.aspx', N'menu/company_structure.gif', 1, N'WeekOff  Master'),
--	(6034, N'Warning Master', 6027, 42, 1, N'Master_Warning.aspx', N'menu/company_structure.gif', 1, N'Warning Master'),
--	(6035, N'Bank Master', 6027, 43, 1, N'Master_Bank.aspx', N'menu/company_structure.gif', 1, N'Bank Master'),
--	(6036, N'Qualification', 6012, 50, 0, N'Home.aspx', N'menu/qualification.gif', 1, N'Qualification'),
--	(6037, N'Qualification Master', 6036, 51, 1, N'Master_Qualification.aspx', N'menu/qualification.gif', 1, N'Qualification Master'),
--	(6038, N'Skill Master', 6036, 52, 1, N'../admin_associates/Master_skill.aspx', N'menu/qualification.gif', 1, N'Skill Master'),
--	(6039, N'License Master', 6036, 53, 1, N'Master_License.aspx', N'menu/qualification.gif', 1, N'License Master'),
--	(6040, N'Document Master', 6012, 57, 1, N'Master_Document.aspx', N'menu/fix.gif', 1, N'Document Master'),
--	(6041, N'Publish News Letters', 6012, 60, 1, N'Master_News_Letter.aspx', N'menu/fix.gif', 1, N'Publish News Letters'),
	
--	(6042, N'Employee', -1, 65, 1, N'Home.aspx', N'menu/info.gif', 1, N'Employee'),
--	(6043, N'Employee Master', 6042, 66, 1, N'Employee_Master.aspx', N'menu/info.gif', 1, N'Employee Master'),
--	(6044, N'Left Employee Details', 6042, 67, 1, N'Employee_Left.aspx', N'menu/info.gif', 1, N'Left Employee Details'),
--	(6045, N'Employee Increment', 6042, 68, 1, N'Employee_Increment.aspx', N'menu/info.gif', 1, N'Employee Increment'),
--	(6046, N'Employee Transfer', 6042, 69, 1, N'Employee_Transfer.aspx', N'menu/info.gif', 1, N'Employee Transfer'),
--	(6047, N'Gradewise Allowance', 6042, 70, 1, N'Employee_Gradewise_allowance.aspx', N'menu/info.gif', 1, N'Gradewise Allowance'),
--	(6048, N'Employee Weekoff', 6042, 71, 1, N'Employee_weekOff.aspx', N'menu/info.gif', 1, N'Employee Weekoff'),
--	(6049, N'Half Weekoff', 6042, 72, 1, N'Employee_Half_Weekoff.aspx', N'menu/info.gif', 1, N'Half Weekoff'),
--	(6050, N'Employee In Out', 6169, 73, 1, N'Employee_In_Out.aspx', N'menu/info.gif', 1, N'Employee In Out'),
--	(6157, N'Employee Default In out', 6169, 74, 1, N'Employee_In_Out_Daily.aspx', N'menu/info.gif', 1, N'Employee Default In out'),
--	(6051, N'Employee In Out Record', 6169, 74, 1, N'Employee_Inout_Record.aspx', N'menu/info.gif', 1, N'Employee In Out Record'),
--	(6052, N'Employee Shift Change', 6171, 76, 1, N'Employee_Shift_Change.aspx', N'menu/info.gif', 1, N'Employee Shift Change'),
--	(6053, N'Employee Shift Change Detail', 6171, 76, 1, N'Employee_Shift_Change_Details.aspx', N'menu/info.gif', 1, N'Employee Shift Change Detail'),
--	(6054, N'Employee Shift Rotation', 6171, 77, 1, N'Employee_Shift_Rotation.aspx', N'menu/info.gif', 1, N'Employee Shift Rotation'),
--	(6055, N'Warning Card Details', 6042, 78, 1, N'Employee_Warning.aspx', N'menu/info.gif', 1, N'Warning Card Details'),
--	(6056, N'Employee Privileges', 6042, 79, 1, N'Privilege_Employee.aspx', N'menu/info.gif', 1, N'Employee Privileges'),
--	(6156, N'Roster', 6042, 83, 1, N'Employee_Roster_WO_SH.aspx', N'menu/info.gif', 1, N'Roster'),
--	(6155, N'Optional Holiday Approval', 6042, 83, 1, N'Employee_OptionalHoliday_Approval.aspx', N'menu/info.gif', 1, N'Optional Holiday Approval'),
--	(6166, N'Salary Cycle Transfer', 6042, 83, 1, N'Employee_Salary_Cycle_Transfer.aspx', N'menu/info.gif', 1, N'Salary Cycle Transfer'),
--	(6167, N'Employee Schemes', 6042, 83, 1, N'Scheme_Employee.aspx', N'menu/info.gif', 1, N'Employee Schemes'),
--	(6169, N'Employee In-Out', 6042, 72, 1, N'Home.aspx', N'menu/info.gif', 1, N'Employee In-Out'),
--	(6171, N'Employee Shift', 6042, 75, 1, N'Home.aspx', N'menu/info.gif', 1, N'Employee Shift'),
	
	
--	(6057, N'Leave', -1, 85, 1, N'Home.aspx', N'menu/leave_management.gif', 1, N'Leave'),
--	(6058, N'Leave Master', 6057, 86, 1, N'Leave_Master.aspx', N'menu/leave_management.gif', 1, N'Leave Master'),
--	(6059, N'Leave Detail', 6057, 87, 1, N'Leave_Details.aspx', N'menu/leave_management.gif', 1, N'Leave Detail'),
--	(6060, N'Leave Opening', 6057, 88, 1, N'Leave_Opening.aspx', N'menu/leave_management.gif', 1, N'Leave Opening'),
--	(6061, N'Leave Application', 6057, 89, 1, N'Leave_application.aspx', N'menu/leave_management.gif', 1, N'Leave Application'),
--	(6062, N'Leave Approval', 6057, 90, 1, N'Leave_Approve.aspx', N'menu/leave_management.gif', 1, N'Leave Approval'),
--	(6063, N'Admin Leave Approval', 6057, 91, 1, N'Leave_Admin_Approve.aspx', N'menu/leave_management.gif', 1, N'Admin Leave Approval'),
--	(6064, N'Leave Updates', 6057, 92, 1, N'Leave_Update.aspx', N'menu/leave_management.gif', 1, N'Leave Updates'),
--	(6065, N'Leave Cancellation', 6057, 98, 1, N'Leave_Cancelation_Approval.aspx', N'menu/leave_management.gif', 1, N'Leave Cancellation'),
--	(6066, N'Leave Carry Forward', 6057, 94, 1, N'Leave_Carry_Forward.aspx', N'menu/leave_management.gif', 1, N'Leave Carry Forward'),
--	(6067, N'Leave Encash Approve', 6057, 95, 1, N'Leave_Encashment.aspx', N'menu/leave_management.gif', 1, N'Leave Encash Approve'),
--	(6068, N'Leave Direct Encash', 6057, 96, 1, N'Leave_Encashment_Approval.aspx', N'menu/leave_management.gif', 1, N'Leave Direct Encash'),
--	(6069, N'LeaveWise Encashment', 6057, 97, 1, N'Leave_Encashment_Leavewise.aspx', N'menu/leave_management.gif', 1, N'LeaveWise Encashment'),
--	(6070, N'Loan LIC Claim', -1, 103, 1, N'Home.aspx', N'menu/loan_claim.gif', 1, N'Loan/Claim'),
--	(6071, N'Loan LIC Details', 6070, 104, 0, N'Home.aspx', N'menu/loan_claim.gif', 1, N'Loan Details'),
--	(6072, N'Loan LIC Master', 6071, 105, 1, N'Loan_Master.aspx', N'menu/loan_claim.gif', 1, N'Loan Master'),
--	(6073, N'Loan LIC Application', 6071, 106, 1, N'Loan_Application.aspx', N'menu/loan_claim.gif', 1, N'Loan Application'),
--	(6074, N'Loan LIC Approval', 6071, 107, 1, N'Loan_Approve.aspx', N'menu/loan_claim.gif', 1, N'Loan Approval'),
--	(6075, N'Admin Loan LIC Approval', 6071, 108, 1, N'Loan_Approve_Admin.aspx', N'menu/loan_claim.gif', 1, N'Admin Loan Approval'),
--	(6076, N'Loan LIC Payment', 6071, 109, 1, N'Loan_Payment.aspx', N'menu/loan_claim.gif', 1, N'Loan Payment'),
--	(6077, N'Claim Details', 6070, 115, 0, N'Home.aspx', N'menu/claim.gif', 1, N'Claim Details'),
--	(6078, N'Claim Master', 6077, 116, 1, N'Master_Claim.aspx', N'menu/claim.gif', 1, N'Claim Master'),
--	(6079, N'Claim Application', 6077, 117, 1, N'Claim_Admin_Application.aspx', N'menu/claim.gif', 1, N'Claim Application'),
--	(6080, N'Claim Approval', 6077, 118, 1, N'Claim_Admin_Approval.aspx', N'menu/claim.gif', 1, N'Claim Approval'),
--	(6081, N'Claim Payment', 6077, 119, 1, N'Claim_Admin_Payment.aspx', N'menu/claim.gif', 1, N'Claim Payment'),
	
--	(6082, N'LTA Medical Details', 6070, 123, 0, NULL, NULL, 0, N'LTA Medical Details'),
--	(6083, N'LTA Medical Setting Master', 6082, 124, 1, NULL, NULL, 0, N'LTA Medical Setting Master'),
--	(6084, N'Employee LTA Medical Detail', 6082, 125, 1, NULL, NULL, 0, N'Employee LTA Medical Detail'),
--	(6085, N'LTA Medical Application  Approval', 6082, 126, 1, NULL, NULL, 0, N'LTA Medical Application  Approval'),
--	(6086, N'LTA Medical Payment', 6082, 127, 1, NULL, NULL, 0, N'LTA Medical Payment'),
--	(6087, N'LTA Medical History', 6082, 128, 1, NULL, NULL, 0, N'LTA Medical History'),
--	(6088, N'Salary Details', -1, 135, 1, N'Home.aspx', N'menu/rupee.gif', 1, N'Salary Details'),
--	(6089, N'OT Approval', 6088, 136, 1, N'Salary_Daily_OT.aspx', N'menu/rupee.gif', 1, N'OT Approval'),
--	(6091, N'Bonus Detail', 6088, 138, 1, N'Salary_Bonus_Detail.aspx', N'menu/rupee.gif', 1, N'Bonus Detail'),
--	(6092, N'Performance Detail', 6088, 139, 1, N'Salary_Employee_Performance.aspx', N'menu/rupee.gif', 1, N'Performance Detail'),
--	(6093, N'Advance', 6088, 140, 0, N'Home.aspx', N'menu/rupee.gif', 1, N'Advance'),
--	(6168, N'Reverse Salary', 6088, 141, 1, N'Reverse_Salary_Calculation.aspx', N'menu/rupee.gif', 1, N'Reverse Salary'),
--	(6094, N'Monthly Salary', 6170, 143, 1, N'Salary_Monthly.aspx', N'menu/rupee.gif', 1, N'Monthly Salary'),
--	(6095, N'Manually Salary', 6170, 143, 1, N'Salary_Manually.aspx', N'menu/rupee.gif', 1, N'Manually Salary'),
--	(6096, N'Salary Daily', 6170, 143, 1, N'Salary_Daily_Wages.aspx', N'menu/rupee.gif', 1, N'Salary Daily'),
--	(6097, N'Salary Settlement', 6088, 144, 1, N'Salary_settlement.aspx', N'menu/rupee.gif', 1, N'Salary Settlement'),
--	(6098, N'F F Settlement', 6088, 145, 1, N'Salary_Final_Settlement.aspx', N'menu/rupee.gif', 1, N'F F Settlement'),
--	(6099, N'Gratuity Detail', 6088, 146, 1, N'Salary_Gratuity_Detail.aspx', N'menu/rupee.gif', 1, N'Gratuity Detail'),
--	(6100, N'TDS', 6088, 150, 0, N'Home.aspx', N'menu/rupee.gif', 1, N'TDS'),
--	(6101, N'IT Master', 6100, 151, 1, N'IT_Master1.aspx', N'menu/rupee.gif', 1, N'IT Master'),

--	(6102, N'IT Declaration', 6100, 152, 1, N'../admin_associates/IT_Declaration.aspx', N'menu/rupee.gif', 1, N'IT Declaration'),
--	(6103, N'IT Limit', 6100, 153, 1, N'../admin_associates/IT_Limit.aspx', N'menu/rupee.gif', 1, N'IT Limit'),
--	(6104, N'IT Form Design', 6100, 154, 1, N'IT_Form_Desing.aspx', N'menu/rupee.gif', 1, N'IT Form Design'),
--	(6105, N'IT Employee Perquisites', 6100, 155, 1, N'Employee_Perquisites.aspx', N'menu/rupee.gif', 1, N'IT Employee Perquisites'),
--	(6106, N'IT Tax Planning', 6100, 156, 1, N'IT_Tax_Planning.aspx', N'menu/rupee.gif', 1, N'IT Tax Planning'),
--	(6107, N'Challan', 6088, 160, 0, N'Home.aspx', N'menu/rupee.gif', 1, N'Challan'),
--	(6108, N'PF Challan', 6107, 161, 1, N'Salary_PF_Challan.aspx', N'menu/rupee.gif', 1, N'PF Challan'),
--	(6111, N'ESIC Challan', 6107, 166, 1, N'Salary_ESIC_Challan.aspx', N'menu/rupee.gif', 1, N'ESIC Challan'),
--	(6112, N'ESIC Challan Sett', 6107, 167, 1, N'Salary_ESIC_Challan_Sett.aspx', N'menu/rupee.gif', 1, N'ESIC Challan Sett'),
--	(6170, N'Salary', 6088, 142, 1, N'Home.aspx', N'menu/rupee.gif', 1, N'Salary'),

--	(6126, N'HR Management', -1, 200, 1, N'../HRMS/HR_Home.aspx', N'menu/process.png', 1, N'HR Management'),
	
--	(6127, N'Reporting Manager', 6042, 80, 1, N'Assign_Reporting_Manager.aspx', N'menu/info.gif', 1, N'Reporting Manager'),
--	(6128, N'Payment Process', 6088, 147, 1, N'Payment_Process.aspx', N'menu/rupee.gif', 1, N'Payment Process'),
--	(6129, N'Month Lock', 6088, 148, 1, N'Salary_Lock.aspx', N'menu/rupee.gif', 1, N'Month Lock'),
--	(6130, N'Leave Cancellation Application', 6065, 98, 1, N'Leave_Cancellation_Application.aspx', N'menu/leave_management.gif', 1, N'Leave Cancellation Application'),
--	(6131, N'Leave Cancellation Approval', 6065, 98, 1, N'Leave_Cancelation_Approval.aspx', N'menu/leave_management.gif', 1, N'Leave Cancellation Approval'),
--	(6132, N'Leave Cancellation View Delete', 6065, 98, 1, N'Leave_Cancelation_Status.aspx', N'menu/leave_management.gif', 1, N'Leave Cancellation View Delete'),
--	(6133, N'Comp Off', 6057, 98, 1, N'Home.aspx', N'menu/leave_management.gif', 1, N'Comp Off'),
--	(6134, N'comp off Application', 6133, 98, 1, N'CompOff_Application.aspx', N'menu/leave_management.gif', 1, N'comp off Application'),
--	(6135, N'comp off Approval', 6133, 98, 1, N'CompOff_Approval.aspx', N'menu/leave_management.gif', 1, N'comp off Approval'),
--	(6136, N'TDS Challan', 6107, 168, 1, N'Salary_TDS_Challan.aspx', N'menu/rupee.gif', 1, N'TDS Challan'),
--	(6137, N'Question Master', 6013, 30, 1, N'Question_Master.aspx', N'menu/job_master.gif', 1, N'Question Master'),
--	(6138, N'Exit Application', 6148, 82, 1, N'Admin_ExitApplication.aspx', N'menu/info.gif', 1, N'Exit Application'),
--	(6139, N'Exit Interview', 6148, 82, 1, N'Admin_ExitInterview.aspx', N'menu/info.gif', 1, N'Exit Interview'),
--	(6140, N'Exit Status', 6148, 82, 1, N'Exit_ApplicationStatus.aspx', N'menu/info.gif', 1, N'Exit Status'),
	
--	(6142, N'Attendance Reason Master', 6013, 31, 1, N'Master_Reason.aspx', N'menu/job_master.gif', 1, N'Attendance Reason Master'),
--	(6143, N'Travel Approval', 6151, 122, 1, N'Travel_Approval.aspx', N'menu/claim.gif', 1, N'Travel Approval'),
--	(6144, N'Policy Document Master', 6013, 32, 1, N'Policy_Document.aspx', N'menu/job_master.gif', 1, N'Policy Document Master'),
--	(6145, N'IT Acknowledgement', 6100, 157, 1, N'Tds_AcknowledgeNo.aspx', N'menu/rupee.gif', 1, N'IT Acknowledgement'),
--	(6146, N'Salary Advance Approval', 6093, 140, 1, N'Salary_Advance_Approval.aspx', N'menu/rupee.gif', 1, N'Salary Advance Approval'),
--	(6147, N'Admin Advance Approval', 6093, 140, 1, N'Salary_Advance.aspx', N'menu/rupee.gif', 1, N'Admin Advance Approval'),
--	(6148, N'Exit', 6042, 81, 1, N'Home.aspx', N'menu/info.gif', 1, N'Exit'),
--	(6149, N'Travel Settlement Approval', 6151, 123, 1, N'TravelSettlement_Approval.aspx', N'menu/claim.gif', 1, N'Travel Settlement Approval'),
--	(6150, N'Expense Type Master', 6013, 33, 1, N'Master_Expense_Type.aspx', N'menu/job_master.gif', 1, N'Expense Type Master'),
--	(6151, N'Travel', 6070, 119, 1, N'Home.aspx', N'menu/claim.gif', 1, N'Travel'),
--	(6152, N'Travel Settlement Application', 6151, 121, 1, N'TravelSettlement.aspx', N'menu/claim.gif', 1, N'Travel Settlement Application'),
--	(6153, N'Travel Applications', 6151, 120, 1, N'Travel_Applications.aspx', N'menu/claim.gif', 1, N'Travel Applications'),

--	(6154, N'PT Challan', 6107, 169, 1, N'Salary_PT_Chalan.aspx', N'menu/rupee.gif', 1, N'PT Challan'),
	
	
--	(6158, N'SubVertical Master', 6013, 34, 1, N'Master_SubVertical.aspx', N'menu/job_master.gif', 1, N'SubVertical Master'),
--	(6159, N'Sub Branch Master', 6013, 17, 1, N'Master_SubBranch.aspx', N'menu/job_master.gif', 1, N'Sub Branch Master'),
--	(6160, N'Salary Cycle Master', 6013, 34, 1, N'Master_Salary_Cycle.aspx', N'menu/job_master.gif', 1, N'Salary Cycle Master'),
--	(6161, N'Business Segment Master', 6013, 34, 1, N'Master_Business_Segment.aspx', N'menu/job_master.gif', 1, N'Business Segment Master'),
--	(6162, N'Vertical Master', 6013, 34, 1, N'Master_Vertical.aspx', N'menu/job_master.gif', 1, N'Vertical Master'),
--	(6163, N'Reports', -1, 170, 1, N'../Reports/Report_Employee_List.aspx', N'menu/file.gif', 1, N'Reports'),
	

--	-- HRMS SIDE Panel  form id between 6500 to 6699
--	(6500, N'HRMS Home', -1, 201, 1, NULL, NULL, 1, N'HRMS Home'),
--	(6501, N'Recruitment Panel', -1, 202, 1, NULL, NULL, 1, N'Recruitment Panel'),
--	(6502, N'Recruitment Process Master', 6501, 203, 1, NULL, NULL, 1, N'Recruitment Process Master'),
--	(6503, N'Recruitment Application', 6501, 203, 1, NULL, NULL, 1, N'Recruitment Application'),
--	(6504, N'Recruitment Posted Detail', 6501, 203, 1, NULL, NULL, 1, N'Recruitment Posted Detail'),
--	(6505, N'Resume Import', 6501, 203, 1, NULL, NULL, 1, N'Resume Import'),
--	(6506, N'Posted Resume Collection', 6501, 203, 1, NULL, NULL, 1, N'Posted Resume Collection'),
--	(6507, N'Candidates Detail', 6501, 203, 1, NULL, NULL, 1, N'Candidates Detail'),
--	(6508, N'Candidates Finalization Detail', 6501, 203, 1, NULL, NULL, 1, N'Candidates Finalization Detail'),
--	(6509, N'Training', -1, 206, 1, NULL, NULL, 1, N'Training'),
--	(6510, N'Training Master', 6509, 207, 1, NULL, NULL, 1, N'Training Master'),
--	(6511, N'Training Provider', 6509, 208, 1, NULL, NULL, 1, N'Training Provider'),
--	(6512, N'Training Plan', 6509, 209, 1, NULL, NULL, 1, N'Training Plan'),
--	(6513, N'Training Calendar', 6509, 210, 1, NULL, NULL, 1, N'Training Calendar'),
--	(6514, N'Training Approval', 6509, 211, 1, NULL, NULL, 1, N'Training Approval'),
--	(6515, N'Training Feedback', 6509, 212, 1, NULL, NULL, 1, N'Training Feedback'),
--	(6516, N'Training History', 6509, 213, 1, NULL, NULL, 1, N'Training History'),
--	(6517, N'Training Questionnaire', 6509, 214, 1, NULL, NULL, 1, N'Training Questionnaire'),
--	(6518, N'Appraisal', -1, 218, 1, NULL, NULL, 1, N'Appraisal'),
--	(6519, N'Rating Master', 6518, 219, 1, NULL, NULL, 1, N'Rating Master'),
--	(6520, N'Goal Master', 6518, 220, 1, NULL, NULL, 1, N'Goal Master'),
--	(6521, N'Appraisal General Setting', 6518, 221, 1, NULL, NULL, 1, N'Appraisal General Setting'),
--	(6522, N'Skill General Setting', 6518, 222, 1, NULL, NULL, 1, N'Skill General Setting'),
--	(6523, N'Assign Goal', 6518, 223, 1, NULL, NULL, 1, N'Assign Goal'),
--	(6524, N'Employee Skill Rating', 6518, 224, 1, NULL, NULL, 1, N'Employee Skill Rating'),
--	(6525, N'Initiate Appraisal', 6518, 225, 1, NULL, NULL, 1, N'Initiate Appraisal'),
--	(6526, N'Appraisal Approval', 6518, 226, 1, NULL, NULL, 1, N'Appraisal Approval'),
--	(6527, N'Initiate Appraisal Report', 6518, 227, 1, NULL, NULL, 1, N'Initiate Appraisal Report'),
--	(6528, N'Performance Appraisal', -1, 230, 1, NULL, NULL, 1, N'Performance Appraisal'),
--	(6529, N'Performance Rating Master', 6528, 231, 1, NULL, NULL, 1, N'Performance Rating Master'),
--	(6530, N'GoalType Master', 6528, 232, 1, NULL, NULL, 1, N'GoalType Master'),
--	(6531, N'Competency Master', 6528, 233, 1, NULL, NULL, 1, N'Competency Master'),
--	(6532, N'Setting Master', 6528, 234, 1, NULL, NULL, 1, N'Setting Master'),
--	(6533, N'Review Employee Goal', 6528, 235, 1, NULL, NULL, 1, N'Review Employee Goal'),
--	(6534, N'Review Performance Summary', 6528, 236, 1, NULL, NULL, 1, N'Review Performance Summary'),
--	(6535, N'Review Competency', 6528, 237, 1, NULL, NULL, 1, N'Review Competency'),
--	(6536, N'HR Documents', -1, 240, 1, NULL, NULL, 1, N'HR Documents'),
--	(6537, N'HR Document Master', 6536, 241, 1, NULL, NULL, 1, N'HR Document Master'),
--	(6538, N'Export Employee Document', 6536, 242, 1, NULL, NULL, 1, N'Export Employee Document'),
--	(6539, N'Employee Document History', 6536, 243, 1, NULL, NULL, 1, N'Employee Document History'),
--	(6540, N'Organogram', -1, 245, 1, NULL, NULL, 1, N'Organogram'),
--	(6541, N'Organization Organogram', 6540, 246, 1, NULL, NULL, 1, N'Organization Organogram'),
--	(6542, N'Employee Organogram', 6540, 247, 1, NULL, NULL, 1, N'Employee Organogram'),
--	(6543, N'Finalize Candidate', 6501, 203, 1, NULL, NULL, 1, N'Finalize Candidate'),
--	(6544, N'Candidate For Offer', 6501, 203, 1, NULL, NULL, 1, N'Candidate For Offer'),
--	(6545, N'Candidates OnBoard', 6501, 203, 1, NULL, NULL, 1, N'Candidates OnBoard'),
	

---- Admin Side report Form id from 6700 to 6999
--	(6701, N'Employee Reports', 6163, 171, 1, NULL, NULL, 1, N'Employee Reports'),
--	(6702, N'Attendance Reports', 6163, 173, 1, NULL, NULL, 1, N'Attendance Reports'),
--	(6703, N'Leave Reports', 6163, 175, 1, NULL, NULL, 1, N'Leave Reports'),
--	(6704, N'Loan LIC Reports', 6163, 177, 1, NULL, NULL, 1, N'Loan Reports'),
--	(6705, N'Salary Reports', 6163, 179, 1, NULL, NULL, 1, N'Salary Reports'),
--	(6706, N'PF Reports', 6163, 181, 1, NULL, NULL, 1, N'PF Reports'),
--	(6707, N'ESIC Reports', 6163, 183, 1, NULL, NULL, 1, N'ESIC Reports'),
--	(6708, N'PT Reports', 6163, 185, 1, NULL, NULL, 1, N'PT Reports'),
--	(6709, N'Letters', 6163, 187, 1, NULL, NULL, 1, N'Letters'),
--	(6710, N'TAX Reports', 6163, 189, 1, NULL, NULL, 1, N'TAX Reports'),
--	(6711, N'Gratuity Bonus HRIS', 6163, 191, 1, NULL, NULL, 1, N'Gratuity Bonus HRIS'),
--	(6712, N'Other Reports', 6163, 193, 1, NULL, NULL, 1, N'Other Reports'),
--	(6713, N'Gratuity Report', 6163, 195, 1, NULL, NULL, 1, N'Gratuity Report'),
	
	
--	(6714, N'Customize Report', 6701, 172, 1, NULL, NULL, 1, N'Customize Report'),
--	(6715, N'Employee List(Form-13)', 6701, 172, 1, NULL, NULL, 1, N'Employee List(Form-13)'),
--	(6716, N'Employee CTC', 6701, 172, 1, NULL, NULL, 1, N'Employee CTC'),
--	(6717, N'Left Employee', 6701, 172, 1, NULL, NULL, 1, N'Left Employee'),
--	(6718, N'Shift Report', 6701, 172, 1, NULL, NULL, 1, N'Shift Report'),
--	(6719, N'Weekly Off', 6701, 172, 1, NULL, NULL, 1, N'Weekly Off'),
--	(6720, N'Employee Warning', 6701, 172, 1, NULL, NULL, 1, N'Employee Warning'),
--	(6721, N'Employee Insurance2', 6701, 172, 1, NULL, NULL, 1, N'Employee Insurance2'),
--	(6722, N'Asset Position', 6701, 172, 1, NULL, NULL, 1, N'Asset Position'),
--	(6723, N'Employee Salary Structure', 6701, 172, 1, NULL, NULL, 1, N'Employee Salary Structure'),
--	(6724, N'Employee Birthday List', 6701, 172, 1, NULL, NULL, 1, N'Employee Birthday List'),
--	(6725, N'Active/InActive User History', 6701, 172, 1, NULL, NULL, 1, N'Active/InActive User History'),
	
--	(6726, N'Attendance Register', 6702, 174, 1, NULL, NULL, 1, N'Attendance Register'),
--	(6727, N'In-Out Register', 6702, 174, 1, NULL, NULL, 1, N'In-Out Register'),
--	(6728, N'Holiday Work', 6702, 174, 1, NULL, NULL, 1, N'Holiday Work'),
--	(6729, N'In-Out Summary ', 6702, 174, 1, NULL, NULL, 1, N'In-Out Summary '),
--	(6730, N'Missing In-out', 6702, 174, 1, NULL, NULL, 1, N'Missing In-out'),
--	(6731, N'Late/Early Mark Summary', 6702, 174, 1, NULL, NULL, 1, N'Late/Early Mark Summary'),
--	(6732, N'Device Inout Summary', 6702, 174, 1, NULL, NULL, 1, N'Device Inout Summary'),
--	(6733, N'Employee Inout Present Days', 6702, 174, 1, NULL, NULL, 1, N'Employee Inout Present Days'),
--	(6734, N'Daily Attendance', 6702, 174, 1, NULL, NULL, 1, N'Daily Attendance'),
--	(6735, N'Login History', 6702, 174, 1, NULL, NULL, 1, N'Login History'),
--	(6736, N'Absent', 6702, 174, 1, NULL, NULL, 1, N'Absent'),
--	(6737, N'Attendance Regularization', 6702, 174, 1, NULL, NULL, 1, N'Attendance Regularization'),
	
--	(6738, N'Leave Approval', 6703, 176, 1, NULL, NULL, 1, N'Leave Approval'),
--	(6739, N'Leave Balance', 6703, 176, 1, NULL, NULL, 1, N'Leave Balance'),
--	(6740, N'Leave Closing', 6703, 176, 1, NULL, NULL, 1, N'Leave Closing'),
--	(6741, N'Yearly Leave Summary', 6703, 176, 1, NULL, NULL, 1, N'Yearly Leave Summary'),
--	(6742, N'Yearly Leave Transaction ', 6703, 176, 1, NULL, NULL, 1, N'Yearly Leave Transaction '),
--	(6743, N'Leave Encash', 6703, 176, 1, NULL, NULL, 1, N'Leave Encash'),
--	(6744, N'Leave Register with wages', 6703, 176, 1, NULL, NULL, 1, N'Leave Register with wages'),
--	(6745, N'Leave Card (Form-19)', 6703, 176, 1, NULL, NULL, 1, N'Leave Card (Form-19)'),
	
--	(6746, N'Monthly Loan Payment', 6704, 178, 1, NULL, NULL, 1, N'Monthly Loan Payment'),
--	(6747, N'Loan Approval', 6704, 178, 1, NULL, NULL, 1, N'Loan Approval'),
--	(6748, N'Loan Number', 6704, 178, 1, NULL, NULL, 1, N'Loan Number'),
--	(6749, N'Loan Statement Report', 6704, 178, 1, NULL, NULL, 1, N'Loan Statement Report'),
	
--	(6750, N'Salary Slip Weekly Basis', 6705, 180, 1, NULL, NULL, 1, N'Salary Slip Weekly Basis'),
--	(6751, N'Salary Register Daily Basis', 6705, 180, 1, NULL, NULL, 1, N'Salary Register Daily Basis'),
--	(6752, N'Salary Register(Allo/Ded)', 6705, 180, 1, NULL, NULL, 1, N'Salary Register(Allo/Ded)'),
--	(6753, N'Register With Settlement', 6705, 180, 1, NULL, NULL, 1, N'Register With Settlement'),
--	(6754, N'Allowance/Deduction Report', 6705, 180, 1, NULL, NULL, 1, N'Allowance/Deduction Report'),
--	(6755, N'Yearly Salary', 6705, 180, 1, NULL, NULL, 1, N'Yearly Salary'),
--	(6756, N'Yearly Advance', 6705, 180, 1, NULL, NULL, 1, N'Yearly Advance'),
--	(6757, N'Yearly Attandance ', 6705, 180, 1, NULL, NULL, 1, N'Yearly Attandance '),
--	(6758, N'Pending Advance', 6705, 180, 1, NULL, NULL, 1, N'Pending Advance'),
--	(6759, N'Employee Overtime', 6705, 180, 1, NULL, NULL, 1, N'Employee Overtime'),
--	(6760, N'Employee Daily Overtime ', 6705, 180, 1, NULL, NULL, 1, N'Employee Daily Overtime '),
--	(6761, N'Bank Statement', 6705, 180, 1, NULL, NULL, 1, N'Bank Statement'),
--	(6762, N'Allowance Export', 6705, 180, 1, NULL, NULL, 1, N'Allowance Export'),
	
--	(6763, N'PF Statement', 6706, 182, 1, NULL, NULL, 1, N'PF Statement'),
--	(6764, N'PF Statement Sett', 6706, 182, 1, NULL, NULL, 1, N'PF Statement Sett'),
--	(6765, N'PF Challan', 6706, 182, 1, NULL, NULL, 1, N'PF Challan'),
--	(6766, N'PF Challan Sett', 6706, 182, 1, NULL, NULL, 1, N'PF Challan Sett'),
--	(6767, N'Form2', 6706, 182, 1, NULL, NULL, 1, N'Form2'),
--	(6768, N'Form05', 6706, 182, 1, NULL, NULL, 1, N'Form05'),
--	(6769, N'Form10', 6706, 182, 1, NULL, NULL, 1, N'Form10'),
--	(6770, N'Form12A', 6706, 182, 1, NULL, NULL, 1, N'Form12A'),
--	(6771, N'Form3A-Yearly', 6706, 182, 1, NULL, NULL, 1, N'Form3A-Yearly'),
--	(6772, N'Form6A-Yearly', 6706, 182, 1, NULL, NULL, 1, N'Form6A-Yearly'),
--	(6773, N'Form13 (Revised)', 6706, 182, 1, NULL, NULL, 1, N'Form13 (Revised)'),
--	(6774, N'PF Employer Contribution', 6706, 182, 1, NULL, NULL, 1, N'PF Employer Contribution'),
--	(6775, N'PF Statement for Inspection', 6706, 182, 1, NULL, NULL, 1, N'PF Statement for Inspection'),
--	(6776, N'Employee Pension Scheme-10C ', 6706, 182, 1, NULL, NULL, 1, N'Employee Pension Scheme-10C '),
--	(6777, N'Employee Pension Scheme-10D', 6706, 182, 1, NULL, NULL, 1, N'Employee Pension Scheme-10D'),
--	(6778, N'PF FORM 11', 6706, 182, 1, NULL, NULL, 1, N'PF FORM 11'),
--	(6779, N'PF FORM 19 ', 6706, 182, 1, NULL, NULL, 1, N'PF FORM 19 '),
--	(6780, N'PF FORM 20 ', 6706, 182, 1, NULL, NULL, 1, N'PF FORM 20 '),
	
--	(6781, N'ESIC Statement', 6707, 184, 1, NULL, NULL, 1, N'ESIC Statement'),
--	(6782, N'ESIC Challan', 6707, 184, 1, NULL, NULL, 1, N'ESIC Challan'),
--	(6783, N'Form 1(Declaration)', 6707, 184, 1, NULL, NULL, 1, N'Form 1(Declaration)'),
--	(6784, N'Form 3', 6707, 184, 1, NULL, NULL, 1, N'Form 3'),
--	(6785, N'Form 5', 6707, 184, 1, NULL, NULL, 1, N'Form 5'),
--	(6786, N'Form 6', 6707, 184, 1, NULL, NULL, 1, N'Form 6'),
--	(6787, N'Form 7', 6707, 184, 1, NULL, NULL, 1, N'Form 7'),
--	(6788, N'ESIC Challan Sett', 6707, 184, 1, NULL, NULL, 1, N'ESIC Challan Sett'),
--	(6789, N'ESIC Statement Sett', 6707, 184, 1, NULL, NULL, 1, N'ESIC Statement Sett'),
--	(6790, N'ESIC Employer', 6707, 184, 1, NULL, NULL, 1, N'ESIC Employer'),
	
--	(6791, N'PT Challan', 6708, 186, 1, NULL, NULL, 1, N'PT Challan'),
--	(6792, N'PT Statement', 6708, 186, 1, NULL, NULL, 1, N'PT Statement'),
--	(6793, N'PT Statement Sett', 6708, 186, 1, NULL, NULL, 1, N'PT Statement Sett'),
--	(6794, N'PT Form5', 6708, 186, 1, NULL, NULL, 1, N'PT Form5'),
--	(6795, N'PT Form5A', 6708, 186, 1, NULL, NULL, 1, N'PT Form5A'),
--	(6796, N'LWF Statement FORM A', 6708, 186, 1, NULL, NULL, 1, N'LWF Statement FORM A'),
--	(6797, N'Form 9-A', 6708, 186, 1, NULL, NULL, 1, N'Form 9-A'),
	
--	(6798, N'Offer Letter', 6709, 188, 1, NULL, NULL, 1, N'Offer Letter'),
--	(6799, N'Appoint Letter', 6709, 188, 1, NULL, NULL, 1, N'Appoint Letter'),
--	(6800, N'Resignation Letter', 6709, 188, 1, NULL, NULL, 1, N'Resignation Letter'),
--	(6801, N'Joining Letter', 6709, 188, 1, NULL, NULL, 1, N'Joining Letter'),
--	(6802, N'Confirmation Letter', 6709, 188, 1, NULL, NULL, 1, N'Confirmation Letter'),
--	(6803, N'Experience Letter', 6709, 188, 1, NULL, NULL, 1, N'Experience Letter'),
--	(6804, N'Reliever Letter', 6709, 188, 1, NULL, NULL, 1, N'Reliever Letter'),
--	(6805, N'Termination Letter', 6709, 188, 1, NULL, NULL, 1, N'Termination Letter'),
--	(6806, N'F & F Letter', 6709, 188, 1, NULL, NULL, 1, N'F & F Letter'),
--	(6807, N'Increment Letter', 6709, 188, 1, NULL, NULL, 1, N'Increment Letter'),
--	(6808, N'Forwarding Letter', 6709, 188, 1, NULL, NULL, 1, N'Forwarding Letter'),

--	(6809, N'Income Tax Declaration', 6710, 190, 1, NULL, NULL, 1, N'Income Tax Declaration'),
--	(6810, N'Tax Computation', 6710, 190, 1, NULL, NULL, 1, N'Tax Computation'),
--	(6811, N'Form -16(IT)', 6710, 190, 1, NULL, NULL, 1, N'Form -16(IT)'),
--	(6812, N'Employee Tax Report', 6710, 190, 1, NULL, NULL, 1, N'Employee Tax Report'),
--	(6813, N'TDS Challan', 6710, 190, 1, NULL, NULL, 1, N'TDS Challan'),
	
--	(6814, N'Bonus Statement', 6711, 192, 1, NULL, NULL, 1, N'Bonus Statement'),
--	(6815, N'Bonus(Form C)', 6711, 192, 1, NULL, NULL, 1, N'Bonus(Form C)'),
--	(6816, N'Employee Status', 6711, 192, 1, NULL, NULL, 1, N'Employee Status'),
--	(6817, N'Employee Strength', 6711, 192, 1, NULL, NULL, 1, N'Employee Strength'),
--	(6818, N'Employee Variance Report', 6711, 192, 1, NULL, NULL, 1, N'Employee Variance Report'),
--	(6819, N'Salary Variance Report', 6711, 192, 1, NULL, NULL, 1, N'Salary Variance Report'),
--	(6820, N'Gratuity', 6711, 192, 1, NULL, NULL, 1, N'Gratuity'),
	
--	(6821, N'Leave Encashment paid', 6712, 194, 1, NULL, NULL, 1, N'Leave Encashment paid'),
--	(6822, N'Fitness Certificate', 6712, 194, 1, NULL, NULL, 1, N'Fitness Certificate'),
--	(6823, N'Health Register-Form32', 6712, 194, 1, NULL, NULL, 1, N'Health Register-Form32'),
--	(6824, N'Adult Worker Register', 6712, 194, 1, NULL, NULL, 1, N'Adult Worker Register'),
--	(6825, N'Exit Interview ', 6712, 194, 1, NULL, NULL, 1, N'Exit Interview '),
--	(6826, N'Clearance Form', 6712, 194, 1, NULL, NULL, 1, N'Clearance Form'),
--	(6827, N'Form ER 1 ', 6712, 194, 1, NULL, NULL, 1, N'Form ER 1 '),
--	(6828, N'Form ER 2', 6712, 194, 1, NULL, NULL, 1, N'Form ER 2'),
--	(6829, N'Consolidated Annual Return', 6712, 194, 1, NULL, NULL, 1, N'Consolidated Annual Return'),
--	(6830, N'Form-25', 6712, 194, 1, NULL, NULL, 1, N'Form-25'),
--	(6831, N'Holiday Details', 6712, 194, 1, NULL, NULL, 1, N'Holiday Details'),
--	(6832, N'Travel Detail', 6712, 194, 1, NULL, NULL, 1, N'Travel Detail'),
--	(6833, N'Travel Settlement ', 6712, 194, 1, NULL, NULL, 1, N'Travel Settlement '),
--	(6834, N'Travel Settlement Status', 6712, 194, 1, NULL, NULL, 1, N'Travel Settlement Status'),
--	(6835, N'Employee Probation', 6712, 194, 1, NULL, NULL, 1, N'Employee Probation'),
--	(6836, N'Employee Insurance', 6712, 194, 1, NULL, NULL, 1, N'Employee Insurance'),
--	(6837, N'Leave Allowance Detail', 6712, 194, 1, NULL, NULL, 1, N'Leave Allowance Detail'),
--	(6838, N'Memo Report', 6712, 194, 1, NULL, NULL, 1, N'Memo Report'),


---- Ess Side panel Form id from 7000 to 7499
--	(7000, N'ESS Module', -1, 300, 1, NULL, NULL, 1, N'ESS Module'),
--	(7001, N'Employee', -1, 301, 1, N'Home.aspx', N'menu/info.gif', 1, N'Employee'),
--	(7002, N'My Profile', 7001, 302, 1, N'Default.aspx', N'menu/info.gif', 1, N'My Profile'),
--	(7003, N'Change Password Ess ', 7001, 303, 1, N'Changepassword.aspx', N'menu/info.gif', 1, N'Change Password Ess '),
--	(7004, N'My In Out', 7001, 304, 1, N'emp_inout_new.aspx', N'menu/info.gif', 1, N'My In Out'),
--	(7005, N'Leave', -1, 308, 1, N'Home.aspx', N'menu/leave_management.gif', 1, N'Leave'),
--	(7006, N'Leave Application', 7005, 309, 1, N'Leave_application.aspx', N'menu/leave_management.gif', 1, N'Leave Application'),
--	(7007, N'Leave Approval', 7005, 310, 1, N'Leave_Approve.aspx', N'menu/leave_management.gif', 1, N'Leave Approval'),
--	(7008, N'Leave Status', 7005, 311, 1, N'Leave_Status.aspx', N'menu/leave_management.gif', 1, N'Leave Status'),
--	(7009, N'Leave Encashment Application', 7005, 312, 1, N'Leave_Encashment_Application.aspx', N'menu/leave_management.gif', 1, N'Leave Encashment Application'),
--	(7010, N'Loan LIC', -1, 315, 1, N'Home.aspx', N'menu/loan_claim.gif', 1, N'Loan'),
--	(7011, N'Loan LIC Application', 7010, 316, 1, N'Loan_Application.aspx', N'menu/loan_claim.gif', 1, N'Loan Application'),
--	(7012, N'Loan LIC Status', 7010, 317, 1, N'Loan_Status.aspx', N'menu/loan_claim.gif', 1, N'Loan Status'),
--	(7013, N'Claim', -1, 320, 1, N'Home.aspx', N'menu/claim.gif', 1, N'Claim'),
--	(7014, N'Claim Application', 7013, 321, 1, N'Claim_Application.aspx', N'menu/claim.gif', 1, N'Claim Application'),
--	(7015, N'Claim Status', 7013, 322, 1, N'Claim_status.aspx', N'menu/claim.gif', 1, N'Claim Status'),
--	(7016, N'LTA Medical', -1, 327, 1, N'Home.aspx', N'menu/LM.gif', 0, N'LTA Medical'),
--	(7017, N'LTA Medical Application', 7016, 328, 1, N'LTA_Medical_Application.aspx', N'menu/LM.gif', 0, N'LTA Medical Application'),
--	(7018, N'LTA Medical History', 7016, 329, 1, N'LTA_Medical_History.aspx', N'menu/LM.gif', 0, N'LTA Medical History'),
--	(7019, N'Salary Detail', -1, 330, 1, N'Home.aspx', N'menu/rupee.gif', 1, N'Salary Detail'),

--	(7020, N'Performance Detail', 7019, 331, 1, N'Employee_performance.aspx', N'menu/rupee.gif', 1, N'Performance Detail'),
--	(7021, N'IT Declaration Form', 7019, 332, 1, N'IT_Declarationn_User.aspx', N'menu/rupee.gif', 1, N'IT Declaration Form'),
--	(7022, N'Salary Slip', 7019, 333, 1, N'Salary_Slip.aspx', N'menu/rupee.gif', 1, N'Salary Slip'),
--	(7023, N'My Team', -1, 340, 1, N'Home.aspx', N'menu/info.gif', 1, N'My Team'),
--	(7024, N'WeekOff', 7023, 341, 1, N'Employee_Weekoff_Superior.aspx', N'menu/info.gif', 1, N'WeekOff'),
--	(7025, N'Over Time', 7023, 342, 1, N'Employee_OT.aspx', N'menu/info.gif', 1, N'Over Time'),
--	(7027, N'Shift Change', 7023, 344, 1, N'Employee_Shift_Change_Superior.aspx', N'menu/info.gif', 1, N'Shift Change'),
--	(7028, N'Member Details', 7023, 345, 1, N'Employee_Downline.aspx', N'menu/info.gif', 1, N'Member Details'),
--	(7029, N'HRMS', -1, 370, 1, N'Home.aspx', N'menu/process.png', 1, N'HRMS'),
--	(7030, N'Organization Organogram', 7029, 371, 1, N'desig_chart.aspx', N'menu/process.png', 1, N'Organization Organogram'),
--	(7031, N'Employee Organogram', 7029, 372, 1, N'org_chart.aspx', N'menu/process.png', 1, N'Employee Organogram'),
--	(7032, N'Document History', 7029, 372, 1, N'View_Emp_Doc_History.aspx', N'menu/process.png', 1, N'Document History'),  --Edit By Ripal 07Oct2013 (373 to 372)
--	(7033, N'Training Application', 7029, 374, 1, N'Hrms_Training_Application.aspx', N'menu/process.png', 1, N'Training Application'),
--	(7034, N'Training History', 7029, 375, 1, N'Hrms_Training_Feedback.aspx', N'menu/process.png', 1, N'Training History'),
--	(7035, N'Training Chart', 7029, 376, 1, N'hrms_Training_Chart.aspx', N'menu/process.png', 1, N'Training Chart'),
--	(7036, N'Recruitment Request', 7029, 377, 1, N'HRMS_Recruitment_Request.aspx', N'menu/process.png', 1, N'Recruitment Request'),
--	--(7037, N'Interview Process Acceptance', 7029, 378, 1, N'HRMS_Interview_Process.aspx', N'menu/process.png', 1, N'Interview Process Acceptance'),
--	(7038, N'Interview Process', 7029, 379, 1, N'HRMS_RECRUITMENT_PROCESS_DETAIL.aspx', N'menu/process.png', 1, N'Interview Process'),
--	(7039, N'Appraisal Detail', 7029, 380, 1, N'Appraisal_List_Emp.aspx', N'menu/process.png', 1, N'Appraisal Detail'),
--	(7040, N'Employee Appraisal Process Data', 7029, 381, 1, N'Appraisal_List.aspx', N'menu/process.png', 1, N'Employee Appraisal Process Data'),
--	(7041, N'Admin Leave Approval', 7005, 313, 1, N'Leave_Admin_Approve_Superior.aspx', N'menu/leave_management.gif', 1, N'Admin Leave Approval'),
--	(7042, N'Member In Out Records', 7023, 346, 1, N'Employee_Downline_Inout_Record.aspx', N'menu/info.gif', 1, N'Member In Out Records'),
--	(7043, N'Leave Cancellation', 7005, 314, 1, N'Leave_Cancellation_Application.aspx', N'menu/leave_management.gif', 1, N'Leave Cancellation'),
--	(7044, N'Leave Cancellation Approval Member', 7005, 314, 1, N'Leave_Cancelation_Approval.aspx', N'menu/leave_management.gif', 1, N'Leave Cancellation Approval Member'),
--	(7045, N'Comp Off', 7005, 314, 1, N'Home.aspx', N'menu/leave_management.gif', 1, N'Comp Off'),
--	(7046, N'comp off Application', 7045, 314, 1, N'CompOff_Application.aspx', N'menu/leave_management.gif', 1, N'comp off Application'),
--	(7047, N'comp off Approval', 7045, 314, 1, N'CompOff_Approval.aspx', N'menu/leave_management.gif', 1, N'comp off Approval'),
--	(7048, N'Optional Holiday Application', 7001, 305, 1, N'Option_Holiday_Application.aspx', N'menu/info.gif', 1, N'Optional Holiday Application'),

--	(7049, N'Exit', -1, 408, 1, N'Home.aspx', N'menu/exit.png', 1, N'Exit'),
--	(7050, N'Exit Application', 7049, 409, 1, N'Emp_ExitApplication.aspx', N'menu/exit.png', 1, N'Exit Application'),
--	(7051, N'Exit Feedback', 7049, 410, 1, N'Emp_ManagerFeedback.aspx', N'menu/exit.png', 1, N'Exit Feedback'),
	
--	(7052, N'Travel Details', -1, 323, 1, N'Home.aspx', N'menu/claim.gif', 1, N'Travel Details'),
--	(7053, N'Advance', 7019, 334, 1, N'Home.aspx', N'menu/rupee.gif', 1, N'Advance'),
--	(7054, N'Advance Application', 7053, 334, 1, N'Salary_Advance_Application.aspx', N'menu/rupee.gif', 1, N'Advance Application'),
--	(7055, N'Advance Approval', 7053, 334, 1, N'Salary_Advance_Approval.aspx', N'menu/rupee.gif', 1, N'Advance Approval'),
--	(7056, N'Advance Status', 7053, 334, 1, N'Salary_Adavance_Status.aspx', N'menu/rupee.gif', 1, N'Advance Status'),
--	(7057, N'Travel Application', 7052, 324, 1, N'Travel_Application.aspx', N'menu/claim.gif', 1, N'Travel Application'),
--	(7058, N'Travel Settlement', 7052, 326, 1, N'TravelSettlement.aspx', N'menu/claim.gif', 1, N'Travel Settlement'),
--	(7059, N'Travel Approvals ', 7052, 325, 1, N'Travel_Approval_Superior.aspx', N'menu/claim.gif', 1, N'Travel Approvals '),
--	(7060, N'Travel Settlement Approvals', 7052, 327, 1, N'Travel_Settlement_Approval_Superior.aspx', N'menu/claim.gif', 1, N'Travel Settlement Approvals'),
--	(7061, N'Member Reports', 7023, 347, 1, N'Report_Employee_List.aspx', N'menu/info.gif', 1, N'Member Reports'),
--	(7062, N'My Reports', -1, 385, 1, N'Report_Mine.aspx', N'menu/file.gif', 1, N'My Reports'),
	

---- Report Of Ess Side Form id from 7500 to end
	
--	(7501, N'Employee Records Member#', 7061, 348, 1, NULL, NULL, 1, N'Employee Records Member#'),
--	(7502, N'Employee List(Form-13) Member#', 7501, 349, 1, NULL, NULL, 1, N'Employee List(Form-13) Member#'),
--	(7503, N'Attendance Reports Member#', 7061, 350, 1, NULL, NULL, 1, N'Attendance Reports Member#'),
--	(7504, N'Attendance Register Member#', 7503, 351, 1, NULL, NULL, 1, N'Attendance Register Member#'),
--	(7505, N'In-Out Summary Member#', 7503, 352, 1, NULL, NULL, 1, N'In-Out Summary Member#'),
--	(7506, N'Employee Inout Present Member#', 7503, 353, 1, NULL, NULL, 1, N'Employee Inout Present Member#'),
--	(7507, N'Leave Reports Member#', 7061, 354, 1, NULL, NULL, 1, N'Leave Reports Member#'),
--	(7508, N'Leave Approval Member#', 7507, 355, 1, NULL, NULL, 1, N'Leave Approval Member#'),
--	(7509, N'Leave Balance Member#', 7507, 356, 1, NULL, NULL, 1, N'Leave Balance Member#'),
--	(7510, N'Yearly Leave Transaction Member#', 7507, 357, 1, NULL, NULL, 1, N'Yearly Leave Transaction Member#'),
--	(7511, N'Loan Reports Member#', 7061, 358, 1, NULL, NULL, 1, N'Loan Reports Member#'),
--	(7512, N'Loan Approval Member#', 7511, 359, 1, NULL, NULL, 1, N'Loan Approval Member#'),
--	(7513, N'Loan Statement Report Member#', 7511, 360, 1, NULL, NULL, 1, N'Loan Statement Report Member#'),
--	(7514, N'Other Reports Member#', 7061, 361, 1, NULL, NULL, 1, N'Other Reports Member#'),
--	(7515, N'Salary Slip Member#', 7514, 362, 1, NULL, NULL, 1, N'Salary Slip Member#'),
--	(7516, N'Yearly Salary Member#', 7514, 363, 1, NULL, NULL, 1, N'Yearly Salary Member#'),
--	(7517, N'PF Statement Member#', 7514, 364, 1, NULL, NULL, 1, N'PF Statement Member#'),
--	(7518, N'Tax Preparation Member#', 7514, 365, 1, NULL, NULL, 1, N'Tax Preparation Member#'),
--	(7519, N'Form-16(IT) Member#', 7514, 366, 1, NULL, NULL, 1, N'Form-16(IT) Member#'),
	
--	(7521, N'Attendance Reports My#', 7062, 386, 1, NULL, NULL, 1, N'Attendance Reports My#'),
--	(7522, N'Attendance Register My#', 7521, 387, 1, NULL, NULL, 1, N'Attendance Register My#'),
--	(7523, N'In-Out Summary My#', 7521, 388, 1, NULL, NULL, 1, N'In-Out Summary My#'),
--	(7524, N'Employee Inout Present My#', 7521, 389, 1, NULL, NULL, 1, N'Employee Inout Present My#'),
--	(7525, N'Leave Reports My#', 7062, 390, 1, NULL, NULL, 1, N'Leave Reports My#'),
--	(7526, N'Leave Approval My#', 7525, 391, 1, NULL, NULL, 1, N'Leave Approval My#'),
--	(7527, N'Leave Balance My#', 7525, 392, 1, NULL, NULL, 1, N'Leave Balance My#'),
--	(7528, N'Yearly Leave Transaction My#', 7525, 393, 1, NULL, NULL, 1, N'Yearly Leave Transaction My#'),
--	(7529, N'Loan Reports My#', 7062, 394, 1, NULL, NULL, 1, N'Loan Reports My#'),
--	(7530, N'Loan Approval My#', 7529, 395, 1, NULL, NULL, 1, N'Loan Approval My#'),
--	(7531, N'Loan Statement Report My#', 7529, 396, 1, NULL, NULL, 1, N'Loan Statement Report My#'),
--	(7532, N'Other Reports My#', 7062, 397, 1, NULL, NULL, 1, N'Other Reports My#'),
--	(7533, N'Salary Slip My#', 7532, 398, 1, NULL, NULL, 1, N'Salary Slip My#'),
--	(7534, N'Yearly Salary My#', 7532, 399, 1, NULL, NULL, 1, N'Yearly Salary My#'),
--	(7535, N'PF Statement My#', 7532, 400, 1, NULL, NULL, 1, N'PF Statement My#'),
--	(7536, N'Tax Preparation My#', 7532, 401, 1, NULL, NULL, 1, N'Tax Preparation My#'),
--	(7537, N'Form-16(IT) My#', 7532, 402, 1, NULL, NULL, 1, N'Form-16(IT) My#'),
--	(7538, N'CTC letter (Annexure) My#', 7532, 402, 1, NULL, NULL, 1, N'CTC letter (Annexure) My#'),
--	(7539, N'Travel Report My#', 7062, 403, 1, NULL, NULL, 1, N'Travel Report My#'),
--	(7540, N'Travel Detail My#', 7539, 404, 1, NULL, NULL, 1, N'Travel Detail My#'),
--	(7541, N'Travel Settlement My#', 7539, 405, 1, NULL, NULL, 1, N'Travel Settlement My#'),
--	(7542, N'Travel Statement My#', 7539, 406, 1, NULL, NULL, 1, N'Travel Statement My#'),
--	(7543, N'Travel Settlement Status My#', 7539, 407, 1, NULL, NULL, 1, N'Travel Settlement Status My#')

--	-- Admin Side panel  form id between 6000 to 6500

INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6001, N'Control Panel', -1, 1, 1, N'Home.aspx', @Control_Pnl_Img, 1, N'Control Panel')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6002, N'Company Information', 6001, 2, 1, N'Home_Company_Update.aspx', @Control_Pnl_Img, 1, N'Company Information')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6003, N'Change Password', 6001, 3, 1, N'Home_Change_Password.aspx', @Control_Pnl_Img, 1, N'Change Password')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6004, N'Company General Setting', 6001, 4, 1, N'Home_General_Setting.aspx', @Control_Pnl_Img, 1, N'Company General Setting')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6005, N'Professional Tax Setting', 6001, 5, 1, N'Home_PT_Master.aspx', @Control_Pnl_Img, 1, N'Professional Tax Setting')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6006, N'Privilege Master', 6001, 6, 1, N'Master_Privilege.aspx',@Control_Pnl_Img, 1, N'Privilege Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6007, N'Imports Data', 6001, 7, 1, N'Home_Import_Data.aspx', @Control_Pnl_Img, 1, N'Import Data')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6008, N'Email Notification Setting', 6001, 8, 1, N'Home_Email_Notification.aspx', @Control_Pnl_Img, 0, N'Email Notification Setting')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6009, N'IP Address Master', 6001, 9, 1, N'Home_IP_Master.aspx', @Control_Pnl_Img, 1, N'IP Address Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6010, N'SMS Setting', 6001, 10, 1, N'Home_Sms_Setting.aspx', @Control_Pnl_Img, 1, N'SMS Setting')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6011, N'Scheme', 6001, 11, 0, N'Home.aspx', @Control_Pnl_Img, 1, N'Scheme')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6164, N'Scheme Master', 6011, 12, 1, N'Master_Scheme.aspx', @Control_Pnl_Img, 1, N'Scheme Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6165, N'Scheme Detail', 6011, 13, 1, N'Scheme_Detail.aspx', @Control_Pnl_Img, 1, N'Scheme Detail')


INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6012, N'Masters', -1, 15, 1, N'Home.aspx',@Masters_Img, 1, N'Masters')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6013, N'Job Master', 6012, 16, 0, N'Home.aspx', @Masters_Img, 1, N'Job Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6014, N'Branch master', 6013, 20, 1, N'Master_Branch.aspx', @Masters_Img, 1, N'Branch Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6015, N'Grade Master', 6013, 18, 1, N'Master_Grade.aspx', @Masters_Img, 1, N'Grade Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6016, N'Department Master', 6013, 19, 1, N'Master_Department.aspx', @Masters_Img, 1, N'Department Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6017, N'Designation Master', 6013, 23, 1, N'Master_Designation.aspx', @Masters_Img, 1, N'Designation Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6018, N'Country Master', 6013, 21, 1, N'Master_Location.aspx', @Masters_Img, 1, N'Country Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6019, N'Shift Master', 6013, 22, 1, N'Master_Shift.aspx', @Masters_Img, 1, N'Shift Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6020, N'Project Master', 6013, 23, 1, N'Master_Project.aspx', @Masters_Img, 1, N'Project Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6021, N'State Master', 6013, 24, 1, N'Master_State.aspx', @Masters_Img, 1, N'State Master')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6022, N'Asset Master', 6013, 25, 1, N'Master_Asset.aspx', @Masters_Img, 1, N'Asset Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6023, N'Insurance/Medical Master', 6013, 26, 1, N'Master_Insurance.aspx', @Masters_Img, 1, N'Insurance/Medical Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6024, N'Category Master', 6013, 27, 1, N'Master_Category.aspx', @Masters_Img, 1, N'Category Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6025, N'Employee Type Master', 6013, 28, 1, N'Master_Employee_Status.aspx', @Masters_Img, 1, N'Employee Type Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6026, N'Cost Center Master', 6013, 29, 1, N'Master_CostCenter.aspx', @Masters_Img, 1, N'Cost Center Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6027, N'Company Structure', 6012, 35, 0, N'Home.aspx', @Masters_Img, 1, N'Company Structure')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6028, N'Allowance Deduction Master', 6027, 36, 1, N'Master_Allowance_Deduction.aspx', @Masters_Img, 1, N'Allowance Deduction Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6029, N'Present Late Scenario', 6027, 37, 1, N'Master_Present_Late_Scenario.aspx', @Masters_Img, 1, N'Present Late Scenario')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6030, N'AD Slab Settings', 6027, 38, 1, N'AD_Slab_Setting.aspx', @Masters_Img, 1, N'AD Slab Settings')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6031, N'Performance Master', 6027, 39, 1, N'Master_Performance_Incentive.aspx', @Masters_Img, 1, N'Performance Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6032, N'Holiday Master', 6027, 40, 1, N'Master_Holiday.aspx',@Masters_Img, 1, N'Holiday Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6033, N'WeekOff  Master', 6027, 41, 1, N'Master_Weekoff.aspx', @Masters_Img, 1, N'WeekOff  Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6034, N'Warning Master', 6027, 42, 1, N'Master_Warning.aspx', @Masters_Img, 1, N'Warning Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6035, N'Bank Master', 6027, 43, 1, N'Master_Bank.aspx', @Masters_Img, 1, N'Bank Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6036, N'Qualification', 6012, 50, 0, N'Home.aspx', @Masters_Img, 1, N'Qualification')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6037, N'Qualification Master', 6036, 51, 1, N'Master_Qualification.aspx', @Masters_Img, 1, N'Qualification Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6038, N'Skill Master', 6036, 52, 1, N'../admin_associates/Master_skill.aspx', @Masters_Img, 1, N'Skill Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6039, N'License Master', 6036, 53, 1, N'Master_License.aspx', @Masters_Img, 1, N'License Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6040, N'Document Master', 6012, 57, 1, N'Master_Document.aspx', @Masters_Img, 1, N'Document Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6041, N'Publish News Letters', 6012, 60, 1, N'Master_News_Letter.aspx', @Masters_Img, 1, N'Publish News Letters')


INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6042, N'Employee', -1, 65, 1, N'Home.aspx', @Employee_Img, 1, N'Employee')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6043, N'Employee Master', 6042, 66, 1, N'Employee_Master.aspx', @Employee_Img, 1, N'Employee Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6044, N'Left Employee Details', 6042, 67, 1, N'Employee_Left.aspx', @Employee_Img, 1, N'Left Employee Details')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6045, N'Employee Increment', 6042, 68, 1, N'Employee_Increment.aspx', @Employee_Img, 1, N'Employee Increment')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6046, N'Employee Transfer', 6042, 69, 1, N'Employee_Transfer.aspx', @Employee_Img, 1, N'Employee Transfer')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6047, N'Gradewise Allowance', 6042, 70, 1, N'Employee_Gradewise_allowance.aspx', @Employee_Img, 1, N'Gradewise Allowance')
-- COMMENTED BY GADRIWALA MUSLIM 29092016
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6048, N'Employee Weekoff', 6042, 71, 1, N'Employee_weekOff.aspx', @Employee_Img, 0, N'Employee Weekoff')	/* Deactive Employee Weekoff form and murge logic with Alternet Weekoff page - Ankit 23062016 */
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6049, N'Half Weekoff', 6042, 72, 1, N'Employee_Half_Weekoff.aspx', @Employee_Img, 1, N'Half Weekoff')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6050, N'Employee In Out', 6169, 73, 1, N'Employee_In_Out.aspx', @Employee_Img, 1, N'Employee In Out')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6157, N'Employee Default In out', 6169, 74, 1, N'Employee_In_Out_Daily.aspx', @Employee_Img, 1, N'Employee Default In out')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6051, N'Employee In Out Record', 6169, 74, 1, N'Employee_Inout_Record.aspx', @Employee_Img, 1, N'Employee In Out Record')
-- COMMENTED BY GADRIWALA MUSLIM 29092016
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6052, N'Employee Shift Change', 6171, 76, 1, N'Employee_Shift_Change.aspx', @Employee_Img, 0, N'Employee Shift Change') /* Deactive Employee Shift Change form and murge logic with Shift Change Detail page - Ankit 23062016 */
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6053, N'Employee Shift Change Detail', 6171, 76, 1, N'Employee_Shift_Change_Details.aspx',@Employee_Img, 1, N'Employee Shift Change Detail')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6054, N'Employee Shift Rotation', 6171, 78, 1, N'Employee_Assign_ShiftRotation.aspx',@Employee_Img, 1, N'Employee Shift Rotation') --URL modified by Nimesh 22 May 2015  (Employee_Shift_Rotation.aspx)
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6055, N'Warning Card Details', 6042, 78, 1, N'Employee_Warning.aspx', @Employee_Img, 1, N'Warning Card Details')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6056, N'Employee Privileges', 6042, 79, 1, N'Privilege_Employee.aspx', @Employee_Img, 1, N'Employee Privileges')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6156, N'Roster', 6042, 83, 1, N'Employee_Roster_WO_SH.aspx',@Employee_Img, 1, N'Roster')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6155, N'Optional Holiday Approval', 6042, 83, 1, N'Employee_OptionalHoliday_Approval.aspx', @Employee_Img, 1, N'Optional Holiday Approval')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6166, N'Salary Cycle Transfer', 6042, 83, 1, N'Employee_Salary_Cycle_Transfer.aspx', @Employee_Img, 1, N'Salary Cycle Transfer')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6167, N'Employee Schemes', 6042, 83, 1, N'Scheme_Employee.aspx', @Employee_Img, 1, N'Employee Schemes')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6169, N'Employee In-Out', 6042, 72, 1, N'Home.aspx',@Employee_Img, 1, N'Employee In-Out')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6171, N'Employee Shift', 6042, 75, 1, N'Home.aspx', @Employee_Img, 1, N'Employee Shift')


--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6057, N'Leave', -1, 85, 1, N'Home.aspx', N'menu/leave_management.gif', 1, N'Leave')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6057, N'Leave', -1, 85, 1, N'Home.aspx', @Leave_Img, 1, N'Leave')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6058, N'Leave Master', 6057, 86, 1, N'Leave_Master.aspx', @Leave_Img, 1, N'Leave Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6059, N'Leave Detail', 6057, 87, 1, N'Leave_Details.aspx',@Leave_Img, 1, N'Leave Detail')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6060, N'Leave Opening', 6057, 88, 1, N'Leave_Opening.aspx', @Leave_Img, 1, N'Leave Opening')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6061, N'Leave Application', 6057, 89, 1, N'Leave_application.aspx', @Leave_Img, 1, N'Leave Application')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6062, N'Leave Approval', 6057, 90, 1, N'Home.aspx', @Leave_Img, 1, N'Leave Approval')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6114, N'Leave Approval', 6062, 91, 1, N'Leave_Approve.aspx', @Leave_Img, 1, N'Leave Approval')

INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6063, N'Admin Leave Approval', 6062, 92, 1, N'Leave_Admin_Approve.aspx',@Leave_Img, 1, N'Admin Leave Approval')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6064, N'Leave Updates', 6062, 93, 1, N'Leave_Update.aspx', @Leave_Img, 1, N'Leave Updates')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6065, N'Leave Cancellation', 6057, 98, 1, N'Leave_Cancelation_Approval.aspx', @Leave_Img, 1, N'Leave Cancellation')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6066, N'Leave Carry Forward', 6057, 94, 1, N'Leave_Carry_Forward.aspx', @Leave_Img, 1, N'Leave Carry Forward')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6067, N'Leave Encash', 6057, 95, 1, N'Leave_Encashment.aspx', @Leave_Img, 1, N'Leave Encash')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6115, N'Leave Encash Approve', 6067, 96, 1, N'Leave_Encashment.aspx', @Leave_Img, 1, N'Leave Encash Approve')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6068, N'Leave Direct Encash', 6067, 97, 1, N'Leave_Encashment_Approval.aspx', @Leave_Img, 1, N'Leave Direct Encash')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6068, N'Leave Direct Encash', 6067, 97, 1, N'Leave_Encashment_Leavewise.aspx', @Leave_Img, 1, N'Leave Direct Encash')  --Change by Jaina 26-06-2017
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6069, N'LeaveWise Encashment', 6067, 98, 1, N'Leave_Encashment_Leavewise.aspx', @Leave_Img, 0, N'LeaveWise Encashment')  --Change by Jaina 26-06-2017


--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6070, N'Loan LIC Claim', -1, 103, 1, N'Home.aspx', N'menu/loan_claim.gif', 1, N'Loan/Claim')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6070, N'Loan LIC Claim', -1, 103, 1, N'Home.aspx', @Loan_Claim_Img, 1, N'Loan/Claim')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6071, N'Loan LIC Details', 6070, 104, 0, N'Home.aspx', @Loan_Claim_Img, 1, N'Loan Details')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6072, N'Loan LIC Master', 6071, 105, 1, N'Loan_Master.aspx', @Loan_Claim_Img, 1, N'Loan Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6073, N'Loan LIC Application', 6071, 106, 1, N'Loan_Application.aspx', @Loan_Claim_Img, 1, N'Loan Application')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6074, N'Loan LIC Approval', 6071, 107, 1, N'Loan_Approve.aspx',@Loan_Claim_Img, 1, N'Loan Approval')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6075, N'Admin Loan LIC Approval', 6071, 108, 1, N'Loan_Approve_Admin.aspx', @Loan_Claim_Img, 1, N'Admin Loan Approval')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6076, N'Loan LIC Payment', 6071, 109, 1, N'Loan_Payment.aspx', @Loan_Claim_Img, 1, N'Loan Payment')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6077, N'Claim Details', 6070, 115, 0, N'Home.aspx', @Loan_Claim_Img, 1, N'Claim Details')

INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6078, N'Claim Master', 6077, 116, 1, N'Master_Claim.aspx',@Loan_Claim_Img, 1, N'Claim Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6079, N'Claim Application', 6077, 117, 1, N'Claim_Admin_Application.aspx', @Loan_Claim_Img, 1, N'Claim Application')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6080, N'Claim Approval', 6077, 118, 1, N'Claim_Admin_Approval.aspx', @Loan_Claim_Img, 1, N'Claim Approval')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6081, N'Claim Payment', 6077, 119, 1, N'Claim_Admin_Payment.aspx', @Loan_Claim_Img, 1, N'Claim Payment')



INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6082, N'LTA Medical Details', 6070, 123, 0, NULL, NULL, 0, N'LTA Medical Details')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6083, N'LTA Medical Setting Master', 6082, 124, 1, NULL, NULL, 0, N'LTA Medical Setting Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6084, N'Employee LTA Medical Detail', 6082, 125, 1, NULL, NULL, 0, N'Employee LTA Medical Detail')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6085, N'LTA Medical Application  Approval', 6082, 126, 1, NULL, NULL, 0, N'LTA Medical Application  Approval')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6086, N'LTA Medical Payment', 6082, 127, 1, NULL, NULL, 0, N'LTA Medical Payment')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6087, N'LTA Medical History', 6082, 128, 1, NULL, NULL, 0, N'LTA Medical History')


--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6088, N'Salary Details', -1, 135, 1, N'Home.aspx', N'menu/rupee.gif', 1, N'Salary Details')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6088, N'Salary Details', -1, 135, 1, N'Home.aspx', @Salary_Img, 1, N'Salary Details')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6089, N'OT Approval', 6088, 136, 1, N'Salary_Daily_OT.aspx', @Salary_Img, 1, N'OT Approval')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6091, N'Bonus Detail', 6088, 138, 1, N'Salary_Bonus_Detail.aspx', @Salary_Img, 1, N'Bonus Detail')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6092, N'Performance Detail', 6088, 139, 1, N'Salary_Employee_Performance.aspx',@Salary_Img, 1, N'Performance Detail')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6093, N'Advance', 6088, 140, 0, N'Home.aspx',@Salary_Img, 1, N'Advance')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6168, N'Reverse Salary', 6088, 141, 1, N'Reverse_Salary_Calculation.aspx', @Salary_Img, 1, N'Reverse Salary')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6094, N'Monthly Salary', 6170, 143, 1, N'Salary_Monthly.aspx',@Salary_Img, 1, N'Monthly Salary')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6095, N'Manually Salary', 6170, 143, 1, N'Salary_Manually.aspx', @Salary_Img, 1, N'Manually Salary')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6096, N'Salary Daily', 6170, 143, 1, N'Salary_Daily_Wages.aspx', @Salary_Img, 1, N'Salary Daily')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6097, N'Salary Settlement', 6088, 144, 1, N'Salary_settlement.aspx', @Salary_Img, 1, N'Salary Settlement')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6098, N'F F Settlement', 6088, 145, 1, N'Salary_Final_Settlement.aspx', @Salary_Img, 1, N'F F Settlement')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6099, N'Gratuity Detail', 6088, 146, 1, N'Salary_Gratuity_Detail.aspx', @Salary_Img, 1, N'Gratuity Detail')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6100, N'TDS', 6088, 150, 0, N'Home.aspx', @Salary_Img, 1, N'TDS')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6101, N'IT Master', 6100, 151, 1, N'IT_Master1.aspx', @Salary_Img, 1, N'IT Master')

INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6102, N'IT Declaration', 6100, 152, 1, N'../admin_associates/IT_Declaration_With_Detail.aspx', @Salary_Img, 1, N'IT Declaration')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6103, N'IT Limit', 6100, 153, 1, N'../admin_associates/IT_Limit.aspx',@Salary_Img, 1, N'IT Limit')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6104, N'IT Form Design', 6100, 154, 1, N'IT_Form_Desing.aspx', @Salary_Img, 1, N'IT Form Design')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6105, N'IT Employee Perquisites', 6100, 155, 1, N'Employee_Perquisites.aspx', @Salary_Img, 1, N'IT Employee Perquisites')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6106, N'IT Tax Planning', 6100, 156, 1, N'IT_Tax_Planning.aspx', @Salary_Img, 1, N'IT Tax Planning')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6107, N'Challan', 6088, 160, 0, N'Home.aspx',@Salary_Img, 1, N'Challan')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6108, N'PF Challan', 6107, 161, 1, N'Salary_PF_Challan.aspx', @Salary_Img, 1, N'PF Challan')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6111, N'ESIC Challan', 6107, 166, 1, N'Salary_ESIC_Challan.aspx', @Salary_Img, 1, N'ESIC Challan')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6112, N'ESIC Challan Sett', 6107, 167, 1, N'Salary_ESIC_Challan_Sett.aspx', @Salary_Img, 0, N'ESIC Challan Sett') /* InActive Form & Report - Ankit 04072016 */
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6170, N'Salary', 6088, 142, 1, N'Home.aspx', @Salary_Img, 1, N'Salary')


--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6126, N'HR Management', -1, 200, 1, N'../HRMS/HR_Home.aspx', N'menu/process.png', 1, N'HR Management')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6126, N'HR Management', -1, 200, 1, N'../HRMS/HR_Home.aspx', @HR_Img, 1, N'HR Management')

INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6127, N'Reporting Manager', 6042, 80, 1, N'Assign_Reporting_Manager.aspx', @Employee_Img, 1, N'Reporting Manager')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6128, N'Payment Process', 6088, 147, 1, N'Payment_Process.aspx', @Salary_Img, 1, N'Payment Process')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6129, N'Month Lock', 6088, 148, 1, N'Salary_Lock.aspx', @Salary_Img, 1, N'Month Lock')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6130, N'Leave Cancellation Application', 6065, 98, 1, N'Leave_Cancellation_Application.aspx', @Leave_Img, 1, N'Leave Cancellation Application')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6131, N'Leave Cancellation Approval', 6065, 98, 1, N'Leave_Cancelation_Approval.aspx', @Leave_Img, 1, N'Leave Cancellation Approval')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6132, N'Leave Cancellation View Delete', 6065, 98, 1, N'Leave_Cancelation_Status.aspx',@Leave_Img, 1, N'Leave Cancellation View Delete')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6133, N'Comp Off', 6057, 98, 1, N'Home.aspx', @Leave_Img, 1, N'Comp Off')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6134, N'Comp Off Application', 6133, 98, 1, N'CompOff_Application.aspx', @Leave_Img, 1, N'Comp Off Application')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6135, N'Comp Off Approval', 6133, 98, 1, N'CompOff_Approval.aspx', @Leave_Img, 1, N'Comp Off Approval')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6136, N'TDS Challan', 6107, 168, 1, N'Salary_TDS_Challan.aspx', @Salary_Img, 1, N'TDS Challan')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6137, N'Question Master', 6013, 30, 1, N'Question_Master.aspx', @Masters_Img, 1, N'Question Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6138, N'Exit Application', 6148, 82, 1, N'Admin_ExitApplication.aspx', @Employee_Img, 1, N'Exit Application')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6139, N'Exit Interview', 6148, 82, 1, N'Admin_ExitInterview.aspx', @Employee_Img, 1, N'Exit Interview')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6140, N'Exit Status', 6148, 82, 1, N'Exit_ApplicationStatus.aspx',@Employee_Img, 1, N'Exit Status')

--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6142, N'Attendance Reason Master', 6013, 31, 1, N'Master_Reason.aspx', N'menu/job_master.gif', 1, N'Attendance Reason Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6142, N'Attendance Reason Master', 6013, 31, 1, N'Master_Reason.aspx', @Masters_Img, 1, N'Reason Master') --ChangeBy Jaina 24-10-2015
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6143, N'Travel Approval', 6151, 122, 1, N'Travel_Approval.aspx', @Loan_Claim_Img, 1, N'Travel Approval')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6144, N'Policy Document Master', 6013, 32, 1, N'Policy_Document.aspx', @Masters_Img, 1, N'Policy Document Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6145, N'IT Acknowledgement', 6100, 157, 1, N'Tds_AcknowledgeNo.aspx', @Salary_Img, 1, N'IT Acknowledgement')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6146, N'Salary Advance Approval', 6093, 140, 1, N'Salary_Advance_Approval.aspx', @Salary_Img, 1, N'Salary Advance Approval')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6147, N'Admin Advance Approval', 6093, 140, 1, N'Salary_Advance.aspx', @Salary_Img, 1, N'Admin Advance Approval')

INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6148, N'Exit', 6042, 81, 1, N'Home.aspx', @Employee_Img, 1, N'Exit')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6149, N'Travel Settlement Approval', 6151, 123, 1, N'TravelSettlement_Approval.aspx', @Loan_Claim_Img, 1, N'Travel Settlement Approval')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6150, N'Expense Type Master', 6013, 33, 1, N'Master_Expense_Type.aspx', @Masters_Img, 1, N'Expense Type Master')

INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6151, N'Travel', 6070, 119, 1, N'Home.aspx', @Loan_Claim_Img, 1, N'Travel')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6152, N'Travel Settlement Application', 6151, 121, 1, N'TravelSettlement.aspx', @Loan_Claim_Img, 1, N'Travel Settlement Application')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6153, N'Travel Applications', 6151, 120, 1, N'Travel_Applications.aspx', @Loan_Claim_Img, 1, N'Travel Applications')

INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6154, N'PT Challan', 6107, 169, 1, N'Salary_PT_Chalan.aspx', @Salary_Img, 1, N'PT Challan')

INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6158, N'SubVertical Master', 6013, 34, 1, N'Master_SubVertical.aspx', @Masters_Img, 1, N'SubVertical Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6159, N'SubBranch Master', 6013, 17, 1, N'Master_SubBranch.aspx', @Masters_Img, 1, N'SubBranch Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6160, N'Salary Cycle Master', 6013, 34, 1, N'Master_Salary_Cycle.aspx', @Masters_Img, 1, N'Salary Cycle Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6161, N'Business Segment Master', 6013, 34, 1, N'Master_Business_Segment.aspx', @Masters_Img, 1, N'Business Segment Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6162, N'Vertical Master', 6013, 34, 1, N'Master_Vertical.aspx', @Masters_Img, 1, N'Vertical Master')


--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6163, N'Reports', -1, 170, 1, N'../Reports/Report_Employee_List.aspx', N'menu/file.gif', 1, N'Reports')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6163, N'Reports', -1, 170, 1, N'../Reports/Report_Employee_List.aspx', @Report_Img, 1, N'Reports')

-- HRMS SIDE Panel  form id between 6500 to 6699
-- Commented and Added by rohit on 11-feb-2014 for Merge bma Code
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6500, N'HRMS Home', -1, 201, 1, NULL, NULL, 1, N'HRMS Home')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6501, N'Recruitment Panel', -1, 202, 1, NULL, NULL, 1, N'Recruitment Panel')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6502, N'Recruitment Process Master', 6501, 203, 1, NULL, NULL, 1, N'Recruitment Process Master')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6503, N'Recruitment Application', 6501, 203, 1, NULL, NULL, 1, N'Recruitment Application')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6504, N'Recruitment Posted Detail', 6501, 203, 1, NULL, NULL, 1, N'Recruitment Posted Detail')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6505, N'Resume Import', 6501, 203, 1, NULL, NULL, 1, N'Resume Import')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6506, N'Posted Resume Collection', 6501, 203, 1, NULL, NULL, 1, N'Posted Resume Collection')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6507, N'Candidates Detail', 6501, 203, 1, NULL, NULL, 1, N'Candidates Detail')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6508, N'Candidates Finalization Detail', 6501, 203, 1, NULL, NULL, 1, N'Candidates Finalization Detail')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6509, N'Training', -1, 206, 1, NULL, NULL, 1, N'Training')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6510, N'Training Master', 6509, 207, 1, NULL, NULL, 1, N'Training Master')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6511, N'Training Provider', 6509, 208, 1, NULL, NULL, 1, N'Training Provider')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6512, N'Training Plan', 6509, 209, 1, NULL, NULL, 1, N'Training Plan')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6513, N'Training Calendar', 6509, 210, 1, NULL, NULL, 1, N'Training Calendar')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6514, N'Training Approval', 6509, 211, 1, NULL, NULL, 1, N'Training Approval')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6515, N'Training Feedback', 6509, 212, 1, NULL, NULL, 1, N'Training Feedback')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6516, N'Training History', 6509, 213, 1, NULL, NULL, 1, N'Training History')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6517, N'Training Questionnaire', 6509, 214, 1, NULL, NULL, 1, N'Training Questionnaire')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6518, N'Appraisal', -1, 218, 1, NULL, NULL, 1, N'Appraisal')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6519, N'Rating Master', 6518, 219, 1, NULL, NULL, 1, N'Rating Master')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6520, N'Goal Master', 6518, 220, 1, NULL, NULL, 1, N'Goal Master')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6521, N'Appraisal General Setting', 6518, 221, 1, NULL, NULL, 1, N'Appraisal General Setting')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6522, N'Skill General Setting', 6518, 222, 1, NULL, NULL, 1, N'Skill General Setting')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6523, N'Assign Goal', 6518, 223, 1, NULL, NULL, 1, N'Assign Goal')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6524, N'Employee Skill Rating', 6518, 224, 1, NULL, NULL, 1, N'Employee Skill Rating')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6525, N'Initiate Appraisal', 6518, 225, 1, NULL, NULL, 1, N'Initiate Appraisal')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6526, N'Appraisal Approval', 6518, 226, 1, NULL, NULL, 1, N'Appraisal Approval')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6527, N'Initiate Appraisal Report', 6518, 227, 1, NULL, NULL, 1, N'Initiate Appraisal Report')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6528, N'Performance Appraisal', -1, 230, 1, NULL, NULL, 1, N'Performance Appraisal')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6529, N'Performance Rating Master', 6528, 231, 1, NULL, NULL, 1, N'Performance Rating Master')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6530, N'GoalType Master', 6528, 232, 1, NULL, NULL, 1, N'GoalType Master')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6531, N'Competency Master', 6528, 233, 1, NULL, NULL, 1, N'Competency Master')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6532, N'Setting Master', 6528, 234, 1, NULL, NULL, 1, N'Setting Master')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6533, N'Review Employee Goal', 6528, 235, 1, NULL, NULL, 1, N'Review Employee Goal')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6534, N'Review Performance Summary', 6528, 236, 1, NULL, NULL, 1, N'Review Performance Summary')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6535, N'Review Competency', 6528, 237, 1, NULL, NULL, 1, N'Review Competency')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6536, N'HR Documents', -1, 240, 1, NULL, NULL, 1, N'HR Documents')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6537, N'HR Document Master', 6536, 241, 1, NULL, NULL, 1, N'HR Document Master')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6538, N'Export Employee Document', 6536, 242, 1, NULL, NULL, 1, N'Export Employee Document')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6539, N'Employee Document History', 6536, 243, 1, NULL, NULL, 1, N'Employee Document History')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6540, N'Organogram', -1, 245, 1, NULL, NULL, 1, N'Organogram')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6541, N'Organization Organogram', 6540, 246, 1, NULL, NULL, 1, N'Organization Organogram')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6542, N'Employee Organogram', 6540, 247, 1, NULL, NULL, 1, N'Employee Organogram')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6543, N'Finalize Candidate', 6501, 203, 1, NULL, NULL, 1, N'Finalize Candidate')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6544, N'Candidate For Offer', 6501, 203, 1, NULL, NULL, 1, N'Candidate For Offer')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6545, N'Candidates OnBoard', 6501, 203, 1, NULL, NULL, 1, N'Candidates OnBoard')

INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6500, N'HRMS Home', -1, 201, 1, N'HRMS/HR_Home.aspx', N'menu/b_home.gif', 1, N'HRMS Home')

INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6501, N'Recruitment Panel', -1, 202, 1, N'HRMS/HR_Home.aspx',N'menu/Recruitement.png', 1, N'Recruitment Panel')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6502, N'Recruitment Process Master', 6501, 203, 1, N'HRMS/HRMS_Process_Master.aspx', N'menu/Recruitement.png', 1, N'Recruitment Process Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6503, N'Recruitment Application', 6501, 203, 1, N'HRMS/HRMS_Recruitment_Posted.aspx', N'menu/Recruitement.png', 1, N'Recruitment Application')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6504, N'Recruitment Posted Detail', 6501, 203, 1, N'HRMS/HRMS_Posted_Detail.aspx', N'menu/Recruitement.png', 1, N'Recruitment Posted Detail')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6505, N'Resume Import', 6501, 203, 1, N'HRMS/Resume_Import_Data.aspx', N'menu/Recruitement.png', 1, N'Resume Import')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6506, N'Posted Resume Collection', 6501, 203, 1, N'HRMS/HRMS_Resume_Bank.aspx', N'menu/Recruitement.png', 1, N'Posted Resume Collection')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6507, N'Candidates Detail', 6501, 203, 1, N'HRMS/HRMS_Candidate_details.aspx', N'menu/Recruitement.png', 1, N'Candidates Detail')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6508, N'Candidates Finalization Detail', 6501, 203, 1, N'HRMS/FinalizedResumes.aspx', N'menu/Recruitement.png', 1, N'Candidates Finalization Detail')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6546, N'Joining Status Updation', 6501, 204, 1, N'HRMS/HRMS_Candidate_Finalization_details.aspx', N'menu/Recruitement.png', 1, N'Joining Status Updation')

-- Added by rohit on 11-feb-2014

INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6543, N'Recruitment Application BMA', 6501, 203, 1, N'HRMS/HRMS_Recruitment_Posted_BMA.aspx', N'menu/Recruitement.png', 0, N'Recruitment Application')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6544, N'Recruitment Posted Detail BMA', 6501, 203, 1, N'HRMS/HRMS_Posted_Detail_BMA.aspx', N'menu/Recruitement.png', 0, N'Recruitment Posted Detail')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6545, N'Resume Import BMA', 6501, 203, 1, N'HRMS/Resume_Import_Data_BMA.aspx', N'menu/Recruitement.png', 0, N'Resume Import')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6547, N'Posted Resume Collection BMA', 6501, 203, 1, N'HRMS/HRMS_Resume_Bank_BMA.aspx', N'menu/Recruitement.png', 0, N'Posted Resume Collection')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6548, N'Candidates Detail BMA', 6501, 203, 1, N'HRMS/HRMS_Candidate_details_BMA.aspx', N'menu/Recruitement.png', 0, N'Candidates Detail')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6549, N'Finalize Candidate BMA', 6501, 204, 1, N'HRMS/FinalizedResumes_BMA.aspx', N'menu/Recruitement.png', 0, N'Finalize Candidate')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6550, N'Candidate For Offer BMA', 6501, 204, 1, N'HRMS/CandidateOffer_BMA.aspx', N'menu/Recruitement.png', 0, N'Candidate For Offer')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6551, N'Joining Status Updation BMA', 6501, 204, 1, N'HRMS/HRMS_Candidate_Finalization_details_BMA.aspx', N'menu/Recruitement.png', 0, N'Joining Status Updation')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6552, N'Candidates OnBoard BMA', 6501, 205, 1, N'HRMS/HRMS_NewJoineesList_BMA.aspx', N'menu/Recruitement.png', 0, N'Candidates OnBoard')
-- Ended by rohit on 11-feb-2014


INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6509, N'Training', -1, 206, 1, N'HRMS/HR_Home.aspx', N'menu/fix.gif', 1, N'Training')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6510, N'Training Master', 6509, 207, 1, N'HRMS/HRMS_Training_Master.aspx', N'menu/fix.gif', 1, N'Training Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6511, N'Training Provider', 6509, 208, 1, N'HRMS/HRMS_Training_Provider_Master.aspx', N'menu/fix.gif', 1, N'Training Provider')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6512, N'Training Plan', 6509, 209, 1, N'HRMS/HRMS_View_Training_Approval.aspx', N'menu/fix.gif', 1, N'Training Plan')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6513, N'Training Calendar', 6509, 210, 1, N'HRMS/HRMS_Training_Calander.aspx', N'menu/fix.gif', 1, N'Training Calendar')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6514, N'Training Approval', 6509, 211, 1, N'HRMS/HRMS_Training_Approval.aspx', N'menu/fix.gif', 1, N'Training Approval')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6515, N'Training Feedback', 6509, 212, 1, N'HRMS/HRMS_View_Training_Feedback.aspx', N'menu/fix.gif', 1, N'Training Feedback')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6516, N'Training History', 6509, 213, 1, N'HRMS/HRMS_Training_Emp_feedback_detail.aspx', N'menu/fix.gif', 1, N'Training History')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6517, N'Training Questionnaire', 6509, 214, 1, N'HRMS/HRMS_Training_Questionnaire.aspx', N'menu/fix.gif', 1, N'Training Questionnaire')

INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6518, N'Appraisal', -1, 218, 1, N'HRMS/HR_Home.aspx', N'menu/company_structure.gif', 1, N'Appraisal')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6519, N'Rating Master', 6518, 219, 1, N'HRMS/Master_Rating.aspx', N'menu/company_structure.gif', 1, N'Rating Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6520, N'Goal Master', 6518, 220, 1, N'HRMS/Master_Goal.aspx', N'menu/company_structure.gif', 1, N'Goal Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6521, N'Appraisal General Setting', 6518, 221, 1, N'HRMS/Appraisal_General_Setting.aspx', N'menu/company_structure.gif', 1, N'Appraisal General Setting')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6522, N'Skill General Setting', 6518, 222, 1, N'HRMS/Skill_General_Setting.aspx', N'menu/company_structure.gif', 1, N'Skill General Setting')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6523, N'Assign Goal', 6518, 223, 1, N'HRMS/Assign_Goal.aspx', N'menu/company_structure.gif', 1, N'Assign Goal')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6524, N'Employee Skill Rating', 6518, 224, 1, N'HRMS/Employee_Skill_Rating.aspx', N'menu/company_structure.gif', 1, N'Employee Skill Rating')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6525, N'Initiate Appraisal', 6518, 225, 1, N'HRMS/Initiate_Appraisal.aspx?ID=1', N'menu/company_structure.gif', 1, N'Initiate Appraisal')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6526, N'Appraisal Approval', 6518, 226, 1, N'HRMS/Appraisal_Effection_Payroll.aspx', N'menu/company_structure.gif', 1, N'Appraisal Approval')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6527, N'Initiate Appraisal Report', 6518, 227, 1, N'HRMS/Initiated_Appraisal_Report.aspx', N'menu/company_structure.gif', 1, N'Initiate Appraisal Report')



INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6528, N'Performance Appraisal', -1, 230, 1, N'HRMS/HR_Home.aspx', N'menu/job_master.gif', 1, N'Performance Appraisal')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6529, N'Performance Rating Master', 6528, 231, 1, N'HRMS/NewAppraisal_Master_Rating.aspx', N'menu/job_master.gif', 1, N'Performance Rating Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6530, N'GoalType Master', 6528, 232, 1, N'HRMS/NewAppraisal_Master_GoalType.aspx', N'menu/job_master.gif', 1, N'GoalType Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6531, N'Competency Master', 6528, 233, 1, N'HRMS/NewAppraisal_Master_SOL.aspx', N'menu/job_master.gif', 1, N'Competency Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6532, N'Setting Master', 6528, 234, 1, N'HRMS/NewAppraisal_Master_SignoffSetting.aspx', N'menu/job_master.gif', 1, N'Setting Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6533, N'Review Employee Goal', 6528, 235, 1, N'HRMS/NewAppraisal_ReviewGoal.aspx', N'menu/job_master.gif', 1, N'Review Employee Goal')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6534, N'Review Performance Summary', 6528, 236, 1, N'HRMS/NewAppraisal_ReviewPerformanceSummary.aspx', N'menu/job_master.gif', 1, N'Review Performance Summary')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6535, N'Review Competency', 6528, 237, 1, N'HRMS/NewAppraisal_ReviewSOL.aspx', N'menu/job_master.gif', 1, N'Review Competency')

INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6536, N'HR Documents', -1, 240, 1, N'HRMS/HR_Home.aspx', N'menu/leave_management.gif', 1, N'HR Documents')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6537, N'HR Document Master', 6536, 241, 1, N'admin_associates/Master_hr_Document.aspx', N'menu/leave_management.gif', 1, N'HR Document Master')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6538, N'Export Employee Document', 6536, 242, 1, N'admin_associates/employee_hr_document.aspx', N'menu/leave_management.gif', 1, N'Export Employee Document')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6539, N'Employee Document History', 6536, 243, 1, N'admin_associates/view_emp_doc_history.aspx', N'menu/leave_management.gif', 1, N'Employee Document History')

INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6540, N'Organogram', -1, 245, 1, N'HRMS/HR_Home.aspx', N'menu/desig.png', 1, N'Organogram')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6541, N'Organization Organogram', 6540, 246, 1, N'admin_associates/desig_chart.aspx', N'menu/desig.png', 1, N'Organization Organogram')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6542, N'Employee Organogram', 6540, 247, 1, N'admin_associates/Org_chart.aspx', N'menu/desig.png', 1, N'Employee Organogram')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6852, N'Employee Organogram', 6540, 247, 1, N'admin_associates/Org_chart_tree_view.aspx', N'menu/desig.png', 1, N'Employee Organogram Tree View') ---added by Sid for New OrgChart	
-- Commented and Added by rohit on 11-feb-2014 for Merge bma Code -- End


---- Admin Side report Form id from 6700 to 6999
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6701, N'Employee Reports', 6163, 171, 1, NULL, NULL, 1, N'Employee Reports')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6702, N'Attendance Reports', 6163, 173, 1, NULL, NULL, 1, N'Attendance Reports')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias], [Page_Flag])values(6703, N'Leave Reports', 6163, 175, 1, NULL, NULL, 1, N'Leave Reports', 'AR')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6704, N'Loan LIC Reports', 6163, 177, 1, NULL, NULL, 1, N'Loan Reports')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6705, N'Salary Reports', 6163, 179, 1, NULL, NULL, 1, N'Salary Reports')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6706, N'PF Reports', 6163, 181, 1, NULL, NULL, 1, N'PF Reports')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6707, N'ESIC Reports', 6163, 183, 1, NULL, NULL, 1, N'ESIC Reports')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6708, N'PT Reports', 6163, 185, 1, NULL, NULL, 1, N'PT Reports')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6709, N'Letters', 6163, 187, 1, NULL, NULL, 1, N'Letters')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6710, N'TAX Reports', 6163, 189, 1, NULL, NULL, 1, N'TAX Reports')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6711, N'Gratuity Bonus HRIS', 6163, 191, 1, NULL, NULL, 1, N'Gratuity Bonus HRIS')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6712, N'Other Reports', 6163, 193, 1, NULL, NULL, 1, N'Other Reports')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6713, N'Gratuity Report', 6163, 195, 1, NULL, NULL, 1, N'Gratuity Report')

INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6714, N'Customize Report', 6701, 172, 1, NULL, NULL, 1, N'Customize Report')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6715, N'Employee List(Form-13)', 6701, 172, 1, NULL, NULL, 1, N'Employee List(Form-13)')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6716, N'Employee CTC', 6701, 172, 1, NULL, NULL, 1, N'Employee CTC')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6717, N'Left Employee', 6701, 172, 1, NULL, NULL, 1, N'Left Employee')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6718, N'Shift Report', 6701, 172, 1, NULL, NULL, 1, N'Shift Report')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6719, N'Weekly Off', 6701, 172, 1, NULL, NULL, 1, N'Weekly Off')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6720, N'Employee Warning', 6701, 172, 1, NULL, NULL, 1, N'Employee Warning')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6721, N'Employee Insurance2', 6701, 172, 1, NULL, NULL, 1, N'Employee Insurance2')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6722, N'Asset Position', 6701, 172, 1, NULL, NULL, 1, N'Asset Position')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6723, N'Employee Salary Structure', 6701, 172, 1, NULL, NULL, 1, N'Employee Salary Structure')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6724, N'Employee Birthday List', 6701, 172, 1, NULL, NULL, 1, N'Employee Birthday List')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6725, N'Active/InActive User History', 6701, 172, 1, NULL, NULL, 1, N'Active/InActive User History')

INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6726, N'Attendance Register', 6702, 174, 1, NULL, NULL, 1, N'Attendance Register')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6727, N'In-Out Register', 6702, 174, 1, NULL, NULL, 1, N'In-Out Register')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6728, N'Holiday Work', 6702, 174, 1, NULL, NULL, 1, N'Holiday Work')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6729, N'In-Out Summary ', 6702, 174, 1, NULL, NULL, 1, N'In-Out Summary ')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6730, N'Missing In-out', 6702, 174, 1, NULL, NULL, 1, N'Missing In-out')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6731, N'Late/Early Mark Summary', 6702, 174, 1, NULL, NULL, 1, N'Late/Early Mark Summary')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6732, N'Device Inout Summary', 6702, 174, 1, NULL, NULL, 1, N'Device Inout Summary')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6733, N'Employee Inout Present Days', 6702, 174, 1, NULL, NULL, 1, N'Employee Inout Present Days')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6734, N'Daily Attendance', 6702, 174, 1, NULL, NULL, 1, N'Daily Attendance')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6735, N'Login History', 6702, 174, 1, NULL, NULL, 1, N'Login History')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6736, N'Absent', 6702, 174, 1, NULL, NULL, 1, N'Absent')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6737, N'Attendance Regularization', 6702, 174, 1, NULL, NULL, 1, N'Attendance Regularization')

INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6738, N'Leave Approval', 6703, 176, 1, NULL, NULL, 1, N'Leave Approval')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6739, N'Leave Balance', 6703, 176, 1, NULL, NULL, 1, N'Leave Balance')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6740, N'Leave Closing', 6703, 176, 1, NULL, NULL, 1, N'Leave Closing')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6741, N'Yearly Leave Summary', 6703, 176, 1, NULL, NULL, 1, N'Yearly Leave Summary')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6742, N'Yearly Leave Transaction ', 6703, 176, 1, NULL, NULL, 1, N'Yearly Leave Transaction ')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6743, N'Yearly Leave Encash', 6703, 176, 1, NULL, NULL, 1, N'Yearly Leave Encash')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6744, N'Leave Register with wages', 6703, 176, 1, NULL, NULL, 1, N'Leave Register with wages')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6745, N'Leave Card (Form-19)', 6703, 176, 1, NULL, NULL, 1, N'Leave Card (Form-19)')

INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6746, N'Monthly Loan Payment', 6704, 178, 1, NULL, NULL, 1, N'Monthly Loan Payment')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6747, N'Loan Approval', 6704, 178, 1, NULL, NULL, 1, N'Loan Approval')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6748, N'Loan Number', 6704, 178, 1, NULL, NULL, 1, N'Loan Number')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6749, N'Loan Statement Report', 6704, 178, 1, NULL, NULL, 1, N'Loan Statement Report')

INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6750, N'Salary Slip Weekly Basis', 6705, 180, 1, NULL, NULL, 1, N'Salary Slip Weekly Basis')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6751, N'Salary Register Daily Basis', 6705, 180, 1, NULL, NULL, 1, N'Salary Register Daily Basis')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6752, N'Salary Register(Allo/Ded)', 6705, 180, 1, NULL, NULL, 1, N'Salary Register(Allo/Ded)')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6753, N'Register With Settlement', 6705, 180, 1, NULL, NULL, 1, N'Register With Settlement')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6754, N'Allowance/Deduction Report', 6705, 180, 1, NULL, NULL, 1, N'Allowance/Deduction Report')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6755, N'Yearly Salary', 6705, 180, 1, NULL, NULL, 1, N'Yearly Salary')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6756, N'Yearly Advance', 6705, 180, 1, NULL, NULL, 1, N'Yearly Advance')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6757, N'Yearly Attendance ', 6705, 180, 1, NULL, NULL, 1, N'Yearly Attendance ')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6758, N'Pending Advance', 6705, 180, 1, NULL, NULL, 1, N'Pending Advance')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6759, N'Employee Overtime', 6705, 180, 1, NULL, NULL, 1, N'Employee Overtime')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6760, N'Employee Daily Overtime ', 6705, 180, 1, NULL, NULL, 1, N'Employee Daily Overtime ')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6761, N'Bank Statement', 6705, 180, 1, NULL, NULL, 1, N'Bank Statement')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6762, N'Allowance Export', 6705, 180, 1, NULL, NULL, 1, N'Allowance Export')

INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6763, N'PF Statement', 6706, 182, 1, NULL, NULL, 1, N'PF Statement')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6764, N'PF Statement Sett', 6706, 182, 1, NULL, NULL, 1, N'PF Statement Sett')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6765, N'PF Challan', 6706, 182, 1, NULL, NULL, 1, N'PF Challan')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6766, N'PF Challan Sett', 6706, 182, 1, NULL, NULL, 1, N'PF Challan Sett')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6767, N'Form2', 6706, 182, 1, NULL, NULL, 1, N'Form2')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6768, N'Form05', 6706, 182, 1, NULL, NULL, 1, N'Form05')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6769, N'Form10', 6706, 182, 1, NULL, NULL, 1, N'Form10')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6770, N'Form12A', 6706, 182, 1, NULL, NULL, 1, N'Form12A')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6771, N'Form3A-Yearly', 6706, 182, 1, NULL, NULL, 1, N'Form3A-Yearly')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6772, N'Form6A-Yearly', 6706, 182, 1, NULL, NULL, 1, N'Form6A-Yearly')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6773, N'Form13 (Revised)', 6706, 182, 1, NULL, NULL, 1, N'Form13 (Revised)')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6774, N'PF Employer Contribution', 6706, 182, 1, NULL, NULL, 1, N'PF Employer Contribution')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6775, N'PF Statement for Inspection', 6706, 182, 1, NULL, NULL, 1, N'PF Statement for Inspection')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6776, N'Employee Pension Scheme-10C ', 6706, 182, 1, NULL, NULL, 1, N'Employee Pension Scheme-10C ')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6777, N'Employee Pension Scheme-10D', 6706, 182, 1, NULL, NULL, 1, N'Employee Pension Scheme-10D')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6778, N'PF FORM 11', 6706, 182, 1, NULL, NULL, 1, N'PF FORM 11')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6779, N'PF FORM 19 ', 6706, 182, 1, NULL, NULL, 1, N'PF FORM 19 ')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6780, N'PF FORM 20 ', 6706, 182, 1, NULL, NULL, 1, N'PF FORM 20 ')



INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6781, N'ESIC Statement', 6707, 184, 1, NULL, NULL, 1, N'ESIC Statement')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6782, N'ESIC Challan', 6707, 184, 1, NULL, NULL, 1, N'ESIC Challan')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6783, N'Form 1(Declaration)', 6707, 184, 1, NULL, NULL, 1, N'Form 1(Declaration)')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6784, N'Form 3', 6707, 184, 1, NULL, NULL, 1, N'Form 3')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6785, N'Form 5', 6707, 184, 1, NULL, NULL, 1, N'Form 5')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6786, N'Form 6', 6707, 184, 1, NULL, NULL, 1, N'Form 6')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6787, N'Form 7', 6707, 184, 1, NULL, NULL, 1, N'Form 7')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6788, N'ESIC Challan Sett', 6707, 184, 1, NULL, NULL, 0, N'ESIC Challan Sett') /* InActive Form & Report - Ankit 04072016 */  --Change By Jaina 31-08-2016
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6789, N'ESIC Statement Sett', 6707, 184, 1, NULL, NULL, 0, N'ESIC Statement Sett') /* InActive Form & Report - Ankit 04072016 */ --Change By Jaina 31-08-2016
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6790, N'ESIC Employer', 6707, 184, 1, NULL, NULL, 1, N'ESIC Employer')

INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6791, N'PT Challan', 6708, 186, 1, NULL, NULL, 1, N'PT Challan')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6792, N'PT Statement', 6708, 186, 1, NULL, NULL, 1, N'PT Statement')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6793, N'PT Statement Sett', 6708, 186, 1, NULL, NULL, 1, N'PT Statement Sett')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6794, N'PT Form5', 6708, 186, 1, NULL, NULL, 1, N'PT Form5')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6795, N'PT Form5A', 6708, 186, 1, NULL, NULL, 1, N'PT Form5A')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6796, N'LWF Statement FORM A', 6708, 186, 1, NULL, NULL, 1, N'LWF Statement FORM A')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6797, N'Form 9-A', 6708, 186, 1, NULL, NULL, 1, N'Form 9-A')

INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6798, N'Offer Letter', 6709, 188, 1, NULL, NULL, 1, N'Offer Letter')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6799, N'Appoint Letter', 6709, 188, 1, NULL, NULL, 1, N'Appoint Letter')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6800, N'Resignation Letter', 6709, 188, 1, NULL, NULL, 1, N'Resignation Letter')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6801, N'Joining Letter', 6709, 188, 1, NULL, NULL, 1, N'Joining Letter')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6802, N'Confirmation Letter', 6709, 188, 1, NULL, NULL, 1, N'Confirmation Letter')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6803, N'Experience Letter', 6709, 188, 1, NULL, NULL, 1, N'Experience Letter')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6804, N'Reliever Letter', 6709, 188, 1, NULL, NULL, 1, N'Reliever Letter')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6805, N'Termination Letter', 6709, 188, 1, NULL, NULL, 1, N'Termination Letter')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6806, N'F & F Letter', 6709, 188, 1, NULL, NULL, 1, N'F & F Letter')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6807, N'Increment Letter', 6709, 188, 1, NULL, NULL, 1, N'Increment Letter')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6808, N'Forwarding Letter', 6709, 188, 1, NULL, NULL, 1, N'Forwarding Letter')

INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6809, N'Income Tax Declaration', 6710, 190, 1, NULL, NULL, 1, N'Income Tax Declaration')
-----------------added jimit 29032016---------------------------
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6840, N'Tax Consolidate Report', 6710, 190, 1, NULL, NULL, 1, N'Tax Consolidate Report')
-----------------ended---------------------------
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6810, N'Tax Computation', 6710, 190, 1, NULL, NULL, 1, N'Tax Computation')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6811, N'Form -16(IT)', 6710, 190, 1, NULL, NULL, 1, N'Form -16(IT)')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6812, N'Employee Tax Report', 6710, 190, 1, NULL, NULL, 1, N'Employee Tax Report')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6813, N'TDS Challan', 6710, 190, 1, NULL, NULL, 1, N'TDS Challan')

INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6814, N'Bonus Statement', 6711, 192, 1, NULL, NULL, 1, N'Bonus Statement')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6815, N'Bonus(Form C)', 6711, 192, 1, NULL, NULL, 1, N'Bonus(Form C)')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6816, N'Employee Status', 6711, 192, 1, NULL, NULL, 1, N'Employee Status')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6817, N'Employee Strength', 6711, 192, 1, NULL, NULL, 1, N'Employee Strength')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6818, N'Employee Variance Report', 6711, 192, 1, NULL, NULL, 1, N'Employee Variance Report')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6819, N'Salary Variance Report', 6711, 192, 1, NULL, NULL, 1, N'Salary Variance Report')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6820, N'Gratuity', 6711, 192, 1, NULL, NULL, 1, N'Gratuity')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6839, N'Gratuity Statement', 6711, 192, 1, NULL, NULL, 1, N'Gratuity Statement')
																																										

INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6821, N'Leave Encashment paid', 6712, 194, 1, NULL, NULL, 1, N'Leave Encashment paid')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6822, N'Fitness Certificate', 6712, 194, 1, NULL, NULL, 1, N'Fitness Certificate')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6823, N'Health Register-Form32', 6712, 194, 1, NULL, NULL, 1, N'Health Register-Form32')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6824, N'Adult Worker Register', 6712, 194, 1, NULL, NULL, 1, N'Adult Worker Register')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6825, N'Exit Interview ', 6712, 194, 1, NULL, NULL, 1, N'Exit Interview ')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6826, N'Clearance Form', 6712, 194, 1, NULL, NULL, 1, N'Clearance Form')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6827, N'Form ER 1 ', 6712, 194, 1, NULL, NULL, 1, N'Form ER 1 ')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6828, N'Form ER 2', 6712, 194, 1, NULL, NULL, 1, N'Form ER 2')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6829, N'Consolidated Annual Return', 6712, 194, 1, NULL, NULL, 1, N'Consolidated Annual Return')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6830, N'Form-25', 6712, 194, 1, NULL, NULL, 1, N'Form-25')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6831, N'Holiday Details', 6712, 194, 1, NULL, NULL, 1, N'Holiday Details')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6832, N'Travel Detail', 6712, 194, 1, NULL, NULL, 1, N'Travel Detail')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6833, N'Travel Settlement ', 6712, 194, 1, NULL, NULL, 1, N'Travel Settlement ')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6834, N'Travel Settlement Status', 6712, 194, 1, NULL, NULL, 1, N'Travel Settlement Status')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6835, N'Employee Probation', 6712, 194, 1, NULL, NULL, 1, N'Employee Probation')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6836, N'Employee Insurance', 6712, 194, 1, NULL, NULL, 1, N'Employee Insurance')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6837, N'Leave Allowance Detail', 6712, 194, 1, NULL, NULL, 1, N'Leave Allowance Detail')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6838, N'Memo Report', 6712, 194, 1, NULL, NULL, 1, N'Memo Report')

------------------------added by jimit 03092016 for change request approval------------------------------------------------------------------------------------
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6841, N'Employee Change Request Approval', 6701, 172, 1, NULL, NULL, 1, N'Employee Change Request Approval')
--------------------------------ended----------------------------------------------------------------------------------------------
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6842, N'Contractor Reports', 6163, 185, 1, NULL, NULL, 1, N'Contractor Reports')




---- Ess Side panel Form id from 7000 to 7499
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7000, N'ESS Module', -1, 300, 1, NULL, NULL, 1, N'ESS Module')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7001, N'Employee', -1, 301, 1, N'Home.aspx', N'menu/info.gif', 1, N'Employee')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7001, N'Employee', -1, 301, 1, N'Home.aspx', @Employee_Img, 1, N'Employee')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7002, N'My Profile', 7001, 302, 1, N'Default.aspx', @Employee_Img, 1, N'My Profile')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7003, N'Change Password Ess ', 7001, 303, 1, N'Changepassword.aspx', @Employee_Img, 1, N'Change Password Ess ')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7004, N'My In Out', 7001, 304, 1, N'emp_inout_new.aspx', @Employee_Img, 1, N'My In Out')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7005, N'Leave', -1, 308, 1, N'Home.aspx', @Leave_Img, 1, N'Leave')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7006, N'Leave Application', 7005, 309, 1, N'Leave_application.aspx', @Leave_Img, 1, N'Leave Application')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7007, N'Leave Approval', 7005, 310, 1, N'Leave_Approve.aspx', @Leave_Img, 1, N'Leave Approval')
--Commented binal 04122019
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7008, N'Leave Status', 7005, 311, 1, N'Leave_Status.aspx', @Leave_Img, 1, N'Leave Status')

INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7009, N'Leave Encashment Application', 7005, 312, 1, N'Leave_Encashment_Application.aspx', @Leave_Img, 1, N'Leave Encashment Application')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7010, N'Loan LIC', -1, 315, 1, N'Home.aspx', @Loan_Claim_Img, 1, N'Loan')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7011, N'Loan LIC Application', 7010, 316, 1, N'Loan_Application.aspx', @Loan_Claim_Img, 1, N'Loan Application')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7012, N'Loan LIC Status', 7010, 317, 1, N'Loan_Status.aspx', @Loan_Claim_Img, 1, N'Loan Status')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7013, N'Claim', -1, 320, 1, N'Home.aspx', @Loan_Claim_Img, 1, N'Claim')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7014, N'Claim Application', 7013, 321, 1, N'Claim_Application.aspx', @Loan_Claim_Img, 1, N'Claim Application')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7015, N'Claim Status', 7013, 322, 1, N'Claim_status.aspx', @Loan_Claim_Img, 1, N'Claim Status')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7016, N'LTA Medical', -1, 327, 1, N'Home.aspx', N'menu/LM.gif', 0, N'LTA Medical')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7017, N'LTA Medical Application', 7016, 328, 1, N'LTA_Medical_Application.aspx', N'menu/LM.gif', 0, N'LTA Medical Application')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7018, N'LTA Medical History', 7016, 329, 1, N'LTA_Medical_History.aspx', N'menu/LM.gif', 0, N'LTA Medical History')
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7019, N'Salary Detail', -1, 330, 1, N'Home.aspx', N'menu/rupee.gif', 1, N'Salary Detail')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7019, N'Salary Detail', -1, 330, 1, N'Home.aspx', @Salary_Img, 1, N'Salary Detail')

--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7020, N'Performance Detail', 7019, 331, 1, N'Employee_performance.aspx', N'menu/rupee.gif', 1, N'Performance Detail')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7020, N'Performance Detail', 7019, 331, 1, N'Employee_performance.aspx',@Salary_Img, 1, N'Performance Detail')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7021, N'IT Declaration Form', 7019, 332, 1, N'IT_Declaration_User_With_Detail.aspx', @Salary_Img, 1, N'IT Declaration Form')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7022, N'Salary Slip', 7019, 333, 1, N'Salary_Slip.aspx', @Salary_Img, 0, N'Salary Slip')  --Mukti(25062016)Inactive form Salary Slip
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7023, N'My Team', -1, 340, 1, N'Home.aspx', @Employee_Img, 1, N'My Team')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7024, N'WeekOff', 7023, 341, 1, N'Employee_Weekoff_Superior.aspx', @Employee_Img, 1, N'WeekOff')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7025, N'Over Time', 7023, 342, 1, N'Employee_OT.aspx', @Employee_Img, 1, N'Over Time')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7027, N'Shift Change', 7023, 344, 1, N'Employee_Shift_Change_Superior.aspx', @Masters_Img, 1, N'Shift Change')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7028, N'Member Details', 7023, 345, 1, N'Employee_Downline.aspx', @Employee_Img, 1, N'Member Details')

--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7029, N'HRMS', -1, 370, 1, N'Home.aspx', N'menu/process.png', 1, N'HRMS')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7029, N'HRMS', -1, 370, 1, N'Home.aspx', @HR_Img, 1, N'HRMS')

INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7030, N'Organization Organogram', 7029, 371, 1, N'desig_chart.aspx', @HR_Img, 1, N'Organization Organogram')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7031, N'Employee Organogram', 7029, 372, 1, N'org_chart.aspx', @HR_Img, 1, N'Employee Organogram')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7032, N'Document History', 7029, 372, 1, N'View_Emp_Doc_History.aspx', @HR_Img, 1, N'Document History')  --Edit By Ripal 07Oct2013 (373 to 372)
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7033, N'Training Application', 7029, 374, 1, N'Hrms_Training_Application.aspx', @HR_Img, 1, N'Training Application')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7034, N'Training History', 7029, 375, 1, N'Hrms_Training_Feedback.aspx',@HR_Img, 1, N'Training History')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7035, N'Training Chart', 7029, 376, 1, N'hrms_Training_Chart.aspx', @HR_Img, 1, N'Training Chart')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7036, N'Recruitment Request', 7029, 377, 1, N'HRMS_Recruitment_Request.aspx', @HR_Img, 1, N'Recruitment Request')

--(7037, N'Interview Process Acceptance', 7029, 378, 1, N'HRMS_Interview_Process.aspx', N'menu/process.png', 1, N'Interview Process Acceptance')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7038, N'Interview Process', 7029, 379, 1, N'HRMS_RECRUITMENT_PROCESS_DETAIL.aspx', @HR_Img, 1, N'Interview Process')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7039, N'Appraisal Detail', 7029, 380, 1, N'Appraisal_List_Emp.aspx',@HR_Img, 1, N'Appraisal Detail')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7040, N'Employee Appraisal Process Data', 7029, 381, 1, N'Appraisal_List.aspx', @HR_Img, 1, N'Employee Appraisal Process Data')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7041, N'Admin Leave Approval', 7005, 313, 1, N'Leave_Admin_Approve_Superior.aspx', @Leave_Img, 1, N'Admin Leave Approval')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7042, N'Member In Out Records', 7023, 346, 1, N'Employee_Downline_Inout_Record.aspx', @Employee_Img, 1, N'Member In Out Records')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7043, N'Leave Cancellation', 7005, 314, 1, N'Leave_Cancellation_Application.aspx',@Leave_Img, 1, N'Leave Cancellation')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7044, N'Leave Cancellation Approval Member', 7005, 314, 1, N'Leave_Cancelation_Approval.aspx', @Leave_Img, 1, N'Leave Cancellation Approval Member')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7045, N'Comp Off', 7005, 314, 1, N'Home.aspx',@Leave_Img, 1, N'Comp Off')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7046, N'Comp Off Application', 7045, 314, 1, N'CompOff_Application.aspx', @Leave_Img, 1, N'Comp Off Application')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7047, N'Comp Off Approval', 7045, 314, 1, N'CompOff_Approval.aspx', @Leave_Img, 1, N'Comp Off Approval')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7048, N'Optional Holiday Application', 7001, 305, 1, N'Option_Holiday_Application.aspx', @Employee_Img, 1, N'Optional Holiday Application')

--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7049, N'Exit', -1, 408, 1, N'Home.aspx', N'menu/exit.png', 1, N'Exit')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7049, N'Exit', -1, 408, 1, N'Home.aspx', @Masters_Img, 1, N'Exit')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7050, N'Exit Application', 7049, 409, 1, N'Emp_ExitApplication.aspx',@Masters_Img, 1, N'Exit Application')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7051, N'Exit Feedback', 7049, 410, 1, N'Emp_ManagerFeedback.aspx', @Masters_Img, 1, N'Exit Approval')  --Alias Name Change By Jaina 19-10-2015

INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7052, N'Travel Details', -1, 323, 1, N'Home.aspx', @Loan_Claim_Img, 1, N'Travel Details')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7053, N'Advance', 7019, 334, 1, N'Home.aspx', @Salary_Img, 1, N'Advance')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7054, N'Advance Application', 7053, 334, 1, N'Salary_Advance_Application.aspx', @Salary_Img, 1, N'Advance Application')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7055, N'Advance Approval', 7053, 334, 1, N'Salary_Advance_Approval.aspx', @Salary_Img, 1, N'Advance Approval')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7056, N'Advance Status', 7053, 334, 1, N'Salary_Adavance_Status.aspx',@Salary_Img, 1, N'Advance Status')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7057, N'Travel Application', 7052, 324, 1, N'Travel_Application.aspx', @Loan_Claim_Img, 1, N'Travel Application')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7058, N'Travel Settlement', 7052, 326, 1, N'TravelSettlement.aspx', @Loan_Claim_Img, 1, N'Travel Settlement')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7059, N'Travel Approvals ', 7052, 325, 1, N'Travel_Approval_Superior.aspx', @Loan_Claim_Img, 1, N'Travel Approvals ')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7060, N'Travel Settlement Approvals', 7052, 327, 1, N'Travel_Settlement_Approval_Superior.aspx', @Loan_Claim_Img, 1, N'Travel Settlement Approvals')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7061, N'Member Reports', 7023, 347, 1, N'Report_Employee_List.aspx', @Employee_Img, 1, N'Member Reports')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7062, N'My Reports', -1, 385, 1, N'Report_Mine.aspx',@Report_Img, 1, N'My Reports')


---- Report Of Ess Side Form id from 7500 to end
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7501, N'Employee Reports Member#', 7061, 347, 1, NULL, NULL, 1, N'Employee Reports Member#') 
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7502, N'Employee List(Form-13) Member#', 7501, 347, 1, NULL, NULL, 1, N'Employee List(Form-13) Member#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7503, N'Attendance Reports Member#', 7061, 347, 1, NULL, NULL, 1, N'Attendance Reports Member#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7504, N'Attendance Register Member#', 7503, 347, 1, NULL, NULL, 1, N'Attendance Register Member#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7505, N'In-Out Summary Member#', 7503, 347, 1, NULL, NULL, 1, N'In-Out Summary Member#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7506, N'Employee Inout Present Member#', 7503, 347, 1, NULL, NULL, 1, N'Employee Inout Present Member#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7507, N'Leave Reports Member#', 7061, 347, 1, NULL, NULL, 1, N'Leave Reports Member#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7508, N'Leave Approval Member#', 7507, 347, 1, NULL, NULL, 1, N'Leave Approval Member#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7509, N'Leave Balance Member#', 7507, 347, 1, NULL, NULL, 1, N'Leave Balance Member#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7510, N'Yearly Leave Transaction Member#', 7507, 347, 1, NULL, NULL, 1, N'Yearly Leave Transaction Member#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7511, N'Loan Reports Member#', 7061, 347, 1, NULL, NULL, 1, N'Loan Reports Member#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7512, N'Loan Approval Member#', 7511, 347, 1, NULL, NULL, 1, N'Loan Approval Member#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7513, N'Loan Statement Report Member#', 7511, 347, 1, NULL, NULL, 1, N'Loan Statement Report Member#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7514, N'Other Reports Member#', 7061, 347, 1, NULL, NULL, 1, N'Other Reports Member#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7515, N'Salary Slip Member#', 7514, 347, 1, NULL, NULL, 1, N'Salary Slip Member#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7516, N'Yearly Salary Member#', 7514, 347, 1, NULL, NULL, 1, N'Yearly Salary Member#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7517, N'PF Statement Member#', 7514, 347, 1, NULL, NULL, 1, N'PF Statement Member#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7518, N'Tax Preparation Member#', 7514, 347, 1, NULL, NULL, 1, N'Tax Preparation Member#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7519, N'Form-16(IT) Member#', 7514, 347, 1, NULL, NULL, 1, N'Form-16(IT) Member#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7521, N'Attendance Reports My#', 7062, 386, 1, NULL, NULL, 1, N'Attendance Reports My#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7522, N'Attendance Register My#', 7521, 387, 1, NULL, NULL, 1, N'Attendance Register My#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7523, N'In-Out Summary My#', 7521, 388, 1, NULL, NULL, 1, N'In-Out Summary My#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7524, N'Employee Inout Present My#', 7521, 389, 1, NULL, NULL, 1, N'Employee Inout Present My#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7525, N'Leave Reports My#', 7062, 390, 1, NULL, NULL, 1, N'Leave Reports My#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7526, N'Leave Approval My#', 7525, 391, 1, NULL, NULL, 1, N'Leave Approval My#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7527, N'Leave Balance My#', 7525, 392, 1, NULL, NULL, 1, N'Leave Balance My#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7528, N'Yearly Leave Transaction My#', 7525, 393, 1, NULL, NULL, 1, N'Yearly Leave Transaction My#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7529, N'Loan Reports My#', 7062, 394, 1, NULL, NULL, 1, N'Loan Reports My#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7530, N'Loan Approval My#', 7529, 395, 1, NULL, NULL, 1, N'Loan Approval My#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7531, N'Loan Statement Report My#', 7529, 396, 1, NULL, NULL, 1, N'Loan Statement Report My#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7532, N'Other Reports My#', 7062, 397, 1, NULL, NULL, 1, N'Other Reports My#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7533, N'Salary Slip My#', 7532, 398, 1, NULL, NULL, 1, N'Salary Slip My#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7534, N'Yearly Salary My#', 7532, 399, 1, NULL, NULL, 1, N'Yearly Salary My#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7535, N'PF Statement My#', 7532, 400, 1, NULL, NULL, 1, N'PF Statement My#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7536, N'Tax Preparation My#', 7532, 401, 1, NULL, NULL, 1, N'Tax Preparation My#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7537, N'Form-16(IT) My#', 7532, 402, 1, NULL, NULL, 1, N'Form-16(IT) My#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7538, N'CTC letter (Annexure) My#', 7532, 402, 1, NULL, NULL, 1, N'CTC letter (Annexure) My#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7539, N'Travel Report My#', 7062, 403, 1, NULL, NULL, 1, N'Travel Report My#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7540, N'Travel Detail My#', 7539, 404, 1, NULL, NULL, 1, N'Travel Detail My#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7541, N'Travel Settlement My#', 7539, 405, 1, NULL, NULL, 1, N'Travel Settlement My#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7542, N'Travel Statement My#', 7539, 406, 1, NULL, NULL, 1, N'Travel Statement My#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7543, N'Travel Settlement Status My#', 7539, 407, 1, NULL, NULL, 1, N'Travel Settlement Status My#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7546, N'GatePass InOut My#', 7525, 393, 1, NULL, NULL, 1, N'GatePass InOut My#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7545, N'GatePass InOut Member#', 7507, 347, 1, NULL, NULL, 1, N'GatePass InOut My#')

--Added By Jaina 9-10-2015
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7561, N'Late/Early Mark Summary My#', 7521, 389, 1, NULL, NULL, 1, N'Late/Early Mark Summary My#')
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(7562, N'Late/Early Mark Summary Member#', 7503, 347, 1, NULL, NULL, 1, N'Late/Early Mark Summary Member#')





end

if @ver_update=1
Begin 
	-- For Add menu Admin Side use form id between 6000 to 6499
	-- For Add menu Hrms side use Form Id between 6500 to 6699
	-- For Add menu Admin report Side use Form Id 6700 to 6999
	-- For Add menu Ess Side use Form id 7000 to 7499
	-- For Add report Ess Side use Form Id between 7500 to 7999
	--You Do not Understand that then please contact Rohit for Add new Menu 
-- Commented by rohit this is for sample only
--if not exists (select Form_id from T0000_DEFAULT_FORM where  Form_name = 'Menu Master')
--	begin
--		declare @Menu_id1 numeric
--		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID > 6000 and Form_ID < 6500
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
--		values (@Menu_id1,'Menu Master',6001,11,1,'Menu_Master.aspx','menu/IP_Master.gif',1,'Menu Master')
--	end
	declare @Menu_id1 numeric
	--For Reim/Claim 
	declare @Temp_Form_ID1 numeric
	-- Added by rohit for Home page Rights on 01-nov-2013
	exec P0000_Home_Page_New @ver_update
	-- Ended by rohit on 01-nov-2013
	--set @Control_Pnl_Img=N'menu/Control_Panel.gif'
	--set @Masters_Img=N'menu/master.gif'
	--set @Report_Img=N'menu/reports.gif'
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Admin Setting')
	begin
	
		--select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID > 6000 and Form_ID < 6500
		--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		--values (@Menu_id1,'Admin Setting',6001,14,1,'GuestAdmin.aspx','menu/company_updates.gif',1,'Admin Setting')
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Admin Setting',6001,14,1,'GuestAdmin.aspx',@Control_Pnl_Img,1,'Admin Setting')
	end


-------------------------------------------------------------------------- Prakash ---------------------------------------------------------------------------------------------
   ------------------------ Timesheet Form Id from 8001 to 8999  Add by Prakash Patel 18122014 -------------------------------------------------------------------       

If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Timesheet Management'  AND  Form_ID > 6000 and Form_ID < 6500   )      
	BEGIN
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500      
		--set @Temp_Form_ID1   = @Menu_id1
 
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check])
		values(@Menu_id1, N'Timesheet Management', -1, 248, 1, N'Home.aspx', @timesheet_img, 1,N'Timesheet',0)    
		--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check])
		--values(@Menu_id1, N'Timesheet Management', -1, 248, 1, N'../Timesheet/Timesheet_Home.aspx', N'menu/process.png', 1,N'Timesheet',0)    
	END
--If not exists (select Form_id from T0000_DEFAULT_FORM where  Form_name = 'Timesheet Home'  AND  Form_ID > 6700 and Form_ID < 7000)      
--	BEGIN
--		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID > 6700 and Form_ID < 7000
--		set @Temp_Form_ID1   = @Menu_id1
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check])
--		values(@Menu_id1, N'Timesheet Home', -1, 249, 1, N'Timesheet/Timesheet_Home.aspx', N'menu/process.png', 1,N'Timesheet',0)    
--	END
--If not exists (select Form_id from T0000_DEFAULT_FORM where  Form_name = 'Timesheet')      
--	BEGIN
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check])
--		values(8002, N'Timesheet', -1, 501, 1, N'Timesheet/Timesheet_Home.aspx', N'menu/process.png', 1,N'Timesheet',1)   
--	END

select @Temp_Form_ID1 = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Timesheet Management'  AND  Form_ID > 6000 and Form_ID < 6500   

If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Client Master' AND Form_ID > 6000  and Form_ID < 6500)     
	BEGIN
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check])
		values(@Menu_id1, N'Client Master', @Temp_Form_ID1, 249, 1, N'Master_Client.aspx', @timesheet_img, 1,N'Client Master',1)  
	END

If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Speciality Master' AND Form_ID > 6000  and Form_ID < 6500)     
	BEGIN
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check])
		values(@Menu_id1, N'Speciality Master', @Temp_Form_ID1, 249, 1, N'Master_Speciality.aspx', @timesheet_img, 1,N'Speciality Master',1)  
	END 	

If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Status Master' AND  Form_ID > 6000 and Form_ID < 6500)     
	BEGIN
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check])
		values(@Menu_id1, N'Status Master', @Temp_Form_ID1, 250, 1, N'Master_ProjectStatus.aspx', @timesheet_img, 1,N'Status Master',2)
	END
If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Milestone Master' AND  Form_ID > 6000 and Form_ID < 6500)
	BEGIN
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check])
		values(@Menu_id1, N'Milestone Master', @Temp_Form_ID1, 251, 1, N'Master_Milestone.aspx',@timesheet_img, 1,N'Milestone Master',3)    
	END
If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Task Type Master' AND  Form_ID > 6000 and Form_ID < 6500)     
	BEGIN
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check])
		values(@Menu_id1, N'Task Type Master', @Temp_Form_ID1, 252, 1, N'Master_Task_Type.aspx', @timesheet_img, 1,N'Task Type Master',4)    
    
	END
If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Timesheet Project Master' AND  Form_ID > 6000 and Form_ID < 6500)
	BEGIN
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check])
		values(@Menu_id1, N'Timesheet Project Master', @Temp_Form_ID1, 253, 1, N'Master_Project_TS.aspx', @timesheet_img, 1,N'Project Master',5)
    
	END
If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Task Master' AND  Form_ID > 6000 and Form_ID < 6500)
	BEGIN
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check])
		values(@Menu_id1, N'Task Master', @Temp_Form_ID1, 254, 1, N'Master_Task.aspx', @timesheet_img, 1,N'Task Master',6)    
	END
If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TimeSheet Entry' AND  Form_ID > 6000 and Form_ID < 6500)
	BEGIN
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check])
		values(@Menu_id1, N'TimeSheet Entry', @Temp_Form_ID1, 255, 1, N'TimeSheet.aspx', @timesheet_img, 1,N'TimeSheet',7)    
	END    
    
If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Collection' AND  Form_ID > 6000 and Form_ID < 6500)     
	BEGIN
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check])
		values(@Menu_id1, N'Collection', @Temp_Form_ID1, 256, 1, N'Master_Collection.aspx', @timesheet_img, 1,N'Collection',8)  
	END
If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Collection Detail' AND  Form_ID > 6000 and Form_ID < 6500)     
	BEGIN
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check])
		values(@Menu_id1, N'Collection Detail', @Temp_Form_ID1, 257, 1, N'Collection_Details.aspx', @timesheet_img, 1,N'Collection Detail',8)  
	END
If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'OverHead' AND  Form_ID > 6000 and Form_ID < 6500)     
	BEGIN
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check])
		values(@Menu_id1, N'OverHead', @Temp_Form_ID1, 257, 1, N'OverHead.aspx', @timesheet_img, 1,N'OverHead',9)  
	END
	
	
------------------------------Prakash Patel 28012015 -------------------------------------
If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Timesheet Approval' AND  Form_ID > 6000 and Form_ID < 6500)     
	BEGIN
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check])
		values(@Menu_id1, N'Timesheet Approval', @Temp_Form_ID1, 257, 1, N'Timesheet_Approval.aspx', @timesheet_img, 1,N'Timesheet Approval',10)  
	END 	
------------------------------------------------------------------------------------------ 	
If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'ESS TimeSheet Entry' AND  Form_ID > 7000 and Form_ID < 7500)      
	BEGIN
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check])
		values(@Menu_id1, N'ESS TimeSheet Entry', 7001, 306, 1, N'TimeSheet.aspx', @Employee_Img, 1,N'TimeSheet',0)    
	END  
------------------------------Prakash Patel 29012015 -------------------------------------
If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'ESS TimeSheet Detail' AND  Form_ID > 7000 and Form_ID < 7500)      
	BEGIN
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check])
		values(@Menu_id1, N'ESS TimeSheet Detail', 7001, 306, 1, N'Timesheet_Detail_ESS.aspx', @Employee_Img, 1,N'TimeSheet Detail',0)    
	END 
------------------------------------------------------------------------------------------ 	  
      
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------      
----Nilay 30/09/2013 
----Optional holiday approval form of superior. 	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Optional HO Approval Manager')
	begin
	
		--select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID > 7000 and Form_ID < 7500
		--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		--values (@Menu_id1,'Optional HO Approval Manager',7023,348,1,'Optional_HO_Approval_Manager.aspx','menu/info.gif',1,'Optional HO Approval')
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Optional HO Approval Manager',7023,348,1,'Optional_HO_Approval_Manager.aspx',@Employee_Img,1,'Optional HO Approval')
	end
Else
	BEGIN
		select @Menu_id1 = (select Form_ID from T0000_DEFAULT_FORM WITH (NOLOCK) where [Form_Name] = 'Optional HO Approval Manager')
		UPDATE T0000_DEFAULT_FORM SET [Sort_ID] = 348 Where [Form_ID] = @Menu_id1
	END
	
----Optional holiday approval form of superior. 	
	
----Nilay 30/09/2013 
----Employee Hisotry form of superior. 		
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee History Manager')
	begin
	
		--select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID > 7000 and Form_ID < 7500
		--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		--values (@Menu_id1,'Employee History Manager',7023,349,1,'Employee_History_Manager.aspx','menu/info.gif',1,'Employee History')
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Employee History Manager',7023,349,1,'Employee_History_Manager.aspx',@Employee_Img,1,'Employee History')
	end	
Else
	Begin
		select @Menu_id1 = (select Form_ID from T0000_DEFAULT_FORM WITH (NOLOCK) where [Form_Name] = 'Employee History Manager')
		UPDATE T0000_DEFAULT_FORM SET [Sort_ID] = 349 Where [Form_ID] = @Menu_id1
	End
	
----Employee Hisotry form of superior.

------Performance Appraisal Menu   Ripal 01-Oct-2013

	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Performance Appraisal' And Form_ID > 7000 and Form_ID < 7500)
	begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	values (@Menu_id1,'Performance Appraisal', 7029,372,1,'Home.aspx',@HR_Img,1,'Performance Appraisal')
	end
	
	Declare @Temp_Form_ID as Numeric(18,0)
	select @Temp_Form_ID = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Performance Appraisal' And Form_ID > 7000 and Form_ID < 7500
	
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Define Goal' And Form_ID > 7000 and Form_ID < 7500)
	begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	values (@Menu_id1,'Define Goal', @Temp_Form_ID,372,1,'NewAppraisal_EmployeeGoal.aspx',@HR_Img,1,'Define Goal')
	end
	
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Goal' And Form_ID > 7000 and Form_ID < 7500)
	begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	values (@Menu_id1,'Employee Goal', @Temp_Form_ID,372,1,'NewAppraisal_ReviewEmployeeGoal_Manager.aspx',@HR_Img,1,'Employee Goal')
	end
	
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Review Goal' And Form_ID > 7000 and Form_ID < 7500)
	begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	values (@Menu_id1,'Review Goal', @Temp_Form_ID,372,1,'NewAppraisal_ReviewGoal_Employee.aspx',@HR_Img,1,'Review Goal')
	end
	
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Review Employee Goal' And Form_ID > 7000 and Form_ID < 7500)
	begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	values (@Menu_id1,'Review Employee Goal', @Temp_Form_ID,372,1,'NewAppraisal_ReviewGoal_Manager.aspx',@HR_Img,1,'Review Employee Goal')
	end
	
	if not exists (select Form_id from T0000_DEFAULT_FORM  WITH (NOLOCK) where  Form_name = 'Review Performance Summary' And Form_ID > 7000 and Form_ID < 7500)
	begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	values (@Menu_id1,'Review Performance Summary', @Temp_Form_ID,372,1,'NewAppraisal_PerformanceSummary_Employee.aspx',@HR_Img,1,'Review Performance Summary')
	end
	
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Review Employee PerformanceSummary' And Form_ID > 7000 and Form_ID < 7500)
	begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	values (@Menu_id1,'Review Employee PerformanceSummary', @Temp_Form_ID,372,1,'NewAppraisal_PerformanceSummary_Manager.aspx',@HR_Img,1,'Review Employee PerformanceSummary')
	end
	
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Review Competency' And Form_ID > 7000 and Form_ID < 7500)
	begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	values (@Menu_id1,'Review Competency', @Temp_Form_ID,372,1,'NewAppraisal_SOLAssessment_Employee.aspx',@HR_Img,1,'Review Competency')
	end
	
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Review Employee Competency' And Form_ID > 7000 and Form_ID < 7500)
	begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	values (@Menu_id1,'Review Employee Competency', @Temp_Form_ID,372,1,'NewAppraisal_SOLAssessment_Manager.aspx',@HR_Img,1,'Review Employee Competency')
	end
	
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Reim/Claim' And Form_ID > 6000 and Form_ID < 6499)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Reim/Claim',6070 ,124,1,'Home.aspx',@Loan_Claim_Img,1,'Reim-Claim')
	end
	
	select @Temp_Form_ID1 = isnull(Form_id,0) from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6499 and Form_Name='Reim/Claim'
	
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Reim/Claim Approval' And Form_ID > 6000 and Form_ID < 6499)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Reim/Claim Approval',@Temp_Form_ID1 ,124,1,'Employee_ReimClaim_Approval.aspx',@Loan_Claim_Img,1,'Reim-Claim Approval')
	end
	
	
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Reim/Claim Opening' And Form_ID > 6000 and Form_ID < 6499)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Reim/Claim Opening',@Temp_Form_ID1 ,124,1,'Reim-Claim Opening.aspx',@Loan_Claim_Img,1,'Reim-Claim Opening')
	end
	
	---Ripal 02 Jan 2014---(start)-----
	--if not exists (select Form_id from T0000_DEFAULT_FORM where  Form_name = 'Reim/Claim Opening Import' And Form_ID > 6000 and Form_ID < 6499)
	--begin    
	--	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID > 6000 and Form_ID < 6499
	--	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	--	values (@Menu_id1,'Reim/Claim Opening Import',@Temp_Form_ID1 ,124,1,'ReimClaim_Opening_Import.aspx',@Loan_Claim_Img,1,'Reim-Claim Opening Import')
	--end
	---Ripal 02 Jan 2014---(end)-------
	
	
	declare @Temp_Form_ID2 as numeric
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Reim/Claim' And Form_ID > 7000 and Form_ID < 7499)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Reim/Claim',7013 ,320,1,'Home.aspx',@Loan_Claim_Img,1,'Reim-Claim')
	end
	
	select @Temp_Form_ID2 = isnull(Form_id,0)  from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7499 and Form_name = 'Reim/Claim' 
	
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Reim/Claim Application' And Form_ID > 7000 and Form_ID < 7499)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Reim/Claim Application',@Temp_Form_ID2 ,320,1,'Reimbursemnt_Application_ESS.aspx',@Loan_Claim_Img,1,'Reim-Claim Application')
	end
	
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Reim/Claim Approval' And Form_ID > 7000 and Form_ID < 7499)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Reim/Claim Approval',@Temp_Form_ID2 ,320,1,'Employee_ReimClaim_Approval.aspx',@Loan_Claim_Img,1,'Reim-Claim Approval')
	end
	
------Performance Appraisal Menu  Ripal 01-Oct-2013  (end)

	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Responsibility & Escalation') --- added by mitesh on 19112013
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Responsibility & Escalation',6001,14,1,'Auto_Escalation_Settings.aspx',@Control_Pnl_Img,1,'Responsibility & Escalation')
	end

---------------------------------------------------------------------------------------------------------
--if not exists (select Form_id from T0000_DEFAULT_FORM where  Form_name = 'Reimbursement Approval Report') --- added by mitesh on 19112013
--	begin
	
--		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID > 7500  and Form_ID < 7544  
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
--		values (@Menu_id1,'Reimbursement Approval Report',7511,407,1,'Reimbursement Approval Report',@Control_Pnl_Img,1,'Reimbursement Approval Report')
--	end
----------Above Commented by Sumit for Wrong under form id and not use in any where in payroll--18082015---------------------------------------------------------------------------------------------	


if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'AX Mapping') --- added by Rohit on 09122013
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000  and Form_ID < 6499  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'AX Mapping',6001,14,1,'AX_Mapping.aspx', @Control_Pnl_Img, 1, N'AX Mapping')
	end

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'AX Mapping Slab Master') --- added by Mr.Mehul on 24082022
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000  and Form_ID < 6499  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'AX Mapping Slab Master',6001,16,1,'Master_Cost_Center_Slab.aspx', @Control_Pnl_Img, 1, N'AX Mapping Slab Master')
	end
	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Income Tax Declaration My#') 
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7500     and Form_ID < 7999  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Income Tax Declaration My#',7532,401,1,NULL, NULL, 1, N'Income Tax Declaration My#')
	end
--------------------------------------------added jimit 12072016-------------------------------------------
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Income Tax Declaration Member#') 
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7500     and Form_ID < 7999  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Income Tax Declaration Member#',7514,401,1,NULL, NULL, 1, N'Income Tax Declaration Member#')
	end

-----------------------------------------------------------------------------------------------------------	
---Added By Jimit 11122019---
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee OverTime Reports Member#') 
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7500     and Form_ID < 7999  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[page_Flag])
		values (@Menu_id1,'Employee OverTime Reports Member#',7503,347,1,NULL, NULL, 1, N'Employee OverTime Reports Member#','ER')
	end

--Ended--
--------------------------------------------added jimit 29032016-------------------------------------------
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Tax Consolidate Report My#') 
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7500     and Form_ID < 7999  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Tax Consolidate Report My#',7532,401,1,NULL, NULL, 1, N'Tax Consolidate Report My#')
	end
--------------------------------------------ended----------------------------------------------------------	
--if not exists (select Form_id from T0000_DEFAULT_FORM where  Form_name = 'Cross Company Privilege') 
--	begin
	
--		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID > 6000  and Form_ID < 6499  
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
--		values (@Menu_id1,'Cross Company Privilege',6001,14,1,'Privilege_Employee_Other_Company.aspx', N'menu/company_updates.gif', 0, N'Cross Company Privilege')
		
--	end
	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Cross Company Privilege') 
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000  and Form_ID < 6499  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Cross Company Privilege',6001,14,1,'Privilege_Employee_Other_Company.aspx', @Control_Pnl_Img, 1, N'Cross Company Privilege')
		
	end --Changed by Gadriwala Muslim 26052015
	else
			begin
				select @Menu_id1 = Form_id from T0000_DEFAULT_FORM  WITH (NOLOCK) where  Form_name = 'Cross Company Privilege'
				update [dbo].[T0000_DEFAULT_FORM] set [Form_Image_url] = @Control_Pnl_Img, Is_Active_For_menu = 1 where  Form_ID = @Menu_id1
			end
		
	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Leave Application Tracking') 
	begin
		
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700  and Form_ID < 6999	  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Leave Application Tracking',6703, 176,1,NULL, NULL, 1, N'Leave Application Tracking')
		
	end
	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'FORM 11 (PF) My#')  -- Added By Ali 07012014
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7500     and Form_ID < 7999  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'FORM 11 (PF) My#',7532,401,1,NULL, NULL, 1, N'FORM 11 (PF) My#')
	end
	
	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Warning My#')  -- Added Muslim 14022014
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7500     and Form_ID < 7999 
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'Employee Warning My#', 7532, 402, 1, NULL, NULL, 1, N'Employee Warning My#')	
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Warning Member#')  -- Added Muslim 14022014
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7500     and Form_ID < 7999 
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'Employee Warning Member#', 7514, 347, 1, NULL, NULL, 1, N'Employee Warning Member#')		
	end
		
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Warning Card')  -- Added Muslim 14022014
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'Warning Card', 7023, 350, 1, N'Employee_Warning.aspx', @Employee_Img, 1, N'Warning Card Details')			
	end
	------Added on 28 Feb 2014 sneha---------------------------------------------
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Range Master & General Settings') 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 6700
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'Range Master & General Settings', 6518, 228, 1, N'HRMS/HRMS_Range_Master.aspx', N'menu/company_structure.gif', 1, N'Range Master & General Settings')			
	end	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Criteria Master') 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 6700
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'Criteria Master', 6518, 228, 1, N'HRMS/HRMS_SelfAppraisal_Master.aspx', N'menu/company_structure.gif', 1, N'Criteria Master')			
	end	
	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Performance Feedback Master') 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 6700
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'Performance Feedback Master', 6518, 228, 1, N'HRMS/PerformaceFeedback_Master.aspx', N'menu/company_structure.gif', 1, N'Performance Feedback Master')			
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Performance Attributes') 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 6700
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'Performance Attributes', 6518, 228, 1, N'HRMS/Performance_Attribute.aspx', N'menu/company_structure.gif', 1, N'Performance Attributes')			
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Appraisal Initiation') 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 6700
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'Appraisal Initiation', 6518, 228, 1, N'HRMS/HRMS_AppraisalSetting.aspx', N'menu/company_structure.gif', 1, N'Appraisal Initiation')			
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Self Assessment') 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 6700
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'Employee Self Assessment', 6518, 228, 1, N'HRMS/HRMS_EmpSelfAssessment.aspx', N'menu/company_structure.gif', 1, N'Employee Self Assessment')			
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Performance Assessment') 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 6700
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'Performance Assessment', 6518, 228, 1, N'HRMS/PerformanceAssessment.aspx', N'menu/company_structure.gif', 1, N'Performance Assessment')			
	end
------Added on 28 Feb 2014 sneha---------------------------------------------
------Added on 3 Mar 2014 sneha---------------------------------------------
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Assessment' And Form_ID > 7000 and Form_ID < 7500)
	begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	values (@Menu_id1,'Employee Assessment',7029,382,1,'ess_empassessment.aspx',@HR_Img,1,'Employee Assessment')
	end
	
IF EXISTS (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Performance Assessment'	and Page_Flag='EP')
	BEGIN    
		UPDATE T0000_DEFAULT_FORM SET Form_Name='Appraisal Reporting Manager Approval',Alias='Appraisal Reporting Manager Approval',Sort_Id_Check=6 WHERE Form_name = 'Employee Performance Assessment'	and Page_Flag='EP'
	END
		
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Appraisal Reporting Manager Approval' And Form_ID > 7000 and Form_ID < 7500)
	begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],Sort_Id_Check)
	values (@Menu_id1,'Appraisal Reporting Manager Approval',7029,383,1,'Ess_PerformanceAssessment.aspx',@HR_Img,1,'Appraisal Reporting Manager Approval',6)
	end
	
IF EXISTS (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'My Performance' and Page_Flag='EP')
	BEGIN    
		UPDATE T0000_DEFAULT_FORM SET Form_Name='My Performance/Closing Loop',Alias='My Performance/Closing Loop',Sort_Id_Check=9 WHERE Form_name = 'My Performance' and Page_Flag='EP'
	END	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'My Performance/Closing Loop' And Form_ID > 7000 and Form_ID < 7500)
	begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],Sort_Id_Check)
	values (@Menu_id1,'My Performance/Closing Loop', 7029,384,1,'Self_PerformanceAssessment.aspx',@HR_Img,1,'My Performance/Closing Loop',9)
	end		
------Added on 3 mar 2014 sneha---------------------------------------------	
-- exec P0000_Default_Form_New_test 1
----Ankit 06032014	 
If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Company Transfer')
	begin

		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Employee Company Transfer',6042, 69, 1,'Company_Transfer.aspx',@Employee_Img,1,'Employee Company Transfer')
	end

If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Company Transfer Multi')
	begin

		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Employee Company Transfer Multi',6042, 69, 1,'Company_Transfer_Multi.aspx',@Employee_Img,1,'Employee Company Transfer Multi')
	end
	
----Ankit 06032014

------Added on 19 mar 2014 sneha---------------------------------------------
IF EXISTS (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Appraisal Finalization'	and Page_Flag='EP')
	BEGIN    
		UPDATE T0000_DEFAULT_FORM SET Form_Name='Appraisal Group Head/GH Approval',Alias='Appraisal Group Head/GH Approval',Sort_Id_Check=8 WHERE Form_name = 'Appraisal Finalization'	and Page_Flag='EP'
	END	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Appraisal Group Head/GH Approval' And Form_ID > 7000 and Form_ID < 7500)
	begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],Sort_Id_Check)
	values (@Menu_id1,'Appraisal Group Head/GH Approval', 7029,384,1,'Ess_AppraisalFinalization.aspx',@HR_Img,1,'Appraisal Group Head/GH Approval',8)
	end	
	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Appraisal Finalization' And Form_ID > 6500 and Form_ID < 6700) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 6700
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'Appraisal Finalization', 6518, 228, 1, N'HRMS/Hrms_ApprisalFinalization.aspx', N'menu/company_structure.gif', 1, N'Appraisal Finalization')			
	end
------Added on 19 mar 2014 sneha---------------------------------------------
------Added on 24 mar 2014 sneha---------------------------------------------
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Final Approval Stage' And Form_ID > 6500 and Form_ID < 6700) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 6700
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'Final Approval Stage', 6518, 229, 1, N'HRMS/Final_AppraisalApproval.aspx', N'menu/company_structure.gif', 1, N'Final Approval Stage')			
	end
------Added on 24 mar 2014 sneha---------------------------------------------
-- Added by rohit on 19032014
If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Source Master')
	begin

		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Source Master',6013, 35, 1,'Master_Source.aspx',@Masters_Img,1,'Source Master')
	end
	-- Ended by rohit on 19032014
	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Register With Settlement My#')  -- Added By Ali 20032014
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7500 and Form_ID < 7999  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Register With Settlement My#',7532,398,1,NULL, NULL, 1, N'Register With Settlement My#')
	end



if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Timesheet Summary My#')  -- Added By MR.MEHUL 19122022
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7500 and Form_ID < 7999  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Timesheet Summary My#',7532,410,1,NULL, NULL, 1, N'Timesheet Summary My#')
	end

------Added on 1 Apr 2014 sneha---------------------------------------------
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Other Assessment Master' And Form_ID > 6500 and Form_ID < 6700) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 6700
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'Other Assessment Master', 6518, 230, 1, N'HRMS/HRMS_OtherAssessment_Master.aspx', N'menu/company_structure.gif', 1, N'Other Assessment Master')			
	end
------Added on 1 Apr mar 2014 sneha---------------------------------------------	
--Added by Gadriwala 01042014-Start
--Delete from T0000_DEFAULT_FORM where  Form_name = 'Email News Letter'
If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Email News Letter')
	begin

		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Email News Letter',6012, 61, 1,'Email_News_Letter.aspx',@Masters_Img,1,'Email News Letter')
	end
--Delete from T0000_DEFAULT_FORM where  Form_name = 'Email Logs'
If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Email Logs')
	begin

		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Email Logs',6012, 62, 1,'Email_Logs.aspx',@Masters_Img,1,'Email Logs')
	end

--Added by Gadriwala 01042014 -End

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Gate Pass')  -- Added By Rohit on 22022014
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000     and Form_ID < 6500  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Gate Pass',6057,100,1,'Home.aspx',@Leave_Img, 1, N'Gate Pass')
	end
--Added by Sumit 19022015

Declare @Menu_id_Gatepass Numeric(18,0)

select @Menu_id_Gatepass = form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Gate Pass' and Form_id > 6000 and Form_ID < 6500

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Gate Pass Entry')  -- Added By Rohit on 22022014
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000     and Form_ID < 6500  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Gate Pass Entry',@Menu_id_Gatepass,100,1,'get_pass_entry.aspx',@Leave_Img, 1, N'Gate Pass Entry')
	end

--Added By Gadriwala Muslim 08012014 - Start
If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Gate Pass with device' and Form_ID>6000 and Form_ID<6500)
	begin
		--Set @temp_menu_id_Increment  = 0
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		--set @temp_menu_id_Increment = @Menu_id1

		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Gate Pass with device',@Menu_id_Gatepass, 101, 1,'Employee_Gate_Pass_Regularization.aspx',@Leave_Img,1,'Gate Pass with device')
		
	end	


-- Added by Ali 21042014 -- State
IF NOT EXISTS (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Strength Master')
	BEGIN	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000     and Form_ID < 6500  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Employee Strength Master',6012,60,1,'Employee_Strength_Master.aspx',@Masters_Img, 1, N'Employee Strength Master')
	END 		
else
	begin
		update T0000_DEFAULT_FORM set [Form_url] = 'Employee_Strength_Master.aspx' where Form_name = 'Employee Strength Master'  -- added by Gadriwala Muslim 09022015 - Start
	end
	
-- Added by Ali 21042014 -- End
--Added by Gadriwala 24042014-Start
If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Skill Type Master')
	begin

		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Skill Type Master',6013, 63, 1,'Master_Skill_type.aspx',@Masters_Img,1,'Skill Type Master')
	end
	
	
If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Minimum Wages Master')
	begin

		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Minimum Wages Master',6013, 64, 1,'Master_Minimum_Wages.aspx',@Masters_Img,1,'Minimum Wages Master')
	end
--Added by Gadriwala 24042014-end

--Added by nilesh patel on 08082015 --Start
If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Pay Scale Master')
	begin

		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Pay Scale Master',6013, 64, 1,'Master_Pay_Scale.aspx',@Masters_Img,1,'Pay Scale Master')
	end
--Added by nilesh patel on 08082015 --End

If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Abstract Report Master')
	begin

		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Abstract Report Master',6013, 64, 1,'Abstract_Report_Format.aspx',@Masters_Img,1,'Abstract Report Master')
	end

If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Loan Approval' And Form_ID > 7000 and Form_ID < 7500)	--Ankit 05052014
	Begin
		Select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Loan Approval',7010, 316, 1,'Loan_Approve_Ess.aspx',@Loan_Claim_Img,1,'Loan Approval')
	End
	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Company Transfer' And Form_ID > 6700 and Form_ID < 6999) --Ankit 07052014
	begin
		
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700  and Form_ID < 6999	  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Employee Company Transfer',6701, 172,1,NULL, NULL, 1, N'Employee Company Transfer')
		
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Optional Holiday' And Form_ID > 6700 and Form_ID < 6999) --Ankit 07052014
	begin
		
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700  and Form_ID < 6999	  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Optional Holiday',6701, 172,1,NULL, NULL, 1, N'Optional Holiday')
		
	end	
If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Shift Rotation Superior' And Form_ID > 7000 and Form_ID < 7500)	--Ankit 20062014
	Begin
		Select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Employee Shift Rotation Superior',7023, 344, 1,'Employee_Shift_Rotation_Superior.aspx',@Employee_Img,1,'Employee Shift Rotation')		
	End
--------------------------------------------- Prakash Patel 24012015 -----------------------------------------------
If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'ESS Timesheet Details' And Form_ID > 7000 and Form_ID < 7500)	
	Begin
		Select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'ESS Timesheet Details',7023, 344, 1,'Timesheet_Details.aspx',@Employee_Img,1,'Timesheet Details')
	End
--------------------------------------------------------------------------------------------------------------------

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Information' And Form_ID > 6700 and Form_ID < 6999) 
	begin
		
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700  and Form_ID < 6999	  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Employee Information',6701, 172,1,NULL, NULL, 1, N'Employee Information')
		
end	

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Reim/Claim Approval' And Form_ID > 6700 and Form_ID < 6999) 
	begin
		
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700  and Form_ID < 6999	  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Reim/Claim Approval',6704, 178,1,NULL, NULL, 1, N'Reim/Claim Approval')
		
end	


if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Reim/Claim Statement' And Form_ID > 6700 and Form_ID < 6999) 
	begin
		
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700  and Form_ID < 6999	  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Reim/Claim Statement',6704, 178,1,NULL, NULL, 1, N'Reim/Claim Statement')
		
end	


if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Reim/Claim Balance' And Form_ID > 6700 and Form_ID < 6999) 
	begin
		
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700  and Form_ID < 6999	  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Reim/Claim Balance',6704, 178,1,NULL, NULL, 1, N'Reim/Claim Balance')
		
end	

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Salary Slip' And Form_ID > 6700 and Form_ID < 6999) 
	begin
		
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700  and Form_ID < 6999	  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Salary Slip',6705, 180,1,NULL, NULL, 1, N'Salary Slip')
		
end	

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Reimbursement Slip' And Form_ID > 6700 and Form_ID < 6999) 
	begin
		
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700  and Form_ID < 6999	  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Reimbursement Slip',6705, 180,1,NULL, NULL, 1, N'Reimbursement Slip')
		
end	
--added jimit 10/11/2015--start
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Loan Application Report Member#' And Form_ID > 7500 and Form_ID < 8000) 
	begin
		
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7500 and Form_ID < 8000	  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Loan Application Report Member#',7511, 347,1,NULL, NULL, 1, N'Loan Application Report Member#')
		
end	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Loan Application Report My#' And Form_ID > 7500 and Form_ID < 8000) 
	begin
		
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7500 and Form_ID < 8000	  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Loan Application Report My#',7529, 396,1,NULL, NULL, 1, N'Loan Application Report My#')
		
end	
--------------ended-----
	------Added on 12 may 2014 Sneha-------------------------------------
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'HRMS Reports' And Form_ID > 6700 and Form_ID < 6999) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700 and Form_ID < 6999
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'HRMS Reports', 6163, 196, 1, null,null, 1, N'HRMS Reports')			
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Hrms Customize Report' And Form_ID > 6700 and Form_ID < 6999) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700 and Form_ID < 6999
		declare @hrreport_id as numeric(18,0)
		select @hrreport_id = form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'HRMS Reports' And Form_ID > 6700 and Form_ID < 6999 
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'Hrms Customize Report', @hrreport_id, 197, 1, null, null, 1, N'Hrms Customize Report')			
	end
else
	begin 
		select @hrreport_id = form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'HRMS Reports' And Form_ID > 6700 and Form_ID < 6999 
		update [T0000_DEFAULT_FORM] set under_form_Id = @hrreport_id where Form_name = 'Hrms Customize Report' And Form_ID > 6700 and Form_ID < 6999
	End

------Added on 12 may 2014 Sneha-------------------------------------	


--------------Added By Mukti on 13 May 2014 (Start)----------------------------------
	--if not exists (select Form_id from T0000_DEFAULT_FORM where  Form_name = 'Brand Master') 
	--begin
	
	--	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID > 6000  and Form_ID < 6499  
	--	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	--	values(@Menu_id1, N'Brand Master', 6013, 34, 1, N'Master_Brand.aspx', @Masters_Img, 1, N'Brand Master')
	--end
	--added By Mukti(start)23032015
--if not exists (select Form_id from T0000_DEFAULT_FORM where  Form_name = 'Asset Installation Master' And Form_ID > 6000 and Form_ID < 6499) 
--		begin    
--			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID > 6000 and Form_ID < 6499
--			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
--			values(@Menu_id1, N'Asset Installation Master', 6013, 34, 1, N'Asset_Installation_Master.aspx', @Masters_Img, 1, N'Asset Installation Master')
--	end
		
--added By Mukti(end)23032015
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Asset' And Form_ID > 6000 and Form_ID < 6499)
	begin    
		select @Temp_Form_ID1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Temp_Form_ID1,'Asset',6070 ,124,1,'Home.aspx',@Loan_Claim_Img,1,'Asset')
	end
	else
	begin
		update T0000_DEFAULT_FORM set under_form_id=6070,[Sort_ID]=124,[Sort_ID_Check]=1,[Form_Image_url]=@Loan_Claim_Img where  Form_name = 'Asset' and  Form_ID > 6000 and Form_ID < 6499
	end

	
	
	Declare @Form_Id_Asset as numeric
	select @Form_Id_Asset = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Asset' And Form_ID > 6000 and Form_ID < 6499
	
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Asset Master')
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000  and Form_ID < 6499  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
		values(@Menu_id1, N'Asset Master', @Form_Id_Asset, 124, 1, N'Master_Asset.aspx', @Loan_Claim_Img, 1, N'Asset Master',2)
	end
	else
	begin
		update T0000_DEFAULT_FORM set under_form_id=@Form_Id_Asset,form_type=1,[Sort_ID]=124,[Sort_ID_Check]=2,[Form_Image_url]=@Loan_Claim_Img where  Form_name = 'Asset Master'
	end	

	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Brand Master') 
		begin
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000  and Form_ID < 6499  
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
			values(@Menu_id1, N'Brand Master', @Form_Id_Asset, 124,1, N'Master_Brand.aspx', @Loan_Claim_Img, 1, N'Brand Master',3)
		end
	else
		begin
			update T0000_DEFAULT_FORM set under_form_id=@Form_Id_Asset,form_type=1,[Sort_ID]=124,[Sort_ID_Check]=3,[Form_Image_url]=@Loan_Claim_Img where Form_name = 'Brand Master'
		end	
		
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Asset Installation Master' And Form_ID > 6000 and Form_ID < 6499) 
		begin    
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6499
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_check])
			values(@Menu_id1, N'Asset Installation Master', @Form_Id_Asset, 124, 1, N'Asset_Installation_Master.aspx', @Loan_Claim_Img, 1, N'Asset Installation Master',4)
		end
	else
		begin
			update T0000_DEFAULT_FORM set under_form_id=@Form_Id_Asset,form_type=1,[Sort_ID]=124,[Form_Image_url]=@Loan_Claim_Img,[Sort_Id_Check]=4 where Form_name = 'Asset Installation Master'
		end	
		
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Vendor Master' And Form_ID > 6000 and Form_ID < 6499) 
		begin    
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6499
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_check])
			values(@Menu_id1, N'Vendor Master', @Form_Id_Asset, 124, 1, N'Vendor_Master.aspx', @Loan_Claim_Img, 1, N'Vendor Master',5)
		end
	else
		begin
			update T0000_DEFAULT_FORM set under_form_id=@Form_Id_Asset,form_type=1,[Sort_ID]=124,[Form_Image_url]=@Loan_Claim_Img,[Sort_Id_Check]=5 where Form_name = 'Vendor Master'
		end	
	
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Asset Details') 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000  and Form_ID < 6499  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
		values(@Menu_id1, N'Asset Details', @Form_Id_Asset, 124, 1, N'Asset_Details.aspx',@Loan_Claim_Img, 1, N'Asset Details',6)
	end
	else
		begin
			update T0000_DEFAULT_FORM set [Sort_ID]=124,[Sort_Id_check]=6 where Form_name = 'Asset Details'
		end	
	
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Asset Approval') 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000  and Form_ID < 6499  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_check])
		values(@Menu_id1, N'Asset Approval', @Form_Id_Asset, 124, 1, N'Asset_Approval.aspx', @Loan_Claim_Img, 1, N'Asset Approval',7)
	end
	else
		begin
			update T0000_DEFAULT_FORM set [Sort_ID]=124,[Sort_id_check]=7 where Form_name = 'Asset Approval'
		end	
	
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Admin Asset Approval') 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000  and Form_ID < 6499  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_check])
		values(@Menu_id1, N'Admin Asset Approval', @Form_Id_Asset, 124, 1, N'Admin_Asset_Approval.aspx', @Loan_Claim_Img, 1, N'Admin Asset Approval',8)
	end
	else
		begin
			update T0000_DEFAULT_FORM set [Sort_ID]=124,[Sort_id_check]=8 where Form_name = 'Admin Asset Approval'
		end	
		
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Meter Reading') -- Added by Rajput on 29032019
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000  and Form_ID < 6499  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_check])
		values(@Menu_id1, N'Meter Reading', @Form_Id_Asset, 124, 1, N'Meter_Reading.aspx', @Loan_Claim_Img, 1, N'Meter Reading',9)
	end
	
	--Added By Jimit 01052019
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Directory Setting') 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM  WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Page_Flag])
		values(@Menu_id1, N'Employee Directory Setting', 6001,14, 1, N'Employee_Directory_Setting.aspx', @Control_Pnl_Img, 1, N'Employee Directory Setting','AP')
	end
	--Ended
	
	--Added By Nilesh Patel on 17072019
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Directory - Admin') 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Page_Flag])
		values(@Menu_id1, N'Employee Directory - Admin', 6001,15, 1, N'Employee_Directory.aspx', N'menu/Control_Panel.gif', 1, N'Employee Directory','AP')
	end
	-- Added By Nilesh patel on 17072019

	--ess side asset
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Asset' And Form_ID > 7000 and Form_ID < 7499)
	begin    
		select @Temp_Form_ID1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Temp_Form_ID1,'Asset',7013 ,322,1,'Home.aspx',@Loan_Claim_Img,1,'Asset')
	end
	
	Declare @Form_Id_Asset_Ess as numeric
	select @Form_Id_Asset_Ess = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Asset' And Form_ID > 7000 and Form_ID < 7499
	
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Asset Application' And Form_ID > 7000 and Form_ID < 7499) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000  and Form_ID < 7499  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'Asset Application', @Form_Id_Asset_Ess, 322, 1, N'Asset_Application.aspx', @Loan_Claim_Img, 1, N'Asset Application')
	end
	
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Asset Status' And Form_ID > 7000 and Form_ID < 7499) 
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000  and Form_ID < 7499  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'Asset Status', @Form_Id_Asset_Ess, 322, 1, N'Asset_Status.aspx', @Loan_Claim_Img, 1, N'Asset Status')
	end
--------------Added By Mukti on 13 May 2014 (End)----------------------------------

------Added on 19 may 2014 Sneha (start)-------------------------------------
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Self Assessment' And Form_ID > 6700 and Form_ID < 6999) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700 and Form_ID < 6999
		select @hrreport_id = form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'HRMS Reports' And Form_ID > 6700 and Form_ID < 6999 
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'Employee Self Assessment', @hrreport_id, 198, 1, null, null, 1, N'Employee Self Assessment')			
	end
else
	begin 
		--declare @hrreport_id as numeric(18,0)
		select @hrreport_id = form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'HRMS Reports' And Form_ID > 6700 and Form_ID < 6999 
		update [T0000_DEFAULT_FORM] set under_form_Id = @hrreport_id where Form_name = 'Employee Self Assessment' And Form_ID > 6700 and Form_ID < 6999
	End
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'HRMS Reports Member#')  
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7500     and Form_ID < 7999  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'HRMS Reports Member#',7061,348,1,NULL, NULL, 1, N'HRMS Reports Member#')
	end
	
declare @id_hrmsreport  numeric(18,0)
select @id_hrmsreport =  Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'HRMS Reports Member#'
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Hrms Customize Report Member#')  
	begin
		
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7500     and Form_ID < 7999  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Hrms Customize Report Member#',@id_hrmsreport,348,1,'~/Report_Customized_HRMS_Ess.aspx', NULL, 1, N'Hrms Customize Report Member#')
	end
Else
	begin --added on 17082015 sneha
		update [T0000_DEFAULT_FORM]
		set  [Under_Form_ID] =@id_hrmsreport,
		form_url ='~/Report_Customized_HRMS_Ess.aspx'
		where form_name = 'Hrms Customize Report Member#' and Form_ID > 7500  and Form_ID < 7999 
	End
	
select @id_hrmsreport =  Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'HRMS Reports Member#'
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Self Assessment Member#')  
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7500     and Form_ID < 7999  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Employee Self Assessment Member#',@id_hrmsreport,348,1,'~/Report_Payroll.aspx?Id=9007', NULL, 1, N'Employee Self Assessment Member#')
	end
Else
	begin --added on 17082015 sneha
		update [T0000_DEFAULT_FORM]
		set  [Under_Form_ID] =@id_hrmsreport,
		form_url='~/Report_Payroll.aspx?Id=9007'
		where form_name = 'Employee Self Assessment Member#' and Form_ID > 7500  and Form_ID < 7999 
	End
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'HRMS Report My#')  
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7500     and Form_ID < 7999  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'HRMS Report My#',7062,407,1,NULL, NULL, 1, N'HRMS Report My#')
	end	

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Self Assessment Form My#')  
	begin
	declare @mineid_hrmsreport  numeric(18,0)
	select @mineid_hrmsreport =  Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'HRMS Report My#'
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7500     and Form_ID < 7999  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Self Assessment Form My#',@mineid_hrmsreport,408,1,'~/Report_Payroll_Mine.aspx?Id=9007', NULL, 1, N'Self Assessment Form My#')
	end
Else
	begin 
		declare @esshrreport_id as numeric(18,0)
		select @esshrreport_id = form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'HRMS Report My#' And Form_ID > 7500     and Form_ID < 7999
		update [T0000_DEFAULT_FORM] set under_form_Id = @esshrreport_id,form_url='~/Report_Payroll_Mine.aspx?Id=9007' where Form_name = 'Self Assessment Form My#' And Form_ID > 7500     and Form_ID < 7999
	End
------Added on 19 may 2014 Sneha (End)-------------------------------------
------Added on 22 may 2014 Sneha (start)-------------------------------------
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Performance Assessment Form' And Form_ID > 6700 and Form_ID < 6999) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700 and Form_ID < 6999
		select @hrreport_id = form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'HRMS Reports' And Form_ID > 6700 and Form_ID < 6999 

		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'Performance Assessment Form', @hrreport_id, 199, 1, null, null, 1, N'Performance Assessment Form')			
	end
else
	begin 
		--declare @hrreport_id as numeric(18,0)
		select @hrreport_id = form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'HRMS Reports' And Form_ID > 6700 and Form_ID < 6999 
		update [T0000_DEFAULT_FORM] set under_form_Id = @hrreport_id where Form_name = 'Performance Assessment Form' And Form_ID > 6700 and Form_ID < 6999
	End
------Added on 22 may 2014 Sneha (End)-------------------------------------

--If not exists (select Form_id from T0000_DEFAULT_FORM where  Form_name = 'Employee Bulk Increment')
--	begin
--		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID > 6000 and Form_ID < 6499
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
--		values (@Menu_id1,'Employee Bulk Increment',@temp_menu_id_Increment, 68, 1,'Bulk_Increment.aspx',@Employee_Img,1,'Employee Bulk Increment')
--	--6402
--	end



----------------For Grieavne Module ----------------------------
-- Added By Ronakk 11032022 For ESS
		if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Grievance' And Form_ID > 7000 and Form_ID < 7499)
	begin    
		select @Temp_Form_ID1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Temp_Form_ID1,'Grievance',-1,321,1,'Home.aspx',@Loan_Claim_Img,1,'Grievance')
	end
	else
	begin
		update T0000_DEFAULT_FORM set under_form_id=-1,[Sort_ID]=321,[Sort_ID_Check]=1,[Form_Image_url]=@Loan_Claim_Img where  Form_name = 'Grievance' and  Form_ID > 7000 and Form_ID < 7499
	end

	Declare @Form_Id_Grev_ESS as numeric
	select @Form_Id_Grev_ESS = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Grievance' And Form_ID > 7000 and Form_ID < 7499




	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Grievance Application' And Form_ID > 7000 and Form_ID < 7499)
	begin    
		select @Temp_Form_ID1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Temp_Form_ID1,'Grievance Application',@Form_Id_Grev_ESS,321,1,'ESS_Grievance_Application.aspx',@Loan_Claim_Img,1,'Grievance Application')
	end
	else
	begin
		update T0000_DEFAULT_FORM set under_form_id=@Form_Id_Grev_ESS,[Sort_ID]=321,[Sort_ID_Check]=1,[Form_Image_url]=@Loan_Claim_Img where  Form_name = 'Grievance Application' and  Form_ID > 7000 and Form_ID < 7499
	end

	--Added by ronakk 19042022
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Grievance Application Allocation' And Form_ID > 7000 and Form_ID < 7499)
	begin    
		select @Temp_Form_ID1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Temp_Form_ID1,'Grievance Application Allocation',@Form_Id_Grev_ESS,322,1,'ESS_Griev_Application_Allocation.aspx',@Loan_Claim_Img,1,'Grievance Application Allocation')
	end
	else
	begin
		update T0000_DEFAULT_FORM set under_form_id=@Form_Id_Grev_ESS,[Sort_ID]=322,[Sort_ID_Check]=1,[Form_Image_url]=@Loan_Claim_Img where  Form_name = 'Grievance Application Allocation' and  Form_ID > 7000 and Form_ID < 7499
	end


	--Added by ronakk 25042022
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Grievance Hearing' And Form_ID > 7000 and Form_ID < 7499)
	begin    
		select @Temp_Form_ID1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Temp_Form_ID1,'Grievance Hearing',@Form_Id_Grev_ESS,323,1,'ESS_Griev_Hearing.aspx',@Loan_Claim_Img,1,'Grievance Hearing')
	end
	else
	begin
		update T0000_DEFAULT_FORM set under_form_id=@Form_Id_Grev_ESS,[Sort_ID]=323,[Sort_ID_Check]=1,[Form_Image_url]=@Loan_Claim_Img where  Form_name = 'Grievance Hearing' and  Form_ID > 7000 and Form_ID < 7499
	end


	--Added by ronakk 11052022
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Grievance Application Allocation - Chairperson' And Form_ID > 7000 and Form_ID < 7499)
	begin    
		select @Temp_Form_ID1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Temp_Form_ID1,'Grievance Application Allocation - Chairperson',@Form_Id_Grev_ESS,324,1,'ESS_Griev_Application_Allocation_Chairperson.aspx',@Loan_Claim_Img,1,'Grievance Application Allocation - Chairperson')
	end
	else
	begin
		update T0000_DEFAULT_FORM set under_form_id=@Form_Id_Grev_ESS,[Sort_ID]=324,[Sort_ID_Check]=1,[Form_Image_url]=@Loan_Claim_Img where  Form_name = 'Grievance Application Allocation - Chairperson' and  Form_ID > 7000 and Form_ID < 7499
	end


	--Added by ronakk 11052022
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Grievance Hearing - Chairperson' And Form_ID > 7000 and Form_ID < 7499)
	begin    
		select @Temp_Form_ID1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Temp_Form_ID1,'Grievance Hearing - Chairperson',@Form_Id_Grev_ESS,325,1,'ESS_Griev_Hearing_Chairperson.aspx',@Loan_Claim_Img,1,'Grievance Hearing - Chairperson')
	end
	else
	begin
		update T0000_DEFAULT_FORM set under_form_id=@Form_Id_Grev_ESS,[Sort_ID]=325,[Sort_ID_Check]=1,[Form_Image_url]=@Loan_Claim_Img where  Form_name = 'Grievance Hearing - Chairperson' and  Form_ID > 7000 and Form_ID < 7499
	end

	--Added by ronakk 29102022
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Hearing Calender' And Form_ID > 7000 and Form_ID < 7499)
	begin    
		select @Temp_Form_ID1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Temp_Form_ID1,'Hearing Calender',@Form_Id_Grev_ESS,326,1,'ESS_Griev_Calender.aspx',@Loan_Claim_Img,1,'Hearing Calender')
	end
	else
	begin
		update T0000_DEFAULT_FORM set under_form_id=@Form_Id_Grev_ESS,[Sort_ID]=326,[Sort_ID_Check]=1,[Form_Image_url]=@Loan_Claim_Img where  Form_name = 'Hearing Calender' and  Form_ID > 7000 and Form_ID < 7499
	end





-- End By Ronak 11032022
--added by mansi 01-04-2022 for ESS
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'File Management' And Form_ID > 7000 and Form_ID < 7499)
	begin    
		select @Temp_Form_ID1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Temp_Form_ID1,'File Management',-1,324,1,'Home.aspx',@Loan_Claim_Img,1,'File Management')
	end
	else
	begin
		update T0000_DEFAULT_FORM set under_form_id=-1,[Sort_ID]=324,[Sort_ID_Check]=1,[Form_Image_url]=@Loan_Claim_Img where  Form_name = 'File Management' and  Form_ID > 7000 and Form_ID < 7499
	end

	Declare @Form_Id_File_ESS as numeric
	select @Form_Id_File_ESS = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'File Management' And Form_ID > 7000 and Form_ID < 7499


	
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'File Application' And Form_ID > 7000 and Form_ID < 7499)
	begin    
		select @Temp_Form_ID1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Temp_Form_ID1,'File Application',@Form_Id_File_ESS,324,1,'ESS_File_Application.aspx',@Loan_Claim_Img,1,'File Application')
	end
	else
	begin
		update T0000_DEFAULT_FORM set under_form_id=@Form_Id_File_ESS,[Sort_ID]=324,[Sort_ID_Check]=1,[Form_Image_url]=@Loan_Claim_Img where  Form_name = 'File Application' and  Form_ID > 7000 and Form_ID < 7499
	end

		if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'File Approve' And Form_ID > 7000 and Form_ID < 7499)
	begin    
		select @Temp_Form_ID1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Temp_Form_ID1,'File Approve',@Form_Id_File_ESS,325,1,'ESS_File_Approve.aspx',@Loan_Claim_Img,1,'File Approve')
	end
	else
	begin
		update T0000_DEFAULT_FORM set under_form_id=@Form_Id_File_ESS,[Sort_ID]=325,[Sort_ID_Check]=1,[Form_Image_url]=@Loan_Claim_Img where  Form_name = 'File Approve' and  Form_ID > 7000 and Form_ID < 7499
	end

		if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'File History' And Form_ID > 7000 and Form_ID < 7499)
	begin    
		select @Temp_Form_ID1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Temp_Form_ID1,'File History',@Form_Id_File_ESS,326,1,'ESS_File_History.aspx',@Loan_Claim_Img,1,'File History')
	end
	else
	begin
		update T0000_DEFAULT_FORM set under_form_id=@Form_Id_File_ESS,[Sort_ID]=326,[Sort_ID_Check]=1,[Form_Image_url]=@Loan_Claim_Img where  Form_name = 'File History' and  Form_ID > 7000 and Form_ID < 7499
	end

--end by mansi 01-04-2022 for ESS



-- Ronak K Date :- 01022022
--For Admin

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Grievance' And Form_ID > 6000 and Form_ID < 6499)
	begin    
		select @Temp_Form_ID1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Temp_Form_ID1,'Grievance',6070 ,251,1,'Home.aspx',@Loan_Claim_Img,1,'Grievance')
	end
	else
	begin
		update T0000_DEFAULT_FORM set under_form_id=6070,[Sort_ID]=251,[Sort_ID_Check]=1,[Form_Image_url]=@Loan_Claim_Img where  Form_name = 'Grievance' and  Form_ID > 6000 and Form_ID < 6499
	end

	Declare @Form_Id_Grev as numeric
	select @Form_Id_Grev = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Grievance' And Form_ID > 6000 and Form_ID < 6499
	

	--Added By ronakk 07022022
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Grievance Master' and Form_ID > 6000  and Form_ID < 6499  )
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000  and Form_ID < 6499  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
		values(@Menu_id1, N'Grievance Master', @Form_Id_Grev, 251, 1, N'Grievance_Master.aspx', @Loan_Claim_Img, 1, N'Grievance Master',1)
	end
	else
	begin
		update T0000_DEFAULT_FORM set under_form_id=@Form_Id_Grev,form_type=1,[Sort_ID]=251,[Sort_ID_Check]=1,[Form_Image_url]=@Loan_Claim_Img where  Form_name = 'Grievance Master'  and Form_ID > 6000  and Form_ID < 6499  
	end	
	
		--Added By ronakk 11022022
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Grievance Priority Master' and Form_ID > 6000  and Form_ID < 6499  )
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000  and Form_ID < 6499  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
		values(@Menu_id1, N'Grievance Priority Master', @Form_Id_Grev, 253, 1, N'Grievance_Priority_Master.aspx', @Loan_Claim_Img, 1, N'Grievance Priority Master',1)
	end
	else
	begin
		update T0000_DEFAULT_FORM set under_form_id=@Form_Id_Grev,form_type=1,[Sort_ID]=253,[Sort_ID_Check]=1,[Form_Image_url]=@Loan_Claim_Img where  Form_name = 'Grievance Priority Master' and Form_ID > 6000  and Form_ID < 6499  
	end	

		--Added By ronakk 14022022
		--Change by ronakk 04032022
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Grievance Cat. Master' and Form_ID > 6000  and Form_ID < 6499  )
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000  and Form_ID < 6499  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
		values(@Menu_id1, N'Grievance Cat. Master', @Form_Id_Grev, 254, 1, N'Grievance_Category_Master.aspx', @Loan_Claim_Img, 1, N'Grievance Cat. Masterr',1)
	end
	else
	begin
		update T0000_DEFAULT_FORM set under_form_id=@Form_Id_Grev,form_type=1,[Sort_ID]=254,[Sort_ID_Check]=1,[Form_Image_url]=@Loan_Claim_Img where  Form_name = 'Grievance Cat. Master' and Form_ID > 6000  and Form_ID < 6499  
	end	


		--Added By ronakk 28022022
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Committee Member Allocation' and Form_ID > 6000  and Form_ID < 6499  )
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000  and Form_ID < 6499  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
		values(@Menu_id1, N'Committee Member Allocation', @Form_Id_Grev, 255, 1, N'Griev_Committee_Member_Allocate.aspx', @Loan_Claim_Img, 1, N'Committee Member Allocation',1)
	end
	else
	begin
		update T0000_DEFAULT_FORM set under_form_id=@Form_Id_Grev,form_type=1,[Sort_ID]=255,[Sort_ID_Check]=1,[Form_Image_url]=@Loan_Claim_Img where  Form_name = 'Committee Member Allocation' and Form_ID > 6000  and Form_ID < 6499  
	end	


			--Added By ronakk 01032022
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Grievance Committee Master' and Form_ID > 6000  and Form_ID < 6499  )
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000  and Form_ID < 6499  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
		values(@Menu_id1, N'Grievance Committee Master', @Form_Id_Grev, 256, 1, N'Griev_Committee_Master.aspx', @Loan_Claim_Img, 1, N'Grievance Committee Master',1)
	end
	else
	begin
		update T0000_DEFAULT_FORM set under_form_id=@Form_Id_Grev,form_type=1,[Sort_ID]=256,[Sort_ID_Check]=1,[Form_Image_url]=@Loan_Claim_Img where  Form_name = 'Grievance Committee Master' and Form_ID > 6000  and Form_ID < 6499  
	end	




	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Grievance Application' and Form_ID > 6000  and Form_ID < 6499  )
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000  and Form_ID < 6499  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
		values(@Menu_id1, N'Grievance Application', @Form_Id_Grev, 257, 1, N'Grievance_Application1.aspx', @Loan_Claim_Img, 1, N'Grievance Application',2)
	end
	else
	begin
		update T0000_DEFAULT_FORM set under_form_id=@Form_Id_Grev,form_type=1,[Sort_ID]=257,[Sort_ID_Check]=2,[Form_Image_url]=@Loan_Claim_Img where  Form_name = 'Grievance Application' and Form_ID > 6000  and Form_ID < 6499  
	end	


	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Grievance Application Allocation' and Form_ID > 6000  and Form_ID < 6499  )
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000  and Form_ID < 6499  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
		values(@Menu_id1, N'Grievance Application Allocation', @Form_Id_Grev, 258, 1, N'Griev_Application_Allocation.aspx', @Loan_Claim_Img, 1, N'Grievance Application Allocation',2)
	end
	else
	begin
		update T0000_DEFAULT_FORM set under_form_id=@Form_Id_Grev,form_type=1,[Sort_ID]=258,[Sort_ID_Check]=2,[Form_Image_url]=@Loan_Claim_Img where  Form_name = 'Grievance Application Allocation' and Form_ID > 6000  and Form_ID < 6499  
	end	



	--Added by Ronakk 01042022
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Grievance Hearing' and Form_ID > 6000  and Form_ID < 6499  )
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000  and Form_ID < 6499  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
		values(@Menu_id1, N'Grievance Hearing', @Form_Id_Grev, 259, 1, N'Grievance_Hearing.aspx', @Loan_Claim_Img, 1, N'Grievance Hearing',2)
	end
	else
	begin
		update T0000_DEFAULT_FORM set under_form_id=@Form_Id_Grev,form_type=1,[Sort_ID]=259,[Sort_ID_Check]=2,[Form_Image_url]=@Loan_Claim_Img where  Form_name = 'Grievance Hearing' and Form_ID > 6000  and Form_ID < 6499  
	end	


	--Added by Ronakk 07042022
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Grievance Hearing Calendar' and Form_ID > 6000  and Form_ID < 6499  )
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000  and Form_ID < 6499  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
		values(@Menu_id1, N'Grievance Hearing Calendar', @Form_Id_Grev, 260, 1, N'Griev_Calendar.aspx', @Loan_Claim_Img, 1, N'Grievance Hearing Calendar',2)
	end
	else
	begin
		update T0000_DEFAULT_FORM set under_form_id=@Form_Id_Grev,form_type=1,[Sort_ID]=260,[Sort_ID_Check]=2,[Form_Image_url]=@Loan_Claim_Img where  Form_name = 'Grievance Hearing Calendar' and Form_ID > 6000  and Form_ID < 6499  
	end	



	--Added by Ronakk 17052022
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Grievance Dashboard' and Form_ID > 6000  and Form_ID < 6499  )
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000  and Form_ID < 6499  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
		values(@Menu_id1, N'Grievance Dashboard', @Form_Id_Grev, 261, 1, N'GrievDashboard.aspx', @Loan_Claim_Img, 1, N'Grievance Dashboard',2)
	end
	else
	begin
		update T0000_DEFAULT_FORM set under_form_id=@Form_Id_Grev,form_type=1,[Sort_ID]=261,[Sort_ID_Check]=2,[Form_Image_url]=@Loan_Claim_Img where  Form_name = 'Grievance Dashboard' and Form_ID > 6000  and Form_ID < 6499  
	end	



--END Ronak K Date :- 01022022


--start by mansi  030322
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'File Management' And Form_ID > 6000 and Form_ID < 6499)
	begin    
		select @Temp_Form_ID1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Temp_Form_ID1,'File Management',6070 ,251,1,'Home.aspx',@Loan_Claim_Img,1,'File Management')
	end
	else
	begin
		update T0000_DEFAULT_FORM set under_form_id=6070,[Sort_ID]=251,[Sort_ID_Check]=1,[Form_Image_url]=@Loan_Claim_Img where  Form_name = 'File Management' and  Form_ID > 6000 and Form_ID < 6499
	end
	Declare @Form_Id_FM as numeric
	select @Form_Id_FM = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'File Management' And Form_ID > 6000 and Form_ID < 6499
	

	----need to comment for FM Status start
	--if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'FM Status Master')
	--begin
	--	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000  and Form_ID < 6499  
	--	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
	--	values(@Menu_id1, N'FM Status Master', @Form_Id_FM, 251, 1, N'File_Status_Master.aspx', @Loan_Claim_Img, 1, N'FM Status Master',1)
	--end
	--else
	--begin
	--	update T0000_DEFAULT_FORM set under_form_id=@Form_Id_FM,form_type=1,[Sort_ID]=251,[Sort_ID_Check]=1,[Form_Image_url]=@Loan_Claim_Img where  Form_name = 'FM Status Master'
	--end	
	--	--need to comment for FM Status end
	
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'FM Type Master')
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000  and Form_ID < 6499  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
		values(@Menu_id1, N'FM Type Master', @Form_Id_FM, 252, 1, N'File_Type_Master.aspx', @Loan_Claim_Img, 1, N'FM Type Master',1)
	end
	else
	begin
		update T0000_DEFAULT_FORM set under_form_id=@Form_Id_FM,form_type=1,[Sort_ID]=252,[Sort_ID_Check]=1,[Form_Image_url]=@Loan_Claim_Img where  Form_name = 'FM Type Master' And Form_ID > 6000 and Form_ID < 6499
	end	
	
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'File Application' and Form_ID > 6000  and Form_ID < 6499)
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000  and Form_ID < 6499  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
		values(@Menu_id1, N'File Application', @Form_Id_FM, 253, 1, N'File_Admin_Application.aspx', @Loan_Claim_Img, 1, N'File Application',1)
	end
	else
	begin
		update T0000_DEFAULT_FORM set under_form_id=@Form_Id_FM,form_type=1,[Sort_ID]=253,[Sort_ID_Check]=1,[Form_Image_url]=@Loan_Claim_Img where  Form_name = 'File Application' And Form_ID > 6000 and Form_ID < 6499
	end	

	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'File Admin Approval' and Form_ID > 6000  and Form_ID < 6499)
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000  and Form_ID < 6499  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
		values(@Menu_id1, N'File Admin Approval', @Form_Id_FM, 254, 1, N'File_Admin_Approve.aspx', @Loan_Claim_Img, 1, N'File Admin Approval',1)
	end
	else
	begin
		update T0000_DEFAULT_FORM set under_form_id=@Form_Id_FM,form_type=1,[Sort_ID]=254,[Sort_ID_Check]=1,[Form_Image_url]=@Loan_Claim_Img where  Form_name = 'File Admin Approval'  and Form_ID > 6000  and Form_ID < 6499
	end	

	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'File Approve' and Form_ID > 6000  and Form_ID < 6499)
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000  and Form_ID < 6499  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
		values(@Menu_id1, N'File Approve', @Form_Id_FM, 255, 1, N'File_Approve.aspx', @Loan_Claim_Img, 1, N'File Approve',1)
	end
	else
	begin
		update T0000_DEFAULT_FORM set under_form_id=@Form_Id_FM,form_type=1,[Sort_ID]=255,[Sort_ID_Check]=1,[Form_Image_url]=@Loan_Claim_Img where  Form_name = 'File Approve' and Form_ID > 6000  and Form_ID < 6499
	end	

	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'File History' and Form_ID > 6000  and Form_ID < 6499)
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000  and Form_ID < 6499  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
		values(@Menu_id1, N'File History', @Form_Id_FM, 256, 1, N'File_Admin_History.aspx', @Loan_Claim_Img, 1, N'File History',1)
	end
	else
	begin
		update T0000_DEFAULT_FORM set under_form_id=@Form_Id_FM,form_type=1,[Sort_ID]=256,[Sort_ID_Check]=1,[Form_Image_url]=@Loan_Claim_Img where  Form_name = 'File History' and Form_ID > 6000  and Form_ID < 6499
	end	

	--added by mansi on 31-08-22
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'File Dashboard' and Form_ID > 6000  and Form_ID < 6499)
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000  and Form_ID < 6499  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
		values(@Menu_id1, N'File Dashboard', @Form_Id_FM, 257, 1, N'File_Dashboard.aspx', @Loan_Claim_Img, 1, N'File Dashboard',1)
	end
	else
	begin
		update T0000_DEFAULT_FORM set under_form_id=@Form_Id_FM,form_type=1,[Sort_ID]=257,[Sort_ID_Check]=1,[Form_Image_url]=@Loan_Claim_Img where  Form_name = 'File Dashboard' and Form_ID > 6000  and Form_ID < 6499
	end	
	--ended by mansi on 31-08-22
--end by mansi  030322

--added by mehul 24032022 for admin side

	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Medical' And Form_ID > 6000 and Form_ID < 6499)
	begin    
		select @Temp_Form_ID1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Temp_Form_ID1,'Medical',6070 ,251,1,'Home.aspx',@Loan_Claim_Img,1,'Medical')
	end
	else
	begin
		update T0000_DEFAULT_FORM set under_form_id=6070,[Sort_ID]=251,[Sort_ID_Check]=1,[Form_Image_url]=@Loan_Claim_Img where  Form_name = 'Medical' and  Form_ID > 6000 and Form_ID < 6499
	end
	Declare @Form_Id_Medical as numeric
	select @Form_Id_Medical = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Medical' And Form_ID > 6000 and Form_ID < 6499
	
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Medical Application')
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000  and Form_ID < 6499  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
		values(@Menu_id1, N'Medical Application', @Form_Id_Medical, 251, 1, N'Medical_Application.aspx', @Loan_Claim_Img, 1, N'Medical Application',1)
	end
	else
	begin
		update T0000_DEFAULT_FORM set under_form_id=@Form_Id_Medical,form_type=1,[Sort_ID]=251,[Sort_ID_Check]=1,[Form_Image_url]=@Loan_Claim_Img where  Form_name = 'Medical Application'
	end	

--end

-- added by mehul for ess side

	--	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Medical' And Form_ID > 7000 and Form_ID < 7499)
	--begin    
	--	select @Temp_Form_ID1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7499
	--	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	--	values (@Temp_Form_ID1,'Medical',-1,321,1,'Home.aspx',@Loan_Claim_Img,1,'Medical')
	--end
	--else
	--begin
	--	update T0000_DEFAULT_FORM set under_form_id=-1,[Sort_ID]=321,[Sort_ID_Check]=1,[Form_Image_url]=@Loan_Claim_Img where  Form_name = 'Medical' and  Form_ID > 7000 and Form_ID < 7499
	--end

	--Declare @Form_Id_MedicalEss as numeric
	--select @Form_Id_MedicalEss = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Medical' And Form_ID > 7000 and Form_ID < 7499

	--	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Medical Application' And Form_ID > 7000 and Form_ID < 7499)
	--begin    
	--	select @Temp_Form_ID1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7499
	--	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	--	values (@Temp_Form_ID1,'Medical Application',@Form_Id_MedicalEss,321,1,'Ess_Medical_Application.aspx',@Loan_Claim_Img,1,'Medical Application')
	--end
	--else
	--begin
	--	update T0000_DEFAULT_FORM set under_form_id=@Form_Id_MedicalEss,[Sort_ID]=321,[Sort_ID_Check]=1,[Form_Image_url]=@Loan_Claim_Img where  Form_name = 'Medical Application' and  Form_ID > 7000 and Form_ID < 7499
	--end
	--added start 
	
		if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Medical' And Form_ID > 7000 and Form_ID < 7499)
	begin    
		select @Temp_Form_ID1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Temp_Form_ID1,'Medical',-1,322,1,'Home.aspx',@Loan_Claim_Img,1,'Medical')
	end
	else
	begin
		update T0000_DEFAULT_FORM set under_form_id=-1,[Sort_ID]=322,[Sort_ID_Check]=1,[Form_Image_url]=@Loan_Claim_Img where  Form_name = 'Medical' and  Form_ID > 7000 and Form_ID < 7499
	end

	Declare @Form_Id_MedicalEss as numeric
	select @Form_Id_MedicalEss = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Medical' And Form_ID > 7000 and Form_ID < 7499

		if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Medical Application' And Form_ID > 7000 and Form_ID < 7499)
	begin    
		select @Temp_Form_ID1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Temp_Form_ID1,'Medical Application',@Form_Id_MedicalEss,322,1,'Ess_Medical_Application.aspx',@Loan_Claim_Img,1,'Medical Application')
	end
	else
	begin
		update T0000_DEFAULT_FORM set under_form_id=@Form_Id_MedicalEss,[Sort_ID]=322,[Sort_ID_Check]=1,[Form_Image_url]=@Loan_Claim_Img where  Form_name = 'Medical Application' and  Form_ID > 7000 and Form_ID < 7499
	end

	---added end

--end


------Added on 19 June 2014 Mukti (start)-------------------------------------
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Scheme Details My#')  
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7500 and Form_ID < 7999  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Scheme Details My#',7532,402,1,NULL, NULL, 1, N'Scheme Details My#')

	end


if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Scheme Details Report' And Form_ID > 6700 and Form_ID < 6999) 
	begin
		
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700  and Form_ID < 6999	  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Scheme Details Report',6701, 172,1,NULL, NULL, 1, N'Scheme Details Report')
		
	end	
------Added on 19 June 2014 Mukti (end)-------------------------------------

------Added on 28 Jan 2015 Mukti (start)---------------------------------------------
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Recruitment Request Approval' And Form_ID > 7000 and Form_ID < 7500)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Recruitment Request Approval', 7029,384,1,'Recruitment_Application_Approval.aspx',@HR_Img,1,'Recruitment Request Approval')
	end	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Candidate Approval' And Form_ID > 7000 and Form_ID < 7500)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Candidate Approval', 7029,384,1,'HRMS_ResumeFinal_Approval.aspx',@HR_Img,1,'Candidate Approval')
	end	
------Added on 28 Jan 2015 Mukti (end)---------------------------------------------

---Added On 19 Jun 2014 Ripal (Start)-------------
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Allowance/Reimbursement Application' And Form_ID > 7000 and Form_ID < 7499)
begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7499
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	values (@Menu_id1,'Allowance/Reimbursement Application',7013 ,322,1,'AssignOptionalAllowance.aspx',@Loan_Claim_Img,1,'Allowance/Reimbursement Application')
end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Allowance/Reimbursement Approval') 
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000  and Form_ID < 6499  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'Allowance/Reimbursement Approval', 6070, 125, 1, N'AllowanceReimApplicationApproval.aspx', @Loan_Claim_Img, 1, N'Allowance/Reimbursement Approval')
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Allowance/Reimbursement Approval' And Form_ID > 7000 and Form_ID < 7499)
begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7499
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	values (@Menu_id1,'Allowance/Reimbursement Approval',7013 ,322,1,'AllowanceReimAppApprovalManager.aspx',@Loan_Claim_Img,1,'Allowance/Reimbursement Approval')
end
---Added On 19 Jun 2014 Ripal (End)-------------

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Travel Approval - Help Desk' And Form_ID > 6000 and Form_ID < 6500)
begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	values (@Menu_id1,'Travel Approval - Help Desk',6151 ,124,1,'Travel_Approval_Admin_Desk.aspx',@Loan_Claim_Img,1,'Travel Approval - Help Desk')
end

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Travel Mode Master' And Form_ID > 6000 and Form_ID < 6500)
begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	values (@Menu_id1,'Travel Mode Master',6013 ,34,1,'Travel_Mode_Master.aspx',@Masters_Img,1,'Travel Mode Master')
end

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Joining Status Updation Corporate BMA' And Form_ID > 6500 and Form_ID < 6700)
begin    
select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 6700
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(@Menu_id1, N'Joining Status Updation Corporate BMA', 6501, 204, 1, N'HRMS/HRMS_Candidate_Finalization_details_Corporate_BMA.aspx', N'menu/Recruitement.png', 0, N'Joining Status Updation Corporate')
end

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Weekoff Approval' And Form_ID > 6000 and Form_ID < 6500)
begin    
select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(@Menu_id1, N'Weekoff Approval', 6042, 70, 1, N'Weekoff_Approval.aspx', @Employee_Img, 1, N'Weekoff Approval')
end

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Weekoff Request' And Form_ID > 7000 and Form_ID < 7499)
begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7499
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(@Menu_id1, N'Weekoff Request', 7001, 307, 1, N'Weekoff_Request.aspx', @Employee_Img, 1, N'Weekoff Request')
end
else
BEGIN--ADDED BY JAINA 19-09-2016
		update T0000_DEFAULT_FORM 
		set Form_url='home.aspx',
			Sort_ID = 307 
		where Form_Name = 'Weekoff Request' and Form_ID > 7000 and Form_ID < 7499
END

--'' Ankit 01092014 ''--
--If not exists (select Form_id from T0000_DEFAULT_FORM where  Form_name = 'Employee AllowDedu Revised' And Form_ID > 6000 and Form_ID < 6499 )
--	begin
--		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID > 6000 and Form_ID < 6499
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
--		values (@Menu_id1,'Employee AllowDedu Revised',6042, 68, 1,'Employee_AllowDedu_Revised.aspx',@Employee_Img,1,'Employee AllowDedu Revised')
--	end
	
	Declare @temp_menu_id_Increment as numeric(18,0)
If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee-Increment' and Form_ID>6000 and Form_ID<6500)
	begin
		
		
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6499
		set @temp_menu_id_Increment = @Menu_id1
		
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Employee-Increment',6042, 68, 1,'home.aspx',@Employee_Img,1,'Employee-Increment')
		
		Update T0000_DEFAULT_FORM Set Under_Form_ID= @temp_menu_id_Increment where Form_Name in ('Employee Increment','Employee AllowDedu Revised','Employee Bulk Increment','Employee Additional GPF Request') and Form_ID>6000 and Form_ID<6500
		
		
		Update T0000_DEFAULT_FORM Set Sort_id_check = 1 Where Form_Name = 'Employee Increment' And Form_ID>6000 And Form_ID<6500
		Update T0000_DEFAULT_FORM Set Sort_id_check = 2 Where Form_Name = 'Employee Bulk Increment' And Form_ID>6000 And Form_ID<6500
		Update T0000_DEFAULT_FORM Set Sort_id_check = 3 Where Form_Name = 'Employee AllowDedu Revised' And Form_ID>6000 And Form_ID<6500
		Update T0000_DEFAULT_FORM Set Sort_id_check = 6 Where Form_Name = 'Employee Additional GPF Request' And Form_ID>6000 And Form_ID<6500
		
	end
	ELSE
	BEGIN
		
		SELECT @temp_menu_id_Increment=Form_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee-Increment' and Form_ID>6000 and Form_ID<6500
		Update T0000_DEFAULT_FORM Set Under_Form_ID= @temp_menu_id_Increment where Form_Name in ('Employee Increment','Employee AllowDedu Revised','Employee Bulk Increment','Employee Additional GPF Request','Employee Increment Application') and Form_ID>6000 and Form_ID<6500
				
		Update T0000_DEFAULT_FORM Set Sort_id_check = 1 Where Form_Name = 'Employee Increment' And Form_ID>6000 And Form_ID<6500
		Update T0000_DEFAULT_FORM Set Sort_id_check = 2 Where Form_Name = 'Employee Bulk Increment' And Form_ID>6000 And Form_ID<6500
		Update T0000_DEFAULT_FORM Set Sort_id_check = 3 Where Form_Name = 'Employee AllowDedu Revised' And Form_ID>6000 And Form_ID<6500
		Update T0000_DEFAULT_FORM Set Sort_id_check = 6 Where Form_Name = 'Employee Additional GPF Request' And Form_ID>6000 And Form_ID<6500
	END
	
	If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Bulk Increment')
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Employee Bulk Increment',@temp_menu_id_Increment, 68, 1,'Bulk_Increment.aspx',@Employee_Img,1,'Employee Bulk Increment')
	--6402
	end
	
	If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee AllowDedu Revised' And Form_ID > 6000 and Form_ID < 6499 )
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Employee AllowDedu Revised',@temp_menu_id_Increment, 68, 1,'Employee_AllowDedu_Revised.aspx',@Employee_Img,1,'Employee AllowDedu Revised')
	--6402
	end

If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee-Transfer' and Form_ID>6000 and Form_ID<6500)
	begin
		Set @temp_menu_id_Increment  = 0
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6499
		set @temp_menu_id_Increment = @Menu_id1

		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Employee-Transfer',6042, 69, 1,'home.aspx',@Employee_Img,1,'Employee-Transfer')
		
		UPDATE T0000_DEFAULT_FORM SET Under_Form_ID= @temp_menu_id_Increment WHERE Form_Name in ('Employee Transfer','Employee Company Transfer','Employee Company Transfer Multi') and Form_ID > 6000 and Form_ID < 6500
	end
If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee-Weekoff' and Form_ID>6000 and Form_ID<6500)
	begin
		Set @temp_menu_id_Increment  = 0
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6499
		set @temp_menu_id_Increment = @Menu_id1

		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Employee-Weekoff',6042, 70, 1,'home.aspx',@Employee_Img,1,'Employee-Weekoff')
		
		UPDATE T0000_DEFAULT_FORM SET Under_Form_ID= @temp_menu_id_Increment WHERE Form_Name in ('Employee Weekoff','Half Weekoff','Weekoff Approval') and Form_ID > 6000 and Form_ID < 6500
	end
--ADDED BY GADRIWALA MUSLIM 29092016 - START	
IF EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE FORM_NAME = 'Employee Weekoff' AND FORM_ID > 6000 AND FORM_ID <6500)
	BEGIN
		DELETE FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Employee Weekoff' AND FORM_ID > 6000 AND FORM_ID < 6500
	END
IF EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE FORM_NAME = 'Employee Shift Change' AND FORM_ID > 6000 AND FORM_ID <6500)
	BEGIN
		DELETE FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Employee Shift Change' AND FORM_ID > 6000 AND FORM_ID < 6500
	END
--ADDED BY GADRIWALA MUSLIM 29092016 - END
--'' Ankit 01092014 ''--
--Added by Gadriwala Muslim 11102014 - End
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Comp-Off Leave Adjustment Details' And Form_ID > 6000 and Form_ID < 7000) 
	begin    
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 7000
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(@Menu_id1, N'Comp-Off Leave Adjustment Details', 6703, 176, 1, NULL, NULL, 1, N'Comp-Off Leave Adjustment Details')
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Comp-Off Leave Adjustment Details My#' And Form_ID > 7500 and Form_ID < 8000) 
	begin    
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7500 and Form_ID < 8000
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(@Menu_id1, N'Comp-Off Leave Adjustment Details My#', 7525, 393, 1, NULL, NULL, 1, N'Comp-Off Leave Adjustment Details My#')
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Comp-Off Leave Adjustment Details Member#' And Form_ID > 7500 and Form_ID < 8000) 
	begin 
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7500 and Form_ID < 8000
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(@Menu_id1, N'Comp-Off Leave Adjustment Details Member#', 7507, 347, 1, NULL, NULL, 1, N'Comp-Off Leave Adjustment Details Member#')
	end

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Comp-Off Avail Balance My#' And Form_ID > 7500 and Form_ID < 8000) 
	begin    

			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7500 and Form_ID < 8000
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(@Menu_id1, N'Comp-Off Avail Balance My#', 7525, 394, 1, NULL, NULL, 1, N'Comp-Off Avail Balance My#')
	end


	
--Added by Gadriwala Muslim 11102014 - Start
---23 May 2014---to make old appraisal old inactive(Start)
update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='Rating Master'
update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='Goal Master'
update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='Appraisal General Setting'
update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='Skill General Setting'
update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='Assign Goal'
update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='Employee Skill Rating'
update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='Initiate Appraisal'
update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='Appraisal Approval'
update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='Initiate Appraisal Report'
---23 May 2014---to make old appraisal old inactive(End)

--added on 1 July 2015- default inactive appraisal-1-sneha
update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='KPI Import'
update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='KPI Master'
update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='KPI Setting'
update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='KPI Objectives'
update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='KPI Appraisal Form'
update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='KPIPMS Final Evaluation'
--ended on 1 July 2015- default inactive appraisal-1-sneha
--added on 1 July 2015- default inactive performance appraisal-sneha
update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='Performance Appraisal'
update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='Performance Rating Master'
update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='GoalType Master'
update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='Competency Master'
update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='Setting Master'
update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='Review Employee Goal'
update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='Review Performance Summary'
update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='Review Competency'


update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='define goal' and form_id>7000
update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='Employee Goal' and form_id>7000
update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='Review Goal' and form_id>7000
update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='Review Employee PerformanceSummary' and form_id>7000
update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='Review Employee Competency' and form_id>7000

--ended on 1 July 2015- default inactive performance appraisal-sneha

-- Added by rohit on 07102014
	if exists(select form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name ='Sub Branch master' and  Form_ID > 6000 and Form_ID < 6500)
	begin
	
		Update T0000_DEFAULT_FORM set Form_name='SubBranch Master',Alias ='SubBranch Master'  where Form_Name ='Sub Branch Master' and  Form_ID > 6000 and Form_ID < 6500
	
	end
	--Added by Gadriwala Muslim 30102014 - Start
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Leave Balance with Amount' And Form_ID > 6000 and Form_ID < 7000) 
		begin    
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 7000
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(@Menu_id1, N'Leave Balance with Amount', 6703, 176, 1, NULL, NULL, 1, N'Leave Balance with Amount')
		end
	--Added by Gadriwala Muslim 30102014 - End
	
	---Ripal 07 Nov 2014---(start)-----
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Reimbursement Sub Expense Detail' And Form_ID > 6000 and Form_ID < 6499)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Reimbursement Sub Expense Detail',6027 ,44,1,'Master_Allowance_Expense.aspx',@Masters_Img,1,'Reimbursement Sub Expense Detail')
	end
	---Ripal 07 Nov 2014---(end)-------
	
	-- Added by rohit on 10112014 for update Sequence of job master.
		--Update T0000_DEFAULT_FORM set Sort_ID=20,Sort_Id_Check =1 where Form_Name ='Asset Master' and  Under_Form_ID=6013
		Update T0000_DEFAULT_FORM set Sort_ID=20,Sort_Id_Check =2 where Form_Name ='Attendance Reason Master' and  Under_Form_ID=6013
		Update T0000_DEFAULT_FORM set Sort_ID=20,Sort_Id_Check =3 where Form_Name ='Branch master' and  Under_Form_ID=6013
		Update T0000_DEFAULT_FORM set Sort_ID=20,Sort_Id_Check =4 where Form_Name ='SubBranch Master' and  Under_Form_ID=6013
		Update T0000_DEFAULT_FORM set Sort_ID=20,Sort_Id_Check =5 where Form_Name ='State Master' and  Under_Form_ID=6013
		Update T0000_DEFAULT_FORM set Sort_ID=20,Sort_Id_Check =6 where Form_Name ='Country Master' and  Under_Form_ID=6013
		Update T0000_DEFAULT_FORM set Sort_ID=20,Sort_Id_Check =7 where Form_Name ='Department Master' and  Under_Form_ID=6013
		Update T0000_DEFAULT_FORM set Sort_ID=20,Sort_Id_Check =8 where Form_Name ='Designation Master' and  Under_Form_ID=6013
		Update T0000_DEFAULT_FORM set Sort_ID=20,Sort_Id_Check =9 where Form_Name ='Grade Master' and  Under_Form_ID=6013
		Update T0000_DEFAULT_FORM set Sort_ID=20,Sort_Id_Check =10 where Form_Name ='Shift Master' and  Under_Form_ID=6013
		--Update T0000_DEFAULT_FORM set Sort_ID=20,Sort_Id_Check =11 where Form_Name ='Brand Master' and  Under_Form_ID=6013
		Update T0000_DEFAULT_FORM set Sort_ID=20,Sort_Id_Check =12 where Form_Name ='Category Master' and  Under_Form_ID=6013
		Update T0000_DEFAULT_FORM set Sort_ID=20,Sort_Id_Check =13 where Form_Name ='Cost Center Master' and  Under_Form_ID=6013
		Update T0000_DEFAULT_FORM set Sort_ID=20,Sort_Id_Check =14 where Form_Name ='Employee Type Master' and  Under_Form_ID=6013
		Update T0000_DEFAULT_FORM set Sort_ID=20,Sort_Id_Check =15 where Form_Name ='Expense Type Master' and  Under_Form_ID=6013
		Update T0000_DEFAULT_FORM set Sort_ID=20,Sort_Id_Check =16 where Form_Name ='Insurance/Medical Master' and  Under_Form_ID=6013
		Update T0000_DEFAULT_FORM set Sort_ID=20,Sort_Id_Check =17 where Form_Name ='Minimum Wages Master' and  Under_Form_ID=6013
		Update T0000_DEFAULT_FORM set Sort_ID=20,Sort_Id_Check =18 where Form_Name ='Skill Type Master' and  Under_Form_ID=6013
		Update T0000_DEFAULT_FORM set Sort_ID=20,Sort_Id_Check =19 where Form_Name ='Policy Document Master' and  Under_Form_ID=6013
		Update T0000_DEFAULT_FORM set Sort_ID=20,Sort_Id_Check =20 where Form_Name ='Project Master' and  Under_Form_ID=6013
		Update T0000_DEFAULT_FORM set Sort_ID=20,Sort_Id_Check =21 where Form_Name ='Question Master' and  Under_Form_ID=6013
		Update T0000_DEFAULT_FORM set Sort_ID=20,Sort_Id_Check =22 where Form_Name ='Salary Cycle Master' and  Under_Form_ID=6013
		Update T0000_DEFAULT_FORM set Sort_ID=20,Sort_Id_Check =23 where Form_Name ='Source Master' and  Under_Form_ID=6013
		Update T0000_DEFAULT_FORM set Sort_ID=20,Sort_Id_Check =24 where Form_Name ='Travel Mode Master' and  Under_Form_ID=6013
		Update T0000_DEFAULT_FORM set Sort_ID=20,Sort_Id_Check =25 where Form_Name ='Business Segment Master' and  Under_Form_ID=6013
		Update T0000_DEFAULT_FORM set Sort_ID=20,Sort_Id_Check =26 where Form_Name ='Vertical Master' and  Under_Form_ID=6013
		Update T0000_DEFAULT_FORM set Sort_ID=20,Sort_Id_Check =27 where Form_Name ='SubVertical Master' and  Under_Form_ID=6013
-- Ended by rohit on 10112014
-- added on 28 Nov 2014 for training feedback form sneha
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_288' And Form_ID > 9000 and Form_ID < 10000)
	begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 10000
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	values (@Menu_id1,'TD_Home_ESS_288',9261,1274,1,'','',1,'Give Training Feedback')
	end	
----- added end on 28 Nov 2014 for training feedback form 

	--Ankit  - 16122014 - Start
	IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Night Halt Application' And Form_ID > 7000 and Form_ID < 7500) 
		BEGIN    
			SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 7000     and Form_ID < 7500  
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
			VALUES (@Menu_id1,'Night Halt Application',7005,315,1,'Night_Halt_Application.aspx',@Leave_Img, 1, N'Night Halt Application')
		END
		
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Night Halt' And Form_ID > 6000 and Form_ID < 7000) 
		BEGIN    
			SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000     and Form_ID < 6500  
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
			VALUES (@Menu_id1,'Night Halt',6057,99,1,'Home.aspx',@Leave_Img, 1, N'Night Halt')
		END	
declare @Night_Halt_Id as Numeric(18,0)
SELECT @Night_Halt_Id = Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Night Halt' And Form_ID > 6000 and Form_ID < 7000		
		
	IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Night Halt Approve' And Form_ID > 6000 and Form_ID < 7000) 
		BEGIN    
			SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000     and Form_ID < 6500  
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
			VALUES (@Menu_id1,'Night Halt Approve',@Night_Halt_Id,99,1,'Night_Halt_Approval.aspx',@Leave_Img, 1, N'Night Halt Approve')
		END	
	else
		Begin
			Update [T0000_DEFAULT_FORM] set Under_Form_ID = @Night_Halt_Id,Sort_Id_Check = 2 where Form_name = 'Night Halt Approve' And Form_ID > 6000 and Form_ID < 7000
		End

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Night Halt Application Admin' And Form_ID > 6000 and Form_ID < 7000) 
		BEGIN    
			SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000     and Form_ID < 6500  
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_Check])
			VALUES (@Menu_id1,'Night Halt Application Admin',@Night_Halt_Id,99,1,'Night_Halt_Application_Admin.aspx',@Leave_Img, 1, N'Night Halt Application',1)
		END			
		
	--Ankit  - 16122014 - End
	---------------17 dec 2014 rewards sneha---------------

	Declare @Temp_Form_ID_HR as Numeric(18,0)
	select @Temp_Form_ID_HR = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'HR Documents' And Form_ID > 6500 and Form_ID < 6700
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Rewards & Recognition' And Form_ID > 6500 and Form_ID < 6700) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 6700
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'Rewards & Recognition', @Temp_Form_ID_HR, 243, 1, N'HRMS/HR_Home.aspx', N'menu/trophy.png', 1, N'Rewards & Recognition')			
	end


	Declare @Temp_Form_ID_RR as Numeric(18,0)
	select @Temp_Form_ID_RR = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Rewards & Recognition' And Form_ID > 6500 and Form_ID < 6700
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Initiate Employee Reward' And Form_ID > 6500 and Form_ID < 6700) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 6700
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'Initiate Employee Reward', @Temp_Form_ID_RR, 243, 1, N'HRMS/HRMS_InitiateEmpReward.aspx', N'menu/trophy.png', 1, N'Initiate Employee Reward')			
	end


	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Reward' And Form_ID > 6500 and Form_ID < 6700) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 6700
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'Employee Reward', @Temp_Form_ID_RR, 243, 1, N'HRMS/HRMS_EmployeeRewards.aspx', N'menu/trophy.png', 1, N'Employee Reward')			
	end
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Rewards & Recognition' And Form_ID > 7000 and Form_ID < 7500)
		begin    
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
			values (@Menu_id1,'Rewards & Recognition',7029,386,1,'Home.aspx',@HR_Img,0,'Rewards & Recognition')
		end
	else --Added by Mukti(02052019) 
		begin 
			UPDATE T0000_DEFAULT_FORM SET Is_Active_For_menu=0 WHERE Form_name = 'Rewards & Recognition' AND Page_Flag='EP'
		END	
	

	Declare @Temp_Form_ID_RR_ess as Numeric(18,0)
	select @Temp_Form_ID_RR_ess = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Rewards & Recognition' And Form_ID > 7000 and Form_ID < 7500
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Reward' And Form_ID > 7000 and Form_ID < 7500) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'Employee Reward', @Temp_Form_ID_RR_ess, 386, 1, N'Ess_HRMS_EmployeeReward.aspx', @HR_Img, 1, N'Employee Reward')			
	end
	
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_341' And Form_ID > 9000 and Form_ID < 10000)
	begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 10000
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	values (@Menu_id1,'TD_Home_ESS_341',9261,1298,1,'','',1,'Employee Rewards Initiated')
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_Admin_138' And Form_ID > 9000 and Form_ID < 10000)
	begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 9200
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	values (@Menu_id1,'TD_Home_Admin_138',9131,1138,1,'','',1,'Employee Rewards Display')
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_306' And Form_ID > 9000 and Form_ID < 10000)
	begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 10000
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	values (@Menu_id1,'TD_Home_ESS_306',9301,1306,1,'','',1,'Employee Rewards Display')
	end
	---------------17 dec 2014 rewards end-----------------
	---------------19 dec 2014 screen sneha---------------
	Declare @Temp_Form_ID_Rec as Numeric(18,0)
    select @Temp_Form_ID_Rec = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'HRMS' And Form_ID > 7000 and Form_ID < 7500	
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Resume For Screening' And Form_ID > 7000 and Form_ID < 7500)
		begin    
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
			values (@Menu_id1,'Resume For Screening',@Temp_Form_ID_Rec,372,1,'ess_resumescreening.aspx',@HR_Img,1,'Resume For Screening')
		end	
	---------------19 dec 2014 screen end---------------
	
--------------Added By Mukti 24122014(start)-------------------------------	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK)  where  Form_name = 'TD_Home_Admin_65' And Form_ID > 9000 and Form_ID < 10000)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 9200
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'TD_Home_Admin_65',9061,1065,1,'','',1,'Survey')
	end
	
--Added by Gadriwala Muslim 27042015 - Start	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_Admin_67' And Form_ID > 9000 and Form_ID < 10000)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 9200
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'TD_Home_Admin_67',9061,1065,1,'','',1,'IT Declaration History')
	end		
--Added by Gadriwala Muslim 27042015 - End
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_345' And Form_ID > 9000 and Form_ID < 10000)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 10000
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'TD_Home_ESS_345',9261,1274,1,'','',1,'Fill Up The Survey Form')
	end
--------------Added By Mukti 24122014(end)-------------------------------	

---------------24 dec 2014 kpi sneha-------------------
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'KPI Master' And Form_ID > 6500 and Form_ID < 6700) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 6700
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'KPI Master', 6518, 230, 1, N'HRMS/KPI_Main.aspx', N'menu/company_structure.gif', 1, N'KPI Master')			
	end 
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK)where  Form_name = 'KPI Setting' And Form_ID > 6500 and Form_ID < 6700) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 6700
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'KPI Setting', 6518, 230, 1, N'HRMS/KPI_Setting.aspx', N'menu/company_structure.gif', 1, N'KPI Setting')			
	end	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'KPI Objectives' And Form_ID > 6500 and Form_ID < 6700) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 6700
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'KPI Objectives', 6518, 230, 1, N'HRMS/KPI_Master.aspx', N'menu/company_structure.gif', 1, N'KPI Objectives')			
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'KPI Appraisal Form' And Form_ID > 6500 and Form_ID < 6700) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 6700
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'KPI Appraisal Form', 6518, 230, 1, N'HRMS/KPIPMS_AppraisalForm.aspx', N'menu/company_structure.gif', 1, N'KPI Appraisal Form')			
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'KPIPMS Final Evaluation' And Form_ID > 6500 and Form_ID < 6700) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 6700
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'KPIPMS Final Evaluation', 6518, 230, 1, N'HRMS/KPI_FinalForm.aspx', N'menu/company_structure.gif', 1, N'KPIPMS Final Evaluation')			
	end
	--ess	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'KPI/PMS' And Form_ID > 7000 and Form_ID < 7500)
	begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	values (@Menu_id1,'KPI/PMS',7029,382,1,'Home.aspx',@HR_Img,1,'KPI/PMS')
	end	
Declare @Temp_Form_ID_Kpi as Numeric(18,0)
select @Temp_Form_ID_kpi = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'KPI/PMS' And Form_ID > 7000 and Form_ID < 7500

--if not exists (select Form_id from T0000_DEFAULT_FORM where  Form_name = 'KPI Master' And Form_ID > 7000 and Form_ID < 7500)
--	begin    
--	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID > 7000 and Form_ID < 7500
--	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
--	values (@Menu_id1,'KPI Master',@Temp_Form_ID_kpi,382,1,'ESS_KPIMaster.aspx','menu/process.png',1,'KPI Master')
--	end	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'KPI Objectives' And Form_ID > 7000 and Form_ID < 7500)
	begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	values (@Menu_id1,'KPI Objectives',@Temp_Form_ID_kpi,382,1,'Ess_KPIEmployeeReview.aspx','menu/process.png',1,'KPI Objectives')
	end	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee KPI Objectives' And Form_ID > 7000 and Form_ID < 7500)
	begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	values (@Menu_id1,'Employee KPI Objectives',@Temp_Form_ID_kpi,382,1,'ESS_KPISupObjectives.aspx','menu/process.png',1,'Employee KPI Objectives')
	end		
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'KPI Apparisal Form' And Form_ID > 7000 and Form_ID < 7500)
	begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	values (@Menu_id1,'KPI Apparisal Form',@Temp_Form_ID_kpi,382,1,'Ess_KPI_PMS_AppraisalForm.aspx','menu/process.png',1,'KPI Appraisal Form')
	end	
else--added on 6 July 2015 sneha - to correct spelling
	begin
		update [T0000_DEFAULT_FORM] set alias = 'KPI Appraisal Form' where Form_name = 'KPI Apparisal Form'
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee KPI Apparisal Form' And Form_ID > 7000 and Form_ID < 7500)
	begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	values (@Menu_id1,'Employee KPI Apparisal Form',@Temp_Form_ID_kpi,382,1,'Ess_Sup_KPIPMS_AppraisalForm.aspx','menu/process.png',1,'Employee KPI Apparisal Form')
	end	
else--added on 6 July 2015 sneha - to correct spelling
	begin
		update [T0000_DEFAULT_FORM] set alias = 'Employee KPI Appraisal Form' where Form_name = 'Employee KPI Appraisal Form'
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'KPIPMS Final Evaluation' And Form_ID > 7000 and Form_ID < 7500)
	begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	values (@Menu_id1,'KPIPMS Final Evaluation',@Temp_Form_ID_kpi,382,1,'ESS_KPIFinalForm.aspx','menu/process.png',1,'KPIPMS Final Evaluation')
	end	 
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee KPIPMS Final Evaluation' And Form_ID > 7000 and Form_ID < 7500)
	begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	values (@Menu_id1,'Employee KPIPMS Final Evaluation',@Temp_Form_ID_kpi,382,1,'Ess_SupKPIFinalForm.aspx','menu/process.png',1,'Employee KPIPMS Final Evaluation')
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_333' And Form_ID > 9000 and Form_ID < 10000)
	begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 10000
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	values (@Menu_id1,'TD_Home_ESS_333',9291,1297,1,'','',1,'Appraisal Alert')
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_334' And Form_ID > 9000 and Form_ID < 10000)
	begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 10000
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	values (@Menu_id1,'TD_Home_ESS_334',9291,1297,1,'','',1,'Approve KPI Rating')
	end	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_335' And Form_ID > 9000 and Form_ID < 10000)
	begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 10000
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	values (@Menu_id1,'TD_Home_ESS_335',9291,1297,1,'','',1,'Employee Reviewed Alert')
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_336' And Form_ID > 9000 and Form_ID < 10000)
	begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 10000
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	values (@Menu_id1,'TD_Home_ESS_336',9291,1297,1,'','',1,'Employee Approved Alert')
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_337' And Form_ID > 9000 and Form_ID < 10000)
	begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 10000
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	values (@Menu_id1,'TD_Home_ESS_337',9291,1297,1,'','',1,'KPI For Review')
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_338' And Form_ID > 9000 and Form_ID < 10000)
	begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 10000
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	values (@Menu_id1,'TD_Home_ESS_338',9291,1297,1,'','',1,'KPI Objective')
	end	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_339' And Form_ID > 9000 and Form_ID < 10000)
	begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 10000
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	values (@Menu_id1,'TD_Home_ESS_339',9291,1297,1,'','',1,'KPI Objective NewEmployee')
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_340' And Form_ID > 9000 and Form_ID < 10000)
	begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 10000
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	values (@Menu_id1,'TD_Home_ESS_340',9291,1297,1,'','',1,'KPI Objective Notify NewEmployee')
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_344' And Form_ID > 9000 and Form_ID < 10000)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 10000
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'TD_Home_ESS_344',9291,1297,1,'','',1,'KPI Appraisal For Review')
	end	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_346' And Form_ID > 9000 and Form_ID < 10000)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 10000
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'TD_Home_ESS_346',9291,1297,1,'','',1,'KPI Objective for Employee Review')
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_347' And Form_ID > 9000 and Form_ID < 10000)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 10000
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'TD_Home_ESS_347',9291,1297,1,'','',1,'KPI Objective Reviewed by Employee ')
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_348' And Form_ID > 9000 and Form_ID < 10000)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 10000
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'TD_Home_ESS_348',9291,1297,1,'','',1,'KPI Objective Approved by Employee ')
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_349' And Form_ID > 9000 and Form_ID < 10000)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 10000
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'TD_Home_ESS_349',9291,1297,1,'','',1,'KPI Objective for Superior Review')
	end
---------------25 dec 2014 kpi sneha end---------------
--Added by Gadriwala Muslim 11102014 - Start

If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Interest Subsidy Approval' and Form_ID>6000 and Form_ID<6500)
	begin
		Set @temp_menu_id_Increment  = 0
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6499
		set @temp_menu_id_Increment = @Menu_id1

		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Interest Subsidy Approval',6071, 108, 1,'Interest_subsidy_Approve_Admin.aspx',@Loan_Claim_Img,1,'Interest Subsidy Approval')
		
		--UPDATE T0000_DEFAULT_FORM SET Under_Form_ID= @temp_menu_id_Increment WHERE Form_Name in ('Employee Weekoff','Half Weekoff','Weekoff Approval') and Form_ID > 6000 and Form_ID < 6500
	end
--Added By Gadriwala Muslim 08012014 - End
--Added by Nilesh Patel 16122014 - Start
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Change Request Application' And Form_ID > 7000 and Form_ID < 7500) 
	begin 
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(@Menu_id1, N'Change Request Application', 7001, 306, 1, 'Change_Request.aspx',@Employee_Img, 1, N'Change Request Application')
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Change Request Approval' And Form_ID > 7000 and Form_ID < 7500) 
	begin 
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(@Menu_id1, N'Change Request Approval', 7001, 306, 1, 'Change_Request_Approval.aspx',@Employee_Img, 1, N'Change Request Approval')
	end

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Admin Change Request Approval' And Form_ID > 6000 and Form_ID < 6499)
	begin    
		select @Temp_Form_ID1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Temp_Form_ID1,'Admin Change Request Approval',6070 ,124,1,'Change_Request_Admin_Approval.aspx',@Loan_Claim_Img,1,'Admin Change Request Approval')
	end
--Added by Nilesh Patel 16122014 - Start
---------------26 dec 2014 hrms dashboard sneha-------------------
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'HR Home Page Rights' And Form_ID > 9000 and Form_ID < 10000)
	begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 10000
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	values (@Menu_id1,'HR Home Page Rights',-1,2000,1,'','',1,'HR Home Page Rights')
	end
	
declare @hrhomeid  as Numeric(18,0)
select @hrhomeid = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'HR Home Page Rights' And Form_ID > 9000 and Form_ID < 10000

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_HR_2' And Form_ID > 9000 and Form_ID < 10000)
	begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 10000
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	values (@Menu_id1,'TD_Home_HR_2',@hrhomeid,2001,1,'','',1,'Appraisal Alert')
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_HR_3' And Form_ID > 9000 and Form_ID < 10000)
	begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 10000
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	values (@Menu_id1,'TD_Home_HR_3',@hrhomeid,2001,2,'','',1,'Appraisal Manager Approve')
	end

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_HR_8' And Form_ID > 9000 and Form_ID < 10000)
	begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 10000
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	values (@Menu_id1,'TD_Home_HR_8',@hrhomeid,2001,2,'','',1,'KPI Objectives Approved Manager')
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_HR_12' And Form_ID > 9000 and Form_ID < 10000)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 10000
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'TD_Home_HR_12',@hrhomeid,2001,5,'','',1,'KPI Objectives Reviewed by Employee')
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_HR_13' And Form_ID > 9000 and Form_ID < 10000)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 10000
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'TD_Home_HR_13',@hrhomeid,2001,5,'','',1,'KPI Objectives Approved by Employee')
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_HR_14' And Form_ID > 9000 and Form_ID < 10000)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 10000
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'TD_Home_HR_14',@hrhomeid,2001,5,'','',1,'Appraisal Reviewed by Employee')
	end
else--added on 6 July 2015 sneha - to correct spelling
	begin
		update [T0000_DEFAULT_FORM] set alias = 'Appraisal Reviewed by Employee' where Form_name = 'TD_Home_HR_14'
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_HR_15' And Form_ID > 9000 and Form_ID < 10000)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 10000
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'TD_Home_HR_15',@hrhomeid,2001,5,'','',1,'Appraisal Approved by Employee')
	end
else--added on 6 July 2015 sneha - to correct spelling
	begin
		update [T0000_DEFAULT_FORM] set alias = 'Appraisal Reviewed by Employee' where Form_name = 'TD_Home_HR_15'
	end
	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_HR_7' And Form_ID > 9000 and Form_ID < 10000)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 10000
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'TD_Home_HR_7',@hrhomeid,2001,2,'','',1,'Resume Screened Successfully')
	end

--Added by Jaina 1-09-2016 Start
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_HR_20' And Form_ID > 9000 and Form_ID < 10000)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 10000
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'TD_Home_HR_20',@hrhomeid,2001,3,'','',1,'Candidates Joining In Next 7 Days')
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_HR_21' And Form_ID > 9000 and Form_ID < 10000)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 10000
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'TD_Home_HR_21',@hrhomeid,2001,4,'','',1,'Candidates Joining Today/Tomorrow')
	end
--Added by Jaina 1-09-2016 End

--added on 16 Mar 2016 start	
select @id_hrmsreport =  Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'HRMS Reports Member#'
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee KPA Score Member#')  
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7500     and Form_ID < 7999  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name])
		values (@Menu_id1,'Employee KPA Score Member#',@id_hrmsreport,348,1,'~/Report_Payroll.aspx?Id=9031', NULL, 1, N'Employee KPA Score Member#','HRMS')
	end
Else
	begin 
		update [T0000_DEFAULT_FORM]
		set  [Under_Form_ID] =@id_hrmsreport,
		form_url='~/Report_Payroll.aspx?Id=9031'
		where form_name = 'Employee KPA Score Member#' and Form_ID > 7500  and Form_ID < 7999 
	End	
	--added on 16 Mar 2016 end	
	
--------------------------- Ess Mobile Application Form Id from 10000 to 10200  Add by Prakash Patel 26092014 ------------------------------------------------------------------- 
 
		if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Mobile Application' AND Form_ID > 9800 AND Form_ID < 9999)
			BEGIN     
				select @Menu_id1 = isnull(MAX(Form_id),9800) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9800 and Form_ID < 9999
				 
				set @Temp_Form_ID1   = @Menu_id1
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],  
				[Form_Image_url],[Is_Active_For_menu],[Alias])values  
				(@Menu_id1,N'Mobile Application',-1, 800, 1, NULL, NULL,1,N'Mobile Application') 
				 
			END     
		if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Mobile Dashboard' AND Form_ID > 9800 AND Form_ID < 9999)   
			BEGIN
				select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9800 and Form_ID < 9999
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],  
				[Form_Image_url],[Is_Active_For_menu],[Alias])values  
				(@Menu_id1,N'Mobile Dashboard',@Temp_Form_ID1, 802, 1, N'New_Dashboard.aspx', NULL,1,N'Mobile Dashboard')    
			END     
		if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Mobile Employee Details' AND Form_ID > 9800 AND Form_ID < 9999)
			BEGIN 
				select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9800 and Form_ID < 9999
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],  
				[Form_Image_url],[Is_Active_For_menu],[Alias])values  
				(@Menu_id1,N'Mobile Employee Details',@Temp_Form_ID1, 803, 1, N'Employee_Details.aspx', NULL,1,N'Mobile Employee Details')    
			END
		if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Mobile Attendance' AND Form_ID > 9800 AND Form_ID < 9999)    
			BEGIN
				select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9800 and Form_ID < 9999
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],  
				[Form_Image_url],[Is_Active_For_menu],[Alias])values  
				(@Menu_id1,N'Mobile Attendance',@Temp_Form_ID1, 809, 1, N'Attendance.aspx', NULL,1,N'Mobile Attendance')   
			END		  
		if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Mobile Leave' AND Form_ID > 9800 AND Form_ID < 9999)
			BEGIN
				select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9800 and Form_ID < 9999
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],  
				[Form_Image_url],[Is_Active_For_menu],[Alias])values  
				(@Menu_id1,N'Mobile Leave',@Temp_Form_ID1, 809, 1, N'Leave.aspx', NULL,1,N'Mobile Leave')    
			END    
		if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Mobile Approval' AND Form_ID > 9800 AND Form_ID < 9999)
			BEGIN
				select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9800 and Form_ID < 9999
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],  
				[Form_Image_url],[Is_Active_For_menu],[Alias])values  
				(@Menu_id1,N'Mobile Approval',@Temp_Form_ID1, 808, 1, N'Leave_Approve_View.aspx', NULL,1,N'Mobile Approval')  
			END    
		
		--if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Mobile Approval' AND Form_ID > 9800 AND Form_ID < 9999)
		--	BEGIN
		--		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9800 and Form_ID < 9999
		--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],  
		--		[Form_Image_url],[Is_Active_For_menu],[Alias])values  
		--		(@Menu_id1,N'Mobile Approval',@Temp_Form_ID1, 808, 1, N'Leave_Approve_View.aspx', NULL,1,N'Mobile Approval')  
		--	END    
		
		DECLARE @MOBUNDERAPP  NUMERIC(18,0) = 0
		---commented by prapti #22939  11112022
		SELECT @MOBUNDERAPP = FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Mobile Approval'
		--IF @MOBUNDERAPP > 0
		--BEGIN
		--	IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  FORM_NAME = 'Mobile Change Request Approval' 
		--	AND FORM_ID > 9800 AND FORM_ID < 9999)
		--	BEGIN
		--		SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE FORM_ID > 9800 AND FORM_ID < 9999
		--		INSERT INTO [DBO].[T0000_DEFAULT_FORM]([FORM_ID],[FORM_NAME],[UNDER_FORM_ID],[SORT_ID],[FORM_TYPE],[FORM_URL],  
		--		[FORM_IMAGE_URL],[IS_ACTIVE_FOR_MENU],[ALIAS])VALUES  
		--		(@MENU_ID1,N'Mobile Change Request Approval',@MOBUNDERAPP, 812, 1, N'Andriod', NULL,1,N'Mobile Change Request Approval')  
		--	END    
		--END
		
		IF @MOBUNDERAPP > 0
		BEGIN
			IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  FORM_NAME = 'Mobile Exit Approval' 
			AND FORM_ID > 9800 AND FORM_ID < 9999)
			BEGIN
				SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE FORM_ID > 9800 AND FORM_ID < 9999
				INSERT INTO [DBO].[T0000_DEFAULT_FORM]([FORM_ID],[FORM_NAME],[UNDER_FORM_ID],[SORT_ID],[FORM_TYPE],[FORM_URL],  
				[FORM_IMAGE_URL],[IS_ACTIVE_FOR_MENU],[ALIAS])VALUES  
				(@MENU_ID1,N'Mobile Exit Approval',@MOBUNDERAPP, 812, 1, N'Andriod', NULL,1,N'Mobile Exit Approval')  
			END    
		END

		IF @MOBUNDERAPP > 0 --added by Prapti 07102022
		BEGIN
			IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  FORM_NAME = 'Mobile Travel Approval' 
			AND FORM_ID > 9800 AND FORM_ID < 9999)
			BEGIN
				SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE FORM_ID > 9800 AND FORM_ID < 9999
				INSERT INTO [DBO].[T0000_DEFAULT_FORM]([FORM_ID],[FORM_NAME],[UNDER_FORM_ID],[SORT_ID],[FORM_TYPE],[FORM_URL],  
				[FORM_IMAGE_URL],[IS_ACTIVE_FOR_MENU],[ALIAS])VALUES  
				(@MENU_ID1,N'Mobile Travel Approval',@MOBUNDERAPP, 812, 1, N'Andriod', NULL,1,N'Mobile Travel Approval')  
			END    
		END

		IF @MOBUNDERAPP > 0 --added by Prapti 07102022
		BEGIN
			IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  FORM_NAME = 'Mobile Claim Approval' 
			AND FORM_ID > 9800 AND FORM_ID < 9999)
			BEGIN
				SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE FORM_ID > 9800 AND FORM_ID < 9999
				INSERT INTO [DBO].[T0000_DEFAULT_FORM]([FORM_ID],[FORM_NAME],[UNDER_FORM_ID],[SORT_ID],[FORM_TYPE],[FORM_URL],  
				[FORM_IMAGE_URL],[IS_ACTIVE_FOR_MENU],[ALIAS])VALUES  
				(@MENU_ID1,N'Mobile Claim Approval',@MOBUNDERAPP, 812, 1, N'Andriod', NULL,1,N'Mobile Claim Approval')  
			END    
		END

		IF @MOBUNDERAPP > 0
		BEGIN
			IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  FORM_NAME = 'Mobile Ticket Approval' 
			AND FORM_ID > 9800 AND FORM_ID < 9999)
			BEGIN
				SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE FORM_ID > 9800 AND FORM_ID < 9999
				INSERT INTO [DBO].[T0000_DEFAULT_FORM]([FORM_ID],[FORM_NAME],[UNDER_FORM_ID],[SORT_ID],[FORM_TYPE],[FORM_URL],  
				[FORM_IMAGE_URL],[IS_ACTIVE_FOR_MENU],[ALIAS])VALUES  
				(@MENU_ID1,N'Mobile Ticket Approval',@MOBUNDERAPP, 812, 1, N'Andriod', NULL,1,N'Mobile Ticket Approval')  
			END    
		END

		IF @MOBUNDERAPP > 0
		BEGIN
			IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  FORM_NAME = 'Mobile Comp-Off Approval' 
			AND FORM_ID > 9800 AND FORM_ID < 9999)
			BEGIN
				SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE FORM_ID > 9800 AND FORM_ID < 9999
				INSERT INTO [DBO].[T0000_DEFAULT_FORM]([FORM_ID],[FORM_NAME],[UNDER_FORM_ID],[SORT_ID],[FORM_TYPE],[FORM_URL],  
				[FORM_IMAGE_URL],[IS_ACTIVE_FOR_MENU],[ALIAS])VALUES  
				(@MENU_ID1,N'Mobile Comp-Off Approval',@MOBUNDERAPP, 812, 1, N'Andriod', NULL,1,N'Mobile Comp-Off Approval')  
			END    
		END

		IF @MOBUNDERAPP > 0
		BEGIN
			IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  FORM_NAME = 'Mobile Leave Cancellation Approval' 
			AND FORM_ID > 9800 AND FORM_ID < 9999)
			BEGIN
				SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE FORM_ID > 9800 AND FORM_ID < 9999
				INSERT INTO [DBO].[T0000_DEFAULT_FORM]([FORM_ID],[FORM_NAME],[UNDER_FORM_ID],[SORT_ID],[FORM_TYPE],[FORM_URL],  
				[FORM_IMAGE_URL],[IS_ACTIVE_FOR_MENU],[ALIAS])VALUES  
				(@MENU_ID1,N'Mobile Leave Cancellation Approval',@MOBUNDERAPP, 812, 1, N'Andriod', NULL,1,N'Mobile Leave Cancellation Approval')  
			END    
		END

		IF @MOBUNDERAPP > 0
		BEGIN
			IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  FORM_NAME = 'Mobile Attendance Regularization Approval' 
			AND FORM_ID > 9800 AND FORM_ID < 9999)
			BEGIN
				SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE FORM_ID > 9800 AND FORM_ID < 9999
				INSERT INTO [DBO].[T0000_DEFAULT_FORM]([FORM_ID],[FORM_NAME],[UNDER_FORM_ID],[SORT_ID],[FORM_TYPE],[FORM_URL],  
				[FORM_IMAGE_URL],[IS_ACTIVE_FOR_MENU],[ALIAS])VALUES  
				(@MENU_ID1,N'Mobile Attendance Regularization Approval',@MOBUNDERAPP, 812, 1, N'Andriod', NULL,1,N'Mobile Attendance Regularization Approval')  
			END    
		END

		IF @MOBUNDERAPP > 0
		BEGIN
			IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  FORM_NAME = 'Mobile Leave Approval' 
			AND FORM_ID > 9800 AND FORM_ID < 9999)
			BEGIN
				SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE FORM_ID > 9800 AND FORM_ID < 9999
				INSERT INTO [DBO].[T0000_DEFAULT_FORM]([FORM_ID],[FORM_NAME],[UNDER_FORM_ID],[SORT_ID],[FORM_TYPE],[FORM_URL],  
				[FORM_IMAGE_URL],[IS_ACTIVE_FOR_MENU],[ALIAS])VALUES  
				(@MENU_ID1,N'Mobile Leave Approval',@MOBUNDERAPP, 812, 1, N'Andriod', NULL,1,N'Mobile Leave Approval')  
			END    
		END

		IF not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Mobile Change Request' AND Form_ID > 9800 AND Form_ID < 9999)
			BEGIN
				select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9800 and Form_ID < 9999
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],  
				[Form_Image_url],[Is_Active_For_menu],[Alias])values  
				(@Menu_id1,N'Mobile Change Request',@Temp_Form_ID1, 811, 1, N'Android', NULL,1,N'Mobile Change Request')    
			END

		 


		if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Mobile Salary Detail' AND Form_ID > 9800 AND Form_ID < 9999)
			BEGIN
				select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9800 and Form_ID < 9999
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],  
				[Form_Image_url],[Is_Active_For_menu],[Alias])values  
				(@Menu_id1,N'Mobile Salary Detail',@Temp_Form_ID1, 809, 1, N'Salary.aspx', NULL,1,N'Mobile Salary Detail')  
			END 
			
		if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Mobile Loan Detail' AND Form_ID > 9800 AND Form_ID < 9999)
			BEGIN
				select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9800 and Form_ID < 9999
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],  
				[Form_Image_url],[Is_Active_For_menu],[Alias])values  
				(@Menu_id1,N'Mobile Loan Detail',@Temp_Form_ID1, 810, 1, N'Loan_Detail.aspx', NULL,1,N'Mobile Loan Detail')    
			END  
		if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Mobile Claim Application' AND Form_ID > 9800 AND Form_ID < 9999)
			BEGIN
				select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9800 and Form_ID < 9999
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],  
				[Form_Image_url],[Is_Active_For_menu],[Alias])values  
				(@Menu_id1,N'Mobile Claim Application',@Temp_Form_ID1, 810, 1, N'Claim_Application.aspx', NULL,1,N'Mobile Claim Detail')    
			END
		if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK)  where  Form_name = 'Mobile Travel Application' AND Form_ID > 9800 AND Form_ID < 9999)
			BEGIN
				select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9800 and Form_ID < 9999
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],  
				[Form_Image_url],[Is_Active_For_menu],[Alias])values  
				(@Menu_id1,N'Mobile Travel Application',@Temp_Form_ID1, 810, 1, N'Travel_Application.aspx', NULL,1,N'Mobile Travel Detail')    
			END
		--if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Mobile Training' AND Form_ID > 9800 AND Form_ID < 9999)
		--	BEGIN
		--		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9800 and Form_ID < 9999
		--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],  
		--		[Form_Image_url],[Is_Active_For_menu],[Alias])values  
		--		(@Menu_id1,N'Mobile Training',@Temp_Form_ID1, 810, 1, N'Training.aspx', NULL,1,N'Mobile Training')    
		--	END
		if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Mobile Change Password' AND Form_ID > 9800 AND Form_ID < 9999)
			BEGIN
				select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9800 and Form_ID < 9999
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],  
				[Form_Image_url],[Is_Active_For_menu],[Alias])values  
				(@Menu_id1,N'Mobile Change Password',@Temp_Form_ID1, 810, 1, N'ChangePassword.aspx', NULL,1,N'Mobile Change Password')    
			END
		if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Mobile Event Celebration' AND Form_ID > 9800 AND Form_ID < 9999)
			BEGIN
				select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9800 and Form_ID < 9999
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],  
				[Form_Image_url],[Is_Active_For_menu],[Alias])values  
				(@Menu_id1,N'Mobile Event Celebration',@Temp_Form_ID1, 810, 1, N'BirthdayNotification.aspx', NULL,1,N'Mobile Event & Celebration')    
			END
		--if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Mobile Help Desk' AND Form_ID > 9800 AND Form_ID < 9999)
		--	BEGIN
		--		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9800 and Form_ID < 9999
		--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],  
		--		[Form_Image_url],[Is_Active_For_menu],[Alias])values  
		--		(@Menu_id1,N'Mobile Help Desk',@Temp_Form_ID1, 810, 1, N'Attendance_Regularization.aspx', NULL,1,N'Mobile KR Care')    
		--	END
		if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Mobile Document' AND Form_ID > 9800 AND Form_ID < 9999)
			BEGIN
				select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9800 and Form_ID < 9999
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],  
				[Form_Image_url],[Is_Active_For_menu],[Alias])values  
				(@Menu_id1,N'Mobile Document',@Temp_Form_ID1, 810, 1, N'Other.aspx', NULL,1,N'Mobile Document')
			ENd
		if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Mobile CompOff Application' AND Form_ID > 9800 AND Form_ID < 9999)
			BEGIN
				select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9800 and Form_ID < 9999
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],  
				[Form_Image_url],[Is_Active_For_menu],[Alias])values  
				(@Menu_id1,N'Mobile CompOff Application',@Temp_Form_ID1, 810, 1, N'Compoff.aspx', NULL,1,N'Mobile CompOff Application')
			ENd
		if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Mobile Ticket Application' AND Form_ID > 9800 AND Form_ID < 9999)
			BEGIN
				select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9800 and Form_ID < 9999
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],  
				[Form_Image_url],[Is_Active_For_menu],[Alias])values  
				(@Menu_id1,N'Mobile Ticket Application',@Temp_Form_ID1, 810, 1, N'Android', NULL,1,N'Mobile Ticket Application')    
			END
		if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Mobile Survey' AND Form_ID > 9800 AND Form_ID < 9999)
			BEGIN
				select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9800 and Form_ID < 9999
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],  
				[Form_Image_url],[Is_Active_For_menu],[Alias])values  
				(@Menu_id1,N'Mobile Survey',@Temp_Form_ID1, 810, 1, N'Android', NULL,1,N'Mobile Survey')    
			END

		if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Mobile Attendance Regularization' AND Form_ID > 9800 AND Form_ID < 9999)
			BEGIN
				select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9800 and Form_ID < 9999
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],  
				[Form_Image_url],[Is_Active_For_menu],[Alias])values  
				(@Menu_id1,N'Mobile Attendance Regularization',@Temp_Form_ID1, 810, 1, N'Attendance_Regularization.aspx', NULL,1,N'Mobile Attendance Regularization')    
			END

		--if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Mobile Mood Tracker' AND Form_ID > 9800 AND Form_ID < 9999)
		--	BEGIN
		--		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9800 and Form_ID < 9999
		--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],  
		--		[Form_Image_url],[Is_Active_For_menu],[Alias])values  
		--		(@Menu_id1,N'Mobile Mood Tracker',@Temp_Form_ID1, 811, 1, N'Android', NULL,1,N'Mobile Mood Tracker')    
		--	END

			--	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Mobile Weather' AND Form_ID > 9800 AND Form_ID < 9999)
			--BEGIN
			--	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9800 and Form_ID < 9999
			--	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],  
			--	[Form_Image_url],[Is_Active_For_menu],[Alias])values  
			--	(@Menu_id1,N'Mobile Weather',@Temp_Form_ID1, 811, 1, N'Android', NULL,1,N'Mobile Weather')    
			--END

			--	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Mobile Step Tracker' AND Form_ID > 9800 AND Form_ID < 9999)
			--BEGIN
			--	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9800 and Form_ID < 9999
			--	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],  
			--	[Form_Image_url],[Is_Active_For_menu],[Alias])values  
			--	(@Menu_id1,N'Mobile Step Tracker',@Temp_Form_ID1, 811, 1, N'Android', NULL,1,N'Mobile Step Tracker')    
			--END

			if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Mobile Clocking' AND Form_ID > 9800 AND Form_ID < 9999)
			BEGIN
				select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9800 and Form_ID < 9999
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],  
				[Form_Image_url],[Is_Active_For_menu],[Alias])values  
				(@Menu_id1,N'Mobile Clocking',@Temp_Form_ID1, 811, 1, N'Android', NULL,1,N'Mobile Clocking')    
			END

			-- Start Added by Niraj for Mobile QR Code (27042022)
			if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Mobile QR Code Scanner' AND Form_ID > 9800 AND Form_ID < 9999)
			BEGIN
				select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9800 and Form_ID < 9999
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],  
				[Form_Image_url],[Is_Active_For_menu],[Alias])values  
				(@Menu_id1,N'Mobile QR Code Scanner',@Temp_Form_ID1, 811, 1, N'Android', NULL,1,N'Mobile QR Code Scanner')    
			END
			-- End Added by Niraj for Mobile QR Code (27042022)

			if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Mobile My Team' AND Form_ID > 9800 AND Form_ID < 9999)
			BEGIN
				select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9800 and Form_ID < 9999
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],  
				[Form_Image_url],[Is_Active_For_menu],[Alias])values  
				(@Menu_id1,N'Mobile My Team',@Temp_Form_ID1, 811, 1, N'Android', NULL,1,N'Mobile My Team')    
			END

			if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Mobile Exit Application' AND Form_ID > 9800 AND Form_ID < 9999)
			BEGIN
				select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9800 and Form_ID < 9999
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],  
				[Form_Image_url],[Is_Active_For_menu],[Alias])values  
				(@Menu_id1,N'Mobile Exit Application',@Temp_Form_ID1, 811, 1, N'Android', NULL,1,N'Mobile Exit Application')    
			END

			if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Mobile Holiday' AND Form_ID > 9800 AND Form_ID < 9999)
			BEGIN
				select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9800 and Form_ID < 9999
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],  
				[Form_Image_url],[Is_Active_For_menu],[Alias])values  
				(@Menu_id1,N'Mobile Holiday',@Temp_Form_ID1, 811, 1, N'Android', NULL,1,N'Mobile Holiday')    
			END
			----Added by yogesh on 16062023
			--if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Canteen Application' AND Form_ID > 9800 AND Form_ID < 9999)
			--BEGIN
			--	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9800 and Form_ID < 9999
			--	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],  
			--	[Form_Image_url],[Is_Active_For_menu],[Alias])values  
			--	(@Menu_id1,N'Canteen Application',@Temp_Form_ID1, 809, 1, N'Android', NULL,1,N'Mobile Canteen Application')  
			--END


			--Added by ronakk 04032022
			--As discussion with chintan prajapti added this page for privilege
					--Medical Treatment Application

			IF not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Mobile Medical Treatment Application' AND Form_ID > 9800 AND Form_ID < 9999)
			BEGIN
				select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9800 and Form_ID < 9999
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],  
				[Form_Image_url],[Is_Active_For_menu],[Alias])values  
				(@Menu_id1,N'Mobile Medical Treatment Application',@Temp_Form_ID1, 811, 1, N'Android', NULL,1,N'Mobile Medical Treatment Application')    
			END

			IF not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Mobile Gallery' AND Form_ID > 9800 AND Form_ID < 9999)
			BEGIN
				select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9800 and Form_ID < 9999
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],  
				[Form_Image_url],[Is_Active_For_menu],[Alias])values  
				(@Menu_id1,N'Mobile Gallery',@Temp_Form_ID1, 811, 1, N'Android', NULL,1,N'Mobile Gallery')    
			END

			--Added by Prapti 18072022
			IF not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Mobile Grievance' AND Form_ID > 9800 AND Form_ID < 9999)
			BEGIN
				select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9800 and Form_ID < 9999
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],  
				[Form_Image_url],[Is_Active_For_menu],[Alias])values  
				(@Menu_id1,N'Mobile Grievance',@Temp_Form_ID1, 811, 1, N'Android', NULL,1,N'Mobile Grievance')    
			END
			--End by Prapti 18072022
			--start by yogesh on 17062023
			IF not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Mobile Canteen' AND Form_ID > 9800 AND Form_ID < 9999)
			BEGIN
				select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9800 and Form_ID < 9999
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],  
				[Form_Image_url],[Is_Active_For_menu],[Alias])values  
				(@Menu_id1,N'Mobile Canteen',@Temp_Form_ID1, 811, 1, N'Android', NULL,1,N'Mobile Canteen')    
			END
			--End by yogesh on 17062023
			--End by ronak 04032022
			
--------------------------------------------------------------------------------------------------------------------------------------------------------------
	
		--Added by nilesh patel on 20022015 -Start For Custmize report rights wise
		--DECLARE @Cust_Report_Count Numeric(5,0)
		--SELECT  @Cust_Report_Count = COUNT(*) FROM T0000_DEFAULT_FORM where Under_Form_ID = 6714

		--if @Cust_Report_Count = 0
		--	Begin
		/*
				Declare @CustomizeReportFormID INT
				SELECT @CustomizeReportFormID = Form_ID FROM T0000_DEFAULT_FORM  WHERE Form_Name='Customize Report' And Page_Flag='AR'
				if not exists (select Form_id from T0000_DEFAULT_FORM where  Form_name = 'Employee Customize' And Page_Flag='AR')
					begin    
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM 
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Employee Customize',@CustomizeReportFormID ,172,1,'',NULL,1,N'Employee Customize')
					end
				if not exists (select Form_id from T0000_DEFAULT_FORM where  Form_name = 'Leave Customize' And Page_Flag='AR')
					begin    
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Leave Customize',@CustomizeReportFormID ,172,1,'',NULL,1,N'Leave Customize')
					end
				if not exists (select Form_id from T0000_DEFAULT_FORM where  Form_name = 'Salary Customize' And Page_Flag='AR')
					begin    
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Salary Customize',@CustomizeReportFormID ,172,1,'',NULL,1,N'Salary Customize')
					end
				if not exists (select Form_id from T0000_DEFAULT_FORM where  Form_name = 'Tax Customize' And Page_Flag='AR')
					begin    
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Tax Customize',@CustomizeReportFormID ,172,1,'',NULL,1,N'Tax Customize')
					end
				if not exists (select Form_id from T0000_DEFAULT_FORM where  Form_name = 'Attendance Customize' And Page_Flag='AR')
					begin    
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Attendance Customize',@CustomizeReportFormID ,172,1,'',NULL,1,N'Attendance Customize')
					end
				
				if  not exists (select Form_id from T0000_DEFAULT_FORM where  Form_name = 'Asset Customize' And Page_Flag='AR')  --Mukti 05102015
					begin  
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Asset Customize',@CustomizeReportFormID ,172,1,'',NULL,1,N'Asset Customize')
					end
				if  not exists (select Form_id from T0000_DEFAULT_FORM where  Form_name = 'Claim Customize' And Page_Flag='AR')  --Mukti 05102015
					begin  
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Claim Customize',@CustomizeReportFormID ,172,1,'',NULL,1,N'Claim Customize')
					end
				--Added By Ramiz on 29/10/2018--
				IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WHERE Form_name = 'PF_ESIC Customize' And Page_Flag='AR')
					BEGIN    
						SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias] , [Page_Flag])
						VALUES (@Menu_id1,N'PF_ESIC Customize',@CustomizeReportFormID ,172,1,'',NULL,1,N'PF_ESIC Customize' , 'AR')
					END	
				if not exists (select Form_id from T0000_DEFAULT_FORM where  Form_name = 'Others Customize' And Page_Flag='AR')
					begin    
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Others Customize',@CustomizeReportFormID ,172,1,'',NULL,1,N'Others Customize')
					end
				IF NOT EXISTS(SELECT Form_Id From T0050_PRIVILEGE_DETAILS where Form_id IN(Select T0000_DEFAULT_FORM.Form_ID From T0000_DEFAULT_FORM where Under_Form_ID = @CustomizeReportFormID))
					BEGIN 
					
					Declare @Privilage_ID_Report Numeric(5,0)
					Declare @Cmp_ID_Report Numeric(5,0)
					Declare @Form_Id_Report Numeric(10,0)
					DECLARE Report_rights_Cursor CURSOR FOR SELECT Privilage_ID,Cmp_Id,Form_Id From T0050_PRIVILEGE_DETAILS where Form_Id = @CustomizeReportFormID and (Is_View = 1 or Is_Edit = 1 or Is_Save = 1 or Is_Delete = 1) ORDER BY Cmp_Id 
						OPEN Report_rights_Cursor 
							fetch next from Report_rights_Cursor into @Privilage_ID_Report,@Cmp_ID_Report,@Form_Id_Report
							  while @@fetch_status = 0
								Begin
										
										Declare @Trans_Id_1 Numeric(18,0) = 0
										select @Trans_Id_1 = Isnull(max(Trans_Id),0) + 1 	From T0050_PRIVILEGE_DETAILS
										
										--Select @Trans_Id_Report, @Privilage_ID_Report,@Cmp_ID_Report,Form_ID,1,1,1,1,0 from T0000_DEFAULT_FORM where Under_Form_ID = @CustomizeReportFormID
										
										INSERT INTO T0050_PRIVILEGE_DETAILS
										  (Trans_Id, Privilage_ID, Cmp_Id, Form_Id, Is_View, Is_Edit, Is_Save, Is_Delete, Is_Print)
										(Select  (@Trans_Id_1 + ROW_NUMBER() OVER ( ORDER BY Form_ID )) as row_id,@Privilage_ID_Report,@Cmp_ID_Report,Form_ID,1,1,1,1,0 from T0000_DEFAULT_FORM where Under_Form_ID = @CustomizeReportFormID)
														 
										fetch next from Report_rights_Cursor into @Privilage_ID_Report,@Cmp_ID_Report,@Form_Id_Report
								End
						 Close Report_rights_Cursor 
						 deallocate Report_rights_Cursor
						 
						 
					End 
					
					UPDATE T0000_DEFAULT_FORM Set Sort_Id_Check = 1 where Form_ID = @CustomizeReportFormID
					UPDATE T0000_DEFAULT_FORM Set Sort_Id_Check = 2 where Under_Form_ID = @CustomizeReportFormID 
			*/
			--Added by nilesh patel on 20022015 -End For Custmize report rights wise
			
			/*Following Code Commented by Nimesh on 05-Mar-2019
				And moved in new Stored Procedure P0000_DEFAULT_FORM_IMPORT_DATA
				And executed at the end of the stored procedure
			*/
			/*
				-- Import rights added by nilesh patel on 20022015 
				DECLARE @Import_Count Numeric(5,0)

				SELECT  @Import_Count = COUNT(*) FROM T0000_DEFAULT_FORM where Under_Form_ID = 6007

				
					
				DECLARE @Sort_id_Check as numeric(18,0)--= 0
				SET  @Sort_id_Check  = 0   --changed jimit 18042016
				DECLARE @Under_form_Id as numeric
				SELECT @Under_form_Id = form_Id from T0000_DEFAULT_FORM WHERE Form_Name = 'Imports Data' 


				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Branch Import')
					BEGIN
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Branch Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Branch Import',@Under_form_Id,7,1,NULL,NULL,1,N'Branch Import')
					END
				Set @Sort_id_Check = @Sort_id_Check + 1	
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Grade Import')
					BEGIN
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Grade Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Grade Import',@Under_form_Id,7,1,NULL,NULL,1,N'Grade Import')
					END	
				Set @Sort_id_Check = @Sort_id_Check + 1					
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Department Import')
					BEGIN
						
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Department Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Department Import',@Under_form_Id,7,1,NULL,NULL,1,N'Department Import')
					END		
				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Designation Import')
					BEGIN
						
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Designation Import' AND UNDER_FORM_ID = @Under_form_Id
					END	
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Designation Import',@Under_form_Id,7,1,NULL,NULL,1,N'Designation Import')
					END
				Set @Sort_id_Check = @Sort_id_Check + 1		
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Bank Import')
					BEGIN
						
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Bank Import' AND UNDER_FORM_ID = @Under_form_Id
					END	
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Bank Import',@Under_form_Id,7,1,NULL,NULL,1,N'Bank Import')
					END
				Set @Sort_id_Check = @Sort_id_Check + 1		
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'City Master Import')
					BEGIN
						
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'City Master Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'City Master Import',@Under_form_Id,7,1,NULL,NULL,1,N'City Master Import')
					END	
				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'City Category Expense Import')
					BEGIN
						
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'City Category Expense Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'City Category Expense Import',@Under_form_Id,7,1,NULL,NULL,1,N'City Category Expense Import')
					END	
				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Business Segment Import')
					BEGIN				
						
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Business Segment Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Business Segment Import',@Under_form_Id,7,1,NULL,NULL,1,N'Business Segment Import')
					END	
				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Cost Center Import')
					BEGIN
						
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Cost Center Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Cost Center Import',@Under_form_Id,7,1,NULL,NULL,1,N'Cost Center Import')
					END	
				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Asset Master Import')
					BEGIN
						
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Asset Master Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Asset Master Import',@Under_form_Id,7,1,NULL,NULL,1,N'Asset Master Import')
					END	
				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Asset Import')
					BEGIN
						
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Asset Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Asset Import',@Under_form_Id,7,1,NULL,NULL,1,N'Asset Import')
					END	
				--Mukti(start)18012016	
				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Vendor Master Import')
					BEGIN						
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Vendor Master Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Vendor Master Import',@Under_form_Id,7,1,NULL,NULL,1,N'Vendor Master Import')
					END	
				--Mukti(end)18012016	
				
				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Employee Import')
					BEGIN
						
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Employee Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Employee Import',@Under_form_Id,7,1,NULL,NULL,1,N'Employee Import')
					END	
				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Employee Update Import')
					BEGIN
						
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Employee Update Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Employee Update Import',@Under_form_Id,7,1,NULL,NULL,1,N'Employee Update Import')
					END	

				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Employee Transfer IMPORT')
					BEGIN
						
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Employee Transfer Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Employee Transfer Import',@Under_form_Id,7,1,NULL,NULL,1,N'Employee Transfer Import')
					END	

				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Employee Nominees Import')
					BEGIN
						
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Employee Nominees Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Employee Nominees Import',@Under_form_Id,7,1,NULL,NULL,1,N'Employee Nominees Import')
					END	
				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Employee FamilyMember Import')
					BEGIN
								
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Employee FamilyMember Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Employee FamilyMember Import',@Under_form_Id,7,1,NULL,NULL,1,N'Employee FamilyMember Import')
					END	
				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Employee Salary Cycle Import')
					BEGIN
						
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Employee Salary Cycle Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Employee Salary Cycle Import',@Under_form_Id,7,1,NULL,NULL,1,N'Employee Salary Cycle Import')
					END		
					
					
					

				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Employee Salary Cycle Import')
					BEGIN
						
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Employee Salary Cycle Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Employee Salary Cycle Import',@Under_form_Id,7,1,NULL,NULL,1,N'Employee Salary Cycle Import')
					END		
				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Change Password IMPORT')
					BEGIN
						
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Change Password Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Change Password Import',@Under_form_Id,7,1,NULL,NULL,1,N'Change Password Import')
					END		
				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Employee Scheme')
					BEGIN
						
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Employee Scheme' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Employee Scheme',@Under_form_Id,7,1,NULL,NULL,1,N'Employee Scheme')
					END		
				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Employee Weekoff Import')
					BEGIN
						
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Employee Weekoff Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Employee Weekoff Import',@Under_form_Id,7,1,NULL,NULL,1,N'Employee Weekoff Import')
					END		
				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Reporting Manager Import')
					BEGIN
						
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Reporting Manager Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Reporting Manager Import',@Under_form_Id,7,1,NULL,NULL,1,N'Reporting Manager Import')
					END		
				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Qualification Import')
					BEGIN
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Qualification Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Qualification Import',@Under_form_Id,7,1,NULL,NULL,1,N'Qualification Import')
					END		
				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Experience Import')
					BEGIN
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Experience Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Experience Import',@Under_form_Id,7,1,NULL,NULL,1,N'Experience Import')
					END		

				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Earn/Ded Data Import')
					BEGIN
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Earn/Ded Data Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Earn/Ded Data Import',@Under_form_Id,7,1,NULL,NULL,1,N'Earn/Ded Data Import')
					END		


			

				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Allow/Dedu Revised Import')
					BEGIN
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Allow/Dedu Revised Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Allow/Dedu Revised Import',@Under_form_Id,7,1,NULL,NULL,1,N'Allow/Dedu Revised Import')
					END		

				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Bulk Increment Import')
					BEGIN
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Bulk Increment Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Bulk Increment Import',@Under_form_Id,7,1,NULL,NULL,1,N'Bulk Increment Import')
					END			


				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Insurance Detail Import')
					BEGIN
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Insurance Detail Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Insurance Detail Import',@Under_form_Id,7,1,NULL,NULL,1,N'Insurance Detail Import')
					END		
				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Cross Company Privilege Import')
					BEGIN
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Cross Company Privilege Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Cross Company Privilege Import',@Under_form_Id,7,1,NULL,NULL,1,N'Cross Company Privilege Import')
					END		
				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'License Detail Import')
					BEGIN
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'License Detail Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'License Detail Import',@Under_form_Id,7,1,NULL,NULL,1,N'License Detail Import')
					END		
				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Reference Import')
					BEGIN
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Reference Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Reference Import',@Under_form_Id,7,1,NULL,NULL,1,N'Reference Import')
					END		

				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Employee Left Import')
					BEGIN
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Employee Left Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Employee Left Import',@Under_form_Id,7,1,NULL,NULL,1,N'Employee Left Import')
					END
							
				Set @Sort_id_Check = @Sort_id_Check + 1	
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Asset Allocation Import')
					BEGIN
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Asset Allocation Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Asset Allocation Import',@Under_form_Id,7,1,NULL,NULL,1,N'Asset Allocation Import')
					END		
				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Leave Opening Import')
					BEGIN
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Leave Opening Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Leave Opening Import',@Under_form_Id,7,1,NULL,NULL,1,N'Leave Opening Import')
					END		
				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Leave Credit Import')
					BEGIN
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Leave Credit Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Leave Credit Import',@Under_form_Id,7,1,NULL,NULL,1,N'Leave Credit Import')
					END		
				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Leave Allowance Detail Import')
					BEGIN
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Leave Allowance Detail Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Leave Allowance Detail Import',@Under_form_Id,7,1,NULL,NULL,1,N'Leave Allowance Detail Import')
					END		

				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Leave Approval Import')
					BEGIN
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Leave Approval Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Leave Approval Import',@Under_form_Id,7,1,NULL,NULL,1,N'Leave Approval Import')
					END		

				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Multiple Leave Opening Import')
					BEGIN
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Multiple Leave Opening Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Multiple Leave Opening Import',@Under_form_Id,7,1,NULL,NULL,1,N'Multiple Leave Opening Import')
					END		

				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Loan Approval Import')
					BEGIN
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Loan Approval Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Loan Approval Import',@Under_form_Id,7,1,NULL,NULL,1,N'Loan Approval Import')
					END		

				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Loan Interest Subsidy')
					BEGIN
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Loan Interest Subsidy' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Loan Interest Subsidy',@Under_form_Id,7,1,NULL,NULL,1,N'Loan Interest Subsidy')
					END		
				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Attendance(In/Out) Import')
					BEGIN
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Attendance(In/Out) Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Attendance(In/Out) Import',@Under_form_Id,7,1,NULL,NULL,1,N'Attendance(In/Out) Import')
					END		
				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Attendance Import')
					BEGIN
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Attendance Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Attendance Import',@Under_form_Id,7,1,NULL,NULL,1,N'Attendance Import')
					END		
				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Monthly Present Import')
					BEGIN
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Monthly Present Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Monthly Present Import',@Under_form_Id,7,1,NULL,NULL,1,N'Monthly Present Import')
					END		

				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Monthly Earn/Ded Import')
					BEGIN
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Monthly Earn/Ded Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Monthly Earn/Ded Import',@Under_form_Id,7,1,NULL,NULL,1,N'Monthly Earn/Ded Import')
					END		
				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Allowance Days Import')
					BEGIN
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Allowance Days Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Allowance Days Import',@Under_form_Id,7,1,NULL,NULL,1,N'Allowance Days Import')
					END		
				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Grade Change Import')
					BEGIN
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Grade Change Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Grade Change Import',@Under_form_Id,7,1,NULL,NULL,1,N'Grade Change Import')
					END		



				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Reimbursement Approval Import')
					BEGIN
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Reimbursement Approval Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Reimbursement Approval Import',@Under_form_Id,7,1,NULL,NULL,1,N'Reimbursement Approval Import')
					END		
					
					--Added By Ramiz on 04/03/2016
				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Advance Import')
					BEGIN						
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check,
							Module_Name = 'Payroll'
						WHERE FORM_NAME = 'Advance Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_Name])
						values (@Menu_id1,N'Advance Import',@Under_form_Id,7,1,NULL,NULL,1,N'Advance Import','Payroll')
					END
				--Ended By Ramiz on 04/03/2016
				
				--Added By Mukti start(16052016)
				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Production Bonus/Variable Import')
					BEGIN
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check,
							Module_Name = 'Payroll'
						WHERE FORM_NAME = 'Production Bonus/Variable Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_Name])
						values (@Menu_id1,N'Production Bonus/Variable Import',@Under_form_Id,7,1,NULL,NULL,1,N'Production Bonus/Variable Import','Payroll')
					END	
				--Added By Mukti end(16052016)
				
				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Tax Declaration Import')
					BEGIN
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Tax Declaration Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Tax Declaration Import',@Under_form_Id,7,1,NULL,NULL,1,N'Tax Declaration Import')
					END		
				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Product Details Import')
					BEGIN
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Product Details Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Product Details Import',@Under_form_Id,7,1,NULL,NULL,1,N'Product Details Import')
					END		

				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Estimated Amount Import')
					BEGIN
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Estimated Amount Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Estimated Amount Import',@Under_form_Id,7,1,NULL,NULL,1,N'IT Estimated Amount Import')
					END		
				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'GPF Opening Import')
					BEGIN
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'GPF Opening Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_Name])--Change By Jaina 1-09-2016 (Module Name added)
						values (@Menu_id1,N'GPF Opening Import',@Under_form_Id,7,1,NULL,NULL,1,N'GPF Opening Import','GPF')
					END		

				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'GPF Additional Amount Import')
					BEGIN
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'GPF Additional Amount Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name])  --Change By Jaina 1-09-2016 (Module Name added)
						values (@Menu_id1,N'GPF Additional Amount Import',@Under_form_Id,7,1,NULL,NULL,1,N'GPF Additional Amount Import','GPF')
					END		
				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'CPS Opening Import')
					BEGIN
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check ,
						Module_name = 'CPS'
						WHERE FORM_NAME = 'CPS Opening Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'CPS Opening Import',@Under_form_Id,7,1,NULL,NULL,1,N'CPS Opening Import')
					END		
				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Publish News Letter Import') 
					BEGIN
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Publish News Letter Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Publish News Letter Import',@Under_form_Id,7,1,NULL,NULL,1,N'News Announcement Import')
					END
					
				
					-- Added by Prakash Patel on 23022016 Start
				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Transport Attendance Import')
					BEGIN						
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Transport Attendance Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
						values (@Menu_id1,N'Transport Attendance Import',@Under_form_Id,7,1,NULL,NULL,1,N'Transport Attendance Import')
					END			
				-- Added by Prakash Patel on 23022016 End	
			
					--Added By Rohit start(19052016)
				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Bonus Deduction Import')
					BEGIN
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Bonus Deduction Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
						values (@Menu_id1,N'Bonus Deduction Import',@Under_form_Id,7,1,NULL,NULL,1,N'Bonus Deduction Import',@Sort_id_Check)
					END	
				--Added By Rohit end(19052016)
				
				--Added By Jaina 08-06-2016 Start
				Set @Sort_id_Check = @Sort_id_Check + 1
				IF EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Clearance Attribute Import')
					BEGIN
						UPDATE T0000_DEFAULT_FORM 
						SET SORT_ID_CHECK = @Sort_id_Check 
						WHERE FORM_NAME = 'Clearance Attribute Import' AND UNDER_FORM_ID = @Under_form_Id
					END
				ELSE
					BEGIN
						select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
						INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
						values (@Menu_id1,N'Clearance Attribute Import',@Under_form_Id,7,1,NULL,NULL,1,N'Clearance Attribute Import',@Sort_id_Check)
					END	
				--Added By Jaina 08-06-2016 End
				
			
						---------ended----------------------------- 	
						if @Import_Count = 0
						Begin	
							--if not exists(SELECT Form_Id From T0050_PRIVILEGE_DETAILS where Form_id >= 6875 and Form_id <= 6909)
							if not exists(SELECT Form_Id From T0050_PRIVILEGE_DETAILS where Form_id IN(Select T0000_DEFAULT_FORM.Form_ID From T0000_DEFAULT_FORM where Under_Form_ID = 6007))
							begin 
							
							Declare @Privilage_ID Numeric(5,0)
							Declare @Cmp_ID Numeric(5,0)
							Declare @Form_Id Numeric(10,0)
							DECLARE Import_rights_Cursor CURSOR FOR SELECT Privilage_ID,Cmp_Id,Form_Id From T0050_PRIVILEGE_DETAILS where Form_Id = 6007 and  Is_View = 1 and Is_Edit = 1 and Is_Save = 1 and Is_Delete = 1 ORDER BY Cmp_Id 
								OPEN Import_rights_Cursor 
									fetch next from Import_rights_Cursor into @Privilage_ID,@Cmp_ID,@Form_Id
									  while @@fetch_status = 0
										Begin
												
												Declare @Trans_Id Numeric(18,0) = 0
												select @Trans_Id = Isnull(max(Trans_Id),0) + 1 	From T0050_PRIVILEGE_DETAILS
												
												--Select @Trans_Id,@Privilage_ID,@Cmp_Id,Form_ID,1,1,1,1,0 from T0000_DEFAULT_FORM where Under_Form_ID = 6007
												
												INSERT INTO T0050_PRIVILEGE_DETAILS
												  (Trans_Id, Privilage_ID, Cmp_Id, Form_Id, Is_View, Is_Edit, Is_Save, Is_Delete, Is_Print)
												(Select  (@Trans_Id + ROW_NUMBER() OVER ( ORDER BY Form_ID )) as row_id,@Privilage_ID,@Cmp_Id,Form_ID,1,1,1,1,0 from T0000_DEFAULT_FORM where Under_Form_ID = 6007)
																 
												fetch next from Import_rights_Cursor into @Privilage_ID,@Cmp_ID,@Form_Id
										End
								 Close Import_rights_Cursor 
								 deallocate Import_rights_Cursor
							End 
					End 
				--Added by nilesh patel on 20022015 -End For Custmize report rights wise

				End of Comment: Nimesh on 05-Mar-
				*/

	
---------------30 dec 2014 hrms dashboard sneha-------------------

--If not exists (select Form_id from T0000_DEFAULT_FORM where  Form_name = 'Member_Timesheet_Details' And Form_ID > 7000 and Form_ID < 7500)	
--	Begin
--		Select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID > 7000 and Form_ID < 7500
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
--		values (@Menu_id1,'Member Timesheet Details',7023, 344, 1,'Project_Details.aspx',N'menu/info.gif',1,'Member Timesheet Details')
--	End
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Claim_Approval_Superior' And Form_ID > 7000 and Form_ID < 7499)
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Claim_Approval_Superior',7013 ,321,1,'Claim_Approval_Superior.aspx','menu/loan-claim.gif',1,'Claim Approvals')
	end

--Added By Mukti 05022015(start)
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee KPA') 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 6700
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'Employee KPA', 6518, 229, 1, N'HRMS/Employee_KPA.aspx', N'menu/company_structure.gif', 1, N'Employee KPA')			
	end		
--Added By Mukti 05022015(end)


if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Schedule Master')  -- Added By Rohit on 12032015
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000     and Form_ID < 6500  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check])
		values (@Menu_id1,'Schedule Master',6013,20,1,'Batch.aspx',@Masters_Img, 1, N'Schedule Master',28)
	end

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Labour Hours Report')  -- Added By Rohit on 12032015
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500     and Form_ID < 7000  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check])
		values (@Menu_id1,'Labour Hours Report',6712, 194,1,Null,Null, 1, N'Labour Hours Report',1)
	end

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Payment Process Report')  -- Added By Rohit on 07042015
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500     and Form_ID < 7000  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check])
		values (@Menu_id1,'Payment Process Report',6712, 194,1,Null,Null, 1, N'Payment Process Report',2)
	end	

--Added by Gadriwala Muslim 20032015 - Start
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Comp-Off Avail Balance' And Form_ID > 6000 and Form_ID < 7000) 
	begin    
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 7000
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(@Menu_id1, N'Comp-Off Avail Balance', 6703, 176, 1, NULL, NULL, 1, N'Comp-Off Avail Balance')
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Interest Subsidy Statement' And Form_ID > 6000 and Form_ID < 7000) 
	begin    
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 7000
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(@Menu_id1, N'Interest Subsidy Statement',6704, 178, 1, NULL, NULL, 1, N'Interest Subsidy Statement')
	end
else
	begin
			update 	[T0000_DEFAULT_FORM] set [Under_Form_ID] = 6704 where Form_name = 'Interest Subsidy Statement' And Form_ID > 6000 and Form_ID < 7000
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Gate Pass In out Summary' And Form_ID > 6000 and Form_ID < 7000) 
	begin    
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 7000
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(@Menu_id1, N'Gate Pass In out Summary', 6702, 174, 1, NULL, NULL, 1, N'Gate Pass In out Summary')
	end
--Added by Gadriwala Muslim 20032015 - End

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Asset Allocation Report')  -- Mukti 25032015
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500     and Form_ID < 7000  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check])
		--values (@Menu_id1,'Asset Allocation Report',6712, 194,1,Null,Null, 1, N'Asset Allocation Report',1)
		values (@Menu_id1,'Asset Allocation Report',6704, 178,1,Null,Null, 1, N'Asset Allocation Report',5)
	end
	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Asset Installment Statement')  -- Mukti 01042015
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500     and Form_ID < 7000  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check])
		--values (@Menu_id1,'Asset Installment Statement',6712, 194,1,Null,Null, 1, N'Asset Installment Statement',1)
		values (@Menu_id1,'Asset Installment Statement',6704, 178,1,Null,Null, 1, N'Asset Installment Statement',6)
	end

	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Pending Asset Installment Details')  -- Mukti 29092015
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500     and Form_ID < 7000  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check])
		values (@Menu_id1,'Pending Asset Installment Details',6704, 178,1,Null,Null, 1, N'Pending Asset Installment Details',7)
	end

		
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'In Out Re-Synchronized')  
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000     and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check])
		values (@Menu_id1,'In Out Re-Synchronized',6169, 74,1,'EMPLOYEE_DATA_SYNCHRONIZED.ASPX',@Employee_Img, 1, N'In Out Re-Synchronized',0)
	end
else
	begin		
		UPDATE	T0000_DEFAULT_FORM SET [Is_Active_For_menu]=1 
		WHERE	Form_Name='In Out Re-Synchronized' AND Under_Form_ID=6169
	end

----Ankit 05032016
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Canteen Punch')  
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000     and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check])
		values (@Menu_id1,'Canteen Punch',6169, 74,1,'Employee_CanteenPunch.aspx',@Employee_Img, 1, N'Canteen Punch',0)
	end
else
	begin		
		UPDATE	T0000_DEFAULT_FORM SET [Is_Active_For_menu]=1 
		WHERE	Form_Name='Canteen Punch' AND Under_Form_ID=6169
	end	
	
	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Transfer Letter')  -- Added By Sumit 15042015
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 7000  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check])
		values (@Menu_id1,'Transfer Letter',6709, 188,1,Null,Null, 1, N'Transfer Letter',1)
	end	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'LWF Statement' and form_id>6500 and Form_ID<7000)  -- Added By Sumit 15042015
	begin	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 7000  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check])
		values (@Menu_id1,'LWF Statement',6708, 186,1,Null,Null, 1, N'LWF Statement',1)
	end		
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Form 37')  -- Added By Sumit 15042015
	begin	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 7000  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check])
		values (@Menu_id1,'Form 37',6707, 184,1,Null,Null, 1, N'Form 37',1)
	end
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Allowance Status')  -- Added By Sumit 15042015
	begin	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 7000  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check])
		values (@Menu_id1,'Allowance Status',6705, 180,1,Null,Null, 1, N'Allowance Status',1)
	end		
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Night Halt Slip')  -- Added By Sumit 15042015
	begin	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 7000  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check])
		values (@Menu_id1,'Night Halt Slip',6705, 180,1,Null,Null, 1, N'Night Halt Slip',1)
	end
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Salary Certificate')  -- Added By Sumit 15042015
	begin	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 7000  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check])
		values (@Menu_id1,'Salary Certificate',6705, 180,1,Null,Null, 1, N'Salary Certificate',1)
	end
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Claim Detail Report')  -- Added By Sumit 15042015
	begin	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 7000  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check])
		values (@Menu_id1,'Claim Detail Report',6704, 178,1,Null,Null, 1, N'Claim Detail Report',1)
	end
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Shift Allocation')  -- Added By Sumit 15042015
	begin	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 7000  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check])
		values (@Menu_id1,'Shift Allocation',6702, 174,1,Null,Null, 1, N'Shift Allocation',1)
	end
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Age Analysis' And Form_ID > 6700 and Form_ID < 6999) -- Added By Sumit 15042015
	begin		
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700  and Form_ID < 6999	  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Employee Age Analysis',6701, 172,1,NULL, NULL, 1, N'Employee Age Analysis')
		
	end	
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Experience Analysis' And Form_ID > 6700 and Form_ID < 6999) -- Added By Sumit 15042015
	begin		
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700  and Form_ID < 6999	  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Employee Experience Analysis',6701, 172,1,NULL, NULL, 1, N'Employee Experience Analysis')
		
	end	
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee New Joining-Left Summary' And Form_ID > 6700 and Form_ID < 6999) -- Added By Sumit 15042015
	begin		
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700  and Form_ID < 6999	  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Employee New Joining-Left Summary',6701, 172,1,NULL, NULL, 1, N'Employee New Joining-Left Summary')		
	end	 

	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Incerment Summary' And Form_ID > 6700 and Form_ID < 6999) -- Added By Sumit 15042015
		begin		
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700  and Form_ID < 6999	  
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
			values (@Menu_id1,'Employee Incerment Summary',6701, 172,1,NULL, NULL, 1, N'Employee Increment Summary')
		end
	else--added on 6 July 2015 sneha - to correct spelling
		begin
			update [T0000_DEFAULT_FORM] set alias = 'Employee Increment Summary' where Form_name = 'Employee Incerment Summary'
		end	

	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Retirement Summary' And Form_ID > 6700 and Form_ID < 6999) -- Added By Sumit 15042015
	begin		
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700  and Form_ID < 6999	  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Employee Retirement Summary',6701, 172,1,NULL, NULL, 1, N'Employee Retirement Summary')
		
	end
	
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Asset Installment Statement My#')  
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7500 and Form_ID < 7999  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Asset Installment Statement My#',7532,402,1,NULL, NULL, 1, N'Asset Installment Statement My#')
	end
	else
	begin
		update T0000_DEFAULT_FORM
		set [Under_Form_ID]=7532, [Sort_ID]=402
		where Form_name = 'Asset Installment Statement My#'
	end
	-- Added by Gadriwala Muslim 27052015-Start
	
	If not exists (select Form_ID from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name = 'Pre comp-Off Application' and Form_ID > 7000 and Form_ID < 7500 )
	  begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check] )
		values(@Menu_id1, N'Pre comp-Off Application', 7045, 314, 1, N'PreCompOff_Application.aspx', @Leave_Img, 1, N'Pre comp-Off Application',1)
	  end
	 If not exists (select Form_ID from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name = 'Pre comp-Off Approval' and Form_ID > 7000 and Form_ID < 7500 )
	  begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check] )
		values(@Menu_id1, N'Pre comp-Off Approval', 7045, 314, 1, N'PreCompOff_Approval.aspx', @Leave_Img, 1, N'Pre comp-Off Approval',2)
	  end 
	 -- INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6135, N'Comp Off Approval', 6133, 98, 1, N'CompOff_Approval.aspx', @Leave_Img, 1, N'Comp Off Approval')
	 -- If not exists (select Form_ID from T0000_DEFAULT_FORM where Form_Name = 'Pre comp-Off Approval' and Form_ID > 6000 and Form_ID < 6500)
	 -- begin
		--select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID > 6000 and Form_ID < 6500  
		--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		--values(@Menu_id1, N'Pre comp-Off Approval', 6133, 98, 1, N'PreCompOff_Approval.aspx', @Leave_Img, 1, N'Pre Comp Off Approval')
	 -- end 
	-- Added by Gadriwala Muslim 27052015-End
	
--Mukti(start)23042015
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'KPI Import' And Form_ID > 6500 and Form_ID < 6700) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 6700
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'KPI Import', 6518, 230, 1, N'HRMS/KPI_Import_Data.aspx', N'menu/company_structure.gif', 1, N'KPI Import')			
	end
--Mukti(end)23042015
--sneha(start)07052015
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Genealogy Chart' And Form_ID > 6500 and Form_ID < 6700) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM  WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 6700
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'Genealogy Chart', 6540, 248, 1, N'HRMS/HRMS_Geneology_Chart.aspx', N'menu/desig.png', 1, N'Genealogy Chart')			
	end
--sneha(end)07052015


--------------Added by Sumit (Nimesh)15052015----------------------------
--if not exists (select Form_id from T0000_DEFAULT_FORM where  Form_name = 'Canteen Master' And Form_ID > 6000 and Form_ID < 6500) 
--	begin
--		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID > 6000 and Form_ID < 6500
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
--		values(@Menu_id1, N'Canteen Master', 6027, 45, 1, N'Master_Canteen.aspx', @Masters_Img, 1, N'Canteen Master')			
--	end
-------------Ended by Sumit (Nimesh)15052015----------------------------


------------Added by Nimesh 22-05-2015 ----------------------------
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Shift Rotation Master' And Form_ID > 6000 and Form_ID < 6500) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'Shift Rotation Master', 6027, 46, 1, N'ShiftRotation.aspx', @Masters_Img, 1, N'Shift Rotation Master')			
	end
--Updating URL for Employee Shift Rotation menu and we are using Employee Shift Import name instead of rotation.
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Shift Rotation' And Form_ID > 6000 and Form_ID < 6500) 
	begin
		Update	[dbo].[T0000_DEFAULT_FORM] 
		SET		[Sort_ID]=77, [Form_url]=N'Employee_Assign_ShiftRotation.aspx',[Alias]=N'Employee Shift Rotation'
		WHERE	[Form_name] = 'Employee Shift Rotation' And Form_ID > 6000 and Form_ID < 6500
				AND [Under_Form_ID]=6171		
	end		
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Shift Import' And Form_ID > 6000 and Form_ID < 6500) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'Employee Shift Import', 6171, 77, 1, N'Employee_Shift_Rotation.aspx', @Employee_Img, 1, N'Employee Shift Import')			
	end	
ELSE  --Mukti(15032017)
	BEGIN
		Update	[dbo].[T0000_DEFAULT_FORM] 
		SET		Is_Active_For_menu=0
		WHERE	[Form_name] = 'Employee Shift Import' And Form_ID > 6000 and Form_ID < 6500
				AND [Under_Form_ID]=6171	
	END
-----------Ended by Nimesh----------------------------

-- Added by rohit on 26052015
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'ESIC Calculation Process' And Form_ID > 6000 and Form_ID < 6500) 
		BEGIN    
			SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000     and Form_ID < 6500  
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_Check])
			VALUES (@Menu_id1,'ESIC Calculation Process',6088,146,1,'Esic_Calc.aspx',@Salary_Img, 1, N'ESIC Calculation Process',1)
		END
		-- Added by Sumit 27052015
--IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WHERE  Form_name = 'Leave Encashment Report#' And Form_ID > 7500 and Form_ID < 8000) 
--		BEGIN    
--			SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WHERE Form_ID > 7500     and Form_ID < 8000  
--			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_Check])
--			VALUES (@Menu_id1,'Leave Encashment Report#',7525,347,1,null,null, 1, N'Leave Encashment Report#',1)
--		END	

-- Added by rohit on 09062015

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Other Payment Process' And Form_ID > 6000 and Form_ID < 6500) 
		BEGIN    
			SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000     and Form_ID < 6500  
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_Check])
			VALUES (@Menu_id1,'Other Payment Process',6088,146,1,'Home.aspx',@Salary_Img, 1, N'Other Payment Process',0)
		END
Declare @For_Id_Other_Process as numeric
SELECT @For_Id_Other_Process = Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Other Payment Process' And Form_ID > 6000 and Form_ID < 6500

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Process Type Master' And Form_ID > 6000 and Form_ID < 6500) 
		BEGIN    
			SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000     and Form_ID < 6500  
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_Check])
			VALUES (@Menu_id1,'Process Type Master',@For_Id_Other_Process,146,1,'master_process_type.aspx',@Salary_Img, 1, N'Process Type Master',0)
		END


IF EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'ESIC Calculation Process' And Form_ID > 6000 and Form_ID < 6500) 
		BEGIN    
			update T0000_DEFAULT_FORM 
			set Under_Form_ID = @For_Id_Other_Process
			,sort_id=146,Sort_Id_Check=1
			,Alias = 'ESIC & TDS Calculation Process'
			WHERE  Form_name = 'ESIC Calculation Process' And Form_ID > 6000 and Form_ID < 6500
		END
		
IF EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Payment Process' And Form_ID > 6000 and Form_ID < 6500) 
		BEGIN    
			update T0000_DEFAULT_FORM 
			set Under_Form_ID = @For_Id_Other_Process
			,sort_id=146,Sort_Id_Check=10
			WHERE  Form_name = 'Payment Process' And Form_ID > 6000 and Form_ID < 6500
		END		

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Seniority Calculation Process' And Form_ID > 6000 and Form_ID < 6500) 
		BEGIN    
			SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000     and Form_ID < 6500  
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_Check])
			VALUES (@Menu_id1,'Seniority Calculation Process',@For_Id_Other_Process,146,1,'Seniority_Calc.aspx',@Salary_Img, 1, N'Seniority Calculation Process',2)
		END
-- Ended by rohit on 09062015		

IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Reimbursement Slip My#')		-----Ankit 07072015
	BEGIN
		SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7500 and Form_ID < 7999  
		
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		VALUES (@Menu_id1,'Reimbursement Slip My#',7532,398,1,NULL, NULL, 1, N'Reimbursement Slip My#')
	END
IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Shift Report My#')		-----Sumit 10072015
	BEGIN
		SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7500 and Form_ID < 7999  
		
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		VALUES (@Menu_id1,'Shift Report My#',7532,399,1,'~/Report_Payroll_Mine.aspx?Id=2', NULL, 1, N'Shift Report My#')
	END	
IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Shift Report Member#')		-----Sumit 10072015
	BEGIN
		SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7500 and Form_ID < 7999  
		
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		VALUES (@Menu_id1,'Shift Report Member#',7514,347,1,'~/Report_Payroll.aspx?Id=2', NULL, 1, N'Shift Report Member#')
	END			
IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Leave Card My#')		-----Sumit 16072015
	BEGIN
		SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7500 and Form_ID < 7999  
		
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		VALUES (@Menu_id1,'Leave Card My#',7525,393,1,'~/Report_Payroll_Mine.aspx?Id=1013', NULL, 1, N'Leave Card My#')
	END	
IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Leave Card Member#')		-----Sumit 16072015
	BEGIN
		SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7500 and Form_ID < 7999  
		
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		VALUES (@Menu_id1,'Leave Card Member#',7507,347,1,'~/Report_Payroll.aspx?Id=1013', NULL, 1, N'Leave Card Member#')
	END	
	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Allowance/Deduction Revised Report' And Form_ID > 6700 and Form_ID < 6999) --Added by Sumit 20072015
	begin
		
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700  and Form_ID < 6999	  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Allowance/Deduction Revised Report',6705, 180,1,NULL, NULL, 1, N'Allowance/Deduction Revised Report')
		
end	

		
IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee CTC Report Member#')		-----Mukti 05102015
	BEGIN
		SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7500 and Form_ID < 7999  
		
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		VALUES (@Menu_id1,'Employee CTC Report Member#',7514,347,1,'~/Report_Payroll.aspx?Id=3', NULL, 1, N'Employee CTC Report Member#')
	END			
	
-- added by rohit on 20072015
--added by sneha on 23 July 2015
Declare @under_Id_Other_Process as numeric
SELECT @under_Id_Other_Process = Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Training' And Form_ID > 6500 and Form_ID < 6700
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Training In/Out' And Form_ID > 6500 and Form_ID < 6700) 
		BEGIN    
			SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6500     and Form_ID < 6700  
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_Check])
			VALUES (@Menu_id1,'Training In/Out',@under_Id_Other_Process,215,1,'hrms/Training_inout.aspx','menu/fix.gif', 1, N'Training Attendance',2)
		END
ELSE
	BEGIN
		UPDATE T0000_DEFAULT_FORM set Alias = 'Training Attendance'  where Form_Name ='Training In/Out'
	END
		
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Training InOut Summary' And Form_ID > 6700 and Form_ID < 6999) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700 and Form_ID < 6999
		declare @hrreport_id1 as numeric(18,0)
		select @hrreport_id1 = form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'HRMS Reports' And Form_ID > 6700 and Form_ID < 6999 
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'Training InOut Summary', @hrreport_id1, 200, 1, null, null, 1, N'Training Attendance Summary')			
	end
ELSE
	BEGIN
		UPDATE T0000_DEFAULT_FORM SET Alias = 'Training Attendance Summary'  WHERE Form_Name ='Training InOut Summary'
	END
--ended by sneha on 23 July 2015	
--added by sneha on 07 Aug 2015
SELECT @under_Id_Other_Process = Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Training' And Form_ID > 6500 and Form_ID < 6700
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Training Category Master' And Form_ID > 6500 and Form_ID < 6700) 
		BEGIN    
			SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6500     and Form_ID < 6700  
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_Check],[Module_name])
			VALUES (@Menu_id1,'Training Category Master',@under_Id_Other_Process,216,1,'hrms/TrainingCategory_Master.aspx','menu/fix.gif', 1, N'Training Category Master',2,'HRMS')
		END
--Added by Gadriwala Muslim Wrong Calender spelling	25112016	
UPDATE T0000_DEFAULT_FORM SET Form_Name = 'Training Calendar Year',Form_url = 'hrms/training_yearly_calendar.aspx' WHERE  Form_name = 'Training Calender Year' And Form_ID > 6500 and Form_ID < 6700		
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Training Calendar Year' And Form_ID > 6500 and Form_ID < 6700) 
		BEGIN    
			SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6500     and Form_ID < 6700  
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_Check],[Module_name])
			VALUES (@Menu_id1,'Training Calendar Year',@under_Id_Other_Process,217,1,'hrms/training_yearly_calender.aspx','menu/fix.gif', 0, N'Training Calendar Year',2,'HRMS')
		END
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK)  WHERE  Form_name = 'Training Type Master' And Form_ID > 6500 and Form_ID < 6700) 
	BEGIN    
		SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6500     and Form_ID < 6700  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_Check],[Module_name])
		VALUES (@Menu_id1,'Training Type Master',@under_Id_Other_Process,217,1,'hrms/TrainingType_master.aspx','menu/fix.gif', 1, N'Training Type Master',2,'HRMS')
	END		
If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Training Plan' AND  Form_ID > 7000 and Form_ID < 7500)      
	BEGIN
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name])
		values(@Menu_id1, N'Training Plan', 7029, 382, 1, N'Hrms_Training_Plan.aspx', 'menu/hr.gif', 1,N'Training Plan',0,'HRMS')    
	END 	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_297' And Form_ID > 9000 and Form_ID < 10000)
	begin  
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9200 and Form_ID < 9360
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
	values (@Menu_id1,'TD_Home_ESS_297',9261,1274,1,'','',1,'Training Questionnairre',0,'HRMS')
	end
--ended by sneha on 07 Aug 2015
--added by sneha on 11 Aug 2015
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_298' And Form_ID > 9000 and Form_ID < 10000)
	begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9200 and Form_ID < 9360
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
	values (@Menu_id1,'TD_Home_ESS_298',9261,1274,1,'','',1,'OJT Pending since For Month Joinees',0,'HRMS')
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_299' And Form_ID > 9000 and Form_ID < 10000)
	begin  
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9200 and Form_ID < 9360
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
	values (@Menu_id1,'TD_Home_ESS_299',9261,1274,1,'','',1,'OJT Pending since Last Year',0,'HRMS')
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_HR_16' And Form_ID > 9000 and Form_ID < 10000)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 9800
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
		values (@Menu_id1,'TD_Home_HR_16',@hrhomeid,2001,5,'','',1,'OJT Pending since For Month Joinees',0,'HRMS')
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_HR_17' And Form_ID > 9000 and Form_ID < 10000)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 9800
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
		values (@Menu_id1,'TD_Home_HR_17',@hrhomeid,2001,5,'','',1,'OJT Pending since Last Year',0,'HRMS')
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_HR_18' And Form_ID > 9000 and Form_ID < 10000)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 9800
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
		values (@Menu_id1,'TD_Home_HR_18',@hrhomeid,2001,5,'','',1,'Training Pending for last month joinees',0,'HRMS')
	end
--ended by sneha on 11 Aug 2015
--Added By Mukti(start)12082015
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_HR_19' And Form_ID > 9000 and Form_ID < 10000)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 9800
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
		values (@Menu_id1,'TD_Home_HR_19',@hrhomeid,2001,5,'','',1,'Training Application',0,'HRMS')
	end
--Added By Mukti(end)12082015	
--added by sneha on 18082015---
UPDATE T0000_DEFAULT_FORM SET Form_Name = 'Training Calendar Year', Alias= N'Training Calendar Year' WHERE  Form_name = 'Training Calender Year' And Form_ID > 6700 and Form_ID < 6999
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Training Calendar Year' And Form_ID > 6700 and Form_ID < 6999) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700 and Form_ID < 6999
		--declare @hrreport_id1 as numeric(18,0)
		select @hrreport_id1 = form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'HRMS Reports' And Form_ID > 6700 and Form_ID < 6999 
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'Training Calendar Year', @hrreport_id1, 200, 1, null, null, 0, N'Training Calendar Year')			
	end

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Training Inventory' And Form_ID > 6700 and Form_ID < 6999) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700 and Form_ID < 6999
		--declare @hrreport_id1 as numeric(18,0)
		select @hrreport_id1 = form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'HRMS Reports' And Form_ID > 6700 and Form_ID < 6999 
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'Training Inventory', @hrreport_id1, 200, 1, null, null, 1, N'Training Inventory')			
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Training Record' And Form_ID > 6700 and Form_ID < 6999) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700 and Form_ID < 6999
		--declare @hrreport_id1 as numeric(18,0)
		select @hrreport_id1 = form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'HRMS Reports' And Form_ID > 6700 and Form_ID < 6999 
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'Training Record', @hrreport_id1, 200, 1, null, null, 1, N'Training Record')			
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'On Job Training Record' And Form_ID > 6700 and Form_ID < 6999) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700 and Form_ID < 6999
		--declare @hrreport_id1 as numeric(18,0)
		select @hrreport_id1 = form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'HRMS Reports' And Form_ID > 6700 and Form_ID < 6999 
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'On Job Training Record', @hrreport_id1, 200, 1, null, null, 1, N'On Job Training Record')			
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Training Feedback' And Form_ID > 6700 and Form_ID < 6999) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700 and Form_ID < 6999
		--declare @hrreport_id1 as numeric(18,0)
		select @hrreport_id1 = form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'HRMS Reports' And Form_ID > 6700 and Form_ID < 6999 
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'Training Feedback', @hrreport_id1, 200, 1, null, null, 1, N'Training Feedback')			
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Training Induction Feedback' And Form_ID > 6700 and Form_ID < 6999) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700 and Form_ID < 6999
		--declare @hrreport_id1 as numeric(18,0)
		select @hrreport_id1 = form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'HRMS Reports' And Form_ID > 6700 and Form_ID < 6999 
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'Training Induction Feedback', @hrreport_id1, 200, 1, null, null, 1, N'Training Induction Feedback')			
	end
--ended by sneha on 18082015----

--added by sneha on 3oct2015
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee KPA' And Form_ID > 6700 and Form_ID < 6999) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700 and Form_ID < 6999
		--declare @hrreport_id1 as numeric(18,0)
		select @hrreport_id1 = form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'HRMS Reports' And Form_ID > 6700 and Form_ID < 6999 
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
		values(@Menu_id1, N'Employee KPA', @hrreport_id1, 200, 1, null, null, 1, N'Employee KPA',11,'Appraisal2')			
	end
--ended by sneha on 3oct2015
-- Added by rohit on 11072015 for menu reset
--=========================================

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Esic Component' and Form_ID > 6700  and form_id < 6999)
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700  and form_id < 6999
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
		values (@Menu_id1,'Esic Component',6707,184,1,'','',1,'Esic Component',1)
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Payment Slip' and Form_ID > 6700  and form_id < 6999)
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700  and form_id < 6999
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
		values (@Menu_id1,'Payment Slip',6705,180,1,'','',1,'Payment Slip',1)
	end	


--if not exists (select Form_id from T0000_DEFAULT_FORM where  Form_name = 'Esic Component' )
--	begin
--		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID > 6000 and Form_ID < 7000
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
--		values (@Menu_id1,'Esic Component',6707,184,1,'','',1,'Esic Component',1)
--	end


-- Added by rohit on 08072015
---Added By Jaina 14-09-2015 Start
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Insurance Deduction')
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700 and Form_ID < 7000
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
		values (@Menu_id1,'Insurance Deduction',6705,180,1,'','',1,'Insurance Deduction',1)
	end	
---Added By Jaina 14-09-2015 End

--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(6726, N'Attendance Register', 6702, 174, 1, NULL, NULL, 1, N'Attendance Register')
---Added By Jaina 18-09-2015 Start
--if not exists (select Form_id from T0000_DEFAULT_FORM where  Form_name = 'Deviation Report')
--	begin
--		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID > 6700 and Form_ID < 7000
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
--		values (@Menu_id1,'Deviation Report',6702,173,1,'','',1,'Deviation Report',15)
--	end	

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Loan Application Form')
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700 and Form_ID < 7000
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
		values (@Menu_id1,'Loan Application Form',6704,178,1,'','',1,'Loan Application Form',4)
	end	
	
---Added By Jaina 18-09-2015 End

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Organogram' and Form_id>7000)
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Organogram',7029,371,1,'home.aspx',@HR_Img,1,'Organogram')
	end
	
--added by sneha on 17 sep 2015 -start
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Reporting Geneology' And Form_ID > 7000 and Form_ID < 7500)    --Added By Jaina 1-09-2016
	BEGIN
				select @hrreport_id1 = form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Organogram' And Form_ID  > 7000 and Form_ID < 7500 
				update T0000_DEFAULT_FORM SET [Under_Form_ID] = @hrreport_id1
				where Form_name = 'Employee Reporting Geneology' And Form_ID > 7000 and Form_ID < 7500
	END
ELSE
	BEGIN
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID  > 7000 and Form_ID < 7500
		--declare @hrreport_id1 as numeric(18,0)
		select @hrreport_id1 = form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Organogram' And Form_ID  > 7000 and Form_ID < 7500 
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name])
		values(@Menu_id1, N'Employee Reporting Geneology', @hrreport_id1, 371, 1, 'Ess_ReportingGeneology_Chart.aspx', 'menu/hr.gif', 1, N'Employee Reporting Geneology','HRMS')	
	End
--added by sneha on 17 sep 2015 -end

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK)  where  Form_name = 'Admin Settings')
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Admin Settings',6001,14,1,'home.aspx',@Control_Pnl_Img,1,'Admin Settings')
	end

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Report Format Setting')
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Report Format Setting',6001,14,1,'Report_Master_Settings.aspx',@Control_Pnl_Img,1,'Report Format Setting')
	end
		
	--added by sneha on 3 FEB 2016 -start
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Job Description' And Form_ID > 6500 and Form_ID < 7000) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID  > 6500 and Form_ID < 7000
		--declare @hrreport_id1 as numeric(18,0)
		select @hrreport_id1 = form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Recruitment Panel' And Form_ID  > 6500 and Form_ID < 7000 
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name])
		values(@Menu_id1, N'Job Description', @hrreport_id1, 203, 1, 'HRMS/HR_Home.aspx',@Recruitment_img, 1, N'Job Description','HRMS')			
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Job Description Master' And Form_ID > 6500 and Form_ID < 7000) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID  > 6500 and Form_ID < 7000
		--declare @hrreport_id1 as numeric(18,0)
		select @hrreport_id1 = form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Job Description' And Form_ID  > 6500 and Form_ID < 7000 
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name])
		values(@Menu_id1, N'Job Description Master', @hrreport_id1, 203, 1, 'HRMS/Job_DescriptionMaster.aspx',@Recruitment_img, 1, N'Job Description Master','HRMS')			
	end

--added by sneha on 3 FEB 2016 -end
--added by sneha on 6 feb 2016-start
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Assign Employee Job Description' And Form_ID > 6500 and Form_ID < 7000) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID  > 6500 and Form_ID < 7000
		--declare @hrreport_id1 as numeric(18,0)
		select @hrreport_id1 = form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Job Description' And Form_ID  > 6500 and Form_ID < 7000 
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name])
		values(@Menu_id1, N'Assign Employee Job Description', @hrreport_id1, 203, 1, 'HRMS/JD_AssignEmployee.aspx',@Recruitment_img, 1, N'Assign Employee Job Description','HRMS')			
	end
--added by sneha on 6 feb 2016-end

--added by sneha on 10 feb 2016---start
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Appraisal HOD Approval' And Form_ID > 7000 and Form_ID < 7500) 
	begin
		select @hrreport_id1 = form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Appraisal' And Form_ID > 7000 and Form_ID < 7500
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
		values(@Menu_id1, N'Appraisal HOD Approval', @hrreport_id1, 380, 1, N'Ess_ApprisalHoDApproval.aspx', N'menu/hr.gif', 1, N'Appraisal HOD Approval',7,'Appraisal2')			
	end
else
	Begin
		select @hrreport_id1 = form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Appraisal' And Form_ID > 7000 and Form_ID < 7500
		update T0000_DEFAULT_FORM
		set [Under_Form_ID]=@hrreport_id1
		Where Form_name = 'Appraisal HOD Approval' And Form_ID > 7000 and Form_ID < 7500
	end

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_350' and Form_ID > 9000 and Form_ID < 9500) 
	begin 
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 9500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
		values(@Menu_id1, N'TD_Home_ESS_350', 9291, 1296, 1, N'', N'', 1, N'Employee For HOD Approval',0,'Appraisal2')			
	end
--added by sneha on 15 feb 2016---end
--added by sneha on 31 Mar 2016 ---start
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_307' and Form_ID > 9000 and Form_ID < 9500) 
	begin 
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID > 9000 and Form_ID < 9500
		declare @mylink_id as numeric(18,0)
		select @mylink_id= form_id from T0000_DEFAULT_FORM where form_name='TD_Home_ESS_261'
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
		values(@Menu_id1, N'TD_Home_ESS_307', @mylink_id, 273, 1, N'', N'', 1, N'Training Manager Feedback',0,'HRMS')			
	end
--added by sneha on 15 Mar 2016---end
---added by mansi for file notification 08-09-22 --start
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_File_Approve' and Form_ID > 9000 and Form_ID < 9500) 
	begin 
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID > 9000 and Form_ID < 9500
		declare @link_id as numeric(18,0)
		select @link_id= form_id from T0000_DEFAULT_FORM where form_name='TD_Home_ESS_261'
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Page_Flag])
		values(@Menu_id1, N'TD_Home_ESS_File_Approve', @link_id, 1252, 1, N'', N'', 1, N'File Approval',0,'DE')			
	end

	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_File_Approve_forward' and Form_ID > 9000 and Form_ID < 9500) 
	begin 
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID > 9000 and Form_ID < 9500
		declare @link1_id as numeric(18,0)
		select @link1_id= form_id from T0000_DEFAULT_FORM where form_name='TD_Home_ESS_261'
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Page_Flag])
		values(@Menu_id1, N'TD_Home_ESS_File_Approve_forward', @link1_id, 1252, 1, N'', N'', 1, N'Forward To File Approval',0,'DE')			
	end

	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_File_Approve_Forward_By' and Form_ID > 9000 and Form_ID < 9500) 
	begin 
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID > 9000 and Form_ID < 9500
		declare @link2_id as numeric(18,0)
		select @link2_id= form_id from T0000_DEFAULT_FORM where form_name='TD_Home_ESS_261'
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Page_Flag])
		values(@Menu_id1, N'TD_Home_ESS_File_Approve_Forward_By', @link2_id, 1252, 1, N'', N'', 1, N'Forward By File Approval',0,'DE')			
	end

	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_File_Approve_Reivew' and Form_ID > 9000 and Form_ID < 9500) 
	begin 
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID > 9000 and Form_ID < 9500
		declare @link3_id as numeric(18,0)
		select @link3_id= form_id from T0000_DEFAULT_FORM where form_name='TD_Home_ESS_261'
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Page_Flag])
		values(@Menu_id1, N'TD_Home_ESS_File_Approve_Reivew', @link3_id, 1252, 1, N'', N'', 1, N'Review To File Approval',0,'DE')			
	end

	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_File_Approve_Reivew_By' and Form_ID > 9000 and Form_ID < 9500) 
	begin 
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID > 9000 and Form_ID < 9500
		declare @link4_id as numeric(18,0)
		select @link4_id= form_id from T0000_DEFAULT_FORM where form_name='TD_Home_ESS_261'
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Page_Flag])
		values(@Menu_id1, N'TD_Home_ESS_File_Approve_Reivew_By', @link4_id, 1252, 1, N'', N'', 1, N'Review By File Approval',0,'DE')			
	end

	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_File_Application_Review_To' and Form_ID > 9000 and Form_ID < 9500) 
	begin 
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID > 9000 and Form_ID < 9500
		declare @link5_id as numeric(18,0)
		select @link5_id= form_id from T0000_DEFAULT_FORM where form_name='TD_Home_ESS_261'
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Page_Flag])
		values(@Menu_id1, N'TD_Home_ESS_File_Application_Review_To', @link5_id, 1252, 1, N'', N'', 1, N'Review To File Application',0,'DE')			
	end
	---added by mansi for file notification 08-09-22 --end

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_310' and Form_ID > 9000 and Form_ID < 9500) 
	begin 
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 9500
		
		select @mylink_id= form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where form_name='TD_Home_ESS_301'
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
		values(@Menu_id1, N'TD_Home_ESS_310', @mylink_id, 1317, 1, N'', N'', 1, N'Training Calender',0,'HRMS')			
	end
--added by sneha on 22 Jun 2016 --end
--added by sneha on 08 Jul 2016 --start
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_311' and Form_ID > 9000 and Form_ID < 9500) 
	begin 
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 9500
		
		select @mylink_id= form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where form_name='TD_Home_ESS_261'
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
		values(@Menu_id1, N'TD_Home_ESS_311', @mylink_id, 274, 1, N'', N'', 1, N'Recruitment Opening',0,'HRMS')			
	end
--added by sneha on 08 Jul 2016 --end
--added by sneha on 22 Jul 2016 --start
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Goal Setting' And Form_ID > 6500 and Form_ID < 6700) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 6700
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name])
		values(@Menu_id1, N'Employee Goal Setting', 6518, 230, 1, N'HRMS/EmployeeGoalSetting.aspx', N'menu/company_structure.gif', 0, N'Employee Goal Setting','Appraisal3')			
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Goal Assessment' And Form_ID > 6500 and Form_ID < 6700) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 6700
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name])
		values(@Menu_id1, N'Employee Goal Assessment', 6518, 230, 1, N'HRMS/EmployeeGoalSetting_Review.aspx', N'menu/company_structure.gif', 0, N'Employee Goal Assessment','Appraisal3')			
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'ESS Employee Goal Setting' And Form_ID > 7000 and Form_ID < 7500)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name])
		values (@Menu_id1,'ESS Employee Goal Setting',@Temp_Form_ID_kpi,382,1,'Ess_EmployeeGoalSetting.aspx','menu/process.png',0,'Employee Goal Setting','Appraisal3')
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'ESS Employee Goal Setting Approval' And Form_ID > 7000 and Form_ID < 7500)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name])
		values (@Menu_id1,'ESS Employee Goal Setting Approval',@Temp_Form_ID_kpi,382,1,'Ess_EmployeeGoalSetting_Approval.aspx','menu/process.png',0,'Employee Goal Setting Approval','Appraisal3')
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'ESS Employee Goal Assessment' And Form_ID > 7000 and Form_ID < 7500)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name])
		values (@Menu_id1,'ESS Employee Goal Assessment',@Temp_Form_ID_kpi,382,1,'Ess_EmployeeGoalSetting_Review.aspx','menu/process.png',0,'Employee Goal Assessment','Appraisal3')
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'ESS Employee Goal Assessment Approval' And Form_ID > 7000 and Form_ID < 7500)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name])
		values (@Menu_id1,'ESS Employee Goal Assessment Approval',@Temp_Form_ID_kpi,382,1,'Ess_EmployeeGoalSetting_Review_Approval.aspx','menu/process.png',0,'Employee Goal Assessment Approval','Appraisal3')
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Balance Score Card Setting' And Form_ID > 6500 and Form_ID < 6700) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 6700
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name])
		values(@Menu_id1, N'Balance Score Card Setting', 6518, 230, 1, N'HRMS/BalanceScoreCard.aspx', N'menu/company_structure.gif', 0, N'Balance Score Card Setting','Appraisal3')			
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Balance Score Card Evaluation' And Form_ID > 6500 and Form_ID < 6700) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 6700
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name])
		values(@Menu_id1, N'Balance Score Card Evaluation', 6518, 230, 1, N'HRMS/BalanceScoreCard_Review.aspx', N'menu/company_structure.gif', 0, N'Balance Score Card Evaluation','Appraisal3')			
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'ESS Balance Score Card Setting' And Form_ID > 7000 and Form_ID < 7500)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name])
		values (@Menu_id1,'ESS Balance Score Card Setting',@Temp_Form_ID_kpi,382,1,'ESS_BalanceScoreCard.aspx','menu/process.png',0,'Balance Score Card Setting','Appraisal3')
	end

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'ESS Balance Score Card Approval' And Form_ID > 7000 and Form_ID < 7500)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name])
		values (@Menu_id1,'ESS Balance Score Card Approval',@Temp_Form_ID_kpi,382,1,'ESS_BalanceScoreCard_Approval.aspx','menu/process.png',0,'Balance Score Card Approval','Appraisal3')
	end
	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'ESS Balance Score Card Review' And Form_ID > 7000 and Form_ID < 7500)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name])
		values (@Menu_id1,'ESS Balance Score Card Review',@Temp_Form_ID_kpi,382,1,'ESS_BalanceScoreCard_Review.aspx','menu/process.png',0,'Balance Score Card Review','Appraisal3')
	end

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'ESS Balance Score Card Review Approval' And Form_ID > 7000 and Form_ID < 7500)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name])
		values (@Menu_id1,'ESS Balance Score Card Review Approval',@Temp_Form_ID_kpi,382,1,'Ess_BalanceScoreCard_Review_Approval.aspx','menu/process.png',0,'Balance Score Card Review Approval','Appraisal3')
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Development Planning Template' And Form_ID > 6500 and Form_ID < 6700) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 6700
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name])
		values(@Menu_id1, N'Development Planning Template', 6518, 230, 1, N'HRMS/DevelopmentPlanning.aspx', N'menu/company_structure.gif', 0, N'Development Planning Template','Appraisal3')			
	end
	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Performance Improvement Plan' And Form_ID > 6500 and Form_ID < 6700) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 6700
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name])
		values(@Menu_id1, N'Performance Improvement Plan', 6518, 230, 1, N'HRMS/PerformanceImprovementPlan.aspx', N'menu/company_structure.gif', 0, N'Performance Improvement Plan','Appraisal3')			
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'ESS Development Planning Template' And Form_ID > 7000 and Form_ID < 7500)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name])
		values (@Menu_id1,'ESS Development Planning Template',@Temp_Form_ID_kpi,382,1,'Ess_DevelopmentPlanning.aspx','menu/process.png',0,'Development Planning Template','Appraisal3')
	end
	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'ESS Development Planning Template Approval' And Form_ID > 7000 and Form_ID < 7500)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name])
		values (@Menu_id1,'ESS Development Planning Template Approval',@Temp_Form_ID_kpi,382,1,'Ess_DevelopmentPlanning_Approval.aspx','menu/process.png',0,'Development Planning Template Approval','Appraisal3')
	end

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'ESS Performance Improvement Plan' And Form_ID > 7000 and Form_ID < 7500)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name])
		values (@Menu_id1,'ESS Performance Improvement Plan',@Temp_Form_ID_kpi,382,1,'ESS_PerformanceImprovementPlan.aspx','menu/process.png',0,'Performance Improvement Plan','Appraisal3')
	end
	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'ESS Performance Improvement Plan Approval' And Form_ID > 7000 and Form_ID < 7500)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name])
		values (@Menu_id1,'ESS Performance Improvement Plan Approval',@Temp_Form_ID_kpi,382,1,'ESS_PerformanceImprovementPlan_Approval.aspx','menu/process.png',0,'Performance Improvement Plan Approval','Appraisal3')
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Goal Assessment' And Form_ID > 6700 and Form_ID < 6999) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700 and Form_ID < 6999
		--declare @hrreport_id1 as numeric(18,0)
		select @hrreport_id1 = form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'HRMS Reports' And Form_ID > 6700 and Form_ID < 6999 
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
		values(@Menu_id1, N'Employee Goal Assessment', @hrreport_id1, 200, 1, null, null, 1, N'Employee Goal Assessment',12,'Appraisal3')			
	end

--added by sneha on 8 Aug 2016 --start


	Begin  -- #region Admin Setting Menu Start 


Declare @form_id_Admin as Numeric(18,0)
declare @Sort_Id as numeric(18,0)
declare @Sor_id_Check as numeric(18,0)

set @form_id_Admin = 0
--set @Sort_Id = @Sort_Id + 20
set @Sort_Id = 0
select @form_id_Admin = Form_id,@Sort_Id = sort_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Admin Settings'

set @Sor_id_Check =0
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Admin Setting')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Admin,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check
		where Form_Name = 'Admin Setting' 
	end

set @Sor_id_Check = @Sor_id_Check + 1	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Schedule Master')
	begin
	    update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Admin,
		Sort_ID = @Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Schedule (SQL Job) Master',
		Form_image_url = @Control_Pnl_Img
		where Form_Name = 'Schedule Master' 
	end	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'SMS Setting')
	begin
	    update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Admin,
		Sort_ID = @Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='SMS Setting'
		where Form_Name = 'SMS Setting' 
	end	
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'AX Mapping')
	begin
	    update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Admin,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='AX Mapping'
		where Form_Name = 'AX Mapping' 
	end	

if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'AX Mapping Slab Master')
	begin
	    update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Admin,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='AX Mapping Slab Master'
		where Form_Name = 'AX Mapping Slab Master' 
	end	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'IP Address Master')
	begin
	    update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Admin,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='IP Address Master'
		where Form_Name = 'IP Address Master' 
	end		
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Responsibility & Escalation')
	begin
	    update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Admin,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Responsibility & Escalation'
		where Form_Name = 'Responsibility & Escalation' 
	end

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Publish News Letters')
	begin
	    update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Admin,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='News Announcement',
		Form_image_url = @Control_Pnl_Img
		where Form_Name = 'Publish News Letters' 
	end	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Report Format Setting')
	begin
	    update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Admin,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Report Format Setting(Ess)',
		Form_image_url = @Control_Pnl_Img
		where Form_Name = 'Report Format Setting' 
	end		
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Directory Setting')  --Added By Jimit 01052019
	begin
	    update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Admin,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Employee Directory Setting',
		Form_image_url = @Control_Pnl_Img
		where Form_Name = 'Employee Directory Setting' 
	end	
				
End-- #region Admin Setting Menu End

	Begin --  #region Scheme Setting Menu Start

		Declare @form_id_Scheme as Numeric

		set @form_id_Scheme = 0
		set @Sor_id_Check = 0
		--set @Sort_Id = @Sort_Id + 20

		select @form_id_Scheme = Form_id,@Sort_Id = Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Scheme'

		set @Sor_id_Check = @Sor_id_Check + 1
		if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Scheme Master')
		begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Scheme,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Scheme Master',
		Form_Type = 1  ---Aded By Jimit 12062019
		where Form_Name = 'Scheme Master' 
		end

		set @Sor_id_Check = @Sor_id_Check + 1
		if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Scheme Detail')
		begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Scheme,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Scheme Detail' ,
		Form_Type = 1  ---Aded By Jimit 12062019
		where Form_Name = 'Scheme Detail' 
		end
	

	end  -- #region Scheme Setting Menu End


if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Privilege Setting')
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Privilege Setting',6001,6,1,'home.aspx',@Control_Pnl_Img,1,'Privilege Setting')
	end

	Begin --  #region Priviledge Setting Menu Start

		Declare @form_id_Priviledge as Numeric

		set @form_id_Priviledge = 0
		set @Sor_id_Check = 0
		--set @Sort_Id = @Sort_Id + 20

		select @form_id_Priviledge = Form_id,@Sort_Id = Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Privilege Setting'

		set @Sor_id_Check = @Sor_id_Check + 1
		if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Privilege Master')
		begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Priviledge,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Privilege Master' 
		where Form_Name = 'Privilege Master' 
		end

		set @Sor_id_Check = @Sor_id_Check + 1
		if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Cross Company Privilege')
		begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Priviledge,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Cross Company Privilege'
		where Form_Name = 'Cross Company Privilege' 
		end

	end  -- #region Priviledge Setting Menu End

	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Email Setting')
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Email Setting',6001,13,1,'home.aspx',@Control_Pnl_Img,1,'Email Setting')
	end	
	
		-- Added by rohit on 20042016
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Email Settings' And Form_ID > 6000 and Form_ID < 6500) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name])
		values(@Menu_id1, N'Email Settings', 6001, 13, 1, N'Email_Settings.aspx', @Control_Pnl_Img, 1, N'Email Configurations','Payroll')			
	end			
	-- ended by rohit on 20042016
	
	
	begin  -- #region Email Setting Menu Start

Declare @form_id_Email as Numeric
set @form_id_Email = 0
set @Sor_id_Check = 0
--set @Sort_Id = @Sort_Id + 20

select @form_id_Email = Form_id,@Sort_Id=Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Email Setting'

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Email Settings')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Email,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Email Configurations' ,
		Form_image_url = @Control_Pnl_Img
		where Form_Name = 'Email Settings' 
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Email Logs')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Email,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Email Logs' ,
		Form_image_url = @Control_Pnl_Img
		where Form_Name = 'Email Logs' 
	end
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Email News Letter')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Email,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Email News Letter' ,
		Form_image_url = @Control_Pnl_Img
		where Form_Name = 'Email News Letter' 
	end

End -- #region Email Setting Menu End


	Begin --  #region Job Master Menu Start

Declare @form_id_Job as Numeric

set @form_id_Job = 0
set @Sor_id_Check = 0
--set @Sort_Id = @Sort_Id + 20

select @form_id_Job = Form_id,@Sort_Id = Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Job Master'

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'State Master')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Job,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'State/City Master' 
		where Form_Name = 'State Master' 
	end

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Branch master')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Job,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Branch master' 
		where Form_Name = 'Branch master' 
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'SubBranch Master')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Job,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'subBranch Master' ,
		form_name='subBranch Master'
		where Form_Name = 'SubBranch Master' 
	end
	
	set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Department Master')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Job,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Department Master' 
		where Form_Name = 'Department Master' 
	end
	
	set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Designation Master')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Job,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Designation Master' 
		where Form_Name = 'Designation Master' 
	end	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Grade Master')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Job,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Grade Master' 
		where Form_Name = 'Grade Master' 
	end	

	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Shift Master')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Job,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Shift Master' 
		where Form_Name = 'Shift Master' 
	end		
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Category Master')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Job,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Category Master' 
		where Form_Name = 'Category Master' 
	end		
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Business Segment Master')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Job,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Business Segment Master' 
		where Form_Name = 'Business Segment Master' 
	end		
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Vertical Master')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Job,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Vertical Master' 
		where Form_Name = 'Vertical Master' 
	end		
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'SubVertical Master')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Job,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'SubVertical Master' 
		where Form_Name = 'SubVertical Master' 
	end		

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Attendance Reason Master')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Job,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Reason Master' 
		where Form_Name = 'Attendance Reason Master' 
	end	
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Attendance Reason Master')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Job,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Reason Master' 
		where Form_Name = 'Attendance Reason Master' 
	end				
	
end  -- #region Job master Menu End


	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Travel Master')
		begin
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
			values (@Menu_id1,'Travel Master',6012,54,1,'home.aspx',@Masters_Img,1,'Travel Master')
		end

begin  -- #region travel master Menu Start

Declare @form_id_travel as Numeric
set @form_id_travel = 0
set @Sor_id_Check = 0
--set @Sort_Id = @Sort_Id + 20

select @form_id_travel = Form_id,@Sort_Id=Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Travel Master'

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Expense Type Master')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_travel,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Expense Type Master' 
		where Form_Name = 'Expense Type Master' 
	end
		
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Travel Mode Master')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_travel,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Travel Mode Master' 
		where Form_Name = 'Travel Mode Master' 
	end
				
	
	
End -- #region travel Master Menu End


if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Statutory Master')
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Statutory Master',6012,55,1,'home.aspx',@Masters_Img,1,'Statutory Master')
	end	

begin  -- #region Statutory master Menu Start

Declare @form_id_Statutory as Numeric
set @form_id_Statutory = 0
set @Sor_id_Check = 0
--set @Sort_Id = @Sort_Id + 20

select @form_id_Statutory = Form_id,@Sort_Id=Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Statutory Master'

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Minimum Wages Master')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Statutory,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Minimum Wages Master' 
		where Form_Name = 'Minimum Wages Master' 
	end
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Skill Type Master')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Statutory,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Skill Type Master' 
		where Form_Name = 'Skill Type Master' 
	end	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Pay Scale Master')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Statutory,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Pay Scale Master' 
		where Form_Name = 'Pay Scale Master' 
	end	
	
	
End -- #region Statutory Master Menu End	


if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Other Master')
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Other Master',6012,56,1,'home.aspx',@Masters_Img,1,'Other Master')
	end
	

begin  -- #region other master Menu Start

Declare @form_id_other as Numeric
set @form_id_Other = 0
set @Sor_id_Check = 0
--set @Sort_Id = @Sort_Id + 20

select @form_id_other = Form_id,@Sort_Id=Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Other Master'

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Country Master')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Other,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Country Master' 
		where Form_Name = 'Country Master' 
	end
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Cost Center Master')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Other,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Cost Center Master' 
		where Form_Name = 'Cost Center Master' 
	end	

set @Sor_id_Check = @Sor_id_Check + 1	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Insurance/Medical Master')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Other,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Insurance/Medical Master' 
		where Form_Name = 'Insurance/Medical Master' 
	end	
	
set @Sor_id_Check = @Sor_id_Check + 1	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Policy Document Master')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Other,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Organization Policy' 
		where Form_Name = 'Policy Document Master' 
	end		
	
set @Sor_id_Check = @Sor_id_Check + 1	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Project Master')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Other,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Project Master' 
		where Form_Name = 'Project Master' 
	end		
	
set @Sor_id_Check = @Sor_id_Check + 1	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Question Master')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Other,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Question Master' 
		where Form_Name = 'Question Master' 
	end			
	
set @Sor_id_Check = @Sor_id_Check + 1	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Salary Cycle Master')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Other,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Salary Cycle Master' 
		where Form_Name = 'Salary Cycle Master' 
	end		
	
set @Sor_id_Check = @Sor_id_Check + 1	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Source Master')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Other,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Source Master' 
		where Form_Name = 'Source Master' 
	end	
	
set @Sor_id_Check = @Sor_id_Check + 1	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Strength Master')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Other,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Employee Strength Master' 
		where Form_Name = 'Employee Strength Master' 
	end	

set @Sor_id_Check = @Sor_id_Check + 1	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Type Master')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Other,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Employee Type Master' 
		where Form_Name = 'Employee Type Master' 
	end	



set @Sor_id_Check = @Sor_id_Check + 1	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Document Master')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Other,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Document Master' 
		where Form_Name = 'Document Master' 
	end	
	
set @Sor_id_Check = @Sor_id_Check + 1	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Abstract Report Master')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Other,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Abstract Report Master' 
		where Form_Name = 'Abstract Report Master' 
	end		

-- Added by Prakash Patel 03042018 ---
	SET @Sor_id_Check = @Sor_id_Check + 1	

	IF EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  FORM_NAME = 'GEO Location Master')
		BEGIN
			UPDATE T0000_DEFAULT_FORM 
			SET UNDER_FORM_ID = @FORM_ID_OTHER,SORT_ID=@SORT_ID,SORT_ID_CHECK=@SOR_ID_CHECK,ALIAS = 'GEO Location Master - Assign' 
			WHERE FORM_NAME = 'GEO Location Master' 
		END		
	ELSE
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000 and Form_ID < 6500
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
			VALUES (@Menu_id1,'GEO Location Master',@form_id_other,56,1,'Master_Mobile_Geo_Location.aspx',@Masters_Img,1,'GEO Location Master - Assign')
		END
-- Added by Prakash Patel 03042018 ---
	
End 


-- #region other master Menu End

----Start--Ankit 08022016

	IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Trainee/Probation')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000 AND Form_ID < 6500
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [ALIAS])
			VALUES (@Menu_id1,'Trainee/Probation',6012,57,1,'home.aspx',@Masters_Img,1,'Trainee/Probation')
		END

	IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Score Master')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000 AND Form_ID < 6500
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [ALIAS],[Sort_Id_Check])
			VALUES (@Menu_id1,'Score Master',6257,57,1,'Master_Rating.aspx',@Masters_Img,1,'Score Master',2)
		END
	
	IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Attribute Skill Assignment')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000 AND Form_ID < 6500
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [ALIAS],[Sort_Id_Check])
			VALUES (@Menu_id1,'Attribute Skill Assignment',6257,57,1,'Attribute_Skill_Assignment.aspx',@Masters_Img,1,'Attribute Skill Assignment',2)
		END
	
	BEGIN	--# Trainee/Probation Menu Start
		SET @form_id_other = 0
		set @form_id_Other = 0
		set @Sor_id_Check = 0

		select @form_id_other = Form_id,@Sor_id_Check=Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Trainee/Probation'

		set @Sor_id_Check = @Sor_id_Check + 1
		if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Skill Master')
			begin
				update T0000_DEFAULT_FORM 
				set Under_Form_ID = @form_id_other,
				Sort_ID=@Sort_Id,
				Sort_Id_Check=@Sor_id_Check,
				alias = 'Skill Master' 
				where Form_Name = 'Skill Master' 
			end
		
		set @Sor_id_Check = @Sor_id_Check + 1
		if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Score Master')
			begin
				update T0000_DEFAULT_FORM 
				set Under_Form_ID = @form_id_other,
				Sort_ID=@Sort_Id,
				Sort_Id_Check=@Sor_id_Check,
				alias = 'Score Master' 
				where Form_Name = 'Score Master' 
			end
		
		set @Sor_id_Check = @Sor_id_Check + 1
		if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Attribute Skill Assignment')
			begin
				update T0000_DEFAULT_FORM 
				set Under_Form_ID = @form_id_other,
				Sort_ID=@Sort_Id,
				Sort_Id_Check=@Sor_id_Check,
				alias = 'Attribute Skill Assignment' 
				where Form_Name = 'Attribute Skill Assignment' 
			end
		
	END	--# Trainee/Probation Menu End
	
----End--Trainee/Probation --Ankit 08022016



---Incentive Menu Start 20072017 Added By Rajput
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Incentive')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000 AND Form_ID < 6500
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [ALIAS])
			VALUES (@Menu_id1,'Incentive',6012,58,1,'home.aspx',@Masters_Img,1,'Incentive')
		END
	
			
	IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Parameter Template')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000 AND Form_ID < 6500
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [ALIAS],[Sort_Id_Check])
			VALUES (@Menu_id1,'Parameter Template',6257,57,1,'parameter_master.aspx',@Masters_Img,1,'Parameter Template',2)
		END
		
	IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Incentive Scheme')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000 AND Form_ID < 6500
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [ALIAS],[Sort_Id_Check])
			VALUES (@Menu_id1,'Incentive Scheme',6257,57,1,'incentive_scheme.aspx',@Masters_Img,1,'Incentive Scheme',2)
		END
	IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Incentive Template')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000 AND Form_ID < 6500
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [ALIAS],[Sort_Id_Check])
			VALUES (@Menu_id1,'Incentive Template',6257,57,1,'incentive_master.aspx',@Masters_Img,1,'Incentive Template',2)
		END

	BEGIN	--# Incentive Menu Start
		SET @form_id_other = 0
		set @form_id_Other = 0
		set @Sor_id_Check = 0

		select @form_id_other = Form_id,@Sor_id_Check=Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Incentive'

		set @Sor_id_Check = @Sor_id_Check + 1
		if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Parameter Template')
			begin
				update T0000_DEFAULT_FORM 
				set Under_Form_ID = @form_id_other,
				Sort_ID=@Sort_Id,
				Sort_Id_Check=@Sor_id_Check,
				alias = 'Parameter Template' 
				where Form_Name = 'Parameter Template' 
			end
		
		set @Sor_id_Check = @Sor_id_Check + 1
		if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Incentive Template')
			begin
				update T0000_DEFAULT_FORM 
				set Under_Form_ID = @form_id_other,
				Sort_ID=@Sort_Id,
				Sort_Id_Check=@Sor_id_Check,
				alias = 'Incentive Template' 
				where Form_Name = 'Incentive Template' 
			end
				
		set @Sor_id_Check = @Sor_id_Check + 1
		if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Incentive Scheme')
			begin
				update T0000_DEFAULT_FORM 
				set Under_Form_ID = @form_id_other,
				Sort_ID=@Sort_Id,
				Sort_Id_Check=@Sor_id_Check,
				alias = 'Incentive Scheme' 
				where Form_Name = 'Incentive Scheme' 
			end
		
		
		
	END
	--# Incentive Menu End



begin  -- #region increment Menu Start

Declare @form_id_increment as Numeric
set @form_id_increment = 0
set @Sor_id_Check = 0
--set @Sort_Id = @Sort_Id + 20

select @form_id_increment = Form_id,@Sort_Id=Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee-Increment'

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Gradewise Allowance')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_increment,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Gradewise Allowance' 
		where Form_Name = 'Gradewise Allowance' 
	end
	
	
End -- #region increment Menu End	


begin  -- #region shift Menu Start

Declare @form_id_Shift as Numeric
set @form_id_Shift = 0
set @Sor_id_Check = 0
--set @Sort_Id = @Sort_Id + 20

select @form_id_Shift = Form_id,@Sort_Id=Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Shift'

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Roster' and Form_ID>6000 and Form_ID<7000)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Shift,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Roster' 
		where Form_Name = 'Roster' and Form_ID>6000 and Form_ID<7000 
	end

End -- #region shift Menu End	

if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Allowance/Reimbursement Approval' and form_id < 7000)
	begin
		update T0000_DEFAULT_FORM 
		set alias = 'Optional Allowance Approval' 
		where Form_Name = 'Allowance/Reimbursement Approval' and form_id<7000
	end


if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Privileges/Scheme Assign')
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Privileges/Scheme Assign',6042,79,1,'home.aspx',@Employee_Img,1,'Privileges/Scheme Assign')
	end	


begin  -- #region Scheme Assign Menu Start

Declare @form_id_Scheme_Assign as Numeric
set @form_id_Scheme_Assign = 0
set @Sor_id_Check = 0
--set @Sort_Id = @Sort_Id + 20

select @form_id_Scheme_Assign = Form_id,@Sort_Id=Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Privileges/Scheme Assign'

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Privileges' and Form_ID>6000 and Form_ID<7000)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Scheme_Assign,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Employee Privileges' 
		where Form_Name = 'Employee Privileges' and Form_ID>6000 and Form_ID<7000 
	end



set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Privileges' and Form_ID>6000 and Form_ID<7000)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Scheme_Assign,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Employee Privileges' 
		where Form_Name = 'Employee Privileges' and Form_ID>6000 and Form_ID<7000 
	end
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Schemes' and Form_ID>6000 and Form_ID<7000)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Scheme_Assign,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Employee Schemes' 
		where Form_Name = 'Employee Schemes' and Form_ID>6000 and Form_ID<7000 
	end
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Reporting Manager' and Form_ID>6000 and Form_ID<7000)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Scheme_Assign,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Reporting Manager' 
		where Form_Name = 'Reporting Manager' and Form_ID>6000 and Form_ID<7000 
	end		
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Salary Cycle Transfer' and Form_ID>6000 and Form_ID<7000)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Scheme_Assign,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Salary Cycle Transfer' 
		where Form_Name = 'Salary Cycle Transfer' and Form_ID>6000 and Form_ID<7000 
	end		

End -- #region Scheme Assign Menu End	


begin  -- #region leave Menu Start

Declare @form_id_leave as Numeric
set @form_id_leave = 0
set @Sor_id_Check = 0
--set @Sort_Id = @Sort_Id + 20

select @form_id_leave = Form_id,@Sort_Id=Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Leave' and form_id>6000 and form_id<7000

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Optional Holiday Approval' and Form_ID>6000 and Form_ID<7000)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_leave,
		Sort_ID=102,
		Sort_Id_Check=@Sor_id_Check,
		Form_Image_url =@Leave_Img ,
		alias = 'Optional Holiday Approval' 
		where Form_Name = 'Optional Holiday Approval' and Form_ID>6000 and Form_ID<7000 
	end




End -- #region Leave Menu End	


begin  -- #region travel Menu Start

Declare @form_id_travel_Admin as Numeric
set @form_id_travel_Admin = 0
set @Sor_id_Check = 0
--set @Sort_Id = @Sort_Id + 20

select @form_id_travel_Admin = Form_id,@Sort_Id=Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Travel' and form_id>6000 and form_id<7000

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Travel Applications' and Form_ID>6000 and Form_ID<7000)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_travel_Admin,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Travel Application' 
		where Form_Name = 'Travel Applications' and Form_ID>6000 and Form_ID<7000 
	end
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Travel Approval' and Form_ID>6000 and Form_ID<7000)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_travel_Admin,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Travel Approval' 
		where Form_Name = 'Travel Approval' and Form_ID>6000 and Form_ID<7000 
	end

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Travel Approval - Help Desk' and Form_ID>6000 and Form_ID<7000)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_travel_Admin,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Travel Approval - Help Desk' 
		where Form_Name = 'Travel Approval - Help Desk' and Form_ID>6000 and Form_ID<7000 
	end
	
	set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Travel Settlement Application' and Form_ID>6000 and Form_ID<7000)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_travel_Admin,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Travel Settlement Application' 
		where Form_Name = 'Travel Settlement Application' and Form_ID>6000 and Form_ID<7000 
	end	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Travel Settlement Approval' and Form_ID>6000 and Form_ID<7000)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_travel_Admin,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Travel Settlement Approval' 
		where Form_Name = 'Travel Settlement Approval' and Form_ID>6000 and Form_ID<7000 
	end		

End -- #region traavel Menu End


begin  -- #region Salary Menu Start

Declare @form_id_Salary as Numeric
set @form_id_Salary = 0
set @Sor_id_Check = 0
--set @Sort_Id = @Sort_Id + 20

select @form_id_Salary = Form_id,@Sort_Id=Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Salary' and form_id>6000 and form_id<7000

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Monthly Salary' and Form_ID>6000 and Form_ID<7000)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Salary,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Monthly Salary' 
		where Form_Name = 'Monthly Salary' and Form_ID>6000 and Form_ID<7000 
	end

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Manually Salary' and Form_ID>6000 and Form_ID<7000)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Salary,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Manually Salary' 
		where Form_Name = 'Manually Salary' and Form_ID>6000 and Form_ID<7000 
	end
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Salary Daily' and Form_ID>6000 and Form_ID<7000)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Salary,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Salary Daily' 
		where Form_Name = 'Salary Daily' and Form_ID>6000 and Form_ID<7000 
	end
	


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Reverse Salary' and Form_ID>6000 and Form_ID<7000)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Salary,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Reverse Salary' 
		where Form_Name = 'Reverse Salary' and Form_ID>6000 and Form_ID<7000 
	end

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Salary Settlement' and Form_ID>6000 and Form_ID<7000)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Salary,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Salary Settlement' 
		where Form_Name = 'Salary Settlement' and Form_ID>6000 and Form_ID<7000 
	end


End -- #region Salary Menu End	




if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Attendance Regularization')
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Attendance Regularization',7001,305,1,'Employee_Attendance.aspx',@Employee_Img,1,'Attendance Regularization')
	end



begin  -- #region Employee Ess Menu Start

Declare @form_id_Employee as Numeric
set @form_id_Employee = 0
set @Sor_id_Check = 0
--set @Sort_Id = @Sort_Id + 20

select @form_id_Employee = Form_id,@Sort_Id=Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee' and form_id>7000

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Change Password Ess ' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Employee,
		Sort_ID=303,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Change Password' 
		where Form_Name = 'Change Password Ess ' and Form_ID>7000 
	end
--added by sneha on 30 sep 201- for hrms -ess menu
--#region Appraisal-1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Appraisal Detail' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Module_name='Appraisal1'
		where Form_Name = 'Appraisal Detail' and Form_ID>7000 
	end
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Appraisal Process Data' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Module_name='Appraisal1'
		where Form_Name = 'Employee Appraisal Process Data' and Form_ID>7000 
	end
--added on 11 dec 2015 sneha --start
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_292' And Form_ID > 9000 and Form_ID < 10000 )
	begin
		update T0000_DEFAULT_FORM 
		set Module_name='Appraisal1'
		where Form_Name = 'TD_Home_ESS_292' And Form_ID > 9000 and Form_ID < 10000
	end
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_293' And Form_ID > 9000 and Form_ID < 10000 )
	begin
		update T0000_DEFAULT_FORM 
		set Module_name='Appraisal1'
		where Form_Name = 'TD_Home_ESS_293' And Form_ID > 9000 and Form_ID < 10000
	end
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_Admin_62' And Form_ID > 9000 and Form_ID < 10000 )
	begin
		update T0000_DEFAULT_FORM 
		set Module_name='Appraisal1'
		where Form_Name = 'TD_Home_Admin_62' And Form_ID > 9000 and Form_ID < 10000
	end
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_Admin_63' And Form_ID > 9000 and Form_ID < 10000 )
	begin
		update T0000_DEFAULT_FORM 
		set Module_name='Appraisal1'
		where Form_Name = 'TD_Home_Admin_63' And Form_ID > 9000 and Form_ID < 10000
	end
	--added on 11 dec 2015 sneha --end
--#endregion
--#region Appraisal-2
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Assessment' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Module_name='Appraisal2'
		where Form_Name = 'Employee Assessment' and Form_ID>7000 
	end
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Performance Assessment' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Module_name='Appraisal2'
		where Form_Name = 'Employee Performance Assessment' and Form_ID>7000 
	end
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'My Performance' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Module_name='Appraisal2'
		where Form_Name = 'My Performance' and Form_ID>7000 
	end
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Appraisal Finalization' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Module_name='Appraisal2'
		where Form_Name = 'Appraisal Finalization' and Form_ID>7000 
	end
---added on 11 dec 2015 sneha --start
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_294' And Form_ID > 9000 and Form_ID < 10000 )
	begin
		update T0000_DEFAULT_FORM 
		set Module_name='Appraisal2'
		where Form_Name = 'TD_Home_ESS_294' And Form_ID > 9000 and Form_ID < 10000
	end
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_295' And Form_ID > 9000 and Form_ID < 10000 )
	begin
		update T0000_DEFAULT_FORM 
		set Module_name='Appraisal2'
		where Form_Name = 'TD_Home_ESS_295' And Form_ID > 9000 and Form_ID < 10000
	end	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_296' And Form_ID > 9000 and Form_ID < 10000 )
	begin
		update T0000_DEFAULT_FORM 
		set Module_name='Appraisal2'
		where Form_Name = 'TD_Home_ESS_296' And Form_ID > 9000 and Form_ID < 10000 
	end	
---added on 11 dec 2015 sneha --end
--#endregion
--#region Appraisal-3
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'KPI Objectives' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Module_name='Appraisal3'
		where Form_Name = 'KPI Objectives' and Form_ID>7000 
	end
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee KPI Objectives' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Module_name='Appraisal3'
		where Form_Name = 'Employee KPI Objectives' and Form_ID>7000 
	end
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'KPI Apparisal Form' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Module_name='Appraisal3'
		where Form_Name = 'KPI Apparisal Form' and Form_ID>7000 
	end
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee KPI Apparisal Form' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Module_name='Appraisal3'
		where Form_Name = 'Employee KPI Apparisal Form' and Form_ID>7000 
	end
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'KPIPMS Final Evaluation' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Module_name='Appraisal3'
		where Form_Name = 'KPIPMS Final Evaluation' and Form_ID>7000 
	end
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee KPIPMS Final Evaluation' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Module_name='Appraisal3'
		where Form_Name = 'Employee KPIPMS Final Evaluation' and Form_ID>7000 
	end
--added on 11 dec 2015 - sneha --start
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_333' And Form_ID > 9000 and Form_ID < 10000 )
	begin
		update T0000_DEFAULT_FORM 
		set Module_name='Appraisal3'
		where Form_Name = 'TD_Home_ESS_333' And Form_ID > 9000 and Form_ID < 10000
	end	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_334' And Form_ID > 9000 and Form_ID < 10000 )
	begin
		update T0000_DEFAULT_FORM 
		set Module_name='Appraisal3'
		where Form_Name = 'TD_Home_ESS_334' And Form_ID > 9000 and Form_ID < 10000
	end	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_335' And Form_ID > 9000 and Form_ID < 10000 )
	begin
		update T0000_DEFAULT_FORM 
		set Module_name='Appraisal3'
		where Form_Name = 'TD_Home_ESS_335' And Form_ID > 9000 and Form_ID < 10000
	end	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_336' And Form_ID > 9000 and Form_ID < 10000 )
	begin
		update T0000_DEFAULT_FORM 
		set Module_name='Appraisal3'
		where Form_Name = 'TD_Home_ESS_336' And Form_ID > 9000 and Form_ID < 10000
	end	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_337' And Form_ID > 9000 and Form_ID < 10000 )
	begin
		update T0000_DEFAULT_FORM 
		set Module_name='Appraisal3'
		where Form_Name = 'TD_Home_ESS_337' And Form_ID > 9000 and Form_ID < 10000
	end	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_338' and Form_ID>9000 )
	begin
		update T0000_DEFAULT_FORM 
		set Module_name='Appraisal3'
		where Form_Name = 'TD_Home_ESS_338' And Form_ID > 9000 and Form_ID < 10000 
	end	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_339' And Form_ID > 9000 and Form_ID < 10000 )
	begin
		update T0000_DEFAULT_FORM 
		set Module_name='Appraisal3'
		where Form_Name = 'TD_Home_ESS_339' And Form_ID > 9000 and Form_ID < 10000
	end	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_340' And Form_ID > 9000 and Form_ID < 10000 )
	begin
		update T0000_DEFAULT_FORM 
		set Module_name='Appraisal3'
		where Form_Name = 'TD_Home_ESS_340' And Form_ID > 9000 and Form_ID < 10000 
	end	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_344' And Form_ID > 9000 and Form_ID < 10000 )
	begin
		update T0000_DEFAULT_FORM 
		set Module_name='Appraisal3'
		where Form_Name = 'TD_Home_ESS_344' And Form_ID > 9000 and Form_ID < 10000
	end	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_346' And Form_ID > 9000 and Form_ID < 10000 )
	begin
		update T0000_DEFAULT_FORM 
		set Module_name='Appraisal3'
		where Form_Name = 'TD_Home_ESS_346' And Form_ID > 9000 and Form_ID < 10000 
	end	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_347' And Form_ID > 9000 and Form_ID < 10000 )
	begin
		update T0000_DEFAULT_FORM 
		set Module_name='Appraisal3'
		where Form_Name = 'TD_Home_ESS_347' And Form_ID > 9000 and Form_ID < 10000
	end	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_348' And Form_ID > 9000 and Form_ID < 10000 )
	begin
		update T0000_DEFAULT_FORM 
		set Module_name='Appraisal3'
		where Form_Name = 'TD_Home_ESS_348' And Form_ID > 9000 and Form_ID < 10000 
	end	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_349' And Form_ID > 9000 and Form_ID < 10000 )
	begin
		update T0000_DEFAULT_FORM 
		set Module_name='Appraisal3'
		where Form_Name = 'TD_Home_ESS_349' And Form_ID > 9000 and Form_ID < 10000 
	end	
	--added on 11 dec 2015 - sneha --end
--#endregion
End -- #region Employee Ess Menu End	


if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Time sheets')
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Time sheets',7001,306,1,'home.aspx',@Employee_Img,1,'Time sheets')
	end	

begin  -- #region time sheet Menu Start

Declare @form_id_Time as Numeric
set @form_id_Employee = 0
set @Sor_id_Check = 0
--set @Sort_Id = @Sort_Id + 20

select @form_id_Time = Form_id,@Sort_Id=Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Time sheets' and form_id>7000

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'ESS TimeSheet Entry' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Time,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'TimeSheet' 
		where Form_Name = 'ESS TimeSheet Entry' and Form_ID>7000 
	end

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'ESS TimeSheet Detail' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Time,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'TimeSheet Detail' 
		where Form_Name = 'ESS TimeSheet Detail' and Form_ID>7000 
	end


End -- #region time sheet Menu End	

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Change Request')
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Change Request',7001,307,1,'home.aspx',@Employee_Img,1,'Change Request')
	end			
	
begin  -- #region Change request Menu Start

Declare @form_id_Request as Numeric
set @form_id_Employee = 0
set @Sor_id_Check = 0
--set @Sort_Id = @Sort_Id + 20

select @form_id_Request = Form_id,@Sort_Id=Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Change Request' and form_id>7000

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Change Request Application' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Request,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Change Request Application' 
		where Form_Name = 'Change Request Application' and Form_ID>7000 
	end

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Change Request Approval' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Request,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Change Request Approval' 
		where Form_Name = 'Change Request Approval' and Form_ID>7000 
	end


End -- #region Change request Menu End	

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Optional Holiday' and Form_id>7000)
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Optional Holiday',7005,313,1,'home.aspx',@Leave_Img,1,'Optional Holiday')
	end


begin  -- #region Change request Menu Start

Declare @form_id_leave_Ess as Numeric
set @form_id_leave_Ess = 0
set @Sor_id_Check = 0
--set @Sort_Id = @Sort_Id + 20

select @form_id_leave_Ess = Form_id,@Sort_Id=Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Optional Holiday' and form_id>7000

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Optional Holiday Application' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_leave_Ess,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		form_image_url =@Leave_Img,
		alias = 'Optional Holiday Application' 
		where Form_Name = 'Optional Holiday Application' and Form_ID>7000 
	end

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Optional HO Approval Manager' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_leave_Ess,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		form_image_url =@Leave_Img,
		alias = 'Optional Holiday Approval' 
		where Form_Name = 'Optional HO Approval Manager' and Form_ID>7000 
	end


End -- #region Change request Menu End	


if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Leave Approvals' and Form_id>7000)
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Leave Approvals',7005,310,1,'home.aspx',@Leave_Img,1,'Leave Approval')
	end

begin  -- #region leave Menu Start

Declare @form_id_leave_Appr_Ess as Numeric
set @form_id_leave_Appr_Ess = 0
set @Sor_id_Check = 0
--set @Sort_Id = @Sort_Id + 20

select @form_id_leave_Appr_Ess = Form_id,@Sort_Id=Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Leave Approvals' and form_id>7000

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Leave Approval' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_leave_Appr_Ess,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Leave Approval' 
		where Form_Name = 'Leave Approval' and Form_ID>7000 
	end

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Admin Leave Approval' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_leave_Appr_Ess,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Admin Leave Approval' 
		where Form_Name = 'Admin Leave Approval' and Form_ID>7000 
	end
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Leave Status' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_leave_Appr_Ess,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Leave Status' 
		where Form_Name = 'Leave Status' and Form_ID>7000 
	end	
	


End -- #region leave  Menu End	


begin  -- #region Comp off Menu Start

Declare @form_id_Compoff as Numeric
set @form_id_Compoff = 0
set @Sor_id_Check = 0
--set @Sort_Id = @Sort_Id + 20

select @form_id_Compoff = Form_id,@Sort_Id=Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Comp Off' and form_id>7000

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Comp Off Application' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Compoff,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Comp Off Application' 
		where Form_Name = 'Comp Off Application' and Form_ID>7000 
	end

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Comp Off Approval' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Compoff,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Comp Off Approval' 
		where Form_Name = 'Comp Off Approval' and Form_ID>7000 
	end
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Pre comp-Off Application' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Compoff,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Pre comp-Off Application' 
		where Form_Name = 'Pre comp-Off Application' and Form_ID>7000 
	end	
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Pre comp-Off Approval' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Compoff,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Pre comp-Off Approval' 
		where Form_Name = 'Pre comp-Off Approval' and Form_ID>7000 
	end		


End -- #region compoff  Menu End	



if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Leave Cancellations' and Form_id>7000)
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Leave Cancellations',7005,311,1,'home.aspx',@Leave_Img,1,'Leave Cancellations')
	end

begin  -- #region leave cancel Menu Start

Declare @form_id_leave_cancel as Numeric
set @form_id_leave_cancel = 0
set @Sor_id_Check = 0
--set @Sort_Id = @Sort_Id + 20

select @form_id_leave_cancel = Form_id,@Sort_Id=Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Leave Cancellations' and form_id>7000

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Leave Cancellation' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_leave_cancel,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Leave Cancellation' 
		where Form_Name = 'Leave Cancellation' and Form_ID>7000 
	end
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Leave Cancellation Approval Member' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_leave_cancel,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Leave Cancellation Approval' 
		where Form_Name = 'Leave Cancellation Approval Member' and Form_ID>7000 
	end	

End -- #region leave cancel  Menu End	


begin  -- #region reim Menu Start

Declare @form_id_reim as Numeric
set @form_id_reim = 0
set @Sor_id_Check = 0
--set @Sort_Id = @Sort_Id + 20

select @form_id_reim = Form_id,@Sort_Id=Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Reim/Claim' and form_id>7000

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Reim/Claim' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set alias = 'Reimbursement' 
		where Form_Name = 'Reim/Claim' and Form_ID>7000 
	end

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Reim/Claim Application' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_reim,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Reimbursement Application' 
		where Form_Name = 'Reim/Claim Application' and Form_ID>7000 
	end	
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Reim/Claim Approval' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_reim,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Reimbursement Approval' 
		where Form_Name = 'Reim/Claim Approval' and Form_ID>7000 
	end		


End -- #region reim  Menu End	

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Claims' and Form_id>7000)
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Claims',7013,321,1,'home.aspx',@Loan_Claim_Img,1,'Claims')
	end

begin  -- #region claim Menu Start

Declare @form_id_leave_Claims as Numeric
set @form_id_leave_Claims = 0
set @Sor_id_Check = 0
--set @Sort_Id = @Sort_Id + 20

select @form_id_leave_Claims = Form_id,@Sort_Id=Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Claims' and form_id>7000

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Claim Application' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_leave_Claims,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Claim Application' 
		where Form_Name = 'Claim Application' and Form_ID>7000 
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Claim_Approval_Superior' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_leave_Claims,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Claim Approval' 
		where Form_Name = 'Claim_Approval_Superior' and Form_ID>7000 
	end
	
	set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Claim Status' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_leave_Claims,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Claim Status' 
		where Form_Name = 'Claim Status' and Form_ID>7000 
	end

End -- #region claim  Menu End	

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Optional Allowance' and Form_id>7000)
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Optional Allowance',7013,323,1,'home.aspx',@Loan_Claim_Img,1,'Optional Allowance')
	end

begin  -- #region optinal Menu Start

Declare @form_id_leave_optinal as Numeric
set @form_id_leave_optinal = 0
set @Sor_id_Check = 0
--set @Sort_Id = @Sort_Id + 20

select @form_id_leave_optinal = Form_id,@Sort_Id=Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Optional Allowance' and form_id>7000

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Allowance/Reimbursement Application' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_leave_optinal,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Optional Allowance Application' 
		where Form_Name = 'Allowance/Reimbursement Application' and Form_ID>7000 
	end
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Allowance/Reimbursement Approval' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_leave_optinal,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Optional Allowance Approval' 
		where Form_Name = 'Allowance/Reimbursement Approval' and Form_ID>7000 
	end	
	
End -- #region optinal  Menu End	


begin  -- #region travel Menu Start

Declare @form_id_travel_ess as Numeric
set @form_id_travel_ess = 0
set @Sor_id_Check = 0
--set @Sort_Id = @Sort_Id + 20

if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Travel Details' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Sort_ID=325,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Travel Details' 
		where Form_Name = 'Travel Details' and Form_ID>7000 
	end

select @form_id_travel_ess = Form_id,@Sort_Id=Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Travel Details' and form_id>7000

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Travel Application' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_travel_ess,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Travel Application' 
		where Form_Name = 'Travel Application' and Form_ID>7000 
	end
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Travel Approvals ' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_travel_ess,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Travel Approvals' 
		where Form_Name = 'Travel Approvals ' and Form_ID>7000 
	end
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Travel Settlement' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_travel_ess,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Travel Settlement' 
		where Form_Name = 'Travel Settlement' and Form_ID>7000 
	end		

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Travel Settlement Approvals' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_travel_ess,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Travel Settlement Approvals' 
		where Form_Name = 'Travel Settlement Approvals' and Form_ID>7000 
	end			
	
End -- #region optinal  Menu End	


if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Member Shift' and Form_id>7000)
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Member Shift',7023,343,1,'home.aspx',@Employee_Img,1,'Member Shift')
	end

begin  -- #region member shift Menu Start

Declare @form_id_member_shift as Numeric
set @form_id_member_shift = 0
set @Sor_id_Check = 0
--set @Sort_Id = @Sort_Id + 20

select @form_id_member_shift = Form_id,@Sort_Id=Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Member Shift' and form_id>7000

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Shift Change' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_member_shift,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		Form_Image_url =@Masters_Img,
		alias = 'Shift Change' 
		where Form_Name = 'Shift Change' and  Form_ID > 7000 
	end

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Shift Rotation Superior' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_member_shift,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		Form_Image_url =@Masters_Img,
		--alias = 'Employee Shift Rotation' 
		alias = 'Employee Shift Import' --Commented and Changed by SUmit on15062016
		where Form_Name = 'Employee Shift Rotation Superior' and  Form_ID>7000 
	end
		
	
	
End -- #region member shift Menu End	



begin  -- #region member shift Menu Start

Declare @form_id_Oraganogram as Numeric
set @form_id_Oraganogram = 0
set @Sor_id_Check = 0
--set @Sort_Id = @Sort_Id + 20

select @form_id_Oraganogram = Form_id,@Sort_Id=Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Organogram' and form_id>7000

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Organization Organogram' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Oraganogram,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Organization Organogram' 
		where Form_Name = 'Organization Organogram' and  Form_ID > 7000 
	end
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Organogram' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Oraganogram,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Employee Organogram' 
		where Form_Name = 'Employee Organogram' and  Form_ID > 7000 
	end	
	
End -- #region member shift Menu End		

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Recruitment' and Form_id>7000)
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Recruitment',7029,373,1,'home.aspx',@HR_Img,1,'Recruitment')
	end

begin  -- #region member recruitment Menu Start

Declare @form_id_recruitment as Numeric
set @form_id_recruitment = 0
set @Sor_id_Check = 0
--set @Sort_Id = @Sort_Id + 20

select @form_id_recruitment = Form_id,@Sort_Id=Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Recruitment' and form_id>7000

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Recruitment Request' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_recruitment,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Recruitment Application' 
		where Form_Name = 'Recruitment Request' and  Form_ID > 7000 
	end
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Recruitment Request Approval' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_recruitment,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Recruitment Approval' 
		where Form_Name = 'Recruitment Request Approval' and  Form_ID > 7000 
	end	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Resume For Screening' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_recruitment,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Resume For Screening' 
		where Form_Name = 'Resume For Screening' and  Form_ID > 7000 
	end	
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Interview Process' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_recruitment,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Interview Process' 
		where Form_Name = 'Interview Process' and  Form_ID > 7000 
	end		

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Candidate Approval' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_recruitment,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Candidate Approval' 
		where Form_Name = 'Candidate Approval' and  Form_ID > 7000 
	end		

	
End -- #region recruitment Menu End		

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Training' and Form_id>7000)
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Training',7029,374,1,'home.aspx',@HR_Img,1,'Training')
	end

begin  -- #region Training Menu Start

Declare @form_id_Training as Numeric
set @form_id_Training = 0
set @Sor_id_Check = 0
--set @Sort_Id = @Sort_Id + 20

select @form_id_Training = Form_id,@Sort_Id=Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Training' and form_id>7000

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Training Application' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Training,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Training Application' 
		where Form_Name = 'Training Application' and  Form_ID > 7000 
	end
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Training Plan' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Training,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Training Plan' 
		where Form_Name = 'Training Plan' and  Form_ID > 7000 
	end
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Training History' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Training,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Training History' 
		where Form_Name = 'Training History' and  Form_ID > 7000 
	end	
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Training Chart' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Training,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Training Chart' 
		where Form_Name = 'Training Chart' and  Form_ID > 7000 
	end	
	
End -- #region recruitment Menu End		

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Appraisal' and Form_id>7000)
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Appraisal',7029,380,1,'home.aspx',@HR_Img,1,'Appraisal')
	end

begin  -- #region appraisal Menu Start

Declare @form_id_Appraisal as Numeric
set @form_id_Appraisal = 0
set @Sor_id_Check = 0
--set @Sort_Id = @Sort_Id + 20

select @form_id_Appraisal = Form_id,@Sort_Id=Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Appraisal' and form_id>7000

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Appraisal Detail' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Appraisal,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Appraisal Detail' 
		where Form_Name = 'Appraisal Detail' and  Form_ID > 7000 
	end
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Appraisal Process Data' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Appraisal,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Employee Appraisal Process Data' 
		where Form_Name = 'Employee Appraisal Process Data' and  Form_ID > 7000 
	end	
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Assessment' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Appraisal,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Employee Assessment' 
		where Form_Name = 'Employee Assessment' and  Form_ID > 7000 
	end		
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Appraisal Reporting Manager Approval' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Appraisal,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Appraisal Reporting Manager Approval' 
		where Form_Name = 'Appraisal Reporting Manager Approval' and  Form_ID > 7000 
	end			
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Appraisal Group Head/GH Approval' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Appraisal,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Appraisal Group Head/GH Approval' 
		where Form_Name = 'Appraisal Group Head/GH Approval' and  Form_ID > 7000 
	end			
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'My Performance/Closing Loop' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Appraisal,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'My Performance/Closing Loop' 
		where Form_Name = 'My Performance/Closing Loop' and  Form_ID > 7000 
	end			
	
		
End -- #region appraisal Menu End		


if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'KPI/PMS' and Form_ID>7000 )
	begin
	update T0000_DEFAULT_FORM 
		set Form_Image_url = @HR_Img
		where under_form_id = (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'KPI/PMS' and Form_ID>7000)
	end
	
begin  -- #region appraisal Menu Start

Declare @form_id_Reward as Numeric
set @form_id_Reward = 0
set @Sor_id_Check = 0
--set @Sort_Id = @Sort_Id + 20


if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Rewards & Recognition' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Sort_ID=83,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Rewards & Recognition' 
		where Form_Name = 'Rewards & Recognition' and  Form_ID > 7000 
	end
select @form_id_Reward = Form_id,@Sort_Id=Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Rewards & Recognition' and form_id>7000

	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Reward' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Reward,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Employee Reward' 
		where Form_Name = 'Employee Reward' and  Form_ID > 7000 
	end
	
		
End -- #region appraisal Menu End	

--added on 7 Aug 2015 
begin  
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Training'  And Form_ID > 6500 and Form_ID < 6700)
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 6700
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name] )
		values (@Menu_id1,'Training',-1,206,1,'HRMS/HR_Home.aspx','menu/fix.gif',1,'Training','HRMS')
	end
end		
--#region Training -Admin Menu Start 
Declare @form_id_TrainingHR as Numeric
set @form_id_TrainingHR = 0
set @Sor_id_Check = 0
select @form_id_TrainingHR = Form_id,@Sort_Id=Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Training' And Form_ID > 6500 and Form_ID < 6700

set @Sor_id_Check = @Sor_id_Check + 1

--added by sneha on 26 Nov 2015--start
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'T_Masters'  And Form_ID > 6500 and Form_ID < 6700)
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 6700
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name] )
		values (@Menu_id1,'T_Masters',@form_id_TrainingHR,@Sort_Id,@Sor_id_Check,'HRMS/HR_Home.aspx','menu/fix.gif',1,'Masters','HRMS')
	end
Declare @form_id_TrainingHR_M as Numeric
set @form_id_TrainingHR_M = 0
select @form_id_TrainingHR_M = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'T_Masters' And Form_ID > 6500 and Form_ID < 6700

--added by sneha on 26 Nov 2015--end

if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Training Type Master' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_TrainingHR_M,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Training Type Master' 
		where Form_Name = 'Training Type Master' and  Form_ID > 6500 and Form_ID < 6700
	end
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Training Category Master' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_TrainingHR_M,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Training Category Master' 
		where Form_Name = 'Training Category Master' and  Form_ID > 6500 and Form_ID < 6700
	end

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Training Master' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_TrainingHR_M,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Training Master' 
		where Form_Name = 'Training Master' and  Form_ID > 6500 and Form_ID < 6700
	end

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Training Provider' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_TrainingHR_M,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Training Provider' 
		where Form_Name = 'Training Provider' and  Form_ID > 6500 and Form_ID < 6700
	end
	
set @Sor_id_Check = @Sor_id_Check + 1

if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Training Calendar Year' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_TrainingHR,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Training Calendar Year', 
		Is_Active_For_menu = 1
		where Form_Name = 'Training Calendar Year' and  Form_ID > 6500 and Form_ID < 6700
	end

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Training Questionnaire' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_TrainingHR,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Training Questionnaire' 
		where Form_Name = 'Training Questionnaire' and  Form_ID > 6500 and Form_ID < 6700
	end	
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Training Plan' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_TrainingHR,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Training Plan' 
		where Form_Name = 'Training Plan' and  Form_ID > 6500 and Form_ID < 6700
	end	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Training Calendar' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_TrainingHR,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Training Calendar' ,
		Is_active_for_menu=0
		where Form_Name = 'Training Calendar' and  Form_ID > 6500 and Form_ID < 6700
	end	
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Training Approval' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_TrainingHR,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Training Approval' 
		where Form_Name = 'Training Approval' and  Form_ID > 6500 and Form_ID < 6700
	end	
		
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Training Feedback' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_TrainingHR,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Training Feedback' 
		where Form_Name = 'Training Feedback' and  Form_ID > 6500 and Form_ID < 6700
	end	
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Training History' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_TrainingHR,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Training History' 
		where Form_Name = 'Training History' and  Form_ID > 6500 and Form_ID < 6700
	end
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Training In/Out' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_TrainingHR,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Training In/Out' 
		where Form_Name = 'Training In/Out' and  Form_ID > 6500 and Form_ID < 6700
	end
	
---added by sneha on 30 sep 2015
--appraisal 1- start
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Goal Master' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set module_name = 'Appraisal1'
		where Form_Name = 'Goal Master' and  Form_ID > 6500 and Form_ID < 6700
	end
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Appraisal General Setting' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set module_name = 'Appraisal1'
		where Form_Name = 'Appraisal General Setting' and  Form_ID > 6500 and Form_ID < 6700
	end	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Skill General Setting' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set module_name = 'Appraisal1'
		where Form_Name = 'Skill General Setting' and  Form_ID > 6500 and Form_ID < 6700
	end	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Assign Goal' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set module_name = 'Appraisal1'
		where Form_Name = 'Assign Goal' and  Form_ID > 6500 and Form_ID < 6700
	end	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Skill Rating' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set module_name = 'Appraisal1'
		where Form_Name = 'Employee Skill Rating' and  Form_ID > 6500 and Form_ID < 6700
	end	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Initiate Appraisal' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set module_name = 'Appraisal1'
		where Form_Name = 'Initiate Appraisal' and  Form_ID > 6500 and Form_ID < 6700
	end	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Appraisal Approval' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set module_name = 'Appraisal1'
		where Form_Name = 'Appraisal Approval' and  Form_ID > 6500 and Form_ID < 6700
	end	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Initiate Appraisal Report' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set module_name = 'Appraisal1'
		where Form_Name = 'Initiate Appraisal Report' and  Form_ID > 6500 and Form_ID < 6700
	end	
--appraisal 1- end
--appraisal 2- start
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Range Master & General Settings' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set module_name = 'Appraisal2'
		where Form_Name = 'Range Master & General Settings' and  Form_ID > 6500 and Form_ID < 6700
	end	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Range Master & General Settings' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set module_name = 'Appraisal2'
		where Form_Name = 'Range Master & General Settings' and  Form_ID > 6500 and Form_ID < 6700
	end	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Criteria Master' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set module_name = 'Appraisal2' 
		where Form_Name = 'Criteria Master' and  Form_ID > 6500 and Form_ID < 6700
	end	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Performance Feedback Master' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set module_name = 'Appraisal2'
		where Form_Name = 'Performance Feedback Master' and  Form_ID > 6500 and Form_ID < 6700
	end	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Performance Attributes' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set module_name = 'Appraisal2'
		where Form_Name = 'Performance Attributes' and  Form_ID > 6500 and Form_ID < 6700
	end	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Appraisal Initiation' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set module_name = 'Appraisal2'
		where Form_Name = 'Appraisal Initiation' and  Form_ID > 6500 and Form_ID < 6700
	end	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Self Assessment' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set module_name = 'Appraisal2'
		where Form_Name = 'Employee Self Assessment' and  Form_ID > 6500 and Form_ID < 6700
	end	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Performance Assessment' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set module_name = 'Appraisal2'
		where Form_Name = 'Performance Assessment' and  Form_ID > 6500 and Form_ID < 6700
	end	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Appraisal Finalization' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set module_name = 'Appraisal2'
		where Form_Name = 'Appraisal Finalization' and  Form_ID > 6500 and Form_ID < 6700
	end	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Final Approval Stage' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set module_name = 'Appraisal2'
		where Form_Name = 'Final Approval Stage' and  Form_ID > 6500 and Form_ID < 6700
	end	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Other Assessment Master' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set module_name = 'Appraisal2'
		where Form_Name = 'Other Assessment Master' and  Form_ID > 6500 and Form_ID < 6700
	end	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee KPA' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set module_name = 'Appraisal2'
		where Form_Name = 'Employee KPA' and  Form_ID > 6500 and Form_ID < 6700
	end	
--appraisal 2- end
--appraisal 3- start
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'KPI Master' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set module_name = 'Appraisal3'
		where Form_Name = 'KPI Master' and  Form_ID > 6500 and Form_ID < 6700
	end	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'KPI Setting' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set module_name = 'Appraisal3'
		where Form_Name = 'KPI Setting' and  Form_ID > 6500 and Form_ID < 6700
	end	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'KPI Objectives' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set module_name = 'Appraisal3'
		where Form_Name = 'KPI Objectives' and  Form_ID > 6500 and Form_ID < 6700
	end	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'KPI Appraisal Form' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set module_name = 'Appraisal3'
		where Form_Name = 'KPI Appraisal Form' and  Form_ID > 6500 and Form_ID < 6700
	end	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'KPIPMS Final Evaluation' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set module_name = 'Appraisal3'
		where Form_Name = 'KPIPMS Final Evaluation' and  Form_ID > 6500 and Form_ID < 6700
	end	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'KPI Import' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set module_name = 'Appraisal3'
		where Form_Name = 'KPI Import' and  Form_ID > 6500 and Form_ID < 6700
	end	
--appraisal 3- end
---ended by sneha on 30 sep 2015	
-- #region Training -Admin Menu End			
--#region Recruitment -Admin
Declare @form_id_RecruitmentHR as Numeric
set @form_id_RecruitmentHR = 0
set @Sor_id_Check = 0
select @form_id_RecruitmentHR = Form_id,@Sort_Id=Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Recruitment Panel' And Form_ID > 6500 and Form_ID < 6700

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Recruitment Process Master' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_RecruitmentHR,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Recruitment Process Master' 
		where Form_Name = 'Recruitment Process Master' and  Form_ID > 6500 and Form_ID < 6700
	end
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Job Description' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_RecruitmentHR,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Job Description' 
		where Form_Name = 'Job Description' and  Form_ID > 6500 and Form_ID < 6700
	end
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Recruitment Application' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_RecruitmentHR,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Recruitment Application' 
		where Form_Name = 'Recruitment Application' and  Form_ID > 6500 and Form_ID < 6700
	end
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Recruitment Posted Detail' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_RecruitmentHR,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Recruitment Posted Detail' 
		where Form_Name = 'Recruitment Posted Detail' and  Form_ID > 6500 and Form_ID < 6700
	end
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Resume Import' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_RecruitmentHR,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Resume Import' 
		where Form_Name = 'Resume Import' and  Form_ID > 6500 and Form_ID < 6700
	end
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Resume Import' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_RecruitmentHR,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Resume Import' 
		where Form_Name = 'Resume Import' and  Form_ID > 6500 and Form_ID < 6700
	end
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Posted Resume Collection' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_RecruitmentHR,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Posted Resume Collection' 
		where Form_Name = 'Posted Resume Collection' and  Form_ID > 6500 and Form_ID < 6700
	end
	if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Candidates Detail' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_RecruitmentHR,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Candidates Detail' 
		where Form_Name = 'Candidates Detail' and  Form_ID > 6500 and Form_ID < 6700
	end
	if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Joining Status Updation' and Form_ID > 6500 and Form_ID < 6700)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_RecruitmentHR,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Joining Status Updation' 
		where Form_Name = 'Joining Status Updation' and  Form_ID > 6500 and Form_ID < 6700
	end
--#endregion

-- Added by rohit for update module name on 14072015
if not exists(select 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name='HR Management' and module_name = 'HRMS')
begin
 update T0000_DEFAULT_FORM set Module_name='HRMS' where Form_ID >= 6500 and Form_ID < 6700 
 update T0000_DEFAULT_FORM set module_name='HRMS' where Form_Name = 'HR Management'
end

if not exists (select 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name='Timesheet Management' and module_name = 'TIMESHEET')
begin 
declare @time_sheet numeric(18,0)

select @time_sheet = form_id from  t0000_default_form WITH (NOLOCK) where Form_Name  ='Timesheet Management'
update t0000_default_form set module_name = 'TIMESHEET' where Form_Name  ='Timesheet Management'
update T0000_DEFAULT_FORM set module_name = 'TIMESHEET'  where Under_Form_ID =@time_sheet
end

if not exists (select 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name='Mobile Application' and module_name = 'MOBILE')
begin 
declare @Mobile numeric(18,0)
select @Mobile = form_id from  t0000_default_form WITH (NOLOCK) where Form_Name  ='Mobile Application'
update t0000_default_form set module_name = 'MOBILE' where Form_Name  ='Mobile Application'
update T0000_DEFAULT_FORM set module_name = 'MOBILE'  where Under_Form_ID =@Mobile
end


--ended by rohit on 14072015
-------Addde by Sumit 14072015------------------------------
if not exists(select 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Module_name='HRMS' and Form_ID >7000 and Form_Image_url='menu/hr.gif')
Begin
	update T0000_DEFAULT_FORM set Module_name='HRMS' where Form_ID>7000 and Form_Image_url='menu/hr.gif'
End
if not exists(select 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Module_name='TIMESHEET' and Form_ID >7000)
Begin
	update T0000_DEFAULT_FORM set Module_name='TIMESHEET' where Form_ID>7000 and Form_Name like '%Timesheet%'
End

-- Changed Menu name As per Guide By Sandip on 20072015
update T0000_DEFAULT_FORM set Alias='Employee Increment' where  Form_name = 'Employee-Increment' and form_id>6000 and Form_ID < 7000
update T0000_DEFAULT_FORM set Alias='Gradewise Allowance' where  Form_name = 'Gradewise Allowance' and form_id>6000 and Form_ID < 7000
update T0000_DEFAULT_FORM set Alias='Employee Allowance Revised' where  Form_name = 'Employee AllowDedu Revised' and form_id>6000 and Form_ID < 7000

update T0000_DEFAULT_FORM set Alias='Employee In Out' where  Form_name = 'Employee In-Out' and form_id>6000 and Form_ID < 6500
update T0000_DEFAULT_FORM set Alias='Employee Transfer' where  Form_name = 'Employee-Transfer' and form_id>6000 and Form_ID < 6500
update T0000_DEFAULT_FORM set Alias='Employee Weekoff' where  Form_name = 'Employee-Weekoff' and form_id>6000 and Form_ID < 6500
update T0000_DEFAULT_FORM set Alias='In Out Re-Synchronized' where  Form_name = 'In Out Re-Synchronized' and form_id>6000 and Form_ID < 6500
update T0000_DEFAULT_FORM set Alias='Pre Comp Off Approval' where  Form_name = 'Pre comp-Off Approval' and form_id>6000 and Form_ID < 6500

update T0000_DEFAULT_FORM set Alias='Employee Bulk Company Transfer' where  Form_name = 'Employee Company Transfer Multi' and form_id>6000 and Form_ID < 6500
--update T0000_DEFAULT_FORM set Alias='Leave Cancellation Status' where  Form_name = 'Leave Cancellation View Delete' and form_id>6000 and Form_ID < 6500
update T0000_DEFAULT_FORM set Alias='Night Halt Approval' where  Form_name = 'Night Halt Approve' and form_id>6000 and Form_ID < 6500
update T0000_DEFAULT_FORM set Alias='OverTime Approval' where  Form_name = 'OT Approval' and form_id>6000 and Form_ID < 6500
update T0000_DEFAULT_FORM set Alias='Full & Final Settlement' where  Form_name = 'F F Settlement' and form_id>6000 and Form_ID < 6500

update T0000_DEFAULT_FORM set Alias='Reimbursement' where  Form_name = 'Reim/Claim' and form_id>6000 and Form_ID < 6500
update T0000_DEFAULT_FORM set Alias='Reimbursement Approval' where  Form_name = 'Reim/Claim Approval' and form_id>6000 and Form_ID < 6500
update T0000_DEFAULT_FORM set Alias='Reimbursement Opening' where  Form_name = 'Reim/Claim Opening' and form_id>6000 and Form_ID < 6500
--update T0000_DEFAULT_FORM set Alias='Reimbursement Opening Import' where  Form_name = 'Reim/Claim Opening Import' and form_id>6000 and Form_ID < 6500

update T0000_DEFAULT_FORM set Alias='Employee Weekoff / Alternate Weekoff'/*'Alternate Weekoff'*/ where  Form_name = 'Half Weekoff' and form_id>6000 and Form_ID < 6500 /* Alias Change [Alternate weekoff to Employee Weekoff / Alternate Weekoff] - Ankit 23062016 */


update T0000_DEFAULT_FORM set Alias='Pre Comp Off Application' where  Form_name = 'Pre comp-Off Application' and form_id>7000 and Form_ID < 8000
update T0000_DEFAULT_FORM set Alias='Pre comp Off Approval' where  Form_name = 'Pre comp-Off Approval' and form_id>7000 and Form_ID < 8000


-----------------Update form_url for dynamically generated form_id in ESS Side by Sumit 13072015 ------------------------------
---------Attendance Reports------------------------------------------
update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=12' 
where Form_ID=7522 and Under_Form_ID=7521

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=15' 
where Form_ID=7523 and Under_Form_ID=7521

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=22' 
where Form_ID=7524 and Under_Form_ID=7521

--Added By Jaina 9-10-2015
update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=16' 
where Form_ID=7561 and Under_Form_ID=7521

--------Leave Reports------------------------------------------------------------
update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=11' 
where Form_ID=7526 and Under_Form_ID=7525

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=9' 
where Form_ID=7527 and Under_Form_ID=7525

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=36' 
where Form_ID=7528 and Under_Form_ID=7525

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=1270' 
where Form_ID=7556 and Under_Form_ID=7525

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=1272' 
where Form_ID=7558 and Under_Form_ID=7525

------------Loan Reports--------------------------------------------------------
update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=42' 
where Form_ID=7530 and Under_Form_ID=7529

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=44' 
where Form_ID=7531 and Under_Form_ID=7529

--added jimit 10/11/2015
--update T0000_DEFAULT_FORM SET Form_url = '~/Report_Payroll.aspx?Id=1281'
--WHERE Form_ID = 7568 and under_form_id = 7511

--update T0000_DEFAULT_FORM SET Form_url = '~/Report_Payroll_Mine.aspx?Id=1281'
--WHERE Form_ID = 7569 and under_form_id = 7529
---ended

--Added by Jaina 11-01-2019 Start
update T0000_Default_Form set Form_url = '~/Report_Payroll.aspx?Id=1281'
where Form_Name = 'Loan Application Report Member#' and Page_Flag ='ER'


update T0000_Default_Form set Form_url = '~/Report_Payroll_Mine.aspx?Id=1281'
where Form_Name = 'Loan Application Report My#' and Page_Flag ='ER'
--Added by Jaina 11-01-2019 End


--Added By Jimit 11122019
update	T0000_DEFAULT_FORM set Form_url='~/Report_Payroll.aspx?Id=58'
where	Form_name = 'Employee OverTime Reports Member#' and Page_Flag ='ER'
--Ended


------------Other Reports-------------------------------------------------------
update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=69' 
where Form_ID=7560 and Under_Form_ID=7532


update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=51' 
where Form_ID=7533 and Under_Form_ID=7532

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=54' 
where Form_ID=7534 and Under_Form_ID=7532

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=75' 
where Form_ID=7535 and Under_Form_ID=7532

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=201' 
where Form_ID=7536 and Under_Form_ID=7532

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=202' 
where Form_ID=7537 and Under_Form_ID=7532

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=3' 
where Form_ID=7538 and Under_Form_ID=7532



update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=204' 
where Form_ID=7545 and Under_Form_ID=7532

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=117' 
where Form_ID=7546 and Under_Form_ID=7532

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=111' 
where Form_ID=7547 and Under_Form_ID=7532

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=62' 
where Form_ID=7549 and Under_Form_ID=7532

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=9007' 
where Form_ID=7554 and Under_Form_ID=7553

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=9009' 
where Form_ID=7555 and Under_Form_ID=7532



update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=1276' 
where Form_ID=7559 and Under_Form_ID=7532

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=69' 
where Form_ID=7560 and Under_Form_ID=7532

-----------------Travel Reports-------------------------------------------------------
--update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=203' 
--where Form_ID=7539 and Under_Form_ID=7532


update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=1257' 
where Form_ID=7540 and Under_Form_ID=7539

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=1261' 
where Form_ID=7541 and Under_Form_ID=7539

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=1257' 
where Form_ID=7540 and Under_Form_ID=7539

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=1261' 
where Form_ID=7541 and Under_Form_ID=7539

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=1262' 
where Form_ID=7542 and Under_Form_ID=7539

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=1263' 
where Form_ID=7543 and Under_Form_ID=7539

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=225' 
where Form_ID=7546 and Under_Form_ID=7525


---------------------------------------------------
---------------Attendance------------------------------------
update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll.aspx?Id=12'
where Form_ID=7504 and Under_Form_ID=7503

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll.aspx?Id=15'
where Form_ID=7505 and Under_Form_ID=7503

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll.aspx?Id=22'
where Form_ID=7506 and Under_Form_ID=7503


--Added By Jaina 9-10-2015
update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll.aspx?Id=16'
where Form_ID=7562 and Under_Form_ID=7503

--------------Leave Reports-----------------------------------------
update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll.aspx?Id=11'
where Form_ID=7508 and Under_Form_ID=7507

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll.aspx?Id=9'
where Form_ID=7509 and Under_Form_ID=7507

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll.aspx?Id=36'
where Form_ID=7510 and Under_Form_ID=7507

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll.aspx?Id=1270'
where Form_ID=7557 and Under_Form_ID=7507

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll.aspx?Id=225'
where Form_ID=7545 and Under_Form_ID=7507

---------Loan Reports------------------------------------

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll.aspx?Id=42'
where Form_ID=7512 and Under_Form_ID=7511

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll.aspx?Id=44'
where Form_ID=7513 and Under_Form_ID=7511

--update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll.aspx?Id=44'
--where Form_ID=7544 and Under_Form_ID=7511

-----------------Other Reports----------------------------------
update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll.aspx?Id=51'
where Form_ID=7515 and Under_Form_ID=7514

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll.aspx?Id=54'
where Form_ID=7516 and Under_Form_ID=7514

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll.aspx?Id=75'
where Form_ID=7517 and Under_Form_ID=7514

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll.aspx?Id=201'
where Form_ID=7518 and Under_Form_ID=7514

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll.aspx?Id=202'
where Form_ID=7519 and Under_Form_ID=7514

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll.aspx?Id=111'
where Form_ID=7548 and Under_Form_ID=7514

---------------------HRMS Link-------------------------------------

--update T0000_DEFAULT_FORM set Form_url='~/Report_Customized_HRMS_Ess.aspx'
--where Form_ID=7551 --and Under_Form_ID=7550

--update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll.aspx?Id=9007'
--where Form_ID=7552 and Under_Form_ID=7550

-------------------------------------------
update t0000_default_form set form_url='~/Report_Payroll.aspx?Id=0'
where form_id=7502 and Under_Form_ID=7501

update t0000_default_form set Module_name='HRMS' where Form_id > 7500 and Form_id < 8000 and alias like '%HRMS%'


update t0000_default_form set Module_name='HRMS' where under_Form_id = 6163
and alias like '%HRMS%'

declare @form_id_hrms as numeric(18,0)
select @form_id_hrms = form_id from  t0000_default_form WITH (NOLOCK) where under_Form_id = 6163
and alias like '%HRMS%'

update t0000_default_form set Module_name='HRMS' where under_Form_id = @form_id_hrms 

update t0000_default_form set Module_name='TIMESHEET' where Under_Form_ID=9261 and Alias like '%Timesheet%'
update t0000_default_form set Module_name='TIMESHEET' where Under_Form_ID=9061 and Alias like '%Timesheet%'

set @form_id_hrms=0
update t0000_default_form set Module_name='HRMS' where Form_Name='HR Home Page Rights'
select @form_id_hrms = form_id from  t0000_default_form WITH (NOLOCK) where Form_Name='HR Home Page Rights'
update t0000_default_form set Module_name='HRMS' where under_Form_id = @form_id_hrms 


update T0000_DEFAULT_FORM set alias='Asset Details' where form_name ='Asset Import' 
------------Added by Sumit 07082015----------------------------------------------------------------------------------------------
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Travel Account - Desk' And Form_ID > 6000 and Form_ID < 6500)--Added by Sumit 06082015
begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
	values (@Menu_id1,'Travel Account - Desk',6151 ,119,1,'Travel_Approval_Account_Desk.aspx',@Loan_Claim_Img,1,'Travel Account - Desk',3)
end
----------------------------------------------------------------------------------------------------------------
--and alias like '%HRMS%'
------Ended by Sumit 14072015----------------------------------------------------

------------Added by Nimesh 07-Aug-2015----------------------------
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Employee Additional GPF Request' And Form_ID > 6000 and Form_ID < 6500) 
BEGIN
	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000 and Form_ID < 6500
	
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias], [Sort_Id_Check],[Module_name])
	VALUES(@Menu_id1, N'Employee Additional GPF Request', 6220, 68, 1, N'Employee_GPF_Request.aspx', @Employee_Img, 1, N'Employee Additional GPF Request',5,'GPF')			
END
------------Added by Nimesh 10-Aug-2015----------------------------
SELECT  @SubmenuId = Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Privileges/Scheme Assign' And Form_ID > 6000 and Form_ID < 6500 -- added by Prakash Patel 03122015

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Employee PayScale Detail' And Form_ID > 6000 and Form_ID < 6500) 
BEGIN
	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000 and Form_ID < 6500
	
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
	VALUES(@Menu_id1, N'Employee PayScale Detail', @SubmenuId, 79, 1, N'Employee_PayScale_Detail.aspx', @Employee_Img, 1, N'Employee PayScale Detail', 7)
END
ELSE
BEGIN

	UPDATE	[T0000_DEFAULT_FORM] 
	SET		Alias=N'Employee PayScale Detail', Sort_Id_Check=7, Form_Image_url=@Employee_Img, Under_Form_ID=@SubmenuId
	WHERE	Form_name = 'Employee PayScale Detail' And Form_ID > 6000 and Form_ID < 6500	
END

------------Ankit 27082015----------------------------
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Employee Grade Change Detail' And Form_ID > 6000 and Form_ID < 6500) 
BEGIN
	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000 and Form_ID < 6500
	
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
	VALUES(@Menu_id1, N'Employee Grade Change Detail', @SubmenuId, 79, 1, N'Employee_Grade_Change.aspx', @Employee_Img, 1, N'Employee Grade Change Detail', 6)
END
ELSE
BEGIN
	UPDATE	[T0000_DEFAULT_FORM] 
	SET		Alias=N'Employee Grade Change Detail', Sort_Id_Check=6, Form_Image_url=@Employee_Img ,UNDER_FORM_ID=@SUBMENUID
	WHERE	Form_name = 'Employee Grade Change Detail' And Form_ID > 6000 and Form_ID < 6500	
END

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Policy Document Read' and Page_Flag='AR') 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) --where Form_ID > 6700  and Form_ID < 6999	  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],Page_Flag)
		values (@Menu_id1,'Employee Policy Document Read',6701, 173,1,NULL, NULL, 1, N'Employee Policy Document Read','AR')
		
	end 
	
	--Binal added on 24012020
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'COPH / COND Avail Balance' and Page_Flag='AR') 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) --where Form_ID > 6700  and Form_ID < 6999	  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],Page_Flag)
		values (@Menu_id1,'COPH / COND Avail Balance',6703, 174,1,NULL, NULL, 1, N'COPH / COND Avail Balance','AR')
		
	end 

	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'COPH / COND Leave Adjustment Details' and Page_Flag='AR') 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) --where Form_ID > 6700  and Form_ID < 6999	  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],Page_Flag)
		values (@Menu_id1,'COPH / COND Leave Adjustment Details',6703, 175,1,NULL, NULL, 1, N'COPH / COND Leave Adjustment Details','AR')
		
	end 
	--end Binal added on 24012020
	--Changed by Sumit on 25102016

----Ankit 13102015
--DELETE from T0000_DEFAULT_FORM where  Form_name = 'Employee Policy Document Read' And Form_ID > 6700 and Form_ID < 6999
--if not exists (select Form_id from T0000_DEFAULT_FORM where  Form_name = 'Employee Policy Document Read' And Form_ID > 6700 and Form_ID < 6999) 
--	begin		
--		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID > 6700  and Form_ID < 6999	  
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
--		values (@Menu_id1,'Employee Policy Document Read',6701, 173,1,NULL, NULL, 1, N'Organization Policy Read')
		
--	end

--Added By Jaina 02-06-2016 Start

--(Clearance Attribute)

DECLARE @Under_Formid As numeric
SELECT @Under_Formid = Form_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name = 'Other Master'
If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Exit Clearance Attribute Master')
	begin

		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Exit Clearance Attribute Master',@Under_Formid, 64, 1,'Clearance_Attribute.aspx',@Masters_Img,1,'Exit Clearance Attribute Master')
	end
else
	begin
		UPDATE	[T0000_DEFAULT_FORM] 
		SET		Alias=N'Exit Clearance Attribute Master', Form_Image_url=@Masters_Img
		WHERE	Form_name = 'Exit Clearance Attribute Master' And Form_ID > 6000 and Form_ID < 6500	
	End
-- Added by Gadriwala Muslim 14092016
IF NOT EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE FORM_NAME= 'Exit Analysis Questions' AND FORM_ID > 6000 AND FORM_ID < 6500 )
	BEGIN
		SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE FORM_ID > 6000 AND FORM_ID < 6500
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
			values (@Menu_id1,'Exit Analysis Questions',@Under_Formid,64,1,'Master_Analysis_Question.aspx',@Masters_Img,1,'Exit Analysis Questions')
	END 	
-- (Exit Clearance Approval)

IF NOT EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE FORM_NAME= 'Ticket Type' AND FORM_ID > 6000 AND FORM_ID < 6500 )
	BEGIN
		SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE FORM_ID > 6000 AND FORM_ID < 6500
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
			values (@Menu_id1,'Ticket Type',@Under_Formid,64,1,'Master_Ticket_Type.aspx',@Masters_Img,1,'Ticket Type')
	END 

-- Start Added by Niraj (16062022) 
IF NOT EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE FORM_NAME= 'QR Code' AND FORM_ID > 6000 AND FORM_ID < 6500 )
BEGIN
	SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE FORM_ID > 6000 AND FORM_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'QR Code',@Under_Formid,64,1,'https://192.168.1.200:4343/Home/Index/',@Masters_Img,1,'QR Code')
END 
-- End Added by Niraj (16062022) 

If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Exit Clearance Approval')
	begin
		SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 
		FROM T0000_DEFAULT_FORM WITH (NOLOCK)
		WHERE Form_ID > 7000 and Form_ID < 7500
		
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID],
		 [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		 values(@Menu_id1, N'Exit Clearance Approval', 7049, 411, 1, N'Emp_Exit_Clearance_Approval.aspx',
				@Masters_Img, 1, N'Exit Clearance Approval')
	end
else
	begin
		UPDATE	[T0000_DEFAULT_FORM] 
		SET		Alias=N'Exit Clearance Approval', Form_Image_url=@Masters_Img
		WHERE	Form_name = 'Exit Clearance Approval' And Form_ID > 7000 and Form_ID < 7500	
	End
	

--(Admin Side Exit Clearance Approval) 

If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Exit Clearance Approval' AND Form_ID > 6000 and Form_ID < 6500)
	begin

		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID],
		 [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		 values(@Menu_id1, N'Exit Clearance Approval', 6148, 82, 1, N'Exit_Clearance_Approval.aspx',@Employee_Img,
				 1, N'Exit Clearance Approval')	
	end
else
	begin
		UPDATE	[T0000_DEFAULT_FORM] 
		SET		Alias=N'Exit Clearance Approval',Sort_ID=83 ,Form_Image_url=@Employee_Img
		WHERE	Form_name = 'Exit Clearance Approval' And Form_ID > 6000 and Form_ID < 6500	
	End


--Added By Jaina 02-06-2016 End

----Added By Mukti(05112015)start
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_name = 'Reimbursement Statement My#' And Form_ID > 7500 and Form_ID < 8000) 
	begin		
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7500  and Form_ID < 8000	  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Reimbursement Statement My#',7532, 402,1,'~/Report_Payroll_Mine.aspx?Id=46', NULL, 1, N'Reimbursement Statement My#')
		
	end
----Added By Mukti(05112015)end
----Added by Sumit 20-11-2015---------------------------------------------------------------------------------------
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Payment Slip My#')  
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7500 and Form_ID < 7999  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Payment Slip My#',7532,403,1,'~/Report_Payroll_Mine.aspx?Id=86', NULL, 1, N'Payment Slip My#')

	end

--Added by Mr.Mehul 17112022
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Project Allocation Report#')  
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7500 and Form_ID < 7999  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Project Allocation Member#',7514,10,1,'~/Report_Payroll.aspx?Id=9054', NULL, 1, N'Project Allocation Member#')

	end

--Added by Mr.Mehul 17112022
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Timesheet Summary')  
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7500 and Form_ID < 7999  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Timesheet Summary',7514,10,1,'~/Report_Payroll.aspx?Id=9055', NULL, 1, N'Timesheet Summary')

	end
	
--Transfer from P0000_Report_Reset --By sumit
--declare @Menu_id1 as numeric(18,0)


IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Attendance Card' And Form_ID > 6700 and Form_ID < 7000) 
BEGIN
	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6700 and Form_ID < 7000
	
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
	VALUES(@Menu_id1, N'Attendance Card', 6702, 173, 1, null, null, 1, N'Attendance Card', 14)
END
--Added By Jaina 2-11-2015 Start
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Deviation Report')
Begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700 and Form_ID < 7000
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
		values (@Menu_id1,'Deviation Report',6702,173,1,'','',1,'Deviation Report',15)
End	
--Added By Jaina 2-11-2015 End
--Added By Prakash Patel 03-12-2015 Start

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Mobile Inout Summary')
Begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700 and Form_ID < 7000
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
		values (@Menu_id1,'Mobile Inout Summary',6702,173,1,'','',1,'Mobile Inout Summary',16)
End
--Added By Prakash Patel 03-12-2015 End

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Leave Encash Amount' And Form_ID > 6700 and Form_ID < 7000) 
BEGIN
	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6700 and Form_ID < 7000
	
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
	VALUES(@Menu_id1, N'Leave Encash Amount', 6703, 79, 1, null, null, 1, N'Leave Encash Amount', 6)
END


IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Pending Loan Detail' And Form_ID > 6700 and Form_ID < 7000) 
BEGIN
	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6700 and Form_ID < 7000
	
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
	VALUES(@Menu_id1, N'Pending Loan Detail', 6703, 79, 1, null, null, 1, N'Pending Loan Detail', 6)
END

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Salary Summary Bankwise' And Form_ID > 6700 and Form_ID < 7000) 
BEGIN
	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6700 and Form_ID < 7000
	
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
	VALUES(@Menu_id1, N'Salary Summary Bankwise', 6703, 79, 1, null, null, 1, N'Salary Summary Bankwise', 6)
END

--IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WHERE  Form_name = 'ESIC Components' And Form_ID > 6700 and Form_ID < 7000) 
--BEGIN
--	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WHERE Form_ID > 6700 and Form_ID < 7000
	
--	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
--	VALUES(@Menu_id1, N'ESIC Components', 6703, 79, 1, null, null, 1, N'ESIC Components', 6)
--END

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Travel Statement' And Form_ID > 6700 and Form_ID < 7000) 
BEGIN
	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6700 and Form_ID < 7000
	
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
	VALUES(@Menu_id1, N'Travel Statement', 6703, 79, 1, null, null, 1, N'Travel Statement', 6)
END

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Employee Insurance1' And Form_ID > 6700 and Form_ID < 7000) 
BEGIN
	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6700 and Form_ID < 7000
	
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
	VALUES(@Menu_id1, N'Employee Insurance1', 6703, 79, 1, null, null, 1, N'Employee Insurance1', 6)
END

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Canteen Deduction' And Form_ID > 6700 and Form_ID < 7000) 
BEGIN
	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6700 and Form_ID < 7000
	
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
	VALUES(@Menu_id1, N'Canteen Deduction', 6705, 180, 1, null, null, 1, N'Canteen Deduction', 6)
END

--Added by nilesh patel on 27112015 -start

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Cash Voucher' And Form_ID > 6700 and Form_ID < 7000) 
BEGIN
	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6700 and Form_ID < 7000
	
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
	VALUES(@Menu_id1, N'Cash Voucher', 6712, 188, 1, null, null, 1, N'Cash Voucher', 25)
END

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Consolidation Statement' And Form_ID > 6700 and Form_ID < 7000) 
BEGIN
	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6700 and Form_ID < 7000
	
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
	VALUES(@Menu_id1, N'Consolidation Statement', 6712, 188, 1, null, null, 1, N'Consolidation Statement', 26)
END

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Monthly Abstract Report' And Form_ID > 6700 and Form_ID < 7000) 
BEGIN
	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6700 and Form_ID < 7000
	
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
	VALUES(@Menu_id1, N'Monthly Abstract Report', 6712, 188, 1, null, null, 1, N'Monthly Abstract Report', 27)
END

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Journal Voucher Report' And Form_ID > 6700 and Form_ID < 7000) 
BEGIN
	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6700 and Form_ID < 7000
	
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
	VALUES(@Menu_id1, N'Journal Voucher Report', 6712, 188, 1, null, null, 1, N'Journal Voucher Report', 28)
END

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Pay Bill Report' And Form_ID > 6700 and Form_ID < 7000) 
BEGIN
	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6700 and Form_ID < 7000
	
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
	VALUES(@Menu_id1, N'Pay Bill Report', 6712, 188, 1, null, null, 1, N'Pay Bill Report', 29)
END

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Tax Calculation Report' And Form_ID > 6700 and Form_ID < 7000) 
BEGIN
	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6700 and Form_ID < 7000
	
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
	VALUES(@Menu_id1, N'Tax Calculation Report', 6712, 188, 1, null, null, 1, N'Tax Calculation Report', 30)
END

--Added by nilesh patel on 27112015 -start


-------------------- Timesheet Report Start ------------------------
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Timesheet Reports' And Form_ID > 6700 and Form_ID < 7000) 
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6700 and Form_ID < 7000
		
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name] )
		VALUES(@Menu_id1, N'Timesheet Reports', 6163, 198, 1, null, null, 1, N'Timesheet Reports', 0,'TIMESHEET')
	END
ELSE  -- Added by Prakash Patel 28102015
	BEGIN
		UPDATE T0000_DEFAULT_FORM SET Module_name = 'TIMESHEET' WHERE Form_name = 'Timesheet Reports' AND Form_ID > 6700 AND Form_ID < 7000
	END

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Employee Costing Report' And Form_ID > 6700 and Form_ID < 7000) 
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6700 and Form_ID < 7000
		
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
		VALUES(@Menu_id1, N'Employee Costing Report', 6163, 196, 1, null, null, 1, N'Employee Costing Report', 6,'TIMESHEET')
	END
ELSE  -- Added by Prakash Patel 28102015
	BEGIN
		UPDATE T0000_DEFAULT_FORM SET Module_name = 'TIMESHEET' WHERE Form_name = 'Employee Costing Report' AND Form_ID > 6700 AND Form_ID < 7000
	END

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Project Cost' And Form_ID > 6700 and Form_ID < 7000) 
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6700 and Form_ID < 7000
		
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
		VALUES(@Menu_id1, N'Project Cost', 6163, 196, 1, null, null, 1, N'Project Cost', 6,'TIMESHEET')
	END
ELSE -- Added by Prakash Patel 28102015
	BEGIN
		UPDATE T0000_DEFAULT_FORM SET Module_name = 'TIMESHEET' WHERE Form_name = 'Project Cost' AND Form_ID > 6700 AND Form_ID < 7000
	END

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Project Overhead Cost' And Form_ID > 6700 and Form_ID < 7000) 
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6700 and Form_ID < 7000
		
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
		VALUES(@Menu_id1, N'Project Overhead Cost', 6163, 196, 1, null, null, 1, N'Project Overhead Cost', 6,'TIMESHEET')
	END
ELSE -- Added by Prakash Patel 28102015
	BEGIN
		UPDATE T0000_DEFAULT_FORM SET Module_name = 'TIMESHEET' WHERE Form_name = 'Project Overhead Cost' AND Form_ID > 6700 AND Form_ID < 7000
	END


IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Collection Detail' And Form_ID > 6700 and Form_ID < 7000) 
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6700 and Form_ID < 7000
		
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
		VALUES(@Menu_id1, N'Collection Detail', 6163, 196, 1, null, null, 1, N'Collection Detail', 6,'TIMESHEET')
	END
	
ELSE -- Added by Prakash Patel 28102015
	BEGIN
		UPDATE T0000_DEFAULT_FORM SET Module_name = 'TIMESHEET' WHERE Form_name = 'Collection Detail' AND Form_ID > 6700 AND Form_ID < 7000
	END


IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Timesheet Details Reports' And Form_ID > 6700 and Form_ID < 7000) 
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6700 and Form_ID < 7000
		
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
		VALUES(@Menu_id1, N'Timesheet Details Reports', 6163, 196, 1, null, null, 1, N'Timesheet Details Reports', 6,'TIMESHEET')
	END
ELSE -- Added by Prakash Patel 28102015
	BEGIN
		UPDATE T0000_DEFAULT_FORM SET Module_name = 'TIMESHEET' WHERE Form_name = 'Timesheet Details Reports' AND Form_ID > 6700 AND Form_ID < 7000
	END
	



SELECT @SubmenuId = Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Timesheet Reports' And Form_ID > 6700 and Form_ID < 7000 -- Added by Prakash Patel 03122015

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Manager Collection Details' And Form_ID > 6700 and Form_ID < 7000) 
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6700 and Form_ID < 7000
		
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
		VALUES(@Menu_id1, N'Manager Collection Details', @SubmenuId, 198, 1, null, null, 1, N'Manager Collection Details', 6,'TIMESHEET')
	END
ELSE -- Added by Prakash Patel 28102015
	BEGIN
		UPDATE T0000_DEFAULT_FORM SET Under_Form_ID =@SubmenuId,Module_name = 'TIMESHEET' WHERE Form_name = 'Manager Collection Details' AND Form_ID > 6700 AND Form_ID < 7000
	END



--SELECT @SubmenuId = Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Timesheet Reports' And Form_ID > 6700 and Form_ID < 7000 -- Added by Mr.Mehul 10112022

--IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Project Allocation Report' And Form_ID > 6700 and Form_ID < 7000) 
--	BEGIN
--		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6700 and Form_ID < 7000
		
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
--		VALUES(@Menu_id1, N'Project Allocation Report', 6163, 198, 1, null, null, 1, N'Project Allocation Report', 6,'TIMESHEET')
--	END
--ELSE -- Added by Mr.Mehul 10112022
--	BEGIN
--		UPDATE T0000_DEFAULT_FORM SET Under_Form_ID =@SubmenuId,Module_name = 'TIMESHEET' WHERE Form_name = 'Project Allocation Report' AND Form_ID > 6700 AND Form_ID < 7000
--	END


IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Project Allocation Report' And Form_ID > 6700 and Form_ID < 7000) 
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6700 and Form_ID < 7000
		
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
		VALUES(@Menu_id1, N'Project Allocation Report', 6163, 196, 1, null, null, 1, N'Project Allocation Report', 6,'TIMESHEET')
	END
ELSE -- Added by Prakash Patel 28102015
	BEGIN
		UPDATE T0000_DEFAULT_FORM SET Module_name = 'TIMESHEET' WHERE Form_name = 'Project Allocation Report' AND Form_ID > 6700 AND Form_ID < 7000
	END



-------------------- Timesheet Report End ------------------------


IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Allowance/Deduction Revised Report' And Form_ID > 6700 and Form_ID < 7000) 
BEGIN
	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6700 and Form_ID < 7000
	
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
	VALUES(@Menu_id1, N'Allowance/Deduction Revised Report', 6705, 179, 1, null, null, 1, N'Allowance/Deduction Revised Report', 6)
END


IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'CPS Balance Report' And Form_ID > 6700 and Form_ID < 7000) 
BEGIN
	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6700 and Form_ID < 7000
	
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
	VALUES(@Menu_id1, N'CPS Balance Report', 6705, 179, 1, null, null, 1, N'CPS Balance Report', 6)  
END 

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Payment Slip' And Form_ID > 6700 and Form_ID < 7000) 
BEGIN
	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6700 and Form_ID < 7000
	
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
	VALUES(@Menu_id1, N'Payment Slip', 6705, 179, 1, null, null, 1, N'Payment Slip', 6)
END

--if  not exists (select Form_id from T0000_DEFAULT_FORM where  Form_name = 'Asset Customize' And Form_ID < 7000)  --Mukti 05102015
--begin  
--	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
--	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
--	values (@Menu_id1,N'Asset Customize',6714 ,172,1,'',NULL,1,N'Asset Customize')
--end
------------Added by Sumit 25112015----------------------------
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Currency Master' And Form_ID > 6000 and Form_ID < 6500) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'Currency Master', 6027, 47, 1, N'master_currency.aspx', @Masters_Img, 1, N'Currency Master')			
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Currency Conversion' And Form_ID > 6000 and Form_ID < 6500) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'Currency Conversion', 6027, 48, 1, N'salary_currency_conversion.aspx', @Masters_Img, 1, N'Currency Conversion')			
	end	
--------------------Added by Sumit 25112015 for update Url of Comp-off leave Adjustment report----------------------------------------------------------
--Ended
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Half Yearly Return Report' And Form_ID > 6700 and Form_ID < 7000)   -- Added By Mukti on 26122015
BEGIN
	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6700 and Form_ID < 7000
	
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
	VALUES(@Menu_id1, N'Half Yearly Return Report', 6712, 188, 1, null, null, 1, N'Half Yearly Return Report', 31)
END

--------------------Added by Sumit 18012016 for Added new Masters for Travel----------------------------------------------------------
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Project Master Travel' And Form_ID > 6000 and Form_ID < 6500) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name])
		values(@Menu_id1, N'Project Master Travel', @form_id_travel, @Sort_Id, 1, N'Master_Projects.aspx', @Masters_Img, 0, N'Project Master','Payroll')			
	end
Else
	Begin
		update [dbo].[T0000_DEFAULT_FORM] set [Is_Active_For_menu]=0
		where Form_Name ='Project Master Travel' And Form_ID > 6000 and Form_ID < 6500
	End	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Vendor Master Travel' And Form_ID > 6000 and Form_ID < 6500) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name])
		values(@Menu_id1, N'Vendor Master Travel', @form_id_travel, @Sort_Id, 1, N'Master_Vendor.aspx', @Masters_Img, 0, N'Vendor Master','Payroll')			
	end
Else
	Begin
		update [dbo].[T0000_DEFAULT_FORM] set [Is_Active_For_menu]=0
		where Form_Name ='Vendor Master Travel' And Form_ID > 6000 and Form_ID < 6500
	End	
	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Order Type Master Travel' And Form_ID > 6000 and Form_ID < 6500) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name])
		values(@Menu_id1, N'Order Type Master Travel', @form_id_travel, @Sort_Id, 1, N'Master_Order_Type.aspx', @Masters_Img, 0, N'Order Type Master','Payroll')			
	end
Else
	Begin
		update [dbo].[T0000_DEFAULT_FORM] set [Is_Active_For_menu]=0
		where Form_Name ='Order Type Master Travel' And Form_ID > 6000 and Form_ID < 6500
	End	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Tax Component Master Travel' And Form_ID > 6000 and Form_ID < 6500) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name])
		values(@Menu_id1, N'Tax Component Master Travel', @form_id_travel, @Sort_Id, 1, N'Master_TaxComponent.aspx', @Masters_Img, 0, N'Tax Component Master','Payroll')			
	end
Else --Default Inactive menus
	Begin
		update [dbo].[T0000_DEFAULT_FORM] set [Is_Active_For_menu]=0
		where Form_Name ='Tax Component Master Travel' And Form_ID > 6000 and Form_ID < 6500
	End							

----Sumit-Ended----------------------------------------------------18012016----------

--------------------Added by Sumit 17082015 for update Url of Comp-off leave Adjustment report----------------------------------------------------------
update T0000_DEFAULT_FORM set form_url='~/Report_Payroll.aspx?Id=1270' where Form_Name='Comp-Off Leave Adjustment Details Member#'

update T0000_DEFAULT_FORM set form_url='~/Report_Payroll.aspx?Id=111' where Form_Name='Employee Warning Member#'
--------------------------------------------------------------------------------------------
Delete from T0000_DEFAULT_FORM where Form_Name='Reimbursement Approval Report' and Under_Form_ID='7511'

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=1272'
where Form_Name='Comp-Off Avail Balance My#'

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=1270'
where Form_Name='Comp-Off Leave Adjustment Details My#'

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=204'
where Form_Name='Income Tax Declaration My#'
----------------added jimit 12072016-----------------------------------
update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll.aspx?Id=204'
where Form_Name='Income Tax Declaration Member#'
-----------------------------------------------------------------------
----------------added jimit 29032016-----------------------------------
update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=9037'
where Form_Name='Tax Consolidate Report My#'
------------------------ended-------------------------------------------
update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=117'
where Form_Name='FORM 11 (PF) My#'

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=111'
where Form_Name='Employee Warning My#'

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=62'
where Form_Name='Register With Settlement My#'

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=7532' --Added by Mr.Mehul 19122022
where Form_Name='Timesheet Summary My#'

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=9009'
where Form_Name='Scheme Details My#'

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=1276'
where Form_Name='Asset Installment Statement My#'

update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=69'
where Form_Name='Reimbursement Slip My#'

--Added by Sumit 01092015 for problem of Customize reports in Rights Page---------------------------------------------------------------------------
update T0000_default_form set Form_url=''
where Under_Form_ID=(select form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name='Customize Report')

------------------------------------------------------------------------------------------
----Added by Sumit 25-02-2016---------------------------------------------------------------------------------------
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Daily Overtime My#')  
	begin	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7500 and Form_ID < 7999  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name])
		values (@Menu_id1,'Employee Daily Overtime My#',7532,404,1,'~/Report_Payroll_Mine.aspx?Id=60', NULL, 1, N'Employee Daily Overtime My#','Payroll')
	end	
--Ended by Sumit
IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Leave Encash Slip My#')		-----Sumit 16072015
	BEGIN
		SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7500 and Form_ID < 7999  
		
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name])
		VALUES (@Menu_id1,'Leave Encash Slip My#',7525,393,1,'~/Report_Payroll_Mine.aspx?Id=9036', NULL, 1, N'Leave Encash Slip My#','Payroll')
	END


IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Leave Encash Slip' And Form_ID > 6700 and Form_ID < 7000) 
BEGIN
	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6700 and Form_ID < 7000
	
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
	VALUES(@Menu_id1, N'Leave Encash Slip', 6703, 175, 1, null, null, 1, N'Leave Encash Slip', 14,'Payroll')
END

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Leave Against Gatepass' And Form_ID > 6700 and Form_ID < 7000) 
BEGIN
	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6700 and Form_ID < 7000
	
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
	VALUES(@Menu_id1, N'Leave Against Gatepass', 6703, 176, 1, null, null, 1, N'Leave Against Gatepass', 15,'Payroll')
END

--Added By Jaina 31-08-2016
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Leave Application Form' And Form_ID > 6700 and Form_ID < 7000) 
BEGIN
	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6700 and Form_ID < 7000
	
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
	VALUES(@Menu_id1, N'Leave Application Form', 6703, 177, 1, null, null, 1, N'Leave Application Form', 16,'Payroll')
END

----Added by Sumit for insert default report name in dropdown 09092015--------------------
if not exists(select Report_Name from T0240_Default_Report WITH (NOLOCK) where Report_Name='Salary_Slip')
Begin
insert into T0240_Default_Report(Report_Name,Rpt_Alias)
select 'Salary_Slip','Salary Slip' union 	
 SELECT 'CTC','CTC' union 
 SELECT 'Inout Summary','Inout Summary'
End

if not exists(select Report_Name from T0240_Default_Report WITH (NOLOCK) where Report_Name='TAX COMPUTATION')
begin
insert into T0240_Default_Report(Report_Name,Rpt_Alias) values
('TAX COMPUTATION','TAX COMPUTATION')

end

----Ended by Sumit 09092015---------------------------------------------------------------

-- Added by rohit on 12022016 for move form in employee tab as per discussion with ankur sir.

if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Admin Change Request Approval' And Form_ID > 6000 and Form_ID < 6499)
	begin    
		update T0000_DEFAULT_FORM
		set sort_id=80,Under_Form_ID=6042,Form_Image_url=@Employee_Img 
		where  Form_name = 'Admin Change Request Approval' And Form_ID > 6000 and Form_ID < 6499
	end
--ended by rohit	

--Added By Ramiz on 15-Feb-2016 , to fill Default Value in AX Reports ( FOR SAP FILE ) --
DELETE FROM T9999_AX_REPORT_SETTING	--Deleting Old Records and Inserting new One

IF NOT EXISTS (SELECT 1 from T9999_AX_REPORT_SETTING WITH (NOLOCK))
	BEGIN
		INSERT INTO T9999_AX_Report_Setting (AX_ID , AX_TYPE , SP_NAME , PARAMETER , MODIFY_DATE , FORMAT)
		VALUES ( 1 , 'SALARY','AX_ERP_REPORT_SALARY' , 'C' , GETDATE() , 'F1')
		
		INSERT INTO T9999_AX_Report_Setting (AX_ID , AX_TYPE , SP_NAME , PARAMETER , MODIFY_DATE, FORMAT)
		VALUES ( 1 , 'SALARY','AX_SAP_REPORT_SALARY' , 'C' , GETDATE() , 'F2')

		INSERT INTO T9999_AX_Report_Setting (AX_ID , AX_TYPE , SP_NAME , PARAMETER , MODIFY_DATE, FORMAT)  --Added by Jaina 30-07-2020
		VALUES ( 1 , 'SALARY','AX_JV_REPORT_WESTROCK_SALARY' , 'C' , GETDATE() , 'F3')
		
		INSERT INTO T9999_AX_Report_Setting (AX_ID , AX_TYPE , SP_NAME , PARAMETER , MODIFY_DATE , FORMAT)
		VALUES ( 2 , 'REIMBURSEMENT','AX_ERP_REPORT_REIM' , 'R' , GETDATE() , NULL)
		
		INSERT INTO T9999_AX_Report_Setting (AX_ID , AX_TYPE , SP_NAME , PARAMETER , MODIFY_DATE , FORMAT)
		VALUES ( 3 , 'Claim','AX_ERP_REPORT_CLAIM' , 'C' , GETDATE() , NULL)
		
		INSERT INTO T9999_AX_Report_Setting (AX_ID , AX_TYPE , SP_NAME , PARAMETER , MODIFY_DATE , FORMAT)
		VALUES ( 4 , 'Absent Detail','P_RPT_AX_IMPORT' , 'AB' , GETDATE() , NULL)
		
		INSERT INTO T9999_AX_Report_Setting (AX_ID , AX_TYPE , SP_NAME , PARAMETER , MODIFY_DATE , FORMAT)
		VALUES ( 5 , 'Half Absent Report','P_RPT_AX_IMPORT' , 'HR' , GETDATE() , NULL)
		
		INSERT INTO T9999_AX_Report_Setting (AX_ID , AX_TYPE , SP_NAME , PARAMETER , MODIFY_DATE , FORMAT)
		VALUES ( 6 , 'Comp & LWP Leave','P_RPT_AX_IMPORT' , 'COMP' , GETDATE() , NULL)
		
		INSERT INTO T9999_AX_Report_Setting (AX_ID , AX_TYPE , SP_NAME , PARAMETER , MODIFY_DATE , FORMAT)
		VALUES ( 7 , 'Half Leave','P_RPT_AX_IMPORT' , 'HL' , GETDATE() , NULL)
		
		INSERT INTO T9999_AX_Report_Setting (AX_ID , AX_TYPE , SP_NAME , PARAMETER , MODIFY_DATE , FORMAT)
		VALUES ( 8 , 'Leave Applied Pending For Approval','P_RPT_AX_IMPORT' , 'PL' , GETDATE() , NULL)
		
		INSERT INTO T9999_AX_Report_Setting (AX_ID , AX_TYPE , SP_NAME , PARAMETER , MODIFY_DATE , FORMAT)
		VALUES ( 9 , 'Pending Attendance Regularization','P_RPT_AX_IMPORT' , 'PR' , GETDATE() , NULL)
		
		INSERT INTO T9999_AX_Report_Setting (AX_ID , AX_TYPE , SP_NAME , PARAMETER , MODIFY_DATE , FORMAT)
		VALUES ( 10 , 'Approved Attendance Regularization','P_RPT_AX_IMPORT' , 'AR' , GETDATE() , NULL)

		INSERT INTO T9999_AX_Report_Setting (AX_ID , AX_TYPE , SP_NAME , PARAMETER , MODIFY_DATE , FORMAT)
		VALUES ( 11 , 'Cost Center','P_Get_Ax_Slab_Master_Details' , 'CC' , GETDATE() , 'F5')

	END
--Ended By Ramiz on 15-Feb-2016 , to fill Default Value in AX Reports--

--Added by Nilesh Patel on 13042016 --Start
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Employee Directory' And Form_ID > 7000 and Form_ID < 7499) 
BEGIN
	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 7000 and Form_ID < 7499
	
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
	VALUES(@Menu_id1, N'Employee Directory', 7001, 305, 1, 'Employee_Direcotry_New.aspx', @Employee_Img, 1, N'Employee Directory', 14,'Payroll')
END
--Added by Nilesh Patel on 13042016 --End

------------------------ Transport Module Add by Prakash Patel 01032016 Start -----------------------------------------------------------------
--- Transport Form Start ---

DECLARE @Under_form_Id INT

IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Transport' AND Form_ID > 6000 AND Form_ID < 6500)      
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000 AND Form_ID < 6500      
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name])
		VALUES(@Menu_id1, N'Transport', 6070, 248, 1, N'Home.aspx', @Loan_Claim_Img, 1,N'Transport',0,'TRANSPORT')
	END
SELECT @Under_form_Id = Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Transport' AND Form_ID > 6000 AND Form_ID < 6500

IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Vehicle'  AND  Form_ID > 6000 AND Form_ID < 6500)
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000 AND Form_ID < 6500      
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name])
		VALUES(@Menu_id1, N'Vehicle', @Under_form_Id, 248, 1, N'Master_Vehicle.aspx', @Loan_Claim_Img, 1,N'Vehicle',1,'TRANSPORT')
	END
IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Route'  AND  Form_ID > 6000 AND Form_ID < 6500)
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000 AND Form_ID < 6500      
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name])
		VALUES(@Menu_id1, N'Route', @Under_form_Id, 248, 1, N'Master_Route.aspx', @Loan_Claim_Img, 1,N'Route',2,'TRANSPORT')
	END
IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'PickupStation'  AND  Form_ID > 6000 AND Form_ID < 6500)
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000 AND Form_ID < 6500      
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name])
		VALUES(@Menu_id1, N'PickupStation', @Under_form_Id, 248, 1, N'Master_PickupStation.aspx', @Loan_Claim_Img, 1,N'PickupStation',3,'TRANSPORT')
	END
IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'PickupStationFare' AND Form_ID > 6000 AND Form_ID < 6500)
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000 AND Form_ID < 6500      
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name])
		VALUES(@Menu_id1, N'PickupStationFare', @Under_form_Id, 248, 1, N'Master_PickupStationFare.aspx', @Loan_Claim_Img, 1,N'PickupStationFare',4,'TRANSPORT')
	END
IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'EmployeeTransportRegistration' AND Form_ID > 6000 and Form_ID < 6500)
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000 AND Form_ID < 6500      
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name])
		VALUES(@Menu_id1, N'EmployeeTransportRegistration', @Under_form_Id, 248, 1, N'Employee_Transport_Registration.aspx', @Loan_Claim_Img, 1,N'EmployeeTransportRegistration',5,'TRANSPORT')
	END
IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'RouteVehicleDetails' AND Form_ID > 6000 and Form_ID < 6500)
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000 AND Form_ID < 6500      
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name])
		VALUES(@Menu_id1, N'RouteVehicleDetails', @Under_form_Id, 248, 1, N'Vehicle_Route_Assign.aspx', @Loan_Claim_Img, 1,N'RouteVehicleDetails',6,'TRANSPORT')
	END
--- Transport Form End ---




------------------------ BOND MODULE  ADDED BY RAJPUT ON 12092018 START -----------------------------------------------------------------


IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Bond' AND Form_ID > 6000 AND Form_ID < 6500)      
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000 AND Form_ID < 6500      
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check])
		VALUES(@Menu_id1, N'Bond', 6070, 249, 1, N'Home.aspx', @Loan_Claim_Img, 1,N'Bond',0)
	END
SELECT @Under_form_Id = Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Bond' AND Form_ID > 6000 AND Form_ID < 6500

IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Bond Master'  AND  Form_ID > 6000 AND Form_ID < 6500)
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000 AND Form_ID < 6500      
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check])
		VALUES(@Menu_id1, N'Bond Master', @Under_form_Id, 249, 1, N'Bond_Master.aspx', @Loan_Claim_Img, 1,N'Bond Master',1)
	END
IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Admin Bond Approval'  AND  Form_ID > 6000 AND Form_ID < 6500)
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000 AND Form_ID < 6500      
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check])
		VALUES(@Menu_id1, N'Admin Bond Approval', @Under_form_Id, 249, 1, N'Bond_Approve_Admin.aspx', @Loan_Claim_Img, 1,N'Admin Bond Approval',2)
	END

--------------------------- BOND MODULE FORM END -------------------------

------------------------ CANTEEN MODULE  ADDED BY RAJPUT ON 18032019 START  AS PER DISCUSSED WITH HARDIK BHAI TAKE MANU IN LOAN / CLAIM -----------------------------------------------------------------


IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Canteen' AND Form_ID > 6000 AND Form_ID < 6500)      
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000 AND Form_ID < 6500      
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check])
		VALUES(@Menu_id1, N'Canteen', 6070, 249, 1, N'Home.aspx', @Loan_Claim_Img, 1,N'Canteen',0)
	END
SELECT @Under_form_Id = Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Canteen' AND Form_ID > 6000 AND Form_ID < 6500

IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Canteen Master'  AND  Form_ID > 6000 AND Form_ID < 6500)
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000 AND Form_ID < 6500      
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check])
		VALUES(@Menu_id1, N'Canteen Master', @Under_form_Id, 249, 1, N'Master_Canteen.aspx', @Loan_Claim_Img, 1,N'Canteen Master',1)
	END
IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Canteen Management'  AND  Form_ID > 6000 AND Form_ID < 6500)
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000 AND Form_ID < 6500      
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check])
		VALUES(@Menu_id1, N'Canteen Management', @Under_form_Id, 249, 1, N'Canteen_Management.aspx', @Loan_Claim_Img, 1,N'Canteen Management',2)
	END
	IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Canteen Finger Print Details'  AND  Form_ID > 6000 AND Form_ID < 6500)
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000 AND Form_ID < 6500      
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check])
		VALUES(@Menu_id1, N'Canteen Finger Print Details', @Under_form_Id, 249, 1, N'Canteen_Finger_Print_Details.aspx', @Loan_Claim_Img, 1,N'Canteen Finger Print Details',2)
	END
	-- Added By Divyaraj Kiri on 21042023

	IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Canteen Application'  AND  Form_ID > 6000 AND Form_ID < 6500)
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000 AND Form_ID < 6500      
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check])
		VALUES(@Menu_id1, N'Canteen Application', @Under_form_Id, 249, 1, N'Canteen_Application.aspx', @Loan_Claim_Img, 1,N'Canteen Application',2)
	END
	-- Ended By Divyaraj Kiri on 21042023
--------------------------- CANTEEN MODULE FORM END -------------------------



-------Gate-Pass Menu---------Ankit 28052016

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Gate Pass' AND Form_id>7000)
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 7000 AND Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [ALIAS])
		VALUES (@Menu_id1,'Gate Pass',7005,313,1,'home.aspx',@Leave_Img,1,'Gate Pass')
	END
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Gate Pass Application' AND Form_id>7000)
	BEGIN
		DECLARE @G_UnFormID AS NUMERIC
		SELECT @G_UnFormID = Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Gate Pass' AND Form_id>7000
		
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 7000 AND Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [ALIAS])
		VALUES (@Menu_id1,'Gate Pass Application',@G_UnFormID,313,1,'Ess_GatePass_Application.aspx',@Leave_Img,1,'Gate Pass Application')
	END
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Gate Pass Approval' AND Form_id>7000)
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 7000 AND Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [ALIAS])
		VALUES (@Menu_id1,'Gate Pass Approval',@G_UnFormID,313,1,'Ess_GatePass_Approval.aspx',@Leave_Img,1,'Gate Pass Approval')
	END	
If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK)  where  Form_name = 'Gate Pass Application' and Form_ID>6000 and Form_ID<6500)
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Gate Pass Application',@Menu_id_Gatepass, 103, 1,'Gate_Pass_Application.aspx',@Leave_Img,1,'Gate Pass Application')
		
	end
If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Gate Pass Approval' and Form_ID>6000 and Form_ID<6500)
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Gate Pass Approval',@Menu_id_Gatepass, 104, 1,'Gate_Pass_Approval.aspx',@Leave_Img,1,'Gate Pass Approval')
		
	end	
If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Gate Pass Security' and Form_ID>6000 and Form_ID<6500)
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Gate Pass Security',@Menu_id_Gatepass, 105, 1,'GatePass_Security.aspx',@Leave_Img,1,'Gate Pass Security')
		
	end	

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Leave Upload' and Form_ID>6000 and Form_ID<6500)
	begin
		
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
		values (@Menu_id1,'Leave Upload',6057,102,0,'Leave_Upload.aspx',@Leave_Img,0,'Leave Upload',10)
	end


-------Gate-Pass Menu----------
----- Current Opening start sneha 02072016--modified on 12 jan 2017---
declare @recpostid as numeric(18,0)
select @recpostid =  Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name ='Recruitment Posted Detail'
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Current Opening Link' and Form_ID>9000 and Form_ID<9999)
	begin
		
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID>9000 and Form_ID<9999
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
		--values (@Menu_id1,'Current Opening Link',-1,2002,1,'View_Current_Open.aspx','',1,'Current Opening Link',0,'HRMS')
		VALUES(@Menu_id1,'Current Opening Link',@recpostid,202,1,'View_Current_Open.aspx','',0,'Current Opening Link',0,'HRMS')
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Current Opening Link New' and Form_ID>9000 and Form_ID<9999)
	begin
		
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID>9000 and Form_ID<9999
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
		values (@Menu_id1,'Current Opening Link New',-1,2003,0,'View_Current_Open_New.aspx','',0,'Current Opening Link',0,'HRMS')
	end

-- Employee Increment Approval - Ankit 21072016
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Employee Increment Approval' AND Form_id > 7000) -- Ess Panel
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 7000 AND Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [ALIAS])
		VALUES (@Menu_id1,'Employee Increment Approval',7023,351,1,'Employee_Increment_Approval.aspx',@Employee_Img,1,'Employee Increment Approval')
	END
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Employee Increment Application' and Form_ID > 6000 and Form_ID < 6500) -- Admin Panel
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [ALIAS])
		VALUES (@Menu_id1,'Employee Increment Application',6220,68,1,'Employee_Increment_Application.aspx',@Employee_Img,1,'Employee Increment Application')
	END
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Attendance Regularization' and Form_ID > 6000 and Form_ID < 6500) -- Admin Panel
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [ALIAS])
		VALUES (@Menu_id1,'Attendance Regularization',6169,75,1,'Attendance_Regularization.aspx',@Employee_Img,1,'Attendance Regularization')
	END
	-- CHANGED BY GADRIWALA MUSLIM 29092016 - DUPLICATE MENU ENTRY 
IF NOT EXISTS (SELECT Form_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE (Form_Name = 'Pre Comp Off Application' OR Form_Name = 'Pre CompOff Application') AND Form_ID > 6000 AND Form_ID < 6500)
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000 AND Form_ID < 6500  
		
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [ALIAS])
		VALUES(@Menu_id1, N'Pre Comp Off Application', 6133, 98, 1, N'PreCompOff_Application.aspx', @Leave_Img, 1, N'Pre Comp Off Application')
	END 
else
	begin
		update T0000_DEFAULT_FORM SET Form_Name = 'Pre Comp Off Application' WHERE Form_Name = 'Pre CompOff Application' AND Form_ID > 6000 AND Form_ID < 6500
	END
	-- CHANGED BY GADRIWALA MUSLIM 29092016 - DUPLICATE MENU ENTRY 

 If not exists (select Form_ID from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name = 'Pre comp-Off Approval' and Form_ID > 6000 and Form_ID < 6500)
	  begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'Pre comp-Off Approval', 6133, 98, 1, N'PreCompOff_Approval.aspx', @Leave_Img, 1, N'Pre Comp Off Approval')
	  END
	  
--Added by Sumit on 17/08/2016	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Member Roster' and Form_ID>7000 and Form_ID<7500)
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
		values (@Menu_id1,'Member Roster',@form_id_member_shift,344,1,'Employee_Roster_WO_SH_Superior.aspx',@Employee_Img,1,'Member Roster',10)
	end	
ELSE
	BEGIN
		UPDATE T0000_DEFAULT_FORM 
		SET Form_Name = 'Member Roster' , Form_Image_url = @Masters_Img
		WHERE Form_Name = 'Member Roster' 
	END	

--Added By Jaina 06-09-2016
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'View Allowance Tab' and Form_ID > 6000 and Form_ID < 6499)  
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check])
		values (@Menu_id1,'View Allowance Tab',6043, 189,1,Null,Null, 1, N'View Allowance Tab',1)
	end		
--INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url],
-- [Form_Image_url], [Is_Active_For_menu], [Alias])values(7002, N'My Profile', 7001, 302, 1, N'Default.aspx', @Employee_Img, 1, N'My Profile')

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'View Allowance Tab' and Form_ID > 7000 and Form_ID < 7500)  
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check])
		values (@Menu_id1,'View Allowance Tab',7002, 189,1,Null,Null, 1, N'View Allowance Tab',1)
	end		
----- Current Opening end---

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_Admin_Compoff' And Form_ID > 9000 and Form_ID < 10000)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 10000
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'TD_Home_Admin_Compoff',9061,1065,1,'','',1,'Comp-off Laps Details')
	end	
----- added by Prakash patel 14092016 -----
IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Increment Budget' AND Form_ID > 6000 and Form_ID < 6500)
	BEGIN
		SELECT @temp_menu_id_Increment=Form_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee-Increment' and Form_ID>6000 and Form_ID<6500
		
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000 AND Form_ID < 6500      
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name])
		VALUES(@Menu_id1, N'Increment Budget', @temp_menu_id_Increment,68, 1, N'Salary_Budgeting.aspx', @Employee_Img, 1,N'Increment Budget',6,'Payroll')
	END
ELSE
	BEGIN
		Update T0000_DEFAULT_FORM Set Sort_id_check = 7 Where Form_Name = 'Increment Budget' And Form_ID>6000 And Form_ID<6500
	end
	
	
----- added by Prakash patel 14092016 -----

--Added By Jaina 19-09-2016 Start
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Weekoff Request Application' And Form_ID > 7000 and Form_ID < 7499)
begin    
select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7499
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(@Menu_id1, N'Weekoff Request Application', 7094, 306, 1, N'Weekoff_Request.aspx', @Employee_Img, 1, N'Weekoff Request Application')
end

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Weekoff Request Approval' And Form_ID > 7000 and Form_ID < 7499)
begin    
select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7499
INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(@Menu_id1, N'Weekoff Request Approval', 7094, 306, 1, N'Weekoff_Request_Approval.aspx', @Employee_Img, 1, N'Weekoff Request Approval')
end
--Added By Jaina 19-09-2016 End

--Added by Jaina 19-12-2016 Start
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Show Hidden Allowance' and Form_ID > 6000 and Form_ID < 6499)  
	begin
		
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check])
		values (@Menu_id1,'Show Hidden Allowance',6279, 1,1,Null,Null, 1, N'Show Hidden Allowance',1)
	end		
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Show Hidden Allowance' and Form_ID > 7000 and Form_ID < 7500)
	begin
		
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check])
		values (@Menu_id1,'Show Hidden Allowance',7145, 1,1,Null,Null, 1, N'Show Hidden Allowance',1)
	end		
	
--Added by Jaina 19-12-2016 End

----- added by Mukti 15042017 (start)-----
IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Employee Increment Slabwise' AND Form_ID > 6000 and Form_ID < 6500)
	BEGIN
		SELECT @temp_menu_id_Increment=Form_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Increment Slabwise' and Form_ID>6000 and Form_ID<6500
		
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000 AND Form_ID < 6500      
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name])
		VALUES(@Menu_id1, N'Employee Increment Slabwise', @temp_menu_id_Increment,68, 1, N'Employee_Increment_Calc.aspx', @Employee_Img, 1,N'Employee Increment Slabwise',5,'Payroll')
	END
----- added by Mukti 15042017 (end)-----
--Added by Jaina 26-06-2017 Start

If exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Leave Direct Encash')
BEGIN	
		UPDATE	T0000_DEFAULT_FORM
		SET		Form_url=N'Leave_Encashment_Leavewise.aspx'
		WHERE	Form_name = 'Leave Direct Encash' And Form_ID > 6000 and Form_ID < 6500	
		
END
If exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Leave Direct Encash')
BEGIN	
		UPDATE	T0000_DEFAULT_FORM
		SET		Is_Active_For_menu=0
		WHERE	Form_name = 'LeaveWise Encashment' And Form_ID > 6000 and Form_ID < 6500	
			
END
--Added by Jaina 26-06-2017 End

--Added by Jaina 20-04-2018
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Profile Photo' and Form_ID > 7000 and Form_ID < 7500)  
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check])
		values (@Menu_id1,'Profile Photo',7002, 3,1,Null,Null, 1, N'Profile Photo',1)
	end	
	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Ticket Request')
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Ticket Request',7001,310,1,'home.aspx',@Employee_Img,1,'Ticket Request')
	end	

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Ticket Open')
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Ticket Open',7001,310,1,'Ticket_Application.aspx',@Employee_Img,1,'Ticket Open')
	end	
	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Ticket Close')
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Ticket Close',7001,310,1,'Ticket_Approval.aspx',@Employee_Img,1,'Ticket Close')
	end	
	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'KPA Type/Method/Timeframe Master' and Form_ID > 6500 and Form_ID < 6700)
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 6700
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],Sort_Id_Check,Module_name)
		values(@Menu_id1, N'KPA Type/Method/Timeframe Master', 20014, 230, 1, N'HRMS/Employe_KPA_Type.aspx', N'menu/company_structure.gif', 1, N'KPA Type/Method/Timeframe Master',1,'Appraisal2')			
	end	
	
begin  -- #region Change request Menu Start

Declare @form_id_Ticket As Numeric
set @form_id_Employee = 0
set @Sor_id_Check = 0
--set @Sort_Id = @Sort_Id + 20

select @form_id_Ticket = Form_id,@Sort_Id=Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Ticket Request' and form_id>7000

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Ticket Open' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Ticket,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Ticket Open' 
		where Form_Name = 'Ticket Open' and Form_ID>7000 
	end

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Ticket Close' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Ticket,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'Ticket Close' 
		where Form_Name = 'Ticket Close' and Form_ID>7000 
	end

End	


	
-----------------added By Jimit 24112017---------------------
			
		declare @Under_Form_Id_IDCard Numeric		
		set @Sor_id_Check = 0
		
		SELECT @Under_Form_Id_IDCard = Form_ID,@Sort_Id=Sort_Id FROM T0000_DEFAULT_FORM  WITH (NOLOCK)
				where  Form_name = 'Privileges/Scheme Assign' --and Form_ID > 6000 and Form_ID < 7000
		
		if not exists(select form_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name = 'Employee ID Card Issue' and Form_ID > 6000 and Form_ID < 6500)
			BEGIN
				select	@Menu_Id1 = ISNULL(MAX(Form_id),0) + 1						
				from	T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Id > 6000 and Form_ID < 6500					
				
				
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
				values (@Menu_id1,'Employee ID Card Issue',6250,79,1,'Employee_ID_Card_Issue.aspx',@Employee_Img,1,'Employee ID Card Issue')
			END
		if exists(select form_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name = 'Employee ID Card Issue' and Form_ID > 6000 and form_Id < 6500)
			begin 					
					select @Sor_id_Check = ISNULL(MAX(Sort_Id_Check),0) + 1	from T0000_DEFAULT_FORM WITH (NOLOCK)
					where Under_Form_ID = @Under_Form_Id_IDCard
					
										
					update	T0000_DEFAULT_FORM					
					set		Sort_ID=@Sort_Id,
							Under_Form_ID = @Under_Form_Id_IDCard,
							Sort_Id_Check=@Sor_id_Check,
							alias = 'Employee ID Card Issue'		
					where Form_Name = 'Employee ID Card Issue' and Form_ID > 6000 and form_Id < 6500 
					
			END
		
-------------------------ended----------------------------------

---------------Added BY Jimit 19112018-------------------------

		if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Assign Break Time') 
					begin			
							select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) --where Form_ID > 7500 and Form_ID < 8000  
							INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Page_Flag])
							values (@Menu_id1,'Assign Break Time',6053,2,1,NULL, NULL, 1, N'Assign Break Time','AP')
					end

-------------------Ended------------------------


-----------------added By Jimit 24112017---------------------

		declare @Under_Form_Id_LeaveApplicationReport Numeric		
		set @Sor_id_Check = 0
		
		SELECT @Under_Form_Id_LeaveApplicationReport = Form_ID,@Sort_Id=Sort_Id FROM T0000_DEFAULT_FORM  WITH (NOLOCK)
				where  Form_name = 'Leave Reports' --and Page_Flag = 'AR'	--Commented By Ramiz on 13/07/2018 ( As Flag is Updated after this Stage )
		
		
		if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Leave Application Report') 
			begin
			
				select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700 and Form_ID < 7000  
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
				values (@Menu_id1,'Leave Application Report',6703,175,1,NULL, NULL, 1, N'Leave Application Report')
			end
			if exists(select form_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name = 'Leave Application Report' and Form_ID > 6700 and Form_ID < 7000)
					begin 					
							select @Sor_id_Check = ISNULL(MAX(Sort_Id_Check),0) + 1	from T0000_DEFAULT_FORM WITH (NOLOCK)
							where Under_Form_ID = @Under_Form_Id_LeaveApplicationReport
							
												
							update	T0000_DEFAULT_FORM					
							set		Sort_ID=@Sort_Id,
									Under_Form_ID = @Under_Form_Id_LeaveApplicationReport,
									Sort_Id_Check=@Sor_id_Check,
									alias = 'Leave Application Report'		
							where Form_Name = 'Leave Application Report' and Form_ID > 6700 and Form_ID < 7000 
							
					END
					
					
		--declare @Under_Form_Id_LeaveApplicationReportMy Numeric		
		--set @Sor_id_Check = 0
		
		--SELECT @Under_Form_Id_LeaveApplicationReportMy = Form_ID,@Sort_Id=Sort_Id FROM T0000_DEFAULT_FORM 
		--		where  Form_name = 'Leave Reports' and Page_Flag = 'ER'

		if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Leave Application Report My#') 
			begin
			
				select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7500 and Form_ID < 8000  
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
				values (@Menu_id1,'Leave Application Report My#',7525,391,1,NULL, NULL, 1, N'Leave Application Report My#')
			end
		if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Leave Application Report Member#') 
			begin
			
				select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7500 and Form_ID < 8000  
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
				values (@Menu_id1,'Leave Application Report Member#',7507,347,1,NULL, NULL, 1, N'Leave Application Report Member#')
			end
		
		
		update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll_Mine.aspx?Id=9046'
		where Form_Name='Leave Application Report My#'
		
		update T0000_DEFAULT_FORM set Form_url='~/Report_Payroll.aspx?Id=9048'
		where Form_Name='Leave Application Report Member#'
		DECLARE @Sor_id as numeric = 0
		
		--if exists(select form_Id from T0000_DEFAULT_FORM where Form_Name = 'Leave Application Report My#' and Form_ID > 7500 and Form_ID < 8000)
		--			begin 					
		--					select @Sor_id = ISNULL(MAX(Sort_Id),0) + 1	from T0000_DEFAULT_FORM
		--					where Under_Form_ID = 7525
							
							
												
		--					update	T0000_DEFAULT_FORM					
		--					set		Sort_ID=@Sort_Id,									
		--							Sort_Id_Check=@Sort_Id,
		--							alias = 'Leave Application Report My#'		
		--					where Form_Name = 'Leave Application Report My#' and Form_ID > 7500 and Form_ID < 8000 
							
		--			END	
-------------------------ended----------------------------------

---- Transport Report Start ----------

--IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WHERE Form_name = 'Transport Reports' AND Form_ID > 6700 AND Form_ID < 7000)
--	BEGIN
--		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WHERE Form_ID > 6700 and Form_ID < 7000
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name])
--		VALUES(@Menu_id1,'Transport Reports',6163,199,1,'','',1,'Transport Reports',0,'TRANSPORT')
--	END
	
--SELECT @Under_form_Id = Form_id FROM T0000_DEFAULT_FORM WHERE Form_name = 'Transport Reports' AND Form_ID > 6700 AND Form_ID < 7000

--IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WHERE Form_name = 'Route Wise Employee Report' AND Form_ID > 6700 AND Form_ID < 7000)
--	BEGIN
--		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WHERE Form_ID > 6700 and Form_ID < 7000
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name])
--		VALUES(@Menu_id1,'Route Wise Employee Report',@Under_form_Id,199,1,'','',1,'Route Wise Employee Report',1,'TRANSPORT')
--	END
--IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WHERE Form_name = 'Section Wise Transportation Report' AND Form_ID > 6700 AND Form_ID < 7000)
--	BEGIN
--		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WHERE Form_ID > 6700 and Form_ID < 7000
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name])
--		VALUES(@Menu_id1,'Section Wise Transportation Report',@Under_form_Id,199,1,'','',1,'Section Wise Transportation Report',2,'TRANSPORT')
--	END
--IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WHERE Form_name = 'Route Wise Employee Related Report' AND Form_ID > 6700 AND Form_ID < 7000)
--	BEGIN
--		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WHERE Form_ID > 6700 and Form_ID < 7000
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name])
--		VALUES(@Menu_id1,'Route Wise Employee Related Report',@Under_form_Id,199,1,'','',1,'Route Wise Employee Related Report',3,'TRANSPORT')
--	END
--IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WHERE Form_name = 'Route Details Report' AND Form_ID > 6700 AND Form_ID < 7000)
--	BEGIN
--		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WHERE Form_ID > 6700 and Form_ID < 7000
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name])
--		VALUES(@Menu_id1,'Route Details Report',@Under_form_Id,199,1,'','',1,'Route Details Report',4,'TRANSPORT')
--	END
--IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WHERE Form_name = 'Private Vehicle Driver And Route Details' AND Form_ID > 6700 AND Form_ID < 7000)
--	BEGIN
--		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WHERE Form_ID > 6700 and Form_ID < 7000
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name])
--		VALUES(@Menu_id1,'Private Vehicle Driver And Route Details',@Under_form_Id,199,1,'','',1,'Private Vehicle Driver & Route Details',5,'TRANSPORT')
--	END
--IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WHERE Form_name = 'Staff Bus Driver And Route Details' AND Form_ID > 6700 AND Form_ID < 7000)
--	BEGIN
--		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WHERE Form_ID > 6700 and Form_ID < 7000
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name])
--		VALUES(@Menu_id1,'Staff Bus Driver And Route Details',@Under_form_Id,199,1,'','',1,'Staff Bus Driver & Route Details',6,'TRANSPORT')
--	END
--IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WHERE Form_name = 'Route Wise Pick Station And Fair' AND Form_ID > 6700 AND Form_ID < 7000)
--	BEGIN
--		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WHERE Form_ID > 6700 and Form_ID < 7000
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name])
--		VALUES(@Menu_id1,'Route Wise Pick Station And Fair',@Under_form_Id,199,1,'','',1,'Route Wise Pick Station & Fair',7,'TRANSPORT')
--	END
---- Transport Report End ----------	
------------------------ Transport Module Add by Prakash Patel 01032016 End -------------------------------------------------------------------

-------binal 14102019------
IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name =  'Dashboard Employee'  AND Form_ID > 9200 AND Form_ID < 10000 )   
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 9200  AND Form_ID < 10000
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Page_Flag])
		VALUES(@Menu_id1, N'Dashboard Employee', 0, 0, 0, N'Dashboard_Employee.aspx', '', 0,N'Dashboard Employee',0,'DE')
	END

	IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name =  'Dashboard Employee' AND Form_ID > 9200 AND Form_ID < 10000 )   
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 9200  AND Form_ID < 10000
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Page_Flag])
		VALUES(@Menu_id1, N'Dashboard Salary', 0, 0, 0, N'Dashboard_Salary.aspx', '', 0,N'Dashboard Salary',0,'DE')
	END

		IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name =  'Dashboard Attendance Leave' AND Form_ID > 9200 AND Form_ID < 10000 )   
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 9200  AND Form_ID < 10000
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Page_Flag])
		VALUES(@Menu_id1, N'Dashboard Attendance Leave', 0, 0, 0, N' Dashboard_Attendance', '', 0,N'Dashboard Attendance Leave',0,'DE')
	END
-----end binal 14102019----

--added By Krushna 17122019--
--updated binal due to useradmin not access the report 11012020
	IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Travel GST Report' and Page_Flag ='AR')
		BEGIN
			--SELECT @temp_menu_id_Increment=Form_ID FROM T0000_DEFAULT_FORM where  Form_name = 'Travel GST Report' and Form_ID>6000 and Form_ID<6500
			--print 'a'
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_Flag])
			VALUES(@Menu_id1, N'Travel GST Report', 6712,0, 1, N'Report_Payroll.aspx', null, 1,N'Travel GST Report',5,'Payroll','AR')
			--print 'b'
		END


		IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'TD_CONSOLIDATE_310' and Page_Flag ='DA')
		BEGIN
			--SELECT @temp_menu_id_Increment=Form_ID FROM T0000_DEFAULT_FORM where  Form_name = 'Travel GST Report' and Form_ID>6000 and Form_ID<6500
			--print 'a'
			Declare @U_Form_Id numeric
			Set @U_Form_Id=0
			Select @U_Form_Id=Form_ID from T0000_DEFAULT_FORM WITH (NOLOCK) where (Form_Name ='Company Consolidate Info' or Alias='Company Consolidate Info') and Page_Flag ='DA'
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_Flag])
			VALUES(@Menu_id1, N'TD_CONSOLIDATE_310', @U_Form_Id,0, 1, N'Cmp_consolidate_Details.aspx', null, 0,N'Company Consolidate Details',5,'Payroll','DA')
			--print 'b'
		END

--updated binal due to useradmin not access the report 11012020

--Deepal 04092020
IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Employee WorkPlan' and Page_Flag ='AR')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_Flag])
			VALUES(@Menu_id1, N'Employee WorkPlan', 20120,13, 1, N'Report_Customized.aspx', null, 1,N'Employee WorkPlan',1,'Payroll','AR')
END

IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Employee Mobile Stock Sales' and Page_Flag ='AR')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_Flag])
			VALUES(@Menu_id1, N'Employee Mobile Stock Sales', 20120,14, 1, N'Report_Customized.aspx', null, 1,N'Employee Mobile Stock Sales',1,'Payroll','AR')
END

IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Mobile Model Master' and Page_Flag ='AP')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_Flag])
			VALUES(@Menu_id1, N'Mobile Model Master', 6245,64, 1, N'Master_MobileModel.aspx', 'menu/master.gif' , 1,N'Mobile Model Master',14,'Payroll','AP')
			
END
IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Mobile Store Master' and Page_Flag ='AP')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_Flag])
			VALUES(@Menu_id1, N'Mobile Store Master', 6245,64, 1, N'Master_MobileStore.aspx', 'menu/master.gif' , 1,N'Mobile Store Master',15,'Payroll','AP')
			
END
IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Mobile Store And Employee Assign' and Page_Flag ='AP')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_Flag])
			VALUES(@Menu_id1, N'Mobile Store And Employee Assign', 6245,79, 1, N'Master_MobileStoreEmpAssign.aspx', 'menu/master.gif' , 1,N'Mobile Store And Employee Assign',14,'Payroll','AP')
			
END

IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Band Master' and Page_Flag ='AP')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_Flag])
			VALUES(@Menu_id1, N'Band Master', 6245,64, 1, N'MasterBand.aspx', 'menu/master.gif' , 1,N'Band Master',15,'Payroll','AP')
			
END

--END Deepal 04092020

--Added by Mr.Mehul on 12012023

IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Category Skill Master' and Page_Flag ='AP')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_Flag])
			VALUES(@Menu_id1, N'Skill Master', 6260,2003, 1, N'CategorySkill_Master.aspx', 'menu/master.gif' , 1,N'Category Skill Master',16,'Payroll','AP')
			
END


IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'SubCategory Skill Master' and Page_Flag ='AP')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_Flag])
			VALUES(@Menu_id1, N'SubSkill Master', 6260,2004, 1, N'SubCategorySkill_Master.aspx', 'menu/master.gif' , 1,N'SubCategory Skill Master',17,'Payroll','AP')
			
END

IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Level Skill Master' and Page_Flag ='AP')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_Flag])
			VALUES(@Menu_id1, N'Level Skill Master', 6260,2005, 1, N'LevelSkill_Master.aspx', 'menu/master.gif' , 1,N'Level Skill Master',18,'Payroll','AP')
			
END

--Added by Divyaraj Kiri on 20032023

IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Certificate Skill Mapping' and Page_Flag ='AP')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_Flag])
			VALUES(@Menu_id1, N'CertificateSkill Mapping', 6260,2006, 1, N'CertificateSkill_Mapping.aspx', 'menu/master.gif' , 1,N'Certificate Skill Mapping',19,'Payroll','AP')
			
END

-- Ended by Divyaraj Kiri on 20032023

--Added by Mr.Mehul on 12012023

--end krushna 17122019

-- Task Management Forms, Added by Darshan 07/01/2021
-- added unit and unit type masters by mehul for claim  on 28/7/2021
-- added bill type master by mehul for claim on 29/7/2021
--added fuel conversion master by mehul for claim on 11/8/2021

	IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Fuel Conversion Master' and Page_Flag = 'AP')
	BEGIN
		
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],Module_name,Page_Flag)
		VALUES(@Menu_id1, N'Fuel Conversion Master', 6077,113, 1, N'Master_Fuel_Conversion.aspx', @Loan_Claim_Img , 1,N'Fuel Conversion Master','Payroll','AP')
	END

	IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Bill Type Master' and Page_Flag = 'AP')
	BEGIN
		
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],Module_name,Page_Flag)
		VALUES(@Menu_id1, N'Bill Type Master', 6077,114, 1, N'Master_Bill_Type.aspx', @Loan_Claim_Img , 1,N'Bill Type Master','Payroll','AP')
	END
	

	IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Unit Type Master' and Page_Flag = 'AP')
	BEGIN
		
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],Module_name,Page_Flag)
		VALUES(@Menu_id1, N'Unit Type Master', 6077,115, 1, N'Master_Unit_Type.aspx', @Loan_Claim_Img , 1,N'Unit Type Master','Payroll','AP')
	END


	IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Unit Master' and Page_Flag = 'AP')
	BEGIN
		
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],Module_name,Page_Flag)
		VALUES(@Menu_id1, N'Unit Master', 6077,116, 1, N'Master_Unit.aspx', @Loan_Claim_Img , 1,N'Unit Master','Payroll','AP')
	END

	


	IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Task Management' and Page_Flag ='AP')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_Flag])
			VALUES(@Menu_id1, N'Task Management', -1,0, 1, N'http://ess.orangetechnolab.com/PSB_LOAN_test/admin_associates/Home.aspx', 'menu/master.gif' , 1,N'Task Management',0,'TASK','AP')
		END
				
	Set @U_Form_Id=0
	Select @U_Form_Id=Form_ID from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name ='Task Management' and Page_Flag ='AP'

	IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Task Masters' and Page_Flag ='AP')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_Flag])
			VALUES(@Menu_id1, N'Task Masters', @U_Form_Id ,0, 1, N'', 'menu/master.gif' , 1,N'Task Masters',1,'TASK','AP')
		END
	ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET @Under_form_Id = @U_Form_Id WHERE Form_Name = 'Task Masters' and Page_Flag ='AP'
		END

	IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Employee Role' and Page_Flag ='AP')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_Flag])
			VALUES(@Menu_id1, N'Employee Role', @U_Form_Id ,0, 1, N'/Account/AssignRole', 'menu/master.gif' , 1,N'Employee Role',1,'TASK','AP')
		END
	ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET @Under_form_Id = @U_Form_Id WHERE Form_Name = 'Employee Role' and Page_Flag ='AP'
		END

	IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Task Center' and Page_Flag ='AP')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_Flag])
			VALUES(@Menu_id1, N'Task Center', @U_Form_Id ,0, 1, N'/Account/Dashboard', 'menu/master.gif' , 1,N'Task Center',1,'TASK','AP')
		END
	ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET @Under_form_Id = @U_Form_Id WHERE Form_Name = 'Task Center' and Page_Flag ='AP'
		END

	IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Overview' and Page_Flag ='AP')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_Flag])
			VALUES(@Menu_id1, N'Overview', @U_Form_Id ,0, 1, N'/Account/TaskDashboard', 'menu/master.gif' , 1,N'Overview',1,'TASK','AP')
		END
	ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET @Under_form_Id = @U_Form_Id WHERE Form_Name = 'Overview' and Page_Flag ='AP'
		END

	Set @U_Form_Id=0
	Select @U_Form_Id=Form_ID from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name ='Task Masters' and Page_Flag ='AP'

	IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Role Masters' and Page_Flag ='AP')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_Flag])
			VALUES(@Menu_id1, N'Role Masters', @U_Form_Id ,0, 1, N'/Account/RoleMaster', 'menu/master.gif' , 1,N'Role Masters',1,'TASK','AP')
		END
	ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET @Under_form_Id = @U_Form_Id WHERE Form_Name = 'Role Masters' and Page_Flag ='AP'
		END
			
	IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Status Masters' and Page_Flag ='AP')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_Flag])
			VALUES(@Menu_id1, N'Status Masters', @U_Form_Id ,0, 1, N'/Account/StatusMaster', 'menu/master.gif' , 1,N'Status Masters',2,'TASK','AP')
		END
	ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET @Under_form_Id = @U_Form_Id WHERE Form_Name = 'Status Masters' and Page_Flag ='AP'
		END

	IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Task Type Masters' and Page_Flag ='AP')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_Flag])
			VALUES(@Menu_id1, N'Task Type Masters', @U_Form_Id ,0, 1, N'/Account/TaskTypeMaster', 'menu/master.gif' , 1,N'Task Type Masters',3,'TASK','AP')
		END
	ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET @Under_form_Id = @U_Form_Id WHERE Form_Name = 'Task Type Masters' and Page_Flag ='AP'
		END

	IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Task Category Masters' and Page_Flag ='AP')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_Flag])
			VALUES(@Menu_id1, N'Task Category Masters', @U_Form_Id ,0, 1, N'/Account/TaskCategoryMaster', 'menu/master.gif' , 1,N'Task Category Masters',4,'TASK','AP')
		END
	ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET @Under_form_Id = @U_Form_Id WHERE Form_Name = 'Task Category Masters' and Page_Flag ='AP'
		END

	IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Priority Masters' and Page_Flag ='AP')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_Flag])
			VALUES(@Menu_id1, N'Priority Masters', @U_Form_Id ,0, 1, N'/Account/PriorityMaster', 'menu/master.gif' , 1,N'Priority Masters',5,'TASK','AP')
		END
	ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET @Under_form_Id = @U_Form_Id WHERE Form_Name = 'Priority Masters' and Page_Flag ='AP'
		END

	IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Project Masters' and Page_Flag ='AP')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_Flag])
			VALUES(@Menu_id1, N'Project Masters', @U_Form_Id ,0, 1, N'/Account/ProjectMaster', 'menu/master.gif' , 1,N'Project Masters',6,'TASK','AP')
		END
	ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET @Under_form_Id = @U_Form_Id WHERE Form_Name = 'Project Masters' and Page_Flag ='AP'
		END

	IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Activity Masters' and Page_Flag ='AP')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_Flag])
			VALUES(@Menu_id1, N'Activity Masters', @U_Form_Id ,0, 1, N'/Account/ActivityMaster', 'menu/master.gif' , 1,N'Activity Masters',7,'TASK','AP')
		END
	ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET @Under_form_Id = @U_Form_Id WHERE Form_Name = 'Activity Masters' and Page_Flag ='AP'
		END

	IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Task Management' and Page_Flag ='EP')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_Flag])
			VALUES(@Menu_id1, N'Task Management', -1,0, 1, N'http://ess.orangetechnolab.com/PSB_LOAN_test/admin_associates/Home.aspx', 'menu/master.gif' , 1,N'Task Management',0,'TASK','EP')			
		END
	
	Set @U_Form_Id=0
	Select @U_Form_Id=Form_ID from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name ='Task Management' and Page_Flag ='EP'

	IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Task Center' and Page_Flag ='EP')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_Flag])
			VALUES(@Menu_id1, N'Task Center', @U_Form_Id ,0, 1, N'/Account/Dashboard', 'menu/master.gif' , 1,N'Task Center',1,'TASK','EP')
		END
	ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET @Under_form_Id = @U_Form_Id WHERE Form_Name = 'Task Center' and Page_Flag ='EP'
		END

	IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Overview' and Page_Flag ='EP')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_Flag])
			VALUES(@Menu_id1, N'Overview', @U_Form_Id ,0, 1, N'/Account/TaskDashboard', 'menu/master.gif' , 1,N'Overview',1,'TASK','EP')
		END
	ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET @Under_form_Id = @U_Form_Id WHERE Form_Name = 'Overview' and Page_Flag ='EP'
		END

	--IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Canteen' and Page_Flag ='EP')
	--	BEGIN
	--		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
	--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_Flag])
	--		VALUES(@Menu_id1, N'Canteen', -1 ,0, 1, N'Home.aspx', 'menu/employee.gif' , 1,N'Canteen',1,'','EP')
	--END
	
	
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Canteen' AND Form_ID > 7000 AND Form_ID < 7500)
			BEGIN     
				select @Menu_id1 = isnull(MAX(Form_id),7500) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
				 
				set @Temp_Form_ID1   = @Menu_id1
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],  
				[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_Flag])values  
				
				(@Menu_id1,N'Canteen',-1, 800, 1, NULL, 'menu/employee.gif' ,1,N'Canteen',0,'Canteen','EP') 
				 
	END  
	
	Set @U_Form_Id=0
	Select @U_Form_Id=Form_ID from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name ='Canteen' and Page_Flag ='EP'

	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Canteen Dashboard' AND Form_ID > 7000 AND Form_ID < 7500)
			BEGIN     
				select @Menu_id1 = isnull(MAX(Form_id),7500) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
				 
				set @Temp_Form_ID1   = @Menu_id1
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],  
				[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_Flag])values  
				
				(@Menu_id1,N'Canteen Dashboard',@U_Form_Id, 1, 1, 'Emp_Canteen.aspx', 'menu/employee.gif' ,1,N'Canteen Dashboard',0,'Canteen','EP') 
				 
	END  
	-- Added By Divyaraj Kiri on 21042023
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Canteen Application' AND Form_ID > 7000 AND Form_ID < 7500)
			BEGIN     
				select @Menu_id1 = isnull(MAX(Form_id),7500) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
				 
				set @Temp_Form_ID1   = @Menu_id1
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],  
				[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_Flag])values  
				
				(@Menu_id1,N'Canteen Application',@U_Form_Id, 1, 1, 'Ess_Canteen_Application.aspx', 'menu/employee.gif' ,1,N'Canteen Application',0,'Canteen','EP') 
				 
	END
	-- Ended By Divyaraj Kiri on 21042023
-- Task Management Forms End, Added by Darshan 07/01/2021


-- Add by Deepal 24/08/2020
DECLARE @FormID as Numeric(18,0)
SELECT @FormID = Form_ID FROM T0000_DEFAULT_FORM WHERE Form_Name = 'Customize Report' and Page_Flag = 'AR'

IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE  FORM_NAME = 'Canteen Customize' AND PAGE_FLAG='AR')
BEGIN    
		SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM
		INSERT INTO [DBO].[T0000_DEFAULT_FORM]([FORM_ID], [FORM_NAME], [UNDER_FORM_ID], [SORT_ID], [FORM_TYPE], [FORM_URL], [FORM_IMAGE_URL], [IS_ACTIVE_FOR_MENU], [ALIAS],[Sort_Id_Check],[Module_name],[Page_Flag])
		VALUES (@MENU_ID1,N'Canteen Customize',@FormID ,1,1,'',NULL,1,N'Canteen Customize',1,'Payroll','AR')
END

set @FormID = 0
SELECT @FormID = Form_ID FROM T0000_DEFAULT_FORM WHERE Form_Name = 'Canteen Customize' and Page_Flag = 'AR'
IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE  FORM_NAME = 'Canteen Report - Employee Wise' AND PAGE_FLAG='AR')
	BEGIN    
		SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM
		INSERT INTO [DBO].[T0000_DEFAULT_FORM]([FORM_ID], [FORM_NAME], [UNDER_FORM_ID], [SORT_ID], [FORM_TYPE], [FORM_URL], [FORM_IMAGE_URL], [IS_ACTIVE_FOR_MENU], [ALIAS],[Sort_Id_Check],[Module_name],[Page_Flag])
		VALUES (@MENU_ID1,N'Canteen Report - Employee Wise',@FormID ,1,1,'',NULL,1,N'Canteen Report - Employee Wise',1,'Payroll','AR')
		
		IF NOT EXISTS (SELECT FORM_ID FROM T0250_CUSTOMIZED_REPORT WHERE ReportName = 'Canteen Report - Employee Wise' and TypeID = 10)
		BEGIN 
			insert into T0250_CUSTOMIZED_REPORT Values (141,'Canteen Report - Employee Wise',10,'Canteen',@MENU_ID1)
		END
		
	END

IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE  FORM_NAME = 'Canteen Details Report' AND PAGE_FLAG='AR')
	BEGIN    
		SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM
		INSERT INTO [DBO].[T0000_DEFAULT_FORM]([FORM_ID], [FORM_NAME], [UNDER_FORM_ID], [SORT_ID], [FORM_TYPE], [FORM_URL], [FORM_IMAGE_URL], [IS_ACTIVE_FOR_MENU], [ALIAS],[Sort_Id_Check],[Module_name],[Page_Flag])
		VALUES (@MENU_ID1,N'Canteen Details Report',@FormID ,2,1,'',NULL,1,N'Canteen Details Report',1,'Payroll','AR')

		IF NOT EXISTS (SELECT FORM_ID FROM T0250_CUSTOMIZED_REPORT WHERE ReportName = 'Canteen Details Report' and TypeID = 10)
		BEGIN 
			insert into T0250_CUSTOMIZED_REPORT Values (142,'Canteen Details Report',10,'Canteen',@MENU_ID1)
		END
	END
IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE  FORM_NAME = 'Canteen Exemption Report' AND PAGE_FLAG='AR')
	BEGIN    
		SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM
		INSERT INTO [DBO].[T0000_DEFAULT_FORM]([FORM_ID], [FORM_NAME], [UNDER_FORM_ID], [SORT_ID], [FORM_TYPE], [FORM_URL], [FORM_IMAGE_URL], [IS_ACTIVE_FOR_MENU], [ALIAS],[Sort_Id_Check],[Module_name],[Page_Flag])
		VALUES (@MENU_ID1,N'Canteen Exemption Report',@FormID ,3,1,'',NULL,1,N'Canteen Exemption Report',1,'Payroll','AR')
		
		IF NOT EXISTS (SELECT FORM_ID FROM T0250_CUSTOMIZED_REPORT WHERE ReportName = 'Canteen Exemption Report' and TypeID = 10)
		BEGIN 
			insert into T0250_CUSTOMIZED_REPORT Values (143,'Canteen Exemption Report',10,'Canteen',@MENU_ID1)
		END
	END

	-- Added by Divyaraj kiri on 10042023
	IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE  FORM_NAME = 'Canteen Application Report' AND PAGE_FLAG='AR')
	BEGIN    
		SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM
		INSERT INTO [DBO].[T0000_DEFAULT_FORM]([FORM_ID], [FORM_NAME], [UNDER_FORM_ID], [SORT_ID], [FORM_TYPE], [FORM_URL], [FORM_IMAGE_URL], [IS_ACTIVE_FOR_MENU], [ALIAS],[Sort_Id_Check],[Module_name],[Page_Flag])
		VALUES (@MENU_ID1,N'Canteen Application Report',@FormID ,3,1,'',NULL,1,N'Canteen Application Report',1,'Payroll','AR')
		
		IF NOT EXISTS (SELECT FORM_ID FROM T0250_CUSTOMIZED_REPORT WHERE ReportName = 'Canteen Application Report' and TypeID = 10)
		BEGIN 
			insert into T0250_CUSTOMIZED_REPORT Values (161,'Canteen Application Report',10,'Canteen',@MENU_ID1)
		END
	END
	-- Ended by Divyaraj kiri on 10042023

-- END by Deepal 24/08/2020

--Start added by Niraj(22082022)
set @FormID = 0
SELECT @FormID = Form_ID FROM T0000_DEFAULT_FORM WHERE Form_Name = 'Customize Report' and Page_Flag = 'AR'

IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE  FORM_NAME = 'Ticket Customize' AND PAGE_FLAG='AR')
BEGIN    
		SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM
		INSERT INTO [DBO].[T0000_DEFAULT_FORM]([FORM_ID], [FORM_NAME], [UNDER_FORM_ID], [SORT_ID], [FORM_TYPE], [FORM_URL], [FORM_IMAGE_URL], [IS_ACTIVE_FOR_MENU], [ALIAS],[Sort_Id_Check],[Module_name],[Page_Flag])
		VALUES (@MENU_ID1,N'Ticket Customize',@FormID ,1,1,'',NULL,1,N'Ticket Customize',1,'Payroll','AR')
END


set @FormID = 0
SELECT @FormID = Form_ID FROM T0000_DEFAULT_FORM WHERE Form_Name = 'Ticket Customize' and Page_Flag = 'AR'

IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE  FORM_NAME = 'Ticket Status' AND PAGE_FLAG='AR')
	BEGIN    
		SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM
		INSERT INTO [DBO].[T0000_DEFAULT_FORM]([FORM_ID], [FORM_NAME], [UNDER_FORM_ID], [SORT_ID], [FORM_TYPE], [FORM_URL], [FORM_IMAGE_URL], [IS_ACTIVE_FOR_MENU], [ALIAS],[Sort_Id_Check],[Module_name],[Page_Flag])
		VALUES (@MENU_ID1,N'Ticket Status',@FormID ,1,1,'',NULL,1,N'Ticket Status',1,'Payroll','AR')
		
		IF NOT EXISTS (SELECT FORM_ID FROM T0250_CUSTOMIZED_REPORT WHERE ReportName = 'Ticket Status' and TypeID = 13)
		BEGIN 
			insert into T0250_CUSTOMIZED_REPORT Values (146,'Ticket Status',11,'Ticket',@MENU_ID1)
		END
		
	END
--End added by Niraj(22082022)

--Added by Ronakk 29042022

set @FormID = 0
SELECT @FormID = Form_ID FROM T0000_DEFAULT_FORM WHERE Form_Name = 'Customize Report' and Page_Flag = 'AR'

IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE  FORM_NAME = 'Grievance Customize' AND PAGE_FLAG='AR')
BEGIN    
		SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM
		INSERT INTO [DBO].[T0000_DEFAULT_FORM]([FORM_ID], [FORM_NAME], [UNDER_FORM_ID], [SORT_ID], [FORM_TYPE], [FORM_URL], [FORM_IMAGE_URL], [IS_ACTIVE_FOR_MENU], [ALIAS],[Sort_Id_Check],[Module_name],[Page_Flag])
		VALUES (@MENU_ID1,N'Grievance Customize',@FormID ,1,1,'',NULL,1,N'Grievance Customize',1,'Payroll','AR')
END


set @FormID = 0
SELECT @FormID = Form_ID FROM T0000_DEFAULT_FORM WHERE Form_Name = 'Grievance Customize' and Page_Flag = 'AR'

IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE  FORM_NAME = 'Grievance Register' AND PAGE_FLAG='AR')
	BEGIN    
		SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM
		INSERT INTO [DBO].[T0000_DEFAULT_FORM]([FORM_ID], [FORM_NAME], [UNDER_FORM_ID], [SORT_ID], [FORM_TYPE], [FORM_URL], [FORM_IMAGE_URL], [IS_ACTIVE_FOR_MENU], [ALIAS],[Sort_Id_Check],[Module_name],[Page_Flag])
		VALUES (@MENU_ID1,N'Grievance Register',@FormID ,1,1,'',NULL,1,N'Grievance Register',1,'Payroll','AR')
		
		IF NOT EXISTS (SELECT FORM_ID FROM T0250_CUSTOMIZED_REPORT WHERE ReportName = 'Grievance Register' and TypeID = 13)
		BEGIN 
			insert into T0250_CUSTOMIZED_REPORT Values (151,'Grievance Register',13,'Grievance',@MENU_ID1)
		END
		
	END
--End by Ronakk 29042022

--Added by mansi 25-08-22

set @FormID = 0
SELECT @FormID = Form_ID FROM T0000_DEFAULT_FORM WHERE Form_Name = 'Customize Report' and Page_Flag = 'AR'

IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE  FORM_NAME = 'File Management Customize' AND PAGE_FLAG='AR')
BEGIN    
		SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM
		INSERT INTO [DBO].[T0000_DEFAULT_FORM]([FORM_ID], [FORM_NAME], [UNDER_FORM_ID], [SORT_ID], [FORM_TYPE], [FORM_URL], [FORM_IMAGE_URL], [IS_ACTIVE_FOR_MENU], [ALIAS],[Sort_Id_Check],[Module_name],[Page_Flag])
		VALUES (@MENU_ID1,N'File Management Customize',@FormID ,1,1,'',NULL,1,N'File Management Customize',1,'Payroll','AR')
END


set @FormID = 0
SELECT @FormID = Form_ID FROM T0000_DEFAULT_FORM WHERE Form_Name = 'File Management Customize' and Page_Flag = 'AR'

IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE  FORM_NAME = 'File Management Register' AND PAGE_FLAG='AR')
	BEGIN    
		SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM
		INSERT INTO [DBO].[T0000_DEFAULT_FORM]([FORM_ID], [FORM_NAME], [UNDER_FORM_ID], [SORT_ID], [FORM_TYPE], [FORM_URL], [FORM_IMAGE_URL], [IS_ACTIVE_FOR_MENU], [ALIAS],[Sort_Id_Check],[Module_name],[Page_Flag])
		VALUES (@MENU_ID1,N'File Management Register',@FormID ,1,1,'',NULL,1,N'File Management Register',1,'Payroll','AR')
		
		IF NOT EXISTS (SELECT FORM_ID FROM T0250_CUSTOMIZED_REPORT WHERE ReportName = 'File Management Register' and TypeID = 15)
		BEGIN 
			insert into T0250_CUSTOMIZED_REPORT Values (156,'File Management Register',15,'File Management',@MENU_ID1)
		END
		
	END
--End by mansi 25-08-22



--Added by Ronakk 29042022


IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE  FORM_NAME = 'Claim Report Summary' AND PAGE_FLAG='AR')
	BEGIN    
		SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM
		INSERT INTO [DBO].[T0000_DEFAULT_FORM]([FORM_ID], [FORM_NAME], [UNDER_FORM_ID], [SORT_ID], [FORM_TYPE], [FORM_URL], [FORM_IMAGE_URL], [IS_ACTIVE_FOR_MENU], [ALIAS],[Sort_Id_Check],[Module_name],[Page_Flag])
		VALUES (@MENU_ID1,N'Claim Report Summary',20163 ,1,1,'',NULL,1,N'Claim Report Summary',1,'Payroll','AR')
		
		IF NOT EXISTS (SELECT FORM_ID FROM T0250_CUSTOMIZED_REPORT WHERE ReportName = 'Claim Report Summary' and TypeID = 15)
		BEGIN 
			insert into T0250_CUSTOMIZED_REPORT Values (153,'Claim Report Summary',8,'Claim',20264)
		END
		
	END

	-- Added by yogesh on 31082022
	--set @FormID = 0
	IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE  FORM_NAME = 'SAP Attendance InOut' AND PAGE_FLAG='AR')
	BEGIN    
		SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM
		INSERT INTO [DBO].[T0000_DEFAULT_FORM]([FORM_ID], [FORM_NAME], [UNDER_FORM_ID], [SORT_ID], [FORM_TYPE], [FORM_URL], [FORM_IMAGE_URL], [IS_ACTIVE_FOR_MENU], [ALIAS],[Sort_Id_Check],[Module_name],[Page_Flag])
		VALUES (@MENU_ID1,N'SAP Attendance InOut',20161 ,1,1,'',NULL,1,N'SAP Attendance InOut',1,'Payroll','AR')
		
		IF NOT EXISTS (SELECT FORM_ID FROM T0250_CUSTOMIZED_REPORT WHERE ReportName = 'SAP Attendance InOut' and TypeID = 5)
		BEGIN 
			insert into T0250_CUSTOMIZED_REPORT Values (157,'SAP Attendance InOut',5,'Attendance',20408)	
		END
		
	END






--Added by Mr.Mehul 05082022

IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE  FORM_NAME = 'All Dependent Details' AND PAGE_FLAG='AR')
	BEGIN    
		SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM
		INSERT INTO [DBO].[T0000_DEFAULT_FORM]([FORM_ID], [FORM_NAME], [UNDER_FORM_ID], [SORT_ID], [FORM_TYPE], [FORM_URL], [FORM_IMAGE_URL], [IS_ACTIVE_FOR_MENU], [ALIAS],[Sort_Id_Check],[Module_name],[Page_Flag])
		VALUES (@MENU_ID1,N'All Dependent Details',@FormID ,1,1,'',NULL,1,N'All Dependent Details',1,'Payroll','AR')
		
		IF NOT EXISTS (SELECT FORM_ID FROM T0250_CUSTOMIZED_REPORT WHERE ReportName = 'All Dependent Details' and TypeID = 13)
		BEGIN 
			insert into T0250_CUSTOMIZED_REPORT Values (154,'All Dependent Details',15,'Medical',@MENU_ID1)
		END
		
END

IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE  FORM_NAME = 'Dependents Import Sample' AND PAGE_FLAG='AR')
	BEGIN    
		SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM
		INSERT INTO [DBO].[T0000_DEFAULT_FORM]([FORM_ID], [FORM_NAME], [UNDER_FORM_ID], [SORT_ID], [FORM_TYPE], [FORM_URL], [FORM_IMAGE_URL], [IS_ACTIVE_FOR_MENU], [ALIAS],[Sort_Id_Check],[Module_name],[Page_Flag])
		VALUES (@MENU_ID1,N'Dependents Import Sample',@FormID ,1,1,'',NULL,1,N'Dependents Import Sample',1,'Payroll','AR')
		
		IF NOT EXISTS (SELECT FORM_ID FROM T0250_CUSTOMIZED_REPORT WHERE ReportName = 'Dependents Import Sample' and TypeID = 13)
		BEGIN 
			insert into T0250_CUSTOMIZED_REPORT Values (152,'Dependents Import Sample',14,'Medical',@MENU_ID1)
		END
		
END


IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE  FORM_NAME = 'Medical Application Report' AND PAGE_FLAG='AR')
	BEGIN    
		SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM
		INSERT INTO [DBO].[T0000_DEFAULT_FORM]([FORM_ID], [FORM_NAME], [UNDER_FORM_ID], [SORT_ID], [FORM_TYPE], [FORM_URL], [FORM_IMAGE_URL], [IS_ACTIVE_FOR_MENU], [ALIAS],[Sort_Id_Check],[Module_name],[Page_Flag])
		VALUES (@MENU_ID1,N'Medical Application Report',@FormID ,1,1,'',NULL,1,N'Medical Application Report',1,'Payroll','AR')
		
		IF NOT EXISTS (SELECT FORM_ID FROM T0250_CUSTOMIZED_REPORT WHERE ReportName = 'Medical Application Report' and TypeID = 13)
		BEGIN 
			insert into T0250_CUSTOMIZED_REPORT Values (149,'Medical Application Report',12,'Medical',@MENU_ID1)
		END
		
END

set @FormID = 0
SELECT @FormID = Form_ID FROM T0000_DEFAULT_FORM WHERE Form_Name = 'AX Mapping Slab Master' and Page_Flag = 'AR'

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'AX Mapping Slab Master') --- added by Mr.Mehul on 24082022
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000  and Form_ID < 6499  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'AX Mapping Slab Master',6001,16,1,'Master_Cost_Center_Slab.aspx', @Control_Pnl_Img, 1, N'AX Mapping Slab Master')

		--IF NOT EXISTS (SELECT FORM_ID FROM T0250_CUSTOMIZED_REPORT WHERE ReportName = 'AX Mapping Slab Master' and TypeID = 13)
		--BEGIN 
		--	insert into T0250_CUSTOMIZED_REPORT Values (155,'AX Mapping Slab Master',4,'Others',@MENU_ID1)
		--END

	end

----Added by Mr.Mehul on 12-01-2023

--Declare @form_id_Skill as Numeric
--Declare @Sort_id_Skill as Numeric
--set @form_id_Skill = 0
--set @Sor_id_Check = 0
--set @Sort_id_Skill =0
--Set @U_Form_Id=0
--Select @U_Form_Id=Form_ID ,@Sor_id_Check = Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name ='Employee'  and  Page_Flag ='AP'
--set @Sor_id_Check = @Sor_id_Check + 1	

--	IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Employee Skill & Certification' and Page_Flag = 'AP')
--	BEGIN
		
--		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],Module_name,Page_Flag)
--		VALUES(@Menu_id1, N'Employee Skill & Certification', @U_Form_Id,2004, 1,'Home.aspx',@Employee_Img, 1,'','Payroll','AP')
--	END
--	else
--	Begin
--	select @form_id_Skill = Form_id,@Sort_Id=Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Skill & Certification' and Page_Flag = 'AP'
--	set @Sort_id_Skill = @Sort_Id + 1

--	if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Skill & Certification' and Page_Flag = 'AP')
--	begin
--		update T0000_DEFAULT_FORM 
--		set Under_Form_ID = @U_Form_Id,
--		Sort_ID=2004,
--		alias = 'Employee Skill & Certification', 
--		Form_url ='Home.aspx',
--		Form_Image_Url= @Employee_Img,
--		Page_Flag ='AP'
--		where Form_Name = 'Employee Skill & Certification' and Page_Flag = 'AP'
--	end
	

--	Set @form_id_Skill=0
--	Select @form_id_Skill=Form_ID ,@Sort_id_Skill = Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name ='Employee Skill & Certification' and  Page_Flag ='AP'
--	set @Sort_id_Skill = @Sort_id_Skill + 1


--	If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Skills And Certifications' AND  Page_Flag = 'AP' and   Form_ID > 6000 and Form_ID < 6500)     
--	BEGIN
--		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url],[Module_name], [Is_Active_For_menu],[page_flag], [Alias])
--		values(@Menu_id1, N'Skills And Certifications', @form_id_Skill,2005, 1, N'Employee_Skills_Certifications.aspx',@Employee_Img, 'Payroll',1,'AP', N'Skills And Certifications')
--	END 
--	if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Skills And Certifications' and Page_Flag ='AP' AND  Form_ID > 6000 and Form_ID < 6500)
--	begin
--		update T0000_DEFAULT_FORM 
--		set Under_Form_ID = @form_id_Skill,
--		Form_Image_Url= @Employee_Img,
--		Sort_ID=2005		 
--		where Form_Name = 'Skills And Certifications' and  Page_Flag ='AP' AND  Form_ID > 6000 and Form_ID < 6500
--	end

--	End
----Added by Mr.Mehul on 12-01-2023


--Added By Deepali -25 Jan-22 -To add Retaining Module - Start

begin  -- #region Retaining Menu Start

Declare @form_id_Retain as Numeric
Declare @Sort_id_Retain as Numeric
set @form_id_Retain = 0
set @Sor_id_Check = 0
set @Sort_id_Retain =0
--set @Sort_id_Retain = @Sort_id_Retain + 20
Set @U_Form_Id=0
	Select @U_Form_Id=Form_ID ,@Sor_id_Check = Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name ='Employee'  and  Page_Flag ='AP'
	set @Sor_id_Check = @Sor_id_Check + 1	

IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Employee Retaining' and Page_Flag = 'AP')
	BEGIN
		
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],Module_name,Page_Flag)
		VALUES(@Menu_id1, N'Employee Retaining', @U_Form_Id,124, 1,'Home.aspx',@Employee_Img, 1,'','Payroll','AP')
	END
	else
	Begin
	select @form_id_Retain = Form_id,@Sort_Id=Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Retaining' and Page_Flag = 'AP'
	set @Sort_id_Retain = @Sort_Id + 1

	if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Retaining' and Page_Flag = 'AP')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @U_Form_Id,
		Sort_ID=124,
		alias = 'Employee Retaining', 
		Form_url ='Home.aspx',
		Form_Image_Url= @Employee_Img,
		Page_Flag ='AP'
		where Form_Name = 'Employee Retaining' and Page_Flag = 'AP'
	end
	

	Set @form_id_Retain=0
	Select @form_id_Retain=Form_ID ,@Sort_id_Retain = Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name ='Employee Retaining' and  Page_Flag ='AP'
	set @Sort_id_Retain = @Sort_id_Retain + 1

	If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Assign Retaining Status' AND  Page_Flag = 'AP' and   Form_ID > 6000 and Form_ID < 6500)     
	BEGIN
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url],[Module_name], [Is_Active_For_menu],[page_flag], [Alias])
		values(@Menu_id1, N'Assign Retaining Status', @form_id_Retain,268, 1, N'Employee_Retaining_Assign.aspx',@Employee_Img, 'Payroll',1,'AP', N'Assign Retaining Status')
	END 
	if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Assign Retaining Status' and Page_Flag ='AP' AND  Form_ID > 6000 and Form_ID < 6500)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Retain,
		Form_Image_Url= @Employee_Img,
		Sort_ID=268		 
		where Form_Name = 'Assign Retaining Status' and  Page_Flag ='AP' AND  Form_ID > 6000 and Form_ID < 6500
	end
	If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Retaining Rate Master' and Page_Flag ='AP' AND  Form_ID > 6000 and Form_ID < 6500)     
	BEGIN
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url],[Module_name], [Is_Active_For_menu],[page_flag], [Alias])
		values(@Menu_id1, N'Retaining Rate Master', @form_id_Retain,267, 1, N'Retaining_Rate_Master.aspx',@Employee_Img, 'Payroll',1,'AP', N'Retaining Rate Master')
	END 	
	if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Retaining Rate Master' and Page_Flag ='AP' AND  Form_ID > 6000 and Form_ID < 6500)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Retain,
		Form_Image_Url= @Employee_Img,
		Sort_ID=267		 
		where Form_Name = 'Retaining Rate Master' and  Page_Flag ='AP' AND  Form_ID > 6000 and Form_ID < 6500
	end
	If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Retaining Payment Process' and Page_Flag ='AP' AND  Form_ID > 6000 and Form_ID < 6500)     
	BEGIN
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url],[Module_name], [Is_Active_For_menu],[page_flag], [Alias])
		values(@Menu_id1, N'Retaining Payment Process', @form_id_Retain,269, 1, N'Retaining_Payment.aspx',@Employee_Img, 'Payroll',1,'AP', N'Retaining Payment Process')
	END 	
	if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Retaining Payment Process' and Page_Flag ='AP' AND  Form_ID > 6000 and Form_ID < 6500)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Retain,
		Form_Image_Url= @Employee_Img,
		Sort_ID=269		 
		where Form_Name = 'Retaining Payment Process' and  Page_Flag ='AP'AND  Form_ID > 6000 and Form_ID < 6500
	end

	If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Final Retaining Payment' and Page_Flag ='AP' AND  Form_ID > 6000 and Form_ID < 6500)     
	BEGIN
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url],[Module_name], [Is_Active_For_menu],[page_flag], [Alias])
		values(@Menu_id1, N'Final Retaining Payment', @form_id_Retain,270, 1, N'Final_Retaining_Payment.aspx',@Employee_Img, 'Payroll',1,'AP', N'Final Retaining Payment')
	END 	
	if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Final Retaining Payment' and Page_Flag ='AP' AND  Form_ID > 6000 and Form_ID < 6500)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Retain,
		Form_Image_Url= @Employee_Img,
		Sort_ID=270	 
		where Form_Name = 'Final Retaining Payment' and  Page_Flag ='AP'AND  Form_ID > 6000 and Form_ID < 6500
	end
End -- #region Retaining Menu End	
End
--Added By Deepali -25 Jan-22 -To add Retaining Module - End



-- added by rohit on 27102016			--Page Flag is null; Added By Ramiz on 16/11/2018--
UPDATE T0000_DEFAULT_FORM SET Page_Flag = 'AP' WHERE Form_ID >= 6000 AND Form_ID < 6500  AND Page_Flag IS NULL
UPDATE T0000_DEFAULT_FORM SET Page_Flag = 'EP' WHERE Form_ID >= 7000 AND Form_ID < 7500  AND Page_Flag IS NULL
UPDATE T0000_DEFAULT_FORM SET Page_Flag = 'AR' WHERE Form_ID >= 6700 AND Form_ID < 7000  AND Page_Flag IS NULL
UPDATE T0000_DEFAULT_FORM SET Page_Flag = 'HP' WHERE Form_ID >= 6500 AND Form_ID < 6700  AND Page_Flag IS NULL
UPDATE T0000_DEFAULT_FORM SET Page_Flag = 'ER' WHERE Form_ID >= 7500 AND Form_ID < 8000  AND Page_Flag IS NULL
UPDATE T0000_DEFAULT_FORM SET Page_Flag = 'DA' WHERE Form_ID >= 9000 AND Form_ID < 9200  AND Page_Flag IS NULL
UPDATE T0000_DEFAULT_FORM SET Page_Flag = 'DE' WHERE Form_ID >= 9200 AND Form_ID < 10000 AND Page_Flag IS NULL
-- ended by rohit on 27102016

--For Import Data pages
exec P0000_DEFAULT_FORM_IMPORT_DATA

exec P0000_Report_Reset   -- Added by rohit For Set sequence of Report.
EXEC SP_Update_Sort_ID_Check  --Added By Jaina For Menu Sort 07-09-2015
exec P0000_Payroll_Form_Update -- Added by rohit for update payroll flag in menu on 16012016
exec P0000_Import_Data -- Added by rohit for Import Data rights entry on 16012016
Exec Default_Leave_Amount_Update -- Added by rohit for leave amount Update in encashment table on 04032016 /*Commented By Nimesh and Discussed with Hardikbhai on 08-Mar-2018*/
Exec Default_Net_Payable_Bonus_Update -- Added by rohit for Net_paybale_Bonus update in table on 19052016
--exec Default_settings_Rohit -- added binal for default template forgot password
exec P0000_New_Forms_Report -- added by rohit For add new Report on 29092016

----------------------- Don't do code below this Line becuse this Sp check parent Checked if Child menu is checked
--=====================	if you have Query in menu contact Rohit patel
exec P0000_ESS_HOME_Update	-- added by binal 03012020
--exec Default_menu_update
----------------------	
--===================	
exec P_CUSTOMIZE_REPORTS_ENTRY
 -- exec P0000_Default_Form_New_test 1

--Added by Nilesh Patel on 18-Jun-2019 -- Wrong Setting is added in Admin Setting 
Update T0040_Setting 
	Set Setting_Name='Enable Back Dated Leave As Leave Arrear Days in Next Month Salary',
		Alias='Enable Back Dated Leave As Leave Arrear Days in Next Month Salary'
Where Setting_Name='Enable Back Dated Leave As Leave Arrear Days in Next Month Salary.'	

		
End



