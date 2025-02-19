


CREATE VIEW [dbo].[V0100_TRAVEL_APPLICATION]
AS
SELECT  distinct   TA.Cmp_ID, TA.Emp_ID, TA.Travel_Application_ID, TA.Application_Code,isnull(TAPR.Approval_date,TA.Application_Date) as Application_Date, EM.Emp_Full_Name, 
                      SEMP.Emp_Full_Name AS Supervisor, TA.Application_Status, dbo.T0040_DESIGNATION_MASTER.Desig_Name, 
                      dbo.T0030_BRANCH_MASTER.Branch_Name, dbo.T0030_BRANCH_MASTER.Branch_ID, EM.Alpha_Emp_Code
                      ,ISNULL(TAPR.Travel_Approval_ID,0) as travel_approval_id
                     ,ISNULL(TSA.Travel_Set_Application_id,0) as travel_set_Application_id
                     ,EM.Emp_First_Name
                     ,convert(varchar(10),TA.Application_Date,103) as Application_Date_Show
                     ,isnull(Help_Desk.Cnt,0) as Cnt,Vs.Vertical_ID,sv.SubVertical_ID,em.Dept_ID                     
                     --,dbo.F_GET_Emp_Visit(TA.Cmp_ID,TA.Travel_Application_ID,1) as Emp_Visit
                      ,case when Application_Status='A' then dbo.F_GET_Emp_Visit(TA.Cmp_ID,TAPR.Travel_Application_ID,0)
						Else dbo.F_GET_Emp_Visit(TA.Cmp_ID,TA.Travel_Application_ID,1) End
                      as Emp_Visit , ta.S_Emp_ID ,DV.DynHierColValue,Isnull(TT.Travel_Type_Id,0) as Travel_Type_Id,TT.Travel_Type_Name
					  ,(select count(TravelApp_Code) from T0080_Emp_Travel_Proof where TravelApp_Code=TA.Application_Code and Cmp_Id=TA.Cmp_ID and Emp_ID=ta.Emp_ID ) as ProofCount
	FROM         dbo.T0100_TRAVEL_APPLICATION AS TA WITH (NOLOCK) INNER JOIN
					--T0110_TRAVEL_APPLICATION_DETAIL TAD on TA.Travel_Application_ID = TAD.Travel_app_id left outer join 
					T0110_TRAVEL_APPLICATION_DETAIL TAD on TA.Travel_Application_ID = TAD.Travel_app_id left join 
						T0040_Travel_Type TT on TT.Travel_Type_Id = TAD.TravelTypeId Inner join 
                      dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK)  ON TA.Emp_ID = EM.Emp_ID INNER JOIN
					
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  
					  ON dbo.T0030_BRANCH_MASTER.Branch_ID= (select top 1 Branch_ID from T0095_INCREMENT where emp_id=em.Emp_ID order by Increment_Effective_Date desc) INNER JOIN
                      --dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON EM.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID INNER JOIN
                      dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK)  ON EM.Desig_Id = dbo.T0040_DESIGNATION_MASTER.Desig_ID LEFT JOIN
                      T0040_Vertical_Segment Vs WITH (NOLOCK)  on Em.Vertical_Id=Vs.vertical_id left join
                      T0050_SubVertical sv  WITH (NOLOCK) on em.SubVertical_ID =sv.SubVertical_ID left join
                      dbo.T0080_EMP_MASTER AS SEMP  WITH (NOLOCK) ON isnull(TA.S_Emp_ID,0) = SEMP.Emp_ID 
					  Left join T0080_DynHierarchy_Value DV on  DV.DynHierColValue = SEMP.Emp_ID and ta.Emp_ID = DV.Emp_ID
					  left join T0040_DEPARTMENT_MASTER Dp WITH (NOLOCK)  on Dp.Dept_Id=Em.Dept_ID left join
                      T0120_TRAVEL_APPROVAL as TAPR WITH (NOLOCK)  ON TA.Travel_Application_ID = TAPR.Travel_Application_ID left join
                      T0140_Travel_Settlement_Application as TSA WITH (NOLOCK)  ON TAPR.Travel_Approval_ID = TSA.Travel_Approval_ID
                      left Join (Select COUNT(*) as Cnt,Travel_Approval_id,Emp_Id from T0130_TRAVEL_Help_Desk WITH (NOLOCK)  group by Travel_Approval_ID,Emp_Id ) Help_Desk on TAPR.Travel_Approval_ID = Help_Desk.Travel_Approval_ID
					  inner join T0095_EMP_SCHEME ES  on TA.Emp_ID=ES.Emp_ID
					  inner join T0050_Scheme_Detail SD on sd.Scheme_Id=es.Scheme_ID 
					  inner join T0095_INCREMENT EI on EI.Emp_ID=em.Emp_ID 
						where SD.Scheme_ID=(select top 1 Scheme_Id from T0095_EMP_SCHEME where Type='Travel' and Emp_id=ES.Emp_ID order by Effective_Date desc) 
					  and TAD.TravelTypeId!=0 or TAD.TravelTypeId!=null  
                      

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane3', @value = N'    Width = 1500
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
         Alias = 2220
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_TRAVEL_APPLICATION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 3, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_TRAVEL_APPLICATION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'80
            TopColumn = 0
         End
         Begin Table = "DV"
            Begin Extent = 
               Top = 270
               Left = 38
               Bottom = 400
               Right = 220
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Dp"
            Begin Extent = 
               Top = 270
               Left = 258
               Bottom = 400
               Right = 440
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TAPR"
            Begin Extent = 
               Top = 402
               Left = 38
               Bottom = 532
               Right = 309
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TSA"
            Begin Extent = 
               Top = 534
               Left = 38
               Bottom = 664
               Right = 285
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Help_Desk"
            Begin Extent = 
               Top = 6
               Left = 1221
               Bottom = 119
               Right = 1410
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
      Begin ColumnWidths = 104
         Width = 284
         Width = 1500
         Width = 1500
         Width = 2625
         Width = 1500
         Width = 1995
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
     ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_TRAVEL_APPLICATION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[30] 4[22] 2[17] 3) )"
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
         Begin Table = "TA"
            Begin Extent = 
               Top = 0
               Left = 312
               Bottom = 188
               Right = 498
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "EM"
            Begin Extent = 
               Top = 1
               Left = 565
               Bottom = 160
               Right = 782
            End
            DisplayFlags = 280
            TopColumn = 73
         End
         Begin Table = "T0030_BRANCH_MASTER"
            Begin Extent = 
               Top = 0
               Left = 1024
               Bottom = 115
               Right = 1183
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "T0040_DESIGNATION_MASTER"
            Begin Extent = 
               Top = 70
               Left = 849
               Bottom = 185
               Right = 1010
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Vs"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 231
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "sv"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 268
               Right = 251
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SEMP"
            Begin Extent = 
               Top = 4
               Left = 46
               Bottom = 107
               Right = 263
            End
            DisplayFlags = 2', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_TRAVEL_APPLICATION';

