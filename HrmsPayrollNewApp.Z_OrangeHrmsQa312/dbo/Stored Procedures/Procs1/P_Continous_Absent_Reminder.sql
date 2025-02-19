
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_Continous_Absent_Reminder]
@CMP_ID_PASS NUMERIC(18,0) = 0,
@CC_EMAIL NVARCHAR(MAX) = '',
@CON_ABSENT_DAYS VARCHAR(10) = '3'
AS 
BEGIN   
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	  DECLARE @DATE VARCHAR(11)   
      DECLARE @APPROVAL_DAY AS NUMERIC    
      DECLARE @ReminderTemplate AS NVARCHAR(4000)
      Declare @From_Date as datetime
      Declare @To_date as datetime
      
      set @From_Date  = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
      set @To_date   = DATEADD(DAY, -(DAY(DATEADD(MONTH, 1, GETDATE()))),DATEADD(MONTH, 1, GETDATE()))
            
      SET @DATE = CAST(GETDATE() AS varchar(11))
      
      --declare @Con_Absent_Days as numeric
      --set @Con_Absent_Days = 3
       
       
       if @cmp_id_Pass = 0
			set @cmp_id_Pass=null
      
      IF OBJECT_ID('tempdb..#Temp') IS NOT NULL 
         BEGIN
               DROP TABLE #Temp
         END
       
       
       -------------------------------------------------------------------------------------------------------
       -------------------------------------------------------------------------------------------------------
       
       IF OBJECT_ID('tempdb..##tmp_Absent_Con_1') IS not NULL
		begin 
			drop table ##tmp_Absent_Con_1
		end

		create table ##tmp_Absent_Con_1
		(
			Emp_ID numeric, 
			F_DT datetime,
			toDate datetime,
			Absent_Days Numeric(18,0)
		)

		exec SP_RPT_EMP_ATTENDANCE_MUSTER_GET @Cmp_ID=@cmp_id_Pass,@From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0,@Constraint='',@Report_For='ABSENT_CON',@Con_Absent_Days=@Con_Absent_Days 

	
       ---------------------------------------------------------------------------------------------------------
	   ---------------------------------------------------------------------------------------------------------
			   
		--insert into #Temp
		--select 
		--EM.Cmp_id,Em.Emp_ID,Em.Alpha_Emp_Code,Em.Emp_Full_Name,Bm.Branch_Name,DSM.Desig_Name,Dm.Dept_Name,CONVERT(varchar(11),date_of_birth,103) as Date_of_birth
		--from t0080_emp_master EM 
		--inner join T0095_INCREMENT I on EM.Increment_ID = I.Increment_ID 
		--left join t0030_Branch_Master BM on I.Branch_ID = Bm.branch_id 
		--left join T0040_DEPARTMENT_MASTER DM on I.Dept_ID = DM.Dept_Id 
		--left join T0040_DESIGNATION_MASTER DSM on I.Desig_Id = DSM.Desig_ID 
		--where Date_Of_Birth is not null and month(Date_Of_Birth)=month(GETDATE()) and day(Date_Of_Birth) = day(GETDATE()) 
		--and isnull(Emp_Left,'N')<>'Y' and  em.Cmp_ID = isnull(@cmp_id_Pass,em.Cmp_ID)


      CREATE table #HR_Email
      ( 
		Row_Id INT IDENTITY(1, 1),
        Cmp_ID NUMERIC(18, 0)
      )   

	Insert Into #HR_Email (Cmp_ID)
	Select Cmp_Id From ##tmp_Absent_Con_1 T inner join T0080_EMP_MASTER E WITH (NOLOCK) on t.Emp_ID = E.Emp_ID   Group by Cmp_ID
	
	
	

	Declare @HREmail_ID	nvarchar(4000)
	Declare @Cmp_Id as numeric
	Declare @HR_Name as varchar(255)
	Declare @ECount as numeric
	
	declare Cur_Company cursor for                    
		select Cmp_Id from #HR_Email order by Cmp_ID
	open Cur_Company                      
	fetch next from Cur_Company into @Cmp_Id
	while @@fetch_status = 0                    
		begin     
				
			SELECT TOP 1 @HREmail_ID = Email_ID, @HR_Name = Emp_Full_Name
			FROM T0011_LOGIN L WITH (NOLOCK) Left Outer Join T0080_EMP_MASTER E WITH (NOLOCK) on L.Emp_ID = E.Emp_ID
			Where L.Cmp_ID=@Cmp_ID AND Is_HR = 1
			
			if isnull(@HREmail_ID,'')='' 
			begin
				select @HREmail_ID = (SELECT TOP 1 Email_ID FROM T0011_LOGIN WITH (NOLOCK) where Is_HR = 1)
			end

			Select @ECount = COUNT(distinct t1.Emp_Id) 
			from ##tmp_Absent_Con_1	t1
			inner join T0080_EMP_MASTER E WITH (NOLOCK) on t1.emp_id = E.Emp_ID 
			where t1.F_DT=(select min(F_DT) as F_DT From ##tmp_Absent_Con_1 t2 where t1.toDate=t2.toDate and t1.Emp_ID = t2.Emp_ID group by toDate)
			and (DATEDIFF(d, t1.F_DT, t1.toDate) +1) >= @Con_Absent_Days
			and Cmp_ID = @Cmp_Id
			
			
			  ---ALTER dynamic template for Employee.				
		      Declare  @TableHead varchar(max),
					   @TableTail varchar(max)   
           		  Set @TableHead = '<html><head>' +
								  '<style>' +
								  'td {border: solid black 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:8pt; text-align:Center;} ' +
								  '</style>' +
								  '</head>' +
								  '<body>
								  <div style=" font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">
								  Dear ' + isnull(@HR_Name,'') + ' </div>	<br/>					
								  
								  <table width="800" border="0" align="center" cellpadding="0" cellspacing="0" style="border:1px solid #cacaca; border-radius: 10px 10px 10px 10px;" >
								  <tr>
									 <td align="center" valign="middle"><table width="800" border="0" cellspacing="0" cellpadding="0">
										<tr>
										<td height="9" align="center" valign="middle" ></td>
										</tr>
									  <tr>
										<td width="800" height="24" align="center" valign="middle" style="background:#0b0505; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">Today''s Continuous Absent Report ( ' + @Date + ') </td>
									  </tr>
										  <tr>
											<td height="4" align="center" valign="middle"></td>
										  </tr>
										  <tr>
											<td width="800" align="center" valign="middle" style="border:1px solid #cacaca; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#000000;  text-decoration:none; text-align:center; font-size:12px;">Total Employees Absent: [ ' + CAST(@ECount AS VARCHAR(255)) + ' ] </td>
										  </tr>
										  <tr>
											<td height="8" align="center" valign="middle"></td>
										  </tr>
								  </table>
                                    
								  <table border="1" width="800" height="24" align="center" valign="middle" style="background: #FFFFF;border-color:solid black;
									border-radius: 10px 10px 10px 10px; font-family: Arial, Helvetica, sans-serif;
									color: #000000; text-decoration: none; font-weight: normal; text-align: center;
									font-size: 12px;">' +
										  '<tr border="1"><td align=center><span style="font-size:small"><b>Code</b></span></td>' +
										  '<td align=center><b><span style="font-size:small">Employee Name</span></b></td>' +
										  '<td align=center><b><span style="font-size:small">Branch</span></b></td>' +
										  '<td align=center><b><span style="font-size:small">Department</span></b></td>' +
										  '<td align=center><b><span style="font-size:small">Designation</span></b></td>' +
										  '<td align=center><b><span style="font-size:small">From Date</span></b></td>' +
										  '<td align=center><b><span style="font-size:small">To Date</span></b></td>' +
										  '<td align=center><b><span style="font-size:small">Absent Days</span></b></td>' 
										                                     
                  SET @TableTail = '</table></body></html>';                  	
                  DECLARE @Body AS VARCHAR(MAX)
                  SET @Body = ( SELECT  
										EM.Alpha_Emp_Code  as [TD],
										EM.Emp_Full_Name  as [TD],
										Isnull(Branch_Name,'-') as [TD],
										Isnull(Dept_Name,'-') as [TD],
										Isnull(Desig_Name,'-') as [TD],
										Isnull(convert(varchar(11),F_Dt,103),'-') As [TD],
										Isnull(convert(varchar(11),toDate,103),'-') As [TD],
										Isnull((DATEDIFF(d, t1.F_DT, t1.toDate) +1),'-') As [TD]
										from ##tmp_Absent_Con_1	t1
										Inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON t1.Emp_ID = EM.Emp_ID
										INNER JOIN ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,I.Type_ID FROM dbo.T0095_Increment I WITH (NOLOCK) inner join 
											( select max(Increment_ID) as Increment_ID , Emp_ID From dbo.T0095_Increment WITH (NOLOCK)	-- Ankit 08092014 for Same Date Increment
											where Increment_Effective_date <= @To_Date
											and Cmp_ID = @Cmp_ID
											group by emp_ID  ) Qry on
											I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)Q_I ON
										EM.EMP_ID = Q_I.EMP_ID INNER JOIN dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
										dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
										dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
										dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID  INNER JOIN
										T0010_COMPANY_MASTER cm WITH (NOLOCK) on cm.cmp_id = EM.cmp_id 
										INNER JOIN
										T0040_TYPE_MASTER TM WITH (NOLOCK) ON TM.Type_ID = Q_I.Type_ID
										where t1.F_DT=(select min(F_DT) as F_DT From ##tmp_Absent_Con_1 t2 where t1.toDate=t2.toDate and t1.Emp_ID = t2.Emp_ID group by toDate)
										--t1.F_DT=(select min(F_DT) as F_DT From #tmp_Absent_Con_1 t2 where t1.toDate=t2.toDate group by toDate) 
										and (DATEDIFF(d, t1.F_DT, t1.toDate) +1) >= @Con_Absent_Days
								
								Order by Case When IsNumeric(EM.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + EM.Alpha_Emp_Code, 20)
								When IsNumeric(EM.Alpha_Emp_Code) = 0 then Left(EM.Alpha_Emp_Code + Replicate('',21), 20)
									Else EM.Alpha_Emp_Code
								End--,For_date
                                For XML raw('tr'), ELEMENTS) 
                             
                       
                       --if (@HREmail_ID <> '')
                       -- BEGIN
                       --    EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Orange', @recipients = @HREmail_ID,  @subject = 'Leave Approval Reminder', @body = @Body, @body_format = 'HTML'                               
                           
                       -- END
					
           			
           		  SELECT  @Body = @TableHead + @Body + @TableTail  
           		  
           		  Declare @subject as varchar(100)           
           		  Set @subject = 'Continuous Absent Report for ( ' + @Date + ' )'
           		  
           		  Declare @profile as varchar(50)
				  set @profile = ''
				  
				  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = @Cmp_Id
				  
				  if isnull(@profile,'') = ''
				  begin
				  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = 0
				  end
		  -- select @Body
			if isnull(@HREmail_ID,'') <> '' or isnull(@CC_Email,'') <> ''       	
			begin
			print 1
				EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @HREmail_ID, @subject = @subject, @body = @Body, @body_format = 'HTML',@copy_recipients = @CC_Email
			end	
		--	EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = 'Rohit@orangewebtech.com', @subject = @subject, @body = @Body, @body_format = 'HTML',@copy_recipients = @CC_Email
			
			Set @HREmail_ID = ''
			Set @HR_Name = ''
			Set @ECount = 0
			
		 fetch next from Cur_Company into @Cmp_Id
	   end                    
	close Cur_Company                    
	deallocate Cur_Company         

End

