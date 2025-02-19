  
  
  
  
  
   
CREATE VIEW [dbo].[V0030_Branch_Master]    
AS    
SELECT     dbo.T0030_BRANCH_MASTER.Branch_Name, dbo.T0030_BRANCH_MASTER.Branch_Address, upper(dbo.T0030_BRANCH_MASTER.Branch_City) as Branch_City,     
upper(dbo.T0020_STATE_MASTER.State_Name) as State_Name , dbo.T0030_BRANCH_MASTER.Branch_ID, dbo.T0030_BRANCH_MASTER.Cmp_ID,     
dbo.T0030_BRANCH_MASTER.State_ID, dbo.T0030_BRANCH_MASTER.Branch_Code, dbo.T0030_BRANCH_MASTER.Comp_Name,     
dbo.T0030_BRANCH_MASTER.Is_Contractor_Branch, dbo.T0030_BRANCH_MASTER.Branch_Default, dbo.T0010_COMPANY_MASTER.Cmp_Name,     
dbo.T0030_BRANCH_MASTER.Location_ID, dbo.T0001_LOCATION_MASTER.Loc_name,  
  
dbo.T0030_BRANCH_MASTER.District_ID, DM.Dist_Name,  --Added by ronaKK 17022022  
dbo.T0030_BRANCH_MASTER.Tehsil_ID, TM.T_Name,  --Added by ronaKK 17022022  
  
dbo.T0030_BRANCH_MASTER.PT_RC_No,dbo.T0030_BRANCH_MASTER.PT_Zone,dbo.T0030_BRANCH_MASTER.PT_Ward_No,dbo.T0030_BRANCH_MASTER.PT_Census_No    
,dbo.T0030_BRANCH_MASTER.IsActive,dbo.T0030_BRANCH_MASTER.InActive_EffeDate     
,dbo.T0030_BRANCH_MASTER.PF_No,dbo.T0030_BRANCH_MASTER.ESIC_No,  
CASE WHEN dbo.T0030_BRANCH_MASTER.IsActive=1 THEN 'awards_link'   
WHEN dbo.T0030_BRANCH_MASTER.IsActive=0 THEN 'awards_link clsinactive' ELSE 'awards_link clsinactive' END  as Status_Color  
,Contr_PersonName ,Contr_Email ,Contr_MobileNo ,Contr_Aadhaar ,Contr_GSTNumber ,Nature_Of_Work ,No_Of_LabourEmployed ,Date_Of_Commencement ,Date_Of_Termination ,Vendor_Code,Contr_Det_ID,LICENCE_DOC  
FROM dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  
INNER JOIN  dbo.T0010_COMPANY_MASTER WITH (NOLOCK)  ON dbo.T0030_BRANCH_MASTER.Cmp_ID = dbo.T0010_COMPANY_MASTER.Cmp_Id   
LEFT OUTER JOIN dbo.T0001_LOCATION_MASTER WITH (NOLOCK)  ON dbo.T0030_BRANCH_MASTER.Location_ID = dbo.T0001_LOCATION_MASTER.Loc_ID  
  
LEFT OUTER JOIN dbo.T0030_DISTRICT_MASTER as DM WITH (NOLOCK)  ON dbo.T0030_BRANCH_MASTER.District_ID = DM.Dist_ID --Added by ronaKK 17022022  
LEFT OUTER JOIN dbo.T0030_TEHSIL_MASTER as TM WITH (NOLOCK)  ON dbo.T0030_BRANCH_MASTER.Tehsil_ID = TM.T_ID --Added by ronaKK 17022022  
  
LEFT OUTER JOIN  dbo.T0020_STATE_MASTER WITH (NOLOCK)  ON dbo.T0030_BRANCH_MASTER.State_ID = dbo.T0020_STATE_MASTER.State_ID  AND T0030_BRANCH_MASTER.Cmp_ID = T0020_STATE_MASTER.Cmp_ID  
Left Outer join (SELECT CDM.* FROM dbo.T0035_CONTRACTOR_DETAIL_MASTER CDM  WITH (NOLOCK)   
     INNER JOIN (SELECT MAX(DATE_OF_COMMENCEMENT) AS DOC, BRANCH_ID   
        FROM T0035_CONTRACTOR_DETAIL_MASTER  WITH (NOLOCK)   
        GROUP BY Branch_ID) QRY ON CDM.BRANCH_ID = QRY.BRANCH_ID AND CDM.Date_Of_Commencement = QRY.DOC) CONTR   
        ON T0030_BRANCH_MASTER.Branch_ID = CONTR.Branch_ID  
GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[61] 4[1] 2[29] 3) )"
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
         Begin Table = "T0030_BRANCH_MASTER"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 300
               Right = 226
            End
            DisplayFlags = 280
            TopColumn = 6
         End
         Begin Table = "T0010_COMPANY_MASTER"
            Begin Extent = 
               Top = 77
               Left = 458
               Bottom = 196
               Right = 699
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0001_LOCATION_MASTER"
            Begin Extent = 
               Top = 155
               Left = 264
               Bottom = 240
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0020_STATE_MASTER"
            Begin Extent = 
               Top = 0
               Left = 1006
               Bottom = 104
               Right = 1166
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
  ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0030_Branch_Master';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'       Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0030_Branch_Master';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0030_Branch_Master';

