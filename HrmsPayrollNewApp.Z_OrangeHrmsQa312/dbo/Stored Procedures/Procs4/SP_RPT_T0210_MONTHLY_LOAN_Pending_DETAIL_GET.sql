
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_T0210_MONTHLY_LOAN_Pending_DETAIL_GET]
 @Cmp_ID 		numeric
,@From_Date 	datetime
,@To_Date 		datetime
--,@Branch_ID 	numeric
--,@Cat_ID 		numeric 
--,@Grd_ID 		numeric
--,@Type_ID 		numeric
--,@Dept_ID 		numeric
--,@Desig_ID 		numeric
,@Branch_ID 	varchar(max)
,@Cat_ID 		varchar(max)
,@Grd_ID 		varchar(max)
,@Type_ID 		varchar(max)
,@Dept_ID 		varchar(max)
,@Desig_ID 		varchar(max)
,@Emp_ID 		numeric
,@constraint 	varchar(MAX)
,@Sal_Type		numeric = 0
,@Loan_Id       numeric=0
,@Salary_Cycle_id numeric = 0
,@Segment_Id  varchar(max) = ''
,@Vertical_Id varchar(max) = ''
,@SubVertical_Id varchar(max) = ''
,@SubBranch_Id varchar(max) = ''
--,@Segment_Id  numeric = 0		 -- Added By Gadriwala Muslim 24072013
--,@Vertical_Id numeric = 0		 -- Added By Gadriwala Muslim 24072013
--,@SubVertical_Id numeric = 0	 -- Added By Gadriwala Muslim 24072013
,@Is_EmpCount numeric = 0	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	/* 
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
		set @Emp_ID = null */
		
	If @Loan_Id =0 
		Set @Loan_Id= NULL	
 /*		
if @Segment_Id = 0 
  set @Segment_Id = null
  IF @Vertical_Id= 0 
  set @Vertical_Id = null
  if @SubVertical_Id = 0 
  set @SubVertical_Id= Null */

	CREATE TABLE #Emp_Cons	-- Ankit 10092014 for Same Date Increment
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )   
	 -- Comment by nilesh on 07102014 
	 --EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,@Sal_Type ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id, 0 
	-- Added by nilesh patel on 07102014
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,@Salary_Cycle_id,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_Id,0,0,0,'0',0,0

	--Declare #Emp_Cons Table
	--(
	--	Emp_ID	numeric
	--)
	
	--if @Constraint <> ''
	--	begin
	--		Insert Into #Emp_Cons
	--		select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
	--	end
	--else
	--	begin
	--		Insert Into #Emp_Cons

	--		select I.Emp_Id from dbo.T0095_Increment I inner join 
	--				( select max(Increment_effective_Date) as For_Date , Emp_ID from dbo.T0095_Increment
	--				where Increment_Effective_date <= @To_Date
	--				and Cmp_ID = @Cmp_ID
	--				group by emp_ID  ) Qry on
	--				I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date								
	--		Where Cmp_ID = @Cmp_ID 
	--		and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
	--		and Branch_ID = isnull(@Branch_ID ,Branch_ID)
	--		and Grd_ID = isnull(@Grd_ID ,Grd_ID)
	--		and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
	--		and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
	--		and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
	--		and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))	 -- Added By Gadriwala Muslim 24072013
	--		and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 -- Added By Gadriwala Muslim 24072013
	--		and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) -- Added By Gadriwala Muslim 24072013
 
	--		and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
	--		 /* and I.Emp_ID in   
	--			( select Emp_Id from  
	--			(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry  
	--			where cmp_ID = @Cmp_ID   and    
	--			(( @From_Date  >= join_Date  and  @From_Date <= left_date )   
	--			or ( @To_Date  >= join_Date  and @To_Date <= left_date )  
	--			or Left_date is null and @To_Date >= Join_Date)  
	--			or @To_Date >= left_date  and  @From_Date <= left_date )   
     
 -- */      							
	--	end	
		if @Is_EmpCount = 1
		begin 
		
		select distinct LQry.emp_id,
		 --lqry.loan_apr_id,LQry.loan_id,
		 E.alpha_Emp_code ,e.Emp_full_Name,I_Q.Branch_ID
		 ,E.Vertical_ID,E.SubVertical_ID,E.Dept_ID  --Added By Jaina 7-10-2015
			
			from 
				(
					select SUM(Loan_Pay_Amount) as loan_pay_amount,Emp_ID,T0120_LOAN_APPROVAL.Loan_Apr_ID,T0120_LOAN_APPROVAL.Loan_ID,Loan_Apr_Date as for_date,T0120_LOAN_APPROVAL.Loan_Apr_Amount as Loan_amount ,T0120_LOAN_APPROVAL.Loan_Apr_Installment_Amount,
						(T0120_LOAN_APPROVAL.Loan_Apr_Amount-SUM(ISNULL(Loan_Pay_Amount,0)) - SUM(ISNULL(T0210_MONTHLY_LOAN_PAYMENT.Subsidy_Amount,0)) ) as Loan_Closing
						from T0120_LOAN_APPROVAL WITH (NOLOCK)
						left join T0210_MONTHLY_LOAN_PAYMENT  WITH (NOLOCK) on 
						T0210_MONTHLY_LOAN_PAYMENT.Loan_Apr_ID=T0120_LOAN_APPROVAL.Loan_Apr_ID
						
						where @To_Date >= ISNULL(T0210_MONTHLY_LOAN_PAYMENT.Loan_Payment_Date, @To_Date) and -- Uncommented by Rajput 12072017 - (Guide by Nimesh bhai) Due to Pending Loan Detail in Customized Report Wrong Generate(Mentis Error ID - 0006372 )  
							T0120_LOAN_APPROVAL.Loan_Apr_Date <=@To_Date
						group by Emp_ID,T0120_LOAN_APPROVAL.Loan_Apr_ID,T0120_LOAN_APPROVAL.Loan_ID,T0120_LOAN_APPROVAL.Loan_Apr_Amount,Loan_Apr_Date , T0120_LOAN_APPROVAL.Loan_Apr_Installment_Amount
												) LQry inner join
												 dbo.T0040_LOAN_MASTER LM WITH (NOLOCK) ON LQry.LOAN_ID = LM.LOAN_ID  INNER JOIN  dbo.T0080_EMP_MASTER E WITH (NOLOCK) on LQry.emp_ID = E.emp_ID  Left outer  JOIN 
			#Emp_Cons EC ON E.EMP_ID = EC.EMP_ID inner join 
			(select I.Emp_Id , Grd_ID,Cmp_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date from dbo.T0095_Increment I WITH (NOLOCK) inner join 
					(select max(Increment_Id) as Increment_Id, Emp_ID from dbo.T0095_Increment WITH (NOLOCK) --Changed by Hardik 09/09/2014 for Same Date Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID) Qry on
					I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id) I_Q  --Changed by Hardik 09/09/2014 for Same Date Increment
				on E.Emp_ID = I_Q.Emp_ID  inner join
					dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					dbo.T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join 
					dbo.T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  Inner JOin
					dbo.T0010_Company_Master CM WITH (NOLOCK) on I_Q.Cmp_ID = CM.Cmp_ID inner join 
					#Emp_Cons ECM on ECM.emp_id = LQry.emp_id
					
					WHERE E.Cmp_ID = @Cmp_Id 
				and LQry.for_date <=@To_Date
				And Isnull(LM.Loan_Id,0) = isnull(@Loan_Id ,Isnull(LM.Loan_Id,0))
				and LQry.loan_closing > 0
		
		
		end
		else
		begin
		
		 select LQry.emp_id,
		 --lqry.loan_apr_id,LQry.loan_id,
		 E.alpha_Emp_code as Alpha_Emp_code ,e.Emp_full_Name,Cmp_name,Cmp_Address,GM.Grd_Name,ETM.Type_Name,DM.Dept_Name,DGM.Desig_Name,Branch_Name,LM.LOAN_NAME,replace(convert(NVARCHAR, Lqry.For_date, 103), ' ', '/') as Loan_Approval_Date,Lqry.loan_Amount,LQry.Loan_Apr_Installment_Amount as EMI  ,LQry.Loan_Pay_Amount as Loan_Paid_Amount,LQry.Loan_Closing as Loan_Pending_Amount
		 ,BM.Branch_ID
			
			from 
				(
					select SUM(Loan_Pay_Amount) as loan_pay_amount,Emp_ID,T0120_LOAN_APPROVAL.Loan_Apr_ID,T0120_LOAN_APPROVAL.Loan_ID,Loan_Apr_Date as for_date,T0120_LOAN_APPROVAL.Loan_Apr_Amount as Loan_amount ,T0120_LOAN_APPROVAL.Loan_Apr_Installment_Amount,
						(T0120_LOAN_APPROVAL.Loan_Apr_Amount-SUM(ISNULL(Loan_Pay_Amount,0))) as Loan_Closing
						from T0120_LOAN_APPROVAL WITH (NOLOCK)
						left join T0210_MONTHLY_LOAN_PAYMENT WITH (NOLOCK)  on 
						T0210_MONTHLY_LOAN_PAYMENT.Loan_Apr_ID=T0120_LOAN_APPROVAL.Loan_Apr_ID
						
						where Isnull(T0210_MONTHLY_LOAN_PAYMENT.Loan_Payment_Date,@To_Date) <= @To_Date and -- Uncommented by Rajput 12072017 - (Guide by Nimesh bhai) Due to Pending Loan Detail in Customized Report Wrong Generate(Mentis Error ID - 0006372 )    
							T0120_LOAN_APPROVAL.Loan_Apr_Date <=@To_Date
						group by Emp_ID,T0120_LOAN_APPROVAL.Loan_Apr_ID,T0120_LOAN_APPROVAL.Loan_ID,T0120_LOAN_APPROVAL.Loan_Apr_Amount,Loan_Apr_Date , T0120_LOAN_APPROVAL.Loan_Apr_Installment_Amount
												) LQry inner join
												 dbo.T0040_LOAN_MASTER LM WITH (NOLOCK) ON LQry.LOAN_ID = LM.LOAN_ID  INNER JOIN  dbo.T0080_EMP_MASTER E WITH (NOLOCK) on LQry.emp_ID = E.emp_ID  Left outer  JOIN 
			#Emp_Cons EC ON E.EMP_ID = EC.EMP_ID inner join 
			(select I.Emp_Id , Grd_ID,Cmp_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date from dbo.T0095_Increment I WITH (NOLOCK) inner join 
					(select max(Increment_Id) as Increment_Id , Emp_ID from dbo.T0095_Increment WITH (NOLOCK) --Changed by Hardik 09/09/2014 for Same Date Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID) Qry on
					I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id) I_Q  --Changed by Hardik 09/09/2014 for Same Date Increment
				on E.Emp_ID = I_Q.Emp_ID  inner join
					dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					dbo.T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join 
					dbo.T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  Inner JOin
					dbo.T0010_Company_Master CM WITH (NOLOCK) on I_Q.Cmp_ID = CM.Cmp_ID inner join
					#Emp_Cons ECM on ECM.emp_id = LQry.emp_id
					
					WHERE E.Cmp_ID = @Cmp_Id 
				and LQry.for_date <=@To_Date
				And Isnull(LM.Loan_Id,0) = isnull(@Loan_Id ,Isnull(LM.Loan_Id,0))
				and LQry.loan_closing > 0
				
			end											
RETURN 
