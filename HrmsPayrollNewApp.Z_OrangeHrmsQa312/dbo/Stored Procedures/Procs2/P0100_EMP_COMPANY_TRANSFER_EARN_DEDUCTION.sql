


---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0100_EMP_COMPANY_TRANSFER_EARN_DEDUCTION]
	 @AD_TRAN_ID		Numeric OUTPUT
	,@Tran_ID			Numeric
	,@EMP_ID			Numeric
	,@CMP_ID			Numeric
	,@AD_ID				Numeric
	,@INCREMENT_ID		Numeric(18,0)
	,@FOR_DATE			DateTime
	,@E_AD_FLAG			Char(1)
	,@E_AD_MODE			Varchar(10)
	,@E_AD_PERCENTAGE	numeric(5,2)
	,@E_AD_AMOUNT		numeric(18,2)
	,@Old_EMP_ID		Numeric
	,@Old_CMP_ID		Numeric
	,@Old_AD_ID			Numeric
	,@Old_AD_MODE		Varchar(10)
	,@Old_AD_PERCENTAGE	numeric(5,2)
	,@Old_AD_AMOUNT		numeric(18,2)
	,@Ad_Row_Id			Numeric = 0
	,@tran_type			varchar(1)
	,@User_Id numeric(18,0) = 0, -- Add By Mukti 11072016
	@IP_Address varchar(30)= '' -- Add By Mukti 11072016
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
		
		Declare @AD_Calculate_On	varchar(20)
		Declare @AD_Other_Amount	numeric(18,2)
		Declare @Calculated_Amount	numeric (18,2)
		Declare @AD_DEF_ID			int
		Declare @Emp_Full_PF		int
		Declare @Emp_PT				int
		Declare @Basic_Salary		numeric(18,2)
		declare @PT_Amount			numeric(18,2)
		Declare @Branch_ID			numeric
		Declare @AD_Amount			as numeric(18,2)
		Declare @Gross_Salary		numeric(18,2)
		Declare @CTC				Numeric(18,2)
		Declare @Temp_Amount		Numeric(18,2)
		Declare @ESIC_Limit			numeric(18,2)	
		Declare @Is_Yearly			numeric	
		Declare @E_AD_AMOUNT_YEARLY		numeric(18,2)
		Declare @Current_Date		datetime
		Declare @E_AD_MAX_LIMIT		numeric(18,2)
		Declare @PF_Limit Numeric(18,2)
								
		set @Current_Date = getdate()
		Set @CTC = 0
		Set @Temp_Amount = 0
		set @ESIC_Limit = 0
		set @Is_Yearly = 0
		set @E_AD_AMOUNT_YEARLY = 0
		Set @PF_Limit= 0
		
		If @E_AD_AMOUNT is null
			set @AD_Other_Amount = 0
			
		set @Emp_Full_PF =0 
		set @PT_Amount =0
		
	-- Add By Mukti 07072016(start)
		declare @OldValue as  varchar(max)
		Declare @String as varchar(max)
		set @String=''
		set @OldValue =''
	-- Add By Mukti 07072016(end)	
		
		SELECT @AD_DEF_ID = AD_DEF_ID ,@AD_Calculate_On = AD_CALCULATE_ON,@AD_Amount =Ad_Amount,@E_AD_MAX_LIMIT = AD_MAX_LIMIT,@Is_Yearly = Is_Yearly FROM T0050_AD_MASTER WITH (NOLOCK) WHERE AD_ID =@AD_ID
		SELECT @Branch_ID = Branch_ID , @Emp_PT =Emp_PT, @Emp_Full_PF = Emp_Full_PF ,@Basic_Salary = Basic_Salary ,@Calculated_Amount = Basic_Salary 
				, @Gross_Salary = Isnull(Gross_Salary,0), @CTC = Isnull(CTC,0)
		FROM	T0095_Increment WITH (NOLOCK) WHERE Increment_ID =@Increment_ID
		
		
		Declare @AD_Rounding  INT		
		SELECT @AD_Rounding = AD_Rounding, @PF_Limit = Isnull(PF_LIMIT,0) 
		FROM dbo.T0040_GENERAL_SETTING G WITH (NOLOCK) Left Outer Join T0050_GENERAL_DETAIL GD WITH (NOLOCK) on G.Gen_ID = GD.GEN_ID
			WHERE G.Cmp_ID=@CMP_ID AND Branch_ID=@Branch_ID
		AND For_Date = ( SELECT MAX(For_Date) FROM T0040_GENERAL_SETTING WITH (NOLOCK)
						  WHERE  Branch_ID = @Branch_ID AND Cmp_ID = @Cmp_ID)
			
		
		IF @AD_Calculate_On = 'Actual Gross' 
			set @Calculated_Amount = @Gross_Salary 
		Else IF @AD_Calculate_On = 'CTC' 
			set @Calculated_Amount = @CTC 
		Else
			Set @Calculated_Amount = @Basic_Salary 
		
		SELECT @ESIC_Limit = ISNULL(ESIC_Upper_Limit,0)                    
		FROM dbo.T0040_GENERAL_SETTING g WITH (NOLOCK)
		WHERE g.cmp_ID = @cmp_ID and Branch_ID = @Branch_ID                    
			  AND For_Date = (SELECT MAX(For_Date) FROM dbo.T0040_GENERAL_SETTING WITH (NOLOCK) WHERE Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)
		  
		
		
		IF @E_AD_PERCENTAGE >  0
			BEGIN				
				SELECT @AD_Other_Amount = ISNULL(SUM(E_AD_Amount),0) FROM T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) WHERE Increment_ID=@Increment_ID
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
							SET @E_AD_AMOUNT = @Calculated_Amount * @E_AD_PERCENTAGE/100	
						
						If @E_AD_AMOUNT > @E_AD_MAX_LIMIT and @E_AD_MAX_LIMIT > 0
							Set @E_AD_AMOUNT = @E_AD_MAX_LIMIT
						
						IF @Is_Yearly = 1
							Begin
								set @E_AD_AMOUNT_YEARLY = @E_AD_AMOUNT
								
								IF @AD_Rounding = 1
									begin
										set @E_AD_AMOUNT = ROUND(@E_AD_AMOUNT/12,0)
									end
								Else
									begin
										set @E_AD_AMOUNT = @E_AD_AMOUNT/12
									end
							End
					END
			END
			IF @AD_Calculate_On ='FIX'
				BEGIN
					SET @E_AD_AMOUNT =@E_AD_AMOUNT	
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
			Else If @AD_Calculate_On = 'Slab Wise' 
				Begin 
					exec CALCULATE_AD_AMOUNT_SLAB_WISE @CMP_ID,@Emp_ID,@AD_ID,@FOR_DATE,@Calculated_Amount output,@E_AD_AMOUNT output
				End
			Else If @AD_Calculate_On = 'Arrears CTC' --Changed the Spelling from "Arears" to "Arrears" by Ramiz on 16/11/2016
				Begin
					Select @Temp_Amount = Isnull(SUM(E_AD_AMOUNT),0)FROM T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) WHERE cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID 
							AND INCREMENT_ID = @INCREMENT_ID And E_AD_FLAG = 'I'
							
					Set @E_AD_AMOUNT = @CTC - Isnull((@Basic_Salary + @Temp_Amount),0) 
					set @Temp_Amount = 0
				End
			Else If @AD_Calculate_On = 'Arrears' --Changed the Spelling from "Arears" to "Arrears" by Ramiz on 16/11/2016
				Begin
					Select @Temp_Amount = Isnull(SUM(E_AD_AMOUNT),0)FROM T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) WHERE cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID 
							AND INCREMENT_ID = @INCREMENT_ID And E_AD_FLAG = 'I'
							AND AD_ID not in (select AD_ID from dbo.T0050_AD_MASTER WITH (NOLOCK) where Cmp_ID =@Cmp_ID and AD_Not_effect_salary = 1) 
							
					Set @E_AD_AMOUNT = @Gross_Salary - Isnull((@Basic_Salary + @Temp_Amount),0) 
					Set @Temp_Amount = 0
				End
	Set @E_AD_AMOUNT = Isnull(@E_AD_AMOUNT,0)
	
	IF @tran_type  = 'I' 
			BEGIN
				DECLARE @Row_Id Numeric
				SELECT  @Row_Id = ISNULL(MAX(Row_Id),0) + 1 FROM T0100_EMP_COMPANY_TRANSFER_EARN_DEDUCTION WITH (NOLOCK)
				
				INSERT INTO T0100_EMP_COMPANY_TRANSFER_EARN_DEDUCTION
							(Row_Id,Tran_Id,Old_Cmp_Id,Old_Emp_Id,Old_Ad_Id,Old_Mode,Old_Percentage,Old_Amount,New_Cmp_Id,New_Emp_Id,New_ad_Id,New_Mode,New_Percentage,New_Amount,Ad_Row_Id)
				VALUES		(@Row_Id,@Tran_ID,@Old_CMP_ID,@Old_EMP_ID,@Old_AD_ID,@Old_AD_MODE,@Old_AD_PERCENTAGE,@Old_AD_AMOUNT,@CMP_ID,@EMP_ID,@AD_ID,@E_AD_MODE,@E_AD_PERCENTAGE,@E_AD_AMOUNT,@Ad_Row_Id )

				-- Add By Mukti 07072016(start)
					exec P9999_Audit_get @table = 'T0100_EMP_COMPANY_TRANSFER_EARN_DEDUCTION' ,@key_column='Row_Id',@key_Values=@Row_Id,@String=@String output
					set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))	 
				-- Add By Mukti 07072016(end)		
				
				IF EXISTS(SELECT AD_TRAN_ID FROM T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) WHERE cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID AND INCREMENT_ID=@INCREMENT_ID AND AD_ID=@AD_ID)					
					BEGIN	    
						SET @AD_ID = 0				
						RETURN
					END
	
				SELECT  @AD_TRAN_ID = ISNULL(MAX(AD_TRAN_ID),0) + 1 FROM T0100_EMP_EARN_DEDUCTION WITH (NOLOCK)
		
				INSERT INTO T0100_EMP_EARN_DEDUCTION
				       (AD_TRAN_ID,EMP_ID,CMP_ID,AD_ID,INCREMENT_ID,FOR_DATE,E_AD_FLAG,E_AD_MODE,E_AD_PERCENTAGE,E_AD_AMOUNT,E_AD_YEARLY_AMOUNT,E_AD_MAX_LIMIT)
				VALUES (@AD_TRAN_ID,@EMP_ID,@CMP_ID,@AD_ID,@INCREMENT_ID,@FOR_DATE,@E_AD_FLAG,@E_AD_MODE,@E_AD_PERCENTAGE,@E_AD_AMOUNT,@E_AD_AMOUNT_YEARLY,@E_AD_MAX_LIMIT)
				
		
		
				if Exists(Select Increment_ID From dbo.T0095_INCREMENT WITH (NOLOCK) Where Emp_ID = @Emp_ID and Increment_effective_Date > @for_Date and (Increment_Type = 'Transfer' or  Increment_Type = 'Deputation') and Increment_ID <> @INCREMENT_ID)
					begin
							Declare  @Inc_Table table(
							inc_id numeric,
							increment_type nvarchar(20)
						)
						
						insert into @Inc_table
						Select Increment_ID,Increment_Type From dbo.T0095_INCREMENT WITH (NOLOCK) Where Emp_ID = @Emp_ID and Increment_effective_Date > @FOR_DATE 
						
						declare @Inc_id_update numeric
						declare @Inc_flag numeric
						declare @inc_type_update nvarchar(20)
						set @Inc_id_update = 0
						set @inc_type_update = ''
						set @Inc_flag = 0
						
						
						
						Declare cur_inc cursor for	                  
							select inc_id,increment_type from @Inc_Table 
						Open cur_inc                      
						Fetch next from cur_inc into @Inc_id_update,@inc_type_update
						   	While @@fetch_status = 0                    
							Begin 									
									--if @inc_type_update = 'Increment'
									--	begin
									--		set @Inc_flag = 1
									--	end
									--else if @Inc_flag = 0 
										begin
											SELECT  @AD_TRAN_ID = ISNULL(MAX(AD_TRAN_ID),0) + 1 FROM T0100_EMP_EARN_DEDUCTION WITH (NOLOCK)
											INSERT INTO T0100_EMP_EARN_DEDUCTION
												(AD_TRAN_ID,EMP_ID,CMP_ID,AD_ID,INCREMENT_ID,FOR_DATE,E_AD_FLAG,E_AD_MODE,E_AD_PERCENTAGE,E_AD_AMOUNT,E_AD_YEARLY_AMOUNT)
											VALUES (@AD_TRAN_ID,@EMP_ID,@CMP_ID,@AD_ID,@Inc_id_update,@FOR_DATE,@E_AD_FLAG,@E_AD_MODE,@E_AD_PERCENTAGE,@E_AD_AMOUNT,@E_AD_AMOUNT_YEARLY)		
											
										end
									fetch next from cur_inc into @Inc_id_update,@inc_type_update							  
							end                    
						close cur_inc                    
						deallocate cur_inc	
					end				
			END
	ELSE IF @Tran_Type = 'U' 
		BEGIN
			IF EXISTS(SELECT AD_TRAN_ID FROM T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) WHERE cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID AND INCREMENT_ID=@INCREMENT_ID AND AD_ID=@AD_ID)					
				BEGIN	    
					SET @AD_ID = 0
					RETURN
				END			
			
			
			--Update Company Transfer Table --
			Update	T0100_EMP_COMPANY_TRANSFER_EARN_DEDUCTION
			Set		New_Cmp_Id = @CMP_ID,
					New_Emp_Id = @EMP_ID,
					New_ad_Id = @AD_ID,
					New_Mode= @E_AD_MODE,
					New_Percentage = @E_AD_PERCENTAGE,
					New_Amount =@E_AD_AMOUNT--,
					--Ad_Row_Id =@Ad_Row_Id
			Where	Tran_Id = @Tran_Id
			--Update Company Transfer Table --
					
			UPDATE    T0100_EMP_EARN_DEDUCTION
			SET       FOR_DATE=@FOR_DATE,
					  E_AD_FLAG=@E_AD_FLAG,
					  E_AD_MODE=@E_AD_MODE,
					  E_AD_PERCENTAGE=@E_AD_PERCENTAGE,
					  E_AD_AMOUNT=@E_AD_AMOUNT,
					  E_AD_YEARLY_AMOUNT = @E_AD_AMOUNT_YEARLY
            Where AD_TRAN_ID = @AD_TRAN_ID and EMP_ID = @EMP_ID and CMP_ID = @CMP_ID and INCREMENT_ID = @INCREMENT_ID and AD_ID = @AD_ID
				
			 
		end
	Else if @Tran_Type = 'D' 
		begin
								
				Delete From T0100_EMP_EARN_DEDUCTION Where AD_TRAN_ID = @AD_TRAN_ID and Cmp_Id=@Cmp_ID
		end


	-- PT Update --
		if @Emp_PT = 1
			begin
				Select @AD_Other_Amount = isnull(sum(E_AD_Amount),0) from T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) where Increment_ID=@Increment_ID and E_AD_Flag ='I'
				set @Basic_Salary = @Basic_Salary + isnull(@AD_Other_Amount,0)
				Exec SP_CALCULATE_PT_AMOUNT @Cmp_ID,@Emp_ID,@Current_Date,@Basic_Salary,@PT_Amount output,'',@Branch_ID
			end
			
		Update T0095_Increment set Emp_PT_Amount = @PT_Amount where Increment_ID = @Increment_ID 
	-- PT Update --

	exec P9999_Audit_Trail @CMP_ID,@Tran_type,'Employee Company Transfer',@OldValue,@EMP_ID,@User_Id,@IP_Address,1
RETURN
