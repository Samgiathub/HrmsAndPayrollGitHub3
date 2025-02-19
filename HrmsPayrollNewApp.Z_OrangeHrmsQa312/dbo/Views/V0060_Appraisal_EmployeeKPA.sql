


CREATE VIEW [dbo].[V0060_Appraisal_EmployeeKPA]
AS
SELECT DISTINCT dbo.T0080_EMP_MASTER.Alpha_Emp_Code, dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0080_EMP_MASTER.Emp_ID, AEK.Cmp_Id, 
				dbo.T0080_EMP_MASTER.Emp_First_Name,I.Desig_Id, I.Dept_ID, DG.Desig_Name, D.Dept_Name, AEK.Effective_Date,
				CASE WHEN IK.KPA_InitiateId > 0 THEN ISNULL(ik.Initiate_Status, 1)   else ISNULL(AEK.status, 1) end AS status
FROM            dbo.T0060_Appraisal_EmployeeKPA AEK WITH (NOLOCK)
						INNER JOIN (SELECT MAX(EMP_KPA_ID)EMP_KPA_ID,ESC.Emp_Id 
									FROM T0060_Appraisal_EmployeeKPA ESC WITH (NOLOCK)  
										INNER JOIN (SELECT MAX(Effective_date) AS Effective_date,emp_id 
														FROM T0060_Appraisal_EmployeeKPA  WITH (NOLOCK) GROUP BY emp_id
													) Qry ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id
								GROUP BY ESC.emp_id) AS QrySC ON QrySC.EMP_KPA_ID = AEK.EMP_KPA_ID
						LEFT JOIN T0055_Hrms_Initiate_KPASetting ik on ik.KPA_InitiateId= AEK.KPA_InitiateId
						LEFT JOIN (select max(Emp_KPA_Id)emp_kpa_id,KPA_InitiateId from T0060_Appraisal_EmployeeKPA group 
						 by KPA_InitiateId)AE on ae.KPA_InitiateId=AEK.KPA_InitiateId AND AE.emp_kpa_id=AEK.Emp_KPA_Id
						 INNER JOIN
                         dbo.T0080_EMP_MASTER WITH (NOLOCK) ON AEK.Emp_Id = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN
                         dbo.T0095_INCREMENT AS I WITH (NOLOCK) ON I.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID AND I.Increment_ID =
                             (SELECT        MAX(Increment_ID) AS Expr1
                               FROM            dbo.T0095_INCREMENT AS i2 WITH (NOLOCK)
                               WHERE        (Emp_ID = I.Emp_ID) AND (Increment_Effective_Date =
                                                             (SELECT        MAX(Increment_Effective_Date) AS Expr1
                                                               FROM            dbo.T0095_INCREMENT AS i3 WITH (NOLOCK)
                                                               WHERE        (Emp_ID = i2.Emp_ID)))) LEFT OUTER JOIN
                         dbo.T0040_DESIGNATION_MASTER AS DG WITH (NOLOCK) ON DG.Desig_ID = I.Desig_Id LEFT OUTER JOIN
                         dbo.T0040_DEPARTMENT_MASTER AS D WITH (NOLOCK) ON D.Dept_Id = I.Dept_ID



GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[21] 2[14] 3) )"
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
         Begin Table = "T0060_Appraisal_EmployeeKPA"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 190
               Right = 228
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 6
               Left = 266
               Bottom = 187
               Right = 510
            End
            DisplayFlags = 280
            TopColumn = 8
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
         Width = 2925
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0060_Appraisal_EmployeeKPA';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0060_Appraisal_EmployeeKPA';

