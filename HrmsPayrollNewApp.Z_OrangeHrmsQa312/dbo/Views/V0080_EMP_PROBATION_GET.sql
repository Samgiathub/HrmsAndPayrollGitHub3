


CREATE  VIEW [dbo].[V0080_EMP_PROBATION_GET]
AS
--changed by deepali - Bug 30050
SELECT 	 CASE WHEN ISNULL(e.Probation,0) > 0 THEN 
			  CASE WHEN E.Is_Probation_Month_Days=0 THEN
				  CASE WHEN Probation_Review='Quarterly' THEN ISNULL(emp_probation.New_Probation_EndDate, DATEADD(dd, 0, DATEADD(mm,3, e.Date_Of_Join))) 
					   WHEN Probation_Review='Six Monthly' THEN ISNULL(emp_probation.New_Probation_EndDate, DATEADD(dd, 0, DATEADD(mm,6, e.Date_Of_Join))) 
					   WHEN Probation_Review='' then ISNULL(emp_probation.New_Probation_EndDate, DATEADD(dd, 0, DATEADD(mm, E.Probation, e.Date_Of_Join))) 
				  END
		      ELSE ISNULL(emp_probation.New_Probation_EndDate, DATEADD(dd, 0, DATEADD(DAY, E.Probation, e.Date_Of_Join))) 
		    END		     
		 ELSE 
			 CASE WHEN QRY.Is_Probation_Month_Days=0 THEN
				  CASE WHEN Probation_Review='Quarterly' THEN ISNULL(emp_probation.New_Probation_EndDate, DATEADD(dd, 0, DATEADD(mm,3, e.Date_Of_Join))) 
					   WHEN Probation_Review='Six Monthly' THEN ISNULL(emp_probation.New_Probation_EndDate, DATEADD(dd, 0, DATEADD(mm,6, e.Date_Of_Join))) 
					   WHEN ISNULL(Probation_Review,'')='' then ISNULL(emp_probation.New_Probation_EndDate, DATEADD(dd, 0, DATEADD(mm, qry.Probation, e.Date_Of_Join)))
				  END
			-- ELSE ISNULL(emp_probation.New_Probation_EndDate, DATEADD(dd, - 1, DATEADD(DAY, qry.Probation, e.Date_Of_Join))) END 	
			 			 ELSE ISNULL(emp_probation.New_Probation_EndDate, DATEADD(dd, 0, DATEADD(DAY, qry.Probation, e.Date_Of_Join))) END 			--changed by deepali - Bug 30050
         END AS probation_date, 	
		 e.Alpha_Emp_Code,e.Emp_Full_Name, e.Date_Of_Join, 
		 CASE WHEN ISNULL(e.Probation,0) > 0 THEN e.Probation ELSE QRY.Probation END AS Probation,
		 dbo.T0030_BRANCH_MASTER.Branch_Name, dbo.T0040_DEPARTMENT_MASTER.Dept_Name, 
		 dbo.T0040_DESIGNATION_MASTER.Desig_Name, i.Emp_ID, i.Cmp_ID, i.Branch_ID, i.Cat_ID, i.Grd_ID, ISNULL(i.Dept_ID,0)as Dept_ID, i.Desig_Id, i.Type_ID, e.Emp_Left, 
		 e.Is_On_Probation, emp_probation.New_Probation_EndDate, ISNULL(emp_probation.Old_Probation_Period + emp_probation.Extend_Period, qry.Probation) 
		 AS New_Prob_period,e.Work_Email,'PROBATION' AS Flag, e.Emp_First_Name , dbo.T0040_GRADE_MASTER.Grd_Name,TM.Type_Name,emp_probation.Emp_Type_Id,
		 Qry.Probation_Review,'' AS Training_ID,emp_probation.Approval_Period_Type,
		 CASE WHEN ISNULL(e.Probation,0) > 0 THEN e.Is_Probation_Month_Days else Qry.Is_Probation_Month_Days END AS Is_Probation_Month_Days,'' as Attach_Docs,emp_probation.Confirmation_date		 		  
FROM         dbo.T0080_EMP_MASTER AS e WITH (NOLOCK)  INNER JOIN
                      dbo.T0095_INCREMENT AS i WITH (NOLOCK)  ON e.Increment_ID = i.Increment_ID INNER JOIN
                      (Select Probation, G.Branch_Id,G.Probation_Review,Is_Probation_Month_Days,G.Cmp_ID From T0040_General_Setting G WITH (NOLOCK)  Inner Join
                          (SELECT     MAX(For_Date) AS for_date, Branch_ID
                            FROM          dbo.T0040_GENERAL_SETTING AS gs WITH (NOLOCK) 
                            GROUP BY Branch_ID) AS qry1 ON qry1.Branch_ID = g.Branch_ID and qry1.For_Date=G.For_Date) As Qry on Qry.Branch_ID = i.Branch_ID and Qry.cmp_id=e.Cmp_ID LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON i.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID LEFT OUTER JOIN
                      dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK)  ON i.Dept_ID = dbo.T0040_DEPARTMENT_MASTER.Dept_Id LEFT OUTER JOIN
                      dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK)  ON i.Desig_Id = dbo.T0040_DESIGNATION_MASTER.Desig_ID LEFT OUTER JOIN
                      dbo.T0040_GRADE_MASTER WITH (NOLOCK)  ON i.Grd_ID = dbo.T0040_GRADE_MASTER.Grd_ID LEFT OUTER JOIN
                      dbo.T0040_TYPE_MASTER TM WITH (NOLOCK)  ON i.Type_ID = TM.Type_ID LEFT OUTER JOIN	
                          (SELECT     Probation_Evaluation_ID, Emp_ID, Cmp_ID, Probation_Status, Evaluation_Date, Extend_Period, Old_Probation_Period, New_Probation_EndDate, 
                                                   Major_Strength, Major_Weakness, Appraiser_Remarks, Appraisal_Reviewer_Remarks, Supervisor_ID,Emp_Type_Id,Training_ID,Approval_Period_Type,Confirmation_date
                            FROM          dbo.T0095_EMP_PROBATION_MASTER WITH (NOLOCK) 
                            WHERE      (Probation_Evaluation_ID IN
                                                       (SELECT     MAX(Probation_Evaluation_ID) AS Expr1
                                                         FROM          dbo.T0095_EMP_PROBATION_MASTER AS T0095_EMP_PROBATION_MASTER_1 WITH (NOLOCK) 
                                                         GROUP BY Emp_ID))) AS emp_probation ON emp_probation.Emp_ID = e.Emp_ID
WHERE     ((e.Is_On_Probation = 1)OR emp_probation.Approval_Period_Type='Confirm') and e.Emp_Left='N'




















GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[11] 2[12] 3) )"
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
         Begin Table = "e"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 263
            End
            DisplayFlags = 280
            TopColumn = 63
         End
         Begin Table = "i"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 245
               Right = 254
            End
            DisplayFlags = 280
            TopColumn = 32
         End
         Begin Table = "qry"
            Begin Extent = 
               Top = 24
               Left = 758
               Bottom = 128
               Right = 918
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0030_BRANCH_MASTER"
            Begin Extent = 
               Top = 17
               Left = 381
               Bottom = 136
               Right = 548
            End
            DisplayFlags = 280
            TopColumn = 2
         End
         Begin Table = "T0040_DEPARTMENT_MASTER"
            Begin Extent = 
               Top = 143
               Left = 734
               Bottom = 262
               Right = 894
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_DESIGNATION_MASTER"
            Begin Extent = 
               Top = 111
               Left = 980
               Bottom = 230
               Right = 1149
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "emp_probation"
            Begin Extent = 
               Top = 138
               Left = 292
               Bottom = 257
               Right = 523
         ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0080_EMP_PROBATION_GET';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'   End
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
         Width = 1995
         Width = 1725
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 2355
         Width = 2445
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
         Width = 1995
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0080_EMP_PROBATION_GET';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0080_EMP_PROBATION_GET';

