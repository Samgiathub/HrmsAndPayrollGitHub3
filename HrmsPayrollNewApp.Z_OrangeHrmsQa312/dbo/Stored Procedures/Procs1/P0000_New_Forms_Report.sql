
CREATE PROCEDURE [dbo].[P0000_New_Forms_Report]  
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

begin


declare @Menu_id1 as numeric(18,0)
set @Menu_id1 = 0

declare @Under_form_Id as numeric(18,0)
set @Under_form_Id = 0

DECLARE @Sort_ID INT
	
--pages Flag  assign according the page or Report add in which section. 
-- if You have Any query then please contact Mr.Rohit for understand Logic 
--('AP' -- Admin Pages
--,'EP' -- Ess pages
--,'AR' -- Admin Side report
--,'HP' -- Hrms Pages
--,'IP' -- Import pages
--,'ER' -- Ess Side reports
--,'DA' -- Dashboard Admin pages
--,'DE' -- Dashboard Ess pages
--,'DH' -- Dashboard HRMS
--,'MO' -- Mobile Pages
--)


update T0000_DEFAULT_FORM set Page_Flag = 'AP' where Form_ID >=6000 and Form_ID <6500
update T0000_DEFAULT_FORM set Page_Flag = 'EP' where Form_ID >=7000 and Form_ID <7500
update T0000_DEFAULT_FORM set Page_Flag = 'AR' where Form_ID >=6700 and Form_ID <7000
update T0000_DEFAULT_FORM set Page_Flag = 'HP' where Form_ID >=6500 and Form_ID <6700
update T0000_DEFAULT_FORM set Page_Flag = 'ER' where Form_ID >=7500 and Form_ID <8000
update T0000_DEFAULT_FORM set Page_Flag = 'DA' where Form_ID >=9000 and Form_ID <9200
update T0000_DEFAULT_FORM set Page_Flag = 'DE' where Form_ID >=9200 and Form_ID <10000


-- Below Code add For Start series from 20001 for New Form Entry on 29092016
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'New Forms and Report' )
BEGIN
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_flag])
	VALUES(20001,'New Forms and Report',6163,199,1,'','',0,'New Forms and Report',0,'null','AR')
end
--Do not Code Abouve this Line 
-- Added you code always at end not Add in middle. but Assign Page_Flag always.

---- Transport Report Start ----------



IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Transport Reports' and Page_flag = 'AR')
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 20000 
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_flag])
		VALUES(@Menu_id1,'Transport Reports',6163,199,1,'','',1,'Transport Reports',0,'TRANSPORT','AR')
	END
	
SELECT @Under_form_Id = Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Transport Reports' AND Form_ID > 20000

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Route Wise Employee Report' AND Page_flag = 'AR')
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 20000 
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_flag])
		VALUES(@Menu_id1,'Route Wise Employee Report',@Under_form_Id,199,1,'','',1,'Route Wise Employee Report',1,'TRANSPORT','AR')
	END
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Section Wise Transportation Report' AND Page_flag = 'AR')
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 20000
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_flag])
		VALUES(@Menu_id1,'Section Wise Transportation Report',@Under_form_Id,199,1,'','',1,'Section Wise Transportation Report',2,'TRANSPORT','AR')
	END
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Route Wise Employee Related Report' AND Page_flag = 'AR')
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 20000
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_flag])
		VALUES(@Menu_id1,'Route Wise Employee Related Report',@Under_form_Id,199,1,'','',1,'Route Wise Employee Related Report',3,'TRANSPORT','AR')
	END
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Route Details Report' AND Page_flag = 'AR')
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 20000
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_flag])
		VALUES(@Menu_id1,'Route Details Report',@Under_form_Id,199,1,'','',1,'Route Details Report',4,'TRANSPORT','AR')
	END
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Private Vehicle Driver And Route Details' AND Page_flag = 'AR')
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 20000
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_flag])
		VALUES(@Menu_id1,'Private Vehicle Driver And Route Details',@Under_form_Id,199,1,'','',1,'Private Vehicle Driver & Route Details',5,'TRANSPORT','AR')
	END
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Staff Bus Driver And Route Details' AND Page_flag = 'AR')
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 20000
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_flag])
		VALUES(@Menu_id1,'Staff Bus Driver And Route Details',@Under_form_Id,199,1,'','',1,'Staff Bus Driver & Route Details',6,'TRANSPORT','AR')
	END
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Route Wise Pick Station And Fair' AND Page_flag = 'AR')
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 20000
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_flag])
		VALUES(@Menu_id1,'Route Wise Pick Station And Fair',@Under_form_Id,199,1,'','',1,'Route Wise Pick Station & Fair',7,'TRANSPORT','AR')
	END
---- Transport Report End ----------	
--Added by Sumit on 04102016 Dashboard Link--------------------------
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'TD_Home_ESS_312' AND Page_flag = 'DE')
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) --WHERE Form_ID > 20000
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_flag])
		VALUES(@Menu_id1,'TD_Home_ESS_312',9261,275,1,'','',1,'Optional Holiday Approval',0,'PAYROLL','DE')
	END

--Added By Jaina 31-08-2016		
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Exit Clearance Letter' AND Page_Flag = 'AR')  
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) ---where Form_ID > 6500 and Form_ID < 7000  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		values (@Menu_id1,'Exit Clearance Letter',6709, 189,1,Null,Null, 1, N'Exit Clearance Letter',1,'PAYROLL','AR')
	end		
--------------------------------------------------------------------

-----added by Nilesh Patel on 12082019 ------
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'PF Form 9' AND Page_Flag = 'AR')  
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) ---where Form_ID > 6500 and Form_ID < 7000  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		values (@Menu_id1,'PF Form 9',6706, 183,1,Null,Null, 1, N'PF Form 9',1,'PAYROLL','AR')
	end	
--------ended----------------------

-----added by jimit 02122016------
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'PF Form 15G' AND Page_Flag = 'AR')  
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) ---where Form_ID > 6500 and Form_ID < 7000  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		values (@Menu_id1,'PF Form 15G',6706, 182,1,Null,Null, 1, N'PF Form 15G',1,'PAYROLL','AR')
	end	
--------ended----------------------

--Added by Mukti on 31082018 Dashboard Link--------------------------
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'TD_Home_ESS_314' AND Page_flag = 'DE')
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM  WITH (NOLOCK) 
		select @Menu_id1
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_flag])
		VALUES(@Menu_id1,'TD_Home_ESS_314',9261,275,1,'Self_Probation.aspx','',1,'Self Assessment Probation',0,'PAYROLL','DE')
	END
	
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK)  WHERE Form_name = 'TD_Home_ESS_316' AND Page_flag = 'DE')
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID >=10000 and Form_ID <10050
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_flag])
		VALUES(@Menu_id1,'TD_Home_ESS_316',9261,275,1,'','',1,'Fill HR Checklist',0,'PAYROLL','DE')
	END
	
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'TD_Home_ESS_317' AND Page_flag = 'DE')
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID >=10000 and Form_ID <10050
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_flag])
		VALUES(@Menu_id1,'TD_Home_ESS_317',9261,275,1,'','',1,'Induction Training Questionnaire',0,'PAYROLL','DE')
	END

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'TD_Home_ESS_318' AND Page_flag = 'DE')
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID >=10000 and Form_ID <10050
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_flag])
		VALUES(@Menu_id1,'TD_Home_ESS_318',9261,275,1,'','',1,'Fill Functional Checklist',0,'PAYROLL','DE')
	END

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'TD_Home_ESS_319' AND Page_flag = 'DE')
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID >=10000 and Form_ID <10050
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_flag])
		VALUES(@Menu_id1,'TD_Home_ESS_319',9261,275,1,'','',1,'Function Induction Training Questionnaire',0,'PAYROLL','DE')
	END

----------HRMS MENU START--------------------------
declare @HRMS_Id as numeric(18,0)
declare @recruitment_id as numeric(18,0)
declare @Jobdesc_id as numeric(18,0)
declare @HRHome_Id as numeric(18,0)
declare @Appraisal_id	as NUMERIC(18,0)
declare @Appraisal_M_id	as NUMERIC(18,0)
declare @Appraisal_E_id	as NUMERIC(18,0)
declare @HRReportId NUMERIC(18,0)
declare @Rec_Post_Id as NUMERIC(18,0)
DECLARE @Training_M_Id	NUMERIC(18,0)
DECLARE @HRMS_ESS_D_Id	NUMERIC(18,0)

select @HRMS_Id = Form_ID from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name = 'HR Management' and page_flag='AP'
Update T0000_DEFAULT_FORM SET Under_Form_ID = @HRMS_Id where  page_flag = 'HP' and Under_Form_ID =-1

select @recruitment_id = Form_ID from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name = 'Recruitment Panel' and page_flag='HP'
update T0000_DEFAULT_FORM set page_flag = 'HP' where Form_Name = 'Job Description' and Under_Form_ID = @recruitment_id
select @Jobdesc_id = Form_ID from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name = 'Job Description' and page_flag='HP'
update T0000_DEFAULT_FORM set page_flag = 'HP' where  Under_Form_ID = @Jobdesc_id

update T0000_DEFAULT_FORM set page_flag = 'DH' where Form_Name = 'HR Home Page Rights' and Under_Form_ID = -1
select @HRHome_Id = form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name = 'HR Home Page Rights'  and Under_Form_ID = -1 and page_flag='DH'
update T0000_DEFAULT_FORM set page_flag = 'DH' where Under_Form_ID = @HRHome_Id

-- #region Recruitment
select  @Rec_Post_Id = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name ='Recruitment Posted Detail' and Page_Flag='HP'
update T0000_DEFAULT_FORM set page_flag = 'HP',Is_Active_For_menu=0 ,Under_Form_ID = @Rec_Post_Id where Form_Name ='Current Opening Link'

-- #region Recruitment

-- #region Training
update T0000_DEFAULT_FORM set Alias = 'Training Attendance'  where Form_Name ='Training In/Out'
update T0000_DEFAULT_FORM set Alias = 'Training Attendance Summary'  where Form_Name ='Training InOut Summary'
update T0000_DEFAULT_FORM SET Sort_Id_Check = 5 where Form_Name ='Training Provider' and Page_Flag='HP'
-- #region Training

-- #region Appraisal2
---Appraisal --2 start
select @Appraisal_id= form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name = 'Appraisal' and page_flag='HP'
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Appraisal Masters')
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag] )
		values (@Menu_id1,'Appraisal Masters',@Appraisal_id,228,0,'HRMS/HR_Home.aspx','menu/company_structure.gif',1,'Masters','Appraisal2','HP')
	end
ELSE
	BEGIN
		update T0000_DEFAULT_FORM 
		set page_flag='HP'
		where Form_Name = 'Appraisal Masters' and Under_Form_ID = @Appraisal_id
	END

select @Appraisal_M_id = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Appraisal Masters' and page_flag='HP'
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Criteria Master' and page_flag='HP')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @Appraisal_M_id, Form_Name='Criteria Master' ,alias='Criteria Master'
		where Form_Name = 'Criteria Master' and  page_flag='HP'
	end
	
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Performance Feedback Master' and page_flag='HP')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @Appraisal_M_id
		where Form_Name = 'Performance Feedback Master' and  page_flag='HP'
	end
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'KPA Type/Method/Timeframe Master' and page_flag='HP')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @Appraisal_M_id,Module_name='Appraisal2'
		where Form_Name = 'KPA Type/Method/Timeframe Master' and  page_flag='HP'
	end
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Performance Attributes' and page_flag='HP')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @Appraisal_M_id
		where Form_Name = 'Performance Attributes' and  page_flag='HP'
	end
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Other Assessment Master' and page_flag='HP')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @Appraisal_M_id
		where Form_Name = 'Other Assessment Master' and  page_flag='HP'
	end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Appraisal Status Tracker')
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM  WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag] )
		values (@Menu_id1,'Appraisal Status Tracker',@Appraisal_id,228,1,'HRMS/HRMS_Appraisal_Tracker.aspx','menu/company_structure.gif',1,'Appraisal Status Tracker','Appraisal2','HP')
	end
ELSE
	BEGIN
		update T0000_DEFAULT_FORM 
		set page_flag='HP'
			,Sort_Id_Check = 0,
			Form_Type  = 1    ---Aded By Jimit 12062019
		where Form_Name = 'Appraisal Status Tracker' and Under_Form_ID = @Appraisal_id
	END
--
select @Appraisal_E_id = form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name = 'Appraisal' and page_flag='EP'
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Appraisal HOD Approval' and page_flag='HP')
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @Appraisal_E_id	,
		    page_flag='EP'	
		where Form_Name = 'Appraisal HOD Approval' and  page_flag='HP'
	end

---Appraisal --2 end
-- #region Appraisal2

-- #region Appraisal3
--Appraisal-3 start
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Goal Setting' and page_flag='HP')
	begin
		update T0000_DEFAULT_FORM 
		set Module_name = 'Appraisal3'
		where Form_Name = 'Employee Goal Setting' and  page_flag='HP'
	end
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Goal Assessment' and page_flag='HP')
	begin
		update T0000_DEFAULT_FORM 
		set Module_name = 'Appraisal3'
		where Form_Name = 'Employee Goal Assessment' and  page_flag='HP'
	end
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Balance Score Card Setting' and page_flag='HP')
	begin
		update T0000_DEFAULT_FORM 
		set Module_name = 'Appraisal3'
		where Form_Name = 'Balance Score Card Setting' and  page_flag='HP'
	end
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Balance Score Card Evaluation' and page_flag='HP')
	begin
		update T0000_DEFAULT_FORM 
		set Module_name = 'Appraisal3'
		where Form_Name = 'Balance Score Card Evaluation' and  page_flag='HP'
	end
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Development Planning Template' and page_flag='HP')
	begin
		update T0000_DEFAULT_FORM 
		set Module_name = 'Appraisal3'
		where Form_Name = 'Development Planning Template' and  page_flag='HP'
	end
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Performance Improvement Plan' and page_flag='HP')
	begin
		update T0000_DEFAULT_FORM 
		set Module_name = 'Appraisal3'
		where Form_Name = 'Performance Improvement Plan' and  page_flag='HP'
	end
--Appraisal-3 end
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Balance Score Card' ) 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		
		select @HRReportId = form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'HRMS Reports' and Page_Flag ='AR'
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name],[page_flag])
		values(@Menu_id1, N'Balance Score Card', @HRReportId, 200, 1, null, null, 1, N'Balance Score Card',13,'Appraisal3','AR')			
	end
-- #region Appraisal3
----------HRMS MENU END--------------------------
--Added by Sumit on 25102016 because ankit bhai commented Report 
update T0000_DEFAULT_FORM set Is_Active_For_menu=0 
where Form_Name ='PT Statement Sett' and Page_Flag='AR'
------------------------------------------

--Added by Mukti(start)07112016 Added Rewards form at admin side and inactive at HRMS 
update T0000_DEFAULT_FORM set Is_Active_For_menu=0 
where Form_Name ='Rewards & Recognition' and Page_Flag='HP'

update T0000_DEFAULT_FORM set Is_Active_For_menu=0 
where Form_Name ='Initiate Employee Reward' and Page_Flag='HP'

update T0000_DEFAULT_FORM set Is_Active_For_menu=0 
where Form_Name ='Employee Reward' and Page_Flag='HP'

	Declare @Temp_Form_ID as Numeric(18,0)
	Declare @Employee_Img as varchar(50)
	set @Employee_Img=N'menu/employee.gif'
	
	select @Temp_Form_ID = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee' And Page_Flag='AP'
	select @Sort_ID = isnull(MAX(Sort_ID),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where  UNDER_FORM_ID=@Temp_Form_ID
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Rewards & Recognition' And Page_Flag='AP') 
		begin
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag],chinese_alias)
			values(@Menu_id1, N'Rewards & Recognition', @Temp_Form_ID, 82, 1, N'home.aspx', @Employee_Img, 1, N'Rewards & Recognition','PAYROLL','AP',N'獎勵和表彰')			
		end
	ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM 
			SET Sort_Id=@Sort_ID 
			WHERE FORM_NAME='Rewards & Recognition' AND UNDER_FORM_ID=@Temp_Form_ID;
		END
		
		--- binal added 9-April-2019	
	
	BEGIN 
		DECLARE @Employee_Under_Form_ID As INTEGER
		SELECT @Employee_Under_Form_ID = Form_ID From T0000_DEFAULT_FORM WITH (NOLOCK) Where Form_Name='Employee' And  Page_Flag='AP' And Under_Form_ID=-1
		
		   
		 IF NOT EXISTS (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Maker/Checker' And Page_Flag='AP') 
			BEGIN
				select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag],chinese_alias)
				values(@Menu_id1, N'Employee Maker/Checker', @Employee_Under_Form_ID, 1, 1, N'home.aspx', @Employee_Img, 1, 'Employee Maker/Checker','PAYROLL','AP',N'')			
				SET @Employee_Under_Form_ID = @Menu_id1
			END
		 ELSE
			BEGIN
				SELECT @Employee_Under_Form_ID = Form_ID  From T0000_DEFAULT_FORM WITH (NOLOCK) Where FORM_NAME='Employee Maker/Checker' AND UNDER_FORM_ID=@Employee_Under_Form_ID And Page_Flag='AP';
				UPDATE	T0000_DEFAULT_FORM 
				SET		Sort_Id=1,
						Alias = 'Employee Maker/Checker' 
				WHERE	Form_ID=@Employee_Under_Form_ID
			END
		 /*    \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ */
		 /*	   Do not add menu here */
	     /*    /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ */
	     --
		 IF NOT EXISTS (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Application' And Page_Flag='AP' )   --AND UNDER_FORM_ID=@Employee_Under_Form_ID 
			BEGIN
				SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag],chinese_alias)
				values(@Menu_id1, N'Employee Application', @Employee_Under_Form_ID, 2, 1, N'Employee_Master_Application.aspx', @Employee_Img, 1, N'Employee Application','PAYROLL','AP',N'')			
			END
		 ELSE
			BEGIN
				UPDATE T0000_DEFAULT_FORM 
				SET		Sort_Id=@Sort_ID ,
						Alias = 'Employee Application'
				WHERE FORM_NAME='Employee Application'  And Page_Flag='AP'; --AND UNDER_FORM_ID=@Employee_Under_Form_ID
			END		
		
		IF NOT EXISTS (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Approval' And Page_Flag='AP')   
			BEGIN
				SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM  WITH (NOLOCK)
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag],chinese_alias)
				values(@Menu_id1, N'Employee Approval', @Employee_Under_Form_ID, 2, 1, N'Employee_Master_Approval.aspx', @Employee_Img, 1, N'Employee Approval','PAYROLL','AP',N'')			
			END
		 ELSE
			BEGIN
				UPDATE T0000_DEFAULT_FORM 
				SET		Sort_Id=@Sort_ID ,
						Alias = 'Employee Approval',
						[Form_url] = N'Employee_Master_Approval.aspx'
				WHERE FORM_NAME='Employee Approval'  And Page_Flag='AP'; --AND UNDER_FORM_ID=@Employee_Under_Form_ID
			END		
	END
		
	---	binal end added 9-April-2019
	
	Declare @Temp_Form_ID_RR as Numeric(18,0)
	select @Temp_Form_ID_RR = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Rewards & Recognition' And Page_Flag='AP'
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Initiate Employee Reward' And Page_Flag='AP') 
		begin
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Page_Flag='AP'
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag],chinese_alias)
			values(@Menu_id1, N'Initiate Employee Reward', @Temp_Form_ID_RR, 82, 1, N'Initiate_EmpReward.aspx', @Employee_Img, 1, N'Initiate Employee Reward','PAYROLL','AP',N'啟動員工獎勵')			
		end
	ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM 
			SET Sort_Id=@Sort_ID , Form_Image_url = @Employee_Img
			WHERE FORM_NAME='Initiate Employee Reward' AND UNDER_FORM_ID=@Temp_Form_ID_RR;
		END
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Reward' And Page_Flag='AP') 
		begin
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Page_Flag='AP'
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag],chinese_alias)
			values(@Menu_id1, N'Employee Reward', @Temp_Form_ID_RR, 82, 1, N'Employee_Rewards.aspx', @Employee_Img, 1, N'Employee Reward','PAYROLL','AP',N'員工獎勵')			
		end
	ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM 
			SET Sort_Id = @Sort_ID , Form_Image_url = @Employee_Img
			WHERE FORM_NAME='Employee Reward' AND UNDER_FORM_ID=@Temp_Form_ID_RR;
		END
--Added by Mukti(end)07112016

/********ADDED BY RAMIZ ON 12/11/2016 FOR ADDING NEW PROVISION IN IMPORT PAGE AND SALES TARGET PAGES**********/
/* Kindly Use these Variables when you Add a new Provision of Import , instead of Static Numbers for Under_form_Id and Sort_ID */

DECLARE @Under_form_Id_Sales as numeric
--DECLARE @Under_form_Id_Import as numeric
DECLARE @Sort_Id_Sales as numeric
--DECLARE @Sort_Id_Import as numeric			
DECLARE @Mobile_ID as NUMERIC

--SELECT Top 1 @Under_form_Id_Import = Form_Id , @Sort_Id_Import = Sort_ID from T0000_DEFAULT_FORM WHERE Form_Name = 'Imports Data'  
--SALES ASSIGNED TARGET IMPORT PAGE
--IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM where  UPPER(FORM_NAME) = 'SALES TARGET IMPORT' AND Page_Flag = 'IP')  
--	BEGIN
--		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
--		values (@Menu_id1,'Sales Target Import',@Under_form_Id_Import, @Sort_Id_Import,1,Null,Null, 1, N'Sales Target Import',1,'Sales','IP')
--	END

--NEW MENU OF SALES TARGET
IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  UPPER(FORM_NAME) = 'SALES TARGET' AND Page_Flag = 'AP')  
	BEGIN
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		values (@Menu_id1,'Sales Target',-1, 249,1,'home.aspx','menu/sales.jpg', 1, N'Sales Target',1,'Sales','AP')
	END

SELECT Top 1 @Under_form_Id_Sales = Form_Id , @Sort_Id_Sales = Sort_ID from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_Name = 'Sales Target'  

--SALES ROUTE MASTER (ADMIN SIDE)
IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  UPPER(FORM_NAME) = 'SALES ROUTE MASTER' AND Page_Flag = 'AP')  
	BEGIN
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		values (@Menu_id1,'Sales Route Master',@Under_form_Id_Sales, @Sort_Id_Sales,1,'Sales_Route_Master.aspx','menu/sales.jpg', 1, N'Sales Route Master',1,'Sales','AP')
	END

--SALES WEEK MASTER (ADMIN SIDE)
IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  UPPER(FORM_NAME) = 'SALES WEEK MASTER' AND Page_Flag = 'AP')  
	BEGIN
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		values (@Menu_id1,'Sales Week Master',@Under_form_Id_Sales, @Sort_Id_Sales,1,'Sales_Week_Creation.aspx','menu/sales.jpg', 1, N'Sales Week Master',1,'Sales','AP')
	END

--SALES ASSIGNED TARGET VIEW PAGE (ADMIN SIDE)
IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  UPPER(FORM_NAME) = 'SALES ASSIGNED TARGET' AND Page_Flag = 'AP')  
	BEGIN
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		values (@Menu_id1,'Sales Assigned Target',@Under_form_Id_Sales, @Sort_Id_Sales,1,'Sales_AssignedTarget.aspx','menu/sales.jpg', 1, N'Sales Assigned Target',1,'Sales','AP')
	END
	
--MY ACHEIVED TARGET(ESS SIDE)
IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  UPPER(FORM_NAME) = 'My Sales Acheivement' AND Page_Flag = 'EP')  
	BEGIN
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		values (@Menu_id1,'My Sales Acheivement',7001, 309,1,'Sales_View_Target.aspx','menu/employee.gif', 1, N'My Sales Acheivement',1,'Sales','EP')
	END
	
--MEMBERS TARGET (ESS SIDE)
IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  UPPER(FORM_NAME) = 'SALES MEMBER TARGET' AND Page_Flag = 'EP')  
	BEGIN
		DECLARE @Team_ID as NUMERIC
		DECLARE @Sales_Sort_ID as NUMERIC
		
		SELECT Top 1 @Team_ID = Form_Id from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_Name = 'My Team' 
		SELECT Top 1 @Sales_Sort_ID = MAX(Sort_ID) from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Under_Form_ID = @Team_ID
		SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		VALUES (@Menu_id1,'Sales Member Target',@Team_ID, @Sales_Sort_ID,1,'Sales_Member_Target.aspx','menu/employee.gif', 1, N'Sales Member Target',1,'Sales','EP')
	END

--MOBILE PAGES (SALES TARGET -- PAGE 1)
IF NOT EXISTS (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Mobile My Sales Achievement' and Page_Flag = 'DE')
		BEGIN
			
			SELECT Top 1 @Mobile_ID = Form_Id from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Mobile Application'
			SELECT Top 1 @Sales_Sort_ID = MAX(Sort_ID) from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Under_Form_ID = @Mobile_ID
			SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_id_check],[Module_name],[Page_flag])
			VALUES  (@Menu_id1,N'Mobile My Sales Achievement',@Mobile_ID, @Sales_Sort_ID, 1, N'Sales_SelfAcheivement.aspx', NULL,1,N'Mobile My Sales Achievement' , 0 , 'Sales' , 'DE') 
		END

IF NOT EXISTS (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Mobile My Team' and Page_Flag = 'DE')
		BEGIN
			
			SELECT Top 1 @Mobile_ID = Form_Id from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Mobile Application'
			SELECT Top 1 @Sales_Sort_ID = MAX(Sort_ID) from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Under_Form_ID = @Mobile_ID
			SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_id_check],[Module_name],[Page_flag])
			VALUES  (@Menu_id1,N'Mobile My Team',@Mobile_ID, @Sales_Sort_ID, 1, N'Andriod', NULL,1,N'Mobile My Team' , 0 , 'Mobile' , 'DE') 
		END

IF NOT EXISTS (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Mobile My Sales Achievement' and Page_Flag = 'DE')
		BEGIN
			
			SELECT Top 1 @Mobile_ID = Form_Id from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Mobile Application'
			SELECT Top 1 @Sales_Sort_ID = MAX(Sort_ID) from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Under_Form_ID = @Mobile_ID
			SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_id_check],[Module_name],[Page_flag])
			VALUES  (@Menu_id1,N'Mobile My Sales Achievement',@Mobile_ID, @Sales_Sort_ID, 1, N'Sales_SelfAcheivement.aspx', NULL,1,N'Mobile My Sales Achievement' , 0 , 'Sales' , 'DE') 
		END
		
--MOBILE PAGES (SALES TARGET -- PAGE 2)		
IF NOT EXISTS (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Mobile Member Sales Achievement' and Page_Flag = 'DE')
		BEGIN
			
			SELECT Top 1 @Mobile_ID = Form_Id from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Mobile Application'
			SELECT Top 1 @Sales_Sort_ID = MAX(Sort_ID) from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Under_Form_ID = @Mobile_ID
			SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
				
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_id_check],[Module_name],[Page_flag])
			VALUES  (@Menu_id1,N'Mobile Member Sales Achievement',@Mobile_ID, @Sales_Sort_ID, 1, N'Sales_Member_Target.aspx', NULL,1,N'Mobile Member Sales Achievement' , 0 , 'Sales' , 'DE') 
		END
/******** CODE OF IMPORT PAGE & SALES PAGE ENDED BY RAMIZ ON 12/11/2016 **********/

--Added by nilesh patel on 15122016
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'View Tax Details' AND Page_Flag = 'AP')  
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) ---where Form_ID > 6500 and Form_ID < 7000  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		values (@Menu_id1,'View Tax Details',6102,153,1,Null,Null, 1, N'View Tax Details',1,'PAYROLL','AP')
	end
--Added by nilesh patel on 15122016
if not exists (select Form_id from T0000_DEFAULT_FORM  WITH (NOLOCK) where  Form_name = 'View Tax Details' AND Page_Flag = 'EP')  
	begin
	
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) ---where Form_ID > 6500 and Form_ID < 7000  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		values (@Menu_id1,'View Tax Details',7021,333,1,Null,Null, 1, N'View Tax Details',1,'PAYROLL','EP')
	end	
----Added by Sumit on 11012017-----------------------------------
--if not exists (select Form_id from T0000_DEFAULT_FORM where  Form_name = 'Tax on Other Components Import' AND Page_Flag = 'AR')  
--	begin
	
--		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM ---where Form_ID > 6500 and Form_ID < 7000  
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
--		values (@Menu_id1,'Tax on Other Components Import',6007,7,1,Null,Null, 1, N'Tax on Other Components Import',1,'PAYROLL','AR')
--	end		
IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Claim Report My#' and Page_flag='ER')		-----Sumit 12012017
	BEGIN
		SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		VALUES (@Menu_id1,'Claim Report My#',7532,400,1,'~/Report_Payroll_Mine.aspx?Id=49', NULL, 1, N'Claim Report My#',1,'PAYROLL','ER')
	END

IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  FORM_NAME = 'Increment Letter My#' AND PAGE_FLAG = 'ER')  
	BEGIN
		SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM  WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		values (@Menu_id1,'Increment Letter My#',7532, 405,1,'~/Report_Payroll_Mine.aspx?Id=172','menu/employee.gif', 1, N'Increment Letter My#',1,'Payroll','ER')
	END	
	
update T0000_DEFAULT_FORM set Sort_Id_Check=1 where Page_Flag='EP' and Under_Form_ID=7010
					and Form_Name='Loan Approval' --Added by Sumit to set Order for Loan Approval in ESS side Menu form on 07022017

/*--Ended by Sumit on 09022017-------------------------------------------------*/

----Monthly Shift Import(Added by Mukti-14032017)
--IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM where  UPPER(FORM_NAME) = 'Monthly Shift Import' AND Page_Flag = 'IP')  
--	BEGIN
--		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
--		values (@Menu_id1,'Monthly Shift Import',@Under_form_Id_Import, @Sort_Id_Import,1,Null,Null, 1, N'Monthly Shift Import',1,'Payroll','IP')
--	END

--IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM where  UPPER(FORM_NAME) = 'Incentive Import' AND Page_Flag = 'IP')  --Added by Rajput 20072017
--	BEGIN
--		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
--		values (@Menu_id1,'Incentive Import',@Under_form_Id_Import, @Sort_Id_Import,1,Null,Null, 1, N'Incentive Import',1,'Payroll','IP')
--	END
----Added by Jaina 23-02-2017 Start
--IF NOT EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Reimbursement Opening Import' AND Page_Flag = 'IP')
--	BEGIN
--		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM 
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name],[Page_flag])
--		values (@Menu_id1,N'Reimbursement Opening Import',6007,8,1,NULL,NULL,1,N'Reimbursement Opening Import',1,'Payroll','IP')
--	END	
--Added by Jaina 23-02-2017 End
				
--Added by Jaina 14-03-2017 (Responsibility Pass Over)
IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  UPPER(FORM_NAME) = 'Responsibility Pass Over' AND Page_Flag = 'EP')  
	BEGIN
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		values (@Menu_id1,'Responsibility Pass Over',7001, 309,1,'Auto_Responsibilty_Settings.aspx','menu/employee.gif', 1, N'Responsibility Pass Over',1,'Payroll','EP')
	END
--Added by Jaina 15-03-2017 Start
IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  FORM_NAME = 'View Attachment Tab(For Manager)' AND PAGE_FLAG = 'EP')  
	BEGIN
		SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		values (@Menu_id1,'View Attachment Tab(For Manager)',7002, 1,1,Null,Null, 1, N'View Attachment Tab(For Manager)',1,'Payroll','EP')
	END		

IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  FORM_NAME = 'View Attachment Tab' AND PAGE_FLAG = 'AP')  
	BEGIN
		SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		values (@Menu_id1,'View Attachment Tab',6043, 1,1,Null,Null, 1, N'View Attachment Tab',1,'Payroll','AP')
	END		
--Added by Jaina 15-03-2017 End

--Added by Jaina 17-03-2017 Start
IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  FORM_NAME = 'View Salary Tab(For Manager)' AND PAGE_FLAG = 'EP')  
	BEGIN
		
		SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM  WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		values (@Menu_id1,'View Salary Tab(For Manager)',7002, 2,1,Null,Null, 1, N'View Salary Tab(For Manager)',1,'Payroll','EP')
	END		

IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM v WHERE  FORM_NAME = 'View Salary Tab' AND PAGE_FLAG = 'AP')  
	BEGIN
		SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM  WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		values (@Menu_id1,'View Salary Tab',6043, 2,1,Null,Null, 1, N'View Salary Tab',1,'Payroll','AP')
	END	
--Added by Jaina 17-03-2017 End

IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  FORM_NAME = 'Member Change Request Details' AND PAGE_FLAG = 'EP')  
	BEGIN
		SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM  WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		values (@Menu_id1,'Member Change Request Details',7023, 352,1,'Member_Change_Request.aspx','menu/employee.gif', 1, N'Member Change Request Details',1,'Payroll','EP')
	END	
	
IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  FORM_NAME = 'News Announcement' AND PAGE_FLAG = 'EP')  
	BEGIN
		SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		values (@Menu_id1,'News Announcement',7023, 352,1,'Publish_Announcement.aspx','menu/employee.gif', 1, N'News Announcement',1,'Payroll','EP')
	END	

--Added by Jaina 03-10-2020

IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  FORM_NAME = 'Salary Lock' AND PAGE_FLAG = 'AP')  
	BEGIN
		SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM  WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		values (@Menu_id1,'Salary Lock',6129, 1,1,Null,Null, 1, N'Salary Lock',1,'Payroll','AP')
	END	

IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  FORM_NAME = 'FY Lock For IT' AND PAGE_FLAG = 'AP')  
	BEGIN
		SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		values (@Menu_id1,'FY Lock For IT',6129, 1,1,Null,Null, 1, N'FY Lock For IT',1,'Payroll','AP')
	END	

IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  FORM_NAME = 'Salary View' AND PAGE_FLAG = 'AP')  
	BEGIN
		SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		values (@Menu_id1,'Salary View',6129, 1,1,Null,Null, 1, N'Salary View',1,'Payroll','AP')
	END	

IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  FORM_NAME = 'Periodically lock for Inv. Declaration' AND PAGE_FLAG = 'AP')  
	BEGIN
		SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM  WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		values (@Menu_id1,'Periodically lock for Inv. Declaration',6129, 1,1,Null,Null, 1, N'Periodically lock for Inv. Declaration',1,'Payroll','AP')
	END	

IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  FORM_NAME = 'Payment View' AND PAGE_FLAG = 'AP')  
	BEGIN 
		SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		values (@Menu_id1,'Payment View',6129, 1,1,Null,Null, 1, N'Payment View',1,'Payroll','AP')
	END	


IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  FORM_NAME = 'Form 16 Publish' AND PAGE_FLAG = 'AP')  
	BEGIN
		SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		values (@Menu_id1,'Form 16 Publish',6129, 1,1,Null,Null, 1, N'Form 16 Publish',1,'Payroll','AP')
	END	

IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  FORM_NAME = 'Attendance Lock' AND PAGE_FLAG = 'AP')  
	BEGIN
		SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		values (@Menu_id1,'Attendance Lock',6129, 1,1,Null,Null, 1, N'Attendance Lock',1,'Payroll','AP')
	END	

IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  FORM_NAME = 'Employee Regime Selection' AND PAGE_FLAG = 'AP')  
	BEGIN
		SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		values (@Menu_id1,'Employee Regime Selection',6129, 1,1,Null,Null, 1, N'Employee Regime Selection',1,'Payroll','AP')
	END	

----Added by Nilesh Patel on 27-04-2017 Start
--IF NOT EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Uniform Opening Import' AND Page_Flag = 'IP')
--	BEGIN
--		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM 
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name],[Page_flag])
--		values (@Menu_id1,N'Uniform Opening Import',6007,8,1,NULL,NULL,1,N'Uniform Opening Import',1,'Payroll','IP')
--	END	
----Added by Nilesh Patel on 27-04-2017 End

----Added by Jaina 18-01-2018 Start
--IF NOT EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Holiday Master Import' AND Page_Flag = 'AR')
--	BEGIN
--		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM 
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name],[Page_flag])
--		values (@Menu_id1,N'Holiday Master Import',6007,8,1,NULL,NULL,1,N'Holiday Master Import',1,'Payroll','AR')
--	END	
----Added by Jaina 18-01-2018 End

--Added by Rajput 05-07-2017
DECLARE @Under_form_Id_Incentive as numeric
DECLARE @Under_form_Id_Import_Incentive as numeric
DECLARE @Sort_Id_Incentive as numeric
DECLARE @Sort_Id_Import_Incentive as numeric			

SELECT Top 1 @Under_form_Id_Incentive = Form_Id , @Sort_Id_Incentive = Sort_ID from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_Name = 'Salary Details'  
IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  UPPER(FORM_NAME) = 'Incentive Process' AND Page_Flag = 'AP')  
	BEGIN
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		values (@Menu_id1,'Incentive Process',@Under_form_Id_Incentive, 161,1,'Incentive_Process.aspx','menu/salary.gif', 1, N'Incentive Process',0,'Incentive','AP') --Change by ronak 27122023 Sep Module as "Incentive"
	END
	
--Added by Rajput 05-07-2017 End
--Added Binal 31-08-2020

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM  WITH (NOLOCK) WHERE  Form_name = 'Salary Dashboard' And Page_Flag='AP') 
    BEGIN
        SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK)
        INSERT INTO T0000_DEFAULT_FORM
				 (Form_ID,Form_Name,Under_Form_ID,Sort_ID,Form_Type,Form_url,Form_Image_url,Is_Active_For_menu,Alias,Sort_Id_Check,Module_name,Page_Flag,chinese_alias)
		VALUES (@Menu_id1,'Salary Dashboard',@Under_form_Id_Incentive,0,1,'Salary_Dashboard.aspx','menu/salary.gif',1,'Salary Dashboard',0,'Payroll','AP',Null)

    END
SELECT Top 1 @Under_form_Id_Incentive = Form_Id , @Sort_Id_Incentive = Sort_ID from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_Name = 'Salary Dashboard'  
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'TD_Salary_Dashboard_01' And Page_Flag='AP') 
    BEGIN
        SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM  WITH (NOLOCK)
        INSERT INTO T0000_DEFAULT_FORM
				 (Form_ID,Form_Name,Under_Form_ID,Sort_ID,Form_Type,Form_url,Form_Image_url,Is_Active_For_menu,Alias,Sort_Id_Check,Module_name,Page_Flag,chinese_alias)
		VALUES (@Menu_id1,'TD_Salary_Dashboard_01',@Under_form_Id_Incentive,0,1,'','',0,'Total Employee',0,'Payroll','AP',Null)

    END


IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM  WITH (NOLOCK) WHERE  Form_name = 'TD_Salary_Dashboard_02' And Page_Flag='AP') 
    BEGIN
        SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK)
        INSERT INTO T0000_DEFAULT_FORM
				 (Form_ID,Form_Name,Under_Form_ID,Sort_ID,Form_Type,Form_url,Form_Image_url,Is_Active_For_menu,Alias,Sort_Id_Check,Module_name,Page_Flag,chinese_alias)
		VALUES (@Menu_id1,'TD_Salary_Dashboard_02',@Under_form_Id_Incentive,0,1,'','',0,'Processed',0,'Payroll','AP',Null)

    END

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'TD_Salary_Dashboard_03' And Page_Flag='AP') 
    BEGIN
        SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK)
        INSERT INTO T0000_DEFAULT_FORM
				 (Form_ID,Form_Name,Under_Form_ID,Sort_ID,Form_Type,Form_url,Form_Image_url,Is_Active_For_menu,Alias,Sort_Id_Check,Module_name,Page_Flag,chinese_alias)
		VALUES (@Menu_id1,'TD_Salary_Dashboard_03',@Under_form_Id_Incentive,0,1,'','',0,'On Hold',0,'Payroll','AP',Null)

    END
	
	IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'TD_Salary_Dashboard_04' And Page_Flag='AP') 
    BEGIN
        SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK)
        INSERT INTO T0000_DEFAULT_FORM
				 (Form_ID,Form_Name,Under_Form_ID,Sort_ID,Form_Type,Form_url,Form_Image_url,Is_Active_For_menu,Alias,Sort_Id_Check,Module_name,Page_Flag,chinese_alias)
		VALUES (@Menu_id1,'TD_Salary_Dashboard_04',@Under_form_Id_Incentive,0,1,'','',0,'Pending',0,'Payroll','AP',Null)

    END

	
	IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'TD_Salary_Dashboard_05' And Page_Flag='AP') 
    BEGIN
        SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK)
        INSERT INTO T0000_DEFAULT_FORM
				 (Form_ID,Form_Name,Under_Form_ID,Sort_ID,Form_Type,Form_url,Form_Image_url,Is_Active_For_menu,Alias,Sort_Id_Check,Module_name,Page_Flag,chinese_alias)
		VALUES (@Menu_id1,'TD_Salary_Dashboard_05',@Under_form_Id_Incentive,0,1,'','',0,'Leave Pending',0,'Payroll','AP',Null)

    END

	IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'TD_Salary_Dashboard_06' And Page_Flag='AP') 
    BEGIN
        SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK)
        INSERT INTO T0000_DEFAULT_FORM
				 (Form_ID,Form_Name,Under_Form_ID,Sort_ID,Form_Type,Form_url,Form_Image_url,Is_Active_For_menu,Alias,Sort_Id_Check,Module_name,Page_Flag,chinese_alias)
		VALUES (@Menu_id1,'TD_Salary_Dashboard_06',@Under_form_Id_Incentive,0,1,'','',0,'Attendance Pending',0,'Payroll','AP',Null)

    END

	
	IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'TD_Salary_Dashboard_07' And Page_Flag='AP') 
    BEGIN
        SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK)
        INSERT INTO T0000_DEFAULT_FORM
				 (Form_ID,Form_Name,Under_Form_ID,Sort_ID,Form_Type,Form_url,Form_Image_url,Is_Active_For_menu,Alias,Sort_Id_Check,Module_name,Page_Flag,chinese_alias)
		VALUES (@Menu_id1,'TD_Salary_Dashboard_07',@Under_form_Id_Incentive,0,1,'','',0,'Salary Paid In Last 3 Months',0,'Payroll','AP',Null)

    END

	IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'TD_Salary_Dashboard_08' And Page_Flag='AP') 
    BEGIN
        SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK)
        INSERT INTO T0000_DEFAULT_FORM
				 (Form_ID,Form_Name,Under_Form_ID,Sort_ID,Form_Type,Form_url,Form_Image_url,Is_Active_For_menu,Alias,Sort_Id_Check,Module_name,Page_Flag,chinese_alias)
		VALUES (@Menu_id1,'TD_Salary_Dashboard_08',@Under_form_Id_Incentive,0,1,'','',0,'PF Eligible',0,'Payroll','AP',Null)

    END

	
	IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'TD_Salary_Dashboard_09' And Page_Flag='AP') 
    BEGIN
        SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK)
        INSERT INTO T0000_DEFAULT_FORM
				 (Form_ID,Form_Name,Under_Form_ID,Sort_ID,Form_Type,Form_url,Form_Image_url,Is_Active_For_menu,Alias,Sort_Id_Check,Module_name,Page_Flag,chinese_alias)
		VALUES (@Menu_id1,'TD_Salary_Dashboard_09',@Under_form_Id_Incentive,0,1,'','',0,'PF Non-Eligible',0,'Payroll','AP',Null)

    END

	
	IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'TD_Salary_Dashboard_10' And Page_Flag='AP') 
    BEGIN
        SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK)
        INSERT INTO T0000_DEFAULT_FORM
				 (Form_ID,Form_Name,Under_Form_ID,Sort_ID,Form_Type,Form_url,Form_Image_url,Is_Active_For_menu,Alias,Sort_Id_Check,Module_name,Page_Flag,chinese_alias)
		VALUES (@Menu_id1,'TD_Salary_Dashboard_10',@Under_form_Id_Incentive,0,1,'','',0,'ESIC',0,'Payroll','AP',Null)

    END

	
	IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'TD_Salary_Dashboard_11' And Page_Flag='AP') 
    BEGIN
        SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK)
        INSERT INTO T0000_DEFAULT_FORM
				 (Form_ID,Form_Name,Under_Form_ID,Sort_ID,Form_Type,Form_url,Form_Image_url,Is_Active_For_menu,Alias,Sort_Id_Check,Module_name,Page_Flag,chinese_alias)
		VALUES (@Menu_id1,'TD_Salary_Dashboard_11',@Under_form_Id_Incentive,0,1,'','',0,'Non-ESIC',0,'Payroll','AP',Null)

    END

	
	IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'TD_Salary_Dashboard_12' And Page_Flag='AP') 
    BEGIN
        SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK)
        INSERT INTO T0000_DEFAULT_FORM
				 (Form_ID,Form_Name,Under_Form_ID,Sort_ID,Form_Type,Form_url,Form_Image_url,Is_Active_For_menu,Alias,Sort_Id_Check,Module_name,Page_Flag,chinese_alias)
		VALUES (@Menu_id1,'TD_Salary_Dashboard_12',@Under_form_Id_Incentive,0,1,'','',0,'PT',0,'Payroll','AP',Null)

    END

	IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'TD_Salary_Dashboard_13' And Page_Flag='AP') 
    BEGIN
        SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK)
        INSERT INTO T0000_DEFAULT_FORM
				 (Form_ID,Form_Name,Under_Form_ID,Sort_ID,Form_Type,Form_url,Form_Image_url,Is_Active_For_menu,Alias,Sort_Id_Check,Module_name,Page_Flag,chinese_alias)
		VALUES (@Menu_id1,'TD_Salary_Dashboard_13',@Under_form_Id_Incentive,0,1,'','',0,'Fixed Salary',0,'Payroll','AP',Null)

    END

	
	IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'TD_Salary_Dashboard_14' And Page_Flag='AP') 
    BEGIN
        SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK)
        INSERT INTO T0000_DEFAULT_FORM
				 (Form_ID,Form_Name,Under_Form_ID,Sort_ID,Form_Type,Form_url,Form_Image_url,Is_Active_For_menu,Alias,Sort_Id_Check,Module_name,Page_Flag,chinese_alias)
		VALUES (@Menu_id1,'TD_Salary_Dashboard_14',@Under_form_Id_Incentive,0,1,'','',0,'Department And Branch Wise Salary',0,'Payroll','AP',Null)

    END

	--end binal
	

--Added by Mukti(start)01052017
Declare @Temp_Employee_ID as Numeric(18,0)
Declare @Temp_Uniform_ID as Numeric(18,0)

select @Temp_Employee_ID = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee' And Page_Flag='AP'
select @Sort_ID = isnull(MAX(Sort_ID),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where  UNDER_FORM_ID=@Temp_Employee_ID
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Uniform' And Page_Flag='AP') 
		begin
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag])
			values(@Menu_id1, N'Employee Uniform', @Temp_Employee_ID, 83, 1, N'home.aspx', @Employee_Img, 1, N'Employee Uniform','Uniform','AP')	 --Change by ronak 27122023 Sep Module as "Uniform"		
		end
	ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET Sort_Id=@Sort_ID WHERE FORM_NAME='Employee Uniform' AND UNDER_FORM_ID=@Temp_Employee_ID;
		END
	select @Temp_Uniform_ID = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Uniform' And Page_Flag='AP'
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Uniform Master' And Page_Flag='AP') 
		begin
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Page_Flag='AP'
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag])
			values(@Menu_id1, N'Uniform Master', @Temp_Uniform_ID, 83, 1, N'Master_Uniform.aspx', @Employee_Img, 1, N'Uniform Master','Uniform','AP')	 --Change by ronak 27122023 Sep Module as "Uniform"		
		end
	ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET Sort_Id=@Sort_ID WHERE FORM_NAME='Uniform Master' AND UNDER_FORM_ID=@Temp_Employee_ID;
		END
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Uniform Issue/Receive' And Page_Flag='AP') 
		begin
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Page_Flag='AP'
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag])
			values(@Menu_id1, N'Uniform Issue/Receive', @Temp_Uniform_ID, 83, 1, N'Employee_Uniform.aspx', @Employee_Img, 1, N'Uniform Issue/Receive','Uniform','AP')	 --Change by ronak 27122023 Sep Module as "Uniform"		
		end
	ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET Sort_Id=@Sort_ID WHERE FORM_NAME='Uniform Issue/Receive' AND UNDER_FORM_ID=@Temp_Employee_ID;
		END
--Added by Mukti(end)01052017
--binal 17082020
--declare @Menu_id1 as numeric(18,0)
--declare @Temp_Uniform_ID as numeric(18,0)


select @Temp_Uniform_ID = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Uniform' And Page_Flag='AP'

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Uniform Requisition Application' And Page_Flag='AP') 
		begin
		--Print 'I'
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag])
			values(@Menu_id1, N'Uniform Requisition Application', @Temp_Uniform_ID, 84, 1, N'Employee_Uniform_Requisition_Application.aspx', @Employee_Img, 1, N'Uniform Requisition Application','Uniform','AP') --Change by ronak 27122023 Sep Module as "Uniform"			
		end
	ELSE
		BEGIN	
		--Print 'U'
				
			UPDATE T0000_DEFAULT_FORM SET Sort_Id=84,Form_Image_url=@Employee_Img WHERE FORM_NAME='Uniform Requisition Application' ;
		END
		
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Uniform Requisition Approval' And Page_Flag='AP') 
		begin
		--Print 'I'
		
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag])
			values(@Menu_id1, N'Uniform Requisition Approval', @Temp_Uniform_ID, 85, 1, N'Employee_Uniform_Approval.aspx', @Employee_Img, 1, N'Uniform Requisition Approval','Uniform','AP')	 --Change by ronak 27122023 Sep Module as "Uniform"		
		end
	ELSE
		BEGIN	
		--Print 'U'
				
			UPDATE T0000_DEFAULT_FORM SET Sort_Id=85, Form_Image_url=@Employee_Img WHERE FORM_NAME='Uniform Requisition Approval' ;
		END

	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Uniform Dispatch' And Page_Flag='AP') 
		begin
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag])
			values(@Menu_id1, N'Uniform Dispatch', @Temp_Uniform_ID, 86, 1, N'Employee_Uniform_Dispatch.aspx', @Employee_Img, 1, N'Uniform Dispatch','Uniform','AP')	 --Change by ronak 27122023 Sep Module as "Uniform"		
		end
	ELSE
		BEGIN			
			UPDATE T0000_DEFAULT_FORM SET Sort_Id=86,Form_Image_url=@Employee_Img  WHERE FORM_NAME='Uniform Dispatch';
		END
	-------------------------

--binal end

--added on 05/05/2017--start
IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  UPPER(FORM_NAME) = 'Training Institute/Faculty Master' AND Page_Flag = 'HP')  
	BEGIN
		select @Training_M_Id = Form_ID from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name = 'T_Masters' and page_flag='HP' 
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		values (@Menu_id1,'Training Institute/Faculty Master',@Training_M_Id, 206,1,'HRMS/Training_Institute_master.aspx','menu/fix.gif', 1, N'Training Institute Master',4,'HRMS','HP')
	END
ELSE
	BEGIN
		UPDATE T0000_DEFAULT_FORM SET [Alias]='Training Institute Master' WHERE FORM_NAME='Training Institute/Faculty Master';
	END
--end

IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  UPPER(FORM_NAME) = 'Checklist Master' AND Page_Flag = 'HP')  
	BEGIN
		select @Training_M_Id = Form_ID from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name = 'T_Masters' and page_flag='HP' 
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		values (@Menu_id1,'Checklist Master',@Training_M_Id, 206,1,'HRMS/Induction_Checklist.aspx','menu/fix.gif', 0, N'Checklist Master',4,'HRMS','HP')
	END
ELSE
	BEGIN
		UPDATE T0000_DEFAULT_FORM SET [Alias]='Checklist Master',[Is_Active_For_menu]=0 WHERE FORM_NAME='Checklist Master';
	END
	
IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  UPPER(FORM_NAME) = 'Assign Checklist Training Wise' AND Page_Flag = 'HP')  
	BEGIN
		select @Training_M_Id = Form_ID from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name = 'T_Masters' and page_flag='HP' 
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		values (@Menu_id1,'Assign Checklist Training Wise',@Training_M_Id, 206,1,'HRMS/Training_Wise_Checklist.aspx','menu/fix.gif', 0, N'Assign Checklist Training Wise',4,'HRMS','HP')
	END
ELSE
	BEGIN
		UPDATE T0000_DEFAULT_FORM SET [Alias]='Assign Checklist Training Wise',[Is_Active_For_menu]=0 WHERE FORM_NAME='Assign Checklist Training Wise';
	END

--Added by Mukti(start)16052017
select @Under_form_Id = Form_ID from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name = 'Other Reports' and page_flag='AR'
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Uniform Stock Balance' AND Page_flag = 'AR')
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 20000
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_flag])
		VALUES(@Menu_id1,'Uniform Stock Balance',@Under_form_Id,189,1,'','',1,'Uniform Stock Balance',32,'Uniform','AR') --Change by ronak 27122023 Sep Module as "Uniform"
	END
	
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Monthly Uniform Payment' AND Page_flag = 'AR')
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 20000
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_flag])
		VALUES(@Menu_id1,'Monthly Uniform Payment',@Under_form_Id,190,1,'','',1,'Monthly Uniform Payment',32,'Uniform','AR') --Change by ronak 27122023 Sep Module as "Uniform"
	END
--Added by Mukti(end)16052017

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK)where  Form_name = 'Employee Password Details' and Page_Flag='AR') 
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) --where Form_ID > 6700  and Form_ID < 6999	  
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],Page_Flag)
		values (@Menu_id1,'Employee Password Details',6701, 173,1,NULL, NULL, 1, N'Employee Password Details','AR')
	end

--Added By Jimit 04072017--
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Employee Increment Slabwise' AND Page_flag = 'AR')
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 20000
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_flag])
		VALUES(@Menu_id1,'Employee Increment Slabwise',@Under_form_Id,191,1,'','',1,'Employee Increment Slabwise',32,'PAYROLL','AR')
	END
--ended

--Added By Mukti on 13082018--
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Exit Graphical Reports' AND Page_flag = 'AR')
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 20000
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_flag])
		VALUES(@Menu_id1,'Exit Graphical Reports',@Under_form_Id,191,1,'Exit_Graphical_Chart.aspx','',1,'Exit Graphical Reports',33,'PAYROLL','AR')
	END
--ended
--added on 17/05/2017 sneha--start
DECLARE @HRMS_ER_Id AS NUMERIC(18,0)
IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  UPPER(FORM_NAME) = 'Employee KPA My#' AND Page_Flag = 'ER')  
	BEGIN
		SELECT @HRMS_ER_Id = Form_ID from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name = 'HRMS Report My#' and page_flag='ER' 
		SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		VALUES (@Menu_id1,'Employee KPA My#',@HRMS_ER_Id, 409,1,'~/Report_Payroll_Mine.aspx?Id=9031','', 1, N'Employee KPA My#',1,'Appraisal2','ER')
	END
--end

--Added By Ramiz on 19/06/2017--
SELECT @Under_form_Id = Form_ID from T0000_DEFAULT_FORM WITH (NOLOCK) where UPPER(FORM_NAME) = 'TDS' and page_flag='AP'
SELECT @Sort_ID = isnull(MAX(Sort_ID),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where  UNDER_FORM_ID = @Under_form_Id

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Upload Form16 (Signed)' AND Page_flag = 'AP')
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_flag])
		VALUES(@Menu_id1,'Upload Form16 (Signed)',@Under_form_Id,@Sort_ID,1,'Upload_Form16.aspx','menu/salary.gif',1,'Upload Form16 (Signed)',1,'PAYROLL','AP')
	END
	
--added by Mukti(23062017)start
IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  UPPER(FORM_NAME) = 'Mobile Inout Summary My#' AND Page_Flag = 'ER')  
	BEGIN
		SELECT @Under_form_Id = Form_ID from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name = 'Attendance Reports My#' and page_flag='ER' 
		SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		VALUES (@Menu_id1,'Mobile Inout Summary My#',@Under_form_Id, 389,1,'~/Report_Payroll_Mine.aspx?Id=9033',NULL, 1, N'Mobile Inout Summary My#',1,'PAYROLL','ER')
	END
	
IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  UPPER(FORM_NAME) = 'Mobile Inout Summary Member#' AND Page_Flag = 'ER')  
	BEGIN
		SELECT @Under_form_Id = Form_ID from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name = 'Attendance Reports Member#' and page_flag='ER' 
		SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		VALUES (@Menu_id1,'Mobile Inout Summary Member#',@Under_form_Id, 347,1,'~/Report_Payroll.aspx?Id=9033',NULL, 1, N'Mobile Inout Summary Member#',1,'PAYROLL','ER')
	END
--added by Mukti(23062017)end

--IF NOT EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Quick Link' AND Page_Flag = 'AP')
--	BEGIN
--		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WHERE Form_ID > 20000
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name],[Page_flag])
--		values (@Menu_id1,N'Quick Link',-1,389,1,'home.aspx',NULL,1,N'Quick Link',1,'PAYROLL','AP')
--	END	

--IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM where  UPPER(FORM_NAME) = 'Quick Company Information' AND Page_Flag = 'AP')  
--	BEGIN
--		SELECT @Under_form_Id = Form_ID from T0000_DEFAULT_FORM where Form_Name = 'Quick Link' and page_flag='AP' 
--		SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WHERE Form_ID > 20000
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
--		VALUES (@Menu_id1,'Quick Company Information',@Under_form_Id, 390,1,'Home_Company_Update.aspx',NULL, 1, N'Company Information',1,'PAYROLL','AP')
--	END
	
--IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM where  UPPER(FORM_NAME) = 'Quick Company General Setting' AND Page_Flag = 'AP')  
--	BEGIN
--		SELECT @Under_form_Id = Form_ID from T0000_DEFAULT_FORM where Form_Name = 'Quick Link' and page_flag='AP' 
--		SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WHERE Form_ID > 20000
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
--		VALUES (@Menu_id1,'Quick Company General Setting',@Under_form_Id, 391,1,'Home_General_Setting.aspx',NULL, 1, N'Company General Setting',1,'PAYROLL','AP')
--	END
--IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM where  UPPER(FORM_NAME) = 'Upload Employees Photos' AND Page_Flag = 'AP')  
--	BEGIN
--		SELECT @Under_form_Id = Form_ID from T0000_DEFAULT_FORM where Form_Name = 'Quick Link' and page_flag='AP' 
--		SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WHERE Form_ID > 20000
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
--		VALUES (@Menu_id1,'Upload Employees Photos',@Under_form_Id, 392,1,'Upload_photo.aspx',NULL, 1, N'Upload Employees Photos',1,'PAYROLL','AP')
--	END
--IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM where  UPPER(FORM_NAME) = 'Upload Image and Video' AND Page_Flag = 'AP')  
--	BEGIN
--		SELECT @Under_form_Id = Form_ID from T0000_DEFAULT_FORM where Form_Name = 'Quick Link' and page_flag='AP' 
--		SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WHERE Form_ID > 20000
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
--		VALUES (@Menu_id1,'Upload Image and Video',@Under_form_Id, 393,1,'Gallery.aspx',NULL, 1, N'Upload Image and Video',1,'PAYROLL','AP')
--	END
	
--Added By Mukti(12072017)start--
select @Under_form_Id = Form_ID from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name = 'HRMS Reports' and page_flag='AR'
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Training Invitation Letter' AND Page_flag = 'AR')
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 20000
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_flag])
		VALUES(@Menu_id1,'Training Invitation Letter',@Under_form_Id,200,1,'','',1,'Training Invitation Letter',14,'HRMS','AR')
	END
--Added By Mukti(12072017)end--
---added on 20/07/2017 sneha ---start
SELECT @Appraisal_id= form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name = 'Appraisal' and page_flag='HP'
IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Appraisal Increment Utility' and page_flag='HP')
	BEGIN
		SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag],Sort_Id_Check )
		VALUES (@Menu_id1,'Appraisal Increment Utility',@Appraisal_id,228,1,'HRMS/Appraisal_Increment_Utility.aspx','menu/company_structure.gif',1,'Appraisal Increment Utility','Appraisal2','HP',0)
	end
ELSE
	BEGIN
		UPDATE [T0000_DEFAULT_FORM]
		SET    Form_Type = 0,
			   Form_url  = 'HRMS/HR_Home.aspx'
			   ,Sort_ID = 229
		WHERE Form_name = 'Appraisal Increment Utility' and page_flag='HP'
	END
	
DECLARE  @Appraisal_Utility AS NUMERIC(18,2)
SELECT @Appraisal_Utility = Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Appraisal Increment Utility' and page_flag='HP'
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Increment Utility' and page_flag='HP')
	BEGIN 
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag],Sort_Id_Check )
		VALUES (@Menu_id1,'Increment Utility',@Appraisal_Utility,229,1,'HRMS/Appraisal_Increment_Utility.aspx','menu/company_structure.gif',1,'Increment Utility','Appraisal2','HP',0)
	END
	
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Extra Increment Utility' and page_flag='HP')
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag],Sort_Id_Check )
		VALUES (@Menu_id1,'Extra Increment Utility',@Appraisal_Utility,229,1,'HRMS/Hrms_Extra_Increment_Utility.aspx','menu/company_structure.gif',1,'Extra Increment Utility','Appraisal2','HP',0)
	END
---added on 31/07/2017 sneha--end
--Added By Mukti(11082017)start--
select @Under_form_Id = Form_ID from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name = 'HRMS Reports' and page_flag='AR'
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Performance Improvement Letter' AND Page_flag = 'AR')
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_ID > 20000
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_flag])
		VALUES(@Menu_id1,'Performance Improvement Letter',@Under_form_Id,200,1,'','',1,'Performance Improvement Letter',14,'HRMS','AR')
	END
--Added By Mukti(11082017)end--

--added on 10/08/2017---start
	SELECT @HRMS_ESS_D_Id = Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'TD_Home_ESS_291' and page_flag='DE'
	IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'TD_Home_ESS_355' AND Page_flag = 'DE')
	BEGIN		
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_flag])
		VALUES(@Menu_id1,'TD_Home_ESS_355',@HRMS_ESS_D_Id,1332,1,'','',1,'Employee KPA Setting',0,'Appraisal2','DE')
	END
	
	IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'TD_Home_ESS_356' AND Page_flag = 'DE')
	BEGIN		
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_flag])
		VALUES(@Menu_id1,'TD_Home_ESS_356',@HRMS_ESS_D_Id,1333,1,'','',1,'Employee KPA Setting Approval',0,'Appraisal2','DE')
	END
	
	IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Employee KPA Setting Approval' and page_flag='EP')
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_flag])
		VALUES(@Menu_id1,'Employee KPA Setting Approval',@Appraisal_E_id,380,1,'ESS_EmployeeKPA_Approval.aspx','menu/hr.gif',1,'Employee KPA Setting Approval',8,'Appraisal2','EP')
	END
--added on 10/08/2017--end

--Added By Mukti(30082017)start--
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Mobile In Out Approval' AND Page_flag = 'AP')
	BEGIN
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		values (@Menu_id1,'Mobile In Out Approval',6169, 75,1,'Mobile_In_Out_Approval.aspx',@Employee_Img, 1, N'Mobile In Out Approval',0,'Payroll','AP')
	END
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'Member Mobile In Out Approval' and Page_flag = 'EP') -- Ess Panel
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [ALIAS],[Sort_id_check],[Module_name],[Page_flag])
		VALUES (@Menu_id1,'Member Mobile In Out Approval',7023,353,1,'Mobile_In_Out_Approval.aspx',@Employee_Img,1,'Member Mobile In Out Approval',0,'Payroll','EP')
	END
	
--Added By Mukti(30082017)end--

--added by chetan 020917 for user rights 

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  Form_name = 'tr_GPF_Interest' and Page_flag = 'DA') -- Ess Panel
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [ALIAS],[Sort_id_check],[Module_name],[Page_flag])
		VALUES (@Menu_id1,'tr_GPF_Interest',9061,1070,1,'','',1,'GPF Interest Credit Process',0,'GPF','DA')
	END
	
/********ADDED BY RAMIZ ON 23/02/2018 FOR ADDING NEW PROVISION OF MACHINE BASED SALARY**********/

DECLARE @Under_form_Id_Machine as numeric
DECLARE @Sort_Id_Machine as numeric	

--NEW MENU OF MACHINE
IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  UPPER(FORM_NAME) = 'MACHINE' AND Page_Flag = 'AP')  
	BEGIN
		SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		values (@Menu_id1,'Machine',-1, 250,1,'home.aspx','menu/machine.png', 1, N'Machine',1,'Machine','AP')
	END

SELECT Top 1 @Under_form_Id_Machine = Form_Id , @Sort_Id_Machine = Sort_ID from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_Name = 'Machine'  

--MACHINE MASTER (ADMIN SIDE)
IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  UPPER(FORM_NAME) = 'MACHINE MASTER' AND Page_Flag = 'AP')  
	BEGIN
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		values (@Menu_id1,'Machine Master',@Under_form_Id_Machine, @Sort_Id_Machine,1,'Machine_Master.aspx','menu/machine.png', 1, N'Machine Master',1,'Machine','AP')
	END

--MACHINE EFFICIENCY MASTER (ADMIN SIDE)
IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  UPPER(FORM_NAME) = 'MACHINE EFFICIENCY SLAB' AND Page_Flag = 'AP')  
	BEGIN
		SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		values (@Menu_id1,'Machine Efficiency Slab',@Under_form_Id_Machine, @Sort_Id_Machine,1,'Machine_Efficiency_Slab.aspx','menu/machine.png', 1, N'Machine Efficiency Slab',1,'Machine','AP')
	END

--MACHINE ALLOCATION MASTER (ADMIN SIDE)
IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  UPPER(FORM_NAME) = 'MACHINE ALLOCATION MASTER' AND Page_Flag = 'AP')  
	BEGIN
		SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		values (@Menu_id1,'Machine Allocation Master',@Under_form_Id_Machine, @Sort_Id_Machine,1,'Machine_Allocation_Master.aspx','menu/machine.png', 1, N'Machine Allocation Master',1,'Machine','AP')
	END
	
--MACHINE DAILY EFFICIENCY UPDATE(ADMIN SIDE)
IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  UPPER(FORM_NAME) = 'MACHINE DAILY EFFICIENCY' AND Page_Flag = 'AP')  
	BEGIN
		SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		values (@Menu_id1,'Machine Daily Efficiency',@Under_form_Id_Machine, @Sort_Id_Machine,1,'Machine_Daily_Efficiency.aspx','menu/machine.png', 1, N'Machine Daily Efficiency',1,'Machine','AP')
	END


----MACHINE DAILY EFFICIENCY IMPORT
--IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM where  UPPER(FORM_NAME) = 'MACHINE DAILY EFFICIENCY IMPORT' AND Page_Flag = 'IP')  
--	BEGIN
--		SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
--		VALUES (@Menu_id1,'Machine Daily Efficiency Import',@Under_form_Id_Import, @Sort_Id_Import,1,Null,Null, 1, N'Machine Daily Efficiency Import',1,'Machine','IP')
--	END

----GRADEWISE OVERTIME IMPORT AND MACHINE BASED OVERTIME IMPORT
--IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM where  UPPER(FORM_NAME) = 'MACHINE GRADEWISE OVERTIME IMPORT' AND Page_Flag = 'IP')  
--	BEGIN
--		SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
--		VALUES (@Menu_id1,'Machine Gradewise Overtime Import',@Under_form_Id_Import, @Sort_Id_Import,1,Null,Null, 1, N'Machine Gradewise Overtime Import',1,'Machine','IP')
--	END

----MACHINE ALLOWANCE IMPORT - MONTHLY BASIS
--IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM where  UPPER(FORM_NAME) = 'MACHINE MONTHLY ALLOWANCE IMPORT' AND Page_Flag = 'IP')  
--	BEGIN
--		SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
--		VALUES (@Menu_id1,'Machine Monthly Allowance Import',@Under_form_Id_Import, @Sort_Id_Import,1,Null,Null, 1, N'Machine Monthly Allowance Import',1,'Machine','IP')
--	END

/******** CODE ENDS FOR MACHINE BASED SALARY ON 07/02/2018  **********/

IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  UPPER(FORM_NAME) = 'Sales MIS My#' AND Page_Flag = 'ER')  
	BEGIN
		SELECT @Under_form_Id = Form_ID from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name = 'Other Reports My#' and page_flag='ER' 
		SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
 		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		VALUES (@Menu_id1,'Sales MIS My#',@Under_form_Id, 390,1,'~/Report_Payroll_Mine.aspx?Id=9053',NULL, 1, N'Sales MIS My#',1,'PAYROLL','ER')
	END

IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  FORM_NAME = 'Sales Import' AND PAGE_FLAG = 'EP')  
	BEGIN
		SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		values (@Menu_id1,'Sales Import',7001, 352,1,'Sales_Import.aspx','menu/employee.gif', 1, N'Sales Import',1,'Payroll','EP')
	END	


	
----MEDICAL DETAILS IMPORT - ADDED BY RAMIZ ON 16/04/2018
--IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM where  UPPER(FORM_NAME) = 'Medical Detail Import' AND Page_Flag = 'IP')  
--	BEGIN
--		SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
--		VALUES (@Menu_id1,'Medical Detail Import',@Under_form_Id_Import, @Sort_Id_Import,1,Null,Null, 1, N'Medical Detail Import',1,'Payroll','IP')
--	END

--Added by Mukti(start)18042018	
DECLARE @Under_form_Id_Appraisal as numeric
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Appraisal Status Tracker' And Form_ID > 7000 and Form_ID < 7500) 
	begin
		select @Under_form_Id_Appraisal = form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Appraisal' And Form_ID > 7000 and Form_ID < 7500
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7500
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name],[Page_Flag])
		values(@Menu_id1, N'Appraisal Status Tracker', @Under_form_Id_Appraisal, 380, 1, N'Ess_HRMS_Appraisal_Tracker.aspx', N'menu/hr.gif', 1, N'Appraisal Status Tracker',9,'Appraisal2','EP')			
	end

--Added by Mukti(end)18042018	

--Following Code added by Nilesh on 01/05/2018 (For Monarch Client)
/*
--This code is commented by Nimesh (No need to add in project if this is for only one client
IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE  FORM_NAME = 'Lead Application' AND PAGE_FLAG = 'EP')  
	BEGIN
		SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM 
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		values (@Menu_id1,'Lead Application',7001, 352,1,'http://192.168.1.79/LMS/Login.aspx','menu/employee.gif', 1, N'Lead Application',1,'Payroll','EP')
	END	
*/
	
IF NOT EXISTS (SELECT FORM_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE  FORM_NAME = 'Lead Assign' AND PAGE_FLAG = 'DE')  
	BEGIN
		SELECT @MENU_ID1 = ISNULL(MAX(FORM_ID),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		values (@Menu_id1,'Lead Assign',7001, 353,1,'','', 1, N'Lead Assign',1,'Payroll','DE')
	END	

IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  UPPER(FORM_NAME) = 'Attendance Approval' AND Page_Flag = 'EP')  
	BEGIN
		SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		values (@Menu_id1,'Attendance Approval',7001, 352,1,'Attendance_Approve_Ess.aspx','menu/employee.gif', 1, N'Attendance Approval',1,'Payroll','EP')
	END
 
--Added By Mukti(15052018)start--
select @Under_form_Id = Form_ID from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name = 'HRMS Reports' and page_flag='AR'
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Training Graphical Reports' AND Page_flag = 'AR')
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) --WHERE Form_ID > 20000
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_flag])
		VALUES(@Menu_id1,'Training Graphical Reports',@Under_form_Id,200,1,'','',1,'Training Graphical Reports',14,'HRMS','AR')
	END	
--Added By Mukti(15052018)end--

--Added by Mukti(start)19062018
Declare @Temp_Training_ID as Numeric(18,0)
Declare @Temp_Induction_ID as Numeric(18,0)

select @Temp_Training_ID = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Training' And Page_Flag='HP'
select @Sort_ID = isnull(MAX(Sort_ID),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where  UNDER_FORM_ID=@Temp_Training_ID
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Training Induction' And Page_Flag='HP') 
		begin
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag])
			values(@Menu_id1, N'Training Induction', @Temp_Training_ID, 206, 1, N'HRMS/HR_Home.aspx', 'menu/fix.gif', 1, N'Training Induction','HRMS','HP')			
		end
	ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET Sort_Id=@Sort_ID WHERE FORM_NAME='Training Induction' AND UNDER_FORM_ID=@Temp_Training_ID;
		END
	select @Temp_Induction_ID = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Training Induction' And Page_Flag='HP'
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Training Induction Master' And Page_Flag='HP') 
		begin
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) --where Page_Flag='HP'
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag])
			values(@Menu_id1, N'Training Induction Master', @Temp_Induction_ID, 206, 1, N'HRMS/HRMS_Training_Induction_Master.aspx', 'menu/fix.gif', 1, N'Training Induction Master','HRMS','HP')			
		end
	ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET Sort_Id=@Sort_ID WHERE FORM_NAME='Training Induction Master' AND UNDER_FORM_ID=@Temp_Training_ID;
		END
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Training Induction Plan' And Page_Flag='HP') 
		begin
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) --where Page_Flag='HP'
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag])
			values(@Menu_id1, N'Training Induction Plan', @Temp_Induction_ID, 206, 1, N'HRMS/HRMS_Training_Induction_Entry.aspx', 'menu/fix.gif', 1, N'Training Induction Plan','HRMS','HP')			
		end
	ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET Sort_Id=@Sort_ID WHERE FORM_NAME='Training Induction Plan' AND UNDER_FORM_ID=@Temp_Training_ID;
		END
	--Added by Mukti(end)19062018
	--Added by Mukti(start)21072018
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Training Evaluation' And Page_Flag='HP') 
			begin
				select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) --where Page_Flag='HP'
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag])
				values(@Menu_id1, N'Training Evaluation', @Temp_Training_ID, 214, 1, N'HRMS/Training_Typewise_Evaluation.aspx', 'menu/fix.gif', 1, N'Training Evaluation','HRMS','HP')			
			end
		ELSE
			BEGIN
				UPDATE T0000_DEFAULT_FORM SET Sort_Id=214 WHERE FORM_NAME='Training Evaluation' AND UNDER_FORM_ID=@Temp_Training_ID;
			END
	--Added by Mukti(end)21072018
	--Added by Mukti(17092018)start
	IF NOT EXISTS (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Probation Self Rating' And Form_ID > 7000 and Form_ID < 7499)
			BEGIN    
				select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 7000 and Form_ID < 7499
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name],[Page_flag])
				VALUES(@Menu_id1, N'Probation Self Rating', 7001, 353, 1, N'Self_Probation.aspx', 'menu/employee.gif', 1, N'Probation Self Rating',1,'Payroll','EP')
			END
	--Added by Mukti(17092018)end



	----- ADDED BY RAJPUT ON 03112018 ---

	--IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM where  UPPER(FORM_NAME) = 'Bond Approval Import' AND Page_Flag = 'IP')  
	--	BEGIN
		
	--		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM
	--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
	--		values (@Menu_id1,N'Bond Approval Import',@Under_form_Id_Import, @Sort_Id_Import,1,Null,Null, 1, N'Bond Approval Import',1,'Loan','IP')
	--	END

	---- END ----
	------------ ASSIGN EMPLOYEE VERTICAL - SUBVERTICAL ---------------
	If not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Assign Vertical & Sub-Vertical' AND Page_Flag = 'AP')
		Begin
			Select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_Flag])
			values (@Menu_id1,'Assign Vertical & Sub-Vertical',6171, 345, 1,'Assign_Vertical_Sub_Vertical.aspx',@Employee_Img,1,'Assign Vertical & Sub-Vertical','Payroll','AP')		
		End
	------------ END ASSIGN EMPLOYEE VERTICAL - SUBVERTICAL ---------------

	--Added by Mukti(29012019)start
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Recruitment Tracker' And Page_Flag = 'HP') 
		begin
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_Flag])
			values(@Menu_id1, N'Recruitment Tracker', 6501, 205, 1, 'HRMS/Recruitment_Tracker.aspx','menu/Recruitement.png', 1, N'Recruitment Tracker','HRMS','HP')			
		end
	--Added by Mukti(29012019)end


	--Added By Mukti(26112018)start--
	select @Under_form_Id = Form_ID from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name = 'HRMS Reports' and page_flag='AR'
	IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Resume Details Report' AND Page_flag = 'AR')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_flag])
			VALUES(@Menu_id1,'Resume Details Report',@Under_form_Id,201,1,'','',1,'Resume Details Report',15,'HRMS','AR')
		END
	--Added By Mukti(26112018)end--

		----Added By Jimit 01032019			
		--	IF NOT EXISTS(SELECT FORM_ID FROM T0000_DEFAULT_FORM WHERE FORM_NAME = 'Increment Application Import' AND Page_Flag = 'IP')
		--		BEGIN
		--				select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM
		--				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Page_Flag])
		--				values (@Menu_id1,N'Increment Application Import',@Under_form_Id_Import,@Sort_Id_Import,1,NULL,NULL,1,N'Increment Application Import','IP')
		--		END				
		----Ended

	--Added by Mukti(29012019)start
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Recruitment Tracker' And Page_Flag = 'HP') 
		begin
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_Flag])
			values(@Menu_id1, N'Recruitment Tracker', 6501, 205, 1, 'HRMS/Recruitment_Tracker.aspx','menu/Recruitement.png', 1, N'Recruitment Tracker','HRMS','HP')			
		end
	--Added by Mukti(29012019)end

	--Added by Mukti(04032019)start
	IF NOT EXISTS (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'My KPA' AND Page_Flag='EP') 
		BEGIN		
			SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name],[Page_Flag])
			VALUES(@Menu_id1, N'My KPA', 7137, 380, 1, N'Ess_EmployeeKPA.aspx', N'menu/hr.gif', 1, N'My KPA',3,'Appraisal2','EP')			
		END
	
	IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'TD_Home_ESS_320' AND Page_flag = 'DE')
		BEGIN
			SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_flag])
			VALUES(@Menu_id1,'TD_Home_ESS_320',9291,1295,1,'Ess_HRMS_Appraisal_Tracker.aspx','',1,'Appraisal Status Tracker',0,'Appraisal2','DE')
		END
	
	UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=4 WHERE Form_name = 'Employee KPA Setting Approval' and Page_Flag='EP'
	UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=5 WHERE Form_name = 'Employee Assessment' and Page_Flag='EP'
	UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=7 WHERE Form_name = 'Appraisal HOD Approval' and Page_Flag='EP'
	UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=10 WHERE Form_name = 'Appraisal Status Tracker' and Page_Flag='EP'

	UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=1 WHERE Form_name = 'Appraisal Masters' and Page_Flag='HP'
	UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=2 WHERE Form_name = 'Range Master & General Settings' and Page_Flag='HP'
	UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=3 WHERE Form_name = 'Employee KPA' and Page_Flag='HP'
	UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=4 WHERE Form_name = 'Appraisal Initiation' and Page_Flag='HP'
	UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=5 WHERE Form_name = 'Employee Self Assessment' and Page_Flag='HP'
	UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=6 WHERE Form_name = 'Performance Assessment' and Page_Flag='HP'
	UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=7 WHERE Form_name = 'Appraisal Finalization' and Page_Flag='HP'
	UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=8 WHERE Form_name = 'Final Approval Stage' and Page_Flag='HP'
	UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=9 WHERE Form_name = 'Appraisal Status Tracker' and Page_Flag='HP'
	UPDATE T0000_DEFAULT_FORM SET Sort_Id_Check=10 WHERE Form_name = 'Appraisal Increment Utility' and Page_Flag='HP'
	UPDATE T0000_DEFAULT_FORM SET Form_url='~/Report_Customized_HRMS_Ess.aspx?Id=999' WHERE Form_name = 'Hrms Customize Report Member#' and Page_Flag='ER' --Mukti(14052019)
	DELETE FROM T0000_DEFAULT_FORM where Form_Name='Self Assessment Master'

	IF NOT EXISTS (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'My Self Assessment' AND Page_Flag='EP') 
		BEGIN		
			SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name],[Page_Flag])
			VALUES(@Menu_id1, N'My Self Assessment', 7137, 380, 1, N'SelfAppraisal_Form.aspx', N'menu/hr.gif', 1, N'My Self Assessment',2,'Appraisal2','EP')			
		END
END 
--Added by Mukti(04032019)

--Added By Nilesh Patel on 19032019
select @Under_form_Id = Form_ID from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name = 'Attendance Regularization' and page_flag='AP'
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Attendance Regularization Approval' AND Page_flag = 'AP')
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_flag])
		VALUES(@Menu_id1,'Attendance Regularization Approval',@Under_form_Id,1,1,NULL,NULL,1,'Attendance Regularization Approval',1,'Payroll','AP')
		
		/* Added Code By Nilesh patel on 20032019 -- For Assign Default Privilege */
		IF OBJECT_ID('tempdb..#AttendanceData') is not null
			Begin
				Drop Table #AttendanceData
			End

		Create Table #AttendanceData
		(
			Privilege_ID Numeric,
			Cmp_ID Numeric
		)

		Insert Into #AttendanceData
		Select Distinct Privilage_ID,Cmp_Id From T0050_PRIVILEGE_DETAILS WITH (NOLOCK) Where Form_Id = @Under_form_Id and (Is_View + Is_Delete + Is_Edit + Is_Print + Is_Save) > 0

		INSERT INTO T0050_PRIVILEGE_DETAILS 
		select  (select Isnull(max(Trans_Id),0) from T0050_PRIVILEGE_DETAILS WITH (NOLOCK))  + ROW_NUMBER() OVER (ORDER BY Privilege_ID) as Trans_Id,
		PM.Privilege_ID,PM.Cmp_Id,@Menu_id1,1, 1, 1, 1, 1
		From #AttendanceData PM
	END
	
	
--Added by Rajput on 29032019 Performance Import 
select @Under_form_Id = Form_ID from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name = 'Performance Detail' and page_flag='AP'
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Performance Import' AND Page_flag = 'AP')
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_flag])
		VALUES(@Menu_id1,'Performance Import',@Under_form_Id,1,1,NULL,NULL,1,'Performance Import',1,'Payroll','AP')
	END

--Added by Mukti(05062019)start
select @Under_form_Id = Form_ID from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name = 'Loan LIC Reports' and page_flag='AR'	
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Asset Purchase Details Report' AND Page_Flag = 'AR')  
begin
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
	values (@Menu_id1,'Asset Purchase Details Report',@Under_form_Id, 178,1,Null,Null, 1, N'Asset Purchase Details Report',1,'PAYROLL','AR')
end	

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Asset Summary Details Report' AND Page_Flag = 'AR')  
begin
	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
	values (@Menu_id1,'Asset Summary Details Report',@Under_form_Id, 179,1,Null,Null, 1, N'Asset Summary Details Report',1,'PAYROLL','AR')
end	
--Added by Mukti(05062019)end

--Added by Mukti(06062019)start
	select @Under_form_Id = Form_ID from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name = 'Recruitment Panel' and page_flag='HP'	
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Interview Calendar' And Page_Flag = 'HP') 
		begin
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_Flag])
			values(@Menu_id1, N'Interview Calendar', @Under_form_Id, 206, 1, 'HRMS/HRMS_Interview_Schedule_Calander.aspx','menu/Recruitement.png', 1, N'Interview Calendar','HRMS','HP')			
		end
--Added by Mukti(06062019)end

--Added By Nilesh Patel on 19082019 --Start -- Privilege Details is not exists so that why added it
IF NOT EXISTS (select Form_id from T0000_DEFAULT_FORM  WITH (NOLOCK) where  Form_name = 'Mobile CompOff Application' and Page_Flag = 'DE')
		BEGIN
			
			SELECT Top 1 @Mobile_ID = Form_Id from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Mobile Application'
			SELECT Top 1 @Sales_Sort_ID = MAX(Sort_ID) from T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Under_Form_ID = @Mobile_ID
			SELECT @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_id_check],[Module_name],[Page_flag])
			VALUES  (@Menu_id1,N'Mobile CompOff Application',@Mobile_ID, @Sales_Sort_ID, 1, N'Compoff.aspx', NULL,1,N'Mobile CompOff Application' , 0 , 'MOBILE' , 'DE') 
		END
--Added By Nilesh Patel on 19082019 -- End

--Added By Mukti(11102019)start--
select @Under_form_Id = Form_ID from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name = 'HRMS Reports' and page_flag='AR'
IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Appraisal Graphical Reports' AND Page_flag = 'AR')
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) --WHERE Form_ID > 20000
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_flag])
		VALUES(@Menu_id1,'Appraisal Graphical Reports',@Under_form_Id,201,1,'','',1,'Appraisal Graphical Reports',15,'HRMS','AR')
	END	
--Added By Mukti(11102019)end--

--Added By Mukti(06022020)start--
select @Under_form_Id = Form_ID from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name = 'Recruitment Panel' and page_flag='HP'
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Induction Schedule' And Page_Flag = 'HP') 
		begin
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_Flag])
			values(@Menu_id1, N'Induction Schedule', @Under_form_Id, 206, 1, 'HRMS/Induction_Recruitment.aspx','menu/Recruitement.png', 1, N'Induction Schedule','HRMS','HP')			
		end
--Added By Mukti(06022020)end--

--Added by Krushna(start)21072020
select @Temp_Employee_ID = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee' And Page_Flag='AP'
select @Sort_ID = isnull(MAX(Sort_ID),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where  UNDER_FORM_ID=@Temp_Employee_ID
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Piece Transaction' And Page_Flag='AP') 
		begin
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag])
			values(@Menu_id1, N'Piece Transaction', @Temp_Employee_ID, 84, 1, N'home.aspx', @Employee_Img, 1, N'Piece Transaction','Piece_Transaction','AP') --Change by ronak 27122023 Sep Module as "Piece_Transaction"			
		end
	ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET Sort_Id=@Sort_ID WHERE FORM_NAME='Piece Transaction' AND UNDER_FORM_ID=@Temp_Employee_ID;
		END
	select @Temp_Uniform_ID = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Piece Transaction' And Page_Flag='AP'
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Product/SubProduct Master' And Page_Flag='AP') 
		begin
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Page_Flag='AP'
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag])
			values(@Menu_id1, N'Product/SubProduct Master', @Temp_Uniform_ID, 85, 1, N'Piece_Transaction_Master.aspx', @Employee_Img, 1, N'Product/SubProduct Master','Piece_Transaction','AP')		--Change by ronak 27122023 Sep Module as "Piece_Transaction"	
		end
	ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET Sort_Id=@Sort_ID WHERE FORM_NAME='Product/SubProduct Master' AND UNDER_FORM_ID=@Temp_Employee_ID;
		END
--Added by Krushna(end)21072020

--Added by Deepak for Contractor Reports
select @Temp_Employee_ID = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Reports'
select @Sort_ID = isnull(MAX(Sort_ID),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where  UNDER_FORM_ID=@Temp_Employee_ID
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Contractor Reports' And Page_Flag='AR') 
		begin
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag])
			values(@Menu_id1, N'Contractor Reports', @Temp_Employee_ID, 200, 1, N'', @Employee_Img, 1, N'Contractor Reports','PAYROLL','AR')			
		end
	ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET Sort_Id=@Sort_ID WHERE FORM_NAME='Contractor Reports' AND UNDER_FORM_ID=@Temp_Employee_ID;
		END

	
	select @Temp_Uniform_ID = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Contractor Reports' And Page_Flag='AR'
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'FORM VI-A Notice' And Page_Flag='AR') 
		begin
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Page_Flag='AR'
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag])
			values(@Menu_id1, N'FORM VI-A Notice', @Temp_Uniform_ID, 2, 1, N'', @Employee_Img, 1, N'FORM VI-A Notice','PAYROLL','AR')			
		end
	ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET Sort_Id=@Sort_ID WHERE FORM_NAME='FORM VI-A Notice' AND UNDER_FORM_ID=@Temp_Employee_ID;
		END
	
	select @Temp_Uniform_ID = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Contractor Reports' And Page_Flag='AR'
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'FORM XII Register of Contractor' And Page_Flag='AR') 
		begin
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Page_Flag='AR'
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag])
			values(@Menu_id1, N'FORM XII Register of Contractor', @Temp_Uniform_ID, 3, 1, N'', @Employee_Img, 1, N'FORM XII Register of Contractor','PAYROLL','AR')			
		end
	ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET Sort_Id=@Sort_ID WHERE FORM_NAME='FORM XII Register of Contractor' AND UNDER_FORM_ID=@Temp_Employee_ID;
		END
	
	select @Temp_Uniform_ID = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Contractor Reports' And Page_Flag='AR'
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'FORM XIV-Employment Card' And Page_Flag='AR') 
		begin
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Page_Flag='AR'
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag])
			values(@Menu_id1, N'FORM XIV-Employment Card', @Temp_Uniform_ID, 4, 1, N'', @Employee_Img, 1, N'FORM XIV-Employment Card','PAYROLL','AR')			
		end
	ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET Sort_Id=@Sort_ID WHERE FORM_NAME='FORM XIV-Employment Card' AND UNDER_FORM_ID=@Temp_Employee_ID;
		END

		select @Temp_Uniform_ID = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Contractor Reports' And Page_Flag='AR'
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'FORM XV-Service Certificate' And Page_Flag='AR') 
		begin
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Page_Flag='AR'
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag])
			values(@Menu_id1, N'FORM XV-Service Certificate', @Temp_Uniform_ID, 5, 1, N'', @Employee_Img, 1, N'FORM XV-Service Certificate','PAYROLL','AR')			
		end
	ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET Sort_Id=@Sort_ID WHERE FORM_NAME='FORM XV-Service Certificate' AND UNDER_FORM_ID=@Temp_Employee_ID;
		END
		 
----Added by Deepak for Contractor Reports start For ESS Menu
IF NOT EXISTS (SELECT Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  FORM_NAME = 'Contractor Reports My#' AND Page_Flag = 'ER')  
	BEGIN
		SELECT @Under_form_Id = Form_ID from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_Name = 'My Reports' and page_flag='EP' 
		SELECT  @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_id_check],[Module_name],[Page_flag])
		VALUES (@Menu_id1,'Contractor Reports My#',@Under_form_Id, 409,1,NULL,NULL, 1, N'Contractor Reports My#',0,'Payroll','ER')
	END
		
select @Temp_Uniform_ID = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Contractor Reports My#' And Page_Flag='ER'
select @Sort_ID = isnull(MAX(Sort_ID),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where  UNDER_FORM_ID=@Temp_Uniform_ID
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'FORM VI-A Notice My#' And Page_Flag='ER') 
		begin
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Page_Flag='ER'
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag])
			values(@Menu_id1, N'FORM VI-A Notice My#', @Temp_Uniform_ID, @Sort_ID, 1, '~/Report_Payroll_Mine.aspx?Id=20100', @Employee_Img, 1, N'FORM VI-A Notice My#','PAYROLL','ER')			
		end
	ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET Sort_Id=@Sort_ID WHERE FORM_NAME='FORM VI-A Notice My#' AND UNDER_FORM_ID=@Temp_Uniform_ID;
		END
	
	select @Temp_Uniform_ID = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Contractor Reports My#' And Page_Flag='ER'
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'FORM XII Register of Contractor My#' And Page_Flag='ER') 
		begin
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Page_Flag='ER'
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag])
			values(@Menu_id1, N'FORM XII Register of Contractor My#', @Temp_Uniform_ID, @Sort_ID, 1, '~/Report_Payroll_Mine.aspx?Id=20101', @Employee_Img, 1, N'FORM XII Register of Contractor My#','PAYROLL','ER')			
		end
	ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET Sort_Id=@Sort_ID WHERE FORM_NAME='FORM XII Register of Contractor My#' AND UNDER_FORM_ID=@Temp_Uniform_ID;
		END
	
	select @Temp_Uniform_ID = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Contractor Reports My#' And Page_Flag='ER'
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'FORM XIV-Employment Card My#' And Page_Flag='ER') 
		begin
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Page_Flag='ER'
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag])
			values(@Menu_id1, N'FORM XIV-Employment Card My#', @Temp_Uniform_ID,@Sort_ID, 1, '~/Report_Payroll_Mine.aspx?Id=20102', @Employee_Img, 1, N'FORM XIV-Employment Card My#','PAYROLL','ER')			
		end
	ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET Sort_Id=@Sort_ID WHERE FORM_NAME='FORM XIV-Employment Card My#' AND UNDER_FORM_ID=@Temp_Uniform_ID;
		END

		select @Temp_Uniform_ID = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Contractor Reports My#' And Page_Flag='ER'
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'FORM XV-Service Certificate My#' And Page_Flag='ER') 
		begin
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Page_Flag='ER'
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag])
			values(@Menu_id1, N'FORM XV-Service Certificate My#', @Temp_Uniform_ID, @Sort_ID, 1,'~/Report_Payroll_Mine.aspx?Id=20103', @Employee_Img, 1, N'FORM XV-Service Certificate My#','PAYROLL','ER')			
		end
	ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET Sort_Id=@Sort_ID WHERE FORM_NAME='FORM XV-Service Certificate My#' AND UNDER_FORM_ID=@Temp_Uniform_ID;
		END

------Added by Deepak for Contractor Reports start For Admin Menu	
select @Temp_Uniform_ID = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Contractor Reports' And Page_Flag='AR'

select @Sort_ID = isnull(MAX(Sort_ID),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where  UNDER_FORM_ID=@Temp_Uniform_ID

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'FORM XX-Reg Deduction' And Page_Flag='AR') 
		begin
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		    INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag])
			values(@Menu_id1, N'FORM XX-Reg Deduction', @Temp_Uniform_ID, @Sort_ID, 1, N'', @Employee_Img, 1, N'FORM XX-Reg Deduction','PAYROLL','AR')	
		end
	ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET Sort_Id=@Sort_ID WHERE FORM_NAME='FORM XX-Reg Deduction' AND UNDER_FORM_ID=@Temp_Uniform_ID;
		END

if not exists (select Form_id from T0000_DEFAULT_FORM  WITH (NOLOCK) where  Form_name = 'FORM XVII-Register Of Wages' And Page_Flag='AR') 
		begin
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag])
			values(@Menu_id1, N'FORM XVII-Register Of Wages', @Temp_Uniform_ID, @Sort_ID, 1, N'', @Employee_Img, 1, N'FORM XVII-Register Of Wages','PAYROLL','AR')	
		end
ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET Sort_Id=@Sort_ID WHERE FORM_NAME='FORM XVII-Register Of Wages' AND UNDER_FORM_ID=@Temp_Uniform_ID;
		END

if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'FORM XXI-Register Of Fines' And Page_Flag='AR') 
		begin
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag])
			values(@Menu_id1, N'FORM XXI-Register Of Fines', @Temp_Uniform_ID, @Sort_ID, 1, N'', @Employee_Img, 1, N'FORM XXI-Register Of Fines','PAYROLL','AR')	
		end
ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET Sort_Id=@Sort_ID WHERE FORM_NAME='FORM XXI-Register Of Fines' AND UNDER_FORM_ID=@Temp_Uniform_ID;
		END
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'FORM XXII-Register Of Advances' And Page_Flag='AR') 
		begin
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag])
			values(@Menu_id1, N'FORM XXII-Register Of Advances', @Temp_Uniform_ID, @Sort_ID, 1, N'', @Employee_Img, 1, N'FORM XXII-Register Of Advances','PAYROLL','AR')	
		end
ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET Sort_Id=@Sort_ID WHERE FORM_NAME='FORM XXII-Register Of Advances' AND UNDER_FORM_ID=@Temp_Uniform_ID;
		END
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'FORM XXIII-Register Of Overtime' And Page_Flag='AR') 
		begin
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag])
			values(@Menu_id1, N'FORM XXIII-Register Of Overtime', @Temp_Uniform_ID, @Sort_ID, 1, N'', @Employee_Img, 1, N'FORM XXIII-Register Of Overtime','PAYROLL','AR')	
		end
ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET Sort_Id=@Sort_ID WHERE FORM_NAME='FORM XXIII-Register Of Overtime' AND UNDER_FORM_ID=@Temp_Uniform_ID;
		END
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'FORM 9-COMPA' And Page_Flag='AR') 
		begin
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag])
			values(@Menu_id1, N'FORM 9-COMPA', @Temp_Uniform_ID, @Sort_ID, 1, N'', @Employee_Img, 1, N'FORM 9-COMPA','PAYROLL','AR')	
		end
ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET Sort_Id=@Sort_ID WHERE FORM_NAME='FORM 9-COMPA' AND UNDER_FORM_ID=@Temp_Uniform_ID;
		END
if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'FORM B-NH/NF' And Page_Flag='AR') 
		begin
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag])
			values(@Menu_id1, N'FORM B-NH/NF', @Temp_Uniform_ID, @Sort_ID, 1, N'', @Employee_Img, 1, N'FORM B-NH/NF','PAYROLL','AR')	
		end
ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET Sort_Id=@Sort_ID WHERE FORM_NAME='FORM B-NH/NF' AND UNDER_FORM_ID=@Temp_Uniform_ID;
		END

IF NOT EXISTS (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'FORM XXIV-RETURNS' And Page_Flag='AR') 
		BEGIN
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag])
			values(@Menu_id1, N'FORM XXIV-RETURNS', @Temp_Uniform_ID, @Sort_ID, 1, N'', @Employee_Img, 1, N'FORM XXIV-RETURNS','PAYROLL','AR')	
		END
ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET Sort_Id=@Sort_ID WHERE FORM_NAME='FORM XXIV-RETURNS' AND UNDER_FORM_ID=@Temp_Uniform_ID;
		END

IF NOT EXISTS (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'FORM XXV-ANNUAL RETURN' And Page_Flag='AR') 
		BEGIN
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag])
			values(@Menu_id1, N'FORM XXV-ANNUAL RETURN', @Temp_Uniform_ID, @Sort_ID, 1, N'', @Employee_Img, 1, N'FORM XXV-ANNUAL RETURN','PAYROLL','AR')	
		END
ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET Sort_Id=@Sort_ID WHERE FORM_NAME='FORM XXV-ANNUAL RETURN' AND UNDER_FORM_ID=@Temp_Uniform_ID;
		END

IF NOT EXISTS (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'FORM D-EQUAL REMUNERATION' And Page_Flag='AR') 
		BEGIN
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag])
			values(@Menu_id1, N'FORM D-EQUAL REMUNERATION', @Temp_Uniform_ID, @Sort_ID, 1, N'', @Employee_Img, 1, N'FORM D-EQUAL REMUNERATION','PAYROLL','AR')	
		END
ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET Sort_Id=@Sort_ID WHERE FORM_NAME='FORM D-EQUAL REMUNERATION' AND UNDER_FORM_ID=@Temp_Uniform_ID;
		END

IF NOT EXISTS (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'FORM B-Welfare' And Page_Flag='AR') 
		BEGIN
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag])
			values(@Menu_id1, N'FORM B-Welfare', @Temp_Uniform_ID, @Sort_ID, 1, N'', @Employee_Img, 1, N'FORM B-Welfare','PAYROLL','AR')	
		END
ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET Sort_Id=@Sort_ID WHERE FORM_NAME='FORM B-Welfare' AND UNDER_FORM_ID=@Temp_Uniform_ID;
		END

	

--Added by Krushna(start)10092020
	set @Temp_Uniform_ID = 0
	select @Temp_Uniform_ID = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Piece Transaction' And Page_Flag='AP'
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Rate / Revised Assginment' And Page_Flag='AP') 
		begin
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag])
			values(@Menu_id1, N'Rate / Revised Assginment', @Temp_Uniform_ID, 86, 1, N'Rate_Master.aspx', @Employee_Img, 1, N'Rate / Revised Assginment','Piece_Transaction','AP')	 --Change by ronak 27122023 Sep Module as "Piece_Transaction"		
		end
	ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET Sort_Id=@Sort_ID WHERE FORM_NAME='Rate / Revised Assginment' AND UNDER_FORM_ID=@Temp_Employee_ID;
		END

		set @Temp_Uniform_ID = 0
		select @Temp_Uniform_ID = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Piece Transaction' And Page_Flag='AP'
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Pieces Transaction' And Page_Flag='AP') 
		begin
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag])
			values(@Menu_id1, N'Pieces Transaction', @Temp_Uniform_ID, 87, 1, N'Pieces_Transaction.aspx', @Employee_Img, 1, N'Pieces Transaction','Piece_Transaction','AP')	 --Change by ronak 27122023 Sep Module as "Piece_Transaction"		
		end
	ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET Sort_Id=@Sort_ID WHERE FORM_NAME='Pieces Transaction' AND UNDER_FORM_ID=@Temp_Employee_ID;
		END
--Added by Krushna(end)10092020

	-- Added by Hardik 28/12/2020 for Salary Summary Report -- HMP Client
	set @Temp_Uniform_ID = 0
	select @Temp_Uniform_ID = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Salary Reports' And Page_Flag='AR'
	select @Sort_ID = isnull(MAX(Sort_ID),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where  UNDER_FORM_ID=@Temp_Uniform_ID
	if not exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Salary Summary' And Page_Flag='AR') 
		begin
			select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag])
			values(@Menu_id1, N'Salary Summary', @Temp_Uniform_ID, @Sort_ID, 1, N'', Null, 1, N'Salary Summary','PAYROLL','AR')	
		end
	ELSE
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET Sort_Id=@Sort_ID WHERE FORM_NAME='Salary Summary' AND UNDER_FORM_ID=@Temp_Uniform_ID;
		END


IF EXISTS (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Over Time' And Page_Flag='EP') 
		BEGIN
			select @Temp_Employee_ID = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'My Team' And Page_Flag='EP'
			UPDATE T0000_DEFAULT_FORM SET FORM_NAME='Overtime Approval',alias='Overtime Approval' WHERE FORM_NAME='Over Time' AND UNDER_FORM_ID=@Temp_Employee_ID And Page_Flag='EP'
		END
UPDATE T0000_DEFAULT_FORM SET Alias='Appraisal HOD Approval' where Form_Name='TD_Home_ESS_350'
UPDATE T0000_DEFAULT_FORM SET Alias='Appraisal Group Head Approval' where Form_Name='TD_Home_ESS_296'
UPDATE T0000_DEFAULT_FORM SET Alias='Appraisal Reporting Manager Approval' where Form_Name='TD_Home_ESS_295'
UPDATE T0000_DEFAULT_FORM SET Is_Active_For_menu=0 WHERE FORM_NAME='Employee Assessment' AND Page_Flag='EP'

IF NOT EXISTS (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Own Your Vehicle' and Page_Flag='EP')
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag])		
		values(@Menu_id1, N'Own Your Vehicle', -1, 330, 1, N'home.aspx', 'menu/loan-claim.gif', 0, N'Own Your Vehicle','PAYROLL','EP')	 -- Change by ronak 27122023
	end

IF NOT EXISTS (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Vehicle Application' and Page_Flag='EP')
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		set @Temp_Uniform_ID = 0
		select @Temp_Uniform_ID = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Own Your Vehicle' And Page_Flag='EP'
		select @Sort_ID = isnull(MAX(Sort_ID),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where  UNDER_FORM_ID=@Temp_Uniform_ID
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag])		
		values(@Menu_id1, N'Vehicle Application', @Temp_Uniform_ID, 330, 1, N'Vehicle_Application.aspx', 'menu/loan-claim.gif', 1, N'Vehicle Application','PAYROLL','EP')	
	end

IF NOT EXISTS (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Vehicle Approval' and Page_Flag='EP')
	begin
		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		set @Temp_Uniform_ID = 0
		select @Temp_Uniform_ID = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Own Your Vehicle' And Page_Flag='EP'
		select @Sort_ID = isnull(MAX(Sort_ID),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where  UNDER_FORM_ID=@Temp_Uniform_ID
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name],[Page_flag])		
		values(@Menu_id1, N'Vehicle Approval', @Temp_Uniform_ID, 330, 1, N'Vehicle_Approval.aspx', 'menu/loan-claim.gif', 1, N'Vehicle Approval','PAYROLL','EP')	
	end

IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Own Your Vehicle' and PAGE_FLAG='AP')      
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK)   
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_flag])
		VALUES(@Menu_id1, N'Own Your Vehicle', 6070, 250, 1, N'Home.aspx', N'menu/loan-claim.gif', 0,N'Own Your Vehicle',0,'PAYROLL','AP')  -- Change by ronak 27122023
	END

	SET @Temp_Uniform_ID=0
IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Vehicle Type Master' and PAGE_FLAG='AP')      
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK)   
		select @Temp_Uniform_ID = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Own Your Vehicle' And Page_Flag='AP'
		select @Sort_ID = isnull(MAX(Sort_ID),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where  UNDER_FORM_ID=@Temp_Uniform_ID
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_flag])
		VALUES(@Menu_id1, N'Vehicle Type Master', @Temp_Uniform_ID, @Sort_ID, 1, N'Vehicle_Type_Master.aspx',N'menu/loan-claim.gif', 1,N'Vehicle Type Master',0,'PAYROLL','AP')
	END

IF NOT EXISTS(SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'Admin Vehicle Approval' and PAGE_FLAG='AP')      
	BEGIN
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM  WITH (NOLOCK)  
		select @Temp_Uniform_ID = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Own Your Vehicle' And Page_Flag='AP'
		select @Sort_ID = isnull(MAX(Sort_ID),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where  UNDER_FORM_ID=@Temp_Uniform_ID
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_flag])
		VALUES(@Menu_id1, N'Admin Vehicle Approval', @Temp_Uniform_ID, @Sort_ID, 1, N'Admin_Vehicle_Approval.aspx',N'menu/loan-claim.gif', 1,N'Admin Vehicle Approval',0,'PAYROLL','AP')
	END

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'TD_Home_ESS_358' AND Page_flag = 'DE')
	BEGIN		
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_flag])
		VALUES(@Menu_id1,'TD_Home_ESS_358',9261,1334,1,'Vehicle_Approval.aspx','',1,'Own Your Vehicle Approval',0,'Payroll','DE')
	END

IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_name = 'TD_Home_ESS_357' AND Page_flag = 'DE')
	BEGIN		
		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM WITH (NOLOCK)
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID],[Form_Name],[Under_Form_ID],[Sort_ID],[Form_Type],[Form_url],[Form_Image_url],[Is_Active_For_menu],[Alias],[Sort_Id_Check],[Module_name],[Page_flag])
		VALUES(@Menu_id1,'TD_Home_ESS_357',9261,1334,1,'Recruitment_Application_Approval.aspx','',1,'Recruitment Approval',0,'HRMS','DE')
	END
		UPDATE T0000_DEFAULT_FORM SET Form_url = 'hrms/TrainingType_master.aspx' WHERE Form_Name='Training Type Master' and Page_Flag='HP'
		UPDATE T0000_DEFAULT_FORM SET Alias='Resume Screening',form_type=1,page_flag='DE' WHERE Form_name='TD_Home_HR_7'
