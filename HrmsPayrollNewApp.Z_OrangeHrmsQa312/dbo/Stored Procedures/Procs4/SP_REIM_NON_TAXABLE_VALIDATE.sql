

---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_REIM_NON_TAXABLE_VALIDATE]
	@CMP_ID		NUMERIC ,
	@EMP_ID		NUMERIC ,
	@RC_ID	NUMERIC,
	@For_date datetime
	

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @Grd_ID numeric
	declare @Date_of_join as datetime
	Declare @Increment_ID numeric	
	Declare @Non_Taxable numeric(18,2)
	declare @Total_Paid_Amount numeric(18,2) 
	SET @Total_Paid_Amount = 0.0
	declare @StartDate as datetime
	declare @EndDate as datetime
	declare @Ad_Cal_type as varchar(255)
	declare @Auto_Paid as numeric
	declare @Leave_Negative as numeric

	Declare @Total_Taxable_Amount numeric(18,2) --Added by Hardik 16/03/2016
	Set @Total_Taxable_Amount = 0 --Added by Hardik 16/03/2016
	
	
	SELECT @Ad_Cal_type=AD_CAL_TYPE,@Auto_Paid =Auto_Paid,@Leave_Negative=isnull(Negative_Balance,0) FROM T0050_AD_MASTER WITH (NOLOCK) WHERE CMP_ID=@Cmp_Id and AD_ID=@RC_ID
	
	SET @StartDate = DATEADD(dd,0, DATEDIFF(dd,0, DATEADD( mm, -(((12 + DATEPART(m, @for_Date)) - 4)%12), @for_Date ) - datePart(d,DATEADD( mm, -(((12 + DATEPART(m, @for_Date)) - 4)%12),@for_Date ))+1 ) )
    SET @EndDate = DATEADD(ss,-1,DATEADD(mm,12,@StartDate ))

	select @Date_of_join=Date_Of_Join from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@emp_ID and Cmp_ID=@Cmp_ID

			select @Increment_Id = I.Increment_Id,@Grd_ID=I.Grd_ID from T0095_Increment I WITH (NOLOCK) inner join 
				(Select Max(I.Increment_ID) As Increment_Id, I.Emp_ID from T0095_INCREMENT I WITH (NOLOCK) Inner Join
					( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @For_date
					and Cmp_ID = @Cmp_ID and Emp_ID=@EMP_ID
					group by emp_ID  ) Qry on I.Increment_Effective_Date = Qry.For_Date And I.Emp_ID = Qry.Emp_ID
				GROUP By I.Emp_ID) Qry1 on I.Emp_ID = Qry1.Emp_ID	and I.Increment_ID = Qry1.Increment_Id
			Where Cmp_ID = @Cmp_ID 

			
		
			declare @Total_Paid_Amount_1 as numeric(18,2)
			
			select @Total_Paid_Amount_1=isnull(sum(I.reim_closing),0) from T0140_ReimClaim_Transacation I WITH (NOLOCK) inner join 
					( select max(For_Date) as For_Date , Emp_ID,rc_ID from T0140_ReimClaim_Transacation WITH (NOLOCK)
					where For_Date >= @StartDate and For_Date <=@For_date
					and Cmp_ID = @Cmp_ID and Emp_ID=@EMP_ID and rc_ID=@RC_ID
					group by emp_ID,rc_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.For_Date = Qry.For_Date and I.rc_ID = Qry.rc_ID
			Where Cmp_ID = @Cmp_ID
			
			
		  
			--Added By Ripal 04July2014 Start			
			--select @Total_Paid_Amount=isnull(sum(RCA.Apr_Amount),0) 
			--	from T0140_ReimClaim_Transacation I inner join
			--			T0120_RC_Approval RCA On RCA.RC_APR_ID = I.RC_apr_ID
			--	Where I.For_Date >= @StartDate and I.For_Date <=@For_date
			--			and I.Cmp_ID = @Cmp_ID and I.Emp_ID=@EMP_ID and RCA.RC_ID = @RC_ID
	
						
			select @Total_Paid_Amount= @Total_Paid_Amount + isnull(sum(MRD.Tax_Free_amount),0) ,@Total_Taxable_Amount= isnull(sum(MRD.Taxable),0)  --Taxable Amount added by Hardik 16/03/2016
				from T0210_monthly_Reim_Detail MRD WITH (NOLOCK)
				Where For_Date >= @StartDate and For_Date <=@For_date
						and Cmp_ID = @Cmp_ID and Emp_ID=@EMP_ID and MRD.RC_ID = @RC_ID --AND MRD.Sal_tran_ID IS NOT NULL  --Change on 18Sep2014	-- MRD.Sal_tran_ID IS NOT NULL --Ankit After Discuss with hardikbhai	For Not Eff Salary get double value
			--Added By Ripal 04July2014 End  
					
					
			
		    select 
		    @Non_Taxable = 
				((isnull(AD_NON_TAX_LIMIT,0))/12)  *  case when DATEDIFF(MONTH, @Date_of_join, @EndDate) + 1 < 12 then DATEDIFF(MONTH, @Date_of_join, @EndDate) + 1 else 12 end--Condition Chnaged by sumit 06032015
		    from T0120_GRADEWISE_ALLOWANCE WITH (NOLOCK) where Grd_ID=@Grd_ID and Ad_ID=@RC_ID and cmp_ID=@cmp_ID		    		   
			
		----Hardik 11/03/2016-----
			DECLARE @Earn_Amount numeric(18,4)
			Declare @Max_Sal_Months numeric
			Declare @Month_Sal_generated numeric
			Declare @Month_Diff numeric
			Declare @Month_Max_Date datetime
			Declare @Acutal_Earning_Amount Numeric(18,2)
			DECLARE @temp_date AS DATETIME
			Declare @Month_Count Numeric
			DECLARE @Total_Eligible_Amount_Yearly Numeric(18,2)
			Declare @Assume_Amount numeric(18,2)
			Declare @AD_DEF_ID as numeric
			DECLARE @Actual_Tax_Free_Limit as numeric(18,2)
			DECLARE @Tax_Free_Amount_Grade_Wise as numeric(18,2)
			DECLARE @Negative_Balance tinyint
			Declare @Setting_Value tinyint
			Declare @Eligible_Amount_Yearly as numeric(18,2)
			
			Set @Assume_Amount = 0
			Set @Month_Sal_generated = 0 
			Set @Acutal_Earning_Amount =0
			Set @Actual_Tax_Free_Limit =0
			Set @Total_Eligible_Amount_Yearly = 0
			Set @Tax_Free_Amount_Grade_Wise = 0
			Set @Negative_Balance = 0
			Set @Setting_Value = 0
			Set @Eligible_Amount_Yearly = 0
						
			Select @AD_DEF_ID = AD_DEF_ID, @Negative_Balance = Negative_Balance  From T0050_AD_MASTER WITH (NOLOCK) Where Cmp_Id=@Cmp_Id And AD_ID = @RC_Id
			
			Select @Setting_Value = Isnull(Setting_Value,0) From T0040_SETTING WITH (NOLOCK) Where Setting_Name = 'Restrict Reim. Application Amount on Yearly Prorata Limit' And Cmp_ID = @Cmp_Id
			--If @Negative_Balance = 1 And @Setting_Value = 1
			--	BEGIN
					--If @AD_DEF_ID <> 8 -- 8 for LTA Reimbursement
					--	BEGIN
					--		SET @StartDate = DATEADD(dd,0, DATEDIFF(dd,0, DATEADD( mm, -(((24 + DATEPART(m, @for_Date)) - 4)%24), @for_Date ) - datePart(d,DATEADD( mm, -(((24 + DATEPART(m, @for_Date)) - 4)%24),@for_Date ))+1 ) )
					--		SET @EndDate = DATEADD(ss,-1,DATEADD(mm,24,@StartDate ))
					--	END
						
					--select @StartDate,@EndDate
					--return
					
					SELECT @Month_Sal_generated = ISNULL(COUNT(emp_ID),0) 
						FROM T0200_Monthly_Salary WITH (NOLOCK)
					WHERE Emp_ID=@emp_ID AND Month_End_Date >=@StartDate AND Month_End_Date <=@EndDate
					
					SELECT @Month_Max_Date = MAX(Month_End_Date) 
						FROM T0200_Monthly_Salary WITH (NOLOCK)
					WHERE Emp_ID=@emp_ID AND Month_End_Date >=@StartDate AND Month_End_Date <=@EndDate

					SELECT @Acutal_Earning_Amount = Isnull(SUM(M_AD_Amount),0)
						FROM T0210_MONTHLY_AD_DETAIL WITH (NOLOCK)
					WHERE Emp_ID=@emp_ID AND For_Date >=@StartDate AND To_date <=@EndDate And AD_ID=@RC_Id
					
					IF @StartDate < @Date_of_join AND ISNULL(@Month_Max_Date,@StartDate) = @StartDate
						SET @Month_Max_Date = ISNULL(@Month_Max_Date,@Date_of_join)
					ELSE IF	ISNULL(@Month_Max_Date,@StartDate) = @StartDate
						SET @Month_Max_Date = ISNULL(@Month_Max_Date,@StartDate)

					IF @StartDate < @Date_of_join  
						SET @temp_date = @Date_of_join
					ELSE 
						SET @temp_date = @StartDate

					IF @Month_Max_Date = @Date_of_join OR @Month_Max_Date = @StartDate
						BEGIN
							SET	@Max_Sal_Months = DATEDIFF(mm,@temp_date ,@Month_Max_Date) 				
						END
					ELSE
						BEGIN
							SET @Max_Sal_Months = DATEDIFF(mm,@temp_date ,@Month_Max_Date) + 1
						END

					Set @Month_Count = DATEDIFF(mm,@temp_date,@EndDate)+1
					
					If @Month_Count - @Month_Sal_generated > 0 
						SET @Month_Diff = @Month_Count  - @Month_Sal_generated
					ELSE
						SET @Month_Diff =0
					 
					If @Month_Diff > 0
						BEGIN
							SELECT @Earn_Amount = EED.E_AD_AMOUNT From T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) Where EED.INCREMENT_ID = @Increment_ID And EED.AD_ID = @RC_Id
							Set @Assume_Amount = @Earn_Amount * @Month_Diff
						End
				
					Set @Total_Eligible_Amount_Yearly = (Isnull(@Acutal_Earning_Amount,0) + Isnull(@Assume_Amount,0)) 
					Set @Actual_Tax_Free_Limit = @Total_Eligible_Amount_Yearly - isnull(@Total_Paid_Amount,0) - ISNULL(@Total_Taxable_Amount,0)
					
					If  @Actual_Tax_Free_Limit < 0
						Set @Actual_Tax_Free_Limit = 0
					--Set @Eligible_Amount_Yearly = @Total_Eligible_Amount_Yearly
				--END
			
			--select @Earn_Amount,@Increment_ID,@Month_Sal_generated,@Month_Max_Date,@Acutal_Earning_Amount,@Max_Sal_Months,@Month_Diff,@Eligible_Amount_Yearly
		--End Hardik 11/03/2016----
			Set @Tax_Free_Amount_Grade_Wise = isnull(@Non_Taxable,0) - isnull(@Total_Paid_Amount,0)
		
			If @Negative_Balance = 1 And @Setting_Value = 1 And @AD_DEF_ID <> 8 --8 for LTA
				BEGIN
					select Case When @Actual_Tax_Free_Limit < @Tax_Free_Amount_Grade_Wise Then @Actual_Tax_Free_Limit Else @Tax_Free_Amount_Grade_Wise End as Tax_Free_amount,
						   @Leave_Negative as Negative_Balance, @Total_Paid_Amount_1 as Total_balance,
						   @Total_Eligible_Amount_Yearly as Eligible_Amount_Yearly, @Actual_Tax_Free_Limit as Pending_Claim_Amount  --Added by Hardik 12/03/2016
						   ,@Setting_Value as Setting_value --Mukti(19042016)
				END
			Else
				BEGIN
					select @Tax_Free_Amount_Grade_Wise as Tax_Free_amount,
						   @Leave_Negative as Negative_Balance, @Total_Paid_Amount_1 as Total_balance,
						   @Total_Eligible_Amount_Yearly as Eligible_Amount_Yearly, @Actual_Tax_Free_Limit as Pending_Claim_Amount  --Added by Hardik 12/03/2016
						   ,@Setting_Value as Setting_value --Mukti(19042016)
				end 				   
							   
			
			
	RETURN


