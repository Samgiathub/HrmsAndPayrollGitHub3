CREATE PROCEDURE [dbo].[MOBILE_HRMS_P0120_TRAVEL_APPROVAL]
	 @Travel_Approval_ID	NUMERIC(18,0)	OUTPUT
	,@Travel_Application_ID NUMERIC(18,0)
	,@Cmp_ID				NUMERIC(18,0)
	,@Emp_ID				NUMERIC(18,0)
	,@S_Emp_ID				NUMERIC(18,0)
	,@Approval_Date			Datetime
	,@Approval_Status		Char(1)
	,@Approval_Comments		Varchar(250)
	,@Login_ID				NUMERIC(18,0)
	,@Is_Import				Int
	,@Total					Numeric(18,2)
	,@chk_Adv				tinyint
	,@chk_Agenda			tinyint
	,@Tour_Agenda			nvarchar(Max)
	,@IMP_Business_Appoint  nvarchar(Max)
	,@KRA_Tour				nvarchar(max)
	,@Attached_Doc_File		nvarchar(max)
	,@Tran_Type				Char(1) 
	,@User_Id				numeric(18,0) = 0 
	,@IP_Address		    varchar(30)= ''
	,@Travel_Other_Details  		xml = ''
	,@Travel_Adv_Details    		xml = ''
	,@Travel_Details        		xml = ''
	,@TravelTypeId			NUMERIC(18,0)
	
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
	Declare @Create_Date As Datetime
	Declare @Modify_Date As Datetime
	Declare @leave_approval_id as numeric(18,0)
	Set @Create_Date = GETDATE()
	Set @Modify_Date = GETDATE()
	
	declare @OldValue as  varchar(max)
	Declare @String_val as varchar(max)
	set @String_val=''
	set @OldValue =''

	If @S_Emp_ID = 0
		Set @S_Emp_ID = NULL


	
	If UPPER(@Tran_Type) = 'I'
		Begin

			IF not exists(select travel_application_id from T0120_TRAVEL_APPROVAL WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Emp_ID=@Emp_ID and Travel_Application_ID=@Travel_Application_ID) --Add exist condition by sumit 25/09/2014
			begin
				Select @Travel_Approval_ID = ISNULL(MAX(Travel_Approval_ID),0) + 1 From T0120_TRAVEL_APPROVAL WITH (NOLOCK)
				
				Insert Into T0120_TRAVEL_APPROVAL
				(Travel_Approval_ID,Travel_Application_ID, Cmp_ID, Emp_ID, S_Emp_ID, Approval_Date, Approval_Status,Approval_Comments, Login_ID,Is_Import,Total, Create_Date,chk_Adv,chk_Agenda,Tour_Agenda,IMP_Business_Appoint,KRA_Tour,Attached_Doc_File)
				Values (@Travel_Approval_ID, @Travel_Application_ID, @Cmp_ID, @Emp_ID, @S_Emp_ID, @Approval_Date,@Approval_Status, @Approval_Comments, @Login_ID, @Is_Import,@Total, @Create_Date,@chk_Adv,@chk_Agenda,@Tour_Agenda,@IMP_Business_Appoint,@KRA_Tour,@Attached_Doc_File)
				

				Update T0100_TRAVEL_APPLICATION set Application_Status=@Approval_Status where Travel_Application_ID=@Travel_Application_ID
					exec P9999_Audit_get @table = 'T0120_TRAVEL_APPROVAL' ,@key_column='Travel_Approval_ID',@key_Values=@Travel_Approval_ID,@String=@String_val output
					set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))	 
			
			end
		End
	Else If UPPER(@Tran_Type) = 'U'
		Begin
					exec P9999_Audit_get @table='T0120_TRAVEL_APPROVAL' ,@key_column='Travel_Approval_ID',@key_Values=@Travel_Approval_ID,@String=@String_val output
					set @OldValue = @OldValue + 'old Value' + '#' + cast(@String_val as varchar(max))
			
			update T0120_TRAVEL_APPROVAL
			set Approval_Date=@Approval_Date,
			Approval_Status=@Approval_Status,
			Approval_Comments=@Approval_Comments, 
			Total=@Total,
			chk_Adv=@chk_Adv,
			chk_Agenda=@chk_Agenda,
			Attached_Doc_File=@Attached_Doc_File,
			Tour_Agenda=@Tour_Agenda,
			IMP_Business_Appoint=@IMP_Business_Appoint,
			KRA_Tour=@KRA_Tour,
			Is_Import=@Is_Import
			where Cmp_ID=@Cmp_ID and Travel_Approval_ID=@Travel_Approval_ID 
			and Travel_Application_ID=@Travel_Application_ID
			
			Update T0100_TRAVEL_APPLICATION set Application_Status=@Approval_Status where Travel_Application_ID=@Travel_Application_ID
			
			-- Add By Mukti 11072016(start)
				exec P9999_Audit_get @table = 'T0120_TRAVEL_APPROVAL' ,@key_column='Travel_Approval_ID',@key_Values=@Travel_Approval_ID,@String=@String_val output
				set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))
			-- Add By Mukti 11072016(end) 
		End	
	Else If UPPER(@Tran_Type) = 'D'
		Begin
				declare @chk_reference as varchar(20)
				select @chk_reference=Approved_Account_Advance_desk from T0120_TRAVEL_APPROVAL WITH (NOLOCK) where Travel_Approval_ID=@Travel_Approval_ID and emp_id=@Emp_ID
				if @chk_reference='A' or @chk_reference='R' and @chk_reference <> null
					begin
						Raiserror('@@Travel Account Desk Detail Exist for Travel Approval@@',18,2)
						Return -1
					End
			if Exists( select Emp_ID from T0140_Travel_Settlement_Group_Emp WITH (NOLOCK) where Travel_Approval_ID=@Travel_Approval_ID and Cmp_ID=@Cmp_ID and Emp_ID=@Emp_ID)
					begin
						Raiserror('@@Reference Exists in Group Employees in Settlement@@',18,2)
						Return -1
					End	

			if exists (SELECT 1 FROM T0302_Payment_Process_Travel_Details PT WITH (NOLOCK) INNER JOIN 
									 MONTHLY_EMP_BANK_PAYMENT ME WITH (NOLOCK) ON PT.Payment_Process_Id = ME.payment_process_id INNER JOIN
									 T0120_TRAVEL_APPROVAL TA WITH (NOLOCK) ON TA.Travel_Approval_ID = PT.Travel_Approval_Id
					   WHERE PT.Cmp_ID=@Cmp_id AND PT.Travel_Approval_ID=@Travel_Approval_ID AND PT.Emp_Id = @Emp_ID)
					BEGIN
						Raiserror('@@Reference Exists in Payment Process@@',18,2)
						Return -1
					END
					
			If not Exists (select 1 from T0140_Travel_Settlement_Application WITH (NOLOCK) where Travel_Approval_ID=@Travel_Approval_ID and emp_id=@Emp_ID)
			begin
				if not Exists (select 1 from t0130_travel_help_desk WITH (NOLOCK) where Travel_Approval_ID=@Travel_Approval_ID and emp_id=@Emp_ID)
				BEGIN
				-- Add By Mukti 11072016(start)
					exec P9999_Audit_get @table='T0120_TRAVEL_APPROVAL' ,@key_column='Travel_Approval_ID',@key_Values=@Travel_Approval_ID,@String=@String_val output
					set @OldValue = @OldValue + 'old Value' + '#' + cast(@String_val as varchar(max))
				-- Add By Mukti 11072016(end)
			
					declare curLeave cursor Fast_forward for                    
					select leave_approval_id from T0130_TRAVEL_APPROVAL_DETAIL WITH (NOLOCK) where Travel_Approval_ID = @Travel_Approval_ID 
					open curLeave
					fetch next from curLeave into @leave_approval_id
					while @@fetch_status = 0      
					begin
					
						exec P0120_LEAVE_APPROVAL @Leave_Approval_ID=@leave_approval_id output,@Leave_Application_ID=0,@Cmp_ID=0,@Emp_ID=0,@S_Emp_ID=0,@Approval_Date = @Modify_Date,@Approval_Status='',@Approval_Comments='',@Login_ID=0,@System_Date = @Modify_Date,@tran_type='Delete'
						
						fetch next from curLeave into @leave_approval_id
					end                    
					close curLeave                    
					deallocate curLeave

					update T0100_TRAVEL_APPLICATION set Application_Status='P' where Travel_Application_ID= @Travel_Application_ID

					Delete From dbo.T0080_Emp_Travel_Proof where TravelApp_Code=(Select distinct Application_Code from T0100_TRAVEL_APPLICATION where Travel_Application_ID= @Travel_Application_ID) and Emp_ID=@Emp_ID and Cmp_ID=@Cmp_ID
					DELETE FROM dbo.t0130_travel_approval_other_detail where Travel_Approval_ID= @Travel_Approval_ID	
					DELETE FROM dbo.T0130_TRAVEL_APPROVAL_ADVDETAIL where Travel_Approval_ID=@Travel_Approval_ID
					DELETE FROM dbo.T0130_TRAVEL_APPROVAL_DETAIL where  Travel_Approval_ID = @Travel_Approval_ID   
					DELETE FROM dbo.T0120_TRAVEL_APPROVAL where Travel_Approval_ID= @Travel_Approval_ID
					-- ADDED ON 15072019
					DELETE FROM dbo.T0130_TRAVEL_APPROVAL_OTHER_MODE_DETAIL WHERE TRAVEL_APPROVAL_ID= @TRAVEL_APPROVAL_ID 
					
					declare @Tran_id as numeric(18,0)
					declare @Rm_emp_id as numeric(18,0)
					set @Rm_emp_id = 0
					set @Tran_id = 0
					
					Select @Rm_emp_id = S_Emp_ID,@Tran_id = Tran_ID from T0115_TRAVEL_LEVEL_APPROVAL WITH (NOLOCK) where  Travel_Application_ID= @Travel_Application_ID AND Rpt_Level IN (SELECT max(Rpt_Level) from T0115_TRAVEL_LEVEL_APPROVAL WITH (NOLOCK) where Travel_Application_ID= @Travel_Application_ID )


					If @Rm_emp_id = @S_Emp_ID 
						Begin
							Delete from T0115_TRAVEL_APPROVAL_ADVDETAIL_LEVEL Where Tran_ID = @Tran_id
							Delete from T0115_TRAVEL_APPROVAL_OTHER_DETAIL_LEVEL Where Tran_ID = @Tran_id
							Delete from T0115_TRAVEL_APPROVAL_DETAIL_LEVEL Where Tran_ID = @Tran_id
							Delete from T0115_TRAVEL_LEVEL_APPROVAL Where Tran_ID = @Tran_id and Travel_Application_ID= @Travel_Application_ID
							
							DELETE FROM T0115_TRAVEL_APPROVAL_OTHER_MODE_DETAIL_LEVEL WHERE OTHER_TRAN_ID = @TRAN_ID
						End
					Else
						Begin
							Delete from T0115_TRAVEL_APPROVAL_ADVDETAIL_LEVEL Where Tran_ID = @Tran_id
							Delete from T0115_TRAVEL_APPROVAL_OTHER_DETAIL_LEVEL Where Tran_ID = @Tran_id
							Delete from T0115_TRAVEL_APPROVAL_DETAIL_LEVEL Where Tran_ID = @Tran_id
							Delete from T0115_TRAVEL_LEVEL_APPROVAL Where Tran_ID = @Tran_id
							
							DELETE FROM T0115_TRAVEL_APPROVAL_OTHER_MODE_DETAIL_LEVEL WHERE OTHER_TRAN_ID = @TRAN_ID
						End	

					End
					Else
					Begin
						Raiserror('@@Travel Approval From Help Desk Exist@@',18,2)
						Return -1
					End
			end
			else
			begin 
			Raiserror('@@travel Settlement is Exist for Travel Approval@@',18,2)
              Return -1
			end

		End

		EXEC P9999_Audit_Trail @CMP_ID,@Tran_Type,'Travel Approval',@OldValue,@Emp_ID,@User_Id,@IP_Address,1

		EXEC Mobile_HRMS_P0130_TRAVEL_APPROVAL_DETAIL @Cmp_ID=@Cmp_ID,
		@Travel_App_ID=@Travel_Application_ID,@Instruct_Emp_ID=@Emp_ID,@Tran_Type=@Tran_Type,@User_Id=@User_Id,
		@Tran_ID=@Tran_ID,@Travel_Details= @Travel_Details,@TravelTypeId=@TravelTypeId,@Travel_Approval_ID = @Travel_Approval_ID
		,@Travel_Approval_Detail_ID = 0

		EXEC Mobile_HRMS_P0130_TRAVEL_Approval_OTHER_DETAIL @Travel_Apr_Other_Detail_Id = 0,@Tran_Type = @Tran_Type,@Tran_ID =@Tran_ID,
		@Cmp_ID=@Cmp_ID,@Travel_Other_Details = @Travel_Other_Details,@Travel_Approval_ID = @Travel_Approval_ID	

		EXEC Mobile_HRMS_P0130_TRAVEL_APPROVAL_ADVDETAIL @Row_Adv_ID = 0,@Travel_App_ID = @Travel_Application_ID, @Cmp_ID = @Cmp_ID,
		@Tran_ID = @Tran_ID, @Tran_Type = @Tran_Type, @Travel_Adv_Details = @Travel_Adv_Details,@Travel_Approval_ID = @Travel_Approval_ID,
		@Travel_Approval_AdvDetail_ID = 0
END

