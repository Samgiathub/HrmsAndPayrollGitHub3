CREATE PROCEDURE [dbo].[SP_GRATUITY_EMP_RECORD_GET_FNF]
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
			--and I.Emp_ID in 
			--	( select Emp_Id from
			--	(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
			--	where cmp_ID = @Cmp_ID   and  
			--	(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
			--	or ( @To_Date  >= join_Date  and @To_Date <= left_date )
			--	or Left_date is null and @To_Date >= Join_Date)
			--	or @To_Date >= left_date  and  @From_Date <= left_date ) 
			
		end
		
		Declare @Default_Branch_ID numeric 
		Declare @gr_Min_Year	   int
		Declare @Gr_Cal_Month	   int
		
		select @Default_Branch_ID = Branch_ID from T0030_BRANCH_MASTER WITH (NOLOCK) WHERE CMP_ID =@CMP_ID AND BRANCH_DEFAULT =1
		
		IF Isnull(@Default_Branch_ID,0) = 0 and Isnull(@Branch_ID,0) = 0 
			Begin
					select @gr_Min_Year = gr_Min_Year,@Gr_Cal_Month=Gr_Cal_Month
					from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID 
					and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Cmp_ID = @Cmp_ID)
					

			end
		else if Isnull(@Branch_ID,0) = 0 and Isnull(@Default_Branch_ID,0) > 0
			begin
					select @gr_Min_Year = gr_Min_Year,@Gr_Cal_Month=Gr_Cal_Month
					from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and  Branch_ID =@Default_Branch_ID 
					and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Cmp_ID = @Cmp_ID and Branch_ID =@Default_Branch_ID)
			end
		else if Isnull(@Branch_ID,0) > 0
			begin
					select @gr_Min_Year = gr_Min_Year,@Gr_Cal_Month=Gr_Cal_Month
					from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID =@Branch_ID
					and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Cmp_ID = @Cmp_ID and Branch_ID =@Branch_ID)
			
			end
		
			set @gr_Min_Year  = isnull(@gr_Min_Year,0)
			set @Gr_Cal_Month = isnull(@Gr_Cal_Month,0)
			
			Declare @Last_Gratuity table
				(
					Emp_ID		numeric,
					Last_Gr_Date Datetime
				)
			
			insert into @Last_Gratuity 
				select ec.Emp_ID ,max(To_Date) from T0100_Gratuity g WITH (NOLOCK) inner join @Emp_Cons ec on g.emp_ID =ec.emp_ID 
				where Cmp_ID =@Cmp_ID group by ec.emp_ID
			
		
		
		
			insert #Gratuity(Emp_ID,Emp_Left,Emp_Code,Emp_Full_Name,Date_Of_Join,Last_Gr_Date,Gr_Year,Work_Year) 
		
		
			select * 
			,DBO.F_GET_AGE (last_Gr_Date,@To_Date,'Y','N')  as  Gr_Year,
			DBO.F_GET_AGE (Date_Of_Join,@To_Date,'Y','N')  as Work_Year
			
				from 
		 	( 
			select e.emp_ID ,e.Emp_LEft,Emp_Code,Emp_Full_Name,
		 		Case when E.GroupJoiningDate Is null or E.GroupJoiningDate = '01-Jan-1900' then E.Date_Of_Join else E.GroupJoiningDate end AS Date_of_join
		 			,case when Last_Gr_Date is null then
		 				--Date_of_Join 
		 				Case when E.GroupJoiningDate Is null or E.GroupJoiningDate = '01-Jan-1900' then E.Date_Of_Join else E.GroupJoiningDate end
		 			else
		 				Last_Gr_Date
		 			end last_Gr_Date
		 			
			From T0080_EMP_MASTER E WITH (NOLOCK) inner join @Emp_Cons ec on e.emp_Id = ec.emp_ID inner join 
		  T0010_COMPANY_MASTER Cm WITH (NOLOCK) on E.Cmp_ID = Cm.Cmp_ID inner join
			( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_Id) as Increment_Id, Emp_ID from T0095_Increment WITH (NOLOCK)  --Changed by Hardik 09/09/2014 for Same Date Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id) I_Q  --Changed by Hardik 09/09/2014 for Same Date Increment
				on E.Emp_ID = I_Q.Emp_ID  inner join
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
					T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
					@Last_Gratuity lg on e.Emp_ID = lg.Emp_ID 
				
			WHERE E.Cmp_ID = @Cmp_Id	) q 
		Where @gr_Min_Year > 0 and ( @Gr_Cal_Month =0 or @Gr_Cal_Month = Month(@To_Date)) 
		
			And (( CAST(DBO.F_GET_AGE (last_Gr_Date,@To_Date,'N','N')  as DECIMAL(10,0))  >= @gr_Min_Year  ) 
			-- Deepal discussed with chintan bhai Start Comment the below Condition 20102021 
			--OR 
			--cast( Substring(dbo.F_GET_AGE(last_Gr_Date,@To_Date,'Y','N'),charindex('.',dbo.F_GET_AGE(last_Gr_Date,@To_Date,'Y','N'))+1,2) as numeric) >=6   --- This condition for Month Split, if employee work 4.6 and above then he should come under gratuity, by Hardik 17/11/2017
			--And cast( substring(dbo.F_GET_AGE(last_Gr_Date,@To_Date,'Y','N'),1,charindex('.',dbo.F_GET_AGE(last_Gr_Date,@To_Date,'Y','N'))) as numeric) >=4 --- This condition for Year Split, if employee work 4.6 and above then he should come under gratuity, by Hardik 17/11/2017
			-- Deepal  discussed with chintan bhai END Comment the below Condition 20102021
			) 
		-----Below condition commented by Hardik 17/11/2017 and added above one
		--where Cast(DBO.F_GET_AGE (last_Gr_Date,@To_Date,'N','N') as numeric(18,2)) >= @gr_Min_Year 
		--And  @gr_Min_Year > 0 and ( @Gr_Cal_Month =0 or @Gr_Cal_Month = Month(@To_Date))
		--OR  (Cast(DBO.F_GET_AGE(last_Gr_Date,@To_Date,'Y','N') as numeric(18,2)) >= 4.6 --AND Q.Emp_Left='Y'
		--)
		
	
	RETURN




