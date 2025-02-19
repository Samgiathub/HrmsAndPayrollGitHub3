CREATE  PROCEDURE [dbo].[P0115_AttendanceRegul_Level_Approval]
	 @Tran_ID		Numeric(18,0)		Output
	,@IO_Tran_Id	numeric(18) 
	,@Emp_ID		numeric(18)    
    ,@Cmp_Id		numeric(18)
	,@Reason   varchar(50) = '' -- -- Added by Niraj (05012022)
    ,@Sup_Comment   varchar(50) --Change by sumit for error data would be truncated because of size 16012016
    ,@Is_Cancel_Late_In tinyint
    ,@Is_Cancel_Early_Out tinyint 
    ,@Half_Full_day_Manager varchar(20) = '' 
    ,@In_Date_Time	Datetime	= NULL
    ,@Out_Date_Time	Datetime	= NULL 
    ,@Chk_By_Superior numeric(18) 
    ,@S_Emp_ID numeric(18) 
    ,@Rpt_Level tinyint
	,@For_Date datetime = NULL
AS
BEGIN
	SET NOCOUNT ON;
	--Declare @For_Date datetime
	Declare @Duration Varchar(10)
	Declare @For_In_Date_Time datetime --Mukti(03042017)
	Declare @For_Out_Date_Time datetime --Mukti(03042017)
	
	--IF @In_Date_Time = ''
	--	Set @In_Date_Time = Null
	--IF 	@Out_Date_Time = ''
	--	Set @Out_Date_Time  = Null

	
	IF Exists(Select 1 From T0115_AttendanceRegu_Level_Approval Where Emp_ID=@Emp_ID and IO_Tran_Id=@IO_Tran_Id And S_Emp_Id = @S_Emp_ID And Rpt_Level = @Rpt_Level)
	Begin
		Set @Tran_ID = 0
		--Select @Tran_ID commented by Niraj (04062222)
		Raiserror('@@Already Approved@@',16,2)
		Return
	End

	Declare @forDate as Date = NULL
	SELECT @forDate = cast(For_Date as Date) FROM  T0150_EMP_INOUT_RECORD where IO_Tran_Id = @IO_Tran_Id and Emp_id = @Emp_ID and Cmp_Id = @Cmp_Id

	If ((SELECT count(1) FROM T0150_EMP_INOUT_RECORD E 
	inner join T0180_LOCKED_ATTENDANCE SPE WITH (NOLOCK) ON E.EMP_ID = SPE.EMP_ID 
	WHERE E.CMP_ID = @CMP_ID and SPE.Emp_Id = @Emp_ID and IO_Tran_Id = @IO_Tran_Id and @forDate between From_Date and To_Date) > 0)
	BEGIN
		Raiserror('@@ Attendance Lock for this Period. @@',16,2)
		return -1								
	END
	--Start Commented by Deepal 12-31-2020	
	--Select @For_Date=For_Date,@For_In_Date_Time=In_Date_Time,@For_Out_Date_Time=Out_Date_Time
	--From dbo.t0150_Emp_Inout_Record Where Emp_ID=@Emp_ID and IO_Tran_Id=@IO_Tran_Id
	--END Commented by Deepal 12-31-2020
IF ((Select count(1)  FROM T0115_AttendanceRegu_Level_Approval lla WITH (NOLOCK) 
		inner join (SELECT max(rpt_level) AS rpt_level1, IO_Tran_Id
					FROM T0115_AttendanceRegu_Level_Approval  WITH (NOLOCK) group by IO_Tran_Id 
		) Qry
	on qry.IO_Tran_Id = lla.IO_Tran_Id and qry.rpt_level1 = lla.rpt_level
	Where Emp_ID=@Emp_ID and lla.IO_Tran_Id=@IO_Tran_Id) > 0)
	BEGIN
				SELECT @For_Date=For_Date,@For_In_Date_Time=In_Time,@For_Out_Date_Time=Out_Time
			FROM T0115_AttendanceRegu_Level_Approval lla WITH (NOLOCK) 
				inner join (SELECT max(rpt_level) AS rpt_level1, IO_Tran_Id
							FROM T0115_AttendanceRegu_Level_Approval  WITH (NOLOCK) group by IO_Tran_Id 
				) Qry
			on qry.IO_Tran_Id = lla.IO_Tran_Id and qry.rpt_level1 = lla.rpt_level
			Where Emp_ID=@Emp_ID and lla.IO_Tran_Id=@IO_Tran_Id

	END
	ELSE
	BEGIN
		Select @For_Date=For_Date,@For_In_Date_Time=In_Date_Time,@For_Out_Date_Time=Out_Date_Time
			From dbo.t0150_Emp_Inout_Record Where Emp_ID=@Emp_ID and IO_Tran_Id=@IO_Tran_Id
	END
	

	--Added by Mukti(03042017)start
	IF @In_Date_Time is NULL
		Set @In_Date_Time = @For_In_Date_Time
	IF 	@Out_Date_Time is NULL
		Set @Out_Date_Time  = @For_Out_Date_Time

	--print @Out_Date_Time
	--Added by Mukti(03042017)end
	--print 'In_Date_Time'
	--print @In_Date_Time
	--print 'Out_Date_Time'
	--print @Out_Date_Time
	if Exists (Select Sal_Tran_ID from T0200_MONTHLY_SALARY where Month_St_Date <=@For_Date and isnull(Cutoff_Date,Month_End_Date) >=@For_Date and emp_id=@Emp_ID and isnull(is_Monthly_Salary,0)=1 And @Chk_By_Superior<>2)
		begin
			Raiserror('@@This Months Salary Exists@@',16,2)
			return -1
		end
	
	Set @Duration = dbo.F_Return_Hours (datediff(s,@In_Date_Time,@Out_Date_Time))
	
	Select @Tran_ID = isnull(max(Tran_ID),0) + 1 from T0115_AttendanceRegu_Level_Approval
	if isnull(@For_Date,'') = ''
		set @For_Date = getdate()

	Insert Into T0115_AttendanceRegu_Level_Approval
			(Tran_Id,Emp_ID,Cmp_ID,IO_Tran_ID,For_Date,In_Time,Out_Time,Duration,Reason -- Added by Niraj (05012022)
			,Chk_By_Superior,Half_Full_day,Is_Cancel_Late_In,Is_Cancel_Early_Out,S_Emp_Id,S_Comment,Rpt_Level,System_Date)
    Values	(@Tran_ID,@Emp_ID,@Cmp_Id,@IO_Tran_Id,@For_Date,@In_Date_Time,@Out_Date_Time,@Duration,@Reason,@Chk_By_Superior,@Half_Full_day_Manager,@Is_Cancel_Late_In,@Is_Cancel_Early_Out,@S_Emp_ID,@Sup_Comment,@Rpt_Level,GETDATE())
    
END
