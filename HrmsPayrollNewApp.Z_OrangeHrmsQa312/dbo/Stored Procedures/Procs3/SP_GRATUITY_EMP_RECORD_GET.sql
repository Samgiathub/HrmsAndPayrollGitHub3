
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_GRATUITY_EMP_RECORD_GET]
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
	,@Constraint	varchar(MAX) = ''
	,@PBranch_ID varchar(max) = '0'  --Added By Jaina 30-09-2015
	,@PVertical_ID	varchar(max)= '0' --Added By Jaina 30-09-2015
	,@PSubVertical_ID	varchar(max)= '0' --Added By Jaina 30-09-2015
	,@PDept_ID varchar(max)='0'  --Added By Jaina 30-09-2015
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
		
	IF @PBranch_ID = '0' or @PBranch_ID='' --Added By Jaina 30-09-2015
		set @PBranch_ID = null   	

	if @PVertical_ID ='0' or @PVertical_ID = ''		--Added By Jaina 30-09-2015
		set @PVertical_ID = null

	if @PsubVertical_ID ='0' or @PsubVertical_ID = ''	--Added By Jaina 30-09-2015
		set @PsubVertical_ID = null

	IF @PDept_ID = '0' or @PDept_Id=''  --Added By Jaina 30-09-2015
		set @PDept_ID = NULL	 


--Added By Jaina 30-09-2015 Start		
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
	--Added By Jaina 30-09-2015 End
		
	
	CREATE Table #Emp_Cons
	(
		Emp_ID	NUMERIC,
		BRANCH_ID NUMERIC,
		INCREMENT_ID NUMERIC
	)
	
	
	if @Constraint <> ''
		begin
			Insert Into #Emp_Cons (EMP_ID)
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
		end
	else
		begin
			
			Insert Into #Emp_Cons (EMP_ID)

			select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date
					  
			Where Cmp_ID = @Cmp_ID 
			and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
			and Branch_ID = isnull(@Branch_ID ,Branch_ID)  --uncommented jimit 04072016 due to not filtered according to brnach_Id wise
			and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))  --uncommented jimit 04072016 due to not filtered according to department_Id wise
			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			--Added By Jaina 14-10-2015 start   
			and EXISTS (select Data from dbo.Split(@PBranch_ID, ',') B Where cast(B.data as numeric)=Isnull(I.Branch_ID,0))
			and EXISTS (select Data from dbo.Split(@PVertical_ID, ',') V Where cast(v.data as numeric)=Isnull(I.Vertical_ID,0))
			and EXISTS (select Data from dbo.Split(@PsubVertical_ID, ',') S Where cast(S.data as numeric)=Isnull(I.SubVertical_ID,0))
		    and EXISTS (select Data from dbo.Split(@PDept_ID, ',') D Where cast(D.data as numeric)=Isnull(I.Dept_ID,0)) 
			--Added By Jaina 14-10-2015 end
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
		
		UPDATE	E
		SET		BRANCH_ID= I.BRANCH_ID, INCREMENT_ID=I.INCREMENT_ID
		FROM	#Emp_Cons E INNER JOIN T0095_INCREMENT I ON E.EMP_ID=I.EMP_ID
				INNER JOIN  (
					SELECT	MAX(I1.INCREMENT_ID) AS INCREMENT_ID, I1.EMP_ID
					FROM	T0095_INCREMENT I1 WITH (NOLOCK) 
							INNER JOIN (
											SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I2.EMP_ID
											FROM	T0095_INCREMENT I2 WITH (NOLOCK) INNER JOIN #Emp_Cons E2 ON I2.EMP_ID=E2.Emp_ID
											WHERE	INCREMENT_EFFECTIVE_DATE <= @To_Date
											GROUP BY I2.EMP_ID
										) I2 ON I1.EMP_ID=I2.EMP_ID AND I1.INCREMENT_EFFECTIVE_DATE= I2.INCREMENT_EFFECTIVE_DATE
					GROUP BY I1.EMP_ID
				) I1 ON I.INCREMENT_ID=I1.INCREMENT_ID

		
		--commented By Mukti(start)23092016 as join of T0040_GENERAL_SETTING in next select query
		--Declare @Default_Branch_ID numeric 
		--Declare @gr_Min_Year	   int
		--Declare @Gr_Cal_Month	   int
		
		--select @Default_Branch_ID = Branch_ID from T0030_BRANCH_MASTER WHERE CMP_ID =@CMP_ID AND BRANCH_DEFAULT =1
	
		--IF Isnull(@Default_Branch_ID,0) = 0 and Isnull(@Branch_ID,0) = 0 
		--	Begin
					
		--			select @gr_Min_Year = gr_Min_Year,@Gr_Cal_Month=Gr_Cal_Month
		--			from T0040_GENERAL_SETTING where cmp_ID = @cmp_ID 
		--			and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING where For_Date <=@To_Date and Cmp_ID = @Cmp_ID)
					

		--	end
		--else if Isnull(@Branch_ID,0) = 0 and Isnull(@Default_Branch_ID,0) > 0
		--	begin			
		--			select @gr_Min_Year = gr_Min_Year,@Gr_Cal_Month=Gr_Cal_Month
		--			from T0040_GENERAL_SETTING where cmp_ID = @cmp_ID and  Branch_ID =@Default_Branch_ID 
		--			and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING where For_Date <=@To_Date and Cmp_ID = @Cmp_ID and Branch_ID =@Default_Branch_ID)					
		--	end
		--else if Isnull(@Branch_ID,0) > 0
		--	begin					
		--			select @gr_Min_Year = gr_Min_Year,@Gr_Cal_Month=Gr_Cal_Month
		--			from T0040_GENERAL_SETTING where cmp_ID = @cmp_ID and Branch_ID =@Branch_ID
		--			and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING where For_Date <=@To_Date and Cmp_ID = @Cmp_ID and Branch_ID =@Branch_ID)
			
		--	end
		
		--	set @gr_Min_Year  = isnull(@gr_Min_Year,0)
		--	set @Gr_Cal_Month = isnull(@Gr_Cal_Month,0)
		--commented By Mukti(end)23092016
		
		CREATE TABLE #Last_Gratuity
		(
			Emp_ID		numeric(18,0),
			Last_Gr_Date Datetime
		)
		
		insert into #Last_Gratuity 
		select ec.Emp_ID ,max(To_Date) from T0100_Gratuity g WITH (NOLOCK) inner join #Emp_Cons ec on g.emp_ID =ec.emp_ID 
		where Cmp_ID =@Cmp_ID group by ec.emp_ID
	
		SELECT	 *,DBO.F_GET_AGE (last_Gr_Date,@To_Date,'Y','N') AS Gr_Year, DBO.F_GET_AGE (Date_of_Join,@To_Date,'Y','N') AS Work_Year
		FROM	(
					SELECT	e.emp_ID ,e.Emp_LEft,Emp_Code,(e.Alpha_Emp_Code + '-' + Emp_Full_Name)as Emp_Full_Name,Date_of_join,isnull(qry_1.gr_Min_Year,0) AS gr_Min_Year,ISNULL(qry_1.Gr_Cal_Month,0) AS Gr_Cal_Month,QRY_1.Branch_ID,
							(CASE WHEN Last_Gr_Date IS NULL THEN Date_Of_join ELSE Last_Gr_Date END) AS  last_Gr_Date		 			
					FROM	T0080_EMP_MASTER E WITH (NOLOCK) 
							INNER JOIN #Emp_Cons ec on e.emp_Id = ec.emp_ID 
							INNER JOIN T0010_COMPANY_MASTER Cm WITH (NOLOCK) on E.Cmp_ID = Cm.Cmp_ID 
							INNER JOIN T0095_Increment I_Q WITH (NOLOCK) ON EC.INCREMENT_ID=I_Q.INCREMENT_ID
										--COMMENTED BY NIMESH ON 14-SEP-2016 (INCREMENT ID TAKEN IN EMP_CONS TABLE)
										--inner join ( 
										--	select	I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID 
										--	from	T0095_Increment I 
										--			inner join ( 
										--						SELECT	MAX(Increment_ID) AS Increment_ID , Emp_ID 
										--						FROM	T0095_Increment  --Changed by Hardik 09/09/2014 for Same Date Increment
										--						WHERE	Increment_Effective_date <= @To_Date AND Cmp_ID = @Cmp_ID
										--						GROUP BY emp_ID  
										--						) Qry ON I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID
										--) I_Q ON E.Emp_ID = I_Q.Emp_ID --Changed by Hardik 09/09/2014 for Same Date Increment
							INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
							LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.[Type_ID] = ETM.[Type_ID]
							LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
							LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
							INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID
							LEFT OUTER JOIN #Last_Gratuity lg ON e.Emp_ID = lg.Emp_ID 
							--added jimit 11072016
							INNER JOIN (
										SELECT  gr_Min_Year,Gr_Cal_Month,G.Branch_ID
										FROM	T0040_GENERAL_SETTING G WITH (NOLOCK) 
												INNER JOIN (
																SELECT	MAX(FOR_DATE) AS FOR_DATE, G1.BRANCH_ID
																FROM	T0040_GENERAL_SETTING G1 WITH (NOLOCK)
																		INNER JOIN (SELECT DISTINCT BRANCH_ID FROM #Emp_Cons) E1 ON G1.BRANCH_ID=E1.BRANCH_ID
																WHERE	CMP_ID=@CMP_ID AND FOR_DATE <= @TO_DATE
																GROUP BY G1.BRANCH_ID
															) G1 ON G.BRANCH_ID=G1.BRANCH_ID AND G.FOR_DATE=G1.FOR_DATE
										--COMMENTED BY NIMESH ON 14-SEP-2016 (ILLIGEL QUERY SPECIFIED "NO BRANCH ID USED TO GET MAX EFFECTIVE DATE")
										--WHERE   cmp_ID = @Cmp_ID --and Branch_ID = @Branch_Id
										--		AND For_Date = ( select max(For_Date) 
										--			 from   T0040_GENERAL_SETTING 											 
										--			 where  For_Date <=GETDATE() and Cmp_ID = @Cmp_ID
										--			)
										)	QRY_1 On QRY_1.Branch_ID = EC.Branch_ID
					--ended
				WHERE E.Cmp_ID = @Cmp_Id	
			) Q 
		where	Cast(DBO.F_GET_AGE (IsNull(Q.last_Gr_Date, '1900-01-01'),@To_Date,'N','N') as numeric(18,2)) >= CAST(Q.gr_Min_Year AS NUMERIC) AND
				q.Gr_Min_Year > 0  AND
				( q.Gr_Cal_Month =0 or q.Gr_Cal_Month = Month(@To_Date))
				OR	( Cast(DBO.F_GET_AGE(IsNull(Q.last_Gr_Date, '1900-01-01'),@To_Date,'Y','N') as numeric(18,2)) >= Cast(4.6 as numeric))
		
	RETURN




