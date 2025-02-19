


--exec P_Self_Assessment_Probation_Reminder 120,''
-- =============================================
-- Author:		<Mukti>
-- Create date: <06-08-2018>
-- Description:	<Send Email Reminder to Employee to fill Self Assessment Probation>
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P_Self_Assessment_Probation_Reminder]
@CMP_ID_PASS NUMERIC(18,0) = 0,
@CC_EMAIL NVARCHAR(MAX) = ''
AS 

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN   
     
	DECLARE @DATE VARCHAR(11)   
    DECLARE @APPROVAL_DAY AS NUMERIC    
    DECLARE @REMINDERTEMPLATE AS NVARCHAR(4000)
    SET @DATE = CAST(GETDATE() AS varchar(11))
       
    if @cmp_id_Pass = 0
		set @cmp_id_Pass=null
      
    IF OBJECT_ID('tempdb..#Temp') IS NOT NULL 
         BEGIN
               DROP TABLE #Temp
         END
	
   IF OBJECT_ID('tempdb..#HR_Email') IS NOT NULL 
      BEGIN
         DROP TABLE #HR_Email
      END

   CREATE table #HR_Email
      ( 
		Row_Id INT IDENTITY(1, 1),
        Cmp_ID NUMERIC(18, 0)
      ) 
    CREATE TABLE #EMAIL_ID
    (
    Work_Email VARCHAR(MAX)
    )
      

	Insert Into #HR_Email (Cmp_ID)
	SELECT Cmp_ID From T0010_COMPANY_MASTER WITH (NOLOCK)

	Declare @HREmail_ID	nvarchar(4000)
	Declare @Cmp_Id as numeric
	Declare @HR_Name as varchar(255)
	Declare @ECount as numeric
	Declare @DAYS_REMINDER as Numeric
	DECLARE @Work_Email as VARCHAR(250)
	DECLARE @Emp_Full_Name AS VARCHAR(MAX)
	DECLARE @email_format AS VARCHAR(MAX)
	DECLARE @Probation_Date AS DATETIME
	DECLARE @Emp_ID as Numeric	
	DECLARE @PROBATION_START_DATE AS DATETIME
	DECLARE @Date_of_Join AS DATETIME
	DECLARE @period AS INT
	DECLARE @Review_type AS VARCHAR(30)
	
	declare Cur_Company cursor for 
	select Cmp_Id from #HR_Email where Cmp_ID=@CMP_ID_PASS order by Cmp_ID 
	open Cur_Company                      
	fetch next from Cur_Company into @Cmp_Id
	while @@fetch_status = 0                    
		begin
			Select @DAYS_REMINDER = Isnull(Setting_Value,0) FROM T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID=@CMP_ID and Setting_Value > 0 and Setting_Name ='Set days to fill Self Assessment Probation Details'
													
		
											
		--SELECT DISTINCT E.Emp_ID,E.Cmp_ID,E.Branch_ID,E.Dept_ID,E.Alpha_Emp_Code,E.Emp_Full_Name,EA.resignation_date,
		--				EA.last_date,EA.exit_id,E.Dept_Name,EA.sup_ack,E.Emp_Left,EA.Clearance_ManagerID,E.Date_Of_Join,
		--				E.Desig_Name,RM.Reason_Name AS [Reason]
		--into #Temp_Exit						
		--FROM T0200_Emp_ExitApplication EA INNER JOIN
		--	  V0080_EMP_MASTER_INCREMENT_GET E ON EA.emp_id = E.Emp_ID INNER JOIN
		--	  T0300_Exit_Clearance_Approval EC ON EC.Emp_ID=EA.emp_id AND EC.Exit_ID=EA.exit_id INNER JOIN
		--	  T0040_Reason_Master RM ON RM.Res_Id=EA.reason
		--WHERE EA.[Status] <> 'R' and E.Cmp_ID =@Cmp_Id and ISNULL(EA.Clearance_ManagerID,'') <> ''
	 --   and (GETDATE() BETWEEN DateAdd(DAY,-@Exit_Reminder_Days,EA.last_date) AND (EA.last_date+1) or GETDATE() >= EA.last_date)
	         	
		SELECT TOP 1 @HREmail_ID = Email_ID, @HR_Name = Emp_Full_Name
		FROM T0011_LOGIN L WITH (NOLOCK) Left Outer Join T0080_EMP_MASTER E WITH (NOLOCK) on L.Emp_ID = E.Emp_ID
		Where L.Cmp_ID=@Cmp_ID AND Is_HR = 1	
		if isnull(@HREmail_ID,'')='' 
			begin
				select @HREmail_ID = (SELECT TOP 1 Email_ID FROM T0011_LOGIN WITH (NOLOCK) where Is_HR = 1)
			end
				--PRINT @HREmail_ID		
		
		CREATE TABLE #Emp_Probation
		 (      
		   Emp_ID numeric ,     
		   Probation_Date DATETIME,
		   Review_type varchar(20)
		 )  		 
		Declare @profile as varchar(50)
		set @profile = ''
		  
		select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = @Cmp_Id
		  
		if isnull(@profile,'') = ''
		  begin
			select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = 0
		  end
		  
		EXEC P_GET_PROBATION_TRAINEE_LIST @Cmp_Id,'Probation','','HomePage'
		
		DECLARE Probation_Details cursor for 
			select EP.Emp_ID,EP.Probation_Date,EM.Emp_Full_Name,EM.Work_Email,EM.Date_Of_Join,Review_type from #Emp_Probation EP INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID=EP.Emp_ID 	
			--where (GETDATE() BETWEEN DateAdd(DAY,-@DAYS_REMINDER,EP.Probation_Date) AND (EP.Probation_Date) or GETDATE() >= EP.Probation_Date)
		open Probation_Details                      
		fetch next from Probation_Details into @Emp_ID,@Probation_Date,@Emp_Full_Name,@Work_Email,@Date_of_Join,@Review_type
		while @@fetch_status = 0                    
			begin	
				IF @Review_type='Quarterly'
					SET @period=3
				ELSE IF @Review_type='Six Monthly'
					SET @period=6
				ELSE	
					SET @period=12
					
				SET @PROBATION_START_DATE=DATEADD(mm,-@period,@Probation_Date)
				
				DECLARE @Body AS VARCHAR(MAX)
				SET @Body = '<html>
								<head>
								</head>
								<body>
									<table width="580" border="0" align="center" cellpadding="0" cellspacing="0">
										<tr>
											<td align="center" valign="bottom">
												<table width="580" border="0" cellspacing="0" cellpadding="0">
													<tr>
														<td width="10" align="left" valign="top" bgcolor="#3D3C4C">
															&nbsp;
														</td>
														<td width="560" align="left" valign="top" bgcolor="#3D3C4C">
															<table width="572" height="56" border="0" cellpadding="0" cellspacing="0">
																<tr>
																	<td width="491" height="37" align="center" valign="bottom" style="padding-bottom: 10px;
																		color: #7FDFFF; font-family: Verdana; font-size: large">
																		Message From Online Payroll
																	</td>
																</tr>
																<tr>
																	<td align="center" style="font-family: Verdana; font-size: 12pt; color: #ffffff;
																		text-decoration: none; padding-bottom: 10px;">
																	</td>
																</tr>
															</table>
														</td>
														<td width="10" align="right" valign="top" bgcolor="#3D3C4C">
															&nbsp;
														</td>
													</tr>
												</table>
											</td>
										</tr>
										<tr>
											<td bgcolor="#4F4E60" style="font-family: arial; text-decoration: none; font-weight: bold;
												width: 509px; height: 26px; color: #7FDFFF; text-align: left; padding: 10px 0px 10px 54px;">
												Fill Self Assessment For Probation 
											</td>
										</tr>
										<tr>
											<td align="left" valign="middle" bgcolor="#4F4E60" style="padding-bottom: 20px;"
												class="style1">
												<table width="473" border="0" align="center" cellpadding="0" cellspacing="0">               
													<tr>
														<td align="left" valign="bottom" bgcolor="#5f6275" align="center" valign="bottom"
															style="padding-bottom: 10px; color: #FFFFFF; font-family: Verdana; font-size: 10pt">
															Dear '+ @Emp_Full_Name +' ,
														</td>
													</tr>
													<tr>
														<td align="left" valign="bottom" bgcolor="#5f6275" align="left" valign="bottom" style="padding-bottom: 10px;
															color: #FFFFFF; font-family: Verdana; font-size: 10pt">
															Your Self Assessment For Probation has been initaited for the period of '+ CONVERT(VARCHAR(15),@PROBATION_START_DATE,103) +' to '+ CONVERT(VARCHAR(15),@Probation_Date,103) +'. 
															Kindly fill the form to make it effective.
														</td>
													</tr>              
												</table>
											</td>
										</tr>
										<tr>
											<td height="27" align="left" valign="middle" bgcolor="#6D7083" style="font-family: Verdana;
												font-size: 8pt; color: #ffffff; text-align: left; text-decoration: none;">
												<div align="left">
													&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Do not reply to this mail, this is a system generated
													mail.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div>
											</td>
										</tr>
									</table>'			
		--SELECT @Body
				
				--EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @Work_Email, @subject = 'Fill Self Assessment Probation Form', @body = @email_format, @body_format = 'HTML',@copy_recipients = @CC_Email
				EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @Work_Email, @subject = 'Fill Self Assessment Probation Form', @body = @email_format, @body_format = 'HTML',@copy_recipients = @CC_Email
			 fetch next from Probation_Details into @Emp_ID,@Probation_Date,@Emp_Full_Name,@Work_Email,@Date_of_JOin,@Review_type
			 end                    
		close Probation_Details                    
		deallocate Probation_Details       
	--PRINT @email_format
		
		 fetch next from Cur_Company into @Cmp_Id
	   end                    
	close Cur_Company                    
	deallocate Cur_Company         
	
End




