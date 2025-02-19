

                          
CREATE PROCEDURE [dbo].[Get_Rpt_Claim_Details_format4_for_HealthCheckupDetail]                    
   @Cmp_ID NUMERIC                                      
  ,@From_Date  DATETIME                                  
  ,@To_Date   DATETIME                                  
  ,@Branch_ID  VARCHAR                         
  ,@Grade_ID   VARCHAR                             
  ,@Type_ID   VARCHAR                                  
  ,@Dept_ID   VARCHAR                          
  ,@Desig_ID   VARCHAR                        
  ,@Emp_ID   VARCHAR                      
  ,@Constraint VARCHAR(MAX)                       
  ,@Cat_ID   VARCHAR=0                                          
 ,@Segment_ID VARCHAR = 0                       
 ,@Vertical VARCHAR = 0                       
 ,@SubVertical VARCHAR = 0                       
                                
AS                             
begin                            
SET NOCOUNT ON                                   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED                                  
SET ARITHABORT ON                                
                              
                            
IF @Branch_ID = 0                        
  SET @Branch_ID = NULL                      
                        
 IF @Grade_ID = 0                        
   SET @Grade_ID = NULL                        
                         
 IF @Emp_ID = 0                        
  SET @Emp_ID = NULL                        
                        
 IF @Desig_ID = 0                        
  SET @Desig_ID = NULL                        
                        
    IF @Dept_ID = 0                        
  SET @Dept_ID = NULL                       
                        
 IF @Type_ID = 0                        
  SET @Type_ID = NULL                        
                        
    IF @Cat_ID = 0                      
        SET @Cat_ID = NULL                      
                                          
 If @Segment_ID = 0                      
  set @Segment_ID = null                      
                              
     If @Vertical = 0                      
  set @Vertical = null                      
                    
      If @SubVertical = 0                      
  set @SubVertical = null                      
            
 IF @Constraint= '0' OR @Constraint=''  --Added By Jaina 21-09-2015                            
  SET @Constraint = NULL                            
                              
  CREATE table #Emp_Cons                             
 (                                  
  Emp_ID NUMERIC ,                                 
  Branch_ID NUMERIC,                            
  Increment_ID NUMERIC                            
 )                             
  exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @cmp_id,@From_Date,@To_Date,@Branch_Id,@Cat_ID,@Grade_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@Constraint,0,0,0,0,0,0,0,0,0,0,0,0  --Check and verify the above parameter                            
                      
   --added by mansi start 29-7-21                                
  --  IF @Constraint <> ''                            
  --Begin          
     
  -- INSERT INTO #Emp_Cons                         
  -- SELECT cast(data  as numeric),0,0 FROM dbo.Split(@Constraint,'#') T                              
  --End                            
                         
 IF @Constraint <> ''                                  
  BEGIN                                                
 
	 select  cm.Claim_Name,EM.Emp_Full_Name,EM.Emp_ID,EM.Branch_ID,DS.Desig_Name,DM.Dept_Name,dm.Dept_Code,ds.Desig_Code,em.Emp_code,                      
      em.Alpha_Emp_Code,cd.Claim_Model,cd.Claim_IMEI,cd.Claim_App_Amount,cd.Claim_DateOfPurchase,cd.Claim_ID,                      
      cd.Curr_Rate,cd.Claim_Age,cd.Claim_ActualPrice,Cd.Claim_App_Ttl_Amount                
      ,cd.Claim_Apr_Amount,                
      dbo.F_Number_TO_Word(cd.Claim_Apr_Amount) as Claim_Apr_Amount_In_Word,                
      dbo.F_Number_TO_Word(cd.Claim_App_Amount) as Claim_App_Amount_In_Word,                  
      dbo.F_Number_TO_Word(cd.Claim_App_Ttl_Amount) as Claim_App_Ttl_Amount_In_Word ,cm.Claim_Terms_Condition                   
      ,cd.Claim_Apr_Dtl_ID,cd.Claim_NoofPerson,cd.Claim_Apr_Date          
      ,[dbo].[F_GET_FINANCIAL_YEAR](cd.Claim_Apr_Date) as financial_yr         
      ,dbo.F_GET_Quarter(MONTH(cd.Claim_Apr_Date)) as Claim_Apr_Quar          
      ,bm.Branch_Address,bm.Branch_Name,com.Cmp_Name,com.Cmp_Address,bm.Comp_Name,@From_Date as P_From_date ,@To_Date as P_To_Date         
    ,fd.Claim_FamilyMemberName,fd.Claim_FamilyRelation,fd.cf_BillNumber,fd.cf_BirthDate,fd.cf_BillAmount,fd.Claim_Amount,fd.cf_BillDate      
      ,fad.Claim_FamilyMemberName as Apr_FamilyMember,fad.Claim_FamilyRelation as Apr_Relation,fad.cfa_BillNumber as Apr_BillNo      
      ,fad.cfa_BirthDate as Apr_BirthDate,fad.cfa_BillAmount as Apr_BillAmount,fad.Claim_Amount as Apr_ClaimAmount,fad.cfa_BillDate as Apr_BillDate    
      ,fad.Claim_FamilyMemberName as Apr_FamilyMember,fad.Claim_FamilyRelation as Apr_Relation,fad.cfa_BillNumber as Apr_BillNo      
      ,fad.cfa_BirthDate as Apr_BirthDate,fad.cfa_BillAmount as Apr_BillAmount,fad.Claim_Amount as Apr_ClaimAmount,fad.cfa_BillDate as Apr_BillDate,cd.Claim_App_ID      
       ,(case when cm.Claim_Name like '%Self%' then 'Self' else '' end)as Flag, g.Grd_Name
	  from T0080_EMP_MASTER EM  
      inner join T0130_CLAIM_APPROVAL_DETAIL CD with (NoLock) on CD.Emp_ID=EM.Emp_ID                    
      left join T0040_CLAIM_MASTER CM with (NoLock) on CM.Claim_ID=cd.Claim_ID                    
      inner join T0040_DEPARTMENT_MASTER DM with(Nolock) on DM.Dept_Id=EM.Dept_ID                          
      INNER JOIN T0040_DESIGNATION_MASTER DS WITH (NOLOCK) ON EM.Desig_Id = DS.Desig_Id                                     
      --LEFT OUTER JOIN T0040_BANK_MASTER BN WITH (NOLOCK) ON Inc_Qry.Bank_Id = BN.Bank_Id           
      inner join  dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK)  ON em.BRANCH_ID = BM.BRANCH_ID         
	     left join T0040_GRADE_MASTER G with(Nolock) on G.Grd_ID=EM.Grd_ID  
      LEFT OUTER JOIN   dbo.T0010_COMPANY_MASTER COM WITH (NOLOCK)  ON COM.CMP_ID = Em.CMP_ID          
      left join T0110_Claim_FamilyDetails FD with (NoLock) on FD.Claim_AppId=cd.Claim_App_ID        
      left join T0110_Claim_Approval_FamilyDetails FAD with (NoLock) on FAD.Claim_AppId=cd.Claim_App_ID        
      where   cd.Claim_Status='A' and                 
      EM.Cmp_ID=@Cmp_ID                      
      and cd.Claim_Apr_Date between    @From_Date and @To_Date  and cm.Claim_Report_Def_Id=11  
   --and  Claim_Name  like '%14_Annual Health Check-upr%' or Claim_Name  like '%Annual Health Check-up%'                  
    order by cm.Claim_ID         
  END                              
 ELSE             
  BEGIN            
    --added by mansi end 29-7-21                                
      select  cm.Claim_Name,EM.Emp_Full_Name,EM.Emp_ID,EM.Branch_ID,DS.Desig_Name,DM.Dept_Name,dm.Dept_Code,ds.Desig_Code,em.Emp_code,                      
      em.Alpha_Emp_Code,cd.Claim_Model,cd.Claim_IMEI,cd.Claim_App_Amount,cd.Claim_DateOfPurchase,cd.Claim_ID,                      
      cd.Curr_Rate,cd.Claim_Age,cd.Claim_ActualPrice,Cd.Claim_App_Ttl_Amount                
      ,cd.Claim_Apr_Amount,                
      dbo.F_Number_TO_Word(cd.Claim_Apr_Amount) as Claim_Apr_Amount_In_Word,                
      dbo.F_Number_TO_Word(cd.Claim_App_Amount) as Claim_App_Amount_In_Word,                  
      dbo.F_Number_TO_Word(cd.Claim_App_Ttl_Amount) as Claim_App_Ttl_Amount_In_Word ,cm.Claim_Terms_Condition                   
      ,cd.Claim_Apr_Dtl_ID,cd.Claim_NoofPerson,cd.Claim_Apr_Date          
      ,[dbo].[F_GET_FINANCIAL_YEAR](cd.Claim_Apr_Date) as financial_yr         
      ,dbo.F_GET_Quarter(MONTH(cd.Claim_Apr_Date)) as Claim_Apr_Quar          
      ,bm.Branch_Address,bm.Branch_Name,com.Cmp_Name,com.Cmp_Address,bm.Comp_Name,@From_Date as P_From_date ,@To_Date as P_To_Date         
    ,fd.Claim_FamilyMemberName,fd.Claim_FamilyRelation,fd.cf_BillNumber,fd.cf_BirthDate,fd.cf_BillAmount,fd.Claim_Amount,fd.cf_BillDate      
      ,fad.Claim_FamilyMemberName as Apr_FamilyMember,fad.Claim_FamilyRelation as Apr_Relation,fad.cfa_BillNumber as Apr_BillNo      
      ,fad.cfa_BirthDate as Apr_BirthDate,fad.cfa_BillAmount as Apr_BillAmount,fad.Claim_Amount as Apr_ClaimAmount,fad.cfa_BillDate as Apr_BillDate    
      ,fad.Claim_FamilyMemberName as Apr_FamilyMember,fad.Claim_FamilyRelation as Apr_Relation,fad.cfa_BillNumber as Apr_BillNo      
      ,fad.cfa_BirthDate as Apr_BirthDate,fad.cfa_BillAmount as Apr_BillAmount,fad.Claim_Amount as Apr_ClaimAmount,fad.cfa_BillDate as Apr_BillDate,cd.Claim_App_ID      
       ,(case when cm.Claim_Name like '%Self%' then 'Self' else '' end)as Flag, g.Grd_Name
	  from T0080_EMP_MASTER EM                               
      inner join T0130_CLAIM_APPROVAL_DETAIL CD with (NoLock) on CD.Emp_ID=EM.Emp_ID                    
      left join T0040_CLAIM_MASTER CM with (NoLock) on CM.Claim_ID=cd.Claim_ID                    
      inner join T0040_DEPARTMENT_MASTER DM with(Nolock) on DM.Dept_Id=EM.Dept_ID                          
      INNER JOIN T0040_DESIGNATION_MASTER DS WITH (NOLOCK) ON EM.Desig_Id = DS.Desig_Id                                     
      --LEFT OUTER JOIN T0040_BANK_MASTER BN WITH (NOLOCK) ON Inc_Qry.Bank_Id = BN.Bank_Id           
      inner join  dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK)  ON em.BRANCH_ID = BM.BRANCH_ID     
	     left join T0040_GRADE_MASTER G with(Nolock) on G.Grd_ID=EM.Grd_ID  
      LEFT OUTER JOIN   dbo.T0010_COMPANY_MASTER COM WITH (NOLOCK)  ON COM.CMP_ID = Em.CMP_ID          
      left join T0110_Claim_FamilyDetails FD with (NoLock) on FD.Claim_AppId=cd.Claim_App_ID        
      left join T0110_Claim_Approval_FamilyDetails FAD with (NoLock) on FAD.Claim_AppId=cd.Claim_App_ID        
      where   cd.Claim_Status='A' and                 
      EM.Cmp_ID=@Cmp_ID                      
      and cd.Claim_Apr_Date between    @From_Date and @To_Date  and cm.Claim_Report_Def_Id=11  
   --and  Claim_Name  like '%14_Annual Health Check-upr%' or Claim_Name  like '%Annual Health Check-up%'                  
    order by cm.Claim_ID                           
  END                                  
 end 



