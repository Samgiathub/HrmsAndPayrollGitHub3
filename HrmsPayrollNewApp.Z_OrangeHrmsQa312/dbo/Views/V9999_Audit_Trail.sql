



CREATE VIEW [dbo].[V9999_Audit_Trail]
AS
SELECT     TOP (100) PERCENT Audit_Trail_Id, Cmp_ID, Audit_Change_Type, Audit_Module_Name, Audit_Modulle_Description, Audit_Change_For, 
                      Audit_Change_By, Audit_Date, Audit_Ip, is_emp_id, Alpha_Emp_Code, Emp_Full_Name
FROM         (SELECT     AT.Audit_Trail_Id, AT.Cmp_ID, AT.Audit_Change_Type, AT.Audit_Module_Name, AT.Audit_Modulle_Description, AT.Audit_Change_For, 
                                              AT.Audit_Change_By, AT.Audit_Date, AT.Audit_Ip, AT.is_emp_id, EM.Alpha_Emp_Code, EM.Emp_Full_Name
                       FROM          dbo.T9999_Audit_Trail AS AT WITH (NOLOCK) INNER JOIN
                                              dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK)  ON EM.Emp_ID = AT.Audit_Change_For
                       WHERE      (AT.is_emp_id = 1)
                       UNION
                       SELECT     Audit_Trail_Id, Cmp_ID, Audit_Change_Type, Audit_Module_Name, Audit_Modulle_Description, Audit_Change_For, Audit_Change_By, 
                                             Audit_Date, Audit_Ip, is_emp_id, '' AS Alpha_Emp_Code, '' AS Emp_Full_Name
                       FROM         dbo.T9999_Audit_Trail AS AT WITH (NOLOCK) 
                       WHERE     (is_emp_id = 0)
                       UNION
                       SELECT     Audit_Trail_Id, Cmp_ID, Audit_Change_Type, Audit_Module_Name, Audit_Modulle_Description, Audit_Change_For, Audit_Change_By, 
                                             Audit_Date, Audit_Ip, is_emp_id, '' AS Alpha_Emp_Code, '' AS Emp_Full_Name
                       FROM         dbo.T9999_Audit_Trail AS AT WITH (NOLOCK) 
                       WHERE     (Audit_Change_For = 0) AND (is_emp_id = 1)) AS qry
ORDER BY Audit_Date DESC



GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[27] 4[13] 2[43] 3) )"
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
         Begin Table = "qry"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 245
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
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
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V9999_Audit_Trail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V9999_Audit_Trail';

