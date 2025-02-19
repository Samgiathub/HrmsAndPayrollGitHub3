





/*ALTER VIEW [dbo].[V0055_Resume_View1]
AS
SELECT     ISNULL(dbo.T0052_HRMS_Posted_Recruitment.Job_title, '') AS Job_Title, 
                      isnull(dbo.T0055_Resume_Master.Initial,'') + ' ' + dbo.T0055_Resume_Master.Emp_First_Name + ' ' + ISNULL(dbo.T0055_Resume_Master.Emp_Second_Name,
                       '') + ' ' + dbo.T0055_Resume_Master.Emp_Last_Name AS App_Full_name, ISNULL(dbo.T0055_Resume_Master.Total_Exp, 0) AS Total_Experience, 
                      dbo.T0080_EMP_MASTER.Branch_ID, dbo.T0055_Resume_Master.Resume_Id, dbo.T0055_Resume_Master.Cmp_id, 
                      dbo.T0055_Resume_Master.Rec_Post_Id, dbo.T0055_Resume_Master.Resume_Posted_date, dbo.T0055_Resume_Master.Initial, 
                      dbo.T0055_Resume_Master.Emp_First_Name, dbo.T0055_Resume_Master.Emp_Second_Name, dbo.T0055_Resume_Master.Emp_Last_Name, 
                      ISNULL(dbo.T0055_Resume_Master.Date_Of_Birth, '') AS Date_Of_Birth, dbo.T0055_Resume_Master.Marital_Status, 
                      dbo.T0055_Resume_Master.Gender, dbo.T0055_Resume_Master.Present_Street, dbo.T0055_Resume_Master.Present_City, 
                      dbo.T0055_Resume_Master.Present_State, dbo.T0055_Resume_Master.Present_Post_Box, dbo.T0055_Resume_Master.Permanent_Street, 
                      dbo.T0055_Resume_Master.Permanent_City, dbo.T0055_Resume_Master.Permanent_State, dbo.T0055_Resume_Master.Permanentt_Post_Box, 
                      dbo.T0055_Resume_Master.Home_Tel_no, ISNULL(dbo.T0055_Resume_Master.Mobile_No, 0) AS Mobile_No, 
                      dbo.T0055_Resume_Master.Primary_email, dbo.T0055_Resume_Master.Other_Email, dbo.T0055_Resume_Master.Cur_CTC, 
                      dbo.T0055_Resume_Master.Exp_CTC, dbo.T0055_Resume_Master.Resume_Name, dbo.T0055_Resume_Master.File_Name, 
                      dbo.T0055_Resume_Master.Resume_Status, dbo.T0055_Resume_Master.Final_CTC, dbo.T0055_Resume_Master.Date_Of_Join, 
                      dbo.T0055_Resume_Master.Basic_Salary, dbo.T0055_Resume_Master.Emp_Full_PF, dbo.T0055_Resume_Master.Emp_Fix_Salary, 
                      dbo.T0055_Resume_Master.Present_Loc, dbo.T0055_Resume_Master.Permanent_Loc_ID, ISNULL(dbo.T0001_LOCATION_MASTER.Loc_name, '') 
                      AS loc_name, dbo.T0080_EMP_MASTER.Emp_Full_Name, dbo.T0055_Interview_Process_Detail.Dis_No, dbo.T0080_EMP_MASTER.Work_Email, 
                      dbo.T0080_EMP_MASTER.Emp_ID, dbo.T0055_Interview_Process_Detail.Interview_Process_detail_ID, 
                      dbo.T0052_HRMS_Posted_Recruitment.S_Emp_id, dbo.T0055_Interview_Process_Detail.S_Emp_ID AS S_Emp, 
                      dbo.T0052_HRMS_Posted_Recruitment.Rec_Start_date, dbo.T0052_HRMS_Posted_Recruitment.Rec_End_date, 
                      dbo.T0055_Resume_Master.Non_Technical_Skill, T0040_HRMS_R_PROCESS_MASTER_1.Process_Name, 
                      dbo.T0052_HRMS_Posted_Recruitment.Location, dbo.T0055_Resume_Master.Resume_Code
FROM         dbo.T0052_HRMS_Posted_Recruitment LEFT OUTER JOIN
                      dbo.T0055_Interview_Process_Detail ON 
                      dbo.T0055_Interview_Process_Detail.Rec_Post_ID = dbo.T0052_HRMS_Posted_Recruitment.Rec_Post_Id LEFT OUTER JOIN
                      dbo.T0040_HRMS_R_PROCESS_MASTER ON 
                      dbo.T0040_HRMS_R_PROCESS_MASTER.Process_ID = dbo.T0055_Interview_Process_Detail.Process_ID LEFT OUTER JOIN
                      dbo.T0040_HRMS_R_PROCESS_MASTER AS T0040_HRMS_R_PROCESS_MASTER_1 ON 
                      T0040_HRMS_R_PROCESS_MASTER_1.Process_ID = dbo.T0055_Interview_Process_Detail.Process_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER ON dbo.T0055_Interview_Process_Detail.S_Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID RIGHT OUTER JOIN
                      dbo.T0055_Resume_Master ON dbo.T0055_Resume_Master.Rec_Post_Id = dbo.T0052_HRMS_Posted_Recruitment.Rec_Post_Id LEFT OUTER JOIN
                      dbo.T0001_LOCATION_MASTER ON dbo.T0001_LOCATION_MASTER.Loc_ID = dbo.T0055_Resume_Master.Permanent_Loc_ID
GO*/
CREATE VIEW [dbo].[V0055_Resume_View1]
AS
SELECT     ISNULL(dbo.T0052_HRMS_Posted_Recruitment.Job_title, '') AS Job_Title, ISNULL(dbo.T0055_Resume_Master.Initial, '') 
                      + ' ' + dbo.T0055_Resume_Master.Emp_First_Name + ' ' + ISNULL(dbo.T0055_Resume_Master.Emp_Second_Name, '') 
                      + ' ' + dbo.T0055_Resume_Master.Emp_Last_Name AS App_Full_name, ISNULL(dbo.T0055_Resume_Master.Total_Exp, 0) AS Total_Experience, 
                      dbo.T0080_EMP_MASTER.Branch_ID, dbo.T0055_Resume_Master.Resume_Id, dbo.T0055_Resume_Master.Cmp_id, dbo.T0055_Resume_Master.Rec_Post_Id, 
                      dbo.T0055_Resume_Master.Resume_Posted_date, dbo.T0055_Resume_Master.Initial, dbo.T0055_Resume_Master.Emp_First_Name, 
                      dbo.T0055_Resume_Master.Emp_Second_Name, dbo.T0055_Resume_Master.Emp_Last_Name, ISNULL(dbo.T0055_Resume_Master.Date_Of_Birth, '') 
                      AS Date_Of_Birth, dbo.T0055_Resume_Master.Marital_Status, dbo.T0055_Resume_Master.Gender, dbo.T0055_Resume_Master.Present_Street, 
                      dbo.T0055_Resume_Master.Present_City, dbo.T0055_Resume_Master.Present_State, dbo.T0055_Resume_Master.Present_Post_Box, 
                      dbo.T0055_Resume_Master.Permanent_Street, dbo.T0055_Resume_Master.Permanent_City, dbo.T0055_Resume_Master.Permanent_State, 
                      dbo.T0055_Resume_Master.Permanentt_Post_Box, dbo.T0055_Resume_Master.Home_Tel_no, ISNULL(dbo.T0055_Resume_Master.Mobile_No, 0) AS Mobile_No, 
                      dbo.T0055_Resume_Master.Primary_email, dbo.T0055_Resume_Master.Other_Email, dbo.T0055_Resume_Master.Cur_CTC, dbo.T0055_Resume_Master.Exp_CTC, 
                      dbo.T0055_Resume_Master.Resume_Name, dbo.T0055_Resume_Master.File_Name, dbo.T0055_Resume_Master.Resume_Status, 
                      dbo.T0055_Resume_Master.Final_CTC, dbo.T0055_Resume_Master.Date_Of_Join, dbo.T0055_Resume_Master.Basic_Salary, 
                      dbo.T0055_Resume_Master.Emp_Full_PF, dbo.T0055_Resume_Master.Emp_Fix_Salary, dbo.T0055_Resume_Master.Present_Loc, 
                      dbo.T0055_Resume_Master.Permanent_Loc_ID, ISNULL(dbo.T0001_LOCATION_MASTER.Loc_name, '') AS loc_name, dbo.T0080_EMP_MASTER.Emp_Full_Name, 
                      dbo.T0055_Interview_Process_Detail.Dis_No, dbo.T0080_EMP_MASTER.Work_Email, dbo.T0080_EMP_MASTER.Emp_ID, 
                      dbo.T0055_Interview_Process_Detail.Interview_Process_detail_ID, dbo.T0052_HRMS_Posted_Recruitment.S_Emp_id, 
                      dbo.T0055_Interview_Process_Detail.S_Emp_ID AS S_Emp, dbo.T0052_HRMS_Posted_Recruitment.Rec_Start_date, 
                      dbo.T0052_HRMS_Posted_Recruitment.Rec_End_date, dbo.T0055_Resume_Master.Non_Technical_Skill, T0040_HRMS_R_PROCESS_MASTER_1.Process_Name, 
                      dbo.T0052_HRMS_Posted_Recruitment.Location, dbo.T0055_Resume_Master.Resume_Code, TMP.Work_Email AS HR_Email_ID, 
                      dbo.T0052_HRMS_Posted_Recruitment.Venue_address,CM.Domain_Name,Rec_Post_Code
FROM         dbo.T0052_HRMS_Posted_Recruitment WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0055_Interview_Process_Detail WITH (NOLOCK)  ON dbo.T0055_Interview_Process_Detail.Rec_Post_ID = dbo.T0052_HRMS_Posted_Recruitment.Rec_Post_Id LEFT OUTER JOIN
                      dbo.T0040_HRMS_R_PROCESS_MASTER WITH (NOLOCK)  ON 
                      dbo.T0040_HRMS_R_PROCESS_MASTER.Process_ID = dbo.T0055_Interview_Process_Detail.Process_ID LEFT OUTER JOIN
                      dbo.T0040_HRMS_R_PROCESS_MASTER AS T0040_HRMS_R_PROCESS_MASTER_1 WITH (NOLOCK)  ON 
                      T0040_HRMS_R_PROCESS_MASTER_1.Process_ID = dbo.T0055_Interview_Process_Detail.Process_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0055_Interview_Process_Detail.S_Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID AND 
                      dbo.T0080_EMP_MASTER.Emp_Left = 'N' RIGHT OUTER JOIN
                      dbo.T0055_Resume_Master WITH (NOLOCK)  ON dbo.T0055_Resume_Master.Rec_Post_Id = dbo.T0052_HRMS_Posted_Recruitment.Rec_Post_Id LEFT OUTER JOIN
                      dbo.T0001_LOCATION_MASTER WITH (NOLOCK)  ON dbo.T0001_LOCATION_MASTER.Loc_ID = dbo.T0055_Resume_Master.Permanent_Loc_ID LEFT OUTER JOIN
                      dbo.T0051_HRMS_Recruitment_Setting AS HRM WITH (NOLOCK)  ON HRM.RecApplicationId = dbo.T0052_HRMS_Posted_Recruitment.Rec_Req_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS TMP WITH (NOLOCK)  ON TMP.Emp_ID = HRM.PostVacancy_EmpId AND TMP.Emp_Left = 'N' left JOIN
                      T0010_COMPANY_MASTER CM WITH (NOLOCK)  ON CM.Cmp_Id=dbo.T0052_HRMS_Posted_Recruitment.Cmp_id




GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[25] 4[17] 2[23] 3) )"
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
         Top = -288
         Left = 0
      End
      Begin Tables = 
         Begin Table = "T0052_HRMS_Posted_Recruitment"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 200
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0055_Interview_Process_Detail"
            Begin Extent = 
               Top = 6
               Left = 238
               Bottom = 121
               Right = 457
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_HRMS_R_PROCESS_MASTER"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 241
               Right = 190
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_HRMS_R_PROCESS_MASTER_1"
            Begin Extent = 
               Top = 126
               Left = 228
               Bottom = 241
               Right = 380
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 246
               Left = 38
               Bottom = 361
               Right = 255
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0055_Resume_Master"
            Begin Extent = 
               Top = 366
               Left = 38
               Bottom = 481
               Right = 226
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0001_LOCATION_MASTER"
            Begin Extent = 
               Top = 246
        ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0055_Resume_View1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'       Left = 293
               Bottom = 331
               Right = 445
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "HRM"
            Begin Extent = 
               Top = 366
               Left = 264
               Bottom = 485
               Right = 456
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TMP"
            Begin Extent = 
               Top = 486
               Left = 38
               Bottom = 605
               Right = 282
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
      Begin ColumnWidths = 56
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
         Table = 1185
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0055_Resume_View1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0055_Resume_View1';

