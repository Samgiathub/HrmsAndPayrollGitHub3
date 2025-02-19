  
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[Get_Leave_Detail_For_Mail_Apporval]  
   @Cmp_id numeric(18,0)  
  ,@Emp_id numeric(18,0)  
  ,@Leave_application_id numeric(18,0)   
  ,@Leave_id numeric(18,0)   
  ,@Curr_rpt_level  numeric(18,0)   
AS  
BEGIN  
   
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
   
 --Added By Jimit 18012018  
   DECLARE @R_Emp_Id1 as NUMERIC  
   SET @R_Emp_Id1 = 0  
   DECLARE @R_Emp_Id2 as NUMERIC  
     
   SELECT @R_Emp_Id1 = R_Emp_ID   
   FROM T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN   
     (  
      select max(Effect_Date) as Effect_Date,emp_id   
      from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)  
      where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID  
      GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date  
   where ERD.Emp_ID = @Emp_ID  
     
     --select @R_Emp_Id1
     
   If @R_Emp_Id1 <> 0  
    BEGIN  
        
      SELECT @R_Emp_Id2 = R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN   
       (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)  
        where ERD1.Effect_Date <= getdate() AND Emp_ID = @R_Emp_Id1  
       GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date  
      where ERD.Emp_ID = @R_Emp_Id1          
        
        
    END  
   ------------------Ended----------------------  
   Declare @App_Date as datetime= getdate()
   Declare @From_Date as datetime= (select From_Date from T0110_LEAVE_APPLICATION_DETAIL where Leave_Application_ID=@Leave_application_id)
   Declare @Period as numeric= (select Leave_Period from T0110_LEAVE_APPLICATION_DETAIL where Leave_Application_ID=@Leave_application_id)
   Declare @Rpt_Level as numeric= @Curr_rpt_level+1
   Create table #Continuity_Check
   (
   Cmp_iid  numeric(18,2) 
   ,App_Emp_iID  numeric(18,2) 
   ,Leave_DDays  numeric(18,2) 
   ,Rpt_LLevel  numeric(18,2) 
   )
   insert into #Continuity_Check(Cmp_iid,App_Emp_IID,Leave_DDays,Rpt_LLevel) 
   exec SP_Leave_Continuity_Check @cmp_id=@cmp_id,@leave_id=@Leave_id,@Emp_id=@emp_id,@app_Date=@App_Date,@From_Date=	@From_DAte,@Period=@Period,@Rpt_Level=@Rpt_Level
   

   --return
   
 if exists (SELECT Rpt_Level FROM T0115_Leave_Level_Approval WITH (NOLOCK) WHERE Leave_Application_ID = @Leave_application_id )  
  begin  
     
   Select distinct LLA.Half_Leave_Date,lla.Leave_Assign_As, VLA.Application_Date   
   ,ISNULL(lla.is_Arrear,0) as is_Arrear  
   ,ISNULL(lla.arrear_month,0) as arrear_month  
   ,ISNULL(lla.arrear_year,0) as arrear_year  
   ,ISNULL(lla.is_Responsibility_pass,0) as is_Responsibility_pass  
   ,ISNULL(lla.Responsible_Emp_id,0) as Responsible_Emp_id  
   ,lla.From_Date,lla.To_Date,lla.Leave_Period, lm.Leave_Name   
   ,ISNULL(lla.Leave_Reason,'') as Leave_Reason, lm.Leave_ID , tbl1.Rpt_Level,tbl1.Is_Fwd_Leave_Rej, CASE WHEN tbl1.Leave_Days > 0 THEN CASE WHEN isnull((select  Leave_DDays from #Continuity_Check),LLA.leave_period) <= tbl1.leave_Days THEN 1 ELSE 0 end   ELSE  tbl1.is_final_approval END AS is_final_approval
  
   ,ISNULL((Case when isnull(tbl1.App_Emp_ID,0) =  0 then (case when isnull(tbl1.Is_RM,0) = 1  then VLA.S_Emp_ID   
                 when isnull(tbl1.Is_RMToRM,0) = 1 THEN @R_Emp_Id2  --Added By Jimit 18012018  
    ELSE (CASE WHEN tbl1.Is_BM > 0 THEN   
   (  
      SELECT Emp_id FROM T0095_MANAGERS WITH (NOLOCK)  
      WHERE Effective_Date = (SELECT MAX(Effective_Date) FROM dbo.T0095_MANAGERS WITH (NOLOCK) WHERE branch_id =   
      (  
         
      SELECT  inc.branch_id FROM dbo.T0080_EMP_MASTER EM WITH (NOLOCK) INNER JOIN   
       dbo.T0095_INCREMENT inc WITH (NOLOCK) ON inc.increment_id = em.Increment_ID   
       WHERE em.emp_id = lla.Emp_ID  
        
      )   
      AND Effective_Date <= lla.From_Date) AND dbo.T0095_MANAGERS.branch_id =   
      (  
      SELECT  inc.branch_id FROM dbo.T0080_EMP_MASTER EM WITH (NOLOCK) INNER JOIN   
       dbo.T0095_INCREMENT inc WITH (NOLOCK) ON inc.increment_id = em.Increment_ID   
       WHERE em.emp_id = lla.Emp_ID  
      )  
  
   )  
    else tbl1.App_Emp_ID END) END ) ELSE tbl1.App_Emp_ID  end ),0) as s_emp_id_Scheme_current  
    ,Isnull(lla.Leave_CompOff_dates,'') as Leave_CompOff_dates  -- Changed By Gadriwala Muslim 02102014  
    ,VLA.Is_Backdated_application --Ankit 30062016  
    ,VLA.M_Cancel_WO_HO --Ankit 06082016  
    ,LLA.Approval_Comments  
   from   
   T0115_Leave_Level_Approval LLA WITH (NOLOCK)  
   inner join T0040_LEAVE_MASTER LM WITH (NOLOCK) on lm.Leave_ID= lla.Leave_ID  
   inner join   V0110_LEAVE_APPLICATION_DETAIL VLA on VLA.Leave_Application_ID = LLA.Leave_Application_ID   
   CROSS JOIN  
   (  
    SELECT SD.Rpt_Level,SD.App_Emp_ID, (CASE WHEN isnull(tblFinal.Rpt_Level,1) > (select max(Rpt_Level) + 1 from T0115_Leave_Level_Approval WITH (NOLOCK) where Leave_Application_ID = @Leave_application_id) THEN 0 ELSE 1 end) as is_final_approval  
    ,Is_Fwd_Leave_Rej, sd.Is_RM , ISNULL(sd.Is_BM,0) AS is_BM , Leave_Days    
    ,SD.Is_RMToRM --Added By Jimit 18012018  
    FROM T0050_Scheme_Detail SD WITH (NOLOCK)  
    INNER JOIN  
     (  
      SELECT max(Rpt_Level) as Rpt_Level,Scheme_Id from T0050_Scheme_Detail WITH (NOLOCK)   
       WHERE Scheme_Id in  
       (  
        SELECT Scheme_ID FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id  
        and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id AND effective_date <= getdate() And Type = 'Leave')  
        And Type = 'Leave'  
       )  
       AND @Leave_id IN (SELECT data FROM dbo.Split(leave,'#')) --and Rpt_Level = 1  
       and NOT_MANDATORY = 0  -- Added by rohit for send only intimation to employee if level is not medatory on 01062016.  
      GROUP BY Scheme_Id  
        
     ) as tblFinal  
    ON SD.Scheme_Id = tblFinal.Scheme_Id  
    WHERE SD.Scheme_Id in  
    (  
     SELECT Scheme_ID FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id  
     and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id AND effective_date <= getdate() And Type = 'Leave')  
     And Type = 'Leave'  
    )  
    AND @Leave_id IN (SELECT data FROM dbo.Split(SD.leave,'#')) and SD.Rpt_Level = (select max(Rpt_Level) + 1 from T0115_Leave_Level_Approval WITH (NOLOCK) where Leave_Application_ID = @Leave_application_id)  
      
   ) as tbl1  
   where lla.Leave_Application_ID = @Leave_application_id   
   and lla.Rpt_Level = (select max(Rpt_Level) from T0115_Leave_Level_Approval WITH (NOLOCK) where Leave_Application_ID = @Leave_application_id)  
   and tbl1.Rpt_Level <= @Curr_rpt_level  
    
  end  
 else  
  begin  
     
   SELECT distinct LAD.* , tbl1.Rpt_Level,tbl1.Is_Fwd_Leave_Rej, CASE WHEN tbl1.Leave_Days > 0 THEN CASE WHEN isnull((select  Leave_DDays from #Continuity_Check),Leave_Period) <= tbl1.leave_Days THEN 1 ELSE 0 end   ELSE  tbl1.is_final_approval END AS is_final_approval,0 as is_arrear ,0 as arrear_month, 0 as arrear_year  
   , (Case when isnull(tbl1.App_Emp_ID,0) =  0 then (case when isnull(tbl1.Is_RM,0) = 1  then lad.S_Emp_ID   
      when isnull(tbl1.Is_RMToRM,0) = 1 THEN @R_Emp_Id2  --Added By Jimit 18012018  
   else tbl1.App_Emp_ID end ) else tbl1.App_Emp_ID end) as s_emp_id_Scheme_current,  
   '' as Approval_Comments  
      FROM V0110_LEAVE_APPLICATION_DETAIL LAD  
   CROSS JOIN  
   (  
    SELECT SD.Rpt_Level,SD.App_Emp_ID, (CASE WHEN isnull(tblFinal.Rpt_Level,1) > 1 THEN 0 ELSE 1 end) as is_final_approval  
    ,Is_Fwd_Leave_Rej, sd.Is_RM , sd.Is_BM , Leave_Days  
    ,SD.Is_RMToRM  
    FROM T0050_Scheme_Detail SD WITH (NOLOCK)  
    INNER JOIN  
     (  
      SELECT max(Rpt_Level) as Rpt_Level,Scheme_Id from T0050_Scheme_Detail WITH (NOLOCK)    
       WHERE Scheme_Id in  
       (  
        SELECT Scheme_ID FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id  
        and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id AND effective_date <= getdate() And Type = 'Leave')  
        And Type = 'Leave'  
       )  
       AND @Leave_id IN (SELECT data FROM dbo.Split(leave,'#')) --and Rpt_Level = 1  
       and NOT_MANDATORY = 0  -- Added by rohit for send only intimation to employee if level is not medatory on 01062016.  
      GROUP BY Scheme_Id  
        
     ) as tblFinal  
    ON SD.Scheme_Id = tblFinal.Scheme_Id  
    WHERE SD.Scheme_Id in  
    (  
     SELECT Scheme_ID FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id  
     and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id AND effective_date <= getdate() And Type = 'Leave')  
     And Type = 'Leave'  
    )  
    AND @Leave_id IN (SELECT data FROM dbo.Split(SD.leave,'#')) and SD.Rpt_Level = 1  
   ) as tbl1  
     
   WHERE Leave_Application_ID = @Leave_application_id  
     
     
   --SELECT SD.Rpt_Level,SD.App_Emp_ID, (CASE WHEN tblFinal.Rpt_Level > 0 THEN 0 ELSE 1 end) as is_final_approval  
   --FROM T0050_Scheme_Detail SD   
   --INNER JOIN  
   -- (  
   --  SELECT max(Rpt_Level) as Rpt_Level,Scheme_Id from T0050_Scheme_Detail    
   --   WHERE Scheme_Id in  
   --   (  
   --    SELECT Scheme_ID FROM T0095_EMP_SCHEME WHERE Emp_ID = @Emp_id  
   --    and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME WHERE Emp_ID = @Emp_id AND effective_date <= getdate())  
   --   )  
   --   AND @Leave_id IN (SELECT data FROM dbo.Split(leave,'#')) and Rpt_Level = 1  
   --  GROUP BY Scheme_Id  
       
   -- ) as tblFinal  
   --ON SD.Scheme_Id = tblFinal.Scheme_Id  
   --WHERE SD.Scheme_Id in  
   --(  
   -- SELECT Scheme_ID FROM T0095_EMP_SCHEME WHERE Emp_ID = @Emp_id  
   -- and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME WHERE Emp_ID = @Emp_id AND effective_date <= getdate())  
   --)  
   --AND @Leave_id IN (SELECT data FROM dbo.Split(SD.leave,'#')) and SD.Rpt_Level = 1  
     
       
     
  end  
   
  Drop table #Continuity_Check
END  
  