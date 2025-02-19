







CREATE VIEW [dbo].[V0200_MONTHLY_SALARY]
AS
select *
 from 
 
(
SELECT     MS.Sal_Tran_ID, MS.Sal_Receipt_No, MS.Emp_ID, MS.Cmp_ID, MS.Increment_ID, MS.Month_St_Date, MS.Month_End_Date, MS.Sal_Generate_Date, 
                      MS.Sal_Cal_Days, MS.Present_Days, MS.Absent_Days, MS.Holiday_Days, MS.Weekoff_Days, MS.Cancel_Holiday, MS.Cancel_Weekoff, 
                      MS.Working_Days, MS.Outof_Days, MS.Total_Leave_Days, MS.Paid_Leave_Days, MS.Actual_Working_Hours, MS.Working_Hours, MS.Outof_Hours, 
                      MS.OT_Hours, MS.Total_Hours, MS.Shift_Day_Sec, MS.Shift_Day_Hour, MS.Day_Salary, MS.Hour_Salary, MS.Salary_Amount AS basic_salary, 
                      MS.Allow_Amount, MS.OT_Amount, MS.Other_Allow_Amount, MS.Gross_Salary, MS.Dedu_Amount, MS.Loan_Amount, MS.Loan_Intrest_Amount, 
                      MS.Advance_Amount, MS.Other_Dedu_Amount, MS.Total_Dedu_Amount, MS.Due_Loan_Amount, MS.Net_Amount, MS.Actually_Gross_Salary, 
                      MS.PT_Amount, MS.PT_Calculated_Amount, MS.Total_Claim_Amount, MS.M_OT_Hours, MS.M_Adv_Amount, MS.M_Loan_Amount, MS.M_IT_Tax, 
                      MS.LWF_Amount, MS.Revenue_Amount, MS.PT_F_T_Limit, e.Emp_Full_Name,
                      /*i.Dept_ID, i.Grd_ID, i.Branch_ID, BM.Branch_Name,i.SalDate_id, i.Segment_ID, i.Vertical_ID, i.SubVertical_ID, i.subBranch_ID,i.Desig_Id, ISNULL(i.Cat_ID, 0) AS Cat_ID*/
                      e.Other_Email, 
                      ISNULL(MS.Is_FNF, 0) AS IS_FNF, e.IS_Emp_FNF, e.Emp_First_Name, e.Emp_code, e.Alpha_Emp_Code, 
                      MS.Salary_Status, 
                      
                      (
						SELECT Increment_ID from
						(
						   select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)    
						   where Increment_Effective_date <= MS.Month_End_Date and Emp_ID = ms.Emp_id
						   GROUP BY Emp_ID
						) as tbl
                      ) as Max_Increment_ID
                      ,e.Emp_Left,e.Emp_Left_Date,EX.exit_id --Ankit 27062016
FROM         dbo.T0200_MONTHLY_SALARY AS MS WITH (NOLOCK)  INNER JOIN
                      dbo.T0080_EMP_MASTER AS e WITH (NOLOCK)  ON MS.Emp_ID = e.Emp_ID
					  LEFT JOIN 
                     (select EX.* from T0200_Emp_ExitApplication  EX
						INnER JOIN (
						select max(exit_id)exit_id from T0200_Emp_ExitApplication
						group by emp_id ) EX1 oN EX1.exit_id = EX.exit_id ) EX ON EX.emp_id=MS.Emp_ID
					  --LEFT JOIN 
       --               T0200_Emp_ExitApplication EX WITH (NOLOCK)  ON EX.emp_id=MS.Emp_ID --comment by tejas for get multiple sallry data when more than one exit application
                      	--INNER JOIN
                      --dbo.T0095_INCREMENT AS i ON MS.Increment_ID = i.Increment_ID 
					  --INNER JOIN
                      --dbo.T0030_BRANCH_MASTER AS BM ON i.Branch_ID = BM.Branch_ID
                      
) as tbl1 Inner join

(select I.Emp_Id as Emp_id1, Increment_Effective_Date,i.Dept_ID, i.Grd_ID, i.Branch_ID, BM.Branch_Name,i.SalDate_id, i.Segment_ID, i.Vertical_ID, i.SubVertical_ID, i.subBranch_ID,i.Desig_Id, ISNULL(i.Cat_ID, 0) AS Cat_ID,I.Increment_ID As Max_Increment_ID_1 
	from T0095_INCREMENT as I WITH (NOLOCK)  INNER JOIN
		dbo.T0030_BRANCH_MASTER AS BM WITH (NOLOCK)  ON i.Branch_ID = BM.Branch_ID
	) as Qry1
	on Qry1.Emp_id1 = tbl1.Emp_ID and Qry1.Max_Increment_ID_1 = tbl1.Max_Increment_ID

	



GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[36] 4[6] 2[41] 3) )"
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
         Top = -203
         Left = 0
      End
      Begin Tables = 
         Begin Table = "MS"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 255
            End
            DisplayFlags = 280
            TopColumn = 74
         End
         Begin Table = "e"
            Begin Extent = 
               Top = 37
               Left = 711
               Bottom = 294
               Right = 928
            End
            DisplayFlags = 280
            TopColumn = 72
         End
         Begin Table = "i"
            Begin Extent = 
               Top = 246
               Left = 38
               Bottom = 361
               Right = 246
            End
            DisplayFlags = 280
            TopColumn = 63
         End
         Begin Table = "BM"
            Begin Extent = 
               Top = 6
               Left = 293
               Bottom = 121
               Right = 452
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
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0200_MONTHLY_SALARY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0200_MONTHLY_SALARY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'put = 720
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0200_MONTHLY_SALARY';

