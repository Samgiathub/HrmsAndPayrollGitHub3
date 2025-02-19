



---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_EMP_SALARY_RECORD_GET]
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		numeric   = 0
	,@Cat_ID		numeric  = 0
	,@Grd_ID		numeric = 0
	,@Type_ID		numeric  = 0
	,@Dept_ID		numeric  = 0
	,@Desig_ID		numeric = 0
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(5000) = ''
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	
	declare @Date_Diff numeric 
	
	set @Date_Diff = datediff(d,@From_Date,@To_date) + 1
	

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
	
	

		select Sal_tran_ID,e.Emp_Id,Pan_No,BM.Comp_Name,CM.Cmp_Name,Cm.Cmp_Address,BM.Branch_address,cast( E.Emp_Code as varchar) + ' - '+E.Emp_Full_Name as Emp_Full_Name,TP1.IT_M_Amount,TP1.IT_M_ED_Cess_Amount,TP1.IT_M_Surcharge_Amount,M_OT_Hours,Other_Dedu_Amount,M_LOAN_AMOUNT,M_ADV_AMOUNT,Other_Allow_Amount
				,@Date_Diff	Month_days	, isnull(Present_Days,@Date_Diff)Present_Days ,
				case When not Sal_Tran_ID is null then
					'Done'
				else
					''
				end Status
				,P_DAYS
		from T0080_EMP_MASTER E WITH (NOLOCK) LEFT OUTER join 
					(Select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I WITH (NOLOCK) inner join 
					(Select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
						Where Increment_Effective_date <= @To_Date
						And Cmp_ID = @Cmp_ID
						Group by emp_ID  ) Qry on
							I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date	 ) I_Q 
							On E.Emp_ID = I_Q.Emp_ID  inner join
							T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID				LEFT OUTER JOIN
							T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID			LEFT OUTER JOIN
							T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
							T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id		INNER JOIN 
							T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID		Inner join 
							T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID				LEFT OUTER JOIN 
					(SELECT MS.EMP_ID,Present_Days ,Sal_Tran_ID,M_OT_Hours,M_Adv_Amount,M_Loan_Amount,M_IT_Tax,Other_Dedu_Amount,Other_Allow_Amount,IT_M_ED_Cess_Amount,IT_M_Surcharge_Amount FROM 	T0200_MONTHLY_SALARY MS WITH (NOLOCK) INNER JOIN 
						@EMP_CONS EC ON MS.EMP_ID = EC.EMP_ID 
						WHERE CMP_ID = @CMP_ID And MONTH_END_DATE >=@FROM_DATE AND MONTH_END_DATE <=@TO_DATE )SG ON 
						E.EMP_ID  =SG.EMP_ID inner join
						
		           (SELECT TP.IT_M_Amount,TP.IT_M_ED_Cess_Amount,TP.IT_M_Surcharge_Amount FROM 	T0190_Tax_Planning TP WITH (NOLOCK)  INNER JOIN 
						@EMP_CONS EC ON TP.EMP_ID = EC.EMP_ID 
						WHERE CMP_ID = @CMP_ID And TP.For_Date >=@FROM_DATE AND TP.For_Date <=@TO_DATE )TP1 ON 
						E.EMP_ID  =SG.EMP_ID Left outer join	
						
					(SELECT MPI.EMP_ID,P_DAYS FROM 	T0190_MONTHLY_PRESENT_IMPORT MPI WITH (NOLOCK) INNER JOIN 
						@EMP_CONS EC ON MPI.EMP_ID = EC.EMP_ID 
						WHERE CMP_ID = @CMP_ID AND FOR_DATE >=@FROM_DATE AND FOR_DATE <=@TO_DATE )Q_MPI	ON E.EMP_ID =Q_MPI.EMP_ID
			WHERE E.Cmp_ID = @Cmp_Id And ((@From_Date < E.Emp_LEft_Date And @To_Date < E.Emp_LEft_Date) or E.Emp_LEft_Date is null)	--and Tp.for_Date>= @FROM_DATE and Tp.for_Date<=@To_Date
				And E.Emp_ID in (select Emp_ID From @Emp_Cons)  
				
				order by  Emp_Code asc
				
			
	--	Select * from T0190_Tax_Planning TP inner join @Emp_cons E 
	--	  On TP.Emp_ID = E.Emp_ID where Cmp_ID=@Cmp_ID and Tp.for_Date>= @FROM_DATE and Tp.for_Date<=@To_Date
		
		
		
	RETURN




