
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Employee_Daily_Absent_Reminder_Branch_Wise]
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
      
      
       
      IF OBJECT_ID('tempdb..#Temp') IS NOT NULL 
         BEGIN
               DROP TABLE #Temp
         END
       
     CREATE table #Temp (
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
            
		--Insert Into #Temp
		--	(Emp_ID,Emp_code,Emp_name,Status) 
			 
		--	exec SP_TODAYS_PRESENT_GET @Cmp_ID=1,@branch_ID=0,@Todate=cast(getdate() as varchar(11)),@Type='X'
            
      CREATE table #HR_Email
      ( 
		Row_Id INT IDENTITY(1, 1),
        Cmp_ID NUMERIC(18, 0)
      )   

            
	 INSERT    INTO #Temp
     exec [SP_Get_Present_Absent_Emp_List] @cmp_id_Pass,@DATE

	
	Delete #Temp Where Status <> 'A'
	


	Insert Into #HR_Email (Cmp_ID)
	Select Cmp_Id From #Temp Group by Cmp_ID

	Declare @HREmail_ID	nvarchar(4000)
	Declare @Cmp_Id as numeric
	Declare @HR_Name as varchar(255)
	Declare @ECount as numeric
	Declare @Branch as varchar(255)
	
	declare Cur_Company cursor for                    
		select Cmp_Id from #HR_Email order by Cmp_ID
	open Cur_Company                      
	fetch next from Cur_Company into @Cmp_Id
	while @@fetch_status = 0                    
		begin     
				
				declare Cur_Branch cursor for                    
				select  Branch_Name as Branch from T0030_Branch_master WITH (NOLOCK)
				where Cmp_id = @Cmp_Id order by Branch_name
				open Cur_Branch                      
				fetch next from Cur_Branch into @Branch
				while @@fetch_status = 0                    
				begin     
			
					SELECT TOP 1 @HREmail_ID = Email_ID, @HR_Name = Emp_Full_Name
					FROM T0011_LOGIN L WITH (NOLOCK) Left Outer Join T0080_EMP_MASTER E WITH (NOLOCK) on L.Emp_ID = E.Emp_ID
					Where L.Cmp_ID=@Cmp_ID AND Is_HR = 1

					Select @ECount = COUNT(Emp_Id) From #Temp where Cmp_ID = @Cmp_Id and branch_name = @branch

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
												<td width="800" height="24" align="center" valign="middle" style="background:#0b0505; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">Today''s Absent Report ( ' + @Date + ') for ' + @Branch + ' </td>
											  </tr>
												  <tr>
													<td height="4" align="center" valign="middle"></td>
												  </tr>
												  <tr>
													<td width="800" align="center" valign="middle" style="border:1px solid #cacaca; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#000000;  text-decoration:none; text-align:center; font-size:12px;">Total Absent Employees : [ ' + CAST(@ECount AS VARCHAR(255)) + ' ] </td>
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
												  '<td align=center><b><span style="font-size:small">Status</span></b></td>'
												                                     
						  SET @TableTail = '</table></body></html>';                  	
						  DECLARE @Body AS VARCHAR(MAX)
						  SET @Body = ( SELECT  
												emp_Code  as [TD],
												Emp_name  as [TD],
												Isnull(Dept_Name,'-') as [TD],
												Isnull(Desig_Name,'-') as [TD],
												Status As [TD]
										FROM    #Temp
										WHERE   Cmp_ID = @Cmp_Id and Isnull(Branch_name,'') = @Branch ORDER BY  Emp_code For XML raw('tr'), ELEMENTS) 
			                         


							   --if (@HREmail_ID <> '')
							   -- BEGIN
							   --    EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Orange', @recipients = @HREmail_ID,  @subject = 'Leave Approval Reminder', @body = @Body, @body_format = 'HTML'                               
			                       
							   -- END
							
			       			
       					  SELECT  @Body = @TableHead + @Body + @TableTail  
			       		  
       					  Declare @subject as varchar(100)           
       					  Set @subject = 'Absent Report ( ' + @Date + ' ) ( ' + @Branch + ')'
       					  Declare @profile as varchar(50)
       					  set @profile = ''
       					  
       					  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = @Cmp_Id
       					  
       					  if isnull(@profile,'') = ''
       					  begin
       					  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = 0
       					  end
       					  
			       		    		 	           			              

					--EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Orange1', @recipients = @HREmail_ID, @subject = @subject, @body = @Body, @body_format = 'HTML',@copy_recipients = 'Rohit@orangewebtech.com'  
					EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile , @recipients = @HREmail_ID, @subject = @subject, @body = @Body, @body_format = 'HTML',@copy_recipients = @CC_Email    
					--EXEC msdb.dbo.sp_send_dbmail @profile_name = 'com-i2', @recipients = 'Rohit@orangewebtech.com', @subject = @subject, @body = @Body, @body_format = 'HTML'

					Set @HREmail_ID = ''
					Set @HR_Name = ''
					Set @ECount = 0
			
			
			fetch next from Cur_Branch into @Branch
			end                    
			close Cur_Branch
			deallocate Cur_Branch
			
		 fetch next from Cur_Company into @Cmp_Id
	   end                    
	close Cur_Company                    
	deallocate Cur_Company         

End

