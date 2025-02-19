


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	exec P0152_Hrms_Training_Quest_Final_Get 19,27,57
-- exec  P0152_Hrms_Training_Quest_Final_Get 55,25,55
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0152_Hrms_Training_Quest_Final_Get]
	 @cmp_id		numeric(18,0)
	,@training_id	numeric(18,0)
	,@tranining_apr_id	numeric(18,0)
AS
BEGIN 

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	if exists(select 1 from V0152_Hrms_Training_Quest_Final where Cmp_Id = @cmp_id and Training_Apr_Id=@tranining_apr_id and Training_Id like + '%'+ cast(@training_id as varchar(18)) + '%')
		begin 
			with cte as
			(
				select Training_Que_ID,Question,Question_Type,QuestionType,Answer,Marks,Tran_Id 
				from V0152_Hrms_Training_Quest_Final 
				where cmp_id=@cmp_id   and Questionniare_Type=1 and Training_Apr_Id=@tranining_apr_id and  Training_Id like + '%'+ cast(@training_id as varchar(18)) + '%'
				Union all
				select Training_Que_ID,Question,Question_Type,QuestionType,Answer,ISNULL(null, Marks) AS Marks,null as Tran_Id 
				from V0150_HRMS_TRAINING_Questionnaire 
				where cmp_id = @cmp_id and Questionniare_Type=1 and Training_Id like + '%'+ cast(@training_id as varchar(18)) + '%'
				and Training_Que_ID not IN (select Training_Que_ID from V0152_Hrms_Training_Quest_Final where cmp_id=@cmp_id   and Questionniare_Type=1 and Training_Apr_Id=@tranining_apr_id and  Training_Id like + '%'+ cast(@training_id as varchar(18)) + '%')
			)
			select distinct Training_Que_ID,Question,Question_Type,QuestionType,Answer,Marks,Tran_Id  from cte 
		end	
	else
		begin 
			select Training_Que_ID,Question,Question_Type,QuestionType,Answer,ISNULL(null, Marks) AS Marks,null as Tran_Id 
			from V0150_HRMS_TRAINING_Questionnaire 
			where cmp_id = @cmp_id and Questionniare_Type=1 and Training_Id like + '%'+ cast(@training_id as varchar(18)) + '%'
		end
END


