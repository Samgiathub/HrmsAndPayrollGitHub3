


---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[SP_RPT_LEAVE_BALANCE_GET_SUB_SP]
	 @Cmp_ID		Numeric
	,@From_Date		Datetime
	,@To_Date		Datetime
	,@Branch_ID		Numeric 
	,@Cat_ID		Numeric
	,@Grd_ID		Numeric
	,@Type_ID		Numeric 
	,@Dept_Id		Numeric
	,@Desig_Id		Numeric
	,@Emp_ID		Numeric
	,@Leave_ID		Numeric
	,@Constraint	varchar(5000)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		declare @Closing as numeric(18,1)
		declare @Opening as numeric(18,1)
		declare @Earn as numeric(18,1)
		declare @Adj_LMark as numeric(18,1)
		declare @Adj_Absent as numeric(18,1)	
		declare @Total_Adj as numeric(18,1)
		
		Declare @Emp_Leave_Bal table
			(
				Cmp_ID			numeric,
				Emp_ID			numeric,
				For_Date		datetime,
				Leave_Opening	numeric(18,1),
				Leave_Credit	numeric(18,1),
				Leave_Used		numeric(18,1),
				Leave_Closing	numeric(18,1),
				Leave_ID		numeric
			) 

		
	if @Branch_ID = 0
		set @Branch_ID = null
	If @Cat_ID = 0
		set @Cat_ID  = null
	if @Type_ID = 0
		set @Type_ID = null
	if @Dept_ID = 0
		set @Dept_ID = null
	if @Grd_ID = 0
		set @Grd_ID = null
	if @Desig_ID = 0
		set @Desig_ID = null
	if @Emp_ID = 0
		set @Emp_ID = null
		
 	
		
	Declare @Emp_Cons Table
	(
		Emp_ID	numeric
	)
	
	if @Constraint <> ''
		begin
			Insert Into @Emp_Leave_Bal
			select  @Cmp_ID , cast(data  as numeric),@From_Date,0,0,0,0,@Leave_ID from dbo.Split (@Constraint,'#') 
		end
	else
		begin
			
			Insert Into @Emp_Leave_Bal
			
			select @Cmp_ID , I.Emp_Id ,@From_Date,0,0,0,0,@Leave_ID from T0095_Increment I WITH (NOLOCK) inner join 
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
		
			update @Emp_Leave_Bal 
			set Leave_Opening = leave_Bal.Leave_Closing
			From @Emp_Leave_Bal  LB Inner join  
			( select lt.* From T0140_leave_Transaction LT WITH (NOLOCK) inner join 
				( select max(For_Date) For_Date , Emp_ID ,leave_ID from T0140_leave_Transaction WITH (NOLOCK) where For_date <= @From_Date and Cmp_ID = @Cmp_ID
				and LEave_ID = @Leave_ID 
				Group by Emp_ID ,LEave_ID ) q on Lt.Emp_Id = Q.Emp_ID and lt.For_Date = Q.For_Date and lt.Leave_ID = Q.LEave_ID
				)Leave_Bal on LB.LEave_ID = LEave_Bal.Leave_ID and LB.Emp_ID = leave_Bal.Emp_ID 

			update @Emp_Leave_Bal 
			set Leave_Opening = leave_Bal.Leave_Opening
			From @Emp_Leave_Bal  LB Inner join  
			( select lt.* From T0140_leave_Transaction LT WITH (NOLOCK) inner join 
				( select max(For_Date) For_Date , Emp_ID ,leave_ID from T0140_leave_Transaction WITH (NOLOCK) where For_date = @From_Date and Cmp_ID = @Cmp_ID
				and LEave_ID = @Leave_ID 
				Group by Emp_ID ,LEave_ID ) q on Lt.Emp_Id = Q.Emp_ID and lt.For_Date = Q.For_Date and lt.Leave_ID = Q.LEave_ID
				)Leave_Bal on LB.LEave_ID = LEave_Bal.Leave_ID and LB.Emp_ID = leave_Bal.Emp_ID 
			
			update @Emp_Leave_Bal 
			set Leave_Credit = Q.Leave_Credit
			From @Emp_Leave_Bal  LB Inner join  
			( select Emp_ID , Leave_ID ,Sum(Leave_Credit) as Leave_Credit From T0140_LEave_Transaction WITH (NOLOCK)
				Where Cmp_ID = @Cmp_ID and LEave_ID = @Leave_ID and For_Date >=@From_date and For_Date <=@To_Date
				Group by Emp_ID ,LEave_ID)Q on
				lb.LEave_ID = Q.LEave_ID and Lb.emp_ID = Q.Emp_ID
			
			update @Emp_Leave_Bal 
			set Leave_Used = Q.Leave_Used
			From @Emp_Leave_Bal  LB Inner join  
			( select Emp_ID , Leave_ID ,Sum(Leave_Used) as Leave_Used From T0140_LEave_Transaction WITH (NOLOCK)
				Where Cmp_ID = @Cmp_ID and LEave_ID = @Leave_ID and For_Date >=@From_date and For_Date <=@To_Date
				Group by Emp_ID ,LEave_ID)Q on
				lb.LEave_ID = Q.LEave_ID and Lb.emp_ID = Q.Emp_ID

			update @Emp_Leave_Bal 
			set Leave_Closing = leave_Bal.Leave_Closing 
			From @Emp_Leave_Bal  LB Inner join  
			( select lt.* From T0140_leave_Transaction LT WITH (NOLOCK) inner join 
				( select max(For_Date) For_Date , Emp_ID ,leave_ID from T0140_leave_Transaction WITH (NOLOCK) where For_date <= @To_Date and Cmp_ID = @Cmp_ID
				and LEave_ID = @Leave_ID 
				Group by Emp_ID ,LEave_ID ) q on Lt.Emp_Id = Q.Emp_ID and lt.For_Date = Q.For_Date and lt.Leave_ID = Q.LEave_ID
				)Leave_Bal on LB.LEave_ID = LEave_Bal.Leave_ID and LB.Emp_ID = leave_Bal.Emp_ID 
			

	insert into #Emp_Leave_Bal
	select * from @Emp_Leave_Bal

	RETURN 




