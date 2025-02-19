





CREATE VIEW [dbo].[V0060_HRMS_EmployeeReward]
AS
SELECT     dbo.T0060_HRMS_EmployeeReward.EmpReward_Id, dbo.T0060_HRMS_EmployeeReward.Cmp_Id, dbo.T0060_HRMS_EmployeeReward.From_Date, 
                      dbo.T0060_HRMS_EmployeeReward.To_Date, dbo.T0060_HRMS_EmployeeReward.Employee_Id, dbo.T0060_HRMS_EmployeeReward.Type, 
                      dbo.T0060_HRMS_EmployeeReward.EmpReward_Rating, dbo.T0060_HRMS_EmployeeReward.Awards_Id, dbo.T0040_HRMS_AwardMaster.Award_Name, 
                      RewardValues_Id, comments, dbo.T0060_HRMS_EmployeeReward.Reward_Attachment,
                      CASE WHEN T0060_HRMS_EmployeeReward.RewardValues_Id IS NOT NULL THEN
                          (SELECT     R.RewardValues_Name + ','
                            FROM          T0040_Hrms_RewardValues R WITH (NOLOCK)
                            WHERE      R.RewardValues_Id IN
                                                       (SELECT     cast(data AS numeric(18, 0))
                                                         FROM          dbo.Split(ISNULL(dbo.T0060_HRMS_EmployeeReward.RewardValues_Id, '0'), '#')
                                                         WHERE      data <> '') FOR XML path('')) 
                      ELSE 'ALL'
                      END AS RewardValues, 
                      CASE WHEN T0060_HRMS_EmployeeReward.Employee_Id IS NOT NULL 
                      THEN
                          (SELECT     (('#img src="../App_File/EMPIMAGES/' +  Case when  isnull(E.Image_Name,'') = '' then case when E.Gender = 'M' then 'Emp_default.png' else 'Emp_Default_Female.png' END else E.Image_Name END + '" width=25px height=25px style="border-radius:10px" "$') + ' ' + E.Alpha_Emp_Code + '-' + E.Emp_Full_Name) + ','
                            FROM          T0080_EMP_MASTER E WITH (NOLOCK)
                            WHERE      E.Emp_ID IN
                                                       (SELECT     cast(data AS numeric(18, 0))
                                                         FROM          dbo.Split(ISNULL(dbo.T0060_HRMS_EmployeeReward.Employee_Id, '0'), '#')
                                                         WHERE      data <> '') FOR XML path('')) 
                     ELSE 'ALL' END AS Employee
					 --CASE WHEN T0060_HRMS_EmployeeReward.Employee_Id IS NOT NULL 
      --                THEN
      --                    (SELECT  ('#img src="../App_File/EMPIMAGES/ ' +  Case when  isnull(E.Image_Name,'') = '' then case when E.Gender = 'M' then 'Emp_default.png' else 'Emp_Default_Female.png' END else E.Image_Name END +'"$') + ',' 
      --                      FROM          T0080_EMP_MASTER E WITH (NOLOCK)
      --                      WHERE      E.Emp_ID IN
      --                                                 (SELECT     cast(data AS numeric(18, 0))
      --                                                   FROM          dbo.Split(ISNULL(dbo.T0060_HRMS_EmployeeReward.Employee_Id, '0'), '#')
      --                                                   WHERE      data <> '') FOR XML path('')) 
      --               ELSE 'ALL' END AS Emp_Img
FROM         dbo.T0060_HRMS_EmployeeReward WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0040_HRMS_AwardMaster WITH (NOLOCK) ON dbo.T0060_HRMS_EmployeeReward.Awards_Id = dbo.T0040_HRMS_AwardMaster.Awards_Id



GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[33] 4[17] 2[25] 3) )"
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
      Begin ColumnWidths = 14
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0060_HRMS_EmployeeReward';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0060_HRMS_EmployeeReward';

