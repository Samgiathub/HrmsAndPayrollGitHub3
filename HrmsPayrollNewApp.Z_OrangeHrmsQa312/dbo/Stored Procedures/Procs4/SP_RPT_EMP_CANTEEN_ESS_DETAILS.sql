CREATE PROCEDURE [dbo].[SP_RPT_EMP_CANTEEN_ESS_DETAILS]
	@EmpID numeric(18,0),
	@CmpID numeric(18,0),
	@FromDate Datetime,
	@ToDate Datetime,
	@CatID numeric(18,0)
AS
BEGIN

--IF @FromDate = '' OR @ToDate = ''
--BEGIN
	
--	DECLARE @Month int
--	DECLARE @Year int

--	SET @ToDate =  GETDATE()
	 
--    SET @FromDate = (SELECT CONVERT(DATE,DATEADD(dd,-(DAY(GETDATE())-1),GETDATE())))
--	SET @ToDate= CONVERT(DateTime,CONVERT(Char(10), @ToDate, 103), 103);

--	SET @FromDate = CONVERT(datetime, CAST(@Month as varchar) + '/01/' + CAST(@Year as varchar))  
--	SET @ToDate = DATEADD(month, 1, CONVERT(datetime, CAST(@Month as varchar)+ '/01/' + CAST(@Year as varchar))) -1
	
--	--print @FromDate
--	--print @ToDate
--END


--IF @CatID = 0
--BEGIN

--	SELECT ROW_NUMBER() OVER(ORDER BY CP.Emp_ID ASC) AS SrNo,CP.Emp_ID,CP.Cmp_ID,CP.Canteen_ID,
--	      CONVERT(VARCHAR(10), CP.Canteen_Punch_Datetime, 103) + ' '  + convert(VARCHAR(8), CP.Canteen_Punch_Datetime, 14) as Canteen_Punch_Datetime,
--		  CP.Quantity,EM.Emp_Full_Name,CM.Cnt_Name
--	FROM T0150_EMP_CANTEEN_PUNCH CP WITH(NOLOCK)
--	INNER JOIN T0080_EMP_MASTER EM WITH(NOLOCK) ON EM.Emp_ID = CP.Emp_ID
--	INNER JOIN T0050_CANTEEN_MASTER CM WITH(NOLOCK) ON CM.Cnt_Id = CP.Canteen_ID
--	WHERE CP.Emp_ID = @EmpID  AND CP.Cmp_ID = @CmpID
--	and CAST(CP.Canteen_Punch_Datetime as DATE)  between @FromDate and @ToDate
--	order by Tran_Id asc
		    
--END
--ELSE
--BEGIN
	
--	SELECT ROW_NUMBER() OVER(ORDER BY CP.Emp_ID ASC) AS SrNo,CP.Emp_ID,CP.Cmp_ID,CP.Canteen_ID,
--	       CONVERT(VARCHAR(10), CP.Canteen_Punch_Datetime, 103) + ' '  + convert(VARCHAR(8), CP.Canteen_Punch_Datetime, 14) as Canteen_Punch_Datetime,
--	       CP.Quantity,EM.Emp_Full_Name,CM.Cnt_Name
--	FROM T0150_EMP_CANTEEN_PUNCH  CP WITH(NOLOCK)
--	INNER JOIN T0080_EMP_MASTER EM WITH(NOLOCK) ON EM.Emp_ID = CP.Emp_ID
--	INNER JOIN T0050_CANTEEN_MASTER CM WITH(NOLOCK) ON CM.Cnt_Id = CP.Canteen_ID
--	WHERE CP.Emp_ID = @EmpID  AND CP.Cmp_ID = @CmpID
--	and CP.Canteen_ID = @CatID
--	and CAST(CP.Canteen_Punch_Datetime as DATE)  between @FromDate and @ToDate
--	order by Tran_Id asc
--END

	 --DECLARE @From_Date datetime
	 --DECLARE @ToDate datetime
	 DECLARE @CONSTRAINT varchar(MAX) 
	 DECLARE @CURR_COMPANY_AMOUNT NUMERIC(18,2)
	 DECLARE @CURR_SUBSIDY_AMOUNT NUMERIC(18,2)
	 DECLARE @CURR_TOTAL_AMOUNT NUMERIC(18,2)

	 DECLARE @ForDate DATETIME
	 DECLARE @Quantity NUMERIC
	 DECLARE @ID NUMERIC
	 DECLARE @grd_id NUMERIC
	 

	 --SET @From_Date = CONVERT(datetime, CAST(@Month as varchar) + '/01/' + CAST(@Year as varchar))  
	 --SET @ToDate = DATEADD(month, 1, CONVERT(datetime, CAST(@Month as varchar)+ '/01/' + CAST(@Year as varchar))) -1

	 SET @CONSTRAINT = cast(@EmpID as varchar(20))
	   
  --   IF DATEDIFF(D,@From_Date,@ToDate)>31 
	 --BEGIN
		--SET @ToDate=DATEADD(D,-1,DATEADD(MM,1,@From_Date))				
	 --END	

    --Category wise table for employee

	CREATE TABLE #EMP_CAT_WISE_COUNT
	( 
		COUNT_ID NUMERIC IDENTITY(1,1),
		EMP_ID NUMERIC, 
		CMP_ID NUMERIC,
		CAT_ID NUMERIC,
		CAT_COUNT NUMERIC (18,2),
		RESULT VARCHAR(MAX)
	);
 

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
		TOTAL_RATE_FINAL NUMERIC(18,2),
		EMP_FULL_NAME varchar(50),
		CANTEEN_CAT_NAME varchar(50),
		grd_id NUMERIC
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
		--TRAN_ID NUMERIC , 
		CAT_ID NUMERIC,
		EFF_COMPANY_AMOUNT NUMERIC(18,2),
		EFF_SUBSIDY_AMOUNT NUMERIC(18,2),
		TOTAL_AMOUNT NUMERIC(18,2),
		EFFECT_DATE DATETIME,
		grd_id NUMERIC
	);

	--TABLE FOR SHOE THE DETAILS WHILE PUNCH TO SYSTEM
	CREATE TABLE #EMP_CANTEEN_CONTRIBUTION_AMOUNT
	(      
		ROW_ID NUMERIC IDENTITY(1,1),
		EMP_ID NUMERIC,     
		BRANCH_ID NUMERIC,
		INCREMENT_ID NUMERIC,
		GRD_ID NUMERIC,
		CNT_ID  INT,
		CNT_NAME VARCHAR(50),
		EMPLOYEE_CONTRIBUTION NUMERIC(18,2),
		SUBSIDY_BORN_BY_COMPANY NUMERIC(18,2),
		QUANTITY NUMERIC(18,0), 
		TOTAL_AMOUNT NUMERIC(18,2),
		CURRUNT_EMPLOYEE_CON_RATE NUMERIC(18,2),
		CURRUNT_SUB_COMPANY_RATE NUMERIC(18,2),
		CURRUNT_TOTAL_AMOUNT NUMERIC(18,2)
	);

	--GET LATEST INCREMENT_ID FROM EMPLOYEE
	EXEC SP_RPT_FILL_EMP_CONS  @CmpID,@FromDate,@ToDate,0,0,0,0,0,0 ,0 ,@CONSTRAINT,0 ,0 ,0,0,0,0,0,0,0,0,0,0

	--INITIAL ADD FOR GRD_ID FOR MAPPING WITH CANTEEN PUNCH
	INSERT INTO  #EMP_DETAILS
	SELECT TI.Emp_ID,ti.Branch_ID,TI.Increment_ID,TI.GRD_ID
	from T0095_INCREMENT TI WITH(NOLOCK)
	where TI.Increment_ID in (select Increment_ID from #EMP_CONS)
	 
	 --print @CmpID

	INSERT INTO #EMP_CAT_WISE_COUNT
	SELECT @EmpID,@CmpID,EP.Canteen_ID,ISNULL(SUM (Quantity),0) as Quantity,''
	FROM T0150_EMP_CANTEEN_PUNCH EP WITH(NOLOCK)
	where  EP.Emp_ID=@EmpID
	   AND EP.Cmp_ID=@CmpID
	   AND CAST(EP.Canteen_Punch_Datetime AS DATE) between @FromDate and @ToDate
	GROUP BY EP.Canteen_ID

	Declare @Eff_Date Datetime 
	Declare @EFF_COMPANY_AMOUNT NUMERIC(18,2)
	Declare @EFF_SUBSIDY_AMOUNT NUMERIC(18,2)
	Declare @EFF_TOTAL_AMOUNT NUMERIC(18,2)
	Declare @COUNT_ID NUMERIC
	Declare @CatID_ALL NUMERIC

	Declare @COMPANY_RATE_TOTAL NUMERIC(18,2)
	Declare	@SUBSIDY_RATE_TOTAL NUMERIC(18,2)
	Declare	@TOTAL_RATE_FINAL NUMERIC(18,2)
	Declare @Eff_Date_Latest Datetime
   
   IF @CatID = 0
   BEGIN
			--select * from #EMP_CAT_WISE_COUNT
			--select * from #EMP_DETAILS
			--return

		   INSERT INTO #EMP_CATEGORY_WISE_RECORDS
		   SELECT CP.Emp_ID,CP.Cmp_ID,CP.Canteen_ID,CP.Canteen_Punch_Datetime,0,0,CP.Quantity,0,0,0,0,EM.Emp_Full_Name,CM.Cnt_Name,grd_id
		   from T0150_EMP_CANTEEN_PUNCH  CP WITH(NOLOCK)
		   INNER JOIN T0080_EMP_MASTER EM WITH(NOLOCK) ON EM.Emp_ID = CP.Emp_ID
		   INNER JOIN T0050_CANTEEN_MASTER CM WITH(NOLOCK) ON CM.Cnt_Id = CP.Canteen_ID
		   where CP.Emp_ID =@EmpID  AND CP.Cmp_ID = @CmpID
		   and CP.Canteen_ID IN (SELECT CAT_ID FROM #EMP_CAT_WISE_COUNT)
		   and CAST(CP.Canteen_Punch_Datetime as DATE)  between @FromDate and @ToDate 

		   

		   	--SELECT DATES AS EFFECTIVE
			--INSERT INTO #EMP_EFFECTDATE
			--			SELECT I2.Tran_Id,I2.Cnt_Id,I2.Amount,I2.Subsidy_Amount,I2.Total_Amount,I2.Effective_Date 
			--			FROM T0050_CANTEEN_DETAIL I2 INNER JOIN
			--					( SELECT MAX(Effective_Date) AS CANTEEN_EFFECTIVE_DATE, I3.Tran_Id
			--						,i3.Cnt_Id
			--						 FROM	T0050_CANTEEN_DETAIL I3  WITH (NOLOCK) INNER JOIN #EMP_DETAILS E3 ON I3.grd_id=E3.GRD_ID 
			--						 AND i3.Cnt_Id IN (SELECT CAT_ID FROM #EMP_CAT_WISE_COUNT)
			--						 WHERE	I3.Effective_Date <= @ToDate and Cmp_Id = @CmpID
			--						 GROUP BY I3.CNT_ID,Tran_Id
			--		    ) I4 ON I2.Effective_Date=I4.CANTEEN_EFFECTIVE_DATE 
			--			AND I2.Tran_Id=I4.Tran_Id 
			--			and I2.Cnt_Id = I4.Cnt_Id
			--			where I2.Effective_Date <= @ToDate
			--			ORDER BY I2.Tran_Id DESC

			INSERT INTO #EMP_EFFECTDATE
			SELECT distinct I2.Cnt_Id,I2.Amount,I2.Subsidy_Amount,I2.Total_Amount,I2.Effective_Date ,I2.grd_id
						FROM T0050_CANTEEN_DETAIL I2 INNER JOIN
					    ( SELECT	MAX(Effective_Date) AS CANTEEN_EFFECTIVE_DATE--, --I3.Tran_Id
								,i3.Cnt_Id
									 FROM	T0050_CANTEEN_DETAIL I3  WITH (NOLOCK) 
									 INNER JOIN #EMP_DETAILS E3 ON I3.grd_id= E3.GRD_ID 
									 AND i3.Cnt_Id IN (SELECT CAT_ID FROM #EMP_CAT_WISE_COUNT)
									 WHERE	I3.Effective_Date <= @ToDate and Cmp_Id = @CmpID
									 GROUP BY I3.CNT_ID--,Tran_Id
					    ) I4 ON I2.Effective_Date=I4.CANTEEN_EFFECTIVE_DATE 
						--AND I2.Tran_Id=I4.Tran_Id 
						and I2.Cnt_Id = I4.Cnt_Id

						--select * from #EMP_EFFECTDATE

			IF EXISTS(SELECT 1 FROM #EMP_CATEGORY_WISE_RECORDS)
			BEGIN

					
					--Select * from #EMP_EFFECTDATE
					DECLARE CANTEEN_CATEGORY_CURSOR CURSOR Fast_forward FOR
					SELECT COUNT_ID,CAT_ID FROM #EMP_CAT_WISE_COUNT
					OPEN CANTEEN_CATEGORY_CURSOR 
					FETCH NEXT FROM CANTEEN_CATEGORY_CURSOR INTO @COUNT_ID,@CatID_ALL
					WHILE @@FETCH_STATUS = 0
						BEGIN
							BEGIN TRY
								
								DECLARE CANTEEN_CURSOR CURSOR  Fast_forward FOR
								SELECT CMP_ID,EMP_ID,CONVERT(datetime,ForDate,103),CAT_ID,Quantity, ID,grd_id FROM #EMP_CATEGORY_WISE_RECORDS
								OPEN CANTEEN_CURSOR
								FETCH NEXT FROM CANTEEN_CURSOR INTO @CmpID,@EmpID,@ForDate,@CatID,@Quantity,@ID,@grd_id
								WHILE @@FETCH_STATUS = 0
									BEGIN
				
									BEGIN TRY

										 SELECT @Eff_Date = Max(cast(EFFECT_DATE as date)), 
											   @EFF_COMPANY_AMOUNT = EFF_COMPANY_AMOUNT,
											   @EFF_SUBSIDY_AMOUNT = EFF_SUBSIDY_AMOUNT,
											   @EFF_TOTAL_AMOUNT = TOTAL_AMOUNT
										 FROM #EMP_EFFECTDATE EF 
										 WHERE cast(EF.EFFECT_DATE as Date) < = @ForDate
												and  EF.CAT_ID = @CatID_ALL and grd_id = @grd_id
										 GROUP BY EFF_COMPANY_AMOUNT,EFF_SUBSIDY_AMOUNT,TOTAL_AMOUNT

										  
   										SELECT @Eff_Date_Latest = Max(cast(EFFECT_DATE as date)), 
												@CURR_COMPANY_AMOUNT = EFF_COMPANY_AMOUNT,
												@CURR_SUBSIDY_AMOUNT = EFF_SUBSIDY_AMOUNT,
												@CURR_TOTAL_AMOUNT = TOTAL_AMOUNT
										from #EMP_EFFECTDATE EF 
										where cast(EF.EFFECT_DATE as Date) <= CAST(GETDATE() as DATE)
										    and  EF.CAT_ID = @CatID_ALL and grd_id = @grd_id
										Group by EFF_COMPANY_AMOUNT,EFF_SUBSIDY_AMOUNT,TOTAL_AMOUNT

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
										 where ID=@ID and 
										 CAT_ID=@CatID_ALL and grd_id = @grd_id 
										 
										-- Select * from #EMP_CATEGORY_WISE_RECORDS
										   
										END TRY
										BEGIN CATCH 
										END CATCH
										FETCH NEXT FROM CANTEEN_CURSOR INTO @CmpID,@EmpID,@ForDate,@CatID,@Quantity,@ID,@grd_id
									END
								CLOSE CANTEEN_CURSOR     
								DEALLOCATE CANTEEN_CURSOR
						 
				END TRY
				BEGIN CATCH 
				END CATCH
				FETCH NEXT FROM CANTEEN_CATEGORY_CURSOR INTO @COUNT_ID,@CatID_ALL
				END
			CLOSE CANTEEN_CATEGORY_CURSOR     
			DEALLOCATE CANTEEN_CATEGORY_CURSOR
			 	   
		END
		--ELSE
		--BEGIN
			
		--	 INSERT INTO #EMP_CATEGORY_WISE_RECORDS
		--	 SELECT NULL,NULL,NULL,NULL,0,0,0,0,0,0,0,'','',0
		--END
		  	 
   END
   ELSE
   BEGIN
		   INSERT INTO #EMP_CATEGORY_WISE_RECORDS
		   select CP.Emp_ID,CP.Cmp_ID,CP.Canteen_ID,CP.Canteen_Punch_Datetime,0,0,CP.Quantity,0,0,0,0,EM.Emp_Full_Name,CM.Cnt_Name,grd_id
		   from T0150_EMP_CANTEEN_PUNCH  CP WITH(NOLOCK)
		   INNER JOIN T0080_EMP_MASTER EM WITH(NOLOCK) ON EM.Emp_ID = CP.Emp_ID
		   INNER JOIN T0050_CANTEEN_MASTER CM WITH(NOLOCK) ON CM.Cnt_Id = CP.Canteen_ID
		   where CP.Emp_ID =@EmpID AND CP.Cmp_ID = @CmpID
		   and CP.Canteen_ID = @CatID
		   and CAST(CP.Canteen_Punch_Datetime as DATE)  between @FromDate and @ToDate

		  
		   	----select dates as effective
			--INSERT INTO #EMP_EFFECTDATE
			--			SELECT I2.Tran_Id,I2.Cnt_Id,I2.Amount,I2.Subsidy_Amount,I2.Total_Amount,I2.Effective_Date FROM T0050_CANTEEN_DETAIL I2 INNER JOIN
			--		    ( SELECT	MAX(Effective_Date) AS CANTEEN_EFFECTIVE_DATE, I3.Tran_Id,CNT_ID
			--						 FROM	T0050_CANTEEN_DETAIL I3  WITH (NOLOCK) INNER JOIN #EMP_DETAILS E3 ON I3.grd_id=E3.GRD_ID AND i3.Cnt_Id=@CatID
			--						 WHERE	I3.Effective_Date <= @ToDate and Cmp_Id = @CmpID
			--						 GROUP BY I3.CNT_ID,Tran_Id
			--		    ) I4 ON I2.Effective_Date=I4.CANTEEN_EFFECTIVE_DATE AND I2.Tran_Id=I4.Tran_Id and i2.Cnt_Id = i4.CNT_ID
			--			--where I2.Effective_Date <= @ForDate
			--			ORDER BY I2.Tran_Id DESC

			INSERT INTO #EMP_EFFECTDATE
			SELECT distinct I2.Cnt_Id,I2.Amount,I2.Subsidy_Amount,I2.Total_Amount,I2.Effective_Date ,I2.grd_id
						FROM T0050_CANTEEN_DETAIL I2 INNER JOIN
					    ( SELECT	MAX(Effective_Date) AS CANTEEN_EFFECTIVE_DATE--, --I3.Tran_Id
								,i3.Cnt_Id
									 FROM	T0050_CANTEEN_DETAIL I3  WITH (NOLOCK) 
									 INNER JOIN #EMP_DETAILS E3 ON I3.grd_id= E3.GRD_ID 
									 AND i3.Cnt_Id IN (SELECT CAT_ID FROM #EMP_CAT_WISE_COUNT)
									 WHERE	I3.Effective_Date <= @ToDate and Cmp_Id = @CmpID 
									 GROUP BY I3.CNT_ID--,Tran_Id
					    ) I4 ON I2.Effective_Date=I4.CANTEEN_EFFECTIVE_DATE 
						--AND I2.Tran_Id=I4.Tran_Id 
						and I2.Cnt_Id = I4.Cnt_Id
		
			IF EXISTS(SELECT 1 FROM #EMP_CATEGORY_WISE_RECORDS)
			BEGIN
	 
					DECLARE CANTEEN_CURSOR CURSOR  Fast_forward FOR
					SELECT CMP_ID,EMP_ID,CONVERT(datetime,ForDate,103),CAT_ID,Quantity, ID,grd_id FROM #EMP_CATEGORY_WISE_RECORDS
					OPEN CANTEEN_CURSOR
					FETCH NEXT FROM CANTEEN_CURSOR INTO @CmpID,@EmpID,@ForDate,@CatID,@Quantity,@ID,@grd_id
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
									and Ef.CAT_ID = @CatID and grd_id = @grd_id
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
							 where ID=@ID and grd_id = @grd_id
					   
							END TRY
							BEGIN CATCH 
							END CATCH
							FETCH NEXT FROM CANTEEN_CURSOR INTO @CmpID,@EmpID,@ForDate,@CatID,@Quantity,@ID,@grd_id
						END
					CLOSE CANTEEN_CURSOR     
					DEALLOCATE CANTEEN_CURSOR
	   
			END
			--ELSE
			--BEGIN
			
			--	 INSERT INTO #EMP_CATEGORY_WISE_RECORDS
			--	 SELECT @EmpID,@CmpID,@CatID,NULL,0,0,0,0,0,0,0,'','',0
			--END
		  	
   END
       
   IF EXISTS(select 1 from #EMP_CATEGORY_WISE_RECORDS where ISNULL(EMP_ID,0) <> 0)
   BEGIN 
	
	--DECLARE @MAXID NUMERIC(18,2)
 --   SELECT @MAXID= Isnull(Max(ID),0) + 1 FROM #EMP_CATEGORY_WISE_RECORDS
		
	INSERT INTO #EMP_CATEGORY_WISE_RECORDS
	SELECT	    0,0,0,NULL,
				SUM(COMPANY_RATE) AS COMPANY_RATE_TOTAL,
				SUM(SUBSIDY_RATE) AS SUBSIDY_RATE_TOTAL,
				SUM(QUANTITY) AS QUANTITY_TOTAL, 
				SUM(TOTAL_RATE) AS TOTAL_RATE_TOT,
				SUM(COMPANY_RATE_TOTAL) AS COMPANY_RATE_TOTAL_SUB,
				SUM(SUBSIDY_RATE_TOTAL) AS SUBSIDY_RATE_TOTAL_SUB,
				SUM(TOTAL_RATE_FINAL) AS TOTAL_RATE_FINAL_SUB,
				'','TOTAL',NULL
		FROM #EMP_CATEGORY_WISE_RECORDS CR
		GROUP BY CR.EMP_ID
   END

   select ID,EMP_ID,EMP_FULL_NAME,CMP_ID,CAT_ID,ForDate,CANTEEN_CAT_NAME,QUANTITY,COMPANY_RATE as EMPLOYEE_CONTRIBUTION_RATE,COMPANY_RATE_TOTAL as AMOUNT_OF_EMPLOYEES_CONTRIBUTION
   ,SUBSIDY_RATE as SUBSIDY_BORN_BY_COMPANY_RATE
   ,SUBSIDY_RATE_TOTAL as AMOUNT_OF_SUBSIDY_BORN_BY_COMPANY
   ,TOTAL_RATE_FINAL as TOTAL_AMOUNT
   from #EMP_CATEGORY_WISE_RECORDS

   --select * from #EMP_CANTEEN_CONTRIBUTION_AMOUNT

   --select * from #EMP_CAT_WISE_COUNT

   DROP TABLE #EMP_CATEGORY_WISE_RECORDS
   DROP TABLE #EMP_DETAILS
   DROP TABLE #EMP_CONS
   DROP TABLE #EMP_EFFECTDATE
   DROP TABLE #EMP_CANTEEN_CONTRIBUTION_AMOUNT
   DROP TABLE #EMP_CAT_WISE_COUNT
    
END