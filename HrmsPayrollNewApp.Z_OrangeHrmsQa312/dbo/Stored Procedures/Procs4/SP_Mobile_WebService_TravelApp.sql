CREATE PROCEDURE [dbo].[SP_Mobile_WebService_TravelApp]  
 @Cmp_ID numeric(18,0),  
 @Emp_ID numeric(18,0),  
 @Type char(5)  
 ,@FromDate datetime,  
 @ToDate datetime  
AS   
BEGIN  
  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
DECLARE @Setting_Value int  
SELECT @Setting_Value = Setting_Value from T0040_SETTING where Setting_Name = 'Enable Travel Type in Travel Module / Travel Expense' and Cmp_ID = @Cmp_ID   
  
IF(@Setting_Value = 1)  
 BEGIN  
  IF @Type = 'P'  
  BEGIN    
  
   SELECT distinct  V.Travel_Application_ID, Application_Code, Application_Date,Alpha_Emp_Code,Emp_Full_Name, Supervisor, Application_Status,  
   Isnull(ProofCount,0) as ProofCount, Branch_Name, Desig_Name,V.Emp_ID,travel_approval_id,travel_set_Application_id,Application_Date_Show,Cnt,Emp_Visit,  
   Travel_Type_Name,Travel_Type_Id,isnull(VC.RPT_Level,0) as RPT_Level  
   FROM V0100_TRAVEL_APPLICATION_Without_TravelType as v   
   Left join T0115_TRAVEL_LEVEL_APPROVAL as t on v.Travel_Application_ID = t.Travel_Application_ID    
   LEft Outer  join (select Max(Rpt_Level) as RPT_Level,Travel_Application_ID from T0115_TRAVEL_LEVEL_APPROVAL V group  by Travel_Application_ID  
   ) VC on VC.Travel_Application_ID = T.Travel_Application_ID   
   WHERE V.Cmp_ID = @Cmp_ID and V.Emp_ID = @Emp_ID and (Application_Status in ('P','D') or Application_Status='F') and    
   cast(Application_Date as date) >= @FromDate and Cast(Application_Date as date) <= @ToDate  
            ORDER BY Application_Code DESC  
    
  END    
  ELSE IF @Type = 'A'  
  BEGIN    
  
   SELECT DISTINCT V.Travel_Application_ID, Application_Code, Application_Date,Alpha_Emp_Code,Emp_Full_Name, Supervisor, Application_Status,Isnull(ProofCount,0) as ProofCount  
   , Branch_Name, Desig_Name,V.Emp_ID,travel_approval_id,travel_set_Application_id,Application_Date_Show,Cnt,Emp_Visit,  
   Travel_Type_Name,Travel_Type_Id  
   ,isnull(VC.RPT_Level,0) as RPT_Level  
   FROM V0100_TRAVEL_APPLICATION as v   
   Left join T0115_TRAVEL_LEVEL_APPROVAL as t on v.Travel_Application_ID = t.Travel_Application_ID    
   LEft Outer  join (select Max(Rpt_Level) as RPT_Level,Travel_Application_ID from T0115_TRAVEL_LEVEL_APPROVAL V group  by Travel_Application_ID  
   ) VC on VC.Travel_Application_ID = T.Travel_Application_ID   
   WHERE V.Cmp_ID = @Cmp_ID and V.Emp_ID = @Emp_ID and Application_Status in ('A')  and  cast(Application_Date as date) >= @FromDate and Cast(Application_Date as date) <= @ToDate  
   ORDER BY Application_Code DESC  
  END   
  ELSE IF @Type = 'R'  
  BEGIN    
  
   SELECT DISTINCT V.Travel_Application_ID, Application_Code, Application_Date,Alpha_Emp_Code,Emp_Full_Name, Supervisor, Application_Status,Isnull(ProofCount,0) as ProofCount  
   , Branch_Name, Desig_Name,V.Emp_ID,travel_approval_id,travel_set_Application_id,Application_Date_Show,Cnt,Emp_Visit,  
   Travel_Type_Name,Travel_Type_Id  
   ,isnull(VC.RPT_Level,0) as RPT_Level  
   FROM V0100_TRAVEL_APPLICATION as v   
   Left join T0115_TRAVEL_LEVEL_APPROVAL as t on v.Travel_Application_ID = t.Travel_Application_ID    
   LEft Outer  join (select Max(Rpt_Level) as RPT_Level,Travel_Application_ID from T0115_TRAVEL_LEVEL_APPROVAL V group  by Travel_Application_ID  
   ) VC on VC.Travel_Application_ID = T.Travel_Application_ID   
   WHERE V.Cmp_ID = @Cmp_ID and V.Emp_ID = @Emp_ID and Application_Status in ('R')  and  cast(Application_Date as date) >= @FromDate and Cast(Application_Date as date) <= @ToDate  
   ORDER BY Application_Code DESC  
  END   
 END  
ELSE  
 BEGIN  
  IF @Type = 'P'  
  BEGIN    
    
   SELECT distinct  V.Travel_Application_ID, Application_Code, Application_Date,Alpha_Emp_Code,Emp_Full_Name, Supervisor, Application_Status,  
   Isnull(ProofCount,0) as ProofCount, Branch_Name, Desig_Name,V.Emp_ID,travel_approval_id,travel_set_Application_id,Application_Date_Show,Cnt,Emp_Visit,  
   Travel_Type_Name,Travel_Type_Id,isnull(VC.RPT_Level,0) as RPT_Level  
   FROM V0100_TRAVEL_APPLICATION_Without_TravelType as v   
   Left join T0115_TRAVEL_LEVEL_APPROVAL as t on v.Travel_Application_ID = t.Travel_Application_ID    
   LEft Outer  join (select Max(Rpt_Level) as RPT_Level,Travel_Application_ID from T0115_TRAVEL_LEVEL_APPROVAL V group  by Travel_Application_ID  
   ) VC on VC.Travel_Application_ID = T.Travel_Application_ID   
   WHERE V.Cmp_ID = @Cmp_ID and V.Emp_ID = @Emp_ID and (Application_Status in ('P','D') or Application_Status='F') and    
  cast(Application_Date as date) >= @FromDate and Cast(Application_Date as date) <= @ToDate
   ORDER BY Application_Code DESC  
  
   END    
  ELSE IF @Type = 'A'  
  BEGIN    
     
   SELECT DISTINCT V.Travel_Application_ID, Application_Code, Application_Date,Alpha_Emp_Code,Emp_Full_Name, Supervisor, Application_Status,Isnull(ProofCount,0) as ProofCount  
   , Branch_Name, Desig_Name,V.Emp_ID,travel_approval_id,travel_set_Application_id,Application_Date_Show,Cnt,Emp_Visit,  
   Travel_Type_Name,Travel_Type_Id  
   ,isnull(VC.RPT_Level,0) as RPT_Level  
   FROM V0100_TRAVEL_APPLICATION_Without_TravelType as v   
   Left join T0115_TRAVEL_LEVEL_APPROVAL as t on v.Travel_Application_ID = t.Travel_Application_ID    
   LEft Outer  join (select Max(Rpt_Level) as RPT_Level,Travel_Application_ID from T0115_TRAVEL_LEVEL_APPROVAL V group  by Travel_Application_ID  
   ) VC on VC.Travel_Application_ID = T.Travel_Application_ID   
   WHERE V.Cmp_ID = @Cmp_ID and V.Emp_ID = @Emp_ID and Application_Status in ('A')  and  cast(Application_Date as date) >= @FromDate and Cast(Application_Date as date) <= @ToDate  
   ORDER BY Application_Code DESC  
  
   END   
  ELSE IF @Type = 'R'  
  BEGIN    
  
   SELECT DISTINCT V.Travel_Application_ID, Application_Code, Application_Date,Alpha_Emp_Code,Emp_Full_Name, Supervisor, Application_Status,Isnull(ProofCount,0) as ProofCount  
   , Branch_Name, Desig_Name,V.Emp_ID,travel_approval_id,travel_set_Application_id,Application_Date_Show,Cnt,Emp_Visit,  
   Travel_Type_Name,Travel_Type_Id  
   ,isnull(VC.RPT_Level,0) as RPT_Level  
   FROM V0100_TRAVEL_APPLICATION_Without_TravelType as v   
   Left join T0115_TRAVEL_LEVEL_APPROVAL as t on v.Travel_Application_ID = t.Travel_Application_ID    
   LEft Outer  join (select Max(Rpt_Level) as RPT_Level,Travel_Application_ID from T0115_TRAVEL_LEVEL_APPROVAL V group  by Travel_Application_ID  
   ) VC on VC.Travel_Application_ID = T.Travel_Application_ID   
   WHERE V.Cmp_ID = @Cmp_ID and V.Emp_ID = @Emp_ID and Application_Status in ('R')  and  cast(Application_Date as date) >= @FromDate and Cast(Application_Date as date) <= @ToDate  
   ORDER BY Application_Code DESC  
  
   END   
 END  
  
  
END
