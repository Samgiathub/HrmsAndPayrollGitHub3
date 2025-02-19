
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_EMP_CALCATE_INCREMENT]      
  @Cmp_ID  numeric   
 ,@Emp_ID  numeric    
 ,@From_Date  datetime      
 ,@To_Date  datetime       
 ,@Branch_ID  varchar(MAX) = ''    
 ,@Cat_ID  varchar(MAX) = ''  
 ,@Grd_ID  varchar(MAX) = ''  
 ,@Type_ID  numeric  
 ,@Dept_ID  varchar(max)=''  
 ,@Desig_ID  varchar(max)=''  
 ,@Constraint varchar(MAX) = ''  
 ,@Vertical_ID_Multi varchar(max)=''
 ,@Subvertical_ID_Multi varchar(max)='' 
 ,@Segment_Id varchar(max)='' 
 ,@SubBranch_ID varchar(max)='' 
AS      
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON    
 
 --if @Branch_ID = 0      
 -- set @Branch_ID = null   
     
 --if @Cat_ID = 0      
 -- set @Cat_ID = null      
         
 if @Type_ID = 0      
  set @Type_ID = null 
       
 --if @Dept_ID = 0      
 -- set @Dept_ID = null   
     
 --if @Grd_ID = 0      
 -- set @Grd_ID = null   
     
 if @Emp_ID = 0      
  set @Emp_ID = null      
        
 --If @Desig_ID = 0      
 -- set @Desig_ID = null  
  
 --IF @Branch_ID_Multi='0' or @Branch_ID_Multi='' 
	--set @Branch_ID_Multi=null	

 IF @Vertical_ID_Multi='0' or @Vertical_ID_Multi='' 
	set @Vertical_ID_Multi=null	

 IF @Subvertical_ID_Multi='0' or @Subvertical_ID_Multi='' 
	set @Subvertical_ID_Multi=null	
		
 IF @Dept_ID='0' or @Dept_ID='' 
	set @Dept_ID=null	             
 
 IF object_ID('tempdb..#Emp_Cons') is not null
	Begin
		drop table #Emp_Cons
	End      
       
 CREATE table #Emp_Cons 
 (      
	  Emp_ID numeric ,     
	  Branch_ID numeric,
	  Increment_ID numeric
 )      

 Exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN  @Cmp_ID=@Cmp_ID ,@From_Date = @From_Date,@To_Date=@To_Date,@Branch_ID=@Branch_ID,@Cat_ID=@Cat_ID,@Grd_ID=@Grd_ID,@Type_ID=@Type_ID,@Dept_ID=@Dept_ID,@Desig_ID =@Desig_ID ,@Emp_ID = @Emp_ID ,@constraint = @Constraint,@Sal_Type = 0 ,@Salary_Cycle_id = 0,@Segment_Id=@Segment_Id,@Vertical_Id	=@Vertical_ID_Multi,@SubVertical_Id =@Subvertical_ID_Multi,@SubBranch_Id=@SubBranch_ID,@New_Join_emp =0,@Left_Emp = 0 ,@SalScyle_Flag = 0,@PBranch_ID = 0,@With_Ctc = 0,@Type = 0 
 
 If object_id('tempdb..#Emp_Increment_Calc') is not null
	Begin
		drop TABLE #Emp_Increment_Calc
	End	
	 
  CREATE table #Emp_Increment_Calc
  (
	 Emp_ID numeric ,     
	 Branch_ID numeric,
	 Increment_ID numeric,
	 Cmp_ID numeric,
	 Basic_Salary numeric(18,2),
	 Gross_Amount Numeric(18,2),
	 Wages_Calc_on Numeric(18,2),
	 Wages_Calculation Numeric(18,2),
	 Salary_Cal_Days Numeric(18,2),
	 Eligible_Days Numeric(18,2),
	 Increment_Amount Numeric(18,2),
	 Working_Days Numeric(18,2),
  )
	
  Insert INTO #Emp_Increment_Calc 
  Select EC.Emp_ID,I.Branch_ID,I.Increment_ID,I.Cmp_ID,I.Basic_Salary,0,0,0,0,0,0,0
  From #Emp_Cons EC Inner join T0095_INCREMENT I WITH (NOLOCK)
  ON I.Emp_ID = EC.Emp_ID inner JOIN
		(
			SELECT Max(I1.increment_Id) as Increment_Id,I1.Emp_ID
			from T0095_INCREMENT I1 WITH (NOLOCK) INNER JOIN
					(
						SELECT max(I2.Increment_Effective_Date) as Increment_Effective_Date,I2.Emp_ID 
						from T0095_INCREMENT I2 WITH (NOLOCK)
						where I2.Increment_Effective_Date <= GETDATE() and I2.Cmp_ID = @cmp_Id
							and I2.Increment_Type <> 'Transfer' and I2.Increment_Type <> 'Deputation'
						GROUP By I2.Emp_ID
					)Q On Q.Emp_ID = I1.Emp_ID and q.Increment_Effective_Date = I1.Increment_Effective_Date
			where  I1.Cmp_ID = @Cmp_Id and I1.Increment_Type <> 'Transfer' and I1.Increment_Type <> 'Deputation'
			GROUP By I1.Emp_ID				
		)Q1 On q1.Increment_Id = I.Increment_ID--and I.Increment_ID = EC.Increment_ID
  
  SELECT EMP_ID,AD_ID,E_AD_PERCENTAGE,E_Ad_Amount,E_AD_Flag,E_AD_Max_Limit ,AD_Calculate_On ,AD_DEF_ID ,        --- Performance             
			AD_NOT_EFFECT_ON_PT,
			AD_NOT_EFFECT_SALARY,AD_EFFECT_ON_OT,
			AD_EFFECT_ON_EXTRA_DAY,
			AD_Name,AD_effect_on_Late,
			AD_Effect_Month,
			AD_CAL_TYPE,AD_EFFECT_FROM,AD_NOT_EFFECT_ON_LWP,
			Allowance_Type, AutoPaid,
			AD_LEVEL,is_rounding,
			Add_in_sal_amt
		Into #AD_Master
		FROM (
		SELECT EED.EMP_ID, EED.AD_ID,
			 Case When Qry1.Increment_ID >= EED.INCREMENT_ID /*Qry1.FOR_DATE > EED.FOR_DATE*/ Then
				Case When Qry1.E_AD_PERCENTAGE IS null Then eed.E_AD_PERCENTAGE Else Qry1.E_AD_PERCENTAGE End 
			 Else
				eed.E_AD_PERCENTAGE End As E_AD_PERCENTAGE,
			 Case When Qry1.Increment_ID >= EED.INCREMENT_ID /*Qry1.FOR_DATE > EED.FOR_DATE*/ Then
				Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End 
			 Else
				eed.e_ad_Amount End As E_Ad_Amount,
			E_AD_Flag,E_AD_Max_Limit ,AD_Calculate_On ,AD_DEF_ID ,                    
			ISNULL(AD_NOT_EFFECT_ON_PT,0) AS AD_NOT_EFFECT_ON_PT,
			ISNULL(AD_NOT_EFFECT_SALARY,0) AS AD_NOT_EFFECT_SALARY,ISNULL(AD_EFFECT_ON_OT,0) AS AD_EFFECT_ON_OT,
			ISNULL(AD_EFFECT_ON_EXTRA_DAY,0) AS AD_EFFECT_ON_EXTRA_DAY,
			AD_Name,ISNULL(AD_effect_on_Late,0) AS AD_effect_on_Late,
			ISNULL(AD_Effect_Month,'') AS AD_Effect_Month,
			ISNULL(AD_CAL_TYPE,'') AS AD_CAL_TYPE,ISNULL(AD_EFFECT_FROM,'') AS AD_EFFECT_FROM,
			ISNULL(ADM.AD_NOT_EFFECT_ON_LWP,0) AS AD_NOT_EFFECT_ON_LWP,
			ISNULL(ADM.Allowance_Type,'A') as Allowance_Type, 
			ISNULL(ADM.auto_paid,0) as AutoPaid,
			ADM.AD_LEVEL,ADM.is_rounding,
			ISNULL(ADM.Add_in_sal_amt,0) as Add_in_sal_amt
		FROM dbo.T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN                    
			   dbo.T0050_AD_MASTER ADM  WITH (NOLOCK) ON EEd.AD_ID = ADM.AD_ID   LEFT OUTER JOIN
				( Select EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE ,EEDR.Increment_ID
					From T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN
					( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK)
						Where  For_date <= @to_date
					 Group by Ad_Id )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
				) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID  And Qry1.FOR_DATE>=EED.FOR_DATE  
				Inner JOIN #Emp_Increment_Calc EIC ON EIC.Increment_ID =  EED.INCREMENT_ID             
		WHERE Adm.AD_ACTIVE = 1
			  And Case When Qry1.ENTRY_TYPE IS null Then '' Else Qry1.ENTRY_TYPE End <> 'D'
			  and ISNULL(ADM.Add_in_sal_amt,0) = 1
		UNION 
		
		SELECT EED.EMP_ID,EED.AD_ID,E_AD_Percentage,E_AD_Amount,E_AD_Flag,E_AD_Max_Limit ,AD_Calculate_On ,AD_DEF_ID ,                    
			ISNULL(AD_NOT_EFFECT_ON_PT,0) AS AD_NOT_EFFECT_ON_PT,
			ISNULL(AD_NOT_EFFECT_SALARY,0) AS AD_NOT_EFFECT_SALARY,
			ISNULL(AD_EFFECT_ON_OT,0) AS AD_EFFECT_ON_OT,
			ISNULL(AD_EFFECT_ON_EXTRA_DAY,0) AS AD_EFFECT_ON_EXTRA_DAY
			,AD_Name,ISNULL(AD_effect_on_Late,0) AS AD_effect_on_Late ,ISNULL(AD_Effect_Month,'') AS AD_Effect_Month,
			ISNULL(AD_CAL_TYPE,'') AS AD_CAL_TYPE,ISNULL(AD_EFFECT_FROM,'') AS AD_EFFECT_FROM,
			ISNULL(ADM.AD_NOT_EFFECT_ON_LWP,0) AS AD_NOT_EFFECT_ON_LWP,
			ISNULL(ADM.Allowance_Type,'A') as Allowance_Type, 
			isnull(ADM.auto_paid,0) as AutoPaid,
			ADM.AD_LEVEL,ADM.is_rounding,
			ISNULL(ADM.Add_in_sal_amt,0) as Add_in_sal_amt
		FROM dbo.T0110_EMP_EARN_DEDUCTION_REVISED EED WITH (NOLOCK) INNER JOIN  
			( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK)
				Where For_date <= @to_date 
				Group by Ad_Id )Qry on EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id                   
		   INNER JOIN dbo.T0050_AD_MASTER ADM  WITH (NOLOCK) ON EEd.AD_ID = ADM.AD_ID 
		   Inner JOIN #Emp_Increment_Calc EIC ON EIC.Increment_ID =  EED.INCREMENT_ID                      
		WHERE Adm.AD_ACTIVE = 1
				And EEd.ENTRY_TYPE = 'A'
				and ISNULL(ADM.Add_in_sal_amt,0) = 1
		) Qry
	
  Update EIC SET Gross_Amount = Isnull(EIC.Basic_Salary,0) + isnull(E_Ad_Amount,0)
  From #Emp_Increment_Calc EIC
  LEFT OUTER JOIN(
				SELECT SUM(E_Ad_Amount) as E_Ad_Amount,AM.Emp_ID From #AD_Master AM
				Group By AM.Emp_ID
			) as Qry 
  ON Qry.Emp_ID = EIC.Emp_ID
  
  Update EIC
	SET EIC.Wages_Calc_on = Isnull(IWS.PERCENTAGE,0),
		EIC.Wages_Calculation =  Case WHEN Isnull(IWS.PERCENTAGE,0) <> 0 THEN (EIC.Gross_Amount * IWS.PERCENTAGE)/100 ELSE 0 END,
		EIC.Salary_Cal_Days = Isnull(Qry_1.Sal_Cal_Days,0),
		EIC.Working_Days = ISNULL(Qry_1.Working_Days,0)
  From #Emp_Increment_Calc EIC
  Inner JOIN T0040_INCREMENT_CALC TIC ON EIC.Branch_ID = TIC.BRANCH_ID
  INNER JOIN T0045_INCREMENT_WAGES_SLAB IWS ON TIC.TRAN_ID = IWS.TRAN_ID and EIC.Gross_Amount Between IWS.FROM_WAGES AND IWS.TO_WAGES
  Inner JOIN(
			  select Max(FOR_DATE) as For_Date,BRANCH_ID from T0040_INCREMENT_CALC TIC1 WITH (NOLOCK)
			  group by BRANCH_ID
			) as Qry
  ON Qry.BRANCH_ID = TIC.Branch_ID 
  Left Outer JOIN(
				select Emp_ID,SUM(Sal_Cal_Days) as Sal_Cal_Days,SUM(Working_Days) as Working_Days
			    from T0200_MONTHLY_SALARY WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Month_End_Date between @From_Date and @To_Date
			    group by Emp_ID
			  ) as Qry_1
  ON Qry_1.Emp_ID = EIC.Emp_ID
  


  select E.Emp_ID, T.ID,T.CAPTION,CASE T.CAPTION 
										WHEN 'Present Days' THEN 'Present_Days'
										WHEN 'Absent Days' THEN 'Absent_Days'
										WHEN 'WeekOff' THEN 'Weekoff_Days'
										WHEN 'Holiday' THEN 'Holiday_Days'
										WHEN 'Late Deduction Days' THEN 'Late_Days'
						END As FieldName,T.Flag,0 As L_Count
  INTO	#EMP_INC_DETAIL
  from	#Emp_Cons E 		
		Cross APPLY (Select * FROM dbo.fn_getParticulars(@Cmp_ID,E.Branch_ID,@From_Date, 'I') T  Where T.Selected=1) T
  
  Update EID
	SET EID.L_Count = Isnull(T.leave_Sum,0)
  From #EMP_INC_DETAIL EID 
  Inner JOIN(   
				 --select SUM(LT.Leave_Used)+ SUM(LT.CompOff_Used) as Leave_Used,LT.Emp_ID,LT.Leave_ID
				 --from T0140_LEAVE_TRANSACTION LT 
				 --where Cmp_ID=@Cmp_ID and For_date between @FROM_DATE and @TO_DATE 
				 --group by LT.Emp_ID,LT.Leave_ID
				 SELECT MLD.Leave_Days as leave_Sum ,MLD.Leave_ID,emp_id 
				 FROM T0210_MONTHLY_LEAVE_DETAIL MLD WITH (NOLOCK)
				 inner join T0040_LEAVE_MASTER LM WITH (NOLOCK) on MLD.Leave_ID = Lm.Leave_id
				 where For_Date >= @FROM_DATE and For_Date <= @TO_DATE 
			) as T
  ON EID.ID = T.Leave_ID and EID.Emp_ID = T.Emp_ID
  Where EID.Flag = 'L'
  
  Declare @colsPivot_Add varchar(max)
  Set @colsPivot_Add = ''
	
  select @colsPivot_Add = coalesce(@colsPivot_Add+' ',' ') + FieldName + '#'
  from (select Distinct FieldName,ID from #EMP_INC_DETAIL Where Flag='D' AND Isnull(FieldName,'') <> '') T
  ORDER BY T.ID
  
  if @colsPivot_Add <> ''
    Set @colsPivot_Add = LEFT(@colsPivot_Add, LEN(@colsPivot_Add) - 1)
  
  Declare @Column varchar(max)
  set @Column = ''
  
  Declare CRU_COLUMNS CURSOR FOR
  Select data from Split(@colsPivot_Add,'#') where data <> ''
  Open CRU_COLUMNS
  fetch next from CRU_COLUMNS into @Column
	while @@fetch_status = 0
		Begin
				Update EID
				SET EID.L_Count = Qry.Month_Day
				From #EMP_INC_DETAIL EID 
				Inner JOIN(
							select Emp_ID,
							CASE @Column WHEN 'Present_Days' THEN SUM(Present_Days)
										 WHEN 'Absent_Days' THEN SUM(Absent_Days)
										 WHEN 'Weekoff_Days' THEN SUM(Weekoff_Days)
										 WHEN 'Holiday_Days' THEN SUM(Holiday_Days)
										 WHEN 'Late_Days' THEN SUM(Late_Days)
							END AS Month_Day
							from T0200_MONTHLY_SALARY WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Month_End_Date between @From_Date and @To_Date
							group by Emp_ID
						   ) as Qry
				ON Qry.Emp_ID = EID.Emp_ID and EID.FieldName = @Column
				Where Flag='D'
				
			fetch next from CRU_COLUMNS into @Column
		End
  close CRU_COLUMNS	
  deallocate CRU_COLUMNS						
  
  Update EIC
  Set EIC.Eligible_Days = Qry.L_Count,
  EIC.Increment_Amount = ROUND((CASE When Qry.L_Count > 30 THEN 0 ELSE 
	 (Case WHEN EIC.Working_Days <> 0 THEN (Wages_Calculation * EIC.Salary_Cal_Days)/EIC.Working_Days  
	 Else 0 END)
	 END),0)
  From #Emp_Increment_Calc EIC 
  Inner JOIN(
				Select SUM(L_Count) as L_Count,Emp_ID From #EMP_INC_DETAIL
				Group by Emp_ID
			) as Qry
  ON Qry.Emp_ID = EIC.Emp_ID
  
  
   Select	EM.Alpha_Emp_Code,EIC.Emp_ID,EM.Emp_Full_Name,EIC.Gross_Amount,(case when Dm.Category = 0 then 'Select' 
			WHEN Dm.Category = 1 then 'Sales & Production Staff' else 'Other Staff' end) as Category ,Dm.Minimum_Wages,EIC.Eligible_Days,EIC.Increment_Amount,EIC.Salary_Cal_Days,EIC.Wages_Calc_on,EIC.Wages_Calculation 
			
  From		#Emp_Increment_Calc EIC 
			  Inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = EIC.Emp_ID
			  INNER JOIN T0095_INCREMENT I WITH (NOLOCK) On I.Increment_ID = Eic.Increment_ID
			  INNER JOIN T0040_DEPARTMENT_MASTER Dm WITH (NOLOCK) On dm.Dept_Id = I.Dept_ID
  where		Em.Emp_Left <> 'Y'     --Added By Jimit 15052018 NO need to give Increment to Left Employee			  
  
 RETURN
