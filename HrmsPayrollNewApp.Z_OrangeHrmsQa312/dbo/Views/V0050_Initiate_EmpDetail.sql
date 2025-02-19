
CREATE VIEW [dbo].[V0050_Initiate_EmpDetail]
AS
SELECT DISTINCT 
                      HI.InitiateId, HI.Cmp_ID, HI.Emp_Id, 
                      HI.AppraiserId, HI.SA_Startdate, HI.SA_EmpComments, 
                      HI.SA_Enddate, HI.SA_AppComments, HI.SA_Status, 
                      HI.KPA_Score, HI.KPA_Final, HI.SA_SubmissionDate, 
                      HI.SA_ApprovedDate, HI.PF_Final, HI.PO_Score, 
                      HI.PF_Score, HI.PO_Final, HI.Overall_Score, 
                      HI.Achivement_Id, HI.AppraiserComment, HI.Promo_YesNo, 
                      HI.Promo_Desig, HI.Promo_Wef, HI.JR_YesNo, 
                      HI.JR_From, HI.JR_To, HI.Inc_YesNo, 
                      HI.Inc_Reason, HI.ReviewerComment, HI.Appraiser_Date, 
                      HI.SA_ApprovedBy, HI.Per_ApprovedBy, HI.Overall_Status, 
                      HI.GH_Comment, dbo.T0080_EMP_MASTER.Emp_ID AS Expr1, dbo.T0080_EMP_MASTER.Date_Of_Join, 
                      dbo.T0080_EMP_MASTER.Work_Email, dbo.T0080_EMP_MASTER.Emp_Full_Name, ERD.R_Emp_ID, dbo.T0080_EMP_MASTER.Old_Ref_No, 
                      dbo.T0080_EMP_MASTER.Alpha_Emp_Code, D.Dept_Name, desi.Desig_Name,
                      case when ISNULL(HI.Rm_Required, 1)=1 then ISNULL(E1.Alpha_Emp_Code + '-' + E1.Emp_Full_Name, '') 
                      else '' end AS Superior, 
                      case when ISNULL(HI.Rm_Required, 1)=1 then E1.Emp_ID else 0 end AS Superior_ID, 
                      R.Range_Level, dbo.T0080_EMP_MASTER.Dept_ID, G.Grd_ID, G.Grd_Name, HI.SendToHOD, 
                      HI.HOD_ApprovedBy, HI.HOD_Id, HI.GH_Id, 
                      ISNULL(HI.Rm_Required, 1) AS Rm_Required,
					  --CASE WHEN isnull(HOD_Id, 0) = 0 AND isnull(GH_Id, 0)= 0 THEN 'RM' WHEN ISNULL(HOD_Id, 0) <> 0 AND ISNULL(GH_Id, 0) = 0 
					  --THEN 'HOD' WHEN ISNULL(GH_Id, 0) <> 0 THEN 'GH' END AS 'ApprovalStatus'
                      case when ISNULL(Final_Evaluation,1)=0 then 'Intrim' else 'Final' end as [Review_Type],T0080_EMP_MASTER.Emp_Left,
					  dbo.F_GET_MONTH_NAME(Duration_FromMonth)Duration_FromMonth,dbo.F_GET_MONTH_NAME(Duration_ToMonth)Duration_ToMonth,
		 			  CASE		WHEN HI.SA_STATUS=4 THEN 'Self Assessment Not Submitted'
								WHEN HI.SA_STATUS=3 THEN 'Self Assessment Draft By Employee' 
								WHEN HI.SA_STATUS=0 THEN 'Self Assessment Submitted' 
								WHEN HI.SA_STATUS=2 THEN 'Self Assessment Sent Back For Review' 
								WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS IS NULL THEN 'Self Assessment Approved By RM' 
								WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS =1  THEN 'Approved By GH'
								WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS =2  THEN 'Sent For RM Review' 
								WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS =3  THEN 'Sent For Final Approval' 
								WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS =4  THEN 'Sent For GH Review' 
								WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS =6  THEN 'Approved By HOD' 
								WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS =7  THEN 'Sent For GH Approval BY HOD/Approved BY HOD'
								WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS =5 and ISNULL(HI.Emp_Engagement_Comment,'') <> '' THEN 'Approved and Completed Closing Loop'
								WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS =5  THEN 'Completed' 
								WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS =0  THEN 'Performance Assessment Approved' 
								WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS =8  THEN 'Performance Assessment Sent For Review' 
								WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS =9  THEN 'Draft BY RM' 
								WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS =10 THEN 'Draft BY HOD'
								WHEN HI.SA_STATUS=1 AND HI.OVERALL_STATUS =11  THEN 'Draft BY GH' 										
							END AS 'ApprovalStatus'
FROM      T0050_HRMS_InitiateAppraisal HI WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER  WITH (NOLOCK) ON HI.Emp_Id = dbo.T0080_EMP_MASTER.Emp_ID LEFT OUTER JOIN
                      dbo.T0040_DEPARTMENT_MASTER AS D  WITH (NOLOCK) ON D.Dept_Id = dbo.T0080_EMP_MASTER.Dept_ID LEFT OUTER JOIN
                      dbo.T0040_DESIGNATION_MASTER AS desi  WITH (NOLOCK) ON desi.Desig_ID = dbo.T0080_EMP_MASTER.Desig_Id                       
                      LEFT OUTER JOIN (
							select	R.EMP_ID,R.R_EMP_ID 
							FROM	T0090_EMP_REPORTING_DETAIL R WITH (NOLOCK) 
									INNER JOIN (SELECT	MAX(R1.ROW_ID) AS ROW_ID, R1.EMP_ID
												FROM	T0090_EMP_REPORTING_DETAIL R1 WITH (NOLOCK) 
														INNER JOIN (SELECT	MAX(R2.EFFECT_DATE) AS EFFECT_DATE, R2.EMP_ID
																	FROM	T0090_EMP_REPORTING_DETAIL R2 WITH (NOLOCK) 
																	INNER JOIN T0050_HRMS_InitiateAppraisal HI  WITH (NOLOCK) ON R2.Emp_ID = HI.Emp_Id AND 
                                                                    R2.Effect_Date <= HI.SA_Enddate
																	GROUP	BY R2.EMP_ID
																	) R2 ON R1.Emp_ID=R2.Emp_ID AND R1.Effect_Date=R2.EFFECT_DATE
												GROUP BY R1.Emp_ID) R1 ON R.Emp_ID=R1.Emp_ID AND R.Row_ID=R1.ROW_ID
							) ERD ON HI.EMP_ID=ERD.EMP_ID LEFT OUTER JOIN
						  --dbo.T0090_EMP_REPORTING_DETAIL AS ERD ON ERD.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID 
                          --(SELECT     MAX(dbo.T0090_EMP_REPORTING_DETAIL.Row_ID) AS Row_ID, dbo.T0090_EMP_REPORTING_DETAIL.Emp_ID
                          --  FROM          dbo.T0090_EMP_REPORTING_DETAIL INNER JOIN
                          --                             (SELECT     MAX(T0090_EMP_REPORTING_DETAIL_1.Effect_Date) AS Effect_Date, T0090_EMP_REPORTING_DETAIL_1.Emp_ID
                          --                               FROM          dbo.T0090_EMP_REPORTING_DETAIL AS T0090_EMP_REPORTING_DETAIL_1 INNER JOIN
                          --                                                      HI AS T0050_HRMS_InitiateAppraisal_1 ON 
                          --                                                      T0050_HRMS_InitiateAppraisal_1.Emp_Id = T0090_EMP_REPORTING_DETAIL_1.Emp_ID AND 
                          --                                                      T0090_EMP_REPORTING_DETAIL_1.Effect_Date <= T0050_HRMS_InitiateAppraisal_1.SA_Startdate
                          --                               GROUP BY T0090_EMP_REPORTING_DETAIL_1.Emp_ID) AS ERD2 ON ERD2.Emp_ID = dbo.T0090_EMP_REPORTING_DETAIL.Emp_ID
                          --  GROUP BY dbo.T0090_EMP_REPORTING_DETAIL.Emp_ID) AS ERD1 ON ERD.Row_ID = ERD1.Row_ID AND ERD.Emp_ID = ERD1.Emp_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS E1  WITH (NOLOCK) ON E1.Emp_ID = ERD.R_Emp_ID LEFT OUTER JOIN
                      dbo.T0040_HRMS_RangeMaster AS R  WITH (NOLOCK) ON R.Range_ID = HI.Achivement_Id LEFT OUTER JOIN
                      dbo.T0040_GRADE_MASTER AS G  WITH (NOLOCK) ON G.Grd_ID = dbo.T0080_EMP_MASTER.Grd_ID



GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N' 280
            TopColumn = 0
         End
         Begin Table = "G"
            Begin Extent = 
               Top = 252
               Left = 38
               Bottom = 371
               Right = 249
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
      Begin ColumnWidths = 46
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
         SortOrder = 1260
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0050_Initiate_EmpDetail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0050_Initiate_EmpDetail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[35] 4[18] 2[36] 3) )"
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
               Top = 12
               Left = 84
               Bottom = 131
               Right = 267
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 0
               Left = 303
               Bottom = 119
               Right = 547
            End
            DisplayFlags = 280
            TopColumn = 78
         End
         Begin Table = "D"
            Begin Extent = 
               Top = 0
               Left = 573
               Bottom = 119
               Right = 733
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "desi"
            Begin Extent = 
               Top = 6
               Left = 783
               Bottom = 125
               Right = 952
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ERD"
            Begin Extent = 
               Top = 132
               Left = 38
               Bottom = 251
               Right = 216
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "E1"
            Begin Extent = 
               Top = 6
               Left = 990
               Bottom = 125
               Right = 1236
            End
            DisplayFlags = 280
            TopColumn = 71
         End
         Begin Table = "R"
            Begin Extent = 
               Top = 132
               Left = 254
               Bottom = 251
               Right = 461
            End
            DisplayFlags =', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0050_Initiate_EmpDetail';

