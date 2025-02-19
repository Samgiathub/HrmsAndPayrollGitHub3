
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Employee_Daily_Reminder_Shift_Wise_ToManager]
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
       
    CREATE TABLE #Temp (
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
            
    CREATE TABLE #HR_Email
    ( 
		Row_Id INT IDENTITY(1, 1),
		Cmp_ID NUMERIC(18, 0)
    )   

            
	 INSERT    INTO #Temp
     exec [SP_Get_Present_Absent_Emp_List] @cmp_id_Pass,@DATE
 
     
     -- Added by rohit on 15072013
     Alter  table #Temp
     Add  Shift_Id numeric(3,0);
     
       -- Added by rohit on 30012015 for Wonder For order by Desig sort id
     Alter  table #Temp
     Add  Desig_Sort_Id numeric(3,0);


	--Updating Default Shift ID
	update #temp
	set Shift_id = dbo.fn_get_Shift_From_Monthly_Rotation(@Cmp_ID_Pass,Emp_ID,For_Date)
	from #temp 
	--inner join
	--(select Esd.Shift_id,Esd.Emp_id,For_date from T0100_Emp_Shift_Detail as ESD inner join
	--(select Emp_ID,MAX(For_date) as MAX_For_date from T0100_Emp_Shift_Detail  where for_date <= @DATE group by Emp_ID) Q1 on
	--ESD.Emp_id = Q1.Emp_ID and esd.For_Date = q1.MAX_For_date) QA1 on
	--#temp.Emp_id = QA1.Emp_ID


	--Add by Nimesh 20 May, 2015
	--This sp retrieves the Shift Rotation as per given employee id and effective date.
	--it will fetch all employee's shift rotation detail if employee id is not specified.
	IF (OBJECT_ID('tempdb..#Rotation') IS NULL)
		Create Table #Rotation (R_EmpID numeric(18,0), R_DayName varchar(25), R_ShiftID numeric(18,0), R_Effective_Date DateTime);
	--The #Rotation table gets re-created in dbo.P0050_UNPIVOT_EMP_ROTATION stored procedure
	declare @Constraint varchar(max);
	SELECT @Constraint=COALESCE(@constraint + '# ', '') + CAST(Emp_ID AS Varchar) FROM #Temp
	
	Exec dbo.P0050_UNPIVOT_EMP_ROTATION @cmp_id_Pass, NULL, @DATE, @Constraint

	--Added by Nimesh 21 April, 2015
	Update	#Temp
	SET		Shift_ID = R_ShiftID
	FROM	#Rotation
	WHERE	Emp_Id=R_EmpID  AND R_DayName='Day' + CAST(DATEPART(d, @DATE) As Varchar) AND 
			R_Effective_Date = (Select Max(R_Effective_Date) FROM #Rotation WHERE R_EmpID=Emp_Id)

	--Updating Shift ID from Employee Shift Detail if defined where Shift_Type = 0 and exist in Employee Shift Detail
	Update	#Temp
	SET		Shift_ID = E_ShiftID
	FROM	(
				SELECT	ESD.Shift_ID As E_ShiftID,ESD.Emp_ID As E_EmpID
				FROM	T0100_Emp_Shift_Detail AS ESD WITH (NOLOCK)
				WHERE	For_Date = @DATE AND ESD.Cmp_ID=@cmp_id_Pass
			) ES			
	WHERE	ES.E_EmpID=Emp_Id AND E_EmpID IN (
												SELECT	R_EMPID 
												FROM	#Rotation R 
												WHERE	R.R_Effective_Date <= @DATE
											)

			
	--Updating Shift ID from Employee Shift Detail if defined where Shift_Type = 1 and not exist in Employee Shift Detail
	Update	#Temp
	SET		Shift_ID = E_ShiftID
	FROM	(
				SELECT	ESD.Shift_ID As E_ShiftID,ESD.Emp_ID As E_EmpID
				FROM	T0100_Emp_Shift_Detail AS ESD WITH (NOLOCK)
				WHERE	For_Date = @DATE AND IsNull(Shift_Type,0)=1 AND ESD.Cmp_ID=@cmp_id_Pass
			) ES			
	WHERE	ES.E_EmpID=Emp_Id AND E_EmpID NOT IN (
													SELECT	R_EMPID 
													FROM	#Rotation R 
													WHERE	R.R_Effective_Date <= @DATE 
												)
	--End Nimesh


   
	update #temp
	set Desig_Sort_Id = QA1.Desig_Dis_No
	from #temp inner join
	(select * from t0040_designation_master WITH (NOLOCK)) QA1 on
	#temp.Desig_Name COLLATE SQL_Latin1_General_CP1_CI_AS = QA1.Desig_Name COLLATE SQL_Latin1_General_CP1_CI_AS  and  #Temp.Cmp_Id = QA1.Cmp_ID   
   
	--Where D.For_Date = @DATE 

	declare @Sh_Id numeric
	Declare @shift_Id numeric

	set @Sh_id = DATEPART(hh,GETDATE())

	CREATE TABLE #Shift_Cons 
	(      
		Shift_ID numeric  
	)      
     

	Insert Into #Shift_Cons  
	select shift_id from dbo.T0040_SHIFT_MASTER WITH (NOLOCK) where cast(left(Shift_St_Time,2) as numeric(2,0))  <= @Sh_id and cast(left(Shift_St_Time,2) as numeric(2,0)) >= @Sh_id - 2

	Delete #Temp Where shift_id not in (select Shift_id from #Shift_Cons )
	-- ended by rohit on 15072013


	CREATE TABLE #TempSuperiore
	( 
		CON INT IDENTITY(1, 1),
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
    Select Distinct LA.cmp_ID,ED.R_Emp_ID,EM.Emp_Full_Name 
    From #Temp LA left join 
            T0090_EMP_REPORTING_DETAIL ED WITH (NOLOCK) on LA.Emp_ID = ED.Emp_ID 
            INNER JOIN 				
                        (select MAX(Effect_Date) as Effect_Date, Emp_ID from T0090_EMP_REPORTING_DETAIL	WITH (NOLOCK)				 
                        where Effect_Date<=GETDATE()					 
                        GROUP BY emp_ID) RQry on  ED.Emp_ID = RQry.Emp_ID and ED.Effect_Date = RQry.Effect_Date inner join
            T0080_EMP_MASTER EM WITH (NOLOCK) on ED.R_Emp_ID = EM.emp_id
               
       
               
    UPDATE    #TempSuperiore
    SET       EmployeeCount = LQ.Ecount
    FROM      #TempSuperiore LA
            INNER JOIN ( SELECT COUNT(LA.Emp_ID) AS Ecount,
                                ED.R_Emp_ID
                            FROM   #Temp LA left join 
                            T0090_EMP_REPORTING_DETAIL ED WITH (NOLOCK) on LA.Emp_Id =ED.Emp_ID
                            INNER JOIN 				
                        (select MAX(Effect_Date) as Effect_Date, Emp_ID from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)					 
                        where Effect_Date<=GETDATE()					 
                        GROUP BY emp_ID) RQry on  ED.Emp_ID = RQry.Emp_ID and ED.Effect_Date = RQry.Effect_Date
                            GROUP BY ED.R_Emp_ID
                            HAVING COUNT(LA.Emp_ID) > 0
                        ) LQ ON LA.Emp_Superior = LQ.R_Emp_ID 
                           
                           

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
	  
	
	Insert Into #HR_Email (Cmp_ID)
	Select Cmp_Id From #Temp Group by Cmp_ID


	declare Cur_Company cursor for                    
	select Cmp_Id from #HR_Email order by Cmp_ID
	open Cur_Company                      
	
	fetch next from Cur_Company into @Cmp_Id
	while @@fetch_status = 0                    
		begin     
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
			FROM      #TempSuperiore where Cmp_ID=@Cmp_Id
      
			WHILE ( @I <= @COUNT ) 
				BEGIN     
            
					SELECT  @Cmp_ID = Cmp_ID,
							@Emp_Superior = Emp_Superior,
							@ECount = EmployeeCount,
							@Emp_Superior_Name  = Emp_Superior_Name
					FROM    #TempSuperiore
					WHERE   CON = @I 
                  
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
           			    

		
					Declare @HREmail_ID	nvarchar(4000)
					Declare @HR_Name as varchar(255)
					Declare @Branch as varchar(255)

						
					--declare Cur_Branch cursor for                    
					--select  Branch_Name as Branch from T0030_Branch_master 
					--where Cmp_id = @Cmp_Id order by Branch_name
					--open Cur_Branch                      
					--fetch next from Cur_Branch into @Branch
					--while @@fetch_status = 0                    
					--begin     
					
					SELECT TOP 1 @HREmail_ID = Email_ID , @HR_Name = Emp_Full_Name
					FROM T0011_LOGIN L WITH (NOLOCK) Left Outer Join T0080_EMP_MASTER E WITH (NOLOCK) on L.Emp_ID = E.Emp_ID
					Where L.Cmp_ID=@Cmp_ID AND Is_HR = 1

					if @CC_Email <> ''
						begin 
							set @HREmail_ID = @HREmail_ID + ';' + @CC_Email
						end

					--	Select @ECount = COUNT(Emp_Id) From #Temp where Cmp_ID = @Cmp_Id and branch_name = @branch


					---ALTER dynamic template for Employee.				
					Declare  @TableHead nvarchar(max),
							@TableTail nvarchar(max)   
   						Set @TableHead = '<html><head>' +
										'<style>' +
										'td {border: solid black 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:8pt;} ' +
										'</style>' +
										'</head>' +
										'<body>
										<div style=" font-family:Arial, Helvetica, sans-serif; color:Black;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">
										Dear ' + @Emp_Superior_Name + ' </div>	<br/>
										<table width="800" border="0" align="center" cellpadding="0" cellspacing="0" style="border:1px solid #cacaca; border-radius: 10px 10px 10px 10px;" >
										<tr>
											<td align="center" valign="middle"><table width="800" border="0" cellspacing="0" cellpadding="0">
											<tr>
											<td height="9" align="center" valign="middle" ></td>
											</tr>
											<tr>
											<td width="800" height="24" align="center" valign="middle" style="background:#0b0505; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;"> Attendance Report of your Team for ( ' + @Date + ') </td>
											</tr>
												<tr>
												<td height="4" align="center" valign="middle"></td>
												</tr>
												<tr>
												<td width="800" align="center" valign="middle" style="border:1px solid #cacaca; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#000000;  text-decoration:none; text-align:center; font-size:12px;">Total Employees : [ ' + CAST(@ECount AS VARCHAR(255)) + ' ] </td>
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
												'<td align=center><b><span style="font-size:small">Status</span></b></td>' +
												'<td align=center><b><span style="font-size:small">In Punch</span></b></td>'
								                                     
					SET @TableTail = '</table></body></html>';                  	
					Declare @Body as varchar(Max)
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
										Status As [TD],
										REPLACE(REPLACE(RIGHT('0' + CONVERT(VARCHAR(10) , CAST(For_Date AS TIME) , 100) , 7) , 'PM' , ' PM'),'AM' , ' AM') AS [TD]
								FROM    #Temp LA 
										LEFT JOIN T0090_EMP_REPORTING_DETAIL ED WITH (NOLOCK) on LA.Emp_ID = ED.Emp_ID
										INNER JOIN 	(select MAX(Effect_Date) as Effect_Date, Emp_ID 
													from	T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
													where	Effect_Date<=GETDATE()
													GROUP BY emp_ID) RQry on  ED.Emp_ID = RQry.Emp_ID and ED.Effect_Date = RQry.Effect_Date
								WHERE   LA.Cmp_ID = @Cmp_Id and ED.R_Emp_ID =@Emp_Superior and Status='P' 
								ORDER BY  LA.Desig_Sort_Id For XML raw('tr'), ELEMENTS
								) 
					                         
					SET @Body_present = '<tr><td colspan="6" align="center" style="font-weight:bold;font-size:16PX;"> Present</td></tr>'
												 
					SET @Body1 = ( SELECT  
											emp_Code  as [TD],
											Emp_name  as [TD],
											Isnull(Dept_Name,'-') as [TD],
											Isnull(Desig_Name,'-') as [TD],
											Status As [TD],
											ISNULL(CAST(For_Date AS VARCHAR(10)),'-') AS [TD]
									FROM    #Temp LA 
											LEFT JOIN 
											  T0090_EMP_REPORTING_DETAIL ED WITH (NOLOCK) on LA.Emp_ID = ED.Emp_ID
											  INNER JOIN (SELECT	MAX(Effect_Date) as Effect_Date, Emp_ID 
														 FROM	T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)		
														 WHERE Effect_Date<=GETDATE()
														 GROUP BY emp_ID) RQry on  ED.Emp_ID = RQry.Emp_ID and ED.Effect_Date = RQry.Effect_Date
									WHERE   LA.Cmp_ID = @Cmp_Id and ED.R_Emp_ID =@Emp_Superior and Status='A' 
									ORDER BY  LA.Desig_Sort_Id For XML raw('tr'), ELEMENTS
									) 
					                         
												 
					SET @Body_Absent = '<tr><td colspan="6" align="center" style="font-weight:bold;font-size:16PX;"> Absent</td></tr>'	
												 
					SET @Body2 = ( SELECT  
											emp_Code  as [TD],
											Emp_name  as [TD],
											Isnull(Dept_Name,'-') as [TD],
											Isnull(Desig_Name,'-') as [TD],
											Status As [TD],
											ISNULL(CAST(For_Date AS VARCHAR(10)),'-') AS [TD]
									FROM    #Temp LA 
											LEFT JOIN T0090_EMP_REPORTING_DETAIL ED WITH (NOLOCK) on LA.Emp_ID = ED.Emp_ID
											INNER JOIN (SELECT	MAX(Effect_Date) as Effect_Date, Emp_ID 
														FROM	T0090_EMP_REPORTING_DETAIL	WITH (NOLOCK)				 
														WHERE	Effect_Date<=GETDATE()					 
														GROUP BY emp_ID) RQry ON  ED.Emp_ID = RQry.Emp_ID and ED.Effect_Date = RQry.Effect_Date
									WHERE   LA.Cmp_ID = @Cmp_Id and ED.R_Emp_ID =@Emp_Superior and Status='L' 
									ORDER BY  LA.Desig_Sort_Id For XML raw('tr'), ELEMENTS) 
					                         
												 
					SET @Body_Leave = '<tr><td colspan="6" align="center" style="font-weight:bold;font-size:16PX;"> Leave</td></tr>'			
												 
					SET @Body3 = ( SELECT  
										emp_Code  as [TD],
										Emp_name  as [TD],
										Isnull(Dept_Name,'-') as [TD],
										Isnull(Desig_Name,'-') as [TD],
										Status As [TD],
										ISNULL(CAST(For_Date AS VARCHAR(10)),'-') AS [TD]
								FROM    #Temp LA 
										LEFT JOIN T0090_EMP_REPORTING_DETAIL ED WITH (NOLOCK) on LA.Emp_ID = ED.Emp_ID
										INNER JOIN (SELECT	MAX(Effect_Date) AS Effect_Date, Emp_ID 
													FROM	T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
													WHERE	Effect_Date<=GETDATE()
													GROUP BY emp_ID) RQry ON  ED.Emp_ID = RQry.Emp_ID and ED.Effect_Date = RQry.Effect_Date
								WHERE   LA.Cmp_ID = @Cmp_Id and ED.R_Emp_ID =@Emp_Superior and Status='OD' 
								ORDER BY  LA.Desig_Sort_Id For XML raw('tr'), ELEMENTS) 

					SET @Body_OD = '<tr><td colspan="6" align="center" style="font-weight:bold;font-size:16PX;"> On Duty</td></tr>'			 
					                   
					SET @Body4 = ( SELECT  
											emp_Code  as [TD],
											Emp_name  as [TD],
											Isnull(Dept_Name,'-') as [TD],
											Isnull(Desig_Name,'-') as [TD],
											Status As [TD],
											ISNULL(CAST(For_Date AS VARCHAR(10)),'-') AS [TD]
									FROM    #Temp LA 
											LEFT JOIN T0090_EMP_REPORTING_DETAIL ED WITH (NOLOCK) on LA.Emp_ID = ED.Emp_ID
											INNER JOIN (SELECT	MAX(Effect_Date) AS Effect_Date, Emp_ID 
														FROM	T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
														WHERE	Effect_Date<=GETDATE()
														GROUP BY emp_ID) RQry ON ED.Emp_ID = RQry.Emp_ID and ED.Effect_Date = RQry.Effect_Date
									WHERE   LA.Cmp_ID = @Cmp_Id and ED.R_Emp_ID =@Emp_Superior and ( Status='WO' or Status='HO') 
									ORDER BY  LA.Desig_Sort_Id For XML raw('tr'), ELEMENTS) 
					                         
					--             SET @Body_OD = ( SELECT  
											--	''  as [TD],
											--	''  as [TD],
											--	'WeekOff / Holiday' as [TD],
											--	'' as [TD],
											--	'' As [TD]
											--For XML raw('tr'), ELEMENTS) 
												 
					SET @Body_Weekoff_holiday = '<tr><td colspan="6" align="center" style="font-weight:bold;font-size:16PX;"> WeekOff / Holiday</td></tr>'			
					                   
					--if (@HREmail_ID <> '')
					-- BEGIN
					--    EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Orange', @recipients = @HREmail_ID,  @subject = 'Leave Approval Reminder', @body = @Body, @body_format = 'HTML'                               
					                       
					-- END
									
					       		
				If isnull(@Body,'')='' and isnull(@Body1,'')='' and isnull(@Body2,'')='' and isnull(@Body3,'')='' and isnull(@Body4,'')='' 
					Begin
						GOTO ABC;
					End	
				else
					begin
						  
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
						  
 						end
						
						
						
   								  SELECT  @Body_Final = @TableHead + @Body_Final + @TableTail  
			       		  
   								  Declare @subject as varchar(100)           
   								  Set @subject = 'Attendance Report of your Team for ( ' + @Date + ' ) '
					       		  
		       						Declare @profile as varchar(50)
   								  set @profile = ''
			   					  
   								  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = @Cmp_Id
			   					  
   								  if isnull(@profile,'') = ''
   								  begin
   								  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = 0
   								  end  		 	           			              


							--EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Orange1', @recipients = @HREmail_ID, @subject = @subject, @body = @Body, @body_format = 'HTML',@copy_recipients = 'Rohit@orangewebtech.com'  
							--	EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @HREmail_ID, @subject = @subject, @body = @Body, @body_format = 'HTML',@copy_recipients = 'Rohit@orangewebtech.com'  
							--EXEC msdb.dbo.sp_send_dbmail @profile_name = 'com-i2', @recipients = 'Rohit@orangewebtech.com', @subject = @subject, @body = @Body, @body_format = 'HTML'

							IF @Work_Email <> '' 
                              BEGIN                                   
                                   --print 1
                                                                                                              
                                   --EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Absolute_Mail', @recipients = @Work_Email, @subject = 'Leave Approval Reminder', @body = @Body, @body_format = 'HTML' , @copy_recipients = @HREmail_ID                      

                   
                                   EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @Work_Email, @subject = @subject, @body = @Body_Final, @body_format = 'HTML' , @copy_recipients = @HREmail_ID                                          

                                     
                                  --EXEC msdb.dbo.sp_send_dbmail @profile_name = 'com-i2', @recipients = 'Rohit@orangewebtech.com', @subject = 'Leave Approval Reminder', @body = @Body, @body_format = 'HTML' , @copy_recipients = 'Rohit@orangewebtech.com'  

                                       
                              END
                           ELSE 
                              IF @Other_Email <> '' 
                                 BEGIN      
                                -- print 2                                                                             
                                    --EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Absolute_Mail', @recipients = @Other_Email, @subject = 'Leave Approval Reminder', @body = @Body, @body_format = 'HTML' , @copy_recipients = @HREmail_ID          
                                    EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @Other_Email, @subject = @subject, @body = @Body_Final, @body_format = 'HTML' , @copy_recipients = @HREmail_ID                                        

      
                                    --EXEC msdb.dbo.sp_send_dbmail @profile_name = 'com-i2', @recipients = 'Rohit@orangewebtech.com', @subject = 'Leave Approval Reminder', @body = @Body, @body_format = 'HTML' , @copy_recipients = 'Rohit@orangewebtech.com'

                                          
                                 END      


							Set @HREmail_ID = ''
							Set @HR_Name = ''
							Set @ECount = 0
					
					
					--fetch next from Cur_Branch into @Branch
					--end                    
					--close Cur_Branch
					--deallocate Cur_Branch
					
					ABC:	
					SELECT    @I = @I + 1       
					END      
					
				 fetch next from Cur_Company into @Cmp_Id
			   end                    
			close Cur_Company                    
			deallocate Cur_Company         
        
       

End




