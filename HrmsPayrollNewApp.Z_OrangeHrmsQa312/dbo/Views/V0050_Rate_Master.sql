


CREATE VIEW [dbo].[V0050_Rate_Master]
AS

SELECT  D.RateDetail_ID,E.Alpha_Emp_Code,E.Emp_Full_Name,R.Effective_date,p.Product_Name,SP.SubProduct_Name
,D.From_Limit,D.To_Limit,D.Rate,r.Cmp_ID,e.Emp_ID, p.Product_ID,SP.SubProduct_ID
FROM         dbo.T0050_Rate_Master AS R WITH (NOLOCK) INNER JOIN
             dbo.T0051_Rate_Details AS D WITH (NOLOCK)  ON R.Rate_Id = d.Rate_ID
             INNER JOIN(
				Select MAX(Effective_date) as Effective_date,Rate_Id
				From T0050_Rate_Master WITH (NOLOCK)  Where Effective_date <= GETDATE()
				GROUP BY Rate_Id
             ) as Qry ON Qry.Effective_date = R.Effective_date AND Qry.Rate_Id = R.Rate_Id
			 Left Join T0080_EMP_MASTER E on R.Emp_ID = E.Emp_ID
			 Left Join T0040_Product_Master P on R.Product_ID = p.Product_ID
			 Left Join T0040_SubProduct_Master SP on R.SubProduct_ID = SP.SubProduct_ID and Sp.Product_ID = p.Product_ID



