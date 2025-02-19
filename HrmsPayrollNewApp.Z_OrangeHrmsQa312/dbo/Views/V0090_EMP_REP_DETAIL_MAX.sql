


 


CREATE VIEW [dbo].[V0090_EMP_REP_DETAIL_MAX]
AS
--SELECT     MAX(Effect_Date) AS EFFECT_DATE, Emp_ID
--FROM         dbo.T0090_EMP_REPORTING_DETAIL
--WHERE     (Effect_Date <= GETDATE())
--GROUP BY Emp_ID

SELECT I.EFFECT_DATE, I.Emp_ID,I.Row_ID FROM T0090_EMP_REPORTING_DETAIL I WITH (NOLOCK)
	Inner JOIN
	 (
		SELECT MAX(RD.Row_ID) as RowID,RD.Emp_ID 
		FROM T0090_EMP_REPORTING_DETAIL RD WITH (NOLOCK)
			Inner JOIN 
				(
					SELECT MAX(Effect_Date) as EffDt ,Emp_ID  
					FROM dbo.T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
					WHERE     (Effect_Date <= GETDATE()) --and Emp_ID = 821
					GROUP BY Emp_ID
				) as Qry ON Qry.EffDt = RD.Effect_Date AND Qry.Emp_ID = RD.Emp_ID
		GROUP BY RD.Emp_ID 
	) as Qry_1 ON I.Row_ID = Qry_1.RowID AND I.Emp_ID = Qry_1.Emp_ID


