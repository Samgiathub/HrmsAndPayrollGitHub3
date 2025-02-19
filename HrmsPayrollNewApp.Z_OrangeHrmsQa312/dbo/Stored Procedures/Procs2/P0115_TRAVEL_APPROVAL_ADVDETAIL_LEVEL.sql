

-- =============================================
-- Author:		<Ankit>
-- ALTER date: <20062014>
-- Description:	<Description,,>
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================

CREATE PROCEDURE [dbo].[P0115_TRAVEL_APPROVAL_ADVDETAIL_LEVEL]
	 @Row_Adv_ID					Numeric(18,0)
	,@Travel_App_ID					Numeric(18,0)	
	,@Tran_ID						Numeric(18,0)	
	,@Cmp_ID						Numeric(18,0)
	,@Expence_Type					Varchar(100)
	,@Amount						Numeric(18,2)
	,@Adv_Detail_Desc				Nvarchar(250)
	,@Curr_ID						numeric(18,0)=0
	,@Tran_Type						Char(1) 
AS

BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	declare @ToDate as datetime
	declare @Dlr_Amnt as numeric(18,2)
SELECT @ToDate=max(to_date)
			FROM T0115_TRAVEL_APPROVAL_DETAIL_LEVEL  WITH (NOLOCK)
			where Travel_Application_Id=@Travel_App_ID and Cmp_ID=@Cmp_ID --and Tran_ID=@Tran_ID
			
			--select @ToDate
	if (@Curr_ID=0)
		Begin
			set @Curr_ID=null;
			set @Dlr_Amnt=null;
		End
	Else
		Begin
		declare @Cur_Amnt as numeric(18,2)
		--select @Cur_Amnt= CC.CURR_RATE from T0180_CURRENCY_CONVERSION CC inner join T0040_CURRENCY_MASTER CM on CC.CURR_ID=CM.Curr_ID and CC.CMP_ID =Cm.Cmp_ID where CC.CURR_ID=@Curr_ID 
		--					and CC.CMP_ID=@Cmp_ID and Curr_Major<>'Y' and FOR_DATE
		--					=(select MAX(FOR_DATE) from T0180_CURRENCY_CONVERSION where CURR_ID=@Curr_ID and CMP_ID=@Cmp_ID)
		SELECT @Cur_Amnt= C.CURR_RATE FROM T0180_CURRENCY_CONVERSION C WITH (NOLOCK)
								INNER JOIN (SELECT MAX(For_Date) AS For_Date, Curr_ID
												FROM T0180_CURRENCY_CONVERSION  WITH (NOLOCK)
												WHERE For_Date <= @ToDate AND Cmp_ID = @Cmp_ID 
												GROUP BY CURR_ID
											) Qry ON C.CURR_ID = Qry.CURR_ID AND C.FOR_DATE = Qry.For_date   
											inner join T0040_CURRENCY_MASTER Cm WITH (NOLOCK) on Cm.Curr_ID=C.CURR_ID and Cm.Cmp_ID=C.CMP_ID
							WHERE C.cmp_id = @Cmp_ID and C.Curr_ID=@Curr_ID and C.CMP_ID=@Cmp_ID and Curr_Major<>'Y'					
			
			if (@Cur_Amnt is not null)
				Begin
					set @Dlr_Amnt=@Amount
					set @Amount=@Amount * @Cur_Amnt
				End	
			Else
				Begin
					set @Dlr_Amnt=null;
				End		
		End --Added by Sumit 15102015
	
	
	SELECT @Cmp_ID = Cmp_ID FROM T0115_TRAVEL_LEVEL_APPROVAL WITH (NOLOCK) WHERE Tran_ID = @Tran_ID 
	
	If UPPER(@Tran_Type) = 'I'
		Begin
		
			Select @Row_Adv_ID = ISNULL(MAX(Row_Adv_ID),0) + 1 From T0115_TRAVEL_APPROVAL_ADVDETAIL_LEVEL WITH (NOLOCK)
			
			Insert Into T0115_TRAVEL_APPROVAL_ADVDETAIL_LEVEL
					(Tran_Id, Cmp_ID, Row_Adv_ID, Expence_Type, Amount, Adv_Detail_Desc,Travel_App_ID,Curr_ID,Amount_dollar)
			values (@Tran_ID, @Cmp_ID, @Row_Adv_ID, @Expence_Type, @Amount, @Adv_Detail_Desc,@Travel_App_ID,@Curr_ID,@Dlr_Amnt)
		End
		--select @Tran_ID, @Cmp_ID, @Row_Adv_ID, @Expence_Type, @Amount, @Adv_Detail_Desc,@Travel_App_ID,@Curr_ID,@Dlr_Amnt
END

