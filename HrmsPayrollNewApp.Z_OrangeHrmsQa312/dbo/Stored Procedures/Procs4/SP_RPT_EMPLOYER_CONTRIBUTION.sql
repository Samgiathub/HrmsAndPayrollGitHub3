---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[SP_RPT_EMPLOYER_CONTRIBUTION]
	 @Cmp_ID 		numeric
	,@From_Date		datetime
	,@To_Date 		datetime
	--,@Branch_ID	numeric
	--,@Cat_ID 		numeric 
	--,@Grd_ID 		numeric
	--,@Type_ID 	numeric
	--,@Dept_ID 	numeric
	--,@Desig_ID 	numeric
	--,@Emp_ID 		numeric
	,@Branch_ID	    varchar(Max) =''
	,@Cat_ID 		varchar(Max) =''
	,@Grd_ID 		varchar(Max) =''
	,@Type_ID 	    varchar(Max) =''
	,@Dept_ID 	    varchar(Max) =''
	,@Desig_ID 	    varchar(Max) =''
	,@Emp_ID 		numeric
	,@constraint 	varchar(MAX)
	,@Report_for    varchar(20) =''
	,@Vertical_ID varchar(max)=''  --Added By Jaina 5-10-2015
	,@SubVertical_ID varchar(max)='' --Added By Jaina 5-10-2015

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	declare @PF_LIMIT as numeric
	Declare @PF_DEF_ID		numeric 
	set @PF_DEF_ID =2
		
	set @PF_LIMIT = 15000	
	
	IF @Branch_ID = '' or @Branch_ID = '0'  
		set @Branch_ID = null
		
	/*
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
		set @Emp_ID = null */
	
	-- Ankit 06092014 for Same Date Increment


	CREATE TABLE #Emp_Cons 
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )   
	 
	 
	 print @constraint
	 --EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0 ,0 ,0 ,0 ,0 ,0
	 exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'',@Vertical_ID,@SubVertical_ID,'',0,0,0,'0',0,0   --Change By Jaina 5-10-2015
	 
	 
	 --added jimit 27112015
	 declare @PBranch_ID as numeric
	 set @PBranch_ID = 0
	 
	
	 
	 select top 1 @PBranch_ID = EC.Branch_ID from #Emp_Cons Ec
	 inner join (SELECT	TI.Increment_ID,TI.Branch_ID,TI.Emp_ID, TI.INCREMENT_EFFECTIVE_dATE
										FROM	t0095_increment TI WITH (NOLOCK)
												INNER JOIN (
															SELECT	MAX(T0095_Increment.Increment_ID) AS Increment_ID,T0095_Increment.Emp_ID 
															FROM	T0095_Increment WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON T0095_INCREMENT.Emp_ID=E.Emp_ID	-- Ankit 12092014 for Same Date Increment
															WHERE	T0095_Increment.Increment_effective_Date <= @to_date AND T0095_Increment.Cmp_ID =@cmp_Id  
															GROUP BY T0095_Increment.emp_ID
															) new_inc ON TI.Emp_ID = new_inc.Emp_ID AND Ti.Increment_ID=new_inc.Increment_ID
										WHERE	Increment_effective_Date <= @to_date  )  ES on EC.Emp_ID = ES.Emp_ID
								
	 
	 --ended
	 SELECT TOP 1 @PF_LIMIT = ACC_10_1_MAX_LIMIT  
	 FROM T0040_General_setting gs WITH (NOLOCK) INNER JOIN     
			T0050_General_Detail gd WITH (NOLOCK) on gs.gen_Id =gd.gen_ID     						
	 WHERE gs.Cmp_Id=@cmp_Id and gs.Branch_ID = @PBranch_ID     -- Modified by Nimesh 29-May-2015 (@BranchID is a constrain not an id)
				and For_Date in (select max(For_Date) from T0040_General_setting  g WITH (NOLOCK) inner join     
				T0050_General_Detail d WITH (NOLOCK) on g.gen_Id =d.gen_ID       
			where g.Cmp_Id=@cmp_Id  and g.Branch_ID = gs.Branch_ID    --Modified by Nimesh 29-May-2015 (@BranchID is a constrain not an id)
		and For_Date <=@To_Date )  	
		
	/*	
	--Declare #Emp_Cons Table
	--(
	--	Emp_ID	numeric
	--)
	
	--if @Constraint <> ''
	--	begin
	--		Insert Into #Emp_Cons
	--		select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
	--	end
	--else
	--	begin
			
			
	--		Insert Into #Emp_Cons

	--		select I.Emp_Id from T0095_Increment I inner join 
	--				( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment
	--				where Increment_Effective_date <= @To_Date
	--				and Cmp_ID = @Cmp_ID
	--				group by emp_ID  ) Qry on
	--				I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	
							
	--		Where Cmp_ID = @Cmp_ID 
	--		and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
	--		and Branch_ID = isnull(@Branch_ID ,Branch_ID)
	--		and Grd_ID = isnull(@Grd_ID ,Grd_ID)
	--		and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
	--		and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
	--		and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
	--		and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
	--		and I.Emp_ID in 
	--			( select Emp_Id from
	--			(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
	--			where cmp_ID = @Cmp_ID   and  
	--			(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
	--			or ( @To_Date  >= join_Date  and @To_Date <= left_date )
	--			or Left_date is null and @To_Date >= Join_Date)
	--			or @To_Date >= left_date  and  @From_Date <= left_date ) 
			
	--	end

*/
if @Report_for ='PF'
  Begin 
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
		
	
	
	-- Changed By Ali 25112013 EmpName_Alias
	INSERT INTO  #EMP_PF_REPORT	
	SELECT  QRY.CMP_ID,QRY.EMP_CODE,QRY.EMP_ID,EMP_full_NAME,PF_NO ,t.month
	, t.year, t.for_Date from @PF_Report t cross join 
	( SELECT DISTINCT SG.CMP_ID,SG.EMP_ID ,E.EMP_CODE ,ISNULL(E.EmpName_Alias_ESIC,E.Emp_Full_Name) as EMP_full_NAME,SSN_NO as PF_NO FROM    T0200_MONTHLY_SALARY  SG WITH (NOLOCK) INNER JOIN 
			( select Emp_ID , M_AD_Percentage as PF_PER , M_AD_Amount as PF_Amount ,sal_Tran_ID
					from T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID where AD_DEF_ID = @PF_DEF_ID 
					and ad_not_effect_salary <> 1
					and AD.CMP_ID = @CMP_ID) MAD on SG.Emp_ID = MAD.Emp_ID 
						and SG.Sal_Tran_ID = MAD.Sal_Tran_ID INNER JOIN
				T0080_EMP_MASTER E WITH (NOLOCK) ON SG.EMP_ID = E.EMP_ID INNER JOIN
				#Emp_Cons E_S on E.Emp_ID = E_S.Emp_ID
				
		WHERE   e.CMP_ID = @CMP_ID 
				and SG.Month_St_Date >=@From_Date  and SG.Month_End_Date <= @To_Date )QRY
	
	
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
		    SELECT  SG.EMP_ID,MONTH(MONTH_ST_DATe),YEAR(MONTH_ST_DATE),SG.Salary_Amount 
				 ,0 ,sg.Month_st_Date,SG.Month_End_date
				 ,MAD.PF_PER,MAD.PF_AMOUNT  , m_ad_Calculated_Amount ,@PF_Limit,0,0,0
				FROM    T0200_MONTHLY_SALARY  SG WITH (NOLOCK) INNER JOIN 
				( select Emp_ID , m_ad_Percentage as PF_PER , m_ad_Amount as PF_Amount , m_ad_Calculated_Amount ,SAL_tRAN_ID from 
					T0210_MONTHLY_AD_DETAIL AD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AD.AD_ID = AM.AD_ID  where ad_DEF_id = @PF_DEF_ID And ad_not_effect_salary <> 1 and sal_type<>1
					and AD.CMP_ID = @CMP_ID) MAD on SG.Emp_ID = MAD.Emp_ID 
					AND SG.SAL_tRAN_ID = MAD.SAL_TRAN_ID INNER JOIN
					T0080_EMP_MASTER E WITH (NOLOCK) ON SG.EMP_ID = E.EMP_ID inner join
				#Emp_Cons E_S on E.Emp_ID = E_S.Emp_ID				
				
		WHERE   e.CMP_ID = @CMP_ID 
 				and SG.Month_St_Date >=@From_Date  and SG.Month_End_Date <= @To_Date  
				
		Declare @PF_541 As Numeric(18,2)
		Set @PF_541 = 0
		Set @PF_541 = round(@PF_Limit * 0.0833,0)
	
		update #EMP_SALARY
		set	  PF_833 = round(PF_SALARY_AMOUNT * 0.0833,0)
			 ,PF_367 = PF_Amount - round(PF_SALARY_AMOUNT * 0.0833,0) 
		where PF_SALARY_AMOUNT <= PF_Limit


		update #EMP_SALARY
		set PF_Diff_6500 = PF_SALARY_AMOUNT - PF_Limit
			,PF_833 = @PF_541
			,PF_367 = PF_Amount - @PF_541
		where PF_SALARY_AMOUNT > PF_Limit

  -- Select * from #EMP_SALARY
    
    
     
		-- Changed By Ali 25112013 EmpName_Alias
		SELECT EPF.*, (SALARY_AMOUNT + ISNULL(OTHER_PF_SALARY,0) )SALARY_AMOUNT
				,(PF_AMOUNT ) PF_AMOUNT	,PF_PER,PF_Limit , PF_SALARY_AMOUNT,PF_833,PF_367
				,PF_Diff_6500,EMP_SECOND_NAME,
				ISNULL(E.EmpName_Alias_ESIC,Emp_Full_Name) as Emp_Full_Name,Grd_Name,Type_Name,dept_Name,Desig_Name
				 ,Cmp_Name,Cmp_Address	
				,@From_Date P_From_Date ,@To_Date P_To_Date,Alpha_Emp_Code,E.Emp_First_Name    --added jimit 29062015
				,BM.Branch_Name,BM.Branch_Address		--added jimit 22072016
		  FROM #EMP_PF_REPORT EPF INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON EPF.EMP_ID = E.EMP_ID
		  LEFT OUTER JOIN 	#EMP_SALARY ES ON EPF.EMP_ID = ES.EMP_ID AND EPF.MONTH = ES.MONTH 
						AND EPF.YEAR = ES.YEAR 	INNER JOIN 
						( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,Type_ID FROM T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	)Q_I ON
		E.EMP_ID = Q_I.EMP_ID INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
		T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
		T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
		T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID Left outer join 
		T0040_Type_Master TM WITH (NOLOCK) on Q_I.Type_ID = Tm.Type_Id  Inner join 
		T0010_company_Master cm WITH (NOLOCK) on e.cmp_ID = cm.cmp_Id
		
		

  End
  
  Else if @Report_for ='ESIC'
    Begin 
    
    Declare @AD_Def_ID numeric 
	declare @EMPLOYER_CONT_PER numeric (18,2)
	Declare @Emp_Share_Cont_Amount numeric 
	Declare @Employer_Share_Cont_Amount numeric 
	Declare @Total_Share_Cont_Amount numeric 
	
	set @EMPLOYER_CONT_PER =0
	set @AD_Def_ID =3
	set @Emp_Share_Cont_Amount =0
	set @Employer_Share_Cont_Amount = 0
	set @Total_Share_Cont_Amount =0 
		 

	
	select TOP 1 @EMPLOYER_CONT_PER =ESIC_EMPLOYER_CONTRIBUTION
		from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID	
		--and Branch_ID = ISNULL(@Branch_ID,Branch_ID) Comment by nilesh patel
		and Branch_ID IN(SELECT cast(data  as numeric) FROM dbo.Split(@Branch_ID,'#')) --Added by nilesh patel
		and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@tO_DATE 
		--and Branch_ID = isnull(@Branch_ID,Branch_ID) 
		 and Branch_ID IN(SELECT cast(data  as numeric) FROM dbo.Split(@Branch_ID,'#'))
		and Cmp_ID = @Cmp_ID)

		
	select @Emp_Share_Cont_Amount = sum(Emp_Cont_Amount) , 
		   @Employer_Share_Cont_Amount = sum(Employer_Cont_Amount) 
	From T0220_ESIC_Challan ec WITH (NOLOCK)	Where ec.Cmp_ID = @Cmp_ID and dbo.GET_MONTH_ST_DATE(ec.Month,ec.Year) >= @From_date and dbo.GET_MONTH_ST_DATE(ec.Month,ec.Year) <= @To_Date and 
	--isnull(Branch_ID,0) = isnull(@Branch_Id ,isnull(Branch_ID,0))
	  isnull(Branch_ID,0) IN(SELECT cast(data  as numeric) FROM dbo.Split(@Branch_ID,'#'))
	
	 
	Set @Total_Share_Cont_amount =  @Emp_Share_Cont_Amount + @Employer_Share_Cont_Amount  

	
	CREATE table #ESIC
	(
	    Emp_name varchar(100),
	    Emp_code   numeric(18,2),
	    Emp_ID numeric(18,0),
	    Emp_share_cont_Amount  numeric(18,2),
	    Employer_Share_Cont_Amount numeric(18,2),
	    M_AD_Calculated_Amount numeric(18,2),
	)
	
	-- Changed By Ali 25112013 EmpName_Alias
	insert into #ESIC
	Select 	ISNULL(EmpName_Alias_ESIC,Emp_Full_Name),Emp_code,MAD.Emp_ID,@Emp_Share_Cont_Amount  Emp_Share_Cont_Amount , round(MAD.M_AD_Calculated_Amount *Qry.ESIC_Employer_Contribution/100,0) as Employer_Share_Cont_Amount ,(MAD.M_AD_Calculated_Amount) as SALARY_AMOUNT
		 From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) Inner join 
			  T0050_AD_MASTER ADM WITH (NOLOCK) ON MAD.AD_ID = ADM.AD_ID INNER JOIN 
		T0080_EMP_MASTER E WITH (NOLOCK) on MAD.emp_ID = E.emp_ID INNER  JOIN 
			#Emp_Cons EC ON E.EMP_ID = EC.EMP_ID inner join 
					T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON MAD.SAL_tRAN_ID = MS.SAL_TRAN_ID INNER JOIN 
					T0095_INCREMENT I_Q WITH (NOLOCK) ON MS.INCREMENT_ID = I_Q.INCREMENT_ID	inner join
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join 
					T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID INNER JOIN 
					T0010_COMPANY_MASTER CM WITH (NOLOCK) ON MAD.CMP_ID = CM.CMP_ID  Inner Join 
					(Select GS.Branch_ID,ESIC_EMPLOYER_CONTRIBUTION From T0040_GENERAL_SETTING GS WITH (NOLOCK) Inner JOIN
						( select max(For_Date) As For_Date, Branch_ID 
							from T0040_GENERAL_SETTING WITH (NOLOCK)
							where For_Date <=@tO_DATE and Cmp_ID = @Cmp_ID
							GROUP by Branch_ID)Qry1 On Qry1.For_Date=Gs.For_Date And Qry1.Branch_ID = GS.Branch_ID) Qry On EC.Branch_ID = Qry.Branch_id					
		WHERE E.Cmp_ID = @Cmp_Id	 and For_date >=@From_Date and For_date <=@To_Date
				and  ADM.AD_DEF_ID =  @AD_Def_ID And ADM.AD_not_effect_salary <>1 And sal_type<>1
    
     
		-- Changed By Ali 25112013 EmpName_Alias
		SELECT EPF.*,EMP_SECOND_NAME,E.Alpha_Emp_Code,E.Emp_First_Name,
				ISNULL(E.EmpName_Alias_ESIC,Emp_Full_Name) as Emp_Full_Name,Grd_Name,Type_Name,dept_Name,Desig_Name
				 ,Cmp_Name,Cmp_Address	
				,@From_Date P_From_Date ,@To_Date P_To_Date,
				BM.Comp_Name,BM.Branch_Address
				,BM.Branch_Name,E.Emp_First_Name            --added jimit 15062015
				
		  FROM #ESIC EPF INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON EPF.EMP_ID = E.EMP_ID
		  
							INNER JOIN 
						( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,Type_ID FROM T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	)Q_I ON
		E.EMP_ID = Q_I.EMP_ID INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
		T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
		T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
		T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID Left outer join 
		T0040_Type_Master TM WITH (NOLOCK) on Q_I.Type_ID = Tm.Type_Id  Inner join 
		T0010_company_Master cm WITH (NOLOCK) on e.cmp_ID = cm.cmp_Id
     
    Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End
    --ORDER BY RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) 
    
   
   
    End
						
RETURN
