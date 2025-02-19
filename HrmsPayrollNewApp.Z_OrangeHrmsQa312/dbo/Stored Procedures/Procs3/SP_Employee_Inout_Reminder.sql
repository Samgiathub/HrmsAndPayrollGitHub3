CREATE PROCEDURE [dbo].[SP_Employee_Inout_Reminder]
	@flag  numeric = 1 -- For Send Report Monthly - 01-jan to 31 jan
	--,@flag  numeric = 2 for Send report Weekly 01-jan -07-jan
	--,@flag  numeric = 3 for Send Report Daily 01 - jan to 01-jan
	,@cmp_id_Pass		Numeric(18,0) = 1,
	@CC_Email			Nvarchar(max) = '',
	@CC_to_Manager		Numeric(18,0) = 1,
	@IP_ADDRESS_LIST	VARCHAR(500) = ''	--Added By Ramiz on 31/08/2018 for OTL IP Address	--'192.168.1.201#192.168.1.202'
AS 
BEGIN   
	SET NOCOUNT ON;
	SET ARITHABORT ON;
	SET ANSI_WARNINGS OFF;
	
	  DECLARE @DATE VARCHAR(11)   
      DECLARE @Approval_day AS NUMERIC    
      DECLARE @ReminderTemplate AS NVARCHAR(4000)
      Declare @From_Date as Datetime
      Declare @To_Date as Datetime
      SET @DATE = CAST(GETDATE() AS varchar(11))
          
      
      if @flag = 1
		  BEGIN 
		  -----------------below code if you set up job on next month ---------------------
			--set @To_Date = cast(DATEADD(dd,-(DAY(Getdate())),getdate()) as varchar(max))
			--set @From_Date = cast(DATEADD(dd,-(DAY(@To_Date)-1),@To_Date) as varchar(max))
			

          -----------------below code if you set up job in Current month and required report based on cut off ---------------------
			set @From_Date = cast((dateadd(dd,-(day(getdate())-1),getdate())-5) as varchar(max))
            set @To_Date = cast((dateadd(s,-1,dateadd(mm,datediff(m,0,getdate())+1,0))-6)as varchar(max))


			-----------set @From_Date = (dateadd(dd,-(day(getdate())-1),getdate()))  -----------old code 
            ----------set @To_Date = (dateadd(s,-1,dateadd(mm,datediff(m,0,getdate())+1,0))) -----------old code 

		  END
      else if @flag = 2
		  Begin
			set @To_Date = cast(DATEADD(day,
				   -2 - (DATEPART(dw, GETDATE()) + @@DATEFIRST - 2) % 7,
				   GETDATE()) as varchar)
	               
			set @From_Date = cast(DATEADD(dd, -(DATEPART(dw, @To_Date)-1), @To_Date) as varchar)
		  end
      else if @flag = 3
		  Begin
			set @To_Date =  cast((Getdate()-1) as varchar(max))
			set @From_Date =  cast((Getdate()-1) as varchar(max))
		  end
      
       
      
      IF OBJECT_ID('tempdb..#Temp_inout') IS NOT NULL 
         BEGIN
              DROP TABLE #Temp_inout
         END
       
     CREATE table #TEMP_INOUT
     (
		emp_id Numeric,
		for_Date Datetime,
		Dept_id varchar(max),
		Grd_ID varchar(200),
		Type_ID varchar(max),
		Desig_ID Varchar(max),
		Shift_ID varchar(max),
		In_Time varchar(max),
		Out_Time varchar(max),
		Duration varchar(max),
		Duration_sec varchar(max),
		Late_In varchar(max),
		Late_Out varchar(max),
		Early_In varchar(max),
		Early_Out varchar(max),
		Leave varchar(max),
		Shift_Sec varchar(max),
		Shift_Dur varchar(max),
		Total_work varchar(max),
		Less_Work varchar(max),
		More_Work varchar(max),
		Reason varchar(max),
		Other_Reason varchar(300) null, --Added By Jaina 12-09-2015        
		AB_LEAVE varchar(max),
		Late_In_Sec varchar(max),
		Late_In_count varchar(max),
		Early_Out_sec varchar(max),
		Early_Out_Count varchar(max),
		Total_Less_work_Sec varchar(max),
		Shift_St_Datetime varchar(max),
		Shift_en_Datetime varchar(max),
		Working_Sec_AfterShift varchar(max),
		Working_AfterShift_Count varchar(max),
		Leave_Reason varchar(max),
		Inout_Reason varchar(max),
		SysDate varchar(max),
		Total_Work_Sec varchar(max),
		Late_Out_Sec varchar(max),
		Early_In_sec varchar(max),
		Total_More_work_Sec varchar(max),
		Is_OT_Applicable varchar(max),
		Monthly_Deficit_Adjust_OT_Hrs varchar(max),
		Late_Comm_sec varchar(max),
		Branch_Id varchar(max),
		P_Days varchar(max),
		--vertical_Id numeric default 0,  --added jimit 15062016
		--subvertical_Id numeric default 0,  --added jimit 15062016
		Emp_full_Name varchar(max),
		Alpha_Emp_Code varchar(max),
		Emp_Code varchar(max),
		Grd_Name varchar(max),
		Shift_name varchar(max),
		dept_name varchar(max),
		Type_Name varchar(max),
		Desig_Name varchar(max),
		CMP_NAME varchar(max),
		CMP_ADDRESS varchar(max),
		P_From_date varchar(max),
		P_To_Date varchar(max),
		Shift_Start_Time varchar(max),
		Shift_End_Time varchar(max),
		Actual_In_Time varchar(max),
		Actual_Out_Time varchar(max),
		On_Date varchar(max),
		manager_Id varchar(10),
		Branch_Name Varchar(max)
	) 
           
        SET @from_date = REPLACE(CONVERT(VARCHAR(11),@from_date,106), ' ','-')
        SET @To_Date = REPLACE(CONVERT(VARCHAR(11),@To_Date,106), ' ','-')
     

		INSERT INTO #TEMP_INOUT
		EXEC SP_RPT_EMP_INOUT_RECORD_GET @Cmp_ID=@cmp_id_Pass,@From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0,@Constraint='',@PBranch_ID='0',@Report_call = 'Inout_Mail'      
		
		
		--New Code Added For OTL by Ramiz on 31/08/2018--
		
		ALTER TABLE #TEMP_INOUT
		ADD PUNCH_STR VARCHAR(5000) DEFAULT ''
		
		IF @IP_ADDRESS_LIST <> ''
			BEGIN
				IF OBJECT_ID('tempdb..#PUNCH_DETAILS') IS NULL
					BEGIN
						CREATE TABLE #PUNCH_DETAILS
						(	
							EMP_ID		NUMERIC,
							ENROLL_NO	NUMERIC,
							FOR_DATE	DATETIME,
							PUNCH_STR	VARCHAR(5000)
						)
					END
				
				INSERT INTO #PUNCH_DETAILS
					(EMP_ID , ENROLL_NO , FOR_DATE , PUNCH_STR)
				EXEC SP_DEVICE_INOUT_ANALYSIS @CMP_ID = @cmp_id_Pass , @FROM_DATE = @From_Date , @TO_DATE = @To_Date , @IP_ADDRESS_LIST = @IP_ADDRESS_LIST 
				
				UPDATE T
				SET T.PUNCH_STR = P.PUNCH_STR
				FROM #TEMP_INOUT T
					INNER JOIN #PUNCH_DETAILS P ON T.EMP_ID = P.EMP_ID AND T.FOR_DATE = P.FOR_DATE
			END

      CREATE TABLE #HR_Email
      ( 
		Row_Id INT IDENTITY(1, 1),
        Emp_ID NUMERIC(18, 0),
        manager_Id	NUMERIC(18, 0)
      )   


	
	--Commented By Ramiz to Send Notification to HR also
	--Insert Into #HR_Email (Emp_ID)
	--Select Emp_Id From #Temp_inout Group by Emp_id
	
	Insert Into #HR_Email (Emp_ID , manager_Id)
	Select Emp_Id , manager_Id From #Temp_inout Group by Emp_id , manager_Id
	

	Declare @EmpEmail_ID	nvarchar(4000)
	Declare @Emp_Id as numeric
	Declare @Emp_Name as varchar(255)
	--Declare @ECount as numeric
	DECLARE @cmp_id as numeric(18,0)
	DECLARE @Manager_ID as numeric 
	DECLARE @Manager_Email as Varchar(100)
	DECLARE @subject as varchar(max)
    DECLARE @profile as varchar(50)    
	DECLARE @TableHead varchar(max)
	DECLARE @TableTail varchar(max) 
    SET @profile = ''  
    


	DECLARE Cur_Employee CURSOR FOR                    
		SELECT Emp_Id , manager_Id FROM #HR_Email ORDER BY EMP_ID
	OPEN Cur_Employee                      
	FETCH NEXT FROM Cur_Employee INTO @Emp_Id , @Manager_ID
	WHILE @@FETCH_STATUS = 0                    
		BEGIN     
				
			SELECT TOP 1 @EmpEmail_ID = Work_Email, @Emp_Name = Emp_Full_Name,@cmp_id=cmp_id
			FROM T0080_EMP_MASTER E Where emp_id=@Emp_Id
			
			SELECT TOP 1 @Manager_Email = Work_Email FROM T0080_EMP_MASTER E Where emp_id = @Manager_ID 
			 
			  ---ALTER dynamic template for Employee.				
					SET @TableHead = ''
					SET @TableTail = ''
					
           		  Set @TableHead = '<html><head>' +
								  '<style>' +
								  'td {border: solid black 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:8pt;} ' +
								  '</style>' +
								  '</head>' +
								  '<body>
								  <div style=" font-family:Arial, Helvetica, sans-serif; color:Black;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">
								  Dear ' + @Emp_Name + ' </div>	<br/>					
								  
								  <table width="800" border="0" align="center" cellpadding="0" cellspacing="0" style="border:1px solid #cacaca; border-radius: 10px 10px 10px 10px;" >
								  <tr>
									 <td align="center" valign="middle"><table width="800" border="0" cellspacing="0" cellpadding="0">
										<tr>
										<td height="9" align="center" valign="middle" ></td>
										</tr>
									  <tr>
										<td width="800" height="24" align="center" valign="middle" style="background:#0b0505; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;"> Inout Report  for ( from date ' + convert(varchar(15),@From_Date,103) + ' To ' + convert(varchar(15),@to_date,103) +  ') </td>
									  </tr>
										  <tr>
											<td height="4" align="center" valign="middle"></td>
										  </tr>
										  <tr>
											<td height="8" align="center" valign="middle"></td>
										  </tr>
								  </table>
            
								  <table border="1" width="1000" height="24" align="center" valign="middle" style="background: #FFFFF;border-color:solid black;
									border-radius: 10px 10px 10px 10px; font-family: Arial, Helvetica, sans-serif;
									color: #000000; text-decoration: none; font-weight: normal; text-align: left;
									font-size: 12px;">' +
										  '<tr border="1"><td align=center><span style="font-size:small"><b>Code</b></span></td>' +
										  '<td align=center><b><span style="font-size:small">For Date</span></b></td>' +
										  '<td align=center><b><span style="font-size:small">Shift In Time</span></b></td>' +
										  '<td align=center><b><span style="font-size:small">Shift Out Time</span></b></td>' +
										  '<td align=center><b><span style="font-size:small">Shift Duration</span></b></td>' +
										  '<td align=center><b><span style="font-size:small">In Time</span></b></td>' +
										  '<td align=center><b><span style="font-size:small">Out Time</span></b></td>' +
										  '<td align=center><b><span style="font-size:small">Duration</span></b></td>' +
										  '<td align=center><b><span style="font-size:small">Leave/Weekoff</span></b></td>' +
										  '<td align=center><b><span style="font-size:small">Deficit</span></b></td>' +
										  '<td align=center><b><span style="font-size:small">Surplus</span></b></td>' +
										  '<td align=center><b><span style="font-size:small">Remark & Punch History</span></b></td>'
										                                     
                  SET @TableTail = '</table><table><tr><td style="font-size:small">
                            Note:- <span style="color:red;font-size:15px;font-weight:bold">*</span> indicate the late coming or Early Going on Date.
                          </td>
                          </tr> </table></body></html>';                  	
                  DECLARE @Body AS VARCHAR(MAX)
                  DECLARE @Body1 AS VARCHAR(MAX)
                  SET @Body = ( SELECT  
										#Temp_inout.alpha_emp_Code  as [TD],
										On_Date  as [TD],
										Isnull( dbo.F_GET_AMPM(shift_st_datetime),'-') as [TD],
										Isnull(dbo.F_GET_AMPM(shift_en_datetime),'-') as [TD],
										Isnull(shift_dur,'-') as [TD],
										case when isnull(late_in,'-') in ('-','') then Isnull(Actual_In_Time,'-') else cast( Isnull(Actual_In_Time,'-') as varchar(max)) + ' "*"' end  as [TD],
										case when Isnull(early_out,'-')in('-','') then isnull(Actual_Out_Time,'-') else cast(isnull(Actual_Out_Time,'-')as varchar(Max)) + ' "*"' end  as [TD],
										Isnull(Total_Work,'-') as [TD],
										Isnull(AB_Leave,'-') as [TD],
										Isnull(Less_Work,'-') as [TD],
										Isnull(More_Work,'-') as [TD],
										CASE WHEN Inout_Reason <> '' AND PUNCH_STR = '' THEN Inout_Reason 
											WHEN Inout_Reason = ''  AND PUNCH_STR <> '' THEN PUNCH_STR
										ELSE ISNULL(Inout_Reason  + '"break"' + PUNCH_STR , '-') END as [TD]
                                FROM    #Temp_inout  
                                WHERE   Emp_ID = @Emp_Id ORDER BY  #Temp_inout.for_Date For XML raw('tr'), ELEMENTS) -- Deepal Change emp_code to For_date on order by query :- 05092022
                             
				  SET @Body1 = ( SELECT  
										'Total' as [TD],
										'-' as [TD],
										'-' as [TD],
										'-' as [TD],
										DBO.F_Return_Hours(sum(cast(shift_sec as numeric(18,0)))) as [TD],
										'-' as [TD],
										'-' as [TD],
										DBO.F_Return_Hours(sum(cast(Total_Work_sec as numeric(18,0))))as [TD],
										'-' as [TD],
										DBO.F_Return_Hours(sum(cast(total_Less_Work_sec as numeric(18,0)))) as [TD],
										DBO.F_Return_Hours(sum(cast(total_More_Work_sec as numeric(18,0)))) as [TD],
										'-' As [TD]
                                FROM    #Temp_inout 
                                WHERE   Emp_ID = @Emp_Id group by alpha_emp_Code For XML raw('tr'), ELEMENTS) 
					
           			SET @Body  = REPLACE(@Body, '"*"', '<span style="color:red;font-size:15px;font-weight:bold">*</span>')
           			SET @Body1 = REPLACE(@Body1,'<tr>', '<tr style=''font-weight: bold; color: #000000; background-color: darkgrey;''>')
           			SET @Body  = REPLACE(@Body, '"break"', '<br />')	--For Line Break
           			
           			SELECT  @BODY = @TABLEHEAD + @BODY + @BODY1 + @TABLETAIL
           	
 					SET @SUBJECT = 'Inout Report ( ' + @Date + ' )'

           		  IF @CC_to_Manager = 1
           			BEGIN
           				IF @CC_Email <> ''
           					SET @CC_Email = ISNULL(@CC_Email,'') + ';' + ISNULL(@Manager_Email	,'')
           				ELSE
           					SET @CC_Email = ISNULL(@Manager_Email	,'')
           			END
			    SELECT @profile = isnull(DB_Mail_Profile_Name,'') FROM t9999_Reminder_Mail_Profile WHERE cmp_id = @cmp_id
			   					  
				IF ISNULL(@profile,'') = ''
				  BEGIN
					SELECT @profile = isnull(DB_Mail_Profile_Name,'') FROM t9999_Reminder_Mail_Profile WHERE cmp_id = 0
				  END
	  
			--if @EmpEmail_ID <> '' or @CC_Email <> ''
			--	BEGIN
			--		EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @EmpEmail_ID, @subject = @subject, @body = @Body, @body_format = 'HTML',@copy_recipients = @CC_Email
			--	END
				
			SET @EMPEMAIL_ID = ''
			SET @EMP_NAME = ''
			SET @MANAGER_EMAIL = ''
			SET @CC_EMAIL = ''	
			--Set @ECount = 0
			
		 FETCH NEXT FROM Cur_Employee INTO @emp_id , @Manager_ID
	   END                    
	CLOSE Cur_Employee                    
	DEALLOCATE Cur_Employee         

End




