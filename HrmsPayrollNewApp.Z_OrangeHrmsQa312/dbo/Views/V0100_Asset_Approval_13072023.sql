











Create VIEW [dbo].[V0100_Asset_Approval_13072023]
AS
SELECT     *, LEFT(Asset_Name1, len(Asset_Name1) - 1) AS Asset_Name
FROM         (SELECT DISTINCT 
                                              AA.Asset_Approval_Date, AB.Application_status, aa.Asset_Application_ID AS Application_Code, aa.Asset_Application_ID, aa.Cmp_ID, aa.Asset_Approval_ID, 
                                              e.Emp_ID, aa.Branch_ID, mm.Branch_ID AS emp_branch, CASE WHEN aa.Status = 'A' THEN 'Approve' ELSE 'Reject' END AS [status], '' AS Allocation_date, 
                                              '' AS Return_date, e.Emp_First_Name, aa.applied_by, t0040_department_master.Dept_Id, mm.Dept_ID as emp_dept,AA.Branch_For_Dept,AA.Transfer_Branch_For_Dept,                                              
                                              CASE WHEN AD.Application_Type = 3 AND isnull(Transfer_Dept_Id, 0) > 0 THEN T3.Dept_Name + '-' + BDT.Branch_Name
                                              WHEN isnull(Transfer_Dept_Id, 0) = 0 AND isnull(Transfer_Emp_Id, 0) = 0 AND isnull(Transfer_Branch_Id, 0) = 0 THEN t0040_department_master.Dept_Name + '-' + BD.Branch_Name END AS [Dept_Name],
                                             
                                              CASE WHEN AD.Application_Type = 3 AND isnull(Transfer_Branch_Id, 0) > 0 THEN T2.Branch_Name 
                                              WHEN isnull(Transfer_Dept_Id, 0) = 0 AND isnull(Transfer_Emp_Id, 0) = 0 AND isnull(Transfer_Branch_Id, 0) = 0 THEN B.Branch_Name END AS [Branch_Name], 
                                              CASE WHEN AD.Application_Type = 3 AND isnull(Transfer_Emp_Id, 0) > 0 THEN T1.Emp_Full_Name 
                                              WHEN isnull(Transfer_Dept_Id, 0) = 0 AND isnull(Transfer_Emp_Id, 0) = 0 AND isnull(Transfer_Branch_Id, 0)= 0 THEN E.Emp_Full_Name END AS [Emp_Full_Name], 
                                              CASE WHEN AD.Application_Type = 3 AND isnull(Transfer_Emp_Id, 0) > 0 THEN T1.Alpha_Emp_Code 
                                              WHEN isnull(Transfer_Dept_Id, 0) = 0 AND isnull(Transfer_Emp_Id, 0) = 0 AND isnull(Transfer_Branch_Id, 0) = 0 THEN E.Alpha_Emp_Code END AS [Emp_code], 
                                              CASE WHEN AD.Application_Type = 0 THEN 'Allocation' WHEN AD.Application_Type = 1 THEN 'Return' WHEN AD.Application_Type = 2 THEN 'Sell' WHEN AD.Application_Type
                                               = 3 THEN 'Transfer' END AS [Application_Type1], 0 AS AssetM_ID, EE.Alpha_Emp_Code AS Applied_ByEmp_Code, 
                                              CASE WHEN EE.Alpha_Emp_Code IS NULL THEN 'Admin' ELSE (EE.Alpha_Emp_Code + '-' + EE.Emp_Full_Name) END AS Applied_By_Name, 
                                              mm.Vertical_ID, mm.SubVertical_ID, /*Added By Jaina 29-09-2015    */ AD.Transfer_Id,
                                                  (SELECT     Asset_Name + ','
                                                    FROM          T0040_ASSET_MASTER WITH (NOLOCK)
                                                    WHERE      Asset_ID IN
                                                                               (SELECT     Asset_ID
                                                                                 FROM          T0130_Asset_Approval_Det WITH (NOLOCK)
                                                                                 WHERE      Asset_Approval_ID = aa.Asset_Approval_ID) FOR xml path('')) AS Asset_Name1, AA.Transfer_Emp_Id, AA.Transfer_Branch_Id
                                              --,AD.Transfer_Id
                                              --,case 
                                              --when ISNULL(AA.Transfer_Branch_Id,0)>0 THEN T2.Branch_Name
                                             -- when
                                               ,CASE when ISNULL(AA.Emp_Id,0)>0 THEN 'Employee: <br/>'+ (e.Alpha_Emp_Code+'-'+e.Emp_Full_Name)  
                                               WHEN ISNULL(AA.Branch_ID,0)>0 THEN 'Branch: <br/>'+ B.Branch_Name
                                               WHEN ISNULL(AA.Dept_Id,0)>0 THEN 'Department: <br/>'+ t0040_department_master.Dept_Name + '-' + BD.Branch_Name end as Transfer_From,Transfer_Dept_Id
                       FROM          T0120_Asset_Approval AA WITH (NOLOCK) LEFT JOIN
                                              dbo.T0130_Asset_Approval_Det AD WITH (NOLOCK) ON AD.Asset_Approval_ID = AA.Asset_Approval_ID AND AD.Cmp_ID = AA.Cmp_ID LEFT JOIN
                                             -- dbo.T0130_Asset_Approval_Det ATD ON AA.Asset_Approval_ID = ATD.Transfer_Id AND ATD.Cmp_ID = AA.Cmp_ID LEFT OUTER JOIN
                                              dbo.T0100_Asset_Application AB WITH (NOLOCK) ON AA.Asset_Application_ID = AB.Asset_Application_ID AND AA.Cmp_ID = AB.Cmp_ID 
											 LEFT OUTER JOIN dbo.T0080_EMP_MASTER E WITH (NOLOCK) ON AA.Emp_ID = E.Emp_ID AND E.Cmp_ID = AA.Cmp_ID LEFT OUTER JOIN
                                              dbo.T0080_EMP_MASTER EE WITH (NOLOCK) ON AA.Applied_By = EE.Emp_ID AND EE.Cmp_ID = AA.Cmp_ID LEFT OUTER JOIN
                                              dbo.T0030_BRANCH_MASTER B WITH (NOLOCK) ON AA.Branch_ID = B.Branch_ID AND B.Cmp_ID = AA.Cmp_ID LEFT OUTER JOIN
                                              dbo.t0040_department_master WITH (NOLOCK) ON AA.Dept_ID = dbo.t0040_department_master.Dept_ID AND 
                                              t0040_department_master.Cmp_ID = AA.Cmp_ID LEFT OUTER JOIN
                                              dbo.T0080_EMP_MASTER T1 WITH (NOLOCK) ON AA.Transfer_Emp_Id = T1.Emp_ID AND T1.Cmp_ID = AA.Cmp_ID LEFT OUTER JOIN
                                              dbo.T0030_BRANCH_MASTER T2 WITH (NOLOCK) ON AA.Transfer_Branch_ID = T2.Branch_ID AND T2.Cmp_ID = AA.Cmp_ID LEFT OUTER JOIN
                                              dbo.t0040_department_master T3 WITH (NOLOCK) ON AA.Transfer_Dept_ID = T3.Dept_ID AND T3.Cmp_ID = AA.Cmp_ID LEFT OUTER JOIN
                                              dbo.T0030_BRANCH_MASTER BD WITH (NOLOCK) ON AA.Branch_For_Dept = BD.Branch_ID AND BD.Cmp_ID = AA.Cmp_ID LEFT OUTER JOIN
                                              dbo.T0030_BRANCH_MASTER BDT WITH (NOLOCK) ON AA.Transfer_Branch_For_Dept = BDT.Branch_ID AND BDT.Cmp_ID = AA.Cmp_ID LEFT OUTER JOIN
                                                  (SELECT     I.emp_id, I.branch_id, i.Cmp_ID, I.Vertical_ID, I.SubVertical_ID, I.Dept_ID
                                                    /*Change By Jaina 29-09-2015*/ FROM dbo.T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
                                                                           dbo.T0080_EMP_MASTER E WITH (NOLOCK) ON E.Emp_ID = I.Emp_ID
                                                    WHERE      I.INCREMENT_id IN
                                                                               (SELECT     MAX(INCREMENT_ID)
                                                                                 FROM          dbo.T0095_INCREMENT WITH (NOLOCK)
                                                                                 GROUP BY EMP_ID)) mm ON e.Emp_ID = mm.Emp_ID AND e.Cmp_ID = mm.Cmp_ID) src

