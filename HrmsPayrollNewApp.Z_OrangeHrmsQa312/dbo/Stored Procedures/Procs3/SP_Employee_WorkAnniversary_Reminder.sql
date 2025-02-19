--exec  SP_Employee_WorkAnniversary_Reminder 119,'chintan.p@orangewebtech.com'
CREATE PROCEDURE [dbo].[SP_Employee_WorkAnniversary_Reminder]
@cmp_id_Pass Numeric(18,0) = 0,
@CC_Email Nvarchar(max) = ''
AS 
BEGIN   

	  DECLARE @DATE VARCHAR(11)   
      DECLARE @Approval_day AS NUMERIC    
      DECLARE @ReminderTemplate AS NVARCHAR(4000)
      SET @DATE = CAST(GETDATE() AS varchar(11))
       
       
       if @cmp_id_Pass = 0
			set @cmp_id_Pass=null
      
      IF OBJECT_ID('tempdb..#Temp') IS NOT NULL 
         BEGIN
               DROP TABLE #Temp
         END
       
     CREATE table #Temp 
     (
		CMP_ID NUMERIC,
		EMP_ID NUMERIC,
		BRANCH_ID NUMERIC(18,0),
		EMP_CODE VARCHAR(100),
		EMP_NAME VARCHAR(200),
		BRANCH_NAME VARCHAR(100),
		DESIG_NAME VARCHAR(100),
		DEPT_NAME VARCHAR(100),
		Date_Of_Join VARCHAR(50)
	) 
				
			
	INSERT INTO #Temp
	SELECT 
		EM.Cmp_id,Em.Emp_ID,BM.BRANCH_ID,Em.Alpha_Emp_Code,Em.Emp_Full_Name,Bm.Branch_Name,DSM.Desig_Name,Dm.Dept_Name,
		--CONVERT(varchar(11),date_of_birth,103) as Date_of_birth
		CONVERT(varchar(7),Date_Of_Join,6) as Date_Of_Join
	FROM T0080_EMP_MASTER EM WITH (NOLOCK) 
		INNER JOIN T0095_INCREMENT I WITH (NOLOCK) on EM.Increment_ID = I.Increment_ID
		LEFT JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) on I.Branch_ID = Bm.branch_id 
		LEFT JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on I.Dept_ID = DM.Dept_Id 
		LEFT JOIN T0040_DESIGNATION_MASTER DSM WITH (NOLOCK) on I.Desig_Id = DSM.Desig_ID 
	WHERE Date_Of_Join is not null and month(Date_Of_Join)=month(GETDATE()) and day(Date_Of_Birth) = day(GETDATE()) 
		and isnull(Emp_Left,'N')<>'Y' and  em.Cmp_ID = isnull(@cmp_id_Pass,em.Cmp_ID)


      CREATE table #HR_Email
      ( 
		Row_Id INT IDENTITY(1, 1),
        Cmp_ID NUMERIC(18, 0),
        
      )   

	INSERT INTO #HR_EMAIL (CMP_ID)
	SELECT CMP_ID FROM #TEMP GROUP BY CMP_ID


	DECLARE @HREMAIL_ID	NVARCHAR(4000)
	DECLARE @CMP_ID AS NUMERIC
	DECLARE @HR_NAME AS VARCHAR(255)
	DECLARE @ECOUNT AS NUMERIC
	DECLARE @EMAIL_ID AS NVARCHAR(4000)
	DECLARE @BRANCH_ID_MULTI AS NVARCHAR(MAX)	
	DECLARE @BRANCH_ID AS NUMERIC(18,0)
	DECLARE @EMP_ID AS NUMERIC(18,0)
		
		
	DECLARE CUR_COMPANY CURSOR FOR     
	--select Cmp_Id from #HR_Email order by Cmp_ID         COMMENTED BY RAJPUT ON 07042018 BRANCH WISE NOT WORKING STORE PROCEDURE UPDATED.
	SELECT EMP_ID FROM T0011_LOGIN WITH (NOLOCK) WHERE ISNULL(CMP_ID,0)=@CMP_ID_PASS AND IS_HR = 1 AND EMP_ID IS NOT NULL ORDER BY EMP_ID
	OPEN CUR_COMPANY                      
	FETCH NEXT FROM CUR_COMPANY INTO @EMP_ID
	WHILE @@FETCH_STATUS = 0                    
		BEGIN
			
		
			SELECT @HREMAIL_ID = EMAIL_ID, @HR_NAME = EMP_FULL_NAME,@BRANCH_ID_MULTI=BRANCH_ID_MULTI
			FROM T0011_LOGIN L LEFT OUTER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON L.EMP_ID = E.EMP_ID
			WHERE L.CMP_ID=ISNULL(@CMP_ID_PASS,0) AND IS_HR = 1 AND L.EMP_ID=@EMP_ID
				
			SELECT CAST(DATA AS NUMERIC) BRANCH_ID
			INTO #TBL_BRANCH
			FROM DBO.SPLIT(@BRANCH_ID_MULTI, '#') T 
			
			IF ISNULL(@HREMAIL_ID,'')='' 
				BEGIN
					SELECT @HREMAIL_ID = (SELECT TOP 1 EMAIL_ID FROM T0011_LOGIN WITH (NOLOCK) WHERE IS_HR = 1)
				END
			
			IF EXISTS(SELECT 1 FROM #TBL_BRANCH WHERE BRANCH_ID > 0)
				BEGIN
					SELECT @ECOUNT = COUNT(EMP_ID)
					FROM #TEMP WHERE CMP_ID = ISNULL(@CMP_ID_PASS,0) 
					AND BRANCH_ID IN (SELECT BRANCH_ID FROM #TBL_BRANCH)
				END
			ELSE
				BEGIN
					SELECT @ECOUNT = COUNT(EMP_ID)
					FROM #TEMP WHERE CMP_ID = ISNULL(@CMP_ID_PASS,0) 
				END
		
		                        
			  ---ALTER dynamic template for Employee.				
		      Declare  @TableHead varchar(max),
					   @TableTail varchar(max)   
           		  Set @TableHead = '<html><head>' +
								  '<style>' +
								  'td {font-size:9pt;font-family: calibri;padding:4px;} ' +
								  '</style>' +
								  '</head>' +
								  '<body>
								  <div style="font-family:Arial, Helvetica, sans-serif; color:#000000;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">
								  Dear ' + isnull(@HR_Name,'') + ' </div>	<br/>					
								  
								  <table width="800" border="0" align="center" cellpadding="0" cellspacing="0" style="border:1px solid #cacaca;padding: 10px 10px 10px 10px;">
								  <tr>
									 <td align="center" valign="middle"><table width="800" border="0" cellspacing="0" cellpadding="0">
										<tr>
										<td height="9" align="center" valign="middle" ></td>
										</tr>
									  <tr>
										<td width="800" height="24" align="center" valign="middle" style="background:#0b0505;font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">Today''s Birthday Report ( ' + @Date + ') </td>
									  </tr>
										  <tr>
											<td height="4" align="center" valign="middle"></td>
										  </tr>
										  <tr>
											<td width="800" align="center" valign="middle" style="font-family:Arial, Helvetica, sans-serif; color:#000000;  text-decoration:none; text-align:center; font-size:12px;font-weight: 600;">Total Employees Birthday: [ ' + CAST(@ECount AS VARCHAR(255)) + ' ] </td>
										  </tr>
										  <tr>
											<td height="8" align="center" valign="middle"></td>
										  </tr>
								  </table>
                                    
								  <table border="1" width="800" height="24" align="center" valign="middle" style="background: #FFFFF;border-color:solid black;
											border-radius: 10px 10px 10px 10px; font-family: Arial, Helvetica, sans-serif;
											color: #000000; text-decoration: none; font-weight: normal; text-align: left;
											font-size: 12px; border-collapse: collapse;">' +
										  '<tr border="1"><td align=center><span style="font-size:small"><b>Code</b></span></td>' +
										  '<td align=center><b><span style="font-size:small">Employee Name</span></b></td>' +
										  '<td align=center><b><span style="font-size:small">Branch</span></b></td>' +
										  '<td align=center><b><span style="font-size:small">Department</span></b></td>' +
										  '<td align=center><b><span style="font-size:small">Designation</span></b></td>' +
										  '<td align=center><b><span style="font-size:small">Birth Date</span></b></td>'
										                                     
				SET @TableTail = '</table></body></html>';                  	
                DECLARE @Body AS VARCHAR(MAX)

				IF EXISTS(SELECT 1 FROM #TBL_BRANCH WHERE BRANCH_ID > 0)
					BEGIN
						SET @Body = ( SELECT  
											Emp_Code  as [TD],
											Emp_name  as [TD],
											Isnull(Branch_name,'-') as [TD],
											Isnull(Dept_Name,'-') as [TD],
											Isnull(Desig_Name,'-') as [TD],
											Isnull(Date_Of_Join,'-') As [TD]
									FROM    #Temp
									WHERE   Cmp_ID = ISNULL(@CMP_ID_PASS,0)  AND BRANCH_ID IN (SELECT BRANCH_ID FROM #TBL_BRANCH) 
									ORDER BY  Emp_code For XML raw('tr'), ELEMENTS) 
					END
				ELSE
					BEGIN
						SET @Body = ( SELECT  
											Emp_Code  as [TD],
											Emp_name  as [TD],
											Isnull(Branch_name,'-') as [TD],
											Isnull(Dept_Name,'-') as [TD],
											Isnull(Desig_Name,'-') as [TD],
											Isnull(Date_Of_Join,'-') As [TD]
									FROM    #Temp
									WHERE   Cmp_ID = ISNULL(@CMP_ID_PASS,0)  
									ORDER BY  Emp_code For XML raw('tr'), ELEMENTS) 
					END

                             
                       
                       --if (@HREmail_ID <> '')
                       -- BEGIN
                       --    EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Orange', @recipients = @HREmail_ID,  @subject = 'Leave Approval Reminder', @body = @Body, @body_format = 'HTML'                               
                           
                       -- END
					
           			
           		  SELECT  @Body = @TableHead + @Body + @TableTail  
           		  
           		
           		  Declare @subject as varchar(100)           
           		  Set @subject = 'Birthday Report ( ' + @Date + ' )'
           		  
           		    Declare @profile as varchar(50)
       					  set @profile = ''
       					  
       					  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile where cmp_id = @Cmp_Id
       					  
			  IF ISNULL(@PROFILE,'') = ''
			  BEGIN
				SELECT @PROFILE = ISNULL(DB_MAIL_PROFILE_NAME,'') FROM T9999_REMINDER_MAIL_PROFILE WITH (NOLOCK) WHERE CMP_ID = 0
			  END
           	
           	
			EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @HREmail_ID, @subject = @subject, @body = @Body, @body_format = 'HTML',@copy_recipients = @CC_Email
		--	EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = 'Rohit@orangewebtech.com', @subject = @subject, @body = @Body, @body_format = 'HTML',@copy_recipients = @CC_Email
			
			Set @HREmail_ID = ''
			Set @HR_Name = ''
			Set @ECount = 0
			
		 FETCH NEXT FROM CUR_COMPANY INTO @EMP_ID
	   END                    
	CLOSE CUR_COMPANY                    
	DEALLOCATE CUR_COMPANY         

End
