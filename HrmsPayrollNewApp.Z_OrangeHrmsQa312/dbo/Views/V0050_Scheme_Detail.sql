


CREATE  View [dbo].[V0050_Scheme_Detail]
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
						  ((SELECT     Travel_Type_Name + ', '
                              FROM         T0040_Travel_Type LM WITH (NOLOCK) 
                              WHERE     Cmp_ID = SD.Cmp_Id AND Travel_Type_Id IN
                                                        (SELECT     Cast(data AS Numeric(18, 0))
                                                          FROM          dbo.Split(SD.Leave, '#')) FOR xml path('')), Len
                          ((SELECT     Travel_Type_Name + ', '
                              FROM         T0040_Travel_Type LM WITH (NOLOCK) 
                              WHERE      Travel_Type_Id IN
                                                        (SELECT     Cast(data AS Numeric(18, 0))
                                                          FROM          dbo.Split(SD.Leave, '#')) FOR xml path(''))) - 1) AS Travel, /*Ankit 01052014--*/ LEFT	
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
                                                    SELECT     CASE WHEN Is_RM = 1 THEN 'Reporting Manager' WHEN Is_Hod = 1 THEN 'Head of Department' WHEN Is_HR = 1 THEN 'HR' 
													WHEN Is_PRM = 1 THEN 'Probation Manager' END
                                                                           AS Expr1
                                                    FROM         dbo.T0050_Scheme_Detail WITH (NOLOCK) 
                                                    WHERE     (Scheme_Id = SD.Scheme_Id) AND (Leave = SD.Leave) AND (Rpt_Level = 1) AND (Is_RM = 1 OR
                                                                          IS_HOD = 1 OR
                                                                          IS_HR = 1 OR
                                                                          Is_PRM = 1)
													UNION
                                                    SELECT   
                                                          DT.Dyn_Hierarchy_Type AS Expr1
                                                    FROM     dbo.T0050_Scheme_Detail Sdt WITH (NOLOCK) 
													inner join T0040_Dyn_Hierarchy_Type DT on  Sdt.Dyn_Hier_Id = Dt.Dyn_Hierarchy_Id
													 where isnull(sdt.Dyn_Hier_Id,0) <> 0 and Sdt.Scheme_Id = Sd.Scheme_Id
													 AND (Rpt_Level = 1) --AND (Is_RM = 1 OR IS_HOD = 1 OR IS_HR = 1 OR Is_PRM = 1)
													 ) AS TBL1) AS Rpt_Mgr_1,
                        (SELECT  TOP 1 * FROM  (SELECT     Isnull(Alpha_Emp_Code, '') + ' - ' + ISNULL(Emp_Full_Name, '') AS Expr1
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
                                                                          Is_RMToRM = 1)
													UNION
                                                    SELECT   
                                                          DT.Dyn_Hierarchy_Type AS Expr1
                                                    FROM     dbo.T0050_Scheme_Detail Sdt WITH (NOLOCK) 
													inner join T0040_Dyn_Hierarchy_Type DT on  Sdt.Dyn_Hier_Id = Dt.Dyn_Hierarchy_Id
													 where isnull(sdt.Dyn_Hier_Id,0) <> 0 and Sdt.Scheme_Id = Sd.Scheme_Id 
													 AND (Rpt_Level = 2) --AND (Is_RM = 1 OR IS_HOD = 1 OR IS_HR = 1 OR Is_PRM = 1)
													 ) AS TBL2) 
						AS Rpt_Mgr_2
						,(SELECT  TOP 1 *  FROM  (SELECT     Isnull(Alpha_Emp_Code, '') + ' - ' + ISNULL(Emp_Full_Name, '') AS Expr1
											FROM  dbo.T0080_EMP_MASTER AS T0080_EMP_MASTER_2  WITH (NOLOCK)                                                                                                                                                                              
											WHERE  (Emp_ID = (SELECT     App_Emp_ID  
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
																AND (Is_BM = 1 OR Is_HOD = 1 OR IS_HR = 1 OR Is_PRM = 1)
														UNION
														SELECT DT.Dyn_Hierarchy_Type AS Expr1
														FROM  dbo.T0050_Scheme_Detail Sdt WITH (NOLOCK) 
														inner join T0040_Dyn_Hierarchy_Type DT on  Sdt.Dyn_Hier_Id = Dt.Dyn_Hierarchy_Id
														where isnull(sdt.Dyn_Hier_Id,0) <> 0 and Sdt.Scheme_Id = Sd.Scheme_Id 
														AND (Rpt_Level = 3) --AND (Is_RM = 1 OR IS_HOD = 1 OR IS_HR = 1 OR Is_PRM = 1)
														) AS TBL3) 
						 AS Rpt_Mgr_3
						,(SELECT TOP 1 *  FROM (SELECT Isnull(Alpha_Emp_Code, '') + ' - ' + ISNULL(Emp_Full_Name, '') AS Expr1
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
												       AND (Is_HOD = 1 OR IS_HR = 1 OR IS_PRM = 1)
												 UNION
												 SELECT DT.Dyn_Hierarchy_Type AS Expr1
												 FROM  dbo.T0050_Scheme_Detail Sdt WITH (NOLOCK) 
												 inner join T0040_Dyn_Hierarchy_Type DT on  Sdt.Dyn_Hier_Id = Dt.Dyn_Hierarchy_Id
												 where isnull(sdt.Dyn_Hier_Id,0) <> 0 and Sdt.Scheme_Id = Sd.Scheme_Id 
												 AND (Rpt_Level = 4) --AND (Is_RM = 1 OR IS_HOD = 1 OR IS_HR = 1 OR Is_PRM = 1)
												 ) AS TBL2)
									AS Rpt_Mgr_4
						,(SELECT TOP 1 * 
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
													           AND (Is_HOD = 1 OR IS_HR = 1 OR Is_PRM = 1)
														 UNION
														 SELECT DT.Dyn_Hierarchy_Type AS Expr1
														 FROM  dbo.T0050_Scheme_Detail Sdt WITH (NOLOCK) 
														 inner join T0040_Dyn_Hierarchy_Type DT on  Sdt.Dyn_Hier_Id = Dt.Dyn_Hierarchy_Id
														 where isnull(sdt.Dyn_Hier_Id,0) <> 0 and Sdt.Scheme_Id = Sd.Scheme_Id 
														 AND (Rpt_Level = 5) --AND (Is_RM = 1 OR IS_HOD = 1 OR IS_HR = 1 OR Is_PRM = 1)
												) AS TBL2)
									AS Rpt_Mgr_5
						,(SELECT TOP 1 *  
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
													       AND (Is_HOD = 1 OR IS_HR = 1 OR IS_PRM = 1)
													 UNION
													 SELECT DT.Dyn_Hierarchy_Type AS Expr1
													 FROM  dbo.T0050_Scheme_Detail Sdt WITH (NOLOCK) 
													 inner join T0040_Dyn_Hierarchy_Type DT on  Sdt.Dyn_Hier_Id = Dt.Dyn_Hierarchy_Id
													 where isnull(sdt.Dyn_Hier_Id,0) <> 0 and Sdt.Scheme_Id = Sd.Scheme_Id 
													 AND (Rpt_Level = 6) --AND (Is_RM = 1 OR IS_HOD = 1 OR IS_HR = 1 OR Is_PRM = 1)
													 ) AS TBL2)
										 AS Rpt_Mgr_6
						,(SELECT TOP 1 *  
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
									 				       AND (Is_HOD = 1 OR IS_HR = 1 OR IS_PRM = 1)
													 UNION
													 SELECT DT.Dyn_Hierarchy_Type AS Expr1
													 FROM  dbo.T0050_Scheme_Detail Sdt WITH (NOLOCK) 
													 inner join T0040_Dyn_Hierarchy_Type DT on  Sdt.Dyn_Hier_Id = Dt.Dyn_Hierarchy_Id
													 where isnull(sdt.Dyn_Hier_Id,0) <> 0 and Sdt.Scheme_Id = Sd.Scheme_Id 
													 AND (Rpt_Level = 7) --AND (Is_RM = 1 OR IS_HOD = 1 OR IS_HR = 1 OR Is_PRM = 1)
													 ) AS TBL2)
									 	 AS Rpt_Mgr_7
						,(SELECT TOP 1 *  
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
												       AND (Is_HOD = 1 OR IS_HR = 1 OR IS_PRM = 1)
											     UNION
												 SELECT DT.Dyn_Hierarchy_Type AS Expr1
												 FROM  dbo.T0050_Scheme_Detail Sdt WITH (NOLOCK) 
												 inner join T0040_Dyn_Hierarchy_Type DT on  Sdt.Dyn_Hier_Id = Dt.Dyn_Hierarchy_Id
												 where isnull(sdt.Dyn_Hier_Id,0) <> 0 and Sdt.Scheme_Id = Sd.Scheme_Id 
												 AND (Rpt_Level = 8) --AND (Is_RM = 1 OR IS_HOD = 1 OR IS_HR = 1 OR Is_PRM = 1)
												 ) AS TBL2)
									 AS Rpt_Mgr_8
								, Cmp_id
								FROM dbo.T0050_Scheme_Detail AS SD WITH (NOLOCK) 
								GROUP BY Leave, Scheme_Id, Cmp_id
																																											  



GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[8] 4[5] 2[53] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = -576
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 13
         Width = 284
         Width = 1500
         Width = 1815
         Width = 2520
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 525
         Or = 525
         Or = 525
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0050_Scheme_Detail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0050_Scheme_Detail';

