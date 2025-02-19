
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
 
CREATE PROCEDURE [dbo].[MP0100_TRAVEL_APPLICATION]  
	@Cmp_ID NUMERIC(18,0),
	@Emp_ID NUMERIC(18,0),
	@Login_ID NUMERIC(18,0),
	@Chk_Adv int,
	@Chk_Other int,
	@Attached_Doc_File VARCHAR(MAX),
	@TravelDetail XML,
	@OtherDetail XML,
	@ExpDetail XML,
	@Result VARCHAR(100) OUTPUT
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

DECLARE @Travel_Application_ID NUMERIC(18,0)  
DECLARE @S_Emp_ID NUMERIC(18,0)
DECLARE @State_ID NUMERIC(18,0)
DECLARE @City_ID NUMERIC(18,0)
DECLARE @Application_Date DATETIME
DECLARE @Place_Of_Visit VARCHAR(100)
DECLARE @Travel_Purpose VARCHAR(MAX)
DECLARE @Instruct_Emp_ID NUMERIC(18,0)
DECLARE @Travel_Mode_ID NUMERIC(18,0) 
DECLARE @For_Date DATETIME
DECLARE @From_Date DATETIME
DECLARE @To_Date DATETIME
DECLARE @Period NUMERIC(18,2)
DECLARE @Remarks VARCHAR(MAX)
DECLARE @Description VARCHAR(MAX)
DECLARE @OtherAmount NUMERIC(18,2)
DECLARE @Selfpay int
DECLARE @From_Date1 varchar(11)
DECLARE @To_Date1 varchar(11)
DECLARE @Expence_Type VARCHAR(100)
DECLARE @Amount NUMERIC(18,2)
DECLARE @Adv_Detail_Desc VARCHAR(MAX)

SET @Travel_Mode_ID = 0
SET @Travel_Application_ID = 0

SET @S_Emp_ID = (SELECT Emp_Superior FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @Emp_ID )
SET @Application_Date = (Select CAST(GETDATE() AS varchar(11)))

BEGIN TRY

	EXEC P0100_TRAVEL_APPLICATION @Travel_Application_ID OUTPUT,@Cmp_ID,@Emp_ID,@S_Emp_ID,@Application_Date,'System generate','P',@Login_ID,@Chk_Adv,0,'','','',@Attached_Doc_File,'Insert'


	--SELECT @Travel_Application_ID = Travel_Application_ID FROM T0100_TRAVEL_APPLICATION WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID --AND S_Emp_ID = @S_Emp_ID 
	 
	SELECT Table1.value('(StateName/text())[1]','varchar(100)') AS StateName,
	Table1.value('(StateId/text())[1]','numeric(18,0)') AS StateId,
	Table1.value('(CityName/text())[1]','varchar(100)') AS CityName,
	Table1.value('(CityId/text())[1]','numeric(18,0)') AS CityId,
	Table1.value('(PlaceName/text())[1]','varchar(100)') AS Place_Of_Visit,
	CONVERT(datetime, Table1.value('(Fromdate/text())[1]','varchar(11)'),103) AS FromDate,
	Table1.value('(Period/text())[1]','numeric(18,2)') AS Period,
	CONVERT(datetime, Table1.value('(Todate/text())[1]','varchar(11)'),103) AS ToDate,
	Table1.value('(Purpose/text())[1]','varchar(100)') AS Purpose
    INTO #TravelDetailTemp FROM @TravelDetail.nodes('/NewDataSet/Table1') AS Temp(Table1)

    DECLARE TravelDetail_CURSOR CURSOR  FAST_FORWARD FOR
    SELECT StateId,CityId,Place_Of_Visit,FromDate,Period,ToDate ,Purpose FROM #TravelDetailTemp
    OPEN TravelDetail_CURSOR
    FETCH NEXT FROM TravelDetail_CURSOR INTO @State_ID,@City_ID,@Place_Of_Visit,@From_Date ,@Period,@To_Date ,@Travel_Purpose
	WHILE @@FETCH_STATUS = 0
		BEGIN
		
			EXEC P0110_TRAVEL_APPLICATION_DETAIL @Travel_App_Detail_ID=0,@Cmp_ID=@Cmp_ID,@Travel_App_ID=@Travel_Application_ID,@Place_Of_Visit=@Place_Of_Visit,@Travel_Purpose=@Travel_Purpose,@Instruct_Emp_ID=@Instruct_Emp_ID,@Travel_Mode_ID=@Travel_Mode_ID,@From_Date=@From_Date,@Period=@Period,@To_Date=@To_Date,@Remarks=@Remarks,@State_ID=@State_ID,@City_ID=@City_ID,@Loc_ID=0,@Project_ID=0,@Tran_Type='I',@User_Id=0,@IP_Address=''
			 
			FETCH NEXT FROM TravelDetail_CURSOR INTO @State_ID,@City_ID,@Place_Of_Visit,@From_Date ,@Period,@To_Date ,@Travel_Purpose
		END
    CLOSE TravelDetail_CURSOR
    DEALLOCATE TravelDetail_CURSOR
    
    
            
    IF @Chk_Other = 1
		BEGIN
			SELECT Table1.value('(Travel_Mode_ID/text())[1]','numeric(18,0)') AS Travel_Mode_ID,
			Table1.value('(Travel_Mode/text())[1]','varchar(50)') AS Travel_Mode,
			CONVERT(datetime, Table1.value('(Date/text())[1]','varchar(50)'),103) AS ForDate,
			ISNULL(Table1.value('(Amount/text())[1]','numeric(18,2)'),0) AS Amount,
			Table1.value('(Self_Pay/text())[1]','int') AS Self_Pay,
			Table1.value('(Description/text())[1]','varchar(MAX)') AS Description
			INTO #TravelOtherDetailTemp FROM @OtherDetail.nodes('/NewDataSet/Table1') AS Temp(Table1)  
    
			DECLARE TravelOtherDetail_CURSOR CURSOR  FAST_FORWARD FOR
			SELECT Travel_Mode_ID,ForDate,Description,Amount,Self_Pay FROM #TravelOtherDetailTemp
			OPEN TravelOtherDetail_CURSOR
			FETCH NEXT FROM TravelOtherDetail_CURSOR INTO @Travel_Mode_ID,@For_Date,@Description,@OtherAmount,@Selfpay
			WHILE @@FETCH_STATUS = 0
				BEGIN
					EXEC P0110_TRAVEL_APPLICATION_OTHER_DETAIL @Travel_App_Other_Detail_Id=0,@Cmp_ID=@Cmp_ID,@Travel_App_ID=@Travel_Application_ID,@Travel_Mode_Id=@Travel_Mode_ID,@For_date=@For_Date,@Description=@Description,@Amount=@OtherAmount,@Self_Pay=@Selfpay,@Tran_Type = 'I',@To_Date=@To_Date,@Curr_ID=0
					
					FETCH NEXT FROM TravelOtherDetail_CURSOR INTO @Travel_Mode_ID,@For_Date,@Description,@OtherAmount,@Selfpay
				END
			CLOSE TravelOtherDetail_CURSOR
			DEALLOCATE TravelOtherDetail_CURSOR
		END
     
    
	IF @Chk_Adv = 1
		BEGIN
			SELECT Table1.value('(ExpenceType/text())[1]','varchar(100)') AS ExpenceType,
			ISNULL(Table1.value('(Amount/text())[1]','numeric(18,2)'),0) AS Amount,
			Table1.value('(Remarks/text())[1]','varchar(MAX)') AS Remarks
			INTO #TravelAdvDetailTemp FROM @ExpDetail.nodes('/NewDataSet/Table1') AS Temp(Table1)  
    
    
			DECLARE TravelAdvDetail_CURSOR CURSOR FAST_FORWARD FOR
			SELECT ExpenceType,Amount,Remarks FROM #TravelAdvDetailTemp
			OPEN TravelAdvDetail_CURSOR
			FETCH NEXT FROM TravelAdvDetail_CURSOR INTO @Expence_Type,@Amount,@Adv_Detail_Desc
			WHILE @@FETCH_STATUS = 0
				BEGIN
					EXEC P0110_TRAVEL_ADVANCE_DETAIL @Travel_Advance_Detail_ID =0,@Cmp_ID=@Cmp_ID,@Travel_App_ID=@Travel_Application_ID,@Expence_Type=@Expence_Type,@Amount=@Amount,@Adv_Detail_Desc=@Adv_Detail_Desc,@Curr_ID=0,@Tran_Type='I'		
					FETCH NEXT FROM TravelAdvDetail_CURSOR INTO @Expence_Type,@Amount,@Adv_Detail_Desc
				END
			CLOSE TravelAdvDetail_CURSOR
			DEALLOCATE TravelAdvDetail_CURSOR
		END
	SET @Result = 'Travel Application Done'
END TRY
BEGIN CATCH
	SET @Result = ERROR_MESSAGE()
	ROLLBACK 
END CATCH


