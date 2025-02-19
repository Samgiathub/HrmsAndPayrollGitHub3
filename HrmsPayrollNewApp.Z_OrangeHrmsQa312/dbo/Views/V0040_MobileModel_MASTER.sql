



CREATE VIEW [dbo].[V0040_MobileModel_MASTER]
AS

	--SELECT  Mobile_Cat_ID,Mobile_Cat_Name,case when cast(Effective_Date as date) = '1900-01-01' then NULL else Effective_Date END as Effective_Date 
	--,Cmp_ID,Sale_Active,Stock_Active,Is_Active, ParentCategory_ID 
	--from   T0040_MOBILE_CATEGORY WITH(NOLOCK)

	SELECT  m.Mobile_Cat_ID
			,CASE WHEN t.Mobile_Cat_Name is null THEN m.Mobile_Cat_Name ELSE t.Mobile_Cat_Name END AS [Mobile_Company_Name]
			,m.Mobile_Cat_Name
			,CASE WHEN cast(Effective_Date as date) = '1900-01-01' THEN NULL ELSE Effective_Date END AS Effective_Date 
			,Cmp_ID,Sale_Active,Stock_Active,Is_Active, m.ParentCategory_ID 
	FROM T0040_MOBILE_CATEGORY M WITH(NOLOCK) 
		 LEFT JOIN (SELECT Mobile_Cat_ID,Mobile_Cat_Name,ParentCategory_ID 
					FROM T0040_MOBILE_CATEGORY where ParentCategory_ID = 0) t 
					ON m.ParentCategory_ID=t.Mobile_Cat_ID 
					

