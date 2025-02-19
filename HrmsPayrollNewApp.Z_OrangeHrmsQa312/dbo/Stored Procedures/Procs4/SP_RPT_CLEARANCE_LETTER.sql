

---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_CLEARANCE_LETTER]
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
		
	
	
	Declare @Emp_Cons Table
	(
		Emp_ID	numeric
	)
	
	if @Constraint <> ''
		begin
			Insert Into @Emp_Cons
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
		end
	else
		begin
			
			
			Insert Into @Emp_Cons

			select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date
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
				where cmp_ID = @Cmp_ID   and  
				(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
				or ( @To_Date  >= join_Date  and @To_Date <= left_date )
				or Left_date is null and @To_Date >= Join_Date)
				or @To_Date >= left_date  and  @From_Date <= left_date ) 
			
		end
		
	CREATE table #Emp_Data 
		(
			Emp_ID numeric(18,0),
			P_Leaves numeric(18,2),
			P_Advance numeric(22,2),
			p_Days numeric(18,2)
		)
	
	insert into #Emp_Data 
	select Emp_ID,0,0,0 from @Emp_Cons 	where Emp_ID in
	(select Emp_ID from T0100_LEFT_EMP WITH (NOLOCK)  where Cmp_ID=@Cmp_ID and LEFT_DATE <=@TO_DATE AND LEFT_DATE >= @FROM_DATE)
			
			
	
	update 	#Emp_Data 
	set P_Leaves = q.Leave_Closing
	from #Emp_Data EC inner join
	(select Emp_ID,Leave_Closing  from  T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) inner join T0040_LEAVE_MASTER LM WITH (NOLOCK)
	on LT.Leave_ID=LM.Leave_ID where LM.Leave_Code='PL'
	And LT.Leave_Tran_ID in (select MAX(Leave_Tran_ID) from T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Cmp_ID=@Cmp_ID group by Emp_ID)
	)q on EC.Emp_ID=Q.emp_id where EC.Emp_ID =q.Emp_ID 
		
		
	update 	#Emp_Data 
	set P_Advance = q.Adv_Closing
	from #Emp_Data EC inner join
	(select Emp_ID,Adv_Closing  from  T0140_ADVANCE_TRANSACTION WITH (NOLOCK) where Adv_Tran_ID in (select MAX(Adv_Tran_ID) from T0140_ADVANCE_TRANSACTION WITH (NOLOCK) where Cmp_ID=@Cmp_ID group by Emp_ID)
	)q on EC.Emp_ID=Q.emp_id where EC.Emp_ID =q.Emp_ID 	
		
	
	update 	#Emp_Data 
	set p_Days = q.p_days
	from #Emp_Data EC inner join
	(select EIR.Emp_ID,COUNT(EIR.IO_Tran_Id )as p_days  from  T0150_EMP_INOUT_RECORD  EIR WITH (NOLOCK)
	inner join T0100_LEFT_EMP LM WITH (NOLOCK) on EIR.Emp_ID=LM.Emp_ID where EIR.For_Date  >=@From_Date and EIR.For_Date <=LM.Left_Date  Group by EIR.Emp_ID )
	q on EC.Emp_ID=Q.emp_id where EC.Emp_ID =q.Emp_ID 	
		
		
		
		select I_Q.* ,ED.P_Advance,Ed.p_Days ,ED.P_Leaves, E.Emp_Code,E.Emp_Full_Name as Emp_Full_Name,dateadd(d,-1,eMP_lEFT_DATE)  as eMP_lEFT_DATE,CM.Cmp_Name,CM.Cmp_Address,LE.REG_ACCEPT_DATE,dateadd(d,-1,LE.LEFT_DATE) as LEFT_DATE,street_1,city,emp_first_name
					,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Branch_Address,Comp_Name
					,E.Alpha_Emp_Code                   --added jimit 28052015
		from T0080_EMP_MASTER E WITH (NOLOCK) inner join 
		     T0010_Company_master CM WITH (NOLOCK) on E.Cmp_ID =Cm.Cmp_ID inner join
		     T0100_LEFT_EMP LE WITH (NOLOCK) ON E.EMP_ID = LE.EMP_ID INNER JOIN
		     ( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date	 ) I_Q 
				on E.Emp_ID = I_Q.Emp_ID  inner join
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
					T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID inner join
					#Emp_Data ED on E.Emp_ID=ED.Emp_ID 

		WHERE E.Cmp_ID = @Cmp_Id	AND
		LE.LEFT_DATE <=@TO_DATE AND LE.LEFT_DATE >= @FROM_DATE 
		AND
		   E.Emp_ID in (select Emp_ID From @Emp_Cons) order by E.Emp_Code asc 
				
 		
		
	RETURN




