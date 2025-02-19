  
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[SP_RPT_Employee_Transfer]   
  @Cmp_ID  numeric    
 ,@From_Date  datetime  
 ,@To_Date   datetime  
 ,@Branch_ID  varchar(max) = ''  
 ,@Grd_ID   varchar(max) = ''  
 ,@Type_ID   varchar(max) = ''  
 ,@Dept_ID   varchar(max) = ''  
 ,@Desig_ID   varchar(max) = ''  
 ,@Emp_ID   numeric = 0  
 ,@Constraint varchar(max) = ''  
 ,@Cat_ID        varchar(max) = ''  
AS  
  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
BEGIN  
   
 if Object_ID('tempdb..#Temp_Emp') is not null  
  drop TABLE #Temp_Emp  
    
 if Object_ID('tempdb..#Emp_INC') is not null  
  drop TABLE #Emp_INC  
  
 CREATE table #Emp_Cons   
 (        
  Emp_ID NUMERIC ,       
  Branch_ID NUMERIC,  
  Increment_ID NUMERIC  
 )  
   
 exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@Constraint,0,0,'','','','',0,0,0,'0',0,0     
   
   
 CREATE Table #Temp_Emp  
 (  
  Cmp_ID Numeric(18,0),  
  Emp_ID Numeric(18,0),  
  For_Date Datetime,  
  New_Branch Varchar(200),  
  New_Department Varchar(200),  
  New_Designation Varchar(200),  
  Old_Branch Varchar(200),  
  Old_Department Varchar(200),  
  Old_Designation Varchar(200),  
  New_Reporting_Manager Varchar(500),  
  Old_Reporting_Manager Varchar(500),  
  CTC      Numeric(18,2)   
 )  
   
 CREATE Table #Emp_INC  
 (  
  Row_Id Numeric(18,0),  
  Cmp_ID Numeric(18,0),  
  Emp_ID Numeric(18,0),  
  For_Date Datetime,  
  Branch Numeric,  
  Department Numeric,  
  Designation Numeric,  
  Reporting Numeric,  
  CTC      Numeric(18,2)   
  )  
   
 IF OBJECT_ID('#TEMP.DB..#Emp_INC_Detail_For_CTC') IS NOT NULL  
  BEGIN  
    DROP TABLE #Emp_INC_Detail_For_CTC     
  END   
    
   
 CREATE Table #Emp_INC_Detail_For_CTC  
 (  
  [Increment_ID] [numeric](18, 0) NOT NULL,  
  Emp_ID   [NUMERIC] NOT NULL,  
  AD_ID   [NUMERIC] NOT NULL,  
  FOR_DATE  [DateTime] NOT NULL,  
  E_AD_FLAG  [VARCHAR] (10),  
  E_AD_PERCENTAGE [NUMERIC] (18,4),  
  E_AD_AMOUNT  [NUMERIC] (18,4)     
 )   
     
 Insert INTO #Emp_INC_Detail_For_CTC  
 select * from dbo.fn_getEmpIncrementDetail(@Cmp_ID,@Constraint,@To_Date)  
   
   
 DECLARE @Branch_nAME Varchar(500)  
 DECLARE @old_bRANCH_nAME Varchar(500)  
 DECLARE @F_Branch_Name Varchar(500)  
    
 DECLARE @Department_nAME Varchar(500)  
 DECLARE @old_Dept_nAME Varchar(500)  
 DECLARE @F_Dept_Name Varchar(500)  
    
 DECLARE @Designation_nAME Varchar(500)  
 DECLARE @old_Desig_nAME Varchar(500)  
 DECLARE @F_Desig_Name Varchar(500)  
   
 DECLARE @Reporting_nAME Varchar(500)  
 DECLARE @old_@Reporting_nAME Varchar(500)  
   
   
   
 Declare @Cur_Emp_ID Numeric(18,0)  
 Declare cur_emp cursor for  
  Select Emp_ID From #Emp_Cons   
 Open cur_emp   
 fetch next from cur_emp into @Cur_Emp_ID  
 while @@fetch_status = 0   
  Begin  
   
  if ((Select COUNT(*) From T0095_INCREMENT WITH (NOLOCK) Where Emp_ID = @Cur_Emp_ID) > 1)   
      BEGIN  
        
   INSERT Into #Emp_INC(Row_Id,Cmp_ID,Emp_ID,For_Date,Branch,Department,Designation)  
   SELECT TOP 2 ROW_NUMBER() over(ORDER BY EC.Emp_ID), I.Cmp_ID,I.Emp_ID,I.Increment_Effective_Date,I.Branch_ID,I.Dept_ID,I.Desig_Id   
   FROM T0095_INCREMENT I WITH (NOLOCK) Inner JOIN #Emp_Cons EC  
   On I.Emp_ID = EC.Emp_ID  
   where EC.Emp_ID = @Cur_Emp_ID  
   ORDER BY I.Emp_ID,I.Increment_Effective_Date DESC  
     
   update INC SET Reporting = qry.R_Emp_ID  
   From #Emp_INC INC Inner JOIN   
   (SELECT TOP 2 ROW_NUMBER() over(ORDER BY EC.Emp_ID) as Row_Id,EC.Emp_ID,ER.R_Emp_ID,ER.Effect_Date  
   FROM T0090_EMP_REPORTING_DETAIL ER WITH (NOLOCK) Inner JOIN #Emp_Cons EC  
   On ER.Emp_ID = EC.Emp_ID  
   where EC.Emp_ID = @Cur_Emp_ID   
   ORDER BY ER.Emp_ID,ER.Effect_Date DESC) as qry  
   ON INC.Row_Id = qry.Row_Id and INC.Emp_ID = qry.Emp_ID  
     
     
   ---Added By Jimit 01032018--     
     
     
   UPDATE INC  
   SET    CTC = ISNULL(IE.BASIC_SALARY,0)  
   FROM   #EMP_INC INC INNER JOIN  
       #EMP_CONS EC ON EC.EMP_ID = INC.EMP_ID INNER JOIN  
       T0095_INCREMENT IE ON EC.Emp_ID = IE.Emp_ID INNER JOIN    
       (          
      SELECT MAX(I2.Increment_ID) AS Increment_ID,I2.Emp_ID   
      FROM T0095_Increment I2 WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I2.Emp_ID=E.Emp_ID   
        INNER JOIN (SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID  
           FROM T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E3 WITH (NOLOCK) ON I3.Emp_ID=E3.Emp_ID   
           WHERE I3.Increment_effective_Date <= @TO_DATE AND I3.Cmp_ID = @Cmp_ID AND   
              I3.EMP_ID = @CUR_EMP_ID and I3.Increment_Type Not IN ('Transfer','Deputation')  
           GROUP BY I3.EMP_ID    
           ) I3 ON I2.Increment_Effective_Date=I3.Increment_Effective_Date AND   
             I2.EMP_ID=I3.Emp_ID                                     
      GROUP BY I2.Emp_ID  
     ) I ON IE.Emp_ID = I.Emp_ID AND IE.Increment_ID=I.Increment_ID  
   WHERE  INC.Emp_ID = @CUR_EMP_ID     
     
     
         
   UPDATE INC  
   SET    CTC = INC.CTC + Q.CTC   
   FROM   #EMP_INC INC INNER JOIN  
       #EMP_CONS EC ON EC.EMP_ID = INC.EMP_ID INNER JOIN  
       (  
      SELECT emp_Id,ISNULL(SUM(EID.E_AD_AMOUNT),0) AS CTC   
      FROM #Emp_INC_Detail_For_CTC EID INNER JOIN  
        T0050_AD_MASTER AM WITH (NOLOCK) ON EID.AD_ID = AM.AD_ID AND AM.AD_PART_OF_CTC = 1 AND AM.AD_FLAG = 'I'  
      WHERE AM.CMP_ID = @CMP_ID AND EID.EMP_ID = @CUR_EMP_ID       
      GROUP By EID.Emp_ID       
     )Q ON Q.Emp_Id = EC.Emp_ID       
       
        
      ------Ended---------------   
     
   
     
   Set @Branch_nAME = ''  
   Set @old_bRANCH_nAME = ''  
     
   Set @Department_nAME = ''  
   Set @old_Dept_nAME = ''  
     
   Set @Designation_nAME = ''  
   Set @old_Desig_nAME = ''  
     
   Set @Reporting_nAME = ''  
   Set @old_@Reporting_nAME = ''  
    
     
    IF ((SELECT Branch FROM #Emp_INC WHERE Row_Id = 1) <> (SELECT Branch FROM #Emp_INC WHERE rOW_id =2))  
     BEGIN  
       SELECT @Branch_nAME =  BRANCH_nAME FROM T0030_BRANCH_MASTER BM  WITH (NOLOCK) INNER JOIN  
       #Emp_INC ei ON  BM.Branch_ID = ei.Branch  
       WHERE ei.Row_Id = 1  
         
       SELECT @old_bRANCH_nAME =  BRANCH_nAME FROM T0030_BRANCH_MASTER bm WITH (NOLOCK) INNER JOIN  
       #Emp_INC ei ON  BM.Branch_ID = ei.Branch  
       WHERE ei.Row_Id = 2  
     END   
       
    IF ((SELECT Department FROM #Emp_INC WHERE Row_Id = 1) <> (SELECT Department FROM #Emp_INC WHERE rOW_id =2))  
     BEGIN  
       SELECT @Department_nAME =  DM.Dept_Name FROM T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) INNER JOIN  
       #Emp_INC ei ON  DM.Dept_Id = ei.Department  
       WHERE ei.Row_Id = 1  
         
       SELECT @old_Dept_nAME =  DM.Dept_Name FROM T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) INNER JOIN  
       #Emp_INC ei ON  DM.Dept_Id = ei.Department  
       WHERE ei.Row_Id = 2  
         
     END   
       
    IF ((SELECT Designation FROM #Emp_INC WHERE Row_Id = 1) <> (SELECT Designation FROM #Emp_INC WHERE rOW_id =2))  
     BEGIN  
       SELECT @Designation_nAME =  DM.Desig_Name FROM T0040_DESIGNATION_MASTER DM WITH (NOLOCK) INNER JOIN  
       #Emp_INC ei ON  DM.Desig_ID = ei.Designation  
       WHERE ei.Row_Id = 1  
         
       SELECT @old_Desig_nAME =  DM.Desig_Name FROM T0040_DESIGNATION_MASTER DM WITH (NOLOCK) INNER JOIN  
       #Emp_INC ei ON  DM.Desig_ID = ei.Designation  
       WHERE ei.Row_Id = 2  
     END   
      
    IF ((SELECT Reporting FROM #Emp_INC WHERE Row_Id = 1) <> (SELECT Reporting FROM #Emp_INC WHERE rOW_id =2))  
     BEGIN   
       SELECT @Reporting_nAME =  EM.Emp_Full_Name FROM T0080_EMP_MASTER EM WITH (NOLOCK) INNER JOIN  
       #Emp_INC ei ON  EM.Emp_ID = ei.Reporting  
       WHERE ei.Row_Id = 1  
         
       SELECT @old_@Reporting_nAME =  EM.Emp_Full_Name FROM T0080_EMP_MASTER EM WITH (NOLOCK) INNER JOIN  
       #Emp_INC ei ON  EM.Emp_ID = ei.Reporting  
       WHERE ei.Row_Id = 2  
     END   
     
   if Isnull(@Branch_nAME,'') <> '' or  Isnull(@Department_nAME,'') <> '' or Isnull(@Department_nAME,'') <> '' or Isnull(@Reporting_nAME,'') <> ''    
    Begin  
     INSERT INTO #Temp_Emp(Cmp_ID,Emp_ID,For_Date,New_Branch,New_Department,New_Designation,Old_Branch,Old_Department,Old_Designation,New_Reporting_Manager,Old_Reporting_Manager,CTC)  
     SELECT Cmp_ID,Emp_ID,For_Date,@Branch_nAME,@Department_nAME,@Designation_nAME,@old_bRANCH_nAME,@old_Dept_nAME,@old_Desig_nAME,@Reporting_nAME,@old_@Reporting_nAME,CTC FROM #Emp_INC where Row_Id = 1  
    End    
  End  
    
  Delete FROM #Emp_INC  
    
  fetch next from cur_emp into @Cur_Emp_ID  
    
  End  
  Close cur_emp  
  deallocate cur_emp  
    
   
 Select '="' + EM.Alpha_Emp_Code + '"' AS Emp_code  ,EM.Emp_Full_Name,REPLACE(CONVERT(VARCHAR,#Temp_Emp.For_Date,106),' ','-') AS For_Date,  
 #Temp_Emp.Old_Branch,#Temp_Emp.New_Branch,  
 #Temp_Emp.Old_Department,#Temp_Emp.New_Department,  
 #Temp_Emp.Old_Designation,#Temp_Emp.New_Designation,  
 Old_Reporting_Manager,New_Reporting_Manager,EC.Branch_ID  
 ,CTC   
 From #Temp_Emp   
 Inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK)  
 inner join #Emp_Cons EC ON EM.EMP_ID=EC.Emp_ID  
 on #Temp_Emp.Emp_ID = EM.Emp_ID  
 Where For_Date >= @From_Date and For_Date <= @To_Date  
END  
  