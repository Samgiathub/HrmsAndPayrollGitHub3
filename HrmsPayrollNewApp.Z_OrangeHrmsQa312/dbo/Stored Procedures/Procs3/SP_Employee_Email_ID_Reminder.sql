
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Employee_Email_ID_Reminder]
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
        Cmp_ID NUMERIC(18,0),
		Emp_ID NUMERIC(18,0),
		Alpha_Emp_Code VARCHAR(100),
		Emp_Full_Name VARCHAR(200),
		Branch_ID NUMERIC(18,0),
		Branch_Name VARCHAR(200),
		Dept_ID NUMERIC(18,0),
		Dept_Name VARCHAR(200),
		Desig_Id NUMERIC(18,0),
		Desig_Name VARCHAR(200),
		Cmp_Name VARCHAR(300),
		Work_Email VARCHAR(50)
      )   
           
            
			INSERT    INTO #Temp
                ( Cmp_ID,
                  Emp_ID,
                  Alpha_Emp_Code,
				  Emp_Full_Name,
				  Branch_ID,
				  Branch_Name,
				  Dept_ID,
				  Dept_Name,
				  Desig_Id,
				  Desig_Name,				  
				  Cmp_Name,
				  Work_Email
                )
                ( 
					Select  EM.Cmp_ID,EM.Emp_ID,EM.Alpha_Emp_Code,EM.Emp_Full_Name,EM.Branch_ID,BM.Branch_Name,
					EM.Dept_ID,ISNULL(DM.Dept_Name,'NA'),EM.Desig_Id,ISNULL(DEM.Desig_Name,'NA')
					,CM.Cmp_Name,'Not Available'
					from T0080_EMP_MASTER EM WITH (NOLOCK) Inner join
					(select Distinct I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join   
						 ( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment  WITH (NOLOCK)
						 group by emp_ID) Qry ON I.Emp_ID = Qry.Emp_ID ) Qry1 ON EM.Emp_ID = Qry1.Emp_ID 
						 Inner Join T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Bm.Branch_ID = EM.Branch_ID
						 Inner Join T0010_COMPANY_MASTER CM WITH (NOLOCK) ON EM.Cmp_ID = CM.Cmp_Id
						 Left Outer Join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON DM.Dept_Id = EM.Dept_ID
						 Left Outer Join T0040_DESIGNATION_MASTER DEM WITH (NOLOCK) ON DEM.Desig_ID = EM.Desig_Id
						 Where ISNULL(Work_Email,'') = '' and Em.Cmp_ID = ISNULL(@cmp_id_Pass,Em.Cmp_ID)
						 and isnull(emp_left,'') <> 'Y'
                )  
      
		 IF OBJECT_ID('tempdb..#Temp_Cmp') IS NOT NULL 
         BEGIN
               DROP TABLE #Temp_Cmp
         END
         
        CREATE table #Temp_Cmp
		( 
			CON INT IDENTITY(1, 1),
			Cmp_ID NUMERIC(18,0)
		)
		
		INSERT  INTO #Temp_Cmp
        (Cmp_ID)
        (Select Cmp_ID from #Temp group by #Temp.Cmp_ID)
            
            
      DECLARE @Cmp_ID AS NUMERIC(18, 0)  
      DECLARE @Cmp_Name AS varchar(250)    
	  SET @Cmp_ID = 0 
	  SET @Cmp_Name = ''
	  
      Declare @current_Date as Datetime
      set @current_Date = GETDATE()
      
      
      DECLARE @I INT       
      SET @I = 1                      
      DECLARE @COUNT INT       
      SELECT    @COUNT = COUNT(CON)
      FROM      #Temp_Cmp    
            
      WHILE ( @I <= @COUNT ) 
         BEGIN         
                  SELECT    @Cmp_ID = Cmp_ID
                  FROM      #Temp_Cmp
                  WHERE     CON = @I 
        
					  SET @Cmp_Name = (Select TOP 1 Cmp_Name From #Temp where Cmp_ID = @Cmp_ID)
					
           			  Declare @profile as varchar(50)
					  Declare @Server_link as varchar(500)
					  Declare @Profile_Email as varchar(Max)
					  set @Server_link =''
       				  set @profile = ''
       				  set @Profile_Email = ''
       					  
       				  select @profile = isnull(DB_Mail_Profile_Name,''),@Server_link = isnull(Server_link,''),@Profile_Email = ISNULL(Email_Id,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = @Cmp_Id
       					         					  
       				  if isnull(@profile,'') = ''
       				     begin
       					   select @profile = isnull(DB_Mail_Profile_Name,''),@Server_link = isnull(Server_link,''),@Profile_Email = ISNULL(Email_Id,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = 0       					   
       				     end 
       				     
       				 Declare @HREmail_ID nvarchar(4000)
       				 Declare @HREmp_Name nvarchar(400)
					 Select @HREmail_ID =(SELECT TOP 1 Email_ID FROM T0011_LOGIN WITH (NOLOCK) where Cmp_ID=@Cmp_Id AND Is_HR = 1)
					 Select @HREmp_Name =(Select Emp_Full_Name From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID in (SELECT TOP 1 Emp_ID FROM T0011_LOGIN WITH (NOLOCK) where Cmp_ID= @Cmp_Id AND Is_HR = 1 ))
  		  
				  Declare  @TableHead varchar(max),
				  @TableTail varchar(max)   
           		  Set @TableHead = '<html><head>' +
									  '<style>' +
									  'td {border: solid black 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:8pt;} ' +
									  '</style>' +
								  '</head>' +
								  '<body>
								  <div style=" font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">
								  Dear All, </div>	<br/>					
								  								  
								  <table width="850" border="0" align="center" cellpadding="0" cellspacing="0" style="border:1px solid #cacaca; border-radius: 10px 10px 10px 10px;" >
								  <tr>
									 <td align="center" valign="middle"><table width="800" border="0" cellspacing="0" cellpadding="0">
										<tr>
										<td height="9" align="center" valign="middle" ></td>
										</tr>
									  <tr>
										<td colspan="2" width="800" height="24" align="center" valign="middle" style="background:#0b0505; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">Employee Work Email Pending Records.</td>
									  </tr>
										  <tr>
											<td height="4" align="center" valign="middle"></td>
										  </tr>
										  <tr>
											<td colspan="2" width="800" align="center" valign="middle" style="border:1px solid #cacaca; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#000000;  text-decoration:none; text-align:center; font-size:12px;">
											 <a href="' + @Server_link + '" style="text-decoration: bold;">
												<div align="center" class="White" style="padding-left: 40px">
                                                click here for login to payroll Hrms </div></a>
											
											</td>
										  </tr>
										  <tr>
											<td height="8" align="center" valign="middle"></td>
										  </tr>
										  <tr>
											<td width="400" align="center" valign="middle" style="border:1px solid #cacaca; border-radius: 10px 0px 0px 10px; font-family:Arial, Helvetica, sans-serif; color:#000000;  text-decoration:none; text-align: left; font-size: 12px; padding-left:20px;border-right:none;"><b>Company Name : '+ @Cmp_Name +'</b></td>
											<td width="400" align="center" valign="middle" style="border:1px solid #cacaca; border-radius: 0px 10px 10px 0px; font-family:Arial, Helvetica, sans-serif; color:#000000;  text-decoration:none; text-align: right; font-size: 12px; padding-right:20px;border-left:none;"><b>'+ CONVERT(varchar(20),GETDATE(),106) +'</b></td>
										  </tr>
										   <tr>
											<td height="8" align="center" valign="middle"></td>
										  </tr>
								  </table>                                    
								  <table width="800" height="24" align="center" valign="middle" style="background: #FFFFF;border-color:black;
									border-radius: 10px 10px 10px 10px; font-family: Arial, Helvetica, sans-serif;
									color: #000000; text-decoration: none; font-weight: bold; text-align: center;
									font-size: 12px;"><tr>' +
										  '<td bgcolor=#FFFFFF align=center><b>Employee Code</b></td>' +
										  '<td align=center><b>Employee Name</b></td>' +
										  '<td align=center><b>Branch Name</b></td>' +
										  '<td align=center><b>Designation</b></td>' +
										  '<td align=center><b>Department</b></td>' +	
										  '<td align=center><b>Work Email</b></td></tr>'
										                                     
                  SET @TableTail = '</table></td></tr></table></body></html>';                  	
                  DECLARE @Body AS VARCHAR(MAX)
                  SET @Body = (SELECT  
										Alpha_Emp_Code  as [TD],
										Emp_Full_Name  as [TD],
										Branch_Name  as [TD],
										Desig_Name  as [TD],
										Dept_Name  as [TD],
										Work_Email as [TD]
                                FROM    #Temp where Cmp_ID = @Cmp_ID
                                ORDER BY  Alpha_Emp_Code For XML raw('tr'), ELEMENTS) 
				  
				  Set @Body = replace(@Body,'<td>','<td align=''left''>')
           		  SELECT  @Body = @TableHead + @Body + @TableTail 
           		 
           		  DECLARE @EmailNotification AS NUMERIC
                  set @EmailNotification = 1
                  IF @EmailNotification = 1 
                     BEGIN		
							
							--Select @profile,@Profile_Email,@Cmp_ID,@Body
							--select 1
							EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @HREmail_ID, @subject = 'Employee Work Email Pending Records.', @body = @Body, @body_format = 'HTML',@copy_recipients = @CC_Email
							--Select 2
					 END      
					
			  SELECT @I = @I + 1   
		END                  
End


