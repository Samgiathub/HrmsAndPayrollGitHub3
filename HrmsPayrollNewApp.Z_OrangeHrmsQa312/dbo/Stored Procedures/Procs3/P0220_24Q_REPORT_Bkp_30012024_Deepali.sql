
    
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---    
Create PROCEDURE [dbo].[P0220_24Q_REPORT_Bkp_30012024_Deepali]    
 @Cmp_Id Numeric,    
 @From_Date Datetime,    
 @To_Date Datetime,    
 @Constraint varchar(max)='',    
 @Format_Type varchar(50)=''    
     
AS    
    
SET NOCOUNT ON     
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
SET ARITHABORT ON    
    
BEGIN    
         
CREATE TABLE #Tax_Report_output    
   (     
  Row_ID numeric(18),    
  FIELD_NAME varchar(500),    
  Amount_Col_Final numeric(18,2),    
  Amount_Col_1 numeric(18,2),    
  Amount_Col_2 numeric(18,2),    
  Amount_Col_3 numeric(18,2),    
  Amount_Col_4 numeric(18,2),    
  Default_def_ID numeric(18,0),    
  AD_ID numeric(18,0),    
  IT_ID  numeric(18,0),    
  Emp_ID  numeric(18,0),    
  Emp_Code  numeric(18),    
  Alpha_Emp_Code varchar(50),    
  Emp_Full_Name varchar(100),    
  Desig_Name varchar(50),    
  Date_Of_Join datetime,    
  Pan_No varchar(50),    
  P_From_Date datetime,    
  P_To_Date datetime,    
  Is_Show tinyint,    
  Concate_Space numeric(18,0),    
  Exempted_Amount numeric(18,2),    
  Branch_ID numeric(18,0),    
  H_From_date datetime ,    
  H_To_test datetime,    
  field_type tinyint,    
  Show_In_SalarySlip tinyint, -- Added By Ali 05042014    
  Display_Name_For_SalarySlip varchar(300), -- Added By Ali 05042014    
  Column_24Q tinyint default 0 --added by Hardik 19/08/2014    
  ,Amount_Col_Actual    NUMERIC DEFAULT 0,  -- Added By rohit For Actual Value on 04052015    
  Amount_Col_Assumed   NUMERIC DEFAULT 0, -- Added by rohit For Assumed Value on 04052015    
  Dept_Name varchar(Max),    
  branch_Name Varchar(max)    
   )    
     
 CREATE NONCLUSTERED INDEX ind_temp2 ON #Tax_Report_output(Row_ID)    
 CREATE NONCLUSTERED INDEX ind_temp3 ON #Tax_Report_output(Emp_ID)    
 CREATE NONCLUSTERED INDEX ind_temp4 ON #Tax_Report_output(Field_Name)    
    
    
 CREATE TABLE #Final_Table    
 (    
  Emp_PAN varchar(200),    
  Emp_Name varchar(Max),    
  Designation varchar(200),    
  Men_Women_Senior_Cityzen varchar(100),    
  From_Date datetime,    
  To_Date Datetime,    
  Taxable_Amount numeric(18,2),    
  Income_Section_192_2B numeric(18,2),    
  Amount_80C_80CCC_80CCD Numeric(18,2),    
  Amount_Chapter_VI_A Numeric(18,2),    
  Total_Tax Numeric(18,2),    
  Total_Amount_Tax_Deducted_Whole_Year numeric(18,2)    
 )    
    
 declare @form_id as integer    
 set @form_id = 0    
 SELECT @form_id = isnull(Form_ID,0) from T0040_FORM_MASTER WITH (NOLOCK) where Form_Name = 'Income Tax'  and Cmp_ID = @Cmp_ID    
       
  
    
 Select * from (    
    
  SELECT  Cast(Row_number() over (Order by Year,Month) As numeric(18,0)) S_No, Tax_Amount As TDS, '' as 'Surcharge', ED_Cess as 'Education_Cess', '' as 'Higher_Education_Cess',    
    Interest_Amount As Interest, Other_Amount As Other, Penalty_Amount As Fee, Cheque_No as Cheque_Or_DD_No, Bank_BSR_Code as BSR_Code,    
    Convert(varchar(11),Payment_Date,103) as Date_on_Which_Tax_Deposited, CIN_No as Transfer_Voucher_or_Challan_Serial_No, 'No' As 'Whether_TDS_Deposited_by_Book_Entry?',    
    200 As 'Minor_Head'    
  FROM         T0220_TDS_CHALLAN WITH (NOLOCK)    
  WHERE Cmp_Id = @Cmp_Id And dbo.GET_MONTH_ST_DATE(Month,Year) >= @From_Date And    
    dbo.GET_MONTH_END_DATE(Month,Year) <= @To_Date    
  --Union     
  -- Select '="301"' ,'302','303','304','305','306','307','0','308','309','310','311','312','0'    
   ) Qry order by S_No Asc    
        
     
  SELECT    Row_number() over (Order by TCD.Challan_Id,TCD.Emp_Id) Serial_No,E.Alpha_Emp_Code as Employee_reference_No_provided_by_employer,    
     E.Pan_No As PAN_of_the_Employee, E.Emp_Full_Name as Name_Of_Employee, CONVERT(varchar(11),Month_End_Date,103) as Date_of_Payment_or_Credit,    
     '' as Period_of_Employment, (Isnull(MS.Gross_Salary,0) - Isnull(MS.Settelement_Amount,0)) + ISNULL(MSS.S_Gross_Salary,0) As Taxable_Amount_on_which_Tax_deducted, -- Change Condition for Gross by Hardik 23/07/2018 for Inductotherm as gross showing NetSettlement amount which is wrong    
     --MS.M_IT_Tax as TDS,'' as 'Surcharge', TCD.Ed_Cess as 'Education_Cess', '' as 'Higher_Education_Cess', MS.M_IT_Tax as Total_Tax_Deducted,    
     --Added TDS Amount and ED Cess as per requirement of TOTO on 25/07/2016 by Hardik    
     TCD.TDS_Amount as TDS,'' as 'Surcharge', TCD.Ed_Cess as 'Education_Cess', '' as 'Higher_Education_Cess',    
      --MS.M_IT_Tax as Total_Tax_Deducted, MS.M_IT_Tax As Total_Tax_Deposited, -- changed by rohit for Total Showing Wrong on 19052017    
      isnull(TCD.TDS_Amount,0) + isnull(TCD.Ed_Cess,0)  as Total_Tax_Deducted, isnull(TCD.TDS_Amount,0) + isnull(TCD.Ed_Cess,0) As Total_Tax_Deposited,    
          
       CONVERT(varchar(11),Month_End_Date,103) as Date_of_deduction, Payment_Date as Date_of_Deposited,    
     CIN_No as Transfer_Voucher_or_Challan_Serial_No,Bank_BSR_Code as BSR_Code,CIN_No as Challan_S_No,'' as Reason_for_non_deduction_or_lower_deduction  FROM T0230_TDS_CHALLAN_DETAIL TCD WITH (NOLOCK) INNER JOIN    
     T0220_TDS_CHALLAN TC WITH (NOLOCK) on TC.Challan_Id = TCD.Challan_Id Inner Join    
     T0080_EMP_MASTER E WITH (NOLOCK) ON TCD.Emp_Id = E.Emp_ID Left Outer Join    
     T0200_MONTHLY_SALARY MS WITH (NOLOCK) on TC.Month = Month(Month_End_Date) and TC.Year = Year(Month_End_Date) And TCD.Emp_Id = MS.Emp_ID Left Outer Join    
     T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK) on TC.Month = Month(S_Month_End_Date) and TC.Year = Year(S_Month_End_Date) And TCD.Emp_Id = MSS.Emp_ID    
  WHERE Tc.cmp_id = @Cmp_Id And dbo.GET_MONTH_ST_DATE(Month,Year) >= @From_Date And    
    dbo.GET_MONTH_END_DATE(Month,Year) <= @To_Date    
  ORDER BY TCD.CHALLAN_ID    
    
    
      
  --insert into #Tax_Report_output    
  --exec SP_IT_TAX_PREPARATION @Cmp_ID=@Cmp_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0,@Constraint='',@Product_ID=0,@Taxable_Amount_Cond=0,@Form_ID=@form_id    
    
  --DECLARE @CONSTRAINT VARCHAR(MAX)    
  --SELECT TOP 100 @CONSTRAINT = COALESCE(@CONSTRAINT + '#', '')  + CAST(EMP_ID AS VARCHAR(10))    
  --FROM T0080_EMP_MASTER WHERE Emp_Left_Date IS NULL    
    
    DECLARE @fin_year AS NVARCHAR(20)      
    Set @fin_year = ''    
     
    
    Declare @Fn_Start_Date as Datetime    
    Declare @Fn_ENd_Date as Datetime    
     
    select @Fn_Start_Date = dbo.GET_YEAR_START_DATE(year(@From_date),MONTH(@From_date),0)    
    select @Fn_ENd_Date = dbo.GET_YEAR_END_DATE(year(@To_Date),MONTH(@To_Date),0)    
     
    SET @fin_year = CAST(YEAR(@Fn_Start_Date) AS NVARCHAR) + '-' + CAST(YEAR(@Fn_ENd_Date) AS NVARCHAR)    
    
      
  insert into #Tax_Report_output     
  exec SP_IT_TAX_PREPARATION @Cmp_ID=@Cmp_ID,@From_Date=@Fn_Start_Date,@To_Date=@Fn_ENd_Date,@Branch_ID='',@Cat_ID='',@Grd_ID='',@Type_ID='',@Dept_ID='',@Desig_ID='',@Emp_ID=0,@Constraint=@Constraint,@Product_ID=0,@Taxable_Amount_Cond=0,@Format_Name ='Format1',@Form_ID=@form_id,@Sp_Call_For = 'Form24Q',@Month_En_Date = NULL ,@Month_St_Date = NULL ,@Salary_Cycle_id = 0, @Segment_ID = '' ,@Vertical = '' ,@SubVertical = '' ,@subBranch = ''    

  
  
  If @Format_Type = 'Format Before 2019'    
   BEGIN    
    Select Distinct T.Pan_No,E.Emp_Full_Name, T.Desig_Name As Designation,     
     Case When CAST(dbo.F_GET_AGE(E.Date_Of_Birth,getdate(),'N','Y') AS Numeric(18,2)) > 60 Then 'S - Senior Citizen'      
      When E.Gender='F' Then 'W - Woman'     
      Else '' End as Gender,    
      Case When E.Date_Of_Join > @From_Date then E.Date_Of_Join Else @From_Date End as From_Date,    
      Case When E.Emp_Left_Date < @To_Date then E.Emp_Left_Date else @To_Date End as To_Date,     
      (Select Amount_Col_Final From #Tax_Report_output P Where Column_24Q = 1 and P.Emp_ID = T.Emp_ID) as Taxable_Amount,    
      (Select Amount_Col_Final From #Tax_Report_output P Where Column_24Q = 2 and P.Emp_ID = T.Emp_ID) as Reported_Taxable_Amount_Pre_Employer,    
      (Select Amount_Col_Final From #Tax_Report_output P Where Column_24Q = 1 and P.Emp_ID = T.Emp_ID) as Total_Amount_of_Salary,    
     0 as Total_Deduction_Under_Sec_16II,    
      (Select Amount_Col_Final From #Tax_Report_output P Where Column_24Q = 4 and P.Emp_ID = T.Emp_ID) as Total_Deduction_Under_Sec_16III,    
      '' as Income_Chargeable,    
      Isnull((Select Amount_Col_Final From #Tax_Report_output P Where Column_24Q = 5 and P.Emp_ID = T.Emp_ID),0) as Income_Section_192_2B,    
      0 as Gross_Total_Income,    
      Isnull((Select Amount_Col_Final From #Tax_Report_output P Where Column_24Q = 6 and P.Emp_ID = T.Emp_ID),0) as Amount_80C_80CCC_80CCD,    
      0 as Amount_80CCF,    
      0 as Amount_80CCG,    
      Isnull((Select Amount_Col_Final From #Tax_Report_output P Where Column_24Q = 9 and P.Emp_ID = T.Emp_ID),0) -     
      Isnull((Select Amount_Col_Final From #Tax_Report_output P Where Column_24Q = 6 and P.Emp_ID = T.Emp_ID),0) as Amount_Chapter_VI_A,    
      '' as Total_Amount_Under_Chapter_VIA,    
      '' as Total_Taxable_Income,    
      Isnull((Select Amount_Col_Final From #Tax_Report_output P Where Column_24Q = 10 and P.Emp_ID = T.Emp_ID),0) as Total_Tax,    
      Isnull((Select Amount_Col_Final From #Tax_Report_output P Where Column_24Q = 11 and P.Emp_ID = T.Emp_ID),0) as Surcharge,    
      Isnull((Select Amount_Col_Final From #Tax_Report_output P Where Column_24Q = 12 and P.Emp_ID = T.Emp_ID),0) as Ed_Cess,    
      Isnull((Select Amount_Col_Final From #Tax_Report_output P Where Column_24Q = 13 and P.Emp_ID = T.Emp_ID),0) as H_Ed_Cess,    
      Isnull((Select Amount_Col_Final From #Tax_Report_output P Where Column_24Q = 14 and P.Emp_ID = T.Emp_ID),0) as Income_Tax_Relief_Under_Sec_89,    
      '' as Net_Tax_Payable,    
      Isnull((Select Amount_Col_Final From #Tax_Report_output P Where Column_24Q = 15 and P.Emp_ID = T.Emp_ID),0) as Total_Amount_Tax_Deducted_Whole_Year,    
      Isnull((Select Amount_Col_Final From #Tax_Report_output P Where Column_24Q = 16 and P.Emp_ID = T.Emp_ID),0) as Reported_Amt_Tax_Pre_Employer,    
      '' as Total_amount_of_Tax_Deducted,    
      '' as ShortFall_in_Tax_Deduction,    
      T.Emp_Code As Emp_Code    
    From #Tax_Report_output T inner join T0080_EMP_MASTER E WITH (NOLOCK) on T.Emp_ID = E.Emp_ID     
    order by T.Emp_Code    
    RETURN     
   END    
  ELSE IF @Format_Type = 'Format From 2019'    
   BEGIN    
    
    CREATE TABLE #PIVOT_24Q    
    (    
     Emp_ID  INT,    
     Desig_Name Varchar(128)    
    )    
     
    DECLARE @SQL NVARCHAR(MAX)    
    DECLARE @COLS NVARCHAR(MAX)    
    DECLARE @COLS_PAN_LANDLORD NVARCHAR(150)    
        
    DECLARE @LAST_EFF_DATE DateTime    
    SELECT @LAST_EFF_DATE = Max(Effective_Date) FROM T0040_24Q_COLUMN_SETTINGS WITH (NOLOCK) Where Effective_Date <= @To_Date    
    
    SET @COLS_PAN_LANDLORD = '' 
	
	-- Ronak 110120221
		-- SELECT Column_Name  
		--FROM T0040_24Q_COLUMN_SETTINGS  WITH (NOLOCK)    
		--WHERE Effective_Date = @LAST_EFF_DATE  and Column_Name LIKE '%PAN OF LANDLORD%' 

	-- Select @COLS_PAN_LANDLORD = Column_Name     
	-- from(
	--	SELECT Column_Name  
	--	FROM T0040_24Q_COLUMN_SETTINGS  WITH (NOLOCK)    
	--	WHERE Effective_Date = @LAST_EFF_DATE  
	--	union 
	--	SELECT Column_Name  
	--	FROM T0040_24Q_COLUMN_SETTINGS  WITH (NOLOCK)    
	--	WHERE Column_Name LIKE '%PAN OF LANDLORD%'
	--) as q
	    
    Select @COLS_PAN_LANDLORD = Column_Name     
	 from(
		SELECT Column_Name  
		FROM T0040_24Q_COLUMN_SETTINGS  WITH (NOLOCK)    
		WHERE Effective_Date = @LAST_EFF_DATE  
		union 
		SELECT Column_Name  
		FROM T0040_24Q_COLUMN_SETTINGS  WITH (NOLOCK)    
		WHERE Column_Name LIKE '%PAN OF LANDLORD%'
	) as q

    SELECT @SQL = COALESCE(@SQL + ';','') + CASE WHEN @COLS_PAN_LANDLORD = Column_Name THEN     
                  'ALTER TABLE #PIVOT_24Q ADD [' + Column_Name + '] VARCHAR(30)'     
                ELSE 'ALTER TABLE #PIVOT_24Q ADD [' + Column_Name + '] Numeric(18,2)' END,    
      @COLS = COALESCE(@COLS + ',','') + QUOTENAME(Column_Name)    
    FROM T0040_24Q_COLUMN_SETTINGS TCS WITH (NOLOCK)    
    WHERE TCS.Effective_Date=@LAST_EFF_DATE    
    ORDER BY Sort_ID    
    
    EXEC sp_executesql @SQL    
        
    CREATE TABLE #EMP_LIST(EMP_ID INT, Column_24Q INT, Amount_Col_Final NUMERIC(18,2),Desig_Name Varchar(128))    
          
    INSERT INTO #EMP_LIST    
    SELECT T.EMP_ID, TFQ.IT_24Q_Id,0, Desig_Name    
    FROM (SELECT DISTINCT EMP_ID,Desig_Name FROM #Tax_Report_output) T     
      CROSS JOIN T0040_24Q_COLUMN_SETTINGS TFQ WITH (NOLOCK)    
    WHERE TFQ.Effective_Date = @LAST_EFF_DATE    
        
    UPDATE EL    
    SET  Amount_Col_Final = T.Amount_Col_Final    
    FROM #EMP_LIST EL    
      INNER JOIN #Tax_Report_output T ON EL.Emp_ID=T.Emp_ID AND EL.Column_24Q=T.Column_24Q    
    
	
     
    
    SET @SQL = 'INSERT INTO #PIVOT_24Q    
       SELECT Emp_ID,Desig_Name,' + @COLS + '    
       FROM (    
          SELECT  Column_Name ,  Amount_Col_Final As Amount,Emp_ID,Desig_Name    
          FROM T0040_24Q_COLUMN_SETTINGS TFQ WITH (NOLOCK)    
            INNER JOIN #EMP_LIST T ON T.Column_24Q = TFQ.IT_24Q_Id    
          WHERE TFQ.Effective_Date = @LAST_EFF_DATE            
         ) PVT            
         PIVOT    
         (    
          SUM(Amount) FOR Column_Name IN (' + @COLS + ')    
         ) T '    
    
    
    EXEC sp_executesql @SQL, N'@LAST_EFF_DATE DateTime', @LAST_EFF_DATE    
    
    SET @SQL = ''    
    

	
    SET @SQL = 'UPDATE P SET [' + @COLS_PAN_LANDLORD + ']= IE.Detail_3    
       FROM #PIVOT_24Q P     
       INNER JOIN T0110_IT_Emp_Details IE ON P.EMP_ID = IE.Emp_ID    
         INNER JOIN T0070_IT_MASTER I On IE.IT_ID = I.IT_ID     
       WHERE I.IT_Def_ID=1 and IE.Financial_Year= ''' + @fin_year + ''' and IE.Cmp_Id =' + CAST(@Cmp_Id AS VARCHAR(4)) +' And IE.Detail_3 <>'''''    
    
          
	
    EXEC sp_executesql @SQL    
  
    
     Select ROW_NUMBER()OVER(ORDER by E.Emp_Code) As Sr_No, E.Pan_No,E.Emp_Full_Name, --T.Desig_Name As Designation,     
       Case When CAST(dbo.F_GET_AGE(E.Date_Of_Birth,getdate(),'N','Y') AS Numeric(18,2)) > 60 Then 'S'      
        When E.Gender='F' Then 'W'     
        Else 'G' End as Gender,    
        Case When E.Date_Of_Join > @From_Date then E.Date_Of_Join Else @From_Date End as From_Date,    
        Case When E.Emp_Left_Date < @To_Date then E.Emp_Left_Date else @To_Date End as To_Date,     
        T.*,         
        E.Emp_Code As Emp_Code    
     INTO #FINAL    
     From #PIVOT_24Q T     
       INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) on T.Emp_ID = E.Emp_ID     
     order by E.Emp_Code    
         
     ALTER TABLE #FINAL DROP COLUMN Desig_Name, Emp_ID    
     SELECT  * FROM #FINAL     
   END     
    
END    
    
    
    
