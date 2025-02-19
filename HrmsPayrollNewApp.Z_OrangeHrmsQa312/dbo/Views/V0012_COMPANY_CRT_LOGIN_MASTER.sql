





CREATE VIEW [dbo].[V0012_COMPANY_CRT_LOGIN_MASTER]
AS
SELECT		login.Cmp_ID, login.cmp_count, login.Last_login_date, login.Create_date, cmp.Cmp_Name, cmp.Cmp_Address, cmp.Loc_ID, 
			cmp.Cmp_City, cmp.Cmp_PinCode, cmp.Cmp_Phone, cmp.Cmp_Email, cmp.Cmp_Web, cmp.Date_Format, cmp.From_Date, cmp.To_Date, 
			cmp.PF_No, cmp.ESIC_No, cmp.Domain_Name, cmp.Image_name, cmp.Default_Holiday, 'admin' + cmp.Domain_Name AS Login_ID , Active_Emp
FROM        dbo.T0010_COMPANY_MASTER AS cmp WITH (NOLOCK)
			INNER JOIN
				  (
						SELECT     x.Cmp_ID, ISNULL(new.cmp_count, 0) AS cmp_count, x.Last_login_date, x.Create_date , ISNULL(ACT.Active_Emp,0) AS Active_Emp
						FROM       dbo.T0012_COMPANY_CRT_LOGIN_MASTER AS x  WITH (NOLOCK)
						LEFT OUTER JOIN
											   (	--Counting Total Number of Employees in Company ( Active + Left )
												 SELECT     COUNT(q.Emp_ID) AS cmp_count, q.Cmp_ID
												 FROM          dbo.T0080_EMP_MASTER AS q  WITH (NOLOCK)
												 LEFT OUTER JOIN dbo.T0012_COMPANY_CRT_LOGIN_MASTER AS f WITH (NOLOCK) ON q.Cmp_ID = f.Cmp_ID
												 GROUP BY q.Cmp_ID
												) AS new ON x.Cmp_ID = new.Cmp_ID
						LEFT OUTER JOIN
											   (	--Counting Total Active Employees in Company ( Only Active ) (Ramiz 20092017)
												 SELECT     COUNT(E.Emp_ID) AS Active_Emp, E.Cmp_ID
												 FROM          dbo.T0080_EMP_MASTER AS E WITH (NOLOCK)
												 WHERE E.Emp_Left = 'N' 
												 GROUP BY E.Cmp_ID
												) AS ACT ON x.Cmp_ID = ACT.Cmp_ID
						GROUP BY x.Cmp_ID, new.cmp_count, x.Last_login_date, x.Create_date , act.Active_Emp
					) AS login ON cmp.Cmp_Id = login.Cmp_ID
			WHERE cmp.Is_Active = 1





GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[13] 4[4] 2[40] 3) )"
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
         Begin Table = "cmp"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 279
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "login"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 245
               Right = 203
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0012_COMPANY_CRT_LOGIN_MASTER';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0012_COMPANY_CRT_LOGIN_MASTER';

