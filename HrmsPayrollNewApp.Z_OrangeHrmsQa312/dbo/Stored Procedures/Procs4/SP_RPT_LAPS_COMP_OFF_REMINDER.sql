


-- =============================================
-- Author:		Nilesh Patel 
-- Create date: 09/09/2016
-- Description:	For Send Email of Laps Comp-Off Balance to Emp & Reporting Manager
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_LAPS_COMP_OFF_REMINDER]
	@cmp_id_Pass Numeric(18,0) = 0,
	@CC_Email Nvarchar(max) = ''
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @For_Date Datetime
	Set @For_Date = GETDATE()
	
	
	if Object_ID('tempdb..#Emp_Compoff_Details') is not null
		drop table Emp_Compoff_Details
		
	if @cmp_id_Pass = 0
		set @cmp_id_Pass = NULL
		
	CREATE Table #Emp_Compoff_Details
	(
		Emp_ID	     Numeric(18,0),
		Cmp_ID	     Numeric(18,0),
		Emp_Code     Varchar(100),
		Emp_Name     Varchar(1000),
		Designation  Varchar(500),
		For_date	 DATETIME,		
		Balance		 Numeric(18,2),
		Due_Date	 DATETIME,	
		Remaining_Days Numeric(18,0)
	)
	
	 exec SP_RPT_COMPOFF_Avail_Balance @Cmp_ID=149,@To_Date=@For_Date,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0,@Leave_ID=0,@Constraint='14838',@Flag='TRUE',@Email_Flag = 'TRUE'
	

	Declare @EmpEmail_ID nvarchar(4000)
	Declare @Cmp_Id as numeric
	Declare @Emp_Id as numeric
	Declare @HR_Name as varchar(255)
	Declare @ECount as numeric
	
	declare Cur_Company cursor for                    
		select DISTINCT Cmp_ID,Emp_ID from #Emp_Compoff_Details where (Remaining_Days = 10 or Remaining_Days = 3) order by Cmp_ID
	open Cur_Company                      
	fetch next from Cur_Company into @Cmp_Id,@Emp_Id
	while @@fetch_status = 0                    
		begin     
				
			Select @EmpEmail_ID = ISNULL(Work_Email,''),@HR_Name = isnull(Emp_Full_Name,'') From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_Id AND Cmp_ID = @Cmp_Id
			
			Select @ECount = COUNT(Emp_Id) From #Emp_Compoff_Details where Emp_ID = @Emp_Id and Cmp_ID = @Cmp_Id
			
			  ---ALTER dynamic template for Employee.				
		      Declare  @TableHead varchar(max),
					   @TableTail varchar(max)   
           		  Set @TableHead = '<html><head>' +
								  '<style>' +
								  'td {border: solid #cacaca 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:8pt;} ' +
								  '</style>' +
								  '</head>' +
								  '<body>
								  <div style=" font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">
								  Dear ' + @HR_Name + ' </div>	<br/>					
								  
								  <table width="800" border="0" align="center" cellpadding="0" cellspacing="0" style="border:1px solid #cacaca; border-collapse: collapse" >
								  <tr>
									 <td align="center" valign="middle"><table width="800" border="0" cellspacing="0" cellpadding="0">
										<tr>
										<td height="9" align="center" valign="middle" ></td>
										</tr>
									  <tr>
										<td width="800" height="24" align="center" valign="middle" style="background:#0b0505; border-collapse: collapse; font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">Comp-off Lapse Details Report ( ' + REPLACE(CONVERT(VARCHAR(11),@For_Date,103),' ','/')  + ' ) </td>
									  </tr>5
										  <tr>
											<td height="4" align="center" valign="middle"></td>
										  </tr>
										  <tr>
											<td width="800" align="right" valign="middle" style=" border-collapse: collapse; font-family:Arial, Helvetica, sans-serif; color:#000000;  text-decoration:none; text-align:center; font-size:12px;">Total Count: [ ' + CAST(@ECount AS VARCHAR(255)) + ' ] </td>
										  </tr>
										  <tr>
											<td height="8" align="center" valign="middle"></td>
										  </tr>
								  </table>
                                    
								  <table border="1" width="800" height="24" align="center" valign="middle" style="background: #FFFFF;border-color:solid #cacaca;
									border-collapse: collapse; font-family:verdana,Arial, Helvetica, sans-serif;
									text-decoration: none; font-weight: normal; text-align: left;
									font-size: 11px;">' +
										  '<tr border="1"><td align=center><span><b>Code</b></span></td>' +
										  '<td align=center><b><span>Employee Name</span></b></td>' +
										  '<td align=center><b><span>Designation</span></b></td>' +
										  '<td align=center><b><span>For Date </span></b></td>' + 
										  '<td align=center><b><span>Comp-off Balance</span></b></td>' + 
										  '<td align=center><b><span>Due Date</span></b></td>' +
										  '<td align=center><b><span>Remaining Days</span></b></td></tr>' 
                  SET @TableTail = '</table></body></html>';                  	
                  DECLARE @Body AS VARCHAR(MAX)
                  SET @Body = ( SELECT  
										[td/@align]='center',
										td = Emp_Code,'',
										[td/@align]='center',
										td = Emp_Name,'',
										[td/@align]='center',
										td = Isnull(Designation,'-'),'',
										[td/@align]='center',
										td = REPLACE(CONVERT(VARCHAR(11),For_date,103),' ','/'),'',
										[td/@align]='center',
										td = Balance,'',
										[td/@align]='center',
										td = REPLACE(CONVERT(VARCHAR(11),Due_Date,103),' ','/'),'',
										[td/@align]='center',
										td = Remaining_Days,''
                                FROM    #Emp_Compoff_Details
                                WHERE   Cmp_ID = @Cmp_Id AND Emp_ID = @Emp_Id and (Remaining_Days = 10 or Remaining_Days = 3)
                                ORDER BY  Emp_code For XML path('tr'))
                            
           		  SELECT  @Body = @TableHead + @Body + @TableTail  
           		  
           		  Declare @subject as varchar(100)           
           		  Set @subject = 'Comp-off Laps Details Report ( ' + REPLACE(CONVERT(VARCHAR(11),@For_Date,103),' ','/')  + ' )'
           		  
           		    Declare @profile as varchar(50)
       					  set @profile = ''
       					  
       					  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = @Cmp_Id
       					  
       					  if isnull(@profile,'') = ''
       					  begin
       					  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = 0
       					  end
           	
           	if @EmpEmail_ID <> '' or @EmpEmail_ID is not null
           		Begin
           			EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @EmpEmail_ID, @subject = @subject, @body = @Body, @body_format = 'HTML',@copy_recipients = ''
           		End	    		 	           			              

			Set @EmpEmail_ID = ''
			Set @HR_Name = ''
			Set @ECount = 0
			
		 fetch next from Cur_Company into @Cmp_Id,@Emp_Id
	   end                    
	close Cur_Company                    
	deallocate Cur_Company 
	
	
END

