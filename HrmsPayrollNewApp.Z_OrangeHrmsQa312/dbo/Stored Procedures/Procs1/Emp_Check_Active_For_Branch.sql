
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Emp_Check_Active_For_Branch]  
	 @Company_Id	numeric  
	,@To_Date 		datetime
	,@Constraint	varchar(max)	
	
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

  declare @SqlQuery as Varchar(max)
       
  Set @SqlQuery ='SELECT Emp_code,e.Emp_ID,Initial,Alpha_Emp_code,Emp_full_name,Emp_Last_Name,BM.Branch_Name,GM.Grd_Name,DM.Desig_Name,TM.Type_Name,CM.Cat_Name,DT.Dept_Name
	from T0080_EMP_MASTER e WITH (NOLOCK)
      INNER JOIN   
      ( select T0095_INCREMENT.Emp_Id,T0095_INCREMENT.Increment_Effective_Date,cat_id,Grd_ID,Dept_ID,Desig_Id,Branch_Id,Type_id,Bank_id,Curr_id,Wages_Type,Salary_Basis_on,Basic_salary,Gross_salary
		,Inc_Bank_Ac_No,Emp_OT,Emp_Late_Mark,Emp_Full_PF,Emp_PT,Emp_Fix_Salary,Emp_Part_time,Late_Dedu_Type,Emp_Childran
      from T0095_INCREMENT WITH (NOLOCK) inner join   
      ( select max(Increment_Effective_Date) as Increment_Effe , Emp_ID from T0095_INCREMENT WITH (NOLOCK)
      where Increment_Effective_date <= '''+ CAST(@To_Date as varchar(50)) +''' and Cmp_ID = ' + CAST(@Company_Id AS VARCHAR(10)) + ' Group by emp_ID  ) Qry  
     on T0095_INCREMENT.Emp_ID = Qry.Emp_ID and  
     T0095_INCREMENT.Increment_Effective_Date   = Qry.Increment_Effe
     where cmp_id = ' + CAST(@Company_Id AS VARCHAR(10)) + ' ) Inc_Qry on   
      e.Emp_ID = Inc_Qry.Emp_ID inner join  
      T0040_GRADE_MASTER GM WITH (NOLOCK) ON Inc_Qry.Grd_Id = GM.Grd_Id INNER JOIN
      T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Inc_Qry.Branch_ID = BM.Branch_Id Inner join       
      T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON Inc_Qry.Desig_Id = DM.Desig_Id LEFT OUTER JOIN
      T0040_BANK_MASTER BN WITH (NOLOCK) On Inc_Qry.Bank_id = BN.Bank_Id Left Outer join
      T0040_TYPE_MASTER TM WITH (NOLOCK) On Inc_Qry.Type_Id = TM.Type_Id Left Outer Join
      T0030_CATEGORY_MASTER CM WITH (NOLOCK) On Inc_Qry.Cat_id = CM.Cat_Id Left Outer Join
      T0040_DEPARTMENT_MASTER DT WITH (NOLOCK) ON Inc_Qry.Dept_Id = DT.Dept_Id 
     WHERE IsNull(e.Emp_Left, ''N'') <> ''Y'' AND '+ @Constraint

	 
	exec(@SqlQuery)
 RETURN   




