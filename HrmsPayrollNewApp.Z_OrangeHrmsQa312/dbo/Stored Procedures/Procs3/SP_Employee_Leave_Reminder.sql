
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Employee_Leave_Reminder]
	@cmp_id_Pass NUMERIC(18,0) = 0,
	@CC_Email NVARCHAR(max) = ''
AS 
BEGIN 

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	DECLARE @DATE VARCHAR(20)   
	DECLARE @Approval_day AS NUMERIC    
	DECLARE @ReminderTemplate AS NVARCHAR(4000)
	--Added By Mukti(start)07112015
	DECLARE @leave_app_id_cur AS NUMERIC(18,0) 
	DECLARE @is_approve_cur AS NUMERIC(18,0) 
	DECLARE @Emp_id_cur AS NUMERIC(18,0) 
	DECLARE @Leave_ID_cur AS NUMERIC(18,0)
	DECLARE @Rpt_Level_max NUMERIC(18,0)
	DECLARE @S_Emp_ID_cur AS NUMERIC(18,0)
	DECLARE @is_Rm AS tinyint
	DECLARE @is_Bm AS TINYINT
	DECLARE @Rpt_Level_cur AS TinyInt
	DECLARE @emp_branch AS NUMERIC
	--Added By Mukti(END)07112015
	  
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
		Cmp_ID NUMERIC(18, 0),
		Emp_ID NUMERIC(18, 0),
		Emp_code VARCHAR(255),
		Emp_name VARCHAR(255),
		Leave_name VARCHAR(255),
		Emp_Superior NUMERIC(18, 0),
		Leave_Application_ID NUMERIC(18, 0),
		Leave_App_Date DATETIME,
		From_Date DATETIME,
		To_Date DATETIME
    )  
       
  --Commented By Mukti(start)16112015
     --INSERT    INTO #Temp
     --           ( Cmp_ID,
     --             Emp_ID,
     --             Emp_code,
     --             Emp_name,
     --             Leave_name,
				 -- Emp_Superior,
     --             Leave_Application_ID,
     --             Leave_App_Date,
     --             From_Date,
     --             to_date                   
     --           )
     --           ( SELECT    LA.Cmp_Id,
     --                       LA.Emp_Id,
     --                       Alpha_Emp_Code,
     --                       Emp_Full_Name,
     --                       LM.Leave_Name,
     --                       ED.R_Emp_ID,
     --                       la.Leave_Application_Id,
     --                       CONVERT(VARCHAR(10), LA.Application_Date,101),
     --                       CONVERT(VARCHAR(10),LAD.From_Date, 101),
     --                       CONVERT(VARCHAR(10),LAD.To_Date,101)
     --             FROM      dbo.T0100_Leave_Application LA
					--		INNER JOIN dbo.T0110_LEAVE_APPLICATION_DETAIL LAD ON LA.Leave_Application_ID  = LAD.Leave_Application_ID
     --                       INNER JOIN dbo.T0080_EMP_MASTER ON LA.Emp_Id = dbo.T0080_EMP_MASTER.Emp_ID   
     --                       INNER JOIN dbo.T0040_LEAVE_MASTER LM ON LM.Leave_ID = lad.Leave_ID 
     --                       LEFT OUTER JOIN T0090_EMP_REPORTING_DETAIL ED ON LA.Emp_ID = ED.Emp_ID                         
					--		INNER JOIN (SELECT MAX(Effect_Date) AS Effect_Date, Emp_ID FROM T0090_EMP_REPORTING_DETAIL	--Ankit 02042015
					--						WHERE Effect_Date<=GETDATE() GROUP BY emp_ID) RQry ON  ED.Emp_ID = RQry.Emp_ID AND ED.Effect_Date = RQry.Effect_Date
     --             WHERE     LA.Application_Status = 'P'   AND la.cmp_id = IsNull(@cmp_id_Pass,la.cmp_id)                          
     --           )  
      --Commented By Mukti(END)16112015           
                 
       --Added By Mukti(start)16112015             
    Create table #LeaveAppRrd
	(		 
		leave_app_id	NUMERIC(18,0),
		is_approve tinyint default 0
	)  
			 
	INSERT INTO #LeaveAppRrd
	SELECT Leave_Application_ID,1 
	FROM T0100_LEAVE_APPLICATION WITH (NOLOCK)
	WHERE (Application_Status = 'P') AND Cmp_ID = IsNull(@cmp_id_Pass,cmp_id)  
		AND Leave_Application_ID NOT IN 
		(SELECT LA.Leave_Application_ID FROM T0100_LEAVE_APPLICATION LA WITH (NOLOCK)
		INNER JOIN T0115_Leave_Level_Approval lla WITH (NOLOCK) ON LA.Leave_Application_ID = lla.Leave_Application_ID)
		AND Application_Status='P' AND Cmp_ID = IsNull(@cmp_id_Pass,cmp_id)  
		
    INSERT INTO #LeaveAppRrd
	SELECT DISTINCT LA.Leave_Application_ID,1 FROM T0100_LEAVE_APPLICATION LA WITH (NOLOCK)
	left JOIN (SELECT llas.* FROM T0115_Leave_Level_Approval llas WITH (NOLOCK) INNER JOIN
	(
	SELECT MAX(Rpt_Level) AS rpt_level,Leave_Application_ID FROM T0115_Leave_Level_Approval WITH (NOLOCK)
	GROUP BY Leave_Application_ID
	) AS qry
	on llas.Leave_Application_ID = qry.Leave_Application_ID AND llas.Rpt_Level = qry.rpt_level) AS  lla ON LA.Leave_Application_ID = lla.Leave_Application_ID 
	WHERE lla.Cmp_ID = IsNull(@cmp_id_Pass,lla.Cmp_ID)  AND LA.Application_Status='P' 
		
		
  -- SELECT * FROM #LeaveAppRrd    
         
    DECLARE Leave_Mail_Cur CURSOR FAST_FORWARD FOR 
	SELECT	lar.leave_app_id,lar.is_approve 
	FROM	#LeaveAppRrd LAR	--WHERE 	lar.leave_app_id = 1108	

	OPEN Leave_Mail_Cur
	FETCH NEXT FROM Leave_Mail_Cur INTO  @leave_app_id_cur,@is_approve_cur
	
	WHILE @@FETCH_STATUS = 0
		BEGIN        
			IF NOT EXISTS(SELECT 1 FROM T0115_Leave_Level_Approval WITH (NOLOCK) WHERE Leave_Application_ID = @leave_app_id_cur)
				BEGIN								
					INSERT INTO #Temp(Cmp_ID,Emp_ID,Emp_code,Emp_name,Leave_name,Emp_Superior,Leave_Application_ID,Leave_App_Date,From_Date,to_date)
					SELECT	DISTINCT LA.Cmp_Id,LA.Emp_Id,Alpha_Emp_Code,Emp_Full_Name,LM.Leave_Name,ED.R_Emp_ID,la.Leave_Application_Id,
							CONVERT(VARCHAR(10), LA.Application_Date,101),CONVERT(VARCHAR(10),LAD.From_Date, 101),CONVERT(VARCHAR(10),LAD.To_Date,101)
					FROM    dbo.T0100_Leave_Application LA WITH (NOLOCK)
							INNER JOIN dbo.T0110_LEAVE_APPLICATION_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Application_ID  = LAD.Leave_Application_ID
                            INNER JOIN dbo.T0080_EMP_MASTER WITH (NOLOCK) ON LA.Emp_Id = dbo.T0080_EMP_MASTER.Emp_ID   
                            INNER JOIN dbo.T0040_LEAVE_MASTER LM WITH (NOLOCK)  ON LM.Leave_ID = lad.Leave_ID 
                            INNER JOIN dbo.T0095_EMP_SCHEME ES WITH (NOLOCK) ON ES.emp_id=dbo.T0080_EMP_MASTER.Emp_ID 
                            LEFT OUTER JOIN T0090_EMP_REPORTING_DETAIL ED WITH (NOLOCK) ON LA.Emp_ID = ED.Emp_ID                         
							INNER JOIN (SELECT	MAX(Effect_Date) AS Effect_Date, Emp_ID 
										FROM	T0090_EMP_REPORTING_DETAIL	WITH (NOLOCK) --Ankit 02042015
										WHERE	Effect_Date<=GETDATE() 
										GROUP BY emp_ID) RQry ON ED.Emp_ID = RQry.Emp_ID AND ED.Effect_Date = RQry.Effect_Date
					WHERE     LA.Application_Status = 'P' AND la.cmp_id = IsNull(@cmp_id_Pass,la.cmp_id) AND LA.Leave_Application_ID  = @leave_app_id_cur                        

				END
			ELSE
				BEGIN
					IF NOT EXISTS(SELECT 1 FROM #Temp WHERE Leave_Application_ID = @leave_app_id_cur)												
						BEGIN
							SET @S_Emp_ID_cur=0
							
							SELECT  @Emp_id_cur = Emp_ID , @Leave_ID_cur = Leave_ID ,@Rpt_Level_cur = Rpt_Level + 1
							FROM	T0115_Leave_Level_Approval LLA WITH (NOLOCK)
							WHERE	Leave_Application_ID = @leave_app_id_cur 
									AND LLA.Rpt_Level IN (	SELECT	MAX(Rpt_Level) Rpt_Level 
															FROM	T0115_Leave_Level_Approval LLA1 WITH (NOLOCK)
															WHERE	Leave_Application_ID = @leave_app_id_cur)
			
		
							SELECT	@S_Emp_ID_cur = App_Emp_ID,@is_Rm = Is_RM,@is_Bm = Is_BM 
							FROM	T0050_Scheme_Detail WITH (NOLOCK)
							WHERE	Rpt_Level = (@Rpt_Level_cur)
									AND Scheme_Id = (SELECT TOP 1 QES.Scheme_ID 
													FROM	T0095_EMP_SCHEME QES WITH (NOLOCK)
															INNER JOIN (SELECT	MAX(effective_date) AS effective_date,emp_id 
																		FROM	T0095_EMP_SCHEME IES WITH (NOLOCK)
																		WHERE	IES.effective_date <= GETDATE() AND Emp_ID = @Emp_id_cur AND Type = 'Leave'
																		GROUP BY emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date AND Type = 'Leave'
													)
			    					AND @Leave_ID_cur IN (SELECT CAST(data AS NUMERIC(18, 0)) FROM dbo.Split(Leave, '#')) 	
				    	
							IF @S_Emp_ID_cur = 0  AND @is_Rm =1 
								BEGIN
									SELECT	@S_Emp_ID_cur = R_Emp_ID 
									FROM	T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)
											INNER JOIN (SELECT	MAX(Effect_Date) AS Effect_Date,emp_id 
														FROM	T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
														WHERE	ERD1.Effect_Date <= GETDATE() AND Emp_ID = @Emp_id_cur
														GROUP BY Emp_ID) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
					 				WHERE	ERD.Emp_ID = @Emp_id_cur
								END
							ELSE IF @S_Emp_ID_cur = 0  AND @is_Bm =1 
								BEGIN							
									SELECT	@S_Emp_ID_cur = Emp_id FROM T0095_MANAGERS WITH (NOLOCK)
									WHERE	Effective_Date = (SELECT MAX(Effective_Date) FROM dbo.T0095_MANAGERS WITH (NOLOCK) WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()) AND dbo.T0095_MANAGERS.branch_id = @emp_branch
								END
										 
													
							INSERT	INTO #Temp(Cmp_ID,Emp_ID,Emp_code,Emp_name,Leave_name,Emp_Superior,Leave_Application_ID,Leave_App_Date,From_Date,to_date)
							SELECT	DISTINCT  LA.Cmp_Id,LA.Emp_Id,Alpha_Emp_Code,Emp_Full_Name,LM.Leave_Name,@S_Emp_ID_cur,la.Leave_Application_Id,
									CONVERT(VARCHAR(10), LA.Application_Date,101),CONVERT(VARCHAR(10),LAD.From_Date, 101),CONVERT(VARCHAR(10),LAD.To_Date,101)
							FROM    dbo.T0100_Leave_Application LA WITH (NOLOCK) 
									INNER JOIN dbo.T0110_LEAVE_APPLICATION_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Application_ID  = LAD.Leave_Application_ID
									INNER JOIN dbo.T0080_EMP_MASTER WITH (NOLOCK) ON LA.Emp_Id = dbo.T0080_EMP_MASTER.Emp_ID   
									INNER JOIN dbo.T0040_LEAVE_MASTER LM WITH (NOLOCK)  ON LM.Leave_ID = lad.Leave_ID 
									INNER JOIN dbo.T0095_EMP_SCHEME ES WITH (NOLOCK)  ON ES.emp_id=dbo.T0080_EMP_MASTER.Emp_ID 
							WHERE   LA.Application_Status = 'P'   AND la.cmp_id = IsNull(@cmp_id_Pass,la.cmp_id) 
									AND LA.Leave_Application_ID = @leave_app_id_cur          					
						END
				END
                 
			FETCH NEXT FROM Leave_Mail_Cur INTO @leave_app_id_cur,@is_approve_cur
		END
	CLOSE Leave_Mail_Cur
	DEALLOCATE Leave_Mail_Cur	
   
	--Added By Mukti(END)16112015             
           
    CREATE TABLE #TempSuperiore(
		CON INT IDENTITY(1, 1),
        Cmp_ID NUMERIC(18, 0),
        Emp_Superior NUMERIC(18, 0),
        Emp_Superior_Name NVARCHAR(200),
        EmployeeCount NUMERIC(18, 0) DEFAULT 0,
    )   
      
    INSERT	INTO #TempSuperiore(Cmp_ID,Emp_Superior,Emp_Superior_Name)				 
    SELECT	DISTINCT LA.cmp_ID,LA.Emp_Superior,EM.Emp_Full_Name 
    FROM	#Temp LA 
			INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON LA.Emp_Superior = EM.emp_id
    WHERE	LA.Cmp_ID = IsNull(@cmp_id_Pass,la.cmp_id)     
    --Added By Mukti(END)16112015 
                
    UPDATE  #TempSuperiore
    SET     EmployeeCount = LQ.Ecount
    FROM    #TempSuperiore LA
			INNER JOIN(	SELECT	COUNT(Emp_ID) AS Ecount,Emp_Superior
                        FROM	#Temp
						GROUP BY Emp_Superior
						HAVING	COUNT(Emp_ID) > 0
                      ) LQ ON LA.Emp_Superior = LQ.Emp_Superior
                                                      

	DECLARE @Emp_Superior AS NUMERIC(18, 0)
	DECLARE @Emp_Full_Name AS VARCHAR(255)
	DECLARE @Emp_Superior_Name AS VARCHAR(200)
	DECLARE @Work_Email AS NVARCHAR(4000)
	DECLARE @Other_Email AS NVARCHAR(4000)
	DECLARE @Emp_ID AS NUMERIC(18, 0)
	DECLARE @Cmp_ID AS NUMERIC(18, 0)      
	DECLARE @Leave_Application_ID AS NUMERIC(18, 0)
	DECLARE @Leave_App_Date AS DATETIME
	DECLARE @Leave_From_date AS DATETIME
	DECLARE @Leave_To_date AS DATETIME
	DECLARE @Status AS DATETIME
	DECLARE @PENDingApplication AS NUMERIC(18, 0)
	DECLARE @Annual_Leave_App_ReminderDate AS DATETIME
	DECLARE @ECount AS NUMERIC(18, 0)
      
	---- Added by rohit ON 19082013
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
		  
	-- ENDed by rohit ON 19082013

      
	DECLARE @current_Date AS Datetime
	SET @current_Date = GETDATE()
      

	  
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

    
	EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@current_Date, @TO_DATE=@current_Date, @All_Weekoff = 0, @Exec_Mode=0		


      
	DECLARE @I INT       
	SET @I = 1                      

	DECLARE @COUNT INT       

	SELECT    @COUNT = COUNT(CON)
	FROM      #TempSuperiore      
       
    WHILE ( @I <= @COUNT ) 
		BEGIN         
			SELECT  @Cmp_ID = Cmp_ID,
                    @Emp_Superior = Emp_Superior,
                    @ECount = EmployeeCount,
                    @Emp_Superior_Name  = Emp_Superior_Name
            FROM    #TempSuperiore
            WHERE   CON = @I 
                  
                                
            
			----Get Superior Work Email AND Other Email Detail FOR Particulare Employee.        
              
                                           
			IF IsNull(@Emp_Superior, 0) <> 0 
				BEGIN								
					SELECT   @Work_Email = Work_Email,
							@Other_Email = Other_Email
							--,@join_dt=Date_Of_Join,@Left_Date=Emp_Left_Date 
					FROM     dbo.T0080_EMP_MASTER WITH (NOLOCK)
					WHERE    Emp_ID = @Emp_Superior 
							--AND Cmp_ID = @Cmp_ID
				END           			   
           			
           		-- Added by rohit FOR Mail NOT SEND ON Week Off ON 19082013
   --         Exec SP_EMP_HOLIDAY_DATE_GET @Emp_Superior,@Cmp_ID,@current_Date,@current_Date,null,null,0,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,0,0,@StrWeekoff_Date
			--Exec SP_EMP_WEEKOFF_DATE_GET @Emp_Superior,@Cmp_ID,@current_Date,@current_Date,@join_dt,@left_Date,0,@StrHoliday_Date,@StrWeekoff_Date output,@WO_Days output ,@Cancel_Weekoff output    	
					
			--IF charindex(CONVERT(VARCHAR(11),@current_Date,109),@StrWeekoff_Date,0) > 0
			IF EXISTS(SELECT 1 FROM #EMP_WEEKOFF WHERE For_Date = @current_Date AND Emp_ID=@Emp_ID)			
				BEGIN
					GOTO ABC;
				END
					
			--IF CHARINDEX(CONVERT(VARCHAR(11),@current_Date,109),@StrHoliday_Date,0) > 0
			IF EXISTS(SELECT 1 FROM #EMP_HOLIDAY WHERE For_Date = @current_Date AND Emp_ID=@Emp_ID)
				BEGIN
					GOTO ABC;
				END

						
			-- ENDed by rohit ON 19082013
			-- Added by rohit ON 28-nov-2013
           			
			DECLARE @profile AS VARCHAR(50)
			DECLARE @Server_link AS VARCHAR(500)
			SET @Server_link =''
			SET @profile = ''
       					  
			SELECT @profile = IsNull(DB_Mail_Profile_Name,''),@Server_link = IsNull(Server_link,'') FROM t9999_Reminder_Mail_Profile WITH (NOLOCK) WHERE cmp_id = @Cmp_Id
       					  
			IF IsNull(@profile,'') = ''
				BEGIN
					SELECT @profile = IsNull(DB_Mail_Profile_Name,''),@Server_link = IsNull(Server_link,'') FROM t9999_Reminder_Mail_Profile WITH (NOLOCK) WHERE cmp_id = 0
				END 
			--ENDed by rohit ON 28-nov-2013
           		
			  ---ALTER dynamic template FOR Employee.				
			DECLARE @TableHead VARCHAR(max),
					@TableTail VARCHAR(max)
					
			SET @TableHead = '<html><head>' +
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
										<td width="800" height="24" align="center" valign="middle" style="background:#0b0505; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">Leave Approval Reminder</td>
									  </tr>
										  <tr>
											<td height="4" align="center" valign="middle"></td>
										  </tr>
										  <tr>
											<td width="800" align="center" valign="middle" style="border:1px solid #cacaca; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#000000;  text-decoration:none; text-align:center; font-size:12px;">You have [ ' + CAST(@ECount AS VARCHAR(255)) + ' ] PENDing Leave Application that need to be approve.</td>
										  </tr>
										  <tr>
											<td width="800" align="center" valign="middle" style="border:1px solid #cacaca; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#000000;  text-decoration:none; text-align:center; font-size:12px;">
											 <a href="' + @Server_link + '" style="text-decoration: bold;">
												<div align="center" class="White" style="padding-left: 40px">
                                                click here FOR login to payroll Hrms </div>
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
										  '<td align=center><b>Leave Name</b></td>' +
										  '<td align=center><b>From</b></td>' +
										  '<td align=center><b>To</b></td>' +		                  
										  '<td align=center><b>Status</b></td></tr>'
										                                     
            SET @TableTail = '</table></body></html>';                  	
            DECLARE @Body AS VARCHAR(MAX)
                  
                   
                  
            SET @Body = (SELECT  
								--'' AS  [TRRow],
								emp_Code  AS [TD],
								Emp_name  AS [TD],
								CONVERT(VARCHAR(12), Leave_App_Date, 103) AS [TD],
								Leave_Name AS [TD],
                                CONVERT(VARCHAR(12),From_Date, 103) AS [TD],
                                CONVERT(VARCHAR(12),To_Date,103) AS [TD],
                                'PENDing' AS [TD]
                                                                                 
						FROM    #Temp
						WHERE   Emp_Superior = @Emp_Superior ORDER BY  Emp_code FOR XML raw('tr'), ELEMENTS) 
                             
			DECLARE @HREmail_ID	NVARCHAR(4000)
	
			SELECT @HREmail_ID = (SELECT TOP 1 Email_ID FROM T0011_LOGIN WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID AND Is_HR = 1)

			IF IsNull(@HREmail_ID,'')='' 
				BEGIN
					SELECT @HREmail_ID = (SELECT TOP 1 Email_ID FROM T0011_LOGIN WITH (NOLOCK) WHERE Is_HR = 1)
				END
                  
			IF @CC_Email<>''
				BEGIN
					SET @HREmail_ID = @HREmail_ID + ';' + @CC_Email
				END
                       
			--IF (@HREmail_ID <> '')
			-- BEGIN
			--    EXEC msdb.dbo.sp_sEND_dbmail @profile_name = 'Com-i2', @recipients = @HREmail_ID,  @subject = 'Leave Approval Reminder', @body = @Body, @body_format = 'HTML'                               
                           
			-- END
					
           	IF IsNull(@Body,'')=''
				BEGIN
					GOTO ABC;
				END

           	SELECT  @Body = @TableHead + @Body + @TableTail              		 	           			              
            DECLARE @EmailNotification AS NUMERIC
            --SELECT    @EmailNotification = EMAIL_NTF_SENT
            --FROM      T0040_EMAIL_NOTIFICATION_CONFIG
            --WHERE     EMAIL_NTF_DEF_ID = 2
                  
            SET @EmailNotification = 1
            IF @EmailNotification = 1 
                BEGIN		                     											
                    IF @Work_Email <> '' 
                        BEGIN                                   
                            --EXEC msdb.dbo.sp_sEND_dbmail @profile_name = 'Absolute_Mail', @recipients = @Work_Email, @subject = 'Leave Approval Reminder', @body = @Body, @body_format = 'HTML' , @copy_recipients = @HREmail_ID                                         
                            EXEC msdb.dbo.sp_sEND_dbmail @profile_name = @profile, @recipients = @Work_Email, @subject = 'Leave Approval Reminder', @body = @Body, @body_format = 'HTML' , @copy_recipients = @HREmail_ID                                                                               
                            --EXEC msdb.dbo.sp_sEND_dbmail @profile_name = 'com-i2', @recipients = 'Rohit@orangewebtech.com', @subject = 'Leave Approval Reminder', @body = @Body, @body_format = 'HTML' , @copy_recipients = 'Rohit@orangewebtech.com'                                         
                        END
                    ELSE 
						BEGIN
							IF @Other_Email <> '' 
								BEGIN      
									--EXEC msdb.dbo.sp_sEND_dbmail @profile_name = 'Absolute_Mail', @recipients = @Other_Email, @subject = 'Leave Approval Reminder', @body = @Body, @body_format = 'HTML' , @copy_recipients = @HREmail_ID          
									EXEC msdb.dbo.sp_sEND_dbmail @profile_name = @profile, @recipients = @Other_Email, @subject = 'Leave Approval Reminder', @body = @Body, @body_format = 'HTML' , @copy_recipients = @HREmail_ID                                              
									--EXEC msdb.dbo.sp_sEND_dbmail @profile_name = 'com-i2', @recipients = 'Rohit@orangewebtech.com', @subject = 'Leave Approval Reminder', @body = @Body, @body_format = 'HTML' , @copy_recipients = 'Rohit@orangewebtech.com'                                          
								END                                             
						END
                END                    
                     
                    --SELECT @Work_Email,@Other_Email
		ABC:	
                     
			SELECT    @I = @I + 1       
		END           
END


