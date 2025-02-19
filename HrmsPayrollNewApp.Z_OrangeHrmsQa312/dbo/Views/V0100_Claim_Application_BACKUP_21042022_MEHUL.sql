













--ALTER view [dbo].[V0100_Claim_Application]
--AS
--SELECT     dbo.T0100_CLAIM_APPLICATION.Claim_App_ID, dbo.T0100_CLAIM_APPLICATION.Cmp_ID, dbo.T0100_CLAIM_APPLICATION.Claim_ID, 
--                      dbo.T0100_CLAIM_APPLICATION.Claim_App_Date, dbo.T0100_CLAIM_APPLICATION.Claim_App_Code, 
--                      dbo.T0100_CLAIM_APPLICATION.Claim_App_Amount, dbo.T0100_CLAIM_APPLICATION.Claim_App_Description, 
--                      dbo.T0100_CLAIM_APPLICATION.Claim_App_Doc, dbo.T0100_CLAIM_APPLICATION.Claim_App_Status, dbo.T0040_CLAIM_MASTER.Claim_Name, 
--                      ISNULL(dbo.T0100_CLAIM_APPLICATION.Emp_ID, 0) AS Emp_ID, dbo.T0080_EMP_MASTER.Emp_Full_Name, 
--                      dbo.T0040_CLAIM_MASTER.Claim_Max_Limit, dbo.T0080_EMP_MASTER.Emp_First_Name, dbo.T0080_EMP_MASTER.Mobile_No, 
--                      dbo.T0080_EMP_MASTER.Work_Email, dbo.T0080_EMP_MASTER.Other_Email, ISNULL(dbo.T0095_INCREMENT.Branch_ID, 0) AS Branch_ID, 
--                      dbo.T0080_EMP_MASTER.Emp_code, dbo.T0080_EMP_MASTER.Emp_Superior, dbo.T0090_EMP_REPORTING_DETAIL.R_Emp_ID
--FROM         dbo.T0100_CLAIM_APPLICATION LEFT OUTER JOIN
--                      dbo.T0040_CLAIM_MASTER ON dbo.T0100_CLAIM_APPLICATION.Claim_ID = dbo.T0040_CLAIM_MASTER.Claim_ID LEFT OUTER JOIN
--                      dbo.T0080_EMP_MASTER ON dbo.T0100_CLAIM_APPLICATION.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN
--                      dbo.T0095_INCREMENT ON dbo.T0080_EMP_MASTER.Increment_ID = dbo.T0095_INCREMENT.Increment_ID LEFT OUTER JOIN
--                      dbo.T0090_EMP_REPORTING_DETAIL ON dbo.T0080_EMP_MASTER.Emp_ID = dbo.T0090_EMP_REPORTING_DETAIL.Emp_ID AND 
--                      dbo.T0080_EMP_MASTER.Emp_ID = dbo.T0090_EMP_REPORTING_DETAIL.Emp_ID



--GO

CREATE VIEW [dbo].[V0100_Claim_Application_BACKUP_21042022_MEHUL]
AS
SELECT   DISTINCT   dbo.T0100_CLAIM_APPLICATION.Claim_App_ID, dbo.T0100_CLAIM_APPLICATION.Cmp_ID, dbo.T0100_CLAIM_APPLICATION.Claim_ID, 
                      dbo.T0100_CLAIM_APPLICATION.Claim_App_Date, dbo.T0100_CLAIM_APPLICATION.Claim_App_Code, 
                      dbo.T0100_CLAIM_APPLICATION.Claim_App_Amount, dbo.T0100_CLAIM_APPLICATION.Claim_App_Description, 
                      dbo.T0100_CLAIM_APPLICATION.Claim_App_Doc, dbo.T0100_CLAIM_APPLICATION.Claim_App_Status, dbo.T0040_CLAIM_MASTER.Claim_Name, 
                      ISNULL(dbo.T0100_CLAIM_APPLICATION.Emp_ID, 0) AS Emp_ID, dbo.T0080_EMP_MASTER.Emp_Full_Name, 
                      dbo.T0040_CLAIM_MASTER.Claim_Max_Limit, dbo.T0080_EMP_MASTER.Emp_First_Name, dbo.T0080_EMP_MASTER.Mobile_No, 
                      dbo.T0080_EMP_MASTER.Work_Email, dbo.T0080_EMP_MASTER.Other_Email, ISNULL(dbo.T0095_INCREMENT.Branch_ID, 0) AS Branch_ID, 
                      dbo.T0080_EMP_MASTER.Emp_code, dbo.T0080_EMP_MASTER.Emp_Superior,0 AS R_EMP_ID, -- dbo.T0090_EMP_REPORTING_DETAIL.R_Emp_ID,
                      SEMP.Emp_Full_Name as Supervisor,dbo.T0030_BRANCH_MASTER.Branch_Name,dbo.T0040_DESIGNATION_MASTER.Desig_Name,
                      dbo.T0080_EMP_MASTER.Alpha_Emp_Code,ISNULL(CAPR.Claim_Apr_ID,0) as Claim_approval_id,dbo.T0040_CLAIM_MASTER.Desig_Wise_Limit,
                      dbo.T0040_DESIGNATION_MASTER.Desig_ID,
                      dbo.T0100_CLAIM_APPLICATION.Submit_Flag,ISNULL(dbo.T0095_INCREMENT.Grd_ID, 0) AS Grd_ID,isnull(dbo.T0040_CLAIM_MASTER.Claim_Limit_Type,0) as Claim_Limit_Type, -- GRADE ID ADDED BY RAJPUT ON 07032018
					  dbo.T0080_EMP_MASTER.Date_Of_Join,isnull(Dept_Name,'') as Dept_Name,
					  dbo.T0040_GRADE_MASTER.Grd_Name as Grade_Name,
					  isnull(Terms_isAccepted,0) as Terms_isAccepted,
					  CASE WHEN Submit_Flag = 1 THEN isnull(Claim_TermsCondition,Claim_Terms_Condition) else isnull(Claim_TermsCondition,'') END as Claim_TermsCondition
FROM         dbo.T0100_CLAIM_APPLICATION WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0040_CLAIM_MASTER  WITH (NOLOCK) ON dbo.T0100_CLAIM_APPLICATION.Claim_ID = dbo.T0040_CLAIM_MASTER.Claim_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER  WITH (NOLOCK) ON dbo.T0100_CLAIM_APPLICATION.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN
                      dbo.T0030_BRANCH_MASTER  WITH (NOLOCK) ON dbo.T0080_EMP_MASTER.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID left join
                      dbo.T0040_DESIGNATION_MASTER  WITH (NOLOCK) ON dbo.T0080_EMP_MASTER.Desig_Id = dbo.T0040_DESIGNATION_MASTER.Desig_ID LEFT OUTER JOIN
					  dbo.T0040_DEPARTMENT_MASTER  WITH (NOLOCK) ON dbo.T0080_EMP_MASTER.Dept_Id = dbo.T0040_DEPARTMENT_MASTER.Dept_Id LEFT OUTER JOIN					
                      dbo.T0095_INCREMENT  WITH (NOLOCK) ON dbo.T0080_EMP_MASTER.Increment_ID = dbo.T0095_INCREMENT.Increment_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER SEMP  WITH (NOLOCK) on dbo.T0100_CLAIM_APPLICATION.S_Emp_ID=SEMP.Emp_ID left outer join 
                      T0120_CLAIM_APPROVAL as CAPR  WITH (NOLOCK) ON dbo.T0100_CLAIM_APPLICATION.Claim_App_ID = CAPR.Claim_App_ID left outer join
                      dbo.T0090_EMP_REPORTING_DETAIL  WITH (NOLOCK) ON dbo.T0080_EMP_MASTER.Emp_ID = dbo.T0090_EMP_REPORTING_DETAIL.Emp_ID AND 
                      dbo.T0080_EMP_MASTER.Emp_ID = dbo.T0090_EMP_REPORTING_DETAIL.Emp_ID left outer join
					  dbo.T0040_GRADE_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Grd_ID = dbo.T0040_GRADE_MASTER.Grd_ID
					  




