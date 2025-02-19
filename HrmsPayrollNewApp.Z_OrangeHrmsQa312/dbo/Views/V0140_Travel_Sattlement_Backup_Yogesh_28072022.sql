







create VIEW [dbo].[V0140_Travel_Sattlement_Backup_Yogesh_28072022]  
AS  
--SELECT       
--       TA.Travel_Approval_ID,TA.Approval_Date,TA.Approval_Comments,TA.Approval_Status,  
--       TA.Cmp_ID,TA.Emp_ID,TA.S_Emp_ID,TA.Travel_Application_ID,TA.Total  
--       ,EM.Emp_Full_Name,Em.Alpha_Emp_Code,ISNULL(SEM.Emp_Full_Name ,'')as S_Emp_full_Name  
--       ,ISNULL(EM.Emp_First_Name,'')AS Emp_First_Name,EM.Branch_ID  
--        ,0 as Travel_Set_Application_id
--        ,dbo.F_GET_Emp_Visit(TA.Cmp_ID,TA.Travel_Application_ID,0) as Emp_Visit
--        ,TRA.Application_Code as Travel_App_Code,inc.Vertical_ID,inc.SubVertical_ID,inc.Dept_ID
--        ,isnull(TRA.Chk_International,0) as Is_Foreign
--        ,isnull(Inc.Desig_Id,0) as Desig_Id
--        ,C.GST_No
--FROM         dbo.T0120_TRAVEL_APPROVAL as TA INNER JOIN  
----dbo.T0130_TRAVEL_APPROVAL_DETAIL as TAD ON TA.Travel_Approval_ID = TAD .Travel_Approval_ID INNER JOIN  
----dbo.T0130_TRAVEL_APPROVAL_ADVDETAIL as TAAD ON TA.Travel_Approval_ID = TAAD.Travel_Approval_ID INNER JOIN  
--                      dbo.T0080_EMP_MASTER as EM ON TA.Emp_ID = EM.Emp_ID inner JOIN  
--                      dbo.T0095_INCREMENT Inc ON EM.Increment_ID = Inc.Increment_ID left JOIN  
--                      dbo.T0080_EMP_MASTER as SEM on TA.S_Emp_ID = SEM.Emp_ID  
--                      left Join T0100_TRAVEL_APPLICATION TRA on TRA.Emp_ID=TA.Emp_ID and TRA.Travel_Application_ID=TA.Travel_Application_ID
--                      INNER JOIN T0010_COMPANY_MASTER C ON C.Cmp_Id = Inc.Cmp_ID
--where TA.Travel_Approval_ID not in (select Travel_Approval_ID from T0140_Travel_Settlement_Application )  
  
  
  SELECT  TA.TRAVEL_APPROVAL_ID,TA.APPROVAL_DATE,TA.APPROVAL_COMMENTS,TA.APPROVAL_STATUS,  
		TA.CMP_ID,TA.EMP_ID,TA.S_EMP_ID,TA.TRAVEL_APPLICATION_ID,TA.TOTAL ,
		EM.EMP_FULL_NAME,EM.ALPHA_EMP_CODE,ISNULL(SEM.EMP_FULL_NAME ,'')AS S_EMP_FULL_NAME ,ISNULL(EM.EMP_FIRST_NAME,'')AS EMP_FIRST_NAME,EM.BRANCH_ID  
        ,0 as Travel_Set_Application_id,dbo.F_GET_Emp_Visit(TA.Cmp_ID,TA.Travel_Application_ID,0) as Emp_Visit
        ,TRA.Application_Code as Travel_App_Code,inc.Vertical_ID,inc.SubVertical_ID,inc.Dept_ID
        ,isnull(TRA.Chk_International,0) as Is_Foreign
        ,isnull(Inc.Desig_Id,0) as Desig_Id
        ,C.GST_No,TT.Travel_Type_Name,TT.Travel_Type_Id
FROM         dbo.T0120_TRAVEL_APPROVAL as TA WITH (NOLOCK) INNER JOIN  
                      dbo.T0080_EMP_MASTER as EM  WITH (NOLOCK) ON TA.Emp_ID = EM.Emp_ID inner JOIN  
                      dbo.T0095_INCREMENT Inc  WITH (NOLOCK) ON EM.Increment_ID = Inc.Increment_ID left JOIN  
                      dbo.T0080_EMP_MASTER as SEM  WITH (NOLOCK) on TA.S_Emp_ID = SEM.Emp_ID  
                      left Join T0100_TRAVEL_APPLICATION TRA  WITH (NOLOCK) on TRA.Emp_ID=TA.Emp_ID and TRA.Travel_Application_ID=TA.Travel_Application_ID
					  inner join T0110_TRAVEL_APPLICATION_DETAIL TAD With (Nolock) on TRA.Travel_Application_ID = TAD.Travel_App_ID
						inner join T0040_Travel_Type TT With (NOLOCK) on TAD.TravelTypeId = TT.Travel_Type_Id
                      INNER JOIN T0010_COMPANY_MASTER C  WITH (NOLOCK) ON C.Cmp_Id = Inc.Cmp_ID
where TA.Travel_Approval_ID not in (select Travel_Approval_ID from T0140_Travel_Settlement_Application WITH (NOLOCK) )  


UNION ALL


SELECT	ISNULL(TA.TRAVEL_APPROVAL_ID,0) AS TRAVEL_APPROVAL_ID,ISNULL(TRSA.APPROVAL_DATE,TSA.FOR_DATE) AS APPROVAL_DATE,TSA.COMMENT AS APPROVAL_COMMENTS,ISNULL(TSA.STATUS,'D') AS APPROVAL_STATUS,  
		TSA.CMP_ID,ISNULL(TA.EMP_ID,TSA.EMP_ID) AS EMP_ID,ISNULL(TA.S_EMP_ID,0) AS S_EMP_ID,TA.TRAVEL_APPLICATION_ID,ISNULL(TA.TOTAL,0) AS TOTAL,
		EM.EMP_FULL_NAME,EM.ALPHA_EMP_CODE,ISNULL(SEM.EMP_FULL_NAME ,'')AS S_EMP_FULL_NAME,ISNULL(EM.EMP_FIRST_NAME,'')AS EMP_FIRST_NAME,EM.BRANCH_ID,
		TSA.TRAVEL_SET_APPLICATION_ID AS TRAVEL_SET_APPLICATION_ID,DBO.F_GET_EMP_VISIT(TA.CMP_ID,TA.TRAVEL_APPLICATION_ID,0) AS EMP_VISIT,
		(TSA.TRAVEL_SET_APPLICATION_ID) AS TRAVEL_APP_CODE,INC.VERTICAL_ID,INC.SUBVERTICAL_ID,INC.DEPT_ID,ISNULL(TRA.CHK_INTERNATIONAL,0) AS IS_FOREIGN,
		ISNULL(INC.DESIG_ID,0) AS DESIG_ID,C.GST_NO,TT.Travel_Type_Name,TT.Travel_Type_Id
		
		--ISNULL(TSA.STATUS,0) AS STATUS,TSA.DOCUMENT,ISNULL(TRA.APPLICATION_CODE,TRSA.APPROVAL_DATE AS SET_APPROVE_DATE,
		--ISNULL(TSA.ODDATES,0) AS ODDATES,ISNULL(TSA.VISITED_FLAG,0) AS VISITED_FLAG,
		
FROM    T0140_TRAVEL_SETTLEMENT_APPLICATION AS TSA  WITH (NOLOCK) LEFT JOIN
		DBO.T0120_TRAVEL_APPROVAL AS TA  WITH (NOLOCK) ON TA.TRAVEL_APPROVAL_ID = TSA.TRAVEL_APPROVAL_ID AND TA.EMP_ID=TSA.EMP_ID
		INNER JOIN  DBO.T0080_EMP_MASTER AS EM  WITH (NOLOCK) ON TSA.EMP_ID = EM.EMP_ID 
		INNER JOIN  DBO.T0095_INCREMENT INC  WITH (NOLOCK) ON EM.INCREMENT_ID = INC.INCREMENT_ID 
		LEFT JOIN   DBO.T0080_EMP_MASTER AS SEM  WITH (NOLOCK) ON TA.S_EMP_ID = SEM.EMP_ID
		LEFT JOIN	T0100_TRAVEL_APPLICATION TRA  WITH (NOLOCK) ON TRA.EMP_ID=TA.EMP_ID AND TRA.TRAVEL_APPLICATION_ID=TA.TRAVEL_APPLICATION_ID
		inner join T0110_TRAVEL_APPLICATION_DETAIL TAD With (Nolock) on TRA.Travel_Application_ID = TAD.Travel_App_ID
		inner join T0040_Travel_Type TT With (NOLOCK) on TAD.TravelTypeId = TT.Travel_Type_Id
		LEFT JOIN	T0150_TRAVEL_SETTLEMENT_APPROVAL TRSA  WITH (NOLOCK) ON TRSA.TRAVEL_SET_APPLICATION_ID=TSA.TRAVEL_SET_APPLICATION_ID AND TRSA.EMP_ID=TSA.EMP_ID
        INNER JOIN	T0010_COMPANY_MASTER C  WITH (NOLOCK) ON C.CMP_ID = INC.CMP_ID
		WHERE TSA.STATUS='D'
  
  
  


