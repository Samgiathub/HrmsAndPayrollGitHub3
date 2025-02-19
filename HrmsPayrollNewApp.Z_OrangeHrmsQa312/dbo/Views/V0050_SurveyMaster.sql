


CREATE VIEW [dbo].[V0050_SurveyMaster]
AS
select Survey_ID,T0050_SurveyMaster.Cmp_ID,
case when Start_Time <>'' then  convert(varchar(15),SurveyStart_Date,103) + ' ' + Start_Time else convert(varchar(15),SurveyStart_Date,103) end as SurveyStart_Date,
SurveyEnd_Date,Min_Passing_Criteria,
convert(varchar(15),Survey_OpenTill,107) as SurveyEndDate,convert(varchar(15),SurveyStart_Date,107) as SurveyStartDate,Survey_Title,Survey_Purpose,
case when End_Time <>'' then  convert(varchar(15),Survey_OpenTill,103) + ' ' + End_Time else convert(varchar(15),Survey_OpenTill,103) end as Survey_OpenTill,
Survey_Instruction,Survey_CreatedBy, T0050_SurveyMaster.Branch_Id,Desig_ID,
case when  T0050_SurveyMaster.Branch_Id IS null then '' else  T0030_BRANCH_MASTER.branch_name end branch_name,
case when Desig_ID IS not null then
(SELECT     dm.Desig_Name + ','
FROM          T0040_DESIGNATION_MASTER dm WITH (NOLOCK)
WHERE      dm.Desig_ID IN
(SELECT     cast(data AS numeric(18, 0))
 FROM          dbo.Split(ISNULL(Desig_ID, '0'), '#')
 WHERE      data <> '') FOR XML path('')) ELSE 'ALL' END Desig_Name, 
Survey_EmpId , case when Survey_EmpId IS not null then
(SELECT     E.Emp_Full_Name + ','
FROM          T0080_EMP_MASTER E WITH (NOLOCK)
WHERE      E.Emp_ID IN
(SELECT     cast(data AS numeric(18, 0))
 FROM          dbo.Split(ISNULL(Survey_EmpId, '0'), '#')
 WHERE      data <> '') FOR XML path('')) ELSE 'ALL' END AS Employee, Start_Time,End_Time
 --dbo.F_GET_AMPM (Start_Time)Start_Time, dbo.F_GET_AMPM (End_Time)End_Time
from T0050_SurveyMaster WITH (NOLOCK) 
left join T0030_BRANCH_MASTER WITH (NOLOCK)
on T0030_BRANCH_MASTER.Branch_ID = T0050_SurveyMaster.Branch_ID  






GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[26] 4[24] 2[18] 3) )"
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
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 14
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0050_SurveyMaster';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0050_SurveyMaster';

