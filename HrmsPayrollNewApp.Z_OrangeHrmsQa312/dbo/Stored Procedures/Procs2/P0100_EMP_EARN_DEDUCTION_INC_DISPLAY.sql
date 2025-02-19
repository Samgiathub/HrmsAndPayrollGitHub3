
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0100_EMP_EARN_DEDUCTION_INC_DISPLAY]
	 @AD_TRAN_ID	Numeric OUTPUT
	,@EMP_ID		Numeric
	,@CMP_ID		Numeric
	,@AD_ID			Numeric
	,@INCREMENT_ID	Numeric(18,0)
	,@FOR_DATE		DateTime
	,@E_AD_FLAG		Char(1)
	,@E_AD_MODE		Varchar(10)
	,@E_AD_PERCENTAGE	numeric(18,5) -- Changed by Gadriwala Muslim 19032015
	,@E_AD_AMOUNT		NUMERIC(18, 4) Output
	,@E_AD_MAX_LIMIT	NUMERIC(18, 4)
	,@tran_type			varchar(1)
	,@Basic_New		NUMERIC(18, 4)
    ,@Gross_New		NUMERIC(18, 4)
    ,@CTC_New		NUMERIC(18, 4)
	,@Temp_Amount_arrear		NUMERIC(18, 4)
	,@Temp_Amount_arrear_CTC	NUMERIC(18, 4)
AS
		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

		
		Declare @AD_Calculate_On varchar(20)
		Declare @AD_Other_Amount	NUMERIC(18, 4)
		Declare @Calculated_Amount	NUMERIC(18, 4)
		Declare @AD_DEF_ID			int
		Declare @Emp_Full_PF		int
		Declare @Emp_PT				int
		Declare @Basic_Salary		NUMERIC(18, 4)
		declare @PT_Amount			NUMERIC(18, 4)
		Declare @Branch_ID			NUMERIC(18, 4)
		Declare @AD_Amount as NUMERIC(18, 4)
		Declare @Gross_Salary		NUMERIC(18, 4)
		Declare @CTC				NUMERIC(18, 4)
		Declare @Temp_Amount		NUMERIC(18, 4)
		Declare @ESIC_Limit			NUMERIC(18, 4)
		Declare @Is_Yearly			NUMERIC(18, 4)
		Declare @E_AD_AMOUNT_YEARLY		NUMERIC(18, 4)	
		Declare @PF_Limit NUMERIC(18, 4)
		Declare @Grd_Id as numeric
		
		Set @CTC = 0
		Set @Temp_Amount = 0
		set @ESIC_Limit = 0
		set @Is_Yearly = 0
		set @E_AD_AMOUNT_YEARLY = 0
		Set @PF_Limit = 0
		
		if @E_AD_AMOUNT is null
			set @AD_Other_Amount = 0
			
		set @Emp_Full_PF =0 
		set @PT_Amount =0
		--CHANGE BY NILAY - 25 -JAN-2011--------
		---set @E_AD_AMOUNT=0
		--set @AD_Amount =0
		
		declare @IS_ROUNDING_Allowance int 
		
		SELECT @AD_DEF_ID = AD_DEF_ID ,@AD_Calculate_On = AD_CALCULATE_ON,@AD_Amount =Ad_Amount,--@E_AD_MAX_LIMIT = AD_MAX_LIMIT , 
			@Is_Yearly = Is_Yearly , @IS_ROUNDING_Allowance = is_rounding 
		FROM T0050_AD_MASTER WITH (NOLOCK) WHERE AD_ID =@AD_ID
		
		SELECT  @Branch_ID		= Branch_ID , @Emp_PT =Emp_PT, @Emp_Full_PF = Emp_Full_PF ,@Basic_Salary = isnull(Basic_Salary,0) ,@Calculated_Amount = isnull(Basic_Salary,0) ,
				--@For_Date		= Increment_Effective_Date, 
				@Gross_Salary = Isnull(Gross_Salary,0), @CTC = Isnull(CTC,0),@Grd_Id = Grd_ID
		FROM	T0095_Increment WITH (NOLOCK) WHERE Increment_ID =@Increment_ID
		
		-- Alpesh 20-Jul-2011 Added for Rounding 
		Declare @AD_Rounding  INT	
		set @AD_Rounding = 0	
		SELECT @AD_Rounding = AD_Rounding,@PF_Limit = Isnull(PF_LIMIT,0)
		FROM dbo.T0040_GENERAL_SETTING G WITH (NOLOCK) Left Outer Join T0050_GENERAL_DETAIL GD WITH (NOLOCK) on G.Gen_ID = GD.GEN_ID
		WHERE G.Cmp_ID=@CMP_ID AND Branch_ID=@Branch_ID
		AND For_Date = ( SELECT MAX(For_Date) FROM T0040_GENERAL_SETTING WITH (NOLOCK)
						  WHERE  Branch_ID = @Branch_ID AND Cmp_ID = @Cmp_ID)
						  
		set @AD_Rounding =  isnull(@IS_ROUNDING_Allowance,@AD_Rounding)				  

		Select @E_AD_MAX_LIMIT = isnull(AD_MAX_LIMIT,0) from T0120_GRADEWISE_ALLOWANCE WITH (NOLOCK) where Ad_ID = @AD_ID And Grd_ID = @Grd_Id
			
		set @Basic_Salary = @Basic_New
		set @Gross_Salary = @Gross_New
		set @Calculated_Amount = @Basic_New
		set @CTC = @CTC_New
		
		
		
		IF @AD_Calculate_On = 'Actual Gross' -- Added by Falak on 03-MAY-2011 
			set @Calculated_Amount = @Gross_Salary 
		Else IF @AD_Calculate_On = 'CTC' 
			set @Calculated_Amount = @CTC 
		Else if @AD_Calculate_On = 'Extra OT' -- Added by Jaina 03-09-2016
			set @Calculated_Amount = 0
		Else
			Set @Calculated_Amount = @Basic_Salary 		
		
			
		SELECT @ESIC_Limit = ISNULL(ESIC_Upper_Limit,0)                    
		  FROM dbo.T0040_GENERAL_SETTING g WITH (NOLOCK) INNER JOIN T0050_General_Detail gd WITH (NOLOCK) on g.Gen_ID = Gd.gen_ID                    
		  WHERE g.cmp_ID = @cmp_ID and Branch_ID = @Branch_ID                    
		  AND For_Date = (SELECT MAX(For_Date) FROM dbo.T0040_GENERAL_SETTING WITH (NOLOCK) WHERE For_Date <=@For_Date AND Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)
		  
		
		IF @E_AD_PERCENTAGE >  0
			BEGIN	
				SELECT @AD_Other_Amount = ISNULL(SUM(E_AD_Amount),0) FROM T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) WHERE Increment_ID=@Increment_ID
						AND AD_ID IN (SELECT AD_ID FROM T0060_EFFECT_AD_MASTER WITH (NOLOCK) WHERE Effect_AD_ID =@AD_ID)
				
				-- Need to put this below one insted of above one. so chk this
										
				--SELECT @AD_Other_Amount = ISNULL(SUM(E_AD_Amount),0) FROM T0100_EMP_EARN_DEDUCTION ed
				--inner join T0050_AD_MASTER am on ed.AD_ID=am.AD_ID
				--WHERE Increment_ID=@Increment_ID AND ed.AD_ID IN (SELECT AD_ID FROM T0060_EFFECT_AD_MASTER WHERE Effect_AD_ID =@AD_ID)
				--and am.AD_NOT_EFFECT_SALARY=0 and ed.CMP_ID=@CMP_ID	and ed.EMP_ID=@EMP_ID
				
				SET @Calculated_Amount = @Calculated_Amount + 	@AD_Other_Amount
				
				if @AD_DEF_ID =3 or @AD_DEF_ID = 6 
					BEGIN
						IF @ESIC_Limit <> 0  
							BEGIN
								--IF @Calculated_Amount <= @ESIC_Limit  --Deepal Comment as per chintan done in iconic and TOTO :- 04012022 
								--	BEGIN
										SET @E_AD_Amount = CEILING((@Calculated_Amount * @E_AD_PERCENTAGE / 100)) 
								--	END	
								--Else
								--	Begin
								--		SET @E_AD_Amount = 0 --Deepal Comment as per chintan done in iconic and TOTO :- 04012022 
								--	End						
							END		
						--ELSE
						--	BEGIN
						--		SET @E_AD_AMOUNT = 0 --Deepal Comment as per chintan done in iconic and TOTO :- 04012022 
						--	END
					END
				--Else if @AD_DEF_ID = 5  --For company PF  added by hasmukh 03012012
				--	SET @E_AD_AMOUNT = ROUND(@Calculated_Amount * @E_AD_PERCENTAGE/100,0)	
				--Else if @AD_DEF_ID = 6  --For company ESIC added by hasmukh 03012012
				--	SET @E_AD_Amount = CEILING((@Calculated_Amount * @E_AD_PERCENTAGE / 100))	
				ELSE IF @AD_DEF_ID = 2	or @AD_DEF_ID = 5					
					BEGIN
					
						IF @Emp_Full_PF = 0
							Begin 
								IF @Calculated_Amount > @PF_Limit
									Begin 
										SET @Calculated_Amount = @PF_Limit
										SET @E_AD_AMOUNT = ROUND(@Calculated_Amount * @E_AD_PERCENTAGE/100,0)
									End
								Else
									--Hardik 07/08/2012
									Begin
										SET @E_AD_AMOUNT = ROUND(@Calculated_Amount * @E_AD_PERCENTAGE/100,0)
									End
									
									
							End
						Else
							Begin							
								-- Alpesh 20-Jul-2011 Changed for Rounding 
								--IF @AD_Rounding = 1
								--	SET @E_AD_AMOUNT = ROUND(@Calculated_Amount * @E_AD_PERCENTAGE/100,0)
								--ELSE
								--	SET @E_AD_AMOUNT = @Calculated_Amount * @E_AD_PERCENTAGE/100
								SET @E_AD_AMOUNT = ROUND(@Calculated_Amount * @E_AD_PERCENTAGE/100,0)	
								
							End
					End
				ELSE
					BEGIN			
																						
						--SET @E_AD_AMOUNT = cast((@Calculated_Amount * @E_AD_PERCENTAGE)/100 as NUMERIC(18, 4))
						
						IF @AD_Rounding = 1
							SET @E_AD_AMOUNT = ROUND(@Calculated_Amount * @E_AD_PERCENTAGE/100,0)
						ELSE							
							SET @E_AD_AMOUNT = (@Calculated_Amount * @E_AD_PERCENTAGE)/100 
						
						select @E_AD_AMOUNT,@Calculated_Amount
						
						If @E_AD_AMOUNT > @E_AD_MAX_LIMIT and @E_AD_MAX_LIMIT > 0          ---Add by hasmukh for check max limit for % type allowance 23082011
							set @E_AD_AMOUNT = @E_AD_MAX_LIMIT
							
						if @Is_Yearly = 1 -- added by mitesh on 17042012 for yearly salary input
							Begin
								set @E_AD_AMOUNT_YEARLY = @E_AD_AMOUNT
								IF @AD_Rounding = 1
									begin
										set @E_AD_AMOUNT = ROUND(@E_AD_AMOUNT/12,0)
									end
								else
									begin
										set @E_AD_AMOUNT = @E_AD_AMOUNT/12
									end
							End
						
					END
			END
			IF @AD_Calculate_On ='FIX'
				BEGIN
					--SET @E_AD_AMOUNT =@E_AD_AMOUNT	
					--if @Is_Yearly = 1 -- added by mitesh on 17042012 for yearly salary input
					--	Begin
					--		set @E_AD_AMOUNT_YEARLY = @E_AD_AMOUNT
							IF @AD_Rounding = 1
									begin
										set @E_AD_AMOUNT = ROUND(@E_AD_AMOUNT,0)
									end
								else
									begin
										set @E_AD_AMOUNT = @E_AD_AMOUNT
									end
						--End
				END
			Else If @AD_Calculate_On = 'Slab Wise'   -- Hasmukh for slab wise allowance
				Begin 
					exec CALCULATE_AD_AMOUNT_SLAB_WISE @CMP_ID,@Emp_ID,@AD_ID,@FOR_DATE,@Calculated_Amount output,@E_AD_AMOUNT output
				End
			Else If @AD_Calculate_On = 'Arrears CTC'   -- Hasmukh for Auto SP allowance when calc on CTC  --Changed the Spelling from "Arears" to "Arrears" by Ramiz on 16/11/2016
				Begin
					
					--Select @Temp_Amount = Isnull(SUM(E_AD_AMOUNT),0)FROM T0100_EMP_EARN_DEDUCTION WHERE cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID 
					--		AND INCREMENT_ID = @INCREMENT_ID And E_AD_FLAG = 'I'
							
					Set @E_AD_AMOUNT = @CTC - Isnull((@Basic_Salary + @Temp_Amount_arrear_CTC),0) 
					set @Temp_Amount_arrear_CTC = 0
					
					IF @AD_Rounding = 1
						begin
							set @E_AD_AMOUNT = ROUND(@E_AD_AMOUNT,0)
						end
					else
						begin
							set @E_AD_AMOUNT = @E_AD_AMOUNT
						end
						
				End
			Else If @AD_Calculate_On = 'Arrears'   -- Hasmukh for Auto SP allowance when calc on gross --Changed the Spelling from "Arears" to "Arrears" by Ramiz on 16/11/2016
				Begin
					
					--Select @Temp_Amount = Isnull(SUM(E_AD_AMOUNT),0)FROM T0100_EMP_EARN_DEDUCTION WHERE cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID 
					--		AND INCREMENT_ID = @INCREMENT_ID And E_AD_FLAG = 'I'
					--		AND AD_ID not in (select AD_ID from dbo.T0050_AD_MASTER where Cmp_ID =@Cmp_ID and AD_Not_effect_salary = 1) 
							
					Set @E_AD_AMOUNT = @Gross_Salary - Isnull((@Basic_Salary + @Temp_Amount_arrear),0) 
					Set @Temp_Amount_arrear = 0
					
					IF @AD_Rounding = 1
						begin
							set @E_AD_AMOUNT = ROUND(@E_AD_AMOUNT,0)
						end
					else
						begin
							set @E_AD_AMOUNT = @E_AD_AMOUNT
						end
					
				End
				
	Set @E_AD_AMOUNT = Isnull(@E_AD_AMOUNT,0)
	
		
	RETURN

