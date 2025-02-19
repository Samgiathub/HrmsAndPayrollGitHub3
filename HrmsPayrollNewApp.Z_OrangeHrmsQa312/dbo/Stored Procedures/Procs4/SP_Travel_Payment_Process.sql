    
    
-- =============================================    
-- Author:  <Jaina>    
-- Create date: <19-12-2017>    
-- Description: <Travel Advance Payment Process>    
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---    
-- =============================================    
CREATE PROCEDURE [dbo].[SP_Travel_Payment_Process]    
  @Cmp_ID  Numeric    
 ,@From_Date  Datetime    
 ,@To_Date  Datetime    
 ,@Branch_ID  varchar(max) =''    
 ,@Cat_ID  varchar(max) =''    
 ,@Grd_ID  varchar(max) =''    
 ,@Type_ID  varchar(max) =''     
 ,@Dept_Id  varchar(max) =''    
 ,@Desig_Id  varchar(max) =''     
 ,@Vertical_Id   varchar(maX)=''    
 ,@SubVertical_Id varchar(max)=''    
 ,@SubBranch_Id varchar(max)=''    
 ,@Segment_Id  varchar(max)=''    
 ,@Emp_ID  Numeric=0    
 ,@Constraint varchar(MAX)=''    
 ,@Process_type varchar(max)=''     
     
     
AS    
    
SET NOCOUNT ON     
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
SET ARITHABORT ON    
    
BEGIN    
     
 IF @Branch_ID = '0' or @Branch_ID = ''    
  set @Branch_ID = null    
      
 IF @Cat_ID = '0'  or @Cat_ID = ''     
  set @Cat_ID = null    
    
 IF @Grd_ID = '0'  or @Grd_ID = ''    
  set @Grd_ID = null    
    
 IF @Type_ID = '0'  or @Type_ID = ''      
  set @Type_ID = null    
    
 IF @Dept_ID = '0'  or @Dept_ID = ''    
  set @Dept_ID = null    
    
 IF @Desig_ID = '0' or @Desig_ID = ''      
  set @Desig_ID = null    
    
 IF @Emp_ID = 0      
  set @Emp_ID = null    
      
      
 CREATE TABLE #Emp_Cons     
 (          
  Emp_ID numeric ,         
  Branch_ID numeric,    
  Increment_ID numeric        
 )     
 EXEC dbo.SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@Constraint,0,0,0,@Vertical_Id,@SubVertical_Id,@SubBranch_Id,0,0,0,'0',0,0        
        
        
          
 IF @Process_type = 'Travel Advance Amount'    
  BEGIN    
         
   SELECT TAD.TRAVEL_APPROVAL_ID,CONVERT(VARCHAR,TA.APPROVAL_DATE,103) AS APPROVAL_DATE,    
       TA.EMP_ID ,E.ALPHA_EMP_CODE + ' - '+ E.EMP_FULL_NAME AS EMP_FULL_NAME,    
       SUM(AMOUNT) AS ADVANCE_AMOUNT,MONTH(APPROVAL_DATE) AS MONTH_ID, YEAR(APPROVAL_DATE) AS YEAR_ID    
       ,I.Branch_ID,I.Vertical_ID,I.SubVertical_ID,I.Dept_ID    
   FROM  DBO.T0120_TRAVEL_APPROVAL TA WITH (NOLOCK)    
     INNER JOIN T0130_TRAVEL_APPROVAL_ADVDETAIL TAD WITH (NOLOCK) ON TA.TRAVEL_APPROVAL_ID=TAD.TRAVEL_APPROVAL_ID AND TA.CMP_ID=TAD.CMP_ID    
     INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON E.EMP_ID = TA.EMP_ID     
     INNER JOIN #EMP_CONS EC ON EC.EMP_ID = E.EMP_ID     
     INNER JOIN (SELECT I1.EMP_ID, I1.INCREMENT_ID, I1.BRANCH_ID,I1.Dept_ID,I1.Vertical_ID,I1.SubVertical_ID    
        FROM T0095_INCREMENT I1 WITH (NOLOCK) INNER JOIN #Emp_Cons E1 ON I1.Emp_ID=E1.EMP_ID    
          INNER JOIN (SELECT MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID    
             FROM T0095_INCREMENT I2 WITH (NOLOCK) INNER JOIN #Emp_Cons E2 ON I2.Emp_ID=E2.EMP_ID    
               INNER JOIN (SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID    
                  FROM T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN #Emp_Cons E3 ON I3.Emp_ID=E3.EMP_ID    
                  WHERE I3.Increment_Effective_Date <= @To_Date    
                  GROUP BY I3.Emp_ID    
                  ) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID                      
             WHERE I2.Cmp_ID = @Cmp_Id     
             GROUP BY I2.Emp_ID    
             ) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_ID=I2.INCREMENT_ID     
        WHERE I1.Cmp_ID=@Cmp_Id               
       ) I ON EC.EMP_ID=I.Emp_ID               
   WHERE TAD.AMOUNT > 0 AND LTRIM(RTRIM(isnull(TA.Approved_Account_Advance_desk,'P')))='A' AND E.CMP_ID=@CMP_ID    
    AND TA.APPROVAL_DATE BETWEEN @FROM_DATE AND @TO_DATE and TA.Cmp_ID = @Cmp_id    
    And NOT EXISTS(Select 1 From T0302_Payment_Process_Travel_Details PT WITH (NOLOCK)    
          WHERE TA.Travel_Approval_Id = PT.Travel_Approval_Id  AND TA.Emp_ID = PT.Emp_Id)           
    GROUP BY TA.EMP_ID,TAD.TRAVEL_APPROVAL_ID,TAD.Travel_Approval_ID,E.Alpha_Emp_Code,E.Emp_Full_Name,TA.Approval_Date    
     ,MONTH(TA.APPROVAL_DATE) ,YEAR(TA.APPROVAL_DATE),I.Branch_ID,I.Vertical_ID,I.SubVertical_ID,I.Dept_ID    
  END    
 ELSE    
  Begin    
  --select * from #EMP_CONS where emp_id=29948  
    SELECT TS.Travel_Set_Application_id AS TRAVEL_APPROVAL_ID, CONVERT(VARCHAR,APPROVAL_DATE,103) AS APPROVAL_DATE,TS.EMP_ID ,    
        E.ALPHA_EMP_CODE + ' - ' + E.EMP_FULL_NAME AS EMP_FULL_NAME,    
       SUM(Approved_Expance) AS ADVANCE_AMOUNT,MONTH(APPROVAL_DATE) AS MONTH_ID, YEAR(APPROVAL_DATE) AS YEAR_ID,     
         I.Branch_ID,I.Vertical_ID,I.SubVertical_ID,I.Dept_ID    
    FROM  DBO.T0150_TRAVEL_SETTLEMENT_APPROVAL TS WITH (NOLOCK) INNER JOIN    
       T0080_EMP_MASTER E WITH (NOLOCK) ON E.EMP_ID =TS.EMP_ID INNER JOIN    
       #EMP_CONS EC ON EC.EMP_ID = E.EMP_ID    
       INNER JOIN (SELECT I1.EMP_ID, I1.INCREMENT_ID, I1.BRANCH_ID,I1.Dept_ID,I1.Vertical_ID,I1.SubVertical_ID    
        FROM T0095_INCREMENT I1 WITH (NOLOCK) INNER JOIN #Emp_Cons E1 ON I1.Emp_ID=E1.EMP_ID    
          INNER JOIN (SELECT MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID    
             FROM T0095_INCREMENT I2 WITH (NOLOCK) INNER JOIN #Emp_Cons E2 ON I2.Emp_ID=E2.EMP_ID    
               INNER JOIN (SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID    
                  FROM T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN #Emp_Cons E3 ON I3.Emp_ID=E3.EMP_ID    
                  WHERE I3.Increment_Effective_Date <= @To_Date    
                  GROUP BY I3.Emp_ID    
                  ) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID                      
             WHERE I2.Cmp_ID = @Cmp_Id     
             GROUP BY I2.Emp_ID    
             ) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_ID=I2.INCREMENT_ID     
        WHERE I1.Cmp_ID=@Cmp_Id               
       ) I ON EC.EMP_ID=I.Emp_ID               
    WHERE TRAVEL_AMT_IN_SALARY = 0 AND Adjust_Amount > 0 and TS.Cmp_ID  = @Cmp_id    
       AND IS_APR=1 AND TS.APPROVAL_DATE BETWEEN @FROM_DATE AND @TO_DATE    
       AND NOT EXISTS(SELECT 1 FROM T0302_PAYMENT_PROCESS_TRAVEL_DETAILS PT WITH (NOLOCK)    
          WHERE TS.TRAVEL_SET_APPLICATION_ID = PT.TRAVEL_SET_APPROVAL_ID AND TS.EMP_ID = PT.EMP_ID)     
    GROUP BY  TS.EMP_ID,TS.TRAVEL_SET_APPLICATION_ID,E.ALPHA_EMP_CODE,E.EMP_FULL_NAME,TS.APPROVAL_DATE,    
      MONTH(APPROVAL_DATE) ,YEAR(APPROVAL_DATE),I.Branch_ID,I.Vertical_ID,I.SubVertical_ID,I.Dept_ID    
           
  END    
             
     
     
END    