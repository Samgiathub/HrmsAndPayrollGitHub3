




--- DONT USE
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_EMP_PAYSLIP_GET]
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
	,@constraint 	varchar(5000)
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
			and I.Emp_ID in 
				( select Emp_Id from
				(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
				where cmp_ID = @Cmp_ID   and  
				(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
				or ( @To_Date  >= join_Date  and @To_Date <= left_date )
				or Left_date is null and @To_Date >= Join_Date)
				or @To_Date >= left_date  and  @From_Date <= left_date ) 
			
		end
		 
	 CREATE table #Pay_slip 
		(
			Row_ID					numeric IDENTITY ,
			Emp_ID					numeric,
			Cmp_ID					numeric,
			AD_ID					numeric,
			Sal_Tran_ID				numeric,
			AD_Description			varchar(100),
			AD_Amount				numeric(18,2),
			AD_Actual_Amount		numeric(18,2),
			AD_Calculated_Amount	numeric(18,2),
			For_Date				Datetime,
			M_AD_Flag				char(1),
			Loan_ID					numeric
		)	 

	
	Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
	select ms.Emp_ID,Cmp_ID,null,'Basic Salary',Sal_Tran_ID,Salary_amount,Basic_Salary,0,Month_end_Date ,'I'
		From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
		and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date
			
	Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
	Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,mad.sal_Tran_ID,mad.m_AD_Amount,mad.M_AD_Actual_Per_amount,mad.M_AD_Calculated_amount,mad.For_Date,mad.M_AD_Flag
		 From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN 
			@EMP_CONS EC ON MAD.EMP_ID = EC.EMP_ID 
		WHERE MAD.Cmp_ID = @Cmp_Id and For_date >=@From_Date and For_date <=@To_Date	 
			  and M_AD_NOT_EFFECT_SALARY = 0 and M_AD_Flag ='I'		

	Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
	select ms.Emp_ID,Cmp_ID,null,'Claim Amount',Sal_Tran_ID,Total_claim_Amount,null,Gross_Salary,Month_end_Date ,'I'
		From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
		and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date

	Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
	select  ms.Emp_ID,Cmp_ID,null,'OT Amount',Sal_Tran_ID,OT_Amount,null,Gross_Salary,Month_end_Date ,'I'
		From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
		and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date

	Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
	select  ms.Emp_ID,Cmp_ID,null,'Gross Salary',Sal_Tran_ID,Gross_Salary,null,Gross_Salary,Month_end_Date ,'I'
		From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
		and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date
		
	Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
	Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,mad.sal_Tran_ID,mad.m_AD_Amount,mad.M_AD_Actual_Per_amount,mad.M_AD_Calculated_amount,mad.For_Date,mad.M_AD_Flag
		 From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN 
			@EMP_CONS EC ON MAD.EMP_ID = EC.EMP_ID 
		WHERE MAD.Cmp_ID = @Cmp_Id and For_date >=@From_Date and For_date <=@To_Date	 
			  and M_AD_NOT_EFFECT_SALARY = 0 and M_AD_Flag ='D'
			  
	Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
	select ms.Emp_ID,Cmp_ID,null,'Advance Amount',Sal_Tran_ID,Advance_Amount,null,Gross_Salary,Month_end_Date ,'D'
		From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
		and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date
		

				
	Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,Loan_ID)
	Select ms.Emp_ID ,ms.Cmp_ID,null,Loan_Name,ms.Sal_Tran_ID,Loan_Pay_Amount,null,Gross_Salary,Month_end_Date ,'D',La.loan_ID  
	from T0200_Monthly_Salary ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID = ec.emp_ID inner join T0210_monthly_loan_payment  mlp on ms.sal_Tran_Id = mlp.Sal_Tran_Id 
	inner join T0120_loan_approval la WITH (NOLOCK) on mlp.loan_apr_ID = la.Loan_Apr_ID inner join 
	t0040_Loan_Master lm WITH (NOLOCK) on la.loan_Id = lm.loan_Id
	and Loan_payment_Date >=@From_Date and Loan_payment_Date <=@To_Date

	
	Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
		
	select ms.Emp_ID,Cmp_ID,null,'PT Amount',Sal_Tran_ID,PT_Amount,null,Gross_Salary,Month_end_Date ,'D'
		From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
		and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date
	

	Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
	select ms.Emp_ID,Cmp_ID,null,'LWF Amount',Sal_Tran_ID,LWF_Amount,null,Gross_Salary,Month_end_Date ,'D'
		From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
		and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date


	Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
	select ms.Emp_ID,Cmp_ID,null,'Revenue Amount',Sal_Tran_ID,Revenue_Amount,null,Gross_Salary,Month_end_Date ,'D'
		From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
		and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date


	Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
	select  ms.Emp_ID,Cmp_ID,null,'Total Deduction',Sal_Tran_ID,Total_Dedu_Amount,null,Gross_Salary,Month_end_Date ,'I'
		From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
		and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date


		Select Ms.Emp_ID,Ms.Month_St_Date,Sal_cal_Days,Present_Days,Absent_Days,Holiday_Days,Weekoff_Days,Working_Days,Outof_Days,Paid_Leave_Days,ms.Gross_Salary,Total_Dedu_amount,Net_Amount 
	 ,Emp_full_Name,Grd_Name,EMP_CODE,Type_Name,Dept_Name,Sin_NO,Pan_NO,Desig_Name,AD_Name,AD_LEVEL,
	Mad.AD_Description,mad.AD_Amount,Mad.AD_Calculated_Amount,M_AD_Flag
		 ,Row_ID 
		 From T0200_Monthly_Salary ms WITH (NOLOCK) inner join  #Pay_Slip  MAD on ms.sal_Tran_ID =mad.sal_Tran_Id  Left outer join 
			  T0050_AD_MASTER ADM WITH (NOLOCK) ON MAD.AD_ID = ADM.AD_ID INNER JOIN 
		      T0080_EMP_MASTER E WITH (NOLOCK) on MAD.emp_ID = E.emp_ID INNER  JOIN 
			@EMP_CONS EC ON E.EMP_ID = EC.EMP_ID inner join 
			 T0095_Increment I_Q WITH (NOLOCK) on ms.Increment_ID = I_Q.Increment_Id inner join
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join 
					T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  
					
		WHERE E.Cmp_ID = @Cmp_Id	 and For_date >=@From_Date and For_date <=@To_Date
			 and MAD.AD_Amount > 0 
		Order by mad.Emp_ID,Row_ID
			
			
	 
	RETURN 




