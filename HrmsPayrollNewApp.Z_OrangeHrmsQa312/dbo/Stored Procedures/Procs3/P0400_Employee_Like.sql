


CREATE PROCEDURE [dbo].[P0400_Employee_Like]
	@Emp_Id numeric(18,0),
	@Cmp_Id numeric(18,0),
	@For_date datetime,
	@Emp_Like_Id numeric(18,0),
	@Like_date datetime,
	@Like_Flag numeric(18,0)=0,
	@Reminder_type varchar(250) = ''
AS

SET NOCOUNT ON;

BEGIN
	DECLARE @Notification_Flag INT
	SET @Notification_Flag = 0
	
	IF @Reminder_type = 'TODAYS BIRTHDAY'
		SET @Notification_Flag = 1
	ELSE IF @Reminder_type = 'TODAYS WORK ANNIVERSARY'
		SET @Notification_Flag = 2
	ELSE IF @Reminder_type = 'TODAYS MARRIAGE ANNIVERSARY'
		SET @Notification_Flag = 3
	ELSE IF @Reminder_type = 'Upcoming Birthday'
		SET @Notification_Flag = 4
	ELSE IF @Reminder_type = 'Upcoming Work Anniversary'
		SET @Notification_Flag = 5
	ELSE IF @Reminder_type = 'Upcoming Marriage Anniversary'
		SET @Notification_Flag = 6
	
	
	IF EXISTS (SELECT * FROM T0400_Employee_Like WITH (NOLOCK) WHERE Emp_Id = @Emp_Id AND Emp_Like_Id = @Emp_Like_Id AND Notification_Flag = @Notification_Flag)
		BEGIN
			UPDATE T0400_Employee_Like
			SET Like_Flag = @Like_Flag, --CASE WHEN Like_Flag = 1 THEN 0 ELSE 1 END,
			Like_Date = GETDATE()
			WHERE Emp_Id = @Emp_Id AND Emp_Like_Id = @Emp_Like_Id AND Cmp_Id=@Cmp_Id AND Notification_Flag = @Notification_Flag
		END
	ELSE
		BEGIN
			--SET @Like_Flag = 1
			INSERT INTO T0400_Employee_Like (Emp_Id,Cmp_Id,For_date,Emp_Like_Id,Like_date,Like_Flag,Notification_Flag)
			VALUES (@Emp_Id,@Cmp_Id,@For_date,@Emp_Like_Id,@Like_date,@Like_Flag,@Notification_Flag)
		END
		
	DECLARE @ISGrouofCmp int
		
	SELECT @ISGrouofCmp = Setting_Value FROM T0040_SETTING  WITH (NOLOCK) 
	WHERE Setting_Name = 'Show Birthday Reminder Group Company wise' AND Cmp_ID = @Cmp_Id 
    
    
    IF @ISGrouofCmp = 1
		BEGIN
			SELECT COUNT(*) AS 'Like_Count'
			FROM T0400_Employee_Like  WITH (NOLOCK) 
			WHERE Emp_Like_Id = @Emp_Like_Id AND Emp_Id = @Emp_Id  AND Notification_Flag = @Notification_Flag
		END
	ELSE
		BEGIN
			SELECT COUNT(*) AS 'Like_Count'
			FROM T0400_Employee_Like  WITH (NOLOCK) 
			WHERE Emp_Like_Id = @Emp_Like_Id AND Emp_Id = @Emp_Id AND Cmp_Id = @Cmp_Id AND Notification_Flag = @Notification_Flag
		END
		
 --   SELECT COUNT(*) AS 'Like_Count',
	--(
	--	SELECT Like_Flag 
	--	FROM T0400_Employee_Like 
	--	WHERE Emp_Like_Id = @Emp_Like_Id AND Emp_Id = @Emp_Id AND Cmp_Id = @Cmp_Id AND Notification_Flag = @Notification_Flag
	--) AS E_Like
 --   FROM T0400_Employee_Like 
 --   WHERE Emp_Id = @Emp_Id AND Cmp_Id = @Cmp_Id AND Like_Flag = 1 AND Notification_Flag = @Notification_Flag
    
END



