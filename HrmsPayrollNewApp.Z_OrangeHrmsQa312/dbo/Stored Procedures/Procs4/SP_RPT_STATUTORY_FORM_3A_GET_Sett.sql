
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[SP_RPT_STATUTORY_FORM_3A_GET_Sett]
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
	,@constraint 	varchar(MAX)

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	declare @PF_LIMIT as numeric
	Declare @PF_DEF_ID		numeric 
	set @PF_DEF_ID =2
		
	set @PF_LIMIT = 15000	
	
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



	--------
	DECLARE @TEMP_DATE AS DATETIME
	
	
	DECLARE @PF_REPORT TABLE
		(
			MONTH		NUMERIC ,
			YEAR		NUMERIC ,
			FOR_DATE	DATETIME
		)
	
	SET @TEMP_DATE = @FROM_DATE
	
	WHILE @TEMP_DATE <= @TO_DATE
		BEGIN
			
			INSERT INTO @PF_REPORT (MONTH,YEAR,FOR_DATE)
				VALUES(MONTH(@TEMP_DATE),YEAR(@TEMP_DATE),@TEMP_DATE)	
			
			SET @TEMP_DATE = DATEADD(m,1,@TEMP_DATE)
		END

	if	exists (select * from [tempdb].dbo.sysobjects where name like '#EMP_PF_REPORT' )		
			begin
				drop table #EMP_PF_REPORT
			end
			
	CREATE table #EMP_PF_REPORT 
		(
			CMP_ID	NUMERIC,
			EMP_CODE	NUMERIC,
			EMP_ID		NUMERIC,
			EMP_NAME	VARCHAR(200),
			PF_NO		VARCHAR(50),
			MONTH		NUMERIC,
			YEAR		NUMERIC,
			FOR_DATE	DATETIME
		)
		
	
	
	-- Changed By Ali 23112013 EmpName_Alias
	INSERT INTO  #EMP_PF_REPORT	
	SELECT  QRY.CMP_ID,QRY.EMP_CODE,QRY.EMP_ID,EMP_full_NAME,PF_NO ,t.month, t.year, t.for_Date from @PF_Report t cross join 
	( SELECT DISTINCT SG.CMP_ID,SG.EMP_ID ,E.EMP_CODE ,ISNULL(E.EmpName_Alias_PF,E.Emp_Full_Name) as EMP_full_NAME ,SSN_NO as PF_NO FROM    t0201_monthly_salary_sett  SG  WITH (NOLOCK) INNER JOIN 
			( select Emp_ID , M_AD_Percentage as PF_PER , M_AD_Amount as PF_Amount ,sal_Tran_ID
					from T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID where AD_DEF_ID = @PF_DEF_ID 
					and ad_not_effect_salary <> 1 And ad.sal_type=1
					and AD.CMP_ID = @CMP_ID) MAD on SG.Emp_ID = MAD.Emp_ID 
						and SG.Sal_Tran_ID = MAD.Sal_Tran_ID INNER JOIN
				T0080_EMP_MASTER E WITH (NOLOCK) ON SG.EMP_ID = E.EMP_ID INNER JOIN
				@EMP_CONS E_S on E.Emp_ID = E_S.Emp_ID
				
		WHERE   e.CMP_ID = @CMP_ID 
				and SG.s_Month_St_Date >=@From_Date  and SG.s_Month_End_Date <= @To_Date )QRY
	
	
	if	exists (select * from [tempdb].dbo.sysobjects where name like '#EMP_SALARY' )		
		begin
			drop table #EMP_SALARY
		end
	
		CREATE table #EMP_SALARY 
			(
				EMP_ID					NUMERIC,
				MONTH					NUMERIC,
				YEAR					NUMERIC,
				SALARY_AMOUNT			NUMERIC,
				OTHER_PF_SALARY			NUMERIC,
				MONTH_ST_DATE			DATETIME,
				MONTH_END_DATE			DATETIME,
				PF_PER					NUMERIC(18,2),
				PF_AMOUNT				NUMERIC,
				PF_SALARY_AMOUNT		NUMERIC,
				PF_LIMIT				numeric,
				PF_367					NUMERIC,
				PF_833					NUMERIC,
				PF_DIFF_6500			NUMERIC
			 )
			
		    INSERT INTO #EMP_SALARY
		    SELECT  SG.EMP_ID,MONTH(S_MONTH_ST_DATe),YEAR(S_MONTH_ST_DATE),SG.s_Salary_Amount 
				 ,0 ,sg.S_Month_st_Date,SG.S_Month_End_date
				 ,MAD.PF_PER,MAD.PF_AMOUNT  , m_ad_Calculated_Amount ,@PF_Limit,0,0,0
				FROM    t0201_monthly_salary_sett  SG  WITH (NOLOCK) INNER JOIN 
				( select Emp_ID , m_ad_Percentage as PF_PER , m_ad_Amount as PF_Amount , m_ad_Calculated_Amount ,SAL_tRAN_ID from 
					T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID  where ad_DEF_id = @PF_DEF_ID And ad_not_effect_salary <> 1 And ad.sal_type=1
					and AD.CMP_ID = @CMP_ID) MAD on SG.Emp_ID = MAD.Emp_ID 
					AND SG.SAL_tRAN_ID = MAD.SAL_TRAN_ID INNER JOIN
					T0080_EMP_MASTER E WITH (NOLOCK) ON SG.EMP_ID = E.EMP_ID inner join
				@EMP_CONS E_S on E.Emp_ID = E_S.Emp_ID				
				
		WHERE   e.CMP_ID = @CMP_ID 
 				and SG.s_Month_St_Date >=@From_Date  and SG.s_Month_End_Date <= @To_Date  
				
		Declare @PF_NOT_FUll_AMT As Numeric(18,2)
		Declare @PF_541 As Numeric(18,2)
	 
		Set @PF_541 = 0
		SET @PF_NOT_FUll_AMT = 0
		
		Set @PF_541 = round(@PF_Limit * 0.0833,0)
		SET @PF_NOT_FUll_AMT = round(@PF_Limit * 12/100,0)
	 
		update #EMP_SALARY
		set	  PF_833 = round(PF_SALARY_AMOUNT * 0.0833,0)
			 ,PF_367 = PF_Amount - round(PF_SALARY_AMOUNT * 0.0833,0) 
		where PF_SALARY_AMOUNT <= PF_Limit


		update #EMP_SALARY
		set PF_Diff_6500 = PF_SALARY_AMOUNT - PF_Limit
			,PF_833 = @PF_541
			,PF_367 = PF_Amount - @PF_541
		where PF_SALARY_AMOUNT > PF_Limit
		
	--EXEC SP_RPT_STATUTORY_GET_RECORD_SETT @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint

		-- Changed By Ali 23112013 EmpName_Alias
		SELECT EPF.*, (SALARY_AMOUNT + ISNULL(OTHER_PF_SALARY,0) )SALARY_AMOUNT
				,(PF_AMOUNT ) PF_AMOUNT	,PF_PER,PF_Limit , PF_SALARY_AMOUNT,PF_833,PF_367
				,PF_Diff_6500,EMP_SECOND_NAME,
				ISNULL(EmpName_Alias_PF,Emp_Full_Name) as Emp_Full_Name,Grd_Name,Type_Name,dept_Name,Desig_Name
				 ,Cmp_Name,Cmp_Address	
				,@From_Date P_From_Date ,@To_Date P_To_Date
				,E.Alpha_Emp_Code  --added jimit 02062015
				,BM.Branch_Name	   --added by jimit 09092016
		  FROM #EMP_PF_REPORT EPF INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON EPF.EMP_ID = E.EMP_ID
		  LEFT OUTER JOIN 	#EMP_SALARY ES ON EPF.EMP_ID = ES.EMP_ID AND EPF.MONTH = ES.MONTH 
						AND EPF.YEAR = ES.YEAR 	INNER JOIN 
						( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,Type_ID FROM T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID From T0095_Increment WITH (NOLOCK)	-- Ankit 09092014 for Same Date Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)Q_I ON
		E.EMP_ID = Q_I.EMP_ID INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
		T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
		T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
		T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID Left outer join 
		T0040_Type_Master TM WITH (NOLOCK) on Q_I.Type_ID = Tm.Type_Id  Inner join 
		T0010_company_Master cm WITH (NOLOCK) on e.cmp_ID = cm.cmp_Id
		
RETURN




