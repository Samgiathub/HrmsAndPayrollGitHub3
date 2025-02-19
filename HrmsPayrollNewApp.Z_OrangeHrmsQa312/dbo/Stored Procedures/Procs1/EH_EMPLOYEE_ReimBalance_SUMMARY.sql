

---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[EH_EMPLOYEE_ReimBalance_SUMMARY]
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
	,@constraint 	varchar(max)
	,@RC_ID 	    varchar(5000) =0
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
					( select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK)  --Changed by Hardik 10/09/2014 for Same Date Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id	
							
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
		
		IF OBJECT_ID('tempdb..#ReimBalance') IS NOT NULL
		BEGIN
			DROP TABLE #TEMP
		END		
					
		CREATE table #ReimBalance
		(
		   Month_1 varchar(200),
		   Month_2 numeric,
		   Emp_ID  numeric,
		   Reim_ID varchar(20),
		   Reim_Opening numeric(18,2) default 0,
		   Reim_Credit numeric(18,2) default 0,
		   Reim_Debit numeric(18,2)  default 0,		   
		   Reim_Closing numeric(18,2) default 0,
		   Temp_Date	datetime
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
	
		declare @Month as numeric	
		declare @Month_name as varchar(3)
		declare @Temp_Date datetime
		
		set @Temp_Date = @From_Date
		
		while @Temp_Date <=@To_Date 
			Begin
			
			set @Month_name = Upper(DATENAME(MONTH, @Temp_Date))
			set @Month = MONTH(@Temp_Date)
			
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
							SELECT  @Month_name + ' ' +cast(Year(@Temp_Date) AS varchar(10)),@Month,E.Emp_ID,@RC_ID,
									
								(SELECT LT.Reim_Opening FROM T0140_ReimClaim_Transacation LT WITH (NOLOCK) inner join		
											(SELECT  min(LT.Reim_Tran_ID) Reim_Tran_ID
													FROM T0140_ReimClaim_Transacation LT WITH (NOLOCK) INNER JOIN 
														 T0050_AD_Master AD WITH (NOLOCK) ON LT.RC_ID = AD.AD_ID
													WHERE LT.Emp_ID = @Emp_ID AND LT.RC_ID = @RC_ID and
														  Month(LT.FOR_DATE) = month(@Temp_Date) and Year(LT.FOR_DATE) = Year(@Temp_Date)
													group by LT.Emp_ID,LT.RC_ID) Opening on LT.Reim_Tran_ID = Opening.Reim_Tran_ID)	Reim_Opening,
													
							   (SELECT  Sum(LT.Reim_Credit)
										FROM T0140_ReimClaim_Transacation LT WITH (NOLOCK) INNER JOIN 
											 T0050_AD_Master AD WITH (NOLOCK) ON LT.RC_ID = AD.AD_ID
										WHERE LT.Emp_ID = @Emp_ID AND LT.RC_ID = @RC_ID and
											  Month(LT.FOR_DATE) = month(@Temp_Date) and Year(LT.FOR_DATE) = Year(@Temp_Date)
										group by LT.Emp_ID,LT.RC_ID )Reim_Credit,
											
								(SELECT  Sum(LT.Reim_Debit)
										FROM T0140_ReimClaim_Transacation LT WITH (NOLOCK) INNER JOIN 
											 T0050_AD_Master AD WITH (NOLOCK) ON LT.RC_ID = AD.AD_ID
										WHERE LT.Emp_ID = @Emp_ID AND LT.RC_ID = @RC_ID and
											  Month(LT.FOR_DATE) = month(@Temp_Date) and Year(LT.FOR_DATE) = Year(@Temp_Date)
										group by LT.Emp_ID,LT.RC_ID)Reim_Debit,
													
								(SELECT LT.Reim_Closing FROM T0140_ReimClaim_Transacation LT WITH (NOLOCK) inner join
										(SELECT  MAX(LT.Reim_Tran_ID) Reim_Tran_ID
												FROM T0140_ReimClaim_Transacation LT WITH (NOLOCK) INNER JOIN 
													 T0050_AD_Master AD WITH (NOLOCK) ON LT.RC_ID = AD.AD_ID
												WHERE LT.Emp_ID = @Emp_ID AND LT.RC_ID = @RC_ID and
													  Month(LT.FOR_DATE) = month(@Temp_Date) and Year(LT.FOR_DATE) = Year(@Temp_Date)
												group by LT.Emp_ID,LT.RC_ID) Closing on LT.Reim_Tran_ID = Closing.Reim_Tran_ID)Reim_Closing,
								@Temp_Date
										   
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
																												
				set @Temp_Date = dateadd(m,1,@Temp_date)
			End
			
		select #ReimBalance.*,AD.AD_NAME,E.Emp_Full_Name from #ReimBalance inner join
					 T0050_AD_MASTER AD WITH (NOLOCK) on AD.AD_ID = #ReimBalance.Reim_ID inner join
					 T0080_EMP_MASTER E WITH (NOLOCK) on E.Emp_ID = #ReimBalance.Emp_ID
			where ISNULL(#ReimBalance.Reim_Opening,0) > 0
			order by #ReimBalance.Emp_ID,#ReimBalance.Reim_ID,#ReimBalance.Temp_Date Asc 

		select #ReimBalance.Month_1,E.Alpha_Emp_Code,E.Emp_Full_Name,AD.AD_NAME,
			   #ReimBalance.Reim_Opening,#ReimBalance.Reim_Credit,#ReimBalance.Reim_Debit,#ReimBalance.Reim_Closing
			from #ReimBalance inner join
					 T0050_AD_MASTER AD WITH (NOLOCK) on AD.AD_ID = #ReimBalance.Reim_ID inner join
					 T0080_EMP_MASTER E WITH (NOLOCK) on E.Emp_ID = #ReimBalance.Emp_ID
			where ISNULL(#ReimBalance.Reim_Opening,0) > 0
			order by #ReimBalance.Emp_ID,#ReimBalance.Reim_ID,#ReimBalance.Temp_Date Asc 							 
					 
		
		drop table #RC_ID
		drop table #ReimBalance
	RETURN




