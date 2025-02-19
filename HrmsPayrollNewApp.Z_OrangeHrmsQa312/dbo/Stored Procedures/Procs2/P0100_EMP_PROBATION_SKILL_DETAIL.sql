


-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0100_EMP_PROBATION_SKILL_DETAIL]
	 @Prob_Skill_ID		NUMERIC(18,0)	OUTPUT
	,@Cmp_ID			NUMERIC(18,0)
	,@Emp_ID			NUMERIC(18,0)
	,@Skill_Rating		NUMERIC(18,0)
	,@Skill_ID			NUMERIC(18,0)
	,@Emp_Prob_ID		NUMERIC(18,0)
	,@Tran_Type			Char(1) 
	,@Final_Review		NUMERIC(18,0)  --Mukti(02122017) 0 for Quaterly,Six Monthly,1 for Final
	,@Review_Type		Varchar(15)	   --Mukti(02122017)Quaterly,Six Monthly
	,@Strength			varchar(5000)=''
	,@Other_Factors		varchar(5000)=''
	,@Remarks			varchar(5000)=''
	,@Supervisor_ID		INTEGER  --Mukti(17072019)
	,@Final_Approver	INTEGER = 0	--Mukti(17072019)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	DECLARE @Row_Id INT
	
	If UPPER(@Tran_Type) = 'I'
		Begin
			IF @Supervisor_ID <> 0
				BEGIN				
					SELECT @Emp_Prob_ID = ISNULL(MAX(Tran_Id),0) FROM T0115_EMP_PROBATION_MASTER_LEVEL WITH (NOLOCK) where Emp_id=@emp_id
					SELECT @Row_Id = ISNULL(MAX(Row_ID),0) + 1  FROM T0115_EMP_PROBATION_SKILL_DETAIL_LEVEL WITH (NOLOCK)
																
					INSERT INTO T0115_EMP_PROBATION_SKILL_DETAIL_LEVEL(Row_ID, Cmp_ID, Emp_ID, Skill_Rating, Skill_ID, Tran_ID,Final_Review,Review_Type,Strengths,Other_Factors,Remarks)
					VALUES (@Row_Id, @Cmp_ID, @Emp_ID, @Skill_Rating, @Skill_ID, @Emp_Prob_ID, @Final_Review, @Review_Type,@Strength,@Other_Factors,@Remarks)	
				END 
			
			
			IF @Final_Approver = 1
				BEGIN				
					SELECT @Prob_Skill_ID = ISNULL(MAX(Prob_Skill_ID),0) + 1 FROM T0100_EMP_PROBATION_SKILL_DETAIL WITH (NOLOCK)
					SELECT @Emp_Prob_ID = ISNULL(MAX(Probation_Evaluation_ID),0) FROM T0095_EMP_PROBATION_MASTER WITH (NOLOCK)
					
					INSERT INTO T0100_EMP_PROBATION_SKILL_DETAIL(Prob_Skill_ID, Cmp_ID, Emp_ID, Skill_Rating, Skill_ID, Emp_Prob_ID,Final_Review,Review_Type,Strengths,Other_Factors,Remarks)
					VALUES (@Prob_Skill_ID, @Cmp_ID, @Emp_ID, @Skill_Rating, @Skill_ID, @Emp_Prob_ID,@Final_Review,@Review_Type,@Strength,@Other_Factors,@Remarks)
				END
			END
		
END



