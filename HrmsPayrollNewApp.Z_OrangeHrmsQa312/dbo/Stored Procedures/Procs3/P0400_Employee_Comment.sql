

 ---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0400_Employee_Comment]
	@Comment_Id numeric(18,0),
	@Emp_Id numeric(18,0),
	@Cmp_Id numeric(18,0),
	@Emp_Id_Comment numeric(18,0),
	@For_date datetime,
	@U_Comment_Id numeric(18,0),
	@Comment_date datetime,
	@Comment nvarchar(500),
	@Comment_Status varchar(50),
	@Reply_Comment_Id numeric(18,0) = 0,
	@Tran_type varchar(5) = '',
	@Reminder_type varchar(150) = ''
	
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
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
		
	if @Tran_type = 'I'
	begin
		SELECT @Comment_Id = isnull(max(Comment_Id),0)+1 from T0400_Employee_Comment WITH (NOLOCK)
		
		IF exists(select * from T0400_Employee_Comment WITH (NOLOCK) where Emp_Id=@Emp_Id and For_date = @For_date )
		BEGIN
		
			select @U_Comment_Id= Comment_Id  from T0400_Employee_Comment WITH (NOLOCK) where Emp_Id=@Emp_Id and For_date = @For_date --and Emp_Id_Comment=@Emp_Id_Comment
		END
		else
		begin
			
			set @U_Comment_Id = -1
			--select @U_Comment_Id = isnull(max(U_Comment_Id),0)+1  from T0400_Employee_Comment 
		end
		
		if @Reply_Comment_Id = 0
			set @U_Comment_Id = -1
			
		Insert INTO T0400_Employee_Comment (Comment_Id,Emp_Id,Cmp_Id,Emp_Id_Comment,For_date,U_Comment_Id,Comment_date,Comment,Comment_Status,Reply_Comment_Id,Notification_Flag)
		VALUES(@Comment_Id,@Emp_Id,@Cmp_Id,@Emp_Id_Comment,@For_date,@U_Comment_Id,@Comment_date,@Comment,@Comment_Status,@Reply_Comment_Id,@Notification_Flag)
	    
		--select * from T0400_Employee_Comment where Emp_Id=@Emp_Id and For_date = @For_date
    END
    
    if @Tran_type = 'D'
    BEGIN
		--select @Comment_Id,@Emp_Id,@For_date
		--delete FROM T0400_Employee_Comment where Comment_Id=@Comment_Id and Emp_Id=@Emp_Id --and For_date = @For_date
		select ROW_NUMBER() OVER(ORDER BY EC.Comment_Id,Reply_Comment_Id) AS ROW_ID,EC.Comment_Id,EC.Reply_Comment_Id,EC.U_Comment_Id
		INTO	#TMP
		from T0400_Employee_Comment EC WITH (NOLOCK)
		where EC.Emp_Id=@Emp_Id and For_date=@For_date and Ec.Cmp_Id =@Cmp_Id and Notification_Flag = @Notification_Flag
			
		;WITH R(ROW_ID,Comment_Id,Reply_Comment_Id,U_Comment_Id,Chk_ID) AS
		(
			SELECT	ROW_ID, Comment_Id, Reply_Comment_Id,U_Comment_Id,CAST((RIGHT('00000' + CAST(ROW_ID AS VARCHAR),5)) AS VARCHAR(1024)) AS Chk_ID
			FROM	#TMP T1
			WHERE	U_Comment_Id < 0 --and T1.Comment_Id = @Comment_Id 
			UNION ALL
			SELECT	T2.ROW_ID, T2.Comment_Id,T2.Reply_Comment_Id,T2.U_Comment_Id,CAST((R.Chk_ID + ' ' + RIGHT('00000' + CAST(T2.ROW_ID AS VARCHAR),5)) AS VARCHAR(1024)) As Chk_ID
			FROM	#TMP T2 INNER JOIN R ON T2.Reply_Comment_Id=R.Comment_Id
			
		)
		--SELECT * from T0400_Employee_Comment EC inner JOIN
		Delete EC from T0400_Employee_Comment EC inner JOIN
	 			   R on R.Comment_Id = EC.Comment_Id	 
		where EC.Emp_Id=@Emp_Id and For_date=@For_date and Ec.Cmp_Id =@Cmp_Id 
		and (Ec.Comment_Id = @Comment_Id  OR EC.Reply_Comment_Id =@Comment_Id)
		and Notification_Flag = @Notification_Flag
		
		
    END
	
	exec P_Get_Comment_Detail @Emp_Id=@Emp_Id,@Cmp_Id=@Cmp_Id,@For_Date=@For_Date,@Reminder_Type=@Reminder_Type
END



