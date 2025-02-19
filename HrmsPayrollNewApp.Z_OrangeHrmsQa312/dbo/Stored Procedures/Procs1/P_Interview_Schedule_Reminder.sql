-- =============================================
-- Author:		<Mayur Modi>
-- Create date: <18-02-2019>
-- Description:	<Send Interview Reminder Email to Employee before 1 day>
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================

--exec P_Interview_Schedule_Reminder
CREATE PROCEDURE [dbo].[P_Interview_Schedule_Reminder]
	
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

	DECLARE @emp_id int ,@Interview_Schedule_Id nvarchar(20),@Work_Email nvarchar(max),
@Emp_Full_Name nvarchar(max),@candidate_name nvarchar(max),@Schedule_Date nvarchar(max),
@candidate_email nvarchar(max),@Job_title nvarchar(max),@Location nvarchar(max),@memberemails nvarchar(max),@Cmp_Id as numeric,
@profile as varchar(50);
set @profile = ''
DECLARE emp_cursor CURSOR FOR     
 SELECT L.Emp_ID,v.Interview_Schedule_Id,l.Work_Email,  l.Emp_Full_Name
 ,ISNULL(sch.Initial, '') + ' ' + sch.Emp_First_Name + ' ' + ISNULL(sch.Emp_Second_Name, '') + ' ' + sch.Emp_Last_Name AS candidate_name,cast(v.Schedule_Date as datetime) as Schedule_Date,
 sch.Primary_email as candidate_email,
 pr.Job_title
 --, brn.Branch_Name as Location
 , CASE WHEN pr.location IS NOT NULL 
                      THEN
                          (SELECT     (upper(isnull(Branch_Name, '')) + ' » ' + upper(isnull(branch_city, ''))) + ' , '
                            FROM          v0030_branch_master d
                            WHERE      d .Branch_ID IN
                                                       (SELECT     cast(data AS numeric(18, 0))
                                                         FROM          dbo.Split(ISNULL(pr.location, '0'), '#')
                                                         WHERE      data <> 0) FOR XML path('')) ELSE '' END AS Location,
isnull(T0080_EMP_MASTER_1.Work_Email,'') + ';'+  isnull(T0080_EMP_MASTER_2.Work_Email,'') + ';'+ isnull(T0080_EMP_MASTER_3.Work_Email,'') AS memberemails,v.Cmp_Id
		FROM T0055_HRMS_Interview_Schedule v WITH (NOLOCK) inner Join T0080_EMP_MASTER l WITH (NOLOCK) on v.S_Emp_Id = l.Emp_ID 
		LEFT OUTER JOIN dbo.T0080_EMP_MASTER AS T0080_EMP_MASTER_1 WITH (NOLOCK) ON v.S_Emp_Id2 = T0080_EMP_MASTER_1.Emp_ID
		LEFT OUTER JOIN dbo.T0080_EMP_MASTER AS T0080_EMP_MASTER_2 WITH (NOLOCK) ON v.S_Emp_Id3 = T0080_EMP_MASTER_2.Emp_ID
		LEFT OUTER JOIN dbo.T0080_EMP_MASTER AS T0080_EMP_MASTER_3 WITH (NOLOCK) ON v.S_Emp_ID4 = T0080_EMP_MASTER_3.Emp_ID
		inner join T0055_Resume_Master sch WITH (NOLOCK) on sch.Resume_Id = v.Resume_Id
		inner join T0052_HRMS_Posted_Recruitment pr WITH (NOLOCK) on pr.Rec_Post_Id = v.Rec_Post_Id
		inner join T0050_HRMS_Recruitment_Request rr WITH (NOLOCK) on rr.Rec_Req_ID = pr.Rec_Req_ID
		inner join T0030_BRANCH_MASTER brn WITH (NOLOCK) on brn.Branch_ID= rr.Branch_ID
		Where 
		l.Work_Email <> '' 
		and l.Emp_Left = 'n'
		and	cast(convert(varchar(10),Schedule_Date, 110) as datetime) = cast(convert(varchar(10), getdate() -1, 110) as datetime)
		order by Schedule_Date asc   
  
OPEN emp_cursor    
  
FETCH NEXT FROM emp_cursor     
INTO @emp_id,@Interview_Schedule_Id,@Work_Email,@Emp_Full_Name,@candidate_name,@Schedule_Date,@candidate_email,@Job_title,@Location,@memberemails,@Cmp_Id
WHILE @@FETCH_STATUS = 0    
BEGIN    
select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = @Cmp_Id
DECLARE @Body AS VARCHAR(MAX)
				SET @Body = '<html>
								<head>
								</head>
								<body>
									<table border="0" cellpadding="2" cellspacing="0" width="100%">
	<tbody>
		<tr bgcolor="#FFFFFF">
			<td class="awards">
				<div align="justify">
					<p>
						<font face="Verdana" size="2">Dear <strong>'+@Emp_Full_Name+'</strong></font></p>
				</div>
			</td>
		</tr>
		<tr bgcolor="#FFFFFF">
			<td>
				<font face="Verdana" size="2">&nbsp;</font></td>
		</tr>		
		<tr bgcolor="#FFFFFF">
			<td style="height: 162px">
				<table bgcolor="#999999" border="0" cellpadding="3" cellspacing="1" width="100%">
					<tbody>
						<tr>
							<td bgcolor="#f2f2f2" class="awards" colspan="2" height="20">
								<strong><font color="#D9AD00" face="Tahoma, Verdana" size="2">Interview Details</font></strong></td>
						</tr>
						<tr>
							<td bgcolor="#f2f2f2" class="awards">
								<font face="Verdana" size="2"><strong>Applicant Name</strong></font></td>
							<td bgcolor="#FFFFFF" class="awards_black">
								<font face="Verdana" size="2">'+ @candidate_name+'</font></td>
						</tr>
						<tr>
							<td bgcolor="#f2f2f2" class="awards" width="29%">
								<font face="Verdana" size="2"><strong>Job Title</strong></font></td>
							<td bgcolor="#FFFFFF" class="awards_black" width="71%">
								<font face="Verdana" size="2">'+@Job_title+'</font></td>
						</tr>
						<tr>
							<td bgcolor="#f2f2f2" class="awards">
								<font face="Verdana" size="2"><strong>Interview Date</strong></font></td>
							<td bgcolor="#FFFFFF" class="awards_black">
								<font face="Verdana" size="2">'+@Schedule_Date+'</font></td>
						</tr>
						<tr>
							<td bgcolor="#f2f2f2" class="awards">
								<font face="Verdana" size="2"><strong>Location</strong></font></td>
							<td bgcolor="#FFFFFF" class="awards_black">
								<font face="Verdana" size="2">'+isnull(@Location,'')+'</font></td>
						</tr>
						<tr>
							<td bgcolor="#f2f2f2" class="awards">
								<font face="Verdana" size="2"><strong>Timing</strong></font></td>
							<td bgcolor="#FFFFFF" class="awards_black">
								<font face="Verdana" size="2">'+ SUBSTRING(CONVERT(nvarchar(100),@Schedule_Date),12,9) +'</font></td>
						</tr>
					</tbody>
				</table>
			</td>
		</tr>
	</tbody>
</table>'		
								--	SELECT @Body
  
     EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @Work_Email, @subject = 'Interview Schedule Reminder Email', @body = @Body, @body_format = 'HTML',@copy_recipients = @memberemails
    FETCH NEXT FROM emp_cursor     
INTO @emp_id,@Interview_Schedule_Id,@Work_Email,@Emp_Full_Name,@candidate_name,@Schedule_Date,@candidate_email,@Job_title,@Location,@memberemails,@Cmp_Id
   
END     
CLOSE emp_cursor;    
DEALLOCATE emp_cursor;    
END
