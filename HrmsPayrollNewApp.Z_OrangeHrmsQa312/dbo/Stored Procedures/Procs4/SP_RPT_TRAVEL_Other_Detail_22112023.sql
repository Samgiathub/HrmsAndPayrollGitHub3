
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
Create PROCEDURE [dbo].[SP_RPT_TRAVEL_Other_Detail_22112023]
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
	,@is_foreign tinyint =0
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
		
	     Select TAD.*
	     ,e.Emp_Full_name,e.Emp_Code,e.Alpha_Emp_Code,e.Emp_First_Name
	     --,Cmp_Name,Cmp_Address 
	     ,@From_Date as From_Date,@To_Date as To_Date
		,isnull(TAA.Travel_Approval_ID,0) as TAA_Approval_Id,TAA.travel_mode_id as TAA_travel_mode_id,
		TAA.Description,TAA.Amount as Amount
		,case when TAA.Self_Pay = 1 then 'Yes' else 'No' end As Self_Pay  
		,CONVERT(VARCHAR(11),TAA.For_date,103) as For_date 
		,right(convert(varchar,TAA.For_date),7) as From_Time
		,TM.Travel_mode_name--,
			--CRM.Curr_Symbol
			
         from T0150_Travel_Settlement_Approval TAD WITH (NOLOCK)
         inner join T0140_Travel_Settlement_Application TSA WITH (NOLOCK) ON TAD.Travel_Set_Application_id=TSA.Travel_Set_Application_id and TAD.emp_id =TSA.emp_id		 
         inner join @Emp_cons ec on TAD.Emp_ID = ec.emp_ID 
         inner join T0080_Emp_Master e WITH (NOLOCK) on TAD.Emp_ID = e.emp_ID 
         left join T0130_Travel_Approval_Other_Detail as TAA WITH (NOLOCK) on TSA.Travel_Approval_ID =TAA.Travel_Approval_ID
         left JOIN dbo.T0030_TRAVEL_MODE_MASTER AS TM WITH (NOLOCK) ON TM.Travel_Mode_ID = TAA.Travel_Mode_ID          
         left join T0040_CURRENCY_MASTER crm WITH (NOLOCK) on crm.curr_id=TAA.Curr_ID
         
         
         --inner join T0010_Company_Master CM on TAD.Cmp_ID= CM.CMP_ID
     --    inner join
					--( select I.Emp_Id , Cmp_ID,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date from T0095_Increment I inner join 
					--		( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment
					--		where Increment_Effective_date <= @To_Date
					--		and Cmp_ID = @Cmp_ID
					--		group by emp_ID  ) Qry on
					--		I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date	 ) I_Q 
					--	on E.Emp_ID = I_Q.Emp_ID  
		
		where  TAd.Cmp_ID = @Cmp_ID 
		and TAD.Approval_date >=@From_Date and 
			 TAD.Approval_date <=@To_Date
		--and
		--TAD.Approval_date >= case when @Flag ='0' then TAD.Approval_date else  cast(cast(@From_Date as varchar(11)) as datetime) end
		--			and  
		--			TAD.Approval_date <= case when @Flag ='0' then TAD.Approval_date else  cast(cast(@To_Date + 1 as varchar(11)) as datetime)  end
		--			and
		--			TSA.Travel_Set_Application_id=case when @Flag ='0' then TSA.Travel_Set_Application_id else @Settlement_ID end 
		Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End
		--ORDER BY RIGHT(REPLICATE(N' ', 500) + e.ALPHA_EMP_CODE, 500) 
         
    	RETURN 


