

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[GetTraining_FeedbackGraphicalSummary]
	 @Cmp_Id			numeric(18,0)
	,@training_Id		numeric(18,0)
	,@Question_Id		numeric(18,0)
	,@Question_Type		int
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


BEGIN


   create table #Table1
	(
		 Question_Option	varchar(800)
		,Response			numeric(18,2)	
		,Res_Count			numeric(18,0)
		,Emp_id				numeric(18,0)
	)
	
	declare @optionstr as varchar(800) 
	declare @col1 as varchar(100)
	declare @tot_cnt as int
	declare @res_cnt as int
	declare @empid as numeric(18,0)
	declare @col2 as numeric(18,0)
	declare @chkcnt as numeric(18,0)
	set @chkcnt = 0
	SET @optionstr = ''
	
		If @Question_Type =4 or @Question_Type=5 or @Question_Type=6
			BEGIN
				select @optionstr = Question_Option from T0150_HRMS_TRAINING_Questionnaire WITH (NOLOCK) where Training_Que_ID=@Question_Id 
				insert into #Table1 (Question_Option)
				select  CAST(DATA  AS varchar) from dbo.Split (@optionstr,'#') 
				
				declare cur cursor
			for 
				select Question_Option from #Table1 where Question_Option <> ''
			open cur
				fetch next from cur into @col1
				while @@FETCH_STATUS = 0
					Begin
						-- get total count
						select @tot_cnt = COUNT(emp_id) from T0150_HRMS_TRAINING_Answers WITH (NOLOCK) where Training_Apr_ID = @training_Id and Tran_Question_Id = @Question_Id 
						if @Question_Type = 5
							begin
								select @res_cnt =  COUNT(emp_id) from T0150_HRMS_TRAINING_Answers WITH (NOLOCK) where Training_Apr_ID = @training_Id and Tran_Question_Id = @Question_Id and Answer like '%' +  @col1 + '%'
								set @chkcnt = @chkcnt + @res_cnt
								set @tot_cnt = @chkcnt
								
								update #Table1 
								set Res_Count = @res_cnt
								Where Question_Option = @col1								
							End
						else
							begin						
								select @res_cnt =  COUNT(emp_id) from T0150_HRMS_TRAINING_Answers WITH (NOLOCK) where training_Apr_ID = @training_Id and Tran_Question_Id = @Question_Id and Answer = @col1							
									update #Table1 
									set Res_Count = @res_cnt
									, Response = (@res_cnt * 100) / @tot_cnt
									Where Question_Option = @col1
							End	
						fetch next from cur into @col1
					End
			close cur
			deallocate cur
			END
			
			if @Question_Type = 5
				begin
					declare cur cursor
					for 
						select res_count,Question_Option from #Table1 where Question_Option <> ''
					open cur
					fetch next from cur into @col2,@col1
					while @@FETCH_STATUS = 0
						Begin								
								update #Table1 
									set  Response = (@col2 * 100) / @tot_cnt
									Where Question_Option = @col1 and Res_Count = @col2
									
							fetch next from cur into @col2,@col1
						end
					close cur
					deallocate cur					
				End
		Else IF @Question_Type = 3 or @Question_Type = 2
		Begin
			 Insert into  #Table1 (Emp_id)
			 (select Emp_Id from  T0150_HRMS_TRAINING_Answers WITH (NOLOCK) where Tran_Question_Id=@Question_Id and Training_Apr_ID = @training_Id)
			 
			 declare cur cursor
			 for 
				select Emp_Id from #Table1
			 open cur
				fetch next from cur into @col2
				while @@FETCH_STATUS = 0
					Begin
						 update #Table1
						 set Question_Option =a.Answer
						 from  (select Answer from  T0150_HRMS_TRAINING_Answers WITH (NOLOCK) where Tran_Question_Id=@Question_Id and Training_Apr_ID=@training_Id and Emp_Id=@col2)a
						 where Emp_id = @col2
						fetch next from cur into @col2
					End				
			 close cur
			deallocate cur
		End		
		Select * from #Table1
		where Question_Option<>''
END

