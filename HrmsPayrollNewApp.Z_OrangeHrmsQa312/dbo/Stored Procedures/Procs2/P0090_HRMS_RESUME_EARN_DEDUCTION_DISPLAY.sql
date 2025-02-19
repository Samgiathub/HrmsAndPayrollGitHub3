CREATE PROCEDURE [dbo].[P0090_HRMS_RESUME_EARN_DEDUCTION_DISPLAY]
	  @AD_TRAN_ID		Numeric		OUTPUT
	 ,@Resume_ID		Numeric
	 ,@CMP_ID			Numeric 
	 ,@AD_ID			Numeric
	 ,@FOR_DATE			DateTime
	 ,@E_AD_FLAG		Char(1)=''
	 ,@E_AD_MODE		Varchar(10)=''
	 ,@E_AD_PERCENTAGE	numeric(18,5)
	 ,@E_AD_AMOUNT		NUMERIC(18, 4)	OUTPUT
	 ,@E_AD_MAX_LIMIT	NUMERIC(18, 4)	
	 ,@Basic_New		NUMERIC(18, 4)
     ,@Gross_New		NUMERIC(18, 4)
     ,@CTC_New			NUMERIC(18, 4)=0
	 ,@Temp_Amount_arrear		NUMERIC(18, 4)=0
	 ,@Temp_Amount_arrear_CTC	NUMERIC(18, 4)=0
	 ,@Branch_ID			NUMERIC(18, 4)
	 ,@Gross_Salary		NUMERIC(18, 4)=0
	 ,@CTC				NUMERIC(18, 4)=0
	 ,@Basic_Salary		NUMERIC(18, 4)=0
	 ,@Grd_Id as numeric
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	
	DECLARE @AD_Calculate_On	VARCHAR(20)
	DECLARE @AD_Other_Amount	NUMERIC(18, 4)
	DECLARE @Calculated_Amount	NUMERIC(18, 4)
	DECLARE @AD_DEF_ID			INT
	DECLARE @Emp_Full_PF		INT
	DECLARE @Emp_PT				INT		
	DECLARE @PT_Amount			NUMERIC(18, 4)		
	DECLARE @AD_Amount			NUMERIC(18, 4)		
	DECLARE @Temp_Amount		NUMERIC(18, 4)
	DECLARE @ESIC_Limit			NUMERIC(18, 4)
	DECLARE @Is_Yearly			NUMERIC(18, 4)
	DECLARE @E_AD_AMOUNT_YEARLY	NUMERIC(18, 4)	
	DECLARE @PF_Limit			NUMERIC(18, 4)
	
	
	SET @CTC = 0
	SET @Temp_Amount = 0
	SET @ESIC_Limit = 0
	SET @Is_Yearly = 0
	SET @E_AD_AMOUNT_YEARLY = 0
	SET @PF_Limit = 0
	
	IF @E_AD_AMOUNT is null
		SET @AD_Other_Amount = 0
		
	SET @Emp_Full_PF =0 
	SET @PT_Amount =0
	
	IF @FOR_DATE = ''
	SET @FOR_DATE= GETDATE()
	
	DECLARE @IS_ROUNDING_Allowance INT
	SELECT @AD_DEF_ID = AD_DEF_ID ,@AD_Calculate_On = AD_CALCULATE_ON,@AD_Amount =Ad_Amount, 
			@Is_Yearly = Is_Yearly , @IS_ROUNDING_Allowance = is_rounding 
	FROM T0050_AD_MASTER WITH (NOLOCK)
	WHERE AD_ID =@AD_ID 
	
	DECLARE @AD_Rounding  INT	
	SET @AD_Rounding = 0	
	SELECT @AD_Rounding = AD_Rounding,@PF_Limit = Isnull(PF_LIMIT,0)
	FROM dbo.T0040_GENERAL_SETTING G WITH (NOLOCK) LEFT OUTER JOIN T0050_GENERAL_DETAIL GD WITH (NOLOCK) on G.Gen_ID = GD.GEN_ID
	WHERE G.Cmp_ID=@CMP_ID AND Branch_ID=@Branch_ID
	AND For_Date = ( SELECT MAX(For_Date) FROM T0040_GENERAL_SETTING WITH (NOLOCK)
						  WHERE  Branch_ID = @Branch_ID AND Cmp_ID = @Cmp_ID)
	SET @AD_Rounding =  isnull(@IS_ROUNDING_Allowance,@AD_Rounding)		
	
	SELECT @E_AD_MAX_LIMIT = isnull(AD_MAX_LIMIT,0) FROM T0120_GRADEWISE_ALLOWANCE WITH (NOLOCK) where Ad_ID = @AD_ID And Grd_ID = @Grd_Id
	
	SET @Basic_Salary = @Basic_New
	SET @Gross_Salary = @Gross_New
	SET @Calculated_Amount = @Basic_New
	SET @CTC = @CTC_New
	
	IF @AD_Calculate_On = 'Actual Gross' 
		SET @Calculated_Amount = @Gross_Salary 
	ELSE IF @AD_Calculate_On = 'CTC' 
		SET @Calculated_Amount = @CTC 
	ELSE IF @AD_Calculate_On = 'Extra OT' 
		SET @Calculated_Amount = 0
	ELSE
		SET @Calculated_Amount = @Basic_Salary 
		
	SELECT @ESIC_Limit = ISNULL(ESIC_Upper_Limit,0)                    
	FROM dbo.T0040_GENERAL_SETTING g WITH (NOLOCK) INNER JOIN T0050_General_Detail gd WITH (NOLOCK) on g.Gen_ID = Gd.gen_ID                    
	WHERE g.cmp_ID = @cmp_ID and Branch_ID = @Branch_ID                    
			AND For_Date = (SELECT MAX(For_Date) FROM dbo.T0040_GENERAL_SETTING WITH (NOLOCK) WHERE For_Date <=@For_Date AND Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)

	
	Declare @Upper_Round_Employer_ESIC as int
		Select  @Upper_Round_Employer_ESIC = (Select Setting_ID from dbo.T0040_SETTING WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Setting_Name='Upper Round for Employer ESIC')

	IF @E_AD_PERCENTAGE >  0
			begin
				SELECT @AD_Other_Amount = ISNULL(SUM(E_AD_Amount),0) FROM
				 T0090_HRMS_RESUME_EARN_DEDUCTION WITH (NOLOCK)
				 WHERE Resume_id=@Resume_ID
						AND AD_ID IN (SELECT AD_ID FROM T0060_EFFECT_AD_MASTER WITH (NOLOCK) WHERE Effect_AD_ID =@AD_ID)	
				
				SET @Calculated_Amount = @Calculated_Amount + 	@AD_Other_Amount
				
				IF @AD_DEF_ID =3 or @AD_DEF_ID = 6 
					BEGIN
						IF @ESIC_Limit <> 0  
							BEGIN
								IF @Calculated_Amount <= @ESIC_Limit
									BEGIN 
										--SET @E_AD_Amount = CEILING((@Calculated_Amount * @E_AD_PERCENTAGE / 100))
										IF @AD_DEF_ID = 3 --SELECT @Calculated_Amount,@E_AD_PERCENTAGE
											SET @E_AD_Amount = CEILING((@Calculated_Amount * @E_AD_PERCENTAGE / 100)) 
										ELSE
											IF @AD_DEF_ID = 6 And @Upper_Round_Employer_ESIC = 0  
												SET @E_AD_Amount = Round(@Calculated_Amount * @E_AD_PERCENTAGE / 100,0) 
											ELSE
												SET @E_AD_Amount = CEILING((@Calculated_Amount * @E_AD_PERCENTAGE / 100))  
										END	
								Else
									BEGIN
										SET @E_AD_Amount = 0
									END						
							END		
						ELSE
							BEGIN
								SET @E_AD_AMOUNT = 0 
							END
					END
				ELSE IF @AD_DEF_ID = 2	or @AD_DEF_ID = 5	
					BEGIN
						IF @Emp_Full_PF = 0
							BEGIN
								IF @Calculated_Amount > @PF_Limit
									Begin 
										SET @Calculated_Amount = @PF_Limit
										SET @E_AD_AMOUNT = ROUND(@Calculated_Amount * @E_AD_PERCENTAGE/100,0)
									end
								Else
									Begin
										SET @E_AD_AMOUNT = ROUND(@Calculated_Amount * @E_AD_PERCENTAGE/100,0)
									End
									--select 22,@E_AD_AMOUNT,@PF_Limit,@Calculated_Amount
							END
						ELSE
							BEGIN
								SET @E_AD_AMOUNT = ROUND(@Calculated_Amount * @E_AD_PERCENTAGE/100,0)	
							END
					END
				ELSE
					BEGIN
					--select @E_AD_AMOUNT,@Calculated_Amount
						IF @AD_Rounding = 1
							SET @E_AD_AMOUNT = ROUND(@Calculated_Amount * @E_AD_PERCENTAGE/100,0)
						ELSE							
							SET @E_AD_AMOUNT = (@Calculated_Amount * @E_AD_PERCENTAGE)/100 
							
						

						IF @E_AD_AMOUNT > @E_AD_MAX_LIMIT and @E_AD_MAX_LIMIT > 0          ---Add by hasmukh for check max limit for % type allowance 23082011
							SET @E_AD_AMOUNT = @E_AD_MAX_LIMIT							
						
						IF @Is_Yearly = 1 
							BEGIN
								SET @E_AD_AMOUNT_YEARLY = @E_AD_AMOUNT
								IF @AD_Rounding = 1
									BEGIN
										SET @E_AD_AMOUNT = ROUND(@E_AD_AMOUNT/12,0)
									END
								ELSE
									BEGIN
										SET @E_AD_AMOUNT = @E_AD_AMOUNT/12
									END
							End
					END
			END	
			
		IF @AD_Calculate_On ='FIX'
			begin	
				IF @AD_Rounding = 1
					begin
						set @E_AD_AMOUNT = ROUND(@E_AD_AMOUNT,0)
					END
				ELSE
					BEGIN
						set @E_AD_AMOUNT = @E_AD_AMOUNT
					END
			END
		--ELSE IF @AD_Calculate_On = 'Slab Wise'
		--	BEGIN
		--		exec CALCULATE_AD_AMOUNT_SLAB_WISE @CMP_ID,@Emp_ID,@AD_ID,@FOR_DATE,@Calculated_Amount output,@E_AD_AMOUNT output
		--	END
		ELSE IF @AD_Calculate_On = 'Arrears CTC'
			BEGIN
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
			END
		Else If @AD_Calculate_On = 'Arrears' 
			BEGIN
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
			END
			
		Set @E_AD_AMOUNT = Isnull(@E_AD_AMOUNT,0)
END

