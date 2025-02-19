




CREATE VIEW [dbo].[V0160_OT_Approve]
AS
SELECT     dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0160_OT_APPROVAL.Tran_ID, dbo.T0160_OT_APPROVAL.Emp_ID, 
                      dbo.T0160_OT_APPROVAL.Cmp_ID, dbo.T0160_OT_APPROVAL.For_Date, dbo.T0160_OT_APPROVAL.Working_Sec, dbo.T0160_OT_APPROVAL.OT_Sec, 
                      dbo.T0160_OT_APPROVAL.Is_Approved, dbo.T0160_OT_APPROVAL.Approved_OT_Sec, dbo.T0160_OT_APPROVAL.Comments, 
                      dbo.T0160_OT_APPROVAL.Login_ID, dbo.T0160_OT_APPROVAL.System_Date, dbo.T0080_EMP_MASTER.Emp_First_Name, 
                      dbo.T0095_INCREMENT.Branch_ID, dbo.T0080_EMP_MASTER.Emp_code, dbo.T0160_OT_APPROVAL.Approved_OT_Hours, 
                      dbo.T0080_EMP_MASTER.Emp_Superior, dbo.T0160_OT_APPROVAL.P_Days_Count, ISNULL(dbo.T0160_OT_APPROVAL.Is_Month_Wise, 0) 
                      AS Is_Month_Wise, ISNULL(dbo.T0160_OT_APPROVAL.Weekoff_OT_Sec, 0.00) AS Weekoff_OT_Sec, 
                      ISNULL(dbo.T0160_OT_APPROVAL.Approved_WO_OT_Sec, 0.00) AS Approved_WO_OT_Sec, 
                      ISNULL(dbo.T0160_OT_APPROVAL.Approved_WO_OT_Hours, '0.00') AS Approved_WO_OT_Hours, 
                      ISNULL(dbo.T0160_OT_APPROVAL.Holiday_OT_Sec, 0.00) AS Holiday_OT_Sec, ISNULL(dbo.T0160_OT_APPROVAL.Approved_HO_OT_Sec, 0.00) 
                      AS Approved_HO_OT_Sec, ISNULL(dbo.T0160_OT_APPROVAL.Approved_HO_OT_Hours, '0.00') AS Approved_HO_OT_Hours, 
                      dbo.T0080_EMP_MASTER.Alpha_Emp_Code, dbo.T0160_OT_APPROVAL.Remark,
                      dbo.T0095_INCREMENT.Vertical_ID,dbo.T0095_INCREMENT.SubVertical_ID,dbo.T0095_INCREMENT.Dept_ID   -- Added By Jaina 30-09-2015
                      ,dbo.T0030_BRANCH_MASTER.Branch_Name,dbo.T0040_DEPARTMENT_MASTER.Dept_Name , dbo.T0040_DESIGNATION_MASTER.Desig_Name , T0040_GRADE_MASTER.Grd_Name
                      ,dbo.T0040_TYPE_MASTER.Type_Name , T0040_Vertical_Segment.Vertical_Name , T0050_SubVertical.SubVertical_Name
                      ,isnull(BS.Segment_name,'') as Segment_name
FROM         dbo.T0080_EMP_MASTER WITH (NOLOCK)
			INNER JOIN dbo.T0160_OT_APPROVAL WITH (NOLOCK) ON dbo.T0080_EMP_MASTER.Emp_ID = dbo.T0160_OT_APPROVAL.Emp_ID
			Inner Join T0095_INCREMENT WITH (NOLOCK) On T0080_EMP_MASTER.Emp_ID = T0095_INCREMENT.Emp_ID
			CROSS APPLY (SELECT	MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
						FROM	T0095_INCREMENT I2 WITH (NOLOCK)
								INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
											FROM	T0095_INCREMENT I3 WITH (NOLOCK) 
											WHERE	I3.Increment_Effective_Date <= T0160_OT_APPROVAL.For_Date
											GROUP BY I3.Emp_ID
											) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
						GROUP BY I2.Emp_ID HAVING T0095_Increment.Emp_ID=I2.Emp_ID AND T0095_Increment.Increment_ID=	MAX(I2.Increment_ID)
						) I2
			INNER JOIN dbo.T0040_GRADE_MASTER WITH (NOLOCK) ON dbo.T0095_INCREMENT.Grd_ID = dbo.T0040_GRADE_MASTER.Grd_ID						
			INNER JOIN dbo.T0030_BRANCH_MASTER WITH (NOLOCK) ON dbo.T0095_INCREMENT.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID
			INNER JOIN dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK) ON dbo.T0095_INCREMENT.DESIG_ID = T0040_DESIGNATION_MASTER.DESIG_ID
			LEFT OUTER JOIN dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK) ON dbo.T0095_INCREMENT.DEPT_ID = T0040_DEPARTMENT_MASTER.DEPT_ID
			LEFT OUTER JOIN dbo.T0040_TYPE_MASTER WITH (NOLOCK) on T0095_INCREMENT.Type_ID = T0040_TYPE_MASTER.Type_ID
			LEFT OUTER JOIN dbo.T0040_Vertical_Segment WITH (NOLOCK) ON dbo.T0095_INCREMENT.Vertical_ID = T0040_Vertical_Segment.Vertical_ID
			LEFT OUTER JOIN dbo.T0050_SubVertical WITH (NOLOCK) on T0095_INCREMENT.SubVertical_ID = T0050_SubVertical.SubVertical_ID
			left outer join T0040_Business_Segment BS WITH (NOLOCK) on BS.Segment_ID=T0095_INCREMENT.Segment_ID




GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[38] 4[20] 2[21] 3) )"
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
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 255
            End
            DisplayFlags = 280
            TopColumn = 75
         End
         Begin Table = "T0095_INCREMENT"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 241
               Right = 246
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0160_OT_APPROVAL"
            Begin Extent = 
               Top = 6
               Left = 293
               Bottom = 121
               Right = 546
            End
            DisplayFlags = 280
            TopColumn = 17
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 27
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
         Width = 1905
         Width = 1500
         Width = 1500
         Width = 1860
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 4935
         Alias = 2055
         Table = 1170
         Output = 720
         Append = 1400
         NewValue =', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0160_OT_Approve';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N' 1170
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0160_OT_Approve';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0160_OT_Approve';

