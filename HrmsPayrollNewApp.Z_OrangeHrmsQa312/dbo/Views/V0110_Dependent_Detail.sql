





CREATE VIEW [dbo].[V0110_Dependent_Detail]
AS
SELECT     EM.Emp_ID, EM.Cmp_ID, EM.Alpha_Emp_Code, EM.Branch_ID, BM.Branch_Name, GM.Grd_Name as Grade, DM.Desig_Name as Designation, Qry.Basic_Salary, Qry.Gross_Salary,
                      EM.Initial + '  ' + EM.Emp_First_Name + '  ' + ISNULL(EM.EMP_SECOND_NAME,'') + '  ' + EM.Emp_Last_Name AS Emp_Name, Convert (varchar(11),EM.Date_Of_Join,103) AS Date_Of_Join, 
                      EC.Name AS Dependent_Name, EC.Gender, EM.Father_name as Father_name, Convert (varchar(11),EC.Date_Of_Birth,103) AS Date_Of_Birth, EC.C_Age AS Dependent_Age, 
                      EC.Relationship, CASE EC.Is_Dependant WHEN 0 THEN 'NO' WHEN 1 THEN 'YES' END AS Is_Dependant, 
                      Case EM.Marital_Status When 0 Then 'Single' When 1 Then 'Married' When 2 Then 'Divorced' When 3 THEN 'Separated' When 4 Then 'Widowed' End As Marrital_Status,
					  ISNULL(EC.Height,'') AS Height,ISNULL(EC.Weight,'') AS Weight
					  -------------------------------------------Added by ronakk 06062022 ------------------------
					  ,ISNULL(OM.Occupation_Name,'') as Occupation
					  ,ISNULL(EC.HobbyName,'') as  Hobby
					  ,ISNULL(EC.DepCompanyName,'') as Dependent_Company_Name
					  ,ISNULL(EC.CmpCity,'') as Dependent_Company_City
					  ,ISNULL(EC.DepWorkTime,'') as Dependent_Work_Time --Added by ronakk 03082022
					  ,ISNULL(DSM.StandardName,'') as Dependent_Standard
					  ,ISNULL(EC.Std_Specialization,'') as Standard_Specialization -- Added by ronakk 25072022
					  ,ISNULL(EC.Shcool_College,'') as Dependent_Shcool_College
					  ,ISNULL(EC.City,'') as Dependent_Shcool_College_City
					  ,ISNULL(EC.ExtraActivity,'') as Dependent_Extra_Activity

					   -------------------------------------------End by ronakk 06062022 ------------------------

FROM         dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) INNER JOIN

			(Select	I.Increment_ID,I.Branch_ID,I.Grd_ID,I.Desig_Id,I.Basic_Salary,I.Gross_Salary, I.Emp_ID
			From	T0095_INCREMENT I  WITH (NOLOCK) 
					INNER JOIN ( 
								Select	MAX(Increment_ID) As Increment_ID, I1.Emp_ID
								From	T0095_INCREMENT I1 WITH (NOLOCK) 
										INNER JOIN (
													Select	MAX(Increment_Effective_Date) As Increment_Effective_Date,I2.Emp_ID
													From	T0095_INCREMENT I2 WITH (NOLOCK) 
													WHERE Increment_Effective_Date <= Getdate()
													GROUP BY I2.Emp_ID
													) I2 ON I1.Increment_Effective_Date=I2.Increment_Effective_Date And I1.Emp_ID = I2.Emp_ID
								GROUP By I1.Emp_ID) I3 ON I.Increment_ID=I3.Increment_ID) Qry On EM.Emp_ID = Qry.Emp_ID Inner Join
                      dbo.T0090_EMP_CHILDRAN_DETAIL AS EC WITH (NOLOCK)  ON EM.Emp_ID = EC.Emp_ID INNER JOIN
                      dbo.T0030_BRANCH_MASTER AS BM WITH (NOLOCK)  ON Qry.Branch_ID = BM.Branch_ID INNER JOIN
                      dbo.T0040_GRADE_MASTER GM WITH (NOLOCK)  On Qry.Grd_ID = GM.Grd_ID INNER JOIN
                      dbo.T0040_DESIGNATION_MASTER DM WITH (NOLOCK)  On Qry.Desig_Id = DM.Desig_ID
					  left JOIN dbo.T0040_Occupation_Master OM WITH (NOLOCK)  On EC.OccupationID = OM.O_ID   --Added by ronakk 06062022
					  left JOIN dbo.T0040_Dep_Standard_Master DSM WITH (NOLOCK)  On EC.Standard_ID = DSM.S_ID  --Added by ronakk 06062022
                      




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
         Begin Table = "EM"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 255
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "EC"
            Begin Extent = 
               Top = 6
               Left = 293
               Bottom = 121
               Right = 445
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "BM"
            Begin Extent = 
               Top = 6
               Left = 483
               Bottom = 121
               Right = 642
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
      Begin ColumnWidths = 11
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0110_Dependent_Detail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'V0110_Dependent_Detail';

