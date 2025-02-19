
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Employee_Yesterday_Late_mark_reminder]
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
	   Emp_ID   numeric ,  
	   Cmp_ID   numeric ,  
	   Increment_ID numeric,  
	   For_Date  Datetime ,  
	   In_Time   Datetime ,  
	   Shift_Time  Datetime ,  
	   Late_Sec  int default 0 ,  
	   Late_Limit_Sec int default 0,  
	   Late_Hour  varchar(10), 
	   Branch_Id NUMERIC,
	   Late_Limit Varchar(100),
	   Out_Time   Datetime,			
	   Shift_End_Time  Datetime,	
	   Shift_Max_St_Time Datetime	
	   ,Shift_max_Ed_Time DATETIME  
	   ,Early_Sec INT DEFAULT 0     
	   ,Early_Limit_Sec int default 0 
	   ,Early_hour VARCHAR(10) 
	   ,Early_Limit Varchar(100) 
	   ,Shift_ID	numeric  default 0
	   ,Is_Late		tinyint default 0  
	  )  
	 insert into #Temp
	  exec SP_RPT_EMP_LATE_RECORD_GET @Cmp_ID=@cmp_id_Pass,@From_Date=@DATE,@To_Date=@DATE,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0,@Constraint='',@Report_Type='Late_Reminder'	
     
      CREATE table #HR_Email
      ( 
		Row_Id INT IDENTITY(1, 1),
        Cmp_ID NUMERIC(18, 0)
      )   

	Insert Into #HR_Email (Cmp_ID)
	Select Cmp_Id From #Temp Group by Cmp_ID

	Declare @HREmail_ID	nvarchar(4000)
	Declare @Cmp_Id as numeric
	Declare @HR_Name as varchar(255)
	Declare @ECount as numeric
	declare  @Work_Email varchar(500)
	
	declare Cur_Company cursor for                    
		select Cmp_ID from #HR_Email 
	open Cur_Company                      
	fetch next from Cur_Company into @Cmp_ID
	while @@fetch_status = 0                    
		begin     
			select @ECount = count(*) from #Temp where Cmp_ID = @Cmp_ID

			SELECT TOP 1 @HREmail_ID = isnull(Email_ID,''), @HR_Name = isnull(Emp_Full_Name,'')
			FROM T0011_LOGIN L WITH (NOLOCK) Left Outer Join T0080_EMP_MASTER E WITH (NOLOCK) on L.Emp_ID = E.Emp_ID
			Where L.Cmp_ID=@Cmp_ID AND Is_HR = 1
	
		      Declare  @TableHead varchar(max),
					   @TableTail varchar(max)   
           		  Set @TableHead = '<html><head>' +
								  '<style>' +
								  'TD {border: solid black 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:8pt;text-align:center;} ' +
								  '</style>' +
								  '</head>' +
								  '<body>
								  <div style=" font-family:Arial, Helvetica, sans-serif; color:Black;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">
								  Dear ' + isnull(@HR_Name,'') + ' </div>	<br/>					
								  
								  <table width="800" border="0" align="center" cellpadding="0" cellspacing="0" style="border:1px solid #cacaca; border-radius: 10px 10px 10px 10px;" >
								  <tr>
									 <td align="center" valign="middle"><table width="800" border="0" cellspacing="0" cellpadding="0">
										<tr>
										<td height="9" align="center" valign="middle" ></td>
										</tr>
									  <tr>
										<td width="800" height="24" align="center" valign="middle" style="background:#0b0505; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">Late Early report For ( ' + @Date + ') </td>
									  </tr>
										  <tr>
											<td height="4" align="center" valign="middle"></td>
										  </tr>
										  <tr>
											<td width="800" align="center" valign="middle" style="border:1px solid #cacaca; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#000000;  text-decoration:none; text-align:center; font-size:12px;">Total Late Employees : [ ' + CAST(@ECount AS VARCHAR(255)) + ' ] </td>
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
										 '<td align=center><b><span style="font-size:small">Shift In Time</span></b></td>'+
													'<td align=center><b><span style="font-size:small">Shift Out Time</span></b></td>' +
													'<td align=center><b><span style="font-size:small">In Time</span></b></td>' +
													'<td align=center><b><span style="font-size:small">Out Time</span></b></td>' +
													'<td align=center><b><span style="font-size:small">Late Limit</span></b></td>' +
													'<td align=center><b><span style="font-size:small">Early Limit</span></b></td>' +
													'<td align=center><b><span style="font-size:small">Late Hours</span></b></td>' +
													'<td align=center><b><span style="font-size:small">Early Hours</span></b></td> </tr>' 
										  
										                                     
                  SET @TableTail = '</table> <table width="100%" border="0" cellspacing="0" cellpadding="0">
                    <tr>
                        <td width="51%" align="center" valign="middle">
                            <span style="font-family: arial; font-size: 11px; font-weight: normal; color: #8f8f8f;
                                line-height: 17px;">Copyright &copy; 2016 - Orange Technolab Private Limited. All
                                Rights Reserved</span>
                        </td>
                        <td width="49%" align="right" valign="middle" style="font-family: arial; font-size: 11px;
                            font-weight: normal; color: #595858;">
                            Powered By : Orange Technolab P Ltd  
                        </td>
                    </tr>
                                              
                </table>
               </td>
               </tr>
               </table>
                
</body>
</html>';                  	
                  DECLARE @Body AS VARCHAR(MAX)
                  Declare @Body_Total as varchar(Max)
                  declare @Body_total_1 as varchar(Max)
                  SET @Body = ( SELECT  
										EM.Alpha_Emp_Code  as [TD],
										EM.emp_first_name  as [TD],
										dbo.F_Return_HHMM (T.Shift_Max_St_Time) as [TD],
										dbo.F_Return_HHMM (T.Shift_max_Ed_Time) as [TD],
										isnull(dbo.F_Return_HHMM (T.In_Time),'')  as [TD],
										isnull(dbo.F_Return_HHMM (T.Out_Time),'')  as [TD],
										isnull(T.Late_Limit,'')  as [TD],
										isnull(T.Early_Limit,'')  as [TD],
										case when isnull(T.Late_Hour,'0') = '0' then '00:00' ELSE T.Late_Hour end   as [TD],
										case when isnull(T.Early_hour,'0') = '0' then '00:00' ELSE T.Early_hour end   as [TD]
								FROM    #Temp T inner join T0080_EMP_MASTER EM WITH (NOLOCK) on T.Emp_Id = EM.Emp_ID 
                                WHERE   T.Cmp_ID=@cmp_id
                                 ORDER BY  EM.alpha_Emp_code For XML raw('tr'), ELEMENTS) 
              
              	  SELECT  @Body = @TableHead + @Body  + @TableTail  
           		  
           		  Declare @subject as varchar(100)           
           		  Set @subject = 'Late Early Report for ( ' + @Date + ' )'
           		  
           		    Declare @profile as varchar(50)
       					  set @profile = ''
       					  
       					  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = @Cmp_Id
       					  
       					  if isnull(@profile,'') = ''
       					  begin
       					  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = 0
       					  end
           	
		set @HREmail_ID = isnull(@HREmail_ID,'')
   
 ----select @Body
	if @Body is not null
	begin
		print 1
		--EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = 'rohit@orangewebtech.com' , @subject = @subject, @body = @Body, @body_format = 'HTML',@copy_recipients = @CC_Email
		EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @HREmail_ID , @subject = @subject, @body = @Body, @body_format = 'HTML',@copy_recipients = @CC_Email
	end
			Set @HREmail_ID = ''
			Set @HR_Name = ''
			Set @ECount = 0
			
		 fetch next from Cur_Company into @Cmp_ID
	   end                    
	close Cur_Company                    
	deallocate Cur_Company         

End


