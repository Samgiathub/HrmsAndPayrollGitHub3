/*Added By Jaina 16-09-2015 End
left join T0030_BRANCH_MASTER BM 
on BM.Branch_ID=EM.Branch_ID
SELECT   distinct (dbo.T0120_CLAIM_APPROVAL.Claim_App_ID),CLM.Claim_Apr_ID,
					  dbo.T0040_CLAIM_MASTER.Claim_Name, 
					  dbo.T0040_CLAIM_MASTER.Claim_Max_Limit, dbo.T0080_EMP_MASTER.Emp_First_Name, 
                      dbo.T0080_EMP_MASTER.Mobile_No, dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0080_EMP_MASTER.Emp_Left, 
                      dbo.T0100_CLAIM_APPLICATION.Claim_App_Date, dbo.T0100_CLAIM_APPLICATION.Claim_App_Code,
                      CLM.Cmp_ID, dbo.T0120_CLAIM_APPROVAL.Emp_ID, 
                      CLM.Claim_ID, dbo.T0120_CLAIM_APPROVAL.Claim_Apr_Date, dbo.T0120_CLAIM_APPROVAL.Claim_Apr_Code, 
                      CLM.Claim_Apr_Amount,
                      dbo.T0120_CLAIM_APPROVAL.Claim_Apr_Comments, dbo.T0120_CLAIM_APPROVAL.Claim_Apr_By, 
                      dbo.T0120_CLAIM_APPROVAL.Claim_Apr_Deduct_From_Sal,
                      dbo.T0120_CLAIM_APPROVAL.Claim_Apr_Pending_Amount, 
                      CLM.Claim_Status,
                      dbo.T0100_CLAIM_APPLICATION.Claim_App_Status,
                      dbo.T0095_INCREMENT.Branch_ID, 
                      dbo.T0080_EMP_MASTER.Emp_code as Emp_Code1, dbo.T0080_EMP_MASTER.Work_Email AS Other_Email,dbo.T0080_EMP_MASTER.Alpha_Emp_Code as Emp_Code
FROM         dbo.T0100_CLAIM_APPLICATION
--INNER JOIN dbo.T0110_CLAIM_APPLICATION_DETAIL on dbo.T0100_CLAIM_APPLICATION.Claim_App_ID=dbo.T0100_CLAIM_APPLICATION.Claim_App_ID
					  inner join
                      dbo.T0120_CLAIM_APPROVAL ON dbo.T0100_CLAIM_APPLICATION.Claim_App_ID = dbo.T0120_CLAIM_APPROVAL.Claim_App_ID INNER JOIN
                      dbo.T0040_CLAIM_MASTER ON dbo.T0120_CLAIM_APPROVAL.Claim_ID = dbo.T0040_CLAIM_MASTER.Claim_ID INNER JOIN
                      dbo.T0080_EMP_MASTER ON dbo.T0120_CLAIM_APPROVAL.Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID INNER JOIN
                      dbo.T0095_INCREMENT ON dbo.T0080_EMP_MASTER.Increment_ID = dbo.T0095_INCREMENT.Increment_ID
                      left join T0130_CLAIM_APPROVAL_DETAIL CLM on CLM.Claim_Apr_ID=T0120_CLAIM_APPROVAL.Claim_Apr_ID*/
CREATE VIEW dbo.[V0230_Claim_Payment_Detail_Aswini280823]
AS
SELECT DISTINCT 
                  EM.Emp_First_Name, EM.Emp_Full_Name, EM.Alpha_Emp_Code, EM.Emp_ID, CA.Claim_Apr_Date, EM.Dept_ID, EM.Emp_Left, EM.Branch_ID, EM.Alpha_Emp_Code AS Emp_Code, CM.Claim_Pay_ID, CM.Claim_Apr_ID, CM.Cmp_ID, CM.Sal_Tran_ID, CM.Claim_Pay_Code, 
                  CM.Claim_Pay_Amount, CM.Claim_Pay_Comments, CM.Claim_Payment_Date, CM.Claim_Payment_Type, CM.Bank_Name, CM.Claim_Cheque_No, CM.Temp_Sal_Tran_ID, CM.Voucher_No, CM.Voucher_Date, B.Vertical_ID, B.SubVertical_ID
FROM        dbo.T0210_MONTHLY_CLAIM_PAYMENT AS CM WITH (NOLOCK) INNER JOIN
                  dbo.T0230_MONTHLY_CLAIM_PAYMENT_DETAIL AS CPD WITH (NOLOCK) ON CM.Claim_Pay_ID = CPD.Claim_Pay_Id AND CM.Cmp_ID = CPD.Cmp_ID INNER JOIN
                  dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON CPD.Emp_ID = EM.Emp_ID LEFT OUTER JOIN
                  dbo.T0120_CLAIM_APPROVAL AS CA WITH (NOLOCK) ON CA.Claim_Apr_ID = CPD.Claim_Apr_Id AND CA.Emp_ID = CPD.Emp_ID AND CA.Claim_ID = CPD.Claim_ID LEFT OUTER JOIN
                      (SELECT     Emp_ID, Branch_ID, Cmp_ID, Vertical_ID, SubVertical_ID
                       FROM        dbo.T0095_INCREMENT AS I WITH (NOLOCK)
                       WHERE     (Increment_ID =
                                             (SELECT     TOP (1) Increment_ID
                                              FROM        dbo.T0095_INCREMENT AS I1 WITH (NOLOCK)
                                              WHERE     (Emp_ID = I.Emp_ID) AND (Cmp_ID = I.Cmp_ID)
                                              ORDER BY Increment_Effective_Date DESC, Increment_ID DESC))) AS B ON B.Emp_ID = EM.Emp_ID AND B.Cmp_ID = EM.Cmp_ID

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
         Begin Table = "CM"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 170
               Right = 287
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CPD"
            Begin Extent = 
               Top = 175
               Left = 48
               Bottom = 338
               Right = 274
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "EM"
            Begin Extent = 
               Top = 343
               Left = 48
               Bottom = 506
               Right = 375
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CA"
            Begin Extent = 
               Top = 511
               Left = 48
               Bottom = 674
               Right = 331
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "B"
            Begin Extent = 
               Top = 7
               Left = 335
               Bottom = 170
               Right = 529
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0230_Claim_Payment_Detail_Aswini280823';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0230_Claim_Payment_Detail_Aswini280823';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0230_Claim_Payment_Detail_Aswini280823';

