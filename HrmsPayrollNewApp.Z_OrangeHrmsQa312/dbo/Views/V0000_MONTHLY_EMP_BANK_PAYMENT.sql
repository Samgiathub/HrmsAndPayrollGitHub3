





CREATE  VIEW [dbo].[V0000_MONTHLY_EMP_BANK_PAYMENT]
AS
SELECT DISTINCT   MEBP.Emp_ID, MEBP.Cmp_ID, MEBP.For_Date, MEBP.Payment_Date, MEBP.Emp_Bank_ID, MEBP.Payment_Mode, MEBP.Net_Amount, MEBP.Emp_Bank_AC_No,
		  MEBP.Cmp_Bank_ID,MEBP.Emp_Cheque_No, MEBP.Cmp_Bank_Cheque_No, MEBP.Cmp_Bank_AC_No, MEBP.Emp_Left, MEBP.Status, EMP.Alpha_Emp_Code,
		  EMP.Emp_Full_Name, ISNULL(BKM.Bank_Name, '-') AS Bank_Name,I.Branch_ID,BRM.Branch_Name,
		  CASE WHEN isnull(Am.AD_ID,0) = 0 THEN MEBP.Process_type ELSE Am.Ad_Name END as Process_Type,ISNULL(AM.AD_ID,0) as Ad_Id,I.Vertical_ID,
		  I.SubVertical_ID,I.Dept_ID,ISNULL(process_type_id,0) as process_type_id,ISNULL(MEBP.payment_process_id,0) as payment_process_id,I.Desig_Id,
		  I.Grd_ID,I.Cat_ID,I.Type_ID,I.subBranch_ID , BOND.Bond_Id , BOND.Bond_Apr_Id ,cad.Claim_ID,cad.Claim_Apr_ID,cm.Claim_Name,Claim_Apr_Deduct_From_Sal
		  --added by jimit 28072017
FROM    dbo.MONTHLY_EMP_BANK_PAYMENT MEBP WITH (NOLOCK)
		INNER JOIN		dbo.T0080_EMP_MASTER EMP WITH (NOLOCK) ON MEBP.Emp_ID = EMP.Emp_ID
		LEFT OUTER JOIN	dbo.T0040_BANK_MASTER BKM WITH (NOLOCK) ON MEBP.Emp_Bank_ID = BKM.Bank_ID AND MEBP.Cmp_Bank_ID = BKM.Bank_ID AND EMP.Bank_ID = BKM.Bank_ID
        INNER JOIN
				  (	SELECT Branch_ID,I.Increment_Id, I.Emp_Id,I.Grd_ID,I.Desig_Id,I.Dept_ID,I.Vertical_ID,I.SubVertical_ID,I.Segment_ID,I.Cat_ID,I.Type_ID,I.subBranch_ID 
					FROM T0095_INCREMENT I WITH (NOLOCK)
						INNER JOIN
							(SELECT Max(TI.Increment_ID) Increment_Id,ti.Emp_ID 
							 FROM T0095_INCREMENT TI WITH (NOLOCK)
								INNER JOIN
								(SELECT Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID
								 FROM T0095_Increment WITH (NOLOCK)
								 WHERE Increment_effective_Date <= GETDATE()
								 GROUP BY emp_ID
								) new_inc on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
							WHERE TI.Increment_effective_Date <= GETDATE()
							GROUP BY ti.emp_id
							) Qry on I.Increment_Id = Qry.Increment_Id 
				  ) I ON EMP.EMP_ID=I.EMP_ID
		LEFT OUTER JOIN T0050_AD_MASTER AM WITH (NOLOCK)			ON CASE WHEN Process_Type <> 'Bond' THEN MEBP.AD_ID else 0 end = AM.AD_ID
		LEFT OUTER JOIN T0030_BRANCH_MASTER BRM WITH (NOLOCK)		ON I.Branch_id = BRM.Branch_ID
		LEFT OUTER JOIN T0120_BOND_APPROVAL BOND WITH (NOLOCK)	ON BOND.Payment_Process_ID = MEBP.payment_process_id
		LEFT OUTER JOIN T0130_CLAIM_APPROVAL_DETAIL cad WITH (NOLOCK)	ON MEBP.process_type_id = cad.Payment_Process_ID 
		--LEFT OUTER JOIN T0120_CLAIM_APPROVAL CAPP WITH (NOLOCK) ON CAPP.Claim_Apr_ID = CAD.Claim_Apr_ID
		LEFT OUTER JOIN T0040_CLAIM_MASTER CM WITH (NOLOCK) ON cm.Claim_ID = cad.Claim_ID and Claim_Apr_Deduct_From_Sal = 0


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
         Begin Table = "MONTHLY_EMP_BANK_PAYMENT"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 231
            End
            DisplayFlags = 280
            TopColumn = 5
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 9
               Left = 850
               Bottom = 112
               Right = 1096
            End
            DisplayFlags = 280
            TopColumn = 3
         End
         Begin Table = "T0040_BANK_MASTER"
            Begin Extent = 
               Top = 67
               Left = 510
               Bottom = 182
               Right = 686
            End
            DisplayFlags = 280
            TopColumn = 4
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 20
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
     ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0000_MONTHLY_EMP_BANK_PAYMENT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'    Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0000_MONTHLY_EMP_BANK_PAYMENT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0000_MONTHLY_EMP_BANK_PAYMENT';

