--exec  SP_RPT_EMP_CANTEEN_ESS_COUNT 13961,119,2,2021,9,'S'
CREATE PROCEDURE [dbo].[SP_RPT_EMP_CANTEEN_ESS_COUNT]
	@EmpID numeric(18,0),
	@CmpID numeric(18,0),
	--@Month int,
	--@Year int,
	@FromDate Datetime,
	@ToDate Datetime,
	@CatID numeric(18,0),
	@Type Char(1)

AS

IF @Type = 'S'  --Add Category,employee,date wise count for the limit on single category.
BEGIN  

	 --DECLARE @EmpID numeric(18,0)
	 --DECLARE @CmpID numeric(18,0)
	 --DECLARE @CatID numeric(18,0)
	  
	 --DECLARE @FROM_DATE  DATETIME     
	 --DECLARE @TO_DATE  DATETIME 
	 DECLARE @From_Date datetime
	 DECLARE @To_Date datetime
	 DECLARE @CONSTRAINT varchar(MAX) 
	 DECLARE @CURR_COMPANY_AMOUNT NUMERIC(18,2)
	 DECLARE @CURR_SUBSIDY_AMOUNT NUMERIC(18,2)
	 DECLARE @CURR_TOTAL_AMOUNT NUMERIC(18,2)

	 DECLARE @ForDate DATETIME
	 DECLARE @Quantity NUMERIC
	 DECLARE @ID NUMERIC

	 --SET  @EmpID=24731
	 --SET @CmpID=150
	 --SET @CatID=9

	 --SET @TO_DATE =  GETDATE()

     --SET @From_Date = (SELECT CONVERT(DATE,DATEADD(dd,-(DAY(GETDATE())-1),GETDATE())))
	 --SET @To_Date= CONVERT(DateTime,CONVERT(Char(10), @To_Date, 103), 103);
	 
	 SET @From_Date = @FromDate
	 SET @To_Date = @ToDate
	 SET @CONSTRAINT = cast(@EmpID as varchar(20))
	   
	--IF DATEDIFF(D,@From_Date,@To_Date)>31 
	 --BEGIN
		--SET @To_Date=DATEADD(D,-1,DATEADD(MM,1,@From_Date))				
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
	EXEC SP_RPT_FILL_EMP_CONS  @CmpID,@FROM_DATE,@TO_DATE,0,0,0,0,0,0 ,0 ,@CONSTRAINT,0 ,0 ,0,0,0,0,0,0,0,0,0,0

	--INITIAL ADD FOR GRD_ID FOR MAPPING WITH CANTEEN PUNCH
	
	INSERT INTO  #EMP_DETAILS
	SELECT TI.Emp_ID,ti.Branch_ID,TI.Increment_ID,TI.GRD_ID
	from T0095_INCREMENT TI WITH(NOLOCK)
	where TI.Increment_ID in (select Increment_ID from #EMP_CONS)
	 
	 
	INSERT INTO #EMP_CAT_WISE_COUNT
	SELECT @EmpID,@CmpID,EP.Canteen_ID,ISNULL(SUM (Quantity),0) as Quantity,''
	FROM T0150_EMP_CANTEEN_PUNCH EP WITH(NOLOCK)
	where  EP.Emp_ID=@EmpID
	   AND EP.Cmp_ID=@CmpID
	   AND CAST(EP.Canteen_Punch_Datetime AS DATE) between @FROM_DATE and @TO_DATE
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
    DECLARE @grd_id NUMERIC

   IF @CatID = 0
   BEGIN
			
		   INSERT INTO #EMP_CATEGORY_WISE_RECORDS
		   select CP.Emp_ID,CP.Cmp_ID,CP.Canteen_ID,CP.Canteen_Punch_Datetime,0,0,CP.Quantity,0,0,0,0,grd_id
		   from T0150_EMP_CANTEEN_PUNCH  CP WITH(NOLOCK)
		   INNER JOIN T0080_EMP_MASTER EM WITH(NOLOCK) ON EM.Emp_ID = CP.Emp_ID
		   where CP.Emp_ID =@EmpID  AND CP.Cmp_ID = @CmpID 
		   and CP.Canteen_ID IN (SELECT CAT_ID FROM #EMP_CAT_WISE_COUNT)
		   and CAST(CP.Canteen_Punch_Datetime as DATE)  between @FROM_DATE and @TO_DATE 

		   

		   	----select dates as effective
			--INSERT INTO #EMP_EFFECTDATE
			--			SELECT I2.Tran_Id,I2.Cnt_Id,I2.Amount,I2.Subsidy_Amount,I2.Total_Amount,I2.Effective_Date 
			--			FROM T0050_CANTEEN_DETAIL I2 INNER JOIN
			--		    ( SELECT	MAX(Effective_Date) AS CANTEEN_EFFECTIVE_DATE, I3.Tran_Id
			--						 FROM	T0050_CANTEEN_DETAIL I3  WITH (NOLOCK) INNER JOIN #EMP_DETAILS E3 ON I3.grd_id=E3.GRD_ID AND i3.Cnt_Id IN (SELECT CAT_ID FROM #EMP_CAT_WISE_COUNT)
			--						 WHERE	I3.Effective_Date <= @To_Date and Cmp_Id = @CmpID
			--						 GROUP BY I3.CNT_ID,Tran_Id
			--		    ) I3 ON I2.Effective_Date=I3.CANTEEN_EFFECTIVE_DATE AND I2.Tran_Id=I3.Tran_Id	
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

										 --print @ForDate

										 select @Eff_Date = Max(cast(EFFECT_DATE as date)), 
											   @EFF_COMPANY_AMOUNT = EFF_COMPANY_AMOUNT,
											   @EFF_SUBSIDY_AMOUNT = EFF_SUBSIDY_AMOUNT,
											   @EFF_TOTAL_AMOUNT = TOTAL_AMOUNT
										 from #EMP_EFFECTDATE EF 
										 where cast(EF.EFFECT_DATE as Date) < = @ForDate
												and  EF.CAT_ID = @CatID_ALL and grd_id = @grd_id
										 Group by EFF_COMPANY_AMOUNT,EFF_SUBSIDY_AMOUNT,TOTAL_AMOUNT
										  
   										SELECT @Eff_Date_Latest = Max(cast(EFFECT_DATE as date)), 
												@CURR_COMPANY_AMOUNT = EFF_COMPANY_AMOUNT,
												@CURR_SUBSIDY_AMOUNT = EFF_SUBSIDY_AMOUNT,
												@CURR_TOTAL_AMOUNT = TOTAL_AMOUNT
										from #EMP_EFFECTDATE EF 
										where cast(EF.EFFECT_DATE as Date) <= CAST(GETDATE() as DATE)
										    and  EF.CAT_ID = @CatID_ALL  and grd_id = @grd_id
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
										 where ID=@ID and 
										 CAT_ID=@CatID_ALL and grd_id = @grd_id 
										   
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
		ELSE
		BEGIN
			
			 INSERT INTO #EMP_CATEGORY_WISE_RECORDS
			 SELECT @EmpID,@CmpID,@CatID,'',0,0,0,0,0,0,0,0
		END
		  	 
   END
   ELSE
   BEGIN
			
		   INSERT INTO #EMP_CATEGORY_WISE_RECORDS
		   select CP.Emp_ID,CP.Cmp_ID,CP.Canteen_ID,CP.Canteen_Punch_Datetime,0,0,CP.Quantity,0,0,0,0,grd_id
		   from T0150_EMP_CANTEEN_PUNCH  CP WITH(NOLOCK)
		    INNER JOIN T0080_EMP_MASTER EM WITH(NOLOCK) ON EM.Emp_ID = CP.Emp_ID
		   where CP.Emp_ID =@EmpID AND CP.Cmp_ID = @CmpID
		   and CP.Canteen_ID = @CatID  
		   and CAST(CP.Canteen_Punch_Datetime as DATE)  between @FROM_DATE and @TO_DATE

		   
		   	----select dates as effective
			--INSERT INTO #EMP_EFFECTDATE
			--			SELECT I2.Tran_Id,I2.Cnt_Id,I2.Amount,I2.Subsidy_Amount,I2.Total_Amount,I2.Effective_Date 
			--			FROM T0050_CANTEEN_DETAIL I2 INNER JOIN
			--		    ( SELECT	MAX(Effective_Date) AS CANTEEN_EFFECTIVE_DATE, I3.Tran_Id
			--						 FROM	T0050_CANTEEN_DETAIL I3  WITH (NOLOCK) INNER JOIN #EMP_DETAILS E3 ON I3.grd_id=E3.GRD_ID AND i3.Cnt_Id=@CatID
			--						 WHERE	I3.Effective_Date <= @To_Date and Cmp_Id = @CmpID
			--						 GROUP BY I3.CNT_ID,Tran_Id
			--		    ) I3 ON I2.Effective_Date=I3.CANTEEN_EFFECTIVE_DATE AND I2.Tran_Id=I3.Tran_Id	
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
							 where ID=@ID and 
										 CAT_ID=@CatID and grd_id = @grd_id
					   
								
							END TRY
							BEGIN CATCH 
							END CATCH
							FETCH NEXT FROM CANTEEN_CURSOR INTO @CmpID,@EmpID,@ForDate,@CatID,@Quantity,@ID,@grd_id
						END
					CLOSE CANTEEN_CURSOR     
					DEALLOCATE CANTEEN_CURSOR
	   
			END
			ELSE
			BEGIN
				 INSERT INTO #EMP_CATEGORY_WISE_RECORDS
				 SELECT @EmpID,@CmpID,@CatID,'',0,0,0,0,0,0,0,0
			END
		  	
   END
      
	  
	--Declare @CanteenName varchar(50)
	
	--IF @CatID > 0
	--BEGIN
	--	SELECT @CanteenName = Cnt_Name
	--	FROM T0050_CANTEEN_MASTER 
	--	WHERE Cnt_Id = @CatID
	--END 
	--ELSE
	--BEGIN
	--	SET @CanteenName = ''
	--END


	 --Declare @Eff_Date_Latest Datetime

      --SELECT @Eff_Date_Latest = Max(cast(EFFECT_DATE as date)), 
		--	 @CURR_COMPANY_AMOUNT = EFF_COMPANY_AMOUNT,
		--	 @CURR_SUBSIDY_AMOUNT = EFF_SUBSIDY_AMOUNT,
		--	 @CURR_TOTAL_AMOUNT = TOTAL_AMOUNT
	 --from #EMP_EFFECTDATE EF 
	 --where cast(EF.EFFECT_DATE AS DATE) <= CAST(GETDATE() as DATE)
		--  AND EF.CAT_ID = @CatID
	 --Group by EFF_COMPANY_AMOUNT,EFF_SUBSIDY_AMOUNT,TOTAL_AMOUNT


  -- INSERT INTO #EMP_CANTEEN_CONTRIBUTION_AMOUNT 
  -- SELECT @EmpID,ED.BRANCH_ID,ED.INCREMENT_ID,ED.GRD_ID,@CatID,@CanteenName,
  --        SUM(ECW.COMPANY_RATE_TOTAL),SUM(ECW.SUBSIDY_RATE_TOTAL),
		--  SUM(ECW.QUANTITY),SUM(ECW.TOTAL_RATE_FINAL),
		--  ISNULL(@CURR_COMPANY_AMOUNT,0),ISNULL(@CURR_SUBSIDY_AMOUNT,0),ISNULL(@CURR_TOTAL_AMOUNT,0)
  -- FROM #EMP_CATEGORY_WISE_RECORDS ECW
  -- INNER JOIN #EMP_DETAILS ED ON ED.EMP_ID = ECW.EMP_ID
  -- group by ECW.EMP_ID,ED.BRANCH_ID,ED.INCREMENT_ID,ED.GRD_ID

  
   IF EXISTS(SELECT 1 FROM #EMP_CAT_WISE_COUNT)
   BEGIN
		 ---
		   -- DECLARE @Result_temp VARCHAR(MAX)
		    DECLARE @CCOUNT_ID NUMERIC
			DECLARE @CountEMP_ID NUMERIC
			DECLARE @CountCMP_ID NUMERIC
			DECLARE @CountCAT_ID NUMERIC
			DECLARE @CountCAT_COUNT NUMERIC(18,2)
			DECLARE @CountRESULT VARCHAR(MAX)
			DECLARE @CategoryName VARCHAR(50)
			DECLARE @CategoryImage VARCHAR(200)

		 	DECLARE CANTEEN_CATEGORY CURSOR  Fast_forward FOR
			SELECT 	COUNT_ID,EMP_ID,CMP_ID,CAT_ID,CAT_COUNT,RESULT FROM #EMP_CAT_WISE_COUNT
			OPEN CANTEEN_CATEGORY
			FETCH NEXT FROM CANTEEN_CATEGORY INTO @CCOUNT_ID,@CountEMP_ID,@CountCMP_ID,@CountCAT_ID,@CountCAT_COUNT,@CountRESULT
			WHILE @@FETCH_STATUS = 0
				BEGIN
				
				BEGIN TRY
					 
					SELECT  @CategoryName = CM.Cnt_Name,
					        @CategoryImage = CASE WHEN ISNULL(CM.Canteen_Image,'') = ''
													THEN 'default_canteen.jpg' 
												  ELSE CM.Canteen_Image END 
					FROM T0050_CANTEEN_MASTER CM WITH(NOLOCK)
					WHERE CM.Cnt_Id = @CountCAT_ID


					 SELECT @Eff_Date_Latest = Max(cast(EFFECT_DATE as date)), 
							 @CURR_COMPANY_AMOUNT = EFF_COMPANY_AMOUNT,
							 @CURR_SUBSIDY_AMOUNT = EFF_SUBSIDY_AMOUNT,
							 @CURR_TOTAL_AMOUNT = TOTAL_AMOUNT
					 from #EMP_EFFECTDATE EF 
					 where cast(EF.EFFECT_DATE AS DATE) <= CAST(GETDATE() as DATE)
						  AND EF.CAT_ID = @CountCAT_ID
					 Group by EFF_COMPANY_AMOUNT,EFF_SUBSIDY_AMOUNT,TOTAL_AMOUNT

					 

				   INSERT INTO #EMP_CANTEEN_CONTRIBUTION_AMOUNT 
				   SELECT @EmpID,ED.BRANCH_ID,ED.INCREMENT_ID,ED.GRD_ID,@CountCAT_ID,@CategoryName,
						  SUM(ECW.COMPANY_RATE_TOTAL),SUM(ECW.SUBSIDY_RATE_TOTAL),
						  SUM(ECW.QUANTITY),SUM(ECW.TOTAL_RATE_FINAL),
						  ISNULL(@CURR_COMPANY_AMOUNT,0),ISNULL(@CURR_SUBSIDY_AMOUNT,0),ISNULL(@CURR_TOTAL_AMOUNT,0)
				   FROM #EMP_CATEGORY_WISE_RECORDS ECW
				   INNER JOIN #EMP_DETAILS ED ON ED.EMP_ID = ECW.EMP_ID
				   where ECW.CAT_ID = @CountCAT_ID
				   group by ECW.EMP_ID,ED.BRANCH_ID,ED.INCREMENT_ID,ED.GRD_ID
				    
					
					set @CountRESULT = @CountRESULT 
											  +'<div class="col-lg-3 col-xs-6" id="TD_Canteen_Details '+ CONVERT(VARCHAR,@CCOUNT_ID) +' "runat="server" visible="false">'
											  +'<div class="small-box bg-aqua"><div class="inner"><h3>'
											  +'<asp:Label ID="lblcan'+ Lower(dbo.RemoveSpecialChars(@CategoryName)) + 'total" runat="server" Text="'+ CONVERT(VARCHAR,@CountCAT_COUNT) +'" CssClass="lblcat' +
											   Lower(dbo.RemoveSpecialChars(@CategoryName)) +'"></asp:Label>'
											  +'</h3><p>'+ @CategoryName +'</p></div><div class="icon"><img src="../images/CanteenDashboard/' + @CategoryImage + '" />'
											  +'</div></div></div></div>'

					 UPDATE  #EMP_CAT_WISE_COUNT
					 SET  RESULT = @CountRESULT
					 WHERE COUNT_ID=@CCOUNT_ID
					   
					END TRY
					BEGIN CATCH 
					END CATCH
					FETCH NEXT FROM CANTEEN_CATEGORY INTO @CCOUNT_ID,@CountEMP_ID,@CountCMP_ID,@CountCAT_ID,@CountCAT_COUNT,@CountRESULT
				END
			CLOSE CANTEEN_CATEGORY     
			DEALLOCATE CANTEEN_CATEGORY
		  
   END
   ELSE
   BEGIN
		 INSERT INTO #EMP_CAT_WISE_COUNT
		 SELECT @EmpID,@CmpID,0,0,''
   END

   --select * from #EMP_CATEGORY_WISE_RECORDS

   select * from #EMP_CANTEEN_CONTRIBUTION_AMOUNT

   select * from #EMP_CAT_WISE_COUNT

   DROP TABLE #EMP_CATEGORY_WISE_RECORDS
   DROP TABLE #EMP_DETAILS
   DROP TABLE #EMP_CONS
   DROP TABLE #EMP_EFFECTDATE
   DROP TABLE #EMP_CANTEEN_CONTRIBUTION_AMOUNT
   DROP TABLE #EMP_CAT_WISE_COUNT

END