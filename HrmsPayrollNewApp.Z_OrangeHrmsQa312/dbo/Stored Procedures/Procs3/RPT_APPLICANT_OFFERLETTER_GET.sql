

  
CREATE PROCEDURE [dbo].[RPT_APPLICANT_OFFERLETTER_GET]  
  @Cmp_ID  numeric  
 ,@From_Date  datetime  
 ,@To_Date  datetime   
 ,@Branch_ID  numeric   = 0  
 ,@Cat_ID  numeric  = 0  
 ,@Grd_ID  numeric = 0  
 ,@Type_ID  numeric  = 0  
 ,@Dept_ID  numeric  = 0  
 ,@Desig_ID  numeric = 0  
 ,@Emp_ID  numeric  = 0  
 ,@Constraint varchar(5000) = ''  
 ,@Letter  varchar(30)='Offer Letter'  
 ,@reportPath    varchar(max)  
AS  
  
        SET NOCOUNT ON   
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
  SET ARITHABORT ON  
  
BEGIN  
    
 if @Branch_ID = 0  
  set @Branch_ID = null  
 if @Cat_ID = 0  
  set @Cat_ID = null  
     
 if @Type_ID = 0  
  set @Type_ID = null  
 if @Dept_ID = 0  
  set @Dept_ID = null  
 if @Grd_ID = 0  
  set @Grd_ID = null  
 if @Emp_ID = 0  
  set @Emp_ID = null  
    
 If @Desig_ID = 0  
  set @Desig_ID = null  
    
    
   
 Declare @Emp_Cons Table  
  (  
   Emp_ID numeric  
  )  
   
 if @Constraint <> ''  
  begin  
   Insert Into @Emp_Cons  
   select  cast(data  as numeric) from dbo.Split (@Constraint,'#')   
  end  
  --update Offer to Offer Letter by chetan 210717  
  if @Letter ='Offer Letter'  
  begin  
  
   select Job_title,       
     Resume_ID,  
     Resume_Code,  
     Present_Street,  
     Present_City,  
     Present_State,  
     Present_Post_Box,  
     rec_post_date,  
     Rec_post_Id,  
     app_full_name,  
     Emp_First_Name,  
     Rec_Post_Code,  
     v.Branch_id,  
     v.Branch_Name,  
     (Select Branch_Address from T0030_BRANCH_MASTER WITH (NOLOCK) where Branch_id=v.Branch_id) as BranchAddress,  
     (Select branch_city from T0030_BRANCH_MASTER WITH (NOLOCK) where Branch_id=v.Branch_id) as BranchCity,  
     Desig_id,  
     Desig_Name,  
     Dept_id,  
     Dept_Name,  
     Basic_Salay ,  
     Total_CTC,  
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
      ,cmp_logo  
      ,Cmp_Name  
      ,Cmp_Address  
      ,Cmp_City         
      ,CAST(@reportPath as varchar(max)) + '\report_image\header_' + cast (v.cmp_id as varchar) + '.bmp' as rp_header  
      ,CAST(@reportPath as varchar(max)) + '\report_image\Footer_' + cast (v.cmp_id as varchar) + '.bmp' as rp_Footer  
      ,replace(CAST(@reportPath as varchar(max)),'\Reports\','') + '\App_File\Signature\' + cast (v.Signature as varchar(max)) as rp_Sign  
      ,c.cmp_hr_manager  
      ,v.notice_period  as Short_Fall_Days  
      ,ELR.Reference_No  
      ,ELR.Issue_Date  
      ,offer_date--,'') as offer_date  
   From v0060_RESUME_FINAL as v left join  
     T0010_COMPANY_MASTER as c WITH (NOLOCK) on v.Cmp_ID = c.Cmp_Id  
	
     left join t0040_general_setting GS WITH (NOLOCK) on v.branch_id = GS.branch_id   
     left join T0081_Emp_LetterRef_Details ELR WITH (NOLOCK) on ELR.Emp_Id = @Emp_ID and ELR.Letter_Name='Offer Letter' --Mukti(04012017)  
   Where v.Cmp_ID= @Cmp_ID --and v.Resume_ID=@Emp_ID    Ronakb010224  
  End  
   
END  
  
  
