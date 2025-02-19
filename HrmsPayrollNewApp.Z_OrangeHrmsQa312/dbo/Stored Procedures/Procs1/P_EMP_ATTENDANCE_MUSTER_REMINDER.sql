
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_EMP_ATTENDANCE_MUSTER_REMINDER]
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


	SET	@FROM_DATE	= DATEADD(M, -1, GETDATE())
	SET @FROM_DATE	= CONVERT(DATETIME, CONVERT(CHAR(10), @FROM_DATE, 103), 103);
	SET @FROM_DATE	= DATEADD(D, DAY(@FROM_DATE) * -1, @FROM_DATE) + 1;	
	SET	@TO_DATE	= DATEADD(M, 1, @FROM_DATE) - 1
	
	

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

		

	--SELECT	@CONSTRAINT=COALESCE(@CONSTRAINT + '#','') + CAST(R.EMP_ID AS VARCHAR(10))
	--FROM	T0090_EMP_REPORTING_DETAIL R
	--		INNER JOIN (SELECT	R1.EMP_ID, MAX(R1.Row_ID) AS ROW_ID
	--					FROM	T0090_EMP_REPORTING_DETAIL R1
	--							INNER JOIN (SELECT	R2.Emp_ID, MAX(R2.Effect_Date) AS Effect_Date
	--										FROM	T0090_EMP_REPORTING_DETAIL R2
	--										WHERE	R2.Effect_Date <= @TO_DATE 
	--										GROUP BY R2.Emp_ID) R2 ON R1.Emp_ID=R2.Emp_ID AND R1.Effect_Date=R2.Effect_Date
	--					GROUP BY R1.Emp_ID) R1 ON R.Emp_ID=R1.Emp_ID AND R.Row_ID=R1.ROW_ID
	--					inner join T0080_EMP_MASTER E on R.Emp_ID=E.Emp_id and Isnull(Emp_Left,'N')='N'
	--where	R_Emp_ID=1047 or R.emp_id=1047 --1047 -- 922
	--FROM	T0080_EMP_MASTER E
	--WHERE	Emp_Left_Date IS NULL AND CMP_ID=IsNull(@CMP_ID,CMP_ID)



	CREATE TABLE #EMP_CONS 
	(      
		EMP_ID NUMERIC ,     
		BRANCH_ID NUMERIC,
		INCREMENT_ID NUMERIC    
	)  

	EXEC SP_RPT_FILL_EMP_CONS  @CMP_ID,@FROM_DATE,@TO_DATE,0,0,0,0,0,0,0,'',0 ,0 ,0,0,0,0,0,0,0,0,0,0
	
	SELECT	@CONSTRAINT=COALESCE(@CONSTRAINT + '#','') + CAST(EMP_ID AS VARCHAR(10))
	FROM	#EMP_CONS E  	--where BRANCH_ID<>5   --- Remove Marketing Branch, as per email of Vijaybhai on 01/11/2017
	
	CREATE TABLE #EMP_ATTENDANCE
	(
		EMP_ID		NUMERIC,
		FOR_DATE	DATETIME,
		ROW_ID		NUMERIC,
		CAPTION		VARCHAR(32),
		STATUS1		VARCHAR(8),
		STATUS2		VARCHAR(8),
		R_TYPE		TINYINT
	)

	exec SP_RPT_EMP_ATTENDANCE_MUSTER_GET @Cmp_ID=@CMP_ID,@From_Date=@FROM_DATE,@To_Date=@TO_DATE,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,
	@Desig_ID=0,@Emp_ID=0,@Constraint=@CONSTRAINT,@Report_For='ATT_STATUS',@Type=0	

	

	DECLARE @MAX_ROW_ID INT

	SELECT	@MAX_ROW_ID = MAX(ROW_ID)  FROM (SELECT DISTINCT ROW_ID, FOR_DATE FROM #EMP_ATTENDANCE WHERE R_TYPE=1) T 

	UPDATE	#EMP_ATTENDANCE SET CAPTION = '', STATUS1='', STATUS2='' WHERE ROW_ID < (@MAX_ROW_ID - 7) AND FOR_DATE > @TO_DATE

	UPDATE	#EMP_ATTENDANCE SET CAPTION = 'P', STATUS1=ISNULL(STATUS1,'0.00')	WHERE ROW_ID = @MAX_ROW_ID - 7
	UPDATE	#EMP_ATTENDANCE SET CAPTION = 'A', STATUS1=ISNULL(STATUS1,'0.00')	WHERE ROW_ID = @MAX_ROW_ID - 6
	UPDATE	#EMP_ATTENDANCE SET CAPTION = 'L', STATUS1=ISNULL(STATUS1,'0.00')	WHERE ROW_ID = @MAX_ROW_ID - 5
	UPDATE	#EMP_ATTENDANCE SET CAPTION = 'W', STATUS1=ISNULL(STATUS1,'0.00')	WHERE ROW_ID = @MAX_ROW_ID - 4 
	UPDATE	#EMP_ATTENDANCE SET CAPTION = 'H', STATUS1=ISNULL(STATUS1,'0.00')	WHERE ROW_ID = @MAX_ROW_ID - 3
	UPDATE	#EMP_ATTENDANCE SET CAPTION = 'LC', STATUS1=ISNULL(STATUS1,'0.00')	WHERE ROW_ID = @MAX_ROW_ID - 2
	UPDATE	#EMP_ATTENDANCE SET CAPTION = 'GP', STATUS1=ISNULL(STATUS1,'0.00')	WHERE ROW_ID = @MAX_ROW_ID - 1
	UPDATE	#EMP_ATTENDANCE SET CAPTION = 'PD', STATUS1=ISNULL(STATUS1,'0.00')	WHERE ROW_ID = @MAX_ROW_ID - 0

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
											WHERE	R2.Effect_Date <= @TO_DATE
											GROUP BY R2.Emp_ID) R2 ON R1.Emp_ID=R2.Emp_ID AND R1.Effect_Date=R2.Effect_Date
						GROUP BY R1.Emp_ID) R1 ON R.Emp_ID=R1.Emp_ID AND R.Row_ID=R1.ROW_ID
			INNER JOIN (SELECT	DISTINCT EMP_ID FROM #EMP_ATTENDANCE) A ON R.Emp_ID=A.EMP_ID
	

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
	FROM	#EMP_DATA ED
			INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON E.Emp_ID=ED.R_EMP_ID 
	ORDER BY R_EMP_ID

	OPEN curManager 
	FETCH NEXT FROM curManager INTO @R_EMP_ID, @DISPLAY_NAME, @TO_EMAIL
	WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @BODY = '<table ' + REPLACE(@STYLE_TABLE,'##custom', 'border-width:1px;border-style: solid;')  + '>'
			SET @TR1 = ''
			SET @TR2 = ''
			SET	@EMP_ID = 0;

			
			
			SELECT	@EMP_ID = MIN(EMP_ID) FROM #EMP_DATA WHERE EMP_ID > @EMP_ID AND (R_EMP_ID=@R_EMP_ID OR EMP_ID=@R_EMP_ID)

			IF ISNULL(@EMP_ID,0) > 0
				BEGIN 
					SET @TR1 = '<tr>
									<td ' + @STYLE_TH + ' width="30px">Sr. No.</td>
									<td ' + @STYLE_TH + ' width="100px">Code</td>
									<td ' + @STYLE_TH + ' width="160px">Name</td>'


					SELECT	@TR1 = @TR1 + '
									<td ' + @STYLE_TH + ' align="center">' + RIGHT(CAPTION,2) + '</td>'
						
					FROM	#EMP_ATTENDANCE	A
					WHERE	EMP_ID=@EMP_ID
				
					SET @BODY = @BODY + @TR1 + '
							</tr>'
				END
		
			WHILE ISNULL(@EMP_ID,0) > 0
				BEGIN 
				
					SET @TR2 = '<tr>'

					SELECT	@TR1 = '<tr>
										<td ' + @STYLE_TD + ' rowspan="2" width="30px">' + CAST(@INDEX AS VARCHAR(10)) + '</td>
										<td ' + @STYLE_TD + ' rowspan="2" width="100px">' + Alpha_Emp_Code + '</td>
										<td ' + @STYLE_TD + ' rowspan="2" width="160px">' + Emp_Full_Name + '</td>'
					FROM	T0080_EMP_MASTER WITH (NOLOCK)
					WHERE	Emp_ID=@EMP_ID

					

					SELECT	@TR1 = @TR1 + '
									<td ' + @STYLE_TD + ' align="center">' + ISNULL(STATUS1,'') + '</td>',
							@TR2 = @TR2 + '
									<td ' + @STYLE_TD + ' align="center">' + ISNULL(STATUS2,'') + '</td>'
					FROM	#EMP_ATTENDANCE	A
					WHERE	EMP_ID=@EMP_ID


				
					SELECT	@EMP_ID = MIN(EMP_ID) FROM #EMP_DATA WHERE EMP_ID > @EMP_ID AND (R_EMP_ID=@R_EMP_ID OR EMP_ID=@R_EMP_ID)

					SET @TR1 = @TR1 + '
								</tr>';
					SET @TR2 = @TR2 + '
								</tr>';
					
					
					
					SET @BODY = @BODY + @TR1 + @TR2 

					IF ISNULL(@EMP_ID,0) > 0
						SET	@INDEX = @INDEX + 1;

					
					
				END

				SET @BODY = @BODY + '
						</table>';

				SET	@HTML = '<table ' + REPLACE(@STYLE_TABLE,'##custom', 'border-width:1px;border-style: solid;padding:10px;') + ' >
								<tr>
									<td>									
										<p <pre style="font-family:arial,sans-serif; font-size: 7.5pt">	Hello ' + @DISPLAY_NAME + ', </p>
	
	Kindly verify the Attendance in the following report for your respective Team Members.</p>
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
								<tr>
									<td>									
										<table ' + REPLACE(@STYLE_TABLE, '##custom', 'border-top: 1px solid #b0daff') + ' width="100%" >
											<tr>
												<td height="18px">P : Present</td>
												<td>A : Absent</td>
												<td>L : Leave</td>
												<td>HF : Half Day</td>
												<td>QD : Quarter Day(0.25)</td>
												<td>3QD : 3rd Quarter(0.75)</td>
											</tr>
											<tr>
												<td height="18px">W : Week Off</td>
												<td>HO : Holiday</td>
												<td>HHO : Half Holiday</td>
												<td>OHO : Optional Holiday</td>
												<td>FH : First Half</td>
												<td>SH : Second Half</td>
											</tr>
											<tr>
												<td height="18px">EC : Early Count</td>
												<td>LC : Late Count</td>
												<td>GP : Gate Pass</td>
												<td>* : Late Mark Exempted </td>
												<td>PD : Paid Days</td>
												<td></td>
											</tr>
										</table>
									</td>
								</tr>
							</table>'
				SET	@SUBJECT = 'Attendance Register for Period ' + CONVERT(CHAR(10), @FROM_DATE, 103)  + ' TO ' + CONVERT(CHAR(10), @TO_DATE, 103)

				SET @HTML = REPLACE(@HTML, '##custom','');
				
				--select CAST('<node>"' + @HTML + '"</node>' AS XML)
				--select * from #EMP_ATTENDANCE
				--print @HTML

				--set @TO_EMAIL = 'noreplyhr@aculife.co.in'
				--set @TO_EMAIL = 'nimesh.p@orangewebtech.com'
				

				--if @R_EMP_ID = 1047
					begin 
						--select @TO_EMAIL
						IF ISNULL(@TO_EMAIL, '') <> ''
							EXEC msdb.dbo.sp_send_dbmail @profile_name = @EMAIL_PROFILE, @recipients = @TO_EMAIL, @subject = @SUBJECT, @body = @HTML, @body_format = 'HTML',@copy_recipients = '',@blind_copy_recipients = ''			
					end 
			FETCH NEXT FROM curManager INTO @R_EMP_ID, @DISPLAY_NAME, @TO_EMAIL
		END

