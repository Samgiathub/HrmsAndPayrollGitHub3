  
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[SP_RPT_EMP_LATEMARK_PERCENTAGE]    
  @Cmp_ID   numeric    
 ,@From_Date  datetime    
 ,@To_Date   datetime     
 ,@Branch_ID  numeric    
 ,@Cat_ID   numeric     
 ,@Grd_ID   numeric    
 ,@Type_ID   numeric    
 ,@Dept_ID   numeric    
 ,@Desig_ID   numeric    
 ,@Emp_ID   numeric    
 ,@constraint  varchar(MAX)    
   
     
AS    
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
   
 IF @Branch_ID = 0      
  set @Branch_ID = null    
      
 IF @Cat_ID = 0      
  set @Cat_ID = null    
    
 IF @Grd_ID = 0      
  set @Grd_ID = null    
    
 IF @Type_ID = 0      
  set @Type_ID = null    
    
 IF @Dept_ID = 0      
  set @Dept_ID = null    
    
 IF @Desig_ID = 0      
  set @Desig_ID = null    
    
 IF @Emp_ID = 0      
  set @Emp_ID = null    
  
CREATE table #Emp_Cons   
 (        
   Emp_ID numeric ,       
  Branch_ID numeric,  
  Increment_ID numeric      
 )       
   
     
   INSERT INTO #Emp_Cons   
  SELECT  EMP_ID, 0,0  
   FROM (Select Cast(Data As Numeric) As Emp_ID FROM dbo.Split(@Constraint,'#') T Where T.Data <> '') E  
     
   UPDATE  E   
  SET Branch_ID = I.Branch_ID, Increment_ID=I.Increment_ID  
   FROM #Emp_Cons E        
   INNER JOIN (SELECT I1.EMP_ID, I1.INCREMENT_ID, I1.BRANCH_ID  
     FROM T0095_INCREMENT I1 WITH (NOLOCK) INNER JOIN #Emp_Cons E1 ON I1.Emp_ID=E1.EMP_ID  
       INNER JOIN (SELECT MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID  
          FROM T0095_INCREMENT I2 WITH (NOLOCK) INNER JOIN #Emp_Cons E2 ON I2.Emp_ID=E2.EMP_ID  
            INNER JOIN (SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID  
               FROM T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN #Emp_Cons E3 ON I3.Emp_ID=E3.EMP_ID  
               WHERE I3.Increment_Effective_Date <= @To_Date  
               GROUP BY I3.Emp_ID  
               ) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID                    
          WHERE I2.Cmp_ID = IsNull(@Cmp_Id , I2.Cmp_ID)  
          GROUP BY I2.Emp_ID  
          ) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_ID=I2.INCREMENT_ID   
     WHERE I1.Cmp_ID=IsNull(@Cmp_Id , I1.Cmp_ID)             
    ) I ON E.EMP_ID=I.Emp_ID  
  
  
 if OBJECT_ID('tempdb..#LateEarlyData') is not null  
  Begin  
   Drop Table #LateEarlyData  
  End  
  
 Create Table #LateEarlyData  
 (  
  Emp_ID Numeric,  
  For_Date Datetime,  
  Late_Min Varchar(20),  
  Late_Sec Numeric,  
  Late_Cal_on_Percent Numeric(18,2),  
  Late_Calc_on_Amt Numeric(18,2),  
  Late_Amount Numeric(18,2),  
  Late_Limit Varchar(20),  
  Shift_Name varchar(100),  
  IN_Time Datetime,  
  Early_Min Varchar(20),  
  Early_Sec Numeric,  
  Early_Cal_on_Percent Numeric(18,2),  
  Early_Amount Numeric(18,2),  
  Early_Limit Varchar(20),  
  Out_Time Datetime  
 )  
  
 Insert into #LateEarlyData  
 Select   
 MLT.EMP_ID,MLT.For_Date,  
 MLT.Late_Min,MLT.Late_Sec,MLT.Late_Cal_on_Percent,  
 MLT.Late_Calc_on_Amt,MLT.Late_Amount,Late_Limit,MLT.Shift_Name,MLT.IN_Time,'00:00',0,0,0,'00:00',NULL  
 From T0140_Monthly_Latemark_Transaction MLT WITH (NOLOCK)   
 INNER JOIN #Emp_Cons EC ON MLT.Emp_ID = EC.Emp_ID   
 
 Update LE  
  SET LE.Early_Min = MLT.EARLY_MIN,  
   LE.Early_Sec = MLT.EARLY_SEC,  
   LE.Early_Cal_on_Percent = MLT.EARLY_CAL_ON_PERCENT,  
   LE.Early_Amount = MLT.EARLY_AMOUNT,  
   LE.Early_Limit = MLT.EARLY_LIMIT,  
   LE.Out_Time = MLT.OUT_TIME  
 From #LateEarlyData LE   
  Inner Join  T0140_Monthly_Earlymark_Transaction MLT  ON LE.Emp_ID = MLT.EMP_ID and LE.For_Date = MLT.FOR_DATE  
  
  
 Insert into #LateEarlyData  
 Select   
 MET.EMP_ID,MET.For_Date,  
 '00:00',0,0,EARLY_CALC_ON_AMT,0,'00:00',MET.Shift_Name,NULL,EARLY_MIN,Early_Sec,EARLY_CAL_ON_PERCENT,EARLY_AMOUNT,EARLY_LIMIT,OUT_TIME  
 From T0140_Monthly_Earlymark_Transaction MET WITH (NOLOCK)   
 INNER JOIN #Emp_Cons EC ON MET.Emp_ID = EC.Emp_ID   
 Where NOT EXISTS(SELECT 1 FROM #LateEarlyData LD WHERE LD.Emp_ID = MET.EMP_ID and LD.For_Date = MET.FOR_DATE)  
  
 SELECT   
 EM.Cmp_ID,EM.EMP_ID,  
 MLT.Late_Min,MLT.Late_Sec,MLT.For_Date,MLT.Late_Cal_on_Percent  
 ,MLT.Late_Calc_on_Amt,MLT.Late_Amount,Late_Limit,MLT.Shift_Name,MLT.IN_Time  
 ,GM.Grd_Name ,TM.Type_Name   
 ,DM.Dept_Name,DSM.Desig_Name,BM.Branch_Name,BM.Comp_Name,BM.Branch_Address, VS.Vertical_Name,SV.SubVertical_Name   
 ,EM.Alpha_Emp_Code,EM.Emp_code,EM.Emp_Full_Name,CM.Cmp_Name,CM.Cmp_Address ,  
 MLT.Early_Min,MLT.Early_Sec,MLT.Early_Cal_on_Percent,MLT.Early_Amount,MLT.Early_Limit,MLT.Out_Time,Isnull(MLT.Late_Amount,0) + Isnull(MLT.Early_Amount,0) as total_amt  
  FROM #LateEarlyData MLT    
 INNER JOIN #Emp_Cons EC ON MLT.Emp_ID = EC.Emp_ID   
 INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON MLT.Emp_ID = EM.Emp_ID   
 INNER JOIN T0095_Increment I WITH (NOLOCK) ON EC.Increment_ID=I.Increment_ID AND EC.Emp_ID = I.Emp_ID     
 INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON EC.Branch_ID=BM.Branch_ID    
 INNER JOIN t0010_company_master CM WITH (NOLOCK) ON EM.Cmp_ID = CM.Cmp_Id      
 LEFT JOIN t0040_designation_master DSM WITH (NOLOCK) ON I.Desig_id = DSM.Desig_id      
 LEFT JOIN T0040_department_master DM WITH (NOLOCK) ON I.Dept_id = DM.Dept_id           
 LEFT JOIN T0040_TYPE_MASTER TM WITH (NOLOCK) ON I.Type_ID = TM.Type_ID        
 LEFT JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I.Grd_ID = GM.Grd_ID      
 LEFT JOIN T0040_Vertical_Segment VS WITH (NOLOCK) ON I.Vertical_ID = VS.Vertical_ID     
 LEFT JOIN T0050_SubVertical SV WITH (NOLOCK) ON I.SubVertical_ID = SV.SubVertical_ID   
 WHERE MLT.FOR_DATE >= @From_Date AND MLT.FOR_DATE <= @To_Date and (Late_Amount > 0 OR Early_Amount > 0)  
 ORDER BY EC.Emp_ID, MLT.FOR_DATE  
   
 RETURN    
  
  