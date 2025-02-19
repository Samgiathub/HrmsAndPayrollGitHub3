

---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Employee_Missing_Punch_reminder]
	@cmp_id_Pass NUMERIC(18,0) = 0,
	@CC_Email NVARCHAR(max) = '',
	@Flag NUMERIC = 1
AS 
	BEGIN   
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	  DECLARE @DATE VARCHAR(20)   
      DECLARE @Approval_day AS NUMERIC    
      DECLARE @ReminderTemplate AS NVARCHAR(4000)
      SET @DATE = RIGHT(CAST(GETDATE() AS DATETIME), 5)      
      
      IF @cmp_id_Pass = 0
		 SET @cmp_id_Pass = null
       
      
      IF OBJECT_ID('tempdb..#Temp') IS NOT NULL 
         BEGIN
               DROP TABLE #Temp
         END
       
      CREATE table #Temp
      ( 
		CON INT IDENTITY(1, 1),
		IO_Tran_ID NUMERIC(18,0),		
        Emp_ID NUMERIC(18, 0),
        Cmp_ID NUMERIC(18, 0),        
        for_Date DATETIME,
        In_Time Datetime,
        Out_Time datetime,
        Duration VARCHAR(100),
        Reason VARCHAR(200),
        Ip_Address VARCHAR(100),
        In_Date_Time datetime,
        Out_date_time datetime,
        Skip_Count NUMERIC(18,0),
        Late_Calc_Not_App NUMERIC(18,0),
        Chk_by_Superior tinyint,
        Sup_Comment VARCHAR(100),
        Half_Full_Day VARCHAR(20),
        Is_Cancel_late_in tinyint,
        Is_Cancel_Early_Out tinyint,
        Is_default_In tinyint,
        Is_Default_Out tinyint,
        Cmp_prp_in_flag NUMERIC(5,0),
        Cmp_prp_out_flag NUMERIC(5,0),
        Is_Cmp_purpose tinyint,
        App_date datetime,
        Apr_date datetime,
        System_date datetime,
        Other_Reason VARCHAR(100),
        ManaulEntryFlag char(3),        
        Emp_code VARCHAR(255),
        Alpha_Emp_code VARCHAR(255),        
        Emp_name VARCHAR(255),
        Emp_Full_name VARCHAR(255),
        Dept_name VARCHAR(255),
        Desig_name VARCHAR(255),
        Typename VARCHAR(255),
        Gradename VARCHAR(255),
        Branchname VARCHAR(255),
        DateOfJoin Datetime,
        GENDer VARCHAR(20),
        Comp_Name VARCHAR(500),
        Branch_Address VARCHAR(500),
        Cmp_Name VARCHAR(500),
        Cmp_Address VARCHAR(700),
        Emp_Left VARCHAR(10),
        Branch_ID NUMERIC(18,0),        
        Shift_Time VARCHAR(255),
        Vertical VARCHAR(255),
        Subverical VARCHAR(255),
       -- MissPunchCount NUMERIC(18,0) default 0
        )   
        
       DECLARE @from_Date AS datetime       
       DECLARE @To_Date AS datetime
       
       IF @Flag = 1
			BEGIN
				SET @from_Date= DATEADD(month, DATEDIFF(month, 0, getdate()), 0)
				SET @To_Date= DATEADD(D,-1,GETDATE())
			END
	   Else
			BEGIN
				SET @from_Date= convert(datetime,convert(int,DATEADD(D,-7,GETDATE()))) 
				SET @To_Date= convert(datetime,convert(int,DATEADD(D,-1,GETDATE())))  
			END
       
        
	INSERT INTO #Temp
	Exec SP_RPT_MISSING_INOUT @Cmp_ID=@cmp_id_Pass,@From_Date=@from_Date,@To_Date=@To_Date,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0,@Constraint='',@Report_Type='Only Single Punch'
     
   
    Alter Table  #Temp
    Add  MissPunchCount NUMERIC(18,0) default 0
   
	UPDATE    LA
    SET       MissPunchCount = LQ.Mcount
    FROM      #Temp LA
              INNER JOIN ( SELECT COUNT(for_Date) AS Mcount,
                                    Emp_ID
                             FROM   #Temp
                             GROUP BY Emp_ID
                             HAVING COUNT(Emp_ID) > 0
                           ) LQ ON LA.Emp_ID = LQ.Emp_ID
                 
    

	DECLARE @Emp_Full_Name AS VARCHAR(255)     
	DECLARE @Work_Email AS NVARCHAR(4000)
	DECLARE @Other_Email AS NVARCHAR(4000)
	DECLARE @Emp_ID AS NUMERIC(18, 0)
	DECLARE @Cmp_ID AS NUMERIC(18, 0)      
    
	DECLARE @MCount AS NUMERIC(18, 0)
      
	-- Added by rohit on 19082013
	--DECLARE @Left_Date		datetime  
	--DECLARE @join_dt   		datetime  
	--DECLARE @Holiday_days NUMERIC (2,0)
	--DECLARE @Cancel_Holiday NUMERIC (2,0)
	--DECLARE @StrHoliday_Date  VARCHAR(max)    
	--DECLARE @StrWeekoff_Date  VARCHAR(max)
	--DECLARE @Cancel_Weekoff	NUMERIC(18, 0)
	--DECLARE @WO_Days	NUMERIC
	  
	  
	  
	--SET @StrHoliday_Date = ''    
	--SET @StrWeekoff_Date = ''  
	--SET @Holiday_days = 0
	--SET @Cancel_Holiday=0
		  
	 
      
	DECLARE @current_Date AS Datetime
	SET @current_Date = GETDATE()
      
      
	DECLARE @I INT       
	SET @I = 1                      
	DECLARE @COUNT INT       
      
    Create table #COUNT
    (
		Emp_ID NUMERIC(18,0),
		Count_Emp NUMERIC(18,0)
    )
      
    INSERT	INTO #COUNT
	SELECT	Emp_ID,COUNT(Emp_ID)
	FROM    #Temp 
	GROUP BY EMP_ID
	HAVING COUNT(Emp_ID) > 0
     
	SELECT @COUNT=COUNT(Emp_ID)
	FROM #COUNT

	CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));
	CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);

	CREATE TABLE #EMP_WEEKOFF
	(
		Row_ID			NUMERIC,
		Emp_ID			NUMERIC,
		For_Date		DATETIME,
		Weekoff_day		VARCHAR(10),
		W_Day			numeric(4,1),
		Is_Cancel		BIT
	)
	CREATE CLUSTERED INDEX IX_Emp_WeekOff_EmpID_ForDate ON #EMP_WEEKOFF(Emp_ID, For_Date)

	DECLARE @CONSTRAINT VARCHAR(MAX)
	SELECT	@CONSTRAINT = COALESCE(@CONSTRAINT + '#', '') + CAST(EMP_ID AS VARCHAR(10))
	FROM	(SELECT DISTINCT EMP_ID FROM #Temp) T

    
	EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@TO_DATE, @All_Weekoff = 0, @Exec_Mode=0		


	WHILE ( @I <= @COUNT ) 
		BEGIN   
			SELECT  @Cmp_ID = Cmp_ID,
					@Emp_ID=Emp_ID,
					@Emp_Full_Name = Emp_Full_name,
					@MCount=MissPunchCount
			FROM    #Temp
			WHERE   CON = @I 
                  
                                          
            IF IsNull(@Emp_ID, 0) <> 0 
                BEGIN	                     
                    SELECT  @Work_Email = Work_Email,
							@Other_Email = Other_Email--,
							--@join_dt=Date_Of_Join,@Left_Date=Emp_Left_Date 
                    FROM    dbo.T0080_EMP_MASTER WITH (NOLOCK)
                    WHERE   Emp_ID = @Emp_ID                            
                END           			   
           	
			-- Added by rohit For Mail Not SEND on Week Off on 19082013
   --         Exec SP_EMP_HOLIDAY_DATE_GET @Emp_ID,@Cmp_ID,@current_Date,@current_Date,null,null,0,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,0,0,@StrWeekoff_Date
			--Exec SP_EMP_WEEKOFF_DATE_GET @Emp_ID,@Cmp_ID,@current_Date,@current_Date,@join_dt,@left_Date,0,@StrHoliday_Date,@StrWeekoff_Date output,@WO_Days output ,@Cancel_Weekoff output    	
					
			--IF CHARINDEX(CONVERT(VARCHAR(11),@current_Date,109),@StrWeekoff_Date,0) > 0
			IF EXISTS(SELECT 1 FROM #EMP_WEEKOFF WHERE For_Date = @current_Date AND Emp_ID=@Emp_ID)			
				BEGIN
					GOTO ABC;
				END
					
			--IF CHARINDEX(CONVERT(VARCHAR(11),@current_Date,109),@StrHoliday_Date,0) > 0
			IF EXISTS(SELECT 1 FROM #EMP_HOLIDAY WHERE For_Date = @current_Date AND Emp_ID=@Emp_ID)
				BEGIN
					GOTO ABC;
				END
								
           			
			DECLARE @profile AS VARCHAR(50)
			DECLARE @Server_link AS VARCHAR(500)
			SET @Server_link =''
       		SET @profile = ''
       					  
       		SELECT @profile = IsNull(DB_Mail_Profile_Name,''),@Server_link = IsNull(Server_link,'') FROM t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = @Cmp_Id
       					  
       		IF IsNull(@profile,'') = ''
       			BEGIN
       				SELECT @profile = IsNull(DB_Mail_Profile_Name,''),@Server_link = IsNull(Server_link,'') FROM t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = 0
       			END 
           		
			DECLARE @style VARCHAR(max)
			SET @style = 'text-align:center;border-collapse: collapse;border :1px solid;width:15%;font-size: 12px;border-color:#b0daff';
				  			
			DECLARE @TableHead VARCHAR(max),
					@TableTail VARCHAR(max)  

			SET @TableHead = '<html><head>
									<style>
											td {font-family: arial,sans-serif;font-size: 13px;}
									</style>
									</head>
									<blockquote class="gmail_quote" style="margin: 0 0 0 .8ex; border-left: 1px #ccc solid;
										padding-left: 1ex">
										<table style="background-color: #edf7fd; border-collapse: collapse;"
											align="center" cellpadding="5px" width="100%">
											<tbody>
												<tr>
													<td colspan="9">
														Hello ' + @Emp_Full_Name + ',
													</td>
												</tr>
												<tr>
													<td colspan="9"> 
														You have [' + CAST(@MCount AS VARCHAR(255)) + '] Miss Punches on below dates.
													</td>
												</tr>
												<tr>
													<td>
														Please refer <a href="' + @Server_link + '" style="text-decoration: bold;">Login to payroll hrms</a> to verify your attENDance date.
													</td>
												</tr>
												<tr>
													<td colspan="9">
														<table style="background-color: #edf7fd; border-collapse: collapse;border:1px solid #b0daff" cellpadding="3"  border="1px"
															cellspacing="0" width="100%">
															<tbody>
																<tr>
																	<td colspan="9" style="color: #3f628e; font-weight: bold">
																		Employee Miss Punch Details
																	</td>
																</tr>
																<tr>
																	<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
																		align="center" width="20%">
																		<b>Alpha Emp Code</b>
																	</td>
																	<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
																		align="center" width="20%">
																		<b>Employee Name</b>
																	</td>
																	<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
																		align="center" nowrap="" width="15%">
																		<b>For Date</b>
																	</td>
																	<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
																		align="center" nowrap="" width="15%">
																		<b>In Time</b>
																	</td>
																	<td style="border: 1px solid #b0daff; background-color: #bed9f0; color: #3f628e"
																		align="center" nowrap="" width="15%">
																		<b>Out Time</b>
																	</td>
																</tr>'
												SET @TableTail = '</tbody>
														</table>
													</td>
												</tr>
												<tr>
													<td colspan="9">
														&nbsp;
													</td>
												</tr>
												<tr>
													<td colspan="9" style="color: #757677" align="left">
														Thank you,<br>
														HR Department
													</td>
												</tr>
												</tbody>
										</table>
									</blockquote>
									</html>'
                DECLARE @Body AS VARCHAR(MAX)
				SET @Body = ( SELECT  
										Cast(Alpha_Emp_code AS VARCHAR(50)) AS [TD],
										Emp_Full_name  AS [TD],									
										IsNull(CONVERT(VARCHAR(12), for_Date, 103),'') AS [TD],
										IsNull(RIGHT(CONVERT(VARCHAR,in_time,0),7),'') AS [TD],
										IsNull(RIGHT(CONVERT(VARCHAR,Out_time,0),7),'-') AS [TD]
                                FROM    #Temp
                                WHERE   Emp_ID = @Emp_ID ORDER BY  Alpha_Emp_code For XML raw('tr'),ELEMENTS) 
				DECLARE @HREmail_ID	NVARCHAR(4000)
				SELECT @HREmail_ID =(SELECT TOP 1 Email_ID FROM T0011_LOGIN WITH (NOLOCK) where Cmp_ID=@Cmp_ID AND Is_HR = 1)
						
				IF IsNull(@HREmail_ID,'')='' 
					BEGIN
						SELECT @HREmail_ID = (SELECT TOP 1 Email_ID FROM T0011_LOGIN WITH (NOLOCK) where Is_HR = 1)
					END
				
				IF @CC_Email<>''
					BEGIN
						SET @HREmail_ID = @HREmail_ID + ';' + @CC_Email
					END
                     
           		IF IsNull(@Body,'')=''
					BEGIN
						GOTO ABC;
					END
           			
				SELECT  @Body = @TableHead + @Body + @TableTail   
           		  
           		SET @Body = REPLACE(@Body, '<td>', '<td style="'+ @style + '">')
           		             		 	           			              
                DECLARE @EmailNotification AS NUMERIC
                                  
                  
				SET @EmailNotification = 1
                IF @EmailNotification = 1 
					BEGIN		                     											
						IF @Work_Email <> '' 
							BEGIN
								EXEC msdb.dbo.sp_sEND_dbmail @profile_name = @profile, @recipients = @Work_Email, @subject = 'Miss Punch Reminder', @body = @Body, @body_format = 'HTML' , @copy_recipients = @HREmail_ID                                                                               
                            END
						ELSE 
							BEGIN
								IF @Other_Email <> '' 
									BEGIN
										EXEC msdb.dbo.sp_sEND_dbmail @profile_name = @profile, @recipients = @Other_Email, @subject = 'Miss Punch Reminder', @body = @Body, @body_format = 'HTML' , @copy_recipients = @HREmail_ID 
									END                                             
							END
					END
				
				ABC:	
				SELECT    @I = @I + 1     
            END           

END



