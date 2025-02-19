


CREATE VIEW [dbo].[V0040_Asset_Allocation]
AS
SELECT DISTINCT 
                      dbo.T0040_ASSET_MASTER.Asset_Name, dbo.T0040_BRAND_MASTER.BRAND_Name, dbo.T0040_Asset_Details.Asset_Code, dbo.T0040_Asset_Details.SerialNo, 
                      dbo.T0130_Asset_Approval_Det.Allocation_Date, dbo.T0040_Asset_Details. Vendor, dbo.T0040_Asset_Details.Type_of_Asset, 
                      dbo.T0130_Asset_Approval_Det.Asset_Approval_ID, dbo.T0040_Asset_Details.Model AS Model_Name, dbo.T0040_Asset_Details.SerialNo AS Serial_No, 
                      dbo.T0040_Asset_Details.Asset_Code AS Expr1, dbo.T0130_Asset_Approval_Det.Cmp_ID, dbo.T0120_Asset_Approval.Emp_ID, 
                      CASE WHEN T0130_Asset_Approval_Det.Application_Type = 0 THEN '' ELSE CONVERT(varchar(11), dbo.T0130_Asset_Approval_Det.Return_Date, 103) 
                      END AS Return_Date, CASE WHEN T0130_Asset_Approval_Det.Application_Type = 0 THEN 'Application' ELSE 'Return' END AS Type, E.Emp_Full_Name, 
                      B.Branch_Name, dbo.T0040_Asset_Details.AssetM_ID, dbo.T0040_Asset_Details.Asset_ID, E.Alpha_Emp_Code, 
                      CASE WHEN dbo.T0040_Asset_Details.Asset_Status = 'D' THEN 'Damage' ELSE 'Working' END AS Asset_Status, T0040_Asset_Details.Brand_Id, 
                      dbo.T0040_Asset_Details.Invoice_amount, dbo.T0130_Asset_Approval_Det.Issue_Amount
FROM         dbo.T0130_Asset_Approval_Det WITH (NOLOCK) INNER JOIN
                      dbo.T0040_ASSET_MASTER WITH (NOLOCK)  ON dbo.T0130_Asset_Approval_Det.Asset_ID = dbo.T0040_ASSET_MASTER.Asset_ID INNER JOIN
                      dbo.T0040_BRAND_MASTER WITH (NOLOCK)  ON dbo.T0130_Asset_Approval_Det.Brand_Id = dbo.T0040_BRAND_MASTER.BRAND_ID INNER JOIN
                      dbo.T0040_Asset_Details WITH (NOLOCK)  ON dbo.T0130_Asset_Approval_Det.AssetM_ID = dbo.T0040_Asset_Details.AssetM_ID INNER JOIN
                      dbo.T0120_Asset_Approval WITH (NOLOCK)  ON dbo.T0120_Asset_Approval.Asset_Approval_ID = dbo.T0130_Asset_Approval_Det.Asset_Approval_ID AND 
                      dbo.T0120_Asset_Approval.Cmp_ID = dbo.T0130_Asset_Approval_Det.Cmp_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS E WITH (NOLOCK)  ON dbo.T0120_Asset_Approval.Emp_ID = E.Emp_ID AND E.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER AS B WITH (NOLOCK)  ON dbo.T0120_Asset_Approval.Branch_ID = B.Branch_ID AND B.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID LEFT OUTER JOIN
                          (SELECT     I.Emp_ID, I.Branch_ID, I.Cmp_ID
                            FROM          dbo.T0095_INCREMENT AS I WITH (NOLOCK)  INNER JOIN
                                                   dbo.T0080_EMP_MASTER AS E WITH (NOLOCK)  ON E.Emp_ID = I.Emp_ID
                            WHERE      (I.Increment_ID IN
                                                       (SELECT     MAX(Increment_ID) AS Expr1
                                                         FROM          dbo.T0095_INCREMENT WITH (NOLOCK) 
                                                         GROUP BY Emp_ID))) AS mm ON E.Emp_ID = mm.Emp_ID AND E.Cmp_ID = mm.Cmp_ID
WHERE     isnull(Return_Date, '') <> '1900-01-01 00:00:00.000' AND isnull(Return_asset_approval_id, 0) > 0 AND T0130_Asset_Approval_Det.application_type = 1
UNION
SELECT DISTINCT 
                      dbo.T0040_ASSET_MASTER.Asset_Name, dbo.T0040_BRAND_MASTER.BRAND_Name, dbo.T0040_Asset_Details.Asset_Code, dbo.T0040_Asset_Details.SerialNo, 
                      a1.Allocation_Date, dbo.T0040_Asset_Details. Vendor, dbo.T0040_Asset_Details.Type_of_Asset, a1.Asset_Approval_ID, 
                      dbo.T0040_Asset_Details.Model AS Model_Name, dbo.T0040_Asset_Details.SerialNo AS Serial_No, dbo.T0040_Asset_Details.Asset_Code AS Expr1, a1.Cmp_ID, 
                      dbo.T0120_Asset_Approval.Emp_ID, CASE WHEN a1.Application_Type = 0 THEN '' ELSE CONVERT(varchar(11), a1.Return_Date, 103) END AS Return_Date, 
                      CASE WHEN a1.Application_Type = 0 THEN 'Application' ELSE 'Return' END AS Type, E.Emp_Full_Name, B.Branch_Name, dbo.T0040_Asset_Details.AssetM_ID, 
                      dbo.T0040_Asset_Details.Asset_ID, E.Alpha_Emp_Code, 
                      CASE WHEN dbo.T0040_Asset_Details.Asset_Status = 'D' THEN 'Damage' ELSE 'Working' END AS Asset_Status, T0040_Asset_Details.Brand_Id, 
                      dbo.T0040_Asset_Details.Invoice_amount, a1.Issue_Amount
FROM         dbo.T0130_Asset_Approval_Det a1 WITH (NOLOCK)  INNER JOIN
                      dbo.T0040_ASSET_MASTER WITH (NOLOCK)  ON a1.Asset_ID = dbo.T0040_ASSET_MASTER.Asset_ID INNER JOIN
                      dbo.T0040_BRAND_MASTER WITH (NOLOCK)  ON a1.Brand_Id = dbo.T0040_BRAND_MASTER.BRAND_ID INNER JOIN
                      dbo.T0040_Asset_Details WITH (NOLOCK)  ON a1.AssetM_ID = dbo.T0040_Asset_Details.AssetM_ID INNER JOIN
                      dbo.T0120_Asset_Approval WITH (NOLOCK)  ON dbo.T0120_Asset_Approval.Asset_Approval_ID = a1.Asset_Approval_ID AND 
                      dbo.T0120_Asset_Approval.Cmp_ID = a1.Cmp_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS E WITH (NOLOCK)  ON dbo.T0120_Asset_Approval.Emp_ID = E.Emp_ID AND E.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER AS B WITH (NOLOCK)  ON dbo.T0120_Asset_Approval.Branch_ID = B.Branch_ID AND B.Cmp_ID = dbo.T0120_Asset_Approval.Cmp_ID LEFT OUTER JOIN
                          (SELECT     I.Emp_ID, I.Branch_ID, I.Cmp_ID
                            FROM          dbo.T0095_INCREMENT AS I WITH (NOLOCK)  INNER JOIN
                                                   dbo.T0080_EMP_MASTER AS E WITH (NOLOCK)  ON E.Emp_ID = I.Emp_ID
                            WHERE      (I.Increment_ID IN
                                                       (SELECT     MAX(Increment_ID) AS Expr1
                                                         FROM          dbo.T0095_INCREMENT WITH (NOLOCK) 
                                                         GROUP BY Emp_ID))) AS mm ON E.Emp_ID = mm.Emp_ID AND E.Cmp_ID = mm.Cmp_ID
WHERE     Return_asset_approval_id IS NULL  AND (a1.asset_approval_id NOT IN
                          (SELECT  isnull(Return_asset_approval_id, 0)Return_asset_approval_id
                            FROM          dbo.t0130_asset_approval_det AS V0040_Asset_Return_1 WITH (NOLOCK)  
                            WHERE    (Application_Type = 1)))    


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[8] 4[5] 2[51] 3) )"
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
         Top = -768
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 25
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1515
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0040_Asset_Allocation';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0040_Asset_Allocation';

