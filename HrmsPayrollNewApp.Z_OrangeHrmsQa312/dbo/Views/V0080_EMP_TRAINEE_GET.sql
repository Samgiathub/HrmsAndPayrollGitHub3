
CREATE  VIEW [dbo].[V0080_EMP_TRAINEE_GET]
AS
SELECT   CASE WHEN ISNULL(e.Training_Month,0) > 0 
		 THEN CASE WHEN E.Is_Trainee_Month_Days=0 THEN ISNULL(emp_probation.New_Probation_EndDate, DATEADD(dd, - 1, DATEADD(mm, E.Training_Month, e.Date_Of_Join))) 
		      ELSE ISNULL(emp_probation.New_Probation_EndDate, DATEADD(dd, - 1, DATEADD(DAY, E.Training_Month, e.Date_Of_Join))) END
		 ELSE 
			 CASE WHEN QRY.Is_Trainee_Month_Days=0 THEN ISNULL(emp_probation.New_Probation_EndDate, DATEADD(dd, - 1, DATEADD(mm, qry.Training_Month, e.Date_Of_Join)))
				 ELSE ISNULL(emp_probation.New_Probation_EndDate, DATEADD(dd, - 1, DATEADD(DAY, qry.Training_Month, e.Date_Of_Join))) END 			
         END AS probation_date,         
          e.Alpha_Emp_Code,e.Emp_Full_Name, e.Date_Of_Join,          
          CASE WHEN ISNULL(e.Training_Month,0) > 0 THEN e.Training_Month ELSE QRY.Training_Month END AS Training_Month, 
          dbo.T0030_BRANCH_MASTER.Branch_Name, dbo.T0040_DEPARTMENT_MASTER.Dept_Name, TM.Type_Name,
          dbo.T0040_DESIGNATION_MASTER.Desig_Name, i.Emp_ID, i.Cmp_ID, i.Branch_ID, i.Cat_ID, i.Grd_ID, i.Dept_ID, i.Desig_Id, i.Type_ID, e.Emp_Left, 
          e.Is_On_Probation, emp_probation.New_Probation_EndDate, ISNULL(emp_probation.Old_Probation_Period + emp_probation.Extend_Period, qry.Training_Month) 
          AS New_Prob_period,e.Work_Email,'TRAINEE' AS Flag , Qry.Probation , e.Emp_First_Name,emp_probation.Emp_Type_Id,Qry.Trainee_Review,
		'' AS Training_ID,Qry.Is_Probation_Month_Days,
		emp_probation.Approval_Period_Type,
		CASE WHEN ISNULL(e.Training_Month,0) > 0 THEN e.Is_Trainee_Month_Days else Qry.Is_Trainee_Month_Days END as Is_Trainee_Month_Days,'' as Attach_Docs ,emp_probation.Confirmation_date                    
FROM    dbo.T0080_EMP_MASTER AS e WITH (NOLOCK)  INNER JOIN
		dbo.T0095_INCREMENT AS i  WITH (NOLOCK) ON e.Increment_ID = i.Increment_ID INNER JOIN
			( SELECT G.Training_Month, G.Branch_Id , G.Probation,G.Trainee_Review,G.Is_Probation_Month_Days,G.Is_Trainee_Month_Days FROM T0040_General_Setting G WITH (NOLOCK)  INNER JOIN
                      (SELECT     MAX(For_Date) AS for_date, Branch_ID
                        FROM          dbo.T0040_GENERAL_SETTING AS gs WITH (NOLOCK) 
                        GROUP BY Branch_ID ) AS qry1 ON qry1.Branch_ID = g.Branch_ID AND qry1.For_Date=G.For_Date
             ) AS Qry ON Qry.Branch_ID = i.Branch_ID LEFT OUTER JOIN
		dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON i.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID LEFT OUTER JOIN
		dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK)  ON i.Dept_ID = dbo.T0040_DEPARTMENT_MASTER.Dept_Id LEFT OUTER JOIN
		dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK)  ON i.Desig_Id = dbo.T0040_DESIGNATION_MASTER.Desig_ID LEFT OUTER JOIN
		dbo.T0040_TYPE_MASTER TM  WITH (NOLOCK) ON i.Type_ID = TM.Type_ID LEFT OUTER JOIN	
		  ( SELECT	Probation_Evaluation_ID, Emp_ID, Cmp_ID, Probation_Status, Evaluation_Date, Extend_Period, Old_Probation_Period, New_Probation_EndDate, 
				Major_Strength, Major_Weakness, Appraiser_Remarks, Appraisal_Reviewer_Remarks, Supervisor_ID,Emp_Type_Id,Training_ID,Approval_Period_Type,Confirmation_date
			FROM dbo.T0095_EMP_PROBATION_MASTER WITH (NOLOCK)  WHERE  Flag = 'TRAINEE'  AND  
				( Probation_Evaluation_ID IN ( SELECT MAX(Probation_Evaluation_ID) AS Expr1 FROM  dbo.T0095_EMP_PROBATION_MASTER AS T0095_EMP_PROBATION_MASTER_1 WITH (NOLOCK) 
											  WHERE T0095_EMP_PROBATION_MASTER_1.Flag = 'TRAINEE' GROUP BY Emp_ID ))
		  ) AS emp_probation ON emp_probation.Emp_ID = e.Emp_ID
WHERE     ((e.Is_On_Training = 1)OR (emp_probation.Approval_Period_Type='Confirm')) AND e.Emp_Left='N'





















