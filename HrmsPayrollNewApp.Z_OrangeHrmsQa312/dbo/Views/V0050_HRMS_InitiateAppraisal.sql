


CREATE  VIEW [dbo].[V0050_HRMS_InitiateAppraisal]
AS
SELECT     dbo.T0050_HRMS_InitiateAppraisal.InitiateId, dbo.T0050_HRMS_InitiateAppraisal.Cmp_ID, dbo.T0050_HRMS_InitiateAppraisal.Emp_Id, 
                      dbo.T0050_HRMS_InitiateAppraisal.AppraiserId, dbo.T0050_HRMS_InitiateAppraisal.SA_Startdate, dbo.T0050_HRMS_InitiateAppraisal.SA_Enddate, 
                      dbo.T0050_HRMS_InitiateAppraisal.SA_EmpComments, dbo.T0050_HRMS_InitiateAppraisal.SA_AppComments, dbo.T0050_HRMS_InitiateAppraisal.SA_Status, 
                      T0080_EMP_MASTER_2.Alpha_Emp_Code, T0080_EMP_MASTER_2.Emp_Full_Name, T0080_EMP_MASTER_1.Alpha_Emp_Code AS appraiser_code, 
                      T0080_EMP_MASTER_1.Emp_Full_Name AS appraiser_name, dbo.T0050_HRMS_InitiateAppraisal.SA_SubmissionDate, 
                      dbo.T0050_HRMS_InitiateAppraisal.SA_ApprovedDate, dbo.T0050_HRMS_InitiateAppraisal.SA_ApprovedBy, 
                      T0080_EMP_MASTER_3.Emp_Full_Name AS Approved_Name, T0080_EMP_MASTER_3.Alpha_Emp_Code AS ApprovedCode, T0080_EMP_MASTER_2.Emp_Superior, 
                      T0080_EMP_MASTER_1.Emp_Full_Name AS Expr1, ISNULL(T0080_EMP_MASTER_1.Alpha_Emp_Code + '-' + T0080_EMP_MASTER_1.Emp_Full_Name, 'Admin') 
                      AS appraiser, ISNULL(T0080_EMP_MASTER_3.Alpha_Emp_Code + '-' + T0080_EMP_MASTER_3.Emp_Full_Name, 'Admin') AS approvedby, 
                      dbo.T0050_HRMS_InitiateAppraisal.Overall_Score,
                      ISNULL(dbo.T0050_HRMS_InitiateAppraisal.Overall_Score_HOD,0)Overall_Score_HOD,
                      ISNULL(dbo.T0050_HRMS_InitiateAppraisal.Overall_Score_RM,0)Overall_Score_RM,
                      ISNULL(dbo.T0050_HRMS_InitiateAppraisal.Overall_Score,0)Overall_Score_GH,
                      T0080_EMP_MASTER_2.Old_Ref_No, dbo.T0050_HRMS_InitiateAppraisal.Overall_Status, 
                      dbo.T0050_HRMS_InitiateAppraisal.Per_ApprovedBy, dbo.T0050_HRMS_InitiateAppraisal.Appraiser_Date, 
                      dbo.T0080_EMP_MASTER.Emp_Full_Name AS PerApprovedName, dbo.T0080_EMP_MASTER.Alpha_Emp_Code AS PerApprovedCode, 
                      ISNULL(dbo.T0080_EMP_MASTER.Alpha_Emp_Code + '-' + dbo.T0080_EMP_MASTER.Emp_Full_Name, 'Admin') AS PerApprovedBy, 
                      dbo.T0050_HRMS_InitiateAppraisal.Achivement_Id, dbo.T0040_HRMS_RangeMaster.Range_Level, Dept.Dept_Name, Desig.Desig_Name, Grade.Grd_Name, 
                      T0095_INCREMENT.Dept_ID, dbo.T0050_HRMS_InitiateAppraisal.SA_SendToRM, T0095_INCREMENT.Grd_ID, dbo.T0050_HRMS_InitiateAppraisal.Promo_Desig, 
                      dbo.T0050_HRMS_InitiateAppraisal.SendToHOD, dbo.T0050_HRMS_InitiateAppraisal.HOD_ApprovedBy, dbo.T0050_HRMS_InitiateAppraisal.HOD_ApprovedOn, 
                      dbo.T0050_HRMS_InitiateAppraisal.HOD_Id, dbo.T0050_HRMS_InitiateAppraisal.DirectScore, T0095_INCREMENT.Desig_Id, T0095_INCREMENT.Branch_ID, 
                      T0095_INCREMENT.Cat_ID, T0095_INCREMENT.Type_ID, dbo.T0050_HRMS_InitiateAppraisal.Duration_FromMonth, 
                      dbo.T0050_HRMS_InitiateAppraisal.Duration_ToMonth, dbo.T0050_HRMS_InitiateAppraisal.Promo_Grade, dbo.T0050_HRMS_InitiateAppraisal.Financial_Year, 
                      dbo.T0050_HRMS_InitiateAppraisal.Final_Evaluation, dbo.T0050_HRMS_InitiateAppraisal.Promo_YesNo, dbo.T0050_HRMS_InitiateAppraisal.Promo_Wef, 
                      dbo.T0050_HRMS_InitiateAppraisal.JR_YesNo, dbo.T0050_HRMS_InitiateAppraisal.GH_Id, ISNULL(dbo.T0050_HRMS_InitiateAppraisal.Rm_Required, 1) 
                      AS Rm_Required,case when ISNULL(Final_Evaluation,1)=0 then 'Interim' else 'Final' end as [Review_Type],T0080_EMP_MASTER_2.Emp_Left,
                      isnull(Emp_Engagement,0)Emp_Engagement,isnull(Emp_Engagement_Comment,'')Emp_Engagement_Comment,ISNULL(Achivement_Id_RM,0)Achivement_Id_RM,
                      ISNULL(Achivement_Id_HOD,0)Achivement_Id_HOD,ISNULL(Achivement_Id_GH,0)Achivement_Id_GH ,
					  dbo.F_GET_MONTH_NAME(Duration_FromMonth)Duration_From_Month,dbo.F_GET_MONTH_NAME(Duration_ToMonth)Duration_To_Month,
					  isnull(Send_directly_Performance_Assessment,0)Send_directly_Performance_Assessment,
					  dbo.T0050_HRMS_InitiateAppraisal.AppraiserComment  --added  by Deepali 06092023
FROM         dbo.T0050_HRMS_InitiateAppraisal WITH (NOLOCK)  LEFT OUTER JOIN
                      dbo.T0040_HRMS_RangeMaster WITH (NOLOCK)  ON dbo.T0050_HRMS_InitiateAppraisal.Achivement_Id = dbo.T0040_HRMS_RangeMaster.Range_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER  WITH (NOLOCK) ON dbo.T0050_HRMS_InitiateAppraisal.Per_ApprovedBy = dbo.T0080_EMP_MASTER.Emp_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS T0080_EMP_MASTER_3 WITH (NOLOCK)  ON dbo.T0050_HRMS_InitiateAppraisal.SA_ApprovedBy = T0080_EMP_MASTER_3.Emp_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS T0080_EMP_MASTER_2 WITH (NOLOCK)  ON dbo.T0050_HRMS_InitiateAppraisal.Emp_Id = T0080_EMP_MASTER_2.Emp_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS T0080_EMP_MASTER_1 WITH (NOLOCK)  ON dbo.T0050_HRMS_InitiateAppraisal.AppraiserId = T0080_EMP_MASTER_1.Emp_ID LEFT OUTER JOIN
                      dbo.T0095_INCREMENT AS T0095_INCREMENT WITH (NOLOCK)  ON T0095_INCREMENT.Emp_ID = T0080_EMP_MASTER_2.Emp_ID AND T0095_INCREMENT.Increment_ID =
                          (SELECT     MAX(Increment_ID) AS Expr1
                            FROM          dbo.T0095_INCREMENT WITH (NOLOCK) 
                            WHERE      (Emp_ID = T0080_EMP_MASTER_2.Emp_ID)) LEFT OUTER JOIN
                      dbo.T0040_DEPARTMENT_MASTER AS Dept WITH (NOLOCK)  ON Dept.Dept_Id = T0095_INCREMENT.Dept_ID LEFT OUTER JOIN
                      dbo.T0040_DESIGNATION_MASTER AS Desig WITH (NOLOCK)  ON Desig.Desig_ID = T0095_INCREMENT.Desig_Id LEFT OUTER JOIN
                      dbo.T0040_GRADE_MASTER AS Grade WITH (NOLOCK)  ON Grade.Grd_ID = T0095_INCREMENT.Grd_ID



GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[39] 4[10] 2[26] 3) )"
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
         Begin Table = "T0050_HRMS_InitiateAppraisal"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 216
            End
            DisplayFlags = 280
            TopColumn = 18
         End
         Begin Table = "T0040_HRMS_RangeMaster"
            Begin Extent = 
               Top = 6
               Left = 254
               Bottom = 125
               Right = 461
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 111
               Left = 325
               Bottom = 230
               Right = 569
            End
            DisplayFlags = 280
            TopColumn = 77
         End
         Begin Table = "T0080_EMP_MASTER_3"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 245
               Right = 282
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0080_EMP_MASTER_2"
            Begin Extent = 
               Top = 13
               Left = 532
               Bottom = 132
               Right = 776
            End
            DisplayFlags = 280
            TopColumn = 37
         End
         Begin Table = "T0080_EMP_MASTER_1"
            Begin Extent = 
               Top = 41
               Left = 593
               Bottom = 160
               Right = 837
            End
            DisplayFlags = 280
            TopColumn = 86
         End
         Begin Table = "Dept"
            Begin Extent = 
               Top = 246
               Left = 38
               Bottom = 365', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0050_HRMS_InitiateAppraisal';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'
               Right = 198
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Desig"
            Begin Extent = 
               Top = 246
               Left = 236
               Bottom = 365
               Right = 405
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Grade"
            Begin Extent = 
               Top = 366
               Left = 38
               Bottom = 485
               Right = 221
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
      Begin ColumnWidths = 40
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0050_HRMS_InitiateAppraisal';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0050_HRMS_InitiateAppraisal';

