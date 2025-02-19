
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_EMP_PENDING_OVERTIME_REMINDER]
	@CMP_ID		NUMERIC
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	DECLARE @CONSTRAINT VARCHAR(MAX)
	DECLARE @FROM_DATE	DATETIME
	DECLARE @TO_DATE	DATETIME	

	DECLARE @EMP_ID		NUMERIC
	DECLARE @R_EMP_ID	NUMERIC


	SET	@FROM_DATE	= CONVERT(DATETIME,(CONVERT(VARCHAR(4),YEAR(GETDATE())) + '-' + CONVERT(VARCHAR(4),(MONTH(GETDATE()) -2)) + '-' + '01')) 	
	SET	@TO_DATE	= GETDATE()
	
	

	DECLARE @EMAIL_PROFILE	VARCHAR(128)

	SELECT	TOP 1 @EMAIL_PROFILE = IsNull(DB_Mail_Profile_Name,'') 
	FROM	t9999_Reminder_Mail_Profile WITH (NOLOCK)
	WHERE	cmp_id = IsNull(@CMP_ID,cmp_id)
						
	IF IsNull(@EMAIL_PROFILE,'') = ''
		SELECT	@EMAIL_PROFILE = isnull(DB_Mail_Profile_Name,'')
		FROM	t9999_Reminder_Mail_Profile WITH (NOLOCK)
		WHERE	cmp_id = 0
			            
	IF IsNull(@EMAIL_PROFILE,'') = ''
		BEGIN
			RAISERROR('@@Email Profile is not created@@',16,2)
			RETURN 
		END

		
	--CREATE TABLE #EMP_CONS 
	--(      
	--	EMP_ID NUMERIC ,     
	--	BRANCH_ID NUMERIC,
	--	INCREMENT_ID NUMERIC    
	--)  

	--EXEC SP_RPT_FILL_EMP_CONS  @CMP_ID,@FROM_DATE,@TO_DATE,0,0,0,0,0,0,0,'',0 ,0 ,0,0,0,0,0,0,0,0,0,0
	
	--SELECT	@CONSTRAINT=COALESCE(@CONSTRAINT + '#','') + CAST(EMP_ID AS VARCHAR(10))
	--FROM	#EMP_CONS E  	
	
	
	
	CREATE TABLE #PENDING_OVERTIME
		(
			 Tran_Id				NUMERIC(18,0) IDENTITY
			,Cmp_ID					NUMERIC(18,0)
			,Emp_ID					NUMERIC(18,0)								
			,Alpha_Emp_code			NVARCHAR(100)
			,For_DATE				DATETIME								
			,Emp_Full_Name			NVARCHAR(200)
			,Working_Hour			VARCHAR(10)
			,OT_Hour				VARCHAR(10)			
			,Weekoff_OT_Hour		VARCHAR(10)
			,Holiday_OT_Hour		VARCHAR(10)
										
		)
		
	--EXEC SP_Get_OT_Level_Approval_Records @Cmp_ID=@Cmp_ID,@Emp_ID=0,@R_Emp_ID = 13960,@From_Date = @FROM_DATE,
	--									  @To_Date = @TO_DATE,@Rpt_level=0,@Return_Record_set = 4,
	--									  @Constraint = N'1=1 and status = ''P''',@Type = 2,@DEPT_Id =0,@GRD_Id = 0					  
		
			
	
	If OBJECT_ID('TEMPDB..#DBO.#PENDING_OVERTIME_RECORD') IS NOT NULL
		DROP TABLE #PENDING_OVERTIME_RECORD
	
		CREATE TABLE #PENDING_OVERTIME_RECORD
			(
				Cmp_ID				NUMERIC(18,0),
				Emp_ID				NUMERIC(18,0),								
				Alpha_Emp_code		NVARCHAR(100),
				For_DATE			DATETIME,
				Emp_Full_Name		NVARCHAR(200),
				COLUMN_NAME			VARCHAR(10),		
				COLUMN_VALUE		VARCHAR(10)						
			)
	
	
							
	CREATE TABLE #EMP_DATA 
	(
		EMP_ID		NUMERIC,
		R_EMP_ID	NUMERIC
	)

	INSERT	INTO #EMP_DATA
	SELECT	R.EMP_ID, R.R_EMP_ID
	FROM	T0090_EMP_REPORTING_DETAIL R WITH (NOLOCK)
			INNER JOIN (SELECT	R1.EMP_ID, MAX(R1.Row_ID) AS ROW_ID
						FROM	T0090_EMP_REPORTING_DETAIL R1 WITH (NOLOCK)
								INNER JOIN (SELECT	R2.Emp_ID, MAX(R2.Effect_Date) AS Effect_Date
											FROM	T0090_EMP_REPORTING_DETAIL R2 WITH (NOLOCK)
											WHERE	R2.Effect_Date <= @TO_DATE AND
													R2.Cmp_ID = @CMP_Id
											GROUP BY R2.Emp_ID) R2 ON R1.Emp_ID=R2.Emp_ID AND R1.Effect_Date=R2.Effect_Date
						 WHERE 	R1.Cmp_ID = @CMP_Id				
						GROUP BY R1.Emp_ID) R1 ON R.Emp_ID=R1.Emp_ID AND R.Row_ID=R1.ROW_ID						
			--INNER JOIN (SELECT	DISTINCT EMP_ID FROM #PENDING_OVERTIME) A ON R.Emp_ID=A.EMP_ID
	WHERE   R.Cmp_ID = @CMP_Id	and 
			EXISTS (
						select 1 From T0095_EMP_SCHEME ES WITH (NOLOCK) Inner Join
						(	
							select	MAX(Effective_Date) as For_Date, Emp_ID 
							from	T0095_EMP_SCHEME WITH (NOLOCK)
							where	Effective_Date<=GETDATE() And Type = 'Over Time'
							GROUP BY emp_ID									
						) Qry on ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date 
								 And Type = 'Over Time' and Es.Emp_ID = R.Emp_ID
					)

				
	
	If OBJECT_ID('TEMPDB..#DBO.#OVERTIME_PENDING') IS NOT NULL
		DROP TABLE #OVERTIME_PENDING
	
		CREATE TABLE #OVERTIME_PENDING
			(
				Tran_Id				NUMERIC(18,0) IDENTITY,
				Cmp_ID				NUMERIC(18,0),
				Emp_ID				NUMERIC(18,0),								
				Alpha_Emp_code		NVARCHAR(100),
				For_DATE			DATETIME,
				Emp_Full_Name		NVARCHAR(200),
				OT_Hour				VARCHAR(10),
				Weekoff_OT_Hour		VARCHAR(10),
				Holiday_OT_Hour		VARCHAR(10)						
			)
	
	
	
	DECLARE	@HTML	VARCHAR(MAX)
	DECLARE @BODY	VARCHAR(MAX)
	DECLARE @TR1	VARCHAR(MAX)
	DECLARE @TR2	VARCHAR(MAX)
	DECLARE @INDEX	INT

	DECLARE @DISPLAY_NAME	VARCHAR(128)
	DECLARE @SUBJECT		VARCHAR(512)
	DECLARE @TO_EMAIL		VARCHAR(256)

	DECLARE @STYLE_TABLE	VARCHAR(512)
	DECLARE @STYLE_TD		VARCHAR(512)
	DECLARE @STYLE_TH		VARCHAR(512)



	SET @STYLE_TABLE = ' cellpadding="0" cellspacing="0" style="border-color:#b0daff;font-family:Arial;background-color:#edf7fd;font-size:7.5pt;width:100%;##custom;"';
	SET	@STYLE_TD = ' style="border-right:1px solid #b0daff;border-bottom:1px solid #b0daff;padding: 2px;height:20px;##custom"'
	SET	@STYLE_TH = REPLACE(@STYLE_TD, '##custom', 'font-weight:bold;background-color: rgb(190,217,240);')
	SET	@INDEX = 1;
		
	
	
	DECLARE	curManager CURSOR FAST_FORWARD FOR
	SELECT	DISTINCT R_EMP_ID, Emp_Full_Name, Work_Email
	FROM	#EMP_DATA ED INNER JOIN 
			T0080_EMP_MASTER E WITH (NOLOCK) ON E.Emp_ID=ED.R_EMP_ID 
    --WHERE	E.Emp_ID in (13961)
	ORDER BY R_EMP_ID

	OPEN curManager 
	FETCH NEXT FROM curManager INTO @R_EMP_ID, @DISPLAY_NAME, @TO_EMAIL
	WHILE @@FETCH_STATUS = 0
		BEGIN
					
			
			EXEC SP_GET_OT_LEVEL_APPROVAL_RECORDS @CMP_ID=@CMP_ID,@EMP_ID=0,@R_EMP_ID = @R_EMP_ID,@FROM_DATE = @FROM_DATE,
										  @TO_DATE = @TO_DATE,@RPT_LEVEL=0,@RETURN_RECORD_SET = 4,
										  @CONSTRAINT = N'1=1 AND STATUS = ''P''',@TYPE = 2,@DEPT_ID =0,@GRD_ID = 0					  
				
			
			
			INSERT INTO #PENDING_OVERTIME_RECORD(CMP_ID,EMP_ID,ALPHA_EMP_CODE,For_DATE,EMP_FULL_NAME,COLUMN_NAME,COLUMN_VALUE)
			SELECT		CMP_ID,EMP_ID,ALPHA_EMP_CODE,For_DATE,EMP_FULL_NAME,'WD_OT',OT_Hour
			FROM		#PENDING_OVERTIME
			
			INSERT INTO #PENDING_OVERTIME_RECORD(CMP_ID,EMP_ID,ALPHA_EMP_CODE,For_DATE,EMP_FULL_NAME,COLUMN_NAME,COLUMN_VALUE)
			SELECT		CMP_ID,EMP_ID,ALPHA_EMP_CODE,For_DATE,EMP_FULL_NAME,'WO_OT',Weekoff_OT_Hour
			FROM		#PENDING_OVERTIME
			
			
			INSERT INTO #PENDING_OVERTIME_RECORD(CMP_ID,EMP_ID,ALPHA_EMP_CODE,For_DATE,EMP_FULL_NAME,COLUMN_NAME,COLUMN_VALUE)
			SELECT		CMP_ID,EMP_ID,ALPHA_EMP_CODE,For_DATE,EMP_FULL_NAME,'HO_OT',Holiday_OT_Hour
			FROM		#PENDING_OVERTIME
			
			
			
			DECLARE @SQL VARCHAR(MAX)
			DECLARE @COLS VARCHAR(MAX)
			DECLARE @Sr_NO NUMERIC
			
			SET @COLS = NULL
			SET @SQL = ''
			SET @Sr_NO = 1
			
			SELECT	@COLS = COALESCE(@COLS + ',','')  + '[' + COLUMN_NAME + ']'
			FROM	(
						SELECT	DISTINCT COLUMN_NAME
						FROM	#PENDING_OVERTIME_RECORD
					) PL	
			
			
			IF @COLS <> ''
				BEGIN
						SET @SQL = 'INSERT INTO	#OVERTIME_PENDING
									SELECT	*												
									FROM	 
										(								
											SELECT	CMP_ID,EMP_ID,ALPHA_EMP_CODE,For_DATE,EMP_FULL_NAME,
													COLUMN_VALUE,COLUMN_NAME
											FROM	#PENDING_OVERTIME_RECORD P
										) YS 
										PIVOT 
										(
											Max(COLUMN_VALUE) FOR COLUMN_NAME IN (' + @COLS + ')
										) PVT'
				END		
			
			PRINT @SQL
			EXEC(@SQL)		
			
			
			
			SET @BODY = '<table ' + REPLACE(@STYLE_TABLE,'##custom', 'border-width:1px;border-style: solid;')  + '>'
			SET @TR1 = ''
			SET @TR2 = ''
			SET	@EMP_ID = 0;

			
					
			SELECT	@EMP_ID = MIN(EMP_ID),
					@INDEX = MIN(Tran_Id)
			FROM	#OVERTIME_PENDING 
			--WHERE	EMP_ID = @EMP_ID 
			
			
			
			--SELECT @EMP_ID,@INDEX
			
			IF ISNULL(@EMP_ID,0) > 0
				BEGIN 
					SET @TR1 = '<tr>
									<td ' + @STYLE_TH + ' width="30px"	align="center">Sr. No.</td>
									<td ' + @STYLE_TH + ' width="100px" align="center">Code</td>
									<td ' + @STYLE_TH + ' width="160px" align="center">Name</td>
									<td ' + @STYLE_TH + ' width="120px" align="center">For Date</td>
									<td ' + @STYLE_TH + ' width="100px" align="center">OT Hours</td>
									<td ' + @STYLE_TH + ' width="100px" align="center">WeekOff OT Hours</td>
									<td ' + @STYLE_TH + ' width="100px" align="center">Holiday OT Hours</td>'


					--SELECT	@TR1 = @TR1 + '
					--				<td ' + @STYLE_TH + ' align="center">' + RIGHT(CAPTION,2) + '</td>'
						
					--FROM	#PENDING_OVERTIME A
					--WHERE	EMP_ID=@EMP_ID
				
					SET @BODY = @BODY + @TR1 + '
							</tr>'
				END
		
			WHILE ISNULL(@INDEX,0) > 0
				BEGIN 
						
					SET @TR2 = '<tr>'

					SELECT	@TR1 = '<tr>
										<td ' + @STYLE_TD + ' align="center" width="30px">' + CAST(@Sr_NO AS VARCHAR(10)) + '</td>
										<td ' + @STYLE_TD + ' align="center" width="100px">' + Alpha_Emp_Code + '</td>
										<td ' + @STYLE_TD + ' align="center" width="160px">' + Emp_Full_Name + '</td>'
					FROM	T0080_EMP_MASTER WITH (NOLOCK)
					WHERE	Emp_ID=@EMP_ID

					

					SELECT	@TR1 = @TR1 + '
									<td ' + @STYLE_TD + ' align="center">' + Convert(Varchar(20),ISNULL(A.For_DATE,''),103) + '</td>
									<td ' + @STYLE_TD + ' align="center">' + ISNULL(A.OT_Hour,'') + '</td>
									<td ' + @STYLE_TD + ' align="center">' + ISNULL(A.Weekoff_OT_Hour,'') + '</td>
									<td ' + @STYLE_TD + ' align="center">' + ISNULL(A.Holiday_OT_Hour,'') + '</td>'							
					FROM	#OVERTIME_PENDING	A
					WHERE	EMP_ID=@EMP_ID and tran_Id = @INDEX
					
								
					
					SELECT	@EMP_ID = MIN(EMP_ID),
							@INDEX =  MIN(Tran_Id) 
					FROM	#OVERTIME_PENDING 
					WHERE	Tran_Id > @INDEX
					
					

					SET @TR1 = @TR1 + '
								</tr>';	
					
					
					
					SET @BODY = @BODY + @TR1
					SET @Sr_NO = @Sr_NO + 1
					
					
				END

				SET @BODY = @BODY + '
						</table>';

				SET	@HTML = '<table ' + REPLACE(@STYLE_TABLE,'##custom', 'border-width:1px;border-style: solid;padding:10px;') + ' >
								<tr>
									<td>									
										<p <pre style="font-family:arial,sans-serif; font-size: 7.5pt">	Hello ' + @DISPLAY_NAME + ', </p>
	
										Kindly verify Pending Overtime in the following report for your respective Team Members.</p>
									</td>
								</tr>
								<tr>
									<td height="20px"><td>
								</tr>
								<tr>
									<td>
										'  + @BODY + '
									</td>
								</tr>
								<tr>
									<td height="20px"><td>
								</tr>								
							</table>'
				SET	@SUBJECT = 'Attendance Register for Period ' + CONVERT(CHAR(10), @FROM_DATE, 103)  + ' TO ' + CONVERT(CHAR(10), @TO_DATE, 103)

				SET @HTML = REPLACE(@HTML, '##custom','');
				
				
				
				--set @TO_EMAIL = 'noreplyhr@aculife.co.in'
				set @TO_EMAIL = 'jimit@orangewebtech.com'
				SET @EMAIL_PROFILE = 'Acer-7'
				
				
				--if @R_EMP_ID = 1047
					--begin 
						--select @TO_EMAIL
						IF ISNULL(@TO_EMAIL, '') <> ''
							EXEC msdb.dbo.sp_send_dbmail @profile_name = @EMAIL_PROFILE, @recipients = @TO_EMAIL, @subject = @SUBJECT, @body = @HTML, @body_format = 'HTML',@copy_recipients = '',@blind_copy_recipients = ''			
					--end 
					
				DELETE FROM #PENDING_OVERTIME_RECORD	
				DELETE FROM #PENDING_OVERTIME
				DELETE FROM #OVERTIME_PENDING			
				DELETE FROM #PENDING_OVERTIME
				
				--SELECT @BODY
				SET @BODY = ''
				SET @INDEX = 0
				
			FETCH NEXT FROM curManager INTO @R_EMP_ID, @DISPLAY_NAME, @TO_EMAIL
		END


