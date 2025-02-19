

-- =============================================
-- Author:		Nilesh Patel
-- Create date: 06-04-2019
-- Description:	Auto Credit Comp-off Balance if Weekoff and Holiday on Same date. 
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[AUTO_COMP_UTILITY_SP]
	@CMP_ID_PASS NUMERIC(18,0) = 0,
	@CC_Email Nvarchar(max) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	Declare @From_Date As Datetime
	Declare @To_Date As Datetime
	Declare @CONSTRAINT As Varchar(Max)
	Declare @CMPID Numeric
	Declare @COPH_CREDIT_DAYS Numeric

	--Set @CMP_ID_PASS = 149

	Set @From_Date = Replace(Convert(Varchar(11),getDate()-1,106),' ','-') --DATEADD(d,-1,Replace(Convert(Varchar(11),getDate(),106),' ','-'))
	Set @To_Date = Replace(Convert(Varchar(11),getDate()-1,106),' ','-') --DATEADD(d,1,Replace(Convert(Varchar(11),getDate(),106),' ','-'))

	/* Weekoff and Holiday Tables Details */

	IF OBJECT_ID('TEMPDB..#EMP_WEEKOFF') IS NULL
		BEGIN
			CREATE TABLE #EMP_WEEKOFF
			(
				ROW_ID			NUMERIC,
				EMP_ID			NUMERIC,
				FOR_DATE		DATETIME,
				WEEKOFF_DAY		VARCHAR(10),
				W_DAY			NUMERIC(3,1),
				IS_CANCEL		BIT
			)
			CREATE CLUSTERED INDEX IX_EMP_WEEKOFF_EMPID_FORDATE ON #EMP_WEEKOFF(EMP_ID, FOR_DATE)		
		END
		
	IF OBJECT_ID('tempdb..#EMP_HOLIDAY') IS NULL
		BEGIN
			CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(3,1));
			CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);
		END
		
	IF OBJECT_ID('TEMPDB..#EMP_WH') IS NOT NULL
		DROP TABLE #EMP_WH

	CREATE TABLE #EMP_WH
	(
		EMP_ID NUMERIC(18,0),
		FOR_DATE DATETIME,			
		INCREMENT_ID NUMERIC(18,0)
	)

	IF OBJECT_ID('TEMPDB..#EMP_CONS') IS NOT NULL
		DROP TABLE #EMP_CONS

	CREATE TABLE #EMP_CONS
	(
		EMP_ID NUMERIC,
		BRANCH_ID NUMERIC,
		INCREMENT_ID NUMERIC
	)

	IF OBJECT_ID('TEMPDB..#EMPDATA') IS NOT NULL
		BEGIN
			DROP TABLE #EMPDATA
		END

	CREATE TABLE #EMPDATA
	(
		EMP_ID NUMERIC,
		GRD_ID NUMERIC,
		INCREMENT_ID NUMERIC,
		BRANCH_ID NUMERIC,
		IS_APPLICABLE NUMERIC
	)

	Declare @HREmail_ID Varchar(100)
	Set @HREmail_ID = ''
	Declare @HR_Name Varchar(200)
	Set @HR_Name = ''

	Declare @Body Varchar(Max)
	Declare @TableHead varchar(max),@TableTail varchar(max)

	Declare @profile as varchar(50)
	Declare @server_link as varchar(500)

	DECLARE CUR_COMP CURSOR FOR 
	SELECT CMP_ID FROM T0010_COMPANY_MASTER WITH (NOLOCK) WHERE CMP_ID = ISNULL(@CMP_ID_PASS,CMP_ID)
		OPEN CUR_COMP FETCH NEXT FROM CUR_COMP INTO @CMPID
			WHILE @@FETCH_STATUS = 0
				BEGIN
					
					TRUNCATE TABLE #EmpData
					TRUNCATE TABLE #Emp_Cons

					EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID=@CMP_ID_PASS,@From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0,@constraint=''            

					Insert into #EmpData
					Select EC.Emp_ID,0,Increment_ID,Branch_ID,0 
						From #Emp_Cons EC
					LEFT JOIN T0100_LEAVE_CF_DETAIL LD WITH (NOLOCK) on LD.Emp_ID=EC.Emp_ID AND LD.CF_Type = 'AUTO_COMP' AND LD.CF_For_Date = @From_Date
					WHERE LD.LEAVE_CF_ID IS NULL 

					Update ED 
						Set ED.Grd_ID = I.Grd_ID
					From #EmpData ED
					Inner Join T0095_INCREMENT I ON I.Increment_ID = ED.Increment_ID AND I.Emp_ID = ED.Emp_ID

					Update ED	
						Set ED.Is_Applicable = 1 
						From #EmpData ED 
					Inner Join T0050_LEAVE_DETAIL LD ON ED.Grd_ID = LD.Grd_ID
					Inner Join T0040_LEAVE_MASTER LM ON LD.Leave_ID = LM.Leave_ID
					WHERE LM.Default_Short_Name = 'COMP'
				
					SET @CONSTRAINT=NULL;
					
					SELECT	 @CONSTRAINT=	COALESCE(@CONSTRAINT + '#', '') +  CAST(EMP_ID AS VARCHAR(MAX))
					FROM	#EmpData
					
					EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@CMPID, @FROM_DATE=@From_Date, @TO_DATE=@To_Date, @All_Weekoff = 1, @Exec_Mode=0
					
					INSERT INTO #Emp_WH
					SELECT	EW.Emp_ID,EW.For_Date,E.Increment_ID
					FROM	#Emp_WeekOff EW 
							inner join #EMP_HOLIDAY EH on EW.Emp_ID=EH.EMP_ID and EW.For_Date=EH.FOR_DATE
							inner join #EMPDATA E on EW.Emp_ID=E.Emp_ID

					IF EXISTS(SELECT 1 FROM #EMP_WH)
						BEGIN
							EXEC Auto_Credit_COMP_Leave @CMP_ID = @CMPID,@COMP_Credit_Days =@COPH_CREDIT_DAYS  OUTPUT--,@ALPHA_EMP_CODE = '' ,@HOLIDAY_STR = '',@WEEKOFF_STR = '',@SAL_EFFECT_DATE = @SALGENDATE ,@INCREMENT_ID = @INCREMENTID ,@COPH_CREDIT_DAYS =@COPH_CREDIT_DAYS  OUTPUT--,@FOR_DATE=@FORDATE
						END
					
					Set @HR_Name = ''
					Set @HREmail_ID = ''

					SELECT TOP 1 @HREmail_ID = Email_ID, @HR_Name = Emp_Full_Name
					FROM T0011_LOGIN L WITH (NOLOCK) Left Outer Join T0080_EMP_MASTER E WITH (NOLOCK) on L.Emp_ID = E.Emp_ID
					Where L.Cmp_ID=@CMPID AND Is_HR = 1

					Set @Body = ''
					Set @TableHead = ''
					Set @TableTail = ''
					Set @profile =''
					Set @server_link = ''

					Set @TableHead = '<blockquote class="gmail_quote" style="margin: 0 0 0 .8ex; border-left: 1px #ccc solid; padding-left: 1ex">
									<style> 
									.new {text-align:center;border-collapse: collapse;border:1px solid #b0daff;width:15%}   
  									</style>
  
									<table style="background-color: #edf7fd; border-collapse: collapse; border: 1px solid #b0daff"
										align="center" cellpadding="5px" width="100%">
										<tbody>
											<tr>
												<td colspan="9">
													Hello ' + @HR_Name + ',
												</td>
											</tr>
											<tr>
												<td colspan="9">
													System has given Auto Credit to Compoff Leave for below mentioned Employees for the Date of ' + Replace(Convert(Varchar(11),@From_Date,106),' ','-')  + '.
												</td>
											</tr>
											<tr>
												<td colspan="9">
													<table style="background-color: #edf7fd; border-collapse: collapse;border:1px solid #b0daff" cellpadding="5"  border="1px"
														cellspacing="0" width="100%">
														<tbody>
															<tr>
																<th colspan="10" style="color: #3f628e; font-weight: bold" align="left">
																	Auto Credit Comp-off Leave Details:
																</th>
															</tr>
															<tr>
																<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
																	align="left">
																	<b>Alpha Emp Code</b>
																</td>
																<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
																	align="left">
																	<b>Emp Name</b>
																</td>
																<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
																	align="left">
																	<b>Branch Name</b>
																</td>
																<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
																	align="left">
																	<b>Grade</b>
																</td>
																<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
																	align="left">
																	<b>Credited Day</b>
																</td>
															</tr>'
										SET @TableTail = '</tbody>
																		</table>
																	</td>
																<tr>
																	<td colspan="10">
																		&nbsp;
																	</td>
																</tr>
																<tr>
																	<td colspan="4" align="left" style="color: #757677; font-style: italic;">
																		This is an automatically generated email please do not reply to it.
																	</td>
																	<td colspan="4" align="right">
																		<span style="font-family: arial; font-size: 11px; color: rgb(93,93,93)">Powered by&nbsp;</span>
																		<span><a href ="www.payrollsoftware.co.in" >ORANGE HRMS</a></span>
																	</td>
																</tr>

															</tbody>
														</table>
													</blockquote>'
					
					Set @Body = (Select EM.Alpha_Emp_Code as [TD],
					       EM.Emp_Full_Name as [TD],
						   BM.Branch_Name as [TD],
						   GM.Grd_Name as [TD],
						   Cast(LD.CF_Leave_Days as Numeric(4,2)) as [TD]
						From T0100_LEAVE_CF_DETAIL LD WITH (NOLOCK)
					Inner join #EmpData ED ON LD.Emp_ID = ED.EMP_ID
					Inner Join T0030_BRANCH_MASTER BM WITH (NOLOCK) ON BM.Branch_ID = ED.BRANCH_ID
					Inner Join T0040_GRADE_MASTER GM WITH (NOLOCK) ON GM.Grd_ID = ED.GRD_ID
					Inner Join T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = LD.Emp_ID
					Where CF_For_Date = @From_Date AND LD.CF_Type = 'AUTO_COMP'
					ORDER BY  Alpha_Emp_Code For XML raw('tr'), ELEMENTS)

					Set  @Body = @TableHead + @Body + @TableTail
					select @profile = isnull(DB_Mail_Profile_Name,''),@server_link = Server_link  from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = @CMPID
			  
					if isnull(@profile,'') = ''
						begin
							select @profile = isnull(DB_Mail_Profile_Name,''),@server_link = Server_link from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = 0
						end

					if @HREmail_ID <> '' AND isnull(@Body,'') <> ''
						begin
							EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @HREmail_ID, @subject = 'Auto Credit Comp-off Leave Balance For Same Date Holiday and Weekoff', @body = @Body, @body_format = 'HTML',@copy_recipients = @CC_Email,@blind_copy_recipients = ''
						end

					FETCH NEXT FROM CUR_COMP INTO @CMPID
				END
			CLOSE CUR_COMP
		DEALLOCATE CUR_COMP
END

