
CREATE PROCEDURE [dbo].[P9999_IMPORT_SHIFT_SCHEDULE_ESS]	
@Cmp_Id_Para As Numeric(18,0),
@Sup_Emp_Id  As Numeric (18,0) = 0,	--Ankit 18062014
@Log_Status Int = 0 Output,
@Row_No Int=0,
@GUID Varchar(2000) = '',
@User_ID int = 0, -- added by rajput on 29062019
@Import_By int = 0 -- added by rajput on 29062019
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @Emp_ID			numeric 
	Declare @Cmp_ID			numeric 
	DEclare @Emp_Code		varchar(40)
	Declare @Month			numeric 
	Declare @Year			numeric 
	
	Declare @Day1			varchar(100)	
	Declare @Day2			varchar(100)
	Declare @Day3			varchar(100)
	DEclare @Day4			varchar(100)
	DEclare @Day5			varchar(100)
	DEclare @Day6			varchar(100)
	Declare @Day7			varchar(100)	
	DEclare @Day8			varchar(100)	
	Declare @Day9			varchar(100)
	Declare @Day10			varchar(100)
	Declare @Day11			varchar(100)	
	Declare @Day12			varchar(100)
	Declare @Day13			varchar(100)
	Declare @Day14			varchar(100)
	Declare @Day15			varchar(100)
	Declare @Day16			varchar(100)
	Declare @Day17			varchar(100)
	Declare @Day18			varchar(100)
	Declare @Day19			varchar(100)
	Declare @Day20			varchar(100)
	Declare @Day21			varchar(100)
	Declare @Day22			varchar(100)
	Declare @Day23			varchar(100)
	Declare @Day24			varchar(100)
	Declare @Day25			varchar(100)
	Declare @Day26			varchar(100)
	Declare @Day27			varchar(100)	
	Declare @Day28			varchar(100)
	Declare @Day29			varchar(100)
	Declare @Day30			varchar(100)
	Declare @Day31			varchar(100)
	Declare @For_Date		Datetime
	Declare @Shift_Type		numeric(1,0)									  			
	Declare @Shift_ID		numeric		
	Declare @Shift_Tran_ID	numeric
	
	---- '' Manager Import shift --'' Ankit 18062014
	Declare @LogDesc	nvarchar(max)
	Declare @Alpha_Emp_Code Varchar(100)
	Declare @Emp_Name Varchar(100)
	Declare @Alpha_Emp_Code_11 Varchar(100)
	declare @Max_TranId numeric(18,0)
	set @Max_TranId = 0
	
	
	

	IF @Sup_Emp_Id > 0
		BEGIN
			Delete From Event_Logs where Module_Name = 'Shift Rotation Import Manager' And Cmp_Id = @Cmp_Id_Para
			--Delete From T0080_Import_Log where Import_type = 'Shift Rotation Import Manager' And Cmp_Id = @Cmp_Id_Para
			
			Declare Curr_EmpShift cursor for
				Select Emp_Code From T9999_IMPORT_SHIFT_SCHEDULE WITH (NOLOCK)
				Where Month > 0 and year >0	
			Open Curr_EmpShift
			fetch next from Curr_EmpShift into 	@Alpha_Emp_Code
			
			While @@fetch_Status=0
				Begin
					
					If Exists(Select 1 FROM T9999_IMPORT_SHIFT_SCHEDULE WITH (NOLOCK)
						WHERE Month > 0 and year >0 AND Emp_Code = @Alpha_Emp_Code And
						EMP_CODE NOT IN (Select E.Alpha_Emp_Code
								  From T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN 
									   T0090_EMP_REPORTING_DETAIL R WITH (NOLOCK) ON E.Emp_ID = R.Emp_ID
								  Where R.R_Emp_ID = @Sup_Emp_Id ) )
				
						Begin
							Select @Alpha_Emp_Code_11 = Emp_Code,@Emp_Name = Emp_Name FROM T9999_IMPORT_SHIFT_SCHEDULE WITH (NOLOCK)
							WHERE Month > 0 and year >0 AND Emp_Code = @Alpha_Emp_Code And
								EMP_CODE NOT IN (Select E.Alpha_Emp_Code
												  From T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN 
													   T0090_EMP_REPORTING_DETAIL R WITH (NOLOCK) ON E.Emp_ID = R.Emp_ID
												  Where R.R_Emp_ID = @Sup_Emp_Id )	
							
							Set @LogDesc = 'Emp_Code='+@Alpha_Emp_Code_11+', Employee Name='+ @Emp_Name
							exec Event_Logs_Insert 0,@Cmp_Id_Para,@Emp_Id,@Sup_Emp_Id,'Shift Rotation Import Manager','Employee Shift Rotation can not Import',@LogDesc,1,'' --commented by Mukti(15032017)			 
							
							--Added by Mukti(15032017)start
							Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id_Para,@Alpha_Emp_Code_11,@LogDesc,0,'Employee Shift Rotation can not Import',GetDate(),'Shift Rotation Import Manager',@GUID)						
							SET @Log_Status=1
							
						End
					--Else If Exists(Select 1 FROM T9999_IMPORT_SHIFT_SCHEDULE 
					--	WHERE Month > 0 and year >0 AND Emp_Code = @Alpha_Emp_Code And
					--	EMP_CODE IN (Select E.Alpha_Emp_Code
					--			  From T0080_EMP_MASTER E INNER JOIN 
					--				   T0090_EMP_REPORTING_DETAIL R ON E.Emp_ID = R.Emp_ID
					--			  Where R.R_Emp_ID = @Sup_Emp_Id ) )
				
					--	Begin
					--		Select @Alpha_Emp_Code_11 = Emp_Code,@Emp_Name = Emp_Name FROM T9999_IMPORT_SHIFT_SCHEDULE 
					--		WHERE Month > 0 and year >0 AND Emp_Code = @Alpha_Emp_Code And
					--			EMP_CODE IN (Select E.Alpha_Emp_Code
					--							  From T0080_EMP_MASTER E INNER JOIN 
					--								   T0090_EMP_REPORTING_DETAIL R ON E.Emp_ID = R.Emp_ID
					--							  Where R.R_Emp_ID = @Sup_Emp_Id )	
							
					--		Set @LogDesc = 'Emp_Code='+@Alpha_Emp_Code_11+', Employee Name='+ @Emp_Name
					--		exec Event_Logs_Insert 0,@Cmp_Id_Para,@Emp_Id,@Emp_ID,'Shift Rotaion Import Manager','Employee Shift Rotation Sheet Imported Successfully',@LogDesc,1,''			
					--		--return -1
					--	End
						
					Fetch next from Curr_EmpShift into @Alpha_Emp_Code
				End
					
			Close Curr_EmpShift
			Deallocate Curr_EmpShift
		
		
			Delete FROM T9999_IMPORT_SHIFT_SCHEDULE 
			WHERE Month > 0 and year >0 AND
				EMP_CODE NOT IN (Select E.Alpha_Emp_Code
								  From T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN 
									   T0090_EMP_REPORTING_DETAIL R WITH (NOLOCK) ON E.Emp_ID = R.Emp_ID
								  Where R.R_Emp_ID = @Sup_Emp_Id )	
		
		END
		
		
	
		----- CODE ADDED BY RAJPUT 03072019
		DECLARE @LOG_TRANID AS NUMERIC(18,0)
		SET		@LOG_TRANID = 0
		
				
		IF OBJECT_ID('tempdb..#SHIFT') IS NOT NULL
		BEGIN

			DROP TABLE #SHIFT
		END
		IF OBJECT_ID('tempdb..#SHIFT_DATA') IS NOT NULL
		BEGIN
			DROP TABLE #SHIFT_DATA
		END
			
	
		
		----- UNPIVOT CONDITION 
		SELECT EMP_ID, EMP_NAME, EMP_CODE,[MONTH],[YEAR],
			(
				CASE 
					WHEN CHARINDEX('#',SHIFT) > 0 
						THEN
							CASE WHEN CHARINDEX('#T#W',SHIFT,0) > 0 THEN RTRIM(LTRIM(SUBSTRING(SHIFT,0,LEN(SHIFT) - 3))) ELSE RTRIM(LTRIM(SUBSTRING(SHIFT,0,LEN(SHIFT) - 1))) END
						ELSE 
							RTRIM(LTRIM(SHIFT))
				END
			) AS SHIFT,
			(CASE WHEN CHARINDEX('-',SHIFT,0) > 0 THEN 1 WHEN CHARINDEX('#T',SHIFT,0) > 0 THEN 1  ELSE 0 END)AS SHIFT_TYPE,
			(CASE WHEN CHARINDEX('#',SHIFT) >0 THEN RIGHT(SHIFT, 1) ELSE '' END) AS WFLAG,FOR_DAYS,CONVERT(DATETIME,CAST([YEAR] AS VARCHAR(4)) + '-' + CAST([MONTH] AS VARCHAR(2)) + '-' + SUBSTRING(FOR_DAYS,4,LEN(FOR_DAYS))) AS FOR_DATE
		INTO #SHIFT
		FROM T9999_IMPORT_SHIFT_SCHEDULE I WITH (NOLOCK)
			
		UNPIVOT
		(
			SHIFT
			FOR FOR_DAYS IN (DAY1,DAY2,DAY3,DAY4,DAY5,DAY6,DAY7,DAY8,DAY9,DAY10,DAY11,DAY12,DAY13,DAY14,DAY15,DAY16,DAY17,DAY18,DAY19,DAY20,DAY21,DAY22,DAY23,DAY24,DAY25,DAY26,DAY27,DAY28,DAY29,DAY30,DAY31)
		) AS SCHOOLUNPIVOT
		
			

		ALTER TABLE #SHIFT ADD CMP_ID INT


		
	    update #SHIFT set Shift=0  where Shift ='' or SHIFT is null --Added by ronakk 20012023

		

		--Change by Ronak 08122022
		UPDATE S SET CMP_ID=isnull(SM.Cmp_ID,@Cmp_Id_Para)
		,Emp_ID = EM.Emp_ID
		FROM #SHIFT S 
		left JOIN T0040_SHIFT_MASTER SM ON SM.Shift_ID = S.SHIFT  --Added  by ronakk 06122022 for remove the duplicate employee from other company
		INNER JOIN T0080_EMP_MASTER EM ON S.Emp_Code = EM.Alpha_Emp_Code and isnull(SM.Cmp_ID,@Cmp_Id_Para) = EM.Cmp_ID
		
		update #SHIFT set CMP_ID=@Cmp_Id_Para  where CMP_ID  is null  --Added by ronakk 20012023





		--- TAKE DEFAULT RECORDS
		SELECT	S.EMP_ID, EMP_NAME, EMP_CODE,[MONTH],[YEAR],0 AS SHIFT_ID,SHIFT,SHIFT_TYPE,WFLAG,FOR_DAYS,FOR_DATE, CMP_ID
		INTO #SHIFT_DATA 
		FROM #SHIFT S WHERE EMP_ID = 0

		
		--- CHECK CONDITION IMPORT BY SHIFT_NAME OR SHIFT ID
		IF (@Import_By = 1)
			BEGIN
				IF EXISTS(	SELECT 1 FROM #SHIFT WHERE ISNUMERIC(SHIFT) = 1 )
						BEGIN
							DELETE FROM T9999_IMPORT_SHIFT_SCHEDULE
							
							SELECT	@LOG_TRANID = ISNULL(MAX(IM_ID),0) FROM T0080_IMPORT_LOG WITH (NOLOCK)
							INSERT INTO DBO.T0080_IMPORT_LOG 
							SELECT @LOG_TRANID + (ROW_NUMBER() OVER(ORDER BY EMP_ID ASC)) AS RowNo,
							@CMP_ID_PARA,EMP_CODE,'Wrong ShiftName Imported',0,'Shift Name Does not match',GETDATE(),'MONTHLY SHIFT IMPORT',@GUID
							FROM #SHIFT 
							WHERE ISNUMERIC(SHIFT) = 1
							 
							SET @LOG_STATUS=1
							RETURN			
						END
				  --For Shift Name wise logic 
				begin
					INSERT INTO #SHIFT_DATA
					SELECT	Distinct EM.EMP_ID, S.EMP_NAME, S.EMP_CODE,S.[MONTH],S.[YEAR],SM.SHIFT_ID,RTRIM(LTRIM(S.SHIFT)) AS SHIFT,
					S.SHIFT_TYPE,S.WFLAG,S.FOR_DAYS,S.FOR_DATE, S.Cmp_ID
					FROM #SHIFT S 
					INNER JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK) ON RTRIM(LTRIM(S.SHIFT)) = RTRIM(LTRIM(SM.SHIFT_NAME)) AND SM.CMP_ID = @CMP_ID_PARA
					INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON S.Emp_Code = EM.Alpha_Emp_Code 
					--WHERE EM.CMP_ID = @Cmp_Id_Para
					ORDER BY FOR_DATE,EMP_ID ASC
				end
			


				IF EXISTS(SELECT	SHIFT FROM	#SHIFT SFT WHERE	NOT EXISTS 
																	( SELECT SHIFT_NAME FROM T0040_SHIFT_MASTER SM WITH (NOLOCK)
																	 WHERE SFT.SHIFT = SM.SHIFT_NAME AND SM.CMP_ID = SFT.CMP_ID --AND SM.CMP_ID = @CMP_ID_PARA
																	 )
						  ) 
				BEGIN

					--SELECT	SFT.EMP_ID,SFT.SHIFT,SFT.EMP_NAME,SFT.EMP_CODE
					--INTO	#TBL_INVALID_SHIFT_NAME
					--FROM	T0040_SHIFT_MASTER SM 
					--		INNER JOIN #SHIFT SFT ON SM.SHIFT_NAME <> SFT.SHIFT
					--WHERE	SM.CMP_ID = @CMP_ID_PARA
					
					SELECT	SFT.EMP_ID,SFT.SHIFT,SFT.EMP_NAME,SFT.EMP_CODE
					INTO	#TBL_INVALID_SHIFT_NAME
					FROM	#SHIFT SFT
					WHERE	NOT EXISTS 
							(
								 SELECT SHIFT_NAME 
								 FROM T0040_SHIFT_MASTER SM WITH (NOLOCK)
								 WHERE SFT.SHIFT = SM.SHIFT_NAME AND SM.CMP_ID = SFT.CMP_ID --AND SM.CMP_ID = @CMP_ID_PARA
							)
					SELECT	@LOG_TRANID = ISNULL(MAX(IM_ID),0) FROM T0080_IMPORT_LOG WITH (NOLOCK)
					INSERT INTO DBO.T0080_IMPORT_LOG 
					SELECT @LOG_TRANID + (ROW_NUMBER() OVER(ORDER BY EMP_ID ASC)) AS RowNo,
					@CMP_ID_PARA,EMP_CODE,'INCORRECT SHIFT NAME',0,'EMPLOYEE SHIFT ROTATION CAN NOT IMPORT',GETDATE(),'MONTHLY SHIFT IMPORT',@GUID
					FROM #TBL_INVALID_SHIFT_NAME
					
					SET @LOG_STATUS=1
					RETURN					
				END		

			END
		ELSE
			BEGIN
				   --For Shift ID wise logic 
					update #SHIFT set [Shift] = NULL where isnull([SHIFT],'') = ''
					 
					IF EXISTS(SELECT 1 FROM #SHIFT WHERE ISNUMERIC(SHIFT) = 0 and isnull([SHIFT],'') <> '')
						BEGIN
							DELETE FROM T9999_IMPORT_SHIFT_SCHEDULE 
					
							SELECT	@LOG_TRANID = ISNULL(MAX(IM_ID),0) FROM T0080_IMPORT_LOG WITH (NOLOCK)
							INSERT INTO DBO.T0080_IMPORT_LOG 
							SELECT @LOG_TRANID + (ROW_NUMBER() OVER(ORDER BY EMP_ID ASC)) AS RowNo,
							@CMP_ID_PARA,EMP_CODE,'Wrong ShiftID Imported',0,'Shift ID does not match',GETDATE(),'MONTHLY SHIFT IMPORT',@GUID
							FROM #SHIFT 
							WHERE ISNUMERIC(SHIFT) = 0
							 
							SET @LOG_STATUS=1
							RETURN			
						END
						
						
				INSERT INTO #SHIFT_DATA
				SELECT	EM.EMP_ID, S.EMP_NAME, S.EMP_CODE,S.[MONTH],S.[YEAR],(CASE WHEN CHARINDEX('-',SM.SHIFT_ID,0) > 0 THEN REPLACE(SM.SHIFT_ID,'-','') ELSE SM.SHIFT_ID END),RTRIM(LTRIM(S.SHIFT)) AS SHIFT,S.SHIFT_TYPE,S.WFLAG,S.FOR_DAYS,S.FOR_DATE, S.CMP_ID
				FROM #SHIFT S 
				INNER JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK) ON CAST(RTRIM(LTRIM((CASE WHEN CHARINDEX('-',S.SHIFT,0) > 0 THEN REPLACE(S.SHIFT,'-','') ELSE S.SHIFT END))) AS NUMERIC) = SM.SHIFT_ID --AND SM.CMP_ID = @CMP_ID_PARA
				INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON S.Emp_Code = EM.Alpha_Emp_Code  and S.Cmp_id = EM.Cmp_ID  --Added by ronakk 0612022 for get proper employee
				--WHERE EM.CMP_ID = @CMP_ID_PARA
				ORDER BY FOR_DATE,EMP_ID ASC

		

				IF (SELECT COUNT(1) FROM #SHIFT where SHIFT = 0) <>(SELECT COUNT(1) FROM #SHIFT)
					Begin--Added by ronakk condtion for direct weekoff assigne (disccuse with sandip bhai and Sajid bhai) 20012023 Ticket #23976

								--- VALIDATION FOR SHIFT MASTER EXIST OR NOT AS PER SHIFT ID WISE
								IF NOT EXISTS(	
								                SELECT		1	
												FROM		T0040_SHIFT_MASTER SM WITH (NOLOCK)
												INNER JOIN	#SHIFT SFT ON SM.SHIFT_ID = SFT.SHIFT AND SFT.cmp_id =SM.Cmp_ID --Added by ronakk 20012023
												)--WHERE	SM.CMP_ID = @CMP_ID_PARA) 
								BEGIN
									
									SELECT	SFT.EMP_ID,SFT.SHIFT,SFT.EMP_NAME,SFT.EMP_CODE
									INTO	#TBL_INVALID_SHIFT_ID
									FROM	T0040_SHIFT_MASTER SM WITH (NOLOCK)
											INNER JOIN #SHIFT SFT ON SM.SHIFT_ID <> SFT.SHIFT
											group by SFT.EMP_ID,SFT.SHIFT,SFT.EMP_NAME,SFT.EMP_CODE --Added by ronakk 20012023
									--WHERE	SM.CMP_ID = @CMP_ID_PARA
									
									SELECT	@LOG_TRANID = ISNULL(MAX(IM_ID),0) FROM T0080_IMPORT_LOG WITH (NOLOCK)
										
									INSERT INTO DBO.T0080_IMPORT_LOG 
									SELECT @LOG_TRANID + (ROW_NUMBER() OVER(ORDER BY EMP_ID ASC)) AS RowNo,
									@CMP_ID_PARA,EMP_CODE,'INCORRECT SHIFT ID',0,'EMPLOYEE SHIFT ROTATION CAN NOT IMPORT',GETDATE(),'MONTHLY SHIFT IMPORT',@GUID
									FROM #TBL_INVALID_SHIFT_ID
									
									SET @LOG_STATUS=1
									RETURN				
			 						
								END		
                   END

			
			END
			
		
			----- MONTHLY SALARY EXIST OR-NOT CONDITION 
			IF EXISTS	(
							SELECT 1	FROM	T0200_MONTHLY_SALARY MS WITH (NOLOCK) INNER JOIN #SHIFT SFT ON MS.EMP_ID = SFT.EMP_ID AND 
												MONTH(MS.MONTH_END_DATE) = SFT.[MONTH] AND YEAR(MS.MONTH_END_DATE) = SFT.[YEAR]
										--WHERE	MS.CMP_ID = @CMP_ID_PARA
						) 
				BEGIN
					
					
					SELECT	SFT.EMP_ID,SFT.EMP_NAME,SFT.EMP_CODE
					INTO	#TBL_SALARY_EXIST
					FROM	T0200_MONTHLY_SALARY MS WITH (NOLOCK) INNER JOIN #SHIFT SFT ON MS.EMP_ID = SFT.EMP_ID AND 
							MONTH(MS.MONTH_END_DATE) = SFT.[MONTH]  AND YEAR(MS.MONTH_END_DATE) = SFT.[YEAR]
					--WHERE	MS.CMP_ID = @CMP_ID_PARA
					
					
					SELECT	@LOG_TRANID = ISNULL(MAX(IM_ID),0) FROM T0080_IMPORT_LOG WITH (NOLOCK)
						
					--SELECT @ALPHA_EMP_CODE_11 = ALPHA_EMP_CODE,@EMP_NAME = EMP_FULL_NAME FROM T0080_EMP_MASTER 
					--WHERE EMP_ID = @EMP_ID
												  
					--SET @LOGDESC = 'EMP_CODE='+@ALPHA_EMP_CODE_11+', EMPLOYEE NAME='+ @EMP_NAME + 'SALARY EXISTS'
					
					
					 INSERT INTO DBO.T0080_IMPORT_LOG 
					 SELECT @LOG_TRANID + (ROW_NUMBER() OVER(ORDER BY EMP_ID ASC)) AS RowNo,
					 @CMP_ID_PARA,EMP_CODE,'SALARY EXISTS',0,'EMPLOYEE SHIFT ROTATION CAN NOT IMPORT',GETDATE(),'MONTHLY SHIFT IMPORT',@GUID
					 FROM #TBL_SALARY_EXIST
					 
					 SET @LOG_STATUS=1
					 RETURN				
				 		
				END		
			
			--- SALARY EXIST RECORDS DELETED
			DELETE	S
			FROM	#SHIFT S INNER JOIN T0200_MONTHLY_SALARY MS ON S.EMP_ID = MS.EMP_ID AND S.[MONTH] = MONTH(MS.MONTH_END_DATE) AND 
					S.[YEAR] = YEAR(MS.MONTH_END_DATE)
			--WHERE	MS.CMP_ID = @CMP_ID_PARA
			
			
			
			------- CODE FOR WEEKOFF AND CANCEL WEEKOFF UPDATE INTO ROSTER TABLE
			DECLARE @MAX_ROSTER_TRANID AS NUMERIC(18,0)
			SET		@MAX_ROSTER_TRANID = 0
			SELECT @MAX_ROSTER_TRANID = ISNULL(MAX(TRAN_ID),0) FROM T0100_WEEKOFF_ROSTER WITH (NOLOCK)
			
			--select FOR_DATE,count(Emp_ID) from #SHIFT_DATA
			--group by FOR_DATE having COUNT(Emp_ID) > 1
			
			--delete w from #SHIFT_DATA w 
			--inner join 
			--(
			--	select FOR_DATE,Emp_ID from #SHIFT_DATA
			--	group by FOR_DATE,Emp_ID having COUNT(Emp_ID) > 1
			--) tmpo on w.FOR_DATE = tmpo.FOR_DATE and w.Emp_ID = tmpo.Emp_ID
			
			--return
			


			
			--Comment by ronakk 08122022 for week-off with  id bypass
			--IF EXISTS(
			--			SELECT	1
			--			FROM	#SHIFT_DATA S 
			--			INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON S.EMP_ID = EM.EMP_ID
			--			INNER JOIN T0100_WEEKOFF_ROSTER WR WITH (NOLOCK) ON S.EMP_ID = WR.EMP_ID AND S.FOR_DATE = WR.FOR_DATE
						
			--		)
			--		BEGIN	
						
			--			--- FIRST DELETE RECORDS FROM T0100_WEEKOFF_ROSTER IF RECORDS IS EXIST
			--			DELETE		WR
			--			FROM		T0100_WEEKOFF_ROSTER WR  
			--			INNER JOIN	#SHIFT_DATA S ON S.EMP_ID = WR.EMP_ID AND S.FOR_DATE = WR.FOR_DATE
						
			--		END

			--Added by ronakk 08122022 for take week-off in on going shift without any ID
			IF EXISTS(
						SELECT	1
						FROM	#SHIFT S 
						INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON S.EMP_ID = EM.EMP_ID
						INNER JOIN T0100_WEEKOFF_ROSTER WR WITH (NOLOCK) ON S.EMP_ID = WR.EMP_ID AND S.FOR_DATE = WR.FOR_DATE
						
					)
					BEGIN	
						
						--- FIRST DELETE RECORDS FROM T0100_WEEKOFF_ROSTER IF RECORDS IS EXIST
						DELETE		WR
						FROM		T0100_WEEKOFF_ROSTER WR  
						INNER JOIN	#SHIFT S ON S.EMP_ID = WR.EMP_ID AND S.FOR_DATE = WR.FOR_DATE
						
					END



						  
			---- INSERT RECORDS IN T0100_WEEKOFF_ROSTER   --Comment by ronakk 08122022 
			--INSERT INTO T0100_WEEKOFF_ROSTER(TRAN_ID,CMP_ID,EMP_ID,FOR_DATE,IS_CANCEL_WO,USER_ID,SYSTEM_DATE)
			--SELECT	@MAX_ROSTER_TRANID + (ROW_NUMBER() OVER(ORDER BY EMP_ID ASC)) AS RowNo,CMP_ID,EMP_ID,FOR_DATE,(CASE WHEN WFLAG = 'W' THEN 0 ELSE 1 END),@User_ID,GETDATE()
			--FROM		#SHIFT_DATA WHERE ISNULL(WFLAG,'') <> ''

		

            --Added by ronakk 08122022 change the table take the week-off and cancelation directly 
			INSERT INTO T0100_WEEKOFF_ROSTER(TRAN_ID,CMP_ID,EMP_ID,FOR_DATE,IS_CANCEL_WO,USER_ID,SYSTEM_DATE)
			SELECT	@MAX_ROSTER_TRANID + (ROW_NUMBER() OVER(ORDER BY EMP_ID ASC)) AS RowNo,CMP_ID,EMP_ID,FOR_DATE,(CASE WHEN WFLAG = 'W' THEN 0 ELSE 1 END),@User_ID,GETDATE()
			FROM		#SHIFT WHERE ISNULL(WFLAG,'') <> '' -- Change by ronakk 08122022

			
		
				

			------- CODE FOR SHIFT ASSIGN IN SHIFT DETAIL TABLE
				IF EXISTS(
						SELECT		1
						FROM		#SHIFT_DATA S 
						INNER JOIN	T0080_EMP_MASTER EM WITH (NOLOCK) ON S.EMP_ID = EM.EMP_ID
						INNER JOIN	T0100_EMP_SHIFT_DETAIL ESD WITH (NOLOCK) ON S.EMP_ID = ESD.EMP_ID AND S.FOR_DATE = ESD.FOR_DATE
						
					  )
					
					BEGIN	
					
					
						--- FIRST DELETE RECORDS FROM T0100_WEEKOFF_ROSTER IF RECORDS IS EXIST
						DELETE	ESD
						FROM	T0100_EMP_SHIFT_DETAIL ESD  
						INNER JOIN #SHIFT_DATA S ON S.EMP_ID = ESD.EMP_ID AND S.FOR_DATE = ESD.FOR_DATE
					
					END
					
					DECLARE	@MAX_SHIFT_TRANID AS NUMERIC(18,0)
					SET		@MAX_SHIFT_TRANID = 0
					SELECT	@MAX_SHIFT_TRANID = ISNULL(MAX(SHIFT_TRAN_ID),0) FROM T0100_EMP_SHIFT_DETAIL WITH (NOLOCK)
		     

			        

				--  INSERT RECORDS IN T0100_EMP_SHIFT_DETAIL
					INSERT INTO T0100_EMP_SHIFT_DETAIL(SHIFT_TRAN_ID, EMP_ID, CMP_ID, SHIFT_ID, FOR_DATE, SHIFT_TYPE)
					SELECT distinct	@MAX_SHIFT_TRANID + (ROW_NUMBER() OVER(ORDER BY EMP_ID ASC)) AS RowNo,EMP_ID,CMP_ID,SHIFT_ID,FOR_DATE,SHIFT_TYPE
					FROM	#SHIFT_DATA WHERE ISNULL(SHIFT_ID,0) <> 0

		
	----- END 
			
		
	
	-----'' Manager Import shift --'' Ankit 18062014
			
	--Declare Cur_Shift cursor for
	--	select Cmp_ID,e.Emp_Id,s.Emp_Code,Month,Year ,Day1,Day2,Day3,Day4,Day5,Day6,Day7,Day8,Day9,Day10
	--									  ,Day11,Day12,Day13,Day14,Day15,Day16,Day17,Day18,Day19,Day20
	--									  ,Day21,Day22,Day23,Day24,Day25,Day26,Day27,Day28,Day29,Day30,Day31
	--			From T9999_IMPORT_SHIFT_SCHEDULE S INNER JOIN T0080_EMP_MASTER E on s.emp_code =e.Alpha_emp_Code						  
	--			Where Month > 0 and year >0	
	--Open cur_Shift
	--fetch next from cur_Shift into @Cmp_Id,@Emp_ID,@Emp_Code,@Month,@Year ,@Day1,@Day2,@Day3,@Day4,@Day5,@Day6,@Day7,@Day8,@Day9,@Day10
	--									  ,@Day11,@Day12,@Day13,@Day14,@Day15,@Day16,@Day17,@Day18,@Day19,@Day20
	--									  ,@Day21,@Day22,@Day23,@Day24,@Day25,@Day26,@Day27,@Day28,@Day29,@Day30,@Day31
	
	
	--While @@fetch_Status=0
	--	begin
	--			 -- Added by rohit on 20102015 
				
	--			if Exists (select 1 from T0200_MONTHLY_SALARY where Emp_ID=@Emp_ID and MONTH(Month_End_Date) = @Month  and YEAR(Month_End_Date)=@Year) 
	--			begin
				
	--			 Select @Alpha_Emp_Code_11 = Alpha_Emp_Code,@Emp_Name = emp_full_name FROM t0080_emp_master 
	--			 WHERE emp_id = @Emp_ID
												  
	--			 Set @LogDesc = 'Emp_Code='+@Alpha_Emp_Code_11+', Employee Name='+ @Emp_Name + 'Salary Exists'
	--			 --exec Event_Logs_Insert 0,@Cmp_Id_Para,@Emp_Id,@Sup_Emp_Id,'Shift Rotation Import','Employee Shift Rotation can not Import',@LogDesc,1,''	--commented by Mukti(15032017)
	--			 --Added by Mukti(15032017)start
	--			 Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code_11,'Salary Exists',0,'Employee Shift Rotation can not Import',GetDate(),'Monthly Shift Import',@GUID)						
	--			 SET @Log_Status=1				
	--			 --Added by Mukti(15032017)end
	--			 Goto ABC;
				 		
	--			end			
	--			-- Ended by rohit on 20102015 
				 
				 
	--			Delete from T0100_EMP_SHIFT_DETAIL where emp_ID=@Emp_ID and Month(For_Date) =@month and Year(for_Date)=@Year			
				
							
	--			if (charindex('-',@Day1,0) > 0 and len(@Day1) > 1 ) or isnumeric(@Day1) =1
	--				begin						
						
	--					if charindex('-',@Day1,0) > 0 
	--						set @shift_Type =1
	--					else
	--						set @shift_Type =0	
							
	--					set @Day1 = replace(@day1,'-','')
						
						
	--					if isnumeric(@Day1) =1 
	--						begin
	--							if exists(Select Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day1)
	--								begin
										
	--									Select @Shift_ID = Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day1
	--									select @Shift_Tran_ID = isnull(max(Shift_Tran_ID),0) + 1 from T0100_EMP_SHIFT_DETAIL
	--									select  @For_Date = dbo.GET_MONTH_ST_DATE(@month,@Year)
										
	--									INSERT INTO T0100_EMP_SHIFT_DETAIL
	--									                            (Shift_Tran_ID, Emp_ID, Cmp_ID, Shift_ID, For_Date, Shift_Type)
	--									VALUES     (@Shift_Tran_ID, @Emp_ID, @Cmp_ID, @Shift_ID, @For_Date, @Shift_Type)
	--								end
	--						end
	--				end
				
	--		if (charindex('-',@Day2,0) > 0 and len(@Day2) > 1 ) or isnumeric(@Day2) =1 
	--				begin					
	--					if charindex('-',@Day2,0) > 0 
	--						set @shift_Type =1
	--					else
	--						set @shift_Type =0
	--					set @Day2 = replace(@Day2,'-','')
	--					if isnumeric(@Day2) =1 
	--						begin
	--							if exists(Select Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day2)
	--								begin
	--									Select @Shift_ID = Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day2
	--									select @Shift_Tran_ID = isnull(max(Shift_Tran_ID),0) + 1 from T0100_EMP_SHIFT_DETAIL
	--									select  @For_Date = dateadd(d,1,dbo.GET_MONTH_ST_DATE(@month,@Year))
										
	--									INSERT INTO T0100_EMP_SHIFT_DETAIL
	--									                            (Shift_Tran_ID, Emp_ID, Cmp_ID, Shift_ID, For_Date, Shift_Type)
	--									VALUES     (@Shift_Tran_ID, @Emp_ID, @Cmp_ID, @Shift_ID, @For_Date, @Shift_Type)
	--								end
	--						end
	--				end


	--			if ( charindex('-',@Day3,0) > 0 and len(@Day3) > 1 ) or isnumeric(@Day3) =1 
	--				begin
						
	--					if charindex('-',@Day3,0) > 0 
	--						set @shift_Type =1
	--					else
	--						set @shift_Type =0
	--					set @Day3 = replace(@Day3,'-','')
	--					if isnumeric(@Day3) =1 
	--						begin
	--							if exists(Select Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day3)
	--								begin
	--									Select @Shift_ID = Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day3
	--									select @Shift_Tran_ID = isnull(max(Shift_Tran_ID),0) + 1 from T0100_EMP_SHIFT_DETAIL
	--									select  @For_Date = dateadd(d,2,dbo.GET_MONTH_ST_DATE(@month,@Year))
										
	--									INSERT INTO T0100_EMP_SHIFT_DETAIL
	--									                            (Shift_Tran_ID, Emp_ID, Cmp_ID, Shift_ID, For_Date, Shift_Type)
	--									VALUES     (@Shift_Tran_ID, @Emp_ID, @Cmp_ID, @Shift_ID, @For_Date, @Shift_Type)
	--								end
	--						end
	--				end

	--			if ( charindex('-',@Day4,0) > 0 and len(@Day4) > 1 ) or isnumeric(@Day4) =1 
	--				begin
						
	--					if charindex('-',@Day4,0) > 0 
	--						set @shift_Type =1
	--					else
	--						set @shift_Type =0
	--					set @Day4 = replace(@Day4,'-','')
	--					if isnumeric(@Day4) =1 
	--						begin
	--							if exists(Select Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day4)
	--								begin
	--									Select @Shift_ID = Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day4
	--									select @Shift_Tran_ID = isnull(max(Shift_Tran_ID),0) + 1 from T0100_EMP_SHIFT_DETAIL
	--									select  @For_Date = dateadd(d,3,dbo.GET_MONTH_ST_DATE(@month,@Year))
										
	--									INSERT INTO T0100_EMP_SHIFT_DETAIL
	--									                            (Shift_Tran_ID, Emp_ID, Cmp_ID, Shift_ID, For_Date, Shift_Type)
	--									VALUES     (@Shift_Tran_ID, @Emp_ID, @Cmp_ID, @Shift_ID, @For_Date, @Shift_Type)
	--								end
	--						end
	--				end
					
	--			if ( charindex('-',@Day5,0) > 0 and len(@Day5) > 1 ) or isnumeric(@Day5) =1 
	--				begin
						
	--					if charindex('-',@Day5,0) > 0 
	--						set @shift_Type =1
	--					else
	--						set @shift_Type =0
	--					set @Day5 = replace(@Day5,'-','')
	--					if isnumeric(@Day5) =1 
	--						begin
	--							if exists(Select Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day5)
	--								begin
	--									Select @Shift_ID = Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day5
	--									select @Shift_Tran_ID = isnull(max(Shift_Tran_ID),0) + 1 from T0100_EMP_SHIFT_DETAIL
	--									select  @For_Date = dateadd(d,4,dbo.GET_MONTH_ST_DATE(@month,@Year))
										
	--									INSERT INTO T0100_EMP_SHIFT_DETAIL
	--									                            (Shift_Tran_ID, Emp_ID, Cmp_ID, Shift_ID, For_Date, Shift_Type)
	--									VALUES     (@Shift_Tran_ID, @Emp_ID, @Cmp_ID, @Shift_ID, @For_Date, @Shift_Type)
	--								end
	--						end
	--				end

	--			if ( charindex('-',@Day6,0) > 0 and len(@Day6) > 1 ) or isnumeric(@Day6) =1 
	--				begin
						
	--					if charindex('-',@Day6,0) > 0 
	--						set @shift_Type =1
	--					else
	--						set @shift_Type =0
	--					set @Day6 = replace(@Day6,'-','')
	--					if isnumeric(@Day6) =1 
	--						begin
	--							if exists(Select Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day6)
	--								begin
	--									Select @Shift_ID = Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day6
	--									select @Shift_Tran_ID = isnull(max(Shift_Tran_ID),0) + 1 from T0100_EMP_SHIFT_DETAIL
	--									select  @For_Date = dateadd(d,5,dbo.GET_MONTH_ST_DATE(@month,@Year))
										
	--									INSERT INTO T0100_EMP_SHIFT_DETAIL
	--									                            (Shift_Tran_ID, Emp_ID, Cmp_ID, Shift_ID, For_Date, Shift_Type)
	--									VALUES     (@Shift_Tran_ID, @Emp_ID, @Cmp_ID, @Shift_ID, @For_Date, @Shift_Type)
	--								end
	--						end
	--				end
										
														
	--			if ( charindex('-',@Day7,0) > 0 and len(@Day7) > 1 ) or isnumeric(@Day7) =1 
	--				begin
						
	--					if charindex('-',@Day7,0) > 0 
	--						set @shift_Type =1
	--					else
	--						set @shift_Type =0
	--					set @Day7 = replace(@Day7,'-','')
	--					if isnumeric(@Day7) =1 
	--						begin
	--							if exists(Select Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day7)
	--								begin
	--									Select @Shift_ID = Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day7
	--									select @Shift_Tran_ID = isnull(max(Shift_Tran_ID),0) + 1 from T0100_EMP_SHIFT_DETAIL
	--									select  @For_Date = dateadd(d,6,dbo.GET_MONTH_ST_DATE(@month,@Year))
										
	--									INSERT INTO T0100_EMP_SHIFT_DETAIL
	--									                            (Shift_Tran_ID, Emp_ID, Cmp_ID, Shift_ID, For_Date, Shift_Type)
	--									VALUES     (@Shift_Tran_ID, @Emp_ID, @Cmp_ID, @Shift_ID, @For_Date, @Shift_Type)
	--								end
	--						end
	--				end
					
	--			if ( charindex('-',@Day8,0) > 0 and len(@Day8) > 1 ) or isnumeric(@Day8) =1 
	--				begin
						
	--					if charindex('-',@Day8,0) > 0 
	--						set @shift_Type =1
	--					else
	--						set @shift_Type =0
	--					set @Day8 = replace(@Day8,'-','')
	--					if isnumeric(@Day8) =1 
	--						begin
	--							if exists(Select Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day8)
	--								begin
	--									Select @Shift_ID = Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day8
	--									select @Shift_Tran_ID = isnull(max(Shift_Tran_ID),0) + 1 from T0100_EMP_SHIFT_DETAIL
	--									select  @For_Date = dateadd(d,7,dbo.GET_MONTH_ST_DATE(@month,@Year))
										
	--									INSERT INTO T0100_EMP_SHIFT_DETAIL
	--									                            (Shift_Tran_ID, Emp_ID, Cmp_ID, Shift_ID, For_Date, Shift_Type)
	--									VALUES     (@Shift_Tran_ID, @Emp_ID, @Cmp_ID, @Shift_ID, @For_Date, @Shift_Type)
	--								end
	--						end
	--				end					

	--			if ( charindex('-',@Day9,0) > 0 and len(@Day9) > 1 ) or isnumeric(@Day9) =1 
	--				begin
						
	--					if charindex('-',@Day9,0) > 0 
	--						set @shift_Type =1
	--					else
	--						set @shift_Type =0
	--					set @Day9 = replace(@Day9,'-','')
	--					if isnumeric(@Day9) =1 
	--						begin
	--							if exists(Select Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day9)
	--								begin
	--									Select @Shift_ID = Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day9
	--									select @Shift_Tran_ID = isnull(max(Shift_Tran_ID),0) + 1 from T0100_EMP_SHIFT_DETAIL
	--									select  @For_Date = dateadd(d,8,dbo.GET_MONTH_ST_DATE(@month,@Year))
										
	--									INSERT INTO T0100_EMP_SHIFT_DETAIL
	--									                            (Shift_Tran_ID, Emp_ID, Cmp_ID, Shift_ID, For_Date, Shift_Type)
	--									VALUES     (@Shift_Tran_ID, @Emp_ID, @Cmp_ID, @Shift_ID, @For_Date, @Shift_Type)
	--								end
	--						end
	--				end
				
	--			if ( charindex('-',@Day10,0) > 0 and len(@Day10) > 1 ) or isnumeric(@Day10) =1 
	--				begin
						
	--					if charindex('-',@Day10,0) > 0 
	--						set @shift_Type =1
	--					else
	--						set @shift_Type =0
	--					set @Day10 = replace(@Day10,'-','')
	--					if isnumeric(@Day10) =1 
	--						begin
	--							if exists(Select Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day10)
	--								begin
	--									Select @Shift_ID = Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day10
	--									select @Shift_Tran_ID = isnull(max(Shift_Tran_ID),0) + 1 from T0100_EMP_SHIFT_DETAIL
	--									select  @For_Date = dateadd(d,9,dbo.GET_MONTH_ST_DATE(@month,@Year))
										
	--									INSERT INTO T0100_EMP_SHIFT_DETAIL
	--									                            (Shift_Tran_ID, Emp_ID, Cmp_ID, Shift_ID, For_Date, Shift_Type)
	--									VALUES     (@Shift_Tran_ID, @Emp_ID, @Cmp_ID, @Shift_ID, @For_Date, @Shift_Type)
	--								end
	--						end
	--				end
					
	--			if ( charindex('-',@Day11,0) > 0 and len(@Day11) > 1 ) or isnumeric(@Day11) =1 
	--				begin
						
	--					if charindex('-',@Day11,0) > 0 
	--						set @shift_Type =1
	--					else
	--						set @shift_Type =0
	--					set @Day11 = replace(@Day11,'-','')
	--					if isnumeric(@Day11) =1 
	--						begin
	--							if exists(Select Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day11)
	--								begin
	--									Select @Shift_ID = Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day11
	--									select @Shift_Tran_ID = isnull(max(Shift_Tran_ID),0) + 1 from T0100_EMP_SHIFT_DETAIL
	--									select  @For_Date = dateadd(d,10,dbo.GET_MONTH_ST_DATE(@month,@Year))
										
	--									INSERT INTO T0100_EMP_SHIFT_DETAIL
	--									                            (Shift_Tran_ID, Emp_ID, Cmp_ID, Shift_ID, For_Date, Shift_Type)
	--									VALUES     (@Shift_Tran_ID, @Emp_ID, @Cmp_ID, @Shift_ID, @For_Date, @Shift_Type)
	--								end
	--						end
	--				end

	--			if ( charindex('-',@Day12,0) > 0 and len(@Day12) > 1 ) or isnumeric(@Day12) =1 
	--				begin
						
	--					if charindex('-',@Day12,0) > 0 
	--						set @shift_Type =1
	--					else
	--						set @shift_Type =0
	--					set @Day12 = replace(@Day12,'-','')
	--					if isnumeric(@Day12) =1 
	--						begin
	--							if exists(Select Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day12)
	--								begin
	--									Select @Shift_ID = Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day12
	--									select @Shift_Tran_ID = isnull(max(Shift_Tran_ID),0) + 1 from T0100_EMP_SHIFT_DETAIL
	--									select  @For_Date = dateadd(d,11,dbo.GET_MONTH_ST_DATE(@month,@Year))
										
	--									INSERT INTO T0100_EMP_SHIFT_DETAIL
	--									                            (Shift_Tran_ID, Emp_ID, Cmp_ID, Shift_ID, For_Date, Shift_Type)
	--									VALUES     (@Shift_Tran_ID, @Emp_ID, @Cmp_ID, @Shift_ID, @For_Date, @Shift_Type)
	--								end
	--						end
	--				end

	--			if ( charindex('-',@Day13,0) > 0 and len(@Day13) > 1 ) or isnumeric(@Day13) =1 
	--				begin
						
	--					if charindex('-',@Day13,0) > 0 
	--						set @shift_Type =1
	--					else
	--						set @shift_Type =0
	--					set @Day13 = replace(@Day13,'-','')
	--					if isnumeric(@Day13) =1 
	--						begin
	--							if exists(Select Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day13)
	--								begin
	--									Select @Shift_ID = Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day13
	--									select @Shift_Tran_ID = isnull(max(Shift_Tran_ID),0) + 1 from T0100_EMP_SHIFT_DETAIL
	--									select  @For_Date = dateadd(d,12,dbo.GET_MONTH_ST_DATE(@month,@Year))
										
	--									INSERT INTO T0100_EMP_SHIFT_DETAIL
	--									                            (Shift_Tran_ID, Emp_ID, Cmp_ID, Shift_ID, For_Date, Shift_Type)
	--									VALUES     (@Shift_Tran_ID, @Emp_ID, @Cmp_ID, @Shift_ID, @For_Date, @Shift_Type)
	--								end
	--						end
	--				end

	--			if ( charindex('-',@Day14,0) > 0 and len(@Day14) > 1 ) or isnumeric(@Day14) =1 
	--				begin
						
	--					if charindex('-',@Day14,0) > 0 
	--						set @shift_Type =1
	--					else
	--						set @shift_Type =0
	--					set @Day14 = replace(@Day14,'-','')
	--					if isnumeric(@Day14) =1 
	--						begin
	--							if exists(Select Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day14)
	--								begin
	--									Select @Shift_ID = Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day14
	--									select @Shift_Tran_ID = isnull(max(Shift_Tran_ID),0) + 1 from T0100_EMP_SHIFT_DETAIL
	--									select  @For_Date = dateadd(d,13,dbo.GET_MONTH_ST_DATE(@month,@Year))
										
	--									INSERT INTO T0100_EMP_SHIFT_DETAIL
	--									                            (Shift_Tran_ID, Emp_ID, Cmp_ID, Shift_ID, For_Date, Shift_Type)
	--									VALUES     (@Shift_Tran_ID, @Emp_ID, @Cmp_ID, @Shift_ID, @For_Date, @Shift_Type)
	--								end
	--						end
	--				end

			
					
	--			if ( charindex('-',@Day15,0) > 0 and len(@Day15) > 1 ) or isnumeric(@Day15) =1 
	--				begin
						
	--					if charindex('-',@Day15,0) > 0 
	--						set @shift_Type =1
	--					else
	--						set @shift_Type =0
	--					set @Day15 = replace(@Day15,'-','')
	--					if isnumeric(@Day15) =1 
	--						begin
	--							if exists(Select Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day15)
	--								begin
	--									Select @Shift_ID = Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day15
	--									select @Shift_Tran_ID = isnull(max(Shift_Tran_ID),0) + 1 from T0100_EMP_SHIFT_DETAIL
	--									select  @For_Date = dateadd(d,14,dbo.GET_MONTH_ST_DATE(@month,@Year))
										
	--									INSERT INTO T0100_EMP_SHIFT_DETAIL
	--									                            (Shift_Tran_ID, Emp_ID, Cmp_ID, Shift_ID, For_Date, Shift_Type)
	--									VALUES     (@Shift_Tran_ID, @Emp_ID, @Cmp_ID, @Shift_ID, @For_Date, @Shift_Type)
	--								end
	--						end
	--				end

	--			if ( charindex('-',@Day16,0) > 0 and len(@Day16) > 1 ) or isnumeric(@Day16) =1 
	--				begin
						
	--					if charindex('-',@Day16,0) > 0 
	--						set @shift_Type =1
	--					else
	--						set @shift_Type =0
	--					set @Day16 = replace(@Day16,'-','')
	--					if isnumeric(@Day16) =1 
	--						begin
	--							if exists(Select Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day16)
	--								begin
	--									Select @Shift_ID = Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day16
	--									select @Shift_Tran_ID = isnull(max(Shift_Tran_ID),0) + 1 from T0100_EMP_SHIFT_DETAIL
	--									select  @For_Date = dateadd(d,15,dbo.GET_MONTH_ST_DATE(@month,@Year))
										
	--									INSERT INTO T0100_EMP_SHIFT_DETAIL
	--									                            (Shift_Tran_ID, Emp_ID, Cmp_ID, Shift_ID, For_Date, Shift_Type)
	--									VALUES     (@Shift_Tran_ID, @Emp_ID, @Cmp_ID, @Shift_ID, @For_Date, @Shift_Type)
	--								end
	--						end
	--				end
					
	--			if ( charindex('-',@Day17,0) > 0 and len(@Day17) > 1 ) or isnumeric(@Day17) =1 
	--				begin
						
	--					if charindex('-',@Day17,0) > 0 
	--						set @shift_Type =1
	--					else
	--						set @shift_Type =0
	--					set @Day17 = replace(@Day17,'-','')
	--					if isnumeric(@Day17) =1 
	--						begin
	--							if exists(Select Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day17)
	--								begin
	--									Select @Shift_ID = Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day17
	--									select @Shift_Tran_ID = isnull(max(Shift_Tran_ID),0) + 1 from T0100_EMP_SHIFT_DETAIL
	--									select  @For_Date = dateadd(d,16,dbo.GET_MONTH_ST_DATE(@month,@Year))
										
	--									INSERT INTO T0100_EMP_SHIFT_DETAIL
	--									                            (Shift_Tran_ID, Emp_ID, Cmp_ID, Shift_ID, For_Date, Shift_Type)
	--									VALUES     (@Shift_Tran_ID, @Emp_ID, @Cmp_ID, @Shift_ID, @For_Date, @Shift_Type)
	--								end
	--						end
	--				end
																																													
	--			if ( charindex('-',@Day18,0) > 0 and len(@Day18) > 1 ) or isnumeric(@Day18) =1 
	--				begin
						
	--					if charindex('-',@Day18,0) > 0 
	--						set @shift_Type =1
	--					else
	--						set @shift_Type =0
	--					set @Day18 = replace(@Day18,'-','')
						
	--					if isnumeric(@Day18) =1 
	--						begin
	--							if exists(Select Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day18)
	--								begin
	--									Select @Shift_ID = Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day18
	--									select @Shift_Tran_ID = isnull(max(Shift_Tran_ID),0) + 1 from T0100_EMP_SHIFT_DETAIL
	--									select  @For_Date = dateadd(d,17,dbo.GET_MONTH_ST_DATE(@month,@Year))
										
	--									INSERT INTO T0100_EMP_SHIFT_DETAIL
	--									                            (Shift_Tran_ID, Emp_ID, Cmp_ID, Shift_ID, For_Date, Shift_Type)
	--									VALUES     (@Shift_Tran_ID, @Emp_ID, @Cmp_ID, @Shift_ID, @For_Date, @Shift_Type)
	--								end
	--						end
	--				end
	
	
	--				if ( charindex('-',@Day19,0) > 0 and len(@Day19) > 1 ) or isnumeric(@Day19) =1 
	--				begin
						
	--					if charindex('-',@Day19,0) > 0 
	--						set @shift_Type =1
	--					else
	--						set @shift_Type =0
	--					set @Day19 = replace(@Day19,'-','')
	--					if isnumeric(@Day19) =1 
	--						begin
	--							if exists(Select Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day19)
	--								begin
	--									Select @Shift_ID = Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day19
	--									select @Shift_Tran_ID = isnull(max(Shift_Tran_ID),0) + 1 from T0100_EMP_SHIFT_DETAIL
	--									select  @For_Date = dateadd(d,18,dbo.GET_MONTH_ST_DATE(@month,@Year))
										
	--									INSERT INTO T0100_EMP_SHIFT_DETAIL
	--									                            (Shift_Tran_ID, Emp_ID, Cmp_ID, Shift_ID, For_Date, Shift_Type)
	--									VALUES     (@Shift_Tran_ID, @Emp_ID, @Cmp_ID, @Shift_ID, @For_Date, @Shift_Type)
	--								end
	--						end
	--				end
	
	--				if ( charindex('-',@Day20,0) > 0 and len(@Day20) > 1 ) or isnumeric(@Day20) =1 
	--				begin
						
	--					if charindex('-',@Day20,0) > 0 
	--						set @shift_Type =1
	--					else
	--						set @shift_Type =0
	--					set @Day20 = replace(@Day20,'-','')
						
	--					if isnumeric(@Day20) =1 
	--						begin
	--							if exists(Select Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day20)
	--								begin
	--									Select @Shift_ID = Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day20
	--									select @Shift_Tran_ID = isnull(max(Shift_Tran_ID),0) + 1 from T0100_EMP_SHIFT_DETAIL
	--									select  @For_Date = dateadd(d,19,dbo.GET_MONTH_ST_DATE(@month,@Year))
										
	--									INSERT INTO T0100_EMP_SHIFT_DETAIL
	--									                            (Shift_Tran_ID, Emp_ID, Cmp_ID, Shift_ID, For_Date, Shift_Type)
	--									VALUES     (@Shift_Tran_ID, @Emp_ID, @Cmp_ID, @Shift_ID, @For_Date, @Shift_Type)
	--								end
	--						end
	--				end
	
	
	--				if ( charindex('-',@Day21,0) > 0 and len(@Day21) > 1 ) or isnumeric(@Day21) =1 
	--				begin
						
	--					if charindex('-',@Day21,0) > 0 
	--						set @shift_Type =1
	--					else
	--						set @shift_Type =0
	--					set @Day21 = replace(@Day21,'-','')
	--					if isnumeric(@Day21) =1 
	--						begin
	--							if exists(Select Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day21)
	--								begin
	--									Select @Shift_ID = Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day21
	--									select @Shift_Tran_ID = isnull(max(Shift_Tran_ID),0) + 1 from T0100_EMP_SHIFT_DETAIL
	--									select  @For_Date = dateadd(d,20,dbo.GET_MONTH_ST_DATE(@month,@Year))
										
	--									INSERT INTO T0100_EMP_SHIFT_DETAIL
	--									                            (Shift_Tran_ID, Emp_ID, Cmp_ID, Shift_ID, For_Date, Shift_Type)
	--									VALUES     (@Shift_Tran_ID, @Emp_ID, @Cmp_ID, @Shift_ID, @For_Date, @Shift_Type)
	--								end
	--						end
	--				end
	
	--				if ( charindex('-',@Day22,0) > 0 and len(@Day22) > 1 ) or isnumeric(@Day22) =1 
	--				begin
						
	--					if charindex('-',@Day22,0) > 0 
	--						set @shift_Type =1
	--					else
	--						set @shift_Type =0
	--					set @Day22 = replace(@Day22,'-','')
	--					if isnumeric(@Day22) =1 
	--						begin
	--							if exists(Select Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day22)
	--								begin
	--									Select @Shift_ID = Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day22
	--									select @Shift_Tran_ID = isnull(max(Shift_Tran_ID),0) + 1 from T0100_EMP_SHIFT_DETAIL
	--									select  @For_Date = dateadd(d,21,dbo.GET_MONTH_ST_DATE(@month,@Year))
										
	--									INSERT INTO T0100_EMP_SHIFT_DETAIL
	--									                            (Shift_Tran_ID, Emp_ID, Cmp_ID, Shift_ID, For_Date, Shift_Type)
	--									VALUES     (@Shift_Tran_ID, @Emp_ID, @Cmp_ID, @Shift_ID, @For_Date, @Shift_Type)
	--								end
	--						end
	--				end
	
	--				if ( charindex('-',@Day23,0) > 0 and len(@Day23) > 1 ) or isnumeric(@Day23) =1 
	--				begin
						
	--					if charindex('-',@Day23,0) > 0 
	--						set @shift_Type =1
	--					else
	--						set @shift_Type =0
	--					set @Day23 = replace(@Day23,'-','')
	--					if isnumeric(@Day23) =1 
	--						begin
	--							if exists(Select Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day23)
	--								begin
	--									Select @Shift_ID = Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day23
	--									select @Shift_Tran_ID = isnull(max(Shift_Tran_ID),0) + 1 from T0100_EMP_SHIFT_DETAIL
	--									select  @For_Date = dateadd(d,22,dbo.GET_MONTH_ST_DATE(@month,@Year))
										
	--									INSERT INTO T0100_EMP_SHIFT_DETAIL
	--									                            (Shift_Tran_ID, Emp_ID, Cmp_ID, Shift_ID, For_Date, Shift_Type)
	--									VALUES     (@Shift_Tran_ID, @Emp_ID, @Cmp_ID, @Shift_ID, @For_Date, @Shift_Type)
	--								end
	--						end
	--				end
	
	--				if ( charindex('-',@Day24,0) > 0 and len(@Day24) > 1 ) or isnumeric(@Day24) =1 
	--				begin
						
	--					if charindex('-',@Day24,0) > 0 
	--						set @shift_Type =1
	--					else
	--						set @shift_Type =0
	--					set @Day24 = replace(@Day24,'-','')
	--					if isnumeric(@Day24) =1 
	--						begin
	--							if exists(Select Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day24)
	--								begin
	--									Select @Shift_ID = Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day24
	--									select @Shift_Tran_ID = isnull(max(Shift_Tran_ID),0) + 1 from T0100_EMP_SHIFT_DETAIL
	--									select  @For_Date = dateadd(d,23,dbo.GET_MONTH_ST_DATE(@month,@Year))
										
	--									INSERT INTO T0100_EMP_SHIFT_DETAIL
	--									                            (Shift_Tran_ID, Emp_ID, Cmp_ID, Shift_ID, For_Date, Shift_Type)
	--									VALUES     (@Shift_Tran_ID, @Emp_ID, @Cmp_ID, @Shift_ID, @For_Date, @Shift_Type)
	--								end
	--						end
	--				end
	
	--				if ( charindex('-',@Day25,0) > 0 and len(@Day25) > 1 ) or isnumeric(@Day25) =1 
	--				begin
						
	--					if charindex('-',@Day25,0) > 0 
	--						set @shift_Type =1
	--					else
	--						set @shift_Type =0
	--					set @Day25 = replace(@Day25,'-','')
	--					if isnumeric(@Day25) =1 
	--						begin
	--							if exists(Select Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day25)
	--								begin
	--									Select @Shift_ID = Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day25
	--									select @Shift_Tran_ID = isnull(max(Shift_Tran_ID),0) + 1 from T0100_EMP_SHIFT_DETAIL
	--									select  @For_Date = dateadd(d,24,dbo.GET_MONTH_ST_DATE(@month,@Year))
										
	--									INSERT INTO T0100_EMP_SHIFT_DETAIL
	--									                            (Shift_Tran_ID, Emp_ID, Cmp_ID, Shift_ID, For_Date, Shift_Type)
	--									VALUES     (@Shift_Tran_ID, @Emp_ID, @Cmp_ID, @Shift_ID, @For_Date, @Shift_Type)
	--								end
	--						end
	--				end
	--			if ( charindex('-',@Day26,0) > 0 and len(@Day26) > 1 ) or isnumeric(@Day26) =1 
	--				begin
						
	--					if charindex('-',@Day26,0) > 0 
	--						set @shift_Type =1
	--					else
	--						set @shift_Type =0
	--					set @Day26 = replace(@Day26,'-','')
	--					if isnumeric(@Day26) =1 
	--						begin
	--							if exists(Select Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day26)
	--								begin
	--									Select @Shift_ID = Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day26
	--									select @Shift_Tran_ID = isnull(max(Shift_Tran_ID),0) + 1 from T0100_EMP_SHIFT_DETAIL
	--									select  @For_Date = dateadd(d,25,dbo.GET_MONTH_ST_DATE(@month,@Year))
										
	--									INSERT INTO T0100_EMP_SHIFT_DETAIL
	--									                            (Shift_Tran_ID, Emp_ID, Cmp_ID, Shift_ID, For_Date, Shift_Type)
	--									VALUES     (@Shift_Tran_ID, @Emp_ID, @Cmp_ID, @Shift_ID, @For_Date, @Shift_Type)
	--								end
	--						end
	--				end

	--			if ( charindex('-',@Day27,0) > 0 and len(@Day27) > 1 ) or isnumeric(@Day27) =1 
	--				begin
						
	--					if charindex('-',@Day27,0) > 0 
	--						set @shift_Type =1
	--					else
	--						set @shift_Type =0
	--					set @Day27 = replace(@Day27,'-','')
	--					if isnumeric(@Day27) =1 
	--						begin
	--							if exists(Select Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day27)
	--								begin
	--									Select @Shift_ID = Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day27
	--									select @Shift_Tran_ID = isnull(max(Shift_Tran_ID),0) + 1 from T0100_EMP_SHIFT_DETAIL
	--									select  @For_Date = dateadd(d,26,dbo.GET_MONTH_ST_DATE(@month,@Year))
										
	--									INSERT INTO T0100_EMP_SHIFT_DETAIL
	--									                            (Shift_Tran_ID, Emp_ID, Cmp_ID, Shift_ID, For_Date, Shift_Type)
	--									VALUES     (@Shift_Tran_ID, @Emp_ID, @Cmp_ID, @Shift_ID, @For_Date, @Shift_Type)
	--								end
	--						end
	--				end
	--				if ( charindex('-',@Day28,0) > 0 and len(@Day28) > 1 ) or isnumeric(@Day28) =1 
	--				begin
						
	--					if charindex('-',@Day28,0) > 0 
	--						set @shift_Type =1
	--					else
	--						set @shift_Type =0
	--					set @Day28 = replace(@Day28,'-','')
	--					if isnumeric(@Day28) =1 
	--						begin
	--							if exists(Select Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day28)
	--								begin
	--									Select @Shift_ID = Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day28
	--									select @Shift_Tran_ID = isnull(max(Shift_Tran_ID),0) + 1 from T0100_EMP_SHIFT_DETAIL
	--									select  @For_Date = dateadd(d,27,dbo.GET_MONTH_ST_DATE(@month,@Year))
										
	--									INSERT INTO T0100_EMP_SHIFT_DETAIL
	--									                            (Shift_Tran_ID, Emp_ID, Cmp_ID, Shift_ID, For_Date, Shift_Type)
	--									VALUES     (@Shift_Tran_ID, @Emp_ID, @Cmp_ID, @Shift_ID, @For_Date, @Shift_Type)
	--								end
	--						end
	--				end
	--				if ( charindex('-',@Day29,0) > 0 and len(@Day29) > 1 ) or isnumeric(@Day29) =1 
	--				begin
						
	--					if charindex('-',@Day29,0) > 0 
	--						set @shift_Type =1
	--					else
	--						set @shift_Type =0
	--					set @Day29 = replace(@Day29,'-','')
	--					if isnumeric(@Day29) =1 
	--						begin
	--							if exists(Select Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day29)
	--								begin
	--									Select @Shift_ID = Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day29
	--									select @Shift_Tran_ID = isnull(max(Shift_Tran_ID),0) + 1 from T0100_EMP_SHIFT_DETAIL
	--									select  @For_Date = dateadd(d,28,dbo.GET_MONTH_ST_DATE(@month,@Year))
										
	--									INSERT INTO T0100_EMP_SHIFT_DETAIL
	--									                            (Shift_Tran_ID, Emp_ID, Cmp_ID, Shift_ID, For_Date, Shift_Type)
	--									VALUES     (@Shift_Tran_ID, @Emp_ID, @Cmp_ID, @Shift_ID, @For_Date, @Shift_Type)
	--								end
	--						end
	--				end
	--				if ( charindex('-',@Day30,0) > 0 and len(@Day30) > 1 ) or isnumeric(@Day30) =1 
	--				begin
						
	--					if charindex('-',@Day30,0) > 0 
	--						set @shift_Type =1
	--					else
	--						set @shift_Type =0
	--					set @Day30 = replace(@Day30,'-','')
	--					if isnumeric(@Day30) =1 
	--						begin
	--							if exists(Select Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day30)
	--								begin
	--									Select @Shift_ID = Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day30
	--									select @Shift_Tran_ID = isnull(max(Shift_Tran_ID),0) + 1 from T0100_EMP_SHIFT_DETAIL
	--									select  @For_Date = dateadd(d,29,dbo.GET_MONTH_ST_DATE(@month,@Year))
										
	--									INSERT INTO T0100_EMP_SHIFT_DETAIL
	--									                            (Shift_Tran_ID, Emp_ID, Cmp_ID, Shift_ID, For_Date, Shift_Type)
	--									VALUES     (@Shift_Tran_ID, @Emp_ID, @Cmp_ID, @Shift_ID, @For_Date, @Shift_Type)
	--								end
	--						end
	--				end
	--				if ( charindex('-',@Day31,0) > 0 and len(@Day31) > 1 ) or isnumeric(@Day31) =1 
	--				begin
						
	--					if charindex('-',@Day31,0) > 0 
	--						set @shift_Type =1
	--					else
	--						set @shift_Type =0
	--					set @Day31 = replace(@Day31,'-','')
	--					if isnumeric(@Day31) =1 
	--						begin
	--							if exists(Select Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day31)
	--								begin
	--									Select @Shift_ID = Shift_ID from T0040_Shift_Master where cmp_ID=@Cmp_ID and Shift_ID=@Day31
	--									select @Shift_Tran_ID = isnull(max(Shift_Tran_ID),0) + 1 from T0100_EMP_SHIFT_DETAIL
	--									select  @For_Date = dateadd(d,30,dbo.GET_MONTH_ST_DATE(@month,@Year))
										
	--									INSERT INTO T0100_EMP_SHIFT_DETAIL
	--									                            (Shift_Tran_ID, Emp_ID, Cmp_ID, Shift_ID, For_Date, Shift_Type)
	--									VALUES     (@Shift_Tran_ID, @Emp_ID, @Cmp_ID, @Shift_ID, @For_Date, @Shift_Type)
	--								end
	--						end
	--				end
				
	--			ABC:  -- Added by rohit on 20102015
				
	--			Fetch next from cur_Shift into @Cmp_Id,@Emp_ID,@Emp_Code,@Month,@Year ,@Day1,@Day2,@Day3,@Day4,@Day5,@Day6,@Day7,@Day8,@Day9,@Day10
	--									  ,@Day11,@Day12,@Day13,@Day14,@Day15,@Day16,@Day17,@Day18,@Day19,@Day20
	--									  ,@Day21,@Day22,@Day23,@Day24,@Day25,@Day26,@Day27,@Day28,@Day29,@Day30,@Day31			
				
	--	end
	--close cur_shift
	--deallocate cur_Shift
	
		
	RETURN




