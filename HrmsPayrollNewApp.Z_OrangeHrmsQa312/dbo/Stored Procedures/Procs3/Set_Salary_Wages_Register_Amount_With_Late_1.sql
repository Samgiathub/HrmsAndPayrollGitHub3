
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Set_Salary_Wages_Register_Amount_With_Late_1]
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
,@Sal_Type    numeric 
,@Payment_Mode varchar(20) = ''
,@Salary_Cycle_id numeric =0
,@Segment_Id numeric = 0
,@Vertical_Id  numeric = 0
,@SubVertical_Id numeric = 0
,@SubBranch_Id numeric = 0
,@PBranch_ID   varchar(5000) = '0'

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
	Declare @To_Date_1 Datetime
	Declare @From_Date_1 Datetime
	Declare @Late_Dedu_Amount Numeric(18,2)
	
	Set @LWP_Days = 0
	Set @Gross_Salary = 0
	Set @W_OT_Wages = 0
	Set @H_OT_Wages = 0
	Set @Late_Dedu_Amount = 0
	
	
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

	Set @To_Date_1 = @To_Date
	Set @From_Date_1 = @From_Date	
	
	CREATE TABLE #Temp_report_Label
	(
	Row_ID  numeric(18, 0) NOt null,
	Label_Name  varchar(200) not null,
	Income_Tax_ID numeric(18, 0) null,
	Is_Active	varchar(1) null
	)
	
	--ALTER index idx_1 on #Temp_report_Label (Row_ID)
	CREATE CLUSTERED INDEX ind_temp ON #Temp_report_Label(Row_ID)
	CREATE NONCLUSTERED INDEX ind_temp6 ON #Temp_report_Label(Label_Name)

		
	CREATE TABLE #Temp_Salary_Muster_Report		
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
		Group_By Numeric(18,0),
		Loan_Detail Varchar(Max) Default NULL
	)
	CREATE CLUSTERED INDEX ind_temp1	ON #Temp_Salary_Muster_Report(Row_id)
	CREATE NONCLUSTERED INDEX ind_temp2 ON #Temp_Salary_Muster_Report(Emp_ID)
	CREATE NONCLUSTERED INDEX ind_temp3 ON #Temp_Salary_Muster_Report(Cmp_ID)
	CREATE NONCLUSTERED INDEX ind_temp4 ON #Temp_Salary_Muster_Report(Label_Name)
	CREATE NONCLUSTERED INDEX ind_temp5 ON #Temp_Salary_Muster_Report(Value_String)
		
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
				
			If @Branch_ID is null
				Begin 
					select Top 1 @Sal_St_Date  = Sal_st_Date, @ROUNDING =Ad_Rounding , @Net_Salary_Round = Net_Salary_Round
					  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
					  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Cmp_ID = @Cmp_ID)    
				End
			Else
				Begin
					select @Sal_St_Date  =Sal_st_Date ,@ROUNDING =Ad_Rounding , @Net_Salary_Round = Net_Salary_Round
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

		
	set @month = month(@To_Date)
	set @Year = Year(@To_Date)
	  
	EXEC Set_Salary_Wages_register_Lable_With_Late @Cmp_ID,@month,@Year
	
	
	
	 CREATE TABLE #Emp_Cons 
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )   
	 
	 EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,@Sal_Type ,0 ,0,0,0,0,0,0,2,@PBranch_ID 
	      
	
	
	--Declare #Emp_Cons Table
	--	(
	--		Emp_ID	numeric
	--	)
	
	--if @Constraint <> ''
	--	begin
	--		Insert Into #Emp_Cons
	--		select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
	--	end
	--else 
	--	begin
	--		if @PBranch_ID <> '0' and isnull(@Branch_ID,0) = 0  -- added by mitesh on 02042012
	--			begin
				
	--				Insert Into #Emp_Cons
					
	--				select I.Emp_Id from dbo.T0095_Increment I inner join 
	--						( select max(Increment_effective_Date) as For_Date , Emp_ID from dbo.T0095_Increment
	--						where Increment_Effective_date <= @To_Date
	--						and Cmp_ID = @Cmp_ID
	--						group by emp_ID  ) Qry on
	--						I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date
	--				Where Cmp_ID = @Cmp_ID 
	--				and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
	--				--and Branch_ID = isnull(@Branch_ID ,Branch_ID)
	--				and Grd_ID = isnull(@Grd_ID ,Grd_ID)
	--				and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
	--				and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
	--				and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
	--				and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
	--				and Branch_ID in (select cast(data as numeric) from dbo.Split(@PBranch_ID,'#'))
	--				and I.Emp_ID in 
	--					( select Emp_Id from
	--					(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
	--					where cmp_ID = @Cmp_ID   and  
	--					(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
	--					or ( @To_Date  >= join_Date  and @To_Date <= left_date )
	--					or Left_date is null and @To_Date >= Join_Date)
	--					or @To_Date >= left_date  and  @From_Date <= left_date ) 
	--			end
	--		else
	--			begin
				
	--				Insert Into #Emp_Cons

	--				select I.Emp_Id from dbo.T0095_Increment I inner join 
	--						( select max(Increment_effective_Date) as For_Date , Emp_ID from dbo.T0095_Increment
	--						where Increment_Effective_date <= @To_Date
	--						and Cmp_ID = @Cmp_ID
	--						group by emp_ID  ) Qry on
	--						I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date
	--				Where Cmp_ID = @Cmp_ID 
	--				and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
	--				and Branch_ID = isnull(@Branch_ID ,Branch_ID)
	--				and Grd_ID = isnull(@Grd_ID ,Grd_ID)
	--				and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
	--				and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
	--				and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
	--				and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
	--				and I.Emp_ID in 
	--					( select Emp_Id from
	--					(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
	--					where cmp_ID = @Cmp_ID   and  
	--					(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
	--					or ( @To_Date  >= join_Date  and @To_Date <= left_date )
	--					or Left_date is null and @To_Date >= Join_Date)
	--					or @To_Date >= left_date  and  @From_Date <= left_date ) 
	--			end
	--	end
	
	
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
						
						Declare @Sal as numeric(18,2)
						set @Sal =0
						
						Declare @GatePass_Deduct_Days numeric(18,2) -- Added by Gadriwala Muslim 09012015
						Declare @GatePass_Amount numeric(18,2) -- Added by Gadriwala Muslim 09012015
						set @GatePass_Deduct_Days = 0
						set @GatePass_Amount = 0
						
					--Added for Basic Rate should come from Increment.. Before it was taken from Salary Table..
					--Hardik 08/08/2012
					select @Sal = I.Basic_Salary from dbo.T0095_Increment I WITH (NOLOCK) inner join 
							( select max(Increment_ID) as Increment_ID from dbo.T0095_Increment	 WITH (NOLOCK) -- Ankit 05092014 for Same Date Increment
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
					select @P_Days = isnull(Present_Days,0) ,--@Sal=Basic_Salary,
						@A_Days = isnull(Absent_Days,0) - isnull(Late_Days,0) - isnull(Early_Days,0) ,@TDS=isnull(M_IT_TAX,0), 
						@Basic_Salary = Salary_Amount, @Act_Gross_salary = Actually_Gross_salary,@Settl = Settelement_Amount,@OTher_Allow = ISNULL(Other_Allow_Amount,0),
						@Paid_Leave = isnull(Paid_Leave_Days,0) + ISNULL(OD_Leave_Days,0),@Holiday_Days = ISNULL(Holiday_Days,0),@WeekOff = ISNULL(Weekoff_Days,0),
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


					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage,Group_By)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Present', @P_Days,'',2,'P',1)
					
					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage,Group_By)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Absent', @A_Days,'',3,'P',1)

					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage,Group_By)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Late', @Late,'',4,'P',1)
					
					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage,Group_By)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Early', @Early,'',5,'P',1)

					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage,Group_By)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Leave', @Paid_Leave,'',6,'P',1)

					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage,Group_By)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'LWP', @LWP_Days,'',7,'P',1)

					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage,Group_By)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Holiday', @Holiday_Days,'',8,'P',1)					
					
					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage,Group_By)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Week Off', @WeekOff,'',9,'P',1)
					
					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage,Group_By)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'T.Days', @Total_Days,'',10,'P',1)
					
					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage,Group_By)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Arrear Days', @Arear_Days,'',11,'P',1)

					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage,Group_By)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'M.W.', 0,'',12,'P',1)

					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage,Rate,Group_By)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year,'Basic', @Sal,'',13,'I',@Sal,2)
					
					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage,Rate,Group_By)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year,'Wages', @Basic_salary,'',14,'I',@Basic_salary,2)

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
					
					
					Declare Cur_Label cursor for 
					SELECT Label_Name ,Row_ID FROM dbo.#TEMP_REPORT_LABEL where Row_ID > 29 and Label_Name <> 'Loss or Damage'
					open Cur_label
					fetch next from Cur_label into @Label_Name ,@Row_ID
					while @@fetch_Status = 0
						begin
							INSERT INTO dbo.#Temp_Salary_Muster_Report
							(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage,Group_By)
							VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, @Label_Name, 0,'',@Row_ID,'',2)
							fetch next from Cur_label into @Label_Name,@Row_ID
						end
					close Cur_Label
					deallocate Cur_Label
					--select 'Temp'
					--Select * From #Temp_Salary_Muster_Report
					--Select 'Temp'
					--select Ad_Sort_Name ,M_Ad_Amount,t0050_ad_master.AD_Flag,MAD.Emp_Id, Case when t0050_ad_master.AD_PERCENTAGE > 0 then t0050_ad_master.AD_PERCENTAGE Else MAD.M_AD_Actual_per_Amount End  						     
					--	r from t0210_monthly_ad_detail MAD inner join
					--		t0050_ad_master on MAD.Ad_Id = t0050_ad_master.Ad_ID  Left Outer join #Temp_Salary_Muster_Report
					--		on MAD.Emp_Id = #Temp_Salary_Muster_Report.Emp_ID 
					--		and MAD.Cmp_ID = t0050_ad_master.Cmp_Id
					--		and MAD.Emp_ID  = @Emp_ID
					--	where 
					--	MAD.Cmp_ID = @Cmp_ID and month(MAD.For_Date) =  @Month and Year(MAD.For_Date) = @Year
					--	and isnull(t0050_ad_master.Ad_Not_Effect_Salary,0) = 0 and Ad_Active = 1 and AD_Flag = 'I' and MAD.Emp_ID  = @Emp_ID

					  Update  #Temp_Salary_Muster_Report
					  set M_AD_Flage ='I',Group_By = 2
					  from #Temp_Salary_Muster_Report E1
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
									
									Select  @S_Total_Deduction = Isnull(SUM(M_AD_Amount),0)  
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
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Amount + Isnull(@S_Total_Deduction,0), 
												  Value_String = '',M_AD_Flage=@AD_Flage,Rate =@Percentage,Group_By = 3
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
					  set M_AD_Flage ='D',Group_By = 3 from #Temp_Salary_Muster_Report E1
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
								@Deficit_Amt = Isnull(Deficit_Dedu_Amount,0),
								@Late_Dedu_Amount = Isnull(Late_Dedu_Amount,0)
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
								
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Loan'
						
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Loan, 
											  Value_String = '',M_AD_Flage='D',Group_By = 4
						WHERE     (Label_Name = 'Loan') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
						
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Loan Int'
						
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Loan_intrest, 
											  Value_String = '',M_AD_Flage='D',Group_By = 4
						WHERE     (Label_Name = 'Loan Int') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID								
								
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Advance'
						
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Advance, 
											  Value_String = '',M_AD_Flage='D',Group_By = 4
						WHERE     (Label_Name = 'Advance') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
								
						
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Late Deduction'
						
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Late_Dedu_Amount, 
											  Value_String = '',M_AD_Flage='D',Group_By = 4
						WHERE     (Label_Name = 'Late Deduction') AND (Row_id = @Row_ID)
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
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Fine'
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = 0, 
											  Value_String = '',M_AD_Flage='D'
						WHERE     (Label_Name = 'Fine') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID

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
											  Value_String = '',M_AD_Flage='N',Group_By = 5
						WHERE     (Label_Name = 'Net') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
								
						IF @ROUNDING = 0 AND @Net_Salary_Round <> -1
							Begin	
								select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Net'
						
								UPDATE    dbo.#Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = Isnull(@Net_Salary,0) - Isnull(@Net_Salary_Round_Diff_Amount,0), 
													  Value_String = '',M_AD_Flage='N' ,Group_By = 5
								WHERE     (Label_Name = 'Net') AND (Row_id = @Row_ID)
										and Emp_ID = @Emp_ID
											
								select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Net Round'
								
								UPDATE    dbo.#Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = Isnull(@Net_Salary_Round_Diff_Amount,0), 
													  Value_String = '',M_AD_Flage='N' ,Group_By = 5
								WHERE     (Label_Name = 'Net Round') AND (Row_id = @Row_ID)
										and Emp_ID = @Emp_ID
										
								select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Total Net'
						
								UPDATE    dbo.#Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Net_Salary, 
													  Value_String = '',M_AD_Flage='N' ,Group_By = 5
								WHERE     (Label_Name = 'Total Net') AND (Row_id = @Row_ID)
										and Emp_ID = @Emp_ID		
										
								IF @Net_Salary_Round_Diff_Amount = 0 
									BEGIN
										DELETE FROM  dbo.#Temp_Salary_Muster_Report
										WHERE Label_Name = 'Total Net'
									END
								
							End
							
			FETCH NEXT FROM CUR_EMP INTO @EMP_ID
		END
	Close Cur_Emp
	Deallocate Cur_emp
	
	
	CREATE TABLE #Loan_Installment_Status
	(
			Emp_ID numeric(18,0),
			Loan_ID numeric(18,0),
			Total_Installment numeric(18,0),
			Current_installment numeric(18,0),
			Loan_Apr_ID numeric(18,0),
			Loan_Amount Numeric(18,2) default 0
	)
	

	--Added by nilesh patel on 08102015 --Start 
	Insert into #Loan_Installment_Status
				(Emp_ID,Loan_ID,Total_Installment,Current_installment,Loan_Apr_ID)
				exec SP_RPT_LOAN_STATEMENT_REPORT @Cmp_ID,@From_Date_1,@To_Date_1,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@Constraint,'','',1
	
	Update #Loan_Installment_Status SET Loan_Amount = LP.Loan_Pay_Amount
	From #Loan_Installment_Status LS Inner JOIN T0210_MONTHLY_LOAN_PAYMENT LP 
	ON LS.Loan_Apr_ID = LP.Loan_Apr_ID
	Where Month(LP.Loan_Payment_Date) = Month(@To_Date_1) and Year(LP.Loan_Payment_Date) = Year(@To_Date_1)
	
	DECLARE @LOAN_DETAIL VARCHAR(MAX);
	
	
	UPDATE	T
	SET		Loan_Detail = STUFF((
				Select CHAR(10) + LEFT(LM.Loan_Name + SPACE(60), 60) +'  '+ Cast(LS.Loan_Amount as varchar(100)) + '('+ Cast(LS.Current_installment as varchar(100)) + '/'+ Cast(LS.Total_Installment as varchar(100)) +')' as Loan_Details From #Loan_Installment_Status LS Inner JOIN T0040_LOAN_MASTER LM WITH (NOLOCK)
				On LM.Loan_ID = LS.Loan_ID and LM.Cmp_ID = @Cmp_ID  where Emp_ID = T.EMP_ID
				FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,''
				)
	FROM	#Temp_Salary_Muster_Report T WHERE T.Label_Name = 'Net'
	
	
	
	-- Changed By Ali 22112013 EmpName_Alias
	select dbo.#Temp_Salary_Muster_Report.* ,ISNULL(E.EmpName_Alias_Salary,E.Emp_Full_Name) as Emp_Full_Name,E.Emp_Code,E.Alpha_Emp_Code,GM.Grd_name,ETM.Type_name,DGM.Desig_Name,DM.Dept_Name,BM.Branch_Name, 
		E.Dept_ID,Cmp_Name,Cmp_Address,isnull(Inc_Qry.Inc_Bank_Ac_no,0)Inc_Bank_Ac_no,isnull(Inc_Qry.Payment_Mode,'') as Payment_Mode,
		E.SSN_No As PF_No, E.SIN_No As ESIC_No, E.Gender, BM.Comp_Name,BM.Branch_Address,BM.Branch_City, CM.PF_No AS Cmp_PF_No,CM.ESIC_No AS Cmp_ESIC_No,
		@From_Date As From_Date,@To_Date As To_Date, cm.cmp_logo,
		(Select AD_PERCENTAGE from T0050_AD_MASTER WITH (NOLOCK) Where CMP_ID = E.Cmp_ID And AD_DEF_ID = 2 and AD_CALCULATE_ON = 'Basic Salary') As PF_RATE, Day_Salary,E.Father_name
		,ISNULL(Inc_Qry.Master_Gross_Salary,0) As Master_Gross_Salary	--Ankit 10032014
		,IsNUll(DM.Dept_Dis_no,0) as Dept_Dis_no   --added jimit 05082015
		,Dgm.Desig_Dis_No                          --added jimit 25092015 
	into #Temp_Salary_Muster_Report1  -----Add Jignesh 04-Sep-2012
	
	from dbo.#Temp_Salary_Muster_Report Inner join 
	
		T0080_Emp_Master E WITH (NOLOCK) on dbo.#Temp_Salary_Muster_Report.Emp_Id = E.Emp_ID inner join
		( select I.Emp_Id ,Grd_ID,DEsig_ID ,Dept_ID,Inc_Bank_Ac_no,Branch_ID,Type_ID,
		--Payment_Mode 
		case when @Payment_Mode = '' then 'ALL' else Payment_Mode end as Payment_Mode,Gross_Salary As Master_Gross_Salary
		from t0095_Increment I WITH (NOLOCK) inner join 
					( 
					select max(Increment_ID) as Increment_ID, Emp_ID from t0095_Increment	WITH (NOLOCK) -- Ankit 05092014 for Same Date Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  
					) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID )Inc_Qry on 
		E.Emp_ID = Inc_Qry.Emp_ID left outer join t0040_department_Master
		on Inc_Qry.dept_ID = t0040_department_Master.Dept_ID LEFT OUTER JOIN
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON Inc_Qry.Grd_ID = GM.Grd_ID				LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON Inc_Qry.Type_ID = ETM.Type_ID			LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Inc_Qry.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Inc_Qry.Dept_Id = DM.Dept_Id		INNER JOIN 
					T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Inc_Qry.BRANCH_ID = BM.BRANCH_ID
		 inner join t0010_company_master CM WITH (NOLOCK) on E.cmp_id=CM.cmp_id
		 Left Outer Join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on #Temp_Salary_Muster_Report.Emp_ID = MS.Emp_ID And #Temp_Salary_Muster_Report.Month = Month(MS.Month_End_Date) And #Temp_Salary_Muster_Report.Year = Year(MS.Month_End_Date)
		 Where Label_Name not in 
			(select label_name from #Temp_Salary_Muster_Report 
				Where Row_id > 19 And Label_Name <> 'Loan' And Label_Name <> 'Loan Int' And Label_Name <> 'Advance' And Label_Name <> 'LWF' And Label_Name <> 'PT' And Label_Name <> 'Fine' --And Label_Name <> 'Loss or Damage'
			group by Label_Name having sum(Amount) = 0 ) 
		
		-----Modify Jignesh 04-Sep-2012
		and (@Payment_Mode ='' or isnull(Inc_Qry.Payment_Mode,'')=@Payment_Mode)
		-----End---------- 
		order by Emp_code,Row_ID
	
	
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

-----Add Jignesh 04-Sep-2012 (use Table #Temp_Salary_Muster_Report1 to #Temp_Salary_Muster_Report)
	select *,RIGHT(REPLICATE(N' ', 500) + #Temp_Salary_Muster_Report1.Alpha_EMP_CODE, 500) as ord_code   from #Temp_Salary_Muster_Report1 
	Order by Case When IsNumeric(Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + Alpha_Emp_Code, 20)
			When IsNumeric(Alpha_Emp_Code) = 0 then Left(Alpha_Emp_Code + Replicate('',21), 20)
				Else Alpha_Emp_Code
			End ,Group_By,Row_Id,Label_Name
	--order by RIGHT(REPLICATE(N' ', 500) + Alpha_EMP_CODE, 500)
	
	Select Label_Name,Row_Id, M_ad_Flage,Group_BY from dbo.#Temp_Salary_Muster_Report1 as TMP Group by Label_Name,Row_Id,M_ad_Flage,Group_BY Order By Group_BY,Row_Id,Label_Name
	Select Label_Name,Row_Id, M_ad_Flage, SUM(Amount) As Total_Amt,Group_BY from dbo.#Temp_Salary_Muster_Report1  as TMP Group by Label_Name,Row_Id,M_ad_Flage,Group_BY Order By Group_BY,Row_Id,Label_Name
-----End---------- 
	
	
	
	RETURN




