




CREATE VIEW [dbo].[V0100_LEFT_EMP]
AS
SELECT     dbo.T0100_LEFT_EMP.Left_ID, dbo.T0100_LEFT_EMP.Cmp_ID, dbo.T0100_LEFT_EMP.Emp_ID, dbo.T0100_LEFT_EMP.Uniform_Return, dbo.T0100_LEFT_EMP.Exit_Interview, 
                      dbo.T0100_LEFT_EMP.Notice_Period, dbo.T0100_LEFT_EMP.Left_Date, dbo.T0100_LEFT_EMP.Left_Reason, dbo.T0100_LEFT_EMP.New_Employer, 
                      ISNULL(dbo.T0100_LEFT_EMP.Reg_Accept_Date, '') AS Reg_Accept_Date, ISNULL(dbo.T0100_LEFT_EMP.Is_Terminate, 0) AS Is_Terminate, ISNULL(dbo.T0100_LEFT_EMP.Is_Death, 0) AS Is_Death,
                       dbo.T0080_EMP_MASTER.Emp_code, dbo.T0080_EMP_MASTER.Emp_First_Name, dbo.T0080_EMP_MASTER.Date_Of_Join, dbo.T0080_EMP_MASTER.Gender, 
                      dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0095_INCREMENT.Branch_ID, dbo.T0095_INCREMENT.Cat_ID, dbo.T0095_INCREMENT.Grd_ID, dbo.T0095_INCREMENT.Dept_ID, 
                      dbo.T0095_INCREMENT.Desig_Id, dbo.T0040_GRADE_MASTER.Grd_Name, dbo.T0040_DEPARTMENT_MASTER.Dept_Name, dbo.T0030_BRANCH_MASTER.Branch_Name, 
                      dbo.T0040_DESIGNATION_MASTER.Desig_Name, dbo.T0080_EMP_MASTER.Alpha_Emp_Code, dbo.T0100_LEFT_EMP.Reg_Date, dbo.T0100_LEFT_EMP.Rpt_Manager_ID, 
                      dbo.T0100_LEFT_EMP.Is_Retire,dbo.T0095_INCREMENT.Vertical_ID,dbo.T0095_INCREMENT.SubVertical_ID,  --Added By Jaina 18-09-2015
                      dbo.T0100_LEFT_EMP.LeftReasonValue,dbo.T0100_LEFT_EMP.LeftReasonText, --added by chetan 030817
					  dbo.T0040_Reason_Master.Res_Id, --Added By Jimit 25122018
					  CASE WHEN Is_Terminate=1 THEN 'Terminated' WHEN Is_Death=1 THEN 'Death' WHEN Is_Retire=1 THEN 'Retirement' WHEN Is_Absconded = 1 THEN 'Absconded' ELSE 'Resignation' END AS Reason_Type,
					  RM.Reason_Name AS LEFT_REASON_NAME,ISNULL(Is_Absconded,0) As Is_Absconded
FROM         dbo.T0095_INCREMENT WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Desig_Id = dbo.T0040_DESIGNATION_MASTER.Desig_ID LEFT OUTER JOIN
                      dbo.T0040_GRADE_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Grd_ID = dbo.T0040_GRADE_MASTER.Grd_ID LEFT OUTER JOIN
                      dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Dept_ID = dbo.T0040_DEPARTMENT_MASTER.Dept_Id LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID RIGHT OUTER JOIN
                      dbo.T0080_EMP_MASTER  WITH (NOLOCK) ON dbo.T0095_INCREMENT.Increment_ID = dbo.T0080_EMP_MASTER.Increment_ID RIGHT OUTER JOIN
                      dbo.T0100_LEFT_EMP  WITH (NOLOCK) ON dbo.T0080_EMP_MASTER.Emp_ID = dbo.T0100_LEFT_EMP.Emp_ID Left Outer Join
					  dbo.T0040_Reason_Master WITH (NOLOCK)  ON dbo.T0040_Reason_Master.Res_Id = dbo.T0100_LEFT_EMP.Res_Id Left Outer Join
					  dbo.T0040_Reason_Master RM  WITH (NOLOCK) ON RM.RES_ID = dbo.T0100_LEFT_EMP.Left_ID--Ronakb161023

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[47] 4[15] 2[21] 3) )"
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
         Top = -54
         Left = 0
      End
      Begin Tables = 
         Begin Table = "T0095_INCREMENT"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 246
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_DESIGNATION_MASTER"
            Begin Extent = 
               Top = 6
               Left = 284
               Bottom = 121
               Right = 436
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_GRADE_MASTER"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 241
               Right = 213
            End
            DisplayFlags = 280
            TopColumn = 7
         End
         Begin Table = "T0040_DEPARTMENT_MASTER"
            Begin Extent = 
               Top = 44
               Left = 519
               Bottom = 159
               Right = 671
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "T0030_BRANCH_MASTER"
            Begin Extent = 
               Top = 246
               Left = 38
               Bottom = 361
               Right = 197
            End
            DisplayFlags = 280
            TopColumn = 6
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 10
               Left = 675
               Bottom = 125
               Right = 892
            End
            DisplayFlags = 280
            TopColumn = 79
         End
         Begin Table = "T0100_LEFT_EMP"
            Begin Extent = 
               Top = 198
               Left = 225
               Bottom = ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_LEFT_EMP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'309
               Right = 393
            End
            DisplayFlags = 280
            TopColumn = 15
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 10
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_LEFT_EMP';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_LEFT_EMP';

