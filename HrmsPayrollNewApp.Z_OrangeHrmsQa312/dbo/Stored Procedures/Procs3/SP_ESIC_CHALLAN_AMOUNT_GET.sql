




CREATE PROCEDURE [dbo].[SP_ESIC_CHALLAN_AMOUNT_GET]
	@CMP_ID			NUMERIC,
	@FROM_DATE		DATETIME,
	@TO_DATE 		DATETIME,
	--@BRANCH_ID		NUMERIC,
	@Branch_ID		varchar(Max) --  Added by nilesh patel on 06092014
AS
	    SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON 
	
	IF @BRANCH_ID = '' --0
		SET @BRANCH_ID = NULL
	
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
					  from T0040_GENERAL_SETTING WITH (NOLOCK)
					  where cmp_ID = @cmp_ID --and Branch_ID = @Branch_ID    
							and Branch_ID in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(Cast(@Branch_ID AS varchar(1000))  ,ISNULL(Branch_ID,0)),'#'))
					  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) 
										where For_Date <=@From_Date and Branch_ID in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(Cast(@Branch_ID AS varchar(1000))  ,ISNULL(Branch_ID,0)),'#'))
										and Cmp_ID = @Cmp_ID)    
					--select @Sal_St_Date  =Sal_st_Date 
					--  from T0040_GENERAL_SETTING where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
					--  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING 
					--					where For_Date <=@From_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
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
		 else  if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
			begin    
			   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
			   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))
			   set @From_Date = @Sal_St_Date
			   Set @To_Date = @Sal_end_Date   
			End
	
	DECLARE @EMPLOYER_CONT_PER NUMERIC(18,2) 
	
	SET @EMPLOYER_CONT_PER = 0

	--Hardik 11/06/2013 
	DECLARE @ESIC_CHALLAN_Employee TABLE
		(
			CMP_ID				NUMERIC,
			EMP_ID				Numeric,
			BRANCH_ID			NUMERIC,
			SALARY_AMOUNT		NUMERIC,
			EMP_CONT_PER		NUMERIC(18,2),
			EMP_CONT_AMOUNT			NUMERIC
		 )
	
	DECLARE @ESIC_CHALLAN TABLE
		(
			CMP_ID				NUMERIC,
			BRANCH_ID			NUMERIC,
			TOTAL_SUBSCRIBER	NUMERIC,
			TOTAL_WAGES_DUE		NUMERIC,
			EMP_CONT_PER		NUMERIC(18,2),
			EMP_CONT_AMOUNT			NUMERIC,
			EMPLOYER_CONT_PER	NUMERIC(18,2) DEFAULT 0,
			EMPLOYER_CONT_AMOUNT	NUMERIC DEFAULT 0,
			TOTAL_AMOUNT			NUMERIC DEFAULT 0
		 )

	--Hardik 11/06/2013 for Salary Settlement
	DECLARE @ESIC_CHALLAN_Sett TABLE
		(
			CMP_ID				NUMERIC,
			EMP_ID				Numeric,
			BRANCH_ID			NUMERIC,
			SALARY_AMOUNT		NUMERIC,
			EMP_CONT_PER		NUMERIC(18,2),
			EMP_CONT_AMOUNT			NUMERIC
		 )
	
	select TOP 1 @EMPLOYER_CONT_PER =ESIC_EMPLOYER_CONTRIBUTION
	from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID	--and Branch_ID = ISNULL(@Branch_ID,Branch_ID)
		and Branch_ID in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(Cast(@Branch_ID AS varchar(1000))  ,ISNULL(Branch_ID,0)),'#'))
		and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@tO_DATE --and Branch_ID = isnull(@Branch_ID,Branch_ID) 
							and Branch_ID in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(Cast(@Branch_ID AS varchar(1000))  ,ISNULL(Branch_ID,0)),'#')) and Cmp_ID = @Cmp_ID)
		 
		 	
		 	
	if @EMPLOYER_CONT_PER = 0
		set @EMPLOYER_CONT_PER = 4.75

	INSERT INTO @ESIC_CHALLAN_Employee 
	(CMP_ID,EMP_ID,BRANCH_ID,SALARY_AMOUNT,EMP_CONT_PER,EMP_CONT_AMOUNT)
	SELECT MAD.CMP_ID,MAD.Emp_ID, IQ.Branch_ID,
		MAD.M_AD_Calculated_Amount + Isnull(Arear_Calc_Amount,0) + ISNULL(MS.Arear_Basic,0)+isnull(ms.Basic_Salary_Arear_cutoff,0) as M_AD_CALCULATED_AMOUNT,
		M_AD_Actual_Per_Amount, M_AD_Amount + Isnull(MAD.M_AREAR_AMOUNT,0) + Isnull(MAD.M_AREAR_AMOUNT_cutoff,0)   as M_AD_Amount
	FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)  
		INNER JOIN 
			(	select I.Emp_Id,BRANCH_ID from T0095_Increment I WITH (NOLOCK)
				inner join 
					(Select Max(Increment_Id) As Increment_Id, II.Emp_ID From T0095_INCREMENT II WITH (NOLOCK)Inner JOIN
					( 
						select max(Increment_effective_Date) as For_Date , Emp_ID 
						From T0095_Increment WITH (NOLOCK)
						where Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID
						group by emp_ID
					) Qry on II.Emp_ID = Qry.Emp_ID	and II.Increment_effective_Date = Qry.For_Date
					GROUP by II.Emp_ID) Qry1
					
					on I.Emp_ID = Qry1.Emp_ID	and I.Increment_ID = Qry1.Increment_Id
			) IQ ON	MAD.EMP_ID = IQ.EMP_ID  
		INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON MAD.AD_ID = AM.AD_ID 
		INNER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON MAD.Sal_Tran_ID = MS.Sal_Tran_ID 
		LEFT OUTER JOIN
					(
						Select ISNULL(SUM(M_AREAR_AMOUNT),0) + ISNULL(SUM(M_AREAR_AMOUNT_Cutoff),0) as Arear_Calc_Amount,Emp_ID	
						From T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) 
						Where AD_ID in (
											Select AD_ID from T0060_EFFECT_AD_MASTER WITH (NOLOCK)
											where CMP_ID=@Cmp_ID and EFFECT_AD_ID = (
																						SELECT TOP 1 AD_ID From T0050_AD_MASTER WITH (NOLOCK)
																						where CMP_ID=@Cmp_ID and AD_DEF_ID=3
																					 )
										) and(M_AREAR_AMOUNT <> 0 or M_AREAR_AMOUNT_Cutoff <> 0) and For_Date >= @From_Date and For_Date <= @To_Date
						Group by Emp_ID
					) Qry on MAD.Emp_ID = Qry.Emp_ID
		WHERE MAD.CMP_ID = @CMP_ID
		and IQ.BRANCH_ID in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(Cast(@Branch_ID AS varchar(1000))  ,ISNULL(IQ.BRANCH_ID,0)),'#'))
		AND FOR_dATE >=@FROM_dATE AND FOR_dATE <=@TO_DATE AND AD_DEF_ID = 3 And ad_not_effect_salary<>1 and M_AD_AMOUNT > 0 and sal_type <> 1 
	
	--INSERT INTO @ESIC_CHALLAN_Employee 
	--	(CMP_ID,EMP_ID,BRANCH_ID,SALARY_AMOUNT,EMP_CONT_PER,EMP_CONT_AMOUNT)
	--SELECT MAD.CMP_ID,MAD.Emp_ID, @BRANCH_ID, M_AD_CALCULATED_AMOUNT, M_AD_Actual_Per_Amount, M_AD_Amount
	--FROM T0210_MONTHLY_AD_DETAIL MAD  INNER JOIN 
	--	( select I.Emp_Id,BRANCH_ID from T0095_Increment I inner join 
	--				( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment
	--				where Increment_Effective_date <= @To_Date
	--				and Cmp_ID = @Cmp_ID
	--				group by emp_ID) Qry on
	--				I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date ) IQ ON
	--		MAD.EMP_ID = IQ.EMP_ID  INNER JOIN T0050_AD_MASTER AM ON MAD.AD_ID = AM.AD_ID
	
	--WHERE MAD.CMP_ID = @CMP_ID AND IQ.BRANCH_ID = ISNULL(@BRANCH_ID,IQ.BRANCH_ID)
	--	AND FOR_dATE >=@FROM_dATE AND FOR_dATE <=@TO_DATE AND AD_DEF_ID = 3 And ad_not_effect_salary<>1 and M_AD_AMOUNT > 0 and sal_type <> 1


	
	--Hardik 11/06/2013 for Salary Settlement
	INSERT INTO @ESIC_CHALLAN_Sett 
	(CMP_ID,EMP_ID, BRANCH_ID,SALARY_AMOUNT,EMP_CONT_PER,EMP_CONT_AMOUNT)
	SELECT MAD.CMP_ID, MAD.Emp_ID,EC.BRANCH_ID--@BRANCH_ID
		,MAD.M_AD_AMOUNT * 100 /M_AD_Actual_Per_Amount as M_AD_CALCULATED_AMOUNT,M_AD_Actual_Per_Amount,MAD.M_AD_AMOUNT
	FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) INNER JOIN 
		( select I.Emp_Id,BRANCH_ID from T0095_Increment I WITH (NOLOCK) inner join 
					(Select Max(Increment_Id) As Increment_Id, II.Emp_ID From T0095_INCREMENT II WITH (NOLOCK) Inner JOIN
					( 
						select max(Increment_effective_Date) as For_Date , Emp_ID 
						From T0095_Increment WITH (NOLOCK)
						where Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID
						group by emp_ID
					) Qry on II.Emp_ID = Qry.Emp_ID	and II.Increment_effective_Date = Qry.For_Date
					GROUP by II.Emp_ID) Qry1
					
					on I.Emp_ID = Qry1.Emp_ID	and I.Increment_ID = Qry1.Increment_Id) IQ ON
			MAD.EMP_ID = IQ.EMP_ID  INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON MAD.AD_ID = AM.AD_ID Inner Join 
			@ESIC_CHALLAN_Employee EC on MAD.Emp_ID = EC.EMP_ID And MAD.Cmp_ID = EC.CMP_ID
	
	WHERE MAD.CMP_ID = @CMP_ID --AND IQ.BRANCH_ID = ISNULL(@BRANCH_ID,IQ.BRANCH_ID)
		and IQ.BRANCH_ID in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(Cast(@Branch_ID AS varchar(1000))  ,ISNULL(IQ.BRANCH_ID,0)),'#'))
		--AND FOR_dATE >=@FROM_dATE AND FOR_dATE <=@TO_DATE
		And S_Sal_Tran_Id In (Select S_Sal_Tran_ID from T0201_MONTHLY_SALARY_SETT WITH (NOLOCK) Where Cmp_ID = @CMP_ID And S_Eff_Date >=@FROM_DATE AND S_Eff_Date <=@TO_DATE)
		AND AD_DEF_ID = 3 And ad_not_effect_salary<>1 and M_AD_AMOUNT > 0 and sal_type = 1
	
	--Hardik 11/06/2013
	If exists(Select 1 From @ESIC_CHALLAN_Sett)
		Begin
			Update @ESIC_CHALLAN_Employee Set SALARY_AMOUNT = EC.SALARY_AMOUNT + ISNULL(ES.SALARY_AMOUNT,0) ,
				EMP_CONT_AMOUNT = EC.EMP_CONT_AMOUNT + ISNULL(ES.EMP_CONT_AMOUNT,0)
			From @ESIC_CHALLAN_Sett ES Inner Join @ESIC_CHALLAN_Employee EC on ES.EMP_ID = EC.EMP_ID
		End
		
	--INSERT INTO @ESIC_CHALLAN (CMP_ID,BRANCH_ID,TOTAL_SUBSCRIBER,TOTAL_WAGES_DUE,EMP_CONT_PER,EMP_CONT_AMOUNT,EMPLOYER_CONT_AMOUNT,EMPLOYER_CONT_PER)
	--SELECT MAD.CMP_ID ,@BRANCH_ID,COUNT(MAD.EMP_ID),SUM(M_AD_CALCULATED_AMOUNT),MAX(M_AD_Actual_Per_Amount),SUM(MAD.M_AD_AMOUNT),CEILING(SUM(M_AD_CALCULATED_AMOUNT *@EMPLOYER_CONT_PER/100)) ,@EMPLOYER_CONT_PER 
	--FROM T0210_MONTHLY_aD_DETAIL MAD  INNER JOIN 
	--	( select I.Emp_Id,BRANCH_ID from T0095_Increment I inner join 
	--				( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment
	--				where Increment_Effective_date <= @To_Date
	--				and Cmp_ID = @Cmp_ID
	--				group by emp_ID) Qry on
	--				I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date ) IQ ON
	--		MAD.EMP_ID = IQ.EMP_ID  INNER JOIN T0050_AD_MASTER AM ON MAD.AD_ID = AM.AD_ID
	
	--WHERE MAD.CMP_ID = @CMP_ID AND IQ.BRANCH_ID = ISNULL(@BRANCH_ID,IQ.BRANCH_ID)
	--	AND FOR_dATE >=@FROM_dATE AND FOR_dATE <=@TO_DATE AND AD_DEF_ID = 3 And ad_not_effect_salary<>1 and M_AD_AMOUNT > 0 and sal_type <> 1
	--GROUP BY MAD.CMP_ID

	--Hardik 11/06/2013
	INSERT INTO @ESIC_CHALLAN (CMP_ID,BRANCH_ID,TOTAL_SUBSCRIBER,TOTAL_WAGES_DUE,EMP_CONT_PER,EMP_CONT_AMOUNT,EMPLOYER_CONT_AMOUNT,EMPLOYER_CONT_PER)
	SELECT CMP_ID,0,
		COUNT(EMP_ID),SUM(SALARY_AMOUNT),MAX(EMP_CONT_PER),SUM(EC.EMP_CONT_AMOUNT),CEILING(SUM(SALARY_AMOUNT* @EMPLOYER_CONT_PER/100)) ,@EMPLOYER_CONT_PER 
	FROM @ESIC_CHALLAN_Employee EC
	Group by CMP_ID
	
	
	UPDATE @ESIC_CHALLAN
	SET EMPLOYER_CONT_PER = @EMPLOYER_CONT_PER,
		--EMPLOYER_CONT_AMOUNT = ROUND(TOTAL_WAGES_DUE * @EMPLOYER_CONT_PER /100,0),
		--TOTAL_AMOUNT = ROUND(TOTAL_WAGES_DUE * @EMPLOYER_CONT_PER /100,0) + EMP_CONT_AMOUNT
		TOTAL_AMOUNT = EMPLOYER_CONT_AMOUNT + EMP_CONT_AMOUNT
	
	SELECT * FROM @ESIC_CHALLAN 
			
	
	
	RETURN



