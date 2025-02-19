

-- =============================================
-- Author:		Ripal Patel
-- Create date: 07 Jun 2014
-- Description:	<Description,,>
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0100_ALLOWANCE_CALCULATION]
	 @EMP_ID			Numeric(18,0)
	,@CMP_ID			Numeric(18,0)
	,@AD_ID				Numeric(18,0)
	,@E_AD_PERCENTAGE	numeric(18,2)
	,@E_AD_AMOUNT		numeric(18,2)
	,@E_AD_MAX_LIMIT	numeric(18,2)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

--Added by ripal 
Declare @INCREMENT_ID	Numeric(18,0)
Declare @FOR_DATE		DateTime
select @INCREMENT_ID=Increment_ID,@FOR_DATE=Increment_Effective_Date from T0095_INCREMENT WITH (NOLOCK)
	where Increment_ID in(select max(Increment_ID) from T0095_INCREMENT WITH (NOLOCK)
							where Cmp_id = @CMP_ID and emp_id = @EMP_ID group by emp_id)
---
		Declare @AD_Calculate_On varchar(20)
		Declare @AD_Other_Amount	numeric 
		Declare @Calculated_Amount	numeric (18,2)
		Declare @AD_DEF_ID			int
		Declare @Emp_Full_PF		int
		Declare @Emp_PT				int
		Declare @Basic_Salary		numeric(18,2)
		declare @PT_Amount			numeric 
		Declare @Branch_ID			numeric
		Declare @AD_Amount as numeric(18,2)
		Declare @Gross_Salary		numeric
		Declare @CTC				Numeric
		Declare @Temp_Amount		Numeric
		Declare @ESIC_Limit			numeric	
		Declare @Is_Yearly			numeric	
		Declare @E_AD_AMOUNT_YEARLY		numeric(18,2)		
		Declare @Current_Date datetime
		Declare @AD_Other_Amount_ESIC	numeric(18,2) 
		Declare @ESIC_limit_Calculated_Amount Numeric (18,2)
		Declare @PF_Limit as Numeric(18,2)

		Declare @Grd_Id as Numeric
		
		set @Current_Date = getdate()
		
		Set @CTC = 0
		Set @Temp_Amount = 0
		set @ESIC_Limit = 0
		set @Is_Yearly = 0
		set @E_AD_AMOUNT_YEARLY = 0
		set @AD_Other_Amount_ESIC = 0
		set @ESIC_limit_Calculated_Amount = 0
		Set @Grd_Id = 0
		SEt @PF_Limit = 0

		if @E_AD_AMOUNT is null
			set @AD_Other_Amount = 0
			
		set @Emp_Full_PF =0 
		set @PT_Amount =0
		--CHANGE BY NILAY - 25 -JAN-2011--------
		---set @E_AD_AMOUNT=0
		--set @AD_Amount =0
		
		SELECT @AD_DEF_ID = AD_DEF_ID ,@AD_Calculate_On = AD_CALCULATE_ON,@AD_Amount =Ad_Amount,@Is_Yearly = Is_Yearly --,@E_AD_MAX_LIMIT = AD_MAX_LIMIT
		FROM T0050_AD_MASTER WITH (NOLOCK) WHERE AD_ID =@AD_ID
		
		SELECT  @Branch_ID		= Branch_ID , @Emp_PT =Emp_PT, @Emp_Full_PF = Emp_Full_PF ,@Basic_Salary = isnull(Basic_Salary,0) ,@Calculated_Amount = isnull(Basic_Salary,0) 
				-- , @For_Date		= Increment_Effective_Date -- comented by mitesh on 12072012
				, @Gross_Salary = Isnull(Gross_Salary,0), @CTC = Isnull(CTC,0),@Grd_Id = Grd_ID
		FROM	T0095_Increment WITH (NOLOCK) WHERE Increment_ID =@Increment_ID
		
		Select @E_AD_MAX_LIMIT = isnull(AD_MAX_LIMIT,0) from T0120_GRADEWISE_ALLOWANCE WITH (NOLOCK) where Ad_ID = @AD_ID And Grd_ID = @Grd_Id
		
		-- Alpesh 20-Jul-2011 Added for Rounding 
		Declare @AD_Rounding  INT		
		SELECT @AD_Rounding = AD_Rounding,@PF_Limit = PF_Limit FROM dbo.T0040_GENERAL_SETTING G WITH (NOLOCK)
			Left Outer join T0050_General_Detail GD WITH (NOLOCK) On G.Gen_Id =GD.Gen_Id
		WHERE G.Cmp_ID=@CMP_ID AND Branch_ID=@Branch_ID
		AND For_Date = ( SELECT MAX(For_Date) FROM T0040_GENERAL_SETTING WITH (NOLOCK)
						  WHERE  Branch_ID = @Branch_ID AND Cmp_ID = @Cmp_ID)
			

		IF @AD_Calculate_On = 'Actual Gross' -- Added by Falak on 03-MAY-2011 
			set @Calculated_Amount = @Gross_Salary 
		Else IF @AD_Calculate_On = 'CTC' 
			set @Calculated_Amount = @CTC 
		Else
			Set @Calculated_Amount = @Basic_Salary 

		SELECT @ESIC_Limit = ISNULL(ESIC_Upper_Limit,0)                    
		  FROM dbo.T0040_GENERAL_SETTING g WITH (NOLOCK) --INNER JOIN T0050_General_Detail gd on g.Gen_ID = Gd.gen_ID                    
		  WHERE g.cmp_ID = @cmp_ID and Branch_ID = @Branch_ID                    
		  AND For_Date = (SELECT MAX(For_Date) FROM dbo.T0040_GENERAL_SETTING WITH (NOLOCK) WHERE Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)

		IF @E_AD_PERCENTAGE >  0
			BEGIN				
				SELECT @AD_Other_Amount = ISNULL(SUM(E_AD_Amount),0) FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) inner join 
					T0050_ad_master AM WITH (NOLOCK) on eed.ad_id = am.ad_id WHERE Increment_ID=@Increment_ID  
						AND eed.AD_ID IN (SELECT AD_ID FROM T0060_EFFECT_AD_MASTER WITH (NOLOCK) WHERE Effect_AD_ID =@AD_ID)

			------------import condition added by hasmukh 13042013----------------

				--SELECT @AD_Other_Amount_esic = ISNULL(SUM(E_AD_Amount),0) FROM T0100_EMP_EARN_DEDUCTION EED inner join 
				--	T0050_ad_master AM on eed.ad_id = am.ad_id WHERE Increment_ID=@Increment_ID and am.AD_CALCULATE_ON <> 'Import'   
				--		AND eed.AD_ID IN (SELECT AD_ID FROM T0060_EFFECT_AD_MASTER WHERE Effect_AD_ID =@AD_ID)
											
			-----------------End---------------------------------------------------
								
		--		set @ESIC_limit_Calculated_Amount = @Calculated_Amount   ---Added by Hasmukh 18042013 for esic limit not check on import type allowance 

				SET @Calculated_Amount = @Calculated_Amount + @AD_Other_Amount


		--		Set @ESIC_limit_Calculated_Amount = @ESIC_limit_Calculated_Amount + @AD_Other_Amount_esic  ---Added by Hasmukh 18042013 for esic limit not check on import type allowance 

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
				--Else if @AD_DEF_ID = 5  --For company PF  added by hasmukh 03012012
				--	SET @E_AD_AMOUNT = ROUND(@Calculated_Amount * @E_AD_PERCENTAGE/100,0)	
				--Else if @AD_DEF_ID = 6  --For company ESIC added by hasmukh 03012012
				--	SET @E_AD_Amount = CEILING((@Calculated_Amount * @E_AD_PERCENTAGE / 100))	
				ELSE IF @AD_DEF_ID = 2 or @AD_DEF_ID = 5		
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

						If @E_AD_AMOUNT > @E_AD_MAX_LIMIT and @E_AD_MAX_LIMIT > 0          ---Add by hasmukh for check max limit for % type allowance 23082011
							set @E_AD_AMOUNT = @E_AD_MAX_LIMIT
							
					End
				ELSE
					BEGIN							 
						--SET @E_AD_AMOUNT = @Calculated_Amount * @E_AD_PERCENTAGE/100
						
						IF @AD_Rounding = 1
							SET @E_AD_AMOUNT = ROUND(@Calculated_Amount * @E_AD_PERCENTAGE/100,0)
						ELSE
							SET @E_AD_AMOUNT = @Calculated_Amount * @E_AD_PERCENTAGE/100	
						
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
					SET @E_AD_AMOUNT =@E_AD_AMOUNT	
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
			Else If @AD_Calculate_On = 'Slab Wise'   -- Hasmukh for slab wise allowance
				Begin 
					exec CALCULATE_AD_AMOUNT_SLAB_WISE @CMP_ID,@Emp_ID,@AD_ID,@FOR_DATE,@Calculated_Amount output,@E_AD_AMOUNT output
				End
			Else If @AD_Calculate_On = 'Arrears CTC'   -- Hasmukh for Auto SP allowance when calc on CTC --Changed the Spelling from "Arears CTC" to "Arrears CTC" by Ramiz on 16/11/2016
				Begin
					Select @Temp_Amount = Isnull(SUM(E_AD_AMOUNT),0)FROM T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) WHERE cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID 
							AND INCREMENT_ID = @INCREMENT_ID And E_AD_FLAG = 'I'
							
					Set @E_AD_AMOUNT = @CTC - Isnull((@Basic_Salary + @Temp_Amount),0) 
					set @Temp_Amount = 0
				End
			Else If @AD_Calculate_On = 'Arrears'   -- Hasmukh for Auto SP allowance when calc on gross   --Changed the Spelling from "Arears" to "Arrears" by Ramiz on 16/11/2016
				Begin
					Select @Temp_Amount = Isnull(SUM(E_AD_AMOUNT),0)FROM T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) WHERE cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID 
							AND INCREMENT_ID = @INCREMENT_ID And E_AD_FLAG = 'I'
							AND AD_ID not in (select AD_ID from dbo.T0050_AD_MASTER WITH (NOLOCK) where Cmp_ID =@Cmp_ID and AD_Not_effect_salary = 1) 
							
					Set @E_AD_AMOUNT = @Gross_Salary - Isnull((@Basic_Salary + @Temp_Amount),0) 
					Set @Temp_Amount = 0
				End
	Set @E_AD_AMOUNT = Isnull(@E_AD_AMOUNT,0)	
	select @E_AD_AMOUNT E_AD_AMOUNT
	
END


