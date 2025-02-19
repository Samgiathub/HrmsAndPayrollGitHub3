

CREATE VIEW [dbo].[V0050_Retaintion_Rate_Master]
AS
SELECT  D.RRateDetail_ID,R.Effective_date,GRD.Grd_ID,GRD.Grd_Name,GRD.Grd_Description,A.AD_NAME,A.AD_ID,D.Mode
,D.From_Limit,D.To_Limit,D.Amount,R.Cmp_ID
FROM         dbo.T0050_Retaintion_Rate_Master AS R WITH (NOLOCK) INNER JOIN
             dbo.T0051_Retaintion_Rate_Details AS D WITH (NOLOCK)  ON R.RRate_Id = d.RRate_ID
             INNER JOIN(
				Select MAX(Effective_date) as Effective_date,RRate_Id
				From T0050_Retaintion_Rate_Master WITH (NOLOCK)  Where Effective_date <= GETDATE()
				GROUP BY RRate_Id
             ) as Qry ON Qry.Effective_date = R.Effective_date AND Qry.RRate_Id = R.RRate_Id 
			 INNER Join T0050_AD_MASTER  A on R.AD_ID= A.AD_ID and A.CMP_ID = R.Cmp_ID
			 INNER Join T0040_GRADE_MASTER GRD on GRD.Grd_ID = R.Grd_ID and grd.Cmp_ID = R.Cmp_ID

