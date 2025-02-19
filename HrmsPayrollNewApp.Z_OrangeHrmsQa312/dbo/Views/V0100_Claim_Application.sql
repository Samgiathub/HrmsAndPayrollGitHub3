

CREATE VIEW [dbo].[V0100_Claim_Application]
AS
SELECT   DISTINCT   dbo.T0100_CLAIM_APPLICATION.Claim_App_ID, dbo.T0100_CLAIM_APPLICATION.Cmp_ID, dbo.T0100_CLAIM_APPLICATION.Claim_ID, 
                      dbo.T0100_CLAIM_APPLICATION.Claim_App_Date, dbo.T0100_CLAIM_APPLICATION.Claim_App_Code, dbo.T0110_CLAIM_APPLICATION_DETAIL.For_Date,
                      dbo.T0100_CLAIM_APPLICATION.Claim_App_Amount, dbo.T0100_CLAIM_APPLICATION.Claim_App_Description, 
                      dbo.T0100_CLAIM_APPLICATION.Claim_App_Doc, dbo.T0100_CLAIM_APPLICATION.Claim_App_Status, dbo.T0040_CLAIM_MASTER.Claim_Name, 
                      ISNULL(dbo.T0100_CLAIM_APPLICATION.Emp_ID, 0) AS Emp_ID, dbo.T0080_EMP_MASTER.Emp_Full_Name, 
                      dbo.T0040_CLAIM_MASTER.Claim_Max_Limit, dbo.T0080_EMP_MASTER.Emp_First_Name, dbo.T0080_EMP_MASTER.Mobile_No, 
                      dbo.T0080_EMP_MASTER.Work_Email, dbo.T0080_EMP_MASTER.Other_Email, ISNULL(dbo.T0095_INCREMENT.Branch_ID, 0) AS Branch_ID, 
                      dbo.T0080_EMP_MASTER.Emp_code, dbo.T0080_EMP_MASTER.Emp_Superior,0 AS R_EMP_ID, -- dbo.T0090_EMP_REPORTING_DETAIL.R_Emp_ID,
                      SEMP.Emp_Full_Name as Supervisor,dbo.T0030_BRANCH_MASTER.Branch_Name,dbo.T0040_DESIGNATION_MASTER.Desig_Name,
                      dbo.T0080_EMP_MASTER.Alpha_Emp_Code,ISNULL(CAPR.Claim_Apr_ID,0) as Claim_approval_id,dbo.T0040_CLAIM_MASTER.Desig_Wise_Limit,
                      dbo.T0040_DESIGNATION_MASTER.Desig_ID,
                      dbo.T0100_CLAIM_APPLICATION.Submit_Flag,ISNULL(dbo.T0095_INCREMENT.Grd_ID, 0) AS Grd_ID,isnull(dbo.T0040_CLAIM_MASTER.Claim_Limit_Type,0) as Claim_Limit_Type, -- GRADE ID ADDED BY RAJPUT ON 07032018
					  dbo.T0080_EMP_MASTER.Date_Of_Join,isnull(Dept_Name,'') as Dept_Name,
					  dbo.T0040_GRADE_MASTER.Grd_Name as Grade_Name,
					  isnull(Terms_isAccepted,0) as Terms_isAccepted,
					  CASE WHEN Submit_Flag = 1 THEN isnull(Claim_TermsCondition,Claim_Terms_Condition) else isnull(Claim_TermsCondition,'') END as Claim_TermsCondition,
					  isnull(T0110_CLAIM_APPLICATION_DETAIL.Claim_Date_Label,'') as Claim_Date_Label
FROM         dbo.T0100_CLAIM_APPLICATION WITH (NOLOCK) LEFT OUTER JOIN
					  dbo.T0040_CLAIM_MASTER  WITH (NOLOCK) ON dbo.T0100_CLAIM_APPLICATION.Claim_ID = dbo.T0040_CLAIM_MASTER.Claim_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER  WITH (NOLOCK) ON dbo.T0100_CLAIM_APPLICATION.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN
                      dbo.T0030_BRANCH_MASTER  WITH (NOLOCK) ON dbo.T0080_EMP_MASTER.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID left join
                      dbo.T0040_DESIGNATION_MASTER  WITH (NOLOCK) ON dbo.T0080_EMP_MASTER.Desig_Id = dbo.T0040_DESIGNATION_MASTER.Desig_ID LEFT OUTER JOIN
					  dbo.T0040_DEPARTMENT_MASTER  WITH (NOLOCK) ON dbo.T0080_EMP_MASTER.Dept_Id = dbo.T0040_DEPARTMENT_MASTER.Dept_Id LEFT OUTER JOIN					
                      dbo.T0095_INCREMENT  WITH (NOLOCK) ON dbo.T0080_EMP_MASTER.Increment_ID = dbo.T0095_INCREMENT.Increment_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER SEMP  WITH (NOLOCK) on dbo.T0100_CLAIM_APPLICATION.S_Emp_ID=SEMP.Emp_ID left outer join 
                      T0120_CLAIM_APPROVAL as CAPR  WITH (NOLOCK) ON dbo.T0100_CLAIM_APPLICATION.Claim_App_ID = CAPR.Claim_App_ID left outer join
                      dbo.T0090_EMP_REPORTING_DETAIL  WITH (NOLOCK) ON dbo.T0080_EMP_MASTER.Emp_ID = dbo.T0090_EMP_REPORTING_DETAIL.Emp_ID AND 
                      dbo.T0080_EMP_MASTER.Emp_ID = dbo.T0090_EMP_REPORTING_DETAIL.Emp_ID left outer join
					  dbo.T0040_GRADE_MASTER WITH (NOLOCK)  ON dbo.T0095_INCREMENT.Grd_ID = dbo.T0040_GRADE_MASTER.Grd_ID LEFT OUTER JOIN
					  dbo.T0110_CLAIM_APPLICATION_DETAIL on dbo.T0110_CLAIM_APPLICATION_DETAIL.Claim_App_ID = dbo.T0100_CLAIM_APPLICATION.Claim_App_ID 
					  





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
            TopColumn = 0
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
         Begin Table = "T0090_EMP_REPORTING_DETAIL"
            Begin Extent = 
               Top = 126
               Left = 293
               Bottom = 241
               Right = 463
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
      Begin ColumnWidths = 22
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
         Width = 1500', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_Claim_Application';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_Claim_Application';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_Claim_Application';

