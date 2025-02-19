





CREATE VIEW [dbo].[V0020_PRIVILEGE_MASTER_DETAILS]
AS
SELECT     dbo.T0020_PRIVILEGE_MASTER.Privilege_ID, dbo.T0020_PRIVILEGE_MASTER.Cmp_Id, dbo.T0020_PRIVILEGE_MASTER.Privilege_Name, 
                      dbo.T0050_PRIVILEGE_DETAILS.Form_Id, dbo.T0050_PRIVILEGE_DETAILS.Is_View, dbo.T0050_PRIVILEGE_DETAILS.Is_Edit, 
                      dbo.T0050_PRIVILEGE_DETAILS.Is_Save, dbo.T0050_PRIVILEGE_DETAILS.Is_Delete, dbo.T0000_DEFAULT_FORM.Form_Name, 
                      dbo.T0000_DEFAULT_FORM.Under_Form_ID, dbo.T0000_DEFAULT_FORM.Sort_ID, dbo.T0000_DEFAULT_FORM.Form_Type
                      ,T0000_DEFAULT_FORM.Form_url,T0000_DEFAULT_FORM.form_image_url
                      , case when dbo.T0050_PRIVILEGE_DETAILS.Is_View = 1 then 1 when dbo.T0050_PRIVILEGE_DETAILS.Is_Edit= 1 then 1 when dbo.T0050_PRIVILEGE_DETAILS.Is_Save = 1 then 1 when dbo.T0050_PRIVILEGE_DETAILS.Is_Delete=1 then 1 else 0 end as Is_Active
                      ,T0000_DEFAULT_FORM.Is_Active_For_menu
                      ,T0000_DEFAULT_FORM.Alias
                      ,t0000_default_form.sort_id_check
                      ,t0000_default_form.module_name
                      ,t0000_default_form.Page_Flag
                      ,t0000_default_form.chinese_alias
FROM         dbo.T0050_PRIVILEGE_DETAILS WITH (NOLOCK) INNER JOIN
                      dbo.T0020_PRIVILEGE_MASTER  WITH (NOLOCK) ON dbo.T0050_PRIVILEGE_DETAILS.Privilage_ID = dbo.T0020_PRIVILEGE_MASTER.Privilege_ID INNER JOIN
                      dbo.T0000_DEFAULT_FORM WITH (NOLOCK)  ON dbo.T0050_PRIVILEGE_DETAILS.Form_Id = dbo.T0000_DEFAULT_FORM.Form_ID





GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
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
         Begin Table = "T0050_PRIVILEGE_DETAILS"
            Begin Extent = 
               Top = 6
               Left = 425
               Bottom = 121
               Right = 577
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "T0020_PRIVILEGE_MASTER"
            Begin Extent = 
               Top = 6
               Left = 233
               Bottom = 121
               Right = 387
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0000_DEFAULT_FORM"
            Begin Extent = 
               Top = 9
               Left = 638
               Bottom = 124
               Right = 795
            End
            DisplayFlags = 280
            TopColumn = 1
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0020_PRIVILEGE_MASTER_DETAILS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0020_PRIVILEGE_MASTER_DETAILS';

