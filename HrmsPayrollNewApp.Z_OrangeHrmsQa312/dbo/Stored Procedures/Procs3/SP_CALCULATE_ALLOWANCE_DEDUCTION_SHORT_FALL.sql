

---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_CALCULATE_ALLOWANCE_DEDUCTION_SHORT_FALL]
	@Sal_Tran_ID			NUMERIC,	-- Normal Salary Generation
	@Emp_Id					Numeric ,
	@Cmp_ID					Numeric ,
	@Increment_ID			Numeric ,
	@From_Date				Datetime,
	@To_Date				Datetime,
	@Wages_type				varchar(10),
	@Basic_Salary			Numeric(25,5),
	@Gross_Salary_ProRata	Numeric(25,5),
	@Salary_Amount			numeric(25,5),
	@Present_Days			numeric(12,1),
	@Salary_Cal_Day			numeric(18,1),
	@Tot_Salary_Day			numeric(18,1),
	@Day_Salary				numeric(12,5),
	@Branch_ID				numeric  
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	 

	DECLARE @AD_DEF_ID  NUMERIC  
	
	 
	declare @AD_ID						numeric
	declare @M_AD_Percentage			numeric(12,5)
	declare @M_AD_Amount				numeric(12,5)
	declare @M_AD_Flag					varchar(1)
	declare @Max_Upper					numeric(27,5)
	Declare @varCalc_On					varchar(50)
	Declare @Calc_On_Allow_Dedu			numeric(18,2) 
	Declare @Other_Allow_Amount			numeric(18,2)
	Declare @M_AD_Actual_Per_Amount		numeric(18,5)
	declare @Temp_Percentage	numeric(18,5)
	Declare @Type				varchar(20)
	Declare @M_AD_Tran_ID		numeric
	
	set @Calc_On_Allow_Dedu = 0.0
	SET @varCalc_On = ''
	set @Other_Allow_Amount = 0
	set @Calc_On_Allow_Dedu = 0.0
	SET @varCalc_On = ''
	
	set @M_AD_Actual_Per_Amount = 0.0
	
 
	
	Declare curAD cursor for
		select EED.AD_ID,
		Case When Qry1.Increment_ID >= EED.INCREMENT_ID /*Qry1.FOR_DATE > EED.FOR_DATE*/ Then
				Case When Qry1.E_AD_PERCENTAGE IS null Then eed.E_AD_PERCENTAGE Else Qry1.E_AD_PERCENTAGE End 
			 Else
				eed.E_AD_PERCENTAGE End As E_AD_PERCENTAGE,
			 Case When Qry1.Increment_ID >= EED.INCREMENT_ID /*Qry1.FOR_DATE > EED.FOR_DATE*/ Then
				Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End 
			 Else
				eed.e_ad_Amount End As E_Ad_Amount,
		E_AD_Flag,E_AD_Max_Limit ,AD_Calculate_On 
			From T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK)
		inner join T0050_AD_MASTER ADM  WITH (NOLOCK) on EEd.AD_ID = ADM.AD_ID 
		LEFT OUTER JOIN
				( Select EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE ,EEDR.Increment_ID, EEDR.Is_Calculate_Zero
					From T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN
					( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK)
						Where Emp_Id = @Emp_Id And For_date <= @to_date
					 Group by Ad_Id )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
				) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID  And Qry1.FOR_DATE>=EED.FOR_DATE
		where EED.emp_id = @emp_id and EED.increment_id = @Increment_Id	
			and isnull(AD_Effect_on_Short_Fall,0) = 1
		order by AD_LEVEL, E_AD_Flag desc
	open curAD		
		fetch next from curAD into @AD_ID,@M_AD_Percentage,@M_AD_Amount,@M_AD_Flag,@Max_Upper,@varCalc_On
		while @@fetch_status = 0
			begin
				
				
				If @varCalc_On ='Gross Salary'	
					set @Calc_On_Allow_Dedu = @Gross_Salary_ProRata
				Else If @varCalc_On ='Basic Salary'	
					set @Calc_On_Allow_Dedu = @Salary_Amount
				Else 
					set @Calc_On_Allow_Dedu = @Basic_Salary
				
				
				if @M_AD_Percentage > 0 
					set @M_AD_Actual_Per_Amount = @M_AD_Percentage
				else
					set @M_AD_Actual_Per_Amount = @M_AD_Amount


				set @Other_Allow_Amount = 0
				
				select @Other_Allow_Amount = isnull(sum(M_AD_amount),0)  from #Salary_AD
				where Company_ID = @Cmp_ID and Emp_ID = @Emp_ID 
				and For_Date >=@From_Date and For_Date <=@To_Date
				and Allow_Dedu_ID in 
				(select AD_ID  from T0060_EFFECT_AD_MASTER WITH (NOLOCK) where Effect_AD_ID = @AD_ID AND Cmp_ID  = @Cmp_ID )

				

				set @Calc_On_Allow_Dedu = isnull(@Calc_On_Allow_Dedu,0) + isnull(@Other_Allow_Amount ,0)

				if @M_AD_Flag = 'I'
					begin
						
						If  @M_AD_Percentage > 0
								begin									
									If upper(@varCalc_On) ='CTC'
									   BEGIN								   
												SELECT	@Calc_On_Allow_Dedu = I.CTC
												from	
												T0095_INCREMENT I  WITH (NOLOCK) inner JOIN
												(
													SELECT Max(I1.increment_Id) as Increment_Id,I1.Emp_ID
													from T0095_INCREMENT I1 WITH (NOLOCK) INNER JOIN
															(
																SELECT max(I2.Increment_Effective_Date) as Increment_Effective_Date,I2.Emp_ID 
																from T0095_INCREMENT I2 WITH (NOLOCK)
																where I2.Increment_Effective_Date <= @To_Date and I2.Cmp_ID = @cmp_Id and I2.Emp_ID = @Emp_ID
																	and I2.Increment_Type <> 'Transfer' and I2.Increment_Type <> 'Deputation'
																GROUP By I2.Emp_ID
															)Q On Q.Emp_ID = I1.Emp_ID and q.Increment_Effective_Date = I1.Increment_Effective_Date
													where  I1.Cmp_ID = @Cmp_Id and I1.Increment_Type <> 'Transfer' and I1.Increment_Type <> 'Deputation'
															and I1.Emp_ID = @Emp_ID
													GROUP By I1.Emp_ID				
												)Q1 On q1.Increment_Id = I.Increment_ID												
											
											set @M_AD_Amount = (round((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0)	* @Salary_Cal_Day)/@Tot_Salary_Day
										END
								ELSE	
									BEGIN
											if round((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0) > @Max_Upper and @Max_Upper > 0
												begin
														set @M_AD_Amount = @Max_Upper	
												end	
											else		
												begin
														set @M_AD_Amount = round((@Calc_On_Allow_Dedu * @M_AD_Percentage / 100),0)	
												end
											END				
									end	
							Else
								begin
									If upper(@varCalc_On) ='FIX'
										begin
												set @M_AD_Amount =  @M_AD_Amount
										end
									Else if @Wages_type = 'Monthly'					 
											begin
												set @M_AD_Amount =  (@M_AD_Amount * @Salary_Cal_Day)/@Tot_Salary_Day 
											end
									Else 
											begin
												set @M_AD_Amount =  @M_AD_Amount * @Salary_Cal_Day 
											end					
									End	
								end
					 
					SET @M_AD_Amount = ROUND(@M_AD_Amount,0)
					
					insert into #Salary_AD(Company_ID,Emp_ID,Allow_Dedu_ID,For_Date,M_AD_Flag,M_AD_Amount)
					select @Cmp_ID,@Emp_ID,@AD_ID,@From_Date,@M_AD_Flag,@M_AD_Amount
					                    
				fetch next from curAD into @AD_ID,@M_AD_Percentage,@M_AD_Amount,@M_AD_Flag,@Max_Upper,@varCalc_On
			end
	close curAD
	deallocate curAD
	 
	RETURN




