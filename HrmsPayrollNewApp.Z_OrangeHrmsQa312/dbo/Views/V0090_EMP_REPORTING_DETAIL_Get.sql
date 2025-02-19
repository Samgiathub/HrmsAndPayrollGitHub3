





CREATE VIEW [dbo].[V0090_EMP_REPORTING_DETAIL_Get]
AS

SELECT    distinct dbo.T0090_EMP_REPORTING_DETAIL.Row_ID, dbo.T0090_EMP_REPORTING_DETAIL.Emp_ID, dbo.T0090_EMP_REPORTING_DETAIL.R_Emp_ID, 
                         dbo.T0090_EMP_REPORTING_DETAIL.Cmp_ID, 
                         CASE WHEN dbo.T0090_EMP_REPORTING_DETAIL.Reporting_To = 'Supervisor' THEN 'Manager' ELSE dbo.T0090_EMP_REPORTING_DETAIL.Reporting_To END
                          AS Reporting_To, dbo.T0090_EMP_REPORTING_DETAIL.Reporting_Method, T0080_EMP_MASTER_1.Alpha_Emp_Code, 
                         T0080_EMP_MASTER_1.Emp_Full_Name, CAST(dbo.T0080_EMP_MASTER.Alpha_Emp_Code AS varchar(15)) 
                         + ' - ' + dbo.T0080_EMP_MASTER.Emp_Full_Name AS R_Emp_Full_Name, dbo.T0080_EMP_MASTER.Branch_ID, CAST(dbo.T0080_EMP_MASTER.Alpha_Emp_Code AS varchar(15)) as R_Emp_Alpha_Code,
                         dbo.T0030_BRANCH_MASTER.Branch_Name, CAST(T0080_EMP_MASTER_1.Date_Of_Join AS varchar(11)) AS Date_Of_Join, 
                         dbo.T0010_COMPANY_MASTER.Cmp_Name AS E_Cmp, T0010_COMPANY_MASTER_R.Cmp_Name, 
                         dbo.T0040_DESIGNATION_MASTER.Desig_Name AS Reporting_manager_Designation,
                         --CAST(dbo.T0090_EMP_REPORTING_DETAIL.Effect_Date As Varchar(11)) AS Effect_Date,
                         CONVERT(varchar(11), dbo.T0090_EMP_REPORTING_DETAIL.Effect_Date, 103) AS Effect_Date,
						dbo.T0090_EMP_REPORTING_DETAIL.Effect_Date as Effect_Date_Order
FROM            dbo.T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
				INNER JOIN dbo.T0080_EMP_MASTER WITH (NOLOCK) ON dbo.T0090_EMP_REPORTING_DETAIL.R_Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID 
				INNER JOIN dbo.T0080_EMP_MASTER AS T0080_EMP_MASTER_1 WITH (NOLOCK) ON dbo.T0090_EMP_REPORTING_DETAIL.Emp_ID = T0080_EMP_MASTER_1.Emp_ID 
				INNER JOIN (
								SELECT        Increment_ID, Emp_ID, Cmp_ID, Branch_ID, Cat_ID, Grd_ID, Dept_ID, Desig_Id, Type_ID, Bank_ID, Curr_ID, Wages_Type, Salary_Basis_On, 
                                                         Basic_Salary, Gross_Salary, Increment_Type, Increment_Date, Increment_Effective_Date, Payment_Mode, Inc_Bank_AC_No, Emp_OT, 
                                                         Emp_OT_Min_Limit, Emp_OT_Max_Limit, Increment_Per, Increment_Amount, Pre_Basic_Salary, Pre_Gross_Salary, Increment_Comments, 
                                                         Emp_Late_mark, Emp_Full_PF, Emp_PT, Emp_Fix_Salary, Emp_Part_Time, Late_Dedu_Type, Emp_Late_Limit, Emp_PT_Amount, 
                                                         Emp_Childran, Is_Master_Rec, Login_ID, System_Date, Yearly_Bonus_Amount, Deputation_End_Date, Is_Deputation_Reminder, Appr_Int_ID, 
                                                         CTC, Emp_Early_mark, Early_Dedu_Type, Emp_Early_Limit, Emp_Deficit_mark, Deficit_Dedu_Type, Emp_Deficit_Limit, Center_ID, 
                                                         Emp_WeekDay_OT_Rate, Emp_WeekOff_OT_Rate, Emp_Holiday_OT_Rate, Vertical_ID, SubVertical_ID
                               FROM            dbo.T0095_INCREMENT AS SInc WITH (NOLOCK)
                               WHERE        (Increment_Effective_Date =
                                                             (SELECT        MAX(Increment_Effective_Date) AS For_Date
                                                               FROM            dbo.T0095_INCREMENT AS ssInc WITH (NOLOCK)
                                                               WHERE        (Emp_ID = SInc.Emp_ID)
                                                               GROUP BY Emp_ID))
                            ) AS Qry ON T0080_EMP_MASTER_1.Emp_ID = Qry.Emp_ID 
				INNER JOIN dbo.T0030_BRANCH_MASTER WITH (NOLOCK) ON dbo.T0080_EMP_MASTER.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID 
				INNER JOIN dbo.T0010_COMPANY_MASTER WITH (NOLOCK) ON T0080_EMP_MASTER_1.Cmp_ID = dbo.T0010_COMPANY_MASTER.Cmp_Id 
				INNER JOIN dbo.T0010_COMPANY_MASTER AS T0010_COMPANY_MASTER_R WITH (NOLOCK) ON dbo.T0080_EMP_MASTER.Cmp_ID = T0010_COMPANY_MASTER_R.Cmp_Id 
                LEFT OUTER JOIN (
								SELECT	Emp_id,I.Desig_Id,I.Cmp_ID 
								FROM		T0095_INCREMENT I WITH (NOLOCK)
								WHERE		I.Increment_ID=(	SELECT	MAX(INCREMENT_ID)
																FROM	T0095_INCREMENT I1 WITH (NOLOCK)
																WHERE	I1.Increment_Effective_Date = (	SELECT	MAX(I2.Increment_Effective_Date)
																										FROM	T0095_INCREMENT I2 WITH (NOLOCK)
																										WHERE	I2.Emp_ID=I1.Emp_ID AND I2.Cmp_ID=I1.Cmp_ID
																										GROUP BY I2.Emp_ID, I2.Cmp_ID
																									   )
																AND I1.Cmp_ID=I.Cmp_ID AND I1.Emp_ID=I.Emp_ID
																GROUP BY I1.Emp_ID, I1.Cmp_ID
															)													
								) RPT_EMP ON T0080_EMP_MASTER.Cmp_ID=RPT_EMP.Cmp_ID AND dbo.T0080_EMP_MASTER.Emp_ID=RPT_EMP.Emp_ID																																																		
              INNER JOIN dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK) ON RPT_EMP.Desig_Id = dbo.T0040_DESIGNATION_MASTER.Desig_ID AND dbo.T0040_DESIGNATION_MASTER.Cmp_ID = dbo.T0080_EMP_MASTER.Cmp_ID





GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_EMP_REPORTING_DETAIL_Get';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'  Bottom = 256
               Right = 468
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Qry"
            Begin Extent = 
               Top = 6
               Left = 969
               Bottom = 136
               Right = 1191
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
      Begin ColumnWidths = 14
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_EMP_REPORTING_DETAIL_Get';


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
         Begin Table = "T0090_EMP_REPORTING_DETAIL"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 121
               Right = 463
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0080_EMP_MASTER_1"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 241
               Right = 255
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0030_BRANCH_MASTER"
            Begin Extent = 
               Top = 6
               Left = 501
               Bottom = 121
               Right = 660
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0010_COMPANY_MASTER"
            Begin Extent = 
               Top = 6
               Left = 698
               Bottom = 121
               Right = 931
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0010_COMPANY_MASTER_R"
            Begin Extent = 
               Top = 378
               Left = 38
               Bottom = 508
               Right = 292
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_DESIGNATION_MASTER"
            Begin Extent = 
               Top = 126
               Left = 293
             ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_EMP_REPORTING_DETAIL_Get';

