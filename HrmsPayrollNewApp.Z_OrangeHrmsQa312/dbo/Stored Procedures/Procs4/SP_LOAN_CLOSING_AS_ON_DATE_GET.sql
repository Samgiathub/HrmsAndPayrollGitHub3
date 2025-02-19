

---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_LOAN_CLOSING_AS_ON_DATE_GET]
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
	,@Flag			tinyint = 0 -- Added by nilesh patel on 30082016 For Skip Monthly Loan Installment 
	,@Request_ID	numeric(18,0) = 0 -- Added by nilesh patel on 30082016 For Skip Monthly Loan Installment
	,@S_Emp_ID		numeric(18,0) = 0 -- Added by nilesh patel on 30082016 For Skip Monthly Loan Installment
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
		Set @Grd_ID = null
	if @Emp_ID = 0
		Set @Emp_ID = null
	If @Desig_ID = 0
		Set @Desig_ID = null
		
	Declare @Emp_Cons Table
	(
		Emp_ID	numeric
	)
	
	Declare @loan_closing table
		(
			Cmp_id			numeric,
			emp_id			Numeric,
			Loan_apr_ID		Numeric,
			Loan_ID			Numeric,
			Loan_Issue		numeric,
			Loan_Return		numeric,
			Loan_Closing	numeric(18,2),
			For_Date		Datetime,
			Loan_Installment_Amt Numeric(18,2) --Added by nilesh patel for Show Loan Details in change Request
		)
	
	if @Constraint <> ''
		begin
			Insert Into @Emp_Cons
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
		end
	else
		begin
			
			Insert Into @Emp_Cons

			select I.Emp_Id from dbo.T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID from dbo.T0095_Increment WITH (NOLOCK)
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

		Insert into @Loan_closing (Cmp_ID ,Emp_Id,Loan_Id,Loan_Apr_Id,Loan_Issue,For_Date,Loan_Return,Loan_Closing,Loan_Installment_Amt)
		select Cmp_ID , Emp_ID ,Loan_Id ,Loan_Apr_ID , Loan_Apr_Amount , @To_Date ,0 ,0,Loan_Apr_Installment_Amount From dbo.T0120_Loan_Approval WITH (NOLOCK)
			where Cmp_ID = @Cmp_ID and Emp_ID in (Select Emp_ID From @Emp_Cons )
				and Loan_Apr_Pending_Amount >0
				
		
		
		Update @Loan_Closing 
		set Loan_Return = mlp.Loan_Pay_Amount
		From @Loan_Closing  Lc  inner join 
		(Select Loan_apr_ID , Sum(Loan_pay_amount) Loan_Pay_Amount  From 
			dbo.T0210_MONTHLY_LOAN_PAYMENT WITH (NOLOCK) where Cmp_ID = @Cmp_ID  Group by Loan_Apr_ID ) mlp on lc.loan_apr_ID = Mlp.Loan_apr_ID 	
		
		
		
		Update @Loan_Closing 
		set Loan_closing = Q1.Loan_closing
		From @Loan_Closing lc Inner join 
		(Select lt.Emp_ID ,Lt.Loan_ID, Sum(Loan_Closing) Loan_Closing from dbo.T0140_loan_transaction LT WITH (NOLOCK) inner join 
		(Select Emp_ID , Loan_ID , max(for_Date) for_Date  from T0140_loan_transaction WITH (NOLOCK)
			Where For_Date <=for_date group by emp_ID  , Loan_ID ) Q on Lt.Emp_ID = Q.Emp_ID and lt.Loan_ID = Q.Loan_ID 
		and Lt.For_Date = Q.For_Date Group by lt.Emp_ID ,lt.Loan_ID) Q1 on lc.Loan_ID = q1.Loan_ID
		and Lc.Emp_ID = Q1.Emp_ID
		
		if @Request_ID = 0
			Set @Request_ID = NULL
	
		
		if @Flag = 0
			Begin
				Select (case when lc.Loan_Closing < 0 THEN 0 ELSE lc.Loan_Closing end) as Loan_Closing,lc.*,Loan_Name 
				from @Loan_Closing lc  Inner join dbo.T0040_Loan_Master lm WITH (NOLOCK) on lc.Loan_ID = Lm.Loan_ID
				where Floor(lc.Loan_Closing) > 0
			End
		Else if @Flag = 1	--Added by nilesh patel on 07092016 -- Start
			Begin
				if exists(SELECT 1 from T0100_Monthly_Loan_Skip_Approval WITH (NOLOCK) where Request_Apr_ID = @Request_ID AND Final_Approval = 1)
					Begin
						Select ROW_NUMBER()Over(ORDER BY lc.Loan_apr_ID) as row_id, (case when lc.Loan_Closing < 0 THEN 0 ELSE lc.Loan_Closing end) as Loan_Closing,lc.*,Loan_Name,Isnull(MLS.New_Install_Amount,0) as New_Install_Amt
						from @Loan_Closing lc  Inner join dbo.T0040_Loan_Master lm WITH (NOLOCK) on lc.Loan_ID = Lm.Loan_ID
						Inner JOIN T0100_Monthly_Loan_Skip_Approval MLS WITH (NOLOCK) On lc.Loan_ID = MLS.Loan_ID and MLS.Request_Apr_ID = @Request_ID
						where Floor(lc.Loan_Closing) > 0
					End
				Else if exists(SELECT 1 from T0100_Monthly_Loan_Skip_Approval WITH (NOLOCK) where Request_ID = @Request_ID AND Final_Approval = 0)
					Begin
						Select ROW_NUMBER()Over(ORDER BY lc.Loan_apr_ID) as row_id, (case when lc.Loan_Closing < 0 THEN 0 ELSE lc.Loan_Closing end) as Loan_Closing,lc.*,Loan_Name,Isnull(MLS.New_Install_Amount,0) as New_Install_Amt
						from @Loan_Closing lc  Inner join dbo.T0040_Loan_Master lm WITH (NOLOCK) on lc.Loan_ID = Lm.Loan_ID
						Inner JOIN T0100_Monthly_Loan_Skip_Approval MLS WITH (NOLOCK) On lc.Loan_ID = MLS.Loan_ID and MLS.Request_ID = @Request_ID
						where Floor(lc.Loan_Closing) > 0
					End
				Else if exists(SELECT 1 from T0100_Monthly_Loan_Skip_Application WITH (NOLOCK) where Request_ID = @Request_ID)
						Select ROW_NUMBER()Over(ORDER BY lc.Loan_apr_ID) as row_id, (case when lc.Loan_Closing < 0 THEN 0 ELSE lc.Loan_Closing end) as Loan_Closing,lc.*,Loan_Name,Isnull(MLS.New_Install_Amount,0) as New_Install_Amt
						from @Loan_Closing lc  Inner join dbo.T0040_Loan_Master lm WITH (NOLOCK) on lc.Loan_ID = Lm.Loan_ID
						Inner JOIN T0100_Monthly_Loan_Skip_Application MLS WITH (NOLOCK) On lc.Loan_ID = MLS.Loan_ID and MLS.Request_ID = Isnull(@Request_ID,0)
						where Floor(lc.Loan_Closing) > 0
				Else
					Begin
						Select ROW_NUMBER()Over(ORDER BY lc.Loan_apr_ID) as row_id, (case when lc.Loan_Closing < 0 THEN 0 ELSE lc.Loan_Closing end) as Loan_Closing,lc.*,Loan_Name,Isnull(MLS.New_Install_Amount,0) as New_Install_Amt
						from @Loan_Closing lc  Inner join dbo.T0040_Loan_Master lm WITH (NOLOCK) on lc.Loan_ID = Lm.Loan_ID
						Left OUTER JOIN T0100_Monthly_Loan_Skip_Application MLS WITH (NOLOCK) On lc.Loan_ID = MLS.Loan_ID and MLS.Request_ID = Isnull(@Request_ID,0)
						where Floor(lc.Loan_Closing) > 0
					End
			End
		Else
			Begin
				if exists(SELECT 1 from T0100_Monthly_Loan_Skip_Approval WITH (NOLOCK) where Request_ID = @Request_ID and Final_Approval = 0)
					Begin
						Select ROW_NUMBER()Over(ORDER BY lc.Loan_apr_ID) as row_id, (case when lc.Loan_Closing < 0 THEN 0 ELSE lc.Loan_Closing end) as Loan_Closing,lc.*,Loan_Name,Isnull(MLS.New_Install_Amount,0) as New_Install_Amt
						from @Loan_Closing lc  Inner join dbo.T0040_Loan_Master lm WITH (NOLOCK) on lc.Loan_ID = Lm.Loan_ID
						Inner JOIN T0100_Monthly_Loan_Skip_Approval MLS WITH (NOLOCK) On lc.Loan_ID = MLS.Loan_ID and MLS.Request_ID = @Request_ID
						Inner JOIN(
							Select MAX(Rpt_Level) as Rpt_Level From T0100_Monthly_Loan_Skip_Approval WITH (NOLOCK) where Request_ID = @Request_ID and Final_Approval = 0
						) as qry ON MLS.Rpt_Level = qry.Rpt_Level	
						where Floor(lc.Loan_Closing) > 0
					End
				Else if exists(SELECT 1 from T0100_Monthly_Loan_Skip_Application WITH (NOLOCK) where Request_ID = @Request_ID)
						Select ROW_NUMBER()Over(ORDER BY lc.Loan_apr_ID) as row_id, (case when lc.Loan_Closing < 0 THEN 0 ELSE lc.Loan_Closing end) as Loan_Closing,lc.*,Loan_Name,Isnull(MLS.New_Install_Amount,0) as New_Install_Amt
						from @Loan_Closing lc  Inner join dbo.T0040_Loan_Master lm WITH (NOLOCK) on lc.Loan_ID = Lm.Loan_ID
						Inner JOIN T0100_Monthly_Loan_Skip_Application MLS WITH (NOLOCK) On lc.Loan_ID = MLS.Loan_ID and MLS.Request_ID = Isnull(@Request_ID,0)
						where Floor(lc.Loan_Closing) > 0
				Else
					Begin
						Select ROW_NUMBER()Over(ORDER BY lc.Loan_apr_ID) as row_id, (case when lc.Loan_Closing < 0 THEN 0 ELSE lc.Loan_Closing end) as Loan_Closing,lc.*,Loan_Name,Isnull(MLS.New_Install_Amount,0) as New_Install_Amt
						from @Loan_Closing lc  Inner join dbo.T0040_Loan_Master lm WITH (NOLOCK) on lc.Loan_ID = Lm.Loan_ID
						Left OUTER JOIN T0100_Monthly_Loan_Skip_Application MLS WITH (NOLOCK) On lc.Loan_ID = MLS.Loan_ID and MLS.Request_ID = Isnull(@Request_ID,0)
						where Floor(lc.Loan_Closing) > 0
					End
			End
		
		--Added by nilesh patel on 07092016 -- End




