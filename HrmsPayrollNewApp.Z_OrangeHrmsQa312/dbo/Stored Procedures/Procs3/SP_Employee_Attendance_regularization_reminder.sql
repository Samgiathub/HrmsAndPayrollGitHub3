
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Employee_Attendance_regularization_reminder]
@cmp_id_Pass Numeric(18,0) = 0,
@CC_Email Nvarchar(max) = ''
AS 
BEGIN   
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

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
        Reason VARCHAR(255),
        Emp_Superior NUMERIC(18, 0),
        Request_for varchar(255),
        App_Date DATETIME,
        for_Date DATETIME,
        in_time DATETIME,
        Out_time DATETIME,
      )   
      
     
            
	 INSERT    INTO #Temp
                ( Cmp_ID,
                  Emp_ID,
                  Emp_code,
                  Emp_name,
                  Reason,
				  Emp_Superior,
                  Request_for,
                  App_Date,
                  for_Date,
                  in_time,
                  Out_time                   
                )
                ( SELECT    LA.Cmp_Id,
                            LA.Emp_Id,
                            LA.Alpha_Emp_Code,
                            LA.Emp_Name,
                            LA.Reason,
                            Qry.R_Emp_ID,--ED.R_Emp_ID,
                            la.Half_Full_day,
                            CONVERT(VARCHAR(10), LA.App_Date,101),
                           -- GETDATE(),
                            CONVERT(VARCHAR(10),LA.for_date, 101),
                            LA.In_Time,
                            LA.Out_Time
                  FROM      View_Late_Emp LA
							--left outer join T0090_EMP_REPORTING_DETAIL ED on LA.Emp_ID = ED.Emp_ID                         
							LEFT OUTER JOIN 
							( SELECT ED.R_Emp_ID,ED.Emp_ID FROM T0090_EMP_REPORTING_DETAIL ED WITH (NOLOCK) INNER JOIN 	--Ankit 28032016
								( SELECT MAX(Effect_Date) AS Effect_Date,ERD1.Emp_ID FROM T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
									WHERE Effect_Date<=GETDATE() AND cmp_id = ISNULL(@cmp_id_Pass,cmp_id) GROUP BY ERD1.emp_ID
								) RQry ON  ED.Emp_ID = RQry.Emp_ID AND ED.Effect_Date = RQry.Effect_Date 
                            ) Qry ON Qry.Emp_ID =LA.Emp_ID 
                  WHERE     LA.Chk_By_Superior = 0 and LA.cmp_id = ISNULL(@cmp_id_Pass,la.cmp_id) and -- Changed By rohit on 11032015
                  (
					(month(For_Date)=MONTH(GETDATE()) and year(For_Date)= year(GETDATE()) ) or (month(For_Date)=MONTH(DATEADD(month, DATEDIFF(month, -1, getdate()) - 2, 0)) and year(For_Date)= year(DATEADD(month, DATEDIFF(month, -1, getdate()) - 2, 0) )))
                )  
           
                 
           
      CREATE table #TempSuperiore
      ( CON INT IDENTITY(1, 1),
        Cmp_ID NUMERIC(18, 0),
        Emp_Superior NUMERIC(18, 0),
        Emp_Superior_Name nvarchar(200),
        EmployeeCount NUMERIC(18, 0) DEFAULT 0,
       
      )   
      
      INSERT    INTO #TempSuperiore
                ( Cmp_ID,
                  Emp_Superior,     
                  Emp_Superior_Name             
                )
				  --SELECT  distinct  LA.Cmp_Id,                            
						--	S_Emp_ID ,
						--	 EM.Emp_Full_Name
      --            FROM      dbo.T0100_Leave_Application LA
						--	--INNER JOIN dbo.T0110_LEAVE_APPLICATION_DETAIL LAD ON LA.Leave_Application_ID  = LAD.Leave_Application_ID 
						--	inner JOIN T0080_EMP_MASTER EM ON EM.Emp_ID = LA.S_Emp_ID                           
      --            WHERE     LA.Application_Status = 'P'  
      
                   Select Distinct EM.cmp_ID,Qry.R_Emp_ID,EM.Emp_Full_Name 
                   From View_Late_Emp LA left outer join 
                           --T0090_EMP_REPORTING_DETAIL ED on LA.Emp_ID = ED.Emp_ID inner join 
                           	( SELECT ED.R_Emp_ID,ED.Emp_ID FROM T0090_EMP_REPORTING_DETAIL ED WITH (NOLOCK) INNER JOIN 	--Ankit 28032016
								( SELECT MAX(Effect_Date) AS Effect_Date,ERD1.Emp_ID FROM T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
									WHERE Effect_Date<=GETDATE() AND cmp_id = ISNULL(@cmp_id_Pass,cmp_id) GROUP BY ERD1.emp_ID
								) RQry ON  ED.Emp_ID = RQry.Emp_ID AND ED.Effect_Date = RQry.Effect_Date 
                            ) Qry ON Qry.Emp_ID =LA.Emp_ID INNER JOIN
                           T0080_EMP_MASTER EM WITH (NOLOCK) on Qry.R_Emp_ID = EM.emp_id
                   Where  LA.Chk_By_Superior = 0 and LA.cmp_id = ISNULL(@cmp_id_Pass,la.cmp_id)  -- Changed By rohit on 11032015
                        
        
               
      UPDATE    #TempSuperiore
      SET       EmployeeCount = LQ.Ecount
      FROM      #TempSuperiore LA
                INNER JOIN ( SELECT COUNT(Emp_ID) AS Ecount,
                                    Emp_Superior
                             FROM   #Temp
                             GROUP BY Emp_Superior
                             HAVING COUNT(Emp_ID) > 0
                           ) LQ ON LA.Emp_Superior = LQ.Emp_Superior
                                                      

	 
      DECLARE @Emp_Superior AS NUMERIC(18, 0)
      DECLARE @Emp_Full_Name AS VARCHAR(255)
      DECLARE @Emp_Superior_Name AS varchar(200)
      DECLARE @Work_Email AS NVARCHAR(4000)
      DECLARE @Other_Email AS NVARCHAR(4000)
      DECLARE @Emp_ID AS NUMERIC(18, 0)
      DECLARE @Cmp_ID AS NUMERIC(18, 0)      
      DECLARE @Leave_Application_ID AS NUMERIC(18, 0)
      DECLARE @Leave_App_Date AS DATETIME
      DECLARE @Leave_From_date AS DATETIME
      DECLARE @Leave_To_date AS DATETIME
      DECLARE @Status AS DATETIME
      DECLARE @PendingApplication AS NUMERIC(18, 0)
      DECLARE @Annual_Leave_App_ReminderDate AS DATETIME
      DECLARE @ECount AS NUMERIC(18, 0)
      
      -- Added by rohit on 19082013
      Declare @Left_Date		datetime  
	  Declare @join_dt   		datetime  
	  Declare @Holiday_days numeric (2,0)
	  Declare @Cancel_Holiday numeric (2,0)
	  Declare @StrHoliday_Date  varchar(max)    
	  Declare @StrWeekoff_Date  varchar(max)
	  Declare @Cancel_Weekoff	numeric(18, 0)
	  Declare @WO_Days	numeric
	  
	  
	  
	Set @StrHoliday_Date = ''    
	set @StrWeekoff_Date = ''  
	set @Holiday_days = 0
	set @Cancel_Holiday=0
		  
	  -- Ended by rohit on 19082013
      
      Declare @current_Date as Datetime
      set @current_Date = GETDATE()
      
      
      DECLARE @I INT       
      SET @I = 1                      
      DECLARE @COUNT INT       
      SELECT    @COUNT = COUNT(CON)
      FROM      #TempSuperiore      
       
      WHILE ( @I <= @COUNT ) 
            BEGIN         
                  SELECT    @Cmp_ID = Cmp_ID,
                            @Emp_Superior = Emp_Superior,
                            @ECount = EmployeeCount,
                            @Emp_Superior_Name  = Emp_Superior_Name
                  FROM      #TempSuperiore
                  WHERE     CON = @I 
                  
                                
            
                  ----Get Superior Work Email and Other Email Detail for Particulare Employee.        
              
                                           
                  IF ISNULL(@Emp_Superior, 0) <> 0 
                     BEGIN								
                           SELECT   @Work_Email = Work_Email,
                                    @Other_Email = Other_Email
                                    ,@join_dt=Date_Of_Join,@Left_Date=Emp_Left_Date 
                           FROM     dbo.T0080_EMP_MASTER WITH (NOLOCK)
                           WHERE    Emp_ID = @Emp_Superior 
      --AND Cmp_ID = @Cmp_ID
                                    
                     END           			   
           			
           			 -- Added by rohit For Mail Not Send on Week Off on 19082013
                  	Exec SP_EMP_HOLIDAY_DATE_GET @Emp_Superior,@Cmp_ID,@current_Date,@current_Date,null,null,0,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,0,0,@StrWeekoff_Date
					Exec SP_EMP_WEEKOFF_DATE_GET @Emp_Superior,@Cmp_ID,@current_Date,@current_Date,@join_dt,@left_Date,0,@StrHoliday_Date,@StrWeekoff_Date output,@WO_Days output ,@Cancel_Weekoff output    	
					
					If charindex(CONVERT(VARCHAR(11),@current_Date,109),@StrWeekoff_Date,0) > 0
						Begin
							GOTO ABC;
						End
					
					If charindex(CONVERT(VARCHAR(11),@current_Date,109),@StrHoliday_Date,0) > 0
						Begin
							GOTO ABC;
						End
						
						-- Ended by rohit on 19082013
           			-- Added by rohit on 28-nov-2013
           			
           			  Declare @profile as varchar(50)
					  Declare @Server_link as varchar(500)
					  set @Server_link =''
       					  set @profile = ''
       					  
       					  select @profile = isnull(DB_Mail_Profile_Name,''),@Server_link = isnull(Server_link,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = @Cmp_Id
       					  
       					  if isnull(@profile,'') = ''
       					  begin
       					  select @profile = isnull(DB_Mail_Profile_Name,''),@Server_link = isnull(Server_link,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = 0
       					  end 
					--ended by rohit on 28-nov-2013
           		
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
								  Dear ' + @Emp_Superior_Name + ' </div>	<br/>					
								  								  
								  <table width="800" border="0" align="center" cellpadding="0" cellspacing="0" style="border:1px solid #cacaca; border-radius: 10px 10px 10px 10px;" >
								  <tr>
									 <td align="center" valign="middle"><table width="800" border="0" cellspacing="0" cellpadding="0">
										<tr>
										<td height="9" align="center" valign="middle" ></td>
										</tr>
									  <tr>
										<td width="800" height="24" align="center" valign="middle" style="background:#0b0505; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">Attendance Regularization Reminder</td>
									  </tr>
										  <tr>
											<td height="4" align="center" valign="middle"></td>
										  </tr>
										  <tr>
											<td width="800" align="center" valign="middle" style="border:1px solid #cacaca; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#000000;  text-decoration:none; text-align:center; font-size:12px;">You have [ ' + CAST(@ECount AS VARCHAR(255)) + ' ] Pending Attendance Request Application that need to be approve.</td>
										  </tr>
										  <tr>
											<td width="800" align="center" valign="middle" style="border:1px solid #cacaca; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#000000;  text-decoration:none; text-align:center; font-size:12px;">
											 <a href="' + @Server_link + '" style="text-decoration: bold;">
												<div align="center" class="White" style="padding-left: 40px">
                                                click here for login to payroll Hrms </div>
                 </a>
											
											</td>
										  </tr>
										  <tr>
											<td height="8" align="center" valign="middle"></td>
										  </tr>
								  </table>
                                    
								  <table width="800" height="24" align="center" valign="middle" style="background: #FFFFF;border-color:black;
									border-radius: 10px 10px 10px 10px; font-family: Arial, Helvetica, sans-serif;
									color: #000000; text-decoration: none; font-weight: bold; text-align: center;
									font-size: 12px;">' +
										  '<tr bgcolor=#FFFFFF><td align=center><b>Code</b></td>' +
										  '<td align=center><b>Employee Name</b></td>' +
										 '<td align=center><b>Application Date</b></td>' +
										  '<td align=center><b>For Date</b></td>' +
										  '<td align=center><b>In Time</b></td>' +
										  '<td align=center><b>Out time</b></td>' +		                  
										  '<td align=center><b>Reason</b></td>' +
										  '<td align=center><b>Half/Full Day</b></td>' +
										  '<td align=center><b>Status</b></td></tr>'
										                                     
                  SET @TableTail = '</table></body></html>';                  	
                  DECLARE @Body AS VARCHAR(MAX)
                  
                   
                  
                  SET @Body = ( SELECT  
										--'' as  [TRRow],
										emp_Code  as [TD],
										Emp_name  as [TD],
										isnull(CONVERT(VARCHAR(12), App_Date, 103),'') As [TD],
										isnull(CONVERT(VARCHAR(12), for_Date, 103),'') As [TD],
										isnull(RIGHT(CONVERT(VARCHAR,in_time,0),7),'') As [TD],
										isnull(RIGHT(CONVERT(VARCHAR,Out_time,0),7),'') As [TD],
										isnull(Reason,'') as [TD],
                                        isnull(Request_for,'') as [TD],
                                        'Pending' AS [TD]
                                                                                 
                                FROM    #Temp
                                WHERE   Emp_Superior = @Emp_Superior ORDER BY  Emp_code For XML raw('tr'), ELEMENTS) 
                             
					Declare @HREmail_ID				nvarchar(4000)
					   Select @HREmail_ID =(SELECT TOP 1 Email_ID FROM T0011_LOGIN WITH (NOLOCK) where Cmp_ID=@Cmp_ID AND Is_HR = 1)
						
					if isnull(@HREmail_ID,'')='' 
					begin
					select @HREmail_ID = (SELECT TOP 1 Email_ID FROM T0011_LOGIN WITH (NOLOCK) where Is_HR = 1)
					end
					if @CC_Email<>''
					begin
						set @HREmail_ID = @HREmail_ID + ';' + @CC_Email
					end
                       --if (@HREmail_ID <> '')
                       -- BEGIN
                       --    EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Com-i2', @recipients = @HREmail_ID,  @subject = 'Leave Approval Reminder', @body = @Body, @body_format = 'HTML'                               
                           
                       -- END
					
           			If isnull(@Body,'')=''
						Begin
							GOTO ABC;
						End
           			
           		  SELECT  @Body = @TableHead + @Body + @TableTail              		 	           			              
                  DECLARE @EmailNotification AS NUMERIC
                  
                  
                  SELECT    @EmailNotification = EMAIL_NTF_SENT
                  FROM      T0040_EMAIL_NOTIFICATION_CONFIG WITH (NOLOCK)
                  WHERE     EMAIL_NTF_DEF_ID = 2
                  
                  set @EmailNotification = 1
                  IF @EmailNotification = 1 
                     BEGIN		                     											
                           IF @Work_Email <> '' 
                              BEGIN                                   
                                   
                                                                                                              
                                   --EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Absolute_Mail', @recipients = @Work_Email, @subject = 'Attendance Regularization Reminder', @body = @Body, @body_format = 'HTML' , @copy_recipients = @HREmail_ID                                         
                                     EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @Work_Email, @subject = 'Attendance Regularization Reminder', @body = @Body, @body_format = 'HTML' , @copy_recipients = @HREmail_ID                                                                               
                                  --EXEC msdb.dbo.sp_send_dbmail @profile_name = 'com-i2', @recipients = 'Rohit@orangewebtech.com', @subject = 'Attendance Regularization Reminder', @body = @Body, @body_format = 'HTML' , @copy_recipients = 'Rohit@orangewebtech.com'                                         
                              END
                           ELSE 
                              IF @Other_Email <> '' 
                                 BEGIN      
                                                                                                             
                                    --EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Absolute_Mail', @recipients = @Other_Email, @subject = 'Attendance Regularization Reminder', @body = @Body, @body_format = 'HTML' , @copy_recipients = @HREmail_ID          
                                    EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @Other_Email, @subject = 'Attendance Regularization Reminder', @body = @Body, @body_format = 'HTML' , @copy_recipients = @HREmail_ID                                              
                                    --EXEC msdb.dbo.sp_send_dbmail @profile_name = 'com-i2', @recipients = 'Rohit@orangewebtech.com', @subject = 'Attendance Regularization Reminder', @body = @Body, @body_format = 'HTML' , @copy_recipients = 'Rohit@orangewebtech.com'                                          
                                    
                                 END                                             
                     END                    
                     
                    --select @Work_Email,@Other_Email
			ABC:	
                     
                  SELECT    @I = @I + 1       
            END           

End


