

 
CREATE PROCEDURE [dbo].[P_Get_Employee_Like]
	@Emp_Id numeric(18,0),
	@Cmp_Id numeric(18,0),
	@For_Date datetime,
	@Reminder_Type varchar(150) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @Notification_Flag numeric(18,0)
	set @Notification_Flag = 0;
	
	
	IF @Reminder_type = 'TODAYS BIRTHDAY'
		set @Notification_Flag = 1
	else if @Reminder_type = 'TODAYS WORK ANNIVERSARY'
		set @Notification_Flag = 2
	else if @Reminder_type = 'TODAYS MARRIAGE ANNIVERSARY'
		set @Notification_Flag = 3
	ELSE IF @Reminder_type = 'Upcoming Birthday'
		SET @Notification_Flag = 4
	ELSE IF @Reminder_type = 'Upcoming Work Anniversary'
		SET @Notification_Flag = 5
	ELSE IF @Reminder_type = 'Upcoming Marriage Anniversary'
		SET @Notification_Flag = 6
		
  	select EL.*,EM.Emp_Full_Name,REM.Emp_Full_Name As Like_EmployeeName,REM.Image_Name As Profile_Img,
				SUBSTRING(REM.Emp_First_Name,1,1) As Profile_Name 
				from T0400_Employee_Like EL WITH (NOLOCK) inner JOIN
						T0080_EMP_MASTER EM WITH (NOLOCK)  ON EL.Emp_Id = EM.Emp_ID inner JOIN
						T0080_EMP_MASTER REM WITH (NOLOCK)  ON EL.Emp_Like_Id = REM.Emp_ID
				 where EL.Emp_Id=@Emp_Id and EL.Cmp_Id =@Cmp_Id and EL.Like_Flag=1
					and EL.Notification_Flag = @Notification_Flag --and For_date=@For_date 
END



