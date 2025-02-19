
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_EMP_Warning_Get_All_Cmp]
	@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		numeric   = 0
	,@Cat_ID		numeric  = 0
	,@Grd_ID		numeric = 0
	,@Type_ID		numeric  = 0
	,@Dept_ID		numeric  = 0
	,@Desig_ID		numeric = 0
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(5000) = ''
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
		
	
	
	CREATE table #Emp_Cons 
	(      
	Emp_ID numeric ,     
	Branch_ID numeric,
	Increment_ID numeric    
	)      
	
	if @Constraint <> ''
		begin
			Insert Into #Emp_Cons
			select  cast(data  as numeric),cast(data  as numeric),cast(data  as numeric) from dbo.Split (@Constraint,'#') 
		end
	else
		begin
			  Insert Into #Emp_Cons      
		      Select distinct emp_id,branch_id,Increment_ID from V_Emp_Cons where 
		      Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
		   and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
		   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
		   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
		   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
		   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
		   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
		      and Increment_Effective_Date <= @To_Date 
		      and 
                       ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
						or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
						or (Left_date is null and @To_Date >= Join_Date)      
						or (@To_Date >= left_date  and  @From_Date <= left_date )) 
						order by Emp_ID
						
			delete  from #emp_cons where Increment_ID not in (select max(Increment_ID) from T0095_Increment WITH (NOLOCK)
				where  Increment_effective_Date <= @to_date
				group by emp_ID)

			
			--Insert Into @Emp_Cons

			--select I.Emp_Id from T0095_Increment I inner join 
			--		( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment
			--		where Increment_Effective_date <= @To_Date
					
			--		group by emp_ID  ) Qry on
			--		I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date
			--Where  
			-- Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
			--and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			--and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			--and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			--and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			--and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			--and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			--and I.Emp_ID in 
			--	( select Emp_Id from
			--	(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
			--	where  
			--	(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
			--	or ( @To_Date  >= join_Date  and @To_Date <= left_date )
			--	or Left_date is null and @To_Date >= Join_Date)
			--	or @To_Date >= left_date  and  @From_Date <= left_date ) 
			
		end
		
	
	
		select I_Q.* , E.Alpha_Emp_Code + ' - '+E.Emp_Full_Name as Emp_Full_Name,Shift_Name,E.Shift_id,
					Emp_code,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender,Emp_Superior,cm.Cmp_Id
		from T0080_EMP_MASTER E WITH (NOLOCK) inner join T0010_Company_Master CM WITH (NOLOCK) on
		Cm.Cmp_Id =E.Cmp_ID inner join 
			( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date	 ) I_Q 
				on E.Emp_ID = I_Q.Emp_ID  inner join
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
					T0040_Shift_Master SM WITH (NOLOCK) on E.Shift_ID = SM.Shift_ID inner join
					T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 

		WHERE  E.Emp_ID in (select Emp_ID From #Emp_Cons) order by E.Emp_Code asc
		
		
		
	RETURN




