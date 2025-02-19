---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_EMP_SALARY_SETT_RECORD_GET]
	 @Cmp_ID			numeric
	,@From_Date			datetime
	,@To_Date			datetime 
	,@Branch_ID			numeric = 0
	,@Cat_ID			numeric	= 0
	,@Grd_ID			numeric = 0
	,@Type_ID			numeric = 0
	,@Dept_ID			numeric = 0
	,@Desig_ID			numeric = 0
	,@Emp_ID			numeric = 0
	,@Constraint		varchar(5000) = ''
	,@PBranch_ID		varchar(max)= '0'	--Added By Jaina 29-09-2015
	,@PVertical_ID		varchar(max)= '0'	--Added By Jaina 29-09-2015
	,@PSubVertical_ID	varchar(max)= '0'	--Added By Jaina 29-09-2015
	,@PDept_ID			varchar(max)= '0'	--Added By Jaina 29-09-2015
	,@Vertical_ID		numeric = 0			--Added By Ramiz 05/11/2015
	,@Subvertical_ID	numeric = 0			--Added By Ramiz 05/11/2015
	,@Increment_Entry_Date	datetime	--Added by Hardik 18/12/2018
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	
	declare @Date_Diff numeric 
	Declare @Month numeric 
	Declare @Year  numeric 
	
	set @Date_Diff = datediff(d,@From_Date,@To_date) + 1
	set @Month = month(Getdate())
	set @Year = YEar(Getdate())

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
		
	IF @PBranch_ID = '0' or @PBranch_ID='' --Added By Jaina 29-09-2015
		set @PBranch_ID = null   	

	if @PVertical_ID ='0' or @PVertical_ID = ''		--Added By Jaina 29-09-2015
		set @PVertical_ID = null

	if @PsubVertical_ID ='0' or @PsubVertical_ID = ''	--Added By Jaina 29-09-2015
		set @PsubVertical_ID = null

	IF @PDept_ID = '0' or @PDept_Id=''  --Added By Jaina 29-09-2015
		set @PDept_ID = NULL	 
--Added By Ramiz on 05/11/2015--	
	If @Vertical_ID = 0
		set @Vertical_ID = null
		
	If @Subvertical_ID = 0
		set @Subvertical_ID = null	 
		
	If @Increment_Entry_Date = '' Or @Increment_Entry_Date = '1900-01-01' Or @Increment_Entry_Date = '1900-01-01 00:00:00'
		Set @Increment_Entry_Date = NULL
--Ended By Ramiz on 05/11/2015--

--Added By Jaina 29-09-2015 Start		
	if @PBranch_ID is null
	Begin	
		select   @PBranch_ID = COALESCE(@PBranch_ID + ',', '') + cast(Branch_ID as nvarchar(5))  from T0030_BRANCH_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		set @PBranch_ID = @PBranch_ID + ',0'
	End
	
	if @PVertical_ID is null
	Begin	
		select   @PVertical_ID = COALESCE(@PVertical_ID + ',', '') + cast(Vertical_ID as nvarchar(5))  from T0040_Vertical_Segment WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		If @PVertical_ID IS NULL
			set @PVertical_ID = '0';
		else
			set @PVertical_ID = @PVertical_ID + ',0'
	End
	if @PsubVertical_ID is null
	Begin	
		select   @PsubVertical_ID = COALESCE(@PsubVertical_ID + ',', '') + cast(subVertical_ID as nvarchar(5))  from T0050_SubVertical WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		If @PsubVertical_ID IS NULL
			set @PsubVertical_ID = '0';
		else
			set @PsubVertical_ID = @PsubVertical_ID + ',0'
	End
	IF @PDept_ID is null
	Begin
		select   @PDept_ID = COALESCE(@PDept_ID + ',', '') + cast(Dept_ID as nvarchar(5))  from T0040_DEPARTMENT_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 		
		if @PDept_ID is null
			set @PDept_ID = '0';
		else
			set @PDept_ID = @PDept_ID + ',0'
	End
	--Added By Jaina 29-09-2015 End
		
	
	CREATE TABLE #Emp_Cons
		(
			Emp_ID	numeric
		)
	
	if @Constraint <> ''
		begin
			Insert Into #Emp_Cons
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
		end
	else 
		begin
		
			Insert Into #Emp_Cons
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
			and Isnull(Vertical_ID,0) = isnull(@Vertical_ID ,Isnull(Vertical_ID,0))		--Added By Ramiz on 05/11/2015
			and Isnull(SubVertical_ID,0) = isnull(@Subvertical_ID ,Isnull(SubVertical_ID,0))	--Added By Ramiz on 05/11/2015
			and Cast(Cast(Isnull(I.Increment_Date,0) as varchar(11)) as datetime) = isnull(@Increment_Entry_Date,Cast(Cast(Isnull(I.Increment_Date,0) as varchar(11)) as datetime))	--Added By Hardik 18/12/2018
			--Added By Jaina 14-10-2015
			and EXISTS (select Data from dbo.Split(@PBranch_ID, ',') PB Where cast(PB.data as numeric)=Isnull(i.Branch_ID,0))
		   and EXISTS (select Data from dbo.Split(@PVertical_ID, ',') V Where cast(v.data as numeric)=Isnull(I.Vertical_ID,0))
		   and EXISTS (select Data from dbo.Split(@PsubVertical_ID, ',') S Where cast(S.data as numeric)=Isnull(I.SubVertical_ID,0))
       	   and EXISTS (select Data from dbo.Split(@PDept_ID, ',') D Where cast(D.data as numeric)=Isnull(I.Dept_ID,0)) 
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			and I.Emp_ID in 
				( select Emp_Id from
				(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK) where cmp_ID = @Cmp_ID ) qry
				where cmp_ID = @Cmp_ID   and  
				(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
				or ( @To_Date  >= join_Date  and @To_Date <= left_date )
				or Left_date is null and @To_Date >= Join_Date)
				or @To_Date >= left_date  and  @From_Date <= left_date ) 
			
		end
		
		
	
		select S_Sal_tran_ID,e.Emp_Id, E.Alpha_Emp_code + '-' + E.Emp_full_Name as Emp_full_Name, S_M_IT_Tax,S_M_OT_Hours,S_Other_Dedu_Amount,S_M_LOAN_AMOUNT,S_M_ADV_AMOUNT,
				S_Other_Allow_Amount,@Date_Diff	Month_days	, isnull(S_M_Present_Days,0)S_M_Present_Days ,
				case When not S_Sal_Tran_ID is null then 'Done' else '' end Status ,
				isnull(S_Eff_Month,@Month) S_Eff_Month,isnull(S_Eff_Year,@Year) S_Eff_Year
				,isnull(S_Eff_Month,@Month) S_Eff_Month_to,isnull(S_Eff_Year,@Year) S_Eff_Year_to
				,I_Q.Branch_ID, month(I_Q.Increment_Effective_Date) as S_Eff_Month_new
		from T0080_EMP_MASTER E WITH (NOLOCK) inner join 
			#Emp_Cons EC ON E.Emp_ID = EC.Emp_ID INNER JOIN
			( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , T0095_INCREMENT.Emp_ID 
						from T0095_Increment WITH (NOLOCK) INNER JOIN
							#Emp_Cons EC ON T0095_INCREMENT.Emp_ID = EC.Emp_ID
						where Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID
						group by T0095_INCREMENT.emp_ID) Qry on
					I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID) I_Q 
				on E.Emp_ID = I_Q.Emp_ID  inner join
					T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  LEFT OUTER join 
					( SELECT MS.EMP_ID,S_M_Present_Days ,S_Sal_Tran_ID,S_M_OT_Hours,S_M_Adv_Amount,S_M_Loan_Amount,S_M_IT_Tax,S_Other_Dedu_Amount,S_Other_Allow_Amount 
							,Month(S_Eff_Date)S_Eff_Month,Year(S_Eff_Date)S_Eff_Year
						FROM 	T0201_MONTHLY_SALARY_SETT MS WITH (NOLOCK) INNER JOIN #Emp_Cons EC ON MS.EMP_ID = EC.EMP_ID 
						WHERE CMP_ID = @CMP_ID AND S_MONTH_END_DATE >=@FROM_DATE AND S_MONTH_END_DATE <=@TO_DATE )SG ON 
						E.EMP_ID  =SG.EMP_ID
		WHERE E.Cmp_ID = @Cmp_Id	
		Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End
				--order by 	RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500)
				
		
		
		
	RETURN











