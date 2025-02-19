
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0150_EMP_INOUT_RECORDS_IMPORT]
	@EMP_CODE			varchar(40),
	@CMP_ID				NUMERIC ,
	@FOR_DATE			DATETIME,
	@IN_TIME			DATETIME = NULL,
	@OUT_TIME			DATETIME = NULL,
	@IN_DATETIME		DATETIME = NULL,
	@OUT_DATETIME		DATETIME = NULL,
	@IS_Enroll_NO		int=0,
	@GUID				Varchar(2000) = '' --Added by nilesh patel on 15062016
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	Declare @IO_Tran_Id		Numeric 
	Declare @Emp_ID			Numeric
	Declare @Duration		Varchar(20)
	Declare @Duration_Sec	numeric 
	set @Emp_ID = 0
			
	Select @IO_Tran_Id = isnull(max(IO_Tran_Id),0) + 1  from T0150_EMP_INOUT_RECORD WITH (NOLOCK)
		
	if @IS_Enroll_NO =0			
		Begin			
			select @Emp_ID = isnull(Emp_ID,0) from T0080_Emp_Master WITH (NOLOCK) where  Cmp_ID =@Cmp_ID and Alpha_Emp_Code = @Emp_Code
		End
	Else
		Begin
			select @Emp_ID = isnull(Emp_ID,0) from T0080_Emp_Master WITH (NOLOCK) where  Cmp_ID =@Cmp_ID and Enroll_No = @Emp_Code
		End
		
	if ISNULL(@Emp_ID ,0)=0
		begin
			Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@Emp_ID,'Employee Code not Exists',0,'Enter Proper Employee Code',GetDate(),'IN OUT Import',@GUID)							
			return
		end
		
	if @FOR_DATE IS NULL
		begin
			Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@Emp_ID,'For Date not Exists',0,'Enter Correct For Date',GetDate(),'IN OUT Import',@GUID)							
			return
		end
		
	if @IN_TIME Is NULL
		Begin
			Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@Emp_ID,'In Time not Exists',0,'Enter Correct In Time Details',GetDate(),'IN OUT Import',@GUID)							
			return
		End 
	
	if @OUT_TIME IS NULL
		Begin
			Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@Emp_ID,'Out Time not Exists',0,'Enter Correct Out Time Details',GetDate(),'IN OUT Import',@GUID)							
			return
		End 
	
	If isnull(@IN_TIME,'')='' and ISNULL(@OUT_TIME,'')='' and ISNULL(@OUT_DATETIME,'')='' and ISNULL(@IN_DATETIME,'')=''
		return

	IF ISNULL(@IN_DATETIME,'')='' 
		BEGIN
			if len(@IN_TIME ) < 15  and isnull(@IN_TIME,'') <> '' 
				begin
					set  @IN_DATETIME  =cast ( cast(@FOR_DATE as varchar(11)) + ' ' + cast(cast(datepart(hh,(CAST(@IN_TIME AS SMALLDATETIME))) as varchar(3))  + ':'  + cast(datepart(mi,(CAST(@IN_TIME AS SMALLDATETIME))) as varchar(2))  as datetime) as datetime)
				end
			else if year(@IN_TIME ) <= 1900
				begin
					set @IN_TIME = dbo.F_Return_HHMM(@IN_TIME)
					set  @IN_DATETIME  =cast ( cast(@FOR_DATE as varchar(11)) + ' ' + cast(cast(datepart(hh,(CAST(@IN_TIME AS SMALLDATETIME))) as varchar(3))  + ':'  + cast(datepart(mi,(CAST(@IN_TIME AS SMALLDATETIME))) as varchar(2))  as datetime) as datetime)
				end
			else if isdate(@IN_TIME) = 1
				begin
					set @IN_DATETIME = @IN_TIME
				end
				
		END 
	if isnull(@Out_Datetime,'') ='' 
		begin
			if len(@OUT_TIME ) < 15 and isnull(@OUT_TIME,'') <> '' 
				begin
					set  @OUT_DATETIME  = cast ( cast(@FOR_DATE as varchar(11)) + ' ' + cast(cast(datepart(hh,(CAST(@OUT_TIME AS SMALLDATETIME))) as varchar(3))  + ':'  + cast(datepart(mi,(CAST(@OUT_TIME AS SMALLDATETIME))) as varchar(2))  as datetime) as datetime)
				end
			else if year(@OUT_TIME ) <= 1900
				begin
					set @OUT_TIME = dbo.F_Return_HHMM(@OUT_TIME)
					set  @OUT_DATETIME  = cast ( cast(@FOR_DATE as varchar(11)) + ' ' + cast(cast(datepart(hh,(CAST(@OUT_TIME AS SMALLDATETIME))) as varchar(3))  + ':'  + cast(datepart(mi,(CAST(@OUT_TIME AS SMALLDATETIME))) as varchar(2))  as datetime) as datetime)
				end		
			else if isdate(@OUT_TIME) = 1
				begin
					set @OUT_DATETIME = @OUT_TIME
				end						
		end
	
	
		if isnull(@IN_DATETIME ,'') = '' and isnull(@OUT_DATETIME ,'') = '' 
			begin
				return 
			end
		else if isnull(@IN_DATETIME ,'') <> '' and isnull(@OUT_DATETIME ,'') <> '' 
			begin
				if @IN_DATETIME > @OUT_DATETIME
					set @OUT_DATETIME =dateadd(d,1,@OUT_DATETIME)
			end

		
		
		if @Emp_ID > 0
			begin
				if exists(select Emp_ID from T0150_EMP_INOUT_RECORD WITH (NOLOCK) where Emp_ID = @Emp_ID and In_Time = @IN_DATETIME and isnull(@IN_DATETIME,'') <> '' )
					begin
						return
					end
				else if exists(select Emp_ID from T0150_EMP_INOUT_RECORD WITH (NOLOCK) where Emp_ID = @Emp_ID and Out_Time = @OUT_DATETIME and isnull(@OUT_DATETIME,'') <> '' )
					begin
						return
					end					
			
				
			
				set @Duration_Sec =isnull(datediff(s,@IN_DATETIME,@OUT_DATETIME),0)
				set @Duration = dbo.F_Return_Hours(@Duration_Sec)
				
				Insert Into T0150_EMP_INOUT_RECORD(IO_Tran_Id,Emp_ID,Cmp_ID,For_Date,In_Time,Out_Time,Duration,Reason,Ip_Address,ManualEntryFlag)
				values(@IO_Tran_Id,@Emp_ID,@Cmp_ID,@For_Date,@IN_DATETIME,@OUT_DATETIME,@Duration,'','Import','New') --Added ManualEntry Column for getting Color in Emp In Out form, after import the attendance
			end
			
	
	
	RETURN




