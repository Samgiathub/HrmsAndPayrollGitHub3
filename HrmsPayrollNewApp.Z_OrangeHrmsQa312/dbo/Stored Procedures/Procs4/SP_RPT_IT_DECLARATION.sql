CREATE PROCEDURE [dbo].[SP_RPT_IT_DECLARATION]    
  @Cmp_ID  numeric    
 ,@From_Date  datetime    
 ,@To_Date  datetime     
 --,@Branch_ID  numeric   = 0    
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
 ,@Constraint nvarchar(Max) = ''    
 ,@New_Join_emp numeric = 0     
 ,@Left_Emp  Numeric = 0    
 ,@Salary_Cycle_id numeric = 0    
 --,@Segment_Id  numeric = 0    
 --,@Vertical_Id  numeric = 0    
 --,@SubVertical_Id numeric = 0     
 --,@SubBranch_Id  numeric = 0    
 ,@Segment_Id  varchar(Max) = ''    
 ,@Vertical_Id  varchar(Max) = ''    
 ,@SubVertical_Id varchar(Max) = ''    
 ,@SubBranch_Id  varchar(Max) = ''    
 ,@FYear   Varchar(20) = ''    
 ,@Iscolumn  Tinyint  = 0    
 ,@Gender  varchar(20) = ''    
AS    
 Set Nocount on     
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
 SET ARITHABORT ON    
     
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
 if @FYear = ''     
  set @FYear = null    
 if @Gender = ''    
 set @Gender = null    
 if @Salary_Cycle_id = 0     
 set @Salary_Cycle_id = null    
 if @Segment_Id = 0    
 set @Segment_Id =null    
 if @Vertical_Id = 0     
 set @Vertical_Id = null    
 if @SubVertical_Id = 0     
 set @SubVertical_Id  = null    
 if @SubBranch_Id = 0    
 set @SubBranch_Id = null    
 */    
  
  if @Gender = ''    
 set @Gender = null    
  
  DECLARE @Show_Left_Employee_for_Salary AS TINYINT    
 SET @Show_Left_Employee_for_Salary = 0    
      
  SELECT @Show_Left_Employee_for_Salary = ISNULL(Setting_Value,0)     
  FROM T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Setting_Name LIKE 'Show Left Employee for Salary'    
    
     
 CREATE table #Emp_Cons     
 (          
   Emp_ID numeric ,         
  Branch_ID numeric,    
  Increment_ID numeric        
 )          
     
   exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,@Salary_Cycle_id,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_Id,@New_Join_emp,@Left_Emp,0,'0',0,0  
  
  --EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0,0,0,0,0 ,0,@New_Join_emp,@Left_Emp    
     
 --if @Constraint <> ''    
 -- begin    
 --  Insert Into #Emp_Cons    
 --  Select cast(data  as numeric),cast(data  as numeric),cast(data  as numeric) From dbo.Split(@Constraint,'#')     
 -- end    
 --else if @New_Join_emp = 1     
 -- begin    
    
 --  Insert Into #Emp_Cons          
 --  Select distinct emp_id,branch_id,Increment_ID     
 --  From V_Emp_Cons Where Cmp_id=@Cmp_ID     
 --   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))          
 --   and Branch_ID = isnull(@Branch_ID ,Branch_ID)          
 --   and Grd_ID = isnull(@Grd_ID ,Grd_ID)          
 --   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))          
 --   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))          
 --   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))     
 --   and ISNULL(V_Emp_Cons.SalDate_id,0) = ISNULL(@Salary_Cycle_id,Isnull(V_Emp_Cons.SalDate_id,0))    
 --   and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))      
 --   and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))      
 --   and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0))     
 --   and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0))      
 --   and Emp_ID = isnull(@Emp_ID ,Emp_ID)      
 --   and Increment_Effective_Date <= @To_Date     
 --   and Date_of_Join >=@From_Date and Date_OF_Join <=@to_Date    
 --  Order by Emp_ID    
          
 --  Delete  From #Emp_Cons Where Increment_ID Not In (Select Max(Increment_ID) from T0095_Increment    
 --   Where  Increment_effective_Date <= @to_date Group by emp_ID)    
 -- end    
 --else if @Left_Emp = 1     
 -- begin    
    
 --  Insert Into #Emp_Cons          
 --  Select distinct emp_id,branch_id,Increment_ID     
 --  From V_Emp_Cons Where Cmp_id=@Cmp_ID     
 --   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))          
 --   and Branch_ID = isnull(@Branch_ID ,Branch_ID)          
 --   and Grd_ID = isnull(@Grd_ID ,Grd_ID)          
 --   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))          
 --   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))          
 --   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))      
 --   and ISNULL(V_Emp_Cons.SalDate_id,0) = ISNULL(@Salary_Cycle_id,Isnull(V_Emp_Cons.SalDate_id,0))    
 --   and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))      
 --   and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))      
 --   and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0))     
 --   and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0))     
 --   and Emp_ID = isnull(@Emp_ID ,Emp_ID)      
 --   and Increment_Effective_Date <= @To_Date     
 --   and Left_date >=@From_Date and Left_Date <=@to_Date    
 --  Order by Emp_ID    
          
 --  Delete  From #Emp_Cons Where Increment_ID Not In (Select Max(Increment_ID) from T0095_Increment    
 --   Where  Increment_effective_Date <= @to_date Group by emp_ID)    
 -- end      
 --else     
 -- begin    
    
       
 --  Insert Into #Emp_Cons          
 --       select distinct emp_id,branch_id,Increment_ID from V_Emp_Cons     
 --         left OUTER JOIN  (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id as eid FROM T0095_Emp_Salary_Cycle ESC    
 --      inner join     
 --      (SELECT max(Effective_date) as Effective_date,emp_id FROM T0095_Emp_Salary_Cycle where Effective_date <= @To_Date    
 --      GROUP BY emp_id) Qry    
 --      on Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id) as QrySC    
 --        ON QrySC.eid = V_Emp_Cons.Emp_ID    
 --   where     
 --      cmp_id=@Cmp_ID     
 --        and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))          
 --    and Branch_ID = isnull(@Branch_ID ,Branch_ID)          
 --    and Grd_ID = isnull(@Grd_ID ,Grd_ID)          
 --    and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))          
 --    and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))          
 --    and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))     
 --    and ISNULL(V_Emp_Cons.SalDate_id,0) = ISNULL(@Salary_Cycle_id,Isnull(V_Emp_Cons.SalDate_id,0))    
 --    and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))      
 --    and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))      
 --    and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0))     
 --    and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0))     
 --    and Emp_ID = isnull(@Emp_ID ,Emp_ID)       
 --       and Increment_Effective_Date <= @To_Date     
 --       and     
 --                     ( (@From_Date  >= join_Date  and  @From_Date <= left_date )          
 --     or ( @To_Date  >= join_Date  and @To_Date <= left_date )          
 --     or (Left_date is null and @To_Date >= Join_Date)          
 --     or (@To_Date >= left_date  and  @From_Date <= left_date )    
 --     OR 1=(case when ((@Show_Left_Employee_for_Salary = 1) and (left_date <= @To_Date) and (dateadd(mm,1,Left_Date) > @From_Date ))  then 1 else 0 end)    
 --     )     
 --     order by Emp_ID    
          
 --  delete  from #emp_cons where Increment_ID not in (select max(Increment_ID) from T0095_Increment    
 --   where  Increment_effective_Date <= @to_date    
 --   group by emp_ID)    
 -- end    
 if @Iscolumn = 1     
 begin    
  -- Changed By Ali 22112013 EmpName_Alias    
	select	E.Alpha_Emp_Code as Emp_Code,ISNULL(E.EmpName_Alias_Tax,E.Emp_Full_Name) as Emp_Full_Name,case when( e.Gender = 'M')  then 'Male' else case when(e.Gender = 'F') then 'Female' else '' end end as Gender ,Branch_Name,E.Date_Of_Join as Joining_Date,
			E.Emp_Left_Date as Left_Date,I_Q.Basic_Salary,I_Q.Gross_Salary,I_Q.CTC
			,case when ETR.Regime = 'Tax Regime 2' then 'New Regime' else 'Old Regime' end as Regime
	from	dbo.T0080_EMP_MASTER E WITH (NOLOCK) 
			left outer join dbo.T0100_Left_Emp l WITH (NOLOCK) on E.Emp_ID =  l.Emp_ID 
			inner join (
							select	I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,I.Basic_Salary,I.Gross_Salary,I.CTC 
							from	dbo.T0095_Increment I WITH (NOLOCK) 
									inner join (
													select	max(Increment_ID) as Increment_ID , Emp_ID 
													from	dbo.T0095_Increment WITH (NOLOCK) -- Ankit 10092014 for Same Date Increment    
													where	Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID    
													group by emp_ID  
												) Qry on I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  
					) I_Q  on E.Emp_ID = I_Q.Emp_ID  
			inner join dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
			LEFT OUTER JOIN dbo.T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
			LEFT OUTER JOIN dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
			LEFT OUTER JOIN dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
			INNER JOIN dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  
			Inner join dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID 
			Inner Join #Emp_Cons EC on E.Emp_ID = EC.Emp_ID    
			left Outer join T0095_IT_Emp_Tax_Regime ETR On E.Emp_ID = ETR.Emp_ID and ETR.Financial_Year = @FYear 
  WHERE E.Cmp_ID = @Cmp_Id  and E.Gender = isnull(@Gender,E.Gender) and  i_Q.Emp_ID   not in (select distinct(isnull(IT.Emp_ID,0)) from T0100_IT_DECLARATION IT WITH (NOLOCK) where IT.CMP_ID = @Cmp_ID and IT.FINANCIAL_YEAR = @FYear)    
  Order by Case When IsNumeric(Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + Alpha_Emp_Code, 20)    
   When IsNumeric(Alpha_Emp_Code) = 0 then Left(Alpha_Emp_Code + Replicate('',21), 20)    
    Else Alpha_Emp_Code    
   End    
 end    
 else    
 begin    
  -- Changed By Ali 22112013 EmpName_Alias    
  select I_Q.* ,E.Emp_Last_Name,E.Emp_Second_Name, E.Street_1,E.City,E.State,ISNULL(E.EmpName_Alias_Tax,E.Emp_Full_Name) as Emp_Full_Name ,E.Worker_Adult_No,E.Father_Name, E.Emp_Code,E.Alpha_Emp_Code,E.Emp_First_Name,convert(varchar(15),Left_Date,103) as 
  
Left_Date  ,BM.Comp_Name,BM.Branch_Address,Left_Reason    
     ,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,convert(varchar(15),Date_of_Join,103) as Joining_Date ,Date_Of_Birth,Emp_Mark_Of_Identification,@From_Date as From_Date ,@To_Date as To_Date    
     ,Cmp_Name,Cmp_Address,Present_Street,Present_State,Present_City,Present_Post_Box,l.left_reason,DATEDIFF(YY,ISNULL(Date_of_bIRTH,getdate()),GETDATE()) AS AGE,    
     Nature_of_Business,Cmp_City,Cmp_State_Name,Cmp_PinCode,E.mobile_no, @FYear as Financial_Year, case when( e.Gender = 'M')  then 'Male' else case when(e.Gender = 'F') then 'Female' else '' end end as Gender
	 ,case when ETR.Regime = 'Tax Regime 2' then 'New Regime' else 'Old Regime' end as Regime
  from dbo.T0080_EMP_MASTER E WITH (NOLOCK) left outer join dbo.T0100_Left_Emp l WITH (NOLOCK) on E.Emp_ID =  l.Emp_ID inner join    
   ( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Vertical_ID,SubVertical_ID,I.Basic_Salary,I.Gross_Salary,I.CTC from dbo.T0095_Increment I WITH (NOLOCK) inner join     
     ( select max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment WITH (NOLOCK) -- Ankit 10092014 for Same Date Increment    
     where Increment_Effective_date <= @To_Date    
     and Cmp_ID = @Cmp_ID    
     group by emp_ID  ) Qry on    
     I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q     
    on E.Emp_ID = I_Q.Emp_ID  inner join    
     dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN    
     dbo.T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN    
     dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN    
     dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN     
     dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  Inner join     
     dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID Inner Join    
     #Emp_Cons EC on E.Emp_ID = EC.Emp_ID    
    left Outer join T0095_IT_Emp_Tax_Regime ETR On E.Emp_ID = ETR.Emp_ID and ETR.Financial_Year = @FYear 
  WHERE E.Cmp_ID = @Cmp_Id and E.Gender = isnull(@Gender,E.Gender)   
  and  i_Q.Emp_ID   not in (select distinct(isnull(IT.Emp_ID,0)) from T0100_IT_DECLARATION IT WITH (NOLOCK) where IT.CMP_ID = @Cmp_ID and IT.FINANCIAL_YEAR = @FYear)    
  Order by Case When IsNumeric(Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + Alpha_Emp_Code, 20)    
   When IsNumeric(Alpha_Emp_Code) = 0 then Left(Alpha_Emp_Code + Replicate('',21), 20)    
    Else Alpha_Emp_Code    
   End    
 end     
RETURN       
     
    