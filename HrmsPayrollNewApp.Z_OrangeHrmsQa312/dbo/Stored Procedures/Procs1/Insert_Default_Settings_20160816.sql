

---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Insert_Default_Settings_20160816]
	@Cmp_ID		numeric
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
BEGIN
	/*
	SET NOCOUNT ON;
	declare @setting_id_max numeric
	--- T0040_SETTING
	
	DECLARE @SETTING_NAME VARCHAR(512);
	DECLARE @ALIAS VARCHAR(512);
	DECLARE @TOOLTIP VARCHAR(MAX);
	DECLARE @GROUP_NAME VARCHAR(128);
	
 ----------------------setting start-----------------------------		
	--if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='IS_YEARLY_CTC')
	--	begin
	--		select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
	--		Insert into T0040_SETTING 
	--		values(@setting_id_max,@Cmp_ID,'IS_YEARLY_CTC',0
	--		,'Active option  for make yearly Base CTC Structure for employee master salary entry','Salary Settings','IS_YEARLY_CTC',NULL)	
	--	end	
	--Else
	--	Begin
	--		select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID and Setting_Name='IS_YEARLY_CTC')
	--		Update T0040_SETTING Set Comment = 'Active option  for make yearly Base CTC Structure for employee master salary entry', Group_By = 'Salary Settings' 
	--			 ,alias ='IS_YEARLY_CTC' Where Setting_ID = @setting_id_max
	--	End
		
		
	
    if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='InActive User After Days')
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING 
			values(@setting_id_max,@Cmp_ID,'InActive User After Days',0
			,'If there is no any attendance activity found within a set days of user then this option will make user as Inactive for login','Other Settings'
			,'InActive User After Days',NULL)
		end
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='InActive User After Days')
			Update T0040_SETTING Set Comment = 'If there is no any attendance activity found within a set days of user then this option will make user as Inactive for login', Group_By = 'Other Settings' 
			,alias ='InActive User After Days'  Where Setting_ID = @setting_id_max
		End
		
		
		
 --   if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='IT Declaration Lock After')
	--	begin
	--		select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
	--		Insert into T0040_SETTING values(@setting_id_max,@Cmp_ID,'IT Declaration Lock After',''
	--		,'From given date it will lock IT Declaration online form for user')
	--	end
	--Else
	--	Begin
	--		select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
	--		and Setting_Name='IT Declaration Lock After')
	--		Update T0040_SETTING Set Comment = 'From given date it will lock IT Declaration online form for user' Where Setting_ID = @setting_id_max
	--	End
		
		
	if exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='IT Declaration Lock After')
	begin
		delete from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='IT Declaration Lock After'
	end
	
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='AX')
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING 
			values(@setting_id_max,@Cmp_ID,'AX',0,'Export salary data in excel file for Dynamic Microsoft ERP','Other Settings'
			,'AX',NULL)
		end
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='AX')
			Update T0040_SETTING Set Comment = 'Export salary data in excel file for Dynamic Microsoft ERP', Group_By = 'Other Settings'  
			,alias ='AX' Where Setting_ID = @setting_id_max
		End
		
		
		-- Added by rohit For 
		if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Min. basic rules applicable')
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING 
			 values(@setting_id_max,@Cmp_ID,'Min. basic rules applicable',0
			,'Active option for set employee’s Min. Basic rule according to government minimum wages','Employee Settings'
			,'Min. basic rules applicable',NULL)
		end
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Min. basic rules applicable')
			Update T0040_SETTING Set Comment = 'Active option for set employee’s Min. Basic rule according to government minimum wages',Group_By = 'Employee Settings' 
			,alias ='Min. basic rules applicable'  Where Setting_ID = @setting_id_max
		End
		
		
		
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Show Left Employee for Salary')
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING 
			values(@setting_id_max,@Cmp_ID,'Show Left Employee for Salary',0
			,'Show left employee at the time of salary generation for generate salary for the month','Salary Settings','Show Left Employee for Salary',NULL)
		end
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Show Left Employee for Salary')
			Update T0040_SETTING Set Comment = 'Show left employee at the time of salary generation for generate salary for the month',Group_By = 'Salary Settings'
			,alias ='Show Left Employee for Salary' Where Setting_ID = @setting_id_max
		End
		
		
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Add initial in employee full name') --Hasmukh change for Initial add in full name or not 22022013
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING 
			values(@setting_id_max,@Cmp_ID,'Add initial in employee full name','1'
			,'Active option for add initial(Mr., Mrs.) in employee’s full name','Employee Settings','Add initial in employee full name',NULL)
		end	
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Add initial in employee full name')
			Update T0040_SETTING Set Comment = 'Active option for add initial(Mr., Mrs.) in employee’s full name', Group_By = 'Employee Settings' 
			,alias ='Add initial in employee full name' Where Setting_ID = @setting_id_max
		End
		
		
		
	-- Added By Hiral 11 Apr,2013 (Start)
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Send Email in Bulk Leave Approval')
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING 
			values(@setting_id_max,@Cmp_ID,'Send Email in Bulk Leave Approval','0'
			,'Active option for send email at the time of bulk leave approval for multiple employees','Leave Settings','Send Email in Bulk Leave Approval',NULL)
		end
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Send Email in Bulk Leave Approval')
			Update T0040_SETTING Set Comment = 'Active option for send email at the time of bulk leave approval for multiple employees',Group_By = 'Leave Settings' 
			,alias ='Send Email in Bulk Leave Approval' Where Setting_ID = @setting_id_max
		End
		
	--Added by Nilesh Patel on 30012015
	
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Employee Retirement Age')
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING 
			values(@setting_id_max,@Cmp_ID,'Employee Retirement Age',58
			,'Set Employess Retirement Age(Retirement age 58 or 60)','Employee Settings','Employee Retirement Age',NULL)
		end	
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID and Setting_Name='Employee Retirement Age')
			Update T0040_SETTING Set alias='Employee Retirement Age' Where Setting_ID = @setting_id_max
		End
	
	--Added by Nilesh Patel on 13052015 -start
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Enable Miss punch SMS')
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING 
			values(@setting_id_max,@Cmp_ID,'Enable Miss punch SMS',0
			,'Set 0 for Inactive and 1 For Active','SMS Settings','Enable Miss punch SMS',NULL)
		end
	else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID and Setting_Name='Enable Miss punch SMS')
			Update T0040_SETTING Set alias='Enable Miss punch SMS' Where Setting_ID = @setting_id_max
		End
	--Added by Nilesh Patel on 13052015 -End	
	
	--Added by Nilesh Patel on 02032015 -start
	if not exists(SELECT 1 from T0040_SETTING where Cmp_ID = @cmp_id AND Setting_Name='Send Remainder mail of Increment')
		BEGIN
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING 
			values(@setting_id_max,@Cmp_ID,'Send Remainder mail of Increment',1
			,'Set days for send remainder mail of increment','Employee Settings','Send Remainder mail of Increment',NULL)
		End 
	else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID and Setting_Name='Send Remainder mail of Increment')
			Update T0040_SETTING Set alias='Send Remainder mail of Increment' Where Setting_ID = @setting_id_max
		End
	--Added by Nilesh Patel on 02032015 -End	
	
	--Added by Nilesh Patel on 02032015 -start
	if not exists(SELECT 1 from T0040_SETTING where Cmp_ID = @cmp_id AND Setting_Name='Present Compulsory Extra Days Deduction(Holiday Master)')
		BEGIN
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING 
			values(@setting_id_max,@Cmp_ID,'Present Compulsory Extra Days Deduction(Holiday Master)',0
			,'Set Extra Days Deduction When Present Compulsory','Salary Settings','Present Compulsory Extra Days Deduction(Holiday Master)',NULL)
		End
	else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID and Setting_Name='Present Compulsory Extra Days Deduction(Holiday Master)')
			Update T0040_SETTING Set alias='Present Compulsory Extra Days Deduction(Holiday Master)' Where Setting_ID = @setting_id_max
		End 
	--Added by Nilesh Patel on 02032015 -End
	
	--Added by Nilesh Patel on 11032015 -start
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Calculate Salary Base on Production Details')
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING
			values(@setting_id_max,@Cmp_ID,'Calculate Salary Base on Production Details',0
			,'Set 0 for Inactive and 1 For Active','Salary Settings','Calculate Salary Base on Production Details',NULL)	
		end	
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Calculate Salary Base on Production Details')
			Update T0040_SETTING Set Comment = 'Set 0 for Inactive and 1 For Active',Group_By = 'Salary Settings' 
			,Alias='Calculate Salary Base on Production Details' Where Setting_ID = @setting_id_max
		End
	--Added by Nilesh Patel on 11032015 -End
	
	--Added by Nilesh Patel on 11032015 -Start
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Send Email through SQL Job')
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING 
			values(@setting_id_max,@Cmp_ID,'Send Email through SQL Job',0
			,'Set 1 For Send Email through SQL Job','Email Settings','Send Email through SQL Job',NULL)
		end
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Send Email through SQL Job')
			Update T0040_SETTING set Alias='Send Email through SQL Job' Where Setting_ID = @setting_id_max
		End
	--Added by Nilesh Patel on 11032015 -End	
		
	-- Added By Hiral 11 Apr,2013 (End)
	
	-- Commented by rohit on 12112013
	---- Added by rohit For Showing New Joining Detail on home page on 22042013
	--	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Show New Joining Details(ESS)')
	--	begin
	--		select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
	--		Insert into T0040_SETTING values(@setting_id_max,@Cmp_ID,'Show New Joining Details(ESS)',1)
	--	end
	---- Ended by rohit For Showing New Joining Detail on home page on 22042013
	if exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Show New Joining Details(ESS)')
	begin
		delete from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Show New Joining Details(ESS)'
	end
	-- Ended by rohit on 12112013
	
	-- Added By Hiral 04 June,2013 (Start)
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Employee Lock After First Salary')
		begin
			select @setting_id_max = isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING 
			values(@setting_id_max,@Cmp_ID,'Employee Lock After First Salary','1'
			,'Active option for Lock employee’s salary & other details after first salary','Employee Settings'
			,'Employee Lock After First Salary',NULL)
		end
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Employee Lock After First Salary')
			Update T0040_SETTING Set Comment = 'Active option for Lock employee’s salary & other details after first salary', Group_By = 'Employee Settings' 
			,Alias='Employee Lock After First Salary' Where Setting_ID = @setting_id_max
		End
		
	-- Added By Hiral 04 June,2013 (End)
	
	-- Commented and added by rohit on 12112013
		----Start Add By Paras  12 June ,2013
		--	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Show New Policy Document(ESS)')
		--	begin
		--		select @setting_id_max = isnull(max(setting_id),0) + 1 from T0040_SETTING
		--		Insert into T0040_SETTING values(@setting_id_max,@Cmp_ID,'Show New Policy Document(ESS)','1')
		--	end
		----End Add By Paras  12 June ,2013
		if exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Show New Policy Document(ESS)')
		begin
			delete from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Show New Policy Document(ESS)'
		end
		
	----Start Add By Paras  12 June ,2013
	--if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Show Working Hour Graph (ESS)')
	--	begin
	--		select @setting_id_max = isnull(max(setting_id),0) + 1 from T0040_SETTING
	--		Insert into T0040_SETTING values(@setting_id_max,@Cmp_ID,'Show Working Hour Graph (ESS)','1')
	--	end
	----End Add By Paras  12 June ,2013
	if exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Show Working Hour Graph (ESS)')
	begin
		delete from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Show Working Hour Graph (ESS)'
	end
	-- ended by rohit on 12112013
	
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Salary Cycle Employee Wise')
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING 
			values(@setting_id_max,@Cmp_ID,'Salary Cycle Employee Wise',0
			,'Active option for make salary cycle employee wise','Salary Settings','Salary Cycle Employee Wise',NULL)	
		end	
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Salary Cycle Employee Wise')
			Update T0040_SETTING Set Comment = 'Active option for make salary cycle employee wise',Group_By = 'Salary Settings' 
			,Alias='Salary Cycle Employee Wise' Where Setting_ID = @setting_id_max
		End
		
		
	--Commented by rohit on 12112013
	----Start Add By Gadriwala 27082013
	--if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Hide Post Request')
	--	begin
	--		select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
	--		Insert into T0040_SETTING values(@setting_id_max,@Cmp_ID,'Hide Post Request',0)	
	--	end	
	----End Add By Gadriwala 27092013
	if exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Hide Post Request')
	begin
		delete from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Hide Post Request'
	end
	----Start Add By Gadriwala 30082013
	--if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Hide Todays Thought')
	--	begin
	--		select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
	--		Insert into T0040_SETTING values(@setting_id_max,@Cmp_ID,'Hide Todays Thought',0)	
	--	end	
	----End Add By Gadriwala 30082013
	
	if exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Hide Todays Thought')
	begin
		delete from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Hide Todays Thought'
	end
	
	--Start Add By Gadriwala 03092013
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Salary Records Highlight if no PAN Card Number')
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING 
			values(@setting_id_max,@Cmp_ID,'Salary Records Highlight if no PAN Card Number',0
			,'Active option for highlight row when employee’s PAN Card detail is missing at the time of salary generation','Salary Settings',
			'Salary Records Highlight if no PAN Card Number',NULL)	
		end	
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Salary Records Highlight if no PAN Card Number')
			Update T0040_SETTING Set Comment = 'Active option for highlight row when employee’s PAN Card detail is missing at the time of salary generation', Group_By = 'Salary Settings' 
			,Alias='Salary Records Highlight if no PAN Card Number' Where Setting_ID = @setting_id_max
		End
		
	--End Add By Gadriwala 03092013
		--Start Add By Gadriwala 30092013
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Salary Records Highlight if Previous Salary on Hold')
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING 
			values(@setting_id_max,@Cmp_ID,'Salary Records Highlight if Previous Salary on Hold',0
			,'Active option for highlight row when employee’s salary on HOLD the time of salary generation','Salary Settings'
			,'Salary Records Highlight if Previous Salary on Hold',NULL)	
		end	
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Salary Records Highlight if Previous Salary on Hold')
			Update T0040_SETTING Set Comment = 'Active option for highlight row when employee’s salary on HOLD the time of salary generation', Group_By = 'Salary Settings' 
			,Alias='Salary Records Highlight if Previous Salary on Hold' Where Setting_ID = @setting_id_max
		End
		
	--End Add By Gadriwala 03082013
	--Start Add By Gadriwala 03092013
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Leave not Approval Popup in Salary')
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING
			values(@setting_id_max,@Cmp_ID,'Leave not Approval Popup in Salary',0
			,'Active option for view list of employees whose leaves are still pending for approval at the time of salary generation','Salary Settings'
			,'Leave not Approval Popup in Salary',NULL)	
		end	
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Leave not Approval Popup in Salary')
			Update T0040_SETTING Set Comment = 'Active option for view list of employees whose leaves are still pending for approval at the time of salary generation', Group_By = 'Salary Settings' 
			,Alias='Leave not Approval Popup in Salary' Where Setting_ID = @setting_id_max
		End
		
	--End Add By Gadriwala 03092013
	
	-- Added By Ali 30112013 -- Start
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Hide Browse file in IT declaration')
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING 
			values(@setting_id_max,@Cmp_ID,'Hide Browse file in IT declaration',0
			,'Active option for hide Browse file option in IT declaration page for upload some documents/proof.','Income-Tax Settings'
			,'Hide Browse file in IT declaration',NULL)	
		end	
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Hide Browse file in IT declaration')
			Update T0040_SETTING Set Comment = 'Active option for hide Browse file option in IT declaration page for upload some documents/proof.' , Group_By = 'Income-Tax Settings'
			,Alias='Hide Browse file in IT declaration' Where Setting_ID = @setting_id_max
		End
		
	-- Added By Ali 30112013 -- End
	
	-- Added By Ali 22012014 -- Start
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Enable IT Declaration for mid join employee upto days')
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING 
			values(@setting_id_max,@Cmp_ID,'Enable IT Declaration for mid join employee upto days',0
			,'For Mid join employee enable IT Declaration for the days period even if Periodically lock is enabled.','Income-Tax Settings'
			,'Enable IT Declaration for mid join employee upto days',NULL)	
		end	
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Enable IT Declaration for mid join employee upto days')
			Update T0040_SETTING Set Comment = 'For Mid join employee enable IT Declaration for the days period even if Periodically lock is enabled.', Group_By = 'Income-Tax Settings' 
			,Alias='Enable IT Declaration for mid join employee upto days' Where Setting_ID = @setting_id_max
		End
	-- Added By Ali 22012014 -- End
	
 
 -- Added by rohit on 29-nov-2013
 if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='show other Employee leave in leave Approval')
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING 
			values(@setting_id_max,@Cmp_ID,'show other Employee leave in leave Approval',1
			,'Active Hyper link for view other employee’s leaves while leave approval.','Leave Settings'
			,'show other Employee leave in leave Approval',NULL)	
		end	
Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='show other Employee leave in leave Approval')
			Update T0040_SETTING Set Comment = 'Active Hyper link for view other employee’s leaves while leave approval.', Group_By = 'Leave Settings' 
			,Alias='show other Employee leave in leave Approval' Where Setting_ID = @setting_id_max
		End
		
-- ended by rohit on 29-nov-2013		
 
 if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Show Emp Detail at top view(Ess)')
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING 
			values(@setting_id_max,@Cmp_ID,'Show Emp Detail at top view(Ess)',1
			,'Active option for view employee’s details at ESS Side at the top of the page','Employee Settings',
			'Show Emp Detail at top view(Ess)',NULL)	
		end	
Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Show Emp Detail at top view(Ess)')
			Update T0040_SETTING Set Comment = 'Active option for view employee’s details at ESS Side at the top of the page', Group_By ='Employee Settings' 
			,Alias='Show Emp Detail at top view(Ess)'
			Where Setting_ID = @setting_id_max
		End
		
	-- added by mitesh on 09122013
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Process salary in background')
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING 
			values(@setting_id_max,@Cmp_ID,'Process salary in background',0
			,'Active option for salary process in background','Salary Settings',
			'Process salary in background',NULL)	
		end	
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Process salary in background')
			Update T0040_SETTING Set Comment = 'Active option for salary process in background', Group_By = 'Salary Settings' 
			,Alias='Process salary in background'  Where Setting_ID = @setting_id_max
		End
		-- added by mitesh
		-- Added by Gadriwala 11012014
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Show Pass Responsibility in Leave')
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING 
			values(@setting_id_max,@Cmp_ID,'Show Pass Responsibility in Leave',0,'Active option for pass responsibility while leave application/approval.','Leave Settings'
			,'Show Pass Responsibility in Leave',NULL)	
		end	
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Show Pass Responsibility in Leave')
			Update T0040_SETTING Set Comment = 'Active option for pass responsibility while leave application/approval.', Group_By = 'Leave Settings' 
			,Alias='Show Pass Responsibility in Leave'  Where Setting_ID = @setting_id_max
		End
	
	---- Added by rohit on 03-apr-2014
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Show list of employees whose PT settings are pending during Salary Process')
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING 
			values(@setting_id_max,@Cmp_ID,'Show list of employees whose PT settings are pending during Salary Process',0,'Active option for Show list of employees whose PT settings are pending during Salary Process even if settings done in "general setting"','Salary Settings'
			,'Show list of employees whose PT settings are pending during Salary Process',NULL)	
		end	
	else
	begin
		select @setting_id_max =(select setting_ID from  T0040_SETTING where Cmp_ID=@Cmp_ID 
		and Setting_Name='Show list of employees whose PT settings are pending during Salary Process')
		Update T0040_SETTING set Group_By = 'Salary Settings' 
		,Alias='Show list of employees whose PT settings are pending during Salary Process' Where Setting_ID = @setting_id_max
	end
	
	--Added by nilesh patel on 04112015 Start
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Show absent days in salary slip when calaculate salary on fix day')
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING 
			values(@setting_id_max,@Cmp_ID,'Show absent days in salary slip when calaculate salary on fix day',0,'Show Absent Day in salary slip when calculate on Fix day','Salary Settings'
			,'Show absent days in salary slip when calaculate salary on fix day',NULL)	
		end	
	else
	begin
		select @setting_id_max =(select setting_ID from  T0040_SETTING where Cmp_ID=@Cmp_ID 
		and Setting_Name='Show absent days in salary slip when calaculate salary on fix day')
		Update T0040_SETTING set Group_By = 'Salary Settings' 
		,Alias='Show absent days in salary slip when calaculate salary on fix day' Where Setting_ID = @setting_id_max
	end
	--Added by nilesh patel on 04112015 End
	
		
	-- Added by Gadriwala Muslim 17042014
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Salary Slip with Password Protected')
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING 
			values(@setting_id_max,@Cmp_ID,'Salary Slip with Password Protected',0
			,'Salary Slip file with Password Protected.','Salary Settings','Salary Slip with Password Protected',NULL)	
		end	
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Salary Slip with Password Protected')
			Update T0040_SETTING Set Comment = 'Salary Slip file with Password Protected.',Group_By = 'Salary Settings' 
			,Alias='Salary Slip with Password Protected' Where Setting_ID = @setting_id_max
		End
	-- Added by Gadriwala Muslim 17042014
	
	-- Added by Gadriwala Muslim 24042014
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='State wise minimum wages Calculation')
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING 
			values(@setting_id_max,@Cmp_ID,'State wise minimum wages Calculation',0
			,'State wise minimum wages Calculation.','Employee Settings','State wise minimum wages Calculation',NULL)	
		end	
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='State wise minimum wages Calculation')
			Update T0040_SETTING Set Comment = 'State wise minimum wages Calculation.', Group_By = 'Employee Settings' 
			,Alias='State wise minimum wages Calculation'  Where Setting_ID = @setting_id_max
		End
	-- Added by Gadriwala Muslim 24042014
	
	-- Added By Ali 14052014 -- Start
	
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Hide Downline Employee Salary')
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING 
			values(@setting_id_max,@Cmp_ID,'Hide Downline Employee Salary',0,'Hide Downline Employee Salary','Salary Settings'
			,'Hide Downline Employee Salary',NULL)	
		end	
	else
	begin
		select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Hide Downline Employee Salary')
			Update T0040_SETTING Set  Group_By = 'Salary Settings' 
			,Alias='Hide Downline Employee Salary' 
			Where Setting_ID = @setting_id_max
	
	end
-----Added by sid 23052014

	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Allow Part Day Leave')
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING 
			values(@setting_id_max,@Cmp_ID,'Allow Part Day Leave',0,'Activation will allow Part day leave, Apply hourly tag on Leave Master','Leave Settings'
			,'Allow Part Day Leave',NULL)	
		end	
	else
		begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Allow Part Day Leave')
			Update T0040_SETTING Set  Group_By = 'Leave Settings'
			,Alias='Allow Part Day Leave' 
			 Where Setting_ID = @setting_id_max
		end	
		
	-------Added by Sumit for Leave Cancellation Comment Mandatory or not-07042016----------------------------------------------
 if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Comment field Mandatory in Leave Cancellation form')
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING 
			values(@setting_id_max,@Cmp_ID,'Comment field Mandatory in Leave Cancellation form',1
			,'Activation will do Comment field Mandatory in Leave Cancellation form','Leave Settings'
			,'Comment field Mandatory in Leave Cancellation form',NULL)	
		end	
Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Comment field Mandatory in Leave Cancellation form')
			Update T0040_SETTING Set Comment = 'Activation will do Comment field Mandatory in Leave Cancellation form', Group_By = 'Leave Settings' 
			,Alias='Comment field Mandatory in Leave Cancellation form' Where Setting_ID = @setting_id_max
		End
		

	-----Ended by Sumit 07042016------------------------------------------------	
		
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Allow Attendance Regularization Editable')
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING 
			values(@setting_id_max,@Cmp_ID,'Allow Attendance Regularization Editable',0,'Allow Attendance Regularization Editable','Attendance Settings'
			,'Allow Attendance Regularization Editable',NULL)	
		end	
	else
		begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Allow Attendance Regularization Editable')
			Update T0040_SETTING Set  Group_By = 'Attendance Settings'
			,Alias='Allow Attendance Regularization Editable' 
			Where Setting_ID = @setting_id_max
		end	
	
	-----Ankit 29012015
	IF NOT EXISTS(SELECT 1 FROM T0040_SETTING WHERE Cmp_ID=@Cmp_ID and Setting_Name='Show Current Month Attendance Regularization Count On Home Page')
		BEGIN
			SELECT @Setting_ID_max=isnull(max(Setting_ID),0) + 1 from T0040_SETTING
			INSERT INTO T0040_SETTING
			VALUES(@Setting_ID_max,@Cmp_ID,'Show Current Month Attendance Regularization Count On Home Page','1','Show Current Month Attendance Regularization Pending App Count On Home Page','Attendance Settings'
			,'Show Current Month Attendance Regularization Count On Home Page',NULL)
		END
	else
		begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Show Current Month Attendance Regularization Count On Home Page')
			Update T0040_SETTING Set Alias='Show Current Month Attendance Regularization Count On Home Page' 
			Where Setting_ID = @setting_id_max
		end
	-----Ankit 29012015
			
-----Adde by sid ends
-----Added by sid 030602014
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Allow Comments in Salary Slip')
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING 
			values(@setting_id_max,@Cmp_ID,'Allow Comments in Salary Slip',0,'Allow Comments in Salary Slip','Reports'
			,'Allow Comments in Salary Slip',NULL)	
		end	
	else
		begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Allow Comments in Salary Slip')
			Update T0040_SETTING Set  Group_By = 'Reports'
			,Alias='Allow Comments in Salary Slip' 
			Where Setting_ID = @setting_id_max
		end	
-----Added by sid ends

	
	-- Added By Ali 14052014 -- End
	
-- Added by Gadriwala Muslim 09052014 - Start
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='In OT Approval Remark Column Show')
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING 
			values(@setting_id_max,@Cmp_ID,'In OT Approval Remark Column Show',0
			,'In OT Approval Remark Column Show','Leave Settings','In OT Approval Remark Column Show',NULL)	
		end	
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='In OT Approval Remark Column Show')
			Update T0040_SETTING Set Comment = 'In OT Approval Remark Column Show',Group_By = 'Leave Settings' 
			,Alias='In OT Approval Remark Column Show' 
			Where Setting_ID = @setting_id_max
		End
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Hide Cancel Weekoff and Holiday in Leave Approval')
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING
			values(@setting_id_max,@Cmp_ID,'Hide Cancel Weekoff and Holiday in Leave Approval',0
			,'Hide Cancel Weekoff and Holiday in Leave Approval','Leave Settings','Hide Cancel Weekoff and Holiday in Leave Approval',NULL)	
		end	
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Hide Cancel Weekoff and Holiday in Leave Approval')
			Update T0040_SETTING Set Comment = 'Hide Cancel Weekoff and Holiday in Leave Approval' ,Group_By = 'Leave Settings'
			,Alias='Hide Cancel Weekoff and Holiday in Leave Approval'  
			Where Setting_ID = @setting_id_max
		End
	-- Added by Gadriwala Muslim 09052014	-End
	
	--------Ankit 06082016
	IF NOT EXISTS(SELECT 1 FROM T0040_SETTING WHERE Cmp_ID=@Cmp_ID AND Setting_Name='Hide Cancel Weekoff and Holiday in Leave Application')
		BEGIN
			SELECT @setting_id_max=ISNULL(MAX(setting_id),0) + 1 FROM T0040_SETTING
			INSERT INTO T0040_SETTING
			VALUES(@setting_id_max,@Cmp_ID,'Hide Cancel Weekoff and Holiday in Leave Application',0
			,'Hide Cancel Weekoff and Holiday in Leave Application','Leave Settings','Hide Cancel Weekoff and Holiday in Leave Application',NULL)	
		END	
	ELSE
		BEGIN
			SELECT @setting_id_max = (SELECT Setting_ID FROM T0040_SETTING WHERE Cmp_ID = @Cmp_ID AND Setting_Name='Hide Cancel Weekoff and Holiday in Leave Application')
			UPDATE T0040_SETTING 
			SET Comment = 'Hide Cancel Weekoff and Holiday in Leave Application' ,Group_By = 'Leave Settings'
				,ALIAS='Hide Cancel Weekoff and Holiday in Leave Application'  
			WHERE Setting_ID = @setting_id_max
		END
	--------Ankit 06082016
	
	-- Added by Hardik 25/06/2014 for BMA wants Employer ESIC Upper Round
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Upper Round for Employer ESIC')
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING 
			values(@setting_id_max,@Cmp_ID,'Upper Round for Employer ESIC',0,'Active Option for Upper Rounding for Employer ESIC','Employee Settings'
			,'Upper Round for Employer ESIC',NULL)	
		end	
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Upper Round for Employer ESIC')
			Update T0040_SETTING Set Comment = 'Active Option for Upper Rounding for Employer ESIC', Group_By = 'Employee Settings' 
			,Alias='Upper Round for Employer ESIC' 
			Where Setting_ID = @setting_id_max
		End
	
	-----------------------------
	
	---Ripal 19Jun2014 Start
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Allowance detail show in Allowance/Reimbursement')
		begin
			select @Setting_ID_max=isnull(max(Setting_ID),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING
			values(@Setting_ID_max,@Cmp_ID,'Allowance detail show in Allowance/Reimbursement','0','Allowance detail show in Allowance/Reimbursement','Reimbursement Settings'
			,'Allowance detail show in Allowance/Reimbursement',NULL)
		end
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Allowance detail show in Allowance/Reimbursement')
			Update T0040_SETTING Set Group_By = 'Reimbursement Settings' 
			,Alias='Allowance detail show in Allowance/Reimbursement' 
			Where Setting_ID = @setting_id_max
		End	
		
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Intimate day for Allowance/Reimbursement application')
		begin
			select @Setting_ID_max=isnull(max(Setting_ID),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING
			values(@Setting_ID_max,@Cmp_ID,'Intimate day for Allowance/Reimbursement application','0','Intimate day for Allowance/Reimbursement application','Reimbursement Settings',
			'Intimate day for Allowance/Reimbursement application',NULL)
		end
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Intimate day for Allowance/Reimbursement application')
			Update T0040_SETTING Set Group_By = 'Reimbursement Settings' 
			,Alias='Intimate day for Allowance/Reimbursement application' 
			Where Setting_ID = @setting_id_max
		End	
		-----------Added by Sumit 09072015-------------------------------------------------------------
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Enable Age Restriction in Medical for Dependent (Enter Age)')
		begin
			select @Setting_ID_max=isnull(max(Setting_ID),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING(Setting_ID,Cmp_ID,Setting_Name,Setting_Value,Comment,Group_By,Alias,Module_Name)
			                   values(@Setting_ID_max,@Cmp_ID,'Enable Age Restriction in Medical for Dependent (Enter Age)','0','Enable Age Restriction in Medical for Dependent (Enter Age)','Reimbursement Settings','Enable Age Restriction in Medical for Dependent (Enter Age)',NULL)
		end
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Enable Age Restriction in Medical for Dependent (Enter Age)')
			Update T0040_SETTING Set Group_By = 'Reimbursement Settings',Alias='Enable Age Restriction in Medical for Dependent (Enter Age)' Where Setting_ID = @setting_id_max 
		End	
		
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Hide Age Column')
		begin
			select @Setting_ID_max=isnull(max(Setting_ID),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING(Setting_ID,Cmp_ID,Setting_Name,Setting_Value,Comment,Group_By,alias,Module_Name)
			                   values(@Setting_ID_max,@Cmp_ID,'Hide Age Column','0','Hide Age Column','Reimbursement Settings','Hide Age Column',NULL)
		end
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Hide Age Column')
			Update T0040_SETTING Set Group_By = 'Reimbursement Settings',Alias='Hide Age Column' Where Setting_ID = @setting_id_max 
		End				
	-----------Ended by Sumit 09072015-------------------------------------------------------------	
	---Ripal 19Jun2014 End
	
	-- Nilay 23JUN2014 Start
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Reimbusement application after date of join days')
		begin
			select @Setting_ID_max=isnull(max(Setting_ID),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING
			                   values(@Setting_ID_max,@Cmp_ID,'Reimbusement application after date of join days','0','Reimbusement application after date of join days','Reimbursement Settings',
			                   'Reimbursement application after date of join days',NULL)
		end
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Reimbusement application after date of join days')
			Update T0040_SETTING Set Group_By = 'Reimbursement Settings'
			,Alias='Reimbursement application after date of join days'  
			Where Setting_ID = @setting_id_max
		End	
	-- Nilay 23Jun2014 End
	
	-- Added by rohit on 19062015
	
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Reimbershment Not Effect in Salary Default')
		begin
			select @Setting_ID_max=isnull(max(Setting_ID),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING
			values(@Setting_ID_max,@Cmp_ID,'Reimbershment Not Effect in Salary Default','0','Eanable option for Reimbershment Not Effect in Salary by Default','Reimbursement Settings'
			,'Reimbursement Not Effect in Salary Default',NULL)
		end
	else
		begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Reimbershment Not Effect in Salary Default')
			Update T0040_SETTING Set Alias='Reimbursement Not Effect in Salary Default'  
			Where Setting_ID = @setting_id_max
		end
	-- Ended by rohit on 19062015
	
	-- Ankit 10072014 Start
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Insurance Reminder Days')
		begin
			select @Setting_ID_max=isnull(max(Setting_ID),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING
			values(@Setting_ID_max,@Cmp_ID,'Insurance Reminder Days','0','Insurance Reminder Days','Other Settings'
			,'Insurance Reminder Days',NULL)
		end
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Insurance Reminder Days')
			Update T0040_SETTING Set Group_By = 'Other Settings'
			 ,Alias='Insurance Reminder Days'
			Where Setting_ID = @setting_id_max
		End		
	-----Added by Sumit for Showing Multi Employee Option in Enable in Travel Settlement 08082015---------------------------------------------------------------------------------------------------	
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Add Other Employees In Travel Settlement')
		begin
			select @Setting_ID_max=isnull(max(Setting_ID),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING
			values(@Setting_ID_max,@Cmp_ID,'Add Other Employees In Travel Settlement','0','Add Other Employees In Travel Settlement','Travel Settings'
			,'Add Other Employees In Travel Settlement',NULL)
		end
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Add Other Employees In Travel Settlement')
			Update T0040_SETTING Set Group_By = 'Travel Settings'
			 ,Alias='Add Other Employees In Travel Settlement'
			Where Setting_ID = @setting_id_max
		End	
	-----Added by Sumit for Enable International Travel 01102015---------------------------------------------------------------------------------------------------	
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Enable International Travel')
		begin
			select @Setting_ID_max=isnull(max(Setting_ID),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING
			values(@Setting_ID_max,@Cmp_ID,'Enable International Travel','0','Enable International Travel','Travel Settings'
			,'Enable International Travel',NULL)
		end
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Enable International Travel')
			Update T0040_SETTING Set Group_By = 'Travel Settings'
			 ,Alias='Enable International Travel'
			Where Setting_ID = @setting_id_max
		End		
	-----Ended by Sumit for Showing Multi Employee Option in Enable in Travel Settlement 08082015---		
	-----Added by Sumit for Showing Multi Employee Option in Enable in Travel Settlement 08082015---------------------------------------------------------------------------------------------------	
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Enable Check out Date Option in Travel Application')
		begin
			select @Setting_ID_max=isnull(max(Setting_ID),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING
			values(@Setting_ID_max,@Cmp_ID,'Enable Check out Date Option in Travel Application','0','Enable Check out Date Option in Travel Application','Travel Settings'
			,'Enable Check out Date Option in Travel Application',NULL)
		end
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Enable Check out Date Option in Travel Application')
			Update T0040_SETTING Set Group_By = 'Travel Settings'
			 ,Alias='Enable Check out Date Option in Travel Application'
			Where Setting_ID = @setting_id_max
		End	
	-----Ended by Sumit for Showing Multi Employee Option in Enable in Travel Settlement 08082015---	
	-----Added by Sumit for Show / Hide Instruct by column Travel Application Page 28092015---------------------------------------------------------------------------------------------------	
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Enable Instruct By Employee Column in Travel Application')
		begin
			select @Setting_ID_max=isnull(max(Setting_ID),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING
			values(@Setting_ID_max,@Cmp_ID,'Enable Instruct By Employee Column in Travel Application','0','Enable Instruct By Employee Column in Travel Application','Travel Settings'
			,'Enable Instruct By Employee Column in Travel Application',NULL)
		end
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Enable Instruct By Employee Column in Travel Application')
			Update T0040_SETTING Set Group_By = 'Travel Settings'
			 ,Alias='Enable Instruct By Employee Column in Travel Application'
			Where Setting_ID = @setting_id_max
		End	
	-----Ended by Sumit for Show / Hide Instruct by column Travel Application Page 28092015---
	-----Added by Sumit for Enable Vendor-payment request Travel 13012016---------------------------------------------------------------------------------------------------	
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Enable Project in Travel')
		begin
			select @Setting_ID_max=isnull(max(Setting_ID),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING
			values(@Setting_ID_max,@Cmp_ID,'Enable Project in Travel','0','Enable Project in Travel','Travel Settings'
			,'Enable Project in Travel',NULL)
		end
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Enable Project in Travel')
			Update T0040_SETTING Set Group_By = 'Travel Settings'
			 ,Alias='Enable Project in Travel'
			Where Setting_ID = @setting_id_max
		End		
	-----Ended by Sumit Vendor-payment request Travel 13012016---
	---Added by rohit on 04022016 ---------
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Travel Claim Submit Limit')
		begin
			select @Setting_ID_max=isnull(max(Setting_ID),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING
			values(@Setting_ID_max,@Cmp_ID,'Travel Claim Submit Limit','0','Travel Claim Submit Limit with Travel Approval Date Ex. 0 means Unlimited Days and 15 means Settlement application apply within 15 days after travel approval date. ','Travel Settings'
			,'Travel Claim Submit Limit(days)','PAYROLL')
		end
	
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Eanable Advance in Travel')
		begin
			select @Setting_ID_max=isnull(max(Setting_ID),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING
			values(@Setting_ID_max,@Cmp_ID,'Eanable Advance in Travel','1','Active Option for Enable Advance in Travel.','Travel Settings'
			,'Enable Advance in Travel','PAYROLL')
		end			
	---Ended by rohit on 04022016 ---------
	
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='In Travel Settlement Approval -- Approval Amount should not be greater than Claim Amount')
		begin
			select @Setting_ID_max=isnull(max(Setting_ID),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING
			values(@Setting_ID_max,@Cmp_ID,'In Travel Settlement Approval -- Approval Amount should not be greater than Claim Amount','0','In Travel Settlement Approval -- Approval Amount should not be greater than Claim Amount','Travel Settings'
			,'In Travel Settlement Approval -- Approval Amount should not be greater than Claim Amount',NULL)
		end
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='In Travel Settlement Approval -- Approval Amount should not be greater than Claim Amount')
			Update T0040_SETTING Set Group_By = 'Travel Settings'
			 ,Alias='In Travel Settlement Approval -- Approval Amount should not be greater than Claim Amount'
			Where Setting_ID = @setting_id_max
		End		
	-----Ended by Sumit for Approval Amount 09032016
	
	-------Added by sumit 04112014--------------------------------------	
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Hide Currency in Claim Application')
		begin
			select @Setting_ID_max=isnull(max(Setting_ID),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING
			values(@Setting_ID_max,@Cmp_ID,'Hide Currency in Claim Application','0','Active Option for Show Currency and Exchange rate in Claim Application','Claim Settings',
			'Hide Currency in Claim Application',NULL)
		end
	else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Hide Currency in Claim Application')
			Update T0040_SETTING Set Group_By = 'Claim Settings' 
			,Alias='Hide Currency in Claim Application'
			Where Setting_ID = @setting_id_max
		End	
		-------Ended by sumit 04112014--------------------------------------	
-----Added by Sumit for Enable Travel Purpose Column Mandatory 14072016---------------------------------------------------------------------------------------------------	
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Purpose Column Mandatory in Travel Application')
		begin
			select @Setting_ID_max=isnull(max(Setting_ID),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING
			values(@Setting_ID_max,@Cmp_ID,'Purpose Column Mandatory in Travel Application','0','Purpose Column Mandatory in Travel Application','Travel Settings'
			,'Purpose Column Mandatory in Travel Application','PAYROLL')
		end
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Purpose Column Mandatory in Travel Application')
			Update T0040_SETTING Set Group_By = 'Travel Settings'
			 ,Alias='Purpose Column Mandatory in Travel Application'
			Where Setting_ID = @setting_id_max
		End
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Leave Selection [On Duty] Mandatory for Travel')
		begin
			select @Setting_ID_max=isnull(max(Setting_ID),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING
			values(@Setting_ID_max,@Cmp_ID,'Leave Selection [On Duty] Mandatory for Travel','0','Leave Selection [On Duty] Mandatory for Travel','Travel Settings'
			,'Leave Selection [On Duty] Mandatory for Travel','PAYROLL')
		end
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Leave Selection [On Duty] Mandatory for Travel')
			Update T0040_SETTING Set Group_By = 'Travel Settings'
			 ,Alias='Leave Selection [On Duty] Mandatory for Travel'
			Where Setting_ID = @setting_id_max
		End	
		
				
	-----Ended by Sumit Travel Purpose Column Mandatory 14072016---		
-- Added by rohit on 17102014 Start

	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Enable document upload in grade master')
		begin
			select @Setting_ID_max=isnull(max(Setting_ID),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING
			values(@Setting_ID_max,@Cmp_ID,'Enable document upload in grade master','0','Active option for Enable document upload in grade master','Other Settings'
			,'Enable document upload in Grade Master',NULL)
		end
	else
		begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Enable document upload in grade master')
			Update T0040_SETTING set Alias='Enable document upload in Grade Master'
			Where Setting_ID = @setting_id_max
		end
		--ended by rohit on 17102014
		
		
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='OD and CompOff Leave Consider As Present')
		begin
			select @Setting_ID_max=isnull(max(Setting_ID),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING
			values(@Setting_ID_max,@Cmp_ID,'OD and CompOff Leave Consider As Present','0','OD and CompOff Leave Consider As Present','Leave Settings'
			,'OD and CompOff Leave Consider As Present',NULL)
		end	
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='OD and CompOff Leave Consider As Present')
			Update T0040_SETTING Set Group_By = 'Leave Settings' 
			,Alias='OD and CompOff Leave Consider As Present'
			Where Setting_ID = @setting_id_max
		End	
		
		-- Added by rohit for Round Value in  leave balance on 12122014
		--Added by sumit 25022015 for Checking BackDated in Leave Application--------------------------------
		if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Check Absent History of Previous Month in Leave')
		begin
			select @Setting_ID_max=isnull(max(Setting_ID),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING
			values(@Setting_ID_max,@Cmp_ID,'Check Absent History of Previous Month in Leave','1','Check Absent History of Previous Month','Leave Settings'
			,'Check Absent History of Previous Month in Leave',NULL)
		end
		Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Check Absent History of Previous Month in Leave')
			Update T0040_SETTING Set Group_By = 'Leave Settings' 
			,Alias='Check Absent History of Previous Month in Leave'
			Where Setting_ID = @setting_id_max
		End	
		----Ended by sumit 25022015-------------------------------------------------------------
		if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Lower Round in leave Balance')
		begin
			select @Setting_ID_max=isnull(max(Setting_ID),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING
			values(@Setting_ID_max,@Cmp_ID,'Lower Round in leave Balance','0','Active Option for Showing Lower Round in leave Balance.For Ex. if Balance is 1.25 then balance Showing 1 or leave balance is 1.56 then 1.5','Leave Settings',
			'Lower Round in leave Balance',NULL)
		end	
		else
			begin
				select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
				and Setting_Name='Lower Round in leave Balance')
				Update T0040_SETTING Set Alias='Lower Round in leave Balance'
				Where Setting_ID = @setting_id_max	
			end
		-- ended by rohit on 12122014

--Added By Mukti(start) for Asset Installment 23032015
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Enable Asset Installment')
		begin
			select @Setting_ID_max=isnull(max(Setting_ID),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING
			    values(@Setting_ID_max,@Cmp_ID,'Enable Asset Installment','0','Enable Asset Installment in Asset Approval form','Other Settings',
			    'Enable Asset Installment',NULL)
		end
	else
		begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Enable Asset Installment')
			Update T0040_SETTING Set Alias='Enable Asset Installment'
			Where Setting_ID = @setting_id_max	
		end
--Added By Mukti(end) for Asset Installment 23032015
		
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Conveyance Tax Exemption based on prorate')
		begin
			select @Setting_ID_max=isnull(max(Setting_ID),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING
			values(@Setting_ID_max,@Cmp_ID,'Conveyance Tax Exemption based on prorate','0','Conveyance Tax Exemption based on prorate or full amount(with max limit) depends on Mid-Join or Mid-Left','Income-Tax Settings'
			,'Conveyance Tax Exemption based on prorate',NULL)
		end	
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Conveyance Tax Exemption based on prorate')
			Update T0040_SETTING Set Group_By = 'Income-Tax Settings' 
			,Alias='Conveyance Tax Exemption based on prorate'
			Where Setting_ID = @setting_id_max
		End	
			
	-- Ankit 10072014 End
	--Gadriwala Muslim 18072014 - Start
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Hide Monthly OT Approval')
		begin
			select @Setting_ID_max=isnull(max(Setting_ID),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING
			values(@Setting_ID_max,@Cmp_ID,'Hide Monthly OT Approval','0','Hide or Show Monthly OT Approval for At the time of Approving OT','Leave Settings'
			,'Hide Monthly OT Approval',NULL)
		end
	else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Hide Monthly OT Approval')
			Update T0040_SETTING Set 
			Alias='Hide Monthly OT Approval'
			 Where Setting_ID = @setting_id_max
		End
	
	--Added by Gadriwala Muslim 13052015 - Start
	IF not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Comp-off Balance show as on date wise')
			BEGIN 
				select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
				Insert into T0040_SETTING 
				values(@setting_id_max,@Cmp_ID,'Comp-off Balance show as on date wise',0
				,'1 for Comp-off Balance show as on date wise','Leave Settings','Comp-off Balance show as on date wise',NULL)	
			END
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Comp-off Balance show as on date wise')
			Update T0040_SETTING Set Alias='Comp-off Balance show as on date wise'
			Where Setting_ID = @setting_id_max
		End	
	--Added by Gadriwala Muslim 13052015 - End
	--if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Production Incentive Salary')
	--	begin
	--		select @Setting_ID_max=isnull(max(Setting_ID),0) + 1 from T0040_SETTING
	--		Insert into T0040_SETTING(Setting_ID,Cmp_ID,Setting_Name,Setting_Value,Comment,Group_By)
	--		                   values(@Setting_ID_max,@Cmp_ID,'Production Incentive Salary','0','Show Production Incentive in Salary Pages','Salary Settings')
	--	end
	--else
	--	Begin
	--		select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
	--		and Setting_Name='Production Incentive Salary')
	--		Update T0040_SETTING Set Group_By = 'Salary Settings' Where Setting_ID = @setting_id_max
	--	End
		
	--Gadriwala Muslim 18072014 - End
	--Added by Gadriwala 15102014 - End	
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Bulk Increment Basic Salary Upper Rouning')
		begin
			select @Setting_ID_max=isnull(max(Setting_ID),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING
			values(@Setting_ID_max,@Cmp_ID,'Bulk Increment Basic Salary Upper Rouning','0','You can insert 0,5 or 10 in Field value for Bulk Increment Basic Salary Upper Rounding','Bulk Increment'
			,'Bulk Increment Basic Salary Upper Rouning',NULL)
		end
	else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Bulk Increment Basic Salary Upper Rouning')
			Update T0040_SETTING Set Group_By = 'Bulk Increment' 
			,Alias='Bulk Increment Basic Salary Upper Rouning'
			Where Setting_ID = @setting_id_max
		End
	--Added by Gadriwala 15102014 - End	
	-----------------------------
	
	--Added By Jaina 02-06-2016 Start
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Exit Clearance Require')
		begin
			select @Setting_ID_max=isnull(max(Setting_ID),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING
			values(@Setting_ID_max,@Cmp_ID,'Exit Clearance Require','0','Set 0 for Inactive and 1 For Active','Other Settings'
			,'Exit Clearance Require','PAYROLL')
		end
	else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Exit Clearance Require')
			Update T0040_SETTING Set Group_By = 'Other Settings' 
			,Alias='Exit Clearance Require'
			Where Setting_ID = @setting_id_max
		End
	--Added By Jaina 02-06-2016 End
	
	
	/***Added by Nimesh 19 May, 2015***
	*****For Report Preview Options****/
	SET @setting_id_max = (SELECT Setting_ID FROM T0040_SETTING WHERE Cmp_ID = @Cmp_ID 
				AND Setting_Name='Report Preview Options')
	IF @setting_id_max IS NULL BEGIN
			SELECT @Setting_ID_max=ISNULL(MAX(Setting_ID),0) + 1 FROM T0040_SETTING			
			INSERT INTO T0040_SETTING
		VALUES(@Setting_ID_max,@Cmp_ID,'Report Preview Options','0','You can insert 0 to disable the preview options and 1 to enable it.','Reports','Report Preview Options',NULL)
	END ELSE			
			Update T0040_SETTING Set Group_By = 'Reports' 
			,Alias='Report Preview Options'
			Where Setting_ID = @setting_id_max
				
	SET @setting_id_max = (SELECT Setting_ID FROM T0040_SETTING WHERE Cmp_ID = @Cmp_ID 
				AND Setting_Name='Show Reimbursement Amount in Salary Slip')
	IF @setting_id_max IS NULL BEGIN
			SELECT @Setting_ID_max=ISNULL(MAX(Setting_ID),0) + 1 FROM T0040_SETTING			
			INSERT INTO T0040_SETTING
           VALUES(@Setting_ID_max,@Cmp_ID,'Show Reimbursement Amount in Salary Slip',
           '0','You can insert 0 to hide the reimbursement amount from the salary slip and 1 to show it.','Reports',
           'Show Reimbursement Amount in Salary Slip',NULL)
	END ELSE
			Update T0040_SETTING Set Group_By = 'Reports'
			,Alias='Show Reimbursement Amount in Salary Slip'
			 Where Setting_ID = @setting_id_max	
			
	---Added on 25-May-2015 (FOR removing gap between two Canteen In-Out punch)
	SET @setting_id_max = (SELECT Setting_ID FROM T0040_SETTING WHERE Cmp_ID = @Cmp_ID 
				AND Setting_Name='Maximum gap between two canteen punch (In minutes)')
	IF @setting_id_max IS NULL BEGIN
			SELECT @Setting_ID_max=ISNULL(MAX(Setting_ID),0) + 1 FROM T0040_SETTING			
			INSERT INTO T0040_SETTING
           VALUES(@Setting_ID_max,@Cmp_ID,'Maximum gap between two canteen punch (In minutes)',
           '0','Multiple punch will not be considered if the difference between two entries is less than or equal to given maximum number of minutes in gap. Enter 0 to allow all entries to be calcuated in canteen deduction.','Canteen Deduction'
           ,'Maximum gap between two canteen punch (In minutes)',NULL)
	END ELSE
			Update T0040_SETTING Set Group_By = 'Canteen Deduction'
			,Alias='Maximum gap between two canteen punch (In minutes)'
			 Where Setting_ID = @setting_id_max	
	/*Nimesh End*/
	
	
	
	-- Added by rohit on 11052015 for It Estimated Amount
	
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Enable Import Option for Estimated Amount')
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING 
			values(@setting_id_max,@Cmp_ID,'Enable Import Option for Estimated Amount',0
			,'Enable Import Option for Estimated Amount in It Preparation report on Listed Type Allowance.(Late,Present Senario,Absent Senario,Leave Senario,Performance,Transfer OT,Import,Bonus,Present Days,Slab Wise,Reference,Shift Wise,Leave Allowance,Split Shift,Formula,Security Deposit,Present + Paid Leave Days,Night Halt)','Income-Tax Settings'
			,'Enable Import Option for Estimated Amount',NULL)	
		end	
	else
		begin
			SET @setting_id_max = (SELECT Setting_ID FROM T0040_SETTING WHERE Cmp_ID = @Cmp_ID 
				AND Setting_Name='Enable Import Option for Estimated Amount')
			Update T0040_SETTING Set Alias='Enable Import Option for Estimated Amount'
			Where Setting_ID = @setting_id_max
		end
	
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Reimbershment Shows in IT Computation')
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING 
			values(@setting_id_max,@Cmp_ID,'Reimbershment Shows in IT Computation',0
			,'Enable Reimbershment Shows in IT Computation','Income-Tax Settings','Reimbursement Shows in IT Computation',NULL)	
		end	
	else
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING where Cmp_ID = @Cmp_ID and Setting_Name='Reimbershment Shows in IT Computation'
			Update T0040_SETTING Set Alias='Reimbursement Shows in IT Computation'
			Where Cmp_ID = @Cmp_ID and Setting_Name='Reimbershment Shows in IT Computation'
		end
	
	-- Ended By rohit on 11052015	
		
	IF NOT EXISTS(SELECT 1 FROM T0040_SETTING WHERE Cmp_ID=@Cmp_ID and Setting_Name='Allow Same Date Increment')	----Ankit
			BEGIN
				SELECT @setting_id_max=isnull(max(setting_id),0) + 1 FROM T0040_SETTING
				INSERT INTO T0040_SETTING 
				VALUES(@setting_id_max,@Cmp_ID,'Allow Same Date Increment',0,'Allow Employee Same Date Increment Entry','Employee Settings','Allow Same Date Increment',NULL)
			END	
	else
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING where Cmp_ID = @Cmp_ID and Setting_Name='Allow Same Date Increment'
			Update T0040_SETTING Set Alias='Allow Same Date Increment'
			Where  Cmp_ID = @Cmp_ID and Setting_Name='Allow Same Date Increment'
		end

	IF NOT EXISTS(SELECT 1 FROM T0040_SETTING WHERE Cmp_ID=@Cmp_ID and Setting_Name='Special Allowance Calculate From Employee Allowance/Deduction Revise')	----Ankit 10062015
			BEGIN
				SELECT @setting_id_max=isnull(max(setting_id),0) + 1 FROM T0040_SETTING
				INSERT INTO T0040_SETTING 
				VALUES(@setting_id_max,@Cmp_ID,'Special Allowance Calculate From Employee Allowance/Deduction Revise',0,'Special Allowance Calculate From Employee Allowance/Deduction Revise','Employee Settings'
				,'Special Allowance Calculate From Employee Allowance/Deduction Revise',NULL)
			END	
	else
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING where Cmp_ID = @Cmp_ID and Setting_Name='Special Allowance Calculate From Employee Allowance/Deduction Revise'
			Update T0040_SETTING Set Alias='Special Allowance Calculate From Employee Allowance/Deduction Revise'
			Where  Cmp_ID = @Cmp_ID and Setting_Name='Special Allowance Calculate From Employee Allowance/Deduction Revise'
		end
			
	--Added by Gadriwala Muslim 29052015 -Start
		IF not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Pre Comp-off Request Mandatory')
			BEGIN 
				select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
				Insert into T0040_SETTING 
				values(@setting_id_max,@Cmp_ID,'Pre Comp-off Request Mandatory',0
				,'1 for Pre Comp-Off Request Mandatory before Comp-Off Application','Leave Settings','Pre Comp-off Request Mandatory',NULL)	
			END	
		else
			begin
				select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING where Cmp_ID = @Cmp_ID and Setting_Name='Pre Comp-off Request Mandatory'
				Update T0040_SETTING Set Alias='Pre Comp-off Request Mandatory'
				Where  Cmp_ID = @Cmp_ID and Setting_Name='Pre Comp-off Request Mandatory'
				
			end
		--Added by Gadriwala Muslim 29052015 -End
				--Added by Gadriwala Muslim 10062015 -Start
		IF not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Auto comp-Off leave dates adjust')
			BEGIN 
				select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
				Insert into T0040_SETTING 
				values(@setting_id_max,@Cmp_ID,'Auto comp-Off leave dates adjust',0
				,'1 for Auto comp-Off leave adjust,while comp-Off leave applied by employee, No need to select comp-off dates from right side panel','Leave Settings',
				'Auto comp-Off leave dates adjust',NULL)	
			END	
		else
			begin
				select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING where Cmp_ID = @Cmp_ID and Setting_Name='Auto comp-Off leave dates adjust'
				Update T0040_SETTING Set Alias='Auto comp-Off leave dates adjust'
				Where Cmp_ID = @Cmp_ID and Setting_Name='Auto comp-Off leave dates adjust'
			end
			
			
		-- Added by Gadriwala Muslim 30092015 - Start	
		IF not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Auto CompOff Approval')
			BEGIN 
				select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
				Insert into T0040_SETTING 
				values(@setting_id_max,@Cmp_ID,'Auto CompOff Approval',0
				,'1 for Auto CompOff Approval when pre-compOff Approval with job daily schedule ','Leave Settings',
				'Auto CompOff Approval',NULL)	
			END	
		else
			begin
				select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING where Cmp_ID = @Cmp_ID and Setting_Name='Auto CompOff Approval'
				Update T0040_SETTING Set Alias='Auto CompOff Approval'
				Where Cmp_ID = @Cmp_ID and Setting_Name='Auto CompOff Approval'
			end	
		-- Added by Gadriwala Muslim 30092015 - End	
			
		IF not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Branch wise Leave')
			BEGIN 
				select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
				Insert into T0040_SETTING 
				values(@setting_id_max,@Cmp_ID,'Branch wise Leave',0
				,'1 for Branch wise Leave,0 for Regular Leave','Leave Settings','Branch wise Leave',NULL)	
			END	
		Else
			begin
				select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING where Cmp_ID = @Cmp_ID and Setting_Name='Branch wise Leave'
				Update T0040_SETTING Set Alias='Branch wise Leave'
				Where  Cmp_ID = @Cmp_ID and Setting_Name='Branch wise Leave'
			end
			
			IF not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Auto LWP Leave')
			BEGIN 
				select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
				Insert into T0040_SETTING 
				values(@setting_id_max,@Cmp_ID,'Auto LWP Leave',1
				,'1 for Auto LWP Leave,0 for Negative Leave Message show','Leave Settings','Auto LWP Leave',NULL)	
			END
			else
			begin
				select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING where Cmp_ID = @Cmp_ID and Setting_Name='Auto LWP Leave'
				Update T0040_SETTING Set Alias='Auto LWP Leave'
				Where Cmp_ID = @Cmp_ID and Setting_Name='Auto LWP Leave'
			end
			
		--Added by Gadriwala Muslim 10062015 -End	
		IF not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Monthly base get reimbursement claim amount')
			BEGIN 
				select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
				Insert into T0040_SETTING values(@setting_id_max,@Cmp_ID,'Monthly base get reimbursement claim amount',0
				,'1 for Monthly base get reimbursement claim amount','Reimbursement Settings','Monthly base get reimbursement claim amount',NULL)	
			END	
		
		-------------------------- Prakash Patel 05012014 -----------------------------------------------------------------------
----------------------------Timesheet Setting Start ---------------------------------------------------------------------
		IF not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Timesheet Type (Daily or Weekly)')
			BEGIN 
				select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
				Insert into T0040_SETTING 
				values(@setting_id_max,@Cmp_ID,'Timesheet Type (Daily or Weekly)',0
				,'0 for Daily and 1 for Weekly Timesheet','Timesheet Settings','Timesheet Type (Daily or Weekly)',NULL)	
			END
		Else
			BEGIN
				select @setting_id_max = (Select Setting_ID from T0040_SETTING 
				where Cmp_ID = @Cmp_ID and Setting_Name='Timesheet Type (Daily or Weekly)')
				Update T0040_SETTING Set Comment = '0 for Daily and 1 for Weekly Timesheet', Group_By = 'Timesheet Settings'
				 ,Alias='Timesheet Type (Daily or Weekly)'
				Where Setting_ID = @setting_id_max
			END
			
			
		IF not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Required Specility and Type of Services')
			BEGIN 
				select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
				Insert into T0040_SETTING 
				values(@setting_id_max,@Cmp_ID,'Required Specility and Type of Services',0
				,'0 for Comman Timesheet and 1 for Client Changes in Timesheet','Timesheet Settings','Required Speciality and Type of Services',NULL)	
			END
		Else
			BEGIN
				select @setting_id_max = (Select Setting_ID from T0040_SETTING 
				where Cmp_ID = @Cmp_ID and Setting_Name='Required Specility and Type of Services')
				Update T0040_SETTING Set Comment = '0 for Comman Timesheet and 1 for Client Changes in Timesheet', Group_By = 'Timesheet Settings' 
				,Alias = 'Required Speciality and Type of Services'
				Where Setting_ID = @setting_id_max
			END
			
		--Ankit 01052015
			IF NOT EXISTS(SELECT 1 FROM T0040_SETTING WHERE Cmp_ID=@Cmp_ID and Setting_Name='Hide Allowance Rate in Salary Slip')
				BEGIN
					SELECT @setting_id_max=ISNULL(MAX(setting_id),0) + 1 FROM T0040_SETTING
					INSERT INTO T0040_SETTING
					VALUES(@setting_id_max,@Cmp_ID,'Hide Allowance Rate in Salary Slip',0,'Hide Allowance Rate in Salary Slip','Reports','Hide Allowance Rate in Salary Slip',NULL)	
				END	
			ELSE
				BEGIN
					SELECT @setting_id_max = (SELECT Setting_ID FROM T0040_SETTING WHERE Cmp_ID = @Cmp_ID 
						and Setting_Name='Hide Allowance Rate in Salary Slip')
					UPDATE T0040_SETTING SET  Group_By = 'Reports',
					Alias='Hide Allowance Rate in Salary Slip' WHERE Setting_ID = @setting_id_max
				END	
			--Ankit 01052015
					
	--------- Added by Ramiz on 07/07/2015 ---------------------
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Admin Side Default Salary Slip Format')
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING values(@setting_id_max,@Cmp_ID,'Admin Side Default Salary Slip Format',0
			,'Enter the Format Number which you want to Generate as default','Reports','Admin Side Default Salary Slip Format',NULL)	
		end	
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Admin Side Default Salary Slip Format')
			Update T0040_SETTING Set Comment = 'Enter the Format Number which you want to Generate as default', Group_By = 'Reports' 
			,alias = 'Admin Side Default Salary Slip Format'
			Where Setting_ID = @setting_id_max
		End
		
		--------- Ended by Ramiz on 07/07/2015 --------------------
	
	
	--ADDED BY Nimesh 29-Jul-2015 (To display leave detail by financial year or Calendar year)
	SET @setting_id_max = NULL;
	SET @setting_id_max = (SELECT Setting_ID FROM T0040_SETTING WHERE Cmp_ID = @Cmp_ID 
				AND Setting_Name='Display Leave Detail by Selected Period')
	IF @setting_id_max IS NULL 
		BEGIN
			SELECT	@Setting_ID_max=ISNULL(MAX(Setting_ID),0) + 1 
			FROM	T0040_SETTING			
			
			INSERT	INTO T0040_SETTING
				VALUES(@Setting_ID_max,@Cmp_ID,'Display Leave Detail by Selected Period',
			   '0','Insert 1 to display leave detail by caledar year (i.e. the leave transactions will be taken from 1st Jan to 31st Dec), Insert 2 for financial year wise or leave 0 to display leave as on date in Leave Application/Approval.',
			   'Leave Settings',
			   'Display Leave Detail by Selected Period',NULL)
		END 
	ELSE
		BEGIN
			Update T0040_SETTING Set Group_By = 'Leave Settings'
			,Alias='Display Leave Detail by Selected Period'
			,Comment='Insert 1 to display leave detail by caledar year (i.e. the leave transactions will be taken from 1st Jan to 31st Dec), Insert 2 for financial year wise or leave 0 to display leave as on date in Leave Application/Approval.'
			 Where Setting_ID = @setting_id_max	
		END
	--END OF LEAVE DETAIL SETTING
	--------- Added by Ramiz on 10/08/2015 ---------------------
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Include Leave Details in Salary Slip')
		begin
		
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING values(@setting_id_max,@Cmp_ID,'Include Leave Details in Salary Slip',0
			,'Enter 1 if you want to Display Leave Details in Salary Slip','Reports','Include Leave Details in Salary Slip',NULL)	
		end	
	Else
		Begin
		
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Include Leave Details in Salary Slip')
			Update T0040_SETTING Set Comment = 'Enter 1 if you want to Display Leave Details in Salary Slip', Group_By = 'Reports' 
			,alias = 'Include Leave Details in Salary Slip'
			Where Setting_ID = @setting_id_max
		End
		
		--------- Ended by Ramiz on 10/08/2015 --------------------
		
 
				--------- Added by Ramiz on 02/09/2015 ---------------------
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Show Birthday Reminder Group Company wise')
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING values(@setting_id_max,@Cmp_ID,'Show Birthday Reminder Group Company wise',0
			,'If you want to Show Group Companies in Birthday Reminder','Employee Settings','Show Birthday Reminder Group Company wise',NULL)	
		end	
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Show Birthday Reminder Group Company wise')
			Update T0040_SETTING Set Comment = 'If you want to Show Group Companies in Birthday Reminder', Group_By = 'Employee Settings' 
			,alias = 'Show Birthday Reminder Group Company wise'
			Where Setting_ID = @setting_id_max
		End
		
		--------- Ended by Ramiz on 02/09/2015 --------------------
		
		----------added jimit 06012016-------------
		
		if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Show New Joining Details for All Group Company wise on Dashboard')
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING values(@setting_id_max,@Cmp_ID,'Show New Joining Details for All Group Company wise on Dashboard',0
			,'If you want to Show New Joining Details Group Company wise','Employee Settings','Show New Joining Details for All Group Company wise on Dashboard',NULL)	
		end	
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Show New Joining Details for All Group Company wise on Dashboard')
			Update T0040_SETTING Set Comment = 'If you want to Show New Joining Details Group Company wise', Group_By = 'Employee Settings' 
			,alias = 'Show New Joining Details for All Group Company wise on Dashboard'
			Where Setting_ID = @setting_id_max
		End
		
		---------ended-------------------------
		
		
		----------added jimit 20052016-------------
		
		if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Minimum Character for Leave Reason')
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING values(@setting_id_max,@Cmp_ID,'Minimum Character for Leave Reason',0
			,'Enter Minimum Character for Leave Reason.For Ex. if Minimum Character set to 22 then minimum characters require in reason is 22.','Leave Settings','Minimum Character for Leave Reason',NULL)	
		end	
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Minimum Character for Leave Reason')
			Update T0040_SETTING Set Comment = 'Enter Minimum Character for Leave Reason.For Ex. if Minimum Character set to 22 then minimum characters require in reason is 22.', Group_By = 'Leave Settings' 
			,alias = 'Minimum Character for Leave Reason'
			Where Setting_ID = @setting_id_max
		End
		
		---------ended-------------------------
		
		
	--Ankit 24092015
	IF NOT EXISTS(SELECT 1 FROM T0040_SETTING WHERE Cmp_ID=@Cmp_ID and Setting_Name='Round Loan Interest Amount')
		BEGIN
			SELECT @setting_id_max=ISNULL(MAX(setting_id),0) + 1 FROM T0040_SETTING
			INSERT INTO T0040_SETTING
			VALUES(@setting_id_max,@Cmp_ID,'Round Loan Interest Amount',0,'Round Loan Interest Amount','Other Settings','Round Loan Interest Amount',NULL)	
		END	
	ELSE
		BEGIN
			SELECT @setting_id_max = (SELECT Setting_ID FROM T0040_SETTING WHERE Cmp_ID = @Cmp_ID and Setting_Name='Round Loan Interest Amount')
			UPDATE T0040_SETTING SET  Group_By = 'Other Settings',Alias='Round Loan Interest Amount' WHERE Setting_ID = @setting_id_max
		END	
	--Ankit 24092015
	
	--Nilesh Patel on 18012016--Start
	IF NOT EXISTS(SELECT 1 FROM T0040_SETTING WHERE Cmp_ID=@Cmp_ID and Setting_Name='Show Loan Details Grade wise')
		BEGIN
			SELECT @setting_id_max=ISNULL(MAX(setting_id),0) + 1 FROM T0040_SETTING
			INSERT INTO T0040_SETTING
			VALUES(@setting_id_max,@Cmp_ID,'Show Loan Details Grade wise',0,'Set 1 if you want to assign & show loan grade wise other set 0','Other Settings','Show Loan Details Grade wise',NULL)	
		END	
	ELSE
		BEGIN
			SELECT @setting_id_max = (SELECT Setting_ID FROM T0040_SETTING WHERE Cmp_ID = @Cmp_ID and Setting_Name='Show Loan Details Grade wise')
			UPDATE T0040_SETTING SET  Group_By = 'Other Settings',Alias='Show Loan Details Grade wise' WHERE Setting_ID = @setting_id_max
		END	
	--Nilesh Patel on 18012016--End
	
	--Nilesh Patel on 04042016--Start
	IF NOT EXISTS(SELECT 1 FROM T0040_SETTING WHERE Cmp_ID=@Cmp_ID and Setting_Name='Restrict other master creation when Emplyee Master Import')
		BEGIN
			SELECT @setting_id_max=ISNULL(MAX(setting_id),0) + 1 FROM T0040_SETTING
			INSERT INTO T0040_SETTING
			VALUES(@setting_id_max,@Cmp_ID,'Restrict other master creation when Emplyee Master Import',0,'Set 1 if you want to create other master at time of Employee Import otherwise set 0','Other Settings','Restrict other master creation when Emplyee Master Import',NULL)	
		END	
	ELSE
		BEGIN
			SELECT @setting_id_max = (SELECT Setting_ID FROM T0040_SETTING WHERE Cmp_ID = @Cmp_ID and Setting_Name='Restrict other master creation when Emplyee Master Import')
			UPDATE T0040_SETTING SET  Group_By = 'Other Settings',Alias='Restrict other master creation when Emplyee Master Import' WHERE Setting_ID = @setting_id_max
		END	
	--Nilesh Patel on 04042016--End
	
	--Nilesh Patel on 06052016--Start
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Hide Employee Details Caption on Dashboard(ESS)')
		begin
			select @Setting_ID_max=isnull(max(Setting_ID),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING(Setting_ID,Cmp_ID,Setting_Name,Setting_Value,Comment,Group_By,Alias,Module_Name)
			                   values(@Setting_ID_max,@Cmp_ID,'Hide Employee Details Caption on Dashboard(ESS)',0,'Set 0 For Show Employee Details Caption on Employee Profile(ESS) otherwise Set 1','Employee Settings','Hide Employee Details Caption on Dashboard(ESS)',NULL)
		end
	Else
		Begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Hide Employee Details Caption on Dashboard(ESS)')
			Update T0040_SETTING Set Group_By = 'Employee Settings',Alias='Hide Employee Details Caption on Dashboard(ESS)' Where Setting_ID = @setting_id_max 
		End
	--Nilesh Patel on 06052016--End
	
	--Nilesh Patel on 05042016--Start
	IF NOT EXISTS(SELECT 1 FROM T0040_SETTING WHERE Cmp_ID=@Cmp_ID and Setting_Name='Disable Employee Code,Date of Joining & PF No when Employee Creation from Employee Master')
		BEGIN
			SELECT @setting_id_max=ISNULL(MAX(setting_id),0) + 1 FROM T0040_SETTING
			INSERT INTO T0040_SETTING
			VALUES(@setting_id_max,@Cmp_ID,'Disable Employee Code,Date of Joining & PF No when Employee Creation from Employee Master',0,'Set 1 for Disable Employee Code,Date of join,PF No in Employee Master otherwise set 0','Employee Settings','Disable Employee Code,Date of Joining & PF No when Employee Creation from Employee Master',NULL)	
		END	
	ELSE
		BEGIN
			SELECT @setting_id_max = (SELECT Setting_ID FROM T0040_SETTING WHERE Cmp_ID = @Cmp_ID and Setting_Name='Disable Employee Code,Date of Joining & PF No when Employee Creation from Employee Master')
			UPDATE T0040_SETTING SET  Group_By = 'Employee Settings',Alias='Disable Employee Code,Date of Joining & PF No when Employee Creation from Employee Master' WHERE Setting_ID = @setting_id_max
		END	
	--Nilesh Patel on 05042016--End
	
	--Nilesh Patel on 05032016--Start
	IF NOT EXISTS(SELECT 1 FROM T0040_SETTING WHERE Cmp_ID=@Cmp_ID and Setting_Name='In F&F, Disable Leave Encash Days Validation')
		BEGIN
			SELECT @setting_id_max=ISNULL(MAX(setting_id),0) + 1 FROM T0040_SETTING
			INSERT INTO T0040_SETTING
			VALUES(@setting_id_max,@Cmp_ID,'In F&F, Disable Leave Encash Days Validation',0,'Set 1 if for disable leave encash days validation other set 0','Other Settings','In F&F, Disable Leave Encash Days Validation','PAYROLL')	
		END	
	ELSE
		BEGIN
			SELECT @setting_id_max = (SELECT Setting_ID FROM T0040_SETTING WHERE Cmp_ID = @Cmp_ID and Setting_Name='In F&F, Disable Leave Encash Days Validation')
			UPDATE T0040_SETTING SET  Group_By = 'Other Settings',Alias='In F&F, Disable Leave Encash Days Validation' WHERE Setting_ID = @setting_id_max
		END	
	--Nilesh Patel on 05032016--End
		
		--Added by Gadriwala Muslim 14-09-2015 - Start
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Auto Credit one Medical Leave when First time ESIC Leave have Approved in Year')
		begin
		
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING values(@setting_id_max,@Cmp_ID,'Auto credit one medical leave when first time ESIC leave have approved in year',0
			,'Enter 1 if you want to auto credit one medical leave when first time ESIC leave have approved in year','Leave Settings','Auto credit one medical leave when first time ESIC leave have approved in year',NULL)	
		end	
	Else
		Begin
		
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='Auto credit one medical leave when first time ESIC leave have approved in year')
			Update T0040_SETTING Set Comment = 'Enter 1 if you want to auto credit one medical leave when first time ESIC leave have approved in year', Group_By = 'Leave Settings' 
			,alias = 'Auto credit one medical leave when first time ESIC leave have approved in year'
			Where Setting_ID = @setting_id_max
		End
	--Added by Gadriwala Muslim 14-09-2015 - End
	
	--'' Ankit 09102015
	IF NOT EXISTS(SELECT 1 FROM T0040_SETTING WHERE Cmp_ID=@Cmp_ID and Setting_Name='Display Actual Birth Date')
		BEGIN
			SELECT @setting_id_max=ISNULL(MAX(setting_id),0) + 1 FROM T0040_SETTING
			INSERT INTO T0040_SETTING 
			VALUES(@setting_id_max,@Cmp_ID,'Display Actual Birth Date',0,'Display Employee Actual Birth Date(Employee Master ==>Personal Detail)','Employee Settings','Display Actual Birth Date',NULL)
		END	
	ELSE
		BEGIN
			SELECT @setting_id_max = (SELECT Setting_ID FROM T0040_SETTING WHERE Cmp_ID = @Cmp_ID AND Setting_Name='Display Actual Birth Date')
			UPDATE T0040_SETTING 
			SET Comment = 'Display Employee Actual Birth Date', Group_By = 'Employee Settings' ,ALIAS = 'Display Actual Birth Date'
			WHERE Setting_ID = @setting_id_max
		END
		
	
	--Added by Nimesh on 27-Jan-2016 
	SET @SETTING_NAME = 'Auto Generate Employee PF Number'
	SET @ALIAS = 'Auto Generate Employee PF Number'
	SET @TOOLTIP = 'If you want to generate the Employee PF Number automatically then enter "1" as the setting value otherwise leave "0" for manual PF No.'
	SET @GROUP_NAME = 'Employee Settings'
	
	IF NOT EXISTS(SELECT 1 FROM T0040_SETTING WHERE Cmp_ID=@Cmp_ID and Setting_Name=@SETTING_NAME)
		BEGIN
			SELECT @setting_id_max=ISNULL(MAX(setting_id),0) + 1 FROM T0040_SETTING			
			INSERT INTO T0040_SETTING
			VALUES(@setting_id_max,@Cmp_ID,@SETTING_NAME,1,@TOOLTIP,@GROUP_NAME,@ALIAS,'PAYROLL')	
		END	
	ELSE
		BEGIN			
			UPDATE T0040_SETTING SET  Group_By = @GROUP_NAME,Alias=@SETTING_NAME,Comment=@TOOLTIP WHERE Cmp_ID=@Cmp_ID and Setting_Name=@SETTING_NAME
		END	
	--NIMESH 27-JAN-2016
		
		
	IF NOT EXISTS(SELECT 1 FROM T0040_SETTING WHERE Cmp_ID=@Cmp_ID and Setting_Name='Disable Tax Free Checkbox')
		BEGIN
			SELECT @setting_id_max=ISNULL(MAX(setting_id),0) + 1 FROM T0040_SETTING
			INSERT INTO T0040_SETTING 
			VALUES(@setting_id_max,@Cmp_ID,'Disable Tax Free Checkbox',0,'Disable Tax Free Checkbox in Reimbursement Application and Approval','Reimbursement Settings','Disable Tax Free Checkbox',NULL)
		END	
	ELSE
		BEGIN
			SELECT @setting_id_max = (SELECT Setting_ID FROM T0040_SETTING WHERE Cmp_ID = @Cmp_ID AND Setting_Name='Disable Tax Free Checkbox')
			UPDATE T0040_SETTING 
			SET Comment = 'Disable Tax Free Checkbox in Reimbursement Application and Approval', Group_By = 'Reimbursement Settings' ,ALIAS = 'Disable Tax Free Checkbox'
			WHERE Setting_ID = @setting_id_max
		END		
	-- Starts By Ramiz 19/10/2015
	IF NOT EXISTS(SELECT 1 FROM T0040_SETTING WHERE Cmp_ID=@Cmp_ID and Setting_Name='Show Gradewise Salary Textbox in Grade Master')
		BEGIN
			SELECT @setting_id_max=ISNULL(MAX(setting_id),0) + 1 FROM T0040_SETTING
			INSERT INTO T0040_SETTING 
			VALUES(@setting_id_max,@Cmp_ID,'Show Gradewise Salary Textbox in Grade Master',0,'Show Gradewise Salary Textbox in Grade Master','Other Settings','Show Gradewise Salary Textbox in Grade Master',NULL)
		END	
	ELSE
		BEGIN
			SELECT @setting_id_max = (SELECT Setting_ID FROM T0040_SETTING WHERE Cmp_ID = @Cmp_ID AND Setting_Name='Show Gradewise Salary Textbox in Grade Master')
			UPDATE T0040_SETTING 
			SET Comment = 'Show Gradewise Salary Textbox in Grade Master', Group_By = 'Other Settings' ,ALIAS = 'Show Gradewise Salary Textbox in Grade Master'
			WHERE Setting_ID = @setting_id_max
		END
	-- Ends By Ramiz on 19/10/2015
	
	
	-- Added by rohit on 29102015
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='How Many Decimal In Allowance')
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING 
			values(@setting_id_max,@Cmp_ID,'How Many Decimal In Allowance',2
			,'option for How many decimal Value Shows in the Allowance.like 2 decimal means 18.00 and 3 decimal means 18.000 and Max Is 4 Decimal only','Salary Settings','No of Decimal In Salary Allowance',NULL)	
		end	
	
	-- Ended by rohit on 29102015
	
	--Nilesh Patel on 20012016--Start
	IF NOT EXISTS(SELECT 1 FROM T0040_SETTING WHERE Cmp_ID=@Cmp_ID and Setting_Name='Default Checked Arrear Day Checkbox in Leave Approval')
		BEGIN
			SELECT @setting_id_max=ISNULL(MAX(setting_id),0) + 1 FROM T0040_SETTING
			INSERT INTO T0040_SETTING
			VALUES(@setting_id_max,@Cmp_ID,'Default Checked Arrear Day Checkbox in Leave Approval',1,'if you want checked of Arrear day set value 1 otherwise set 0','Leave Settings','Default Checked Arrear Day Checkbox in Leave Approval',NULL)	
		END	
	ELSE
		BEGIN
			SELECT @setting_id_max = (SELECT Setting_ID FROM T0040_SETTING WHERE Cmp_ID = @Cmp_ID and Setting_Name='Default Checked Arrear Day Checkbox in Leave Approval')
			UPDATE T0040_SETTING SET  Group_By = 'Leave Settings',Alias='Default Checked Arrear Day Checkbox in Leave Approval' WHERE Setting_ID = @setting_id_max
		END	
	--Nilesh Patel on 20012016--End
	
	--Nilesh Patel on 09022016--Start
	IF NOT EXISTS(SELECT 1 FROM T0040_SETTING WHERE Cmp_ID=@Cmp_ID and Setting_Name='Advance Leave balance assign from Employee Master')
		BEGIN
			SELECT @setting_id_max=ISNULL(MAX(setting_id),0) + 1 FROM T0040_SETTING
			INSERT INTO T0040_SETTING
			VALUES(@setting_id_max,@Cmp_ID,'Advance Leave balance assign from Employee Master',0,'Set 1 value for assign Advance Leave From Employee Master otherwise set 0','Employee Settings','Advance Leave balance assign from Employee Master','PAYROLL')	
		END	
	ELSE
		BEGIN
			SELECT @setting_id_max = (SELECT Setting_ID FROM T0040_SETTING WHERE Cmp_ID = @Cmp_ID and Setting_Name='Advance Leave balance assign from Employee Master')
			UPDATE T0040_SETTING SET  Group_By = 'Employee Settings',Alias='Advance Leave balance assign from Employee Master' WHERE Setting_ID = @setting_id_max
		END	
	--Nilesh Patel on 09022016--End
	
	--Ankit 17032016--Start /* Aculife Client */
	IF NOT EXISTS(SELECT 1 FROM T0040_SETTING WHERE Cmp_ID=@Cmp_ID and Setting_Name='Reverse Current WO/HO Cancel Policy')
		BEGIN
			SELECT @setting_id_max=ISNULL(MAX(setting_id),0) + 1 FROM T0040_SETTING
			INSERT INTO T0040_SETTING
			VALUES(@setting_id_max,@Cmp_ID,'Reverse Current WO/HO Cancel Policy',0,
				'if value is 0 then If Leave taken before or After WO/HO then WO/HO will be Cancel,  if value is 1 then If Leave has unticked WO/HO as Leave in Leave master, and taken same leave before and after WO/HO then only WO/HO will not cancel',
				'Leave Settings','Reverse Current WO/HO Cancel Policy',NULL)	
		END	
	ELSE
		BEGIN
			SELECT @setting_id_max = (SELECT Setting_ID FROM T0040_SETTING WHERE Cmp_ID = @Cmp_ID and Setting_Name='Reverse Current WO/HO Cancel Policy')
			UPDATE T0040_SETTING SET  Group_By = 'Leave Settings',Alias='Reverse Current WO/HO Cancel Policy' WHERE Setting_ID = @setting_id_max
		END	
	
	IF NOT EXISTS(SELECT 1 FROM T0040_SETTING WHERE Cmp_ID=@Cmp_ID and Setting_Name='Hide Leave Balance in Leave Application/Approval')
		BEGIN
			SELECT @setting_id_max=ISNULL(MAX(setting_id),0) + 1 FROM T0040_SETTING
			INSERT INTO T0040_SETTING
			VALUES(@setting_id_max,@Cmp_ID,'Hide Leave Balance in Leave Application/Approval',0,
				'Hide Leave Balance Panel in Leave Application/Approval','Leave Settings','Hide Leave Balance in Leave Application/Approval',NULL)	
		END	
	ELSE
		BEGIN
			SELECT @setting_id_max = (SELECT Setting_ID FROM T0040_SETTING WHERE Cmp_ID = @Cmp_ID and Setting_Name='Hide Leave Balance in Leave Application/Approval')
			UPDATE T0040_SETTING SET  Group_By = 'Leave Settings',Alias='Hide Leave Balance in Leave Application/Approval' WHERE Setting_ID = @setting_id_max
		END
		
	IF NOT EXISTS(SELECT 1 FROM T0040_SETTING WHERE Cmp_ID=@Cmp_ID and Setting_Name='Disable Guarantor Validation in Loan Application/Approval')
		BEGIN
			SELECT @setting_id_max=ISNULL(MAX(setting_id),0) + 1 FROM T0040_SETTING
			INSERT INTO T0040_SETTING
			VALUES(@setting_id_max,@Cmp_ID,'Disable Guarantor Validation in Loan Application/Approval',0,'Disable Guarantor Validation in Loan Application/Approval','Other Settings','Disable Guarantor Validation in Loan Application/Approval',NULL)	
		END			
	--Ankit --End
	
--Mukti(start)08042016
	IF NOT EXISTS(SELECT 1 FROM T0040_SETTING WHERE Cmp_ID=@Cmp_ID and Setting_Name='Show Work Anniversary Reminder on Dashboard')
		BEGIN
			SELECT @setting_id_max=ISNULL(MAX(setting_id),0) + 1 FROM T0040_SETTING
			INSERT INTO T0040_SETTING
			VALUES(@setting_id_max,@Cmp_ID,'Show Work Anniversary Reminder on Dashboard',0,'Set 1 if you want to show work anniversary details else set 0','Other Settings','Show Work Anniversary Reminder on Dashboard',NULL)	
		END	
--Mukti(end)08042016
	
		---Hardik 15/04/2016 added option for Reimbursement claim amount validate on employee's Yearly Limit (Monthly reimbursement amount x 12) for Client : G&D
		IF NOT EXISTS(SELECT 1 FROM T0040_SETTING WHERE Cmp_ID=@Cmp_ID and Setting_Name='Restrict Reim. Application Amount on Yearly Prorata Limit')
			BEGIN
				SELECT @setting_id_max=ISNULL(MAX(setting_id),0) + 1 FROM T0040_SETTING
				INSERT INTO T0040_SETTING 
				VALUES(@setting_id_max,@Cmp_ID,'Restrict Reim. Application Amount on Yearly Prorata Limit',0,'If 1 then Reimbursment Application Amount will not allow beyond Yearly Prorata Limit, If 0 then Application Amount will check Max Limit from Allowance Master','Reimbursement Settings','Restrict Reim. Application Amount on Yearly Prorata Limit',NULL)
			END	
		ELSE
			BEGIN
				SELECT @setting_id_max = (SELECT Setting_ID FROM T0040_SETTING WHERE Cmp_ID = @Cmp_ID AND Setting_Name='Restrict Reim. Application Amount on Yearly Prorata Limit')
				UPDATE T0040_SETTING 
				SET Comment = 'If 1 then Reimbursment Application Amount will not allow beyond Yearly Prorata Limit, If 0 then Application Amount will check Max Limit from Allowance Master', Group_By = 'Reimbursement Settings' ,ALIAS = 'Restrict Reim. Application Amount on Yearly Prorata Limit'
				WHERE Setting_ID = @setting_id_max
			END		
			
			-- Starts By Ramiz 09/05/2016
			IF NOT EXISTS(SELECT 1 FROM T0040_SETTING WHERE Cmp_ID=@Cmp_ID and Setting_Name='Auto Calculate CTC Amount during Salary Structure Assigning or Changing')
				BEGIN
					SELECT @setting_id_max=ISNULL(MAX(setting_id),0) + 1 FROM T0040_SETTING
					INSERT INTO T0040_SETTING 
					VALUES(@setting_id_max,@Cmp_ID,'Auto Calculate CTC Amount during Salary Structure Assigning or Changing',0,'Auto Calculate CTC Amount during Salary Structure Assigning or Changing','Salary Settings','Auto Calculate CTC Amount during Salary Structure Assigning or Changing',NULL)
				END	
			ELSE
				BEGIN
					SELECT @setting_id_max = (SELECT Setting_ID FROM T0040_SETTING WHERE Cmp_ID = @Cmp_ID AND Setting_Name='Auto Calculate CTC Amount during Salary Structure Assigning or Changing')
					UPDATE T0040_SETTING 
					SET Comment = 'Auto Calculate CTC Amount during Salary Structure Assigning or Changing', Group_By = 'Salary Settings' ,ALIAS = 'Auto Calculate CTC Amount during Salary Structure Assigning or Changing'
					WHERE Setting_ID = @setting_id_max
				END
			-- Ends By Ramiz on 09/05/2016
	
			--Ankit 10052016
			IF NOT EXISTS(SELECT 1 FROM T0040_SETTING WHERE Cmp_ID=@Cmp_ID and Setting_Name='Gratuity Amount Hide In FNF Letter')
				BEGIN
					SELECT @setting_id_max=ISNULL(MAX(setting_id),0) + 1 FROM T0040_SETTING
					INSERT INTO T0040_SETTING 
					VALUES(@setting_id_max,@Cmp_ID,'Gratuity Amount Hide In FNF Letter',0,'Gratuity Amount Hide In FNF Letter','Salary Settings','Gratuity Amount Hide In FNF Letter',NULL)
				END
			
			--Ankit 03062016	
			IF NOT EXISTS(SELECT 1 FROM T0040_SETTING WHERE Cmp_ID=@Cmp_ID AND Setting_Name='Bonus Detail - Salary Arear Amount Calculated In Arear Month')
				BEGIN
					SELECT @setting_id_max=ISNULL(MAX(setting_id),0) + 1 FROM T0040_SETTING
					INSERT INTO T0040_SETTING 
					VALUES(@setting_id_max,@Cmp_ID,'Bonus Detail - Salary Arear Amount Calculated In Arear Month',0,'Bonus Detail - Salary Arear Amount Calculated In Arear Month','Salary Settings','Bonus Detail - Salary Arear Amount Calculated In Arear Month',NULL)
				END	
				
	--Mukti 17052016(start)
	IF NOT EXISTS(SELECT 1 FROM T0040_SETTING WHERE Cmp_ID=@Cmp_ID and Setting_Name='Restrict Self Leave Approval if Admin rights assigned ')
		BEGIN
			SELECT @setting_id_max=ISNULL(MAX(setting_id),0) + 1 FROM T0040_SETTING
			INSERT INTO T0040_SETTING
			VALUES(@setting_id_max,@Cmp_ID,'Restrict Self Leave Approval if Admin rights assigned ',0,'Set 1 for Restriction of self Approval Leave if admin rights assigned else set 0 Ex.Employee cannot approve his own leave in Leave Approval form','Leave Settings','Restrict Self Leave Approval if Admin rights assigned ',NULL)	
		END	
	ELSE
		BEGIN
			SELECT @setting_id_max = (SELECT Setting_ID FROM T0040_SETTING WHERE Cmp_ID = @Cmp_ID and Setting_Name='Restrict Self Leave Approval if Admin rights assigned ')
			UPDATE T0040_SETTING SET  Group_By = 'Leave Settings',Alias='Restrict Self Leave Approval if Admin rights assigned ' WHERE Setting_ID = @setting_id_max
		END	
	--Mukti 17052016(end)

	--Added by Hardik 15/06/2016
	if not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='In and Out Punch depends on Device In-Out Flag')
		begin
			select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
			Insert into T0040_SETTING 
			values(@setting_id_max,@Cmp_ID,'In and Out Punch depends on Device In-Out Flag',0,'Set 1 if In Out Punch depends on Device In-Out Flag Else Set 2 if Shift Start from 12 AM Else 0 for Regular Synchronise','Attendance Settings'
			,'In and Out Punch depends on Device In-Out Flag',NULL)	
		end	
	else
		begin
			select @setting_id_max = (Select Setting_ID from T0040_SETTING where Cmp_ID = @Cmp_ID 
			and Setting_Name='In and Out Punch depends on Device In-Out Flag')
			 
			Update T0040_SETTING Set  Group_By = 'Attendance Settings'
			,Alias='In and Out Punch depends on Device In-Out Flag' 
			Where Setting_ID = @setting_id_max
		end		
		
	--Added Ankit 30062016
	IF NOT EXISTS(SELECT 1 FROM T0040_SETTING WHERE Cmp_ID=@Cmp_ID AND Setting_Name='Direct Login to ESS Portal')
		BEGIN
			SELECT @setting_id_max=ISNULL(MAX(setting_id),0) + 1 FROM T0040_SETTING
			INSERT INTO T0040_SETTING 
			VALUES(@setting_id_max,@Cmp_ID,'Direct Login to ESS Portal',1,'Set 1 If Admin/Ess Employee Privileges User Directly Login to Ess Portal else Set 0 User Directly Login to Admin Portal','Other Settings'
			,'Direct Login to ESS Portal',NULL)	
		END	
	ELSE
		BEGIN
			SELECT @setting_id_max = (SELECT Setting_ID FROM T0040_SETTING WHERE Cmp_ID = @Cmp_ID and Setting_Name='Direct Login to ESS Portal')
			 
			UPDATE T0040_SETTING SET  Group_By = 'Other Settings',ALIAS='Direct Login to ESS Portal' 
			WHERE Setting_ID = @setting_id_max
		END			
		
		
 --------------------setting end-----------------------------			
			
    if not exists(Select 1 from T0040_LEAVE_MASTER where Cmp_ID=@Cmp_ID and Default_Short_Name='LWP')
		begin
			--Alpesh 07-Apr-2012 -> Default Leave LWP
			exec [P0040_LEAVE_MASTER] 0,@Cmp_ID,'LWP','LWP','--',0,'U',0,0,0,0,0,0,0,0,'None',0,0,'M',0,'Ins',0,1,0,0,0,0,0,1,0,1,0,0,1,1,0,0,0,0,'LWP'
		end
		
    if not exists(Select 1 from T0040_LEAVE_MASTER where Cmp_ID=@Cmp_ID and Default_Short_Name='COMP')
		begin
			--Trivedi 17-May-2012 -> Default Leave Comp-off
			exec [P0040_LEAVE_MASTER] 0,@Cmp_ID,'COMP','Comp-Off Leave','--',0,'P',0,0,0,0,0,0,0,0,'None',0,0,'M',0,'Ins',0,0,0,0,0,0,0,1,0,1,0,0,1,1,0,0,0,0,'COMP'
		end
	
	--Alpesh 21-May-2012 -> T0050_Leave_Detail
	declare @Chk_Leave_ID numeric(18,0)
	set  @Chk_Leave_ID = 0
	Select @Chk_Leave_ID = Leave_ID from T0040_LEAVE_MASTER where Cmp_ID=@Cmp_ID and Default_Short_Name='COMP'
	if not exists(Select 1 from T0050_LEAVE_DETAIL where Cmp_ID=@Cmp_ID and Leave_ID=@Chk_Leave_ID)
		begin
		
			Declare @Leave_ID	numeric(18,0)
			Declare @Grd_ID		numeric(18,0)
		    
			Declare cur cursor for Select Grd_ID from T0040_GRADE_MASTER where Cmp_ID = @Cmp_ID 
			Open cur
			Fetch Next From cur into @Grd_ID
		    
			While @@FETCH_STATUS = 0
				Begin
					If exists(Select 1 from T0040_LEAVE_MASTER where Cmp_ID=@Cmp_ID and Default_Short_Name='LWP')
						Begin					
							Select @Leave_ID = Leave_ID from T0040_LEAVE_MASTER where Cmp_ID=@Cmp_ID and Default_Short_Name='LWP'
							exec [P0050_LEAVE_DETAIL] 0,@Leave_ID,@Grd_ID,@Cmp_ID,0,'Ins'			
						End 
						
					If exists(Select 1 from T0040_LEAVE_MASTER where Cmp_ID=@Cmp_ID and Default_Short_Name='COMP')
						Begin	
							
									Select @Leave_ID = Leave_ID from T0040_LEAVE_MASTER where Cmp_ID=@Cmp_ID and Default_Short_Name='COMP'
									exec [P0050_LEAVE_DETAIL] 0,@Leave_ID,@Grd_ID,@Cmp_ID,0,'Ins'	
						 
						End 
				
					Fetch Next From cur into @Grd_ID
				End
				
			Close cur
			Deallocate cur
			---- End ----
	
		end
		
		--added on 07 Aug 2015 sneha
	 if not exists(Select 1 from T0030_Hrms_Training_Type where Cmp_ID=@Cmp_ID and Training_TypeName='External')
		begin
			exec P0030_Hrms_Training_Type 0,@Cmp_ID,'External','I'
		end
	 if not exists(Select 1 from T0030_Hrms_Training_Type where Cmp_ID=@Cmp_ID and Training_TypeName='Internal')
		begin
			exec P0030_Hrms_Training_Type 0,@Cmp_ID,'Internal','I'
		end
	--ended on  07 Aug 2015 sneha
	
	-- Caption Start --
		--if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID)
		--	begin
		--			declare @capTran_id numeric
		--			select @capTran_id = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
					
		--			INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo])
		--				SELECT @capTran_id + 1, @Cmp_ID, N'Category', N'Category', 1 UNION ALL
		--				SELECT @capTran_id + 2, @Cmp_ID, N'DBRD Code', N'DBRD Code', 2 UNION ALL
		--				SELECT @capTran_id + 3, @Cmp_ID, N'Dealer Code', N'Dealer Code', 3
		--	end
			
		-- if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='Branch')
		--	begin
		--			declare @capTran_id1 numeric
		--			select @capTran_id1 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
					
		--			INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo])
		--				SELECT @capTran_id1 + 1, @Cmp_ID, N'Branch', N'Branch',4 
						 
		--	end		
		
		--Start Add By Paras 22042013
			 if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='Category')
			begin
					declare @capTran_id numeric
		 			select @capTran_id = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id + 1, @Cmp_ID, N'Category', N'Category', 1,N'Category Master' 
			 end	
			 else
			 begin
			       update T0040_CAPTION_SETTING set Remarks = N'Category Master' where Cmp_Id = @Cmp_ID and Caption='Category'
			 end
			 
			 	 if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='DBRD Code')
			begin
					declare @capTran_id_DB numeric
		 			select @capTran_id_DB = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id_DB + 2, @Cmp_ID, N'DBRD Code', N'DBRD Code', 2,N'Employee Master => Salary Details'
			 end	
			 else
				 begin
			       update T0040_CAPTION_SETTING set Remarks = N'Employee Master => Salary Details' where Cmp_Id = @Cmp_ID and Caption='DBRD Code'
				end
			 
			 	 if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='Dealer Code')
			begin
					declare @capTran_id_DE numeric
		 			select @capTran_id_DE = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id_DE + 3, @Cmp_ID, N'Dealer Code', N'Dealer Code', 3,N'Employee Master => Salary Details'
			 end	
			 else
				 begin
			       update T0040_CAPTION_SETTING set Remarks = N'Employee Master => Salary Details' where Cmp_Id = @Cmp_ID and Caption='Dealer Code'
				 end
			
			
			
		 if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='Branch')
			begin
					declare @capTran_id1 numeric
					select @capTran_id1 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id1 + 1, @Cmp_ID, N'Branch', N'Branch',4 ,N'Branch Master'
						 
			end	
			 else
			 begin
			       update T0040_CAPTION_SETTING set Remarks = N'Branch Master' where Cmp_Id = @Cmp_ID and Caption='Branch'
			 end	
			
			if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='Insurance')
			begin
					declare @capTran_id2 numeric
					select @capTran_id2 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id2 + 1, @Cmp_ID, N'Insurance', N'Insurance',5,N'Insurance Master' 
						 
			end	
			 else
			 begin
			       update T0040_CAPTION_SETTING set Remarks = N'Insurance Master' where Cmp_Id = @Cmp_ID and Caption='Insurance'
			 end	
			if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='InsuranceMenu')
			begin
					declare @capTran_id3 numeric
					select @capTran_id3 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo])
						SELECT @capTran_id3 + 1, @Cmp_ID, N'InsuranceMenu', N'InsuranceMenu',6 
						 
			end	
			--End Add By Paras 19042013
			
			--Start Add By Paras 22042013
			if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='Policy Type')
			begin
					declare @capTran_id4 numeric
					select @capTran_id4 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id4 + 1, @Cmp_ID, N'Policy Type', N'Policy Type',7,N'Employee Master => Insurance Details' 
						 
			end
			else
			 begin
			       update T0040_CAPTION_SETTING set Remarks = N'Employee Master => Insurance Details' where Cmp_Id = @Cmp_ID and Caption='Policy Type'
			 end
			 	
				if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='Company Name')
			begin
					declare @capTran_id5 numeric
					select @capTran_id5 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id5 + 1, @Cmp_ID, N'Company Name', N'Company Name',8,N'Empployee Master => Insurance Details'  
					 
			end	
			else
			  begin
			       update T0040_CAPTION_SETTING set Remarks = N'Employee Master => Insurance Details' where Cmp_Id = @Cmp_ID and Caption='Company Name'
			  end
			  
			  
				if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='Policy No')
			begin
					declare @capTran_id6 numeric
					select @capTran_id6 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id6 + 1, @Cmp_ID, N'Policy No', N'Policy No',9,N'Empployee Master => Insurance Details'  
						 
			end	
			else
			  begin
			       update T0040_CAPTION_SETTING set Remarks = N'Employee Master => Insurance Details' where Cmp_Id = @Cmp_ID and Caption='Policy No'
			  end
			
			
			
				if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='Registration Date')
			begin
					declare @capTran_id7 numeric
					select @capTran_id7 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id7 + 1, @Cmp_ID, N'Registration Date', N'Registration Date',10 ,N'Empployee Master => Insurance Details' 
						 
			end	
			else
			  begin
			       update T0040_CAPTION_SETTING set Remarks = N'Employee Master => Insurance Details' where Cmp_Id = @Cmp_ID and Caption='Registration Date'
			  end
			
			
			
				if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='Due Date')
			begin
					declare @capTran_id8 numeric
					select @capTran_id8 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id8 + 1, @Cmp_ID, N'Due Date', N'Due Date',11,N'Employee Master => Insurance Details'  
						 
			End
			else	
			 begin
			       update T0040_CAPTION_SETTING set Remarks = N'Employee Master => Insurance Details' where Cmp_Id = @Cmp_ID and Caption='Due Date'
			  end
			
			
			if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='Exp Date')
			begin
					declare @capTran_id9 numeric
					select @capTran_id9 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id9 + 1, @Cmp_ID, N'Exp Date', N'Exp Date',12,N'Empployee Master => Insurance Details'  
						 
			end	
			else	
			 begin
			       update T0040_CAPTION_SETTING set Remarks = N'Employee Master => Insurance Details' where Cmp_Id = @Cmp_ID and Caption='Exp Date'
			  end
			
			
			
				if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='Insurance Amount')
			begin
					declare @capTran_id10 numeric
					select @capTran_id10 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id10 + 1, @Cmp_ID, N'Insurance Amount', N'Insurance Amount',13,N'Empployee Master => Insurance Details'  
						 
			end
			else
			 begin
			       update T0040_CAPTION_SETTING set Remarks = N'Employee Master => Insurance Details' where Cmp_Id = @Cmp_ID and Caption='Insurance Amount'
			  end	
			
			
				if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='Annual Amount')
			begin
					declare @capTran_id11 numeric
					select @capTran_id11 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id11 + 1, @Cmp_ID, N'Annual Amount', N'Annual Amount',14,N'Empployee Master => Insurance Details'  
						 
			end	
			else
			 begin
			       update T0040_CAPTION_SETTING set Remarks = N'Employee Master => Insurance Details' where Cmp_Id = @Cmp_ID and Caption='Annual Amount'
			  end
			  -------------------------------Gadriwala Muslim on 19-7-2013--------------------------
			if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='Business Segment')
			begin
					declare @capTran_id12 numeric
					select @capTran_id12 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id12 + 1, @Cmp_ID, N'Business Segment', N'Business Segment',15,N'Business Segment Master'
						 
			end	
			  if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='Vertical')
			begin
					declare @capTran_id13 numeric
					select @capTran_id13 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id13 + 1, @Cmp_ID, N'Vertical', N'Vertical',16,N'Vertical Master'
						 
			end
			  if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='SubVertical')
			begin
					declare @capTran_id14 numeric
					select @capTran_id14 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id14 + 1, @Cmp_ID, N'SubVertical', N'SubVertical',17,N'SubVertical Master'
						 
			end
			if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='subBranch')
			begin
					declare @capTran_id15 numeric
					select @capTran_id15 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id15 + 1, @Cmp_ID, N'subBranch', N'Sub Branch',18,N'Sub Branch Master'
						 
			end
		if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='Exit')
			begin
					declare @capTran_id16 numeric
					select @capTran_id16 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id16 + 1, @Cmp_ID, N'Exit', N'Exit',18,N'Exit'
						 
			end
			--Added by Gadriwala 10012014 - Start
			if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='Direct Reporters')
			begin
					declare @capTran_id17 numeric
					select @capTran_id17 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id17 + 1, @Cmp_ID, N'Direct Reporters', N'Direct Reporters',19,N'Employee => Direct Reporters'  
						 
			end
			if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='Indirect Reporters')
			begin
					declare @capTran_id18 numeric
					select @capTran_id18 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id18 + 1, @Cmp_ID, N'Indirect Reporters', N'Indirect Reporters',19,N'Employee => Indirect Reporters'  
						 
			end
		   --Added by Gadriwala 10012014 - End
			 --sneha on 1 apr 2014
			if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='No Of Accidents')
			begin
					declare @capTran_id19 numeric
					select @capTran_id19 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id19 + 1, @Cmp_ID, N'No Of Accidents', N'No Of Accidents',19,N'No Of Accidents'  
						 
			end
			if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='No Of Person Involved')
			begin
					declare @capTran_id20 numeric
					select @capTran_id20 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id20 + 1, @Cmp_ID, N'No Of Person Involved', N'No Of Person Involved',19,N'No Of Person Involved'  
						 
			end
			--sneha on 1 apr 2014
			
			-- Added By Ali 01042014 -- Start
			if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='Canteen Code')
			begin
					declare @capTran_id21 numeric
					select @capTran_id21 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id21 + 1, @Cmp_ID, N'Canteen Code', N'Canteen Code',21,N'Employee => Canteen Code'  
						 
			end
			-- Added By Ali 01042014 -- End
			--sneha on 3 apr 2014
			if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='Title')
			begin
					declare @capTran_id22 numeric
					select @capTran_id22 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id22 + 1, @Cmp_ID, N'Title', N'Title',22,N'Title'  
						 
			end
			--sneha end on 3 apr 2014
			
			--Added By Gadriwala Muslim 15072014 - Start
			if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='Reporting Manager')
			begin
					declare @capTran_id23 numeric
					select @capTran_id23 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id23 + 1, @Cmp_ID, N'Reporting Manager', N'Reporting Manager',23,N'Reporting Manager'  
						 
			end
			if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='Grade')
			begin
					declare @capTran_id24 numeric
					select @capTran_id24 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id24 + 1, @Cmp_ID, N'Grade', N'Grade',24,N'Grade'  
						 
			end
			
			if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='Tehsil')
			begin
					declare @capTran_id25 numeric
					select @capTran_id25 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id25 + 1, @Cmp_ID, N'Tehsil', N'Tehsil',25,N'Tehsil'  
						 
			end
			Else
			begin
				update T0040_CAPTION_SETTING --Added by Sumit 29062015
				set Alias='Taluka'				
				where caption='Tehsil' and Cmp_Id=@Cmp_ID
			end
			
			if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='Thana')
			begin
					declare @capTran_id26 numeric
					select @capTran_id26 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id26 + 1, @Cmp_ID, N'Thana', N'Thana',26,N'Thana'  
						 
			end
			Else
			begin
				update T0040_CAPTION_SETTING --Added by Sumit 29062015
				set Alias='Police Station'						
				where caption='Thana' and Cmp_Id=@Cmp_ID
			end
			--Added By Gadriwala Muslim 15072014 - End
			
			--added by sneha on 27 Feb 2015 - start
				if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='Main KPI')
				begin
						declare @capTran_id27 numeric
						select @capTran_id27 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
						
						INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
							SELECT @capTran_id27 + 1, @Cmp_ID, N'Main KPI', N'Main KPI',27,N'Main KPI'  
							 
				end
				if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='Sub KPI')
				begin
						declare @capTran_id28 numeric
						select @capTran_id28 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
						
						INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
							SELECT @capTran_id28 + 1, @Cmp_ID, N'Sub KPI', N'Sub KPI',28,N'Sub KPI'  
							 
				end
				if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='KPI Attributes')
				begin
						declare @capTran_id29 numeric
						select @capTran_id29 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
						
						INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
							SELECT @capTran_id29 + 1, @Cmp_ID, N'KPI Attributes', N'KPI Attributes',29,N'KPI Attributes'  
							 
				end
			--added by sneha on 27 Feb 2015 - end
			--added by sneha on 23 Apr 2015 - start
				if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='Objectives')
				begin
						declare @capTran_id30 numeric
						select @capTran_id30 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
						
						INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
							SELECT @capTran_id30 + 1, @Cmp_ID, N'Objectives', N'Objectives',30,N'Objectives'  
							 
				end
			--added by sneha on 23 Apr 2015 - end
			
			--added by jaina on 10-08-2015 start
			if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='Employee Type')
				begin
					declare @capTran_id31 numeric
					select @capTran_id31 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id31 + 1, @Cmp_ID, N'Employee Type', N'Employee Type',31 ,N'Employee Type'
					
				end	
			else
			 begin
			       update T0040_CAPTION_SETTING set Remarks = N'Employee Type' where Cmp_Id = @Cmp_ID and Caption='Employee Type'
			 end	
			--added by jaina on 10-08-2015 end
			--Added By Ramiz on 27/11/2015
			if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='Tally Ledger Name')
				begin
					declare @capTran_id32 numeric
					select @capTran_id32 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTran_id32 + 1, @Cmp_ID, N'Tally Ledger Name', N'Tally Ledger Name',32 ,N'Tally Ledger Name'
					
				end	
			else
			 begin
			       update T0040_CAPTION_SETTING set Remarks = N'Tally Ledger Name' where Cmp_Id = @Cmp_ID and Caption='Tally Ledger Name'
			 end	
		--Added By Ramiz on 27/11/2015	
		--added By jimit 03082016
			if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='Gate Pass')
					begin
						declare @capTran_id33 numeric
						select @capTran_id33 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
						
						INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
							SELECT @capTran_id33 + 1, @Cmp_ID, N'Gate Pass', N'Gate Pass',33 ,N'Gate Pass'
						
					end	
				else
				 begin
					   update T0040_CAPTION_SETTING set Remarks = N'Gate Pass' where Cmp_Id = @Cmp_ID and Caption='Gate Pass'
				 end
		--ended
	-- Caption End --
	
	
	if not exists (select Perquisites_Id from T0240_Perquisites_Master where Cmp_Id = @Cmp_ID)
		begin
			Declare @per_tran_id as numeric
			set @per_tran_id = 0
			
			select @per_tran_id = isnull(max(Perquisites_Id),0) from T0240_Perquisites_Master
					
			INSERT INTO [dbo].[T0240_Perquisites_Master]([Perquisites_Id], [Cmp_id], [Name], [Sort_Name], [Sorting_no], [Def_id], [Remarks])
			SELECT @per_tran_id + 1, @Cmp_Id, N'Accommodation', N'RFA', 1, 0, NULL UNION ALL
			SELECT @per_tran_id + 2, @Cmp_Id, N'Cars / Other automotive', N'Car', 2, 0, NULL --UNION ALL
			--SELECT @per_tran_id + 3, @Cmp_Id, N'Sweeper, gardener, watchman or personal attendant', N'Clerk', 3, 0, NULL UNION ALL
			--SELECT @per_tran_id + 4, @Cmp_Id, N'Gas, electricity, water', N'Facilities', 4, 0, NULL UNION ALL
			--SELECT @per_tran_id + 5, @Cmp_Id, N'Interest free or concessional Loans', N'Interest', 5, 0, NULL UNION ALL
			--SELECT @per_tran_id + 6, @Cmp_Id, N'Holiday expenses', N'Holiday', 6, 0, NULL UNION ALL
			--SELECT @per_tran_id + 7, @Cmp_Id, N'Free or concessional travel', N'Travel', 7, 0, NULL UNION ALL
			--SELECT @per_tran_id + 8, @Cmp_Id, N'Free meals', N'Meals', 8, 0, NULL UNION ALL
			--SELECT @per_tran_id + 9, @Cmp_Id, N'Free Education', N'Education', 9, 0, NULL UNION ALL
			--SELECT @per_tran_id + 10, @Cmp_Id, N'Gifts, vouchers etc', N'Gift', 10, 0, NULL UNION ALL
			--SELECT @per_tran_id + 11, @Cmp_Id, N'Credit card expenses', N'Credit', 11, 0, NULL UNION ALL
			--SELECT @per_tran_id + 12, @Cmp_Id, N'Club expenses', N'Club', 12, 0, NULL UNION ALL
			--SELECT @per_tran_id + 13, @Cmp_Id, N'Use of movable assets by employees', N'Assets', 13, 0, NULL UNION ALL
			--SELECT @per_tran_id + 14, @Cmp_Id, N'Transfer of assets to employees', N'TAssets ', 14, 0, NULL UNION ALL
			--SELECT @per_tran_id + 15, @Cmp_Id, N'Value of any other benefit / amenity / service / privilege', N'Benefits', 15, 0, NULL UNION ALL
			--SELECT @per_tran_id + 16, @Cmp_Id, N'Stock options (non-qualified options)', N'Stock', 16, 0, NULL UNION ALL
			--SELECT @per_tran_id + 17, @Cmp_Id, N'Other benefits or amenities', N'Other', 17, 0, NULL
		end
		
		--EmailNotificationStart
		--	Start By Hiral 07 Nov, 2012
				If exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Attendance Regularization')
					Begin
						If exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Attendance Regulariz')
							Begin
								Delete From T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Attendance Regulariz'
							End
					End
					
				If exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Attendance Regulariz')
					Begin
						Update T0040_Email_Notification_Config Set EMAIL_TYPE_NAME = 'Attendance Regularization' where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Attendance Regulariz'
					End
		--	Start By Hiral 07 Nov, 2012
			
			if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Travel Settlement Approval')
					begin
							declare @capTranEmail2_id1 numeric
							select @capTranEmail2_id1 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
								SELECT  @capTranEmail2_id1+1, @Cmp_ID, N'Travel Settlement Approval', 0, 25, 0, 0, 0, N'' 
							
					end
				else
					begin
							UPDATE T0040_Email_Notification_Config SET  EMAIL_NTF_DEF_ID = 25 where EMAIL_TYPE_NAME = 'Travel Settlement Approval' and cmp_id = @cmp_id						
							delete T0040_Email_Notification_Config  where EMAIL_TYPE_NAME = 'Travel Settelment Approval' and cmp_id = @cmp_id						
						
					end
					
			
					
		--ALTER By Paras 20-09-2012
				if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Leave Application')
					begin
							declare @capTranEmail_id1 numeric
							select @capTranEmail_id1 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
								SELECT  @capTranEmail_id1+1, @Cmp_ID, N'Leave Application', 0, 2, 0, 0, 0, N'' 
							
					end
					
				if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Leave Approval')
					begin
							declare @capTranEmail_id2 numeric
							select @capTranEmail_id2 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
								SELECT @capTranEmail_id2 + 1, @Cmp_ID, N'Leave Approval', 0, 3, 0, 0, 0, N''
							
					end	
					
						-- Added By Gadriwala 17042014
				if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Cancel Leave Application')
					begin
							declare @capTranEmail_id23 numeric
							select @capTranEmail_id1 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
								SELECT  @capTranEmail_id1+1, @Cmp_ID, N'Cancel Leave Application', 0, 39, 0, 0, 0, N'' 
							
					end
					
				if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Cancel Leave Approval')
					begin
							declare @capTranEmail_id24 numeric
							select @capTranEmail_id2 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
								SELECT @capTranEmail_id2 + 1, @Cmp_ID, N'Cancel Leave Approval', 0, 40, 0, 0, 0, N''
							
					end	
					-- Added By Gadriwala 17042014
					
			   if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Loan Application')
					begin
							declare @capTranEmail_id3 numeric
							select @capTranEmail_id3 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
								SELECT @capTranEmail_id3 + 1, @Cmp_ID, N'Loan Application', 0, 4, 0, 0, 0, N''
							
					end	
					
					if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Loan Approval')
					begin
							declare @capTranEmail_id4 numeric
							select @capTranEmail_id4 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
								SELECT @capTranEmail_id4 + 1, @Cmp_ID, N'Loan Approval', 0, 5, 0, 0, 0, N''
							
					end	
					
						if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Loan Payment')
					begin
							declare @capTranEmail_id5 numeric
							select @capTranEmail_id5 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
								SELECT @capTranEmail_id5 + 1, @Cmp_ID, N'Loan Payment', 0, 6, 0, 0, 0, N''
							
					end	
					
						if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Appraisal Initiation')
					begin
							declare @capTranEmail_id6 numeric
							select @capTranEmail_id6 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
								SELECT @capTranEmail_id6 + 1, @Cmp_ID, N'Appraisal Initiation', 0, 7, 0, 0, 0, N''
							
					end	
					
						if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Claim Approval')
					begin
							declare @capTranEmail_id7 numeric
							select @capTranEmail_id7 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
								SELECT @capTranEmail_id7 + 1, @Cmp_ID,N'Claim Approval', 0, 8, 0, 0, 0, N''
							
					end	
					
						if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Claim Payment')
					begin
							declare @capTranEmail_id8 numeric
							select @capTranEmail_id8 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
								SELECT @capTranEmail_id8 + 1, @Cmp_ID,N'Claim Payment', 0, 9, 0, 0, 0, N''
							
					end	
					
						if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Claim Application')
					begin
							declare @capTranEmail_id9 numeric
							select @capTranEmail_id9 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
								SELECT @capTranEmail_id9 + 1, @Cmp_ID,N'Claim Application', 0, 10, 0, 0, 0, N''
							
					end	
					
					if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Appraisal Approval')
					begin
							declare @capTranEmail_id10 numeric
							select @capTranEmail_id10 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
								SELECT @capTranEmail_id10 + 1, @Cmp_ID,N'Appraisal Approval', 0, 11, 0, 0, 0, N''
							
					end	
					
					if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Recruitment Approval')
					begin
							declare @capTranEmail_id11 numeric
							select @capTranEmail_id11 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
								SELECT @capTranEmail_id11 + 1, @Cmp_ID, N'Recruitment Approval', 0, 12, 0, 0, 0, N''
							
					end	
					
					if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Interview Schedule')
					begin
							declare @capTranEmail_id12 numeric
							select @capTranEmail_id12 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
								SELECT @capTranEmail_id12 + 1, @Cmp_ID,N'Interview Schedule', 0, 13, 0, 0, 0, N''
							
					end	
					
					if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Forget Password')
					begin
							declare @capTranEmail_id13 numeric
							select @capTranEmail_id13 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
								SELECT @capTranEmail_id13 + 1, @Cmp_ID,N'Forget Password', 0, 15, 0, 0, 0, N''
							
					end	

					-- Added By Hiral Start 10102012
					if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Travel Application')
					begin
							declare @capTranEmail_id14 numeric
							select @capTranEmail_id14 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
								SELECT @capTranEmail_id14 + 1, @Cmp_ID,N'Travel Application', 0, 16, 0, 0, 0, N''
							
					end
					-- Added By Hiral End 10102012
					
					-- Added By Hiral Start 15102012
					if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Comp-Off Application')
					begin
							declare @capTranEmail_id15 numeric
							select @capTranEmail_id15 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
								SELECT @capTranEmail_id15 + 1, @Cmp_ID,N'Comp-Off Application', 0, 17, 0, 0, 0, N''
					end
					
					if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Comp-Off Approval')
					begin
							declare @capTranEmail_id16 numeric
							select @capTranEmail_id16 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
								SELECT @capTranEmail_id16 + 1, @Cmp_ID,N'Comp-Off Approval', 0, 18, 0, 0, 0, N''
					end
					-- Added By Hiral End 15102012
					
					-- Added By Hiral Start 16102012
					if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Attendance Regularization')
					begin
							declare @capTranEmail_id17 numeric
							select @capTranEmail_id17 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
								SELECT @capTranEmail_id17 + 1, @Cmp_ID,N'Attendance Regularization', 0, 19, 0, 0, 0, N''
					end
					
					if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Employee Probation')
					begin
							declare @capTranEmail_id18 numeric
							select @capTranEmail_id18 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
								SELECT @capTranEmail_id18 + 1, @Cmp_ID,N'Employee Probation', 0, 20, 0, 0, 0, N''
					end
					-- Added By Hiral End 16102012
					----Training -- Ankit 06042016
					IF NOT EXISTS (SELECT EMAIL_NTF_ID FROM T0040_Email_Notification_Config WHERE Cmp_Id = @Cmp_ID AND EMAIL_TYPE_NAME = 'Employee Training')
					BEGIN
							set @capTranEmail_id18 = 0
							SELECT @capTranEmail_id18 = ISNULL(MAX(EMAIL_NTF_ID),0) FROM T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
								SELECT @capTranEmail_id18 + 1, @Cmp_ID,N'Employee Training', 0, 20, 0, 0, 0, N''
					END
					
					-- Added By Hiral Start 08112012
					if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Exit Application')
					begin
							declare @capTranEmail_id19 numeric
							select @capTranEmail_id19 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
								SELECT @capTranEmail_id19 + 1, @Cmp_ID,N'Exit Application', 0, 21, 0, 0, 0, N''
					end
					-- Added By Hiral End 08112012
		--End Email
		-- Added by rohit for Attendance regularization approve on 25022013.
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Attendance Regularization Approve')
					begin
							declare @capTranEmail_id20 numeric
							select @capTranEmail_id20 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
								SELECT @capTranEmail_id20 + 1, @Cmp_ID,N'Attendance Regularization Approve', 0, 22, 0, 0, 0, N''
					end
		
		-- ended by rohit on 25022013
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Birth Day')
					begin
							declare @capTranEmail_id21 numeric
							select @capTranEmail_id21 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
								SELECT @capTranEmail_id21 + 1, @Cmp_ID,N'Birth Day', 0, 23, 0, 0, 0, N''
					end
		
		-- ended by rohit on 25022013
		
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Travel Settlement Application')
					begin
							declare @capTranEmail_id22 numeric
							select @capTranEmail_id22 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
								SELECT  @capTranEmail_id22+1, @Cmp_ID, N'Travel Settlement Application', 0, 24, 0, 0, 0, N'' 
							
					end
		
			-- Added By Nilesh Start 0501215
					Delete from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Change Request Application' AND EMAIL_NTF_DEF_ID = 20
					Delete from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Change Request Approval' AND EMAIL_NTF_DEF_ID = 20
					if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Change Request Application')
					begin
							declare @capTranEmail_id30 numeric
							select @capTranEmail_id30 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
								SELECT @capTranEmail_id30 + 1, @Cmp_ID,N'Change Request Application', 0, 77, 0, 0, 0, N''
					end
					if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Change Request Approval')
					begin
							declare @capTranEmail_id31 numeric
							select @capTranEmail_id31 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
								SELECT @capTranEmail_id31 + 1, @Cmp_ID,N'Change Request Approval', 0, 78, 0, 0, 0, N''
					end
		-- Added By Nilesh End 0501215
		---------------------------------------------------------- Prakash Patel 27012015 -----------------------------------------------------------------------------------
			declare @EmailNotification_ID numeric
				if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Timesheet Application')
					begin
							select @EmailNotification_ID = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID],[Cmp_Id],[EMAIL_TYPE_NAME],[EMAIL_NTF_SENT],[EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
								SELECT  @EmailNotification_ID + 1, @Cmp_ID, N'Timesheet Application', 0, 62, 0, 0, 0, N'' 
					end
				if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Timesheet Approval')
					begin
							select @EmailNotification_ID = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
								SELECT  @EmailNotification_ID + 1, @Cmp_ID, N'Timesheet Approval', 0, 63, 0, 0, 0, N'' 
					end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
		---- Added by rohit For Claim Reimbersment Application on 24102013
		--if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Claim\Reimbershment Application')
		--begin
		--		declare @capTranEmail_id23 numeric
		--		select @capTranEmail_id23 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
				
		--		INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
		--			SELECT  @capTranEmail_id23+1, @Cmp_ID, N'Claim\Reimbershment Application', 0, 26, 0, 0, 0, N'' 
				
		--end
		----Ended by rohit on 24102013
					
		---- Rohit For Increment mail Send on 13052013
		--if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Increment')
		--			begin
		--					declare @capTranEmail_id23 numeric
		--					select @capTranEmail_id23 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
		--					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
		--						SELECT  @capTranEmail_id23+1, @Cmp_ID, N'Increment', 0, 25, 0, 0, 0, N'' 
							
		--			end
		---- Rohit For Increment mail Send on 13052013
		
		-- Travel Mode Start (Hiral 28092012) --
		if not exists (select Travel_Mode_ID from T0030_TRAVEL_MODE_MASTER where Cmp_Id = @Cmp_ID)
			begin
					declare @Travel_Mode_ID numeric
					select @Travel_Mode_ID = isnull(MAX(Travel_Mode_ID),0) from T0030_TRAVEL_MODE_MASTER
					
					INSERT INTO [dbo].[T0030_TRAVEL_MODE_MASTER]([Travel_Mode_ID], [Cmp_Id], [Travel_Mode_Name], [Login_ID], [Create_Date])
						SELECT @Travel_Mode_ID + 1, @Cmp_ID, N'Car', 0, GETDATE() UNION ALL
						SELECT @Travel_Mode_ID + 2, @Cmp_ID, N'Bus', 0 , GETDATE() UNION ALL
						SELECT @Travel_Mode_ID + 3, @Cmp_ID, N'Train', 0, GETDATE() UNION ALL
						SELECT @Travel_Mode_ID + 4, @Cmp_ID, N'Flight', 0, GETDATE() UNION ALL
						SELECT @Travel_Mode_ID + 5, @Cmp_ID, N'Other', 0, GETDATE() 
			end
	-- Travel Mode End (Hiral 28092012) --
	
	
	-- Email General Setting Start (Hiral 08102012)
		exec Insert_Default_Mail_Settings @Cmp_ID
	-- Email General Setting End (Hiral 08102012)
	
	
	-- Digital Signature start
		if not exists (select Tran_id from T0250_DIGITAL_SIGNATURE_POSITION_SETTINGS where Cmp_Id = @Cmp_ID and Module = 'Form16')
			begin					
				INSERT INTO T0250_DIGITAL_SIGNATURE_POSITION_SETTINGS
                      (Cmp_id, Module, Param1, Param2, Param3, Param4, PageNo)
				VALUES     (@Cmp_ID,'Form16',300,635,400,675, 2)
			end
		
		if not exists (select Tran_id from T0250_DIGITAL_SIGNATURE_POSITION_SETTINGS where Cmp_Id = @Cmp_ID and Module = 'Form12B')
			begin					
				INSERT INTO T0250_DIGITAL_SIGNATURE_POSITION_SETTINGS
                      (Cmp_id, Module, Param1, Param2, Param3, Param4, PageNo)
				VALUES     (@Cmp_ID,'Form12B',400,90,450,120,4)
			end
			
	--- Digital Signature end
	
	-- Added By Hiral For Password Expiry Setting 04 June,2013 (Start)
	If not exists(Select 1 from T0011_Password_Settings where Cmp_ID = @Cmp_ID)
		begin
			Declare @Password_ID As Numeric(18,0)
			Select @Password_ID = ISNULL(MAX(Password_ID),0) + 1 from T0011_Password_Settings
			
			Insert into T0011_Password_Settings
				(Password_ID, Cmp_ID, Enable_Validation, Min_Chars, Upper_Char, Lower_Char, 
				 Is_Digit, Special_Char, Password_Format, Pass_Exp_Days, Reminder_Days)
				values(@Password_ID, @Cmp_ID, 1, 0, 0, 0, 0, 0, '', 180, 30)	
		end	
	-- Added By Hiral For Password Expiry Setting 04 June,2013 (End)
	-- Added By Gadriwala Muslim 23/05/2014 -start
	if not Exists(select 1 from T0250_Password_Format_Setting where Cmp_ID = @Cmp_ID)
		begin
				Insert into T0250_Password_Format_Setting (Pwd_ID,Cmp_ID,Name,Format_ID)
				select 1,@Cmp_ID,'Form-16',0 union all
				select 2,@Cmp_ID,'Salary Slip',0	
		end
	-- Added By Gadriwala Muslim 23/05/2014 -End
		---- Added by rohit For Claim Reimbersment Application on 24102013
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Reimbursement\Claim Application')
		begin
				declare @capTranEmail_id26 numeric
				select @capTranEmail_id26 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
				
				INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT  @capTranEmail_id26+1, @Cmp_ID, N'Reimbursement\Claim Application', 0, 26, 0, 0, 0, N'' 
				
		end
		----Ended by rohit on 24102013
		
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Reimbursement\Claim Approval')
		begin
				declare @capTranEmail_id27 numeric
				select @capTranEmail_id27 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
				
				INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT  @capTranEmail_id27+1, @Cmp_ID, N'Reimbursement\Claim Approval', 0, 27, 0, 0, 0, N'' 
				
		end
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Auto Mail of Probation Over')
					begin
							declare @capTranEmail_id28 numeric
							select @capTranEmail_id28 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
								SELECT @capTranEmail_id28 + 1, @Cmp_ID,N'Auto Mail of Probation Over', 0, 28, 0, 0, 0, N''
					end
					
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Auto Carry forward Intimation')
					begin
							declare @capTranEmail_id29 numeric
							select @capTranEmail_id29 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
								SELECT @capTranEmail_id29 + 1, @Cmp_ID,N'Auto Carry forward Intimation', 0, 29, 0, 0, 0, N''
					end
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Self Assessment')
					begin
							declare @capTranEmail_id510 numeric
							select @capTranEmail_id510 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
								SELECT @capTranEmail_id510 + 1, @Cmp_ID,N'Self Assessment', 0, 30, 0, 0, 0, N''
					end				
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'SelfAssessment Approval')
					begin
							declare @capTranEmail_id520 numeric
							select @capTranEmail_id520 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
								SELECT @capTranEmail_id520 + 1, @Cmp_ID,N'SelfAssessment Approval', 0, 31, 0, 0, 0, N''
					end	
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'SelfAssessment Review')
					begin
							declare @capTranEmail_id32 numeric
							select @capTranEmail_id32 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
								SELECT @capTranEmail_id32 + 1, @Cmp_ID,N'SelfAssessment Review', 0, 32, 0, 0, 0, N''
					end	
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'SelfAssessment Approved')
				begin
						declare @capTranEmail_id33 numeric
						select @capTranEmail_id33 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
						
						INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
							SELECT @capTranEmail_id33 + 1, @Cmp_ID,N'SelfAssessment Approved', 0, 33, 0, 0, 0, N''
				end		
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'PerformanceAssessment Allocation')
				begin
						declare @capTranEmail_id34 numeric
						select @capTranEmail_id34 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
						
						INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
							SELECT @capTranEmail_id34 + 1, @Cmp_ID,N'PerformanceAssessment Allocation', 0, 34, 0, 0, 0, N''
				end		
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'PerformanceAssessment Review')
				begin
						declare @capTranEmail_id35 numeric
						select @capTranEmail_id35 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
						
						INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
							SELECT @capTranEmail_id35 + 1, @Cmp_ID,N'PerformanceAssessment Review', 0, 35, 0, 0, 0, N''
				end	
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'PerformanceAssessment Final')
				begin
						declare @capTranEmail_id36 numeric
						select @capTranEmail_id36 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
						
						INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
							SELECT @capTranEmail_id36 + 1, @Cmp_ID,N'PerformanceAssessment Final', 0, 36, 0, 0, 0, N''
				end	
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Final Stage Review')
				Begin
					declare @capTranEmail_id37 numeric
					select @capTranEmail_id37 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
							SELECT @capTranEmail_id37 + 1, @Cmp_ID,N'Final Stage Review', 0, 37, 0, 0, 0, N''
				End	
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Direct Assessment Approved')
				Begin
					declare @capTranEmail_id38 numeric
					select @capTranEmail_id38 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
							SELECT @capTranEmail_id38 + 1, @Cmp_ID,N'Direct Assessment Approved', 0, 38, 0, 0, 0, N''
				End		
		--added 16 apr 2014
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Extended Self Assessment')
				Begin
					declare @capTranEmail_id39 numeric
					select @capTranEmail_id39 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
							SELECT @capTranEmail_id39 + 1, @Cmp_ID,N'Extended Self Assessment', 0, 79, 0, 0, 0, N''
				End	
		Else --modified on 23 oct 2015
			begin				
				update 	[T0040_Email_Notification_Config]
				set 	[EMAIL_NTF_DEF_ID] =79
				where [EMAIL_TYPE_NAME]='Extended Self Assessment' and cmp_id = @Cmp_ID 
			end								
				
		--Added By Mukti(Start)
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Asset Application')
					begin
							declare @capTranEmail_id40 numeric
							select @capTranEmail_id40 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
								SELECT @capTranEmail_id40 + 1, @Cmp_ID,N'Asset Application', 0, 57, 0, 0, 0, N''
					end
					
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Asset Approval')
					begin
							declare @capTranEmail_id41 numeric
							select @capTranEmail_id41 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
								SELECT @capTranEmail_id41 + 1, @Cmp_ID,N'Asset Approval', 0, 58, 0, 0, 0, N''
					end
					
		--Added By Mukti(End)	
		
		---Added By Ripal 25Jun2014 Start
		declare @capTranEmail_id42 numeric
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Recruitment Request')
					begin
							select @capTranEmail_id42 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]
									 ([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
								SELECT @capTranEmail_id42 + 1, @Cmp_ID,N'Recruitment Request', 0, 41, 0, 0, 0, N''
					end
					if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Recruitment Request Approval')
					begin
							select @capTranEmail_id42 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]
									   ([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
								SELECT @capTranEmail_id42 + 1, @Cmp_ID,N'Recruitment Request Approval', 0, 42, 0, 0, 0, N''
					end
		---Added By Ripal 25Jun2014 End
		
		
		--IF not exists(Select 1 from T0040_SETTING where Cmp_ID=@Cmp_ID and Setting_Name='Required Timesheet Approval')
		--	BEGIN 
		--		select @setting_id_max=isnull(max(setting_id),0) + 1 from T0040_SETTING
		--		Insert into T0040_SETTING values(@setting_id_max,@Cmp_ID,'Required Timesheet Approval',0
		--		,'0 for Single Level Approval Timesheet and 1 for Multi Leavel Approval','Timesheet Settings')	
		--	END
		--Else
		--	BEGIN
		--		select @setting_id_max = (Select Setting_ID from T0040_SETTING 
		--		where Cmp_ID = @Cmp_ID and Setting_Name='Required Timesheet Approval')
		--		Update T0040_SETTING Set Comment = '0 for Single Level Approval Timesheet and 1 for Multi Leavel Approval', Group_By = 'Timesheet Settings' 
		--		Where Setting_ID = @setting_id_max
		--	END
----------------------------Timesheet Setting End ---------------------------------------------------------------------
		--added by sneha on 19dec2014
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Resume Screening')
			begin
					declare @capTranEmail_id60 numeric
					select @capTranEmail_id60 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
					
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT @capTranEmail_id60 + 1, @Cmp_ID,N'Resume Screening', 0, 60, 0, 0, 0, N''
			end	
			
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Resume Screened')
			begin
					declare @capTranEmail_id61 numeric
					select @capTranEmail_id61 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
					
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT @capTranEmail_id61 + 1, @Cmp_ID,N'Resume Screened', 0, 61, 0, 0, 0, N''
			end	
		
		--added by sneha on 19dec2014 end
		--added by sneha on 25Dec2014
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'KPI Employee Review')
				begin
						declare @capTranEmail_id43 numeric
						select @capTranEmail_id43 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
						
						INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id43 + 1, @Cmp_ID,N'KPI Employee Review', 0, 43, 0, 0, 0, N''
				end
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'KPI Employee Approved')
				begin
						declare @capTranEmail_id44 numeric
						select @capTranEmail_id44 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
						
						INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id44 + 1, @Cmp_ID,N'KPI Employee Approved', 0, 44, 0, 0, 0, N''
				end	
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'KPI Reviewed')
					begin
							declare @capTranEmail_id45 numeric
							select @capTranEmail_id45 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
							SELECT @capTranEmail_id45 + 1, @Cmp_ID,N'KPI Reviewed', 0, 45, 0, 0, 0, N''
					end	
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'KPI Manager Approved')
					begin
							declare @capTranEmail_id46 numeric
							select @capTranEmail_id46 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
							SELECT @capTranEmail_id46 + 1, @Cmp_ID,N'KPI Manager Approved', 0, 46, 0, 0, 0, N''
					end				
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'KPIRating Employee Review')
					begin
							declare @capTranEmail_id47 numeric
							select @capTranEmail_id47 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
							SELECT @capTranEmail_id47 + 1, @Cmp_ID,N'KPIRating Employee Review', 0, 47, 0, 0, 0, N''
					end
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'KPIRating Reviewed')
				begin
						declare @capTranEmail_id48 numeric
						select @capTranEmail_id48 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
						
						INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
						SELECT @capTranEmail_id48 + 1, @Cmp_ID,N'KPIRating Reviewed', 0, 48, 0, 0, 0, N''
				end
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'KPIRating Employee Approved')
			begin
					declare @capTranEmail_id49 numeric
					select @capTranEmail_id49 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
					
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT @capTranEmail_id49 + 1, @Cmp_ID,N'KPIRating Employee Approved', 0, 49, 0, 0, 0, N''
			end					
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'KPIRating Manager Approved')
		begin
				declare @capTranEmail_id50 numeric
				select @capTranEmail_id50 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
				
				INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
				SELECT @capTranEmail_id50 + 1, @Cmp_ID,N'KPIRating Manager Approved', 0, 50, 0, 0, 0, N''
		end
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'KPIRating Manager Review')
		begin
				declare @capTranEmail_id51 numeric
				select @capTranEmail_id51 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
				
				INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
				SELECT @capTranEmail_id51 + 1, @Cmp_ID,N'KPIRating Manager Review', 0, 51, 0, 0, 0, N''
		end	
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'KPIRating Reject')
			begin
					declare @capTranEmail_id52 numeric
					select @capTranEmail_id52 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
					
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT @capTranEmail_id52 + 1, @Cmp_ID,N'KPIRating Reject', 0, 52, 0, 0, 0, N''
			end	
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'KPIRating Approve')
			begin
					declare @capTranEmail_id53 numeric
					select @capTranEmail_id53 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
					
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT @capTranEmail_id53 + 1, @Cmp_ID,N'KPIRating Approve', 0, 53, 0, 0, 0, N''
			end	
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'KPI Closed')
			begin
					declare @capTranEmail_id54 numeric
					select @capTranEmail_id54 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
					
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT @capTranEmail_id54 + 1, @Cmp_ID,N'KPI Closed', 0, 54, 0, 0, 0, N''
			end		
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'KPI Objective Manager Review')
			begin
					declare @capTranEmail_id55 numeric
					select @capTranEmail_id55 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
					
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT @capTranEmail_id55 + 1, @Cmp_ID,N'KPI Objective Manager Review', 0, 55, 0, 0, 0, N''
			end
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'KPI Objective Final Approval')
		begin
				declare @capTranEmail_id56 numeric
				select @capTranEmail_id56 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
				
				INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
				SELECT @capTranEmail_id56 + 1, @Cmp_ID,N'KPI Objective Final Approval', 0, 56, 0, 0, 0, N''
		end			
		--by sneha on 25 Dec 2014 end
		
	--added by Mukti on 28012015 start
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Recruitment Approval Level')
			begin
					declare @capTranEmail_id64 numeric
					select @capTranEmail_id64 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
					
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT @capTranEmail_id64 + 1, @Cmp_ID,N'Recruitment Approval Level', 0, 64, 0, 0, 0, N''
			end	
			
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Candidate Approval')
			begin
					declare @capTranEmail_id66 numeric
					select @capTranEmail_id66 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
					
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT @capTranEmail_id66 + 1, @Cmp_ID,N'Candidate Approval', 0, 66, 0, 0, 0, N''
			end	
				
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Candidate Approval Level')
			begin
					declare @capTranEmail_id65 numeric
					select @capTranEmail_id65 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
					
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT @capTranEmail_id65 + 1, @Cmp_ID,N'Candidate Approval Level', 0, 65, 0, 0, 0, N''
			end	
 --added by Mukti on 28012015 end
		
--added by Mukti on 11022015 start
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Candidate Rejection')
			begin
					declare @capTranEmail_id67 numeric
					select @capTranEmail_id67 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
					
					INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
					SELECT @capTranEmail_id67 + 1, @Cmp_ID,N'Candidate Rejection', 0, 67, 0, 0, 0, N''
			end	
			
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Recruitment Post Detail')
					begin
							declare @capTranEmail_id68 numeric
							select @capTranEmail_id68 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
							SELECT @capTranEmail_id68 + 1, @Cmp_ID,N'Recruitment Post Detail', 0, 68, 0, 0, 0, N''
					end		
--added by Mukti on 11022015 end

--added by Mukti on 02032015 start
if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Training Reminder')
					begin
							declare @capTranEmail_id69 numeric
							select @capTranEmail_id69 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
							SELECT @capTranEmail_id69 + 1, @Cmp_ID,N'Training Reminder', 0, 69, 0, 0, 0, N''
					end	
if exists (select 1 from T0040_Email_Notification_Config where email_type_name ='Training Remainder')	
	begin
		delete from T0040_Email_Notification_Config where email_type_name ='Training Remainder'
	end
--added by Mukti on 02032015 end		

--added by Mukti 03032015(start)
if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Survey Form Filled By Employee')
	begin
		declare @capTranEmail_id70 numeric
		select @capTranEmail_id70 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
		INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])	
		SELECT @capTranEmail_id70 + 1, @Cmp_ID,N'Survey Form Filled By Employee', 0, 70, 0, 0, 0, N''
	End
	if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Fill The Survey Form')
	begin
		declare @capTranEmail_id71 numeric
		select @capTranEmail_id71 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
		INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])	
		SELECT @capTranEmail_id71 + 1, @Cmp_ID,N'Fill The Survey Form', 0, 71, 0, 0, 0, N''
	End
--added by Mukti 03032015(end)

--Added by Gadriwala Muslim -03072015
	if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Pre-CompOff Application')
					begin
							declare @capTranEmail_id73 numeric
							select @capTranEmail_id73 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
								SELECT @capTranEmail_id73 + 1, @Cmp_ID, N'Pre-CompOff Application', 0, 73, 0, 0, 0, N''
							
					end	
		if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Pre-CompOff Approval')
					begin
							declare @capTranEmail_id74 numeric
							select @capTranEmail_id74 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
							INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
								SELECT @capTranEmail_id74 + 1, @Cmp_ID, N'Pre-CompOff Approval', 0, 74, 0, 0, 0, N''
							
					end	
--Added by Gadriwala Muslim -03072015

--added by sneha on 07 Aug 2015 start	
if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Send final list of trainees')
		begin
			declare @capTranEmail_id75 numeric
			select @capTranEmail_id75 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
			INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
			SELECT @capTranEmail_id75 + 1, @Cmp_ID,N'Send final list of trainees', 0, 75, 0, 0, 0, N''
	    end	
--added by sneha on 07 Aug 2015 end

--added by sneha on 07 Aug 2015 start	
if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Training Answers/Feedback Submitted')
		begin
			declare @capTranEmail_id76 numeric
			select @capTranEmail_id76 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
			INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
			SELECT @capTranEmail_id76 + 1, @Cmp_ID,N'Training Answers/Feedback Submitted', 0, 76, 0, 0, 0, N''
	    end	
--added by sneha on 07 Aug 2015 end
					
--added by sneha on 21 Jun 2016 start
if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Register For Training')
	begin
		declare @capTranEmail_id85 numeric
		select @capTranEmail_id85 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
						
		INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email],[Module_Name])
		SELECT @capTranEmail_id85 + 1, @Cmp_ID,N'Register For Training', 0, 85, 0, 0, 0, N'',N'HRMS'
    end	
--added by sneha on 21 Jun 2016 end		
--added by 01/08/2016 sneha start--
IF NOT EXISTS (SELECT EMAIL_NTF_ID FROM T0040_Email_Notification_Config WHERE Cmp_Id = @Cmp_ID AND EMAIL_TYPE_NAME = 'Balance Score Card')
	BEGIN
		declare @TranEmail_id86 numeric
		SET  @TranEmail_id86  = 0
		SELECT @TranEmail_id86 = ISNULL(MAX(EMAIL_NTF_ID),0) FROM T0040_Email_Notification_Config
							
		INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email],[module_name])
		SELECT @TranEmail_id86 + 1, @Cmp_ID,N'Balance Score Card', 0, 86, 0, 0, 0,N'','Appraisal3'
	END		 

IF NOT EXISTS (SELECT EMAIL_NTF_ID FROM T0040_Email_Notification_Config WHERE Cmp_Id = @Cmp_ID AND EMAIL_TYPE_NAME = 'Balance Score Card Assessment')
	BEGIN
		declare @TranEmail_id87 numeric
		SET  @TranEmail_id87  = 0
		SELECT @TranEmail_id87 = ISNULL(MAX(EMAIL_NTF_ID),0) FROM T0040_Email_Notification_Config
							
		INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email],[module_name])
		SELECT @TranEmail_id87 + 1, @Cmp_ID,N'Balance Score Card Assessment', 0, 87, 0, 0, 0,N'','Appraisal3'
	END			 	 
--added by 01/08/2016 sneha end--	
					
--Added by nilesh patel on 12012015 -start
	  
	    if not exists (select Request_id from T0040_Change_Request_Master where Cmp_Id = @Cmp_ID and Request_type = 'Birthdate Change')
		begin
				declare @Request_id1 numeric
				select  @Request_id1 = isnull(MAX(Tran_id),0) + 1 from T0040_Change_Request_Master
				INSERT INTO T0040_Change_Request_Master (Tran_id,Request_id,Request_type,Cmp_ID)VALUES(@Request_id1,1,'Birthdate Change',@Cmp_ID)
		end
		
		if not exists (select Request_id from T0040_Change_Request_Master where Cmp_Id = @Cmp_ID and Request_type = 'Branch Change')
		begin
				declare @Request_id2 numeric
				select  @Request_id2 = isnull(MAX(Tran_id),0) + 1 from T0040_Change_Request_Master
				INSERT INTO T0040_Change_Request_Master (Tran_id,Request_id,Request_type,Cmp_ID)VALUES(@Request_id2,2,'Branch Change',@Cmp_ID)
		end
		
		if not exists (select Request_id from T0040_Change_Request_Master where Cmp_Id = @Cmp_ID and Request_type = 'Shift Change')
		begin
				declare @Request_id3 numeric
				select  @Request_id3 = isnull(MAX(Tran_id),0) + 1 from T0040_Change_Request_Master
				INSERT INTO T0040_Change_Request_Master (Tran_id,Request_id,Request_type,Cmp_ID)VALUES(@Request_id3,3,'Shift Change',@Cmp_ID)
		end
		
		if not exists (select Request_id from T0040_Change_Request_Master where Cmp_Id = @Cmp_ID and Request_type = 'Marital Status Change')
		begin
				declare @Request_id4 numeric
				select  @Request_id4 = isnull(MAX(Tran_id),0) + 1 from T0040_Change_Request_Master
				INSERT INTO T0040_Change_Request_Master (Tran_id,Request_id,Request_type,Cmp_ID)VALUES(@Request_id4,4,'Marital Status Change',@Cmp_ID)
		end
		
		if not exists (select Request_id from T0040_Change_Request_Master where Cmp_Id = @Cmp_ID and Request_type = 'Permanent Address Change')
		begin
				declare @Request_id5 numeric
				select  @Request_id5 = isnull(MAX(Tran_id),0) + 1 from T0040_Change_Request_Master
				INSERT INTO T0040_Change_Request_Master (Tran_id,Request_id,Request_type,Cmp_ID)VALUES(@Request_id5,5,'Permanent Address Change',@Cmp_ID)
		end
		
		if not exists (select Request_id from T0040_Change_Request_Master where Cmp_Id = @Cmp_ID and Request_type = 'Present Address Change')
		begin
				declare @Request_id6 numeric
				select  @Request_id6 = isnull(MAX(Tran_id),0) + 1 from T0040_Change_Request_Master
				INSERT INTO T0040_Change_Request_Master (Tran_id,Request_id,Request_type,Cmp_ID)VALUES(@Request_id6,6,'Present Address Change',@Cmp_ID)
		end
		if not exists (select Request_id from T0040_Change_Request_Master where Cmp_Id = @Cmp_ID and Request_type = 'Qualification')
		begin
				declare @Request_id7 numeric
				select  @Request_id7 = isnull(MAX(Tran_id),0) + 1 from T0040_Change_Request_Master
				INSERT INTO T0040_Change_Request_Master (Tran_id,Request_id,Request_type,Cmp_ID)VALUES(@Request_id7,7,'Qualification',@Cmp_ID)
		end
		
		if not exists (select Request_id from T0040_Change_Request_Master where Cmp_Id = @Cmp_ID and Request_type = 'Dependent')
		begin
				declare @Request_id8 numeric
				select  @Request_id8 = isnull(MAX(Tran_id),0) + 1 from T0040_Change_Request_Master
				INSERT INTO T0040_Change_Request_Master (Tran_id,Request_id,Request_type,Cmp_ID)VALUES(@Request_id8,8,'Dependent',@Cmp_ID)
		end
		
		if not exists (select Request_id from T0040_Change_Request_Master where Cmp_Id = @Cmp_ID and Request_type = 'Passport')
		begin
				declare @Request_id9 numeric
				select  @Request_id9 = isnull(MAX(Tran_id),0) + 1 from T0040_Change_Request_Master
				INSERT INTO T0040_Change_Request_Master (Tran_id,Request_id,Request_type,Cmp_ID)VALUES(@Request_id9,9,'Passport',@Cmp_ID)
		end
		
		if not exists (select Request_id from T0040_Change_Request_Master where Cmp_Id = @Cmp_ID and Request_type = 'Visa')
		begin
				declare @Request_id10 numeric
				select  @Request_id10 = isnull(MAX(Tran_id),0) + 1 from T0040_Change_Request_Master
				INSERT INTO T0040_Change_Request_Master (Tran_id,Request_id,Request_type,Cmp_ID)VALUES(@Request_id10,10,'Visa',@Cmp_ID)
		end
		
		if not exists (select Request_id from T0040_Change_Request_Master where Cmp_Id = @Cmp_ID and Request_type = 'License')
		begin
				declare @Request_id11 numeric
				select  @Request_id11 = isnull(MAX(Tran_id),0) + 1 from T0040_Change_Request_Master
				INSERT INTO T0040_Change_Request_Master (Tran_id,Request_id,Request_type,Cmp_ID)VALUES(@Request_id11,11,'License',@Cmp_ID)
		end
			
		--Added By Jaina 28-10-2015 		
		if not exists (select Request_id from T0040_Change_Request_Master where Cmp_Id = @Cmp_ID and Request_type = 'Others')
		begin
				declare @Request_id12 numeric
				select  @Request_id12 = isnull(MAX(Tran_id),0) + 1 from T0040_Change_Request_Master
				INSERT INTO T0040_Change_Request_Master (Tran_id,Request_id,Request_type,Cmp_ID)VALUES(@Request_id12,12,'Others',@Cmp_ID)
		end
		
		if not exists (select Request_id from T0040_Change_Request_Master where Cmp_Id = @Cmp_ID and Request_type = 'Bank Details')
		begin
				declare @Request_id13 numeric
				select  @Request_id13 = isnull(MAX(Tran_id),0) + 1 from T0040_Change_Request_Master
				INSERT INTO T0040_Change_Request_Master (Tran_id,Request_id,Request_type,Cmp_ID)VALUES(@Request_id13,13,'Bank Details',@Cmp_ID)
		end		
		if not exists (select Request_id from T0040_Change_Request_Master where Cmp_Id = @Cmp_ID and Request_type = 'Nominees')
		begin
				declare @Request_id14 numeric
				select  @Request_id14 = isnull(MAX(Tran_id),0) + 1 from T0040_Change_Request_Master
				INSERT INTO T0040_Change_Request_Master (Tran_id,Request_id,Request_type,Cmp_ID)VALUES(@Request_id14,14,'Nominees',@Cmp_ID)
		end
		
		if not exists (select Request_id from T0040_Change_Request_Master where Cmp_Id = @Cmp_ID and Request_type = 'Mediclaim')
		begin
				declare @Request_id15 numeric
				select  @Request_id15 = isnull(MAX(Tran_id),0) + 1 from T0040_Change_Request_Master
				INSERT INTO T0040_Change_Request_Master (Tran_id,Request_id,Request_type,Cmp_ID)VALUES(@Request_id15,15,'Mediclaim',@Cmp_ID)
		end
		
		if not exists (select Request_id from T0040_Change_Request_Master where Cmp_Id = @Cmp_ID and Request_type = 'Pan Crad & Adhar Card')
		begin
				declare @Request_id16 numeric
				select  @Request_id16 = isnull(MAX(Tran_id),0) + 1 from T0040_Change_Request_Master
				INSERT INTO T0040_Change_Request_Master (Tran_id,Request_id,Request_type,Cmp_ID)VALUES(@Request_id16,16,'Pan Crad & Adhar Card',@Cmp_ID)
		end
		
		if not exists (select Request_id from T0040_Change_Request_Master where Cmp_Id = @Cmp_ID and Request_type = 'Skip Monthly Loan Installment')
		begin
				declare @Request_id17 numeric
				select  @Request_id17 = isnull(MAX(Tran_id),0) + 1 from T0040_Change_Request_Master
				INSERT INTO T0040_Change_Request_Master (Tran_id,Request_id,Request_type,Cmp_ID)VALUES(@Request_id17,17,'Skip Monthly Loan Installment',@Cmp_ID)
		end

		-- Ankit For Update Sample Code IS Null -- 26122014
		
		IF Exists( SELECT 1 FROM T0010_COMPANY_MASTER WHERE (Sample_Emp_Code Is Null OR Sample_Emp_Code = '') And Cmp_Id = @Cmp_ID )
			BEGIN
				Declare @IS_Auto_Alpha_Numeric_Code Numeric(18,0)
				Declare @No_OF_Digit_Emp_Code	 Numeric(18,0)
				Declare @Is_CompanyWise Numeric(18,0)
				Declare @IS_Alpha_Numeric_Branchwise Numeric(18,0)
				Declare @Sample_Emp_Code Varchar(100)
				Declare @Dig Varchar(15)
				Declare @Is_DateWise Numeric(18,0)
				Declare @Is_JoiningDateWise Numeric(18,0)
				Declare @DateFormat Varchar(15)
				
				Set @IS_Auto_Alpha_Numeric_Code = 0
				Set @No_OF_Digit_Emp_Code		= 0
				Set @Is_CompanyWise				= 0
				Set @IS_Alpha_Numeric_Branchwise = 0
				Set @Sample_Emp_Code			= ''
				Set @Dig = ''
				Set @Is_DateWise	= 0
				Set @Is_JoiningDateWise	= 0
				Set @DateFormat = ''
				
				SELECT @IS_Auto_Alpha_Numeric_Code = IS_Auto_Alpha_Numeric_Code ,@No_OF_Digit_Emp_Code = No_OF_Digit_Emp_Code ,
						@Is_CompanyWise = Is_CompanyWise , @IS_Alpha_Numeric_Branchwise = IS_Alpha_Numeric_Branchwise,
						@Is_DateWise = Is_DateWise ,@Is_JoiningDateWise = Is_JoiningDateWise , @DateFormat = DateFormat
				FROM T0010_COMPANY_MASTER WHERE (Sample_Emp_Code Is Null OR Sample_Emp_Code = '') And Cmp_Id = @Cmp_ID
			
				IF @IS_Auto_Alpha_Numeric_Code = 1
					BEGIN
						 IF @No_OF_Digit_Emp_Code > 0
							SET @Dig = RIGHT(REPLICATE('0', @No_OF_Digit_Emp_Code)  ,@No_OF_Digit_Emp_Code - 1)   +  '1'
						 
						 IF @Is_CompanyWise = 1
							SET @Sample_Emp_Code = 'CM+'
						 
						 IF @IS_Alpha_Numeric_Branchwise = 1
							SET @Sample_Emp_Code = @Sample_Emp_Code + 'BR+'
						 
						 IF @Is_DateWise = 1 AND @Is_JoiningDateWise = 1
							SET @Sample_Emp_Code = @Sample_Emp_Code + 'JD('+ @DateFormat + ')+'
						 Else IF @Is_DateWise = 1 AND @Is_JoiningDateWise = 0
							SET @Sample_Emp_Code = @Sample_Emp_Code + 'CD('+ @DateFormat + ')+'
							
							
						 SET @Sample_Emp_Code = ISNULL(@Sample_Emp_Code,'') + @Dig
					END
				ELSE
					BEGIN
						IF @No_OF_Digit_Emp_Code > 0
							SET @Sample_Emp_Code = RIGHT(REPLICATE('0', @No_OF_Digit_Emp_Code)  ,@No_OF_Digit_Emp_Code - 1)   +  '1'
					END
				
				UPDATE T0010_COMPANY_MASTER 
				SET Sample_Emp_Code = @Sample_Emp_Code
				WHERE (Sample_Emp_Code IS NULL OR Sample_Emp_Code = '') And Cmp_Id = @Cmp_ID
					
			END
		
		UPDATE T0090_EMP_REPORTING_DETAIL		--UPDATE EFFECT DATE OF REPORTING MANAGER AS EMPLOYEE DOJ
		SET EFFECT_DATE = A.DATE_OF_JOIN
		FROM T0080_EMP_MASTER A INNER JOIN 
			T0090_EMP_REPORTING_DETAIL B ON  A.EMP_ID = B.EMP_ID
		WHERE B.EFFECT_DATE IS  NULL
			
		-- Ankit For Update Sample Code Is Null -- 26122014
		
		--IF NOT EXISTS(SELECT 1 FROM T0040_SETTING WHERE Cmp_ID=@Cmp_ID and Setting_Name='Allow Same Date Increment')
		--	BEGIN
		--		SELECT @setting_id_max=isnull(max(setting_id),0) + 1 FROM T0040_SETTING
		--		INSERT INTO T0040_SETTING 
		--		VALUES(@setting_id_max,@Cmp_ID,'Allow Same Date Increment',0,'Allow Employee Same Date Increment Entry','Employee Settings')
		--	END		
		
		--Added By Gadriwala Muslim 25022015 - Start
					declare @pwd_Frmt_ID as integer 
					declare @Format as varchar(max)
 
					declare curPassFormat cursor for select pwd_Frmt_ID,Format from T0040_Password_Format where cmp_ID = @cmp_ID
 
					 open curPassFormat
						fetch next from curPassFormat into @pwd_Frmt_ID,@Format
							while @@fetch_Status = 0
								begin
									set @Format = REPLACE(@Format,'Employee First Name','EFN + ')
									set @Format = REPLACE(@Format,'Employee Last Name','ELN + ')
									set @Format = REPLACE(@Format,'Employee Code','EC + ')
									set @Format = REPLACE(@Format,'PAN Card','PAN + ')
									set @Format = REPLACE(@Format,'Date of Birth','DOB + ')
									set @Format = REPLACE(@Format,'Date of Join','DOJ + ')
									if  right(@format,2) = '+'
									 set @format =	Substring(isnull(@format,''),1,len(@format) - 2)
									
									update T0040_Password_Format set Format = @Format 
									where pwd_Frmt_ID =  @pwd_Frmt_ID
									
								fetch next from curPassFormat into @pwd_Frmt_ID,@Format
								end
					 close curPassFormat
					 deallocate curPassFormat
		--Added By Gadriwala Muslim 25022015 - End
		
		--Added by nilesh patel on 07032015 -Start
		DECLARE @Char_index as Numeric(18,0)
		SELECT @Char_index = (Select charindex('{',data) From dbo.Split(Actual_AD_Formula,'#') where id=1) from (Select  Actual_AD_Formula ,ROW_NUMBER() OVER(ORDER BY Tran_Id) as Row_id  from T0040_AD_Formula_Setting where Cmp_Id = @Cmp_ID ) t WHERE t.Row_id = 1 
		
		if @Char_index = 0
		begin
			DECLARE @Ad_ID Numeric(18,0)
			DECLARE @Ad_Actual_Name Varchar(2000)
			DECLARE @Cmp_ID_temp Numeric(18,0)
			DECLARE @Cmp_ID_1 Numeric(18,0)
			DECLARE @ID Numeric(18,0)
			DECLARE @Data Varchar(500)
			DECLARE @In_Formula Varchar(500)
			declare @StrSQl as nvarchar(max)
			
			CREATE Table #Temp
			(
				ID Numeric(18,0),
				Name Varchar(1000),
				Cmp_ID Numeric(18,0)
			)
			Declare  Cur_Spit cursor for Select AD_Id,Actual_AD_Formula,Cmp_Id From T0040_AD_Formula_Setting where Cmp_Id = @Cmp_ID
			open Cur_Spit
			FETCH next from Cur_Spit into @Ad_ID,@Ad_Actual_Name,@Cmp_ID_temp
			while @@fetch_status = 0 
				BEGIN
				
					
					Insert INTO #Temp(ID,Name,Cmp_ID)
					Select @Ad_ID,data,@Cmp_ID_temp From dbo.Split(@Ad_Actual_Name,'#')
					
										
					Declare Cur_Spit1 cursor for Select ID,Name,Cmp_ID From #Temp
					open Cur_Spit1  
					fetch next from Cur_Spit1 into @ID,@Data,@Cmp_ID_1
					while @@fetch_status = 0
						Begin
														
							Set @In_Formula = ''
							if @Data = 'Basic Salary'
								Begin 
									Set @In_Formula = '{' + @Data + '}'
									Update #Temp Set Name =  @In_Formula where Name = @Data
								End 
							if @Data = 'Gross Salary'
								Begin 
									Set @In_Formula = '{' + @Data + '}'
									Update #Temp Set Name =  @In_Formula where Name = @Data
								End
							if @Data = 'CTC'
								Begin 
									Set @In_Formula = '{' + @Data + '}'
									Update #Temp Set Name =  @In_Formula where Name = @Data
								End
							if @Data = 'Absent Days'
								Begin 
									Set @In_Formula = '{' + @Data + '}'
									Update #Temp Set Name =  @In_Formula where Name = @Data
								End
							if @Data = 'Present Days'
								Begin 
									Set @In_Formula = '{' + @Data + '}'
									Update #Temp Set Name =  @In_Formula where Name = @Data
								End
							if @Data = 'Actual Gross'
								Begin 
									Set @In_Formula = '{' + @Data + '}'
									Update #Temp Set Name =  @In_Formula where Name = @Data
								End
							if @Data = 'Actual Basic'
								Begin 
									Set @In_Formula = '{' + @Data + '}'
									Update #Temp Set Name =  @In_Formula where Name = @Data
								End
							if @Data = 'XDays'
								Begin 
									Set @In_Formula = '{' + @Data + '}'
									Update #Temp Set Name =  @In_Formula where Name = @Data
								End
							if @Data = 'Night Halt Count'
								Begin 
									Set @In_Formula = '{' + @Data + '}'
									Update #Temp Set Name =  @In_Formula where Name = @Data
								End
							if @Data = 'Month Days'
								Begin 
									Set @In_Formula = '{' + @Data + '}'
									Update #Temp Set Name =  @In_Formula where Name = @Data
								End	
							fetch next from Cur_Spit1 into @ID,@Data,@Cmp_ID_1
						End
						set @StrSQl=''
						SELECT @StrSQl = COALESCE(@StrSQl+'#',' ') + Name from #Temp	 where ID = @Ad_ID and Cmp_Id = @Cmp_ID_temp
						set @StrSQl = right(@StrSQl,LEN(@StrSQl)-1)
						close Cur_Spit1                    
						deallocate Cur_Spit1 
						Update T0040_AD_Formula_Setting SET Actual_AD_Formula = @StrSQl where AD_Id = @Ad_ID   and Cmp_Id = @Cmp_ID_temp
					FETCH next from Cur_Spit into @Ad_ID,@Ad_Actual_Name,@Cmp_ID_temp
				End
			close Cur_Spit                    
			deallocate Cur_Spit
			DROP TABLE #Temp
		End
		--Added by nilesh patel on 07032015 -End
		
		--Added by nilesh patel on 07032015 -Start
		DECLARE @Fromula_Ad Numeric(18,0)
		SELECT @Fromula_Ad = AD_Formula from (Select Charindex('{',AD_Formula) as AD_Formula ,ROW_NUMBER() OVER(ORDER BY Tran_Id) as Row_id  from T0040_AD_Formula_Setting where Cmp_Id = @Cmp_Id ) t WHERE t.Row_id = 1
		
		if @Fromula_Ad = 0
		begin
			DECLARE @StrSQl_12 Varchar(max)
			Declare @AD_ID_12  nvarchar(max)
			Declare @AD_NAME_12  nvarchar(max) 
			Declare @Ad_ID_123 Numeric(18,0)
			DECLARE @Ad_Actual_Name_12 nvarchar(max)
			DECLARE @Cmp_ID_12 Numeric(18,0)

			  Declare  Cur_Spit cursor for Select AD_Id,Actual_AD_Formula,Cmp_Id From T0040_AD_Formula_Setting where Cmp_Id = @Cmp_ID
				open Cur_Spit
				FETCH next from Cur_Spit into @Ad_ID_123,@Ad_Actual_Name_12,@Cmp_ID_12
				while @@fetch_status = 0 
					Begin 
						set @StrSQl_12=''
						SELECT @StrSQl_12 = COALESCE(@StrSQl_12+' ',' ') + Data FROM dbo.Split(@Ad_Actual_Name_12,'#')
						DECLARE Cur_Get_AD_Formula CURSOR FOR  
							  select AD_ID,AD_NAME from T0050_AD_MASTER where CMP_ID = @Cmp_ID_12  
							  OPEN Cur_Get_AD_Formula  
								   fetch next from Cur_Get_AD_Formula into @AD_ID_12,@AD_NAME_12  
								   while @@fetch_status = 0  
									Begin  
										 If CHARINDEX('{'+ @AD_ID_12 +'}',@StrSQl_12)>0 
											  Begin 	
												   set @StrSQl_12=REPLACE(@StrSQl_12,@AD_ID_12,@AD_NAME_12) 
											  End
									fetch next from Cur_Get_AD_Formula into @AD_ID_12,@AD_NAME_12  
									End 
							Set @StrSQl_12 = REPLACE(REPLACE(@StrSQl_12,'} }','}'),'{ {','{')
							update T0040_AD_Formula_Setting SET AD_Formula = @StrSQl_12 where AD_Id = @Ad_ID_123
						close Cur_Get_AD_Formula   
						deallocate Cur_Get_AD_Formula  
					FETCH next from Cur_Spit into @Ad_ID_123,@Ad_Actual_Name_12,@Cmp_ID_12
				End 
				close Cur_Spit                    
				deallocate Cur_Spit
		End
		--Added by nilesh patel on 07032015 -End
		
--added by Mukti on 17062015 start
if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Offer/Appointment Letter Status')
		begin
			declare @capTranEmail_id72 numeric
			select @capTranEmail_id72 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
			INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
			SELECT @capTranEmail_id72 + 1, @Cmp_ID,N'Offer/Appointment Letter Status', 0, 72, 0, 0, 0, N''
	    end		
--added by Mukti on 17062015 end	

----check the maximum EMAIL_NTF_DEF_ID in the table before assigning to the email type currently max EMAIL_NTF_DEF_ID is 79


--added by Mukti on 04022016(start)
if not exists (select EMAIL_NTF_ID from T0040_Email_Notification_Config where Cmp_Id = @Cmp_ID and EMAIL_TYPE_NAME = 'Training In-Out')
	begin
		declare @capTranEmail_id80 numeric
		select @capTranEmail_id80 = isnull(MAX(EMAIL_NTF_ID),0) from T0040_Email_Notification_Config
							
		INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
		SELECT @capTranEmail_id80 + 1, @Cmp_ID,N'Training In-Out', 0, 80, 0, 0, 0,N''
	end	
--added by Mukti on 04022016(end)


--Ankit 26052016
IF NOT EXISTS (SELECT EMAIL_NTF_ID FROM T0040_Email_Notification_Config WHERE Cmp_Id = @Cmp_ID AND EMAIL_TYPE_NAME = 'GatePass')
	BEGIN
		SET  @capTranEmail_id80  = 0
		SELECT @capTranEmail_id80 = ISNULL(MAX(EMAIL_NTF_ID),0) FROM T0040_Email_Notification_Config
							
		INSERT INTO [dbo].[T0040_Email_Notification_Config]([EMAIL_NTF_ID], [Cmp_Id], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[To_Manager],[To_Hr],[To_Account],[Other_Email])
		SELECT @capTranEmail_id80 + 1, @Cmp_ID,N'GatePass', 0, 81, 0, 0, 0,N''
	END	
-------

--Added By Jaina 06-06-2016 Start
	IF NOT EXISTS (SELECT EMAIL_NTF_ID FROM T0040_EMAIL_NOTIFICATION_CONFIG WHERE CMP_ID = @CMP_ID AND EMAIL_TYPE_NAME = 'Exit Approval')
		BEGIN
				DECLARE @CAPTRANEMAIL_ID82 NUMERIC
				SELECT @CAPTRANEMAIL_ID82 = ISNULL(MAX(EMAIL_NTF_ID),0) FROM T0040_EMAIL_NOTIFICATION_CONFIG
							
				INSERT INTO [DBO].[T0040_EMAIL_NOTIFICATION_CONFIG]([EMAIL_NTF_ID], [CMP_ID], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[TO_MANAGER],[TO_HR],[TO_ACCOUNT],[OTHER_EMAIL])
				SELECT @CAPTRANEMAIL_ID82 + 1, @CMP_ID,N'Exit Approval', 0, 82, 0, 0, 0, N''
		END

	IF NOT EXISTS (SELECT EMAIL_NTF_ID FROM T0040_EMAIL_NOTIFICATION_CONFIG WHERE CMP_ID = @CMP_ID AND EMAIL_TYPE_NAME = 'Clearance Approval')
		BEGIN
				DECLARE @CAPTRANEMAIL_ID83 NUMERIC
				SELECT @CAPTRANEMAIL_ID83 = ISNULL(MAX(EMAIL_NTF_ID),0) FROM T0040_EMAIL_NOTIFICATION_CONFIG
							
				INSERT INTO [DBO].[T0040_EMAIL_NOTIFICATION_CONFIG]([EMAIL_NTF_ID], [CMP_ID], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[TO_MANAGER],[TO_HR],[TO_ACCOUNT],[OTHER_EMAIL])
				SELECT @CAPTRANEMAIL_ID83 + 1, @CMP_ID,N'Clearance Approval', 0, 83, 0, 0, 0, N''
		END

	IF NOT EXISTS (SELECT EMAIL_NTF_ID FROM T0040_EMAIL_NOTIFICATION_CONFIG WHERE CMP_ID = @CMP_ID AND EMAIL_TYPE_NAME = 'Final Clearance Approval')
		BEGIN
				DECLARE @CAPTRANEMAIL_ID84 NUMERIC
				SELECT @CAPTRANEMAIL_ID84 = ISNULL(MAX(EMAIL_NTF_ID),0) FROM T0040_EMAIL_NOTIFICATION_CONFIG
							
				INSERT INTO [DBO].[T0040_EMAIL_NOTIFICATION_CONFIG]([EMAIL_NTF_ID], [CMP_ID], [EMAIL_TYPE_NAME], [EMAIL_NTF_SENT], [EMAIL_NTF_DEF_ID],[TO_MANAGER],[TO_HR],[TO_ACCOUNT],[OTHER_EMAIL])
				SELECT @CAPTRANEMAIL_ID84 + 1, @CMP_ID,N'Final Clearance Approval', 0, 84, 0, 0, 0, N''
		END
		
--Added By Jaina 06-06-2016 End

--Added By Mukti(21072016)start
		if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='KPA')
			begin
					declare @capTranEmail_id86 numeric
					select @capTranEmail_id86 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTranEmail_id86 + 1, @Cmp_ID, N'KPA', N'KPA',86,N'KPA'						 
			end	
			
		if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='Target')
			begin
					declare @capTranEmail_id87 numeric
					select @capTranEmail_id87 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTranEmail_id87 + 1, @Cmp_ID, N'Target', N'Target',87,N'Target'						 
			end	
			
		if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='Perfomance Attribute')
			begin
					declare @capTranEmail_id88 numeric
					select @capTranEmail_id88 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTranEmail_id88 + 1, @Cmp_ID, N'Perfomance Attribute', N'Perfomance Attribute',88,N'Perfomance Attribute'
			end	
		
		if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='Potential Attribute')
			begin
					declare @capTranEmail_id89 numeric
					select @capTranEmail_id89 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTranEmail_id89 + 1, @Cmp_ID, N'Potential Attribute', N'Potential Attribute',89,N'Potential Attribute'
			end	
			
		if not exists (select tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='Justification for High Score')
			begin
					declare @capTranEmail_id90 numeric
					select @capTranEmail_id90 = isnull(MAX(tran_id),0) from T0040_CAPTION_SETTING
					
					INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
						SELECT @capTranEmail_id90 + 1, @Cmp_ID, N'Justification for High Score', N'Justification for High Score',90,N'Justification for High Score'
			end		
	 --Added By Mukti(21072016)end
	 
	 --Added By Ramiz on 11/08/2016
	 if not exists (select Tran_id from T0040_CAPTION_SETTING where Cmp_Id = @Cmp_ID and Caption='AX Mapping')
			BEGIN
				Declare @Cap_AX91 numeric
				Select @Cap_AX91 = ISNULL(MAX(TRAN_ID),0) + 1 from T0040_CAPTION_SETTING
				
				INSERT INTO [dbo].[T0040_CAPTION_SETTING]([Tran_Id], [Cmp_Id], [Caption], [Alias], [SortingNo],[Remarks])
				SELECT @Cap_AX91, @Cmp_ID, N'AX Mapping', N'AX Mapping',91,N'AX Mapping'
			END		
	 --Ended By Ramiz on 11/08/2016
	 
-- Added by rohit on 21082015 for Default City Entry.
exec InsertCity
 
	
exec P0030_City_Master_Default @cmp_id
-- Ended by rohit on 21082015		 
exec Update_CAPTION_SETTING @cmp_id	  --Mukti 07012016
exec Update_Menu_setting @cmp_id  --Mukti 16012016
exec Update_Email_Notification_Config @cmp_id --Mukti 16012016
--Added by rohit For Default Module Entry on 16012016
 --Declare @sql as varchar(5000)
 --if not exists(select Name from sysobjects where xtype = 'U' and Name = 'T0011_module_detail')
	--begin
	--	set @sql = 'ALTER TABLE [dbo].[T0011_module_detail]([module_ID] [numeric](18, 0) NOT NULL,[module_name] [varchar](50) NULL,[Cmp_id] [numeric](18, 0) NULL,[module_status] [int] NULL) ON [PRIMARY]'
	--	execute(@sql)
	--	set @sql = 'ALTER PROCEDURE [dbo].[P0011_module_detail]@module_ID	numeric(18,0),@module_name varchar(50),@Cmp_id	numeric(18,0),@module_status int AS If Exists(Select module_ID From T0011_module_detail  Where Cmp_ID = @Cmp_ID and module_name = @module_name)begin set @module_ID = 0 Return end select @module_ID = Isnull(max(module_ID),0) + 1 	From T0011_module_detail INSERT INTO T0011_module_detail(module_ID,module_name,Cmp_id,module_status)VALUES(@module_ID,@module_name,@Cmp_id,@module_status)return'
	--	execute(@sql)
	--end
	
	exec P0011_module_detail 0,'HRMS',@cmp_id,0
	exec P0011_module_detail 0,'Appraisal1',@cmp_id,0
	exec P0011_module_detail 0,'Appraisal2',@cmp_id,0
	exec P0011_module_detail 0,'Appraisal3',@cmp_id,0 --THIS APPRAISAL FOR SCHEME
	exec P0011_module_detail 0,'MOBILE',@cmp_id,0 --THIS MOBILE Module added by rohit on 22072015
	exec P0011_module_detail 0,'GPF',@cmp_id,0 --Added by nilesh patel on 17082015
	exec P0011_module_detail 0,'CPS',@cmp_id,0 --Added by nilesh patel on 17082015
	exec P0011_module_detail 0,'Payroll',@cmp_id,1 --Added by rohit for Payroll Module on 16012016
	exec P0011_module_detail 0,'Timesheet',@cmp_id,0 --Added by Prakash Patel on 01032016
	exec P0011_module_detail 0,'Transport',@cmp_id,0 --Added by Prakash Patel on 01032016
	
	EXEC P0350_EXIT_CLEARANCE_STATUS @CMP_ID --ADDED BY JAINA FOR EXIT CLEARANCE STATUS 05-07-2016
	
-- Ended by rohit for Add default Module Status Entry.
*/
print 1
END


