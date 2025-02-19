

-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
-- SP_HRMS_Get_Questions 9,8
CREATE PROCEDURE [dbo].[SP_HRMS_Get_Questions]
	@Cmp_Id			Numeric(18,0),
	@Training_Id	varchar(18),
	@Type			int = 0	
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	
	if (@Type = 0 OR @Type = 3)
		begin
			Select Training_Que_ID,Question,Training_Id,Cmp_Id,Questionniare_Type,Question_Type,
			case when Question_Type = 1 then 'Title' when Question_Type = 2 then 'Text' when Question_Type=3 then 'Paragraph Text' when Question_Type = 4 then 'Multiple Choice' when Question_Type=5 then 'CheckBoxList' when Question_Type = 6 then 'DropdownList' when Question_Type = 7 then 'Multiple Choice Grid' else 'Paragraph Text' end  QuestionType,
				Sorting_No,Question_Option,Answer,Marks,ISNULL(Question_Row_Type,0)Question_Row_Type
			From T0150_HRMS_TRAINING_Questionnaire WITH (NOLOCK)
			Where Cmp_Id = @Cmp_Id And @Training_Id in (select Data from dbo.Split(Training_Id, '#'))
			--like '%'+ @Training_Id +'%'
					and Questionniare_Type = @Type ---0 --and Training_Id = @Training_Id
			order by Sorting_No asc
		End
	Else
		begin
			Select f.Training_Que_ID,f.tran_id,Question,f.Training_Id,g.Cmp_Id,Questionniare_Type,Question_Type,
			case when Question_Type = 1 then 'Title' when Question_Type = 2 then 'Text' when Question_Type=3 then 'Paragraph Text' when Question_Type = 4 then 'Multiple Choice' when Question_Type=5 then 'CheckBoxList' when Question_Type = 6 then 'DropdownList' when Question_Type = 7 then 'Multiple Choice Grid' else 'Paragraph Text' end  QuestionType,
				Sorting_No,Question_Option,Answer as actualAnswer,f.Marks as actualMarks,ISNULL(Question_Row_Type,0)Question_Row_Type
			From T0150_HRMS_TRAINING_Questionnaire g WITH (NOLOCK) inner join 
			T0152_Hrms_Training_Quest_Final f WITH (NOLOCK) on f.Training_Que_ID = g.Training_Que_ID 
			Where g.Cmp_Id = @Cmp_Id And f.Training_Apr_Id =@Training_Id
					and Questionniare_Type = 1
			order by Sorting_No asc
		End
END


