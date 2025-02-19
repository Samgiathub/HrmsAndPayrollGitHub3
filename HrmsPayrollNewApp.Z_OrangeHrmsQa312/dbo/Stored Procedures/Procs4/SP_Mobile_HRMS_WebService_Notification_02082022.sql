CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_Notification_02082022]
	@Emp_ID numeric(18,0),
	@Cmp_ID numeric(18,0),
	@Dept_ID numeric(18,0),
	@GalleryType int,
	@Type char(2),
	@Year int = 1900 ,--- Add By Jignesh Patel 03-Oct-2018 
	
	@Notification_ID numeric(18,0) = 0,
	@NEmp_ID numeric(18,0) = 0,
	@For_date datetime = null,
	@U_Comment_Id numeric(18,0) = 0,
	@Notification_date datetime = null,
	@Flag int = 0,
	@Comment varchar(max) = '',
	@Comment_Status varchar(50) = '',
	@Reply_Comment_Id numeric(18,0) = 0,
	@Reminder_Type varchar(50)

AS

IF @Type = 'C' --- For Circular
	BEGIN
		SELECT News_Letter_ID,News_Title,News_Description FROM T0040_NEWS_LETTER_MASTER
		WHERE Cmp_ID= @Cmp_ID AND CONVERT(VARCHAR(10),Start_Date,120) <= CONVERT(VARCHAR(10),Getdate(),120) AND CONVERT(VARCHAR(10),End_Date,120) >= CONVERT(VARCHAR(10),Getdate(),120) And Is_Visible=1 
		Order by News_Letter_ID 
	END

ELSE IF @Type = 'B' --- For BirthDay & Anniversary Notification
	BEGIN
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
		

		SELECT DISTINCT TB.Emp_ID,TB.Cmp_ID,VM.EmpName,TB.Dept_Name,TB.Desig_Name,TB.Branch_Name,VM.Branch_Code As 'Branch_Code',
		VM.Groupby,--(CASE WHEN TB.Month_Name = '' THEN CONVERT(varchar,GETDATE(),103) ELSE TB.DOJ END) AS 'BDate',
		CONVERT(varchar(11),VM.Date,103) AS 'Date',TB.Gender,
		(CASE WHEN ISNULL(VM.Image_Name,'') = '' OR VM.Image_Name = '0.jpg' THEN (CASE WHEN TB.Gender = 'M' 
		THEN 'Emp_Default.png' ELSE 'Emp_Default_Female.png' END) ELSE VM.Image_Name END) AS 'Image_Name',
		'' AS 'DocPath',VM.CommentCount,VM.LikeCount,ISNULL(EL.Like_Flag,0) AS 'Like_Flag',Total_Year
		FROM #tblBirthday TB
		INNER JOIN View_BirthdayAlert VM ON TB.Emp_ID = VM.Emp_ID
		LEFT JOIN T0400_Employee_Like EL ON VM.Emp_Id = EL.Emp_ID AND MONTH(VM.Date) = MONTH(EL.For_date) AND DAY(VM.Date) = DAY(EL.For_date) AND EL.Emp_Like_Id = @Emp_ID AND VM.NotificationFlag = EL.Notification_Flag
		WHERE Emp_FullName NOT LIKE '&nbsp%' and [Date] <> '01/01/1900' -- Added by Niraj(05012022)
		
		ORDER BY VM.Groupby,Date
	END
ELSE IF @Type = 'E' -- For Today's Events
	BEGIN
		SELECT * FROM View_BirthdayAlert 
		WHERE Groupby LIKE 'Todays%' AND Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID
		ORDER BY Groupby
	END
ELSE IF @Type = 'D' --- For Document
	BEGIN
		SELECT * FROM
		(
			----- Circular --- 
			--SELECT News_Letter_ID AS 'Doc_ID',News_Title AS 'Doc_Title',News_Description AS 'Description',News_Description AS 'Doc_Name','' AS 'Doc_Tooltip',
			--'' AS 'Doc_FromDate','' AS 'Doc_ToDate', 0 AS 'Emp_ID',0 AS 'Dept_Id',0  AS 'Is_Mobile_Read','Circular' AS 'DocType','' AS 'DocPath'
			--FROM T0040_NEWS_LETTER_MASTER
			--WHERE Cmp_ID= @Cmp_ID AND CONVERT(VARCHAR(10),Start_Date,120) <= CONVERT(VARCHAR(10),GETDATE(),120) AND CONVERT(VARCHAR(10),End_Date,120) >= CONVERT(VARCHAR(10),GETDATE(),120) AND Is_Visible=1 
			----ORDER BY News_Letter_ID 
			
			--UNION ALL
			--- Policy Document --- 
			SELECT TPM.Policy_Doc_ID AS 'Doc_ID',TPM.Policy_Title AS 'Doc_Title',TPM.Policy_Upload_Doc AS 'Description',TPM.Policy_Upload_Doc AS 'Doc_Name',
			TPM.Policy_Tooltip AS 'Doc_Tooltip',CONVERT(VARCHAR(11), TPM.Policy_From_Date,103) AS 'Doc_FromDate',
			CONVERT(VARCHAR(11), TPM.Policy_To_Date,103) AS 'Doc_ToDate',
			TPM.Emp_ID,ISNULL(TPM.Dept_Id,0) AS 'Dept_Id',ISNULL(TRD.Is_Mobile_Read,0) AS 'Is_Mobile_Read',
			'Policy Document' AS 'DocType','' AS 'DocPath'
			
			FROM T0040_POLICY_DOC_MASTER TPM
			LEFT JOIN T0090_EMP_POLICY_DOC_READ_DETAIL TRD ON TPM.Policy_Doc_ID = TRD.Policy_Doc_ID AND ISNULL(TRD.Doc_Type,0) = 1 AND ISNULL(TRD.Is_Mobile_Read,0) = 1 AND TRD.Emp_ID = @Emp_ID
			WHERE (TPM.Cmp_ID= @Cmp_ID AND TPM.Policy_To_Date + 1 >= GETDATE() AND TPM.Policy_From_Date  <= GETDATE()) 
			AND ((CAST(@Emp_ID AS varchar) IN(SELECT data FROM dbo.Split(TPM.Emp_id,'#'))) OR TPM.Emp_ID LIKE '0' ) 
			AND ((CAST(@Dept_ID AS VARCHAR) IN (SELECT data FROM dbo.Split(Dept_Id,'#')) OR Dept_Id LIKE '0') )
			AND TPM.Policy_Tooltip NOT LIKE '%Training%'
						
			UNION ALL
			--- Training Document --- 
			SELECT TPM.Policy_Doc_ID AS 'Doc_ID',TPM.Policy_Title AS 'Doc_Title',TPM.Policy_Upload_Doc AS 'Description',TPM.Policy_Upload_Doc AS 'Doc_Name',
			TPM.Policy_Tooltip AS 'Doc_Tooltip',CONVERT(VARCHAR(11), TPM.Policy_From_Date,103) AS 'Doc_FromDate',
			CONVERT(VARCHAR(11), TPM.Policy_To_Date,103) AS 'Doc_ToDate',
			TPM.Emp_ID,ISNULL(TPM.Dept_Id,0) AS 'Dept_Id',ISNULL(TRD.Is_Mobile_Read,0) AS 'Is_Mobile_Read',
			'Training Document' AS 'DocType','' AS 'DocPath'
			
			FROM T0040_POLICY_DOC_MASTER TPM
			LEFT JOIN T0090_EMP_POLICY_DOC_READ_DETAIL TRD ON TPM.Policy_Doc_ID = TRD.Policy_Doc_ID AND ISNULL(TRD.Doc_Type,0) = 2 AND ISNULL(TRD.Is_Mobile_Read,0) = 1 AND TRD.Emp_ID = @Emp_ID
			WHERE (TPM.Cmp_ID= @Cmp_ID AND TPM.Policy_To_Date + 1 >= GETDATE() AND TPM.Policy_From_Date  <= GETDATE()) 
			AND ((CAST(@Emp_ID AS varchar) IN(SELECT data FROM dbo.Split(TPM.Emp_id,'#'))) OR TPM.Emp_ID LIKE '0' ) 
			AND ((CAST(@Dept_ID AS varchar) IN (SELECT data FROM dbo.Split(Dept_Id,'#')) OR Dept_Id LIKE '0') )
			AND TPM.Policy_Tooltip LIKE '%Training%'
			
			UNION ALL
			
			--- My Document --- 
			--SELECT ED.Doc_ID,DM.Doc_Name  AS 'Doc_Title',ED.Doc_Comments AS 'Description',ED.Doc_Path  AS 'Doc_Name',
			--(SUBSTRING(ED.Doc_Path,30,LEN(ED.Doc_Path))) AS 'Doc_Tooltip',''AS 'Doc_FromDate','' AS 'Doc_ToDate',ED.Emp_ID,
			--0 AS 'Dept_Id',0 AS 'Is_Mobile_Read','My Document' AS 'DocType','' AS 'DocPath'
			--FROM T0090_EMP_DOC_DETAIL ED
			--LEFT JOIN T0040_DOCUMENT_MASTER DM ON ED.Doc_ID = DM.Doc_ID
			--WHERE ED.Emp_ID = @Emp_ID
			
			SELECT ED.Doc_ID,DM.Doc_Name  AS 'Doc_Title',ED.Doc_Comments AS 'Description',ED.Doc_Path  AS 'Doc_Name',
			(SUBSTRING(ED.Doc_Path,30,LEN(ED.Doc_Path))) AS 'Doc_Tooltip',''AS 'Doc_FromDate','' AS 'Doc_ToDate',ED.Emp_ID,
			0 AS 'Dept_Id',0 AS 'Is_Mobile_Read','My Document' AS 'DocType','' AS 'DocPath'
			FROM T0040_DOCUMENT_MASTER DM 
			CROSS JOIN T0080_EMP_MASTER EM 
			LEFT JOIN T0090_EMP_DOC_DETAIL ED ON DM.Doc_ID = ED.Doc_ID AND EM.EMP_ID = ED.EMP_ID
			WHERE EM.Emp_ID = @Emp_ID AND DM.Cmp_ID = @Cmp_ID AND ED.Doc_ID IS NOT NULL
			
		) AS Q ORDER BY Q.DocType
		
	END
ELSE IF @Type = 'G' --- For Gallery
	BEGIN
		IF @GalleryType = 1 -- For Images
			BEGIN
				SELECT --S.data,
				Gallery_ID,Gallery_Name,EG.purpose,'Images' AS 'GalleryType'
				,'Images/' AS 'DocPath'
				,Name as [data]
				FROM T0010_Emp_Gallery EG 
				--OUTER APPLY dbo.split(EG.Name, '#') S 
				WHERE Type ='Images' AND EG.expiry_Date >= CONVERT(VARCHAR(12),GETDATE(),101) AND Cmp_ID = @Cmp_ID 
				AND(@Emp_ID IN 
				(
					SELECT CAST(data AS NUMERIC) FROM dbo.split(emp_id_multi, '#')) OR ISNULL(emp_id_multi,'')=''
				)
			END
		ELSE IF @GalleryType = 2 -- For Video
			BEGIN
				SELECT --S.data,
				Gallery_ID,Gallery_Name,EG.purpose,'Video' AS 'GalleryType'
				,'Video/' AS 'DocPath',Name as [data]
				FROM T0010_Emp_Gallery EG 
				--OUTER APPLY dbo.split(EG.Name, '#') S 
				WHERE Type ='Video' AND EG.expiry_Date >= CONVERT(VARCHAR(12),GETDATE(),101) AND Cmp_ID = @Cmp_ID 
				AND(@Emp_ID IN 
				(
					SELECT CAST(data AS NUMERIC) FROM dbo.split(emp_id_multi, '#')) OR ISNULL(emp_id_multi,'')=''
				)
				--SELECT S.data,EG.purpose,'Video' AS 'GalleryType','' AS 'DocPath'
				--FROM T0010_Emp_Gallery EG 
				--OUTER APPLY dbo.split(EG.Name, '#') S 
				--WHERE Type ='Video' AND expiry_date >= CONVERT(VARCHAR(12),GETDATE(),101) AND Cmp_ID = @Cmp_ID  
				--AND(@Emp_ID IN 
				--(
				--	SELECT CAST(data AS NUMERIC) FROM dbo.split(emp_id_multi, '#')) OR ISNULL(emp_id_multi,'')=''
				--)
			END
		ELSE
			--BEGIN -- For Images & Video
			--	SELECT * FROM
			--	(
			--		SELECT S.data,EG.purpose,'Images' AS 'GalleryType','' AS 'DocPath'
			--		FROM T0010_Emp_Gallery EG 
			--		OUTER APPLY dbo.split(EG.Name, '#') S 
			--		WHERE Type ='Images' AND EG.expiry_Date >= CONVERT(VARCHAR(12),GETDATE(),101) AND Cmp_ID = @Cmp_ID 
			--		AND(@Emp_ID IN 
			--		(
			--			SELECT CAST(data AS NUMERIC) FROM dbo.split(emp_id_multi, '#')) OR ISNULL(emp_id_multi,'')=''
			--		)
					
			--		UNION ALL
					
			--		SELECT S.data,EG.purpose,'Video' AS 'GalleryType','' AS 'DocPath'
			--		FROM T0010_Emp_Gallery EG 
			--		OUTER APPLY dbo.split(EG.Name, '#') S 
			--		WHERE Type ='Video' AND expiry_date >= CONVERT(VARCHAR(12),GETDATE(),101) AND Cmp_ID = @Cmp_ID  
			--		AND(@Emp_ID IN 
			--		(
			--			SELECT CAST(data AS NUMERIC) FROM dbo.split(emp_id_multi, '#')) OR ISNULL(emp_id_multi,'')=''
			--		)
			--	) AS Q ORDER BY Q.GalleryType
			--END
			BEGIN -- For Images & Video
			
						SELECT --S.data,
						Gallery_ID,Gallery_Name,EG.purpose,'Images' AS 'GalleryType','Images/' AS 'DocPath',Name as [data]
						FROM T0010_Emp_Gallery EG 
						--OUTER APPLY dbo.split(EG.Name, '#') S 
						WHERE Type ='Images' AND EG.expiry_Date >= CONVERT(VARCHAR(12),GETDATE(),101) AND Cmp_ID = @Cmp_ID 
						AND(@Emp_ID IN 
						(
							SELECT CAST(data AS NUMERIC) FROM dbo.split(emp_id_multi, '#')) OR ISNULL(emp_id_multi,'')=''
						)
						Union	
						SELECT --S.data,
						Gallery_ID,Gallery_Name,EG.purpose,'Video' AS 'GalleryType','Video/' AS 'DocPath',Name as [data]
						FROM T0010_Emp_Gallery EG 
						--OUTER APPLY dbo.split(EG.Name, '#') S 
						WHERE Type ='Video' AND EG.expiry_Date >= CONVERT(VARCHAR(12),GETDATE(),101) AND Cmp_ID = @Cmp_ID 
						AND(@Emp_ID IN 
						(
							SELECT CAST(data AS NUMERIC) FROM dbo.split(emp_id_multi, '#')) OR ISNULL(emp_id_multi,'')=''
						)

						--Declare @ConData varchar(500)
						--SELECT
						--@ConData = STUFF((SELECT ',' + Q.data
						--FROM	(
						--				SELECT distinct(EG.purpose),S.data,'Images' AS 'GalleryType','' AS 'DocPath' 
						--				FROM T0010_Emp_Gallery EG 
						--				OUTER APPLY dbo.split(EG.Name, '#') S  
						--				WHERE Type ='Images' AND EG.expiry_Date >= CONVERT(VARCHAR(12),GETDATE(),101) AND Cmp_ID = @Cmp_ID 
						--				AND(@Emp_ID IN 
						--				(
						--					SELECT CAST(data AS NUMERIC) FROM dbo.split(emp_id_multi, '#')) OR ISNULL(emp_id_multi,'') =''
						--				)
									
						--				UNION ALL
								
						--				SELECT S.data,EG.purpose,'Video' AS 'GalleryType','' AS 'DocPath' 
						--				FROM T0010_Emp_Gallery EG 
						--				OUTER APPLY dbo.split(EG.Name, '#') S 
						--				WHERE Type ='Video' AND expiry_date >= CONVERT(VARCHAR(12),GETDATE(),101) AND Cmp_ID = @Cmp_ID  
						--				AND(@Emp_ID IN 
						--				(
						--					SELECT CAST(data AS NUMERIC) FROM dbo.split(emp_id_multi, '#')) OR ISNULL(emp_id_multi,'')=''
						--				)
						--			) AS Q 
						--			 FOR XML Path('')),1,1,'')

						--			SELECT *, @ConData as data FROM
						--			(
						--				SELECT distinct(EG.purpose),'Images' AS 'GalleryType','' AS 'DocPath'
						--				FROM T0010_Emp_Gallery EG 
						--				OUTER APPLY dbo.split(EG.Name, '#') S 
						--				WHERE Type ='Images' AND EG.expiry_Date >= CONVERT(VARCHAR(12),GETDATE(),101) AND Cmp_ID = @Cmp_ID
						--				AND(@Emp_ID IN 
						--				(
						--					SELECT CAST(data AS NUMERIC) FROM dbo.split(emp_id_multi, '#')) OR ISNULL(emp_id_multi,'')=''
						--				)
								
						--				UNION ALL
								
						--				SELECT EG.purpose,'Video' AS 'GalleryType','' AS 'DocPath'
						--				FROM T0010_Emp_Gallery EG 
						--				OUTER APPLY dbo.split(EG.Name, '#') S 
						--				WHERE Type ='Video' AND expiry_date >= CONVERT(VARCHAR(12),GETDATE(),101) AND Cmp_ID = @Cmp_ID
						--				AND(@Emp_ID IN 
						--				(
						--					SELECT CAST(data AS NUMERIC) FROM dbo.split(emp_id_multi, '#')) OR ISNULL(emp_id_multi,'')=''
						--				)
						--			) AS Q ORDER BY Q.GalleryType
					END
	END
ELSE IF @Type = 'R' --- For Request Details
	BEGIN
		SELECT request_id,request_type,request_detail,(CASE WHEN ISNULL(VC.emp_name1,'')='' THEN REPLACE(VC.Login_Name1,VC.domain_name1,'') ELSE VC.emp_name1 END) AS 'RequestBy',
		'Reply' AS 'ReqStatus',request_status,VC.emp_name AS 'RepliedBy',status,VC.Feedback_detail,VC.request_date, --CONVERT(varchar(11), VC.request_date,103) AS 'request_date'
		(CASE WHEN EM.Image_Name = '0.jpg' OR EM.Image_Name = '' THEN (CASE WHEN EM.Gender = 'Male' THEN 'Emp_Default.png' ELSE 'Emp_Default_Female.png' END) ELSE EM.Image_Name END) AS 'PImageName',
		(CASE WHEN TEM.Image_Name = '0.jpg' OR TEM.Image_Name = '' THEN (CASE WHEN TEM.Gender = 'Male' THEN 'Emp_Default.png' ELSE 'Emp_Default_Female.png' END) ELSE TEM.Image_Name END) AS 'RImageName'
		FROM V0090_Common_Request_Detail VC
		INNER JOIN T0011_LOGIN LM ON VC.Login_id = LM.Login_ID
		INNER JOIN T0080_EMP_MASTER EM ON LM.Emp_ID = EM.Emp_ID
		INNER JOIN T0011_LOGIN TLM ON VC.Login_id = TLM.Login_ID
		INNER JOIN T0080_EMP_MASTER TEM ON TLM.Emp_ID = TEM.Emp_ID
		WHERE LM.Emp_ID = @Emp_ID

		UNION ALL

		SELECT request_id,request_type,request_detail,(CASE WHEN ISNULL(VC.emp_name,'') = '' THEN REPLACE(VC.Login_Name1,VC.Domain_Name1,'') ELSE VC.emp_name1 END) AS 'RequestBy',
		'Posted' AS 'ReqStatus',request_status,VC.emp_name AS 'RepliedBy',status,VC.Feedback_detail,VC.request_date, -- CONVERT(varchar(11), VC.request_date,103) AS 'request_date'
		(CASE WHEN EM.Image_Name = '0.jpg' OR EM.Image_Name = '' THEN (CASE WHEN EM.Gender = 'Male' THEN 'Emp_Default.png' ELSE 'Emp_Default_Female.png' END) ELSE EM.Image_Name END) AS 'PImageName',
		(CASE WHEN TEM.Image_Name = '0.jpg' OR TEM.Image_Name = '' THEN (CASE WHEN TEM.Gender = 'Male' THEN 'Emp_Default.png' ELSE 'Emp_Default_Female.png' END) ELSE TEM.Image_Name END) AS 'RImageName'
		FROM V0090_Common_Request_Detail VC
		INNER JOIN T0011_LOGIN LM ON VC.Emp_Login_id = LM.Login_ID
		INNER JOIN T0080_EMP_MASTER EM ON LM.Emp_ID = EM.Emp_ID
		INNER JOIN T0011_LOGIN TLM ON VC.Login_id = TLM.Login_ID
		INNER JOIN T0080_EMP_MASTER TEM ON TLM.Emp_ID = TEM.Emp_ID
		WHERE LM.Emp_ID = @Emp_ID

		--SELECT request_id,request_type,request_detail,(CASE WHEN ISNULL(VC.emp_name1,'')='' THEN REPLACE(VC.Login_Name1,VC.domain_name1,'') ELSE VC.emp_name1 END) AS 'RequestBy',
		--'Reply' AS 'ReqStatus',request_status,emp_name AS 'RepliedBy',status,VC.Feedback_detail,VC.request_date --CONVERT(varchar(11), VC.request_date,103) AS 'request_date'
		--FROM V0090_Common_Request_Detail VC
		--INNER JOIN T0011_LOGIN LM ON VC.Login_id = LM.Login_ID
		--WHERE LM.Emp_ID = @Emp_ID

		--UNION ALL
		
		--SELECT request_id,request_type,request_detail,(CASE WHEN ISNULL(VC.emp_name,'') = '' THEN REPLACE(VC.Login_Name1,VC.Domain_Name1,'') ELSE VC.emp_name1 END) AS 'RequestBy',
		--'Posted' AS 'ReqStatus',request_status,emp_name AS 'RepliedBy',status,VC.Feedback_detail,VC.request_date -- CONVERT(varchar(11), VC.request_date,103) AS 'request_date'
		--FROM V0090_Common_Request_Detail VC
		--INNER JOIN T0011_LOGIN LM ON VC.Emp_Login_id = LM.Login_ID
		--WHERE LM.Emp_ID = @Emp_ID
		
		ORDER BY request_id desc
	END
ELSE IF @Type = 'T' --- For Get Employee Document Type
	BEGIN
		SELECT * FROM T0040_DOCUMENT_MASTER WHERE Cmp_ID = @Cmp_ID --AND Doc_Required = 1 
		
		--SELECT TD.Doc_ID,TD.Cmp_ID,TD.Doc_Name,TD.Doc_Comments 
		--FROM T0040_DOCUMENT_MASTER TD
		--LEFT JOIN 
		--(
		--	SELECT Doc_ID
		--	FROM T0090_EMP_DOC_DETAIL 
		--	WHERE Emp_ID = @Emp_ID
			
		--)ED ON TD.Doc_ID = ED.Doc_ID
		--WHERE Cmp_ID = @Cmp_ID AND Doc_Required = 1 AND ISNULL(ED.Doc_ID,0) = 0
	END
ELSE IF @Type = 'H' --- For Get Holiday List
	BEGIN
	
		DECLARE @Branch_ID INT
		DECLARE @From_Date DATETIME 
		DECLARE @To_date DATETIME 
	
		SET @From_Date = CAST('01-Jan-'+ CAST(@Year AS VARCHAR(4)) as DATE)
		SET @To_date = CAST('31-Dec-'+ CAST(@Year AS VARCHAR(4)) as DATE)

   
		SELECT @Branch_id = Branch_id  FROM T0095_increment AS A
		INNER JOIN(
		SELECT Emp_id,MAX(Increment_id) as Maxincrement_id 
		FROM T0095_Increment 
		WHERE Increment_effective_date BETWEEN @From_date AND @To_date
		AND Emp_ID=@Emp_ID
		GROUP BY Emp_id
		)AS B on A.Emp_id = B.Emp_id AND A.Increment_id = B.Maxincrement_id

		EXEC SP_Home_Holiday_Detail @Cmp_ID ,@From_Date,@To_Date,0,@Emp_ID,@Branch_ID
		
	END
ELSE IF @Type = 'N' -- For Get Comment & Like Details
	BEGIN
	
		EXEC P_Get_Comment_Detail @Emp_Id = @Emp_ID,@Cmp_Id = @Cmp_ID,@For_Date = @For_date,@Reminder_Type = @Reminder_type
		
		EXEC P_Get_Employee_Like @Emp_Id = @Emp_ID,@Cmp_Id = @Cmp_ID,@For_Date = @For_date,@Reminder_Type = @Reminder_type
	END
ELSE IF @Type = 'CI' -- For Insert Comment
	BEGIN
		BEGIN TRY
			EXEC P0400_Employee_Comment @Comment_Id = @Notification_ID,@Emp_Id = @Emp_ID,@Cmp_Id = @Cmp_ID,
			@Emp_Id_Comment = @NEmp_ID,@For_date = @For_date,@U_Comment_Id = @U_Comment_Id,@Comment_date = @Notification_date,
			@Comment = @Comment,@Comment_Status = @Comment_Status,@Reply_Comment_Id = @Reply_Comment_Id,@Tran_type = 'I',
			@Reminder_type = @Reminder_type
			SELECT 'Comment Added Successfully#True#'
		END TRY
		BEGIN CATCH
			SELECT ERROR_MESSAGE()+'#False#'
		END CATCH
		
		--EXEC P_Get_Comment_Detail @Emp_Id = @Emp_ID,@Cmp_Id = @Cmp_ID,@For_Date = @For_date,@Reminder_Type = @Reminder_type
	END
ELSE IF @Type = 'CD' -- For Delete Comment
	BEGIN
		BEGIN TRY
			EXEC P0400_Employee_Comment @Comment_Id = @Notification_ID,@Emp_Id = @Emp_ID,@Cmp_Id = @Cmp_ID,
			@Emp_Id_Comment = @NEmp_ID,@For_date = @For_date,@U_Comment_Id = @U_Comment_Id,@Comment_date = @Notification_date,
			@Comment = @Comment,@Comment_Status = @Comment_Status,@Reply_Comment_Id = @Reply_Comment_Id,@Tran_type = 'D',
			@Reminder_type = @Reminder_type
			SELECT 'Comment Deleted Successfully#True#'
		END TRY
		BEGIN CATCH
			SELECT ERROR_MESSAGE()+'#False#'
		END CATCH
	END
ELSE IF @Type = 'LI' -- For Insert Like
	BEGIN
		BEGIN TRY
			EXEC P0400_Employee_Like @Emp_Id = @Emp_ID,@Cmp_Id = @Cmp_ID,@For_date = @For_date,@Emp_Like_Id = @NEmp_ID,
			@Like_date = @Notification_date,@Like_Flag = @Flag,@Reminder_type = @Reminder_type
			SELECT 'Like Added Successfully#True#'
		END TRY
		BEGIN CATCH
			SELECT ERROR_MESSAGE()+'#False#'
		END CATCH
	END
--ELSE IF @Type = 'CD' -- For Insert Comment
--	BEGIN
		 
		
--		IF @NotificationFlag = 1
--			BEGIN
--				SET @Reminder_type = 'TODAYS BIRTHDAY'
--			END
--		ELSE IF @NotificationFlag = 2
--			BEGIN
--				SET @Reminder_type = 'TODAYS WORK ANNIVERSARY'
--			END
--		ELSE IF @NotificationFlag = 3
--			BEGIN
--				SET @Reminder_type = 'TODAYS MARRIAGE ANNIVERSARY'
--			END
--		EXEC P0400_Employee_Comment @Comment_Id = @Notification_ID,@Emp_Id = @Emp_ID,@Cmp_Id = @Cmp_ID,@Emp_Id_Comment = @NEmp_ID,@For_date = @For_date,@U_Comment_Id = @U_Comment_Id,@Comment_date = @Notification_date,@Comment = @Comment,@Comment_Status = @Comment_Status,@Reply_Comment_Id = @Reply_Comment_Id,@Tran_type = 'D',@Reminder_type = @Reminder_type
		
--		EXEC P_Get_Comment_Detail @Emp_Id = @Emp_ID,@Cmp_Id = @Cmp_ID,@For_Date = @For_date,@Reminder_Type = @Reminder_type
	
--	END
