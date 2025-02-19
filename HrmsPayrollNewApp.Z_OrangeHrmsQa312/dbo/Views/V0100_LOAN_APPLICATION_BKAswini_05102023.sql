



CREATE VIEW [dbo].[V0100_LOAN_APPLICATION_BKAswini_05102023]
AS
SELECT     dbo.T0040_LOAN_MASTER.Loan_Name, dbo.T0100_LOAN_APPLICATION.Loan_App_ID, dbo.T0100_LOAN_APPLICATION.Cmp_ID, 
                      dbo.T0100_LOAN_APPLICATION.Emp_ID, dbo.T0100_LOAN_APPLICATION.Loan_ID, dbo.T0100_LOAN_APPLICATION.Loan_App_Date, 
                      dbo.T0100_LOAN_APPLICATION.Loan_App_Code, dbo.T0100_LOAN_APPLICATION.Loan_App_Amount, dbo.T0100_LOAN_APPLICATION.Loan_App_No_of_Insttlement, 
                      dbo.T0100_LOAN_APPLICATION.Loan_App_Installment_Amount, dbo.T0100_LOAN_APPLICATION.Loan_App_Comments, dbo.T0080_EMP_MASTER.Emp_Full_Name, 
                      dbo.T0080_EMP_MASTER.Emp_First_Name, dbo.T0100_LOAN_APPLICATION.Loan_status, dbo.T0080_EMP_MASTER.Emp_Left, 
                      dbo.T0080_EMP_MASTER.Mobile_No, dbo.T0080_EMP_MASTER.Other_Email, dbo.T0095_INCREMENT.Branch_ID, dbo.T0080_EMP_MASTER.Emp_code, 
                      dbo.T0080_EMP_MASTER.Emp_Superior AS R_Emp_ID, dbo.T0040_LOAN_MASTER.Loan_Max_Limit, dbo.T0120_LOAN_APPROVAL.Loan_Apr_Amount, 
                      dbo.T0080_EMP_MASTER.Work_Email, dbo.T0120_LOAN_APPROVAL.Loan_Apr_ID, dbo.T0080_EMP_MASTER.Alpha_Emp_Code, 
                      dbo.T0040_DEPARTMENT_MASTER.Dept_Name, dbo.T0040_DESIGNATION_MASTER.Desig_Name, dbo.T0095_INCREMENT.Gross_Salary, 
                      dbo.T0095_INCREMENT.CTC, dbo.T0080_EMP_MASTER.Date_Of_Join, dbo.T0095_INCREMENT.Basic_Salary, dbo.T0030_BRANCH_MASTER.Branch_Name, 
                      dbo.T0100_LOAN_APPLICATION.Guarantor_Emp_ID, dbo.T0040_LOAN_MASTER.Loan_Guarantor, ISNULL(dbo.T0100_LOAN_APPLICATION.Installment_Start_Date, 
                      dbo.T0100_LOAN_APPLICATION.Loan_App_Date) AS Installment_Start_Date, dbo.T0120_LOAN_APPROVAL.Loan_Approval_Remarks, 
                      dbo.T0100_LOAN_APPLICATION.Loan_Interest_Type, dbo.T0100_LOAN_APPLICATION.Loan_Interest_Per, dbo.T0100_LOAN_APPLICATION.Loan_Require_Date, 
                      dbo.T0100_LOAN_APPLICATION.Attachment_Path, dbo.T0040_LOAN_MASTER.Is_attachment, dbo.T0100_LOAN_APPLICATION.No_of_Inst_Loan_Amt, 
                      dbo.T0100_LOAN_APPLICATION.Total_Loan_Int_Amount, dbo.T0100_LOAN_APPLICATION.Loan_Int_Installment_Amount, 
                      dbo.T0040_LOAN_MASTER.Is_Principal_First_than_Int, dbo.T0100_LOAN_APPLICATION.Loan_App_Amount AS Loan_Taken_Amount, 
                      dbo.T0095_INCREMENT.Vertical_ID, dbo.T0095_INCREMENT.SubVertical_ID, dbo.T0095_INCREMENT.Dept_ID, dbo.T0100_LOAN_APPLICATION.Guarantor_Emp_ID2, 
                      dbo.T0040_LOAN_MASTER.Loan_Guarantor2,isnull(T0040_LOAN_MASTER.is_subsidy_loan,0) as is_subsidy_loan,
                      dbo.T0040_LOAN_MASTER.Hide_Loan_Max_Amount,T0040_BANK_MASTER.Bank_Name,
					  T0095_INCREMENT.Inc_Bank_AC_No,
					  --T0040_BANK_MASTER.Bank_Ac_No,
					  isnull(T0080_EMP_MASTER.Ifsc_Code,'')as Ifsc_Code
					    ,isnull(format(T0080_EMP_MASTER.Date_of_Retirement,'dd/MM/yyyy'),'') as  Date_of_Retirement --Added by ronakk 02112022
					  FROM         
					  dbo.T0100_LOAN_APPLICATION WITH (NOLOCK) INNER JOIN
                      dbo.T0040_LOAN_MASTER  WITH (NOLOCK) ON dbo.T0100_LOAN_APPLICATION.Loan_ID = dbo.T0040_LOAN_MASTER.Loan_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER  WITH (NOLOCK) ON dbo.T0100_LOAN_APPLICATION.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN
					   dbo.T0095_INCREMENT  WITH (NOLOCK) ON dbo.T0080_EMP_MASTER.Increment_ID = dbo.T0095_INCREMENT.Increment_ID left join --added by mansi 
                      --dbo.T0095_INCREMENT  WITH (NOLOCK) ON dbo.T0080_EMP_MASTER.Increment_ID = dbo.T0095_INCREMENT.Increment_ID inner join  --commented by mansi
					  --dbo.T0040_BANK_MASTER WITH (NOLOCK) ON dbo.T0040_BANK_MASTER.Bank_ID = dbo.T0080_EMP_MASTER.Bank_ID  LEFT OUTER JOIN
					  dbo.T0040_BANK_MASTER WITH (NOLOCK) ON dbo.T0040_BANK_MASTER.Bank_ID = dbo.T0095_INCREMENT.Bank_ID  LEFT OUTER JOIN
                      dbo.T0040_DEPARTMENT_MASTER  WITH (NOLOCK) ON dbo.T0095_INCREMENT.Dept_ID = dbo.T0040_DEPARTMENT_MASTER.Dept_Id INNER JOIN
                      dbo.T0040_DESIGNATION_MASTER  WITH (NOLOCK) ON dbo.T0095_INCREMENT.Desig_Id = dbo.T0040_DESIGNATION_MASTER.Desig_ID LEFT OUTER JOIN
                      dbo.T0120_LOAN_APPROVAL WITH (NOLOCK)  ON dbo.T0100_LOAN_APPLICATION.Loan_App_ID = dbo.T0120_LOAN_APPROVAL.Loan_App_ID AND 
                      dbo.T0040_LOAN_MASTER.Loan_ID = dbo.T0120_LOAN_APPROVAL.Loan_ID AND  dbo.T0080_EMP_MASTER.Emp_ID = dbo.T0120_LOAN_APPROVAL.Emp_ID LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER  WITH (NOLOCK) ON dbo.T0095_INCREMENT.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID AND 
                      dbo.T0100_LOAN_APPLICATION.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID




GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[35] 4[5] 2[38] 3) )"
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
         Top = -96
         Left = 0
      End
      Begin Tables = 
         Begin Table = "T0100_LOAN_APPLICATION"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 269
            End
            DisplayFlags = 280
            TopColumn = 10
         End
         Begin Table = "T0040_LOAN_MASTER"
            Begin Extent = 
               Top = 6
               Left = 307
               Bottom = 121
               Right = 467
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
            TopColumn = 77
         End
         Begin Table = "T0095_INCREMENT"
            Begin Extent = 
               Top = 246
               Left = 38
               Bottom = 361
               Right = 246
            End
            DisplayFlags = 280
            TopColumn = 11
         End
         Begin Table = "T0040_DEPARTMENT_MASTER"
            Begin Extent = 
               Top = 6
               Left = 505
               Bottom = 121
               Right = 657
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_DESIGNATION_MASTER"
            Begin Extent = 
               Top = 6
               Left = 695
               Bottom = 121
               Right = 856
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0120_LOAN_APPROVAL"
            Begin Extent = 
               Top = 366
               Left = 38
               Bott', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_LOAN_APPLICATION_BKAswini_05102023';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'om = 481
               Right = 267
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0030_BRANCH_MASTER"
            Begin Extent = 
               Top = 486
               Left = 38
               Bottom = 605
               Right = 233
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
      Begin ColumnWidths = 31
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_LOAN_APPLICATION_BKAswini_05102023';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0100_LOAN_APPLICATION_BKAswini_05102023';

