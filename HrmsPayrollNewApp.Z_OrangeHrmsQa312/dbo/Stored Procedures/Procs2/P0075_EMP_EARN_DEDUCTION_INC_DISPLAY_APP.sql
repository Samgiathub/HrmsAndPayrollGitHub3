

---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0075_EMP_EARN_DEDUCTION_INC_DISPLAY_APP]
	 @AD_TRAN_ID	int OUTPUT
	,@Emp_Tran_ID		bigint
	,@CMP_ID		int
	,@AD_ID			int
	,@INCREMENT_ID	int
	,@FOR_DATE		DateTime
	,@E_AD_FLAG		Char(1)
	,@E_AD_MODE		Varchar(10)
	,@E_AD_PERCENTAGE	numeric(18,5) 
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
		Declare @Grd_Id as int
		
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
		
		declare @IS_ROUNDING_Allowance int 
		
		SELECT @AD_DEF_ID = AD_DEF_ID ,@AD_Calculate_On = AD_CALCULATE_ON,@AD_Amount =Ad_Amount,
			@Is_Yearly = Is_Yearly , @IS_ROUNDING_Allowance = is_rounding 
		FROM T0050_AD_MASTER WITH (NOLOCK) WHERE AD_ID =@AD_ID
		
		SELECT  @Branch_ID		= Branch_ID , @Emp_PT =Emp_PT, @Emp_Full_PF = Emp_Full_PF ,@Basic_Salary = isnull(Basic_Salary,0) ,@Calculated_Amount = isnull(Basic_Salary,0) ,
				
				@Gross_Salary = Isnull(Gross_Salary,0), @CTC = Isnull(CTC,0),@Grd_Id = Grd_ID
		FROM	T0070_EMP_INCREMENT_APP WITH (NOLOCK) WHERE Increment_ID =@Increment_ID
		
		
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
		
		
		
		IF @AD_Calculate_On = 'Actual Gross'  
			set @Calculated_Amount = @Gross_Salary 
		Else IF @AD_Calculate_On = 'CTC' 
			set @Calculated_Amount = @CTC 
		Else if @AD_Calculate_On = 'Extra OT' 
			set @Calculated_Amount = 0
		Else
			Set @Calculated_Amount = @Basic_Salary 
		
		
		
		SELECT @ESIC_Limit = ISNULL(ESIC_Upper_Limit,0)                    
		  FROM dbo.T0040_GENERAL_SETTING g WITH (NOLOCK)  INNER JOIN T0050_General_Detail gd WITH (NOLOCK) on g.Gen_ID = Gd.gen_ID                    
		  WHERE g.cmp_ID = @cmp_ID and Branch_ID = @Branch_ID                    
		  AND For_Date = (SELECT MAX(For_Date) FROM dbo.T0040_GENERAL_SETTING WITH (NOLOCK) WHERE For_Date <=@For_Date AND Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)
		  
		
		IF @E_AD_PERCENTAGE >  0
			BEGIN	
				SELECT @AD_Other_Amount = ISNULL(SUM(E_AD_Amount),0) FROM T0075_EMP_EARN_DEDUCTION_APP WITH (NOLOCK) WHERE Increment_ID=@Increment_ID
						AND AD_ID IN (SELECT AD_ID FROM T0060_EFFECT_AD_MASTER WITH (NOLOCK) WHERE Effect_AD_ID =@AD_ID)
				
				
				
				SET @Calculated_Amount = @Calculated_Amount + 	@AD_Other_Amount
				 
				if @AD_DEF_ID =3 or @AD_DEF_ID = 6 
					BEGIN
						IF @ESIC_Limit <> 0  
							BEGIN
								IF @Calculated_Amount <= @ESIC_Limit
									BEGIN
										SET @E_AD_Amount = CEILING((@Calculated_Amount * @E_AD_PERCENTAGE / 100)) 
									END	
								Else
									Begin
										SET @E_AD_Amount = 0
									End						
							END		
						ELSE
							BEGIN
								SET @E_AD_AMOUNT = 0 
							END
					END
					
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
									
									Begin
										SET @E_AD_AMOUNT = ROUND(@Calculated_Amount * @E_AD_PERCENTAGE/100,0)
									End
									
									
							End
						Else
							Begin							
								
								SET @E_AD_AMOUNT = ROUND(@Calculated_Amount * @E_AD_PERCENTAGE/100,0)	
								
							End
					End
				ELSE
					BEGIN			
																						
						
						
						IF @AD_Rounding = 1
							SET @E_AD_AMOUNT = ROUND(@Calculated_Amount * @E_AD_PERCENTAGE/100,0)
						ELSE							
							SET @E_AD_AMOUNT = (@Calculated_Amount * @E_AD_PERCENTAGE)/100 
						
						
						If @E_AD_AMOUNT > @E_AD_MAX_LIMIT and @E_AD_MAX_LIMIT > 0          
							set @E_AD_AMOUNT = @E_AD_MAX_LIMIT
							
						if @Is_Yearly = 1
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
				
							IF @AD_Rounding = 1
									begin
										set @E_AD_AMOUNT = ROUND(@E_AD_AMOUNT,0)
									end
								else
									begin
										set @E_AD_AMOUNT = @E_AD_AMOUNT
									end
						
				END
			Else If @AD_Calculate_On = 'Slab Wise'   
				Begin 
					exec CALCULATE_AD_AMOUNT_SLAB_WISE_FOR_EMP_APP @CMP_ID,@Emp_Tran_ID,@AD_ID,@FOR_DATE,@Calculated_Amount output,@E_AD_AMOUNT output
				End
			Else If @AD_Calculate_On = 'Arrears CTC'  
				Begin
					
							
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
			Else If @AD_Calculate_On = 'Arrears'  
				Begin
					
					
							
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


