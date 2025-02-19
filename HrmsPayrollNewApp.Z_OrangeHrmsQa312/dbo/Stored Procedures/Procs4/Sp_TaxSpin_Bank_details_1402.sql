







-----Created by Manisha on 11/12/2024 for TaxSpin Reports  (CHM #32017)          
Create PROCEDURE [dbo].[Sp_TaxSpin_Bank_details_1402]      
@Cmp_ID AS INT          
 ,@Emp_Id AS INT          
 ,@Constraint VARCHAR(MAX)          
 ,@Date AS DATE          
 ,@newdate As Date      
 ,@Email_ID As VARCHAR(MAX) =''      
 ,@flag AS NVARCHAR(10)          
AS          
SET NOCOUNT ON          
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED          
SET ARITHABORT ON          
          
BEGIN          
 -- Calculate the first and last day of the month from @Date          
 DECLARE @Year INT = YEAR(@newdate);          
 DECLARE @Month INT = MONTH(@newdate);          
 -- Calculate Start and End Dates          
 DECLARE @StartDate DATETIME = DATEFROMPARTS(@Year, @Month, 1);-- First day of the month (00:00:00)          
 DECLARE @EndDate DATETIME = DATEADD(DAY, 0, DATEADD(MONTH, 1, @StartDate));-- Start of the next month (00:00:00)          
 DECLARE @Emp_Cons TABLE (Emp_ID NUMERIC)          
          
 IF @Constraint <> ''          
 BEGIN          
  PRINT 'ok'          
          
  INSERT INTO @Emp_Cons          
  SELECT cast(data AS NUMERIC)          
  FROM dbo.Split(@Constraint, '#')          
 END          
          
 CREATE TABLE #Emp_Cons (          
  Emp_ID NUMERIC          
  ,Branch_ID NUMERIC          
  ,Increment_ID NUMERIC          
  )          
          
 EXEC SP_RPT_FILL_EMP_CONS @Cmp_ID          
  ,@Date          
  ,@Date          
  ,0          
  ,0          
  ,0          
  ,0          
  ,0          
  ,0          
  ,@Emp_ID          
  ,@constraint          
  ,0          
  ,0          
  ,0          
  ,0          
  ,0          
  ,0          
  ,0          
  ,0          
  ,0          
  ,0          
  ,0          
  ,0          
          
 --select * From #Emp_Cons 
 --return          
 IF @flag = 'AXIS'          
 BEGIN          
  SELECT CASE           
    WHEN b.Bank_Name = 'Axis'   OR b.Bank_Name = 'Axis Bank'       
     THEN 'I'          
    ELSE 'N'          
    END AS [Payment Method Name]          
   ,S.Net_Amount AS [Payment Amount (Request)]          
   ,REPLACE(CONVERT(VARCHAR, @Date, 103), '/', '-') AS [Activation Date]          
   ,emp.EmpName_Alias_PrimaryBank AS [Beneficiary Name (Request)]          
     ---  , '''' + CONVERT(VARCHAR, i.Inc_Bank_AC_No) AS [Account No]   --add for Bug #32442      
 
     --,RIGHT('000000000000000' + CONVERT(VARCHAR, i.Inc_Bank_AC_No), 10) AS [Account No]      
,( '="' + RIGHT('' + CONVERT(VARCHAR, i.Inc_Bank_AC_No), 15)+ '"') AS [Account Number....]    
  -- CONCAT('=', CAST(Inc_Bank_AC_No AS VARCHAR(255))) AS [Account No]

   ,NULL AS [Email]          
   ,NULL AS [Email Body]          
 ---, '''' + CONVERT(VARCHAR,b.Bank_Ac_No ) AS [Debit Account No]      
  ---  ,RIGHT('0000000000' + CONVERT(VARCHAR, b.Bank_Ac_No), 10) AS [Debit Account No]    
 -- ,( '="' + RIGHT('000000000000000' + CONVERT(VARCHAR, b.Bank_Ac_No), 15) + '"')  AS [Debit Account No] 
    --r,( '="' + RIGHT('00000000000000' + CONVERT(VARCHAR, bb.Account_No), 15) + '"')  AS [Debit Account No]           --ronakb030225
	--------------ronakb130225 comment this --------------------
 --,( '="' + RIGHT('' + CONVERT(VARCHAR, bb.Account_No), 15)+ '"') AS [Debit Account No]    
 -- ,( '="' + RIGHT('' + CONVERT(VARCHAR, b.Bank_Ac_No), 15)+ '"') AS [Debit Account No]   
 -------------------------------------------------------------------------------------------------------
 ,CASE 
    WHEN bb.Account_No IS NOT NULL 
        THEN ( '="' + RIGHT('' + CONVERT(VARCHAR, bb.Account_No), 15) + '"')
    ELSE ( '="' + RIGHT('' + CONVERT(VARCHAR, b.Bank_Ac_No), 15) + '"')
  END AS [Debit Account No]


   --,'''' + CONCAT (          
   -- RIGHT('00' + CAST(DAY(@newdate) AS VARCHAR(2)), 2)          
   -- ,RIGHT('00' + CAST(MONTH(@newdate) AS VARCHAR(2)), 2)          
   -- ,CAST(YEAR(@Date) AS VARCHAR(4))          
   -- ,Alpha_Emp_Code          
   -- ) AS [CRN No]      
   ,'="' + CONCAT (          
    RIGHT('00' + CAST(DAY(@newdate) AS VARCHAR(2)), 2)          
    ,RIGHT('00' + CAST(MONTH(@newdate) AS VARCHAR(2)), 2)          
    ,CAST(YEAR(@Date) AS VARCHAR(4))          
    ,Alpha_Emp_Code          
    ) + '"' AS [CRN No]      
   ,Ifsc_Code AS [RECEIVER IFSC Code]          
   ,10 AS [RECEIVER Account Type]          
   ,NULL AS [Remarks]          
   ,NULL AS [Phone No]          
  FROM T0080_EMP_MASTER emp          
  INNER JOIN #Emp_Cons EC WITH (NOLOCK) ON EMP.Emp_ID = ec.Emp_ID          
  INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.Increment_ID = EC.Increment_ID          
  INNER JOIN T0040_BANK_MASTER b WITH (NOLOCK) ON I.Bank_Id = b.Bank_Id 
  --INNER JOIN T0030_BRANCH_MASTER bm WITH (NOLOCK) ON bm.Branch_ID = emp.Branch_ID  --ronakb030225
  left JOIN T0040_CompanyWise_Branch_Table bb WITH (NOLOCK) ON bb.Bank_Id = B.Bank_Id and emp.Branch_ID= bb.Branch_Id     --ronakb030225
  INNER JOIN T0200_MONTHLY_SALARY S  WITH (NOLOCK) ON S.Emp_Id = ec.Emp_ID          
  WHERE emp.Cmp_id = @Cmp_ID          
   AND S.Month_St_Date >= @StartDate          
   AND S.Month_End_Date < @EndDate          
   AND S.Net_Amount > 0    -- RB

 END          
 ELSE IF @flag = 'BOB'          
 BEGIN          
  SELECT CONCAT (          
    'SALARY '          
    ,UPPER(LEFT(FORMAT(@newdate, 'MMMM'), 3))          
    ,CAST(YEAR(@newdate) AS VARCHAR(4))          
    ) AS [CUSTOM_DETAILS1]          
   ,REPLACE(CONVERT(VARCHAR, @Date, 103), '/', '-') AS [Value Date]          
   ,CASE           
    WHEN b.Bank_Name = 'BOB'    OR   b.Bank_Name = 'Bank Of Baroda'       
     THEN 'IFT'          
    ELSE 'NEFT'          
    END AS [Message Type]          
         --- , '''' + CONVERT(VARCHAR, b.Bank_Ac_No) AS [Debit Account No]       
   -- ,( '="' + RIGHT('000000000000000' + CONVERT(VARCHAR, I.Inc_Bank_AC_No), 15) + '"') AS [Debit Account No]    
    --,( '="' + RIGHT('00000000000000' + CONVERT(VARCHAR, bb.Account_No), 15) + '"')  AS [Debit Account No]           --ronakb030225
	 ,( '="' + RIGHT('' + CONVERT(VARCHAR, bb.Account_No), 15)+ '"') AS [Debit Account No]    
   --- ,RIGHT('0000000000' + CONVERT(VARCHAR,b.Bank_Ac_No ), 10) AS [Debit Account No]          
   ,emp.EmpName_Alias_PrimaryBank AS [Beneficiary Name]          
   ,S.Net_Amount AS [Payment Amount]          
   ,Ifsc_Code AS [Beneficiary Bank Swift Code / IFSC Code]          
   ,  ( '="' + RIGHT('000000000000000' + CONVERT(VARCHAR,b.Bank_Ac_No ), 15)+ '"')  AS [Beneficiary Account No.]  
   --- , '''' + CONVERT(VARCHAR, I.Inc_Bank_AC_No) AS [Beneficiary Account No.]          
 --- ,RIGHT('0000000000' + CONVERT(VARCHAR, I.Inc_Bank_AC_No), 10) AS [Beneficiary Account No.]          
   ,CASE           
    WHEN b.Bank_Name = 'BOB'  OR     b.Bank_Name = 'Bank Of Baroda'      
     THEN 'IFT'          
    ELSE 'NEFT'          
    END AS [Transaction Type Code]          
   ,NULL AS [CUSTOM_DETAILS2]          
   ,NULL AS [CUSTOM_DETAILS3]          
   ,NULL AS [CUSTOM_DETAILS4]          
   ,NULL AS [CUSTOM_DETAILS5]          
   ,NULL AS [CUSTOM_DETAILS6]          
   ,CONCAT (          
    'SALARY '          
    ,UPPER(LEFT(FORMAT(@newdate, 'MMMM'), 3))          
    ,CAST(YEAR(@newdate) AS VARCHAR(4))          
    ) AS [Remarks]          
   ,CONCAT (          
    'SALARY '          
    ,UPPER(LEFT(FORMAT(@newdate, 'MMMM'), 3))          
 ,CAST(YEAR(@newdate) AS VARCHAR(4))          
    ) AS [Purpose Of Payment]          
  FROM T0080_EMP_MASTER emp          
  --INNER JOIN T0040_BANK_MASTER b WITH (NOLOCK) ON emp.Bank_Id = b.Bank_Id          
  INNER JOIN #Emp_Cons EC WITH (NOLOCK) ON EMP.Emp_ID = ec.Emp_ID          
  INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.Increment_ID = EC.Increment_ID          
   INNER JOIN T0040_BANK_MASTER b WITH (NOLOCK) ON I.Bank_Id = b.Bank_Id      
 --  AND I.Bank_Id = emp.Bank_ID     
  -- INNER JOIN T0030_BRANCH_MASTER bm WITH (NOLOCK) ON bm.Branch_ID = emp.Branch_ID  --ronakb030225
   left JOIN T0040_CompanyWise_Branch_Table bb WITH (NOLOCK) ON bb.Bank_Id = emp.Bank_Id and emp.Branch_ID= bb.Branch_Id     --ronakb030225
  INNER JOIN T0200_MONTHLY_SALARY S ON S.Emp_Id = ec.Emp_ID          
  WHERE emp.Cmp_id = @Cmp_ID          
   AND S.Month_St_Date >= @StartDate          
   AND S.Month_End_Date < @EndDate        
   AND S.Net_Amount > 0      
 END          
 Else If @flag='Other'      
  BEGIN          
  SELECT CONCAT (          
    'Prod Inc  '          
    ,LEFT(FORMAT(@newdate, 'MMMM'), 3)          
    ,CAST(YEAR(@newdate) AS VARCHAR(4))       
    ) AS [CUSTOM_DETAILS1]          
   ,REPLACE(CONVERT(VARCHAR, @Date, 103), '/', '-') AS [Value Date]          
   ,CASE           
    WHEN b.Bank_Name = 'BOB'    OR   b.Bank_Name = 'Bank Of Baroda'       
     THEN 'IFT'          
    ELSE 'NEFT'          
    END AS [Message Type]          
         --- , '''' + CONVERT(VARCHAR, b.Bank_Ac_No) AS [Debit Account No]       
     -- ,( '="' + RIGHT('000000000000000' + CONVERT(VARCHAR, I.Inc_Bank_AC_No), 15) + '"') AS [Debit Account No]  
	-- ,( '="' + RIGHT('00000000000000' + CONVERT(VARCHAR, bb.Account_No), 15) + '"')  AS [Debit Account No]           --ronakb030225
	 ,( '="' + RIGHT('' + CONVERT(VARCHAR, bb.Account_No), 15)+ '"') AS [Debit Account No]    
   --- ,RIGHT('0000000000' + CONVERT(VARCHAR,b.Bank_Ac_No ), 10) AS [Debit Account No]          
   ,emp.EmpName_Alias_PrimaryBank AS [Beneficiary Name]          
   ,S.Net_Amount AS [Payment Amount]          
   ,Ifsc_Code AS [Beneficiary Bank Swift Code / IFSC Code]         
     ,( '="' + RIGHT('000000000000000' + CONVERT(VARCHAR, b.Bank_Ac_No), 15) + '"') AS [Beneficiary Account No.]  
   --- , '''' + CONVERT(VARCHAR, I.Inc_Bank_AC_No) AS [Beneficiary Account No.]          
 --- ,RIGHT('0000000000' + CONVERT(VARCHAR, I.Inc_Bank_AC_No), 10) AS [Beneficiary Account No.]          
   ,CASE           
    WHEN b.Bank_Name = 'BOB'  OR     b.Bank_Name = 'Bank Of Baroda'      
     THEN 'IFT'          
    ELSE 'NEFT'          
    END AS [Transaction Type Code]          
   ,NULL AS [CUSTOM_DETAILS2]          
   ,NULL AS [CUSTOM_DETAILS3]          
   ,NULL AS [CUSTOM_DETAILS4]          
   ,NULL AS [CUSTOM_DETAILS5]          
   ,NULL AS [CUSTOM_DETAILS6]          
   ,CONCAT (          
    'Prod Inc  '          
    ,LEFT(FORMAT(@newdate, 'MMMM'), 3)      
    ,CAST(YEAR(@newdate) AS VARCHAR(4))          
    ) AS [Remarks]          
   ,CONCAT (          
    'Prod Inc  '          
    ,LEFT(FORMAT(@newdate, 'MMMM'), 3)      
 ,CAST(YEAR(@newdate) AS VARCHAR(4))          
    ) AS [Purpose Of Payment]          
  FROM T0080_EMP_MASTER emp          
  --INNER JOIN T0040_BANK_MASTER b WITH (NOLOCK) ON emp.Bank_Id = b.Bank_Id          
  INNER JOIN #Emp_Cons EC WITH (NOLOCK) ON EMP.Emp_ID = ec.Emp_ID          
  INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.Increment_ID = EC.Increment_ID          
   INNER JOIN T0040_BANK_MASTER b WITH (NOLOCK) ON I.Bank_Id = b.Bank_Id      
 --  AND I.Bank_Id = emp.Bank_ID      
 --  INNER JOIN T0030_BRANCH_MASTER bm WITH (NOLOCK) ON bm.Branch_ID = emp.Branch_ID  --ronakb030225
   left JOIN T0040_CompanyWise_Branch_Table bb WITH (NOLOCK) ON bb.Bank_Id = emp.Bank_Id and emp.Branch_ID= bb.Branch_Id     --ronakb030225
  INNER JOIN MONTHLY_EMP_BANK_PAYMENT S ON S.Emp_Id = ec.Emp_ID          
  WHERE emp.Cmp_id = @Cmp_ID          
 --  AND S.For_Date >= @StartDate          
 ---  AND S.Payment_Date < @EndDate        
   AND S.Net_Amount > 0      
 END          
      
      
 ELSE IF @flag = 'HDFC'          
 BEGIN          
  SELECT CASE           
    WHEN b.Bank_Name = 'HDFC'     OR b.Bank_Name = 'HDFC Bank'       
     THEN 'I'          
    ELSE 'N'          
    END AS [Payment Mode]          
-- ,('="' +  RIGHT('00000000' + REPLACE(CONVERT(VARCHAR, @Date, 103), '/', ''), 8) + '"') AS [Date]       
---, convert(varchar(10),@Date,103)  AS [Date]  
---,'="' + Right('' + REPLACE(CONVERT(VARCHAR, @Date, 103), '/', '') ,10)+ '"'  AS [Date]  
 ,CONCAT(      
  RIGHT('' + CONVERT(VARCHAR(2), DAY(@Date)), 2),      
     RIGHT('' + CONVERT(VARCHAR(2), MONTH(@Date)), 2),      
 YEAR(@Date)) AS [Date]      
      
  ---  ,'''' +   CONVERT(VARCHAR, I.Inc_Bank_AC_No) AS [Account Number]      
     ,( '="' + RIGHT('' + CONVERT(VARCHAR(20), I.Inc_Bank_AC_No), 20) + '"') AS [Account Number]   
    --- ,RIGHT('000000000000000' + CONVERT(VARCHAR, I.Inc_Bank_AC_No), 15) AS [Account Number]          
   ,S.Net_Amount AS [Amount]          
               
   ,emp.EmpName_Alias_PrimaryBank AS [Name]          
   ,'' AS 'Blank'          
   ,'' AS 'Blank '          
   ,'' AS 'Blank '          
   ,'' AS 'Blank '          
   ,'' AS 'Blank '          
   ,'' AS 'Blank '          
   ,'' AS 'Blank '          
   ,CONCAT (          
    'SALARY '          
    ,UPPER(LEFT(FORMAT(@newdate, 'MMMM'), 3))          
    ,Right(CAST(YEAR(@Date) AS VARCHAR(4)),2)          
    ) AS [Remark]          
   ,UPPER(CONCAT (          
    'SALARY '          
    ,LEFT(FORMAT(@newdate, 'MMMM'), 3)          
     ,Right(CAST(YEAR(@Date) AS VARCHAR(4)),2)          
    ) )AS [Remark1]          
   ,'' AS 'Blank '          
   ,'' AS 'Blank '          
   ,'' AS 'Blank '          
   ,'' AS 'Blank '          
   ,'' AS 'Blank '          
   ,'' AS 'Blank '          
, '="'+ REPLACE(CONVERT(VARCHAR, @Date, 103), '-', '/') + '"' AS [Date]          
-- ,CONVERT(VARCHAR, @Date, 102) AS [Date1]         
     ---,('="' +  RIGHT('0000000000' + (CONVERT(VARCHAR, @Date, 103)), 10) + '"') AS [Date]     
 --- , convert(varchar(10),@Date,101)  AS [Date]  
  --, '="' + CONVERT(VARCHAR, @Date, 103) + '"' AS [Date]  
   ,'' AS ' '          
   ,Ifsc_Code AS [IFSC Code]          
   ,b.Bank_Name AS [Bank Name]          
   ,b.Bank_Branch_Name AS [Branch]          
  --- ,@Email_ID  AS [Mail Id] 31122024      
    ,@Email_ID  AS [Mail Id]      
  FROM T0080_EMP_MASTER emp          
  ---INNER JOIN T0040_BANK_MASTER b WITH (NOLOCK) ON emp.Bank_Id = b.Bank_Id          
  INNER JOIN #Emp_Cons EC WITH (NOLOCK) ON EMP.Emp_ID = ec.Emp_ID          
  INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.Increment_ID = EC.Increment_ID        
   INNER JOIN T0040_BANK_MASTER b WITH (NOLOCK) ON I.Bank_Id = b.Bank_Id      
   ---AND I.Bank_Id = emp.Bank_ID          
  INNER JOIN T0200_MONTHLY_SALARY S  WITH (NOLOCK) ON S.Emp_Id = ec.Emp_ID          
  WHERE emp.Cmp_id = @Cmp_ID          
   AND S.Month_St_Date >= @StartDate          
   AND S.Month_End_Date < @EndDate          
  AND S.Net_Amount > 0          
 END          
      
END
