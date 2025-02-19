

---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_EMP_ReimBalance_RECORD_GET]
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
	,@RC_ID			numeric(18,0) = 0
	
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
	
	Create Table #ReimBalance
	(
		Cmp_ID numeric(18,0),
		Emp_ID numeric(18,0),
		AD_ID  numeric(18,0),
		Reim_Opening numeric(18,2),
		Reim_Credit numeric(18,2),
		Reim_Debit numeric(18,2),
		Reim_Closing numeric(18,2)
	)
	
	create table #RC_ID
		(
			RC_ID varchar(5)
		)
	If @RC_ID = 0
		Begin
			insert into #RC_ID
				select AD_ID from T0050_AD_Master WITH (NOLOCK) where Cmp_Id=@Cmp_ID and isnull(AD_NOT_EFFECT_SALARY,0) = 1  and Allowance_Type='R' and AD_ACTIVE = 1  order by AD_ID asc
		End
	Else
		Begin
			insert into #RC_ID values(@RC_ID)
		End
	
	Declare cur_Emp_Id Cursor for
		select Emp_ID From @Emp_Cons
	open cur_Emp_Id
	 fetch next from cur_Emp_Id into @Emp_ID
	 while @@FETCH_STATUS = 0
		begin
		
			Declare cur_RC_ID Cursor for
				select RC_ID From #RC_ID
			open cur_RC_ID
			 fetch next from cur_RC_ID into @RC_ID
			 while @@FETCH_STATUS = 0
				Begin
					
					insert into #ReimBalance
					SELECT  @Cmp_ID,E.Emp_ID,@RC_ID,
							
						(SELECT LT.Reim_Opening FROM T0140_ReimClaim_Transacation LT WITH (NOLOCK) inner join		
									(SELECT  top 1 LT.Reim_Tran_ID Reim_Tran_ID
											FROM T0140_ReimClaim_Transacation LT WITH (NOLOCK) INNER JOIN 
												 T0050_AD_Master AD WITH (NOLOCK) ON LT.RC_ID = AD.AD_ID
											WHERE LT.Emp_ID = @Emp_ID AND LT.RC_ID = @RC_ID and
												  LT.FOR_DATE >= @From_Date AND LT.For_Date <= @To_Date
												  order BY LT.For_Date ASC
											) Opening on LT.Reim_Tran_ID = Opening.Reim_Tran_ID)	Reim_Opening,
											
					   (SELECT  Sum(LT.Reim_Credit)
								FROM T0140_ReimClaim_Transacation LT WITH (NOLOCK) INNER JOIN 
									 T0050_AD_Master AD WITH (NOLOCK) ON LT.RC_ID = AD.AD_ID
								WHERE LT.Emp_ID = @Emp_ID AND LT.RC_ID = @RC_ID and
									  LT.FOR_DATE >= @From_Date AND LT.For_Date <= @To_Date
								group by LT.Emp_ID,LT.RC_ID )Reim_Credit,
									
						(SELECT  Sum(LT.Reim_Debit)
								FROM T0140_ReimClaim_Transacation LT WITH (NOLOCK) INNER JOIN 
									 T0050_AD_Master AD WITH (NOLOCK) ON LT.RC_ID = AD.AD_ID
								WHERE LT.Emp_ID = @Emp_ID AND LT.RC_ID = @RC_ID and
									  LT.FOR_DATE >= @From_Date AND LT.For_Date <= @To_Date
								group by LT.Emp_ID,LT.RC_ID)Reim_Debit,
											
						(SELECT LT.Reim_Closing FROM T0140_ReimClaim_Transacation LT WITH (NOLOCK) inner join
								(SELECT  top 1 LT.Reim_Tran_ID as Reim_Tran_ID
										FROM T0140_ReimClaim_Transacation LT WITH (NOLOCK) INNER JOIN 
											 T0050_AD_Master AD WITH (NOLOCK) ON LT.RC_ID = AD.AD_ID
										WHERE LT.Emp_ID = @Emp_ID AND LT.RC_ID = @RC_ID and
											  LT.FOR_DATE >= @From_Date AND LT.For_Date <= @To_Date
										--group by LT.Emp_ID,LT.RC_ID
										ORDER by LT.For_Date DESC 
										) Closing on LT.Reim_Tran_ID = Closing.Reim_Tran_ID)Reim_Closing							
								   
					FROM T0080_EMP_MASTER E WITH (NOLOCK)
					WHERE  E.Emp_ID = @Emp_ID
					
					fetch next from cur_RC_ID into @RC_ID
				End
				close cur_RC_ID
				Deallocate cur_RC_ID
	
			fetch next from cur_Emp_Id into @Emp_ID
		end
	close cur_Emp_Id
	Deallocate cur_Emp_Id
	
	Delete from #ReimBalance where isnull(Reim_Opening,0) = 0 And   --Ripal 21Nov2014 Change by Ripal
								   isnull(Reim_Credit,0) = 0 And 
								   isnull(Reim_Debit,0) = 0 And 
								   isnull(Reim_Closing,0) = 0
	
	select #ReimBalance.*,@From_Date as From_Date,@To_Date as To_Date,
		   E.Alpha_Emp_Code,E.Emp_Full_Name,AD.AD_NAME,AD.AD_SORT_NAME,
		   GM.Grd_Name,DM.Dept_Name,DGM.Desig_Name,ETM.Type_Name,BM.Branch_Name,BM.Branch_Address
			,CM.Cmp_Address,CM.Cmp_Name 
			,E.Emp_first_Name  --added jimit 21052015
			,BM.Branch_ID --Added By Nimesh 11-Jul-2015 (To filter by multiple branch)
			from #ReimBalance inner join
			T0050_AD_Master AD WITH (NOLOCK) ON #ReimBalance.AD_ID = AD.AD_ID INNER JOIN
			T0080_EMP_MASTER E WITH (NOLOCK) on #ReimBalance.Emp_ID = E.Emp_ID  LEFT OUTER JOIN
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON E.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON E.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM  WITH (NOLOCK) ON E.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON E.Dept_Id = DM.Dept_Id LEFT OUTER JOIN
					T0030_BRANCH_MASTER BM WITH (NOLOCK) ON E.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
					T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID
					
		--where isnull(#ReimBalance.Reim_Opening,0) > 0
				  
	
	drop table #ReimBalance
	drop table #RC_ID
RETURN


