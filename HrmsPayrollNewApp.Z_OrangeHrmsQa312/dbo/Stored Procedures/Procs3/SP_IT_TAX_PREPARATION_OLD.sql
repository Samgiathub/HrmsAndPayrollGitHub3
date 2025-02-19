



---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_IT_TAX_PREPARATION_OLD]
	 @Cmp_ID				numeric
	,@From_Date				Datetime
	,@To_Date				Datetime
	,@Branch_ID				numeric 
	,@Cat_ID				numeric
	,@Grd_ID				numeric
	,@Type_ID				numeric
	,@Dept_ID				numeric
	,@Desig_Id				numeric 
	,@Emp_ID				numeric
	,@Constraint			varchar(4000)
	,@Product_ID			numeric 
	,@Taxable_Amount_Cond	numeric = 0  
	,@Format_Name			varchar(50) ='Format1'
	,@Form_ID				numeric =0
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @Cont_Basic_Sal		tinyint
	Declare @Cont_PT_Amount		tinyint 
	Declare @Cont_Total_Tax		tinyint 
	Declare @Cont_Surcharge		tinyint 
	Declare @Cont_Total_tax_Lia	tinyint 
	Declare @Cont_ED_Cess		tinyint 
	Declare @Cont_Net_Lia		tinyint 
	Declare @Cont_Tax			tinyint 
	Declare @Cont_Paid_Tax		tinyint 
	Declare @Cont_Due_Tax		tinyint 
	Declare @Cont_Annual_Sal	tinyint 
	Declare @Cont_HRA			tinyint 
	
	set @Cont_Basic_Sal		=1
	set @Cont_PT_Amount		=10
	set @Cont_Total_Tax		=101
	set @Cont_Surcharge		=102
	set @Cont_Total_tax_Lia	=103
	set @Cont_ED_Cess		=104
	set @Cont_Net_Lia		=105
	set @Cont_Tax			=106
	set @Cont_Paid_Tax		=107
	set @Cont_Due_Tax		=108
	set @Cont_Annual_Sal	=109
	set @Cont_HRA			=110


	
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
			and I.Emp_ID in 
				( select Emp_Id from
				(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
				where cmp_ID = @Cmp_ID   and  
				(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
				or ( @To_Date  >= join_Date  and @To_Date <= left_date )
				or Left_date is null and @To_Date >= Join_Date)
				or @To_Date >= left_date  and  @From_Date <= left_date ) 		
		end
	
	
	CREATE table #Tax_Report 
	  ( 
		T_ID						numeric identity(1,1),
		Emp_ID						numeric,
		Cmp_ID						numeric(18, 0) NOT NULL ,
		Format_Name					varchar (20) ,
		Row_ID						int NOT NULL ,
		Field_Name					varchar (100) ,
		AD_ID						numeric(18, 0) NULL ,
		Rimb_ID						numeric(18, 0) NULL ,
		Default_Def_Id				int NOT NULL ,
		Is_Total					tinyint NOT NULL ,
		From_Row_ID					int NOT NULL ,
		To_Row_ID					int NOT NULL ,
		Multiple_Row_ID				varchar (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
		Is_Exempted					tinyint NOT NULL ,
		Max_Limit					numeric(18, 0)	NOT NULL ,
		Max_Limit_Compare_Row_ID	int NOT NULL ,
		Max_Limit_Compare_Type		varchar (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
		Is_Proof_Req				tinyint NOT NULL ,
		IT_ID						numeric null,
		From_Date					Datetime ,
		To_Date						Datetime ,
		Amount_Col_1				numeric default 0,
		Amount_Col_2				numeric default 0,
		Amount_Col_3				numeric default 0,
		Amount_Col_4				numeric default 0,
		Amount_Col_Final			numeric default 0,
		Sal_No_Of_Month				int default 0,
		Field_Type					tinyint default 0,
		IT_Month					int ,
		IT_YEAR						int ,
		Increment_ID				numeric,
		IT_L_ID						numeric,
		Is_Show						tinyint default 1,
		Col_No						int 
	  )
	   	
		
	CREATE table #Tax_Report_Male
	  (
		 Auto_Row_Id	 int identity(1,1) ,
		 Field_Name		varchar(200),
		 Default_Def_Id	numeric,
		 T_F_Row_ID		INT ,
		 T_T_Row_ID		int ,
		 IT_Month		int,
		 IT_YEAR		int,
		 IT_L_ID		numeric
	   )
	 
	 CREATE table #Salary_AD
		(
			Cmp_ID					numeric,
			Emp_ID					numeric,
			AD_ID					numeric ,
			M_AD_Amount				numeric ,
			Month_Count				int,
			Old_M_AD_Amount			numeric,
			AD_NOT_EFFECT_ON_PT		TINYINT	Default 0,
			AD_NOT_EFFECT_ON_SAL	TINYINT Default 0,
			Month_Diff_Amount		numeric,
			For_Date				Datetime,
			Default_Def_ID			TINYINT default 0		
		)
	 
	Declare @Max_Row_ID numeric
	Declare @Max_From_Row_ID numeric
	Declare @T_For_Date	Datetime
	Declare @Increment_ID		numeric
	Declare @Month_Count		tinyint
	Declare @Month_Sal			tinyint
	Declare @Month_Diff			tinyint
	
	set @Month_Count = datediff(m,@From_Date,@To_Date) +1
	
	
	Insert Into #Tax_Report (Emp_ID,Cmp_ID,Format_Name,Row_ID,Field_Name,AD_ID,Rimb_ID,Default_Def_Id,Is_Total,From_Row_ID,To_Row_ID,Multiple_Row_ID,Is_Exempted,Max_Limit
								,Max_Limit_Compare_Row_ID,Max_Limit_Compare_Type,Is_Proof_Req,IT_ID,From_Date,To_Date,Field_Type,Is_Show,Col_No)
	select Emp_ID,Cmp_ID,Format_Name,Row_ID,Field_Name,AD_ID,Rimb_ID,Default_Def_Id,Is_Total,From_Row_ID,To_Row_ID,Multiple_Row_ID,Is_Exempted,Max_Limit
								,Max_Limit_Compare_Row_ID,Max_Limit_Compare_Type,Is_Proof_Req,IT_ID,@From_Date,@To_Date ,Field_Type,Is_Show,Col_No From T0100_IT_FORM_DESIGN WITH (NOLOCK) cross join @Emp_Cons ec 
	Where isnull(Form_ID,0) = @Form_ID						
								
	
	
	insert into #Tax_Report_Male (Field_Name,Default_def_ID)
	select ' ',0	
		 
	insert into #Tax_Report_Male (Field_Name,Default_def_ID)
	select 'Tax Limit ',0
	
	insert into #Tax_Report_Male (Field_Name,Default_def_ID)
	select ' ',0
		 
/*	insert into #Tax_Report_Male (Field_Name,Default_def_ID)
	
	select cast(From_Limit as varchar(15)) + ' To ' +  cast(TO_Limit as varchar(10)),0   from T0040_tAx_limit t inner join
	( select cmp_ID , max(for_Date) For_Date from T0040_tAx_limit 
		where cmp_ID= @Cmp_ID and For_Date <=@To_Date and gender ='M' group by cmp_ID)q on t.cmp_ID =q.cmp_ID and T.for_Date =q.for_Date and gender ='M'


	insert into #Tax_Report_Male (Field_Name,Default_def_ID)
	select ' ',0 
	
	insert into #Tax_Report_Male (Field_Name,Default_def_ID)
	select 'Tax Liabilities ',0
*/

	insert into #Tax_Report_Male (Field_Name,Default_def_ID)
	select ' ',0

	insert into #Tax_Report_Male (Field_Name,Default_def_ID,IT_L_ID)
	
	select cast(From_Limit as varchar(15)) + ' To ' +  cast(TO_Limit as varchar(15)) + ' ( ' +  cast(Percentage as varchar(10))+ ' %) ' ,0,IT_L_ID   
	From T0040_tAx_limit t WITH (NOLOCK) inner join
	( select cmp_ID , max(for_Date) For_Date from T0040_tAx_limit WITH (NOLOCK)
		where cmp_ID= @Cmp_ID and For_Date <=@To_Date and gender ='M' group by cmp_ID)q on t.cmp_ID =q.cmp_ID and T.for_Date =q.for_Date and gender ='M'
	
	insert into #Tax_Report_Male (Field_Name,Default_def_ID)
	select ' ',0
	
	insert into #Tax_Report_Male (Field_Name,Default_def_ID,IT_L_ID)
	select cast(From_Limit as varchar(15)) + ' To ' +  cast(TO_Limit as varchar(15)) + ' ( ' +  cast(Percentage as varchar(10))+ ' %) ' ,0,IT_L_ID   
	From T0040_tAx_limit t WITH (NOLOCK) inner join
	( select cmp_ID , max(for_Date) For_Date from T0040_tAx_limit WITH (NOLOCK)
		where cmp_ID= @Cmp_ID and For_Date <=@To_Date and gender ='F' group by cmp_ID)q on t.cmp_ID =q.cmp_ID and T.for_Date =q.for_Date and gender ='F'


	insert into #Tax_Report_Male (Field_Name,Default_def_ID)
	select 'Total Tax ',101
	insert into #Tax_Report_Male (Field_Name,Default_def_ID)
	select 'Surcharge @10% on Tax ',102
	insert into #Tax_Report_Male (Field_Name,Default_def_ID)
	select 'Total Tax Liabilities',103
	insert into #Tax_Report_Male (Field_Name,Default_def_ID)
	select 'Ed. Cess 2%',104
	insert into #Tax_Report_Male (Field_Name,Default_def_ID)
	select 'Net Tax Liabilities',105

	insert into #Tax_Report_Male (Field_Name,Default_def_ID)
	select ' ',0
	insert into #Tax_Report_Male (Field_Name,Default_def_ID)
	select 'Income Tax ',106

	select @Max_Row_ID = isnull(max(AUTO_Row_ID),0) + 1  From  #Tax_Report_Male
	set @Max_From_Row_ID = @Max_Row_ID
	set @T_For_Date = @From_Date
	while @T_For_Date <=@To_Date 
		begin
				insert into #Tax_Report_Male (Field_Name,Default_def_ID,IT_Month,IT_YEAR)
				select datename(m,@T_For_Date),0,month(@T_For_Date),Year(@T_For_Date)
				
			set @T_For_Date = dateadd(m,1,@T_For_Date)
			SET @Max_Row_ID = @Max_Row_ID + 1
		end
	
	insert into #Tax_Report_Male (Field_Name,Default_def_ID,T_F_Row_ID,T_T_Row_ID)
	select 'TOTAL PAID INCOME TAX ',107,@Max_From_Row_ID,@Max_Row_ID-1

	insert into #Tax_Report_Male (Field_Name,Default_def_ID)
	select 'Due Income Tax ',108


	insert into #Tax_Report_Male (Field_Name,Default_def_ID)
	select 'HOUSE RENT ALLOWANCE EXEMPT',0
	
	insert into #Tax_Report_Male (Field_Name,Default_def_ID)
	select 'Annual Salary ( Exclusive benefits and Perquisites)',109

	insert into #Tax_Report_Male (Field_Name,Default_def_ID)
	select 'House Rent Allowance Received',110

	insert into #Tax_Report_Male (Field_Name,Default_def_ID)
	select 'Less : Exemption u/s 10 (13A) read with rule 2 A',0

	insert into #Tax_Report_Male (Field_Name,Default_def_ID)
	select '  A ) House rent allowance Received',110
	insert into #Tax_Report_Male (Field_Name,Default_def_ID)
	select '  B ) Actual Rent Paid',112
	insert into #Tax_Report_Male (Field_Name,Default_def_ID)
	select '   Less : 1/10 of Salary',113
	insert into #Tax_Report_Male (Field_Name,Default_def_ID)
	select '   Different Amount',114
	insert into #Tax_Report_Male (Field_Name,Default_def_ID)
	select '  C ) Two Fifth of Salary',115

	insert into #Tax_Report_Male (Field_Name,Default_def_ID)
	select 'House rent Allow. Exempted ( least of a,b or c )',7

	
	select @Max_Row_ID = isnull(max(Row_ID),0) + 1  From  #Tax_Report
	
	Insert Into #Tax_Report (Emp_ID,Cmp_ID,Format_Name,Row_ID,Field_Name,AD_ID,Rimb_ID,Default_Def_Id,Is_Total,From_Row_ID,To_Row_ID,Multiple_Row_ID,Is_Exempted,Max_Limit
								,Max_Limit_Compare_Row_ID,Max_Limit_Compare_Type,Is_Proof_Req,IT_ID,From_Date,To_Date,IT_Month,IT_YEAR,IT_L_ID)
	select Emp_ID,@Cmp_ID,@Format_Name,Auto_Row_Id + @Max_Row_ID ,Field_Name,null,null,Default_Def_Id,0,isnull(T_F_Row_ID + @Max_Row_ID,0) ,isnull(T_T_Row_ID + @Max_Row_ID,0),'',0,0
								,0,0,0,null,@From_Date,@To_Date,IT_Month,IT_Year,IT_L_ID From #Tax_Report_Male cross join @Emp_Cons
	

	Update #Tax_Report 
	set Increment_ID = Q.Increment_ID 
	from #Tax_Report t inner join 
	(select I.Emp_Id ,Increment_ID from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	
			Where Cmp_ID = @Cmp_ID )Q on t.emp_ID =q.Emp_ID 

	
	
------------------ Allowance Exemption ---------------

	DECLARE CUR_AD_Tax CURSOR FOR 
		SELECT Distinct EMP_ID ,Increment_ID FROM #Tax_Report 	
	OPEN CUR_AD_Tax 
	FETCH NEXT FROM CUR_AD_Tax INTO @EMP_ID ,@Increment_ID
	WHILE @@FETCH_STATUS =0
		BEGIN
			set @Month_Sal =0
			select @Month_Sal = isnull(count(emp_ID),0) From T0200_Monthly_Salary WITH (NOLOCK) where Emp_ID=@emp_ID and Month_St_Date >=@From_Date and Month_st_Date <=@To_Date
			if @Month_Count -( @Month_Sal + 1 ) > 0
				set @Month_Diff = @Month_Count -( @Month_Sal + 1 )
			else 
				set @Month_Diff =0
			
			Exec dbo.SP_IT_TAX_ALLOW_DEDU_CALCULATION @emp_ID,@Cmp_ID,@Increment_ID,@From_Date,@To_Date,@Month_Diff
			Exec SP_IT_TAX_ALLOWANCE_EXEMPT_GET @Emp_ID,@Cmp_Id,@Increment_ID,@From_Date,@To_Date,@Month_Count,0
			FETCH NEXT FROM CUR_AD_Tax INTO @EMP_ID ,@Increment_ID		
		END
	CLOSE CUR_AD_Tax
	DEALLOCATE CUR_AD_Tax
		
	-------------------End Allowance	   ---------------
	
update #Tax_Report
	set Amount_Col_Final = Max_Limit 
	where Is_Exempted = 0 and max_Limit_Compare_Row_ID =0
	
	UPdate #Tax_Report 
	set Sal_No_Of_Month = E_COUNT
	From #Tax_Report Tr inner join (  SELECT MS.EMP_ID ,COUNT(MS.EMP_ID)E_COUNT FROM 
											T0200_MONTHLY_SALARY MS WITH (NOLOCK) INNER JOIN @EMP_CONS EC ON MS.EMP_ID = EC.EMP_ID 
											WHERE MS.MONTH_sT_DATE >=@FROM_DATE AND MS.MONTH_ST_DATE <=@TO_DATE 
										GROUP BY MS.EMP_ID ) Q ON TR.EMP_ID =Q.EMP_ID
	
	UPdate #Tax_Report 
	set Amount_Col_Final = isnull(M_AD_Amount,0) + isnull(Old_M_AD_Amount,0) + isnull(Month_Diff_Amount,0)
	From #Tax_Report Tr inner join #Salary_AD sa on tr.Emp_ID =sa.Emp_ID and sa.Default_Def_ID = @Cont_Basic_Sal
	WHERE tr.DEFAULT_DEF_ID =@Cont_Basic_Sal
	 
	UPdate #Tax_Report 
	set Amount_Col_Final = isnull(M_AD_Amount,0) + isnull(Old_M_AD_Amount,0) + isnull(Month_Diff_Amount,0)
	From #Tax_Report Tr inner join #Salary_AD sa on tr.Emp_ID =sa.Emp_ID and sa.Default_Def_ID = @Cont_PT_Amount
	WHERE tr.DEFAULT_DEF_ID = @Cont_PT_Amount

	UPdate #Tax_Report 
	set Amount_Col_Final = isnull(M_AD_Amount,0) + isnull(Old_M_AD_Amount,0) + isnull(Month_Diff_Amount,0)
	From #Tax_Report Tr inner join #Salary_AD sa on tr.Emp_ID =sa.Emp_ID and tr.AD_ID = sa.aD_ID
	

	UPdate #Tax_Report 
	set Amount_Col_Final = AMOUNT
	From #Tax_Report Tr inner join (  SELECT ITD.EMP_ID,IT_ID ,SUM(ITD.AMOUNT)AMOUNT FROM 
											T0100_IT_DECLARATION ITD WITH (NOLOCK) INNER JOIN @EMP_CONS EC ON ITD.EMP_ID = EC.EMP_ID 
											WHERE ITD.FOR_DATE >=@FROM_DATE AND ITD.FOR_DATE <=@TO_DATE 
										GROUP BY ITD.EMP_ID,IT_ID ) Q ON TR.EMP_ID =Q.EMP_ID AND TR.IT_ID = Q.IT_ID

	
	
	Declare @IS_TOTAL int 
	Declare @ROW_ID	  int 
	Declare @From_Row_ID int 
	Declare @TO_ROW_ID	int 
	Declare @Multiple_Row_ID	varchar(100)
	Declare @Max_Limit			numeric(18, 0)
	Declare @Max_Limit_Compare_Row_ID	int 
	Declare @Max_Limit_Compare_Type		varchar(20)
	Declare @sqlQuery as nvarchar(4000)
		
	DECLARE CUR_T CURSOR FOR 
		SELECT IS_TOTAL ,ROW_ID ,From_Row_ID ,TO_ROW_ID,Multiple_Row_ID,Max_Limit,Max_Limit_Compare_Row_ID,
				Max_Limit_Compare_Type 
		FROM #Tax_Report  WHERE IS_TOTAL > 0
		
	OPEN CUR_T 
	FETCH NEXT FROM CUR_t INTO @Is_Total,@ROW_ID ,@FROM_ROW_ID,@To_row_ID,@Multiple_Row_ID,@Max_Limit,@Max_Limit_Compare_Row_ID,@Max_Limit_Compare_Type 
	while @@fetch_status =0
		begin
			set @sqlQuery =''
			if @is_Total =1 and @FROM_ROW_ID > 0 and @To_row_ID > 0 
				begin
					update #Tax_Report
					set Amount_Col_Final =isnull(Q.sum_amount,0)
					from #Tax_Report t inner join (select Emp_ID ,sum(Amount_Col_Final)Sum_amount From #Tax_Report where
						Row_ID >=@From_Row_ID and Row_ID <=@To_Row_ID group by Emp_ID )Q  on t.emp_ID =q.Emp_ID and t.Row_ID =@Row_ID							
																
				end
			else if @is_Total =1  and rtrim(@Multiple_Row_ID) <> ''
				begin

						update #Tax_Report
									set Amount_Col_Final =isnull(Q.sum_amount,0)
									from #Tax_Report t inner join (select Emp_ID ,sum(Amount_Col_Final)Sum_amount From #Tax_Report where
									Row_ID in (select Data From dbo.Split(@Multiple_Row_ID,'#') where Data >0) group by Emp_ID )Q  on t.emp_ID =q.Emp_ID and t.Row_ID =@Row_ID 
									
	--				set @sqlQuery = 'update #Tax_Report
	--								set Amount_Col_Final =isnull(Q.sum_amount,0)
	--								from #Tax_Report t inner join (select Emp_ID ,sum(Amount_Col_Final)Sum_amount From #Tax_Report where
	--								Row_ID in (' + @Multiple_Row_ID + ') group by Emp_ID )Q  on t.emp_ID =q.Emp_ID and t.Row_ID =@Row_ID '
					
	--				execute sp_executesql @sqlQuery , N'@Multiple_Row_ID varchar(200),@Row_ID int',@Multiple_Row_ID,@Row_ID
				end
			else if @is_Total =2 and @FROM_ROW_ID > 0 and @To_row_ID > 0 
				begin
					update #Tax_Report
					set Amount_Col_Final =isnull(Q.First_Amount,0) - isnull(Q1.Second_Amount,0)
					from #Tax_Report t inner join (select Emp_ID ,Amount_Col_Final as First_Amount  From #Tax_Report where
						Row_ID =@From_Row_ID )Q  on t.emp_ID =q.Emp_ID 
						inner join (select Emp_ID ,Amount_Col_Final as Second_Amount  From #Tax_Report where
						Row_ID =@To_row_ID )Q1  on t.emp_ID =Q1.Emp_ID 
					Where t.Row_ID =@Row_ID													
																
				end
			else if @is_Total = 3 and @FROM_ROW_ID > 0 and @To_row_ID > 0 and @Max_Limit > 0
				begin
					
					update #Tax_Report
					set Amount_Col_Final = 
					case when isnull(Q.Sum_amount,0)  <=   @Max_Limit Then
								isnull(Q.Sum_amount,0)
						else
								@Max_Limit
						end 
					from #Tax_Report t inner join  (select Emp_ID ,sum(Amount_Col_Final)Sum_amount From #Tax_Report where
						Row_ID >=@From_Row_ID and Row_ID <=@To_Row_ID group by Emp_ID )Q  on t.emp_ID =q.Emp_ID
					Where t.Row_ID =@Row_ID													
																
				end
			else if @is_Total = 3 and @FROM_ROW_ID > 0 and @To_row_ID > 0 
				begin
					update #Tax_Report
					set Amount_Col_Final =
					case when isnull(Q.First_Amount,0)  <=   isnull(Q1.Second_Amount,0) Then
								isnull(Q.First_Amount,0)
						else
								isnull(Q1.Second_Amount,0)
						end 
					from #Tax_Report t inner join (select Emp_ID ,Amount_Col_Final as First_Amount  From #Tax_Report where
						Row_ID =@From_Row_ID )Q  on t.emp_ID =q.Emp_ID 
						inner join (select Emp_ID ,Amount_Col_Final as Second_Amount  From #Tax_Report where
						Row_ID =@To_row_ID )Q1  on t.emp_ID =Q1.Emp_ID 
					Where t.Row_ID =@Row_ID													
																
				end
			
			FETCH NEXT FROM CUR_t INTO @Is_Total,@ROW_ID ,@FROM_ROW_ID,@To_row_ID,@Multiple_Row_ID,@Max_Limit,@Max_Limit_Compare_Row_ID,@Max_Limit_Compare_Type
		end
	close cur_T 
	deallocate Cur_T 
	
				
	
	update #Tax_Report 
	set Amount_Col_Final = M_AD_Amount 
	from #Tax_Report  t inner join T0210_Monthly_AD_Detail mad on t.emp_ID =mad.Emp_ID 
		and t.IT_Month = month(Mad.For_Date) and t.IT_Year = Year(Mad.For_Date) inner join
		T0050_AD_MAster am on mad.AD_ID= am.AD_ID and AD_DEF_ID = 1
	
	
	
	Update #Tax_Report 
	set Increment_ID = Q.Increment_ID 
	from #Tax_Report t inner join 
	(select I.Emp_Id ,Increment_ID from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	
			Where Cmp_ID = @Cmp_ID )Q on t.emp_ID =q.Emp_ID 
	
	DECLARE @TAXABLE_AMOUNT		NUMERIC 
	Declare @Return_Tax_Amount	numeric 
	Declare @Surcharge_amount	numeric 
	Declare @ED_Cess			numeric 
	Declare @M_AD_Amount		numeric 
	DECLARE CUR_TAX CURSOR FOR 
		SELECT EMP_ID ,Amount_Col_Final,Increment_ID FROM #Tax_Report 	Where field_type = 2	
	OPEN CUR_TAX 
	FETCH NEXT FROM CUR_TAX INTO @EMP_ID ,@TAXABLE_AMOUNT,@Increment_ID
	WHILE @@FETCH_STATUS =0
		BEGIN
			set @Return_Tax_Amount	=0
			set @Surcharge_amount	=0 
			set @ED_Cess			=0

			
			Exec dbo.SP_IT_TAX_CALCULATION @Cmp_ID,@Emp_ID,@To_Date,@TAXABLE_AMOUNT ,	@Return_Tax_Amount output 
							,@Surcharge_amount output ,@ED_Cess output 

			Update #Tax_Report 
			set Amount_Col_Final = @Return_Tax_Amount 
			where Emp_ID =@Emp_ID and Default_Def_ID = @Cont_Total_Tax
							
			Update #Tax_Report 
			set Amount_Col_Final = @Surcharge_amount 
			where Emp_ID =@Emp_ID and Default_Def_ID = @Cont_Surcharge
			set @Return_Tax_Amount = @Return_Tax_Amount + @Surcharge_amount
			Update #Tax_Report 
			set Amount_Col_Final = @Return_Tax_Amount
			where Emp_ID =@Emp_ID and Default_Def_ID = @Cont_Total_tax_Lia

			Update #Tax_Report 
			set Amount_Col_Final = @ED_Cess 
			where Emp_ID =@Emp_ID and Default_Def_ID = @Cont_ED_Cess

			set @Return_Tax_Amount  = @Return_Tax_Amount + @ED_Cess
			Update #Tax_Report 
			set Amount_Col_Final = @Return_Tax_Amount 
			where Emp_ID =@Emp_ID and (Default_Def_ID = @Cont_Net_Lia or Default_Def_ID = @Cont_Tax )

			set @M_AD_Amount = 0
			select @M_AD_Amount = isnull(sum(M_AD_Amount),0)  from T0210_Monthly_AD_Detail mad WITH (NOLOCK) inner join
					T0050_AD_MAster am WITH (NOLOCK) on mad.AD_ID= am.AD_ID and AD_DEF_ID = 1
			Where Emp_ID =@Emp_ID and For_Date >=@From_Date and for_Date <=@To_Date
		
			Update #Tax_Report 
			set Amount_Col_Final = @M_AD_Amount 
			where Emp_ID =@Emp_ID and (Default_Def_ID = @Cont_Paid_Tax )

			Update #Tax_Report 
			set Amount_Col_Final = @Return_Tax_Amount - @M_AD_Amount 
			where Emp_ID =@Emp_ID and (Default_Def_ID = @Cont_Due_Tax )

		
			FETCH NEXT FROM CUR_TAX INTO @EMP_ID ,@TAXABLE_AMOUNT,@Increment_ID		
		END
	CLOSE CUR_TAX
	DEALLOCATE CUR_TAX 

	UPdate #Tax_Report 
	set Amount_Col_Final = SALARY_AMOUNT
	From #Tax_Report Tr inner join (  SELECT MS.EMP_ID ,SUM(MS.SALARY_AMOUNT)SALARY_AMOUNT FROM 
											T0200_MONTHLY_SALARY MS WITH (NOLOCK) INNER JOIN @EMP_CONS EC ON MS.EMP_ID = EC.EMP_ID 
											WHERE MS.MONTH_sT_DATE >=@FROM_DATE AND MS.MONTH_ST_DATE <=@TO_DATE 
										GROUP BY MS.EMP_ID ) Q ON TR.EMP_ID =Q.EMP_ID
	WHERE DEFAULT_DEF_ID =@Cont_Annual_Sal

	Update #Tax_Report
	set Amount_col_1 = Amount_Col_Final
	Where isnull(Col_No,0) in(0,1 )
		
	Update #Tax_Report
	set Amount_col_2 = Amount_Col_Final
	Where isnull(Col_No,0) =2

	Update #Tax_Report
	set Amount_col_3 = Amount_Col_Final
	Where isnull(Col_No,0) =3

	Update #Tax_Report
	set Amount_col_4 = Amount_Col_Final
	Where isnull(Col_No,0) =4


	--select * from #Tax_Report_Male
	select  Row_ID 	,FIELD_NAME,Amount_Col_Final,Amount_Col_1,Amount_Col_2,Amount_Col_3,Amount_Col_4,Default_def_ID,AD_ID,IT_ID 
			,tr.Emp_ID,em.Emp_Code,em.Emp_Full_Name,@From_Date P_From_Date ,@To_Date P_To_Date
			,Col_No
	From #Tax_Report tr left outer join T0080_EMP_MASTER EM WITH (NOLOCK) ON TR.EMP_ID = EM.EMP_ID
	--Where Is_Show =1
	order by tr.Emp_ID ,tr.Row_ID
	
	
	
	RETURN




