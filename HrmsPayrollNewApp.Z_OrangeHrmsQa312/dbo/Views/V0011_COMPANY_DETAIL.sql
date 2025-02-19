





CREATE VIEW [dbo].[V0011_COMPANY_DETAIL]
AS

SELECT     Cmp.cmp_id,cmpdet.Tran_Id,ISNULL(cmpdet.Cmp_Name, Cmp.Cmp_Name) As Cmp_Name, ISNULL(cmpdet.Cmp_Address,Cmp.Cmp_Address) as Cmp_Address,
                      'admin' + cmp.Domain_Name AS Login_ID, cmpdet.Old_Cmp_Name,cmpdet.Old_Cmp_Address,IsNull(cmpdet.Effect_Date, Cmp.From_Date) as Effect_Date,
             ISNULL(cmpdet.Cmp_Header , cmp.Cmp_Header) AS Cmp_Header, ISNULL(cmpdet.Cmp_Footer , cmp.Cmp_Footer) AS Cmp_Footer
FROM         dbo.T0010_COMPANY_MASTER AS Cmp WITH (NOLOCK) 
		LEFT OUTER JOIN dbo.T0011_COMPANY_DETAIL AS cmpdet  WITH (NOLOCK) on Cmp.Cmp_Id=cmpdet.Cmp_Id




