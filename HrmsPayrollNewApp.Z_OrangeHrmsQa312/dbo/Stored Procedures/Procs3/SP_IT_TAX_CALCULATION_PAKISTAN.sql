



---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_IT_TAX_CALCULATION_PAKISTAN]
	 @Cmp_ID				numeric,
	 @Emp_ID				numeric,
	 @For_Date				Datetime,
	 @Taxable_Amount		numeric,
	 @Return_Tax_Amount		numeric output,
	 @Surcharge_amount		numeric output,
	 @ED_Cess				numeric output,
	 @ED_Cess_Per			numeric(18,2)=0 ,
	 @SurCharge				numeric(18,2)=0 
	 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
		Declare @count as numeric 
		Declare @from_limit as numeric(18,2)
		Declare @To_limit as numeric(18,2)
		declare @IT_Percentage as numeric(18,4)
		declare @it_Round as numeric(18,2)
		Declare @Actual_IT_Amount as numeric(18,2)
		declare @Pre_To_Limit as numeric(18,2)
		DEclare @Temp_Row_ID as numeric 
		Declare @Temp_Name as varchar(100)
		Declare @Temp_IT_Amount as numeric ( 27,2)
		declare @Is_check as varchar(1)
		DECLARE @GENDER AS VARCHAR(1)
		Declare @Name as varchar(100)
		Declare @Temp_Limit_Amount as numeric(18,2)
--		declare @ED_Cess_Per numeric(18,2)
--		Declare @SurCharge	numeric(18,2)
		Declare	@IT_L_ID		numeric	
	
		--select @Gender = Gender from T0080_Emp_master where emp_ID =@Emp_ID
		Set @Gender ='M'
		
	   
		
		set @ED_Cess_Per = 0
		set @SurCharge	 = 0
		set @count =0
		set @from_limit =0
		set @To_limit = 0 
		set @IT_Percentage =0
		set @it_Round =0
		set @Actual_IT_Amount =0
		set @Pre_To_Limit =0
		set @Temp_IT_Amount = 0
		

		set @Is_check = 'N'
		set @ED_Cess_Per = @ED_Cess_Per
--		set @SurCharge   = 10
--Comment by hasmukh for Surcharge rule cancel by Govt from Apr 10	Dt: 07/03/2011								
	
		Declare @Gender1 as varchar(10)
		Declare @Date_OF_Birth as DateTime
		Declare @Count1 as numeric(18,2)
		
		Select  @Date_OF_Birth =isnull(Date_Of_Birth,getdate()) from T0080_emp_master WITH (NOLOCK) where Emp_ID=@Emp_ID 
				And Cmp_ID=@Cmp_ID
	
		
		SELECT @Count1 = DATEDIFF(year, @Date_OF_Birth, getdate())
		
	
		--If @Count1 >=60
		--  Begin
		--	set @Gender ='S'
		--  End		 
	  
		
		Declare curIncomeTax cursor for
			select from_limit,to_limit,Percentage,IT_L_ID from T0040_tAx_limit t WITH (NOLOCK) inner join
				( select cmp_ID , max(for_Date) For_Date from T0040_tAx_limit WITH (NOLOCK)
			where cmp_ID= @Cmp_ID and For_Date <=@For_Date and gender =@Gender  group by cmp_ID)q 
			on t.cmp_ID =q.cmp_ID and T.for_Date =q.for_Date and gender =@Gender
			order by From_Limit
		open curIncomeTax
		fetch next from curIncomeTax into @From_Limit,@To_Limit,@IT_Percentage,@IT_L_ID
				while @@fetch_status = 0
					begin					     
						set @IT_Percentage = @IT_Percentage /100
						set @Temp_IT_Amount = 0
						set @Count = @Count + 1
						if  @Taxable_Amount <= @To_Limit and @Count = 1 
							begin
								set @Actual_IT_Amount = 0
								set @Is_check = 'Y'
							end
						else if @Taxable_Amount <= @To_Limit and @Count = 1 and @IT_Percentage > 0 and @Is_check <> 'Y'
							begin							
								set @Actual_IT_Amount = round((@Taxable_Amount * @IT_Percentage) ,@IT_Round)
								set @Temp_IT_Amount  = @Actual_IT_Amount
								set @Taxable_Amount = 0								
							end
						else if @Taxable_Amount >= @To_Limit and @Count = 1 and @IT_Percentage > 0 and @Is_check <> 'Y'
							begin								
								set @Actual_IT_Amount = round(((@To_Limit ) * @IT_Percentage) ,@IT_Round)
								set @Temp_IT_Amount  = @Actual_IT_Amount																	
							end
						else if @Taxable_Amount >= (@to_Limit ) and @To_Limit > 0 and @IT_Percentage > 0 and @Is_check <> 'Y'
							begin							     
								set @Actual_IT_Amount = @Actual_IT_Amount + round((((@to_Limit ) - @Pre_To_Limit) * @IT_Percentage) ,@IT_Round)
								set @Temp_IT_Amount  = round((((@to_Limit ) - @Pre_To_Limit) * @IT_Percentage) ,@IT_Round)															
							end	
						else if @Taxable_Amount <= (@To_Limit ) and @Taxable_Amount>= @From_Limit and @To_Limit > 0 and @IT_Percentage > 0 and @Is_check <> 'Y'
							begin							
								set @Actual_IT_Amount = @Actual_IT_Amount + round((((@Taxable_Amount ) - @Pre_To_Limit) * @IT_Percentage) ,@IT_Round)
								set @Temp_IT_Amount = round((((@Taxable_Amount ) - @Pre_To_Limit) * @IT_Percentage) ,@IT_Round)								
							end								
						else if @Taxable_Amount > @From_Limit and @To_Limit = 0 and @IT_Percentage > 0 and @Is_check <> 'Y'
							begin						
								set @Actual_IT_Amount = @Actual_IT_Amount + round(( ( @Taxable_Amount - @Pre_To_Limit ) * @IT_Percentage) ,@IT_Round)
								set @Temp_IT_Amount = round(( ( @Taxable_Amount - @Pre_To_Limit ) * @IT_Percentage) ,@IT_Round)								
							end
						
							if @Taxable_Amount > @From_Limit  
								Begin										
									if @taxable_amount > @To_Limit  and @To_Limit >0
									   Begin 										
											set @Temp_Limit_Amount = @To_Limit - @Pre_To_Limit
									   end	
									else 
									   Begin 
											set @Temp_Limit_Amount =  @Taxable_Amount - @From_Limit 
									   End	
								end 
							else
								Begin
									set @Temp_Limit_Amount = 0 
								End
						
							set @Pre_To_Limit = @To_Limit	
							Update #Tax_Report 
							set Amount_Col_Final = @Temp_IT_Amount
							Where Emp_ID =@Emp_ID and IT_L_ID =@IT_L_ID
							
					fetch next from curIncomeTax into @From_Limit,@To_Limit,@IT_Percentage,@IT_L_ID
				end
			close curIncomeTax
			deallocate curIncomeTax
	
		DECLARE @Relief_sec_87 NUMERIC(18,2)
		DECLARE @Relief_sec_87_limit NUMERIC(18,2)
		DECLARE @Relief_amount AS NUMERIC(18,2)
		
--		SET @Relief_sec_87 = 2000
--		SET @Relief_sec_87_limit = 500000
		SET @Relief_sec_87 = 0
		SET @Relief_sec_87_limit = 0
		SET @Relief_amount = 0
		
		
	-- Comment by hasmukh for Surcharge rule cancel by Govt from Apr 10	Dt: 07/03/2011 --
							
	--		if @Taxable_amount > 1000000
	--			set @Surcharge_Amount = @Actual_IT_Amount * @SurCharge /100
	--		else
	--			set @Surcharge_Amount = 0
		
		
	
			--IF @Taxable_Amount <= @Relief_sec_87_limit AND YEAR(@For_Date) >= 2014 
			--	BEGIN
			--		--UPDATE #tax_report SET Amount_Col_Final = @Relief_sec_87  WHERE default_def_Id = 121 AND Emp_ID =@Emp_ID
			--		IF @Actual_IT_Amount < @Relief_sec_87
			--			BEGIN
			--				SET @Relief_sec_87 = @Actual_IT_Amount
			--			END
			--		ELSE
			--			BEGIN
			--				SET @Relief_sec_87 = 2000
			--			END 
	
			--	SET @Relief_amount =  @Relief_sec_87
			--	END
			--ELSE
			--	BEGIN
			--		SET @Relief_sec_87 = 2000 
			--		--UPDATE #tax_report SET Amount_Col_Final = 0 WHERE default_def_Id = 121 AND Emp_ID =@Emp_ID
			--		SET @Relief_amount =  0
			--	END	
				
			
			set @ED_Cess = ( @Actual_IT_Amount + @Surcharge_Amount - @Relief_amount )  * @ED_Cess_Per /100	
			set @Return_Tax_Amount = @Actual_IT_Amount - @Relief_amount
			
					
	RETURN



