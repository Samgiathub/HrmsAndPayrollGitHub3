



---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_IT_EMPLOYEE_GET]
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
	,@Constraint			varchar(max)
	,@Product_ID			numeric =0
	,@Taxable_Amount_Cond	numeric = 0  
	,@Format_Name			varchar(50) ='Format1'
	,@Form_ID				numeric =0
	,@Sp_Call_For			varchar(30) =''
	,@Month_En_Date			Datetime =null 
	,@Month_St_Date			Datetime = null
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @Cont_Basic_Sal tinyint
	Declare @Cont_PT_Amount tinyint 
	Declare @Cont_Total_Tax tinyint 
	Declare @Cont_Surcharge		tinyint 
	Declare @Cont_Total_tax_Lia	tinyint 
	Declare @Cont_ED_Cess	tinyint 
	Declare @Cont_Net_Lia	tinyint 
	Declare @Cont_Tax		tinyint 
	Declare @Cont_Paid_Tax		tinyint 
	Declare @Cont_Due_Tax		tinyint 
	Declare @Cont_Annual_Sal		tinyint 
	Declare @Cont_HRA			tinyint 
	
	set @Cont_Basic_Sal =1
	set @Cont_PT_Amount =10
	set @Cont_Total_Tax =101
	set @Cont_Surcharge		=102
	set @Cont_Total_tax_Lia	=103
	set @Cont_ED_Cess	=104
	set @Cont_Net_Lia	=105
	set @Cont_Tax		=106
	set @Cont_Paid_Tax		=107
	set @Cont_Due_Tax		=108
	set @Cont_Annual_Sal	=109
	set @Cont_HRA			=110
	
	if isnull(@Month_En_Date,'') = ''
		begin
			set @Month_En_Date = @To_Date
		end 
	if isnull(@Month_St_Date,'') =''
		begin
			set @Month_St_Date = @From_Date
		end
	

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
				(select emp_id, cmp_ID, join_Date, isnull(left_Date, @Month_En_Date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
				where cmp_ID = @Cmp_ID   and  
				(( @Month_St_Date  >= join_Date  and  @Month_St_Date <= left_date ) 
				or ( @Month_En_Date  >= join_Date  and @Month_En_Date <= left_date )
				or Left_date is null and @Month_En_Date >= Join_Date)
				or @Month_En_Date >= left_date  and  @Month_St_Date <= left_date ) 		
		end
	 IF	EXISTS (SELECT * FROM [tempdb].dbo.sysobjects where name like '#Tax_Report' )		
			BEGIN
				DROP TABLE #Tax_Report
			END
			
	IF EXISTS(SELECT * FROM [TEMPDB].DBO.SYSOBJECTS WHERE NAME LIKE '#Tax_Report_Male')
	    BEGIN
	        DROP TABLE #Tax_Report_Male
	    END	
	    
	 IF EXISTS(SELECT * FROM [TEMPDB].DBO.SYSOBJECTS WHERE NAME LIKE '#Salary_AD')
	    BEGIN
	        DROP TABLE #Salary_AD
	    END		
	
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
		Is_Show						tinyint default 0,
		Col_No						int ,
		Concate_Space				tinyint default 0,
		Is_Salary_comp				tinyint default 0,
		Exem_Againt_row_Id			int default 0,
		Exempted_Amount				numeric default 0,
		Is_TaxPaid_Rec				tinyint default 0,
		Y_IT_Paid_Amount			numeric default 0,
		Y_Edu_Cess_Amount			numeric default 0,
		Y_Surcharge_Amount			numeric default 0,
		M_IT_Amount					numeric default 0,
		M_Edu_Cess_Amount			numeric default 0,
		M_Surcharge_Amount			numeric default 0,
		Month_Count					numeric default 0,
		Total_TAxable_Amount		numeric default 0,
		Final_Tax					numeric default 0,
		Total_Amount				numeric default 0,
		Incentive_Tax               numeric(18, 0),
		Incentive_Tax_Amount        numeric(18, 0),
		Is_Incentive                tinyint
	  )
	Create CLUSTERED INDEX ind_temp1	ON #Tax_Report(T_ID)
	Create NONCLUSTERED INDEX ind_temp2 ON #Tax_Report(Row_ID)
	Create NONCLUSTERED INDEX ind_temp3 ON #Tax_Report(Emp_ID)
	Create NONCLUSTERED INDEX ind_temp4 ON #Tax_Report(Field_Name)
	Create NONCLUSTERED INDEX ind_temp5 ON #Tax_Report(Cmp_ID)
	   	
		
	CREATE table #Tax_Report_Male
	  (
		 Auto_Row_Id	 int identity(1,1) ,
		 Field_Name		varchar(200),
		 Default_Def_Id	numeric,
		 T_F_Row_ID		INT ,
		 T_T_Row_ID		int ,
		 IT_Month		int,
		 IT_YEAR		int,
		 IT_L_ID		numeric,
		 Is_Show		tinyint default 1,
		 Is_TaxPaid_Rec  tinyint default 0	
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
			Ad_Effect_On_TDS        TINYINT default 0,
			Month_Diff_Amount		numeric,
			For_Date				Datetime,
			Default_Def_ID			TINYINT default 0,
			
			
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
								,Max_Limit_Compare_Row_ID,Max_Limit_Compare_Type,Is_Proof_Req,IT_ID,From_Date,To_Date,Field_Type,Is_Show,Col_No,Concate_Space
								,Is_Salary_comp,Exem_Againt_row_Id,Exempted_Amount)
	

	select Emp_ID,Cmp_ID,Format_Name,Row_ID,Field_Name,AD_ID,Rimb_ID,Default_Def_Id,Is_Total,From_Row_ID,To_Row_ID,Multiple_Row_ID,Is_Exempted,Max_Limit
								,Max_Limit_Compare_Row_ID,Max_Limit_Compare_Type,Is_Proof_Req,IT_ID,@From_Date,@To_Date ,Field_Type,Is_Show,Col_No,isnull(Concate_Space,0) 
								,isnull(Is_Salary_comp,0),isnull(Exem_Againt_row_Id,0),0
								From T0100_IT_FORM_DESIGN WITH (NOLOCK) cross join @Emp_Cons ec 
	Where isnull(Form_ID,0) = @Form_ID and Cmp_Id=@Cmp_ID 				
								

			
	insert into #Tax_Report_Male (Field_Name,Default_def_ID,Is_show)
	select ' ',0,0	
		 
	insert into #Tax_Report_Male (Field_Name,Default_def_ID,Is_show)
	select 'Tax Limit ',0,0
	
	insert into #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	select ' ',0,0
		 
/* insert into #Tax_Report_Male (Field_Name,Default_def_ID)	
	
	select cast(From_Limit as varchar(15)) + ' To ' +  cast(TO_Limit as varchar(10)),0   from T0040_tAx_limit t inner join
	( select cmp_ID , max(for_Date) For_Date from T0040_tAx_limit 
		where cmp_ID= @Cmp_ID and For_Date <=@To_Date and gender ='M' group by cmp_ID)q on t.cmp_ID =q.cmp_ID and T.for_Date =q.for_Date and gender ='M'
	insert into #Tax_Report_Male (Field_Name,Default_def_ID)
	select ' ',0 
	
	insert into #Tax_Report_Male (Field_Name,Default_def_ID)
	select 'Tax Liabilities ',0
*/

	insert into #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	select ' ',0,0

	insert into #Tax_Report_Male (Field_Name,Default_def_ID,IT_L_ID,IS_Show)
	
	select cast(From_Limit as varchar(15)) + ' To ' +  cast(TO_Limit as varchar(15)) + ' ( ' +  cast(Percentage as varchar(10))+ ' %) ' ,0,IT_L_ID ,0  
	From T0040_tAx_limit t WITH (NOLOCK) inner join
	( select cmp_ID , max(for_Date) For_Date from T0040_tAx_limit WITH (NOLOCK)
		where cmp_ID= @Cmp_ID and For_Date <=@To_Date and gender ='M' group by cmp_ID)q on t.cmp_ID =q.cmp_ID and T.for_Date =q.for_Date and gender ='M'
	
	insert into #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	select ' ',0,0
	
	insert into #Tax_Report_Male (Field_Name,Default_def_ID,IT_L_ID,Is_show)
	
	select cast(From_Limit as varchar(15)) + ' To ' +  cast(TO_Limit as varchar(15)) + ' ( ' +  cast(Percentage as varchar(10))+ ' %) ' ,0,IT_L_ID ,0  
	From T0040_tAx_limit t WITH (NOLOCK) inner join
	( select cmp_ID , max(for_Date) For_Date from T0040_tAx_limit WITH (NOLOCK)
		where cmp_ID= @Cmp_ID and For_Date <=@To_Date and gender ='F' group by cmp_ID)q on t.cmp_ID =q.cmp_ID and T.for_Date =q.for_Date and gender ='F'


	insert into #Tax_Report_Male (Field_Name,Default_def_ID)
	select 'Tax on Income ',101
	insert into #Tax_Report_Male (Field_Name,Default_def_ID)
	select 'Surcharge @10% on Tax ',102
	insert into #Tax_Report_Male (Field_Name,Default_def_ID)
	select 'Total Tax Liabilities',103
	insert into #Tax_Report_Male (Field_Name,Default_def_ID)
	select 'Ed. Cess 2%',104
	insert into #Tax_Report_Male (Field_Name,Default_def_ID)
	select 'Tax Payable',105

	insert into #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	select ' ',0,0
	insert into #Tax_Report_Male (Field_Name,Default_def_ID,is_show)
	select 'Income Tax ',106,0

	select @Max_Row_ID = isnull(max(AUTO_Row_ID),0) + 1  From  #Tax_Report_Male
	set @Max_From_Row_ID = @Max_Row_ID
	set @T_For_Date = @From_Date
	while @T_For_Date <=@To_Date 
		begin
				insert into #Tax_Report_Male (Field_Name,Default_def_ID,IT_Month,IT_YEAR,Is_Show,Is_TaxPaid_Rec	)
				select datename(m,@T_For_Date),0,month(@T_For_Date),Year(@T_For_Date),0,1
				
			set @T_For_Date = dateadd(m,1,@T_For_Date)
			SET @Max_Row_ID = @Max_Row_ID + 1
		end
	
	insert into #Tax_Report_Male (Field_Name,Default_def_ID,T_F_Row_ID,T_T_Row_ID)
	select 'Relief Under section 89 (attach details)',107,@Max_From_Row_ID,@Max_Row_ID-1

	insert into #Tax_Report_Male (Field_Name,Default_def_ID)
	select 'TAX PAYABLE / (REFUNDABLE )',108


	insert into #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	select 'HOUSE RENT ALLOWANCE EXEMPT',0,0
	
	insert into #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	select 'Annual Salary ( Exclusive benefits and Perquisites)',109,0

	insert into #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	select 'House Rent Allowance Received',110,0

	insert into #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	select 'Less : Exemption u/s 10 (13A) read with rule 2 A',0,0

	insert into #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	select '  A ) House rent allowance Received',110,0
	insert into #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	select '  B ) Actual Rent Paid',112,0
	insert into #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	select '   Less : 1/10 of Salary',113,0
	insert into #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	select '   Different Amount',114,0
	insert into #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	select '  C ) Two Fifth of Salary',115,0

	insert into #Tax_Report_Male (Field_Name,Default_def_ID,Is_Show)
	select 'House rent Allow. Exempted ( least of a,b or c )',7,0

	
	select @Max_Row_ID = isnull(max(Row_ID),0) + 1  From  #Tax_Report
	
	Insert Into #Tax_Report (Emp_ID,Cmp_ID,Format_Name,Row_ID,Field_Name,AD_ID,Rimb_ID,Default_Def_Id,Is_Total,From_Row_ID,To_Row_ID,Multiple_Row_ID,Is_Exempted,Max_Limit
								,Max_Limit_Compare_Row_ID,Max_Limit_Compare_Type,Is_Proof_Req,IT_ID,From_Date,To_Date,IT_Month,IT_YEAR,IT_L_ID,Is_Show,Is_TaxPaid_Rec)
	select Emp_ID,@Cmp_ID,@Format_Name,Auto_Row_Id + @Max_Row_ID ,Field_Name,null,null,Default_Def_Id,0,isnull(T_F_Row_ID + @Max_Row_ID,0) ,isnull(T_T_Row_ID + @Max_Row_ID,0),'',0,0
								,0,0,0,null,@From_Date,@To_Date,IT_Month,IT_Year,IT_L_ID,Is_Show ,Is_TaxPaid_Rec From #Tax_Report_Male cross join @Emp_Cons
	
	

Update #Tax_Report
	set Month_Count =  case when Date_OF_Join > @From_date  and isnull(Emp_Left_Date,@To_Date) >=@To_Date  then 
								datediff(m,Date_OF_Join,@To_Date) +1 
							when Date_OF_Join > @From_date  and isnull(Emp_Left_Date,@To_Date) < @To_Date  then 
								datediff(m,Date_OF_Join,Emp_Left_Date) +1 	
							when Date_OF_Join <= @From_date  and isnull(Emp_Left_Date,@To_Date) < @To_Date  then 
								datediff(m,@From_date,Emp_Left_Date) +1 	
							else
								datediff(m,@From_Date,@To_Date) +1
							end
							
	From #Tax_Report t inner join T0080_emp_Master e on t.Emp_ID =e.Emp_ID  
	Where Month_count = 0

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
		SELECT Distinct EMP_ID ,Increment_ID,Month_Count FROM #Tax_Report 	
	OPEN CUR_AD_Tax 
	FETCH NEXT FROM CUR_AD_Tax INTO @EMP_ID ,@Increment_ID,@Month_Count
	WHILE @@FETCH_STATUS =0
		BEGIN
                       
			set @Month_Sal =0
		
			select @Month_Sal = isnull(count(emp_ID),0) From T0200_Monthly_Salary WITH (NOLOCK) where Emp_ID=@emp_ID and Month_St_Date >=@From_Date and Month_st_Date <=@To_Date and Month_St_Date <=@Month_En_Date
			
		
			if @Month_Count -( @Month_Sal ) > 0
                               Begin 
									set @Month_Diff = @Month_Count -( @Month_Sal)
								
								end	
			else 
                             Begin 
								set @Month_Diff =0
							 end	
			
			
			
			Exec dbo.SP_IT_TAX_ALLOW_DEDU_CALCULATION @emp_ID,@Cmp_ID,@Increment_ID,@From_Date,@To_Date,@Month_Diff,@Month_En_Date
			Exec SP_IT_TAX_PREPARATION_ALLOWANCE_EXEMPT_GET @Emp_ID,@Cmp_Id,@Increment_ID,@From_Date,@To_Date,@Month_Diff,0
		
			FETCH NEXT FROM CUR_AD_Tax INTO @EMP_ID ,@Increment_ID	,@Month_Count	
		END
	CLOSE CUR_AD_Tax
	DEALLOCATE CUR_AD_Tax
		
		

	-------------------End Allowance	   ---------------

	update #Tax_Report
	set Amount_Col_Final = Max_Limit 
	where Is_Exempted = 0 and max_Limit_Compare_Row_ID =0 and Max_Limit  >0
		--	and Default_Def_Id not in (7,107,108,109,110,111,112,113,114,115)

	
	UPdate #Tax_Report 
	set Sal_No_Of_Month = E_COUNT
	From #Tax_Report Tr inner join (SELECT MS.EMP_ID ,COUNT(MS.EMP_ID)E_COUNT FROM 
											T0200_MONTHLY_SALARY MS WITH (NOLOCK) INNER JOIN @EMP_CONS EC ON MS.EMP_ID = EC.EMP_ID 
											WHERE MS.MONTH_sT_DATE >=@FROM_DATE AND MS.MONTH_ST_DATE <=@TO_DATE 
										GROUP BY MS.EMP_ID ) Q ON TR.EMP_ID =Q.EMP_ID

	  
	
	UPdate #Tax_Report 
	set Amount_Col_Final = isnull(Old_M_AD_Amount,0) + isnull(Month_Diff_Amount,0) --isnull(M_AD_Amount,0) + 
	From #Tax_Report Tr inner join #Salary_AD sa on tr.Emp_ID =sa.Emp_ID and sa.Default_Def_ID = @Cont_Basic_Sal
	WHERE tr.DEFAULT_DEF_ID =@Cont_Basic_Sal
	

		
	UPdate #Tax_Report 
	set Amount_Col_Final = isnull(Old_M_AD_Amount,0) + isnull(Month_Diff_Amount,0) --isnull(M_AD_Amount,0) + 
	From #Tax_Report Tr inner join #Salary_AD sa on tr.Emp_ID =sa.Emp_ID and sa.Default_Def_ID = @Cont_HRA
	WHERE tr.DEFAULT_DEF_ID =@Cont_HRA
	
	    		
	UPdate #Tax_Report 
	set Amount_Col_Final =  isnull(Old_M_AD_Amount,0) + isnull(Month_Diff_Amount,0) --isnull(M_AD_Amount,0) +
	From #Tax_Report Tr inner join #Salary_AD sa on tr.Emp_ID =sa.Emp_ID and sa.Default_Def_ID = @Cont_PT_Amount
	WHERE tr.DEFAULT_DEF_ID = @Cont_PT_Amount


	----Change Nilay 16-july-2010 ---------------------------
	
	UPdate #Tax_Report 
	set Amount_Col_Final =  isnull(Old_M_AD_Amount,0) + isnull(Month_Diff_Amount,0) --isnull(M_AD_Amount,0) +
	From #Tax_Report Tr inner join #Salary_AD sa on tr.Emp_ID =sa.Emp_ID and tr.AD_ID = sa.aD_ID
	-- where tr.Default_def_ID =0
	  and (isnull(AD_NOT_EFFECT_ON_SAL,0) =0 or Ad_effect_on_TDS =1)
	 -----Change Nilay 16-july-2010 ---------------------------
	 


	UPdate #Tax_Report 
	set Amount_Col_Final = AMOUNT
	From #Tax_Report Tr inner join (SELECT ITD.EMP_ID,IT_ID ,SUM(ITD.AMOUNT)AMOUNT FROM 
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
		FROM #Tax_Report  WHERE IS_TOTAL > 0 order by Row_ID
		
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
						 when  isnull(Q.Sum_amount,0) > 0 then
								@Max_Limit
						else
							0
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
	

	    Update #Tax_Report 
	      set Amount_Col_Final = M_AD_Amount 
	      from #Tax_Report  t inner join T0210_Monthly_AD_Detail mad on t.emp_ID =mad.Emp_ID 
	      and t.IT_Month = month(Mad.For_Date) and t.IT_Year = Year(Mad.For_Date) inner join
		  T0050_AD_MAster am on mad.AD_ID= am.AD_ID and AD_DEF_ID=1
	
	
	
	Update #Tax_Report 
	set Increment_ID = Q.Increment_ID 
	from #Tax_Report t inner join 
	(select I.Emp_Id ,Increment_ID from T0095_Increment I WITH (NOLOCK) inner join 
					(select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment WITH (NOLOCK)
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
	Declare @Incentive_Amount	numeric
	
   
   
	  	CREATE table #Get_Employee
	  	(
	  	   Emp_ID numeric(18,0),
	  	   Amount numeric(18,0),
	  	   Increment_ID numeric(18,0),	   
	  	)
	  	
	  	insert into #Get_Employee (Emp_ID,Amount,Increment_ID)
	  	
	    select  tr.EMP_ID ,Amount_Col_Final,tr.Increment_ID From #Tax_Report tr inner join T0080_emp_Master E WITH (NOLOCK)
	    on tr.Emp_ID= E.Emp_ID 
	    Where field_type = 2 and tr.Amount_Col_Final >=160000
			

		
		select I_Q.* , cast( E.Emp_Code as varchar) + ' - '+E.Emp_Full_Name as Emp_Full_Name,Emp_superior  
				,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender  
				,BM.Comp_Name,BM.Branch_Address,CM.Cmp_Name,Cm.Cmp_address,E.Emp_Left, E.Emp_Code
		from T0080_EMP_MASTER E WITH (NOLOCK) inner join  #Get_Employee GE on E.Emp_ID =GE.Emp_ID inner join
			T0010_company_master Cm WITH (NOLOCK) on E.Cmp_ID = Cm.Cmp_ID left outer join      
		    T0100_LEFT_EMP EL WITH (NOLOCK) on E.Emp_Id=EL.Emp_Id inner join    
			(select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I WITH (NOLOCK) inner join   
			(select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK) 
				where Increment_Effective_date <= @To_Date  
				and Cmp_ID = @Cmp_ID  
				group by emp_ID  ) Qry on  
				 I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date  ) I_Q   
				on E.Emp_ID = I_Q.Emp_ID  inner join  
				 T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN  
				 T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN  
				 T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN  
				 T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN   
				 T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID   
			WHERE E.Cmp_ID = @Cmp_Id  and Emp_Left<>'y' 
				And E.Emp_ID in (select Emp_ID From @Emp_Cons) order by E.Emp_Code  asc 
         
	RETURN




