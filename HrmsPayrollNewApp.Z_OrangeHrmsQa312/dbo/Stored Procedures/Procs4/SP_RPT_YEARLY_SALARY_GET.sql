CREATE PROCEDURE [dbo].[SP_RPT_YEARLY_SALARY_GET]
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
	,@Report_Call	varchar(20)='Net Salary'
	,@Salary_Cycle_id numeric = NULL
	,@Segment_Id  numeric = 0		 -- Added By Gadriwala Muslim 21082013
	,@Vertical_Id numeric = 0		 -- Added By Gadriwala Muslim 21082013
	,@SubVertical_Id numeric = 0	 -- Added By Gadriwala Muslim 21082013	
	,@SubBranch_Id numeric = 0		 -- Added By Gadriwala Muslim 21082013	
	,@With_Ctc numeric = 0 -- Added by rohit on 09102013
	,@Group_Type numeric = 0 --added jimit 20072015
	,@Publish_Flag numeric = 0 --added Nilesh Patel on 27112015
	,@AD_ID		   numeric = 0 --added jimit 02032016
	,@Show_Hidden_Allowance  bit = 0   --Added by Jaina 16-05-2017
	,@Bonus_Amount bit = 0 --Added By Jimit 06032018                     
AS
	Set Nocount on 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
	
	
	set @Show_Hidden_Allowance = 0
	
	--(SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1)This condition By Mukti to display report if FNF done and Publish_Flag=0 at ESS side

	 --Declare #Emp_Cons Table
	 --(
		--Emp_ID	numeric ,     
		--Branch_ID NUMERIC,
		--Increment_ID NUMERIC 
	 --)
	 
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
		
	IF @Salary_Cycle_id = 0	 -- Added By Gadriwala Muslim 21082013
		set @Salary_Cycle_id = null	
	If @Segment_Id = 0		 -- Added By Gadriwala Muslim 21082013
		set @Segment_Id = null
	If @Vertical_Id = 0		 -- Added By Gadriwala Muslim 21082013
		set @Vertical_Id = null
	If @SubVertical_Id = 0	 -- Added By Gadriwala Muslim 21082013
		set @SubVertical_Id = null	
	If @SubBranch_Id = 0	 -- Added By Gadriwala Muslim 21082013
		set @SubBranch_Id = null	
	
	
	
	CREATE TABLE #Emp_Cons 
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )   


	EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0 ,0 ,0,0,0,0,0,0,0,'' ,@With_Ctc = 1
	
	Create Clustered index IX_Emp_Cons_Emp_ID_Branch_ID_Increment_ID on #Emp_Cons (Emp_ID,Branch_ID,Increment_ID)
	
	--if @Constraint <> ''
	--	begin
	--		Insert Into #Emp_Cons
	--		select CAST(DATA  AS NUMERIC),CAST(DATA  AS NUMERIC),CAST(DATA  AS NUMERIC) from dbo.Split (@Constraint,'#')
	--	end
	--else
	--	begin
			
	--		Insert Into #Emp_Cons
			
	--		  SELECT DISTINCT V.emp_id,branch_id,V.Increment_ID FROM V_Emp_Cons V 
	--		  Inner Join
	--					dbo.T0200_MONTHLY_SALARY MS on MS.Emp_ID = V.Emp_ID 
	--		LEFT OUTER JOIN (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id AS eid 
	--								FROM T0095_Emp_Salary_Cycle ESC
	--									INNER JOIN (SELECT MAX(Effective_date) AS Effective_date,emp_id 
	--													FROM T0095_Emp_Salary_Cycle 
	--													WHERE Effective_date <= @To_Date
	--													GROUP BY emp_id
	--												) Qry ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id
	--							) AS QrySC ON QrySC.eid = V.Emp_ID
	--		WHERE 
	--	      V.cmp_id=@Cmp_ID 		
	--	       AND ISNULL(Cat_ID,0) = ISNULL(@Cat_ID ,ISNULL(Cat_ID,0))          
	--	       AND Branch_ID = ISNULL(@Branch_ID ,Branch_ID)      
	--	   AND Grd_ID = ISNULL(@Grd_ID ,Grd_ID)      
	--	   AND ISNULL(Dept_ID,0) = ISNULL(@Dept_ID ,ISNULL(Dept_ID,0))      
	--	   AND ISNULL(TYPE_ID,0) = ISNULL(@Type_ID ,ISNULL(TYPE_ID,0))      
	--	   AND ISNULL(Desig_ID,0) = ISNULL(@Desig_ID ,ISNULL(Desig_ID,0))
	--	   AND ISNULL(QrySC.SalDate_id,0) = ISNULL(@Salary_Cycle_id ,ISNULL(QrySC.SalDate_id,0))     
	--	   And ISNULL(Segment_ID,0) = ISNULL(@Segment_ID,IsNull(Segment_ID,0))
	--	   And ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,IsNull(Vertical_ID,0))
	--	   And ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_Id,IsNull(SubVertical_ID,0))
	--	   And ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,IsNull(subBranch_ID,0)) -- Added on 06082013
	--	   --and month(ms.Month_End_Date)  = month(@To_Date)	--Comment Ankit 11072014
	--	   --and year(ms.Month_End_Date)  = year(@To_Date)		--Comment Ankit 11072014
	--	   and ms.month_end_date >= @from_date and ms.month_end_date <= @to_date
	--	   and ms.Is_FNF = 0
	--	   AND V.Emp_Id = ISNULL(@Emp_Id,V.Emp_Id) 
	--	      AND Increment_Effective_Date <= @To_Date 
	--	      AND 
 --                      ( (@From_Date  >= join_Date  AND  @From_Date <= left_date )      
	--					OR ( @To_Date  >= join_Date  AND @To_Date <= left_date )      
	--					OR (Left_date IS NULL AND @To_Date >= Join_Date)      
	--					OR (@To_Date >= left_date  AND  @From_Date <= left_date )
	--					OR 1=(case when ( (left_date <= @To_Date) and (dateadd(mm,1,Left_Date) > @From_Date ))  then 1 else 0 end)
	--					)
			 
	--		ORDER BY Emp_ID


	--		DELETE  FROM #Emp_Cons WHERE Increment_ID NOT IN (SELECT MAX(Increment_ID) FROM T0095_Increment
	--			WHERE  Increment_effective_Date <= @to_date
	--			GROUP BY emp_ID )
		
				
	--		--Delete From #Emp_Cons Where Increment_ID Not In
	--		--		(select TI.Increment_ID from t0095_increment TI inner join
	--		--		(Select Max(Increment_Effective_Date) as Effective_Date,Emp_ID from T0095_Increment
	--		--		Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
	--		--		on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Effective_Date
	--		--		Where Increment_effective_Date <= @to_date)	
		
		
	--		--Insert Into #Emp_Cons

	--		--select I.Emp_Id from T0095_Increment I inner join 
	--		--		( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment
	--		--		where Increment_Effective_date <= @To_Date
	--		--		and Cmp_ID = @Cmp_ID
	--		--		group by emp_ID  ) Qry on
	--		--		I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	
							
	--		--Where Cmp_ID = @Cmp_ID 
	--		--and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
	--		--and Branch_ID = isnull(@Branch_ID ,Branch_ID)
	--		--and Grd_ID = isnull(@Grd_ID ,Grd_ID)
	--		--and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
	--		--and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
	--		--and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
	--		--and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))	 -- Added By Gadriwala Muslim 21082013
	--		--and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 -- Added By Gadriwala Muslim 21082013
	--		--and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) -- Added By Gadriwala Muslim 21082013
	--		--and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) -- Added By Gadriwala Muslim 21082013
			
	--		--and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
	--		--and I.Emp_ID in 
	--		--	( select Emp_Id from
	--		--	(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
	--		--	where cmp_ID = @Cmp_ID   and  
	--		--	(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
	--		--	or ( @To_Date  >= join_Date  and @To_Date <= left_date )
	--		--	or Left_date is null and @To_Date >= Join_Date)
	--		--	or @To_Date >= left_date  and  @From_Date <= left_date ) 
			
	--	end
		
		
		-- Ankit 17072014 --
		DECLARE @ROUNDING Numeric
		Set @ROUNDING = 2
		Declare @Net_Salary_Round NUMERIC(18,2)
		SET @Net_Salary_Round = 0
		
		DECLARE @ProductionBonus_Ad_Def_Id as NUMERIC ---added by jimit 24032017	
		Set @ProductionBonus_Ad_Def_Id=20
		
		If @Branch_ID is null
			Begin 
				select Top 1 @ROUNDING =Ad_Rounding, @Net_Salary_Round = ISNULL(Net_Salary_Round,0)
				  from dbo.T0040_GENERAL_SETTING G
						INNER JOIN (SELECT TOP 1 BRANCH_ID FROM #Emp_Cons ) E ON G.Branch_ID=E.Branch_ID
				  where cmp_ID = @cmp_ID    
				  and For_Date = ( select max(For_Date) 
									from dbo.T0040_GENERAL_SETTING G INNER JOIN 
									(SELECT TOP 1 BRANCH_ID FROM #Emp_Cons ) E ON G.Branch_ID=E.Branch_ID
									where For_Date <=@To_Date and Cmp_ID = @Cmp_ID)    
			End
		Else
			Begin
				select @ROUNDING =Ad_Rounding, @Net_Salary_Round = ISNULL(Net_Salary_Round,0)
				  from dbo.T0040_GENERAL_SETTING where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
				  and For_Date = ( select max(For_Date) from dbo.T0040_GENERAL_SETTING where For_Date <=@To_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
			End
		
		
		
		-- Ankit 17072014 --		
 
		Declare @Month numeric 
		Declare @Year numeric  
		--if	exists (select 1 from [tempdb].dbo.sysobjects where name like '#Yearly_Salary' )	
		If Object_Id ('tempdb..#Yearly_Salary') Is not null
			begin
				drop table #Yearly_Salary 
			end
			
		--if exists(SELECT 1 FROM [tempdb].dbo.sysobjects where name LIKE '#Salary_Publish_Emp')
		If Object_Id ('tempdb..#Salary_Publish_Emp') Is not null
			begin
				drop TABLE #Salary_Publish_Emp
			End 
			
		Create Table #Salary_Publish_Emp
		(
			Cmp_ID numeric,
			Emp_ID numeric,
			P_Month Numeric,
			P_Year Numeric,
			Publish_Flag Numeric
		)
		Create Clustered index IX_Salary_Publish_Emp_Emp_ID_P_Month_P_Year_Publish_Flag on #Salary_Publish_Emp (Emp_ID,P_Month,P_Year,Publish_Flag)
		
		

		Insert into #Salary_Publish_Emp(Cmp_ID,Emp_ID,P_Month,P_Year,Publish_Flag)
		(Select ms.Cmp_ID,EC.Emp_ID,month(Ms.Month_End_Date),YEAR(ms.Month_End_Date),isnull(SPE.Is_Publish,0) FROM T0200_MONTHLY_SALARY Ms 
		left join T0250_SALARY_PUBLISH_ESS SPE on Ms.Emp_ID=SPE.Emp_ID and month(Ms.Month_End_Date) = SPE.MONTH and YEAR(ms.Month_End_Date) = SPE.Year AND SPE.Sal_Type='Salary'  --Mukti(30062016)added Sal_Type
		Inner Join #Emp_Cons EC on ms.Emp_ID = EC.Emp_ID)  -- Changed by rohit For if Salary Not Publish or Unpublish then its Not Shows in yearly Salary report- on 17122015
		
		if @Publish_Flag = 1 --Added by nilesh patel on 27112015 For When Admin show all salary.
			Begin
				update #Salary_Publish_Emp Set Publish_Flag = 1
			End 		 
		CREATE table #Yearly_Salary 
			(
				Row_ID			numeric IDENTITY (1,1) not null,
				Cmp_ID			numeric ,
				Emp_Id			numeric ,
				Def_ID			varchar(max) collate SQL_Latin1_General_CP1_CI_AS ,
				Lable_Name		varchar(100) collate SQL_Latin1_General_CP1_CI_AS,
				Month_1			numeric(18,2) default 0,
				Month_2			numeric(18,2) default 0,
				Month_3			numeric(18,2) default 0,
				Month_4			numeric(18,2) default 0,
				Month_5			numeric(18,2) default 0,
				Month_6			numeric(18,2) default 0,
				Month_7			numeric(18,2) default 0,
				Month_8			numeric(18,2) default 0,
				Month_9			numeric(18,2) default 0,
				Month_10		numeric(18,2) default 0,
				Month_11		numeric(18,2) default 0,
				Month_12		numeric(18,2) default 0,
				Total			numeric(18,2) default 0,
				AD_ID			numeric, 
				LOAN_ID			NUMERIC,
				CLAIM_ID		NUMERIC,
				Group_Def_ID	numeric default 0,
				AD_Level		numeric default 0,
			)
	
		Create nonclustered index IX_Yearly_Salary_Emp_ID_Def_ID_AD_ID_Loan_id on #Yearly_Salary (	Emp_ID,AD_ID,Loan_id) INCLUDE (Month_1,Month_2,Month_3,Month_4,Month_5,Month_6,Month_7,Month_8,Month_9,Month_10,Month_11,Month_12)
			--if @Report_Call <> 'Net Salary'
				begin						
						insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
						select @Cmp_ID,emp_ID,51,'Strength' From #Emp_Cons 

						insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
						select @Cmp_ID,emp_ID,52,'Salary Days' From #Emp_Cons 
						
						--Added by Mukti(05122020)start TO Get Actual Salary Structure Columns Wonder
						IF @Report_Call='ALL1'
						BEGIN	
							If Object_Id ('tempdb..#Tbl_Get_AD') Is null
							begin				
								Create table #Tbl_Get_AD
								(
									Emp_ID numeric(18,0),
									Ad_ID numeric(18,0),
									for_date datetime,
									E_Ad_Percentage numeric(18,5),
									E_Ad_Amount numeric(18,2)
								)
							End
		
							IF OBJECT_ID ('tempdb..#Tbl_Yearly_Salary_Register') IS NULL
								BEGIN
									INSERT INTO #Tbl_Get_AD
									Exec P_Emp_Revised_Allowance_Get @CMP_id,@TO_DATE,@Constraint
								END
							ELSE
								BEGIN
									Exec P_Emp_Revised_Allowance_Get @CMP_id,@TO_DATE,@Constraint

									INSERT INTO #Tbl_Get_AD
									SELECT * FROM #Tbl_Yearly_Salary_Register
								END

							insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
							select @Cmp_ID,emp_ID,'53','Basic Salary Actual' From #Emp_Cons 	
					
							insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,AD_ID,AD_Level)
							select @Cmp_ID,EC.emp_ID,'A'+CAST(TAD.AD_ID  as varchar(max)),AD_NAME+ '_' + 'Actual' ,TAD.AD_ID,A.AD_LEVEL
							From T0050_AD_MASTER AS A  WITH (NOLOCK) 
							INNER JOIN 
							  (SELECT     T.EMP_ID, T.E_AD_AMOUNT, T.AD_ID
								FROM          #Tbl_Get_AD AS T
								WHERE      (T.E_AD_PERCENTAGE > 0) OR (T.E_AD_AMOUNT > 0)) AS TAD ON A.AD_ID = TAD.AD_ID 
							INNER JOIN #Emp_Cons EC	ON EC.EMP_ID=TAD.EMP_ID											
							WHERE     (TAD.E_AD_AMOUNT <> 0) and a.AD_FLAG = 'I' and AD_NOT_EFFECT_SALARY = 0	and A.Cmp_ID = @Cmp_ID	
							order by A.Ad_Level,A.AD_Sort_name
						
							insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,AD_ID,AD_Level)
							select @Cmp_ID,EC.emp_ID,'B'+CAST(TAD.AD_ID  as varchar(max)),AD_NAME+ '_' + 'Actual' ,TAD.AD_ID,A.AD_LEVEL
							From T0050_AD_MASTER AS A  WITH (NOLOCK)								
							INNER JOIN 
							  (SELECT     T.EMP_ID, T.E_AD_AMOUNT, T.AD_ID
								FROM          #Tbl_Get_AD AS T
								WHERE      (T.E_AD_PERCENTAGE > 0) OR (T.E_AD_AMOUNT > 0)) AS TAD ON A.AD_ID = TAD.AD_ID 
							INNER JOIN #Emp_Cons EC	ON EC.EMP_ID=TAD.EMP_ID											
							WHERE     (TAD.E_AD_AMOUNT <> 0) and a.AD_FLAG = 'I' and AD_NOT_EFFECT_SALARY = 1	and A.Cmp_ID = @Cmp_ID	
							order by A.Ad_Level,A.AD_Sort_name
											   						

							insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,AD_ID,AD_Level)
							SELECT DISTINCT @Cmp_ID,m.emp_ID,'AR'+CAST(m.AD_ID  as varchar(max)),AD_NAME+ '_' + 'Arrear' ,m.AD_ID,A.AD_LEVEL
							--replace(A.AD_NAME,' ','_') as AD_SORT_NAME, t.EMP_ID, t.E_AD_AMOUNT
							FROM         T0210_MONTHLY_AD_DETAIL AS m  WITH (NOLOCK) 
							INNER JOIN T0050_AD_MASTER AS a WITH (NOLOCK) ON a.AD_ID = m.AD_ID AND a.CMP_ID = m.Cmp_ID
							INNER JOIN #Emp_Cons Ec ON Ec.emp_id = m.Emp_ID
							LEFT OUTER JOIN
							(
								SELECT  MAD.AD_ID as AD_ID_arear, Isnull(SUM(M_AD_Amount),0) as ms_amount,MSS.Emp_id as Emp_id_arear  
								FROM t0210_monthly_ad_detail MAD WITH (NOLOCK)  
									inner join T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK) on MAD.S_Sal_Tran_ID=MSS.S_Sal_Tran_ID and mad.emp_id = Mss.emp_id  
									inner join T0050_AD_MASTER on MAD.Ad_Id = T0050_AD_MASTER.Ad_ID and MAD.Cmp_ID = T0050_AD_MASTER.Cmp_Id
								WHERE MAD.Cmp_ID = @Cmp_ID AND Cast(CONVERT(varchar(6), MSS.S_Eff_Date, 112) As Numeric) between  Cast(CONVERT(varchar(6), @FROM_DATE, 112) As Numeric) AND Cast(CONVERT(varchar(6), @TO_DATE, 112) As Numeric)
								--and month(MSS.S_Eff_Date) = Month(@To_Date) and Year(MSS.S_Eff_Date) = Year(@To_Date) 
									  and (AD_NOT_EFFECT_SALARY = 0 OR ReimShow = 1)  and Ad_Active = 1 
								GROUP BY MAD.AD_ID,MSS.Emp_ID
							) as MS_arear   on m.ad_id = MS_arear.AD_ID_arear and  m.emp_id = MS_arear.emp_id_arear
							WHERE  Cast(CONVERT(varchar(6), M.For_Date, 112) As Numeric) between  Cast(CONVERT(varchar(6), @FROM_DATE, 112) As Numeric) AND Cast(CONVERT(varchar(6), @TO_DATE, 112) As Numeric) and
							M_AD_Flag = 'I' and a.AD_ACTIVE = 1 and (M_AREAR_AMOUNT <> 0 OR m.M_AREAR_AMOUNT_Cutoff <> 0 or MS_arear.ms_amount <> 0) 
							and (AD_NOT_EFFECT_SALARY = 0 OR ReimShow = 1)	and m.Cmp_ID = @Cmp_ID	and	m.S_Sal_Tran_ID is NULL
							--order by a.AD_SORT_NAME

							insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
							select @Cmp_ID,emp_ID,'C2','Gross Salary Actual' From #Emp_Cons 
						

							insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
							select @Cmp_ID,emp_ID,'C3','PT Amount Actual' From #Emp_Cons 

							insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,AD_ID,AD_Level)
							select  @Cmp_ID,EC.emp_ID,'D'+CAST(tad.AD_ID  as varchar(max)),AD_NAME+ '_' + 'Actual' ,TaD.AD_ID,A.AD_LEVEL
							From T0050_AD_MASTER AS A  WITH (NOLOCK) 
							INNER JOIN 
							  (SELECT     T.EMP_ID, T.E_AD_AMOUNT, T.AD_ID
								FROM          #Tbl_Get_AD AS T
								WHERE      (T.E_AD_PERCENTAGE > 0) OR (T.E_AD_AMOUNT > 0)) AS TAD ON A.AD_ID = TAD.AD_ID 
							INNER JOIN #Emp_Cons EC	ON EC.EMP_ID=TAD.EMP_ID											
							WHERE     (TAD.E_AD_AMOUNT <> 0) and a.AD_FLAG = 'D' and AD_NOT_EFFECT_SALARY = 0	and A.Cmp_ID = @Cmp_ID	
							order by A.Ad_Level,A.AD_Sort_name
							--From  T0210_MONTHLY_AD_DETAIL AS M  WITH (NOLOCK) 
							--INNER JOIN T0050_AD_MASTER AS a  WITH (NOLOCK) ON a.AD_ID = m.AD_ID AND a.CMP_ID = m.Cmp_ID
							--INNER JOIN #Emp_Cons Ec ON Ec.emp_id = m.Emp_ID 			
							--WHERE  Cast(CONVERT(varchar(6), M.To_date, 112) As Numeric) between  Cast(CONVERT(varchar(6), @FROM_DATE, 112) As Numeric) AND Cast(CONVERT(varchar(6), @TO_DATE, 112) As Numeric)
							--and (m.M_AD_Amount <> 0) AND (m.M_AD_Flag = 'D')   and AD_NOT_EFFECT_SALARY = 0 and m.Cmp_ID = @Cmp_ID and m.S_Sal_Tran_ID is NULL    
							--order by A.Ad_Level,A.AD_Sort_name

							insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
							select @Cmp_ID,emp_ID,'E1','Total Deduction Actual' From #Emp_Cons 

							insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
							select @Cmp_ID,emp_ID,'E2','Net Amount Actual' From #Emp_Cons 

							insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
							select @Cmp_ID,emp_ID,'E3','CTC Actual' From #Emp_Cons 
						--select * from #Yearly_Salary
						END
						--Added by Mukti(05122020)end TO Get Actual Salary Structure Columns Wonder	

						--SELECT     m.Emp_ID, (isnull(m.M_AREAR_AMOUNT,0) + isnull(m.M_AREAR_AMOUNT_Cutoff,0) + isnull(MS_arear.ms_amount,0))as M_AREAR_AMOUNT  , replace(a.AD_NAME,' ','_') as AD_SORT_NAME
						--FROM         T0210_MONTHLY_AD_DETAIL AS m  WITH (NOLOCK) 
						--			INNER JOIN T0050_AD_MASTER AS a WITH (NOLOCK) ON a.AD_ID = m.AD_ID AND a.CMP_ID = m.Cmp_ID
						--			INNER JOIN #Emp_Cons Ec ON Ec.emp_id = m.Emp_ID
						--			LEFT OUTER JOIN
						--			(
						--				SELECT  MAD.AD_ID as AD_ID_arear, Isnull(SUM(M_AD_Amount),0) as ms_amount,MSS.Emp_id as Emp_id_arear  
						--				FROM t0210_monthly_ad_detail MAD WITH (NOLOCK)  
						--					inner join T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK) on MAD.S_Sal_Tran_ID=MSS.S_Sal_Tran_ID and mad.emp_id = Mss.emp_id  
						--					inner join T0050_AD_MASTER on MAD.Ad_Id = T0050_AD_MASTER.Ad_ID and MAD.Cmp_ID = T0050_AD_MASTER.Cmp_Id
						--				WHERE MAD.Cmp_ID = @Cmp_ID and MSS.S_Eff_Date between @From_Date and @To_Date
						--					  and (AD_NOT_EFFECT_SALARY = 0 OR ReimShow = 1) and Ad_Active = 1 
						--				GROUP BY MAD.AD_ID,MSS.Emp_ID
						--			) as MS_arear   on m.ad_id = MS_arear.AD_ID_arear and  m.emp_id = MS_arear.emp_id_arear
						--WHERE   M_AD_Flag = 'I' and a.AD_ACTIVE = 1 and (M_AREAR_AMOUNT <> 0 OR m.M_AREAR_AMOUNT_Cutoff <> 0 or MS_arear.ms_amount <> 0) 
						--and (AD_NOT_EFFECT_SALARY = 0 OR ReimShow = 1)	and m.Cmp_ID = @Cmp_ID	and	m.S_Sal_Tran_ID is NULL
						--order by a.AD_SORT_NAME

						--SELECT     m.Emp_ID, (isnull(m.M_AREAR_AMOUNT,0) + isnull(m.M_AREAR_AMOUNT_Cutoff,0) ) as M_AREAR_AMOUNT, replace(a.AD_NAME,' ','_') as AD_SORT_NAME
						--INTO       #v_Ad_Name_Arr_ntes
						--FROM         T0210_MONTHLY_AD_DETAIL AS m  WITH (NOLOCK) 
						--			INNER JOIN	 T0050_AD_MASTER AS a  WITH (NOLOCK) ON a.AD_ID = m.AD_ID AND a.CMP_ID = m.Cmp_ID
						--			Inner join   #Emp_Cons1 Ec ON Ec.emp_id = m.Emp_ID  
						--WHERE  (m.For_Date = @From_Date)   
						--and M_AD_Flag = 'I' and a.AD_ACTIVE = 1 and ( M_AREAR_AMOUNT<>0 or M_AREAR_AMOUNT_Cutoff<>0) and (AD_NOT_EFFECT_SALARY = 1 and AD_PART_OF_CTC = 1) and m.Cmp_ID = @Company_ID
						--and	m.S_Sal_Tran_ID is NULL    
						--order by a.AD_SORT_NAME

						insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
						select @Cmp_ID,emp_ID,'F1','Basic Salary' From #Emp_Cons 
						
						insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,AD_ID,AD_Level)
						select DISTINCT @Cmp_ID,EC.emp_ID,'i'+CAST(mad.AD_ID  as varchar(max)),AD_NAME ,MAD.AD_ID,AM.AD_LEVEL From #Emp_Cons EC	INNER JOIN  
						T0210_MONTHLY_AD_DETAIL MAD ON EC.EMP_ID = MAD.EMP_ID INNER JOIN T0050_AD_MASTER AM ON MAD.AD_ID = AM.AD_ID
						WHERE M_AD_FLAG = 'i' AND  
						--FOR_DATE >=@fROM_dATE AND FOR_dATE <=@TO_DATE 
						Cast(CONVERT(varchar(6), MAD.To_date, 112) As Numeric) between  Cast(CONVERT(varchar(6), @FROM_DATE, 112) As Numeric) AND Cast(CONVERT(varchar(6), @TO_DATE, 112) As Numeric)
						and (AM.AD_NOT_EFFECT_SALARY = 0 or isnull(AM.FOR_FNF,0)=1 ) and ad_Def_Id <> @ProductionBonus_Ad_Def_Id
						Order by AM.AD_LEVEL -- Added By Ali 18122013


						--INNER JOIN  
						--	T0210_MONTHLY_AD_DETAIL MAD ON EC.EMP_ID = MAD.EMP_ID INNER JOIN T0050_AD_MASTER AM ON MAD.AD_ID = AM.AD_ID
						--  WHERE M_AD_FLAG = 'i' AND Cast(CONVERT(varchar(6), MAD.To_date, 112) As Numeric) between  Cast(CONVERT(varchar(6), @FROM_DATE, 112) As Numeric) AND Cast(CONVERT(varchar(6), @TO_DATE, 112) As Numeric)
						--  and AM.AD_NOT_EFFECT_SALARY = 0  and MAD.M_AD_Amount >0
						--  Order by AM.AD_LEVEL

						--insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,AD_ID,AD_Level,Total)
						--SELECT     @Cmp_ID,m.Emp_ID,'M'+CAST(A.AD_ID  as varchar(max)),
						--case when a.Allowance_type='R' then replace(a.AD_NAME,' ','_')+ '_' + 'Credit' Else replace(a.AD_NAME,' ','_')End as AD_Sort_NAME,A.AD_ID,A.AD_LEVEL,
						--(isnull(m.M_AD_Amount,0) + isnull(MS_arear.ms_amount,0) + isnull(m.M_AREAR_AMOUNT,0)+ isnull(m.M_AREAR_AMOUNT_Cutoff,0)) as M_AD_Amount						
						--FROM         T0210_MONTHLY_AD_DETAIL AS m  WITH (NOLOCK) 
						--			INNER JOIN T0050_AD_MASTER AS a  WITH (NOLOCK) ON a.AD_ID = m.AD_ID AND a.CMP_ID = m.Cmp_ID
						--			INNER JOIN #Emp_Cons Ec ON Ec.emp_id = m.Emp_ID 
						--			Left outer JOIN
						--			(
						--				Select DISTINCT  MAD.AD_ID as AD_ID_arear, Isnull(SUM(M_AD_Amount),0) as ms_amount,MSS.Emp_id as Emp_id_arear  
						--					From t0210_monthly_ad_detail MAD  WITH (NOLOCK) 
						--					inner join T0201_MONTHLY_SALARY_SETT MSS  WITH (NOLOCK) on MAD.S_Sal_Tran_ID=MSS.S_Sal_Tran_ID and mad.emp_id = Mss.emp_id  
						--					inner join T0050_AD_MASTER on MAD.Ad_Id = T0050_AD_MASTER.Ad_ID and MAD.Cmp_ID = T0050_AD_MASTER.Cmp_Id
						--				where MAD.Cmp_ID = @Cmp_ID --and month(MSS.S_Eff_Date) = Month(@To_Date) and Year(MSS.S_Eff_Date) = Year(@To_Date) 
						--				      AND Cast(CONVERT(varchar(6), MAD.To_date, 112) As Numeric) between  Cast(CONVERT(varchar(6), @FROM_DATE, 112) As Numeric) AND Cast(CONVERT(varchar(6), @TO_DATE, 112) As Numeric)
						--					  and isnull(mad.M_AD_NOT_EFFECT_SALARY,0) = 1    and Ad_Active = 1 
						--				Group By MAD.AD_ID,MSS.Emp_ID
						--			) as MS_arear   on m.ad_id = MS_arear.AD_ID_arear and  m.emp_id = MS_arear.emp_id_arear									
						--WHERE -- MONTH(M.For_Date) = @Month AND YEAR(M.For_Date) =@Year AND
						----(m.For_Date = @From_Date) and 
						--(m.M_AD_Amount <> 0) AND (m.M_AD_Flag = 'I') and AD_NOT_EFFECT_SALARY = 1 and AD_PART_OF_CTC = 1 
						--AND (CASE WHEN @Show_Hidden_Allowance = 0 AND Hide_In_Reports = 1 THEN 0 ELSE 1 END )= 1  and m.Cmp_ID = @Cmp_ID  and	ISNULL(m.S_Sal_Tran_ID,0)=0   
						--order by a.Ad_Level,a.AD_Sort_name

						--select 444,* from #Yearly_Salary


						  	----added by jimit 24032017
						Insert Into  #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name) 						
						Select  @Cmp_ID,emp_Id,'i199','Production_Bonus' From #Emp_Cons						
						---ended
						  
						insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,AD_ID,AD_Level)
						select DISTINCT @Cmp_ID,EC.emp_ID,'i'+CAST(mad.AD_ID  as varchar(max)),AD_NAME ,MAD.AD_ID,AM.AD_LEVEL From #Emp_Cons EC	INNER JOIN  
							T0210_MONTHLY_AD_DETAIL MAD ON EC.EMP_ID = MAD.EMP_ID INNER JOIN T0050_AD_MASTER AM ON MAD.AD_ID = AM.AD_ID
						  WHERE M_AD_FLAG = 'i' AND  
						  --FOR_DATE >=@fROM_dATE AND FOR_dATE <=@TO_DATE 
						  --above condtion commented and below new condition added by Hardik 21/01/2016 as BMA has issue when employee has different salary cycle, now it will check with month and year only
						  Cast(CONVERT(varchar(6), MAD.To_date, 112) As Numeric) between  Cast(CONVERT(varchar(6), @FROM_DATE, 112) As Numeric) AND
						  Cast(CONVERT(varchar(6), @TO_DATE, 112) As Numeric)
						  --and (AM.AD_NOT_EFFECT_SALARY = 1 or MAD.ReimAmount >0 ) 
						  and (MAD.ReimAmount >0 ) -- change as per discussion with hardikbhai. on 15122016
						  and AM.Hide_In_Reports = 0  --Change by Jaina 12-09-2016
						  And Not Exists (select 1 from #Yearly_Salary Y Where Y.Emp_Id=MAD.Emp_ID And Y.AD_Id = Mad.AD_ID)
						  Order by AM.AD_LEVEL -- Added By Ali 18122013  
						
						
						
						-- Change place for arears done by ali -- 18122013
						insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
						select @Cmp_ID,emp_ID,'J2','Other Allowance' From #Emp_Cons 
						--select @Cmp_ID,emp_ID,'J2','Arrears' From #Emp_Cons -- Comment by nilesh patel on 06052016 After Discussion with Hardik bhai also change Name of Header
						-- Change place for arears done by ali -- 18122013
						
						-- commenetd by rohit because it add in respect head.
						--insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
						--select @Cmp_ID,emp_ID,'J16','Settlement Amount' From #Emp_Cons
						
						-----------Added by Hasmukh 29032013 ------
						insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
						select @Cmp_ID,emp_ID,'J20','WD OT Amount' From #Emp_Cons 

						insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
						select @Cmp_ID,emp_ID,'J21','WO OT Amount' From #Emp_Cons 

						insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
						select @Cmp_ID,emp_ID,'J22','HO OT Amount' From #Emp_Cons 

						insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name) -- Added by rohit on 13-dec-2013
						select @Cmp_ID,emp_ID,'J17','Leave Encashment Amount' From #Emp_Cons 
						
						insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name) -- Added by sumit 24092015
						select @Cmp_ID,emp_ID,'J18','Travel Amount' From #Emp_Cons

						insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name) -- Added by Mukti 20062017
						select @Cmp_ID,emp_ID,'J26','Uniform Refund Amount' From #Emp_Cons  
						
						--insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name) --Added By Jimit 02072018 -- Commeted By Sajid Beacause of Earning Side Shown in Yearly Report
						--select @Cmp_ID,emp_ID,'J27','Notice Period' From #Emp_Cons 

					    insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name) --Added By Sajid 02122021
						select @Cmp_ID,emp_ID,'J28','Notice Period (Earning)' From #Emp_Cons 
						
						insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name) --Added By Sajid 02122021
						select @Cmp_ID,emp_ID,'J29','Gratuity Amount' From #Emp_Cons 

						insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
						select @Cmp_ID,emp_ID,'J23','Gross' From #Emp_Cons 
						
						IF @ROUNDING <> 0
							Begin
								insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)	--Ankit 16072014
								select @Cmp_ID,emp_ID,'J24','Gross Round' From #Emp_Cons 
								
								insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)	--Ankit 16072014
								select @Cmp_ID,emp_ID,'J25','Total Gross' From #Emp_Cons 
							End
						
					
						-- Added by rohit For Add component which Not Effect in salary and Part of Ctc on 09102013
						if @with_ctc = 1 
							begin
							
								insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,AD_ID,AD_Level)
								select DISTINCT @Cmp_ID,EC.emp_ID,'K'+ CAST(MAD.AD_ID as varchar(max)),AD_NAME ,MAD.AD_ID,AM.AD_LEVEL From #Emp_Cons EC	INNER JOIN  
								T0210_MONTHLY_AD_DETAIL MAD ON EC.EMP_ID = MAD.EMP_ID INNER JOIN T0050_AD_MASTER AM ON MAD.AD_ID = AM.AD_ID
								WHERE M_AD_FLAG = 'i' AND  
								--FOR_DATE >=@fROM_dATE AND FOR_dATE <=@TO_DATE 
								--above condtion commented and below new condition added by Hardik 21/01/2016 as BMA has issue when employee has different salary cycle, now it will check with month and year only
								Cast(CONVERT(varchar(6), MAD.To_date, 112) As Numeric) between  Cast(CONVERT(varchar(6), @FROM_DATE, 112) As Numeric) AND Cast(CONVERT(varchar(6), @TO_DATE, 112) As Numeric)
								and AM.AD_NOT_EFFECT_SALARY = 1 And AM.AD_Part_Of_CTC = 1 and Effect_Net_Salary =0 
								AND (CASE WHEN @SHOW_HIDDEN_ALLOWANCE = 0  AND  AM.HIDE_IN_REPORTS = 1 THEN 0 ELSE 1 END )=1  --CHANGE BY JAINA 16-05-2017
								--and am.allowance_type <> 'R' 
								Order by AM.AD_LEVEL -- Added By Ali 18122013
	
								insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
								select @Cmp_ID,emp_ID,'L4','CTC' From #Emp_Cons 


							end
						--Ended by rohit on 09102013

						insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,CLAIM_ID)
						select @Cmp_ID,EC.emp_ID,'M1',CLAIM_NAME ,CLAIM_ID From #Emp_Cons EC	INNER JOIN  
						( SELECT DISTINCT CA.EMP_ID ,CA.CLAIM_ID,CLAIM_NAME FROM T0210_MONTHLY_CLAIM_PAYMENT CP INNER JOIN  T0120_CLAIM_APPROVAL CA ON CP.CLAIM_APR_ID =CA.CLAIM_APR_iD  
						INNER JOIN T0040_CLAIM_MASTER  CM ON CA.CLAIM_ID = CM.CLAIM_ID 
						  WHERE 
						  --CLAIM_PAYMENT_DATE >=@FROM_DATE  AND CLAIM_PAYMENT_dATE <=@TO_DATE 
						  --above condtion commented and below new condition added by Hardik 21/01/2016 as BMA has issue when employee has different salary cycle, now it will check with month and year only
						  Cast(CONVERT(varchar(6), CLAIM_PAYMENT_DATE, 112) As Numeric) between  Cast(CONVERT(varchar(6), @FROM_DATE, 112) As Numeric) AND Cast(CONVERT(varchar(6), @TO_DATE, 112) As Numeric)
						  )Q ON EC.EMP_ID = Q.EMP_ID

						insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,AD_ID,AD_Level)
						select DISTINCT @Cmp_ID,EC.emp_ID,'N' + CAST(mad.ad_id as varchar(max)),AD_NAME ,MAD.AD_ID,AM.AD_LEVEL  From #Emp_Cons EC	INNER JOIN  
							T0210_MONTHLY_AD_DETAIL MAD ON EC.EMP_ID = MAD.EMP_ID INNER JOIN T0050_AD_MASTER AM ON MAD.AD_ID = AM.AD_ID
						  WHERE M_AD_FLAG = 'D' AND  
						  --FOR_DATE >=@fROM_dATE AND FOR_dATE <=@TO_DATE 
						  --above condtion commented and below new condition added by Hardik 21/01/2016 as BMA has issue when employee has different salary cycle, now it will check with month and year only
						  Cast(CONVERT(varchar(6), MAD.To_date, 112) As Numeric) between  Cast(CONVERT(varchar(6), @FROM_DATE, 112) As Numeric) AND Cast(CONVERT(varchar(6), @TO_DATE, 112) As Numeric)
						  and (AM.AD_NOT_EFFECT_SALARY = 0 Or MAD.ReimAmount >0 or isnull(mad.FOR_FNF,0)=1 ) -- change as per discussion with hardikbhai. on 15122016
						  Order by AM.AD_LEVEL -- Added By Ali 18122013

						insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
						select @Cmp_ID,emp_ID,'P11','PT' From #Emp_Cons 

						insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
						select @Cmp_ID,emp_ID,'P12','LWF' From #Emp_Cons 

						insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
						select @Cmp_ID,emp_ID,'P13','REVENUE' From #Emp_Cons 
						
						insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
						select @Cmp_ID,emp_ID,'P14','ADVANCE' From #Emp_Cons
						
						insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
						select @Cmp_ID,emp_ID,'P23','LOAN' From #Emp_Cons
						
						insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
						select @Cmp_ID,emp_ID,'P24','Loan Int Amt' From #Emp_Cons 
						
						insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
						select @Cmp_ID,emp_ID,'P25','Oth Ded.' From #Emp_Cons  
						
						insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name) -- Added by Gadriwala 09012015
						select @Cmp_ID,emp_ID,'P26','Gate Pass Amount' From #Emp_Cons  
						
						insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name) -- Added by Mukti 07042015
						select @Cmp_ID,emp_ID,'P27','Asset Installment Amount' From #Emp_Cons  
						
						insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name) -- Added by Sumit 24092015
						select @Cmp_ID,emp_ID,'P18','Travel Advance Amount' From #Emp_Cons  
						
						insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name) -- Added by Mukti 20062017
						select @Cmp_ID,emp_ID,'P28','Uniform Installment Amount' From #Emp_Cons  
						
						insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name) -- Added by jimit 28072017
						select @Cmp_ID,emp_ID,'P29','Late Dedu.' From #Emp_Cons

						insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name) --Added By Sajid 02122021
						select @Cmp_ID,emp_ID,'J27','Notice Period (Deduction)' From #Emp_Cons 
						
						
				End
				
			insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
			select @Cmp_ID,emp_ID,'P98','NET Total Deduction' From #Emp_Cons 

			-- Added by rohit on 03082016
			insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,AD_ID,AD_Level)
			select DISTINCT @Cmp_ID,EC.emp_ID,'K'+ CAST(MAD.AD_ID as varchar(max)),AD_NAME ,MAD.AD_ID,AM.AD_LEVEL From #Emp_Cons EC	INNER JOIN  
			T0210_MONTHLY_AD_DETAIL MAD ON EC.EMP_ID = MAD.EMP_ID INNER JOIN T0050_AD_MASTER AM ON MAD.AD_ID = AM.AD_ID
			WHERE M_AD_FLAG = 'i' AND  
			--FOR_DATE >=@fROM_dATE AND FOR_dATE <=@TO_DATE 
			--above condtion commented and below new condition added by Hardik 21/01/2016 as BMA has issue when employee has different salary cycle, now it will check with month and year only
			Cast(CONVERT(varchar(6), MAD.To_date, 112) As Numeric) between  Cast(CONVERT(varchar(6), @FROM_DATE, 112) As Numeric) AND Cast(CONVERT(varchar(6), @TO_DATE, 112) As Numeric)
			and AM.AD_NOT_EFFECT_SALARY = 1 And AM.AD_Part_Of_CTC = 1 and Effect_Net_Salary =1 and am.allowance_type <> 'R' -- added by rohit due reimbershment claim already add in table on 20062016

			Order by AM.AD_LEVEL -- Added By Ali 18122013
			
			---- added by rohit on 15072016
			insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,AD_ID,AD_Level)
			select DISTINCT @Cmp_ID,EC.emp_ID,'K'+ CAST(MAD.AD_ID as varchar(max)),AD_NAME ,MAD.AD_ID,AM.AD_LEVEL From #Emp_Cons EC	INNER JOIN  
			T0210_MONTHLY_AD_DETAIL MAD ON EC.EMP_ID = MAD.EMP_ID INNER JOIN T0050_AD_MASTER AM ON MAD.AD_ID = AM.AD_ID
			WHERE M_AD_FLAG = 'D' AND  
			Cast(CONVERT(varchar(6), MAD.To_date, 112) As Numeric) between  Cast(CONVERT(varchar(6), @FROM_DATE, 112) As Numeric) AND Cast(CONVERT(varchar(6), @TO_DATE, 112) As Numeric)
			and AM.AD_NOT_EFFECT_SALARY = 1 And AM.Effect_Net_Salary = 1 and am.allowance_type <> 'R' 
			Order by AM.AD_LEVEL 
			-- ended by rohit on 03082016
			
			
			insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
			select @Cmp_ID,emp_ID,'P99','NET SALARY' From #Emp_Cons 
			
			--Added By Jimit 06032018
			IF @BONUS_AMOUNT = 1 
				BEGIN
					insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
					select @Cmp_ID,emp_ID,'P999','Bonus Amount' From #Emp_Cons
				END
			--Ended
			
			IF @ROUNDING <> 0 AND @Net_Salary_Round <> -1
				Begin
					
					
					insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)	--Ankit 17072014
					select @Cmp_ID,emp_ID,'P100','Net Round' From #Emp_Cons 
					
					insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)	--Ankit 17072014
					select @Cmp_ID,emp_ID,'P101','TOTAL NET' From #Emp_Cons 
				End
		
		
		
		declare @Temp_Date datetime
		declare @TempEnd_Date datetime
		Declare @count numeric 
		
		set @Temp_Date = @From_Date 
		set @TempEnd_Date = dateadd(mm,1,@From_Date )  -1 
		set @count = 1 
		
		Declare @sqlQuery as Varchar(Max)
		Declare @Str_Month as varchar(Max)
		DECLARE @TO_MONTH_DATE AS DATETIME		
		set @sqlQuery = ''
		set @Str_Month = ''
		
		CREATE TABLE #ACTUAL_DATA 
		(
		Increment_Id INT,
		Emp_Id INT,
		Basic_Salary FLOAT,
		CTC FLOAT,
		Emp_PT_Amount FLOAT,
		Gross_Salary FLOAT,
		Branch_ID	int
		)

		declare @loopCounter as numeric
		set @loopCounter = 1 --added by Mr.mehul 17102022 for Bug #16434 
		while @Temp_Date <=@To_Date 
			Begin
					set @Month =month(@TempEnd_Date)
					set @Year = year(@TempEnd_Date)
					
					if @count > 12 
					begin
						if @loopCounter > 12  --added by Mr.mehul 17102022 for Bug #16434
						begin
							set @loopCounter = 1
							set @Str_Month = 'Month_' + CAST(@loopCounter as varchar(10))
						end
						else
						begin
							set @Str_Month = 'Month_' + CAST(@loopCounter as varchar(10))
						end
					end
					else
					begin
						set @Str_Month = 'Month_' + CAST(@count as varchar(10))
					end  --added by Mr.mehul 17102022 for Bug #16434
					
					


			-- Added by rohit for Single change Effect in All month on 16122015					
					--Update #Yearly_Salary 
					--		set Month_1 = 1 
					--		From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
					--		--Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
					--		Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year --and SP.Publish_Flag = 1
					--			and Def_ID = '51'

					set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= 1  From #Yearly_Salary  Ys  
									inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
									and month(ms.month_end_date) = ' + cast(@Month as varchar(10))  + ' and Year(ms.month_end_date) =  ' + cast(@Year as varchar(10))  + 
									' and Def_ID = ''51'''
									--and isnull(ms.is_fnf,0)=0 commented By Mukti 27012016 to show record of FNF done 
					exec (@sqlQuery)					
					set @sqlQuery= ''

				
				--Added by Mukti(05122020)START TO Get Actual Salary Structure Columns Wonder
					IF @Report_Call='ALL1'
						BEGIN	
							SET @TO_MONTH_DATE=DBO.GET_MONTH_END_DATE(@Month,@Year)

							TRUNCATE TABLE #Tbl_Get_AD
							IF OBJECT_ID ('tempdb..#Tbl_Yearly_Salary_Register') IS NULL
								BEGIN
									INSERT INTO #Tbl_Get_AD
									Exec P_Emp_Revised_Allowance_Get @CMP_id,@TO_MONTH_DATE,@Constraint
								END
							ELSE
								BEGIN
									Exec P_Emp_Revised_Allowance_Get @CMP_id,@TO_MONTH_DATE,@Constraint

									INSERT INTO #Tbl_Get_AD
									SELECT * FROM #Tbl_Yearly_Salary_Register
								END

							TRUNCATE TABLE #ACTUAL_DATA

							INSERT INTO #ACTUAL_DATA
							SELECT I_Q.Increment_Id,YS.Emp_Id,I_Q.Basic_Salary,I_Q.CTC,I_Q.Emp_PT_Amount,I_Q.Gross_Salary,I_Q.Branch_ID
							FROM #Emp_Cons  Ys 
							INNER JOIN	T0095_INCREMENT I_Q ON YS.Emp_ID = I_Q.Emp_ID INNER JOIN 
											 (
												SELECT	MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
												FROM	T0095_INCREMENT I2 WITH (NOLOCK)  
														INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
																	FROM	T0095_INCREMENT I3 WITH (NOLOCK)
																	WHERE	 I3.cmp_ID =@CMP_ID
																			And I3.Increment_Effective_Date<= @TO_MONTH_DATE
																			and I3.Increment_Type NOT In ('Transfer','Deputation')
																	GROUP BY I3.Emp_ID
																	) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
												GROUP BY I2.Emp_ID
											) I2_Q ON I_Q.Emp_ID=I2_Q.Emp_ID AND I_Q.Increment_ID=I2_Q.INCREMENT_ID    
							Inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID AND  MONTH(Month_End_Date) = @Month  AND YEAR(Month_End_Date) =@Year
					

							set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + ' = AD.Basic_Salary
							FROM #Yearly_Salary  Ys 
							INNER JOIN #ACTUAL_DATA  AD ON AD.Emp_Id=YS.Emp_Id
							WHERE  DEF_ID=''53'''
					
							exec (@sqlQuery)					
							set @sqlQuery= ''
					
							set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + ' = AD.Basic_Salary + isnull(adv1.E_AD_Amount,0)
											from #Yearly_Salary  Ys 
											INNER JOIN #ACTUAL_DATA  AD ON AD.Emp_Id=YS.Emp_Id
											LEFT JOIN(select t1.EMP_ID,t1.CMP_ID,Isnull(SUM(e_Ad_Amount),0) as e_Ad_Amount,Increment_ID from T0100_EMP_EARN_DEDUCTION as t1  WITH (NOLOCK) 
											inner join T0050_AD_MASTER as t3 WITH (NOLOCK)  on t1.ad_id = t3.AD_ID where E_AD_FLAG = ''I'' and t3.AD_NOT_EFFECT_SALARY = 0 and t3.AD_ACTIVE = 1 
											group by t1.EMP_ID,t1.CMP_ID,Increment_ID) as adv1 on YS.Emp_ID = adv1.EMP_ID AND YS.Cmp_ID = adv1.CMP_ID and AD.Increment_Id=adv1.Increment_ID
											WHERE DEF_ID=''C2'''																	
							exec (@sqlQuery)					
							set @sqlQuery= ''

							set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + ' = AD.CTC
											 FROM #Yearly_Salary  Ys 
											 INNER JOIN #ACTUAL_DATA  AD ON AD.Emp_Id=YS.Emp_Id
											 WHERE DEF_ID=''E3'''																	
							exec (@sqlQuery)					
							set @sqlQuery= ''


							set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + ' = (case when SMM.PT_Deduction_Type = ''Monthly'' then AD.Emp_PT_Amount else 0 end)
											from #Yearly_Salary  Ys 									
											INNER JOIN #ACTUAL_DATA  AD ON AD.Emp_Id=YS.Emp_Id
											inner join T0030_BRANCH_MASTER as bm WITH (NOLOCK)  on AD.Branch_ID = bm.Branch_ID and YS.Cmp_ID = bm.Cmp_ID
											Left Outer Join T0020_STATE_MASTER SMM WITH (NOLOCK)  on bm.State_Id = SMM.State_Id And bm.Cmp_Id = SMM.Cmp_Id
											Inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID AND  MONTH(Month_End_Date) = ' + cast(@Month as varchar(10))  + ' AND YEAR(Month_End_Date) = ' + cast(@Year as varchar(10))  +'
											WHERE DEF_ID=''C3'''																	
							exec (@sqlQuery)					
							set @sqlQuery= ''

									set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + ' = AD.Emp_PT_Amount + isnull(TAD.E_AD_Amount,0)
											from #Yearly_Salary  Ys 									
											INNER JOIN #ACTUAL_DATA  AD ON AD.Emp_Id=YS.Emp_Id
											LEFT JOIN 
											  (SELECT     T.EMP_ID, T.E_AD_AMOUNT, T.AD_ID
												FROM         #Tbl_Get_AD AS T
												INNER join T0050_AD_MASTER AS A  WITH (NOLOCK) ON T.AD_ID=A.AD_ID AND AD_FLAG = ''D''
												WHERE      (T.E_AD_PERCENTAGE > 0) OR (T.E_AD_AMOUNT > 0)) AS TAD ON  YS.EMP_ID = TAD.EMP_ID and (TAD.E_AD_AMOUNT <> 0)
											WHERE DEF_ID=''E1'''									
									exec (@sqlQuery)					
									set @sqlQuery= ''

									--select * from  #Tbl_Get_AD
									set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + ' =(ISNULL(adv1.e_Ad_Amount,0) + Isnull(AD.BASIC_Salary,0))- (Isnull(AD.Emp_PT_Amount,0) +	isnull(TAD.E_AD_Amount,0))
											from #Yearly_Salary  Ys 
											INNER JOIN #ACTUAL_DATA  AD ON AD.Emp_Id=YS.Emp_Id
											LEFT JOIN 
											  (SELECT     T.EMP_ID, T.E_AD_AMOUNT, T.AD_ID
												FROM         #Tbl_Get_AD AS T
												INNER join T0050_AD_MASTER AS A  WITH (NOLOCK) ON T.AD_ID=A.AD_ID AND AD_FLAG = ''D''
												WHERE      (T.E_AD_PERCENTAGE > 0) OR (T.E_AD_AMOUNT > 0)) AS TAD ON  YS.EMP_ID = TAD.EMP_ID and (TAD.E_AD_AMOUNT <> 0)
											LEFT JOIN(select t1.EMP_ID,t1.CMP_ID,Isnull(SUM(e_Ad_Amount),0) as e_Ad_Amount,Increment_ID from T0100_EMP_EARN_DEDUCTION as t1  WITH (NOLOCK) 
													  inner join T0050_AD_MASTER as t3 WITH (NOLOCK)  on t1.ad_id = t3.AD_ID where E_AD_FLAG = ''I'' and t3.AD_NOT_EFFECT_SALARY = 0 and t3.AD_ACTIVE = 1 
													  group by t1.EMP_ID,t1.CMP_ID,Increment_ID) as adv1 on YS.Emp_ID = adv1.EMP_ID AND YS.Cmp_ID = adv1.CMP_ID and AD.Increment_Id=adv1.Increment_ID
											WHERE DEF_ID=''E2'''									
									exec (@sqlQuery)					
									set @sqlQuery= ''
					END
				--Added by Mukti(05122020)END TO Get Actual Salary Structure Columns Wonder

						set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + ' = (Salary_Amount + isnull(Arear_Basic ,0) + isnull(Qry.S_Salary_Amount,0)) + IsNull(Basic_Salary_Arear_cutoff,0)
							From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID and Def_ID = ''F1'' and month(ms.month_end_date) = ' + cast(@Month as varchar(10))  + ' and Year(ms.month_end_date) =  ' + cast(@Year as varchar(10))  +
							' Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
							left join
							(   SELECT  ms.Emp_ID,SUM(ms.S_Salary_Amount) AS S_Salary_Amount ,S_Eff_Date
								FROM T0201_MONTHLY_SALARY_SETT ms INNER JOIN #Emp_Cons ec ON ms.Emp_ID =ec.emp_ID 
									AND  MONTH(S_Eff_Date) = ' + cast(@Month as varchar(10))  + ' AND YEAR(S_Eff_Date) = ' + cast(@Year as varchar(10))  +'
								GROUP BY ms.Emp_ID,S_Eff_Date
							 ) Qry ON Qry.Emp_ID = Ys.Emp_ID			 
							Where (SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1) '--Mukti(03022016)or isnull(ms.is_fnf,0)=1
							--and isnull(ms.is_fnf,0)=0 commented By Mukti 27012016 to show record of FNF done 
					
					exec (@sqlQuery)
					
					set @sqlQuery= ''

					--Update #Yearly_Salary 
					--		set Month_1 = Other_Allow_Amount + isnull(Arear_Basic ,0)	-- Changed By Gadriwala(add field Arear_basic) 26042014
					--		From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
					--		Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
					--		Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
					--			and Def_ID = 'J2'
					-- Other_Allow_Amount + isnull(Arear_Basic ,0) Remove Arrear Basic By Nilesh already Basic Sum in Allowance Details on 06052016
					set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + ' = Other_Allow_Amount 
							From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
							Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
							Where Month(Month_End_Date) = ' + cast(@Month as varchar(10)) +' and Year(Month_End_Date) = ' + cast(@Year as varchar(10)) +' and 
							(SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1)  and Def_ID = ''J2''' --Mukti(03022016)or isnull(ms.is_fnf,0)=1
							--and isnull(ms.is_fnf,0)=0 commented By Mukti 27012016 to show record of FNF done 
					exec (@sqlQuery)
					set @sqlQuery= ''		

					--Update #Yearly_Salary 
					--		set Month_1 = Gross_Salary
					--		From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
					--		Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
					--		Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
					--			and Def_ID = 'J23'
					
					--'' Add Arears Amount in Gross -Ankit 05052016
					--  Gross_Salary + Other_Allow_Amount + isnull(Arear_Basic ,0) -Comment by nilesh patel on 06052016 After Discuss with Hardik bhai 
					-- commenet and added by rohit on 03082016
					--set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= Gross_Salary
					--		From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
					--		Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
					--		Where Month(Month_End_Date) = ' + cast(@Month as varchar(10)) +' and Year(Month_End_Date) = ' + cast(@Year as varchar(10)) +' and
					--		(SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1)  and Def_ID = ''J23''' --Mukti(03022016)or isnull(ms.is_fnf,0)=1
					--		--and isnull(ms.is_fnf,0)=0 commented By Mukti 27012016 to show record of FNF done 
					
						set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= Gross_Salary + isnull(S_gross_salary,0) - isnull(S_Net_Amount,0)
							From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
							Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
							left join
							(   SELECT  ms.Emp_ID,SUM(ms.S_gross_salary) AS S_gross_salary,SUM(ms.S_net_Amount) AS S_net_Amount ,S_Eff_Date
								FROM T0201_MONTHLY_SALARY_SETT ms INNER JOIN #Emp_Cons ec ON ms.Emp_ID =ec.emp_ID 
									AND  MONTH(S_Eff_Date) = ' + cast(@Month as varchar(10))  + ' AND YEAR(S_Eff_Date) = ' + cast(@Year as varchar(10))  +'
								GROUP BY ms.Emp_ID,S_Eff_Date
							 ) Qry ON Qry.Emp_ID = Ys.Emp_ID
							Where Month(Month_End_Date) = ' + cast(@Month as varchar(10)) +' and Year(Month_End_Date) = ' + cast(@Year as varchar(10)) +' and
							(SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1)  and Def_ID = ''J23''' --Mukti(03022016)or isnull(ms.is_fnf,0)=1
							--and isnull(ms.is_fnf,0)=0 commented By Mukti 27012016 to show record of FNF done 
					
					exec (@sqlQuery)
					set @sqlQuery= ''		
								
			
					--Update #Yearly_Salary 
					--		set Month_1 = Total_Earning_Fraction
					--		From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
					--		Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
					--		Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
					--			and Def_ID = 'J24'
								
					set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= Total_Earning_Fraction
							From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
							Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
							Where Month(Month_End_Date) = ' + cast(@Month as varchar(10)) +' and Year(Month_End_Date) = ' + cast(@Year as varchar(10)) +' and 
							(SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1)  and Def_ID = ''J24''' --Mukti(03022016)or isnull(ms.is_fnf,0)=1
							--and isnull(ms.is_fnf,0)=0 commented By Mukti 27012016 to show record of  FNF done 
					exec (@sqlQuery)
					set @sqlQuery= ''
			
					--Update #Yearly_Salary 
					--		set Month_1 = Gross_Salary + Total_Earning_Fraction
					--		From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
					--		Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
					--		Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
					--			and Def_ID = 'J25'
					
					-- comment and added by rohit on 03082016
					--set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= Gross_Salary + Total_Earning_Fraction
					--		From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
					--		Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
					--		Where Month(Month_End_Date) = ' + cast(@Month as varchar(10)) + 'and Year(Month_End_Date) = ' +cast(@Year as varchar(10)) +'and 
					--		(SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1)  and Def_ID = ''J25''' --Mukti(03022016)or isnull(ms.is_fnf,0)=1
					--		--and isnull(ms.is_fnf,0)=0 commented By Mukti 27012016 to show record of FNF done 
					
					set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= Gross_Salary  + isnull(S_gross_salary,0) - isnull(S_Net_Amount,0) + Total_Earning_Fraction
							From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
							Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
							left join
							(   SELECT  ms.Emp_ID,SUM(ms.S_gross_salary) AS S_gross_salary,SUM(ms.S_net_Amount) AS S_net_Amount ,S_Eff_Date
								FROM T0201_MONTHLY_SALARY_SETT ms INNER JOIN #Emp_Cons ec ON ms.Emp_ID =ec.emp_ID 
									AND  MONTH(S_Eff_Date) = ' + cast(@Month as varchar(10))  + ' AND YEAR(S_Eff_Date) = ' + cast(@Year as varchar(10))  +'
								GROUP BY ms.Emp_ID,S_Eff_Date
							 ) Qry ON Qry.Emp_ID = Ys.Emp_ID
							Where Month(Month_End_Date) = ' + cast(@Month as varchar(10)) + 'and Year(Month_End_Date) = ' +cast(@Year as varchar(10)) +'and 
							(SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1)  and Def_ID = ''J25''' --Mukti(03022016)or isnull(ms.is_fnf,0)=1
							--and isnull(ms.is_fnf,0)=0 commented By Mukti 27012016 to show record of FNF done 
					
					exec (@sqlQuery)
					set @sqlQuery= ''		
							
			
					--Update #Yearly_Salary 
					--		set Month_1 = PT_Amount 
					--		From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
					--		Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
					--		Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
					--			and Def_ID = 'P11'
								
					set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= PT_Amount 
							From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
							Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
							Where Month(Month_End_Date) = ' + cast(@Month as varchar(10)) + 'and Year(Month_End_Date) = ' + cast(@Year as varchar(10)) +' and 
							(SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1) and Def_ID = ''P11'''
							--and isnull(ms.is_fnf,0)=0 commented By Mukti 27012016 to show record of FNF done 
					exec (@sqlQuery)
					set @sqlQuery= ''		
							
					--Update #Yearly_Salary 
					--	set Month_1 = LWF_Amount 
					--	From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
					--	Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
					--	Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
					--		and Def_ID = 'P12'
									
					set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= LWF_Amount 
						From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
						Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
						Where Month(Month_End_Date) = ' + cast(@Month as varchar(10)) + 'and Year(Month_End_Date) = '+ cast(@Year as varchar(10)) + 'and
						(SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1) and Def_ID = ''P12'''
						--and isnull(ms.is_fnf,0)=0 commented By Mukti 27012016 to show record of FNF done 
					exec (@sqlQuery)
					set @sqlQuery= ''		
									
						--Update #Yearly_Salary 
						--	set Month_1 = Revenue_Amount
						--	From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
						--	Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
						--	Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
						--		and Def_ID = 'P13'
								
					set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= Revenue_Amount
							From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
							Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
							Where Month(Month_End_Date) = ' + cast(@Month as varchar(10)) + ' and Year(Month_End_Date) = ' + cast(@Year as varchar(10)) + 'and 
							(SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1)  and Def_ID = ''P13'''
							--and isnull(ms.is_fnf,0)=0 commented By Mukti 27012016 to show record of FNF done 
					exec (@sqlQuery)
					set @sqlQuery= ''			

					--Update #Yearly_Salary		
					--		set Month_1 = Advance_Amount
					--		From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
					--		Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
					--		Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
					--			and Def_ID = 'P14'
									
					set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= Advance_Amount
							From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
							Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
							Where Month(Month_End_Date) = ' + cast(@Month as varchar(10)) + ' and Year(Month_End_Date) = ' + cast(@Year as varchar(10)) + 'and 
							(SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1) and Def_ID = ''P14'''
							--and isnull(ms.is_fnf,0)=0 commented By Mukti 27012016 to show record of FNF done 
					exec (@sqlQuery)
					set @sqlQuery= ''

					
					
						
						--Update #Yearly_Salary		
						--	set Month_1 = Total_Dedu_Amount
						--	From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
						--	Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year  
						--	Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
						--		and Def_ID = 'P98'
					-- comment and added by rohit on 03082016				
					--set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= Total_Dedu_Amount
					--		From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
					--		Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year  
					--		Where Month(Month_End_Date) = ' + cast(@Month as varchar(10)) + ' and Year(Month_End_Date) = ' + cast(@Year as varchar(10)) + 'and 
					--		(SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1) and Def_ID = ''P98'''
					--		--and isnull(ms.is_fnf,0)=0 commented By Mukti 27012016 to show record of FNF done 
					
						set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= Total_Dedu_Amount + isnull(S_total_Dedu_Amount,0)
							From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
							Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year  
							left join
							(   SELECT  ms.Emp_ID,SUM(ms.S_total_Dedu_Amount) AS S_total_Dedu_Amount ,S_Eff_Date
								FROM T0201_MONTHLY_SALARY_SETT ms INNER JOIN #Emp_Cons ec ON ms.Emp_ID =ec.emp_ID 
									AND  MONTH(S_Eff_Date) = ' + cast(@Month as varchar(10))  + ' AND YEAR(S_Eff_Date) = ' + cast(@Year as varchar(10))  +'
								GROUP BY ms.Emp_ID,S_Eff_Date
							 ) Qry ON Qry.Emp_ID = Ys.Emp_ID
							Where Month(Month_End_Date) = ' + cast(@Month as varchar(10)) + ' and Year(Month_End_Date) = ' + cast(@Year as varchar(10)) + 'and 
							(SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1) and Def_ID = ''P98'''
							--and isnull(ms.is_fnf,0)=0 commented By Mukti 27012016 to show record of FNF done 
							
					exec (@sqlQuery)
					set @sqlQuery= ''

					--Update #Yearly_Salary		
					--		set Month_1 = Net_Amount
					--		From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
					--		Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year  
					--		Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
					--			and Def_ID = 'P99'		
					set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= Net_Amount
							From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
							Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year  
							Where Month(Month_End_Date) = ' + cast(@Month as varchar(10)) + ' and Year(Month_End_Date) = ' + cast(@Year as varchar(10)) + 'and 
							(SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1)  and Def_ID = ''P99'''
							--and isnull(ms.is_fnf,0)=0 commented By Mukti 27012016 to show record of FNF done 
					exec (@sqlQuery)
					set @sqlQuery= ''			
						
					
					--Added By Jimit 06032018
					IF @BONUS_AMOUNT = 1 
						BEGIN
								set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= Bonus_Amount
												 From	#Yearly_Salary  Ys  inner join 
														T0100_Bonus_Slabwise Bs on ys.emp_ID = bs.emp_ID								
												 Where  Bonus_Effect_Month = ' + cast(@Month as varchar(10)) + ' and 
														Bonus_Effect_Year = ' + cast(@Year as varchar(10)) + ' and 
														Def_ID = ''P999'''							
						
						exec (@sqlQuery)
						set @sqlQuery= ''
						END
					--Ended
					
						--Added By Jimit 02072018  for RK Notice period amount is not coming seperately
					--set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= Short_Fall_Dedu_Amount
					--		From #Yearly_Salary  Ys  inner join
					--			 T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID								 
					--		Where Month(Month_End_Date) = ' + cast(@Month as varchar(10)) + ' and Year(Month_End_Date) = ' + cast(@Year as varchar(10)) + 'and 
					--		(isnull(ms.is_fnf,0)=1) and Def_ID = ''J27'''

					  set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= Short_Fall_Dedu_Amount
							From #Yearly_Salary  Ys  inner join
								 T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID	
								 INNER JOIN T0100_LEFT_EMP LE ON ys.emp_ID  = LE.Emp_ID
							Where Month(Month_End_Date) = ' + cast(@Month as varchar(10)) + ' and Year(Month_End_Date) = ' + cast(@Year as varchar(10)) + 'and 
							(isnull(ms.is_fnf,0)=1) and LE.IS_Terminate<>1 and  Def_ID = ''J27''' 
								
						exec (@sqlQuery)
						set @sqlQuery= ''

						-- Added By Sajid  02122021
								set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= Short_Fall_Dedu_Amount
							From #Yearly_Salary  Ys  inner join
								 T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID	
								 INNER JOIN T0100_LEFT_EMP LE ON ys.emp_ID  = LE.Emp_ID
							Where Month(Month_End_Date) = ' + cast(@Month as varchar(10)) + ' and Year(Month_End_Date) = ' + cast(@Year as varchar(10)) + 'and 
							(isnull(ms.is_fnf,0)=1) and LE.IS_Terminate=1 and  Def_ID = ''J28''' 
										
					exec (@sqlQuery)
					set @sqlQuery= ''

											-- Added By Sajid  02122021
								set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= Gratuity_Amount
							From #Yearly_Salary  Ys  inner join
								 T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID	
								 INNER JOIN T0100_LEFT_EMP LE ON ys.emp_ID  = LE.Emp_ID
							Where Month(Month_End_Date) = ' + cast(@Month as varchar(10)) + ' and Year(Month_End_Date) = ' + cast(@Year as varchar(10)) + 'and 
							(isnull(ms.is_fnf,0)=1) and Def_ID = ''J29''' 
										
					exec (@sqlQuery)
					set @sqlQuery= ''

					-- Added By Sajid  02122021
					
					--ENDED
						
							IF @ROUNDING <> 0 AND @Net_Salary_Round <> -1
								Begin
								
									--Update #Yearly_Salary		
									--set Month_1 = Net_Amount - Net_Salary_Round_Diff_Amount
									--From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
									--Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
									--Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
									--	and Def_ID = 'P99'
									
									set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= Net_Amount - Net_Salary_Round_Diff_Amount
									From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
									Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year  
									Where Month(Month_End_Date) = ' + cast(@Month as varchar(10)) + ' and Year(Month_End_Date) = ' + cast(@Year as varchar(10)) + 'and 
									(SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1)  and Def_ID = ''P99'''
									--and isnull(ms.is_fnf,0)=0 commented By Mukti 27012016 to show record of FNF done 
									exec (@sqlQuery)
									set @sqlQuery= ''		
														
														
									--Update #Yearly_Salary		
									--set Month_1 = Net_Salary_Round_Diff_Amount
									--From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
									--Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
									--Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
									--	and Def_ID = 'P100'
									
									set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= Net_Salary_Round_Diff_Amount
									From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
									Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
									Where Month(Month_End_Date) = ' + cast(@Month as varchar(10)) + ' and Year(Month_End_Date) = ' + cast(@Year as varchar(10)) + 'and 
									(SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1)  and Def_ID = ''P100'''
									--and isnull(ms.is_fnf,0)=0 commented By Mukti 27012016 to show record of FNF done 
									exec (@sqlQuery)
									set @sqlQuery= ''		
										
									--Update #Yearly_Salary		
									--set Month_1 = Net_Amount 
									--From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
									--Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
									--Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
									--	and Def_ID = 'P101'
									
									set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= Net_Amount 
									From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
									Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
									Where Month(Month_End_Date) = ' + cast(@Month as varchar(10)) + ' and Year(Month_End_Date) = ' + cast(@Year as varchar(10)) + 'and 
									(SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1)  and Def_ID = ''P101'''
									--and isnull(ms.is_fnf,0)=0 commented By Mukti 27012016 to show record of FNF done 
									exec (@sqlQuery)
									set @sqlQuery= ''	
								End
								
							--Update #Yearly_Salary 
							--set Month_1 = m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0)
							--From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on 
							--	YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID  inner join T0050_AD_MASTER AM ON 
							--	 MAD.AD_ID = AM.AD_ID
							--Where mad.For_Date =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD where TSMAD.Emp_ID = MAD.Emp_ID and To_date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date)  order by tsmad.For_Date desc )
							--and isnull(mad.S_Sal_Tran_ID,0) = 0	and MAD.M_AD_NOT_EFFECT_SALARY=0
							
							
							
							--Update #Yearly_Salary 
							--set Month_1 = m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0)
							--From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID  
							--						 inner join T0050_AD_MASTER AM ON MAD.AD_ID = AM.AD_ID
							--						 --Inner JOIN #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(MAD.To_date) = SP.P_Month and Year(MAD.To_date) = SP.P_Year 
							--Where mad.For_date =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD 
							--						   where TSMAD.Emp_ID = MAD.Emp_ID and To_date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date) and TSMAD.AD_ID = MAD.AD_ID 
							--						   order by tsmad.For_Date desc )
							--and isnull(mad.S_Sal_Tran_ID,0) = 0	and MAD.M_AD_NOT_EFFECT_SALARY=0 --and SP.Publish_Flag = 1
							----Commented and Changed by Sumit for same date entry of TDS 25112015
							
							-- comment and added by rohit
							--set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0)
							--From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID 
							--						 inner join t0200_monthly_salary ms on ms.sal_tran_id= MAD.sal_tran_id and ms.emp_ID = MAD.emp_ID   
							--						 inner join T0050_AD_MASTER AM ON MAD.AD_ID = AM.AD_ID
							--						 Inner JOIN #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(MAD.To_date) = SP.P_Month and Year(MAD.To_date) = SP.P_Year 
							--Where Month(to_Date)= ' + Cast(@Month as varchar(3)) + ' And Year(To_Date) = '+ Cast(@Year as varchar(4)) + ' 
							--and isnull(mad.S_Sal_Tran_ID,0) = 0	and MAD.M_AD_NOT_EFFECT_SALARY=0 and (SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1)'
							----and isnull(ms.is_fnf,0)=0 commented By Mukti 27012016 to show record of FNF done 
							
							set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0) + isnull(MS_arear.ms_amount,0) + IsNull(M_AREAR_AMOUNT_Cutoff,0)
							From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID 
													 inner join t0200_monthly_salary ms on ms.sal_tran_id= MAD.sal_tran_id and ms.emp_ID = MAD.emp_ID   
													 inner join T0050_AD_MASTER AM ON MAD.AD_ID = AM.AD_ID
													 Inner JOIN #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(MAD.To_date) = SP.P_Month and Year(MAD.To_date) = SP.P_Year 
													  left Join
								 (	Select  MAD.AD_ID as AD_ID_arear, Isnull(SUM(M_AD_Amount),0) as ms_amount,MSS.Emp_id as emp_id_arear  From t0210_monthly_ad_detail MAD inner join
							T0201_MONTHLY_SALARY_SETT MSS on MAD.S_Sal_Tran_ID=MSS.S_Sal_Tran_ID and mad.emp_id = Mss.emp_id  inner join 
							T0050_AD_MASTER on MAD.Ad_Id = T0050_AD_MASTER.Ad_ID
							and MAD.Cmp_ID = T0050_AD_MASTER.Cmp_Id
						where MAD.Cmp_ID = ' + cast(@Cmp_ID as varchar(10)) + 'and month(MSS.S_Eff_Date) =  ' + Cast(@Month as varchar(3)) + ' and Year(MSS.S_Eff_Date) = '+ Cast(@Year as varchar(4)) + ' 
							and isnull(mad.M_AD_NOT_EFFECT_SALARY,0) = 0    and Ad_Active = 1 
							And Sal_Type = 1
						Group By MAD.AD_ID,MSS.Emp_ID) as MS_arear  on MAD.ad_id = MS_arear.AD_ID_arear and  MAD.emp_id = MS_arear.emp_id_arear 
						
							Where Month(to_Date)= ' + Cast(@Month as varchar(3)) + ' And Year(To_Date) = '+ Cast(@Year as varchar(4)) + ' 
							and isnull(mad.S_Sal_Tran_ID,0) = 0	and MAD.M_AD_NOT_EFFECT_SALARY=0 and (SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1)'
							--and isnull(ms.is_fnf,0)=0 commented By Mukti 27012016 to show record of FNF done 
							
							
							exec (@sqlQuery)
							set @sqlQuery= ''
							
							--- Not effect on salary but payment in salary		
							--Update #Yearly_Salary 
							--set Month_1 = 		case when  MAD.ReimAmount  > 0 then  MAD.ReimAmount else 0 end + isnull(M_AREAR_AMOUNT ,0)																					
							--From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID  
							--	 inner join T0050_AD_MASTER AM ON MAD.AD_ID = AM.AD_ID
							--	 Inner JOIN #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(MAD.To_date) = SP.P_Month and Year(MAD.To_date) = SP.P_Year 
							--Where mad.For_Date =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD 
							--					   where TSMAD.Emp_ID = MAD.Emp_ID and To_date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date)  and TSMAD.AD_ID = MAD.AD_ID 
							--					   order by tsmad.For_Date desc )
							--and isnull(mad.S_Sal_Tran_ID,0) = 0	and MAD.M_AD_NOT_EFFECT_SALARY=1 and SP.Publish_Flag = 1	 					
							--- Not effect on salary but payment in salary		
							
							--where condition changed by Hardik 21/01/2016
							-- comment and added by rohit on 03082016
							------set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= case when  MAD.ReimAmount  > 0 then  MAD.ReimAmount else MAD.m_AD_AMOUNT end + isnull(M_AREAR_AMOUNT ,0)-- Comment by Ankit 05052016
							--set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= MAD.ReimAmount + isnull(M_AREAR_AMOUNT ,0)
							--From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID 
							--	 inner join t0200_monthly_salary ms on ms.sal_tran_id= MAD.sal_tran_id and ms.emp_ID = MAD.emp_ID   
							--	 inner join T0050_AD_MASTER AM ON MAD.AD_ID = AM.AD_ID
							--	 Inner JOIN #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(MAD.To_date) = SP.P_Month and Year(MAD.To_date) = SP.P_Year 
							--Where Month(to_Date)= ' + Cast(@Month as varchar(3)) + ' And Year(To_Date) = '+ Cast(@Year as varchar(4)) + ' 	
							--and isnull(mad.S_Sal_Tran_ID,0) = 0	and MAD.M_AD_NOT_EFFECT_SALARY=1 and (SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1) 
							--and MAD.ReimAmount  > 0'
							----and isnull(ms.is_fnf,0)=0 commented By Mukti 27012016 to show record of FNF done 
							----and MAD.ReimAmount  > 0 --Reimbursment Amount get only approved claim--  Ankit 05052016	
							
						--		set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= case when  MAD.ReimAmount  > 0 then  MAD.ReimAmount +  isnull(MS_arear.ms_amount,0) else MAD.m_AD_AMOUNT + + isnull(MS_arear.ms_amount,0) end + isnull(M_AREAR_AMOUNT ,0)-- Comment by Ankit 05052016
						--	From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID 
						--		 inner join t0200_monthly_salary ms on ms.sal_tran_id= MAD.sal_tran_id and ms.emp_ID = MAD.emp_ID   
						--		 inner join T0050_AD_MASTER AM ON MAD.AD_ID = AM.AD_ID
						--		 Inner JOIN #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(MAD.To_date) = SP.P_Month and Year(MAD.To_date) = SP.P_Year
						--		 left Join
						--		 (	Select  MAD.AD_ID as AD_ID_arear, Isnull(SUM(M_AD_Amount),0) as ms_amount,MSS.Emp_id as Emp_id_arear  From t0210_monthly_ad_detail MAD inner join
						--	T0201_MONTHLY_SALARY_SETT MSS on MAD.Sal_Tran_ID=MSS.Sal_Tran_ID and mad.emp_id = Mss.emp_id  inner join 
						--	T0050_AD_MASTER on MAD.Ad_Id = T0050_AD_MASTER.Ad_ID
						--	and MAD.Cmp_ID = T0050_AD_MASTER.Cmp_Id
						--where MAD.Cmp_ID = ' + cast(@Cmp_ID as varchar(10)) + ' and month(MSS.S_Eff_Date) = ' + Cast(@Month as varchar(3)) + ' and Year(MSS.S_Eff_Date) = '+ Cast(@Year as varchar(4)) + ' 
						--	and isnull(mad.M_AD_NOT_EFFECT_SALARY,0) = 1    and Ad_Active = 1 
						--	And Sal_Type = 1
						--Group By MAD.AD_ID,MSS.Emp_ID) as MS_arear   on MAD.ad_id = MS_arear.AD_ID_arear and  MAD.emp_id = MS_arear.emp_id_arear  
						--	Where Month(to_Date)= ' + Cast(@Month as varchar(3)) + ' And Year(To_Date) = '+ Cast(@Year as varchar(4)) + ' 	
						--	and isnull(mad.S_Sal_Tran_ID,0) = 0	and MAD.M_AD_NOT_EFFECT_SALARY=1 and (SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1) '
						--	--and MAD.ReimAmount  > 0
						--	--and isnull(ms.is_fnf,0)=0 commented By Mukti 27012016 to show record of FNF done 
						--	--and MAD.ReimAmount  > 0 --Reimbursment Amount get only approved claim--  Ankit 05052016	
						set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= case when  MAD.ReimAmount  > 0 then  MAD.ReimAmount +  isnull(MS_arear.ms_amount,0) else isnull(MS_arear.ms_amount,0) end + IsNull(M_AREAR_AMOUNT_Cutoff,0)+ IsNull(M_AREAR_AMOUNT,0)
							From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID 
								 inner join t0200_monthly_salary ms on ms.sal_tran_id= MAD.sal_tran_id and ms.emp_ID = MAD.emp_ID   
								 inner join T0050_AD_MASTER AM ON MAD.AD_ID = AM.AD_ID
								 Inner JOIN #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(MAD.To_date) = SP.P_Month and Year(MAD.To_date) = SP.P_Year
								 left Join
								 (	Select  MAD.AD_ID as AD_ID_arear, Isnull(SUM(M_AD_Amount),0) as ms_amount,MSS.Emp_id as Emp_id_arear  From t0210_monthly_ad_detail MAD inner join
							T0201_MONTHLY_SALARY_SETT MSS on MAD.S_Sal_Tran_ID=MSS.S_Sal_Tran_ID and mad.emp_id = Mss.emp_id  inner join 
							T0050_AD_MASTER on MAD.Ad_Id = T0050_AD_MASTER.Ad_ID
							and MAD.Cmp_ID = T0050_AD_MASTER.Cmp_Id
						where MAD.Cmp_ID = ' + cast(@Cmp_ID as NVARCHAR(10)) + ' and month(MSS.S_Eff_Date) = ' + Cast(@Month as NVARCHAR(3)) + ' and Year(MSS.S_Eff_Date) = '+ Cast(@Year as NVARCHAR(4)) + ' 
							and isnull(mad.M_AD_NOT_EFFECT_SALARY,0) = 1    and Ad_Active = 1 
							And Sal_Type = 1
						Group By MAD.AD_ID,MSS.Emp_ID) as MS_arear   on MAD.ad_id = MS_arear.AD_ID_arear and  MAD.emp_id = MS_arear.emp_id_arear  
							Where Month(to_Date)= ' + Cast(@Month as NVARCHAR(3)) + ' And Year(To_Date) = '+ Cast(@Year as NVARCHAR(4)) + ' 	
							and isnull(mad.S_Sal_Tran_ID,0) = 0	and MAD.M_AD_NOT_EFFECT_SALARY=1 and (SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1)
							and MAD.ReimAmount  > 0'							 
							exec (@sqlQuery)
							set @sqlQuery= ''
							
							
							set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= mad.m_Ad_amount + mad.M_AREAR_AMOUNT + isnull(MS_arear.ms_amount,0) + IsNull(M_AREAR_AMOUNT_Cutoff,0)
							From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID 
								 inner join t0200_monthly_salary ms on ms.sal_tran_id= MAD.sal_tran_id and ms.emp_ID = MAD.emp_ID   
								 inner join T0050_AD_MASTER AM ON MAD.AD_ID = AM.AD_ID
								 Inner JOIN #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(MAD.To_date) = SP.P_Month and Year(MAD.To_date) = SP.P_Year
								 left Join
								 (	Select  MAD.AD_ID as AD_ID_arear, Isnull(SUM(M_AD_Amount),0) as ms_amount,MSS.Emp_id as Emp_id_arear  From t0210_monthly_ad_detail MAD inner join
							T0201_MONTHLY_SALARY_SETT MSS on MAD.S_Sal_Tran_ID=MSS.S_Sal_Tran_ID and mad.emp_id = Mss.emp_id  inner join 
							T0050_AD_MASTER on MAD.Ad_Id = T0050_AD_MASTER.Ad_ID
							and MAD.Cmp_ID = T0050_AD_MASTER.Cmp_Id
						where MAD.Cmp_ID = ' + cast(@Cmp_ID as NVARCHAR(10)) + ' and month(MSS.S_Eff_Date) = ' + Cast(@Month as NVARCHAR(3)) + ' and Year(MSS.S_Eff_Date) = '+ Cast(@Year as NVARCHAR(4)) + ' 
							and isnull(mad.M_AD_NOT_EFFECT_SALARY,0) = 1    and Ad_Active = 1 
						Group By MAD.AD_ID,MSS.Emp_ID) as MS_arear   on MAD.ad_id = MS_arear.AD_ID_arear and  MAD.emp_id = MS_arear.emp_id_arear  
							Where Month(to_Date)= ' + Cast(@Month as NVARCHAR(3)) + ' And Year(To_Date) = '+ Cast(@Year as NVARCHAR(4)) + ' 	
							and isnull(mad.S_Sal_Tran_ID,0) = 0	and MAD.M_AD_NOT_EFFECT_SALARY=1 and (SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1)
							 and def_id like ''%K%'''	
									exec (@sqlQuery)									
									set @sqlQuery= ''
							
							--Added by Rohit and Sumit for FNF case 04012016
							----where condition changed by Hardik 21/01/2016
							--set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0)
							--From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID and mad.for_fnf = 1
							--						 inner join t0200_monthly_salary ms on ms.sal_tran_id= MAD.sal_tran_id and ms.emp_ID = MAD.emp_ID  
							--						 inner join T0050_AD_MASTER AM ON MAD.AD_ID = AM.AD_ID
							--						 Inner JOIN #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(MAD.To_date) = SP.P_Month and Year(MAD.To_date) = SP.P_Year 
							--Where Month(to_Date)= ' + Cast(@Month as varchar(3)) + ' And Year(To_Date) = '+ Cast(@Year as varchar(4)) + ' 
							--and isnull(mad.S_Sal_Tran_ID,0) = 0	and MAD.M_AD_NOT_EFFECT_SALARY=0'
							----and isnull(ms.is_fnf,0)=0 commented By Mukti 27012016 to show record of FNF done 
							
								set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0) + isnull(MS_arear.ms_amount,0) + IsNull(M_AREAR_AMOUNT_Cutoff,0)
							From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID and mad.for_fnf = 1
													 inner join t0200_monthly_salary ms on ms.sal_tran_id= MAD.sal_tran_id and ms.emp_ID = MAD.emp_ID  
													 inner join T0050_AD_MASTER AM ON MAD.AD_ID = AM.AD_ID
													 Inner JOIN #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(MAD.To_date) = SP.P_Month and Year(MAD.To_date) = SP.P_Year 
													 	 left Join
								 (	Select  MAD.AD_ID as AD_ID_arear, Isnull(SUM(M_AD_Amount),0) as ms_amount,MSS.Emp_id as Emp_id_arear  From t0210_monthly_ad_detail MAD inner join
							T0201_MONTHLY_SALARY_SETT MSS on MAD.S_Sal_Tran_ID=MSS.S_Sal_Tran_ID and mad.emp_id = Mss.emp_id  inner join 
							T0050_AD_MASTER on MAD.Ad_Id = T0050_AD_MASTER.Ad_ID
							and MAD.Cmp_ID = T0050_AD_MASTER.Cmp_Id
						where MAD.Cmp_ID = ' + cast(@Cmp_ID as varchar(10)) + ' and month(MSS.S_Eff_Date) =  ' + Cast(@Month as varchar(3)) + ' and Year(MSS.S_Eff_Date) = '+ Cast(@Year as varchar(4)) + ' 
							and isnull(mad.M_AD_NOT_EFFECT_SALARY,0) = 0    and Ad_Active = 1 
							And Sal_Type = 1
						Group By MAD.AD_ID,MSS.Emp_ID) as MS_arear   on MAD.ad_id = MS_arear.AD_ID_arear and  MAD.emp_id = MS_arear.emp_id_arear  
							Where Month(to_Date)= ' + Cast(@Month as varchar(3)) + ' And Year(To_Date) = '+ Cast(@Year as varchar(4)) + ' 
							and isnull(mad.S_Sal_Tran_ID,0) = 0	and MAD.M_AD_NOT_EFFECT_SALARY=0'
							--and isnull(ms.is_fnf,0)=0 commented By Mukti 27012016 to show record of FNF done 
							exec (@sqlQuery)
							
							set @sqlQuery= ''
							
							
							-- for settelment amount added by mitesh on 17072012
							--Update #Yearly_Salary 
							--set Month_1 = Settelement_Amount
							--From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
							--Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
							--Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
							--	and  Def_ID = 'J16'
								
							-- commneted by rohit on 03082016	
							--set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= Settelement_Amount
							--From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
							--Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
							--Where Month(Month_End_Date) = ' + cast(@Month as varchar(10)) + ' and Year(Month_End_Date) = ' + cast(@Year as varchar(10)) + ' and (SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1)  and  Def_ID = ''J16'''
							----and isnull(ms.is_fnf,0)=0 commented By Mukti 27012016 to show record of FNF done 
							--		exec (@sqlQuery)
							--		set @sqlQuery= ''	

							-- Added by rohit For leave Encasement amount on 13-dec-2013
							--Update #Yearly_Salary 
							--set Month_1 = Leave_Salary_Amount
							--From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
							--Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
							--Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
							--	and  Def_ID = 'J17'
							-- ended by rohit	
								
							set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= Leave_Salary_Amount
							From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
							Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
							Where Month(Month_End_Date) = ' + cast(@Month as varchar(10)) + ' and Year(Month_End_Date) = ' + cast(@Year as varchar(10)) + 'and 
							SP.Publish_Flag = 1  and  Def_ID = ''J17'''
							--and isnull(ms.is_fnf,0)=0 commented By Mukti 27012016 to show record of FNF done 
							exec (@sqlQuery)
							set @sqlQuery= ''		
								
							--Update #Yearly_Salary 
							--set Month_1 = isnull(Travel_Amount,0)
							--From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
							--Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
							--Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
							--and  Def_ID = 'J18'	 --Added by Sumit 24092015
							
							set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= isnull(Travel_Amount,0)
							From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
							Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
							Where Month(Month_End_Date) = ' + cast(@Month as varchar(10)) + ' and Year(Month_End_Date) = ' + cast(@Year as varchar(10)) + 'and 
							(SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1) and  Def_ID = ''J18'''
							--and isnull(ms.is_fnf,0)=0 commented By Mukti 27012016 to show record of FNF done 
							exec (@sqlQuery)
							set @sqlQuery= ''

							-- for OT amount added by Hasmukh on 29032013
							--Update #Yearly_Salary 
							--set Month_1 = OT_Amount
							--From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
							--Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year  
							--Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
							--	and  Def_ID = 'J20'
								
							set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= OT_Amount
							From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
							Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year  
							Where Month(Month_End_Date) = ' + cast(@Month as varchar(10)) + ' and Year(Month_End_Date) = ' + cast(@Year as varchar(10)) + 'and 
							(SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1) and  Def_ID = ''J20'''
							--and isnull(ms.is_fnf,0)=0 commented By Mukti 27012016 to show record of FNF done 
							exec (@sqlQuery)
							set @sqlQuery= ''	

							--Update #Yearly_Salary 
							--set Month_1 = M_WO_OT_Amount
							--From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
							--Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
							--Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
							--	and  Def_ID = 'J21'
							
							set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= M_WO_OT_Amount
							From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
							Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
							Where Month(Month_End_Date) = ' + cast(@Month as varchar(10)) + ' and Year(Month_End_Date) = ' + cast(@Year as varchar(10)) + 'and 
							(SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1)  and  Def_ID = ''J21'''
							--and isnull(ms.is_fnf,0)=0 commented By Mukti 27012016 to show record of FNF done 
							exec (@sqlQuery)
							set @sqlQuery= ''	

							--Update #Yearly_Salary 
							--set Month_1 = M_HO_OT_Amount
							--From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
							--Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
							--Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
							--	and  Def_ID = 'J22'
							
							set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= M_HO_OT_Amount
							From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
							Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
							Where Month(Month_End_Date) = ' + cast(@Month as varchar(10)) + ' and Year(Month_End_Date) = ' + cast(@Year as varchar(10)) + 'and 
							(SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1)  and  Def_ID = ''J22'''
							--and isnull(ms.is_fnf,0)=0 commented By Mukti 27012016 to show record of FNF done 
							exec (@sqlQuery)
							set @sqlQuery= ''		

							--Update #Yearly_Salary 
							--set Month_1 = Loan_Amount
							--From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
							--Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
							--Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
							--	and Def_ID = 'P23'
							
							set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= Loan_Amount
							From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
							Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
							Where Month(Month_End_Date) = ' + cast(@Month as varchar(10)) + ' and Year(Month_End_Date) = ' + cast(@Year as varchar(10)) + 'and 
							(SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1)  and Def_ID = ''P23'''
							--and isnull(ms.is_fnf,0)=0 commented By Mukti 27012016 to show record of FNF done 
							exec (@sqlQuery)
							set @sqlQuery= ''		

							--Update #Yearly_Salary 
							--set Month_1 = Loan_Intrest_Amount
							--From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
							--Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
							--Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
							--	and Def_ID = 'P24'
								
							set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= Loan_Intrest_Amount
							From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
							Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
							Where Month(Month_End_Date) = ' + cast(@Month as varchar(10)) + ' and Year(Month_End_Date) = ' + cast(@Year as varchar(10)) + 'and 
							(SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1)  and Def_ID = ''P24'''
							--and isnull(ms.is_fnf,0)=0 commented By Mukti 27012016 to show record of FNF done 
							exec (@sqlQuery)
							set @sqlQuery= ''
							

							--Update #Yearly_Salary 
							--set Month_1 = Other_dedu_amount
							--From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
							--Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
							--Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
							--	and Def_ID = 'P25'
							
							set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= Other_dedu_amount
							From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
							Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
							Where Month(Month_End_Date) = ' + cast(@Month as varchar(10)) + ' and Year(Month_End_Date) = ' + cast(@Year as varchar(10)) + 'and 
							(SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1) and Def_ID = ''P25'''
							--and isnull(ms.is_fnf,0)=0 commented By Mukti 27012016 to show record of FNF done 
							exec (@sqlQuery)
							set @sqlQuery= ''	
							
							
							--Update #Yearly_Salary 
							--set Month_1 = isnull(GatePass_Amount,0)
							--From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
							--Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
							--Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
							--	and Def_ID = 'P26'
							
							set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= isnull(GatePass_Amount,0)
							From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
							Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
							Where Month(Month_End_Date) = ' + cast(@Month as varchar(10)) + ' and Year(Month_End_Date) = ' + cast(@Year as varchar(10)) + 'and 
							(SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1)  and Def_ID = ''P26'''
							--and isnull(ms.is_fnf,0)=0 commented By Mukti 27012016 to show record of FNF done 
							exec (@sqlQuery)
							set @sqlQuery= ''	
								
							--Update #Yearly_Salary   -- Added by Mukti 07042015
							--set Month_1 = isnull(Asset_Installment,0)
							--From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
							--Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
							--Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
							--and Def_ID = 'P27'
							
							set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= isnull(Asset_Installment,0)
							From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
							Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
							Where Month(Month_End_Date) = ' + cast(@Month as varchar(10)) + ' and Year(Month_End_Date) = ' + cast(@Year as varchar(10)) + 'and 
							(SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1)  and Def_ID = ''P27'''
							--and isnull(ms.is_fnf,0)=0 commented By Mukti 27012016 to show record of FNF done 
							exec (@sqlQuery)
							set @sqlQuery= ''

							--Update #Yearly_Salary   -- Added by Sumit 24092015
							--set Month_1 = isnull(Travel_Advance_Amount,0)
							--From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
							--Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
							--Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
							--and Def_ID = 'P18'
							
							set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= isnull(Travel_Advance_Amount,0)
							From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
							Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
							Where Month(Month_End_Date) = ' + cast(@Month as varchar(10)) + ' and Year(Month_End_Date) = ' + cast(@Year as varchar(10)) + 'and 
							(SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1)  and Def_ID = ''P18'''
							--and isnull(ms.is_fnf,0)=0 commented By Mukti 27012016 to show record of FNF done 
							exec (@sqlQuery)
							set @sqlQuery= ''

							------OT Amount---Hasmukh 29032013
							--Update #Yearly_Salary 
							--set Month_1 = Claim_pay_amount
							--From #Yearly_Salary  Ys  inner join 
							--(SELECT CLAIM_PAYMENT_DATE,ca.claim_ID,cm.Claim_Name,ca.Emp_Id,Claim_pay_Amount From T0210_MONTHLY_CLAIM_PAYMENT CP INNER JOIN  T0120_CLAIM_APPROVAL CA ON CP.CLAIM_APR_ID =CA.CLAIM_APR_iD  
							--	INNER JOIN T0040_CLAIM_MASTER CM ON CA.CLAIM_ID = CM.CLAIM_ID  inner join #Emp_Cons ec on ca.emp_ID =ec.emp_Id 
							--	WHERE CLAIM_PAYMENT_DATE >=@FROM_DATE  AND CLAIM_PAYMENT_dATE <=@TO_DATE ) q on ys.Emp_ID = q.emp_ID
							--Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(CLAIM_PAYMENT_DATE) = SP.P_Month and Year(CLAIM_PAYMENT_DATE) = SP.P_Year 
							--Where Month(CLAIM_PAYMENT_DATE) = @Month and Year(CLAIM_PAYMENT_DATE) = @Year And Q.Claim_Name collate SQL_Latin1_General_CP1_CI_AS = YS.Lable_Name collate SQL_Latin1_General_CP1_CI_AS and SP.Publish_Flag = 1
			 
							set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= Claim_pay_amount
							From #Yearly_Salary  Ys  inner join 
							(SELECT CLAIM_PAYMENT_DATE,ca.claim_ID,cm.Claim_Name,ca.Emp_Id,Claim_pay_Amount From T0210_MONTHLY_CLAIM_PAYMENT CP INNER JOIN  T0120_CLAIM_APPROVAL CA ON CP.CLAIM_APR_ID =CA.CLAIM_APR_iD  
								INNER JOIN T0040_CLAIM_MASTER CM ON CA.CLAIM_ID = CM.CLAIM_ID  inner join #Emp_Cons ec on ca.emp_ID =ec.emp_Id 
								WHERE CLAIM_PAYMENT_DATE >= '''+ cast(@FROM_DATE as varchar(20))+''' AND CLAIM_PAYMENT_dATE <=''' + cast(@TO_DATE as varchar(20)) +''') q on ys.Emp_ID = q.emp_ID
							Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(CLAIM_PAYMENT_DATE) = SP.P_Month and Year(CLAIM_PAYMENT_DATE) = SP.P_Year 
							Where Month(CLAIM_PAYMENT_DATE) = ' + cast(@Month as varchar(10)) +' and Year(CLAIM_PAYMENT_DATE) = '+ cast(@Year as varchar(10)) + 'And Q.Claim_Name collate SQL_Latin1_General_CP1_CI_AS = YS.Lable_Name collate SQL_Latin1_General_CP1_CI_AS and SP.Publish_Flag = 1 '
							exec (@sqlQuery)
							set @sqlQuery= ''
							
							--Added by Mukti(start)20062017
							set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= isnull(Uniform_Dedu_Amount,0)
							From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
							Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
							Where Month(Month_End_Date) = ' + cast(@Month as varchar(10)) + ' and Year(Month_End_Date) = ' + cast(@Year as varchar(10)) + 'and 
							(SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1)  and Def_ID = ''P28'''
							exec (@sqlQuery)
							set @sqlQuery= ''
							
							set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= isnull(Uniform_Refund_Amount,0)
							From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
							Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
							Where Month(Month_End_Date) = ' + cast(@Month as varchar(10)) + ' and Year(Month_End_Date) = ' + cast(@Year as varchar(10)) + 'and 
							(SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1)  and Def_ID = ''J26'''
							exec (@sqlQuery)
							set @sqlQuery= ''
							--Added by Mukti(end)20062017
							
							
							--added by jimit 28072017
							set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= isnull(Late_Dedu_Amount,0)
							From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
							Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
							Where Month(Month_End_Date) = ' + cast(@Month as varchar(10)) + ' and Year(Month_End_Date) = ' + cast(@Year as varchar(10)) + 'and 
							Def_ID = ''P29'''
							exec (@sqlQuery)
							set @sqlQuery= ''
							--ended					
							
							-- Added by rohit For Add component which Not Effect in salary and Part of Ctc on 09102013
							if @with_Ctc = 1
							begin 
								--Update #Yearly_Salary 
								--set Month_1 = table_Sum_CTC.Sum_CTC
								--from #Yearly_Salary YSD inner join 
								--(select Isnull(SUM(M_AD_Amount),0) as Sum_CTC,Def_ID  , T.emp_id          
							 --  From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID             
							 --  inner join T0210_MONTHLY_AD_DETAIL T on ms.sal_tran_id = T.sal_tran_id             
							 --  inner join T0050_AD_MASTER A on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID 
							 --  Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year           
							 --  Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year            
							 --  and Def_ID = 'L4' and isnull(T.M_Ad_Not_Effect_Salary,0) = 1 and Ad_Active = 1 And A.AD_Part_Of_CTC = 1 and AD_Flag = 'I' 
							 --  and isnull(S_Sal_Tran_ID,0) = 0 and SP.Publish_Flag = 1            
							 --  group by def_id ,T.Emp_ID) table_Sum_CTC on YSD.def_id = table_Sum_CTC.def_id   and ysd.Emp_Id = table_Sum_CTC.Emp_ID       
							 --  where YSD.def_id = 'L4'   
							   
							   -- comment and added by rohit 03082016
							 --  set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= table_Sum_CTC.Sum_CTC
								--from #Yearly_Salary YSD inner join 
								--(select Isnull(SUM(M_AD_Amount),0) as Sum_CTC,Def_ID  , T.emp_id          
							 --  From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID             
							 --  inner join T0210_MONTHLY_AD_DETAIL T on ms.sal_tran_id = T.sal_tran_id             
							 --  inner join T0050_AD_MASTER A on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID 
							 --  Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year           
							 --  Where Month(ms.Month_End_Date) = '+cast(@Month as varchar(10)) + 'and Year(ms.Month_End_Date) = '+ cast(@Year as varchar(10)) + '
							 --  and Def_ID = ''L4'' and isnull(T.M_Ad_Not_Effect_Salary,0) = 1 and Ad_Active = 1 And A.AD_Part_Of_CTC = 1 and AD_Flag = ''I'' 
							 --  and isnull(S_Sal_Tran_ID,0) = 0 and (SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1)
							 --  group by def_id ,T.Emp_ID) table_Sum_CTC on YSD.def_id = table_Sum_CTC.def_id   and ysd.Emp_Id = table_Sum_CTC.Emp_ID         
							 --  where YSD.def_id = ''L4''   '
							   --and isnull(ms.is_fnf,0)=0 commented By Mukti 27012016 to show record of FNF done 
							   
							   
							   
							   set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= table_Sum_CTC.Sum_CTC 
								from #Yearly_Salary YSD inner join 
								(select Isnull(SUM(M_AD_Amount + isnull(ms_amount,0)),0)as Sum_CTC,Def_ID  , T.emp_id          
							   From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID             
							   inner join T0210_MONTHLY_AD_DETAIL T on ms.sal_tran_id = T.sal_tran_id             
							   inner join T0050_AD_MASTER A on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID 
							   Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year           
							    left Join
								 (	Select  MAD.AD_ID as AD_ID_arear, Isnull(SUM(M_AD_Amount),0) as ms_amount,MSS.Emp_id as Emp_id_arear  From t0210_monthly_ad_detail MAD inner join
									T0201_MONTHLY_SALARY_SETT MSS on MAD.S_Sal_Tran_ID=MSS.S_Sal_Tran_ID and mad.emp_id = Mss.emp_id  inner join 
									T0050_AD_MASTER on MAD.Ad_Id = T0050_AD_MASTER.Ad_ID
									and MAD.Cmp_ID = T0050_AD_MASTER.Cmp_Id
									where MAD.Cmp_ID = ' + cast(@Cmp_ID as varchar(10)) + ' and month(MSS.S_Eff_Date) = ' + Cast(@Month as varchar(3)) + ' and Year(MSS.S_Eff_Date) = '+ Cast(@Year as varchar(4)) + ' 
									and isnull(mad.M_AD_NOT_EFFECT_SALARY,0) = 1    and Ad_Active = 1 
									And Sal_Type = 1
									Group By MAD.AD_ID,MSS.Emp_ID) as MS_arear   on T.ad_id = MS_arear.AD_ID_arear and  T.emp_id = MS_arear.emp_id_arear  
							   Where Month(ms.Month_End_Date) = '+cast(@Month as varchar(10)) + 'and Year(ms.Month_End_Date) = '+ cast(@Year as varchar(10)) + '
							   and Def_ID = ''L4'' and isnull(T.M_Ad_Not_Effect_Salary,0) = 1 and Ad_Active = 1 And A.AD_Part_Of_CTC = 1 and AD_Flag = ''I'' 
							   and isnull(S_Sal_Tran_ID,0) = 0 and (SP.Publish_Flag = 1 or isnull(ms.is_fnf,0) = 1)
							   group by def_id ,T.Emp_ID) table_Sum_CTC on YSD.def_id = table_Sum_CTC.def_id   and ysd.Emp_Id = table_Sum_CTC.Emp_ID         
							   where YSD.def_id = ''L4''   '
							   --and isnull(ms.is_fnf,0)=0 commented By Mukti 27012016 to show record of FNF done 							   
							exec (@sqlQuery) 							
							set @sqlQuery= ''
							
									  set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= ' + @Str_Month + ' + Gross_Salary + isnull(S_gross_salary,0) -isnull(S_net_Amount,0)
								From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
								Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
								left join
							(   SELECT  ms.Emp_ID,SUM(ms.S_gross_salary) AS S_gross_salary,SUM(ms.S_net_Amount) AS S_net_Amount ,S_Eff_Date
								FROM T0201_MONTHLY_SALARY_SETT ms INNER JOIN #Emp_Cons ec ON ms.Emp_ID =ec.emp_ID 
									AND  MONTH(S_Eff_Date) = ' + cast(@Month as varchar(10))  + ' AND YEAR(S_Eff_Date) = ' + cast(@Year as varchar(10))  +'
								GROUP BY ms.Emp_ID,S_Eff_Date
							 ) Qry ON Qry.Emp_ID = Ys.Emp_ID
								Where Month(Month_End_Date) = ' + cast(@Month as varchar(10)) + ' and Year(Month_End_Date) = ' + cast(@Year as varchar(10)) + 'and (SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1) and Def_ID = ''L4'''
								--and isnull(ms.is_fnf,0)=0 commented By Mukti 27012016 to show record of FNF done 
								
							exec (@sqlQuery)
							set @sqlQuery= ''
								
							end	
							--	Ended by Rohit on 09102013							
							
							
							 set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= Ms.Sal_Cal_Days + IsNull(Arear_Day_Previous_month,0) + IsNull(Arear_Day,0)
							From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
							Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
							Where Month(Month_End_Date) = ' + cast(@Month as varchar(10)) + ' and Year(Month_End_Date) = ' + cast(@Year as varchar(10)) + 'and (SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1) and Def_ID = ''52'''
							--and isnull(ms.is_fnf,0)=0 commented By Mukti 27012016 to show record of FNF done 
							exec (@sqlQuery)
							set @sqlQuery= ''

							--Added by Mukti(05122020)start TO Get Actual Salary Structure Columns Wonder
							IF @Report_Call='ALL1'
							BEGIN	
								set @sqlQuery= ''			
								set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '=	TAD.E_AD_AMOUNT	
								From #Yearly_Salary  Ys 
								inner join T0050_AD_MASTER AS A  WITH (NOLOCK) ON YS.AD_ID=A.AD_ID
								INNER JOIN 
								  (SELECT     T.EMP_ID, T.E_AD_AMOUNT, T.AD_ID
									FROM          #Tbl_Get_AD AS T
									WHERE      (T.E_AD_PERCENTAGE > 0) OR (
									T.E_AD_AMOUNT > 0)) AS TAD ON A.AD_ID = TAD.AD_ID 
								Inner join T0200_Monthly_Salary ms on TAD.emp_ID = ms.emp_ID AND  MONTH(Month_End_Date) = ' + cast(@Month as varchar(10))  + ' AND YEAR(Month_End_Date) = ' + cast(@Year as varchar(10))  +'
								WHERE     (TAD.E_AD_AMOUNT <> 0) and a.AD_FLAG = ''I'' AND DEF_ID LIKE ''A%'' and AD_NOT_EFFECT_SALARY = 0	and A.Cmp_ID = ' + cast(@Cmp_ID as varchar(10)) + ''
								exec (@sqlQuery)
								set @sqlQuery= ''					
							
								set @sqlQuery= ''			
								set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '=	TAD.E_AD_AMOUNT								
								From #Yearly_Salary  Ys 
								Inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID AND  MONTH(Month_End_Date) = ' + cast(@Month as varchar(10))  + ' AND YEAR(Month_End_Date) = ' + cast(@Year as varchar(10))  +'
								inner join T0050_AD_MASTER AS A  WITH (NOLOCK) ON YS.AD_ID=A.AD_ID
								INNER JOIN 
								  (SELECT     T.EMP_ID, T.E_AD_AMOUNT, T.AD_ID
									FROM         #Tbl_Get_AD AS T
									WHERE      (T.E_AD_PERCENTAGE > 0) OR (T.E_AD_AMOUNT > 0)) AS TAD ON A.AD_ID = TAD.AD_ID 													
								WHERE     (TAD.E_AD_AMOUNT <> 0) and a.AD_FLAG = ''I'' AND DEF_ID LIKE ''B%'' and AD_NOT_EFFECT_SALARY = 1	and A.Cmp_ID = ' + cast(@Cmp_ID as varchar(10)) + ''exec (@sqlQuery)
								set @sqlQuery= ''
														
								set @sqlQuery= ''			
								set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '=	TAD.E_AD_Amount	
								From #Yearly_Salary  Ys 
								Inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID AND  MONTH(Month_End_Date) = ' + cast(@Month as varchar(10))  + ' AND YEAR(Month_End_Date) = ' + cast(@Year as varchar(10))  +'
								inner join T0050_AD_MASTER AS A  WITH (NOLOCK) ON YS.AD_ID=A.AD_ID
								INNER JOIN 
								  (SELECT     T.EMP_ID, T.E_AD_AMOUNT, T.AD_ID
									FROM         #Tbl_Get_AD AS T
									WHERE      (T.E_AD_PERCENTAGE > 0) OR (T.E_AD_AMOUNT > 0)) AS TAD ON A.AD_ID = TAD.AD_ID 													
								WHERE     (TAD.E_AD_AMOUNT <> 0) and a.AD_FLAG = ''D'' AND DEF_ID LIKE ''D%'' and AD_NOT_EFFECT_SALARY = 0 and A.Cmp_ID = ' + cast(@Cmp_ID as varchar(10)) + ''
								exec (@sqlQuery)
								set @sqlQuery= ''
		
								set @sqlQuery= ''			
								set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '=	(isnull(m.M_AREAR_AMOUNT,0) + isnull(m.M_AREAR_AMOUNT_Cutoff,0) + isnull(MS_arear.ms_amount,0))	
								From #Yearly_Salary  Ys 
								INNER JOIN T0210_MONTHLY_AD_DETAIL AS M  WITH (NOLOCK) ON M.EMP_ID=YS.EMP_ID
								INNER JOIN T0050_AD_MASTER AS A  WITH (NOLOCK) ON A.AD_ID = M.AD_ID AND A.CMP_ID = M.Cmp_ID
								INNER JOIN #Emp_Cons Ec ON Ec.emp_id = m.Emp_ID 	
								LEFT OUTER JOIN
								(
									SELECT  MAD.AD_ID as AD_ID_arear, Isnull(SUM(M_AD_Amount),0) as ms_amount,MSS.Emp_id as Emp_id_arear  
									FROM t0210_monthly_ad_detail MAD WITH (NOLOCK)  
										inner join T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK) on MAD.S_Sal_Tran_ID=MSS.S_Sal_Tran_ID and mad.emp_id = Mss.emp_id  
										inner join T0050_AD_MASTER on MAD.Ad_Id = T0050_AD_MASTER.Ad_ID and MAD.Cmp_ID = T0050_AD_MASTER.Cmp_Id
									WHERE MAD.Cmp_ID = ' + cast(@Cmp_ID as varchar(10)) + ' and month(MSS.S_Eff_Date) = ' + cast(@Month as varchar(10))  + ' and Year(MSS.S_Eff_Date) =' + cast(@Year as varchar(10))  +'
										  and (AD_NOT_EFFECT_SALARY = 0 OR ReimShow = 1) and Ad_Active = 1 
									GROUP BY MAD.AD_ID,MSS.Emp_ID
								) as MS_arear   on m.ad_id = MS_arear.AD_ID_arear and  m.emp_id = MS_arear.emp_id_arear
								WHERE  (m.For_Date = '''+ cast(@FROM_DATE as varchar(20))+''') AND DEF_ID LIKE ''AR%'' and (m.M_AD_Amount <> 0) AND (m.M_AD_Flag = ''D'') and AD_NOT_EFFECT_SALARY = 0 and m.Cmp_ID =' + cast(@Cmp_ID as varchar(10)) + '
								and	m.S_Sal_Tran_ID is NULL'

								exec (@sqlQuery)
							END
							--Added by Mukti(05122020)END TO Get Actual Salary Structure Columns Wonder

							set @sqlQuery= ''

							-----added by jimit 24032017
							
							set @sqlQuery = 'UPDATE   CM 						
												SET		 ' + @Str_Month + ' = Q.Amount
												FROM	#Yearly_Salary CM 
														INNER JOIN (
														SELECT	ISNULL(SUM(M_AD_Amount),0) as Amount,Mad.Emp_ID
														FROM	T0210_MONTHLY_AD_DETAIL MAD 
																INNER JOIN T0050_AD_MASTER AD ON MAD.AD_ID = AD.AD_ID AND MAD.Cmp_ID = AD.CMP_ID												
														WHERE	MAD.Cmp_ID = ' + cast(@Cmp_Id as varchar(10))  + ' 
																	AND MONTH(MAD.For_Date) = ' + cast(@Month as varchar(10)) + '  and YEAR(MAD.For_Date) =  ' + cast(@Year as varchar(10)) +  ' 
																	AND Ad_Active = 1 AND AD_Flag = ''I'' AND ad_not_effect_salary = 0 
																	AND AD_DEF_ID =  ' + cast(@ProductionBonus_Ad_Def_Id  as varchar(10)) + '   
														GROUP BY Mad.Emp_ID
													  )Q On CM.Emp_ID = Q.Emp_ID 
												where Def_ID = ''i199'''
							
							exec (@sqlQuery)
							set @sqlQuery= ''
											
							print @Str_Month
											
							
							---ended
						
					
					-- Ended by rohit for Single change Effect in All month on 16122015
					
				--if @count = 1 
				--	begin
							
				--			Update #Yearly_Salary 
				--			set Month_1 = 1 
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
				--			--Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year --and SP.Publish_Flag = 1
				--				and Def_ID = '51'

				--			Update #Yearly_Salary 
				--			set Month_1 = Salary_Amount + isnull(Arear_Basic ,0)
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'B1'
								
				--			Update #Yearly_Salary 
				--			set Month_1 = Other_Allow_Amount + isnull(Arear_Basic ,0)	-- Changed By Gadriwala(add field Arear_basic) 26042014
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'J2'

				--			Update #Yearly_Salary 
				--			set Month_1 = Gross_Salary
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'J23'
							
				--			Update #Yearly_Salary 
				--			set Month_1 = Total_Earning_Fraction
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'J24'
							
				--			Update #Yearly_Salary 
				--			set Month_1 = Gross_Salary + Total_Earning_Fraction
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'J25'
								
				--			Update #Yearly_Salary 
				--			set Month_1 = PT_Amount 
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P11'

				--			Update #Yearly_Salary 
				--			set Month_1 = LWF_Amount 
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P12'


				--			Update #Yearly_Salary 
				--			set Month_1 = Revenue_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P13'

				--			Update #Yearly_Salary		
				--			set Month_1 = Advance_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P14'
								
				--			Update #Yearly_Salary		
				--			set Month_1 = Total_Dedu_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year  
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P98'
																													
				--			Update #Yearly_Salary		
				--			set Month_1 = Net_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year  
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P99'
							
				--			IF @ROUNDING = 0 AND @Net_Salary_Round <> -1
				--				Begin
				--					Update #Yearly_Salary		
				--					set Month_1 = Net_Amount - Net_Salary_Round_Diff_Amount
				--					From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--					Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
				--					Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--						and Def_ID = 'P99'
										
				--					Update #Yearly_Salary		
				--					set Month_1 = Net_Salary_Round_Diff_Amount
				--					From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--					Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
				--					Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--						and Def_ID = 'P100'
										
				--					Update #Yearly_Salary		
				--					set Month_1 = Net_Amount 
				--					From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--					Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
				--					Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--						and Def_ID = 'P101'
				--				End
								
							
				--			--Update #Yearly_Salary 
				--			--set Month_1 = m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0)
				--			--From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on 
				--			--	YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID  inner join T0050_AD_MASTER AM ON 
				--			--	 MAD.AD_ID = AM.AD_ID
				--			--Where mad.For_Date =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD where TSMAD.Emp_ID = MAD.Emp_ID and To_date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date)  order by tsmad.For_Date desc )
				--			--and isnull(mad.S_Sal_Tran_ID,0) = 0	and MAD.M_AD_NOT_EFFECT_SALARY=0
							
							
							
				--			Update #Yearly_Salary 
				--			set Month_1 = m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0)
				--			From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID  
				--									 inner join T0050_AD_MASTER AM ON MAD.AD_ID = AM.AD_ID
				--									 --Inner JOIN #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(MAD.To_date) = SP.P_Month and Year(MAD.To_date) = SP.P_Year 
				--			Where mad.M_AD_Tran_ID =  (select top 1 M_AD_Tran_ID from T0210_MONTHLY_AD_DETAIL TSMAD 
				--									   where TSMAD.Emp_ID = MAD.Emp_ID and To_date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date) and TSMAD.AD_ID = MAD.AD_ID 
				--									   order by tsmad.M_AD_Tran_ID desc )
				--			and isnull(mad.S_Sal_Tran_ID,0) = 0	and MAD.M_AD_NOT_EFFECT_SALARY=0 --and SP.Publish_Flag = 1
				--			--Commented and Changed by Sumit for same date entry of TDS 25112015
							
						
				--			--- Not effect on salary but payment in salary		
				--			Update #Yearly_Salary 
				--			set Month_1 = 		case when  MAD.ReimAmount  > 0 then  MAD.ReimAmount else 0 end + isnull(M_AREAR_AMOUNT ,0)																					
				--			From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID  
				--				 inner join T0050_AD_MASTER AM ON MAD.AD_ID = AM.AD_ID
				--				 Inner JOIN #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(MAD.To_date) = SP.P_Month and Year(MAD.To_date) = SP.P_Year 
				--			Where mad.For_Date =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD 
				--								   where TSMAD.Emp_ID = MAD.Emp_ID and To_date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date)  and TSMAD.AD_ID = MAD.AD_ID 
				--								   order by tsmad.For_Date desc )
				--			and isnull(mad.S_Sal_Tran_ID,0) = 0	and MAD.M_AD_NOT_EFFECT_SALARY=1 and SP.Publish_Flag = 1	 					
				--			--- Not effect on salary but payment in salary		
								
				--			-- for settelment amount added by mitesh on 17072012
				--			Update #Yearly_Salary 
				--			set Month_1 = Settelement_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and  Def_ID = 'J16'

				--			-- Added by rohit For leave Encasement amount on 13-dec-2013
				--			Update #Yearly_Salary 
				--			set Month_1 = Leave_Salary_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and  Def_ID = 'J17'
								
				--			Update #Yearly_Salary 
				--			set Month_1 = isnull(Travel_Amount,0)
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--			and  Def_ID = 'J18'	 --Added by Sumit 24092015

				--			-- for OT amount added by Hasmukh on 29032013
				--			Update #Yearly_Salary 
				--			set Month_1 = OT_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year  
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and  Def_ID = 'J20'

				--			Update #Yearly_Salary 
				--			set Month_1 = M_WO_OT_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and  Def_ID = 'J21'

				--			Update #Yearly_Salary 
				--			set Month_1 = M_HO_OT_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and  Def_ID = 'J22'

				--			Update #Yearly_Salary 
				--			set Month_1 = Loan_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P23'

				--			Update #Yearly_Salary 
				--			set Month_1 = Loan_Intrest_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P24'

				--			Update #Yearly_Salary 
				--			set Month_1 = Other_dedu_amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P25'
								
				--			Update #Yearly_Salary 
				--			set Month_1 = isnull(GatePass_Amount,0)
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P26'
								
				--			Update #Yearly_Salary   -- Added by Mukti 07042015
				--			set Month_1 = isnull(Asset_Installment,0)
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--			and Def_ID = 'P27'

				--			Update #Yearly_Salary   -- Added by Sumit 24092015
				--			set Month_1 = isnull(Travel_Advance_Amount,0)
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--			and Def_ID = 'P18'

				--			------OT Amount---Hasmukh 29032013
				--			Update #Yearly_Salary 
				--			set Month_1 = Claim_pay_amount
				--			From #Yearly_Salary  Ys  inner join 
				--			(SELECT CLAIM_PAYMENT_DATE,ca.claim_ID,cm.Claim_Name,ca.Emp_Id,Claim_pay_Amount From T0210_MONTHLY_CLAIM_PAYMENT CP INNER JOIN  T0120_CLAIM_APPROVAL CA ON CP.CLAIM_APR_ID =CA.CLAIM_APR_iD  
				--				INNER JOIN T0040_CLAIM_MASTER CM ON CA.CLAIM_ID = CM.CLAIM_ID  inner join #Emp_Cons ec on ca.emp_ID =ec.emp_Id 
				--				WHERE CLAIM_PAYMENT_DATE >=@FROM_DATE  AND CLAIM_PAYMENT_dATE <=@TO_DATE ) q on ys.Emp_ID = q.emp_ID
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(CLAIM_PAYMENT_DATE) = SP.P_Month and Year(CLAIM_PAYMENT_DATE) = SP.P_Year 
				--			Where Month(CLAIM_PAYMENT_DATE) = @Month and Year(CLAIM_PAYMENT_DATE) = @Year And Q.Claim_Name collate SQL_Latin1_General_CP1_CI_AS = YS.Lable_Name collate SQL_Latin1_General_CP1_CI_AS and SP.Publish_Flag = 1
			 
				--			-- Added by rohit For Add component which Not Effect in salary and Part of Ctc on 09102013
				--			if @with_Ctc = 1
				--			begin 
				--				Update #Yearly_Salary 
				--				set Month_1 = table_Sum_CTC.Sum_CTC
				--				from #Yearly_Salary YSD inner join 
				--				(select Isnull(SUM(M_AD_Amount),0) as Sum_CTC,Def_ID  , T.emp_id          
				--			   From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID             
				--			   inner join T0210_MONTHLY_AD_DETAIL T on ms.sal_tran_id = T.sal_tran_id             
				--			   inner join T0050_AD_MASTER A on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID 
				--			   Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year           
				--			   Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year            
				--			   and Def_ID = 'L4' and isnull(T.M_Ad_Not_Effect_Salary,0) = 1 and Ad_Active = 1 And A.AD_Part_Of_CTC = 1 and AD_Flag = 'I' 
				--			   and isnull(S_Sal_Tran_ID,0) = 0 and SP.Publish_Flag = 1            
				--			   group by def_id ,T.Emp_ID) table_Sum_CTC on YSD.def_id = table_Sum_CTC.def_id   and ysd.Emp_Id = table_Sum_CTC.Emp_ID         
				--			   where YSD.def_id = 'L4'   
								
				--				Update #Yearly_Salary 
				--				set Month_1 = Month_1 + Gross_Salary
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'L4'
								
				--			end	
				--			--	Ended by Rohit on 09102013
							
				--			-- Ankit 28032014 --
				--			Update #Yearly_Salary 
				--			set Month_1 = Ms.Sal_Cal_Days
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--			and Def_ID = '52'
				--			-- Ankit 28032014 --
				--	End
				--Else if @count = 2
				--	begin
						 				
				--			Update #Yearly_Salary 
				--			set Month_2 = 1 
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--			and Def_ID = '51'
								
				--			Update #Yearly_Salary 
				--			set Month_2 = Salary_Amount + isnull(Arear_Basic ,0)
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'B1'
								
				--			Update #Yearly_Salary 
				--			set Month_2 = Other_Allow_Amount + isnull(Arear_Basic ,0)	-- Changed By Gadriwala(add field Arear_basic) 26042014
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'J2'
								
								
				--			Update #Yearly_Salary 
				--			set Month_2 = Gross_Salary
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'J23' 
							
				--			Update #Yearly_Salary 
				--			set Month_2 = Total_Earning_Fraction
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'J24'
							
				--			Update #Yearly_Salary 
				--			set Month_2 = Gross_Salary + Total_Earning_Fraction
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'J25'
							
				--			Update #Yearly_Salary 
				--			set Month_2 = PT_Amount 
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P11'

				--			Update #Yearly_Salary 
				--			set Month_2 = LWF_Amount 
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year  
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P12'


				--			Update #Yearly_Salary 
				--			set Month_2 = Revenue_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P13'

				--			Update #Yearly_Salary		
				--			set Month_2 = Advance_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year  
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P14'
								
				--			Update #Yearly_Salary		
				--			set Month_2 = Total_Dedu_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year  
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P98'
																													
				--			Update #Yearly_Salary		
				--			set Month_2 = Net_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year  
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P99'
								
				--			IF @ROUNDING = 0 AND @Net_Salary_Round <> -1
				--				Begin
				--					Update #Yearly_Salary		
				--					set Month_2 = Net_Amount - Net_Salary_Round_Diff_Amount
				--					From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--					Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year  
				--					Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--						and Def_ID = 'P99'
										
				--					Update #Yearly_Salary		
				--					set Month_2 = Net_Salary_Round_Diff_Amount
				--					From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--					Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year  
				--					Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--						and Def_ID = 'P100'
										
				--					Update #Yearly_Salary		
				--					set Month_2 = Net_Amount 
				--					From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--					Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year  
				--					Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--						and Def_ID = 'P101'
				--				End
								
				--			--Update #Yearly_Salary 
				--			--set Month_2 = m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0)
				--			--From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on ys.emp_ID = MAD.emp_ID 
				--			--	AND YS.AD_ID = MAD.AD_ID
				--			--	Where FOR_DATE =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD where TSMAD.Emp_ID = MAD.Emp_ID and To_date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date) order by tsmad.For_Date desc )
				--			--and isnull(mad.S_Sal_Tran_ID,0) = 0	and MAD.M_AD_NOT_EFFECT_SALARY=0
				--			Update #Yearly_Salary 
				--			set Month_2 = m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0)
				--			From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on ys.emp_ID = MAD.emp_ID AND YS.AD_ID = MAD.AD_ID
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(MAD.To_date) = SP.P_Month and Year(MAD.To_date) = SP.P_Year  
				--				Where M_AD_Tran_ID =  (select top 1 M_AD_Tran_ID from T0210_MONTHLY_AD_DETAIL TSMAD 
				--									   where TSMAD.Emp_ID = MAD.Emp_ID and To_date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date) and TSMAD.AD_ID = MAD.AD_ID  
				--									   order by tsmad.M_AD_Tran_ID desc )
				--			and isnull(mad.S_Sal_Tran_ID,0) = 0	and MAD.M_AD_NOT_EFFECT_SALARY=0 and SP.Publish_Flag = 1
				--			--Commented and Changed by Sumit for same date entry of TDS 25112015
																																						
				--			--- Not effect on salary but payment in salary		
				--			Update #Yearly_Salary 
				--			set Month_2 = case when  MAD.ReimAmount  > 0 then  MAD.ReimAmount else 0 end + isnull(M_AREAR_AMOUNT ,0)												
				--			From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID  
				--									 inner join T0050_AD_MASTER AM ON MAD.AD_ID = AM.AD_ID
				--									 Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(MAD.To_date) = SP.P_Month and Year(MAD.To_date) = SP.P_Year  
				--			Where mad.For_Date =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD where TSMAD.Emp_ID = MAD.Emp_ID and To_date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date) and TSMAD.AD_ID = MAD.AD_ID  order by tsmad.For_Date desc )
				--			and isnull(mad.S_Sal_Tran_ID,0) = 0	and MAD.M_AD_NOT_EFFECT_SALARY=1 and SP.Publish_Flag = 1
				--			--- Not effect on salary but payment in salary		
							
				--			Update #Yearly_Salary 
				--			set Month_2 = Settelement_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year  
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and  Def_ID = 'J16'

				--			-- Added by rohit For leave Encasement amount on 13-dec-2013
				--			Update #Yearly_Salary 
				--			set Month_2 = Leave_Salary_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year   
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and  Def_ID = 'J17'
								
				--			Update #Yearly_Salary 
				--			set Month_2 = isnull(Travel_Amount,0)
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year    
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--			and  Def_ID = 'J18'	 --Added by Sumit 24092015

				--			-- for OT amount added by Hasmukh on 29032013
				--			Update #Yearly_Salary 
				--			set Month_2 = OT_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year     
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and  Def_ID = 'J20'

				--			Update #Yearly_Salary 
				--			set Month_2 = M_WO_OT_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year     
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and  Def_ID = 'J21'

				--			Update #Yearly_Salary 
				--			set Month_2 = M_HO_OT_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and  Def_ID = 'J22'

				--			Update #Yearly_Salary 
				--			set Month_2 = Loan_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year 
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P23'

				--			Update #Yearly_Salary 
				--			set Month_2 = Loan_Intrest_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year  
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P24'

				--			Update #Yearly_Salary 
				--			set Month_2 = Other_dedu_amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year  
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P25'
							
				--			Update #Yearly_Salary 
				--			set Month_2 = isnull(GatePass_Amount,0)
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P26'
				--			------OT Amount---Hasmukh 29032013
							
				--			Update #Yearly_Salary  -- Added by Mukti 07042015
				--			set Month_2 = isnull(Asset_Installment,0)
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--			and Def_ID = 'P27'
							
				--			Update #Yearly_Salary   -- Added by Sumit 24092015
				--			set Month_2 = isnull(Travel_Advance_Amount,0)
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--			and Def_ID = 'P18'
							
				--			Update #Yearly_Salary 
				--			set Month_2 = Claim_pay_amount
				--			From #Yearly_Salary  Ys  inner join 
				--			(SELECT CLAIM_PAYMENT_DATE,ca.claim_ID,cm.Claim_Name,ca.Emp_Id,Claim_pay_Amount From T0210_MONTHLY_CLAIM_PAYMENT CP INNER JOIN  T0120_CLAIM_APPROVAL CA ON CP.CLAIM_APR_ID =CA.CLAIM_APR_iD  
				--				INNER JOIN T0040_CLAIM_MASTER CM ON CA.CLAIM_ID = CM.CLAIM_ID  inner join #Emp_Cons ec on ca.emp_ID =ec.emp_Id 
				--				WHERE CLAIM_PAYMENT_DATE >=@FROM_DATE  AND CLAIM_PAYMENT_dATE <=@TO_DATE ) q on ys.Emp_ID = q.emp_ID
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(CLAIM_PAYMENT_DATE) = SP.P_Month and Year(CLAIM_PAYMENT_DATE) = SP.P_Year
				--			Where Month(CLAIM_PAYMENT_DATE) = @Month and Year(CLAIM_PAYMENT_DATE) = @Year And Q.Claim_Name collate SQL_Latin1_General_CP1_CI_AS = YS.Lable_Name collate SQL_Latin1_General_CP1_CI_AS and SP.Publish_Flag = 1
		
		
				--			-- Added by rohit For Add component which Not Effect in salary and Part of Ctc on 09102013
				--			if @with_Ctc = 1
				--			begin 
				--				Update #Yearly_Salary 
				--				set Month_2 = table_Sum_CTC.Sum_CTC
				--				from #Yearly_Salary YSD inner join 
				--				(select Isnull(SUM(M_AD_Amount),0) as Sum_CTC,Def_ID  , T.emp_id          
				--			   From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID             
				--			   inner join T0210_MONTHLY_AD_DETAIL T on ms.sal_tran_id = T.sal_tran_id             
				--			   inner join T0050_AD_MASTER A on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID 
				--			   Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year           
				--			   Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year            
				--			   and Def_ID = 'L4' and isnull(T.M_Ad_Not_Effect_Salary,0) = 1 and Ad_Active = 1 And A.AD_Part_Of_CTC = 1 
				--			   and AD_Flag = 'I' and isnull(S_Sal_Tran_ID,0) = 0 and SP.Publish_Flag = 1           
				--			   group by def_id ,T.Emp_ID) table_Sum_CTC on YSD.def_id = table_Sum_CTC.def_id   and ysd.Emp_Id = table_Sum_CTC.Emp_ID         
				--			   where YSD.def_id = 'L4'   
								
				--				Update #Yearly_Salary 
				--				set Month_2 = Month_2 + Gross_Salary
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1   
				--				and Def_ID = 'L4'
								
				--			end	
				--			--	Ended by Rohit on 09102013
							
				--			-- Ankit 28032014 --
				--			Update #Yearly_Salary 
				--			set Month_2 = Ms.Sal_Cal_Days
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1 
				--			and Def_ID = '52'
				--			-- Ankit 28032014 --
				--	end	
				--else if @count = 3
				--	begin
						
				--			Update #Yearly_Salary 
				--			set Month_3 = 1 
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = '51'
						
				--			Update #Yearly_Salary 
				--			set Month_3 = Salary_Amount + isnull(Arear_Basic ,0)
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'B1'
								
				--			Update #Yearly_Salary 
				--			set Month_3 = Other_Allow_Amount + isnull(Arear_Basic ,0)	-- Changed By Gadriwala(add field Arear_basic) 26042014
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'J2'
								
				--			Update #Yearly_Salary 
				--			set Month_3 = Gross_Salary
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'J23'
							
				--			Update #Yearly_Salary 
				--			set Month_3 = Total_Earning_Fraction
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'J24'
							
				--			Update #Yearly_Salary 
				--			set Month_3 = Gross_Salary + Total_Earning_Fraction
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'J25'
							
				--			Update #Yearly_Salary 
				--			set Month_3 = PT_Amount 
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P11'

				--			Update #Yearly_Salary 
				--			set Month_3 = LWF_Amount 
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P12'


				--			Update #Yearly_Salary 
				--			set Month_3 = Revenue_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P13'

				--			Update #Yearly_Salary		
				--			set Month_3 = Advance_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P14'
								
				--			Update #Yearly_Salary		
				--			set Month_3 = Total_Dedu_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P98'
																													
				--			Update #Yearly_Salary		
				--			set Month_3 = Net_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P99'
								
				--			IF @ROUNDING = 0 AND @Net_Salary_Round <> -1
				--				Begin
				--					Update #Yearly_Salary		
				--					set Month_3 = Net_Amount - Net_Salary_Round_Diff_Amount
				--					From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--					Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
				--					Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--						and Def_ID = 'P99'
										
				--					Update #Yearly_Salary		
				--					set Month_3 = Net_Salary_Round_Diff_Amount
				--					From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--					Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
				--					Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--						and Def_ID = 'P100'
										
				--					Update #Yearly_Salary		
				--					set Month_3 = Net_Amount 
				--					From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--					Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
				--					Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--						and Def_ID = 'P101'
				--				End
							
				--			--Update #Yearly_Salary 
				--			--set Month_3 = m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0)
				--			--From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on ys.emp_ID = MAD.emp_ID 
				--			--	AND YS.AD_ID = MAD.AD_ID
				--			--Where FOR_DATE =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD where TSMAD.Emp_ID = MAD.Emp_ID and To_date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date) order by tsmad.For_Date desc )
				--			--and isnull(mad.S_Sal_Tran_ID,0) = 0	 and MAD.M_AD_NOT_EFFECT_SALARY=0
				--			Update #Yearly_Salary 
				--			set Month_3 = m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0)
				--			From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on ys.emp_ID = MAD.emp_ID AND YS.AD_ID = MAD.AD_ID
				--									 Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(MAD.To_date) = SP.P_Month and Year(MAD.To_date) = SP.P_Year
				--			Where M_AD_Tran_ID =  (select top 1 M_AD_Tran_ID from T0210_MONTHLY_AD_DETAIL TSMAD where TSMAD.Emp_ID = MAD.Emp_ID and To_date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date) and TSMAD.AD_ID = MAD.AD_ID order by tsmad.M_AD_Tran_ID desc )
				--			and isnull(mad.S_Sal_Tran_ID,0) = 0	 and MAD.M_AD_NOT_EFFECT_SALARY=0 and SP.Publish_Flag = 1
				--			--Commented and Changed by Sumit for same date entry of TDS 25112015
																																				
				--			--- not effect on Salary but amount get in payslip
				--			Update #Yearly_Salary 
				--			set Month_3 = case when  MAD.ReimAmount  > 0 then  MAD.ReimAmount else 0 end + isnull(M_AREAR_AMOUNT ,0)																								
				--			From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on 
				--				YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID  inner join T0050_AD_MASTER AM ON 
				--				 MAD.AD_ID = AM.AD_ID
				--				 Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(MAD.To_date) = SP.P_Month and Year(MAD.To_date) = SP.P_Year
				--			Where mad.For_Date =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD where TSMAD.Emp_ID = MAD.Emp_ID and To_date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date) and TSMAD.AD_ID = MAD.AD_ID  order by tsmad.For_Date desc )
				--			and isnull(mad.S_Sal_Tran_ID,0) = 0	and MAD.M_AD_NOT_EFFECT_SALARY=1 and SP.Publish_Flag = 1
				--			--- not effect on Salary but amount get in payslip
							
							
				--			Update #Yearly_Salary 
				--			set Month_3 = Settelement_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and  Def_ID = 'J16'

				--			-- Added by rohit For leave Encasement amount on 13-dec-2013
				--			Update #Yearly_Salary 
				--			set Month_3 = Leave_Salary_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and  Def_ID = 'J17'
							
				--			Update #Yearly_Salary 
				--			set Month_3 = isnull(Travel_Amount,0)
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--			and  Def_ID = 'J18'	 --Added by Sumit 24092015
							
				--			-- for OT amount added by Hasmukh on 29032013
				--			Update #Yearly_Salary 
				--			set Month_3 = OT_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and  Def_ID = 'J20'

				--			Update #Yearly_Salary  
				--			set Month_3 = M_WO_OT_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and  Def_ID = 'J21'

				--			Update #Yearly_Salary 
				--			set Month_3 = M_HO_OT_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and  Def_ID = 'J22'

				--			Update #Yearly_Salary 
				--			set Month_3 = Loan_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P23'

				--			Update #Yearly_Salary 
				--			set Month_3 = Loan_Intrest_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P24'

				--			Update #Yearly_Salary 
				--			set Month_3 = Other_dedu_amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P25'
							
				--			Update #Yearly_Salary 
				--			set Month_3 = isnull(GatePass_Amount,0)
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P26'
				--			------OT Amount---Hasmukh 29032013
							
				--			Update #Yearly_Salary  
				--			set Month_3 = isnull(Asset_Installment,0)
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--			and Def_ID = 'P27'
							
				--			Update #Yearly_Salary   -- Added by Sumit 24092015
				--			set Month_3 = isnull(Travel_Advance_Amount,0)
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--			and Def_ID = 'P18'

				--			Update #Yearly_Salary 
				--			set Month_3 = Claim_pay_amount
				--			From #Yearly_Salary  Ys  inner join 
				--			(SELECT CLAIM_PAYMENT_DATE,ca.claim_ID,cm.Claim_Name,ca.Emp_Id,Claim_pay_Amount From T0210_MONTHLY_CLAIM_PAYMENT CP INNER JOIN  T0120_CLAIM_APPROVAL CA ON CP.CLAIM_APR_ID =CA.CLAIM_APR_iD  
				--				INNER JOIN T0040_CLAIM_MASTER CM ON CA.CLAIM_ID = CM.CLAIM_ID  inner join #Emp_Cons ec on ca.emp_ID =ec.emp_Id 
				--				WHERE CLAIM_PAYMENT_DATE >=@FROM_DATE  AND CLAIM_PAYMENT_dATE <=@TO_DATE ) q on ys.Emp_ID = q.emp_ID
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(CLAIM_PAYMENT_DATE) = SP.P_Month and Year(CLAIM_PAYMENT_DATE) = SP.P_Year
				--			Where Month(CLAIM_PAYMENT_DATE) = @Month and Year(CLAIM_PAYMENT_DATE) = @Year And Q.Claim_Name collate SQL_Latin1_General_CP1_CI_AS = YS.Lable_Name collate SQL_Latin1_General_CP1_CI_AS and SP.Publish_Flag = 1

				--			-- Added by rohit For Add component which Not Effect in salary and Part of Ctc on 09102013
				--			if @with_Ctc = 1
				--			begin 
				--				Update #Yearly_Salary 
				--				set Month_3 = table_Sum_CTC.Sum_CTC
				--				from #Yearly_Salary YSD inner join 
				--				(select Isnull(SUM(M_AD_Amount),0) as Sum_CTC,Def_ID  , T.emp_id          
				--			   From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID             
				--			   inner join T0210_MONTHLY_AD_DETAIL T on ms.sal_tran_id = T.sal_tran_id             
				--			   inner join T0050_AD_MASTER A on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID   
				--			   Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year         
				--			   Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year            
				--			   and Def_ID = 'L4' and isnull(T.M_Ad_Not_Effect_Salary,0) = 1 and Ad_Active = 1 And A.AD_Part_Of_CTC = 1 and AD_Flag = 'I' 
				--			   and isnull(S_Sal_Tran_ID,0) = 0  and SP.Publish_Flag = 1          
				--			   group by def_id ,T.Emp_ID) table_Sum_CTC on YSD.def_id = table_Sum_CTC.def_id   and ysd.Emp_Id = table_Sum_CTC.Emp_ID         
				--			   where YSD.def_id = 'L4'   
								
				--				Update #Yearly_Salary 
				--				set Month_3 = Month_3 + Gross_Salary
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year   
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1   
				--				and Def_ID = 'L4'
								
				--			 end	
				--			--	Ended by Rohit on 09102013

				--			-- Ankit 28032014 --
				--			Update #Yearly_Salary 
				--			set Month_3 = Ms.Sal_Cal_Days
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year   
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year  and SP.Publish_Flag = 1
				--			and Def_ID = '52'
				--			-- Ankit 28032014 --
						
				--	end	
				--else if @count = 4
				--	begin
						
				--			Update #Yearly_Salary 
				--			set Month_4 = 1 
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year   
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = '51'
						
				--			Update #Yearly_Salary 
				--			set Month_4 = Salary_Amount + isnull(Arear_Basic ,0)
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year   
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'B1'
								
				--			Update #Yearly_Salary 
				--			set Month_4 = Other_Allow_Amount + isnull(Arear_Basic ,0)	-- Changed By Gadriwala(add field Arear_basic) 26042014
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year   
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'J2'
								
				--			Update #Yearly_Salary 
				--			set Month_4 = Gross_Salary
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year   
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'J23'

				--			Update #Yearly_Salary 
				--			set Month_4 = Total_Earning_Fraction
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year   
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'J24'
							
				--			Update #Yearly_Salary 
				--			set Month_4 = Gross_Salary + Total_Earning_Fraction
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year   
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'J25' 

				--			Update #Yearly_Salary 
				--			set Month_4 = PT_Amount 
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year   
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P11'

				--			Update #Yearly_Salary 
				--			set Month_4 = LWF_Amount 
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year   
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P12'


				--			Update #Yearly_Salary 
				--			set Month_4 = Revenue_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P13'

				--			Update #Yearly_Salary		
				--			set Month_4 = Advance_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P14' 
								
				--					Update #Yearly_Salary		
				--			set Month_4 = Total_Dedu_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P98'
												
																													
				--			Update #Yearly_Salary		
				--			set Month_4 = Net_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P99'
								
				--			IF @ROUNDING = 0 AND @Net_Salary_Round <> -1
				--				Begin
				--					Update #Yearly_Salary		
				--					set Month_4 = Net_Amount - Net_Salary_Round_Diff_Amount
				--					From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--					Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--					Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--						and Def_ID = 'P99'
										
				--					Update #Yearly_Salary		
				--					set Month_4 = Net_Salary_Round_Diff_Amount
				--					From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--					Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--					Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--						and Def_ID = 'P100'
										
				--					Update #Yearly_Salary		
				--					set Month_4 = Net_Amount 
				--					From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--					Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--					Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--						and Def_ID = 'P101'
				--				End
						
				--			--Update #Yearly_Salary 
				--			--set Month_4 = m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0)
				--			--From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on ys.emp_ID = MAD.emp_ID 
				--			--	AND YS.AD_ID = MAD.AD_ID
				--			--Where FOR_DATE =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD where TSMAD.Emp_ID = MAD.Emp_ID and To_date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date) order by tsmad.For_Date desc )
				--			--and isnull(mad.S_Sal_Tran_ID,0) = 0	 and MAD.M_AD_NOT_EFFECT_SALARY=0
							
				--			Update #Yearly_Salary 
				--			set Month_4 = m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0)
				--			From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on ys.emp_ID = MAD.emp_ID 
				--				AND YS.AD_ID = MAD.AD_ID
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(MAD.To_date) = SP.P_Month and Year(MAD.To_date) = SP.P_Year
				--			Where M_AD_Tran_ID =  (select top 1 M_AD_Tran_ID from T0210_MONTHLY_AD_DETAIL TSMAD where TSMAD.Emp_ID = MAD.Emp_ID and To_date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date) and TSMAD.AD_ID = MAD.AD_ID order by tsmad.M_AD_Tran_ID desc )
				--			and isnull(mad.S_Sal_Tran_ID,0) = 0	 and MAD.M_AD_NOT_EFFECT_SALARY=0 and SP.Publish_Flag = 1
				--			--Commented and Changed by Sumit for same date entry of TDS 25112015
				--			--- not effect on Salary but amount get in payslip
				--			Update #Yearly_Salary 
				--			set Month_4 = case when  MAD.ReimAmount  > 0 then  MAD.ReimAmount else 0 end + isnull(M_AREAR_AMOUNT ,0)																								
				--			From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on 
				--				YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID  inner join T0050_AD_MASTER AM ON 
				--				 MAD.AD_ID = AM.AD_ID
				--				 Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(MAD.To_date) = SP.P_Month and Year(MAD.To_date) = SP.P_Year
				--			Where mad.For_Date =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD where TSMAD.Emp_ID = MAD.Emp_ID and To_date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date) and TSMAD.AD_ID = MAD.AD_ID order by tsmad.For_Date desc )
				--			and isnull(mad.S_Sal_Tran_ID,0) = 0	and MAD.M_AD_NOT_EFFECT_SALARY=1  and SP.Publish_Flag = 1
				--			--- not effect on Salary but amount get in payslip
							
				--			Update #Yearly_Salary 
				--			set Month_4 = Settelement_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and  Def_ID = 'J16'

				--			-- Added by rohit For leave Encasement amount on 13-dec-2013
				--			Update #Yearly_Salary 
				--			set Month_4 = Leave_Salary_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year
				--				and  Def_ID = 'J17'

				--			Update #Yearly_Salary 
				--			set Month_4 = isnull(Travel_Amount,0)
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--			and  Def_ID = 'J18'	 --Added by Sumit 24092015
							
				--			-- for OT amount added by Hasmukh on 29032013
				--			Update #Yearly_Salary 
				--			set Month_4 = OT_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and  Def_ID = 'J20'

				--			Update #Yearly_Salary 
				--			set Month_4 = M_WO_OT_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and  Def_ID = 'J21'

				--			Update #Yearly_Salary 
				--			set Month_4 = M_HO_OT_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and  Def_ID = 'J22'

				--			Update #Yearly_Salary 
				--			set Month_4 = Loan_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P23'

				--			Update #Yearly_Salary 
				--			set Month_4 = Loan_Intrest_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P24'

				--			Update #Yearly_Salary 
				--			set Month_4 = Other_dedu_amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P25'
							
				--			Update #Yearly_Salary 
				--			set Month_4 = isnull(GatePass_Amount,0)
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P26'
								
				--			------OT Amount---Hasmukh 29032013
							
				--			Update #Yearly_Salary 
				--			set Month_4 = isnull(Asset_Installment,0)
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--			and Def_ID = 'P27'
							
				--			Update #Yearly_Salary   -- Added by Sumit 24092015
				--			set Month_4 = isnull(Travel_Advance_Amount,0)
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--			and Def_ID = 'P18'		

				--			Update #Yearly_Salary 
				--			set Month_4 = Claim_pay_amount
				--			From #Yearly_Salary  Ys  inner join 
				--			(SELECT CLAIM_PAYMENT_DATE,ca.claim_ID,cm.Claim_Name,ca.Emp_Id,Claim_pay_Amount From T0210_MONTHLY_CLAIM_PAYMENT CP INNER JOIN  T0120_CLAIM_APPROVAL CA ON CP.CLAIM_APR_ID =CA.CLAIM_APR_iD  
				--				INNER JOIN T0040_CLAIM_MASTER CM ON CA.CLAIM_ID = CM.CLAIM_ID  inner join #Emp_Cons ec on ca.emp_ID =ec.emp_Id 
				--				WHERE CLAIM_PAYMENT_DATE >=@FROM_DATE  AND CLAIM_PAYMENT_dATE <=@TO_DATE ) q on ys.Emp_ID = q.emp_ID
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(CLAIM_PAYMENT_DATE) = SP.P_Month and Year(CLAIM_PAYMENT_DATE) = SP.P_Year
				--			Where Month(CLAIM_PAYMENT_DATE) = @Month and Year(CLAIM_PAYMENT_DATE) = @Year And Q.Claim_Name collate SQL_Latin1_General_CP1_CI_AS = YS.Lable_Name collate SQL_Latin1_General_CP1_CI_AS and SP.Publish_Flag = 1

				--			-- Added by rohit For Add component which Not Effect in salary and Part of Ctc on 09102013
				--			if @with_Ctc = 1
				--			begin 
				--				Update #Yearly_Salary 
				--				set Month_4 = table_Sum_CTC.Sum_CTC
				--				from #Yearly_Salary YSD inner join 
				--				(select Isnull(SUM(M_AD_Amount),0) as Sum_CTC,Def_ID  , T.emp_id          
				--			   From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID             
				--			   inner join T0210_MONTHLY_AD_DETAIL T on ms.sal_tran_id = T.sal_tran_id             
				--			   inner join T0050_AD_MASTER A on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID 
				--			   Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year           
				--			   Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year            
				--			   and Def_ID = 'L4' and isnull(T.M_Ad_Not_Effect_Salary,0) = 1 and Ad_Active = 1 And A.AD_Part_Of_CTC = 1 and AD_Flag = 'I' 
				--			   and isnull(S_Sal_Tran_ID,0) = 0 and SP.Publish_Flag = 1            
				--			   group by def_id ,T.Emp_ID) table_Sum_CTC on YSD.def_id = table_Sum_CTC.def_id   and ysd.Emp_Id = table_Sum_CTC.Emp_ID         
				--			   where YSD.def_id = 'L4'   
								
				--				Update #Yearly_Salary 
				--				set Month_4 = Month_4 + Gross_Salary
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year  
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'L4'
								
				--			 end	
				--			--	Ended by Rohit on 09102013
							
				--			-- Ankit 28032014 --
				--			Update #Yearly_Salary 
				--			set Month_4 = Ms.Sal_Cal_Days
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--			and Def_ID = '52'
				--			-- Ankit 28032014 --
						
				--	end	
				--else if @count = 5
				--	begin
						
				--			Update #Yearly_Salary 
				--			set Month_5 = 1 
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = '51'
								
				--			Update #Yearly_Salary 
				--			set Month_5 = Salary_Amount + isnull(Arear_Basic ,0)
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'B1'
								
				--			Update #Yearly_Salary 
				--			set Month_5 = Other_Allow_Amount + isnull(Arear_Basic ,0)	-- Changed By Gadriwala(add field Arear_basic) 26042014
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'J2'
								
								
				--			Update #Yearly_Salary 
				--			set Month_5 = Gross_Salary
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'J23'
							
				--			Update #Yearly_Salary 
				--			set Month_5 = Total_Earning_Fraction
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'J24'
							
				--			Update #Yearly_Salary 
				--			set Month_5 = Gross_Salary + Total_Earning_Fraction
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'J25'
							
				--			Update #Yearly_Salary 
				--			set Month_5 = PT_Amount 
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P11'

				--			Update #Yearly_Salary 
				--			set Month_5 = LWF_Amount 
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P12'


				--			Update #Yearly_Salary 
				--			set Month_5 = Revenue_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P13'

				--			Update #Yearly_Salary		
				--			set Month_5 = Advance_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P14'
								
				--					Update #Yearly_Salary		
				--			set Month_5 = Total_Dedu_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P98'
													
																													
				--			Update #Yearly_Salary		
				--			set Month_5 = Net_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P99' 
								
				--			IF @ROUNDING = 0 AND @Net_Salary_Round <> -1
				--				Begin
				--					Update #Yearly_Salary		
				--					set Month_5 = Net_Amount - Net_Salary_Round_Diff_Amount
				--					From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--					Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--					Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--						and Def_ID = 'P99'
										
				--					Update #Yearly_Salary		
				--					set Month_5 = Net_Salary_Round_Diff_Amount
				--					From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--					Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--					Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--						and Def_ID = 'P100'
										
				--					Update #Yearly_Salary		
				--					set Month_5 = Net_Amount 
				--					From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--					Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--					Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--						and Def_ID = 'P101'
				--				End	
						
				--			--Update #Yearly_Salary 
				--			--set Month_5 = m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0)
				--			--From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on ys.emp_ID = MAD.emp_ID 
				--			--	AND YS.AD_ID = MAD.AD_ID
				--			--Where FOR_DATE =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD where TSMAD.Emp_ID = MAD.Emp_ID and To_date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date) order by tsmad.For_Date desc )
				--			--and isnull(mad.S_Sal_Tran_ID,0) = 0	and MAD.M_AD_NOT_EFFECT_SALARY=0
				--			Update #Yearly_Salary 
				--			set Month_5 = m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0)
				--			From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on ys.emp_ID = MAD.emp_ID 
				--				AND YS.AD_ID = MAD.AD_ID
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(MAD.To_date) = SP.P_Month and Year(MAD.To_date) = SP.P_Year
				--			Where M_AD_Tran_ID =  (select top 1 M_AD_Tran_ID from T0210_MONTHLY_AD_DETAIL TSMAD where TSMAD.Emp_ID = MAD.Emp_ID and To_date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date) and TSMAD.AD_ID = MAD.AD_ID order by tsmad.M_AD_Tran_ID desc )
				--			and isnull(mad.S_Sal_Tran_ID,0) = 0	and MAD.M_AD_NOT_EFFECT_SALARY=0 and SP.Publish_Flag = 1
				--			--Commented and Changed by Sumit for same date entry of TDS 25112015
							
				--			--- not effect on Salary but amount get in payslip
				--			Update #Yearly_Salary 
				--			set Month_5 = case when  MAD.ReimAmount  > 0 then  MAD.ReimAmount else 0 end + isnull(M_AREAR_AMOUNT ,0)																							
				--			From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on 
				--				YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID  inner join T0050_AD_MASTER AM ON 
				--				 MAD.AD_ID = AM.AD_ID
				--				 Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(MAD.To_date) = SP.P_Month and Year(MAD.To_date) = SP.P_Year
				--			Where mad.For_Date =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD where TSMAD.Emp_ID = MAD.Emp_ID and To_date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date) and TSMAD.AD_ID = MAD.AD_ID order by tsmad.For_Date desc )
				--			and isnull(mad.S_Sal_Tran_ID,0) = 0	and MAD.M_AD_NOT_EFFECT_SALARY=1 and SP.Publish_Flag = 1						
				--			--- not effect on Salary but amount get in payslip 
							
				--			Update #Yearly_Salary 
				--			set Month_5 = Settelement_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1	
				--				and  Def_ID = 'J16'

				--			-- Added by rohit For leave Encasement amount on 13-dec-2013
				--			Update #Yearly_Salary 
				--			set Month_5 = Leave_Salary_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1	
				--				and  Def_ID = 'J17'

				--			Update #Yearly_Salary 
				--			set Month_5 = isnull(Travel_Amount,0)
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1	
				--			and  Def_ID = 'J18'	 --Added by Sumit 24092015
							
				--			-- for OT amount added by Hasmukh on 29032013
				--			Update #Yearly_Salary 
				--			set Month_5 = OT_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1	
				--				and  Def_ID = 'J20'

				--			Update #Yearly_Salary 
				--			set Month_5 = M_WO_OT_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1	
				--				and  Def_ID = 'J21'

				--			Update #Yearly_Salary 
				--			set Month_5 = M_HO_OT_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and  Def_ID = 'J22'

				--			Update #Yearly_Salary 
				--			set Month_5 = Loan_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P23'

				--			Update #Yearly_Salary 
				--			set Month_5 = Loan_Intrest_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P24'

				--			Update #Yearly_Salary 
				--			set Month_5 = Other_dedu_amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P25'
								
				--			Update #Yearly_Salary 
				--			set Month_5 = isnull(GatePass_Amount,0)
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--				and Def_ID = 'P26'
				--			------OT Amount---Hasmukh 29032013
							
				--			Update #Yearly_Salary 
				--			set Month_5 = isnull(Asset_Installment,0)
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--			and Def_ID = 'P27'

				--			Update #Yearly_Salary   -- Added by Sumit 24092015
				--			set Month_5 = isnull(Travel_Advance_Amount,0)
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag = 1
				--			and Def_ID = 'P18'		
							
				--			Update #Yearly_Salary 
				--			set Month_5 = Claim_pay_amount
				--			From #Yearly_Salary  Ys  inner join 
				--			(SELECT CLAIM_PAYMENT_DATE,ca.claim_ID,cm.Claim_Name,ca.Emp_Id,Claim_pay_Amount From T0210_MONTHLY_CLAIM_PAYMENT CP INNER JOIN  T0120_CLAIM_APPROVAL CA ON CP.CLAIM_APR_ID =CA.CLAIM_APR_iD  
				--				INNER JOIN T0040_CLAIM_MASTER CM ON CA.CLAIM_ID = CM.CLAIM_ID  inner join #Emp_Cons ec on ca.emp_ID =ec.emp_Id 
				--				WHERE CLAIM_PAYMENT_DATE >=@FROM_DATE  AND CLAIM_PAYMENT_dATE <=@TO_DATE ) q on ys.Emp_ID = q.emp_ID
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(CLAIM_PAYMENT_DATE) = SP.P_Month and Year(CLAIM_PAYMENT_DATE) = SP.P_Year
				--			Where Month(CLAIM_PAYMENT_DATE) = @Month and Year(CLAIM_PAYMENT_DATE) = @Year And Q.Claim_Name collate SQL_Latin1_General_CP1_CI_AS = YS.Lable_Name collate SQL_Latin1_General_CP1_CI_AS and SP.Publish_Flag = 1
							
				--			-- Added by rohit For Add component which Not Effect in salary and Part of Ctc on 09102013
				--			if @with_Ctc = 1
				--			begin 
				--				Update #Yearly_Salary 
				--				set Month_5 = table_Sum_CTC.Sum_CTC
				--				from #Yearly_Salary YSD inner join 
				--				(select Isnull(SUM(M_AD_Amount),0) as Sum_CTC,Def_ID  , T.emp_id          
				--			   From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID             
				--			   inner join T0210_MONTHLY_AD_DETAIL T on ms.sal_tran_id = T.sal_tran_id             
				--			   inner join T0050_AD_MASTER A on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID 
				--			   Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year           
				--			   Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year            
				--			   and Def_ID = 'L4' and isnull(T.M_Ad_Not_Effect_Salary,0) = 1 and Ad_Active = 1 And A.AD_Part_Of_CTC = 1 and AD_Flag = 'I' 
				--			   and isnull(S_Sal_Tran_ID,0) = 0 and SP.Publish_Flag = 1           
				--			   group by def_id ,T.Emp_ID) table_Sum_CTC on YSD.def_id = table_Sum_CTC.def_id   and ysd.Emp_Id = table_Sum_CTC.Emp_ID         
				--			   where YSD.def_id = 'L4'   
								
				--				Update #Yearly_Salary 
				--				set Month_5 = Month_5 + Gross_Salary
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year           
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and Def_ID = 'L4'
								
				--			 end	
				--			--	Ended by Rohit on 09102013
							
				--			-- Ankit 28032014 --
				--			Update #Yearly_Salary 
				--			set Month_5 = Ms.Sal_Cal_Days
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year           
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--			and Def_ID = '52'
				--			-- Ankit 28032014 --
					
				--	end	
				--else if @count = 6
				--	begin
						
				--				Update #Yearly_Salary 
				--				set Month_6 = 1 
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year           
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = '51'
								
				--				Update #Yearly_Salary 
				--				set Month_6 = Salary_Amount + isnull(Arear_Basic ,0)
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year            
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'B1'
									
				--				Update #Yearly_Salary 
				--				set Month_6 = Other_Allow_Amount + isnull(Arear_Basic ,0)	-- Changed By Gadriwala(add field Arear_basic) 26042014
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'J2'
									
				--				Update #Yearly_Salary 
				--				set Month_6 = Gross_Salary
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'J23'
								
				--				Update #Yearly_Salary 
				--				set Month_6 = Total_Earning_Fraction
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'J24'
								
				--				Update #Yearly_Salary 
				--				set Month_6 = Gross_Salary + Total_Earning_Fraction
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'J25'
								
				--				Update #Yearly_Salary 
				--				set Month_6 = PT_Amount 
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P11'

				--				Update #Yearly_Salary 
				--				set Month_6 = LWF_Amount 
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P12'


				--				Update #Yearly_Salary 
				--				set Month_6 = Revenue_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P13'

				--				Update #Yearly_Salary		
				--				set Month_6 = Advance_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P14'
									
				--					Update #Yearly_Salary		
				--				set Month_6 = Total_Dedu_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P98'
																														
				--				Update #Yearly_Salary		
				--				set Month_6 = Net_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P99'
								
				--				IF @ROUNDING = 0 AND @Net_Salary_Round <> -1
				--					Begin
				--						Update #Yearly_Salary		
				--						set Month_6 = Net_Amount - Net_Salary_Round_Diff_Amount
				--						From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--						Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--						Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--							and Def_ID = 'P99'
											
				--						Update #Yearly_Salary		
				--						set Month_6 = Net_Salary_Round_Diff_Amount
				--						From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--						Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--						Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--							and Def_ID = 'P100'
											
				--						Update #Yearly_Salary		
				--						set Month_6 = Net_Amount 
				--						From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--						Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--						Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--							and Def_ID = 'P101'
				--					End
									
				--				--Update #Yearly_Salary 
				--				--set Month_6 = m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0)
				--				--From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on ys.emp_ID = MAD.emp_ID 
				--				--	AND YS.AD_ID = MAD.AD_ID
				--				--Where FOR_DATE =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD where TSMAD.Emp_ID = MAD.Emp_ID and To_date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date) order by tsmad.For_Date desc )
				--				--and isnull(mad.S_Sal_Tran_ID,0) = 0	and MAD.M_AD_NOT_EFFECT_SALARY=0
				--				Update #Yearly_Salary 
				--				set Month_6 = m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0)
				--				From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on ys.emp_ID = MAD.emp_ID  AND YS.AD_ID = MAD.AD_ID
				--					Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(MAD.To_date) = SP.P_Month and Year(MAD.To_date) = SP.P_Year
				--				Where M_AD_Tran_ID =  (select top 1 M_AD_Tran_ID from T0210_MONTHLY_AD_DETAIL TSMAD where TSMAD.Emp_ID = MAD.Emp_ID and To_date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date) and TSMAD.AD_ID = MAD.AD_ID order by tsmad.M_AD_Tran_ID desc )
				--				and isnull(mad.S_Sal_Tran_ID,0) = 0	and MAD.M_AD_NOT_EFFECT_SALARY=0  and SP.Publish_Flag =1
				--				--Commented and Changed by Sumit for same date entry of TDS 25112015
								
				--				--- not effect on Salary but amount get in payslip
				--				Update #Yearly_Salary 
				--				set Month_6 = case when  MAD.ReimAmount  > 0 then  MAD.ReimAmount else 0 end + isnull(M_AREAR_AMOUNT ,0)																								
				--				From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on 
				--					YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID  inner join T0050_AD_MASTER AM ON 
				--					 MAD.AD_ID = AM.AD_ID
				--					 Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(MAD.To_date) = SP.P_Month and Year(MAD.To_date) = SP.P_Year
				--				Where mad.For_Date =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD where TSMAD.Emp_ID = MAD.Emp_ID and To_date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date) and TSMAD.AD_ID = MAD.AD_ID  order by tsmad.For_Date desc )
				--				and isnull(mad.S_Sal_Tran_ID,0) = 0	and MAD.M_AD_NOT_EFFECT_SALARY=1  and SP.Publish_Flag =1
				--				--- not effect on Salary but amount get in payslip
								
				--				Update #Yearly_Salary 
				--				set Month_6 = Settelement_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and  Def_ID = 'J16'

				--				-- Added by rohit For leave Encasement amount on 13-dec-2013
				--				Update #Yearly_Salary 
				--				set Month_6 = Leave_Salary_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and  Def_ID = 'J17'

				--				Update #Yearly_Salary 
				--				set Month_6 = isnull(Travel_Amount,0)
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and  Def_ID = 'J18'	 --Added by Sumit 24092015
								
								
				--				-- for OT amount added by Hasmukh on 29032013
				--				Update #Yearly_Salary 
				--				set Month_6 = OT_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and  Def_ID = 'J20'

				--				Update #Yearly_Salary 
				--				set Month_6 = M_WO_OT_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and  Def_ID = 'J21'

				--				Update #Yearly_Salary 
				--				set Month_6 = M_HO_OT_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and  Def_ID = 'J22'

				--				Update #Yearly_Salary 
				--				set Month_6 = Loan_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P23'

				--				Update #Yearly_Salary 
				--				set Month_6 = Loan_Intrest_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P24'

				--				Update #Yearly_Salary 
				--				set Month_6 = Other_dedu_amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P25'
								
				--				Update #Yearly_Salary 
				--				set Month_6 = isnull(GatePass_Amount,0)
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P26'
				--				------OT Amount---Hasmukh 29032013
								
				--				Update #Yearly_Salary 
				--				set Month_6 = isnull(Asset_Installment,0)
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and Def_ID = 'P27'
								
				--				Update #Yearly_Salary   -- Added by Sumit 24092015
				--				set Month_6 = isnull(Travel_Advance_Amount,0)
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and Def_ID = 'P18'		

				--				Update #Yearly_Salary 
				--				set Month_6 = Claim_pay_amount
				--				From #Yearly_Salary  Ys  inner join 
				--				(SELECT CLAIM_PAYMENT_DATE,ca.claim_ID,cm.Claim_Name,ca.Emp_Id,Claim_pay_Amount From T0210_MONTHLY_CLAIM_PAYMENT CP INNER JOIN  T0120_CLAIM_APPROVAL CA ON CP.CLAIM_APR_ID =CA.CLAIM_APR_iD  
				--					INNER JOIN T0040_CLAIM_MASTER CM ON CA.CLAIM_ID = CM.CLAIM_ID  inner join #Emp_Cons ec on ca.emp_ID =ec.emp_Id 
				--					WHERE CLAIM_PAYMENT_DATE >=@FROM_DATE  AND CLAIM_PAYMENT_dATE <=@TO_DATE ) q on ys.Emp_ID = q.emp_ID
				--					Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(CLAIM_PAYMENT_DATE) = SP.P_Month and Year(CLAIM_PAYMENT_DATE) = SP.P_Year
				--				Where Month(CLAIM_PAYMENT_DATE) = @Month and Year(CLAIM_PAYMENT_DATE) = @Year And Q.Claim_Name collate SQL_Latin1_General_CP1_CI_AS = YS.Lable_Name collate SQL_Latin1_General_CP1_CI_AS and SP.Publish_Flag =1
								
				--				-- Added by rohit For Add component which Not Effect in salary and Part of Ctc on 09102013
				--				if @with_Ctc = 1
				--				begin 
				--					Update #Yearly_Salary 
				--					set Month_6 = table_Sum_CTC.Sum_CTC
				--					from #Yearly_Salary YSD inner join 
				--					(select Isnull(SUM(M_AD_Amount),0) as Sum_CTC,Def_ID  , T.emp_id          
				--				   From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID             
				--				   inner join T0210_MONTHLY_AD_DETAIL T on ms.sal_tran_id = T.sal_tran_id             
				--				   inner join T0050_AD_MASTER A on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID   
				--				   Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year         
				--				   Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year            
				--				   and Def_ID = 'L4' and isnull(T.M_Ad_Not_Effect_Salary,0) = 1 and Ad_Active = 1 And A.AD_Part_Of_CTC = 1 and AD_Flag = 'I' 
				--				   and isnull(S_Sal_Tran_ID,0) = 0 and SP.Publish_Flag =1            
				--				   group by def_id ,T.Emp_ID) table_Sum_CTC on YSD.def_id = table_Sum_CTC.def_id   and ysd.Emp_Id = table_Sum_CTC.Emp_ID         
				--				   where YSD.def_id = 'L4'   
									
				--					Update #Yearly_Salary 
				--					set Month_6 = Month_6 + Gross_Salary
				--					From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--					Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--					Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'L4'
									
				--				 end	
				--				--	Ended by Rohit on 09102013
								
				--				-- Ankit 28032014 --
				--				Update #Yearly_Salary 
				--				set Month_6 = Ms.Sal_Cal_Days
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year  and SP.Publish_Flag =1
				--				and Def_ID = '52'
				--				-- Ankit 28032014 --
							
				--	end	
				--else if @count = 7
				--	begin
						
				--				Update #Yearly_Salary 
				--				set Month_7 = 1 
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and Def_ID = '51'
									
				--				Update #Yearly_Salary 
				--				set Month_7 = Salary_Amount + isnull(Arear_Basic ,0)
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'B1'
								
				--				Update #Yearly_Salary 
				--				set Month_7 = Other_Allow_Amount + isnull(Arear_Basic ,0)	-- Changed By Gadriwala(add field Arear_basic) 26042014
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'J2'
									
				--				Update #Yearly_Salary 
				--				set Month_7 = Gross_Salary
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'J23'
								
				--				Update #Yearly_Salary 
				--				set Month_7 = Total_Earning_Fraction
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'J24'
								
				--				Update #Yearly_Salary 
				--				set Month_7 = Gross_Salary + Total_Earning_Fraction
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'J25'
								
				--				Update #Yearly_Salary 
				--				set Month_7 = PT_Amount 
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P11'

				--				Update #Yearly_Salary 
				--				set Month_7 = LWF_Amount 
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P12'


				--				Update #Yearly_Salary 
				--				set Month_7 = Revenue_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P13'

				--				Update #Yearly_Salary		
				--				set Month_7 = Advance_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P14'
									
				--					Update #Yearly_Salary		
				--				set Month_7 = Total_Dedu_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P98'						
																														
				--				Update #Yearly_Salary		
				--				set Month_7 = Net_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P99'
									
				--				IF @ROUNDING = 0 AND @Net_Salary_Round <> -1
				--					Begin
				--						Update #Yearly_Salary		
				--						set Month_7 = Net_Amount - Net_Salary_Round_Diff_Amount
				--						From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--						Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--						Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--							and Def_ID = 'P99'
											
				--						Update #Yearly_Salary		
				--						set Month_7 = Net_Salary_Round_Diff_Amount
				--						From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--						Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--						Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--							and Def_ID = 'P100'
											
				--						Update #Yearly_Salary		
				--						set Month_7 = Net_Amount 
				--						From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--						Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--						Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--							and Def_ID = 'P101'
				--					End	
							
				--				--Update #Yearly_Salary 
				--				--set Month_7 = m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0)
				--				--From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on ys.emp_ID = MAD.emp_ID 
				--				--	AND YS.AD_ID = MAD.AD_ID
				--				--Where FOR_DATE =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD where TSMAD.Emp_ID = MAD.Emp_ID and To_date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date) order by tsmad.For_Date desc )
				--				--and isnull(mad.S_Sal_Tran_ID,0) = 0 and MAD.M_AD_NOT_EFFECT_SALARY=0
				--				Update #Yearly_Salary 
				--				set Month_7 = m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0)
				--				From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on ys.emp_ID = MAD.emp_ID AND YS.AD_ID = MAD.AD_ID
				--										 Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(MAD.To_date) = SP.P_Month and Year(MAD.To_date) = SP.P_Year
				--				Where M_AD_Tran_ID =  (select top 1 M_AD_Tran_ID from T0210_MONTHLY_AD_DETAIL TSMAD where TSMAD.Emp_ID = MAD.Emp_ID and To_date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date) and TSMAD.AD_ID = MAD.AD_ID order by tsmad.M_AD_Tran_ID desc )
				--				and isnull(mad.S_Sal_Tran_ID,0) = 0 and MAD.M_AD_NOT_EFFECT_SALARY=0 and SP.Publish_Flag =1
								
				--				--Commented and Changed by Sumit for same date entry of TDS 25112015
								
				--				--- not effect on Salary but amount get in payslip
				--				Update #Yearly_Salary 
				--				set Month_7 = case when  MAD.ReimAmount  > 0 then  MAD.ReimAmount else 0 end + isnull(M_AREAR_AMOUNT ,0)																								
				--				From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on 
				--					YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID  inner join T0050_AD_MASTER AM ON MAD.AD_ID = AM.AD_ID
				--					Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(MAD.To_date) = SP.P_Month and Year(MAD.To_date) = SP.P_Year
				--				Where mad.For_Date =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD where TSMAD.Emp_ID = MAD.Emp_ID and To_date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date) and TSMAD.AD_ID = MAD.AD_ID  order by tsmad.For_Date desc )
				--				and isnull(mad.S_Sal_Tran_ID,0) = 0	and MAD.M_AD_NOT_EFFECT_SALARY=1  and SP.Publish_Flag =1
				--				--- not effect on Salary but amount get in payslip
								
								
				--				Update #Yearly_Salary 
				--				set Month_7 = Settelement_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and  Def_ID = 'J16'

				--				-- Added by rohit For leave Encasement amount on 13-dec-2013
				--				Update #Yearly_Salary 
				--				set Month_7 = Leave_Salary_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and  Def_ID = 'J17'
									
				--				Update #Yearly_Salary 
				--				set Month_7 = isnull(Travel_Amount,0)
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and  Def_ID = 'J18'	 --Added by Sumit 24092015

				--				-- for OT amount added by Hasmukh on 29032013
				--				Update #Yearly_Salary 
				--				set Month_7 = OT_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and  Def_ID = 'J20'

				--				Update #Yearly_Salary 
				--				set Month_7 = M_WO_OT_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and  Def_ID = 'J21'

				--				Update #Yearly_Salary 
				--				set Month_7 = M_HO_OT_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and  Def_ID = 'J22'

				--				Update #Yearly_Salary 
				--				set Month_7 = Loan_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P23'

				--				Update #Yearly_Salary 
				--				set Month_7 = Loan_Intrest_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P24'

				--				Update #Yearly_Salary 
				--				set Month_7 = Other_dedu_amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P25'
								
				--				Update #Yearly_Salary 
				--				set Month_7 = isnull(GatePass_Amount,0)
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P26'
				--				------OT Amount---Hasmukh 29032013
								
				--				Update #Yearly_Salary 
				--				set Month_7 = isnull(Asset_Installment,0)
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and Def_ID = 'P27'
								
				--				Update #Yearly_Salary   -- Added by Sumit 24092015
				--				set Month_7 = isnull(Travel_Advance_Amount,0)
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and Def_ID = 'P18'		

				--				Update #Yearly_Salary 
				--				set Month_7 = Claim_pay_amount
				--				From #Yearly_Salary  Ys  inner join 
				--				(SELECT CLAIM_PAYMENT_DATE,ca.claim_ID,cm.Claim_Name,ca.Emp_Id,Claim_pay_Amount From T0210_MONTHLY_CLAIM_PAYMENT CP INNER JOIN  T0120_CLAIM_APPROVAL CA ON CP.CLAIM_APR_ID =CA.CLAIM_APR_iD  
				--					INNER JOIN T0040_CLAIM_MASTER CM ON CA.CLAIM_ID = CM.CLAIM_ID  inner join #Emp_Cons ec on ca.emp_ID =ec.emp_Id 
				--					WHERE CLAIM_PAYMENT_DATE >=@FROM_DATE  AND CLAIM_PAYMENT_dATE <=@TO_DATE ) q on ys.Emp_ID = q.emp_ID
				--					Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(CLAIM_PAYMENT_DATE) = SP.P_Month and Year(CLAIM_PAYMENT_DATE) = SP.P_Year
				--				Where Month(CLAIM_PAYMENT_DATE) = @Month and Year(CLAIM_PAYMENT_DATE) = @Year And Q.Claim_Name collate SQL_Latin1_General_CP1_CI_AS = YS.Lable_Name collate SQL_Latin1_General_CP1_CI_AS  and SP.Publish_Flag =1
								
				--				-- Added by rohit For Add component which Not Effect in salary and Part of Ctc on 09102013
				--				if @with_Ctc = 1
				--				begin 
				--					Update #Yearly_Salary 
				--					set Month_7 = table_Sum_CTC.Sum_CTC
				--					from #Yearly_Salary YSD inner join 
				--					(select Isnull(SUM(M_AD_Amount),0) as Sum_CTC,Def_ID  , T.emp_id          
				--				   From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID             
				--				   inner join T0210_MONTHLY_AD_DETAIL T on ms.sal_tran_id = T.sal_tran_id             
				--				   inner join T0050_AD_MASTER A on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID 
				--				   Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year           
				--				   Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year            
				--				   and Def_ID = 'L4' and isnull(T.M_Ad_Not_Effect_Salary,0) = 1 and Ad_Active = 1 And A.AD_Part_Of_CTC = 1 and AD_Flag = 'I' 
				--				   and isnull(S_Sal_Tran_ID,0) = 0 and SP.Publish_Flag =1            
				--				   group by def_id ,T.Emp_ID) table_Sum_CTC on YSD.def_id = table_Sum_CTC.def_id   and ysd.Emp_Id = table_Sum_CTC.Emp_ID         
				--				   where YSD.def_id = 'L4'   
									
				--					Update #Yearly_Salary 
				--					set Month_7 = Month_7 + Gross_Salary
				--					From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--					Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--					Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'L4'
									
				--				 end	
				--				--	Ended by Rohit on 09102013
								
				--				-- Ankit 28032014 --
				--				Update #Yearly_Salary 
				--				set Month_7 = Ms.Sal_Cal_Days
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and Def_ID = '52'
				--				-- Ankit 28032014 --
						
				--	end	
				--else if @count = 8
				--	begin
					
					
				--				Update #Yearly_Salary 
				--				set Month_8 = 1 
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = '51'
							
				--				Update #Yearly_Salary 
				--				set Month_8 = Salary_Amount + isnull(Arear_Basic ,0)
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'B1'
									
				--				Update #Yearly_Salary 
				--				set Month_8 = Other_Allow_Amount + isnull(Arear_Basic ,0)	-- Changed By Gadriwala(add field Arear_basic) 26042014
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'J2'
									
				--				Update #Yearly_Salary 
				--				set Month_8 = Gross_Salary
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'J23'
								
				--				Update #Yearly_Salary 
				--				set Month_8 = Total_Earning_Fraction
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'J24'
								
				--				Update #Yearly_Salary 
				--				set Month_8 = Gross_Salary + Total_Earning_Fraction
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'J25'

				--				Update #Yearly_Salary 
				--				set Month_8 = PT_Amount 
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P11'

				--				Update #Yearly_Salary 
				--				set Month_8 = LWF_Amount 
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P12'


				--				Update #Yearly_Salary 
				--				set Month_8 = Revenue_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P13'

				--				Update #Yearly_Salary		
				--				set Month_8 = Advance_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P14'
									
				--					Update #Yearly_Salary		
				--				set Month_8 = Total_Dedu_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P98'
																														
				--				Update #Yearly_Salary		
				--				set Month_8 = Net_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P99'
									
				--				IF @ROUNDING = 0 AND @Net_Salary_Round <> -1
				--					Begin
				--						Update #Yearly_Salary		
				--						set Month_8 = Net_Amount - Net_Salary_Round_Diff_Amount
				--						From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--						Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--						Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--							and Def_ID = 'P99'
											
				--						Update #Yearly_Salary		
				--						set Month_8 = Net_Salary_Round_Diff_Amount
				--						From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--						Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--						Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--							and Def_ID = 'P100'
											
				--						Update #Yearly_Salary		
				--						set Month_8 = Net_Amount 
				--						From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--						Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--						Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--							and Def_ID = 'P101'
				--					End	
							
				--				--Update #Yearly_Salary 
				--				--set Month_8 = m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0)
				--				--From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on ys.emp_ID = MAD.emp_ID 
				--				--	AND YS.AD_ID = MAD.AD_ID
				--				--Where FOR_DATE =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD where TSMAD.Emp_ID = MAD.Emp_ID and To_date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date) order by tsmad.For_Date desc )
				--				--and isnull(mad.S_Sal_Tran_ID,0) = 0 and MAD.M_AD_NOT_EFFECT_SALARY=0
				--				Update #Yearly_Salary 
				--				set Month_8 = m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0)
				--				From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on ys.emp_ID = MAD.emp_ID 
				--					AND YS.AD_ID = MAD.AD_ID
				--					Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(MAD.To_date) = SP.P_Month and Year(MAD.To_date) = SP.P_Year
				--				Where M_AD_Tran_ID =  (select top 1 M_AD_Tran_ID from T0210_MONTHLY_AD_DETAIL TSMAD where TSMAD.Emp_ID = MAD.Emp_ID and To_date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date) and TSMAD.AD_ID = MAD.AD_ID order by tsmad.M_AD_Tran_ID desc )
				--				and isnull(mad.S_Sal_Tran_ID,0) = 0 and MAD.M_AD_NOT_EFFECT_SALARY=0 and SP.Publish_Flag =1
				--				--Commented and Changed by Sumit for same date entry of TDS in FNF Case problem in BMA Client 25112015					
								
				--				--- not effect on Salary but amount get in payslip
				--				Update #Yearly_Salary 
				--				set Month_8 = case when  MAD.ReimAmount  > 0 then  MAD.ReimAmount else 0 end + isnull(M_AREAR_AMOUNT ,0)																								
				--				From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on 
				--					YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID  inner join T0050_AD_MASTER AM ON 
				--					 MAD.AD_ID = AM.AD_ID
				--					 Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(MAD.To_date) = SP.P_Month and Year(MAD.To_date) = SP.P_Year
				--				Where mad.For_Date =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD where TSMAD.Emp_ID = MAD.Emp_ID and To_date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date) and TSMAD.AD_ID = MAD.AD_ID order by tsmad.For_Date desc )
				--				and isnull(mad.S_Sal_Tran_ID,0) = 0	and MAD.M_AD_NOT_EFFECT_SALARY=1  and SP.Publish_Flag =1
				--				--- not effect on Salary but amount get in payslip
								
				--				Update #Yearly_Salary 
				--				set Month_8 = Settelement_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and  Def_ID = 'J16'

				--				-- Added by rohit For leave Encasement amount on 13-dec-2013
				--				Update #Yearly_Salary 
				--				set Month_8 = Leave_Salary_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and  Def_ID = 'J17'

				--				Update #Yearly_Salary 
				--				set Month_8 = isnull(Travel_Amount,0)
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and  Def_ID = 'J18'	 --Added by Sumit 24092015
								
				--				-- for OT amount added by Hasmukh on 29032013
				--				Update #Yearly_Salary 
				--				set Month_8 = OT_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and  Def_ID = 'J20'

				--				Update #Yearly_Salary 
				--				set Month_8 = M_WO_OT_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and  Def_ID = 'J21'

				--				Update #Yearly_Salary 
				--				set Month_8 = M_HO_OT_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and  Def_ID = 'J22'

				--				Update #Yearly_Salary 
				--				set Month_8 = Loan_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P23'

				--				Update #Yearly_Salary 
				--				set Month_8 = Loan_Intrest_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P24'

				--				Update #Yearly_Salary 
				--				set Month_8 = Other_dedu_amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P25'
								
				--				Update #Yearly_Salary 
				--				set Month_8 = isnull(GatePass_Amount,0)
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P26'
				--				------OT Amount---Hasmukh 29032013
								
				--				Update #Yearly_Salary 
				--				set Month_8 = isnull(Asset_Installment,0)
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and Def_ID = 'P27'

				--				Update #Yearly_Salary   -- Added by Sumit 24092015
				--				set Month_8 = isnull(Travel_Advance_Amount,0)
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and Def_ID = 'P18'		

				--				Update #Yearly_Salary 
				--				set Month_8 = Claim_pay_amount
				--				From #Yearly_Salary  Ys  inner join 
				--				(SELECT CLAIM_PAYMENT_DATE,ca.claim_ID,cm.Claim_Name,ca.Emp_Id,Claim_pay_Amount From T0210_MONTHLY_CLAIM_PAYMENT CP INNER JOIN  T0120_CLAIM_APPROVAL CA ON CP.CLAIM_APR_ID =CA.CLAIM_APR_iD  
				--					INNER JOIN T0040_CLAIM_MASTER CM ON CA.CLAIM_ID = CM.CLAIM_ID  inner join #Emp_Cons ec on ca.emp_ID =ec.emp_Id 
				--					WHERE CLAIM_PAYMENT_DATE >=@FROM_DATE  AND CLAIM_PAYMENT_dATE <=@TO_DATE ) q on ys.Emp_ID = q.emp_ID
				--					Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(CLAIM_PAYMENT_DATE) = SP.P_Month and Year(CLAIM_PAYMENT_DATE) = SP.P_Year
				--				Where Month(CLAIM_PAYMENT_DATE) = @Month and Year(CLAIM_PAYMENT_DATE) = @Year And Q.Claim_Name collate SQL_Latin1_General_CP1_CI_AS = YS.Lable_Name collate SQL_Latin1_General_CP1_CI_AS and SP.Publish_Flag =1
								
				--				-- Added by rohit For Add component which Not Effect in salary and Part of Ctc on 09102013
				--				if @with_Ctc = 1
				--				begin 
				--					Update #Yearly_Salary 
				--					set Month_8 = table_Sum_CTC.Sum_CTC
				--					from #Yearly_Salary YSD inner join 
				--					(select Isnull(SUM(M_AD_Amount),0) as Sum_CTC,Def_ID  , T.emp_id          
				--				   From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID             
				--				   inner join T0210_MONTHLY_AD_DETAIL T on ms.sal_tran_id = T.sal_tran_id             
				--				   inner join T0050_AD_MASTER A on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID 
				--				   Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year           
				--				   Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year            
				--				   and Def_ID = 'L4' and isnull(T.M_Ad_Not_Effect_Salary,0) = 1 and Ad_Active = 1 And A.AD_Part_Of_CTC = 1 and AD_Flag = 'I' 
				--				   and isnull(S_Sal_Tran_ID,0) = 0 and SP.Publish_Flag =1         
				--				   group by def_id ,T.Emp_ID) table_Sum_CTC on YSD.def_id = table_Sum_CTC.def_id   and ysd.Emp_Id = table_Sum_CTC.Emp_ID         
				--				   where YSD.def_id = 'L4'   
									
				--					Update #Yearly_Salary 
				--					set Month_8 = Month_8 + Gross_Salary
				--					From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--					Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--					Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'L4'
									
				--				 end	
				--				--	Ended by Rohit on 09102013
								
				--				-- Ankit 28032014 --
				--				Update #Yearly_Salary 
				--				set Month_8 = Ms.Sal_Cal_Days
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year  and SP.Publish_Flag =1
				--				and Def_ID = '52'
				--				-- Ankit 28032014 --
							
				--	end	
				--else if @count = 9
				--	begin

					
				--			Update #Yearly_Salary 
				--			set Month_9 = 1 
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and Def_ID = '51'
						
				--			Update #Yearly_Salary 
				--			set Month_9 = Salary_Amount + isnull(Arear_Basic ,0)
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and Def_ID = 'B1'
								
				--			Update #Yearly_Salary 
				--			set Month_9 = Other_Allow_Amount + isnull(Arear_Basic ,0)	-- Changed By Gadriwala(add field Arear_basic) 26042014
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and Def_ID = 'J2'
								
				--			Update #Yearly_Salary 
				--			set Month_9 = Gross_Salary
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and Def_ID = 'J23'
							
				--			Update #Yearly_Salary 
				--			set Month_9 = Total_Earning_Fraction
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and Def_ID = 'J24'
							
				--			Update #Yearly_Salary 
				--			set Month_9 = Gross_Salary + Total_Earning_Fraction
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and Def_ID = 'J25'
							
				--			Update #Yearly_Salary 
				--			set Month_9 = PT_Amount 
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and Def_ID = 'P11'

				--			Update #Yearly_Salary 
				--			set Month_9 = LWF_Amount 
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and Def_ID = 'P12'


				--			Update #Yearly_Salary 
				--			set Month_9 = Revenue_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and Def_ID = 'P13'

				--			Update #Yearly_Salary		
				--			set Month_9 = Advance_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and Def_ID = 'P14'
								
				--			Update #Yearly_Salary		
				--			set Month_9 = Total_Dedu_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and Def_ID = 'P98'
																													
				--			Update #Yearly_Salary		
				--			set Month_9 = Net_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and Def_ID = 'P99'
								
				--			IF @ROUNDING = 0 AND @Net_Salary_Round <> -1
				--				Begin
				--					Update #Yearly_Salary		
				--					set Month_9 = Net_Amount - Net_Salary_Round_Diff_Amount
				--					From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--					Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--					Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--						and Def_ID = 'P99'
										
				--					Update #Yearly_Salary		
				--					set Month_9 = Net_Salary_Round_Diff_Amount
				--					From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--					Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--					Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--						and Def_ID = 'P100'
										
				--					Update #Yearly_Salary		
				--					set Month_9 = Net_Amount 
				--					From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--					Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--					Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--						and Def_ID = 'P101'
				--				End	
						
				--			--Update #Yearly_Salary 
				--			--set Month_9 = m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0)
				--			--From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on ys.emp_ID = MAD.emp_ID 
				--			--	AND YS.AD_ID = MAD.AD_ID
				--			--Where FOR_DATE =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD where TSMAD.Emp_ID = MAD.Emp_ID and To_date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date) order by tsmad.For_Date desc )
				--			--and isnull(mad.S_Sal_Tran_ID,0) = 0 and MAD.M_AD_NOT_EFFECT_SALARY=0
				--			Update #Yearly_Salary 
				--			set Month_9 = m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0)
				--			From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on ys.emp_ID = MAD.emp_ID 
				--				AND YS.AD_ID = MAD.AD_ID
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(MAD.To_date) = SP.P_Month and Year(MAD.To_date) = SP.P_Year 
				--			Where M_AD_Tran_ID =  (select top 1 M_AD_Tran_ID from T0210_MONTHLY_AD_DETAIL TSMAD where TSMAD.Emp_ID = MAD.Emp_ID and To_date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date) and TSMAD.AD_ID = MAD.AD_ID order by tsmad.M_AD_Tran_ID desc )
				--			and isnull(mad.S_Sal_Tran_ID,0) = 0 and MAD.M_AD_NOT_EFFECT_SALARY=0 and SP.Publish_Flag =1
				--			--Commented and Changed by Sumit for same date entry of TDS in FNF Case problem in BMA Client 25112015					
				--			--- not effect on Salary but amount get in payslip
				--			Update #Yearly_Salary 
				--			set Month_9 = case when  MAD.ReimAmount  > 0 then  MAD.ReimAmount else 0 end + isnull(M_AREAR_AMOUNT ,0)																								
				--			From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on 
				--				YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID  inner join T0050_AD_MASTER AM ON 
				--				 MAD.AD_ID = AM.AD_ID
				--				 Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(MAD.To_date) = SP.P_Month and Year(MAD.To_date) = SP.P_Year 
				--			Where mad.For_Date =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD where TSMAD.Emp_ID = MAD.Emp_ID and To_date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date) and TSMAD.AD_ID = MAD.AD_ID  order by tsmad.For_Date desc )
				--			and isnull(mad.S_Sal_Tran_ID,0) = 0	and MAD.M_AD_NOT_EFFECT_SALARY=1 and SP.Publish_Flag =1
				--			--- not effect on Salary but amount get in payslip
							
				--			Update #Yearly_Salary 
				--			set Month_9 = Settelement_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and  Def_ID = 'J16'
							
				--			-- Added by rohit For leave Encasement amount on 13-dec-2013
				--			Update #Yearly_Salary 
				--			set Month_9 = Leave_Salary_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and  Def_ID = 'J17'
							
				--			--select @Month,@Year
							
				--			--select *,ms.Travel_Amount From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			--Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and def_id='J18'
				--			--return
						
				--			Update #Yearly_Salary 
				--			set Month_9 = isnull(Travel_Amount,0)
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--			and  Def_ID = 'J18'	 --Added by Sumit 24092015
							
				--			-- for OT amount added by Hasmukh on 29032013
				--			Update #Yearly_Salary 
				--			set Month_9 = OT_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and  Def_ID = 'J20'

				--			Update #Yearly_Salary 
				--			set Month_9 = M_WO_OT_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and  Def_ID = 'J21'

				--			Update #Yearly_Salary 
				--			set Month_9 = M_HO_OT_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and  Def_ID = 'J22' 

				--			Update #Yearly_Salary 
				--			set Month_9 = Loan_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and Def_ID = 'P23'

				--			Update #Yearly_Salary 
				--			set Month_9 = Loan_Intrest_Amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and Def_ID = 'P24'

				--			Update #Yearly_Salary 
				--			set Month_9 = Other_dedu_amount
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and Def_ID = 'P25'
							
				--			Update #Yearly_Salary 
				--			set Month_9 = isnull(GatePass_Amount,0)
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and Def_ID = 'P26'
				--			------OT Amount---Hasmukh 29032013
							
				--			Update #Yearly_Salary 
				--			set Month_9 = isnull(Asset_Installment,0)
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--			and Def_ID = 'P27'
							
				--			Update #Yearly_Salary   -- Added by Sumit 24092015
				--			set Month_9 = isnull(Travel_Advance_Amount,0)
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year  
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--			and Def_ID = 'P18'		

				--			Update #Yearly_Salary 
				--			set Month_9 = Claim_pay_amount
				--			From #Yearly_Salary  Ys  inner join 
				--			(SELECT CLAIM_PAYMENT_DATE,ca.claim_ID,cm.Claim_Name,ca.Emp_Id,Claim_pay_Amount From T0210_MONTHLY_CLAIM_PAYMENT CP INNER JOIN  T0120_CLAIM_APPROVAL CA ON CP.CLAIM_APR_ID =CA.CLAIM_APR_iD  
				--				INNER JOIN T0040_CLAIM_MASTER CM ON CA.CLAIM_ID = CM.CLAIM_ID  inner join #Emp_Cons ec on ca.emp_ID =ec.emp_Id 
				--				WHERE CLAIM_PAYMENT_DATE >=@FROM_DATE  AND CLAIM_PAYMENT_dATE <=@TO_DATE ) q on ys.Emp_ID = q.emp_ID
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(CLAIM_PAYMENT_DATE) = SP.P_Month and Year(CLAIM_PAYMENT_DATE) = SP.P_Year 
				--			Where Month(CLAIM_PAYMENT_DATE) = @Month and Year(CLAIM_PAYMENT_DATE) = @Year And Q.Claim_Name collate SQL_Latin1_General_CP1_CI_AS = YS.Lable_Name collate SQL_Latin1_General_CP1_CI_AS and SP.Publish_Flag =1

				--			-- Added by rohit For Add component which Not Effect in salary and Part of Ctc on 09102013
				--			if @with_Ctc = 1
				--			begin 
				--				Update #Yearly_Salary 
				--				set Month_9 = table_Sum_CTC.Sum_CTC
				--				from #Yearly_Salary YSD inner join 
				--				(select Isnull(SUM(M_AD_Amount),0) as Sum_CTC,Def_ID  , T.emp_id          
				--			   From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID             
				--			   inner join T0210_MONTHLY_AD_DETAIL T on ms.sal_tran_id = T.sal_tran_id             
				--			   inner join T0050_AD_MASTER A on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID  
				--			   Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year           
				--			   Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year            
				--			   and Def_ID = 'L4' and isnull(T.M_Ad_Not_Effect_Salary,0) = 1 and Ad_Active = 1 And A.AD_Part_Of_CTC = 1 and AD_Flag = 'I' 
				--			   and isnull(S_Sal_Tran_ID,0) = 0 and SP.Publish_Flag =1           
				--			   group by def_id ,T.Emp_ID) table_Sum_CTC on YSD.def_id = table_Sum_CTC.def_id   and ysd.Emp_Id = table_Sum_CTC.Emp_ID         
				--			   where YSD.def_id = 'L4'   
								
				--				Update #Yearly_Salary 
				--				set Month_9 = Month_9 + Gross_Salary
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and Def_ID = 'L4'
								
				--			 end	
				--			--	Ended by Rohit on 09102013
							
				--			-- Ankit 28032014 --
				--			Update #Yearly_Salary 
				--			set Month_9 = Ms.Sal_Cal_Days
				--			From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--			Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--			Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--			and Def_ID = '52'
				--			-- Ankit 28032014 --
				--	end	
				--else if @count = 10
				--	begin
						
				--				Update #Yearly_Salary 
				--				set Month_10 = 1 
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and Def_ID = '51'
								
				--				Update #Yearly_Salary 
				--				set Month_10 = Salary_Amount + isnull(Arear_Basic ,0)
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'B1'
									
				--				Update #Yearly_Salary 
				--				set Month_10 = Other_Allow_Amount + isnull(Arear_Basic ,0)	-- Changed By Gadriwala(add field Arear_basic) 26042014
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'J2'
																
				--				Update #Yearly_Salary 
				--				set Month_10 = Gross_Salary
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'J23'
								
				--				Update #Yearly_Salary 
				--				set Month_10 = Total_Earning_Fraction
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'J24'
								
				--				Update #Yearly_Salary 
				--				set Month_10 = Gross_Salary + Total_Earning_Fraction
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'J25'
								
				--				Update #Yearly_Salary 
				--				set Month_10 = PT_Amount 
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P11'

				--				Update #Yearly_Salary 
				--				set Month_10 = LWF_Amount 
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P12'


				--				Update #Yearly_Salary 
				--				set Month_10 = Revenue_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P13'

				--				Update #Yearly_Salary		
				--				set Month_10 = Advance_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P14'
									
				--					Update #Yearly_Salary		
				--				set Month_10 = Total_Dedu_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P98'
																														
				--				Update #Yearly_Salary		
				--				set Month_10 = Net_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P99'
									
				--				IF @ROUNDING = 0 AND @Net_Salary_Round <> -1
				--					Begin
				--						Update #Yearly_Salary		
				--						set Month_10 = Net_Amount - Net_Salary_Round_Diff_Amount
				--						From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--						Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--						Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--							and Def_ID = 'P99'
											
				--						Update #Yearly_Salary		
				--						set Month_10 = Net_Salary_Round_Diff_Amount
				--						From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--						Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--						Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--							and Def_ID = 'P100'
											
				--						Update #Yearly_Salary		
				--						set Month_10 = Net_Amount 
				--						From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--						Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--						Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--							and Def_ID = 'P101'
				--					End	
							
				--				--Update #Yearly_Salary 
				--				--set Month_10 = m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0)
				--				--From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on ys.emp_ID = MAD.emp_ID 
				--				--	AND YS.AD_ID = MAD.AD_ID
				--				--Where FOR_DATE =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD where TSMAD.Emp_ID = MAD.Emp_ID and To_date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date) order by tsmad.For_Date desc )
				--				--and isnull(mad.S_Sal_Tran_ID,0) = 0 and MAD.M_AD_NOT_EFFECT_SALARY=0
				--				Update #Yearly_Salary 
				--				set Month_10 = m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0)
				--				From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on ys.emp_ID = MAD.emp_ID 
				--					AND YS.AD_ID = MAD.AD_ID
				--					Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(MAD.For_Date) = SP.P_Month and Year(MAD.For_Date) = SP.P_Year
				--				Where M_AD_Tran_ID =  (select top 1 M_AD_Tran_ID from T0210_MONTHLY_AD_DETAIL TSMAD where TSMAD.Emp_ID = MAD.Emp_ID and To_date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date) and TSMAD.AD_ID = MAD.AD_ID order by tsmad.M_AD_Tran_ID desc )
				--				and isnull(mad.S_Sal_Tran_ID,0) = 0 and MAD.M_AD_NOT_EFFECT_SALARY=0 and SP.Publish_Flag =1
				--				--Commented and Changed by Sumit for same date entry of TDS in FNF Case problem in BMA Client 25112015					
				--				--- not effect on Salary but amount get in payslip
				--				Update #Yearly_Salary 
				--				set Month_10 = case when  MAD.ReimAmount  > 0 then  MAD.ReimAmount else 0 end + isnull(M_AREAR_AMOUNT ,0)																								
				--				From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on 
				--					YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID  inner join T0050_AD_MASTER AM ON 
				--					 MAD.AD_ID = AM.AD_ID
				--					 Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(MAD.For_Date) = SP.P_Month and Year(MAD.For_Date) = SP.P_Year
				--				Where mad.For_Date =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD where TSMAD.Emp_ID = MAD.Emp_ID and To_date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date) and TSMAD.AD_ID = MAD.AD_ID order by tsmad.For_Date desc )
				--				and isnull(mad.S_Sal_Tran_ID,0) = 0	and MAD.M_AD_NOT_EFFECT_SALARY=1 and SP.Publish_Flag =1
				--				--- not effect on Salary but amount get in payslip
								
				--				Update #Yearly_Salary 
				--				set Month_10 = Settelement_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and  Def_ID = 'J16'
								
				--				-- Added by rohit For leave Encasement amount on 13-dec-2013
				--				Update #Yearly_Salary 
				--				set Month_10 = Leave_Salary_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and  Def_ID = 'J17'
								
				--				Update #Yearly_Salary 
				--				set Month_10 = ISNULL(Travel_Amount,0)
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and  Def_ID = 'J18'	 --Added by Sumit 24092015
								
				--				-- for OT amount added by Hasmukh on 29032013
				--				Update #Yearly_Salary 
				--				set Month_10 = OT_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and  Def_ID = 'J20'

				--				Update #Yearly_Salary 
				--				set Month_10 = M_WO_OT_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and  Def_ID = 'J21'

				--				Update #Yearly_Salary 
				--				set Month_10 = M_HO_OT_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and  Def_ID = 'J22'

				--				Update #Yearly_Salary 
				--				set Month_10 = Loan_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P23'

				--				Update #Yearly_Salary 
				--				set Month_10 = Loan_Intrest_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P24'

				--				Update #Yearly_Salary 
				--				set Month_10 = Other_dedu_amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P25'
								
				--				Update #Yearly_Salary 
				--				set Month_10 = isnull(GatePass_Amount,0)
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P26'
				--				------OT Amount---Hasmukh 29032013
								
				--				Update #Yearly_Salary 
				--				set Month_10 = isnull(Asset_Installment,0)
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and Def_ID = 'P27'
								
				--				Update #Yearly_Salary   -- Added by Sumit 24092015
				--				set Month_10 = isnull(Travel_Advance_Amount,0)
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and Def_ID = 'P18'

				--				Update #Yearly_Salary 
				--				set Month_10 = Claim_pay_amount
				--				From #Yearly_Salary  Ys  inner join 
				--				(SELECT CLAIM_PAYMENT_DATE,ca.claim_ID,cm.Claim_Name,ca.Emp_Id,Claim_pay_Amount From T0210_MONTHLY_CLAIM_PAYMENT CP INNER JOIN  T0120_CLAIM_APPROVAL CA ON CP.CLAIM_APR_ID =CA.CLAIM_APR_iD  
				--					INNER JOIN T0040_CLAIM_MASTER CM ON CA.CLAIM_ID = CM.CLAIM_ID  inner join #Emp_Cons ec on ca.emp_ID =ec.emp_Id 
				--					WHERE CLAIM_PAYMENT_DATE >=@FROM_DATE  AND CLAIM_PAYMENT_dATE <=@TO_DATE ) q on ys.Emp_ID = q.emp_ID
				--					Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(CLAIM_PAYMENT_DATE) = SP.P_Month and Year(CLAIM_PAYMENT_DATE) = SP.P_Year
				--				Where Month(CLAIM_PAYMENT_DATE) = @Month and Year(CLAIM_PAYMENT_DATE) = @Year And Q.Claim_Name collate SQL_Latin1_General_CP1_CI_AS = YS.Lable_Name collate SQL_Latin1_General_CP1_CI_AS and SP.Publish_Flag =1
								
				--				-- Added by rohit For Add component which Not Effect in salary and Part of Ctc on 09102013
				--				if @with_Ctc = 1
				--				begin 
				--					Update #Yearly_Salary 
				--					set Month_10 = table_Sum_CTC.Sum_CTC
				--					from #Yearly_Salary YSD inner join 
				--					(select Isnull(SUM(M_AD_Amount),0) as Sum_CTC,Def_ID  , T.emp_id          
				--				   From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID             
				--				   inner join T0210_MONTHLY_AD_DETAIL T on ms.sal_tran_id = T.sal_tran_id             
				--				   inner join T0050_AD_MASTER A on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID 
				--				   Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year           
				--				   Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year            
				--				   and Def_ID = 'L4' and isnull(T.M_Ad_Not_Effect_Salary,0) = 1 and Ad_Active = 1 And A.AD_Part_Of_CTC = 1 and AD_Flag = 'I' 
				--				   and isnull(S_Sal_Tran_ID,0) = 0 and SP.Publish_Flag =1           
				--				   group by def_id ,T.Emp_ID) table_Sum_CTC on YSD.def_id = table_Sum_CTC.def_id   and ysd.Emp_Id = table_Sum_CTC.Emp_ID         
				--				   where YSD.def_id = 'L4'   
									
				--					Update #Yearly_Salary 
				--					set Month_10 = Month_10 + Gross_Salary
				--					From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--					Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--					Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'L4'
									
				--				 end	
				--				--	Ended by Rohit on 09102013
								
				--				-- Ankit 28032014 --
				--				Update #Yearly_Salary 
				--				set Month_10 = Ms.Sal_Cal_Days
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year  and SP.Publish_Flag =1
				--				and Def_ID = '52'
				--				-- Ankit 28032014 --
							
				--	end	
				--else if @count = 11
				--	begin
						
				--				Update #Yearly_Salary 
				--				set Month_11 = 1 
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = '51'	
								
				--				Update #Yearly_Salary 
				--				set Month_11 = Salary_Amount + isnull(Arear_Basic ,0)
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'B1'
									
				--				Update #Yearly_Salary 
				--				set Month_11 = Other_Allow_Amount + isnull(Arear_Basic ,0)	-- Changed By Gadriwala(add field Arear_basic) 26042014
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'J2'
									
				--				Update #Yearly_Salary 
				--				set Month_11 = Gross_Salary
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'J23'
								
				--				Update #Yearly_Salary 
				--				set Month_11 = Total_Earning_Fraction
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'J24'
								
				--				Update #Yearly_Salary 
				--				set Month_11 = Gross_Salary + Total_Earning_Fraction
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'J25'

				--				Update #Yearly_Salary 
				--				set Month_11 = PT_Amount 
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P11'

				--				Update #Yearly_Salary 
				--				set Month_11 = LWF_Amount 
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P12'


				--				Update #Yearly_Salary 
				--				set Month_11 = Revenue_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P13'

				--				Update #Yearly_Salary		
				--				set Month_11 = Advance_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P14'
									
				--					Update #Yearly_Salary		
				--				set Month_11 = Total_Dedu_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P98'
																														
				--				Update #Yearly_Salary		
				--				set Month_11 = Net_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P99'
									
				--				IF @ROUNDING = 0 AND @Net_Salary_Round <> -1
				--					Begin
				--						Update #Yearly_Salary		
				--						set Month_11 = Net_Amount - Net_Salary_Round_Diff_Amount
				--						From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--						Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--						Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--							and Def_ID = 'P99'
											
				--						Update #Yearly_Salary		
				--						set Month_11 = Net_Salary_Round_Diff_Amount
				--						From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--						Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--						Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--							and Def_ID = 'P100'
											
				--						Update #Yearly_Salary		
				--						set Month_11 = Net_Amount 
				--						From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--						Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--						Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--							and Def_ID = 'P101'
				--					End	
							
				--				--Update #Yearly_Salary 
				--				--set Month_11 = m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0)
				--				--From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on ys.emp_ID = MAD.emp_ID 
				--				--	AND YS.AD_ID = MAD.AD_ID
				--				--Where FOR_DATE =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD where TSMAD.Emp_ID = MAD.Emp_ID and To_date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date) order by tsmad.For_Date desc )
				--				--and isnull(mad.S_Sal_Tran_ID,0) = 0 and MAD.M_AD_NOT_EFFECT_SALARY=0
				--				Update #Yearly_Salary 
				--				set Month_11 = m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0)
				--				From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on ys.emp_ID = MAD.emp_ID 
				--					AND YS.AD_ID = MAD.AD_ID
				--					Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(MAD.To_date) = SP.P_Month and Year(MAD.To_date) = SP.P_Year
				--				Where M_AD_Tran_ID =  (select top 1 M_AD_Tran_ID from T0210_MONTHLY_AD_DETAIL TSMAD where TSMAD.Emp_ID = MAD.Emp_ID and To_date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date) and TSMAD.AD_ID = MAD.AD_ID order by tsmad.M_AD_Tran_ID desc )
				--				and isnull(mad.S_Sal_Tran_ID,0) = 0 and MAD.M_AD_NOT_EFFECT_SALARY=0 and SP.Publish_Flag =1
								
				--				--Commented and Changed by Sumit for same date entry of TDS in FNF Case problem in BMA Client 25112015					
								
				--				--- not effect on Salary but amount get in payslip
				--				Update #Yearly_Salary 
				--				set Month_11 =  case when  MAD.ReimAmount  > 0 then  MAD.ReimAmount else 0 end + isnull(M_AREAR_AMOUNT ,0)																								
				--				From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on 
				--					YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID  inner join T0050_AD_MASTER AM ON 
				--					 MAD.AD_ID = AM.AD_ID
				--					 Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(MAD.To_date) = SP.P_Month and Year(MAD.To_date) = SP.P_Year
				--				Where mad.For_Date =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD where TSMAD.Emp_ID = MAD.Emp_ID and To_date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date) and TSMAD.AD_ID = MAD.AD_ID  order by tsmad.For_Date desc )
				--				and isnull(mad.S_Sal_Tran_ID,0) = 0	and MAD.M_AD_NOT_EFFECT_SALARY=1  and SP.Publish_Flag =1
				--				--- not effect on Salary but amount get in payslip
								
								
								
				--				Update #Yearly_Salary 
				--				set Month_11 = Settelement_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and  Def_ID = 'J16'
								
				--				-- Added by rohit For leave Encasement amount on 13-dec-2013
				--				Update #Yearly_Salary 
				--				set Month_11 = Leave_Salary_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and  Def_ID = 'J17'
								
				--				Update #Yearly_Salary 
				--				set Month_11 = ISNULL(Travel_Amount,0)
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and  Def_ID = 'J18'	 --Added by Sumit 24092015
								
														
				--				-- for OT amount added by Hasmukh on 29032013
				--				Update #Yearly_Salary 
				--				set Month_11 = OT_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and  Def_ID = 'J20'

				--				Update #Yearly_Salary 
				--				set Month_11 = M_WO_OT_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and  Def_ID = 'J21'

				--				Update #Yearly_Salary 
				--				set Month_11 = M_HO_OT_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and  Def_ID = 'J22'

				--				Update #Yearly_Salary 
				--				set Month_11 = Loan_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P23'

				--				Update #Yearly_Salary 
				--				set Month_11 = Loan_Intrest_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P24'

				--				Update #Yearly_Salary 
				--				set Month_11 = Other_dedu_amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P25'
								
				--				Update #Yearly_Salary 
				--				set Month_11 = isnull(GatePass_Amount,0)
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P26'
				--				------OT Amount---Hasmukh 29032013
								
				--				Update #Yearly_Salary 
				--				set Month_11 = isnull(Asset_Installment,0)
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and Def_ID = 'P27'

				--				Update #Yearly_Salary   -- Added by Sumit 24092015
				--				set Month_11 = isnull(Travel_Advance_Amount,0)
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year 
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and Def_ID = 'P18'

				--				Update #Yearly_Salary 
				--				set Month_11 = Claim_pay_amount
				--				From #Yearly_Salary  Ys  inner join 
				--				(SELECT CLAIM_PAYMENT_DATE,ca.claim_ID,cm.Claim_Name,ca.Emp_Id,Claim_pay_Amount From T0210_MONTHLY_CLAIM_PAYMENT CP INNER JOIN  T0120_CLAIM_APPROVAL CA ON CP.CLAIM_APR_ID =CA.CLAIM_APR_iD  
				--					INNER JOIN T0040_CLAIM_MASTER CM ON CA.CLAIM_ID = CM.CLAIM_ID  inner join #Emp_Cons ec on ca.emp_ID =ec.emp_Id 
				--					WHERE CLAIM_PAYMENT_DATE >=@FROM_DATE  AND CLAIM_PAYMENT_dATE <=@TO_DATE ) q on ys.Emp_ID = q.emp_ID
				--					Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(CLAIM_PAYMENT_DATE) = SP.P_Month and Year(CLAIM_PAYMENT_DATE) = SP.P_Year
				--				Where Month(CLAIM_PAYMENT_DATE) = @Month and Year(CLAIM_PAYMENT_DATE) = @Year And Q.Claim_Name collate SQL_Latin1_General_CP1_CI_AS = YS.Lable_Name collate SQL_Latin1_General_CP1_CI_AS  and SP.Publish_Flag =1
								
				--				-- Added by rohit For Add component which Not Effect in salary and Part of Ctc on 09102013
				--				if @with_Ctc = 1
				--				begin 
				--					Update #Yearly_Salary 
				--					set Month_11 = table_Sum_CTC.Sum_CTC
				--					from #Yearly_Salary YSD inner join 
				--					(select Isnull(SUM(M_AD_Amount),0) as Sum_CTC,Def_ID  , T.emp_id          
				--				   From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID             
				--				   inner join T0210_MONTHLY_AD_DETAIL T on ms.sal_tran_id = T.sal_tran_id             
				--				   inner join T0050_AD_MASTER A on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID  
				--				   Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year          
				--				   Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year            
				--				   and Def_ID = 'L4' and isnull(T.M_Ad_Not_Effect_Salary,0) = 1 and Ad_Active = 1 And A.AD_Part_Of_CTC = 1 and AD_Flag = 'I' 
				--				   and isnull(S_Sal_Tran_ID,0) = 0 and SP.Publish_Flag =1           
				--				   group by def_id ,T.Emp_ID) table_Sum_CTC on YSD.def_id = table_Sum_CTC.def_id   and ysd.Emp_Id = table_Sum_CTC.Emp_ID         
				--				   where YSD.def_id = 'L4'   
									
				--					Update #Yearly_Salary 
				--					set Month_11 = Month_11 + Gross_Salary
				--					From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--					Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year  
				--					Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'L4'
									
				--				 end	
				--				--	Ended by Rohit on 09102013
								
				--				-- Ankit 28032014 --
				--				Update #Yearly_Salary 
				--				set Month_11 = Ms.Sal_Cal_Days
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year  
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and Def_ID = '52'
				--				-- Ankit 28032014 --
							
				--	end	
				--else if @count = 12
				--	begin
						
				--				Update #Yearly_Salary 
				--				set Month_12 = 1 
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year  
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = '51'
							
				--				Update #Yearly_Salary 
				--				set Month_12 = Salary_Amount + isnull(Arear_Basic ,0)
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year  
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'B1'
								
				--				Update #Yearly_Salary 
				--				set Month_12 = Other_Allow_Amount + isnull(Arear_Basic ,0)	-- Changed By Gadriwala(add field Arear_basic) 26042014
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year  
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'J2'
									
									
				--				-- Changed By Paras 31-12-2012
				--				Update #Yearly_Salary 
				--				set Month_12 = Gross_Salary
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year  
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'J23'
				--				-- End by Paras on 31122012
									
				--					-- Changed By rohit For Gross not Showing on 31122012
				--				Update #Yearly_Salary 
				--				set Month_12 = Gross_Salary
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year  
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and Def_ID = 'J23'
				--				-- End by rohit on 31122012
								
				--				Update #Yearly_Salary 
				--				set Month_12 = Total_Earning_Fraction
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'J24'
								
				--				Update #Yearly_Salary 
				--				set Month_12 = Gross_Salary + Total_Earning_Fraction
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'J25'
								
				--				Update #Yearly_Salary 
				--				set Month_12 = PT_Amount 
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P11'

				--				Update #Yearly_Salary 
				--				set Month_12 = LWF_Amount 
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P12'


				--				Update #Yearly_Salary 
				--				set Month_12 = Revenue_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P13'

				--				Update #Yearly_Salary		
				--				set Month_12 = Advance_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P14'
									
				--				Update #Yearly_Salary		
				--				set Month_12 = Total_Dedu_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P98'
																														
				--				Update #Yearly_Salary		
				--				set Month_12 = Net_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P99'
									
				--				IF @ROUNDING = 0 AND @Net_Salary_Round <> -1
				--					Begin
				--						Update #Yearly_Salary		
				--						set Month_12 = Net_Amount - Net_Salary_Round_Diff_Amount
				--						From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--						Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--						Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--							and Def_ID = 'P99'
											
				--						Update #Yearly_Salary		
				--						set Month_12 = Net_Salary_Round_Diff_Amount
				--						From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--						Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--						Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--							and Def_ID = 'P100'
											
				--						Update #Yearly_Salary		
				--						set Month_12 = Net_Amount 
				--						From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--						Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--						Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--							and Def_ID = 'P101'
				--					End	
							
				--				--Update #Yearly_Salary 
				--				--set Month_12 = m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0)
				--				--From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on ys.emp_ID = MAD.emp_ID 
				--				--	AND YS.AD_ID = MAD.AD_ID
				--				--Where FOR_DATE =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD where TSMAD.Emp_ID = MAD.Emp_ID and To_date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date) order by tsmad.For_Date desc )
				--				--and isnull(mad.S_Sal_Tran_ID,0) = 0  and MAD.M_AD_NOT_EFFECT_SALARY=0
				--				Update #Yearly_Salary 
				--				set Month_12 = m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0)
				--				From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on ys.emp_ID = MAD.emp_ID 
				--					AND YS.AD_ID = MAD.AD_ID
				--					Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(MAD.To_date) = SP.P_Month and Year(MAD.To_date) = SP.P_Year
				--				Where M_AD_Tran_ID =  (select top 1 M_AD_Tran_ID from T0210_MONTHLY_AD_DETAIL TSMAD where TSMAD.Emp_ID = MAD.Emp_ID and To_date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date) and TSMAD.AD_ID = MAD.AD_ID order by tsmad.M_AD_Tran_ID desc )
				--				and isnull(mad.S_Sal_Tran_ID,0) = 0  and MAD.M_AD_NOT_EFFECT_SALARY=0 and SP.Publish_Flag =1
				--				--Commented and Changed by Sumit for same date entry of TDS in FNF Case problem in BMA Client 25112015					
								
				--				--- not effect on Salary but amount get in payslip
				--				Update #Yearly_Salary 
				--				set Month_12 = case when  MAD.ReimAmount  > 0 then  MAD.ReimAmount else 0 end + isnull(M_AREAR_AMOUNT ,0)																								
				--				From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on 
				--					YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID  inner join T0050_AD_MASTER AM ON 
				--					 MAD.AD_ID = AM.AD_ID
				--					 Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(MAD.To_date) = SP.P_Month and Year(MAD.To_date) = SP.P_Year
				--				Where mad.For_Date =  (select top 1 For_Date from T0210_MONTHLY_AD_DETAIL TSMAD where TSMAD.Emp_ID = MAD.Emp_ID and To_date >= @Temp_Date and To_date < dateadd(m,1,@Temp_Date) and TSMAD.AD_ID = MAD.AD_ID order by tsmad.For_Date desc )
				--				and isnull(mad.S_Sal_Tran_ID,0) = 0	and MAD.M_AD_NOT_EFFECT_SALARY=1 and SP.Publish_Flag =1
								
				--				--- not effect on Salary but amount get in payslip
								
				--				Update #Yearly_Salary 
				--				set Month_12 = Settelement_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and  Def_ID = 'J16'

				--				-- Added by rohit For leave Encasement amount on 13-dec-2013
				--				Update #Yearly_Salary 
				--				set Month_12 = Leave_Salary_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and  Def_ID = 'J17'

				--				Update #Yearly_Salary 
				--				set Month_12 = ISNULL(Travel_Amount,0)
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and  Def_ID = 'J18'	 --Added by Sumit 24092015
								
				--				-- for OT amount added by Hasmukh on 29032013
				--				Update #Yearly_Salary 
				--				set Month_12 = OT_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and  Def_ID = 'J20'

				--				Update #Yearly_Salary 
				--				set Month_12 = M_WO_OT_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and  Def_ID = 'J21'

				--				Update #Yearly_Salary 
				--				set Month_12 = M_HO_OT_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and  Def_ID = 'J22'

				--				Update #Yearly_Salary 
				--				set Month_12 = Loan_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P23'

				--				Update #Yearly_Salary 
				--				set Month_12 = Loan_Intrest_Amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P24'

				--				Update #Yearly_Salary 
				--				set Month_12 = Other_dedu_amount
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P25'
								
				--				Update #Yearly_Salary		-- Added by Gadriwala Muslim 09012015
				--				set Month_12 = isnull(GatePass_Amount,0)
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'P26'
				--				------OT Amount---Hasmukh 29032013
								
				--				Update #Yearly_Salary 
				--				set Month_12 = isnull(Asset_Installment,0)
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and Def_ID = 'P27'

				--				Update #Yearly_Salary   -- Added by Sumit 24092015
				--				set Month_12 = isnull(Travel_Advance_Amount,0)
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and Def_ID = 'P18'

				--				Update #Yearly_Salary 
				--				set Month_12 = Claim_pay_amount
				--				From #Yearly_Salary  Ys  inner join 
				--				(SELECT CLAIM_PAYMENT_DATE,ca.claim_ID,cm.Claim_Name,ca.Emp_Id,Claim_pay_Amount From T0210_MONTHLY_CLAIM_PAYMENT CP INNER JOIN  T0120_CLAIM_APPROVAL CA ON CP.CLAIM_APR_ID =CA.CLAIM_APR_iD  
				--					INNER JOIN T0040_CLAIM_MASTER CM ON CA.CLAIM_ID = CM.CLAIM_ID  inner join #Emp_Cons ec on ca.emp_ID =ec.emp_Id 
				--					WHERE CLAIM_PAYMENT_DATE >=@FROM_DATE  AND CLAIM_PAYMENT_dATE <=@TO_DATE ) q on ys.Emp_ID = q.emp_ID
				--					Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(CLAIM_PAYMENT_DATE) = SP.P_Month and Year(CLAIM_PAYMENT_DATE) = SP.P_Year
				--				Where Month(CLAIM_PAYMENT_DATE) = @Month and Year(CLAIM_PAYMENT_DATE) = @Year And Q.Claim_Name collate SQL_Latin1_General_CP1_CI_AS = YS.Lable_Name collate SQL_Latin1_General_CP1_CI_AS and SP.Publish_Flag =1

				--				-- Added by rohit For Add component which Not Effect in salary and Part of Ctc on 09102013
				--				if @with_Ctc = 1
				--				begin 
				--					Update #Yearly_Salary 
				--					set Month_12 = table_Sum_CTC.Sum_CTC
				--					from #Yearly_Salary YSD inner join 
				--					(select Isnull(SUM(M_AD_Amount),0) as Sum_CTC,Def_ID  , T.emp_id          
				--				   From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID             
				--				   inner join T0210_MONTHLY_AD_DETAIL T on ms.sal_tran_id = T.sal_tran_id             
				--				   inner join T0050_AD_MASTER A on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID 
				--				   Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year            
				--				   Where Month(ms.Month_End_Date) = @Month and Year(ms.Month_End_Date) = @Year            
				--				   and Def_ID = 'L4' and isnull(T.M_Ad_Not_Effect_Salary,0) = 1 and Ad_Active = 1 And A.AD_Part_Of_CTC = 1 and AD_Flag = 'I' 
				--				   and isnull(S_Sal_Tran_ID,0) = 0 and SP.Publish_Flag =1          
				--				   group by def_id ,T.Emp_ID) table_Sum_CTC on YSD.def_id = table_Sum_CTC.def_id   and ysd.Emp_Id = table_Sum_CTC.Emp_ID         
				--				   where YSD.def_id = 'L4'   
									
				--					Update #Yearly_Salary 
				--					set Month_12 = Month_12 + Gross_Salary
				--					From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--					Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year  
				--					Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--					and Def_ID = 'L4' 
									
				--				 end	
				--				--	Ended by Rohit on 09102013
								
				--				-- Ankit 28032014 --
				--				Update #Yearly_Salary 
				--				set Month_12 = Ms.Sal_Cal_Days
				--				From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
				--				Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(ms.Month_End_Date) = SP.P_Month and Year(ms.Month_End_Date) = SP.P_Year  
				--				Where Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year and SP.Publish_Flag =1
				--				and Def_ID = '52'
				--				-- Ankit 28032014 --
							
				--	end						
																																			
				set @Temp_Date = dateadd(m,1,@Temp_date)
				set @TempEnd_date = dateadd(m,1,@TempEnd_date)
				set @count = @count + 1  
				set @loopCounter = @loopCounter + 1   --added by Mr.Mehul 17102022 for Bug #16434
			End
	
		UPDATE #Yearly_Salary
		SET TOTAL = MONTH_1 + MONTH_2 + MONTH_3 + MONTH_4 + MONTH_5 +MONTH_6 + MONTH_7 + MONTH_8 + MONTH_9	
					+ MONTH_10 + MONTH_11 + MONTH_12 
		
		
		
		Update #Yearly_Salary
		set group_Def_ID = New_ID
		from #Yearly_Salary y Inner join 
		( select min(row_ID)New_ID ,Lable_NAme from #Yearly_Salary group by lable_name)q on y.Lable_NAme = q.lable_Name

delete #Yearly_Salary Where Isnull(Total,0) = 0

		DECLARE @Query nvarchar(max)    --added jimit 20072015
		DECLARE @GruopBy Varchar(40)
		
		
		
		-- Changed By Ali 22112013 EmpName_Alias
		If @Report_Call = '' or @Report_Call = 'All'
			Begin			
				select Ys.*,Grd_NAme,Dept_Name,Desig_Name,Branch_NAme,Type_NAme,Branch_Address,Comp_name 
					,Cmp_NAme,Cmp_Address,Emp_Code,Alpha_Emp_Code,Emp_First_Name,
					ISNULL(EmpName_Alias_Salary,Emp_Full_Name) as Emp_Full_Name,
					@From_Date P_From_Date , @To_Date P_To_Date, BM.Branch_ID,
					EM.Pan_No,EM.Date_Of_Join ,EM.Date_Of_Birth,EM.Emp_Left_Date --Ankit 28032014
					,VS.Vertical_Name -- added by rohit on 27112014
					Into #tmpSalary
					
				from #Yearly_Salary  Ys inner join 
				( select I.Emp_Id,Grd_ID,Type_ID,Desig_ID,Dept_ID,Branch_ID,Vertical_ID from T0095_Increment I inner join 
							( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment	-- Ankit 06092014 for Same Date Increment
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = @Cmp_ID
							group by emp_ID  ) Qry on
							I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)IQ on
						ys.emp_Id = iq.emp_Id inner join
							T0080_EMP_MASTER EM ON YS.EMP_ID = EM.EMP_ID INNER JOIN 
							T0040_GRADE_MASTER GM ON IQ.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
							T0040_TYPE_MASTER ETM ON IQ.Type_ID = ETM.Type_ID LEFT OUTER JOIN
							T0040_DESIGNATION_MASTER DGM ON IQ.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
							T0040_DEPARTMENT_MASTER DM ON IQ.Dept_Id = DM.Dept_Id Inner join 
							T0030_Branch_Master BM on IQ.Branch_ID = BM.Branch_ID inner join 
							T0010_COMPANY_MASTER cm on ys.cmp_Id = cm.cmp_Id left Join 
							T0040_Vertical_Segment VS on IQ.Vertical_ID = vs.Vertical_ID
						 --WHERE ys.total <> 0	--Zero Net salary employee display in Summary report Employee strenth - RKM client--Ankit 22082015
				--order by ys.Emp_ID ,Row_ID
				WHERE    ISNULL(Ys.AD_ID,0) = (CAse when @AD_ID <> 0 then @AD_ID else ISNULL(Ys.AD_ID,0) END) --added jimit 02032016
				ORDER BY RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500),Row_ID
				
				Select * FROM #tmpSalary
					ORDER BY Case							--- Added by rohit for Order by not Working in yearly salary report - cera
						When IsNumeric(Alpha_Emp_Code) = 1 then 
							Right(Replicate('0',21) + Alpha_Emp_Code , 20) 
						When IsNumeric(Alpha_Emp_Code) = 0 then 
							Left(Alpha_Emp_Code + Replicate('',21), 20)	
						Else 
							Alpha_Emp_Code 
						End,row_id
						
				if @Group_Type = 0 
					SET @GruopBy = 'Grd_NAme'
					ELSE IF @Group_Type = 1
					SET @GruopBy = 'Type_NAme'
					ELSE IF @Group_Type = 2
					SET @GruopBy = 'Dept_Name'
					ELSE IF @Group_Type = 3
					SET @GruopBy = 'Desig_Name'	
					
				SET @Query = 'Select ' + @GruopBy + ', COUNT(Emp_ID) As Total_Employee,(Select Sum(Total)  from #tmpSalary)As Total_Amount
				FROM #tmpSalary
				Group BY ' + @GruopBy + '
				Order By ' + @GruopBy 
				--print @Query
				EXEC(@Query)			
					
					
				
			End
		else If @Report_Call = 'All1'
			Begin
				select  Ys.*,Grd_NAme,Dept_Name,Desig_Name,Branch_NAme,Type_NAme,Branch_Address,Comp_name 
					,Cmp_NAme,Cmp_Address,Emp_Code,Alpha_Emp_Code,Emp_First_Name,
					ISNULL(EmpName_Alias_Salary,Emp_Full_Name) as Emp_Full_Name,
					@From_Date P_From_Date , @To_Date P_To_Date, BM.Branch_ID,
					EM.Pan_No,EM.Date_Of_Join ,EM.Date_Of_Birth,EM.Emp_Left_Date --Ankit 28032014
					,VS.Vertical_Name -- added by rohit on 27112014
					--,DGM.Desig_Dis_No,em.Enroll_No  --added jimit 29/09/2015
					,0 as leave_id  --added by rohit on 30012017
				from #Yearly_Salary  Ys inner join 
				( select I.Emp_Id,Grd_ID,Type_ID,Desig_ID,Dept_ID,Branch_ID,Vertical_ID from T0095_Increment I inner join 
							( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = @Cmp_ID
							group by emp_ID  ) Qry on
							I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)IQ on
						ys.emp_Id = iq.emp_Id inner join
							T0080_EMP_MASTER EM ON YS.EMP_ID = EM.EMP_ID INNER JOIN 
							T0040_GRADE_MASTER GM ON IQ.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
							T0040_TYPE_MASTER ETM ON IQ.Type_ID = ETM.Type_ID LEFT OUTER JOIN
							T0040_DESIGNATION_MASTER DGM ON IQ.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
							T0040_DEPARTMENT_MASTER DM ON IQ.Dept_Id = DM.Dept_Id Inner join 
							T0030_Branch_Master BM on IQ.Branch_ID = BM.Branch_ID inner join 
							T0010_COMPANY_MASTER cm on ys.cmp_Id = cm.cmp_Id left Join 
							T0040_Vertical_Segment VS on IQ.Vertical_ID = vs.Vertical_ID
						 where Lable_Name <> 'Strength'
							And (Month_1 <> 0 or Month_2 <> 0 or Month_3 <> 0 or Month_4 <> 0 or Month_5 <> 0 or Month_6 <> 0 or Month_7 <> 0 or Month_8 <> 0 or Month_9 <> 0
							or Month_10 <> 0 or Month_11 <> 0 or Month_12 <> 0 )
							ANd ISNULL(Ys.AD_ID,0) = (CAse when @AD_ID <> 0 then @AD_ID else ISNULL(Ys.AD_ID,0) END) --added jimit 02032016
				ORDER BY RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500),Row_ID	
				
				
			End
			
		Else
			Begin					
				select  Ys.*,Grd_NAme,Dept_Name,Desig_Name,Branch_NAme,Type_NAme,Branch_Address,Comp_name 
					,Cmp_NAme,Cmp_Address,Emp_Code,Alpha_Emp_Code,Emp_First_Name
					,ISNULL(EmpName_Alias_Salary,Emp_Full_Name) as Emp_Full_Name,
					@From_Date P_From_Date , @To_Date P_To_Date, BM.Branch_ID,
					EM.Pan_No,EM.Date_Of_Join ,EM.Date_Of_Birth,EM.Emp_Left_Date --Ankit 28032014
					,VS.Vertical_Name -- added by rohit on 27112014
					
				from #Yearly_Salary  Ys inner join 
				( select I.Emp_Id,Grd_ID,Type_ID,Desig_ID,Dept_ID,Branch_ID,Vertical_ID from T0095_Increment I inner join 
							( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = @Cmp_ID
							group by emp_ID  ) Qry on
							I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)IQ on
						ys.emp_Id = iq.emp_Id inner join
							T0080_EMP_MASTER EM ON YS.EMP_ID = EM.EMP_ID INNER JOIN 
							T0040_GRADE_MASTER GM ON IQ.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
							T0040_TYPE_MASTER ETM ON IQ.Type_ID = ETM.Type_ID LEFT OUTER JOIN
							T0040_DESIGNATION_MASTER DGM ON IQ.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
							T0040_DEPARTMENT_MASTER DM ON IQ.Dept_Id = DM.Dept_Id Inner join 
							T0030_Branch_Master BM on IQ.Branch_ID = BM.Branch_ID inner join 
							T0010_COMPANY_MASTER cm on ys.cmp_Id = cm.cmp_Id left Join 
							T0040_Vertical_Segment VS on IQ.Vertical_ID = vs.Vertical_ID
				Where Lable_Name = @Report_Call and 
					   ISNULL(Ys.AD_ID,0) = (CAse when @AD_ID <> 0 then @AD_ID else ISNULL(Ys.AD_ID,0) END) --added jimit 02032016
						
				--order by ys.Emp_ID ,Row_ID
				ORDER BY RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500),Row_ID	
			End
					
	RETURN