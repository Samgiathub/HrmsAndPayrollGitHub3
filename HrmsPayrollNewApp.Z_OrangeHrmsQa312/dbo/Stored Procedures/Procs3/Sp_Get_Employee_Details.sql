

 
-- =============================================  
-- Author:  <Author,,Zishanali Tailor>  
-- Create date: <Create Date,,11012014>  
-- Description: <Description,,For Get Employee Details>  
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================  
CREATE PROCEDURE [dbo].[Sp_Get_Employee_Details]  
 @Cmp_Id as numeric,  
 @Emp_Id as numeric,  
 @Year as numeric   
AS  
BEGIN  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

  Declare @date as varchar(20)  
  Set @date = '31-Mar-'+ convert(varchar(5),@Year + 1)  
      
  select E.Emp_Code,E.Alpha_Emp_Code,E.Emp_First_Name,E.Emp_Full_Name      
  ,ISNULL(Dept_Name,'') as Dept_Name,ISNULL(Desig_Name,'') as Desig_Name  
  ,ISNULL([Type_Name],'') as [Type_Name],ISNULL(Grd_Name,'') as Grd_Name  
  ,ISNULL(Branch_Name,'') as Branch_Name,
  (CASE WHEN ISNULL(E.GroupJoiningDate,'01-jan-1900') <> '01-jan-1900' THEN E.GroupJoiningDate ELSE ISNULL(E.Date_of_Join,'') END ) AS Date_Of_Join --Added By Dhruv[FNF Group DOJ]
  --ISNULL(Date_of_Join,'') as Date_of_Join  
  ,ISNULL(e.Pan_No,'') as Pan_No, ISNULL(e.CCenter_Remark,'') as Remarks  
  from T0080_EMP_MASTER E WITH (NOLOCK) inner join T0010_company_master Cm WITH (NOLOCK) on E.Cmp_ID = Cm.Cmp_ID   
  left outer join T0100_LEFT_EMP EL WITH (NOLOCK) on E.Emp_Id=EL.Emp_Id   
  inner join (select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I  WITH (NOLOCK) 
  inner join (select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK)  --Changed by Hardik 05/09/2014 for Same Date Increment   
  where Increment_Effective_date <= @date and Cmp_ID = @Cmp_Id group by emp_ID  ) Qry on      
   I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id  ) I_Q       --Changed by Hardik 05/09/2014 for Same Date Increment
   on E.Emp_ID = I_Q.Emp_ID  inner join      
   T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN      
   T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN      
   T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN      
   T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN       
   T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID       
   WHERE E.Cmp_ID = @Cmp_Id And E.Emp_ID = @Emp_Id  
END 
