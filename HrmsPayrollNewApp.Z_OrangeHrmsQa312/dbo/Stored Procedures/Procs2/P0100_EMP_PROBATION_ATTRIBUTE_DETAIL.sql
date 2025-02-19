



-- =============================================
-- Author:		<Author,,Ankit>
-- ALTER date: <ALTER Date,,21012016>
-- Description:	<Description,,>
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0100_EMP_PROBATION_ATTRIBUTE_DETAIL]
	 @Prob_Attr_ID		NUMERIC(18,0)	OUTPUT
	,@Cmp_ID			NUMERIC(18,0)
	,@Emp_ID			NUMERIC(18,0)
	,@Attr_Rating		NUMERIC(18,2)
	,@Attr_ID			NUMERIC(18,0)
	,@Emp_Prob_ID		NUMERIC(18,0)
	,@Tran_Type			Char(1) 
	,@Final_Review		NUMERIC(18,0)  --Mukti(02122017) 0 for Quaterly,Six Monthly,1 for Final
	,@Review_Type		Varchar(15)	   --Mukti(02122017)Quaterly,Six Monthly
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	If UPPER(@Tran_Type) = 'I'
		Begin
			Select @Prob_Attr_ID = ISNULL(MAX(Prob_Attr_ID),0) + 1 From T0100_EMP_PROBATION_ATTRIBUTE_DETAIL WITH (NOLOCK)
			Select @Emp_Prob_ID = ISNULL(MAX(Probation_Evaluation_ID),0)  From T0095_EMP_PROBATION_MASTER WITH (NOLOCK)
			
			Insert Into T0100_EMP_PROBATION_ATTRIBUTE_DETAIL(Prob_Attr_ID, Cmp_ID, Emp_ID, Attr_Rating, Attribute_ID, Emp_Prob_ID,Final_Review,Review_Type)
				VALUES (@Prob_Attr_ID, @Cmp_ID, @Emp_ID, @Attr_Rating, @Attr_ID, @Emp_Prob_ID,@Final_Review,@Review_Type)
		End
END



