
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[LAST_ABSENTISM_REMINDER]
/* =============================================
	NOTE	: PLZ DO NOT DELETE THIS PORTION , IT EXPLAIN YOU REGARDING THE FUNCTIONALITY OF THIS JOB
	AUTHOR:			SHAIKH RAMIZ
	CREATED DATE:	08/08/2016
	DESCRIPTION:	THIS REPORT WILL PROVIDE THE LIST OF THOSE EMPLOYEES WHO ARE ABSENT FOR A PARTICULAR INTERVAL 
					(I.E LAST 60 DAYS).
					BUT WE HAVE ADDED SOME EXCEPTIONS IN THIS, THESE TYPES OF EMPLOYEES ARE NOT INCLUDED IN THIS.
					
					1) EMPLOYEES HAVE A TICK MARK ON FIX SALARY.
					2) EMPLOYEES WHOSE DESIGNATION IS 'DIRECTOR' , 'PRESIDENT' OR 'NATIONAL HEAD'.
 ============================================= */
@CMP_ID_PASS	NUMERIC(18,0) = 0,
@CC_EMAIL VARCHAR(500) = '',
@CON_ABSENT_DAYS NUMERIC(18,0) = 7
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	DECLARE @ECOUNT AS NUMERIC(18,0)
	DECLARE @HREMAIL_ID	NVARCHAR(4000)
	DECLARE @ROW_ID AS NUMERIC
	DECLARE @HR_NAME AS VARCHAR(255)
	DECLARE @EMP_CODE AS VARCHAR(100)
	DECLARE @EMPL_NAME AS VARCHAR(100)
	DECLARE @EMPL_BRANCH AS VARCHAR(100)
	DECLARE @EMPL_EMAIL_ID AS VARCHAR(100) 
	DECLARE @SUPERIOR_EMAIL_ID AS VARCHAR(100) 
	DECLARE @LAST_ATTENDED_DATE AS DATETIME
	DECLARE @ABSENT_DAYS_COUNT AS INTEGER
	DECLARE @Body AS VARCHAR(MAX) = ''
	DECLARE @COMPANY_NAME AS VARCHAR(255)
	DECLARE @PROFILE AS VARCHAR(50)
	SET @PROFILE = ''
	
	--HERE IT WILL CHECK THAT IF THE TEMPLATE IS PRESENT IN EMAIL FORMAT TABLE THEN IT WILL TAKE THAT TEMPLATE;
	--OTHER WISE IT WILL SEND THE DEFAULT FORMAT OF OUR EMAIL.
	DECLARE @TABLE_TEMPLATE AS  VARCHAR(MAX) = ''
	
	IF @CMP_ID_PASS = 0
		BEGIN
			IF EXISTS(	SELECT 1 FROM T0010_EMAIL_FORMAT_SETTING WITH (NOLOCK) WHERE EMAIL_TYPE='Last Absenteeism Reminder') 
				BEGIN
					DECLARE @TEMP_CMP_ID AS NUMERIC
					SELECT TOP 1 @TEMP_CMP_ID = CMP_ID FROM T0010_COMPANY_MASTER WITH (NOLOCK) WHERE IS_MAIN = 1
					SELECT @TABLE_TEMPLATE = EMAIL_SIGNATURE FROM dbo.T0010_EMAIL_FORMAT_SETTING WITH (NOLOCK) WHERE CMP_ID = @TEMP_CMP_ID AND EMAIL_TYPE='Last Absenteeism Reminder'
				END
		END
	ELSE
		BEGIN	
			IF EXISTS(SELECT 1 FROM T0010_EMAIL_FORMAT_SETTING WITH (NOLOCK) WHERE CMP_ID = @CMP_ID_PASS AND EMAIL_TYPE='Last Absenteeism Reminder')
				BEGIN
					SELECT @TABLE_TEMPLATE = EMAIL_SIGNATURE FROM dbo.T0010_EMAIL_FORMAT_SETTING WITH (NOLOCK) WHERE CMP_ID = @CMP_ID_PASS AND EMAIL_TYPE='Last Absenteeism Reminder'
				END
		END
	
	
IF @CMP_ID_PASS = 0
	SET @CMP_ID_PASS = NULL		
		
	IF OBJECT_ID('tempdb..#HR_Email') IS NOT NULL 
     BEGIN
           DROP TABLE #HR_Email
     END
         
	CREATE table #HR_Email
      ( 
		Row_Id INT IDENTITY(1, 1),
        Cmp_ID NUMERIC(18, 0),
        HR_Name Varchar(255),
        HR_Email_Id nvarchar(255)
      )   
      
	   --HERE TEMP TABLE IS CREATED
      IF OBJECT_ID('tempdb..#TEMP') IS NOT NULL 
         BEGIN
               DROP TABLE #TEMP
         END
       
       CREATE table #TEMP
      (	
		CMP_ID Numeric,
        EMP_ID NUMERIC(18, 0),
        EMPLOYEE_CODE VARCHAR(255),
        EMPLOYEE_NAME VARCHAR(255),
        BRANCH_NAME VARCHAR(255),
        DESIG_NAME VARCHAR(255),
        DEPT_NAME VARCHAR(255),
        LAST_ATTENDED_DATE DATETIME,
        ABSENT_DAYS_COUNT NUMERIC(18, 0),
        EMPLOYEES_EMAIL_ID VARCHAR(100),
        SUPERIOR_EMAIL_ID  VARCHAR(100),
        COMPANY_NAME VARCHAR(100)
      )   

		--DATA IS INSERTED IN TEMP TABLE
		INSERT INTO #TEMP(CMP_ID , EMP_ID,EMPLOYEE_CODE,EMPLOYEE_NAME,BRANCH_NAME , DESIG_NAME,DEPT_NAME,LAST_ATTENDED_DATE,ABSENT_DAYS_COUNT , EMPLOYEES_EMAIL_ID , SUPERIOR_EMAIL_ID , COMPANY_NAME)  	
		SELECT EM.CMP_ID , EM.EMP_ID , EM.Alpha_Emp_Code , EM.Emp_Full_Name ,BM.Branch_Name, DM.Desig_Name , DP.Dept_Name
		,ISNULL(Q2.LT_FOR_DATE, Q1.EIR_FOR_DATE) as Last_Attendend_Date
		,DATEDIFF(dd,ISNULL(Q2.LT_FOR_DATE, Q1.EIR_FOR_DATE) ,  GETDATE()) AS Total_Absent_Days ,
		RTRIM(LTRIM(EM.Work_Email)) + ';'+ RTRIM(LTRIM(EM.Other_Email)) as Other_Email, 
		RTRIM(LTRIM(VEM.P_Work_Mail)) as Superior_Email, 
		CM.CMP_NAME
		FROM T0080_EMP_MASTER EM WITH (NOLOCK)
		INNER JOIN T0095_INCREMENT INC WITH (NOLOCK) on INC.EMP_ID = EM.EMP_ID AND INC.CMP_ID = EM.CMP_ID
		INNER JOIN (
						SELECT	MAX(I2.Increment_ID) AS Increment_ID,I2.Emp_ID 
						FROM	T0095_Increment I2 WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I2.Emp_ID=E.Emp_ID
								INNER JOIN (
												SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
												FROM T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E3 WITH (NOLOCK) ON I3.Emp_ID=E3.Emp_ID	
												WHERE I3.Increment_effective_Date <= GETDATE()
												GROUP BY I3.EMP_ID  
											) I3 ON I2.Increment_Effective_Date=I3.Increment_Effective_Date AND I2.EMP_ID=I3.Emp_ID																																			
						GROUP BY I2.Emp_ID
					) I ON INC.Emp_ID = I.Emp_ID AND INC.Increment_ID = I.Increment_ID
		LEFT OUTER JOIN T0150_EMP_INOUT_RECORD EIR WITH (NOLOCK) ON EM.Emp_ID = EIR.Emp_ID  --- Change Inner join to left outer join by Hardik 07/09/2019 for Tradebull issue
		LEFT OUTER JOIN (														--- Change Inner join to left outer join by Hardik 07/09/2019 for Tradebull issue
					SELECT EIR1.EMP_ID , MAX(EIR1.FOR_DATE) AS EIR_FOR_DATE 
					FROM T0150_EMP_INOUT_RECORD EIR1 WITH (NOLOCK)
					GROUP BY EIR1.EMP_ID
					)Q1 ON EM.EMP_ID = Q1.EMP_ID 
		LEFT OUTER JOIN 
					(
					SELECT LT.Emp_ID , MAX(LT.For_Date) AS LT_FOR_DATE
					FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
					WHERE LT.Leave_Used <> 0
					GROUP BY LT.EMP_ID
					)Q2 ON EM.Emp_ID = Q2.Emp_ID AND Q2.LT_FOR_DATE > Q1.EIR_FOR_DATE
		INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Bm.Branch_ID = inc.Branch_ID AND INC.Cmp_ID = bm.Cmp_ID
		INNER JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON DM.DESIG_ID = INC.DESIG_ID AND iNC.Cmp_ID = dm.Cmp_ID 
				AND (DM.DESIG_NAME NOT LIKE '%DIRECTOR%' AND DM.DESIG_NAME NOT LIKE '%PRESIDENT%' AND DM.DESIG_NAME NOT LIKE '%NATIONAL HEAD%')  --Excluding some Higher Authorities as per Client's Requirements
		LEFT JOIN T0040_DEPARTMENT_MASTER DP WITH (NOLOCK) ON DP.DEPT_ID = INC.DEPT_ID AND INC.Cmp_ID = DP.Cmp_Id
		INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON INC.Cmp_ID = CM.Cmp_Id
		INNER JOIN V0080_EMPLOYEE_MASTER VEM ON VEM.EMP_ID = EM.EMP_ID AND VEM.INCREMENT_ID = INC.INCREMENT_ID
		WHERE INC.Cmp_ID = ISNULL(@CMP_ID_PASS,INC.Cmp_ID) and INC.Emp_Fix_Salary <> 1 and Em.EMP_LEFT <> 'Y' 
			AND DATEDIFF(dd,ISNULL(ISNULL(Q2.LT_FOR_DATE, Q1.EIR_FOR_DATE),CM.FROM_DATE) ,  GETDATE()) >= @CON_ABSENT_DAYS -- Condition of CM.From_Date added by Hardik 07/09/2019 as in Tradebull one employee name not coming as no any inout and leave
		GROUP BY em.cmp_iD , EM.EMP_ID , EM.ALPHA_EMP_CODE, EM.EMP_FULL_NAME,BM.BRANCH_NAME, DM.DESIG_NAME , DP.DEPT_NAME,  
				Q2.LT_FOR_DATE,Q1.EIR_FOR_DATE ,EM.Work_Email,  EM.Other_Email , VEM.P_Work_Mail , CM.CMP_NAME
	
	--Send HR NAME in Report
		INSERT INTO #HR_EMAIL
		SELECT E.CMP_ID , EMP_FULL_NAME , WORK_EMAIL
		FROM T0011_LOGIN L WITH (NOLOCK) LEFT OUTER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON L.EMP_ID = E.EMP_ID
		WHERE L.IS_HR = 1 and E.Cmp_ID IN  (SELECT DISTINCT CMP_ID FROM #TEMP)
		ORDER BY CMP_ID
		


	--THIS CURSOR WILL SEND EMAIL TO HR TO ALL COMPANIES	 
	DECLARE CUR_COMPANY CURSOR FOR                    
		SELECT Row_Id FROM #HR_EMAIL ORDER BY Row_Id
	OPEN CUR_COMPANY                      
	FETCH NEXT FROM CUR_COMPANY INTO @ROW_ID
	WHILE @@FETCH_STATUS = 0                    
		BEGIN
			
		SELECT @HREMAIL_ID = HR_EMAIL_ID, @HR_NAME = HR_NAME from #HR_EMAIL where Row_Id = @ROW_ID
		SELECT @ECount = COUNT(emp_id) FROM #Temp
		 
		   Declare  @TableHead varchar(max),
					   @TableTail varchar(max)   
           		  
           		  Set @TableHead = '<html><head>' +
								  '<style>' +
								  'td {border: solid black 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:8pt;} ' +
								  '</style>' +
								  '</head>' +
								  '<body>
								  <div style=" font-family:Arial, Helvetica, sans-serif; color:#000000;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">
								  Dear ' + @HR_NAME + ' </div>	<br/>					
								  
								  <table width="800" border="0" align="center" cellpadding="0" cellspacing="0" style="border:1px solid #cacaca; border-radius: 10px 10px 10px 10px;" >
								  <tr>
									 <td align="center" valign="middle"><table width="800" border="0" cellspacing="0" cellpadding="0">
										<tr>
										<td height="9" align="center" valign="middle" ></td>
										</tr>
									  <tr>
										<td width="800" height="24" align="center" valign="middle" style="background:#0b0505; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">NO. OF EMPLOYEES NEED TO LEFT: [ ' + CAST(@ECount AS VARCHAR(255)) + ' ]</td>
									  </tr>
								  </table>
                                    
								  <table border="1" width="800" height="24" align="center" valign="middle" style="background: #FFFFF;border-color:solid black;
									border-radius: 10px 10px 10px 10px; font-family: Arial, Helvetica, sans-serif;
									color: #000000; text-decoration: none; font-weight: normal; text-align: left;
									font-size: 12px;">' +
										  '<tr border="1"><td align=center><span style="font-size:small"><b> CODE</b></span></td>' +
										  '<td align=center><b><span style="font-size:small">EMPLOYEES NAME</span></b></td>' +
										  '<td align=center><b><span style="font-size:small">BRANCH </span></b></td>' +
										  '<td align=center><b><span style="font-size:small">DESIGNATION </span></b></td>' +
										  '<td align=center><b><span style="font-size:small">DEPARTMENT </span></b></td>' +
										  '<td align=center><b><span style="font-size:small">LAST ATTENDED DATE</span></b></td>' +
										  '<td align=center><b><span style="font-size:small">ABSENT DAYS COUNT</span></b></td>'
										                                     
                  SET @TableTail = '</table><table><tr><td align=center>Report Generated from Orange Payroll</td></tr></table></body></html>';                  	
                  
                         
                  SET @Body = ( SELECT  
										EMPLOYEE_CODE  as [TD],
										EMPLOYEE_NAME  as [TD],
										BRANCH_NAME as [TD],
										DESIG_NAME as [TD],
										DEPT_NAME as [TD],
										LEFT(REPLACE(CONVERT(VARCHAR(25), LAST_ATTENDED_DATE,106),' ','-'),20) As [TD],
										ABSENT_DAYS_COUNT as [TD]
                                FROM    #Temp
                                ORDER BY ABSENT_DAYS_COUNT DESC
                                 For XML raw('tr'), ELEMENTS) 
				
			SELECT  @Body = @TableHead + @Body + @TableTail 
			
			
			
			IF ISNULL(@PROFILE,'') = ''
			  BEGIN
				SELECT @PROFILE = ISNULL(DB_MAIL_PROFILE_NAME,'') FROM T9999_REMINDER_MAIL_PROFILE WITH (NOLOCK) WHERE CMP_ID = @CMP_ID_PASS
			  END

			IF EXISTS(SELECT 1 FROM #TEMP)
				BEGIN
					EXEC msdb.dbo.sp_send_dbmail @profile_name = @PROFILE, @recipients = @HREMAIL_ID, @subject = 'LAST ABSENTISM REPORT', @body = @Body, @body_format = 'HTML' , @copy_recipients = @CC_EMAIL                                         
				END
			
			SET @HREMAIL_ID = ''
			SET @HR_NAME = ''
			SET @ECOUNT = 0
			
		 FETCH NEXT FROM CUR_COMPANY INTO @ROW_ID
	   END                    
	CLOSE CUR_COMPANY                    
	DEALLOCATE CUR_COMPANY   
	--HR CURSOR ENDS HERE--

	
	--THIS CURSOR WILL SEND EMAIL TO PARTICULAR EMPLOYEES
	DECLARE CUR_EMPLOYEE CURSOR FOR                    
		SELECT COMPANY_NAME , EMPLOYEE_CODE , EMPLOYEE_NAME , BRANCH_NAME , LAST_ATTENDED_DATE , EMPLOYEES_EMAIL_ID , SUPERIOR_EMAIL_ID FROM #TEMP ORDER BY EMP_ID
	OPEN CUR_EMPLOYEE                      
		FETCH NEXT FROM CUR_EMPLOYEE INTO @COMPANY_NAME , @EMP_CODE , @EMPL_NAME , @EMPL_BRANCH , @LAST_ATTENDED_DATE , @EMPL_EMAIL_ID , @SUPERIOR_EMAIL_ID
		WHILE @@FETCH_STATUS = 0
			BEGIN
			
			IF (@TABLE_TEMPLATE <> '')
				BEGIN
					SELECT @BODY = @TABLE_TEMPLATE
					SELECT @BODY = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@BODY , '#EmployeeName#' , '' + @EMPL_NAME + ''),'#EmpCode#' , '' + @EMP_CODE +''),'#Branch#','' + @EMPL_BRANCH +''),'#Last_Attended_Date#','' + REPLACE(CONVERT(VARCHAR, @LAST_ATTENDED_DATE, 106) , ' ' , '-') +''),'#Signature#' , '' + @COMPANY_NAME + '')
				END
			ELSE
				BEGIN
					SET @TableHead = '<html><head>' +
									  '</head>' +
									  '<body>
									  <div>
									  Dear <b>' + @EMPL_NAME + '</b>,
									  <p>
										E-Code :- <b>'+ @EMP_CODE +'</b><br />
										Branch :- <b>'+ @EMPL_BRANCH +'</b>
									  <p>
									  </div>
									  '
					 SET @Body = '	<p>
										It has been observed from our attendance record that you have remained absent from <b>'+ REPLACE(CONVERT(VARCHAR, @LAST_ATTENDED_DATE, 106) , ' ' , '-') +'</b> without any prior intimation or leave application. 
									<p>
									<p style="text-align:justify">
										Absenting yourself from duties without prior intimation is a mis-conduct for which necessary actions can be initiated on you.
									<p>
									<p style="text-align:justify">
										Please Consider this as a Formal Warning regarding your un-notified Absence in the system.
									<p>
									<p style="text-align:justify">
										If you fail to Respond to this warning letter within <b> 24 Hours </b> of its receipt,  we will have no choice but to hold your salary for the current month.
									</p>
									<p style="text-align:justify">
										Regards,
										<br />
										<br />
										Human Resource Department
									</p>
									<p>
										<b>'+ @COMPANY_NAME +'</b>
									</p>
									</body>
									</html>
									'				 
					SELECT  @BODY = @TABLEHEAD + @BODY
					
				END
		
			IF ISNULL(@PROFILE,'') = ''
			  BEGIN
				SELECT @PROFILE = ISNULL(DB_MAIL_PROFILE_NAME,'') FROM T9999_REMINDER_MAIL_PROFILE WITH (NOLOCK) WHERE CMP_ID = ISNULL(@CMP_ID_PASS,0)
			  END
			  
			   IF @CC_EMAIL <> ''
					SET @SUPERIOR_EMAIL_ID = @SUPERIOR_EMAIL_ID + ';' + @CC_EMAIL
					
				 IF @EMPL_EMAIL_ID <>''
					BEGIN
						EXEC msdb.dbo.sp_send_dbmail @profile_name = @PROFILE, @recipients = @EMPL_EMAIL_ID, @subject = 'Warning Letter For Absenteeism', @body = @Body, @body_format = 'HTML' , @copy_recipients = @SUPERIOR_EMAIL_ID                                
					END
						
						Set @EMPL_EMAIL_ID = ''
		
			
			FETCH NEXT FROM CUR_EMPLOYEE INTO @COMPANY_NAME , @EMP_CODE , @EMPL_NAME , @EMPL_BRANCH , @LAST_ATTENDED_DATE , @EMPL_EMAIL_ID , @SUPERIOR_EMAIL_ID
			END
	CLOSE CUR_EMPLOYEE                    
	DEALLOCATE CUR_EMPLOYEE
		
END

