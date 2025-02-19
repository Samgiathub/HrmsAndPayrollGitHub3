

CREATE  VIEW [dbo].[V0052_HRMS_Recruitment_Posted]
AS
SELECT     dbo.T0052_HRMS_Posted_Recruitment.Rec_Post_Id, dbo.T0052_HRMS_Posted_Recruitment.Cmp_id, dbo.T0050_HRMS_Recruitment_Request.Rec_Req_ID, 
                      dbo.T0052_HRMS_Posted_Recruitment.Rec_Post_Code, dbo.T0052_HRMS_Posted_Recruitment.Rec_Post_date, 
                      dbo.T0052_HRMS_Posted_Recruitment.Rec_Start_date, dbo.T0052_HRMS_Posted_Recruitment.Rec_End_date, 
                      dbo.T0052_HRMS_Posted_Recruitment.Experience_year, Qual_Detail as Qual_ID,
                      CASE WHEN T0052_HRMS_Posted_Recruitment.location IS NOT NULL THEN
					  (SELECT  (upper(isnull(Branch_Name,'')) + ' » ' + upper(isnull(branch_city,''))) + ' , '
                         FROM          v0030_branch_master d WITH (NOLOCK) 
                         WHERE      d .Branch_ID IN
                               (SELECT     cast(data AS numeric(18, 0))
                                FROM          dbo.Split(ISNULL(T0052_HRMS_Posted_Recruitment.location, '0'), '#')
                                WHERE      data <> 0) FOR XML path('')) else '' end as Location ,
                      CASE WHEN T0052_HRMS_Posted_Recruitment.Qual_Detail IS NOT NULL THEN
					  (SELECT  isnull(QM.Qual_Name,'') + ' , '
                         FROM          T0040_QUALIFICATION_MASTER QM WITH (NOLOCK) 
                         WHERE      QM.Qual_ID IN
                               (SELECT     cast(data AS numeric(18, 0))
                                FROM          dbo.Split(ISNULL(T0052_HRMS_Posted_Recruitment.Qual_Detail, '0'), '#')
                                WHERE      data <> 0) FOR XML path('')) else '' end as Qual_Detail,                  
                      dbo.T0052_HRMS_Posted_Recruitment.Experience, dbo.T0052_HRMS_Posted_Recruitment.Email_id, dbo.T0052_HRMS_Posted_Recruitment.Job_title, 
                      dbo.T0052_HRMS_Posted_Recruitment.Login_id, dbo.T0080_EMP_MASTER.Emp_First_Name, dbo.T0080_EMP_MASTER.Emp_Full_Name, 
                      dbo.T0050_HRMS_Recruitment_Request.S_Emp_ID, dbo.T0050_HRMS_Recruitment_Request.Job_Description, 
                      dbo.T0050_HRMS_Recruitment_Request.No_of_vacancies, dbo.T0050_HRMS_Recruitment_Request.Skill_detail, 
                      dbo.T0050_HRMS_Recruitment_Request.App_status, dbo.T0050_HRMS_Recruitment_Request.Posted_date, dbo.T0050_HRMS_Recruitment_Request.Branch_id, 
                      CASE WHEN dbo.T0052_HRMS_Posted_Recruitment.Rec_End_date < DATEADD(dd, 0, DATEDIFF(dd, 0, GETDATE())) 
                      THEN 4 ELSE dbo.T0052_HRMS_Posted_Recruitment.Posted_Status END AS Posted_Status, dbo.T0040_DESIGNATION_MASTER.Desig_Name, 
                      dbo.T0052_HRMS_Posted_Recruitment.Position, dbo.T0052_HRMS_Posted_Recruitment.Other_Detail, T0010_COMPANY_MASTER_1.Domain_Name, 
                      ISNULL(PR.total_resume, 0) AS total_resume, dbo.T0010_COMPANY_MASTER.Cmp_Name, ISNULL(PS.total_Candidate, 0) AS total_Candidate, 
                      dbo.T0050_HRMS_Recruitment_Request.Dept_Id, dbo.T0050_HRMS_Recruitment_Request.Type_ID, dbo.T0050_HRMS_Recruitment_Request.Desi_Id, 
                      dbo.T0050_HRMS_Recruitment_Request.Grade_Id, dbo.T0050_HRMS_Recruitment_Request.BusinessSegment_Id, 
                      dbo.T0050_HRMS_Recruitment_Request.Vertical_Id, dbo.T0050_HRMS_Recruitment_Request.SubVertical_Id, dbo.T0052_HRMS_Posted_Recruitment.Venue_address, 
                      dbo.T0052_HRMS_Posted_Recruitment.Publish_ToEmp, dbo.T0052_HRMS_Posted_Recruitment.Publish_FromDate, 
                      dbo.T0052_HRMS_Posted_Recruitment.Publish_ToDate,T.Type_Name,ISNULL(k.Skill_Name,'')as Skill_Name,Location as Loc_ID,
                      dbo.T0052_HRMS_Posted_Recruitment.Exp_min                      
FROM         dbo.T0010_COMPANY_MASTER AS T0010_COMPANY_MASTER_1  WITH (NOLOCK) RIGHT OUTER JOIN
                      dbo.T0052_HRMS_Posted_Recruitment WITH (NOLOCK)  LEFT OUTER JOIN
                      dbo.T0010_COMPANY_MASTER WITH (NOLOCK)  ON dbo.T0052_HRMS_Posted_Recruitment.Cmp_id = dbo.T0010_COMPANY_MASTER.Cmp_Id LEFT OUTER JOIN
                          (SELECT     COUNT(Resume_Id) AS total_resume, Rec_Post_Id
                            FROM          dbo.T0055_Resume_Master WITH (NOLOCK) 
                            WHERE   ISNULL(Emp_First_Name,'') <>'' and   (Resume_Id NOT IN
                                                       (SELECT     Resume_ID
                                                         FROM          dbo.T0055_RESUME_APPROVAL_STATUS WITH (NOLOCK) 
                                                         WHERE      (Resume_Status = 1)))
                            GROUP BY Rec_Post_Id) AS PR ON dbo.T0052_HRMS_Posted_Recruitment.Rec_Post_Id = PR.Rec_Post_Id ON 
                      T0010_COMPANY_MASTER_1.Cmp_Id = dbo.T0052_HRMS_Posted_Recruitment.Cmp_id LEFT OUTER JOIN
                      dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK)  RIGHT OUTER JOIN
                      dbo.T0050_HRMS_Recruitment_Request WITH (NOLOCK)  ON dbo.T0040_DESIGNATION_MASTER.Desig_ID = dbo.T0050_HRMS_Recruitment_Request.Desi_Id LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER WITH (NOLOCK)  ON dbo.T0050_HRMS_Recruitment_Request.S_Emp_ID = dbo.T0080_EMP_MASTER.Emp_ID ON 
                      dbo.T0052_HRMS_Posted_Recruitment.Rec_Req_ID = dbo.T0050_HRMS_Recruitment_Request.Rec_Req_ID LEFT OUTER JOIN
                          (SELECT     COUNT(DISTINCT Resume_Id) AS total_Candidate, Rec_Post_Id
                            FROM          dbo.T0055_HRMS_Interview_Schedule WITH (NOLOCK) 
                            GROUP BY Rec_Post_Id) AS PS ON dbo.T0052_HRMS_Posted_Recruitment.Rec_Post_Id = PS.Rec_Post_Id LEFT OUTER JOIN
                    dbo.T0040_TYPE_MASTER T WITH (NOLOCK)  ON T.Type_ID = T0050_HRMS_Recruitment_Request.Type_ID                     
			LEFT OUTER join (
			
							SELECT  DISTINCT  B.Rec_Req_ID, STUFF
								  ((SELECT DISTINCT    ', ' + sm.Skill_Name
									  FROM         T0052_HRMS_Posted_Recruitment A WITH (NOLOCK) 
									  INNER join T0055_RecruitmentSkill rs WITH (NOLOCK)  on b.Rec_Req_ID=rs.Rec_Req_ID 
									  INNER join T0040_SKILL_MASTER sm WITH (NOLOCK)  on sm.Skill_ID=rs.Skill_Id 
									  WHERE     A.[Cmp_id] = B.[Cmp_id]  FOR XML PATH('')), 1, 1, '') AS [Skill_Name]
			
							FROM         T0052_HRMS_Posted_Recruitment B WITH (NOLOCK) 
							INNER join T0055_RecruitmentSkill rs WITH (NOLOCK)  on b.Rec_Req_ID=rs.Rec_Req_ID 
							INNER join T0040_SKILL_MASTER sm WITH (NOLOCK)  on sm.Skill_ID=rs.Skill_Id 
						)k ON k.Rec_Req_ID = T0052_HRMS_Posted_Recruitment.Rec_Req_ID








GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'       Bottom = 451
               Right = 473
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PS"
            Begin Extent = 
               Top = 366
               Left = 38
               Bottom = 451
               Right = 196
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
      Begin ColumnWidths = 39
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0052_HRMS_Recruitment_Posted';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0052_HRMS_Recruitment_Posted';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[12] 4[1] 2[31] 3) )"
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
         Top = -139
         Left = 0
      End
      Begin Tables = 
         Begin Table = "T0010_COMPANY_MASTER_1"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 271
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0052_HRMS_Posted_Recruitment"
            Begin Extent = 
               Top = 6
               Left = 309
               Bottom = 121
               Right = 471
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0010_COMPANY_MASTER"
            Begin Extent = 
               Top = 141
               Left = 382
               Bottom = 256
               Right = 615
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "PR"
            Begin Extent = 
               Top = 83
               Left = 617
               Bottom = 168
               Right = 769
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0040_DESIGNATION_MASTER"
            Begin Extent = 
               Top = 216
               Left = 309
               Bottom = 331
               Right = 470
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T0050_HRMS_Recruitment_Request"
            Begin Extent = 
               Top = 177
               Left = 47
               Bottom = 292
               Right = 227
            End
            DisplayFlags = 280
            TopColumn = 17
         End
         Begin Table = "T0080_EMP_MASTER"
            Begin Extent = 
               Top = 336
               Left = 256
        ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0052_HRMS_Recruitment_Posted';

