---Added For Claim Module Web service
---Added changes by satish on 25-08-2020 added case for insert,update,select statements
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_Claim_Approval]
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
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

--DECLARE @Claim_Date Datetime
DECLARE @Claim_Amount NUMERIC(18,2)
DECLARE @Description VARCHAR(255)
DECLARE @Curr_ID NUMERIC(18,0)
DECLARE @Curr_Rate NUMERIC(18,2)
--DECLARE @Kilometer NUMERIC(18,2)
DECLARE @Claim_App_Code VARCHAR(50)

IF @Type = 'B' --- For Bind Records
	BEGIN
		DECLARE @Desig_ID INT
		DECLARE @Branch_ID INT
		DECLARE @Grd_ID INT
		
		SELECT @Desig_ID = Desig_Id,@Branch_ID = Branch_ID,@Grd_ID = Grd_ID 
		FROM V0080_Employee_Master 
		WHERE Emp_ID = @Emp_ID

		SELECT CM.Claim_ID,CM.Claim_Name,CM.Claim_Max_Limit,ISNULL(Grade_Wise_Limit,0) AS 'Grade_Wise_Limit',
		ISNULL(Branch_Wise_Limit,0) AS 'Branch_Wise_Limit',ISNULL(Claim_Limit_Type,0) AS 'Claim_Limit_Type',
		ISNULL(Claim_Type,0) AS 'Claim_Type',ISNULL(Attach_Mandatory,0) AS 'Attach_Mandatory',
		ISNULL(Claim_Allow_Beyond_Limit,0) AS 'Claim_Allow_Beyond_Limit',
		Max_Limit_Km,Rate_Per_Km
		FROM T0040_Claim_master CM WITH (NOLOCK)
		INNER JOIN T0041_Claim_Maxlimit_Design CMD WITH (NOLOCK) ON CM.Claim_ID = CMD.Claim_ID 
		WHERE CM.Cmp_ID = @Cmp_ID AND (CMD.Branch_ID = @Branch_ID OR CMD.Desig_ID = @Desig_ID OR CMD.Grade_ID = @Grd_ID)
		
		SELECT * FROM T0040_SETTING WITH (NOLOCK) where Group_By like '%Claim%' and Cmp_ID = @Cmp_ID


	END
ELSE IF @Type = 'L'
	BEGIN
		DECLARE @Claim_Type int
		
		SELECT @Claim_Type = Claim_Type FROM T0040_CLAIM_MASTER WITH (NOLOCK) WHERE Claim_ID = @Claim_ID
		
		IF @Claim_Type = 0
			BEGIN
				SELECT Qry.Claim_ID,Qry.ClaimAmount FROM
				(
					SELECT ISNULL(SUM(CAD.Claim_Amount),0) AS 'ClaimAmount',CA.Claim_ID 
					FROM T0110_CLAIM_APPLICATION_DETAIL CAD WITH (NOLOCK)
					INNER JOIN T0100_CLAIM_APPLICATION CA WITH (NOLOCK) ON CA.Claim_App_ID = CAD.Claim_App_ID
					INNER JOIN T0040_CLAIM_MASTER CM WITH (NOLOCK) ON CM.Claim_ID = CAD.Claim_ID AND CM.Cmp_ID = CAD.Cmp_ID 
					WHERE CAD.Cmp_ID = @Cmp_ID AND CAD.For_Date = @ForDate AND CA.Emp_ID = @Emp_ID 
					AND CA.Claim_App_Status = 'P' AND CAD.Claim_App_ID <> 0 AND CM.Claim_ID = @Claim_ID 
					GROUP BY CA.Claim_ID

					UNION ALL

					SELECT ISNULL(SUM(CAD.Claim_Apr_Amount),0) AS 'ClaimAmount',CA.Claim_ID
					FROM T0130_CLAIM_APPROVAL_DETAIL CAD WITH (NOLOCK)
					INNER JOIN T0120_CLAIM_APPROVAL CA WITH (NOLOCK) ON CA.Claim_Apr_ID = CAD.Claim_Apr_ID
					INNER JOIN T0040_CLAIM_MASTER CM WITH (NOLOCK) ON CM.Claim_ID = CAD.Claim_ID AND CM.Cmp_ID = CAD.Cmp_ID 
					WHERE CAD.Cmp_ID = @Cmp_ID AND CAD.Claim_Apr_Date = @ForDate AND CA.Emp_ID = @Emp_ID 
					AND CAD.Claim_Status = 'A' AND CM.Claim_ID = @Claim_ID 
					GROUP BY CA.Claim_ID
				) Qry
			END
		ELSE
			BEGIN
				SELECT TBL.Claim_ID,TBL.ClaimAmount FROM
				(
					SELECT ISNULL(SUM(CAD.Claim_Amount),0) AS 'ClaimAmount',CA.Claim_ID
					FROM T0110_CLAIM_APPLICATION_DETAIL CAD WITH (NOLOCK) 
					INNER JOIN T0100_CLAIM_APPLICATION CA WITH (NOLOCK) ON CA.Claim_App_ID = CAD.Claim_App_ID
					INNER JOIN T0040_CLAIM_MASTER CM WITH (NOLOCK) ON CM.Claim_ID = CAD.Claim_ID AND CM.Cmp_ID = CAD.Cmp_ID 
					WHERE CAD.Cmp_ID = @Cmp_ID AND CA.Emp_ID = @Emp_ID AND CA.Claim_App_Status = 'P' AND CAD.Claim_App_ID <> 0 
					AND CM.Claim_ID = @Claim_ID AND MONTH(CAD.For_Date) = MONTH(@ForDate) AND YEAR(CAD.For_Date) = YEAR(@ForDate) 
					GROUP BY CA.Claim_ID

					UNION ALL

					SELECT ISNULL(SUM(CAD.Claim_Apr_Amount),0) AS 'ClaimAmount',CA.Claim_ID
					FROM T0130_CLAIM_APPROVAL_DETAIL CAD WITH (NOLOCK) 
					INNER JOIN T0120_CLAIM_APPROVAL CA WITH (NOLOCK) ON CA.Claim_Apr_ID = CAD.Claim_Apr_ID 
					INNER JOIN T0040_CLAIM_MASTER CM WITH (NOLOCK) ON CM.Claim_ID = CAD.Claim_ID AND CM.Cmp_ID = CAD.Cmp_ID 
					WHERE CAD.Cmp_ID = @Cmp_ID AND CA.Emp_ID = @Emp_ID AND CAD.Claim_Status = 'A' AND CM.Claim_ID = @Claim_ID
					AND MONTH(CAD.Claim_Apr_Date) = MONTH(@ForDate) AND YEAR(CAD.Claim_Apr_Date) = YEAR(@ForDate) 
					GROUP BY CA.Claim_ID
				) TBL

			END
	END	
ELSE IF @Type = 'I' OR @Type = 'U'
	BEGIN
		   
			EXEC P0100_CLAIM_APPLICATION @Claim_App_ID = @Claim_App_ID OUTPUT,@Claim_ID = @Claim_ID,@Cmp_ID = @Cmp_ID,
			@Emp_ID = @Emp_ID,@Claim_App_Date = @ForDate,@Claim_App_Code = @Claim_App_Code OUTPUT,@Claim_App_Amount = @Claim_App_Amount,
			@Claim_App_Status = 'P',@Claim_App_Description = @Claim_Description,@Claim_App_Docs = @Claim_Attachment,
			@tran_type = @Type,@S_Emp_ID = @SEmp_ID,@Submit_Flag = @Flag,@User_Id = @Login_ID,@IP_Address = @IMEINO
			
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
				DECLARE @ClaimDate as varchar(20)
				DECLARE @ClaimAmount as NUMERIC(18,0)
				DECLARE @Kilometer as NUMERIC(18,0)
				DECLARE @Claim_Date Datetime
				Declare @Attachment Varchar(255)
		
				SET @STATUS = 0
			
				IF (@Claim_Details.exist('/NewDataSet/ClaimDetails') = 1)
				BEGIN
					--SELECT CONVERT(DATETIME, Table1.value('(ClaimDate/text())[1]','varchar(20)'),103) AS ClaimDate,
					SELECT Table1.value('(ClaimDate/text())[1]','varchar(20)') AS ClaimDate,
						Table1.value('(ClaimAmount/text())[1]','numeric(18,2)') AS ClaimAmount,
						Table1.value('(Description/text())[1]','varchar(255)') AS Descriptions,
						Table1.value('(ClaimID/text())[1]','numeric(18,0)') AS ClaimID,
						Table1.value('(CurrencyID/text())[1]','numeric(18,0)') AS CurrencyID,
						Table1.value('(CurrencyRate/text())[1]','numeric(18,2)') AS CurrencyRate,
						Table1.value('(Kilometer/text())[1]','numeric(18,2)') AS Kilometer,
						Table1.value('(Attachment/text())[1]','varchar(255)') AS Attachment
						--Table1.value('(ApprovalKilometer/text())[1]','numeric(18,2)') AS ApprovalKilometer,
						--Table1.value('(ClaimAprAmount/text())[1]','numeric(18,2)') AS ClaimAprAmount,
						--Table1.value('(ApprvoalStatus/text())[1]','varchar(5)') AS ApprvoalStatus
						INTO #ClaimDetailsTemp FROM @Claim_Details.nodes('/NewDataSet/ClaimDetails') AS Temp(Table1)
						
						--select * from #ClaimDetailsTemp						
						DECLARE CLAIMDETAIL_CURSOR CURSOR  FAST_FORWARD FOR
						
						SELECT ClaimDate,ClaimAmount,Descriptions,ClaimID,CurrencyID,CurrencyRate,Kilometer,Attachment
						FROM #ClaimDetailsTemp
						
						OPEN CLAIMDETAIL_CURSOR
						FETCH NEXT FROM CLAIMDETAIL_CURSOR INTO @ClaimDate,@ClaimAmount,@Descriptions,@ClaimID,@CurrencyID,@CurrencyRate,@Kilometer,@Attachment

						WHILE @@FETCH_STATUS = 0
							BEGIN TRY
								--IF @Claim_App_Detail_ID = 0
								--	BEGIN
										 --	print @Cmp_ID
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
											
										EXEC P0110_CLAIM_APPLICATION_DETAIL @Claim_App_Detail_ID OUTPUT,@Cmp_ID = @Cmp_ID,@Claim_App_ID = @Claim_App_ID,
										@Claim_ID = @ClaimID,@For_Date = @ClaimDate,@Application_Amount = @ClaimAmount,@Description = @Descriptions,
										@Curr_ID = @CurrencyID,@Curr_Rate = @CurrencyRate	,@Claim_Amount = @ClaimAmount,@Tran_Type = @Type,@Claim_Attachment = @Attachment,
										@Petrol_KM = @Kilometer,@User_Id = @Login_ID,@IP_Address = @IMEINO

										IF @Type = 'I'
										BEGIN
											SET @Result = 'Claim Application Detail Insert Successfully#True#'+CAST(@Claim_App_ID AS varchar(11))
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
	END
ELSE IF @Type='AD' -- GET CLAIM APPROVAL DETAILS 
		BEGIN
					--DECLARE @rpt INT
					--SELECT DISTINCT TOP 1 @rpt = Rpt_Level  
					--FROM T0115_CLAIM_LEVEL_APPROVAL_DETAIL 
					--WHERE CLAIM_APP_ID=@Claim_App_ID ORDER BY Rpt_Level DESC

					--SELECT	distinct TAP.CMP_ID,TAP.CLAIM_APP_DETAIL_ID,TAP.CLAIM_APP_ID,TAP.CLAIM_ID,
					--TAP.FOR_DATE,CLAIM_NAME
					--,TAP.PETROL_KM,TAP.APPLICATION_AMOUNT as TOTALAMOUNT,TAP.PETROL_KM AS APPROVED_PETROL_KM
					--,Case When Claim_Apr_Amnt is null then TAP.APPLICATION_AMOUNT  
					--	  When TAP.APPLICATION_AMOUNT = ISNULL(Claim_Apr_Amnt,0) then TAP.APPLICATION_AMOUNT 
					--	  Else Claim_Apr_Amnt END as APPLICATION_AMOUNT
					--,TAP.CLAIM_ATTACHMENT 
					--,TAP.Claim_Description as [DESCRIPTION],TAP.CURR_RATE
					--,CD.Claim_Status as Claim_Status,CD.Claim_Apr_Amnt,Q1.Approval_Date,Cd.Rpt_Level
					--,Case When CLM.Claim_Max_Limit = 0 Then ML.Max_Limit_Km else ClM.Claim_Max_Limit END as Max_Limit
					--,CLM.CLAIM_ALLOW_BEYOND_LIMIT
					--FROM T0110_CLAIM_APPLICATION_DETAIL TAP 
					--Left join T0100_CLAIM_APPLICATION CA on  TAP.Claim_App_ID = CA.Claim_App_ID
					--LEft JOIN T0115_CLAIM_LEVEL_APPROVAL_DETAIL CD on TAP.Claim_App_ID = CD.Claim_App_ID and Tap.Claim_ID = CD.Claim_ID and (Rpt_Level = @rpt or Rpt_Level is null)
					--AND Rpt_Level = @rpt 
					--LEFT JOIN (
					--	SELECT Claim_App_ID,Claim_ID,Approval_Date FROM T0115_CLAIM_LEVEL_APPROVAL
					--) Q1 ON CD.Claim_App_ID = Q1.Claim_App_ID and CD.Claim_ID = Q1.Claim_ID
					--LEFT OUTER JOIN T0040_CLAIM_MASTER CLM ON CLM.CLAIM_ID=TAP.CLAIM_ID 
					--LEFT OUTER JOIN T0040_CURRENCY_MASTER CRD ON TAP.CURR_ID =CRD.CURR_ID 
					--LEFT JOIN T0095_INCREMENT I on I.Emp_ID = CA.Emp_ID
					--LEFT JOIN T0041_Claim_Maxlimit_Design ML on ML.Claim_ID = TAP.Claim_ID and (I.Desig_Id = ml.Desig_ID or I.Branch_ID= ml.Branch_ID OR I.Grd_ID = ML.Grade_ID)
					--WHERE TAP.CLAIM_APP_ID=@Claim_App_ID ORDER BY FOR_DATE ASC, CLAIM_NAME DESC

					DECLARE @rpt INT
					SELECT DISTINCT TOP 1 @rpt = Rpt_Level  
					FROM T0115_CLAIM_LEVEL_APPROVAL_DETAIL WITH (NOLOCK)
					WHERE CLAIM_APP_ID=@Claim_App_ID ORDER BY Rpt_Level DESC

					SELECT	distinct 
					ROW_NUMBER() OVER(ORDER BY CLAIM_APP_DETAIL_ID) AS RowNum, CA.Emp_ID,
					TAP.CMP_ID,TAP.CLAIM_APP_DETAIL_ID,TAP.CLAIM_APP_ID,TAP.CLAIM_ID,
					TAP.FOR_DATE,CLAIM_NAME
					,TAP.PETROL_KM,TAP.APPLICATION_AMOUNT as TOTALAMOUNT,TAP.PETROL_KM AS APPROVED_PETROL_KM
					,Case When Claim_Apr_Amnt is null then TAP.APPLICATION_AMOUNT  
						  When TAP.APPLICATION_AMOUNT = ISNULL(Claim_Apr_Amnt,0) then TAP.APPLICATION_AMOUNT 
						  Else Claim_Apr_Amnt END as APPLICATION_AMOUNT
					,TAP.CLAIM_ATTACHMENT 
					,TAP.Claim_Description as [DESCRIPTION],TAP.CURR_RATE
					,CD.Claim_Status as Claim_Status,CD.Claim_Apr_Amnt,Q1.Approval_Date,Cd.Rpt_Level
					,Case When isnull(CLM.Claim_Max_Limit,0) = 0 Then isnull(ML.Max_Limit_Km,0) else isnull(ClM.Claim_Max_Limit,0) END as Max_Limit
					,CLM.CLAIM_ALLOW_BEYOND_LIMIT,CLM.Claim_Limit_Type
					into #tmp
					FROM T0110_CLAIM_APPLICATION_DETAIL TAP WITH (NOLOCK)
					Left join T0100_CLAIM_APPLICATION CA WITH (NOLOCK) on  TAP.Claim_App_ID = CA.Claim_App_ID
					LEft JOIN T0115_CLAIM_LEVEL_APPROVAL_DETAIL CD WITH (NOLOCK) on TAP.Claim_App_ID = CD.Claim_App_ID and Tap.Claim_ID = CD.Claim_ID and (Rpt_Level = @rpt or Rpt_Level is null)
					AND Rpt_Level = @rpt 
					LEFT JOIN (
						SELECT Tran_ID, Claim_App_ID,Claim_ID,Approval_Date FROM T0115_CLAIM_LEVEL_APPROVAL WITH (NOLOCK)
					) Q1 ON CD.Claim_App_ID = Q1.Claim_App_ID and CD.Claim_ID = Q1.Claim_ID --and cd.Claim_Apr_ID= q1.Tran_ID
					LEFT OUTER JOIN T0040_CLAIM_MASTER CLM WITH (NOLOCK) ON CLM.CLAIM_ID=TAP.CLAIM_ID 
					LEFT OUTER JOIN T0040_CURRENCY_MASTER CRD WITH (NOLOCK) ON TAP.CURR_ID =CRD.CURR_ID 
					LEFT JOIN T0095_INCREMENT I WITH (NOLOCK) on I.Emp_ID = CA.Emp_ID
					LEFT JOIN T0041_Claim_Maxlimit_Design ML WITH (NOLOCK) on ML.Claim_ID = TAP.Claim_ID and (I.Desig_Id = ml.Desig_ID or I.Branch_ID= ml.Branch_ID OR I.Grd_ID = ML.Grade_ID)
					WHERE TAP.CLAIM_APP_ID=@Claim_App_ID ORDER BY FOR_DATE ASC, CLAIM_NAME DESC


					Create Table #ClaimSumTbl
					(
						ClaimAPPDetailId   numeric(18,0),
						ClaimId  numeric(18,0) ,
						EmpId  numeric(18,0) ,
						CmpId  numeric(18,0), 
						ClaimIDSum  numeric(18,0), 
						ClaimLimitype numeric(18,0), 
						ClaimAprDate Date
					)

					--select 345
					--	Select * from #tmp
					
					Declare @cnt as int = 1
					Declare @TnlCnt as int 
					Select @TnlCnt =count(1) from #tmp
					WHILE(@cnt <= @TnlCnt )
					BEGIN
						Declare @ClaimLimitype  int  = 0
						Declare @Emp_id1  int  = 0
						Declare @CmpId  numeric(18,0)  = 0
						Declare @ClaimId1  numeric(18,0)  = 0
						Declare @ClaimAPPDetailId  numeric(18,0)  = 0
						--Declare @ClaimAPPId  numeric(18,0)  = 0
						Declare @ClaimAprDate as date = ''

						Select @ClaimLimitype = Claim_Limit_Type
						,@Emp_id=Emp_ID
						,@ClaimAPPDetailId=Claim_App_Detail_ID
						,@CmpId = Cmp_ID
						,@ClaimId = Claim_ID
						,@ClaimAprDate = CONVERT(VARCHAR(20), CONVERT(date, For_Date, 105), 23)
						--,@ClaimAPPId = Claim_App_ID
						from #tmp  where RowNum = @cnt

					Declare @ClaimIDSumm numeric(18,0) = 0
					If @ClaimLimitype = 0 
						BEGIN
							If Exists(SELECT 1
							FROM T0115_CLAIM_LEVEL_APPROVAL_DETAIL WITH (NOLOCK)
							where Emp_ID = @Emp_id  and Cmp_Id = @CmpId and Claim_ID=@ClaimId and (Rpt_Level = @rpt OR Rpt_Level is null) 
							and Claim_Status = 'A'
							and Claim_Apr_Date = CONVERT(VARCHAR(20), CONVERT(DATEtime, @ClaimAprDate, 105), 23)) 
							BEGIN
									print 'Daily level'
									insert into #ClaimSumTbl (ClaimIDSum,ClaimId,CmpId,EmpId,ClaimAprDate,ClaimLimitype,ClaimAPPDetailId)
									SELECT sum(Claim_Apr_Amnt) as DailySum,@ClaimId,@CmpId,@Emp_id,@ClaimAprDate,@ClaimLimitype,@ClaimAPPDetailId 
									FROM T0115_CLAIM_LEVEL_APPROVAL_DETAIL WITH (NOLOCK)
									where Emp_ID = @Emp_id  and Cmp_Id = @CmpId and Claim_ID=@ClaimId and (Rpt_Level = @rpt OR Rpt_Level is null)
									and Claim_Status = 'A'
									and Claim_Apr_Date = CONVERT(VARCHAR(20), CONVERT(DATEtime, @ClaimAprDate, 105), 23) 
								--	And Claim_App_ID <> @Claim_App_ID
									Order by 1 desc 
							END
							ELSE
							BEGIN
									print 'Daily Final'
									insert into #ClaimSumTbl (ClaimIDSum,ClaimId,CmpId,EmpId,ClaimAprDate,ClaimLimitype,ClaimAPPDetailId)
									SELECT sum(Claim_Apr_Amount) as DailySum,@ClaimId,@CmpId,@Emp_id,@ClaimAprDate,@ClaimLimitype,@ClaimAPPDetailId 
									FROM T0130_CLAIM_APPROVAL_DETAIL WITH (NOLOCK)
									where Emp_ID = @Emp_id  and Cmp_Id = @CmpId and Claim_ID=@ClaimId and Claim_Status = 'A'
									and Claim_Apr_Date = CONVERT(VARCHAR(20), CONVERT(DATEtime, @ClaimAprDate, 105), 23) 
								--	And Claim_App_ID <> @Claim_App_ID
									Order by 1 desc 
							END
						END
						ELSE
						BEGIN
							IF exists(SELECT 1
							FROM T0115_CLAIM_LEVEL_APPROVAL_DETAIL WITH (NOLOCK)
							where Emp_ID = @Emp_id  and Cmp_Id = @CmpId and Claim_ID=@ClaimId and (Rpt_Level = @rpt OR Rpt_Level is null)
							and Claim_Status = 'A'
							and (Month(Claim_Apr_Date) = Month(CONVERT(VARCHAR(20), CONVERT(date, @ClaimAprDate, 105), 23))) 
							and (Year(Claim_Apr_Date) = Year(CONVERT(VARCHAR(20), CONVERT(date, @ClaimAprDate, 105), 23))))
							BEGIN
							
									print 'Monthly Level'
									insert into #ClaimSumTbl (ClaimIDSum,ClaimId,CmpId,EmpId,ClaimAprDate,ClaimLimitype,ClaimAPPDetailId)
									SELECT sum(Claim_Apr_Amnt) as MonthlySum,@ClaimId,@CmpId,@Emp_id,@ClaimAprDate,@ClaimLimitype,@ClaimAPPDetailId  
									FROM T0115_CLAIM_LEVEL_APPROVAL_DETAIL WITH (NOLOCK)
									where Emp_ID = @Emp_id  and Cmp_Id = @CmpId and Claim_ID=@ClaimId and (Rpt_Level = @rpt OR Rpt_Level is null)
									and Claim_Status = 'A'
									and (Month(Claim_Apr_Date) = Month(CONVERT(VARCHAR(20), CONVERT(date, @ClaimAprDate, 105), 23))) 
									and (Year(Claim_Apr_Date) = Year(CONVERT(VARCHAR(20), CONVERT(date, @ClaimAprDate, 105), 23)))
									--And Claim_App_ID <> @Claim_App_ID
									Order by 1 desc 
							END
							ELSE
							BEGIN
									print 'Monthly Final'
									insert into #ClaimSumTbl (ClaimIDSum,ClaimId,CmpId,EmpId,ClaimAprDate,ClaimLimitype,ClaimAPPDetailId)
									SELECT sum(Claim_Apr_Amount) as DailySum,@ClaimId,@CmpId,@Emp_id,@ClaimAprDate,@ClaimLimitype,@ClaimAPPDetailId 
									FROM T0130_CLAIM_APPROVAL_DETAIL WITH (NOLOCK)
									where Emp_ID = @Emp_id  and Cmp_Id = @CmpId and Claim_ID=@ClaimId and Claim_Status = 'A'
									and (Month(Claim_Apr_Date) = Month(CONVERT(VARCHAR(20), CONVERT(date, @ClaimAprDate, 105), 23))) 
									and (Year(Claim_Apr_Date) = Year(CONVERT(VARCHAR(20), CONVERT(date, @ClaimAprDate, 105), 23)))
									--And Claim_App_ID <> @Claim_App_ID
									Order by 1 desc 
							END

						END
						print @cnt
						set @cnt = @cnt + 1
					END

					--Select * from #tmp
					--Select * from #ClaimSumTbl


					SELECT distinct Emp_ID,CMP_ID,CLAIM_APP_DETAIL_ID,CLAIM_APP_ID,CLAIM_ID,FOR_DATE,CLAIM_NAME,PETROL_KM,TOTALAMOUNT
					,APPROVED_PETROL_KM,APPLICATION_AMOUNT
					,CLAIM_ATTACHMENT,DESCRIPTION,ISNULL(CURR_RATE,0.00) as CURR_RATE,Claim_Status,Claim_Apr_Amnt,Approval_Date,Rpt_Level,Max_Limit,CLAIM_ALLOW_BEYOND_LIMIT -- Niraj(11102021)
					,Case when ClaimIDSum is null then  0 else ClaimIDSum END as ClaimIDSum
					FROM #ClaimSumTbl c 
					LEFT JOIN  #tmp t ON C.ClaimAPPDetailId = t.Claim_App_Detail_ID

		END
ELSE IF @Type = 'D'  -- For Delete Claim Application Details
	BEGIN
		If ((Select count(1) from T0110_CLAIM_APPLICATION_DETAIL WITH (NOLOCK) where Claim_App_ID = @Claim_App_ID and Cmp_ID = @Cmp_ID) = 1)
		BEGIN
					SET @Result = 'Please Insert atleast one record#False#'
					SELECT @Result
		END
		ELSE
		BEGIN
					DELETE FROM T0110_CLAIM_APPLICATION_DETAIL  WHERE Claim_App_Detail_ID = @Claim_App_Detail_ID AND Claim_App_ID = @Claim_App_ID and Cmp_ID = @Cmp_ID
				
					SET @Result = 'Claim Application Detail Delete Successfully#True#'+CAST(@Claim_App_Detail_ID AS varchar(11))
					SELECT @Result
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
ELSE IF @Type = 'R' --- For Claim Approval Records 
	BEGIN
		--exec SP_Get_Claim_Application_Records  @Cmp_ID=149,@Emp_ID=14838
		--,@Rpt_level=0,@Constrains=N'Claim_App_Status = ''P'' And Submit_Flag=0'
		--,@OrderBy='Order by Claim_App_Date desc'	
		
		--EXEC SP_Get_Claim_Application_Records @Cmp_ID = @Cmp_ID,@Emp_ID = @Emp_ID,@Rpt_level=0,
		--@Constrains=N'Claim_App_Status = ''P'' And Submit_Flag = 0 and ',@OrderBy='ORDER BY Claim_App_Date DESC'
		if @Claim_App_Status = 'P'
		BEGIN
			
			--Select * From V0100_Claim_Application where Cmp_ID =  @Cmp_ID and Emp_ID = @Emp_ID and Claim_App_Status = 'P' And Submit_Flag=0 AND   (Claim_App_Date between cast(@ForDate as varchar(20)) and cast(@ToDate as varchar(20))) Order by Claim_App_Date desc
			
			Declare @set as varchar(MAx) = ''
			SET @set = 'EXEC SP_Get_Claim_Application_Records  @Cmp_ID = ' + cast(@Cmp_ID as varchar(10)) + ' , @Emp_ID = ' + cast(@Emp_ID as varchar(10)) + '
			,@Rpt_level=0,@Constrains=N''Claim_App_Status = ''''P'''' And Submit_Flag=0 AND (Claim_App_Date between ''''' + cast(@ForDate as varchar(20)) + ''''' and ''''' + cast(@ToDate as varchar(20)) + ''''')''
			,@OrderBy=''Order by Claim_App_Date desc'''
			EXEC(@set)
			
		END
		ELSE
		BEGIN
				--Declare @SEmp_ID1 as numeric =0 
				--Select @SEmp_ID1 = S_Emp_ID from View_Claim_Final_N_level_Approval where Emp_ID = @Emp_ID and Claim_App_Date between @ForDate and @ToDate 
				--Select * from View_Claim_Final_N_level_Approval where Emp_ID = @Emp_ID and Claim_App_Date between @ForDate and @ToDate 
				--Order by Claim_App_Date desc
				--print '@SEmp_ID1'
				--print @SEmp_ID1
				Select distinct(ta.claim_app_id) as Claim_App_ID ,0 As Rpt_level,0 As Scheme_Id,0 as Tran_ID,0 As Final_Approver
				,0 As Is_Fwd_Leave_Rej,ta.Alpha_Emp_code,ta.Emp_Full_Name,ta.Supervisor,ta.claim_app_code as Claim_App_Code 
				,ta.claim_app_date as Claim_App_Date,ta.claim_app_status as Claim_App_Status ,ta.S_Emp_ID, ta.Desig_ID,ta.Emp_ID,ta.Branch_ID
				,ta.Grd_ID,ta.Application_Status,ta.Attachment ,MobileAttachment,Approval_Date from View_Claim_Final_N_level_Approval ta 
				Where ta.S_Emp_ID = @SEmp_ID and 1=1 and Claim_App_Date between @ForDate and @ToDate Order by Claim_App_Date desc	
		END
	END
ELSE IF @Type = 'E' --- For Get Claim Application Details
	BEGIN
		SELECT CA.Cmp_ID,Emp_ID,CA.Claim_App_Amount,CAD.Claim_Amount,CAD.Claim_ID,CAD.Claim_Description,CAD.Curr_Rate
		,case when Claim_App_Status = 'P' then 'Pending' When Claim_App_Status = 'A' then 'Approved' else 'Rejected' end as [Claim_App_Status],
		CM.Claim_Name,CR.Curr_Name,CAD.Petrol_Km,CAD.Claim_App_Detail_ID,CAD.Claim_App_ID,CAD.For_Date,CM.Claim_Max_Limit,
		CM.Grade_Wise_Limit,CM.Desig_Wise_Limit,CM.Branch_Wise_Limit,CM.Claim_Limit_Type,CM.Claim_Type,
		CAD.Curr_ID,CAD.Claim_Attachment,CM.CLAIM_ALLOW_BEYOND_LIMIT AS 'Claim_Allow_Beyond_Limit',
		(CASE WHEN CM.Claim_Apr_Deduct_From_Sal = 1 THEN 'Yes' ELSE 'No' END) AS 'Claim_Apr_Deduct_From_Sal'
		FROM T0100_CLAIM_APPLICATION CA WITH (NOLOCK)
		INNER JOIN T0110_CLAIM_APPLICATION_DETAIL CAD WITH (NOLOCK) ON CA.Claim_App_ID = CAD.Claim_App_ID
		LEFT JOIN T0040_CLAIM_MASTER CM WITH (NOLOCK) ON CA.CLAIM_ID = CM.CLAIM_ID
		LEFT JOIN T0040_CURRENCY_MASTER CR WITH (NOLOCK) ON CAD.CURR_ID = CR.CURR_ID 
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
						
						SELECT ClaimDate,ClaimAmount,Descriptions,ClaimID,CurrencyID,CurrencyRate,Kilometer,ApprovalKilometer,
						ClaimAprAmount,ApprvoalStatus
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
	



