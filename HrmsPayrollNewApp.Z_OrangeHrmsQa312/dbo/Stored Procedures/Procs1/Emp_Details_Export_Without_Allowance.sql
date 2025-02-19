---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)--- 
--Emp_Details_Export_Without_Allowance '119','06/17/2021 12:00:00 AM','07/16/2021 12:00:00 AM','0','0','0','0','0','0','25507','0'
CREATE PROCEDURE [dbo].[Emp_Details_Export_Without_Allowance]    
  @Company_Id NUMERIC    
 ,@From_Date  DATETIME  
 ,@To_Date   DATETIME  
 ,@Branch_ID  NUMERIC   
 ,@Grade_ID   NUMERIC  
 ,@Type_ID   NUMERIC  
 ,@Dept_ID   NUMERIC  
 ,@Desig_ID   NUMERIC  
 ,@Emp_ID   NUMERIC  
 ,@Constraint VARCHAR(MAX)  
 ,@Cat_ID        NUMERIC = 0  
 ,@is_Column  tinyint = 0  
AS    
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
    
 DECLARE @Year_End_Date AS DATETIME    
 DECLARE @User_type VARCHAR(30)    
     
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
       
 CREATE TABLE #Emp_Cons  
 (  
  Emp_ID NUMERIC  
 )  
   
 IF @Constraint <> ''  
  BEGIN  
   INSERT INTO #Emp_Cons(Emp_ID)  
   SELECT  CAST(DATA  AS NUMERIC) FROM dbo.Split (@Constraint,'#')   
  END  
 ELSE  
  BEGIN    
   INSERT INTO #Emp_Cons  
    SELECT I.Emp_Id   
     FROM dbo.T0095_INCREMENT I WITH (NOLOCK)  
      INNER JOIN (SELECT MAX(Increment_Id) AS Increment_Id, Emp_ID   --Changed by Hardik 10/09/2014 for Same Date Increment  
          FROM dbo.T0095_INCREMENT WITH (NOLOCK)  
          WHERE Increment_Effective_date <= @To_Date AND Cmp_ID = @Company_ID  
          GROUP BY emp_ID  
         ) Qry ON I.Emp_ID = Qry.Emp_ID AND I.Increment_Id = Qry.Increment_Id  
      INNER JOIN dbo.T0080_EMP_MASTER E WITH (NOLOCK) ON i.emp_ID = E.Emp_ID  
     WHERE E.CMP_ID = @Company_ID   
      AND i.BRANCH_ID = ISNULL(@BRANCH_ID ,i.BRANCH_ID)  
      AND ISNULL(i.Type_ID,0) = ISNULL(@Type_ID ,ISNULL(i.Type_ID,0))-- Added by Mitesh on 06/09/2011  
      AND ISNULL(i.Grd_ID,0) = ISNULL(@Grade_ID ,ISNULL(i.Grd_ID,0))  
      AND ISNULL(i.Dept_ID,0) = ISNULL(@Dept_ID ,ISNULL(i.Dept_ID,0))     
      AND ISNULL(i.Desig_ID,0) = ISNULL(@Desig_ID ,ISNULL(i.Desig_ID,0))     
      AND ISNULL(I.Emp_ID,0) = ISNULL(@Emp_ID ,ISNULL(I.Emp_ID,0))  
      AND ISNULL(I.Cat_ID,0) = ISNULL(@Cat_ID, ISNULL(I.Cat_ID,0))  
      AND Date_Of_Join <= @To_Date   
      AND I.emp_id IN(SELECT e.Emp_Id   
           FROM (SELECT e.emp_id, e.cmp_id, Date_Of_Join, ISNULL(Emp_left_Date, @To_Date) AS left_Date   
              FROM T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)  
             ) qry  
           WHERE cmp_id = @Company_id   
      AND ((@From_Date >= Date_Of_Join AND @From_Date <= Emp_left_date)   
        OR(@to_Date >= Date_Of_Join AND @To_Date <= Emp_left_date)  
        OR Emp_left_date IS NULL AND @To_Date >= Date_Of_Join)  
        OR @To_Date >= Emp_left_date AND @From_Date <= Emp_left_date )    
     
  END  
    

  -- Added by rohit For Add Customized Column in Employee list Report on 07112014  
 declare @sql       NVARCHAR(MAX)-- = N''  
 declare @colNames as varchar (max)--= N''  
   
   
 SET @sql  = N''  
 SET @colNames = N''  
  
 SELECT   
  --@colNames += ',' + QUOTENAME(REPLACE(CAST(column_name AS VARCHAR(MAX)),' ','_' ))  
  @colNames = @colNames + ',' + QUOTENAME(REPLACE(CAST(column_name AS VARCHAR(MAX)),' ','_' ))  --changed jimit 18042016  
  FROM T0081_CUSTOMIZED_COLUMN WITH (NOLOCK)  
  WHERE [cmp_Id] = @Company_Id and Active =1  
   
   
 CREATE TABLE #Cust_Column(Emp_ID Numeric(18,0));  
  
 DECLARE @ALTERCOLS NVARCHAR(MAX);  
   
 SELECT @ALTERCOLS = ISNULL(@ALTERCOLS  + '', ';') + 'ALTER  TABLE #Cust_Column ADD ' + DATA + ' Varchar(max)' FROM dbo.Split(@colNames, ',') Where Data <> '';  
   
 EXEC sp_executesql @ALTERCOLS;  
  
 SET @sql = N'  
 insert into #Cust_Column  
 SELECT emp_id ' + isnull(@colNames,'') + '   
 FROM (  
 SELECT emp_id, REPLACE(CAST(column_name AS VARCHAR(MAX)),'' '',''_'' ) as Column_Name   , value  
 FROM T0082_Emp_Column WITH (NOLOCK) inner join T0081_CUSTOMIZED_COLUMN WITH (NOLOCK) on T0082_Emp_Column.cmp_Id =T0081_CUSTOMIZED_COLUMN.Cmp_Id and T0082_Emp_Column.mst_Tran_Id = T0081_CUSTOMIZED_COLUMN.Tran_Id) up  
 PIVOT (max(value) FOR Column_Name IN ( ' + isnull(STUFF(@colNames, 1, 1, ''),'[0]') + ')) AS pvt  
 ORDER BY emp_id'  
   
 --drop table #Cust_Column  
   
   
 EXEC sp_executesql @sql;  
   
   
 ---Added By Jimit 08052018-----   
 if Object_ID('tempdb..#Emp_INC') is not null  
  drop TABLE #Emp_INC  
    
  CREATE Table #Emp_INC  
  (     
   Emp_ID  Numeric(18,0),     
   CTC   Numeric(18,2)   
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
 select * from dbo.fn_getEmpIncrementDetail(@Company_Id,@Constraint,@To_Date)  
   
--   select * from #Emp_INC_Detail_For_CTC
   INSERT Into #Emp_INC(Emp_ID)  
   SELECT      EC.Emp_ID  
   FROM  #Emp_Cons EC   
   ORDER BY EC.Emp_ID DESC  
     
     
     
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
           WHERE I3.Increment_effective_Date <= @TO_DATE AND I3.Cmp_ID = @Company_Id  and I3.Increment_Type Not IN ('Transfer','Deputation')  
           GROUP BY I3.EMP_ID    
           ) I3 ON I2.Increment_Effective_Date=I3.Increment_Effective_Date AND   
             I2.EMP_ID=I3.Emp_ID                                     
      GROUP BY I2.Emp_ID  
     ) I ON IE.Emp_ID = I.Emp_ID AND IE.Increment_ID=I.Increment_ID  
     
     
     
         
   UPDATE INC  
   SET    CTC = INC.CTC + Q.CTC   
   FROM   #EMP_INC INC INNER JOIN  
       #EMP_CONS EC ON EC.EMP_ID = INC.EMP_ID INNER JOIN  
       (  
      SELECT emp_Id,ISNULL(SUM(EID.E_AD_AMOUNT),0) AS CTC   
      FROM #Emp_INC_Detail_For_CTC EID INNER JOIN  
        T0050_AD_MASTER AM WITH (NOLOCK) ON EID.AD_ID = AM.AD_ID AND AM.AD_PART_OF_CTC = 1 AND AM.AD_FLAG = 'I'  
      WHERE AM.CMP_ID = @Company_Id   
      GROUP By EID.Emp_ID       
     )Q ON Q.Emp_Id = EC.Emp_ID   
       
   
     
 -------Ended----  
   
 CREATE TABLE #EMP_EXP  
 (  
  Emp_Id  INT,  
  OtherExp Numeric(9,2),  
  ExpInOrg Numeric(9,2),  
  TotalExp Numeric(9,2)  
 )  
 INSERT INTO #EMP_EXP(Emp_Id)  
 SELECT Emp_ID FROM #Emp_Cons  
  
  
 --Exp Other  
 
 UPDATE EX  
 SET  OtherExp = IsNull(EED.OtherExp,0)  
 FROM #EMP_EXP EX  
   INNER JOIN (SELECT  EED.Emp_ID, Sum((EmpExp - EmpExp % 1) * 12 + (case when  RIGHT(EmpExp, CHARINDEX('.', REVERSE(EmpExp) + '.') - 1) <= 12 then (EmpExp % 1) * 100 else (EmpExp % 1) * 10 END)) As OtherExp   
         FROM  T0090_EMP_EXPERIENCE_DETAIL EED WITH (NOLOCK)  
        INNER JOIN #EMP_CONS EC ON EED.Emp_ID=EC.Emp_ID  
      Group by EED.Emp_ID) EED ON EX.Emp_Id=EED.Emp_ID  
	  
 --Exp in Organization  
 UPDATE EX  
 SET  ExpInOrg = IsNull(DateDiff(M, E.Date_Of_Join, GetDate()),0)-1,  
   TotalExp = IsNull(OtherExp ,0) + IsNull(DateDiff(M, E.Date_Of_Join, GetDate()),0)  
 FROM #EMP_EXP EX  
   INNER JOIN T0080_EMP_MASTER E ON EX.Emp_Id=E.Emp_ID  
  
	-- Deepal 08-04-204 changes done in the Cliantha
   Update #EMP_EXP set ExpInOrg = 0 where ExpInOrg < 0

 --Exp in Year.Month  
	--UPDATE EX  
	--SET  OtherExp = IsNull((OtherExp - (OtherExp % 12)) / 12 + ((OtherExp % 12) / 10.00),0),  
		--  ExpInOrg = Cast(cast((ExpInOrg/12) as int) as varchar(50)) + '.' + cast(cast((ExpInOrg % 12) as int) as varchar(50)),  
		-- TotalExp = IsNull((TotalExp - (TotalExp % 12)) / 12 + ((TotalExp % 12) / 10.00),0)     
	--FROM #EMP_EXP EX  
	
	UPDATE	EX
	SET		OtherExp = IsNull((isnull(OtherExp,0) - (isnull(OtherExp,0) % 12)) / 12 + ((isnull(OtherExp,0) % 12) / 10.00),0),
			--ExpInOrg = IsNull((ExpInOrg - (ExpInOrg % 12)) / 12 + ((ExpInOrg % 12) / 10.00),0),
			ExpInOrg = Cast(cast((ExpInOrg/12) as int) as varchar(50)) + '.' + cast(cast((ExpInOrg % 12) as int) as varchar(50)),
			TotalExp = IsNull((TotalExp - (TotalExp % 12)) / 12 + ((TotalExp % 12) / 10.00),0)			
	FROM	#EMP_EXP EX 
		where isnull(ExpInOrg,0) > 0 
		-- Deepal 08-04-204 changes done in the Cliantha


 DECLARE @Status VARCHAR(10)   
    SET @Status =  ''  
      
    SELECT '="' + Alpha_Emp_Code + '"' AS Emp_code, Initial, Emp_First_Name as First_Name, Emp_Second_Name as Middle_Name, Emp_Last_Name as Last_Name, E.Emp_Full_Name,  
     BM.Branch_Name, GM.Grd_Name as Grade, DM.Desig_Name as Designation  
    ,TM.Type_Name as [Type], CM.Cat_Name as Category, DT.Dept_Name as Department, REPLACE(CONVERT(VARCHAR,Date_Of_Join,106),' ','-') AS Date_Of_Join,SHM.Shift_Name as Shift_Name  
    ,Qry_Reporting_Direct.Emp_Code as Manager_Code, Qry_Reporting_Direct.emp_full_name as Direct_Manager, Qry_Reporting_InDirect.Emp_Code + ' - ' + Qry_Reporting_InDirect.emp_full_name as InDirect_Manager ,  
    Enroll_No,EI.CTC, EI.CTC * 12 As Annual_CTC,  
    SB.SubBranch_Name, Inc_Qry.Gross_salary,Inc_Qry.Basic_Salary,(case when login_alias = '' then Login_Name ELSE login_alias END) as [Login],PSCM.Pay_Scale_Name,  
    (Case when E.Gender = 'M' then 'MALE' When E.Gender = 'F' then 'FEMALE' End )as Gender,  
    E.Other_Email as Personal_Email,Father_name,E.Mother_Name, REPLACE(CONVERT(VARCHAR,Date_Of_Birth,106),' ','-') AS Date_Of_Birth, Pan_No,SSN_No AS PF_NO,  
    SIN_No AS ESIC_No,(case WHEN E.is_PF_Trust = 1 then 'yes' else 'No' END)as Pf_Trust,E.Probation  
    ,CASE WHEN Marital_Status = 0 THEN 'Single'   
      WHEN Marital_Status = 1 THEN 'Married'   
      WHEN Marital_Status = 2 THEN 'Divorced'   
      WHEN Marital_Status = 3 THEN 'Separated'   
      WHEN Marital_Status = 4 THEN 'Widowed'   
     END AS Marital_Status ,  
    --REPLACE(CONVERT(VARCHAR,Emp_Confirm_Date,106),' ','-') AS Emp_Confirm_Date COMMENTED BY RAJPUT ON 03042018 FOR CERA CASE   
    (CASE WHEN ISNULL(Emp_Confirm_Date,'1900-01-01') = '1900-01-01' THEN '' ELSE REPLACE(CONVERT(VARCHAR,Emp_Confirm_Date,106),' ','-') END) AS Emp_Confirm_Date,REPLACE(CONVERT(VARCHAR,Date_of_Retirement,106),' ','-') AS Date_of_Retirement,E.Training_Month as Training_Month,  
    Despencery as Dispensary, Doctor_Name, DespenceryAddress as Dispensary_Address,REPLACE(CONVERT(VARCHAR,Emp_Offer_Date,106),' ','-') AS Offer_Date,Dr_Lic_No as License,REPLACE(CONVERT(VARCHAR,E.Dr_Lic_Ex_Date,106),' ','-') as License_expiry_date,  
    Tlm.Tally_Led_Name as Tally_Ledger_Name,E.Religion,E.Emp_UIDNo as UIDNO,E.Emp_Cast as Caste,Height,Emp_Mark_Of_Identification as Mark_Identification,  
    Insurance_No,  
    --REPLACE(CONVERT(VARCHAR,E.Emp_Annivarsary_Date,106),' ','-') as Annivarsary_Date, COMMENTED BY RAJPUT ON 03042018 FOR CERA CASE   
    (CASE WHEN ISNULL(CAST(E.Emp_Annivarsary_Date AS DATETIME),'') = '1900-01-01' THEN '' ELSE REPLACE(CONVERT(VARCHAR,CAST(E.Emp_Annivarsary_Date AS DATETIME),106),' ','-') END) as Annivarsary_Date,  
    E.Blood_Group,E.Emp_Dress_Code as Dress_Code,E.Emp_Shirt_Size as Shirt_Size  
    ,E.Emp_Pent_Size as Pent_Size,E.Emp_Shoe_Size as Shoe_Size,E.Emp_Canteen_Code as Canteen_Code,Slm.Skill_Name,E.Vehicle_NO,(case when E.Ration_Card_Type = 'NULL' then '' else E.Ration_Card_Type END) as Ration_Card_Type
		--,E.UAN_No--commented
		,( '="' + isnull(E.UAN_No,'') + '"') as UAN_No--added 
	,E.Aadhar_Card_No,E.Ration_Card_No  
    ,Inc_Qry.Emp_OT as Overtime ,Inc_Qry.Emp_WeekDay_OT_Rate as WeekDay_OT_Rate ,Inc_Qry.Emp_WeekOff_OT_Rate as Weekoff_OT_Rate , Inc_Qry.Emp_Holiday_OT_Rate as Holiday_OT_Rate  
     ,Inc_Qry.Emp_Late_Mark as Late_Mark,Inc_Qry.Emp_Early_mark as Early_Mark , Inc_Qry.Emp_Full_PF as Full_Pf,Inc_Qry.Emp_PT as PT, Inc_Qry.Emp_Fix_Salary as Fix_Salary, Inc_Qry.Emp_Part_time as Part_Time,Inc_Qry.Late_Dedu_Type as Late_deduction_Type,Inc_Qry.Wages_Type       
    ,Present_Street as Present_Address,Present_City, Present_State, Present_Post_Box,E.District_Wok as Present_District,E.Tehsil_Wok as Present_Tehsil,  
    Thm.ThanaName as Present_Police_Station,Street_1 AS [Permanent_Address], City as [Permanent_City], STATE as [Permanent_STATE], Zip_code AS Permanent_Post_Box,E.District as [Permanent_District],E.Tehsil as [Permanent_Tehsil],THM1.ThanaName as Permanent_Police_Station,  
    Lm.Loc_name as Location, Nationality,Home_Tel_no as personal_No, Mobile_No, Work_Tel_No, Work_Email  
    ,isnull(R.Source_Type_Names,'') as Source_Type_Names,isnull(R.Source_Names,'') as Source_Names,isnull(Q.Qual_Names,'') as Qualification --Added by Sumit on 20072016   
    ,E.Extension_No  
    ,(Select STUFF((SELECT ',' + Name from T0090_EMP_EMERGENCY_CONTACT_DETAIL EEC WITH (NOLOCK)  
       INNER join T0080_EMP_MASTER EM WITH (NOLOCK) On Em.Emp_ID = EEC.Emp_ID          
    WHERE EEC.Cmp_ID = @Company_Id and Em.emp_Id = Inc_Qry.Emp_ID FOR XML PATH('')), 1,1,'')) as Emergency_Contact_Name  
   ,(Select STUFF((SELECT ',' + EEC.RelationShip from T0090_EMP_EMERGENCY_CONTACT_DETAIL EEC WITH (NOLOCK)  
       INNER join T0080_EMP_MASTER EM WITH (NOLOCK) On Em.Emp_ID = EEC.Emp_ID          
    WHERE EM.Cmp_ID = @Company_Id and Em.emp_Id = Inc_Qry.Emp_ID FOR XML PATH('')), 1,1,'')) as Emergency_Contact_Relationship  
   ,('="' + (Select STUFF((SELECT ',' + EEC.Home_Tel_No from T0090_EMP_EMERGENCY_CONTACT_DETAIL EEC WITH (NOLOCK)  
       INNER join T0080_EMP_MASTER EM WITH (NOLOCK) On Em.Emp_ID = EEC.Emp_ID          
    WHERE EM.Cmp_ID = @Company_Id and Em.emp_Id = Inc_Qry.Emp_ID and EEC.Home_Tel_No <> '' FOR XML PATH('')), 1,1,'')) + '"') as Emergency_Contact_Home_Tel_No  
   ,('="' + (Select STUFF((SELECT ',' + EEC.Home_Mobile_No from T0090_EMP_EMERGENCY_CONTACT_DETAIL EEC WITH (NOLOCK)  
       INNER join T0080_EMP_MASTER EM WITH (NOLOCK) On Em.Emp_ID = EEC.Emp_ID          
    WHERE EM.Cmp_ID = @Company_Id and Em.emp_Id = Inc_Qry.Emp_ID FOR XML PATH('')), 1,1,'')) + '"' ) as Emergency_Contact_Mobile  
   ,('="' + (Select STUFF((SELECT ',' + EEC.Work_Tel_No from T0090_EMP_EMERGENCY_CONTACT_DETAIL EEC WITH (NOLOCK)  
       INNER join T0080_EMP_MASTER EM WITH (NOLOCK) On Em.Emp_ID = EEC.Emp_ID          
    WHERE EM.Cmp_ID = @Company_Id and Em.emp_Id = Inc_Qry.Emp_ID and EEc.Work_Tel_No <> '' FOR XML PATH('')), 1,1,''))+ '"' ) as Emergency_Contact_Work_Tel_No      
     
   ,Inc_Qry.Payment_Mode as Primary_Payment_Mode,Inc_qry.Payment_Mode_Two as Secondary_Payment_Mode,BN.Bank_Name As Primary_Bank_Name,BN1.Bank_Name As Secondary_Bank_Name,  
   Inc_Qry.Bank_Branch_Name As Primary_Bank_Branch, Inc_Qry.Bank_Branch_Name_Two As Secondary_Bank_Branch,  
   ( '="' + Inc_Qry.Inc_Bank_Ac_No + '"') as Primary_Bank_Account_No,( '="' + Inc_Qry.Inc_Bank_AC_No_Two + '"') as Secondary_Bank_Account_No,  
   e.Ifsc_Code As Primary_IFSC_Code,E.Ifsc_Code_Two As Secondary_IFSC_Code,   
   E.EmpName_Alias_PrimaryBank as Employee_Name_for_Primary_Bank,E.EmpName_Alias_SecondaryBank as Employee_Name_for_Secondary_Bank,     
   [dbo].[F_GET_AGE] (E.Date_Of_Join,GETDATE(),'Y','N') AS Work_Exp_Month       
   , e.Old_Ref_No,e.Dealer_Code, ISNULL(ccm.Center_Name,'') AS Cost_Center_Name, @Status AS Status  
   ,(CASE ISNULL(E.Date_Of_Birth,'') WHEN '' THEN '' ELSE [dbo].[F_GET_AGE] (E.Date_Of_Birth,GETDATE(),'Y','N') END) AS Age     
   , SCM.Name As Salary_Cycle, BS.Segment_Name as Business_segment, VS.Vertical_Name    
   , SV.SubVertical_Name         
   , REPLACE(CONVERT(VARCHAR,E.GroupJoiningDate,106),' ','-') AS Group_Join_Date  
   ,CC.*    
   ,emp_ot_min_limit as Ot_MIN_LIMIT,emp_ot_max_limit as Ot_MAx_LIMIT,Emp_Late_Limit as LATE_LIMIT,emp_early_limit as EARLY_LIMIT   
   ,E.CompOff_Min_hrs As Minimum_CompOff_Hours,Case When E.Image_Name like '0.jpg' then '' else e.Image_Name End as Image_Name  
   ,case when isnull(E.Is_Lwf,0) =0 then 'No' else 'Yes' end LWF  
   ,Case When ISNULL(E.Salary_Depends_on_Production,0) = 1 then 'Yes' Else 'No' END as Salary_Depends_on_Production --Added By Ramiz on 06/05/2016     
   ,isnull(SM.State_Name,'') as Branch_State_Name --Added by Sumit 21Jun2016 for BMA         
   ,Inc_Qry.Salary_Basis_On as Salary_On,CUM.Curr_Name as Currency,E.Extra_AB_Deduction,Early_Dedu_Type as Early_deduction_Type  
   ,E.Emp_PF_Opening,E.Yearly_Leave_Days,E.Yearly_Leave_Amount,E.Yearly_Bonus_Per,E.Yearly_Bonus_Amount,Deputation_End_Date,BN1.Bank_BSR_Code  
   ,( '="' + E.DBRD_Code + '"') as DBRD_Code,E.CCenter_Remark AS CostCenter_Remark,Fix_OT_Hour_Rate_WD as Fix_OT_Hours_Rate_WeekDay,Fix_OT_Hour_Rate_WO_HO as Fix_OT_Hours_Rate_Wo_Ho  
   ,E.EmpName_Alias_Salary as Employee_Name_for_Salary,E.EmpName_Alias_PF as Employee_Name_for_PF  
   ,E.EmpName_Alias_PT as Employee_Name_for_PT,E.EmpName_Alias_Tax as Employee_Name_for_Tax,E.EmpName_Alias_ESIC as Employee_Name_for_ESIC     
   ,E.Emp_Notice_Period as Notice_Period_Days  
   ,E.CompOff_HO_App_Days,E.CompOff_HO_Avail_Days,E.CompOff_WO_App_Days,E.CompOff_WO_Avail_Days  
   ,E.CompOff_WD_App_Days,E.CompOff_WD_Avail_Days  
   ,Inc_Qry.Branch_ID,Inc_Qry.Dept_ID,Inc_Qry.Vertical_ID,inc_qry.SubVertical_ID  
   ,Inc_Qry.Sales_Code,--added by jimit 27022017  
   REPLACE(CONVERT(VARCHAR,Emp_Offer_Date,106),' ','-') AS Emp_Offer_Date,  --Added By Rajput 22062017   
   Emp_Left as Employee_Left, 
   REPLACE(CONVERT(VARCHAR,Emp_Left_Date,106),' ','-') AS Left_Date,
    CASE WHEN (LE.Is_TERMINATE=0 AND LE.Is_RETIRE=0 AND LE.Is_Absconded=0 AND LE.Is_Death=0) THEN 'Resignation' -- Added By Sajid 28-12-2023 
   WHEN LE.Is_RETIRE=1 THEN 'Retirement' 
   WHEN LE.Is_TERMINATE=1 THEN 'Terminated' 
   WHEN LE.Is_Death=1 THEN 'Death' 
   WHEN LE.Is_Absconded=1 THEN 'Absconded' END AS Left_Reason,
   CASE WHEN (LE.Is_TERMINATE=0 AND LE.Is_RETIRE=0 AND LE.Is_Absconded=0 AND LE.Is_Death=0) THEN REPLACE(CONVERT(VARCHAR,LE.Reg_Date,106),' ','-') END AS Resignation_Date , -- Added By Sajid 28-12-2023 Because of Client Required Seprate Date Type Wise. 
   CASE WHEN LE.Is_RETIRE=1 THEN REPLACE(CONVERT(VARCHAR,LE.Reg_Date,106),' ','-') END AS  Retirement_Date , -- Added By Sajid 28-12-2023 Because of Client Required Seprate Date Type Wise. 
   CASE WHEN LE.Is_TERMINATE=1 THEN REPLACE(CONVERT(VARCHAR,LE.Reg_Date,106),' ','-') END AS  Terminated_Date , -- Added By Sajid 28-12-2023 Because of Client Required Seprate Date Type Wise. 
   CASE WHEN LE.Is_Death=1 THEN REPLACE(CONVERT(VARCHAR,LE.Reg_Date,106),' ','-') END AS Death_Date , -- Added By Sajid 28-12-2023 Because of Client Required Seprate Date Type Wise. 
   CASE WHEN LE.Is_Absconded=1 THEN REPLACE(CONVERT(VARCHAR,LE.Reg_Date,106),' ','-') END AS Absconded_Date , -- Added By Sajid 28-12-2023 Because of Client Required Seprate Date Type Wise.       
  
   CASE WHEN ISNULL(Inc_Qry.Is_physical,0) = 1 THEN 'Yes' ELSE 'No' END AS Physically_Disabled --Added By Ramiz on 12/06/2018  
   ,Inc_Qry.Physical_Percent as Percentage_Of_Disability  --added by Krushna 09-07-2018  
   ,Inc_Qry.Emp_Childran as No_of_Children   --added by jimit 01092018  
   ,EX.OtherExp As Other_Experience  
   ,Ex.ExpInOrg As Experience_In_Org  
   ,Ex.TotalExp As Total_Experience  
   ,Is_Gr_App As Grauity_Applicable  
  FROM dbo.T0080_EMP_MASTER E WITH (NOLOCK)  
   inner JOIN #Emp_Cons EC ON e.emp_id = Ec.emp_ID   
   INNER JOIN (SELECT T0095_INCREMENT.Emp_Id, cat_id, Grd_ID, Dept_ID, Desig_Id, Branch_Id, TYPE_ID, Bank_id,Bank_ID_Two, Curr_id, Wages_Type  
        , Salary_Basis_on, Basic_salary, Gross_salary, Inc_Bank_Ac_No,Inc_Bank_AC_No_Two, Emp_OT, Emp_WeekDay_OT_Rate , Emp_WeekOff_OT_Rate , Emp_Holiday_OT_Rate  
        , Emp_Late_Mark, Emp_Full_PF, Emp_PT, Emp_Fix_Salary  
        , Emp_Part_time, Late_Dedu_Type, Emp_Childran, Center_ID  
        , SalDate_ID, Segment_ID, Vertical_ID, SubVertical_ID, SubBranch_ID , CTC -- Added By Hiral 22 August, 2013  
        ,emp_ot_min_limit,emp_ot_max_limit,Emp_Late_Limit,emp_early_limit,Payment_Mode,Payment_Mode_Two,Early_Dedu_Type,Deputation_End_Date          
        ,Fix_OT_Hour_Rate_WD,Fix_OT_Hour_Rate_WO_HO,Sales_Code,Bank_Branch_Name, Bank_Branch_Name_Two,Emp_Early_mark , Is_physical  
        ,Physical_Percent  
       FROM T0095_INCREMENT WITH (NOLOCK)  
        INNER JOIN (  
            SELECT MAX(I.INCREMENT_ID) AS INCREMENT_ID, I.EMP_ID   
            FROM T0095_INCREMENT I WITH (NOLOCK)  
            INNER JOIN   
            (  
              SELECT MAX(i3.INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID  
              FROM T0095_INCREMENT I3 WITH (NOLOCK)  
              WHERE I3.Increment_effective_Date <= @To_Date  
              GROUP BY I3.EMP_ID    
             ) I3 ON I.Increment_Effective_Date=I3.Increment_Effective_Date AND I.EMP_ID=I3.Emp_ID   
              WHERE I.INCREMENT_EFFECTIVE_DATE <= @To_Date and I.Cmp_ID = @Company_id  
              GROUP BY I.emp_ID    
           ) Qry ON T0095_INCREMENT.Emp_ID = Qry.Emp_ID AND T0095_INCREMENT.Increment_ID = Qry.Increment_Id     
       WHERE cmp_id = @Company_ID  
      ) Inc_Qry ON e.Emp_ID = Inc_Qry.Emp_ID   
   INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Inc_Qry.Grd_Id = GM.Grd_Id   
   INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Inc_Qry.Branch_ID = BM.Branch_Id  
   INNER JOIN T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON Inc_Qry.Desig_Id = DM.Desig_Id  
   LEFT OUTER JOIN T0040_BANK_MASTER BN WITH (NOLOCK) ON Inc_Qry.Bank_id = BN.Bank_Id   
   Left OUTER JOIN T0040_BANK_MASTER BN1  WITH (NOLOCK) On Inc_Qry.Bank_ID_Two = Bn1.Bank_ID  
   LEFT OUTER JOIN T0040_TYPE_MASTER TM WITH (NOLOCK) ON Inc_Qry.Type_Id = TM.Type_Id  
   LEFT OUTER JOIN T0030_CATEGORY_MASTER CM WITH (NOLOCK) ON Inc_Qry.Cat_id = CM.Cat_Id  
   LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DT WITH (NOLOCK) ON Inc_Qry.Dept_Id = DT.Dept_Id    
   LEFT OUTER JOIN T0040_COST_CENTER_MASTER CCM WITH (NOLOCK) ON CCM.Center_ID = Inc_Qry.Center_ID  
   LEFT OUTER JOIN T0040_Salary_Cycle_Master SCM WITH (NOLOCK) ON SCM.Tran_ID = Inc_Qry.SalDate_ID  -- Added By Hiral 22 August, 2013  
   LEFT OUTER JOIN T0040_Business_Segment BS WITH (NOLOCK) On BS.Segment_ID = Inc_Qry.Segment_ID   -- Added By Hiral 22 August, 2013  
   LEFT OUTER JOIN T0040_Vertical_Segment VS WITH (NOLOCK) On VS.Vertical_ID = Inc_Qry.Vertical_ID  -- Added By Hiral 22 August, 2013  
   LEFT OUTER JOIN T0050_SubVertical SV WITH (NOLOCK) On SV.SubVertical_ID =  Inc_Qry.SubVertical_ID  -- Added By Hiral 22 August, 2013  
   LEFT OUTER JOIN T0050_SubBranch SB WITH (NOLOCK) On SB.SubBranch_ID = Inc_Qry.SubBranch_ID   -- Added By Hiral 22 August, 2013  
   Left OUTER JOIN T0020_STATE_MASTER SM WITH (NOLOCK) on SM.State_ID=BM.State_ID and SM.Cmp_ID=BM.Cmp_ID  
   Left join #Cust_Column CC on ec.Emp_ID = CC.emp_id    
   LEFT OUTER JOIN --Removed by Nimesh on 30-11-2015 (Duplicate records are displaying for emp code top2010821064)  
                          (SELECT   R1.Emp_ID, Effect_Date AS Effect_Date, R_Emp_ID,Em.emp_full_name,Em.Alpha_Emp_Code as emp_code  
                            FROM    dbo.T0090_EMP_REPORTING_DETAIL R1 WITH (NOLOCK)  
         INNER JOIN (SELECT MAX(ROW_ID) AS ROW_ID, R2.Emp_ID  
            FROM T0090_EMP_REPORTING_DETAIL R2 WITH (NOLOCK)  
             INNER JOIN (  
                SELECT MAX(R3.Effect_Date) AS Effect_Date, R3.Emp_ID   
                FROM T0090_EMP_REPORTING_DETAIL R3 WITH (NOLOCK)  
                WHERE R3.Effect_Date < GETDATE() and Cmp_ID = @Company_Id  
                GROUP BY R3.Emp_ID  
                ) R3 ON R2.Emp_ID=R3.Emp_ID AND R2.Effect_Date=R3.Effect_Date  
            WHERE Reporting_Method = 'Direct'  
            GROUP BY R2.Emp_ID  
            ) R2 ON R1.Row_ID=R2.ROW_ID AND R1.Emp_ID=R2.Emp_ID  
         INNER JOIN t0080_emp_master Em WITH (NOLOCK) on R1.R_emp_id = Em.emp_id  
       ) AS Qry_Reporting_Direct ON E.Emp_ID = Qry_Reporting_Direct.Emp_ID  
   LEFT OUTER JOIN --Added By Ramiz so that we can show 1 Direct and 1 Indirect Reporting Manager  
                          (SELECT   R1.Emp_ID, Effect_Date AS Effect_Date, R_Emp_ID,Em.emp_full_name,Em.Alpha_Emp_Code as emp_code  
                            FROM    dbo.T0090_EMP_REPORTING_DETAIL R1 WITH (NOLOCK)  
         INNER JOIN (SELECT MAX(ROW_ID) AS ROW_ID, R2.Emp_ID  
            FROM T0090_EMP_REPORTING_DETAIL R2 WITH (NOLOCK)  
             INNER JOIN (  
                SELECT MAX(R3.Effect_Date) AS Effect_Date, R3.Emp_ID   
                FROM T0090_EMP_REPORTING_DETAIL R3  WITH (NOLOCK)  
                WHERE R3.Effect_Date < GETDATE() and Cmp_ID = @Company_Id  
                GROUP BY R3.Emp_ID  
                ) R3 ON R2.Emp_ID=R3.Emp_ID AND R2.Effect_Date=R3.Effect_Date  
            WHERE Reporting_Method = 'InDirect'  
            GROUP BY R2.Emp_ID  
            ) R2 ON R1.Row_ID=R2.ROW_ID AND R1.Emp_ID=R2.Emp_ID  
         INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON R1.R_EMP_ID = EM.EMP_ID  
       ) AS Qry_Reporting_InDirect ON E.Emp_ID = Qry_Reporting_InDirect.Emp_ID  
  left outer JOIN  T0040_SKILL_MASTER SLM WITH (NOLOCK) On SLm.Skill_ID = E.SkillType_ID and Sm.Cmp_ID = E.Cmp_ID   
  Left Outer join  T0030_Thana_Master THM WITH (NOLOCK) On THM.Thana_Id = E.Thana_Id and thm.Cmp_Id = e.Cmp_ID  
  Left Outer join  T0030_Thana_Master THM1  WITH (NOLOCK) ON  Thm1.Thana_Id = E.Thana_Id_Wok and thm1.Cmp_Id = E.Cmp_ID   
  Left Outer JOIN  T0040_Tally_Led_Master TLM WITH (NOLOCK) On TLM.Tally_Led_ID = E.Tally_Led_Id and TLM.Cmp_Id = E.Cmp_ID  
  Left outer JOIN     T0001_LOCATION_MASTER LM WITH (NOLOCK) on Lm.Loc_Id = E.Loc_ID   
  --Left OUTER JOIN  T0040_SHIFT_MASTER SHM WITH (NOLOCK) on SHM.Shift_ID = E.shift_Id  Commented to Line and add the below code to take the Max Shift ID on for_date  
  LEFT OUTER JOIN  (  
       SELECT    PSC.Emp_ID,PSC.Cmp_ID,PSC.Shift_ID,PSC.For_Date  
           from       T0100_EMP_SHIFT_DETAIL PSC inner JOIN  
          (SELECT max(For_Date)as  For_date,Emp_ID   
           from   T0100_EMP_SHIFT_DETAIL  SD
		   inner join T0040_SHIFT_MASTER SM WITH (NOLOCK) on SD.Shift_ID = SM.Shift_ID and SM.Is_InActive = 0 -- Deepal Added the inner join  18-2-2025
           where  For_date <= @To_Date and SD.Cmp_ID = @Company_ID  
           GROUP by Emp_ID)Qr On Qr.Emp_ID = PSC.Emp_ID and Qr.For_date= PSC.For_Date   
       WHERE Cmp_ID = @Company_ID  
  ) SH_1 On SH_1.Emp_ID = e.Emp_ID    
  Left OUTER JOIN  T0040_SHIFT_MASTER SHM on SHM.Shift_ID = SH_1.shift_Id  and  SHM.Cmp_ID = SH_1.cmp_Id  
  Left Outer JOIN  T0011_LOGIN L  WITH (NOLOCK) On L.Emp_ID = E.Emp_ID  
  Left Outer JOIN  (SELECT     psc.Pay_Scale_ID,PSC.Emp_ID,PSC.Cmp_ID  
           from       T0050_EMP_PAY_SCALE_DETAIL PSC WITH (NOLOCK) inner JOIN  
          (SELECT max(Pay_Scale_ID)as  pay_scale_Id,Emp_ID   
           from   T0050_EMP_PAY_SCALE_DETAIL WITH (NOLOCK)  
           where  Effective_Date <= @To_Date and Cmp_ID = @Company_ID  
           GROUP by Emp_ID)Qr On Qr.Emp_ID = PSC.Emp_ID and Qr.pay_scale_Id= PSC.Pay_Scale_ID     
       WHERE Cmp_ID = @Company_ID ) Qr_1 On Qr_1.Emp_ID = e.Emp_ID  
  Left Outer join    T0040_PAY_SCALE_MASTER PSCM WITH (NOLOCK) On PSCM.Pay_Scale_ID = Qr_1.Pay_Scale_ID and pscm.Cmp_ID = Qr_1.cmp_Id  
  Left Outer JOIN    T0040_CURRENCY_MASTER  CUM WITH (NOLOCK) On CUM.Curr_ID = E.Curr_ID and CUm.Cmp_ID = E.Cmp_ID  
  Left Outer Join T0100_LEFT_EMP LE WITH (NOLOCK) On E.Emp_ID=LE.Emp_ID  
  --Added by Sumit on 20072016  
  LEFT OUTER JOIN (  
               
    SELECT distinct STUFF((SELECT ',' + Source_Type_Name   
         FROM T0080_EMP_MASTER A WITH (NOLOCK)  
         right outer join T0090_EMP_REFERENCE_DETAIL B WITH (NOLOCK) ON A.Emp_ID = B.Emp_ID  AND A.Cmp_ID=B.Cmp_ID  
         inner join T0030_Source_Type_Master STM WITH (NOLOCK) on STM.Source_Type_ID=B.Source_Type  
         WHERE B.Emp_ID=R.Emp_ID AND B.Cmp_ID=R.Cmp_ID  
         for xml path('')) , 1,1,''  
        ) As Source_Type_Names,R.Emp_ID, R.Cmp_ID,  
      STUFF((SELECT ',' + SM.Source_Name   
         FROM T0080_EMP_MASTER A WITH (NOLOCK)  
         right outer join T0090_EMP_REFERENCE_DETAIL B WITH (NOLOCK) ON A.Emp_ID = B.Emp_ID  AND A.Cmp_ID=B.Cmp_ID  
         inner join T0040_Source_Master SM WITH (NOLOCK) on SM.Source_Id=B.Source_Name  
         WHERE B.Emp_ID=R.Emp_ID AND B.Cmp_ID=R.Cmp_ID  
         for xml path('')) , 1,1,''  
        ) As Source_Names   
      FROM T0090_EMP_REFERENCE_DETAIL R WITH (NOLOCK)  
     ) R ON R.Cmp_ID =E.Cmp_ID AND R.Emp_ID=E.Emp_ID  
    
  Left outer Join   
    (  
     SELECT distinct STUFF((SELECT ',' + Qual_Name   
          FROM T0080_EMP_MASTER A WITH (NOLOCK)  
          right outer join T0090_EMP_QUALIFICATION_DETAIL Q1 WITH (NOLOCK) ON A.Emp_ID = Q1.Emp_ID  AND A.Cmp_ID=Q1.Cmp_ID  
          inner join T0040_QUALIFICATION_MASTER QM WITH (NOLOCK) on QM.Qual_ID=Q1.Qual_ID  
         WHERE Q1.Emp_ID=Q.Emp_ID AND Q1.Cmp_ID=Q1.Cmp_ID  
         for xml path('')) , 1,1,''  
        ) As Qual_Names,Q.Emp_ID, Q.Cmp_ID  
      FROM T0090_EMP_QUALIFICATION_DETAIL Q WITH (NOLOCK)  
    ) Q ON Q.Cmp_ID =E.Cmp_ID AND Q.Emp_ID=E.Emp_ID    
  LEFT Outer Join #Emp_INC EI ON EI.Emp_Id = Ec.emp_ID  -----Added By Jimit 08052018-------     
  LEFT OUTER JOIN #EMP_EXP EX ON EC.Emp_ID=EX.Emp_ID  
      
  where -- Added by Rajput 20062017 Due To Left Employee Show in Report  
  E.EMP_ID IN(SELECT qry.Emp_Id   
     FROM (  
       SELECT e.emp_id, e.cmp_id, Date_Of_Join, ISNULL(Emp_left_Date, @To_Date) AS left_Date   
       FROM T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)  
      ) qry  
     WHERE cmp_id = @Company_id   
      AND (@From_Date >= Date_Of_Join AND @From_Date <= Emp_left_date)   
        OR(@to_Date >= Date_Of_Join AND @To_Date <= Emp_left_date)  
        OR (Emp_left_date IS NULL AND @To_Date >= Date_Of_Join)  
        OR (@To_Date >= Emp_left_date AND @From_Date <= Emp_left_date )     
     )  
       
  Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)  
   When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)  
    Else e.Alpha_Emp_Code  
   End   
  --ORDER BY RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500)  
  --e.Emp_code     
 RETURN
