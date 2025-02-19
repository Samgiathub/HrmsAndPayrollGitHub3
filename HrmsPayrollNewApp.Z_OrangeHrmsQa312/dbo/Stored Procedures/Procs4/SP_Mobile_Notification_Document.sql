

CREATE PROCEDURE [dbo].[SP_Mobile_Notification_Document]
	@Cmp_ID numeric(18,0),
	@Dept_ID numeric(18,0),
	@Type varchar(2),
	@Emp_ID numeric(18,0)= 0,
	 
	@Notification_ID numeric(18,0) = 0,
	@NEmp_ID numeric(18,0) = 0,
	@For_date datetime = null,
	@U_Comment_Id numeric(18,0) = 0,
	@Notification_date datetime = null,
	@Flag int = 0,
	@NotificationFlag int = 0,
	@Comment varchar(max) = '',
	@Comment_Status varchar(50) = '',
	@Reply_Comment_Id numeric(18,0) = 0
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

DECLARE @Reminder_type varchar(50)

IF @Type = 'B' --- For BirthDay & Anniversary Notification
	BEGIN
		--; with Setting_List as (SELECT ROW_NUMBER() OVER(PARTITION BY Groupby ORDER BY Groupby,MONTH(Date),DAY(Date)) As RowID, * FROM View_BirthdayAlert  ) 
		--select case when rowID = 1 then Groupby else ''end as Groupby, * from Setting_List 
		
		--; with Setting_List as (SELECT ROW_NUMBER() OVER(PARTITION BY Groupby ORDER BY Groupby,MONTH(Date),DAY(Date)) As RowID, * FROM View_BirthdayAlert  ) 
		--select case when rowID = 1 then Groupby else ''end as Groupby, EM.* ,ISNULL(EL.Like_Flag,0) AS 'Like_Flag'
		--from Setting_List  EM 
		--LEFT JOIN T0400_Employee_Like EL ON EM.Emp_Id = EL.Emp_ID AND MONTH(EM.Date) = MONTH(EL.For_date) AND DAY(EM.Date) = DAY(EL.For_date) AND EL.Emp_Like_Id = @Emp_ID AND EM.NotificationFlag = EL.Notification_Flag
		
		CREATE TABLE #tblBirthday
		(
			Sorting_No int,
			Cmp_ID int,
			Emp_FullName varchar(MAX),
			Month_Name varchar(50),
			Branch_Name varchar(50),
			Image_Name varchar(MAX),
			Alpha_Emp_code varchar(50),
			Dept_Name varchar(50),
			Desig_Name varchar(50),
			Emp_ID int,
			DOJ varchar(50),
			Total_Year int,
			Gender varchar(50)
		)
		INSERT INTO #tblBirthday
		EXEC Get_Birthday_Anniversary_reminder @Cmp_ID = @Cmp_ID,@pPrivilage_ID = '',@pPrivilage_Department = '',@pPrivilage_Vertical = '',@pPrivilage_Sub_Vertical = ''
		
		--select * from #tblBirthday WHERE Emp_FullName NOT LIKE '&nbsp%'
		--select * from View_BirthdayAlert
		
		;with Setting_List as (SELECT ROW_NUMBER() OVER(PARTITION BY Groupby ORDER BY Groupby,Date) As RowID, * FROM View_BirthdayAlert  ) 
		
		SELECT DISTINCT TB.Emp_ID,VM.EmpName,TB.Dept_Name,TB.Desig_Name,TB.Branch_Name,VM.Branch_Code As 'Branch_Code',
		(CASE WHEN ROWID = 1 THEN VM.GROUPBY ELSE ''END) AS Groupby,--(CASE WHEN TB.Month_Name = '' THEN CONVERT(varchar,GETDATE(),103) ELSE TB.DOJ END) AS 'BDate',
		CONVERT(varchar(11),VM.Date,103) AS 'Date',TB.Gender,
		(CASE WHEN ISNULL(VM.Image_Name,'') = '' OR VM.Image_Name = '0.jpg' THEN (CASE WHEN TB.Gender = 'M' THEN 'Emp_Default.png' ELSE 'Emp_Default_Female.png' END) ELSE VM.Image_Name END) AS 'Image_Name',
		'' AS 'DocPath' ,ISNULL(EL.Like_Flag,0) AS 'Like_Flag',VM.LikeCount,VM.CommentCount,VM.Cmp_ID,VM.NotificationFlag
		FROM #tblBirthday TB
		INNER JOIN Setting_List VM ON TB.Emp_ID = VM.Emp_ID
		LEFT JOIN T0400_Employee_Like EL WITH (NOLOCK) ON VM.Emp_Id = EL.Emp_ID AND MONTH(VM.Date) = MONTH(EL.For_date) AND DAY(VM.Date) = DAY(EL.For_date) AND EL.Emp_Like_Id = @Emp_ID AND VM.NotificationFlag = EL.Notification_Flag
		WHERE Emp_FullName NOT LIKE '&nbsp%'
		
		ORDER BY Date
		--ORDER BY VM.Groupby,Date

	END
ELSE IF @Type = 'C' --- For Circular
	BEGIN
		SELECT News_Letter_ID,News_Title,News_Description FROM T0040_NEWS_LETTER_MASTER WITH (NOLOCK)
		WHERE Cmp_ID= @Cmp_ID AND CONVERT(VARCHAR(10),Start_Date,120) <= CONVERT(VARCHAR(10),Getdate(),120) AND CONVERT(VARCHAR(10),End_Date,120) >= CONVERT(VARCHAR(10),Getdate(),120) And Is_Visible=1 
		Order by News_Letter_ID 
	END
ELSE IF @Type = 'P' --- For Policy Document
	BEGIN
		--SELECT Policy_Doc_ID,Policy_Upload_Doc,Policy_Tooltip,Policy_Title,CONVERT(varchar(11), Policy_From_Date,103) AS 'Policy_From_Date',Emp_ID,ISNULL(Dept_Id,0) AS Dept_Id,
		--CONVERT(varchar(11), Policy_To_Date,103) AS 'Policy_To_Date'
		--FROM T0040_POLICY_DOC_MASTER 
		--WHERE (Cmp_ID= @Cmp_ID AND Policy_To_Date + 1 >= GETDATE() AND Policy_From_Date  <= GETDATE()) AND 
		--((@Cmp_ID IN(SELECT data FROM dbo.Split(Emp_id,'#'))) OR Emp_ID LIKE '0' ) AND ((@Dept_ID IN (
		--SELECT data FROM dbo.Split(Dept_Id,'#')) OR Dept_Id LIKE '0') )
		--AND Policy_Tooltip NOT LIKE '%Training%'
		
		--code Commented and new Code added By Ashwin 03/06/2017
		
		SELECT TPM.Policy_Doc_ID,TPM.Policy_Upload_Doc,TPM.Policy_Tooltip,TPM.Policy_Title,CONVERT(varchar(11), TPM.Policy_From_Date,103) AS 'Policy_From_Date',TPM.Emp_ID,ISNULL(TPM.Dept_Id,0) AS Dept_Id,
		ISNULL(TRD.Is_Mobile_Read,0) AS 'Is_Mobile_Read',
		CONVERT(varchar(11), TPM.Policy_To_Date,103) AS 'Policy_To_Date'
		FROM T0040_POLICY_DOC_MASTER TPM WITH (NOLOCK)
		LEFT JOIN T0090_EMP_POLICY_DOC_READ_DETAIL TRD WITH (NOLOCK) ON TPM.Policy_Doc_ID = TRD.Policy_Doc_ID AND ISNULL(TRD.Doc_Type,0) = 1 AND ISNULL(TRD.Is_Mobile_Read,0) = 1 AND TRD.Emp_ID = @Emp_ID
		
		WHERE (TPM.Cmp_ID= @Cmp_ID AND TPM.Policy_To_Date + 1 >= GETDATE() AND TPM.Policy_From_Date  <= GETDATE()) AND 
		((@Emp_ID IN(SELECT data FROM dbo.Split(TPM.Emp_id,'#'))) OR TPM.Emp_ID LIKE '0' ) AND ((@Dept_ID IN (
		SELECT data FROM dbo.Split(Dept_Id,'#')) OR Dept_Id LIKE '0') )
		AND TPM.Policy_Tooltip NOT LIKE '%Training%'
	END
ELSE IF @Type = 'G'  --- For Gallery
	BEGIN
		SELECT S.data FROM T0010_Emp_Gallery EG WITH (NOLOCK) outer apply dbo.split(EG.Name, '#') S 
		WHERE Type ='Images';
		SELECT S.data FROM T0010_Emp_Gallery EG WITH (NOLOCK) outer apply dbo.split(EG.Name, '#') S 
		WHERE Type ='Video'
	END
ELSE IF @Type = 'T' --- For Training Document
	BEGIN
		--SELECT Policy_Doc_ID,Policy_Upload_Doc,Policy_Tooltip,Policy_Title,CONVERT(varchar(11), Policy_From_Date,103) AS 'Policy_From_Date',Emp_ID,ISNULL(Dept_Id,0) AS Dept_Id,
		--CONVERT(varchar(11), Policy_To_Date,103) AS 'Policy_To_Date'
		--FROM T0040_POLICY_DOC_MASTER 
		--WHERE (Cmp_ID= @Cmp_ID AND Policy_To_Date + 1 >= GETDATE() AND Policy_From_Date  <= GETDATE()) AND 
		--((@Cmp_ID IN(SELECT data FROM dbo.Split(Emp_id,'#'))) OR Emp_ID LIKE '0' ) AND ((@Dept_ID IN (
		--SELECT data FROM dbo.Split(Dept_Id,'#')) OR Dept_Id LIKE '0') )
		--AND Policy_Tooltip LIKE '%Training%'
		
		--code Commented and new Code added By Ashwin 03/06/2017
		
		SELECT TPM.Policy_Doc_ID,TPM.Policy_Upload_Doc,TPM.Policy_Tooltip,TPM.Policy_Title,CONVERT(varchar(11), TPM.Policy_From_Date,103) AS 'Policy_From_Date',TPM.Emp_ID,ISNULL(TPM.Dept_Id,0) AS Dept_Id,
		ISNULL(TRD.Is_Mobile_Read,0) AS 'Is_Mobile_Read',
		CONVERT(varchar(11), TPM.Policy_To_Date,103) AS 'Policy_To_Date'
		FROM T0040_POLICY_DOC_MASTER TPM WITH (NOLOCK)
		LEFT JOIN T0090_EMP_POLICY_DOC_READ_DETAIL TRD WITH (NOLOCK) ON TPM.Policy_Doc_ID = TRD.Policy_Doc_ID AND ISNULL(TRD.Doc_Type,0) = 2 AND ISNULL(TRD.Is_Mobile_Read,0) = 1 AND TRD.Emp_ID = @Emp_ID
		
		WHERE (TPM.Cmp_ID= @Cmp_ID AND TPM.Policy_To_Date + 1 >= GETDATE() AND TPM.Policy_From_Date  <= GETDATE()) AND 
		((@Emp_ID IN(SELECT data FROM dbo.Split(TPM.Emp_id,'#'))) OR TPM.Emp_ID LIKE '0' ) AND ((@Dept_ID IN (
		SELECT data FROM dbo.Split(Dept_Id,'#')) OR Dept_Id LIKE '0') )
		AND TPM.Policy_Tooltip LIKE '%Training%'
	END
ELSE IF @Type = 'N' -- For Get Comment Details
	BEGIN
		--SELECT Comment_Id,EC.Emp_Id,EC.Cmp_Id,Emp_Id_Comment,CONVERT(varchar(11),For_date,103) AS 'For_date',
		--U_Comment_Id,CONVERT(varchar(11),Comment_date,103) AS 'Comment_date',Comment,Comment_Status,Reply_Comment_Id,
		--Notification_Flag,EM.Emp_Full_Name,
		--(CASE WHEN Image_Name = '0.jpg' OR Image_Name = '' OR Image_Name IS NULL THEN (CASE WHEN Gender = 'M' THEN 'Emp_Default.png' ELSE 'Emp_Default_Female.png' END) ELSE Image_Name END) AS 'Image_Name'
		--FROM T0400_Employee_Comment EC
		--INNER JOIN T0080_EMP_MASTER EM ON EC.Emp_Id_Comment = EM.Emp_ID
		--WHERE EC.Emp_Id = @Emp_ID AND Notification_Flag = @NotificationFlag
		
		
		IF @NotificationFlag = 1
			BEGIN
				SET @Reminder_type = 'TODAYS BIRTHDAY'
			END
		ELSE IF @NotificationFlag = 2
			BEGIN
				SET @Reminder_type = 'TODAYS WORK ANNIVERSARY'
			END
		ELSE IF @NotificationFlag = 3
			BEGIN
				SET @Reminder_type = 'TODAYS MARRIAGE ANNIVERSARY'
			END
			
		EXEC P_Get_Comment_Detail @Emp_Id = @Emp_ID,@Cmp_Id = @Cmp_ID,@For_Date = @For_date,@Reminder_Type = @Reminder_type
	END
ELSE IF @Type = 'CI' -- For Insert Comment
	BEGIN
		 
		
		IF @NotificationFlag = 1
			BEGIN
				SET @Reminder_type = 'TODAYS BIRTHDAY'
			END
		ELSE IF @NotificationFlag = 2
			BEGIN
				SET @Reminder_type = 'TODAYS WORK ANNIVERSARY'
			END
		ELSE IF @NotificationFlag = 3
			BEGIN
				SET @Reminder_type = 'TODAYS MARRIAGE ANNIVERSARY'
			END
		EXEC P0400_Employee_Comment @Comment_Id = @Notification_ID,@Emp_Id = @Emp_ID,@Cmp_Id = @Cmp_ID,@Emp_Id_Comment = @NEmp_ID,@For_date = @For_date,@U_Comment_Id = @U_Comment_Id,@Comment_date = @Notification_date,@Comment = @Comment,@Comment_Status = @Comment_Status,@Reply_Comment_Id = @Reply_Comment_Id,@Tran_type = 'I',@Reminder_type = @Reminder_type
		
		EXEC P_Get_Comment_Detail @Emp_Id = @Emp_ID,@Cmp_Id = @Cmp_ID,@For_Date = @For_date,@Reminder_Type = @Reminder_type
	
	END
ELSE IF @Type = 'CD' -- For Insert Comment
	BEGIN
		 
		
		IF @NotificationFlag = 1
			BEGIN
				SET @Reminder_type = 'TODAYS BIRTHDAY'
			END
		ELSE IF @NotificationFlag = 2
			BEGIN
				SET @Reminder_type = 'TODAYS WORK ANNIVERSARY'
			END
		ELSE IF @NotificationFlag = 3
			BEGIN
				SET @Reminder_type = 'TODAYS MARRIAGE ANNIVERSARY'
			END
		EXEC P0400_Employee_Comment @Comment_Id = @Notification_ID,@Emp_Id = @Emp_ID,@Cmp_Id = @Cmp_ID,@Emp_Id_Comment = @NEmp_ID,@For_date = @For_date,@U_Comment_Id = @U_Comment_Id,@Comment_date = @Notification_date,@Comment = @Comment,@Comment_Status = @Comment_Status,@Reply_Comment_Id = @Reply_Comment_Id,@Tran_type = 'D',@Reminder_type = @Reminder_type
		
		EXEC P_Get_Comment_Detail @Emp_Id = @Emp_ID,@Cmp_Id = @Cmp_ID,@For_Date = @For_date,@Reminder_Type = @Reminder_type
	
	END
ELSE IF @Type = 'LI' -- For Insert Like
	BEGIN
		IF @NotificationFlag = 1
			BEGIN
				SET @Reminder_type = 'TODAYS BIRTHDAY'
			END
		ELSE IF @NotificationFlag = 2
			BEGIN
				SET @Reminder_type = 'TODAYS WORK ANNIVERSARY'
			END
		ELSE IF @NotificationFlag = 3
			BEGIN
				SET @Reminder_type = 'TODAYS MARRIAGE ANNIVERSARY'
			END
		EXEC P0400_Employee_Like @Emp_Id = @Emp_ID,@Cmp_Id = @Cmp_ID,@For_date = @For_date,@Emp_Like_Id = @NEmp_ID,
		@Like_date = @Notification_date,@Like_Flag = @Flag,@Reminder_type = @Reminder_type
		--SELECT * FROM T0400_Employee_Like
	END

