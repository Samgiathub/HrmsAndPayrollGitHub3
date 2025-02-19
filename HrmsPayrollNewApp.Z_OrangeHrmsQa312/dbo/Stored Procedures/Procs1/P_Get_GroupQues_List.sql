
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_Get_GroupQues_List]
	@Cmp_Id numeric(18,0)
AS
BEGIN
	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

    SELECT G.* , '<table class="group-question">' + Q.QuestionTable + '</table>' as Sub_Question
	FROM	T0040_Exit_Group_Master G WITH (NOLOCK)
		CROSS APPLY(SELECT (SELECT  Q.Question as td FROM T0200_Question_Exit_Analysis_Master Q WITH (NOLOCK)
					WHERE G.Group_Id=Q.Group_Id for XML PATH('tr')) AS QuestionTable) Q
	WHERE G.Cmp_Id=@Cmp_Id 
	ORDER BY G.Grp_Rate_Id
END


