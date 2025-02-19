
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_EMP_Salary_View_Publish]
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		numeric   = 0
	,@Cat_ID		numeric  = 0
	,@Grd_ID		numeric = 0
	,@Type_ID		numeric  = 0
	,@Dept_ID		numeric  = 0
	,@Desig_ID		numeric = 0
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(max) = ''
	,@New_Join_emp	numeric = 0 
	,@Left_Emp		Numeric = 0
	,@Salary_Cycle_id numeric = NULL
	,@Segment_Id  numeric = 0		
	,@Vertical_Id numeric = 0		
	,@SubVertical_Id numeric = 0	 
	,@SubBranch_Id numeric = 0	
	,@Sal_View_Type numeric = 0
	,@Salary_Status	Varchar(10) = 'ALL'	--Ankit 25032016
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if @Salary_Cycle_id = 0
		set @Salary_Cycle_id =NULL

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
	
	If @Segment_Id = 0		 
	set @Segment_Id = null
	If @Vertical_Id = 0		 
	set @Vertical_Id = null
	If @SubVertical_Id = 0	 
	set @SubVertical_Id = null	
	If @SubBranch_Id = 0	 
	set @SubBranch_Id = null	
	
	IF ISNULL(@Salary_Status,'ALL') = 'ALL'
		SET @Salary_Status = NULL
	
		  
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
 
	
	if @Constraint <> ''
		begin
			Insert Into #Emp_Cons
			Select cast(data  as numeric),cast(data  as numeric),cast(data  as numeric) From dbo.Split(@Constraint,'#') 
		end
	else if @New_Join_emp = 1 
		begin

			Insert Into #Emp_Cons      
			Select distinct emp_id,branch_id,Increment_ID 
			From V_Emp_Cons Where Cmp_id=@Cmp_ID 
				and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
				and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
				and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
				and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
				and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
				and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))  
				and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))	
				and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 
				and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) 
				and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) 
				and Emp_ID = isnull(@Emp_ID ,Emp_ID)  
				and Increment_Effective_Date <= @To_Date 
				and Date_of_Join >=@From_Date and Date_OF_Join <=@to_Date
			Order by Emp_ID
						
			--Delete  From #Emp_Cons Where Increment_ID Not In (Select Max(Increment_ID) from T0095_Increment
			--	Where  Increment_effective_Date <= @to_date Group by emp_ID)
			--Delete E From #Emp_Cons E left Join (Select Max(Increment_ID)as inc from T0095_Increment
			--	Where  Increment_effective_Date <= @to_date Group by emp_ID) as INC_d on E.increment_id = INC_d.inc where isnull(inc_d.inc,0)=0

	Delete #Emp_Cons From  #Emp_Cons EC Left Outer Join
				(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
				(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
				Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
				Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry on EC.Increment_Id = Qry.Increment_Id
			Where Qry.Increment_ID is null
		end
	else if @Left_Emp = 1 
		begin

			Insert Into #Emp_Cons      
			Select distinct emp_id,branch_id,Increment_ID 
			From V_Emp_Cons Where Cmp_id=@Cmp_ID 
				and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
				and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
				and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
				and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
				and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
				and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))  
				and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))			
				and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))		 
				and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) 
				and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) 
				and Emp_ID = isnull(@Emp_ID ,Emp_ID)  
				and Increment_Effective_Date <= @To_Date 
				and Left_date >=@From_Date and Left_Date <=@to_Date
			Order by Emp_ID
						
			--Delete  From #Emp_Cons Where Increment_ID Not In (Select Max(Increment_ID) from T0095_Increment
			--	Where  Increment_effective_Date <= @to_date Group by emp_ID)
			--Delete E From #Emp_Cons E left Join (Select Max(Increment_ID)as inc from T0095_Increment
			--	Where  Increment_effective_Date <= @to_date Group by emp_ID) as INC_d on E.increment_id = INC_d.inc where isnull(inc_d.inc,0)=0
				Delete #Emp_Cons From  #Emp_Cons EC Left Outer Join
				(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
				(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
				Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
				Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry on EC.Increment_Id = Qry.Increment_Id
			Where Qry.Increment_ID is null
		end		
	else 
		begin			
			Insert Into #Emp_Cons      
		      select distinct emp_id,branch_id,Increment_ID from V_Emp_Cons 
		        left OUTER JOIN  (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id as eid FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)
							inner join 
							(SELECT max(Effective_date) as Effective_date,emp_id FROM T0095_Emp_Salary_Cycle WITH (NOLOCK) where Effective_date <= @To_Date
							GROUP BY emp_id) Qry
							on Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id) as QrySC
		       ON QrySC.eid = V_Emp_Cons.Emp_ID
		  where 
		     cmp_id=@Cmp_ID 
		       and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
		   and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
		   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
		   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
		   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
		   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
		   and isnull(QrySC.SalDate_id,0) = isnull(@Salary_Cycle_id ,isnull(QrySC.SalDate_id,0))  
		   and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))       
		   and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	
		   and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0))  
		   and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) 
		   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
		      and Increment_Effective_Date <= @To_Date 
		      and 
                      ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
						or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
						or (Left_date is null and @To_Date >= Join_Date)      
						or (@To_Date >= left_date  and  @From_Date <= left_date )
						OR 1=(case when ((@Show_Left_Employee_for_Salary = 1) and (left_date <= @To_Date) and (dateadd(mm,1,Left_Date) > @From_Date ))  then 1 else 0 end)
						) 
						order by Emp_ID
						
			--delete  from #emp_cons where Increment_ID not in (select max(Increment_ID) from T0095_Increment
			--	where  Increment_effective_Date <= @to_date
			--	group by emp_ID)	
			--Delete E From #Emp_Cons E left Join (Select Max(Increment_ID)as inc from T0095_Increment
			--	Where  Increment_effective_Date <= @to_date Group by emp_ID) as INC_d on E.increment_id = INC_d.inc where isnull(inc_d.inc,0)=0
			
				Delete #Emp_Cons From  #Emp_Cons EC Left Outer Join
				(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
				(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
				Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
				Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry on EC.Increment_Id = Qry.Increment_Id
			Where Qry.Increment_ID is null
		end
		
	   if @Sal_View_Type = 0 
		   begin		
			   select Distinct E.Emp_ID,E.Alpha_Emp_Code as Emp_Code,E.Emp_Full_Name as Employee_Name,DM.Dept_Name as Department, 
							case when IsNull(SPE.Is_Publish,0) = 1 then 'Publish' else 'Unpublish' end  as Is_Publish,Comments--,Ms.Salary_Status
							,I_Q.BRANCH_ID,I_Q.DEPT_ID,I_Q.Vertical_ID,I_Q.SubVertical_ID  --Added By Jimit 11032019
				from dbo.T0080_EMP_MASTER E WITH (NOLOCK)
					--left outer join dbo.T0100_Left_Emp l on E.Emp_ID =  l.Emp_ID 
					inner join
					( select  I.Emp_Id,Branch_ID,Dept_ID,Vertical_ID,SubVertical_ID from dbo.T0095_Increment I WITH (NOLOCK) inner join 
							( select max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment WITH (NOLOCK)
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = @Cmp_ID
							group by emp_ID  ) Qry on
							I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
							on E.Emp_ID = I_Q.Emp_ID  Left OUTER JOIN
							--dbo.T0040_GENERAL_SETTING GS on E.Cmp_ID = GS.Cmp_ID and E.Branch_ID = gs.Branch_ID  LEFT OUTER JOIN 
							--dbo.T0030_BRANCH_MASTER BM ON I_Q.BRANCH_ID = BM.BRANCH_ID  Left outer join  
							dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on I_Q.Dept_ID = DM.Dept_Id LEFT OUTER JOIN
							--dbo.T0010_COMPANY_MASTER CM ON E.CMP_ID = CM.CMP_ID  left outer join
							dbo.T0250_SALARY_PUBLISH_ESS SPE WITH (NOLOCK) on E.Emp_ID = SPE.Emp_ID and sPE.Month = Month(@To_Date) and SPE.Year = Year(@To_Date) and SPE.Sal_Type='Salary' Inner join --Added By Mukti Sal_Type(24062016) 
							#Emp_Cons EC on E.Emp_ID = EC.Emp_ID Inner JOIN
							T0200_MONTHLY_SALARY MS WITH (NOLOCK) on EC.Emp_ID = MS.Emp_ID And Month(MS.Month_End_Date) = Month(@To_Date) and Year(MS.Month_End_Date) = Year(@To_Date)  --Hardik 17/03/2016							
				WHERE E.Cmp_ID = @Cmp_Id --and GS.For_Date = (select max(for_date) From T0040_General_Setting where GS.Cmp_ID = @Cmp_ID and GS.Branch_ID =@branch_id)  --Modified By Ramiz on 17092014
						AND MS.Salary_Status = ISNULL(@Salary_Status ,MS.Salary_Status) and Is_FNF=0 --added by Mukti Is_FNF=0(08072016)	  
				ORDER BY E.ALPHA_EMP_CODE,E.Emp_Full_Name
		   end
	   else if @sal_view_Type = 1 
	     begin
			   select Distinct E.Emp_ID,E.Alpha_Emp_Code as Emp_Code,E.Emp_Full_Name as Employee_Name,DM.Dept_Name as Department, case when IsNull(SPE.Is_Publish,0) = 1 then 'Publish' else 'Unpublish' end  as Is_Publish,Comments
								,I_Q.BRANCH_ID,I_Q.DEPT_ID,I_Q.Vertical_ID,I_Q.SubVertical_ID  --Added By Jimit 11032019
			   from dbo.T0080_EMP_MASTER E WITH (NOLOCK) left outer join dbo.T0100_Left_Emp l WITH (NOLOCK) on E.Emp_ID =  l.Emp_ID inner join
					( select  I.Emp_Id,Branch_ID,I.Emp_Full_PF,I.Emp_Auto_Vpf,Dept_ID,Vertical_ID,SubVertical_ID  
							from dbo.T0095_Increment I inner join 
							( select max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment WITH (NOLOCK)
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = @Cmp_ID
							group by emp_ID  ) Qry on
							I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
							on E.Emp_ID = I_Q.Emp_ID  inner join
							--dbo.T0040_GENERAL_SETTING GS on E.Cmp_ID = GS.Cmp_ID and E.Branch_ID = gs.Branch_ID  LEFT OUTER JOIN 
							dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  Left outer join 
							dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on I_Q.Dept_ID = DM.Dept_Id LEFT OUTER JOIN
							dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID  Inner Join
							dbo.T0250_SALARY_PUBLISH_ESS SPE WITH (NOLOCK) on E.Emp_ID = SPE.Emp_ID and IsNull(SPE.Is_Publish,0) = 1 and sPE.Month = Month(@From_Date) and SPE.Year = Year(@From_Date) and SPE.Sal_Type='Salary' Inner join --Added By Mukti Sal_Type(24062016)
							#Emp_Cons EC on E.Emp_ID = EC.Emp_ID INNER JOIN
							T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON EC.Emp_ID = MS.Emp_ID AND MONTH(MS.Month_End_Date) = MONTH(@To_Date) AND YEAR(MS.Month_End_Date) = YEAR(@To_Date)  --Ankit 25032016

				WHERE E.Cmp_ID = @Cmp_Id --and GS.For_Date = (select max(for_date) From T0040_General_Setting where GS.Cmp_ID = @Cmp_ID and GS.Branch_ID =@branch_id)  --Modified By Ramiz on 17092014	
					AND MS.Salary_Status = ISNULL(@Salary_Status ,MS.Salary_Status)	and Is_FNF=0
				ORDER BY E.ALPHA_EMP_CODE,E.Emp_Full_Name	
	   end
	   else if @sal_view_Type = 2
		   begin
			   select Distinct E.Emp_ID,E.Alpha_Emp_Code as Emp_Code,E.Emp_Full_Name as Employee_Name,DM.Dept_Name as Department, case when IsNull(SPE.Is_Publish,0) = 1 then 'Publish' else 'Unpublish' end  as Is_Publish,Comments  --Change By Jaina 23-10-2015 IsNull(SPE.Is_Publish,0) = 1
						,I_Q.BRANCH_ID,I_Q.DEPT_ID,I_Q.Vertical_ID,I_Q.SubVertical_ID  --Added By Jimit 11032019
				from dbo.T0080_EMP_MASTER E WITH (NOLOCK) left outer join dbo.T0100_Left_Emp l WITH (NOLOCK) on E.Emp_ID =  l.Emp_ID inner join
					( select  I.Emp_Id,Branch_ID,I.Emp_Full_PF,I.Emp_Auto_Vpf,Dept_ID,Vertical_ID,SubVertical_ID 
					 from dbo.T0095_Increment I WITH (NOLOCK) inner join 
							( select max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment WITH (NOLOCK)
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = @Cmp_ID
							group by emp_ID  ) Qry on
							I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
							on E.Emp_ID = I_Q.Emp_ID  inner join
							--dbo.T0040_GENERAL_SETTING GS on E.Cmp_ID = GS.Cmp_ID and E.Branch_ID = gs.Branch_ID  LEFT OUTER JOIN 
							dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  Left outer join 
							dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on I_Q.Dept_ID = DM.Dept_Id LEFT OUTER JOIN
							dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID  
							--dbo.T0250_SALARY_PUBLISH_ESS SPE  on E.Emp_ID = SPE.Emp_ID and SPE.Is_Publish = 0 and sPE.Month = Month(@From_Date) and SPE.Year = Year(@From_Date) Inner join
							 left outer join  dbo.T0250_SALARY_PUBLISH_ESS SPE WITH (NOLOCK) on E.Emp_ID = SPE.Emp_ID and sPE.Month = Month(@From_Date) and SPE.Year = Year(@From_Date) and SPE.Sal_Type='Salary' Inner join   --Added By Jaina 23-10-2015
							#Emp_Cons EC on E.Emp_ID = EC.Emp_ID INNER JOIN
							T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON EC.Emp_ID = MS.Emp_ID AND MONTH(MS.Month_End_Date) = MONTH(@To_Date) AND YEAR(MS.Month_End_Date) = YEAR(@To_Date)  --Ankit 25032016
				WHERE E.Cmp_ID = @Cmp_Id and IsNull(SPE.Is_Publish,0) = 0 --Added By Jaina 23-10-2015
				--and GS.For_Date = (select max(for_date) From T0040_General_Setting where GS.Cmp_ID = @Cmp_ID and GS.Branch_ID =@branch_id)  --Modified By Ramiz on 17092014
						AND MS.Salary_Status = ISNULL(@Salary_Status ,MS.Salary_Status)	and Is_FNF=0
				ORDER BY E.ALPHA_EMP_CODE,E.Emp_Full_Name		
		end
RETURN
	
	
	

