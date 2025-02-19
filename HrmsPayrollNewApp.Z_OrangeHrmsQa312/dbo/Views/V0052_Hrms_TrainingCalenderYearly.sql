


CREATE VIEW [dbo].[V0052_Hrms_TrainingCalenderYearly]
AS
	SELECT     c.Training_CalenderId, c.Cmp_Id, c.Calender_Year, c.Calender_Month, c.Training_Id, t.Training_name, DATENAME(month, DATEADD(month, c.Calender_Month, - 1)) 
						  AS month_name,
	CASE WHEN c.branch_id IS NOT NULL and c.branch_id <> '0' THEN (SELECT bm.Branch_Name + ','
	FROM          T0030_BRANCH_MASTER bm WITH (NOLOCK) WHERE      bm.Branch_ID IN
		   (SELECT     cast(data AS numeric(18, 0))
			 FROM          dbo.Split(ISNULL(c.branch_id, '0'), '#')
			 WHERE      data <> '') FOR XML path('')) ELSE 'ALL' END AS Branch_Name                    
	FROM         dbo.T0052_Hrms_TrainingCalenderYearly AS c WITH (NOLOCK)  INNER JOIN
						  dbo.T0040_Hrms_Training_master AS t WITH (NOLOCK)  ON t.Training_id = c.Training_Id


