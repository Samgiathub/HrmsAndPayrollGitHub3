

--Create by Binal 03012020 For new look of ESS
CREATE PROCEDURE [dbo].[P0000_ESS_HOME_Update]
as

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON


	 Declare @Under_Form_ID as Numeric(18,0)
	 Declare @Form_ID as Numeric(18,0)
	 Declare @Sort_ID as Numeric(18,0)
 
	Select	@Sort_ID = max(Sort_ID) 
	from	[dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK)
	
	Select	@Form_ID = MAX(Form_ID)+1 
	from	[dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK)
	
	Select	@Under_Form_ID = Form_ID 
	from	[dbo].[T0000_DEFAULT_FORM]  WITH (NOLOCK)
	where	Form_Name= 'TD_Home_ESS_201' and Alias='ESS Home Page'

	if exists (
				select	1 
				from	[dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK)
				where	Form_Name= 'TD_Home_ESS_221' and Alias='Policy Document'
				)
		begin
			if not exists (
							select	1 
							from	[dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK) 
							where	Form_Name= 'TD_Home_ESS_221' and Alias='Policy Document' and Under_Form_ID= @Under_Form_ID
							)
				begin
						Update	[dbo].[T0000_DEFAULT_FORM]  
						Set		Under_Form_ID = @Under_Form_ID
						where	Form_Name= 'TD_Home_ESS_221' and Alias='Policy Document' 
				end		
		end
 
  --select * from [dbo].[T0000_DEFAULT_FORM]  where Form_Name= 'TD_Home_ESS_222'  and Alias='New Joining Details'  and Under_Form_ID= @Under_Form_ID

	if exists (
				select	1 
				from	[dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK) 
				where	Form_Name= 'TD_Home_ESS_222' and Alias='New Joining Details'
				)
		begin
			if not exists (
							select	1 
							from	[dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK) 
							where	Form_Name= 'TD_Home_ESS_222' and Alias='New Joining Details' and Under_Form_ID = @Under_Form_ID
							)
				begin
						Update	[dbo].[T0000_DEFAULT_FORM] 
						Set		Under_Form_ID = @Under_Form_ID
						where	Form_Name= 'TD_Home_ESS_222' and Alias='New Joining Details' 
				end		
	end
 
	-- select * from [dbo].[T0000_DEFAULT_FORM]  where Form_Name= 'TD_Home_ESS_271' and Alias='Holiday Calendar' and Under_Form_ID= @Under_Form_ID
	if exists (
					select	1 
					from	[dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK) 
					where	Form_Name= 'TD_Home_ESS_271' and Alias='Holiday Calendar'
				)
		begin
			if not exists (
							select	1 
							from	[dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK) 
							where	Form_Name= 'TD_Home_ESS_271' and Alias='Holiday Calendar' and Under_Form_ID= @Under_Form_ID
							)
				begin
						Update	[dbo].[T0000_DEFAULT_FORM] 
						Set		Under_Form_ID = @Under_Form_ID
						where	Form_Name= 'TD_Home_ESS_271' and Alias='Holiday Calendar' 
				end		
		end
   
  -- select * from [dbo].[T0000_DEFAULT_FORM]  where Form_Name= 'TD_Home_ESS_303' and Alias='Birthday Reminder' and Under_Form_ID= @Under_Form_ID
	if exists (
				select	1 
				from	[dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK) 
				where	Form_Name= 'TD_Home_ESS_303' and Alias='Birthday Reminder'
				)
		begin
			if not exists (
							select	1 
							from	[dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK)  
							where	Form_Name= 'TD_Home_ESS_303' and Alias='Birthday Reminder' and Under_Form_ID = @Under_Form_ID
							)
				begin
						Update	[dbo].[T0000_DEFAULT_FORM] 
						Set		Under_Form_ID = @Under_Form_ID
						where	Form_Name= 'TD_Home_ESS_303' and Alias='Birthday Reminder' 
				end		
		end
  -- select * from [dbo].[T0000_DEFAULT_FORM]  where Form_Name= 'TD_Home_ESS_304' and Alias='Add & View Events' and Under_Form_ID= @Under_Form_ID

	if exists (
				select	1 
				from	[dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK) 
				where	Form_Name= 'TD_Home_ESS_304' and Alias='Add & View Events'
				)
		begin
			if not exists (
							select	1 
							from	[dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK) 
							where	Form_Name= 'TD_Home_ESS_304' and Alias='Add & View Events' and Under_Form_ID= @Under_Form_ID
							)
				begin
						Update	[dbo].[T0000_DEFAULT_FORM] 
						Set		Under_Form_ID = @Under_Form_ID
						where	Form_Name= 'TD_Home_ESS_304' and Alias='Add & View Events' 
				end		
		end

  -- select * from [dbo].[T0000_DEFAULT_FORM]  where Form_Name= 'TD_Home_ESS_306' and Alias='Wall Of Fame' and Under_Form_ID= @Under_Form_ID
	if exists (
				select	1 
				from	[dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK) 
				where	Form_Name= 'TD_Home_ESS_306' and Alias='Wall Of Fame'
				)
		begin
			if not exists (
							select	1 
							from	[dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK) 
							where	Form_Name= 'TD_Home_ESS_306' and Alias='Wall Of Fame' and Under_Form_ID= @Under_Form_ID
							)
				begin
						Update	[dbo].[T0000_DEFAULT_FORM] 
						Set		Under_Form_ID = @Under_Form_ID
						where	Form_Name= 'TD_Home_ESS_306' and Alias='Wall Of Fame' 
				end		
		end



	if exists (
				select	1 
				from	[dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK) 
				where	Form_Name= 'TD_Home_ESS_Marriage_307' and Alias='Marriage Anniversary'
				)
		begin
			if not exists (
							select	1 
							from	[dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK) 
							where	Form_Name= 'TD_Home_ESS_Marriage_307' and Alias='Marriage Anniversary' and Under_Form_ID= @Under_Form_ID
							)
				begin
						Update	[dbo].[T0000_DEFAULT_FORM] 
						Set		Under_Form_ID = @Under_Form_ID
						where	Form_Name= 'TD_Home_ESS_Marriage_307' and Alias='Marriage Anniversary' 
				end		
		end
	else	
		begin
			Select @Sort_ID= max(Sort_ID) + 1 from  [dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK)
			
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name]) 
			VALUES (@Form_ID, N'TD_Home_ESS_Marriage_307', @Under_Form_ID, @Sort_ID, 1, '', '', 1, N'Marriage Anniversary',NULL) 
		end

 
	if exists (
				select	1 
				from	[dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK) 
				where	Form_Name= 'TD_Home_ESS_Work_308' and Alias='Work Anniversary'
				)
		begin
			if not exists (
							select	1 
							from	[dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK)  
							where	Form_Name= 'TD_Home_ESS_Work_308' and Alias='Work Anniversary' and Under_Form_ID= @Under_Form_ID
							)
			begin
				Update	[dbo].[T0000_DEFAULT_FORM] 
				Set		Under_Form_ID = @Under_Form_ID
				where	Form_Name = 'TD_Home_ESS_Work_308' and Alias ='Work Anniversary' 
			end		
		end
	else	
		begin
			Select @Sort_ID= max(Sort_ID) + 1 from  [dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK)
			Set @Form_ID =@Form_ID +1 
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name]) 
			VALUES (@Form_ID, N'TD_Home_ESS_Work_308', @Under_Form_ID, @Sort_ID, 1, '', '', 1, N'Work Anniversary',NULL)
		end

	--if exists (
	--			select	1 
	--			from	[dbo].[T0000_DEFAULT_FORM]  
	--			where Form_Name= 'Card_001' and Alias='Employee & Team'
	--			)
	--	begin
	--		if not exists (
	--						select	1 
	--						from	[dbo].[T0000_DEFAULT_FORM]  
	--						where	Form_Name= 'Card_001' and Alias='Employee & Team' and Under_Form_ID= @Under_Form_ID
	--						)
	--			begin
	--					Update	[dbo].[T0000_DEFAULT_FORM] 
	--					Set		Under_Form_ID = @Under_Form_ID 
	--					where	Form_Name= 'Card_001' and Alias='Employee & Team' 
	--			end		
	--	end
	--else	
	--	begin
	--		Select @Sort_ID= max(Sort_ID) + 1 from  [dbo].[T0000_DEFAULT_FORM] 
	--		Set @Form_ID =@Form_ID +1 
	--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name]) 
	--		VALUES (@Form_ID, N'Card_001', @Under_Form_ID, @Sort_ID, 1, '', '', 1, N'Employee & Team',NULL)
	--	end

	--if exists (
	--			select	1 
	--			from	[dbo].[T0000_DEFAULT_FORM]  
	--			where	Form_Name= 'Card_002' and Alias='Attendance & Leave'
	--			)
	--	begin
	--		if not exists (
	--						select	1 
	--						from	[dbo].[T0000_DEFAULT_FORM]  
	--						where	Form_Name= 'Card_002' and Alias='Attendance & Leave' and Under_Form_ID = @Under_Form_ID
	--						)
	--			begin
	--					Update	[dbo].[T0000_DEFAULT_FORM] 
	--					Set		Under_Form_ID = @Under_Form_ID
	--					where	Form_Name= 'Card_002' and Alias='Attendance & Leave' 
	--			end		
	--	end
	--else	
	--	begin
	--		Select @Sort_ID= max(Sort_ID) + 1 from  [dbo].[T0000_DEFAULT_FORM] 
	--		Set @Form_ID =@Form_ID +1 
	--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name]) 
	--		VALUES (@Form_ID, N'Card_002', @Under_Form_ID, @Sort_ID, 1, '', '', 1, N'Attendance & Leave',NULL)
	--	end 
 
	--if exists (
	--			select	1 
	--			from	[dbo].[T0000_DEFAULT_FORM]  
	--			where	Form_Name= 'Card_003' and Alias='Salary'
	--			)
	--	begin
	--		if not exists (
	--						select	1 
	--						from	[dbo].[T0000_DEFAULT_FORM]  
	--						where	Form_Name= 'Card_003' and Alias='Salary' and Under_Form_ID = @Under_Form_ID
	--						)
	--		begin
	--				Update	[dbo].[T0000_DEFAULT_FORM] 
	--				Set		Under_Form_ID = @Under_Form_ID
	--				where	Form_Name= 'Card_003' and Alias='Salary' 
	--		end		
	--	end
	--else	
	--begin
	--	Select @Sort_ID= max(Sort_ID) + 1 from  [dbo].[T0000_DEFAULT_FORM] 
	--	Set @Form_ID =@Form_ID + 1 
	--	INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name]) 
	--	VALUES (@Form_ID, N'Card_003', @Under_Form_ID, @Sort_ID, 1, '', '', 1, N'Salary',NULL)
	--end 
 
	--if exists (
	--			select	1 
	--			from	[dbo].[T0000_DEFAULT_FORM]  
	--			where	Form_Name= 'Card_004' and Alias='Reports'
	--			)
	--	begin
	--		if not exists (
	--						select	1 
	--						from	[dbo].[T0000_DEFAULT_FORM]  
	--						where	Form_Name= 'Card_004' and Alias='Reports' and Under_Form_ID = @Under_Form_ID
	--						)
	--			begin
	--					Update	[dbo].[T0000_DEFAULT_FORM] 
	--					Set		Under_Form_ID = @Under_Form_ID
	--					where	Form_Name= 'Card_004' and Alias='Reports' 
	--			end		
	--	end
	--else	
	--	begin
	--		Select @Sort_ID= max(Sort_ID) + 1 from  [dbo].[T0000_DEFAULT_FORM] 
	--		Set @Form_ID =@Form_ID + 1 
	--		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name]) 
	--		VALUES (@Form_ID, N'Card_004', @Under_Form_ID, @Sort_ID, 1, '', '', 1, N'Reports',NULL)
	--	end 
	--comented above binal and new added below
	set @Under_Form_ID=0
	Select	@Under_Form_ID = Form_ID 
	from	[dbo].[T0000_DEFAULT_FORM]  WITH (NOLOCK)
	where	Form_Name= 'TD_Home_ESS_201' and Alias='ESS Home Page'	

	if exists (
				select	1 
				from	[dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK)
				where Form_Name= 'Card_001' and (Alias='Employee & Team' or Alias='Employee & Team Dashboard')
				)
		begin
			if not exists (
							select	1 
							from	[dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK) 
							where	Form_Name= 'Card_001' and (Alias='Employee & Team' or Alias='Employee & Team Dashboard') and Under_Form_ID= @Under_Form_ID
							)
				begin
						Update	[dbo].[T0000_DEFAULT_FORM] 
						Set		Under_Form_ID = @Under_Form_ID 
						where	Form_Name= 'Card_001' --and Alias='Employee & Team Dashboard' 
				end		
		end
	else	
		begin
			Select @Sort_ID= max(Sort_ID) + 1 from  [dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK)
			Set @Form_ID =@Form_ID +1 
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name]) 
			VALUES (@Form_ID, N'Card_001', @Under_Form_ID, @Sort_ID, 1, '', '', 1, N'Employee & Team Dashboard',NULL)
		end

	if exists (
				select	1 
				from	[dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK)
				where	Form_Name= 'Card_002' and (Alias='Attendance & Leave' or Alias='Attendance & Leave Dashboard')
				)
		begin
			if not exists (
							select	1 
							from	[dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK) 
							where	Form_Name= 'Card_002' and (Alias='Attendance & Leave' or Alias='Attendance & Leave Dashboard') and Under_Form_ID = @Under_Form_ID
							)
				begin				
						Update	[dbo].[T0000_DEFAULT_FORM] 
						Set		Under_Form_ID = @Under_Form_ID
						where	Form_Name= 'Card_002' --and Alias='Attendance & Leave Dashboard' 
				end		
		end
	else	
		begin		
			Select @Sort_ID= max(Sort_ID) + 1 from  [dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK)
			Set @Form_ID =@Form_ID +1 
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name]) 
			VALUES (@Form_ID, N'Card_002', @Under_Form_ID, @Sort_ID, 1, '', '', 1, N'Attendance & Leave Dashboard',NULL)
		end 
 
	if exists (
				select	1 
				from	[dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK) 
				where	Form_Name= 'Card_003' and (Alias='Salary' or Alias='Salary Dashboard')
				)
		begin
			if not exists (
							select	1 
							from	[dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK) 
							where	Form_Name= 'Card_003' and (Alias='Salary' or Alias='Salary Dashboard') and Under_Form_ID = @Under_Form_ID
							)
			begin
					Update	[dbo].[T0000_DEFAULT_FORM] 
					Set		Under_Form_ID = @Under_Form_ID
					where	Form_Name= 'Card_003' --and Alias='Salary Dashboard' 
			end		
		end
	else	
	begin
		Select @Sort_ID= max(Sort_ID) + 1 from  [dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK)
		Set @Form_ID =@Form_ID + 1 
		INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name]) 
		VALUES (@Form_ID, N'Card_003', @Under_Form_ID, @Sort_ID, 1, '', '', 1, N'Salary Dashboard',NULL)
	end 
 
	if exists (
				select	1 
				from	[dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK) 
				where	Form_Name= 'Card_004' and (Alias='Reports' or Alias='Reports Dashboard')
				)
		begin
			if not exists (
							select	1 
							from	[dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK) 
							where	Form_Name= 'Card_004' and (Alias='Reports' or Alias='Reports Dashboard') and Under_Form_ID = @Under_Form_ID
							)
				begin
						Update	[dbo].[T0000_DEFAULT_FORM] 
						Set		Under_Form_ID = @Under_Form_ID
						where	Form_Name= 'Card_004' --and Alias='Reports Dashboard'  
				end		
		end
	else	
		begin
			Select @Sort_ID= max(Sort_ID) + 1 from  [dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK)
			Set @Form_ID =@Form_ID + 1 
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name]) 
			VALUES (@Form_ID, N'Card_004', @Under_Form_ID, @Sort_ID, 1, '', '', 1, N'Reports Dashboard',NULL)
		end

	if exists (
				select	1 
				from	[dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK) 
				where	Form_Name= 'TD_Home_ESS_330' and Alias='Todays Thought'
				)
		begin
			if not exists (
							select	1 
							from	[dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK) 
							where	Form_Name= 'TD_Home_ESS_330' and Alias='Todays Thought' and Under_Form_ID = @Under_Form_ID
							)
				begin
						Update	[dbo].[T0000_DEFAULT_FORM] 
						Set		Under_Form_ID = @Under_Form_ID
						where	Form_Name= 'TD_Home_ESS_330' and Alias='Todays Thought' 
				end		
		end
	else	
		begin
			Select @Sort_ID= max(Sort_ID) + 1 from  [dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK)
			Set @Form_ID =@Form_ID + 1 
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name]) 
			VALUES (@Form_ID, N'TD_Home_ESS_330', @Under_Form_ID, @Sort_ID, 1, '', '', 1, N'Todays Thought',NULL)
		end 


	if exists (
				select	1 
				from	[dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK) 
				where	Form_Name= 'TD_Home_ESS_321' and Alias='Left Panel'
				)
		begin
			if  exists (
							select	1 
							from	[dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK) 
							where	Form_Name= 'TD_Home_ESS_321' and Alias='Left Panel' and Under_Form_ID = @Under_Form_ID
							)
				begin
					Update	[dbo].[T0000_DEFAULT_FORM] 
					Set		Under_Form_ID = @Under_Form_ID,Alias='Right Panel' 
					where	Form_Name= 'TD_Home_ESS_321' and Alias='Left Panel' 
				end		
			else
				begin
					if not exists (
						select	1 
						from	[dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK) 
						where	Form_Name= 'TD_Home_ESS_321' and Alias='Right Panel'
						)
						begin

							Select @Sort_ID= max(Sort_ID) + 1 from  [dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK)
							Set @Form_ID =@Form_ID + 1 
							INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name]) 
							VALUES (@Form_ID, N'TD_Home_ESS_321', @Under_Form_ID, @Sort_ID, 1, '', '', 1, N'Right Panel',NULL)
						end 
				end 
				
		end
	else	
		begin
			if not exists (
				select	1 
				from	[dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK) 
				where	Form_Name= 'TD_Home_ESS_321' and Alias='Right Panel'
				)
				begin
					Select @Sort_ID= max(Sort_ID) + 1 from  [dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK)
					Set @Form_ID =@Form_ID + 1 
					INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name]) 
					VALUES (@Form_ID, N'TD_Home_ESS_321', @Under_Form_ID, @Sort_ID, 1, '', '', 1, N'Right Panel',NULL)
				end
	end 

 if exists (
			select	1 
			from	[dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK) 
			where	Form_Name= 'TD_Home_ESS_261' and Alias='My Links'
			)
	begin
	
		if exists (
						select	1 
						from	[dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK) 
						where	Form_Name= 'TD_Home_ESS_261' and Alias='My Links' and Under_Form_ID = @Under_Form_ID
						)
				begin

					
					Update [dbo].[T0000_DEFAULT_FORM] 
					Set Under_Form_ID = @Under_Form_ID,Alias='Reminders & Notifications' 
					where Form_Name= 'TD_Home_ESS_261' and Alias='My Links' 
				end	
			else
				begin
					if not exists (
							select	1 
							from	[dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK) 
							where	Form_Name= 'TD_Home_ESS_261' and Alias='Reminders & Notifications'
							)
						begin	
							Select @Sort_ID= max(Sort_ID) + 1 from  [dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK)
							Set @Form_ID =@Form_ID + 1 
							INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name]) 
							VALUES (@Form_ID, N'TD_Home_ESS_261', @Under_Form_ID, @Sort_ID, 1, '', '', 1, N'Reminders & Notifications',NULL)
						end 
				end 
					
	end
 else	
	begin
		 if not exists (
				select	1 
				from	[dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK) 
				where	Form_Name= 'TD_Home_ESS_261' and Alias='Reminders & Notifications'
				)
			begin	
				Select @Sort_ID= max(Sort_ID) + 1 from  [dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK)
				Set @Form_ID =@Form_ID + 1 
				INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name]) 
				VALUES (@Form_ID, N'TD_Home_ESS_261', @Under_Form_ID, @Sort_ID, 1, '', '', 1, N'Reminders & Notifications',NULL)
			end
	end 

  
	if exists (
				select	1 
				from	[dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK) 
				where	Form_Name= 'TD_Home_ESS_310' and Alias='Training Calender'
				)
		begin
			if not exists (
							select	1 
							from	[dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK)  
							where Form_Name= 'TD_Home_ESS_310' and Alias='Training Calender' and Under_Form_ID = @Under_Form_ID
							)
				begin
					Update [dbo].[T0000_DEFAULT_FORM] 
					Set Under_Form_ID = @Under_Form_ID
					where Form_Name= 'TD_Home_ESS_310' and Alias='Training Calender' 
				end		
		end
	else	
		begin
			Select @Sort_ID= max(Sort_ID) + 1 from  [dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK)
			Set @Form_ID =@Form_ID + 1 
			INSERT INTO [dbo].[T0000_DEFAULT_FORM]([Form_ID], [Form_Name], [Under_Form_ID], [Sort_ID], [Form_Type], [Form_url], [Form_Image_url], [Is_Active_For_menu], [Alias],[Module_name]) 
			VALUES (@Form_ID, N'TD_Home_ESS_310', @Under_Form_ID, @Sort_ID, 1, '', '', 1, N'Training Calender',NULL)
		end 


	/* Reset position of last login activity 13012020 note 9348 is left panel id form id*/


	Select @Sort_ID= max(Sort_ID) + 1 from  [dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK)
	Update [dbo].[T0000_DEFAULT_FORM]
	Set  [Under_Form_ID]=9348
	where [Form_Name]='TD_Home_ESS_322' and  [Under_Form_ID]=9321 and [Alias]='Last Login Activity'
	


  /*remove old Right Panel option from home */
  if exists (select 1 from [dbo].[T0000_DEFAULT_FORM]  WITH (NOLOCK) where Form_Name= 'TD_Home_ESS_301' and Alias='Right Panel'  )
	begin 
		delete from [dbo].[T0000_DEFAULT_FORM]  where Form_Name= 'TD_Home_ESS_301' and Alias='Right Panel' 
	end 


	 /*remove old Center Panel option from home */

	 if exists (select 1 from [dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK) where Form_Name= 'TD_Home_ESS_220' and Alias='Center panel'  )
	begin 
		delete from [dbo].[T0000_DEFAULT_FORM]  where Form_Name= 'TD_Home_ESS_220' and Alias='Center panel' 
	end 


	 /*remove old View Graphical Report option from home */

	if exists (select 1 from [dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK)  where Form_Name= 'TD_Home_ESS_279'  and Alias= 'View Graphical Report'  )
	begin 
		delete from [dbo].[T0000_DEFAULT_FORM]  where Form_Name= 'TD_Home_ESS_279'  and Alias= 'View Graphical Report'
	end 

	
	
 /*remove my team option from home notification*/
  if exists (select 1 from [dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK) where Form_Name= 'TD_Home_ESS_263' and Alias='My Team Member Details'  )
	begin 
		delete from [dbo].[T0000_DEFAULT_FORM]  where Form_Name= 'TD_Home_ESS_263' and Alias='My Team Member Details' 
	end 

   /*remove Message Board option from home remove it in future*/
  if exists (select 1 from [dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK) where Form_Name= 'TD_Home_ESS_305' and Alias='Message Board')
	begin 
		delete from [dbo].[T0000_DEFAULT_FORM]  where Form_Name= 'TD_Home_ESS_305' and Alias='Message Board' 
	end 

  /*remove Post Request option from home remove it in future*/
  if exists (select 1 from [dbo].[T0000_DEFAULT_FORM] WITH (NOLOCK) where Form_Name= 'TD_Home_ESS_302' and Alias='Post Request')
	begin 
		delete from [dbo].[T0000_DEFAULT_FORM]  where Form_Name= 'TD_Home_ESS_302' and Alias='Post Request' 
	end 
