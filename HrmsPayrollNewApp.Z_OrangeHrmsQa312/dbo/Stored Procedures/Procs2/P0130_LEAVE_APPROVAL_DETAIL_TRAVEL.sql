

---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0130_LEAVE_APPROVAL_DETAIL_TRAVEL]
	
	 @Leave_Approval_ID		NUMERIC(18,0)
	,@Cmp_ID				NUMERIC  
	,@Emp_ID				NUMERIC  
	,@S_Emp_ID				NUMERIC  
	,@Approval_Status		CHAR(1)  
	,@Leave_ID				NUMERIC
	,@From_Date				DATETIME
	,@To_Date				DATETIME
	,@Leave_Period			NUMERIC(18,2)
	,@Leave_Assign_As		VARCHAR(15)
	,@Leave_Reason			NVARCHAR(Max)
	,@Half_Leave_Date		DATETIME = NULL
	,@NightHalt				NUMERIC(18,0) = 0
	,@Login_ID				NUMERIC(18,0)
	,@tran_type				VARCHAR(1) 
	
	,@Is_Backdated_App		TINYINT = 0
	,@Row_ID				NUMERIC = 0
	,@Is_import				INT = 0
	,@M_Cancel_WO_HO		TINYINT = 0
	,@Leave_Out_Time		DATETIME = '' 
	,@Leave_In_Time			DATETIME = '' 
	,@strLeaveCompOff_Dates VARCHAR(MAX) = ''
	,@Half_Payment			TINYINT = 0
	,@Warning_flag			TINYINT = 0 
	,@Rules_Violate			TINYINT = 0
	 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	DECLARE @LEAVE_APR_ID AS NUMERIC
	SET @LEAVE_APR_ID = 0

	DECLARE @TOTAL_PERIOD AS NUMERIC(18,2)
	SET @TOTAL_PERIOD = @LEAVE_PERIOD
	
		
	IF (@TRAN_TYPE = 'I')
			
			BEGIN
			
				IF NOT EXISTS(SELECT 1 FROM T0130_LEAVE_APPROVAL_DETAIL WITH (NOLOCK) WHERE LEAVE_APPROVAL_ID = ISNULL(@LEAVE_APPROVAL_ID,0))
					BEGIN
					    
						DECLARE @TOTAL_DATE VARCHAR(MAX)
						DECLARE @TOTAL_HALF_LEAVE_DATE VARCHAR(MAX)
						DECLARE @HALF_LEAVE_FLAG INT
						DECLARE @TEMP_DATE DATETIME
						DECLARE @LEAVE_USED NUMERIC(18,2)
						DECLARE @HALF_LEAVE_MAX_DATE DATETIME
						DECLARE @LEAVE_ASSIGN_AS_HALF VARCHAR(15)
						
						SET @HALF_LEAVE_MAX_DATE = NULL
						SET @HALF_LEAVE_FLAG = 1
						SET @TOTAL_DATE = ''
						SET	@TEMP_DATE  = @FROM_DATE
						SET @TOTAL_HALF_LEAVE_DATE = ''
						SET @LEAVE_ASSIGN_AS_HALF = ''
						
					
						WHILE (@TEMP_DATE  <= @TO_DATE)
						BEGIN
						
									IF EXISTS	
									(  
										SELECT		1 
										FROM		T0120_LEAVE_APPROVAL LA WITH (NOLOCK)
										INNER JOIN	T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Approval_ID=LAD.Leave_Approval_ID
										INNER JOIN  T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LAD.LEAVE_ID = LM.LEAVE_ID
										WHERE		LA.CMP_ID = @CMP_ID AND LA.Emp_ID=@EMP_ID AND @TEMP_DATE BETWEEN LAD.FROM_DATE AND LAD.TO_DATE AND 
													LA.Approval_Status = 'A' AND LAD.Leave_ID  <> @Leave_ID AND LM.LEAVE_TYPE <> 'Company Purpose'
									) 
										BEGIN
											
												SELECT 	0 as LeaveAprID,'0' as Flag
												RETURN	
										END
									
									IF EXISTS
									(
										SELECT		1	 
										FROM		T0100_LEAVE_APPLICATION LA WITH (NOLOCK)
										INNER JOIN	T0110_LEAVE_APPLICATION_DETAIL LAD WITH (NOLOCK) ON LA.LEAVE_APPLICATION_ID=LAD.LEAVE_APPLICATION_ID
										INNER JOIN  T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LAD.LEAVE_ID = LM.LEAVE_ID
										WHERE		LA.Emp_ID=@EMP_ID AND @TEMP_DATE BETWEEN FROM_DATE AND TO_DATE AND 
													LAD.Leave_Application_Id  <> @Leave_ID AND LM.LEAVE_TYPE <> 'Company Purpose'
									)
										BEGIN
										
											    SELECT 	0 AS LEAVEAPRID,'0' as Flag
												RETURN	
										
										END
								
							
						
								SET @LEAVE_USED = 0
								--ISNULL(LEAVE_USED,0)
								SELECT @TOTAL_PERIOD  = @TOTAL_PERIOD - ISNULL(LEAVE_USED,0)
								FROM T0140_LEAVE_TRANSACTION  WITH (NOLOCK) WHERE EMP_ID = @EMP_ID AND FOR_DATE = @TEMP_DATE AND CMP_ID = @CMP_ID AND LEAVE_ID = @Leave_ID
								
								
								SELECT @LEAVE_USED  = SUM(ISNULL(LEAVE_USED,0))
								FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK) WHERE EMP_ID = @EMP_ID AND FOR_DATE = @TEMP_DATE AND CMP_ID = @CMP_ID AND LEAVE_ID = @Leave_ID
								
								
								IF(@LEAVE_USED <> 1)
									BEGIN
									
											IF @LEAVE_USED / 1 = 0 
													PRINT @LEAVE_USED
											ELSE
												BEGIN
													SET @HALF_LEAVE_FLAG = 0
													SET @TOTAL_HALF_LEAVE_DATE += CAST(@TEMP_DATE AS VARCHAR(50)) + ','
												END
											
									END
								
								IF NOT EXISTS	
								(  
									SELECT		1 
									FROM		T0120_LEAVE_APPROVAL LA WITH (NOLOCK)
									INNER JOIN	T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Approval_ID=LAD.Leave_Approval_ID
									WHERE		LA.CMP_ID = @CMP_ID AND LA.Emp_ID=@EMP_ID AND @TEMP_DATE BETWEEN LAD.FROM_DATE AND LAD.TO_DATE AND 
												LA.Approval_Status = 'A' and LAD.LEAVE_ID = @Leave_ID
								) OR (@HALF_LEAVE_FLAG = 0)
										
								BEGIN
									
									SET @TOTAL_DATE += CAST(@TEMP_DATE AS VARCHAR(50)) + ','
									
								END
								
								SET @TEMP_DATE  = DATEADD(d, 1, @TEMP_DATE );
								
								
								
						END	
						
						
		
						IF (ISNULL(@TOTAL_DATE,'') <> '')
								BEGIN
							
								SELECT * 
								INTO #TBL_TRAVEL_DATE
								FROM dbo.SplitString(@TOTAL_DATE, ',') T
								WHERE ISNULL(T.PART,'') <> ''
								
								SELECT @FROM_DATE = MIN(CONVERT(DATE,PART)) FROM #TBL_TRAVEL_DATE
								SELECT @TO_DATE = MAX(CONVERT(DATE,PART)) FROM #TBL_TRAVEL_DATE
								
								--SELECT @LEAVE_PERIOD = DATEDIFF(DAY, @FROM_DATE, @TO_DATE)
								SELECT @LEAVE_PERIOD = @TOTAL_PERIOD
								FROM #TBL_TRAVEL_DATE
								--IF (@LEAVE_PERIOD = 0)
									--SET @LEAVE_PERIOD = 1  
								
								
								IF (ISNULL(@TOTAL_HALF_LEAVE_DATE,'') <> '')
									BEGIN
									
										SELECT * 
										INTO #TBL_HALF_TRAVEL_DATES
										FROM dbo.SplitString(@TOTAL_HALF_LEAVE_DATE, ',') T
										WHERE ISNULL(T.PART,'') <> ''
										
										SELECT @HALF_LEAVE_MAX_DATE = MAX(CONVERT(DATE,PART)) FROM #TBL_HALF_TRAVEL_DATES
										
										SELECT @LEAVE_ASSIGN_AS_HALF = LEAVE_ASSIGN_AS FROM T0120_LEAVE_APPROVAL LA WITH (NOLOCK)
											INNER JOIN	T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Approval_ID=LAD.Leave_Approval_ID
											WHERE		LA.CMP_ID = @CMP_ID AND LA.Emp_ID=@EMP_ID AND @HALF_LEAVE_MAX_DATE BETWEEN LAD.FROM_DATE AND LAD.TO_DATE AND 
														LA.Approval_Status = 'A' and LAD.LEAVE_ID = @Leave_ID
									    
										
									END
								
								
							
								SELECT  @LEAVE_APR_ID = ISNULL(MAX(LEAVE_APPROVAL_ID),0) + 1  FROM T0120_LEAVE_APPROVAL  WITH (NOLOCK)
								
								
								INSERT INTO T0120_LEAVE_APPROVAL(Leave_Approval_ID, Leave_Application_ID, Cmp_ID, Emp_ID, S_Emp_ID,Approval_Date,Approval_Status,Approval_Comments,Login_ID,System_Date,Is_Backdated_App)                
														VALUES	(@LEAVE_APR_ID,NULL,@Cmp_ID,@Emp_ID,@S_Emp_ID,GETDATE(),@Approval_Status,'',0,getdate(),@Is_Backdated_App)   					
								
								
						
							 	IF NOT EXISTS	
									(  
										SELECT 1 FROM T0120_LEAVE_APPROVAL LA WITH (NOLOCK)
										INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Approval_ID=LAD.Leave_Approval_ID 
										WHERE	LA.CMP_ID = @CMP_ID AND LA.Emp_ID=@EMP_ID AND @To_Date BETWEEN LAD.FROM_DATE AND LAD.TO_DATE 
												AND LA.Approval_Status = 'A' and 
												LAD.LEAVE_ID = @Leave_ID --AND LAD.LEAVE_APPROVAL_ID = @Leave_Approval_ID
									)	
										
								BEGIN
									
									SELECT @ROW_ID = ISNULL(MAX(ROW_ID),0) + 1   FROM T0130_LEAVE_APPROVAL_DETAIL WITH (NOLOCK)
									
									--IF (@LEAVE_ASSIGN_AS_HALF <> '')
									--	BEGIN
										
									--		IF(@LEAVE_ASSIGN_AS_HALF = 'First Half')
									--			SET @Leave_Assign_As = 'Second Half'
									--		ELSE IF(@LEAVE_ASSIGN_AS_HALF = 'Second Half')
									--			SET @Leave_Assign_As = 'First Half'
											
									--	END
										
										
										
									INSERT INTO T0130_LEAVE_APPROVAL_DETAIL
												  (
														Leave_Approval_ID, 
														Cmp_ID, 
														Leave_ID, 
														From_Date, 
														To_Date, 
														Leave_Period, 
														Leave_Assign_As, 
														Leave_Reason, 
														Row_ID, 
														Login_ID, 
														System_Date,
														IS_Import,
														M_Cancel_WO_HO,
														Half_Leave_Date,
														leave_Out_time,
														leave_In_time,
														NightHalt,
														Leave_CompOff_Dates,
														Half_Payment,
														Warning_flag,
														rules_violate
													)
											VALUES	(
														@LEAVE_APR_ID,
														@Cmp_ID,
														@Leave_ID,
														@From_Date,
														@To_Date,
														@Leave_Period,
														@Leave_Assign_As,
														@Leave_Reason,
														@Row_ID,
														@Login_ID,
														getdate(),
														@Is_Import,
														@M_Cancel_WO_HO,
														--ISNULL(@HALF_LEAVE_MAX_DATE,@Half_Leave_Date),
														@Half_Leave_Date,
														@Leave_Out_Time,
														@Leave_In_Time,
														@NightHalt,
														@strLeaveCompOff_Dates,
														@Half_Payment,
														@Warning_flag,
														@rules_violate
													)
									
								END
							END
							
					END
					
					
			SELECT 	ISNULL(@LEAVE_APR_ID,0) AS LEAVEAPRID,'1' AS FLAG

		END
			
	
	
RETURN



