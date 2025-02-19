



Create VIEW [dbo].[V0140_Travel_Sattlement_Approve_No_TravelType_Direct]  
AS  

select isnull(TA.Travel_Approval_ID,0) as Travel_Approval_ID,
isnull(TRSA.Approval_date,TSA.For_date) as Approval_Date,
TSA.Comment as Approval_Comments,isnull(TA.Approval_Status,'A') as Approval_Status,  
TSA.Cmp_ID,isnull(TA.Emp_ID,TSA.emp_id) as Emp_ID,isnull(TA.S_Emp_ID,0) as S_Emp_ID,
TA.Travel_Application_ID,isnull(TA.Total,0) as Total,
EM.Emp_Full_Name,Em.Alpha_Emp_Code,ISNULL(SEM.Emp_Full_Name ,'')as S_Emp_full_Name,
ISNULL(EM.Emp_First_Name,'')AS Emp_First_Name,EM.Branch_ID,
TSA.Travel_Set_Application_id as Travel_Set_Application_id,
isnull(TSA.status,0) as status,TSA.Document,
dbo.F_GET_Emp_Visit(TA.Cmp_ID,TA.Travel_Application_ID,0) as Emp_Visit,
isnull(TRA.Application_Code,TSA.Travel_Set_Application_id) as Travel_App_code,
TRSA.Approval_date as Set_Approve_Date,Inc.Vertical_ID,Inc.SubVertical_ID,Inc.Dept_ID,
isnull(TRA.Chk_International,0) as Is_Foreign,isnull(Inc.Desig_Id,0) as Desig_Id,
isnull(TSA.ODDates,0) as ODDates,isnull(TSA.Visited_flag,0) as Visited_flag,
c.GST_No,TT.Travel_Type_Id,Travel_Type_Name
FROM  T0140_Travel_Settlement_Application as TSA WITH (NOLOCK) 
LEFT JOIN  T0120_TRAVEL_APPROVAL as TA WITH (NOLOCK)  on TA.Travel_Approval_ID = TSA.Travel_Approval_ID and TA.Emp_ID=TSA.emp_id
INNER JOIN T0080_EMP_MASTER as EM WITH (NOLOCK)  ON TSA.Emp_ID = EM.Emp_ID 
INNER JOIN T0095_INCREMENT Inc WITH (NOLOCK)  ON EM.Increment_ID = Inc.Increment_ID
LEFT JOIN  T0080_EMP_MASTER as SEM WITH (NOLOCK)  on TA.S_Emp_ID = SEM.Emp_ID 
LEFT JOIN  T0100_TRAVEL_APPLICATION TRA WITH (NOLOCK)  on TRA.Emp_ID=TA.Emp_ID and TRA.Travel_Application_ID=TA.Travel_Application_ID
LEFT JOIN T0110_TRAVEL_APPLICATION_DETAIL TRAD WITH (NOLOCK)  on TRA.Travel_Application_ID = Trad.Travel_App_ID
LEFT JOIN  T0040_Travel_Type TT WITH (NOLOCK)  on TRAD.TravelTypeId= TT.Travel_Type_Id
LEFT JOIN  T0150_Travel_Settlement_Approval TRSA WITH (NOLOCK)  on TRSA.Travel_Set_Application_id=TSA.Travel_Set_Application_id and TRSA.emp_id=TSA.emp_id
INNER JOIN T0010_COMPANY_MASTER c WITH (NOLOCK)  ON c.Cmp_Id = Inc.Cmp_ID where TRAD.TravelTypeId=0 or TRAD.TravelTypeId=Null  

Union

select  isnull(TSA.Travel_Approval_ID,0) as Travel_Approval_ID,
isnull(TRSA.Approval_date,TSA.For_date) as Approval_Date,
TSA.Comment as Approval_Comments,'', TSA.Cmp_ID,
TSA.Emp_ID,0,0,0,EM.Emp_Full_Name,Em.Alpha_Emp_Code,'',
ISNULL(EM.Emp_First_Name,'')AS Emp_First_Name,EM.Branch_ID,  
TSA.Travel_Set_Application_id as Travel_Set_Application_id,
isnull(TSA.status,0) as status,TSA.Document,'',
isnull(TRA.Application_Code,TSA.Travel_Set_Application_id) as Travel_App_code,
TRSA.Approval_date as Set_Approve_Date,Inc.Vertical_ID,
Inc.SubVertical_ID,Inc.Dept_ID,
isnull(TRA.Chk_International,0) as Is_Foreign,
isnull(Inc.Desig_Id,0) as Desig_Id,
isnull(TSA.ODDates,0) as ODDates,
isnull(TSA.Visited_flag,0) as Visited_flag,
c.GST_No,TT.Travel_Type_Id,Travel_Type_Name
FROM T0140_Travel_Settlement_Application as TSA WITH (NOLOCK) 
INNER JOIN T0080_EMP_MASTER as EM WITH (NOLOCK)  ON TSA.Emp_ID = EM.Emp_ID 
INNER JOIN T0095_INCREMENT Inc WITH (NOLOCK)  ON EM.Increment_ID = Inc.Increment_ID 
LEFT JOIN  T0100_TRAVEL_APPLICATION TRA WITH (NOLOCK)  on TRA.Emp_ID=TSA.Emp_ID and tra.Travel_Application_ID = TSA.Travel_Set_Application_id 
inner JOIN T0110_TRAVEL_APPLICATION_DETAIL TRAD WITH (NOLOCK)  on TRA.Travel_Application_ID = Trad.Travel_App_ID
LEFT JOIN  T0040_Travel_Type TT WITH (NOLOCK)  on TRAD.TravelTypeId= TT.Travel_Type_Id
LEFT JOIN  T0150_Travel_Settlement_Approval TRSA WITH (NOLOCK)  on TRSA.Travel_Set_Application_id = TSA.Travel_Set_Application_id and TRSA.emp_id=TSA.emp_id
INNER JOIN T0010_COMPANY_MASTER c WITH (NOLOCK)  ON c.Cmp_Id = Inc.Cmp_ID
where TRAD.TravelTypeId=0 or TRAD.TravelTypeId=Null 


