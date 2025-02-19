
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_GET_TRAINING_HISTORY]
	 @Cmp_ID	    Numeric (18,0)
	,@Search_criteria   varchar(300)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

    DECLARE @query as nvarchar(max)
  
	set @query = 'select distinct Te.Emp_ID,(e.Alpha_Emp_Code +''-''+ e.Emp_Full_Name)Emp_Full_Name_new,
	Tran_feedback_ID,ta.Training_Date,ta.Training_End_Date,TE.Training_Apr_ID,(isnull(TA.Training_Code,
	ta.Training_Apr_ID) +''-''+ TA.Training_name)Training_name,(case when TI.emp_id is NOT null then ''Yes'' else ''No'' end)is_attend_name ,
	(case when TF.emp_id is NOT null then ''Yes'' else ''No'' end) FeedbackGiven,(case when TQ.emp_id is NOT null then ''Yes'' 
	else ''No'' end) EvaluationAttended, isnull(ts.Sup_Score,0)Sup_Score,TA.Faculty,i.Dept_id
	from
	T0130_HRMS_TRAINING_EMPLOYEE_DETAIL TE WITH (NOLOCK) LEFT JOIN (select emp_id,Training_Apr_Id from T0150_EMP_Training_INOUT_RECORD WITH (NOLOCK)
	where cmp_Id=' + cast(@Cmp_ID as varchar) + ' GROUP by emp_id,Training_Apr_Id)TI on Ti.Training_Apr_Id = te.Training_Apr_ID 
	and TE.Emp_ID = ti.emp_id inner join V0120_HRMS_TRAINING_APPROVAL TA on TA.Training_Apr_ID = TE.Training_Apr_ID 
	left JOIN (select emp_id,training_apr_id from T0150_HRMS_TRAINING_Answers  WITH (NOLOCK) where Cmp_Id = ' + cast(@Cmp_ID as varchar) + ' 
	GROUP by emp_id,Training_Apr_Id)TF on TF.Emp_ID = TE.Emp_ID and TF.Training_Apr_ID = TE.Training_Apr_ID 
	left JOIN (select emp_id,training_apr_id from T0160_HRMS_Training_Questionnaire_Response WITH (NOLOCK) 
	where Cmp_Id =' + cast(@Cmp_ID as varchar) + ' GROUP by emp_id,Training_Apr_Id)TQ on Tq.Emp_id = te.Emp_ID and 
	tq.Training_Apr_ID = te.Training_Apr_ID left join T0140_HRMS_TRAINING_Feedback_New TS WITH (NOLOCK) on 
	TS.Tran_Emp_Detail_Id = te.Tran_emp_Detail_ID inner JOIN T0080_Emp_master E WITH (NOLOCK) on e.Emp_ID = te.Emp_ID 
	inner Join T0095_INCREMENT I WITH (NOLOCK) on i.Emp_ID = e.Emp_ID and 
	i.Increment_Effective_Date =(select max(Increment_Effective_Date) from T0095_INCREMENT WITH (NOLOCK) where Emp_ID = e.emp_id) 
	left JOIN T0040_DEPARTMENT_MASTER D WITH (NOLOCK) on d.Dept_Id = i.Dept_ID where'
		
	if @Search_criteria <> ''
		exec(@query +  @Search_criteria)
	else
		exec(@query)
	
END
