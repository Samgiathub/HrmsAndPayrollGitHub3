
CREATE PROCEDURE [dbo].[SP_IT_TAX_CALCULATION]
	 @Cmp_ID				numeric,
	 @Emp_ID				numeric,
	 @For_Date				Datetime,
	 @Taxable_Amount		numeric,
	 @Return_Tax_Amount		numeric output,
	 @Surcharge_amount		numeric output,
	 @ED_Cess				numeric output,
	 @ED_Cess_Per			numeric(18,2)=0 ,
	 @SurCharge				numeric(18,2)=0,
	 @Relief_87A_Amount		numeric(18,2) = 0 output  ,
	 @Return_Tax_Amount_Actual NUMERIC = 0 OUTPUT,	--Ankit 27042016
	 @TAX_REGIME VARCHAR(50) = '' --HARDIK 02/04/2020 FOR TAX REGIME
	 
AS
	set nocount on  
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON  
	
		Declare @count as numeric 
		Declare @from_limit as numeric(18,2)
		Declare @To_limit as numeric(18,2)
		declare @IT_Percentage as numeric(18,2)
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
	
		
	
	  	
	--	set @ED_Cess_Per = 0
	--	set @SurCharge	 = 0
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
		DECLARE @Pan_No	AS VARCHAR(30)	--Ankit 04022016
		SET @Pan_No = ''
		DECLARE @Pan_Flag AS NUMERIC
		SET @Pan_Flag = 0
		
		select @Gender = Gender, @Date_OF_Birth =isnull(Date_Of_Birth,getdate()) , @Pan_No = ISNULL(Pan_No,'')
		from T0080_Emp_master where emp_ID =@Emp_ID
		
		--SELECT @Count1 = DATEDIFF(year, @Date_OF_Birth, getdate())
		
		--If @Count1 >=60
		--Added By Jimit 25052018 for case of WCl
		If cast(dbo.F_GET_AGE(@Date_OF_Birth,GETDATE(),'N','Y') as numeric(18,2)) > 80
		  Begin
			set @Gender ='V'
		  End		 
		Else If cast(dbo.F_GET_AGE(@Date_OF_Birth,GETDATE(),'N','Y') as numeric(18,2)) > 60
		  Begin
			set @Gender ='S'
		  End		 
	  
		DECLARE @UpdateTaxReport BIT
		SET @UpdateTaxReport = 1
		IF Object_ID('tempdb..#Taxable_Payment_Process') IS NOT NULL	
			BEGIN
				IF EXISTS(SELECT 1 FROM #Taxable_Payment_Process) 
					SET @UpdateTaxReport = 0											
			END
		
		--If @TAX_REGIME is null  		-- Commeted By Sajid 18-03-2023
		--	set @TAX_REGIME = 'Tax Regime 1' 		-- Commeted By Sajid 18-03-2023

			
		-- Added By Sajid 18-03-2023
		IF YEAR(@For_Date)>=2024
			BEGIN
				If @TAX_REGIME is null								
				set @TAX_REGIME = 'Tax Regime 2' 
			END
		ELSE
		IF YEAR(@For_Date)<=2023
			BEGIN
				If @TAX_REGIME is null 
				set @TAX_REGIME = 'Tax Regime 1'
		END
		-- Added By Sajid 18-03-2023

		
				

		Declare curIncomeTax cursor for
			select from_limit,to_limit,Percentage,IT_L_ID from T0040_tAx_limit t inner join
				( select cmp_ID , max(for_Date) For_Date from T0040_tAx_limit 
			where cmp_ID= @Cmp_ID and For_Date <=@For_Date and gender =@Gender AND Regime = @TAX_REGIME  
			group by cmp_ID)q 
			on t.cmp_ID =q.cmp_ID and T.for_Date =q.for_Date and gender =@Gender AND Regime = @TAX_REGIME
			order by From_Limit
			
			--select from_limit,to_limit,Percentage,IT_L_ID from T0040_tAx_limit t inner join
			--( SELECT cmp_ID , MAX(for_Date) For_Date FROM T0040_tAx_limit 
			--	WHERE cmp_ID= @Cmp_ID AND For_Date <=@To_Date AND gender ='M' GROUP BY cmp_ID)q ON t.cmp_ID =q.cmp_ID AND T.for_Date =q.for_Date AND gender ='M'
		
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
							
								--set @Actual_IT_Amount = @Actual_IT_Amount + round((((@Taxable_Amount ) - @Pre_To_Limit) * @IT_Percentage) ,@IT_Round)
								--set @Temp_IT_Amount = round((((@Taxable_Amount ) - @Pre_To_Limit) * @IT_Percentage) ,@IT_Round)
						
								--IF Pan No not in Master then Calcualte 20 % Tax ----Ankit 04022016
								--IF ISNULL(@Pan_No,'') = ''	
								--	BEGIN

								--		SET @Pan_Flag = 1
								--		select @IT_L_ID = IT_L_ID from T0040_tAx_limit t INNER JOIN
								--			( select cmp_ID , max(for_Date) For_Date from T0040_tAx_limit 
								--				where cmp_ID= @Cmp_ID and For_Date <=@For_Date and gender =@Gender AND ( Percentage = 30) group by cmp_ID
								--			) q on t.cmp_ID =q.cmp_ID and T.for_Date =q.for_Date and gender =@Gender AND ( Percentage = 30)
								--		order by From_Limit
										
								--		set @Actual_IT_Amount = @Actual_IT_Amount + round((((@Taxable_Amount ) - @Pre_To_Limit) * 0.3) ,@IT_Round)
								--		SET @Temp_IT_Amount = round((((@Taxable_Amount ) - @Pre_To_Limit) * 0.3) ,@IT_Round)
								--	END	
								--ELSE
									BEGIN
										set @Actual_IT_Amount = @Actual_IT_Amount + round((((@Taxable_Amount ) - @Pre_To_Limit) * @IT_Percentage) ,@IT_Round)
										SET @Temp_IT_Amount = round((((@Taxable_Amount ) - @Pre_To_Limit) * @IT_Percentage) ,@IT_Round)	
									END	
								
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
						
							
							--Ankit 04022016
							IF @UpdateTaxReport = 1
								BEGIN
									--IF @Pan_Flag <> 1 
									--	BEGIN
									--		Update #Tax_Report 
									--		set Amount_Col_Final = @Temp_IT_Amount
									--		Where Emp_ID =@Emp_ID and IT_L_ID = @IT_L_ID
									--	END
									--ELSE
										BEGIN
											Update #Tax_Report 
											set Amount_Col_Final = @Temp_IT_Amount
											Where Emp_ID =@Emp_ID and IT_L_ID = @IT_L_ID AND Amount_Col_Final = 0
										END		
								END
							--Ankit 04022016
							
							----Comment By Ankit 04022016
							--Update #Tax_Report 
							--set Amount_Col_Final = @Temp_IT_Amount
							--Where Emp_ID =@Emp_ID and IT_L_ID = @IT_L_ID
							
					fetch next from curIncomeTax into @From_Limit,@To_Limit,@IT_Percentage,@IT_L_ID
				end
			close curIncomeTax
			deallocate curIncomeTax

		--- New Login Added by Hardik for PAN No Blank on 07/04/2020
		IF ISNULL(@Pan_No,'') = ''
			begin
				Declare @Max_IT_L_Id Numeric
				Declare @Min_IT_L_Id Numeric
				Declare @Min_To_Limit Numeric
				Declare @Max_IT_Percent numeric(6,2)

				SELECT @Max_IT_L_Id = Max(IT_L_ID),@Min_IT_L_Id = Min(IT_L_ID) 
				FROM #Tax_Report WHERE Emp_Id = @Emp_Id and Isnull(IT_L_Id,0) > 0

				--SELECT @Max_IT_L_Id = Max(IT_L_ID),@Min_IT_L_Id = Min(IT_L_ID) FROM #Tax_Report WHERE Emp_Id = @Emp_Id and Isnull(IT_L_Id,0) > 0
				Set @Min_To_Limit = 0
				-- Commented by Hardik 24/04/2020 as discussed with Chintan and Mohit, No any limit will deduct
				-- Again uncommented by Hardik 08/05/2020 as query send from Unison so require to minus minimum limit
				SELECT @Min_To_Limit = To_Limit  FROM T0040_TAX_LIMIT 
				WHERE CMP_ID = @Cmp_ID And IT_L_ID = @Min_IT_L_Id And Percentage = 0

				SELECT @Max_IT_Percent = Percentage  FROM T0040_TAX_LIMIT 
				WHERE CMP_ID = @Cmp_ID And IT_L_ID = @Max_IT_L_Id

				If @Taxable_Amount > @Min_To_Limit
					Begin
						
						Update #Tax_Report Set Amount_Col_Final = (@Taxable_Amount - @Min_To_Limit) * (@Max_IT_Percent /100)
							Where Emp_Id = @Emp_Id And Isnull(IT_L_Id,0) = @Max_IT_L_Id

						Update #Tax_Report Set Amount_Col_Final = 0 
							Where Emp_Id = @Emp_Id And Isnull(IT_L_Id,0) <> @Max_IT_L_Id And Isnull(IT_L_Id,0) >0

						Set @Actual_IT_Amount = (@Taxable_Amount - @Min_To_Limit) * (@Max_IT_Percent /100)

					End
			end
	
		DECLARE @Relief_sec_87 NUMERIC(18,2)
		DECLARE @Relief_sec_87_limit NUMERIC(18,2)
		DECLARE @Relief_amount AS NUMERIC(18,2)
		
		DECLARE @From_Date DATETIME			--Ankit 27042016
		SET @From_Date = DATEADD(DAY,1,@For_Date)	
		SET @From_Date = Dateadd(Year,-1,@From_Date)
		SET @Return_Tax_Amount_Actual = 0
		
		---- Commeted By Sajid 18-03-2023 - Start
		--SET @Relief_sec_87_limit = 500000
		
		--if YEAR(@From_Date) >= 2019 AND ISNULL(@Pan_No,'') <> ''

		--	begin
		--		SET @Relief_sec_87 = 12500
		--		Set @Relief_sec_87_limit = 500000
		--	end
		--Else if YEAR(@From_Date) >= 2017 AND ISNULL(@Pan_No,'') <> ''
		--	begin
		--		SET @Relief_sec_87 = 2500
		--		Set @Relief_sec_87_limit = 350000
		--	end
		--else IF YEAR(@From_Date) >= 2016 AND ISNULL(@Pan_No,'') <> ''		--Ankit 26042016
		--	SET @Relief_sec_87 = 5000
		--ELSE IF ISNULL(@Pan_No,'') <> ''
		--	SET @Relief_sec_87 = 2000	
		--ELSE
		--	SET @Relief_sec_87 = 0

		--SET @Relief_amount = 0
		---- Commeted By Sajid 18-03-2023 - Sta
		
			-- Added By Sajid 18-03-2023 -Start
		IF @TAX_REGIME='Tax Regime 1'
			BEGIN 	
				SET @Relief_sec_87_limit = 500000
					END
				ELSE 
		IF @TAX_REGIME='Tax Regime 2' AND YEAR(@From_Date) >= 2023 
			BEGIN 
				SET @Relief_sec_87_limit = 700000
			END
			
							
		IF @TAX_REGIME='Tax Regime 1'
		BEGIN		
		if YEAR(@From_Date) >= 2019 AND ISNULL(@Pan_No,'') <> '' AND @TAX_REGIME='Tax Regime 1' -- Added By Sajid 18-03-2023
			begin
				SET @Relief_sec_87 = 12500
				Set @Relief_sec_87_limit = 500000
			end
		Else if YEAR(@From_Date) >= 2017 AND ISNULL(@Pan_No,'') <> '' AND @TAX_REGIME='Tax Regime 1' -- Added By Sajid 18-03-2023
			begin
				SET @Relief_sec_87 = 2500
				Set @Relief_sec_87_limit = 350000
			end
		else IF YEAR(@From_Date) >= 2016 AND ISNULL(@Pan_No,'') <> ''	AND @TAX_REGIME='Tax Regime 1' -- Added By Sajid 18-03-2023
			SET @Relief_sec_87 = 5000
		ELSE IF ISNULL(@Pan_No,'') <> '' AND @TAX_REGIME='Tax Regime 1' -- Added By Sajid 18-03-2023
			SET @Relief_sec_87 = 2000	
		ELSE
			SET @Relief_sec_87 = 0		
		--SET @Relief_amount = 0		
		-- Added By Sajid 18-03-2023
		END 
		 
 IF @TAX_REGIME='Tax Regime 2'
		 BEGIN
			if YEAR(@From_Date) >= 2023 AND ISNULL(@Pan_No,'') <> '' 
			begin			
				SET @Relief_sec_87 = 25000
				Set @Relief_sec_87_limit = 700000
			end
		Else 
			SET @Relief_sec_87 = 0

		SET @Relief_amount = 0
		END 

		
		-- Added By Sajid 18-03-2023 -END
			-- Comment by hasmukh for Surcharge rule cancel by Govt from Apr 10	Dt: 07/03/2011 --
									
			--		if @Taxable_amount > 1000000
			--			set @Surcharge_Amount = @Actual_IT_Amount * @SurCharge /100
			--		else
			--			set @Surcharge_Amount = 0
		
		--	---- Commeted By Sajid 18-03-2023 - Start
		--	IF @Taxable_Amount <= @Relief_sec_87_limit AND YEAR(@For_Date) >= 2014   AND ISNULL(@Pan_No,'') <> ''
		--		BEGIN
				
		--			--UPDATE #tax_report SET Amount_Col_Final = @Relief_sec_87  WHERE default_def_Id = 121 AND Emp_ID =@Emp_ID
		--			IF @Actual_IT_Amount < @Relief_sec_87
		--				BEGIN
		--					SET @Relief_sec_87 = @Actual_IT_Amount
		--				END
		--			ELSE
		--				BEGIN
		--					if YEAR(@From_Date) >= 2019
		--						begin
		--							SET @Relief_sec_87 = 12500
		--							Set @Relief_sec_87_limit = 500000
		--						end
		--					Else if YEAR(@From_Date) >= 2017
		--						begin
		--							SET @Relief_sec_87 = 2500
		--							Set @Relief_sec_87_limit = 350000
		--						end
		--					else IF YEAR(@From_Date) >= 2016		--Ankit 26042016
		--						SET @Relief_sec_87 = 5000
		--					ELSE
		--						SET @Relief_sec_87 = 2000		
		--					--SET @Relief_sec_87 = 2000
		--				END 
	
		--		SET @Relief_amount =  @Relief_sec_87
				
		--		END
		--	ELSE IF  ISNULL(@Pan_No,'') <> ''
		--		BEGIN
		--			if YEAR(@From_Date) >= 2019 
		--				begin
		--					SET @Relief_sec_87 = 12500
		--					Set @Relief_sec_87_limit = 500000
		--				end
		--			else if YEAR(@From_Date) >= 2017
		--				begin
		--					SET @Relief_sec_87 = 2500
		--					Set @Relief_sec_87_limit = 350000
		--				end
		--			else IF YEAR(@From_Date) >= 2016		--Ankit 26042016
		--				SET @Relief_sec_87 = 5000
		--			ELSE
		--				SET @Relief_sec_87 = 2000
						
		--			--SET @Relief_sec_87 = 2000 
		--			--UPDATE #tax_report SET Amount_Col_Final = 0 WHERE default_def_Id = 121 AND Emp_ID =@Emp_ID
		--			SET @Relief_amount =  0
		--		END	
		--	ELSE
		--		BEGIN 
		--			SET @Relief_sec_87 = 0
		--			SET @Relief_amount =  0
		--		END
		--set @Relief_87A_Amount = @Relief_amount	
		------ Commeted By Sajid 18-03-2023 - END
	
	-- Added By Sajid 18-03-2023	-- Start	
	IF @TAX_REGIME='Tax Regime 1' -- Added By Sajid 18-03-2023	-- Start
		BEGIN  -- Added By Sajid 18-03-2023	-- Start	
			IF @Taxable_Amount <= @Relief_sec_87_limit AND YEAR(@For_Date) >= 2014   AND ISNULL(@Pan_No,'') <> '' AND @TAX_REGIME='Tax Regime 1' -- Added By Sajid 18-03-2023
				BEGIN				
					--UPDATE #tax_report SET Amount_Col_Final = @Relief_sec_87  WHERE default_def_Id = 121 AND Emp_ID =@Emp_ID					
					IF @Actual_IT_Amount < @Relief_sec_87
						BEGIN						
							SET @Relief_sec_87 = @Actual_IT_Amount
						END
					ELSE
						BEGIN
							if YEAR(@From_Date) >= 2019 AND @TAX_REGIME='Tax Regime 1' -- Added By Sajid 18-03-2023
								begin
									SET @Relief_sec_87 = 12500
									Set @Relief_sec_87_limit = 500000
								end
							Else if YEAR(@From_Date) >= 2017 AND @TAX_REGIME='Tax Regime 1' -- Added By Sajid 18-03-2023
								begin
									SET @Relief_sec_87 = 2500
									Set @Relief_sec_87_limit = 350000
								end
							else IF YEAR(@From_Date) >= 2016 AND @TAX_REGIME='Tax Regime 1' -- Added By Sajid 18-03-2023
								SET @Relief_sec_87 = 5000
							ELSE
								SET @Relief_sec_87 = 2000		
							--SET @Relief_sec_87 = 2000
						END 
	
				SET @Relief_amount =  @Relief_sec_87
				
				END
			ELSE IF  ISNULL(@Pan_No,'') <> '' AND @TAX_REGIME='Tax Regime 1' -- Added By Sajid 18-03-2023
				BEGIN
					if YEAR(@From_Date) >= 2019  AND @TAX_REGIME='Tax Regime 1' -- Added By Sajid 18-03-2023
						begin
							SET @Relief_sec_87 = 12500
							Set @Relief_sec_87_limit = 500000
						end
					else if YEAR(@From_Date) >= 2017 AND @TAX_REGIME='Tax Regime 1' -- Added By Sajid 18-03-2023
						begin
							SET @Relief_sec_87 = 2500
							Set @Relief_sec_87_limit = 350000
						end
					else IF YEAR(@From_Date) >= 2016 AND @TAX_REGIME='Tax Regime 1' -- Added By Sajid 18-03-2023
						SET @Relief_sec_87 = 5000
					ELSE
						SET @Relief_sec_87 = 2000
					
					SET @Relief_amount =  0
				END	
			ELSE
				BEGIN 
					SET @Relief_sec_87 = 0
					SET @Relief_amount =  0
				END				
			END
		ELSE
		
		IF @TAX_REGIME='Tax Regime 2'		
		BEGIN
		
				IF @Taxable_Amount <= @Relief_sec_87_limit AND YEAR(@For_Date) >= 2023   AND ISNULL(@Pan_No,'') <> '' AND @TAX_REGIME='Tax Regime 2' -- Added By Sajid 18-03-2023
				BEGIN	
				
					IF @Actual_IT_Amount < @Relief_sec_87
						BEGIN
							SET @Relief_sec_87 = @Actual_IT_Amount
						END
							ELSE	IF @Actual_IT_Amount > @Relief_sec_87
						BEGIN
							SET @Relief_sec_87 = 0
						END
					ELSE
						BEGIN
							if YEAR(@From_Date) >= 2023 AND @TAX_REGIME='Tax Regime 2' -- Added By Sajid 18-03-2023
								begin
									SET @Relief_sec_87 = 25000
									Set @Relief_sec_87_limit = 700000
								end							
							ELSE
								SET @Relief_sec_87 = 0									
						END 
	
					SET @Relief_amount =  @Relief_sec_87				
				
				END
			ELSE IF  ISNULL(@Pan_No,'') <> '' AND @TAX_REGIME='Tax Regime 2' -- Added By Sajid 18-03-2023
				BEGIN
					
					if YEAR(@From_Date) >= 2023  AND @TAX_REGIME='Tax Regime 2' -- Added By Sajid 18-03-2023
						begin
							SET @Relief_sec_87 = 25000
							Set @Relief_sec_87_limit = 700000
							
							IF @Taxable_Amount > @Relief_sec_87_limit
							BEGIN
							
										if (@Taxable_Amount - @Relief_sec_87_limit) <  @Actual_IT_Amount
										BEGIN
												SET @Relief_amount = @Actual_IT_Amount - (@Taxable_Amount - @Relief_sec_87_limit)
										END
							END
						end
						ELSE
						BEGIN
							SET @Relief_sec_87 = 0
							SET @Relief_amount =  0
						END
						
						--SELECT @Relief_sec_87,@Relief_sec_87_limit,@Actual_IT_Amount,@Taxable_Amount
				END	
			ELSE
				BEGIN 
					SET @Relief_sec_87 = 0
					SET @Relief_amount =  0
				END
			
			set @Relief_87A_Amount = @Relief_amount	

			-- Added By Sajid 18-03-2023 - END
		END										
			
			
			set @ED_Cess = ( @Actual_IT_Amount + @Surcharge_Amount - @Relief_amount )  * @ED_Cess_Per /100	
			
		
			set @Return_Tax_Amount = @Actual_IT_Amount - @Relief_amount
			
			SET @Return_Tax_Amount_Actual = @Actual_IT_Amount
					
			IF @UpdateTaxReport = 0
				BEGIN
					UPDATE	#Taxable_Payment_Process
					SET		NewTaxAmount = @Actual_IT_Amount,
							NewEdCessAmount = @ED_Cess,
							NewSurchargeAmount = @Surcharge_Amount,
							NewRebateAmount = @Relief_amount,
							NewTotalTaxAmount = @Actual_IT_Amount + Isnull(@ED_Cess,0) + Isnull(@Surcharge_Amount,0) - Isnull(@Relief_Amount,0)
					WHERE	Emp_ID	= @Emp_ID
				END
	RETURN


