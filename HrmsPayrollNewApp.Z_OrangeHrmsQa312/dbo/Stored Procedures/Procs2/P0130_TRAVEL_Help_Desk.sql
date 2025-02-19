
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0130_TRAVEL_Help_Desk]
	 @Tran_Id	NUMERIC(18,0) OUTPUT
	,@Travel_Approval_ID		NUMERIC(18,0)
	,@Cmp_ID					NUMERIC(18,0)
	,@Emp_ID			NUMERIC(18,0)
	,@File_Name			Varchar(200)
	,@Remarks					Nvarchar(500)
	,@Tran_Type					Char(1) 
	,@User_Id numeric(18,0) = 0 -- Add By Mukti 11072016
    ,@IP_Address varchar(30)= '' -- Add By Mukti 11072016 
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	-- Add By Mukti 11072016(start)
	declare @OldValue as  varchar(max)
	Declare @String_val as varchar(max)
	set @String_val=''
	set @OldValue =''
	-- Add By Mukti 11072016(end)
		
	If UPPER(@Tran_Type) = 'I'
		Begin
			select @Tran_Id =ISNULL(MAX(tran_id),0) + 1 from T0130_TRAVEL_Help_Desk  WITH (NOLOCK)
			
			Insert Into T0130_TRAVEL_Help_Desk
					(Tran_id, Travel_Approval_ID ,Cmp_ID ,Emp_ID, File_Name, Remarks)
				Values (@Tran_Id, @Travel_Approval_ID,@Cmp_ID,@Emp_ID,  @File_Name, @Remarks)
			
				-- Add By Mukti 11072016(start)
					exec P9999_Audit_get @table = 'T0130_TRAVEL_Help_Desk' ,@key_column='Tran_id',@key_Values=@Tran_id,@String=@String_val output
					set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))	 
				-- Add By Mukti 11072016(end)					
		End
			
	If UPPER(@Tran_Type) = 'U'
		Begin			
			-- Add By Mukti 11072016(start)
				exec P9999_Audit_get @table='T0130_TRAVEL_Help_Desk' ,@key_column='Tran_id',@key_Values=@Tran_id,@String=@String_val output
				set @OldValue = @OldValue + 'old Value' + '#' + cast(@String_val as varchar(max))
			-- Add By Mukti 11072016(end)
		
			Update T0130_TRAVEL_Help_Desk
			set File_Name = @File_Name,
			Remarks = @Remarks
			where Tran_id=@Tran_Id and Travel_Approval_ID=@Travel_Approval_ID
			
			-- Add By Mukti 11072016(start)
					exec P9999_Audit_get @table = 'T0130_TRAVEL_Help_Desk' ,@key_column='Tran_id',@key_Values=@Tran_id,@String=@String_val output
					set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))	 
			-- Add By Mukti 11072016(end)
		End
		
		If UPPER(@Tran_Type) = 'D'
		Begin
			If not Exists (select 1 from T0140_Travel_Settlement_Application WITH (NOLOCK) where Travel_Approval_ID=@Travel_Approval_ID and emp_id=@Emp_ID)
			begin
				-- Add By Mukti 11072016(start)
					exec P9999_Audit_get @table='T0130_TRAVEL_Help_Desk' ,@key_column='Tran_id',@key_Values=@Tran_id,@String=@String_val output
					set @OldValue = @OldValue + 'old Value' + '#' + cast(@String_val as varchar(max))
				-- Add By Mukti 11072016(end)
			
				delete From T0130_TRAVEL_Help_Desk where Travel_Approval_ID=@Travel_Approval_ID
				update T0120_TRAVEL_APPROVAL set Approved_Status_Help_Desk ='P',Comments_Help_Desk = '' where Travel_Approval_ID = Travel_Approval_ID
			end
			else
			begin 
					Raiserror('@@travel Settlement is Exist for Travel Approval@@',18,2)
					Return -1
			end
		End
	
	  exec P9999_Audit_Trail @CMP_ID,@Tran_Type,'Travel Help Desk',@OldValue,@Emp_ID,@User_Id,@IP_Address,1	
END

