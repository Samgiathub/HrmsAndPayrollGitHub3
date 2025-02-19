





CREATE  VIEW [dbo].[V0140_Uniform_Stock_Transaction]
AS
SELECT UST.Stock_ID,UST.Cmp_ID,UM.Uni_Name, UM.Uni_ID, UST.For_Date, UST.Stock_Opening, 
       UST.Stock_Credit, UST.Stock_Debit,UST.Stock_Balance,UST.Stock_Posting,
       UST.Fabric_Price
	   ,UST.Modify_Date
FROM   T0140_UNIFORM_STOCK_TRANSACTION AS UST  WITH (NOLOCK)
INNER JOIN T0040_UNIFORM_MASTER AS UM WITH (NOLOCK) ON UST.Uni_ID = UM.Uni_ID
WHERE UST.Stock_Credit <> 0 



