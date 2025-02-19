
---09/3/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE  [dbo].[P0060_HRMS_CandidateFinalization_Get1]
	 @Cmp_ID  Numeric (18,0) 
	,@Condition varchar(max)
    ,@status as int    
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	DECLARE  @Query  VARCHAR(6000)
	
	IF @Condition = '-1'
	BEGIN
	 SET @Condition = ' AND 1=1'
	END	
	
	
	if @Cmp_ID<>0
		Begin
			--IF @status=0
				begin				
					set @Query = 'SELECT c.[Resume_ID]
										  ,c.[Resume_Status]
										  ,c.[Cmp_ID]
										  ,c.[Rec_post_Id]
										  ,c.[Branch_id]
										  ,c.[Grd_id]
										  ,c.[Desig_id]
										  ,c.[Dept_id]
										  ,c.[Joining_date]
										  ,c.[Total_CTC]
										  ,c.[ReportingManager_Id]
										  ,c.[SalaryCycle_Id]
										  ,c.[ShiftId]
										  ,c.[EmploymentTypeId]
										  ,c.[BusinessSegment_Id]
										  ,c.[Vertical_Id]
										  ,c.[SubVertical_Id]
										  ,c.[app_full_name]
										  ,c.[Emp_First_Name]
										  ,c.[Emp_Second_Name]
										  ,c.[Emp_Last_Name]
										  ,c.[Initial]
										  ,c.[Gender]
										  ,c.[Job_title]
										  ,c.[Basic_Salay]
										  ,c.[Rec_Post_Code]
										  ,c.[Dept_Name]
										  ,c.[Desig_Name]
										  ,c.[Branch_Name]
										  ,c.[Segment_Name]
										  ,c.[Grd_Name]
										  ,c.[Name]
										  ,c.[SubVertical_Name]
										  ,c.[Vertical_Name]
										  ,c.[Level2_Approval]
										  ,c.[Emp_Full_Name]
										  ,c.[Work_Email]
										  ,c.[Approval_Date]
										  ,c.[PaymentMode]
										  ,c.[BankId]
										  ,c.[AccountNo_Bank]
										  ,c.[Remarks]
										  ,c.[FinalStatus]
										  ,c.[ApprovedBy]
										  ,c.[IsEmployee]
										  ,c.login_id
										  ,c.[Salary_Rule]
										  ,r.[Resume_Code]
										  ,r.HasPancard
										  ,r.PanCardAck_Path
										  ,r.PanCardNo
										  ,r.PanCardAck_No
										  ,r.PanCardProof
										  ,r.Date_Of_Birth
										  ,r.Marital_Status
										  ,r.Present_Loc
										  ,r.Permanent_Loc_ID
										  ,r.Gender
										  ,r.Mobile_No
										  ,r.Present_Street
										  ,r.Present_City
										  ,r.Present_State
										  ,r.Present_Post_Box
										  ,r.FatherName
										  ,r.Permanent_City
										  ,r.Permanent_State
										  ,r.Permanent_Street
										  ,r.Permanentt_Post_Box as Permanent_Post_Box
										  ,r.Home_Tel_no
										  ,r.Primary_email
										  ,h.emp_file_name as photo
										  ,(select top 1 isnull(Employer_Name,'''') from T0090_HRMS_RESUME_EXPERIENCE WITH (NOLOCK) where Resume_Id=c.Resume_ID ) as Employer									
										  ,(select top 1 isnull(GrossSalary,0) from T0090_HRMS_RESUME_EXPERIENCE WITH (NOLOCK) where Resume_Id=c.Resume_ID order by Row_ID desc) as GrossSalary
										  ,(select top 1 isnull(ProfessionalTax,0) from T0090_HRMS_RESUME_EXPERIENCE WITH (NOLOCK) where Resume_Id=c.Resume_ID order by Row_ID desc) as ProfessionalTax
										  ,(select top 1 isnull(Surcharge,0) from T0090_HRMS_RESUME_EXPERIENCE WITH (NOLOCK) where Resume_Id=c.Resume_ID order by Row_ID desc) as Surcharge
										  ,(select top 1 isnull(EducationCess,0) from T0090_HRMS_RESUME_EXPERIENCE WITH (NOLOCK) where Resume_Id=c.Resume_ID order by Row_ID desc) as EducationCess
										  ,(select top 1 isnull(TDS,0) from T0090_HRMS_RESUME_EXPERIENCE WITH (NOLOCK) where Resume_Id=c.Resume_ID order by Row_ID desc) as TDS
										    ,EM.Alpha_Emp_code  as Alpha_Emp_Code
										    ,isnull(gross_salary,0)gross_salary
										    ,isnull(Aadhar_CardNo,'''')Aadhar_CardNo,pm.Privilege_ID,c.Category_ID,C.Type_Of_Opening,c.Customize_column
								FROM      V0060_HRMS_Candidates_Finalization as c
							    LEFT JOIN T0055_Resume_Master as r WITH (NOLOCK) on r.Resume_Id = c.Resume_ID 
							    LEFT JOIN T0090_HRMS_RESUME_HEALTH as h WITH (NOLOCK) on h.Resume_ID = c.Resume_ID
							    left Join T0080_EMP_MASTER Em WITH (NOLOCK) on c.Confirm_emp_id = EM.Emp_id
								LEFT JOIN T0020_PRIVILEGE_MASTER PM WITH (NOLOCK) ON PM.CMP_ID=C.CMP_ID AND Privilege_Name=''EssUser''
							    where  c.Cmp_id=' + cast(@Cmp_ID as varchar(50))
							
							EXEC(@Query + @Condition + 'order by Joining_date asc') 
							print (@Query + @Condition)
				end
		END
END
