






CREATE VIEW [dbo].[V0120_LOAN_APPROVAL]
AS
SELECT		dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0040_LOAN_MASTER.Loan_Name, dbo.T0120_LOAN_APPROVAL.Loan_Apr_ID, 
                      dbo.T0120_LOAN_APPROVAL.Cmp_ID, dbo.T0120_LOAN_APPROVAL.Loan_App_ID, dbo.T0120_LOAN_APPROVAL.Emp_ID, dbo.T0120_LOAN_APPROVAL.Loan_ID, 
                      dbo.T0120_LOAN_APPROVAL.Loan_Apr_Date, dbo.T0120_LOAN_APPROVAL.Loan_Apr_Code, dbo.T0120_LOAN_APPROVAL.Loan_Apr_Amount, 
                      dbo.T0120_LOAN_APPROVAL.Loan_Apr_No_of_Installment, dbo.T0120_LOAN_APPROVAL.Loan_Apr_Installment_Amount, 
                      dbo.T0120_LOAN_APPROVAL.Loan_Apr_Intrest_Type, dbo.T0120_LOAN_APPROVAL.Loan_Apr_Intrest_Per, dbo.T0120_LOAN_APPROVAL.Loan_Apr_Intrest_Amount, 
                      dbo.T0120_LOAN_APPROVAL.Loan_Apr_Deduct_From_Sal, dbo.T0120_LOAN_APPROVAL.Loan_Apr_Pending_Amount, dbo.T0120_LOAN_APPROVAL.Loan_Apr_By, 
                      dbo.T0120_LOAN_APPROVAL.Loan_Apr_Payment_Date, dbo.T0120_LOAN_APPROVAL.Loan_Apr_Payment_Type, dbo.T0120_LOAN_APPROVAL.Bank_ID, 
                      dbo.T0120_LOAN_APPROVAL.Loan_Apr_Cheque_No, dbo.T0080_EMP_MASTER.Mobile_No, dbo.T0080_EMP_MASTER.Emp_First_Name, 
                      dbo.T0080_EMP_MASTER.Emp_Left, dbo.T0100_LOAN_APPLICATION.Loan_App_Date, dbo.T0100_LOAN_APPLICATION.Loan_App_Code, 
                      dbo.T0040_LOAN_MASTER.Loan_Max_Limit, dbo.T0120_LOAN_APPROVAL.Loan_Apr_Status, dbo.T0095_INCREMENT.Branch_ID, 
                      dbo.T0080_EMP_MASTER.Emp_code, dbo.T0120_LOAN_APPROVAL.Deduction_Type, dbo.T0120_LOAN_APPROVAL.Loan_Number, 
                      dbo.T0080_EMP_MASTER.Work_Email AS Other_Email, dbo.T0040_DEPARTMENT_MASTER.Dept_Name, dbo.T0040_DESIGNATION_MASTER.Desig_Name, 
                      dbo.T0095_INCREMENT.Gross_Salary, dbo.T0095_INCREMENT.CTC, dbo.T0080_EMP_MASTER.Date_Of_Join, dbo.T0095_INCREMENT.Basic_Salary, 
                      dbo.T0080_EMP_MASTER.Alpha_Emp_Code, dbo.T0040_LOAN_MASTER.Loan_Guarantor, dbo.T0120_LOAN_APPROVAL.Guarantor_Emp_ID, 
                      ISNULL(dbo.T0120_LOAN_APPROVAL.Installment_Start_Date, dbo.T0120_LOAN_APPROVAL.Loan_Apr_Date) AS Installment_Start_Date, 
                      dbo.T0120_LOAN_APPROVAL.Loan_Approval_Remarks, dbo.T0120_LOAN_APPROVAL.Subsidy_Recover_Perc, dbo.T0040_LOAN_MASTER.Is_Interest_Subsidy_Limit, 
                      dbo.T0040_LOAN_MASTER.Interest_Recovery_Per, dbo.T0040_LOAN_MASTER.Subsidy_Desig_Id_String, dbo.T0040_LOAN_MASTER.Loan_Interest_Type, 
                      dbo.T0040_LOAN_MASTER.Loan_Interest_Per, dbo.T0040_LOAN_MASTER.Is_attachment, dbo.T0040_LOAN_MASTER.Is_Eligible, 
                      dbo.T0040_LOAN_MASTER.Eligible_Days, dbo.T0100_LOAN_APPLICATION.Loan_Interest_Type AS App_Loan_Interest_Type, 
                      dbo.T0100_LOAN_APPLICATION.Loan_Interest_Per AS App_Loan_Interest_Per, dbo.T0100_LOAN_APPLICATION.Loan_Require_Date, 
                      dbo.T0100_LOAN_APPLICATION.Attachment_Path, dbo.T0120_LOAN_APPROVAL.Attachment_Path AS Apr_Attachment_Path, 
                      dbo.T0040_LOAN_MASTER.Subsidy_Bond_Days, dbo.T0120_LOAN_APPROVAL.Actual_subsidy_start_date, dbo.T0120_LOAN_APPROVAL.Opening_subsidy_amount, 
                      dbo.T0120_LOAN_APPROVAL.No_of_Inst_Loan_Amt, dbo.T0120_LOAN_APPROVAL.Total_Loan_Int_Amount, 
                      dbo.T0120_LOAN_APPROVAL.Loan_Int_Installment_Amount, dbo.T0120_LOAN_APPROVAL.Loan_Apr_Pending_Int_Amount, 
                      dbo.T0040_LOAN_MASTER.Is_Principal_First_than_Int, 
                      CAST(dbo.T0120_LOAN_APPROVAL.Paid_Amount + dbo.T0120_LOAN_APPROVAL.Loan_Apr_Amount AS numeric(18, 0)) AS Loan_Taken_Amount, 
					  CAST(dbo.T0120_LOAN_APPROVAL.Loan_Apr_Amount - dbo.T0120_LOAN_APPROVAL.Loan_Apr_Pending_Amount AS numeric(18, 0)) AS Loan_Paid_Amount, 
                     --ISNULL(Loan_Pay_Amount,0) AS Loan_Paid_Amount,
					 dbo.T0095_INCREMENT.Vertical_ID, dbo.T0095_INCREMENT.SubVertical_ID, 
                      dbo.T0095_INCREMENT.Dept_ID, dbo.T0120_LOAN_APPROVAL.Guarantor_Emp_ID2, dbo.T0040_LOAN_MASTER.Loan_Guarantor2,
                      T0040_Vertical_Segment.Vertical_Name , T0050_SubVertical.SubVertical_Name,Isnull(Qry.Interest_Amount,0) as Interest_Amount
                       ,T0120_LOAN_APPROVAL.SubSidy_Amount,T0040_LOAN_MASTER.Is_Subsidy_Loan,isnull(T0040_LOAN_MASTER.Is_GPF,0) as Is_GPF,
                       Isnull(T0120_LOAN_APPROVAL.AD_ID,0) As AD_ID,ISNULL(AD.Hide_In_Reports,0) as Hide_In_Reports
					   ,isnull(format(T0080_EMP_MASTER.Date_of_Retirement,'dd/MM/yyyy'),'') as  Date_of_Retirement --Added by ronakk 02112022
FROM         dbo.T0120_LOAN_APPROVAL WITH (NOLOCK) 
			LEFT OUTER JOIN		dbo.T0100_LOAN_APPLICATION WITH (NOLOCK) ON dbo.T0120_LOAN_APPROVAL.Loan_App_ID = dbo.T0100_LOAN_APPLICATION.Loan_App_ID 
			LEFT OUTER JOIN		dbo.T0080_EMP_MASTER WITH (NOLOCK) ON dbo.T0120_LOAN_APPROVAL.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID
			INNER JOIN			dbo.T0095_INCREMENT WITH (NOLOCK) ON dbo.T0080_EMP_MASTER.Increment_ID = dbo.T0095_INCREMENT.Increment_ID
			LEFT OUTER JOIN		dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK) ON dbo.T0095_INCREMENT.Dept_ID = dbo.T0040_DEPARTMENT_MASTER.Dept_Id 
			INNER JOIN			dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK) ON dbo.T0095_INCREMENT.Desig_Id = dbo.T0040_DESIGNATION_MASTER.Desig_ID 
			LEFT OUTER JOIN		dbo.T0040_LOAN_MASTER WITH (NOLOCK) ON dbo.T0120_LOAN_APPROVAL.Loan_ID = dbo.T0040_LOAN_MASTER.Loan_ID
			LEFT OUTER JOIN		dbo.T0040_VERTICAL_SEGMENT WITH (NOLOCK) on dbo.T0095_INCREMENT.Vertical_ID = T0040_VERTICAL_SEGMENT.Vertical_ID
			LEFT OUTER JOIN		dbo.T0050_SUBVERTICAL WITH (NOLOCK) on dbo.T0095_INCREMENT.SubVertical_ID = T0050_SUBVERTICAL.SubVertical_ID
			left OUTER JOIN		T0050_AD_MASTER AD WITH (NOLOCK) ON AD.AD_ID=dbo.T0120_LOAN_APPROVAL.AD_ID 
			Left outer join
						(
								Select Isnull(SUM(Interest_Amount),0) as Interest_Amount,LP.Loan_Apr_ID, Isnull(SUM(LP.Loan_Pay_Amount),0)  as   Loan_Pay_Amount 
								From T0210_MONTHLY_LOAN_PAYMENT LP WITH (NOLOCK) Inner Join T0120_LOAN_APPROVAL LA WITH (NOLOCK) 
								ON LP.Loan_Apr_ID = LA.Loan_Apr_ID Inner Join T0040_LOAN_MASTER LM WITH (NOLOCK) ON LM.Loan_ID = LA.Loan_ID
								Where LM.Is_Principal_First_than_Int = 1 and LA.Loan_Apr_Pending_Amount > 0 --and Isnull(LA.Loan_Apr_Pending_Int_Amount,0) = 0
								Group By LP.Loan_Apr_ID
								--Union ALL
								--Select Isnull(SUM(Loan_Apr_Pending_Int_Amount),0)  as Interest_Amount,LA.Loan_Apr_ID From T0120_LOAN_APPROVAL LA 
								--Inner Join T0040_LOAN_MASTER LM ON LM.Loan_ID = LA.Loan_ID
								--Where LM.Is_Principal_First_than_Int = 1 and Isnull(LA.Loan_Apr_Pending_Int_Amount,0) > 0 and LA.Loan_Apr_Pending_Amount = 0
								--Group By LA.Loan_Apr_ID

						) as Qry ON Qry.Loan_Apr_ID = dbo.T0120_LOAN_APPROVAL.Loan_Apr_ID
	




GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'tom = 374
               Right = 501
            End
            DisplayFlags = 280
            TopColumn = 15
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 10
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0120_LOAN_APPROVAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[85] 4[5] 2[6] 3) )"
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
         Begin Table = "T0120_LOAN_APPROVAL"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 267
            End
            DisplayFlags = 280
            TopColumn = 26
         End
         Begin Table = "T0100_LOAN_APPLICATION"
            Begin Extent = 
               Top = 24
               Left = 491
               Bottom = 139
               Right = 722
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 246
               Left = 38
               Bottom = 361
               Right = 255
            End
            DisplayFlags = 280
            TopColumn = 76
         End
         Begin Table = "T0095_INCREMENT"
            Begin Extent = 
               Top = 366
               Left = 38
               Bottom = 481
               Right = 246
            End
            DisplayFlags = 280
            TopColumn = 11
         End
         Begin Table = "T0040_DEPARTMENT_MASTER"
            Begin Extent = 
               Top = 6
               Left = 305
               Bottom = 121
               Right = 457
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_DESIGNATION_MASTER"
            Begin Extent = 
               Top = 118
               Left = 587
               Bottom = 233
               Right = 748
            End
            DisplayFlags = 280
            TopColumn = 6
         End
         Begin Table = "T0040_LOAN_MASTER"
            Begin Extent = 
               Top = 246
               Left = 293
               Bot', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0120_LOAN_APPROVAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0120_LOAN_APPROVAL';

