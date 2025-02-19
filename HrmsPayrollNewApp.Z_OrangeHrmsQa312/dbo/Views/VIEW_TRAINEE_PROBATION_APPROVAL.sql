

CREATE VIEW [dbo].[VIEW_TRAINEE_PROBATION_APPROVAL]
AS

SELECT *
FROM 
(
	SELECT  Probation_Evaluation_ID, EP.Emp_ID AS Emp_ID, EP.Cmp_ID AS Cmp_ID, Probation_Status, Evaluation_Date, Extend_Period, 
			Old_Probation_Period, Old_Probation_EndDate, New_Probation_EndDate, Major_Strength, 
			Major_Weakness, Appraiser_Remarks, Appraisal_Reviewer_Remarks, Supervisor_ID, Flag,EP.Training_ID
			,EM.Alpha_Emp_Code,EM.Emp_Full_Name,Em.Emp_First_Name,EM.Date_OF_Join,em.EMP_LEFT, EP.Old_Probation_EndDate AS probation_date ,
			EM.Is_On_Training,EM.is_on_probation,0 as Completed_Month,isnull(EP.Review_Type,'Final')Review_Type,
			case when ep.Supervisor_ID=0 then 'Admin' else ES.Alpha_Emp_Code + '-' + ES.Emp_Full_Name end AS Review_By,EP.Approval_Period_Type,
			TM.[Type_Name],EP.Attach_Docs,
			( SELECT Increment_ID FROM 
				( SELECT MAX(Increment_ID) AS Increment_ID , Emp_ID FROM T0095_Increment WITH (NOLOCK) 
				  WHERE Increment_Effective_date <= EP.New_Probation_EndDate AND Emp_ID = EP.Emp_id
				  GROUP BY Emp_ID
				) AS tbl
			) AS Max_Increment_ID,ep.Confirmation_date
	FROM    dbo.T0095_EMP_PROBATION_MASTER AS EP WITH (NOLOCK) INNER JOIN
            dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON EP.Emp_ID = EM.Emp_ID LEFT JOIN
            dbo.T0080_EMP_MASTER AS ES WITH (NOLOCK) ON EP.Supervisor_ID = ES.Emp_ID LEFT JOIN
            T0040_TYPE_MASTER as TM WITH (NOLOCK) on EP.Emp_Type_Id=TM.[Type_ID]
) AS tbl1 INNER JOIN
( SELECT I.Emp_Id AS Emp_id1, Increment_Effective_Date,ISNULL(i.Dept_ID,0) as Dept_ID, i.Grd_ID, i.Branch_ID, BM.Branch_Name,i.SalDate_id, D.Dept_Name,DM.Desig_Name,Qry_G.Probation,
		i.Segment_ID, i.Vertical_ID, i.SubVertical_ID, i.subBranch_ID,i.Desig_Id, ISNULL(i.Cat_ID, 0) AS Cat_ID, ISNULL(i.type_Id, 0) AS Type_ID,I.Increment_ID AS Max_Increment_ID_1,
		Qry_G.Is_Probation_Month_Days
  FROM T0095_INCREMENT AS I WITH (NOLOCK) INNER JOIN
		dbo.T0030_BRANCH_MASTER AS BM WITH (NOLOCK) ON i.Branch_ID = BM.Branch_ID LEFT OUTER JOIN
		dbo.T0040_DEPARTMENT_MASTER AS D WITH (NOLOCK) ON i.Dept_ID = D.Dept_Id	INNER JOIN
		dbo.T0040_DESIGNATION_MASTER AS DM WITH (NOLOCK) ON I.Desig_Id = DM.Desig_ID INNER JOIN
		  ( Select Probation, G.Branch_Id,G.Is_Probation_Month_Days From T0040_General_Setting G WITH (NOLOCK) INNER JOIN
			  ( SELECT     MAX(For_Date) AS for_date, Branch_ID FROM dbo.T0040_GENERAL_SETTING WITH (NOLOCK) GROUP BY Branch_ID
			   ) AS GS ON GS.Branch_ID = G.Branch_ID and GS.For_Date=G.For_Date
		  ) As Qry_G on Qry_G.Branch_ID = i.Branch_ID 
) AS Qry1 ON Qry1.Emp_id1 = tbl1.Emp_ID AND Qry1.Max_Increment_ID_1 = tbl1.Max_Increment_ID 




