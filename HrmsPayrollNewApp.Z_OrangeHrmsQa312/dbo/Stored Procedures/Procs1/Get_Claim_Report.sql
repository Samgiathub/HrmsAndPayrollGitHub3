
CREATE PROCEDURE [dbo].[Get_Claim_Report]  
@CMP_ID NUMERIC(18,0),  
@CLAIM_APP_ID NUMERIC(18,0),  
@EMP_ID NUMERIC(18,0),  
@TO_DATE DATETIME,  
@Claim_Apr_ID Numeric(18,0) = 0  --Added by Jaina 10-11-2020  
AS  
  
SET NOCOUNT ON  
BEGIN  
  
DECLARE @REPORTING_MANAGER_NAME AS VARCHAR(MAX)  
SET @REPORTING_MANAGER_NAME = ''  
  
if @CLAIM_APP_ID != 0   
Begin  
  --print 111--mansi
  SELECT EM.EMP_FULL_NAME,EM.EMP_ID,EM.ALPHA_EMP_CODE,CLD.CLAIM_APP_DETAIL_ID,CLD.CMP_ID,  
    CLD.CLAIM_APP_ID,CLD.FOR_DATE,ISNULL(QRY2.Claim_Apr_Amnt,CLD.APPLICATION_AMOUNT) AS APPLICATION_AMOUNT,  
    CLD.CLAIM_DESCRIPTION,CLD.CLAIM_ID,ISNULL(CLD.CURR_ID,0) AS CURR_ID,ISNULL(CLD.CURR_RATE,0) AS CURR_RATE,
	isnull(cm.Claim_Type,0)as Claim_Type,  
    ISNULL(CLD.CLAIM_AMOUNT,0) AS ACTUAL_CLAIM_AMOUNT,  
    (  
     CASE   
      WHEN (QRY2.Claim_Apr_Amnt IS NULL) AND (ISNULL(CLD.CURR_ID,0) = 0)   
       THEN  Application_Amount  
	   WHEN (CLD.CLAIM_AMOUNT = 0) --and (ISNULL(QRY2.Rpt_Level,0) <> 1) --add onemore isnull condition for getting zero value at without approval lavel
	   THEN CLD.Application_Amount
      ELSE   
       ISNULL(ISNULL(QRY2.Claim_Apr_Amnt,CRM.CLAIM_APR_AMOUNT),CLD.CLAIM_AMOUNT)   
      END   
    )AS CLAIM_AMOUNT, -- CONDITION ADDED BY RAJPUT ON 16032018
    ISNULL(ISNULL(QRY2.PETROLKM,CRM.PETROL_KM),CLD.PETROL_KM) AS PETROL_KM,CM.CLAIM_NAME,CMP.CMP_NAME,  
    CMP.CMP_ADDRESS,CMP.CMP_LOGO,BM.Branch_Name,DM.Dept_Name,DSM.Desig_Name,isnull(Vs.Vertical_Name,'') as Vertical_Name,--ISNULL(VS.Vertical_Name,'') as Vertical_Name,  
    ISNULL(BS.Segment_Name,'') as Segment_Name,ISNULL(SV.SubVertical_Name,'') as SubVertical_Name,  
    ISNULL(SB.SubBranch_Name,'') as SubBranch_Name,ISNULL(GM.Grd_Name,'') as Grade_Name, (CASE WHEN ISNULL(CMDG.Rate_Per_Km,0.00) <> 0.00 THEN ISNULL(CMDG.Rate_Per_Km,0.00) WHEN ISNULL(CMDB.Rate_Per_Km,0.00) <> 0.00 THEN ISNULL(CMDB.Rate_Per_Km,0.00) ELSE
  isnull(CMD.Rate_Per_Km,0.00) END) as Rate_Per_Km,CMT.Curr_Symbol -- CMT.Curr_Symbol ADDED BY RAJPUT ON 16032018
  ,Claim_Date_Label
  INTO    #CLAIM_CONSOL_REPORT  
  FROM T0110_CLAIM_APPLICATION_DETAIL CLD WITH (NOLOCK)   
    INNER JOIN T0100_CLAIM_APPLICATION CL WITH (NOLOCK) ON CL.CLAIM_APP_ID = CLD.CLAIM_APP_ID AND CL.CMP_ID=CLD.CMP_ID  
    INNER JOIN T0040_CLAIM_MASTER CM WITH (NOLOCK) ON CM.CLAIM_ID=CLD.CLAIM_ID AND CM.CMP_ID=CLD.CMP_ID  
    INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.EMP_ID=CL.EMP_ID AND EM.CMP_ID=CL.CMP_ID  
    INNER JOIN T0010_COMPANY_MASTER CMP WITH (NOLOCK) ON CMP.CMP_ID=CL.CMP_ID  
    LEFT JOIN  
    --    select MAX(rpt_level)as rptLvl,Claim_Apr_Amnt,PetrolKM,Claim_App_ID,Claim_ID,For_Date   
    --    FROM T0115_CLAIM_LEVEL_APPROVAL_DETAIL  
    --    WHERE Cmp_ID=@CMP_ID AND Emp_ID=@EMP_ID AND Claim_App_ID=@CLAIM_APP_ID   
    --    Group by Claim_Apr_Amnt,PetrolKM,Claim_App_ID,Claim_ID,For_Date  
    --   ) InrQry ON InrQry.CLAIM_APP_ID=CLD.CLAIM_APP_ID and CLD.For_Date=InrQry.For_Date and InrQry.Claim_ID=CLd.Claim_ID   
    (  
     SELECT Distinct TLA.Claim_App_Amnt,TLA.Claim_App_ID,TLA.For_Date,TLA.Claim_ID,TLA.Claim_Apr_Amnt,TLA.PetrolKM, Isnull(TLA.Purpose,Qry.Purpose) As Purpose ,TLA.Rpt_Level 
      FROM T0115_CLAIM_LEVEL_APPROVAL_DETAIL TLA WITH (NOLOCK)  
       LEFT JOIN (  
          SELECT MAX(rpt_level)as rptLvl,Claim_App_ID,Claim_ID,For_Date,Purpose   
          FROM T0115_CLAIM_LEVEL_APPROVAL_DETAIL WITH (NOLOCK)  
          WHERE Cmp_ID=@CMP_ID AND Emp_ID=@EMP_ID AND Claim_App_ID=@CLAIM_APP_ID   
          GROUP BY Claim_App_ID,Claim_ID,For_Date,Purpose  
           ) Qry on TLA.For_Date=Qry.For_Date   
         and TLA.Rpt_Level=Qry.rptLvl and TLA.Claim_ID=Qry.Claim_ID and TLA.Claim_App_ID=Qry.Claim_App_ID  
     WHERE Cmp_ID=@CMP_ID and Emp_ID=@EMP_ID AND TLA.Claim_App_ID=@CLAIM_APP_ID and Qry.rptLvl is not null  and TLA.Claim_Status= 'A' --add by tejas for After approved wrong value showing
    ) QRY2 on QRY2.Claim_App_ID=CLD.Claim_App_ID and QRY2.For_Date=CLD.For_Date and QRY2.Claim_App_Amnt=CLD.Application_Amount and QRY2.Claim_ID=CLD.Claim_ID And Qry2.Purpose = CLD.Claim_Description  
     
    LEFT JOIN T0130_CLAIM_APPROVAL_DETAIL CRM WITH (NOLOCK) ON CRM.CLAIM_APP_ID=CLD.CLAIM_APP_ID AND CRM.CLAIM_ID=CLD.CLAIM_ID AND CRM.CLAIM_APP_AMOUNT=CLD.CLAIM_AMOUNT  
    AND CRM.CLAIM_APR_DATE=CLD.FOR_DATE AND CLD.Claim_Description = CRM.Purpose --- Added Purpose in join by Hardik 21/10/2020 for Nepra as same claim showing duplicate  
    
    Inner Join   
    (  
     SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.DEPT_ID,I.Grd_ID,I.Cat_ID,I.Type_ID,  
       I.Vertical_ID,I.Subvertical_ID,I.Segment_ID,I.Subbranch_ID,I.Emp_WeekDay_OT_Rate  
       ,I.Cmp_ID FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN   
         (  
         select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join  
          (  
           Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)  
           Where Increment_effective_Date <= @TO_DATE and Emp_ID=@Emp_ID  Group by emp_ID  
          ) new_inc on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date  
           Where TI.Increment_effective_Date <= @TO_DATE group by ti.emp_id  
        ) Qry on I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID  
         
    )INC_QRY ON EM.EMP_ID = INC_QRY.EMP_ID  
    Left Join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on Dm.Dept_Id=INC_QRY.Dept_ID  
    Left Join T0040_DESIGNATION_MASTER DSM WITH (NOLOCK) on DSM.Desig_ID=INC_QRY.Desig_Id  
    Left Join T0030_BRANCH_MASTER BM WITH (NOLOCK) on BM.Branch_ID=INC_QRY.Branch_ID  
    Left Join T0040_GRADE_MASTER GM WITH (NOLOCK) on GM.Grd_ID=INC_QRY.Grd_ID  
    Left Join T0040_Business_Segment BS WITH (NOLOCK) on BS.Segment_ID=INC_QRY.Segment_ID  
    Left Join T0040_Vertical_Segment VS WITH (NOLOCK) on VS.Vertical_ID=INC_QRY.Vertical_ID  
    Left Join T0050_SubVertical SV WITH (NOLOCK) on SV.SubVertical_ID=INC_QRY.SubVertical_ID  
    Left Join T0050_SubBranch SB WITH (NOLOCK) on SB.SubBranch_ID=INC_QRY.subBranch_ID   
    
    left JOIN  T0041_Claim_Maxlimit_Design CMD WITH (NOLOCK) ON CM.Claim_ID = CMD.Claim_ID and INC_QRY.Desig_Id = CMD.Desig_ID --Added by Jaina 26-07-2017  
    left JOIN  T0041_Claim_Maxlimit_Design CMDG WITH (NOLOCK) ON CM.Claim_ID = CMDG.Claim_ID and INC_QRY.Grd_ID = CMDG.Grade_ID -- ADDED BY RAJPUT ON 19032018   
    left JOIN  T0041_Claim_Maxlimit_Design CMDB WITH (NOLOCK) ON CM.Claim_ID =CMDB.Claim_ID and INC_QRY.Branch_ID = CMDB.Branch_ID  -- ADDED BY RAJPUT ON 19032018   
    
    left join T0040_CURRENCY_MASTER CMT WITH (NOLOCK) ON  CLD.Curr_ID=CMT.Curr_ID  --Added by Rajput on 16032018  
    
    
  WHERE CL.CLAIM_APP_ID=@CLAIM_APP_ID AND CL.EMP_ID=@EMP_ID AND CL.CMP_ID=@CMP_ID  
  and isnull(CRM.Claim_Status,'A') <> 'R'  
  
  
  
  
  SELECT @REPORTING_MANAGER_NAME = STUFF((  
  SELECT ', ' + A.EMP_FULL_NAME   
  FROM DBO.T0080_EMP_MASTER AS A WITH (NOLOCK)  
  INNER JOIN DBO.T0115_CLAIM_LEVEL_APPROVAL AS B WITH (NOLOCK)  
  ON B.S_EMP_ID = A.EMP_ID  
  WHERE B.CLAIM_APP_ID = @CLAIM_APP_ID AND B.EMP_ID = @EMP_ID AND B.CMP_ID = @CMP_ID  
  FOR XML PATH, TYPE).value(N'.[1]', N'VARCHAR(MAX)'), 1, 2, '')  
  
  
  SELECT *,@REPORTING_MANAGER_NAME AS Reporting_Manager_Name FROM #CLAIM_CONSOL_REPORT  
END  
ELSE   
Begin  
 --Added by Jaina 10-11-2020  
 SELECT EM.EMP_FULL_NAME,EM.EMP_ID,EM.ALPHA_EMP_CODE,CLD.Claim_Apr_Dtl_ID,CLD.CMP_ID,  
    CLD.CLAIM_APP_ID,CLD.Claim_Apr_Date as FOR_DATE ,ISNULL(QRY2.Claim_Apr_Amnt,CLd.Claim_Apr_Amount) AS APPLICATION_AMOUNT,  
    CLD.Purpose,CLD.CLAIM_ID,ISNULL(CLD.CURR_ID,0) AS CURR_ID,ISNULL(CLD.CURR_RATE,0) AS CURR_RATE, 
	isnull(cm.Claim_Type,0)as Claim_Type,
    ISNULL(CLD.Claim_App_Amount,0) AS ACTUAL_CLAIM_AMOUNT,  
    (  
     CASE   
      WHEN (APPLICATION_AMOUNT IS NOT NULL) AND (ISNULL(CLD.CURR_ID,0) <> 0)   
       THEN Application_Amount  
      ELSE   
       ISNULL(ISNULL(QRY2.Claim_Apr_Amnt,CLD.CLAIM_APR_AMOUNT),CRM.CLAIM_AMOUNT)   
      END   
    )AS CLAIM_AMOUNT, -- CONDITION ADDED BY RAJPUT ON 16032018  
    ISNULL(ISNULL(QRY2.PETROLKM,CRM.PETROL_KM),CLD.PETROL_KM) AS PETROL_KM,CM.CLAIM_NAME,CMP.CMP_NAME,  
    CMP.CMP_ADDRESS,CMP.CMP_LOGO,BM.Branch_Name,DM.Dept_Name,DSM.Desig_Name,isnull(Vs.Vertical_Name,'') as Vertical_Name,--ISNULL(VS.Vertical_Name,'') as Vertical_Name,  
    ISNULL(BS.Segment_Name,'') as Segment_Name,ISNULL(SV.SubVertical_Name,'') as SubVertical_Name,  
    ISNULL(SB.SubBranch_Name,'') as SubBranch_Name,ISNULL(GM.Grd_Name,'') as Grade_Name, (CASE WHEN ISNULL(CMDG.Rate_Per_Km,0.00) <> 0.00 THEN ISNULL(CMDG.Rate_Per_Km,0.00) WHEN ISNULL(CMDB.Rate_Per_Km,0.00) <> 0.00 THEN ISNULL(CMDB.Rate_Per_Km,0.00) ELSE
  isnull(CMD.Rate_Per_Km,0.00) END) as Rate_Per_Km,CMT.Curr_Symbol -- CMT.Curr_Symbol ADDED BY RAJPUT ON 16032018  
  ,Claim_Date_Label
  INTO    #CLAIM_CONSOL_REPORT_Apr  
  FROM T0130_CLAIM_APPROVAL_DETAIL CLD WITH (NOLOCK)   
    Inner JOIN T0120_CLAIM_APPROVAL CL WITH (NOLOCK) ON CL.Claim_Apr_ID = CLD.Claim_Apr_ID AND CL.CMP_ID=CLD.CMP_ID  
    INNER JOIN T0040_CLAIM_MASTER CM WITH (NOLOCK) ON CM.CLAIM_ID=CLD.CLAIM_ID AND CM.CMP_ID=CLD.CMP_ID  
    INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.EMP_ID=CL.EMP_ID AND EM.CMP_ID=CL.CMP_ID  
    INNER JOIN T0010_COMPANY_MASTER CMP WITH (NOLOCK) ON CMP.CMP_ID=CL.CMP_ID  
    LEFT JOIN  
    --    select MAX(rpt_level)as rptLvl,Claim_Apr_Amnt,PetrolKM,Claim_App_ID,Claim_ID,For_Date   
    --    FROM T0115_CLAIM_LEVEL_APPROVAL_DETAIL  
    --    WHERE Cmp_ID=@CMP_ID AND Emp_ID=@EMP_ID AND Claim_App_ID=@CLAIM_APP_ID   
    --    Group by Claim_Apr_Amnt,PetrolKM,Claim_App_ID,Claim_ID,For_Date  
    --   ) InrQry ON InrQry.CLAIM_APP_ID=CLD.CLAIM_APP_ID and CLD.For_Date=InrQry.For_Date and InrQry.Claim_ID=CLd.Claim_ID   
    (  
     SELECT Distinct TLA.Claim_App_Amnt,TLA.Claim_App_ID,TLA.For_Date,TLA.Claim_ID,TLA.Claim_Apr_Amnt,TLA.PetrolKM, Isnull(TLA.Purpose,Qry.Purpose) As Purpose  
      FROM T0115_CLAIM_LEVEL_APPROVAL_DETAIL TLA WITH (NOLOCK)  
       LEFT JOIN (  
          SELECT MAX(rpt_level)as rptLvl,Claim_App_ID,Claim_ID,For_Date,Purpose   
          FROM T0115_CLAIM_LEVEL_APPROVAL_DETAIL WITH (NOLOCK)  
          WHERE Cmp_ID=@CMP_ID AND Emp_ID=@EMP_ID AND Claim_App_ID=@CLAIM_APP_ID   
          GROUP BY Claim_App_ID,Claim_ID,For_Date,Purpose  
           ) Qry on TLA.For_Date=Qry.For_Date   
         and TLA.Rpt_Level=Qry.rptLvl and TLA.Claim_ID=Qry.Claim_ID and TLA.Claim_App_ID=Qry.Claim_App_ID  
     WHERE Cmp_ID=@CMP_ID and Emp_ID=@EMP_ID AND TLA.Claim_App_ID=@CLAIM_APP_ID and Qry.rptLvl is not null  
    ) QRY2 on QRY2.Claim_App_ID=CLD.Claim_App_ID and QRY2.For_Date=CLD.CLAIM_APR_DATE and QRY2.Claim_App_Amnt=CLD.Claim_Apr_Amount and QRY2.Claim_ID=CLD.Claim_ID And QRY2.Purpose=CLD.Purpose  
     
    LEFT JOIN T0110_CLAIM_APPLICATION_DETAIL CRM WITH (NOLOCK) ON CRM.CLAIM_APP_ID=CLD.CLAIM_APP_ID AND CRM.CLAIM_ID=CLD.CLAIM_ID AND CLD.CLAIM_APP_AMOUNT=CRM.CLAIM_AMOUNT  
    AND CLD.CLAIM_APR_DATE=CRM.FOR_DATE AND CRM.Claim_Description = CLD.Purpose --- Added Purpose in join by Hardik 21/10/2020 for Nepra as same claim showing duplicate  
    
    Inner Join   
    (  
     SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.DEPT_ID,I.Grd_ID,I.Cat_ID,I.Type_ID,  
       I.Vertical_ID,I.Subvertical_ID,I.Segment_ID,I.Subbranch_ID,I.Emp_WeekDay_OT_Rate  
       ,I.Cmp_ID FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN   
         (  
         select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join  
          (  
           Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)  
           Where Increment_effective_Date <= @TO_DATE and Emp_ID=@Emp_ID  Group by emp_ID  
          ) new_inc on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date  
           Where TI.Increment_effective_Date <= @TO_DATE group by ti.emp_id  
        ) Qry on I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID  
         
    )INC_QRY ON EM.EMP_ID = INC_QRY.EMP_ID  
    Left Join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on Dm.Dept_Id=INC_QRY.Dept_ID  
    Left Join T0040_DESIGNATION_MASTER DSM WITH (NOLOCK) on DSM.Desig_ID=INC_QRY.Desig_Id  
    Left Join T0030_BRANCH_MASTER BM WITH (NOLOCK) on BM.Branch_ID=INC_QRY.Branch_ID  
    Left Join T0040_GRADE_MASTER GM WITH (NOLOCK) on GM.Grd_ID=INC_QRY.Grd_ID  
    Left Join T0040_Business_Segment BS WITH (NOLOCK) on BS.Segment_ID=INC_QRY.Segment_ID  
    Left Join T0040_Vertical_Segment VS WITH (NOLOCK) on VS.Vertical_ID=INC_QRY.Vertical_ID  
    Left Join T0050_SubVertical SV WITH (NOLOCK) on SV.SubVertical_ID=INC_QRY.SubVertical_ID  
    Left Join T0050_SubBranch SB WITH (NOLOCK) on SB.SubBranch_ID=INC_QRY.subBranch_ID   
    
    left JOIN  T0041_Claim_Maxlimit_Design CMD WITH (NOLOCK) ON CM.Claim_ID = CMD.Claim_ID and INC_QRY.Desig_Id = CMD.Desig_ID --Added by Jaina 26-07-2017  
    left JOIN  T0041_Claim_Maxlimit_Design CMDG WITH (NOLOCK) ON CM.Claim_ID = CMDG.Claim_ID and INC_QRY.Grd_ID = CMDG.Grade_ID -- ADDED BY RAJPUT ON 19032018   
    left JOIN  T0041_Claim_Maxlimit_Design CMDB WITH (NOLOCK) ON CM.Claim_ID =CMDB.Claim_ID and INC_QRY.Branch_ID = CMDB.Branch_ID  -- ADDED BY RAJPUT ON 19032018   
    
    left join T0040_CURRENCY_MASTER CMT WITH (NOLOCK) ON  CLD.Curr_ID=CMT.Curr_ID  --Added by Rajput on 16032018  
    
    
  WHERE CLD.Claim_Apr_ID=@Claim_Apr_ID AND CL.EMP_ID=@EMP_ID AND CL.CMP_ID=@CMP_ID  
  and isnull(CLD.Claim_Status,'A') <> 'R'  
  
  
  
  
  SELECT @REPORTING_MANAGER_NAME = STUFF((  
  SELECT ', ' + A.EMP_FULL_NAME   
  FROM DBO.T0080_EMP_MASTER AS A WITH (NOLOCK)  
  INNER JOIN DBO.T0115_CLAIM_LEVEL_APPROVAL AS B WITH (NOLOCK)  
  ON B.S_EMP_ID = A.EMP_ID  
  WHERE B.CLAIM_APP_ID = @CLAIM_APP_ID AND B.EMP_ID = @EMP_ID AND B.CMP_ID = @CMP_ID  
  FOR XML PATH, TYPE).value(N'.[1]', N'VARCHAR(MAX)'), 1, 2, '')  
  
  
  SELECT *,@REPORTING_MANAGER_NAME AS Reporting_Manager_Name FROM #CLAIM_CONSOL_REPORT_Apr  
 END  
END  
RETURN  
