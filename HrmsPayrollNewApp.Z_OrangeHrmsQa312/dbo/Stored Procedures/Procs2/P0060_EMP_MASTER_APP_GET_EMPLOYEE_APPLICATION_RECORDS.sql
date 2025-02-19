


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0060_EMP_MASTER_APP_GET_EMPLOYEE_APPLICATION_RECORDS]
	-- Add the parameters for the stored procedure here
	@PageNo		INT = 1,
	@Item_Per_Page	INT = 50,
	@Str_Where VARCHAR(MAX),
	@OrderBy  VARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

   
	SELECT      E.Emp_Tran_ID, E.Emp_Application_ID, E.Approved_Emp_ID, E.Approved_Date, E.Rpt_Level, E.Emp_ID, 
						E.Cmp_ID, E.Emp_First_Name, E.Emp_Second_Name,E.Enroll_No, E.Emp_code,
                      E.Emp_Last_Name, E.Date_Of_Join, SM.Shift_Name, DM.Dept_Name,BM.Branch_Name ,
                      CASE WHEN E.Gender = 'M' THEN 'Male' WHEN E.Gender = 'F' THEN 'Female' ELSE '' END AS Gender, TM.Type_Name, E.Marital_Status, GM.Grd_Name, CAST(E.Alpha_Emp_Code AS varchar(30)) 
                      + '-' + E.Emp_Full_Name AS Emp_Full_Name_new, E.Emp_Full_Name, E.Emp_Left, E.Work_Tel_No, E.Mobile_No, E.Date_Of_Birth,
						CAST(E.Alpha_Emp_Code AS varchar(30)) 
                      + '-' + E.Emp_Full_Name AS Applicant_Name,
                      (Case When E.Approve_Status = 'P' 
							   Then 'Pending' 
							When E.Approve_Status = 'S' 
							   Then 'Submit' 
							When E.Approve_Status = 'V' 
							   Then 'Revert' 
							When E.Approve_Status = 'R' 
							   Then 'Reject'
							 When E.Approve_Status = 'A' 
							   Then 'Final Approve'
					   END) as Approve_Status
INTO	#FINAL_RESULT
FROM         dbo.T0060_EMP_MASTER_APP AS E WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.T0001_LOCATION_MASTER WITH (NOLOCK) ON E.Loc_ID = dbo.T0001_LOCATION_MASTER.Loc_ID LEFT OUTER JOIN                 
                      dbo.T0040_GRADE_MASTER AS GM WITH (NOLOCK) on E.Grd_ID =ISNULL(E.Grd_ID,0) LEFT OUTER JOIN
                      dbo.T0040_SHIFT_MASTER AS SM WITH (NOLOCK) ON SM.Shift_ID  =ISNULL(E.Shift_ID,0) LEFT OUTER JOIN
                      dbo.T0030_CATEGORY_MASTER AS CM WITH (NOLOCK) ON CM.Cat_ID = ISNULL(E.Cat_ID,0) LEFT OUTER JOIN
                      dbo.T0040_DESIGNATION_MASTER WITH (NOLOCK) ON dbo.T0040_DESIGNATION_MASTER.Desig_ID = ISNULL(E.Desig_ID,0) LEFT OUTER JOIN
                      dbo.T0040_DEPARTMENT_MASTER AS DM WITH (NOLOCK) ON DM.Dept_Id = ISNULL(E.Dept_ID,0) LEFT OUTER JOIN
                      dbo.T0030_BRANCH_MASTER AS BM WITH (NOLOCK) ON BM.Branch_ID = ISNULL(E.Branch_ID,0) LEFT OUTER JOIN
                      dbo.T0040_Business_Segment AS BS WITH (NOLOCK) ON BS.Segment_ID = ISNULL(E.Segment_ID,0) LEFT OUTER JOIN
                      dbo.T0040_Vertical_Segment AS VS WITH (NOLOCK) ON VS.Vertical_ID = ISNULL(E.Vertical_ID,0) LEFT OUTER JOIN
                      dbo.T0050_SubVertical AS SV WITH (NOLOCK) ON SV.SubVertical_ID = ISNULL(E.SubVertical_ID,0) LEFT OUTER JOIN
                      dbo.T0040_TYPE_MASTER AS TM WITH (NOLOCK) ON TM.Type_ID = ISNULL(E.Type_ID,0) LEFT OUTER JOIN
                      dbo.T0050_SubBranch AS SB WITH (NOLOCK) ON SB.SubBranch_ID = ISNULL(E.subBranch_ID,0)

exec SP_GetPage @Items_Per_Page=@Item_Per_Page,@Page_No=@PageNo,
			@Select_Fields='Emp_Application_ID, Emp_Tran_ID,Emp_full_Name,Enroll_No,Date_Of_Join,Approved_Date, Applicant_Name,Loc_name,Grd_Name,Branch_Name,Dept_Name,Desig_Name,Emp_code,Cmp_Name,Cmp_ID,Branch_ID,Desig_ID,Dept_ID,Alpha_Emp_code,Approve_Status ',
			@From='#FINAL_RESULT',
			@Where=@Str_Where,@OrderBy=@OrderBy

END


