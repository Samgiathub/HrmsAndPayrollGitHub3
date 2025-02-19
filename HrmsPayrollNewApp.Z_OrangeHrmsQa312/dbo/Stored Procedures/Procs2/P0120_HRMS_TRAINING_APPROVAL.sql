  
  
CREATE PROCEDURE [dbo].[P0120_HRMS_TRAINING_APPROVAL]   
 @Training_Apr_ID numeric(18, 0) output  
 ,@Training_App_ID numeric(18, 0) output  
 ,@Login_ID   numeric(18, 0)  
 ,@Training_id  numeric(18, 0)  
 ,@Training_NAME     VARCHAR(150)  
-- ,@Training_Date  datetime  ' Commented by Gadriwala Muslim 12112016  
 ,@Place    varchar(100)  
 ,@Faculty   varchar(100)  
 ,@Training_Pro_ID numeric(18,0)  
 ,@Description  varchar(200)  
 ,@Training_Cost  numeric(18, 2)  
 ,@Training_Cost_per_Emp numeric(18, 2)  
 ,@Apr_Status  int  
 ,@Cmp_ID   numeric(18, 0)  
 --,@Training_End_Date datetime ' Commented by Gadriwala Muslim 12112016  
 ,@Training_Type  int  
 ,@Training_Leave_Type int  
-- ,@no_of_day   int ' Commented by Gadriwala Muslim 12112016  
 ,@Impact_Salary  int  
 ,@emp_feedback  int  
 ,@Sup_feedback  int  
 ,@skill_id   numeric(18, 0)  
 ,@Comments   text  
 ,@branch_id varchar(max)=''  --modified on 24 Aug 2015 sneha  
    ,@dept_id varchar(max)='' --modified on 24 july 2015 sneha  
    ,@desig_id varchar(max)='' --modified on 24 Aug 2015 sneha  
    ,@grd_id varchar(max)=''  --modified on 24 Aug 2015 sneha  
 ,@Trans_Type        char(1)  
 ,@Training_Code  varchar(50)=''  --added on 24 july 2015 sneha  
 --,@Training_FromTime varchar(50)=null ' Commented by Gadriwala Muslim 12112016  --added on 24 july 2015 sneha  
 --,@Training_ToTime varchar(50)=null ' Commented by Gadriwala Muslim 12112016 --added on 24 july 2015 sneha  
 ,@flag int = 0  --Mukti 12082015  
 ,@User_Id numeric(18,0) = 0 -- added By Mukti 18082015  
    ,@IP_Address varchar(30)= '' -- added By Mukti 18082015  
    ,@Bond_Month int=0  --Mukti(02022016)  
    ,@Attachment Varchar(Max)= '' --Mukti(02022016)  
    ,@Manager_FeedbackDays int = 0 --added 15 feb 2016 sneha  
    ,@PublishTraining int = 0 --added 21 Jun 2016 sneha  
    ,@VideoURL nvarchar(max) = '' -- Added by Gadriwala muslim 15112016  
    ,@latitude numeric(18,14) = 0 -- Added by Gadriwala muslim 21112016  
    ,@longitude  numeric(18,14) = 0 -- Added by Gadriwala muslim 21112016  
    ,@category_id varchar(max) = '' --Added by Mukti(06072017)  
AS  
  
        SET NOCOUNT ON   
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
  SET ARITHABORT ON  
  
 if @skill_id = 0  
    set @skill_id = null   
 --if @branch_id=0  
 -- set @branch_id=null  
  --  if @dept_id=0  
  --set @dept_id=null  
  --  if @desig_id=0  
  --set @desig_id=null  
  --  if @grd_id=0  
  --set @grd_id=null  
    ---------Commet By Nilay 2-Nov-2010 ----------------------  
    --if @Training_id =0  
    --set @Training_id=null  
    --IF @Training_App_ID=0  
    -- set @Training_App_ID=NULL   
  if @Training_Pro_ID = 0  
   set @Training_Pro_ID = NULL  
  --IF @Cmp_ID=0  
  --set @Cmp_ID=NULL  
  --IF @Login_ID = 0   
  --set @Login_ID = NULL  
  -----------------------------------------------------------  
    
--Added By Mukti 18082015(start)  
 declare @OldValue as varchar(max)  
 declare @OldTraining_App_ID VARCHAR(50)  
 declare @OldLogin_ID VARCHAR(50)  
 declare @OldTraining_id VARCHAR(50)  
 declare @OldTraining_NAME   VARCHAR(150)  
-- declare @OldTraining_Date VARCHAR(50) -- Commented by Gadriwala Muslim 12112016   
 declare @OldPlace   varchar(100)  
 declare @OldFaculty   varchar(100)  
 declare @OldTraining_Pro_ID VARCHAR(50)  
 declare @OldDescription  varchar(200)  
 declare @OldTraining_Cost VARCHAR(20)  
 declare @OldTraining_Cost_per_Emp VARCHAR(20)  
 declare @OldApr_Status   VARCHAR(20)  
-- declare @OldTraining_End_Date VARCHAR(50)Commented by Gadriwala Muslim 12112016   
 declare @OldTraining_Type  VARCHAR(20)  
 declare @OldTraining_Leave_Type VARCHAR(20)  
 --declare @Oldno_of_day   VARCHAR(20)Commented by Gadriwala Muslim 12112016   
 declare @OldImpact_Salary  VARCHAR(20)  
 declare @Oldemp_feedback  VARCHAR(20)  
 declare @OldSup_feedback  VARCHAR(20)  
 declare @Oldskill_id   VARCHAR(20)  
 declare @OldComments   varchar(500)  
 declare @Oldbranch_id   VARCHAR(20)  
    declare @Olddept_id    varchar(max)  
    declare @Olddesig_id   VARCHAR(20)  
    declare @Oldgrd_id    VARCHAR(20)  
 declare @OldTraining_Code  varchar(50)  
 declare @OldVideoURL nvarchar(max)   
 declare @oldlatitude numeric(18,14)  -- Added by Gadriwala muslim 21112016  
    declare @oldlongitude  numeric(18,14)  -- Added by Gadriwala muslim 21112016  
    declare @Oldcategory_id varchar(max)  
 set @OldVideoURL = ''  
 set @oldlatitude = 0 -- Added by Gadriwala muslim 21112016  
 set @oldlongitude = 0 -- Added by Gadriwala muslim 21112016  
   
 --declare @OldTraining_FromTime varchar(50) Commented by Gadriwala Muslim 12112016   
 --declare @OldTraining_ToTime  varchar(50) Commented by Gadriwala Muslim 12112016   
--Added By Mukti 18082015(start)   
  
select @Training_Code = @Training_Apr_ID  
  
    set @Description = dbo.fnc_ReverseHTMLTags(@Description)  --added by Ronak 221021
	set @Faculty = dbo.fnc_ReverseHTMLTags(@Faculty)  --added by Ronak 221021
If @Trans_Type  = 'I'   
 Begin  
   -- COMMENTED BY GADRIWALA MUSLIM  DUPLICATION CHECK WITH SEPARTED SP    
   -- If Exists(select Training_Apr_ID From T0120_HRMS_TRAINING_APPROVAL Where Cmp_Id = @Cmp_Id and Training_id = @Training_id /*and Training_Date = @Training_Date*/)  
   --Begin  
   -- Set @Training_Apr_ID = 0  
   -- Return   
   --End   
     
     IF @Training_id = 0  
       Begin  
      EXEC P0040_HRMS_Training_master @Training_id OUTPUT,@Training_Name,'',@CMP_ID,'i'  
       End   
      
  IF @Training_App_ID=0  
   EXEC P0100_HRMS_TRAINING_APPLICATION @Training_App_ID OUTPUT,@Training_id,'',@Description,null,0,@skill_id,'',@Apr_Status,@cmp_id,@Login_ID,'I',0,'',1    
      
      SELECT  @Training_Apr_ID = Isnull(max(Training_Apr_ID),0) + 1  From T0120_HRMS_TRAINING_APPROVAL WITH (NOLOCK)  
      --added on 01/08/2015 sneha--training code generate   
      select @Training_Code = isnull(count(Training_Apr_ID),0)+1 from T0120_HRMS_TRAINING_APPROVAL WITH (NOLOCK) where Cmp_ID = @Cmp_ID /*and  training_date = @training_date*/  
     print @Training_Code  
      set @Training_Code = replace(convert(char,GETDATE(),5),'-','') +'00' + @Training_Code   
      print @Training_Code  
   --select @Training_Code = @Training_Apr_ID   
   --added on 01/08/2015 end sneha  
   set @Training_Code= REPLACE(@Training_Code,' ','')  
  print @Training_Code  
  if not exists(SELECT 1 from T0120_HRMS_TRAINING_APPROVAL WITH (NOLOCK) where Training_App_ID = @Training_App_ID)   
    BEGIN  
    print 'kk'  
     INSERT INTO T0120_HRMS_TRAINING_APPROVAL  
           (  
          Training_Apr_ID  
       ,Training_App_ID  
       ,Login_ID  
       ,Training_id  
       --,Training_Date Commented by Gadriwala Muslim 12112016   
       ,Place  
       ,Faculty  
       ,Training_Pro_ID  
       ,Description  
       ,Training_Cost  
       ,Training_Cost_per_Emp  
       ,Apr_Status  
       ,Cmp_ID  
       --,Training_End_Date Commented by Gadriwala Muslim 12112016   
       ,Training_Type  
       ,Training_Leave_Type  
       --,no_of_day Commented by Gadriwala Muslim 12112016   
       ,Impact_Salary  
       ,emp_feedback  
       ,Sup_feedback  
       ,Comments  
       ,branch_id   
       ,dept_id   
       ,desig_id   
       ,grd_id   
       ,Training_Code   --added on 24 july 2015 sneha  
      -- ,Training_FromTime Commented by Gadriwala Muslim 12112016  --added on 24 july 2015 sneha  
      -- ,Training_ToTime Commented by Gadriwala Muslim 12112016  --added on 24 july 2015 sneha  
       ,Bond_Month --Mukti(02022016)  
       ,Attachment --Mukti(02022016)  
       ,Manager_FeedbackDays  --added 15 feb 2016 sneha  
       ,PublishTraining  
       ,VideoURL  
       ,latitude  
       ,longitude  
       ,category_id --Added by Mukti(06072017)  
     )  
    VALUES       
     (   @Training_Apr_ID  
       ,@Training_App_ID  
       ,@Login_ID  
       ,@Training_id  
      -- ,@Training_Date Commented by Gadriwala Muslim 12112016   
       ,@Place  
       ,@Faculty  
       ,@Training_Pro_ID  
       ,@Description  
       ,@Training_Cost  
       ,@Training_Cost_per_Emp  
       ,@Apr_Status  
       ,@Cmp_ID  
      -- ,@Training_End_Date Commented by Gadriwala Muslim 12112016   
       ,@Training_Type  
       ,@Training_Leave_Type  
      -- ,@no_of_day Commented by Gadriwala Muslim 12112016   
       ,@Impact_Salary  
       ,@emp_feedback  
       ,@Sup_feedback  
       ,@Comments  
       ,@branch_id   
       ,@dept_id   
       ,@desig_id   
       ,@grd_id  
       ,REPLACE(@Training_Code,' ','')   --added on 24 july 2015 sneha  
      -- ,@Training_FromTime Commented by Gadriwala Muslim 12112016  --added on 24 july 2015 sneha  
      -- ,@Training_ToTime Commented by Gadriwala Muslim 12112016  --added on 24 july 2015 sneha   
       ,@Bond_Month --Mukti(02022016)  
       ,@Attachment --Mukti(02022016)  
       ,@Manager_FeedbackDays --added 15 feb 2016 sneha  
       ,@PublishTraining  
       ,@videoURL -- Added by Gadriwala Muslim 15112016  
       ,@latitude -- Added by Gadriwala Muslim 21112016  
       ,@longitude -- Added by Gadriwala Muslim 21112016  
       ,@category_id  --Added by Mukti(06072017)  
     )  
       
     --Added By Mukti 18082015(start)  
     set @OldValue = 'New Value' + '#'+ 'Training Application ID :' + cast(Isnull(@Training_App_ID,0) as varchar(10)) + '#' +   
               'Training ID :' + cast(Isnull(@Training_id,0) as varchar(10)) + '#' +   
               'Place :' + cast(Isnull(@Place,'') as varchar(100)) + '#' +   
               'Faculty :' + cast(Isnull(@Faculty,'') as varchar(100)) + '#' +   
               'Provider ID :' + cast(Isnull(@Training_Pro_ID,0) as varchar(100)) + '#' +   
               'Description :' + cast(Isnull(@Description,'') as varchar(1000)) + '#' +   
               'Training Cost :' + cast(Isnull(@Training_Cost,0) as varchar(20)) + '#' +   
                'Training Cost per Emp :' + cast(Isnull(@Training_Cost_per_Emp,0) as varchar(15)) + '#' +   
                'Approval Status :' + cast(Isnull(@Apr_Status,0) as varchar(20)) + '#' +   
                'Training Type :' + cast(Isnull(@Training_Type,0) as varchar(50)) + '#' +   
                'Training Leave Type :' + cast(Isnull(@Training_Leave_Type,0) as varchar(50)) + '#' +   
                'Impact Salary :' + cast(Isnull(@Impact_Salary,0) as varchar(50)) + '#' +   
                'Employee Feedback :' + cast(Isnull(@emp_feedback,0) as varchar(50)) + '#' +   
                'Superior Feedback :' + cast(Isnull(@Sup_feedback,0) as varchar(50)) + '#' +   
                'Comments :' + cast(Isnull(@Comments,'') as varchar(500)) + '#' +  
                'Branch Id :' + cast(Isnull(@branch_id,0) as varchar(50)) + '#' +  
                'Dept id :' + cast(Isnull(@dept_id,0) as varchar(50)) + '#' +  
                'Desig id :' + cast(Isnull(@desig_id,0) as varchar(50)) + '#' +  
                'Grd id :' + cast(Isnull(@Grd_id,0) as varchar(50)) + '#' +  
                'Training Code :' + cast(Isnull(@Training_Code,'') as varchar(50)) + '#' +  
                'Video Url :' + Isnull(@videoURL,'') + '#' +  
                'latitude :' + cast(Isnull(@latitude,0) as varchar(18)) + '#' +  
                'longitude :' + cast(Isnull(@longitude,0) as varchar(18)) + '#' +  
                'Category ID :' + cast(Isnull(@category_id,0) as varchar(Max))  
       --Added By Mukti 18082015(end)  
      UPDATE T0100_HRMS_TRAINING_APPLICATION  
       SET App_Status = @Apr_Status where Training_App_ID=@Training_App_ID and Cmp_id=@Cmp_ID  
      
      Update T0130_HRMS_TRAINING_EMPLOYEE_DETAIL   
      set Training_Apr_ID =@Training_Apr_ID where Training_App_ID=@Training_App_ID and Cmp_id=@Cmp_ID  
    
    END   
   else  
    BEGIN  
      SELECT @TRAINING_APR_ID = TRAINING_APR_ID FROM T0120_HRMS_TRAINING_APPROVAL WITH (NOLOCK) WHERE TRAINING_APP_ID = @TRAINING_APP_ID  
       
     GOTO UPDATELABLE;  
      
    END  
      
      
    
  End  
 Else if @Trans_Type = 'U'  
   begin  
   
UPDATELABLE:    
   --If Exists(select Training_Apr_ID From T0120_HRMS_TRAINING_APPROVAL  Where Cmp_Id = @Cmp_Id and Training_id=@Training_id  and Training_Apr_ID <> @Training_Apr_ID )  
   -- begin  
   --  set @Training_Apr_ID = 0  
   --  return   
   -- end  
 --commented by Mukti(20062017)start     
  --added on 01/08/2015 sneha--training code generate   
    --if @Training_Code<>''  
    -- begin   
    --  select @Training_Code = isnull(count(Training_Apr_ID),0)+1 from T0120_HRMS_TRAINING_APPROVAL where Cmp_ID = @Cmp_ID /*and  training_date = @training_date*/ and Training_Apr_ID <> @Training_Apr_ID        
    --  set @Training_Code =replace(convert(char,GETDATE(),5),'-','')+ '00' + @Training_Code   
    -- end  
    --else  
    -- begin   
    --  if exists(select 1 From T0120_HRMS_TRAINING_APPROVAL Where Cmp_Id = @Cmp_Id and Training_id=@Training_id  and Training_Apr_ID = @Training_Apr_ID /*and Training_Date <> @Training_Date*/)  
    --   begin  
    --    select @Training_Code = isnull(count(Training_Apr_ID),0)+1 from T0120_HRMS_TRAINING_APPROVAL where Cmp_ID = @Cmp_ID/* and  training_date = @training_date*/ and Training_Apr_ID <> @Training_Apr_ID  
    --    set @Training_Code = replace(convert(char,GETDATE(),5),'-','')+'00' + @Training_Code   
    --   end  
    --End  
 --added on 01/08/2015 sneha--training code generate  end  
 --commented by Mukti(20062017)end  
        
  --Added By Mukti 18082015(start)  
    select @OldLogin_ID=Login_ID  
      ,@OldTraining_id=Training_id  
      --,@OldTraining_Date=Training_Date  
      ,@OldPlace=Place  
      ,@OldFaculty=Faculty  
      ,@OldTraining_Pro_ID=Training_Pro_ID  
      ,@OldDescription=[Description]  
      ,@OldTraining_Cost=Training_Cost  
      ,@OldTraining_Cost_per_Emp=Training_Cost_per_Emp  
      ,@OldApr_Status=Apr_Status  
      --,@OldTraining_End_Date=Training_End_Date  
      ,@OldTraining_Type=Training_Type  
      ,@OldTraining_Leave_Type=Training_Leave_Type  
     -- ,@Oldno_of_day=no_of_day  
      ,@OldImpact_Salary=Impact_Salary  
      ,@Oldemp_feedback=emp_feedback  
      ,@OldSup_feedback=Sup_feedback  
      ,@OldComments=Comments  
      ,@Oldbranch_id=branch_id   
      ,@Olddept_id=dept_id   
      ,@Olddesig_id=desig_id    
      ,@Oldgrd_id=grd_id  
      ,@OldTraining_Code=Training_Code   
      ,@OldVideoURL = isnull(videoURL,'')  
      ,@oldlatitude = latitude -- Added by Gadriwala Muslim 21112016  
      ,@oldlongitude = longitude -- Added by Gadriwala Muslim 21112016  
      ,@Oldcategory_id = category_id  
     -- ,@OldTraining_FromTime=Training_FromTime  
     -- ,@OldTraining_ToTime=Training_ToTime  
       
    from T0120_HRMS_TRAINING_APPROVAL WITH (NOLOCK) where cmp_id = @cmp_id and Training_Apr_ID = @Training_Apr_ID  
  --Added By Mukti 18082015(end)   
     
      
         
    UPDATE    T0120_HRMS_TRAINING_APPROVAL  
    SET   Login_ID=@Login_ID  
      ,Training_id=@Training_id  
     -- ,Training_Date=@Training_Date  
      ,Place=@Place  
      ,Faculty=@Faculty  
      ,Training_Pro_ID=@Training_Pro_ID  
      ,Description=@Description  
      ,Training_Cost=@Training_Cost  
      ,Training_Cost_per_Emp=@Training_Cost_per_Emp  
      ,Apr_Status=@Apr_Status  
     -- ,Training_End_Date=@Training_End_Date  
      ,Training_Type=@Training_Type  
      ,Training_Leave_Type=@Training_Leave_Type  
     -- ,no_of_day=@no_of_day  
      ,Impact_Salary=@Impact_Salary  
      ,emp_feedback=@emp_feedback  
      ,Sup_feedback=@Sup_feedback  
      ,Comments=@Comments  
      ,branch_id=@branch_id   
      ,dept_id=@dept_id   
      ,desig_id=@desig_id    
      ,grd_id=@grd_id  
      --,Training_Code  = @Training_Code --added on 24 july 2015 sneha  
     -- ,Training_FromTime = @Training_FromTime--added on 24 july 2015 sneha  
     -- ,Training_ToTime = @Training_ToTime--added on 24 july 2015 sneha  
      ,Bond_Month = @Bond_Month  --Mukti(02022016)  
      ,Attachment=@Attachment --Mukti(02022016)  
      ,Manager_FeedbackDays = @Manager_FeedbackDays--added 15 feb 2016 sneha  
      ,PublishTraining = @PublishTraining --added 21 Jun 2016 sneha  
      ,VideoURL = @VideoURL  
      ,latitude = @latitude -- Added by Gadriwala Muslim 21112016  
      ,longitude = @longitude  -- Added by Gadriwala Muslim 21112016  
      ,category_id =@category_id  --Added by Mukti(06072017)  
    where Training_Apr_ID = @Training_Apr_ID  
      
   UPDATE T0100_HRMS_TRAINING_APPLICATION  
    SET App_Status = @Apr_Status,Skill_Id=@Skill_Id   
   where Training_App_ID=@Training_App_ID and Cmp_id=@Cmp_ID --Mukti 31072015  
     
  --Added By Mukti 18082015(start)  
       set @OldValue = 'Old Value' + '#'+ 'Training Application ID :' + cast(Isnull(@OldTraining_App_ID,0) as varchar(10)) + '#' +   
               'Training ID :' + cast(Isnull(@OldTraining_id,0) as varchar(10)) + '#' +   
             --  'Training Date :' + cast(Isnull(@OldTraining_Date,'') as varchar(30)) + '#' +   
               'Place :' + cast(Isnull(@OldPlace,'') as varchar(100)) + '#' +   
               'Faculty :' + cast(Isnull(@OldFaculty,'') as varchar(100)) + '#' +   
               'Provider ID :' + cast(Isnull(@OldTraining_Pro_ID,0) as varchar(100)) + '#' +   
               'Description :' + cast(Isnull(@OldDescription,'') as varchar(1000)) + '#' +   
               'Training Cost :' + cast(Isnull(@OldTraining_Cost,0) as varchar(20)) + '#' +   
                'Training Cost per Emp :' + cast(Isnull(@OldTraining_Cost_per_Emp,0) as varchar(15)) + '#' +   
                'Approval Status :' + cast(Isnull(@OldApr_Status,0) as varchar(20)) + '#' +   
              --  'Training End Date :' + cast(Isnull(@OldTraining_End_Date,'') as varchar(30)) + '#' +   
                'Training Type :' + cast(Isnull(@OldTraining_Type,0) as varchar(50)) + '#' +   
                'Training Leave Type :' + cast(Isnull(@OldTraining_Leave_Type,0) as varchar(50)) + '#' +   
              --  'No of days :' + cast(Isnull(@Oldno_of_day,0) as varchar(50)) + '#' +   
                'Impact Salary :' + cast(Isnull(@OldImpact_Salary,0) as varchar(50)) + '#' +   
                'Employee Feedback :' + cast(Isnull(@Oldemp_feedback,0) as varchar(50)) + '#' +   
                'Superior Feedback :' + cast(Isnull(@OldSup_feedback,0) as varchar(50)) + '#' +   
                'Comments :' + cast(Isnull(@OldComments,'') as varchar(500)) + '#' +  
                'Branch Id :' + cast(Isnull(@Oldbranch_id,0) as varchar(50)) + '#' +  
                'Dept id :' + cast(Isnull(@Olddept_id,0) as varchar(50)) + '#' +  
                'Desig id :' + cast(Isnull(@Olddesig_id,0) as varchar(50)) + '#' +  
                'Grd id :' + cast(Isnull(@Oldgrd_id,0) as varchar(50)) + '#' +  
                'Training Code :' + cast(Isnull(@OldTraining_Code,'') as varchar(50)) + '#' +  
                'Video URL :' + Isnull(@OldVideoURL,'') + '#' +  
                'latitude :' + cast(Isnull(@oldlatitude,0) as varchar(18)) + '#' +  
                'longitude :' + cast(Isnull(@oldlongitude,0) as varchar(18)) + '#' +  
                'Category ID :' + cast(Isnull(@Oldcategory_id,0) as varchar(MAX)) + '#' +  
             --   'From Time :' + cast(Isnull(@OldTraining_FromTime,'') as varchar(50)) + '#' +  
             --   'To Time :' + cast(Isnull(@OldTraining_ToTime,'') as varchar(50)) + '#' +   
        'New Value' + '#'+ 'Training Application ID :' + cast(Isnull(@Training_App_ID,0) as varchar(10)) + '#' +   
               'Training ID :' + cast(Isnull(@Training_id,0) as varchar(10)) + '#' +   
            -- 'Training Date :' + cast(Isnull(@Training_Date,'') as varchar(30)) + '#' +   
               'Place :' + cast(Isnull(@Place,'') as varchar(100)) + '#' +   
               'Faculty :' + cast(Isnull(@Faculty,'') as varchar(100)) + '#' +   
               'Provider ID :' + cast(Isnull(@Training_Pro_ID,0) as varchar(100)) + '#' +   
               'Description :' + cast(Isnull(@Description,'') as varchar(1000)) + '#' +   
               'Training Cost :' + cast(Isnull(@Training_Cost,0) as varchar(20)) + '#' +   
                'Training Cost per Emp :' + cast(Isnull(@Training_Cost_per_Emp,0) as varchar(15)) + '#' +   
                'Approval Status :' + cast(Isnull(@Apr_Status,0) as varchar(20)) + '#' +   
              --  'Training End Date :' + cast(Isnull(@Training_End_Date,'') as varchar(30)) + '#' +   
                'Training Type :' + cast(Isnull(@Training_Type,0) as varchar(50)) + '#' +   
                'Training Leave Type :' + cast(Isnull(@Training_Leave_Type,0) as varchar(50)) + '#' +   
              --  'No of days :' + cast(Isnull(@no_of_day,0) as varchar(50)) + '#' +   
                'Impact Salary :' + cast(Isnull(@Impact_Salary,0) as varchar(50)) + '#' +   
                'Employee Feedback :' + cast(Isnull(@emp_feedback,0) as varchar(50)) + '#' +   
                'Superior Feedback :' + cast(Isnull(@Sup_feedback,0) as varchar(50)) + '#' +   
                'Comments :' + cast(Isnull(@Comments,'') as varchar(500)) + '#' +  
                'Branch Id :' + cast(Isnull(@branch_id,0) as varchar(50)) + '#' +  
                'Dept id :' + cast(Isnull(@dept_id,0) as varchar(50)) + '#' +  
                'Desig id :' + cast(Isnull(@desig_id,0) as varchar(50)) + '#' +  
                'Grd id :' + cast(Isnull(@grd_id,0) as varchar(50)) + '#' +  
                'Training Code :' + cast(Isnull(@Training_Code,'') as varchar(50)) + '#' +  
                'Video URL :' + Isnull(@VideoURL,'') + '#' +  
                'latitude :' + cast(Isnull(@latitude,0) as varchar(18)) + '#' +  
                'longitude :' + cast(Isnull(@longitude,0) as varchar(18)) + '#' +  
                'Category ID :' + cast(Isnull(@category_id,0) as varchar(Max))  
             --   'From Time :' + cast(Isnull(@Training_FromTime,'') as varchar(50)) + '#' +  
             --   'To Time :' + cast(Isnull(@Training_ToTime,'') as varchar(50))  
  --Added By Mukti 18082015(end)  
  end  
 Else If upper(@Trans_Type) = 'D'  
 begin   
   if @flag=0  
    begin  
  --Added By Mukti 18082015(start)  
    select @OldLogin_ID=Login_ID  
      ,@OldTraining_id=Training_id  
     -- ,@OldTraining_Date=Training_Date  
      ,@OldPlace=Place  
      ,@OldFaculty=Faculty  
      ,@OldTraining_Pro_ID=Training_Pro_ID  
      ,@OldDescription=[Description]  
      ,@OldTraining_Cost=Training_Cost  
      ,@OldTraining_Cost_per_Emp=Training_Cost_per_Emp  
      ,@OldApr_Status=Apr_Status  
     -- ,@OldTraining_End_Date=Training_End_Date  
      ,@OldTraining_Type=Training_Type  
      ,@OldTraining_Leave_Type=Training_Leave_Type  
     -- ,@Oldno_of_day=no_of_day  
      ,@OldImpact_Salary=Impact_Salary  
      ,@Oldemp_feedback=emp_feedback  
      ,@OldSup_feedback=Sup_feedback  
      ,@OldComments=Comments  
      ,@Oldbranch_id=branch_id   
      ,@Olddept_id=dept_id   
      ,@Olddesig_id=desig_id    
      ,@Oldgrd_id=grd_id  
      ,@OldTraining_Code=Training_Code  
      ,@OldVideoURL = isnull(videoURL ,'')  
      ,@oldlatitude = latitude -- Added by Gadriwala Muslim 21112016  
      ,@oldlongitude = longitude -- Added by Gadriwala Muslim 21112016  
      ,@Oldcategory_id = category_id  
     -- ,@OldTraining_FromTime=Training_FromTime  
     -- ,@OldTraining_ToTime=Training_ToTime  
    from T0120_HRMS_TRAINING_APPROVAL WITH (NOLOCK) where cmp_id = @cmp_id and Training_Apr_ID = @Training_Apr_ID  
  --Added By Mukti 18082015(end)   
    
    --Added By Mukti(start)12082015  
     Delete from T0130_HRMS_TRAINING_EMPLOYEE_DETAIL   
       where cmp_id = @cmp_id and Training_Apr_ID = @Training_Apr_ID  
     Delete from T0130_HRMS_TRAINING_ALERT   
       where cmp_id = @cmp_id and Training_Apr_ID = @Training_Apr_ID  
                  
     Delete from T0152_Hrms_Training_Quest_Final   
       where cmp_id = @cmp_id and Training_Apr_ID = @Training_Apr_ID   
       
     DELETE FROM T0120_HRMS_TRAINING_Attachment   
          WHERE Training_Apr_ID = @Training_Apr_ID --17/04/2017  
            
                   
     select @Training_App_ID = Training_App_ID from T0120_HRMS_TRAINING_APPROVAL   
      where cmp_id = @cmp_id and Training_Apr_ID = @Training_Apr_ID  
        
     DELETE FROM T0120_HRMS_TRAINING_Schedule  
          WHERE Training_App_ID = @Training_App_ID --17/04/2017  
         
     Delete from T0120_HRMS_TRAINING_APPROVAL   
      where cmp_id = @cmp_id and Training_Apr_ID = @Training_Apr_ID  
      
     Delete from T0100_HRMS_TRAINING_APPLICATION   
      where cmp_id = @cmp_id and Training_App_ID = @Training_App_ID   
       
     --update T0100_HRMS_TRAINING_APPLICATION Set App_Status = 0  
     --Where cmp_id = @cmp_id and Training_App_ID = @Training_App_ID and isnull(Posted_Emp_ID,0) <> 0  
    --Added By Mukti(end)12082015  
    end  
   else if @flag=1  --for deleting from ess Training Plan  
    begin  
  --Added By Mukti 18082015(start)  
    select @OldLogin_ID=Login_ID  
      ,@OldTraining_id=Training_id  
      --,@OldTraining_Date=Training_Date  
      ,@OldPlace=Place  
      ,@OldFaculty=Faculty  
      ,@OldTraining_Pro_ID=Training_Pro_ID  
      ,@OldDescription=[Description]  
      ,@OldTraining_Cost=Training_Cost  
      ,@OldTraining_Cost_per_Emp=Training_Cost_per_Emp  
      ,@OldApr_Status=Apr_Status  
      --,@OldTraining_End_Date=Training_End_Date  
      ,@OldTraining_Type=Training_Type  
      ,@OldTraining_Leave_Type=Training_Leave_Type  
      --,@Oldno_of_day=no_of_day  
      ,@OldImpact_Salary=Impact_Salary  
      ,@Oldemp_feedback=emp_feedback  
      ,@OldSup_feedback=Sup_feedback  
      ,@OldComments=Comments  
      ,@Oldbranch_id=branch_id   
      ,@Olddept_id=dept_id   
      ,@Olddesig_id=desig_id    
      ,@Oldgrd_id=grd_id  
      ,@OldTraining_Code=Training_Code  
      ,@OldVideoURL = VideoURL   
      ,@oldlatitude = latitude -- Added by Gadriwala Muslim 21112016  
      ,@oldlongitude = longitude -- Added by Gadriwala Muslim 21112016  
      --,@OldTraining_FromTime=Training_FromTime  
      --,@OldTraining_ToTime=Training_ToTime  
    from T0120_HRMS_TRAINING_APPROVAL WITH (NOLOCK) where Training_Apr_ID = @Training_Apr_ID  
  --Added By Mukti 18082015(end)   
    
    --Added By Mukti(start)12082015  
     delete from T0150_HRMS_TRAINING_Answers   
      where cmp_id = @cmp_id and Tran_Emp_Detail_Id in   
       (select Tran_emp_Detail_ID from T0130_HRMS_TRAINING_EMPLOYEE_DETAIL WITH (NOLOCK)   
         where cmp_id = @cmp_id and Training_Apr_ID = @Training_Apr_ID)  
           
     Delete From T0140_HRMS_TRAINING_Feedback_New  
      where cmp_id = @cmp_id and Tran_Emp_Detail_Id in   
       (select Tran_emp_Detail_ID from T0130_HRMS_TRAINING_EMPLOYEE_DETAIL WITH (NOLOCK)  
         where cmp_id = @cmp_id and Training_Apr_ID = @Training_Apr_ID)  
           
     Delete from T0160_HRMS_Training_Questionnaire_Response   
        where cmp_id = @cmp_id and Training_Apr_ID = @Training_Apr_ID    
          
     Delete from T0150_HRMS_TRAINING_Answers   
        where cmp_id = @cmp_id and Training_Apr_ID = @Training_Apr_ID    
       
     Delete from T0150_EMP_Training_INOUT_RECORD   
        where cmp_id = @cmp_id and Training_Apr_ID = @Training_Apr_ID    
         
      
     Delete from T0130_HRMS_TRAINING_EMPLOYEE_DETAIL   
       where cmp_id = @cmp_id and Training_Apr_ID = @Training_Apr_ID  
     Delete from T0130_HRMS_TRAINING_ALERT   
       where cmp_id = @cmp_id and Training_Apr_ID = @Training_Apr_ID  
                  
     Delete from T0152_Hrms_Training_Quest_Final   
       where cmp_id = @cmp_id and Training_Apr_ID = @Training_Apr_ID   
       
     DELETE FROM T0120_HRMS_TRAINING_Attachment   
          WHERE Training_Apr_ID = @Training_Apr_ID --17/04/2017  
              
     select @Training_App_ID = Training_App_ID from T0120_HRMS_TRAINING_APPROVAL WITH (NOLOCK)  
      where cmp_id = @cmp_id and Training_Apr_ID = @Training_Apr_ID  
       
     DELETE FROM T0120_HRMS_TRAINING_Schedule  
          WHERE Training_App_ID = @Training_App_ID --17/04/2017  
         
     Delete from T0120_HRMS_TRAINING_APPROVAL   
      where cmp_id = @cmp_id and Training_Apr_ID = @Training_Apr_ID  
      
     Delete from T0100_HRMS_TRAINING_APPLICATION   
      where cmp_id = @cmp_id and Training_App_ID = @Training_App_ID   
       
     --update T0100_HRMS_TRAINING_APPLICATION Set App_Status = 0  
     --Where cmp_id = @cmp_id and Training_App_ID = @Training_App_ID and isnull(Posted_Emp_ID,0) <> 0  
    --Added By Mukti(end)12082015  
    end   
     
    --Added By Mukti 18082015(start)  
       set @OldValue = 'Old Value' + '#'+ 'Training Application ID :' + cast(Isnull(@Training_App_ID,0) as varchar(10)) + '#' +   
               'Training ID :' + cast(Isnull(@OldTraining_id,'') as varchar(10)) + '#' +   
            --   'Training Date :' + cast(Isnull(@OldTraining_Date,'') as varchar(30)) + '#' +   
               'Place :' + cast(Isnull(@OldPlace,'') as varchar(100)) + '#' +   
               'Faculty :' + cast(Isnull(@OldFaculty,'') as varchar(100)) + '#' +   
               'Provider ID :' + cast(Isnull(@OldTraining_Pro_ID,'') as varchar(100)) + '#' +   
               'Description :' + cast(Isnull(@OldDescription,'') as varchar(1000)) + '#' +   
               'Training Cost :' + cast(Isnull(@OldTraining_Cost,'') as varchar(20)) + '#' +   
                'Training Cost per Emp :' + cast(Isnull(@OldTraining_Cost_per_Emp,'') as varchar(15)) + '#' +   
                'Approval Status :' + cast(Isnull(@OldApr_Status,'') as varchar(20)) + '#' +   
             --   'Training End Date :' + cast(Isnull(@OldTraining_End_Date,'') as varchar(30)) + '#' +   
                'Training Type :' + cast(Isnull(@OldTraining_Type,'') as varchar(50)) + '#' +   
                'Training Leave Type :' + cast(Isnull(@OldTraining_Leave_Type,'') as varchar(50)) + '#' +   
             --   'No of days :' + cast(Isnull(@Oldno_of_day,'') as varchar(50)) + '#' +   
                'Impact Salary :' + cast(Isnull(@OldImpact_Salary,'') as varchar(50)) + '#' +   
                'Employee Feedback :' + cast(Isnull(@Oldemp_feedback,'') as varchar(50)) + '#' +   
                'Superior Feedback :' + cast(Isnull(@OldSup_feedback,'') as varchar(50)) + '#' +   
                'Comments :' + cast(Isnull(@OldComments,'') as varchar(500)) + '#' +  
                'Branch Id :' + cast(Isnull(@Oldbranch_id,'') as varchar(50)) + '#' +  
                'Dept id :' + cast(Isnull(@Olddept_id,'') as varchar(50)) + '#' +  
                'Desig id :' + cast(Isnull(@Olddesig_id,'') as varchar(50)) + '#' +  
                'Grd id :' + cast(Isnull(@Oldgrd_id,'') as varchar(50)) + '#' +  
                'Training Code :' + cast(Isnull(@OldTraining_Code,'') as varchar(50)) + '#' +  
                'Video URL :' + Isnull(@OldVideoURL,'') + '#' +  
                'latitude :' + cast(Isnull(@oldlatitude,0) as varchar(18)) + '#' +  
                'longitude :' + cast(Isnull(@oldlongitude,0) as varchar(18)) + '#'   
             --   'From Time :' + cast(Isnull(@OldTraining_FromTime,'') as varchar(50)) + '#' +  
             --   'To Time :' + cast(Isnull(@OldTraining_ToTime,'') as varchar(50))   
   --Added By Mukti 18082015(end)  
  end  
   
    
   exec P9999_Audit_Trail @Cmp_ID,@Trans_Type,'Training Plan/Approval',@OldValue,@Training_Apr_ID,@User_Id,@IP_Address  
  
 RETURN  