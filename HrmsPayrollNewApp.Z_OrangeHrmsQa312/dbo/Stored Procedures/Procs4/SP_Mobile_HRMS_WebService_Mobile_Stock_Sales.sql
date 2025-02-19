-- =============================================
-- Author: satish viramgami
-- Create date: 02/09/2020
-- Description:	Add Mobile brand and Sub-models master in vivo WB 
-- Table T0130_EMP_MOBILE_STOCK_SALES
-- =============================================
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_Mobile_Stock_Sales]
	@Cmp_ID numeric(18,0),
	@Emp_ID numeric(18,0),
	@Store_ID numeric(18,0),
	@Login_ID numeric(18,0),
	@Mobile_Remark_ID numeric(18,0),
	@SaleStockDetails XML,
	@Type char(1),
	@For_Date Datetime='',
	@Result varchar(100) OUTPUT
AS	
BEGIN


	IF @Type = 'I'
	BEGIN
		-- As per client request all vba can submit the data 06/10/2020
		--IF EXISTS(SELECT 1 FROM T0130_EMP_MOBILE_STOCK_SALES WHERE CMP_ID = @Cmp_ID AND CAST(For_Date as date) = CAST(@For_Date as date) AND Store_ID = @Store_ID AND Emp_ID=@Emp_ID)
		--BEGIN
		--		SET @Result = 'Data already submitted for the day#False#'
		--		SELECT @Result
		--END
		--ELSE If EXISTS(SELECT 1 FROM T0130_EMP_MOBILE_STOCK_SALES WHERE CMP_ID = @Cmp_ID AND CAST(For_Date as date) = CAST(@For_Date as date) AND Store_ID = @Store_ID and Mobile_Remark_ID=@Mobile_Remark_ID)
		--BEGIN
		--		SET @Result = 'Data already submitted by other VBA for current date and store#False#'
		--		SELECT @Result
		--END				
		--ELSE		
		--BEGIN
				If @Mobile_Remark_ID <> 1
				BEGIN
					insert into T0130_EMP_MOBILE_STOCK_SALES values (@Cmp_ID,0,@Emp_ID,@Store_ID,@For_Date,0,0,@Mobile_Remark_ID,GETDATE(),@Login_ID,0)
					
					SET @Result = 'Record Insert Successfully#True#'
					SELECT @Result
				END
				ELSE
				BEGIN
					DECLARE @Stock_Tran_ID NUMERIC(18,0)
					DECLARE @Mobile_Cat_ID NUMERIC(18,0)
					DECLARE @Mobile_Cat_Sale NUMERIC(18,0)
					DECLARE @Mobile_Cat_Stock NUMERIC(18,0)
					DECLARE @Status AS TINYINT
					
					SET @STATUS = 0
					SET @Stock_Tran_ID = 0
					DECLARE @CURRENTDATETIME DATETIME
					SET @CURRENTDATETIME  = GETDATE()
										SELECT --Table1.value('(Stock_Tran_ID/text())[1]','numeric(18,0)') AS SurveyEmpID,
					Table1.value('(Mobile_Cat_ID/text())[1]','numeric(18,0)') AS Mobile_Cat_ID,
					Table1.value('(Mobile_Cat_Sale/text())[1]','numeric(18,0)') AS Mobile_Cat_Sale,
					Table1.value('(Mobile_Cat_Stock/text())[1]','numeric(18,0)') AS Mobile_Cat_Stock,
					Table1.value('(Stock_Tran_ID/text())[1]','numeric(18,0)') AS Stock_Tran_ID
					INTO #SaleStock FROM @SaleStockDetails.nodes('/NewDataSet/Table1') as Temp(Table1)
					
					SELECT * FROM #SaleStock
					
					DECLARE @ANS AS NVARCHAR(MAX)
					SET @ANS = ''
					DECLARE MOBILE_SALESTOCK_CURSOR CURSOR FAST_FORWARD FOR
					SELECT Mobile_Cat_ID,Mobile_Cat_Sale,Mobile_Cat_Stock,Stock_Tran_ID FROM #SaleStock
					OPEN MOBILE_SALESTOCK_CURSOR
					FETCH NEXT FROM MOBILE_SALESTOCK_CURSOR INTO @Mobile_Cat_ID,@Mobile_Cat_Sale,@Mobile_Cat_Stock,@Stock_Tran_ID
					WHILE @@FETCH_STATUS = 0
						BEGIN
							BEGIN TRY
								--print @Mobile_Cat_ID
								--SET @ANS = @Mobile_Cat_Sale
								--select @ANS, @Mobile_Cat_Sale
								--IF NOT EXISTS(SELECT 1 FROM T0130_EMP_MOBILE_STOCK_SALES WHERE Emp_ID = @Emp_ID AND CAST(For_Date as date) = CAST(@For_Date as date) AND Mobile_Cat_ID = @Mobile_Cat_ID)
								--	BEGIN
									EXEC P0060_MobileSalesStock_Response @Stock_Tran_ID OUTPUT,@Cmp_ID = @Cmp_ID,@Mobile_Cat_ID = @Mobile_Cat_ID,@Emp_Id = @Emp_ID,@Store_ID=@Store_ID
										 ,@Mobile_Cat_Sale = @Mobile_Cat_Sale,@Mobile_Cat_Stock = @Mobile_Cat_Stock ,@Mobile_Remark_ID = @Mobile_Remark_ID ,@Login_ID = @Login_ID,@Tran_Type = @Type,@For_Date=@For_Date
									--END
									--ELSE
									--BEGIN  
									--	IF EXISTS(SELECT 1 FROM T0130_EMP_MOBILE_STOCK_SALES WHERE CMP_ID = @Cmp_ID AND CAST(For_Date as date) = CAST(@For_Date as date) AND Emp_Id = @Emp_ID)
									--	BEGIN
									--		EXEC P0060_MobileSalesStock_Response @Stock_Tran_ID OUTPUT,@Cmp_ID = @Cmp_ID,@Mobile_Cat_ID = @Mobile_Cat_ID,@Emp_Id = @Emp_ID,@Store_ID=@Store_ID
									--		,@Mobile_Cat_Sale = @Mobile_Cat_Sale,@Mobile_Cat_Stock = @Mobile_Cat_Stock ,@Mobile_Remark_ID = @Mobile_Remark_ID ,@Login_ID = @Login_ID,@Tran_Type = 'U',@For_Date=@For_Date	
									--	END
									--END						
								FETCH NEXT FROM MOBILE_SALESTOCK_CURSOR INTO @Mobile_Cat_ID,@Mobile_Cat_Sale,@Mobile_Cat_Stock,@Stock_Tran_ID
							END TRY
							BEGIN CATCH
								SET @Status = 1
							END CATCH
						END
					CLOSE MOBILE_SALESTOCK_CURSOR
					DEALLOCATE MOBILE_SALESTOCK_CURSOR
					IF @Status = 0 and @Stock_Tran_ID <> 0
						BEGIN
							SET @Result = 'Record Insert Successfully#True#'
							SELECT @Result
						END
					ELSE
						BEGIN
							SET @Result = 'Something went Wrong#False#'
							SELECT @Result
						END
				END
		--END
	END
	ELSE IF @Type = 'S'
	BEGIN
		
		IF (OBJECT_ID('tempdb..#CalenderStatus') IS NOT NULL)
		BEGIN
			DROP TABLE #CalenderStatus
		END
		
		DECLARE @FirstDOM datetime
		DECLARE @ClockOut AS NUMERIC(18,0)

		SET @FirstDOM = (select CONVERT(DATE,dateadd(dd,-(day(getdate())-1),getdate())))

		IF EXISTS (SELECT 1 FROM T0130_EMP_MOBILE_STOCK_SALES SB WITH(NOLOCK) 
				   WHERE CAST(SB.For_Date AS DATE) = CAST(GETDATE() AS DATE) --'2020-10-05'
				   AND  SB.Cmp_ID = @Cmp_ID 
				   AND SB.Emp_ID = @Emp_ID)
		BEGIN 
			 SET @ClockOut=1
		END
		ELSE
		BEGIN
			SET @ClockOut=0
		END


		CREATE TABLE #CalenderStatus  (
		ID int,
		Cmp_ID int,
		Emp_ID int,
		For_Date Date,
		Store_ID int,
		Mobile_Remark_ID int,
		Stauts int,
		ClockOut int
		)

		INSERT INTO #CalenderStatus
		SELECT Null,SL.Cmp_ID,SL.Emp_ID,CAST(SL.For_Date AS DATE) As For_Date,SL.Store_ID,SL.Mobile_Remark_ID,
			case when SL.Mobile_Remark_ID = 1 then 1 else 0 end as Stauts,@ClockOut as ClockOut
		from T0130_EMP_MOBILE_STOCK_SALES SL WITH(NOLOCK) 
			 inner join (
					Select For_Date ,Max(Stock_Tran_ID) as Stock_Tran_ID  From T0130_EMP_MOBILE_STOCK_SALES  
					Where  Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID
					Group by For_Date
				 ) q on q.For_Date = SL.For_Date and q.Stock_Tran_ID = SL.Stock_Tran_ID
				WHERE SL.Cmp_ID = @Cmp_ID
				  AND SL.Emp_ID = @Emp_ID
				  --AND SL.Mobile_Remark_ID =  1
				  AND Month(SL.For_Date) = Month(GETDATE()) AND Month(SL.For_Date) = Month(GETDATE())
		GROUP BY SL.Emp_ID,CAST(SL.For_Date AS DATE),SL.Cmp_ID,SL.Store_ID,SL.Mobile_Remark_ID

		;with d(date) as (
		  select cast(@FirstDOM as datetime)
		  union all
		  select date+1
		  from d
		  where date <  CAST(GETDATE() AS DATE)  
		  )
		select ISNULL(t.ID,ROW_NUMBER() OVER( ORDER BY t.ID)) as ID , Convert(varchar(20),d.date,103) as For_Date, ISNULL(t.Cmp_ID,0) as Cmp_ID,
			   ISNULL(t.Emp_ID,0) as Emp_ID,ISNULL(t.Store_ID,0) as Store_ID,ISNULL(t.Mobile_Remark_ID,0) as Mobile_Remark_ID,
			   ISNULL(t.Stauts, 0) as Stauts,ISNULL(t.ClockOut, 0) as ClockOut 
		from d
		left join #CalenderStatus t
			   on t.For_Date = d.date
		order by d.date
		OPTION (MAXRECURSION 0)

		DROP TABLE #CalenderStatus
	
	END
	
END


