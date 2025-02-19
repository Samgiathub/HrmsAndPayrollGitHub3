


CREATE VIEW [dbo].[V0055_HRMS_Interview_Schedule]
AS
SELECT     dbo.T0055_HRMS_Interview_Schedule.Interview_Schedule_Id, dbo.T0055_HRMS_Interview_Schedule.Interview_Process_Detail_Id, 
                      dbo.T0055_HRMS_Interview_Schedule.Rec_Post_Id, dbo.T0055_HRMS_Interview_Schedule.Cmp_Id, dbo.T0055_HRMS_Interview_Schedule.S_Emp_Id, 
                      dbo.T0055_HRMS_Interview_Schedule.S_Emp_Id2, dbo.T0055_HRMS_Interview_Schedule.S_Emp_Id3, dbo.T0055_HRMS_Interview_Schedule.S_Emp_ID4, 
                      dbo.T0055_HRMS_Interview_Schedule.From_Date, dbo.T0055_HRMS_Interview_Schedule.To_Date, dbo.T0055_HRMS_Interview_Schedule.From_Time, 
                      dbo.T0055_HRMS_Interview_Schedule.To_Time, dbo.T0055_HRMS_Interview_Schedule.Resume_Id, dbo.T0055_HRMS_Interview_Schedule.Rating, 
                      dbo.T0055_HRMS_Interview_Schedule.Rating2, dbo.T0055_HRMS_Interview_Schedule.Rating3, dbo.T0055_HRMS_Interview_Schedule.Rating4, 
                      dbo.T0055_HRMS_Interview_Schedule.Schedule_Date, dbo.T0055_HRMS_Interview_Schedule.Schedule_Time, 
                      dbo.T0055_HRMS_Interview_Schedule.Process_Dis_No, dbo.T0055_HRMS_Interview_Schedule.Status, dbo.T0055_HRMS_Interview_Schedule.Comments, 
                      dbo.T0055_HRMS_Interview_Schedule.System_Date, T0040_HRMS_R_PROCESS_MASTER_1.Process_Name, dbo.T0055_Interview_Process_Detail.Dis_No, 
                      dbo.T0052_HRMS_Posted_Recruitment.Rec_Post_Code, dbo.T0052_HRMS_Posted_Recruitment.Job_title, 
                      CAST(dbo.T0080_EMP_MASTER.Alpha_Emp_Code AS varchar(50)) + ' - ' + dbo.T0080_EMP_MASTER.Emp_Full_Name AS emp_full_name_new, 
                      dbo.T0055_Interview_Process_Detail.Process_ID, dbo.T0055_HRMS_Interview_Schedule.Comments2, dbo.T0055_HRMS_Interview_Schedule.Comments3, 
                      dbo.T0055_HRMS_Interview_Schedule.Comments4, dbo.T0040_HRMS_R_PROCESS_MASTER.Process_Name AS prcoess_name, 
                      dbo.T0050_HRMS_Recruitment_Request.Branch_id, dbo.T0052_HRMS_Posted_Recruitment.Position, CAST(T0080_EMP_MASTER_1.Alpha_Emp_Code AS varchar(50)) 
                      + ' - ' + T0080_EMP_MASTER_1.Emp_Full_Name AS member1, CAST(T0080_EMP_MASTER_2.Alpha_Emp_Code AS varchar(50)) 
                      + ' - ' + T0080_EMP_MASTER_2.Emp_Full_Name AS member2, CAST(T0080_EMP_MASTER_3.Alpha_Emp_Code AS varchar(50)) 
                      + ' - ' + T0080_EMP_MASTER_3.Emp_Full_Name AS member3, dbo.T0055_HRMS_Interview_Schedule.BypassInterview, 
                      dbo.T0055_HRMS_Interview_Schedule.HR_DOC_ID, dbo.T0050_HRMS_Recruitment_Request.Dept_Id
FROM         dbo.T0080_EMP_MASTER AS T0080_EMP_MASTER_3 WITH (NOLOCK) RIGHT OUTER JOIN
                      dbo.T0055_HRMS_Interview_Schedule WITH (NOLOCK)  ON T0080_EMP_MASTER_3.Emp_ID = dbo.T0055_HRMS_Interview_Schedule.S_Emp_ID4 LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS T0080_EMP_MASTER_2 WITH (NOLOCK)  ON dbo.T0055_HRMS_Interview_Schedule.S_Emp_Id3 = T0080_EMP_MASTER_2.Emp_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS T0080_EMP_MASTER_1 WITH (NOLOCK)  ON dbo.T0055_HRMS_Interview_Schedule.S_Emp_Id2 = T0080_EMP_MASTER_1.Emp_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0055_HRMS_Interview_Schedule.S_Emp_Id = dbo.T0080_EMP_MASTER.Emp_ID LEFT OUTER JOIN
                      dbo.T0050_HRMS_Recruitment_Request WITH (NOLOCK)  RIGHT OUTER JOIN
                      dbo.T0052_HRMS_Posted_Recruitment WITH (NOLOCK)  ON 
                      dbo.T0050_HRMS_Recruitment_Request.Rec_Req_ID = dbo.T0052_HRMS_Posted_Recruitment.Rec_Req_ID RIGHT OUTER JOIN
                      dbo.T0055_Interview_Process_Detail WITH (NOLOCK)  LEFT OUTER JOIN
                      dbo.T0040_HRMS_R_PROCESS_MASTER WITH (NOLOCK)  ON dbo.T0055_Interview_Process_Detail.Process_ID = dbo.T0040_HRMS_R_PROCESS_MASTER.Process_ID ON 
                      dbo.T0052_HRMS_Posted_Recruitment.Rec_Post_Id = dbo.T0055_Interview_Process_Detail.Rec_Post_ID ON 
                      dbo.T0055_HRMS_Interview_Schedule.Interview_Process_Detail_Id = dbo.T0055_Interview_Process_Detail.Interview_Process_detail_ID LEFT OUTER JOIN
                      dbo.T0040_HRMS_R_PROCESS_MASTER AS T0040_HRMS_R_PROCESS_MASTER_1 WITH (NOLOCK) ON 
                      dbo.T0055_Interview_Process_Detail.Process_ID = T0040_HRMS_R_PROCESS_MASTER_1.Process_ID


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[45] 4[5] 2[25] 3) )"
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
         Begin Table = "T0080_EMP_MASTER_3"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 255
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0055_HRMS_Interview_Schedule"
            Begin Extent = 
               Top = 54
               Left = 248
               Bottom = 212
               Right = 472
            End
            DisplayFlags = 280
            TopColumn = 22
         End
         Begin Table = "T0080_EMP_MASTER_2"
            Begin Extent = 
               Top = 246
               Left = 38
               Bottom = 361
               Right = 255
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0080_EMP_MASTER_1"
            Begin Extent = 
               Top = 366
               Left = 38
               Bottom = 481
               Right = 255
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 486
               Left = 38
               Bottom = 601
               Right = 255
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0050_HRMS_Recruitment_Request"
            Begin Extent = 
               Top = 1
               Left = 471
               Bottom = 116
               Right = 643
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0052_HRMS_Posted_Recruitment"
            Begin Extent = 
               Top = 112
               Left = 620', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0055_HRMS_Interview_Schedule';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'
               Bottom = 227
               Right = 782
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0055_Interview_Process_Detail"
            Begin Extent = 
               Top = 606
               Left = 38
               Bottom = 721
               Right = 257
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
         Begin Table = "T0040_HRMS_R_PROCESS_MASTER_1"
            Begin Extent = 
               Top = 366
               Left = 293
               Bottom = 481
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
      Begin ColumnWidths = 41
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0055_HRMS_Interview_Schedule';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0055_HRMS_Interview_Schedule';

