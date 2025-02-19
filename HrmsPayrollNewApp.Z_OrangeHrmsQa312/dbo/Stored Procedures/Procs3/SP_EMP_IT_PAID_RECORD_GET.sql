



---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_EMP_IT_PAID_RECORD_GET]
	 @Cmp_ID 		numeric
	,@From_Date		datetime
	,@To_Date 		datetime
	,@Branch_ID		numeric
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
	
	Declare @AD_ID numeric 	

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

		
		
		select top 1 @AD_ID =AD_ID From T0050_AD_MAster WITH (NOLOCK) Where AD_DEF_ID =1 and Cmp_ID=@Cmp_ID
		
		
		Select MAD.EMP_ID,EMP_CODE,EMP_FULL_NAME,BRANCH_NAME,PAN_NO,SUM(MAD.M_AD_AMOUNT)- isnull(max(E_IT_Paid_Amount),0) M_AD_AMOUNT 
							,0 Surcharge_Amount , 0 Education_Cess ,SUM(MAD.M_AD_AMOUNT) - isnull(max(E_IT_Paid_Amount),0) Total_Amount 
							,0 Total_Taxable_Amount ,max(E_IT_Paid_Amount)
		 From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) Inner join 
			  T0050_AD_MASTER ADM WITH (NOLOCK) ON MAD.AD_ID = ADM.AD_ID INNER JOIN 
		T0080_EMP_MASTER E WITH (NOLOCK) on MAD.emp_ID = E.emp_ID INNER  JOIN 
			@EMP_CONS EC ON E.EMP_ID = EC.EMP_ID inner join 
			( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date	 ) I_Q 
				on E.Emp_ID = I_Q.Emp_ID  inner join
					T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID   Left outer join 
					(Select d.Emp_ID,Sum(E_IT_Paid_Amount)E_IT_Paid_Amount From T0251_IT_PAID_Detail d WITH (NOLOCK) inner join @Emp_Cons ec1 on d.emp_Id =ec1.Emp_Id
								Inner join T0250_IT_PAid i WITH (NOLOCK) on d.IT_Paid_ID =i.IT_Paid_ID where 
								For_Date >=@From_Date and For_Date <=@To_Date group by D.emp_ID) q on mad.Emp_ID =q.emp_ID
		WHERE E.Cmp_ID = @Cmp_Id	 and For_date >=@From_Date and For_date <=@To_Date
				and  mad.AD_ID = @AD_ID
		GROUP BY MAD.EMP_ID,EMP_CODE,EMP_FULL_NAME,BRANCH_NAME,PAN_NO
						

	RETURN




