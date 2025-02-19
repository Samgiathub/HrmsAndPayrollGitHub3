  
  
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P_UPDATE_CTC]  
 @Cmp_ID   Numeric,  
 @Emp_ID   Numeric,  
 @For_Date  DateTime,  
 @SAL_TRAN_ID NUMERIC = 0,  
 @S_SAL_TRAN_ID NUMERIC = 0,  
 @Sal_Cal_Days Numeric(18,2) = 0,  
 @AD_ID   Numeric = 0,  
 @Out_Of_Days Numeric(9,3)=0  
AS  
 BEGIN   
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
    
  SET @S_SAL_TRAN_ID = ISNULL(@S_SAL_TRAN_ID,0)  
  SET @SAL_TRAN_ID = ISNULL(@SAL_TRAN_ID,0)  
    
  CREATE TABLE #EMP_ESIC  
  (  
   Emp_ID  Numeric,  
   AD_ID  Numeric,     
   AD_Amount Numeric(18,4),  
   ED_Amount Numeric(18,4),  
   ED_Percent Numeric(18,4),  
   Last_Amount Numeric(18,4),  
   AD_Flag  Char(1),  
   Flag_ID  INT,  --10 For ESIC, 20 For Special, 30 For Gross     
   ROW_ID  INT Identity(1,1),  
   LABEL  VARCHAR(128),  
   IsUpdated BIT,  
   Max_Limit Numeric(18,4),  
   Calc_ESIC_Forcefully tinyint --Hardik 07/10/2020 for Webclues  
  )      
    
  DECLARE @BASIC NUMERIC(18,2)  
  DECLARE @GROSS NUMERIC(18,2)  
  DECLARE @CTC NUMERIC(18,2)  
  DECLARE @SPECIAL NUMERIC(18,2)  
  DECLARE @ESIC_475 NUMERIC(18,2)  
  DECLARE @ESIC_175 NUMERIC(18,2)  
    
    
  --IF @SAL_TRAN_ID > 0  
  -- BEGIN  
  --  SELECT @CTC = I.CTC, @Gross = 0  
  --  FROM T0200_MONTHLY_SALARY MS  
  --    INNER JOIN T0095_INCREMENT I ON MS.Increment_ID=I.Increment_ID  
  --  WHERE MS.Sal_Tran_ID=@SAL_TRAN_ID  
      
  --  SELECT TOP 1 @Basic = MAD.M_AD_Calculated_Amount  
  --  FROM T0210_MONTHLY_AD_DETAIL MAD         
  --    INNER JOIN T0050_AD_MASTER AD ON MAD.AD_ID=AD.AD_ID  
  --  WHERE AD.AD_CALCULATE_ON = 'Basic Salary' AND MAD.M_AD_Calculated_Amount > 0   
  --    AND MAD.Sal_Tran_ID=@SAL_TRAN_ID  
  -- END  
  --ELSE  
  -- BEGIN  
    --SELECT Top 1 @Basic = Basic_Salary, @CTC = CTC, @Gross = Gross_Salary  
    --FROM T0095_INCREMENT I   
    --  Inner Join dbo.fn_getEmpIncrementDetail(@Cmp_ID,@Emp_ID,@For_Date) T ON I.Increment_ID=T.Increment_ID               
   --END  
  
  SELECT Top 1 I.Cmp_ID, I.Increment_ID, Basic_Salary, CTC, Gross_Salary, Emp_Full_PF, Branch_ID, Emp_Auto_Vpf As Cmp_Full_PF  
  INTO #T0095_INCREMENT  
  FROM T0095_INCREMENT I WITH (NOLOCK)   
    Inner Join dbo.fn_getEmpIncrementDetail(@Cmp_ID,@Emp_ID,@For_Date) T ON I.Increment_ID=T.Increment_ID               
  
      
  
  SELECT Top 1 @Basic = Basic_Salary, @CTC = CTC, @Gross = Gross_Salary  
  FROM #T0095_INCREMENT  
    
    
  SELECT Top 1 G.Is_PF, G.Full_PF, G.Company_Full_PF, GD.PF_LIMIT, G.ESIC_Upper_Limit  
  INTO #T0040_GENERAL_SETTING  
  FROM T0040_GENERAL_SETTING G WITH (NOLOCK)  
    INNER JOIN #T0095_INCREMENT I ON G.Branch_ID=I.Branch_ID  
    INNER JOIN T0050_GENERAL_DETAIL GD WITH (NOLOCK) ON G.Gen_ID=GD.GEN_ID  
  WHERE G.For_Date <= @For_Date  
  ORDER BY G.For_Date DESC, G.Gen_ID DESC  
  
    
  INSERT INTO #EMP_ESIC(Emp_ID,Ad_ID,AD_Amount,ED_Amount,ED_Percent,Ad_Flag,Label,Flag_ID)  
  Values(@Emp_ID,0,@BASIC,@BASIC,0,'I','Basic', 0)  
    
  INSERT INTO #EMP_ESIC(Emp_ID,Ad_ID,AD_Amount,ED_Amount,ED_Percent,Ad_Flag,Label,Flag_ID)  
  Values(@Emp_ID,0,@GROSS,@GROSS,0,'I','Gross', 0)  
    
     
  IF @SAL_TRAN_ID > 0       
   BEGIN  
     --- Added by Hardik 07/10/2020 for Webclues as they have increment from Aug-2020 but Company ESIC should be deduct from Special up to Sep-2020  
     DECLARE @sal_tran_id1 NUMERIC(18,0)    
     Declare @Calc_ESIC_Forcefully tinyint  
     SET @sal_tran_id1=0    
     SET @Calc_ESIC_Forcefully = 0  
  
     --IF (@ESIC_DEF_ID = @AD_DEF_ID OR @Cmp_ESIC_DEF_ID = @AD_DEF_ID)  
      BEGIN   
       DECLARE @FROM_TERM DATETIME  
       DECLARE @TO_TERM DATETIME  
  
       IF MONTH(@For_Date) BETWEEN 4 AND 9  
        BEGIN          
         SET @FROM_TERM = CAST(YEAR(@For_Date) AS VARCHAR(10)) + '-04-01'   
         SET @TO_TERM = CAST(YEAR(@For_Date) AS VARCHAR(10)) + '-09-30'   
        END  
       ELSE  
        BEGIN  
         IF MONTH(@For_Date) BETWEEN 1 AND 3  
          SET @FROM_TERM = CAST((YEAR(@For_Date)-1) AS VARCHAR(10)) + '-10-01'   
         ELSE  
          SET @FROM_TERM = CAST(YEAR(@For_Date) AS VARCHAR(10)) + '-10-01'   
  
         SET @TO_TERM =DATEADD(D,-1, DATEADD(M, 6, @FROM_TERM));  
        END  
    
       SELECT TOP 1 @Sal_Tran_ID1=Sal_Tran_ID   
       FROM dbo.T0200_MONTHLY_SALARY MS WITH (NOLOCK)  
       WHERE Emp_ID=@emp_id AND MS.Cmp_ID=@Cmp_ID AND MS.Month_End_Date BETWEEN @FROM_TERM AND @TO_TERM   
         AND (sal_tran_id <> @Sal_Tran_ID) AND Sal_Cal_Days > 0  
         AND EXISTS(SELECT 1   
            FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)  
              INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON MAD.AD_ID=AD.AD_ID  
            WHERE MS.SAL_TRAN_ID=MAD.SAL_TRAN_ID AND AD.AD_DEF_ID=3)  
       ORDER BY MS.Month_End_Date ASC  
  
       IF @sal_tran_id1 = 0 AND NOT EXISTS(SELECT 1 FROM T0200_MONTHLY_SALARY MS WITH (NOLOCK)  
                WHERE MS.Emp_ID=@Emp_Id AND MS.Month_End_Date BETWEEN @FROM_TERM AND @TO_TERM  
                  AND Sal_Cal_Days > 0  
                  AND EXISTS(SELECT 1   
                     FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)  
                       INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON MAD.AD_ID=AD.AD_ID  
                     WHERE MS.SAL_TRAN_ID=MAD.SAL_TRAN_ID AND AD.AD_DEF_ID=3)  
                )   
        SET @sal_tran_id1 = -1  
  
       IF NOT EXISTS(SELECT 1  
            FROM  dbo.T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)  
            INNER JOIN  dbo.T0050_AD_MASTER am WITH (NOLOCK) ON MAD.ad_id= am.ad_id  
            WHERE Sal_Tran_ID= @Sal_Tran_ID1 AND M_AD_Amount > 0 AND AD_DEF_ID=3  
           ) AND @Sal_Tran_ID1 > 0 --AND @Production_Based_Salary = 0   
        SET @Sal_Tran_ID1 = 0  
  
        If @sal_tran_id1 <> 0  
         SET @Calc_ESIC_Forcefully = 1  
      END  
       
    INSERT INTO #EMP_ESIC(Emp_ID,Ad_ID,AD_Amount,ED_Amount,ED_Percent,Ad_Flag,Label,Max_Limit)  
    SELECT @Emp_ID,IsNull(MAD.Ad_ID,ED.AD_ID),Sum(IsNull(MAD.M_AD_Amount,ED.E_AD_Amount)),Sum(IsNull(MAD.M_AD_Amount,ED.E_AD_Amount)),  
      Max(ED.E_Ad_Percentage),AD.AD_Flag,AD.AD_NAME,Max(GD.AD_MAX_LIMIT)  
    FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)      
      RIGHT OUTER JOIN dbo.fn_getEmpIncrementDetail(@Cmp_ID,@Emp_ID,@For_Date) ED ON MAD.AD_ID=ED.AD_ID and IsNull(Sal_Tran_ID,Temp_Sal_Tran_ID)=@SAL_TRAN_ID -- AND ISNULL(S_SAL_TRAN_ID,0)=@S_SAL_TRAN_ID  
      INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON AD.Ad_ID = IsNull(MAD.Ad_ID, ED.Ad_ID)  
      INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON ED.Increment_ID =I.Increment_ID  
      INNER JOIN T0120_GRADEWISE_ALLOWANCE GD WITH (NOLOCK) ON I.Grd_ID = GD.Grd_ID AND ED.AD_ID=GD.AD_ID   
    WHERE   AD_CALCULATE_ON NOT IN ('Import')  
    GROUP BY IsNull(MAD.Ad_ID,ED.AD_ID),AD.AD_Flag,AD.AD_NAME,AD.AD_LEVEL  
    ORDER BY AD.AD_LEVEL  
  
      
  
      
   END  
  ELSE  
   INSERT INTO #EMP_ESIC(Emp_ID,Ad_ID,AD_Amount,ED_Amount,ED_Percent,Ad_Flag,Label,Max_Limit)  
   SELECT ED.Emp_ID,ED.Ad_ID,ED.E_AD_Amount,ED.E_AD_Amount,ED.E_AD_Percentage,AD.AD_Flag,AD.AD_NAME,GD.AD_MAX_LIMIT  
   FROM dbo.fn_getEmpIncrementDetail(@Cmp_ID,@Emp_ID,@For_Date) ED   
     INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON ED.Ad_ID=AD.Ad_ID          
     INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON ED.Increment_ID =I.Increment_ID  
     INNER JOIN T0120_GRADEWISE_ALLOWANCE GD WITH (NOLOCK) ON I.Grd_ID = GD.Grd_ID AND ED.AD_ID=GD.AD_ID   
   WHERE   AD_CALCULATE_ON NOT IN ('Import')  
   ORDER BY AD.AD_LEVEL  
        
    
  INSERT INTO #EMP_ESIC(Emp_ID,Ad_ID,AD_Amount,ED_Amount,ED_Percent,Ad_Flag,Label,Flag_ID)  
  Values(@Emp_ID,0,@CTC,@CTC,0,'I','CTC', 0)  
    
    
    
  UPDATE #EMP_ESIC  
  SET  IsUpdated = 0  
    
  DELETE ESIC FROM #EMP_ESIC ESIC INNER JOIN T0050_AD_MASTER AD ON ESIC.AD_ID=AD.AD_ID WHERE HIDE_IN_REPORTS = 1  
    
  DECLARE @SPECIAL_FLAG_ID INT  
  DECLARE @GROSS_FLAG_ID  INT  
  DECLARE @ESIC_FLAG_ID  INT      
  DECLARE @CTC_FLAG_ID  INT  
  
  DECLARE @EPF_FLAG_ID  INT  
  DECLARE @CPF_FLAG_ID  INT  
  
  DECLARE @ESIC_175_FLAG_ID INT      
    
  DECLARE @EDLI_FLAG_ID  INT  
  
  SET @SPECIAL_FLAG_ID = 50      
  SET @GROSS_FLAG_ID = 70  
  SET @ESIC_FLAG_ID = 90  
  SET @CTC_FLAG_ID = 100  
  
  SET @ESIC_175_FLAG_ID = 290  
  
  SET @EPF_FLAG_ID  = 60  
  SET @CPF_FLAG_ID  = 40  
  SET @EDLI_FLAG_ID = 700  
    
    
    
  /*Updating Flag ID*/  
  --GROSS  
  IF @SAL_TRAN_ID > 0  
  Begin  
   UPDATE T  
   SET  Flag_ID = @GROSS_FLAG_ID, AD_Amount=(CTC.Amount + @BASIC)  
   FROM #EMP_ESIC T       
     INNER JOIN (SELECT CTC.EMP_ID, SUM(CTC.AD_Amount) As Amount  
        FROM #EMP_ESIC CTC   
          INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON CTC.AD_ID=AD.AD_ID  
        WHERE IsNull(AD.AD_NOT_EFFECT_SALARY,0)=0  
          AND AD.AD_FLAG = 'I'  
        GROUP BY CTC.EMP_ID) CTC ON T.EMP_ID=CTC.EMP_ID  
   WHERE LABEL='Gross'   
  
     
  END  
  ELSE  
   UPDATE T  
   SET  Flag_ID = @GROSS_FLAG_ID, AD_Amount=0  
   FROM #EMP_ESIC T       
   WHERE LABEL='Gross'   
     
     
    
  --CTC  
  IF @SAL_TRAN_ID > 0  
   UPDATE T  
   SET  Flag_ID = @CTC_FLAG_ID, AD_Amount=(CTC.AMOUNT + @BASIC)  
   FROM #EMP_ESIC T       
     INNER JOIN (SELECT CTC.EMP_ID, SUM(CTC.AD_Amount) As Amount  
        FROM #EMP_ESIC CTC   
          INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON CTC.AD_ID=AD.AD_ID  
        WHERE AD.AD_PART_OF_CTC = 1  
        GROUP BY CTC.EMP_ID) CTC ON T.EMP_ID=CTC.EMP_ID  
   WHERE LABEL='CTC'  
     
     
  --ELSE  
   UPDATE T  
   SET  Flag_ID = @CTC_FLAG_ID  
   FROM #EMP_ESIC T       
   WHERE LABEL='CTC'  
    
  --select @Sal_Cal_Days,@Out_Of_Days  
  --select *   
  --FROM #EMP_ESIC T       
  --    INNER JOIN dbo.fn_getEmpIncrement(@Cmp_ID,@Emp_ID,@For_Date) TI ON T.Emp_ID=TI.Emp_ID  
  --    INNER JOIN T0095_INCREMENT I ON TI.INCREMENT_ID=I.INCREMENT_ID  
  --  WHERE LABEL='CTC'  
    
   IF IsNull(@Sal_Cal_Days,0) > 0 and IsNull(@Out_Of_Days,0) > 0  
   BEGIN  
  
    UPDATE T  
    SET  AD_Amount= ROUND(( T.AD_Amount * @Sal_Cal_Days)/ @Out_Of_Days  , 0)  
    FROM #EMP_ESIC T       
    WHERE LABEL IN ('Basic','Gross')  
  
      
      
    UPDATE T  
    SET  AD_Amount= ROUND(( I.CTC * @Sal_Cal_Days)/ @Out_Of_Days  , 0)  
    FROM #EMP_ESIC T       
      INNER JOIN dbo.fn_getEmpIncrement(@Cmp_ID,@Emp_ID,@For_Date) TI ON T.Emp_ID=TI.Emp_ID  
      INNER JOIN T0095_INCREMENT I ON TI.INCREMENT_ID=I.INCREMENT_ID  
    WHERE LABEL='CTC'  
   END  
  
  
  --SPECIAL  
  UPDATE T  
  SET  Flag_ID = @SPECIAL_FLAG_ID, AD_Amount=0  
  FROM #EMP_ESIC T  
    INNER JOIN T0050_AD_MASTER AD ON T.AD_ID=AD.AD_ID  
  WHERE AD_CALCULATE_ON='Arrears CTC'   
  
     
    
  --Company ESIC 4.75%  
  UPDATE T  
  SET  Flag_ID = @ESIC_FLAG_ID, AD_Amount=0,Calc_ESIC_Forcefully = @Calc_ESIC_Forcefully  
  FROM #EMP_ESIC T  
    INNER JOIN T0050_AD_MASTER AD ON T.AD_ID=AD.AD_ID  
  WHERE AD_DEF_ID=6   
  
  --Employee ESIC 1.75%  
  UPDATE T  
  SET  Flag_ID = @ESIC_175_FLAG_ID, AD_Amount=0,Calc_ESIC_Forcefully = @Calc_ESIC_Forcefully  
  FROM #EMP_ESIC T  
    INNER JOIN T0050_AD_MASTER AD ON T.AD_ID=AD.AD_ID  
  WHERE AD_DEF_ID=3  
  
  --Employee PF  
  UPDATE T  
  SET  Flag_ID = @EPF_FLAG_ID, AD_Amount=0  
  FROM #EMP_ESIC T  
    INNER JOIN T0050_AD_MASTER AD ON T.AD_ID=AD.AD_ID  
  WHERE AD_DEF_ID=2  
    
  --Company PF  
  UPDATE T  
  SET  Flag_ID = @CPF_FLAG_ID, AD_Amount=0  
  FROM #EMP_ESIC T  
    INNER JOIN T0050_AD_MASTER AD ON T.AD_ID=AD.AD_ID  
  WHERE AD_DEF_ID=5  
  
  --Admin Charges PF  
  UPDATE T  
  SET  Flag_ID = @CPF_FLAG_ID, AD_Amount=0  
  FROM #EMP_ESIC T  
    INNER JOIN T0050_AD_MASTER AD ON T.AD_ID=AD.AD_ID  
  WHERE AD_DEF_ID=10  
  
     
    
  --EDLI Admin Charges PF New  
  --ADDED by Yogesh on 20022024 for EDLI   
    
  UPDATE T  
  SET  Flag_ID = @EDLI_FLAG_ID, AD_Amount=0  
     FROM #EMP_ESIC T  
    INNER JOIN T0050_AD_MASTER AD ON T.AD_ID=AD.AD_ID  
  WHERE AD_DEF_ID=38  
    
      
  
    
  DECLARE @ESIC_475_AD_ID  NUMERIC  
  DECLARE @ESIC_175_AD_ID  NUMERIC  
  DECLARE @SPECIAL_AD_ID  NUMERIC  
    
    
  SELECT @ESIC_475_AD_ID = CASE FLAG_ID WHEN @ESIC_FLAG_ID THEN AD_ID ELSE @ESIC_475_AD_ID END,  
    @ESIC_175_AD_ID = CASE FLAG_ID WHEN @ESIC_175_FLAG_ID THEN AD_ID ELSE @ESIC_175_AD_ID END,  
    @SPECIAL_AD_ID = CASE FLAG_ID WHEN @SPECIAL_FLAG_ID THEN AD_ID ELSE @SPECIAL_AD_ID END  
  FROM #EMP_ESIC  
  WHERE FLAG_ID IN (@ESIC_FLAG_ID, @ESIC_175_FLAG_ID, @SPECIAL_FLAG_ID)  
    
    
    
  DECLARE @Approach TINYINT  
  SET @Approach = 0  
    
  IF @Approach = 0 /*0 = Recursive (Cliantha, Corona), 1 = Formula Based (Wonder)*/  
   BEGIN   

   
    EXEC P_CALCULATE_ESIC @Approach=@Approach, @AD_ID=@AD_ID  
  
    SELECT @GROSS = CTC.AD_AMOUNT  
    FROM #EMP_ESIC CTC   
    WHERE CTC.Emp_ID=@Emp_Id AND CTC.FLAG_ID=@GROSS_FLAG_ID --GROSS  
        
    SELECT @ESIC_475 = CTC.AD_AMOUNT  
    FROM #EMP_ESIC CTC   
    WHERE CTC.Emp_ID=@Emp_Id AND CTC.FLAG_ID=@ESIC_FLAG_ID --Company ESIC 4.75%  
        
    --  select CTC.AD_AMOUNT FROM #EMP_ESIC CTC   
    --WHERE CTC.Emp_ID=@Emp_Id AND CTC.FLAG_ID=@SPECIAL_FLAG_ID --SPECIAL  
   -- select * from #EMP_ESIC  
    SELECT @SPECIAL = CTC.AD_AMOUNT  
    FROM #EMP_ESIC CTC   
    WHERE CTC.Emp_ID=@Emp_Id AND CTC.FLAG_ID=@SPECIAL_FLAG_ID --SPECIAL  
        
    SELECT @ESIC_175 = CTC.AD_AMOUNT  
    FROM #EMP_ESIC CTC   
    WHERE CTC.Emp_ID=@Emp_Id AND CTC.FLAG_ID=@ESIC_175_FLAG_ID --ESIC 1.75%  
      
   END  
  ELSE  
   BEGIN  
    CREATE TABLE #FIXED_GROSS  
    (  
     Emp_ID          Numeric,  
     TargetCTC       Numeric(18,2),  
     CTC_Without     Numeric(18,2),  
     SP_ESIC         Numeric(18,2),  
     Gross_Without   Numeric(18,2),  
     Gross_ESIC      AS Cast(Gross_Without + SP_ESIC As Numeric(18,2)),  
     ESIC_Rate       Numeric(9,2),  
     ESIC_Ratio      Numeric(9,4),  
     Gross           Numeric(9,2),  
     Special         As Cast(ROUND(Gross - Gross_Without,0) As Numeric(18,0)),  
     ESIC            Numeric(9,2)   
    )  
    CREATE UNIQUE CLUSTERED INDEX IX_FIXED_GROSS ON #FIXED_GROSS(EMP_ID)  
      
      
  
    EXEC P_CALCULATE_ESIC @Approach=@Approach, @AD_ID=@AD_ID  
          
  
      
    SET @ESIC_175 = 0  
    SELECT @GROSS = Gross, @ESIC_475 = ESIC, @Special = Special,   
      @ESIC_175 = CASE WHEN @ESIC_175_FLAG_ID = ESIC.FLAG_ID AND ESIC_Ratio > 1  THEN  ceiling((T.Gross * ESIC.ED_Percent/100)) ELSE @ESIC_175 END  
    FROM #FIXED_GROSS T  
      INNER JOIN #EMP_ESIC ESIC ON T.EMP_ID=ESIC.EMP_ID              
    WHERE T.EMP_ID=@EMP_ID --AND ESIC.FLAG_ID = @ESIC_175_FLAG_ID        
      
      
      
    IF @S_SAL_TRAN_ID > 0  
     BEGIN  
              
          
      SELECT @ESIC_475 = @ESIC_475 - ISNULL(SUM(M_AD_Amount),0)  
      FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)  
      WHERE ISNULL(S_SAL_TRAN_ID,0) <> @S_SAL_TRAN_ID AND SAL_TRAN_ID=@SAL_TRAN_ID  
        AND AD_ID = @ESIC_475_AD_ID  
        
        
      SELECT @Special = @Special - ISNULL(SUM(M_AD_Amount),0)  
      FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)  
      WHERE ISNULL(S_SAL_TRAN_ID,0) <> @S_SAL_TRAN_ID AND SAL_TRAN_ID=@SAL_TRAN_ID  
        AND AD_ID =@SPECIAL_AD_ID  
          
          
          
      SELECT @ESIC_175 = @ESIC_175 - ISNULL(SUM(M_AD_Amount),0)  
      FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)  
      WHERE ISNULL(S_SAL_TRAN_ID,0) <> @S_SAL_TRAN_ID AND SAL_TRAN_ID=@SAL_TRAN_ID  
        AND AD_ID = @ESIC_175_AD_ID  
         
        
        
     END  
   END  
    
  DECLARE @AD_ID_UPDATED NUMERIC  
  DECLARE @AD_AMOUNT NUMERIC(18,2)  
  
   
  
  IF @Sal_Tran_ID > 0  
   BEGIN  
    IF @S_SAL_TRAN_ID = 0 and @Gross > 0  
     UPDATE T0200_MONTHLY_SALARY  
     SET  Gross_Salary = @Gross  
     WHERE Emp_ID=@Emp_Id and Sal_Tran_ID=@Sal_Tran_ID   
        
        
    UPDATE MAD  
    SET  M_AD_Amount = Isnull(@ESIC_475,0)  
    FROM T0210_MONTHLY_AD_DETAIL MAD        
    WHERE MAD.Emp_ID=@Emp_Id and IsNull(Sal_Tran_ID,Temp_Sal_Tran_ID)=@Sal_Tran_ID  AND ISNULL(S_Sal_Tran_ID,0) = @S_SAL_TRAN_ID  
      AND (CASE WHEN @S_SAL_TRAN_ID > 0 AND M_AD_Amount <> 0 THEN 1 WHEN @S_SAL_TRAN_ID = 0 THEN 1 ELSE 0 END)  = 1  
      AND MAD.AD_ID=@ESIC_475_AD_ID --Company ESIC 4.75%  
          
          
  
    UPDATE MAD  
    SET  M_AD_Amount = Isnull(@SPECIAL,0)  
    FROM T0210_MONTHLY_AD_DETAIL MAD        
    WHERE MAD.Emp_ID=@Emp_Id and IsNull(Sal_Tran_ID,Temp_Sal_Tran_ID)=@Sal_Tran_ID  AND ISNULL(S_Sal_Tran_ID,0) = @S_SAL_TRAN_ID  
      AND (CASE WHEN @S_SAL_TRAN_ID > 0 AND M_AD_Amount <> 0 THEN 1 WHEN @S_SAL_TRAN_ID = 0 THEN 1 ELSE 0 END)  = 1  
      AND MAD.AD_ID=@SPECIAL_AD_ID --SPECIAL  
       
       
    UPDATE MAD  
    SET  M_AD_Amount = Isnull(@ESIC_175,0)  
    FROM T0210_MONTHLY_AD_DETAIL MAD        
    WHERE MAD.Emp_ID=@Emp_Id and IsNull(Sal_Tran_ID,Temp_Sal_Tran_ID)=@Sal_Tran_ID  AND ISNULL(S_Sal_Tran_ID,0) = @S_SAL_TRAN_ID  
      AND (CASE WHEN @S_SAL_TRAN_ID > 0 AND M_AD_Amount <> 0 THEN 1 WHEN @S_SAL_TRAN_ID = 0 THEN 1 ELSE 0 END)  = 1  
      AND MAD.AD_ID=@ESIC_175_AD_ID --ESIC 1.75%  
  
  
     -- select * from #EMP_ESIC  
  
    DECLARE curUpdated Cursor Fast_Forward FOR  
    Select AD_ID,AD_AMOUNT FROM #EMP_ESIC ESIC WHERE IsUpdated=1  
    Open curUpdated  
    FETCH NEXT FROM curUpdated INTO @AD_ID_UPDATED,@AD_AMOUNT  
    WHILE @@FETCH_STATUS = 0  
     BEGIN  
        
      UPDATE MAD  
      SET  M_AD_Amount = Isnull(@AD_AMOUNT,0)  
      FROM T0210_MONTHLY_AD_DETAIL MAD        
      WHERE MAD.Emp_ID=@Emp_Id and IsNull(Sal_Tran_ID,Temp_Sal_Tran_ID)=@Sal_Tran_ID  AND ISNULL(S_Sal_Tran_ID,0) = @S_SAL_TRAN_ID  
        AND (CASE WHEN @S_SAL_TRAN_ID > 0 AND M_AD_Amount <> 0 THEN 1 WHEN @S_SAL_TRAN_ID = 0 THEN 1 ELSE 0 END)  = 1  
        AND MAD.AD_ID=@AD_ID_UPDATED --Calculate ON Gross OR Effect In Gross Allowance   
       
       
       
      FETCH NEXT FROM curUpdated INTO @AD_ID_UPDATED,@AD_AMOUNT  
     END  
    CLOSE curUpdated       
    DEALLOCATE curUpdated       
   END  
  ELSE  
   BEGIN  
      
    DECLARE @Increment_Id NUMERIC  
    SELECT  Top 1 @Increment_Id=Increment_ID  
    FROM    T0095_INCREMENT WITH (NOLOCK)  
    WHERE   Emp_ID=@Emp_ID AND Increment_Effective_Date=@For_Date  
    ORDER BY Increment_ID Desc  
      
    If ISNULL(@Increment_Id, 0) > 0  
     UPDATE I  
     SET  Gross_Salary = ROUND(@Gross,0)  
     FROM T0095_INCREMENT I        
     WHERE I.Emp_ID=@Emp_Id and Increment_ID=@Increment_Id        
         
    /*Company ESIC Contribution 4.75%*/  
      
    IF EXISTS(SELECT 1 FROM T0110_EMP_EARN_DEDUCTION_REVISED WITH (NOLOCK)  
       WHERE Emp_ID=@Emp_ID AND For_Date=@For_Date AND Entry_Type <> 'D'  
         AND (E_AD_Percentage > 0 OR E_AD_Amount > 0) AND AD_ID=@ESIC_475_AD_ID)  
     UPDATE T0110_EMP_EARN_DEDUCTION_REVISED  
     SET  E_AD_AMOUNT = isnull(@ESIC_475,0)  
     WHERE Emp_ID=@Emp_Id and For_Date=@For_Date AND AD_ID=@ESIC_475_AD_ID   
             --AND Case When ISNULL(@Increment_Id,0) > 0 AND Increment_ID=@Increment_Id Then 1 When ISNULL(@Increment_Id,0) = 0 Then 1 Else 0 End = 1  
    ELSE      
     UPDATE T0100_EMP_EARN_DEDUCTION  
     SET  E_AD_AMOUNT = isnull(@ESIC_475,0)  
     WHERE Emp_ID=@Emp_Id AND For_Date=@For_Date AND AD_ID=@ESIC_475_AD_ID  
             AND Case When ISNULL(@Increment_Id,0) > 0 AND Increment_ID=@Increment_Id Then 1 When ISNULL(@Increment_Id,0) = 0 Then 1 Else 0 End = 1  
       
  
  
      
    /*Special Allowance*/  
    IF EXISTS(SELECT 1 FROM T0110_EMP_EARN_DEDUCTION_REVISED WITH (NOLOCK)  
       WHERE Emp_ID=@Emp_ID AND For_Date=@For_Date AND Entry_Type <> 'D'  
         AND (E_AD_Percentage > 0 OR E_AD_Amount > 0) AND AD_ID=@ESIC_475_AD_ID)  
     UPDATE T0110_EMP_EARN_DEDUCTION_REVISED  
     SET  E_AD_AMOUNT = isnull(@SPECIAL,0)  
     WHERE Emp_ID=@Emp_Id AND For_Date=@For_Date AND AD_ID=@SPECIAL_AD_ID   
    ELSE  
     UPDATE T0100_EMP_EARN_DEDUCTION  
     SET  E_AD_AMOUNT = isnull(@SPECIAL,0)  
     WHERE Emp_ID=@Emp_Id AND For_Date=@For_Date AND AD_ID=@SPECIAL_AD_ID          
             AND Case When ISNULL(@Increment_Id,0) > 0 AND Increment_ID=@Increment_Id Then 1 When ISNULL(@Increment_Id,0) = 0 Then 1 Else 0 End = 1  
               
      
          
        
    /*Employee ESIC 1.75%*/  
    UPDATE T0100_EMP_EARN_DEDUCTION  
    SET  E_AD_AMOUNT = isnull(@ESIC_175,0)  
    WHERE Emp_ID=@Emp_Id and For_Date=@For_Date AND AD_ID=@ESIC_175_AD_ID   
            AND Case When ISNULL(@Increment_Id,0) > 0 AND Increment_ID=@Increment_Id Then 1 When ISNULL(@Increment_Id,0) = 0 Then 1 Else 0 End = 1  
          
    Declare @Part_of_CTC as integer
	set @Part_of_CTC =(select isnull(ad.AD_PART_OF_CTC,0) from T0050_AD_MASTER AD inner join #EMP_ESIC ESIC on isnull(ESIC.AD_ID,0)=isnull(ad.AD_ID,0) where  ESIC.Flag_ID=700)
      
    DECLARE curUpdated Cursor Fast_Forward FOR  
    Select AD_ID,AD_AMOUNT FROM #EMP_ESIC ESIC WHERE IsUpdated=1  
    Open curUpdated  
    FETCH NEXT FROM curUpdated INTO @AD_ID_UPDATED,@AD_AMOUNT  
    WHILE @@FETCH_STATUS = 0  
     BEGIN  
     --select @AD_ID_UPDATED,@AD_AMOUNT  
      /*Calculate ON Gross OR Effect In Gross Allowance*/  
      IF EXISTS(SELECT 1 FROM T0110_EMP_EARN_DEDUCTION_REVISED WITH (NOLOCK)  
         WHERE Emp_ID=@Emp_ID AND For_Date=@For_Date AND Entry_Type <> 'D'  
           AND (E_AD_Percentage > 0 OR E_AD_Amount > 0) AND AD_ID=@AD_ID_UPDATED)  
       UPDATE T0110_EMP_EARN_DEDUCTION_REVISED  
       SET  E_AD_AMOUNT = isnull(@AD_AMOUNT,0)  
       WHERE Emp_ID=@Emp_Id AND For_Date=@For_Date AND AD_ID=@AD_ID_UPDATED   
         
      ELSE                
            
      UPDATE T0100_EMP_EARN_DEDUCTION         
       SET E_AD_AMOUNT =  isnull(@AD_AMOUNT,0)   
       --SET  E_AD_AMOUNT = CASE WHEN (isnull(E_AD_MAX_LIMIT,0)> 0 AND isnull(E_AD_AMOUNT,0) >= isnull(E_AD_MAX_LIMIT,0)) THEN isnull(E_AD_MAX_LIMIT,0)   
       --        WHEN isnull(E_AD_MAX_LIMIT,0)> isnull(E_AD_AMOUNT,0) THEN isnull(E_AD_AMOUNT,0)   
       --        ELSE isnull(@AD_AMOUNT,0) END  
       WHERE Emp_ID=@Emp_Id   
               AND For_Date=@For_Date   
         AND AD_ID=@AD_ID_UPDATED          
         AND Case When ISNULL(@Increment_Id,0) > 0   
         AND Increment_ID=@Increment_Id Then 1 When ISNULL(@Increment_Id,0) = 0 Then 1 Else 0 End = 1                                 
             
      FETCH NEXT FROM curUpdated INTO @AD_ID_UPDATED,@AD_AMOUNT  
     END  
    CLOSE curUpdated       
    DEALLOCATE curUpdated   
	
	
     ---- update sp value ----    
	 
		--select @Part_of_CTC
	if @Part_of_CTC=1
	begin
           
     Declare @Special_Adi  as int  
     Declare @Special_Val  as int  
     Declare @Flg_Val  as int  
      set @Flg_Val =(select isnull(ED_Amount,0) From #EMP_ESIC where Flag_ID=700)  
      set @Special_Adi=(select AD_ID From T0050_AD_MASTER where AD_CALCULATE_ON='Arrears CTC' and cmp_id=@Cmp_ID)  
      set @Special_Val=(select isnull(E_AD_AMOUNT,0) From T0100_EMP_EARN_DEDUCTION where AD_ID=@SPECIAL_AD_ID and EMP_ID=@Emp_ID)  
        
      UPDATE T0100_EMP_EARN_DEDUCTION         
      SET  E_AD_AMOUNT = isnull(@Special_Val,0)- isnull(@Flg_Val,0)  
      WHERE Emp_ID=@Emp_Id AND AD_ID=(@Special_Adi)                          

	End
   END  
 END  
  