
create View [dbo].[V0050_Scheme_Detail_backup30112021]
As 
SELECT     Scheme_Id, Leave, LEFT
                          ((SELECT     Leave_Name + ', '
                              FROM         T0040_LEAVE_MASTER LM WITH (NOLOCK) 
                              WHERE     Cmp_ID = SD.Cmp_Id AND Leave_ID IN
                                                        (SELECT     Cast(data AS Numeric(18, 0))
                                                          FROM          dbo.Split(SD.Leave, '#')) FOR xml path('')), Len
                          ((SELECT     Leave_Name + ', '
                              FROM         T0040_LEAVE_MASTER LM WITH (NOLOCK) 
                              WHERE     Cmp_ID = SD.Cmp_Id AND Leave_ID IN
                                                        (SELECT     Cast(data AS Numeric(18, 0))
                                                          FROM          dbo.Split(SD.Leave, '#')) FOR xml path(''))) - 1) AS Leave_Name, /*Ankit 01052014--*/ LEFT
                          ((SELECT     Loan_Name + ', '
                              FROM         T0040_LOAN_MASTER LM WITH (NOLOCK) 
                              WHERE     Cmp_ID = SD.Cmp_Id AND Loan_ID IN
                                                        (SELECT     Cast(data AS Numeric(18, 0))
                                                          FROM          dbo.Split(SD.Leave, '#')) FOR xml path('')), Len
                          ((SELECT     Loan_Name + ', '
                              FROM         T0040_LOAN_MASTER LM WITH (NOLOCK) 
                              WHERE     Cmp_ID = SD.Cmp_Id AND Loan_ID IN
                                                        (SELECT     Cast(data AS Numeric(18, 0))
                                                          FROM          dbo.Split(SD.Leave, '#')) FOR xml path(''))) - 1) AS Loan_Name,LEFT

						((SELECT     Branch_Name + ', '
                              FROM         T0030_Branch_Master LM WITH (NOLOCK) 
                              WHERE     Cmp_ID = SD.Cmp_Id AND Branch_ID IN
                                                        (SELECT     Cast(data AS Numeric(18, 0))
                                                          FROM          dbo.Split(SD.Leave, '#')) FOR xml path('')), Len
                          ((SELECT     Branch_Name + ', '
                              FROM         T0030_Branch_Master LM WITH (NOLOCK) 
                              WHERE     Cmp_ID = SD.Cmp_Id AND Branch_ID IN
                                                        (SELECT     Cast(data AS Numeric(18, 0))
                                                          FROM          dbo.Split(SD.Leave, '#')) FOR xml path(''))) - 1) AS Branch_Name,
                                                                                                                    
                          (SELECT     Scheme_Name
                                                                        FROM         dbo.T0040_Scheme_Master WITH (NOLOCK) 
                                                                        WHERE     (Scheme_Id = SD.Scheme_Id)) AS Scheme_Name,
                          (SELECT     Scheme_Type
                            FROM          dbo.T0040_Scheme_Master AS T0040_Scheme_Master_1 WITH (NOLOCK) 
                            WHERE      (Scheme_Id = SD.Scheme_Id)) AS Scheme_Type,
                          (SELECT     TOP 1 *
                            FROM          (SELECT     Isnull(Alpha_Emp_Code, '') + ' - ' + ISNULL(Emp_Full_Name, '') AS Expr1
                                                    FROM          dbo.T0080_EMP_MASTER WITH (NOLOCK) 
                                                    WHERE      (Emp_ID =
                                                                               (SELECT     App_Emp_ID
                                                                                 FROM          dbo.T0050_Scheme_Detail WITH (NOLOCK) 
                                                                                 WHERE      (Scheme_Id = SD.Scheme_Id) AND (Leave = SD.Leave) AND (Rpt_Level = 1)))
                                                    UNION
                                                    SELECT     CASE WHEN Is_RM = 1 THEN 'Reporting Manager' WHEN Is_Hod = 1 THEN 'Head of Department' WHEN Is_HR = 1 THEN 'HR' WHEN Is_PRM = 1 THEN 'Probation Manager' END
                                                                           AS Expr1
                                                    FROM         dbo.T0050_Scheme_Detail WITH (NOLOCK) 
                                                    WHERE     (Scheme_Id = SD.Scheme_Id) AND (Leave = SD.Leave) AND (Rpt_Level = 1) AND (Is_RM = 1 OR
                                                                          IS_HOD = 1 OR
                                                                          IS_HR = 1 OR
                                                                          Is_PRM = 1)) AS TBL1) AS Rpt_Mgr_1,
                          (SELECT     TOP 1 *
               FROM          (SELECT     Isnull(Alpha_Emp_Code, '') + ' - ' + ISNULL(Emp_Full_Name, '') AS Expr1
                                                    FROM          dbo.T0080_EMP_MASTER AS T0080_EMP_MASTER_3 WITH (NOLOCK) 
                                                    WHERE      (Emp_ID =
                                                                               (SELECT     App_Emp_ID
                                                                                 FROM          dbo.T0050_Scheme_Detail AS T0050_Scheme_Detail_3 WITH (NOLOCK) 
                                                                                 WHERE      (Scheme_Id = SD.Scheme_Id) AND (Leave = SD.Leave) AND (Rpt_Level = 2)))
                                                    UNION
                                                    SELECT     CASE WHEN Is_BM = 1 THEN 'Branch Manager' WHEN Is_Hod = 1 THEN 'Head of Department' WHEN Is_HR = 1 THEN 'HR' WHEN Is_PRM = 1 THEN 'Probation Manager' WHEN
                                                                           Is_RMToRM = 1 THEN 'Reporting To Reporting Manager' END AS Expr1
                                                    FROM dbo.T0050_Scheme_Detail WITH (NOLOCK) 
                                                    WHERE     (Scheme_Id = SD.Scheme_Id) AND (Leave = SD.Leave) AND (Rpt_Level = 2) AND (Is_BM = 1 OR
                                                                          Is_HOD = 1 OR
                                                                          IS_HR = 1 OR
                                                                          IS_PRM = 1 OR
                                                                          Is_RMToRM = 1)) AS TBL2) AS Rpt_Mgr_2,
																				(SELECT     TOP 1 *     FROM         (SELECT     Isnull(Alpha_Emp_Code, '') + ' - ' + ISNULL(Emp_Full_Name, '') AS Expr1
																							FROM          dbo.T0080_EMP_MASTER AS T0080_EMP_MASTER_2  WITH (NOLOCK)                                                                                                                                                                              
																							WHERE      (Emp_ID = (SELECT     App_Emp_ID  
																												  FROM   dbo.T0050_Scheme_Detail AS T0050_Scheme_Detail_2 WITH (NOLOCK) 
																							                      WHERE      (Scheme_Id = SD.Scheme_Id) AND (Leave = SD.Leave) AND (Rpt_Level = 3)))
																							                       
																							                  UNION
																							                        
																							                      SELECT     CASE WHEN Is_BM = 1 THEN 'Branch Manager'
																							                                      WHEN Is_Hod = 1 THEN 'Head of Department'
																							                                      WHEN Is_HR = 1 THEN 'HR' 
																							                                      WHEN Is_PRM = 1 THEN 'Probation Manager' 
																							                                 END AS Expr1
																							                      FROM  dbo.T0050_Scheme_Detail  WITH (NOLOCK) 
																							                      WHERE     (Scheme_Id = SD.Scheme_Id) AND (Leave = SD.Leave) AND (Rpt_Level = 3) 
																																AND (Is_BM = 1 OR Is_HOD = 1 OR IS_HR = 1 OR Is_PRM = 1))
																															 AS TBL3) 
																												AS Rpt_Mgr_3,(SELECT TOP 1 *  
																															  FROM (SELECT Isnull(Alpha_Emp_Code, '') + ' - ' + ISNULL(Emp_Full_Name, '') AS Expr1
																																    FROM dbo.T0080_EMP_MASTER AS T0080_EMP_MASTER_3 WITH (NOLOCK)  
																																    WHERE (Emp_ID = (SELECT  App_Emp_ID 
																																					 FROM  dbo.T0050_Scheme_Detail AS T0050_Scheme_Detail_3 WITH (NOLOCK) 
																																					 WHERE   (Scheme_Id = SD.Scheme_Id) AND (Leave = SD.Leave) AND (Rpt_Level = 4)))
																																					 
																																					 UNION
																																					 
																																					 SELECT     CASE WHEN Is_Hod = 1 THEN 'Head of Department'
																																					                 WHEN Is_HR = 1 THEN 'HR' 
																																					                 WHEN Is_PRM = 1 THEN 'Probation Manager' 
																																					            END AS Expr1 
																																					 FROM dbo.T0050_Scheme_Detail  WITH (NOLOCK) 
																																					 WHERE     (Scheme_Id = SD.Scheme_Id) AND (Leave = SD.Leave) AND (Rpt_Level = 4)
																																					       AND (Is_HOD = 1 OR IS_HR = 1 OR IS_PRM = 1))
																																					 AS TBL2)
																																		 AS Rpt_Mgr_4,(SELECT TOP 1 * 
																																					   FROM  (SELECT     Isnull(Alpha_Emp_Code, '') + ' - ' + ISNULL(Emp_Full_Name, '') AS Expr1
																																					          FROM          dbo.T0080_EMP_MASTER AS T0080_EMP_MASTER_3 WITH (NOLOCK) 
																																					          WHERE   (Emp_ID = (SELECT App_Emp_ID 
																																					                             FROM   dbo.T0050_Scheme_Detail AS T0050_Scheme_Detail_3 WITH (NOLOCK) 
																																					                             WHERE      (Scheme_Id = SD.Scheme_Id) AND (Leave = SD.Leave) AND (Rpt_Level = 5)))
																																					                             
																																					                             UNION
																																					                             
																																					                             SELECT     CASE WHEN Is_Hod = 1 THEN 'Head of Department' 
																																																 WHEN Is_HR = 1 THEN 'HR' 
																																																 WHEN Is_PRM = 1 THEN 'Probation Manager' 
																																													        END AS Expr1
																																											     FROM dbo.T0050_Scheme_Detail WITH (NOLOCK) 
																																											     WHERE     (Scheme_Id = SD.Scheme_Id) AND (Leave = SD.Leave) AND (Rpt_Level = 5) 
																																											           AND (Is_HOD = 1 OR IS_HR = 1 OR Is_PRM = 1)) 
																																											      AS TBL2)
																																											  AS Rpt_Mgr_5,(SELECT TOP 1 *  
																															  FROM (SELECT Isnull(Alpha_Emp_Code, '') + ' - ' + ISNULL(Emp_Full_Name, '') AS Expr1
																																    FROM dbo.T0080_EMP_MASTER AS T0080_EMP_MASTER_3  WITH (NOLOCK) 
																																    WHERE (Emp_ID = (SELECT  App_Emp_ID 
																																					 FROM  dbo.T0050_Scheme_Detail AS T0050_Scheme_Detail_3 WITH (NOLOCK) 
																																					 WHERE   (Scheme_Id = SD.Scheme_Id) AND (Leave = SD.Leave) AND (Rpt_Level = 6)))
																																					 
																																					 UNION
																																					 
																																					 SELECT     CASE WHEN Is_Hod = 1 THEN 'Head of Department'
																																					                 WHEN Is_HR = 1 THEN 'HR' 
																																					                 WHEN Is_PRM = 1 THEN 'Probation Manager' 
																																					            END AS Expr1 
																																					 FROM dbo.T0050_Scheme_Detail  WITH (NOLOCK) 
																																					 WHERE     (Scheme_Id = SD.Scheme_Id) AND (Leave = SD.Leave) AND (Rpt_Level = 6)
																																					       AND (Is_HOD = 1 OR IS_HR = 1 OR IS_PRM = 1))
																																					 AS TBL2)
																																		 AS Rpt_Mgr_6,(SELECT TOP 1 *  
																															  FROM (SELECT Isnull(Alpha_Emp_Code, '') + ' - ' + ISNULL(Emp_Full_Name, '') AS Expr1
																																    FROM dbo.T0080_EMP_MASTER AS T0080_EMP_MASTER_3  WITH (NOLOCK) 
																																    WHERE (Emp_ID = (SELECT  App_Emp_ID 
																																					 FROM  dbo.T0050_Scheme_Detail AS T0050_Scheme_Detail_3 WITH (NOLOCK) 
																																					 WHERE   (Scheme_Id = SD.Scheme_Id) AND (Leave = SD.Leave) AND (Rpt_Level = 7)))
																																					 
																																					 UNION
																																					 
																																					 SELECT     CASE WHEN Is_Hod = 1 THEN 'Head of Department'
																																					                 WHEN Is_HR = 1 THEN 'HR' 
																																					                 WHEN Is_PRM = 1 THEN 'Probation Manager' 
																																					            END AS Expr1 
																																					 FROM dbo.T0050_Scheme_Detail  WITH (NOLOCK) 
																																					 WHERE     (Scheme_Id = SD.Scheme_Id) AND (Leave = SD.Leave) AND (Rpt_Level = 7)
																																					       AND (Is_HOD = 1 OR IS_HR = 1 OR IS_PRM = 1))
																																					 AS TBL2)
																																		 AS Rpt_Mgr_7,(SELECT TOP 1 *  
																															  FROM (SELECT Isnull(Alpha_Emp_Code, '') + ' - ' + ISNULL(Emp_Full_Name, '') AS Expr1
																																    FROM dbo.T0080_EMP_MASTER AS T0080_EMP_MASTER_3  WITH (NOLOCK) 
																																    WHERE (Emp_ID = (SELECT  App_Emp_ID 
																																					 FROM  dbo.T0050_Scheme_Detail AS T0050_Scheme_Detail_3 WITH (NOLOCK) 
																																					 WHERE   (Scheme_Id = SD.Scheme_Id) AND (Leave = SD.Leave) AND (Rpt_Level = 8)))
																																					 
																																					 UNION
																																					 
																																					 SELECT     CASE WHEN Is_Hod = 1 THEN 'Head of Department'
																																					                 WHEN Is_HR = 1 THEN 'HR' 
																																					                 WHEN Is_PRM = 1 THEN 'Probation Manager' 
																																					            END AS Expr1 
																																					 FROM dbo.T0050_Scheme_Detail  WITH (NOLOCK) 
																																					 WHERE     (Scheme_Id = SD.Scheme_Id) AND (Leave = SD.Leave) AND (Rpt_Level = 8)
																																					       AND (Is_HOD = 1 OR IS_HR = 1 OR IS_PRM = 1))
																																					 AS TBL2)
																																		 AS Rpt_Mgr_8, Cmp_id
																																											  FROM         dbo.T0050_Scheme_Detail AS SD WITH (NOLOCK) 
																																											  GROUP BY Leave, Scheme_Id, Cmp_id
																																											  


