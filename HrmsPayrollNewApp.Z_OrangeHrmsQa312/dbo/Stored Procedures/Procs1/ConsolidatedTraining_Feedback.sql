

---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[ConsolidatedTraining_Feedback]
	@cmp_id  as numeric(18,0),
	@Training_Apr_ID as numeric(18,0)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
   
   create table #TrainingFeedback
	(
		 Training_Que_ID  numeric(18,0)	
		,Question_Type int
		,sorting_No	int
		,Question varchar(max)
		,QuestionType  varchar(200)	
	)
	
	declare @training_Id as numeric(18,0)
	declare @emp_id as numeric(18,0)
	declare @Training_Que_ID as numeric(18,0)
	declare @Answer as numeric(18,0)
	declare @columnname as varchar(max)
	declare @empname as varchar(max)
	declare @SQLCol as varchar(max)
	declare @Alpha_emp_code as varchar(50)
	
	
	select @training_Id=Training_id from T0120_HRMS_TRAINING_APPROVAL WITH (NOLOCK) where Training_Apr_ID =@Training_Apr_ID

	insert into #TrainingFeedback
	Select Training_Que_ID,Question_Type,Sorting_No,Question,
	case when Question_Type = 1 then 'Title' when Question_Type = 2 then 'Text' when Question_Type=3 then 'Paragraph Text' when Question_Type = 4 then 'Multiple Choice' when Question_Type=5 then 'CheckBoxList' when Question_Type = 6 then 'DropdownList' else 'Paragraph Text' end  QuestionType

	From T0150_HRMS_TRAINING_Questionnaire WITH (NOLOCK)
	Where Cmp_Id = @cmp_id And @training_Id in (select Data from dbo.Split(Training_Id, '#'))
	and Questionniare_Type = 0 order by Sorting_No
	
	declare cur cursor
	for 
		select distinct T0150_HRMS_TRAINING_Answers.emp_Id,Emp_Full_Name,Alpha_Emp_Code from T0150_HRMS_TRAINING_Answers WITH (NOLOCK) inner JOIN
		T0080_EMP_MASTER WITH (NOLOCK) on T0150_HRMS_TRAINING_Answers.emp_Id =T0080_EMP_MASTER.Emp_ID
		where Training_Apr_ID = @Training_Apr_ID
	open cur
			fetch next from cur into @emp_id,@empname,@Alpha_emp_code
			while @@FETCH_STATUS =0
				Begin
					set @columnname = Replace(Replace(('ANS$'+ @Alpha_emp_code+'@'+@empname),' ','_'),'.','')
					set @SQLCol = 'alter  table  #TrainingFeedback ADD [' + @columnname + '] VARCHAR(800)'
					exec(@SQLCol)
					
					set @SQLCol =''
						set @SQLCol = ' update  #TrainingFeedback
						set ' + cast(@columnname as VARCHAR(800)) + ' = EA.Answer
						from (select answer,Tran_Question_Id from T0150_HRMS_TRAINING_Answers WITH (NOLOCK) where emp_id=' + cast(@emp_id as VARCHAR) + ' and Training_Apr_ID='+ cast(@Training_Apr_ID as varchar) +')EA
						where Training_Que_ID = EA.Tran_Question_Id '
						print(@SQLCol)
					exec(@SQLCol)
					
					set @columnname = ''
					set @SQLCol =''
					fetch next from cur into @emp_id,@empname,@Alpha_emp_code
				END
	close cur
	deallocate cur

	select (TA.Training_Code +'-'+ T.Training_name)Training_name,TA.Training_Date,TA.Training_End_Date,TA.Training_FromTime,TA.Training_ToTime,TT.Training_TypeName,TA.Faculty 
	from T0120_HRMS_TRAINING_APPROVAL TA WITH (NOLOCK) inner Join 
	 T0040_Hrms_Training_master T WITH (NOLOCK) on T.Training_id = TA.Training_id inner join
	 T0030_Hrms_Training_Type TT WITH (NOLOCK) on TT.Training_Type_ID = TA.Training_Type
	 where Training_Apr_ID = @Training_Apr_ID
	 
	select * from #TrainingFeedback order by sorting_No

	drop table #TrainingFeedback
END

