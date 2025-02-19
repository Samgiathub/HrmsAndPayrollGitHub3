
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[Appraisal_Initiate_Email_Send]
	@Emp_Id		varchar(max)
	,@emp_Direct_Id	 varchar(max)
	,@Sa_date		datetime	
	,@TranType		char
	,@cmp_id		numeric(18,0)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

    
	CREATE table #DataTbl
	(
		InitiateId  numeric(18,0),
		Cmp_ID  numeric(18,0),
		Emp_Id  numeric(18,0),
		AppraiserId  numeric(18,0),
		SA_Startdate DATETIME,
		SA_Enddate DATETIME,
		SA_SendToRM INT,
		Emp_Email varchar(50),
		Emp_full_Name varchar(100),
		ManagerName  varchar(100),
		CC_Email VARCHAR(50)
	)
	
	DECLARE @email_body varchar(max)
	
	
	
		IF @TranType <> 'D'
			BEGIN
				IF EXISTS(SELECT 1 FROM T0050_HRMS_InitiateAppraisal WITH (NOLOCK) WHERE cast(Emp_Id as varchar) in (select data from dbo.Split(@emp_id,','))  and CAST(emp_id as VARCHAR) NOT IN (select data from dbo.Split(@emp_Direct_Id,',')) and convert(varchar(10),SA_Startdate,105) =convert(varchar(10),@Sa_date,105))
				BEGIN 
					INSERT INTO #DataTbl
					SELECT InitiateId,I.Cmp_ID,I.Emp_Id,AppraiserId,SA_Startdate,SA_Enddate,SA_SendToRM,E.Work_Email,e.Emp_Full_Name,em.Emp_Full_Name,em.Work_Email
					FROM T0050_HRMS_InitiateAppraisal  I WITH (NOLOCK) inner	 JOIN
						 T0080_EMP_MASTER E WITH (NOLOCK) on e.Emp_ID = I.Emp_Id left JOIN
						 T0080_EMP_MASTER EM WITH (NOLOCK) on Em.Emp_ID = e.Emp_Superior
					WHERE CAST(I.Emp_Id as varchar) in (select data from dbo.Split(@emp_id,','))  and CAST(I.emp_id as VARCHAR) not in (select data from dbo.Split(@emp_Direct_Id,',')) and convert(varchar(10),SA_Startdate,105) =convert(varchar(10),@Sa_date,105)
				END
			END
		ELSE 
			BEGIN
				IF EXISTS (SELECT InitiateId,Cmp_ID,Emp_Id,AppraiserId,SA_Startdate,SA_Enddate FROM T0050_HRMS_InitiateAppraisal WITH (NOLOCK) WHERE Emp_Id in (select data from dbo.Split(@emp_Direct_Id,','))  and  convert(varchar(10),SA_Startdate,105) =convert(varchar(10),@Sa_date,105))
					BEGIN
						INSERT INTO #DataTbl
						SELECT InitiateId,I.Cmp_ID,I.Emp_Id,AppraiserId,SA_Startdate,SA_Enddate,SA_SendToRM,EM.Work_Email,e.Emp_Full_Name,em.Emp_Full_Name,''
						FROM T0050_HRMS_InitiateAppraisal  I WITH (NOLOCK) inner	 JOIN
							 T0080_EMP_MASTER E WITH (NOLOCK) on e.Emp_ID = I.Emp_Id left JOIN
							 T0080_EMP_MASTER EM WITH (NOLOCK) on Em.Emp_ID = e.Emp_Superior
						WHERE I.Emp_Id in (select data from dbo.Split(@emp_Direct_Id,','))  and  convert(varchar(10),SA_Startdate,105) =convert(varchar(10),@Sa_date,105)
					END
			END
		
		
	     declare @InitiateId  numeric(18,0)
		 declare @CmpID  numeric(18,0)
		 declare @EmpId  numeric(18,0)
		 declare @AppraiserId  numeric(18,0)
		 declare @SA_Startdate DATETIME
		 declare @SA_Enddate DATETIME
		 declare @SA_SendToRM INT
		 declare @Emp_Email VARCHAR(50)
		 declare @Emp_full_Name VARCHAR(100)
		 declare @ManagerName VARCHAR(100)
		 declare @CC_Email VARCHAR(100)
		 
		 declare @manager_to INT
		 declare @manager_CC INT
	     declare @HR_to INT
		 declare @HR_CC INT
		 declare @ACC_to INT
		 declare @ACC_CC INT
		 declare @OtherEmail VARCHAR(25)
		
		Declare @profile as varchar(50)
		  set @profile = ''
		  
		  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = @Cmp_Id
		  
		  if isnull(@profile,'') = ''
		  begin
		  select @profile = isnull(DB_Mail_Profile_Name,'') from t9999_Reminder_Mail_Profile WITH (NOLOCK) where cmp_id = 0
		  end  
		  
		Declare @subject as varchar(100)   
		declare @typest as int 
		set @typest =0   
		set @manager_to  =0
		set  @manager_CC = 0
		set  @HR_to	  = 0
		set  @HR_CC	  = 0
		set  @ACC_to  = 0
		set @ACC_CC	  = 0
		set  @OtherEmail = 0    
		declare  @finalcc as VARCHAR(max)
		set @finalcc = ''
		
		
		
	IF @TranType = 'I'
		BEGIN
			IF EXISTS (Select IsNUll(Email_Ntf_Sent,0) As Email_Ntf_Sent From dbo.T0040_EMAIL_NOTIFICATION_CONFIG WITH (NOLOCK) Where cmp_id= @cmp_id And EMAIL_NTF_DEF_ID = 30)
				BEGIN
					SELECT @typest =IsNUll(Email_Ntf_Sent,0) ,
					          @manager_to = To_Manager,
							  @manager_CC = Is_Manager_CC,
							  @HR_to	  = To_Hr,
							  @HR_CC	  = Is_HR_CC,
							  @ACC_to	  = To_Account,
							  @ACC_CC	  = Is_Account_CC,
							  @OtherEmail = Other_Email
					FROM dbo.T0040_EMAIL_NOTIFICATION_CONFIG WITH (NOLOCK) Where cmp_id= @cmp_id And EMAIL_NTF_DEF_ID = 30
					
					IF @typest = 1
					BEGIN 
						SELECT @email_body = Email_Signature
						FROM T0010_Email_Format_Setting WITH (NOLOCK)
						WHERE Cmp_ID = @cmp_id And Email_Type ='Self Assessment'
							
						DECLARE cur CURSOR
						FOR
							SELECT * from #DataTbl where Emp_Email <> ''
						OPEN cur
							FETCH NEXT FROM cur into @InitiateId,@CmpID,@EmpId,@AppraiserId,@SA_Startdate,@SA_Enddate,@SA_SendToRM,@Emp_Email,@Emp_full_Name,@ManagerName,@CC_Email
							WHILE @@fetch_status =0
								BEGIN
									SET @email_body  = REPLACE(@email_body,'#Emp_Full_Name#',@Emp_full_Name)
									SET @email_body  = REPLACE(@email_body,'#Enddate#',convert(varchar(10),@SA_Enddate,105))
									SET @email_body  = REPLACE(@email_body,'#Stdate#',convert(varchar(10),@SA_Startdate,105))
									SET @email_body  = REPLACE(@email_body,'#Employee#',case when isnull(@ManagerName,'')='' then '' else @ManagerName end)
								
									SET @subject = 'Self Assessment Form'	
									
									IF @manager_to=1
										BEGIN
											IF @Emp_Email <>''
												SET @Emp_Email = @Emp_Email + ',' + @CC_Email
											ELSE
												SET @Emp_Email = @CC_Email
										END
									IF @manager_CC = 1
										BEGIN
											IF @finalcc <>''
												SET @finalcc = @finalcc + ',' + @CC_Email
											ELSE
												SET @finalcc = @CC_Email
										END
									
									
									--SELECT  @profile,  @Emp_Email,  @subject,  @email_body,  'HTML','',@CC_Email
									EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @Emp_Email, @subject = @subject, @body = @email_body, @body_format = 'HTML',@copy_recipients = @finalcc
									FETCH NEXT FROM cur into @InitiateId,@CmpID,@EmpId,@AppraiserId,@SA_Startdate,@SA_Enddate,@SA_SendToRM,@Emp_Email,@Emp_full_Name,@ManagerName,@CC_Email
								END
						CLOSE cur
						DEALLOCATE cur
					END
				END				
		END
	ELSE IF @TranType = 'U'
		BEGIN
			IF EXISTS (Select IsNUll(Email_Ntf_Sent,0) As Email_Ntf_Sent From dbo.T0040_EMAIL_NOTIFICATION_CONFIG WITH (NOLOCK) Where cmp_id= @cmp_id And EMAIL_NTF_DEF_ID = 79)
				BEGIN
					SELECT @typest =IsNUll(Email_Ntf_Sent,0)  From dbo.T0040_EMAIL_NOTIFICATION_CONFIG WITH (NOLOCK) Where cmp_id= @cmp_id And EMAIL_NTF_DEF_ID = 79
					IF @typest = 1
						BEGIN
							SELECT @email_body = Email_Signature
							FROM T0010_Email_Format_Setting WITH (NOLOCK)
							WHERE Cmp_ID = @cmp_id And Email_Type ='Extended Self Assessment'
							
							DECLARE cur CURSOR
							FOR
								SELECT * from #DataTbl where Emp_Email <> ''
							OPEN cur
								FETCH NEXT FROM cur into @InitiateId,@CmpID,@EmpId,@AppraiserId,@SA_Startdate,@SA_Enddate,@SA_SendToRM,@Emp_Email,@Emp_full_Name,@ManagerName,@CC_Email
								WHILE @@fetch_status =0
									BEGIN 
										SET @email_body  = REPLACE(@email_body,'#Emp_Full_Name#',@Emp_full_Name)
										SET @email_body  = REPLACE(@email_body,'#Enddate#',convert(varchar(10),@SA_Enddate,105))
										SET @email_body  = REPLACE(@email_body,'#Stdate#',convert(varchar(10),@SA_Startdate,105))
										SET @email_body  = REPLACE(@email_body,'#Employee#',case when isnull(@ManagerName,'')='' then '' else @ManagerName end)
									
										Set @subject = 'Timeline Extended For Self Assessment Form'	
										--select  @profile,  @Emp_Email,  @subject,  @email_body,  'HTML',''
										EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @Emp_Email, @subject = @subject, @body = @email_body, @body_format = 'HTML',@copy_recipients = @CC_Email
										FETCH NEXT FROM cur into @InitiateId,@CmpID,@EmpId,@AppraiserId,@SA_Startdate,@SA_Enddate,@SA_SendToRM,@Emp_Email,@Emp_full_Name,@ManagerName,@CC_Email
									END
							CLOSE cur
							DEALLOCATE cur
						END
				END
		END
	ELSE IF @TranType = 'D'
		BEGIN
			IF EXISTS (Select IsNUll(Email_Ntf_Sent,0) As Email_Ntf_Sent From dbo.T0040_EMAIL_NOTIFICATION_CONFIG WITH (NOLOCK) Where cmp_id= @cmp_id And EMAIL_NTF_DEF_ID = 38)
				BEGIN
					SELECT @typest =IsNUll(Email_Ntf_Sent,0)  From dbo.T0040_EMAIL_NOTIFICATION_CONFIG WITH (NOLOCK) Where cmp_id= @cmp_id And EMAIL_NTF_DEF_ID = 38
					IF @typest = 1
						BEGIN
							SELECT @email_body = Email_Signature
							FROM T0010_Email_Format_Setting WITH (NOLOCK)
							WHERE Cmp_ID = @cmp_id And Email_Type ='Direct Assessment Approved'
							
							DECLARE cur CURSOR
							FOR
								SELECT * from #DataTbl where Emp_Email <> ''
							OPEN cur
								FETCH NEXT FROM cur into @InitiateId,@CmpID,@EmpId,@AppraiserId,@SA_Startdate,@SA_Enddate,@SA_SendToRM,@Emp_Email,@Emp_full_Name,@ManagerName
								WHILE @@fetch_status =0
									BEGIN 
										SET @email_body  = REPLACE(@email_body,'#Emp_Full_Name#',case when isnull(@ManagerName,'')='' then '' else @ManagerName end)
										SET @email_body  = REPLACE(@email_body,'#Employee#',@Emp_full_Name)
										SET @email_body  = REPLACE(@email_body,'#Enddate#',convert(varchar(10),@SA_Enddate,105))
										SET @email_body  = REPLACE(@email_body,'#Stdate#',convert(varchar(10),@SA_Startdate,105))
										
									
										Set @subject = 'Direct Assessment Approved'	
										--select  @profile,  @Emp_Email,  @subject,  @email_body,  'HTML',''
										EXEC msdb.dbo.sp_send_dbmail @profile_name = @profile, @recipients = @Emp_Email, @subject = @subject, @body = @email_body, @body_format = 'HTML',@copy_recipients = ''
										FETCH NEXT FROM cur into @InitiateId,@CmpID,@EmpId,@AppraiserId,@SA_Startdate,@SA_Enddate,@SA_SendToRM,@Emp_Email,@Emp_full_Name,@ManagerName
									END
							CLOSE cur
							DEALLOCATE cur
						END
				END
		END
	--SELECT * FROM #DataTbl
	
	DROP TABLE #DataTbl
END
