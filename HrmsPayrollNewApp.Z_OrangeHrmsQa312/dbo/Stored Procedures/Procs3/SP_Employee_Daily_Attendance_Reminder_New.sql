
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Employee_Daily_Attendance_Reminder_New]
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
      --SET @DATE = RIGHT(CAST(GETDATE() AS DATETIME), 5)      
      SET @DATE = CAST(GETDATE() AS varchar(11))
      
      
         if @cmp_id_Pass = 0
			set @cmp_id_Pass = null
      
      IF OBJECT_ID('tempdb..#Temp') IS NOT NULL 
         BEGIN
               DROP TABLE #Temp
         END
       
  --    CREATE TABLE #Temp
  --    ( 
		--CON INT IDENTITY(1, 1),
  --      Cmp_ID NUMERIC(18, 0),
  --      Emp_ID NUMERIC(18, 0),
  --      Emp_code VARCHAR(255),
  --      Emp_name VARCHAR(255),
  --      Emp_Superior NUMERIC(18, 0),
  --      For_Date Datetime,
		--Dept_Name varchar(150),
		--Desig_Name varchar(150)

  --    )   
  
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
            
      CREATE TABLE #HR_Email
      ( 
		Row_Id INT IDENTITY(1, 1),
        Cmp_ID NUMERIC(18, 0)
      )   

            
	 --INSERT    INTO #Temp
  --              ( Cmp_ID,
  --                Emp_ID,
  --                Emp_code,
  --                Emp_name,
		--		  For_Date,
		--		  Dept_Name,
		--		  Desig_Name
  --              )
  --              (Select EIR.Cmp_Id,EIR.Emp_id,E.Alpha_Emp_Code,E.Emp_Full_Name,Min(In_Time) as In_Time,
		--			Dept_Name,Desig_Name
		--			from T0150_EMP_INOUT_RECORD EIR Inner Join T0080_EMP_MASTER E on
		--				EIR.Emp_ID = E.Emp_ID Left Outer Join
		--				T0090_EMP_REPORTING_DETAIL ERD on E.Emp_ID = ERD.Emp_ID Left Outer Join
		--				T0080_EMP_MASTER E1 on E1.Emp_ID = ERD.R_Emp_ID Left Outer Join
		--				T0040_DEPARTMENT_MASTER DM on E.Dept_ID = DM.Dept_Id Left Outer Join
		--				T0040_DESIGNATION_MASTER DD on E.Desig_Id = DD.Desig_ID
		--		Where For_Date = CAST(Getdate() as varchar(11)) and EIR.Cmp_ID = ISNULL(@cmp_id_Pass,EIR.cmp_id)
		--		Group by EIR.Cmp_Id,EIR.Emp_id,E.Alpha_Emp_Code,E.Emp_Full_Name,Dept_Name,Desig_Name                         
  --              )  

	
	INSERT    INTO #Temp
     exec [SP_Get_Present_Absent_Emp_List] @cmp_id_Pass,@DATE

		
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
								  <div style=" font-family:Arial, Helvetica, sans-serif;   text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">
								  Dear ' + @HR_Name + ' </div>	<br/>					
								  
								  <table width="800" border="0" align="center" cellpadding="0" cellspacing="0" style="border:1px solid #cacaca; border-radius: 10px 10px 10px 10px;" >
								  <tr>
									 <td align="center" valign="middle"><table width="800" border="0" cellspacing="0" cellpadding="0">
										<tr>
										<td height="9" align="center" valign="middle" ></td>
										</tr>
									  <tr>
										<td width="800" height="24" align="center" valign="middle" style="border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#000000;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">Today''s Attendance</td>
									  </tr>
										  <tr>
											<td height="4" align="center" valign="middle"></td>
										  </tr>
										  <tr>
											<td width="800" align="center" valign="middle" style="border:1px solid #cacaca; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#000000;  text-decoration:none; text-align:center; font-size:12px;">Total Present Employee : [ ' + CAST(@ECount AS VARCHAR(255)) + ' ] </td>
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
										  '<td align=center><b><span style="font-size:small">In Time</span></b></td>'
										                                     
                  SET @TableTail = '</table></body></html>';                  	
                  DECLARE @Body AS VARCHAR(MAX)
                  Declare @Body_present as varchar(Max)
				  Declare @Body1 as varchar(Max)
				  Declare @Body_Absent as varchar(Max)
				  Declare @Body2 as varchar(Max)
				  Declare @Body_Leave as varchar(Max)
				  Declare @Body3 as varchar(Max)
				  Declare @Body_OD as varchar(Max)
				   Declare @Body4 as varchar(Max)
				  Declare @Body_Weekoff_holiday as varchar(Max)
				  Declare @Body_Final as varchar(Max)
				  set @Body_Final=''
				  set @Body=''
				  set @Body1=''
				  set @Body2=''
				  set @Body3=''
				  set @Body4=''
                  
                  
                  
                  SET @Body = ( SELECT  
										emp_Code  as [TD],
										Emp_name  as [TD],
										Isnull(Dept_Name,'-') as [TD],
										Isnull(Desig_Name,'-') as [TD],
										Left(Convert(varchar(25), For_Date,113),20) As [TD]
                                FROM    #Temp
                                WHERE   Cmp_ID = @Cmp_Id and Status='P' 
                                ORDER BY  Dept_Name,Case When IsNumeric(emp_Code) = 1 then Right(Replicate('0',21) + emp_Code, 20)
													When IsNumeric(emp_Code) = 0 then Left(emp_Code + Replicate('',21), 20)
														Else emp_Code
													End
                                 For XML raw('tr'), ELEMENTS) 
                             
  
				SET @Body_present = '<tr><td colspan="5" align="center" style="font-weight:bold;font-size:16PX;"> Present</td></tr>'
                  
                     
                  ------------Body Absent Part--------------------
                  
                  
                  
                   SET @Body1 = (  SELECT  
										emp_Code  as [TD],
										Emp_name  as [TD],
										Isnull(Dept_Name,'-') as [TD],
										Isnull(Desig_Name,'-') as [TD],
										'-' as [TD]
										--Left(Convert(varchar(25), For_Date,113),20) As [TD]
                                FROM    #Temp
                                WHERE   Cmp_ID = @Cmp_Id and Status='A' 
                                ORDER BY  Dept_Name,Case When IsNumeric(emp_Code) = 1 then Right(Replicate('0',21) + emp_Code, 20)
													When IsNumeric(emp_Code) = 0 then Left(emp_Code + Replicate('',21), 20)
													Else emp_Code
													End
                                 For XML raw('tr'), ELEMENTS) 
					                         
					        --        SET @Body_Absent = ( SELECT  
													--	''  as [TD],
													--	''  as [TD],
													--	'Absent' as [TD],
													--	'' as [TD],
													--	'' As [TD]
												 --For XML raw('tr'), ELEMENTS) 
												 
				SET @Body_Absent = '<tr><td colspan="5" align="center" style="font-weight:bold;font-size:16PX;"> Absent</td></tr>'	
				                      
                  ---------------------------------------
                  
                  ------------Body Leave Part--------------------
                  
                   SET @Body2 = ( SELECT  
										emp_Code  as [TD],
										Emp_name  as [TD],
										Isnull(Dept_Name,'-') as [TD],
										Isnull(Desig_Name,'-') as [TD],
										'-' as [TD]
										--Left(Convert(varchar(25), For_Date,113),20) As [TD]
                                FROM    #Temp
                                WHERE   Cmp_ID = @Cmp_Id and Status='L'                               
                                 ORDER BY  Dept_Name,Case When IsNumeric(emp_Code) = 1 then Right(Replicate('0',21) + emp_Code, 20)
													When IsNumeric(emp_Code) = 0 then Left(emp_Code + Replicate('',21), 20)
														Else emp_Code
													End
                                 For XML raw('tr'), ELEMENTS) 
					                         
					        --             SET @Body_Leave = ( SELECT  
													--	''  as [TD],
													--	''  as [TD],
													--	'Leave' as [TD],
													--	'' as [TD],
													--	'' As [TD]
												 --For XML raw('tr'), ELEMENTS) 
												 
					SET @Body_Leave = '<tr><td colspan="5" align="center" style="font-weight:bold;font-size:16PX;"> Leave</td></tr>'			
												
			      ---------------------------------------             
                  ------------Body OD Part--------------------   
                    
                   SET @Body3 = ( SELECT  
										emp_Code  as [TD],
										Emp_name  as [TD],
										Isnull(Dept_Name,'-') as [TD],
										Isnull(Desig_Name,'-') as [TD],
										'-' as [TD]
										--Left(Convert(varchar(25), For_Date,113),20) As [TD]
                                FROM    #Temp
                                WHERE   Cmp_ID = @Cmp_Id and Status='OD'   
                                 ORDER BY  Dept_Name,Case When IsNumeric(emp_Code) = 1 then Right(Replicate('0',21) + emp_Code, 20)
													When IsNumeric(emp_Code) = 0 then Left(emp_Code + Replicate('',21), 20)
														Else emp_Code
													End
                                 For XML raw('tr'), ELEMENTS) 
					                         
					        --             SET @Body_OD = ( SELECT  
													--	''  as [TD],
													--	''  as [TD],
													--	'On Duty' as [TD],
													--	'' as [TD],
													--	'' As [TD]
												 --For XML raw('tr'), ELEMENTS) 
					SET @Body_OD = '<tr><td colspan="5" align="center" style="font-weight:bold;font-size:16PX;"> On Duty</td></tr>'			 
				
                    ---------------------------------------   
                    ------------Body WO and HO Part--------------------   
                    
                    SET @Body4 = ( SELECT  
										emp_Code  as [TD],
										Emp_name  as [TD],
										Isnull(Dept_Name,'-') as [TD],
										Isnull(Desig_Name,'-') as [TD],
										Replicate('',10) + '-' as [TD]
										--Left(Convert(varchar(25), For_Date,113),20) As [TD]
                                FROM    #Temp
                                WHERE   Cmp_ID = @Cmp_Id and (Status='WO' or Status='HO')
                                 ORDER BY  Dept_Name,Case When IsNumeric(emp_Code) = 1 then Right(Replicate('0',21) + emp_Code, 20)
													When IsNumeric(emp_Code) = 0 then Left(emp_Code + Replicate('',21), 20)
														Else emp_Code
													End
                                 For XML raw('tr'), ELEMENTS)  
					                         
					        --             SET @Body_OD = ( SELECT  
													--	''  as [TD],
													--	''  as [TD],
													--	'WeekOff / Holiday' as [TD],
													--	'' as [TD],
													--	'' As [TD]
												 --For XML raw('tr'), ELEMENTS) 
												 
					SET @Body_Weekoff_holiday = '<tr><td colspan="5" align="center" style="font-weight:bold;font-size:16PX;"> WeekOff / Holiday</td></tr>'							                   
									   								
                     ---------------------------------------   
                 
						  if isnull(@Body,'') <> ''
						  begin
							set @Body = @Body_Present + @Body
						  end
						  
						  if isnull(@Body1,'') <> ''
						  begin
							set @Body1 = @Body_Absent + @Body1
						  end
						  
						  if isnull(@Body2,'') <> ''
						  begin
							set @Body2 = @Body_Leave + @Body2
						  end
						
						  if isnull(@Body3,'') <> ''
						  begin
							set @Body3 = @Body_OD + @Body3
						  end
						  
						  if isnull(@Body4,'') <> ''
						  begin
							set @Body4 = @Body_Weekoff_holiday + @Body4
						  end
						  
						  set @Body_Final = isnull(@Body,'') + isnull(@Body1,'') + isnull(@Body2,'') + isnull(@Body3,'') + isnull(@Body4,'')
						  
                      
                      
           		  SELECT  @Body_Final = @TableHead + @Body_Final + @TableTail              		 	           			              
           		  
           		     Declare @profile as varchar(50)
       					  set @profile = ''
       					  
       					  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = @Cmp_Id
       					  
       					  if isnull(@profile,'') = ''
       					  begin
       					  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = 0
       					  end  	

			EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @HREmail_ID, @subject = 'Today''s Attendance', @body = @Body_Final, @body_format = 'HTML',@copy_recipients = @CC_Email
			--EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Orange', @recipients = 'rohit@orangewebtech.com', @subject = 'Today''s Attendance', @body = @Body, @body_format = 'HTML',@copy_recipients = 'rohit@orangewebtech.com'
			
			PRINT @Body_Final
			
			Set @HREmail_ID = ''
			Set @HR_Name = ''
			Set @ECount = 0
			
		 fetch next from Cur_Company into @Cmp_Id
	   end                    
	close Cur_Company                    
	deallocate Cur_Company         

End


