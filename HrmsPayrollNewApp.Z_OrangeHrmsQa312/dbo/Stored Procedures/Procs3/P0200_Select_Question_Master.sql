




-- =============================================
-- Author:		Sneha
-- ALTER date: 27-feb-2012
-- Description:	<Description,,>
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0200_Select_Question_Master]
	@Cmp_Id numeric(18,0),
	@str varchar(max),
	@question_id numeric(18,0)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	

	If @Cmp_Id<>0
		Begin
			If @question_id = 0
				Begin
					If @str = ''
						Begin
							Select question_id,Question,Description,Cmp_Id,Is_Active,CASE WHEN T0200_Question_Master.Is_Active=1 THEN 'awards_link'	WHEN T0200_Question_Master.Is_Active=0 THEN 'awards_link clsinactive'
							ELSE 'awards_link clsinactive' END  as Status_Color From T0200_Question_Master WITH (NOLOCK) Where Cmp_Id = @Cmp_Id
						End
					Else
						Begin
							Select question_id,Question,Description,Cmp_Id,Is_Active,CASE WHEN T0200_Question_Master.Is_Active=1 THEN 'awards_link'	WHEN T0200_Question_Master.Is_Active=0 THEN 'awards_link clsinactive'
							ELSE 'awards_link clsinactive' END  as Status_Color
							From T0200_Question_Master WITH (NOLOCK) Where Cmp_Id = @Cmp_Id and Question like '%' + @str + '%' 
						End
				End
			Else
				Begin
					Select question_id,Question,Description,Cmp_Id,Is_Active,CASE WHEN T0200_Question_Master.Is_Active=1 THEN 'awards_link'	WHEN T0200_Question_Master.Is_Active=0 THEN 'awards_link clsinactive'
							ELSE 'awards_link clsinactive' END  as Status_Color From T0200_Question_Master WITH (NOLOCK) Where Cmp_Id = @Cmp_Id and Question_Id = @question_id and Question like '%' + @str + '%'
				End
		End
END




