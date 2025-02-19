

-- =============================================
-- Author:		Shaikh Ramiz
-- Create date: 12th-Jan-2017
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_Branchwise_Attendance_Summary]
	@CMP_ID_PASS		NUMERIC,
	@DATE		DATETIME = '1900-01-01',
	@TO_EMAIL VARCHAR(500) = '',
	@CC_EMAIL VARCHAR(500) = ''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

	IF IsNull(@DATE, '1900-01-01') = '1900-01-01'
	SET @DATE  = CONVERT(DATETIME, CONVERT(VARCHAR(10), GETDATE(), 103), 103)
    
     IF OBJECT_ID('tempdb..#Temp') IS NOT NULL 
         BEGIN
               DROP TABLE #Temp
         END
       
     CREATE table #Temp 
			(
			Cmp_Id Numeric,
			Emp_Id numeric,
			Emp_Code varchar(100),
			Emp_Name varchar(200),
			Desig_Name varchar(100),
			Dept_Name Varchar(100),
			For_Date Datetime,
			Status varchar(10),
			Branch_name varchar(100)
			) 
	IF OBJECT_ID('tempdb..#BRANCH') IS NOT NULL 
         BEGIN
               DROP TABLE #BRANCH
         END
        
    
	 INSERT INTO #Temp
     EXEC [SP_Get_Present_Absent_Emp_List] @CMP_ID_PASS,@DATE
	
	
		SELECT DISTINCT BRANCH_NAME , ROW_NUMBER() OVER(ORDER BY BRANCH_NAME ASC) AS ROW INTO #BRANCH 
		FROM #TEMP
		GROUP BY BRANCH_NAME
		UNION ALL
		SELECT '--All Branches--' , 99999

	
	SELECT * INTO #TEMPLATE 
	FROM
	(
		SELECT TOP 100 PERCENT B.ROW ,B.Branch_name , ISNULL(PR.Total_Present,0) AS Total_Present , ISNULL(AB.Total_Absent,0) AS Total_Absent , 
		ISNULL(L.Total_On_Leave , 0) AS Total_On_Leave
		FROM #BRANCH B
		LEFT OUTER JOIN 
			(	
				SELECT ISNULL(BRANCH_NAME,'--All Branches--') as  BRANCH_NAME ,  COUNT(STATUS) as Total_Present
				FROM #TEMP
				WHERE Status = 'P'
				GROUP BY ROLLUP(Branch_name)
			) PR ON PR.Branch_name = B.Branch_name
		LEFT OUTER JOIN 
			(
				SELECT ISNULL(BRANCH_NAME,'--All Branches--') as  BRANCH_NAME  ,  COUNT(STATUS) as Total_Absent
				FROM #TEMP
				WHERE Status = 'A'
				GROUP BY ROLLUP(Branch_name)
			) AB ON AB.Branch_name = B.Branch_name
		LEFT OUTER JOIN 
			(
				SELECT ISNULL(BRANCH_NAME,'--All Branches--') as  BRANCH_NAME  ,  COUNT(STATUS) as Total_On_Leave
				FROM #TEMP
				WHERE Status = 'L' or Status = 'OD'
				GROUP BY ROLLUP(Branch_name)
			) L ON L.Branch_name = B.Branch_name		
	)T
	ORDER BY ROW
	
	  Declare  @TableHead varchar(max)
	  Declare @TableTail varchar(max)   
	  
	  Set @TableHead = '<html><head>' +
								  '<style>' +
								  'td {border: solid black 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:8pt;} ' +
								  '</style>' +
								  '</head>' +
								  '<body>			
								  <table width="800" border="0" align="center" cellpadding="0" cellspacing="0" style="border:1px solid #cacaca; border-radius: 10px 10px 10px 10px;" >
								  <tr>
									 <td align="center" valign="middle"><table width="800" border="0" cellspacing="0" cellpadding="0">
										<tr>
										<td height="9" align="center" valign="middle" ></td>
										</tr>
									  <tr>
										<td width="800" height="24" align="center" valign="middle" style="background:#0b0505; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;"> Attendance Summary of : [ ' + REPLACE(CONVERT(VARCHAR(20) , @DATE , 106) , ' ' , '-') + ' ]</td>
									  </tr>
								  </table>
                                    
								  <table border="1" width="800" height="24" align="center" valign="middle" style="background: #FFFFF;border-color:solid black;
									border-radius: 10px 10px 10px 10px; font-family: Arial, Helvetica, sans-serif;
									color: #000000; text-decoration: none; font-weight: normal; text-align: left;
									font-size: 12px;">' +
										  '<tr border="1">' +
										  '<td align=center><b><span style="font-size:small">BRANCH NAME</span></b></td>' +
										  '<td align=center><b><span style="font-size:small">PRESENT</span></b></td>' +
										  '<td align=center><b><span style="font-size:small">ABSENT</span></b></td>' +
										  '<td align=center><b><span style="font-size:small">LEAVE</span></b></td>'
                  SET @TableTail = '</table><table><tr><td align=center>Report Sent from Orange Payroll</td></tr></table></body></html>';                  	
                  
                  DECLARE @Body AS VARCHAR(MAX)       
                  SET @Body = ( SELECT  
										Branch_name  as [TD],
										Total_Present as [TD],
										Total_Absent as [TD],
										Total_On_Leave AS [TD]
                                FROM    #TEMPLATE
                                ORDER BY ROW
                                 For XML raw('tr'), ELEMENTS) 
				
				
           			
           		  SELECT  @Body = @TableHead + @Body + @TableTail 

			IF EXISTS(SELECT 1 FROM #TEMPLATE)
				BEGIN
					EXEC msdb.dbo.sp_send_dbmail @profile_name = 'ORANGEHRMS', @recipients = @TO_EMAIL, @subject = 'Branch Wise Attendance Summary', @body = @Body, @body_format = 'HTML' , @copy_recipients = @CC_EMAIL
				END
	
	
END

