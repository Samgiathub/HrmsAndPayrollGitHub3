
-- =============================================
-- Author     :	<Alpesh>
-- ALTER date : <18-Jun-2012>
-- Description:	<To get direct and indirect downline means Tree Structure>
-- =============================================
CREATE PROCEDURE [dbo].[SP_GET_ESS_for_Recruitment_Manager]
	@Cmp_ID int,  
	@Emp_ID int
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	
		select distinct(ep.Emp_ID),em.Grd_ID,em.Branch_ID,em.Cat_ID,em.Desig_Id,em.Dept_Id,em.Type_ID,em.Vertical_Id,em.SubVertical_Id,Segment_ID
		CTC,Emp_code,Alpha_Code,Emp_Full_Name,em.Login_ID,Emp_Superior,Dept_Name,TYPE_NAME,Grd_Name,Branch_Name,Date_Of_Join,Emp_Left_Date,Gender
		Comp_Name,Cmp_Address,Emp_Left,Alpha_Emp_Code,Date_of_Retirement,Cat_Name,Desig_Name
		from V0200_EXIT_APPLICATION as ep
		left join T0080_EMP_MASTER as em on em.Emp_ID =ep.emp_id
		left join T0040_DEPARTMENT_MASTER as dm on dm.Dept_Id = em.Dept_ID
		left join T0040_GRADE_MASTER as gm on gm.Grd_ID = em.Grd_ID
		left join T0030_CATEGORY_MASTER as cm on cm.Cat_ID = em.Cat_ID
		left join T0030_BRANCH_MASTER as bm on bm.Branch_ID = em.Branch_ID
		left join T0010_COMPANY_MASTER as cmp on cmp.Cmp_Id = em.Cmp_ID
		left join T0040_DESIGNATION_MASTER as desig on desig.Desig_ID = em.Desig_Id
		left join T0040_TYPE_MASTER as tm on tm.Type_ID = em.Type_ID
		--inner join T0050_HRMS_Recruitment_Request as hrr on hrr.S_Emp_ID = ep.s_emp_id
		where ep.emp_id = @Emp_ID and status = 'H' and ep.cmp_id = @Cmp_ID --and hrr.Rep_EmployeeId != ep.emp_id
END




