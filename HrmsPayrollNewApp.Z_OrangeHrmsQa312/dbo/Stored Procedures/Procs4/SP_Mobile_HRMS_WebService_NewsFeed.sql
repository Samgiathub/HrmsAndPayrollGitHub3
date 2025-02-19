

-- =============================================
-- Author:		SHAIKH RAMIZ
-- Create date: 10/05/2019
-- Description:	TO SHOW NEWS FEED IN MOBILE
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_NewsFeed]
	@CMP_ID		NUMERIC(18,0),
    @EMP_ID		NUMERIC(18,0)
	
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	DECLARE @BRANCH_ID AS NUMERIC
	SELECT @BRANCH_ID = I.Branch_ID
	FROM T0095_INCREMENT I WITH (NOLOCK)
		INNER JOIN 
			( SELECT MAX(I.INCREMENT_ID) AS INCREMENT_ID, I.EMP_ID 
				FROM T0095_INCREMENT I WITH (NOLOCK) 
				INNER JOIN 
					(
						SELECT MAX(i3.INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
						FROM T0095_INCREMENT I3 WITH (NOLOCK)
						WHERE I3.Increment_effective_Date <= GETDATE()
						GROUP BY I3.EMP_ID  
					) I3 ON I.Increment_Effective_Date=I3.Increment_Effective_Date AND I.EMP_ID=I3.Emp_ID	
			   WHERE I.INCREMENT_EFFECTIVE_DATE <= GETDATE() and I.Cmp_ID = @CMP_ID 
			   GROUP BY I.emp_ID  
			) Qry on	I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID 
	WHERE CMP_ID = @CMP_ID AND I.EMP_ID = @EMP_ID	
							
    CREATE TABLE #NEWS_DETAILS 
	(  
		News_Title			VARCHAR(50),
		News_Description	VARCHAR(250),
		Is_Thought			TINYINT,
		Is_PopUp			TINYINT,
		Login_Notification	TINYINT,
		Is_Member_Flag		TINYINT,
		News_Announ_EmpID	NUMERIC,
		News_Announcer		VARCHAR(100),
		SYSTEM_DATE			DATETIME
	)	
	
	print @BRANCH_ID

	--INSERTING COMMON NEWS FEED - WHICH WILL BE DISPLAYED TO ALL;
	INSERT INTO #NEWS_DETAILS
	SELECT	News_Title ,News_Description ,  Flag_T , Flag_P , Login_Notification , Is_Member_Flag ,News_Announ_EmpID, 'Admin' as News_Announcer, SYSTEM_DATE
	FROM	T0040_NEWS_LETTER_MASTER WITH (NOLOCK)
	WHERE	CMP_ID = @CMP_ID AND Is_Visible = 1 and Is_Member_Flag = 0
			AND Start_Date <= CAST(GETDATE() as varchar(11))
			And End_Date   >= CAST(GETDATE() as varchar(11))
			AND (1 = CASE WHEN CHARINDEX('#'+Cast(@BRANCH_ID as varchar(10)) +'#' ,'#'+  Isnull(Branch_Wise_News_Announ,@BRANCH_ID) +'#')  > 0
					 Then 1 Else 0 END or Branch_Wise_News_Announ = '')
	ORDER BY News_Letter_ID
	
	--INSERTING MANAGER NEWS FEED - WHICH WILL BE DISPLAYED TO DOWNLINE EMPLOYEES ONLY;
	INSERT INTO #NEWS_DETAILS
	SELECT	News_Title ,News_Description ,  Flag_T , Flag_P , Login_Notification , Is_Member_Flag ,News_Announ_EmpID, 'Admin' as News_Announcer, SYSTEM_DATE
	FROM	T0040_NEWS_LETTER_MASTER WITH (NOLOCK)
	WHERE	CMP_ID = @CMP_ID AND Is_Visible = 1 and Is_Member_Flag = 1
			AND Start_Date <= CAST(GETDATE() as varchar(11))
			And End_Date   >= CAST(GETDATE() as varchar(11))
			AND (1 = CASE WHEN CHARINDEX('#'+Cast(@BRANCH_ID as varchar(10)) +'#' ,'#'+  Isnull(Branch_Wise_News_Announ,@BRANCH_ID) +'#')  > 0
					 Then 1 Else 0 END or Branch_Wise_News_Announ = '')
	ORDER BY News_Letter_ID

	--UPDATING MANAGER NAME FROM EMPLOYEE MASTER
	UPDATE	#NEWS_DETAILS
	SET		News_Announcer = EMP_FULL_NAME
	FROM	T0080_EMP_MASTER EM
		INNER JOIN #NEWS_DETAILS ND ON EM.EMP_ID = ND.News_Announ_EmpID
	WHERE EM.CMP_ID = @CMP_ID
	
	
	SELECT News_Title ,News_Description ,  Is_Thought , Is_PopUp , Login_Notification , Is_Member_Flag ,News_Announcer,
		CASE WHEN DATEDIFF(DAY, SYSTEM_DATE, GETDATE()) % 7 > 0 THEN			--IF DAYS > 0, THEN DISPLAY IN DAYS
				CASE WHEN DATEDIFF(day, SYSTEM_DATE, GETDATE()) % 7 = 1 THEN 
						'1 day ago'
					ELSE
						CAST(DATEDIFF(day, SYSTEM_DATE, GETDATE()) % 7 AS NVARCHAR(50)) + ' days ago '
					END
			WHEN DATEDIFF(DAY, SYSTEM_DATE, GETDATE()) % 7 = 0 THEN		--IF DAYS < 0 , THEN DISPLAY IN HOURS :: ELSE IN MINUTES
				CASE WHEN DATEDIFF(hour, SYSTEM_DATE, GETDATE()) % 24 > 0 THEN
						CASE WHEN DATEDIFF(hour, SYSTEM_DATE, GETDATE()) % 24 = 1 THEN
								'1 hour ago'
							WHEN DATEDIFF(hour, SYSTEM_DATE, GETDATE()) % 24 > 1 THEN
								CAST(DATEDIFF(hour, SYSTEM_DATE, GETDATE()) % 24  AS NVARCHAR(50)) + ' hours ago '
							END
					ELSE
						CAST(DATEDIFF(minute, SYSTEM_DATE, GETDATE()) % 60 AS NVARCHAR(50)) + ' minutes ago '
					END				
			END AS ElapsedTime
	FROM #NEWS_DETAILS
	
END

