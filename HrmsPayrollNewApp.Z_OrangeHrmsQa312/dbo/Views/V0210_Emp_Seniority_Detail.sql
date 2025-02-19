


-- Created By rohit For Seniority Calculation on Salary Component Which Not Effect On Salary 19052015

CREATE VIEW [dbo].[V0210_Emp_Seniority_Detail]
AS
SELECT Es.*,Em.Alpha_Emp_Code,Em.Emp_Full_Name,Am.AD_NAME,AM.AD_NOT_EFFECT_SALARY 
,I.Branch_Id,I.Grd_ID,I.Desig_Id,I.Dept_ID,I.Vertical_ID,I.SubVertical_ID,I.Segment_ID,
Bm.Branch_Name,EM.subBranch_ID
FROM T0210_Emp_Seniority_Detail ES WITH (NOLOCK) Inner Join T0080_EMP_MASTER EM WITH (NOLOCK)  On Es.Emp_id = EM.Emp_ID 
inner Join T0050_AD_MASTER Am WITH (NOLOCK)  on Es.Ad_Id = AM.AD_ID
Inner join T0095_INCREMENT I WITH (NOLOCK)  on Em.Increment_ID= I.Increment_ID 
inner join T0030_BRANCH_MASTER BM WITH (NOLOCK)  on I.Branch_ID = Bm.Branch_ID 




