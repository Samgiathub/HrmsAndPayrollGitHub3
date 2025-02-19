CREATE  PROCEDURE [dbo].[SP_RPT_TRAVEL_Expense]
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
		--select @From_Date,@To_Date
		
	     Select  TAD.*,e.Emp_Full_name,e.Emp_Code,e.Alpha_Emp_Code,e.Emp_First_Name
	     ,Cmp_Name,Cmp_Address ,@From_Date as From_Date,@To_Date as To_Date
		--,TAD1.From_Date as TAD_From_Date,TAD1.To_Date as TAD_To_Date,TAd1.Place_Of_Visit 
		,TSAE.*
		,ETM.Expense_Type_name,Etm.Expense_Type_Group
		,case when CRM.Curr_Major='Y' then Approved_Amount
		else isnull(approved_amount,0) * isnull(Exchange_rate,0) end as Apr_amt_rs
		,CRM.Curr_Symbol,case when CRM.Curr_Major='Y' then Amount
		else isnull(Amount,0) * isnull(Exchange_rate,0) end as Amt_Rs
         from T0150_Travel_Settlement_Approval TAD WITH (NOLOCK)
         inner join T0140_Travel_Settlement_Application TSA WITH (NOLOCK) ON TAD.Travel_Set_Application_id=TSA.Travel_Set_Application_id and TAD.emp_id =TSA.emp_id
         --inner Join T0130_TRAVEL_APPROVAL_DETAIL TAD1 ON TSA.Travel_Approval_ID = TAD1.Travel_Approval_ID and TSA.Cmp_id =TAD1.Cmp_id
         inner Join T0150_Travel_Settlement_Approval_Expense as TSAE WITH (NOLOCK) on TAD.Travel_Set_Application_id =TSAE.Travel_Settlement_Id and tad.emp_id = TSAE.Emp_ID 
         inner join @Emp_cons ec on TAD.Emp_ID = ec.emp_ID 
         inner join T0080_Emp_Master e WITH (NOLOCK) on TAD.Emp_ID = e.emp_ID 
         inner join T0010_Company_Master CM WITH (NOLOCK) on TAD.Cmp_ID= CM.CMP_ID
         inner join
					( select I.Emp_Id , Cmp_ID,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date from T0095_Increment I WITH (NOLOCK) inner join 
							( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment	WITH (NOLOCK) -- Ankit 10092014 for Same Date Increment
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = @Cmp_ID
							group by emp_ID  ) Qry on
							I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
						on E.Emp_ID = I_Q.Emp_ID  
		left Join T0040_Expense_Type_Master ETM WITH (NOLOCK) on TSAE.Expense_Type_id=ETM.Expense_Type_ID and TSAE.Cmp_ID=ETM.CMP_ID
		left join T0040_CURRENCY_MASTER CRM WITH (NOLOCK) on  CRM.Curr_ID=TSAE.Curr_ID
		where  
		TAd.Cmp_ID = @Cmp_ID
		and 
		TAD.Approval_date >=@From_Date and 
		
		TAD.Approval_date <=@To_Date
		--(
		--			TAD.Approval_date >= case when @is_foreign ='0' then TAD.Approval_date else  cast(cast(@From_Date as varchar(11)) as datetime) end
		--			and  
		--			TAD.Approval_date <= case when @is_foreign ='0' then TAD.Approval_date else  cast(cast(@To_Date as varchar(11)) as datetime)  end
		--			)
		--			and
		--			TSA.Travel_Set_Application_id=case when @Flag ='0' then TSA.Travel_Set_Application_id else @Settlement_ID end 
					
		
		Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End
		--ORDER BY RIGHT(REPLICATE(N' ', 500) + e.ALPHA_EMP_CODE, 500) 
         
    	RETURN 



