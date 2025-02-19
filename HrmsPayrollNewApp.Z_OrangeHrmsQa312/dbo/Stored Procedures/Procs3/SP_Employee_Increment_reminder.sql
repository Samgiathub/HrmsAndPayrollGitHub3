
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Employee_Increment_reminder]
@cmp_id_Pass Numeric(18,0) = 0,
@CC_Email Nvarchar(max) = ''
AS 
BEGIN   


SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	 DECLARE @DATE VARCHAR(11)   
     DECLARE @Approval_day AS NUMERIC    
     DECLARE @ReminderTemplate AS NVARCHAR(4000)
     SET @DATE = CAST(GETDATE() AS varchar(11))
     
           
      if @cmp_id_Pass = 0
		 set @cmp_id_Pass = null
     
     IF OBJECT_ID('tempdb..#Temp_Cmp') IS NOT NULL
		Begin
			DROP TABLE #Temp_Cmp
		End      
      
     IF OBJECT_ID('tempdb..#Temp') IS NOT NULL 
         BEGIN
               DROP TABLE #Temp
         END
        
        Create table #Temp_Cmp
        ( 
			Cmp_ID NUMERIC(18,0),
			Mail_Send_Days Numeric(18,0)
		)    
        Insert into #Temp_Cmp(Cmp_ID,Mail_Send_Days)(SELECT Cmp_ID,Setting_Value From T0040_SETTING WITH (NOLOCK) where Setting_Name='Send Remainder mail of Increment')
		
                     
		CREATE table #Temp 
		(
			Cmp_Id Numeric,
			Emp_Id numeric,
			Emp_Code varchar(100),
			Emp_Name varchar(200),
			Desig_Name varchar(100),
			Dept_Name Varchar(100),
			Increment_Date Datetime,
			Branch_name varchar(100),
			Temp varchar(100)
		) 
		INSERT    INTO #Temp
		(
			Cmp_Id,
			Emp_Id,
			Emp_Code,
			Emp_Name,
			Desig_Name,
			Dept_Name,
			Increment_Date,
			Branch_name,
			Temp
		)
		(Select
			M.Cmp_ID,
			M.Emp_ID,
			M.Alpha_Emp_Code,
			M.Emp_Full_Name,
			M.Desig_Name,
			M.Dept_Name,
			CONVERT(DATETIME,qry1.Increment_Effective_Date,103) as Increment_Date,
			M.Branch_Name,
			Mail_Send_Days
			from v0080_employee_master M  Inner JOIN 
			(
				SELECT MAX(I.Increment_Effective_Date) as Increment_Effective_Date ,I.Emp_ID as Emp_ID FROM v0080_employee_master EM INNER JOIN  T0095_INCREMENT I WITH (NOLOCK) on EM.Cmp_ID = I.Cmp_ID 
				and EM.Emp_ID = I.Emp_ID
				where  I.Increment_Type = 'Increment'  or I.Increment_Type = 'Joining'
				GROUP BY I.Emp_ID
			)  as qry1 ON qry1.Emp_ID = M.Emp_ID
			INNER JOIN #Temp_Cmp TC on M.Cmp_ID = TC.Cmp_ID
		    Where M.cmp_id = isnull(@cmp_id_Pass,M.Cmp_ID) and
		    -- dateadd(yyyy,1,qry1.Increment_Effective_Date) = CONVERT(DATETIME, CONVERT(varchar(10), dateadd(dd,(-1*Mail_Send_Days),GETDATE()), 101)) 
		    CONVERT(DATETIME, CONVERT(varchar(20) ,dateadd(dd,-1*Mail_Send_Days,dateadd(yyyy,1,qry1.Increment_Effective_Date)),101)) = CONVERT(DATETIME, CONVERT(varchar(20),GETDATE(), 101)) 
		    and dateadd(yyyy,1,qry1.Increment_Effective_Date) <= case when isnull(M.Date_of_Retirement,'') = '' THEN dateadd(yyyy,1,qry1.Increment_Effective_Date) ELSE M.Date_of_Retirement end
			And Isnull(M.Emp_Left,'N') = 'N'
		)
 
      CREATE table #HR_Email
      ( 
		Row_Id INT IDENTITY(1, 1),
        Cmp_ID NUMERIC(18, 0)
      )   
	Select * From #Temp
	Insert Into #HR_Email (Cmp_ID)
	Select Cmp_Id From #Temp Group by Cmp_ID 

	Declare @HREmail_ID	nvarchar(4000)
	Declare @Cmp_Id as numeric
	Declare @HR_Name as varchar(255)
	Declare @ECount as numeric
	
	
	declare Cur_Company cursor for                    
		select Cmp_Id from #HR_Email order by Cmp_ID
	open Cur_Company                      
	fetch next from Cur_Company into @Cmp_Id
	while @@fetch_status = 0                    
		begin     
				
			SELECT TOP 1 @HREmail_ID = Email_ID, @HR_Name = Emp_Full_Name
			FROM T0011_LOGIN L WITH (NOLOCK) Left Outer Join T0080_EMP_MASTER E WITH (NOLOCK) on L.Emp_ID = E.Emp_ID
			Where L.Cmp_ID=@Cmp_ID AND Is_HR = 1
			
			--Declare @Mail_Days
			--select @Mail_Days = Setting_Value from T0040_SETTING where cmp_id = @Cmp_ID and Setting_Name='Send Remainder mail of Increment'
			
			Select @ECount = COUNT(Emp_Id) From #Temp where Cmp_ID = @Cmp_Id

			  ---ALTER dynamic template for Employee.				
		      Declare  @TableHead varchar(max),
					   @TableTail varchar(max)   
           		  Set @TableHead = '<html><head>' +
								  '<style>' +
								  'td {border: solid black 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:8pt;} ' +
								  '</style>' +
								  '</head>' +
								  '<body>
								  <div style=" font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">
								  Dear ' + @HR_Name + ' </div>	<br/>					
								  
								  <table width="800" border="0" align="center" cellpadding="0" cellspacing="0" style="border:1px solid #cacaca; border-radius: 10px 10px 10px 10px;" >
								  <tr>
									 <td align="center" valign="middle"><table width="800" border="0" cellspacing="0" cellpadding="0">
										<tr>
										<td height="9" align="center" valign="middle" ></td>
										</tr>
									  <tr>
										<td width="800" height="24" align="center" valign="middle" style="background:#0b0505; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">Due for Increment Report ( ' + @Date + ') </td>
									  </tr>
										  <tr>
											<td height="4" align="center" valign="middle"></td>
										  </tr>
										  <tr>
											<td width="800" align="center" valign="middle" style="border:1px solid #cacaca; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#000000;  text-decoration:none; text-align:center; font-size:12px;">Total Eligible Employees For Increments: [ ' + CAST(@ECount AS VARCHAR(255)) + ' ] </td>
										  </tr>
										  <tr>
											<td height="8" align="center" valign="middle"></td>
										  </tr>
								  </table>
                                    
								  <table border="1" width="800" height="24" align="center" valign="middle" style="background: #FFFFF;border-color:solid black;
									border-radius: 10px 10px 10px 10px; font-family: Arial, Helvetica, sans-serif;
									color: #000000; text-decoration: none; font-weight: normal; text-align: left;
									font-size: 12px;">' +
										  '<tr border="1"><td align=center><span style="font-size:small"><b>Code</b></span></td>' +
										  '<td align=center><b><span style="font-size:small">Employee Name</span></b></td>' +
										  '<td align=center><b><span style="font-size:small">Department</span></b></td>' +
										  '<td align=center><b><span style="font-size:small">Designation</span></b></td>' +
										  '<td align=center><b><span style="font-size:small">Last Increment Date</span></b></td>'
										                                     
                  SET @TableTail = '</table></body></html>';                  	
                  DECLARE @Body AS VARCHAR(MAX)
                  SET @Body = ( SELECT  
										Emp_Code  as [TD],
										Emp_Name  as [TD],
										Isnull(Dept_Name,'-') as [TD],
										Isnull(Desig_Name,'-') as [TD],
										convert(varchar(11),Increment_Date,101) As [TD]
                                FROM    #Temp
                                WHERE   Cmp_ID = @Cmp_Id ORDER BY  Emp_code For XML raw('tr'), ELEMENTS) 
                             
  
  
                       --if (@HREmail_ID <> '')
                       -- BEGIN
                       --    EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Orange', @recipients = @HREmail_ID,  @subject = 'Leave Approval Reminder', @body = @Body, @body_format = 'HTML'                               
                           
                       -- END
					
           			
           		  SELECT  @Body = @TableHead + @Body + @TableTail  
           		  
           		  Declare @subject as varchar(100)           
           		  Set @subject = 'Increment Report ( ' + @Date + ' )'
           		  
           		    Declare @profile as varchar(50)
       					  set @profile = ''
       					  
       					  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = @Cmp_Id
 					  
       					  if isnull(@profile,'') = ''
       					  begin
       					  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = 0
       					  end
           		    		 	           			              
			
			--EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Orange', @recipients = @HREmail_ID, @subject = @subject, @body = @Body, @body_format = 'HTML'
			EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @HREmail_ID, @subject = @subject, @body = @Body, @body_format = 'HTML',@copy_recipients = @CC_Email
			--EXEC msdb.dbo.sp_send_dbmail @profile_name = 'com-i2', @recipients = 'Rohit@orangewebtech.com', @subject = 'Today''s Attendance', @body = @Body, @body_format = 'HTML',@copy_recipients = 'hardik@orangewebtech.com'  

			Set @HREmail_ID = ''
			Set @HR_Name = ''
			Set @ECount = 0
			
		 fetch next from Cur_Company into @Cmp_Id
	   end                    
	close Cur_Company                    
	deallocate Cur_Company 
End


