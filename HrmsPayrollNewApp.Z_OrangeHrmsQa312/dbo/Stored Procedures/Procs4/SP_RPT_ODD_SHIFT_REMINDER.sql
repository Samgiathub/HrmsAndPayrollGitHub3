

-- =============================================
-- Author:		Nilesh Patel 
-- Create date: 19/08/2016
-- Description:	For Send Email of ODD Shift Details to Employee & Manager on Weekly Base
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_ODD_SHIFT_REMINDER]
	@cmp_id_Pass Numeric(18,0) = 0,
	@CC_Email Nvarchar(max) = ''
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	Declare @From_Date Datetime
	Declare @To_Date Datetime
	
	Set @From_Date = DATEADD(dd, DATEDIFF(dd, 0, getdate()),-7)
	Set @To_Date = DATEADD(dd, DATEDIFF(dd, 0, getdate()), 0)
	
	if Object_ID('tempdb..#Emp_Shift_Details') is not null
		drop table #Emp_Shift_Details
		
	if @cmp_id_Pass = 0
		set @cmp_id_Pass = NULL
		
	CREATE Table #Emp_Shift_Details
	(
		Emp_ID	     Numeric(18,0),
		Cmp_ID	     Numeric(18,0),
		Emp_Code     Varchar(100),
		Emp_Name     Varchar(1000),
		Designation  Varchar(500),
		For_date		DATETIME,		
		Shift_St_Time DATETIME,
		Shift_End_Time DATETIME,
		Shift_Hours   Varchar(50),
		Actual_St_Time DATETIME,
		Actual_End_Time DATETIME,
		Actual_Hours Varchar(50),
		Dev_St_Time Varchar(50),
		Dev_End_Time Varchar(50),
		Dev_Hours Varchar(50)
	)
	
    -- Insert statements for procedure here
	--exec SP_RPT_MISSING_INOUT @Cmp_ID=149,@From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0,@Constraint='',@Report_Type='Odd Shift',@Flag = 1
	exec SP_RPT_DEVIATION_REGISTER @Cmp_ID= @cmp_id_Pass,@From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0,@Constraint='',@Report_For='Format1',@Flag = 1
	--Select * ,dbo.F_Return_HHMM(Shift_IN_Time) as "In Time",dbo.F_Return_HHMM(Shift_OUT_Time) as "Out Time"  From #Emp_Shift_Details
	
	
	
	--Declare @Emp_Code Varchar(100)
	--Declare @Emp_Name Varchar(500)
	--Declare @Shift_Name Varchar(500)
	--Declare @For_Date Datetime
	--Declare @In_Time Time
	
	--Declare Cur_Shift_Details Cursor for
	--	Select Emp_Code,Emp_Name,Designation,Shift_Name,For_date,dbo.F_Return_HHMM(Shift_IN_Time),dbo.F_Return_HHMM(Shift_OUT_Time) From #Emp_Shift_Details
	--Open Cur_Shift_Details
	--fetch next from Cur_Shift_Details into 
	
	
	
	--CREATE table #HR_Email
 --   ( 
	--	Row_Id INT IDENTITY(1, 1),
 --       Cmp_ID NUMERIC(18, 0)
 --   )
	
	--Insert Into #HR_Email (Cmp_ID)
	--Select Cmp_Id From #Emp_Shift_Details Group by Cmp_ID 
	
	

	Declare @EmpEmail_ID nvarchar(4000)
	Declare @RprEmail_ID nvarchar(4000)
	Declare @Cmp_Id as numeric
	Declare @Emp_Id as numeric
	Declare @HR_Name as varchar(255)
	Declare @ECount as numeric
	
	DECLARE @Mail_For_DATE VARCHAR(11) 
	DECLARE @Mail_To_DATE VARCHAR(11)     
    SET @Mail_For_DATE = convert(varchar(11),@From_Date,103) 
    Set @Mail_To_DATE = convert(varchar(11),@To_Date,103)
	
	
	declare Cur_Company cursor for                    
		select DISTINCT Cmp_ID,Emp_ID from #Emp_Shift_Details order by Cmp_ID
	open Cur_Company                      
	fetch next from Cur_Company into @Cmp_Id,@Emp_Id
	while @@fetch_status = 0                    
		begin     
				
			Select @EmpEmail_ID = ISNULL(Work_Email,''),@HR_Name = isnull(Emp_Full_Name,'') From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_Id AND Cmp_ID = @Cmp_Id
			
			SELECT @RprEmail_ID = ISNULL(EM.Work_Email,'') FROM  T0080_EMP_MASTER EM WITH (NOLOCK) Inner JOIN T0090_EMP_REPORTING_DETAIL RM WITH (NOLOCK)
				ON EM.Emp_ID = RM.R_Emp_ID
				Inner join( SELECT MAX(Effect_Date) as Effective_Date,Emp_ID 
							FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
							where Effect_Date <= GETDATE() 
							and Emp_ID = @Emp_Id
							GROUP BY Emp_ID 
						  ) qry
				ON qry.Emp_ID = RM.Emp_ID and qry.Effective_Date = RM.Effect_Date
			
			Select @ECount = COUNT(Emp_Id) From #Emp_Shift_Details where Emp_ID = @Emp_Id and Cmp_ID = @Cmp_Id
			
			
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
										<td width="800" height="24" align="center" valign="middle" style="background:#0b0505; border-collapse: collapse; font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">Shift Deviation Report ( ' + @Mail_For_DATE + ' - ' + @Mail_To_DATE + ' ) </td>
									  </tr>
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
										  '<tr border="1"><td align=center rowspan="2"><span><b>Code</b></span></td>' +
										  '<td align=center rowspan="2"><b><span>Employee Name</span></b></td>' +
										  '<td align=center rowspan="2"><b><span>Designation</span></b></td>' +
										  '<td align=center rowspan="2"><b><span>For Date </span></b></td>' + 
										  
										  '<td align=center colspan="3"><b><span>Allocate Shift</span></b></td>' + 
										  '<td align=center colspan="3"><b><span>Actual In/Out</span></b></td>' +
										  '<td align=center colspan="3"><b><span>Deviation Shift</span></b></td></tr>' +
										  
										  '<tr border="1"><td align=center><span><b>From</b></span></td>' +
										  '<td align=center><span><b>To</b></span></td>' +
										  '<td align=center><span><b>Hours</b></span></td>' +
										  
										  '<td align=center><span><b>From</b></span></td>' +
										  '<td align=center><span><b>To</b></span></td>' +
										  '<td align=center><span><b>Hours</b></span></td>' +
										  
										  '<td align=center><span><b>From</b></span></td>' +
										  '<td align=center><span><b>To</b></span></td>' +
										  '<td align=center><span><b>Hours</b></span></td></tr>'
                  SET @TableTail = '</table></body></html>';                  	
                  DECLARE @Body AS VARCHAR(MAX)
                  SET @Body = ( SELECT  
										Emp_Code  as [TD],
										Emp_Name  as [TD],
										Isnull(Designation,'-') as [TD],
										convert(varchar(11),For_date,103) As [TD],
										dbo.F_Return_HHMM(Shift_St_Time)  As [TD],
										dbo.F_Return_HHMM(Shift_End_Time)  As [TD],
										dbo.F_Return_HHMM(Shift_Hours)  As [TD],
										dbo.F_Return_HHMM(Actual_St_Time)  As [TD],
										dbo.F_Return_HHMM(Actual_End_Time)  As [TD],
										dbo.F_Return_HHMM(Actual_Hours)  As [TD],
										Dev_St_Time As [TD],
										Dev_End_Time As [TD],
										Dev_Hours As [TD]
                                FROM    #Emp_Shift_Details
                                WHERE   Cmp_ID = @Cmp_Id AND Emp_ID = @Emp_Id ORDER BY  Emp_code For XML raw('tr'), ELEMENTS) 
                            
           		  SELECT  @Body = @TableHead + @Body + @TableTail  
           		  
           		  Declare @subject as varchar(100)           
           		  Set @subject = 'Shift Deviation Report ( ' + @Mail_For_DATE + ' - ' + @Mail_To_DATE + ' )'
           		  
           		    Declare @profile as varchar(50)
       					  set @profile = ''
       					  
       					  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = @Cmp_Id
       					  
       					  if isnull(@profile,'') = ''
       					  begin
       					  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = 0
       					  end
           	
           	if @EmpEmail_ID <> '' or @EmpEmail_ID is not null
           		Begin
           			EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @EmpEmail_ID, @subject = @subject, @body = @Body, @body_format = 'HTML',@copy_recipients = @RprEmail_ID
           		End	    		 	           			              

			Set @EmpEmail_ID = ''
			Set @HR_Name = ''
			Set @ECount = 0
			
		 fetch next from Cur_Company into @Cmp_Id,@Emp_Id
	   end                    
	close Cur_Company                    
	deallocate Cur_Company 
	
	
END

