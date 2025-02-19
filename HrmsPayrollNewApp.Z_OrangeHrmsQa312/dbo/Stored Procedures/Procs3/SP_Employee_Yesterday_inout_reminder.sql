


---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[SP_Employee_Yesterday_inout_reminder]
@cmp_id_Pass Numeric(18,0) = 1,
@CC_Email Nvarchar(max) = ''
AS 

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN   

	  DECLARE @DATE VARCHAR(11)   
      DECLARE @Approval_day AS NUMERIC    
      DECLARE @ReminderTemplate AS NVARCHAR(4000)
      
      SET @DATE = CAST(GETDATE()-1 AS varchar(11))
      
      
       
      IF OBJECT_ID('tempdb..#Temp') IS NOT NULL 
         BEGIN
               DROP TABLE #Temp
         END
            
        
		
	 CREATE table #Temp 
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

            
      CREATE table #HR_Email
      ( 
		Row_Id INT IDENTITY(1, 1),
        Cmp_ID NUMERIC(18, 0)
      )   
      
   --   if not exists(select 1 from sys.servers where name='Server_inout')
	  --begin 
	  --print 1
		 -- EXEC sp_addlinkedserver @server=N'Server_inout', @srvproduct=N'',@provider=N'SQLNCLI', @datasrc=@@SERVERNAME;
	  --end
	--SELECT * INTO #Temp
	--	FROM OPENQUERY(Server_inout,'SET FMTONLY OFF; exec SP_RPT_EMP_IN_OUT_MUSTER_GET_WITH_DURATION_Daily @Cmp_ID=1,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0,@Constraint='''',@Report_For=''EMP RECORD''')

insert into #Temp
exec SP_RPT_EMP_IN_OUT_MUSTER_GET_WITH_DURATION_Daily @Cmp_ID=@cmp_id_Pass,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0,@Constraint='',@Report_For='EMP RECORD'

	Insert Into #HR_Email (Cmp_ID)
	Select Cmp_Id From #Temp Group by Cmp_ID

	Declare @HREmail_ID	nvarchar(4000)
	Declare @Cmp_Id as numeric
	Declare @HR_Name as varchar(255)
	Declare @ECount as numeric
	
	
	 CREATE table #TempSuperiore
      ( CON INT IDENTITY(1, 1),
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
                   From #Temp LA left outer join 
                           T0090_EMP_REPORTING_DETAIL ED WITH (NOLOCK) on LA.Emp_ID = ED.Emp_ID inner join 
                           T0080_EMP_MASTER EM WITH (NOLOCK) on ED.R_Emp_ID = EM.emp_id
                   Where la.cmp_id = ISNULL(@cmp_id_Pass,la.cmp_id)                          
                        
        
               
      UPDATE    #TempSuperiore
      SET       EmployeeCount = LQ.Ecount
      FROM      #TempSuperiore LA
                INNER JOIN ( SELECT COUNT(#Temp.Emp_ID) AS Ecount,
                                    T0090_EMP_REPORTING_DETAIL.R_Emp_ID
                             FROM   #Temp inner join T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) on #Temp.Emp_Id = T0090_EMP_REPORTING_DETAIL.Emp_ID
                             GROUP BY T0090_EMP_REPORTING_DETAIL.R_Emp_ID
                             HAVING COUNT(#Temp.Emp_ID) > 0
                           ) LQ ON LA.Emp_Superior = LQ.R_Emp_ID 
	
	--Alter  Table #Temp
	--Add S_Emp_Id numeric(18,0)
	
	--update #Temp
	--set S_Emp_Id = isnull(ED.R_Emp_ID,0)
	--From #Temp LA left outer join 
 --                          T0090_EMP_REPORTING_DETAIL ED on LA.Emp_ID = ED.Emp_ID --inner join 
 --                          --T0080_EMP_MASTER EM on ED.R_Emp_ID = EM.emp_id
 --                  Where la.cmp_id = ISNULL(@cmp_id_Pass,la.cmp_id)            
	
	
	Declare @Emp_Superior  numeric(18,0)
	declare @Emp_Superior_Name varchar(500)
	declare  @Work_Email varchar(500)
	
	declare Cur_Company cursor for                    
		select Emp_Superior,EmployeeCount,Emp_Superior_Name from #TempSuperiore where EmployeeCount > 0 order by Emp_Superior
	open Cur_Company                      
	fetch next from Cur_Company into @Emp_Superior,@Ecount,@Emp_Superior_Name
	while @@fetch_status = 0                    
		begin     
			

			--Select @ECount = COUNT(Emp_Id) From #Temp where Cmp_ID = @Cmp_Id
			
			 SELECT    @Cmp_ID = #TempSuperiore.Cmp_ID,
                            @Emp_Superior = #TempSuperiore.Emp_Superior,
                            @ECount = #TempSuperiore.EmployeeCount,
                            @Emp_Superior_Name  = #TempSuperiore.Emp_Superior_Name,
                             @Work_Email = t0080_emp_master.Work_Email
                  FROM      #TempSuperiore left join t0080_emp_master WITH (NOLOCK) on #TempSuperiore.Emp_Superior = t0080_emp_master.emp_id
                  WHERE     #TempSuperiore.Emp_Superior = @Emp_Superior 
			
				
			SELECT TOP 1 @HREmail_ID = Email_ID, @HR_Name = Emp_Full_Name
			FROM T0011_LOGIN L WITH (NOLOCK) Left Outer Join T0080_EMP_MASTER E WITH (NOLOCK) on L.Emp_ID = E.Emp_ID
			Where L.Emp_id=@Cmp_ID AND Is_HR = 1
			

			  ---ALTER dynamic template for Employee.				
		      Declare  @TableHead varchar(max),
					   @TableTail varchar(max)   
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
										<td width="800" height="24" align="center" valign="middle" style="background:#0b0505; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">Inout Report For Your Team on ( ' + @Date + ') </td>
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
										  '<td align=center><b><span style="font-size:small">Duration</span></b></td>' +
										 '<td align=center><b><span style="font-size:small">Status</span></b></td>' 
										  
										                                     
                  SET @TableTail = '</table></body></html>';                  	
                  DECLARE @Body AS VARCHAR(MAX)
                  Declare @Body_Total as varchar(Max)
                  declare @Body_total_1 as varchar(Max)
                  SET @Body = ( SELECT  
										T0080_EMP_MASTER.Alpha_Emp_Code  as [TD],
										T0080_EMP_MASTER.emp_first_name  as [TD],
										Isnull(#Temp.status_1_1,'-') as [TD],
										Isnull(#Temp.status_2_1,'-') as [TD],
										Isnull(#Temp.status_4_1,'-') As [TD],
										--Isnull(dbo.f_return_hours(second_5_1 - second_6_1),'-') As [TD],
										--Isnull(#Temp.status_7_1,'-') As [TD]
										case when Isnull(#Temp.status_3_1,'-')='-' then 'P' else Isnull(#Temp.status_3_1,'-') end  as [TD]
										
                                FROM    #Temp inner join T0080_EMP_MASTER WITH (NOLOCK) on #Temp.Emp_Id = T0080_EMP_MASTER.Emp_ID 
										left join T0090_EMP_REPORTING_DETAIL ED WITH (NOLOCK) on #Temp.Emp_ID = ED.Emp_ID                           
                                WHERE   ED.R_Emp_ID = @Emp_Superior --and Isnull(#Temp.status_3_1,'-') not in ('WO','HO') 
                                 ORDER BY  T0080_EMP_MASTER.alpha_Emp_code For XML raw('tr'), ELEMENTS) 
                             
                       
                       --if (@HREmail_ID <> '')
                       -- BEGIN
                       --    EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Orange', @recipients = @HREmail_ID,  @subject = 'Leave Approval Reminder', @body = @Body, @body_format = 'HTML'                               
                           
                       -- END
					
           		SET @Body_Total = '<tr><td colspan="6" align="center" style="font-weight:bold;font-size:16PX;"> Total :- [ ' + CAST(@ECount AS VARCHAR(255)) + ' ] </td></tr>'		
           		
           		Declare @Body_Present as varchar(Max)
           		Declare @Body_Absent as varchar(Max)
           		Declare @Body_Leave as varchar(Max)
           		Declare @Body_OD as varchar(Max)
           		Declare @Body_Weekoff as varchar(Max)
           		Declare @Body_Holiday as varchar(Max)
           		
           		    select @Body_Present = COUNT(*) from #Temp  left join T0090_EMP_REPORTING_DETAIL ED WITH (NOLOCK) on #Temp.Emp_ID = ED.Emp_ID where ED.R_Emp_ID = @Emp_Superior and Isnull(#Temp.status_3_1,'-') = '-' 
           		    select @Body_Absent = COUNT(*) from #Temp left join T0090_EMP_REPORTING_DETAIL ED WITH (NOLOCK) on #Temp.Emp_ID = ED.Emp_ID  where ED.R_Emp_ID = @Emp_Superior and Isnull(#Temp.status_3_1,'-') = 'AB' 
           		    select @Body_Leave = COUNT(*) from #Temp left join T0090_EMP_REPORTING_DETAIL ED WITH (NOLOCK) on #Temp.Emp_ID = ED.Emp_ID  where ED.R_Emp_ID = @Emp_Superior and Isnull(#Temp.status_3_1,'-') = 'L' 
           		    select @Body_OD = COUNT(*) from #Temp  left join T0090_EMP_REPORTING_DETAIL ED WITH (NOLOCK) on #Temp.Emp_ID = ED.Emp_ID where ED.R_Emp_ID = @Emp_Superior and Isnull(#Temp.status_3_1,'-') = 'OD' 
           		    select @Body_Weekoff = COUNT(*) from #Temp left join T0090_EMP_REPORTING_DETAIL ED WITH (NOLOCK) on #Temp.Emp_ID = ED.Emp_ID where ED.R_Emp_ID = @Emp_Superior and Isnull(#Temp.status_3_1,'-') = 'WO' 
					select @Body_Holiday = COUNT(*) from #Temp left join T0090_EMP_REPORTING_DETAIL ED WITH (NOLOCK) on #Temp.Emp_ID = ED.Emp_ID where ED.R_Emp_Id = @Emp_Superior and Isnull(#Temp.status_3_1,'-') = 'HO' 	
									
                 SET @Body_total_1 =
                 ( SELECT  
										'Present - ' + cast(isnull(@Body_Present,'0') as Varchar)  as [TD],
										'Absent - ' + cast(isnull(@Body_Absent,'0') as Varchar)  as [TD],
										'Leave - ' + cast(isnull(@Body_Leave,'0') as Varchar)  as [TD],
										'OD - ' + cast(isnull(@Body_OD,'0') as Varchar)  as [TD],
										'WeekOff - ' + cast(isnull(@Body_Weekoff,'0') as Varchar)  As [TD],
						                'HoliDay - ' + cast(isnull(@Body_Holiday,'0') as Varchar)   as [TD]
							   For XML raw('tr'), ELEMENTS) 
							   
				   set @Body_Total_1 = Replace(@Body_Total_1, '<tr>', '<tr style=''font-weight: bold; color: #000000; background-color: darkgrey;''>')
           			
           		  SELECT  @Body = @TableHead + @Body + @Body_Total + @Body_Total_1 + @TableTail  
           		  
           		  Declare @subject as varchar(100)           
           		  Set @subject = 'Inout Report ( ' + @Date + ' )'
           		  
           		    Declare @profile as varchar(50)
       					  set @profile = ''
       					  
       					  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = @Cmp_Id
       					  
       					  if isnull(@profile,'') = ''
       					  begin
       					  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = 0
       					  end
           		    	
  
   if @CC_Email<>''
		set @HREmail_ID = @HREmail_ID + ';@CC_Email'
   
 
if @Body is not null
begin
print 1
			--EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Orange', @recipients = @HREmail_ID, @subject = @subject, @body = @Body, @body_format = 'HTML'
EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @Work_Email , @subject = @subject, @body = @Body, @body_format = 'HTML',@copy_recipients = @HREmail_ID
		
		--EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = 'Rohit@orangewebtech.com', @subject = @subject, @body = @Body, @body_format = 'HTML',@copy_recipients = @CC_Email
			--EXEC msdb.dbo.sp_send_dbmail @profile_name = 'com-i2', @recipients = 'Rohit@orangewebtech.com', @subject = 'Today''s Attendance', @body = @Body, @body_format = 'HTML',@copy_recipients = 'hardik@orangewebtech.com'  
end
			Set @HREmail_ID = ''
			Set @HR_Name = ''
			Set @ECount = 0
			set @Emp_Superior_Name=''
			
		 fetch next from Cur_Company into @Emp_Superior,@Ecount,@Emp_Superior_Name
	   end                    
	close Cur_Company                    
	deallocate Cur_Company         

End

