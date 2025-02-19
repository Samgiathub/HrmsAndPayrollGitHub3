
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[SP_LEAVE_CLOSING_OPENING_AS_ON_DATE_LEAVE_REGISTER]
	 @Cmp_ID 		numeric
	,@From_Date 	datetime
	,@To_Date 		datetime
	,@Branch_ID		Numeric 
	,@Cat_ID		Numeric	
	,@Grd_ID		Numeric
	,@Type_ID		Numeric 
	,@Dept_Id		Numeric
	,@Desig_Id		Numeric
	,@Emp_ID		Numeric
	--,@Leave_ID		Numeric
	,@Constraint	varchar(MAX)
	,@PBranch_ID varchar(200) = '0'
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	 
	IF @Branch_ID = 0  
		set @Branch_ID = null
		
	IF @Cat_ID = 0  
		set @Cat_ID = null

	IF @Grd_ID = 0  
		set @Grd_ID = null

	IF @Type_ID = 0  
		set @Type_ID = null

	IF @Dept_ID = 0  
		set @Dept_ID = null

	IF @Desig_ID = 0  
		set @Desig_ID = null

	IF @Emp_ID = 0  
		set @Emp_ID = null

	Declare @Emp_Cons Table
	(
		Emp_ID	numeric
	)
	
	if @Constraint <> ''
		begin
			Insert Into @Emp_Cons(Emp_ID)
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
		end
	else
		begin
		  
		 if @PBranch_ID <> '0' and isnull(@Branch_ID,0) = 0
		   Begin
			Insert Into @Emp_Cons(Emp_ID)

			select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	
							
			Where Cmp_ID = @Cmp_ID 
			and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
			--and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			and Branch_ID in (select cast(isnull(data,0) as numeric) from dbo.Split(@PBranch_ID,'#'))
			and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			AND I.Emp_ID in (select emp_Id from
					(select emp_id, Cmp_ID, join_Date, isnull(left_Date, @To_Date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
					where Cmp_ID = @Cmp_ID   and  
					(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
					or ( @From_Date <= join_Date  and @To_Date >= left_date )	
					or ( @To_Date  >= join_Date  and @To_Date <= left_date )
					or left_date is null and  @To_Date >= Join_Date)) 
		  end
		else
		  Begin
		    Insert Into @Emp_Cons(Emp_ID)

			select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment WITH (NOLOCK)
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
			AND I.Emp_ID in (select emp_Id from
					(select emp_id, Cmp_ID, join_Date, isnull(left_Date, @To_Date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
					where Cmp_ID = @Cmp_ID   and  
					(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
					or ( @From_Date <= join_Date  and @To_Date >= left_date )	
					or ( @To_Date  >= join_Date  and @To_Date <= left_date )
					or left_date is null and  @To_Date >= Join_Date))
		  end 
		end
		
	select * from 
	(
	
		Select	LT.Emp_Id, LT.Leave_Id, LM.Leave_Code,LM.Leave_Name, Month(@from_date) As [Month],Year(@from_date) As [Year],
				case when @from_date = mdate.for_date then Isnull(LT.Leave_Opening,0) + Isnull(LT.Leave_Credit,0) ELSE LT.Leave_Closing end as Leave_Used  , 'Opening' used_type , @from_date as for_date--lt.For_Date --change by rohit for cera
		From	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) Inner Join @Emp_Cons EC on LT.Emp_ID = EC.Emp_ID
				Inner Join T0040_LEAVE_MASTER LM WITH (NOLOCK) On LT.Leave_ID = LM.Leave_ID inner join 
				( select Max(For_Date) as for_date,Emp_ID,leave_id from T0140_LEAVE_TRANSACTION WITH (NOLOCK) where for_date <= @From_Date 
					--and Leave_ID in (Select Leave_ID from T0040_LEAVE_MASTER Where Leave_Sorting_No in (1,2,3) and Cmp_ID = @CMP_ID and T0040_LEAVE_MASTER.Display_leave_balance=1
					--) 
					group by Emp_ID,Leave_ID
				) mdate on mdate.Emp_ID = LT.Emp_ID and mdate.for_date = lt.For_Date
		Where	LT.Cmp_ID = @CMP_ID 
				And LT.Leave_ID =mdate.leave_id
				and lm.leave_sorting_no in (1,2,3)and LM.Display_leave_balance=1
				And lm.Cmp_ID = @CMP_ID
				and lt.Emp_ID = isnull(@EMP_ID,lt.Emp_ID)
		union 
			Select	LT.Emp_Id, LT.Leave_Id, LM.Leave_Code,LM.Leave_Name, Month(lt.For_Date) As [Month],Year(lt.For_Date) As [Year],Leave_Closing as Leave_Used  , 'Closing' used_type , lt.For_Date
			From	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)  Inner Join @Emp_Cons EC on LT.Emp_ID = EC.Emp_ID
					Inner Join T0040_LEAVE_MASTER LM WITH (NOLOCK) On LT.Leave_ID = LM.Leave_ID inner join 
					( select MAX(For_Date) as for_date,Emp_ID,leave_id from T0140_LEAVE_TRANSACTION WITH (NOLOCK) where for_date <= @To_Date and Leave_ID in (Select Leave_ID from T0040_LEAVE_MASTER WITH (NOLOCK) Where Leave_Sorting_No in (1,2,3) and Cmp_ID = @CMP_ID AND T0040_LEAVE_MASTER.Display_leave_balance=1) group by Emp_ID,Leave_ID
					) mdate on mdate.Emp_ID = LT.Emp_ID and mdate.for_date = lt.For_Date
			Where	LT.Cmp_ID = @CMP_ID 
					And LT.Leave_ID =mdate.leave_id
					And lm.Cmp_ID = @CMP_ID
					and lt.Emp_ID = isnull(@EMP_ID,lt.Emp_ID)
	
	) QryTable
	Order by Emp_Id, Leave_ID,	[Month],[Year] , used_type desc
		
					

	RETURN
