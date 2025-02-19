


CREATE  PROCEDURE [dbo].[SP_RPT_YEARLY_LEAVE_SUMMARY_GET]
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
	,@constraint 	varchar(MAX)
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
		 
		CREATE TABLE #Yearly_Leave
		(
			Row_ID			numeric IDENTITY (1,1) not null,
			Cmp_ID			numeric ,
			Emp_Id			numeric ,
			Leave_Id		numeric,
			Month_1			numeric(12,1) default 0,
			Month_2			numeric(12,1) default 0,
			Month_3			numeric(12,1) default 0,
			Month_4			numeric(12,1) default 0,
			Month_5			numeric(12,1) default 0,
			Month_6			numeric(12,1) default 0,
			Month_7			numeric(12,1) default 0,
			Month_8			numeric(12,1) default 0,
			Month_9			numeric(12,1) default 0,
			Month_10		numeric(12,1) default 0,
			Month_11		numeric(12,1) default 0,
			Month_12		numeric(12,1) default 0,
			Total			numeric(12,1) default 0,
			Leave_Type		VARCHAR(30) DEFAULT ''  --Added By jimit 05012018
		)
		SELECT	DISTINCT M.Emp_ID, Month_St_Date As From_Date,Month_End_Date  As To_Date
		INTO	#EMP_SALARY_PERIOD
		FROM	T0200_MONTHLY_SALARY M WITH (NOLOCK)
				INNER JOIN @Emp_Cons E ON M.Emp_ID=E.Emp_ID
		WHERE	Month_End_Date >= @From_Date And Month_End_Date <= @To_Date

		

		insert into #Yearly_Leave (Cmp_ID,Emp_ID,Leave_ID,Leave_Type)
			select @Cmp_ID,emp_ID,Leave_ID,lm.Leave_Type From @Emp_Cons ec cross join 
			t0040_Leave_Master lm where lm.cmp_ID = @cmp_ID

		
		
		DECLARE @QUERY VARCHAR(MAX)

		
		declare @Temp_Date datetime
		Declare @count numeric 
		set @Temp_Date = @From_Date 
		set @count = 1 
		while @Temp_Date <=@To_Date 
			Begin
				
				SELECT	@Temp_Date= IsNull(From_Date, @Temp_Date) 
				FROM	#EMP_SALARY_PERIOD 
				WHERE	From_Date >= @Temp_Date AND From_Date < DATEADD(M, 1, @Temp_Date)
				print @Temp_Date

				INSERT INTO #EMP_SALARY_PERIOD
				SELECT	E.EMP_ID, @Temp_Date, DATEADD(d, -1, DATEADD(M,1,@Temp_Date))
				FROM	@Emp_Cons E
				WHERE	NOT EXISTS(SELECT 1 FROM #EMP_SALARY_PERIOD ESP 
									WHERE E.Emp_ID=ESP.Emp_ID 
										--AND From_Date >= @Temp_Date AND From_Date < DATEADD(M, 1, @Temp_Date)
										AND  @Temp_Date BETWEEN From_Date AND To_Date
									)
				

				SET @QUERY = 'UPDATE	#Yearly_Leave 
								SET		Month_' + CAST(@count AS VARCHAR(5)) + ' = leave_Used
								From	#Yearly_Leave  Ys  
										INNER JOIN (SELECT	T.Emp_ID,leave_Id,(sum(leave_used) + sum(CompOff_Used) + sum(back_dated_leave) + IsNull(SUM(Leave_Adj_L_Mark),0)) AS leave_Used 
													FROM	T0140_LEAVE_TRANSACTION T WITH (NOLOCK) INNER JOIN 
															#EMP_SALARY_PERIOD SP ON T.Emp_ID=SP.Emp_ID 
															AND (T.For_Date BETWEEN SP.From_Date AND SP.To_Date) 
													WHERE	cmp_Id = ' + CAST(@Cmp_ID AS varchar(5)) + ' 
															' --and From_Date >= ''' + Cast(@Temp_Date as Varchar(20)) + ''' AND From_Date < ''' + Cast(DATEADD(M,1,@Temp_Date) as Varchar(20)) + '''
															+ ' AND ''' + Cast(@Temp_Date as Varchar(20)) + ''' BETWEEN SP.FROM_DATE AND SP.TO_DATE															 
													GROUP BY T.Emp_ID,leave_ID )Q on ys.emp_Id = q.emp_ID  AND ys.leave_Id = q.leave_ID  '

				EXEC(@QUERY)				

				
				
				set @Temp_Date = dateadd(m,1,@Temp_date)
				set @count = @count + 1  
			End
	
		UPDATE #Yearly_Leave
		SET TOTAL = MONTH_1 + MONTH_2 + MONTH_3 + MONTH_4 + MONTH_5 +MONTH_6 + MONTH_7 + MONTH_8 + MONTH_9	
					+ MONTH_10 + MONTH_11 + MONTH_12 
		
		--Ronakb010824 add grouby vertical
		
		select  Ys.*,Grd_NAme,Dept_Name,Comp_name,Branch_Address,Desig_Name,Branch_NAme,V.Vertical_Name,SubVertical_Name,SubBranch_Name,Type_NAme 
			,Cmp_NAme,Cmp_Address,Emp_Code,Emp_Full_Name,Alpha_Emp_Code,Emp_First_Name,LEAVE_NAME
			,@From_Date as P_From_Date , @To_Date as P_To_Date, BM.Branch_ID,EM.Gender
		Into #Yearly_Leave_Balance 
		from #Yearly_Leave  Ys inner join 
		( select I.Emp_Id,Grd_ID,Type_ID,Desig_ID,Dept_ID,Branch_ID,Vertical_ID,SubVertical_ID,SubBranch_ID from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)IQ on
				ys.emp_Id = iq.emp_Id inner join
					T0080_EMP_MASTER EM WITH (NOLOCK) ON YS.EMP_ID = EM.EMP_ID INNER JOIN 
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON IQ.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON IQ.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON IQ.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON IQ.Dept_Id = DM.Dept_Id Inner join 
					T0030_Branch_Master BM WITH (NOLOCK) on IQ.Branch_ID = BM.Branch_ID inner join 
					T0040_Vertical_Segment V WITH (NOLOCK) ON IQ.Vertical_ID = V.Vertical_ID Inner join
					T0050_SubVertical SV WITH (NOLOCK) ON IQ.SubVertical_ID = SV.SubVertical_ID Inner join
					T0050_SubBranch SB  WITH (NOLOCK) ON IQ.SubBranch_ID = SB.SubBranch_ID Inner join
					T0010_COMPANY_MASTER cm WITH (NOLOCK) on ys.cmp_Id = cm.cmp_Id INNER JOIN 
					T0040_LEAVE_MASTER LM WITH (NOLOCK) ON YS.LEAVE_ID =LM.LEAVe_iD
		Where LM.Leave_Status = 1		--Added By Ramiz on 28/10/2015 as In-Active Leave Was Also Coming		 
		--order by ys.Emp_ID ,Row_ID
		ORDER BY RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500),Row_ID 	
		
		--Added By Jimit 05012018
		delete from #Yearly_Leave_Balance
		where (Gender = 'M' and Leave_Type = 'Maternity Leave')
				or 
			  (Gender = 'F' and Leave_Type = 'Paternity Leave')

		select * from #Yearly_Leave_Balance
		--ended
				
	RETURN 
