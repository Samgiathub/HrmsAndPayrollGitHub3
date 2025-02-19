
  
  
  
  
  
  
  
  
  
  
  
--ALTER view [dbo].[V0100_Claim_Application_New]  
--AS  
--SELECT     dbo.T0100_CLAIM_APPLICATION.Claim_App_ID, dbo.T0100_CLAIM_APPLICATION.Cmp_ID, dbo.T0100_CLAIM_APPLICATION.Claim_ID,   
--                      dbo.T0100_CLAIM_APPLICATION.Claim_App_Date, dbo.T0100_CLAIM_APPLICATION.Claim_App_Code,   
--                      dbo.T0100_CLAIM_APPLICATION.Claim_App_Amount, dbo.T0100_CLAIM_APPLICATION.Claim_App_Description,   
--                      dbo.T0100_CLAIM_APPLICATION.Claim_App_Doc, dbo.T0100_CLAIM_APPLICATION.Claim_App_Status, dbo.T0040_CLAIM_MASTER.Claim_Name,   
--                      ISNULL(dbo.T0100_CLAIM_APPLICATION.Emp_ID, 0) AS Emp_ID, dbo.T0080_EMP_MASTER.Emp_Full_Name,   
--                      dbo.T0040_CLAIM_MASTER.Claim_Max_Limit, dbo.T0080_EMP_MASTER.Emp_First_Name, dbo.T0080_EMP_MASTER.Mobile_No,   
--                      dbo.T0080_EMP_MASTER.Other_Email, ISNULL(dbo.T0095_INCREMENT.Branch_ID, 0) AS Branch_ID, dbo.T0080_EMP_MASTER.Emp_code,   
--                      dbo.T0080_EMP_MASTER.Emp_Superior,   
--                      dbo.T0080_EMP_MASTER.Alpha_Emp_Code + ' - ' + dbo.T0080_EMP_MASTER.Emp_Full_Name AS Emp_Full_Name_New,   
--                      dbo.T0080_EMP_MASTER.Alpha_Emp_Code  
--FROM         dbo.T0100_CLAIM_APPLICATION LEFT OUTER JOIN  
--                      dbo.T0040_CLAIM_MASTER ON dbo.T0100_CLAIM_APPLICATION.Claim_ID = dbo.T0040_CLAIM_MASTER.Claim_ID LEFT OUTER JOIN  
--                      dbo.T0080_EMP_MASTER ON dbo.T0100_CLAIM_APPLICATION.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN  
--                      dbo.T0095_INCREMENT ON dbo.T0080_EMP_MASTER.Increment_ID = dbo.T0095_INCREMENT.Increment_ID  
  
  
  
--GO  
CREATE VIEW [dbo].[V0100_Claim_Application_New]  
AS  
SELECT     dbo.T0100_CLAIM_APPLICATION.Claim_App_ID, dbo.T0100_CLAIM_APPLICATION.Cmp_ID, dbo.T0100_CLAIM_APPLICATION.Claim_ID,   
                      dbo.T0100_CLAIM_APPLICATION.Claim_App_Date, dbo.T0100_CLAIM_APPLICATION.Claim_App_Code,   
                      dbo.T0100_CLAIM_APPLICATION.Claim_App_Amount, dbo.T0100_CLAIM_APPLICATION.Claim_App_Description,   
                      dbo.T0100_CLAIM_APPLICATION.Claim_App_Doc, dbo.T0100_CLAIM_APPLICATION.Claim_App_Status, --dbo.T0040_CLAIM_MASTER.Claim_Name,   
                      ISNULL(dbo.T0100_CLAIM_APPLICATION.Emp_ID, 0) AS Emp_ID, dbo.T0080_EMP_MASTER.Emp_Full_Name,   
                      dbo.T0040_CLAIM_MASTER.Claim_Max_Limit, dbo.T0080_EMP_MASTER.Emp_First_Name, dbo.T0080_EMP_MASTER.Mobile_No,   
                      dbo.T0080_EMP_MASTER.Other_Email, ISNULL(dbo.T0095_INCREMENT.Branch_ID, 0) AS Branch_ID, dbo.T0080_EMP_MASTER.Emp_code,   
                      SEMP.Emp_Full_Name as S_emp_name,dbo.T0100_CLAIM_APPLICATION.S_Emp_ID as S_emp_ID,   
                      dbo.T0080_EMP_MASTER.Alpha_Emp_Code + ' - ' + dbo.T0080_EMP_MASTER.Emp_Full_Name AS Emp_Full_Name_New,   
                      dbo.T0080_EMP_MASTER.Alpha_Emp_Code,SEMP.Emp_Full_Name as Supervisor, dbo.T0095_INCREMENT.Desig_ID,  
                      dbo.T0095_INCREMENT.Vertical_ID,dbo.T0095_INCREMENT.SubVertical_ID,  --Added By Jaina 15-09-2015  
                      case when Submit_Flag=0 then 'Submitted' else 'Drafted' End as Draft_status,  
                      Submit_Flag,dbo.T0095_INCREMENT.Dept_ID,   --Added By Jaina 12-08-2016  
                      ISNULL(dbo.T0095_INCREMENT.Grd_ID, 0) as Grd_ID,'01/01/1900' As Claim_Apr_Date,  
      ISNULL(REVERSE(STUFF(REVERSE((SELECT DISTINCT   CD.Claim_Name + ','  
                            FROM          V0100_Claim_Application_New_Detail CD WITH (NOLOCK)  
                            WHERE      CD.Claim_App_ID IN  
                                                       (SELECT     cast(data AS numeric(18, 0))  
                                                         FROM          dbo.Split(ISNULL(dbo.T0100_CLAIM_APPLICATION.Claim_App_ID, '0'), '#')  
                                                         WHERE      data <> '') FOR XML path('') )), 1, 1, '')),'') AS Claim_Name 
														,isnull(dbo.T0040_CLAIM_MASTER.Claim_Type,0) as Claim_Type  ---added by mansi for getting cl_type
FROM         dbo.T0100_CLAIM_APPLICATION WITH (NOLOCK) LEFT OUTER JOIN  
                      dbo.T0040_CLAIM_MASTER WITH (NOLOCK)  ON dbo.T0100_CLAIM_APPLICATION.Claim_ID = dbo.T0040_CLAIM_MASTER.Claim_ID LEFT OUTER JOIN  
                      dbo.T0080_EMP_MASTER AS SEMP WITH (NOLOCK)  ON dbo.T0100_CLAIM_APPLICATION.S_Emp_ID = SEMP.Emp_ID left join  
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0100_CLAIM_APPLICATION.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN  
                      dbo.T0095_INCREMENT WITH (NOLOCK)  ON dbo.T0080_EMP_MASTER.Increment_ID = dbo.T0095_INCREMENT.Increment_ID  
  
  
  
  

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
         Begin Table = "T0100_CLAIM_APPLICATION"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 228
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_CLAIM_MASTER"
            Begin Extent = 
               Top = 6
               Left = 266
               Bottom = 121
               Right = 425
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 241
               Right = 255
            End
            DisplayFlags = 280
            TopColumn = 74
         End
         Begin Table = "T0095_INCREMENT"
            Begin Extent = 
               Top = 246
               Left = 38
               Bottom = 361
               Right = 246
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
      Begin ColumnWidths = 21
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
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_Claim_Application_New';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'11
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_Claim_Application_New';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_Claim_Application_New';

