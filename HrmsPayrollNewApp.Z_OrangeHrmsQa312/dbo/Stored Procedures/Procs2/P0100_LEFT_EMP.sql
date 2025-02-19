  
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0100_LEFT_EMP]  
   @Left_ID numeric(18) output  
  ,@Cmp_ID numeric(18,0)  
  ,@Emp_ID numeric(18,0)  
  ,@Left_Date datetime  
  ,@Reg_Accept_Date datetime  
  ,@Left_Reason varchar(250)  
  ,@New_Employer varchar(100)  
  ,@Is_Terminate tinyint  
  ,@tran_type char(1)  
  ,@Uniform_Return numeric(18,0)  
  ,@Exit_Interview numeric(18,0)  
  ,@Notice_period numeric(18,2)  
  ,@Is_Death tinyint  
  ,@Reg_Date datetime  
  ,@Is_FnF_Applicable tinyint = 1 --Added by Hardik 19/10/2012  
  ,@RptManager_ID numeric(18,0) = 0 -- Added by Gadriwala 20112013  
  ,@IS_Retire numeric(18,0) = 0 -- Added by Nilesh Patel 15042015  
  ,@User_Id numeric(18,0) = 0   --Added By Mukti 29062016  
  ,@IP_Address varchar(30)= '' --Added By Mukti 29062016  
  ,@Request_Apr_ID numeric(18,0) = 0 --Added by nilesh patel on 21042017  
  ,@LeftReasonValue Varchar(500) = ''  
  ,@LeftReasonText Varchar(500) = ''  
  ,@Res_Id  int = 0  --Added By Jimit 25122018  
  ,@Is_Absconded tinyint = 0 --Added by Jaina 13-08-2020  
AS  
  
--Added By Mukti 29-06-2016(Start)  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
   
Declare @OldLeft_ID numeric(18,0)=0  
Declare @OldCmp_ID numeric(18,0)  
Declare @OldEmp_Id numeric(18,0)  
Declare @OldCmp_Name Varchar(500)  
Declare @OldEmp_Name Varchar(500)  
Declare @OldLeft_Date varchar(100)  
Declare @OldLeft_Reason varchar(250)  
Declare @OldNew_Employer varchar(100)  
Declare @OldReg_Accept_Date varchar(100)  
Declare @OldIs_Terminate varchar(10)  
Declare @OldUniform_Return varchar(10)  
Declare @OldExit_Interview varchar(10)  
Declare @OldNotice_period varchar(10)  
Declare @OldIs_Death varchar(10)  
Declare @OldReg_Date varchar(100)  
Declare @OldIs_FnF_Applicable varchar(10)  
Declare @OldRptManager_ID varchar(100)  
Declare @OldRptManager_Name varchar(100)  
Declare @OldIS_Retire varchar(10)  
Declare @OldValue varchar(max)  
Declare @Cmp_name varchar(500)  
Declare @Emp_name varchar(500)  
Declare @Is_Terminate_new varchar(10)  
Declare @Uniform_Return_new varchar(10)  
Declare @Exit_Interview_new varchar(10)  
Declare @Notice_period_new varchar(10)  
Declare @Is_Death_new varchar(10)  
Declare @Is_FnF_Applicable_new varchar(10)  
Declare @RptManager_name varchar(500)  
Declare @IS_Retire_new varchar(10)  
Declare @OldRes_Id Int  
Declare @Is_Absconded_New varchar(10)  
Declare @Old_IsAbsconded varchar(10)  
  
Declare @Old_LeftReasonValue Varchar(500)  
Declare @Old_LeftReasonText Varchar(500)  
set @OldLeft_ID = 0  
set @OldCmp_ID = 0  
Set @OldEmp_Id = 0  
set @OldCmp_Name = ''  
set @OldEmp_Name= ''  
set @OldLeft_Date = ''  
set @OldLeft_Reason = ''  
set @OldNew_Employer = ''  
set @OldReg_Accept_Date = ''  
set @OldIs_Terminate =0  
set @OldUniform_Return = 0  
set @OldExit_Interview = 0  
set @OldNotice_period = 0  
set @OldIs_Death = 0  
set @OldReg_Date = ''  
set @OldIs_FnF_Applicable = 0   
set @OldRptManager_ID = 0    
set @OldIS_Retire = 0    
set @OldValue =''  
set @Cmp_name=''  
set @Emp_name=''  
set @Is_Terminate_new=''  
set @Uniform_Return_new=''  
set @Exit_Interview_new=''  
set @Notice_period_new=''  
set @Is_Death_new=''  
set @Is_FnF_Applicable_new=''  
set @RptManager_name = ''  
set @IS_Retire_new =''  
Set @Old_LeftReasonValue = ''  
set @Old_LeftReasonText = ''  
Set @OldRes_Id = 0  
set @Is_Absconded_New = ''  
set @Old_IsAbsconded = ''  
--Added By Mukti 29-06-2016(End)    
  
  if isnull(@Reg_Accept_Date,'') = ''  
   set @Reg_Accept_Date = null  
  declare @New_R_Emp_id as numeric   
  set @New_R_Emp_id = 0 -- Added by Gadriwala 20112013  
    
  Declare @Effect_Date DATETIME   --Ankit 11022015  
  DECLARE @Row_ID   NUMERIC(18,0) --Ankit 11022015  
  DECLARE @Desig_ID  Numeric(18,0) --Ankit 11022015  
  SET @Row_ID = 0  
  SET @Desig_ID = 0  
  
   set @Left_Reason = dbo.fnc_ReverseHTMLTags(@Left_Reason)  --added by Ronak 271021
    
  If @tran_type ='I'   
   begin  
   if exists (Select Left_ID  from T0100_LEFT_EMP WITH (NOLOCK) Where Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID)   
    begin  
     set @Left_ID=0  
    end  
   else  
    begin  
     IF @Left_Reason <> 'Default Company Transfer' /* Company Transfer Then Unable to Check Salary Exists Condtion --Ankit 03122015 */  
      BEGIN  
       If exists(Select Sal_Tran_Id From T0200_MONTHLY_SALARY WITH (NOLOCK) Where Month_St_Date <= @Left_Date And Month_End_Date > @Left_Date and Emp_ID = @Emp_ID)  
        Begin  
         Raiserror ('Salary Already Exists',16,2)  
         Return -1  
        End  
      END  
    
     Select @Left_ID = isnull(max(Left_ID),0) + 1  from T0100_LEFT_EMP WITH (NOLOCK)  
    
     Insert Into T0100_LEFT_EMP  
      (Left_ID,Cmp_ID,Emp_ID,Left_Date,Left_Reason ,New_Employer,Reg_Accept_Date,Is_Terminate,  
       Uniform_Return,Exit_Interview,Notice_Period,Is_Death,Reg_Date,Is_FnF_Applicable,Rpt_Manager_ID,Is_Retire,Request_Apr_ID,LeftReasonValue,LeftReasonText  
        ,Res_Id,Is_Absconded)  
     values  
      (@Left_ID,@Cmp_ID,@Emp_ID,@Left_Date,@Left_Reason ,@New_Employer,@Reg_Accept_Date,@Is_Terminate,  
       @Uniform_Return,@Exit_Interview,@Notice_Period,@Is_Death,@Reg_Date,@Is_FnF_Applicable,@RptManager_ID,@IS_Retire,@Request_Apr_ID,@LeftReasonValue,@LeftReasonText  
       ,@Res_Id,@Is_Absconded)  
       
       
     UPDATE T0080_EMP_MASTER   
      SET EMP_LEFT  = 'Y' , EMP_LEFT_DATE = @LEFT_DATE--, Enroll_No = 0 -- Commented by Hardik 30/09/2015 as per Ankurbhai's instruction for Havmor  
      ,System_date = getdate() --,is_for_mobile_Access=0  --Commneted by Niraj for Unison (29062022)
      ,System_Date_Join_left = getdate() ---Enroll no Blank add by Hasmukh 19122013  
     WHERE EMP_ID = @EMP_ID  
       
     --Exec SP_Left_Notification_Mail @Cmp_ID,@EMP_ID,@Left_Date  
       
     If isnull(@RptManager_ID,0) <> 0    
     begin  
      -- Added by Gadriwala 20112013 - Start  
      insert into T0090_EMP_REPORTING_DETAIL_REPLACE_HISTORY(Emp_id,Old_R_Emp_id,New_R_Emp_id,Cmp_id,Change_date,Comment)  
      select emp_ID,R_Emp_ID,@RptManager_ID,Cmp_ID,GETDATE(),'Left' from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) where  R_Emp_ID = @Emp_ID  
        
      --Update T0090_EMP_REPORTING_DETAIL   
      --set  R_Emp_ID = @RptManager_ID where R_Emp_ID = @Emp_ID   
      -- Added by Gadriwala 20112013 - End  
        
      -- Insert New reporting Manger Update Scheme Detail As selected Reporting Manager --Ankit 11022015  
      --added by jimit 12012017  
      DECLARE @NEW_CMP_ID AS NUMERIC  
      SELECT @NEW_CMP_ID = CMP_ID FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE EMP_ID = @RPTMANAGER_ID  
        
      IF @NEW_EMPLOYER = '' --ADDED BY RAMIZ ON 01/03/2017; WHEN @NEW_EMPLOYER IS "" , THEN SAME COMPANY ID WILL BE INSERTED  
       SET @NEW_EMPLOYER = @NEW_CMP_ID    
      --ended  
        
        
      select @Row_ID = isnull(max(Row_ID),0) + 1 from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)  
      SELECT @Row_ID + ROW_NUMBER() Over (order by Row_ID) as Row_ID,ERD.Emp_ID,@RptManager_ID R_Emp_ID, Cmp_ID, Reporting_To,--Reporting_Method  
        (CASE @NEW_CMP_ID WHEN @New_Employer THEN 'Direct' ELSE 'InDirect' END) AS REPORTING_METHOD  --added by jimit 12012017  
        ,@Left_Date Effect_Date  
      INTO #REPORTING_DETAIL  
      FROM T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)  
        INNER JOIN (SELECT MAX(Effect_Date) AS Effect_Date, Emp_ID   
            FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)  
            WHERE Effect_Date<=@Left_Date  
            GROUP BY emp_ID) RQry ON  ERD.Emp_ID = RQry.Emp_ID and ERD.Effect_Date = RQry.Effect_Date  
      WHERE ERD.R_Emp_ID = @Emp_ID   
        AND NOT EXISTS(SELECT 1 FROM T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)  
            WHERE ERD1.R_Emp_ID = @RptManager_ID and ERD1.Effect_Date = @Left_Date AND ERD1.EMP_ID=ERD.EMP_ID  
              AND ERD1.Effect_Date=ERD.Effect_Date )  
      ORDER BY ERD.Effect_Date  
        
        
          
      --IF NOT EXISTS(select Row_ID from T0090_EMP_REPORTING_DETAIL WHERE R_Emp_ID = @RptManager_ID and Effect_Date = @Left_Date)  
      IF EXISTS(SELECT 1 FROM #REPORTING_DETAIL)  
       BEGIN  
        --SELEcT  * FROm #REPORTING_DETAIL  
        --select @Row_ID = isnull(max(Row_ID),0) + 1 from T0090_EMP_REPORTING_DETAIL  
          
        INSERT INTO T0090_EMP_REPORTING_DETAIL  
        SELECT * FROM #REPORTING_DETAIL  
        --INSERT INTO T0090_EMP_REPORTING_DETAIL  
        --SELECT @Row_ID + ROW_NUMBER() Over (order by Row_ID) as Row_ID,ERD.Emp_ID,@RptManager_ID, Cmp_ID, Reporting_To,--Reporting_Method  
        --(CASE @NEW_CMP_ID WHEN @New_Employer THEN 'Direct' ELSE 'InDirect' END) AS REPORTING_METHOD  --added by jimit 12012017  
        --,@Left_Date  
        --FROM T0090_EMP_REPORTING_DETAIL ERD INNER JOIN   
        -- (SELECT MAX(Effect_Date) as Effect_Date, Emp_ID from T0090_EMP_REPORTING_DETAIL  
        --  WHERE Effect_Date<=@Left_Date  
        --  GROUP BY emp_ID) RQry on  ERD.Emp_ID = RQry.Emp_ID and ERD.Effect_Date = RQry.Effect_Date  
        --WHERE ERD.R_Emp_ID = @Emp_ID  
        --ORDER BY ERD.Effect_Date  
                  
       END  
         
         
         
      INSERT INTO T0051_Scheme_Detail_History  --Insert scheme detail Record For History  
      SELECT @Cmp_ID, Scheme_Detail_Id,App_Emp_ID,@RptManager_ID ,getdate() As system_Date   
      FROM T0050_Scheme_Detail WITH (NOLOCK) WHERE Is_RM = 0 AND App_Emp_ID = @Emp_ID ORDER BY Scheme_Detail_Id  
        
      --SELECT  @Desig_ID = Desig_ID FROM dbo.T0095_Increment I INNER JOIN       
      --   ( SELECT max(Increment_ID) AS Increment_ID , Emp_ID FROM dbo.T0095_Increment      
      --  WHERE Increment_Effective_date <= GETDATE() and Cmp_ID = @Cmp_ID And Emp_ID = @RptManager_ID GROUP BY emp_ID  
      -- ) Qry on I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID   
      --WHERE I.Emp_ID = @RptManager_ID   
      SELECT  @Desig_ID = Desig_ID FROM dbo.T0095_Increment I WITH (NOLOCK) INNER JOIN       
          (SELECT MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID  
            FROM T0095_INCREMENT I2 WITH (NOLOCK)  
            INNER JOIN (SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID  
               FROM T0095_INCREMENT I3 WITH (NOLOCK)  WHERE I3.Increment_Effective_Date <= GETDATE() and Cmp_ID = @Cmp_ID and Emp_ID=ISNULL(@RptManager_ID, Emp_ID)  
               GROUP BY I3.Emp_ID  
               ) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID                     
          WHERE I2.Cmp_ID = @Cmp_Id and Cmp_ID = @Cmp_ID and I2.Emp_ID=ISNULL(@RptManager_ID, I2.Emp_ID)  
          GROUP BY I2.Emp_ID  
          ) I2 ON I.Emp_ID=I2.Emp_ID AND I.Increment_ID=I2.INCREMENT_ID   
      WHERE I.Emp_ID = @RptManager_ID --Changed by Sumit on 24012017  
      ------added jimit 31122015----  
      DECLARE @R_CMP_ID NUMERIC   
        
        
      SELECT @R_CMP_ID = CMP_ID FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE EMP_ID = @RPTMANAGER_ID  
       
         
        
      -------ended-------------  
                       
      --UPDATE T0050_Scheme_Detail --Update Reporting Manger  
      --SET App_Emp_ID = @RptManager_ID ,R_Desg_Id = (CASE WHEN @R_CMP_ID <> @CMP_ID THEN 0 ELSE @DESIG_ID END)  
      -- ,R_Cmp_Id = @R_Cmp_Id                                     ------added jimit 31122015----  
      --WHERE Is_RM = 0 AND App_Emp_ID = @Emp_ID  
      if (@Emp_ID <> 0)  
       Begin  
        UPDATE T0050_Scheme_Detail --Update Reporting Manger  
        SET App_Emp_ID = @RptManager_ID ,R_Desg_Id = (CASE WHEN @R_CMP_ID <> @CMP_ID THEN 0 ELSE @DESIG_ID END)  
         ,R_Cmp_Id = @R_Cmp_Id                                     ------added jimit 31122015----  
        WHERE Is_RM = 0 AND App_Emp_ID = @Emp_ID  --Changed by Rohit Bhai 20102016-- Sumit   
       End  
        
        
      UPDATE T0080_EMP_MASTER   
      SET  Emp_Superior = @RptManager_ID  
      WHERE   Emp_Superior = @Emp_ID  
      -- Update Scheme Detail As selected Reporting Manager --Ankit 11022015  
     end  
       
     -- Added by Ali 28112013 - Start  
     UPDATE T0011_LOGIN SET Login_Alias  = '' WHERE EMP_ID = @EMP_ID  
     -- Added by Ali 28112013 - End  
       
     --If Employee is Inactive , then we will make it Active , as it was showing InCorrect Count of Inactive Employee on Home Page ( Ramiz - 25/06/2018 )  
     UPDATE T0011_LOGIN   
     SET Is_Active = 1  
     WHERE EMP_ID = @EMP_ID AND Is_Active = 0  
                
    end   
      
    --added jimit 04112015  
     if @Left_Reason = 'Default Company Transfer'   
      BEGIN  
       UPDATE T0080_EMP_MASTER  
       SET Enroll_No = 0 where Cmp_ID = @Cmp_Id AND Emp_ID = @emp_id  
      END       
     --ended  
       
    --Added By Mukti 29-06-2016(Start)Audit Trail      
     select @Cmp_Name = Cmp_Name from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_Id   
     select @Emp_name = Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@Emp_Id and Cmp_ID= @Cmp_id  
     select @RptManager_name = Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@RptManager_ID and Cmp_ID= @Cmp_id  
       
     If @Is_Terminate = 1   
      set @Is_Terminate_new = 'Yes'  
     Else  
      set @Is_Terminate_new = 'No'  
        
     if @Uniform_Return =1  
      set @Uniform_Return_new = 'Yes'  
     else  
      set @Uniform_Return_new = 'No'  
        
     IF @Exit_Interview =1  
      set @Exit_Interview_new = 'Yes'  
     else  
      set @Exit_Interview_new = 'No'  
  
     IF @Notice_period = 1  
      set @Notice_period_new='Yes'  
     Else  
      set @Notice_period_new='No'  
        
     IF @Is_Death = 1  
      set @Is_Death_new='Yes'  
     Else  
      set @Is_Death_new='No'  
        
     IF @Is_FnF_Applicable = 1  
      set @Is_FnF_Applicable_new='Yes'  
     Else  
      set @Is_FnF_Applicable_new='No'  
        
     If @IS_Retire = 1  
      set @IS_Retire_new ='Yes'  
     Else  
      set @IS_Retire_new ='No'  
               
     If @Is_Absconded = 1  
      set @Is_Absconded_New = 'Yes'  
     Else  
      set @Is_Absconded_New= 'No'  
     Set @OldValue = 'New Value' + '#' + 'Company : '+ isnull(@Cmp_Name ,'') +   
            + '#' + 'Employee : '+ isnull(@Emp_Name , '' ) +  
            + '#' + 'Left Date : '+ cast(ISNULL(@Left_Date,'') as varchar(50))+  
            + '#' + 'Resignation Date :' +cast(ISNULL(@Reg_Date,'') as varchar(50))+  
            + '#' + 'Resignation Accepted Date :' +cast(ISNULL(@Reg_Accept_Date,'') as varchar(50))+  
            + '#' + 'Left Reason :' + isnull(@Left_Reason,'')+  
            + '#' + 'Replace Reporting Manager :'+ isnull(@RptManager_name,'')+  
            + '#' + 'New Employer :' + isnull(@New_Employer,'')+  
            + '#' + 'Is Terminate :' + isnull(@Is_Terminate_new,'')+  
            + '#' + 'Uniform Return :'+ isnull(@Uniform_Return_new,'')+  
            + '#' + 'Exit Interview :'+ isnull(@Exit_Interview_new,'')+  
            + '#' + 'Notice Period :'+isnull(@Notice_period_new,'')+  
            + '#' + 'Is Death :' + isnull(@Is_Death_new,'')+              
            + '#' + 'In FNF Applicable :'+ isnull(@Is_FnF_Applicable_new,'')+               
            + '#' + 'Is Retire : ' + isnull(@IS_Retire_new,'')+  
            + '#' + 'LeftReasonValue : '  + isnull(@LeftReasonValue,'')+  
            + '#' + 'LeftReasonText : '  + isnull(@LeftReasonText,'') +  
            + '#' + 'Res_Id : ' + Cast(@Res_Id as varchar(5)) +   
            + '#' + 'Is Absconded :' + isnull(@Is_Absconded_New,'')+            '#'  
    --Added By Mukti 29-06-2016(end)Audit Trail           
   end  
  else if @tran_type ='U'   
   begin  
    --Added By Mukti 29-06-2016(start)Audit Trail   
     SELECT @OldLeft_ID = Left_ID,  
       @OldCmp_ID = Cmp_ID,  
       @OldEmp_ID = Emp_ID,  
       @OldLeft_Date = Left_Date,  
       @OldReg_Accept_Date = Reg_Accept_Date,  
       @OldLeft_Reason = Left_Reason,  
       @OldNew_Employer = New_Employer,  
       @OldIs_Terminate = case when isnull(Is_Terminate,0) = 1 then 'YES' ELSE 'NO' end,  
       @OldUniform_Return = case when isnull(Uniform_Return,0) = 1 THEN 'YES' ELSE 'NO' END,  
       @OldExit_Interview = case when isnull(Exit_Interview,0) = 1 THEN 'YES' ELSE 'NO' END,  
       @OldNotice_period = case when isnull(Notice_Period,0) = 1 THEN 'YES' ELSE 'NO' END,  
       @OldIs_Death =CASE WHEN ISNULL(Is_Death,0) =1 THEN 'YES' ELSE 'NO' END,  
       @OldReg_Date = Reg_Date,  
       @OldIs_FnF_Applicable = case when ISNULL(Is_FnF_Applicable,0) =1 THEN 'YES' ELSE 'NO' END,   
       @OldRptManager_ID = Rpt_Manager_ID,   
       @OldIS_Retire = case when isnull(Is_Retire,0) = 1 THEN 'YES' ELSE 'NO' END,  
       @Old_LeftReasonText = LeftReasonText,  
       @Old_LeftReasonValue = @LeftReasonValue,  
       @OldRes_Id = @Res_Id,  
       @Old_IsAbsconded = Is_Absconded  
     FROM T0100_LEFT_EMP WITH (NOLOCK) where Emp_ID=@Emp_ID and Cmp_ID = @Cmp_Id  
            
     select @OldCmp_Name = Cmp_Name from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id = @OldCmp_ID  
     select @OldEmp_Name = Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@OldEmp_Id and Cmp_Id = @Cmp_Id   
     select @OldRptManager_Name = Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@OldRptManager_ID and Cmp_Id = @Cmp_Id   
   
     select @Cmp_Name = Cmp_Name from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_Id   
     select @Emp_name = Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@Emp_Id and Cmp_Id = @Cmp_Id   
     select @RptManager_name = Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@RptManager_ID and Cmp_ID= @Cmp_id  
       
     --New Value  
     If @Is_Terminate = 1   
      set @Is_Terminate_new = 'Yes'  
     Else  
      set @Is_Terminate_new = 'No'  
        
     if @Uniform_Return =1  
      set @Uniform_Return_new = 'Yes'  
     else  
      set @Uniform_Return_new = 'No'  
        
     IF @Exit_Interview =1  
      set @Exit_Interview_new = 'Yes'  
     else  
      set @Exit_Interview_new = 'No'  
  
     IF @Notice_period = 1  
      set @Notice_period_new='Yes'  
     Else  
      set @Notice_period_new='No'  
        
     IF @Is_Death = 1  
      set @Is_Death_new='Yes'  
     Else  
      set @Is_Death_new='No'  
        
     IF @Is_FnF_Applicable = 1  
      set @Is_FnF_Applicable_new='Yes'  
     Else  
      set @Is_FnF_Applicable_new='No'  
        
     If @IS_Retire = 1  
      set @IS_Retire_new ='Yes'  
     Else  
      set @IS_Retire_new ='No'  
  
     If @Is_Absconded = 1  
      set @Is_Absconded_New = 'Yes'  
     else  
      set @Is_Absconded_New = 'No'  
  
   --Added By Mukti 29-06-2016(end)Audit Trail    
      
    Update T0100_LEFT_EMP   
    Set   
     Left_Reason = @Left_Reason ,  
     New_Employer= @New_Employer,  
     Left_Date = @Left_Date,  
     Reg_Accept_Date= @Reg_Accept_Date,  
     Is_Terminate = @Is_Terminate,  
     Uniform_Return=@Uniform_Return,  
     Exit_Interview=@Exit_Interview,  
     Notice_Period=@Notice_Period,  
     Is_Death=@Is_Death,  
     Reg_Date =@Reg_Date,  
     Is_FnF_Applicable=@Is_FnF_Applicable,  
     Rpt_Manager_ID = @RptManager_ID,  
     Is_Retire = @IS_Retire,  
     --added by chetan 030817  
     LeftReasonValue = @LeftReasonValue,  
     LeftReasonText = @LeftReasonText,  
     Res_Id = @Res_Id,  
     Is_Absconded = @Is_Absconded  
    where Left_ID = @Left_ID and Cmp_ID = @Cmp_ID   
      
    UPDATE T0080_EMP_MASTER   
    SET EMP_LEFT  = 'Y' , EMP_LEFT_DATE = @LEFT_DATE,is_for_mobile_Access = 0  
    ,System_date = getdate()  
    ,System_Date_Join_left = getdate()  
    WHERE EMP_ID = @EMP_ID  
       
    -- Added by Gadriwala 20112013 - Start  
    If isnull(@RptManager_ID,0) <> 0    
     BEGIN  
      select @New_R_Emp_id = New_R_Emp_id from T0090_EMP_REPORTING_DETAIL_REPLACE_HISTORY WITH (NOLOCK) where  Old_R_Emp_id = @Emp_ID  
        
      UPDATE T0090_EMP_REPORTING_DETAIL   
      SET  R_Emp_ID = @RptManager_ID ,Effect_date = @Left_Date  
      WHERE R_Emp_ID = @New_R_Emp_id  
         
      Update T0090_EMP_REPORTING_DETAIL_REPLACE_HISTORY set New_R_Emp_id = @RptManager_ID, Change_date = GETDATE()  where Old_R_Emp_id = @Emp_ID  
        
      --SELECT  @Desig_ID = Desig_ID FROM dbo.T0095_Increment I INNER JOIN       
      --   ( SELECT max(Increment_ID) AS Increment_ID , Emp_ID FROM dbo.T0095_Increment      
      --  WHERE Increment_Effective_date <= GETDATE() and Cmp_ID = @Cmp_ID And Emp_ID = @RptManager_ID GROUP BY emp_ID  
      -- ) Qry on I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID   
      --WHERE I.Emp_ID = @RptManager_ID   
      SELECT  @Desig_ID = Desig_ID FROM dbo.T0095_Increment I WITH (NOLOCK) INNER JOIN  
          (SELECT MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID  
            FROM T0095_INCREMENT I2 WITH (NOLOCK)  
            INNER JOIN (SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID  
               FROM T0095_INCREMENT I3 WITH (NOLOCK) WHERE I3.Increment_Effective_Date <= GETDATE() and Cmp_ID = @Cmp_ID and Emp_ID=ISNULL(@RptManager_ID, Emp_ID)  
               GROUP BY I3.Emp_ID  
               ) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID                     
          WHERE I2.Cmp_ID = @Cmp_Id and Cmp_ID = @Cmp_ID and I2.Emp_ID=ISNULL(@RptManager_ID, I2.Emp_ID)  
          GROUP BY I2.Emp_ID  
          ) I2 ON I.Emp_ID=I2.Emp_ID AND I.Increment_ID=I2.INCREMENT_ID           
      WHERE I.Emp_ID = @RptManager_ID --Changed by Sumit on 24012017  
        
      if(@Emp_ID<>0)  --Changed by Sumit on 20102016  
       Begin  
        UPDATE T0050_Scheme_Detail --Update Reporting Manger  
        SET App_Emp_ID = @RptManager_ID ,R_Desg_Id = @Desig_ID   
        WHERE Is_RM = 0 AND App_Emp_ID IN ( SELECT New_App_Emp_ID From T0051_Scheme_Detail_History WITH (NOLOCK) WHERE Old_App_Emp_ID = @Emp_ID)   
          
        Update T0051_Scheme_Detail_History  
        SET New_App_Emp_ID = @RptManager_ID , System_date = GETDATE()  
        WHERE New_App_Emp_ID IN ( SELECT New_App_Emp_ID From T0051_Scheme_Detail_History WITH (NOLOCK) WHERE Old_App_Emp_ID = @Emp_ID)        
       End  
                 
      --UPDATE T0050_Scheme_Detail --Update Reporting Manger  
      --SET App_Emp_ID = @RptManager_ID ,R_Desg_Id = @Desig_ID   
      --WHERE Is_RM = 0 AND App_Emp_ID IN ( SELECT New_App_Emp_ID From T0051_Scheme_Detail_History WHERE Old_App_Emp_ID = @Emp_ID)  
        
      --Update T0051_Scheme_Detail_History  
      --SET New_App_Emp_ID = @RptManager_ID , System_date = GETDATE()  
      --WHERE New_App_Emp_ID IN ( SELECT New_App_Emp_ID From T0051_Scheme_Detail_History WHERE Old_App_Emp_ID = @Emp_ID)  
        
      UPDATE T0080_EMP_MASTER   
      SET  Emp_Superior = @RptManager_ID  
      WHERE   Emp_Superior = @Emp_ID  
        
     END  
    -- Added by Gadriwala 20112013 - End  
      
    -- Added by Ali 28112013 - Start  
    UPDATE T0011_LOGIN SET Login_Alias  = '' WHERE EMP_ID = @EMP_ID  
    -- Added by Ali 28112013 - End  
      
    --If Employee is Inactive , then we will make it Active , as it was showing InCorrect Count of Inactive Employee on Home Page ( Ramiz - 25/06/2018 )  
     UPDATE T0011_LOGIN   
     SET Is_Active = 1  
     WHERE EMP_ID = @EMP_ID AND Is_Active = 0  
       
    --Added By Mukti 29-06-2016(start)Audit Trail    
    Set @OldValue = 'Old Value' + '#' + 'Company : '+ isnull(@OldCmp_Name ,'') +   
            + '#' + 'Employee : '+ isnull(@OldEmp_Name , '' ) +  
            + '#' + 'Left Date : '+ isnull(@OldLeft_Date,'') +''  
            + '#' + 'Resignation Date :' + isnull(@OldReg_Date,'')+  
            + '#' + 'Resignation Accepted Date :' + isnull(@OldReg_Accept_Date,'')+  
            + '#' + 'Left Reason :' + isnull(@OldLeft_Reason,'')+  
            + '#' + 'Replace Reporting Manager :'+ isnull(@OldRptManager_Name,'')+  
            + '#' + 'New Employer :' + isnull(@OldNew_Employer,'')+  
            + '#' + 'Is Terminate :' + isnull(@OldIs_Terminate,'')+  
            + '#' + 'Uniform Return :'+ isnull(@OldUniform_Return,'')+  
            + '#' + 'Exit Interview :'+ isnull(@OldExit_Interview,'')+  
            + '#' + 'Notice Period :'+isnull(@OldNotice_period,'')+  
            + '#' + 'Is Death :' + isnull(@OldIs_Death,'')+              
            + '#' + 'In FNF Applicable :'+ isnull(@OldIs_FnF_Applicable,'')+               
            + '#' + 'Is Retire : ' + isnull(@OldIS_Retire,'')+  
            + '#' + 'LeftReasonValue : '  + isnull(@Old_LeftReasonValue,'')+  
            + '#' + 'LeftReasonText : '  + isnull(@Old_LeftReasonText,'') +  
            + '#' + 'Res_Id : '  + Cast(@OldRes_Id as Varchar(5)) +  
            + '#' + 'Is Absconded :' + isnull(@Old_IsAbsconded,'')+  
         'New Value' + '#' + 'Company : '+ isnull(@Cmp_Name ,'') +   
            + '#' + 'Employee : '+ isnull(@Emp_Name , '' ) +  
            + '#' + 'Left Date : '+ cast(ISNULL(@Left_Date,'') as varchar(50))+  
            + '#' + 'Resignation Date :' +cast(ISNULL(@Reg_Date,'') as varchar(50))+  
            + '#' + 'Resignation Accepted Date :' +cast(ISNULL(@Reg_Accept_Date,'') as varchar(50))+  
            + '#' + 'Left Reason :' + isnull(@Left_Reason,'')+  
            + '#' + 'Replace Reporting Manager :'+ isnull(@RptManager_name,'')+  
            + '#' + 'New Employer :' + isnull(@New_Employer,'')+  
            + '#' + 'Is Terminate :' + isnull(@Is_Terminate_new,'')+  
            + '#' + 'Uniform Return :'+ isnull(@Uniform_Return_new,'')+  
            + '#' + 'Exit Interview :'+ isnull(@Exit_Interview_new,'')+  
            + '#' + 'Notice Period :'+isnull(@Notice_period_new,'')+  
            + '#' + 'Is Death :' + isnull(@Is_Death_new,'')+              
            + '#' + 'In FNF Applicable :'+ isnull(@Is_FnF_Applicable_new,'')+              
            + '#' + 'Is Retire : ' + isnull(@IS_Retire_new,'')+  
            + '#' + 'LeftReasonValue : '  + isnull(@LeftReasonValue,'')+  
            + '#' + 'LeftReasonText : '  + isnull(@LeftReasonText,'') +  
            + '#' + 'Res_Id : '  + Cast(@Res_Id as Varchar(5)) +  
            + '#' + 'Is Absconded :' + isnull(@Is_Absconded_New,'')+'#'   
    --Added By Mukti 29-06-2016(end)Audit Trail    
   end   
 Else If @tran_type ='D'  
   Begin     
      
    if not exists(select Sal_Tran_ID from T0200_MONTHLY_SALARY WITH (NOLOCK) where Is_FNF = 1 and Emp_ID = @Emp_ID)  
     begin  
      --Select @Left_ID  
      -- Added by Gadriwala 20112013 - Start  
      If exists(SELECT 1 from T0100_LEFT_EMP WITH (NOLOCK) where Left_ID = @Left_ID and Request_Apr_ID <> @Request_Apr_ID)  
       Begin  
        --Raiserror ('Employee Left from Absconding so please delete abscoding details',16,2)  
        set @Left_ID = 0  
        return  
       End  
         
      SELECT @Effect_Date= Left_Date,@RptManager_ID = Rpt_Manager_ID from T0100_LEFT_EMP WITH (NOLOCK) where Left_ID = @Left_ID   
      --Comment By Jaina 18-11-2016  
      --Update T0090_EMP_REPORTING_DETAIL   
      --set  R_Emp_ID = @Emp_ID ,Effect_Date = @Effect_Date  
      --where Emp_ID in (select Emp_ID from T0090_EMP_REPORTING_DETAIL_REPLACE_HISTORY where  Old_R_Emp_id = @Emp_ID)  
      -- And Effect_Date = @Effect_Date  
        
      --Added by Jaina 18-11-2016             
      DELETE FROM T0090_EMP_REPORTING_DETAIL WHERE CMP_ID=@CMP_ID AND R_EMP_ID = @RPTMANAGER_ID AND EFFECT_DATE = @EFFECT_DATE  
      DELETE from T0090_EMP_REPORTING_DETAIL_REPLACE_HISTORY where Old_R_Emp_id = @Emp_ID  
      -- Added by Gadriwala 20112013 - End  
        
      UPDATE T0080_EMP_MASTER   
      SET  Emp_Superior = @Emp_ID  
      WHERE   Emp_Superior = @RptManager_ID  
       
       
      SELECT  @Desig_ID = Desig_ID FROM dbo.T0095_Increment I WITH (NOLOCK) INNER JOIN       
         ( SELECT max(Increment_ID) AS Increment_ID , Emp_ID FROM dbo.T0095_Increment  WITH (NOLOCK)     
        WHERE Increment_Effective_date <= GETDATE() and Cmp_ID = @Cmp_ID And Emp_ID = @RptManager_ID GROUP BY emp_ID  
       ) Qry on I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID   
      WHERE I.Emp_ID = @Emp_ID   
  
                 
      UPDATE T0050_Scheme_Detail --Update Reporting Manger  
      SET App_Emp_ID = @Emp_ID ,R_Desg_Id = @Desig_ID   
      --WHERE Is_RM = 0 AND App_Emp_ID = @RptManager_ID --Commented by Hardik 30/12/2017, it was replacing RM to RM also  
      WHERE App_Emp_ID > 0 AND App_Emp_ID = @RptManager_ID  
        
      --And App_Emp_ID IN ( SELECT New_App_Emp_ID From T0051_Scheme_Detail_History WHERE  )  
        
        
      DELETE FROM T0051_Scheme_Detail_History WHERE Old_App_Emp_ID = @Emp_ID  
      DELETE FROM T9999_ABSCONDING_MAIL_HISTORY WHERE Emp_ID = @Emp_ID --Added by Ramiz on 24/05/2017  
      --Ankit 11022015  
              
     --Added By Mukti 29-06-2016(start)Audit Trail          
      SELECT @OldLeft_ID = Left_ID,  
       @OldCmp_ID = Cmp_ID,  
       @OldEmp_ID = Emp_ID,  
       @OldLeft_Date = Left_Date,  
       @OldReg_Accept_Date = Reg_Accept_Date,  
       @OldLeft_Reason = Left_Reason,  
       @OldNew_Employer = New_Employer,  
       @OldIs_Terminate = case when isnull(Is_Terminate,0) = 1 then 'YES' ELSE 'NO' end,  
       @OldUniform_Return = case when isnull(Uniform_Return,0) = 1 THEN 'YES' ELSE 'NO' END,  
       @OldExit_Interview = case when isnull(Exit_Interview,0) = 1 THEN 'YES' ELSE 'NO' END,  
       @OldNotice_period = case when isnull(Notice_Period,0) = 1 THEN 'YES' ELSE 'NO' END,  
       @OldIs_Death =CASE WHEN ISNULL(Is_Death,0) =1 THEN 'YES' ELSE 'NO' END,  
       @OldReg_Date = Reg_Date,  
       @OldIs_FnF_Applicable = case when ISNULL(Is_FnF_Applicable,0) =1 THEN 'YES' ELSE 'NO' END,   
       @OldRptManager_ID = Rpt_Manager_ID,   
       @OldIS_Retire = case when isnull(Is_Retire,0) = 1 THEN 'YES' ELSE 'NO' END,  
       @Old_IsAbsconded = case when isnull(Is_Absconded,0) = 1 THEN 'YES' ELSE 'NO' END  
     FROM T0100_LEFT_EMP WITH (NOLOCK) where Emp_ID=@Emp_ID and Cmp_ID = @Cmp_Id  
       
     select @OldCmp_Name = Cmp_Name from T0010_COMPANY_MASTER WITH (NOLOCK)  where Cmp_Id = @OldCmp_ID  
     select @OldEmp_Name = Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@OldEmp_Id and Cmp_Id = @Cmp_Id   
     select @OldRptManager_Name = Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@OldRptManager_ID and Cmp_Id = @Cmp_Id   
    --Added By Mukti 29-06-2016(end)Audit Trail    
        
        
      delete  from T0100_LEFT_EMP where Left_ID = @Left_ID   
        
    --Added By Mukti 29-06-2016(start)Audit Trail       
      UPDATE T0080_EMP_MASTER   
      SET EMP_LEFT  = 'N' , EMP_LEFT_DATE = null  
      WHERE EMP_ID = @EMP_ID  
        
      Set @OldValue = 'Old Value' + '#' + 'Company : '+ isnull(@OldCmp_Name ,'') +   
            + '#' + 'Employee : '+ isnull(@OldEmp_Name , '' ) +  
            + '#' + 'Left Date : '+ isnull(@OldLeft_Date,'') +''  
            + '#' + 'Resignation Date :' + isnull(@OldReg_Date,'')+  
            + '#' + 'Resignation Accepted Date :' + isnull(@OldReg_Accept_Date,'')+  
            + '#' + 'Left Reason :' + isnull(@OldLeft_Reason,'')+  
            + '#' + 'Replace Reporting Manager :'+ isnull(@OldRptManager_Name,'')+  
            + '#' + 'New Employer :' + isnull(@OldNew_Employer,'')+  
            + '#' + 'Is Terminate :' + isnull(@OldIs_Terminate,'')+  
            + '#' + 'Uniform Return :'+ isnull(@OldUniform_Return,'')+  
            + '#' + 'Exit Interview :'+ isnull(@OldExit_Interview,'')+  
            + '#' + 'Notice Period :'+isnull(@OldNotice_period,'')+  
            + '#' + 'Is Death :' + isnull(@OldIs_Death,'')+              
            + '#' + 'In FNF Applicable :'+ isnull(@OldIs_FnF_Applicable,'')+               
            + '#' + 'Is Retire : ' + isnull(@OldIS_Retire,'')+  
            + '#' + 'LeftReasonValue : '  + isnull(@Old_LeftReasonValue,'')+  
            + '#' + 'LeftReasonText : '  + isnull(@Old_LeftReasonText,'') +   
            + '#' + 'Res_Id : '  + Cast(@OldRes_Id as Varchar(5)) +  
            + '#' + 'Is Absconded :' + isnull(@Old_IsAbsconded,'')+ '#'  
      --Added By Mukti 29-06-2016(end)Audit Trail       
     end  
    else  
     begin  
      set @Left_ID = 0  
     end  
   End  
  exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Left Employee',@OldValue,@Left_ID,@User_Id,@IP_Address   
 RETURN  
  
  
  
  