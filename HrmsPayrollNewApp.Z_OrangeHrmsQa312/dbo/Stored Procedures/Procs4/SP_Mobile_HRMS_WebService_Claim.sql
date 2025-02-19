CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_Claim]
	@Claim_App_ID NUMERIC(18,0),
	@Claim_App_Detail_ID NUMERIC(18,0),
	@Emp_ID NUMERIC(18,0),
	@Cmp_ID	NUMERIC(18,0),
	@Claim_ID NUMERIC(18,0),
	@SEmp_ID NUMERIC(18,0),
	@ForDate DATETIME,
	@ToDate DATETIME,
	@Claim_App_Amount NUMERIC(18,2),
	@Claim_Description VARCHAR(255),
	@Claim_Attachment VARCHAR(MAX),
	@Claim_App_Status VARCHAR(1),
	@Flag TINYINT,
	@Claim_Details XML,
	@Rpt_Level INT,
	@Final_Approve INT,
	@Is_Fwd_Leave_Rej INT,
	@IMEINO VARCHAR(100),
	@Login_ID NUMERIC(18,0),
	@Type CHAR(2),
	@Result VARCHAR(100) OUTPUT
AS

--DECLARE @Claim_Date Datetime
DECLARE @Claim_Amount NUMERIC(18,2)
DECLARE @Description VARCHAR(255)
DECLARE @Curr_ID NUMERIC(18,0)
DECLARE @Curr_Rate NUMERIC(18,2)
--DECLARE @Kilometer NUMERIC(18,2)
DECLARE @Claim_App_Code VARCHAR(50)
DECLARE @Is_Mobile_Entry TinyInt


IF @Type = 'B' --- For Bind Records
	BEGIN
		--SELECT Claim_ID,Cmp_ID,Claim_Name,Claim_Max_Limit,Desig_Wise_Limit,ISNULL(Grade_Wise_Limit,0) AS 'Grade_Wise_Limit',
		--ISNULL(Branch_Wise_Limit,0) AS 'Branch_Wise_Limit',ISNULL(Claim_Limit_Type,0) AS 'Claim_Limit_Type',
		--ISNULL(Claim_Type,0) AS 'Claim_Type',ISNULL(Attach_Mandatory,0) AS 'Attach_Mandatory',
		--ISNULL(CLAIM_ALLOW_BEYOND_LIMIT,0) AS 'CLAIM_ALLOW_BEYOND_LIMIT'
		--FROM T0040_Claim_Master
		--WHERE Cmp_ID = @Cmp_ID
	
		DECLARE @Desig_ID INT
		DECLARE @Branch_ID INT
		DECLARE @Grd_ID INT
		DECLARE @Basic_Wise_Limit varchar(100)
		DECLARE @Gross_Wise_Limit numeric(18,4)
		DECLARE @Applicable_Only_Once tinyint
		
		SELECT @Desig_ID = Desig_Id,@Branch_ID = Branch_ID,@Grd_ID = Grd_ID
		,@Basic_Wise_Limit = Basic_Salary
		,@Gross_Wise_Limit = Gross_Salary -- Added By Niraj for Feature #17958 as on 29/06/2021 
		FROM V0080_Employee_Master 
		WHERE Emp_ID = @Emp_ID

		SELECT
		CM.Claim_ID,CM.Claim_Name
		,CASE WHEN Basic_Salary_wise = 1 THEN @Basic_Wise_Limit
			 WHEN Gross_Salary_wise = 1 THEN @Gross_Wise_Limit
             ELSE CM.Claim_Max_Limit END AS Claim_Max_Limit
		,ISNULL(Grade_Wise_Limit,0) AS 'Grade_Wise_Limit',
		ISNULL(Branch_Wise_Limit,0) AS 'Branch_Wise_Limit',ISNULL(Desig_Wise_Limit,0) AS 'Desig_Wise_Limit'
		,ISNULL(Claim_Limit_Type,0) AS 'Claim_Limit_Type',
		ISNULL(Claim_Type,0) AS 'Claim_Type',ISNULL(Attach_Mandatory,0) AS 'Attach_Mandatory',
		ISNULL(Claim_Allow_Beyond_Limit,0) AS 'Claim_Allow_Beyond_Limit'
		,ISNULL(Basic_Salary_wise,0) AS 'Basic_Salary_Wise_Limit' -- Added By Niraj for Feature #17958 as on 29/06/2021 
		,ISNULL(Gross_Salary_wise,0) AS 'Gross_Salary_Wise_Limit' -- Added By Niraj for Feature #17958 as on 29/06/2021 
		,ISNULL(Applicable_Once,0) AS 'Applicable_Only_Once_Limit' -- Added By Niraj for Feature #17958 as on 29/06/2021 
		,ISNULL(Gender_Wise,0) AS 'Gender_Wise_Limit' -- Added By Niraj for Feature #17958 as on 29/06/2021 
		,ISNULL(For_Gender,Null) AS 'For_Gender' -- Added By Niraj for Feature #17958 as on 08/09/2021 
		,ISNULL(No_Of_Year_Limit,0) AS 'No_Of_Year_Limit' -- Added By Niraj for Feature #17958 as on 29/06/2021 
		--,case when CM.Claim_Max_Limit = 0 then Max_Limit_Km else CM.Claim_Max_Limit end as Max_Limit_Km  ,Rate_Per_Km 
		--,case when CM.Claim_Max_Limit = 0 then Max_Limit_Km else case when CM.Claim_Max_Limit = 0  then 0 else CM.Claim_Max_Limit end end as Max_Limit_Km  
		,case when CM.Claim_Max_Limit = 0 then case when  Max_Limit_Km is null   then 0 else Max_Limit_Km end  else CM.Claim_Max_Limit end as Max_Limit_Km  
		,Rate_Per_Km 
		FROM T0040_Claim_master CM 
		Left Outer JOIN T0041_Claim_Maxlimit_Design CMD ON CM.Claim_ID = CMD.Claim_ID 
		WHERE CM.Cmp_ID = @Cmp_ID AND ((CMD.Branch_ID = @Branch_ID OR CMD.Desig_ID = @Desig_ID OR CMD.Grade_ID = @Grd_ID
		)
		OR (CMD.Branch_ID IS NULL AND CMD.Desig_ID IS NULL AND CMD.Grade_ID IS NULL))

		
		SELECT * FROM T0040_SETTING where Group_By like '%Claim%' and Cmp_ID = @Cmp_ID


	END
ELSE IF @Type = 'L' --- For Claim Limit Validation
	BEGIN
		DECLARE @Claim_Type int
		DECLARE @Claim_Limit_Type int
		SELECT @Claim_Type = Claim_Type,@Claim_Limit_Type = Claim_Limit_Type FROM T0040_CLAIM_MASTER WHERE Claim_ID = @Claim_ID
		
		IF @Claim_Type = 0
			BEGIN
					IF @Claim_Limit_Type = 0
					BEGIN
						SELECT Qry.Claim_ID,Qry.ClaimAmount FROM
						(
							SELECT ISNULL(SUM(CAD.Claim_Amount),0) AS 'ClaimAmount',CA.Claim_ID 
							FROM T0110_CLAIM_APPLICATION_DETAIL CAD 
							INNER JOIN T0100_CLAIM_APPLICATION CA ON CA.Claim_App_ID = CAD.Claim_App_ID
							INNER JOIN T0040_CLAIM_MASTER CM ON CM.Claim_ID = CAD.Claim_ID AND CM.Cmp_ID = CAD.Cmp_ID 
							WHERE CAD.Cmp_ID = @Cmp_ID AND CAD.For_Date = @ForDate AND CA.Emp_ID = @Emp_ID 
							AND CA.Claim_App_Status = 'P' AND CAD.Claim_App_ID <> 0 AND CM.Claim_ID = @Claim_ID 
							GROUP BY CA.Claim_ID

							UNION ALL

							SELECT ISNULL(SUM(CAD.Claim_Apr_Amount),0) AS 'ClaimAmount',CA.Claim_ID
							FROM T0130_CLAIM_APPROVAL_DETAIL CAD
							INNER JOIN T0120_CLAIM_APPROVAL CA ON CA.Claim_Apr_ID = CAD.Claim_Apr_ID
							INNER JOIN T0040_CLAIM_MASTER CM ON CM.Claim_ID = CAD.Claim_ID AND CM.Cmp_ID = CAD.Cmp_ID 
							WHERE CAD.Cmp_ID = @Cmp_ID AND CAD.Claim_Apr_Date = @ForDate AND CA.Emp_ID = @Emp_ID 
							AND CAD.Claim_Status = 'A' AND CM.Claim_ID = @Claim_ID 
							GROUP BY CA.Claim_ID
						) Qry
					END
					ELSE
					BEGIN
						
						--SELECT TBL.Claim_ID,TBL.ClaimAmount FROM
						--(
						--	SELECT ISNULL(SUM(CAD.Claim_Amount),0) AS 'ClaimAmount',CA.Claim_ID
						--	FROM T0110_CLAIM_APPLICATION_DETAIL CAD 
						--	INNER JOIN T0100_CLAIM_APPLICATION CA ON CA.Claim_App_ID = CAD.Claim_App_ID
						--	INNER JOIN T0040_CLAIM_MASTER CM ON CM.Claim_ID = CAD.Claim_ID AND CM.Cmp_ID = CAD.Cmp_ID 
						--	WHERE CAD.Cmp_ID = @Cmp_ID AND CA.Emp_ID = @Emp_ID AND CA.Claim_App_Status = 'P' AND CAD.Claim_App_ID <> 0 
						--	AND CM.Claim_ID = @Claim_ID AND MONTH(CAD.For_Date) = MONTH(@ForDate) AND YEAR(CAD.For_Date) = YEAR(@ForDate) 
						--	GROUP BY CA.Claim_ID

						--	UNION ALL

						--	SELECT ISNULL(SUM(CAD.Claim_Apr_Amount),0) AS 'ClaimAmount',CA.Claim_ID
						--	FROM T0130_CLAIM_APPROVAL_DETAIL CAD 
						--	INNER JOIN T0120_CLAIM_APPROVAL CA ON CA.Claim_Apr_ID = CAD.Claim_Apr_ID 
						--	INNER JOIN T0040_CLAIM_MASTER CM ON CM.Claim_ID = CAD.Claim_ID AND CM.Cmp_ID = CAD.Cmp_ID 
						--	WHERE CAD.Cmp_ID = @Cmp_ID AND CA.Emp_ID = @Emp_ID AND CAD.Claim_Status = 'A' AND CM.Claim_ID = @Claim_ID
						--	AND MONTH(CAD.Claim_Apr_Date) = MONTH(@ForDate) AND YEAR(CAD.Claim_Apr_Date) = YEAR(@ForDate) 
						--	GROUP BY CA.Claim_ID
						--) TBL
						
						SELECT TBL.Claim_ID,sum(TBL.ClaimAmount) as ClaimAmount FROM
						(
							SELECT ISNULL(SUM(CAD.Claim_Amount),0) AS 'ClaimAmount',CAD.Claim_ID
							FROM T0110_CLAIM_APPLICATION_DETAIL CAD 
							INNER JOIN T0100_CLAIM_APPLICATION CA ON CA.Claim_App_ID = CAD.Claim_App_ID
							INNER JOIN T0040_CLAIM_MASTER CM ON CM.Claim_ID = CAD.Claim_ID AND CM.Cmp_ID = CAD.Cmp_ID 
							WHERE CAD.Cmp_ID = @Cmp_ID AND CA.Emp_ID = @Emp_ID AND CA.Claim_App_Status = 'P' AND CAD.Claim_App_ID <> 0 
							AND CM.Claim_ID = @Claim_ID AND MONTH(CAD.For_Date) = MONTH(@ForDate) AND YEAR(CAD.For_Date) = YEAR(@ForDate) 
							GROUP BY CAD.Claim_ID

							UNION ALL

							SELECT ISNULL(SUM(CAD.Claim_Apr_Amount),0) AS 'ClaimAmount',CAD.Claim_ID
							FROM T0130_CLAIM_APPROVAL_DETAIL CAD 
							INNER JOIN T0120_CLAIM_APPROVAL CA ON CA.Claim_Apr_ID = CAD.Claim_Apr_ID 
							INNER JOIN T0040_CLAIM_MASTER CM ON CM.Claim_ID = CAD.Claim_ID AND CM.Cmp_ID = CAD.Cmp_ID 
							WHERE CAD.Cmp_ID = @Cmp_ID AND CA.Emp_ID = @Emp_ID AND CAD.Claim_Status = 'A' AND CM.Claim_ID = @Claim_ID
							AND MONTH(CAD.Claim_Apr_Date) = MONTH(@ForDate) AND YEAR(CAD.Claim_Apr_Date) = YEAR(@ForDate) 
							GROUP BY CAD.Claim_ID
						) TBL group by Claim_ID
						
						
					END
			END
		ELSE
			BEGIN
				
				SELECT TBL.Claim_ID,TBL.ClaimAmount FROM
				(
					SELECT ISNULL(SUM(CAD.Claim_Amount),0) AS 'ClaimAmount',CA.Claim_ID
					FROM T0110_CLAIM_APPLICATION_DETAIL CAD 
					INNER JOIN T0100_CLAIM_APPLICATION CA ON CA.Claim_App_ID = CAD.Claim_App_ID
					INNER JOIN T0040_CLAIM_MASTER CM ON CM.Claim_ID = CAD.Claim_ID AND CM.Cmp_ID = CAD.Cmp_ID 
					WHERE CAD.Cmp_ID = @Cmp_ID AND CA.Emp_ID = @Emp_ID AND CA.Claim_App_Status = 'P' AND CAD.Claim_App_ID <> 0 
					AND CM.Claim_ID = @Claim_ID AND MONTH(CAD.For_Date) = MONTH(@ForDate) AND YEAR(CAD.For_Date) = YEAR(@ForDate) 
					GROUP BY CA.Claim_ID

					UNION ALL

					SELECT ISNULL(SUM(CAD.Claim_Apr_Amount),0) AS 'ClaimAmount',CA.Claim_ID
					FROM T0130_CLAIM_APPROVAL_DETAIL CAD 
					INNER JOIN T0120_CLAIM_APPROVAL CA ON CA.Claim_Apr_ID = CAD.Claim_Apr_ID 
					INNER JOIN T0040_CLAIM_MASTER CM ON CM.Claim_ID = CAD.Claim_ID AND CM.Cmp_ID = CAD.Cmp_ID 
					WHERE CAD.Cmp_ID = @Cmp_ID AND CA.Emp_ID = @Emp_ID AND CAD.Claim_Status = 'A' AND CM.Claim_ID = @Claim_ID
					AND MONTH(CAD.Claim_Apr_Date) = MONTH(@ForDate) AND YEAR(CAD.Claim_Apr_Date) = YEAR(@ForDate) 
					GROUP BY CA.Claim_ID
				) TBL

			END
	END	
ELSE IF @Type = 'I' OR @Type = 'U' or @Type = 'F'--- For Claim Application
	BEGIN	

			--Select count(1) from T0100_CLAIM_APPLICATION CA left outer join T0040_CLAIM_MASTER CM on 
			--CA.Claim_ID = CM.Claim_ID and CA.Cmp_ID = CM.Cmp_ID where EMP_ID = @Emp_ID and CM.Cmp_ID = @Cmp_ID
			--and Claim_App_Status <> 'R' and CA.Claim_ID = @Claim_ID and CM.Claim_ApplicableOnceBasedOnLimit = 1

			-- Start Added By Niraj(05102021) - Suggestions #19091
			IF ((Select count(1) from T0100_CLAIM_APPLICATION CA left outer join T0040_CLAIM_MASTER CM on 
			CA.Claim_ID = CM.Claim_ID and CA.Cmp_ID = CM.Cmp_ID where EMP_ID = @Emp_ID and CM.Cmp_ID = @Cmp_ID
			and Claim_App_Status <> 'R' and CA.Claim_ID = @Claim_ID and CM.Claim_ApplicableOnceBasedOnLimit = 1)> 0)
			Begin
				SET @Result = 'This claim is not allowed.#False#0'
				Select @Result as Result
				
				



				Return
			End
			-- End Added By Niraj(05102021) - Suggestions #19091
		   
			EXEC P0100_CLAIM_APPLICATION @Claim_App_ID = @Claim_App_ID OUTPUT,@Claim_ID = @Claim_ID,@Cmp_ID = @Cmp_ID,
			@Emp_ID = @Emp_ID,@Claim_App_Date = @ForDate,@Claim_App_Code = @Claim_App_Code OUTPUT,@Claim_App_Amount = @Claim_App_Amount,
			@Claim_App_Status = 'P',@Claim_App_Description = @Claim_Description,@Claim_App_Docs = @Claim_Attachment,
			@tran_type = @Type,@S_Emp_ID = @SEmp_ID,@Submit_Flag = @Flag,@User_Id = @Login_ID,@IP_Address = @IMEINO,@Is_Mobile_Entry=1
			
			IF @Claim_App_Code = 0
			BEGIN 
				SET @Result = 'Same Claim on Same Application Date is already exists#False#0'
				Select @Result
			END
			ELSE
			BEGIN
				DECLARE @Status AS TINYINT
				DECLARE @CurrencyID as NUMERIC(18,0)
				DECLARE @Descriptions as varchar(255)
				DECLARE @ClaimID as NUMERIC(18,0)
				DECLARE @CurrencyRate as NUMERIC(18,0)
				DECLARE @ClaimDate as varchar(30)
				DECLARE @ClaimAmount as NUMERIC(18,0)
				DECLARE @Kilometer as NUMERIC(18,0)
				DECLARE @Claim_Date Datetime
				Declare @Attachment Varchar(255)
		
				SET @STATUS = 0
				
				IF (@Claim_Details.exist('/NewDataSet/ClaimDetails') = 1)
				BEGIN
					
					--SELECT Table1.value('(ClaimDate/text())[1]','varchar(20)') AS ClaimDate,
					--	Table1.value('(ClaimAmount/text())[1]','numeric(18,2)') AS ClaimAmount,
					--	Table1.value('(Description/text())[1]','varchar(255)') AS Descriptions,
					--	Table1.value('(ClaimID/text())[1]','numeric(18,0)') AS ClaimID,
					--	Table1.value('(CurrencyID/text())[1]','numeric(18,0)') AS CurrencyID,
					--	Table1.value('(CurrencyRate/text())[1]','numeric(18,2)') AS CurrencyRate,
					--	Table1.value('(Kilometer/text())[1]','numeric(18,2)') AS Kilometer,
					--	Table1.value('(Attachment/text())[1]','varchar(255)') AS Attachment
					--	--Table1.value('(ApprovalKilometer/text())[1]','numeric(18,2)') AS ApprovalKilometer,
					--	--Table1.value('(ClaimAprAmount/text())[1]','numeric(18,2)') AS ClaimAprAmount,
					--	--Table1.value('(ApprvoalStatus/text())[1]','varchar(5)') AS ApprvoalStatus
					--	INTO #ClaimDetailsTemp FROM @Claim_Details.nodes('/NewDataSet/ClaimDetails') AS Temp(Table1)

					--select @Claim_Details

						SELECT Table1.value('(For_Date/text())[1]','datetime') AS ClaimDate,
						Table1.value('(Claim_App_Amount/text())[1]','numeric(18,2)') AS ClaimAmount,
						Table1.value('(Claim_Description/text())[1]','varchar(255)') AS Descriptions,
						Table1.value('(ClaimID/text())[1]','numeric(18,0)') AS ClaimID,
						Table1.value('(CurrencyID/text())[1]','numeric(18,0)') AS CurrencyID,
						Table1.value('(CurrencyRate/text())[1]','numeric(18,2)') AS CurrencyRate,
						Table1.value('(Petrol_Km/text())[1]','numeric(18,2)') AS Kilometer,
						Table1.value('(Claim_Attachment/text())[1]','varchar(255)') AS Attachment
						INTO #ClaimDetailsTemp FROM @Claim_Details.nodes('/NewDataSet/ClaimDetails') AS Temp(Table1)
												
						--select * from #ClaimDetailsTemp		
						DECLARE CLAIMDETAIL_CURSOR CURSOR  FAST_FORWARD FOR
						
						SELECT ClaimDate,ClaimAmount,Descriptions,ClaimID,CurrencyID,CurrencyRate, case when Kilometer is null then 0 else Kilometer end as Kilometer ,Attachment
						FROM #ClaimDetailsTemp
						
						OPEN CLAIMDETAIL_CURSOR
						FETCH NEXT FROM CLAIMDETAIL_CURSOR INTO @ClaimDate,@ClaimAmount,@Descriptions,@ClaimID,@CurrencyID
						,@CurrencyRate,@Kilometer,@Attachment

						WHILE @@FETCH_STATUS = 0
							BEGIN TRY
								--IF @Claim_App_Detail_ID = 0
								--	BEGIN
											--print @Cmp_ID
											--print @Claim_App_ID
											--print @ClaimID
											--print @ClaimDate
											--print @ClaimAmount
											--print @Descriptions
											--print @CurrencyID 
											--print @CurrencyRate
											--print @ClaimAmount
											--print @Type
											--print @Attachment
											--print @Kilometer
											--print @Login_ID
											--print @IMEINO
								
						--					Select  @Cmp_ID
						--					, @Claim_App_ID
						--					, @ClaimID
						--					, @ClaimDate
						--					, @ClaimAmount
						--					, @Descriptions
						--					, @CurrencyID
						--					, @CurrencyRate
						--					, @ClaimAmount
						--					, @Type
						--					, @Attachment
						--					, @Kilometer
						--					, @Login_ID
						--					, @IMEINO
						
						--set @Attachment = ''

						EXEC P0110_CLAIM_APPLICATION_DETAIL @Claim_App_Detail_ID OUTPUT
						,@Cmp_ID = @Cmp_ID
						,@Claim_App_ID = @Claim_App_ID,
						@Claim_ID = @ClaimID
						,@For_Date = @ClaimDate
						,@Application_Amount = @ClaimAmount
						,@Description = @Descriptions,
						@Curr_ID = @CurrencyID
						,@Curr_Rate = @CurrencyRate
						,@Claim_Amount = @ClaimAmount
						,@Tran_Type = @Type
						,@Claim_Attachment = @Attachment,
						@Petrol_KM =@Kilometer
						,@User_Id = @Login_ID
						,@IP_Address = @IMEINO
										
										
							IF @Type = 'I' 
							BEGIN
								SET @Result = 'Claim Application Detail Saved Successfully#True#'+CAST(@Claim_App_ID AS varchar(11))
							END

							IF @Type = 'F' 
							BEGIN
								SET @Result = 'Claim Application Draft Detail Saved Successfully#True#'+CAST(@Claim_App_ID AS varchar(11))
							END

							ELSE IF @Type = 'U'
							BEGIN
								SET @Result = 'Claim Application Detail Updated Successfully#True#'+CAST(@Claim_App_ID AS varchar(11))
							END

							SELECT @Result

								--	END
								--ELSE
								--	BEGIN
								--		UPDATE T0110_CLAIM_APPLICATION_DETAIL
								--		SET For_Date = @Claim_Date,Application_Amount = @Claim_Amount,
								--		Claim_Description = @Description,Claim_ID = @Claim_ID,Curr_ID = @Curr_ID,
								--		Curr_Rate = @Curr_Rate,Claim_Amount = @Claim_Amount,Petrol_Km = @Kilometer
								--		WHERE Claim_App_Detail_ID = @Claim_App_Detail_ID AND Claim_App_ID = @Claim_App_ID
										
								--		SET @Result = 'Claim Application Detail Update Successfully#True#'+CAST(@Claim_App_Detail_ID AS varchar(11))
								--		SELECT @Result
								--	END
								 
								FETCH NEXT FROM CLAIMDETAIL_CURSOR INTO @ClaimDate,@ClaimAmount,@Descriptions,@ClaimID,@CurrencyID,@CurrencyRate,@Kilometer,@Attachment
							END TRY
							BEGIN CATCH
								SET @Status = 1
							END CATCH
						CLOSE CLAIMDETAIL_CURSOR
						DEALLOCATE CLAIMDETAIL_CURSOR
				END	
						
			
						
				SET @Result = 'Claim Application Done#True#'+ CAST(@Claim_App_ID AS varchar(11))
			
				DECLARE @DeviceID AS nvarchar(MAX)
				SET @DeviceID = ''
				
				SELECT @Result
				
				SELECT *
				FROM V0100_Claim_Application
				WHERE Claim_App_ID = @Claim_App_ID AND Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID
				
				EXEC SP_Mobile_Get_Notification_ToCC @Emp_ID = @EMP_ID,@Cmp_ID = @Cmp_ID,@Module_Name = 'Claim Application',@Flag = 2,
				@Leave_ID = 0,@Rpt_Level = 0,@Final_Approval = 0
			
			END
		--IF @Type = 'I'
		--	BEGIN
		--		SELECT @Claim_Date = CONVERT(DATETIME, Table1.value('(ClaimDate/text())[1]','varchar(11)'),103),
		--		@Claim_Amount = Table1.value('(ClaimAmount/text())[1]','numeric(18,2)'),
		--		@Description =  Table1.value('(Description/text())[1]','varchar(255)'),
		--		@Claim_ID =  Table1.value('(ClaimID/text())[1]','numeric(18,0)'),
		--		@Curr_ID = Table1.value('(CurrencyID/text())[1]','numeric(18,0)'),
		--		@Curr_Rate =  Table1.value('(CurrencyRate/text())[1]','numeric(18,2)'),
		--		@Kilometer = Table1.value('(Kilometer/text())[1]','numeric(18,2)')
		--		--INTO #ClaimDetailsTemp 
		--		FROM @Claim_Details.nodes('/NewDataSet/ClaimDetails') AS Temp(Table1)
				
		--		print('test')
				
				--IF @Claim_App_Detail_ID = 0
				--	BEGIN
				--		EXEC P0110_CLAIM_APPLICATION_DETAIL @Claim_App_Detail_ID OUTPUT,@Cmp_ID = @Cmp_ID,@Claim_App_ID = @Claim_App_ID,
				--		@Claim_ID = @Claim_ID,@For_Date = @Claim_Date,@Application_Amount = @Claim_Amount,@Description = @Description,
				--		@Curr_ID = @Curr_ID,@Curr_Rate = @Curr_Rate	,@Claim_Amount = @Claim_Amount,@Tran_Type = @Type,@Claim_Attachment = '',
				--		@Petrol_KM = @Kilometer,@User_Id = @Login_ID,@IP_Address = @IMEINO
						
				--		SET @Result = 'Claim Application Detail Insert Successfully#True#'+CAST(@Claim_App_Detail_ID AS varchar(11))
				--		SELECT @Result
				--	END
				--ELSE
				--	BEGIN
				--		UPDATE T0110_CLAIM_APPLICATION_DETAIL
				--		SET For_Date = @Claim_Date,Application_Amount = @Claim_Amount,
				--		Claim_Description = @Description,Claim_ID = @Claim_ID,Curr_ID = @Curr_ID,
				--		Curr_Rate = @Curr_Rate,Claim_Amount = @Claim_Amount,Petrol_Km = @Kilometer
				--		WHERE Claim_App_Detail_ID = @Claim_App_Detail_ID AND Claim_App_ID = @Claim_App_ID
						
				--		SET @Result = 'Claim Application Detail Update Successfully#True#'+CAST(@Claim_App_Detail_ID AS varchar(11))
				--		SELECT @Result
				--	END
			--END
		 			
	END
ELSE IF @Type = 'D'  -- For Delete Claim Application Details
	BEGIN
		--If ((Select count(1) from T0110_CLAIM_APPLICATION_DETAIL where Claim_App_ID = @Claim_App_ID and Cmp_ID = @Cmp_ID) = 1)
		--BEGIN
		--			SET @Result = 'Please Insert atleast one record#False#'
		--			SELECT @Result
		--END
		--ELSE
		--BEGIN
		--			DELETE FROM T0110_CLAIM_APPLICATION_DETAIL WHERE Claim_App_Detail_ID = @Claim_App_Detail_ID AND Claim_App_ID = @Claim_App_ID and Cmp_ID = @Cmp_ID
				
		--			SET @Result = 'Claim Application Detail Delete Successfully#True#'+CAST(@Claim_App_Detail_ID AS varchar(11))
		--			SELECT @Result
		--END
		If ((Select count(1) from T0115_CLAIM_LEVEL_APPROVAL where Claim_App_ID = @Claim_App_ID and Cmp_ID = @Cmp_ID) = 0)
		BEGIN

		
				If ((Select count(1) from T0110_CLAIM_APPLICATION_DETAIL where Claim_App_ID = @Claim_App_ID and Cmp_ID = @Cmp_ID) > 0)
				BEGIN
							DELETE FROM T0110_CLAIM_APPLICATION_DETAIL WHERE Claim_App_ID = @Claim_App_ID and Cmp_ID = @Cmp_ID 
							
							DELETE FROM T0100_CLAIM_APPLICATION WHERE Claim_App_ID = @Claim_App_ID and Cmp_ID = @Cmp_ID 

							SET @Result = 'Claim Application Detail Delete Successfully.#True#'
							SELECT @Result
				END
				ELSE If ((Select count(1) from T0100_CLAIM_APPLICATION where Claim_App_ID = @Claim_App_ID and Cmp_ID = @Cmp_ID) > 0)
				BEGIN
							DELETE FROM T0100_CLAIM_APPLICATION WHERE Claim_App_ID = @Claim_App_ID and Cmp_ID = @Cmp_ID 
							SET @Result = 'Claim Application Detail Delete Successfully.#True#'
							SELECT @Result
				END
				ELSE
				BEGIN
							SET @Result = 'Claim Application Not Found.#False#'
							SELECT @Result
				END
		END
		ELSE
		BEGIN
							SET @Result = 'Application Already Approved By Scheme Manager.#False#'
							SELECT @Result
							return
		END
	END	
ELSE IF @Type = 'S' --- For Claim Application Status
	BEGIN
		SELECT Claim_App_ID,Claim_App_Code,Claim_Name,Claim_App_Date,Claim_App_Amount,Claim_App_Status,
		Cmp_ID,Emp_ID,S_Emp_ID,Emp_code,Alpha_Emp_Code,Emp_Full_Name,Emp_Full_Name_New,Branch_ID,Desig_ID,Grd_ID,
		Draft_status,Submit_Flag,Claim_App_Doc,(CASE WHEN ISNULL(CLAIM_APP_DOC,'') <> '' THEN 'Attached' ELSE 'Not-Attached' END) AS 'Attachment'
		FROM V0100_Claim_Application_New
		WHERE Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID AND Claim_App_Date >= @ForDate AND Claim_App_Date <= @ToDate --AND Claim_App_Status = @Claim_App_Status
		ORDER BY Claim_App_Status DESC
	END
ELSE IF @Type = 'R' --- For Claim Application Records for Approval to Manager
	BEGIN
			--SELECT Distinct C.Claim_App_ID as Code , EM.Emp_Full_Name ,EM.Alpha_Emp_Code ,Cast(Claim_App_Date as date) as Claim_App_Date ,Em.Image_Name
			--,case when Claim_App_Status = 'P' then 'Pending' When Claim_App_Status = 'A' then 'Approved' else 'Rejected' end as [Claim_App_Status]
			--,isnull(Claim_App_Doc,'') as Claim_App_Doc
			--FROM T0100_CLAIM_APPLICATION C WITH (NOLOCK) 
			--inner join T0110_CLAIM_APPLICATION_DETAIL D WITH (NOLOCK)  on c.Claim_App_ID = d.Claim_App_ID
			--Left Join T0080_EMP_MASTER EM WITH (NOLOCK) On EM.Emp_ID = c.Emp_ID 
			--WHERE C.Cmp_ID = @Cmp_ID AND C.Emp_ID = @Emp_ID And Claim_App_Status = @Claim_App_Status AND Claim_App_Date >= @ForDate AND Claim_App_Date <= @ToDate 
			--ORDER BY Claim_App_Status DESC
			
		
		--Added by Prapti 10-03-2022 Start
		IF(@Claim_App_Status = 'P')
		BEGIN
		--SELECT Distinct C.Claim_App_ID as Code , EM.Emp_Full_Name ,EM.Alpha_Emp_Code ,Cast(Claim_App_Date as date) as Claim_App_Date ,Em.Image_Name,
		SELECT Distinct C.Claim_App_ID as Code , EM.Emp_Full_Name ,EM.Alpha_Emp_Code ,Cast(Claim_App_Date as date) as Claim_App_Date ,Em.Image_Name,
		CASE 
		when Claim_App_Status = 'P' then 'Pending' 
		When Claim_App_Status = 'A' then 'Approved' 
		else 'Rejected' end as [Claim_App_Status]
		,isnull(Claim_App_Doc,'') as Claim_App_Doc
		FROM T0100_CLAIM_APPLICATION C WITH (NOLOCK) 
		inner join T0110_CLAIM_APPLICATION_DETAIL D WITH (NOLOCK)  on c.Claim_App_ID = d.Claim_App_ID
		Left Join T0080_EMP_MASTER EM WITH (NOLOCK) On EM.Emp_ID = c.Emp_ID 
		WHERE C.Cmp_ID = @Cmp_ID AND C.Emp_ID = @Emp_ID And Claim_App_Status = @Claim_App_Status and Submit_Flag = 0 AND Claim_App_Date >= @ForDate AND Claim_App_Date <= @ToDate 
		ORDER BY Claim_App_Status DESC
		END
		else IF(@Claim_App_Status = 'A' or @Claim_App_Status = 'R') 
			BEGIN
			
				SELECT Distinct C.Claim_App_ID as Code , EM.Emp_Full_Name ,EM.Alpha_Emp_Code ,Cast(Claim_App_Date as date) as Claim_App_Date ,Em.Image_Name,
				CASE 
				when Claim_App_Status = 'P' then 'Pending' 
				When Claim_App_Status = 'A' then 'Approved' 
				else 'Rejected' end as [Claim_App_Status]
				,isnull(Claim_App_Doc,'') as Claim_App_Doc
				FROM T0100_CLAIM_APPLICATION C WITH (NOLOCK) 
				inner join T0110_CLAIM_APPLICATION_DETAIL D WITH (NOLOCK)  on c.Claim_App_ID = d.Claim_App_ID
				Left Join T0080_EMP_MASTER EM WITH (NOLOCK) On EM.Emp_ID = c.Emp_ID 
				WHERE C.Cmp_ID = @Cmp_ID AND C.Emp_ID = @Emp_ID And Claim_App_Status = @Claim_App_Status and Submit_Flag = 0 AND Claim_App_Date >= @ForDate AND Claim_App_Date <= @ToDate 
				ORDER BY Claim_App_Status DESC
			END
			--ELSE IF(@Claim_App_Status = 'R')
			--BEGIN

			--	SELECT Distinct C.Claim_App_ID as Co	de , EM.Emp_Full_Name ,EM.Alpha_Emp_Code ,Cast(Claim_App_Date as date) as Claim_App_Date ,Em.Image_Name,
			--	CASE 
			--	when Claim_App_Status = 'P' then 'Pending' 
			--	When Claim_App_Status = 'A' then 'Approved' 
			--	else 'Rejected' end as [Claim_App_Status]
			--	,isnull(Claim_App_Doc,'') as Claim_App_Doc
			--	FROM T0100_CLAIM_APPLICATION C WITH (NOLOCK) 
			--	inner join T0110_CLAIM_APPLICATION_DETAIL D WITH (NOLOCK)  on c.Claim_App_ID = d.Claim_App_ID
			--	Left Join T0080_EMP_MASTER EM WITH (NOLOCK) On EM.Emp_ID = c.Emp_ID 
			--	WHERE C.Cmp_ID = @Cmp_ID AND C.Emp_ID = @Emp_ID And Claim_App_Status = @Claim_App_Status and Submit_Flag = 0 AND Claim_App_Date >= @ForDate AND Claim_App_Date <= @ToDate 
			--	ORDER BY Claim_App_Status DESC
			--END
			ELSE 
			BEGIN
			If @Claim_App_Status = 'D' set @Claim_App_Status = 'p'
			
			SELECT Distinct C.Claim_App_ID as Code , EM.Emp_Full_Name ,EM.Alpha_Emp_Code ,Cast(Claim_App_Date as date) as Claim_App_Date ,Em.Image_Name,
				CASE 
				when Submit_Flag=1 and Claim_App_Status = 'P' then 'Drafted' 
				When Claim_App_Status = 'A' then 'Approved' 
				else 'Rejected' end as [Claim_App_Status]
				,isnull(Claim_App_Doc,'') as Claim_App_Doc
				FROM T0100_CLAIM_APPLICATION C WITH (NOLOCK) 
				inner join T0110_CLAIM_APPLICATION_DETAIL D WITH (NOLOCK)  on c.Claim_App_ID = d.Claim_App_ID
				Left Join T0080_EMP_MASTER EM WITH (NOLOCK) On EM.Emp_ID = c.Emp_ID 
				WHERE C.Cmp_ID = @Cmp_ID AND C.Emp_ID = @Emp_ID And Claim_App_Status = @Claim_App_Status and Submit_Flag = 1 AND Claim_App_Date >= @ForDate AND Claim_App_Date <= @ToDate 
				ORDER BY Claim_App_Status DESC
			end
		
		--End by Prapti 10-03-2022 Start

		Select d.Claim_ID,Cm.Claim_Name,D.Claim_App_ID FROM T0100_CLAIM_APPLICATION C WITH (NOLOCK) 
		inner join T0110_CLAIM_APPLICATION_DETAIL D WITH (NOLOCK)  on c.Claim_App_ID = d.Claim_App_ID
		Left Join T0080_EMP_MASTER EM WITH (NOLOCK) On EM.Emp_ID = c.Emp_ID 
		Left join T0040_CLAIM_MASTER CM With (NoLock) ON CM.Claim_ID = D.Claim_ID
		WHERE C.Cmp_ID = @Cmp_ID AND C.Emp_ID = @Emp_ID And Claim_App_Status = @Claim_App_Status AND Claim_App_Date >= @ForDate AND Claim_App_Date <= @ToDate 
		ORDER BY c.Claim_App_ID DESC	

		--EXEC SP_Get_Claim_Application_Records @Cmp_ID = @Cmp_ID,@Emp_ID = @Emp_ID,@Rpt_level=0,
		--@Constrains=N'Claim_App_Status = ''P'' And Submit_Flag = 0',@OrderBy='ORDER BY Claim_App_Date DESC'
	END
ELSE IF @Type = 'E' --- For Get Claim Application Details
	BEGIN
	
	If @Claim_App_Status='D' set @Claim_App_Status='Pending'

		--select @Claim_App_Status

		SELECT CA.Cmp_ID,Emp_ID,CA.Claim_App_Amount,CAD.Claim_Amount,CAD.Claim_ID,CAD.Claim_Description,CAD.Curr_Rate
		,case when Claim_App_Status = 'P' then 'Pending' When Claim_App_Status = 'A' then 'Approved' else 'Rejected' end as [Claim_App_Status],
		CM.Claim_Name,CR.Curr_Name,CAD.Petrol_Km,CAD.Claim_App_Detail_ID,CAD.Claim_App_ID,convert(varchar,CAD.For_Date,23) as For_Date,CM.Claim_Max_Limit,
		CM.Grade_Wise_Limit,CM.Desig_Wise_Limit,CM.Branch_Wise_Limit,CM.Claim_Limit_Type,CM.Claim_Type,
		CAD.Curr_ID,CAd.Claim_Attachment,CM.CLAIM_ALLOW_BEYOND_LIMIT AS 'Claim_Allow_Beyond_Limit',
		(CASE WHEN CM.Claim_Apr_Deduct_From_Sal = 1 THEN 'Yes' ELSE 'No' END) AS 'Claim_Apr_Deduct_From_Sal',CAD.Claim_Attachment as Attachment
		FROM T0100_CLAIM_APPLICATION CA
		INNER JOIN T0110_CLAIM_APPLICATION_DETAIL CAD ON CA.Claim_App_ID = CAD.Claim_App_ID
		LEFT JOIN T0040_CLAIM_MASTER CM ON CAD.CLAIM_ID = CM.CLAIM_ID
		LEFT JOIN T0040_CURRENCY_MASTER CR ON CAD.CURR_ID = CR.CURR_ID 
		WHERE CA.Claim_App_ID = @Claim_App_ID and CA.Cmp_ID = @Cmp_ID and Ca.Emp_ID = @Emp_ID and Claim_App_Status = @Claim_App_Status
		--ORDER BY CA.For_Date ASC,CM.Claim_Name DESC
	END
ELSE IF @Type = 'A' --- For Claim Approval
	BEGIN
		DECLARE @Claim_Apr_ID NUMERIC(18,0)
		DECLARE @Tran_ID NUMERIC(18,0)
		DECLARE @Code VARCHAR(50)
		DECLARE @AprKilometer NUMERIC(18,2)
		DECLARE @Claim_Apr_Amount NUMERIC(18,2)
		DECLARE @Date VARCHAR(50)
		SET @Date = CAST(GETDATE() AS VARCHAR(11))
		DECLARE @Claim_Apr_By VARCHAR(50)
			
		IF @Final_Approve = 1 
			BEGIN
				EXEC P0120_Claim_APPROVAL @Claim_Apr_ID OUTPUT,@Cmp_ID = @Cmp_ID,@Claim_App_ID = @Claim_App_ID,
				@Emp_ID = @Emp_ID,@Claim_ID = @Claim_ID,@Claim_Apr_Date = @Date,@Claim_Apr_Code = @Code OUTPUT,
				@Claim_Apr_Comments = @Claim_Description,@Claim_Apr_By = @Claim_Apr_By ,@Claim_Apr_Amount = 0.0,
				@Claim_Apr_Deduct_From_Sal = 0,@Claim_Apr_Pending_Amount = 0.0,@Claim_App_Status = @Claim_App_Status,
				@Claim_App_Date = @ForDate,@Claim_App_Amount = 0.0,@Curr_ID = 0,@Curr_Rate = 0.0,@Purpose = '',
				@Claim_App_Total_Amount  = 0.0,@S_Emp_ID = @SEmp_ID,@tran_type = 'I',@Petrol_KM = 0.0,
				@User_Id = @Login_ID,@IP_Address = @IMEINO
			END
		
			EXEC P0115_CLAIM_LEVEL_APPROVAL @Claim_Apr_ID OUTPUT,@Claim_App_ID = @Claim_App_ID,@Cmp_ID = @Cmp_ID,
			@Emp_ID	= @Emp_ID,@S_Emp_ID = @SEmp_ID,@Approval_Date = @Date,@Approval_Status = @Claim_App_Status,
			@Approval_Comments = @Claim_Description,@Login_ID = @Login_ID,@Rpt_Level = @Rpt_Level,@Claim_Apr_Amount = 0.0,
			@Claim_Apr_Pending_Amnt = 0.0,@Claim_App_Amount = @Claim_App_Amount,@Curr_ID = 0,@Curr_Rate = 0.0,
			@Claim_App_Total_Amount = 0.0,@Tran_Type = 'I',@Attached_Doc_File = @Claim_Attachment,@Claim_ID = @Claim_ID,
			@Deduct_frm_salary = 0,@For_Date = @ForDate,@Claim_App_Purpose = '',@Approved_Petrol_Km = 0
			
			IF (@Claim_Details.exist('/NewDataSet/ClaimDetails') = 1)
				BEGIN
					SELECT CONVERT(DATETIME, Table1.value('(ClaimDate/text())[1]','varchar(11)'),103) AS ClaimDate,
						Table1.value('(ClaimAmount/text())[1]','numeric(18,2)') AS ClaimAmount,
						Table1.value('(Description/text())[1]','varchar(255)') AS Descriptions,
						Table1.value('(ClaimID/text())[1]','numeric(18,0)') AS ClaimID,
						Table1.value('(CurrencyID/text())[1]','numeric(18,0)') AS CurrencyID,
						Table1.value('(CurrencyRate/text())[1]','numeric(18,2)') AS CurrencyRate,
						Table1.value('(Kilometer/text())[1]','numeric(18,2)') AS Kilometer,
						Table1.value('(ApprovalKilometer/text())[1]','numeric(18,2)') AS ApprovalKilometer,
						Table1.value('(ClaimAprAmount/text())[1]','numeric(18,2)') AS ClaimAprAmount,
						Table1.value('(ApprvoalStatus/text())[1]','varchar(5)') AS ApprvoalStatus
						INTO #ClaimDetailsTemp1 FROM @Claim_Details.nodes('/NewDataSet/ClaimDetails') AS Temp(Table1)
						
						DECLARE CLAIMDETAIL_CURSOR CURSOR  FAST_FORWARD FOR
						
						SELECT ClaimDate,ClaimAmount,Descriptions,ClaimID,CurrencyID,CurrencyRate,Kilometer,ApprovalKilometer,ClaimAprAmount,ApprvoalStatus
						FROM #ClaimDetailsTemp
						
						OPEN CLAIMDETAIL_CURSOR
						FETCH NEXT FROM CLAIMDETAIL_CURSOR INTO @Claim_Date,@Claim_Amount,@Description,@Claim_ID,@Curr_ID,@Curr_Rate,@Kilometer,@AprKilometer,@Claim_Apr_Amount,@Claim_App_Status

						WHILE @@FETCH_STATUS = 0
							BEGIN
								IF @Final_Approve = 1 
									BEGIN
										EXEC P0130_Claim_APPROVAL_DETAIL @Claim_Apr_Dtl_ID = @Tran_ID OUTPUT,@Claim_Apr_ID = @Claim_Apr_ID,
										@Cmp_ID = @Cmp_ID,@Emp_ID = @Emp_ID,@Claim_ID = @Claim_ID,@Claim_Apr_Date = @Date,
										@Claim_App_ID = @Claim_App_ID,@Claim_Apr_Code = @Code OUTPUT,@Claim_Apr_Amount = @Claim_Amount,
										@Claim_App_Status = @Claim_App_Status,@Claim_App_Amount = @Claim_Amount,@Curr_ID = @Curr_ID,
										@Curr_Rate = @Curr_Rate ,@Purpose = @Description,@Claim_App_Total_Amount = @Claim_Amount,
										@S_Emp_ID = @SEmp_ID,@Petrol_KM	= @AprKilometer,@tran_type = 'I',@User_Id = @Login_ID,
										@IP_Address = @IMEINO
									END
								EXEC P0115_CLAIM_LEVEL_APPROVAL_DETAIL @Claim_Tran_ID = @Tran_ID OUTPUT,@Claim_Apr_ID = @Claim_Apr_ID,
								@Claim_App_ID = @Claim_App_ID,@Cmp_ID = @Cmp_ID,@Emp_ID = @Emp_ID,@S_Emp_ID = @SEmp_ID,
								@Claim_ID = @Claim_ID,@Claim_Apr_Date = @Date,@Claim_Apr_Code = @Code OUTPUT,@Claim_Apr_Amount = @Claim_Amount,
								@Claim_Status = @Claim_App_Status,@Claim_App_Amount = @Claim_Amount,@Curr_ID = @Curr_ID,
								@Curr_Rate = @Curr_Rate,@Claim_Purpose = @Description,@Claim_App_Total_Amount = @Claim_Amount,
								@Approved_Petrol_Km = @AprKilometer,@Login_ID = @Login_ID,@Rpt_Level = @Rpt_Level,
								@For_Date = @Claim_Date,@tran_type = 'I'
								 
								FETCH NEXT FROM CLAIMDETAIL_CURSOR INTO @Claim_Date,@Claim_Amount,@Description,@Claim_ID,@Curr_ID,@Curr_Rate,@Kilometer,@AprKilometer,@Claim_Apr_Amount,@Claim_App_Status
							END
						CLOSE CLAIMDETAIL_CURSOR
						DEALLOCATE CLAIMDETAIL_CURSOR
				END
	END
