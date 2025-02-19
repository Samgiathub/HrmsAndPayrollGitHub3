


---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_T0200_MONTHLY_SALARY_GET_SMALL]      
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
 ,@constraint  varchar(max)      
 ,@Sal_Type  numeric = 0 
 ,@Salary_Cycle_id numeric = 0  
 ,@Segment_Id  numeric = 0		 -- Added By Gadriwala Muslim 26072013
 ,@Vertical_Id numeric = 0		 -- Added By Gadriwala Muslim 26072013
 ,@SubVertical_Id numeric = 0	 -- Added By Gadriwala Muslim 26072013
 ,@SubBranch_Id numeric = 0		 -- Added By Gadriwala Muslim 01082013	 	
 ,@Status varchar(20) = ''		 -- Added by Nimesh 19 May 2015 (To Filter Salary by Status)		
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
   
 --Added By Gadriwala on 26072013--------------
	if @Segment_Id = 0 
		set @Segment_Id = null
	IF @Vertical_Id= 0 
		set @Vertical_Id = null
	if @SubVertical_Id = 0 
	set @SubVertical_Id= Null
	-----------------------------------------------
 If @SubBranch_Id = 0	 -- Added By Gadriwala Muslim 01082013
		set @SubBranch_Id = null	
	
   
 Declare @Sal_St_Date   Datetime    
  Declare @Sal_end_Date   Datetime  
  
	If @Branch_ID is null
		Begin 
			select Top 1 @Sal_St_Date  = Sal_st_Date 
			  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
			  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Cmp_ID = @Cmp_ID)    
		End
	Else
		Begin
			select @Sal_St_Date  =Sal_st_Date 
			  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
			  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
		End    
	   
	   
	   
 if isnull(@Sal_St_Date,'') = ''    
	begin    
	   set @From_Date  = @From_Date     
	   set @To_Date = @To_Date    
	end     
 else if day(@Sal_St_Date) =1 --and month(@Sal_St_Date)=1    
	begin    
	   set @From_Date  = @From_Date     
	   set @To_Date = @To_Date    
	end     
 else  if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
	begin    
	   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
	   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))
	   set @From_Date = @Sal_St_Date
	   Set @To_Date = @Sal_end_Date   
	End 
	
  
    CREATE TABLE #Emp_Cons 
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )   
	 
	 EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,@Sal_Type ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id 
	      
	--Added by Nimesh 19 May 2015
	--Filtering Employee Record according to Salary Status
	IF (@Status = 'Hold' OR @Status = 'Done') BEGIN
		DELETE	FROM #Emp_Cons 
		WHERE	Emp_ID NOT IN ( 
								SELECT Emp_ID FROM T0200_MONTHLY_SALARY S WITH (NOLOCK)
								WHERE	Month(S.Month_End_Date)=Month(@To_Date) 
										AND Year(S.Month_End_Date)=Year(@To_Date) 
										AND S.Cmp_ID=@Cmp_ID 
										AND S.Salary_Status=@Status
							   )
	END     
 --Declare #Emp_Cons Table      
 --(      
 -- Emp_ID numeric      
 --)      
       
 --if @Constraint <> ''      
 -- begin      
 --  Insert Into #Emp_Cons      
 --  select  cast(data  as numeric) from dbo.Split (@Constraint,'#')       
 -- end      
 --else      
 -- begin      
         
         
 --  Insert Into #Emp_Cons      
      
 --  select I.Emp_Id from T0095_Increment I inner join       
 --    ( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment      
 --    where Increment_Effective_date <= @To_Date      
 --    and Cmp_ID = @Cmp_ID      
 --    group by emp_ID  ) Qry on      
 --    I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date       
             
 --  Where Cmp_ID = @Cmp_ID       
 --  and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
 --  and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
 --  and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
 --  and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
 --  and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
 --  and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))   
 --  and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))	 -- Added By Gadriwala Muslim 26072013
 --  and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 -- Added By Gadriwala Muslim 26072013
 --  and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) -- Added By Gadriwala Muslim 26072013
 --  and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) -- Added By Gadriwala Muslim 01082013            
 --  and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)       
 --  and I.Emp_ID in       
 --   ( select Emp_Id from      
 --   (select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry      
 --   where cmp_ID = @Cmp_ID   and        
 --   (( @From_Date  >= join_Date  and  @From_Date <= left_date )       
 --   or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
 --   or Left_date is null and @To_Date >= Join_Date)      
 --   or @To_Date >= left_date  and  @From_Date <= left_date )       
         
 -- end      
        
        
  DEclare @Emp_Salary table(      
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
   Sal_Cal_Days   numeric(18, 1) ,      
   Present_Days   numeric(18, 1) ,      
   Absent_Days   numeric(18, 1) ,      
   Holiday_Days   numeric(18, 1) ,      
   Weekoff_Days   numeric(18, 1) ,      
   Cancel_Holiday   numeric(18, 1) ,      
   Cancel_Weekoff   numeric(18, 1) ,      
   Working_Days   numeric(18, 1) ,      
   Outof_Days   numeric(18, 1)  ,      
   Total_Leave_Days  numeric(18, 1) ,      
   Paid_Leave_Days  numeric(18, 1) ,      
   Actual_Working_Hours  varchar (20) ,      
   Working_Hours   varchar (20) ,      
   Outof_Hours   varchar (20) ,      
   OT_Hours   numeric(18, 1)  ,      
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
   Total_Claim_Amount  numeric(18, 0) ,      
   M_OT_Hours   numeric(18, 1) ,      
   M_Adv_Amount   numeric(18, 0) ,      
   M_Loan_Amount   numeric(18, 0) ,      
   M_IT_Tax   numeric(18, 0) ,      
   LWF_Amount   numeric(18, 0) ,      
   Revenue_Amount   numeric(18, 0) ,      
   PT_F_T_Limit   varchar (20),    
   Late_Days  numeric,   
   PL numeric(18,2) default 0,
   On_Du numeric(18,2) default 0,
   C_off numeric(18,2) default 0,
   ML numeric(18,2) default 0
          
  )      
      
    
 if @Sal_Type = 0      
   begin      
   
   
       
    INSERT INTO @Emp_Salary      
          (Sal_Tran_ID, Sal_Receipt_No, Emp_ID, Cmp_ID, Increment_ID, Month_St_Date, Month_End_Date, Sal_Generate_Date, Sal_Cal_Days, Present_Days,       
          Absent_Days, Holiday_Days, Weekoff_Days, Cancel_Holiday, Cancel_Weekoff, Working_Days, Outof_Days, Total_Leave_Days, Paid_Leave_Days,       
          Actual_Working_Hours, Working_Hours, Outof_Hours, OT_Hours, Total_Hours, Shift_Day_Sec, Shift_Day_Hour, Basic_Salary, Day_Salary,       
          Hour_Salary, Salary_Amount, Allow_Amount, OT_Amount, Other_Allow_Amount, Gross_Salary, Dedu_Amount, Loan_Amount, Loan_Intrest_Amount,       
          Advance_Amount, Other_Dedu_Amount, Total_Dedu_Amount, Due_Loan_Amount, Net_Amount, Actually_Gross_Salary, PT_Amount,       
          PT_Calculated_Amount, Total_Claim_Amount, M_OT_Hours, M_Adv_Amount, M_Loan_Amount, M_IT_Tax, LWF_Amount, Revenue_Amount,       
          PT_F_T_Limit,Late_Days)      
      
    select Sal_Tran_ID, Sal_Receipt_No, ms.Emp_ID, Cmp_ID, Ms.Increment_ID, Month_St_Date, Month_End_Date, Sal_Generate_Date, Sal_Cal_Days, Present_Days,       
          Absent_Days, Holiday_Days, Weekoff_Days, Cancel_Holiday, Cancel_Weekoff, Working_Days, Outof_Days, Total_Leave_Days, Paid_Leave_Days,       
          Actual_Working_Hours, Working_Hours, Outof_Hours, OT_Hours, Total_Hours, Shift_Day_Sec, Shift_Day_Hour, Basic_Salary, Day_Salary,       
          Hour_Salary, Salary_Amount, Allow_Amount, OT_Amount, Other_Allow_Amount, Gross_Salary, Dedu_Amount, Loan_Amount, Loan_Intrest_Amount,       
          Advance_Amount, Other_Dedu_Amount, Total_Dedu_Amount, Due_Loan_Amount, Net_Amount, Actually_Gross_Salary, PT_Amount,       
          PT_Calculated_Amount, Total_Claim_Amount, M_OT_Hours, M_Adv_Amount, M_Loan_Amount, M_IT_Tax, LWF_Amount, Revenue_Amount,       
          PT_F_T_Limit  ,Late_Days    
              
     From T0200_MONTHLY_SALARY ms WITH (NOLOCK) inner join #Emp_Cons ec on ms.emp_ID =ec.emp_ID       
     Where ms.Cmp_ID = @Cmp_Id       
      and Salary_Amount >0 And Isnull(IS_FNF,0)=0     
      and month(Month_End_Date) = Month(@To_Date)  and Year(Month_End_Date) =Year(@To_Date) 
      
      Update @Emp_Salary 
      set On_Du = Leave_Days from @Emp_Salary ES inner join
      (select TML.Leave_Days,TML.sal_Tran_ID from T0210_MONTHLY_LEAVE_DETAIL TML WITH (NOLOCK) 
      inner join t0040_leave_master LM WITH (NOLOCK) on TML.Leave_ID=LM.Leave_ID where LM.Leave_Code='OD')Q_I
      on ES.Sal_Tran_ID = Q_I.Sal_Tran_ID  
      
      Update @Emp_Salary 
      set PL = Leave_Days from @Emp_Salary ES inner join
      (select TML.Leave_Days,TML.sal_Tran_ID from T0210_MONTHLY_LEAVE_DETAIL TML WITH (NOLOCK) 
      inner join t0040_leave_master LM WITH (NOLOCK) on TML.Leave_ID=LM.Leave_ID where LM.Leave_Code='PL')Q_I
      on ES.Sal_Tran_ID = Q_I.Sal_Tran_ID  
      
      Update @Emp_Salary 
      set C_off = Leave_Days from @Emp_Salary ES inner join
      (select TML.Leave_Days,TML.sal_Tran_ID from T0210_MONTHLY_LEAVE_DETAIL TML WITH (NOLOCK)
      inner join t0040_leave_master LM WITH (NOLOCK) on TML.Leave_ID=LM.Leave_ID where LM.Leave_Code='C.off')Q_I
      on ES.Sal_Tran_ID = Q_I.Sal_Tran_ID  
      
      Update @Emp_Salary 
      set ML = Leave_Days from @Emp_Salary ES inner join
      (select TML.Leave_Days,TML.sal_Tran_ID from T0210_MONTHLY_LEAVE_DETAIL TML WITH (NOLOCK)
      inner join t0040_leave_master LM WITH (NOLOCK) on TML.Leave_ID=LM.Leave_ID where LM.Leave_Code='ML')Q_I
      on ES.Sal_Tran_ID = Q_I.Sal_Tran_ID  
       
      
      
      end      
 else if @Sal_Type = 1       
   begin      
    INSERT INTO @Emp_Salary      
          (S_Sal_Tran_ID, Sal_Receipt_No, Emp_ID, Cmp_ID, Increment_ID, Month_St_Date, Month_End_Date, Sal_Generate_Date, Sal_Cal_Days, Present_Days,       
          Absent_Days, Holiday_Days, Weekoff_Days, Cancel_Holiday, Cancel_Weekoff, Working_Days, Outof_Days, Total_Leave_Days, Paid_Leave_Days,       
          Actual_Working_Hours, Working_Hours, Outof_Hours, OT_Hours, Total_Hours, Shift_Day_Sec, Shift_Day_Hour, Basic_Salary, Day_Salary,       
          Hour_Salary, Salary_Amount, Allow_Amount, OT_Amount, Other_Allow_Amount, Gross_Salary, Dedu_Amount, Loan_Amount, Loan_Intrest_Amount,       
          Advance_Amount, Other_Dedu_Amount, Total_Dedu_Amount, Due_Loan_Amount, Net_Amount, Actually_Gross_Salary, PT_Amount,       
          PT_Calculated_Amount, Total_Claim_Amount, M_OT_Hours, M_Adv_Amount, M_Loan_Amount, M_IT_Tax, LWF_Amount, Revenue_Amount,       
          PT_F_T_Limit)      
      
    select S_Sal_Tran_ID, S_Sal_Receipt_No, ms.Emp_ID, Cmp_ID, Ms.Increment_ID, S_Month_St_Date, S_Month_End_Date, S_Sal_Generate_Date, S_Sal_Cal_Days, S_M_Present_Days,       
          0, 0, 0, 0, 0, s_Working_Days, s_Outof_Days, 0,0,       
          '', '', '', 0, '', S_Shift_Day_Sec, S_Shift_Day_Hour, S_Basic_Salary, S_Day_Salary,       
          S_Hour_Salary, S_Salary_Amount, S_Allow_Amount, S_OT_Amount, S_Other_Allow_Amount, S_Gross_Salary, S_Dedu_Amount, S_Loan_Amount, S_Loan_Intrest_Amount,       
          S_Advance_Amount, S_Other_Dedu_Amount, S_Total_Dedu_Amount, S_Due_Loan_Amount, S_Net_Amount, S_Actually_Gross_Salary, S_PT_Amount,       
          S_PT_Calculated_Amount, S_Total_Claim_Amount, S_M_OT_Hours, S_M_Adv_Amount, S_M_Loan_Amount, S_M_IT_Tax, S_LWF_Amount, S_Revenue_Amount,       
          S_PT_F_T_Limit      
              
     From T0201_MONTHLY_SALARY_Sett ms WITH (NOLOCK) inner join #Emp_Cons ec on ms.emp_ID =ec.emp_ID       
     Where ms.Cmp_ID = @Cmp_Id       
      and S_Salary_Amount >0      
      --and S_Month_St_Date >=@From_Date and S_Month_End_Date <=@To_Date      
       and month(S_Month_End_Date) = Month(@To_Date)  and Year(S_Month_End_Date) =Year(@To_Date) 
      Update @Emp_Salary 
      set On_Du = Leave_Days from @Emp_Salary ES inner join
      (select TML.Leave_Days,TML.sal_Tran_ID from T0210_MONTHLY_LEAVE_DETAIL TML WITH (NOLOCK)
      inner join t0040_leave_master LM WITH (NOLOCK) on TML.Leave_ID=LM.Leave_ID where LM.Leave_Code='OD')Q_I
      on ES.Sal_Tran_ID = Q_I.Sal_Tran_ID  
      
      Update @Emp_Salary 
      set PL = Leave_Days from @Emp_Salary ES inner join
      (select TML.Leave_Days,TML.sal_Tran_ID from T0210_MONTHLY_LEAVE_DETAIL TML WITH (NOLOCK)
      inner join t0040_leave_master LM WITH (NOLOCK) on TML.Leave_ID=LM.Leave_ID where LM.Leave_Code='PL')Q_I
      on ES.Sal_Tran_ID = Q_I.Sal_Tran_ID  
      
      Update @Emp_Salary 
      set C_off = Leave_Days from @Emp_Salary ES inner join
      (select TML.Leave_Days,TML.sal_Tran_ID from T0210_MONTHLY_LEAVE_DETAIL TML WITH (NOLOCK)
      inner join t0040_leave_master LM WITH (NOLOCK) on TML.Leave_ID=LM.Leave_ID where LM.Leave_Code='C.off')Q_I
      on ES.Sal_Tran_ID = Q_I.Sal_Tran_ID  
      
      Update @Emp_Salary 
      set ML = Leave_Days from @Emp_Salary ES inner join
      (select TML.Leave_Days,TML.sal_Tran_ID from T0210_MONTHLY_LEAVE_DETAIL TML WITH (NOLOCK)
      inner join t0040_leave_master LM WITH (NOLOCK) on TML.Leave_ID=LM.Leave_ID where LM.Leave_Code='ML')Q_I
      on ES.Sal_Tran_ID = Q_I.Sal_Tran_ID  
      
   end      
 else if @Sal_Type = 2      
   begin      
    INSERT INTO @Emp_Salary      
          (l_Sal_Tran_ID, Sal_Receipt_No, Emp_ID, Cmp_ID, Increment_ID, Month_St_Date, Month_End_Date, Sal_Generate_Date, Sal_Cal_Days, Present_Days,       
          Absent_Days, Holiday_Days, Weekoff_Days, Cancel_Holiday, Cancel_Weekoff, Working_Days, Outof_Days, Total_Leave_Days, Paid_Leave_Days,       
          Actual_Working_Hours, Working_Hours, Outof_Hours, OT_Hours, Total_Hours, Shift_Day_Sec, Shift_Day_Hour, Basic_Salary, Day_Salary,       
          Hour_Salary, Salary_Amount, Allow_Amount, OT_Amount, Other_Allow_Amount, Gross_Salary, Dedu_Amount, Loan_Amount, Loan_Intrest_Amount,       
          Advance_Amount, Other_Dedu_Amount, Total_Dedu_Amount, Due_Loan_Amount, Net_Amount, Actually_Gross_Salary, PT_Amount,       
          PT_Calculated_Amount, Total_Claim_Amount, M_OT_Hours, M_Adv_Amount, M_Loan_Amount, M_IT_Tax, LWF_Amount, Revenue_Amount,       
          PT_F_T_Limit)      
      
    select L_Sal_Tran_ID, l_Sal_Receipt_No, ms.Emp_ID, Cmp_ID, Ms.Increment_ID, l_Month_St_Date, l_Month_End_Date, L_Sal_Generate_Date, l_Sal_Cal_Days, 0,       
          0, 0, 0, 0, 0, L_Working_Days, l_Outof_Days, 0, 0,       
          '', '', '', 0, '', l_Shift_Day_Sec, l_Shift_Day_Hour, l_Basic_Salary, l_Day_Salary,       
          l_Hour_Salary, l_Salary_Amount, l_Allow_Amount, 0, l_Other_Allow_Amount, L_Gross_Salary, L_Dedu_Amount, L_Loan_Amount, L_Loan_Intrest_Amount,       
          L_Advance_Amount, L_Other_Dedu_Amount, L_Total_Dedu_Amount, L_Due_Loan_Amount, L_Net_Amount, L_Actually_Gross_Salary, L_PT_Amount,       
          l_PT_Calculated_Amount, 0, 0, l_M_Adv_Amount, l_M_Loan_Amount, l_M_IT_Tax, l_LWF_Amount, l_Revenue_Amount,       
          l_PT_F_T_Limit      
              
     From T0200_MONTHLY_SALARY_Leave ms WITH (NOLOCK) inner join #Emp_Cons ec on ms.emp_ID =ec.emp_ID       
     Where ms.Cmp_ID = @Cmp_Id       
      and L_Salary_Amount >0      
      --and L_Month_St_Date >=@From_Date and L_Month_End_Date <=@To_Date      
      and month(L_Month_End_Date) = Month(@To_Date)  and Year(L_Month_End_Date) =Year(@To_Date) 
      
      Update @Emp_Salary 
      set On_Du = Leave_Days from @Emp_Salary ES inner join
      (select TML.Leave_Days,TML.sal_Tran_ID from T0210_MONTHLY_LEAVE_DETAIL TML WITH (NOLOCK)
      inner join t0040_leave_master LM WITH (NOLOCK) on TML.Leave_ID=LM.Leave_ID where LM.Leave_Code='OD')Q_I
      on ES.Sal_Tran_ID = Q_I.Sal_Tran_ID  
      
      Update @Emp_Salary 
      set PL = Leave_Days from @Emp_Salary ES inner join
      (select TML.Leave_Days,TML.sal_Tran_ID from T0210_MONTHLY_LEAVE_DETAIL TML WITH (NOLOCK)
      inner join t0040_leave_master LM WITH (NOLOCK) on TML.Leave_ID=LM.Leave_ID where LM.Leave_Code='PL')Q_I
      on ES.Sal_Tran_ID = Q_I.Sal_Tran_ID  
      
      Update @Emp_Salary 
      set C_off = Leave_Days from @Emp_Salary ES inner join
      (select TML.Leave_Days,TML.sal_Tran_ID from T0210_MONTHLY_LEAVE_DETAIL TML WITH (NOLOCK)
      inner join t0040_leave_master LM WITH (NOLOCK) on TML.Leave_ID=LM.Leave_ID where LM.Leave_Code='C.off')Q_I
      on ES.Sal_Tran_ID = Q_I.Sal_Tran_ID  
      
      Update @Emp_Salary 
      set ML = Leave_Days from @Emp_Salary ES inner join
      (select TML.Leave_Days,TML.sal_Tran_ID from T0210_MONTHLY_LEAVE_DETAIL TML WITH (NOLOCK)
      inner join t0040_leave_master LM WITH (NOLOCK) on TML.Leave_ID=LM.Leave_ID where LM.Leave_Code='ML')Q_I
      on ES.Sal_Tran_ID = Q_I.Sal_Tran_ID  
      
   end      
 else       
   begin      
    INSERT INTO @Emp_Salary      
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
          
          
    Update @Emp_Salary      
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
 Late_Days=ms.Late_Days    
    From @Emp_Salary es Inner join T0200_MONTHLY_SALARY ms on es.emp_ID =ms.emp_ID       
     Where ms.Cmp_ID = @Cmp_Id       
      and ms.Salary_Amount >0      
      --and ms.Month_St_Date >=@From_Date and ms.Month_End_Date <=@To_Date      
       and month(ms.Month_End_Date) = Month(@To_Date)  and Year(ms.Month_End_Date) =Year(@To_Date)     
          
          
    Update @Emp_Salary      
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
    From @Emp_Salary es Inner join T0201_MONTHLY_SALARY_SETT ms on es.emp_ID =ms.emp_ID       
     Where ms.Cmp_ID = @Cmp_Id       
     -- and S_Month_St_Date >=@From_Date and S_Month_End_Date <=@To_Date      
      and month(S_Month_End_Date) = Month(@To_Date)  and Year(S_Month_End_Date) =Year(@To_Date)     
          
    Update @Emp_Salary      
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
    From @Emp_Salary es Inner join T0200_MONTHLY_SALARY_LEAVE ms on es.emp_ID =ms.emp_ID       
     Where ms.Cmp_ID = @Cmp_Id       
      --and L_Month_St_Date >=@From_Date and L_Month_End_Date <=@To_Date      
       and month(L_Month_End_Date) = Month(@To_Date)  and Year(L_Month_End_Date) =Year(@To_Date)  
       
      Update @Emp_Salary 
      set On_Du = Leave_Days from @Emp_Salary ES inner join
      (select TML.Leave_Days,TML.sal_Tran_ID from T0210_MONTHLY_LEAVE_DETAIL TML WITH (NOLOCK)
      inner join t0040_leave_master LM WITH (NOLOCK) on TML.Leave_ID=LM.Leave_ID where LM.Leave_Code='OD')Q_I
      on ES.Sal_Tran_ID = Q_I.Sal_Tran_ID  
      
      Update @Emp_Salary 
      set PL = Leave_Days from @Emp_Salary ES inner join
      (select TML.Leave_Days,TML.sal_Tran_ID from T0210_MONTHLY_LEAVE_DETAIL TML WITH (NOLOCK)
      inner join t0040_leave_master LM WITH (NOLOCK) on TML.Leave_ID=LM.Leave_ID where LM.Leave_Code='PL')Q_I
      on ES.Sal_Tran_ID = Q_I.Sal_Tran_ID  
      
      Update @Emp_Salary 
      set C_off = Leave_Days from @Emp_Salary ES inner join
      (select TML.Leave_Days,TML.sal_Tran_ID from T0210_MONTHLY_LEAVE_DETAIL TML WITH (NOLOCK)
      inner join t0040_leave_master LM WITH (NOLOCK) on TML.Leave_ID=LM.Leave_ID where LM.Leave_Code='C.off')Q_I
      on ES.Sal_Tran_ID = Q_I.Sal_Tran_ID  
      
      Update @Emp_Salary 
      set ML = Leave_Days from @Emp_Salary ES inner join
      (select TML.Leave_Days,TML.sal_Tran_ID from T0210_MONTHLY_LEAVE_DETAIL TML WITH (NOLOCK)
      inner join t0040_leave_master LM WITH (NOLOCK) on TML.Leave_ID=LM.Leave_ID where LM.Leave_Code='ML')Q_I
      on ES.Sal_Tran_ID = Q_I.Sal_Tran_ID  
          
   end      
        
        
 Select MS.*,Emp_full_Name,Branch_Address,branch_name,Comp_name,Grd_Name,Month(Month_St_Date)as Month,YEar(Month_St_Date)as Year ,Branch_NAme,Comp_Name      
   ,EMP_CODE,Type_Name,Dept_Name,Desig_Name,Inc_Bank_Ac_no,PAN_no,DAte_of_Birth,Date_of_Join,      
   SSN_No as PF_No,SIN_No as ESIC_No ,dbo.F_Number_TO_Word(Net_Amount) as Net_Amount_In_Word      
  ,Bank_Name ,CMP_NAME,CMP_ADDRESS, cm.Image_name Cmp_Image_Name , cm.cmp_logo Cmp_Logo ,  -- CMP_Logo added by mihir 06/03/2012
   Branch_Code,DATE_OF_JOIN,I_Q.Inc_Bank_Ac_no
	,BM.Branch_ID
	,E.Emp_First_Name,E.Alpha_emp_Code  --added jimit 29052015
	,DGM.Desig_Dis_No                   --added jimit 24082015
	,t2.Comments						 --added jimit 0912015
 from @Emp_Salary Ms  inner join T0080_Emp_Master E WITH (NOLOCK) on MS.Emp_ID =E.Emp_ID
  inner join 

( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Inc_Bank_Ac_no,Bank_ID from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
				on E.Emp_ID = I_Q.Emp_ID 

 left outer join
 
     T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID left outer  JOIN      
     T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID left outer   JOIN      
     T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id    left outer JOIN      
     T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id    left outer join       
     T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  left outer join
     T0040_Bank_master bk WITH (NOLOCK) on i_Q.Bank_ID = Bk.Bank_ID left outer join       
     T0010_COMPANY_MASTER CM WITH (NOLOCK) ON MS.CMP_ID = CM.CMP_ID  left outer join
     (select * from t0250_salary_publish_ess WITH (NOLOCK)
    where cmp_id = @Cmp_ID and month = month(@to_date) and [year]=year(@to_date) and Sal_Type='Salary') t2 --Added By Mukti Sal_Type(30062016)
    on t2.Emp_ID = ms.Emp_ID
  WHERE E.Cmp_ID = @Cmp_Id       
   and Salary_Amount >0      
   --and Month_St_Date >=@From_Date and Month_End_Date <=@To_Date         
    and month(Month_End_Date) = Month(@To_Date)  and Year(Month_End_Date) =Year(@To_Date)     
           
 RETURN       
      
      
      

