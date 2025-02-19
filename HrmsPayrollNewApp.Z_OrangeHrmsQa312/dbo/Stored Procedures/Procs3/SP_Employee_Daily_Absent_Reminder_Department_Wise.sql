

---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[SP_Employee_Daily_Absent_Reminder_Department_Wise]
@cmp_id_Pass Numeric(18,0) = 0,
@CC_Email Nvarchar(max) = ''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN   

	  DECLARE @DATE VARCHAR(11)   
      DECLARE @APPROVAL_DAY AS NUMERIC    
      DECLARE @REMINDERTEMPLATE AS NVARCHAR(4000)
      SET @DATE = CAST(GETDATE()AS VARCHAR(11))
       
     IF OBJECT_ID('tempdb..#Temp') IS NOT NULL 
         BEGIN
			DROP TABLE #Temp
         END
       
		CREATE TABLE #TEMP 
		(
	 		CMP_ID NUMERIC,
			EMP_ID NUMERIC,
			EMP_CODE VARCHAR(100),
			EMP_NAME VARCHAR(200),
			DESIG_NAME VARCHAR(100),
			DEPT_NAME VARCHAR(100),
			FOR_DATE DATETIME,
			STATUS VARCHAR(10),
			BRANCH_NAME VARCHAR(100)
		) 
            
		CREATE TABLE #HR_EMAIL
		( 
			ROW_ID INT IDENTITY(1, 1),
			CMP_ID NUMERIC(18, 0)
		)   
            
	 INSERT    INTO #TEMP
     EXEC [SP_GET_PRESENT_ABSENT_EMP_LIST] @CMP_ID_PASS,@DATE

	--- FOR SHIFT WISE EMPLOYEE SHOULD COME ON 11042018 ---
	 ALTER  TABLE #TEMP  
     ADD  SHIFT_ID NUMERIC(18,0);
     
	--Add by Nimesh 21 April, 2015
	--This sp retrieves the Shift Rotation as per given employee id and effective date.
	--it will fetch all employee's shift rotation detail if employee id is not specified.
	IF (OBJECT_ID('TEMPDB..#ROTATION') IS NULL)
		CREATE TABLE #ROTATION (R_EMPID NUMERIC(18,0), R_DAYNAME VARCHAR(25), R_SHIFTID NUMERIC(18,0), R_EFFECTIVE_DATE DATETIME);
	--THE #ROTATION TABLE GETS RE-CREATED IN DBO.P0050_UNPIVOT_EMP_ROTATION STORED PROCEDURE
	DECLARE @CONSTRAINT VARCHAR(MAX);
	SELECT DISTINCT @CONSTRAINT + COALESCE(@CONSTRAINT + '# ', '') + CAST(EMP_ID AS VARCHAR(10)) FROM #TEMP
	EXEC DBO.P0050_UNPIVOT_EMP_ROTATION @CMP_ID_PASS, NULL, @DATE, @CONSTRAINT
	
		
	UPDATE	#TEMP
	SET		SHIFT_ID = CAST(QA1.SHIFT_ID AS NUMERIC(18,0))
	FROM	#TEMP  INNER JOIN
			(
				SELECT ESD.SHIFT_ID,ESD.EMP_ID,FOR_DATE FROM T0100_EMP_SHIFT_DETAIL AS ESD WITH (NOLOCK) INNER JOIN
				(
					SELECT EMP_ID,MAX(FOR_DATE) AS MAX_FOR_DATE FROM T0100_EMP_SHIFT_DETAIL WITH (NOLOCK)
					WHERE FOR_DATE <= @DATE GROUP BY EMP_ID
				) Q1 ON
				ESD.EMP_ID = Q1.EMP_ID AND ESD.FOR_DATE = Q1.MAX_FOR_DATE
			) QA1 ON
			#TEMP.EMP_ID = QA1.EMP_ID

	--UPDATING SHIFT ID IF ASSIGNED IN ROTATION
	UPDATE	#TEMP
	SET		SHIFT_ID = R.R_SHIFTID
	FROM	#ROTATION R
	WHERE	EMP_ID=R_EMPID  AND R_DAYNAME='DAY' + CAST(DATEPART(D, @DATE) AS VARCHAR) AND 
			R_EFFECTIVE_DATE = (SELECT MAX(R_EFFECTIVE_DATE) FROM #ROTATION WHERE R_EMPID=EMP_ID )

	--UPDATING SHIFT ID FROM EMPLOYEE SHIFT DETAIL IF DEFINED WHERE SHIFT_TYPE = 0 AND EXIST IN EMPLOYEE SHIFT DETAIL
	UPDATE	#TEMP
	SET		SHIFT_ID = E_SHIFTID
	FROM	(
				SELECT	ESD.SHIFT_ID AS E_SHIFTID,ESD.EMP_ID AS E_EMPID
				FROM	T0100_EMP_SHIFT_DETAIL AS ESD WITH (NOLOCK) 
				WHERE	FOR_DATE = @DATE AND ESD.CMP_ID=@CMP_ID_PASS
			) ES			
	WHERE	ES.E_EMPID=EMP_ID AND E_EMPID IN (
												SELECT	R_EMPID 
												FROM	#ROTATION R 
												WHERE	R.R_EFFECTIVE_DATE <= @DATE
											)
			
	--Updating Shift ID from Employee Shift Detail if defined where Shift_Type = 1 and not exist in Employee Shift Detail
	UPDATE	#TEMP
	SET		SHIFT_ID = E_SHIFTID
	FROM	(
				SELECT	ESD.SHIFT_ID AS E_SHIFTID,ESD.EMP_ID AS E_EMPID
				FROM	T0100_EMP_SHIFT_DETAIL AS ESD WITH (NOLOCK)
				WHERE	FOR_DATE = @DATE AND ISNULL(SHIFT_TYPE,0)=1 AND ESD.CMP_ID=@CMP_ID_PASS
			) ES			
	WHERE	ES.E_EMPID=EMP_ID AND E_EMPID NOT IN (
												SELECT	R_EMPID 
												FROM	#ROTATION R 
												WHERE	R.R_EFFECTIVE_DATE <= @DATE 
											)
	--End Nimesh
	
	DECLARE @SH_ID NUMERIC
	DECLARE @SHIFT_ID NUMERIC
	SET @SH_ID =  DATEPART(HH,GETDATE())
	 CREATE TABLE #SHIFT_CONS 
	 (      
		SHIFT_ID NUMERIC  
	 )      
	 
	INSERT INTO #SHIFT_CONS  
	SELECT SHIFT_ID FROM DBO.T0040_SHIFT_MASTER WITH (NOLOCK) WHERE CAST(LEFT(SHIFT_ST_TIME,2) AS NUMERIC(2,0))  <= @SH_ID AND CAST(LEFT(SHIFT_ST_TIME,2) AS NUMERIC(2,0)) >= @SH_ID - 2  AND CMP_ID=@CMP_ID_PASS
	--
	DELETE #TEMP WHERE SHIFT_ID NOT IN (SELECT SHIFT_ID FROM #SHIFT_CONS )
	
	-- ENDED ON 11042018 --
	--Delete #Temp Where Status <> 'A'
	
	UPDATE T
	SET T.EMP_NAME = E.INITIAL + ' ' + E.EMP_FIRST_NAME + ' ' + E.EMP_SECOND_NAME + ' ' + E.EMP_LAST_NAME
	FROM	#TEMP T
			INNER JOIN	(	
							SELECT CMP_ID,EMP_ID,ISNULL(INITIAL,'') AS INITIAL,ISNULL(EMP_FIRST_NAME,'') AS EMP_FIRST_NAME,ISNULL(EMP_SECOND_NAME,'') AS EMP_SECOND_NAME,ISNULL(EMP_LAST_NAME,'') AS EMP_LAST_NAME
							FROM T0080_EMP_MASTER EMS WITH (NOLOCK)
						)	E ON T.EMP_ID=E.EMP_ID AND T.CMP_ID=E.CMP_ID
	
	Insert Into #HR_Email (Cmp_ID)
	Select Cmp_Id From #Temp Group by Cmp_ID


	
	Declare @HREmail_ID	nvarchar(4000)
	Declare @Cmp_Id as numeric
	Declare @HR_Name as varchar(255)
	Declare @ECount as numeric
	Declare @EPCount as numeric
	Declare @Department as varchar(255)
	
	Declare @DEPT_ID as varchar(255)
	Declare @DeptManagerEmail_ID	nvarchar(4000)
	Declare @DeptManager_Name as varchar(255)
	
	declare Cur_Company cursor for                    
		select Cmp_Id from #HR_Email order by Cmp_ID
	open Cur_Company                      
	fetch next from Cur_Company into @Cmp_Id
	while @@fetch_status = 0                    
		begin     
				
				declare Cur_Department cursor for                    
				select  dept_id  from T0095_Department_Manager WITH (NOLOCK) 
				where Cmp_id = @Cmp_Id order by dept_id
				open Cur_Department                      
				fetch next from Cur_Department into @DEPT_ID
				while @@fetch_status = 0                    
				begin     
			
				
					
					--SELECT TOP 1 @HREmail_ID = Email_ID, @HR_Name = Emp_Full_Name
					--FROM T0011_LOGIN L Left Outer Join T0080_EMP_MASTER E on L.Emp_ID = E.Emp_ID
					--Where L.Cmp_ID=@Cmp_ID AND Is_HR = 1
					--ISNULL(E.INITIAL,'') + ' ' +
					SELECT TOP 1 @DEPTMANAGEREMAIL_ID = WORK_EMAIL , @DEPTMANAGER_NAME = EMP_FULL_NAME FROM T0095_DEPARTMENT_MANAGER M WITH (NOLOCK)
					INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON M.EMP_ID=E.EMP_ID WHERE M.CMP_ID = @CMP_ID AND E.DEPT_ID=@DEPT_ID ORDER BY M.EFFECTIVE_DATE DESC 
					
					SELECT @Department = DEPT_NAME FROM T0040_DEPARTMENT_MASTER WITH (NOLOCK) WHERE CMP_ID=@CMP_ID AND DEPT_ID=@DEPT_ID
					
					
					Select @ECount = COUNT(Emp_Id) From #Temp where Cmp_ID = @Cmp_Id and Dept_Name = @Department and Status='A'
				    select @EPCount = COUNT(Emp_Id) From #Temp where Cmp_ID = @Cmp_Id and Dept_Name = @Department and Status='P'
					
				
					  ---ALTER dynamic template for Employee.				
					  Declare  @TableHead varchar(max),
							   @TableTail varchar(max)   
       					Set @TableHead = '<html><head>' +
										  '<style>' +
										  'td {font-size:9pt;font-family: calibri;padding:4px;} ' +
										  '</style>' +
										  '</head>' +
										  '<body>
										  <p style="font-family:Arial, Helvetica, sans-serif; color:#000000;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">
										  Dear ' + @DEPTMANAGER_NAME + ' </p>
										  
										  <table width="800" border="0" align="center" cellpadding="0" cellspacing="0" style="border:1px solid #cacaca;padding: 10px 10px 10px 10px;" >
										  <tr>
											 <td align="center" valign="middle"><table width="800" border="0" cellspacing="0" cellpadding="0">
											  <tr>
												<td width="800" height="24" align="center" valign="middle" style="background:#0b0505;font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">Today''s Present / Absent Report ( ' + @Date + ' ) for ' + @Department + ' </td>
											  </tr>
												  <tr>
													<td height="4" align="center" valign="middle"></td>
												  </tr>
												  <tr>
													<td width="800" align="center" valign="middle" style="font-family:Arial, Helvetica, sans-serif; color:#000000;  text-decoration:none; text-align:center; font-size:12px;font-weight: 600;">Total Absent Employees : <b style="color:#ff0000;">[ ' + CAST(@ECount AS VARCHAR(255)) + ' ]</b> , Total Present Employees : <b>[ ' + CAST(@EPCount AS VARCHAR(255)) + ' ]</b> </td>
												  </tr>
												  <tr>
													<td height="8" align="center" valign="middle"></td>
												  </tr>
										  </table>
			                                
										  <table border="1" width="800" height="24" align="center" valign="middle" style="background: #FFFFF;border-color:solid black;
											border-radius: 10px 10px 10px 10px; font-family: Arial, Helvetica, sans-serif;
											color: #000000; text-decoration: none; font-weight: normal; text-align: left;
											font-size: 12px; border-collapse: collapse;">' +
												  '<tr border="1"><td align=center><span style="font-size:small"><b>Emp Code</b></span></td>' +
												  '<td align=center><b><span style="font-size:small">Employee Name</span></b></td>' +
												  '<td align=center><b><span style="font-size:small">Department</span></b></td>' +
												  '<td align=center><b><span style="font-size:small">Designation</span></b></td>' +
												  '<td align=center><b><span style="font-size:small">Status</span></b></td></tr>'
												                                     
						  SET @TableTail = '</table></body></html>';                  	
						  DECLARE @Body AS VARCHAR(MAX)
						  DECLARE @Body2 AS VARCHAR(MAX)
						  SET @Body = ( SELECT  
												emp_Code  as [TD],
												Emp_name  as [TD],
												Isnull(Dept_Name,'-') as [TD],
												Isnull(Desig_Name,'-') as [TD],
												Status As [TD style="color:red;text-align:center;font-weight: bold;font-size: 14px;"]
										FROM    #Temp
										WHERE   Cmp_ID = @Cmp_Id and Isnull(Dept_Name,'') = @Department AND Status='A'
										ORDER BY Status,emp_Code For XML raw('tr'), ELEMENTS)
										
							SET @Body2 =
										
										(SELECT  
												emp_Code  as [TD],
												Emp_name  as [TD],
												Isnull(Dept_Name,'-') as [TD],
												Isnull(Desig_Name,'-') as [TD],
												Status As [TD style="color:GREEN;text-align:center;font-weight: bold;font-size: 14px;"]
										FROM    #Temp
										WHERE   Cmp_ID = @Cmp_Id and Isnull(Dept_Name,'') = @Department AND Status='P'
												
											 ORDER BY Status,emp_Code For XML raw('tr'), ELEMENTS) 
			                         

						   SET @Body = isnull(@Body,'') + isnull(@Body2,'')
			              
			                   
							   --if (@HREmail_ID <> '')
							   -- BEGIN
							   --    EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Orange', @recipients = @HREmail_ID,  @subject = 'Leave Approval Reminder', @body = @Body, @body_format = 'HTML'                               
			                       
							   -- END
							
			       			Set @Body = Replace(@Body, '_x0020_', space(1))
							Set @Body= Replace(@Body,'_x0022_','"')
							Set @Body= Replace(@Body,'_x003B_',';')
							Set @Body = Replace(@Body, '_x003D_', '=')
							--Set @Body = Replace(@Body, '<tr><TRRow>1</TRRow>', '<tr bgcolor="#C6CFFF">')
							--Set @Body = Replace(@Body, '<TRRow>0</TRRow>', '')
			       		
       					  SELECT  @Body = @TableHead + @Body + @TableTail  
			       		  
       					  Declare @subject as varchar(100)           
       					  Set @subject = 'Attendance Report ( ' + @Date + ' ) ( ' + @Department + ')'
       					  Declare @profile as varchar(50)
       					  set @profile = ''
       					  
       					  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = @Cmp_Id
       					  
       					  if isnull(@profile,'') = ''
       					  begin
       					  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = 0
       					  end
       					
       				IF(@ECount = 0 AND @EPCount = 0)
						BEGIN
							PRINT 'ABSENT / PRESENT EMPLOYEE COUNT IS ZERO'
						END
					ELSE
						BEGIN
							--EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Orange1', @recipients = @HREmail_ID, @subject = @subject, @body = @Body, @body_format = 'HTML',@copy_recipients = 'Rohit@orangewebtech.com'  
							EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile , @recipients = @DEPTMANAGEREMAIL_ID, @subject = @subject, @body = @Body, @body_format = 'HTML',@copy_recipients = @CC_Email    
							--EXEC msdb.dbo.sp_send_dbmail @profile_name = 'com-i2', @recipients = 'Rohit@orangewebtech.com', @subject = @subject, @body = @Body, @body_format = 'HTML'
						END  

					
					Set @HREmail_ID = ''
					Set @HR_Name = ''
					Set @ECount = 0
			
			
			fetch next from Cur_Department into @DEPT_ID
			end                    
			close Cur_Department
			deallocate Cur_Department
			
		 fetch next from Cur_Company into @Cmp_Id
	   end                    
	close Cur_Company                    
	deallocate Cur_Company         

End

