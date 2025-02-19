


---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[SP_RPT_Overtime_Register] 
	 @Cmp_ID 			numeric
	,@From_Date			datetime
	,@To_Date 			datetime 
	,@Branch_ID			numeric
	,@Cat_ID 			numeric 
	,@Grd_ID 			numeric
	,@Type_ID 			numeric
	,@Dept_ID 			numeric
	,@Desig_ID 			numeric
	,@Emp_ID 			numeric
	,@constraint 		varchar(5000)
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	CREATE table #Data 
		 ( 
			Emp_Id 		numeric , 
			For_date	datetime,
			Working_Sec numeric,
			OT_Sec		numeric,
			Approve_OT_Sec numeric,
		 )
	
	
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
		end
		
		Insert into #Data (Emp_ID, For_Date,Working_Sec,OT_Sec,Approve_OT_Sec)
		
			select EIR.Emp_ID,For_Date,Working_Sec,OT_Sec,Approved_OT_Sec
					from T0160_OT_Approval EIR WITH (NOLOCK) Inner join @Emp_Cons Ec on EIR.Emp_Id = ec.Emp_ID inner Join
					(select I.Emp_ID,Emp_OT from T0095_Increment  I WITH (NOLOCK) inner join 
						(select max(increment_effective_Date)IE_Date ,Emp_ID from T0095_Increment WITH (NOLOCK)
							where increment_effective_Date <=@To_Date and Cmp_ID =@Cmp_ID group by Emp_ID)q on I.emp_ID =q.Emp_ID and 
							I.Increment_effective_Date = q.IE_Date ) IQ on eir.Emp_ID =iq.emp_ID
							Where cmp_Id= @Cmp_ID
				and for_Date >=@From_Date and For_Date <=@To_Date
				group by EIR.Emp_ID,EIR.For_Date,EIR.Working_Sec,EIR.OT_Sec,EIR.Approved_OT_Sec
	
		
	
	RETURN




