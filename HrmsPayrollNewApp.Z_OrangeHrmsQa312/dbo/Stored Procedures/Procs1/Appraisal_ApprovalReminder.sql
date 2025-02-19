


---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Appraisal_ApprovalReminder]
	@cmp_id_Pass Numeric(18,0) = 0,
	@CC_Email Nvarchar(max) = ''
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @Cmp_Id as numeric
	declare @enddate as datetime 
	declare @SA_Status as INT
	declare @overall_status as INT
	declare @rmid as NUMERIC(18,0)
	declare @r_id as NUMERIC(18,0)
	declare @empid as NUMERIC(18,0)
	declare @hod_dept	numeric(18,0)
	declare @CC_Email_id Nvarchar(max) 
	declare @GHCode as varchar(50)

	set @CC_Email_id =''
	
	declare @mandays as int 
	declare @mandays_per as int
	declare @hoddays as int 
	declare @GHdays as int
	
	set @mandays = 0
	set @mandays_per = 0
	set @hoddays = 0
	set @GHdays = 0

	declare @RM_Name as varchar(100)
	declare @RM_EmailId as varchar(100)
----------------------------------------
	Declare  @TableHead varchar(max),
			 @TableTail varchar(max)
	DECLARE @Body AS VARCHAR(MAX) 
	Declare @subject as varchar(100)    
	Declare @profile as varchar(50)
	
	CREATE table #HR_Email
	( 
		Row_Id INT IDENTITY(1, 1),
		Cmp_ID NUMERIC(18, 0)
	) 

	Insert Into #HR_Email (Cmp_ID)
		Select Cmp_Id From T0010_COMPANY_MASTER WITH (NOLOCK) Group by Cmp_ID

	CREATE TABLE #AppraisalInit
	(
		 Emp_Id			NUMERIC(18,0)
		,RM_Id			NUMERIC(18,0)
		,Init_Id		NUMERIC(18,0) 
		,Init_EndDate	DATETIME
		,cmp_id			NUMERIC(18,0)
		,Emp_Code		VARCHAR(100)
		,Emp_Name		varchar(100)
		,Dept			varchar(100)
		,Desig			varchar(100)
		,dept_id		numeric(18,0)
		,oldrefcode		varchar(50)
		,sendtoHod		int
		,hod_id			NUMERIC(18,0)--added on 21 Apr 2016
	)
	
	
	declare @cmp_frmdate datetime
	select @cmp_frmdate = From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id
	
	declare Cur_Company cursor for 
		select Cmp_Id from #HR_Email order by Cmp_ID
	open Cur_Company   
		fetch next from Cur_Company into @Cmp_Id		
		while @@fetch_status = 0  
			begin
				select @mandays=isnull(Emp_AssessApprove_days,0),@mandays_per=isnull(Emp_PA_Approve_RM_days,0),
					   @hoddays = isnull(PA_HOD_Days,0),@GHdays =isnull(PA_GH_Days,0)
				 from T0050_AppraisalLimit_Setting WITH (NOLOCK) where Cmp_ID= @Cmp_Id 
				and isnull(Effective_Date,@cmp_frmdate)= (select isnull(max(Effective_Date),@cmp_frmdate) from T0050_AppraisalLimit_Setting WITH (NOLOCK) where Cmp_ID= @cmp_id)	
			
				select @CC_Email_id = Cc_Email_Id from t0299_Schedule_Master WITH (NOLOCK) where cmp_id= @Cmp_Id
				
				---send employee assessment notification
				INSERT into #AppraisalInit(Emp_Id,Init_Id,Init_EndDate,cmp_id,RM_Id,Emp_Code,Emp_Name,Desig,Dept)
				(SELECT I.Emp_Id,InitiateId,SA_Enddate,@Cmp_Id,r.R_Emp_ID ,E.Alpha_Emp_Code,e.Emp_Full_Name,dg.Desig_Name,d.Dept_Name
					FROM T0050_HRMS_InitiateAppraisal I  WITH (NOLOCK) inner Join
						T0080_EMP_MASTER E WITH (NOLOCK) on E.Emp_ID = I.Emp_Id inner JOIN
						T0095_INCREMENT IC WITH (NOLOCK) on Ic.Emp_ID = I.Emp_ID and IC.Increment_Effective_Date = (select max(Increment_Effective_Date) from T0095_INCREMENT WITH (NOLOCK) where Emp_ID = I.emp_id)
						left join T0040_DEPARTMENT_MASTER D WITH (NOLOCK) on d.Dept_Id = Ic.Dept_ID left JOIN
							T0040_DESIGNATION_MASTER DG WITH (NOLOCK) on dg.Desig_ID = Ic.Desig_Id left join
						T0090_EMP_REPORTING_DETAIL R WITH (NOLOCK) on R.Emp_ID = I.Emp_Id AND						
						Effect_Date =  (select max(effect_date) from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) where emp_id=I.Emp_Id)										 
					WHERE SA_Status = 0 and I.Cmp_ID=@Cmp_Id)				
														
				declare cur_Rm cursor FOR
					select distinct r_emp_id,E.Emp_Full_Name ,e.Work_Email
					FROM T0090_EMP_REPORTING_DETAIL_Clone R WITH (NOLOCK) inner JOIN
						 T0080_EMP_MASTER E WITH (NOLOCK) on e.Emp_ID = r.r_emp_id
					WHERE R.cmp_id=@Cmp_Id
				open cur_Rm
					fetch next from cur_Rm into @rmid,@RM_Name,@RM_EmailId
					
					while @@fetch_status = 0
						BEGIN
							if EXISTS(select 1 from #AppraisalInit where RM_Id= @rmid)
								BEGIN
									
									set @TableHead =''
									set @TableTail =''
									set @Body=''
									
									Set @TableHead = '<html><head>
									<style>
									td {border: solid black 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:8pt;} 
									</style>
									</head>
									<body>
									<div style=" font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">
									Dear ' +  @RM_Name +  '</div>	<br/>					

									<table width="800" border="0" align="center" cellpadding="0" cellspacing="0" style="border:1px solid #cacaca; border-radius: 10px 10px 10px 10px;" >
									<tr>
									 <td align="center" valign="middle"><table width="800" border="0" cellspacing="0" cellpadding="0">
										<tr>
										<td height="9" align="center" valign="middle" ></td>
										</tr>
									  <tr>
										<td width="800" height="24" align="center" valign="middle" style="background:#0b0505; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">Appraisal-Employee Assessment Pending</td>
									  </tr>
										  <tr>
											<td height="4" align="center" valign="middle"></td>
										  </tr>
										  
										  <tr>
											<td height="8" align="center" valign="middle"></td>
										  </tr>
									</table>
									<table border="1" width="800" height="24" align="center" valign="middle" style="background: #FFFFF;border-color:solid black;
									border-radius: 10px 10px 10px 10px; font-family: Arial, Helvetica, sans-serif;
									color: #000000; text-decoration: none; font-weight: normal; text-align: left;
									font-size: 12px;">
										  <tr border="1"><td align=center><span style="font-size:small"><b>Employee Code</b></span></td>
										  <td align=center><b><span style="font-size:small">Employee Name</span></b></td>
										  <td align=center><b><span style="font-size:small">Department</span></b></td>
										  <td align=center><b><span style="font-size:small">Designation</span></b></td>' 
									
									SET @TableTail = '</table></body></html>';  
									 SET @Body = ( SELECT  
										Emp_Code  as [TD],
										Emp_name  as [TD],
										Isnull(Dept,'-') as [TD],
										Isnull(Desig,'-') as [TD]
									FROM    #AppraisalInit 
									WHERE   Cmp_ID = @Cmp_Id and RM_Id=@rmid and getdate() >= DATEADD(DAY,@mandays,Init_EndDate)
									ORDER BY  Emp_code For XML raw('tr'), ELEMENTS) 
									
									
									if isnull(@Body,'')<>''	
										BEGIN								
											SELECT  @Body = @TableHead + @Body + @TableTail  
											
											set @subject=''
           									 Set @subject = 'Employee Assessment Approval Pending-Appraisal'
		           							 
       										  set @profile = ''
					       					  
       										  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = @Cmp_Id
					       					  
       										  if isnull(@profile,'') = ''
       										  begin
       										  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = 0
       										  end	
		       								  
		       								
       										  if @RM_EmailId <>''  or isnull(@Body,'')<>''
       											EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @RM_EmailId, @subject = @subject, @body = @Body, @body_format = 'HTML',@copy_recipients = @CC_Email_id																						  
           											--select @Body,@RM_EmailId,@subject 										
       									END	
       									
       								  Set @RM_EmailId = ''
									  Set @RM_Name = ''
								END
							fetch next from cur_Rm into @rmid,@RM_Name,@RM_EmailId
						END
				close cur_Rm
				DEALLOCATE cur_Rm
				
				delete from #AppraisalInit
				
				-- send the employee performance assessment notification
				INSERT into #AppraisalInit(Emp_Id,Init_Id,Init_EndDate,cmp_id,RM_Id,Emp_Code,Emp_Name,Desig,Dept)
				(SELECT I.Emp_Id,InitiateId,SA_Enddate,@Cmp_Id,r.R_Emp_ID ,E.Alpha_Emp_Code,e.Emp_Full_Name,dg.Desig_Name,d.Dept_Name
					FROM T0050_HRMS_InitiateAppraisal I WITH (NOLOCK) inner Join
						T0080_EMP_MASTER E WITH (NOLOCK) on E.Emp_ID = I.Emp_Id inner JOIN
						T0095_INCREMENT IC WITH (NOLOCK) on Ic.Emp_ID = I.Emp_ID and IC.Increment_Effective_Date = (select max(Increment_Effective_Date) from T0095_INCREMENT WITH (NOLOCK) where Emp_ID = I.emp_id)
						left join T0040_DEPARTMENT_MASTER D WITH (NOLOCK) on d.Dept_Id = Ic.Dept_ID left JOIN
							T0040_DESIGNATION_MASTER DG WITH (NOLOCK) on dg.Desig_ID = Ic.Desig_Id left join
						T0090_EMP_REPORTING_DETAIL R WITH (NOLOCK) on R.Emp_ID = I.Emp_Id AND						
						Effect_Date =  (select max(effect_date) from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) where emp_id=I.Emp_Id)										 
					WHERE SA_Status = 1 and I.Overall_Status is null and I.Cmp_ID=@Cmp_Id)
				
				declare cur_Rm cursor FOR
					select distinct R_Emp_ID,E.Emp_Full_Name ,e.Work_Email
					FROM T0090_EMP_REPORTING_DETAIL  R WITH (NOLOCK) inner JOIN
						 T0080_EMP_MASTER E WITH (NOLOCK) on e.Emp_ID = r.R_Emp_ID
					WHERE R.cmp_id=@Cmp_Id
				open cur_Rm
					fetch next from cur_Rm into @rmid,@RM_Name,@RM_EmailId
					
					while @@fetch_status = 0
						BEGIN
							if EXISTS(select 1 from #AppraisalInit where RM_Id= @rmid)
								BEGIN
									
									set @TableHead =''
									set @TableTail =''
									set @Body=''
									
									Set @TableHead = '<html><head>
									<style>
									td {border: solid black 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:8pt;} 
									</style>
									</head>
									<body>
									<div style=" font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">
									Dear ' +  @RM_Name +  '</div>	<br/>					

									<table width="800" border="0" align="center" cellpadding="0" cellspacing="0" style="border:1px solid #cacaca; border-radius: 10px 10px 10px 10px;" >
									<tr>
									 <td align="center" valign="middle"><table width="800" border="0" cellspacing="0" cellpadding="0">
										<tr>
										<td height="9" align="center" valign="middle" ></td>
										</tr>
									  <tr>
										<td width="800" height="24" align="center" valign="middle" style="background:#0b0505; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">Appraisal-Employee Peformance Assessment Pending</td>
									  </tr>
										  <tr>
											<td height="4" align="center" valign="middle"></td>
										  </tr>
										  
										  <tr>
											<td height="8" align="center" valign="middle"></td>
										  </tr>
									</table>
									<table border="1" width="800" height="24" align="center" valign="middle" style="background: #FFFFF;border-color:solid black;
									border-radius: 10px 10px 10px 10px; font-family: Arial, Helvetica, sans-serif;
									color: #000000; text-decoration: none; font-weight: normal; text-align: left;
									font-size: 12px;">
										  <tr border="1"><td align=center><span style="font-size:small"><b>Employee Code</b></span></td>
										  <td align=center><b><span style="font-size:small">Employee Name</span></b></td>
										  <td align=center><b><span style="font-size:small">Department</span></b></td>
										  <td align=center><b><span style="font-size:small">Designation</span></b></td>' 
									
									SET @TableTail = '</table></body></html>';  
									 SET @Body = ( SELECT  
										Emp_Code  as [TD],
										Emp_name  as [TD],
										Isnull(Dept,'-') as [TD],
										Isnull(Desig,'-') as [TD]
									FROM    #AppraisalInit 
									WHERE   Cmp_ID = @Cmp_Id and RM_Id=@rmid and getdate() >= DATEADD(DAY,(@mandays+@mandays_per),Init_EndDate)
									ORDER BY  Emp_code For XML raw('tr'), ELEMENTS) 
									
										if isnull(@Body,'')<>''	
											BEGIN							
											SELECT  @Body = @TableHead + @Body + @TableTail  
											
											set @subject=''
           									 Set @subject = 'Employee Performance Assessment Approval Pending-Appraisal'
		           							 
       										  set @profile = ''
					       					  
       										  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = @Cmp_Id
					       					  
       										  if isnull(@profile,'') = ''
       										  begin
       										  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = 0
       										  end	
		       								  
       										  if @RM_EmailId <>''  or isnull(@Body,'')<>''         										
       											EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @RM_EmailId, @subject = @subject, @body = @Body, @body_format = 'HTML',@copy_recipients = @CC_Email_id																						  
       											--select @Body,@RM_EmailId,@subject
       									End	
       									
       								  Set @RM_EmailId = ''
									  Set @RM_Name = ''
								END
							fetch next from cur_Rm into @rmid,@RM_Name,@RM_EmailId
						END
				close cur_Rm
				DEALLOCATE cur_Rm
				
				delete from #AppraisalInit
				
				--send alert to Hod
				INSERT into #AppraisalInit(Emp_Id,Init_Id,Init_EndDate,cmp_id,RM_Id,Emp_Code,Emp_Name,Desig,Dept,dept_id,hod_id)
				(SELECT I.Emp_Id,InitiateId,SA_Enddate,@Cmp_Id,r.R_Emp_ID ,E.Alpha_Emp_Code,e.Emp_Full_Name,dg.Desig_Name,d.Dept_Name,ic.Dept_ID,(case when isnull(I.HOD_Id,0) <>0 then I.HOD_Id else DM.Emp_id end)
					FROM T0050_HRMS_InitiateAppraisal I WITH (NOLOCK)  inner Join
						T0080_EMP_MASTER E WITH (NOLOCK) on E.Emp_ID = I.Emp_Id inner JOIN
						T0095_INCREMENT IC WITH (NOLOCK) on Ic.Emp_ID = I.Emp_ID and IC.Increment_Effective_Date = (select max(Increment_Effective_Date) from T0095_INCREMENT WITH (NOLOCK) where Emp_ID = I.emp_id)
						left join T0040_DEPARTMENT_MASTER D WITH (NOLOCK) on d.Dept_Id = Ic.Dept_ID left JOIN
							T0040_DESIGNATION_MASTER DG WITH (NOLOCK) on dg.Desig_ID = Ic.Desig_Id left join
						T0090_EMP_REPORTING_DETAIL R WITH (NOLOCK) on R.Emp_ID = I.Emp_Id AND						
						Effect_Date =  (select max(effect_date) from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) where emp_id=I.Emp_Id)	
						left join T0095_Department_Manager DM WITH (NOLOCK) on dm.Dept_Id = ic.Dept_ID and dm.Effective_Date=(select max(Effective_Date) from T0095_Department_Manager WITH (NOLOCK) where dept_id=ic.Dept_ID )									 
					WHERE SA_Status = 1 and I.Overall_Status =0 and I.SendToHOD=1  and I.Cmp_ID=@Cmp_Id)
				declare cur_Rm cursor FOR
					select  distinct
						ed.Emp_ID,ed.Emp_Full_Name,ed.Work_Email,i.Dept_ID
						from T0050_HRMS_InitiateAppraisal as e WITH (NOLOCK) inner join 
						T0095_INCREMENT as i WITH (NOLOCK) on i.Emp_ID = e.Emp_ID and i.Increment_Effective_Date = (select max(Increment_Effective_Date) from T0095_INCREMENT WITH (NOLOCK) where emp_id=e.emp_id)
						left join T0095_Department_Manager DM WITH (NOLOCK) on dm.Dept_Id = i.Dept_ID and dm.Effective_Date=(select max(Effective_Date) from T0095_Department_Manager WITH (NOLOCK) where dept_id=i.Dept_ID )
						inner Join T0080_EMP_MASTER ED WITH (NOLOCK) on ed.Emp_ID = (case when isnull(e.HOD_Id,0) <>0 then e.HOD_Id else dm.Emp_id end)
						where e.SendToHOD=1 and e.Cmp_ID = @Cmp_Id
				open cur_Rm
					fetch next from cur_Rm into @rmid,@RM_Name,@RM_EmailId,@hod_dept				
					while @@fetch_status = 0
						BEGIN
							if EXISTS(select 1 from #AppraisalInit where hod_id= @rmid)
								BEGIN
									
									set @TableHead =''
									set @TableTail =''
									set @Body=''
									
									Set @TableHead = '<html><head>
									<style>
									td {border: solid black 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:8pt;} 
									</style>
									</head>
									<body>
									<div style=" font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">
									Dear ' +  @RM_Name +  '</div>	<br/>					

									<table width="800" border="0" align="center" cellpadding="0" cellspacing="0" style="border:1px solid #cacaca; border-radius: 10px 10px 10px 10px;" >
									<tr>
									 <td align="center" valign="middle"><table width="800" border="0" cellspacing="0" cellpadding="0">
										<tr>
										<td height="9" align="center" valign="middle" ></td>
										</tr>
									  <tr>
										<td width="800" height="24" align="center" valign="middle" style="background:#0b0505; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">Appraisal-Employee Peformance Assessment HOD Approval Pending</td>
									  </tr>
										  <tr>
											<td height="4" align="center" valign="middle"></td>
										  </tr>
										  
										  <tr>
											<td height="8" align="center" valign="middle"></td>
										  </tr>
									</table>
									<table border="1" width="800" height="24" align="center" valign="middle" style="background: #FFFFF;border-color:solid black;
									border-radius: 10px 10px 10px 10px; font-family: Arial, Helvetica, sans-serif;
									color: #000000; text-decoration: none; font-weight: normal; text-align: left;
									font-size: 12px;">
										  <tr border="1"><td align=center><span style="font-size:small"><b>Employee Code</b></span></td>
										  <td align=center><b><span style="font-size:small">Employee Name</span></b></td>
										  <td align=center><b><span style="font-size:small">Department</span></b></td>
										  <td align=center><b><span style="font-size:small">Designation</span></b></td>' 
									
									SET @TableTail = '</table></body></html>';  
									 SET @Body = ( SELECT  
										Emp_Code  as [TD],
										Emp_name  as [TD],
										Isnull(Dept,'-') as [TD],
										Isnull(Desig,'-') as [TD]
									FROM    #AppraisalInit 
									WHERE   Cmp_ID = @Cmp_Id and hod_id=@rmid and getdate() >= DATEADD(DAY,(@mandays+@mandays_per+@hoddays),Init_EndDate)
									ORDER BY  Emp_code For XML raw('tr'), ELEMENTS) 
									
									if isnull(@Body,'')<>''	
										BEGIN							
											SELECT  @Body = @TableHead + @Body + @TableTail  
											
											set @subject=''
           									 Set @subject = 'HOD Performance Assessment Approval Pending-Appraisal'
		           							 
       										  set @profile = ''
					       					  
       										  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = @Cmp_Id
					       					  
       										  if isnull(@profile,'') = ''
       										  begin
       										  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = 0
       										  end	
		       								  
       										  if @RM_EmailId <>''   or isnull(@Body,'')<>''        										
       											EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @RM_EmailId, @subject = @subject, @body = @Body, @body_format = 'HTML',@copy_recipients = @CC_Email_id																						  
       											--select @Body,@RM_EmailId,@subject
       										End	 
       								  Set @RM_EmailId = ''
									  Set @RM_Name = ''
								END
							fetch next from cur_Rm into @rmid,@RM_Name,@RM_EmailId,@hod_dept
						END
				close cur_Rm
				DEALLOCATE cur_Rm
				delete from #AppraisalInit
				
				--send alert to GH
				INSERT into #AppraisalInit(Emp_Id,Init_Id,Init_EndDate,cmp_id,RM_Id,Emp_Code,Emp_Name,Desig,Dept,oldrefcode,sendtoHod)
				(SELECT I.Emp_Id,InitiateId,SA_Enddate,@Cmp_Id,r.R_Emp_ID ,E.Alpha_Emp_Code,e.Emp_Full_Name,dg.Desig_Name,d.Dept_Name,EG.Alpha_Emp_Code,i.SendToHOD
					FROM T0050_HRMS_InitiateAppraisal I  WITH (NOLOCK) inner Join
						T0080_EMP_MASTER E WITH (NOLOCK) on E.Emp_ID = I.Emp_Id inner JOIN
						T0095_INCREMENT IC WITH (NOLOCK) on Ic.Emp_ID = I.Emp_ID and IC.Increment_Effective_Date = (select max(Increment_Effective_Date) from T0095_INCREMENT WITH (NOLOCK) where Emp_ID = I.emp_id)
						left join T0040_DEPARTMENT_MASTER D WITH (NOLOCK) on d.Dept_Id = Ic.Dept_ID left JOIN
							T0040_DESIGNATION_MASTER DG WITH (NOLOCK) on dg.Desig_ID = Ic.Desig_Id left join
						T0090_EMP_REPORTING_DETAIL R WITH (NOLOCK) on R.Emp_ID = I.Emp_Id AND						
						Effect_Date =  (select max(effect_date) from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) where emp_id=I.Emp_Id)	 inner  JOIN
						T0080_EMP_MASTER EG WITH (NOLOCK) on I.GH_Id = EG.Emp_ID								 
						
					WHERE SA_Status = 1 and Overall_Status = (CASE when I.SendToHOD=1 then 7 when I.SendToHOD=0 then 0 end)and I.Cmp_ID=@Cmp_Id)
				
					
				
				declare cur_Rm cursor FOR
					--select distinct r.Old_Ref_No,e.Emp_ID,E.Emp_Full_Name ,e.Work_Email
					--FROM T0080_EMP_MASTER R inner JOIN
					--	 T0080_EMP_MASTER E on r.Old_Ref_No = e.Alpha_Emp_Code
					--WHERE R.cmp_id=@Cmp_Id
					---above commented & below added on 25 Feb 2017-----------------------
					SELECT DISTINCT e.Alpha_Emp_Code as Old_Ref_No,e.Emp_ID,E.Emp_Full_Name ,e.Work_Email
					FROM T0050_HRMS_InitiateAppraisal IA WITH (NOLOCK) inner JOIN
						 T0080_EMP_MASTER R WITH (NOLOCK) on R.Emp_ID = IA.Emp_Id inner  JOIN
						  T0080_EMP_MASTER E WITH (NOLOCK) on IA.GH_Id = e.Emp_ID
					WHERE R.cmp_id=@Cmp_Id
				open cur_Rm
					fetch next from cur_Rm into @GHCode,@rmid,@RM_Name,@RM_EmailId				
					while @@fetch_status = 0
						BEGIN 
							if EXISTS(select 1 from #AppraisalInit where oldrefcode= @GHCode)
								BEGIN								
									set @TableHead =''
									set @TableTail =''
									set @Body=''
									
									Set @TableHead = '<html><head>
									<style>
									td {border: solid black 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:8pt;} 
									</style>
									</head>
									<body>
									<div style=" font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">
									Dear ' +  @RM_Name +  '</div>	<br/>					

									<table width="800" border="0" align="center" cellpadding="0" cellspacing="0" style="border:1px solid #cacaca; border-radius: 10px 10px 10px 10px;" >
									<tr>
									 <td align="center" valign="middle"><table width="800" border="0" cellspacing="0" cellpadding="0">
										<tr>
										<td height="9" align="center" valign="middle" ></td>
										</tr>
									  <tr>
										<td width="800" height="24" align="center" valign="middle" style="background:#0b0505; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">Appraisal-Employee Peformance Assessment Group Head Approval Pending</td>
									  </tr>
										  <tr>
											<td height="4" align="center" valign="middle"></td>
										  </tr>
										  
										  <tr>
											<td height="8" align="center" valign="middle"></td>
										  </tr>
									</table>
									<table border="1" width="800" height="24" align="center" valign="middle" style="background: #FFFFF;border-color:solid black;
									border-radius: 10px 10px 10px 10px; font-family: Arial, Helvetica, sans-serif;
									color: #000000; text-decoration: none; font-weight: normal; text-align: left;
									font-size: 12px;">
										  <tr border="1"><td align=center><span style="font-size:small"><b>Employee Code</b></span></td>
										  <td align=center><b><span style="font-size:small">Employee Name</span></b></td>
										  <td align=center><b><span style="font-size:small">Department</span></b></td>
										  <td align=center><b><span style="font-size:small">Designation</span></b></td>' 
									
									SET @TableTail = '</table></body></html>';  
									 SET @Body = ( SELECT  
										Emp_Code  as [TD],
										Emp_name  as [TD],
										Isnull(Dept,'-') as [TD],
										Isnull(Desig,'-') as [TD]
									FROM    #AppraisalInit 
									WHERE   Cmp_ID = @Cmp_Id and oldrefcode=@GHCode and 
											getdate() >= (case when sendtoHod = 0  then DATEADD(DAY,(@mandays+@mandays_per+@GHdays),Init_EndDate) else DATEADD(DAY,(@mandays+@mandays_per+@hoddays+@GHdays),Init_EndDate) end)
									ORDER BY  Emp_code For XML raw('tr'), ELEMENTS) 
									
									if isnull(@Body,'')<>''	
										BEGIN								
											SELECT  @Body = @TableHead + @Body + @TableTail  
										
											set @subject=''
           									Set @subject = 'Group Head Performance Assessment Approval Pending-Appraisal'
	           							 
       										set @profile = ''
				       					  
       										select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = @Cmp_Id
					       					  
       										if isnull(@profile,'') = ''
       										  begin
       										  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = 0
       										  end	
		       								  
       										if @RM_EmailId <>''   or isnull(@Body,'')<>''        										
       											EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @RM_EmailId, @subject = @subject, @body = @Body, @body_format = 'HTML',@copy_recipients = @CC_Email_id																						  
       											--select @Body,@RM_EmailId,@subject
       									END
       									
       								  Set @RM_EmailId = ''
									  Set @RM_Name = ''
								END
							fetch next from cur_Rm into @GHCode,@rmid,@RM_Name,@RM_EmailId
						END
				close cur_Rm
				DEALLOCATE cur_Rm
				delete from #AppraisalInit
				
				
				set @CC_Email_id =''
				set @mandays = 0
				set @mandays_per = 0
				set @hoddays = 0
				set @GHdays = 0
				fetch next from Cur_Company into @Cmp_Id	
			END
	close Cur_Company
	DEALLOCATE Cur_Company
	
	--select * from #AppraisalInit
	
	drop TABLE #HR_Email
	drop TABLE #AppraisalInit
END
---------------

