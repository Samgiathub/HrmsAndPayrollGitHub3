
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_SurveyQuestBank]
	   @SurveyQuestBank_Id			numeric(18,0) Output
      ,@Cmp_Id						numeric(18,0)
      ,@Survey_Question				nvarchar(500)  --Changes by Deepali 17Jun2022
      ,@Survey_Type					varchar(50)
      ,@Question_Option				nvarchar(800) ----Changes by Deepali 17Jun2022
	  ,@Answer						NVARCHAR(500) --Changes by Deepali 17Jun2022
	  ,@Marks						float
      ,@tran_type					varchar(1)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If Upper(@tran_type) ='I'
		begin
			if Not exists (select 1 from T0040_SurveyQuestBank WITH (NOLOCK) where cmp_id=@Cmp_Id and Survey_Question=@Survey_Question and Survey_Type=@Survey_Type)
				begin
					select @SurveyQuestBank_Id = isnull(max(SurveyQuestBank_Id),0) + 1 from T0040_SurveyQuestBank WITH (NOLOCK)
					Insert Into T0040_SurveyQuestBank
					(
						 SurveyQuestBank_Id
						,Cmp_Id
						,Survey_Question
						,Survey_Type
						,Question_Option
						,Answer
						,Marks
					)
					Values
					(
						 @SurveyQuestBank_Id
						,@Cmp_Id
						,@Survey_Question
						,@Survey_Type
						,@Question_Option
						,@Answer
						,@Marks
					)
				End
		End
	Else if Upper(@tran_type) ='D'
		begin
				Delete from  T0040_SurveyQuestBank where SurveyQuestBank_Id = @SurveyQuestBank_Id
		End
END
