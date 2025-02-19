


CREATE VIEW [dbo].[V0100_RC_Application]
AS
SELECT DISTINCT 
                      TOP (100) PERCENT dbo.T0100_RC_Application.Cmp_ID, dbo.T0100_RC_Application.RC_APP_ID, dbo.T0100_RC_Application.Emp_ID, 
                      dbo.T0100_RC_Application.APP_Date, 
                      CASE WHEN dbo.T0100_RC_Application.APP_Status = 0 THEN dbo.T0100_RC_Application.APP_Amount ELSE Apr_Amount END AS Tax_Free_Amount, 
                      CASE WHEN dbo.T0100_RC_Application.APP_Status = 0 THEN dbo.T0100_RC_Application.Taxable_Amount ELSE Taxable_Exemption_Amount END AS Tax_Amount, 
                      dbo.T0100_RC_Application.APP_Amount AS APP_Tax_Free_Amount, 
                      
                      dbo.T0100_RC_Application.Taxable_Amount AS APP_Tax_Amount, 
                      ISNULL(dbo.T0120_RC_Approval.Apr_Amount, 0) AS APR_Tax_Free_Amount, 
                      ISNULL(dbo.T0120_RC_Approval.Taxable_Exemption_Amount, 0) AS APR_Tax_Amount, 
                      
                      
                      dbo.T0100_RC_Application.APP_Amount, 
                      dbo.T0100_RC_Application.Taxable_Amount, 
                      
                      dbo.T0100_RC_Application.APP_Comments, 
                      dbo.T0100_RC_Application.APP_Status, dbo.T0100_RC_Application.Leave_From_Date, dbo.T0100_RC_Application.FY, dbo.T0100_RC_Application.Leave_To_Date, 
                      dbo.T0100_RC_Application.Days, dbo.T0100_RC_Application.Is_Manager_Record, dbo.T0100_RC_Application.RC_Apr_ID, dbo.T0080_EMP_MASTER.Emp_Superior, 
                      dbo.T0095_INCREMENT.Branch_ID, dbo.T0080_EMP_MASTER.Alpha_Emp_Code, dbo.T0080_EMP_MASTER.Emp_code, dbo.T0080_EMP_MASTER.Emp_Full_Name, 
                      dbo.T0080_EMP_MASTER.Emp_First_Name, CASE WHEN dbo.T0100_RC_Application.Tax_Exception = 1 THEN 'NO' ELSE 'YES' END AS Taxable, 
                      dbo.T0050_AD_MASTER.AD_NAME, 
                      CASE WHEN APP_Status = 0 THEN 'Pending' WHEN APP_Status = 1 THEN 'Approved' WHEN APP_Status = 2 THEN 'Rejected' END AS Status, 
                      case when Submit_Flag=0 then 'Submitted' when Submit_Flag=1 then 'Drafted' end AS Draft_status, 
                      dbo.T0100_RC_Application.S_emp_ID, dbo.T0040_DESIGNATION_MASTER.Desig_Name, dbo.T0010_COMPANY_MASTER.Cmp_Name, 
                      dbo.T0030_BRANCH_MASTER.Branch_Name, dbo.T0040_DEPARTMENT_MASTER.Dept_Name, dbo.T0050_AD_MASTER.AD_DEF_ID, 
                      dbo.T0100_RC_Application.RC_ID, dbo.T0080_EMP_MASTER.Date_Of_Join, dbo.T0080_EMP_MASTER.Mobile_No, dbo.T0030_CATEGORY_MASTER.Cat_Name,
                      T0120_RC_Approval.Apr_Date,
                      dbo.T0100_RC_Application.Submit_Flag,
                      dbo.T0095_INCREMENT.Vertical_ID,dbo.T0095_INCREMENT.SubVertical_ID,dbo.T0095_INCREMENT.Dept_ID  --Added By Jaina 14-09-2015
FROM         dbo.T0095_INCREMENT WITH (NOLOCK) RIGHT OUTER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Increment_ID = dbo.T0080_EMP_MASTER.Increment_ID INNER JOIN
                      dbo.T0100_RC_Application WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Emp_ID = dbo.T0100_RC_Application.Emp_ID INNER JOIN
                      dbo.T0050_AD_MASTER WITH (NOLOCK)  ON dbo.T0050_AD_MASTER.AD_ID = dbo.T0100_RC_Application.RC_ID LEFT OUTER JOIN
                      dbo.T0120_RC_Approval WITH (NOLOCK)  ON dbo.T0120_RC_Approval.RC_App_ID = dbo.T0100_RC_Application.RC_APP_ID INNER JOIN
                      dbo.T0010_COMPANY_MASTER WITH (NOLOCK)  ON dbo.T0050_AD_MASTER.CMP_ID = dbo.T0010_COMPANY_MASTER.Cmp_Id LEFT OUTER JOIN
                      dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Desig_Id = dbo.T0040_DESIGNATION_MASTER.Desig_ID LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID LEFT OUTER JOIN
                      dbo.T0030_CATEGORY_MASTER WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Cat_ID = dbo.T0030_CATEGORY_MASTER.Cat_ID AND 
                      dbo.T0010_COMPANY_MASTER.Cmp_Id = dbo.T0030_CATEGORY_MASTER.cmp_ID LEFT OUTER JOIN
                      dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK) ON dbo.T0095_INCREMENT.Dept_ID = dbo.T0040_DEPARTMENT_MASTER.Dept_Id



GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[29] 4[8] 2[24] 3) )"
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
         Begin Table = "T0095_INCREMENT"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 272
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 0
               Left = 880
               Bottom = 115
               Right = 1116
            End
            DisplayFlags = 280
            TopColumn = 122
         End
         Begin Table = "T0100_RC_Application"
            Begin Extent = 
               Top = 246
               Left = 38
               Bottom = 361
               Right = 216
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0050_AD_MASTER"
            Begin Extent = 
               Top = 366
               Left = 38
               Bottom = 481
               Right = 283
            End
            DisplayFlags = 280
            TopColumn = 11
         End
         Begin Table = "T0120_RC_Approval"
            Begin Extent = 
               Top = 246
               Left = 254
               Bottom = 361
               Right = 472
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0010_COMPANY_MASTER"
            Begin Extent = 
               Top = 486
               Left = 38
               Bottom = 601
               Right = 271
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_DESIGNATION_MASTER"
            Begin Extent = 
               Top = 22
               Left = 612
               Bottom = 13', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_RC_Application';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'7
               Right = 773
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0030_BRANCH_MASTER"
            Begin Extent = 
               Top = 606
               Left = 38
               Bottom = 721
               Right = 225
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0030_CATEGORY_MASTER"
            Begin Extent = 
               Top = 83
               Left = 1166
               Bottom = 202
               Right = 1331
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_DEPARTMENT_MASTER"
            Begin Extent = 
               Top = 88
               Left = 697
               Bottom = 203
               Right = 849
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
      Begin ColumnWidths = 40
         Width = 284
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_RC_Application';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_RC_Application';

