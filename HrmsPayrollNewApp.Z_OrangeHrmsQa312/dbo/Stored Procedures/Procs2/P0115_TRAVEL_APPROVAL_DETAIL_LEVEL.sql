

CREATE PROCEDURE [dbo].[P0115_TRAVEL_APPROVAL_DETAIL_LEVEL]
	 @Row_ID					NUMERIC(18,0) OUTPUT
	,@Travel_App_ID				NUMERIC(18,0)
	,@Tran_ID					NUMERIC(18,0)
	,@Cmp_ID					NUMERIC(18,0)
	,@Place_Of_Visit			Varchar(100)
	,@Travel_Purpose			Varchar(200)
	,@Instruct_Emp_ID			NUMERIC(18,0)
	,@Travel_Mode_ID			NUMERIC(18,0)
	,@From_Date					Datetime
	,@Period					NUMERIC(18,2)
	,@To_Date					Datetime
	,@Remarks					Nvarchar(500)
	,@Leave_Approval_ID			Numeric(18,0)
	,@Leave_ID					Numeric(18,0)
	,@State_ID					numeric(18,0)=0
	,@City_ID					numeric(18,0)=0
	,@Loc_ID					numeric(18,0)=0
	,@Project_ID				numeric(18,0)=0
	,@Tran_Type					Char(1) 
	,@Half_Leave_Date			Datetime = Null --Added by Jaina 09-10-2017
	,@LeaveType					varchar(50) = '' --Added by Jaina 09-10-2017
	,@Night_Day					numeric(18,0) = 0 --Added by Jaina 12-10-2017
	,@From_State_ID					numeric(18,0)=0
	,@From_City_ID					numeric(18,0)=0
	,@Reason_ID    numeric(18,0)=0 -- Added by Yogesh on 27062024    
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	if (@Loc_ID=0)
		Begin
			set @Loc_ID=null;
		End
	if (@Project_ID=0)
		Begin
			set @Project_ID=null;
		End
	
	if @Half_Leave_Date = '01-01-1990' --Added by Jaina 10-10-2017
		set @Half_Leave_Date = NULL
		
	--SELECT @Cmp_ID = Cmp_ID FROM T0115_TRAVEL_LEVEL_APPROVAL WHERE Tran_ID = @Tran_ID 
	
	If UPPER(@Tran_Type) = 'I'
		Begin
		if not exists(select Row_ID from T0115_TRAVEL_APPROVAL_DETAIL_LEVEL WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Travel_Application_Id=@Travel_App_ID and Travel_Purpose=@Travel_Purpose and from_date=@From_Date and To_Date=@To_Date and State_ID=@State_ID and City_ID=@City_ID)
			Begin
				Select @Row_ID = ISNULL(MAX(Row_ID),0) + 1 From T0115_TRAVEL_APPROVAL_DETAIL_LEVEL WITH (NOLOCK)
			
				Insert Into T0115_TRAVEL_APPROVAL_DETAIL_LEVEL
					(Row_ID,Tran_ID, Cmp_ID, Travel_Application_Id, Place_Of_Visit, Travel_Purpose, Instruct_Emp_ID, Travel_Mode_ID, 
					 From_Date, Period, To_Date, Remarks,Leave_Approval_ID,Leave_ID,State_ID,City_ID,Loc_ID,Project_ID,Half_Leave_Date,Leavetype,Night_Day,From_state_id,From_City_id,Reason_id)
				Values (@Row_ID,@Tran_ID, @Cmp_ID, @Travel_App_ID, @Place_Of_Visit, @Travel_Purpose, @Instruct_Emp_ID, @Travel_Mode_ID,
						@From_Date, @Period, @To_Date, @Remarks,@Leave_Approval_ID,@Leave_ID,@State_ID,@City_ID,@Loc_ID,@Project_ID,@Half_Leave_Date,@Leavetype,@Night_Day,@From_State_ID,@From_City_ID,@Reason_ID)
			End	
		Else
			Begin
			if not exists(select Row_ID from T0115_TRAVEL_APPROVAL_DETAIL_LEVEL WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Travel_Application_Id=@Travel_App_ID and Travel_Purpose=@Travel_Purpose and from_date=@From_Date and To_Date=@To_Date and State_ID=@State_ID and City_ID=@City_ID and Leave_ID=@Leave_ID)
			Begin
			if (@Leave_ID != 0)
				Begin
				update T0115_TRAVEL_APPROVAL_DETAIL_LEVEL set Leave_ID=@Leave_ID,Night_Day = @Night_Day 
					where Cmp_ID=@Cmp_ID and Leave_ID=0 and Travel_Application_Id=@Travel_App_ID
				End	
			End	
			End				
		End
END

