  
CREATE PROCEDURE [dbo].[KPMS_EMP_DETAILS]   
(
	@Cmp_ID	INT,
	@Emp_ID INT      --isnull(,'') as
)
AS     
  
   BEGIN  
		select Emp_code,isnull(Qual_name,'N/A') as Qual_name,Emp_First_Name,Emp_Full_Name as Name,em.Image_Name,isnull(Mobile_No,'N/A') as Mobile_No,isnull(Street_1,'N/A') as Street_1,
		isnull(skill_Name,'N/A')  as skill_Name,isnull(Dept_Name,'') as Dept_Name,isnull(Present_Street,'N/A') as Present_Street,
		isnull(Work_Email,'N/A') as Work_Email,Emp_Last_Name,CONVERT(VARCHAR, CONVERT(varchar, Date_Of_Birth, 103)) as Date_Of_Birth ,
		Grd_Name,isnull(Branch_Name,'N/A') as Branch_Name,isnull(Desig_Name,'N/A') as Desig_Name,isnull(TYPE_NAME,'N/A') as TYPE_NAME from
		T0080_EMP_MASTER as em
		iNNER join T0040_DESIGNATION_MASTER as ds on ds.Desig_Id = em.Desig_Id
		  INNER JOIN T0040_TYPE_MASTER TM WITH (NOLOCK) ON em.Type_Id = TM.Type_Id      
		  Inner Join T0030_BRANCH_MASTER BM WITH (NOLOCK) ON bm.BRANCH_ID = em.BRANCH_ID  
		  Inner Join T0040_GRADE_MASTER GM WITH (NOLOCK) ON gm.Grd_ID = em.Grd_ID
		  left outer Join T0040_SKILL_MASTER SLM WITH (NOLOCK) On SLm.Skill_ID = Em.SkillType_ID and Slm.Cmp_ID = Em.Cmp_ID 
		  lEFT JOIN T0040_DEPARTMENT_MASTER DT WITH (NOLOCK) ON em.Dept_Id = DT.Dept_Id   
		 left join T0090_EMP_QUALIFICATION_DETAIL Q1 WITH (NOLOCK) ON em.Emp_ID = Q1.Emp_ID  AND em.Cmp_ID=Q1.Cmp_ID  
		   left join T0040_QUALIFICATION_MASTER QM WITH (NOLOCK) on QM.Qual_ID=Q1.Qual_ID  
			INNER JOIN	T0010_COMPANY_MASTER cm With(noLock) on cm.Cmp_Id=em.Cmp_ID	

			where em.Emp_ID=@Emp_ID and em.Cmp_ID=@Cmp_ID
End

