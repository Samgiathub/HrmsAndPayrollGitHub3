

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Reminder_KPIReview]
	AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	IF OBJECT_ID('tempdb..#Temp') IS NOT NULL 
         BEGIN
               DROP TABLE #Temp
         END
         
     
             
    CREATE table #HR_Email
	( 
		Row_Id INT IDENTITY(1, 1),
		Cmp_ID NUMERIC(18, 0)
	) 

	Insert Into #HR_Email (Cmp_ID)
		Select Cmp_Id From T0010_COMPANY_MASTER WITH (NOLOCK) Group by Cmp_ID
		
	Declare @HREmail_ID	nvarchar(max)
	Declare @Cmp_Id as numeric
	Declare @HR_Name as varchar(255)
	Declare @ECount as numeric
	declare @KPIMonth as numeric
	declare @kpiDay	as numeric
	declare @NewempAlertdays as numeric
	declare @KPI_AlertType as numeric --added on 23 Mar 2015
	
	
declare Cur_Company cursor for 
		select Cmp_Id from #HR_Email order by Cmp_ID
	open Cur_Company   
		fetch next from Cur_Company into @Cmp_Id		
		while @@fetch_status = 0  
			begin
				--get new employee alert days
				Select @NewempAlertdays= isnull(KPI_AlertNodays,0)  from T0040_KPI_AlertSetting WITH (NOLOCK) where Cmp_Id=@Cmp_Id and KPI_Type=3
			    -- get recipients
				 (SELECT  @HREmail_ID = 
									  STUFF ( ( SELECT ';'+case when  T0080_EMP_MASTER.Work_Email<>'' then T0080_EMP_MASTER.Work_Email end 
												FROM  T0080_EMP_MASTER WITH (NOLOCK)
												WHERE Cmp_ID = @Cmp_Id and Date_Of_Join < DATEADD(DAY,- @NewempAlertdays,CONVERT(datetime, getdate())) and Emp_Left<>'Yes'
												ORDER BY Emp_ID
												FOR XML PATH(''),TYPE 
											   ).value('.','VARCHAR(MAX)') 
											  , 1,1,SPACE(0))
									FROM T0080_EMP_MASTER WITH (NOLOCK) 
									GROUP BY Emp_ID)
				
				-- get Dates type 1
					declare cur_kpi1 cursor for
						Select KPI_AlertDay,KPI_Month,KPI_AlertType from T0040_KPI_AlertSetting WITH (NOLOCK) where Cmp_Id=@Cmp_Id and KPI_Type=1					
					open cur_kpi1   	
						fetch next from cur_kpi1 into @kpiDay,@KPIMonth,@KPI_AlertType	
						while @@FETCH_STATUS = 0
							begin
								 if DATEPART(DD,GETDATE())= @kpiDay and DATEPART(MM,GETDATE())=@KPIMonth
									begin
										 Declare  @TableHead varchar(max),
													@TableTail varchar(max) 
										set @TableHead = '<html>
															<head>
															</head>
															<body>
																<table width="800" border="0" align="center" cellpadding="0" cellspacing="0" style="border: 1px solid #cacaca;
																	border-radius: 10px 10px 10px 10px;">
																	<tr>
																		<td align="center" valign="middle">
																			<table width="800" border="0" cellspacing="0" cellpadding="0">
																				<tr>
																					<td height="9" align="center" valign="middle">
																					</td>
																				</tr>
																				<tr>
																					<td width="800" height="24" align="center" valign="middle" style="background: #0b0505;
																						border-radius: 10px 10px 10px 10px; font-family: Arial, Helvetica, sans-serif;
																						color: #FFFFFF; text-decoration: none; font-weight: bold; text-align: center;
																						font-size: 13px;">
																						Appraisal Process Reminder
																					</td>
																				</tr>
																				<tr>
																					<td height="4" align="center" valign="middle">
																					</td>
																				</tr>';			
										 SET @TableTail = '</td></tr></table></body></html>'; 	
										 DECLARE @Body AS VARCHAR(MAX)
										 if @KPI_AlertType = 1 or @KPI_AlertType is null
										 begin
											 SET @Body = '<tr>
															<td width="800" align="center" valign="middle" style="border: 1px solid #cacaca;
																border-radius: 10px 10px 10px 10px; font-family: Arial, Helvetica, sans-serif;
																color: #000000; text-decoration: none; text-align: center; font-size: 12px;">
															   Your Interim Appraisal Process is starting from ' + cast(@kpiDay as varchar(3)) + ',' + DateName( month , DateAdd( month , @KPIMonth , -1 ) ) + 
															'</td>
														</tr>
														<tr>
															<td height="8" align="center" valign="middle">
															</td>
														</tr>
													</table>'
											end
											Else
												begin
													 SET @Body = '<tr>
															<td width="800" align="center" valign="middle" style="border: 1px solid #cacaca;
																border-radius: 10px 10px 10px 10px; font-family: Arial, Helvetica, sans-serif;
																color: #000000; text-decoration: none; text-align: center; font-size: 12px;">
															   Your Final Appraisal Process is starting from ' + cast(@kpiDay as varchar(3)) + ',' + DateName( month , DateAdd( month , @KPIMonth , -1 ) ) + 
															'</td>
														</tr>
														<tr>
															<td height="8" align="center" valign="middle">
															</td>
														</tr>
													</table>'
												End		 
										SELECT  @Body = @TableHead + @Body + @TableTail 
										 Declare @subject as varchar(100)           
           								Set @subject = 'Appraisal Process Reminder'
										
										Declare @profile as varchar(50)
   										  set @profile = ''
				       					  
   										  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = @Cmp_Id
				       					  
   										  if isnull(@profile,'') = ''
   										  begin
   										  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = 0
   										  end
   										
       								EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @HREmail_ID, @subject = @subject, @body = @Body, @body_format = 'HTML'
									end
								fetch next from cur_kpi1 into @kpiDay,@KPIMonth,@KPI_AlertType
							end	
					close cur_kpi1
					deallocate cur_kpi1		
					  	
					  	set @TableHead = ''
					  	set @Body = ''
					  	set @TableTail = ''
					  	set @kpiDay = 0
					  	set @kpimonth = 0
					  	set @HREmail_ID =''
					  	set @subject= ''
					  	
				-- get recipients
						(SELECT  @HREmail_ID = 
									  STUFF ( ( SELECT ';'+case when  T0080_EMP_MASTER.Work_Email<>'' then T0080_EMP_MASTER.Work_Email end 
												FROM  T0080_EMP_MASTER WITH (NOLOCK)
												WHERE Cmp_ID = @Cmp_Id  and Date_Of_Join < DATEADD(DAY,- @NewempAlertdays,CONVERT(datetime, getdate())) and Emp_Left<>'Yes'
												ORDER BY Emp_ID
												FOR XML PATH(''),TYPE 
											   ).value('.','VARCHAR(MAX)') 
											  , 1,1,SPACE(0))
									FROM T0080_EMP_MASTER WITH (NOLOCK)
									GROUP BY Emp_ID)  	
					  	
				-- get Dates type 2	  	
					
						Select @kpiDay=KPI_AlertDay,@kpimonth=KPI_Month from T0040_KPI_AlertSetting WITH (NOLOCK) where Cmp_Id=@Cmp_Id and KPI_Type=2					
					
						 if DATEPART(DD,GETDATE())= @kpiDay and DATEPART(MM,GETDATE())=@KPIMonth
							begin
								set @TableHead = '<html>
													<head>
													</head>
													<body>
														<table width="800" border="0" align="center" cellpadding="0" cellspacing="0" style="border: 1px solid #cacaca;
															border-radius: 10px 10px 10px 10px;">
															<tr>
																<td align="center" valign="middle">
																	<table width="800" border="0" cellspacing="0" cellpadding="0">
																		<tr>
																			<td height="9" align="center" valign="middle">
																			</td>
																		</tr>
																		<tr>
																			<td width="800" height="24" align="center" valign="middle" style="background: #0b0505;
																				border-radius: 10px 10px 10px 10px; font-family: Arial, Helvetica, sans-serif;
																				color: #FFFFFF; text-decoration: none; font-weight: bold; text-align: center;
																				font-size: 13px;">
																				Objectives Setting Reminder
																			</td>
																		</tr>
																		<tr>
																			<td height="4" align="center" valign="middle">
																			</td>
																		</tr>';			
								SET @TableTail = '</td></tr></table></body></html>';
								
								SET @Body = '<tr>
													<td width="800" align="center" valign="middle" style="border: 1px solid #cacaca;
														border-radius: 10px 10px 10px 10px; font-family: Arial, Helvetica, sans-serif;
														color: #000000; text-decoration: none; text-align: center; font-size: 12px;">
													   Kindly prepare your Objectives for the current financial year starting from ' + cast(@kpiDay as varchar(3)) + ',' + DateName( month , DateAdd( month , @KPIMonth , -1 ) ) + '
													</td>
												</tr>
												<tr>
													<td height="8" align="center" valign="middle">
													</td>
												</tr>
											</table>'		 
								SELECT  @Body = @TableHead + @Body + @TableTail 
								Set @subject = 'Objectives Setting Reminder'
								
   								  set @profile = ''
		       					  
   								  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = @Cmp_Id
		       					  
   								  if isnull(@profile,'') = ''
   								  begin
   								  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = 0
   								  end
   								  
       							EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @HREmail_ID, @subject = @subject, @body = @Body, @body_format = 'HTML'

							End			
							
						set @TableHead = ''
					  	set @Body = ''
					  	set @TableTail = ''
					  	set @kpiDay = 0
					  	set @kpimonth = 0
					  	set @HREmail_ID =''
					  	set @subject= ''
					  	
					  	-- get recipients
							(SELECT  @HREmail_ID = 
									  STUFF ( ( SELECT ';'+case when  T0080_EMP_MASTER.Work_Email<>'' then T0080_EMP_MASTER.Work_Email end 
												FROM  T0080_EMP_MASTER WITH (NOLOCK)
												WHERE Cmp_ID = @Cmp_Id  and Date_Of_Join >= DATEADD(DAY,- @NewempAlertdays,CONVERT(datetime, getdate())) and Emp_Left<>'Yes'
												ORDER BY Emp_ID
												FOR XML PATH(''),TYPE 
											   ).value('.','VARCHAR(MAX)') 
											  , 1,1,SPACE(0))
									FROM T0080_EMP_MASTER WITH (NOLOCK)
									GROUP BY Emp_ID)  
					   -- get Dates type 3
							
							--if isnull(@HREmail_ID,'') <>''
								begin 
									SET @TableHead = '<html>
														<head>
														</head>
														<body>
															<table width="800" border="0" align="center" cellpadding="0" cellspacing="0" style="border: 1px solid #cacaca;
																border-radius: 10px 10px 10px 10px;">
																<tr>
																	<td align="center" valign="middle">
																		<table width="800" border="0" cellspacing="0" cellpadding="0">
																			<tr>
																				<td height="9" align="center" valign="middle">
																				</td>
																			</tr>
																			<tr>
																				<td width="800" height="24" align="center" valign="middle" style="background: #0b0505;
																					border-radius: 10px 10px 10px 10px; font-family: Arial, Helvetica, sans-serif;
																					color: #FFFFFF; text-decoration: none; font-weight: bold; text-align: center;
																					font-size: 13px;">
																					Objectives Setting Reminder (New Joinees)
																				</td>
																			</tr>
																			<tr>
																				<td height="4" align="center" valign="middle">
																				</td>
																			</tr>';			
									SET @TableTail = '</td></tr></table></body></html>';								
									SET @Body = '<tr>
													<td width="800" align="center" valign="middle" style="border: 1px solid #cacaca;
														border-radius: 10px 10px 10px 10px; font-family: Arial, Helvetica, sans-serif;
														color: #000000; text-decoration: none; text-align: center; font-size: 12px;">
														Kindly prepare your Objectives
													</td>
												</tr>
												<tr>
													<td height="8" align="center" valign="middle">
													</td>
												</tr>
											</table>'		 
									SELECT  @Body = @TableHead + @Body + @TableTail 
									Set @subject = 'Objectives Setting Reminder (New Joinees)'									
								    set @profile = ''
								    								 
		       					  
   								  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = @Cmp_Id
		       					  
   								  if isnull(@profile,'') = ''
   									  begin
   										select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = 0
   									  end
   									 
   									EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @HREmail_ID, @subject = @subject, @body = @Body, @body_format = 'HTML'
								end
							set @TableHead = ''
					  		set @Body = ''
					  		set @TableTail = ''
					  		set @kpiDay = 0
					  		set @kpimonth = 0
					  		set @HREmail_ID =''
					  		set @subject= ''
						
							set @NewempAlertdays=0	
							
				fetch next from Cur_Company into @Cmp_Id		
			end                   
	close Cur_Company
	deallocate Cur_Company	
	
	drop table #HR_Email
END

