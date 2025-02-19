
-- Select * from V0040_SUBPRODUCT_MASTER
CREATE VIEW [dbo].[V0040_SUBPRODUCT_MASTER]    
AS    
SELECT	SP.SubProduct_ID,
		SP.Product_ID,
		SP.Cmp_ID,
		SP.Login_ID,
		SP.SubProduct_Name,
		U.Unit_Name,
		SP.System_Date,
		P.Product_Name,
		SP.unit
FROM	dbo.T0040_SUBPRODUCT_MASTER SP WITH (NOLOCK) 
		LEFT OUTER JOIN dbo.T0040_PRODUCT_MASTER P WITH (NOLOCK) ON SP.Product_ID = P.Product_ID
		Left Outer Join Dbo.T0040_Units_Master U with (NOlock) ON SP.Unit = U.Unit_ID

