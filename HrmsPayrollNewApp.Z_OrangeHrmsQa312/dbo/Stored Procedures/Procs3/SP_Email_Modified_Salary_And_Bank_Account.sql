--exec [SP_Email_Modified_Salary_And_Bank_Account] 119,24
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Email_Modified_Salary_And_Bank_Account]
	@CMP_ID Int,
	@EMail_Profile  int
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

IF OBJECT_ID('tempdb..#Employee_DATA') IS NOT NULL
			drop table #Employee_DATA

		SELECT * Into #Employee_DATA  
		FROM
		(
		SELECT  
		ROW_NUMBER() OVER(PARTITION By Emp_ID ORDER BY Increment_ID DESC) as Record_No,
		[Increment_ID],Increment_Type,[Emp_ID],[Alpha_Emp_Code],[Emp_Full_Name],ISNULL([Desig_Name],'-')as Desig_Name, ISNULL([Dept_Name],'-') 
		as Dept_Name,ISNULL([Branch_Name],'-') as Branch_Name,ISNULL(Gross_Salary,0)as Gross_Salary
		,ISNULL([Inc_Bank_AC_No],'-') as Inc_Bank_AC_No,ISNULL(Login_Name,'-') as Login_Name
		,System_Date,Cmp_ID
		FROM [V0095_Increment_All_Data] as A 
		Left outer join
		(Select Login_ID,EMP_CODE as Login_EMP_CODE ,RIGHT('000000'+cast(EMP_CODE AS varchar(50)),6) + ' - '+ Emp_Full_Name as Login_Name 
		FROM V0011_Login ) as B On A.Login_ID =  B.Login_ID
		WHERE Increment_Type <> 'Joining' And 
		A.Cmp_ID =@CMP_ID
		) as DATA 
		Where DATA.Record_No in (1,2)
		and ( cast(cast(System_Date as varchar(11)) as datetime) = cast(cast(getdate() as varchar(11)) as datetime) OR  Record_No=2)

		--Select * from 	#Employee_DATA		

	DECLARE @Notification_Subject as varchar(max)
	SET @Notification_Subject ='Modified Master Alert for ' + convert(varchar(11),getdate()-1,103)  + ''

	DECLARE @style VARCHAR(max)
		SET @style = 'text-align:center;border-collapse: collapse;border :1px solid;width:15%;font-size: 12px;border-color:#b0daff';

	DECLARE @TableHead VARCHAR(max)
			,@TableTail VARCHAR(max)  

		SET @TableHead = '<html><head>
				<style>
						td {font-family: arial,sans-serif;font-size: 13px;}
						span{font-family: arial,sans-serif;font-size: 15px;color: red;font-weight: 700;}
				</style>
				</head>
				<blockquote class="gmail_quote" style="margin: 0 0 0 .8ex; border-left: 1px #ccc solid;
					padding-left: 1ex">
					<table style="background-color: #edf7fd; border-collapse: collapse;"
						align="center" cellpadding="5px" width="100%">
						<tbody>
							<tr>
								<td colspan="6">
									Hello,
								</td>
							</tr>
							<tr>
								<td colspan="6"> 
									Please check Below details of ' + @Notification_Subject + '
								</td>
							</tr>
							<tr>
								<td colspan="6">
									<table style="background-color: #edf7fd; border-collapse: collapse;border:1px solid #b0daff" cellpadding="3"  border="1px"
										cellspacing="0" width="100%">
										<tbody>
											<tr>
												<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
													align="center" width="5%">
													<b>SNo</b>
												</td>
												<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
													align="center" width="15%">
													<b>Employee Code</b>
												</td>
												<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
													align="center" width="25%">
													<b>Employee Name</b>
												</td>
												<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
													align="center" nowrap="" width="15%">
													<b>Designation</b>
												</td>
												<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
													align="center" nowrap="" width="15%">
													<b>Department</b>
												</td>
												<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
													align="center" nowrap="" width="15%">
													<b>Branch</b>
												</td>
												<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
													align="center" nowrap="" width="20%">
													<b>Field Column</b>
												</td>
												<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
													align="center" nowrap="" width="15%">
													<b>Old Record</b>
												</td>
												<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
													align="center" nowrap="" width="15%">
													<b>New Record</b>
												</td>
												<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
													align="center" nowrap="" width="15%">
													<b>Modify By</b>
												</td>
											</tr>'

		SET @TableTail = '</tbody>
									</table>
								</td>
							</tr>
							<tr>
								<td colspan="9">
									&nbsp;
								</td>
							</tr>
							<tr>
								<td colspan="9" style="color: #757677" align="left">
									Thank you,<br>
								</td>
							</tr>
							</tbody>
					</table>
				</blockquote>
				</html>'

			IF OBJECT_ID('tempdb..#Emp_Old_New_Tmp') IS NOT NULL
						 drop table #Emp_Old_New_Tmp

				SELECT	
				[Alpha_Emp_Code] AS [TD] ,
				CASE WHEN isnull(Gross_Old,0)= isnull(Gross_Salary,0) THEN '-' ELSE cast(isnull(Gross_Old,0) as varchar(30)) END AS [TD_GS_Old],
				CASE WHEN isnull(Gross_Old,0)= isnull(Gross_Salary,0) THEN '-' ELSE cast(isnull(Gross_Salary,0) as varchar(30)) END as [TD_GS_New],
				CASE WHEN isnull(Bank_AC_OLD,'-')= ISNULL([Inc_Bank_AC_No],'-') THEN '-' ELSE cast(isnull(Bank_AC_OLD,'-') as varchar(30)) END AS [TD_Bank_Old],
				CASE WHEN isnull(Bank_AC_OLD,'-')= ISNULL([Inc_Bank_AC_No],'-') THEN '-' ELSE cast(ISNULL([Inc_Bank_AC_No],'-') as varchar(30)) END as [TD_Bank_New],
				isnull(Tbl_A.Login_Name,'-') as [TD_Modify]
				Into #Emp_Old_New_Tmp
				FROM (
						SELECT 
						Record_No,[Increment_ID],[Emp_ID],[Alpha_Emp_Code],[Emp_Full_Name],[Desig_Name], [Dept_Name],[Branch_Name],Gross_Salary ,[Inc_Bank_AC_No],Login_Name 
						FROM #Employee_DATA 
						where Record_No =1
				) as Tbl_A
				Left outer join
				(
					SELECT [Emp_ID],Gross_Salary as Gross_Old,[Inc_Bank_AC_No] as  Bank_AC_OLD FROM #Employee_DATA  where Record_No =2
				) AS Tbl_B
					On Tbl_A.[Emp_ID]= Tbl_B.[Emp_ID]
					WHERE (Record_No =1 or (Tbl_A.Inc_Bank_AC_No <> Tbl_B.Bank_AC_OLD Or Tbl_A.Gross_Salary <> Tbl_B.Gross_Old)
				)
				ORDER BY  [Alpha_Emp_Code] 

				--Select * from #Emp_Old_New_Tmp

			IF OBJECT_ID('tempdb..#unPivot_Tmp') IS NOT NULL
					 Drop table #unPivot_Tmp
						
						
				SELECT TD , Field ,Value1 ,TD_Modify into #unPivot_Tmp
				FROM #Emp_Old_New_Tmp 
				UNPIVOT
				(
					Value1
					FOR Field in (TD_GS_Old, TD_GS_New,TD_Bank_Old , TD_Bank_New)
				) AS SP1
				Order by TD			
				
				--Select * from #unPivot_Tmp

			IF OBJECT_ID('tempdb..#Final_Table') IS NOT NULL
					 Drop table #Final_Table
					

			CREATE TABLE #Final_Table(
				Emp_Code    VARCHAR(10),
				Field VARCHAR(20),
				Old   VARCHAR(100),
				New   VARCHAR(100),
				Modify_By VARCHAR(100)
			)			
						
						
			INSERT INTO #Final_Table (Emp_Code,Field,OLD,New,Modify_By)
			SELECT TD,'Gross Salary' as Field, TD_GS_Old, TD_GS_New, TD_Modify FROM   
			(
				SELECT TD, Field , Value1,TD_Modify FROM #unPivot_Tmp where Field in ('TD_GS_Old','TD_GS_New') 
			)t1
			PIVOT  
			(  
				Max(Value1) FOR Field IN (TD_GS_Old ,TD_GS_New) 
			) AS t2
			ORDER BY Td
			
			INSERT INTO #Final_Table (Emp_Code,Field,OLD,New,Modify_By)
			SELECT TD,'Bank A/C No' as Field, TD_Bank_Old, TD_Bank_New, TD_Modify  FROM   
			(
				SELECT TD, Field , Value1,TD_Modify FROM #unPivot_Tmp where Field in ('TD_Bank_Old','TD_Bank_New') 
			)t1
			PIVOT  
			(  
				Max(Value1) FOR Field IN (TD_Bank_Old ,TD_Bank_New) 
			) AS t2
			ORDER BY Td
			--Select * from #Employee_DATA			
			--Select * from #Final_Table
		DECLARE @Body AS VARCHAR(MAX)
	
		SET @Body = (			
						Select ROW_NUMBER() OVER (ORDER BY [Alpha_Emp_Code] Asc) as TD
							,Alpha_Emp_Code as TD 
							,Emp_Full_Name as TD 
							,Desig_Name as TD 
							,Dept_Name as TD 
							,Branch_Name as TD 
							,Field as TD
							,Old as TD
							,New as TD
							,E.Login_Name as TD
						FROM #Employee_DATA E 
							INNER JOIN  #Final_Table T ON E.Alpha_Emp_Code = T.Emp_Code 
						Where E.Record_No = 1 
						Order by Alpha_Emp_Code, Field
						For XML raw('tr'),ELEMENTS
					) 

		IF ISNULL(@BODY,'') =''
		 BEGIN
			SET @TableHead = ''
			SET  @Body =
			'<html><head>
				<style>
						td {font-family: arial,sans-serif;font-size: 13px;}
						span{font-family: arial,sans-serif;font-size: 15px;color: red;font-weight: 700;}
				</style>
				</head>
				<blockquote class="gmail_quote" style="margin: 0 0 0 .8ex; border-left: 1px #ccc solid;
					padding-left: 1ex">
					<table style="background-color: #edf7fd; border-collapse: collapse;"
						align="center" cellpadding="5px" width="100%">
						<tbody>
							<tr>
								<td colspan="9" style="color: #757677" align="left">
									No Record Found<br>
								</td>
							</tr>
							</tbody>
					</table>
				</blockquote>
				</html>'
		 END  
     
    ------------- End-----------------
    
           
	SET  @Body = @TableHead + @Body + @TableTail    		  
	--SET @Body = REPLACE(@Body, '<td>', '<td style="'+ @style + '">')
	Set @Body = REPLACE(@Body,'&lt;span&gt;','<span>')
	Set @Body = REPLACE(@Body,'&lt;/span&gt;','</span>')
	--Select @Body		
	--return
	IF isnull(@Body,'') =''
	begin
		return
	End
	
	DECLARE @HREmail_ID	NVARCHAR(4000)
	--SELECT @HREmail_ID =(SELECT TOP 1 Email_ID FROM T0011_LOGIN where Cmp_ID=@CMP_ID_PASS AND Is_HR = 1)
	--Set @HREmail_ID = 'modifyalert@competentsynergies.com'
	Set @HREmail_ID = 'sajid@orangewebtech.com;deepal.s@orangewebtech.com;qa@orangewebtech.com'

	DECLARE @profile AS VARCHAR(50)
    SET @profile = ''

	

	
	SELECT @profile = IsNull(DB_Mail_Profile_Name,'') FROM t9999_Reminder_Mail_Profile WITH (NOLOCK) where DB_Mail_Profile_Id = @EMail_Profile
       		print 	@profile
			
    IF IsNull(@profile,'') = ''
       	BEGIN
       		SELECT @profile = IsNull(DB_Mail_Profile_Name,'') FROM t9999_Reminder_Mail_Profile WITH (NOLOCK) where DB_Mail_Profile_Id = 0
       	END 

	IF @HREmail_ID <> ''
		Begin
			--EXEC msdb.dbo.sp_sEND_dbmail @profile_name = @profile, @recipients = @HREmail_ID, @subject = @Notification_Subject, @body = @Body, @body_format = 'HTML' , @copy_recipients = 'sajid@orangewebtech.com;hardik@orangewebtech.com;ankur@orangewebtech.com'                                                                             
			EXEC msdb.dbo.sp_sEND_dbmail @profile_name = @profile, @recipients = @HREmail_ID, @subject = @Notification_Subject, @body = @Body, @body_format = 'HTML' , @copy_recipients = ''                                                                             
		End
	
