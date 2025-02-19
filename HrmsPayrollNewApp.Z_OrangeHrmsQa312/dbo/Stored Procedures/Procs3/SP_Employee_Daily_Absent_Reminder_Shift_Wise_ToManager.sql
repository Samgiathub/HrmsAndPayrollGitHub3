
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Employee_Daily_Absent_Reminder_Shift_Wise_ToManager]
@cmp_id_Pass Numeric(18,0) = 0,
@CC_Email Nvarchar(max) = ''
AS 

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN   
	
	DECLARE @DATE VARCHAR(11)
	DECLARE @SH_ID numeric
	DECLARE @CURRENT_DATE AS DATETIME
	DECLARE @HREMAIL_ID	NVARCHAR(4000)
	DECLARE @HR_NAME AS VARCHAR(255)
	DECLARE @BRANCH AS VARCHAR(255)
	DECLARE @I INT
	DECLARE @COUNT INT
	DECLARE  @TABLEHEAD NVARCHAR(MAX)
	DECLARE @TABLETAIL NVARCHAR(MAX)
	DECLARE @SUBJECT AS VARCHAR(100)
	DECLARE @PROFILE AS VARCHAR(50)
	
	SET @CURRENT_DATE = GETDATE()
	SET @SH_ID = DATEPART(HH,GETDATE())
	SET @DATE = CAST(GETDATE() AS varchar(11))
      
      IF OBJECT_ID('tempdb..#Temp') IS NOT NULL 
         BEGIN
               DROP TABLE #Temp
         END
       
		 CREATE TABLE #Temp 
		 (
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

            
		 INSERT  INTO #Temp
		 EXEC [SP_Get_Present_Absent_Emp_List] @CMP_ID_PASS,@DATE
    
    
		 -- Added by rohit on 15072013
		 Alter  table #Temp
		 Add  Shift_Id numeric(3,0);
	     
		 --ADDED BY RAMIZ ON 16/05/2017
		 Alter  table #Temp
		 Add  R_Emp_ID numeric;


		--Add by Nimesh 21 May, 2015
		--This sp retrieves the Shift Rotation as per given employee id and effective date.
		--it will fetch all employee's shift rotation detail if employee id is not specified.
		IF (OBJECT_ID('tempdb..#Rotation') IS NULL)
			CREATE TABLE #Rotation (R_EmpID numeric(18,0), R_DayName varchar(25), R_ShiftID numeric(18,0), R_Effective_Date DateTime);
		
		--The #Rotation table gets re-created in dbo.P0050_UNPIVOT_EMP_ROTATION stored procedure
		Declare @constraint varchar(max);
		Select @constraint = COALESCE(@constraint + '#', @constraint) + Cast(Emp_Id As Varchar) From #Temp
		Exec dbo.P0050_UNPIVOT_EMP_ROTATION @cmp_id_Pass, NULL, @DATE, @constraint

		--Updating default shift id
		update	#temp
		set		Shift_id = QA1.Shift_id
		from	#temp inner join
				(select Esd.Shift_id,Esd.Emp_id,For_date from T0100_Emp_Shift_Detail as ESD WITH (NOLOCK) inner join
				(select Emp_ID,MAX(For_date) as MAX_For_date from T0100_Emp_Shift_Detail WITH (NOLOCK)
					where for_date <= @DATE group by Emp_ID) Q1 on
				ESD.Emp_id = Q1.Emp_ID and esd.For_Date = q1.MAX_For_date) QA1 on
				#temp.Emp_id = QA1.Emp_ID

		--Added by Nimesh 21 April, 2015
		Update	#Temp
		SET		Shift_ID = R.R_ShiftID
		FROM	#Rotation R
		WHERE	Emp_Id=R_EmpID  AND R_DayName='Day' + CAST(DATEPART(d, @DATE) As Varchar) AND 
				R_Effective_Date = (Select Max(R_Effective_Date) FROM #Rotation R1 WHERE R_EmpID=Emp_Id AND R1.R_Effective_Date <= @DATE)

		--Updating Shift ID from Employee Shift Detail if defined where Shift_Type = 0 and exist in Employee Shift Detail
		Update	#Temp
		SET		Shift_ID = E_ShiftID
		FROM	(SELECT ESD.Shift_ID As E_ShiftID,ESD.Emp_ID As E_EmpID,ESD.Shift_Type
				FROM T0100_Emp_Shift_Detail AS ESD WITH (NOLOCK) WHERE For_Date = @DATE AND Cmp_ID=ISNULL(@cmp_id_Pass,Cmp_ID)) ES
		WHERE	ES.E_EmpID=Emp_Id AND E_EmpID IN  (SELECT R_EMPID FROM #Rotation R 
													WHERE R.R_Effective_Date<=@DATE)

	   --Updating Shift ID from Employee Shift Detail if defined where Shift_Type = 1 and not exist in Employee Shift Detail
		Update	#Temp
		SET		Shift_ID = E_ShiftID
		FROM	(SELECT ESD.Shift_ID As E_ShiftID,ESD.Emp_ID As E_EmpID,ESD.Shift_Type
				FROM T0100_Emp_Shift_Detail AS ESD WITH (NOLOCK) WHERE For_Date = @DATE  
					AND Cmp_ID=ISNULL(@cmp_id_Pass,Cmp_ID) AND IsNull(Shift_Type,0) = 1) ES
		WHERE	ES.E_EmpID=Emp_Id  AND E_EmpID NOT IN  (SELECT R_EMPID FROM #Rotation R 
													WHERE R.R_Effective_Date<=@DATE)
		--End Nimesh

		CREATE TABLE #Shift_Cons 
		(      
			Shift_ID numeric  
		)
		
		INSERT INTO #SHIFT_CONS  
		SELECT shift_id from dbo.T0040_SHIFT_MASTER WITH (NOLOCK)
		WHERE CAST(left(Shift_St_Time,2) AS NUMERIC(2,0))  <= @Sh_id and 
		CAST(left(Shift_St_Time,2) AS NUMERIC(2,0)) >= @Sh_id - 2

		Delete #Temp Where Status <> 'A' OR shift_id not in (select Shift_id from #Shift_Cons )
		-- ended by rohit on 15072013
		
		--UPDATING MAX REPORTING MANAGER IN #TEMP TABLE--
		  
		UPDATE LA
		SET R_EMP_ID=Qry_Reporting.R_Emp_ID
		From #Temp LA 
		LEFT OUTER JOIN
			(
				SELECT     R1.Emp_ID, R1.Effect_Date, R1.R_Emp_ID, Em.Emp_Full_Name
				FROM          dbo.T0090_EMP_REPORTING_DETAIL AS R1 WITH (NOLOCK)
				INNER JOIN
						  (
						   SELECT     MAX(Effect_Date) AS Effect_Date, Emp_ID
						   FROM          dbo.T0090_EMP_REPORTING_DETAIL AS R3 WITH (NOLOCK)
						   WHERE      Effect_Date < GETDATE()
						   GROUP BY Emp_ID
						   ) AS R3_1 ON R1.Emp_ID = R3_1.Emp_ID AND R1.Effect_Date = R3_1.Effect_Date
				LEFT OUTER JOIN dbo.T0080_EMP_MASTER AS Em WITH (NOLOCK) ON R1.R_Emp_ID = Em.Emp_ID
			) AS Qry_Reporting ON LA.Emp_ID = Qry_Reporting.Emp_ID
     
      
      
       --Removed Old Code By Ramiz on 27/04/2017 and changed the Logic--
		 CREATE TABLE #TempSuperiore
			  ( 
				CON INT IDENTITY(1, 1),
				Cmp_ID NUMERIC(18, 0),
				Emp_Superior NUMERIC(18, 0),
				Emp_Superior_Name nvarchar(200),
				EmployeeCount NUMERIC(18, 0) DEFAULT 0
			  )   

		INSERT    INTO #TempSuperiore
                ( Cmp_ID,
                  Emp_Superior,     
                  Emp_Superior_Name             
                )
	   SELECT DISTINCT LA.CMP_ID,R_EMP_ID,REM.EMP_FULL_NAME 
	   FROM #TEMP LA INNER JOIN T0080_EMP_MASTER REM WITH (NOLOCK) ON LA.R_EMP_ID=REM.EMP_ID
    

	  UPDATE    #TempSuperiore
	  SET    EmployeeCount = LQ.Ecount
	  FROM      #TempSuperiore LA
				INNER JOIN 
				( 
				  SELECT COUNT(LA.Emp_ID) AS Ecount,ED.R_Emp_ID
				  FROM   #Temp LA 
				  LEFT JOIN T0090_EMP_REPORTING_DETAIL ED WITH (NOLOCK) on LA.Emp_Id =ED.Emp_ID
				  INNER JOIN
					  (
					   SELECT     MAX(Effect_Date) AS Effect_Date, Emp_ID
					   FROM          dbo.T0090_EMP_REPORTING_DETAIL AS R3 WITH (NOLOCK)
					   WHERE      (Effect_Date < GETDATE())
					   GROUP BY Emp_ID
					   ) AS R3_1 ON ED.Emp_ID = R3_1.Emp_ID AND ED.Effect_Date = R3_1.Effect_Date
				  GROUP BY ED.R_Emp_ID
				  HAVING COUNT(LA.Emp_ID) > 0
				 ) LQ ON LA.Emp_Superior = LQ.R_Emp_ID 
	
	
	
	  DECLARE @Emp_Superior AS NUMERIC(18, 0)
      DECLARE @Emp_Superior_Name AS varchar(200)
      DECLARE @Work_Email AS NVARCHAR(4000)
      DECLARE @Other_Email AS NVARCHAR(4000)
      DECLARE @Emp_ID AS NUMERIC(18, 0)
      DECLARE @Cmp_ID AS NUMERIC(18, 0)      
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


		DECLARE CUR_COMPANY CURSOR FOR                    
			SELECT CMP_ID FROM #HR_EMAIL ORDER BY CMP_ID
		OPEN CUR_COMPANY                      
		FETCH NEXT FROM CUR_COMPANY INTO @CMP_ID
		WHILE @@FETCH_STATUS = 0                    
			
			BEGIN
				SET @StrHoliday_Date = ''    
				SET @StrWeekoff_Date = ''  
				SET @Holiday_days	= 0
				SET @Cancel_Holiday =0
				SET @I = 1
						
				SELECT    @COUNT = COUNT(CON) FROM      #TempSuperiore      

				WHILE ( @I <= @COUNT ) 
					BEGIN
					
						SELECT	@Cmp_ID = Cmp_ID,
								@Emp_Superior = Emp_Superior,
								@ECount = EmployeeCount,
								@Emp_Superior_Name  = Emp_Superior_Name
						FROM      #TempSuperiore
						WHERE     CON = @I 
					                                             
						IF ISNULL(@Emp_Superior, 0) <> 0 
							BEGIN								
								SELECT   @Work_Email = Work_Email,@Other_Email = Other_Email,@join_dt=Date_Of_Join,@Left_Date=Emp_Left_Date 
								FROM     dbo.T0080_EMP_MASTER WITH (NOLOCK)
								WHERE    Emp_ID = @Emp_Superior 
							END           			   

								-- Added by rohit For Mail Not Send on Week Off on 19082013
							Exec SP_EMP_HOLIDAY_DATE_GET @Emp_Superior,@Cmp_ID,@current_Date,@current_Date,null,null,0,@StrHoliday_Date output,@Holiday_days output,@Cancel_Holiday output,0,0,@StrWeekoff_Date
							Exec SP_EMP_WEEKOFF_DATE_GET @Emp_Superior,@Cmp_ID,@current_Date,@current_Date,@join_dt,@left_Date,0,@StrHoliday_Date,@StrWeekoff_Date output,@WO_Days output ,@Cancel_Weekoff output    	
							
							If CHARINDEX(CONVERT(VARCHAR(11),@current_Date,109),@StrWeekoff_Date,0) > 0
								BEGIN
									GOTO ABC;
								END
							
							If CHARINDEX(CONVERT(VARCHAR(11),@current_Date,109),@StrHoliday_Date,0) > 0
								BEGIN
									GOTO ABC;
								END
								
								SELECT TOP 1 @HREmail_ID = Email_ID, @HR_Name = Emp_Full_Name
								FROM T0011_LOGIN L WITH (NOLOCK) Left Outer Join T0080_EMP_MASTER E WITH (NOLOCK) on L.Emp_ID = E.Emp_ID
								Where L.Cmp_ID=@Cmp_ID AND Is_HR = 1
									
								IF @CC_Email<>''
									BEGIN 
										SET @HREMAIL_ID = @HREMAIL_ID + ';' + @CC_EMAIL
									END
										     
								  SET @TableHead = '<html><head>' +
												  '<style>' +
												  'td {border: solid black 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:8pt;} ' +
												  '</style>' +
												  '</head>' +
												  '<body>
												  <div style=" font-family:Arial, Helvetica, sans-serif; color:#000;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">
												  Dear ' + @Emp_Superior_Name + ' </div>	<br/>
												  <table width="800" border="0" align="center" cellpadding="0" cellspacing="0" style="border:1px solid #cacaca; border-radius: 10px 10px 10px 10px;" >
												  <tr>
													 <td align="center" valign="middle"><table width="800" border="0" cellspacing="0" cellpadding="0">
														<tr>
														<td height="9" align="center" valign="middle" ></td>
														</tr>
													  <tr>
														<td width="800" height="24" align="center" valign="middle" style="background:#0b0505; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">Today''s Absent Report ( ' + @Date + ') </td>
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
														  '<td align=center><b><span style="font-size:small">Branch</span></b></td>' +
														  '<td align=center><b><span style="font-size:small">Department</span></b></td>' +
														  '<td align=center><b><span style="font-size:small">Designation</span></b></td>' +
														  '<td align=center><b><span style="font-size:small">Status</span></b></td>'
								                                     
								  SET @TableTail = '</table></body></html>';                  	
								
											
								  DECLARE @Body AS VARCHAR(MAX)
								  SET @Body = ( SELECT  
														emp_Code  as [TD],
														Emp_name  as [TD],
														ISNULL(Branch_name,'-') as [TD],
														Isnull(Dept_Name,'-') as [TD],
														Isnull(Desig_Name,'-') as [TD],
														Status As [TD]
												FROM    #Temp LA 
												WHERE   LA.Cmp_ID = @Cmp_Id AND R_EMP_ID=@Emp_Superior 
												ORDER BY  Emp_code For XML raw('tr'), ELEMENTS) 
												
	                        
									IF ISNULL(@BODY,'')=''
										BEGIN
											GOTO ABC;
										END	
						
									
								  SELECT  @BODY = @TABLEHEAD + @BODY + @TABLETAIL  
								  
								  SET @SUBJECT = 'Absent Report ( ' + @Date + ' ) '
					       		  SET @PROFILE = ''
			   					  
								  SELECT @PROFILE = ISNULL(DB_MAIL_PROFILE_NAME,'') FROM T9999_REMINDER_MAIL_PROFILE WITH (NOLOCK) WHERE CMP_ID = @CMP_ID
			   					  
								  IF ISNULL(@PROFILE,'') = ''
									BEGIN
										SELECT @PROFILE = ISNULL(DB_MAIL_PROFILE_NAME,'') FROM T9999_REMINDER_MAIL_PROFILE WITH (NOLOCK) WHERE CMP_ID = 0
									END  		 	           			              

								IF @Work_Email <> '' 
								  BEGIN
									EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @Work_Email, @subject = @subject, @body = @Body, @body_format = 'HTML' , @copy_recipients = @HREmail_ID
								  END
								ELSE IF @Other_Email <> '' 
								  BEGIN
									EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @Other_Email, @subject = @subject, @body = @Body, @body_format = 'HTML' , @copy_recipients = @HREmail_ID                                    
								  END      

								SET @HREMAIL_ID = ''
								SET @HR_NAME = ''
								SET @ECOUNT = 0
								
							ABC:	
								SELECT    @I = @I + 1       
						END      
								
				 FETCH NEXT FROM CUR_COMPANY INTO @CMP_ID
			   END                    
			CLOSE CUR_COMPANY                    
			DEALLOCATE CUR_COMPANY         
END

