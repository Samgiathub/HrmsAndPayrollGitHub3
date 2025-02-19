

-- =============================================
-- Author:		MUKTI CHAUHAN
-- Create date: 09-11-2017
-- Description:	SET DESIGN FOR TABLE OF MULTIPLE RECORDS IN EMAIL TEMPLATE
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P_GET_EMAIL_TEMPLATE]
     @CMP_ID        numeric,
     @TEMPLATE_TYPE varchar(MAX),     
     @TRAN_ID varchar(250),
     @Constraint varchar(MAX)=''
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	DECLARE @email_format as VARCHAR(MAX)
	DECLARE @HTML_TABLE VARCHAR(MAX)
	DECLARE @emp_code VARCHAR(200)
	DECLARE @emp_name VARCHAR(500)	
	CREATE TABLE #TEMPLATE_DETAILS
	(					
		EMAIL_FORMAT	Varchar(MAX)					
	)				
	
	if @TEMPLATE_TYPE ='Asset Approval'
		BEGIN		
			DECLARE @Asset_Name VARCHAR(100)
			DECLARE @Asset_Code VARCHAR(100)
			DECLARE @Brand_name VARCHAR(100)
			DECLARE @Model_Name VARCHAR(100)
			DECLARE @Serial_NO VARCHAR(100)
			DECLARE @Allocation_Date VARCHAR(25)
			DECLARE @Return_date VARCHAR(25)
			DECLARE @Approval_status VARCHAR(15)
			DECLARE @Asset_Status VARCHAR(15)
		
 			select @email_format=Email_Signature from T0010_Email_Format_Setting WITH (NOLOCK) where Cmp_ID=@CMP_ID and Email_Type = 'Asset Approval'
			
			set @HTML_TABLE='<tr>
								<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: Center; text-decoration: none;
									width: 80px;#template-background-color#;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
									Asset
								</td>
								<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: Center; text-decoration: none;
									width: 100px;#template-background-color#;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
									Asset Code
								</td>
								<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: center;  text-decoration: none;
									width: 100px;#template-background-color#;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
									Brand
								</td>
								<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: center; text-decoration: none;
									width: 100px;#template-background-color#;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
									Model
								</td>
								<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: center; text-decoration: none;
									width: 100px;#template-background-color#;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
									Serial No
								</td>
								<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: center; text-decoration: none;
									width: 100px;#template-background-color#;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
									Asset Status
								</td>
								<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: center; text-decoration: none;
									width: 100px;#template-background-color#;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
									Allocation Date
								</td>
								<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: center; text-decoration: none; 
									width: 100px;#template-background-color#;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
									Return Date
								</td>
								<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: center; text-decoration: none; 
									width: 100px;#template-background-color#;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
									Status
								</td>
							</tr>'
		

		DECLARE EMAIL_FORMAT_DETAILS CURSOR FOR
		select Asset_Name,Asset_Code,Brand_name,Model_Name,Serial_NO,case when Asset_status='W' then 'Working' else 'Damage' end as Asset_status,Allocation_Date,Return_date,case when Approval_status='A' then 'Approved' else 'Rejected' end as Approval_status from V0120_Asset_Approval  where Asset_Approval_ID=@TRAN_ID and Cmp_ID =@CMP_ID order by Asset_Name
		OPEN EMAIL_FORMAT_DETAILS
		FETCH NEXT FROM EMAIL_FORMAT_DETAILS into @Asset_Name,@Asset_Code,@Brand_name,@Model_Name,@Serial_NO,@Asset_Status,@Allocation_Date,@Return_date,@Approval_status
		while @@fetch_status = 0
			Begin	
				IF ISNULL(@Asset_Name,'') <>''
					BEGIN
						set @HTML_TABLE = @HTML_TABLE + '<tr>
											<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
												' + @Asset_Name + '
											</td>
											<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
												' + @Asset_Code + '
											</td>
											<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
												' + @Brand_name + '
											</td>											
											<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
												' + @Model_Name + '
											</td>
											<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
												' + @Serial_NO + '
											</td>
											<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
												' + @Asset_Status + '
											</td>
											<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
												' + @Allocation_Date + '
											</td>
											<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
												' + @Return_date + '
											</td>
										    <td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
												' + @Approval_status + '
											</td>
									   </tr>'						
					END				
				FETCH NEXT FROM EMAIL_FORMAT_DETAILS into @Asset_Name,@Asset_Code,@Brand_name,@Model_Name,@Serial_NO,@Asset_Status,@Allocation_Date,@Return_date,@Approval_status
			End
		close EMAIL_FORMAT_DETAILS 
		deallocate EMAIL_FORMAT_DETAILS
		
		SET @email_format = REPLACE(@email_format, '#AssetDetail#', @HTML_TABLE)
		END
	else if @TEMPLATE_TYPE in('Resume Screening','Resume Screened')
		BEGIN
			DECLARE @Candidate_Name VARCHAR(500)
			DECLARE @Job_Title VARCHAR(200)
			
 			select @email_format=Email_Signature from T0010_Email_Format_Setting WITH (NOLOCK) where Cmp_ID=@CMP_ID and Email_Type = 'Resume Screening'
			
			set @HTML_TABLE='<tr>
								<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: Center; text-decoration: none;
									width: 80px;#template-background-color#;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
									Candidate Name
								</td>
								<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: Center; text-decoration: none;
									width: 100px;#template-background-color#;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
									Job Title
								</td>								
							</tr>'
		

		DECLARE EMAIL_FORMAT_DETAILS CURSOR FOR
		--select Asset_Name,Asset_Code,Brand_name,Model_Name,Serial_NO,case when Asset_status='W' then 'Working' else 'Damage' end as Asset_status,Allocation_Date,Return_date,case when Approval_status='A' then 'Approved' else 'Rejected' end as Approval_status from V0120_Asset_Approval  where Asset_Approval_ID=@TRAN_ID and Cmp_ID =@CMP_ID order by Asset_Name
		select (Emp_First_Name + ' ' + Emp_Last_Name) as 'Candidate_Name',(Rec_Post_Code + '-' + Job_title) as 'Job_Title' 
		from V0055_HRMS_RESUME_MASTER where  Cmp_ID =@CMP_ID and resume_id in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (@TRAN_ID,','))
		OPEN EMAIL_FORMAT_DETAILS
		FETCH NEXT FROM EMAIL_FORMAT_DETAILS into @Candidate_Name,@Job_Title
		while @@fetch_status = 0
			Begin	
				IF ISNULL(@Candidate_Name,'') <>''
					BEGIN
						set @HTML_TABLE = @HTML_TABLE + '<tr>
											<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
												' + @Candidate_Name + '
											</td>
											<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
												' + @Job_Title + '
											</td>											
									   </tr>'						
					END				
				FETCH NEXT FROM EMAIL_FORMAT_DETAILS into @Candidate_Name,@Job_Title
			End
		close EMAIL_FORMAT_DETAILS 
		deallocate EMAIL_FORMAT_DETAILS
		
		SET @email_format = REPLACE(@email_format, '#Resume#', @HTML_TABLE)
		END
	else if @TEMPLATE_TYPE ='Training In-Out'
		BEGIN
			DECLARE @Alpha_Emp_Code VARCHAR(50)
			DECLARE @Emp_Full_Name VARCHAR(500)
			DECLARE @For_date VARCHAR(20)
			DECLARE @In_date VARCHAR(20)
			DECLARE @In_Time VARCHAR(20)
			DECLARE @Out_Time VARCHAR(20)
			
 			select @email_format=Email_Signature from T0010_Email_Format_Setting WITH (NOLOCK) where Cmp_ID=@CMP_ID and Email_Type = 'Training In-Out'
			
			set @HTML_TABLE='<tr>
								<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: Center; text-decoration: none;
									width: 80px;#template-background-color#;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
									Employee Code
								</td>
								<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: Center; text-decoration: none;
									width: 100px;#template-background-color#;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
									Employee Name
								</td>								
								<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: Center; text-decoration: none;
									width: 100px;#template-background-color#;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
									In Date
								</td>		
								<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: Center; text-decoration: none;
									width: 100px;#template-background-color#;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
									 In Time
								</td>	
								<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: Center; text-decoration: none;
									width: 100px;#template-background-color#;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
									 Out Time
								</td>	
							</tr>'
		

		DECLARE EMAIL_FORMAT_DETAILS CURSOR FOR
		--select Asset_Name,Asset_Code,Brand_name,Model_Name,Serial_NO,case when Asset_status='W' then 'Working' else 'Damage' end as Asset_status,Allocation_Date,Return_date,case when Approval_status='A' then 'Approved' else 'Rejected' end as Approval_status from V0120_Asset_Approval  where Asset_Approval_ID=@TRAN_ID and Cmp_ID =@CMP_ID order by Asset_Name
		select em.Alpha_Emp_Code,em.Emp_Full_Name,CONVERT(VARCHAR(15),TI.For_date,103)as For_date,LTRIM(RIGHT(CONVERT(VARCHAR(20),TI.In_Time, 100), 7))as In_Time,LTRIM(RIGHT(CONVERT(VARCHAR(20),TI.Out_Time, 100), 7)) as Out_Time
		from T0150_EMP_Training_INOUT_RECORD TI WITH (NOLOCK)
		inner join T0080_EMP_MASTER em WITH (NOLOCK) on TI.emp_id=em.Emp_ID
		where TI.Cmp_ID =@CMP_ID and TI.Training_Apr_Id=@TRAN_ID and em.Emp_ID=@Constraint --and Tran_Id in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (@TRAN_ID,',') where DATA <> '')
		OPEN EMAIL_FORMAT_DETAILS
		FETCH NEXT FROM EMAIL_FORMAT_DETAILS into @Alpha_Emp_Code,@Emp_Full_Name,@In_date,@In_Time,@Out_Time
		while @@fetch_status = 0
			Begin	
				IF ISNULL(@Alpha_Emp_Code,'') <>''
					BEGIN
						set @HTML_TABLE = @HTML_TABLE + '<tr>
											<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
												' + @Alpha_Emp_Code + '
											</td>
											<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
												' + @Emp_Full_Name + '
											</td>											
											<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
												' + @In_date + '
											</td>
											<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
												' + @In_Time + '
											</td>
											<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
												' + @Out_Time + '
											</td>
									   </tr>'						
					END				
				FETCH NEXT FROM EMAIL_FORMAT_DETAILS into @Alpha_Emp_Code,@Emp_Full_Name,@In_date,@In_Time,@Out_Time
			End
		close EMAIL_FORMAT_DETAILS 
		deallocate EMAIL_FORMAT_DETAILS
		
		SET @email_format = REPLACE(@email_format, '#Training_Details#', @HTML_TABLE)
		END	
	else if @TEMPLATE_TYPE ='Training Reminder'
		BEGIN
			DECLARE @from_Date VARCHAR(20)
			DECLARE @to_date VARCHAR(20)			
			DECLARE @From_Time VARCHAR(20)
			DECLARE @To_Time VARCHAR(20)
			DECLARE @days VARCHAR(20)
			DECLARE @Hour VARCHAR(20)
			DECLARE @DayDuration VARCHAR(20)
			
 			select @email_format=Email_Signature from T0010_Email_Format_Setting WITH (NOLOCK) where Cmp_ID=@CMP_ID and Email_Type = 'Training Reminder'
			
			set @HTML_TABLE='<tr>
								<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: Center; text-decoration: none;
									width: 80px;border-top: 1px solid #b1b1b1;border-left: 1px solid #b1b1b1;#template-background-color#;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
									From Date
								</td>
								<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: Center; text-decoration: none;
									width: 100px;border-top: 1px solid #b1b1b1;border-left: 1px solid #b1b1b1;#template-background-color#;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
									To Date
								</td>								
								<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: Center; text-decoration: none;
									width: 100px;border-top: 1px solid #b1b1b1;border-left: 1px solid #b1b1b1;#template-background-color#;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
									From Time
								</td>		
								<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: Center; text-decoration: none;
									width: 100px;border-top: 1px solid #b1b1b1;border-left: 1px solid #b1b1b1;#template-background-color#;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
									 To Time
								</td>	
								<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: Center; text-decoration: none;
									width: 100px;border-top: 1px solid #b1b1b1;border-left: 1px solid #b1b1b1;#template-background-color#;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
									 Days
								</td>	
								<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: Center; text-decoration: none;
									width: 100px;border-top: 1px solid #b1b1b1;border-left: 1px solid #b1b1b1;#template-background-color#;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
									 Hour
								</td>	
								<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: Center; text-decoration: none;
									width: 100px;border-top: 1px solid #b1b1b1;border-left: 1px solid #b1b1b1;#template-background-color#;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
									 Day Duration
								</td>	
							</tr>'
		

		DECLARE EMAIL_FORMAT_DETAILS CURSOR FOR
		--select Asset_Name,Asset_Code,Brand_name,Model_Name,Serial_NO,case when Asset_status='W' then 'Working' else 'Damage' end as Asset_status,Allocation_Date,Return_date,case when Approval_status='A' then 'Approved' else 'Rejected' end as Approval_status from V0120_Asset_Approval  where Asset_Approval_ID=@TRAN_ID and Cmp_ID =@CMP_ID order by Asset_Name
		select convert(varchar,From_date,103) as from_Date,convert(varchar,To_date,103) as to_date,From_Time,To_Time,datediff(d,from_date,to_date) + 1 as days,REPLACE(CONVERT(varchar(5),(CONVERT(DATETIME,To_Time) - CONVERT(DATETIME,From_Time)),114),':','.') as Hour,CASE WHEN (CONVERT(varchar(5),(CONVERT(DATETIME,To_Time) - CONVERT(DATETIME,From_Time)),114)) > '04:00' THEN 'Full Day' ELSE 'Half Day' END AS DayDuration 
		from T0120_HRMS_TRAINING_SCHEDULE WITH (NOLOCK) where Cmp_ID =@CMP_ID and Training_App_id = @TRAN_ID
		OPEN EMAIL_FORMAT_DETAILS
		FETCH NEXT FROM EMAIL_FORMAT_DETAILS into @from_Date,@to_date,@From_Time,@To_Time,@days,@Hour,@DayDuration
		while @@fetch_status = 0
			Begin	
				IF ISNULL(@from_Date,'') <>''
					BEGIN
						set @HTML_TABLE = @HTML_TABLE + '<tr>
											<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;#template-color#;border-top: 1px solid #b1b1b1;border-left: 1px solid #b1b1b1;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
												' + @from_Date + '
											</td>
											<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
												' + @to_date + '
											</td>											
											<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
												' + @From_Time + '
											</td>
											<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
												' + @To_Time + '
											</td>
											<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
												' + @days + '
											</td>
											<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
												' + @Hour + '
											</td>
											<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
												' + @DayDuration + '
											</td>
									   </tr>'						
					END				
				FETCH NEXT FROM EMAIL_FORMAT_DETAILS into @from_Date,@to_date,@From_Time,@To_Time,@days,@Hour,@DayDuration
			End
		close EMAIL_FORMAT_DETAILS 
		deallocate EMAIL_FORMAT_DETAILS
		
		SET @email_format = REPLACE(@email_format, '#TimeScheduleList#', @HTML_TABLE)
		END	
	else if @TEMPLATE_TYPE ='Training Reminder Employee List'
		BEGIN
			select @email_format=Email_Signature from T0010_Email_Format_Setting WITH (NOLOCK) where Cmp_ID=@CMP_ID and Email_Type = 'Training Reminder'
			
			set @HTML_TABLE='<tr>
								<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: Center; text-decoration: none;
									width: 80px;#template-background-color#;#template-color#;border-top: 1px solid #b1b1b1;border-left: 1px solid #b1b1b1;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
									Employee Code
								</td>
								<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: Center; text-decoration: none;
									width: 100px;#template-background-color#;#template-color#;border-top: 1px solid #b1b1b1;border-left: 1px solid #b1b1b1;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
									Employee Name
								</td>
							</tr>'
		

		DECLARE EMAIL_FORMAT_DETAILS CURSOR FOR
		select Alpha_Emp_Code,Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID =@CMP_ID and Emp_ID in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (@TRAN_ID,',') where DATA <> '')
		OPEN EMAIL_FORMAT_DETAILS
		FETCH NEXT FROM EMAIL_FORMAT_DETAILS into @Alpha_Emp_Code,@Emp_Full_Name
		while @@fetch_status = 0
			Begin	
				IF ISNULL(@Alpha_Emp_Code,'') <>''
					BEGIN
						set @HTML_TABLE = @HTML_TABLE + '<tr>
											<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;#template-color#;border-left: 1px solid #b1b1b1;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
												' + @Alpha_Emp_Code + '
											</td>
											<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
												' + @Emp_Full_Name + '
											</td>																						
									   </tr>'						
					END				
				FETCH NEXT FROM EMAIL_FORMAT_DETAILS into @Alpha_Emp_Code,@Emp_Full_Name
			End
		close EMAIL_FORMAT_DETAILS 
		deallocate EMAIL_FORMAT_DETAILS
		
		SET @email_format = REPLACE(@email_format, '#empList#', @HTML_TABLE)
		END	
	else if @TEMPLATE_TYPE ='PerformanceAssessment Allocation'
		BEGIN
			DECLARE @Sr_No VARCHAR(20)			
			DECLARE @Desig_Name VARCHAR(200)			
			DECLARE @Overall_Score numeric(18,2)
			DECLARE @Achievement_Level VARCHAR(50)			
						
 			select @email_format=Email_Signature from T0010_Email_Format_Setting WITH (NOLOCK) where Cmp_ID=@CMP_ID and Email_Type = 'PerformanceAssessment Allocation'
			PRINT @email_format
			set @HTML_TABLE='<tr>
								<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: Center; text-decoration: none;
									width: 80px;#template-background-color#;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
									Sr No
								</td>
								<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: Center; text-decoration: none;
									width: 100px;#template-background-color#;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
									Employee Code
								</td>
								<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: Center; text-decoration: none;
									width: 100px;#template-background-color#;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
									Employee Name
								</td>
								<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: Center; text-decoration: none;
									width: 100px;#template-background-color#;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
									Designation
								</td>
								<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: Center; text-decoration: none;
									width: 100px;#template-background-color#;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
									Score
								</td>
								<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 10pt;text-align: Center; text-decoration: none;
									width: 100px;#template-background-color#;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
									Rating
								</td>
							</tr>'
		DECLARE EMAIL_FORMAT_DETAILS CURSOR FOR
		--select Alpha_Emp_Code,Emp_Full_Name from T0080_EMP_MASTER where Emp_ID in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (@TRAN_ID,',') where DATA <> '')
		--select Dept_Name,EmpName,case when Noc_Status='A' THEN 'Approve' when Noc_Status='R' then 'Reject' else 'Pending' end as Noc_Status from V0300_NOC_Approval where cmp_id = @CMP_ID  and  A_Emp_id = @TRAN_ID and Effective_Date <= GETDATE() and Noc_Status <> 'P'
		select ROW_NUMBER() over (order by Alpha_Emp_Code) as 'Sr_No',Alpha_Emp_Code,Emp_Full_Name,
		d.Desig_Name,h.Overall_Score, ISNULL(a.Achievement_Level,'') from T0080_EMP_MASTER e WITH (NOLOCK)
		left join  T0095_INCREMENT as i WITH (NOLOCK) on i.Emp_ID=e.Emp_ID 
		left join T0040_DESIGNATION_MASTER as d WITH (NOLOCK) on d.Desig_ID=i.Desig_Id 
		left join T0050_HRMS_InitiateAppraisal as h WITH (NOLOCK) on h.Emp_Id=e.Emp_ID 
		left join T0040_HRMS_RangeMaster as r WITH (NOLOCK) on r.Range_ID=h.Achivement_Id 
		left join T0040_Achievement_Master as a WITH (NOLOCK) on a.AchievementId = r.Range_AchievementId 
		where e.Emp_ID in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (@TRAN_ID,',') where DATA <> '')
		and DATEPART(YYYY,h.SA_Startdate)= @Constraint
		and i.Increment_ID=(Select MAX(Increment_ID)  from T0095_INCREMENT WITH (NOLOCK) where Emp_ID = e.Emp_ID)
		OPEN EMAIL_FORMAT_DETAILS
		FETCH NEXT FROM EMAIL_FORMAT_DETAILS into @Sr_No,@Emp_Code,@Emp_Name,@Desig_Name,@Overall_Score,@Achievement_Level
		while @@fetch_status = 0
			Begin	
				IF ISNULL(@Emp_Code,'') <>''
					BEGIN
					--PRINT @Achievement_Level
						set @HTML_TABLE = @HTML_TABLE + '<tr>
											<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
												' + @Sr_No + '
											</td>
											<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
												' + @Emp_Code + '
											</td>																						
											<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
												' + @Emp_Name + '
											</td>			
											<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
												' + @Desig_Name + '
											</td>	
											<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
												' + cast(@Overall_Score as VARCHAR(50)) + '
											</td>	
											<td style=''font-family: Open Sans, Helvetica, Arial, sans-serif; font-size: 12px;text-align: center; text-decoration: none;#template-color#;border-right:1px solid #b1b1b1;border-bottom:1px solid #b1b1b1''>
												' + @Achievement_Level + '
											</td>	
									   </tr>'						
					END				
				FETCH NEXT FROM EMAIL_FORMAT_DETAILS into @Sr_No,@Emp_Code,@Emp_Name,@Desig_Name,@Overall_Score,@Achievement_Level
			End
		close EMAIL_FORMAT_DETAILS 
		deallocate EMAIL_FORMAT_DETAILS
		PRINT @HTML_TABLE
		SET @email_format = REPLACE(@email_format, '#PerformanceAssessment Allocation#', @HTML_TABLE)
		END		
		
		--set default color if hidden template color field not exist(start)
		CREATE TABLE #DEFAULT_PROP
		(
			PROP_NAME	VARCHAR(256),
			PROP_VALUE  VARCHAR(256)
		)
		
		INSERT INTO #DEFAULT_PROP VALUES('template-background-color', '#dcdcdc');
		INSERT INTO #DEFAULT_PROP VALUES('template-color', 'black');
		--set default color if hidden template color field not exist(end)
		
		DECLARE @COUNT INT
		DECLARE @PROP VARCHAR(256)
		DECLARE @PROP_VALUE VARCHAR(256)
		SET @COUNT  = 10;
		WHILE (CHARINDEX('#template-',@HTML_TABLE) > 0)
			BEGIN 
				SET @PROP = SUBSTRING(@HTML_TABLE, CHARINDEX('#template-',@HTML_TABLE)+1, LEN(@HTML_TABLE))				
				SET @PROP = SUBSTRING(@PROP, 0, CHARINDEX('#',@PROP))				
				SET @PROP_VALUE = dbo.fn_getEmailTemplateProperty(@email_format, @PROP)		
				IF ISNULL(@PROP_VALUE,'') = ''
					SELECT @PROP_VALUE = Prop_Value From #DEFAULT_PROP Where PROP_NAME = @PROP					
				SET @PROP_VALUE = REPLACE(@PROP,'template-','') + ':'  +  @PROP_VALUE
				--SET @email_format = replace(@email_format, '#' + @PROP +'#', @PROP_VALUE)
				SET @HTML_TABLE = replace(@HTML_TABLE, '#' + @PROP +'#', @PROP_VALUE)
				SET @COUNT = @COUNT - 1;
				if @COUNT < 0
					BREAK;
			END
		
			declare @template_background_color varchar(256)
			set @template_background_color = 'background-color:' +  dbo.fn_getEmailTemplateProperty(@email_format, '@template-background-color')
			declare @template_color varchar(256)
			set @template_color = 'color:' + dbo.fn_getEmailTemplateProperty(@email_format, '@template-color')

		INSERT INTO #TEMPLATE_DETAILS
		VALUES (@HTML_TABLE)

		select * from #TEMPLATE_DETAILS

