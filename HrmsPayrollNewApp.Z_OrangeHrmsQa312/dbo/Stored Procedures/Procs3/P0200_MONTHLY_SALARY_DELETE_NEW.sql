-- exec P0200_MONTHLY_SALARY_DELETE_NEW  
-- drop proc P0200_MONTHLY_SALARY_DELETE_NEW  
CREATE PROCEDURE [dbo].[P0200_MONTHLY_SALARY_DELETE_NEW]  
@SAL_TRAN_ID_EMP_ID VARCHAR(max),  
@CMP_ID numeric,  
@FROM_Date datetime,  
@to_date datetime,  
@User_Id numeric(18,3) = 0,  
@IP_Address VARCHAR(30) = ''  
as  
begin  
 SET NOCOUNT ON   
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
 SET ARITHABORT ON  
  
 DECLARE @KEYGUID VARCHAR(50) = NULL,@Is_Consider_LWP_In_Same_Month TINYINT,@i INT,@cnt INT  
 Set @Is_Consider_LWP_In_Same_Month = 0  
  
 SELECT @Is_Consider_LWP_In_Same_Month = ISNULL(Setting_Value,0)   
 FROM T0040_SETTING WITH (NOLOCK) WHERE Setting_Name = 'Consider LWP in Same Month for Cutoff Salary' AND Cmp_Id = @Cmp_Id  
  
 CREATE TABLE #tbltmp  
 (  
  tid INT IDENTITY(1,1),t_SalTranId NUMERIC,t_EmpId NUMERIC,t_BranchId INT,t_SalDate DATETIME,t_SalEndDate DATETIME,  
  t_manual_salary_period NUMERIC(18,0),t_RaisedError VARCHAR(5000),t_Severity INT,t_State INT,t_EmpName VARCHAR(150),  
  t_Value VARCHAR(max),t_CutOff_Date DATETIME,t_For_Date DATETIME,t_BOND_RETURN_MONTH INT,t_BOND_RETURN_YEAR INT,  
  t_Leave_Approval_ID NUMERIC(18,0),t_Approval_Date DATETIME,t_OldValue VARCHAR(max),t_LeaveName VARCHAR(500),  
  t_LeaveId NUMERIC(18,0),t_CurrentLeaveId NUMERIC  
 )  
 INSERT INTO #tbltmp  
 SELECT val1,val2,0,NULL,NULL,0,'',0,0,'','',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL FROM dbo.Split(@SAL_TRAN_ID_EMP_ID,',')  
 CROSS APPLY dbo.fnc_BifurcateString(isNULL(data,''),'-') WHERE data <> ''  
  
 UPDATE w SET t_EmpName = ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'') FROM #tbltmp w INNER JOIN T0080_EMP_MASTER ON Emp_ID = t_EmpId  
  
 UPDATE w SET t_SalDate = MONTH_ST_DATE,t_SalEndDate = Month_End_Date FROM #tbltmp w INNER JOIN T0200_MONTHLY_SALARY  
 on t_SalTranId = SAL_TRAN_ID  
  
 UPDATE w SET t_CutOff_Date = Cutoff_Date FROM #tbltmp w INNER JOIN T0200_MONTHLY_SALARY ON SAL_TRAN_ID = t_SalTranId AND EMP_ID = t_EmpId  
  
 UPDATE w SET t_BranchId = Branch_ID FROM #tbltmp w   
 INNER JOIN T0095_Increment I ON Emp_ID = t_EmpId INNER JOIN       
 (  
  select max(Increment_Id) as Increment_Id,Emp_ID,t_EmpId as Innertid  
  FROM T0095_Increment WITH (NOLOCK)  
  INNER JOIN #tbltmp ON Emp_ID = t_EmpId  
  WHERE Increment_Effective_date <= t_SalEndDate      
  and Cmp_ID = @Cmp_ID AND Emp_ID = t_EmpId  
  group by emp_ID,t_EmpId  
 ) Qry ON I.Emp_ID = Qry.Emp_ID AND I.Increment_Id = Qry.Increment_Id      
 WHERE t_EmpId = Innertid  
  
 UPDATE w SET t_manual_salary_period = isNULL(Manual_Salary_Period ,0) FROM #tbltmp w LEFT JOIN T0040_GENERAL_SETTING ON Branch_ID = t_BranchId WHERE cmp_ID = @cmp_ID      
 and For_Date = (select max(For_Date) FROM T0040_GENERAL_SETTING WITH (NOLOCK) LEFT JOIN #tbltmp ON Branch_ID = t_BranchId WHERE For_Date <= @to_date AND Cmp_ID = @Cmp_ID)  
  
 UPDATE w SET t_RaisedError = '@@This month salary is locked by admin.@@',t_Severity = 16,t_State = 2  
 FROM #tbltmp w LEFT JOIN T0250_MONTHLY_LOCK_INFORMATION ON Branch_ID = t_BranchId  
 WHERE MONTH = MONTH(t_SalEndDate) AND YEAR =  year(t_SalEndDate) AND Cmp_ID = @CMP_ID  
 and t_State = 0  
  
 UPDATE w SET t_RaisedError = '@@Salary already exist for the next month. DELETE the next month salary first.@@',t_Severity = 16,t_State = 2  
 FROM #tbltmp w INNER JOIN T0200_MONTHLY_SALARY ON EMP_ID = t_EmpId WHERE Month_St_Date >= @To_Date AND t_State = 0  
  
 UPDATE w SET t_RaisedError = '@@PF Challan is generated for this month salary. DELETE the challan first.@@',t_Severity = 16,t_State = 1  
 FROM #tbltmp w INNER JOIN T0220_Pf_Challan ON CHARINDEX('#'+ Cast(t_BranchId As VARCHAR(18)) ,'#' + Branch_ID_Multi) > 0  
 WHERE Cmp_Id = @CMP_ID AND Month=Month(@to_date) AND Year = Year(@to_date) AND t_State = 0  
  
 UPDATE w SET t_RaisedError = '@@ESIC Challan is generated for this month salary. DELETE the challan first.@@',t_Severity = 16,t_State = 1  
 FROM #tbltmp w INNER JOIN T0220_ESIC_Challan ON CHARINDEX('#'+ Cast(t_BranchId As VARCHAR(18)) ,'#' + Branch_ID_Multi) > 0  
 WHERE Cmp_Id = @CMP_ID AND Month=Month(@to_date) AND Year = Year(@to_date) AND t_State = 0  
  
 UPDATE w SET t_RaisedError = '@@PT Challan is generated for this month salary. DELETE the challan first.@@',t_Severity = 16,t_State = 1  
 FROM #tbltmp w INNER JOIN T0220_PT_CHALLAN ON CHARINDEX('#'+ Cast(t_BranchId As VARCHAR(18)) ,'#' + Branch_ID_Multi) > 0  
 WHERE Cmp_Id = @CMP_ID AND Month=Month(@to_date) AND Year = Year(@to_date) AND t_State = 0  
  
 UPDATE w SET t_RaisedError = '@@TDS Challan is generated for this month salary. DELETE the challan first.@@',t_Severity = 16,t_State = 1  
 FROM #tbltmp w INNER JOIN T0220_TDS_CHALLAN ON Cmp_Id = @CMP_ID AND Month=Month(@to_date) AND Year = Year(@to_date)  
 WHERE t_State = 0  
   
 UPDATE w SET t_RaisedError = '@@This Month Salary Settlement Exists.@@',t_Severity = 16,t_State = 2  
 FROM #tbltmp w INNER JOIN T0201_MONTHLY_SALARY_SETT ON Emp_ID = t_EmpId  
 WHERE Cmp_Id = @CMP_ID AND S_Month_St_Date >= @FROM_Date AND S_Month_End_Date <= @to_date AND t_State = 0  
  
 UPDATE w SET t_RaisedError = '@@Payment Process Exists for this month@@',t_Severity = 16,t_State = 2  
 FROM #tbltmp w INNER JOIN MONTHLY_EMP_BANK_PAYMENT MEB ON MEB.EMP_ID = t_EmpId  
 LEFT JOIN  
 (  
  select Ad_Id FROM T0050_AD_MASTER WITH (NOLOCK) WHERE Is_Calculated_On_Imported_Value = 0  
 ) AM ON MEB.Ad_Id = AM.AD_ID  
 WHERE month(MEB.for_date)= Month(@To_Date) AND Year(MEB.for_date)= Year(@To_Date) AND (MEB.Process_Type ='Salary' or isNULL(Am.Ad_id,0) > 0)  
 and t_State = 0  
  
 UPDATE w SET t_RaisedError = '@@Payment Detail Exists for this month@@',t_Severity = 16,t_State = 2  
 FROM #tbltmp w INNER JOIN T0302_Process_Detail MEB ON MEB.EMP_ID = t_EmpId  
 LEFT JOIN  
 (  
  select Ad_Id FROM T0050_AD_MASTER  WITH (NOLOCK) WHERE Is_Calculated_On_Imported_Value = 0 AND isNULL(Allowance_Type,'A')='A'  
 ) AM ON MEB.Ad_Id = AM.AD_ID  
 WHERE month(MEB.for_date)= Month(@To_Date) AND Year(MEB.for_date)= Year(@To_Date) AND isNULL(AM.Ad_id,0)> 0 AND meb.payment_process_id > 0  
 and t_State = 0  
  
 UPDATE w SET t_RaisedError = '@@Bond Payment Process Exists for this month@@',t_Severity = 16,t_State = 2  
 FROM #tbltmp w INNER JOIN MONTHLY_EMP_BANK_PAYMENT MEB ON t_EmpId = MEB.Emp_ID  
 INNER JOIN T0120_BOND_APPROVAL BA ON BA.Emp_Id = MEB.Emp_ID AND BA.Payment_Process_ID = MEB.payment_process_id  
 WHERE MEB.Process_Type ='Bond' AND MEB.EMP_ID = t_EmpId AND Bond_Return_Date >= @FROM_Date AND t_State = 0  
  
 UPDATE w SET t_Value = 'old Value#Employee Name :' + isNULL(t_EmpName,'') +   
 '#Salary Receipt No :' + convert(VARCHAR,isNULL(Sal_Receipt_No,0)) +  
 '#Increment ID :' + convert(VARCHAR,isNULL(Increment_ID,0)) +  
 '#Month Start Date :' + cast(ISNULL(Month_St_Date,'') as NVARCHAR(11)) +  
 '#Month End Date :' + cast(ISNULL(Month_End_Date,'') as NVARCHAR(11)) +  
 '#Salary Generate Date :' + cast(ISNULL(Sal_Generate_Date,'') as NVARCHAR(11)) +  
 '#Salary Calculate Days :' + convert(VARCHAR,isNULL(Sal_cal_Days,0)) +  
 '#Present Days :' + CONVERT(VARCHAR,ISNULL(Present_Days,0)) +  
 '#Absent Days :' + CONVERT(VARCHAR,ISNULL(Absent_Days,0)) +  
 '#Holiday Days :' + CONVERT(VARCHAR,ISNULL(Holiday_Days,0)) +  
 '#Weekoff Days :' + CONVERT(VARCHAR,ISNULL(Weekoff_Days,0)) +  
 '#Cancel Holiday :' + CONVERT(VARCHAR,ISNULL(Cancel_Holiday,0)) +  
 '#Cancel Weekoff :' + CONVERT(VARCHAR,ISNULL(Cancel_Weekoff,0)) +  
 '#Outof Days :' + CONVERT(VARCHAR,ISNULL(Outof_Days,0)) +  
 '#Paid Leave Days :' + CONVERT(VARCHAR,ISNULL(Paid_Leave_Days,0)) +  
 '#Actual Working Hours :' + CONVERT(VARCHAR,ISNULL(Actual_Working_Hours,0)) +  
 '#Working Hours :' + CONVERT(VARCHAR,ISNULL(Working_Hours,0)) +  
 '#Outof Hours :' + CONVERT(VARCHAR,ISNULL(Outof_Hours,0)) +  
 '#Employee OT Hours :' + CONVERT(VARCHAR,ISNULL(OT_Hours,0)) +  
 '#On Duty Leave Days :' + CONVERT(VARCHAR,ISNULL(OD_Leave_Days,0)) +  
 '#Shift Day In Sec :' + CONVERT(VARCHAR,ISNULL(Shift_Day_Sec,0)) +  
 '#Shift Day In Hour :' + CONVERT(VARCHAR,ISNULL(Shift_Day_Hour,0)) +  
 '#Early Sec :' + CONVERT(VARCHAR,ISNULL(Early_Sec,0)) +  
 '#Early Days :' + CONVERT(VARCHAR,ISNULL(Early_Days,0)) +  
 '#Late Sec :' + CONVERT(VARCHAR,ISNULL(Late_Sec,0)) +  
 '#Late Days :' + CONVERT(VARCHAR,ISNULL(Late_Days,0)) +  
 '#Late Early Penalty days :' + CONVERT(VARCHAR,ISNULL(Late_Early_Penalty_days,0)) +  
 '#Total Leave Days :' + CONVERT(VARCHAR,ISNULL(Total_Leave_Days,0)) +  
 '#Working Days :' + CONVERT(VARCHAR,ISNULL(Working_Days,0)) +  
 '#Total Hours :' + CONVERT(VARCHAR,ISNULL(Total_Hours,0)) +  
 '#PT LIMIT :' + CONVERT(VARCHAR,ISNULL(PT_F_T_Limit,0)) +  
 '#Basic Amount :' + CONVERT(VARCHAR,ISNULL(Basic_Salary,0)) +  
 '#Day Salary :' + CONVERT(VARCHAR,ISNULL(Day_Salary,0)) +  
 '#Day Salary :' + CONVERT(VARCHAR,ISNULL(Day_Salary,0)) +  
 '#Hour Salary :' + CONVERT(VARCHAR,ISNULL(Hour_Salary,0)) +  
 '#Salary Amount :' + CONVERT(VARCHAR,ISNULL(Salary_Amount,0)) +  
 '#Allowance Amount :' + CONVERT(VARCHAR,ISNULL(Allow_Amount,0)) +  
 '#Other Allowance Amount :' + CONVERT(VARCHAR,ISNULL(Other_Allow_Amount,0)) +  
 '#OT Amount :' + CONVERT(VARCHAR,ISNULL(OT_Amount,0)) +  
 '#Leave Salary Amount :' + CONVERT(VARCHAR,ISNULL(Leave_Salary_Amount,0)) +  
 '#Bonus Amount :' + CONVERT(VARCHAR,ISNULL(Bonus_Amount,0)) +  
 '#WeekOff OT Hours :' + CONVERT(VARCHAR,ISNULL(0,0)) +  
 '#WeekOff OT Amount :' + CONVERT(VARCHAR,ISNULL(0,0)) +  
 '#Holiday OT Hours :' + CONVERT(VARCHAR,ISNULL(0,0)) +  
 '#Holiday OT Amount :' + CONVERT(VARCHAR,ISNULL(0,0)) +  
 '#Salary Amount Arear :' + CONVERT(VARCHAR,ISNULL(Arear_Basic,0)) +  
 '#Gross Salary Arear :' + CONVERT(VARCHAR,ISNULL(Arear_Gross,0)) +  
 '#Arear Day :' + CONVERT(VARCHAR,ISNULL(Arear_Day,0)) +  
 '#Total Earning Fraction :' + CONVERT(VARCHAR,ISNULL(Arear_Day,0)) +  
 '#Gross Amount :' + CONVERT(VARCHAR,ISNULL(Gross_Salary,0)) +  
 '#Deduction Amount :' + CONVERT(VARCHAR,ISNULL(Dedu_Amount,0)) +  
 '#Loan Amount :' + CONVERT(VARCHAR,ISNULL(Loan_Amount,0)) +  
 '#Loan Intrest Amount :' + CONVERT(VARCHAR,ISNULL(Loan_Intrest_Amount,0)) +  
 '#Bond Amount :' + CONVERT(VARCHAR,ISNULL(Bond_Amount,0)) +  
 '#Advance Amount :' + CONVERT(VARCHAR,ISNULL(Advance_Amount,0)) +  
 '#Other Deduction Amount :' + CONVERT(VARCHAR,ISNULL(Other_Dedu_Amount,0)) +  
 '#Due Loan Amount :' + CONVERT(VARCHAR,ISNULL(Due_Loan_Amount,0)) +  
 '#PT Calculated Amount :' + CONVERT(VARCHAR,ISNULL(PT_Calculated_Amount,0)) +  
 '#PT Amount :' + CONVERT(VARCHAR,ISNULL(PT_Amount,0)) +  
 '#Total Claim Amount :' + CONVERT(VARCHAR,ISNULL(Total_Claim_Amount,0)) +  
 '#IT Tax :' + CONVERT(VARCHAR,ISNULL(M_IT_Tax,0)) +  
 '#ADVANCE Amount :' + CONVERT(VARCHAR,ISNULL(Advance_Amount,0)) +  
 '#Loan Amount :' + CONVERT(VARCHAR,ISNULL(Loan_Amount,0)) +  
 '#OT Hours :' + CONVERT(VARCHAR,ISNULL(OT_Hours,0)) +  
 '#LWF Amount :' + CONVERT(VARCHAR,ISNULL(LWF_Amount,0)) +  
 '#Revenue Amount :' + CONVERT(VARCHAR,ISNULL(Revenue_Amount,0)) +  
 '#Late Deduction Amount :' + CONVERT(VARCHAR,ISNULL(Late_Dedu_Amount,0)) +  
 '#Extra Late Deduction :' + CONVERT(VARCHAR,ISNULL(Late_Extra_Dedu_Amount,0)) +  
 '#Extra Absent Days :' + CONVERT(VARCHAR,ISNULL(Extra_AB_Days,0)) +  
 '#Extra Absent Rate :' + CONVERT(VARCHAR,ISNULL(Extra_AB_Rate,0)) +  
 '#Extra Absent Amount :' + CONVERT(VARCHAR,ISNULL(Extra_AB_Amount,0)) +  
 '#Early Deduction Amount :' + CONVERT(VARCHAR,ISNULL(Early_Dedu_Amount,0)) +  
 '#Early Extra Deduction Amount :' + CONVERT(VARCHAR,ISNULL(Early_Extra_Dedu_Amount,0)) +  
 '#IT ED Cess Amount :' + CONVERT(VARCHAR,ISNULL(0,0)) +  
 '#IT Surcharge Amount :' + CONVERT(VARCHAR,ISNULL(0,0)) +  
 '#Total Deduction Amount :' + CONVERT(VARCHAR,ISNULL(Total_Dedu_Amount,0)) +  
 '#Gross Salary ProRata :' + CONVERT(VARCHAR,ISNULL(Actually_Gross_Salary,0)) +  
 '#Settlement Amount :' + CONVERT(VARCHAR,ISNULL(Settelement_Amount,0)) +  
 '#Net Round Diff Amount :' + CONVERT(VARCHAR,ISNULL(Net_Salary_Round_Diff_Amount,0)) +  
 '#Net Amount :' + CONVERT(VARCHAR,ISNULL(Net_Amount,0)) +  
 '#Status :' + CONVERT(VARCHAR,ISNULL(Salary_Status,0))  
 FROM #tbltmp w INNER JOIN T0200_MONTHLY_SALARY ON Sal_Tran_ID = t_SalTranId AND Emp_ID = t_EmpId WHERE t_State = 0  
  
 MERGE T9999_Audit_Trail AS Target USING  
 (  
  SELECT ROW_NUMBER () OVER (ORDER BY TT.Audit_Trail_Id) as rno,  
  (SELECT MAX(T.Audit_Trail_Id) FROM T9999_Audit_Trail t WITH (NOLOCK)) as maxid ,  
  TT.Audit_Trail_Id,TT.Cmp_ID,Audit_Change_Type,Audit_Module_Name,Audit_Change_For,KeyGUID,t_EmpId,t_Value  
  FROM T9999_Audit_Trail TT WITH (NOLOCK) LEFT JOIN #tbltmp T ON TT.Cmp_ID = @Cmp_ID  
  and TT.Audit_Change_Type = 'D' AND TT.Audit_Module_Name = 'Salary Monthly/Manually'  
  and TT.Audit_Change_For = t_EmpId AND TT.KeyGUID = @KEYGUID AND @KEYGUID <> '0'  
  WHERE t_State = 0  
 ) AS Source ON Target.Cmp_ID = @Cmp_ID AND Target.Audit_Change_Type = 'D' AND Target.Audit_Module_Name = 'Salary Monthly/Manually'  
 and Target.Audit_Change_For = t_EmpId AND Target.KeyGUID = @KEYGUID AND @KEYGUID <> '0'  
 WHEN MATCHED THEN   
  UPDATE SET Audit_Modulle_Description += t_Value  
 WHEN NOT MATCHED THEN   
  INSERT  
  (  
   Audit_Trail_Id,Cmp_ID,Audit_Change_Type,Audit_Module_Name,Audit_Modulle_Description,Audit_Change_For,Audit_Change_By,Audit_Date,Audit_Ip,is_emp_id,KeyGUID  
  )  
  VALUES  
  (  
   maxid + rno, @Cmp_ID , 'D', 'Salary Monthly/Manually', t_Value, t_EmpId, @User_Id, getdate(), @IP_Address, 1, @KEYGUID  
  );  
  
 DELETE w FROM T0210_Monthly_Salary_Slip_Gradecount w INNER JOIN #tbltmp ON Sal_tran_Id = t_SalTranId AND Emp_id = t_EmpId WHERE t_State = 0  
 DELETE w FROM T0210_PAYSLIP_DATA w INNER JOIN #tbltmp ON SAL_TRAN_ID = t_SalTranId WHERE t_State = 0  
 DELETE w FROM T0210_MONTHLY_LOAN_PAYMENT w INNER JOIN #tbltmp ON SAL_TRAN_ID = t_SalTranId WHERE t_State = 0  
 DELETE w FROM T0140_CLAIM_TRANSACTION w INNER JOIN #tbltmp ON Emp_ID = t_EmpId WHERE Cmp_ID= @CMP_ID AND Claim_Return <> 0 AND For_Date = @to_date AND t_State = 0  
 DELETE w FROM T0210_MONTHLY_AD_DETAIL w INNER JOIN #tbltmp ON SAL_TRAN_ID = t_SalTranId AND EMP_ID = t_EmpId WHERE t_State = 0  
 DELETE w FROM T0210_MONTHLY_LEAVE_DETAIL w INNER JOIN #tbltmp ON SAL_TRAN_ID = t_SalTranId AND EMP_ID = t_EmpId WHERE t_State = 0  
 DELETE w FROM T0210_LWP_Considered_Same_Salary_Cutoff w INNER JOIN #tbltmp ON SAL_TRAN_ID = t_SalTranId AND EMP_ID = t_EmpId WHERE t_State = 0  
   
 UPDATE w SET t_CurrentLeaveId = Leave_ID FROM #tbltmp w INNER JOIN T0160_late_Approval ON emp_id = t_EmpId  
 WHERE For_date = CASE WHEN t_CutOff_Date is NULL THEN t_SalEndDate ELSE t_CutOff_Date END  
  
 DELETE w FROM T0160_late_Approval w INNER JOIN #tbltmp ON emp_id = t_EmpId  
 and For_date = CASE WHEN t_CutOff_Date is NULL THEN t_SalEndDate else t_CutOff_Date END  
 WHERE t_State = 0 AND t_CurrentLeaveId = leave_id  
  
 DELETE w FROM T0200_MONTHLY_SALARY w INNER JOIN #tbltmp ON SAL_TRAN_ID = t_SalTranId AND EMP_ID = t_EmpId WHERE t_State = 0  
 DELETE w FROM t0100_Anual_bonus w INNER JOIN #tbltmp ON SAL_TRAN_ID = t_SalTranId AND EMP_ID = t_EmpId WHERE t_State = 0  
 DELETE w FROM T0210_MONTHLY_AD_DETAIL w INNER JOIN #tbltmp ON isNULL(SAL_TRAN_ID,0) = 0 AND EMP_ID = t_EmpId WHERE t_State = 0  
 DELETE w FROM MONTHLY_EMP_BANK_PAYMENT w INNER JOIN #tbltmp ON EMP_ID = t_EmpId AND FOR_DATE = t_SalEndDate  
 and (Process_Type ='Salary' or isNULL(Ad_id,0)> 0) WHERE t_State = 0  
   
 DELETE w FROM T0200_MONTHLY_SALARY_LEAVE w INNER JOIN #tbltmp ON sal_tran_ID = t_SalTranId AND EMP_ID = t_EmpId WHERE t_State = 0  
 DELETE w FROM T0210_Monthly_Reim_Detail w INNER JOIN #tbltmp ON sal_tran_ID = t_SalTranId AND EMP_ID = t_EmpId WHERE t_State = 0  
 DELETE w FROM t0200_salary_leave_Encashment w INNER JOIN #tbltmp ON Sal_tran_Id = t_SalTranId AND emp_id= t_EmpId WHERE t_State = 0  
 DELETE w FROM T0100_LEAVE_CF_DETAIL w INNER JOIN #tbltmp ON CF_FOR_DATE BETWEEN @FROM_DATE AND @TO_DATE AND EMP_ID = t_EmpId  
 AND UPPER(CF_TYPE) = 'AUTO_COPH' WHERE t_State = 0  
  
 UPDATE #tbltmp SET t_For_Date = DATEADD(d,1, t_SalEndDate)  
  
 DELETE w FROM T0100_ADVANCE_PAYMENT w INNER JOIN #tbltmp ON Emp_ID = t_EmpId AND Cmp_ID = @CMP_ID AND For_Date = t_For_Date WHERE t_State = 0  
 DELETE w FROM T0140_Asset_Transaction w INNER JOIN #tbltmp ON Emp_ID = t_EmpId AND Cmp_ID = @CMP_ID AND For_Date = t_SalEndDate  
 and sal_tran_ID = t_SalTranId WHERE t_State = 0  
  
 MERGE T0140_Asset_Transaction AS Target USING  
 (  
  select ATT.Cmp_ID,ATT.AssetM_Id,ATT.Asset_Approval_ID,t_EmpId,apd.Installment_Amount  
  FROM T0140_Asset_Transaction ATT WITH (NOLOCK)  
  INNER JOIN #tbltmp ON Emp_ID = t_EmpId AND Cmp_ID = @CMP_ID  
  INNER JOIN T0120_Asset_Approval AP WITH (NOLOCK) ON AP.Emp_ID = t_EmpId AND AP.Cmp_ID = @cmp_id  
  INNER JOIN T0130_Asset_Approval_Det APD WITH (NOLOCK) ON ap.Asset_Approval_ID = apd.Asset_Approval_ID AND ap.cmp_id=apd.cmp_id  
  WHERE AP.Emp_ID = t_EmpId AND AP.Cmp_ID = @cmp_id AND APD.AssetM_Id = ATT.AssetM_Id AND ap.Asset_Approval_ID = ATT.Asset_Approval_ID  
  and t_State = 0 AND for_date > t_SalEndDate  
 ) AS Source ON Target.Cmp_ID = @Cmp_ID AND Target.Emp_ID = t_EmpId  
 WHEN MATCHED THEN   
  UPDATE SET Asset_Opening = Asset_Opening + Installment_Amount,Asset_closing = Asset_closing + Installment_Amount;  
  
 DELETE w FROM T0210_Uniform_Monthly_Payment w INNER JOIN #tbltmp ON SAL_TRAN_ID = t_SalTranId WHERE t_State = 0  
 DELETE w FROM T0140_MONTHLY_LATEMARK_TRANSACTION w INNER JOIN #tbltmp ON SAL_TRAN_ID = t_SalTranId WHERE t_State = 0  
 DELETE w FROM T0140_MONTHLY_LATEMARK_DESIGNATION w INNER JOIN #tbltmp ON SAL_TRAN_ID = t_SalTranId WHERE t_State = 0  
 DELETE w FROM T0160_Late_Early_Validation w INNER JOIN #tbltmp ON SAL_TRAN_ID = t_SalTranId WHERE t_State = 0  
 DELETE w FROM T0140_MONTHLY_EARLYMARK_TRANSACTION w INNER JOIN #tbltmp ON SAL_TRAN_ID = t_SalTranId WHERE t_State = 0  
  
 DELETE MBP FROM T0210_MONTHLY_BOND_PAYMENT MBP  
 INNER JOIN T0120_BOND_APPROVAL BA ON BA.BOND_APR_ID = MBP.BOND_APR_ID  
 INNER JOIN #tbltmp ON MBP.SAL_TRAN_ID = t_SalTranId AND BA.EMP_ID = t_EmpId AND BA.CMP_ID = @CMP_ID  
 WHERE t_State = 0  
  
 UPDATE w SET t_BOND_RETURN_MONTH = BOND_RETURN_MONTH,t_BOND_RETURN_YEAR = BOND_RETURN_YEAR  
 FROM #tbltmp w INNER JOIN T0120_BOND_APPROVAL BA ON BA.Emp_Id = t_EmpId  
 WHERE BA.Cmp_Id = @CMP_ID AND BOND_RETURN_MODE = 'S' AND ISNULL(BOND_APR_PENDING_AMOUNT,0) = 0 AND  
 ISNULL(BOND_RETURN_STATUS,'Yes') = 'Yes'  
  
 UPDATE B SET BOND_RETURN_STATUS = 'No',BOND_RETURN_DATE = NULL  
 FROM T0120_BOND_APPROVAL B  
 INNER JOIN #tbltmp ON CMP_ID = @CMP_ID AND EMP_ID = t_EmpId AND BOND_RETURN_MODE = 'S' AND ISNULL(BOND_APR_PENDING_AMOUNT,0) = 0 AND  
 MONTH(@TO_DATE) >= t_BOND_RETURN_MONTH AND YEAR(@TO_DATE) >= t_BOND_RETURN_YEAR WHERE t_State = 0  
  
 UPDATE w SET t_Leave_Approval_ID = LA.Leave_Approval_ID FROM #tbltmp w INNER JOIN T0120_LEAVE_APPROVAL LA ON t_EmpId = Emp_ID  
 INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD ON LA.Leave_Approval_ID = LAD.Leave_Approval_ID  
 WHERE La.Emp_ID = t_EmpId AND La.Cmp_ID = @CMP_ID AND La.Is_Auto_Leave_FROM_Salary = 1 AND LAD.FROM_date >= t_SalDate AND LAD.To_Date <= t_SalEndDate  
  
 MERGE T0130_LEAVE_APPROVAL_DETAIL AS Target USING  
 (  
  select Leave_Approval_ID,t_Leave_Approval_ID  
  FROM T0130_LEAVE_APPROVAL_DETAIL WITH (NOLOCK)  
  INNER JOIN #tbltmp ON Leave_Approval_ID = t_Leave_Approval_ID AND Cmp_ID = @CMP_ID      
 ) AS Source ON Target.Cmp_ID = @Cmp_ID AND Target.Leave_Approval_ID = t_Leave_Approval_ID  
 WHEN MATCHED THEN   
  DELETE;  
  
 MERGE T0120_LEAVE_APPROVAL AS Target USING  
 (  
  select Leave_Approval_ID,t_Leave_Approval_ID  
  FROM T0120_LEAVE_APPROVAL WITH (NOLOCK)  
  INNER JOIN #tbltmp ON Leave_Approval_ID = t_Leave_Approval_ID AND Cmp_ID = @CMP_ID      
 ) AS Source ON Target.Cmp_ID = @Cmp_ID AND Target.Leave_Approval_ID = t_Leave_Approval_ID  
 WHEN MATCHED THEN   
  DELETE;  
  
 select t_EmpId,t_EmpName,t_RaisedError,t_Severity,t_State FROM #tbltmp WHERE t_State > 0   
end