
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[RPT_Salary_Wages_Register_Format18]
 @Cmp_ID		numeric
,@From_Date		datetime
,@To_Date		datetime 
,@Branch_ID		numeric   = 0
,@Cat_ID		numeric  = 0
,@Grd_ID		numeric = 0
,@Type_ID		numeric  = 0
,@Dept_ID		numeric  = 0
,@Desig_ID		numeric = 0
,@Emp_ID		numeric  = 0
,@Constraint	varchar(max) = ''
,@Sal_Type		numeric 
,@Payment_Mode	varchar(20) = ''
,@PBranch_ID	varchar(max) = '0'
,@Group_Name	integer = 4  --added jimit 12052016
AS

	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON

	Declare @Payement varchar(50) 
	Declare @Transaction_ID Numeric
	
	set @Payement = ''
	set @Transaction_ID=0
	
	 if isnull(@Payement,'') = ''
		set  @Payement = ''
	Declare @Row_id as numeric
	Declare @Label_Name as varchar(100)
	Declare @Total_Allowance as numeric(22,2) 
	Declare @Is_Search as varchar(30)
	Declare @Basic_salary as numeric(22,2)
	Declare @Total_Allow as numeric (22,2)
	declare @Value_String as varchar(250)
	Declare @Amount as numeric (22,2)

	Declare @OTher_Allow as numeric(22,2)
	Declare @CO_Amount as numeric(22,2)
	Declare @Leave_Amount as numeric(22,2)
	Declare @Total_Deduction as numeric(22,2)
	Declare @Other_Dedu as numeric(22,2)
	Declare @Loan as numeric(22,2)
	Declare @Loan_Intrest as numeric(22,2)
	Declare @Advance as numeric(22,2)
	Declare @Net_Salary as numeric(22,2)
	Declare @Revenue_amt numeric(10)
	Declare @Lwf_amt numeric(10)
	Declare @PT as numeric(22,2)
	Declare @LWF as numeric(22,2)
	Declare @Revenue as numeric(22,2)
	Declare @Allow_Name as varchar(100)
	Declare @P_Days as numeric(22,2)
	Declare @A_Days as numeric(22,2)
	Declare @Act_Gross_salary as numeric(18,2)
	DEclare @month as numeric(18,0)
	Declare @Year as numeric(18,0)
	DEclare @TDS numeric(18,2)
	Declare @Settl numeric(22,2)
	Declare @Paid_Leave numeric(18,1)
	Declare @Holiday_Days Numeric
	Declare @Total_Days numeric(18,1)
	Declare @OT_Hrs numeric(18,2)
	Declare @OT_Wages numeric(22,2)
	---------Added by Hasmukh 26032013
	Declare @W_OT_Hrs numeric(18,1)
	Declare @W_OT_Wages numeric(22,2)
	Declare @H_OT_Hrs numeric(18,1)
	Declare @H_OT_Wages numeric(22,2)
	----------End Hasmukh 26032013
	--Alpesh 23-Jul-2012
	Declare @Late  numeric(22,2)
	Declare @Early  numeric(22,2)
	Declare @WeekOff numeric(22,2)
	--Alpesh 3-Aug-2012
	Declare @Arear_Days as Numeric(18,2)
	Declare @Arear_Basic As Numeric(22,6)
	Declare @Arear_Earn_Amount as Numeric(22,6)
	Declare @Arear_Dedu_Amount as Numeric(22,6)
	Declare @Arear_Net As Numeric(22,6)	
	Declare @LWP_Days as Numeric(18,2)
	Declare @Gross_Salary as Numeric(18,2)
	Declare @S_Total_Earning as Numeric(18,2)
	Declare @S_Total_Deduction as Numeric(18,2)
	Declare @Deficit_Amt Numeric(18,2) -- Added by Hardik 14/11/2013 for Pakistan
	Declare @Total_Earning_Fraction Numeric(18,2)
	Declare @Net_Salary_Round_Diff_Amount Numeric(18,2)
	
	Declare @Leave_Days as Numeric(18,2) ---added by jimit 30012017
	DECLARE @ProductionBonus_Ad_Def_Id as NUMERIC ---added by jimit 30012017
	Declare	@Ad_AMount	as numeric(18,2)
	
	Set @ProductionBonus_Ad_Def_Id=20
	--SELECT TOP 1 @ProductionBonus_Ad_Id = ad_Def_Id from T0050_AD_MASTER 
	--where cmp_Id = @cmp_Id and (Ad_Name LIKE '%Production Bonus%' or AD_SORT_NAME LIKE '%P_Bonus%')
	
	Set @LWP_Days = 0
	Set @Gross_Salary = 0
	Set @W_OT_Wages = 0
	Set @H_OT_Wages = 0
	
	DECLARE @Loan_Name as VARCHAR(50) --added by jimit 28012017
	DECLARE @Gross_Deduction as NUMERIC(18,2) --added by jimit 28012017
	
	
	IF	EXISTS (SELECT * FROM [tempdb].dbo.sysobjects where name like '#Temp_report_Label')		
		BEGIN
			DROP TABLE #Temp_report_Label
		END
	IF	EXISTS (SELECT * FROM [tempdb].dbo.sysobjects where name like '#Temp_Salary_Muster_Report')		
		BEGIN
			DROP TABLE #Temp_Salary_Muster_Report
		END
						

	--Hardik 03/06/2013 for With Arear Report for Golcha Group
	Declare @With_Arear_Amount tinyint

	Set @With_Arear_Amount = 0

	If @Sal_Type = 3 
		Begin
			Set @With_Arear_Amount = 1
			Set @Sal_Type = 0
		End

			
	
	CREATE table #Temp_report_Label
	(
		Row_ID  numeric(18, 0) NOt null,
		Label_Name  varchar(200) not null,
		Income_Tax_ID numeric(18, 0) null,
		Is_Active	varchar(1) null
	)
	
	--ALTER index idx_1 on #Temp_report_Label (Row_ID)
	Create CLUSTERED INDEX ind_temp ON #Temp_report_Label(Row_ID)
	Create NONCLUSTERED INDEX ind_temp6 ON #Temp_report_Label(Label_Name)

		
	CREATE table #Temp_Salary_Muster_Report		
	(
		Emp_ID numeric(18, 0) Not Null,
		Cmp_ID numeric(18, 0) Not Null,
		Transaction_ID numeric(18, 0) Not Null,
		Month numeric(18, 0) Not Null,
		Year numeric(18, 0) Not Null,
		Label_Name varchar(200) Not Null,
		Amount numeric(18, 2) null,
		Value_String varchar(250) Not Null,
		INCOME_TAX_ID numeric(18, 0)  Default 0,
		Row_id numeric(18, 0) Null,
		M_AD_Flage char(1),
		Rate  numeric(18, 2) Default 0,
		
	)
	Create CLUSTERED INDEX ind_temp1	ON #Temp_Salary_Muster_Report(Row_id)
	Create NONCLUSTERED INDEX ind_temp2 ON #Temp_Salary_Muster_Report(Emp_ID)
	Create NONCLUSTERED INDEX ind_temp3 ON #Temp_Salary_Muster_Report(Cmp_ID)
	Create NONCLUSTERED INDEX ind_temp4 ON #Temp_Salary_Muster_Report(Label_Name)
	Create NONCLUSTERED INDEX ind_temp5 ON #Temp_Salary_Muster_Report(Value_String)
		
	if @Branch_ID = 0
		set @Branch_ID = null
	if @Cat_ID = 0
		set @Cat_ID = null
	if @Type_ID = 0
		set @Type_ID = null
	if @Dept_ID = 0
		set @Dept_ID = null
	if @Grd_ID = 0
		set @Grd_ID = null
	if @Emp_ID = 0
		set @Emp_ID = null
		
	If @Desig_ID = 0
		set @Desig_ID = null
		
		  Declare @Sal_St_Date   Datetime    
		  Declare @Sal_end_Date   Datetime  
		  DECLARE @ROUNDING Numeric
				Set @ROUNDING = 2
		  Declare @Net_Salary_Round NUMERIC(18,2)
		  SET @Net_Salary_Round = 0
				
		  
			declare @manual_salary_period as numeric(18,0)
			set @manual_salary_period = 0	

			If @Branch_ID is null
				Begin 
					select Top 1 @Sal_St_Date  = Sal_st_Date, @ROUNDING =Ad_Rounding , @Net_Salary_Round = Net_Salary_Round, @manual_salary_Period = isnull(manual_salary_Period ,0)
					  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
					  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Cmp_ID = @Cmp_ID)    
				End
			Else
				Begin
					select @Sal_St_Date  =Sal_st_Date ,@ROUNDING =Ad_Rounding , @Net_Salary_Round = Net_Salary_Round, @manual_salary_Period = isnull(manual_salary_Period ,0)
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
				if @manual_salary_Period = 0     
					Begin       
						set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)        
						set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))     			
						Set @From_Date = @Sal_St_Date    
						Set @To_Date = @Sal_End_Date     
					end    
				else  
					begin    
						select @Sal_St_Date=from_date,@Sal_End_Date=end_date from salary_period where month= month(@From_Date) and YEAR=year(@From_Date)                  
						Set @From_Date = @Sal_St_Date    
						Set @To_Date = @Sal_End_Date        				
					End
			End


	set @month = month(@To_Date)
	set @Year = Year(@To_Date)
	  
	
	EXEC Set_Salary_Wages_register_Lable_With_Late_Format18 @Cmp_ID,@month,@Year,@From_Date,@To_Date
    	
		
	DECLARE @Ded_Max_Row_Id as NUMERIC
	Select @Row_id= Max(Row_id) FROM #Temp_report_Label  
	set      @Ded_Max_Row_Id =  @Row_id

	
	
	--SELECT * from #Temp_report_Label
	
	 CREATE TABLE #Emp_Cons 
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )   
	 
	 EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,@Sal_Type ,0 ,0,0,0,0,0,0,2,@PBranch_ID 
	      

		  
	
	DECLARE CUR_EMP CURSOR FOR
	SELECT sg.EMP_ID  FROM dbo.T0200_MONTHLY_SALARY SG WITH (NOLOCK) INNER JOIN
	T0080_EMP_MASTER E WITH (NOLOCK) ON sg.EMP_ID =e.EMP_ID 
	INNER JOIN /*	EMP_OTHER_DETAIL eod ON e.EMP_ID = eod.EMP_ID Inner join*/ #Emp_Cons ec on E.Emp_ID = Ec.Emp_ID 
	--Inner join ( select dbo.T0095_Increment.Emp_Id ,Type_ID ,Grd_ID,Dept_ID,Desig_Id,Branch_ID,Cat_ID,Payment_Mode from t0095_Increment inner join 
	--								( select max(Increment_effective_Date) as For_Date , Emp_ID from t0095_Increment
	--								where Increment_Effective_date <= @To_Date
	--								and Cmp_ID = @Cmp_ID
	--								group by emp_ID  ) Qry
	--								on t0095_Increment.Emp_ID = Qry.Emp_ID and
	--								t0095_Increment.Increment_Effective_date   = Qry.For_date	
	--						where Cmp_ID = @Cmp_ID ) I_Q on 
	--				e.Emp_ID = I_Q.Emp_ID
	WHERE  sg.Cmp_ID = @Cmp_ID 
	AND Month(sg.Month_End_Date) = @MONTH AND Year(sg.Month_End_Date) = @YEAR And isnull(sg.is_FNF,0)=0
		--AND Payment_Mode LIKE isnull(@PAYEMENT,Payment_Mode)
	OPEN  CUR_EMP
	FETCH NEXT FROM CUR_EMP INTO @EMP_ID
	WHILE @@FETCH_STATUS = 0
		BEGIN
						
						SET @Allow_Name = ''
						SET @Row_id  = 0
						SET @Label_Name  = ''
						SET @Total_Allowance = 0
						SET @Is_Search = ''
						SET @Basic_salary = 0
						SET @Total_Allow = 0
						SET @Value_String = ''
						SET @Amount = 0 
						SET @OTher_Allow =0
						set @CO_Amount = 0
						Set @Leave_Amount = 0
						SET @Total_Deduction =0
						SET @Other_Dedu =0
						SET @Loan =0
						SET @Loan_Intrest = 0
						SET @Advance =0
						SET @Net_Salary =0
						SET @PT =0
						SET @LWF =0
						SET @Revenue = 0
						set @P_Days = 0
						Set @A_Days=0
						set @Revenue_amt =0
						set @Lwf_amt  =0
						set @Act_Gross_salary = 0
						set @TDS=0
						set @Settl=0
						Set @Paid_Leave = 0
						Set @Holiday_Days = 0
						Set @Total_Days = 0 
						Set @OT_Hrs = 0
						Set @OT_Wages = 0
						Set @W_OT_Hrs = 0
						Set @W_OT_Wages = 0
						Set @H_OT_Hrs = 0
						Set @H_OT_Wages = 0
						Set @Deficit_Amt = 0
						set @Leave_Days = 0
						Declare @Sal as numeric(18,2)
						set @Sal =0
						
						Declare @GatePass_Deduct_Days numeric(18,2) -- Added by Gadriwala Muslim 09012015
						Declare @GatePass_Amount numeric(18,2) -- Added by Gadriwala Muslim 09012015
						set @GatePass_Deduct_Days = 0
						set @GatePass_Amount = 0
						
					--Added for Basic Rate should come from Increment.. Before it was taken from Salary Table..
					--Hardik 08/08/2012
					select @Sal = I.Basic_Salary from dbo.T0095_Increment I WITH (NOLOCK) inner join 
							( select max(Increment_ID) as Increment_ID from dbo.T0095_Increment	WITH (NOLOCK) -- Ankit 05092014 for Same Date Increment
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = @Cmp_ID And Emp_Id = @Emp_ID
							group by emp_ID  ) Qry on
							I.Increment_ID = Qry.Increment_ID
					Where Cmp_ID = @Cmp_ID And Emp_Id = @Emp_ID
						
						
						--Alpesh 23-Jul-2012
						SET @Late = 0
						SET @Early = 0
						SET @WeekOff = 0
						--Alpesh 3-Aug-2012		
						Set @Arear_Days = 0				
						Set @Arear_Basic = 0 
						Set @Arear_Earn_Amount = 0
						Set @Arear_Dedu_Amount = 0
						Set @Arear_Net = 0 
						Set @S_Total_Deduction = 0
						Set @S_Total_Earning = 0
						
						
					--select @P_Days = Present_Days + Holiday_Days , @Basic_Salary = Salary_Amount from Salary_Generation where Emp_ID = @Emp_ID and Month = @Month and Year = @Year
					select @P_Days = isnull(Present_Days,0)+ ISNULL(OD_Leave_Days,0) ,--@Sal=Basic_Salary,
						@A_Days = isnull(Absent_Days,0) - isnull(Late_Days,0) - isnull(Early_Days,0) ,@TDS=isnull(M_IT_TAX,0), 
						@Basic_Salary = Salary_Amount, @Act_Gross_salary = Actually_Gross_salary,@Settl = Settelement_Amount,@OTher_Allow = ISNULL(Other_Allow_Amount,0),
						@Paid_Leave = isnull(Paid_Leave_Days,0) ,@Holiday_Days = ISNULL(Holiday_Days,0),@WeekOff = ISNULL(Weekoff_Days,0),
						@Total_Days = ISNULL(Sal_Cal_Days,0),@OT_Hrs = OT_Hours,@OT_Wages = OT_Amount, 
						@W_OT_Hrs = Isnull(M_WO_OT_Hours,0),@W_OT_Wages = Isnull(M_WO_OT_Amount,0), @H_OT_Hrs = Isnull(M_HO_OT_Hours,0),@H_OT_Wages = Isnull(M_HO_OT_Amount,0),  --Added by Hasmukh 26032013
						@Late = isnull(Late_Days,0),@Early = isnull(Early_Days,0), @Arear_Days=isnull(Arear_Day,0),@Arear_Basic=ISNULL(Arear_Basic,0),
						@LWP_Days = ISNULL(Total_Leave_Days,0) - ISNULL(Paid_Leave_Days,0) - ISNULL(OD_Leave_Days,0), @Gross_Salary = isnull(Gross_Salary,0),
						@Total_Earning_Fraction = Isnull(Total_Earning_Fraction , 0) , @Net_Salary_Round_Diff_Amount = ISNULL(Net_Salary_Round_Diff_Amount,0),@GatePass_Deduct_Days = ISNULL(GatePass_Deduct_Days,0),@GatePass_Amount = ISNULL(GatePass_Amount,0) -- Added by Gadriwala Muslim 10112014
					from dbo.T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID = @Emp_ID and Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year

				
					--Hardik 03/06/2013					
					IF @With_Arear_Amount = 1
						Begin
							Select  @S_Total_Earning = SUM(S_Gross_Salary), @S_Total_Deduction = SUM(S_Total_Dedu_Amount)       
							From T0201_MONTHLY_SALARY_SETT ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
								and S_Eff_Date >=@From_Date and S_Eff_Date <=@To_Date and ms.Emp_ID = @Emp_ID
								And MS.Emp_ID In 
								(select  ms.Emp_ID
									From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
									and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and ms.Emp_ID = @Emp_ID)
							Group by ms.Emp_ID,MS.Cmp_ID,S_Eff_Date
						End


					SELECT @Row_id = ROW_ID FROM #Temp_report_Label WHERE Label_Name='Present'
					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Present', @P_Days,'',@Row_id,'P')
					
					SELECT @Row_id = ROW_ID FROM #Temp_report_Label WHERE Label_Name='Absent'
					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Absent', @A_Days,'',@Row_id,'P')
					
					--SELECT @Row_id = ROW_ID FROM #Temp_report_Label WHERE Label_Name='Late'
					--INSERT INTO dbo.#Temp_Salary_Muster_Report
					--(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage)
					--VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Late', @Late,'',@Row_id,'P')
					
					--INSERT INTO dbo.#Temp_Salary_Muster_Report
					--(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage)
					--VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Early', @Early,'',5,'P')

					--INSERT INTO dbo.#Temp_Salary_Muster_Report
					--(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage)
					--VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Leave', @Paid_Leave,'',6,'P')
					
					
					--INSERT INTO dbo.#Temp_Salary_Muster_Report
					--(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage)
					--VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'LWP', @LWP_Days,'',7,'P')

					--SELECT @Row_id = ISNULL(MAX(ROW_ID),0) FROM dbo.#TEMP_REPORT_LABEL 
					
					-----------added by jimit 01022017 for Leave
					SET @Row_id = @Row_id;
					
					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage)
					--SELECT	@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, T.Label_Name, Leave_Days,'',T.ROW_ID,'P'
					SELECT	Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, SUM(T.Leave_Days), Value_String,Row_id,M_AD_Flage
					FROM	(
								SELECT	@Emp_ID AS Emp_ID, @Cmp_ID AS Cmp_ID, @Transaction_ID AS Transaction_ID, @Month AS [Month], @Year AS [Year], T.Label_Name, T.Leave_Days,'' AS Value_String,T.ROW_ID,'P' AS M_AD_Flage
								FROM	(
											Select Row_ID,L.Label_Name,Leave_Days From 
											(SELECT Distinct LM.Leave_Code As Label_Name, Isnull(Sum(ML.Leave_Days),0) as Leave_Days 
											FROM	T0210_MONTHLY_LEAVE_DETAIL ML WITH (NOLOCK)
													INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LM.Leave_ID = ML.Leave_ID
											WHERE	Isnull(LM.Display_leave_balance,0) = 1 and LM.Cmp_ID= @Cmp_Id 
														and ML.For_Date = @From_Date AND LM.Leave_Paid_Unpaid = 'P' And ML.Leave_Days>0
														AND ML.Emp_ID=@Emp_ID
											Group by LM.Leave_Code)
													T1 LEFT OUTER JOIN #Temp_report_Label L ON T1.LABEL_NAME=L.Label_Name	
										) T	
							
								UNION ALL
								SELECT	@Emp_ID AS Emp_ID, @Cmp_ID AS Cmp_ID, @Transaction_ID AS Transaction_ID, @Month AS [Month], @Year AS [Year], T.Leave_Code AS Label_Name, T.Leave_Adj_L_Mark AS Leave_Days,'' AS Value_String,L.ROW_ID,'P' AS M_AD_Flage
								FROM	#Temp_report_Label L
										INNER JOIN (SELECT LM.Leave_Code, SUM(LT.Leave_Adj_L_Mark) AS Leave_Adj_L_Mark FROM T0040_LEAVE_MASTER LM WITH (NOLOCK)
														INNER JOIN T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) ON LT.Leave_ID=LM.Leave_ID
											WHERE ISNULL(LT.Leave_Adj_L_Mark,0) > 0 AND LT.Emp_ID=@Emp_ID 
													AND LT.FOR_DATE BETWEEN @FROM_DATE AND @To_Date
											GROUP BY LM.Leave_Code) T ON L.Label_Name=T.Leave_Code
							) T
					GROUP BY Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Value_String,Row_id,M_AD_Flage				
				
					
					----------------------------------
					--SELECT @Row_id = ISNULL(MAX(ROW_ID),0) + 1 FROM dbo.#TEMP_REPORT_LABEL 
					--SELECT * FROM #Temp_Salary_Muster_Report WHERE EMP_ID=@EMP_id ORDER BY EMP_ID,ROW_ID

					select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Holiday'  
					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Holiday', @Holiday_Days,'',@Row_ID,'P')					
					
					select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Week Off'  
					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Week Off', @WeekOff,'',@Row_ID,'P')
					
					select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Sal.Days'  
					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Sal.Days', @Total_Days,'',@Row_ID,'P')
					
					select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Arrear Days'  
					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Arrear Days', @Arear_Days,'',@Row_ID,'P')

					--select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'M.W.'  
					--INSERT INTO dbo.#Temp_Salary_Muster_Report
					--(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage)
					--VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'M.W.', 0,'',@Row_ID,'P')

					select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Basic'  
					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage,Rate)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year,'Basic', @Basic_salary,'',@Row_ID,'I',@Sal)
					
					--select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Wages'  
					--INSERT INTO dbo.#Temp_Salary_Muster_Report
					--(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage,Rate)
					--VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year,'Wages', @Basic_salary,'',@Row_ID,'I',@Basic_salary)

					--INSERT INTO dbo.#Temp_Salary_Muster_Report
					--(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage,Rate)
					--VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year,'OT Hrs.', Isnull(@OT_Hrs,0),'',15,'I',0)

					--INSERT INTO dbo.#Temp_Salary_Muster_Report
					--(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage,Rate)
					--VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year,'W OT Hrs.', Isnull(@W_OT_Hrs,0),'',16,'I',0)

					--INSERT INTO dbo.#Temp_Salary_Muster_Report
					--(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage,Rate)
					--VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year,'H OT Hrs.', Isnull(@H_OT_Hrs,0),'',17,'I',0)

					--INSERT INTO dbo.#Temp_Salary_Muster_Report
					--(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage,Rate)
					--VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year,'OT Amt', @OT_Wages,'',18,'I',0)

					--INSERT INTO dbo.#Temp_Salary_Muster_Report
					--(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage,Rate)
					--VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year,'W OT Amt', @W_OT_Wages,'',19,'I',0)

					--INSERT INTO dbo.#Temp_Salary_Muster_Report
					--(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage,Rate)
					--VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year,'H OT Amt', @H_OT_Wages,'',20,'I',0)
					
					select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Prod.Bonus'  

					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage,Rate)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year,'Prod.Bonus', 0,'',@Row_ID,'I',0)
					
					
					
					Declare Cur_Label cursor for 
						SELECT Label_Name ,Row_ID FROM dbo.#TEMP_REPORT_LABEL where Row_ID > 99  and Row_Id <>@Row_ID And
						 Row_Id NOT BETWEEN 200 and 298
					open Cur_label
					fetch next from Cur_label into @Label_Name ,@Row_ID
					while @@fetch_Status = 0
						begin
											
							INSERT INTO dbo.#Temp_Salary_Muster_Report
							(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage)
							VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, @Label_Name, 0,'',@Row_ID,'')
							fetch next from Cur_label into @Label_Name,@Row_ID							
							
						end
					close Cur_Label
					deallocate Cur_Label
					
					--select * from #TEMP_REPORT_LABEL
							
					
							--added by jimit 01022017 for Production Bonus
							SELECT	@Row_id = ROW_ID FROM dbo.#TEMP_REPORT_LABEL
							WHERE	Label_Name = 'Prod.Bonus'	

							
							UPDATE   T 						
							SET		Amount = Q.Amount
							FROM	dbo.#Temp_Salary_Muster_Report T 
									INNER JOIN (
												SELECT	DISTINCT AD_SORT_NAME ,ISNULL(SUM(M_AD_Amount),0) as Amount
												FROM	T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
														INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON MAD.AD_ID = AD.AD_ID AND MAD.Cmp_ID = AD.CMP_ID
												WHERE	MAD.Cmp_ID= @Cmp_ID 
															AND MONTH(MAD.To_date) =  @Month and YEAR(MAD.To_date) = @Year
															AND Ad_Active = 1 AND AD_Flag = 'I' AND ad_not_effect_salary = 0 AND AD_DEF_ID = @ProductionBonus_Ad_Def_Id
															AND MAD.Emp_ID = @emp_Id	
												GROUP BY Emp_ID,AD_SORT_NAME							
											  )Q On T.Label_Name = 'Prod.Bonus' 							
							WHERE	Row_id = @Row_ID AND T.EMP_ID=@EMP_ID
							---------------------------------------


					
					
					
					
					
					
					
					  Update  #Temp_Salary_Muster_Report
					  set M_AD_Flage ='I' from #Temp_Salary_Muster_Report E1
					  inner join T0050_AD_MASTER AD
					  on AD.AD_SORT_NAME =E1.Label_Name and ad.cmp_id = e1.cmp_id--Falak,Hardik,Nikunj 16-05-2011
					  where E1.Emp_ID =@Emp_ID and E1.Cmp_ID=@Cmp_ID
					   and AD.AD_Flag ='I'  		

							
					Declare @AD_Flage as char(1)
					Declare @AD_percentage as varchar(1000)
					set @Label_Name  = ''
					
					Declare @Percentage as numeric(19,2)
					Declare @M_AREAR_AMOUNT as Numeric(22,6)	--Alpesh 3-Aug-2012
					
									
						declare Cur_Allow   cursor for
						select distinct Ad_Sort_Name ,M_Ad_Amount,t0050_ad_master.AD_Flag,
						  Case 
						     when   MAD.M_AD_PERCENTAGE > 0 then MAD.M_AD_PERCENTAGE
						     Else   MAD.M_AD_Actual_per_Amount
						   End  
						   ,M_AREAR_AMOUNT	--Alpesh 3-Aug-2012  
						 from t0210_monthly_ad_detail MAD WITH (NOLOCK) inner join
							t0050_ad_master WITH (NOLOCK) on MAD.Ad_Id = t0050_ad_master.Ad_ID  inner join #Temp_Salary_Muster_Report
							on MAD.Emp_Id = #Temp_Salary_Muster_Report.Emp_ID 
							and MAD.Cmp_ID = t0050_ad_master.Cmp_Id
							and MAD.Emp_ID  = @Emp_ID
						where 
						MAD.Cmp_ID = @Cmp_ID and month(MAD.To_date) =  @Month and Year(MAD.To_date) = @Year
						and isnull(t0050_ad_master.Ad_Not_Effect_Salary,0) = 0 and Ad_Active = 1 and AD_Flag = 'I'
						and AD_DEF_ID <> @ProductionBonus_Ad_Def_Id
					open cur_allow
					fetch next from cur_allow  into @Allow_Name,@Amount,@AD_Flage,@Percentage,@M_AREAR_AMOUNT	--Alpesh 3-Aug-2012
					while @@fetch_status = 0
						begin
							
							select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like @Allow_Name --And 
							--select * From #TEMP_REPORT_LABEL where Label_Name like @Allow_Name 
							--Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID,
 							UPDATE    dbo.#Temp_Salary_Muster_Report
 							SET              Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
 												  Amount = @Amount, Value_String = '',M_AD_Flage=@AD_Flage,Rate =@Percentage
 							where   Label_Name = @Allow_Name and Row_id = @row_Id                  
 									and Emp_ID = @Emp_ID  
 									
 							Set @Arear_Earn_Amount = @Arear_Earn_Amount	+ isnull(@M_AREAR_AMOUNT,0)	--Alpesh 3-Aug-2012 
 							
 							
							fetch next from cur_allow  into @Allow_Name,@Amount,@AD_Flage,@Percentage,@M_AREAR_AMOUNT	--Alpesh 3-Aug-2012
						end
					close cur_Allow
					deallocate Cur_Allow

					
				--Select * From #Temp_Salary_Muster_Report Where emp_Id=1 And MONTH=2 And Year=2011

						select @Total_Allowance = Allow_Amount ,@Leave_Amount = Isnull(Leave_Salary_Amount,0)
							--@CO_Amount = isnull(Extra_Days_Amount,0)
						from T0200_Monthly_salary WITH (NOLOCK) where Emp_ID = @Emp_ID and Month(MOnth_St_Date) = @Month and Year(MOnth_St_Date) = @Year
					 	

						/*select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Oth A'		

						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year,
											   Amount = @Other_Allow, Value_String = ''
						where   Label_Name = 'Oth A' and Row_id = @row_Id                    
								and Emp_ID = @Emp_ID*/

						--select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'CO A'		

						--UPDATE    dbo.#Temp_Salary_Muster_Report
						--SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year,
						--					   Amount = @CO_Amount, Value_String = '',M_AD_Flage='I' 
						--where   Label_Name = 'CO A' and Row_id = @row_Id                    
						--		and Emp_ID = @Emp_ID
						
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Leave Amt'

						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
											 Amount = @Leave_Amount, Value_String = '',M_AD_Flage='I'
						WHERE     (Label_Name = 'Leave Amt') AND (Row_id = @Row_ID)
								  and Emp_ID = @Emp_ID


						If @With_Arear_Amount = 1
							Begin
								select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Settl Amt'

								UPDATE    dbo.#Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
												Value_String = '',M_AD_Flage='I', Amount = ISNULL(@S_Total_Earning,0)
								WHERE     (Label_Name = 'Settl Amt') AND (Row_id = @Row_ID)
										  and Emp_ID = @Emp_ID
							End
						Else
							Begin
								select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Settl Amt'

								UPDATE    dbo.#Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
												Value_String = '',M_AD_Flage='I', Amount = isnull(@Settl,0)
								WHERE     (Label_Name = 'Settl Amt') AND (Row_id = @Row_ID)
										  and Emp_ID = @Emp_ID
							End
						
							
						IF @With_Arear_Amount = 1	
							Begin
								select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Gross'

								UPDATE    dbo.#Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
												--	 Amount = @Total_Allowance+@Basic_Salary+isnull(@Settl,0)+ISNULL(@OTher_Allow,0)+isnull(@CO_Amount,0) + Isnull(@Leave_Amount,0)+ Isnull(@OT_Wages,0)
													Value_String = '',M_AD_Flage='I',Amount = @Gross_Salary + ISNULL(@S_Total_Earning,0) - isnull(@Settl,0)
								WHERE     (Label_Name = 'Gross') AND (Row_id = @Row_ID)
										  and Emp_ID = @Emp_ID
							End
						Else
							Begin
								select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Gross'

								UPDATE    dbo.#Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
												--	 Amount = @Total_Allowance+@Basic_Salary+isnull(@Settl,0)+ISNULL(@OTher_Allow,0)+isnull(@CO_Amount,0) + Isnull(@Leave_Amount,0)+ Isnull(@OT_Wages,0)
													Value_String = '',M_AD_Flage='I',Amount = @Gross_Salary
								WHERE     (Label_Name = 'Gross') AND (Row_id = @Row_ID)
										  and Emp_ID = @Emp_ID
							End
						
						IF @ROUNDING = 0 And @Total_Earning_Fraction <> 0 
							Begin	
							
								select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Gross Round'

								UPDATE    dbo.#Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
												 Value_String = '',M_AD_Flage='I',Amount = Isnull(@Total_Earning_Fraction,0)
								WHERE     (Label_Name = 'Gross Round') AND (Row_id = @Row_ID)
										  and Emp_ID = @Emp_ID
								
								select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Total Gross'
								
								UPDATE    dbo.#Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
												 Value_String = '',M_AD_Flage='I',Amount = ISNULL(@Gross_Salary,0) + Isnull(@Total_Earning_Fraction,0)
								WHERE     (Label_Name = 'Total Gross') AND (Row_id = @Row_ID)
										  and Emp_ID = @Emp_ID
							End		  
						ELse
							Begin
								
								select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Gross Round'

								UPDATE    dbo.#Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
												 Value_String = '',M_AD_Flage='I'--,Amount = Isnull(@Total_Earning_Fraction,0)
								WHERE     (Label_Name = 'Gross Round') AND (Row_id = @Row_ID)
										  and Emp_ID = @Emp_ID
								
								select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Total Gross'
								
								UPDATE    dbo.#Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
												 Value_String = '',M_AD_Flage='I'--,Amount = ISNULL(@Gross_Salary,0) + Isnull(@Total_Earning_Fraction,0)
								WHERE     (Label_Name = 'Total Gross') AND (Row_id = @Row_ID)
										  and Emp_ID = @Emp_ID
							End
							
						/*select @Amount = M_Ad_Calculated_Amount From t0210_monthly_ad_detail where Emp_Id =@Emp_ID and Month(For_Date)=  @month and YEar(For_Date) = @Year and Ad_ID =2
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'PF Salary'	*/	
					
						
						/*UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year,
											   Amount = @Amount, Value_String = ''
						where   Label_Name = 'PF Salary' and Row_id = @row_Id                    
								and Emp_ID = @Emp_ID
								*/
						set @Amount =0

						/*select @Amount = M_AD_Calculated_Amount From t0210_monthly_ad_detail where Emp_Id = @Emp_ID and Month(For_Date)=  @month and YEar(For_Date) = @Year and Ad_ID =3 and M_Ad_Amount >0
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'ESIC Salary'
						
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year,
											   Amount = @Amount, Value_String = ''
						where   Label_Name = 'ESIC Salary' and Row_id = @row_Id                    
								and Emp_ID = @Emp_ID*/
					
					Declare @S_Total_Deduction_1 as Numeric(18,2)
					Set @S_Total_Deduction_1 = 0
					Declare @AD_Id as Numeric

					
					
					
					
					declare Cur_Dedu   cursor for
						select distinct  t0050_ad_master.AD_ID,Ad_Sort_Name ,M_Ad_Amount,t0050_ad_master.AD_Flag,  
						   Case 
						     when   t0050_ad_master.AD_PERCENTAGE > 0 then t0050_ad_master.AD_PERCENTAGE
						     Else   MAD.M_AD_Actual_Per_Amount
						   End 
						   ,M_AREAR_AMOUNT	--Alpesh 3-Aug-2012
						  from t0210_monthly_ad_detail MAD WITH (NOLOCK) inner join
							t0050_ad_master WITH (NOLOCK) on MAD.Ad_Id = t0050_ad_master.Ad_ID inner  join #Temp_Salary_Muster_Report
							on MAD.Emp_Id = #Temp_Salary_Muster_Report.Emp_ID 
							and MAD.Cmp_ID = t0050_ad_master.Cmp_Id
							and MAD.Emp_ID  = @Emp_ID
						where 
						MAD.Cmp_ID = @Cmp_ID and Month(MAD.To_date) =  @Month and Year(MAD.To_date) = @Year
						and Ad_Active = 1 and AD_Flag = 'D' and isnull(t0050_ad_master.Ad_Not_Effect_Salary,0)=0 
					open Cur_Dedu
					fetch next from cur_DEDU  into @Ad_Id, @Allow_Name ,@Amount,@AD_Flage,@Percentage,@M_AREAR_AMOUNT	--Alpesh 3-Aug-2012
					while @@fetch_status = 0
						begin
							Set @S_Total_Deduction_1 = 0
							
							If @With_Arear_Amount = 1
								Begin
									
									Select  @S_Total_Deduction_1 = Isnull(SUM(M_AD_Amount),0)  
									From t0210_monthly_ad_detail MAD WITH (NOLOCK) inner join
										T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK) on MAD.Sal_Tran_ID=MSS.Sal_Tran_ID inner join 
										T0050_AD_MASTER WITH (NOLOCK) on MAD.Ad_Id = T0050_AD_MASTER.Ad_ID
										and MAD.Cmp_ID = T0050_AD_MASTER.Cmp_Id
									Where MAD.Cmp_ID = @Cmp_ID and month(MSS.S_Eff_Date) =  MONTH(@To_Date) and Year(MSS.S_Eff_Date) = YEAR(@To_Date)
										and isnull(T0050_AD_MASTER.Ad_Not_Effect_Salary,0) = 0 and Ad_Active = 1 
										and AD_Flag = 'D' And Sal_Type = 1
										And MAD.AD_ID = @Ad_Id And MAD.Emp_ID  = @Emp_ID
								End
						
								select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like @Allow_Name 
								UPDATE    dbo.#Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Amount + Isnull(@S_Total_Deduction_1,0), 
												  Value_String = '',M_AD_Flage=@AD_Flage,Rate =@Percentage
								WHERE     (Label_Name = @Allow_Name) AND (Row_id = @Row_ID) and Emp_ID = @Emp_ID
									
							Set @Arear_Dedu_Amount = @Arear_Dedu_Amount	+ isnull(@M_AREAR_AMOUNT,0)	--Alpesh 3-Aug-2012 
							
																
							fetch next from cur_DEDU  into @Ad_Id, @Allow_Name ,@Amount,@AD_Flage,@Percentage,@M_AREAR_AMOUNT	--Alpesh 3-Aug-2012
						end
					close Cur_Dedu
					deallocate Cur_Dedu
					
					Set @Arear_Net = (@Arear_Basic + @Arear_Earn_Amount) - @Arear_Dedu_Amount	--Alpesh 3-Aug-2012
					
					
					Select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Arrear Amt'

					UPDATE    dbo.#Temp_Salary_Muster_Report
					SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
										 Amount = @Arear_Net, Value_String = '',M_AD_Flage='I'
					WHERE     (Label_Name = 'Arrear Amt') AND (Row_id = @Row_ID) and Emp_ID = @Emp_ID

						
						
					-- Select * from #Temp_Salary_Muster_Report
					  Update  #Temp_Salary_Muster_Report
					  set M_AD_Flage ='D' from #Temp_Salary_Muster_Report E1
					  inner join T0210_MONTHLY_AD_DETAIL E on E1.Emp_ID =E.Emp_ID inner join T0050_AD_MASTER AD
					  on AD.AD_ID =E.AD_ID where E1.Emp_ID =@Emp_ID and E1.Cmp_ID=@Cmp_ID
					   and E1.M_AD_Flage ='' 
					
					  Update  #Temp_Salary_Muster_Report
					  set M_AD_Flage =AD_Flag from #Temp_Salary_Muster_Report E1
					  inner join T0050_AD_MASTER AD
					  on AD.Ad_Sort_Name =E1.Label_Name where E1.Emp_ID =@Emp_ID and E1.Cmp_ID=@Cmp_ID
					   and E1.M_AD_Flage ='' 
					 
					   

						select @Total_Deduction = Total_Dedu_Amount ,@PT = PT_Amount ,@Loan =  isnull(Loan_Amount,0) ,@Loan_Intrest = isnull(Loan_Intrest_Amount,0) ---Split Loan & intrest done by Hasmukh 13112013
								,@Advance =  Advance_Amount ,@Net_Salary = Net_Amount ,@Revenue_Amt =Revenue_amount,@LWF_Amt =LWF_Amount,@Other_Dedu=Other_Dedu_Amount,
								@Deficit_Amt = Isnull(Deficit_Dedu_Amount,0)
						from T0200_Monthly_salary WITH (NOLOCK) where Emp_ID = @Emp_ID and Month(Month_End_Date) = @Month and Year(Month_End_Date) = @Year
						--Select @Other_Dedu  = 0
						
					--	set @Loan = @Loan + @Advance

		--				select @Row_ID = Row_ID from Temp_report_label where Label_Name like 'Other Dedu'

		--				INSERT INTO Temp_Salary_Muster_Report


		--						   (Emp_ID, Company_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id)
		--				VALUES     (@Emp_ID, @Company_ID, @Transaction_ID, @Month, @Year, 'Other Dedu', @Other_Dedu,'',@Row_ID)
						
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'PT'
						
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @PT, 
											  Value_String = '',M_AD_Flage='D'
						WHERE     (Label_Name = 'PT') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
								
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'LWF'
						
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Lwf_amt, 
											  Value_String = '',M_AD_Flage='D'
						WHERE     (Label_Name = 'LWF') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
						
						--select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Loan'
						
						--UPDATE    dbo.#Temp_Salary_Muster_Report
						--SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Loan, 
						--					  Value_String = '',M_AD_Flage='D'
						--WHERE     (Label_Name = 'Loan') AND (Row_id = @Row_ID)
						--		and Emp_ID = @Emp_ID
						
						--select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Loan Int'
						
						--UPDATE    dbo.#Temp_Salary_Muster_Report
						--SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Loan_intrest, 
						--					  Value_String = '',M_AD_Flage='D'
						--WHERE     (Label_Name = 'Loan Int') AND (Row_id = @Row_ID)
						--		and Emp_ID = @Emp_ID	
						
						
						 -------------------added by jimit 28012017 For Loan---------------------------------      
						
						--SELECT * FROM DBO.#TEMP_SALARY_MUSTER_REPORT
						
						
						SET @ROW_ID = 200				
						     
						INSERT INTO DBO.#TEMP_SALARY_MUSTER_REPORT
						(EMP_ID, CMP_ID, TRANSACTION_ID, MONTH, YEAR, LABEL_NAME, AMOUNT, VALUE_STRING,ROW_ID,M_AD_FLAGE)
						SELECT	@EMP_ID, @CMP_ID, @TRANSACTION_ID, @MONTH, @YEAR, T.LABEL_NAME,T.LOAN_PAY_AMOUNT,'',ROW_ID,'D'
						FROM	(
									SELECT  L.Row_ID,L.LABEL_NAME,T1.LOAN_PAY_AMOUNT									
									FROM(		
											SELECT	DISTINCT LOAN_SHORT_NAME AS LABEL_NAME,ISNULL(SUM(LOAN_PAY_AMOUNT),0) AS LOAN_PAY_AMOUNT						
											FROM	V0210_MONTHLY_LOAN_PAYMENT       
											WHERE   CMP_ID = @CMP_ID AND MONTH(LOAN_PAYMENT_DATE) = @MONTH AND YEAR(LOAN_PAYMENT_DATE) = @YEAR 
													AND LOAN_SHORT_NAME <> ''		
													AND	EMP_ID = @EMP_ID
													AND LOAN_PAY_AMOUNT <> 0
																									
											GROUP BY LOAN_SHORT_NAME										
										) T1 LEFT OUTER JOIN #Temp_report_Label L ON T1.LABEL_NAME=L.Label_Name									
							 ) T
						
						
						
						SET @ROW_ID = 250				
						
											
						
						
						INSERT INTO DBO.#TEMP_SALARY_MUSTER_REPORT
						(EMP_ID, CMP_ID, TRANSACTION_ID, MONTH, YEAR, LABEL_NAME, AMOUNT, VALUE_STRING,ROW_ID,M_AD_FLAGE)
						SELECT	@EMP_ID, @CMP_ID, @TRANSACTION_ID, @MONTH, @YEAR, T.LABEL_NAME,T.LOAN_INTEREST_AMOUNT,'',ROW_ID,'D'
						FROM	(
									SELECT  L.Row_ID,L.LABEL_NAME,T1.LOAN_INTEREST_AMOUNT									
									FROM(		
											SELECT	DISTINCT (LOAN_SHORT_NAME + ' Int') AS LABEL_NAME,ISNULL(SUM(INTEREST_AMOUNT),0) AS LOAN_INTEREST_AMOUNT						
											FROM	V0210_MONTHLY_LOAN_PAYMENT       
											WHERE   CMP_ID = @CMP_ID AND MONTH(LOAN_PAYMENT_DATE) = @MONTH AND YEAR(LOAN_PAYMENT_DATE) = @YEAR 
													AND LOAN_SHORT_NAME <> ''		
													AND	EMP_ID = @EMP_ID
													AND INTEREST_AMOUNT <> 0
																									
											GROUP BY LOAN_SHORT_NAME										
										) T1 LEFT OUTER JOIN #Temp_report_Label L ON T1.LABEL_NAME=L.Label_Name									
							 ) T
						
												
						--SELECT * FROM dbo.#TEMP_REPORT_LABEL								
						--SELECT * FROM DBO.#TEMP_SALARY_MUSTER_REPORT
						--RETURN
						-------------------ended-----------------------
						
													
								
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Advance'
						
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Advance, 
											  Value_String = '',M_AD_Flage='D'
						WHERE     (Label_Name = 'Advance') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
						
						
						
						--if @Revenue_Amt >0
							--begin
								--select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Revenue'
								
								--UPDATE    dbo.#Temp_Salary_Muster_Report
								--SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Revenue_Amt, 
								--					  Value_String = '', M_AD_Flage ='P'
								--WHERE     (Label_Name = 'Revenue') AND (Row_id = @Row_ID)
								--		and Emp_ID = @Emp_ID
										
							--end
							--Else
							 --begin
								--select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Revenue'
								
								--UPDATE    dbo.#Temp_Salary_Muster_Report
								--SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Revenue_Amt, 
								--					  Value_String = '', M_AD_Flage ='D'
								--WHERE     (Label_Name = 'Revenue') AND (Row_id = @Row_ID)
								--		and Emp_ID = @Emp_ID
										
							--end
							
						--if @LWF_amt > 0
							--begin
							--	select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'LWF'
								
							--	UPDATE    dbo.#Temp_Salary_Muster_Report
								--SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @lwf_Amt, 
								--					  Value_String = '',M_AD_Flage ='P'
							--	WHERE     (Label_Name = 'LWF') AND (Row_id = @Row_ID)
							--			and Emp_ID = @Emp_ID
							--end		
						  --else
						   -- begin
								--select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'LWF'
								
								--UPDATE    dbo.#Temp_Salary_Muster_Report
								--SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @lwf_Amt, 
								--					  Value_String = '',M_AD_Flage ='D'
								--WHERE     (Label_Name = 'LWF') AND (Row_id = @Row_ID)
								--		and Emp_ID = @Emp_ID
							--end							
								
					
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'TDS'
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @TDS, 
											  Value_String = '',M_AD_Flage='D'
						WHERE     (Label_Name = 'TDS') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID

						--- Fine is zero and damages is zero, This is for show on report only						
						--select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Fine'
						--UPDATE    dbo.#Temp_Salary_Muster_Report
						--SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = 0, 
						--					  Value_String = '',M_AD_Flage='D'
						--WHERE     (Label_Name = 'Fine') AND (Row_id = @Row_ID)
						--		and Emp_ID = @Emp_ID

						--select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Loss or Damage'
						--UPDATE    dbo.#Temp_Salary_Muster_Report
						--SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = 0, 
						--					  Value_String = '',M_AD_Flage='D'
						--WHERE     (Label_Name = 'Loss or Damage') AND (Row_id = @Row_ID)
						--		and Emp_ID = @Emp_ID

						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Oth De'
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Other_Dedu, 
											  Value_String = '',M_AD_Flage='D'
						WHERE     (Label_Name = 'Oth De') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
						
						--Added by gadriwala Muslim 09012015 - Start		
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Gate Pass'
								UPDATE    dbo.#Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @GatePass_Amount, 
											  Value_String = '',M_AD_Flage='D'
								WHERE     (Label_Name = 'Gate Pass') AND (Row_id = @Row_ID)
									and Emp_ID = @Emp_ID
						
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Deficit Amt'
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Deficit_Amt, 
											  Value_String = '',M_AD_Flage='D'
						WHERE     (Label_Name = 'Deficit Amt') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID

						If @With_Arear_Amount = 1
							Begin
								select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Dedu'
								
								UPDATE    dbo.#Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
													  Amount = @Total_Deduction + ISNULL(@S_Total_Deduction,0), Value_String = '',M_AD_Flage='D'
								WHERE     (Label_Name = 'Dedu') AND (Row_id = @Row_ID)
										and Emp_ID = @Emp_ID	
							End
						Else
							Begin
								select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Dedu'
								
								UPDATE    dbo.#Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
													  Amount = @Total_Deduction, Value_String = '',M_AD_Flage='D'
								WHERE     (Label_Name = 'Dedu') AND (Row_id = @Row_ID)
										and Emp_ID = @Emp_ID	
							End
							
								
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Net'
						
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Net_Salary, 
											  Value_String = '',M_AD_Flage='N'
						WHERE     (Label_Name = 'Net') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
								
						IF  @Net_Salary_Round <> -1 --@ROUNDING = 0 AND
							Begin	
								select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Net'
						
								UPDATE    dbo.#Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = Isnull(@Net_Salary,0) - Isnull(@Net_Salary_Round_Diff_Amount,0), 
													  Value_String = '',M_AD_Flage='N'
								WHERE     (Label_Name = 'Net') AND (Row_id = @Row_ID)
										and Emp_ID = @Emp_ID
											
								select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Net Round'
								
								UPDATE    dbo.#Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = Isnull(@Net_Salary_Round_Diff_Amount,0), 
													  Value_String = '',M_AD_Flage='N'
								WHERE     (Label_Name = 'Net Round') AND (Row_id = @Row_ID)
										and Emp_ID = @Emp_ID
										
								select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Total Net'
						
								UPDATE    dbo.#Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Net_Salary, 
													  Value_String = '',M_AD_Flage='N'
								WHERE     (Label_Name = 'Total Net') AND (Row_id = @Row_ID)
										and Emp_ID = @Emp_ID		
										
								--IF @Net_Salary_Round_Diff_Amount = 0 
								--	BEGIN
								--		DELETE FROM  dbo.#Temp_Salary_Muster_Report
								--		WHERE Label_Name = 'Total Net'
								--	END
								
							End
							
							 
											
							
							
							
			FETCH NEXT FROM CUR_EMP INTO @EMP_ID
		END
	Close Cur_Emp
	Deallocate Cur_emp	
	
	
	INSERT	INTO DBO.#TEMP_SALARY_MUSTER_REPORT(ROW_ID,EMP_ID,CMP_ID,TRANSACTION_ID,Month,Year,Value_String,M_AD_Flage,LABEL_NAME,AMOUNT)
	SELECT	T.ROW_ID,T2.EMP_ID,@CMP_ID,0,@Month,@Year,'',T.M_AD_Flage,Label_Name, 0
	FROM	(SELECT DISTINCT Emp_ID FROM #TEMP_SALARY_MUSTER_REPORT ) T2 
			CROSS JOIN (
							SELECT	DISTINCT ROW_ID,M_AD_Flage,Label_Name
							FROM	#TEMP_SALARY_MUSTER_REPORT T 
						) T 
	WHERE	NOT EXISTS(SELECT 1 FROM #TEMP_SALARY_MUSTER_REPORT T1 WHERE T1.Label_Name = T.Label_Name AND T2.Emp_ID=T1.Emp_ID)

		
	
	-- Changed By Ali 22112013 EmpName_Alias
	select dbo.#Temp_Salary_Muster_Report.* ,ISNULL(E.EmpName_Alias_Salary,E.Emp_Full_Name) as Emp_Full_Name,E.Emp_Code,E.Alpha_Emp_Code,GM.Grd_name,ETM.Type_name,DGM.Desig_Name,DM.Dept_Name,BM.Branch_Name, 
		ISnull(Inc_Qry.Dept_ID,0) as Dept_ID,Cmp_Name,Cmp_Address,isnull(Inc_Qry.Inc_Bank_Ac_no,0)Inc_Bank_Ac_no,isnull(Inc_Qry.Payment_Mode,'') as Payment_Mode,
		E.SSN_No As PF_No, E.SIN_No As ESIC_No, E.Gender, BM.Comp_Name,BM.Branch_Address,BM.Branch_City, CM.PF_No AS Cmp_PF_No,CM.ESIC_No AS Cmp_ESIC_No,
		@From_Date As From_Date,@To_Date As To_Date, cm.cmp_logo,
		(Select AD_PERCENTAGE from T0050_AD_MASTER WITH (NOLOCK) Where CMP_ID = E.Cmp_ID And AD_DEF_ID = 2 and AD_CALCULATE_ON = 'Basic Salary') As PF_RATE, Day_Salary,E.Father_name
		,ISNULL(Inc_Qry.Master_Gross_Salary,0) As Master_Gross_Salary	--Ankit 10032014
		,IsNUll(DM.Dept_Dis_no,0) as Dept_Dis_no   --added jimit 05082015
		,DGM.Desig_Dis_No      ---added jimit 24082015
		,IsNull(Gm.Grd_ID,0) as Grd_ID,IsNull(ETM.[Type_ID],0) as [Type_ID]  ---added jimit 12052016
		,IsNull(BM.Branch_ID,0) as Branch_ID		---added jimit 12052016
		,vertical_Name,Sv.SubVertical_Name			---added jimit 12052016
		,Isnull(vs.vertical_Id,0) as vertical_Id,IsNull(Sv.SubVertical_ID,0) as subvertical_Id   ---added jimit 12052016
		,Isnull(DGM.Desig_ID,0) as Desig_ID			---added jimit 12052016
		,DM.Dept_Code
	into #Temp_Salary_Muster_Report1  -----Add Jignesh 04-Sep-2012
	
	from dbo.#Temp_Salary_Muster_Report Inner join 
	
		T0080_Emp_Master E WITH (NOLOCK) on dbo.#Temp_Salary_Muster_Report.Emp_Id = E.Emp_ID inner join
		( select I.Emp_Id ,Grd_ID,DEsig_ID ,Dept_ID,Inc_Bank_Ac_no,Branch_ID,Type_ID,I.Vertical_ID,I.SubVertical_ID,
		--Payment_Mode 
		case when @Payment_Mode = '' then 'ALL' else Payment_Mode end as Payment_Mode,Gross_Salary As Master_Gross_Salary
		from t0095_Increment I WITH (NOLOCK) inner join 
					( 
					select max(Increment_ID) as Increment_ID, Emp_ID from t0095_Increment WITH (NOLOCK) -- Ankit 05092014 for Same Date Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					and (Increment_Type <> 'Transfer' or Increment_Type <> 'Deputation')
					group by emp_ID  
					) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID 
			)Inc_Qry on 
		E.Emp_ID = Inc_Qry.Emp_ID left outer join t0040_department_Master WITH (NOLOCK)
		on Inc_Qry.dept_ID = t0040_department_Master.Dept_ID LEFT OUTER JOIN
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON Inc_Qry.Grd_ID = GM.Grd_ID				LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON Inc_Qry.Type_ID = ETM.Type_ID			LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Inc_Qry.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Inc_Qry.Dept_Id = DM.Dept_Id		INNER JOIN 
					T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Inc_Qry.BRANCH_ID = BM.BRANCH_ID
		 inner join t0010_company_master CM WITH (NOLOCK) on E.cmp_id=CM.cmp_id
		 Left Outer Join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on #Temp_Salary_Muster_Report.Emp_ID = MS.Emp_ID And #Temp_Salary_Muster_Report.Month = Month(MS.Month_End_Date) And #Temp_Salary_Muster_Report.Year = Year(MS.Month_End_Date)
		  Left OUTER JOIN T0040_Vertical_Segment Vs WITH (NOLOCK) on vs.Vertical_ID = Inc_Qry.Vertical_ID 
		 Left Outer JOIN T0050_SubVertical Sv WITH (NOLOCK) On sv.SubVertical_ID = Inc_Qry.SubVertical_ID
		 Where Label_Name not in 
			(select label_name from #Temp_Salary_Muster_Report 
				Where Row_id > 19 And Label_Name <> 'Loan' And Label_Name <> 'Loan Int' And Label_Name <> 'Advance' And Label_Name <> 'LWF' And Label_Name <> 'PT' And Label_Name <> 'Fine' And Label_Name <> 'Loss or Damage'
			group by Label_Name having sum(Amount) = 0 ) 
		
		-----Modify Jignesh 04-Sep-2012
		and (@Payment_Mode ='' or isnull(Inc_Qry.Payment_Mode,'')=@Payment_Mode)
		-----End---------- 
		order by Emp_code,Row_ID--,Label_Name
	
	
	/* ----- Comment By Jignesh 04-Sep-2012------------------		
	Select * From (Select Label_Name,Row_Id, M_ad_Flage
		 from dbo.#Temp_Salary_Muster_Report TMP
		 Where Label_Name not in 
			(
			select label_name from #Temp_Salary_Muster_Report 
			Where Row_id > 19 And Label_Name <> 'Loan' And Label_Name <> 'Advance' And Label_Name <> 'LWF' And Label_Name <> 'PT' And Label_Name <> 'Fine' And Label_Name <> 'Loss or Damage'
		 	group by Label_Name having sum(Amount) = 0 
			) 
	Group by Label_Name,Row_Id,M_ad_Flage) Qry 
	Order By Row_Id,Label_Name
		
	Select * From (Select Label_Name,Row_Id, M_ad_Flage, SUM(Amount) As Total_Amt
		 from dbo.#Temp_Salary_Muster_Report TMP
		 Where Label_Name not in 
			(
			select label_name from #Temp_Salary_Muster_Report 
			Where Row_id > 19 And Label_Name <> 'Loan' And Label_Name <> 'Advance' And Label_Name <> 'LWF' And Label_Name <> 'PT' And Label_Name <> 'Fine' And Label_Name <> 'Loss or Damage'
			group by Label_Name having sum(Amount) = 0 
			) 
	Group by Label_Name,Row_Id,M_ad_Flage) Qry 
	Order By Row_Id,Label_Name
*/-----End---------- 

	
	declare @Pf_Def_Id  as numeric 
	declare @Esic_Def_Id  as numeric
	declare @ad_Name_Esic as varchar(20)
	declare	@ad_Name_Pf as varchar(20)
	
	set @Pf_Def_Id = 2
	set @Esic_Def_Id = 3
	
	select top 1 @ad_Name_Esic = upper(ad_sort_Name)
	from t0050_AD_Master WITH (NOLOCK) where ad_def_Id = @Esic_Def_Id and cmp_Id = @Cmp_Id
	
	select top 1 @ad_Name_Pf = upper(ad_sort_Name)
	from t0050_AD_Master WITH (NOLOCK) where ad_def_Id = @Pf_Def_Id and cmp_Id = @Cmp_Id
	
	--select COUNT(emp_Id) as Pf_COunt, cast(CASE WHEN ISNUMERIC(Dept_Code) = 1 THEN Dept_Code ELSE 0 END as Numeric) as Dept_Code
	--from #TEMP_SALARY_MUSTER_REPORT1 
	--where label_Name in (select top 1 ad_sort_Name from t0050_AD_Master where ad_def_Id = @Pf_Def_Id) and amount <> 0 
	--Group by dept_Code
	--return
		
			
	If @group_Name = 0
		BEGIN
				select T.*,RIGHT(REPLICATE(N' ', 500) + T.Alpha_EMP_CODE, 500) as ord_code ,
						q.Pf_COunt,q1.ESIC_COunt,q2.ESIC_WAGES
				from #Temp_Salary_Muster_Report1 T Left Outer join
				(
					select COUNT(emp_Id) as Pf_COunt, grd_Id from #TEMP_SALARY_MUSTER_REPORT1 
					where upper(label_Name) = @ad_Name_Pf and amount <> 0 and cmp_Id = @Cmp_Id
					Group by grd_Id
				)Q On Q.grd_Id = T.grd_Id
				Left Outer join
				(
					select COUNT(emp_Id) as ESIC_COunt,grd_Id from #TEMP_SALARY_MUSTER_REPORT1 
					where upper(label_Name) = @ad_Name_Esic and amount <> 0 and cmp_Id = @Cmp_Id
					Group by grd_Id
				)Q1 On Q1.grd_Id = T.grd_Id
				Left Outer join
					(
						select sum(M_AD_Calculated_Amount) as ESIC_WAGES,grd_Id 
						from #TEMP_SALARY_MUSTER_REPORT1 T1 left Join							 
							 t0210_Monthly_Ad_Detail Mad WITH (NOLOCK) on Mad.emp_Id = T1.emp_Id and t1.month = month(@To_DAte) and t1.year = year(@To_DAte)	inner join
							 T0050_AD_MASTER Am WITH (NOLOCK) On Am.AD_ID = mad.AD_ID						 
						where  amount <> 0
								and  ad_def_Id = @Esic_Def_Id and t1.cmp_Id = @Cmp_Id
								and upper(label_Name) = @ad_Name_Esic and month(for_date) = month(@To_date) and year(for_date) =year(@To_DAte)
						Group by grd_Id
					)Q2 On Q2.grd_Id = T.grd_Id					
				Order by Case When IsNumeric(Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + Alpha_Emp_Code, 20)
						When IsNumeric(Alpha_Emp_Code) = 0 then Left(Alpha_Emp_Code + Replicate('',21), 20)
							Else Alpha_Emp_Code
						End ,Row_ID
		END
	else if  @group_Name = 1
		BEGIN
				select T.*,RIGHT(REPLICATE(N' ', 500) + T.Alpha_EMP_CODE, 500) as ord_code ,
						q.Pf_COunt,q1.ESIC_COunt,q2.ESIC_WAGES
				from #Temp_Salary_Muster_Report1 T Left Outer join
					(
						select COUNT(emp_Id) as Pf_COunt, [type_Id] from #TEMP_SALARY_MUSTER_REPORT1 
						where upper(label_Name) = @ad_Name_Pf and amount <> 0 and cmp_Id = @Cmp_Id
						Group by [type_Id]
					)Q On Q.[type_Id] = T.[type_Id]
					Left Outer join
					(
						select COUNT(emp_Id) as ESIC_COunt, [type_Id] from #TEMP_SALARY_MUSTER_REPORT1 
						where upper(label_Name) = @ad_Name_Esic and amount <> 0 and cmp_Id = @Cmp_Id
						Group by  [type_Id]
					)Q1 On Q1. [type_Id] = T. [type_Id]
					Left Outer join
					(
						select sum(M_AD_Calculated_Amount) as ESIC_WAGES,[type_Id] 
						from #TEMP_SALARY_MUSTER_REPORT1 T1 left Join							 
							 t0210_Monthly_Ad_Detail Mad WITH (NOLOCK) on Mad.emp_Id = T1.emp_Id and t1.month = month(@To_DAte) and t1.year = year(@To_DAte)	inner join
							 T0050_AD_MASTER Am WITH (NOLOCK) On Am.AD_ID = mad.AD_ID						 
						where  t1.cmp_Id = @Cmp_Id and amount <> 0
								and  ad_def_Id = @Esic_Def_Id
								and upper(label_Name) = @ad_Name_Esic and month(for_date) = month(@To_date) and year(for_date) =year(@To_DAte)
						Group by [type_Id]
					)Q2 On Q2.[type_Id] = T.[type_Id]	
				Order by Case When IsNumeric(Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + Alpha_Emp_Code, 20)
						When IsNumeric(Alpha_Emp_Code) = 0 then Left(Alpha_Emp_Code + Replicate('',21), 20)
							Else Alpha_Emp_Code
						End ,Row_ID
		END	
	else if  @group_Name = 2
		BEGIN
			If exists(Select 1 from  #TEMP_SALARY_MUSTER_REPORT1 where ISNUMERIC(Dept_Code) > 0)
				Begin					
					select T.*,RIGHT(REPLICATE(N' ', 500) + T.Alpha_EMP_CODE, 500) as ord_code ,
							q.Pf_COunt,q1.ESIC_COunt,q2.ESIC_WAGES
					from #Temp_Salary_Muster_Report1 T Left Outer join
						(
							select COUNT(emp_Id) as Pf_COunt, cast(CASE WHEN ISNUMERIC(Dept_Code) = 1 THEN Dept_Code ELSE 0 END as Numeric) as Dept_Code
							from #TEMP_SALARY_MUSTER_REPORT1 
							where upper(label_Name) = @ad_Name_Pf and amount <> 0 and cmp_Id = @Cmp_Id
							Group by label_Name,dept_Code
						)Q On cast(CASE WHEN ISNUMERIC(Q.Dept_Code) = 1 THEN Q.Dept_Code ELSE 0 END as Numeric) = cast(CASE WHEN ISNUMERIC(T.Dept_Code) = 1 THEN T.Dept_Code ELSE 0 END as Numeric)
						Left Outer join
						(
							select COUNT(emp_Id) as ESIC_COunt,cast(CASE WHEN ISNUMERIC(Dept_Code) = 1 THEN Dept_Code ELSE 0 END as Numeric) as Dept_Code 
							from #TEMP_SALARY_MUSTER_REPORT1 
							where upper(label_Name) = @ad_Name_Esic and amount <> 0 and cmp_Id = @Cmp_Id
							Group by label_Name,dept_Code
						)Q1 On cast(CASE WHEN ISNUMERIC(Q1.Dept_Code) = 1 THEN Q1.Dept_Code ELSE 0 END as Numeric) = cast(CASE WHEN ISNUMERIC(T.Dept_Code) = 1 THEN T.Dept_Code ELSE 0 END as Numeric)
						Left Outer join
					(
						select sum(M_AD_Calculated_Amount) as ESIC_WAGES, cast(CASE WHEN ISNUMERIC(Dept_Code) = 1 THEN Dept_Code ELSE 0 END as Numeric) as Dept_Code
						from #TEMP_SALARY_MUSTER_REPORT1 T1 left Join							 
							 t0210_Monthly_Ad_Detail Mad WITH (NOLOCK) on Mad.emp_Id = T1.emp_Id and t1.month = month(@To_DAte) and t1.year = year(@To_DAte)	inner join
							 T0050_AD_MASTER Am WITH (NOLOCK) On Am.AD_ID = mad.AD_ID						 
						where  t1.cmp_Id = @Cmp_Id and amount <> 0
								and  ad_def_Id = @Esic_Def_Id
								and upper(label_Name) = @ad_Name_Esic and month(for_date) = month(@To_date) and year(for_date) =year(@To_DAte)
						Group by Dept_Code
					)Q2 On cast(CASE WHEN ISNUMERIC(Q2.Dept_Code) = 1 THEN Q2.Dept_Code ELSE 0 END as Numeric) = cast(CASE WHEN ISNUMERIC(T.Dept_Code) = 1 THEN T.Dept_Code ELSE 0 END as Numeric)
					Order by Case When IsNumeric(Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + Alpha_Emp_Code, 20)
							When IsNumeric(Alpha_Emp_Code) = 0 then Left(Alpha_Emp_Code + Replicate('',21), 20)
								Else Alpha_Emp_Code
							End ,Row_ID
			end
			else
				begin 
					select T.*,RIGHT(REPLICATE(N' ', 500) + T.Alpha_EMP_CODE, 500) as ord_code ,
							q.Pf_COunt,q1.ESIC_COunt,Q2.ESIC_WAGES
					from #Temp_Salary_Muster_Report1 T Left Outer join
						(
							select COUNT(emp_Id) as Pf_COunt, dept_Id
							from #TEMP_SALARY_MUSTER_REPORT1 
							where upper(label_Name) = @ad_Name_Pf and amount <> 0 and cmp_Id = @Cmp_Id
							Group by dept_Id
						)Q On Q.dept_Id = T.dept_Id
						Left Outer join
						(
							select COUNT(emp_Id) as ESIC_COunt,dept_Id
							from #TEMP_SALARY_MUSTER_REPORT1 
							where upper(label_Name) = @ad_Name_Esic and amount <> 0 and cmp_Id = @Cmp_Id
							Group by dept_Id
						)Q1 On Q1.dept_Id = T.dept_Id
						Left Outer join
							(
								select sum(M_AD_Calculated_Amount) as ESIC_WAGES,dept_Id 
								from #TEMP_SALARY_MUSTER_REPORT1 T1 left Join							 
									 t0210_Monthly_Ad_Detail Mad WITH (NOLOCK) on Mad.emp_Id = T1.emp_Id and t1.month = month(@To_DAte) and t1.year = year(@To_DAte)	inner join
									 T0050_AD_MASTER Am WITH (NOLOCK) On Am.AD_ID = mad.AD_ID						 
								where  t1.cmp_Id = @Cmp_Id and amount <> 0
										and  ad_def_Id = @Esic_Def_Id
										and upper(label_Name) = @ad_Name_Esic and month(for_date) = month(@To_date) and year(for_date) =year(@To_DAte)
								Group by dept_Id
							)Q2 On Q2.dept_Id = T.dept_Id
					Order by Case When IsNumeric(Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + Alpha_Emp_Code, 20)
							When IsNumeric(Alpha_Emp_Code) = 0 then Left(Alpha_Emp_Code + Replicate('',21), 20)
								Else Alpha_Emp_Code
							End ,Row_ID
			  
			  end
			END	
	else if  @group_Name = 3
		BEGIN
					select T.*,RIGHT(REPLICATE(N' ', 500) + T.Alpha_EMP_CODE, 500) as ord_code ,
							q.Pf_COunt,q1.ESIC_COunt,q2.ESIC_WAGES
					from #Temp_Salary_Muster_Report1 T Left Outer join
						(
							select COUNT(emp_Id) as Pf_COunt, desig_Id from #TEMP_SALARY_MUSTER_REPORT1 
							where upper(label_Name) = @ad_Name_Pf and amount <> 0 and cmp_Id = @Cmp_Id
							Group by desig_Id
						)Q On Q.desig_Id = T.desig_Id
						Left Outer join
						(
							select COUNT(emp_Id) as ESIC_COunt,desig_Id from #TEMP_SALARY_MUSTER_REPORT1 
							where upper(label_Name) = @ad_Name_Esic and amount <> 0 and cmp_Id = @Cmp_Id
							Group by desig_Id
						)Q1 On Q1.desig_Id = T.desig_Id
						Left Outer join
							(
								select sum(M_AD_Calculated_Amount) as ESIC_WAGES,desig_Id 
								from #TEMP_SALARY_MUSTER_REPORT1 T1 left Join							 
									 t0210_Monthly_Ad_Detail Mad WITH (NOLOCK) on Mad.emp_Id = T1.emp_Id and t1.month = month(@To_DAte) and t1.year = year(@To_DAte)	inner join
									 T0050_AD_MASTER Am WITH (NOLOCK) On Am.AD_ID = mad.AD_ID						 
								where  t1.cmp_Id = @Cmp_Id and amount <> 0
										and  ad_def_Id = @Esic_Def_Id
										and upper(label_Name) = @ad_Name_Esic and month(for_date) = month(@To_date) and year(for_date) =year(@To_DAte)
								Group by desig_Id
							)Q2 On Q2.desig_Id = T.desig_Id
					Order by Case When IsNumeric(Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + Alpha_Emp_Code, 20)
							When IsNumeric(Alpha_Emp_Code) = 0 then Left(Alpha_Emp_Code + Replicate('',21), 20)
								Else Alpha_Emp_Code
							End ,Row_ID
		END
	else if  @group_Name = 4
		BEGIN
					select T.*,RIGHT(REPLICATE(N' ', 500) + T.Alpha_EMP_CODE, 500) as ord_code ,
							q.Pf_COunt,q1.ESIC_COunt,Q2.ESIC_WAGES
					from #Temp_Salary_Muster_Report1 T Left Outer join
						(
							select COUNT(emp_Id) as Pf_COunt, branch_Id from #TEMP_SALARY_MUSTER_REPORT1 
							where upper(label_Name) = @ad_Name_Pf and amount <> 0 and cmp_Id = @Cmp_Id
							Group by branch_Id
						)Q On Q.branch_Id = T.branch_Id
						Left Outer join
						(
							select COUNT(emp_Id) as ESIC_COunt,branch_Id from #TEMP_SALARY_MUSTER_REPORT1 
							where upper(label_Name) = @ad_Name_Esic and amount <> 0 and cmp_Id = @Cmp_Id
							Group by branch_Id
						)Q1 On Q1.branch_Id = T.branch_Id
						Left Outer join
							(
								select sum(M_AD_Calculated_Amount) as ESIC_WAGES,branch_Id 
								from #TEMP_SALARY_MUSTER_REPORT1 T1 left Join							 
									 t0210_Monthly_Ad_Detail Mad WITH (NOLOCK) on Mad.emp_Id = T1.emp_Id and t1.month = month(@To_DAte) and t1.year = year(@To_DAte)	inner join
									 T0050_AD_MASTER Am WITH (NOLOCK) On Am.AD_ID = mad.AD_ID						 
								where  t1.cmp_Id = @Cmp_Id and amount <> 0
										and  ad_def_Id = @Esic_Def_Id
										and upper(label_Name) = @ad_Name_Esic and month(for_date) = month(@To_date) and year(for_date) =year(@To_DAte)
								Group by branch_Id
							)Q2 On Q2.branch_Id = T.branch_Id
					Order by Case When IsNumeric(Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + Alpha_Emp_Code, 20)
							When IsNumeric(Alpha_Emp_Code) = 0 then Left(Alpha_Emp_Code + Replicate('',21), 20)
								Else Alpha_Emp_Code
							End ,Row_ID
		END
	else if  @group_Name = 5
		BEGIN
					select T.*,RIGHT(REPLICATE(N' ', 500) + T.Alpha_EMP_CODE, 500) as ord_code ,
							q.Pf_COunt,q1.ESIC_COunt,Q2.ESIC_WAGES
					from #Temp_Salary_Muster_Report1 T Left Outer join
						(
							select COUNT(emp_Id) as Pf_COunt, vertical_Id from #TEMP_SALARY_MUSTER_REPORT1 
							where upper(label_Name) = @ad_Name_Pf and amount <> 0 and cmp_Id = @Cmp_Id
							Group by vertical_Id
						)Q On Q.vertical_Id = T.vertical_Id
						Left Outer join
						(
							select COUNT(emp_Id) as ESIC_COunt,vertical_Id from #TEMP_SALARY_MUSTER_REPORT1 
							where upper(label_Name) = @ad_Name_Esic and amount <> 0 and cmp_Id = @Cmp_Id
							Group by vertical_Id
						)Q1 On Q1.vertical_Id = T.vertical_Id
						Left Outer join
							(
								select sum(M_AD_Calculated_Amount) as ESIC_WAGES,vertical_Id 
								from #TEMP_SALARY_MUSTER_REPORT1 T1 left Join							 
									 t0210_Monthly_Ad_Detail Mad WITH (NOLOCK) on Mad.emp_Id = T1.emp_Id and t1.month = month(@To_DAte) and t1.year = year(@To_DAte)	inner join
									 T0050_AD_MASTER Am WITH (NOLOCK) On Am.AD_ID = mad.AD_ID						 
								where  t1.cmp_Id = @Cmp_Id and amount <> 0
										and  ad_def_Id = @Esic_Def_Id
										and upper(label_Name) = @ad_Name_Esic and month(for_date) = month(@To_date) and year(for_date) =year(@To_DAte)
								Group by vertical_Id
							)Q2 On Q2.vertical_Id = T.vertical_Id
					Order by Case When IsNumeric(Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + Alpha_Emp_Code, 20)
							When IsNumeric(Alpha_Emp_Code) = 0 then Left(Alpha_Emp_Code + Replicate('',21), 20)
								Else Alpha_Emp_Code
							End ,Row_ID
		END
	else if  @group_Name = 6
		BEGIN
				select T.*,RIGHT(REPLICATE(N' ', 500) + T.Alpha_EMP_CODE, 500) as ord_code ,
						q.Pf_COunt,q1.ESIC_COunt,Q2.ESIC_WAGES
				from #Temp_Salary_Muster_Report1 T Left Outer join
					(
						select COUNT(emp_Id) as Pf_COunt, subvertical_Id from #TEMP_SALARY_MUSTER_REPORT1 
						where upper(label_Name) = @ad_Name_Pf and amount <> 0 and cmp_Id = @Cmp_Id
						Group by subvertical_Id
					)Q On Q.subvertical_Id = T.subvertical_Id
					Left Outer join
					(
						select COUNT(emp_Id) as ESIC_COunt,subvertical_Id from #TEMP_SALARY_MUSTER_REPORT1 
						where upper(label_Name) = @ad_Name_Esic and amount <> 0 and cmp_Id = @Cmp_Id
						Group by subvertical_Id
					)Q1 On Q1.subvertical_Id = T.subvertical_Id
					Left Outer join
							(
								select sum(M_AD_Calculated_Amount) as ESIC_WAGES,subvertical_Id 
								from #TEMP_SALARY_MUSTER_REPORT1 T1 left Join							 
									 t0210_Monthly_Ad_Detail Mad WITH (NOLOCK) on Mad.emp_Id = T1.emp_Id and t1.month = month(@To_DAte) and t1.year = year(@To_DAte)	inner join
									 T0050_AD_MASTER Am WITH (NOLOCK) On Am.AD_ID = mad.AD_ID						 
								where  t1.cmp_Id = @Cmp_Id and amount <> 0
										and  ad_def_Id = @Esic_Def_Id
										and upper(label_Name) = @ad_Name_Esic and month(for_date) = month(@To_date) and year(for_date) =year(@To_DAte)
								Group by subvertical_Id
							)Q2 On Q2.subvertical_Id = T.subvertical_Id
				Order by Case When IsNumeric(Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + Alpha_Emp_Code, 20)
						When IsNumeric(Alpha_Emp_Code) = 0 then Left(Alpha_Emp_Code + Replicate('',21), 20)
							Else Alpha_Emp_Code
						End ,Row_ID
		END
	else 
		BEGIN
				select T.*,RIGHT(REPLICATE(N' ', 500) + T.Alpha_EMP_CODE, 500) as ord_code ,
						0 as Pf_COunt,0 as ESIC_COunt,0 as ESIC_WAGES
				from #Temp_Salary_Muster_Report1 T				
				Order by Case When IsNumeric(Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + Alpha_Emp_Code, 20)
						When IsNumeric(Alpha_Emp_Code) = 0 then Left(Alpha_Emp_Code + Replicate('',21), 20)
							Else Alpha_Emp_Code
						End ,Row_ID
		END
		
-----Add Jignesh 04-Sep-2012 (use Table #Temp_Salary_Muster_Report1 to #Temp_Salary_Muster_Report)
	--select T.*,RIGHT(REPLICATE(N' ', 500) + T.Alpha_EMP_CODE, 500) as ord_code ,
	--		q.Pf_COunt,q1.ESIC_COunt--,q2.ESIC_WAGES
	--from #Temp_Salary_Muster_Report1 T Left Outer join
	--	(
	--		select COUNT(emp_Id) as Pf_COunt, grd_Id from #TEMP_SALARY_MUSTER_REPORT1 
	--		where label_Name in (select top 1 ad_sort_Name from t0050_AD_Master where ad_def_Id = @Pf_Def_Id) and amount <> 0 
	--		Group by grd_Id
	--	)Q On Q.group_Id = T.grd_Id
	--	Left Outer join
	--	(
	--		select COUNT(emp_Id) as ESIC_COunt,grd_Id from #TEMP_SALARY_MUSTER_REPORT1 
	--		where label_Name in (select top 1 ad_sort_Name  from t0050_AD_Master where ad_def_Id = @Esic_Def_Id) and amount <> 0 
	--		Group by grd_Id
	--	)Q1 On Q1.group_Id = T.grd_Id
		--Left Outer join
		--(
		--	select sum(amount) as ESIC_WAGES,desig_Id from #TEMP_SALARY_MUSTER_REPORT1 
		--	where upper(label_Name) Like '%ESI%' and amount <> 0 
		--	Group by desig_Id
		--)Q2 On Q2.desig_Id = T.desig_Id								
	
	--Order by Case When IsNumeric(Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + Alpha_Emp_Code, 20)
	--		When IsNumeric(Alpha_Emp_Code) = 0 then Left(Alpha_Emp_Code + Replicate('',21), 20)
	--			Else Alpha_Emp_Code
	--		End ,Row_ID
	--order by RIGHT(REPLICATE(N' ', 500) + Alpha_EMP_CODE, 500)
	
	Select Label_Name,Row_Id, M_ad_Flage from dbo.#Temp_Salary_Muster_Report1 as TMP  Group by Label_Name,Row_Id,M_ad_Flage Order By Row_Id--,Label_Name
	
	Select Label_Name,Row_Id, M_ad_Flage, SUM(Amount) As Total_Amt from dbo.#Temp_Salary_Muster_Report1  as TMP Group by Label_Name,Row_Id,M_ad_Flage Order By Row_Id,Label_Name
-----End---------- 
	
		
	



	
	---added by jimit 27012017
	DECLARE @CUR_SAL_TRAN_ID NUMERIC(18,0)
	
	CREATE TABLE #RATEOFWAGES
	(
		EMP_ID           NUMERIC(18,0),
		SAL_TRAN_ID      NUMERIC(18,0),
		ALLOWANCE_NAME   NVARCHAR(100),
		RATE_TYPE		 NVARCHAR(10),
		ALLOWANCE_AMOUNT NUMERIC(18,2),
		ALLOWANCE_TYPE	 CHAR(1)
	)
	
	
	
	DECLARE CUR_EMP CURSOR FOR
			SELECT SG.EMP_ID ,SG.SAL_TRAN_ID
			FROM DBO.T0200_MONTHLY_SALARY SG WITH (NOLOCK)
			INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON SG.EMP_ID =E.EMP_ID 
			INNER JOIN #EMP_CONS EC ON E.EMP_ID = EC.EMP_ID 
			WHERE  SG.CMP_ID = @CMP_ID 
			AND MONTH(SG.MONTH_END_DATE) = @MONTH AND YEAR(SG.MONTH_END_DATE) = @YEAR AND ISNULL(SG.IS_FNF,0)=0
	
		
		OPEN  CUR_EMP
			FETCH NEXT FROM CUR_EMP INTO @EMP_ID ,@CUR_SAL_TRAN_ID
			WHILE @@FETCH_STATUS = 0
				BEGIN		
			
			INSERT INTO #RATEOFWAGES(EMP_ID,SAL_TRAN_ID,ALLOWANCE_NAME,RATE_TYPE,ALLOWANCE_AMOUNT,ALLOWANCE_TYPE)
				SELECT MS.Emp_ID,MS.Sal_Tran_ID,'Basic','AMT',MS.Basic_Salary,'I' from T0200_MONTHLY_SALARY MS WITH (NOLOCK)
				WHERE EMP_ID = @EMP_ID AND MONTH(MONTH_END_DATE) = @MONTH AND YEAR(MONTH_END_DATE) = @YEAR  
				union
				SELECT EE.EMP_ID,@CUR_SAL_TRAN_ID,AM.AD_SORT_NAME,E_AD_MODE, E_AD_AMOUNT ,E_AD_FLAG 
				FROM T0100_EMP_EARN_DEDUCTION EE WITH (NOLOCK)
				INNER JOIN
				(
						SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,EED.AD_ID,EED.EMP_ID FROM T0100_EMP_EARN_DEDUCTION EED  WITH (NOLOCK) Inner JOIN
						( 
							SELECT MAX(FOR_DATE)AS FOR_DATE,EED.AD_ID,EED.EMP_ID FROM T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK)
							WHERE CMP_ID = @CMP_ID AND EED.EMP_ID = @EMP_ID AND FOR_DATE <= @TO_dATE		
							GROUP BY EED.EMP_ID,EED.AD_ID,EED.FOR_DATE
						) INN_QRY ON INN_QRY.FOR_DATE = EED.FOR_DATE AND  INN_QRY.AD_ID = EED.AD_ID AND INN_QRY.EMP_ID = EED.EMP_ID
						WHERE CMP_ID = @CMP_ID AND EED.EMP_ID = @EMP_ID AND EED.FOR_DATE <= @TO_dATE	
						GROUP BY EED.EMP_ID,EED.AD_ID
				)QRY ON QRY.EMP_ID = EE.EMP_ID AND QRY.AD_ID = EE.AD_ID AND QRY.INCREMENT_ID =EE.INCREMENT_ID
				INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON AM.AD_ID = EE.AD_ID  		
				
				where EE.E_AD_AMOUNT > 0	
				
				
			
			
					FETCH NEXT FROM CUR_EMP INTO @EMP_ID,@CUR_SAL_TRAN_ID 
				END
		CLOSE CUR_EMP
		DEALLOCATE CUR_EMP
		
		--SELECT * from #RATEOFWAGES
		
		SELECT  T.EMP_ID,@CUR_SAL_TRAN_ID AS SAL_TRAN_ID,T.LABEL_NAME AS ALLOWANCE_NAME,ISNULL(RW.RATE_TYPE,'') AS RATE_TYPE,ISNULL(RW.ALLOWANCE_AMOUNT,0) AS ALLOWANCE_AMOUNT,M_AD_FLAGE AS ALLOWANCE_TYPE,ROW_ID
		FROM	#TEMP_SALARY_MUSTER_REPORT1 T 
				LEFT OUTER JOIN #RATEOFWAGES RW ON	T.EMP_ID = RW.EMP_ID	AND T.LABEL_NAME = RW.ALLOWANCE_NAME				
		--where ALLOWANCE_NAME = 'Present'
		ORDER BY Emp_code, Row_ID
		
		

		--select * from #Temp_Salary_Muster_Report1 where Dept_Name = 'Accounts' and label_name = 'Present'

	If @group_Name = 0 
		Begin
			Select Label_Name,Row_Id, M_ad_Flage, SUM(Amount) As Total_Amt,TMP.grd_Name as group_Name,IsNull(Tmp.grd_Id,0) as Group_Id
			from dbo.#Temp_Salary_Muster_Report1  as TMP 
			Group by grd_Id,grd_Name,Label_Name,Row_Id,M_ad_Flage 
			Order By Row_Id,Label_Name	
		END
	Else If @group_Name = 1 
		Begin
			Select Label_Name,Row_Id, M_ad_Flage, SUM(Amount) As Total_Amt,TMP.[type_Name] as group_Name,IsNull(Tmp.[Type_Id],0) as Group_Id
			from dbo.#Temp_Salary_Muster_Report1  as TMP 
			Group by [Type_Id],[type_Name],Label_Name,Row_Id,M_ad_Flage 
			Order By Row_Id,Label_Name	
		END	
	ELSE If @group_Name = 2 
		BEGIN
			If exists(Select 1 from  #TEMP_SALARY_MUSTER_REPORT1 where ISNUMERIC(Dept_Code) >0)
				Begin
					
					
					Select Label_Name,Row_Id, M_ad_Flage, SUM(Amount) As Total_Amt,
					TMP.Dept_Code as group_Name,cast( CASE WHEN ISNUMERIC(TMP.Dept_Code) =1 THEN TMP.Dept_Code ELSE 0 END as numeric) as Group_Id
					from dbo.#Temp_Salary_Muster_Report1  as TMP 
					Group by Label_Name,Row_Id,M_ad_Flage ,Dept_Code
					Order By Row_Id,Label_Name			
				End
			Else
				Begin
					Select Label_Name,Row_Id, M_ad_Flage, SUM(Amount) As Total_Amt,TMP.Dept_Name as group_Name,IsNull(Tmp.Dept_Id,0) as Group_Id
					from dbo.#Temp_Salary_Muster_Report1  as TMP 
					Group by Dept_Id,Dept_Name,Label_Name,Row_Id,M_ad_Flage 
					Order By Row_Id,Label_Name			
				End

		END
	Else If @group_Name = 3 
		Begin
			Select Label_Name,Row_Id, M_ad_Flage, SUM(Amount) As Total_Amt,TMP.desig_Name as group_Name,IsNull(Tmp.Desig_Id,0) as Group_Id
			from dbo.#Temp_Salary_Muster_Report1  as TMP 
			Group by Desig_Id,desig_Name,Label_Name,Row_Id,M_ad_Flage 
			Order By Row_Id,Label_Name	
		END
	Else If @group_Name = 4 
		Begin
			Select Label_Name,Row_Id, M_ad_Flage, SUM(Amount) As Total_Amt,TMP.branch_Name as group_Name,IsNull(Tmp.branch_Id,0) as Group_Id
			from dbo.#Temp_Salary_Muster_Report1  as TMP 
			Group by branch_Id,branch_Name,Label_Name,Row_Id,M_ad_Flage 
			Order By Row_Id,Label_Name	
		END
	Else If @group_Name = 5 
		Begin
			Select Label_Name,Row_Id, M_ad_Flage, SUM(Amount) As Total_Amt,TMP.vertical_Name as group_Name,IsNull(Tmp.Vertical_Id,0) as Group_Id
			from dbo.#Temp_Salary_Muster_Report1  as TMP 
			Group by Vertical_Id,vertical_Name,Label_Name,Row_Id,M_ad_Flage 
			Order By Row_Id,Label_Name	
		END
		Else If @group_Name = 6 
		Begin
			Select Label_Name,Row_Id, M_ad_Flage, SUM(Amount) As Total_Amt,TMP.subvertical_name as group_Name,IsNull(Tmp.subvertical_Id,0) as Group_Id
			from dbo.#Temp_Salary_Muster_Report1  as TMP 
			Group by subvertical_Id,subvertical_name,Label_Name,Row_Id,M_ad_Flage 
			Order By Row_Id,Label_Name	
		END
	
		
	If @group_Name = 0 
		Begin	
			SELECT  T.LABEL_NAME AS ALLOWANCE_NAME,ISNULL(Sum(RW.ALLOWANCE_AMOUNT),0) AS ALLOWANCE_AMOUNT,M_AD_FLAGE AS ALLOWANCE_TYPE,ROW_ID
					,T.grd_Name as group_Name,IsNull(T.grd_Id,0) as Group_Id
			FROM	#TEMP_SALARY_MUSTER_REPORT1 T 
					LEFT OUTER JOIN #RATEOFWAGES RW ON	T.EMP_ID = RW.EMP_ID	AND T.LABEL_NAME = RW.ALLOWANCE_NAME				
			GROUP BY grd_Id,grd_Name,Label_Name,M_AD_FLAGE,ROW_ID
			ORDER BY Row_ID,Label_Name
		end
	If @group_Name = 1
		Begin	
			SELECT  T.LABEL_NAME AS ALLOWANCE_NAME,ISNULL(Sum(RW.ALLOWANCE_AMOUNT),0) AS ALLOWANCE_AMOUNT,M_AD_FLAGE AS ALLOWANCE_TYPE,ROW_ID
					,T.[type_Name] as group_Name,IsNull(T.[Type_Id],0) as Group_Id
			FROM	#TEMP_SALARY_MUSTER_REPORT1 T 
					LEFT OUTER JOIN #RATEOFWAGES RW ON	T.EMP_ID = RW.EMP_ID	AND T.LABEL_NAME = RW.ALLOWANCE_NAME				
			GROUP BY [Type_Id],[type_Name],Label_Name,M_AD_FLAGE,ROW_ID
			ORDER BY Row_ID,Label_Name
		end
	If @group_Name = 2
		Begin
				If exists(Select 1 from  #TEMP_SALARY_MUSTER_REPORT1 where ISNUMERIC(Dept_Code) >0)
					Begin
						SELECT  T.LABEL_NAME AS ALLOWANCE_NAME,ISNULL(Sum(RW.ALLOWANCE_AMOUNT),0) AS ALLOWANCE_AMOUNT,
								M_AD_FLAGE AS ALLOWANCE_TYPE,ROW_ID
								,T.Dept_Code as group_Name,cast( CASE WHEN ISNUMERIC(T.Dept_Code) =1 THEN T.Dept_Code ELSE 0 END as numeric) as Group_Id
						FROM	#TEMP_SALARY_MUSTER_REPORT1 T 
								LEFT OUTER JOIN #RATEOFWAGES RW ON	T.EMP_ID = RW.EMP_ID	AND T.LABEL_NAME = RW.ALLOWANCE_NAME				
						GROUP BY Label_Name,M_AD_FLAGE,ROW_ID,Dept_Code
						ORDER BY Row_ID,Label_Name
					End
				Else
					Begin
						SELECT  T.LABEL_NAME AS ALLOWANCE_NAME,ISNULL(Sum(RW.ALLOWANCE_AMOUNT),0) AS ALLOWANCE_AMOUNT,
								M_AD_FLAGE AS ALLOWANCE_TYPE,ROW_ID
								,T.Dept_Name as group_Name,IsNull(T.Dept_Id,0) as Group_Id
						FROM	#TEMP_SALARY_MUSTER_REPORT1 T 
								LEFT OUTER JOIN #RATEOFWAGES RW ON	T.EMP_ID = RW.EMP_ID	AND T.LABEL_NAME = RW.ALLOWANCE_NAME				
						GROUP BY Dept_Id,Dept_Name,Label_Name,M_AD_FLAGE,ROW_ID
						ORDER BY Row_ID,Label_Name
					End

		end
		If @group_Name = 3
		Begin	
			SELECT  T.LABEL_NAME AS ALLOWANCE_NAME,ISNULL(Sum(RW.ALLOWANCE_AMOUNT),0) AS ALLOWANCE_AMOUNT,M_AD_FLAGE AS ALLOWANCE_TYPE,ROW_ID
					,T.desig_Name as group_Name,IsNull(T.Desig_Id,0) as Group_Id
			FROM	#TEMP_SALARY_MUSTER_REPORT1 T 
					LEFT OUTER JOIN #RATEOFWAGES RW ON	T.EMP_ID = RW.EMP_ID	AND T.LABEL_NAME = RW.ALLOWANCE_NAME				
			GROUP BY Desig_Id,desig_Name,Label_Name,M_AD_FLAGE,ROW_ID
			ORDER BY Row_ID,Label_Name
		end
		If @group_Name = 4
		Begin	
			SELECT  T.LABEL_NAME AS ALLOWANCE_NAME,ISNULL(Sum(RW.ALLOWANCE_AMOUNT),0) AS ALLOWANCE_AMOUNT,M_AD_FLAGE AS ALLOWANCE_TYPE,ROW_ID
					,T.branch_Name as group_Name,IsNull(T.branch_Id,0) as Group_Id
			FROM	#TEMP_SALARY_MUSTER_REPORT1 T 
					LEFT OUTER JOIN #RATEOFWAGES RW ON	T.EMP_ID = RW.EMP_ID	AND T.LABEL_NAME = RW.ALLOWANCE_NAME				
			GROUP BY branch_Id,branch_Name,Label_Name,M_AD_FLAGE,ROW_ID
			ORDER BY Row_ID,Label_Name
		end
		If @group_Name = 5
		Begin	
			SELECT  T.LABEL_NAME AS ALLOWANCE_NAME,ISNULL(Sum(RW.ALLOWANCE_AMOUNT),0) AS ALLOWANCE_AMOUNT,M_AD_FLAGE AS ALLOWANCE_TYPE,ROW_ID
					,T.vertical_Name as group_Name,IsNull(T.Vertical_Id,0) as Group_Id
			FROM	#TEMP_SALARY_MUSTER_REPORT1 T 
					LEFT OUTER JOIN #RATEOFWAGES RW ON	T.EMP_ID = RW.EMP_ID	AND T.LABEL_NAME = RW.ALLOWANCE_NAME				
			GROUP BY Vertical_Id,vertical_Name,Label_Name,M_AD_FLAGE,ROW_ID
			ORDER BY Row_ID,Label_Name
		end
		If @group_Name = 6
		Begin	
			SELECT  T.LABEL_NAME AS ALLOWANCE_NAME,ISNULL(Sum(RW.ALLOWANCE_AMOUNT),0) AS ALLOWANCE_AMOUNT,M_AD_FLAGE AS ALLOWANCE_TYPE,ROW_ID
					,T.subvertical_name as group_Name,IsNull(T.subvertical_Id,0) as Group_Id
			FROM	#TEMP_SALARY_MUSTER_REPORT1 T 
					LEFT OUTER JOIN #RATEOFWAGES RW ON	T.EMP_ID = RW.EMP_ID	AND T.LABEL_NAME = RW.ALLOWANCE_NAME				
			GROUP BY subvertical_Id,subvertical_name,Label_Name,M_AD_FLAGE,ROW_ID
			ORDER BY Row_ID,Label_Name
		end
	---ended
	


	RETURN
