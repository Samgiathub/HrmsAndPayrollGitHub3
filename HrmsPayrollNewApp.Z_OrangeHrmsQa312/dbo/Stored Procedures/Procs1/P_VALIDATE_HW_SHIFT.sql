-- =============================================
-- Author:		<Jaina>
-- Create date: <02-05-2016>
-- Description:	<Check Validation>
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P_VALIDATE_HW_SHIFT]
	@CMP_ID NUMERIC(18,0),
	@EFFECTIVE_DATE DATETIME,
	@CONSTRAINT VARCHAR(MAX),
	@ERROR_MSG VARCHAR(MAX) OUTPUT,
	@MODULE_NAME VARCHAR(200),
	@BRANCH_ID VARCHAR(MAX) = '',  --ADDED BY JAINA 10-06-2016
	@FLAG CHAR = '' --ADDED BY JAINA 10-06-2016
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
		
		IF @BRANCH_ID  <> ''
			BEGIN
					IF OBJECT_ID('TEMPDB..#HOLIDAY_BRANCH') IS NOT NULL	
							DROP TABLE #HOLIDAY_BRANCH
			
					CREATE TABLE #HOLIDAY_BRANCH
					(
						BRANCH_ID NUMERIC
					)
					
					INSERT INTO #HOLIDAY_BRANCH
					SELECT CAST(DATA AS NUMERIC) FROM DBO.SPLIT(@BRANCH_ID, '#') WHERE ISNULL(DATA, '') <> ''
										
					---Validation For Salary Exits																
					IF EXISTS (
								SELECT 1 FROM T0200_MONTHLY_SALARY M WITH (NOLOCK)
								INNER JOIN T0095_INCREMENT  I WITH (NOLOCK) ON M.INCREMENT_ID = I.INCREMENT_ID 
							    INNER JOIN #HOLIDAY_BRANCH T ON T.BRANCH_ID = I.BRANCH_ID 
								WHERE  M.CMP_ID = @CMP_ID AND @EFFECTIVE_DATE BETWEEN M.MONTH_ST_DATE AND ISNULL(M.Cutoff_Date, M.MONTH_END_DATE)
								)
					BEGIN
							PRINT 1
							SET @ERROR_MSG = 'Referential entries are exists.' + @MODULE_NAME + ' activity can not be performed.'
							SELECT @ERROR_MSG AS ERROR_MSG
							RETURN -1
					END
					--Validation For OverTime Approval														
					IF EXISTS(SELECT 1 FROM T0160_OT_APPROVAL OT WITH (NOLOCK)
		   					  INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.EMP_ID = OT.EMP_ID
							  INNER JOIN #HOLIDAY_BRANCH H ON H.BRANCH_ID = I.BRANCH_ID
							  WHERE OT.CMP_ID= @CMP_ID AND OT.IS_APPROVED=1 AND 
									OT.FOR_DATE BETWEEN DBO.GET_MONTH_ST_DATE(MONTH(@EFFECTIVE_DATE),YEAR(@EFFECTIVE_DATE)) AND
														DBO.GET_MONTH_END_DATE(MONTH(@EFFECTIVE_DATE),YEAR(@EFFECTIVE_DATE))
							 )
					BEGIN
						print 2
						SET @ERROR_MSG = 'Referential entries for overtime approval are exists.' + @MODULE_NAME + ' activity can not be performed.'
						SELECT @ERROR_MSG AS ERROR_MSG
						
						RETURN -1
					END
					--Validation For Comp-off Application   --Added By Jaina 12-07-2016
					IF EXISTS(SELECT 1 FROM T0100_CompOff_Application C WITH (NOLOCK)
							  INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.EMP_ID = C.EMP_ID
							  INNER JOIN #HOLIDAY_BRANCH H ON H.BRANCH_ID = I.BRANCH_ID
							  WHERE C.CMP_ID = @CMP_ID AND
									C.EXTRA_WORK_DATE BETWEEN DBO.GET_MONTH_ST_DATE(MONTH(@EFFECTIVE_DATE),YEAR(@EFFECTIVE_DATE)) AND
															  DBO.GET_MONTH_END_DATE(MONTH(@EFFECTIVE_DATE),YEAR(@EFFECTIVE_DATE))
							 )
					BEGIN
						
						SET @ERROR_MSG = 'Referential entries for comp-off application are exists.' + @MODULE_NAME + ' activity can not be performed.'
						SELECT @ERROR_MSG AS ERROR_MSG
						RETURN -1
					END
					
					--Validation For Comp-off Approval
					IF EXISTS(SELECT 1 FROM T0120_COMPOFF_APPROVAL C WITH (NOLOCK)
							  INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.EMP_ID = C.EMP_ID
							  INNER JOIN #HOLIDAY_BRANCH H ON H.BRANCH_ID = I.BRANCH_ID
							  WHERE C.APPROVE_STATUS = 'A' AND C.CMP_ID = @CMP_ID AND
									C.EXTRA_WORK_DATE BETWEEN DBO.GET_MONTH_ST_DATE(MONTH(@EFFECTIVE_DATE),YEAR(@EFFECTIVE_DATE)) AND
															  DBO.GET_MONTH_END_DATE(MONTH(@EFFECTIVE_DATE),YEAR(@EFFECTIVE_DATE))
							 )
					BEGIN
						PRINT 3
						SET @ERROR_MSG = 'Referential entries for comp-off approval are exists.' + @MODULE_NAME + ' activity can not be performed.'
						SELECT @ERROR_MSG AS ERROR_MSG
						RETURN -1
					END
					--Validation For COPH Leave Application
					IF OBJECT_ID('TEMPDB..#COPH_DATE') IS NOT NULL	
						DROP TABLE #COPH_DATE
					CREATE TABLE #COPH_DATE
					(
						BRANCH_ID NUMERIC,
						COPH_DATE DATETIME
						
					)
																						
					INSERT INTO #COPH_DATE
					SELECT DISTINCT I.BRANCH_ID,CAST(LEFT(LEAVE_COMPOFF_DATES, 11) AS DATETIME) AS COPH_DATE
							   FROM T0110_LEAVE_APPLICATION_DETAIL LD WITH (NOLOCK)
									INNER JOIN T0100_LEAVE_APPLICATION  LA WITH (NOLOCK) ON LA.LEAVE_APPLICATION_ID = LD.LEAVE_APPLICATION_ID
									INNER JOIN T0040_LEAVE_MASTER L WITH (NOLOCK) ON L.LEAVE_ID = LD.LEAVE_ID
									INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON  I.EMP_ID = LA.EMP_ID 
								WHERE L.LEAVE_CODE = 'COPH' OR L.Leave_Code = 'COND'
							
					IF EXISTS (SELECT 1 FROM #COPH_DATE C INNER JOIN #HOLIDAY_BRANCH H ON C.BRANCH_ID = H.BRANCH_ID
							   WHERE C.COPH_DATE = @EFFECTIVE_DATE
  							  )
					BEGIN
						PRINT 4
						SET @ERROR_MSG = 'Referential entries for COPH/COND leave application are exists.' + @MODULE_NAME + ' activity can not be performed.'
						SELECT @ERROR_MSG AS ERROR_MSG
						RETURN -1
					END
					
					--Validation For COPH Leave Approval
					IF OBJECT_ID('TEMPDB..#COPH_DATE_APPROVAL') IS NOT NULL	
							DROP TABLE #COPH_DATE_APPROVAL
							
					CREATE TABLE #COPH_DATE_APPROVAL
					(
						BRANCH_ID NUMERIC,
						COPH_DATE DATETIME
						
					)
					INSERT INTO #COPH_DATE_APPROVAL
					SELECT DISTINCT I.Branch_ID,Cast(Left(Leave_CompOff_Dates, 11) AS datetime) As COPH_DATE
								FROM T0130_LEAVE_APPROVAL_DETAIL LD WITH (NOLOCK)
									inner JOIN T0120_LEAVE_APPROVAL LA WITH (NOLOCK) ON LD.Leave_Approval_ID = Ld.Leave_Approval_ID
									inner JOIN T0100_LEAVE_APPLICATION LAP WITH (NOLOCK) on  LAP.Leave_Application_ID = LA.Leave_Application_ID
									INNER JOIN T0040_LEAVE_MASTER L WITH (NOLOCK) ON L.Leave_ID = LD.Leave_ID
									INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON  I.Emp_ID = LA.Emp_ID 
								WHERE L.Leave_Code = 'COPH' OR L.Leave_Code = 'COND'
					
																	   
					IF EXISTS (SELECT 1 FROM #COPH_DATE_APPROVAL C INNER JOIN #HOLIDAY_BRANCH H ON C.BRANCH_ID = H.BRANCH_ID
							   WHERE C.COPH_DATE = @EFFECTIVE_DATE
  							  )
					BEGIN
						PRINT 5
						SET @ERROR_MSG = 'Referential entries for COPH/COND leave approval are exists.' + @MODULE_NAME + ' activity can not be performed.'
						SELECT @ERROR_MSG AS ERROR_MSG
						RETURN -1
					END
					
					--Validation For Leave Application
					IF OBJECT_ID('TEMPDB..#LEAVE_DATE') IS NOT NULL	
						DROP TABLE #LEAVE_DATE
					CREATE TABLE #LEAVE_DATE
					(
						BRANCH_ID NUMERIC,
						FROM_DATE DATETIME,
						TO_DATE DATETIME
						
					)
																				
					INSERT INTO #LEAVE_DATE
					SELECT I.BRANCH_ID,LD.FROM_DATE,LD.TO_DATE 
					FROM T0100_LEAVE_APPLICATION LA  WITH (NOLOCK)
							INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.EMP_ID = LA.EMP_ID 
							INNER JOIN	T0110_LEAVE_APPLICATION_DETAIL LD WITH (NOLOCK) ON LD.LEAVE_APPLICATION_ID = LA.LEAVE_APPLICATION_ID
						
					
					IF EXISTS (SELECT 1 FROM #LEAVE_DATE L INNER JOIN #HOLIDAY_BRANCH H ON L.BRANCH_ID = H.BRANCH_ID
							   WHERE @EFFECTIVE_DATE BETWEEN L.FROM_DATE and L.TO_DATE
  							  )
					BEGIN
						SET @ERROR_MSG = 'Referential entries are exists in leave application.' + @MODULE_NAME + ' activity can not be performed.'
						SELECT @ERROR_MSG AS ERROR_MSG
						RETURN -1
					END
					
					IF OBJECT_ID('TEMPDB..#LEAVE_DATE_APPROVAL') IS NOT NULL	
							DROP TABLE #LEAVE_DATE_APPROVAL
							
					CREATE TABLE #LEAVE_DATE_APPROVAL
					(
						BRANCH_ID NUMERIC,
						FROM_DATE DATETIME,
						TO_DATE DATETIME
						
					)
														
					--INSERT INTO #LEAVE_DATE_APPROVAL
					--SELECT I.BRANCH_ID,LAD.FROM_DATE,LAD.TO_DATE 
					--		FROM T0100_LEAVE_APPLICATION LA
					--		INNER JOIN T0095_INCREMENT I ON I.EMP_ID = LA.EMP_ID 
					--		 inner JOIN	T0120_LEAVE_APPROVAL LD ON LD.LEAVE_APPLICATION_ID = LA.LEAVE_APPLICATION_ID
					--		inner JOIN T0130_LEAVE_APPROVAL_DETAIL LAD ON LAD.LEAVE_APPROVAL_ID = LD.LEAVE_APPROVAL_ID
							
					
					INSERT INTO #LEAVE_DATE_APPROVAL
					SELECT I.BRANCH_ID,LAD.FROM_DATE,LAD.TO_DATE 
							FROM T0120_LEAVE_APPROVAL LA WITH (NOLOCK) INNER JOIN 
							T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LA.LEAVE_APPROVAL_ID = LAD.LEAVE_APPROVAL_ID					
							LEFT OUTER JOIN T0100_LEAVE_APPLICATION L WITH (NOLOCK) ON L.LEAVE_APPLICATION_ID = LA.LEAVE_APPLICATION_ID
							INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.EMP_ID = LA.EMP_ID
					
																	   
					IF EXISTS (SELECT 1 FROM #LEAVE_DATE_APPROVAL L INNER JOIN #HOLIDAY_BRANCH H ON L.BRANCH_ID = H.BRANCH_ID
							   WHERE @EFFECTIVE_DATE BETWEEN L.FROM_DATE and L.TO_DATE
  							  )
					BEGIN
						PRINT 5345345
						SET @ERROR_MSG = 'Referential entries for leave approval are exists.' + @MODULE_NAME + ' activity can not be performed.'
						SELECT @ERROR_MSG AS ERROR_MSG
						RETURN -1
					END
					
			End
		Else
			Begin
			
					IF OBJECT_ID('tempdb..#EMP_ROT') IS NOT NULL	
							drop table #EMP_ROT
			
					CREATE TABLE #EMP_ROT
					(
						EMP_ID numeric
					)
					INSERT INTO #EMP_ROT
					SELECT CAST(DATA AS NUMERIC) FROM dbo.Split(@Constraint, '#') Where IsNull(Data, '') <> ''
					
					---Validation For Salary Exits																
					
					IF EXISTS(SELECT 1 FROM  T0200_MONTHLY_SALARY M WITH (NOLOCK) INNER JOIN #EMP_ROT R ON R.EMP_ID=M.Emp_ID 
								where M.Cmp_ID = @Cmp_id  AND ISNULL(M.Cutoff_Date, M.MONTH_END_DATE) >= @EFFECTIVE_DATE )
					Begin
						set @Error_msg = 'Referential entries are exists.' + @Module_name + ' activity can not be performed.'
						select @Error_msg AS Error_msg
						return -1
					End

					---Validation For Overtime Approval																
					IF EXISTS(SELECT 1 FROM T0160_OT_APPROVAL OT WITH (NOLOCK) INNER JOIN #EMP_ROT R ON OT.Emp_ID = R.EMP_ID where OT.Cmp_ID= @Cmp_id AND OT.Is_Approved=1 AND OT.For_Date >= @Effective_Date)
					Begin
						
						set @Error_msg = 'Referential entries for overtime approval are exists.' + @Module_name + ' activity can not be performed.'
						select @Error_msg AS Error_msg
						return -1
					End
					
					---Validation For Comp-off Application																
					IF EXISTS(Select 1 from T0100_CompOff_Application C WITH (NOLOCK) INNER JOIN #EMP_ROT R ON R.EMP_ID = C.Emp_ID where C.Extra_Work_Date >= @Effective_Date  and C.Cmp_ID = @Cmp_ID)
					Begin
						
						set @Error_msg = 'Referential entries for comp-off application are exists.' + @Module_name + ' activity can not be performed.'
						select @Error_msg AS Error_msg
						return -1
					End
					
					IF EXISTS(Select 1 from T0120_CompOff_Approval C WITH (NOLOCK) INNER JOIN #EMP_ROT R ON R.EMP_ID = C.Emp_ID where C.Approve_Status = 'A' and C.Extra_Work_Date >= @Effective_Date  and C.Cmp_ID = @Cmp_ID)
					Begin
						
						set @Error_msg = 'Referential entries for comp-off approval are exists.' + @Module_name + ' activity can not be performed.'
						select @Error_msg AS Error_msg
						return -1
					End
					
					if @FLAG = 'W'
					Begin
							IF OBJECT_ID('TEMPDB..#COPH_DATE_W') IS NOT NULL	
								DROP TABLE #COPH_DATE_W
								
							CREATE TABLE #COPH_DATE_W
							(
								EMP_ID NUMERIC,
								COPH_DATE DATETIME
								
							)
							INSERT INTO #COPH_DATE_W
							SELECT DISTINCT I.Emp_ID,CAST(LEFT(LEAVE_COMPOFF_DATES, 11) AS DATETIME) AS COPH_DATE
									   FROM T0110_LEAVE_APPLICATION_DETAIL LD WITH (NOLOCK)
											INNER JOIN T0100_LEAVE_APPLICATION  LA WITH (NOLOCK) ON LA.LEAVE_APPLICATION_ID = LD.LEAVE_APPLICATION_ID
											INNER JOIN T0040_LEAVE_MASTER L WITH (NOLOCK) ON L.LEAVE_ID = LD.LEAVE_ID
											INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON  I.EMP_ID = LA.EMP_ID 
										WHERE L.LEAVE_CODE = 'COPH' OR L.Leave_Code = 'COND'
								
									   					
							IF EXISTS (SELECT 1 FROM #COPH_DATE_W C INNER JOIN #EMP_ROT E ON C.EMP_ID = E.EMP_ID
									   WHERE C.COPH_DATE = @EFFECTIVE_DATE
  									  )
							BEGIN
								
								SET @ERROR_MSG = 'Referential entries for COPH/COND leave application are exists.' + @MODULE_NAME + ' activity can not be performed.'
								SELECT @ERROR_MSG AS ERROR_MSG
								RETURN -1
							END
							
							IF OBJECT_ID('TEMPDB..#COPH_DATE_APPROVAL_W') IS NOT NULL	
							DROP TABLE #COPH_DATE_APPROVAL_W
							
							CREATE TABLE #COPH_DATE_APPROVAL_W
							(
								EMP_ID NUMERIC,
								COPH_DATE DATETIME
								
							)
							INSERT INTO #COPH_DATE_APPROVAL_W
							SELECT DISTINCT I.Emp_ID,Cast(Left(Leave_CompOff_Dates, 11) AS datetime) As COPH_DATE
										FROM T0130_LEAVE_APPROVAL_DETAIL LD WITH (NOLOCK)
											inner JOIN T0120_LEAVE_APPROVAL LA WITH (NOLOCK) ON LD.Leave_Approval_ID = Ld.Leave_Approval_ID
											inner JOIN T0100_LEAVE_APPLICATION LAP WITH (NOLOCK) on  LAP.Leave_Application_ID = LA.Leave_Application_ID
											INNER JOIN T0040_LEAVE_MASTER L WITH (NOLOCK) ON L.Leave_ID = LD.Leave_ID
											INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON  I.Emp_ID = LA.Emp_ID 
										WHERE L.Leave_Code = 'COPH' OR L.Leave_Code = 'COND'
									   
							
							IF EXISTS (SELECT 1 FROM #COPH_DATE_APPROVAL_W C INNER JOIN #EMP_ROT E ON C.EMP_ID = E.EMP_ID
									   WHERE C.COPH_DATE = @EFFECTIVE_DATE
  									  )
							BEGIN
								SET @ERROR_MSG = 'Referential entries for COPH/COND leave approval are exists.' + @MODULE_NAME + ' activity can not be performed.'
								SELECT @ERROR_MSG AS ERROR_MSG
								RETURN -1
							END
							
							--Validation For Leave Application
							IF OBJECT_ID('TEMPDB..#LEAVE_DATE_W') IS NOT NULL	
								DROP TABLE #LEAVE_DATE_W
							CREATE TABLE #LEAVE_DATE_W
							(
								EMP_ID NUMERIC,
								FROM_DATE DATETIME,
								TO_DATE DATETIME
								
							)
																								
							INSERT INTO #LEAVE_DATE_W
							SELECT I.Emp_ID,LD.FROM_DATE,LD.TO_DATE 
								FROM T0100_LEAVE_APPLICATION LA WITH (NOLOCK)
									INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.EMP_ID = LA.EMP_ID 
									INNER JOIN	T0110_LEAVE_APPLICATION_DETAIL LD WITH (NOLOCK) ON LD.LEAVE_APPLICATION_ID = LA.LEAVE_APPLICATION_ID
										
							
							IF EXISTS (SELECT 1 FROM #LEAVE_DATE_W L INNER JOIN #EMP_ROT E ON L.EMP_ID = E.EMP_ID
									   WHERE @EFFECTIVE_DATE <= L.FROM_DATE
  									  )
							BEGIN
								
								SET @ERROR_MSG = 'Referential entries for leave application are exists.' + @MODULE_NAME + ' activity can not be performed.'
								SELECT @ERROR_MSG AS ERROR_MSG
								RETURN -1
							END
							
							IF OBJECT_ID('TEMPDB..#LEAVE_DATE_APPROVAL_W') IS NOT NULL	
							DROP TABLE #LEAVE_DATE_APPROVAL_W
							
							CREATE TABLE #LEAVE_DATE_APPROVAL_W
							(
								EMP_ID NUMERIC,
								FROM_DATE DATETIME,
								TO_DATE DATETIME
								
							)
							--INSERT INTO #LEAVE_DATE_APPROVAL_W
							--SELECT I.BRANCH_ID,LAD.FROM_DATE,LAD.TO_DATE 
							--FROM T0100_LEAVE_APPLICATION LA
							--INNER JOIN T0095_INCREMENT I ON I.EMP_ID = LA.EMP_ID 
							--INNER JOIN	T0120_LEAVE_APPROVAL LD ON LD.LEAVE_APPLICATION_ID = LA.LEAVE_APPLICATION_ID
							--INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD ON LAD.LEAVE_APPROVAL_ID = LD.LEAVE_APPROVAL_ID

							INSERT INTO #LEAVE_DATE_APPROVAL_W										
							SELECT I.Emp_ID,LAD.FROM_DATE,LAD.TO_DATE 
							FROM T0120_LEAVE_APPROVAL LA WITH (NOLOCK) INNER JOIN 
							T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LA.LEAVE_APPROVAL_ID = LAD.LEAVE_APPROVAL_ID					
							LEFT OUTER JOIN T0100_LEAVE_APPLICATION L WITH (NOLOCK) ON L.LEAVE_APPLICATION_ID = LA.LEAVE_APPLICATION_ID
							INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.EMP_ID = LA.EMP_ID
																			   
							IF EXISTS (SELECT 1 FROM #LEAVE_DATE_APPROVAL_W L INNER JOIN #EMP_ROT E ON L.EMP_ID = E.EMP_ID
									   WHERE @EFFECTIVE_DATE <= L.FROM_DATE
  									  )
							BEGIN
								PRINT 5
								SET @ERROR_MSG = 'Referential entries for leave approval are exists.' + @MODULE_NAME + ' activity can not be performed.'
								SELECT @ERROR_MSG AS ERROR_MSG
								RETURN -1
							END
							
					End			
			End

		
END


