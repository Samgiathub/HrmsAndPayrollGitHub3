
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Get_Emp_Training_ManagerFeedback]
	 @Cmp_ID	numeric(18,0)
	,@r_emp_id numeric(18,0)
	,@training_apr_Id numeric(18,0)
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	create table #Trainee
	(
		 Emp_Id				numeric(18,0)
		,emp_full_name		varchar(200)	
	)
	create table #QuestionEmp
	(
		Training_Apr_ID	numeric(18,0)
		,Question_Id		numeric(18,0)
		,Question			varchar(500)
		,Question_Option     varchar(800)
		,QuestionType		varchar(50)
	)
	
	declare @empid as numeric(18,0)
	declare @emp_full_name as varchar(200)
	declare @columnname as varchar(max)
	declare @SQLCol as varchar(max)
	
	insert into #Trainee (emp_id,emp_full_name)
	select DISTINCT TE.emp_id,(E.Alpha_Emp_Code+'-'+(ISNULL(e.Emp_First_Name,'') + ISNULL(e.Emp_Last_Name,'')))as Emp_Full_Name
	from T0150_EMP_Training_INOUT_RECORD TE WITH (NOLOCK) LEFT JOIN
	T0090_EMP_REPORTING_DETAIL RM WITH (NOLOCK) on RM.Emp_ID = TE.Emp_ID and RM.Effect_Date = (select max(Effect_Date) from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) where emp_id=TE.emp_id) left JOIN
	T0120_HRMS_TRAINING_APPROVAL TA WITH (NOLOCK) on TA.Training_Apr_ID = TE.Training_Apr_ID inner JOIN
	--T0160_Hrms_Manager_FeedbackResponse MR on MR.Training_Apr_Id = TE.Training_Apr_Id and Mr.Feedback_By=rm.R_Emp_ID and te.emp_id <> mr.Emp_Id  inner JOIN
	T0080_EMP_MASTER E WITH (NOLOCK) on e.Emp_ID = TE.emp_id and RM.R_Emp_ID=@r_emp_id
	where TE.Training_Apr_Id =@training_apr_Id
	
	insert into #QuestionEmp(Training_Apr_ID,Question_Id,Question,Question_Option,QuestionType)
		select @training_apr_Id,tq.Training_Que_ID,TQ.Question,TQ.Question_Option,
		case when TQ.Question_Type =1 then 'Title' when TQ.Question_Type=2 then 'Text' when TQ.Question_Type=3 then 'Paragraph Text' 
		     when TQ.Question_Type =4 then 'Multiple Choice' when TQ.Question_Type =5 then 'CheckboxList' when TQ.Question_Type =6 then 'DropdownList' end
		from  T0120_HRMS_TRAINING_APPROVAL TA WITH (NOLOCK) inner Join 
			  T0150_HRMS_TRAINING_Questionnaire TQ WITH (NOLOCK) on TA.training_Id in (select data from dbo.Split(TQ.training_id,'#'))  
		Where TA.Training_Apr_ID=@training_apr_Id and TQ.Questionniare_Type =2
		order by TQ.Sorting_No
		
	
DECLARE cur cursor
for 
	select emp_id,emp_full_name from #Trainee
open cur
	fetch next from cur into @empid,@emp_full_name
	while @@FETCH_STATUS =0
		begin
		    
			 set @columnname = Replace(Replace(Replace('Emp'+(cast(@empid as varchar(18))+'$'+ ISNULL(@emp_full_name,'')),' ','_'),'.','#'),'-','@')
				set @SQLCol = 'alter table #QuestionEmp ADD [' + @columnname + '] VARCHAR(MAX)'
				exec(@SQLCol)
				
				print @columnname						
			set @SQLCol =''
			 set @SQLCol = 'Update #QuestionEmp set ' + cast(@columnname as VARCHAR(max)) + '= isnull(k.Manager_Answer,'' '')
							From (select Tran_Question_Id,Manager_Answer,emp_id from T0160_Hrms_Manager_FeedbackResponse WITH (NOLOCK) where emp_id='+ cast(@empid as varchar(18)) +' and training_apr_id=' + cast(@training_apr_Id as varchar(18)) + ' and Feedback_By='+ cast(@r_emp_id as varchar(18)) +')k
							Where Question_Id=k.Tran_Question_Id'
						
				
			exec(@SQLCol)
			
			set @columnname =''
			set @SQLCol =''
			
		
		
			fetch next from cur into @empid,@emp_full_name
		End
close cur
DEALLOCATE cur



select * from #QuestionEmp

drop TABLE #Trainee
drop table #QuestionEmp
END


