




---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_FNF_DETAIL_GET]
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
	,@PBranch_ID	varchar(MAX) = '0'
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
		
	If Isnull(@Emp_Id,0) > 0
		BEGIN
			Declare @Join_Date datetime
			Select @Join_Date =  Date_Of_Join from T0080_EMP_MASTER WITH (NOLOCK) where Emp_Id = @Emp_Id
			
			If @Join_Date > @To_Date
				Set @To_Date = @Join_Date	
		END


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
		  if @PBranch_ID <> '0' and isnull(@Branch_ID,0) = 0
		   Begin	
			Insert Into @Emp_Cons

			select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK) --Changed by Hardik 09/09/2014 for Same Date Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	 --Changed by Hardik 09/09/2014 for Same Date Increment
							
			Where Cmp_ID = @Cmp_ID 
			and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
			and Branch_ID in (select cast(isnull(data,0) as numeric) from dbo.Split(@PBranch_ID,'#'))
			--and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
		  end
		 else
		  Begin
		    Insert Into @Emp_Cons

			select I.Emp_Id from T0095_Increment I WITH (NOLOCK)  inner join 
					( select max(Increment_Id) as Increment_Id, Emp_ID from T0095_Increment WITH (NOLOCK) --Changed by Hardik 09/09/2014 for Same Date Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id	 --Changed by Hardik 09/09/2014 for Same Date Increment
							
			Where Cmp_ID = @Cmp_ID 
			and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))			
			and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)
		  end 
			
		end
		
	
	Declare @Sal_St_Date   Datetime    
	Declare @Sal_end_Date   Datetime  
	
	If @Branch_ID is null
		Begin 
			select Top 1 @Sal_St_Date  = Sal_st_Date 
			  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
			  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Cmp_ID = @Cmp_ID)    
		End
	Else
		Begin
			select @Sal_St_Date  =Sal_st_Date 
			  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
			  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
		End
       
	 if isnull(@Sal_St_Date,'') = ''    
		begin    
		   set @From_Date  = @From_Date     
		   set @To_Date = @To_Date    
		end     
	 else if day(@Sal_St_Date) =1 --and month(@Sal_St_Date)=1    
		begin    
		   set @From_Date  = @From_Date     
		   set @To_Date = @To_Date    
		end     
	 else if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1    
		begin    
		   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
		   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))
		   set @From_Date = @Sal_St_Date
		   Set @To_Date = @Sal_end_Date   
		End
			
	CREATE TABLE #Pay_slip 
		(
			Tran_ID					numeric identity(1,1),
			Emp_ID					numeric,
			Cmp_ID					numeric,
			AD_ID					numeric,
			Sal_Tran_ID				numeric,
			AD_Description			varchar(100),
			AD_Amount				numeric(18,2),
			AD_Actual_Amount		numeric(18,2),
			AD_Calculated_Amount	numeric(18,2),
			For_Date				Datetime,
			M_AD_Flag				char(1),
			Loan_Id					numeric,
			Def_ID					numeric,
			M_AREAR_AMOUNT			numeric default 0, -- Added By Ali 10122013
			Paid_month				varchar(50) --Mukti(02082016)
		)	 
	
			
		Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_AREAR_AMOUNT,Paid_month)
		select ms.Emp_ID,Cmp_ID,null,'Basic Salary',Sal_Tran_ID,Salary_amount,Basic_Salary,0,Month_end_Date ,'I',ISNULL(Arear_Basic,0)+ ISNULL(Basic_Salary_Arear_cutoff,0),''
			From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
		--	and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(IS_FNF,0) =1
			and  Month(Month_End_Date) = Month(@To_Date) and YEAR(Month_End_Date) = YEAR(@To_Date) and isnull(IS_FNF,0) =1
			
		---Added Below Conditions for Bonus Different for Finacial Year wise-- Hardik 08/06/2017 -- Requirement by Havmor and Aculife
			Declare @Bonus_Def_Id numeric
			
			
			CREATE TABLE #BONUS_DETAIL
			(
				EMP_ID	numeric,
				AD_ID	numeric,
				FROM_DATE	DATETIME,
				TO_DATE DATETIME,
				F_FROM_DATE DATETIME,
				F_TO_DATE DATETIME,
				S_FROM_DATE DATETIME,
				S_TO_DATE DATETIME,
			)
			
			Set @Bonus_Def_Id = 19
			
			INSERT INTO #BONUS_DETAIL(Emp_ID, AD_ID, FROM_DATE,TO_DATE, F_FROM_DATE,F_TO_DATE,S_FROM_DATE,S_TO_DATE)
			SELECT	EFA.Emp_ID,AM.AD_ID, EFA.From_Date,EFA.To_Date, 
					[dbo].[GET_YEAR_START_DATE](Year(EFA.From_Date),Month(EFA.From_Date),2), [dbo].[GET_YEAR_END_DATE](Year(EFA.From_Date),Month(EFA.From_Date),2),
					[dbo].[GET_YEAR_START_DATE](Year(EFA.To_Date),Month(EFA.To_Date),2), [dbo].[GET_YEAR_END_DATE](Year(EFA.To_Date),Month(EFA.To_Date),2)
			FROM EMP_FNF_ALLOWANCE_DETAILS EFA WITH (NOLOCK) INNER JOIN 
				T0050_AD_MASTER AM WITH (NOLOCK) ON EFA.Ad_ID = AM.AD_ID INNER JOIN
				@Emp_Cons EC On EFA.Emp_ID = EC.Emp_ID
			WHERE AM.AD_DEF_ID = @Bonus_Def_Id AND AM.CMP_ID = @Cmp_Id
		
			DELETE FROM #BONUS_DETAIL WHERE F_FROM_DATE = S_FROM_DATE
		

		Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_AREAR_AMOUNT,Paid_month)
			Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,null,sum(mad.m_AD_Amount),sum(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),mad.For_Date,mad.M_AD_Flag,MAD.M_AREAR_AMOUNT+ MAD.M_AREAR_AMOUNT_Cutoff,
				(('(' + CONVERT(varchar(3), FA.From_Date, 100) + '-' + cast(YEAR(FA.From_Date) as varchar(5))) + ' To ' +
				(CONVERT(varchar(3), FA.To_Date, 100) + '-' + cast(YEAR(FA.To_Date) as varchar(5)))+')')	
				 From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN 
					@EMP_CONS EC ON MAD.EMP_ID = EC.EMP_ID left join 
					EMP_FNF_ALLOWANCE_DETAILS FA WITH (NOLOCK) on FA.emp_id=MAD.emp_id and FA.Ad_ID=MAD.AD_ID  --Mukti(02082016)
					LEFT OUTER JOIN T0050_AD_MASTER ad WITH (NOLOCK) ON ad.AD_ID = MAD.AD_ID 
				WHERE MAD.Cmp_ID = @Cmp_Id and Month(MAD.To_date) = Month(@To_Date) and YEAR(MAD.To_date) = YEAR(@To_Date) --For_date >=@From_Date and For_date <=@To_Date	 
					  and M_AD_NOT_EFFECT_SALARY = 0  and isnull(sal_tran_id,0)<>0		
					  and isnull(Sal_Type,0) = 0 and M_AD_Percentage =0 and MAD.M_AD_Amount<>0 --Added by Deepali 24nov21 to avoid Duplicate
					  and ad.Hide_In_Reports = 0 --Added by Jaina 22-05-2017
					  AND NOT EXISTS(SELECT 1 FROM #BONUS_DETAIL B WHERE MAD.Emp_ID=B.EMP_ID AND MAD.AD_ID=B.AD_ID) --IF BONUS ARE PAID FOR TWO DIFFERENT FINANCIAL YEAR THEN THOSE RECORD SHOULD NOT BE CONSIDERED HERE
				Group by Mad.Emp_ID,mad.AD_ID ,mad.Cmp_ID,mad.For_Date ,mad.M_AD_Flag,Mad.M_AREAR_AMOUNT,Mad.M_AREAR_AMOUNT_Cutoff,FA.From_Date,FA.To_Date
					
			--Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,null,sum(mad.m_AD_Amount),sum(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),mad.For_Date,mad.M_AD_Flag,MAD.M_AREAR_AMOUNT+ MAD.M_AREAR_AMOUNT_Cutoff 
			--	 From T0210_MONTHLY_AD_DETAIL  MAD INNER  JOIN 
			--		@EMP_CONS EC ON MAD.EMP_ID = EC.EMP_ID 
			--	WHERE MAD.Cmp_ID = @Cmp_Id and Month(To_date) = Month(@To_Date) and YEAR(To_date) = YEAR(@To_Date) --For_date >=@From_Date and For_date <=@To_Date	 
			--		  and M_AD_NOT_EFFECT_SALARY = 0  and isnull(sal_tran_id,0)<>0		
			--		  and isnull(Sal_Type,0) = 0 and M_AD_Percentage =0
			--	Group by Mad.Emp_ID,mad.AD_ID ,mad.Cmp_ID,mad.For_Date ,mad.M_AD_Flag,Mad.M_AREAR_AMOUNT,Mad.M_AREAR_AMOUNT_Cutoff

			/*Folloing Query is used to bifercate the Bonus Amount in Seperate Financial Year*/
			Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_AREAR_AMOUNT,Paid_month)
			Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,null,sum(mad.m_AD_Amount),sum(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),@from_date,mad.M_AD_Flag,MAD.M_AREAR_AMOUNT+ MAD.M_AREAR_AMOUNT_Cutoff,
				(('(' + CONVERT(varchar(3), B.F_FROM_DATE, 100) + '-' + cast(YEAR(B.F_FROM_DATE) as varchar(5))) + ' To ' +
				(CONVERT(varchar(3), B.F_TO_DATE, 100) + '-' + cast(YEAR(B.F_TO_DATE) as varchar(5)))+')')	
				 From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN 
					@EMP_CONS EC ON MAD.EMP_ID = EC.EMP_ID left join 
					EMP_FNF_ALLOWANCE_DETAILS FA WITH (NOLOCK) on FA.emp_id=MAD.emp_id and FA.Ad_ID=MAD.AD_ID  --Mukti(02082016)
					INNER JOIN #BONUS_DETAIL B ON MAD.For_Date BETWEEN B.F_FROM_DATE AND B.F_TO_DATE AND B.EMP_ID=MAD.Emp_ID AND B.AD_ID=MAD.AD_ID
				WHERE MAD.Cmp_ID = @Cmp_Id --and Month(MAD.To_date) = Month(@To_Date) and YEAR(MAD.To_date) = YEAR(@To_Date) --For_date >=@From_Date and For_date <=@To_Date	 
					  and M_AD_NOT_EFFECT_SALARY = 1  and isnull(sal_tran_id,0)<>0		
					  and isnull(Sal_Type,0) = 0 and M_AD_Percentage =0 and FOR_FNF=0					  
				Group by Mad.Emp_ID,mad.AD_ID ,mad.Cmp_ID,mad.M_AD_Flag,Mad.M_AREAR_AMOUNT,Mad.M_AREAR_AMOUNT_Cutoff,B.F_FROM_DATE,B.F_TO_DATE
			UNION ALL
			Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,null,sum(mad.m_AD_Amount),sum(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),@from_date,mad.M_AD_Flag,MAD.M_AREAR_AMOUNT+ MAD.M_AREAR_AMOUNT_Cutoff,
				(('(' + CONVERT(varchar(3), B.S_FROM_DATE, 100) + '-' + cast(YEAR(B.S_FROM_DATE) as varchar(5))) + ' To ' +
				(CONVERT(varchar(3), B.S_TO_DATE, 100) + '-' + cast(YEAR(B.S_TO_DATE) as varchar(5)))+')')	
				 From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN 
					@EMP_CONS EC ON MAD.EMP_ID = EC.EMP_ID left join 
					EMP_FNF_ALLOWANCE_DETAILS FA WITH (NOLOCK) on FA.emp_id=MAD.emp_id and FA.Ad_ID=MAD.AD_ID  --Mukti(02082016)
					INNER JOIN #BONUS_DETAIL B ON MAD.For_Date BETWEEN B.S_FROM_DATE AND B.S_TO_DATE AND B.EMP_ID=MAD.Emp_ID AND B.AD_ID=MAD.AD_ID
				WHERE MAD.Cmp_ID = @Cmp_Id --and Month(MAD.To_date) = Month(@To_Date) and YEAR(MAD.To_date) = YEAR(@To_Date) --For_date >=@From_Date and For_date <=@To_Date	 
					  and M_AD_NOT_EFFECT_SALARY = 1  and isnull(sal_tran_id,0)<>0		
					  and isnull(Sal_Type,0) = 0 and M_AD_Percentage =0		  and FOR_FNF=0			  
				Group by Mad.Emp_ID,mad.AD_ID ,mad.Cmp_ID,mad.M_AD_Flag,Mad.M_AREAR_AMOUNT,Mad.M_AREAR_AMOUNT_Cutoff,B.S_FROM_DATE,B.S_TO_DATE
		
		Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_AREAR_AMOUNT,Paid_month)
			Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,null,sum(mad.m_AD_Amount),max(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),mad.For_Date,mad.M_AD_Flag,MAD.M_AREAR_AMOUNT+ MAD.M_AREAR_AMOUNT_Cutoff,
				(('(' + CONVERT(varchar(3), FA.From_Date, 100) + '-' + cast(YEAR(FA.From_Date) as varchar(5))) + ' To ' +
				(CONVERT(varchar(3), FA.To_Date, 100) + '-' + cast(YEAR(FA.To_Date) as varchar(5)))+')')	 
				 From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN 
					@EMP_CONS EC ON MAD.EMP_ID = EC.EMP_ID left join 
					EMP_FNF_ALLOWANCE_DETAILS FA WITH (NOLOCK) on FA.emp_id=MAD.emp_id and FA.Ad_ID=MAD.AD_ID  --Mukti(02082016)
				WHERE MAD.Cmp_ID = @Cmp_Id and  Month(MAD.To_date) = Month(@To_Date) and YEAR(MAD.To_date) = YEAR(@To_Date)   --For_date >=@From_Date and For_date <=@To_Date	 
					  and ((M_AD_NOT_EFFECT_SALARY = 0 and M_AD_Percentage >0))	and isnull(sal_tran_id,0)<>0	
					  and isnull(Sal_Type,0) = 0 
					  AND NOT EXISTS(SELECT 1 FROM #BONUS_DETAIL B WHERE MAD.Emp_ID=B.EMP_ID AND MAD.AD_ID=B.AD_ID) --IF BONUS ARE PAID FOR TWO DIFFERENT FINANCIAL YEAR THEN THOSE RECORD SHOULD NOT BE CONSIDERED HERE
				Group by Mad.Emp_ID,mad.AD_ID ,mad.Cmp_ID,mad.For_Date ,mad.M_AD_Flag,Mad.M_AREAR_AMOUNT,Mad.M_AREAR_AMOUNT_Cutoff,FA.From_Date,FA.To_Date
		
		--		@EMP_CONS EC ON MAD.EMP_ID = EC.EMP_ID left join 
		--		EMP_FNF_ALLOWANCE_DETAILS FA on FA.emp_id=MAD.emp_id and FA.Ad_ID=MAD.AD_ID  --Mukti(02082016)
		--		INNER JOIN #BONUS_DETAIL B ON MAD.For_Date BETWEEN B.F_FROM_DATE AND B.s_TO_DATE AND B.EMP_ID=MAD.Emp_ID AND B.AD_ID=MAD.AD_ID
		--	WHERE MAD.Cmp_ID = @Cmp_Id    --For_date >=@From_Date and For_date <=@To_Date	 					
		--			  --AND M_AD_NOT_EFFECT_SALARY = 0 
		--			  and FA.Ad_ID=8
		--			  and M_AD_Percentage >0
		--			  --and isnull(sal_tran_id,0)<>0	
		--			  --AND isnull(Sal_Type,0) = 0 
		
				  	
		/*Folloing Query is used to bifercate the Bonus Amount in Seperate Financial Year*/
		Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_AREAR_AMOUNT,Paid_month)
		Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,null,sum(mad.m_AD_Amount),sum(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),@From_date,mad.M_AD_Flag,MAD.M_AREAR_AMOUNT+ MAD.M_AREAR_AMOUNT_Cutoff,
			(('(' + CONVERT(varchar(3), B.F_FROM_DATE, 100) + '-' + cast(YEAR(B.F_FROM_DATE) as varchar(5))) + ' To ' +
			(CONVERT(varchar(3), B.F_TO_DATE, 100) + '-' + cast(YEAR(B.F_TO_DATE) as varchar(5)))+')')	
			 From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN 
				@EMP_CONS EC ON MAD.EMP_ID = EC.EMP_ID left join 
				EMP_FNF_ALLOWANCE_DETAILS FA WITH (NOLOCK) on FA.emp_id=MAD.emp_id and FA.Ad_ID=MAD.AD_ID  --Mukti(02082016)
				INNER JOIN #BONUS_DETAIL B ON MAD.For_Date BETWEEN B.F_FROM_DATE AND B.F_TO_DATE AND B.EMP_ID=MAD.Emp_ID AND B.AD_ID=MAD.AD_ID
			WHERE MAD.Cmp_ID = @Cmp_Id --and  Month(MAD.To_date) = Month(@To_Date) and YEAR(MAD.To_date) = YEAR(@To_Date)   --For_date >=@From_Date and For_date <=@To_Date	 
					  AND ((M_AD_NOT_EFFECT_SALARY = 1 and M_AD_Percentage >0 ))	and isnull(sal_tran_id,0)<>0	
					  AND isnull(Sal_Type,0) = 0  And isnull(FOR_FNF,0)=0
			Group by Mad.Emp_ID,mad.AD_ID ,mad.Cmp_ID,mad.M_AD_Flag,Mad.M_AREAR_AMOUNT,Mad.M_AREAR_AMOUNT_Cutoff,B.F_FROM_DATE,B.F_TO_DATE
		UNION ALL
		Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,null,sum(mad.m_AD_Amount),sum(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),@From_date,mad.M_AD_Flag,MAD.M_AREAR_AMOUNT+ MAD.M_AREAR_AMOUNT_Cutoff,
			(('(' + CONVERT(varchar(3), B.S_FROM_DATE, 100) + '-' + cast(YEAR(B.S_FROM_DATE) as varchar(5))) + ' To ' +
			(CONVERT(varchar(3), B.S_TO_DATE, 100) + '-' + cast(YEAR(B.S_TO_DATE) as varchar(5)))+')')	
			 From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN 
				@EMP_CONS EC ON MAD.EMP_ID = EC.EMP_ID left join 
				EMP_FNF_ALLOWANCE_DETAILS FA WITH (NOLOCK) on FA.emp_id=MAD.emp_id and FA.Ad_ID=MAD.AD_ID  --Mukti(02082016)
				INNER JOIN #BONUS_DETAIL B ON MAD.For_Date BETWEEN B.S_FROM_DATE AND B.S_TO_DATE AND B.EMP_ID=MAD.Emp_ID AND B.AD_ID=MAD.AD_ID
			WHERE MAD.Cmp_ID = @Cmp_Id --and  Month(MAD.To_date) = Month(@To_Date) and YEAR(MAD.To_date) = YEAR(@To_Date)   --For_date >=@From_Date and For_date <=@To_Date	 
					  AND ((M_AD_NOT_EFFECT_SALARY = 1 and M_AD_Percentage >0 ))	and isnull(sal_tran_id,0)<>0	
					  AND isnull(Sal_Type,0) = 0 	 And isnull(FOR_FNF,0)=0		  
			Group by Mad.Emp_ID,mad.AD_ID ,mad.Cmp_ID,mad.M_AD_Flag,Mad.M_AREAR_AMOUNT,Mad.M_AREAR_AMOUNT_Cutoff,B.S_FROM_DATE,B.S_TO_DATE
		
		----- Ankit 10082016 [Gift Case : Claim Approved & Same Month FNF then Reim Amount Should Display in Latter] ---------
		
		INSERT INTO #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_AREAR_AMOUNT,Paid_month)
		SELECT mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,NULL,SUM(CASE WHEN MAD.REIMAMOUNT <> 0  THEN MAD.REIMAMOUNT ELSE MAD.M_AD_AMOUNT END),SUM(mad.M_AD_Actual_Per_amount),SUM(mad.M_AD_Calculated_amount),mad.For_Date,mad.M_AD_Flag,MAD.M_AREAR_AMOUNT+ MAD.M_AREAR_AMOUNT_Cutoff , --SUM(CASE WHEN MAD.REIMAMOUNT > 0 COMMENTED BY RAJPUT ON 12032018 QUERY WAS MINUS AMOUNT WAS NOT COME (INDUCTOTHERM CASE WHILE FNF)
				(('(' + CONVERT(varchar(3), FA.From_Date, 100) + '-' + cast(YEAR(FA.From_Date) as varchar(5))) + ' To ' +
				(CONVERT(varchar(3), FA.To_Date, 100) + '-' + cast(YEAR(FA.To_Date) as varchar(5)))+')')
		 FROM T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN 
			@EMP_CONS EC ON MAD.EMP_ID = EC.EMP_ID INNER JOIN 
			T0050_AD_MASTER AS AM WITH (NOLOCK) ON AM.AD_ID = MAD.AD_ID AND AM.CMP_ID = MAD.Cmp_ID left join 
			EMP_FNF_ALLOWANCE_DETAILS FA WITH (NOLOCK) on FA.emp_id=MAD.emp_id and FA.Ad_ID=MAD.AD_ID  --Mukti(02082016)
		WHERE MAD.Cmp_ID = @Cmp_Id AND MONTH(MAD.To_date) = MONTH(@To_Date) AND YEAR(MAD.To_date) = YEAR(@To_Date) 
			  AND ISNULL(sal_tran_id,0) <> 0		
			  AND ISNULL(Sal_Type,0) = 0 AND 
			  (MAD.M_AD_Flag = 'I') AND (AD_NOT_EFFECT_SALARY = 0 OR ISNULL(MAD.ReimShow,0) = 1) -- (MAD.M_AD_Amount <> 0) COMMENTED BY RAJPUT ON 12032018 QUERY WAS REIM. ALLOWANCE AMOUNT NOT COME AT FNF TIME (INDUCTOTHERM CLIENT)
			  and AM.Allowance_Type = 'R'
		GROUP BY Mad.Emp_ID,mad.AD_ID ,mad.Cmp_ID,mad.For_Date ,mad.M_AD_Flag,Mad.M_AREAR_AMOUNT,Mad.M_AREAR_AMOUNT_Cutoff,FA.From_Date,FA.To_Date
	
		----- Ankit ---------
		
		Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
		select ms.Emp_ID,ms.Cmp_ID,null,'Claim Amount',Sal_Tran_ID,Total_claim_Amount,null,Gross_Salary,Month_end_Date ,'I'			
			From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 			
			--and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date 
			and  Month(Month_End_Date) = Month(@To_Date) and YEAR(Month_End_Date) = YEAR(@To_Date) 
		
		Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
		select ms.Emp_ID,Cmp_ID,null,'OT Amount',Sal_Tran_ID,OT_Amount,null,Gross_Salary,Month_end_Date ,'I'		
			From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 			
		--	and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date 
			and  Month(Month_End_Date) = Month(@To_Date) and YEAR(Month_End_Date) = YEAR(@To_Date) 
		
		--Ankit 01072014--
		Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
		select  ms.Emp_ID,Cmp_ID,null,'Week Off Working',Sal_Tran_ID,M_WO_OT_Amount,M_WO_OT_Amount,0,Month_end_Date ,'I'
			From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
			and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(M_WO_OT_Amount,0) >0
	
		Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
		select  ms.Emp_ID,Cmp_ID,null,'Holiday Working',Sal_Tran_ID,M_HO_OT_Amount,M_HO_OT_Amount,0,Month_end_Date ,'I'
			From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
			and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(M_HO_OT_Amount,0) >0
		--Ankit 01072014--
						
			Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
			select  ms.Emp_ID,Cmp_ID,null,'Settlement Amount',Sal_Tran_ID,Settelement_Amount,null,0,Month_end_Date ,'I'
				From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
			--	and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Settelement_Amount,0) >0 
				and  Month(Month_End_Date) = Month(@To_Date) and YEAR(Month_End_Date) = YEAR(@To_Date)  and isnull(Settelement_Amount,0) >0 
				
			Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
			select  ms.Emp_ID,Cmp_ID,null,'Leave Encash Amount',Sal_Tran_ID,Leave_salary_Amount,null,0,Month_end_Date ,'I'
				From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
				--and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Leave_Salary_Amount,0) >0 
				and  Month(Month_End_Date) = Month(@To_Date) and YEAR(Month_End_Date) = YEAR(@To_Date) --and isnull(Leave_Salary_Amount,0) >0 Comment by nilesh for show Advance Leave Encashment Amount
				
		Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
		select ms.Emp_ID,Cmp_ID,null,'Gratuity',Sal_Tran_ID,Gratuity_Amount,Gratuity_Amount,0,Month_end_Date ,'I'			
			From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
			--and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date 
			and  Month(Month_End_Date) = Month(@To_Date) and YEAR(Month_End_Date) = YEAR(@To_Date)
		
		Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
		select ms.Emp_ID,Cmp_ID,null,'Bonus' ,Sal_Tran_ID,Bonus_Amount,Bonus_Amount,0,Month_end_Date ,'I'	
			From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
			--and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date 
			and  Month(Month_End_Date) = Month(@To_Date) and YEAR(Month_End_Date) = YEAR(@To_Date)
			
				---Change by Falak on 23-FEB-2011 added Arreas Amount and uncommented the Incentive 
		--Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
		--select ms.Emp_ID,Cmp_ID,null,'Incentive',Sal_Tran_ID,Incentive_Amount,Incentive_Amount,0,Month_end_Date ,'I'
		--	From T0200_Monthly_Salary  ms Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
		--	and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date
		
		Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
		select ms.Emp_ID,Cmp_ID,null,'Arrears Amount',Sal_Tran_ID,Other_allow_Amount,Other_allow_Amount,0,Month_end_Date ,'I'
			From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
			--and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date
			and  Month(Month_End_Date) = Month(@To_Date) and YEAR(Month_End_Date) = YEAR(@To_Date)
		
		--Added By Mukti(13062017)start	
		Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
		select ms.Emp_ID,Cmp_ID,null,'Uniform Refund Amount',Sal_Tran_ID,ms.Uniform_Refund_Amount,ms.Uniform_Refund_Amount,0,Month_end_Date ,'I'
			From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
			--and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date
			and  Month(Month_End_Date) = Month(@To_Date) and YEAR(Month_End_Date) = YEAR(@To_Date)
		--Added By Mukti(13062017)end
		
		--Added By Nilesh Patel 19062017 -start
		Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
		select ms.Emp_ID,Cmp_ID,null,'Late Deduction Amt',Sal_Tran_ID,isnull(ms.Late_Dedu_Amount,0),ms.Late_Dedu_Amount,0,Month_end_Date ,'D'
			From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
			--and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date
			and  Month(Month_End_Date) = Month(@To_Date) and YEAR(Month_End_Date) = YEAR(@To_Date)
		--Added By Nilesh Patel 19062017 -end
/*
		Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
		select ms.Emp_ID,Cmp_ID,null,'Travelling Settlement',Sal_Tran_ID,Trav_Earn_Amount,Trav_Earn_Amount,0,Month_end_Date ,'I'
			From T0200_Monthly_Salary  ms Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
			and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date 

		Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
		select ms.Emp_ID,Cmp_ID,null,'Customer Responsibility',Sal_Tran_ID,Cust_Res_Earn_Amount,Cust_Res_Earn_Amount,0,Month_end_Date ,'I'
			From T0200_Monthly_Salary  ms Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
			and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date 

		Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
		select ms.Emp_ID,Cmp_ID,null,'Previous Salary',Sal_Tran_ID,Pre_Month_Net_Salary,Pre_Month_Net_Salary,0,Month_end_Date ,'I'
			From T0200_Monthly_Salary  ms Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
			and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date */
			

		Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
		select ms.Emp_ID,Cmp_ID,null,'Advance Amount',Sal_Tran_ID,Advance_Amount,null,Gross_Salary,Month_end_Date ,'D'			
			From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 			
		--	and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date 
		and  Month(Month_End_Date) = Month(@To_Date) and YEAR(Month_End_Date) = YEAR(@To_Date)
		
		Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
		select ms.Emp_ID,Cmp_ID,null,'Loan Amount',Sal_Tran_ID,Loan_Amount,null,Gross_Salary,Month_end_Date ,'D'		
			From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 			
		--	and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date 
		and  Month(Month_End_Date) = Month(@To_Date) and YEAR(Month_End_Date) = YEAR(@To_Date)
		
		--Added by nilesh patel on 24072015 -start
		Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
		select ms.Emp_ID,Cmp_ID,null,'Loan Interest Amount',Sal_Tran_ID,ms.Loan_Intrest_Amount,null,Gross_Salary,Month_end_Date ,'D'
			From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
		--	and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date 
		and  Month(Month_End_Date) = Month(@To_Date) and YEAR(Month_End_Date) = YEAR(@To_Date)
		--Added by nilesh patel on 24072015 -End
		
		Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)			
		select ms.Emp_ID,Cmp_ID,null,'PT Amount',Sal_Tran_ID,PT_Amount,null,Gross_Salary,Month_end_Date ,'D'		
			From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 			
		--	and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date 
		and  Month(Month_End_Date) = Month(@To_Date) and YEAR(Month_End_Date) = YEAR(@To_Date)
		

		Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
		select ms.Emp_ID,Cmp_ID,null,'LWF Amount',Sal_Tran_ID,LWF_Amount,null,Gross_Salary,Month_end_Date ,'D'			
			From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 			
		--	and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date 
		and  Month(Month_End_Date) = Month(@To_Date) and YEAR(Month_End_Date) = YEAR(@To_Date)

		Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
		select ms.Emp_ID,Cmp_ID,null,'Revenue Amount',Sal_Tran_ID,Revenue_Amount,null,Gross_Salary,Month_end_Date ,'D'
			From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 			
		--	and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date 
		and  Month(Month_End_Date) = Month(@To_Date) and YEAR(Month_End_Date) = YEAR(@To_Date)	 
		
			--Added By Gadriwala Muslim 27042015 - Start
			Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
		select ms.Emp_ID,Cmp_ID,null,'Subsidy Recover Amount',Sal_Tran_ID,isnull(FNF_Subsidy_Recover_Amount,0),null,0,Month_end_Date ,'D'
			From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
		and  Month(Month_End_Date) = Month(@To_Date) and YEAR(Month_End_Date) = YEAR(@To_Date)
			--Added By Gadriwala Muslim 27042015 - End
		
		--Added by Gadriwala Muslim 02122016
			Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
		select ms.Emp_ID,Cmp_ID,null,'Training Recover Amount',Sal_Tran_ID,isnull(FNF_Training_Bnd_Rec_Amt,0),null,0,Month_end_Date ,'D'
			From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
		and  Month(Month_End_Date) = Month(@To_Date) and YEAR(Month_End_Date) = YEAR(@To_Date)
		--Added by Gadriwala Muslim 02122016
		
		--Added by Mukti(13062017)start
			Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
		select ms.Emp_ID,Cmp_ID,null,'Uniform Installment Amount',Sal_Tran_ID,isnull(ms.Uniform_Dedu_Amount,0),null,0,Month_end_Date ,'D'
			From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
		and  Month(Month_End_Date) = Month(@To_Date) and YEAR(Month_End_Date) = YEAR(@To_Date)
		--Added by Mukti(13062017)end
		
		--Added by Mukti(13112017)start
			Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
		select ms.Emp_ID,Cmp_ID,null,'Asset Installment',Sal_Tran_ID,isnull(ms.Asset_Installment,0),null,0,Month_end_Date ,'D'
			From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
		and  Month(Month_End_Date) = Month(@To_Date) and YEAR(Month_End_Date) = YEAR(@To_Date)
		--Added by Mukti(12112017)end
		
		--Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
		--select ms.Emp_ID,Cmp_ID,null,'Other Dedu',Sal_Tran_ID,Other_Dedu_Amount,Other_Dedu_Amount,0,Month_end_Date ,'D'
		--	From T0200_Monthly_Salary  ms Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
		--	and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date 
		--ROnakb
			Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
		select ms.Emp_ID,Cmp_ID,null,'FNF',Sal_Tran_ID,isnull(ms.Asset_Installment,0),null,0,Month_end_Date ,'D'
			From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
		and  Month(Month_End_Date) = Month(@To_Date) and YEAR(Month_End_Date) = YEAR(@To_Date)

-----------Hasmukh for Terminate case for payment 06082012-----
		Declare @Is_Terminate Tinyint
		set @Is_Terminate = 0
		
		select @Is_Terminate = isnull(Is_Terminate,0) from T0100_LEFT_EMP LE WITH (NOLOCK) Inner Join @Emp_Cons ec on LE.Emp_ID =ec.emp_ID
		
		If @Is_Terminate = 1
			Begin
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select ms.Emp_ID,ms.Cmp_ID,null,'Shortfall Amount ('+ cast(E.Emp_Notice_Period AS varchar)+ ' Days)',Sal_Tran_ID,Short_Fall_Dedu_Amount,Short_Fall_Dedu_Amount,0,Month_end_Date ,'I'
					From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					inner JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON E.Emp_ID= ec.Emp_ID  --Added by Jaina 29-06-2017 (For Get Notice Period Days)
			--		and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date
					and  Month(Month_End_Date) = Month(@To_Date) and YEAR(Month_End_Date) = YEAR(@To_Date)
			End
		Else
			Begin
			--Add by chetan 080917 for short fall days same 
			Declare @Short_Fall_Days As Numeric(18,2)=0
			SELECT   @Short_Fall_Days = Short_Fall_Days
				 FROM T0200_MONTHLY_SALARY ms WITH (NOLOCK) inner join @Emp_Cons ec on ms.emp_ID =ec.emp_ID 
				 WHERE ms.Cmp_ID = @Cmp_Id	
						and isnull(IS_FNF,0) = 1
						and  Month(Month_End_Date) = Month(@To_Date) and YEAR(Month_End_Date) = YEAR(@To_Date) 
						-------End---------------------
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				--select ms.Emp_ID,ms.Cmp_ID,null,'Shortfall Amount ('+ cast(E.Emp_Notice_Period AS varchar) + ' Days)',Sal_Tran_ID,Short_Fall_Dedu_Amount,Short_Fall_Dedu_Amount,0,Month_end_Date ,'D'
				select ms.Emp_ID,ms.Cmp_ID,null,'Shortfall Amount ('+ cast(@Short_Fall_Days AS varchar) + ' Days)',Sal_Tran_ID,Short_Fall_Dedu_Amount,Short_Fall_Dedu_Amount,0,Month_end_Date ,'D'
					From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					inner JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON E.Emp_ID= ec.Emp_ID  --Added by Jaina 29-06-2017 (For Get Notice Period Days)
				--	and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date 
				and  Month(Month_End_Date) = Month(@To_Date) and YEAR(Month_End_Date) = YEAR(@To_Date)
			End 
	------------------End Hasmukh 06082012 --------------------------------
	
		--Ankit For Hold Month Salary-- 02012014
		Declare @Hold_Months VARCHAR(512)
		
	--	Select @Hold_Months= @Hold_Months + COALESCE(@Hold_Months + ', ', '') + REPLACE(RIGHT(convert(varchar(30),Month_end_Date,106), 8), ' ', '-') 
	--		From T0200_Monthly_Salary  ms Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID And Ms.Salary_Status='Hold'
	--			and MS.Month_End_Date <@From_Date
	--		Group By ms.Emp_ID,Ms.Net_Amount,Ms.Month_End_Date
	--	ORDER BY Ms.Month_End_Date
			

	----Changed By Ramiz on 13/02/2014 , added the Convert in hold month because FNF letter was not Generating  --
	--	Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
	--	select ms.Emp_ID,Cmp_ID,null,'Hold Month' + ' (' + @Hold_Months +')' ,0,isnull(sum(Net_Amount),0),0,isnull(sum(Net_Amount),0),null ,'I'
	--		From T0200_Monthly_Salary  ms Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID And Ms.Salary_Status='Hold'
	--			and MS.Month_End_Date <@From_Date
	--		Group By ms.Emp_ID,Ms.Cmp_ID
		
		
		Select @Hold_Months=  COALESCE(@Hold_Months + ', ', '') + REPLACE(RIGHT(convert(varchar(30),Month_end_Date,106), 8), ' ', '-') 
		from T0200_Hold_Sal_FNF THS WITH (NOLOCK) 
			 inner join t0200_monthly_salary MS WITH (NOLOCK) ON THS.Sal_Tran_ID = MS.Sal_Tran_ID 
			 Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
		where  isnull(ms.Salary_Status,'')='Hold' -- ms.Month_end_Date <@From_Date and
		Group By ms.Emp_ID,Ms.Net_Amount,Ms.Month_End_Date
 		ORDER BY Ms.Month_End_Date
		
		Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
		select ms.Emp_ID,ms.Cmp_ID,null,'Hold Month' + ' (' + @Hold_Months +')' ,0,isnull(sum(Sal_Amount),0),0,isnull(sum(Sal_Amount),0),null ,'I'
		from T0200_Hold_Sal_FNF THS WITH (NOLOCK) inner join t0200_monthly_salary MS WITH (NOLOCK) ON THS.Sal_Tran_ID = MS.Sal_Tran_ID 
		Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
		where isnull(ms.Salary_Status,'')='Hold' --ms.Month_End_Date <@From_Date and
		Group By ms.Emp_ID,Ms.Cmp_ID
	 	
		
		
		--Ankit For Hold Month Salary
	
	
			
---Put By Nikunj  14-March-2011-------------- Before that it was not there for report.

		--Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
		--select ms.Emp_ID,Cmp_ID,null,'Travelling Recovery',Sal_Tran_ID,Trav_rec_Amount,Trav_rec_Amount,0,Month_end_Date ,'D'
		--	From T0200_Monthly_Salary  ms Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
		--	and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date 
			
---Put By Nikunj  14-March-2011--------------
			
		--Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
		--select ms.Emp_ID,Cmp_ID,null,'Mobile Recovery',Sal_Tran_ID,Mobile_Rec_Amount,Mobile_Rec_Amount,0,Month_end_Date ,'D'
		--	From T0200_Monthly_Salary  ms Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
		--	and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date 			

		--Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
		--select ms.Emp_ID,Cmp_ID,null,'Customer Responsibility',Sal_Tran_ID,Cust_Res_Rec_Amount,Cust_Res_Rec_Amount,0,Month_end_Date ,'D'
		--	From T0200_Monthly_Salary  ms Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
		--	and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date 		

		--Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
		--select ms.Emp_ID,Cmp_ID,null,'Uniform Recovery',Sal_Tran_ID,Uniform_Rec_Amount,Uniform_Rec_Amount,0,Month_end_Date ,'D'
		--	From T0200_Monthly_Salary  ms Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
		--	and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date 

		--Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
		--select ms.Emp_ID,Cmp_ID,null,'I Card Recovery',Sal_Tran_ID,I_Card_Rec_Amount,I_Card_Rec_Amount,0,Month_end_Date ,'D'
		--	From T0200_Monthly_Salary  ms Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
		--	and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date 

		--Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
		--select ms.Emp_ID,Cmp_ID,null,'Salary Recovery',Sal_Tran_ID,Excess_Salary_Rec_Amount,Excess_Salary_Rec_Amount,0,Month_end_Date ,'D'
		--	From T0200_Monthly_Salary  ms Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
		--	and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date 

	  -- Added By Ali 18022014 -- Start
	  Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)  
	  select ms.Emp_ID,Cmp_ID,null,'Access Leave Recovery',Sal_Tran_ID,Access_Leave_Recovery,null,Gross_Salary,Month_end_Date ,'D'
	  From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID   
	  and  Month(Month_End_Date) = Month(@To_Date) and YEAR(Month_End_Date) = YEAR(@To_Date) 
	  -- Added By Ali 18022014 -- End
	
	--Added By Mukti(02082016)start
		--	declare @bonus_fromyear varchar(50)
		--	declare @bonus_toyear varchar(50)
		--	declare @bonus varchar(50)
		--	select @bonus_fromyear= (CONVERT(varchar(3), FA.From_Date, 100) + '-' + cast(YEAR(FA.From_Date) as varchar(5))),
		--	@bonus_toyear=(CONVERT(varchar(3), FA.To_Date, 100) + '-' + cast(YEAR(FA.To_Date) as varchar(5))) from EMP_FNF_ALLOWANCE_DETAILS FA Inner Join @Emp_Cons ec on FA.Emp_ID =ec.emp_ID 
		--	where fa.Cmp_Id=@Cmp_Id 
		--	set @bonus='Bonus (' + @bonus_fromyear + ' ' + @bonus_toyear +')'
		--select @bonus_fromyear,@bonus_toyear,@bonus	
	--Added By Mukti(02082016)end		
		
	Select Emp_full_Name,Grd_Name,Comp_Name,Branch_Address,EMP_CODE,Type_Name,
			Dept_Name,Desig_Name,AD_Name + CASE WHEN ISNULL(F.Comments,'') <> '' THEN ' ('+ISNULL(F.Comments,'')+')' ELSE '' END As AD_Name,
			case when MAD.AD_Description='Basic Salary' then 0 else ISNULL(AD_LEVEL,9999) end as  AD_LEVEL--Mukti(13112017)
			,MAD.Tran_ID
			,MAD.Emp_ID
			,MAD.Cmp_ID
			,MAD.AD_ID
			,MAD.Sal_Tran_ID
			,MAD.AD_Description
			,case when MAD.ad_amount = 0 or MAD.ad_amount is null then F.amount else mad.ad_amount end AD_Amount
			,MAD.AD_Actual_Amount
			,MAD.AD_Calculated_Amount
			,MAD.For_Date
			,MAD.M_AD_Flag
			,MAD.Loan_Id
			,MAD.Def_ID
			,MAD.M_AREAR_AMOUNT
			,MAD.Paid_month
			,ADM.Allowance_Type   --added jimit 01072016	
			FROM #Pay_slip  MAD 
			 LEFT OUTER JOIN  T0050_AD_MASTER ADM WITH (NOLOCK) ON MAD.AD_ID = ADM.AD_ID 
			 INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) on MAD.emp_ID = E.emp_ID 
			 INNER  JOIN @EMP_CONS EC ON E.EMP_ID = EC.EMP_ID 
			 INNER JOIN 
						( 
							select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date 
							from T0095_Increment I WITH (NOLOCK) 
							inner join 
								(
									 select max(Increment_Id) as Increment_Id, Emp_ID 
									 from T0095_Increment WITH (NOLOCK) --Changed by Hardik 09/09/2014 for Same Date Increment
									where Increment_Effective_date <= @To_Date
									and Cmp_ID = @Cmp_ID
									group by emp_ID  
								) Qry on I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id	
						 ) I_Q on E.Emp_ID = I_Q.Emp_ID   --Changed by Hardik 09/09/2014 for Same Date Increment
			INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
			LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
			LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
			LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
			Inner join 		T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID 
			left OUTER JOIN	EMP_FOR_FNF_ALLOWANCE F WITH (NOLOCK) ON F.AD_Id = ADM.AD_ID and E.Emp_ID = F.Emp_id AND F.FOR_DATE Between @From_Date And @To_Date --Added by Jaina 27-06-2017 (FOR_DATE ADDED BY RAMIZ ON 25092017)			
			WHERE E.Cmp_ID = @Cmp_Id
			and (case when MAD.ad_amount = 0 or MAD.ad_amount is null then F.amount else mad.ad_amount end) > 0	
			and isnull(M_AREAR_AMOUNT,0) is not null    --Added by Jaina 31-10-2020 -Changed by Deepali 24nov21 to avoid null condition
			Order by ADM.AD_LEVEL
	RETURN 


