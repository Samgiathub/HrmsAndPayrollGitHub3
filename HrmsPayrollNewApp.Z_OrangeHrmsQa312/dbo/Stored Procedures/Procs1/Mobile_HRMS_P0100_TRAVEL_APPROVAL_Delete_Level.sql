
CREATE PROCEDURE [dbo].[Mobile_HRMS_P0100_TRAVEL_APPROVAL_Delete_Level]
	-- @Tran_ID				NUMERIC(18,0)	
	 @Travel_Approval_ID NUMERIC(18,0)
	,@Travel_Application_ID NUMERIC(18,0)
	,@Cmp_ID				NUMERIC(18,0)
	,@Emp_ID				NUMERIC(18,0)
	,@S_Emp_ID				NUMERIC(18,0)
	,@Approval_Date			Datetime
	--,@Approval_Status		Char(1)
	--,@Approval_Comments		Varchar(250)
	,@Login_ID				NUMERIC(18,0)
	,@Rpt_Level				TinyInt
	--,@Total					Numeric(18,2)
	,@Type				Char(1) 
	--,@Attached_Doc_File		nvarchar(max)
	--,@User_Id				NUMERIC(18,0) = 0 
	--,@TourAgendaPlanned		XML
	--,@Travel_Details		XML
	--,@Travel_Adv_Details    XML
	--,@Travel_Other_Details  XML
	,@Result				VARCHAR(70)OUTPUT
	--,@TravelTypeId          NUMERIC(18,0)
	--,@Chk_International     NUMERIC(18,0) = 0
AS

BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	

	Declare @Create_Date As Datetime
	Declare @SchemeId as numeric(18,0)	  = 0
	Declare @ReportLevel as numeric(18,0) = 0

	--Declare @Create_Date As Datetime
	Declare @Modify_Date As Datetime
	Declare @leave_approval_id as numeric(18,0)
	Set @Create_Date = GETDATE()

	Set @Modify_Date = GETDATE()
	
	-- Add By Mukti 11072016(start)
	declare @OldValue as  varchar(max)
	Declare @String_val as varchar(max)
	set @String_val=''
	set @OldValue =''
	
	Set @Create_Date = GETDATE()

	declare @mx_rptlvl int
		SELECT @SchemeId = Scheme_ID 
		FROM T0095_EMP_SCHEME S
		INNER JOIN (
			SELECT max(Effective_Date) as EffDate,Tran_ID 
			FROM T0095_EMP_SCHEME S1 
			WHERE EMP_ID = @Emp_ID AND CMP_ID = @Cmp_ID AND [TYPE]='TRAVEL'
			group by Tran_id
		) Q1 on s.Effective_Date = Q1.EffDate and s.Tran_ID  = Q1.Tran_ID 
		WHERE EMP_ID = @Emp_ID AND CMP_ID = @Cmp_ID AND [TYPE]='TRAVEL'


	select @mx_rptlvl = max(Rpt_Level) from T0050_Scheme_Detail where Scheme_Id = @SchemeId

	

	If @S_Emp_ID = 0
	Begin 
		Set @S_Emp_ID = NULL


		DECLARE @KRA_Tour varchar(250) 
		DECLARE @IMP_Business_Appoint varchar(250) 
		DECLARE @Tour_Agenda varchar(250) 
		
		--SELECT @SchemeId = Scheme_ID 
		--FROM T0095_EMP_SCHEME S
		--INNER JOIN (
		--	SELECT max(Effective_Date) as EffDate,Tran_ID 
		--	FROM T0095_EMP_SCHEME S1 
		--	WHERE EMP_ID = @Emp_ID AND CMP_ID = @Cmp_ID AND [TYPE]='TRAVEL'
		--	group by Tran_id
		--) Q1 on s.Effective_Date = Q1.EffDate and s.Tran_ID  = Q1.Tran_ID 
		--WHERE EMP_ID = @Emp_ID AND CMP_ID = @Cmp_ID AND [TYPE]='TRAVEL'

		--select @SchemeId

		Select @ReportLevel = Rpt_Level  from T0115_TRAVEL_LEVEL_APPROVAL where  Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID 

		IF @ReportLevel = 0
		Begin
			Select @S_Emp_ID = S_Emp_ID  from T0100_TRAVEL_APPLICATION where  Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID 
			
			SELECT @ReportLevel = 
			sd.Rpt_Level 
			FROM T0050_SCHEME_DETAIL SD 
			INNER JOIN  T0080_DynHierarchy_Value DV on SD.Dyn_Hier_Id = DV.DynHierColId
			INNER JOIN T0095_INCREMENT I on I.Increment_ID = DV.IncrementId
			WHERE sd.Scheme_Id = @SchemeId and DV.DynHierColValue = @S_Emp_ID and Dv.Emp_ID = @Emp_ID and Dv.Cmp_ID = @Cmp_ID

			SELECT @ReportLevel = @ReportLevel + 1 
			set @S_Emp_ID = 0	
		END
		ELSE
		IF @ReportLevel > 0
		Begin
			Select @S_Emp_ID = S_Emp_ID  from T0115_TRAVEL_LEVEL_APPROVAL where  Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID order by Tran_Id desc
			
			SELECT @ReportLevel = 
			sd.Rpt_Level 
			FROM T0050_SCHEME_DETAIL SD 
			INNER JOIN  T0080_DynHierarchy_Value DV on SD.Dyn_Hier_Id = DV.DynHierColId
			INNER JOIN T0095_INCREMENT I on I.Increment_ID = DV.IncrementId
			WHERE sd.Scheme_Id = @SchemeId and DV.DynHierColValue = @S_Emp_ID and Dv.Emp_ID = @Emp_ID and Dv.Cmp_ID = @Cmp_ID

			SELECT @ReportLevel = @ReportLevel + 1 
			set @S_Emp_ID = 0	
		END
		ELSE
		BEGIN 
			SET @ReportLevel = @ReportLevel + 1
		END

		if @ReportLevel > 0
		Begin 
			IF isnull(@S_Emp_ID,0) = 0	
				select @S_Emp_ID = DynHierColValue from T0050_Scheme_Detail SD
				Inner join T0080_DynHierarchy_Value Dy
				on SD.Dyn_Hier_Id = DY.DynHierColId and sd.Scheme_Id = @SchemeId 
				and dy.Emp_ID = @Emp_ID and Rpt_Level = @ReportLevel
		END
	END
	--Select @Travel_Approval_ID = ISNULL(MAX(Travel_Approval_ID),0) + 1 From T0120_TRAVEL_APPROVAL WITH (NOLOCK)
	--select @Travel_Approval_ID
	 If UPPER(@Type) = 'D'
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
			--Added by Jaina 29-12-2017
			if exists (SELECT 1 FROM T0302_Payment_Process_Travel_Details PT WITH (NOLOCK) INNER JOIN 
									 MONTHLY_EMP_BANK_PAYMENT ME WITH (NOLOCK) ON PT.Payment_Process_Id = ME.payment_process_id INNER JOIN
									 T0120_TRAVEL_APPROVAL TA WITH (NOLOCK) ON TA.Travel_Approval_ID = PT.Travel_Approval_Id
					   WHERE PT.Cmp_ID=@Cmp_id AND PT.Travel_Approval_ID=@Travel_Approval_ID AND PT.Emp_Id = @Emp_ID)
					BEGIN
						Raiserror('@@Reference Exists in Payment Process@@',18,2)
						Return -1
					END
					
			If not Exists (select 1 from T0140_Travel_Settlement_Application WITH (NOLOCK) where Travel_Approval_ID=@Travel_Approval_ID and emp_id=@Emp_ID and DirectEntry!=1)
			begin
			
				--select * from T0130_TRAVEL_APPROVAL_DETAIL where Travel_Approval_ID = @Travel_Approval_ID 
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
					
						exec P0120_LEAVE_APPROVAL @Leave_Approval_ID=@leave_approval_id output,@Leave_Application_ID=0,@Cmp_ID=0,@Emp_ID=0,@S_Emp_ID=0,@Approval_Date = @Modify_Date,@Approval_Status='',@Approval_Comments='',@Login_ID=0,@System_Date = @Modify_Date,@Type='Delete'
						
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
					
					
					----Ankit 24062014
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
					----Ankit 24062014
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
			END

			end



--select from T0115_TRAVEL_APPROVAL_DETAIL_LEVEL 
--select * from T0115_TRAVEL_APPROVAL_OTHER_DETAIL_LEVEL 
--select * from T0115_TRAVEL_APPROVAL_OTHER_MODE_DETAIL_LEVEL
--select * from T0115_TRAVEL_APPROVAL_ADVDETAIL_LEVEL
--select * from  T0115_TRAVEL_LEVEL_APPROVAL

