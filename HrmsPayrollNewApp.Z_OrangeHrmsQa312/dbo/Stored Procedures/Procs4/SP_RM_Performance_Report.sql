


-- =============================================
-- Author:		Nilesh Patel
-- Create date: 19042018
-- Description:	RM Wise Performance Tracker 
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_RM_Performance_Report]
	@Cmp_ID Numeric,
    @From_Date Datetime,
	@To_Date Datetime,
	@Constraint Varchar(max) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If Object_ID('tempdb..#EmpCons') is not null
		Begin
			Drop Table #EmpCons
		End

	Create Table #EmpCons
	(
		Emp_ID Numeric
	)

	if @Constraint <> ''
		Begin
			Insert into #EmpCons
			Select Data From dbo.Split(@Constraint,'#')
		End
	
	If Object_ID('tempdb..#EmpRM') is not null
		Begin
			Drop Table #EmpRM
		End

	Create Table #EmpRM
	(
		Emp_ID Numeric,
		Alpha_Emp_Code Varchar(100),
		Emp_Name Varchar(200),
		Branch_Code Varchar(100),
		Branch_Name Varchar(100),
		Date_of_Join Varchar(11),
		Date_of_Birth Varchar(11),
		Date_of_Resig Varchar(11),
		Emp_Join_Month Varchar(200),
		No_of_joning Varchar(20),
		No_of_Resign Varchar(20),
		Designation Varchar(100),
		Basic_Salary Numeric(18,2),
		Actual_CTC_Amount Numeric(18,2) Not Null Default(0),
		Salary_CTC Numeric(18,2) Not Null Default(0),
		Reporting_To Varchar(200) Not Null Default(''),
		Regional_Head Varchar(200) Not Null Default(''),
		No_Map_Client Numeric Not null Default(0),
		No_Map_Client_Direct Numeric Not null Default(0),
		No_Map_Client_Indirect Numeric Not null Default(0),
		No_of_Active_Cliect Numeric Not null Default(0),
		Net_Bokrage Numeric(18,2) Not null Default(0),
		MF Numeric not null Default(0),
		Insurance Numeric not null Default(0), 
		Other Numeric not null Default(0),
		Total_Inc Numeric not null Default(0),
		Kyc Numeric not null Default(0),
		MP	Numeric(18,2) not null Default(0),
		Q1_Salary Numeric not null Default(0),
		Q1_Income Numeric not null Default(0),
		Q1_Kyc Numeric not null Default(0),
		Q1_MP Numeric(18,2) not null Default(0),
 
		Q2_Salary Numeric not null Default(0),
		Q2_Income Numeric not null Default(0),
		Q2_Kyc Numeric not null Default(0),
		Q2_MP Numeric(18,2) not null Default(0),

		Q3_Salary Numeric not null Default(0),
		Q3_Income Numeric not null Default(0),
		Q3_Kyc Numeric not null Default(0),
		Q3_MP Numeric(18,2) not null Default(0),

		Q4_Salary Numeric not null Default(0),
		Q4_Income Numeric not null Default(0),
		Q4_Kyc Numeric not null Default(0),
		Q4_MP Numeric not null Default(0),

		Total_Salary Numeric not null Default(0),
		Total_Income Numeric not null Default(0),
		Total_Kyc Numeric not null Default(0),
		Total_MP Numeric not null Default(0),
		Segment_ID Numeric not null Default(0),

		Trg_MP Numeric not null Default(0),
		Trg_Kyc Numeric not null Default(0),
		Trg_MF Numeric not null Default(0),
		Trg_Insurance Numeric not null Default(0),
		Trg_Other Numeric not null Default(0),

		Arch_MP Numeric not null Default(0),
		Arch_Kyc Numeric not null Default(0),
		Arch_MF Numeric not null Default(0),
		Arch_Insurance Numeric not null Default(0),
		Arch_Other Numeric not null Default(0),

		Weightage_MP Numeric not null Default(0),
		Weightage_Kyc Numeric not null Default(0),
		Weightage_MF Numeric not null Default(0),
		Weightage_Insurance Numeric not null Default(0),
		Weightage_Other Numeric not null Default(0),
		Weightage_Total Numeric not null Default(0),

		Mark_Total Numeric not null Default(0)
	)

	Insert into #EmpRM
	(Emp_ID,Alpha_Emp_Code,Emp_Name,Branch_Code,Branch_Name,Date_of_Join,Date_of_Birth,Date_of_Resig,Emp_Join_Month,No_of_joning,No_of_Resign,Designation,Basic_Salary)
	Select 
	  EM.EMP_ID,
	  Alpha_Emp_Code,
	  Emp_Full_Name,
	  BM.Branch_Code,
	  BM.Branch_Name,
	  Replace(Convert(Varchar(11),EM.Date_Of_Join,104),'.','/') as Date_Of_Join,
	  Replace(Convert(Varchar(11),EM.Date_Of_Birth,104),'.','/') as Date_Of_Join,
	  Isnull(Replace(Convert(Varchar(11),EM.Emp_Left_Date,104),'.','/'),'NA') as Emp_Left_Date,
	  Cast(DATEDIFF(m,EM.Date_Of_Join,getdate()) as Varchar(10)) + ' Months Live' as Status,
	  Cast(DATEDIFF(m,EM.Date_Of_Join,getdate()) as Varchar(10)) as Month_of_Joining,
	  Isnull(Cast(DATEDIFF(m,EM.Emp_Left_Date,getdate()) as Varchar(10)),'NA') as Month_of_Left,
	  DM.Desig_Name,
	  Qry_1.Basic_Salary--,
	  --0,0,'','',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	From T0080_EMP_MASTER EM WITH (NOLOCK)
	Inner Join(
				Select I.Emp_ID,I.Branch_ID,I.Grd_ID,I.Desig_Id,I.Basic_Salary,I.Cmp_ID,I.Segment_ID
					From T0095_INCREMENT I WITH (NOLOCK)
				Inner Join (
							Select Max(Increment_ID) as Inc_ID,TI.Emp_ID From T0095_Increment TI WITH (NOLOCK)
								Inner Join(
											Select Max(Increment_Effective_Date) as Eff_Date,Emp_ID 
												From T0095_INCREMENT WITH (NOLOCK)
											Where Increment_Effective_Date <= @To_Date
											Group By Emp_ID
										) as Qry_1 ON TI.Emp_ID = Qry_1.Emp_ID and Qry_1.Eff_Date = TI.Increment_Effective_Date
								Group by TI.Emp_ID
							) as Qry ON Qry.Emp_ID = I.Emp_ID and Qry.Inc_ID = I.Increment_ID

				) as Qry_1  ON Qry_1.Emp_ID = EM.Emp_ID
	Inner Join T0030_BRANCH_MASTER BM WITH (NOLOCK) ON BM.Branch_ID = Qry_1.Branch_ID
	Inner join #EmpCons EC ON EM.EMP_ID = EC.Emp_ID
	Left outer Join T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON Qry_1.Desig_Id = DM.Desig_ID
	Where Qry_1.Cmp_ID = @Cmp_ID

	-- For Total Client Map 
	Update ERM 
		Set No_Map_Client = KYC_Count
	From #EmpRM ERM
	Inner Join(
				Select Count(1) as KYC_Count,EmployeeCode 
					From OT_SalesMIS.dbo.salesMIS_KYC KYC
						INNER JOIN #EmpRM ER ON KYC.EmployeeCode = ER.Alpha_Emp_Code 
				Where REGISTRATION_DATE <= CONVERT(VARCHAR(10),getdate(), 112)
				Group By EmployeeCode
			  ) as Qry
	ON ERM.Alpha_Emp_Code = Qry.EmployeeCode

	-- For Indirect Client Map
	Update ERM 
		Set No_Map_Client_Indirect = KYC_Count
	From #EmpRM ERM
	Inner Join(
				Select Count(1) as KYC_Count,EmployeeCode
					From OT_SalesMIS.dbo.salesMIS_KYC KYC 
						INNER JOIN #EmpRM ER ON KYC.EmployeeCode = ER.Alpha_Emp_Code
				Where REGISTRATION_DATE <= CONVERT(VARCHAR(10),getdate(), 112) and  Typee='Indirect'
				Group By EmployeeCode
				) as Qry
	ON ERM.Alpha_Emp_Code = Qry.EmployeeCode

	-- For Direct Client Map
	Update ERM 
		Set No_Map_Client_Direct = KYC_Count
	From #EmpRM ERM
	Inner Join(
				Select Count(1) as KYC_Count,EmployeeCode
					From OT_SalesMIS.dbo.salesMIS_KYC KYC 
						INNER JOIN #EmpRM ER ON KYC.EmployeeCode = ER.Alpha_Emp_Code
				Where REGISTRATION_DATE <= CONVERT(VARCHAR(10),getdate(), 112) and  Typee='Direct'
				Group By EmployeeCode
				) as Qry
	ON ERM.Alpha_Emp_Code = Qry.EmployeeCode

	--For Active Client Mapp
	Update ERM 
		Set No_of_Active_Cliect = KYC_Count
	From #EmpRM ERM
	Inner Join(
				Select Count(1) as KYC_Count,EmployeeCode
					From OT_SalesMIS.dbo.salesMIS_KYC KYC 
						INNER JOIN #EmpRM ER ON KYC.EmployeeCode = ER.Alpha_Emp_Code
				Where REGISTRATION_DATE >= CONVERT(VARCHAR(10),Dateadd(m,-6,getdate()), 112)
					  and REGISTRATION_DATE <= CONVERT(VARCHAR(10),getdate(), 112)
				Group By EmployeeCode
				) as Qry
	ON ERM.Alpha_Emp_Code = Qry.EmployeeCode

	-- For Get Current CTC Amount
	Select * Into #EmpCTCDetails 
	From dbo.fn_getEmpIncrementDetail(@Cmp_ID,@Constraint,@To_Date)



	Update ER	
		SET Actual_CTC_Amount = Isnull(Basic_Salary,0) + Isnull(Qry.CTCAmt,0),
		Salary_CTC = Case When (Isnull(Basic_Salary,0) + Isnull(Qry.CTCAmt,0)) > 0  Then ((Isnull(Basic_Salary,0) + Isnull(Qry.CTCAmt,0))/30) * (DATEDIFF(d,@From_Date,@To_Date) + 1) Else 0 END
	From #EmpRM ER
	Inner Join(
				Select SUM(ECD.E_AD_AMOUNT) as CTCAmt,Emp_ID 
					From #EmpCTCDetails ECD 
						Inner Join T0050_AD_MASTER AD WITH (NOLOCK) ON ECD.AD_ID = AD.AD_ID
				Where Isnull(AD_PART_OF_CTC,0) = 1 and ECD.E_AD_FLAG = 'I'
				Group BY EMP_ID
			 ) as Qry ON Qry.Emp_ID = ER.Emp_ID
	-- For Get Current CTC Amount

	Update RM
		SET Reporting_To = EM.Alpha_Emp_Code + ' - ' + EM.Emp_Full_Name 
	From V0090_EMP_REP_DETAIL_MAX ERD
	Inner Join T0090_EMP_REPORTING_DETAIL ERDD  ON ERD.Row_ID = ERDD.Row_ID 
	Inner Join T0080_EMP_MASTER EM ON EM.EMP_ID = ERDD.R_Emp_ID
	Inner Join #EmpRM RM ON ERD.EMp_ID = RM.Emp_ID

	-- For Get Regional Head Details
	Select * into #EmpRegionalHeader 
	From dbo.fn_getRegionalHead(@Cmp_ID,@Constraint,@To_Date)

	Update ER
		SET ER.Regional_Head = RH.Regional_Head
	From #EmpRM ER 
	Inner Join #EmpRegionalHeader RH ON ER.Emp_ID = RH.EMP_ID
	-- For Get Regional Head Details

	-- For Net Brokrage Amount
	Update ERM 
		Set Net_Bokrage = Net_Brokrage
	From #EmpRM ERM
	Inner Join(
				Select SUM(TOTAL_NET_BROKERAGE) AS Net_Brokrage,EmployeeeCode
				From OT_SalesMIS.dbo.SalesMIS_Revenue
					WHERE TrxDt >= @From_Date and TrxDt <= @To_Date 
				GROUP By EmployeeeCode
			  ) as Qry
	ON ERM.Alpha_Emp_Code = Qry.EmployeeeCode
	-- For Net Brokrage Amount

	Update ERM 
		Set MF = Isnull(Qry.MF,0),Insurance = Qry.IncAmt,Other = Qry.otherAmt
	From #EmpRM ERM
	Inner Join(
				Select SUM(Insurance) as IncAmt,SUM(Other) as otherAmt,SUM(MF) as MF,Emp_ID 
					From T0050_Sales_TTP_Income TTP WITH (NOLOCK)
				Where For_Date >= @From_Date and For_Date <= @To_Date
				Group By Emp_ID
			 ) as Qry
	ON ERM.Emp_ID = Qry.Emp_ID

	Update ERM 
		Set Kyc = Qry.Kyc_Count
	From #EmpRM ERM
	Inner Join(
				Select COUNT(1) as Kyc_Count,EmployeeCode
					From OT_SalesMIS.dbo.salesMIS_KYC
				WHERE REGISTRATION_DATE >= CONVERT(VARCHAR(10),@From_Date, 112) 
				AND REGISTRATION_DATE <= CONVERT(VARCHAR(10),@To_Date, 112)
				GROUP By EmployeeCode
			  ) as Qry
	ON ERM.Alpha_Emp_Code = Qry.EmployeeCode
		
	-- For Q1 For Quarter - 1 from April to Jun --start
	Declare @Quarter_Start Datetime
	Declare @Quarter_End Datetime

	Set @Quarter_Start = dbo.GET_MONTH_ST_DATE(4,Year(@From_Date))
	Set @Quarter_End = dbo.GET_MONTH_END_DATE(6,Year(@From_Date))

	Declare @Temp_Date_Quarter Datetime
	Set @Temp_Date_Quarter = NULL

	If @To_Date > @Quarter_End 
		Set @Temp_Date_Quarter = @Quarter_End
	Else
		Set @Temp_Date_Quarter = @To_Date


	Update ERM 
		Set Q1_Salary = (Isnull(Actual_CTC_Amount,0)/30) * 
				(Case 
					When Convert(Datetime,Date_of_Join,104) >= @Quarter_Start Then  
						(DATEDIFF(d,Convert(Datetime,Date_of_Join,104),@Temp_Date_Quarter) + 1)
					When IsDate(Date_of_Resig) = 1 Then
						(Case When Convert(Datetime,Date_of_Resig,104) <= @Quarter_End Then
							(DATEDIFF(d,@Quarter_Start,Convert(Datetime,Date_of_Resig,104)) + 1)
						 Else
							(DATEDIFF(d,@Quarter_Start,@Temp_Date_Quarter) + 1) 
						 End)
					Else 
						(DATEDIFF(d,@Quarter_Start,@Temp_Date_Quarter) + 1) 
				 END),
			Q1_Income = Isnull(Qry.Net_Brokrage,0),
			Q1_Kyc = Isnull(Qry_1.Kyc_Count,0)
	From #EmpRM ERM
	Left Outer Join(
				Select SUM(TOTAL_NET_BROKERAGE) AS Net_Brokrage,EmployeeeCode
				From OT_SalesMIS.dbo.SalesMIS_Revenue
					WHERE TrxDt >= @Quarter_Start and TrxDt <= @Temp_Date_Quarter 
				GROUP By EmployeeeCode
			  ) as Qry
	ON ERM.Alpha_Emp_Code = Qry.EmployeeeCode
	Left Outer Join(
				Select COUNT(1) as Kyc_Count,EmployeeCode
					From OT_SalesMIS.dbo.salesMIS_KYC
				WHERE REGISTRATION_DATE >= CONVERT(VARCHAR(10),@Quarter_Start, 112)   
					  AND REGISTRATION_DATE <= CONVERT(VARCHAR(10),@Temp_Date_Quarter, 112) 
				GROUP By EmployeeCode
			  ) as Qry_1
	ON ERM.Alpha_Emp_Code = Qry_1.EmployeeCode
	Where @Quarter_Start Between @From_Date and @To_Date
	-- For Q1 For Quarter - 1 from April to Jun --End
	
	-- For Q2 For Quarter - 2 from July to Sep --start
	Declare @Quarter_2_Start Datetime
	Declare @Quarter_2_End Datetime

	Set @Quarter_2_Start = dbo.GET_MONTH_ST_DATE(7,Year(@From_Date))
	Set @Quarter_2_End = dbo.GET_MONTH_END_DATE(9,Year(@From_Date))

	Declare @Temp_Date_Quarter_2 Datetime
	Set @Temp_Date_Quarter_2 = NULL

	If @To_Date > @Quarter_2_End 
		Set @Temp_Date_Quarter_2 = @Quarter_2_End
	Else
		Set @Temp_Date_Quarter_2 = @To_Date

	Update ERM 
		Set Q2_Salary = (Isnull(Actual_CTC_Amount,0)/30) * 
				(Case 
					When Convert(Datetime,Date_of_Join,104) >= @Quarter_2_Start Then  
						(DATEDIFF(d,Convert(Datetime,Date_of_Join,104),@Temp_Date_Quarter_2) + 1)
					When IsDate(Date_of_Resig) = 1 Then
						(Case When Convert(Datetime,Date_of_Resig,104) <= @Quarter_2_End Then
							(DATEDIFF(d,@Quarter_2_Start,Convert(Datetime,Date_of_Resig,104)) + 1)
						 Else
							(DATEDIFF(d,@Quarter_2_Start,@Temp_Date_Quarter_2) + 1) 
						 End)
					Else 
						(DATEDIFF(d,@Quarter_2_Start,@Temp_Date_Quarter_2) + 1) 
				 END),
			Q2_Income = Isnull(Qry.Net_Brokrage,0),
			Q2_Kyc = Isnull(Qry_1.Kyc_Count,0)
	From #EmpRM ERM
	Left Outer Join(
				Select SUM(TOTAL_NET_BROKERAGE) AS Net_Brokrage,EmployeeeCode
				From OT_SalesMIS.dbo.SalesMIS_Revenue
					WHERE TrxDt >= @Quarter_2_Start and TrxDt <= @Temp_Date_Quarter_2 
				GROUP By EmployeeeCode
			  ) as Qry
	ON ERM.Alpha_Emp_Code = Qry.EmployeeeCode
	Left Outer Join(
				Select COUNT(1) as Kyc_Count,EmployeeCode
					From OT_SalesMIS.dbo.salesMIS_KYC
				WHERE REGISTRATION_DATE >= CONVERT(VARCHAR(10),@Quarter_2_Start, 112)  
					  AND REGISTRATION_DATE <=  CONVERT(VARCHAR(10),@Temp_Date_Quarter_2, 112)
				GROUP By EmployeeCode
			  ) as Qry_1
	ON ERM.Alpha_Emp_Code = Qry_1.EmployeeCode
	Where @Quarter_2_Start Between @From_Date and @To_Date
	-- For Q2 For Quater - 2 from July to Sep --End
	
	-- For Q3 For Quarter - 3 from Oct to DEC --start
	Declare @Quarter_3_Start Datetime
	Declare @Quarter_3_End Datetime

	Set @Quarter_3_Start = dbo.GET_MONTH_ST_DATE(10,Year(@From_Date))
	Set @Quarter_3_End = dbo.GET_MONTH_END_DATE(12,Year(@From_Date))

	Declare @Temp_Date_Quarter_3 Datetime
	Set @Temp_Date_Quarter_3 = NULL

	If @To_Date > @Quarter_3_End 
		Set @Temp_Date_Quarter_3 = @Quarter_3_End
	Else
		Set @Temp_Date_Quarter_3 = @To_Date

	Update ERM 
		Set Q3_Salary = (Isnull(Actual_CTC_Amount,0)/30) * 
						(Case 
							When Convert(Datetime,Date_of_Join,104) >= @Quarter_3_Start Then  
								(DATEDIFF(d,Convert(Datetime,Date_of_Join,104),@Temp_Date_Quarter_3) + 1)
							When IsDate(Date_of_Resig) = 1 Then
								(Case When Convert(Datetime,Date_of_Resig,104) <= @Quarter_3_End Then
									(DATEDIFF(d,@Quarter_3_Start,Convert(Datetime,Date_of_Resig,104)) + 1)
								 Else
									(DATEDIFF(d,@Quarter_3_Start,@Temp_Date_Quarter_3) + 1) 
								 End)
							Else 
								(DATEDIFF(d,@Quarter_3_Start,@Temp_Date_Quarter_3) + 1) 
						 END),
			Q3_Income = Isnull(Qry.Net_Brokrage,0),
			Q3_Kyc = Isnull(Qry_1.Kyc_Count,0)
	From #EmpRM ERM
	Left Outer Join(
				Select SUM(TOTAL_NET_BROKERAGE) AS Net_Brokrage,EmployeeeCode
				From OT_SalesMIS.dbo.SalesMIS_Revenue
					WHERE TrxDt >= @Quarter_3_Start and TrxDt <= @Temp_Date_Quarter_3 
				GROUP By EmployeeeCode
			  ) as Qry
	ON ERM.Alpha_Emp_Code = Qry.EmployeeeCode
	Left Outer Join(
				Select COUNT(1) as Kyc_Count,EmployeeCode
					From OT_SalesMIS.dbo.salesMIS_KYC
				WHERE REGISTRATION_DATE >= CONVERT(VARCHAR(10),@Quarter_3_Start, 112)  
					 AND REGISTRATION_DATE <= CONVERT(VARCHAR(10),@Temp_Date_Quarter_3, 112)
				GROUP By EmployeeCode
			  ) as Qry_1
	ON ERM.Alpha_Emp_Code = Qry_1.EmployeeCode
	Where @Quarter_3_Start Between @From_Date and @To_Date
	-- For Q3 For Quarter - 3 from Oct to DEC --End

	-- For Q4 For Quarter - 4 from Jan to Mar --start
	Declare @Quarter_4_Start Datetime
	Declare @Quarter_4_End Datetime

	Set @Quarter_4_Start = dbo.GET_MONTH_ST_DATE(1,Year(@From_Date) + 1)
	Set @Quarter_4_End = dbo.GET_MONTH_END_DATE(3,Year(@From_Date) + 1)

	Declare @Temp_Date_Quarter_4 Datetime
	Set @Temp_Date_Quarter_4 = NULL

	If @To_Date > @Quarter_4_End 
		Set @Temp_Date_Quarter_4 = @Quarter_4_End
	Else
		Set @Temp_Date_Quarter_4 = @To_Date

	Update ERM 
		Set Q4_Salary =	 (Isnull(Actual_CTC_Amount,0)/30) * 
						(Case 
							When Convert(Datetime,Date_of_Join,104) >= @Quarter_4_Start Then  
								(DATEDIFF(d,Convert(Datetime,Date_of_Join,104),@Temp_Date_Quarter_4) + 1)
							When IsDate(Date_of_Resig) = 1 Then
								(Case When Convert(Datetime,Date_of_Resig,104) <= @Quarter_4_End Then
									(DATEDIFF(d,@Quarter_4_Start,Convert(Datetime,Date_of_Resig,104)) + 1)
								 Else
									(DATEDIFF(d,@Quarter_4_Start,@Temp_Date_Quarter_4) + 1) 
								 End)
							Else 
								(DATEDIFF(d,@Quarter_4_Start,@Temp_Date_Quarter_4) + 1) 
						 END),
			Q4_Income = Isnull(Qry.Net_Brokrage,0),
			Q4_Kyc = Isnull(Qry_1.Kyc_Count,0)
	From #EmpRM ERM
	Left Outer Join(
				Select SUM(TOTAL_NET_BROKERAGE) AS Net_Brokrage,EmployeeeCode
				From OT_SalesMIS.dbo.SalesMIS_Revenue
					WHERE TrxDt >= @Quarter_4_Start and TrxDt <= @Temp_Date_Quarter_4 
				GROUP By EmployeeeCode
			  ) as Qry
	ON ERM.Alpha_Emp_Code = Qry.EmployeeeCode
	Left Outer Join(
				Select COUNT(1) as Kyc_Count,EmployeeCode
					From OT_SalesMIS.dbo.salesMIS_KYC
				WHERE REGISTRATION_DATE >= CONVERT(VARCHAR(10),@Quarter_4_Start, 112)
					  AND REGISTRATION_DATE <= CONVERT(VARCHAR(10),@Temp_Date_Quarter_4, 112)
				GROUP By EmployeeCode
			  ) as Qry_1
	ON ERM.Alpha_Emp_Code = Qry_1.EmployeeCode
	Where @Quarter_4_Start Between @From_Date and @To_Date
	-- For Q4 For Quarter - 3 from Oct to DEC --End


	-- For Total from Apr to Mar --start
	Declare @Quarter_Total_Start Datetime
	Declare @Quarter_Total_End Datetime

	Set @Quarter_Total_Start = dbo.GET_MONTH_ST_DATE(4,Year(@From_Date))
	Set @Quarter_Total_End = dbo.GET_MONTH_END_DATE(3,Year(@From_Date)+1)

	Declare @Temp_Date_Total_Quarter Datetime
	Set @Temp_Date_Total_Quarter = NULL

	If @To_Date > @Quarter_Total_End 
		Set @Temp_Date_Total_Quarter = @Quarter_Total_End
	Else
		Set @Temp_Date_Total_Quarter = @To_Date
	
	Update ERM 
		Set Total_Salary = (Isnull(Actual_CTC_Amount,0)/30) * 
								(Case 
									When Convert(Datetime,Date_of_Join,104) >= @Quarter_Total_End Then  
										(DATEDIFF(d,Convert(Datetime,Date_of_Join,104),@Temp_Date_Total_Quarter) + 1)
									When IsDate(Date_of_Resig) = 1 Then
										(Case When Convert(Datetime,Date_of_Resig,104) <= @Quarter_Total_End Then
											(DATEDIFF(d,@Quarter_Total_Start,Convert(Datetime,Date_of_Resig,104)) + 1)
										 Else
											(DATEDIFF(d,@Quarter_Total_Start,@Temp_Date_Total_Quarter) + 1) 
										 End)
									Else 
										(DATEDIFF(d,@Quarter_Total_Start,@Temp_Date_Total_Quarter) + 1) 
								 END),
			Total_Income = Isnull(Qry.Net_Brokrage,0),
			Total_Kyc = Isnull(Qry_1.Kyc_Count,0)
	From #EmpRM ERM
	Left Outer Join(
				Select SUM(TOTAL_NET_BROKERAGE) AS Net_Brokrage,EmployeeeCode
				From OT_SalesMIS.dbo.SalesMIS_Revenue
					WHERE TrxDt >= @Quarter_Total_Start and TrxDt <= @Temp_Date_Total_Quarter 
				GROUP By EmployeeeCode
			  ) as Qry
	ON ERM.Alpha_Emp_Code = Qry.EmployeeeCode
	Left Outer Join(
				Select COUNT(1) as Kyc_Count,EmployeeCode
					From OT_SalesMIS.dbo.salesMIS_KYC
				WHERE REGISTRATION_DATE >= CONVERT(VARCHAR(10),@Quarter_Total_Start, 112) 
					  AND REGISTRATION_DATE <= CONVERT(VARCHAR(10),@Temp_Date_Total_Quarter, 112)
				GROUP By EmployeeCode
			  ) as Qry_1
	ON ERM.Alpha_Emp_Code = Qry_1.EmployeeCode
	Where @Quarter_Total_Start Between @From_Date and @To_Date
	-- For Q3 For Quater - 3 from Oct to DEC --End

	Update ERM 
		Set Total_Inc = Net_Bokrage + MF + Insurance + Other, 
			MP = (Net_Bokrage + MF + Insurance + Other) / (Case When Isnull(Salary_CTC,0) = 0 Then 1 Else Salary_CTC END),
			Q1_MP = Isnull(Q1_Income,0) / (Case When Q1_Salary = 0 then 1 Else Q1_Salary End),
			Q2_MP = Isnull(Q2_Income,0) / (Case When Q2_Salary = 0 then 1 Else Q2_Salary End),
			Q3_MP = Isnull(Q3_Income,0) / (Case When Q3_Salary = 0 then 1 Else Q3_Salary End),
			Q4_MP = Isnull(Q4_Income,0) / (Case When Q4_Salary = 0 then 1 Else Q4_Salary End),
			Total_MP = Isnull(Total_Income,0) / (Case When Total_Salary = 0 then 1 Else Total_Salary End)
	From #EmpRM ERM

	Select * From #EmpRM


END

