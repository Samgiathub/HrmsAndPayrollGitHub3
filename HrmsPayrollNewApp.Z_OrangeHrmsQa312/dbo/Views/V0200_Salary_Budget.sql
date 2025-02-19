


CREATE VIEW [dbo].[V0200_Salary_Budget]
AS
SELECT     SalBudget_ID, SalBudget_Type, SalBudget_Date, Cmp_ID, dept_ids, branch_ids, subbranch_ids, subvertical_ids, vertical_ids, type_ids, cat_ids, desig_ids, 
                      grade_ids, busSegment_Ids, CASE WHEN SalBudget_Type = 'Appraisal Rating' THEN CASE WHEN T0200_Salary_Budget.Dept_Ids IS NOT NULL THEN
                          (SELECT     d .Dept_Name + ','
                            FROM          T0040_DEPARTMENT_MASTER d WITH (NOLOCK)
                            WHERE      Dept_Id IN
                                                       (SELECT     cast(data AS numeric(18, 0))
                                                         FROM          dbo.Split(ISNULL(dbo.T0200_Salary_Budget.Dept_Ids, '0'), '#')
                                                         WHERE      data <> '') FOR XML path('')) ELSE '' END ELSE '' END AS Dept_Name, 
                      CASE WHEN SalBudget_Type = 'Appraisal Rating' THEN CASE WHEN T0200_Salary_Budget.Branch_Ids IS NOT NULL THEN
                          (SELECT     B.Branch_Name + ','
                            FROM          T0030_BRANCH_MASTER B WITH (NOLOCK)
                            WHERE      B.Branch_ID IN
                                                       (SELECT     CAST(Data AS NUMERIC(18, 0))
                                                         FROM          dbo.Split(ISNULL(dbo.T0200_Salary_Budget.branch_ids, '0'), '#')
                                                         WHERE      Data <> '') FOR XML PATH('')) ELSE '' END ELSE '' END AS Branch_Name, 
                      CASE WHEN SalBudget_Type = 'Appraisal Rating' THEN CASE WHEN T0200_Salary_Budget.SubBranch_Ids IS NOT NULL THEN
                          (SELECT     SB.SubBranch_Name + ','
                            FROM          T0050_SubBranch SB WITH (NOLOCK)
                            WHERE      SB.SubBranch_ID IN
                                                       (SELECT     CAST(Data AS NUMERIC(18, 0))
                                                         FROM          dbo.Split(isnull(dbo.T0200_Salary_Budget.SubBranch_Ids, '0'), '#')
                                                         WHERE      Data <> '') FOR XML PATH('')) ELSE '' END ELSE '' END AS SubBranch_Name, 
                      CASE WHEN SalBudget_Type = 'Appraisal Rating' THEN CASE WHEN T0200_Salary_Budget.Desig_Ids IS NOT NULL THEN
                          (SELECT     DG.Desig_Name + ','
                            FROM          T0040_DESIGNATION_MASTER DG WITH (NOLOCK)
                            WHERE      DG.Desig_ID IN
                                                       (SELECT     CAST(Data AS NUMERIC(18, 0))
                                                         FROM          dbo.Split(ISNULL(T0200_Salary_Budget.Desig_Ids, 0), '#')
                                                         WHERE      Data <> '') FOR XML PATH('')) ELSE '' END ELSE '' END AS Desig_Name, 
                      CASE WHEN SalBudget_Type = 'Appraisal Rating' THEN CASE WHEN T0200_Salary_Budget.Grade_Ids IS NOT NULL THEN
                          (SELECT     G.Grd_Name + ','
                            FROM          T0040_GRADE_MASTER G WITH (NOLOCK)
                            WHERE      G.Grd_ID IN
                                                       (SELECT     CAST(Data AS NUMERIC(18, 0))
                                                         FROM          dbo.Split(ISNULL(T0200_Salary_Budget.Grade_Ids, 0), '#')
                                                         WHERE      Data <> '') FOR XML PATH('')) ELSE '' END ELSE '' END AS Grade_Name, 
                      CASE WHEN SalBudget_Type = 'Appraisal Rating' THEN CASE WHEN T0200_Salary_Budget.Cat_Ids IS NOT NULL THEN
                          (SELECT     C.Cat_Name + ','
                            FROM          T0030_CATEGORY_MASTER C WITH (NOLOCK)
                            WHERE      C.Cat_ID IN
(SELECT     CAST(Data AS NUMERIC(18, 0))
                                                         FROM          dbo.Split(ISNULL(T0200_Salary_Budget.Cat_Ids, 0), '#')
                                                         WHERE      Data <> '') FOR XML PATH('')) ELSE '' END ELSE '' END AS Cat_Name, 
                      CASE WHEN SalBudget_Type = 'Appraisal Rating' THEN CASE WHEN T0200_Salary_Budget.Type_Ids IS NOT NULL THEN
                          (SELECT     T .Type_Name + ','
                            FROM          T0040_TYPE_MASTER T WITH (NOLOCK)
                            WHERE      T .Type_ID IN
                                                       (SELECT     CAST(Data AS NUMERIC(18, 0))
                                                         FROM          dbo.Split(ISNULL(T0200_Salary_Budget.Type_Ids, 0), '#')
                                                         WHERE      Data <> '') FOR XML PATH('')) ELSE '' END ELSE '' END AS Type_Name, 
                      CASE WHEN SalBudget_Type = 'Appraisal Rating' THEN CASE WHEN T0200_Salary_Budget.BusSegment_Ids IS NOT NULL THEN
                          (SELECT     T .Segment_Name + ','
                            FROM          T0040_Business_Segment T WITH (NOLOCK)
                            WHERE      T .Segment_ID IN
                                                       (SELECT     CAST(Data AS NUMERIC(18, 0))
                                                         FROM          dbo.Split(ISNULL(T0200_Salary_Budget.BusSegment_Ids, 0), '#')
                                                         WHERE      Data <> '') FOR XML PATH('')) ELSE '' END ELSE '' END AS Segment_Name, 
                      CASE WHEN SalBudget_Type = 'Appraisal Rating' THEN CASE WHEN T0200_Salary_Budget.Vertical_Ids IS NOT NULL THEN
                          (SELECT     T .Vertical_Name + ','
                            FROM          T0040_Vertical_Segment T WITH (NOLOCK)
                            WHERE      T .Vertical_ID IN
                                                       (SELECT     CAST(Data AS NUMERIC(18, 0))
                                                         FROM          dbo.Split(ISNULL(T0200_Salary_Budget.Vertical_Ids, 0), '#')
                                                         WHERE      Data <> '') FOR XML PATH('')) ELSE '' END ELSE '' END AS Vertical_Name, 
                      CASE WHEN SalBudget_Type = 'Appraisal Rating' THEN CASE WHEN T0200_Salary_Budget.SubVertical_Ids IS NOT NULL THEN
                          (SELECT     T .SubVertical_Name + ','
                            FROM          T0050_SubVertical T WITH (NOLOCK)
                            WHERE      T .SubVertical_ID IN
                                                       (SELECT     CAST(Data AS NUMERIC(18, 0))
                                                         FROM          dbo.Split(ISNULL(T0200_Salary_Budget.SubVertical_Ids, 0), '#')
                                                         WHERE      Data <> '') FOR XML PATH('')) ELSE '' END ELSE '' END AS SubVertical_Name
FROM         T0200_Salary_Budget WITH (NOLOCK)

