
CREATE PROCEDURE [dbo].[SP_RPT_TRAVEL_Expense_Allowance]
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
	,@Constraint	varchar(MAX)
	,@flag		varchar(5)='0'
	,@Settlement_ID numeric(18,0)=0
	,@is_foreign tinyint=0
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
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID
							
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
		
		--select   EED.cmp_ID,EED.Emp_ID,TSAE.Travel_Settlement_Id, AM.AD_NAME,TSAE.For_Date,(GA.AD_AMOUNT * ADS.Amount)as  Travel_Working_AD_Amount 
		-- from T0100_EMP_EARN_DEDUCTION  EED  
		-- inner join ( select max(Increment_ID) as Increment_ID , Emp_ID					
		--			from T0095_Increment
		--			where Increment_Effective_date <= @To_Date
		--			and Cmp_ID = @Cmp_ID
		--			group by emp_ID					
		--			) Qry on EED.Emp_ID = Qry.Emp_ID	and EED.Increment_ID = Qry.Increment_ID
		--inner join T0095_INCREMENT I on Qry.Increment_ID = I.Increment_ID			
		--inner join T0050_AD_MASTER AM on EED.AD_ID = AM.AD_ID and AM.AD_CALCULATE_ON = 'Slab Wise' 
		--inner join T0040_AD_Slab_Setting ADS on EED.AD_ID = ADS.AD_ID and ADS.Calc_Type = 'Travel(Working Hours)' 
		--inner Join T0150_Travel_Settlement_Approval_Expense TSAE on TSAE.Emp_ID = EED.EMP_ID 
		--inner join T0120_GRADEWISE_ALLOWANCE GA on GA.Ad_ID = EED.AD_ID and GA.Grd_ID = I.Grd_ID 
		--where TSAE.Appr_Duration between ADS.From_Slab AND ADS.To_Slab 
		--	and EED.Cmp_ID = @Cmp_ID and EED.EMP_ID in (select Emp_ID from @Emp_Cons)
	
	
         Select  ETM.Expense_Type_name,SUM(TSAE.Approved_Amount)Approved_Amount,TSAE.Travel_Settlement_Id,TAD.Travel_Set_Application_id
		 from T0150_Travel_Settlement_Approval TAD WITH (NOLOCK)
         inner join T0140_Travel_Settlement_Application TSA WITH (NOLOCK) ON TAD.Travel_Set_Application_id=TSA.Travel_Set_Application_id and TAD.emp_id =TSA.emp_id
         inner Join T0150_Travel_Settlement_Approval_Expense as TSAE WITH (NOLOCK) on TAD.Travel_Set_Application_id =TSAE.Travel_Settlement_Id and tad.emp_id = TSAE.Emp_ID 
         left Join T0040_Expense_Type_Master ETM WITH (NOLOCK) on TSAE.Expense_Type_id=ETM.Expense_Type_ID and TSAE.Cmp_ID=ETM.CMP_ID
         inner join @Emp_cons ec on TAD.Emp_ID = ec.emp_ID 
         where TAD.Cmp_ID = @Cmp_ID AND TAD.Approval_date >=@From_Date and TAD.Approval_date <=@To_Date 
         GROUP BY Expense_Type_name,Travel_Settlement_Id,TAD.Travel_Set_Application_id
         --and EED.EMP_ID in (select Emp_ID from @Emp_Cons)
    	RETURN
