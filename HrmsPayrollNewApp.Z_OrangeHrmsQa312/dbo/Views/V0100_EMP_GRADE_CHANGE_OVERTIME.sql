




CREATE VIEW [dbo].[V0100_EMP_GRADE_CHANGE_OVERTIME]
AS
SELECT    EGO.OT_Tran_ID,EGO.Emp_ID, EGO.Cmp_ID, EGO.Grd_ID, EGO.For_Date, EM.Emp_code, EM.Emp_First_Name, EM.Emp_Full_Name, 
          GM.Grd_Name, INC.Branch_ID, inc.Vertical_ID , inc.SubVertical_ID ,BM.Branch_Name, EM.Emp_Superior, EM.Alpha_Emp_Code,DGM.Desig_Name,
          DPM.DEPT_ID , DPM.Dept_Name,TYM.Type_Name,BS.Segment_Name,EGO.OT_Hours , EGO.Amount_Credit , EGO.Amount_Debit , EGO.Basic_Salary
FROM         dbo.T0100_EMP_GRADE_OVERTIME EGO WITH (NOLOCK)
			INNER JOIN dbo.T0080_EMP_MASTER EM WITH (NOLOCK)					ON EGO.Emp_ID = EM.Emp_ID 
            INNER JOIN dbo.T0095_INCREMENT INC WITH (NOLOCK)					ON EM.Increment_ID = INC.Increment_ID 
            INNER JOIN dbo.T0040_GRADE_MASTER GM WITH (NOLOCK)				ON EGO.Grd_ID = GM.Grd_ID
            INNER JOIN dbo.T0030_BRANCH_MASTER BM	 WITH (NOLOCK)			ON INC.Branch_ID = BM.Branch_ID
            INNER JOIN dbo.T0040_DESIGNATION_MASTER DGM	 WITH (NOLOCK)		ON INC.DESIG_ID = DGM.DESIG_ID
            LEFT OUTER JOIN dbo.T0040_DEPARTMENT_MASTER DPM WITH (NOLOCK)		ON INC.DEPT_ID = DPM.DEPT_ID
			LEFT OUTER JOIN dbo.T0040_TYPE_MASTER TYM	 WITH (NOLOCK)		ON INC.Type_ID = TYM.Type_ID
			LEFT OUTER JOIN dbo.T0040_Business_Segment BS WITH (NOLOCK)		ON INC.Segment_ID = BS.Segment_ID


