 
        
        
        
        
        
        
        
        
CREATE VIEW [dbo].[V0110_TRAVEL_APPLICATION_DETAIL]        
AS        
SELECT     TA.Travel_Application_ID, TA.Application_Date, TA.Application_Code, TA.Emp_ID, EM.Emp_Full_Name, isnull(TA.S_Emp_ID,0) as S_Emp_ID , SEMP.Emp_Full_Name AS Supervisor,         
                      TAD.Travel_App_Detail_ID, TAD.Place_Of_Visit, TAD.Travel_Purpose, TAD.Instruct_Emp_ID,         
                      IEMP.Alpha_Emp_Code + ' - ' + IEMP.Emp_Full_Name AS Instruct_Emp_Name, TAD.Travel_Mode_ID, TM.Travel_Mode_Name, TAD.From_Date, TAD.Period,         
                      TAD.To_Date, TAD.Remarks, dbo.T0030_BRANCH_MASTER.Branch_ID, dbo.T0030_BRANCH_MASTER.Branch_Name, dbo.T0040_DESIGNATION_MASTER.Desig_ID,         
                      dbo.T0040_DESIGNATION_MASTER.Desig_Name        
                      ,0 as Leave_id,'' as Leave_name,TA.Cmp_ID        
                      ,TA.chk_Adv,TA.chk_Agenda,ta.Tour_Agenda,TA.IMP_Business_Appoint,ta.KRA_Tour,TA.Attached_Doc_File        
                      ,isnull(TAD.State_ID,0)as State_ID,isnull(TAD.City_ID,0) as City_ID    
       ,isnull(TAD.From_State_ID,0)as From_State_ID,isnull(TAD.From_City_ID,0) as From_City_ID    
       ,fSm.State_Name as From_State    
       ,Fcm.City_Name as From_City     
       ,Sm.State_Name as State    
       ,cm.City_Name as City        
                      ,ISNULL(TAD.loc_ID,0) as Loc_ID ,LM.Loc_name as Loc_Name,isnull(TA.Chk_International,0) as Chk_International        
                      ,ISNULL(TAD.Project_ID,0) as Project_ID,isnull(PMP.Project_Name,'') as Project_Name,        
                      ISNULL(PMP.Site_Id,'') as Site_ID,isnull(TM.GST_Applicable,0) As GST_Applicable,C.GST_No,EM.Work_tel_no,EM.Mobile_no,EM.Work_email        
       ,isnull(TT.Travel_Type_Name , '') as Travel_Type_Name,isnull(tt.Travel_Type_Id,0) as Travel_Type_Id,RM.Reason_Name,Tad.Reason_ID as Res_id        
FROM     dbo.T0110_TRAVEL_APPLICATION_DETAIL AS TAD WITH (NOLOCK) INNER JOIN        
                      dbo.T0100_TRAVEL_APPLICATION AS TA WITH (NOLOCK)  ON TAD.Travel_App_ID = TA.Travel_Application_ID left JOIN        
                      dbo.T0030_TRAVEL_MODE_MASTER AS TM WITH (NOLOCK)  ON TM.Travel_Mode_ID = TAD.Travel_Mode_ID INNER JOIN        
                      dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK)  ON TA.Emp_ID = EM.Emp_ID --INNER JOIN        
                      LEFT OUTER JOIN  (SELECT I.*        
         FROM  dbo.T0095_INCREMENT AS i  WITH (NOLOCK)         
           INNER JOIN  (SELECT     MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID        
                FROM          dbo.T0095_INCREMENT AS I2 WITH (NOLOCK)  INNER JOIN        
                         (SELECT     MAX(Increment_Effective_Date) AS INCREMENT_EFFECTIVE_DATE, Emp_ID        
                        FROM          dbo.T0095_INCREMENT AS I3 WITH (NOLOCK)         
                        WHERE      (Increment_Effective_Date <= GETDATE())        
                        GROUP BY Emp_ID) AS I3 ON I2.Increment_Effective_Date = I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID = I3.Emp_ID        
                GROUP BY I2.Emp_ID) AS I2 ON i.Emp_ID = I2.Emp_ID AND i.Increment_ID = I2.Increment_ID         
        ) INC ON EM.EMP_ID = INC.EMP_ID  LEFT OUTER JOIN         
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON INC.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID INNER JOIN        
                      dbo.T0040_DESIGNATION_MASTER  WITH (NOLOCK) ON INC.Desig_Id = dbo.T0040_DESIGNATION_MASTER.Desig_ID LEFT OUTER JOIN        
                      dbo.T0080_EMP_MASTER AS SEMP WITH (NOLOCK)  ON TA.S_Emp_ID = SEMP.Emp_ID LEFT OUTER JOIN        
                      dbo.T0080_EMP_MASTER AS IEMP  WITH (NOLOCK) ON TAD.Instruct_Emp_ID = IEMP.Emp_ID left outer join        
                      dbo.T0020_STATE_MASTER sm  WITH (NOLOCK) on sm.State_ID=TAD.state_ID left outer join        
       dbo.T0020_STATE_MASTER fsm  WITH (NOLOCK) on fsm.State_ID=TAD.From_state_ID left outer join        
                      dbo.T0030_CITY_MASTER cm WITH (NOLOCK)  on cm.City_ID=TAD.City_ID left join        
       dbo.T0030_CITY_MASTER Fcm WITH (NOLOCK)  on fcm.City_ID=TAD.From_City_ID left join        
                      dbo.T0001_LOCATION_MASTER LM  WITH (NOLOCK) on TAD.Loc_ID=LM.Loc_ID left join        
                      dbo.T0050_Project_Master_Payroll PMP WITH (NOLOCK)  on PMP.Tran_Id=TAD.ProjeCt_ID and PMP.Cmp_Id=TAD.Cmp_ID INNER JOIN        
                      T0010_COMPANY_MASTER C  WITH (NOLOCK) ON c.Cmp_Id = TAD.Cmp_ID Left Join         
       T0040_Travel_Type TT With (Nolock) on  Tt.Travel_Type_Id = TAD.TravelTypeId        
       left join T0040_Reason_Master RM With (NoLock) on RM.res_id=TAD.Reason_ID        
        

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N' 280
            TopColumn = 0
         End
         Begin Table = "IEMP"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 315
               Right = 255
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
      Begin ColumnWidths = 24
         Width = 284
         Width = 1770
         Width = 1995
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1770
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 2115
         Width = 1500
         Width = 1620
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
         Column = 1800
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0110_TRAVEL_APPLICATION_DETAIL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0110_TRAVEL_APPLICATION_DETAIL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[50] 4[3] 2[18] 3) )"
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
         Begin Table = "TAD"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 224
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TA"
            Begin Extent = 
               Top = 6
               Left = 262
               Bottom = 253
               Right = 448
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TM"
            Begin Extent = 
               Top = 6
               Left = 486
               Bottom = 121
               Right = 662
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "EM"
            Begin Extent = 
               Top = 6
               Left = 700
               Bottom = 154
               Right = 917
            End
            DisplayFlags = 280
            TopColumn = 2
         End
         Begin Table = "T0030_BRANCH_MASTER"
            Begin Extent = 
               Top = 132
               Left = 1033
               Bottom = 251
               Right = 1200
            End
            DisplayFlags = 280
            TopColumn = 3
         End
         Begin Table = "T0040_DESIGNATION_MASTER"
            Begin Extent = 
               Top = 151
               Left = 509
               Bottom = 270
               Right = 678
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SEMP"
            Begin Extent = 
               Top = 6
               Left = 955
               Bottom = 121
               Right = 1172
            End
            DisplayFlags =', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0110_TRAVEL_APPLICATION_DETAIL';

