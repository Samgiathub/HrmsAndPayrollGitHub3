
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_Canteen]
	@Emp_ID numeric(18,0),
	@Cmp_ID numeric(18,0),
	@Emp_Code varchar(50),
	@Canteen_Datails XML,
	@IMEI_No varchar(50),
	@Card_No varchar(50),
	@Login_ID numeric(18,0),
	@Type Char(1),
	@Cnt_Id numeric(18,0)=0,
	@Result VARCHAR(100) OUTPUT
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


DECLARE @MstTranID int
DECLARE @TranID numeric(18,0)
DECLARE @CanteenTranID numeric(18,0)
DECLARE @MAXTranID numeric(18,0)
DECLARE @CanteenID numeric(18,0)
DECLARE @CardNo varchar(50)		
DECLARE @Quantity numeric(18,2)
DECLARE @ForDate datetime
DECLARE @CanteenName varchar(50)
DECLARE @TranFinishDate datetime
DECLARE @IsFinish int
set @CanteenTranID = 0
		
IF @Type = 'B' -- For Bind Canteen Category
	BEGIN
	
		SELECT CM.Cmp_Id,CM.Cnt_Id,CM.Cnt_Name,CM.From_Time,CM.To_Time,CM.System_Date,CM.Ip_Id,IP.Device_Model,IP.Device_Type,CM.Canteen_Image
		FROM T0050_CANTEEN_MASTER CM WITH (NOLOCK) INNER JOIN T0040_IP_MASTER IP WITH (NOLOCK) ON IP.IP_ID = CM.IP_ID
		WHERE CM.Cmp_Id = @Cmp_ID and IP.Device_Model='OTHER' and IP.Device_Type='Others'
		
		
		
	END
ELSE IF @Type = 'R' -- For Registration Card
	BEGIN
		SELECT @Emp_ID = Emp_ID,@Cmp_ID = Cmp_ID 
		FROM T0080_EMP_MASTER WITH (NOLOCK)
		WHERE Alpha_Emp_Code = @Emp_Code OR CAST(Emp_code AS VARCHAR) = @Emp_Code AND Emp_Left = 'N'
		
		SELECT @MstTranID = Tran_Id 
		FROM T0081_CUSTOMIZED_COLUMN WITH (NOLOCK)
		WHERE Column_Name = 'Canteen_Card_No' AND Cmp_Id = @Cmp_ID
		
		IF @Card_No = ''
			BEGIN
				SELECT 'Enter Valid Card No#False#0'
				RETURN
			END 
		ELSE IF ISNULL(@Emp_ID ,0) = 0
			BEGIN
				SELECT 'Employee Code is Invalid#False#0'
				RETURN
			END
		ELSE IF ISNULL(@MstTranID,0) = 0 
			BEGIN
				SELECT 'Does Not Register Card No #False#0'
				RETURN
			END
		IF EXISTS(SELECT 1 FROM T0082_Emp_Column WITH (NOLOCK) WHERE mst_Tran_Id = @MstTranID AND Emp_Id = @Emp_ID)
			BEGIN
				UPDATE T0082_Emp_Column SET Value = @Card_No 
				WHERE mst_Tran_Id = @MstTranID AND Emp_Id = @Emp_ID
				
				SELECT  @TranID = Tran_Id FROM T0082_Emp_Column WITH (NOLOCK)
				WHERE mst_Tran_Id = @MstTranID AND Emp_Id = @Emp_ID
				
				SELECT 'This Card is Already Registered#True#'+CAST(@TranID as varchar(11)) 
			END
		ELSE
			BEGIN
				SELECT  @TranID = ISNULL(MAX(Tran_Id),0) FROM T0082_Emp_Column WITH (NOLOCK)
				
				INSERT INTO T0082_Emp_Column (mst_Tran_Id,cmp_Id,Emp_Id,Value,[sys_Date])
				VALUES(@MstTranID,@Cmp_ID,@Emp_ID,@Card_No,GETDATE())
				
				SELECT 'Card No Register Successfully#True#'+CAST(@TranID as varchar(11)) 
			END
		
		
	END
ELSE IF @Type = 'E' -- For Bind Canteen Details Insert
	BEGIN
		SELECT EM.Emp_ID,EM.Cmp_ID,Emp_Code,Alpha_Emp_Code,Emp_Full_Name_new,Dept_Name,Desig_Name,Gender,
		EC.Value AS 'Card_No'
		FROM V0080_Employee_Master EM
		INNER JOIN T0082_Emp_Column EC WITH (NOLOCK) ON EM.Emp_ID = EC.Emp_Id
		INNER JOIN T0081_CUSTOMIZED_COLUMN CC WITH (NOLOCK) ON CC.Tran_Id = EC.mst_Tran_Id 
		WHERE CC.Column_Name = 'Canteen_Card_No' AND EM.Emp_Left = 'N' --AND EC.Emp_Id = Emp_ID
	END
ELSE IF @Type = 'I' -- For Bind Canteen Details Insert
	BEGIN
	
  		
		
  		SELECT @CANTEENTRANID = ISNULL(MAX(CANTEEN_TRANSACTIONID),0) + 1 
  		FROM T0150_EMP_CANTEEN_PUNCH WITH (NOLOCK)
  		--WHERE CONVERT(DATE,CANTEEN_PUNCH_DATETIME) = CONVERT(DATE,GETDATE()) AND DEVICE_IP = @IMEI_NO
  		WHERE CONVERT(DATE,TransFinishDate) = CONVERT(DATE,GETDATE()) AND DEVICE_IP = @IMEI_NO
  		AND FLAG='MOBILE' AND REASON='MOBILE'
  		
  		
  		
		--BEGIN TRY
		
			--INSERT INTO T0150_EMP_CANTEEN_PUNCH(Tran_Id,Cmp_ID,Emp_ID,Canteen_Punch_Datetime,Flag,Device_IP,
			--Reason,User_ID,System_Date,Canteen_ID,Card_No,Quantity)
			--SELECT	@TranID + (ROW_NUMBER() OVER(ORDER BY CONVERT(DATETIME,Table1.value('(ForDate/text())[1]','varchar(50)'), 103) ASC)),
			--		Table1.value('(CmpID/text())[1]','numeric(18,0)') AS CmpID,
			--		Table1.value('(EmpID/text())[1]','numeric(18,0)') AS EmpID,
			--		CONVERT(DATETIME,Table1.value('(ForDate/text())[1]','varchar(50)'), 103) AS ForDate,				
			--		'Mobile',
			--		Table1.value('(IMEINo/text())[1]','varchar(50)') AS IMEINO,
			--		'Mobile',@Login_ID,GETDATE(),
			--		Table1.value('(Canteen_ID/text())[1]','numeric(18,0)') AS Canteen_ID,
			--		Table1.value('(Card_No/text())[1]','varchar(50)') AS Card_No,
			--		Table1.value('(Quantity/text())[1]','numeric(4,2)') AS Quantity
			--FROM @Canteen_Datails.nodes('/NewDataSet/Table1') as Temp(Table1)
			
			DECLARE @Status AS TINYINT
			SET @Status = 0
			
			
			--SELECT @MAXTranID  = ISNULL(MAX(Tran_Id),0) + 1 FROM T0150_EMP_CANTEEN_PUNCH
			
			SELECT	Table1.value('(CmpID/text())[1]','numeric(18,0)') AS CmpID,
					Table1.value('(EmpID/text())[1]','numeric(18,0)') AS EmpID,
					CONVERT(DATETIME,Table1.value('(ForDate/text())[1]','varchar(50)'), 103) AS ForDate,				
					Table1.value('(IMEINo/text())[1]','varchar(50)') AS IMEINO,
					Table1.value('(Canteen_ID/text())[1]','numeric(18,0)') AS Canteen_ID,
					Table1.value('(Card_No/text())[1]','varchar(50)') AS Card_No,
					Table1.value('(Quantity/text())[1]','numeric(4,2)') AS Quantity,
					CONVERT(DATETIME,Table1.value('(finishTimeDate/text())[1]','varchar(50)'), 103) AS finishTimeDate,
					Table1.value('(isFinish/text())[1]','int') AS isFinish
			INTO #CanteenDetails FROM @Canteen_Datails.nodes('/NewDataSet/Table1') as Temp(Table1)
			
			--select * from #CanteenDetails

			DECLARE CANTEEN_CURSOR CURSOR  Fast_forward FOR
			SELECT CmpID,EmpID,CONVERT(datetime,ForDate,103),Canteen_ID,Card_No,Quantity,CONVERT(datetime,finishTimeDate,103),isFinish FROM #CanteenDetails
			OPEN CANTEEN_CURSOR
			FETCH NEXT FROM CANTEEN_CURSOR INTO @Cmp_ID,@Emp_ID,@ForDate,@CanteenID,@CardNo,@Quantity,@TranFinishDate,@IsFinish
			WHILE @@FETCH_STATUS = 0
				BEGIN
				
				BEGIN TRY
				
					SELECT @CanteenName = Cnt_Name FROM T0050_CANTEEN_MASTER WITH (NOLOCK) WHERE Cnt_Id = @CanteenID
					
					SELECT @CanteenID = Cnt_ID FROM T0050_CANTEEN_MASTER WITH (NOLOCK) WHERE Cnt_Name = @CanteenName AND Cmp_Id = @Cmp_ID
					
					IF NOT EXISTS (SELECT 1 FROM T0150_EMP_CANTEEN_PUNCH WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND Canteen_Punch_Datetime = @ForDate AND Canteen_ID = @CanteenID AND Card_No = @CardNo)
						BEGIN
							SELECT @TranID = ISNULL(MAX(Tran_Id),0) + 1 FROM T0150_EMP_CANTEEN_PUNCH WITH (NOLOCK)
							--SET @Status = 1
							INSERT INTO T0150_EMP_CANTEEN_PUNCH(Tran_Id,Canteen_TransactionID,Cmp_ID,Emp_ID,Canteen_Punch_Datetime,Flag,Device_IP,
							Reason,User_ID,System_Date,Canteen_ID,Card_No,Quantity,TransFinishDate)
							VALUES(@TranID,@CanteenTranID,@Cmp_ID,@Emp_ID,@ForDate,'Mobile',@IMEI_No,'Mobile',@Login_ID,GETDATE(),@CanteenID,@CardNo,@Quantity,@TranFinishDate) 
						 END
					END TRY
					BEGIN CATCH
						SET @Status = 1
						INSERT INTO T0150_EMP_CANTEEN_PUNCH_ERROR_LOGS(Canteen_TransactionID,CMP_ID,EMP_ID,CANTEEN_PUNCH_DATETIME,FLAG,DEVICE_IP,
						USER_ID,SYSTEM_DATE,CANTEEN_ID,CARD_NO,QUANTITY)
						VALUES(@CanteenTranID,@CMP_ID,@EMP_ID,@FORDATE,'MOBILE',@IMEI_NO,@LOGIN_ID,GETDATE(),@CANTEENID,@CARDNO,@QUANTITY) 
					END CATCH
					FETCH NEXT FROM CANTEEN_CURSOR INTO @Cmp_ID,@Emp_ID,@ForDate,@CanteenID,@CardNo,@Quantity,@TranFinishDate,@IsFinish
				END
			CLOSE CANTEEN_CURSOR     
			DEALLOCATE CANTEEN_CURSOR
			
			IF @Status = 0
				SELECT 'Record Inserted Successfully#True#'
			ELSE
				SELECT 'Something Went Wrong #False#'
			
			
			SELECT ECP.Canteen_ID,CM.Cnt_Name AS 'Category',SUM(ECP.Quantity) AS 'Quantity',CAST(DATEPART(HOUR, ECP.TRANSFINISHDATE) AS VARCHAR) + ':00' AS 'HOUR'
			FROM T0150_EMP_CANTEEN_PUNCH ECP WITH (NOLOCK)
			INNER JOIN T0050_CANTEEN_MASTER CM WITH (NOLOCK) ON ECP.Canteen_ID = CM.Cnt_Id
			WHERE ECP.Device_IP = @IMEI_No AND CONVERT(DATE,ECP.TRANSFINISHDATE) = CONVERT(DATE,GETDATE())
			GROUP BY ECP.CANTEEN_TRANSACTIONID,ECP.Canteen_ID,CM.Cnt_Name,CAST(DATEPART(HOUR, ECP.TRANSFINISHDATE) AS VARCHAR)
			ORDER BY ECP.CANTEEN_TRANSACTIONID ASC
			
			--SELECT ECP.Canteen_ID,CM.Cnt_Name AS 'Category',SUM(ECP.Quantity) AS 'Quantity',CAST(DATEPART(HOUR, ECP.SYSTEM_DATE) AS VARCHAR) + ':00' AS 'HOUR'
			--FROM T0150_EMP_CANTEEN_PUNCH ECP
			--INNER JOIN T0050_CANTEEN_MASTER CM ON ECP.Canteen_ID = CM.Cnt_Id
			--WHERE ECP.Device_IP = @IMEI_No --AND ECP.Tran_Id BETWEEN @MAXTranID  AND  @TranID-- CM.Cmp_ID = @Cmp_ID
			--AND CONVERT(DATE,ECP.CANTEEN_PUNCH_DATETIME) = CONVERT(DATE,GETDATE())
			--GROUP BY ECP.CANTEEN_TRANSACTIONID,ECP.Canteen_ID,CM.Cnt_Name,CAST(DATEPART(HOUR, ECP.SYSTEM_DATE) AS VARCHAR)
			--ORDER BY ECP.CANTEEN_TRANSACTIONID ASC
			
	
	
			--SELECT ECP.Canteen_ID,CM.Cnt_Name AS 'Category',SUM(ECP.Quantity) AS 'Quantity'
			--FROM T0150_EMP_CANTEEN_PUNCH ECP
			--INNER JOIN T0050_CANTEEN_MASTER CM ON ECP.Canteen_ID = CM.Cnt_Id
			--WHERE ECP.Device_IP = @IMEI_No AND ECP.Tran_Id BETWEEN @MAXTranID  AND  @TranID-- CM.Cmp_ID = @Cmp_ID
			--GROUP BY ECP.Canteen_ID,CM.Cnt_Name
			
			
		--END TRY
		--BEGIN CATCH
		--	--SELECT ERROR_MESSAGE()+'#False#'
		--	SELECT 'Something Went Wrong #False#'
			
		--END CATCH
		
		--SELECT EC.Emp_ID,EC.Cmp_ID,EM.Emp_Full_Name_new,EC.Canteen_Punch_Datetime,EC.Card_No,EC.Quantity
		--FROM T0150_EMP_CANTEEN_PUNCH EC
		--INNER JOIN V0080_Employee_Master EM ON EC.Emp_ID = EM.Emp_ID
	END
ELSE IF @Type = 'G'  --Add Category,employee,date wise count for the limit on single category.
BEGIN  

	 --DECLARE @Emp_ID numeric(18,0)
	 --DECLARE @Cmp_ID numeric(18,0)
	 DECLARE @Cat_ID numeric(18,0)
	  
	 DECLARE @FROM_DATE  DATETIME     
	 DECLARE @TO_DATE  DATETIME 
	 DECLARE @CONSTRAINT varchar(MAX) 
	 DECLARE @CURR_COMPANY_AMOUNT NUMERIC(18,2)
	 DECLARE @CURR_SUBSIDY_AMOUNT NUMERIC(18,2)
	 DECLARE @CURR_TOTAL_AMOUNT NUMERIC(18,2)

	 DECLARE @ForDate_Temp DATETIME
	 DECLARE @Quantity_Temp NUMERIC
	 DECLARE @ID NUMERIC

	 --SET  @Emp_ID=24731
	 --SET @Cmp_ID=150
	 SET @Cat_ID = @Cnt_Id

	 SET @TO_DATE =  GETDATE()

     SET @From_Date = (SELECT CONVERT(DATE,DATEADD(dd,-(DAY(GETDATE())-1),GETDATE())))
	 SET @To_Date= CONVERT(DateTime,CONVERT(Char(10), @To_Date, 103), 103);
	 SET @CONSTRAINT = cast(@Emp_ID as varchar(20))
	   
     IF DATEDIFF(D,@FROM_DATE,@TO_DATE)>31 
	 BEGIN
		SET @TO_DATE=DATEADD(D,-1,DATEADD(MM,1,@FROM_DATE))				
	 END	
	 --print @From_Date
	 --print @TO_DATE
  
--SELECT EP.Canteen_ID, (Quantity) 
--FROM T0150_EMP_CANTEEN_PUNCH EP
--where  EP.Emp_ID=@Emp_ID
--   AND EP.Cmp_ID=@Cmp_ID
--AND EP.Canteen_Punch_Datetime between @FROM_DATE and @TO_DATE
--GROUP BY EP.Canteen_ID,Quantity

--details  wise table
  CREATE TABLE #EMP_CATEGORY_WISE_RECORDS
	(   
		ID NUMERIC IDENTITY(1,1),
		EMP_ID NUMERIC , 
		CMP_ID NUMERIC,
		CAT_ID NUMERIC,
		ForDate DATETIME,
		COMPANY_RATE NUMERIC(18,2),
		SUBSIDY_RATE NUMERIC(18,2),
		QUANTITY NUMERIC(18,0), 
		TOTAL_RATE NUMERIC(18,2),
		COMPANY_RATE_TOTAL NUMERIC(18,2),
		SUBSIDY_RATE_TOTAL NUMERIC(18,2),
		TOTAL_RATE_FINAL NUMERIC(18,2)
	);

	CREATE TABLE #EMP_DETAILS
	(      
		EMP_ID NUMERIC ,     
		BRANCH_ID NUMERIC,
		INCREMENT_ID NUMERIC,
		GRD_ID NUMERIC 
	);

   CREATE TABLE #EMP_CONS 
	(      
		EMP_ID NUMERIC ,     
		BRANCH_ID NUMERIC,
		INCREMENT_ID NUMERIC
	);

	CREATE TABLE #EMP_EFFECTDATE
	(      
		TRAN_ID NUMERIC ,     
		EFF_COMPANY_AMOUNT NUMERIC,
		EFF_SUBSIDY_AMOUNT NUMERIC,
		TOTAL_AMOUNT NUMERIC,
		EFFECT_DATE DATETIME
	);

	--TABLE FOR SHOE THE DETAILS WHILE PUNCH TO SYSTEM
	CREATE TABLE #EMP_CANTEEN_CONTRIBUTION_AMOUNT
	(      
		EMP_ID NUMERIC ,     
		BRANCH_ID NUMERIC,
		INCREMENT_ID NUMERIC,
		GRD_ID NUMERIC,
		CNT_ID  INT,
		EMPLOYEE_CONTRIBUTION NUMERIC(18,2),
		SUBSIDY_BORN_BY_COMPANY NUMERIC(18,2),
		QUANTITY NUMERIC(18,0), 
		TOTAL_AMOUNT NUMERIC(18,2),
		CURRUNT_EMPLOYEE_CON_RATE NUMERIC(18,2),
		CURRUNT_SUB_COMPANY_RATE NUMERIC(18,2),
		CURRUNT_TOTAL_AMOUNT NUMERIC(18,2)
	);

	--GET LATEST INCREMENT_ID FROM EMPLOYEE
	EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@FROM_DATE,@TO_DATE,0,0,0,0,0,0 ,0 ,@CONSTRAINT,0 ,0 ,0,0,0,0,0,0,0,0,0,0

	--INITIAL ADD FOR GRD_ID FOR MAPPING WITH CANTEEN PUNCH
	INSERT INTO  #EMP_DETAILS
	SELECT TI.Emp_ID,ti.Branch_ID,TI.Increment_ID,TI.GRD_ID
	from T0095_INCREMENT TI WITH(NOLOCK)
	where TI.Increment_ID in (select Increment_ID from #EMP_CONS)
	 
   insert into #EMP_CATEGORY_WISE_RECORDS
   select CP.Emp_ID,CP.Cmp_ID,CP.Canteen_ID,CP.Canteen_Punch_Datetime,0,0,CP.Quantity,0,0,0,0
   from T0150_EMP_CANTEEN_PUNCH CP
   --inner join T0050_CANTEEN_DETAIL CD on CD.Cmp_Id= @Cmp_ID AND CD.Cnt_Id = @Cat_ID 
   where CP.Emp_ID =@Emp_ID  and CP.Cmp_ID = @Cmp_ID
   and CP.Canteen_ID = @Cat_ID
   and CAST(CP.Canteen_Punch_Datetime AS DATE) between @FROM_DATE and @TO_DATE
    
	----select dates as effective
	INSERT INTO #EMP_EFFECTDATE
						SELECT I2.Tran_Id,I2.Amount,I2.Subsidy_Amount,I2.Total_Amount,I2.Effective_Date FROM T0050_CANTEEN_DETAIL I2 INNER JOIN
					    ( SELECT	MAX(Effective_Date) AS CANTEEN_EFFECTIVE_DATE, I3.Tran_Id
									 FROM	T0050_CANTEEN_DETAIL I3  WITH (NOLOCK) INNER JOIN #EMP_DETAILS E3 ON I3.grd_id=E3.GRD_ID AND i3.Cnt_Id=@Cat_ID
									 WHERE	I3.Effective_Date <= @To_Date and Cmp_Id = @Cmp_ID
									 GROUP BY I3.CNT_ID,Tran_Id
					    ) I3 ON I2.Effective_Date=I3.CANTEEN_EFFECTIVE_DATE AND I2.Tran_Id=I3.Tran_Id	
						--where I2.Effective_Date <= @ForDate_Temp
						ORDER BY I2.Tran_Id DESC
	
	
    --Select * from #EMP_EFFECTDATE
	--start cursor to updat the rate and contribution to each record wise.

	IF EXISTS(SELECT 1 FROM #EMP_CATEGORY_WISE_RECORDS)
	BEGIN
			Declare @Eff_Date Datetime 
			Declare @EFF_COMPANY_AMOUNT NUMERIC(18,2)
			Declare @EFF_SUBSIDY_AMOUNT NUMERIC(18,2)
			Declare @EFF_TOTAL_AMOUNT NUMERIC(18,2)

			Declare @COMPANY_RATE_TOTAL NUMERIC(18,2)
			Declare	@SUBSIDY_RATE_TOTAL NUMERIC(18,2)
			Declare	@TOTAL_RATE_FINAL NUMERIC(18,2)

			DECLARE CANTEEN_CURSOR CURSOR  Fast_forward FOR
			SELECT CMP_ID,EMP_ID,CONVERT(datetime,ForDate,103),CAT_ID,Quantity, ID FROM #EMP_CATEGORY_WISE_RECORDS
			OPEN CANTEEN_CURSOR
			FETCH NEXT FROM CANTEEN_CURSOR INTO @Cmp_ID,@Emp_ID,@ForDate,@CAT_ID,@Quantity,@ID
			WHILE @@FETCH_STATUS = 0
				BEGIN
				
				BEGIN TRY

				     --print @ForDate

					 select @Eff_Date = Max(cast(EFFECT_DATE as date)), 
					       @EFF_COMPANY_AMOUNT = EFF_COMPANY_AMOUNT,
						   @EFF_SUBSIDY_AMOUNT = EFF_SUBSIDY_AMOUNT,
						   @EFF_TOTAL_AMOUNT = TOTAL_AMOUNT
					 from #EMP_EFFECTDATE EF 
					 where cast(EF.EFFECT_DATE as Date)< = @ForDate
					 Group by EFF_COMPANY_AMOUNT,EFF_SUBSIDY_AMOUNT,TOTAL_AMOUNT

					 --print @Eff_Date

					 --prepare total amount as effective date wise
					 	set @COMPANY_RATE_TOTAL =(@EFF_COMPANY_AMOUNT * @Quantity)
						set	@SUBSIDY_RATE_TOTAL = (@EFF_SUBSIDY_AMOUNT * @Quantity)

						set	@TOTAL_RATE_FINAL = (@COMPANY_RATE_TOTAL + @SUBSIDY_RATE_TOTAL)
					  
					 update #EMP_CATEGORY_WISE_RECORDS 
					 set COMPANY_RATE= @EFF_COMPANY_AMOUNT,
					     SUBSIDY_RATE= @EFF_SUBSIDY_AMOUNT,
						 TOTAL_RATE= @EFF_TOTAL_AMOUNT,
						 COMPANY_RATE_TOTAL= @COMPANY_RATE_TOTAL,
						 SUBSIDY_RATE_TOTAL= @SUBSIDY_RATE_TOTAL,
					     TOTAL_RATE_FINAL=@TOTAL_RATE_FINAL
					 where ID=@ID
					   
					END TRY
					BEGIN CATCH 
					END CATCH
					FETCH NEXT FROM CANTEEN_CURSOR INTO @Cmp_ID,@Emp_ID,@ForDate,@CAT_ID,@Quantity,@ID
				END
			CLOSE CANTEEN_CURSOR     
			DEALLOCATE CANTEEN_CURSOR
	   
	END
	ELSE
	BEGIN
		 INSERT INTO #EMP_CATEGORY_WISE_RECORDS
		 SELECT @Emp_ID,@Cmp_ID,@Cat_ID,'',0,0,0,0,0,0,0
	END
	 
    --select * from #EMP_CATEGORY_WISE_RECORDS
	Declare @Eff_Date_Latest Datetime

   	SELECT @Eff_Date_Latest = Max(cast(EFFECT_DATE as date)), 
			@CURR_COMPANY_AMOUNT = EFF_COMPANY_AMOUNT,
			@CURR_SUBSIDY_AMOUNT = EFF_SUBSIDY_AMOUNT,
			@CURR_TOTAL_AMOUNT = TOTAL_AMOUNT
	from #EMP_EFFECTDATE EF 
	where cast(EF.EFFECT_DATE as Date) <= CAST(GETDATE() as DATE)
	Group by EFF_COMPANY_AMOUNT,EFF_SUBSIDY_AMOUNT,TOTAL_AMOUNT


   INSERT INTO #EMP_CANTEEN_CONTRIBUTION_AMOUNT 
   SELECT @Emp_ID,ED.BRANCH_ID,ED.INCREMENT_ID,ED.GRD_ID,@Cat_ID,
          SUM(ECW.COMPANY_RATE_TOTAL),SUM(ECW.SUBSIDY_RATE_TOTAL),
		  SUM(ECW.QUANTITY),SUM(ECW.TOTAL_RATE_FINAL),
		  @CURR_COMPANY_AMOUNT,@CURR_SUBSIDY_AMOUNT,@CURR_TOTAL_AMOUNT
   FROM #EMP_CATEGORY_WISE_RECORDS ECW
   INNER JOIN #EMP_DETAILS ED ON ED.EMP_ID = ECW.EMP_ID
   group by ECW.EMP_ID,ED.BRANCH_ID,ED.INCREMENT_ID,ED.GRD_ID

   select * from #EMP_CANTEEN_CONTRIBUTION_AMOUNT

   DROP TABLE #EMP_CATEGORY_WISE_RECORDS
   DROP TABLE #EMP_DETAILS
   DROP TABLE #EMP_CONS
   DROP TABLE #EMP_EFFECTDATE
   DROP TABLE #EMP_CANTEEN_CONTRIBUTION_AMOUNT
END
ELSE  IF @Type = 'Y'
BEGIN
	 
	select * from T0050_CANTEEN_DETAIL
	 
END