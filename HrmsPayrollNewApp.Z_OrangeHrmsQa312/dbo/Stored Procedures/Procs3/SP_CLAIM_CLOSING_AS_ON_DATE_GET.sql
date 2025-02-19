



---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_CLAIM_CLOSING_AS_ON_DATE_GET]
	 @Cmp_ID		numeric
	,@To_Date		datetime 
	,@Branch_ID		numeric   = 0
	,@Cat_ID		numeric  = 0
	,@Grd_ID		numeric = 0
	,@Type_ID		numeric  = 0
	,@Dept_ID		numeric  = 0
	,@Desig_ID		numeric = 0
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(1000) = ''
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
	
	Declare @claim_closing table
		(
			Cmp_id			numeric,
			emp_id			Numeric,
			Claim_apr_ID		Numeric,
			Claim_ID			Numeric,
			Claim_Issue		numeric,
			Claim_Return		numeric,
			Claim_Closing	numeric,
			For_Date		Datetime
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
			
		end

		Insert into @Claim_closing (Cmp_ID ,Emp_Id,Claim_Id,Claim_Apr_Id,Claim_Issue,For_Date,Claim_Return,Claim_Closing)
			select Cmp_ID , Emp_ID ,Claim_Id ,Claim_Apr_ID , Claim_Apr_Amount , @To_Date ,0 ,0 From T0120_Claim_Approval WITH (NOLOCK)
			where Cmp_ID = @Cmp_ID and Emp_ID in (Select Emp_ID From @Emp_Cons )
				and Claim_Apr_Pending_Amount >0
		
		Update @Claim_Closing 
		set Claim_Return = mlp.Claim_Pay_Amount
		From @Claim_Closing  Lc  inner join 
		(select Claim_apr_ID , Sum(Claim_pay_amount) Claim_Pay_Amount  From 
			T0210_MONTHLY_Claim_PAYMENT WITH (NOLOCK) where Cmp_ID = @Cmp_ID  Group by Claim_Apr_ID ) mlp on lc.Claim_apr_ID = Mlp.Claim_apr_ID 	
		
		
		Update @Claim_Closing 
		set Claim_closing = Q1.Claim_closing
		From @Claim_Closing lc Inner join 
		( select lt.Emp_ID ,Lt.Claim_ID, Sum(Claim_Closing) Claim_Closing from T0140_Claim_transaction LT WITH (NOLOCK) inner join 
		( select Emp_ID , Claim_ID , max(for_Date) for_Date  from T0140_Claim_transaction WITH (NOLOCK)
		Where For_Date <=for_date group by emp_ID  , Claim_ID ) Q on Lt.Emp_ID = Q.Emp_ID and lt.Claim_ID = Q.Claim_ID 
		and Lt.For_Date = Q.For_Date Group by lt.Emp_ID ,lt.Claim_ID) Q1 on lc.Claim_ID = q1.Claim_ID
		and Lc.Emp_ID = Q1.Emp_ID
	
		select lc.*,Claim_Name from @Claim_Closing lc  Inner join T0040_Claim_Master lm WITH (NOLOCK) on lc.Claim_ID = Lm.Claim_ID
		



