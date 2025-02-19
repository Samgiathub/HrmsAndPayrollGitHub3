 --exec Emp_Details_Form_A @Company_Id=119,@From_Date='2020-01-01 00:00:00',@To_Date='2020-01-31 00:00:00',@Branch_ID='',@Cat_ID='',@Grade_ID='',@Type_ID='',@Dept_ID='',@Desig_ID='',@Emp_ID=0,@Constraint='18412#14938',@Report_Type='ESIC'                  
  
    
    -- exec Get_Rpt_Claim_Details_format4_for_InternetExpenses @cmp_Id=203,@From_Date='2019-01-01 00:00:00',@To_Date='2021-12-01 00:00:00',@Branch_ID='',@Grade_ID='',@Type_ID='',@Dept_ID='',@Desig_ID='',@Emp_ID=0,@Constraint='',@Cat_ID='',@Segment_ID='0',@Vertical='0',@SubVertical='0'                
 --,@is_column='',@Salary_Cycle_id='',@Segment_ID='0',@Vertical='0',@SubVertical='0',@subBranch='0',@PBranch_ID= '',@PVertical_ID= '',@PSubVertical_ID='',@PDept_ID=''                 
                       
CREATE PROCEDURE Get_Rpt_Claim_Details_format4_for_InternetExpenses                      
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
 -- ,@is_column  tinyint = 0                            
 --  ,@Salary_Cycle_id  NUMERIC  = 0                  
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
    IF @Constraint <> ''                        
  Begin                          
   INSERT INTO #Emp_Cons                     
   SELECT cast(data  as numeric),0,0 FROM dbo.Split(@Constraint,'#') T                          
  End                        
                          
 IF @Constraint <> ''                              
     BEGIN                             
     select distinct cm.Claim_Name,EM.Emp_Full_Name,EM.Emp_ID,EM.Branch_ID,DS.Desig_Name,DM.Dept_Name,dm.Dept_Code,ds.Desig_Code,em.Emp_code,                  
     em.Alpha_Emp_Code      
   ,bm.Branch_Address,bm.Branch_Name,com.Cmp_Name,com.Cmp_Address,bm.Comp_Name,@From_Date as P_From_date ,@To_Date as P_To_Date      
       
     from T0080_EMP_MASTER EM                          
     Inner join #Emp_Cons EC on EC.Emp_ID=EM.Emp_ID                     
     inner join T0130_CLAIM_APPROVAL_DETAIL CD with (NoLock) on CD.Emp_ID=EM.Emp_ID              
     inner join T0040_CLAIM_MASTER CM with (NoLock) on CM.Claim_ID=cd.Claim_ID                
     inner join T0040_DEPARTMENT_MASTER DM with(Nolock) on DM.Dept_Id=EM.Dept_ID                      
     INNER JOIN T0040_DESIGNATION_MASTER DS WITH (NOLOCK) ON EM.Desig_Id = DS.Desig_Id                                 
     --LEFT OUTER JOIN T0040_BANK_MASTER BN WITH (NOLOCK) ON Inc_Qry.Bank_Id = BN.Bank_Id      
     inner join  dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK)  ON em.BRANCH_ID = BM.BRANCH_ID         
     LEFT OUTER JOIN   dbo.T0010_COMPANY_MASTER COM WITH (NOLOCK)  ON COM.CMP_ID = Em.CMP_ID       
     where   cd.Claim_Status='A' and EM.Cmp_ID=@Cmp_ID                    
   and cd.Claim_Apr_Date between    @From_Date and @To_Date and cm.Claim_Report_Def_Id=5  
   --and  Claim_Name like '%Internet Expenses%' or Claim_Name like '%09_Internet Expenses%'  --and cd.Claim_ID=89               
     order by em.Alpha_Emp_Code                
    --  group by Emp_Full_Name,em.Emp_ID,em.Branch_ID,em.Alpha_Emp_Code,DS.Desig_Name,DM.Dept_Name,dm.Dept_Code,ds.Desig_Code,em.Emp_code                     
    END                          
  ELSE         
   BEGIN        
     --added by mansi end 29-7-21                            
    select distinct cm.Claim_Name,EM.Emp_Full_Name,EM.Emp_ID,EM.Branch_ID,DS.Desig_Name,DM.Dept_Name,dm.Dept_Code,ds.Desig_Code,em.Emp_code,                  
    em.Alpha_Emp_Code      
    ,bm.Branch_Address,bm.Branch_Name,com.Cmp_Name,com.Cmp_Address,bm.Comp_Name,@From_Date as P_From_date ,@To_Date as P_To_Date     
       
    from T0080_EMP_MASTER EM                           
    inner join T0130_CLAIM_APPROVAL_DETAIL CD with (NoLock) on CD.Emp_ID=EM.Emp_ID                
    inner join T0040_CLAIM_MASTER CM with (NoLock) on CM.Claim_ID=cd.Claim_ID                
    inner join T0040_DEPARTMENT_MASTER DM with(Nolock) on DM.Dept_Id=EM.Dept_ID                      
    INNER JOIN T0040_DESIGNATION_MASTER DS WITH (NOLOCK) ON EM.Desig_Id = DS.Desig_Id                                 
    --LEFT OUTER JOIN T0040_BANK_MASTER BN WITH (NOLOCK) ON Inc_Qry.Bank_Id = BN.Bank_Id       
    inner join  dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK)  ON em.BRANCH_ID = BM.BRANCH_ID         
    LEFT OUTER JOIN   dbo.T0010_COMPANY_MASTER COM WITH (NOLOCK)  ON COM.CMP_ID = Em.CMP_ID       
    where   cd.Claim_Status='A' and             
    EM.Cmp_ID=@Cmp_ID                  
    and cd.Claim_Apr_Date between    @From_Date and @To_Date   and cm.Claim_Report_Def_Id=5  
 --and  Claim_Name like '%Internet Expenses%' or Claim_Name like '%09_Internet Expenses%'  --- and cd.Claim_ID=89               
   --  group by Emp_Full_Name,em.Emp_ID,em.Branch_ID,em.Alpha_Emp_Code,DS.Desig_Name,DM.Dept_Name,dm.Dept_Code,ds.Desig_Code,em.Emp_code                   
     order by em.Alpha_Emp_Code                       
  END                              
    end                        
   -- RETURN