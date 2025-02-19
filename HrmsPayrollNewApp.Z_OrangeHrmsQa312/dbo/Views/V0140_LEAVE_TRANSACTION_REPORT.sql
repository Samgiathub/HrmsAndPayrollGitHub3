
  
  
  
  
CREATE   VIEW [dbo].[V0140_LEAVE_TRANSACTION_REPORT]  
AS  
 SELECT TOP (100) PERCENT l.Cmp_ID, e.Emp_ID, e.Alpha_Emp_Code AS Emp_code, e.Emp_Full_Name, g.Grd_Name, d.Dept_Name, t.Type_Name,  
 c.Cat_Name, de.Desig_Name, l.Leave_ID, dbo.T0040_LEAVE_MASTER.Leave_Name,  
 l.For_Date  
 , l.Leave_Opening, l.Leave_Credit, l.Leave_Used,  
 l.Leave_Closing, l.Leave_Posting, l.Leave_Adj_L_Mark, l.CompOff_Credit, l.CompOff_Debit, l.CompOff_Balance, l.CompOff_Used,  
 l.Back_Dated_Leave,l.Half_Payment_Days  
 FROM dbo.T0140_LEAVE_TRANSACTION AS l WITH (NOLOCK) INNER JOIN  
  
 dbo.T0080_EMP_MASTER AS e WITH (NOLOCK)  ON l.Emp_ID = e.Emp_ID AND l.Cmp_ID = e.Cmp_ID INNER JOIN  
 dbo.T0040_GRADE_MASTER AS g WITH (NOLOCK)  ON e.Grd_ID = g.Grd_ID INNER JOIN  
 dbo.T0040_LEAVE_MASTER WITH (NOLOCK)  ON l.Leave_ID = dbo.T0040_LEAVE_MASTER.Leave_ID LEFT OUTER JOIN  
 dbo.T0040_DESIGNATION_MASTER AS de WITH (NOLOCK)  ON e.Desig_Id = de.Desig_ID LEFT OUTER JOIN  
 dbo.T0040_TYPE_MASTER AS t WITH (NOLOCK)  ON e.Type_ID = t.Type_ID LEFT OUTER JOIN  
 dbo.T0030_CATEGORY_MASTER AS c WITH (NOLOCK)  ON e.Cat_ID = c.Cat_ID LEFT OUTER JOIN  
 dbo.T0040_DEPARTMENT_MASTER AS d WITH (NOLOCK)  ON e.Dept_ID = d.Dept_Id  
   
  WHERE  isnull(l.IsMakerChaker,0) <> 1 --Added by ronakk 20092022  
  and( (l.Leave_Opening <> 0) OR  
  (l.Leave_Credit <> 0) OR  
  (l.Leave_Used <> 0) OR  
  (l.Leave_Closing <> 0) OR  
  (l.CompOff_Balance <> 0) OR  
  (l.CompOff_Credit <> 0) OR  
  (l.CompOff_Debit <> 0) OR  
  (l.CompOff_Used <> 0) )  
    
  ORDER BY e.Emp_Full_Name, l.For_Date   

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[71] 4[5] 2[5] 3) )"
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
         Begin Table = "l"
            Begin Extent = 
               Top = 0
               Left = 37
               Bottom = 115
               Right = 209
            End
            DisplayFlags = 280
            TopColumn = 17
         End
         Begin Table = "e"
            Begin Extent = 
               Top = 6
               Left = 248
               Bottom = 121
               Right = 465
            End
            DisplayFlags = 280
            TopColumn = 8
         End
         Begin Table = "g"
            Begin Extent = 
               Top = 15
               Left = 740
               Bottom = 130
               Right = 915
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_LEAVE_MASTER"
            Begin Extent = 
               Top = 155
               Left = 269
               Bottom = 270
               Right = 480
            End
            DisplayFlags = 344
            TopColumn = 4
         End
         Begin Table = "de"
            Begin Extent = 
               Top = 272
               Left = 671
               Bottom = 387
               Right = 823
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "t"
            Begin Extent = 
               Top = 129
               Left = 776
               Bottom = 244
               Right = 928
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "c"
            Begin Extent = 
               Top = 244
               Left = 501
               Bottom = 359
               Right = 658
            End
            DisplayFlags = 280
            TopColumn =', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0140_LEAVE_TRANSACTION_REPORT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N' 0
         End
         Begin Table = "d"
            Begin Extent = 
               Top = 166
               Left = 654
               Bottom = 281
               Right = 806
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
      Begin ColumnWidths = 12
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
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0140_LEAVE_TRANSACTION_REPORT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0140_LEAVE_TRANSACTION_REPORT';

