CREATE  PROCEDURE [dbo].[Mobile_HRMS_P0130_TRAVEL_APPROVAL_ADVDETAIL]
	 @Row_Adv_ID					Numeric(18,0)
	,@Travel_App_ID					Numeric(18,0)
	,@Cmp_ID						Numeric(18,0)
	,@Tran_ID						Numeric(18,0)	
	,@Tran_Type						Char(1) 
	,@Travel_Adv_Details			XML = ''
	,@Travel_Approval_ID			Numeric(18,0)
	,@Travel_Approval_AdvDetail_ID  Numeric(18,0)
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	DECLARE @Expence_Type varchar(60)
	DECLARE @Amount Numeric(18,0)
	DECLARE @Adv_Detail_Desc varchar(500)
	DECLARE @Curr_ID Numeric(18,0)



	DECLARE @ToDate as datetime
	DECLARE @Dlr_Amnt as numeric(18,2)
			
			SELECT @ToDate=max(to_date)
			FROM T0115_TRAVEL_APPROVAL_DETAIL_LEVEL  WITH (NOLOCK)
			where Travel_Application_Id=@Travel_App_ID and Cmp_ID=@Cmp_ID 

	IF (@Curr_ID=0)
		Begin
			set @Curr_ID=null;
			set @Dlr_Amnt=null;
		End
	Else
		Begin
			DECLARE @Cur_Amnt as numeric(18,2)

			SELECT @Cur_Amnt= C.CURR_RATE FROM T0180_CURRENCY_CONVERSION C WITH (NOLOCK)
								INNER JOIN (SELECT MAX(For_Date) AS For_Date, Curr_ID
												FROM T0180_CURRENCY_CONVERSION  WITH (NOLOCK)
												WHERE For_Date <= @ToDate AND Cmp_ID = @Cmp_ID 
												GROUP BY CURR_ID
											) Qry ON C.CURR_ID = Qry.CURR_ID AND C.FOR_DATE = Qry.For_date   
											inner join T0040_CURRENCY_MASTER Cm WITH (NOLOCK) on Cm.Curr_ID=C.CURR_ID and Cm.Cmp_ID=C.CMP_ID
							WHERE C.cmp_id = @Cmp_ID and C.Curr_ID=@Curr_ID and C.CMP_ID=@Cmp_ID and Curr_Major<>'Y'					
			
			IF (@Cur_Amnt is not null)
				Begin
					set @Dlr_Amnt=@Amount
					set @Amount=@Amount * @Cur_Amnt
				End	
			Else
				Begin
					set @Dlr_Amnt=null;
				End		
		End 

			SELECT @Cmp_ID = Cmp_ID FROM T0115_TRAVEL_LEVEL_APPROVAL WITH (NOLOCK) WHERE Tran_ID = @Tran_ID 

	

	 IF UPPER(@Tran_Type) = 'I' OR UPPER(@Tran_Type) = 'U'
	 BEGIN
		
		IF (@Travel_Adv_Details.exist('/NewDataSet/TravelAdvanceDetails') = 1)
		 BEGIN
			SELECT
			(ROW_NUMBER() OVER(ORDER BY Table3.value('(Travel_Advance_Detail_ID/text())[1]','NUMERIC(18,0)'))) AS Rownum,
			 Table3.value('(Travel_Advance_Detail_ID/text())[1]','NUMERIC(18,0)') AS Row_Adv_ID,
			 Table3.value('(Expence_Type/text())[1]','VARCHAR(60)') AS Expence_Type,
			 Table3.value('(Amount/text())[1]','NUMERIC(18,0)') AS Amount,
			 Table3.value('(Adv_Detail_Desc/text())[1]','VARCHAR(600)') AS Adv_Detail_Desc,
			 Table3.value('(Curr_ID/text())[1]','NUMERIC(18,0)') AS Curr_ID
			 INTO #MyTeamDetailsTemp3 FROM @Travel_Adv_Details.nodes('/NewDataSet/TravelAdvanceDetails') AS Temp(Table3)

			 DECLARE @COUNT int = 1
			 
			 SELECT @COUNT = count(Row_Adv_ID) FROM #MyTeamDetailsTemp3  

			 WHILE(@COUNT > 0)
				BEGIN
					  SELECT top(1)
						   @Row_Adv_ID = ISnull(Row_Adv_ID,0),
						   @Expence_Type = Expence_Type
						  ,@Amount = Amount,@Adv_Detail_Desc = Adv_Detail_Desc,@Curr_ID = Curr_ID
						   FROM #MyTeamDetailsTemp3
						   WHERE Rownum = @COUNT			
	
				Select @Travel_Approval_AdvDetail_ID = ISNULL(MAX(Travel_Approval_AdvDetail_ID),0) + 1 From T0130_TRAVEL_APPROVAL_ADVDETAIL WITH (NOLOCK)

					If Not Exists(select 1 from T0130_TRAVEL_APPROVAL_ADVDETAIL WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Travel_Approval_ID=@Travel_Approval_ID and Expence_Type=@Expence_Type and Amount=@Amount)
					Begin
						Insert Into T0130_TRAVEL_APPROVAL_ADVDETAIL
								(Travel_Approval_AdvDetail_ID, Cmp_ID, Travel_Approval_ID, Expence_Type, Amount, Adv_Detail_Desc,Curr_ID,Amount_dollar)
							Values (@Travel_Approval_AdvDetail_ID, @Cmp_ID, @Travel_Approval_ID, @Expence_Type, @Amount, @Adv_Detail_Desc,@Curr_ID,@Dlr_Amnt)
				
					End
			
					SET @COUNT = @COUNT - 1 

		 	
				END
		 END
	 END
END



