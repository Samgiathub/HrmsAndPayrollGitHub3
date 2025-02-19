



---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_EMP_GRATUITY_RECORD_GIVEN]
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
				or @To_Date >= left_date and  @From_Date <= left_date ) 
			
		end
				
				select   E.Emp_Full_Name,E.Emp_ID,E.Gender,E.Date_Of_Join,Religion,street_1,city,state, E.Emp_Code,E.Marital_Status, BM.Comp_Name,BM.Branch_Address  
        ,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender,Cmp_Name,Cmp_Address,Present_Street,Present_State,Present_City,
        G.From_Date as G_From_Date,G.To_Date as G_To_Date,G.Gr_Calc_Amount,G.Gr_Amount,G.Gr_Calc_Type,g.Gr_Days,G.Gr_FNF,G.Gr_Percentage,G.Paid_Date,dbo.F_Number_TO_Word(G.Gr_Calc_Amount) as Net_Amount_In_Word,DATEDIFF(MONTH,E.Date_of_Join,E.Emp_Left_Date) as month,E.Emp_left_date,
        EDD.Name as Nominee_Name,EDD.BirthDate as Nominee_Birthdate,EDD.NomineeFor as Nominee_For,EDD.D_Age as Nominee_Age,EDD.RelationShip as nominee_RelationShip,EDD.Is_Resi as Nominee_Resi,EDD.Address as Nominee_Add,EDD.Share as Nominee_Share

				from T0080_EMP_MASTER E WITH (NOLOCK) left outer join t0090_emp_dependant_detail EDD WITH (NOLOCK) on E.Emp_ID=EDD.Emp_ID inner join
						( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I WITH (NOLOCK) inner join 
								( select max(Increment_ID) as Increment_ID, Emp_ID from T0095_Increment WITH (NOLOCK) --Changed by Hardik 09/09/2014 for Same Date Increment
								where Increment_Effective_date <= @To_Date
								and Cmp_ID = @Cmp_ID
								group by emp_ID  ) Qry on
								I.Emp_ID = Qry.Emp_ID and I.Increment_ID= Qry.Increment_ID) I_Q  --Changed by Hardik 09/09/2014 for Same Date Increment
							on E.Emp_ID = I_Q.Emp_ID  
							inner join T0100_GRATUITY G WITH (NOLOCK) on E.Cmp_ID = G.Cmp_ID and E.Emp_Id=G.Emp_ID
							inner join @Emp_Cons EC on G.Emp_Id=EC.Emp_ID
							left join T0040_GRADE_MASTER GM WITH (NOLOCK) ON E.Grd_ID = GM.Grd_ID 
							left outer Join	T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
							left outer Join	T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
							left outer Join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
							left outer Join T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 
							left outer Join T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID
				
			
	RETURN


