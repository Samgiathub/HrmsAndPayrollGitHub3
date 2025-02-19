  
  
  
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P_GET_CUSTOMIZED_REPORT_LIST]  
 @Cmp_ID   INT,  
 @Privilege_ID INT = 0  
AS   
 BEGIN  
   
 SET NOCOUNT ON   
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
 SET ARITHABORT ON  
   
 CREATE TABLE #REPORT_LIST  
  (  
   ReportType_ID INT,  
   ReportType  Varchar(128),  
   Form_Name  Varchar(128),  
   Sort_ID   INT  
  )  
  
  INSERT INTO #REPORT_LIST(ReportType_ID, ReportType,Form_Name,Sort_ID)  
  SELECT 0,'Employee', 'Employee',1  
  UNION ALL  
  SELECT 1,'Leave', 'Leave',2  
  UNION ALL  
  SELECT 2,'Salary', 'Salary',3  
  UNION ALL  
  SELECT 3,'Tax', 'Tax',4  
  UNION ALL  
  SELECT 5,'Attendance', 'Attendance',5  
  UNION ALL  
  SELECT 7,'Asset', 'Asset',6  
  UNION ALL  
  SELECT 8,'Claim', 'Claim',7  
  UNION ALL  
  SELECT 9,'PF & ESIC', 'PF_ESIC',8  
  UNION ALL  
  SELECT 4,'Others', 'Others',9  
  UNION ALL  
  SELECT 10,'Canteen', 'Canteen',9  
  UNION ALL  
  SELECT 11,'Ticket', 'Ticket',11 -- Added by Niraj (21122021)  
  UNION ALL  
  SELECT 12,'Medical', 'Medical',12 --Added by Mehul (28042022)  
  UNION ALL  
  SELECT 13,'Grievance', 'Grievance',13 --Added by Ronakk (28042022)  
  UNION ALL  
  SELECT 15,'FileManagement', 'FileManagement',15 --Added by mansi (28042022)  
  --UNION ALL  
  --SELECT 16,'Travel', 'Travel',16 --Added by yogesh (07102023)
    
  
  
  SELECT ReportID As [Key], ReportName As [Text], ReportType As [group],C.Form_ID  
  INTO #REPORTS   
  FROM T0250_CUSTOMIZED_REPORT C WITH (NOLOCK)  
    LEFT OUTER JOIN T0000_DEFAULT_FORM DF WITH (NOLOCK) ON C.Form_ID=DF.Form_ID      
  ORDER BY TypeID,Sort_ID  
  
  IF IsNull((SELECT SETTING_VALUE FROM T0040_SETTING WITH (NOLOCK) where Setting_name = 'AX' and CMP_ID =@Cmp_ID),0) <> 1  
   BEGIN   
    DELETE FROM #REPORTS WHERE [TEXT] IN ('AX Export', 'AX Export New', 'AX Consolidated')  
   END  
  IF IsNull((SELECT module_status FROM T0011_module_detail WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID AND module_name='GPF'),0) <> 1  
   BEGIN   
    DELETE FROM #REPORTS WHERE [TEXT] IN ('GPF Statement')  
   END  
    
  UPDATE #REPORTS  
  SET  [group] = REPLACE(REPLACE([group], '&', '_'), ' ', '')  
    
  
  IF @Privilege_ID > 0  
   BEGIN     
     
    DELETE T FROM #REPORTS T  
    WHERE NOT EXISTS(SELECT 1 FROM T0050_PRIVILEGE_DETAILS PD WITH (NOLOCK)  
         WHERE T.Form_ID=PD.Form_Id AND Privilage_ID=@Privilege_ID  
           AND (PD.Is_Delete + PD.Is_Edit + PD.Is_Print + PD.Is_Save + PD.Is_View) > 0)  
   END  
  --select * from #REPORTS  
   
  SELECT  t.*,T1.ReportType_ID As ReportType_ID, T1.ReportType,T1.Sort_ID  
  FROM (  
     SELECT 0 As [Key], '--Select Report--' As [Text], '' As [group]  
     UNION ALL  
     SELECT [Key],[Text],[group] FROM #REPORTS   
    ) T  
    LEFT OUTER JOIN #REPORT_LIST T1 ON T.[group]=T1.Form_Name  
  ORDER BY T1.Sort_ID, T.Text  
    
 END  
  
  
  