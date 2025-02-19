
CREATE PROCEDURE [dbo].[Mobile_HRMS_TRAVEL_ADVANCE_DETAIL]
	 @Cmp_ID					Numeric(18,0)
	,@Travel_App_ID				Numeric(18,0)
	,@Tran_Type					Char(1) 
	,@Travel_Adv_Details		XML
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	DECLARE @Travel_Advance_Detail_ID Numeric(18,0)
	DECLARE @Expence_Type varchar(60)
	DECLARE @Amount Numeric(18,0)
	DECLARE @Adv_Detail_Desc varchar(500)
	DECLARE @Curr_ID Numeric(18,0)


		If (UPPER(@Tran_Type) = 'I' or UPPER(@Tran_Type) = 'U' or UPPER(@Tran_Type) = 'M')
		Begin
			IF (@Travel_Adv_Details.exist('/NewDataSet/TravelAdvanceDetails') = 1)
			BEGIN
				SELECT
				(ROW_NUMBER() OVER(ORDER BY Table3.value('(Travel_Advance_Detail_ID/text())[1]','NUMERIC(18,0)'))) AS Rownum,
				 Table3.value('(Travel_Advance_Detail_ID/text())[1]','NUMERIC(18,0)') AS Travel_Adv_Det_ID,
				 Table3.value('(Expence_Type/text())[1]','VARCHAR(60)') AS Expence_Type,
				 Table3.value('(Amount/text())[1]','NUMERIC(18,0)') AS Amount,
				 Table3.value('(Adv_Detail_Desc/text())[1]','VARCHAR(600)') AS Adv_Detail_Desc,
				 Table3.value('(Curr_ID/text())[1]','NUMERIC(18,0)') AS Curr_ID
				 INTO #MyTeamDetailsTemp3 FROM @Travel_Adv_Details.nodes('/NewDataSet/TravelAdvanceDetails') AS Temp(Table3)
				
				DECLARE @COUNT int = 1

				SELECT @COUNT = count(Travel_Adv_Det_ID) FROM #MyTeamDetailsTemp3  

				Declare @Cnt as int = 0

				WHILE(@Cnt < @COUNT)
					BEGIN
						SET @Cnt = @Cnt + 1

						SELECT top(1)
						@Travel_Advance_Detail_ID = ISnull(Travel_Adv_Det_ID,0),
						@Expence_Type = Expence_Type, @Adv_Detail_Desc= Adv_Detail_Desc,
						@Amount=Amount,@Curr_ID = Curr_ID FROM #MyTeamDetailsTemp3
						where Rownum = @Cnt
									
	         			SELECT @Travel_Advance_Detail_ID = ISNULL(MAX(Travel_Advance_Detail_ID),0) + 1 FROM T0110_TRAVEL_ADVANCE_DETAIL WITH (NOLOCK)

							IF not exists(SELECT Travel_Advance_Detail_ID FROM T0110_TRAVEL_ADVANCE_DETAIL WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID AND 
											 Expence_Type=@Expence_Type and Amount=@Amount and Travel_App_ID=@Travel_App_ID)
		 		  			BEGIN
								INSERT INTO T0110_TRAVEL_ADVANCE_DETAIL
									(Travel_Advance_Detail_ID, Cmp_ID, Travel_App_ID, Expence_Type, Amount, Adv_Detail_Desc,Curr_ID)
								VALUES 
									(@Travel_Advance_Detail_ID, @Cmp_ID, @Travel_App_ID, @Expence_Type, @Amount, @Adv_Detail_Desc,@Curr_ID)
							END
			
					END 
			END
		END
END




			


