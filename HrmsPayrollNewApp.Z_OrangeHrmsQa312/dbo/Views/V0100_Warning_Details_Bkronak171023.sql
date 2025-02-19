






create VIEW [dbo].[V0100_Warning_Details_Bkronak171023]
AS
SELECT     WD.War_Tran_ID, WD.Emp_Id, WD.Warr_Date, WD.Warr_Reason, WD.Issue_By, WD.Authorised_By, WM.War_Name, WM.Deduct_Rate, 
                      e.Emp_code, e.Emp_Full_Name, sm.Shift_Name, WD.Shift_ID, i.Branch_ID, i.Dept_ID, i.Grd_ID, dbo.T0030_BRANCH_MASTER.Branch_Name, 
                      dbo.T0040_DEPARTMENT_MASTER.Dept_Name, dbo.T0040_GRADE_MASTER.Grd_Name, e.Emp_First_Name, WM.War_ID, e.Cmp_ID, 
                      e.Alpha_Emp_Code, e.Emp_Superior,i.Vertical_ID,i.SubVertical_ID  --Added By Jaina 19-09-2015
                      ,WD.Level_Id,C.Level_Name,C.No_Of_Card,C.Card_Color,WD.Action_Taken_Date,WD.Action_Detail
FROM         dbo.T0100_WARNING_DETAIL AS WD WITH (NOLOCK) INNER JOIN
                      dbo.T0040_WARNING_MASTER AS WM WITH (NOLOCK)  ON WD.War_ID = WM.War_ID LEFT OUTER JOIN
                      dbo.T0080_EMP_MASTER AS e WITH (NOLOCK)  ON WD.Emp_Id = e.Emp_ID LEFT OUTER JOIN
                      dbo.T0095_INCREMENT AS i WITH (NOLOCK)  ON e.Increment_ID = i.Increment_ID LEFT OUTER JOIN
                      dbo.T0040_SHIFT_MASTER AS sm WITH (NOLOCK)  ON WD.Shift_ID = sm.Shift_ID LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER WITH (NOLOCK)  ON i.Branch_ID = dbo.T0030_BRANCH_MASTER.Branch_ID LEFT OUTER JOIN
                      dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK)  ON i.Dept_ID = dbo.T0040_DEPARTMENT_MASTER.Dept_Id LEFT OUTER JOIN
                      dbo.T0040_GRADE_MASTER WITH (NOLOCK)  ON i.Grd_ID = dbo.T0040_GRADE_MASTER.Grd_ID LEFT OUTER JOIN
                      T0040_Warning_CardMapping C WITH (NOLOCK)  ON C.Level_Id = WD.Level_Id AND C.Cmp_Id = WD.Cmp_ID




