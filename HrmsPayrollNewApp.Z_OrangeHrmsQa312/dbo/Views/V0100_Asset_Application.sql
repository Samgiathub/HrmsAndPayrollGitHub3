    
CREATE VIEW [dbo].[V0100_Asset_Application]    
AS    
 SELECT     *, LEFT(Asset_Name1, len(Asset_Name1) - 1) AS Asset_Name    
 FROM (SELECT DISTINCT     
			dbo.T0100_Asset_Application.Application_date, dbo.T0100_Asset_Application.Application_code, T0080_EMP_MASTER.Alpha_Emp_Code AS Emp_code,     
			dbo.T0100_Asset_Application.Asset_Id, dbo.T0100_Asset_Application.Remarks, dbo.T0100_Asset_Application.Emp_ID,     
			T0080_EMP_MASTER.Emp_First_Name, T0100_Asset_Application.AssetM_Id, T0080_EMP_MASTER.Emp_Full_Name, T0030_BRANCH_MASTER.Branch_Name,     
			dbo.T0100_Asset_Application.cmp_id, T0100_Asset_Application.Branch_ID, mm.Branch_ID AS emp_branch,     
			dbo.T0011_LOGIN.Emp_ID AS Emp_ID1, t0040_department_master.Dept_Name, t0040_department_master.Dept_Id, mm.Vertical_ID,    
			mm.SubVertical_ID, mm.Dept_ID AS Department,     
			/*Added By Jaina 16-09-2015*/     
			CASE WHEN dbo.T0100_Asset_Application.application_status = 'A' THEN 'Approved'     
			WHEN dbo.T0100_Asset_Application.application_status = 'R' THEN 'Rejected'     
			ELSE 'Pending' END AS application_status,     
			CASE WHEN dbo.T0100_Asset_Application.application_Type = 1 THEN 'Return'     
			ELSE 'Allocation' END AS application_Type,    
			dbo.T0100_Asset_Application.Asset_Application_ID,     
			CASE WHEN dbo.T0100_Asset_Application.Asset_ID IS NOT NULL THEN    
			 (SELECT     bm1.Asset_Name + ', '    
			 FROM        T0040_ASSET_MASTER BM1 WITH (NOLOCK)    
			 WHERE     Asset_ID IN    
			                       (SELECT     cast(data AS numeric(18, 0))    
			                        FROM dbo.Split(isnull(dbo.T0100_Asset_Application.Asset_ID, '0'), '#')    
			 --Added By Tejas at 12/10/2023 for fetch only approved item not rejected item     
			 LEFT JOIN    
			 T0110_Asset_Application_Details A     
			 ON A.Asset_Id = Data     
			 where A.Status = 'A' AND dbo.T0100_Asset_Application.Asset_Application_Id = A.Asset_Application_Id    
			 --End By tejas  /////////////////////////////////////////////////////////////////////////////////////    
			   )     
			   FOR xml path('')  
			   )   
			ELSE 'ALL' END AS Asset_Name1,
			CASE WHEN dbo.T0100_Asset_Application.Asset_ID IS NOT NULL THEN    
			 (SELECT     bm1.Asset_Name + ', '    
			 FROM        T0040_ASSET_MASTER BM1 WITH (NOLOCK)    
			 WHERE     Asset_ID IN    
			                       (SELECT     cast(data AS numeric(18, 0))    
			                        FROM dbo.Split(isnull(dbo.T0100_Asset_Application.Asset_ID, '0'), '#')    
			 --Added By Tejas at 12/10/2023 for fetch only approved item not rejected item     
			 LEFT JOIN    
			 T0110_Asset_Application_Details A     
			 ON A.Asset_Id = Data     
			 where A.Status = 'R' AND dbo.T0100_Asset_Application.Asset_Application_Id = A.Asset_Application_Id    
			 --End By tejas  /////////////////////////////////////////////////////////////////////////////////////    
			   )     
			   FOR xml path('')  
			   )   
			ELSE 'ALL' END AS Asset_Name2
			FROM  dbo.T0100_Asset_Application WITH (NOLOCK)     
			LEFT OUTER JOIN dbo.T0040_ASSET_MASTER WITH (NOLOCK) ON dbo.T0100_Asset_Application.Cmp_Id = dbo.T0040_ASSET_MASTER.Cmp_ID     
			LEFT OUTER JOIN dbo.T0080_EMP_MASTER WITH (NOLOCK) ON dbo.T0100_Asset_Application.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID AND T0080_EMP_MASTER.Cmp_ID = dbo.T0100_Asset_Application.Cmp_ID    
			LEFT OUTER JOIN dbo.T0011_LOGIN WITH (NOLOCK) ON dbo.T0011_LOGIN.Cmp_Id = dbo.T0100_Asset_Application.Cmp_ID AND T0100_Asset_Application.LoginId = T0011_LOGIN.Login_ID    
			LEFT OUTER JOIN dbo.T0030_BRANCH_MASTER WITH (NOLOCK) ON dbo.T0100_Asset_Application.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID AND T0030_BRANCH_MASTER.Cmp_ID = dbo.T0100_Asset_Application.Cmp_ID     
			LEFT OUTER JOIN dbo.t0040_department_master WITH (NOLOCK) ON dbo.T0100_Asset_Application.Dept_ID = dbo.t0040_department_master.Dept_ID AND t0040_department_master.Cmp_ID = dbo.T0100_Asset_Application.Cmp_ID     
			LEFT OUTER JOIN    
			          (SELECT     I.emp_id, I.branch_id, i.Cmp_ID, I.Vertical_ID, I.SubVertical_ID, I.Dept_ID    
			             /*Added By Jaina 16-09-2015*/ FROM dbo.T0095_INCREMENT I WITH (NOLOCK) INNER JOIN    
			                               dbo.T0080_EMP_MASTER E WITH (NOLOCK) ON E.Emp_ID = I.Emp_ID    
			                     WHERE     I.INCREMENT_id IN    
			                                            (SELECT     MAX(INCREMENT_ID)    
			                                             FROM        dbo.T0095_INCREMENT WITH (NOLOCK)    
			                                              GROUP BY EMP_ID)    
			 ) mm ON T0080_EMP_MASTER.Emp_ID = mm.Emp_ID AND T0080_EMP_MASTER.Cmp_ID = mm.Cmp_ID  
			) src 
GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[6] 4[5] 2[66] 3) )"
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
         Top = 0
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
      Begin ColumnWidths = 22
         Width = 284
         Width = 4740
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
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
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_Asset_Application';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_Asset_Application';

