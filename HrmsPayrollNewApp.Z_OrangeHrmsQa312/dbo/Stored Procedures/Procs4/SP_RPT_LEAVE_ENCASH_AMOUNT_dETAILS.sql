
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_LEAVE_ENCASH_AMOUNT_dETAILS]
	 @Cmp_ID		Numeric
	,@From_Date		Datetime
	,@To_Date		Datetime
	,@Branch_ID		varchar(Max) = ''
	,@Cat_ID		varchar(Max) = ''
	,@Grd_ID		varchar(Max) = ''
	,@Type_ID		varchar(Max) = ''
	,@Dept_Id		varchar(Max) = ''
	,@Desig_Id		varchar(Max) = ''
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(MAX)
	,@Rpt_Format    varchar(MAX) = 'Default'
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


	CREATE TABLE #Emp_Cons 	
		 (      
		   Emp_ID numeric ,     
		   Branch_ID numeric,
		   Increment_ID numeric    
		 )	
	EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0 ,0 ,0 ,0 ,0 ,0 
	
	if @Rpt_Format = 'Default' or @Rpt_Format = 'Format1'   
		Begin
	     Select distinct la.Leave_Salary_Amount as LeaveAmount,tn.L_Cal_Encash_days,tn.L_Day_Salary as Day_Salary,tn.Encashment_days Leave_Encash_days,lm.Leave_Name,tn.Cal_Amount as Basic_Salary,I_Q.Gross_Salary,--E_AD_AMOUNT,
				 e.Emp_Full_name,e.Alpha_Emp_Code as Emp_Code,GM.Grd_Name,Branch_Name
								  ,Dept_Name,Desig_Name,type_Name,isnull(Tn.Encashment_Rate,0)as Encashment_Rate,Cmp_Name,Cmp_Address,comp_name,branch_name,branch_address ,BM.Branch_ID
				 ,e.Emp_First_Name     --added jimit 10062015
				 from T0200_MONTHLY_SALARY la WITH (NOLOCK)
				 inner join #Emp_Cons ec on la.emp_ID = ec.Emp_ID 
				 inner join T0010_Company_Master CM WITH (NOLOCK) on la.CMP_ID= CM.CMP_ID
				 inner join t0200_salary_leave_Encashment tn WITH (NOLOCK) on tn.Emp_ID=la.Emp_ID and tn.Cmp_ID=la.Cmp_ID and la.sal_tran_id = tn.sal_tran_id -- changed by rohit for Show leave encasement amount on 25122015 
				 inner join t0040_leave_master lm WITH (NOLOCK) on lm.Leave_ID=tn.Leave_ID and lm.Cmp_ID=tn.Cmp_ID
				 inner join T0080_Emp_Master e WITH (NOLOCK) on ec.emp_ID= e.emp_ID 
				 inner join
							( select I.Emp_Id ,i.Basic_Salary,i.Gross_Salary, Cmp_ID,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,i.Type_ID,Increment_effective_Date from T0095_Increment I WITH (NOLOCK) inner join 
									( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)
									where Increment_Effective_date <= @to_date
									and Cmp_ID = @Cmp_ID
									group by emp_ID  ) Qry on
									I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
								on Ec.Emp_ID = I_Q.Emp_ID  and I_Q.Cmp_ID=E.Cmp_ID left join
									T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
									T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
									T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
									T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join 
									T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID left join
									T0100_EMP_EARN_DEDUCTION ed WITH (NOLOCK) on la.Emp_ID=ed.emp_id inner join 
									T0050_AD_MASTER ad WITH (NOLOCK) on ad.cmp_id=ed.cmp_id and ad.AD_ID=ed.AD_ID	left join
									T0200_Monthly_Salary_Leave msl WITH (NOLOCK) on msl.Emp_ID=la.Emp_ID and msl.Increment_ID=e.Increment_ID
									and msl.L_Net_Amount=la.Leave_Salary_Amount
			where  la.cmp_ID=@Cmp_ID 
					--and ad.AD_EFFECT_ON_LEAVE=1
					and la.Month_St_Date>=@From_Date and la.Month_End_Date<=@To_Date
					and la.Leave_Salary_Amount <> 0
					and lm.Leave_Type='Encashable'
	  End
	Else if @Rpt_Format = 'Format2'    
		Begin
			Declare @Lv_Encash_Cal_On Varchar(100)    
			Set @Lv_Encash_Cal_On = ''    
    
		    Declare @Lv_Encash_W_Day Numeric(18,2)    
		    Set @Lv_Encash_W_Day = 0    
    
	   	   select @Lv_Encash_Cal_On = Lv_Encash_Cal_On,@Lv_Encash_W_Day = Lv_Encash_W_Day     
		   FROM T0040_GENERAL_SETTING WITH (NOLOCK) WHERE cmp_ID = @cmp_ID AND Branch_ID = ISNULL(@Branch_ID,Branch_ID)    
			AND For_Date = (SELECT MAX(For_Date) FROM T0040_GENERAL_SETTING WITH (NOLOCK) WHERE For_Date <=@To_Date AND Branch_ID = ISNULL(@Branch_ID,Branch_ID) AND Cmp_ID = @Cmp_ID)    
    
   if object_ID('tempdb..#Temp_report_Label') is not null    
    drop table #Temp_report_Label    
       
      CREATE TABLE #Temp_report_Label    
	   (    
		Row_ID  numeric(18, 0) NOt null,    
		AD_ID   numeric(18, 0) NOt null,    
		Label_Name  varchar(200) not null,    
		Flag Numeric(18,0) not null    
	   )    
       
	   CREATE CLUSTERED INDEX ind_temp ON #Temp_report_Label(Row_ID)    
	   CREATE NONCLUSTERED INDEX ind_temp6 ON #Temp_report_Label(Label_Name)    
       
	   if object_ID('tempdb..#Leave_Encashment') is not null    
		drop table #Leave_Encashment    
      
	   CREATE TABLE #Leave_Encashment      
	   (    
     
		Row_ID  numeric(18, 0) NOt null,    
		Cmp_ID numeric(18, 0) Not Null,    
		Emp_ID numeric(18, 0) Not Null,    
		AD_ID numeric(18, 0) Not Null,    
		AD_Short_Name varchar(500) Not Null,    
		AD_Amount Numeric(18,2),    
		Allow_Flag Numeric(18,0),    
		No_of_Days Numeric(18,2),    
		Gross_Amount numeric(18,2),    
		Net_Amount numeric(18,2),    
		For_Date Varchar(20)    
	   )    
       
	   CREATE NONCLUSTERED INDEX ind_temp2 ON #Leave_Encashment(Emp_ID)    
	   CREATE NONCLUSTERED INDEX ind_temp3 ON #Leave_Encashment(Cmp_ID)    
	   CREATE NONCLUSTERED INDEX ind_temp4 ON #Leave_Encashment(AD_ID)    
	   CREATE NONCLUSTERED INDEX ind_temp5 ON #Leave_Encashment(AD_Short_Name)    
       
	   Declare @Row_id Numeric    
       
	   INSERT INTO dbo.#Temp_report_Label(Row_ID,AD_ID, Label_Name,Flag)VALUES     (1,0,'Basic',1)    
       
	   set @Row_id = 1    
	   Select @Row_id = Max(Row_id) FROM #Temp_report_Label    
       
	   INSERT INTO dbo.#Temp_report_Label    
		(Row_ID, AD_ID,Label_Name,Flag)    
	   Select @Row_id  + ROW_NUMBER() Over (Order by Ad_level,Ad_Sort_Name),AD_ID, Ad_Sort_Name,1     
	   from (    
		 select  AD_ID, Ad_Sort_Name,Ad_level from     
		  DBO.t0050_ad_master WITH (NOLOCK)     
		 where     
		  Ad_Active = 1 and AD_Flag = 'I' and Isnull(AD_EFFECT_ON_LEAVE,0) = 1 and CMP_ID = @Cmp_ID    
		) Qry     
       
	   Declare @Cur_Cmp_ID Numeric    
	   Declare @Cur_Emp_ID Numeric    
	   Declare @Cur_Increment_ID Numeric    
	   Declare @Cur_Encash_Leave Numeric    
	   Declare @Cur_Encash_Leave_Date Varchar(20)    
       
	   Declare Cur_Emp Cursor For    
	   Select EC.Emp_ID,Increment_ID,Isnull(EL.Lv_Encash_Apr_Days,0),Lv_Encash_Apr_Date From T0120_LEAVE_ENCASH_APPROVAL EL WITH (NOLOCK) Inner Join #Emp_Cons EC     
		  ON EL.Emp_ID = EC.Emp_ID    
		  Where Lv_Encash_Apr_Date Between @From_Date And @To_Date    
	   Open Cur_Emp    
	   fetch next from Cur_Emp into @Cur_Emp_ID,@Cur_Increment_ID,@Cur_Encash_Leave,@Cur_Encash_Leave_Date    
		While @@fetch_Status = 0    
		 Begin    
		  Insert into #Leave_Encashment(Row_ID,Cmp_ID,Emp_ID,AD_ID,AD_Short_Name,AD_Amount,Allow_Flag,No_of_Days,Gross_Amount,Net_Amount,For_Date)    
		  SELECT Row_ID, @Cmp_ID,@Cur_Emp_ID,AD_ID,Label_Name,0,Flag,@Cur_Encash_Leave,0,0, Cast(DATENAME(month, @Cur_Encash_Leave_Date) as varchar(3)) + '-' + Cast(Year(@Cur_Encash_Leave_Date) as Varchar(4)) From #Temp_report_Label    
		  fetch next from Cur_Emp into @Cur_Emp_ID,@Cur_Increment_ID,@Cur_Encash_Leave,@Cur_Encash_Leave_Date    
		 End    
	   Close Cur_Emp    
	   deallocate Cur_Emp    
       
       
       
	   if object_ID('tempdb..#AD_Details') is not null    
		drop table #AD_Details    
    
	   CREATE TABLE #AD_Details    
	   (    
		Cmp_ID Numeric,    
		Emp_ID Numeric,    
		AD_ID Numeric,    
		AD_Amount Numeric(18,2),    
		AD_Effect_ON_Leave numeric    
	   )    
   
		   Insert into #AD_Details    
		   SELECT Qry.CMP_ID,Qry.EMP_ID,Qry.AD_ID,E_Ad_Amount,AD_EFFECT_ON_LEAVE    
		   FROM (    
		   SELECT EED.AD_ID,    
       
			Case When Qry1.FOR_DATE >= EED.FOR_DATE Then    
			 Case When Qry1.E_AD_PERCENTAGE IS null Then eed.E_AD_PERCENTAGE Else Qry1.E_AD_PERCENTAGE End     
			 Else    
			 eed.E_AD_PERCENTAGE End As E_AD_PERCENTAGE,    
			 Case When Qry1.FOR_DATE >= EED.FOR_DATE Then    
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
			ADM.AD_LEVEL,ADM.is_rounding,ADM.AD_EFFECT_ON_LEAVE,ADm.CMP_ID,EED.EMP_ID,ADM.AD_SORT_NAME    
		   FROM dbo.T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN                        
			   dbo.T0050_AD_MASTER ADM WITH (NOLOCK)  ON EEd.AD_ID = ADM.AD_ID   LEFT OUTER JOIN    
			 ( Select EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE     
			  From T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN    
			  ( Select Max(For_Date) For_Date, Ad_Id,EEDR_1.Emp_ID From T0110_EMP_Earn_Deduction_Revised EEDR_1  WITH (NOLOCK)
			   Inner join #Emp_Cons EC    
			   ON EC.Emp_ID = EEDR_1.EMP_ID    
			   Where For_date <= @To_Date    
			   Group by Ad_Id,EEDR_1.Emp_ID )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id     
			 ) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID And Qry1.FOR_DATE>=EED.FOR_DATE    
			Inner join #Emp_Cons EC ON EED.EMP_ID = EC.Emp_ID and EED.INCREMENT_ID = EC.Increment_ID                     
		   WHERE Adm.AD_ACTIVE = 1    
			 And Case When Qry1.ENTRY_TYPE IS null Then '' Else Qry1.ENTRY_TYPE End <> 'D'    
			 And Isnull(ADM.AD_EFFECT_ON_LEAVE,0) = 1    
		   UNION     
      
		   SELECT EED.AD_ID,E_AD_Percentage,E_AD_Amount,E_AD_Flag,E_AD_Max_Limit ,AD_Calculate_On ,AD_DEF_ID ,                        
			ISNULL(AD_NOT_EFFECT_ON_PT,0) AS AD_NOT_EFFECT_ON_PT,    
			ISNULL(AD_NOT_EFFECT_SALARY,0) AS AD_NOT_EFFECT_SALARY,    
			ISNULL(AD_EFFECT_ON_OT,0) AS AD_EFFECT_ON_OT,    
			ISNULL(AD_EFFECT_ON_EXTRA_DAY,0) AS AD_EFFECT_ON_EXTRA_DAY    
			,AD_Name,ISNULL(AD_effect_on_Late,0) AS AD_effect_on_Late ,ISNULL(AD_Effect_Month,'') AS AD_Effect_Month,    
			ISNULL(AD_CAL_TYPE,'') AS AD_CAL_TYPE,ISNULL(AD_EFFECT_FROM,'') AS AD_EFFECT_FROM,    
			ISNULL(ADM.AD_NOT_EFFECT_ON_LWP,0) AS AD_NOT_EFFECT_ON_LWP,    
			ISNULL(ADM.Allowance_Type,'A') as Allowance_Type,     
			isnull(ADM.auto_paid,0) as AutoPaid,    
			ADM.AD_LEVEL,ADM.is_rounding,ADM.AD_EFFECT_ON_LEAVE,ADm.CMP_ID,EED.EMP_ID,ADM.AD_SORT_NAME    
		   FROM dbo.T0110_EMP_EARN_DEDUCTION_REVISED EED WITH (NOLOCK) INNER JOIN      
			( Select Max(For_Date) For_Date, Ad_Id,EEDR_1.EMP_ID From T0110_EMP_Earn_Deduction_Revised EEDR_1  WITH (NOLOCK)  
			Inner join #Emp_Cons EC    
			 ON EC.Emp_ID = EEDR_1.EMP_ID    
			 Where For_date <= @To_Date     
			 Group by Ad_Id,EEDR_1.EMP_ID )Qry on EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id AND  EED.For_Date = Qry.For_Date                     
			  INNER JOIN dbo.T0050_AD_MASTER ADM WITH (NOLOCK) ON EEd.AD_ID = ADM.AD_ID      
			  INNER JOiN #Emp_Cons EC ON EC.Emp_ID = EED.EMP_ID     
			WHERE Adm.AD_ACTIVE = 1    
			 And EEd.ENTRY_TYPE = 'A' And Isnull(ADM.AD_EFFECT_ON_LEAVE,0) = 1    
		   ) Qry    
		   ORDER BY AD_LEVEL, E_AD_Flag DESC  
           
		   Update LE     
			SET LE.AD_Amount = AD.AD_Amount    
		   From #Leave_Encashment LE     
		   Inner Join #AD_Details AD    
		   ON AD.AD_ID = LE.AD_ID and AD.Emp_ID = LE.Emp_ID     
    
		   Update LE     
			SET LE.AD_Amount = I.Basic_Salary    
		   From T0095_INCREMENT I     
		   Inner JOIN #Leave_Encashment LE    
		   ON LE.Emp_ID = I.Emp_ID     
		   Inner Join #Emp_Cons EC    
		   ON I.Increment_ID = EC.Increment_ID    
		   Where LE.AD_Short_Name = 'Basic'    
    
		   Update LE    
			SET LE.Gross_Amount = Qry.AD_Amount    
		   From #Leave_Encashment LE     
		   Inner Join    
			(    
			 Select SUM(Cast(AD_Amount as numeric(18,2))) as AD_Amount,Emp_ID      
			 From #Leave_Encashment Where Allow_Flag = 1    
			 Group By Emp_ID    
			) as Qry    
		   ON LE.Emp_ID = Qry.Emp_ID   
			
				
		   
		 --  Update LE    
			--SET LE.Net_Amount = (LE.Gross_Amount * No_of_Days /  @Lv_Encash_W_Day)    
		 --  From #Leave_Encashment LE
		   --Changed By Jimit 09022018
			Update	LE    
			SET		LE.Net_Amount = (LE.Gross_Amount * No_of_Days / case when EM.Leave_Encash_Working_Days > 0 then EM.Leave_Encash_Working_Days when @Lv_Encash_W_Day > 0 Then @Lv_Encash_W_Day else 1 end)    
			From	#Leave_Encashment LE INNER JOIN
					T0080_EMP_MASTER Em ON Em.Emp_ID = Le.Emp_ID
   
   
		   Select  EM.Alpha_Emp_Code,EM.Emp_Full_Name,CM.Cmp_Name,CM.Cmp_Address,LE.* ,GRP_AMT.Grp_Amount
		   From #Leave_Encashment LE     
		   Inner Join T0080_EMP_MASTER EM WITH (NOLOCK) ON LE.Emp_ID = EM.Emp_ID    
		   Inner Join T0010_COMPANY_MASTER CM WITH (NOLOCK) ON CM.Cmp_ID = LE.Cmp_ID    
			left OUTER JOIN ( 
			select min(Emp_id) as MEmp_id, AD_ID,SUM(AD_Amount) as Grp_Amount from #Leave_Encashment 
			   group BY  AD_ID) as GRP_AMT
			ON LE.AD_ID = GRP_AMT.AD_ID   
			and LE.Emp_ID = GRP_AMT.MEmp_id
			order by EM.Emp_ID,LE.Row_ID ,GRP_AMT.AD_ID  
		End
	
		
    	RETURN 


