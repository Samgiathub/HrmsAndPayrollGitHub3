---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0050_HRMS_Recruitment_Request]  
  
 @Rec_Req_ID   numeric(18) output  
,@Job_Title    varchar(50)   
,@cmp_id    numeric(18,0)  
,@S_Emp_ID       numeric(18,0)  
,@Login_ID    numeric(18,0)  
,@Posted_date   datetime  
,@Grade_id    numeric(18,0)  
,@Desi_Id    numeric(18,0)  
,@branch_id    numeric(18,0)  
,@Type_ID    numeric(18,0)  
,@Dept_Id    numeric(18,0)  
,@Skill_detail   nvarchar(1000)  
,@Job_Description  nvarchar(2000)--increase size limit from 1000 to 2000 21/08/2017 - to 2500 on 12/12/2017  
,@No_of_vacancies  numeric(3,0)  
,@App_Status   numeric(1,0)  
,@tran_type    char(1)  
,@Qualification_detail  varchar(500)  
,@Experience_Detail     varchar(500)  
,@BusinessSegment_Id    numeric(18,0)  
,@Vertical_Id   numeric(18,0)  
,@SubVertical_Id        numeric(18,0)  
,@Type_Of_Opening  numeric(18,0)  
,@JD_CodeId    numeric(18,0) =null-----27 Jan 2015 start  
,@Budgeted    bit =0  
,@Exp_Min    float =0  
,@Exp_Max    float =0  
,@Rep_EmployeeId  Varchar(max)--011/07/2017 --numeric(18,0)=null -----27 Jan 2015 end  
,@Justification   varchar(1000) --Mukti(03122018)  
,@CTCBudget    numeric(18,2)--Mukti(03122018)  
,@Is_Left_ReplaceEmpId bit          
,@Comments varchar(1000)  
,@Attach_Doc varchar(2000)  
,@Document_ID varchar(200)  
,@Experience_Type int  
,@MIN_CTC_Budget numeric(18,2)   
,@MRF_Code varchar(200)  
,@Category_ID int =0  
,@Gender_Specific varchar(15)=''  
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
  --SELECT * FROM T0050_HRMS_Recruitment_Request  
   
 if @Type_ID = 0   
  set @Type_ID  = null  
 if @branch_id =0   
  set @branch_id = null  
 if @Grade_id = 0   
  set @Grade_id = null  
 if @desi_id = 0  
   set @desi_id = null  
 if @Dept_Id = 0  
   set @Dept_Id = null  
 if @S_Emp_ID = 0  
  set @S_Emp_ID = null     
 if @BusinessSegment_Id = 0  
  set @BusinessSegment_Id = null  
 if @Vertical_Id = 0  
  set @Vertical_Id = null  
 if @SubVertical_Id = 0  
  set @SubVertical_Id = null  
 if @JD_CodeId = 0 ----27 Jan 2015  
  set @JD_CodeId = null  
 if @Category_ID=0  
  set @Category_ID = null  
  --if @Rep_EmployeeId = 0 ----27 Jan 2015  
 -- set @Rep_EmployeeId = null  
    
  --Added by Mukti start on 01042019 -- For Kataria Client   
  set @Job_Title = dbo.fnc_ReverseHTMLTags(@Job_Title)  --added by Ronak 211021  
  set @Comments = dbo.fnc_ReverseHTMLTags(@Comments)  --added by Ronak 211021  
 DECLARE @Type_Name as VARCHAR(250)  
 set @Type_Name =''  
  IF (Upper(@tran_type) ='I' or Upper(@tran_type) ='U')  
  BEGIN  
   IF(ISNULL(@Type_ID,0) >0)   
    BEGIN  
     SELECT @Type_Name=[Type_Name] FROM T0040_TYPE_MASTER WITH (NOLOCK) WHERE cmp_id = @Cmp_ID AND [Type_ID]=@Type_ID   
    END  
      
  --IF(UPPER(@Type_Name)<>'Additional') --for Wonder Client  
  --BEGIN   
   Declare @Employee_Strength_Setting tinyint  
   select @Employee_Strength_Setting = setting_value from T0040_SETTING WITH (NOLOCK) where cmp_id = @Cmp_ID and setting_name = 'Restrict Entry based on Employee Strength Master'  
   --set @Employee_Strength_Setting=1  
   IF @Employee_Strength_Setting = 1  
    Begin  
     IF @Branch_ID > 0 AND @Desi_Id > 0  
     Begin  
      Declare @Branch_Desig_Wise_Count Numeric(18,0)  
      Set @Branch_Desig_Wise_Count = 0  
  
      Declare @Branch_Desig_Strength_Count Numeric(18,0)  
      Set @Branch_Desig_Strength_Count = 0  
  
      Select   
       @Branch_Desig_Wise_Count = Count(1)  
      FROM  
       (SELECT   
        I1.EMP_ID, I1.DESIG_ID, I1.BRANCH_ID,I1.Dept_ID  
       FROM T0095_INCREMENT I1 WITH (NOLOCK)  
       INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON E.EMP_ID = I1.EMP_ID AND (E.Emp_Left_Date IS NULL OR ISNULL(Emp_Left,'N') = 'N')  
       INNER JOIN (  
          SELECT   
           MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID  
          FROM T0095_INCREMENT I2 WITH (NOLOCK)   
          INNER JOIN (  
              SELECT   
               MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID  
              FROM T0095_INCREMENT I3 WITH (NOLOCK)  
              WHERE I3.Increment_Effective_Date <= Getdate() AND Cmp_ID = @Cmp_ID  
              GROUP BY I3.Emp_ID  
             ) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID                    
          WHERE I2.Cmp_ID = @Cmp_Id   
          GROUP BY I2.Emp_ID  
         ) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_ID=I2.INCREMENT_ID   
       WHERE I1.Cmp_ID=@Cmp_Id   
       AND NOT EXISTS(SELECT 1 FROM T0200_EMP_EXITAPPLICATION EE WITH (NOLOCK) WHERE EE.EMP_ID = I1.EMP_ID AND EE.status NOT IN('R','LR'))           
       ) I  
      WHERE I.Branch_ID = @Branch_ID AND I.Desig_Id = @Desi_Id  AND I.Dept_ID=@Dept_Id  
  
      Select @Branch_Desig_Strength_Count = ESM.Strength  
       From T0040_Employee_Strength_Master ESM WITH (NOLOCK)  
       INNER JOIN(  
          Select Max(Effective_Date) as For_Date,Branch_ID,Desig_Id,DEPT_ID   
           From T0040_Employee_Strength_Master WITH (NOLOCK)   
          Where Branch_Id <> 0 and Desig_Id <> 0 AND Cmp_Id=@CMP_ID  
          Group By Branch_ID,Desig_Id,DEPT_ID  
       ) as Qry   
      ON ESM.Effective_Date = Qry.For_Date AND ESM.Branch_Id = Qry.Branch_Id AND ESM.Desig_Id = Qry.Desig_Id and ESM.Dept_Id=QRY.DEPT_ID  
      WHERE ESM.Cmp_Id=@CMP_ID AND ESM.Branch_Id=@BRANCH_ID AND ESM.Desig_Id=@DESI_ID and ESM.Dept_Id=@DEPT_ID  
        
--SELECT  @Branch_Desig_Strength_Count, @Branch_Desig_Wise_Count,@No_of_vacancies  
      if (@Branch_Desig_Wise_Count+@No_of_vacancies) > @Branch_Desig_Strength_Count  
       Begin  
        set @Rec_Req_ID = 0  
        RAISERROR ('@@No of Vacancy is greater than employee strength master limit@@', 16, 2)  
        return  
       End  
     End  
    End   
  -- END  
  END  
 --Added by Mukti end on 01042019 -- For Kataria Client   
   
     
 if Upper(@tran_type) ='I'   
  begin  
   --@jobTiltle dublicate validation - Deepali 16092023
   if exists (Select Rec_Req_ID  from T0050_HRMS_Recruitment_Request Where Job_Title =@Job_Title and Cmp_ID =@Cmp_ID and branch_id=@branch_id )  
     begin  
       set @Rec_Req_ID=0  
	    RAISERROR ('@@Same Job Title Already Exits@@', 16, 2)  
       return 0  
     end  
      
     select @Rec_Req_ID = isnull(max(Rec_Req_ID),0) + 1 from T0050_HRMS_Recruitment_Request WITH (NOLOCK)  
        
     insert into T0050_HRMS_Recruitment_Request(  
           Rec_Req_ID  
           ,Job_Title  
           ,cmp_id  
           ,S_Emp_ID   
           ,Login_ID  
           ,Posted_date  
           ,Grade_id  
           ,Desi_Id  
           ,branch_id  
           ,Type_ID  
           ,Dept_Id  
           ,Skill_detail  
           ,Job_Description  
           ,No_of_vacancies  
           ,App_status  
              ,Qualification_detail  
           ,Experience_Detail  
           ,System_Date  
           ,BusinessSegment_Id  
           ,Vertical_Id  
           ,SubVertical_Id  
           ,Type_Of_Opening  
           ,JD_CodeId----27 Jan 2015 start  
           ,Budgeted  
           ,Exp_Min  
           ,Exp_Max  
           ,Rep_EmployeeId----27 Jan 2015end  
           ,Justification  
           ,CTC_Budget  
           ,Is_Left_ReplaceEmpId  
           ,Comments  
           ,Attach_Doc  
           ,Document_ID  
           ,Experience_Type  
           ,MIN_CTC_Budget  
           ,MRF_Code  
           ,Category_ID  
           ,Manager_Attach_Docs  
           ,Gender_Specific  
          )   
    
        values( @Rec_Req_ID  
            ,@Job_Title  
            ,@cmp_id  
            ,@S_Emp_ID   
            ,@Login_ID  
            ,@Posted_date  
            ,@Grade_id  
            ,@Desi_Id  
            ,@branch_id  
            ,@Type_ID  
            ,@Dept_Id  
            ,@Skill_detail  
            ,@Job_Description  
            ,@No_of_vacancies  
            ,@App_Status  
            ,@Qualification_detail  
            ,@Experience_Detail  
            ,getdate()  
            ,@BusinessSegment_Id  
            ,@Vertical_Id  
            ,@SubVertical_Id  
            ,@Type_Of_Opening  
            ,@JD_CodeId----27 Jan 2015 start  
            ,@Budgeted  
            ,@Exp_Min  
            ,@Exp_Max  
            ,@Rep_EmployeeId----27 Jan 2015 end  
            ,@Justification  
            ,@CTCBudget  
            ,@Is_Left_ReplaceEmpId  
            ,@Comments  
            ,@Attach_Doc  
            ,@Document_ID  
            ,@Experience_Type  
            ,@MIN_CTC_Budget  
            ,@MRF_Code  
            ,@Category_ID  
            ,''  
            ,@Gender_Specific  
            )        
  
  end   
 else if upper(@tran_type) ='U'   
  begin  
       
    Update T0050_HRMS_Recruitment_Request                    
        Set       Job_Title =@Job_Title  
           ,Posted_date =@Posted_date  
           ,Grade_id=@Grade_id  
           ,Desi_Id =@Desi_Id  
           ,branch_id=@branch_id  
           ,Type_ID=@Type_ID  
           ,Dept_Id=@Dept_Id  
           ,Skill_detail=@Skill_detail  
           ,Job_Description =@Job_Description  
           ,No_of_vacancies =@No_of_vacancies  
           ,App_status =@App_Status     
           ,Qualification_detail=@Qualification_detail  
           ,Experience_Detail=@Experience_Detail  
           ,System_Date=getdate()  
           ,BusinessSegment_Id = @BusinessSegment_Id  
           ,Vertical_Id=@Vertical_Id  
           ,SubVertical_Id=@SubVertical_Id  
           ,Type_Of_Opening =@Type_Of_Opening  
           ,JD_CodeId =  @JD_CodeId----27 Jan 2015 start  
           ,Budgeted =  @Budgeted  
           ,Exp_Min =  @Exp_Min  
           ,Exp_Max =  @Exp_Max  
           ,Rep_EmployeeId =  @Rep_EmployeeId----27 Jan 2015 end  
           ,Justification =@Justification  
           ,CTC_Budget=@CTCBudget  
           ,Is_Left_ReplaceEmpId=@Is_Left_ReplaceEmpId  
           ,Comments=@Comments  
           ,Attach_Doc=@Attach_Doc  
           ,Document_ID=@Document_ID  
           ,Experience_Type=@Experience_Type  
           ,MIN_CTC_Budget=@MIN_CTC_Budget  
           ,MRF_Code=@MRF_Code  
           ,Category_ID=@Category_ID  
           ,Gender_Specific=@Gender_Specific  
    where Rec_Req_ID = @Rec_Req_ID    
  end   
 else if upper(@tran_type) ='D'  
  Begin  
   delete from T0055_RecruitmentSkill  where Rec_Req_ID=@Rec_Req_ID-----27 Jan 2015 start  
   delete from T0055_Recruitment_Responsibility where Rec_Req_ID=@Rec_Req_ID-----27 Jan 2015 end  
     
   declare @recapp_id as numeric(18,0)---added on 1 Feb 2016 sneha start  
   select @recapp_id = RecApp_Id from T0052_Hrms_RecruitmentRequest_Approval WITH (NOLOCK) where Rec_Req_ID=@Rec_Req_ID  
   delete from T0115_RecruitmentSkill_Level where RecApp_Id =@recapp_id  
   delete from T0115_RecruitmentResponsibilty_Level where RecApp_Id =@recapp_id---added on 1 Feb 2016 sneha end  
   delete from T0052_Hrms_RecruitmentRequest_Approval where Rec_Req_ID=@Rec_Req_ID  
   delete  from T0050_HRMS_Recruitment_Request where Rec_Req_ID=@Rec_Req_ID   
  end  
 RETURN  
  
  
  
  