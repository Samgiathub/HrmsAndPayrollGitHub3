



---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_PAYSLIP_DETAIL_GET_Daily_Wages]
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
	,@constraint 	varchar(4000)
	,@Sal_Type		numeric = 0
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
			Loan_ID					numeric,
			Def_ID					numeric 
		)	 
	
  
	if @Sal_Type = 0
		begin
		    
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,Def_ID)
				select ms.Emp_ID,Cmp_ID,null,'Basic Salary',Sal_Tran_ID,Salary_amount,Basic_Salary,0,Month_end_Date ,'I',1
					From T0200_Monthly_Salary_Daily  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date
						
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,mad.sal_Tran_ID,mad.m_AD_Amount,mad.M_AD_Actual_Per_amount,mad.M_AD_Calculated_amount,mad.For_Date,mad.M_AD_Flag
					 From T0210_MONTHLY_AD_DETAIL_Daily  MAD WITH (NOLOCK) INNER  JOIN 
						@EMP_CONS EC ON MAD.EMP_ID = EC.EMP_ID 
					WHERE MAD.Cmp_ID = @Cmp_Id and For_date >=@From_Date and For_date <=@To_Date	 
						  and M_AD_NOT_EFFECT_SALARY = 0 and M_AD_Flag ='I'	 and isnull(Sal_Type,0) =0	

				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select ms.Emp_ID,Cmp_ID,null,'Claim Amount',Sal_Tran_ID,Total_claim_Amount,null,Gross_Salary,Month_end_Date ,'I'
					From T0200_Monthly_Salary_Daily  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date

			/*	Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'OT Amount',Sal_Tran_ID,OT_Amount,null,Gross_Salary,Month_end_Date ,'I'
					From T0200_Monthly_Salary_Daily  ms Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date*/

				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'Arrears',Sal_Tran_ID,Other_Allow_Amount,null,0,Month_end_Date ,'I'
					From T0200_Monthly_Salary_Daily  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Other_Allow_Amount,0) >0
					
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'Settlement Amount',Sal_Tran_ID,Settelement_Amount,null,0,Month_end_Date ,'I'
					From T0200_Monthly_Salary_Daily  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Settelement_Amount,0) >0
	

				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'Leave Encash Amount',Sal_Tran_ID,Leave_salary_Amount,null,0,Month_end_Date ,'I'
					From T0200_Monthly_Salary_Daily  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Leave_Salary_Amount,0) >0
					
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'Other Amount',Sal_Tran_ID,Other_Dedu_Amount,null,0,Month_end_Date ,'D'
					From T0200_Monthly_Salary_Daily  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Other_Dedu_Amount,0) >0	
					
				--commented by Falak on 29-OCT-2010 as per told by nilay
				/*Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'TDS Amount',Sal_Tran_ID,M_IT_Tax,null,0,Month_end_Date ,'D'
					From T0200_Monthly_Salary_Daily  ms Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(M_IT_Tax,0) >0	*/
					
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'Bonus',Sal_Tran_ID,Bonus_Amount,null,0,Month_end_Date ,'I'
					From T0200_Monthly_Salary_Daily  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Bonus_Amount,0) >0		

			/*	Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'Gross Salary',Sal_Tran_ID,Gross_Salary,null,Gross_Salary,Month_end_Date ,'I'
					From T0200_Monthly_Salary_Daily  ms Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date
			*/		
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,mad.sal_Tran_ID,mad.m_AD_Amount,mad.M_AD_Actual_Per_amount,mad.M_AD_Calculated_amount,mad.For_Date,mad.M_AD_Flag
					 From T0210_MONTHLY_AD_DETAIL_Daily  MAD WITH (NOLOCK) INNER  JOIN 
						@EMP_CONS EC ON MAD.EMP_ID = EC.EMP_ID 
					WHERE MAD.Cmp_ID = @Cmp_Id and For_date >=@From_Date and For_date <=@To_Date	 
						  and M_AD_NOT_EFFECT_SALARY = 0 and M_AD_Flag ='D' and isnull(Sal_Type,0) =0
						  
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select ms.Emp_ID,Cmp_ID,null,'Advance Amount',Sal_Tran_ID,Advance_Amount,null,Gross_Salary,Month_end_Date ,'D'
					From T0200_Monthly_Salary_Daily  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date
					

							
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,Loan_ID)
				Select ms.Emp_ID ,ms.Cmp_ID,null,Loan_Name,ms.Sal_Tran_ID,Loan_Pay_Amount,null,Gross_Salary,Month_end_Date ,'D',La.loan_ID  
				from T0200_Monthly_Salary_Daily ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID = ec.emp_ID inner join T0210_monthly_loan_payment  mlp WITH (NOLOCK) on ms.sal_Tran_Id = mlp.Sal_Tran_Id 
				inner join T0120_loan_approval la WITH (NOLOCK) on mlp.loan_apr_ID = la.Loan_Apr_ID inner join 
				t0040_Loan_Master lm WITH (NOLOCK) on la.loan_Id = lm.loan_Id
				and Loan_payment_Date >=@From_Date and Loan_payment_Date <=@To_Date

				
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
					
				select ms.Emp_ID,Cmp_ID,null,'PT Amount',Sal_Tran_ID,PT_Amount,null,Gross_Salary,Month_end_Date ,'D'
					From T0200_Monthly_Salary_Daily  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date
				

				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select ms.Emp_ID,Cmp_ID,null,'LWF Amount',Sal_Tran_ID,LWF_Amount,null,Gross_Salary,Month_end_Date ,'D'
					From T0200_Monthly_Salary_Daily  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date


				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select ms.Emp_ID,Cmp_ID,null,'Revenue Amount',Sal_Tran_ID,Revenue_Amount,null,Gross_Salary,Month_end_Date ,'D'
					From T0200_Monthly_Salary_Daily  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date 

			/*
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'Total Deduction',Sal_Tran_ID,Total_Dedu_Amount,null,Gross_Salary,Month_end_Date ,'I'
					From T0200_Monthly_Salary_Daily  ms Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date
			*/
		end
	else if @Sal_Type = 1
		begin
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select ms.Emp_ID,Cmp_ID,null,'Basic Salary',null,S_Salary_amount,S_Basic_Salary,0,S_Month_end_Date ,'I'
					From T0201_Monthly_Salary_Sett  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					and S_Month_St_DAte >=@From_Date and S_Month_end_Date <=@To_Date
						
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,null,sum(mad.m_AD_Amount),sum(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),max(mad.For_Date),mad.M_AD_Flag
					 From T0210_MONTHLY_AD_DETAIL_Daily  MAD WITH (NOLOCK) INNER  JOIN 
						@EMP_CONS EC ON MAD.EMP_ID = EC.EMP_ID 
					WHERE MAD.Cmp_ID = @Cmp_Id and For_date >=@From_Date and For_date <=@To_Date	 
						  and M_AD_NOT_EFFECT_SALARY = 0 and isnull(Sal_Type,0) in (1,2) and M_Ad_Percentage =0
					Group by mad.emp_ID,mad.cmp_Id,mad.AD_ID ,mad.For_Date ,mad.M_AD_Flag

				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,null,sum(mad.m_AD_Amount),max(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),max(mad.For_Date),mad.M_AD_Flag
					 From T0210_MONTHLY_AD_DETAIL_Daily  MAD WITH (NOLOCK) INNER  JOIN 
						@EMP_CONS EC ON MAD.EMP_ID = EC.EMP_ID 
					WHERE MAD.Cmp_ID = @Cmp_Id and For_date >=@From_Date and For_date <=@To_Date	 
						  and M_AD_NOT_EFFECT_SALARY = 0 and isnull(Sal_Type,0) in (1,2)and M_Ad_Percentage >0	
					Group by mad.emp_ID,mad.cmp_Id,mad.AD_ID ,mad.For_Date ,mad.M_AD_Flag

				
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
					
				select ms.Emp_ID,Cmp_ID,null,'PT Amount',null,S_PT_Amount,null,S_Gross_Salary,S_Month_end_Date ,'D'
					From T0201_Monthly_Salary_Sett  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					and S_Month_St_DAte >=@From_Date and S_Month_end_Date <=@To_Date
				

				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select ms.Emp_ID,Cmp_ID,null,'LWF Amount',null,S_LWF_Amount,null,S_Gross_Salary,S_Month_end_Date ,'D'
					From T0201_Monthly_Salary_Sett  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					and S_Month_St_DAte >=@From_Date and S_Month_end_Date <=@To_Date


				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select ms.Emp_ID,Cmp_ID,null,'Revenue Amount',null,S_Revenue_Amount,null,S_Gross_Salary,S_Month_end_Date ,'D'
					From T0201_Monthly_Salary_Sett  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					and S_Month_St_DAte >=@From_Date and S_Month_end_Date <=@To_Date	
					
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'Other Amount',Sal_Tran_ID,Other_Dedu_Amount,null,0,Month_end_Date ,'D'
					From T0200_Monthly_Salary_Daily  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Other_Dedu_Amount,0) >0	
					
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'TDS Amount',Sal_Tran_ID,M_IT_Tax,null,0,Month_end_Date ,'D'
					From T0200_Monthly_Salary_Daily  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(M_IT_Tax,0) >0
					
					Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'Bonus',Sal_Tran_ID,Bonus_Amount,null,0,Month_end_Date ,'I'
					From T0200_Monthly_Salary_Daily  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Bonus_Amount,0) >0	
		
					
		end
	else if @Sal_Type = 2
		begin
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select ms.Emp_ID,Cmp_ID,null,'Basic Salary',null,L_Salary_amount,L_Basic_Salary,0,L_Month_end_Date ,'I'
					From T0200_Monthly_Salary_Daily_Leave  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					and L_Month_St_DAte >=@From_Date and L_Month_end_Date <=@To_Date
						
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,null,sum(mad.m_AD_Amount),sum(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),max(mad.For_Date),mad.M_AD_Flag
					 From T0210_MONTHLY_AD_DETAIL_Daily  MAD WITH (NOLOCK) INNER  JOIN 
						@EMP_CONS EC ON MAD.EMP_ID = EC.EMP_ID 
					WHERE MAD.Cmp_ID = @Cmp_Id and For_date >=@From_Date and For_date <=@To_Date	 
						  and M_AD_NOT_EFFECT_SALARY = 0 and isnull(Sal_Type,0) = 3 and M_Ad_Percentage =0
					Group by mad.emp_ID,mad.cmp_Id,mad.AD_ID ,mad.For_Date ,mad.M_AD_Flag

				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,null,sum(mad.m_AD_Amount),max(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),max(mad.For_Date),mad.M_AD_Flag
					 From T0210_MONTHLY_AD_DETAIL_Daily  MAD WITH (NOLOCK) INNER  JOIN 
						@EMP_CONS EC ON MAD.EMP_ID = EC.EMP_ID 
					WHERE MAD.Cmp_ID = @Cmp_Id and For_date >=@From_Date and For_date <=@To_Date	 
						  and M_AD_NOT_EFFECT_SALARY = 0 and isnull(Sal_Type,0) = 3 and M_Ad_Percentage >0	
					Group by mad.emp_ID,mad.cmp_Id,mad.AD_ID ,mad.For_Date ,mad.M_AD_Flag
					
	
		end	
	else 
		begin
		
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,Def_ID)
				select Emp_ID,@Cmp_ID,null,'Basic Salary',null,0,0,0,@To_Date,'I',1 From @Emp_Cons ec 
						
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,null,sum(mad.m_AD_Amount),sum(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),max(mad.For_Date),mad.M_AD_Flag
					 From T0210_MONTHLY_AD_DETAIL_Daily  MAD WITH (NOLOCK) INNER  JOIN 
						@EMP_CONS EC ON MAD.EMP_ID = EC.EMP_ID 
					WHERE MAD.Cmp_ID = @Cmp_Id and For_date >=@From_Date and For_date <=@To_Date	 
						  and M_AD_NOT_EFFECT_SALARY = 0  and M_Ad_Percentage =0
					Group by mad.emp_ID,mad.cmp_Id,mad.AD_ID ,mad.For_Date ,mad.M_AD_Flag

				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,null,sum(mad.m_AD_Amount),max(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),max(mad.For_Date),mad.M_AD_Flag
					 From T0210_MONTHLY_AD_DETAIL_Daily  MAD WITH (NOLOCK) INNER  JOIN 
						@EMP_CONS EC ON MAD.EMP_ID = EC.EMP_ID 
					WHERE MAD.Cmp_ID = @Cmp_Id and For_date >=@From_Date and For_date <=@To_Date	 
						  and M_AD_NOT_EFFECT_SALARY = 0 and M_Ad_Percentage >0	
					Group by mad.emp_ID,mad.cmp_Id,mad.AD_ID ,mad.For_Date ,mad.M_AD_Flag


				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'OT Amount',Sal_Tran_ID,OT_Amount,null,Gross_Salary,Month_end_Date ,'I'
					From T0200_Monthly_Salary_Daily  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date

				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'Arrears',Sal_Tran_ID,Other_Allow_Amount,null,0,Month_end_Date ,'I'
					From T0200_Monthly_Salary_Daily  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Other_Allow_Amount,0) >0
					
					

				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'Settlement Amount',Sal_Tran_ID,Settelement_Amount,null,0,Month_end_Date ,'I'
					From T0200_Monthly_Salary_Daily  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Settelement_Amount,0) >0

				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'Leave Encash Amount',Sal_Tran_ID,Leave_salary_Amount,null,0,Month_end_Date ,'I'
					From T0200_Monthly_Salary_Daily  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Leave_Salary_Amount,0) >0



				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select ms.Emp_ID,Cmp_ID,null,'Advance Amount',Sal_Tran_ID,Advance_Amount,null,Gross_Salary,Month_end_Date ,'D'
					From T0200_Monthly_Salary_Daily  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date
					
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,Loan_ID)
				Select ms.Emp_ID ,ms.Cmp_ID,null,Loan_Name,ms.Sal_Tran_ID,Loan_Pay_Amount,null,Gross_Salary,Month_end_Date ,'D',La.loan_ID  
				from T0200_Monthly_Salary_Daily ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID = ec.emp_ID inner join T0210_monthly_loan_payment  mlp WITH (NOLOCK) on ms.sal_Tran_Id = mlp.Sal_Tran_Id 
				inner join T0120_loan_approval la WITH (NOLOCK) on mlp.loan_apr_ID = la.Loan_Apr_ID inner join 
				t0040_Loan_Master lm WITH (NOLOCK) on la.loan_Id = lm.loan_Id
				and Loan_payment_Date >=@From_Date and Loan_payment_Date <=@To_Date
				
				
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,Def_ID)
					select Emp_ID,@Cmp_ID,null,'PT Amount',null,0,null,0,@To_Date,'D',2 From @Emp_Cons 
					
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'Other Amount',Sal_Tran_ID,Other_Dedu_Amount,null,0,Month_end_Date ,'D'
					From T0200_Monthly_Salary_Daily  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Other_Dedu_Amount,0) >0	
					
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'TDS Amount',Sal_Tran_ID,M_IT_Tax,null,0,Month_end_Date ,'D'
					From T0200_Monthly_Salary_Daily  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(M_IT_Tax,0) >0	
					
					Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'Bonus',Sal_Tran_ID,Bonus_Amount,null,0,Month_end_Date ,'I'
					From T0200_Monthly_Salary_Daily  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Bonus_Amount,0) >0
	


				Update #Pay_slip
				set AD_Amount = Salary_amount , 
					AD_ACtual_Amount = Basic_Salary 
				From #Pay_slip P inner join T0200_Monthly_Salary_Daily  ms on p.emp_ID =ms.emp_ID and 
					Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date
				Where Def_ID = 1


				Update #Pay_slip
				set AD_Amount = isnull(AD_Amount,0) + S_Salary_Amount, 
					AD_ACtual_Amount = S_Basic_Salary 
				From #Pay_slip P inner join T0201_Monthly_Salary_Sett  ms on p.emp_ID =ms.emp_ID and 
					S_Month_St_DAte >=@From_Date and S_Month_end_Date <=@To_Date
				Where Def_ID = 1
								

				Update #Pay_slip
				set AD_Amount = isnull(AD_Amount,0) + L_Salary_Amount, 
					AD_ACtual_Amount = L_Basic_Salary 
				From #Pay_slip P inner join T0200_Monthly_Salary_Daily_Leave  ms on p.emp_ID =ms.emp_ID and 
					L_Month_St_DAte >=@From_Date and L_Month_end_Date <=@To_Date
				Where Def_ID = 1


				
				Update #Pay_slip
				set AD_Amount = PT_Amount , 
					AD_Calculated_Amount = PT_Calculated_Amount 
				From #Pay_slip P inner join T0200_Monthly_Salary_Daily  ms on p.emp_ID =ms.emp_ID and 
					Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date
				Where Def_ID = 2
					

				Update #Pay_slip
				set AD_Amount =isnull(AD_Amount,0) +  S_PT_Amount , 
					AD_Calculated_Amount = S_PT_Calculated_Amount 
				From #Pay_slip P inner join T0201_Monthly_Salary_Sett  ms on p.emp_ID =ms.emp_ID and 
					S_Month_St_DAte >=@From_Date and S_Month_end_Date <=@To_Date
				Where Def_ID = 2


				
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,Def_ID)
				select Emp_ID,@Cmp_ID,null,'LWF Amount',null,0,null,0,@To_DAte,'D' ,3 From @Emp_Cons 

				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,Def_ID)
				select Emp_ID,@Cmp_ID,null,'Revenue Amount',null,0,null,0,@To_DAte,'D' ,4 From @Emp_Cons 
				
		
		end
		
		--select * from #Pay_Slip
		Select MAD.*,AD_NAME,AD_SORT_NAME From #Pay_Slip  MAD  left outer  join T0050_AD_MASTER AM WITH (NOLOCK) ON MAD.AD_ID= AM.AD_ID 
		WHERE mad.Cmp_ID = @Cmp_Id	 and For_date >=@From_Date and For_date <=@To_Date
			and MAD.AD_Amount > 0 or MAD.AD_Amount < 0 
		Order by mad.Emp_ID,Row_ID 
			
			
	 
	RETURN 




