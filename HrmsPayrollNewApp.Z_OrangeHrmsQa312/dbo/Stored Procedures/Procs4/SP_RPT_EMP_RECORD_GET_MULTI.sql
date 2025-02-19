

---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_EMP_RECORD_GET_MULTI]
	 @Cmp_ID		VARCHAR(MAX)
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		varchar(max)
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
	,@Segment_Id  numeric = 0		 -- Added By Gadriwala Muslim 24072013
	,@Vertical_Id numeric = 0		 -- Added By Gadriwala Muslim 24072013
	,@SubVertical_Id numeric = 0	 -- Added By Gadriwala Muslim 24072013	
	,@SubBranch_Id numeric = 0		 -- Added By Gadriwala Muslim 01082013	
	,@Report_Type varchar(50) = ''		 -- Added By Jignesh Patel 13-Dec-2013	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if @Salary_Cycle_id = 0
		set @Salary_Cycle_id =NULL

	if @Branch_ID = '0'
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
	
	If @Segment_Id = 0		 -- Added By Gadriwala Muslim 24072013
	set @Segment_Id = null
	If @Vertical_Id = 0		 -- Added By Gadriwala Muslim 24072013
	set @Vertical_Id = null
	If @SubVertical_Id = 0	 -- Added By Gadriwala Muslim 24072013
	set @SubVertical_Id = null	
	If @SubBranch_Id = 0	 -- Added By Gadriwala Muslim 01082013
	set @SubBranch_Id = null	
	
	
		   DECLARE @Show_Left_Employee_for_Salary AS TINYINT
  SET @Show_Left_Employee_for_Salary = 0
  
  --SELECT @Show_Left_Employee_for_Salary = ISNULL(Setting_Value,0) 
  --FROM T0040_SETTING WHERE Cmp_ID = @Cmp_ID AND Setting_Name LIKE 'Show Left Employee for Salary'

	
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
			Select distinct emp_id,branch_id,Increment_ID From V_Emp_Cons 
			Where Cmp_id in (select data from dbo.Split(@Cmp_ID,'#'))
				and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
				and Branch_ID in (Case when not @Branch_ID is null then (select data from dbo.Split(@Branch_ID,'#')) else '%%' end)
				and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
				and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
				and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
				and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))  
				and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))	 -- Added By Gadriwala Muslim 24072013
				and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 -- Added By Gadriwala Muslim 24072013
				and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) -- Added By Gadriwala Muslim 24072013
				and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) -- Added By Gadriwala Muslim 01082013
				and Emp_ID = isnull(@Emp_ID ,Emp_ID)  
				and Increment_Effective_Date <= @To_Date 
				and Date_of_Join >=@From_Date and Date_OF_Join <=@to_Date
			Order by Emp_ID
						
-- Commented and Added by rohit on 17122013 for polycab issue employee transfer
			--Delete  From #Emp_Cons Where Increment_ID Not In (Select Max(Increment_ID) from T0095_Increment
			--	Where  Increment_effective_Date <= @to_date Group by emp_ID)

				Delete From #Emp_Cons Where Increment_ID Not In
				(select TI.Increment_ID from t0095_increment TI WITH (NOLOCK) inner join
				(Select Max(Increment_Effective_Date) as Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
				Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Effective_Date
				Where Increment_effective_Date <= @to_date)

-- Ended by rohit on 17122013 
		
			--Insert Into #Emp_Cons
			--select I.Emp_Id from dbo.T0095_Increment I inner join dbo.T0080_Emp_Master e on i.Emp_ID = E.Emp_ID inner join 
			--		( select max(Increment_effective_Date) as For_Date , Emp_ID from dbo.T0095_Increment
			--		where Increment_Effective_date <= @To_Date
			--		and Cmp_ID = @Cmp_ID
			--		group by emp_ID  ) Qry on
			--		I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date
			--Where I.Cmp_ID = @Cmp_ID 
			--and Isnull(I.Cat_ID,0) = Isnull(@Cat_ID ,Isnull(I.Cat_ID,0))
			--and I.Branch_ID = isnull(@Branch_ID ,I.Branch_ID)
			--and I.Grd_ID = isnull(@Grd_ID ,I.Grd_ID)
			--and isnull(I.Dept_ID,0) = isnull(@Dept_ID ,isnull(I.Dept_ID,0))
			--and Isnull(I.Type_ID,0) = isnull(@Type_ID ,Isnull(I.Type_ID,0))
			--and Isnull(I.Desig_ID,0) = isnull(@Desig_ID ,Isnull(I.Desig_ID,0))
			--and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			--and Date_of_Join >=@From_Date and Date_OF_Join <=@to_Date
		end
	else if @Left_Emp = 1 
		begin

			Insert Into #Emp_Cons      
			Select distinct emp_id,branch_id,Increment_ID 
			From V_Emp_Cons Where Cmp_id in (select data from dbo.Split(@Cmp_ID,'#'))
				and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
				and Branch_ID in (Case when not @Branch_ID is null then (select data from dbo.Split(@Branch_ID,'#')) else Branch_ID end)
				and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
				and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
				and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
				and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))  
				and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))			 -- Added By Gadriwala Muslim 24072013
				and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))		 -- Added By Gadriwala Muslim 24072013	
				and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) -- Added By Gadriwala Muslim 24072013
				and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) -- Added By Gadriwala Muslim 01082013
				and Emp_ID = isnull(@Emp_ID ,Emp_ID)  
				and Increment_Effective_Date <= @To_Date 
				and Left_date >=@From_Date and Left_Date <=@to_Date
			Order by Emp_ID
						
-- Commented and Added by rohit on 17122013 for polycab issue employee transfer
			--Delete  From #Emp_Cons Where Increment_ID Not In (Select Max(Increment_ID) from T0095_Increment
			--	Where  Increment_effective_Date <= @to_date Group by emp_ID)

		Delete From #Emp_Cons Where Increment_ID Not In
				(select TI.Increment_ID from t0095_increment TI WITH (NOLOCK) inner join
				(Select Max(Increment_Effective_Date) as Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
				Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Effective_Date
				Where Increment_effective_Date <= @to_date)
-- Commented and Added by rohit on 17122013 

			--Insert Into #Emp_Cons

			--select I.Emp_Id from dbo.T0095_Increment I inner join T0100_lefT_emp Le on i.emp_Id = le.emp_ID inner join 
			--		( select max(Increment_effective_Date) as For_Date , Emp_ID from dbo.T0095_Increment
			--		where Increment_Effective_date <= @To_Date
			--		and Cmp_ID = @Cmp_ID
			--		group by emp_ID  ) Qry on
			--		I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date
			--Where I.Cmp_ID = @Cmp_ID 
			--and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
			--and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			--and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			--and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			--and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			--and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			--and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			--and Left_date >=@From_Date and Left_Date <=@to_Date
		end		
	else 
		begin

			-- below condition changed by mitesh on 05072013
			Insert Into #Emp_Cons      
		      select distinct emp_id,V_Emp_Cons.branch_id,Increment_ID from V_Emp_Cons
				inner join T0040_GENERAL_SETTING g WITH (NOLOCK) on V_Emp_Cons.branch_id=g.branch_id --Ankit 05032014
		        left OUTER JOIN  (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id as eid FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)
							inner join 
							(SELECT max(Effective_date) as Effective_date,emp_id FROM T0095_Emp_Salary_Cycle WITH (NOLOCK) where Effective_date <= @To_Date
							GROUP BY emp_id) Qry
							on Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id) as QrySC
		       ON QrySC.eid = V_Emp_Cons.Emp_ID
		  where 
		     V_Emp_Cons.Cmp_id in (select data from dbo.Split(@Cmp_ID,'#')) and
		       Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
			   --and V_Emp_Cons.Branch_ID = isnull(@Branch_ID ,V_Emp_Cons.Branch_ID)      
			   and V_Emp_Cons.Branch_ID in (case when @Branch_ID is null then 
											(V_Emp_Cons.Branch_ID) 
									else isnull((select data from dbo.Split(@Branch_ID,'#') where data = V_Emp_Cons.Branch_ID),0) end)
			   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
			   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
			   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
			   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
			   and isnull(QrySC.SalDate_id,0) = isnull(@Salary_Cycle_id ,isnull(QrySC.SalDate_id,0))  
			   and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))       -- Added By Gadriwala Muslim 24072013
			   and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 -- Added By Gadriwala Muslim 24072013
			   and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0))  -- Added By Gadriwala Muslim 24072013
			   and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) -- Added By Gadriwala Muslim 01082013
			   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
		       and Increment_Effective_Date <= @To_Date 
		       and 
                      ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
						or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
						or (Left_date is null and @To_Date >= Join_Date)      
						or (@To_Date >= left_date  and  @From_Date <= left_date )
						--OR 1=(case when ((@Show_Left_Employee_for_Salary = 1) and (left_date <= @To_Date) and (dateadd(mm,1,Left_Date) > @From_Date ))  then 1 else 0 end)
						OR 1=(CASE WHEN ((@Show_Left_Employee_for_Salary = 1) AND (left_date >= case when (isnull(Sal_St_Date,'')) = ''  then @From_Date  when day(Sal_St_Date) = 1  then @From_Date  else  (cast(cast(day(Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@To_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@To_Date) )as varchar(10)) as smalldatetime)) end AND left_date <= case when (isnull(Sal_St_Date,'')) = ''  then @to_date when day(sal_st_date)=1 then @to_date else  dateadd(d,-1,dateadd(m,1,(cast(cast(day(Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@To_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@To_Date) )as varchar(10)) as smalldatetime)))) end))  THEN 1 ELSE 0 END)	--Ankit 05032014
						) 
						order by Emp_ID
						
			

				-- Commented and Added by rohit on 17122013 for polycab issue employee transfer
			--delete  from #emp_cons where Increment_ID not in (select max(Increment_ID) from T0095_Increment
			--	where  Increment_effective_Date <= @to_date
			--	group by emp_ID)

		Delete From #Emp_Cons Where Increment_ID Not In
				(select TI.Increment_ID from t0095_increment TI WITH (NOLOCK) inner join
				(Select Max(Increment_Effective_Date) as Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
				Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Effective_Date
				Where Increment_effective_Date <= @to_date)
-- Commented and Added by rohit on 17122013 
				
				
			--Insert Into #Emp_Cons      
		   --   select distinct emp_id,branch_id,Increment_ID from V_Emp_Cons where 
		   --   cmp_id=@Cmp_ID 
		   --    and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
		   --and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
		   --and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
		   --and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
		   --and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
		   --and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
		   --and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
		   --   and Increment_Effective_Date <= @To_Date 
		   --   and 
     --                 ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
					--	or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
					--	or (Left_date is null and @To_Date >= Join_Date)      
					--	or (@To_Date >= left_date  and  @From_Date <= left_date )
					--	OR 1=(case when ((@Show_Left_Employee_for_Salary = 1) and (left_date <= @To_Date) and (dateadd(mm,1,Left_Date) > @From_Date ))  then 1 else 0 end)
					--	) 
					--	order by Emp_ID
						
			--delete  from #emp_cons where Increment_ID not in (select max(Increment_ID) from T0095_Increment
			--	where  Increment_effective_Date <= @to_date
			--	group by emp_ID)
		
		end

		
	if @Report_Type =''
		begin
			select I_Q.* ,E.Emp_Last_Name,E.Emp_Second_Name, E.Street_1,E.City,E.State,E.Emp_Full_Name ,E.Worker_Adult_No,E.Father_Name, E.Emp_Code,E.Alpha_Emp_Code,E.Emp_First_Name,Left_Date,BM.Comp_Name,BM.Branch_Address,Left_Reason
						,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Date_Of_Birth,Emp_Mark_Of_Identification,Gender,@From_Date as From_Date ,@To_Date as To_Date
						,Cmp_Name,Cmp_Address,Present_Street,Present_State,Present_City,Present_Post_Box,l.left_reason,DATEDIFF(YY,ISNULL(Date_of_bIRTH,getdate()),GETDATE()) AS AGE,
						Nature_of_Business,Cmp_City,Cmp_State_Name,Cmp_PinCode,E.mobile_no
						
			from dbo.T0080_EMP_MASTER E WITH (NOLOCK) left outer join dbo.T0100_Left_Emp l WITH (NOLOCK) on E.Emp_ID =  l.Emp_ID inner join
				( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from dbo.T0095_Increment I WITH (NOLOCK) inner join 
						( select max(Increment_effective_Date) as For_Date , Emp_ID from dbo.T0095_Increment WITH (NOLOCK)
						where Increment_Effective_date <= @To_Date
						and Cmp_id in (select data from dbo.Split(@Cmp_ID,'#')) 
						group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date	 ) I_Q 
					on E.Emp_ID = I_Q.Emp_ID  inner join
						dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
						dbo.T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
						dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
						dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
						dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  Inner join 
						dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID Inner Join
						#Emp_Cons EC on E.Emp_ID = EC.Emp_ID

			WHERE E.Cmp_id in (select data from dbo.Split(@Cmp_ID,'#')) 	
			Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End
			--ORDER BY RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) 
		end
		
	else
						
		if @Report_Type = 'ID Card'
			begin
				select I_Q.* ,E.Emp_Last_Name,E.Emp_Second_Name, E.Street_1,E.City,E.State,
				--E.Emp_Full_Name 
				isnull(E.Initial,'')+' '+E.Emp_First_Name + ' '+ isnull(E.Emp_Last_Name,'') as Emp_Full_Name
				,E.Worker_Adult_No,E.Father_Name, 
				--E.Emp_Code
				E.Enroll_no as Emp_Code
				,E.Alpha_Emp_Code,E.Emp_First_Name,Left_Date,BM.Comp_Name,BM.Branch_Address,Left_Reason
							,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Date_Of_Birth,Emp_Mark_Of_Identification,Gender,@From_Date as From_Date ,@To_Date as To_Date
							,Cmp_Name,Cmp_Address,Present_Street,Present_State,Present_City,Present_Post_Box,l.left_reason,DATEDIFF(YY,ISNULL(Date_of_bIRTH,getdate()),GETDATE()) AS AGE,
							Nature_of_Business,Cmp_City,Cmp_State_Name,Cmp_PinCode,E.mobile_no,E.Image_Name,Blood_Group ,cast ( 0 as VARBINARY(max)) as Emp_Image 
				from dbo.T0080_EMP_MASTER E WITH (NOLOCK) left outer join dbo.T0100_Left_Emp l WITH (NOLOCK) on E.Emp_ID =  l.Emp_ID inner join
					( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from dbo.T0095_Increment I WITH (NOLOCK) inner join 
							( select max(Increment_effective_Date) as For_Date , Emp_ID from dbo.T0095_Increment WITH (NOLOCK)
							where Increment_Effective_date <= @To_Date
							and Cmp_id in (select data from dbo.Split(@Cmp_ID,'#')) 
							group by emp_ID  ) Qry on
							I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date	 ) I_Q 
						on E.Emp_ID = I_Q.Emp_ID  inner join
							dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
							dbo.T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
							dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
							dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
							dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  Inner join 
							dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID Inner Join
							#Emp_Cons EC on E.Emp_ID = EC.Emp_ID

				WHERE E.Cmp_id in (select data from dbo.Split(@Cmp_ID,'#')) 	
				Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End
				--ORDER BY RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) 
				
		
		end
				
		
		
	RETURN


