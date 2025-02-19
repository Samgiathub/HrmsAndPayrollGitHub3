


CREATE VIEW [dbo].[V0090_Common_Request_Detail]
AS
SELECT     T0010_COMPANY_MASTER_1.Domain_Name, dbo.T0090_Common_Request_Detail.request_id, dbo.T0090_Common_Request_Detail.cmp_id, 
                      dbo.T0090_Common_Request_Detail.request_type, dbo.T0090_Common_Request_Detail.request_date, dbo.T0090_Common_Request_Detail.request_detail, 
                      dbo.T0090_Common_Request_Detail.status, dbo.T0090_Common_Request_Detail.Login_id, dbo.T0090_Common_Request_Detail.Feedback_detail, 
                      dbo.T0090_Common_Request_Detail.emp_Login_id, dbo.T0010_COMPANY_MASTER.Domain_Name AS domain_name1, 
                      CASE WHEN status = 0 THEN 'Pending' WHEN status = 1 THEN 'Done' WHEN status = 2 THEN 'Cancel' WHEN status = 3 THEN 'Pending' WHEN status = 4 THEN 'Done'
                       ELSE 'Cancel' END AS request_status, T0011_LOGIN_1.Login_Name AS Login_Name1, dbo.T0080_EMP_MASTER.Emp_First_Name AS Emp_First_Name1, 
                      CAST(dbo.T0080_EMP_MASTER.Alpha_Emp_Code AS varchar(50)) + ' - ' + dbo.T0080_EMP_MASTER.Emp_Full_Name AS emp_name1, 
                      dbo.T0011_LOGIN.Login_Name, T0080_EMP_MASTER_1.Emp_First_Name, CAST(T0080_EMP_MASTER_1.Alpha_Emp_Code AS varchar(50)) 
                      + ' - ' + T0080_EMP_MASTER_1.Emp_Full_Name AS emp_name, dbo.T0080_EMP_MASTER.Emp_Left
FROM         dbo.T0010_COMPANY_MASTER WITH (NOLOCK) RIGHT OUTER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  RIGHT OUTER JOIN
                      dbo.T0011_LOGIN AS T0011_LOGIN_1 WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Emp_ID = T0011_LOGIN_1.Emp_ID ON 
                      dbo.T0010_COMPANY_MASTER.Cmp_Id = T0011_LOGIN_1.Cmp_ID RIGHT OUTER JOIN
                      dbo.T0010_COMPANY_MASTER AS T0010_COMPANY_MASTER_1 WITH (NOLOCK)  RIGHT OUTER JOIN
                      dbo.T0090_Common_Request_Detail  WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS T0080_EMP_MASTER_1 WITH (NOLOCK)  RIGHT OUTER JOIN
                      dbo.T0011_LOGIN WITH (NOLOCK)  ON T0080_EMP_MASTER_1.Emp_ID = dbo.T0011_LOGIN.Emp_ID ON 
                      dbo.T0090_Common_Request_Detail.Login_id = dbo.T0011_LOGIN.Login_ID ON T0010_COMPANY_MASTER_1.Cmp_Id = dbo.T0011_LOGIN.Cmp_ID ON 
                      T0011_LOGIN_1.Login_ID = dbo.T0090_Common_Request_Detail.emp_Login_id


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[53] 4[8] 2[20] 3) )"
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
         Begin Table = "T0010_COMPANY_MASTER"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 279
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 245
               Right = 263
            End
            DisplayFlags = 280
            TopColumn = 40
         End
         Begin Table = "T0011_LOGIN_1"
            Begin Extent = 
               Top = 246
               Left = 38
               Bottom = 365
               Right = 216
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0010_COMPANY_MASTER_1"
            Begin Extent = 
               Top = 366
               Left = 38
               Bottom = 485
               Right = 279
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0090_Common_Request_Detail"
            Begin Extent = 
               Top = 126
               Left = 301
               Bottom = 245
               Right = 468
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0080_EMP_MASTER_1"
            Begin Extent = 
               Top = 486
               Left = 38
               Bottom = 605
               Right = 263
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0011_LOGIN"
            Begin Extent = 
               Top = 246
               Left = 254
               Bottom = 365', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_Common_Request_Detail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'
               Right = 432
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
      Begin ColumnWidths = 20
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_Common_Request_Detail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_Common_Request_Detail';

