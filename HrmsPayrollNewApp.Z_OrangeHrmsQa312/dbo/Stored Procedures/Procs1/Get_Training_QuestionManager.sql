
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Get_Training_QuestionManager]	
	 @r_emp_id numeric(18,0),
	 @Type TinyInt = 0
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN	
	
	DECLARE @emp_id numeric(18,0)
	DECLARE @trainingaprid numeric(18,0)
  
	CREATE table #Final
	(
		 Training_Name			varchar(100)
		,Training_Apr_ID		numeric(18,0)
		,Manager_feedback_Days  int
		,training_stdate		datetime
		,training_enddate		datetime
	)
	


DECLARE cur CURSOR FOR
	SELECT DISTINCT I.emp_id,Training_Apr_Id 
	FROM T0150_EMP_Training_INOUT_RECORD I WITH (NOLOCK) INNER JOIN
		 T0090_EMP_REPORTING_DETAIL R WITH (NOLOCK) on R.Emp_ID = I.emp_id and 
		 R.Effect_Date = (Select Max(Effect_Date) FROM  T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) WHERE Emp_ID = I.emp_id)
	WHERE R.R_Emp_ID=@r_emp_id --I.cmp_id=@cmp_id
	
OPEN cur
	FETCH NEXT FROM cur INTO @emp_id,@trainingaprid
	WHILE @@fetch_status=0
		BEGIN 
		
		IF NOT EXISTS(SELECT 1 FROM T0160_Hrms_Manager_FeedbackResponse WITH (NOLOCK) WHERE Training_Apr_Id = @trainingaprid and Feedback_By = @r_emp_id and Emp_Id=@emp_id)
				BEGIN	
					INSERT INTO #Final
					SELECT TM.Training_name,Training_Apr_Id,isnull(TA.Manager_FeedbackDays,0),TA.Training_Date,TA.Training_End_Date 
					FROM V0120_HRMS_TRAINING_APPROVAL TA  INNER JOIN
						 T0040_Hrms_Training_master TM WITH (NOLOCK) on TM.Training_id = TA.Training_id CROSS JOIN
						 T0150_HRMS_TRAINING_Questionnaire TQ WITH (NOLOCK)
					WHERE TA.Training_Apr_Id = @trainingaprid 
						 and exists(SELECT data from dbo.Split(TQ.Training_Id,'#')PB WHERE PB.Data=TA.Training_id )
						 and TQ.Questionniare_Type=2
				END
			FETCH NEXT FROM cur INTO @emp_id,@trainingaprid
		END
CLOSE cur
DEALLOCATE cur


	IF @TYPE = 1	
		BEGIN
			IF OBJECT_ID('tempdb..#Notification_Value') IS NOT NULL
				BEGIN
					TRUNCATE TABLE #Notification_Value
					INSERT INTO #Notification_Value
					SELECT	COUNT(distinct 1) 
					FROM	#Final
					WHERE	getdate() >= CASE WHEN isnull(Manager_feedback_Days,0)  <> 0 then DATEADD(DAY,Manager_feedback_Days,training_stdate) end 
				END
			ELSE
				SELECT	COUNT(distinct 1) 
				FROM	#Final
				WHERE	getdate() >= CASE WHEN isnull(Manager_feedback_Days,0)  <> 0 then DATEADD(DAY,Manager_feedback_Days,training_stdate) end 

		END		
	ELSE
		select distinct * FROM #Final
		WHERE getdate() >= CASE WHEN isnull(Manager_feedback_Days,0)  <> 0 then DATEADD(DAY,Manager_feedback_Days,training_stdate) end 


DROP TABLE #Final
END
