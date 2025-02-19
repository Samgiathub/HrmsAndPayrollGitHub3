


---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_EMPLOYEE_LOAN_NUMBER_NIIT]
  @Cmp_ID  numeric      
 ,@From_Date  datetime      
 ,@To_Date  datetime       
 --,@Branch_ID  numeric   = 0       -- Added by nilesh patel on 22092014 
 --,@Cat_ID  numeric  = 0      
 --,@Grd_ID  numeric = 0      
 --,@Type_ID  numeric  = 0      
 --,@Dept_ID  numeric  = 0      
 --,@Desig_ID  numeric = 0
 ,@Branch_ID  varchar(Max) = ''        
 ,@Cat_ID  varchar(Max) = ''      
 ,@Grd_ID  varchar(Max) = ''      
 ,@Type_ID  varchar(Max) = ''      
 ,@Dept_ID  varchar(Max) = ''      
 ,@Desig_ID  varchar(Max) = ''  
 ,@Emp_ID  numeric  = 0
 ,@Constraint varchar(MAX) = ''    
 ,@Is_Attend   numeric
 ,@Vertical_Id  varchar(max)=''  --Added By Jaina 03-10-2015
 ,@SubVertical_Id  varchar(max)=''  --Added By Jaina 03-10-2015
AS      
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON   
   
 -- Comment by nilesh patel on 22092014 --Start      
 /*
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
  */    
 If @Is_Attend = 0      
  set @Is_Attend = null       
    
   -- Ankit 08092014 for Same Date Increment


	CREATE TABLE #Emp_Cons 
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )   
	 -- Added by nilesh patel on 22092014
	 exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'',@Vertical_Id,@SubVertical_Id,'',0,0,0,'0',0,0   --Change By Jaina 3-10-2015
	 --EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint --,@Sal_Type ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id  
    
 --Declare #Emp_Cons Table      
 --(      
 --  Emp_ID numeric
  
 --)      
       
 --if @Constraint <> ''      
 -- begin      
 --  Insert Into #Emp_Cons      
 --  select  cast(data  as numeric) from dbo.Split (@Constraint,'#')       
 -- end      
 --else      
 -- begin      
         
         
 --  Insert Into #Emp_Cons      
      
 --  select I.Emp_Id from T0095_Increment I inner join       
 --    ( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment      
 --    where Increment_Effective_date <= @To_Date      
 --    and Cmp_ID = @Cmp_ID      
 --    group by emp_ID  ) Qry on      
 --    I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date      
 --  Where Cmp_ID = @Cmp_ID       
 --  and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
 --  and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
 --  and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
 --  and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
 --  and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
 --  and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))      
 --  and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)       
 --  and I.Emp_ID in       
 --   ( select Emp_Id from      
 --   (select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry      
 --   where cmp_ID = @Cmp_ID   and        
 --   (( @From_Date  >= join_Date  and  @From_Date <= left_date )       
 --   or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
 --   or Left_date is null and @To_Date >= Join_Date)      
 --   or @To_Date >= left_date  and  @From_Date <= left_date )       
         
 -- end      
        
 
--EL.*,lM.LOAN_NAME
	   select E.Emp_Id,E.Emp_Code,E.Alpha_Emp_Code,E.Emp_First_Name,E.Emp_Full_Name as Emp_Full_Name,E.Emp_Full_Name as Emp_Full_Name_only,Emp_superior    
		 ,E.Emp_Full_Name as Emp_Full_Name_Only,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender      
		 ,BM.Comp_Name,BM.Branch_Address,CM.Cmp_Name,Cm.Cmp_address,E.Emp_Left,BM.BRANCH_ID 
	  from T0080_EMP_MASTER E WITH (NOLOCK) inner join           
		T0010_company_master Cm WITH (NOLOCK) on E.Cmp_ID = Cm.Cmp_ID inner join
	   ( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I WITH (NOLOCK) inner join       
		( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment  WITH (NOLOCK)    
		where Increment_Effective_date <= @To_Date      
		and Cmp_ID = @Cmp_ID 
		group by emp_ID  ) Qry on      
		 I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q       
		on E.Emp_ID = I_Q.Emp_ID  inner join      
		 T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN      
		 T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN      
		 T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN      
		 T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN       
		 T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID       
	      
	  WHERE E.Cmp_ID = @Cmp_Id  
	 --and  isnull(EL.Loan_ID,0) = isnull(@Is_Attend ,isnull(EL.Loan_ID,0)) 
	  -- and EL.Loan_Apr_Status='A'
	  --and Loan_apr_date <= @To_Date 
      And E.Emp_ID in (select Emp_ID From #Emp_Cons) 
      And E.emp_ID in (select Emp_ID from t0120_loan_approval WITH (NOLOCK) where LOan_APr_Date <= @To_Date and  isnull(Loan_ID,0) = isnull(@Is_Attend ,isnull(Loan_ID,0)) 
      and Loan_Apr_Status='A') 
    
    --order by E.Emp_Code  asc      
      Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End
      --ORDER BY RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500)
        
 RETURN      
      
      
    

