




CREATE VIEW [dbo].[V0050_Uniform_Master_Detail]
AS
--SELECT     UMD.Tran_ID, UM.Uni_ID, UM.Uni_Name, UMD.Uni_Effective_Date, UMD.Uni_Rate, UMD.Uni_Deduct_Installment, UMD.Uni_Refund_Installment
--FROM         dbo.T0040_Uniform_Master AS UM INNER JOIN
--                      dbo.T0050_Uniform_Master_Detail AS UMD ON UM.Uni_ID = UMD.Uni_ID
SELECT  UMD.Cmp_ID, UMD.Tran_ID, UM.Uni_ID, UM.Uni_Name, UMD.Uni_Effective_Date, UMD.Uni_Rate, UMD.Uni_Deduct_Installment, UMD.Uni_Refund_Installment
FROM         dbo.T0040_Uniform_Master AS UM WITH (NOLOCK) INNER JOIN
             dbo.T0050_Uniform_Master_Detail AS UMD WITH (NOLOCK)  ON UM.Uni_ID = UMD.Uni_ID
             INNER JOIN(
				Select MAX(Uni_Effective_Date) as Uni_Effective_Date,Uni_ID
				From T0050_Uniform_Master_Detail WITH (NOLOCK)  Where Uni_Effective_Date <= GETDATE()
				GROUP BY Uni_ID
             ) as Qry ON Qry.Uni_Effective_Date = UMD.Uni_Effective_Date AND Qry.Uni_ID = UMD.Uni_ID



