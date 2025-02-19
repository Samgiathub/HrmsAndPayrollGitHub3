  
  
        
        
        
        
        
CREATE VIEW [dbo].[V0120_TRAVEL_APPROVAL]        
AS        
SELECT   Distinct  EM.Alpha_Emp_Code, TAPR.Travel_Approval_ID, TAPR.Cmp_ID, TAPR.Emp_ID, dbo.T0100_TRAVEL_APPLICATION.Application_Code,         
                      dbo.T0100_TRAVEL_APPLICATION.Application_Date, SEMP.Emp_Full_Name AS Supervisor, EM.Emp_Full_Name, TAPR.Approval_Date, TAPR.Approval_Status,         
                      TAPR.Approval_Comments,        
                              
                      T0100_TRAVEL_APPLICATION.Travel_Application_ID,         
                      isnull(TAPR.Approved_Status_Help_Desk,'P') as Application_Status,          
                      BM.Branch_Name, BM.Branch_ID        
                     ,ISNULL(TSA.Travel_Set_Application_id,0) as travel_set_Application_id        
                     ,em.Vertical_ID,em.SubVertical_ID,em.Dept_ID,TAPR.Approval_Status As Status        
                       ,'' as Reason_Name      
FROM         dbo.T0120_TRAVEL_APPROVAL AS TAPR WITH (NOLOCK) INNER JOIN        
                      dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK)  ON TAPR.Emp_ID = EM.Emp_ID INNER JOIN        
                      dbo.T0100_TRAVEL_APPLICATION WITH (NOLOCK)  ON TAPR.Travel_Application_ID = dbo.T0100_TRAVEL_APPLICATION.Travel_Application_ID LEFT OUTER JOIN        
                      dbo.T0080_EMP_MASTER AS SEMP WITH (NOLOCK)  ON TAPR.S_Emp_ID = SEMP.Emp_ID inner join         
                       -- Added By Yogesh on 17082023 for to Get latest Branch name Start        
        dbo.T0095_INCREMENT AS IM WITH (NOLOCK)  ON TAPR.Emp_ID = IM.Emp_ID         
        and IM.Increment_Effective_Date=(select Max(Increment_Effective_Date) from T0095_INCREMENT where emp_id=EM.Emp_ID)         
        INNER JOIN        
        T0030_BRANCH_MASTER BM WITH (NOLOCK)  on IM.Branch_ID = BM.Branch_ID left join        
       -- Added By Yogesh on 17082023 for to Get latest Branch name End        
                      T0140_Travel_Settlement_Application as TSA  WITH (NOLOCK) ON TAPR.Travel_Approval_ID = TSA.Travel_Approval_ID       
       left join T0110_TRAVEL_APPLICATION_DETAIL as TRD  WITH (NOLOCK) on trd.Travel_App_Id=TAPR.Travel_Application_ID      
    left join T0130_TRAVEL_APPROVAL_DETAIL as TAD  WITH (NOLOCK) on tad.Travel_Approval_ID=TAPR.Travel_Approval_ID      
       left join T0040_Reason_Master RM WITH (NOLOCK) on rm.Res_Id=TAD.Reason_ID      
        
        
GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[42] 4[14] 2[15] 3) )"
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
         Begin Table = "TAPR"
            Begin Extent = 
               Top = 2
               Left = 589
               Bottom = 247
               Right = 783
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "EM"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 236
               Right = 263
            End
            DisplayFlags = 280
            TopColumn = 33
         End
         Begin Table = "SEMP"
            Begin Extent = 
               Top = 6
               Left = 301
               Bottom = 254
               Right = 526
            End
            DisplayFlags = 280
            TopColumn = 29
         End
         Begin Table = "T0100_TRAVEL_APPLICATION"
            Begin Extent = 
               Top = 10
               Left = 914
               Bottom = 227
               Right = 1108
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
      Begin ColumnWidths = 13
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 2445
         Width = 1935
         Width = 1455
         Width = 1995
         Width = 1500
         Width = 1965
         Width = 1875
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
         GroupBy = 135', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0120_TRAVEL_APPROVAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'0
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0120_TRAVEL_APPROVAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0120_TRAVEL_APPROVAL';

