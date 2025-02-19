





CREATE VIEW [dbo].[V0100_NIGHTHALT_APPLICATION]
AS
SELECT     dbo.T0100_NIGHT_HALT_APPLICATION.Application_ID, dbo.T0100_NIGHT_HALT_APPLICATION.Cmp_ID, dbo.T0100_NIGHT_HALT_APPLICATION.Emp_ID,B.Branch_Id, 
                      dbo.T0100_NIGHT_HALT_APPLICATION.From_Date, dbo.T0100_NIGHT_HALT_APPLICATION.To_Date, 
                      Case when ISNULL(NT.Approve_Days,0) > 0 THEN NT.Approve_Days Else dbo.T0100_NIGHT_HALT_APPLICATION.No_Of_Days End AS No_Of_Days, 
                      dbo.T0100_NIGHT_HALT_APPLICATION.Visit_Place, dbo.T0100_NIGHT_HALT_APPLICATION.Remarks, dbo.T0100_NIGHT_HALT_APPLICATION.App_Status, 
                      dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0080_EMP_MASTER.Emp_First_Name, dbo.T0080_EMP_MASTER.Emp_Superior AS R_Emp_ID, 
                      dbo.T0080_EMP_MASTER.Alpha_Emp_Code, EM1.Emp_Full_Name AS Superior_Name
                      ,NT.Approval_ID,NT.Approve_Days,NT.Amount,NT.Calculated_Amount
					  ,T0100_NIGHT_HALT_APPLICATION.Application_ID as Application_code
                      ,B.Vertical_ID,B.SubVertical_ID,B.Dept_ID   --Added By Jaina 1-10-2015
					  ,ISNULL(NT.AdminFlag,0)AdminFlag --Added By tejas 11062024
FROM         dbo.T0100_NIGHT_HALT_APPLICATION WITH (NOLOCK) INNER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0100_NIGHT_HALT_APPLICATION.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS EM1 WITH (NOLOCK)  ON EM1.Emp_ID = dbo.T0100_NIGHT_HALT_APPLICATION.S_Emp_ID 
                      LEFT OUTER JOIN
                      dbo.T0120_NIGHT_HALT_APPROVAL AS NT WITH (NOLOCK)  ON NT.Application_ID = dbo.T0100_NIGHT_HALT_APPLICATION.Application_ID
                      INNER JOIN 
                      --Added By Jaina 04-09-2015 Start
					  (
						SELECT	EMP_ID, Branch_ID, CMP_ID,I.Vertical_ID,I.SubVertical_ID,I.Dept_ID
						FROM	T0095_INCREMENT I WITH (NOLOCK) 
						WHERE	I.INCREMENT_ID = (
													SELECT	TOP 1 INCREMENT_ID
													FROM	T0095_INCREMENT I1 WITH (NOLOCK) 
													WHERE	I1.EMP_ID=I.EMP_ID AND I1.CMP_ID=I.CMP_ID
													ORDER BY	INCREMENT_EFFECTIVE_DATE DESC, INCREMENT_ID DESC
												)
					  ) AS B ON B.EMP_ID = dbo.T0080_EMP_MASTER.EMP_ID AND B.CMP_ID=dbo.T0080_EMP_MASTER.CMP_ID --Added By Jaina 04-09-2015 End





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
         Begin Table = "T0100_NIGHT_HALT_APPLICATION"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 198
            End
            DisplayFlags = 280
            TopColumn = 8
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 245
               Right = 282
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "EM1"
            Begin Extent = 
               Top = 246
               Left = 38
               Bottom = 365
               Right = 282
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_NIGHTHALT_APPLICATION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_NIGHTHALT_APPLICATION';

