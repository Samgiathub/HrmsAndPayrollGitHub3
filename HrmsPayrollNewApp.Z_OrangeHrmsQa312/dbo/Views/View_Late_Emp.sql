









CREATE VIEW [dbo].[View_Late_Emp]
AS
SELECT     TOP (100) PERCENT dbo.T0150_EMP_INOUT_RECORD.IO_Tran_Id, dbo.T0080_EMP_MASTER.Emp_ID, dbo.T0150_EMP_INOUT_RECORD.For_Date
					--,ISNULL(dbo.T0150_EMP_INOUT_RECORD.In_Time, dbo.T0150_EMP_INOUT_RECORD.In_Date_Time)  as In_Time
					 ,
					 --Case when isnull(Chk_By_Superior,0) = 0 then
					 --null
					 --else
					 --Case when Cast(ISNULL(dbo.T0150_EMP_INOUT_RECORD.In_Time, dbo.T0150_EMP_INOUT_RECORD.In_Date_Time) as Time)  = Cast(Shift_St_Time as Time)
					 --then NULL 
					 --else 
					 --ISNULL(
					 dbo.T0150_EMP_INOUT_RECORD.In_Time--, dbo.T0150_EMP_INOUT_RECORD.In_Date_Time) 
					 --END 
					 --end 	 
					 AS In_Time  -- Change by ronakk 21112022

					 --,Case when Cast(ISNULL(dbo.T0150_EMP_INOUT_RECORD.Out_Time, dbo.T0150_EMP_INOUT_RECORD.Out_Date_Time) as Time)  
					 --= Cast(Shift_End_Time as Time)
					 --then NULL else ISNULL(dbo.T0150_EMP_INOUT_RECORD.Out_Time, dbo.T0150_EMP_INOUT_RECORD.Out_Date_Time) END AS Out_Time
					 
					 ,dbo.T0150_EMP_INOUT_RECORD.Reason, dbo.T0080_EMP_MASTER.Cmp_ID, I.Branch_ID,I.subBranch_ID,
					  BM.Branch_Name,I.Grd_ID, I.Dept_ID, I.Desig_Id, I.Type_ID, dbo.T0080_EMP_MASTER.Emp_code, 
                      CAST(dbo.T0080_EMP_MASTER.Alpha_Emp_Code + '-' + dbo.T0080_EMP_MASTER.Emp_Full_Name AS Varchar(50)) AS Emp_Full_Name, 
                      dbo.T0080_EMP_MASTER.Alpha_Emp_Code, dbo.T0080_EMP_MASTER.Alpha_Code, dbo.T0080_EMP_MASTER.Emp_Superior, 
                      ISNULL(dbo.T0150_EMP_INOUT_RECORD.Chk_By_Superior, 0) AS Chk_By_Superior, dbo.T0150_EMP_INOUT_RECORD.Half_Full_day, 
                      dbo.T0150_EMP_INOUT_RECORD.Sup_Comment, dbo.T0080_EMP_MASTER.Emp_Full_Name AS Emp_Name, 
                      ISNULL(dbo.T0150_EMP_INOUT_RECORD.Is_Cancel_Late_In, 0) AS Is_Cancel_Late_In, ISNULL(Qry.Is_Cancel_Early_Out, 0) AS Is_Cancel_Early_Out, 
                      --isnull(Qry1.Out_Time,Qry1.Out_Date_Time) as Out_Time, 
					  --CASE  WHEN CAST(CONVERT(varchar(16),QRY2.MAX_IN_TIME,120) AS DATETIME) > CAST(CONVERT(VARCHAR(16)
					  --,ISNULL(Qry1.Out_Time,Qry1.Out_Date_Time),120)AS DATETIME) 
					  --Then CAST(CONVERT(VARCHAR(16),QRY2.MAX_IN_TIME,120)as DATETIME) 
					  --Else CAST(CONVERT(VARCHAR(16),ISNULL(Qry1.Out_Time,Qry1.Out_Date_Time),120) AS DATETIME) End as Out_Time

					  -- Case when  isnull(Chk_By_Superior,0)  = 0 then
						--null
						--else
						--CASE  WHEN (CAST(CONVERT(varchar(16),QRY2.MAX_IN_TIME,120) AS TIME) = CAST( Shift_End_Time as time) 
						--OR CAST(ISNULL(Qry1.Out_Time,Qry1.Out_Date_Time) AS TIME) = CAST( Shift_End_Time as time)) 
						-- Then null
						-- WHEN CAST(CONVERT(varchar(16),QRY2.MAX_IN_TIME,120) AS DATETIME) > CAST(CONVERT(VARCHAR(16),ISNULL(Qry1.Out_Time,Qry1.Out_Date_Time),120)AS DATETIME) 
						-- Then CAST(CONVERT(VARCHAR(16),QRY2.MAX_IN_TIME,120)as DATETIME) 
						-- Else  
						 CAST(CONVERT(VARCHAR(16),
						-- ISNULL(
						 Qry1.Out_Time
						 --,Qry1.Out_Date_Time)
						 ,120) AS DATETIME) --Comment by ronakk 19112022
						-- End 
						 --end 
						 as Out_Time
					  ,CAST(ERM.Alpha_Emp_Code + '-' + ERM.Emp_Full_Name AS varchar(50)) AS Superior,
                       ERM.Alpha_Emp_Code AS Superior_Code, case when REPLACE(CONVERT(VARCHAR(11),T0150_EMP_INOUT_RECORD.App_Date,103), ' ','/')  = '01/01/1900' then null  else T0150_EMP_INOUT_RECORD.App_Date end as App_Date
                      ,dbo.T0150_EMP_INOUT_RECORD.Other_Reason
                      ,I.Vertical_ID,I.SubVertical_ID --added jimit 29042016
					  ,dbo.T0150_EMP_INOUT_RECORD.In_Time AS Actual_In_Time, dbo.T0150_EMP_INOUT_RECORD.Out_Time AS Actual_Out_Time,s.Shift_End_Time,s.Shift_St_Time
					  --,S.Shift_ID
FROM         dbo.T0080_EMP_MASTER WITH (NOLOCK)
		INNER JOIN	dbo.T0150_EMP_INOUT_RECORD WITH (NOLOCK) ON dbo.T0080_EMP_MASTER.Emp_ID = dbo.T0150_EMP_INOUT_RECORD.Emp_ID 
		LEFT OUTER JOIN
			(	SELECT  DISTINCT   Is_Cancel_Early_Out, For_Date, Emp_ID
                FROM          dbo.T0150_EMP_INOUT_RECORD AS EIR WITH (NOLOCK)
                WHERE      (Is_Cancel_Early_Out = 1)
             ) AS Qry ON dbo.T0150_EMP_INOUT_RECORD.For_Date = Qry.For_Date AND dbo.T0150_EMP_INOUT_RECORD.Emp_ID = Qry.Emp_ID 
        LEFT OUTER JOIN
             (	SELECT     For_Date, Emp_ID, MAX(Out_Time) AS Out_Time,Max(Out_Date_Time) as Out_Date_Time
                FROM          dbo.T0150_EMP_INOUT_RECORD AS T0150_EMP_INOUT_RECORD_1 WITH (NOLOCK)
                GROUP BY For_Date, Emp_ID
             ) AS Qry1 ON dbo.T0150_EMP_INOUT_RECORD.For_Date = Qry1.For_Date AND dbo.T0150_EMP_INOUT_RECORD.Emp_ID = Qry1.Emp_ID 
       LEFT OUTER JOIN
             (	SELECT     For_Date, Emp_ID, MAX(In_Time) AS MAX_IN_TIME
                FROM          dbo.T0150_EMP_INOUT_RECORD AS T0150_EMP_INOUT_RECORD_1 WITH (NOLOCK)
                GROUP BY For_Date, Emp_ID
             ) AS Qry2 ON dbo.T0150_EMP_INOUT_RECORD.For_Date = Qry2.For_Date AND dbo.T0150_EMP_INOUT_RECORD.Emp_ID = Qry2.Emp_ID 
        INNER JOIN  dbo.T0095_INCREMENT AS I WITH (NOLOCK) ON dbo.T0080_EMP_MASTER.Increment_ID = I.Increment_ID 
       LEFT OUTER JOIN  dbo.T0040_Reason_Master AS rm WITH (NOLOCK) ON rm.Reason_Name = dbo.T0150_EMP_INOUT_RECORD.Reason and RM.Type = 'R' 
        --LEFT OUTER JOIN  dbo.T0080_EMP_MASTER AS T0080_EMP_MASTER_1 ON T0080_EMP_MASTER.Emp_Superior = T0080_EMP_MASTER_1.Emp_ID
        LEFT OUTER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) on BM.Branch_ID = I.Branch_ID
		LEFT OUTER JOIN T0050_SubBranch SBM WITH (NOLOCK) on SBM.SubBranch_ID = I.SubBranch_ID
       --There is wrong Reporting Manager bind for employee at WCL   changed by jimit 27102017
       Left Join
								(SELECT		Q.EMP_ID,MAX(RD.R_EMP_ID) AS R_EMP_ID 
								 FROM		T0090_EMP_REPORTING_DETAIL RD WITH (NOLOCK) INNER JOIN
											(SELECT  MAX(EFFECT_DATE) MAX_DATE,EMP_ID 
											 FROM	 T0090_EMP_REPORTING_DETAIL  WITH (NOLOCK)
											 WHERE	 EFFECT_DATE <= getdate() 
											 GROUP BY EMP_ID)Q ON Q.EMP_ID = RD.EMP_ID AND Q.MAX_DATE = RD.EFFECT_DATE								 
								 GROUP BY Q.EMP_ID)MAIN	ON Main.Emp_ID = T0080_EMP_MASTER.Emp_ID LEFT JOIN 
											T0080_EMP_MASTER ERM WITH (NOLOCK) ON MAIN.R_EMP_ID = ERM.EMP_ID AND ERM.EMP_LEFT <> 'Y'		
		Left Join T0040_SHIFT_MASTER s on s.Shift_ID = T0080_EMP_MASTER.Shift_ID
		
WHERE     (dbo.T0150_EMP_INOUT_RECORD.Reason IS NOT NULL) AND (dbo.T0150_EMP_INOUT_RECORD.Reason <> '')
	and (dbo.T0150_EMP_INOUT_RECORD.App_Date is not null or dbo.T0150_EMP_INOUT_RECORD.apr_date is not null) --Added By Jimit 31122018 
ORDER BY dbo.T0080_EMP_MASTER.Emp_code





GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'View_Late_Emp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[45] 4[5] 2[28] 3) )"
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
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 255
            End
            DisplayFlags = 280
            TopColumn = 44
         End
         Begin Table = "T0150_EMP_INOUT_RECORD"
            Begin Extent = 
               Top = 0
               Left = 279
               Bottom = 229
               Right = 455
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Qry"
            Begin Extent = 
               Top = 6
               Left = 493
               Bottom = 106
               Right = 675
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Qry1"
            Begin Extent = 
               Top = 6
               Left = 713
               Bottom = 106
               Right = 865
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "I"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 241
               Right = 272
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "rm"
            Begin Extent = 
               Top = 6
               Left = 903
               Bottom = 95
               Right = 1063
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0080_EMP_MASTER_1"
            Begin Extent = 
               Top = 96
               Left = 903
               Bottom = 215
               Right = 1128
            End
            Display', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'View_Late_Emp';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'Flags = 280
            TopColumn = 38
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 26
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
         Width = 3285
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 645
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'View_Late_Emp';

