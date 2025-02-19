

-- Created by rohit For Employee Contract Over Reminder to Hr Email on 28112013
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Employee_Contract_Reminder]
@cmp_id_Pass Numeric(18,0) = 0,
@CC_Email Nvarchar(max) = ''
AS 

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN   

	  DECLARE @DATE VARCHAR(20)   
      DECLARE @Approval_day AS NUMERIC    
      DECLARE @ReminderTemplate AS NVARCHAR(4000)
      SET @DATE = RIGHT(CAST(GETDATE() AS DATETIME), 5)      
      
      
       if @cmp_id_Pass = 0
		 set @cmp_id_Pass = null
      
      IF OBJECT_ID('tempdb..#Temp') IS NOT NULL 
         BEGIN
               DROP TABLE #Temp
         END
       
      CREATE table #Temp
      ( 
		CON INT IDENTITY(1, 1),
        Cmp_ID NUMERIC(18, 0),
        Emp_ID NUMERIC(18, 0),
        Emp_code VARCHAR(255),
        Emp_name VARCHAR(255),
        Branch_Name Varchar(255),
		Contract_End_Date Datetime
        
      )   
      
      CREATE table #HR_Email
      ( 
		Row_Id INT IDENTITY(1, 1),
        Cmp_ID NUMERIC(18, 0)
      )   

          
            
	 INSERT    INTO #Temp
                ( Cmp_ID,
                  Emp_ID,
                  Emp_code,
                  Emp_name,
                  Branch_Name,
				  Contract_End_Date
                  
                )
                (
                Select 
                EM.Cmp_ID,
                EM.Emp_ID,
                EM.Alpha_Emp_Code,
                EM.Emp_Full_Name,
                BM.Branch_Name,
                Ecd.End_Date
            
				from t0090_Emp_Contract_DEtail ECD  WITH (NOLOCK) inner join 
				t0080_Emp_Master EM WITH (NOLOCK) on ECD.Emp_ID=EM.Emp_ID inner join 
				T0095_increment I WITH (NOLOCK) ON EM.Increment_ID=I.Increment_ID inner join 
				T0030_Branch_Master BM WITH (NOLOCK) On I.Branch_ID = BM.Branch_ID   inner join 
				t0040_general_setting GS WITH (NOLOCK) on I.Branch_ID=GS.Branch_ID  And isnull(ECD.Is_Reminder, 0) = 1 And 
				DateAdd(d, isnull(Con_Reim_Days, 0), Getdate()) >= ECD.End_Date And 
				left(ECD.End_Date,10) >= left(Getdate(),10)  and ECD.cmp_id = ISNULL(@cmp_id_Pass,ECD.cmp_id) 
                )  
                
		
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
										<td width="800" height="24" align="center" valign="middle" style="background:#0b0505; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">Employee Contract Over Reminder</td>
									  </tr>
										  <tr>
											<td height="4" align="center" valign="middle"></td>
										  </tr>
										  <tr>
											<td width="800" align="center" valign="middle" style="border:1px solid #cacaca; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#000000;  text-decoration:none; text-align:center; font-size:12px;">No Of Employee Contract Over : [ ' + CAST(@ECount AS VARCHAR(255)) + ' ] </td>
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
										  '<td align=center><b><span style="font-size:small">Branch Name</span></b></td>' +
										  '<td align=center><b><span style="font-size:small">Contract End Date</span></b></td>' 
										 
										                                     
                  SET @TableTail = '</table></body></html>';                  	
                  DECLARE @Body AS VARCHAR(MAX)
                  SET @Body = ( SELECT  
										emp_Code  as [TD],
										Emp_name  as [TD],
										Isnull(Branch_Name,'-') as [TD],
										Left(Convert(varchar(25), Contract_End_Date,113),11) As [TD]
										
                                FROM    #Temp
                                WHERE   Cmp_ID = @Cmp_Id ORDER BY  RIGHT(REPLICATE(N' ', 500) + emp_Code, 500) For XML raw('tr'), ELEMENTS) 
                             
  
  
                       --if (@HREmail_ID <> '')
                       -- BEGIN
                       --    EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Orange', @recipients = @HREmail_ID,  @subject = 'Leave Approval Reminder', @body = @Body, @body_format = 'HTML'                               
                           
                       -- END
					
           			
           		  SELECT  @Body = @TableHead + @Body + @TableTail              		 	           			              
           		  
           		     Declare @profile as varchar(50)
       					  set @profile = ''
       					  
       					  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = @Cmp_Id
       					  
       					  if isnull(@profile,'') = ''
       					  begin
       					  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = 0
       					  end  	

			EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @HREmail_ID, @subject = 'Employee Contract Over ', @body = @Body, @body_format = 'HTML',@copy_recipients = @CC_Email
			--EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Orange', @recipients = 'rohit@orangewebtech.com', @subject = 'Today''s Attendance', @body = @Body, @body_format = 'HTML',@copy_recipients = 'rohit@orangewebtech.com'
			
			Set @HREmail_ID = ''
			Set @HR_Name = ''
			Set @ECount = 0
			
		 fetch next from Cur_Company into @Cmp_Id
	   end                    
	close Cur_Company                    
	deallocate Cur_Company         

End


