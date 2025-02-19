



---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0100_NWES_DETAIL_GET] 
@Cmp_ID as Numeric,
@For_Date as datetime
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Select News_Title,News_Description from t0040_news_letter_master WITH (NOLOCK) where cmp_id =  @Cmp_ID And  @For_Date >= Start_Date And @For_Date <= End_Date And Is_Visible = 1
	
	RETURN




