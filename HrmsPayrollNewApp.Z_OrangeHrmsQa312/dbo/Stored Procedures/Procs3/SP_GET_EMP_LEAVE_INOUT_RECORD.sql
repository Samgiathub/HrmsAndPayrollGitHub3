


---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[SP_GET_EMP_LEAVE_INOUT_RECORD]
	 @Cmp_ID 		numeric
	,@From_Date		datetime
	,@To_Date 		datetime
	,@Branch_ID		numeric   
	,@Grd_ID		numeric 
	,@Emp_ID 		numeric
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON 
	
	if @Branch_ID = 0
		set @Branch_ID = null
	if @Grd_ID = 0
		set @Grd_ID = null 
	if @Emp_ID = 0
		set @Emp_ID = null
	
	Declare @Emp_Leave_Inout Table
		(
			Emp_ID				numeric,
			for_date			datetime,
			leave_id			numeric,
			in_time				datetime,
			out_time			datetime,
			leave_period		numeric(12,1),
			Leave_Approval_ID	numeric
		)

			Declare @Emp_Cons Table
			(
				Emp_ID	numeric
			)
	
			Insert Into @Emp_Cons(Emp_ID)

			select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	
							
			Where Cmp_ID = @Cmp_ID 
	--		and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
			and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			and Grd_ID = isnull(@Grd_ID ,Grd_ID)
	--		and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
	--		and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
	--		and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			


		begin
		
			Insert Into @Emp_Leave_Inout(Emp_ID,for_date,leave_id,leave_period)
			
			Select lt.emp_ID,For_Date,Leave_ID,(isnull(Leave_Used,0) + isnull(CompOff_Used,0)) as Leave_Used -- Changed By Gadriwala Muslim 01102014
			From   T0140_LEAVE_TRANSACTION  lt WITH (NOLOCK) inner join T0080_EMP_MASTER Ea WITH (NOLOCK) on
				lt.emp_ID= ea.Emp_ID  Inner join @Emp_Cons ec on ea.emp_ID= ec.emp_ID
			And lt.For_date >=@From_Date and lt.For_date < = @To_Date 
			and (leave_used > 0	or CompOff_Used > 0)	-- Changed By Gadriwala Muslim 01102014
			--select  emp_ID,For_Date,Leave_ID,Leave_Used from T0140_LEAVE_TRANSACTION where cmp_ID=@cmp_ID and EMP_ID=@emp_ID and For_date >=@From_Date and For_date < = @To_Date 
		end
		
		
		
		update @Emp_Leave_Inout
		set in_time = EMP_IN_TIME
		,out_time = EMP_OUT_TIME
		from @Emp_Leave_Inout EN inner join 
			(select eir.Emp_Id,For_date , min(IN_TIME)as EMP_IN_TIME ,max(OUT_TIME)as EMP_OUT_TIME 
				from T0150_EMP_INOUT_RECORD EIR WITH (NOLOCK) inner join @Emp_Cons ec on eir.emp_ID =ec.emp_ID 
				where For_date >= @From_DATE and FOR_DATE <= @TO_DATE group by eir.Emp_ID,FOR_DATE) Q 
					on EN.for_date =Q.For_DATE and EN.EMP_ID = Q.EMP_ID
	
		 	 
	Delete from @Emp_Leave_Inout where in_Time is null

	Declare @leave_ID numeric 
	Declare @For_Date datetime 
	
	DEclare cur_l  cursor Static for 
		select Leave_ID ,Emp_ID ,For_Date from @Emp_Leave_Inout 
	Open Cur_l 
	Fetch next from cur_l into @leave_ID ,@Emp_ID ,@For_date
	while @@Fetch_Status = 0
		begin 
								
				Update @Emp_Leave_Inout
				set LEave_Approval_ID = q.leavE_Approval_ID 
				From @Emp_Leave_Inout  el inner join 
				(select la.Leave_Approval_ID ,Emp_ID from T0130_LEAVE_APPROVAL_DETAIL ld WITH (NOLOCK) inner join T0120_LEAVE_APPROVAL La WITH (NOLOCK) on
				ld.leave_approval_ID = la.leave_Approval_ID and Emp_ID = @emp_ID and leave_ID =@leave_ID 
				and @For_date >=From_Date and @For_date <= To_date)Q on el.emp_Id= q.emp_ID
		 
				Fetch next from cur_l into @leave_ID ,@Emp_ID ,@For_date
		end
	close cur_l 
	deallocate cur_l 
	
	
	select EI.Emp_ID,EI.for_date,EI.leave_id,EI.in_time,dbo.F_GET_AMPM(EI.in_time) as IN_TIME_new,EI.out_time,dbo.F_GET_AMPM(EI.out_time) as OUT_TIME_new,EI.leave_period,EI.Leave_Approval_ID,LM.Leave_NAME,EM.Emp_full_name from @Emp_Leave_Inout EI inner join T0040_LEAVE_MASTER LM WITH (NOLOCK) on EI.Leave_ID = LM.Leave_ID inner join t0080_emp_master EM WITH (NOLOCK) on EI.Emp_ID = EM.Emp_Id order by for_date asc
	
	
	

