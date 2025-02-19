





CREATE VIEW [dbo].[V0055_Interview_Process_Detail]
AS
SELECT     T0055_Interview_Process_Detail_1.Interview_Process_detail_ID, T0055_Interview_Process_Detail_1.Cmp_ID, T0055_Interview_Process_Detail_1.Rec_Post_ID, 
                      T0055_Interview_Process_Detail_1.Process_ID, T0055_Interview_Process_Detail_1.S_Emp_ID, dbo.T0040_HRMS_R_PROCESS_MASTER.Process_Name, 
                      T0055_Interview_Process_Detail_1.Dis_No, dbo.T0052_HRMS_Posted_Recruitment.Job_title, T0055_Interview_Process_Detail_1.S_Emp_Id2, 
                      T0055_Interview_Process_Detail_1.S_Emp_ID4, T0055_Interview_Process_Detail_1.To_Time, T0055_Interview_Process_Detail_1.From_Time, 
                      T0055_Interview_Process_Detail_1.To_Date, T0055_Interview_Process_Detail_1.From_Date, T0055_Interview_Process_Detail_1.S_Emp_Id3, 
                      dbo.T0052_HRMS_Posted_Recruitment.Rec_Post_Code, dbo.T0050_HRMS_Recruitment_Request.Branch_id, 
                      CAST(dbo.T0080_EMP_MASTER.Alpha_Emp_Code AS varchar(50)) + ' - ' + dbo.T0080_EMP_MASTER.Emp_Full_Name AS emp_full_name_new,    --Change By Jaina 12-10-2016 Repalce Emp_Code to Alpha_Emp_Code
                      CAST(T0080_EMP_MASTER_1.Alpha_Emp_Code AS varchar(50)) + ' - ' + T0080_EMP_MASTER_1.Emp_Full_Name AS member1,  --Change By Jaina 12-10-2016
                      CAST(T0080_EMP_MASTER_2.Alpha_Emp_Code AS varchar(50)) + ' - ' + T0080_EMP_MASTER_2.Emp_Full_Name AS member2,  --Change By Jaina 12-10-2016
                      CAST(T0080_EMP_MASTER_3.Alpha_Emp_Code AS varchar(50)) + ' - ' + T0080_EMP_MASTER_3.Emp_Full_Name AS member3,  --Change By Jaina 12-10-2016
                      dbo.T0080_EMP_MASTER.Emp_Full_Name
FROM         dbo.T0055_Interview_Process_Detail AS T0055_Interview_Process_Detail_1 WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON T0055_Interview_Process_Detail_1.S_Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS T0080_EMP_MASTER_1  WITH (NOLOCK)  ON T0055_Interview_Process_Detail_1.S_Emp_Id2 = T0080_EMP_MASTER_1.Emp_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS T0080_EMP_MASTER_2  WITH (NOLOCK)  ON T0055_Interview_Process_Detail_1.S_Emp_Id3 = T0080_EMP_MASTER_2.Emp_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS T0080_EMP_MASTER_3  WITH (NOLOCK)  ON T0055_Interview_Process_Detail_1.S_Emp_ID4 = T0080_EMP_MASTER_3.Emp_ID LEFT OUTER JOIN
                      dbo.T0052_HRMS_Posted_Recruitment  WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0050_HRMS_Recruitment_Request WITH (NOLOCK)  ON dbo.T0052_HRMS_Posted_Recruitment.Rec_Req_ID = dbo.T0050_HRMS_Recruitment_Request.Rec_Req_ID ON 
                      T0055_Interview_Process_Detail_1.Rec_Post_ID = dbo.T0052_HRMS_Posted_Recruitment.Rec_Post_Id LEFT OUTER JOIN
                      dbo.T0040_HRMS_R_PROCESS_MASTER WITH (NOLOCK)  ON T0055_Interview_Process_Detail_1.Process_ID = dbo.T0040_HRMS_R_PROCESS_MASTER.Process_ID





GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0055_Interview_Process_Detail';


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
         Begin Table = "T0050_HRMS_Recruitment_Request"
            Begin Extent = 
               Top = 64
               Left = 716
               Bottom = 179
               Right = 888
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0080_EMP_MASTER_3"
            Begin Extent = 
               Top = 486
               Left = 38
               Bottom = 601
               Right = 255
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0055_Interview_Process_Detail_1"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 257
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0052_HRMS_Posted_Recruitment"
            Begin Extent = 
               Top = 6
               Left = 295
               Bottom = 121
               Right = 457
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 125
               Left = 525
               Bottom = 240
               Right = 742
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0080_EMP_MASTER_1"
            Begin Extent = 
               Top = 246
               Left = 38
               Bottom = 361
               Right = 255
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0080_EMP_MASTER_2"
            Begin Extent = 
               Top = 366
               Left =', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0055_Interview_Process_Detail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N' 38
               Bottom = 481
               Right = 255
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_HRMS_R_PROCESS_MASTER"
            Begin Extent = 
               Top = 246
               Left = 293
               Bottom = 361
               Right = 445
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0055_Interview_Process_Detail';

