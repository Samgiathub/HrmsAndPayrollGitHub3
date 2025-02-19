
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_Leave_Application_Form]
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
	,@Leave_ID		varchar(max) 
	,@Constraint	varchar(MAX)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
		
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
	
	IF Object_ID('tempdb..#Emp_Leave_Details') Is not NULL
		Drop TABLE #Emp_Leave_Details
		
	Create Table #Emp_Leave_Details
	(
		Emp_ID Numeric(18,0),
		Leave_Code Varchar(Max)
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
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)	-- Ankit 08092014 for Same Date Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	
					cross join #Leave_ID LI
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
	
	
	DECLARE @categories_Paid varchar(Max)
	DECLARE @categories_unPaid varchar(Max)
	DECLARE @categories_Compoff varchar(Max)
	
	Declare @Cur_Emp_ID Numeric(18,0)
	
	Declare cur_Leave_Details Cursor FOR 
	Select Emp_ID From @Emp_Cons 
	Open  cur_Leave_Details
		fetch Next From cur_Leave_Details into @Cur_Emp_ID
		While @@fetch_status = 0 
			Begin
				 Set @categories_Paid = NULL 
				 Set @categories_unPaid = NULL
				 Set @categories_Compoff = NULL
				 Select @categories_Paid = COALESCE(@categories_Paid + '/','') + LM.Leave_Code FROM T0040_LEAVE_MASTER LM WITH (NOLOCK) Inner Join T0050_LEAVE_DETAIL LD WITH (NOLOCK)
				 ON LM.Leave_ID = LD.Leave_ID INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK)
				 ON EM.Grd_ID = LD.Grd_ID
				 Where EM.Emp_ID = @Cur_Emp_ID AND Leave_Paid_Unpaid = 'P' AND LM.Leave_Code <> 'COMP'
				 
				 Insert INTO #Emp_Leave_Details(Emp_ID,Leave_Code) SELECT @Cur_Emp_ID,@categories_Paid From @Emp_Cons
				 
				 --Select @categories_unPaid = COALESCE(@categories_unPaid + '/','') + LM.Leave_Code FROM T0040_LEAVE_MASTER LM Inner Join T0050_LEAVE_DETAIL LD 
				 --ON LM.Leave_ID = LD.Leave_ID INNER JOIN T0080_EMP_MASTER EM
				 --ON EM.Grd_ID = LD.Grd_ID
				 --Where EM.Emp_ID = @Cur_Emp_ID AND Leave_Paid_Unpaid = 'U' 
				 
				 --Insert INTO #Emp_Leave_Details(Emp_ID,Leave_Code) SELECT @Cur_Emp_ID,@categories_unPaid From @Emp_Cons
				 
				 --Select @categories_Compoff = COALESCE(@categories_Compoff + '/','') + LM.Leave_Code FROM T0040_LEAVE_MASTER LM Inner Join T0050_LEAVE_DETAIL LD 
				 --ON LM.Leave_ID = LD.Leave_ID INNER JOIN T0080_EMP_MASTER EM
				 --ON EM.Grd_ID = LD.Grd_ID
				 --Where EM.Emp_ID = @Cur_Emp_ID AND Leave_Paid_Unpaid = 'P' AND LM.Leave_Code = 'COMP'
				 
				 --Insert INTO #Emp_Leave_Details(Emp_ID,Leave_Code) SELECT @Cur_Emp_ID,@categories_Compoff From @Emp_Cons
				
				fetch Next From cur_Leave_Details into @Cur_Emp_ID
			End
	Close cur_Leave_Details
	deallocate cur_Leave_Details
	
	SELECT DISTINCT * From #Emp_Leave_Details

	RETURN 




