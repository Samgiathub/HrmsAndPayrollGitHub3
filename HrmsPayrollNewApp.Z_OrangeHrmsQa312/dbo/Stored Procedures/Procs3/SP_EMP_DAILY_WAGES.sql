

---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_EMP_DAILY_WAGES]
  @Cmp_ID  numeric      
 ,@From_Date  datetime      
 ,@To_Date  datetime       
 --,@Branch_ID  numeric   = 0      
 --,@Cat_ID  numeric  = 0      
 --,@Grd_ID  numeric = 0      
 --,@Type_ID  numeric  = 0      
 --,@Dept_ID  numeric  = 0      
 --,@Desig_ID  numeric = 0 
 ,@Branch_ID  varchar(Max) = ''  --Added By nilesh patel 17092014 
 ,@Cat_ID  varchar(Max) = ''    --Added By nilesh patel 17092014
 ,@Grd_ID  varchar(Max) = ''    --Added By nilesh patel 17092014
 ,@Type_ID  varchar(Max) = ''   --Added By nilesh patel 17092014
 ,@Dept_ID  varchar(Max) = ''   --Added By nilesh patel 17092014
 ,@Desig_ID  varchar(Max) = ''  --Added By nilesh patel 17092014
 ,@Emp_ID  numeric  = 0      
 ,@Constraint varchar(5000) = ''
 ,@Report_For	varchar(50) = 'EMP RECORD'      
 ,@Sal_Type numeric=0
 ,@Salary_Cycle_id numeric = NULL
 --,@Segment_Id  numeric = 0		 -- Added By Gadriwala Muslim 21082013
 --,@Vertical_Id numeric = 0		 -- Added By Gadriwala Muslim 21082013
 --,@SubVertical_Id numeric = 0	 -- Added By Gadriwala Muslim 21082013	
 --,@SubBranch_Id numeric = 0		 -- Added By Gadriwala Muslim 21082013
 ,@Segment_Id  varchar(Max)	= ''	 -- Added By nilesh patel 17092014
 ,@Vertical_Id varchar(Max) = ''		 -- Added By nilesh patel 17092014
 ,@SubVertical_Id varchar(Max) = ''	 -- Added By nilesh patel 17092014	
 ,@SubBranch_Id varchar(Max) = ''	 -- Added By nilesh patel 17092014		       
AS      
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
      
 -- Comment by nilesh patel --Start      
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
  if @Salary_Cycle_id = 0
  set @Salary_Cycle_id = null -- Added By Gadriwala Muslim 21082013
  
  If @Segment_Id = 0		 -- Added By Gadriwala Muslim 21082013
	set @Segment_Id = null
	If @Vertical_Id = 0		 -- Added By Gadriwala Muslim 21082013
	set @Vertical_Id = null
	If @SubVertical_Id = 0	 -- Added By Gadriwala Muslim 21082013
	set @SubVertical_Id = null	
	If @SubBranch_Id = 0	 -- Added By Gadriwala Muslim 21082013
	set @SubBranch_Id = null	
     
       
       
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
      
   select I.Emp_Id,I.Branch_ID from T0095_Increment I inner join       
     ( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment      
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
   and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))	 -- Added By Gadriwala Muslim 21082013
   and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 -- Added By Gadriwala Muslim 21082013
   and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) -- Added By Gadriwala Muslim 21082013
   and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) -- Added By Gadriwala Muslim 21082013
     
   and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)       
   and I.Emp_ID in       
    ( select Emp_Id from      
    (select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry      
    where cmp_ID = @Cmp_ID   and        
    (( @From_Date  >= join_Date  and  @From_Date <= left_date )       
    or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
    or Left_date is null and @To_Date >= Join_Date)      
    or @To_Date >= left_date  and  @From_Date <= left_date )       
         
  end   
    */
   -- Comment by nilesh patel --End
   
   -- Added By nilesh patel --start
   CREATE table #Emp_Cons 
  (      
    Emp_ID numeric ,     
    Branch_ID numeric,
    Increment_ID numeric    
  )      
  
  exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,@Salary_Cycle_id,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_Id,0,0,0,'0',0,0
  
  
  
   -- Added By nilesh patel --End
  Select I_Q.* ,E.Emp_Code, E.Alpha_Emp_Code,E.Emp_First_Name, cast( E.Alpha_Emp_Code as varchar) + ' - '+E.Emp_Full_Name as Emp_Full_Name,E.Emp_Full_Name as Emp_Full_Name_only,Emp_superior   --Change only EmpCode istead of AlfhaEmpCode paras02/07/2013   
     ,E.Emp_Full_Name as Emp_Full_Name_Only,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender      
     ,BM.Comp_Name,BM.Branch_Address,CM.Cmp_Name,Cm.Cmp_address,E.Emp_Left ,G_Q.Is_Present,G_Q.Is_Amount  --Change By Jaina 3-10-2015
     ,E.Vertical_ID,E.SubVertical_ID  --Added By Jaina 29-09-2015   
  from T0080_EMP_MASTER E WITH (NOLOCK) inner join           
    T0010_company_master Cm WITH (NOLOCK) on E.Cmp_ID = Cm.Cmp_ID left outer join          
    T0100_LEFT_EMP EL WITH (NOLOCK) on E.Emp_Id=EL.Emp_Id inner join        
   ( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Wages_type from T0095_Increment I WITH (NOLOCK) inner join       
    ( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment  WITH (NOLOCK)    
    where Increment_Effective_date <= @To_Date      
    and Cmp_ID = @Cmp_ID      
    group by emp_ID  ) Qry on      
     I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date  ) I_Q       
    on E.Emp_ID = I_Q.Emp_ID     
    -- T0040_General_setting GS on I_Q.Branch_ID = GS.Branch_ID inner join  
    --Added By Jaina 3-10-2015
		INNER JOIN (
						SELECT	 Branch_ID, CMP_ID,Sal_St_Date,G.Is_Present,G.Is_Amount
						FROM	T0040_General_setting G WITH (NOLOCK)
						WHERE	G.Gen_ID = (
													SELECT	TOP 1 G1.Gen_ID
													FROM	T0040_General_setting G1 WITH (NOLOCK)
													WHERE	G1.Branch_ID=G.Branch_ID AND G1.CMP_ID=G.CMP_ID AND G1.For_Date <= @to_date
													ORDER BY	G1.For_Date DESC,G1.Gen_ID DESC
												)
					  ) AS G_Q ON  G_Q.CMP_ID=E.CMP_ID AND G_Q.Branch_ID=I_Q.Branch_ID INNER JOIN
					  
     T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN      
     T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN      
     T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN      
     T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN       
     T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID       

  WHERE E.Cmp_ID = @Cmp_Id  and Emp_Left<>'y'   and I_Q.Wages_type='Weekly'
    And E.Emp_ID in (select Emp_ID From #Emp_Cons)
    Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End 
---    and GS.For_Date = (select max(gs.For_Date) From T0040_General_Setting where gs.Cmp_ID = @Cmp_ID and gs.Branch_ID =@branch_id)  --Modified By Ramiz on 17092014
    --order by E.Emp_Code  asc   
  --ORDER BY RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500)    
    
    
    
 RETURN      
      
      
    

