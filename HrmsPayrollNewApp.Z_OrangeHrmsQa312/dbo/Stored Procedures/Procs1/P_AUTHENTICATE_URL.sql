


CREATE PROCEDURE [dbo].[P_AUTHENTICATE_URL]
	@Privilage_ID	NUMERIC,
	@ABSOLUTE_URL	VARCHAR(1024),
	@PARA_FID		NUMERIC
AS
	BEGIN
		SET NOCOUNT ON;
		CREATE TABLE #PUBLIC_PAGES 
		(
			ID	NUMERIC,
			FORM_URL VARCHAR(MAX)
		)

		IF @Privilage_ID = 0
			RETURN;

		INSERT INTO #PUBLIC_PAGES  VALUES (1,'/Home.aspx')		
		INSERT INTO #PUBLIC_PAGES  VALUES (2,'/Employee_History.aspx')	
		INSERT INTO #PUBLIC_PAGES  VALUES (3,'/audit_trail.aspx')--add by chetan 20112017
		INSERT INTO #PUBLIC_PAGES  VALUES (4,'/Admin_ExitInterview.aspx')	 --Added by Jaina 19-02-2018		
		INSERT INTO #PUBLIC_PAGES  VALUES (5,'/Employee_Attendance.aspx')	
		INSERT INTO #PUBLIC_PAGES  VALUES (6,'/Employee_Attendance_New.aspx')	
		INSERT INTO #PUBLIC_PAGES  VALUES (7,'/WhoseOffInMyTeam.aspx')
		INSERT INTO #PUBLIC_PAGES  VALUES (8,'/WhosOff.aspx')
		INSERT INTO #PUBLIC_PAGES  VALUES (9,'/WhosOffInMyTeam.aspx')		
		INSERT INTO #PUBLIC_PAGES  VALUES (10,'/Employee_In_Out_with_Map.aspx')
		INSERT INTO #PUBLIC_PAGES  VALUES (11,'/view_posted_request.aspx')  --Added by Jaina 12-01-2019
		INSERT INTO #PUBLIC_PAGES  VALUES (12,'/Employee_Attendance_Admin_new.aspx') -- Added By Nilesh Patel on 19032019
		INSERT INTO #PUBLIC_PAGES  VALUES (13,'/Dashboard.aspx') 
		INSERT INTO #PUBLIC_PAGES  VALUES (14,'/Dashboard_Attendance.aspx') 
		INSERT INTO #PUBLIC_PAGES  VALUES (15,'/Dashboard_Leave.aspx') 
		INSERT INTO #PUBLIC_PAGES  VALUES (16,'/Dashboard_Claim.aspx') 
		INSERT INTO #PUBLIC_PAGES  VALUES (17,'/Dashboard_Team.aspx') 
		INSERT INTO #PUBLIC_PAGES  VALUES (18,'/Dashboard_Employee.aspx') 
		INSERT INTO #PUBLIC_PAGES  VALUES (19,'/Employee_Master_Application.aspx')  --Added binal
		INSERT INTO #PUBLIC_PAGES  VALUES (20,'/Employee_Master_Application_Details.aspx')  --Added binal
		INSERT INTO #PUBLIC_PAGES  VALUES (21,'/Employee_Master_Approval.aspx')  --Added binal
		INSERT INTO #PUBLIC_PAGES  VALUES (22,'/Dashboard_Attendance_backup.aspx')  --Added binal
		INSERT INTO #PUBLIC_PAGES  VALUES (23,'/Hrms_Feedback_Template.aspx')--Mukti(14062019)Ess Recruitment Feedback form  
		INSERT INTO #PUBLIC_PAGES  VALUES (24,'/viewEmailTemplate.aspx')--Nilesh Patel on 08092019
		INSERT INTO #PUBLIC_PAGES  VALUES (25,'/Employee_Master_Application_Import.aspx')  --Added binal
		INSERT INTO #PUBLIC_PAGES  VALUES (26,'/Time_Dashboard.aspx')  --Added Nilesh on 21082019
		INSERT INTO #PUBLIC_PAGES  VALUES (27,'/hrms_training_detail.aspx')  --Added binal on 03022020

		IF EXISTS(SELECT 1 FROM #PUBLIC_PAGES  WHERE CHARINDEX(FORM_URL, @ABSOLUTE_URL)> 0)
			RETURN;
		
		DECLARE @URI_PART VARCHAR(128)
		SET @URI_PART = REVERSE(@ABSOLUTE_URL)
		SET @URI_PART = SUBSTRING(@URI_PART,CHARINDEX('xpsa.',@URI_PART), LEN(@URI_PART))
		SET @URI_PART = REVERSE(SUBSTRING(@URI_PART,0, CHARINDEX('/',@URI_PART)))		

		/*IF URL IS BLANK IN FORM ID BUT, THAT PAGE HAS PERMISSION*/
		IF EXISTS(SELECT 1 FROM T0000_DEFAULT_FORM WITH (NOLOCK) WHERE FORM_ID=@PARA_FID AND ISNULL(FORM_URL,'') = '')
			BEGIN		
				IF EXISTS(SELECT 1 FROM [V0050_NO_PRIVILEGE_DETAIL] WHERE Privilage_ID=@Privilage_ID AND FORM_URL LIKE '%' + @URI_PART + '%')
					RETURN
			END
		
		/*IF URL IS DIFFERENT IN FORM ID*/
		IF NOT EXISTS(SELECT 1 FROM [V0050_NO_PRIVILEGE_DETAIL] 
					WHERE	FORM_ID=@PARA_FID AND Privilage_ID=@Privilage_ID 
							AND (FORM_URL LIKE '%' + @URI_PART + '%' OR ISNULL(FORM_URL,'') = ''))
							--AND FORM_URL LIKE '%' + @URI_PART + '%' AND ISNULL(FORM_URL,'') <> '')
			BEGIN
				RAISERROR('@@No Privilege Access for this page. 1@@',16,2)
				RETURN
			END	

		IF NOT EXISTS(SELECT 1 FROM [V0050_NO_PRIVILEGE_DETAIL] WHERE Privilage_ID=@Privilage_ID AND Form_Id=@PARA_FID)
			BEGIN
			
				RAISERROR('@@No Privilege Access for this page. 2@@',16,2)
				RETURN
			END


		DECLARE @URL VARCHAR(512)
		SELECT @URL= FORM_URL FROM T0000_DEFAULT_FORM WITH (NOLOCK)  WHERE Form_ID=@PARA_FID
		IF ISNULL(@URL,'') <> ''
			BEGIN
				IF CHARINDEX(@URL, @ABSOLUTE_URL) = -1
					BEGIN
						RAISERROR('@@No Privilege Access for this page. 3@@',16,2)
						RETURN		
					END
			END			

	END

