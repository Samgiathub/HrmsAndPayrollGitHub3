
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0050_HRMS_FROM_TO_PROCESS_TEMPLATE]
	@Cmp_ID NUMERIC = 0,
	@From_Process_Id NUMERIC =0,
	@To_Process_Id NUMERIC =0,	
	@New_Process_Name NVARCHAR(500) = '',
	@Return_Id NUMERIC = 1 OUTPUT
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	DECLARE @process_q_id NUMERIC
	SET @process_q_id =0
	
	DECLARE @sorting NUMERIC =0
	SET @sorting = 0
	
	DECLARE @process_id NUMERIC
	set @process_id = 0

IF @To_Process_Id <> 0 and @New_Process_Name = ''
	BEGIN
		IF Exists(SELECT 1 FROM T0045_HRMS_R_PROCESS_TEMPLATE pt1 WITH (NOLOCK) Inner Join T0045_HRMS_R_PROCESS_TEMPLATE pt2 WITH (NOLOCK) ON pt1.QUE_Detail = pt2.QUE_Detail 
				  WHERE pt1.Process_ID = @From_Process_Id and pt2.Process_ID = @To_Process_Id and pt2.Cmp_id=@Cmp_ID)
					  BEGIN
					  SET @Return_Id = -1							
					  RETURN @Return_Id
				  END					
				  SELECT @process_q_id = MAX(ISNULL(process_q_id,0)) from T0045_HRMS_R_PROCESS_TEMPLATE WITH (NOLOCK)
				  SELECT @sorting = MAX(ISNULL(Dis_No,0))+1 from T0045_HRMS_R_PROCESS_TEMPLATE WITH (NOLOCK) WHERE Process_ID=@To_Process_Id and Cmp_id=@Cmp_ID 

	INSERT INTO T0045_HRMS_R_PROCESS_TEMPLATE 
		(process_q_id,Cmp_ID, Process_ID, QUE_Detail, IS_Title, Is_Description, Is_Raiting, is_dynamic, Dis_No, Question_Type, Question_Option)
		SELECT @process_q_id + (row_number() over(order by Process_ID )) n, Cmp_ID, @To_Process_Id, QUE_Detail, IS_Title, Is_Description, Is_Raiting, is_dynamic, @sorting, Question_Type, Question_Option
		FROM T0045_HRMS_R_PROCESS_TEMPLATE AS T0045_HRMS_R_PROCESS_TEMPLATE_1 WITH (NOLOCK) WHERE Process_ID=@From_Process_Id and Cmp_id=@Cmp_ID 	
		RETURN  @Return_Id
END
ELSE
	BEGIN
		IF Exists(SELECT 1 FROM T0040_HRMS_R_PROCESS_MASTER WITH (NOLOCK) WHERE cmp_ID = @cmp_id and	Process_Name = @New_Process_Name)
				  BEGIN
						SET @Return_Id = 0							
						RETURN @Return_Id
				  END
		SELECT @process_q_id = Isnull(max(Process_Q_ID),0) + 1 	FROM T0045_HRMS_R_PROCESS_TEMPLATE WITH (NOLOCK)
		SELECT @process_id = Isnull(max(process_id),0) + 1 	FROM T0040_HRMS_R_PROCESS_MASTER WITH (NOLOCK)

		INSERT INTO T0040_HRMS_R_PROCESS_MASTER(Process_Id,Cmp_Id,Process_Name,Process_Desc)
		VALUES (@process_id,@Cmp_Id,@New_Process_Name,'')

		SELECT @To_Process_Id = ISNULL(MAX(Process_Id),0) FROM T0040_HRMS_R_PROCESS_MASTER WITH (NOLOCK)
								 
		 INSERT INTO T0045_HRMS_R_PROCESS_TEMPLATE 
		 (process_q_id,Cmp_ID, Process_ID, QUE_Detail, IS_Title, Is_Description, Is_Raiting, is_dynamic, Dis_No, Question_Type, Question_Option)
		 SELECT @process_q_id + (ROW_NUMBER() OVER(ORDER BY Process_ID )) n, Cmp_ID, @To_Process_Id, QUE_Detail, IS_Title, Is_Description, Is_Raiting, is_dynamic, Dis_No, Question_Type, Question_Option
		 FROM T0045_HRMS_R_PROCESS_TEMPLATE AS T0045_HRMS_R_PROCESS_TEMPLATE_1 WITH (NOLOCK)
		 WHERE Process_ID=@From_Process_Id and Cmp_id=@Cmp_ID 
		 SET @Return_Id = 1		
		 RETURN  @Return_Id
	END
END			
