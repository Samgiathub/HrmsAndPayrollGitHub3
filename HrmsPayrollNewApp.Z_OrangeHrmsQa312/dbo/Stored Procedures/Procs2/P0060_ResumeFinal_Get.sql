


-- =============================================
-- Author:		Sneha 
-- ALTER date: 8 july 2013
-- Description:	exec P0060_ResumeFinal_Get 0,0,0,'-1',1
-- exec P0060_ResumeFinal_Get 9,0,0,' AND Level2_Approval = 1 and SalaryCycle_Id <> 0',1
--  exec P0060_ResumeFinal_Get 7,0,0,'-1',3
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0060_ResumeFinal_Get]
	@Cmp_ID  Numeric (18,0) 
   ,@rec_post_id Numeric (18,0) 
   ,@resume_ID Numeric (18,0) 
   ,@Process_data varchar(max)
   ,@status as int
AS
BEGIN


SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

DECLARE  @Query  VARCHAR(6000)
	
	IF @Process_data = '-1'
	BEGIN
	SET @Process_data = ' AND 1=1'
	END
	
	if @Cmp_ID=0
		set @Cmp_ID = null
	
	if @Cmp_ID<>0
		begin
			if @status=0
				begin
					set @Query = 'select Job_title,					
										Resume_ID,
										Cmp_ID,
										(select Cmp_Name from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=v0060_RESUME_FINAL.Cmp_ID) As CompanyName,
										Resume_Code,
										rec_post_date,
										Rec_post_Id,
										app_full_name,
										Rec_Post_Code,
										Primary_email,
										Branch_id,
										Branch_Name,
										Desig_id,
										Desig_Name,
										Dept_id,										
										Dept_Name,
										Basic_Salay ,
										BusinessSegment_Id,
										Segment_Name,
										Vertical_Id,
										Vertical_Name,
										SubVertical_Id,
										SubVertical_Name,										
										Approval_Date,
										[BusinessHead]
									  ,[Level2_Approval]
									  ,[SalaryCycle_Id]
									  ,Name
									  ,[ShiftId]
									   ,Shift_Name
									  ,[EmploymentTypeId]
									  ,Type_Name
									  ,[Joining_date]
									  ,ReportingManager_Id
									  ,(select Work_Email from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=ReportingManager_Id) as ReportingMgr_Email
									  ,(select Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=ReportingManager_Id) as Reportingmanager
									  ,Confirm_Emp_id
								from v0060_RESUME_FINAL
								where Resume_Status=3 and Cmp_ID='+cast(@Cmp_ID as varchar(50))
									 --Cmp_ID=isnull(' + cast(@Cmp_ID as varchar(50)) +',Cmp_ID)'				
				End
			else
				begin				
					set @Query = 'select 
									Job_title,
									Resume_ID,
									Cmp_ID,
									(select Cmp_Name from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=v0060_RESUME_FINAL.Cmp_ID) As CompanyName,
									Resume_Code,
									rec_post_date,
									Rec_post_Id,
									app_full_name,
									Rec_Post_Code,
									Primary_email,
									Branch_id,
									Branch_Name,
									Desig_id,
									Desig_Name,
									Dept_id,
									Dept_Name,
									Basic_Salay,
									Approval_Date,
									BusinessSegment_Id,
										Segment_Name,
										Vertical_Id,
										Vertical_Name,
										SubVertical_Id,
										SubVertical_Name,
									[BusinessHead]
								  ,[Level2_Approval]
								  ,[SalaryCycle_Id]
								  ,Name
								  ,[ShiftId]
								  ,Shift_Name
								  ,[EmploymentTypeId] 
								  ,Type_Name
								  ,[Joining_date]
								  ,ReportingManager_Id
								  ,(select Work_Email from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=ReportingManager_Id) as ReportingMgr_Email
								  ,(select Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=ReportingManager_Id) as Reportingmanager
								  ,Confirm_Emp_id
								from v0060_RESUME_FINAL
								where Resume_Status='+CAST (@status as varchar(50))+'and Cmp_ID='+cast(@Cmp_ID as varchar(50))			
				
				end
		End
	Else
		begin
			if @status=0
				begin
					set @Query = 'select Job_title,
										Cmp_ID,		
										(select Cmp_Name from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=v0060_RESUME_FINAL.Cmp_ID) As CompanyName,	
										Resume_ID,
										Resume_Code,
										rec_post_date,
										Rec_post_Id,
										app_full_name,
										Rec_Post_Code,
										Primary_email,
										Branch_id,
										Branch_Name,
										Desig_id,
										Desig_Name,
										Dept_id,										
										Dept_Name,
										Basic_Salay ,
										BusinessSegment_Id,
										Segment_Name,
										Vertical_Id,
										Vertical_Name,
										SubVertical_Id,
										SubVertical_Name,										
										Approval_Date,
										[BusinessHead]
									  ,[Level2_Approval]
									  ,[SalaryCycle_Id]
									  ,Name
									  ,[ShiftId]
									   ,Shift_Name
									  ,[EmploymentTypeId]
									  ,Type_Name
									  ,[Joining_date]
									  ,ReportingManager_Id
									  ,(select Work_Email from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=ReportingManager_Id) as ReportingMgr_Email
									  ,(select Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=ReportingManager_Id) as Reportingmanager
									  ,Confirm_Emp_id
								from v0060_RESUME_FINAL
								where Resume_Status=3 
									 --Cmp_ID=isnull(' + cast(@Cmp_ID as varchar(50)) +',Cmp_ID)'				
				End
			else
				begin				
					set @Query = 'select 
									Job_title,
									Resume_ID,
									Cmp_ID,
									(select Cmp_Name from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=v0060_RESUME_FINAL.Cmp_ID) As CompanyName,
									Resume_Code,
									rec_post_date,
									Rec_post_Id,
									app_full_name,
									Rec_Post_Code,
									Primary_email,
									Branch_id,
									Branch_Name,
									Desig_id,
									Desig_Name,
									Dept_id,
									Dept_Name,
									Basic_Salay,
									Approval_Date,
									BusinessSegment_Id,
										Segment_Name,
										Vertical_Id,
										Vertical_Name,
										SubVertical_Id,
										SubVertical_Name,
									[BusinessHead]
								  ,[Level2_Approval]
								  ,[SalaryCycle_Id]
								  ,Name
								  ,[ShiftId]
								  ,Shift_Name
								  ,[EmploymentTypeId] 
								  ,Type_Name
								  ,[Joining_date]
								  ,ReportingManager_Id
								  ,(select Work_Email from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=ReportingManager_Id) as ReportingMgr_Email
								  ,(select Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=ReportingManager_Id) as Reportingmanager
								  ,Confirm_Emp_id
								from v0060_RESUME_FINAL
								where Resume_Status='+CAST (@status as varchar(50))				
				
				end
		END	
			EXEC(@Query + @Process_data + 'order by Approval_Date desc') 
			print @query
		
END


