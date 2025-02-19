


--Created By: Falak on 25-OCT-2010
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_T0200_MONTHLY_SALARY_DAILY_WITH_DETAIL_GET]
	 @Cmp_ID 		numeric
	,@From_Date		datetime
	,@To_Date 		datetime
	,@Branch_ID		numeric
	,@Cat_ID 		numeric 
	,@Grd_ID 		numeric
	,@Type_ID 		numeric
	,@Dept_ID 		numeric
	,@Desig_ID 		numeric
	,@Emp_ID 		numeric
	,@constraint 	varchar(5000)
	,@Report_For	varchar(50) = 'EMP RECORD'
	,@Sal_Type  numeric = 0 
	,@Salary_Cycle_id numeric = NULL
	,@Segment_Id  numeric = 0		 -- Added By Gadriwala Muslim 21082013
	,@Vertical_Id numeric = 0		 -- Added By Gadriwala Muslim 21082013
	 ,@SubVertical_Id numeric = 0	 -- Added By Gadriwala Muslim 21082013	
	,@SubBranch_Id numeric = 0		 -- Added By Gadriwala Muslim 21082013	       

	
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
	if @Salary_Cycle_id = 0		 -- Added By Gadriwala Muslim 21082013
	set @Salary_Cycle_id = null	
	If @Segment_Id = 0		 -- Added By Gadriwala Muslim 21082013
	set @Segment_Id = null
	If @Vertical_Id = 0		 -- Added By Gadriwala Muslim 21082013
	set @Vertical_Id = null
	If @SubVertical_Id = 0	 -- Added By Gadriwala Muslim 21082013
	set @SubVertical_Id = null	
	If @SubBranch_Id = 0	 -- Added By Gadriwala Muslim 21082013
	set @SubBranch_Id = null	
 	
		
	Declare @Is_Cancel_Holiday  numeric(1,0)
	Declare @Is_Cancel_Weekoff	numeric(1,0)	
		
	Declare @Emp_Cons Table
	(
		Emp_ID	numeric
	)
	
	if @Constraint <> ''
		begin
			Insert Into @Emp_Cons(Emp_ID)
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
		end
	else
		begin
			Insert Into @Emp_Cons(Emp_ID)

			select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment WITH (NOLOCK)
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
			and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))	 -- Added By Gadriwala Muslim 21082013
			and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 -- Added By Gadriwala Muslim 21082013
		    and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) -- Added By Gadriwala Muslim 21082013
			and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) -- Added By Gadriwala Muslim 21082013
   
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			AND I.Emp_ID in (select emp_Id from
					(select emp_id, Cmp_ID, join_Date, isnull(left_Date, @To_Date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
					where Cmp_ID = @Cmp_ID   and  
					(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
					or ( @From_Date <= join_Date  and @To_Date >= left_date )	
					or ( @To_Date  >= join_Date  and @To_Date <= left_date )
					or left_date is null and  @To_Date >= Join_Date)) 
		end
	
	IF @Report_For = 'EMP RECORD'
		BEGIN
		 
		 
			Select QRY.Tot_P_Days,QRY.BASic_Salary,QRY.Net_Amount,Qry.M_AD_Amt,E.Emp_ID ,E.Emp_code, E.Alpha_Emp_Code,E.Emp_full_Name ,Comp_Name,Branch_Address
			, Branch_Name , Dept_Name ,Grd_Name , Desig_Name
			,Type_Name
			,CMP_NAME,CMP_ADDRESS
			,@From_Date as P_From_date ,@To_Date as P_To_Date			
			From @Emp_Cons EC INNER JOIN  T0080_EMP_MASTER E WITH (NOLOCK) ON EC.EMP_ID =E.EMP_ID  INNER JOIN 
			
			(Select Emp_ID,sum(Sal_Cal_Days) AS Tot_P_Days,Basic_Salary,sum(Net_Amount + Other_Allow_Amount ) as Net_Amount,sum(Other_Allow_Amount) as M_AD_Amt
			 from  T0200_Monthly_Salary_Daily MS WITH (NOLOCK)
			 where Month_St_Date>=@From_Date and Month_St_Date <=@to_Date group by Emp_ID,Basic_Salary ) as Qry on Qry.Emp_Id = EC.Emp_id
			 inner join
			
			 
			( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Type_ID,I.Emp_ID FROM T0095_Increment I WITH (NOLOCK) inner join 
						( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment WITH (NOLOCK)
						where Increment_Effective_date <= @To_Date
						and Cmp_ID = @Cmp_ID
						group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	)Q_I ON
			E.EMP_ID = Q_I.EMP_ID INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
			T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
			T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
			T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID INNER JOIN 
			T0010_COMPANY_MASTER CM WITH (NOLOCK) ON CM.CMP_ID = E.CMP_ID Left outer join 
			T0040_Type_Master tm WITH (NOLOCK) on Q_I.Type_ID = tm.Type_ID 
			Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End
			--ORDER BY RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) -- Alpesh 19-Oct-2011
			return 
		END
	
	declare @For_Date datetime 
	Declare @Date_Diff numeric 
	Declare @New_To_Date datetime 
	Declare @Row_ID	numeric 
	
	set @Date_Diff = datediff(d,@From_Date,@to_DAte) + 1 
	set @Date_Diff = 31 - ( @Date_Diff)
	set @New_To_Date = dateadd(d,@date_diff,@To_Date)
	
	
	Declare @Att_Period  table
	  (
		For_Date	datetime,
		Row_ID		numeric
	  )
	set @For_Date = @From_Date
	set @Row_ID = 1
	While @For_Date <= @New_To_Date
		begin
			
			insert into @Att_Period 
			select @For_Date ,@Row_ID
			set @Row_ID =@Row_ID + 1
			set @for_Date = dateadd(d,1,@for_date)
		end
	
	if	exists (select * from [tempdb].dbo.sysobjects where name like '#Emp_Salary_Daily_Muster' )		
			begin
				drop table #Emp_Salary_Daily_Muster
			end
			
	
	 CREATE table #Emp_Salary_Daily_Muster 
	  (
			Emp_Id		numeric , 
			Cmp_ID		numeric,
			For_Date	datetime,
			Status		varchar(10),			
			WO_HO		varchar(2),						
			Status_2	varchar(10),
			Row_ID		numeric ,
			WO_HO_Day	numeric(3,1) default 0,
			P_days		numeric(5,1) default 0
	  )

	CREATE table #Emp_Holiday
	  (
			Emp_Id		numeric , 
			Cmp_ID		numeric,
			For_Date	datetime,
			H_Day		numeric(3,1),
			is_Half_day tinyint
	  )	  

	CREATE table #Emp_Weekoff
	  (
			Emp_Id		numeric , 
			Cmp_ID		numeric,
			For_Date	datetime,
			W_Day		numeric(3,1)
	  )	  
	  
	insert into #Emp_Salary_Daily_Muster (Emp_ID,Cmp_ID,For_Date,row_ID)
	select 	Emp_ID ,@Cmp_ID ,For_Date,row_ID from @Att_Period cross join @Emp_cons
	
	Declare cur_emp cursor for 
	select Emp_ID From @Emp_Cons 
	open cur_emp
	fetch next from Cur_Emp into @Emp_ID 
	while @@fetch_Status = 0
		begin 
			select 	@Branch_ID = Branch_ID From T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date
			Where I.Emp_ID = @Emp_ID

			select @Is_Cancel_Holiday = isnull(Is_Cancel_Holiday,0)  ,@Is_Cancel_Weekoff = isnull(Is_Cancel_Weekoff,0)
				
			from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID	and Branch_ID = @Branch_ID
			and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)
			
			
			
			Exec dbo.SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_Holiday,'',0,0 ,1,@Branch_ID
			Exec dbo.SP_EMP_WEEKOFF_DATE_GET  @Emp_Id,@Cmp_ID,@From_Date,@To_Date,null,null,@Is_Cancel_Weekoff,'','',0,0,1
			fetch next from Cur_Emp into @Emp_ID 
		end 
	close cur_Emp
	Deallocate cur_Emp
	
		
	update #Emp_Salary_Daily_Muster
	set Status =  cast(LT.Sal_Cal_days as varchar(10))
	from #Emp_Salary_Daily_Muster AM inner join T0200_monthly_salary_daily LT ON AM.EMP_ID = LT.EMP_ID
	AND AM.FOR_DATE = LT.Month_St_Date 	
	and Am.For_Date >=@From_Date and Am.For_Date <=@To_Date
	
	
	Update #Emp_Salary_Daily_Muster 
	set WO_HO = 'HO',
		WO_HO_Day =eh.H_Day
	From #Emp_Salary_Daily_Muster   AM inner join #Emp_Holiday eh on am.emp_ID = eh.emp_ID and am.For_date =Eh.For_Date


/*	Update #Emp_Salary_Daily_Muster 
	set WO_HO = 'W',
		WO_HO_Day =1
	From #Emp_Salary_Daily_Muster   AM inner join 
	( select ESD.* from T0100_WEEKOFF_ADJ ESD inner join 
		( select max(For_Date)as For_Date ,Emp_ID from T0100_WEEKOFF_ADJ 
		where For_Date <= @For_Date and Cmp_Id = @Cmp_ID
		group by emp_ID )Q on ESD.emp_ID =Q.Emp_ID and ESD.For_DAte = Q.For_Date)Q_W 
		on AM.Emp_ID = Q_W.Emp_Id
	where charindex(datename(dw,AM.For_Date),Q_W.weekoff_day,0) >0
	and Am.For_Date >=@From_Date and Am.For_Date <=@To_Date
*/	
	Update #Emp_Salary_Daily_Muster 
	set WO_HO = 'W',
		WO_HO_Day =ew.W_Day
	From #Emp_Salary_Daily_Muster   AM inner join #Emp_Weekoff ew on am.emp_ID = ew.emp_ID and am.For_date =ew.For_Date
	and W_Day > 0 and Status = '0'
	
										
	Update #Emp_Salary_Daily_Muster
	set Status_2 ='CO'
	Where Status > '0' and 	( WO_HO = 'W' or WO_HO = 'HO' )and WO_HO_Day =1
	and For_Date >=@From_Date and For_Date <=@To_Date

	--Update #Emp_Salary_Daily_Muster
	--set Status_2 =WO_HO , P_days =0.5
	--Where Status > 0  and 	( WO_HO = 'W' or WO_HO = 'HO' )and WO_HO_Day =0.5
	--and For_Date >=@From_Date and For_Date <=@To_Date

	
	Update #Emp_Salary_Daily_Muster
	set Status =WO_HO
	Where isnull(Status,'') <> 'P' and ( WO_HO = 'HO' or WO_HO = 'W') 
	and For_Date >=@From_Date and For_Date <=@To_Date
	
	Update #Emp_Salary_Daily_Muster
	set Status = '0'
	Where Status is null
	and For_Date >=@From_Date and For_Date <=@To_Date
	
--update #Emp_Salary_Daily_Muster
--	set Status = 'L'
--	from #Emp_Salary_Daily_Muster AM inner join T0140_LEAVE_TRANSACTION LT ON AM.EMP_ID = LT.EMP_ID
--	INNER JOIN T0040_LEAVE_MASTER LM ON LT.LEAVE_ID=LM.LEAVE_ID
--	AND AM.FOR_DATE = LT.FOR_DATE 
--	where LT.Leave_Used  >0 and Status<>0
--	and Am.For_Date >=@From_Date and Am.For_Date <=@To_Date
	
		
	--update #Emp_Salary_Daily_Muster
	--set Status = cast(q.P_Days as varchar(10))
	--from #Emp_Salary_Daily_Muster AM inner join 
	--(select Emp_Id ,sum(Sal_Cal_Days ) as P_Days From T0200_monthly_salary_daily 
	--	where Month_St_Date>=@From_Date and Month_St_Date <=@to_Date 
	--	group by Emp_ID)Q on Am.Emp_ID = Q.Emp_ID
	--where Row_ID = 32
	

	
	--update #Emp_Salary_Daily_Muster
	--set Status = cast(Wages as varchar(10))
	--from #Emp_Salary_Daily_Muster AM inner join 
	--(select Emp_Id ,Basic_Salary as Wages From  T0200_monthly_salary_daily
	--	where Month_St_Date>=@From_Date and Month_St_Date <=@to_Date 
	--	)Q on Am.Emp_ID = Q.Emp_ID
	--where Row_ID = 33
	
	--update #Emp_Salary_Daily_Muster
	--set Status = cast(AD_Amount as varchar(10))
	--from #Emp_Salary_Daily_Muster AM inner join 
	--(select Emp_Id ,sum(M_AD_Amount) as AD_Amount From T0210_monthly_AD_Detail_Daily 
	--	where For_Date>=@From_Date and For_DAte <=@to_Date 
	--	group by Emp_ID)Q on Am.Emp_ID = Q.Emp_ID
	--where Row_ID = 34

    
	
	--update #Emp_Salary_Daily_Muster
	--set Status = Q.Net_Salary
	--from #Emp_Salary_Daily_Muster AM inner join 
	--(select Emp_Id ,sum(Net_Amount) as Net_Salary From T0200_monthly_salary_daily 
	--	Where Month_St_Date>=@From_Date and Month_St_Date <=@to_Date
	--	group by Emp_ID)Q on Am.Emp_ID = Q.Emp_ID
	--where Row_ID = 35
	
	--update #Emp_Salary_Daily_Muster
	--set Status = isnull(Status,0) + W_H_Days
	--from #Emp_Salary_Daily_Muster AM inner join 
	--(select Emp_Id ,sum(WO_HO_Day) as W_H_Days From #Emp_Salary_Daily_Muster 
	--	Where WO_HO_Day =0.5 and For_Date>=@From_Date and For_DAte <=@to_Date 
	--	group by Emp_ID)Q on Am.Emp_ID = Q.Emp_ID
	--where Row_ID = 35
	
	Select AM.* , E.Emp_code, E.Alpha_Emp_Code,cast( E.Emp_Code as varchar) + ' - '+E.Emp_Full_Name as Emp_Full_Name ,Branch_Address,comp_name
		, Branch_Name , Dept_Name ,Grd_Name , Desig_Name,@From_Date as P_From_date ,@To_Date as P_To_Date 
	From #Emp_Salary_Daily_Muster  AM Inner join T0080_EMP_MASTER E WITH (NOLOCK) ON AM.EMP_ID = E.EMP_ID
	
	INNER JOIN ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID FROM T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	)Q_I ON
		E.EMP_ID = Q_I.EMP_ID INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
		T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
		T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
		T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID 
	--Order by Emp_Code,Am.For_Date
	Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End ,Am.For_Date
	--ORDER BY RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500)
	  --'Alpesh 18-Oct-2011  
	
	--Added By Falak on 29-MAR-2011
	Select  For_Date ,sum(P_days) as Total_P_Days
	From #Emp_Salary_Daily_Muster  		
	group by For_Date
	order by For_Date 
	
	RETURN




