
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_GET_TRAVEL_SETTLEMENT_CURRENCY_AMOUNT]
	 @Cmp_ID		Numeric
	,@Curr_ID		numeric(18,0)
	,@Travel_Apr_ID	numeric(18,0)
	,@Limit_Rate_dollar	numeric(18,2)
	,@Expense_Amount numeric(18,2)	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

declare @major_curr as varchar(25)
declare @Curr_rate as numeric(18,2)
declare @CurrID_Dollar as numeric(18,0)
declare @Diff_Amount as numeric(18,2)--=0
declare @CurrRateDollar as numeric(18,2)

declare @getamnt as numeric(18,2)--=0
declare @finalamount as numeric(18,2)--=0
declare @ToDate as datetime

--changed jimit 19042016
SET @Diff_Amount = 0
SET @getamnt = 0
SET @finalamount = 0
--ended

SELECT @ToDate=max(to_date)
			FROM T0130_TRAVEL_APPROVAL_DETAIL WITH (NOLOCK)  
			where Travel_Approval_ID=@Travel_Apr_ID and Cmp_ID=@Cmp_ID

select @major_curr=Curr_Major from T0040_CURRENCY_MASTER WITH (NOLOCK) where Curr_ID=@Curr_ID and Cmp_ID=@Cmp_ID
select @CurrID_Dollar =curr_ID from T0040_CURRENCY_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Curr_Name like '%Dollar%' and Curr_Symbol like '%$%'

--select @CurrRateDollar=isnull(curr_rate,0) from T0180_CURRENCY_CONVERSION where CMP_ID=@Cmp_ID and CURR_ID=@CurrID_Dollar 
--						and FOR_DATE=(select MAX(FOR_DATE) from T0180_CURRENCY_CONVERSION where CMP_ID=@Cmp_ID and CURR_ID=@CurrID_Dollar)
						
					SELECT @CurrRateDollar=isnull(curr_rate,0) FROM T0180_CURRENCY_CONVERSION C WITH (NOLOCK)
								INNER JOIN (SELECT MAX(For_Date) AS For_Date, Curr_ID
												FROM T0180_CURRENCY_CONVERSION  WITH (NOLOCK)
												WHERE For_Date <= @ToDate AND Cmp_ID = @Cmp_ID 
												GROUP BY CURR_ID
											) Qry ON C.CURR_ID = Qry.CURR_ID AND C.FOR_DATE = Qry.For_date   
							WHERE cmp_id = @Cmp_ID and C.Curr_ID=@CurrID_Dollar and Cmp_ID=@Cmp_ID	
				IF (@CurrRateDollar is null)
					Begin
						SELECT @CurrRateDollar=isnull(curr_rate,0) FROM T0040_CURRENCY_MASTER C WITH (NOLOCK)
								WHERE cmp_id = @Cmp_ID and C.Curr_ID=@CurrID_Dollar  and Cmp_ID=@Cmp_ID	
					End		
						
if (@major_curr ='Y')
	Begin
		if (@CurrID_Dollar is not null)
			Begin
			
				--select @Curr_rate=isnull(curr_rate,0) from T0180_CURRENCY_CONVERSION where CMP_ID=@Cmp_ID and CURR_ID=@CurrID_Dollar 
				--		and FOR_DATE=(select MAX(FOR_DATE) from T0180_CURRENCY_CONVERSION where CMP_ID=@Cmp_ID and CURR_ID=@CurrID_Dollar)
				SELECT @Curr_rate=isnull(curr_rate,0) FROM T0180_CURRENCY_CONVERSION C WITH (NOLOCK)
								INNER JOIN (SELECT MAX(For_Date) AS For_Date, Curr_ID
												FROM T0180_CURRENCY_CONVERSION  WITH (NOLOCK)
												WHERE For_Date <= @ToDate AND Cmp_ID = @Cmp_ID 
												GROUP BY CURR_ID
											) Qry ON C.CURR_ID = Qry.CURR_ID AND C.FOR_DATE = Qry.For_date   
							WHERE cmp_id = @Cmp_ID and C.Curr_ID=@CurrID_Dollar  and Cmp_ID=@Cmp_ID	
				IF (@Curr_rate is null)
					Begin
						SELECT @Curr_rate=isnull(curr_rate,0) FROM T0040_CURRENCY_MASTER C WITH (NOLOCK)
								WHERE cmp_id = @Cmp_ID and C.Curr_ID=@CurrID_Dollar  and Cmp_ID=@Cmp_ID	
					End
				
				if (@Curr_rate <> 0)
					Begin	
						SET @getamnt = @Limit_Rate_dollar * @Curr_rate	
						
						set @finalamount =  @Expense_Amount - @getamnt
						--select @getamnt,@Expense_Amount,@finalamount
						set @Diff_Amount = @finalamount / @Curr_rate
						set @getamnt= @Expense_Amount / @Curr_rate
						--select @Diff_Amount= @Expense_Amount / @Curr_rate
					End		
				
			End
	End
Else
	Begin
		if (@CurrID_Dollar=@Curr_ID)
			Begin
				select @Diff_Amount=@Expense_Amount- @Limit_Rate_dollar
				set @getamnt=@Expense_Amount
			End
		Else
			Begin
				--select @Curr_rate=isnull(curr_rate,0) from T0180_CURRENCY_CONVERSION where CMP_ID=@Cmp_ID and CURR_ID=@Curr_ID
				--	and FOR_DATE=(select MAX(FOR_DATE) from T0180_CURRENCY_CONVERSION where CMP_ID=@Cmp_ID and CURR_ID=@Curr_ID)
				SELECT @Curr_rate=isnull(curr_rate,0) FROM T0180_CURRENCY_CONVERSION C WITH (NOLOCK)
								INNER JOIN (SELECT MAX(For_Date) AS For_Date, Curr_ID
												FROM T0180_CURRENCY_CONVERSION  WITH (NOLOCK)
												WHERE For_Date <= @ToDate AND Cmp_ID = @Cmp_ID 
												GROUP BY CURR_ID
											) Qry ON C.CURR_ID = Qry.CURR_ID AND C.FOR_DATE = Qry.For_date   
							WHERE cmp_id = @Cmp_ID and C.Curr_ID=@Curr_ID  and Cmp_ID=@Cmp_ID	
				
				
					if (@Curr_rate is not null or @Curr_rate <>0 )
						Begin
							SET @getamnt= @Curr_rate * @Expense_Amount	
												
							if (@getamnt <> 0 or @getamnt is not null)
								Begin
									select @finalamount= @CurrRateDollar * @Limit_Rate_dollar
																	
									set @finalamount = @getamnt-@finalamount
									
									if (@finalamount<>0 or @finalamount is not null)
										Begin
											--set @finalamount= @finalamount / @CurrRateDollar										
											
											set @Diff_Amount = @finalamount / @CurrRateDollar		
											--SELECT @getamnt,	@finalamount								
											set @getamnt= @getamnt / @CurrRateDollar
											--SELECT @getamnt
										End
								End
						End
			End	
	End	
select @Diff_Amount	as Diff_Amount,isnull(@getamnt,0) as Dollar_Amount,isnull(@CurrRateDollar,0) as CurrRateDollar
RETURN 


