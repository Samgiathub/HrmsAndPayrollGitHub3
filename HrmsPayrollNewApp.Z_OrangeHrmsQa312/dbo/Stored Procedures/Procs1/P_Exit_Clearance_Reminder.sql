

-- =============================================
-- Author:		<Mukti>
-- Create date: <06-08-2018>
-- Description:	<Send Email Reminder to Managers of Cost Center>
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P_Exit_Clearance_Reminder]
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
	Declare @Exit_Reminder_Days as Numeric
	DECLARE @EMP_CODE as VARCHAR(250)
	DECLARE @EMP_NAME AS VARCHAR(500)
	DECLARE @DEPARTMENT AS VARCHAR(500)
	DECLARE @DESIGNATION AS VARCHAR(500)
	DECLARE @DATE_OF_JOINING AS VARCHAR(50)
	DECLARE @DATE_OF_RESIGNATION AS VARCHAR(50)
	DECLARE @LAST_WORKING_DATE AS VARCHAR(50)
	DECLARE @REASON_FOR_RESIGNATION AS VARCHAR(MAX)
	DECLARE @email_format AS VARCHAR(MAX)
	DECLARE @Clearance_Managers AS VARCHAR(MAX)
	DECLARE @Manager_Email_ID as VARCHAR(MAX)	
	
	declare Cur_Company cursor for 
	select Cmp_Id from #HR_Email where Cmp_ID=@CMP_ID_PASS order by Cmp_ID 
	open Cur_Company                      
	fetch next from Cur_Company into @Cmp_Id
	while @@fetch_status = 0                    
		begin
			Select @Exit_Reminder_Days = Isnull(Setting_Value,0) From T0040_SETTING WITH (NOLOCK) Where Cmp_ID = @Cmp_Id and Setting_Name ='Reminder Days for Exit Clearance Cost Center Wise'   				
			
			select @email_format=Email_Signature from T0010_Email_Format_Setting WITH (NOLOCK) where Cmp_ID=@Cmp_Id and Email_Type = 'Clearance Approval'
			--select Email_Signature from T0010_Email_Format_Setting where Cmp_ID=55 and Email_Type = 'Clearance Approval'
			
		SELECT DISTINCT E.Emp_ID,E.Cmp_ID,E.Branch_ID,E.Dept_ID,E.Alpha_Emp_Code,E.Emp_Full_Name,EA.resignation_date,
						EA.last_date,EA.exit_id,E.Dept_Name,EA.sup_ack,E.Emp_Left,EA.Clearance_ManagerID,E.Date_Of_Join,
						E.Desig_Name,RM.Reason_Name AS [Reason]
		into #Temp_Exit						
		FROM T0200_Emp_ExitApplication EA WITH (NOLOCK) INNER JOIN
			  V0080_EMP_MASTER_INCREMENT_GET E ON EA.emp_id = E.Emp_ID INNER JOIN
			  T0300_Exit_Clearance_Approval EC WITH (NOLOCK) ON EC.Emp_ID=EA.emp_id AND EC.Exit_ID=EA.exit_id INNER JOIN
			  T0040_Reason_Master RM WITH (NOLOCK) ON RM.Res_Id=EA.reason
		WHERE EA.[Status] <> 'R' and E.Cmp_ID =@Cmp_Id and ISNULL(EA.Clearance_ManagerID,'') <> ''
	    and (GETDATE() BETWEEN DateAdd(DAY,-@Exit_Reminder_Days,EA.last_date) AND (EA.last_date+1) or GETDATE() >= EA.last_date)
	    
		select * from #Temp_Exit
		Declare @profile as varchar(50)
		set @profile = ''
		  
		select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = @Cmp_Id
		  
		if isnull(@profile,'') = ''
		  begin
			select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = 0
		  end
       	PRINT @profile
		SELECT TOP 1 @HREmail_ID = Email_ID, @HR_Name = Emp_Full_Name
		FROM T0011_LOGIN L WITH (NOLOCK) Left Outer Join T0080_EMP_MASTER E WITH (NOLOCK) on L.Emp_ID = E.Emp_ID
		Where L.Cmp_ID=@Cmp_ID AND Is_HR = 1	
		if isnull(@HREmail_ID,'')='' 
			begin
				select @HREmail_ID = (SELECT TOP 1 Email_ID FROM T0011_LOGIN WITH (NOLOCK) where Is_HR = 1)
			end
				--PRINT @HREmail_ID			  
		DECLARE Clearance_Details cursor for 
		select Alpha_Emp_Code,Emp_Full_Name,Dept_Name,Desig_Name,Date_Of_Join,resignation_date,last_date,reason,Clearance_ManagerID from #Temp_Exit --where emp_id=2835
		open Clearance_Details                      
		fetch next from Clearance_Details into @EMP_CODE,@EMP_NAME,@DEPARTMENT,@DESIGNATION,@DATE_OF_JOINING,@DATE_OF_RESIGNATION,@LAST_WORKING_DATE,@REASON_FOR_RESIGNATION,@Clearance_Managers
		while @@fetch_status = 0                    
			begin
				set @Manager_Email_ID=''
				--PRINT @Clearance_Managers
				INSERT INTO #EMAIL_ID
				select Work_Email from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID in ((select data from dbo.Split(@Clearance_Managers,'#')))
				order by Emp_ID desc
				--select * from #email_id
				SELECT @Manager_Email_ID = COALESCE(@Manager_Email_ID + ';', '')+ CAST(Work_Email AS VARCHAR(100)) from #EMAIL_ID 
				
				SET @email_format = REPLACE(@email_format, '#EmployeeCode#', @EMP_CODE)
				SET @email_format = REPLACE(@email_format, '#EmployeeName#', @EMP_NAME)
				SET @email_format = REPLACE(@email_format, '#Department#', @DEPARTMENT)
				SET @email_format = REPLACE(@email_format, '#Designation#', @DESIGNATION)
				SET @email_format = REPLACE(@email_format, '#DateofJoining#', Convert(nvarchar(11),@DATE_OF_JOINING,113))
				SET @email_format = REPLACE(@email_format, '#DateofResignation#', Convert(nvarchar(11),@DATE_OF_RESIGNATION,113))
				SET @email_format = REPLACE(@email_format, '#LastWorkingDate#', Convert(nvarchar(11),@LAST_WORKING_DATE,113))
				SET @email_format = REPLACE(@email_format, '#ReasonforResignation#', @REASON_FOR_RESIGNATION)
				SET @email_format = REPLACE(@email_format, '#ExitStatus#', 'Pending')
				SET @email_format = REPLACE(@email_format, '#Signature#', '')
				
				
				set @Manager_Email_ID=  right (@Manager_Email_ID, len (@Manager_Email_ID)-1)
				print @Manager_Email_ID
				EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @Manager_Email_ID, @subject = 'Clearance Approval', @body = @email_format, @body_format = 'HTML',@copy_recipients = @CC_Email
				
			 fetch next from Clearance_Details into @EMP_CODE,@EMP_NAME,@DEPARTMENT,@DESIGNATION,@DATE_OF_JOINING,@DATE_OF_RESIGNATION,@LAST_WORKING_DATE,@REASON_FOR_RESIGNATION,@Clearance_Managers
			 end                    
		close Clearance_Details                    
		deallocate Clearance_Details       
	--PRINT @email_format
		
		 fetch next from Cur_Company into @Cmp_Id
	   end                    
	close Cur_Company                    
	deallocate Cur_Company         
	
End




