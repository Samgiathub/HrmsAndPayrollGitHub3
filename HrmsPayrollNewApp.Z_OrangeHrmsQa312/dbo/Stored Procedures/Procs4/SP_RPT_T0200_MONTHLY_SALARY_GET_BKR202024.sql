
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_T0200_MONTHLY_SALARY_GET_BKR202024]            
 @Cmp_ID   numeric            
 ,@From_Date  datetime            
 ,@To_Date   datetime            
 ,@Branch_ID  numeric            
 ,@Cat_ID   numeric             
 ,@Grd_ID   numeric            
 ,@Type_ID   numeric            
 ,@Dept_ID   numeric            
 ,@Desig_ID   numeric            
 ,@Emp_ID   numeric            
 ,@constraint  varchar(MAX)            
 ,@Sal_Type  numeric = 0        
 ,@Salary_Cycle_id numeric = 0      
 ,@Segment_Id  numeric = 0   -- Added By Gadriwala Muslim 24072013      
 ,@Vertical_Id numeric = 0   -- Added By Gadriwala Muslim 24072013      
 ,@SubVertical_Id numeric = 0  -- Added By Gadriwala Muslim 24072013      
 ,@SubBranch_Id numeric = 0   -- Added By Gadriwala Muslim 01082013       
 ,@Status varchar(20) = '' --Added by Nimesh 19 May 2015 (To Filter Salary by Status)  
 ,@Bank_ID varchar(20) = '' --Added by ronakk 20082022
 ,@Payment_mode varchar(20) = '' --Added by ronakk 20082022
  ,@Salary_Status  varchar(100) = '' --Added by ronakk 20102022
AS            
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
          
          
        
 IF @Branch_ID = 0              
  set @Branch_ID = null            
        
 IF @Cat_ID = 0              
  set @Cat_ID = null            
         
 IF @Grd_ID = 0              
  set @Grd_ID = null            
         
 IF @Type_ID = 0              
  set @Type_ID = null            
         
 IF @Dept_ID = 0              
  set @Dept_ID = null            
         
 IF @Desig_ID = 0              
  set @Desig_ID = null            
         
 IF @Emp_ID = 0              
  set @Emp_ID = null            
        
  if @Segment_Id = 0       
  set @Segment_Id = null      
  IF @Vertical_Id= 0       
  set @Vertical_Id = null      
  if @SubVertical_Id = 0       
  set @SubVertical_Id= Null      
 If @SubBranch_Id = 0  -- Added By Gadriwala Muslim 01082013      
 set @SubBranch_Id = null       
      
      
--Hardik 03/06/2013 for With Arear Report for Golcha Group      
Declare @With_Arear_Amount tinyint      
      
Set @With_Arear_Amount = 1  
      
--Hardik 03/06/2013 for With Arear Report for Golcha Group   
If @Sal_Type = 3       
 Begin      
  Set @With_Arear_Amount = 1      
  Set @Sal_Type = 0      
 End      
       
 Declare @Month_St_Date datetime      
 declare @Month_End_Date datetime      
      
 set @Month_St_Date = @From_Date     
 set @Month_End_Date = @To_Date      
     
 declare @OutOf_Days numeric(18,2)      
 set @OutOf_Days = datediff(d,@From_Date,@To_date) + 1      
  
--//**Added By Ramiz on 10/08/2015 for displaying and Hiding Leave Table from Admin Setting  
Declare @Display_leave_table tinyint    
Set @Display_leave_table = 0      
  
select @Display_leave_table =   isnull(Setting_Value,0) from T0040_SETTING WITH (NOLOCK) where Cmp_ID = @cmp_id and Group_By = 'Reports' and Setting_Name = 'Include Leave Details in Salary Slip'  
--//**Ended By Ramiz on 10/08/2015 for displaying and Hiding Leave Table from Admin Setting  
  
  
CREATE table #Emp_Cons   
 (        
   Emp_ID numeric ,       
  Branch_ID numeric,  
  Increment_ID numeric      
 )        
  
 EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,@Sal_Type ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id   
   
   
 --Added by Nimesh 19 May 2015  
 --Filtering Employee Record according to Salary Status  
 IF (@Status = 'Hold' OR @Status = 'Done')   
 BEGIN  
  DELETE FROM #Emp_Cons   
  WHERE Emp_ID NOT IN (   
        SELECT Emp_ID FROM T0200_MONTHLY_SALARY S  WITH (NOLOCK) 
        WHERE Month(S.Month_End_Date)=Month(@To_Date)   
          AND Year(S.Month_End_Date)=Year(@To_Date)   
          AND S.Cmp_ID=@Cmp_ID   
          AND S.Salary_Status=@Status  
          )  
 END        
    
    
  
 Declare @Sal_St_Date   Datetime          
 Declare @Sal_end_Date   Datetime        
 declare @manual_salary_Period as numeric(18,0)    
    
 --------------------- Changed By Ali 13122013 Start ---------------------------------------    
 set @manual_salary_Period = 0    
 declare @is_salary_cycle_emp_wise as tinyint     
 set @is_salary_cycle_emp_wise = 0      
 select @is_salary_cycle_emp_wise = isnull(Setting_Value,0) from T0040_SETTING WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Setting_Name = 'Salary Cycle Employee Wise'      
     
 IF @is_salary_cycle_emp_wise = 1 and exists(Select 1 from T0095_Emp_Salary_Cycle ES WITH (NOLOCK) INNER JOIN #Emp_Cons EC ON ES.Emp_id=EC.Emp_ID where Cmp_id=@Cmp_ID)  
  BEGIN          
   IF ISNULL(@Salary_Cycle_id,0) = 0  
    BEGIN  
     SET @Salary_Cycle_id  = 0           
     SELECT @Salary_Cycle_id = salDate_id from T0095_Emp_Salary_Cycle WITH (NOLOCK) where  emp_id in (SELECT Emp_id from #Emp_Cons) AND effective_date in      
       (SELECT max(effective_date) as effective_date from T0095_Emp_Salary_Cycle  WITH (NOLOCK)     
     WHERE emp_id in (SELECT Emp_id from #Emp_Cons) AND effective_date <=  @Month_End_Date      
          GROUP by emp_id)            
       
    END  
   SELECT @Sal_St_Date = SALARY_ST_DATE FROM t0040_salary_cycle_master WITH (NOLOCK) where tran_id = @Salary_Cycle_id        
  END    
   ELSE    
  BEGIN    
   If @Branch_ID is null      
    Begin     
     select Top 1 @Sal_St_Date  = Sal_st_Date ,@manual_salary_Period= isnull(manual_salary_Period ,0) -- Comment and added By rohit on 11022013      
     from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID          
       and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@Month_End_Date and Cmp_ID = @Cmp_ID)                     
    End      
   Else      
    Begin      
     select @Sal_St_Date  = Sal_st_Date ,@manual_salary_Period= isnull(manual_salary_Period ,0) -- Comment and added By rohit on 11022013      
     from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID          
       and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@Month_End_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)               
    End         
  END    
     
	declare @max_effct_date datetime,@TTo_Date datetime
	select @max_effct_date = Max(Increment_Effective_Date),@TTo_Date = @To_Date from T0095_INCREMENT I
	inner join #Emp_Cons EC on I.Emp_ID = EC.Emp_ID
	where EC.Emp_ID = @Emp_ID and Increment_Effective_Date <= @To_Date
   
  
 if isnull(@Sal_St_Date,'') = ''          
  begin           
   set @From_Date  = @Month_St_Date           
   set @To_Date = @Month_End_Date          
   set @OutOf_Days = @OutOf_Days        
  end           
 else if day(@Sal_St_Date) =1 --and month(@Sal_St_Date)=1          
  begin    
   set @From_Date  = @Month_St_Date           
   set @To_Date = @Month_End_Date          
   set @OutOf_Days = @OutOf_Days       
  end           
 else  if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1  And Day(@From_Date) = 1       
  begin               
   if @manual_salary_Period = 0       
    Begin         
     set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@Month_St_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@Month_St_Date) )as varchar(10)) as smalldatetime)          
     set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))       
     set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1      
     Set @From_Date = @Sal_St_Date      
     Set @To_Date = @Sal_End_Date       
    end      
   else      
    begin         
     select @Sal_St_Date=from_date,@Sal_End_Date=end_date from salary_period where month= month(@From_Date) and YEAR=year(@From_Date)                    
     Set @From_Date = @Sal_St_Date      
     Set @To_Date = @Sal_End_Date          
     set @OutOf_Days = datediff(d,@Sal_St_Date,@Sal_End_Date) + 1         
    End       
  End       
 --------------------- Changed By Ali 13122013 End ---------------------------------------    
  
 if day(@From_Date) <> 1  
  begin  
  if @To_Date < @max_effct_date
			begin
				set @To_Date = @TTo_Date
			end	

   UPDATE EC  
   SET  Increment_ID=I.Increment_ID,  
     Branch_ID=I.Branch_ID  
   FROM #Emp_Cons EC  
     INNER JOIN T0095_INCREMENT I ON EC.Emp_ID=I.EMP_ID  
     INNER JOIN (SELECT I1.Emp_ID, Max(I1.Increment_ID) As Increment_ID  
        FROM T0095_INCREMENT I1  WITH (NOLOCK)
          INNER JOIN (SELECT I2.Emp_ID, Max(I2.Increment_Effective_Date) Increment_Effective_Date  
             FROM T0095_INCREMENT I2  WITH (NOLOCK)
               INNER JOIN #Emp_Cons EC1 ON I2.Emp_ID=EC1.Emp_ID  
             WHERE I2.Increment_Effective_Date <= @To_Date  
             GROUP BY I2.Emp_ID) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_Effective_Date=I2.Increment_Effective_Date  
        GROUP BY I1.Emp_ID) I1 ON I.Emp_ID=I1.Emp_ID AND I.Increment_ID=I1.Increment_ID  
  end  
   
   
       
  Create TABLE #Emp_Salary   
  (            
   Sal_Tran_ID   numeric(18, 0) ,            
   S_Sal_Tran_ID  numeric(18, 0) ,            
   L_Sal_Tran_ID  numeric(18, 0) ,            
   Sal_Receipt_No   numeric(18, 0) ,            
   Emp_ID    numeric(18, 0) ,            
   Cmp_ID    numeric(18, 0) ,            
   Increment_ID   numeric(18, 0) ,            
   Month_St_Date   datetime ,     
   Month_End_Date   datetime ,            
   Sal_Generate_Date  datetime ,            
   Sal_Cal_Days   numeric(18, 2) ,            
   Present_Days   numeric(18, 2) ,            
   Absent_Days   numeric(18, 2) ,            
   Holiday_Days   numeric(18, 2) ,            
   Weekoff_Days   numeric(18, 2) ,            
   Cancel_Holiday   numeric(18, 2) ,            
   Cancel_Weekoff   numeric(18, 2) ,            
   Working_Days   numeric(18, 2) ,            
   Outof_Days   numeric(18, 2)  ,            
   Total_Leave_Days  numeric(18, 2) ,            
   Paid_Leave_Days  numeric(18, 2) ,            
   Actual_Working_Hours  varchar (20) ,            
   Working_Hours   varchar (20) ,            
   Outof_Hours   varchar (20) ,            
   OT_Hours   numeric(18, 2)  ,            
   Total_Hours   varchar (20) ,            
   Shift_Day_Sec   numeric(18, 0) ,            
   Shift_Day_Hour   varchar (20) ,            
   Basic_Salary   numeric(18, 2) ,            
   Day_Salary   numeric(18, 5)  ,            
   Hour_Salary   numeric(18, 5) ,            
   Salary_Amount   numeric(18, 2) ,            
   Allow_Amount   numeric(18, 2) ,            
   OT_Amount   numeric(18, 2)  ,            
   Other_Allow_Amount  numeric(18, 2) ,            
   Gross_Salary   numeric(18, 2) ,            
   Dedu_Amount   numeric(18, 2) ,            
   Loan_Amount   numeric(18, 2) ,         
   Loan_Intrest_Amount  numeric(18, 2) ,            
   Advance_Amount   numeric(18, 2) ,            
   Other_Dedu_Amount  numeric(18, 2) ,            
   Total_Dedu_Amount  numeric(18, 2) ,            
   Due_Loan_Amount  numeric(18, 2) ,            
   Net_Amount   numeric(18, 2) ,            
   Actually_Gross_Salary  numeric(18, 2) ,            
   PT_Amount   numeric(18, 0) ,            
   PT_Calculated_Amount  numeric(18, 0) ,            
   Total_Claim_Amount  numeric(18, 3) ,            
   M_OT_Hours   numeric(18, 1) ,            
   M_Adv_Amount   numeric(18, 0) ,            
   M_Loan_Amount   numeric(18, 0) ,            
   M_IT_Tax   numeric(18, 0) ,            
   LWF_Amount   numeric(18, 0) ,            
   Revenue_Amount   numeric(18, 0) ,            
   PT_F_T_Limit   varchar (20),          
   Late_Days  numeric(18,2),  
   Net_Salary_Round_Diff_Amount numeric(18,2), -- Added By Ali    
   Comments varchar(max),  
   GatePass_Deduct_Days numeric(18,2)default 0 -- Added by Gadriwala Muslim 18032015  
  )     
  /*--------Added by Sumit on 06022017----------------------------------------*/  
  if OBJECT_ID('tempdb..#TMPUNPAIDLEAVE') IS NULL  
 Begin  
    CREATE TABLE #TMPUNPAIDLEAVE  
    (  
   EMP_ID NUMERIC(18,0),   
   CMP_ID NUMERIC(18,0),  
   UNPAID_LEAVE NUMERIC(18,2)  
     
    )  
 End        
    
 INSERT INTO #TMPUNPAIDLEAVE   
  SELECT ML.Emp_ID,@Cmp_ID,isnull(sum(leave_Days),0) from T0210_Monthly_LEave_Detail ML WITH (NOLOCK) INNER JOIN  
  #Emp_Cons ec ON ML.Emp_ID=EC.Emp_ID  
  where Leave_Paid_Unpaid = 'U' and Leave_Type <> 'Company Purpose'  
  and Cmp_Id=@Cmp_ID AND For_Date>=@From_Date AND For_Date<=@To_Date  
  GROUP BY ML.Emp_ID  
    
/*--------Ended by Sumit on 06022017----------------------------------------*/    
    
    
    
 --Added by Nimesh 2015-07-31 (For Customized Field)     
  Declare @VendarCodeID Numeric  
 SELECT @VendarCodeID = Tran_ID FROM T0081_CUSTOMIZED_COLUMN WITH (NOLOCK) Where Column_Name LIKE '%Vendor%' AND Cmp_Id=@Cmp_ID  
   
--SELECT top 1 Value FROM T0082_Emp_Column EC   
--wHERE EC.Emp_Id=10515 AND EC.mst_Tran_Id =@VendarCodeID  
  
   
 if @Sal_Type = 0     
   begin        
  
   
      
   INSERT INTO #Emp_Salary            
      (Sal_Tran_ID, Sal_Receipt_No, Emp_ID, Cmp_ID, Increment_ID, Month_St_Date, Month_End_Date, Sal_Generate_Date, Sal_Cal_Days, Present_Days,             
      Absent_Days, Holiday_Days, Weekoff_Days, Cancel_Holiday, Cancel_Weekoff, Working_Days, Outof_Days, Total_Leave_Days, Paid_Leave_Days,             
      Actual_Working_Hours, Working_Hours, Outof_Hours, OT_Hours, Total_Hours, Shift_Day_Sec, Shift_Day_Hour, Basic_Salary, Day_Salary,             
      Hour_Salary, Salary_Amount, Allow_Amount, OT_Amount, Other_Allow_Amount, Gross_Salary, Dedu_Amount, Loan_Amount, Loan_Intrest_Amount,             
      Advance_Amount, Other_Dedu_Amount, Total_Dedu_Amount, Due_Loan_Amount, Net_Amount, Actually_Gross_Salary, PT_Amount,             
      PT_Calculated_Amount, Total_Claim_Amount, M_OT_Hours, M_Adv_Amount, M_Loan_Amount, M_IT_Tax, LWF_Amount, Revenue_Amount,             
      PT_F_T_Limit,Late_Days,Net_Salary_Round_Diff_Amount,GatePass_Deduct_Days)      -- Added by Gadriwala Muslim 18032015       
           
   select Sal_Tran_ID, Sal_Receipt_No, ms.Emp_ID, ms.Cmp_ID, ms.Increment_ID, Month_St_Date, Month_End_Date, Sal_Generate_Date, Sal_Cal_Days, Present_Days,           
      Absent_Days, Holiday_Days, Weekoff_Days, Cancel_Holiday, Cancel_Weekoff, Working_Days, Outof_Days, Total_Leave_Days, Paid_Leave_Days,           
      Actual_Working_Hours, Working_Hours, Outof_Hours, OT_Hours, Total_Hours, Shift_Day_Sec, Shift_Day_Hour, ms.Basic_Salary, Day_Salary,           
      Hour_Salary, Salary_Amount, Allow_Amount, OT_Amount, Other_Allow_Amount, ms.Gross_Salary, Dedu_Amount, Loan_Amount, Loan_Intrest_Amount,           
      Advance_Amount, Other_Dedu_Amount, Total_Dedu_Amount, Due_Loan_Amount, Net_Amount, Q.AD_AMOUNT + isnull(i.Basic_Salary,0), PT_Amount,           
      PT_Calculated_Amount, Total_Claim_Amount, M_OT_Hours, M_Adv_Amount, M_Loan_Amount, M_IT_Tax, LWF_Amount, Revenue_Amount,           
      PT_F_T_Limit  ,isnull(Late_Days,0),Net_Salary_Round_Diff_Amount,GatePass_Deduct_Days   -- Added by Gadriwala Muslim 18032015   
    From T0200_MONTHLY_SALARY ms WITH (NOLOCK) inner join #Emp_Cons ec on ms.emp_ID =ec.emp_ID
			Left join (
							SELECT	Emp_Id,INCREMENT_ID,IsNull(SUM(E_AD_AMOUNT),0) AS AD_AMOUNT 
							 FROM	T0100_EMP_EARN_DEDUCTION MAD WITH (NOLOCK)
									INNER JOIN T0050_AD_Master AD WITH (NOLOCK) ON MAD.AD_ID=AD.AD_ID 
							 WHERE	AD_FLAG = 'I' and AD_ACtive = 1 and AD_NOT_EFFECT_Salary <> 1		
							 GROUP BY Emp_id,INCREMENT_ID
						) Q On Ms.Emp_ID = Q.Emp_ID AND ms.Increment_ID = Q.Increment_ID
			left Join T0095_INCREMENT I WITH (NOLOCK) on ms.Emp_ID = I.Emp_ID and ms.Increment_ID = i.Increment_ID
    Where ms.Cmp_ID = @Cmp_Id           
     And isnull(is_FNF,0)=0   
     and month(ms.Month_End_Date) = Month(@To_Date)  and Year(ms.Month_End_Date) =Year(@To_Date)  

   If @With_Arear_Amount = 1      
    Begin      
     Declare @S_Gross_Salary as Numeric(18,2)      
     Declare @S_Total_Deduction as Numeric(18,2)      
     Declare @S_Net_Amount as Numeric(18,2)      
     Declare @S_Emp_Id as Numeric      
           
     Set @S_Gross_Salary = 0      
     Set @S_Total_Deduction = 0      
     Set @S_Net_Amount = 0      
      
     declare Cur_Payslip   cursor for      
      Select Emp_ID From #Emp_Salary Group By Emp_ID      
     open Cur_Payslip      
     fetch next from Cur_Payslip  into @S_Emp_Id      
     while @@fetch_status = 0      
      begin      
      
       Set @S_Gross_Salary = 0      
       Set @S_Total_Deduction = 0      
       Set @S_Net_Amount = 0      
            
       declare Cur_Allow   cursor for      
        select  SUM(S_Gross_Salary), SUM(S_Total_Dedu_Amount),SUM(S_Net_Amount)              
         From T0201_MONTHLY_SALARY_SETT ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID       
         and Month(S_Eff_Date) = Month(@to_Date) and Year(S_Eff_Date) = Year(@To_Date) And Ms.Emp_ID = @S_Emp_Id      
         And MS.Emp_ID In       
         (select  ms.Emp_ID      
         From T0200_Monthly_Salary  ms WITH (NOLOCK)  
         WHERE Ms.Emp_ID = @S_Emp_Id              
         and month(Month_End_Date) = Month(@To_Date)  and Year(Month_End_Date) =Year(@To_Date))  
		 and Effect_On_Salary > 0
         Group by ms.Emp_ID,MS.Cmp_ID,S_Eff_Date      
       open cur_allow      
       fetch next from cur_allow  into @S_Gross_Salary,@S_Total_Deduction,@S_Net_Amount      
       while @@fetch_status = 0      
        begin      
      
               
         Update #Emp_Salary Set Gross_Salary = Gross_Salary + Isnull(@S_Gross_Salary,0) - Isnull(@S_Net_Amount,0)      
         Where Emp_ID = @S_Emp_Id And Cmp_ID = @Cmp_ID      
               
         If @S_Total_Deduction > 0      
          Begin      
           Update #Emp_Salary Set Total_Dedu_Amount = Total_Dedu_Amount + ISNULL(@S_Total_Deduction,0)      
           Where Emp_ID = @S_Emp_Id And Cmp_ID = @Cmp_ID      
          End      
      
         fetch next from cur_allow  into @S_Gross_Salary,@S_Total_Deduction,@S_Net_Amount      
        end      
       close cur_Allow      
       deallocate Cur_Allow      
      
       fetch next from Cur_Payslip  into @S_Emp_Id      
      end      
     close Cur_Payslip      
     deallocate Cur_Payslip      
    End      
             
      
         
   end            
 else if @Sal_Type = 1             
   begin    
             
   INSERT INTO #Emp_Salary            
   (S_Sal_Tran_ID, Sal_Receipt_No, Emp_ID, Cmp_ID, Increment_ID, Month_St_Date, Month_End_Date, Sal_Generate_Date, Sal_Cal_Days, Present_Days,             
   Absent_Days, Holiday_Days, Weekoff_Days, Cancel_Holiday, Cancel_Weekoff, Working_Days, Outof_Days, Total_Leave_Days, Paid_Leave_Days,             
   Actual_Working_Hours, Working_Hours, Outof_Hours, OT_Hours, Total_Hours, Shift_Day_Sec, Shift_Day_Hour, Basic_Salary, Day_Salary,             
   Hour_Salary, Salary_Amount, Allow_Amount, OT_Amount, Other_Allow_Amount, Gross_Salary, Dedu_Amount, Loan_Amount, Loan_Intrest_Amount,             
   Advance_Amount, Other_Dedu_Amount, Total_Dedu_Amount, Due_Loan_Amount, Net_Amount, Actually_Gross_Salary, PT_Amount,             
   PT_Calculated_Amount, Total_Claim_Amount, M_OT_Hours, M_Adv_Amount, M_Loan_Amount, M_IT_Tax, LWF_Amount, Revenue_Amount,             
   PT_F_T_Limit,Net_Salary_Round_Diff_Amount)            
      
    --changed by jimit 05042017   
     select S_Sal_Tran_ID, S_Sal_Receipt_No, ms.Emp_ID, ms.Cmp_ID, ms.Increment_ID, S_Month_St_Date, S_Month_End_Date, S_Sal_Generate_Date, S_Sal_Cal_Days, MS1.Present_Days,             
   MS1.Absent_Days, MS1.Holiday_Days, MS1.Weekoff_Days, MS1.Cancel_Holiday, MS1.Cancel_Weekoff, MS1.Working_Days, MS1.Outof_Days, MS1.Total_Leave_Days,MS1.Paid_Leave_Days,             
   MS1.Actual_Working_Hours, MS1.Working_Hours, MS1.Outof_Hours, MS1.OT_Hours, MS1.Total_Hours, S_Shift_Day_Sec, S_Shift_Day_Hour, S_Basic_Salary, S_Day_Salary,             
   S_Hour_Salary, S_Salary_Amount, S_Allow_Amount, S_OT_Amount, S_Other_Allow_Amount, S_Gross_Salary, S_Dedu_Amount, S_Loan_Amount, S_Loan_Intrest_Amount,             
   S_Advance_Amount, S_Other_Dedu_Amount, S_Total_Dedu_Amount, S_Due_Loan_Amount, S_Net_Amount, S_Actually_Gross_Salary, S_PT_Amount,             
   S_PT_Calculated_Amount, S_Total_Claim_Amount, S_M_OT_Hours, S_M_Adv_Amount, S_M_Loan_Amount, S_M_IT_Tax, S_LWF_Amount, S_Revenue_Amount,             
   S_PT_F_T_Limit ,0           
             
    From T0201_MONTHLY_SALARY_Sett ms WITH (NOLOCK) inner join #Emp_Cons ec on ms.emp_ID =ec.emp_ID   Left Outer JOIN  
    T0200_MONTHLY_SALARY MS1 WITH (NOLOCK) On Ms1.Emp_ID =  ms.Emp_ID and ms1.Sal_Tran_ID = ms.Sal_Tran_ID        
    Where ms.Cmp_ID = @Cmp_Id             
    and month(S_Month_End_Date) = Month(@To_Date)  and Year(S_Month_End_Date) =Year(@To_Date)  
   --ended  
     
     
      
   --select S_Sal_Tran_ID, S_Sal_Receipt_No, ms.Emp_ID, Cmp_ID, ms.Increment_ID, S_Month_St_Date, S_Month_End_Date, S_Sal_Generate_Date, S_Sal_Cal_Days, S_M_Present_Days,             
   --0, 0, 0, 0, 0, s_Working_Days, s_Outof_Days, 0,0,             
   --'', '', '', 0, '', S_Shift_Day_Sec, S_Shift_Day_Hour, S_Basic_Salary, S_Day_Salary,             
   --S_Hour_Salary, S_Salary_Amount, S_Allow_Amount, S_OT_Amount, S_Other_Allow_Amount, S_Gross_Salary, S_Dedu_Amount, S_Loan_Amount, S_Loan_Intrest_Amount,             
   --S_Advance_Amount, S_Other_Dedu_Amount, S_Total_Dedu_Amount, S_Due_Loan_Amount, S_Net_Amount, S_Actually_Gross_Salary, S_PT_Amount,             
   --S_PT_Calculated_Amount, S_Total_Claim_Amount, S_M_OT_Hours, S_M_Adv_Amount, S_M_Loan_Amount, S_M_IT_Tax, S_LWF_Amount, S_Revenue_Amount,             
   --S_PT_F_T_Limit ,0           
             
    --From T0201_MONTHLY_SALARY_Sett ms inner join #Emp_Cons ec on ms.emp_ID =ec.emp_ID             
    --Where ms.Cmp_ID = @Cmp_Id             
    --and month(S_Month_End_Date) = Month(@To_Date)  and Year(S_Month_End_Date) =Year(@To_Date)        
     --and S_Salary_Amount >0  commented by Falak on 08-APR-2011      
    -- and S_Month_St_Date >=@From_Date and S_Month_End_Date <=@To_Date      
    
   end            
 else if @Sal_Type = 2            
   begin            
 INSERT INTO #Emp_Salary            
    (l_Sal_Tran_ID, Sal_Receipt_No, Emp_ID, Cmp_ID, Increment_ID, Month_St_Date, Month_End_Date, Sal_Generate_Date, Sal_Cal_Days, Present_Days,             
    Absent_Days, Holiday_Days, Weekoff_Days, Cancel_Holiday, Cancel_Weekoff, Working_Days, Outof_Days, Total_Leave_Days, Paid_Leave_Days,             
    Actual_Working_Hours, Working_Hours, Outof_Hours, OT_Hours, Total_Hours, Shift_Day_Sec, Shift_Day_Hour, Basic_Salary, Day_Salary,             
    Hour_Salary, Salary_Amount, Allow_Amount, OT_Amount, Other_Allow_Amount, Gross_Salary, Dedu_Amount, Loan_Amount, Loan_Intrest_Amount,             
    Advance_Amount, Other_Dedu_Amount, Total_Dedu_Amount, Due_Loan_Amount, Net_Amount, Actually_Gross_Salary, PT_Amount,             
    PT_Calculated_Amount, Total_Claim_Amount, M_OT_Hours, M_Adv_Amount, M_Loan_Amount, M_IT_Tax, LWF_Amount, Revenue_Amount,             
    PT_F_T_Limit)            
         
 select L_Sal_Tran_ID, l_Sal_Receipt_No, ms.Emp_ID, Cmp_ID, ms.Increment_ID, l_Month_St_Date, l_Month_End_Date, L_Sal_Generate_Date, l_Sal_Cal_Days, 0,             
    0, 0, 0, 0, 0, L_Working_Days, l_Outof_Days, 0, 0,             
    '', '', '', 0, '', l_Shift_Day_Sec, l_Shift_Day_Hour, l_Basic_Salary, l_Day_Salary,             
    l_Hour_Salary, l_Salary_Amount, l_Allow_Amount, 0, l_Other_Allow_Amount, L_Gross_Salary, L_Dedu_Amount, L_Loan_Amount, L_Loan_Intrest_Amount,             
    L_Advance_Amount, L_Other_Dedu_Amount, L_Total_Dedu_Amount, L_Due_Loan_Amount, L_Net_Amount, L_Actually_Gross_Salary, L_PT_Amount,             
    l_PT_Calculated_Amount, 0, 0, l_M_Adv_Amount, l_M_Loan_Amount, l_M_IT_Tax, l_LWF_Amount, l_Revenue_Amount,             
    l_PT_F_T_Limit            
           
  From T0200_MONTHLY_SALARY_Leave ms WITH (NOLOCK) inner join #Emp_Cons ec on ms.emp_ID =ec.emp_ID             
  Where ms.Cmp_ID = @Cmp_Id            
   and month(L_Month_End_Date) = Month(@To_Date)  and Year(L_Month_End_Date) =Year(@To_Date)    
  --and L_Salary_Amount >0   commented by Falak on 08-APR-2011      
  -- and L_Month_St_Date >=@From_Date and L_Month_End_Date <=@To_Date            
   end            
 else             
   begin      
      
 INSERT INTO #Emp_Salary            
    (Sal_Tran_ID, Sal_Receipt_No, Emp_ID, Cmp_ID, Increment_ID, Month_St_Date, Month_End_Date, Sal_Generate_Date, Sal_Cal_Days, Present_Days,             
    Absent_Days, Holiday_Days, Weekoff_Days, Cancel_Holiday, Cancel_Weekoff, Working_Days, Outof_Days, Total_Leave_Days, Paid_Leave_Days,             
    Actual_Working_Hours, Working_Hours, Outof_Hours, OT_Hours, Total_Hours, Shift_Day_Sec, Shift_Day_Hour, Basic_Salary, Day_Salary,             
    Hour_Salary, Salary_Amount, Allow_Amount, OT_Amount, Other_Allow_Amount, Gross_Salary, Dedu_Amount, Loan_Amount, Loan_Intrest_Amount,             
    Advance_Amount, Other_Dedu_Amount, Total_Dedu_Amount, Due_Loan_Amount, Net_Amount, Actually_Gross_Salary, PT_Amount,             
    PT_Calculated_Amount, Total_Claim_Amount, M_OT_Hours, M_Adv_Amount, M_Loan_Amount, M_IT_Tax, LWF_Amount, Revenue_Amount,             
    PT_F_T_Limit)            
         
 Select null, null, Emp_ID, @Cmp_ID, null, @From_Date, @To_Date, null, 0, 0,             
    0, 0, 0, 0, 0, 0, 0, 0, 0,'', '', '', 0, '', 0, '', 0, 0,0, 0, 0, 0, 0, 0, 0,0, 0,             
    0, 0, 0, 0, 0, 0, 0,0, 0, 0, 0, 0, 0, 0, 0, ''            
 From #Emp_Cons ec             
      
          
 Update #Emp_Salary            
 set Sal_Tran_ID = ms.Sal_Tran_ID,             
  Sal_Receipt_No = ms.Sal_Receipt_No,             
  Increment_ID = ms.Increment_ID,             
  Sal_Generate_Date = ms.Sal_Generate_Date,             
  Sal_Cal_Days = ms.Sal_Cal_Days,             
  Present_Days = ms.Present_Days,             
  Absent_Days = ms.Absent_Days,             
  Holiday_Days = ms.Holiday_Days,             
  Weekoff_Days = ms.Weekoff_Days,             
  Cancel_Holiday = ms.Cancel_Holiday,            
  Cancel_Weekoff = ms.Cancel_Weekoff,             
  Working_Days = ms.Working_Days,             
  Outof_Days = ms.Outof_Days,             
  Total_Leave_Days = ms.Total_Leave_Days,             
  Paid_Leave_Days = ms.Paid_Leave_Days,             
  Actual_Working_Hours = ms.Actual_Working_Hours,             
  Working_Hours = ms.Working_Hours,             
  Outof_Hours = ms.Outof_Hours,             
  OT_Hours = ms.OT_Hours,             
  Total_Hours = ms.Total_Hours,             
  Shift_Day_Sec = ms.Shift_Day_Sec,             
  Shift_Day_Hour = ms.Shift_Day_Hour,             
  Basic_Salary = ms.Basic_Salary,             
  Day_Salary = ms.Day_Salary,             
  Hour_Salary = ms.Hour_Salary,             
  Salary_Amount = ms.Salary_Amount,             
  Allow_Amount = ms.Allow_Amount,             
  OT_Amount = ms.OT_Amount, Other_Allow_Amount = ms.Other_Allow_Amount,             
  Gross_Salary = ms.Gross_Salary, Dedu_Amount = ms.Dedu_Amount,             
  Loan_Amount = ms.Loan_Amount, Loan_Intrest_Amount = ms.Loan_Intrest_Amount, Advance_Amount = ms.Advance_Amount,             
  Other_Dedu_Amount = ms.Other_Dedu_Amount, Total_Dedu_Amount = ms.Total_Dedu_Amount, Due_Loan_Amount = ms.Due_Loan_Amount,             
  Net_Amount = ms.Net_Amount, Actually_Gross_Salary = ms.Actually_Gross_Salary,             
  PT_Amount = ms.PT_Amount, PT_Calculated_Amount = ms.PT_Calculated_Amount, Total_Claim_Amount = ms.Total_Claim_Amount,             
  M_OT_Hours = ms.M_OT_Hours, M_Adv_Amount = ms.M_Adv_Amount, M_Loan_Amount = ms.M_Loan_Amount, M_IT_Tax = ms.M_IT_Tax, LWF_Amount = ms.LWF_Amount,             
  Revenue_Amount = ms.Revenue_Amount,          
  PT_F_T_Limit = ms.PT_F_T_Limit  ,          
  Late_Days=ms.Late_Days,          
  gatepass_Deduct_days = ms.gatePass_Deduct_Days   -- Added by Gadriwala Muslim 18032015  
 From #Emp_Salary es Inner join T0200_MONTHLY_SALARY ms on es.emp_ID =ms.emp_ID             
  Where ms.Cmp_ID = @Cmp_Id      
   and month(ms.Month_End_Date) = Month(@To_Date)  and Year(ms.Month_End_Date) =Year(@To_Date)             
   --and ms.Salary_Amount >0    commented by Falak on 08-APR-2011        
  -- and ms.Month_St_Date >=@From_Date and ms.Month_End_Date <=@To_Date           
     
          
          
 Update #Emp_Salary            
 set S_Sal_Tran_ID = ms.S_Sal_Tran_ID,             
  Increment_ID = ms.Increment_ID,             
  Sal_Cal_Days = Sal_Cal_Days + ms.S_M_Present_Days,             
  Present_Days = Present_Days + ms.S_M_Present_Days,             
  Shift_Day_Sec = ms.S_Shift_Day_Sec,             
  Shift_Day_Hour = ms.S_Shift_Day_Hour,             
  Basic_Salary = Basic_Salary + ms.S_Basic_Salary,             
  Day_Salary = Day_Salary + ms.S_Day_Salary,             
  Hour_Salary = Hour_Salary + S_Hour_Salary,             
  Salary_Amount = Salary_Amount + S_Salary_Amount,             
  Allow_Amount = Allow_Amount + S_Allow_Amount,             
  OT_Amount = OT_Amount + s_OT_Amount, Other_Allow_Amount = Other_Allow_Amount + S_Other_Allow_Amount,             
  Gross_Salary = Gross_Salary + S_Gross_Salary, Dedu_Amount = Dedu_Amount + S_Dedu_Amount,             
  Loan_Amount = Loan_Amount + S_Loan_Amount, Loan_Intrest_Amount = Loan_Intrest_Amount + S_Loan_Intrest_Amount, Advance_Amount = Advance_Amount + S_Advance_Amount,             
  Other_Dedu_Amount = Other_Dedu_Amount + s_Other_Dedu_Amount, Total_Dedu_Amount = Total_Dedu_Amount  + S_Total_Dedu_Amount, Due_Loan_Amount = S_Due_Loan_Amount,             
  Net_Amount = Net_Amount + S_Net_Amount, Actually_Gross_Salary = Actually_Gross_Salary + S_Actually_Gross_Salary,             
  PT_Amount = PT_Amount + S_PT_Amount, PT_Calculated_Amount = PT_Calculated_Amount + S_PT_Calculated_Amount              
  , LWF_Amount = LWF_Amount + S_LWF_Amount, Revenue_Amount = Revenue_Amount + s_Revenue_Amount, PT_F_T_Limit = S_PT_F_T_Limit            
 From #Emp_Salary es Inner join T0201_MONTHLY_SALARY_SETT ms on es.emp_ID =ms.emp_ID             
  Where ms.Cmp_ID = @Cmp_Id             
   and month(S_Month_End_Date) = Month(@To_Date)  and Year(S_Month_End_Date) =Year(@To_Date)             
 --  and S_Month_St_Date >=@From_Date and S_Month_End_Date <=@To_Date            
         
          
 Update #Emp_Salary            
 set L_Sal_Tran_ID = ms.L_Sal_Tran_ID,             
  Sal_Cal_Days = Sal_Cal_Days + L_Sal_Cal_Days,             
  Basic_Salary = Basic_Salary + L_Basic_Salary,             
  Day_Salary = Day_Salary + L_Day_Salary,             
  Hour_Salary = Hour_Salary + L_Hour_Salary,             
  Salary_Amount = Salary_Amount + L_Salary_Amount,             
  Allow_Amount = Allow_Amount + L_Allow_Amount,             
  Other_Allow_Amount = Other_Allow_Amount + L_Other_Allow_Amount,             
  Gross_Salary = Gross_Salary + L_Gross_Salary, Dedu_Amount = Dedu_Amount + L_Dedu_Amount,             
  Loan_Amount = Loan_Amount + L_Loan_Amount, Loan_Intrest_Amount = Loan_Intrest_Amount + L_Loan_Intrest_Amount, Advance_Amount = Advance_Amount + L_Advance_Amount,             
  Other_Dedu_Amount = Other_Dedu_Amount + L_Other_Dedu_Amount, Total_Dedu_Amount = Total_Dedu_Amount  + L_Total_Dedu_Amount, Due_Loan_Amount = L_Due_Loan_Amount,    
  Net_Amount = Net_Amount + L_Net_Amount, Actually_Gross_Salary = Actually_Gross_Salary + L_Actually_Gross_Salary,             
  PT_Amount = PT_Amount + L_PT_Amount, PT_Calculated_Amount = PT_Calculated_Amount + L_PT_Calculated_Amount              
  , LWF_Amount = LWF_Amount + L_LWF_Amount, Revenue_Amount = Revenue_Amount + L_Revenue_Amount, PT_F_T_Limit = L_PT_F_T_Limit            
 From #Emp_Salary es Inner join T0200_MONTHLY_SALARY_LEAVE ms on es.emp_ID =ms.emp_ID             
  Where ms.Cmp_ID = @Cmp_Id       
  and month(L_Month_End_Date) = Month(@To_Date)  and Year(L_Month_End_Date) =Year(@To_Date)    
 --  and L_Month_St_Date >=@From_Date and L_Month_End_Date <=@To_Date            
         
          
   end            
    
	
   update t1  
   set t1.Comments = t2.comments  
   from #Emp_Salary t1 left outer join (select * from t0250_salary_publish_ess  WITH (NOLOCK)
    where cmp_id = @Cmp_ID and month = month(@to_date) and [year]=year(@to_date) and Sal_Type='Salary') t2  
    on t1.Emp_id = t2.Emp_ID  --Added By Mukti Sal_Type(30062016)   
        
        
 --Select MS.*,MSMA.total_Earning_fraction,Father_name,Emp_full_Name,BM.Branch_Address,BM.branch_name,BM.Comp_name,Grd_Name,Month(Ms.Month_St_Date)as Month,YEar(Ms.Month_St_Date)as Year ,      
 --BM.Branch_NAme,BM.Comp_Name            
 --,EMP_CODE,Type_Name,Dept_Name,Desig_Name,Inc_Bank_Ac_no,PAN_no,DAte_of_Birth,Date_of_Join,            
 --SSN_No as PF_No,SIN_No as ESIC_No ,dbo.F_Number_TO_Word(Ms.Net_Amount) as Net_Amount_In_Word            
 --,Bank_Name ,CMP_NAME,CMP_ADDRESS, cm.Image_name Cmp_Image_Name , isnull(CM.Image_file_Path,'')as Image_file_Path ,    --added by falak on 24-mar-2011       
 --BM.Branch_Code,DATE_OF_JOIN,I_Q.Inc_Bank_Ac_no,      
 --EBM.Branch_NAme,      
 --dbo.F_Get_Age(E.Date_OF_Birth,getdate(),'Y','Y') as Emp_Age_In_Words,      
 --dbo.F_Get_Age(E.Date_OF_Join,getdate(),'Y','Y') as Emp_Exp_In_Words,      
 --isnull(EPF.PF_Amount,0)as PF_Amount      
 --,isnull((select emps.Emp_Full_Name from T0080_EMP_MASTER empS where emps.Emp_ID = E.Emp_Superior),'-') as Report_To,      
 --CT.Cat_Name, Payment_Mode,Alpha_Emp_Code,isnull(MSMA.Early_Days,0) as Early_Days,isnull(MSMA.Late_Early_Penalty_days,0) as Late_Early_Penalty_days,CM.PF_No as Com_PF_No  --- CM.PF_NO added by Mihir 03122011      
 --, isnull((select Emp_Cheque_No from MONTHLY_EMP_BANK_PAYMENT MEBP where MEBP.Emp_ID = msma.Emp_ID and mebp.For_Date = msma.Month_End_Date),'-' ) as Emp_Cheque_No      
 --, isnull((select Payment_Date from MONTHLY_EMP_BANK_PAYMENT MEBP where MEBP.Emp_ID = msma.Emp_ID and mebp.For_Date = msma.Month_End_Date ),NUll) as Payment_Date      
 --FROM  #Emp_Salary Ms  inner join T0080_Emp_Master E on MS.Emp_ID =E.Emp_ID      
 --Inner Join T0200_MONTHLY_SALARY MSMA On MSMA.Emp_ID = E.Emp_ID    
 --INNER JOIN (SELECT I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Inc_Bank_Ac_no,Bank_ID,Payment_Mode from T0095_Increment I inner join       
 --    (select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment      
 --    where Increment_Effective_date <= @To_Date      
 --    and Cmp_ID = @Cmp_ID      
 --    group by emp_ID  ) Qry on      
 --    I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date  ) I_Q       
 --   on E.Emp_ID = I_Q.Emp_ID LEFT OUTER JOIN   
 --   ( select Emp_Id,isnull(sum(M_Ad_Amount),0) as PF_Amount from T0210_Monthly_AD_Detail where cmp_id = @cmp_id and      
 --    for_date <= @To_Date and AD_ID in (select AD_ID from T0050_AD_Master where cmp_id = @cmp_id and AD_DEF_ID = 2       
 --    and AD_Flag = 'D' and AD_ACtive = 1 and AD_NOT_EFFECT_Salary <> 1)           
 --    group by Emp_id) EPF on E.Emp_Id = EPF.Emp_id Left outer join      
 --    T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID    Left outer  JOIN            
 --    T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID    Left outer   JOIN            
 --    T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id  LEFT OUTER JOIN         
 --    T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id LEFT OUTER JOIN          
 --    T0030_Branch_Master BM on I_Q.Branch_ID = BM.Branch_ID LEFT OUTER JOIN   
 --    T0030_Branch_Master EBM on E.Branch_ID = EBM.Branch_ID LEFT OUTER JOIN   
 --    T0040_Bank_master bk on i_Q.Bank_ID = Bk.Bank_ID  LEFT OUTER JOIN          
 -- T0010_COMPANY_MASTER CM ON MS.CMP_ID = CM.CMP_ID  LEFT OUTER JOIN   
 -- T0030_CATEGORY_MASTER CT ON I_Q.Cat_ID = CT.Cat_ID        
        
        
 -- WHERE E.Cmp_ID = @Cmp_Id             
 --  --and Salary_Amount >0  commented by Falak on 08-APR-2011          
 --  --and Ms.Month_St_Date >=@From_Date and Ms.Month_End_Date <=@To_Date               
 --  and MSMA.Month_St_Date >=@From_Date and MSMA.Month_End_Date <=@To_Date        
 -- ORDER BY RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500)                  
        
   
  DECLARE @Hide_Allowance_Rate_PaySlip AS TINYINT --Ankit 08052015  
  SET @Hide_Allowance_Rate_PaySlip = 0  
    
  SELECT @Hide_Allowance_Rate_PaySlip = ISNULL(Setting_Value,0)   
  FROM T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Setting_Name LIKE 'Hide Allowance Rate in Salary Slip'  
  

 IF @Sal_Type = 0      
 BEGIN 
  print 2224 ---mansi
 SET @From_Date = @From_Date-DAY(@From_Date)+1
  SELECT MS.*,MSMA.total_Earning_fraction,Father_name,ISNULL(EmpName_Alias_Salary,E.Emp_Full_Name) as Emp_full_Name,BM.Branch_Address
  ,BM.branch_name,BM.Comp_name,Grd_Name
  ,Month(Ms.Month_St_Date)as Month,YEar(Ms.Month_St_Date)as Year  
    ,BM.Branch_NAme,BM.Comp_Name,EMP_CODE,Type_Name,Dept_Name,Desig_Name,Inc_Bank_Ac_no,PAN_no,DAte_of_Birth,Date_of_Join  
    ,SSN_No as PF_No,SIN_No as ESIC_No ,dbo.F_Number_TO_Word(Ms.Net_Amount) as Net_Amount_In_Word            
    ,Bank_Name ,CM.CMP_NAME,CMP_ADDRESS, cm.Image_name Cmp_Image_Name , isnull(CM.Image_file_Path,'')as Image_file_Path    --added by falak on 24-mar-2011       
    ,BM.Branch_Code,DATE_OF_JOIN,I_Q.Inc_Bank_Ac_no      
    ,EBM.Branch_NAme as Emp_Branch_Name
	,dbo.F_Get_Age(E.Date_OF_Birth,getdate(),'Y','Y') as Emp_Age  --added by mansi 
	,isnull(FLOOR(dbo.F_Get_Age(E.Date_OF_Birth,getdate(),'Y','Y')),0) as Emp_Age_In_Words
	,MSMA.M_WO_OT_Hours, MSMA.M_HO_OT_Hours  
    ,dbo.F_Get_Age(E.Date_OF_Join,MSMA.Month_End_Date,'Y','Y') as Emp_Exp_In_Words   -- Set Salary End date for Experience Count      
    ,isnull(EPF.PF_Amount,0)as PF_Amount      
    ,isnull((select emps.Emp_Full_Name from T0080_EMP_MASTER empS WITH (NOLOCK) where emps.Emp_ID = E.Emp_Superior),'-') as Report_To  
    ,CT.Cat_Name, Payment_Mode,E.Alpha_Emp_Code,MSMA.Early_Days,MSMA.Late_Early_Penalty_days  
	,MSMA.Late_Days_Arear_Cutoff,MSMA.Early_Days_Arear_Cutoff -- added by tejas at 18092024 for 
    , CASE WHEN ISNULL(BM.PF_No,'') = '' THEN CM.PF_No ELSE BM.PF_No END as Com_PF_No --MODIFIED BY RAMIZ ON 27/06/2018  
    ,tms.Arear_Basic +isnull(tms.basic_salary_arear_cutoff,0) as Arear_Basic  
	, tms.Arear_Day + ISNULL(tms.Arear_Day_Previous_month ,0)as Arear_Day   
	, tms.Arear_Gross + ISNULL(tms.Gross_Salary_Arear_cutoff,0) as Arear_Gross   
	, tmpia.Extra_Day_Month,tmpia.Backdated_Leave_Days      
    , isnull((select Emp_Cheque_No from MONTHLY_EMP_BANK_PAYMENT MEBP WITH (NOLOCK) where MEBP.Emp_ID = msma.Emp_ID and mebp.For_Date = msma.Month_End_Date and process_type='Salary'),'-' ) as Emp_Cheque_No      
    , isnull((select Payment_Date from MONTHLY_EMP_BANK_PAYMENT MEBP WITH (NOLOCK) where MEBP.Emp_ID = msma.Emp_ID and mebp.For_Date = msma.Month_End_Date  and process_type='Salary'),NUll) as Payment_Date      
    ,MSMA.OD_leave_days,CM.Cmp_logo,BM.Branch_ID,Is_Contractor_Company,BM.Is_Contractor_Branch,E.UAN_No,I_Q.CTC,@Hide_Allowance_Rate_PaySlip AS Hide_Allowance_Rate_PaySlip  
    ,E.Emp_First_Name    --added jimit 29052015  
    ,Cast(1 As BigInt) As ROW_NO --Added by Nimesh 19-Jun-2015 (For Format 8 Potrait)  
    ,EC.Value As VendorCode --Added by Nimesh 31-Jul-2015 (Value taken from Customized Field Table)  
    ,Isnull(Qry4.Pay_Scale_Detail,0) as Pay_Scale_Detail  
    ,@Display_leave_table as Display_Leave  --Added By Ramiz on 10/08/2015  
    ,DGM.Desig_Dis_No          --added jimit 24082015  
    ,isnull(msg.Actual_day_Count,0) as Actual_day_Count , isnull(msg.Actual_night_count,0) as Actual_night_count , isnull(msg.Upgrade_day_count,0) as Upgrade_day_count , isnull(msg.Upgrade_night_count,0) as Upgrade_night_count  
    ,ISNULL(msg.Day_Basic_salary,0) as Day_Basic_salary , ISNULL(msg.Night_Basic_salary,0) as Night_Basic_salary,ISNULL(msg.Day_Basic_DA,0) as Day_Basic_DA , ISNULL(msg.Night_Basic_DA,0) as Night_Basic_DA ,  ISNULL(msg.CL_Leave,0) as CL_Leave   
    ,ISNULL(msg.Avg_Sal,0) as AVG_Sal, ISNULL(msg.Grd_OT_Hours,0) as Grd_OT_Hours  
    ,isnull(MSMA.Present_On_Holiday,0) as Present_On_Holiday  
    ,ISNULL(MS.Present_Days,0) - ISNULL(Leave_Adj_L_Mark,0) AS P_Days_Adj_Leave ,ISNULL(Leave_Adj_L_Mark,0) AS Leave_Adj_L_Mark --AIA - Ankit 02062016  
    ,TCM.Curr_Symbol ,TCM.Curr_Name   
    ,ISNULL(UL.UNPAID_LEAVE,0) AS UNPAID_LEAVE  
    ,E.Aadhar_Card_No  --added by jimit 27042017  
    ,E.Old_Ref_No -- Added by Rajput on 01122017  
    ,VS.Vertical_Name,SV.SubVertical_Name , E.Enroll_No ---Added By Jimit 13072018  
    , E.DBRD_Code  
    ,CM.Cmp_Email --added by Krushna 19122019  
    ,CM.Cmp_Phone --added by Krushna 19122019  
    ,contractor.Contr_PersonName Contractor_Name --Added by deepak 11082020  
    ,contractor.Nature_Of_Work --Added by deepak 11082020  
	,Present_State 
	,E.Despencery -- Added by Sajid 24/02/2021 for IFSCA Client
	,convert(decimal(18,2),(select sum(M_AD_Percentage) from T0210_MONTHLY_AD_DETAIL MAD where AD_ID = 3 and For_Date between @From_Date and @To_Date and MAD.Emp_ID = E.Emp_ID)) as DA_Rate
  FROM #Emp_Salary Ms    
    INNER JOIN T0080_Emp_Master E WITH (NOLOCK) on MS.Emp_ID =E.Emp_ID      
    INNER JOIN T0200_MONTHLY_SALARY MSMA WITH (NOLOCK) On MSMA.Sal_Tran_ID = MS.Sal_Tran_ID      
    INNER JOIN (SELECT I.Emp_Id ,I.Increment_ID, Grd_ID,I.Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Inc_Bank_Ac_no,  
         Bank_ID,Payment_Mode,CTC,I.Vertical_ID,I.SubVertical_ID  
       FROM T0095_Increment I  WITH (NOLOCK)
         INNER JOIN #Emp_Cons EC1 ON I.Increment_ID=EC1.Increment_ID      
       ) I_Q ON E.Emp_ID = I_Q.Emp_ID   
    LEFT OUTER JOIN (SELECT Emp_Id,IsNull(SUM(M_Ad_Amount),0) AS PF_Amount   
         FROM T0210_Monthly_AD_Detail MAD WITH (NOLOCK) 
          INNER JOIN T0050_AD_Master AD WITH (NOLOCK) ON MAD.AD_ID=AD.AD_ID AND AD.AD_DEF_ID=2  
         WHERE MAD.cmp_id = @cmp_id AND For_Date <= @To_Date            
               AND AD_FLAG = 'D' and AD_ACtive = 1 and AD_NOT_EFFECT_Salary <> 1    
         GROUP BY Emp_id) EPF on E.Emp_Id = EPF.Emp_id   
    LEFT OUTER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID  
    LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID  
    LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id      
    LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id   
    LEFT OUTER JOIN T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID   
    LEFT OUTER JOIN T0030_Branch_Master EBM WITH (NOLOCK) on E.Branch_ID = EBM.Branch_ID   
    LEFT OUTER JOIN V0030_Branch_Master contractor on contractor.Branch_ID = I_Q.Branch_ID -- Added by deepak to get contractor 11082020 Add the Replace the Contractor table to View 04/01/2020 Bug ID 12862
    LEFT OUTER JOIN T0040_Bank_master bk WITH (NOLOCK) on i_Q.Bank_ID = Bk.Bank_ID   
    LEFT OUTER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON MS.CMP_ID = CM.CMP_ID   
    LEFT OUTER JOIN T0030_CATEGORY_MASTER CT WITH (NOLOCK) ON I_Q.Cat_ID = CT.Cat_ID   
    LEFT OUTER JOIN T0200_MONTHLY_SALARY tms WITH (NOLOCK) on tms.Sal_Tran_ID = Ms.Sal_Tran_ID   
    LEFT OUTER JOIN (SELECT PSM.Emp_ID,PSM.Pay_Scale_Detail   
         FROM V0050_EMP_PAY_SCALE_DETAIL PSM   
          INNER JOIN (SELECT Emp_ID,MAX(Effective_Date) as Effective_Date   
        From V0050_EMP_PAY_SCALE_DETAIL   
             WHERE Effective_Date <= @To_Date    
             GROUP BY Emp_ID) AS Qry3 ON Qry3.Emp_ID = PSM.Emp_ID AND Qry3.Effective_Date = PSM.Effective_Date  
        ) AS Qry4 ON Qry4.Emp_ID = Ms.Emp_ID   
    LEFT OUTER JOIN T0190_MONTHLY_PRESENT_IMPORT TMPIA WITH (NOLOCK) ON tmpia.Emp_ID = Ms.Emp_ID 
	and tmpia.Month = MONTH(@To_Date) and tmpia.Year = YEAR(@To_Date)      
    LEFT OUTER JOIN T0082_Emp_Column EC WITH (NOLOCK) ON E.Emp_ID=EC.Emp_Id And EC.cmp_Id=E.Cmp_ID AND EC.mst_Tran_Id=@VendarCodeID  
    LEFT OUTER JOIN T0210_Monthly_Salary_Slip_Gradecount MSG WITH (NOLOCK) on MSG.Sal_tran_id = MS.Sal_Tran_ID        
    LEFT OUTER JOIN T0040_CURRENCY_MASTER TCM WITH (NOLOCK) on E.Curr_ID = TCM.Curr_ID            
    LEFT OUTER JOIN (SELECT LT.Emp_ID,SUM(LT.Leave_Adj_L_Mark) AS Leave_Adj_L_Mark  
         FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)  
          INNER JOIN #Emp_Salary EES ON LT.Emp_ID = EES.Emp_ID   
         WHERE MOnth(LT.For_Date) = MONTH(@To_Date) AND YEAR(LT.For_Date) = YEAR(@To_Date)  
         GROUP BY LT.Emp_ID) Q_Adj_L ON Q_Adj_L.Emp_ID = MS.Emp_ID  
    LEFT OUTER JOIN #TMPUNPAIDLEAVE UL ON MS.Emp_ID=UL.EMP_ID AND MS.Cmp_ID=UL.CMP_ID  
    LEFT OUTER JOIN T0040_Vertical_Segment VS WITH (NOLOCK) on vs.Vertical_ID = I_Q.Vertical_ID     
    LEFT OUTER JOIN T0050_SubVertical SV WITH (NOLOCK) On Sv.SubVertical_ID = I_Q.SubVertical_ID  
 END      
 else if @Sal_Type = 1      
  begin      
    
    Select MS.*, cast('0' as numeric) as total_Earning_fraction,Father_name,ISNULL(EmpName_Alias_Salary,Emp_Full_Name) as Emp_full_Name,BM.Branch_Address,BM.branch_name,BM.Comp_name,Grd_Name,Month(Ms.Month_St_Date)as Month,YEar(Ms.Month_St_Date)as Year , 
     
  BM.Branch_NAme,BM.Comp_Name            
  ,EMP_CODE,Type_Name,Dept_Name,Desig_Name,Inc_Bank_Ac_no,PAN_no,DAte_of_Birth,Date_of_Join,            
  SSN_No as PF_No,SIN_No as ESIC_No ,dbo.F_Number_TO_Word(Ms.Net_Amount) as Net_Amount_In_Word            
  ,Bank_Name ,CMP_NAME,CMP_ADDRESS, cm.Image_name Cmp_Image_Name , isnull(CM.Image_file_Path,'')as Image_file_Path ,    --added by falak on 24-mar-2011       
  isnull(Cm.cmp_logo,'') as Cmp_logo ,  -- Added by Mihir 06/03/2012      
  BM.Branch_Code,DATE_OF_JOIN,I_Q.Inc_Bank_Ac_no,      
  EBM.Branch_NAme,0 as Extra_Day_Month,0 as OD_leave_days,      
  isnull(dbo.F_Get_Age(E.Date_OF_Birth,getdate(),'Y','Y'),0) as Emp_Age_In_Words,      
  --dbo.F_Get_Age(E.Date_OF_Join,MSMA.S_Month_End_Date,'Y','Y') as Emp_Exp_In_Words, --Comment By Ankit For Twise Settlement --05122015     
  dbo.F_Get_Age(E.Date_OF_Join,MS.Month_End_Date,'Y','Y') as Emp_Exp_In_Words,      
  isnull(EPF.PF_Amount,0)as PF_Amount      
  ,isnull((select emps.Emp_Full_Name from T0080_EMP_MASTER empS WITH (NOLOCK) where emps.Emp_ID = E.Emp_Superior),'-') as Report_To,      
  CT.Cat_Name, Payment_Mode,Alpha_Emp_Code, cast('0' as numeric) as Early_Days, cast('0' as numeric) as Late_Early_Penalty_days,CM.PF_No as Com_PF_No,  
  0 as Arear_Basic , 0 as Arear_Day , 0 as Arear_Gross , 0 as Extra_Day_Month,0 as Backdated_Leave_Days      
  , '-'  as Emp_Cheque_No, Null as Payment_Date,0 as OD_leave_days,CM.Cmp_logo,  
  BM.Branch_ID  --- CM.PF_NO added by Mihir 03122011      
  ,Is_Contractor_Company,BM.Is_Contractor_Branch,E.UAN_No,I_Q.CTC,@Hide_Allowance_Rate_PaySlip AS Hide_Allowance_Rate_PaySlip  
  ,E.Emp_First_Name    --added jimit 29052015  
  ,Cast(1 As BigInt) As ROW_NO --Added by Nimesh 19-Jun-2015 (For Format 8 Potrait)  
  ,DGM.Desig_Dis_No          --added jimit 24082015  
  ,0 as Present_On_Holiday,ISNULL(UL.UNPAID_LEAVE,0) as UNPAID_LEAVE  
  ,'' as Pay_Scale_Detail 
  ,E.Despencery -- Added by Sajid 24/02/2021 for IFSCA Client
    FROM  #Emp_Salary Ms  inner join T0080_Emp_Master E WITH (NOLOCK) on MS.Emp_ID =E.Emp_ID      
  --Inner Join T0201_MONTHLY_SALARY_SETT MSMA On MSMA.Emp_ID = E.Emp_ID  --Comment By Ankit For Twise Settlement --05122015  
  INNER JOIN (SELECT I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Inc_Bank_Ac_no,Bank_ID,Payment_Mode,CTC from T0095_Increment I WITH (NOLOCK) inner join       
   (select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)     
   where Increment_Effective_date <= @To_Date      
   and Cmp_ID = @Cmp_ID      
   group by emp_ID  ) Qry on      
   I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q     
     on E.Emp_ID = I_Q.Emp_ID LEFT OUTER JOIN   
     ( select Emp_Id,isnull(sum(M_Ad_Amount),0) as PF_Amount from T0210_Monthly_AD_Detail WITH (NOLOCK) where cmp_id = @cmp_id and      
   for_date <= @To_Date and AD_ID in (select AD_ID from T0050_AD_Master WITH (NOLOCK) where cmp_id = @cmp_id and AD_DEF_ID = 2       
   and AD_Flag = 'D' and AD_ACtive = 1 and AD_NOT_EFFECT_Salary <> 1)           
   group by Emp_id) EPF on E.Emp_Id = EPF.Emp_id Left outer join      
   T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID    Left outer  JOIN            
   T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID    Left outer   JOIN            
   T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id  LEFT OUTER JOIN         
   T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id LEFT OUTER JOIN          
   T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID LEFT OUTER JOIN   
   T0030_Branch_Master EBM WITH (NOLOCK)on E.Branch_ID = EBM.Branch_ID LEFT OUTER JOIN   
   T0040_Bank_master bk WITH (NOLOCK) on i_Q.Bank_ID = Bk.Bank_ID  LEFT OUTER JOIN          
   T0010_COMPANY_MASTER CM WITH (NOLOCK) ON MS.CMP_ID = CM.CMP_ID  LEFT OUTER JOIN   
   T0030_CATEGORY_MASTER CT WITH (NOLOCK) ON I_Q.Cat_ID = CT.Cat_ID  
   LEFT JOIN #TMPUNPAIDLEAVE UL ON MS.Emp_ID=UL.EMP_ID AND MS.Cmp_ID=UL.CMP_ID   
           
           
     WHERE E.Cmp_ID = @Cmp_Id             
      --and Salary_Amount >0  commented by Falak on 08-APR-2011          
      --and Ms.Month_St_Date >=@From_Date and Ms.Month_End_Date <=@To_Date               
      ---and  Month(MSMA.S_Month_End_Date) = Month(@To_Date) and Year(MSMA.S_Month_End_Date) = Year(@To_Date) --Comment By Ankit For Twise Settlement --05122015     
      and  Month(Ms.Month_End_Date) = Month(@To_Date) and Year(MS.Month_End_Date) = Year(@To_Date)      
     ORDER BY RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500)                  
  end         
 else if @Sal_Type = 2      
  begin      
    Select MS.*, cast('0' as numeric) as total_Earning_fraction,Father_name,ISNULL(EmpName_Alias_Salary,Emp_Full_Name) as Emp_full_Name,BM.Branch_Address,BM.branch_name,BM.Comp_name,Grd_Name,Month(Ms.Month_St_Date)as Month,YEar(Ms.Month_St_Date)as Year , 
     
    BM.Branch_NAme,BM.Comp_Name            
    ,EMP_CODE,Type_Name,Dept_Name,Desig_Name,Inc_Bank_Ac_no,PAN_no,DAte_of_Birth,Date_of_Join,            
    SSN_No as PF_No,SIN_No as ESIC_No ,dbo.F_Number_TO_Word(Ms.Net_Amount) as Net_Amount_In_Word            
    ,Bank_Name ,CMP_NAME,CMP_ADDRESS, cm.Image_name Cmp_Image_Name , isnull(CM.Image_file_Path,'')as Image_file_Path ,    --added by falak on 24-mar-2011       
    isnull(Cm.cmp_logo,'') as Cmp_logo ,  -- Added by Mihir 06/03/2012      
    BM.Branch_Code,DATE_OF_JOIN,I_Q.Inc_Bank_Ac_no,      
    EBM.Branch_NAme,      
    isnull(dbo.F_Get_Age(E.Date_OF_Birth,getdate(),'Y','Y'),0) as Emp_Age_In_Words,      
    dbo.F_Get_Age(E.Date_OF_Join,MSMA.L_Month_End_Date,'Y','Y') as Emp_Exp_In_Words,      
    isnull(EPF.PF_Amount,0)as PF_Amount      
    ,isnull((select emps.Emp_Full_Name from T0080_EMP_MASTER empS WITH (NOLOCK) where emps.Emp_ID = E.Emp_Superior),'-') as Report_To,      
    CT.Cat_Name, Payment_Mode,Alpha_Emp_Code, cast('0' as numeric) as Early_Days, cast('0' as numeric) as Late_Early_Penalty_days,CM.PF_No as Com_PF_No,BM.Branch_ID  --- CM.PF_NO added by Mihir 03122011      
    ,Is_Contractor_Company,BM.Is_Contractor_Branch,E.UAN_No,I_Q.CTC ,@Hide_Allowance_Rate_PaySlip AS Hide_Allowance_Rate_PaySlip   
    ,E.Emp_First_Name    --added jimit 29052015  
    ,Cast(1 As BigInt) As ROW_NO --Added by Nimesh 19-Jun-2015 (For Format 8 Potrait)  
    ,DGM.Desig_Dis_No          --added jimit 24082015  
    ,ISNULL(UL.UNPAID_LEAVE,0) as UNPAID_LEAVE  
	,E.Despencery -- Added by Sajid 24/02/2021 for IFSCA Client
    FROM  #Emp_Salary Ms  inner join T0080_Emp_Master E WITH (NOLOCK) on MS.Emp_ID =E.Emp_ID      
    Inner Join T0200_MONTHLY_SALARY_LEAVE MSMA WITH (NOLOCK) On MSMA.Emp_ID = E.Emp_ID      
    INNER JOIN (SELECT I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Inc_Bank_Ac_no,Bank_ID,Payment_Mode,CTC from T0095_Increment I WITH (NOLOCK) inner join       
        (select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment  WITH (NOLOCK)    
        where Increment_Effective_date <= @To_Date      
        and Cmp_ID = @Cmp_ID      
        group by emp_ID  ) Qry on      
        I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q       
       on E.Emp_ID = I_Q.Emp_ID LEFT OUTER JOIN   
       ( select Emp_Id,isnull(sum(M_Ad_Amount),0) as PF_Amount from T0210_Monthly_AD_Detail WITH (NOLOCK) where cmp_id = @cmp_id and      
        for_date <= @To_Date and AD_ID in (select AD_ID from T0050_AD_Master WITH (NOLOCK) where cmp_id = @cmp_id and AD_DEF_ID = 2       
        and AD_Flag = 'D' and AD_ACtive = 1 and AD_NOT_EFFECT_Salary <> 1)           
        group by Emp_id) EPF on E.Emp_Id = EPF.Emp_id Left outer join      
     T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID    Left outer  JOIN            
     T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID    Left outer   JOIN            
     T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id  LEFT OUTER JOIN         
     T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id LEFT OUTER JOIN          
     T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID LEFT OUTER JOIN   
     T0030_Branch_Master EBM WITH (NOLOCK) on E.Branch_ID = EBM.Branch_ID LEFT OUTER JOIN   
     T0040_Bank_master bk WITH (NOLOCK) on i_Q.Bank_ID = Bk.Bank_ID  LEFT OUTER JOIN          
     T0010_COMPANY_MASTER CM WITH (NOLOCK) ON MS.CMP_ID = CM.CMP_ID  LEFT OUTER JOIN   
     T0030_CATEGORY_MASTER CT WITH (NOLOCK) ON I_Q.Cat_ID = CT.Cat_ID        
     LEFT JOIN #TMPUNPAIDLEAVE UL ON MS.Emp_ID=UL.EMP_ID AND MS.Cmp_ID=UL.CMP_ID   
           
           
     WHERE E.Cmp_ID = @Cmp_Id             
      --and Salary_Amount >0  commented by Falak on 08-APR-2011          
      --and Ms.Month_St_Date >=@From_Date and Ms.Month_End_Date <=@To_Date               
    --  and  MSMA.L_Month_St_Date >=@From_Date and MSMA.L_Month_End_Date <=@To_Date        
     and  Month(MSMA.L_Month_End_Date) = Month(@To_Date) and Year(MSMA.L_Month_End_Date) = Year(@To_Date)    
     ORDER BY RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500)                  
  end        
  else if @Sal_Type = 4 --Added by Nimesh (Salary Type 4 for Duplicate Copy)      
  begin      
    Select MS.*,MSMA.total_Earning_fraction,Father_name,ISNULL(EmpName_Alias_Salary,Emp_Full_Name) as Emp_full_Name,BM.Branch_Address,BM.branch_name,BM.Comp_name,Grd_Name,Month(Ms.Month_St_Date)as Month,YEar(Ms.Month_St_Date)as Year  
    ,EMP_CODE,Type_Name,Dept_Name,Desig_Name,PAN_no,DAte_of_Birth,            
    SSN_No as PF_No,SIN_No as ESIC_No ,dbo.F_Number_TO_Word(Ms.Net_Amount) as Net_Amount_In_Word            
    ,Bank_Name ,CMP_NAME,CMP_ADDRESS, cm.Image_name Cmp_Image_Name , isnull(CM.Image_file_Path,'')as Image_file_Path ,    --added by falak on 24-mar-2011       
    BM.Branch_Code,DATE_OF_JOIN,I_Q.Inc_Bank_Ac_no,      
    EBM.Branch_NAme as Emp_Branch_Name,      
    isnull(dbo.F_Get_Age(E.Date_OF_Birth,getdate(),'Y','Y'),0) as Emp_Age_In_Words,MSMA.M_WO_OT_Hours, MSMA.M_HO_OT_Hours ,        
    dbo.F_Get_Age(E.Date_OF_Join,MSMA.Month_End_Date,'Y','Y') as Emp_Exp_In_Words,   -- Set Salary End date for Experience Count      
     isnull(EPF.PF_Amount,0)as PF_Amount      
    ,isnull((select emps.Emp_Full_Name from T0080_EMP_MASTER empS WITH (NOLOCK) where emps.Emp_ID = E.Emp_Superior),'-') as Report_To,      
    CT.Cat_Name, Payment_Mode,Alpha_Emp_Code,MSMA.Early_Days,MSMA.Late_Early_Penalty_days,CM.PF_No as Com_PF_No  --- CM.PF_NO added by Mihir 03122011      
    ,tms.Arear_Basic +isnull(tms.basic_salary_arear_cutoff,0) as Arear_Basic  , tms.Arear_Day + ISNULL(tms.Arear_Day_Previous_month ,0)as Arear_Day   , tms.Arear_Gross + ISNULL(tms.Gross_Salary_Arear_cutoff,0) as Arear_Gross   , tmpia.Extra_Day_Month,tmpia.Backdated_Leave_Days      
    , isnull((select Emp_Cheque_No from MONTHLY_EMP_BANK_PAYMENT MEBP WITH (NOLOCK) where MEBP.Emp_ID = msma.Emp_ID and mebp.For_Date = msma.Month_End_Date and process_type='Salary'),'-' ) as Emp_Cheque_No      
    , isnull((select Payment_Date from MONTHLY_EMP_BANK_PAYMENT MEBP WITH (NOLOCK) where MEBP.Emp_ID = msma.Emp_ID and mebp.For_Date = msma.Month_End_Date  and process_type='Salary'),NUll) as Payment_Date      
    ,MSMA.OD_leave_days,CM.Cmp_logo,BM.Branch_ID,Is_Contractor_Company,BM.Is_Contractor_Branch,E.UAN_No,I_Q.CTC,@Hide_Allowance_Rate_PaySlip AS Hide_Allowance_Rate_PaySlip  
    ,E.Emp_First_Name    --added jimit 29052015  
   ,DGM.Desig_Dis_No          --added jimit 24082015     
   ,ISNULL(UL.UNPAID_LEAVE,0) as UNPAID_LEAVE  
     ,E.Despencery -- Added by Sajid 24/02/2021 for IFSCA Client
    INTO #tmpSalarySlip  
    FROM  #Emp_Salary Ms  inner join T0080_Emp_Master E WITH (NOLOCK) on MS.Emp_ID =E.Emp_ID      
    Inner Join T0200_MONTHLY_SALARY MSMA WITH (NOLOCK) On MSMA.Sal_Tran_ID = MS.Sal_Tran_ID      
    INNER JOIN                
 ----CHANGE BY NILAY ----------------------------------------------------------  
 ---WONDER ISSUES TO SHOW TRANSFER DESIGNATION AFTER SETTLEMENT.--------------  
 (SELECT I.Emp_Id ,I.Increment_ID, Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Inc_Bank_Ac_no,Bank_ID,Payment_Mode,CTC from T0095_Increment I WITH (NOLOCK) inner join          
       (SELECT CASE when q2.Emp_ID  IS not NULL then q2.Emp_ID ELSE q1.Emp_ID END as Emp_ID,  
      CASE when q2.Increment_ID  IS not NULL then q2.Increment_ID ELSE q1.Increment_ID END  as increment_ID      
   FROM (select I.Increment_ID, i.Emp_ID from T0095_Increment I  WITH (NOLOCK) inner join T0200_Monthly_salary MS WITH (NOLOCK) ON    
   I.Increment_ID = MS.Increment_ID   
   where month(Month_End_Date) = month(@To_Date) and Year(Month_End_Date) = Year(@To_Date)      
   and I.Cmp_ID = @Cmp_ID) as q1  
   left outer join  
   (select Emp_ID,max(Increment_ID) as Increment_ID   from T0095_Increment WITH (NOLOCK) where Increment_ID >=  
   (Select Increment_ID from T0200_Monthly_Salary WITH (NOLOCK) where month(Month_End_Date)=month(@To_Date) and Year(month_End_Date) = Year(@To_Date) and Emp_ID=T0095_INCREMENT.Emp_ID)   
    and Increment_Effective_Date <= @To_Date and Increment_Type='Transfer'  
   GROUP by Emp_ID) as q2   
   on q1.Emp_ID = q2.Emp_ID) I_Q  on I.Emp_ID = I_Q.Emp_ID and I.Increment_ID =I_Q.increment_ID ) I_Q          
       ---WONDER ISSUES TO SHOW TRANSFER DESIGNATION AFTER SETTLEMENT.--------------   
 ----CHANGE BY NILAY ----------------------------------------------------------         
       on E.Emp_ID = I_Q.Emp_ID LEFT OUTER JOIN   
       ( select Emp_Id,isnull(sum(M_Ad_Amount),0) as PF_Amount from T0210_Monthly_AD_Detail WITH (NOLOCK) where cmp_id = @cmp_id and      
        for_date <= @To_Date and AD_ID in (select AD_ID from T0050_AD_Master WITH (NOLOCK) where cmp_id = @cmp_id and AD_DEF_ID = 2       
        and AD_Flag = 'D' and AD_ACtive = 1 and AD_NOT_EFFECT_Salary <> 1)           
        group by Emp_id) EPF on E.Emp_Id = EPF.Emp_id Left outer join      
     T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID    Left outer  JOIN            
     T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID    Left outer   JOIN            
     T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id  LEFT OUTER JOIN         
     T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id LEFT OUTER JOIN          
     T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID LEFT OUTER JOIN   
     T0030_Branch_Master EBM WITH (NOLOCK) on E.Branch_ID = EBM.Branch_ID LEFT OUTER JOIN   
     T0040_Bank_master bk WITH (NOLOCK) on i_Q.Bank_ID = Bk.Bank_ID  LEFT OUTER JOIN          
     T0010_COMPANY_MASTER CM WITH (NOLOCK) ON MS.CMP_ID = CM.CMP_ID  LEFT OUTER JOIN   
     T0030_CATEGORY_MASTER CT WITH (NOLOCK) ON I_Q.Cat_ID = CT.Cat_ID    LEFT OUTER JOIN   
     T0200_MONTHLY_SALARY tms WITH (NOLOCK) on tms.Sal_Tran_ID = Ms.Sal_Tran_ID LEFT OUTER JOIN   
     T0190_MONTHLY_PRESENT_IMPORT tmpia WITH (NOLOCK) on tmpia.Emp_ID = Ms.Emp_ID and tmpia.Month = MONTH(@To_Date) and tmpia.Year = YEAR(@To_Date)      
     LEFT JOIN #TMPUNPAIDLEAVE UL ON MS.Emp_ID=UL.EMP_ID AND MS.Cmp_ID=UL.CMP_ID   
       
     Insert into #tmpSalarySlip SELECT * FROM #tmpSalarySlip;  
       
     SELECT ROW_NUMBER() OVER(PARTITION BY EMP_ID ORDER BY EMP_ID) ROW_NO, *   
     FROM #tmpSalarySlip  
     ORDER BY Emp_ID  
                        
  end       
 else       
  begin      
  Select MS.*, cast('0' as numeric) as total_Earning_fraction,Father_name,ISNULL(EmpName_Alias_Salary,Emp_Full_Name) as Emp_full_Name,  
    BM.Branch_Address,BM.branch_name,BM.Comp_name,Grd_Name,Month(Ms.Month_St_Date)as Month,YEar(Ms.Month_St_Date)as Year ,BM.Branch_NAme,  
    BM.Comp_Name,EMP_CODE,Type_Name,Dept_Name,Desig_Name,Inc_Bank_Ac_no,PAN_no,DAte_of_Birth,Date_of_Join,  
    SSN_No as PF_No,SIN_No as ESIC_No ,dbo.F_Number_TO_Word(Ms.Net_Amount) as Net_Amount_In_Word,  
    Bank_Name ,CMP_NAME,CMP_ADDRESS, cm.Image_name Cmp_Image_Name , isnull(CM.Image_file_Path,'')as Image_file_Path,  
    isnull(Cm.cmp_logo,'') as Cmp_logo,BM.Branch_Code,DATE_OF_JOIN,I_Q.Inc_Bank_Ac_no,EBM.Branch_NAme,  
    isnull(dbo.F_Get_Age(E.Date_OF_Birth,getdate(),'Y','Y'),0) as Emp_Age_In_Words,  
    dbo.F_Get_Age(E.Date_OF_Join,Ms.Month_End_Date,'Y','Y') as Emp_Exp_In_Words,isnull(EPF.PF_Amount,0)as PF_Amount,  
    isnull((select emps.Emp_Full_Name from T0080_EMP_MASTER empS WITH (NOLOCK) where emps.Emp_ID = E.Emp_Superior),'-') as Report_To,  
    CT.Cat_Name, Payment_Mode,Alpha_Emp_Code, cast('0' as numeric) as  Early_Days, cast('0' as numeric) as Late_Early_Penalty_days,  
    CM.PF_No as Com_PF_No,BM.Branch_ID,Is_Contractor_Company,BM.Is_Contractor_Branch,E.UAN_No,I_Q.CTC,  
    @Hide_Allowance_Rate_PaySlip AS Hide_Allowance_Rate_PaySlip,E.Emp_First_Name,DGM.Desig_Dis_No,ISNULL(UL.UNPAID_LEAVE,0) as UNPAID_LEAVE  
  FROM #Emp_Salary Ms    
    INNER JOIN T0080_Emp_Master E WITH (NOLOCK) on MS.Emp_ID =E.Emp_ID   
    INNER JOIN (SELECT I.Emp_Id , Grd_ID,I.Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Inc_Bank_Ac_no,Bank_ID,Payment_Mode,CTC   
       FROM T0095_Increment I  WITH (NOLOCK) 
         INNER JOIN #Emp_Cons EC1 ON I.Increment_ID=EC1.Increment_ID  
         --INNER JOIN (SELECT MAX(Increment_ID) as Increment_ID , Emp_ID   
         --   FROM T0095_Increment   
         --   WHERE Increment_Effective_date <= @To_Date AND Cmp_ID = @Cmp_ID      
         --   GROUP BY emp_ID  ) Qry on I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID    
       ) I_Q ON E.Emp_ID = I_Q.Emp_ID     
    LEFT OUTER JOIN (SELECT Emp_Id,ISNULL(SUM(M_Ad_Amount),0) as PF_Amount   
         FROM T0210_Monthly_AD_Detail  WITH (NOLOCK) 
         WHERE cmp_id = @cmp_id AND for_date <= @To_Date   
          AND AD_ID in (SELECT AD_ID FROM T0050_AD_Master WITH (NOLOCK)  
               WHERE  cmp_id = @cmp_id and AD_DEF_ID = 2  and AD_Flag = 'D' and AD_ACtive = 1 and AD_NOT_EFFECT_Salary <> 1)           
         GROUP BY Emp_id) EPF on E.Emp_Id = EPF.Emp_id   
    LEFT OUTER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID      
    LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID   
    LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id      
    LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id     
    LEFT OUTER JOIN T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID     
    LEFT OUTER JOIN T0030_Branch_Master EBM WITH (NOLOCK) on E.Branch_ID = EBM.Branch_ID     
    LEFT OUTER JOIN T0040_Bank_master bk WITH (NOLOCK) on i_Q.Bank_ID = Bk.Bank_ID      
    LEFT OUTER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON MS.CMP_ID = CM.CMP_ID      
    LEFT OUTER JOIN T0030_CATEGORY_MASTER CT WITH (NOLOCK) ON I_Q.Cat_ID = CT.Cat_ID  
    LEFT JOIN #TMPUNPAIDLEAVE UL ON MS.Emp_ID=UL.EMP_ID AND MS.Cmp_ID=UL.CMP_ID       
  WHERE E.Cmp_ID = @Cmp_Id             
    AND  Month(Ms.Month_End_Date) = Month(@To_Date) and Year(Ms.Month_End_Date) = Year(@To_Date)          
  ORDER BY RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500)                                 
 END      
  
  DROP TABLE #TMPUNPAIDLEAVE  
           
           
 RETURN             
  
  
  
  

