

 
CREATE PROCEDURE [dbo].[P_Get_Comment_Detail]
	@Emp_Id numeric(18,0),
	@Cmp_Id numeric(18,0),
	@For_Date datetime,
	@Reminder_Type varchar(150) = ''
	--@Reply_Comment_Id numeric(18,0)
	
AS
BEGIN
		
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
		
		
	--if @Reply_Comment_Id = 0
	--	BEGIN
	--			select EC.*,EM.Emp_Full_Name,REM.Emp_Full_Name As Comment_EmployeeName,REM.Image_Name As Profile_Img,
	--			SUBSTRING(REM.Emp_First_Name,1,1) As Profile_Name 
	--			from T0400_Employee_Comment EC inner JOIN
	--					T0080_EMP_MASTER EM ON EC.Emp_Id = EM.Emp_ID inner JOIN
	--					T0080_EMP_MASTER REM ON EC.Emp_Id_Comment = REM.Emp_ID
	--			 where EC.Emp_Id=@Emp_Id and For_date=@For_date and Ec.Cmp_Id =@Cmp_Id
	--	END
	--Else
	--	BEGIN
	--		select EC.*,EM.Emp_Full_Name,REM.Emp_Full_Name As Comment_EmployeeName,REM.Image_Name As Profile_Img,
	--			SUBSTRING(REM.Emp_First_Name,1,1) As Profile_Name 
	--			from T0400_Employee_Comment EC inner JOIN
	--					T0080_EMP_MASTER EM ON EC.Emp_Id = EM.Emp_ID inner JOIN
	--					T0080_EMP_MASTER REM ON EC.Emp_Id_Comment = REM.Emp_ID
	--			 where EC.Emp_Id=@Emp_Id and For_date=@For_date and Ec.Cmp_Id =@Cmp_Id and EC.Reply_Comment_ID=@Reply_Comment_Id
	--	end
	DECLARE @Form_ID	Numeric(18,0),
			@Sort_Order	Varchar(40),
			@Row_ID		BigInt,
			@Row_ID_Temp BigInt;
	SET	@Sort_Order = '';	
	SET @Form_ID = 0;		
		
	select ROW_NUMBER() OVER(ORDER BY EC.Comment_Id,Reply_Comment_Id) AS ROW_ID,EC.Comment_Id,EC.Reply_Comment_Id,EC.U_Comment_Id
	INTO	#TMP
	from T0400_Employee_Comment EC WITH (NOLOCK)
	where EC.Emp_Id=@Emp_Id and Ec.Cmp_Id =@Cmp_Id and Notification_Flag = @Notification_Flag --and For_date=@For_date
		
	;WITH R(ROW_ID,Comment_Id,Reply_Comment_Id,U_Comment_Id,Chk_ID) AS
	(
		SELECT	ROW_ID, Comment_Id, Reply_Comment_Id,U_Comment_Id,CAST((RIGHT('00000' + CAST(ROW_ID AS VARCHAR),5)) AS VARCHAR(1024)) AS Chk_ID
		FROM	#TMP T1
		WHERE	U_Comment_Id < 0
		UNION ALL
		SELECT	T2.ROW_ID, T2.Comment_Id,T2.Reply_Comment_Id,T2.U_Comment_Id,CAST((R.Chk_ID + ' ' + RIGHT('00000' + CAST(T2.ROW_ID AS VARCHAR),5)) AS VARCHAR(1024)) As Chk_ID
		FROM	#TMP T2 INNER JOIN R ON T2.Reply_Comment_Id=R.Comment_Id
		
	)
	SELECT R.ROW_ID,R.Comment_Id,R.Reply_Comment_Id,R.U_Comment_Id,R.Chk_ID,
		   EC.Emp_Id,EC.Emp_Id_Comment,EC.For_date,EC.Comment_date,EC.Comment,EC.Comment_Status,EC.Notification_Flag,
		   EM.Emp_Full_Name,REM.Emp_Full_Name As Comment_EmployeeName,
		   REM.Image_Name As Profile_Img,
		   SUBSTRING(REM.Emp_First_Name,1,1) As Profile_Name 
	from T0400_Employee_Comment EC WITH (NOLOCK) inner JOIN
	 	 T0080_EMP_MASTER EM WITH (NOLOCK) ON EC.Emp_Id = EM.Emp_ID inner JOIN
		 T0080_EMP_MASTER REM WITH (NOLOCK) ON EC.Emp_Id_Comment = REM.Emp_ID inner JOIN
		 R on R.Comment_Id = EC.Comment_Id
		 
	where EC.Emp_Id=@Emp_Id  and Ec.Cmp_Id =@Cmp_Id and Notification_Flag = @Notification_Flag --and For_date=@For_date
	ORDER BY R.Chk_ID
	
	
END



