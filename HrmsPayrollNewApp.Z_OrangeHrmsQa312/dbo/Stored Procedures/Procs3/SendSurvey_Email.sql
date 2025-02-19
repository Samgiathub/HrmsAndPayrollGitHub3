

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SendSurvey_Email]
	
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


BEGIN
	 IF OBJECT_ID('tempdb..#Temp') IS NOT NULL 
     BEGIN
           DROP TABLE #Temp
     END
 create table #temp 
 (
	 Cmp_ID NUMERIC(18, 0)
	,survey_id numeric(18,0)
	,survey_title varchar(100)
	,SurveyStart_Date datetime
	,Survey_OpenTill datetime
	,branch_id		numeric(18,0)
	,Survey_EmpId varchar(max)
 )        
 
  CREATE table #HR_Email
      ( 
		Row_Id INT IDENTITY(1, 1),
        Cmp_ID NUMERIC(18, 0)
      )   

insert into #temp(Cmp_ID,Survey_ID,Survey_Title,SurveyStart_Date,Survey_OpenTill,branch_id,Survey_EmpId)
(
	Select Cmp_ID,Survey_ID,Survey_Title,SurveyStart_Date,Survey_OpenTill,branch_id,Survey_EmpId
	from 
	T0050_SurveyMaster WITH (NOLOCK) where CONVERT(varchar(10),survey_updatedate,103)   = CONVERT(varchar(10),GETDATE(),103) 
)

Insert Into #HR_Email (Cmp_ID)
	Select Cmp_Id From #Temp Group by Cmp_ID

	Declare @Cmp_Id as numeric
	Declare @survey_id as numeric
	declare @Survey_EmpId as varchar(max)
	declare @branch_id		numeric(18,0)
	declare @send_recipients as varchar(max)
	set @send_recipients = ''
	declare @emp_email as varchar(50)

declare Cur_Company cursor for                    
	select Cmp_Id from #HR_Email order by Cmp_ID
	open Cur_Company                      
	fetch next from Cur_Company into @Cmp_Id
	while @@fetch_status = 0    
	begin
		  
		  --2nd loop
		  declare cur_survey cursor for
			select survey_id,branch_id,Survey_EmpId from #temp where Cmp_ID = @Cmp_Id
		  open cur_survey
		  fetch next from cur_survey into @survey_id,@branch_id,@Survey_EmpId
		  while @@FETCH_STATUS = 0
		  begin
					Declare	@TableHead varchar(max),
							@TableTail varchar(max) 
										
					Set @TableHead = '<html><head>' +
						  '<style>' +
						  'td {border: solid black 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:8pt;} ' +
						  '</style>' +
						  '</head>' +
						  '<body>
						  	<br/>					
						  
						  <table width="800" border="0" align="center" cellpadding="0" cellspacing="0" style="border:1px solid #cacaca; border-radius: 10px 10px 10px 10px;" >
						  <tr>
							 <td align="center" valign="middle"><table width="800" border="0" cellspacing="0" cellpadding="0">
								<tr>
								<td height="9" align="center" valign="middle" ></td>
								</tr>
							  <tr>
								<td width="800" height="24" align="center" valign="middle" style="background:#0b0505; border-radius: 10px 10px 10px 10px; font-family:Arial, Helvetica, sans-serif; color:#FFFFFF;  text-decoration:none; font-weight:bold; text-align:center; font-size:13px;">Fill The Survey Form</td>
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
							font-size: 12px;">'+
						  '<tr border="1"><td align=center><span style="font-size:small"><b>Survey Title</b></span></td>' +
						  '<td align=center><b><span style="font-size:small">Start Date</span></b></td>' +
						  '<td align=center><b><span style="font-size:small">Open Till</span></b></td>'
							
							
					SET @TableTail = '<tr><td colspan="3"><a href=http://localhost:55829/Orange_Aspen/ess_surveyform.aspx><u>Go To Survey Form </u></a></td></tr></table></body></html>'; 
					DECLARE @Body AS VARCHAR(MAX)
				
							
					set @Body = ( SELECT  
									Survey_Title  as [TD],
									left(CAST(SurveyStart_Date AS DATETIME),12)	 as [TD],
									left(CAST(Survey_OpenTill AS DATETIME),12) as [TD]
							FROM    #Temp
							WHERE   Cmp_ID = @Cmp_Id and survey_id=@survey_id ORDER BY  RIGHT(REPLICATE(N' ', 500) + SurveyStart_Date, 500) For XML raw('tr'), ELEMENTS) 
			
					SELECT  @Body = @TableHead + @Body + @TableTail    
					
					
					
					if @Survey_EmpId is not null
						begin 
						  --3rd loop						
							declare cur_emp cursor for
								--select  work_email from dbo.Split (@Survey_EmpId,'#') left join T0080_EMP_MASTER on Emp_ID = cast(data  as numeric) 
								select Work_Email from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID IN(select  cast(data  as numeric) from dbo.Split (@Survey_EmpId,'#') WHERE DATA <> '')
							open cur_emp 
								fetch next from cur_emp into @emp_email
								while @@FETCH_STATUS = 0									
									begin
										
										if @send_recipients = ''
											begin
												set	@send_recipients = @emp_email
											End
										Else
											begin
												set @send_recipients = @send_recipients + ';' +  @emp_email--Rtrim(Ltrim(isnull('',)))
											end
										
										fetch next from cur_emp into @emp_email
									End
							close cur_emp
							deallocate cur_emp	
						end
					else 
						begin 
							if @branch_id is not null
								begin 
									declare cur_emp cursor for
										select Work_Email from T0080_EMP_MASTER  e WITH (NOLOCK) left join T0095_INCREMENT i WITH (NOLOCK) on i.Emp_ID = i.Emp_ID and i.increment_id = (select MAX(Increment_ID) from T0095_INCREMENT WITH (NOLOCK) where Emp_ID = i.emp_id)
										where i.Branch_ID = @branch_id and e.Cmp_ID = @cmp_id
									open cur_emp 
										fetch next from cur_emp into @emp_email
										while @@FETCH_STATUS = 0
											begin
												if @send_recipients = ''
													set	@send_recipients = @emp_email
												Else
													set @send_recipients = @send_recipients + ';' +  @emp_email--Rtrim(Ltrim(isnull('',@emp_email)))
																							
												fetch next from cur_emp into @emp_email
											End
									close cur_emp
									deallocate cur_emp	
								end
							else
								begin
									declare cur_emp cursor for
										select Work_Email from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID = @Cmp_Id
									open cur_emp 
										fetch next from cur_emp into @emp_email
										while @@FETCH_STATUS = 0
											begin
												if @send_recipients = ''
													set	@send_recipients = @emp_email
												Else
													set @send_recipients = @send_recipients + ';' + @emp_email -- Rtrim(Ltrim(isnull('',@emp_email)))
													
												fetch next from cur_emp into @emp_email
											End
									close cur_emp
									deallocate cur_emp
								end
						end
						
					Declare @profile as varchar(50)
					  set @profile = ''
					  
					  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = @Cmp_Id
					  
					  if isnull(@profile,'') = ''
					  begin
					  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = 0
					  end  
					  
					Declare @subject as varchar(100)           
					  Set @subject = 'Fill The Survey Form'	
												
						--select @Body,@send_recipients,@subject,@Cmp_Id,@survey_id
					EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @send_recipients, @subject = @subject, @body = @Body, @body_format = 'HTML',@copy_recipients = 'sneha@orangewebtech.com'
	
			fetch next from cur_survey into @survey_id,@branch_id,@Survey_EmpId
		  end
		close cur_survey
		deallocate cur_survey	
			
	fetch next from Cur_Company into @Cmp_Id
	End
    close Cur_Company                    
	deallocate Cur_Company        


--select * from #temp

drop table #temp
drop table #HR_Email
END

