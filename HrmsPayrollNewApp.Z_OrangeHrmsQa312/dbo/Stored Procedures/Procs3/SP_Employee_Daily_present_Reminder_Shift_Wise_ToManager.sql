

--Created by rohit for present report Sent to manager Shift Wise. on 05082014
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Employee_Daily_present_Reminder_Shift_Wise_ToManager]
@cmp_id_Pass Numeric(18,0) = 0,
@CC_Email Nvarchar(max) = ''
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN   

	  DECLARE @DATE VARCHAR(11)   
      DECLARE @Approval_day AS NUMERIC    
      DECLARE @ReminderTemplate AS NVARCHAR(4000)
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

            
	 INSERT    INTO #Temp
     exec [SP_Get_Present_Absent_Emp_List] @cmp_id_Pass,@DATE


     
     -- Added by rohit on 15072013
     Alter  table #Temp
     Add  Shift_Id numeric(3,0) , Shift_Name varchar(100);
	 


	--Add by Nimesh 21 April, 2015
	--This sp retrieves the Shift Rotation as per given employee id and effective date.
	--it will fetch all employee's shift rotation detail if employee id is not specified.
	IF (OBJECT_ID('tempdb..#Rotation') IS NULL)
		CREATE TABLE #Rotation (R_EmpID numeric(18,0), R_DayName varchar(25), R_ShiftID numeric(18,0), R_Effective_Date DateTime);
	--The #Rotation table gets re-created in dbo.P0050_UNPIVOT_EMP_ROTATION stored procedure
	DECLARE @Constraint Varchar(Max);
	SELECT DISTINCT @Constraint + COALESCE(@Constraint + '# ', '') + CAST(Emp_ID As Varchar(10)) FROM #TEMP
	Exec dbo.P0050_UNPIVOT_EMP_ROTATION @cmp_id_Pass, NULL, @DATE, @Constraint

	update	#temp
	set		Shift_id = QA1.Shift_id
	from	#temp inner join
			(select Esd.Shift_id,Esd.Emp_id,For_date from T0100_Emp_Shift_Detail as ESD WITH (NOLOCK) inner join
			(select Emp_ID,MAX(For_date) as MAX_For_date from T0100_Emp_Shift_Detail WITH (NOLOCK)
				where for_date <= @DATE group by Emp_ID) Q1 on
			ESD.Emp_id = Q1.Emp_ID and esd.For_Date = q1.MAX_For_date) QA1 on
			#temp.Emp_id = QA1.Emp_ID

	--Updating Shift ID if assigned in Rotation
	Update	#Temp
	SET		Shift_ID = R_ShiftID
	FROM	#Rotation
	WHERE	Emp_Id=R_EmpID  AND R_DayName='Day' + CAST(DATEPART(d, @DATE) As Varchar) AND 
			R_Effective_Date = (Select Max(R_Effective_Date) FROM #Rotation WHERE R_EmpID=Emp_Id )

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



Declare @Emp_ID_AutoShift numeric
Declare @For_Date_Autoshift datetime
Declare @New_Shift_ID numeric

--Now as Allocated Shift is Updated , now we will update Auto Shift-- Code Added By Ramiz on 21/12/2018
If EXISTS(select 1 from T0040_SHIFT_MASTER s WITH (NOLOCK) where Isnull(s.Inc_Auto_Shift,0) = 1 and s.Cmp_ID = @cmp_id_Pass)
	BEGIN
		Declare @Shift_ID_Autoshift numeric
		Declare @Shift_start_time_Autoshift varchar(12)
		Declare @Shift_End_time_Autoshift varchar(12)

		DECLARE curautoshift cursor FAST_FORWARD for	                  
			SELECT d.Emp_ID,d.For_Date ,d.Shift_ID
			FROM #Temp d 
				INNER JOIN T0040_SHIFT_MASTER s WITH (NOLOCK) on d.Shift_ID = s.Shift_ID 
			WHERE  Isnull(s.Inc_Auto_Shift,0) = 1 and For_Date IS NOT NULL
			ORDER BY Emp_ID
		OPEN curautoshift                      
			  Fetch next from curautoshift into @Emp_ID_AutoShift,@For_Date_Autoshift ,@New_Shift_ID
				While @@fetch_status = 0                    
					Begin     
		               
						set @Shift_ID_Autoshift = @New_Shift_ID
						set @Shift_start_time_Autoshift = ''
						set @Shift_End_time_Autoshift = ''
					---------New Code of Auto Shift Kept By Ramiz on 13042015 ----------------
						
						SELECT	TOP 1 @Shift_ID_Autoshift =  Shift_ID ,@Shift_start_time_Autoshift = Shift_St_Time , @Shift_End_time_Autoshift = Shift_End_Time
						FROM	T0040_SHIFT_MASTER WITH (NOLOCK)
						WHERE	Cmp_ID = @cmp_id_Pass And Isnull(Inc_Auto_Shift,0)=1
						ORDER BY ABS(DATEDIFF(s,@For_Date_Autoshift,CAST(CONVERT(VARCHAR(11),  CASE WHEN DATEPART(hh,Shift_St_Time)=0 And DATEPART(hh,@For_Date_Autoshift) <> 0 THEN  DATEADD(dd,1,@For_Date_Autoshift) ELSE @For_Date_Autoshift END, 121)  + CONVERT(VARCHAR(12), Shift_St_Time, 114) AS DATETIME)))			
						
						UPDATE #temp 
						SET Shift_ID = @Shift_ID_Autoshift
						FROM #temp 
						WHERE Emp_ID=@Emp_ID_AutoShift and For_Date=@For_Date_Autoshift 
						And Shift_ID <> @Shift_ID_Autoshift

					
			fetch next from curautoshift into @Emp_ID_AutoShift,@For_Date_Autoshift ,@New_Shift_ID
		                  
		   end                    
		 close curautoshift                    
		 deallocate curautoshift    	  
		 
	END

	--Updating Shift Name in Table--
	UPDATE T
	SET SHIFT_Name = SM.Shift_Name
	from #TEMP T
		INNER JOIN T0040_SHIFT_MASTER SM on SM.Shift_ID = t.Shift_ID


declare @Sh_Id numeric
Declare @shift_Id numeric

set @Sh_id = DATEPART(hh,GETDATE())

 CREATE TABLE #Shift_Cons 
 (      
  Shift_ID numeric  
 )      
     

Insert Into #Shift_Cons  
select shift_id from dbo.T0040_SHIFT_MASTER WITH (NOLOCK) where cast(left(Shift_St_Time,2) as numeric(2,0))  <= @Sh_id and cast(left(Shift_St_Time,2) as numeric(2,0)) >= @Sh_id - 3

Delete #Temp Where Status <> 'P' or shift_id not in (select Shift_id from #Shift_Cons )
	-- ended by rohit on 15072013

	--Added New Code By Ramiz as Manager was Coming Old
	SELECT	R1.Cmp_ID, R1.Emp_ID, R1.Effect_Date, R1.R_Emp_ID, (EM.Alpha_Emp_Code + '-' + Em.Emp_Full_Name)AS Emp_Full_Name
	INTO	#Max_Reporting_Manager 
	FROM    dbo.T0090_EMP_REPORTING_DETAIL AS R1 WITH (NOLOCK)
			INNER JOIN (SELECT	MAX(R2.Row_ID) AS ROW_ID, R2.Emp_ID
						FROM    dbo.T0090_EMP_REPORTING_DETAIL AS R2 WITH (NOLOCK)
								INNER JOIN (SELECT     MAX(Effect_Date) AS Effect_Date, Emp_ID
											FROM          dbo.T0090_EMP_REPORTING_DETAIL AS R3 WITH (NOLOCK)
											WHERE      (Effect_Date < GETDATE())
											GROUP BY Emp_ID
											) AS R3_1 ON R2.Emp_ID = R3_1.Emp_ID AND R2.Effect_Date = R3_1.Effect_Date
						GROUP BY R2.Emp_ID
						) AS R2_1 ON R1.Row_ID = R2_1.ROW_ID AND R1.Emp_ID = R2_1.Emp_ID 
			INNER JOIN dbo.T0080_EMP_MASTER AS Em WITH (NOLOCK) ON R1.R_Emp_ID = Em.Emp_ID and Emp_Left <> 'Y'



	CREATE TABLE #TempSuperiore
      ( CON INT IDENTITY(1, 1),
        Cmp_ID NUMERIC(18, 0),
        Emp_Superior NUMERIC(18, 0),
        Emp_Superior_Name nvarchar(200),
        EmployeeCount NUMERIC(18, 0) DEFAULT 0,
       
      )   
      
		INSERT INTO #TempSuperiore
			( Cmp_ID,  Emp_Superior, Emp_Superior_Name)
		SELECT DISTINCT CMP_ID , R_Emp_ID , Emp_Full_Name
		FROM #Max_Reporting_Manager

      --Select Distinct LA.cmp_ID,ED.R_Emp_ID,EM.Emp_Full_Name 
      -- From #Temp LA left join 
      --         T0090_EMP_REPORTING_DETAIL ED on LA.Emp_ID = ED.Emp_ID inner join 
      --         T0080_EMP_MASTER EM on ED.R_Emp_ID = EM.emp_id
     
               
      --UPDATE    #TempSuperiore
      --SET       EmployeeCount = LQ.Ecount
      --FROM      #TempSuperiore LA
      --          INNER JOIN ( SELECT COUNT(LA.Emp_ID) AS Ecount, ED.R_Emp_ID
      --                       FROM   #Temp LA 
						--		LEFT JOIN #Max_Reporting_Manager ED on LA.Emp_Id =ED.Emp_ID
      --                       GROUP BY ED.R_Emp_ID
      --                       HAVING COUNT(LA.Emp_ID) > 0
      --                     ) LQ ON LA.Emp_Superior = LQ.R_Emp_ID 

	  UPDATE    #TempSuperiore
      SET       EmployeeCount = LQ.Ecount
      FROM      #TempSuperiore LA
                INNER JOIN ( SELECT COUNT(Emp_ID) AS Ecount, ED.R_Emp_ID
                             FROM  #Max_Reporting_Manager ED
                             GROUP BY ED.R_Emp_ID
                             HAVING COUNT(Emp_ID) > 0
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
		Declare @current_Date as Datetime 	
		Declare @HREmail_ID	nvarchar(4000)
		Declare @HR_Name as varchar(255)
		Declare @Branch as varchar(255)
		Declare @subject as varchar(100)
		Declare @profile as varchar(50)


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
      
				  SET @current_Date = GETDATE()
      
      
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
    
					
											SELECT TOP 1 @HREmail_ID = Email_ID, @HR_Name = Emp_Full_Name
											FROM T0011_LOGIN L WITH (NOLOCK) Left Outer Join T0080_EMP_MASTER E WITH (NOLOCK) on L.Emp_ID = E.Emp_ID
											Where L.Cmp_ID=@Cmp_ID AND Is_HR = 1

											if @CC_Email <> ''
											begin
												set @HREmail_ID = @HREmail_ID + ';' + @CC_Email
											end
							
								
											  ---ALTER dynamic template for Employee.				
											  Declare  @TableHead nvarchar(max),
													   @TableTail nvarchar(max)   
   												  Set @TableHead = '<html><head>' +
																  '<style>' +
																  'td {border: solid black 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:8pt;} ' +
																  '</style>' +
																  '</head>' +
																  '<body>
																  <div style=" font-family:Arial, Helvetica, sans-serif; color:#000000; text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">
																	Dear ' + @Emp_Superior_Name + ' </div>	<br/>
																  <table width="800" border="0" align="center" cellpadding="0" cellspacing="0" style="border:1px solid #cacaca; border-radius: 10px 10px 10px 10px;" >
																  <tr>
																	 <td align="center" valign="middle"><table width="800" border="0" cellspacing="0" cellpadding="0">
																		<tr>
																		<td height="9" align="center" valign="middle" ></td>
																		</tr>
																	  <tr>
																		<td width="800" height="24" align="center" valign="middle" style="background:#0b0505; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">Today''s Present Report ( ' + @Date + ') </td>
																	  </tr>
																		  <tr>
																			<td height="4" align="center" valign="middle"></td>
																		  </tr>
																		  <tr>
																			<td width="800" align="center" valign="middle" style="border:1px solid #cacaca; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#000000;  text-decoration:none; text-align:center; font-size:12px;">Total Present Employees : [ ' + CAST(@ECount AS VARCHAR(255)) + ' ] </td>
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
																		  '<td align=center><b><span style="font-size:small">Shift</span></b></td>' +
																		  '<td align=center><b><span style="font-size:small">Status</span></b></td>'
								                                     
												  SET @TableTail = '</table></body></html>';                  	
		
								
												  DECLARE @Body AS VARCHAR(MAX)
												  SET @Body = ( SELECT  
																		Emp_Code  as [TD],
																		Emp_name  as [TD],
																		ISNULL(Dept_Name,'-') as [TD],
																		ISNULL(Desig_Name,'-') as [TD],
																		Shift_Name as [TD],
																		Status As [TD]
																FROM    #Temp LA 
																	INNER JOIN #Max_Reporting_Manager ED on LA.Emp_ID = ED.Emp_ID
																--left join T0090_EMP_REPORTING_DETAIL ED on LA.Emp_ID = ED.Emp_ID
																WHERE   LA.Cmp_ID = @Cmp_Id and ED.R_Emp_ID =@Emp_Superior ORDER BY  Emp_code For XML raw('tr'), ELEMENTS) 

							
           										  If isnull(@Body,'')=''
													Begin
														GOTO ABC;
													End	
					       		
   												  SELECT  @Body = @TableHead + @Body + @TableTail  
					       		  
   												  Set @subject = 'Present Report ( ' + @Date + ' ) '
   												  set @profile = ''
			   					  
   												  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = @Cmp_Id
			   					  
   												  if isnull(@profile,'') = ''
   												  begin
   													select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = 0
   												  end  		 	           			              


											SET @HREmail_ID = @CC_Email	--for Testing
											

											
											IF @Work_Email <> '' 
											  BEGIN                                   
												   EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @Work_Email, @subject = @subject, @body = @Body, @body_format = 'HTML' , @copy_recipients = @HREmail_ID
											  END
										   ELSE 
											  IF @Other_Email <> '' 
												 BEGIN      
													EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @Other_Email, @subject = @subject, @body = @Body, @body_format = 'HTML' , @copy_recipients = @HREmail_ID
												 END      


											Set @HREmail_ID = ''
											Set @HR_Name = ''
											Set @ECount = 0
					
					
										ABC:	
										SELECT    @I = @I + 1       
									END      
					
				 fetch next from Cur_Company into @Cmp_Id
			   end                    
			close Cur_Company                    
			deallocate Cur_Company         
        
       

End



