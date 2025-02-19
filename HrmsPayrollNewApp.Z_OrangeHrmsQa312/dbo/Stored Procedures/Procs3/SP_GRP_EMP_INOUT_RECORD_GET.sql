

---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_GRP_EMP_INOUT_RECORD_GET]    
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
			Select E.Emp_ID ,E.Emp_code,E.Emp_full_Name ,Comp_Name,Branch_Address
			, Branch_Name , Dept_Name ,Grd_Name , Desig_Name
			,Type_Name
			,CMP_NAME,CMP_ADDRESS
			,@From_Date as P_From_date ,@To_Date as P_To_Date			
			From @Emp_Cons EC INNER JOIN  T0080_EMP_MASTER E WITH (NOLOCK) ON EC.EMP_ID =E.EMP_ID  INNER JOIN 
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
			
			return 
		END
	
	declare @For_Date datetime 
	Declare @Date_Diff numeric 
	Declare @New_To_Date datetime 
	Declare @Row_ID	numeric 
	
	set @Date_Diff = datediff(d,@From_Date,@to_DAte) + 1 
	set @Date_Diff = 35 - ( @Date_Diff)
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
	
	if	exists (select * from [tempdb].dbo.sysobjects where name like '#Att_Muster' )		
			begin
				drop table #Att_Muster
			end
			
	
	 CREATE table #Att_Muster 
	  (
			Emp_Id		numeric , 
			Cmp_ID		numeric,
			For_Date	datetime,
			Status		varchar(10),
			Leave_Count	numeric(5,1),
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
	  
	insert into #Att_Muster (Emp_ID,Cmp_ID,For_Date,row_ID)
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
	
	
	
	update #Att_Muster
	set Status = 'P' , P_days = 1
	from #Att_Muster AM inner join T0150_EMP_INOUT_RECORD EIR ON AM.EMP_ID = EIR.EMP_ID
	AND AM.FOR_DATE = EIR.FOR_DATE 
	where NOT EIR.IN_TIME IS NULL
	and Am.For_Date >=@From_Date and Am.For_Date <=@To_Date
	
	update #Att_Muster
	set Leave_Count = Leave_Used
	from #Att_Muster AM inner join T0140_LEAVE_TRANSACTION LT ON AM.EMP_ID = LT.EMP_ID
	AND AM.FOR_DATE = LT.FOR_DATE 
	where LT.Leave_Used  >0
	and Am.For_Date >=@From_Date and Am.For_Date <=@To_Date

	Update #Att_Muster 
	set WO_HO = 'HO',
		WO_HO_Day =eh.H_Day
	From #Att_Muster   AM inner join #Emp_Holiday eh on am.emp_ID = eh.emp_ID and am.For_date =Eh.For_Date


/*	Update #Att_Muster 
	set WO_HO = 'W',
		WO_HO_Day =1
	From #Att_Muster   AM inner join 
	( select ESD.* from T0100_WEEKOFF_ADJ ESD inner join 
		( select max(For_Date)as For_Date ,Emp_ID from T0100_WEEKOFF_ADJ 
		where For_Date <= @For_Date and Cmp_Id = @Cmp_ID
		group by emp_ID )Q on ESD.emp_ID =Q.Emp_ID and ESD.For_DAte = Q.For_Date)Q_W 
		on AM.Emp_ID = Q_W.Emp_Id
	where charindex(datename(dw,AM.For_Date),Q_W.weekoff_day,0) >0
	and Am.For_Date >=@From_Date and Am.For_Date <=@To_Date
*/	

	Update #Att_Muster 
	set WO_HO = 'W',
		WO_HO_Day =ew.W_Day
	From #Att_Muster   AM inner join #Emp_Weekoff ew on am.emp_ID = ew.emp_ID and am.For_date =ew.For_Date
	and W_Day > 0
	
									
	Update #Att_Muster
	set Status_2 ='CO'
	Where Status = 'P' and 	( WO_HO = 'W' or WO_HO = 'HO' )and WO_HO_Day =1
	and For_Date >=@From_Date and For_Date <=@To_Date

	Update #Att_Muster
	set Status_2 =WO_HO , P_days =0.5
	Where Status = 'P' and 	( WO_HO = 'W' or WO_HO = 'HO' )and WO_HO_Day =0.5
	and For_Date >=@From_Date and For_Date <=@To_Date

	
	Update #Att_Muster
	set Status =WO_HO
	Where isnull(Status,'') <> 'P' and ( WO_HO = 'HO' or WO_HO = 'W') 
	and For_Date >=@From_Date and For_Date <=@To_Date
	
	Update #Att_Muster
	set Status ='A'
	Where Status is null
	and For_Date >=@From_Date and For_Date <=@To_Date
	
	
	update #Att_Muster
	set Status = q.P_Days 
	from #Att_Muster AM inner join 
	(select Emp_Id ,sum(P_Days) as P_Days From #Att_Muster 
		Where Status = 'P' and For_Date>=@From_Date and For_DAte <=@to_Date 
		group by Emp_ID)Q on Am.Emp_ID = Q.Emp_ID
	where Row_ID = 32
	
	
	update #Att_Muster
	set Status = AB_Days
	from #Att_Muster AM inner join 
	(select Emp_Id ,count(Status) as AB_Days From #Att_Muster 
		Where Status = 'A' and For_Date>=@From_Date and For_DAte <=@to_Date 
		group by Emp_ID)Q on Am.Emp_ID = Q.Emp_ID
	where Row_ID = 33
	
	update #Att_Muster
	set Status = W_H_Days
	from #Att_Muster AM inner join 
	(select Emp_Id ,sum(WO_HO_Day) as W_H_Days From #Att_Muster 
		Where WO_HO_Day =1 and( Status = 'W'or Status ='HO' ) and For_Date>=@From_Date and For_DAte <=@to_Date 
		group by Emp_ID)Q on Am.Emp_ID = Q.Emp_ID
	where Row_ID = 35
	
	update #Att_Muster
	set Status = isnull(Status,0) + W_H_Days
	from #Att_Muster AM inner join 
	(select Emp_Id ,sum(WO_HO_Day) as W_H_Days From #Att_Muster 
		Where WO_HO_Day =0.5 and For_Date>=@From_Date and For_DAte <=@to_Date 
		group by Emp_ID)Q on Am.Emp_ID = Q.Emp_ID
	where Row_ID = 35
	
	
	CREATE table #P_Day
	(
       		   Present numeric(18,2),
	           WO_HO numeric(18,2),
	           Absent  numeric(18,2)
 	)
 	insert into #P_Day(Present,WO_HO,Absent)
 	select Status,0,0 from #Att_Muster where Row_ID=32 and emp_ID=@emp_ID and cmp_id=@Cmp_id
 	
	Update #P_Day
 	  set WO_HO = Status from #Att_Muster
 	where  Row_ID=35 and emp_ID=@emp_ID and cmp_id=@Cmp_id
 	
	Update #P_Day
 	  set Absent = Status from #Att_Muster
 	where Row_ID=33 and emp_ID=@emp_ID and cmp_id=@Cmp_id
 	
 	
 	Select * from #P_Day
	
	
	Select AM.* , E.Emp_code,E.Emp_full_Name ,Branch_Address,comp_name
		, Branch_Name , Dept_Name ,Grd_Name , Desig_Name,@From_Date as P_From_date ,@To_Date as P_To_Date 
	From #Att_Muster  AM Inner join T0080_EMP_MASTER E WITH (NOLOCK) ON AM.EMP_ID = E.EMP_ID
	
		
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
	Order by Emp_Code,Am.For_Date
	RETURN




