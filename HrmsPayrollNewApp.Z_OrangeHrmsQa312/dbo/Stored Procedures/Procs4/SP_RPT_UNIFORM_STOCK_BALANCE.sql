
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_UNIFORM_STOCK_BALANCE]
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Constraint	varchar(MAX) = ''
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	SELECT UST.Stock_ID, UST.Cmp_ID, UM.Uni_Name, UM.Uni_ID, UST.For_Date, UST.Stock_Opening, UST.Stock_Credit,
		   UST.Stock_Debit, UST.Stock_Balance,UST.Stock_Posting,co.Cmp_Name,co.Cmp_Address
	FROM  dbo.T0140_Uniform_Stock_Transaction AS UST WITH (NOLOCK) INNER JOIN
           dbo.T0040_Uniform_Master AS UM WITH (NOLOCK) ON UM.Uni_ID = UST.Uni_ID inner join
           Dbo.T0010_COMPANY_MASTER co WITH (NOLOCK) on co.Cmp_Id=UST.Cmp_ID 
    where UST.For_Date >= @From_Date and UST.For_Date <= @To_Date
    ORDER BY UST.Stock_ID
        
		
	RETURN















