      
CREATE PROCEDURE [dbo].[KPMS_EMP_DETAILS_ALLOTMENT]       
(    
 @Cmp_ID INT,    
 @Emp_ID INT          
)    
AS              
   BEGIN         
		select Emp_Full_Name as Name1,isnull(Dept_Name,'') as Dept_Name, --ISNULL(Status_Name,'') as  Result5,
		isnull(Branch_Name,'N/A') as Branch_Name,isnull(Desig_Name,'N/A') as Desig_Name   from
		T0080_EMP_MASTER as em      
		iNNER join T0040_DESIGNATION_MASTER as ds on ds.Desig_Id = em.Desig_Id        
		Inner Join T0030_BRANCH_MASTER BM WITH (NOLOCK) ON bm.BRANCH_ID = em.BRANCH_ID         
		lEFT JOIN T0040_DEPARTMENT_MASTER DT WITH (NOLOCK) ON em.Dept_Id = DT.Dept_Id           
		INNER JOIN T0010_COMPANY_MASTER cm With(noLock) on cm.Cmp_Id=em.Cmp_ID      
		where em.Emp_ID=@Emp_ID     
End    
