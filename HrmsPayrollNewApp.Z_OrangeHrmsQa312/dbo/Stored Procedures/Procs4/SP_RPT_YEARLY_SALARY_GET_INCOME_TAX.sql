CREATE PROCEDURE [dbo].[SP_RPT_YEARLY_SALARY_GET_INCOME_TAX]
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
	

			Create table #Tbl_Get_AD
			(
				Emp_ID numeric(18,0),
				Ad_ID numeric(18,0),
				for_date datetime,
				E_Ad_Percentage numeric(18,5),
				M_Ad_Amount numeric(18,2)
				
			)
					
			INSERT into  #Tbl_Get_AD 			
			Exec P_Emp_Revised_Allowance_Get @Cmp_ID,@To_Date,@constraint, @GRD_ID,0 
		 
		

	DECLARE @Fin_Year as varchar(20)

	IF MONTH(@From_Date) > 3 
		BEGIN
			set @Fin_year =  cast(datename(YYYY,@From_Date)as varchar(10)) + '-' + cast(datename(YYYY,@From_Date)+ 1 as varchar(10))
		END
	ELSE
		BEGIN	
			set @Fin_year =  cast(datename(YYYY,@From_Date) - 1 as varchar(10)) + '-' + cast(datename(YYYY,@From_Date) as varchar(10))
		END 

		Declare @Setting_Reim as tinyint
		set @Setting_Reim =0
		select @Setting_Reim = isnull(Setting_Value,0)  from T0040_SETTING where Setting_Name ='Reimbershment Shows in IT Computation' and Cmp_ID= @cmp_id


		
		-- Ankit 17072014 --
		DECLARE @ROUNDING Numeric
		Set @ROUNDING = 2
		Declare @Net_Salary_Round NUMERIC(18,2)
		SET @Net_Salary_Round = 0
		
		If @Branch_ID is null
			Begin 
				select Top 1 @ROUNDING =Ad_Rounding, @Net_Salary_Round = ISNULL(Net_Salary_Round,0)
				  from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
				  and For_Date = ( select max(For_Date) from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Cmp_ID = @Cmp_ID)    
			End
		Else
			Begin
				select @ROUNDING =Ad_Rounding, @Net_Salary_Round = ISNULL(Net_Salary_Round,0)
				  from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
				  and For_Date = ( select max(For_Date) from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
			End
			
		-- Ankit 17072014 --		
 
		Declare @Month numeric 
		Declare @Year numeric  
		if	exists (select * from [tempdb].dbo.sysobjects where name like '#Yearly_Salary' )		
			begin
				drop table #Yearly_Salary 
			end
			
		if exists(SELECT * FROM [tempdb].dbo.sysobjects where name LIKE '#Salary_Publish_Emp')
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
		left join T0250_SALARY_PUBLISH_ESS SPE WITH (NOLOCK) on Ms.Emp_ID=SPE.Emp_ID and month(Ms.Month_End_Date) = SPE.MONTH and YEAR(ms.Month_End_Date) = SPE.Year AND SPE.Sal_Type='Salary'  --Mukti(30062016)added Sal_Type
		Inner Join #Emp_Cons EC on ms.Emp_ID = EC.Emp_ID)  -- Changed by rohit For if Salary Not Publish or Unpublish then its Not Shows in yearly Salary report- on 17122015
		set @Publish_Flag=1
		if @Publish_Flag = 1 --Added by nilesh patel on 27112015 For When Admin show all salary.
			Begin
				update #Salary_Publish_Emp Set Publish_Flag = 1
			End 	
			 
		CREATE table #Yearly_Salary 
			(
				Row_ID			numeric IDENTITY (1,1) not null,
				Cmp_ID			numeric ,
				Emp_Id			numeric(18,0) ,
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
				Salary_Exists   tinyint,
				Default_Def_Id  numeric default 0
			)
	
		Create nonclustered index IX_Yearly_Salary_Emp_ID_Def_ID_AD_ID_Loan_id on #Yearly_Salary (	Emp_ID,AD_ID,Loan_id) INCLUDE (Month_1,Month_2,Month_3,Month_4,Month_5,Month_6,Month_7,Month_8,Month_9,Month_10,Month_11,Month_12)

			insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
			select @Cmp_ID,emp_ID,51,'Salary Exists?' From #Emp_Cons 


			insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
			select @Cmp_ID,emp_ID,'B1','Basic Salary' From #Emp_Cons 
			

			--insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,AD_ID,AD_Level)
			--select DISTINCT @Cmp_ID,EC.emp_ID,'i'+CAST(mad.AD_ID  as varchar(max)),AD_NAME ,MAD.AD_ID,AM.AD_LEVEL From #Emp_Cons EC	INNER JOIN  
			--	T0210_MONTHLY_AD_DETAIL MAD ON EC.EMP_ID = MAD.EMP_ID INNER JOIN T0050_AD_MASTER AM ON MAD.AD_ID = AM.AD_ID
			--  WHERE M_AD_FLAG = 'i' AND  
			--  Cast(CONVERT(varchar(6), MAD.To_date, 112) As Numeric) between  Cast(CONVERT(varchar(6), @FROM_DATE, 112) As Numeric) AND Cast(CONVERT(varchar(6), @TO_DATE, 112) As Numeric)
			--  and AM.AD_NOT_EFFECT_SALARY = 0
			--  Order by AM.AD_LEVEL

			
			insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,AD_ID,AD_Level,Default_Def_Id)
			select DISTINCT @Cmp_ID,EC.emp_ID,'i'+CAST(Isnull(Isnull(IFD.AD_ID,IFD.Rimb_ID),IFD.Default_Def_Id)  as varchar(max)),Field_Name ,Isnull(IFD.AD_ID,IFD.Rimb_ID),Row_ID ,Default_Def_Id
			From #Emp_Cons EC	CROSS JOIN  
				(Select AD_ID,Rimb_ID,Field_Name,Row_ID,Default_Def_Id from T0100_IT_FORM_DESIGN WITH (NOLOCK) 
					where Cmp_ID=@Cmp_Id And Financial_Year=@Fin_year and (not AD_ID is null or not Rimb_ID is null or not Default_Def_Id is NULL) And Row_ID<101
				 ) IFD 
				Left OUTER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON Isnull(IFD.AD_ID,IFD.Rimb_ID) = AM.AD_ID
			Order by Row_ID
			 
		declare @Temp_Date datetime
		declare @TempEnd_Date datetime
		Declare @count numeric 
		
		Declare @Default_Def_Id_Leave_Encash as tinyint  --- As per Income Tax Form Design
		Set @Default_Def_Id_Leave_Encash = 6  --- As per Income Tax Form Design
		
		
		set @Temp_Date = @To_Date --@From_Date 
		set @TempEnd_Date = @To_Date
		--set @TempEnd_Date = dateadd(mm,1,@From_Date )  -1 
		set @count = 12 
		
		Declare @sqlQuery as Varchar(Max)
		Declare @Str_Month as varchar(Max)
		set @sqlQuery = ''
		set @Str_Month = ''

--select i.*,am.AD_NAME from #Tbl_Get_AD i inner join T0050_AD_MASTER am on i.Ad_ID=am.AD_ID
		
		while @Temp_Date >=@From_Date 
			Begin
			
					set @Month =month(@TempEnd_Date)
					set @Year = year(@TempEnd_Date)
				
					set @Str_Month = 'Month_' + CAST(@count as varchar(10))
			
					set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= 1 From #Yearly_Salary  Ys  
									inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
									and month(ms.month_end_date) = ' + cast(@Month as varchar(10))  + ' and Year(ms.month_end_date) =  ' + cast(@Year as varchar(10))  + 
									' and Def_ID = ''51'''

					exec (@sqlQuery)
					
					set @sqlQuery= ''
					
					set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= Isnull(Leave_Salary_Amount,0) From #Yearly_Salary  Ys  
									inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
									and month(ms.month_end_date) = ' + cast(@Month as varchar(10))  + ' and Year(ms.month_end_date) =  ' + cast(@Year as varchar(10))  + 
									' and Default_Def_Id = 6'

					exec (@sqlQuery)
					set @sqlQuery= ''


					set @sqlQuery = 'Update #Yearly_Salary  set Salary_Exists = 1 From #Yearly_Salary  Ys  
									inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID 
									and month(ms.month_end_date) = ' + cast(@Month as varchar(10))  + ' and Year(ms.month_end_date) =  ' + cast(@Year as varchar(10))
									

					exec (@sqlQuery)
					set @sqlQuery= ''					
					
						set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + ' = Round(Salary_Amount + isnull(Arear_Basic ,0) + isnull(Qry.S_Salary_Amount,0) + isnull(Basic_Salary_Arear_cutoff,0),0)
							From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID and Def_ID = ''B1'' and month(ms.month_end_date) = ' + cast(@Month as varchar(10))  + ' and Year(ms.month_end_date) =  ' + cast(@Year as varchar(10))  +
							' Inner JOIN  #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(Month_End_Date) = SP.P_Month and Year(Month_End_Date) = SP.P_Year
							left join
							(   SELECT  ms.Emp_ID,SUM(ms.S_Salary_Amount) AS S_Salary_Amount ,S_Eff_Date
								FROM T0201_MONTHLY_SALARY_SETT ms WITH (NOLOCK) INNER JOIN #Emp_Cons ec ON ms.Emp_ID =ec.emp_ID 
									AND  MONTH(S_Eff_Date) = ' + cast(@Month as varchar(10))  + ' AND YEAR(S_Eff_Date) = ' + cast(@Year as varchar(10))  +'
								GROUP BY ms.Emp_ID,S_Eff_Date
							 ) Qry ON Qry.Emp_ID = Ys.Emp_ID
			 
							Where (SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1) '--Mukti(03022016)or isnull(ms.is_fnf,0)=1
					
					exec (@sqlQuery)
					set @sqlQuery= ''
				
						set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= (m_AD_AMOUNT + isnull(M_AREAR_AMOUNT ,0) + isnull(MS_arear.ms_amount,0) + isnull(M_Arear_Amount_Cutoff,0))
							From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID 
													 inner join t0200_monthly_salary ms on ms.sal_tran_id= MAD.sal_tran_id and ms.emp_ID = MAD.emp_ID   
													 inner join T0050_AD_MASTER AM ON MAD.AD_ID = AM.AD_ID
													 Inner JOIN #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(MAD.To_date) = SP.P_Month and Year(MAD.To_date) = SP.P_Year 
													  left Join
								 (	Select  MAD.AD_ID as AD_ID_arear, Isnull(SUM(M_AD_Amount),0) as ms_amount,MSS.Emp_id as emp_id_arear  From t0210_monthly_ad_detail MAD WITH (NOLOCK) inner join
							T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK) on MAD.S_Sal_Tran_ID=MSS.S_Sal_Tran_ID and mad.emp_id = Mss.emp_id  inner join 
							T0050_AD_MASTER on MAD.Ad_Id = T0050_AD_MASTER.Ad_ID
							and MAD.Cmp_ID = T0050_AD_MASTER.Cmp_Id
						where MAD.Cmp_ID = ' + cast(@Cmp_ID as varchar(10)) + 'and month(MSS.S_Eff_Date) =  ' + Cast(@Month as varchar(3)) + ' and Year(MSS.S_Eff_Date) = '+ Cast(@Year as varchar(4)) + ' 
							and Ad_Active = 1 
							And Sal_Type = 1
						Group By MAD.AD_ID,MSS.Emp_ID) as MS_arear  on MAD.ad_id = MS_arear.AD_ID_arear and  MAD.emp_id = MS_arear.emp_id_arear 
							Where Month(to_Date)= ' + Cast(@Month as varchar(3)) + ' And Year(To_Date) = '+ Cast(@Year as varchar(4)) + ' 
							and isnull(mad.S_Sal_Tran_ID,0) = 0	 and (SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1)'
						
						exec (@sqlQuery)
						set @sqlQuery= ''

						--select emp_id from #Yearly_Salary
						--select @Str_Month

						
						
						--If 
							--BEGIN		
							--	set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= Case When '+ Cast(@Setting_Reim as varchar) +' = 0 or Isnull(AM.Not_display_auto_credit_amount_IT,0) = 1 Then 
							--			 ' +
							--				@Str_Month 
							--			 +'
							--			 Else 
							--				(case when  MAD.ReimAmount  > 0 then  MAD.ReimAmount +  isnull(MS_arear.ms_amount,0) else MAD.m_AD_AMOUNT + isnull(MS_arear.ms_amount,0) end + isnull(M_AREAR_AMOUNT ,0)) 
							--			 End
							--		From #Yearly_Salary  Ys  inner join T0210_MONTHLY_AD_DETAIL MAD on YS.AD_ID = MAD.AD_ID and ys.emp_ID = MAD.emp_ID 
							--				 inner join t0200_monthly_salary ms on ms.sal_tran_id= MAD.sal_tran_id and ms.emp_ID = MAD.emp_ID   
							--				 inner join T0050_AD_MASTER AM ON MAD.AD_ID = AM.AD_ID
							--				 Inner JOIN #Salary_Publish_Emp SP ON SP.Emp_ID = Ys.Emp_Id and Month(MAD.To_date) = SP.P_Month and Year(MAD.To_date) = SP.P_Year
							--				 left Join
							--			 (	Select  MAD.AD_ID as AD_ID_arear, Isnull(SUM(M_AD_Amount),0) as ms_amount,MSS.Emp_id as Emp_id_arear  From t0210_monthly_ad_detail MAD inner join
							--		T0201_MONTHLY_SALARY_SETT MSS on MAD.Sal_Tran_ID=MSS.Sal_Tran_ID and mad.emp_id = Mss.emp_id  inner join 
							--		T0050_AD_MASTER on MAD.Ad_Id = T0050_AD_MASTER.Ad_ID
							--		and MAD.Cmp_ID = T0050_AD_MASTER.Cmp_Id
							--	where MAD.Cmp_ID = ' + cast(@Cmp_ID as varchar(10)) + ' and month(MSS.S_Eff_Date) = ' + Cast(@Month as varchar(3)) + ' and Year(MSS.S_Eff_Date) = '+ Cast(@Year as varchar(4)) + ' 
							--		and isnull(mad.M_AD_NOT_EFFECT_SALARY,0) = 1    and Ad_Active = 1 
							--		And Sal_Type = 1
							--	Group By MAD.AD_ID,MSS.Emp_ID) as MS_arear   on MAD.ad_id = MS_arear.AD_ID_arear and  MAD.emp_id = MS_arear.emp_id_arear  
							--		Where Month(to_Date)= ' + Cast(@Month as varchar(3)) + ' And Year(To_Date) = '+ Cast(@Year as varchar(4)) + ' 	
							--		and isnull(mad.S_Sal_Tran_ID,0) = 0	and ISNULL(AD_NOT_EFFECT_SALARY,0) = 1 AND ISNULL(Allowance_Type,''A'')=''R'' 
							--		and (SP.Publish_Flag = 1 or isnull(ms.is_fnf,0)=1) '
							
							--	exec (@sqlQuery)
							--	set @sqlQuery= ''

							--END
						--select * from #Yearly_Salary

								set @sqlQuery = ' Update #Yearly_Salary Set  ' + @Str_Month + ' = isnull(Amount,0)
								From #Yearly_Salary YS Inner Join
									T0050_AD_MASTER AM On YS.AD_Id = AM.AD_Id Left Outer Join 
									(Select MRD.Emp_ID,RC_Id,isnull(sum(Taxable),0) + isnull(sum(Tax_free_amount),0)As Amount
									From T0210_Monthly_Reim_Detail MRD WITH (NOLOCK) Inner join #Emp_Cons EC On MRD.Emp_Id = EC.Emp_Id 
								where Month(for_Date)= ' + Cast(@Month as varchar(3)) + ' and year(for_Date) = ' + Cast(@Year as varchar(4)) + '
								Group By  MRD.Emp_ID,RC_Id
								Having isnull(sum(Taxable),0) + isnull(sum(Tax_free_amount),0) >0) Qry on YS.AD_ID = Qry.RC_ID and Ys.Emp_Id=Qry.Emp_ID 
								Where ISNULL(Allowance_Type,''A'')=''R'' 
								And ' + Cast(@Setting_Reim as varchar) +' = 0 or Isnull(Not_display_auto_credit_amount_IT,0) = 1'

								exec (@sqlQuery)
								set @sqlQuery= ''

								
						If exists(select DISTINCT Emp_Id,@Month,@Year from #Yearly_Salary where Isnull(Salary_Exists,0)=0)
							BEGIN
								set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + ' = Basic_Salary
												From #Yearly_Salary Ys 
													Inner join #Emp_Cons EC On YS.Emp_Id = EC.Emp_Id
													Inner Join T0095_Increment I on EC.Emp_ID = I.Emp_ID And EC.Increment_Id = I.Increment_Id
												Where Def_ID = ''B1'' And Isnull(Salary_Exists,0)=0 '
							
								exec (@sqlQuery)
								set @sqlQuery= ''
								set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + ' = M_AD_Amount
												From #Yearly_Salary Ys 
													Inner join #Emp_Cons EC On YS.Emp_Id = EC.Emp_Id
													Inner Join #Tbl_Get_AD I on EC.Emp_ID = I.Emp_ID And YS.AD_Id = I.AD_Id
													Inner Join T0050_AD_Master AM On I.Ad_Id = AM.Ad_Id
												Where Isnull(Salary_Exists,0)=0 And ISNULL(Allowance_Type,''A'')=''A'' '

								exec (@sqlQuery)
								set @sqlQuery= ''

								
								If @Setting_Reim =1
									BEGIN									
										set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + ' = M_AD_Amount
														From #Yearly_Salary Ys 
															Inner join #Emp_Cons EC On YS.Emp_Id = EC.Emp_Id
															Inner Join #Tbl_Get_AD I on EC.Emp_ID = I.Emp_ID And YS.AD_Id = I.AD_Id
															Inner Join T0050_AD_Master AM On I.Ad_Id = AM.Ad_Id
														Where Isnull(Salary_Exists,0)=0 And ISNULL(Allowance_Type,''A'')=''R'' And Isnull(AM.Not_display_auto_credit_amount_IT,0) = 0'

										exec (@sqlQuery)
										set @sqlQuery= ''
									END
								
							END
								
				set @Temp_Date = dateadd(m,-1,@Temp_date)
				set @TempEnd_date = dateadd(m,-1,@TempEnd_date)
				set @count = @count - 1  

			End


		UPDATE #Yearly_Salary
		SET TOTAL = Round(MONTH_1 + MONTH_2 + MONTH_3 + MONTH_4 + MONTH_5 +MONTH_6 + MONTH_7 + MONTH_8 + MONTH_9	
					+ MONTH_10 + MONTH_11 + MONTH_12 ,0)
		
		
		
		Update #Yearly_Salary
		set group_Def_ID = New_ID
		from #Yearly_Salary y Inner join 
		( select min(row_ID)New_ID ,Lable_NAme from #Yearly_Salary group by lable_name)q on y.Lable_NAme = q.lable_Name



		delete #Yearly_Salary Where Isnull(Total,0) = 0

		DECLARE @Query nvarchar(max)    --added jimit 20072015
		DECLARE @GruopBy Varchar(40)
		Declare @RowCountax numeric
		Declare @taxcount numeric
		Declare @EmpCountTax numeric
		set @RowCountax = 0
		set @taxcount = 0
		set @EmpCountTax = 0

		--ADDED BY MEHUL 04082022 

		 CREATE table #Emp_Cons_tax 
		 (
			Row_id int IDENTITY(1,1) PRIMARY KEY, 
			Emp_ID numeric(18,0)      
		 ) 

			if @Constraint <> ''
			begin
				Insert Into #Emp_Cons_tax      
				select  cast(data  as numeric) from dbo.Split (@Constraint,'#')    
			end

			select @EmpCountTax = Count(Emp_ID) from #Emp_Cons_tax

			declare @employeeid as varchar(Max),
			@dateofjoin as datetime,
			@Monthtax as numeric,
			@Counttax as numeric

			set @Counttax = 0

			While @RowCountax <= @EmpCountTax
			begin
				if @taxcount >=  @EmpCountTax
				begin
					break
				end
				set @taxcount = @taxcount + 1  

				select @employeeid = emp_id from #Emp_Cons_tax where Row_id = @taxcount

				select @dateofjoin = Date_Of_Join from T0080_EMP_MASTER where Cmp_ID = @Cmp_ID and emp_id = @employeeid
					
					if cast(@dateofjoin as date) >= cast(@From_Date as date) and cast(@dateofjoin as date) <= cast(@To_Date as date)
					begin
						set @Monthtax = Datediff(Month, @from_date, @dateofjoin)
						while @Counttax < @Monthtax
						begin
							set @Counttax = @Counttax + 1
							set @Str_Month = 'Month_' + CAST(@Counttax as varchar(10))
						
							
							set @sqlQuery = 'Update #Yearly_Salary  set ' + @Str_Month + '= 0 where Emp_id = ' + @employeeid
							
							exec (@sqlQuery)
						end
					end
			end

		-- Changed By Ali 22112013 EmpName_Alias
		If @Report_Call = '' or @Report_Call = 'All'
			Begin
				select  Ys.*,Grd_NAme,Dept_Name,Desig_Name,Branch_NAme,Type_NAme,Branch_Address,Comp_name 
					,Cmp_NAme,Cmp_Address,Emp_Code,Alpha_Emp_Code,Emp_First_Name,
					ISNULL(EmpName_Alias_Salary,Emp_Full_Name) as Emp_Full_Name,
					@From_Date P_From_Date , @To_Date P_To_Date, BM.Branch_ID,
					EM.Pan_No,EM.Date_Of_Join ,EM.Date_Of_Birth,EM.Emp_Left_Date --Ankit 28032014
					,VS.Vertical_Name -- added by rohit on 27112014
					Into #tmpSalary
					
				from #Yearly_Salary  Ys inner join 
				( select I.Emp_Id,Grd_ID,Type_ID,Desig_ID,Dept_ID,Branch_ID,Vertical_ID from T0095_Increment I WITH (NOLOCK) inner join 
							( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)	-- Ankit 06092014 for Same Date Increment
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
							T0010_COMPANY_MASTER cm WITH (NOLOCK) on ys.cmp_Id = cm.cmp_Id left Join 
							T0040_Vertical_Segment VS WITH (NOLOCK) on IQ.Vertical_ID = vs.Vertical_ID
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
				from #Yearly_Salary  Ys inner join 
				( select I.Emp_Id,Grd_ID,Type_ID,Desig_ID,Dept_ID,Branch_ID,Vertical_ID from T0095_Increment I WITH (NOLOCK) inner join 
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
							T0010_COMPANY_MASTER cm WITH (NOLOCK) on ys.cmp_Id = cm.cmp_Id left Join 
							T0040_Vertical_Segment VS WITH (NOLOCK) on IQ.Vertical_ID = vs.Vertical_ID
						 where Lable_Name <> 'Strenght'
							And (Month_1 <> 0 or Month_2 <> 0 or Month_3 <> 0 or Month_4 <> 0 or Month_5 <> 0 or Month_6 <> 0 or Month_7 <> 0 or Month_8 <> 0 or Month_9 <> 0
							or Month_10 <> 0 or Month_11 <> 0 or Month_12 <> 0 )
							ANd ISNULL(Ys.AD_ID,0) = (CAse when @AD_ID <> 0 then @AD_ID else ISNULL(Ys.AD_ID,0) END) --added jimit 02032016
				ORDER BY RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500),Row_ID	
				
				
			End
		else If @Report_Call = 'IT'
			Begin
				
				select  Ys.*,Grd_NAme,Dept_Name,Desig_Name,Branch_NAme,Type_NAme,Branch_Address,Comp_name 
					,Cmp_NAme,Cmp_Address,Emp_Code,Alpha_Emp_Code,Emp_First_Name,
					ISNULL(EmpName_Alias_Salary,Emp_Full_Name) as Emp_Full_Name,
					@From_Date P_From_Date , @To_Date P_To_Date, BM.Branch_ID,
					EM.Pan_No,EM.Date_Of_Join ,EM.Date_Of_Birth,EM.Emp_Left_Date --Ankit 28032014
					,VS.Vertical_Name -- added by rohit on 27112014
					--,DGM.Desig_Dis_No,em.Enroll_No  --added jimit 29/09/2015
				into #YS_IT from #Yearly_Salary  Ys inner join 
				( select I.Emp_Id,Grd_ID,Type_ID,Desig_ID,Dept_ID,Branch_ID,Vertical_ID from T0095_Increment I WITH (NOLOCK) inner join 
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
							T0010_COMPANY_MASTER cm WITH (NOLOCK) on ys.cmp_Id = cm.cmp_Id left Join 
							T0040_Vertical_Segment VS WITH (NOLOCK) on IQ.Vertical_ID = vs.Vertical_ID
						 where Lable_Name <> 'Strenght'
							And (Month_1 <> 0 or Month_2 <> 0 or Month_3 <> 0 or Month_4 <> 0 or Month_5 <> 0 or Month_6 <> 0 or Month_7 <> 0 or Month_8 <> 0 or Month_9 <> 0
							or Month_10 <> 0 or Month_11 <> 0 or Month_12 <> 0 )
							ANd ISNULL(Ys.AD_ID,0) = (CAse when @AD_ID <> 0 then @AD_ID else ISNULL(Ys.AD_ID,0) END) --added jimit 02032016
				ORDER BY RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500),Row_ID	

				
				Declare @cols as nvarchar(MAX)
				Declare @cols_Sum as nvarchar(MAX)
				Declare @query1 as varchar(MAX)
				
				select @cols = STUFF((SELECT ',' + QUOTENAME(cast(Lable_Name as varchar(4000)))
											from #YS_IT as a
											--cross apply ( select 'Lable_Name' col, ro so ) c 
											WHERE a.Lable_name <> 'Salary Exists?'
											group by a.Lable_Name,Row_Id
											order by Row_Id	
									FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')

				select @cols_Sum = STUFF((SELECT QUOTENAME(cast(Lable_Name as varchar(4000))) + ',0) + isnull('
											from #YS_IT as a
											WHERE a.Lable_name <> 'Salary Exists?'
											group by a.Lable_Name,Row_Id
											order by Row_Id 
									FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')

				set @cols_Sum = 'isnull([' + @cols_Sum
				set @cols_Sum = LEFT(@cols_Sum,len(@cols_Sum)-9)

				
				SET @query1 = 'select Alpha_Emp_code,Emp_Full_Name,Branch_Name, Dept_Name,Desig_Name,Date_of_Join, '+ @cols +', ' + @cols_Sum + ' As Total into YS_IT
				from (select Alpha_Emp_code,Emp_Full_Name,Branch_Name, Dept_Name,Desig_Name,Date_of_Join,Lable_Name, Total from #YS_IT) 
				as data pivot 
				( sum(Total) 
				for Lable_Name in ('+ @cols +') ) p' 

				exec(@query1)

				select * into #YS_IT_1 from YS_IT
				drop table YS_IT

				select * from #YS_IT_1


			End
		else If @Report_Call = 'RENT FREE'			
			BEGIN
		
		 
				SET @Temp_Date = @To_Date
				set @TempEnd_Date = @To_Date
				SET @count = 12
				SET @sqlQuery = ''
				Set @cols = ''

				WHILE @Temp_Date >=@From_Date
					BEGIN
						set @Str_Month = 'Month_' + CAST(@count as varchar(10))
						set @Month =month(@TempEnd_Date)
						set @Year = year(@TempEnd_Date)

						

						Set @sqlQuery = 'EXEC tempdb.sys.sp_rename ''#Yearly_Salary.' + @Str_Month + ''', ''' + Cast(@Month as varchar) + '-' + Cast(@Year as varchar) + ''', ''COLUMN'''
						Exec(@sqlQuery)

						If @count = 12
							Set @cols = '[' + Cast(@Month as varchar) + '-' + Cast(@Year as varchar) + ']'
						Else
							Set @cols = '[' + Cast(@Month as varchar) + '-' + Cast(@Year as varchar) + ']' + ',' + @cols

						SET @Temp_Date = dateadd(m,-1,@Temp_date)
						SET @count = @count - 1
						set @TempEnd_date = dateadd(m,-1,@TempEnd_date)
					END

				Set @sqlQuery = 'Insert into #Monthly_table
									(Emp_Id,Cmp_Id, Month_Year,Lable_Name, Amount)
								SELECT Emp_Id,Cmp_Id,[Month],Lable_Name, Amount FROM #Yearly_Salary
								Unpivot
								(Amount For [Month] in ( ' + @cols + '))
								As YearlySalary
								Where Row_Id<>1'
				Exec(@sqlQuery)
				
				Update #Monthly_table Set [Month]= SUBSTRING(Month_Year,1,CHARINDEX('-', Month_Year)-1), [Year]=SUBSTRING(Month_Year,CHARINDEX('-', Month_Year)+1,Len(Month_Year))
			END
		Else
			Begin
			  
				select  Ys.*,Grd_NAme,Dept_Name,Desig_Name,Branch_NAme,Type_NAme,Branch_Address,Comp_name 
					,Cmp_NAme,Cmp_Address,Emp_Code,Alpha_Emp_Code,Emp_First_Name
					,ISNULL(EmpName_Alias_Salary,Emp_Full_Name) as Emp_Full_Name,
					@From_Date P_From_Date , @To_Date P_To_Date, BM.Branch_ID,
					EM.Pan_No,EM.Date_Of_Join ,EM.Date_Of_Birth,EM.Emp_Left_Date --Ankit 28032014
					,VS.Vertical_Name -- added by rohit on 27112014
					
				from #Yearly_Salary  Ys inner join 
				( select I.Emp_Id,Grd_ID,Type_ID,Desig_ID,Dept_ID,Branch_ID,Vertical_ID from T0095_Increment I WITH (NOLOCK) inner join 
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
							T0010_COMPANY_MASTER cm WITH (NOLOCK) on ys.cmp_Id = cm.cmp_Id left Join 
							T0040_Vertical_Segment VS WITH (NOLOCK) on IQ.Vertical_ID = vs.Vertical_ID
				Where Lable_Name = @Report_Call and 
					   ISNULL(Ys.AD_ID,0) = (CAse when @AD_ID <> 0 then @AD_ID else ISNULL(Ys.AD_ID,0) END) --added jimit 02032016
						
				--order by ys.Emp_ID ,Row_ID
				ORDER BY RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500),Row_ID	
			End
					
	RETURN
