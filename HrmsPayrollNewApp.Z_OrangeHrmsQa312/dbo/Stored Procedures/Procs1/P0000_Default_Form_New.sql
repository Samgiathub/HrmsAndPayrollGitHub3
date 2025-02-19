---exec P0000_Default_Form_New 1
CREATE PROCEDURE [dbo].[P0000_Default_Form_New]
  @ver_update as tinyint = 0
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON 
	
DECLARE @REPORT_IMG AS VARCHAR(50)
SET @REPORT_IMG=N'MENU/REPORTS.GIF'
DECLARE @CONTROL_PNL_IMG AS VARCHAR(50)
SET @CONTROL_PNL_IMG=N'MENU/CONTROL_PANEL.GIF'
DECLARE @MASTERS_IMG AS VARCHAR(50)
SET @MASTERS_IMG=N'MENU/MASTER.GIF'
DECLARE @EMPLOYEE_IMG AS VARCHAR(50)
SET @EMPLOYEE_IMG=N'MENU/EMPLOYEE.GIF'
DECLARE @LEAVE_IMG AS VARCHAR(50)
SET @LEAVE_IMG=N'MENU/LEAVE.GIF'
DECLARE @LOAN_CLAIM_IMG AS VARCHAR(50)
SET @LOAN_CLAIM_IMG=N'MENU/LOAN-CLAIM.GIF'
DECLARE @SALARY_IMG AS VARCHAR(50)
SET @SALARY_IMG=N'MENU/SALARY.GIF'
DECLARE @HR_IMG AS VARCHAR(50)
SET @HR_IMG=N'MENU/HR.GIF'
DECLARE @TIMESHEET_IMG AS VARCHAR(50)
SET @TIMESHEET_IMG=N'MENU/TIMESHEET.GIF'
DECLARE @RECRUITMENT_IMG AS VARCHAR(50)  
SET @RECRUITMENT_IMG=N'MENU/RECRUITEMENT.PNG'
DECLARE @TRAINING_IMG AS VARCHAR(50)
SET @TRAINING_IMG=N'MENU/FIX.GIF'
DECLARE @APPRAISAL_IMG AS VARCHAR(50)
SET @APPRAISAL_IMG=N'MENU/COMPANY_STRUCTURE.GIF'
DECLARE @HRDOC_IMG AS VARCHAR(50)
SET @HRDOC_IMG=N'MENU/LEAVE_MANAGEMENT.GIF'
DECLARE @ORGANOGRAM_IMG AS VARCHAR(50)
SET @ORGANOGRAM_IMG=N'MENU/DESIG.PNG' 
DECLARE @SUBMENUID NUMERIC(18,0) 
DECLARE @EMP_IMG AS VARCHAR(50)
SET @EMP_IMG=N'MENU/EMP.PNG'
	
IF @VER_UPDATE = 1
BEGIN
		
			DECLARE @CURRDATE AS DATETIME
			DECLARE @VERSION_ID AS NUMERIC
			DECLARE @VERSION_NO AS NVARCHAR(30)
			DECLARE @DATABASE_NAME AS NVARCHAR(30)
			DECLARE @SERVER_NAME AS NVARCHAR(30)
			
			SELECT @DATABASE_NAME = DB_NAME()
			SELECT @CURRDATE = GETDATE()
			SELECT @SERVER_NAME = @@SERVERNAME
	
			SELECT @VERSION_ID  = ISNULL(MAX(VERSION_ID),0) + 1 FROM T0000_VERSION_INFO WITH (NOLOCK)
			SET @Version_No  = 'v24.05.07.01' 
			
			INSERT INTO T0000_VERSION_INFO (Version_Id, Version_No, Last_Update, Database_Name, Server_Name)
			VALUES     (@Version_Id,@Version_No,@currDate,@Database_Name,@Server_Name)	
			
			IF	EXISTS(	SELECT	1 FROM	T0000_DEFAULT_FORM  WITH (NOLOCK) WHERE	FORM_NAME = 'IT Declaration' AND PAGE_FLAG = 'AP')
			BEGIN
					UPDATE 	T0000_DEFAULT_FORM
					SET		FORM_URL = '../admin_associates/IT_Declaration_With_Detail.aspx'
					WHERE	FORM_NAME = 'IT Declaration' AND PAGE_FLAG = 'AP'
			END
				
			IF	EXISTS(SELECT	1 FROM	T0000_DEFAULT_FORM WITH (NOLOCK) WHERE	FORM_NAME = 'IT Declaration Form' AND PAGE_FLAG = 'EP')
			BEGIN
					UPDATE 	T0000_DEFAULT_FORM
					SET		FORM_URL = 'IT_Declaration_User_With_Detail.aspx'
					WHERE	FORM_NAME = 'IT Declaration Form' AND PAGE_FLAG = 'EP'
			END
END

	
	if not exists (select res_id from t0040_reason_master WITH (NOLOCK) ) 
		begin
		
			DELETE FROM T0040_REASON_MASTER 
			Insert into T0040_Reason_Master(Res_Id,Reason_Name,Type,isActive) values (1,'Forget To Punch/Sign In','R',1)
			Insert into T0040_Reason_Master(Res_Id,Reason_Name,Type,isActive) values (2,'Was In Training','R',1)
			Insert into T0040_Reason_Master(Res_Id,Reason_Name,Type,isActive) values (3,'Travel On Duty','R',1)
			Insert into T0040_Reason_Master(Res_Id,Reason_Name,Type,isActive) values (4,'Could Not Sign In','R',1)
			Insert into T0040_Reason_Master(Res_Id,Reason_Name,Type,isActive) values (5,'System Is Down/Networking','R',1)
			Insert into T0040_Reason_Master(Res_Id,Reason_Name,Type,isActive) values (6,'Working from Home (Temp)','R',1)
			Insert into T0040_Reason_Master(Res_Id,Reason_Name,Type,isActive) values (7,'Due employee Resigned','OT',1)	
			Insert into T0040_Reason_Master(Res_Id,Reason_Name,Type,isActive) values (8,'Due to on leave','OT',1)
			Insert into T0040_Reason_Master(Res_Id,Reason_Name,Type,isActive,gate_pass_type) values (9,'Personal','GatePass',1,'Personal')
			Insert into T0040_Reason_Master(Res_Id,Reason_Name,Type,isActive,gate_pass_type) values (10,'Official','GatePass',1,'Official')
			Insert into T0040_Reason_Master(Res_Id,Reason_Name,Type,isActive) values (11,'Others','Left',1)

		end

		IF exists(select 1 from T0040_REASON_MASTER where isnull(Type,'') = '')
		BEGIN
			update T0040_REASON_MASTER set Type='R' where TYPE is null
		END

		if not exists (select res_id from T0040_Reason_Master WITH (NOLOCK) where Reason_Name ='Due employee Resigned' and type='OT')
		begin 
			declare @type_Id_Max as integer
			select @type_Id_Max = MAX(isnull(res_id,0)) +1 from T0040_Reason_Master WITH (NOLOCK)
			Insert into T0040_Reason_Master(Res_Id,Reason_Name,Type,isActive) values (@type_Id_Max,'Due employee Resigned','OT',1)	
				
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
		
		Delete from T0040_CF_TYPE_MASTER

		Insert Into T0040_CF_TYPE_MASTER(CF_TYPE_ID,CF_TYPE_NAME,Status) values (1,'Present',1)
		Insert Into T0040_CF_TYPE_MASTER(CF_TYPE_ID,CF_TYPE_NAME,Status) values (2,'Fix',1)
		Insert Into T0040_CF_TYPE_MASTER(CF_TYPE_ID,CF_TYPE_NAME,Status) values (3,'Slab',1)
		Insert Into T0040_CF_TYPE_MASTER(CF_TYPE_ID,CF_TYPE_NAME,Status) values (4,'Flat',1)
		
		EXEC InsertDefaultLocations
		Exec P0030_InsertDocumentTypeMaster
		Exec P0030_InsertSourceTypeMaster
		EXEC InsertDefaultReminder
		Exec DefaultPayment_Process_Type
		
		EXEC InsertDefaultScheme 
		EXEC P0020_STATE_MASTER_DEFAULT 0 
		EXEC InsertDefault_perquisites  

	if @ver_update=2 
	begin 
		EXEC P0000_Default_Form_New_ver_2
	end

if @ver_update=1
Begin 

DECLARE @MENU_ID1 NUMERIC
DECLARE @TEMP_FORM_ID1 NUMERIC

EXEC P0000_Home_Page_New @ver_update

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Admin Setting')
begin
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	values (@Menu_id1,'Admin Setting',6001,14,1,'GuestAdmin.aspx',@Control_Pnl_Img,1,'Admin Setting')
end


If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Timesheet Management'  AND  Form_ID > 6000 and Form_ID < 6500   )      
	BEGIN
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500      
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check])
		values(@Menu_id1, N'Timesheet Management', -1, 248, 1, N'Home.aspx', @timesheet_img, 1,N'Timesheet',0)    
	END

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

If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Timesheet Approval' AND  Form_ID > 6000 and Form_ID < 6500)     
	BEGIN
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check])
		values(@Menu_id1, N'Timesheet Approval', @Temp_Form_ID1, 257, 1, N'Timesheet_Approval.aspx', @timesheet_img, 1,N'Timesheet Approval',10)  
	END 	

If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'ESS TimeSheet Entry' AND  Form_ID > 7000 and Form_ID < 7500)      
	BEGIN
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check])
		values(@Menu_id1, N'ESS TimeSheet Entry', 7001, 306, 1, N'TimeSheet.aspx', @Employee_Img, 1,N'TimeSheet',0)    
	END  

If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'ESS TimeSheet Detail' AND  Form_ID > 7000 and Form_ID < 7500)      
	BEGIN
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check])
		values(@Menu_id1, N'ESS TimeSheet Detail', 7001, 306, 1, N'Timesheet_Detail_ESS.aspx', @Employee_Img, 1,N'TimeSheet Detail',0)    
	END 

----Optional holiday approval form of superior. 	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Optional HO Approval Manager')
	begin
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
	

----Employee Hisotry form of superior. 		
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee History Manager')
	begin
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

------Performance Appraisal Menu  
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

	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Responsibility & Escalation') 
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Responsibility & Escalation',6001,14,1,'Auto_Escalation_Settings.aspx',@Control_Pnl_Img,1,'Responsibility & Escalation')
	end


if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'AX Mapping') 
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000  and Form_ID < 6499  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'AX Mapping',6001,14,1,'AX_Mapping.aspx', @Control_Pnl_Img, 1, N'AX Mapping')
	end

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'AX Mapping Slab Master')
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

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Income Tax Declaration Member#') 
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7500     and Form_ID < 7999  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Income Tax Declaration Member#',7514,401,1,NULL, NULL, 1, N'Income Tax Declaration Member#')
	end


if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee OverTime Reports Member#') 
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7500     and Form_ID < 7999  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[page_Flag])
		values (@Menu_id1,'Employee OverTime Reports Member#',7503,347,1,NULL, NULL, 1, N'Employee OverTime Reports Member#','ER')
	end


if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Tax Consolidate Report My#') 
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7500     and Form_ID < 7999  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Tax Consolidate Report My#',7532,401,1,NULL, NULL, 1, N'Tax Consolidate Report My#')
	end

	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Cross Company Privilege') 
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000  and Form_ID < 6499  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Cross Company Privilege',6001,14,1,'Privilege_Employee_Other_Company.aspx', @Control_Pnl_Img, 1, N'Cross Company Privilege')
		
	end
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

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Final Approval Stage' And Form_ID > 6500 and Form_ID < 6700) 
begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 6700
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'Final Approval Stage', 6518, 229, 1, N'HRMS/Final_AppraisalApproval.aspx', N'menu/company_structure.gif', 1, N'Final Approval Stage')			
end

If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Source Master')
begin

		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Source Master',6013, 35, 1,'Master_Source.aspx',@Masters_Img,1,'Source Master')
end
	
	
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


if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Other Assessment Master' And Form_ID > 6500 and Form_ID < 6700) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 6700
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'Other Assessment Master', 6518, 230, 1, N'HRMS/HRMS_OtherAssessment_Master.aspx', N'menu/company_structure.gif', 1, N'Other Assessment Master')			
	end

If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Email News Letter')
	begin

		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Email News Letter',6012, 61, 1,'Email_News_Letter.aspx',@Masters_Img,1,'Email News Letter')
	end

If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Email Logs')
	begin

		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Email Logs',6012, 62, 1,'Email_Logs.aspx',@Masters_Img,1,'Email Logs')
	end


if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Gate Pass')  
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000     and Form_ID < 6500  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Gate Pass',6057,100,1,'Home.aspx',@Leave_Img, 1, N'Gate Pass')
	end


Declare @Menu_id_Gatepass Numeric(18,0)

select @Menu_id_Gatepass = form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Gate Pass' and Form_id > 6000 and Form_ID < 6500

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Gate Pass Entry')  -- Added By Rohit on 22022014
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000     and Form_ID < 6500  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Gate Pass Entry',@Menu_id_Gatepass,100,1,'get_pass_entry.aspx',@Leave_Img, 1, N'Gate Pass Entry')
	end


If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Gate Pass with device' and Form_ID>6000 and Form_ID<6500)
	begin

		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Gate Pass with device',@Menu_id_Gatepass, 101, 1,'Employee_Gate_Pass_Regularization.aspx',@Leave_Img,1,'Gate Pass with device')
		
	end	



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

If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Pay Scale Master')
	begin

		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Pay Scale Master',6013, 64, 1,'Master_Pay_Scale.aspx',@Masters_Img,1,'Pay Scale Master')
	end


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

If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'ESS Timesheet Details' And Form_ID > 7000 and Form_ID < 7500)	
	Begin
		Select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'ESS Timesheet Details',7023, 344, 1,'Timesheet_Details.aspx',@Employee_Img,1,'Timesheet Details')
	End


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
	
	
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Directory Setting') 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM  WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Page_Flag])
		values(@Menu_id1, N'Employee Directory Setting', 6001,14, 1, N'Employee_Directory_Setting.aspx', @Control_Pnl_Img, 1, N'Employee Directory Setting','AP')
	end
	
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Directory - Admin') 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Page_Flag])
		values(@Menu_id1, N'Employee Directory - Admin', 6001,15, 1, N'Employee_Directory.aspx', N'menu/Control_Panel.gif', 1, N'Employee Directory','AP')
	end


	if not exists (select Form_id  from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Audit Trail'  And Form_ID > 6000 and Form_ID < 6400) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_ID > 6000 and Form_ID < 6400
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Page_Flag])
		values(@Menu_id1, N'Audit Trail', 6001,16, 1, N'audit_trail.aspx', N'menu/Control_Panel.gif', 1, N'Audit Trail','AP')
	end
	
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

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Self Assessment' And Form_ID > 6700 and Form_ID < 6999) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700 and Form_ID < 6999
		select @hrreport_id = form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'HRMS Reports' And Form_ID > 6700 and Form_ID < 6999 
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'Employee Self Assessment', @hrreport_id, 198, 1, null, null, 1, N'Employee Self Assessment')			
	end
else
	begin 
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
	begin 
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
	begin 
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

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Performance Assessment Form' And Form_ID > 6700 and Form_ID < 6999) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700 and Form_ID < 6999
		select @hrreport_id = form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'HRMS Reports' And Form_ID > 6700 and Form_ID < 6999 

		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values(@Menu_id1, N'Performance Assessment Form', @hrreport_id, 199, 1, null, null, 1, N'Performance Assessment Form')			
	end
else
	begin 

		select @hrreport_id = form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'HRMS Reports' And Form_ID > 6700 and Form_ID < 6999 
		update [T0000_DEFAULT_FORM] set under_form_Id = @hrreport_id where Form_name = 'Performance Assessment Form' And Form_ID > 6700 and Form_ID < 6999
	End

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
		values(@Menu_id1, N'Allowance/Reimbursement Approval', 6070, 125, 1, N'AllowanceReimApplicationApproval.aspx', @Loan_Claim_Img, 0, N'Allowance/Reimbursement Approval') --Change by ronakk 25122023 Is_Active_For_menu = 0
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Allowance/Reimbursement Approval' And Form_ID > 7000 and Form_ID < 7499)
begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7499
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	values (@Menu_id1,'Allowance/Reimbursement Approval',7013 ,322,1,'AllowanceReimAppApprovalManager.aspx',@Loan_Claim_Img,0,'Allowance/Reimbursement Approval') --Change by ronakk 25122023 Is_Active_For_menu = 0
end

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
BEGIN
		update T0000_DEFAULT_FORM 
		set Form_url='home.aspx',
			Sort_ID = 307 
		where Form_Name = 'Weekoff Request' and Form_ID > 7000 and Form_ID < 7499
END

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
	
	end
	
	If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee AllowDedu Revised' And Form_ID > 6000 and Form_ID < 6499 )
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Employee AllowDedu Revised',@temp_menu_id_Increment, 68, 1,'Employee_AllowDedu_Revised.aspx',@Employee_Img,1,'Employee AllowDedu Revised')
	
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


IF EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE FORM_NAME = 'Employee Weekoff' AND FORM_ID > 6000 AND FORM_ID <6500)
	BEGIN
		DELETE FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Employee Weekoff' AND FORM_ID > 6000 AND FORM_ID < 6500
	END
IF EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE FORM_NAME = 'Employee Shift Change' AND FORM_ID > 6000 AND FORM_ID <6500)
	BEGIN
		DELETE FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Employee Shift Change' AND FORM_ID > 6000 AND FORM_ID < 6500
	END

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


	

update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='Rating Master'
update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='Goal Master'
update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='Appraisal General Setting'
update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='Skill General Setting'
update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='Assign Goal'
update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='Employee Skill Rating'
update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='Initiate Appraisal'
update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='Appraisal Approval'
update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='Initiate Appraisal Report'

update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='KPI Import'
update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='KPI Master'
update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='KPI Setting'
update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='KPI Objectives'
update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='KPI Appraisal Form'
update [T0000_DEFAULT_FORM] set Is_Active_For_menu=0 where Form_Name='KPIPMS Final Evaluation'

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


if exists(select form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name ='Sub Branch master' and  Form_ID > 6000 and Form_ID < 6500)
begin
	
		Update T0000_DEFAULT_FORM set Form_name='SubBranch Master',Alias ='SubBranch Master'  where Form_Name ='Sub Branch Master' and  Form_ID > 6000 and Form_ID < 6500
	
end

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Leave Balance with Amount' And Form_ID > 6000 and Form_ID < 7000) 
begin    
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 7000
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])values(@Menu_id1, N'Leave Balance with Amount', 6703, 176, 1, NULL, NULL, 1, N'Leave Balance with Amount')
end

	

	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Reimbursement Sub Expense Detail' And Form_ID > 6000 and Form_ID < 6499)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6499
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'Reimbursement Sub Expense Detail',6027 ,44,1,'Master_Allowance_Expense.aspx',@Masters_Img,1,'Reimbursement Sub Expense Detail')
	end
	
		Update T0000_DEFAULT_FORM set Sort_ID=20,Sort_Id_Check =2 where Form_Name ='Attendance Reason Master' and  Under_Form_ID=6013
		Update T0000_DEFAULT_FORM set Sort_ID=20,Sort_Id_Check =3 where Form_Name ='Branch master' and  Under_Form_ID=6013
		Update T0000_DEFAULT_FORM set Sort_ID=20,Sort_Id_Check =4 where Form_Name ='SubBranch Master' and  Under_Form_ID=6013
		Update T0000_DEFAULT_FORM set Sort_ID=20,Sort_Id_Check =5 where Form_Name ='State Master' and  Under_Form_ID=6013
		Update T0000_DEFAULT_FORM set Sort_ID=20,Sort_Id_Check =6 where Form_Name ='Country Master' and  Under_Form_ID=6013
		Update T0000_DEFAULT_FORM set Sort_ID=20,Sort_Id_Check =7 where Form_Name ='Department Master' and  Under_Form_ID=6013
		Update T0000_DEFAULT_FORM set Sort_ID=20,Sort_Id_Check =8 where Form_Name ='Designation Master' and  Under_Form_ID=6013
		Update T0000_DEFAULT_FORM set Sort_ID=20,Sort_Id_Check =9 where Form_Name ='Grade Master' and  Under_Form_ID=6013
		Update T0000_DEFAULT_FORM set Sort_ID=20,Sort_Id_Check =10 where Form_Name ='Shift Master' and  Under_Form_ID=6013
		
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

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TD_Home_ESS_288' And Form_ID > 9000 and Form_ID < 10000)
	begin    
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 10000
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
	values (@Menu_id1,'TD_Home_ESS_288',9261,1274,1,'','',1,'Give Training Feedback')
	end	

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

-- Added by Divyaraj Kiri on 15/09/2023

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK)  where  Form_name = 'TD_Home_Admin_90' And Form_ID > 9000 and Form_ID < 10000)
	begin    
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 9200
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
		values (@Menu_id1,'TD_Home_Admin_90',9061,1065,1,'','',1,'Template')
	end

-- Ended by Divyaraj Kiri on 15/09/2023
	
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
		
	 
		
		DECLARE @MOBUNDERAPP  NUMERIC(18,0) = 0
		SELECT @MOBUNDERAPP = FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Mobile Approval'
		
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

			--start by Divyaraj Kiri on 27072023
			IF not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Mobile Template' AND Form_ID > 9800 AND Form_ID < 9999)
			BEGIN
				select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9800 and Form_ID < 9999
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],  
				[Form_Image_url],[Is_Active_For_menu],[Alias])values  
				(@Menu_id1,N'Mobile Template',@Temp_Form_ID1, 811, 1, N'Android', NULL,1,N'Mobile Template')    
			END

			
--------------------------------------------------------------------------------------------------------------------------------------------------------------
	
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
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [ALIAS],[Module_name])
			VALUES (@Menu_id1,'Incentive',6012,58,1,'home.aspx',@Masters_Img,1,'Incentive','Incentive') --Change by ronak 27122023 Sep Module as "Incentive"
		END
	
			
	IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Parameter Template')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000 AND Form_ID < 6500
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [ALIAS],[Sort_Id_Check],[Module_name])
			VALUES (@Menu_id1,'Parameter Template',6257,57,1,'parameter_master.aspx',@Masters_Img,1,'Parameter Template',2,'Incentive')  --Change by ronak 27122023 Sep Module as "Incentive"
		END
		
	IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Incentive Scheme')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000 AND Form_ID < 6500
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [ALIAS],[Sort_Id_Check],[Module_name])
			VALUES (@Menu_id1,'Incentive Scheme',6257,57,1,'incentive_scheme.aspx',@Masters_Img,1,'Incentive Scheme',2,'Incentive')  --Change by ronak 27122023 Sep Module as "Incentive"
		END
	IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Incentive Template')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000 AND Form_ID < 6500
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [ALIAS],[Sort_Id_Check],[Module_name])
			VALUES (@Menu_id1,'Incentive Template',6257,57,1,'incentive_master.aspx',@Masters_Img,1,'Incentive Template',2,'Incentive')  --Change by ronak 27122023 Sep Module as "Incentive"
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
	if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'New Claim Application' and Form_ID>7000 )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_leave_Claims,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias = 'New Claim Application' 
		where Form_Name = 'New Claim Application' and Form_ID>7000 
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
	
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Attendance Card' And Form_ID > 6700 and Form_ID < 7000) 
BEGIN
	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6700 and Form_ID < 7000
	
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
	VALUES(@Menu_id1, N'Attendance Card', 6702, 173, 1, null, null, 1, N'Attendance Card', 14)
END


if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Deviation Report' and Form_ID > 6700 and Form_ID < 7000)
Begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700 and Form_ID < 7000
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
		values (@Menu_id1,'Deviation Report',6702,173,1,'','',1,'Deviation Report',15)
End	

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Mobile Inout Summary' and  Form_ID > 6700 and Form_ID < 7000)
Begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700 and Form_ID < 7000
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
		values (@Menu_id1,'Mobile Inout Summary',6702,173,1,'','',1,'Mobile Inout Summary',16)
End

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

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Insurance Deduction' and  Form_ID > 6700 and Form_ID < 7000)
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700 and Form_ID < 7000
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
		values (@Menu_id1,'Insurance Deduction',6705,180,1,'','',1,'Insurance Deduction',1)
	end	

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Loan Application Form' and  Form_ID > 6700 and Form_ID < 7000)
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6700 and Form_ID < 7000
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
		values (@Menu_id1,'Loan Application Form',6704,178,1,'','',1,'Loan Application Form',4)
	end	

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
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name])
		VALUES(@Menu_id1, N'Bond', 6070, 249, 1, N'Home.aspx', @Loan_Claim_Img, 1,N'Bond',0,'Bond') --Change by ronak 27122023 Sep Module as "Bond"
	END
SELECT @Under_form_Id = Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Bond' AND Form_ID > 6000 AND Form_ID < 6500

IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Bond Master'  AND  Form_ID > 6000 AND Form_ID < 6500)
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000 AND Form_ID < 6500      
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name])
		VALUES(@Menu_id1, N'Bond Master', @Under_form_Id, 249, 1, N'Bond_Master.aspx', @Loan_Claim_Img, 1,N'Bond Master',1,'Bond') --Change by ronak 27122023 Sep Module as "Bond"
	END
IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Admin Bond Approval'  AND  Form_ID > 6000 AND Form_ID < 6500)
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 6000 AND Form_ID < 6500      
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name])
		VALUES(@Menu_id1, N'Admin Bond Approval', @Under_form_Id, 249, 1, N'Bond_Approve_Admin.aspx', @Loan_Claim_Img, 1,N'Admin Bond Approval',2,'Bond') --Change by ronak 27122023 Sep Module as "Bond"
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
		
-------------------------ended----------------------------------


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

	IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Travel GST Report' and Page_Flag ='AR')
		BEGIN
			
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_Flag])
			VALUES(@Menu_id1, N'Travel GST Report', 6712,0, 1, N'Report_Payroll.aspx', null, 1,N'Travel GST Report',5,'Payroll','AR')
			
		END


		IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'TD_CONSOLIDATE_310' and Page_Flag ='DA')
		BEGIN
			Declare @U_Form_Id numeric
			Set @U_Form_Id=0
			Select @U_Form_Id=Form_ID from T0000_DEFAULT_FORM WITH (NOLOCK) where (Form_Name ='Company Consolidate Info' or Alias='Company Consolidate Info') and Page_Flag ='DA'
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_Flag])
			VALUES(@Menu_id1, N'TD_CONSOLIDATE_310', @U_Form_Id,0, 1, N'Cmp_consolidate_Details.aspx', null, 0,N'Company Consolidate Details',5,'Payroll','DA')

		END




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

IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'ESOP Master' and Page_Flag ='AP')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_Flag])
			VALUES(@Menu_id1, N'ESOP Master', 6013,16, 1, N'Master_Esop.aspx', 'menu/master.gif' , 1,N'ESOP Master',15,'Payroll','AP')
END


IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Kilometer Rate Master' and Page_Flag ='AP')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_Flag])
			VALUES(@Menu_id1, N'Kilometer Rate Master', 6260,80, 1, N'Kilometer_Rate_Master.aspx', 'menu/master.gif' , 1,N'Kilometer Rate Master',14,'Payroll','AP')
			
END


Declare @SkillUderID int =0
select @SkillUderID =Form_ID from T0000_DEFAULT_FORM  where Form_Name ='Qualification' and Page_Flag = 'AP'

 
IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Cat. Skill Master' and Page_Flag ='AP')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_Flag])
			VALUES(@Menu_id1, N'Cat. Skill Master', @SkillUderID,2003, 1, N'CategorySkill_Master.aspx', 'menu/master.gif' , 1,N'Cat. Skill Master',16,'Payroll','AP')
			
END


IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Sub Cat. Skill Master' and Page_Flag ='AP')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_Flag])
			VALUES(@Menu_id1, N'Sub Cat. Skill Master', @SkillUderID,2004, 1, N'SubCategorySkill_Master.aspx', 'menu/master.gif' , 1,N'Sub Cat. Skill Master',17,'Payroll','AP')
			
END

IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Skill Level Master' and Page_Flag ='AP')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_Flag])
			VALUES(@Menu_id1, N'Skill Level Master', @SkillUderID,2005, 1, N'LevelSkill_Master.aspx', 'menu/master.gif' , 1,N'Skill Level Master',18,'Payroll','AP')
			
END


IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Certificate Skill Mapping' and Page_Flag ='AP')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_Flag])
			VALUES(@Menu_id1, N'Certificate Skill Mapping', @SkillUderID,2006, 1, N'CertificateSkill_Mapping.aspx', 'menu/master.gif' , 1,N'Certificate Skill Mapping',19,'Payroll','AP')
			
END

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
	
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Canteen Application' AND Form_ID > 7000 AND Form_ID < 7500)
			BEGIN     
				select @Menu_id1 = isnull(MAX(Form_id),7500) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
				 
				set @Temp_Form_ID1   = @Menu_id1
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],  
				[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_Flag])values  
				
				(@Menu_id1,N'Canteen Application',@U_Form_Id, 1, 1, 'Ess_Canteen_Application.aspx', 'menu/employee.gif' ,1,N'Canteen Application',0,'Canteen','EP') 
				 
	END

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

	
	IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE  FORM_NAME = 'Canteen Application Report' AND PAGE_FLAG='AR')
	BEGIN    
		SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM
		INSERT INTO [DBO].[T0000_DEFAULT_FORM]([FORM_ID], [FORM_NAME], [UNDER_FORM_ID], [SORT_ID], [FORM_TYPE], [FORM_URL], [FORM_IMAGE_URL], [IS_ACTIVE_FOR_MENU], [ALIAS],[Sort_Id_Check],[Module_name],[Page_Flag])
		VALUES (@MENU_ID1,N'Canteen Application Report',@FormID ,4,1,'',NULL,1,N'Canteen Application Report',1,'Payroll','AR')
		
		IF NOT EXISTS (SELECT FORM_ID FROM T0250_CUSTOMIZED_REPORT WHERE ReportName = 'Canteen Application Report' and TypeID = 10)
		BEGIN 
			insert into T0250_CUSTOMIZED_REPORT Values (161,'Canteen Application Report',10,'Canteen',@MENU_ID1)
		END
	END
	
	IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE  FORM_NAME = 'Canteen Application Details Report' AND PAGE_FLAG='AR')
	BEGIN    
		SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM
		INSERT INTO [DBO].[T0000_DEFAULT_FORM]([FORM_ID], [FORM_NAME], [UNDER_FORM_ID], [SORT_ID], [FORM_TYPE], [FORM_URL], [FORM_IMAGE_URL], [IS_ACTIVE_FOR_MENU], [ALIAS],[Sort_Id_Check],[Module_name],[Page_Flag])
		VALUES (@MENU_ID1,N'Canteen Application Details Report',@FormID ,5,1,'',NULL,1,N'Canteen Application Details Report',1,'Payroll','AR')
		
		IF NOT EXISTS (SELECT FORM_ID FROM T0250_CUSTOMIZED_REPORT WHERE ReportName = 'Canteen Application Details Report' and TypeID = 10)
		BEGIN 
			insert into T0250_CUSTOMIZED_REPORT Values (164,'Canteen Application Details Report',10,'Canteen',@MENU_ID1)
		END
	END
	

	set @FormID = 0
	SELECT @FormID = Form_ID FROM T0000_DEFAULT_FORM WHERE Form_Name = 'Employee Customize' and Page_Flag = 'AR'

	IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE  FORM_NAME = 'Skill & Certificate Report' AND PAGE_FLAG='AR')
	BEGIN    
			SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM
			INSERT INTO [DBO].[T0000_DEFAULT_FORM]([FORM_ID], [FORM_NAME], [UNDER_FORM_ID], [SORT_ID], [FORM_TYPE], [FORM_URL], [FORM_IMAGE_URL], [IS_ACTIVE_FOR_MENU], [ALIAS],[Sort_Id_Check],[Module_name],[Page_Flag])
			VALUES (@MENU_ID1,N'Skill & Certificate Report',@FormID ,31,1,'',NULL,1,N'Skill & Certificate Report',1,'Payroll','AR')
	END


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
	end

begin  

Declare @form_id_Retain as Numeric
Declare @Sort_id_Retain as Numeric
set @form_id_Retain = 0
set @Sor_id_Check = 0
set @Sort_id_Retain =0

Set @U_Form_Id=0
	Select @U_Form_Id=Form_ID ,@Sor_id_Check = Sort_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name ='Employee'  and  Page_Flag ='AP'
	set @Sor_id_Check = @Sor_id_Check + 1	

IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Employee Retaining' and Page_Flag = 'AP')
	BEGIN
		
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],Module_name,Page_Flag)
		VALUES(@Menu_id1, N'Employee Retaining', @U_Form_Id,124, 1,'Home.aspx',@Employee_Img, 1,'','Retaining','AP') --Change by ronak 27122023 Sep Module as "Retaining"
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
		values(@Menu_id1, N'Assign Retaining Status', @form_id_Retain,268, 1, N'Employee_Retaining_Assign.aspx',@Employee_Img, 'Retaining',1,'AP', N'Assign Retaining Status') --Change by ronak 27122023 Sep Module as "Retaining"
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
		values(@Menu_id1, N'Retaining Rate Master', @form_id_Retain,267, 1, N'Retaining_Rate_Master.aspx',@Employee_Img, 'Retaining',1,'AP', N'Retaining Rate Master') --Change by ronak 27122023 Sep Module as "Retaining"
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
		values(@Menu_id1, N'Retaining Payment Process', @form_id_Retain,269, 1, N'Retaining_Payment.aspx',@Employee_Img, 'Retaining',1,'AP', N'Retaining Payment Process') --Change by ronak 27122023 Sep Module as "Retaining"
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
		values(@Menu_id1, N'Final Retaining Payment', @form_id_Retain,270, 1, N'Final_Retaining_Payment.aspx',@Employee_Img, 'Retaining',1,'AP', N'Final Retaining Payment') --Change by ronak 27122023 Sep Module as "Retaining"
	END 	
	if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Final Retaining Payment' and Page_Flag ='AP' AND  Form_ID > 6000 and Form_ID < 6500)
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Retain,
		Form_Image_Url= @Employee_Img,
		Sort_ID=270	 
		where Form_Name = 'Final Retaining Payment' and  Page_Flag ='AP'AND  Form_ID > 6000 and Form_ID < 6500
	end
End 
End


-- Deepal 08-05-24

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Cash Voucher' And Form_ID > 9000 and Form_ID < 10050) 
BEGIN

	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 9000 and Form_ID < 10050
	
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
	VALUES(@Menu_id1, N'Cash Voucher', 6712, 188, 1, null, null, 1, N'Cash Voucher', 25)
END

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Consolidation Statement' And Form_ID > 9000 and Form_ID < 10050) 
BEGIN
	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 9000 and Form_ID < 10050
	
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
	VALUES(@Menu_id1, N'Consolidation Statement', 6712, 188, 1, null, null, 1, N'Consolidation Statement', 26)
END


IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Monthly Abstract Report' And Form_ID > 9000 and Form_ID < 10050) 
BEGIN
	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 9000 and Form_ID < 10050
	
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
	VALUES(@Menu_id1, N'Monthly Abstract Report', 6712, 188, 1, null, null, 1, N'Monthly Abstract Report', 27)
END

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Journal Voucher Report' And Form_ID > 9000 and Form_ID < 10050) 
BEGIN
	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 9000 and Form_ID < 10050
	
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
	VALUES(@Menu_id1, N'Journal Voucher Report', 6712, 188, 1, null, null, 1, N'Journal Voucher Report', 28)
END

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Pay Bill Report' And Form_ID > 9000 and Form_ID < 10050) 
BEGIN
	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 9000 and Form_ID < 10050
	
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
	VALUES(@Menu_id1, N'Pay Bill Report', 6712, 188, 1, null, null, 1, N'Pay Bill Report', 29)
END

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Tax Calculation Report' And Form_ID > 9000 and Form_ID < 10050) 
BEGIN
	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 9000 and Form_ID < 10050
	
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
	VALUES(@Menu_id1, N'Tax Calculation Report', 6712, 188, 1, null, null, 1, N'Tax Calculation Report', 30)
END

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Timesheet Reports' And Form_ID > 9000 and Form_ID < 10050) 
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 9000 and Form_ID < 10050
		
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name] )
		VALUES(@Menu_id1, N'Timesheet Reports', 6163, 198, 1, null, null, 1, N'Timesheet Reports', 0,'TIMESHEET')
	END
ELSE  
	BEGIN
		UPDATE T0000_DEFAULT_FORM SET Module_name = 'TIMESHEET' WHERE Form_name = 'Timesheet Reports' AND Form_ID > 9000 and Form_ID < 10050
	END

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Employee Costing Report' And Form_ID > 9000 and Form_ID < 10050) 
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 9000 and Form_ID < 10050
		
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
		VALUES(@Menu_id1, N'Employee Costing Report', 6163, 196, 1, null, null, 1, N'Employee Costing Report', 6,'TIMESHEET')
	END
ELSE  
	BEGIN
		UPDATE T0000_DEFAULT_FORM SET Module_name = 'TIMESHEET' WHERE Form_name = 'Employee Costing Report' AND Form_ID > 9000 and Form_ID < 10050
	END

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Project Cost' And Form_ID > 9000 and Form_ID < 10050) 
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 9000 and Form_ID < 10050
		
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
		VALUES(@Menu_id1, N'Project Cost', 6163, 196, 1, null, null, 1, N'Project Cost', 6,'TIMESHEET')
	END
ELSE 
	BEGIN
		UPDATE T0000_DEFAULT_FORM SET Module_name = 'TIMESHEET' WHERE Form_name = 'Project Cost' AND Form_ID > 9000 and Form_ID < 10050
	END

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Project Overhead Cost' And Form_ID > 9000 and Form_ID < 10050) 
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 9000 and Form_ID < 10050
		
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
		VALUES(@Menu_id1, N'Project Overhead Cost', 6163, 196, 1, null, null, 1, N'Project Overhead Cost', 6,'TIMESHEET')
	END
ELSE 
	BEGIN
		UPDATE T0000_DEFAULT_FORM SET Module_name = 'TIMESHEET' WHERE Form_name = 'Project Overhead Cost' AND Form_ID > 9000 and Form_ID < 10050
	END


IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Collection Detail' And Form_ID > 9000 and Form_ID < 10050) 
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 9000 and Form_ID < 10050
		
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
		VALUES(@Menu_id1, N'Collection Detail', 6163, 196, 1, null, null, 1, N'Collection Detail', 6,'TIMESHEET')
	END
	
ELSE 
	BEGIN
		UPDATE T0000_DEFAULT_FORM SET Module_name = 'TIMESHEET' WHERE Form_name = 'Collection Detail' AND Form_ID > 9000 and Form_ID < 10050
	END


IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Timesheet Details Reports' And Form_ID > 9000 and Form_ID < 10050) 
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 9000 and Form_ID < 10050
		
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
		VALUES(@Menu_id1, N'Timesheet Details Reports', 6163, 196, 1, null, null, 1, N'Timesheet Details Reports', 6,'TIMESHEET')
	END
ELSE 
	BEGIN
		UPDATE T0000_DEFAULT_FORM SET Module_name = 'TIMESHEET' WHERE Form_name = 'Timesheet Details Reports' AND Form_ID > 9000 and Form_ID < 10050
	END
	

SELECT @SubmenuId = Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Timesheet Reports' And Form_ID > 9000 and Form_ID < 10050 

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Manager Collection Details' And Form_ID > 9000 and Form_ID < 10050) 
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 9000 and Form_ID < 10050
		
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
		VALUES(@Menu_id1, N'Manager Collection Details', @SubmenuId, 198, 1, null, null, 1, N'Manager Collection Details', 6,'TIMESHEET')
	END
ELSE 
	BEGIN
		UPDATE T0000_DEFAULT_FORM SET Under_Form_ID =@SubmenuId,Module_name = 'TIMESHEET' WHERE Form_name = 'Manager Collection Details' AND Form_ID > 9000 and Form_ID < 10050
	END



IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Project Allocation Report' And Form_ID > 9000 and Form_ID < 10050) 
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 9000 and Form_ID < 10050
		
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
		VALUES(@Menu_id1, N'Project Allocation Report', 6163, 196, 1, null, null, 1, N'Project Allocation Report', 6,'TIMESHEET')
	END
ELSE 
	BEGIN
		UPDATE T0000_DEFAULT_FORM SET Module_name = 'TIMESHEET' WHERE Form_name = 'Project Allocation Report' AND Form_ID > 9000 and Form_ID < 10050
	END

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Allowance/Deduction Revised Report' And Form_ID > 9000 and Form_ID < 10050) 
BEGIN
	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 9000 and Form_ID < 10050
	
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
	VALUES(@Menu_id1, N'Allowance/Deduction Revised Report', 6705, 179, 1, null, null, 1, N'Allowance/Deduction Revised Report', 6)
END


IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'CPS Balance Report' And Form_ID > 9000 and Form_ID < 10050) 
BEGIN
	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 9000 and Form_ID < 10050
	
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
	VALUES(@Menu_id1, N'CPS Balance Report', 6705, 179, 1, null, null, 1, N'CPS Balance Report', 6)  
END 

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Payment Slip' And Form_ID > 9000 and Form_ID < 10050) 
BEGIN
	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 9000 and Form_ID < 10050
	
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
	VALUES(@Menu_id1, N'Payment Slip', 6705, 179, 1, null, null, 1, N'Payment Slip', 6)
END
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Half Yearly Return Report' And Form_ID > 9000 and Form_ID < 10050)   -- Added By Mukti on 26122015
BEGIN
	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 9000 and Form_ID < 10050
	
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
	VALUES(@Menu_id1, N'Half Yearly Return Report', 6712, 188, 1, null, null, 1, N'Half Yearly Return Report', 31)
END


IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Leave Encash Slip' And Form_ID > 9000 and Form_ID < 10050) 
BEGIN
	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 9000 and Form_ID < 10050
	
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
	VALUES(@Menu_id1, N'Leave Encash Slip', 6703, 175, 1, null, null, 1, N'Leave Encash Slip', 14,'Payroll')
END

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Leave Against Gatepass' And Form_ID > 9000 and Form_ID < 10050) 
BEGIN
	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 9000 and Form_ID < 10050
	
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
	VALUES(@Menu_id1, N'Leave Against Gatepass', 6703, 176, 1, null, null, 1, N'Leave Against Gatepass', 15,'Payroll')
END

--Added By Jaina 31-08-2016
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Leave Application Form' And Form_ID > 9000 and Form_ID < 10050) 
BEGIN
	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 9000 and Form_ID < 10050
	
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
	VALUES(@Menu_id1, N'Leave Application Form', 6703, 177, 1, null, null, 1, N'Leave Application Form', 16,'Payroll')
END

declare @Under_Form_Id_LeaveApplicationReport Numeric		
		set @Sor_id_Check = 0
		
		SELECT @Under_Form_Id_LeaveApplicationReport = Form_ID,@Sort_Id=Sort_Id FROM T0000_DEFAULT_FORM  WITH (NOLOCK)
				where  Form_name = 'Leave Reports' --and Page_Flag = 'AR'	--Commented By Ramiz on 13/07/2018 ( As Flag is Updated after this Stage )
		
		
		if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Leave Application Report') 
			begin
			
				select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 9000 and Form_ID < 10050  
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
				values (@Menu_id1,'Leave Application Report',6703,175,1,NULL, NULL, 1, N'Leave Application Report')
			end
			if exists(select form_Id from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name = 'Leave Application Report' and Form_ID > 9000 and Form_ID < 10050)
					begin 					
							select @Sor_id_Check = ISNULL(MAX(Sort_Id_Check),0) + 1	from T0000_DEFAULT_FORM WITH (NOLOCK)
							where Under_Form_ID = @Under_Form_Id_LeaveApplicationReport
							
												
							update	T0000_DEFAULT_FORM					
							set		Sort_ID=@Sort_Id,
									Under_Form_ID = @Under_Form_Id_LeaveApplicationReport,
									Sort_Id_Check=@Sor_id_Check,
									alias = 'Leave Application Report'		
							where Form_Name = 'Leave Application Report' and Form_ID > 9000 and Form_ID < 10050 
							
					END
					
-- Deepal 08-05-24



UPDATE T0000_DEFAULT_FORM SET Page_Flag = 'AP' WHERE Form_ID >= 6000 AND Form_ID < 6500  AND Page_Flag IS NULL
UPDATE T0000_DEFAULT_FORM SET Page_Flag = 'EP' WHERE Form_ID >= 7000 AND Form_ID < 7500  AND Page_Flag IS NULL
UPDATE T0000_DEFAULT_FORM SET Page_Flag = 'AR' WHERE Form_ID >= 6700 AND Form_ID < 7000  AND Page_Flag IS NULL
UPDATE T0000_DEFAULT_FORM SET Page_Flag = 'HP' WHERE Form_ID >= 6500 AND Form_ID < 6700  AND Page_Flag IS NULL
UPDATE T0000_DEFAULT_FORM SET Page_Flag = 'ER' WHERE Form_ID >= 7500 AND Form_ID < 8000  AND Page_Flag IS NULL
UPDATE T0000_DEFAULT_FORM SET Page_Flag = 'DA' WHERE Form_ID >= 9000 AND Form_ID < 9200  AND Page_Flag IS NULL
UPDATE T0000_DEFAULT_FORM SET Page_Flag = 'DE' WHERE Form_ID >= 9200 AND Form_ID < 10000 AND Page_Flag IS NULL


--For Import Data pages
exec P0000_DEFAULT_FORM_IMPORT_DATA

exec P0000_Report_Reset
EXEC SP_Update_Sort_ID_Check  
exec P0000_Payroll_Form_Update 
exec P0000_Import_Data 
Exec Default_Leave_Amount_Update 
Exec Default_Net_Payable_Bonus_Update 

exec P0000_New_Forms_Report 

exec P0000_ESS_HOME_Update	

exec P_CUSTOMIZE_REPORTS_ENTRY

exec P0000_Payroll_Form_Update 



Update T0040_Setting 
	Set Setting_Name='Enable Back Dated Leave As Leave Arrear Days in Next Month Salary',
		Alias='Enable Back Dated Leave As Leave Arrear Days in Next Month Salary'
Where Setting_Name='Enable Back Dated Leave As Leave Arrear Days in Next Month Salary.'	

		
End



