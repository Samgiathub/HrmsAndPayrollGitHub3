  
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[SP_RPT_EMP_OFFER_SALARY_GET_Format2]  
  @CMP_ID  NUMERIC  
 ,@FROM_DATE  DATETIME  
 ,@TO_DATE  DATETIME   
 ,@BRANCH_ID  NUMERIC   = 0  
 ,@CAT_ID  NUMERIC  = 0  
 ,@GRD_ID  NUMERIC = 0  
 ,@TYPE_ID  NUMERIC  = 0  
 ,@DEPT_ID  NUMERIC  = 0  
 ,@DESIG_ID  NUMERIC = 0  
 ,@EMP_ID  NUMERIC  = 0  
 ,@CONSTRAINT VARCHAR(MAX) = ''  
 ,@LETTER  VARCHAR(30)= 'Offer'  
    ,@PBRANCH_ID VARCHAR(200) = '0'  
    ,@Show_Hidden_Allowance  bit = 0   --Added by Jaina 24-12-2016  
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
    
 DECLARE @YEAR_END_DATE AS DATETIME    
 DECLARE @USER_TYPE VARCHAR(30)    
     
set @Show_Hidden_Allowance = 0    
   
 IF @BRANCH_ID = 0    
 SET @BRANCH_ID = NULL     
 IF @GRD_ID = 0    
  SET @GRD_ID = NULL    
 IF @EMP_ID = 0    
 SET @EMP_ID = NULL    
 IF @DESIG_ID = 0    
 SET @DESIG_ID = NULL    
 IF @DEPT_ID = 0    
 SET @DEPT_ID = NULL   
   
 CREATE TABLE #EMP_CONS   
 (        
 EMP_ID NUMERIC ,       
 BRANCH_ID NUMERIC,  
 INCREMENT_ID NUMERIC  
 )       
   
 EXEC SP_RPT_FILL_EMP_CONS  @CMP_ID,@FROM_DATE,@TO_DATE,@BRANCH_ID,@CAT_ID,@GRD_ID,@TYPE_ID,@DEPT_ID,@DESIG_ID ,@EMP_ID ,@CONSTRAINT ,0 ,0 ,0,0,0,0,0,0,3,0,0,0  
 CREATE NONCLUSTERED INDEX IX_EMP_CONS_EMPID ON #EMP_CONS (EMP_ID);    
  
 --Declare @Emp_Cons Table  
 --(  
 -- Emp_ID numeric  
 --)  
   
 --if @Constraint <> ''  
 -- begin  
 --  Insert Into @Emp_Cons(Emp_ID)  
 --  select  cast(data  as numeric) from dbo.Split (@Constraint,'#')   
 -- end  
 --else  
 -- begin  
 --  if @PBranch_ID <> '0' and isnull(@Branch_ID,0) = 0  
 --    Begin  
 --  Insert Into @Emp_Cons  
                 
 --   select I.Emp_Id from dbo.T0095_INCREMENT I inner join   
 --     ( select max(Increment_effective_Date) as For_Date , Emp_ID from dbo.T0095_INCREMENT  
 --     where Increment_Effective_date <= @To_Date  
 --     and Cmp_ID = @Cmp_ID  
 --     group by emp_ID  ) Qry on  
 --     I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date  Inner join  
 --     dbo.T0080_EMP_MASTER E on i.emp_ID = E.Emp_ID  
 --    Where E.CMP_ID = @Cmp_ID   
 --    --and i.BRANCH_ID = isnull(@BRANCH_ID ,i.BRANCH_ID)  
 --    and i.Branch_ID in (select cast(isnull(data,0) as numeric) from dbo.Split(@PBranch_ID,'#'))  
 --    and i.Grd_ID = isnull(@Grd_ID ,i.Grd_ID)  
 --    and isnull(i.Dept_ID,0) = isnull(@Dept_ID ,isnull(i.Dept_ID,0))     
 --    and Isnull(i.Desig_ID,0) = isnull(@Desig_ID ,Isnull(i.Desig_ID,0))     
 --    and ISNULL(I.Emp_ID,0) = isnull(@Emp_ID ,ISNULL(I.Emp_ID,0))  
 --    and Date_Of_Join <= @To_Date and I.emp_id in(  
 --     select e.Emp_Id from  
 --     (select e.emp_id, e.cmp_id, Date_Of_Join, isnull(Emp_left_Date, @To_Date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry  
 --     where cmp_id = @Cmp_ID   and    
 --     (( @From_Date  >= Date_Of_Join  and  @From_Date <= Emp_left_date )   
 --     or ( @to_Date  >= Date_Of_Join  and @To_Date <= Emp_left_date )  
 --     or Emp_left_date is null and @To_Date >= Date_Of_Join)  
 --     or @To_Date >= Emp_left_date  and  @From_Date <= Emp_left_date )    
 --    End  
 --  else  
 --    Begin  
 --      Insert Into @Emp_Cons  
                 
 --   select I.Emp_Id from dbo.T0095_INCREMENT I inner join   
 --     ( select max(Increment_effective_Date) as For_Date , Emp_ID from dbo.T0095_INCREMENT  
 --     where Increment_Effective_date <= @To_Date  
 --     and Cmp_ID = @Cmp_ID  
 --     group by emp_ID  ) Qry on  
 --     I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date  Inner join  
 --     dbo.T0080_EMP_MASTER E on i.emp_ID = E.Emp_ID  
 --    Where E.CMP_ID = @Cmp_ID   
 --    and i.BRANCH_ID = isnull(@BRANCH_ID ,i.BRANCH_ID)  
 --    and i.Grd_ID = isnull(@Grd_ID ,i.Grd_ID)  
 --    and isnull(i.Dept_ID,0) = isnull(@Dept_ID ,isnull(i.Dept_ID,0))     
 --    and Isnull(i.Desig_ID,0) = isnull(@Desig_ID ,Isnull(i.Desig_ID,0))     
 --    and ISNULL(I.Emp_ID,0) = isnull(@Emp_ID ,ISNULL(I.Emp_ID,0))  
 --    and Date_Of_Join <= @To_Date and I.emp_id in(  
 --     select e.Emp_Id from  
 --     (select e.emp_id, e.cmp_id, Date_Of_Join, isnull(Emp_left_Date, @To_Date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry  
 --     where cmp_id = @Cmp_ID   and    
 --     (( @From_Date  >= Date_Of_Join  and  @From_Date <= Emp_left_date )   
 --     or ( @to_Date  >= Date_Of_Join  and @To_Date <= Emp_left_date )  
 --     or Emp_left_date is null and @To_Date >= Date_Of_Join)  
 --     or @To_Date >= Emp_left_date  and  @From_Date <= Emp_left_date )   
 --    End    
     
 -- end  
---------------------    
   
CREATE TABLE #CTCMAST  
(  
 TRAN_ID  NUMERIC IDENTITY(1,1),    
 CMP_ID  NUMERIC,  
 Branch_ID numeric,  
 Increment_ID numeric,  
 EMP_ID  NUMERIC,  
 DEF_ID  NUMERIC,  
 LABEL_HEAD VARCHAR(100),  
 MONTHLY_AMT NUMERIC(18,2),  
 YEARLY_AMT NUMERIC(18,2),  
 AD_ID  NUMERIC,  
 AD_FLAG  CHAR(1),  
 AD_DEF_ID NUMERIC,  
 GROUP_NAME VARCHAR(100) NULL,  
 SEQ_NO NUMERIC(18,2) NULL,  
 SALARY_GROUP VARCHAR(100)NULL,
 Band_Name  VARCHAR(100)NULL
 --,Is_Pradhan_Mantri  bit,
 --Is_1time_PF_Member bit
)  
 ----------------------------------------------------------------  
  
CREATE TABLE #Tbl_Get_AD  
(  
 Emp_ID NUMERIC(18,0),  
 Ad_ID NUMERIC(18,0),  
 for_date DATETIME,  
 E_Ad_Percentage NUMERIC(18,5),  
 M_Ad_Amount  NUMERIC(18,2)  
)  
  
INSERT INTO #Tbl_Get_AD  
 Exec P_Emp_Revised_Allowance_Get @Cmp_ID,@To_Date,@Constraint  
  
DECLARE @COLUMNS NVARCHAR(2000)  
DECLARE @CTC_CMP_ID NUMERIC(18,0)  
DECLARE @CTC_EMP_ID NUMERIC(18,0)  
DECLARE @CTC_BASIC NUMERIC(18,2)  
DECLARE @AD_NAME_DYN NVARCHAR(100)  
DECLARE @VAL NVARCHAR(500)  
  
SET @COLUMNS = '#'  
  
 DECLARE @CUR_Band_Name AS VARCHAR(100)
 DECLARE @CUR_Is_Pradhan_Mantri AS bit 
 DECLARE @CUR_Is_1time_PF_Member AS bit  

DECLARE ALLOW_DEDU_CURSOR CURSOR FOR  
 SELECT AD_NAME FROM T0050_AD_MASTER WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND AD_PART_OF_CTC = 1 AND AD_NOT_EFFECT_SALARY = 0   
      AND AD_FLAG = 'I' AND ISNULL(ALLOWANCE_TYPE,'A') = 'A' ORDER BY AD_LEVEL  
 OPEN ALLOW_DEDU_CURSOR  
   FETCH NEXT FROM ALLOW_DEDU_CURSOR INTO @AD_NAME_DYN  
   WHILE @@FETCH_STATUS = 0  
    BEGIN  
     SET @AD_NAME_DYN = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@AD_NAME_DYN)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')  
     Set @Columns = @Columns +  REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_') + '#'  
     FETCH NEXT FROM ALLOW_DEDU_CURSOR INTO @AD_NAME_DYN  
    END  
 CLOSE ALLOW_DEDU_CURSOR   
 DEALLOCATE ALLOW_DEDU_CURSOR  
  ----------------------------------------------------------------     
SET @COLUMNS = @COLUMNS +  'Reimbersement_Salary#'  
   
 ----------------------------------------------------------------  
DECLARE ALLOW_DEDU_CURSOR CURSOR FOR  
  SELECT AD_NAME FROM T0050_AD_MASTER WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND AD_PART_OF_CTC = 1 AND AD_NOT_EFFECT_SALARY = 1   
              AND AD_FLAG = 'I' AND ISNULL(ALLOWANCE_TYPE,'A')='R'   
              AND (CASE WHEN @SHOW_HIDDEN_ALLOWANCE = 0 AND Hide_In_Reports = 1  THEN 0 ELSE 1 END) = 1 --Added by Jaina 09-01-2017  
              ORDER BY AD_LEVEL  
 OPEN ALLOW_DEDU_CURSOR  
   FETCH NEXT FROM ALLOW_DEDU_CURSOR INTO @AD_NAME_DYN  
   WHILE @@FETCH_STATUS = 0  
    BEGIN  
     SET @AD_NAME_DYN = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@AD_NAME_DYN)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')  
     SET @COLUMNS = @COLUMNS +  REPLACE(RTRIM(LTRIM(@AD_NAME_DYN)),' ','_') + '#'  
    FETCH NEXT FROM ALLOW_DEDU_CURSOR INTO @AD_NAME_DYN  
    END  
 CLOSE ALLOW_DEDU_CURSOR   
 DEALLOCATE ALLOW_DEDU_CURSOR  
 ----------------------------------------------------------------  
SET @COLUMNS = @COLUMNS +  'GROSS_SALARY#'   
 ----------------------------------------------------------------  
DECLARE ALLOW_DEDU_CURSOR CURSOR FOR  
  SELECT AD_NAME FROM T0050_AD_MASTER WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND AD_PART_OF_CTC = 1 AND AD_NOT_EFFECT_SALARY = 1   
           AND AD_FLAG = 'I' AND ISNULL(ALLOWANCE_TYPE,'A') <> 'R'   
           AND (CASE WHEN @SHOW_HIDDEN_ALLOWANCE = 0 AND Hide_In_Reports = 1  THEN 0 ELSE 1 END) = 1 --Added by Jaina 09-01-2017  
           ORDER BY AD_LEVEL  
 OPEN ALLOW_DEDU_CURSOR  
  FETCH NEXT FROM ALLOW_DEDU_CURSOR INTO @AD_NAME_DYN  
  WHILE @@FETCH_STATUS = 0  
   BEGIN  
    SET @AD_NAME_DYN = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@AD_NAME_DYN)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')  
    SET @COLUMNS = @COLUMNS +  REPLACE(RTRIM(LTRIM(@AD_NAME_DYN)),' ','_') + '#'  
     FETCH NEXT FROM ALLOW_DEDU_CURSOR INTO @AD_NAME_DYN  
   END  
 CLOSE ALLOW_DEDU_CURSOR   
 DEALLOCATE ALLOW_DEDU_CURSOR  
 ----------------------------------------------------------------  
 SET @COLUMNS = @COLUMNS +  'CTC#'  
 ----------------------------------------------------------------  
 SET @COLUMNS = @COLUMNS +  'PT#'  
 SET @COLUMNS = @COLUMNS +  'Total_Deduction#'  
 SET @COLUMNS = @COLUMNS +  'Net_Take_Home#'  
 ----------------------------------------------------------------     
 SET @CTC_CMP_ID = @CMP_ID  
   
 DECLARE @CUR_BRANCH_ID AS NUMERIC(18,0)  
 SET @CUR_BRANCH_ID = 0  
 DECLARE @PREV_BRANCH_ID AS NUMERIC(18,0)  
 SET @PREV_BRANCH_ID = 0  
 DECLARE @CUR_INCREMENT_ID AS NUMERIC(18,0)  
 SET @CUR_INCREMENT_ID = 0  
   
 DECLARE @CTC_DOJ DATETIME  
 DECLARE @CTC_NEW_DOJ DATETIME  
 DECLARE @CTC_NEW_DOJ2 DATETIME  
 DECLARE @CTC_PRV_MON_DOJ NUMERIC  
 DECLARE @CTC_TOT_MON NUMERIC  
 DECLARE @CTC_COLUMNS NVARCHAR(100)  
 DECLARE @CTC_GROSS NUMERIC(18,2)  
 DECLARE @TOTAL_EAR NUMERIC(18,2)  
 DECLARE @TOTAL_DED NUMERIC(18,2)  
 DECLARE @CTC_AD_FLAG VARCHAR(1)  
 DECLARE @CTC_PT NUMERIC(18,2)  
 DECLARE @ALLOW_AMOUNT NUMERIC(18,2)  
 DECLARE @NUMTMPCAL NUMERIC(18,2)  

 --SET @CUR_Band_ID = 0  
 DECLARE CTC_UPDATE CURSOR FOR  
  SELECT EC.EMP_ID,EC.BRANCH_ID,I.INCREMENT_ID,EM.DATE_OF_JOIN,IE.BASIC_SALARY,B.BandName
  --,IE.Is_Pradhan_Mantri,IE.Is_1time_PF_Member
  FROM #EMP_CONS EC   
  INNER JOIN T0095_INCREMENT IE WITH (NOLOCK) ON EC.Emp_ID = IE.Emp_ID  
   INNER JOIN  tblBandMaster B WITH (NOLOCK) ON B.BandId = IE.Band_Id   
  INNER JOIN (          
     SELECT MAX(I2.Increment_ID) AS Increment_ID,I2.Emp_ID   
     FROM T0095_Increment I2 WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I2.Emp_ID=E.Emp_ID   
       INNER JOIN (SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID  
          FROM T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E3 WITH (NOLOCK) ON I3.Emp_ID=E3.Emp_ID   
          WHERE I3.Increment_effective_Date <= @TO_DATE AND I3.Cmp_ID = @Cmp_ID and I3.Increment_Type Not IN ('Transfer','Deputation')  
          GROUP BY I3.EMP_ID    
          ) I3 ON I2.Increment_Effective_Date=I3.Increment_Effective_Date AND I2.EMP_ID=I3.Emp_ID                                     
     GROUP BY I2.Emp_ID  
     ) I ON IE.Emp_ID = I.Emp_ID AND IE.Increment_ID=I.Increment_ID  --Added By Jimit 28022018 for getting Latest Increment Id not in transfer and deputation    
  INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.EMP_ID = EC.EMP_ID  
 OPEN CTC_UPDATE  
 FETCH NEXT FROM CTC_UPDATE INTO @CTC_EMP_ID,@CUR_BRANCH_ID,@CUR_INCREMENT_ID,@CTC_DOJ,@CTC_BASIC,@CUR_Band_Name --,@CUR_Is_Pradhan_Mantri,@CUR_Is_1time_PF_Member  
 WHILE @@FETCH_STATUS = 0  
  BEGIN     
   DECLARE @COUNT NUMERIC  
   SET @COUNT = 1  
   -------------------------------------------------------------------------------------------------  
   -- Annually Salry will be calulated till current date from date of Joining or Starting of year --  
   -------------------------------------------------------------------------------------------------  
   --select @CTC_DOJ = Date_Of_Join from T0080_EMP_MASTER where Cmp_ID = @CTC_CMP_ID and Emp_ID = @CTC_EMP_ID  
     
   --Added By Jimit 14082018 as case at WCl consider Increment Id without tranafer and deputation   
   SELECT @CUR_INCREMENT_ID = I.INCREMENT_ID
   FROM T0095_INCREMENT IE WITH (NOLOCK)   
     INNER JOIN (  
         SELECT MAX(I2.INCREMENT_ID) AS INCREMENT_ID,I2.EMP_ID   
         FROM T0095_INCREMENT I2 WITH (NOLOCK) INNER JOIN   
           T0080_EMP_MASTER E WITH (NOLOCK) ON I2.EMP_ID=E.EMP_ID   
           INNER JOIN (SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID  
              FROM T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E3 WITH (NOLOCK) ON I3.EMP_ID=E3.EMP_ID   
              WHERE I3.INCREMENT_EFFECTIVE_DATE <= @TO_DATE AND I3.CMP_ID = @CMP_ID AND   
                I3.INCREMENT_TYPE NOT IN ('TRANSFER','DEPUTATION') AND   
                E3.Emp_ID = @CTC_EMP_ID  
              GROUP BY I3.EMP_ID    
              ) I3 ON I2.INCREMENT_EFFECTIVE_DATE=I3.INCREMENT_EFFECTIVE_DATE AND   
              I2.EMP_ID=I3.EMP_ID   
         WHERE I2.INCREMENT_TYPE NOT IN ('TRANSFER','DEPUTATION') AND E.Emp_ID = @CTC_EMP_ID                                     
         GROUP BY I2.EMP_ID  
      ) I ON IE.EMP_ID = I.EMP_ID AND IE.INCREMENT_ID=I.INCREMENT_ID  

   ---ENDED  
     
     
   IF YEAR(@CTC_DOJ) < YEAR(GETDATE()) -1   
    BEGIN   
     SET @CTC_NEW_DOJ = CONVERT(DATETIME,'01-APR-' + CONVERT(NVARCHAR,YEAR(GETDATE()) - 1))  
    END  
   ELSE IF YEAR(@CTC_DOJ) = YEAR(GETDATE()) -1 AND MONTH(@CTC_DOJ) < 4  
    BEGIN  
     SET @CTC_NEW_DOJ = CONVERT(DATETIME,'01-APR-' + CONVERT(NVARCHAR,YEAR(GETDATE()) - 1))  
    END  
   ELSE  
    BEGIN   
     SET @CTC_NEW_DOJ = CONVERT(DATETIME,DBO.GET_MONTH_ST_DATE(MONTH(@CTC_DOJ),YEAR(@CTC_DOJ)))  
    END  
     
   --SELECT @CTC_DOJ  
     
   IF MONTH(GETDATE()) = 3  
    BEGIN   
     SET @CTC_NEW_DOJ2 = CONVERT(DATETIME,'31-MAR-'  + CONVERT(NVARCHAR,YEAR(GETDATE())))  
    END  
   ELSE IF MONTH(GETDATE()) < 4  
    BEGIN   
     SET @CTC_NEW_DOJ2 = CONVERT(DATETIME,'31-MAR-'  + CONVERT(NVARCHAR,YEAR(GETDATE())))  
    END  
   ELSE  
    BEGIN  
     SET @CTC_NEW_DOJ = CONVERT(DATETIME,'01-APR-' + CONVERT(NVARCHAR,YEAR(GETDATE())))  
     SET @CTC_NEW_DOJ2 = CONVERT(DATETIME,'31-MAR-'  + CONVERT(NVARCHAR,YEAR(GETDATE()) + 1))  
    END  
     
   --select @CTC_NEW_DOJ,@CTC_NEW_DOJ2  
   SET @CTC_TOT_MON = DATEDIFF(mm,@CTC_NEW_DOJ,@CTC_NEW_DOJ2) + 1  
   --select @CTC_TOT_MON  
     
   IF @CTC_TOT_MON > 12  
    BEGIN   
     SET @CTC_TOT_MON  = 12  
    END  
           
   SET @CTC_COLUMNS = ''  
   SET @CTC_GROSS = 0  
   SET @TOTAL_EAR = 0  
   SET @TOTAL_DED = 0  
   SET @CTC_AD_FLAG = ''  
   SET @CTC_PT = 0  
   SET @NUMTMPCAL = 0  
   SET @ALLOW_AMOUNT = 0  
     
   --------------------------------------------------------------------------------------  
     
   --Select @CTC_BASIC= isnull(Basic_Salary,0) from T0080_EMP_MASTER where Emp_ID = @CTC_EMP_ID and Cmp_ID = @Cmp_ID  
     
   --select @CTC_BASIC=Basic_Salary  from T0095_INCREMENT where CMP_ID = @Cmp_Id and EMP_ID = @CTC_EMP_ID and Increment_Effective_Date <= @To_Date  
   --select @CTC_BASIC=Basic_Salary  from T0095_INCREMENT where CMP_ID = @Cmp_Id and EMP_ID = @CTC_EMP_ID and Increment_Effective_Date = (select max(Increment_Effective_Date) as Increment_Effective_Date from T0095_INCREMENT where  Increment_Effective_Date<= @To_Date and CMP_ID = @Cmp_Id and EMP_ID = @CTC_EMP_ID)  
   --if @CTC_TOT_YEAR = 0  
   -- if (DaY(dbo.GET_MONTH_END_DATE(MONTH(@CTC_NEW_DOJ),YEAR(@CTC_NEW_DOJ)))) > 0  
  -- Set @numTmpCal = (@CTC_BASIC/(DaY(dbo.GET_MONTH_END_DATE(MONTH(@CTC_NEW_DOJ),YEAR(@CTC_NEW_DOJ))))) * @CTC_PRV_MON_DOJ          
   SET @NUMTMPCAL = @NUMTMPCAL + (@CTC_BASIC * @CTC_TOT_MON)  
  -- Set @numTmpCal = @numTmpCal + ((@CTC_BASIC/(DaY(dbo.GET_MONTH_END_DATE(MONTH(GETDATE()),YEAR(GETDATE()))))) * @CTC_CUR_MON_DAY)  
   INSERT INTO #CTCMAST (CMP_ID,EMP_ID,Branch_ID,Increment_ID,DEF_ID,LABEL_HEAD,MONTHLY_AMT,YEARLY_AMT,AD_ID,AD_FLAG,AD_DEF_ID,GROUP_NAME,SEQ_NO,SALARY_GROUP,Band_Name)  
    VALUES (@CTC_CMP_ID,@CTC_EMP_ID,@CUR_BRANCH_ID,@CUR_INCREMENT_ID,@COUNT,'Basic Salary',@CTC_BASIC,@NUMTMPCAL,NULL,'I',NULL,'Salary',1,'Gross Salary',@CUR_Band_Name)  
  
  --for adding Is_Pradhan_Mantri,Is_1time_PF_Member
    -- INSERT INTO #CTCMAST (CMP_ID,EMP_ID,Branch_ID,Increment_ID,DEF_ID,LABEL_HEAD,MONTHLY_AMT,YEARLY_AMT,AD_ID,AD_FLAG,AD_DEF_ID,GROUP_NAME,SEQ_NO,SALARY_GROUP,Band_Name,Is_Pradhan_Mantri,Is_1time_PF_Member)  
    --VALUES (@CTC_CMP_ID,@CTC_EMP_ID,@CUR_BRANCH_ID,@CUR_INCREMENT_ID,@COUNT,'Basic Salary',@CTC_BASIC,@NUMTMPCAL,NULL,'I',NULL,'Salary',1,'Gross Salary',@CUR_Band_Name,@CUR_Is_Pradhan_Mantri,@CUR_Is_1time_PF_Member)  
  

   SET @COUNT = @COUNT + 1  
     
   DECLARE @ALLOWANCE_PART NUMERIC -- ADDED BY ROHIT ON 30092013  
   SET @ALLOWANCE_PART = 0 -- ADDED BY ROHIT ON 30092013  
   DECLARE @CTC_AD_ID NUMERIC  
   DECLARE @ALLOW_AMOUNT_NET AS NUMERIC(18,2)  
        
   DECLARE CRU_COLUMNS CURSOR FOR  
    SELECT DATA FROM SPLIT(@COLUMNS,'#') WHERE DATA <> ''  
   OPEN CRU_COLUMNS  
     FETCH NEXT FROM CRU_COLUMNS INTO @CTC_COLUMNS  
     WHILE @@FETCH_STATUS = 0  
      BEGIN       
        --------------------------------------------  
   --     select @Inc_Id=MAX(INCREMENT_ID) from T0095_INCREMENT where CMP_ID = @CTC_CMP_ID and EMP_ID = @CTC_EMP_ID and Increment_Effective_Date <= @To_Date  
        if @CUR_INCREMENT_ID > 0  
        begin            
          Set @CTC_COLUMNS = Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(@CTC_COLUMNS)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')   
          SET @NUMTMPCAL = 0          
          IF @CTC_COLUMNS = 'Gross_Salary'  
           BEGIN               
            SET @ALLOWANCE_PART = 1   
           END  
          ELSE IF @CTC_COLUMNS = 'CTC'  
           BEGIN           
            SET @ALLOWANCE_PART = 2   
           END  
         -- Added by rohit on 19112013  
          ELSE IF @CTC_COLUMNS = 'Reimbersement_Salary'  
           BEGIN   
            SET @ALLOWANCE_PART = 3 -- ADDED BY ROHIT ON 30092013  
           END  
           -- Ended by rohit on 19112013  
          ELSE IF @ALLOWANCE_PART = 1    
           BEGIN  
            SELECT @ALLOW_AMOUNT=E_AD_AMOUNT,@CTC_AD_FLAG=E_AD_FLAG,@CTC_AD_ID=AD.AD_ID   
            FROM T0100_EMP_EARN_DEDUCTION  DED WITH (NOLOCK) INNER JOIN   
            T0050_AD_MASTER AD WITH (NOLOCK) ON DED.AD_ID = AD.AD_ID  
             WHERE REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(AD.AD_NAME)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS AND DED.CMP_ID = @CTC_CMP_ID AND DED.EMP_ID = @CTC_EMP_ID AND DED.INCREMENT_ID = @CUR_INCREMENT_ID   
            IF @ALLOW_AMOUNT > 0  
             BEGIN         
              SET @ALLOW_AMOUNT_NET = 0        
              --if @CTC_TOT_YEAR = 0  
              -- if (DaY(dbo.GET_MONTH_END_DATE(MONTH(@CTC_NEW_DOJ),YEAR(@CTC_NEW_DOJ)))) > 0  
              --if @CTC_PRV_MON_DOJ > 0  
              -- Set @ALlow_Amount_Net = @Allow_Amount  
              SET @ALLOW_AMOUNT_NET = @ALLOW_AMOUNT_NET + (@ALLOW_AMOUNT * @CTC_TOT_MON)   
              --Set @ALlow_Amount_Net = @ALlow_Amount_Net + @Allow_Amount  
              INSERT INTO #CTCMAST (CMP_ID,EMP_ID,BRANCH_ID,INCREMENT_ID,DEF_ID,LABEL_HEAD,MONTHLY_AMT,YEARLY_AMT,AD_ID,AD_FLAG,AD_DEF_ID,GROUP_NAME,SEQ_NO,SALARY_GROUP,Band_Name)  
               VALUES  
              (@CTC_CMP_ID,@CTC_EMP_ID,@CUR_BRANCH_ID,@CUR_INCREMENT_ID,NULL,REPLACE(@CTC_COLUMNS,'_',' '),ISNULL(@ALLOW_AMOUNT,0),@ALLOW_AMOUNT_NET ,@CTC_AD_ID,NULL,NULL,'Company Contribution',12,'Z-Cost to the Company',@CUR_Band_Name)     

			  --for adding Is_Pradhan_Mantri,Is_1time_PF_Member
			           --     INSERT INTO #CTCMAST (CMP_ID,EMP_ID,BRANCH_ID,INCREMENT_ID,DEF_ID,LABEL_HEAD,MONTHLY_AMT,YEARLY_AMT,AD_ID,AD_FLAG,AD_DEF_ID,GROUP_NAME,SEQ_NO,SALARY_GROUP,Band_Name,Is_Pradhan_Mantri,Is_1time_PF_Member)  
              -- VALUES  
              --(@CTC_CMP_ID,@CTC_EMP_ID,@CUR_BRANCH_ID,@CUR_INCREMENT_ID,NULL,REPLACE(@CTC_COLUMNS,'_',' '),ISNULL(@ALLOW_AMOUNT,0),@ALLOW_AMOUNT_NET ,@CTC_AD_ID,NULL,NULL,'Company Contribution',12,'Z-Cost to the Company',@CUR_Band_Name,@CUR_Is_Pradhan_Mantri,@CUR_Is_1time_PF_Member)     

              --Set @Count = @Count + 1  
             END   
           END  
          ELSE IF @ALLOWANCE_PART = 3    
           BEGIN     
             SELECT @ALLOW_AMOUNT=E_AD_AMOUNT,@CTC_AD_FLAG=E_AD_FLAG,@CTC_AD_ID=AD.AD_ID FROM T0100_EMP_EARN_DEDUCTION  DED WITH (NOLOCK)  
              INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON DED.AD_ID = AD.AD_ID  
              WHERE REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(AD.AD_NAME)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS AND DED.CMP_ID = @CTC_CMP_ID AND DED.EMP_ID = @CTC_EMP_ID AND DED.INCREMENT_ID = @CUR_INCREMENT_ID          
             IF @ALLOW_AMOUNT > 0  
              BEGIN      
               SET @ALLOW_AMOUNT_NET = 0  
               --if @CTC_TOT_YEAR = 0  
               -- if (DaY(dbo.GET_MONTH_END_DATE(MONTH(@CTC_NEW_DOJ),YEAR(@CTC_NEW_DOJ)))) > 0  
               --if @CTC_PRV_MON_DOJ > 0  
               -- Set @ALlow_Amount_Net = @Allow_Amount  
               SET @ALLOW_AMOUNT_NET = @ALLOW_AMOUNT_NET + (@ALLOW_AMOUNT * @CTC_TOT_MON)  
               --Set @ALlow_Amount_Net = @ALlow_Amount_Net + @Allow_Amount  
               INSERT INTO #CTCMAST (CMP_ID,EMP_ID,BRANCH_ID,INCREMENT_ID,DEF_ID,LABEL_HEAD,MONTHLY_AMT,YEARLY_AMT,AD_ID,AD_FLAG,AD_DEF_ID,GROUP_NAME,SEQ_NO,SALARY_GROUP,Band_Name)  
                VALUES  
               (@CTC_CMP_ID,@CTC_EMP_ID,@Cur_BRANCH_ID,@Cur_INCREMENT_ID,NULL,REPLACE(@CTC_COLUMNS,'_',' '),ISNULL(@ALLOW_AMOUNT,0),@ALLOW_AMOUNT_NET ,@CTC_AD_ID,NULL,NULL,'Reimbursement',11,'Z-Cost to the Company',@CUR_Band_Name)     
               
			   			  --for adding Is_Pradhan_Mantri,Is_1time_PF_Member
						       --INSERT INTO #CTCMAST (CMP_ID,EMP_ID,BRANCH_ID,INCREMENT_ID,DEF_ID,LABEL_HEAD,MONTHLY_AMT,YEARLY_AMT,AD_ID,AD_FLAG,AD_DEF_ID,GROUP_NAME,SEQ_NO,SALARY_GROUP,Band_Name,Is_Pradhan_Mantri,Is_1time_PF_Member)  
             --   VALUES  
             --  (@CTC_CMP_ID,@CTC_EMP_ID,@Cur_BRANCH_ID,@Cur_INCREMENT_ID,NULL,REPLACE(@CTC_COLUMNS,'_',' '),ISNULL(@ALLOW_AMOUNT,0),@ALLOW_AMOUNT_NET ,@CTC_AD_ID,NULL,NULL,'Reimbursement',11,'Z-Cost to the Company',@CUR_Band_Name,@CUR_Is_Pradhan_Mantri,@CUR_Is_1time_PF_Member)     
               
			   
			   --Set @Count = @Count + 1  
              END                
            END  
                     
          ELSE  
           BEGIN  
            SELECT @ALLOW_AMOUNT=E_AD_AMOUNT,@CTC_AD_FLAG=E_AD_FLAG,@CTC_AD_ID=AD.AD_ID FROM T0100_EMP_EARN_DEDUCTION  DED WITH (NOLOCK)  
             INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON DED.AD_ID = AD.AD_ID  
             WHERE REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(AD.AD_NAME)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS AND DED.CMP_ID = @CTC_CMP_ID AND DED.EMP_ID = @CTC_EMP_ID AND  DED.INCREMENT_ID = @CUR_INCREMENT_ID   
            IF @ALLOW_AMOUNT > 0  
             BEGIN    
              SET @ALLOW_AMOUNT_NET = 0  
              --if @CTC_TOT_YEAR = 0  
              -- if (DaY(dbo.GET_MONTH_END_DATE(MONTH(@CTC_NEW_DOJ),YEAR(@CTC_NEW_DOJ)))) > 0  
              --if @CTC_PRV_MON_DOJ > 0  
              -- Set @ALlow_Amount_Net = @Allow_Amount  
              SET @ALLOW_AMOUNT_NET = @ALLOW_AMOUNT_NET + (@ALLOW_AMOUNT * @CTC_TOT_MON)  
              --Set @ALlow_Amount_Net = @ALlow_Amount_Net + @Allow_Amount  
              INSERT INTO #CTCMAST (CMP_ID,EMP_ID,BRANCH_ID,INCREMENT_ID,DEF_ID,LABEL_HEAD,MONTHLY_AMT,YEARLY_AMT,AD_ID,AD_FLAG,AD_DEF_ID,GROUP_NAME,SEQ_NO,SALARY_GROUP,Band_Name)  
               VALUES  
              (@CTC_CMP_ID,@CTC_EMP_ID,@Cur_BRANCH_ID,@Cur_INCREMENT_ID,NULL,REPLACE(@CTC_COLUMNS,'_',' '),ISNULL(@ALLOW_AMOUNT,0),@ALLOW_AMOUNT_NET ,@CTC_AD_ID,NULL,NULL,'Allowances',11,'Gross Salary',@CUR_Band_Name)                
            
			 --for adding Is_Pradhan_Mantri,Is_1time_PF_Member
			       --INSERT INTO #CTCMAST (CMP_ID,EMP_ID,BRANCH_ID,INCREMENT_ID,DEF_ID,LABEL_HEAD,MONTHLY_AMT,YEARLY_AMT,AD_ID,AD_FLAG,AD_DEF_ID,GROUP_NAME,SEQ_NO,SALARY_GROUP,Band_Name,Is_Pradhan_Mantri,Is_1time_PF_Member)  
          --     VALUES  
          --    (@CTC_CMP_ID,@CTC_EMP_ID,@Cur_BRANCH_ID,@Cur_INCREMENT_ID,NULL,REPLACE(@CTC_COLUMNS,'_',' '),ISNULL(@ALLOW_AMOUNT,0),@ALLOW_AMOUNT_NET ,@CTC_AD_ID,NULL,NULL,'Allowances',11,'Gross Salary',@CUR_Band_Name,@CUR_Is_Pradhan_Mantri,@CUR_Is_1time_PF_Member)                
            
			--Set @Count = @Count + 1  
             END   
           END  
          IF @CTC_AD_FLAG = 'I'  
           BEGIN  
            SET @TOTAL_EAR = @TOTAL_EAR + ISNULL(@ALLOW_AMOUNT,0)  
           END  
          ELSE IF @CTC_AD_FLAG = 'D'  
           BEGIN  
            SET @TOTAL_DED = @TOTAL_DED + ISNULL(@ALLOW_AMOUNT,0)             
           END  
          SET @ALLOW_AMOUNT = 0  
        END  
        --------------------------------------------  
       FETCH NEXT FROM CRU_COLUMNS INTO @CTC_COLUMNS  
      END  
   CLOSE CRU_COLUMNS   
   DEALLOCATE CRU_COLUMNS  
       
   
   FETCH NEXT FROM CTC_UPDATE INTO @CTC_EMP_ID,@CUR_BRANCH_ID,@CUR_INCREMENT_ID,@CTC_DOJ,@CTC_BASIC,@CUR_Band_Name --,@CUR_Is_Pradhan_Mantri,@CUR_Is_1time_PF_Member
 END  
 CLOSE CTC_UPDATE   
 DEALLOCATE CTC_UPDATE  
   
 ----------------------------------------------------------------  
    
 SELECT *,(MONTHLY_AMT * 12) AS TOTAL_YEAR_AMT
 --,I.Band_Id,I.Is_Pradhan_Mantri,I.Is_1time_PF_Member 
 FROM #CTCMAST C
 --left join T0095_INCREMENT I on I.Increment_ID=C.Increment_ID
 ORDER BY C.EMP_ID ,SEQ_NO,TRAN_ID  
   
   
 DROP TABLE #CTCMAST  
   
 RETURN  
  
  
  
   