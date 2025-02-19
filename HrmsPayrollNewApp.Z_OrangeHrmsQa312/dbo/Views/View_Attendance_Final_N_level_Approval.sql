

CREATE VIEW [dbo].[View_Attendance_Final_N_level_Approval]
AS
SELECT     LAD.IO_Tran_Id, LAD.Emp_ID, LAD.For_Date, 
			--LAD.In_Time
			isnull(qry.In_Time, lad.In_Time) AS In_Time
			, LAD.Reason, LAD.Cmp_ID
			, LAD.Branch_ID, LAD.App_Date
				, LAD.Emp_code, LAD.Emp_Full_Name, 
                      LAD.Alpha_Emp_Code, LAD.Alpha_Code, qry.Chk_By_Superior, LAD.Half_Full_day, LAD.Sup_Comment
					  , LAD.Emp_Name, LAD.Is_Cancel_Late_In, 
                      LAD.Is_Cancel_Early_Out, 
					  --LAD.Out_Time
					  isnull(qry.Out_Time,lad.Out_Time) as Out_Time
					  --,qry.Out_Time as OT1
					  , LAD.Superior, qry.S_Emp_Id AS S_Emp_ID_A
                      ,LAD.Other_Reason,LAD.Actual_In_Time,LAD.Actual_Out_Time  --Added By Jimit 03082018
FROM         dbo.View_Late_Emp AS LAD WITH (NOLOCK) INNER JOIN
                          (SELECT     lla.IO_Tran_ID, lla.S_Emp_Id, lla.Chk_By_Superior
							, lla.In_Time, lla.Out_Time
                            FROM          dbo.T0115_AttendanceRegu_Level_Approval AS lla WITH (NOLOCK) 
							INNER JOIN
                                                       (SELECT    MAX(Rpt_Level) AS Rpt_Level, IO_Tran_ID
                                                         FROM          dbo.T0115_AttendanceRegu_Level_Approval WITH (NOLOCK) 
                                                         GROUP BY IO_Tran_ID) AS Qry_1 
													ON Qry_1.Rpt_Level = lla.Rpt_Level AND Qry_1.IO_Tran_ID = lla.IO_Tran_ID 
														 INNER JOIN
                                                   dbo.View_Late_Emp AS LA WITH (NOLOCK) ON LA.IO_Tran_Id = lla.IO_Tran_ID
                            WHERE      (lla.Chk_By_Superior = 1) OR
                                                   (lla.Chk_By_Superior = 0) OR
                                                   (lla.Chk_By_Superior = 2)) AS qry 
												   ON LAD.IO_Tran_Id = qry.IO_Tran_ID


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
         Begin Table = "LAD"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 228
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "qry"
            Begin Extent = 
               Top = 6
               Left = 266
               Bottom = 110
               Right = 437
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'View_Attendance_Final_N_level_Approval';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'View_Attendance_Final_N_level_Approval';

