
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Employee_Daily_inout_reminder]
@Cmp_ID		NUMERIC,
@IP_ADDRESS_LIST	VARCHAR(500) = ''	--Added By Ramiz on 04/09/2018 for OTL IP Address	--'192.168.1.201#192.168.1.202'
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN  
/*  
	THIS SP WAS CREATED BY ROHIT PATEL ONLY FOR OTL , 
	AND DUE TO THIS SOME LOGIC OF LINKED SERVER ARE PRESENT IN THIS SP WHICH ARE NOT CHANGED BY ME ALSO. -- COMMENT ADDED BY RAMIZ ON 03/09/2018
*/

	
	  DECLARE @DATE VARCHAR(11)   
      DECLARE @Approval_day AS NUMERIC    
      DECLARE @ReminderTemplate AS NVARCHAR(4000)
      
      SET @DATE = CAST(GETDATE()-1 AS varchar(11))
		
      IF OBJECT_ID('tempdb..#Att_Muster_Job') IS NOT NULL 
         BEGIN
               DROP TABLE #Att_Muster_Job
         END
            
      CREATE table #HR_Email
      ( 
		Row_Id INT IDENTITY(1, 1),
        Cmp_ID NUMERIC(18, 0)
      )
      
      CREATE TABLE #Att_Muster_Job
      (
			Emp_Id		numeric , 
			Cmp_ID		numeric,
			For_Date	datetime,
			Leave_Count	numeric(5,1),
			WO_COHO		varchar(4),
			Status_1_1	varchar(22),
			Status_2_1	varchar(22),
			Status_3_1	varchar(22),
			Status_4_1	varchar(22),
			Second_5_1  numeric(18,0),
			Second_6_1  numeric(18,0),
			Status_7_1	varchar(22),
			Status_1_2	varchar(22),
			Status_2_2	varchar(22),
			Status_3_2	varchar(22),
			Status_4_2	varchar(22),
			Second_5_2  numeric(18,0),
			Second_6_2  numeric(18,0),
			Status_7_2	varchar(22),
			Status_1_3	varchar(22),
			Status_2_3	varchar(22),
			Status_3_3	varchar(22),
			Status_4_3	varchar(22),
			Second_5_3  numeric(18,0),
			Second_6_3  numeric(18,0),
			Status_7_3	varchar(22),
			Status_1_4	varchar(22),
			Status_2_4	varchar(22),
			Status_3_4	varchar(22),
			Status_4_4	varchar(22),
			Second_5_4  numeric(18,0),
			Second_6_4  numeric(18,0),
			Status_7_4	varchar(22),
			Status_1_5	varchar(22),
			Status_2_5	varchar(22),
			Status_3_5	varchar(22),
			Status_4_5	varchar(22),
			Second_5_5  numeric(18,0),
			Second_6_5  numeric(18,0),
			Status_7_5	varchar(22),
			Status_1_6	varchar(22),
			Status_2_6	varchar(22),
			Status_3_6	varchar(22),
			Status_4_6	varchar(22),
			Second_5_6  numeric(18,0),
			Second_6_6  numeric(18,0),
			Status_7_6	varchar(22),
			Status_1_7	varchar(22),
			Status_2_7	varchar(22),
			Status_3_7	varchar(22),
			Status_4_7	varchar(22),
			Second_5_7  numeric(18,0),
			Second_6_7  numeric(18,0),
			Status_7_7	varchar(22),
			Status_1_8	varchar(22),
			Status_2_8	varchar(22),
			Status_3_8	varchar(22),
			Status_4_8	varchar(22),
			Second_5_8  numeric(18,0),
			Second_6_8  numeric(18,0),
			Status_7_8	varchar(22),
			Status_1_9	varchar(22),
			Status_2_9	varchar(22),
			Status_3_9	varchar(22),
			Status_4_9	varchar(22),
			Second_5_9  numeric(18,0),
			Second_6_9  numeric(18,0),
			Status_7_9	varchar(22),
			Status_1_10	varchar(22),
			Status_2_10	varchar(22),
			Status_3_10	varchar(22),
			Status_4_10	varchar(22),
			Second_5_10  numeric(18,0),
			Second_6_10  numeric(18,0),
			Status_7_10	varchar(22),
			Status_1_11	varchar(22),
			Status_2_11	varchar(22),
			Status_3_11	varchar(22),
			Status_4_11	varchar(22),
			Second_5_11  numeric(18,0),
			Second_6_11  numeric(18,0),
			Status_7_11	varchar(22),
			Status_1_12	varchar(22),
			Status_2_12	varchar(22),
			Status_3_12	varchar(22),
			Status_4_12	varchar(22),
			Second_5_12  numeric(18,0),
			Second_6_12  numeric(18,0),
			Status_7_12	varchar(22),
			Status_1_13	varchar(22),
			Status_2_13	varchar(22),
			Status_3_13	varchar(22),
			Status_4_13	varchar(22),
			Second_5_13  numeric(18,0),
			Second_6_13  numeric(18,0),
			Status_7_13	varchar(22),
			Status_1_14	varchar(22),
			Status_2_14	varchar(22),
			Status_3_14	varchar(22),
			Status_4_14	varchar(22),
			Second_5_14  numeric(18,0),
			Second_6_14  numeric(18,0),
			Status_7_14	varchar(22),
			Status_1_15	varchar(22),
			Status_2_15	varchar(22),
			Status_3_15	varchar(22),
			Status_4_15	varchar(22),
			Second_5_15  numeric(18,0),
			Second_6_15  numeric(18,0),
			Status_7_15	varchar(22),
			Status_1_16	varchar(22),
			Status_2_16	varchar(22),
			Status_3_16	varchar(22),
			Status_4_16	varchar(22),
			Second_5_16  numeric(18,0),
			Second_6_16  numeric(18,0),
			Status_7_16	varchar(22),
			Status_1_17	varchar(22),
			Status_2_17	varchar(22),
			Status_3_17	varchar(22),
			Status_4_17	varchar(22),
			Second_5_17  numeric(18,0),
			Second_6_17  numeric(18,0),
			Status_7_17	varchar(22),
			Status_1_18	varchar(22),
			Status_2_18	varchar(22),
			Status_3_18	varchar(22),
			Status_4_18	varchar(22),
			Second_5_18  numeric(18,0),
			Second_6_18  numeric(18,0),
			Status_7_18	varchar(22),
			Status_1_19	varchar(22),
			Status_2_19	varchar(22),
			Status_3_19	varchar(22),
			Status_4_19	varchar(22),
			Second_5_19  numeric(18,0),
			Second_6_19  numeric(18,0),
			Status_7_19	varchar(22),
			Status_1_20	varchar(22),
			Status_2_20	varchar(22),
			Status_3_20	varchar(22),
			Status_4_20	varchar(22),
			Second_5_20  numeric(18,0),
			Second_6_20  numeric(18,0),
			Status_7_20	varchar(22),
			Status_1_21	varchar(22),
			Status_2_21	varchar(22),
			Status_3_21	varchar(22),
			Status_4_21	varchar(22),
			Second_5_21  numeric(18,0),
			Second_6_21  numeric(18,0),
			Status_7_21	varchar(22),
			Status_1_22	varchar(22),
			Status_2_22	varchar(22),
			Status_3_22	varchar(22),
			Status_4_22	varchar(22),
			Second_5_22  numeric(18,0),
			Second_6_22  numeric(18,0),
			Status_7_22	varchar(22),
			Status_1_23	varchar(22),
			Status_2_23	varchar(22),
			Status_3_23	varchar(22),
			Status_4_23	varchar(22),
			Second_5_23  numeric(18,0),
			Second_6_23  numeric(18,0),
			Status_7_23	varchar(22),
			Status_1_24	varchar(22),
			Status_2_24	varchar(22),
			Status_3_24	varchar(22),
			Status_4_24	varchar(22),
			Second_5_24  numeric(18,0),
			Second_6_24  numeric(18,0),
			Status_7_24	varchar(22),
			Status_1_25	varchar(22),
			Status_2_25	varchar(22),
			Status_3_25	varchar(22),
			Status_4_25	varchar(22),
			Second_5_25  numeric(18,0),
			Second_6_25  numeric(18,0),
			Status_7_25	varchar(22),
			Status_1_26	varchar(22),
			Status_2_26	varchar(22),
			Status_3_26	varchar(22),
			Status_4_26	varchar(22),
			Second_5_26  numeric(18,0),
			Second_6_26  numeric(18,0),
			Status_7_26	varchar(22),
			Status_1_27	varchar(22),
			Status_2_27	varchar(22),
			Status_3_27	varchar(22),
			Status_4_27	varchar(22),
			Second_5_27  numeric(18,0),
			Second_6_27  numeric(18,0),
			Status_7_27	varchar(22),
			Status_1_28	varchar(22),
			Status_2_28	varchar(22),
			Status_3_28	varchar(22),
			Status_4_28	varchar(22),
			Second_5_28  numeric(18,0),
			Second_6_28  numeric(18,0),
			Status_7_28	varchar(22),
			Status_1_29	varchar(22),
			Status_2_29	varchar(22),
			Status_3_29	varchar(22),
			Status_4_29	varchar(22),
			Second_5_29  numeric(18,0),
			Second_6_29  numeric(18,0),
			Status_7_29	varchar(22),
			Status_1_30	varchar(22),
			Status_2_30	varchar(22),
			Status_3_30	varchar(22),
			Status_4_30	varchar(22),
			Second_5_30  numeric(18,0),
			Second_6_30  numeric(18,0),
			Status_7_30	varchar(22),
			Status_1_31	varchar(22),
			Status_2_31	varchar(22),
			Status_3_31	varchar(22),
			Status_4_31	varchar(22),
			Second_5_31  numeric(18,0),
			Second_6_31  numeric(18,0),
			Status_7_31	varchar(22),
			Total_Duration varchar(22)		
	  )
        
		--Removing the Method of Linked Server , as that is Less Secure
		--SELECT * INTO #Att_Muster_Job
		--FROM OPENQUERY(Server_inout,'SET FMTONLY OFF; exec SP_RPT_EMP_IN_OUT_MUSTER_GET_WITH_DURATION_Daily @Cmp_ID=1,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0,@Constraint='''',@Report_For=''EMP RECORD''')
		
		INSERT INTO #Att_Muster_Job
		EXEC SP_RPT_EMP_IN_OUT_MUSTER_GET_WITH_DURATION_Daily @Cmp_ID=@Cmp_ID,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0,@Constraint='',@Report_For='EMP RECORD'
		

		
		ALTER TABLE #Att_Muster_Job
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
				EXEC SP_DEVICE_INOUT_ANALYSIS @CMP_ID = @Cmp_ID , @FROM_DATE = @DATE , @TO_DATE = @DATE , @IP_ADDRESS_LIST = @IP_ADDRESS_LIST 
				
				UPDATE T
				SET T.PUNCH_STR = P.PUNCH_STR
				FROM #Att_Muster_Job T
					INNER JOIN #PUNCH_DETAILS P ON T.EMP_ID = P.EMP_ID AND T.FOR_DATE = P.FOR_DATE
			END

	INSERT INTO #HR_Email (Cmp_ID)
	SELECT Cmp_Id FROM #Att_Muster_Job GROUP BY Cmp_ID

	DECLARE @HREmail_ID	AS NVARCHAR(4000)
	DECLARE @Cmp_Id_Cur		AS NUMERIC
	DECLARE @HR_Name	AS VARCHAR(255)
	DECLARE @ECount		AS NUMERIC
	DECLARE @Body		AS VARCHAR(MAX)
	DECLARE @SUBJECT	AS VARCHAR(100)           
	DECLARE @profile	AS VARCHAR(50)
	
	
	DECLARE Cur_Company CURSOR FOR                    
		SELECT Cmp_Id from #HR_Email ORDER BY Cmp_ID
	OPEN Cur_Company                      
	FETCH NEXT FROM Cur_Company INTO @Cmp_Id_Cur
	WHILE @@FETCH_STATUS = 0                    
		BEGIN     	
			SELECT TOP 1 @HREmail_ID = Email_ID, @HR_Name = Emp_Full_Name
			FROM T0011_LOGIN L WITH (NOLOCK) LEFT OUTER JOIN T0080_EMP_MASTER E WITH (NOLOCK) on L.Emp_ID = E.Emp_ID
			WHERE L.Cmp_ID=@Cmp_Id_Cur AND Is_HR = 1

			Select @ECount = COUNT(Emp_Id) From #Att_Muster_Job where Cmp_ID = @Cmp_Id_Cur

			  ---ALTER dynamic template for Employee.				
		      Declare  @TableHead varchar(max),
					   @TableTail varchar(max)   
           		  Set @TableHead = '<html><head>' +
								  '<style>' +
								  'td {border: solid black 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:8pt;} ' +
								  '</style>' +
								  '</head>' +
								  '<body>
								  <div style=" font-family:Arial, Helvetica, sans-serif; color:#000000;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">
								  Dear ' + isnull(@HR_Name, 'Sir / Madam') + ' </div>	<br/>					
								  
								  <table width="800" border="0" align="center" cellpadding="0" cellspacing="0" style="border:1px solid #cacaca; border-radius: 10px 10px 10px 10px;" >
								  <tr>
									 <td align="center" valign="middle"><table width="800" border="0" cellspacing="0" cellpadding="0">
										<tr>
										<td height="9" align="center" valign="middle" ></td>
										</tr>
									  <tr>
										<td width="800" height="24" align="center" valign="middle" style="background:#0b0505; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">Inout Report For ( ' + @Date + ') </td>
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
										  '<td align=center><b><span style="font-size:small">In Time</span></b></td>' +
										  '<td align=center><b><span style="font-size:small">Out Time</span></b></td>' +
										  '<td align=center><b><span style="font-size:small">Total Hours</span></b></td>' +
										  '<td align=center><b><span style="font-size:small">Break Hours</span></b></td>' +
										  '<td align=center><b><span style="font-size:small">Working Hours</span></b></td>' +
										  '<td align=center><b><span style="font-size:small">Punch History</span></b></td>'
                  SET @TableTail = '</table></body></html>';                  	
                  
                  SET @Body = ( SELECT  
										T0080_EMP_MASTER.Alpha_Emp_Code  as [TD],
										T0080_EMP_MASTER.emp_first_name  as [TD],
										Isnull(#Att_Muster_Job.status_1_1,'-') as [TD],
										Isnull(#Att_Muster_Job.status_2_1,'-') as [TD],
										case when Isnull(#Att_Muster_Job.status_3_1,'-') <> '-' then Isnull(#Att_Muster_Job.status_3_1,'-') else Isnull(#Att_Muster_Job.status_4_1,'-') end As [TD],
										Isnull(dbo.f_return_hours(second_5_1 - second_6_1),'-') As [TD],
										Isnull(#Att_Muster_Job.status_7_1,'-') As [TD],
										Isnull(#Att_Muster_Job.PUNCH_STR,'-') As [TD]
                                FROM    #Att_Muster_Job 
									INNER JOIN T0080_EMP_MASTER WITH (NOLOCK) on #Att_Muster_Job.emp_id = T0080_EMP_MASTER.emp_id
                                WHERE   #Att_Muster_Job.Cmp_ID = @Cmp_Id_Cur and Isnull(#Att_Muster_Job.status_3_1,'-') not in ('WO','HO')  
                                ORDER BY  T0080_EMP_MASTER.alpha_Emp_code For XML raw('tr'), ELEMENTS) 

           			
           		  SET @Body = @TableHead + @Body + @TableTail  
           		  SET @SUBJECT = 'Inout Report ( ' + @Date + ' )'
				  SET @PROFILE = ''
				  
				  SELECT @profile = isnull(DB_Mail_Profile_Name,'') FROM t9999_Reminder_Mail_Profile WITH (NOLOCK) WHERE cmp_id = @Cmp_Id_Cur
				  
				  IF ISNULL(@profile,'') = ''
					BEGIN
						SELECT @profile = isnull(DB_Mail_Profile_Name,'') FROM t9999_Reminder_Mail_Profile WITH (NOLOCK) WHERE cmp_id = 0
					END
       
			IF @Body is not null
				BEGIN
					EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @HREmail_ID, @subject = @subject, @body = @Body, @body_format = 'HTML',@copy_recipients = 'ankur@orangewebtech.com;officeadmin@orangewebtech.com;ramiz@orangewebtech.com'  
				END
			SET @HREMAIL_ID = ''
			SET @HR_NAME = ''
			SET @ECOUNT = 0
			
		 FETCH NEXT FROM Cur_Company INTO @Cmp_Id_Cur
	   END                    
	CLOSE Cur_Company                    
	DEALLOCATE Cur_Company         

End

