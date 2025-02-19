



CREATE VIEW [dbo].[V0095_LEAVE_OPENING]
AS
SELECT     dbo.T0095_LEAVE_OPENING.Leave_Op_ID, dbo.T0095_LEAVE_OPENING.Emp_Id, dbo.T0095_LEAVE_OPENING.Grd_ID, dbo.T0095_LEAVE_OPENING.Cmp_ID, 
                      dbo.T0095_LEAVE_OPENING.Leave_ID, dbo.T0095_LEAVE_OPENING.For_Date, dbo.T0095_LEAVE_OPENING.Leave_Op_Days, 
                      dbo.T0040_LEAVE_MASTER.Leave_Name, dbo.T0040_LEAVE_MASTER.Leave_CF_Type, dbo.T0040_LEAVE_MASTER.Leave_Notice_Period, 
                      dbo.T0040_LEAVE_MASTER.Leave_Applicable, dbo.T0040_LEAVE_MASTER.Leave_Min, dbo.T0040_LEAVE_MASTER.Leave_Max, 
                      dbo.T0040_LEAVE_MASTER.Leave_Min_Bal, dbo.T0040_LEAVE_MASTER.Leave_Max_Bal, dbo.T0080_EMP_MASTER.Date_Of_Join, 
                      dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0040_LEAVE_MASTER.Default_Short_Name, dbo.T0040_LEAVE_MASTER.Leave_Status, 
                      dbo.T0040_LEAVE_MASTER.InActive_Effective_Date,
                      dbo.T0080_EMP_MASTER.Alpha_Emp_Code +' - '+dbo.T0080_EMP_MASTER.Emp_Full_Name  As Employee_Name,T0040_GRADE_MASTER.Grd_Name,
                      dbo.T0080_EMP_MASTER.Alpha_Emp_Code,
                      dbo.T0080_EMP_MASTER.Branch_ID,dbo.T0080_EMP_MASTER.Vertical_ID,dbo.T0080_EMP_MASTER.SubVertical_ID,dbo.T0080_EMP_MASTER.Dept_ID,
                      dbo.T0040_LEAVE_MASTER.Leave_Type
FROM         dbo.T0095_LEAVE_OPENING WITH (NOLOCK)  
			LEFT OUTER JOIN dbo.T0080_EMP_MASTER WITH (NOLOCK) ON dbo.T0095_LEAVE_OPENING.Emp_Id = dbo.T0080_EMP_MASTER.Emp_ID 
            Cross Apply dbo.fn_getEmpIncrement(T0095_LEAVE_OPENING.Cmp_ID, T0095_LEAVE_OPENING.Emp_ID, GETDATE())QRY1 
				INNER JOIN  T0095_INCREMENT I_Q WITH (NOLOCK) ON  QRY1.Emp_ID = I_Q.Emp_ID AND QRY1.Increment_id = I_Q.Increment_Id
        --              INNER JOIN (SELECT	MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
								--	FROM	T0095_INCREMENT I2 
								--			INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
								--						FROM	T0095_INCREMENT I3 INNER JOIN T0080_EMP_MASTER EM ON EM.Emp_ID = I3.EMp_ID									
								--						WHERE	I3.Increment_Effective_Date <=  GETDATE() --(Case WHEN EM.Date_Of_Join >= GETDATE() then EM.Date_Of_Join Else GETDATE() END)
								--								and I3.Increment_Type NOT In ('Transfer','Deputation')
								--						GROUP BY I3.Emp_ID
								--						) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
				 
								--	GROUP BY I2.Emp_ID
								--)I3_Q On I3_Q.Increment_ID = I_Q.Increment_ID and I_Q.Emp_ID=I3_Q.Emp_ID
			LEFT OUTER JOIN dbo.T0040_LEAVE_MASTER WITH (NOLOCK) ON dbo.T0095_LEAVE_OPENING.Leave_ID = dbo.T0040_LEAVE_MASTER.Leave_ID 
			INNER JOIN dbo.T0040_GRADE_MASTER WITH (NOLOCK) ON dbo.T0040_GRADE_MASTER.Grd_ID = I_Q.Grd_ID





GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0095_LEAVE_OPENING';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[21] 2[33] 3) )"
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
         Begin Table = "T0095_LEAVE_OPENING"
            Begin Extent = 
               Top = 4
               Left = 0
               Bottom = 119
               Right = 160
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 6
               Left = 236
               Bottom = 121
               Right = 453
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_LEAVE_MASTER"
            Begin Extent = 
               Top = 107
               Left = 567
               Bottom = 222
               Right = 778
            End
            DisplayFlags = 280
            TopColumn = 43
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 18
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0095_LEAVE_OPENING';

