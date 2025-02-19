



CREATE VIEW [dbo].[V0055_View_All_Details]
AS
select distinct RM.Cmp_id,VR.App_Full_name,VR.Acceptance_Date,VR.Approval_Date,VR.Rec_Post_Code as Job_Code,RM.Rec_Post_Id,VR.Resume_ID,VR.Assigned_Cmpid,VR.Basic_Salay
,dbo.Get_Age_CountDMY(RM.Date_Of_Birth,GETDATE(),'YM') as Age,RM.Mobile_No,case when RM.Gender='M' then 'Male' when RM.Gender='F' then 'Female' end as Gender
,VR.Primary_email,
--RM.Total_Exp as Experience_Detail,
HRM.Experience,RM.Resume_Name,HRM.Location,case when HRM.Posted_status='1' then 'Approve' when HRM.Posted_status='0' then 'Pending' else 'Reject' end as Status,HRM.Posted_status as Resume_Status
,VR.Resume_Code,VR.Branch_Name,VR.BusinessHead,VR.BusinessSegment_Id,VR.Desig_Name
,VR.Expr1,VR.Grd_Name,VR.Job_title,VR.Joining_date,VR.Medical_inspection
,VR.Police_Incpection,VR.Name,VR.Present_City,VR.Present_Post_Box
,VR.Rec_Start_date,VR.Rec_End_date
,VR.ReportingManager_Id,VR.Segment_Name,VR.Shift_Name
,VR.Signature,
--RM.Basic_Salary,
VR.Total_CTC,VR.Vertical_Name,VR.SubVertical_Name
,VR.Type_Name,VR.latterfile_name,VR.notice_period
,RM.ConfirmJoining,RM.Date_Of_Birth
,RM.Date_Of_Join,RM.Emp_Fix_Salary,RM.HasPancard,RM.Home_Tel_no,RM.Marital_Status
,RM.Marriage_Date,RM.PanCardAck_No,RM.PanCardNo,RM.Permanent_District
--,RM.Present_Post_Box,
,VR.Level2_Approval,VR.SalaryCycle_Id
,VR.Dept_Name,VR.Rec_Post_Code
--,BM.Branch_Name,DM.Desig_Name
,HRE.Employer_Name,HRE.Desig_Name as Desig_Previous,HRE.St_Date as St_Date_previous,HRE.End_Date as End_date_previous,HRE.ExpProof,HRE.DocumentType,HRE.Fromdate,HRE.Todate,HRE.GrossSalary,HRE.ProfessionalTax,HRE.Surcharge,HRE.EducationCess,HRE.TDS,HRE.ITax,HRE.FYear

,HRI.Loc_ID,HRI.Imm_Type,HRI.Imm_No,HRI.Imm_Issue_Date,HRI.Imm_Issue_Status,HRI.Imm_Date_of_Expiry,HRI.Imm_Review_Date,HRI.Imm_Comments

,HRQ.Qual_ID
,QM.Qual_Name
,qm.Qual_Type
,HRQ.Specialization,HRQ.Year,HRQ.Score,HRQ.St_Date,HRQ.End_Date
,HRS.Skill_Id,HRS.Skill_Comments,HRS.Skill_Experience
,HRN.Member_Name,HRN.Member_Age,HRN.Relationship,HRN.Occupation,HRN.Comments
,VR.branch_id,VR.Vertical_Id,VR.SubVertical_ID
,case when RM.is_physical =1 then 'Yes' else 'No' end as Physically_Disability
,RF.offer_date,RM.Aadhar_CardNo,RM.Source_Name,ST.Source_Type_Name
 from t0055_resume_master RM WITH (NOLOCK)
inner join T0060_RESUME_FINAL RF WITH (NOLOCK) on RM.Resume_Id=RF.Resume_ID
--left join T0030_BRANCH_MASTER BM on BM.Branch_ID=RF.Branch_id
--left join T0040_DESIGNATION_MASTER DM on DM.Desig_ID=RF.Desig_id
inner join v0060_RESUME_FINAL VR WITH (NOLOCK) on VR.Resume_ID=RM.Resume_Id
left join T0052_HRMS_Posted_Recruitment HRM WITH (NOLOCK) on HRM.Rec_Post_Id=RM.Rec_Post_Id
left join T0090_HRMS_RESUME_EXPERIENCE HRE WITH (NOLOCK) on RM.Resume_Id = HRE.Resume_ID
left join T0090_HRMS_RESUME_IMMIGRATION HRI WITH (NOLOCK) On RM.Resume_Id = HRI.resume_id
Left Join T0090_HRMS_RESUME_QUALIFICATION HRQ WITH (NOLOCK) on Rm.Resume_Id = HRQ.Resume_ID
Left Join T0090_HRMS_RESUME_SKILL HRS WITH (NOLOCK) on Rm.Resume_Id = HRS.Resume_Id
left join T0090_HRMS_RESUME_NOMINEE HRN WITH (NOLOCK) on Rm.Resume_Id = HRN.Resume_ID 
left join T0040_QUALIFICATION_MASTER QM WITH (NOLOCK) on HRQ.Qual_ID = Qm.Qual_ID
left join T0030_Source_Type_Master ST WITH (NOLOCK) on RM.Source_type_id=ST.Source_Type_Id




