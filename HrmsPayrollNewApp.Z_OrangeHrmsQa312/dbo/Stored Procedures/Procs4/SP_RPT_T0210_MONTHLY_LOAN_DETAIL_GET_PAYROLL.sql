



---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_T0210_MONTHLY_LOAN_DETAIL_GET_PAYROLL]
 @Cmp_ID 		numeric
,@From_Date 	datetime
,@To_Date 		datetime
,@Branch_ID 	numeric
,@Cat_ID 		numeric 
,@Grd_ID 		numeric
,@Type_ID 		numeric
,@Dept_ID 		numeric
,@Desig_ID 		numeric
,@Emp_ID 		numeric
,@constraint 	varchar(max)
,@Sal_Type		numeric = 0
,@Loan_ID       numeric = 0
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
			 /* and I.Emp_ID in   
				( select Emp_Id from  
				(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry  
				where cmp_ID = @Cmp_ID   and    
				(( @From_Date  >= join_Date  and  @From_Date <= left_date )   
				or ( @To_Date  >= join_Date  and @To_Date <= left_date )  
				or Left_date is null and @To_Date >= Join_Date)  
				or @To_Date >= left_date  and  @From_Date <= left_date )   
     
  */      							
		end	

	 
	Select MLD.*,LA.Loan_Apr_Date,LA.Loan_Apr_No_of_Installment,LA.Loan_Apr_Installment_Amount,LA.Loan_Apr_Installment_Amount,E.Emp_Id,Emp_full_Name,Branch_Address,Comp_name,Grd_Name,EMP_CODE,Type_Name,Dept_Name,Desig_Name,LOAN_NAME,Cmp_Name,Branch_Name
			,Loan_apr_amount,Loan_Apr_pending_amount
		 From dbo.T0210_MONTHLY_LOAN_PAYMENT MLD WITH (NOLOCK) Inner join 
			  dbo.T0120_LOAN_APPROVAL LA WITH (NOLOCK) ON MLD.LOAN_APR_ID = LA.LOAN_APR_ID INNER JOIN 
			  dbo.T0040_LOAN_MASTER LM WITH (NOLOCK) ON LA.LOAN_ID = LM.LOAN_ID  INNER JOIN  dbo.T0080_EMP_MASTER E WITH (NOLOCK) on LA.emp_ID = E.emp_ID  Left outer  JOIN 
			@EMP_CONS EC ON E.EMP_ID = EC.EMP_ID inner join 
			( select I.Emp_Id , Grd_ID,Cmp_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date from dbo.T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_Id) as Increment_Id , Emp_ID from dbo.T0095_Increment WITH (NOLOCK) --Changed by Hardik 09/09/2014 for Same Date Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id	 ) I_Q  --Changed by Hardik 09/09/2014 for Same Date Increment
				on E.Emp_ID = I_Q.Emp_ID  inner join
					dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					dbo.T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join 
					dbo.T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  Inner JOin
					dbo.T0010_Company_Master CM WITH (NOLOCK) on I_Q.Cmp_ID = CM.Cmp_ID  					
		WHERE E.Cmp_ID = @Cmp_Id and Loan_payment_Date >=@From_Date and Loan_payment_Date <=@To_Date
				And not Sal_Tran_ID is null and LA.Loan_ID=@Loan_ID
					
					
	RETURN 




