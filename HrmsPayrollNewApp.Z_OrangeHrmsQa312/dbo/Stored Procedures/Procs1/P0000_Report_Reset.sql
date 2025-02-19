
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0000_Report_Reset]  

AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON --Added by sumit as per nimesh bhai guideline
begin

--declare @Menu_id1 as numeric(18,0)


--IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WHERE  Form_name = 'Attendance Card' And Page_Flag in  ('AR','IP')) 
--BEGIN
--	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WHERE Page_Flag in  ('AR','IP')
	
--	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
--	VALUES(@Menu_id1, N'Attendance Card', 6702, 173, 1, null, null, 1, N'Attendance Card', 14)
--END
----Added By Jaina 2-11-2015 Start
--if not exists (select Form_id from T0000_DEFAULT_FORM where  Form_name = 'Deviation Report')
--Begin
--		select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Page_Flag in  ('AR','IP')
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
--		values (@Menu_id1,'Deviation Report',6702,173,1,'','',1,'Deviation Report',15)
--End	
----Added By Jaina 2-11-2015 End
--IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WHERE  Form_name = 'Leave Encash Amount' And Page_Flag in  ('AR','IP')) 
--BEGIN
--	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WHERE Page_Flag in  ('AR','IP')
	
--	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
--	VALUES(@Menu_id1, N'Leave Encash Amount', 6703, 79, 1, null, null, 1, N'Leave Encash Amount', 6)
--END


--IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WHERE  Form_name = 'Pending Loan Detail' And Page_Flag in  ('AR','IP')) 
--BEGIN
--	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WHERE Page_Flag in  ('AR','IP')
	
--	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
--	VALUES(@Menu_id1, N'Pending Loan Detail', 6703, 79, 1, null, null, 1, N'Pending Loan Detail', 6)
--END

--IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WHERE  Form_name = 'Salary Summary Bankwise' And Page_Flag in  ('AR','IP')) 
--BEGIN
--	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WHERE Page_Flag in  ('AR','IP')
	
--	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
--	VALUES(@Menu_id1, N'Salary Summary Bankwise', 6703, 79, 1, null, null, 1, N'Salary Summary Bankwise', 6)
--END

----IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WHERE  Form_name = 'ESIC Components' And Page_Flag in  ('AR','IP')) 
----BEGIN
----	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WHERE Page_Flag in  ('AR','IP')
	
----	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
----	VALUES(@Menu_id1, N'ESIC Components', 6703, 79, 1, null, null, 1, N'ESIC Components', 6)
----END

--IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WHERE  Form_name = 'Travel Statement' And Page_Flag in  ('AR','IP')) 
--BEGIN
--	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WHERE Page_Flag in  ('AR','IP')
	
--	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
--	VALUES(@Menu_id1, N'Travel Statement', 6703, 79, 1, null, null, 1, N'Travel Statement', 6)
--END

--IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WHERE  Form_name = 'Employee Insurance1' And Page_Flag in  ('AR','IP')) 
--BEGIN
--	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WHERE Page_Flag in  ('AR','IP')
	
--	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
--	VALUES(@Menu_id1, N'Employee Insurance1', 6703, 79, 1, null, null, 1, N'Employee Insurance1', 6)
--END

--IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WHERE  Form_name = 'Canteen Deduction' And Page_Flag in  ('AR','IP')) 
--BEGIN
--	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WHERE Page_Flag in  ('AR','IP')
	
--	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
--	VALUES(@Menu_id1, N'Canteen Deduction', 6705, 180, 1, null, null, 1, N'Canteen Deduction', 6)
--END

---------------------- Timesheet Report Start ------------------------
--IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WHERE Form_name = 'Timesheet Reports' And Page_Flag in  ('AR','IP')) 
--	BEGIN
--		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WHERE Page_Flag in  ('AR','IP')
		
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name] )
--		VALUES(@Menu_id1, N'Timesheet Reports', 6163, 198, 1, null, null, 1, N'Timesheet Reports', 0,'TIMESHEET')
--	END
--ELSE  -- Added by Prakash Patel 28102015
--	BEGIN
--		UPDATE T0000_DEFAULT_FORM SET Module_name = 'TIMESHEET' WHERE Form_name = 'Timesheet Reports' AND Page_Flag in  ('AR','IP')
--	END

--IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WHERE  Form_name = 'Employee Costing Report' And Page_Flag in  ('AR','IP')) 
--	BEGIN
--		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WHERE Page_Flag in  ('AR','IP')
		
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
--		VALUES(@Menu_id1, N'Employee Costing Report', 6163, 196, 1, null, null, 1, N'Employee Costing Report', 6,'TIMESHEET')
--	END
--ELSE  -- Added by Prakash Patel 28102015
--	BEGIN
--		UPDATE T0000_DEFAULT_FORM SET Module_name = 'TIMESHEET' WHERE Form_name = 'Employee Costing Report' AND Page_Flag in  ('AR','IP')
--	END

--IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WHERE  Form_name = 'Project Cost' And Page_Flag in  ('AR','IP')) 
--	BEGIN
--		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WHERE Page_Flag in  ('AR','IP')
		
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
--		VALUES(@Menu_id1, N'Project Cost', 6163, 196, 1, null, null, 1, N'Project Cost', 6,'TIMESHEET')
--	END
--ELSE -- Added by Prakash Patel 28102015
--	BEGIN
--		UPDATE T0000_DEFAULT_FORM SET Module_name = 'TIMESHEET' WHERE Form_name = 'Project Cost' AND Page_Flag in  ('AR','IP')
--	END

--IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WHERE  Form_name = 'Project Overhead Cost' And Page_Flag in  ('AR','IP')) 
--	BEGIN
--		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WHERE Page_Flag in  ('AR','IP')
		
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
--		VALUES(@Menu_id1, N'Project Overhead Cost', 6163, 196, 1, null, null, 1, N'Project Overhead Cost', 6,'TIMESHEET')
--	END
--ELSE -- Added by Prakash Patel 28102015
--	BEGIN
--		UPDATE T0000_DEFAULT_FORM SET Module_name = 'TIMESHEET' WHERE Form_name = 'Project Overhead Cost' AND Page_Flag in  ('AR','IP')
--	END

--IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WHERE  Form_name = 'Collection Detail' And Page_Flag in  ('AR','IP')) 
--	BEGIN
--		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WHERE Page_Flag in  ('AR','IP')
		
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
--		VALUES(@Menu_id1, N'Collection Detail', 6163, 196, 1, null, null, 1, N'Collection Detail', 6,'TIMESHEET')
--	END
	
--ELSE -- Added by Prakash Patel 28102015
--	BEGIN
--		UPDATE T0000_DEFAULT_FORM SET Module_name = 'TIMESHEET' WHERE Form_name = 'Collection Detail' AND Page_Flag in  ('AR','IP')
--	END

--IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WHERE  Form_name = 'Timesheet Details Reports' And Page_Flag in  ('AR','IP')) 
--	BEGIN
--		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WHERE Page_Flag in  ('AR','IP')
		
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
--		VALUES(@Menu_id1, N'Timesheet Details Reports', 6163, 196, 1, null, null, 1, N'Timesheet Details Reports', 6,'TIMESHEET')
--	END
--ELSE -- Added by Prakash Patel 28102015
--	BEGIN
--		UPDATE T0000_DEFAULT_FORM SET Module_name = 'TIMESHEET' WHERE Form_name = 'Timesheet Details Reports' AND Page_Flag in  ('AR','IP')
--	END
--IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WHERE  Form_name = 'Manager Collection Details' And Page_Flag in  ('AR','IP')) 
--	BEGIN
--		SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WHERE Page_Flag in  ('AR','IP')
		
--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check],[Module_name])
--		VALUES(@Menu_id1, N'Manager Collection Details', 6163, 196, 1, null, null, 1, N'Manager Collection Details', 6,'TIMESHEET')
--	END
--ELSE -- Added by Prakash Patel 28102015
--	BEGIN
--		UPDATE T0000_DEFAULT_FORM SET Module_name = 'TIMESHEET' WHERE Form_name = 'Manager Collection Details' AND Page_Flag in  ('AR','IP')
--	END
---------------------- Timesheet Report End ------------------------


--IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WHERE  Form_name = 'Allowance/Deduction Revised Report' And Page_Flag in  ('AR','IP')) 
--BEGIN
--	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WHERE Page_Flag in  ('AR','IP')
	
--	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
--	VALUES(@Menu_id1, N'Allowance/Deduction Revised Report', 6705, 179, 1, null, null, 1, N'Allowance/Deduction Revised Report', 6)
--END


--IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WHERE  Form_name = 'CPS Balance Report' And Page_Flag in  ('AR','IP')) 
--BEGIN
--	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WHERE Page_Flag in  ('AR','IP')
	
--	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
--	VALUES(@Menu_id1, N'CPS Balance Report', 6705, 179, 1, null, null, 1, N'CPS Balance Report', 6)
--END

--IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WHERE  Form_name = 'Payment Slip' And Page_Flag in  ('AR','IP')) 
--BEGIN
--	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WHERE Page_Flag in  ('AR','IP')
	
--	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
--	VALUES(@Menu_id1, N'Payment Slip', 6705, 179, 1, null, null, 1, N'Payment Slip', 6)
--END

--Commented by Sumit to add all this in P0000_default_form_new sp check this sp

--if  not exists (select Form_id from T0000_DEFAULT_FORM where  Form_name = 'Asset Customize' And Form_ID < 7000)  --Mukti 05102015
--begin  
--	select @Menu_id1 = isnull(MAX(Form_id),0) + 1 from T0000_DEFAULT_FORM where Form_ID < 7000
--	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias])
--	values (@Menu_id1,N'Asset Customize',6714 ,172,1,'',NULL,1,N'Asset Customize')
--end
--IF NOT EXISTS (SELECT Form_id FROM T0000_DEFAULT_FORM WHERE  Form_name = 'Form 13 (Revised)' And Page_Flag in  ('AR','IP')) 
--BEGIN
--	SELECT @Menu_id1 = ISNULL(MAX(Form_id),0) + 1 FROM T0000_DEFAULT_FORM WHERE Page_Flag in  ('AR','IP')
	
--	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Sort_Id_Check])
--	VALUES(@Menu_id1, N'Form 13 (Revised)', 6706, 181, 1, null, null, 1, N'Form 13 (Revised)', 6)
--END

declare @Sort_Id as numeric(18,0)
declare @Sor_id_Check as numeric(18,0)

-- Employee Report Start --
Declare @form_id_Emp_Report as Numeric(18,0)
set @form_id_Emp_Report = 0
--set @Sort_Id = @Sort_Id + 20
set @Sort_Id = 0
select @form_id_Emp_Report = Form_id,@Sort_Id = sort_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Reports' and Page_Flag in  ('AR','IP')

set @Sor_id_Check =0
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Customize Report'  and Page_Flag in  ('AR','IP'))
	begin
	declare @form_id_Customized numeric(18,0)
	set @form_id_Customized = 0
	
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Emp_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Customize Report'
		where Form_Name = 'Customize Report' and Page_Flag in  ('AR','IP')
		
		select @form_id_Customized = Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Customize Report'  and Page_Flag in  ('AR','IP')
		
		set @Sor_id_Check = @Sor_id_Check + 1
		if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  form_name='Employee Customize' and Page_Flag in  ('AR','IP'))
		begin
			update T0000_DEFAULT_FORM 
			set Under_Form_ID = @form_id_Customized,
			Sort_ID=@Sort_Id,
			Sort_Id_Check=@Sor_id_Check,
			alias='Employee Customize'
			where Form_Name = 'Employee Customize' and Page_Flag in  ('AR','IP')
		end
		
		set @Sor_id_Check = @Sor_id_Check + 1
		if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  form_name='Leave Customize' and Page_Flag in  ('AR','IP'))
		begin
			update T0000_DEFAULT_FORM 
			set Under_Form_ID = @form_id_Customized,
			Sort_ID=@Sort_Id,
			Sort_Id_Check=@Sor_id_Check,
			alias='Leave Customize'
			where Form_Name = 'Leave Customize' and Page_Flag in  ('AR','IP')
		end
		
		set @Sor_id_Check = @Sor_id_Check + 1
		if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  form_name='Salary Customize' and Page_Flag in  ('AR','IP'))
		begin
			update T0000_DEFAULT_FORM 
			set Under_Form_ID = @form_id_Customized,
			Sort_ID=@Sort_Id,
			Sort_Id_Check=@Sor_id_Check,
			alias='Salary Customize'
			where Form_Name = 'Salary Customize' and Page_Flag in  ('AR','IP')
		end
		
		set @Sor_id_Check = @Sor_id_Check + 1
		if exists (select Form_id from T0000_DEFAULT_FORM  WITH (NOLOCK) where  form_name='Tax Customize' and Page_Flag in  ('AR','IP'))
		begin
			update T0000_DEFAULT_FORM 
			set Under_Form_ID = @form_id_Customized,
			Sort_ID=@Sort_Id,
			Sort_Id_Check=@Sor_id_Check,
			alias='Tax Customize'
			where Form_Name = 'Tax Customize' and Page_Flag in  ('AR','IP')
		end
		
		set @Sor_id_Check = @Sor_id_Check + 1
		if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  form_name='Attendance Customize' and Page_Flag in  ('AR','IP'))
		begin
			update T0000_DEFAULT_FORM 
			set Under_Form_ID = @form_id_Customized,
			Sort_ID=@Sort_Id,
			Sort_Id_Check=@Sor_id_Check,
			alias='Attendance Customize'
			where Form_Name = 'Attendance Customize' and Page_Flag in  ('AR','IP')
		end
		
		set @Sor_id_Check = @Sor_id_Check + 1 --Mukti 05102015
		if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  form_name='Asset Customize' and Page_Flag in  ('AR','IP'))
		begin
			update T0000_DEFAULT_FORM 
			set Under_Form_ID = @form_id_Customized,
			Sort_ID=@Sort_Id,
			Sort_Id_Check=@Sor_id_Check,
			alias='Asset Customize'
			where Form_Name = 'Asset Customize' and Page_Flag in  ('AR','IP')
		end
		
		set @Sor_id_Check = @Sor_id_Check + 1
		if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  form_name='Others Customize' and Page_Flag in  ('AR','IP'))
		begin
			update T0000_DEFAULT_FORM 
			set Under_Form_ID = @form_id_Customized,
			Sort_ID=@Sort_Id,
			Sort_Id_Check=@Sor_id_Check,
			alias='Others Customize'
			where Form_Name = 'Others Customize' and Page_Flag in  ('AR','IP')
		end
	end



set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee List(Form-13)' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Emp_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Employee List(Form-13)'
		where Form_Name = 'Employee List(Form-13)' and Page_Flag in  ('AR','IP')
	end



set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee CTC' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Emp_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Employee CTC'
		where Form_Name = 'Employee CTC' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Left Employee' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Emp_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Left Employee'
		where Form_Name = 'Left Employee' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Shift Report' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Emp_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Shift Report'
		where Form_Name = 'Shift Report' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Weekly Off' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Emp_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Weekly Off'
		where Form_Name = 'Weekly Off' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Warning' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Emp_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Employee Warning'
		where Form_Name = 'Employee Warning' and Page_Flag in  ('AR','IP')
	end
	

update T0000_DEFAULT_FORM set Is_Active_For_menu=0 where  Form_name = 'Employee Insurance' and Page_Flag in  ('AR','IP')
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Insurance2' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Emp_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Employee Insurance'
		where Form_Name = 'Employee Insurance2' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Asset Position' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Emp_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Asset Position'
		where Form_Name = 'Asset Position' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Salary Structure' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Emp_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Employee Salary Structure'
		where Form_Name = 'Employee Salary Structure' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Birthday List' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Emp_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Employee Birthday List'
		where Form_Name = 'Employee Birthday List' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Active/InActive User History' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Emp_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Active/InActive User History'
		where Form_Name = 'Active/InActive User History' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Optional Holiday' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Emp_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Optional Holiday'
		where Form_Name = 'Optional Holiday' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Company Transfer' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Emp_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Employee Company Transfer'
		where Form_Name = 'Employee Company Transfer' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Information' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Emp_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Employee Information'
		where Form_Name = 'Employee Information' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Scheme Details Report' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Emp_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Scheme Details Report'
		where Form_Name = 'Scheme Details Report' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Age Analysis' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Emp_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Employee Age Analysis'
		where Form_Name = 'Employee Age Analysis' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Experience Analysis' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Emp_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Employee Experience Analysis'
		where Form_Name = 'Employee Experience Analysis' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee New Joining-Left Summary' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Emp_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Employee New Joining-Left Summary'
		where Form_Name = 'Employee New Joining-Left Summary' and Page_Flag in  ('AR','IP') 
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Incerment Summary' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Emp_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Employee Incerment Summary'
		where Form_Name = 'Employee Incerment Summary' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Retirement Summary' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Emp_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Employee Retirement Summary'
		where Form_Name = 'Employee Retirement Summary' and Page_Flag in  ('AR','IP')
	end
-- Employee Report End--



-- Attendance Report Start --
Declare @form_id_attendance_Report as Numeric(18,0)
set @form_id_Emp_Report = 0
--set @Sort_Id = @Sort_Id + 20
set @Sort_Id = 0
select @form_id_attendance_Report = Form_id,@Sort_Id = sort_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Attendance Reports' and Page_Flag in  ('AR','IP')

set @Sor_id_Check =0
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Attendance Register' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_attendance_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Attendance Register'
		where Form_Name = 'Attendance Register' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'In-Out Register' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_attendance_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='In-Out Register'
		where Form_Name = 'In-Out Register' and Page_Flag in  ('AR','IP')
	end
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Holiday Work' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_attendance_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Holiday/Weekoff Work'
		where Form_Name = 'Holiday Work' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'In-Out Summary' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_attendance_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='In-Out Summary'
		where Form_Name = 'In-Out Summary' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Missing In-out' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_attendance_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Missing In-out'
		where Form_Name = 'Missing In-out' and Page_Flag in  ('AR','IP') 
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Late/Early Mark Summary' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_attendance_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Late/Early Mark Summary'
		where Form_Name = 'Late/Early Mark Summary' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Device Inout Summary' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_attendance_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Device Inout Summary'
		where Form_Name = 'Device Inout Summary'  and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Inout Present Days' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_attendance_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Employee Inout Present Days'
		where Form_Name = 'Employee Inout Present Days' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Daily Attendance' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_attendance_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Daily Attendance'
		where Form_Name = 'Daily Attendance' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Login History' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_attendance_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Login History'
		where Form_Name = 'Login History' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Absent' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_attendance_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Absent'
		where Form_Name = 'Absent' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Attendance Regularization' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_attendance_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Attendance Regularization'
		where Form_Name = 'Attendance Regularization' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Gate Pass In out Summary' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_attendance_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Gate Pass In out Summary'
		where Form_Name = 'Gate Pass In out Summary' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Shift Allocation' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_attendance_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Shift Allocation'
		where Form_Name = 'Shift Allocation' and Page_Flag in  ('AR','IP')
	end
	
	set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Attendance Card' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_attendance_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Attendance Card'
		where Form_Name = 'Attendance Card' and Page_Flag in  ('AR','IP')
	end
	
	
	
-- Attendance Report End--

-- Leave Report Start --
Declare @form_id_Leave_Report as Numeric(18,0)
set @form_id_Emp_Report = 0
--set @Sort_Id = @Sort_Id + 20
set @Sort_Id = 0
select @form_id_Leave_Report = Form_id,@Sort_Id = sort_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Leave Reports' and Page_Flag in  ('AR','IP')

set @Sor_id_Check =0
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Leave Approval' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Leave_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Leave Approval'
		where Form_Name = 'Leave Approval' and Page_Flag in  ('AR','IP') 
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Leave Balance' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Leave_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Leave Balance'
		where Form_Name = 'Leave Balance' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Leave Closing' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Leave_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Leave Closing'
		where Form_Name = 'Leave Closing' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Yearly Leave Summary' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Leave_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Yearly Leave Summary'
		where Form_Name = 'Yearly Leave Summary' and Page_Flag in  ('AR','IP')
	end



set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Yearly Leave Transaction ' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Leave_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Yearly Leave Transaction '
		where Form_Name = 'Yearly Leave Transaction ' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Yearly Leave Encash' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Leave_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Yearly Leave Encash'
		where Form_Name = 'Yearly Leave Encash' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Leave Register with wages' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Leave_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Leave Register with wages'
		where Form_Name = 'Leave Register with wages' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Leave Card (Form-19)' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Leave_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Leave Card (Form-19)'
		where Form_Name = 'Leave Card (Form-19)' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Leave Application Tracking' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Leave_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Leave Application Tracking'
		where Form_Name = 'Leave Application Tracking' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Comp-Off Leave Adjustment Details' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Leave_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Comp-Off Leave Adjustment Details'
		where Form_Name = 'Comp-Off Leave Adjustment Details' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Leave Balance with Amount' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Leave_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Leave Balance with Amount'
		where Form_Name = 'Leave Balance with Amount' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Comp-Off Avail Balance' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Leave_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Comp-Off Avail Balance'
		where Form_Name = 'Comp-Off Avail Balance' and Page_Flag in  ('AR','IP')
	end
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Leave Encash Amount' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Leave_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Leave Encash Amount'
		where Form_Name = 'Leave Encash Amount' and Page_Flag in  ('AR','IP')
	end
	
--Added by Jaina 03-12-2016 Start
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Leave Against GatePass' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Leave_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Leave Against GatePass'
		where Form_Name = 'Leave Against GatePass' and Page_Flag in  ('AR','IP')
	end
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Leave Encash Slip' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Leave_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Leave Encashment Slip'
		where Form_Name = 'Leave Encash Slip' and Page_Flag in  ('AR','IP')
	end

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Leave Application Form' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Leave_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Leave Application Form'
		where Form_Name = 'Leave Application Form' and Page_Flag in  ('AR','IP')
	end
--Added by Jaina 03-12-2016 End
-- Leave Report End--

-- Loan Report Start --
Declare @form_id_Loan_Report as Numeric(18,0)
set @form_id_Emp_Report = 0
--set @Sort_Id = @Sort_Id + 20
set @Sort_Id = 0
select @form_id_Loan_Report = Form_id,@Sort_Id = sort_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Loan LIC Reports' and Page_Flag in  ('AR','IP')

set @Sor_id_Check =0
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Monthly Loan Payment' and Page_Flag in  ('AR','IP') )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Loan_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Monthly Loan Payment'
		where Form_Name = 'Monthly Loan Payment' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Monthly Loan Payment' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Loan_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Monthly Loan Payment'
		where Form_Name = 'Monthly Loan Payment' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Loan Approval' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Loan_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Loan Approval'
		where Form_Name = 'Loan Approval' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Loan Number' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Loan_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Loan Number'
		where Form_Name = 'Loan Number' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Loan Statement Report' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Loan_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Loan Statement Report'
		where Form_Name = 'Loan Statement Report' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Reim/Claim Approval' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Loan_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Reimbursement Approval'
		where Form_Name = 'Reim/Claim Approval' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Reim/Claim Statement' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Loan_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Reimbursement Statement'
		where Form_Name = 'Reim/Claim Statement' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM  WITH (NOLOCK) where  Form_name = 'Reim/Claim Balance' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Loan_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Reimbursement Balance'
		where Form_Name = 'Reim/Claim Balance' and Page_Flag in  ('AR','IP')
	end
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Claim Detail Report' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Loan_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Claim Details'
		where Form_Name = 'Claim Detail Report' and Page_Flag in  ('AR','IP')
	end

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Interest Subsidy Statement' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Loan_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Interest Subsidy Statement'
		where Form_Name = 'Interest Subsidy Statement' and Page_Flag in  ('AR','IP')
	end
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Pending Loan Detail' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Loan_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Pending Loan Detail'
		where Form_Name = 'Pending Loan Detail' and Page_Flag in  ('AR','IP')
	end
	
	set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Pending Loan Detail' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Loan_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Pending Loan Detail'
		where Form_Name = 'Pending Loan Detail' and Page_Flag in  ('AR','IP')
	end

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Loan Application Form' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Loan_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Loan Application Form'
		where Form_Name = 'Loan Application Form' and Page_Flag in  ('AR','IP')
	end
		
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM  WITH (NOLOCK) where  Form_name = 'Asset Allocation Report' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Loan_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Asset Allocation Report'
		where Form_Name = 'Asset Allocation Report' and Page_Flag in  ('AR','IP')
	end
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Asset Installment Statement' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Loan_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Asset Installment Statement'
		where Form_Name = 'Asset Installment Statement' and Page_Flag in  ('AR','IP')
	end
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Pending Asset Installment Details' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Loan_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Pending Asset Installment Details'
		where Form_Name = 'Pending Asset Installment Details' and Page_Flag in  ('AR','IP')
	end
-- Loan Report End--


-- Salary Report Start --
Declare @form_id_Salary_Report as Numeric(18,0)
set @form_id_Emp_Report = 0
--set @Sort_Id = @Sort_Id + 20
set @Sort_Id = 0
select @form_id_Salary_Report = Form_id,@Sort_Id = sort_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Salary Reports' and Page_Flag in  ('AR','IP')

set @Sor_id_Check =0
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Salary Slip' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Salary_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Salary Slip'
		where Form_Name = 'Salary Slip' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Salary Slip Weekly Basis' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Salary_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Salary Slip Weekly Basis'
		where Form_Name = 'Salary Slip Weekly Basis' and Page_Flag in  ('AR','IP')
	end



set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Salary Register Daily Basis' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Salary_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Salary Register Daily Basis'
		where Form_Name = 'Salary Register Daily Basis' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Salary Register(Allo/Ded)' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Salary_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Salary Register(Allo/Ded)'
		where Form_Name = 'Salary Register(Allo/Ded)' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Register With Settlement' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Salary_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Register With Settlement'
		where Form_Name = 'Register With Settlement' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Allowance/Deduction Report' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Salary_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Allowance/Deduction Report'
		where Form_Name = 'Allowance/Deduction Report' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Yearly Salary' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Salary_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Yearly Salary'
		where Form_Name = 'Yearly Salary' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Yearly Advance' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Salary_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Yearly Advance'
		where Form_Name = 'Yearly Advance' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Yearly Attendance' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Salary_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Yearly Attendance'
		where Form_Name = 'Yearly Attendance' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Pending Advance' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Salary_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Pending Advance'
		where Form_Name = 'Pending Advance' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Overtime' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Salary_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Employee Overtime'
		where Form_Name = 'Employee Overtime' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Daily Overtime' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Salary_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Employee Daily Overtime'
		where Form_Name = 'Employee Daily Overtime' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Bank Statement' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Salary_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Bank Statement'
		where Form_Name = 'Bank Statement' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Allowance Export' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Salary_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Allowance Export'
		where Form_Name = 'Allowance Export' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Reimbursement Slip' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Salary_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Reimbursement Slip'
		where Form_Name = 'Reimbursement Slip' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Allowance Status' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Salary_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Allowance Status'
		where Form_Name = 'Allowance Status' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Night Halt Slip' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Salary_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Night Halt Slip'
		where Form_Name = 'Night Halt Slip' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Salary Certificate' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Salary_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Salary Certificate'
		where Form_Name = 'Salary Certificate' and Page_Flag in  ('AR','IP')
	end
	
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Salary Summary Bankwise' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Salary_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Salary Summary Bankwise'
		where Form_Name = 'Salary Summary Bankwise' and Page_Flag in  ('AR','IP')
	end

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Allowance/Deduction Revised Report' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Salary_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Allowance/Deduction Revised Report'
		where Form_Name = 'Allowance/Deduction Revised Report' and Page_Flag in  ('AR','IP')
	end
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'CPS Balance Report' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Salary_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='CPS Balance Report'
		where Form_Name = 'CPS Balance Report' and Page_Flag in  ('AR','IP')
	end

update T0000_DEFAULT_FORM set Is_Active_For_menu=1 where  Form_name = 'Payment Slip' and Page_Flag in  ('AR','IP')
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Payment Slip' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Salary_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Payment Slip'
		where Form_Name = 'Payment Slip' and Page_Flag in  ('AR','IP')
	end
-- Salary Report End--

-- PF Report Start --
Declare @form_id_Pf_Report as Numeric(18,0)
set @form_id_Emp_Report = 0
--set @Sort_Id = @Sort_Id + 20
set @Sort_Id = 0
select @form_id_Pf_Report = Form_id,@Sort_Id = sort_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'PF Reports' and Page_Flag in  ('AR','IP')

set @Sor_id_Check =0
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'PF Statement' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Pf_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='PF Statement'
		where Form_Name = 'PF Statement' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'PF Statement Sett' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Pf_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='PF Statement Sett'
		where Form_Name = 'PF Statement Sett' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'PF Challan' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Pf_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='PF Challan'
		where Form_Name = 'PF Challan' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK)where  Form_name = 'PF Challan Sett' and Page_Flag in  ('AR','IP') )
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Pf_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='PF Challan Sett'
		where Form_Name = 'PF Challan Sett' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Form2' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Pf_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Form2'
		where Form_Name = 'Form2' and Page_Flag in  ('AR','IP')
	end
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Form05' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Pf_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Form 05'
		where Form_Name = 'Form05' and Page_Flag in  ('AR','IP')
	end

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Form10' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Pf_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Form10'
		where Form_Name = 'Form10' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Form12A' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Pf_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Form12A'
		where Form_Name = 'Form12A' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Form3A-Yearly' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Pf_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Form3A-Yearly'
		where Form_Name = 'Form3A-Yearly' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Form6A-Yearly' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Pf_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Form6A-Yearly'
		where Form_Name = 'Form6A-Yearly' and Page_Flag in  ('AR','IP')
	end

--update T0000_DEFAULT_FORM set Sort_ID=181 where  Form_name = 'Form 13 (Revised)' and Page_Flag in  ('AR','IP')
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Form13 (Revised)' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Pf_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Form13 (Revised)'
		where Form_Name = 'Form13 (Revised)' and Page_Flag in  ('AR','IP')
	end

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'PF Employer Contribution' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Pf_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='PF Employer Contribution'
		where Form_Name = 'PF Employer Contribution' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'PF Statement for Inspection' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Pf_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='PF Statement for Inspection'
		where Form_Name = 'PF Statement for Inspection' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Pension Scheme-10C' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Pf_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Employee Pension Scheme-10C'
		where Form_Name = 'Employee Pension Scheme-10C' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Pension Scheme-10D' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Pf_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Employee Pension Scheme-10D'
		where Form_Name = 'Employee Pension Scheme-10D' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'PF FORM 11' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Pf_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='PF FORM 11'
		where Form_Name = 'PF FORM 11' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'PF FORM 19' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Pf_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='PF FORM 19'
		where Form_Name = 'PF FORM 19' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'PF FORM 20' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Pf_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='PF FORM 20'
		where Form_Name = 'PF FORM 20' and Page_Flag in  ('AR','IP')
	end
-- PF Report End--

-- ESIC Report Start --
Declare @form_id_Esic_Report as Numeric(18,0)
set @form_id_Emp_Report = 0
--set @Sort_Id = @Sort_Id + 20
set @Sort_Id = 0
select @form_id_Esic_Report = Form_id,@Sort_Id = sort_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'ESIC Reports' and Page_Flag in  ('AR','IP')

set @Sor_id_Check =0
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'ESIC Statement' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Esic_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='ESIC Statement'
		where Form_Name = 'ESIC Statement' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'ESIC Challan' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Esic_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='ESIC Challan'
		where Form_Name = 'ESIC Challan' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Form 1(Declaration)' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Esic_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Form 1(Declaration)'
		where Form_Name = 'Form 1(Declaration)' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Form 3' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Esic_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Form 3'
		where Form_Name = 'Form 3' and Page_Flag in  ('AR','IP')
	end
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Form 5' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Esic_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Form 5'
		where Form_Name = 'Form 5' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Form 6' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Esic_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Form 6'
		where Form_Name = 'Form 6' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Form 7' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Esic_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Form 7'
		where Form_Name = 'Form 7' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Form 37' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Esic_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Form 37'
		where Form_Name = 'Form 37' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'ESIC Challan Sett' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Esic_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='ESIC Challan Sett'
		where Form_Name = 'ESIC Challan Sett' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'ESIC Statement Sett' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Esic_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='ESIC Statement Sett'
		where Form_Name = 'ESIC Statement Sett' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'ESIC Employer' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Esic_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='ESIC Employer'
		where Form_Name = 'ESIC Employer' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Esic Components' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Esic_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='ESIC Components'
		where Form_Name = 'Esic Components' and Page_Flag in  ('AR','IP')
	end

-- ESIC Report End--

-- PT Report Start --
Declare @form_id_Pt_Report as Numeric(18,0)
set @form_id_Emp_Report = 0
--set @Sort_Id = @Sort_Id + 20
set @Sort_Id = 0
select @form_id_Pt_Report = Form_id,@Sort_Id = sort_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'PT Reports' and Page_Flag in  ('AR','IP')

set @Sor_id_Check =0
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'PT Challan' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Pt_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='PT Challan'
		where Form_Name = 'PT Challan' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'PT Statement' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Pt_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='PT Statement'
		where Form_Name = 'PT Statement' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'PT Statement Sett' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Pt_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='PT Statement Sett'
		where Form_Name = 'PT Statement Sett' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'PT Form5' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Pt_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='PT Form5'
		where Form_Name = 'PT Form5' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'PT Form5A' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Pt_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='PT Form5A'
		where Form_Name = 'PT Form5A' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'LWF Statement' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Pt_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='LWF Statement'
		where Form_Name = 'LWF Statement' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'LWF Statement FORM A' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Pt_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='LWF Statement FORM A'
		where Form_Name = 'LWF Statement FORM A' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Form 9-A' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Pt_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Form 9-A'
		where Form_Name = 'Form 9-A' and Page_Flag in  ('AR','IP')
	end
-- PT Report End--

-- Letters Report Start --
Declare @form_id_Letters_Report as Numeric(18,0)
set @form_id_Emp_Report = 0
--set @Sort_Id = @Sort_Id + 20
set @Sort_Id = 0
select @form_id_Letters_Report = Form_id,@Sort_Id = sort_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Letters' and Page_Flag in  ('AR','IP')

set @Sor_id_Check =0
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Offer Letter' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Letters_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Offer Letter'
		where Form_Name = 'Offer Letter' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Appoint Letter' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Letters_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Appoint Letter'
		where Form_Name = 'Appoint Letter' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK)where  Form_name = 'Resignation Letter' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Letters_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Resignation Letter'
		where Form_Name = 'Resignation Letter' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Joining Letter' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Letters_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Joining Letter'
		where Form_Name = 'Joining Letter' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Confirmation Letter' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Letters_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Confirmation Letter'
		where Form_Name = 'Confirmation Letter' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Experience Letter' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Letters_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Experience Letter'
		where Form_Name = 'Experience Letter' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Reliever Letter' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Letters_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Reliever Letter'
		where Form_Name = 'Reliever Letter' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Termination Letter' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Letters_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Termination Letter'
		where Form_Name = 'Termination Letter' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'F & F Letter' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Letters_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='F & F Letter'
		where Form_Name = 'F & F Letter' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Increment Letter' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Letters_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Increment Letter'
		where Form_Name = 'Increment Letter' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Forwarding Letter' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Letters_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Forwarding Letter'
		where Form_Name = 'Forwarding Letter' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Transfer Letter' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Letters_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Transfer Letter'
		where Form_Name = 'Transfer Letter' and Page_Flag in  ('AR','IP')
	end
-- Letter Report End--

-- Other Report Start --
Declare @form_id_other_Report as Numeric(18,0)
set @form_id_Emp_Report = 0
--set @Sort_Id = @Sort_Id + 20
set @Sort_Id = 0
update T0000_DEFAULT_FORM set Sort_ID=188 where  Form_name = 'Other Reports' and Page_Flag in  ('AR','IP')
select @form_id_other_Report = Form_id,@Sort_Id = sort_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Other Reports' and Page_Flag in  ('AR','IP')

set @Sor_id_Check =0
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Leave Encashment paid' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_other_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Leave Encashment paid'
		where Form_Name = 'Leave Encashment paid' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Fitness Certificate' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_other_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Fitness Certificate'
		where Form_Name = 'Fitness Certificate' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Fitness Certificate' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_other_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Fitness Certificate'
		where Form_Name = 'Fitness Certificate' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Health Register-Form32' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_other_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Health Register-Form32'
		where Form_Name = 'Health Register-Form32' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Adult Worker Register' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_other_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Adult Worker Register'
		where Form_Name = 'Adult Worker Register' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Exit Interview' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_other_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Exit Interview'
		where Form_Name = 'Exit Interview' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Clearance Form' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_other_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Clearance Form'
		where Form_Name = 'Clearance Form' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Form ER 1' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_other_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Form ER 1'
		where Form_Name = 'Form ER 1' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Form ER 2' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_other_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Form ER 2'
		where Form_Name = 'Form ER 2' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Consolidated Annual Return' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_other_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Consolidated Annual Return'
		where Form_Name = 'Consolidated Annual Return' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Form-25' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_other_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Form-25'
		where Form_Name = 'Form-25' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Holiday Details' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_other_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Holiday Details'
		where Form_Name = 'Holiday Details' and Page_Flag in  ('AR','IP') 
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Travel Detail' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_other_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Travel Detail'
		where Form_Name = 'Travel Detail' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Travel Settlement' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_other_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Travel Settlement'
		where Form_Name = 'Travel Settlement' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Travel Statement' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_other_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Travel Statement'
		where Form_Name = 'Travel Statement' and Page_Flag in  ('AR','IP')
	end

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Travel Settlement Status' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_other_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Travel Settlement Status'
		where Form_Name = 'Travel Settlement Status' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Probation' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_other_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Employee Probation'
		where Form_Name = 'Employee Probation' and Page_Flag in  ('AR','IP')
	end
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Insurance1 ' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_other_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Employee Insurance1'
		where Form_Name = 'Employee Insurance1' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Leave Allowance Detail' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_other_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Leave Allowance Detail'
		where Form_Name = 'Leave Allowance Detail' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Memo Report' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_other_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Memo Report'
		where Form_Name = 'Memo Report' and Page_Flag in  ('AR','IP')
	end
	
--Commented By Mukti 03102015(start)
--set @Sor_id_Check = @Sor_id_Check + 1
--if exists (select Form_id from T0000_DEFAULT_FORM where  Form_name = 'Asset Allocation Report' and Page_Flag in  ('AR','IP'))
--	begin
--		update T0000_DEFAULT_FORM 
--		set Under_Form_ID = @form_id_other_Report,
--		Sort_ID=@Sort_Id,
--		Sort_Id_Check=@Sor_id_Check,
--		alias='Asset Allocation Report'
--		where Form_Name = 'Asset Allocation Report' and Page_Flag in  ('AR','IP')
--	end
--Commented By Mukti 03102015(end)

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Labour Hours Report' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_other_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Labour Hours Report'
		where Form_Name = 'Labour Hours Report' and Page_Flag in  ('AR','IP')
	end

--Commented By Mukti 03102015(start)
--set @Sor_id_Check = @Sor_id_Check + 1
--if exists (select Form_id from T0000_DEFAULT_FORM where  Form_name = 'Asset Installment Statement' and Page_Flag in  ('AR','IP'))
--	begin
--		update T0000_DEFAULT_FORM 
--		set Under_Form_ID = @form_id_other_Report,
--		Sort_ID=@Sort_Id,
--		Sort_Id_Check=@Sor_id_Check,
--		alias='Asset Installment Statement'
--		where Form_Name = 'Asset Installment Statement' and Page_Flag in  ('AR','IP')
--	end
--Commented By Mukti 03102015(end)

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Payment Process Report' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_other_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Payment Process Report'
		where Form_Name = 'Payment Process Report' and Page_Flag in  ('AR','IP')
	end

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Canteen Deduction' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_other_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Canteen Deduction'
		where Form_Name = 'Canteen Deduction' and Page_Flag in  ('AR','IP')
	end
	
-- Other Report End--

-- TAX Report Start --
Declare @form_id_Tax_Report as Numeric(18,0)
set @form_id_Emp_Report = 0
--set @Sort_Id = @Sort_Id + 20
set @Sort_Id = 0
select @form_id_Tax_Report = Form_id,@Sort_Id = sort_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TAX Reports' and Page_Flag in  ('AR','IP')

set @Sor_id_Check =0
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Income Tax Declaration' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Tax_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Income Tax Declaration'
		where Form_Name = 'Income Tax Declaration' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Tax Computation' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Tax_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Tax Computation'
		where Form_Name = 'Tax Computation' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Form -16(IT)' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Tax_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Form -16(IT)'
		where Form_Name = 'Form -16(IT)' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Tax Report' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Tax_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Employee Tax Report'
		where Form_Name = 'Employee Tax Report' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'TDS Challan' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Tax_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='TDS Challan'
		where Form_Name = 'TDS Challan' and Page_Flag in  ('AR','IP')
	end
-- TAX Report End--

-- Gratuity Report Start --
Declare @form_id_Gratuity_Report as Numeric(18,0)
set @form_id_Emp_Report = 0
--set @Sort_Id = @Sort_Id + 20
set @Sort_Id = 0
update T0000_DEFAULT_FORM set Is_Active_For_menu =0 where  Form_name = 'Gratuity Report' and Page_Flag in  ('AR','IP')

select @form_id_Gratuity_Report = Form_id,@Sort_Id = sort_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Gratuity Bonus HRIS' and Page_Flag in  ('AR','IP')

set @Sor_id_Check =0
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Bonus Statement' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Gratuity_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Bonus Statement'
		where Form_Name = 'Bonus Statement' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Bonus(Form C)' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Gratuity_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Bonus(Form C)'
		where Form_Name = 'Bonus(Form C)' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Status' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Gratuity_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Employee Status'
		where Form_Name = 'Employee Status' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Strength' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Gratuity_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Employee Strength'
		where Form_Name = 'Employee Strength' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Variance Report' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Gratuity_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Employee Variance Report'
		where Form_Name = 'Employee Variance Report' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Salary Variance Report' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Gratuity_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Salary Variance Report'
		where Form_Name = 'Salary Variance Report' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Gratuity' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Gratuity_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Gratuity'
		where Form_Name = 'Gratuity' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Gratuity Statement' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Gratuity_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Gratuity Statement'
		where Form_Name = 'Gratuity Statement' and Page_Flag in  ('AR','IP')
	end
-- Gratuity Report End--

-- HRMS Report Start --
Declare @form_id_Hrms_Report as Numeric(18,0)
set @form_id_Emp_Report = 0
--set @Sort_Id = @Sort_Id + 20
set @Sort_Id = 0
select @form_id_Hrms_Report = Form_id,@Sort_Id = sort_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'HRMS Reports' and Page_Flag in  ('AR','IP')

set @Sor_id_Check =0
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Hrms Customize Report' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Hrms_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Hrms Customize Report'
		where Form_Name = 'Hrms Customize Report' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Self Assessment' and Page_Flag in  ('AR','IP')) 
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Hrms_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Employee Self Assessment'
		where Form_Name = 'Employee Self Assessment' and Page_Flag in  ('AR','IP')
	end


set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Performance Assessment Form' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Hrms_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Performance Assessment Form'
		where Form_Name = 'Performance Assessment Form' and Page_Flag in  ('AR','IP')
	end
	
	set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Training InOut Summary' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Hrms_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Training InOut Summary'
		where Form_Name = 'Training InOut Summary' and Page_Flag in  ('AR','IP')
	end
	
	set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Training Calender Year' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Hrms_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Training Calender Year'
		where Form_Name = 'Training Calender Year' and Page_Flag in  ('AR','IP')
	end	

	set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Training Inventory' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Hrms_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Training Inventory'
		where Form_Name = 'Training Inventory' and Page_Flag in  ('AR','IP')
	end	
		
	set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Training Record' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Hrms_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Training Record'
		where Form_Name = 'Training Record' and Page_Flag in  ('AR','IP')
	end		
	
	set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'On Job Training Record' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Hrms_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='On Job Training Record'
		where Form_Name = 'On Job Training Record' and Page_Flag in  ('AR','IP')
	end		
	
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Training Feedback' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Hrms_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Training Feedback'
		where Form_Name = 'Training Feedback' and Page_Flag in  ('AR','IP')
	end			

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Training Induction Feedback' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Hrms_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Training Induction Feedback'
		where Form_Name = 'Training Induction Feedback' and Page_Flag in  ('AR','IP')
	end		
-- HRMS Report End--

 --Timesheet Report Start --
Declare @form_id_Timesheet_Report as Numeric(18,0)
set @form_id_Timesheet_Report = 0
--set @Sort_Id = @Sort_Id + 20
set @Sort_Id = 0
select @form_id_Timesheet_Report = Form_id,@Sort_Id = sort_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Timesheet Reports' and Page_Flag in  ('AR','IP')

set @Sor_id_Check =0
set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Employee Costing Report' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Timesheet_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Employee Costing Report'
		where Form_Name = 'Employee Costing Report' and Page_Flag in  ('AR','IP')
	end



set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Project Cost' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Timesheet_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Project Cost'
		where Form_Name = 'Project Cost' and Page_Flag in  ('AR','IP')
	end



set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Project Overhead Cost' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Timesheet_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Project Overhead Cost'
		where Form_Name = 'Project Overhead Cost' and Page_Flag in  ('AR','IP')
	end
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Collection Detail' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Timesheet_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Collection Detail'
		where Form_Name = 'Collection Detail' and Page_Flag in  ('AR','IP')
	end

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Manager Collection Details' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Timesheet_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Manager Collection Details'
		where Form_Name = 'Manager Collection Details' and Page_Flag in  ('AR','IP')
	end	
	

set @Sor_id_Check = @Sor_id_Check + 1
if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Timesheet Details Reports' and Page_Flag in  ('AR','IP'))
	begin
		update T0000_DEFAULT_FORM 
		set Under_Form_ID = @form_id_Timesheet_Report,
		Sort_ID=@Sort_Id,
		Sort_Id_Check=@Sor_id_Check,
		alias='Timesheet Details Reports'
		where Form_Name = 'Timesheet Details Reports' and Page_Flag in  ('AR','IP')
	end
	
 --Timesheet Report End--

--Added By Mukti(start)14102015
 if exists (select Form_id from T0000_DEFAULT_FORM WITH (NOLOCK) where  Form_name = 'Asset Position' and Page_Flag in  ('AR','IP'))
	begin
		delete from T0000_DEFAULT_FORM where Form_name = 'Asset Position' and Page_Flag in  ('AR','IP')
	end
--Added By Mukti(start)14102015


---- Added By Prakash Patel 01032016 ----------------
	---- Transport Report Start --------

	DECLARE @Form_ID_Transport_Report Numeric(18,0)
	SET @Form_ID_Transport_Report= 0
	SET @Sort_Id = 0

	SELECT @Form_ID_Transport_Report = Form_ID,@Sort_Id = Sort_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_Name = 'Transport Reports' AND Page_Flag in  ('AR','IP')

	SET @Sor_id_Check =0
	SET @Sor_id_Check = @Sor_id_Check + 1
	IF EXISTS(SELECT Form_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_Name = 'Route Wise Employee Report' AND Page_Flag in  ('AR','IP'))
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET Under_Form_ID = @Form_ID_Transport_Report,Sort_ID = @Sort_Id,Sort_Id_Check = @Sor_id_Check,Alias = 'Route Wise Employee Report'
			WHERE Form_Name = 'Route Wise Employee Report' AND Page_Flag in  ('AR','IP')
		END
	SET @Sor_id_Check = @Sor_id_Check + 1
	IF EXISTS(SELECT Form_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_Name = 'Section Wise Transportation Report' AND Page_Flag in  ('AR','IP'))
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET Under_Form_ID = @Form_ID_Transport_Report,Sort_ID = @Sort_Id,Sort_Id_Check = @Sor_id_Check,Alias = 'Section Wise Transportation Report'
			WHERE Form_Name = 'Section Wise Transportation Report' AND Page_Flag in  ('AR','IP')
		END
	SET @Sor_id_Check = @Sor_id_Check + 1
	IF EXISTS(SELECT Form_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_Name = 'Route Wise Employee Related Report' AND Page_Flag in  ('AR','IP'))
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET Under_Form_ID = @Form_ID_Transport_Report,Sort_ID = @Sort_Id,Sort_Id_Check = @Sor_id_Check,Alias = 'Route Wise Employee Related Report'
			WHERE Form_Name = 'Route Wise Employee Related Report' AND Page_Flag in  ('AR','IP')
		END
	SET @Sor_id_Check = @Sor_id_Check + 1
	IF EXISTS(SELECT Form_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_Name = 'Route Details Report' AND Page_Flag in  ('AR','IP'))
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET Under_Form_ID = @Form_ID_Transport_Report,Sort_ID = @Sort_Id,Sort_Id_Check = @Sor_id_Check,Alias = 'Route Details Report'
			WHERE Form_Name = 'Route Details Report' AND Page_Flag in  ('AR','IP')
		END
	SET @Sor_id_Check = @Sor_id_Check + 1
	IF EXISTS(SELECT Form_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_Name = 'Private Vehicle Driver And Route Details' AND Page_Flag in  ('AR','IP'))
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET Under_Form_ID = @Form_ID_Transport_Report,Sort_ID = @Sort_Id,Sort_Id_Check = @Sor_id_Check,Alias = 'Private Vehicle Driver & Route Details'
			WHERE Form_Name = 'Private Vehicle Driver And Route Details' AND Page_Flag in  ('AR','IP')
		END
	SET @Sor_id_Check = @Sor_id_Check + 1
	IF EXISTS(SELECT Form_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_Name = 'Staff Bus Driver And Route Details' AND Page_Flag in  ('AR','IP'))
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET Under_Form_ID = @Form_ID_Transport_Report,Sort_ID = @Sort_Id,Sort_Id_Check = @Sor_id_Check,Alias = 'Staff Bus Driver & Route Details'
			WHERE Form_Name = 'Staff Bus Driver And Route Details' AND Page_Flag in  ('AR','IP')
		END
	SET @Sor_id_Check = @Sor_id_Check + 1
	IF EXISTS(SELECT Form_ID FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE Form_Name = 'Route Wise Pick Station And Fair' AND Page_Flag in  ('AR','IP'))
		BEGIN
			UPDATE T0000_DEFAULT_FORM SET Under_Form_ID = @Form_ID_Transport_Report,Sort_ID = @Sort_Id,Sort_Id_Check = @Sor_id_Check,Alias = 'Route Wise Pick Station & Fair'
			WHERE Form_Name = 'Route Wise Pick Station And Fair' AND Page_Flag in  ('AR','IP')
		END

	---- Transport Report End ----------

End
