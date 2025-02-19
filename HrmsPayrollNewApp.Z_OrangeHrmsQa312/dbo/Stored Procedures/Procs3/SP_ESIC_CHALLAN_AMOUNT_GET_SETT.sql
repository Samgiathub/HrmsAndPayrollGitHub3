




CREATE PROCEDURE [dbo].[SP_ESIC_CHALLAN_AMOUNT_GET_SETT]
	@CMP_ID			NUMERIC,
	@FROM_DATE		DATETIME,
	@TO_DATE 		DATETIME,
	@BRANCH_ID		NUMERIC
AS
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
	
	IF @BRANCH_ID = 0
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
		 else  if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
			begin    
			   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
			   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))
			   set @From_Date = @Sal_St_Date
			   Set @To_Date = @Sal_end_Date   
			End
	
	DECLARE @EMPLOYER_CONT_PER NUMERIC(18,2) 
	
	SET @EMPLOYER_CONT_PER = 0
	
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
	
	select TOP 1 @EMPLOYER_CONT_PER =ESIC_EMPLOYER_CONTRIBUTION
		from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID	and Branch_ID = ISNULL(@Branch_ID,Branch_ID)
		and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@tO_DATE and Branch_ID = isnull(@Branch_ID,Branch_ID) and Cmp_ID = @Cmp_ID)
		 
		 	
	if @EMPLOYER_CONT_PER = 0
		set @EMPLOYER_CONT_PER = 4.75
			
	
	INSERT INTO @ESIC_CHALLAN (CMP_ID,BRANCH_ID,TOTAL_SUBSCRIBER,TOTAL_WAGES_DUE,EMP_CONT_PER,EMP_CONT_AMOUNT,EMPLOYER_CONT_AMOUNT,EMPLOYER_CONT_PER)
	SELECT MAD.CMP_ID ,@BRANCH_ID,COUNT(MAD.EMP_ID),SUM(M_AD_CALCULATED_AMOUNT),MAX(M_AD_Actual_Per_Amount),SUM(MAD.M_AD_AMOUNT),SUM(CEILING(M_AD_CALCULATED_AMOUNT *@EMPLOYER_CONT_PER/100)) ,@EMPLOYER_CONT_PER FROM T0210_MONTHLY_aD_DETAIL MAD WITH (NOLOCK) INNER JOIN 
		( select I.Emp_Id,BRANCH_ID from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date ) IQ ON
			MAD.EMP_ID = IQ.EMP_ID  INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON MAD.AD_ID = AM.AD_ID
	
	WHERE MAD.CMP_ID = @CMP_ID AND IQ.BRANCH_ID = ISNULL(@BRANCH_ID,IQ.BRANCH_ID)
		AND FOR_dATE >=@FROM_dATE AND FOR_dATE <=@TO_DATE AND AD_DEF_ID = 3 And ad_not_effect_salary<>1 and M_AD_AMOUNT > 0 and sal_type = 1
	GROUP BY MAD.CMP_ID
	
	
	UPDATE @ESIC_CHALLAN
	SET EMPLOYER_CONT_PER = @EMPLOYER_CONT_PER,
		--EMPLOYER_CONT_AMOUNT = ROUND(TOTAL_WAGES_DUE * @EMPLOYER_CONT_PER /100,0),
		--TOTAL_AMOUNT = ROUND(TOTAL_WAGES_DUE * @EMPLOYER_CONT_PER /100,0) + EMP_CONT_AMOUNT
		TOTAL_AMOUNT = EMPLOYER_CONT_AMOUNT + EMP_CONT_AMOUNT
	
	SELECT * FROM @ESIC_CHALLAN 
			
	
	
	RETURN




