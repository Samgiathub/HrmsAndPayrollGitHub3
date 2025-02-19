






CREATE VIEW [dbo].[V0120_LEAVE_APPROVAL]
AS
SELECT     LAD.From_Date, LAD.To_Date, LAD.Leave_Assign_As, LAD.Leave_Period, LAD.Leave_Approval_ID, LA.Approval_Status, 
			EM.Emp_First_Name, LA.Approval_Date, LAP.Application_Code, LAD.Cmp_ID, LAP.Application_Date, LM.Leave_Name, 
			LM.Leave_Paid_Unpaid, LM.Leave_Min, LM.Leave_Max, LM.Leave_Status, LM.Leave_Applicable, LM.Leave_Notice_Period, 
			LA.Leave_Application_ID, LM.Leave_ID, LAD.Leave_Reason, LAD.Row_ID, EM.Emp_Full_Name, I.Grd_ID, I.Dept_ID, 
			EM.Date_Of_Join, EM.Emp_code, EM.Other_Email, EM.Mobile_No, EM.Emp_ID, isnull(EMS.Emp_Full_Name,'Admin') AS S_emp_Full_Name,
			EMS.Other_Email AS S_Other_Email, LA.S_Emp_ID,LA.Approval_Comments, I.Branch_ID, I.Desig_Id, LM.Leave_Type, EM.Alpha_Emp_Code, 
            ISNULL(LAD.M_Cancel_WO_HO, 0) AS M_Cancel_WO_HO, LAD.Half_Leave_Date, LAD.Leave_CompOff_Dates, LM.Default_Short_Name, 
			EM.Work_Email, LM.Max_No_Of_Application, LM.Apply_Hourly,I.Vertical_ID,I.SubVertical_ID,   --Added By Jaina 22-09-2015
			LAPD.Leave_App_Doc,EMS.Emp_Full_Name AS  Senior_Employee,CASE LA.Is_Backdated_App WHEN 1 THEN '*' ELSE ''END as Is_Backdated_Application,T.Salary_Status,   --Added By Jaina 05-08-2016
            (
				SELECT STUFF((select '; ' + cast(convert(varchar(11),For_date,103) as varchar(max)) + '-' + cast(Leave_period as varchar(10))
					FROM T0150_LEAVE_CANCELLATION   T WITH (NOLOCK)
					WHERE T.Leave_Approval_id=LAD.Leave_Approval_ID
						AND T.Is_Approve=1
					ORDER BY EMP_ID
				FOR XML PATH('')), 1, 1, '') 
      
			) AS CANCEL_DATE,LAD.Leave_out_time,LAD.Leave_In_Time,LAD.Half_Payment,LA.Is_Backdated_App,LAD.Rules_violate,
			ER.Alpha_Emp_Code + ' - ' + ER.Emp_Full_Name As Responsible_Employee,I.SalDate_id , case when Is_Backdated_App = 1 then 1 else 0 end as Back_Dated_Leave,
			Responsible_Emp_id,1 AS 'is_Final_Approved',Branch_Name
FROM	dbo.T0080_EMP_MASTER AS EM  WITH (NOLOCK)
		INNER JOIN dbo.T0095_INCREMENT I WITH (NOLOCK) ON EM.Emp_ID=I.EMP_ID
		INNER JOIN (SELECT	I1.Emp_ID, Max(I1.Increment_ID) As Increment_ID
					FROM	dbo.T0095_INCREMENT I1  WITH (NOLOCK)
							INNER JOIN (SELECT	I2.Emp_ID, Max(I2.Increment_Effective_Date) As Increment_Effective_Date
										FROM	dbo.T0095_INCREMENT I2 WITH (NOLOCK)
										WHERE	I2.Increment_Effective_Date <= GETDATE()
										GROUP BY I2.Emp_ID) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_Effective_Date=I2.Increment_Effective_Date
					GROUP BY I1.Emp_ID) I1 ON I.Increment_ID=I1.Increment_ID                      
		INNER JOIN	dbo.T0120_LEAVE_APPROVAL LA WITH (NOLOCK) ON EM.Emp_ID=LA.Emp_ID
		LEFT OUTER JOIN dbo.T0080_EMP_MASTER EMS WITH (NOLOCK) ON LA.S_Emp_ID = EMS.Emp_ID AND LA.S_Emp_ID = EMS.Emp_ID 
		Left outer join dbo.T0030_BRANCH_MASTER Bm WITH (NOLOCK) ON BM.Branch_ID = I.Branch_ID
		LEFT OUTER JOIN dbo.T0100_LEAVE_APPLICATION LAP WITH (NOLOCK) ON LA.Leave_Application_ID = LAP.Leave_Application_ID 		
		LEFT OUTER JOIN dbo.T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Approval_ID = LAD.Leave_Approval_ID
		LEFT OUTER JOIN dbo.T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LAD.Leave_ID=LM.Leave_ID
		LEFT OUTER JOIN (SELECT	Leave_Application_ID, Leave_App_Doc 
						 FROM	T0110_LEAVE_APPLICATION_DETAIL WITH (NOLOCK) 
						 WHERE	LEAVE_APP_DOC <> '' 
						 GROUP BY Leave_Application_ID, Leave_App_Doc) LAPD ON LAP.Leave_Application_ID=LAPD.Leave_Application_ID	
		LEFT OUTER JOIN (SELECT LAD.Leave_Approval_ID, lad.From_Date, LAD.To_Date, MIN(SAL.Month_St_Date) Month_St_Date, Min(SAL.Month_End_Date) Month_End_Date,Min(SAL.Salary_Status) Salary_Status
						 FROM	T0130_LEAVE_APPROVAL_DETAIL LAD  WITH (NOLOCK)
								INNER JOIN T0120_LEAVE_APPROVAL LA1 WITH (NOLOCK) ON lad.Leave_Approval_ID=LA1.Leave_Approval_ID
								INNER JOIN T0200_MONTHLY_SALARY SAL WITH (NOLOCK) ON ((lad.From_Date BETWEEN SAL.Month_St_Date AND SAL.Month_End_Date) OR (lad.To_Date BETWEEN SAL.Month_St_Date AND SAL.Month_End_Date)) AND LA1.Emp_ID=SAL.Emp_ID
						GROUP BY LAD.Leave_Approval_ID, lad.From_Date, LAD.To_Date
						  ) T ON LA.Leave_Approval_ID=T.Leave_Approval_ID 	 
		LEFT OUTER JOIN T0080_EMP_MASTER ER WITH (NOLOCK) ON ER.Emp_ID = LAP.Responsible_Emp_id





GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[63] 4[5] 2[9] 3) )"
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
         Begin Table = "T0080_EMP_MASTER_1"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 263
            End
            DisplayFlags = 280
            TopColumn = 32
         End
         Begin Table = "T0095_INCREMENT"
            Begin Extent = 
               Top = 6
               Left = 301
               Bottom = 125
               Right = 517
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0120_LEAVE_APPROVAL"
            Begin Extent = 
               Top = 6
               Left = 555
               Bottom = 125
               Right = 748
            End
            DisplayFlags = 280
            TopColumn = 7
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 245
               Right = 263
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0100_LEAVE_APPLICATION"
            Begin Extent = 
               Top = 126
               Left = 301
               Bottom = 245
               Right = 498
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_LEAVE_MASTER"
            Begin Extent = 
               Top = 126
               Left = 536
               Bottom = 245
               Right = 818
            End
            DisplayFlags = 280
            TopColumn = 46
         End
         Begin Table = "T0130_LEAVE_APPROVAL_DETAIL"
            Begin Extent = 
               Top = 246
               Left = 38
               Bott', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0120_LEAVE_APPROVAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'om = 365
               Right = 222
            End
            DisplayFlags = 280
            TopColumn = 14
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 44
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0120_LEAVE_APPROVAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0120_LEAVE_APPROVAL';

