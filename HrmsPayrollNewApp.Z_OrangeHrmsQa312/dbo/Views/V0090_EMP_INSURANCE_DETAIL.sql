



CREATE VIEW [dbo].[V0090_EMP_INSURANCE_DETAIL]
AS
SELECT     dbo.T0040_INSURANCE_MASTER.Ins_Name, dbo.T0040_INSURANCE_MASTER.Ins_Tran_ID, dbo.T0090_EMP_INSURANCE_DETAIL.Cmp_ID, 
                      dbo.T0090_EMP_INSURANCE_DETAIL.Emp_Id, dbo.T0090_EMP_INSURANCE_DETAIL.Emp_Ins_Tran_ID, 
                      dbo.T0090_EMP_INSURANCE_DETAIL.Ins_Cmp_name, dbo.T0090_EMP_INSURANCE_DETAIL.Ins_Policy_No, 
                      dbo.T0090_EMP_INSURANCE_DETAIL.Ins_Taken_Date, dbo.T0090_EMP_INSURANCE_DETAIL.Ins_Due_Date, 
                      dbo.T0090_EMP_INSURANCE_DETAIL.Ins_Exp_Date, dbo.T0090_EMP_INSURANCE_DETAIL.Ins_Amount, 
                      dbo.T0090_EMP_INSURANCE_DETAIL.Ins_Anual_Amt, dbo.T0040_INSURANCE_MASTER.Type, 
                      dbo.T0090_EMP_INSURANCE_DETAIL.Deduct_From_Salary, dbo.T0090_EMP_INSURANCE_DETAIL.Monthly_Premium, 
                      dbo.T0090_EMP_INSURANCE_DETAIL.Sal_Effective_Date,
                      LEFT(dbo.T0090_EMP_INSURANCE_DETAIL.Emp_Dependent_ID,LEN(dbo.T0090_EMP_INSURANCE_DETAIL.Emp_Dependent_ID) - 1)  AS Emp_Dependent_ID
                      ,ISNULL(CASE WHEN LEFT(dbo.T0090_EMP_INSURANCE_DETAIL.Emp_Dependent_ID,1) = '0' THEN 'Self,' ELSE '' END ,'') + 
					 ISNULL(( SELECT STUFF((SELECT		',' + char(10) + B.Name +'-'+ Relationship 
										FROM		T0090_EMP_CHILDRAN_DETAIL B WITH (NOLOCK) INNER JOIN 
										( SELECT	CAST(DATA AS NUMERIC(18,0)) AS Row_ID FROM	dbo.Split(left(dbo.T0090_EMP_INSURANCE_DETAIL.Emp_dependent_Id,len(dbo.T0090_EMP_INSURANCE_DETAIL.Emp_dependent_Id) - 1), '#')
										  Where	IsNull(data, '') <> ''
										) MB ON B.Row_ID= MB.Row_ID 
										WHERE		B.Cmp_ID=dbo.T0090_EMP_INSURANCE_DETAIL.Cmp_ID AND Emp_Dependent_ID is NOT NULL 
										FOR XML PATH('')
									),1,1,'') 
					  ),'') As Emp_Dependent_Name_Detail FROM         dbo.T0040_INSURANCE_MASTER WITH (NOLOCK) INNER JOIN
                      dbo.T0090_EMP_INSURANCE_DETAIL WITH (NOLOCK) ON dbo.T0040_INSURANCE_MASTER.Ins_Tran_ID = dbo.T0090_EMP_INSURANCE_DETAIL.Ins_Tran_ID





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
         Begin Table = "T0040_INSURANCE_MASTER"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 190
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "T0090_EMP_INSURANCE_DETAIL"
            Begin Extent = 
               Top = 6
               Left = 228
               Bottom = 121
               Right = 395
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_EMP_INSURANCE_DETAIL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0090_EMP_INSURANCE_DETAIL';

