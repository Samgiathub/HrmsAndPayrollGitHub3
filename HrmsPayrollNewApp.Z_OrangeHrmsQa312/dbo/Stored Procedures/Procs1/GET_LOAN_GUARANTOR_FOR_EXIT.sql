

-- =============================================
-- Author:		<Jaina>
-- Create date: <05-12-2016>
-- Description:	<Get Gaurantor Detail For Exit Application>
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[GET_LOAN_GUARANTOR_FOR_EXIT]
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
		Set @Grd_ID = null
	if @Emp_ID = 0
		Set @Emp_ID = null
	If @Desig_ID = 0
		Set @Desig_ID = null
	
	DECLARE @End_Date As Datetime
	
	SET @End_Date = DATEADD(YYYY,-1,@To_Date)
	
	Declare @loan_closing table
		(
			Cmp_id			numeric,
			emp_id			Numeric,
			Loan_apr_ID		Numeric,
			Loan_ID			Numeric,
			Loan_Issue		numeric,
			Loan_Return		numeric,
			Loan_Closing	numeric,
			For_Date		Datetime,
			Loan_Status		Varchar(20),
			Emp_Full_Name   varchar(max),
			Guarantor      varchar(50)
		)
	
	CREATE table #Emp_Cons 
	(      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric    
	)  

	exec SP_RPT_FILL_EMP_CONS @Cmp_ID=@Cmp_ID, @From_Date=@To_Date, @To_Date=@To_Date, @Branch_ID=@Branch_ID, @Cat_ID=@Cat_ID, @Grd_ID=@Grd_ID, @Type_ID= @Type_ID, @Dept_ID=@Dept_ID, @Desig_ID=@Desig_ID, @Emp_ID=@Emp_ID, @constraint=@Constraint
	
		Insert into @Loan_closing (Cmp_ID ,Emp_Id,Loan_Id,Loan_Apr_Id,Loan_Issue,For_Date,Loan_Return,Loan_Closing,Emp_Full_Name,Guarantor)
		select L.Cmp_ID , L.Emp_ID ,Loan_Id ,Loan_Apr_ID , Loan_Apr_Amount , @To_Date ,0 ,0 ,
				EM.Alpha_Emp_Code + '-' + EM.Emp_Full_Name As Emp_Full_Name,
				CASE WHEN Guarantor_Emp_ID = @Emp_ID THEN 'First' ELSE 'Second' END As Guarantor
				From dbo.T0120_Loan_Approval L WITH (NOLOCK)
				inner JOIN #Emp_Cons E ON E.Emp_ID = L.Emp_ID 
				inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = E.Emp_ID
			where L.Cmp_ID = @Cmp_ID --and Emp_ID in (Select Emp_ID From #Emp_Cons )
				--and Loan_Apr_Pending_Amount >0
				
		
		
		Update @Loan_Closing 
		set Loan_Return = mlp.Loan_Pay_Amount
		From @Loan_Closing  Lc  inner join 
		(Select Loan_apr_ID , Sum(Loan_pay_amount) Loan_Pay_Amount  From 
			dbo.T0210_MONTHLY_LOAN_PAYMENT  WITH (NOLOCK) where Cmp_ID = @Cmp_ID  Group by Loan_Apr_ID ) mlp on lc.loan_apr_ID = Mlp.Loan_apr_ID 	
		
		
		
		Update @Loan_Closing 
		set Loan_closing = Q1.Loan_closing
		From @Loan_Closing lc Inner join 
		(Select lt.Emp_ID ,Lt.Loan_ID, Sum(Loan_Closing) Loan_Closing from dbo.T0140_loan_transaction LT WITH (NOLOCK) inner join 
		(Select Emp_ID , Loan_ID , max(for_Date) for_Date  from T0140_loan_transaction WITH (NOLOCK)
			Where For_Date <=for_date group by emp_ID  , Loan_ID ) Q on Lt.Emp_ID = Q.Emp_ID and lt.Loan_ID = Q.Loan_ID 
		and Lt.For_Date = Q.For_Date Group by lt.Emp_ID ,lt.Loan_ID) Q1 on lc.Loan_ID = q1.Loan_ID
		and Lc.Emp_ID = Q1.Emp_ID
		
		Update @Loan_Closing 
		set Loan_Status = Q1.Loan_Apr_Status
		From @Loan_Closing lc Inner join 
		(Select lt.Emp_ID ,Lt.Loan_ID, Loan_Apr_Status from dbo.T0120_LOAN_APPROVAL LT WITH (NOLOCK) inner join 
			(Select Emp_ID , Loan_ID , max(for_Date) for_Date  from T0140_loan_transaction WITH (NOLOCK)
				Where For_Date <=for_date group by emp_ID  , Loan_ID ) Q on Lt.Emp_ID = Q.Emp_ID and lt.Loan_ID = Q.Loan_ID 
			and Lt.Loan_Apr_Date = Q.For_Date Group by lt.Emp_ID ,lt.Loan_ID,lt.Loan_Apr_Status
			) Q1 on lc.Loan_ID = q1.Loan_ID
		and Lc.Emp_ID = Q1.Emp_ID
		Where lc.emp_id = @Emp_ID

		Select lc.*,Loan_Name from @Loan_Closing lc  Inner join dbo.T0040_Loan_Master lm WITH (NOLOCK) on lc.Loan_ID = Lm.Loan_ID


