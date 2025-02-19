



-----------
----Alpesh 20-Apr-2012
-----------
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_ACTIVE_INACTIVE_USER_HISTORY]      
  @Cmp_ID  numeric      
 ,@From_Date  datetime      
 ,@To_Date  datetime       
 ,@Branch_ID  numeric   = 0      
 ,@Cat_ID  numeric  = 0      
 ,@Grd_ID  numeric = 0      
 ,@Type_ID  numeric  = 0      
 ,@Dept_ID  numeric  = 0      
 ,@Desig_ID  numeric = 0      
 ,@Emp_ID  numeric  = 0      
 ,@Constraint varchar(max) = ''      
AS      
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON      
       
      
 if @Branch_ID = 0      
  set @Branch_ID = null      
 if @Cat_ID = 0      
  set @Cat_ID = null      
         
 if @Type_ID = 0      
  set @Type_ID = null      
 if @Dept_ID = 0      
  set @Dept_ID = null      
 if @Grd_ID = 0      
  set @Grd_ID = null      
 if @Emp_ID = 0      
  set @Emp_ID = null      
        
 If @Desig_ID = 0      
  set @Desig_ID = null      
        
       
       
 Declare @Emp_Cons Table      
 (      
   Emp_ID numeric ,     
  Branch_ID numeric    
 )      
       
 if @Constraint <> ''      
  begin      
   Insert Into @Emp_Cons      
   select  cast(data  as numeric),cast(data  as numeric) from dbo.Split (@Constraint,'#')       
  end      
 else      
  begin      
         
         
   Insert Into @Emp_Cons      
      
   select I.Emp_Id,I.Branch_ID from T0095_Increment I WITH (NOLOCK) inner join       
     ( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)     
     where Increment_Effective_date <= @To_Date      
     and Cmp_ID = @Cmp_ID      
     group by emp_ID  ) Qry on      
     I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date      
   Where Cmp_ID = @Cmp_ID       
   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
   and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))      
   and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)       
   and I.Emp_ID in       
    ( select Emp_Id from      
    (select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry      
    where cmp_ID = @Cmp_ID )  --and        
    --(( @From_Date  >= join_Date  and  @From_Date <= left_date )       
    --or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
    --or Left_date is null and @To_Date >= Join_Date)      
    --or @To_Date >= left_date  and  @From_Date <= left_date )       
         
  end      
        

 select i.*,isnull(qry.Alpha_Emp_Code,'') User_Alpha_Emp_Code,isnull(qry.Emp_Full_Name,'Admin') User_Full_Name
	,BM.Branch_Address,CM.Cmp_Name,Cm.Cmp_address,BM.BRANCH_ID,@From_Date as From_Date,@To_Date as To_Date from V0020_INACTIVE_USER_HISTORY i inner join 
	(Select l.Login_Id,l.Emp_Id,e.Alpha_Emp_Code,e.Emp_First_Name,e.Emp_Full_Name from T0011_LOGIN l WITH (NOLOCK)
	left outer join T0080_EMP_MASTER e WITH (NOLOCK) on e.Emp_ID=l.Emp_ID) qry on qry.Login_ID=i.Login_Id        
  inner join T0010_company_master Cm WITH (NOLOCK) on i.Cmp_ID = Cm.Cmp_ID inner join 
   ( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I WITH (NOLOCK) inner join       
    ( select max(Increment_id) as Increment_id , Emp_ID from T0095_Increment WITH (NOLOCK)     
    where Increment_Effective_date <= @To_Date      
    and Cmp_ID = @Cmp_ID      
    group by emp_ID  ) Qry on      
     I.Emp_ID = Qry.Emp_ID and I.Increment_id = Qry.Increment_id  ) I_Q       
    on i.Emp_ID = I_Q.Emp_ID  inner join      
     T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN      
     T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN      
     T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN      
     T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN       
     T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID       
  WHERE i.Cmp_ID = @Cmp_Id And i.System_Date >= @From_Date And i.System_Date <= @to_Date	
    And i.Emp_ID in (select Emp_ID From @Emp_Cons)     
 Order by Case When IsNumeric(i.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + i.Alpha_Emp_Code, 20)
			When IsNumeric(i.Alpha_Emp_Code) = 0 then Left(i.Alpha_Emp_Code + Replicate('',21), 20)
				Else i.Alpha_Emp_Code
			End
 --ORDER BY RIGHT(REPLICATE(N' ', 500) + i.ALPHA_EMP_CODE, 500)
        
        
 RETURN      
      
      
    

