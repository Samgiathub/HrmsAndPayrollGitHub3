


CREATE VIEW [dbo].[V0152_Hrms_Training_Quest_Final]
AS
SELECT     f.Tran_Id, ISNULL(f.Marks, Q.Marks) AS Marks, Q.Question, Q.Questionniare_Type, Q.QuestionType, Q.Sorting_No, Q.Answer, Q.Question_Option, Q.Training_name, 
                      Q.Training_Id, Q.Question_Type, Q.Cmp_Id, Q.Training_Que_ID, f.Training_Apr_Id
FROM         dbo.V0150_HRMS_TRAINING_Questionnaire AS Q WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0152_Hrms_Training_Quest_Final AS f WITH (NOLOCK) ON f.Training_Que_ID = Q.Training_Que_ID
WHERE     (Q.Questionniare_Type = 1)

