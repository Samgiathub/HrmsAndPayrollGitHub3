
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_GET_CURRENCY_AMOUNT]
	 @Cmp_ID		Numeric
	,@Travel_Apr_ID	numeric(18,0)
	,@DDL_ForDate datetime
	,@Curr_ID		numeric(18,0)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
--declare @major_curr as varchar(25)
declare @Curr_rate as numeric(18,2)
declare @ToDate as datetime
declare @Curr_Major as varchar(10)

SELECT @ToDate=max(to_date)
			FROM T0130_TRAVEL_APPROVAL_DETAIL WITH (NOLOCK) 
			where Travel_Approval_ID=@Travel_Apr_ID and Cmp_ID=@Cmp_ID
			
if (@Travel_Apr_ID=0)
	Begin
		set @ToDate=@DDL_ForDate;
	End
--select isnull(Curr_Rate,0) as Curr_Rate from T0180_CURRENCY_CONVERSION where CMP_ID=@Cmp_ID and Curr_ID=@Curr_ID 
--and FOR_DATE >= @DDL_ForDate and FOR_DATE <= @ToDate

--select Inc_Qry.Curr_Rate from T0140_Travel_Settlement_Expense T 
--INNER JOIN (
SELECT @Curr_rate=isnull(Curr_Rate,0) FROM T0180_CURRENCY_CONVERSION C WITH (NOLOCK)
								INNER JOIN (SELECT MAX(For_Date) AS For_Date, Curr_ID
												FROM T0180_CURRENCY_CONVERSION  WITH (NOLOCK)
												WHERE For_Date <= @ToDate AND Cmp_ID = @Cmp_ID 
												GROUP BY CURR_ID
											) Qry ON C.CURR_ID = Qry.CURR_ID AND C.FOR_DATE = Qry.For_date   
							WHERE cmp_id = @Cmp_ID and C.Curr_ID=@Curr_ID and Cmp_ID=@Cmp_ID
						--) Inc_Qry ON T.Curr_ID = Inc_Qry.CURR_ID 
select @Curr_Major=	isnull(Curr_Major,'') FROM T0040_CURRENCY_MASTER C WITH (NOLOCK)
							WHERE cmp_id = @Cmp_ID and C.Curr_ID=@Curr_ID and Cmp_ID=@Cmp_ID
	
	if (@Curr_rate is null)
		Begin
		select @Curr_rate=isnull(Curr_Rate,0) FROM T0040_CURRENCY_MASTER C WITH (NOLOCK)
							WHERE cmp_id = @Cmp_ID and C.Curr_ID=@Curr_ID and Cmp_ID=@Cmp_ID
		End
--where 

select @Curr_rate as Curr_Rate,@Curr_Major as Curr_Major



RETURN 


