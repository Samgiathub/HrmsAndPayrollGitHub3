
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Employee_Revenue_Details]
	@Cmp_ID Numeric,
	@Emp_ID Numeric,
	@From_Date Datetime,
	@To_Date Datetime,
	@Constraint Varchar(max) = '',
	@Bussiness_Level Numeric = 0,
	@Type Varchar(10) = NULL,
	@ChkRM Numeric = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	IF @Type = '--ALL--'
		Set @Type = NULL
		
	
	Declare @Comp_From_Date Datetime
	Declare @Comp_To_Date Datetime
	Declare @Today_Date Datetime
	
	Set @Today_Date = @To_Date 
	Set @To_Date = DateAdd(D,-1,@To_Date)

	Print @From_Date 
	Print @To_Date
	Print @Today_Date
	
	Set @Comp_From_Date = DateAdd(m,-1,@From_Date)
	Set @Comp_To_Date = DateAdd(m,-1,@To_Date)
	
	If Object_ID('tempdb..#Emp_Downline') is not null
		Begin
			Drop TABLE #Emp_Downline
		End
		
	Create Table #Emp_Downline
	(
	  Alpha_Emp_Code Varchar(100),
	  Caption Varchar(100),
	  Emp_ID Numeric,
	  R_Level Numeric,
	  P_ID Numeric,
	  SUB_BRANCH_CODE Varchar(100),
	  
	  Com_Traded_Curr Numeric(18,0) not null default(0),
	  Com_Fo_To_Curr Numeric(18,2) not null default(0),
	  Com_Gb_Curr Numeric(18,2) not null default(0),
	  Com_Nb_Curr Numeric(18,2) not null default(0),
	  Com_Traded_Prev Numeric(18,0) not null default(0),
	  Com_Fo_To_Prev Numeric(18,2) not null default(0),
	  Com_Gb_Prev Numeric(18,2) not null default(0),
	  Com_Nb_Prev Numeric(18,2) not null default(0),
	  Com_Kyc Numeric(18,0) not null default(0),
	  
	  Cash_Traded_Curr Numeric(18,0) not null default(0),
	  Cash_Fo_To_Curr Numeric(18,2) not null default(0),
	  Cash_Gb_Curr Numeric(18,2) not null default(0),
	  Cash_Nb_Curr Numeric(18,2) not null default(0),
	  Cash_Traded_Prev Numeric(18,0) not null default(0),
	  Cash_Fo_To_Prev Numeric(18,2) not null default(0),
	  Cash_Gb_Prev Numeric(18,2) not null default(0),
	  Cash_Nb_Prev Numeric(18,2) not null default(0),
	  Cash_Kyc Numeric(18,0) not null default(0),
	  
	  Eq_Traded_Curr Numeric(18,0) not null default(0),
	  Eq_Eq_To_Curr Numeric(18,2) not null default(0),
	  Eq_Fo_To_Curr Numeric(18,2) not null default(0),
	  Eq_Total_To_Curr Numeric(18,2) not null default(0),
	  Eq_Gb_Curr Numeric(18,2) not null default(0),
	  Eq_Nb_Curr Numeric(18,2) not null default(0),
	  
	  Eq_Traded_Prev Numeric(18,0) not null default(0),
	  Eq_Eq_To_Prev Numeric(18,2) not null default(0),
	  Eq_Fo_To_Prev Numeric(18,2) not null default(0),
	  Eq_Total_To_Prev Numeric(18,2) not null default(0),
	  Eq_Gb_Prev Numeric(18,2) not null default(0),
	  Eq_Nb_Prev Numeric(18,2) not null default(0),
	  Eq_Key Numeric(18,2) not null default(0),
	  
	  Curr_Traded Numeric(18,0) not null default(0),
	  Curr_Eq_To Numeric(18,2) not null default(0),
	  Curr_Fo_To Numeric(18,2) not null default(0),
	  Curr_Total_To Numeric(18,2) not null default(0),
	  Curr_Gb Numeric(18,2) not null default(0),
	  Curr_Nb Numeric(18,2) not null default(0),
	  
	  Prev_Traded Numeric(18,0) not null default(0),
	  Prev_Eq_To Numeric(18,2) not null default(0),
	  Prev_Fo_To Numeric(18,2) not null default(0),
	  Prev_Total_To Numeric(18,2) not null default(0),
	  Prev_Gb Numeric(18,2) not null default(0),
	  Prev_Nb Numeric(18,2) not null default(0),
	  Prev_KYC Numeric(18,2) not null default(0),
	  
	  Comp_Nb Numeric(18,2) not null default(0),
	  Emp_Group_ID Numeric not null default(0),
	  Display_ID Numeric not null default(0)
	)
	
	 If Object_ID('tempdb..#Emp_Caption') is not null
		Begin
			Drop TABLE #Emp_Caption
		End
		
	Create Table #Emp_Caption
	(
		ROW_ID	INT IDENTITY(1,1),
		CMP_ID Numeric,
		EMp_ID Numeric,
		R_Emp_ID Numeric,
		R_Level Numeric,
		Alpha_Emp_Code Varchar(20),
		Emp_Full_NAME Varchar(100),
		Segment_ID Numeric Not Null Default(0),
		EM_Branch Varchar(50)
	)
	
	If Object_ID('tempdb..#Emp_Sub_Branch') is not null
		Begin
			Drop TABLE #Emp_Sub_Branch
		End
		
	Create Table #Emp_Sub_Branch
	(
		P_ID NUMERIC,
		EMP_ID NUMERIC,
		CAPTION VARCHAR(200),
		C_ID NUMERIC,
		SUB_BRANCH_CODE VARCHAR(200)--,
		--Bussiness_Level	Numeric--,
		--UniqueID	Varchar(128)
	)
	
	IF Object_ID('tempdb..#Emp_Cons') is not null
		Begin
			Drop TABLE #Emp_Cons
		End
	
	Create Table #Emp_Cons
	(
		Emp_ID Numeric
	)
	
	
	if @Constraint <> ''
		Begin
			Insert into #Emp_Cons
			Select Data From dbo.Split(@Constraint,'#')
		End
		
	Declare Cur_Emp Cursor For
		Select Emp_ID From #Emp_Cons
	Open Cur_Emp
	fetch next from Cur_Emp into @Emp_ID 
		While @@fetch_status = 0
			Begin
				if @Bussiness_Level = 6 or @Bussiness_Level = 7
					Begin
						Exec SP_Employee_Revenue_Hierarchy_Sales @Cmp_ID,@Emp_ID,@From_Date,@To_Date,@Bussiness_Level
					End
				--Else If @Bussiness_Level <= 3 
				--	Begin
				--		Exec SP_Employee_Revenue_Hierarchy_RH @Cmp_ID,@Emp_ID,@From_Date,@To_Date,@Bussiness_Level
				--	End
				Else
					Begin
						Exec SP_Employee_Revenue_Hierarchy @Cmp_ID,@Emp_ID,@From_Date,@To_Date,@Bussiness_Level
					End
				fetch next from Cur_Emp into @Emp_ID 
			End
	CLOSE Cur_Emp   
	DEALLOCATE Cur_Emp	

	
	-- For Commuditity Calculation Start 
	Update ED
		SET Com_Traded_Prev = Isnull(Qry.Traded,0),
			Com_Fo_To_Prev = Isnull(Qry.Total_Turnover,0), 
		    Com_Gb_Prev = Isnull(Qry.Total_Brokrage,0),
		    Com_Nb_Prev = Isnull(Qry.Net_Brokrage,0),
		    Com_Traded_Curr = Isnull(Qry_1.Traded,0),
		    Com_Fo_To_Curr = Isnull(Qry_1.Total_Turnover,0),
		    Com_Gb_Curr = Isnull(Qry_1.Total_Brokrage,0),
		    Com_Nb_Curr = Isnull(Qry_1.Net_Brokrage,0)
	From #Emp_Downline ED
	 Left Outer JOIN(
					Select COUNT(distinct CLIENT_ID) as Traded ,SUM(TOTAL_TURNOVER) as Total_Turnover, SUM(TOTAL_BROKERAGE) AS Total_Brokrage , 
						   SUM(TOTAL_NET_BROKERAGE) AS Net_Brokrage,
						   EmployeeeCode,SUB_BRANCH_CODE
					From [OT_SalesMIS].dbo.SalesMIS_Revenue
					WHERE TrxDt >= @From_Date and TrxDt <= @To_Date and Segment = 'Com' and RevenueType = Isnull(@Type,RevenueType)
					GROUP By EmployeeeCode,SUB_BRANCH_CODE
				) as Qry
		ON ED.Alpha_Emp_Code = Qry.EmployeeeCode and ED.SUB_BRANCH_CODE = Qry.SUB_BRANCH_CODE 
	 Left Outer JOIN(
					Select COUNT(distinct CLIENT_ID) as Traded ,SUM(TOTAL_TURNOVER) as Total_Turnover, SUM(TOTAL_BROKERAGE) AS Total_Brokrage , 
						   SUM(TOTAL_NET_BROKERAGE) AS Net_Brokrage,
						   EmployeeeCode,SUB_BRANCH_CODE
					From [OT_SalesMIS].dbo.SalesMIS_Revenue
					WHERE TrxDt = @Today_Date and Segment = 'Com' and RevenueType = Isnull(@Type,RevenueType)
					GROUP By EmployeeeCode,SUB_BRANCH_CODE
				) as Qry_1
		ON ED.Alpha_Emp_Code = Qry_1.EmployeeeCode and ED.SUB_BRANCH_CODE = Qry_1.SUB_BRANCH_CODE 
	--Where ED.R_Level = 1
	-- For Commuditity Calculation End 
	
	-- For Currency Calculation Start 
	Update ED
		SET 
			Cash_Traded_Prev = Isnull(Qry.Traded,0),
			Cash_Fo_To_Prev = Isnull(Qry.Total_Turnover,0),
			Cash_Gb_Prev = Isnull(Qry.Total_Brokrage,0),
			Cash_Nb_Prev = Isnull(Qry.Net_Brokrage,0),
		    Cash_Traded_Curr = Isnull(Qry_1.Traded,0),
			Cash_Fo_To_Curr = Isnull(Qry_1.Total_Turnover,0),
			Cash_Gb_Curr = Isnull(Qry_1.Total_Brokrage,0),
			Cash_Nb_Curr = Isnull(Qry_1.Net_Brokrage,0)
	 From #Emp_Downline ED
	 Left Outer JOIN(
					Select COUNT(distinct CLIENT_ID) as Traded ,SUM(TOTAL_TURNOVER) as Total_Turnover, SUM(TOTAL_BROKERAGE) AS Total_Brokrage , 
						   SUM(TOTAL_NET_BROKERAGE) AS Net_Brokrage,
						   EmployeeeCode,SUB_BRANCH_CODE
					From [OT_SalesMIS].dbo.SalesMIS_Revenue
					WHERE TrxDt >= @From_Date and TrxDt <= @To_Date and Segment = 'Curr' and RevenueType = Isnull(@Type,RevenueType)
					GROUP By EmployeeeCode,SUB_BRANCH_CODE
				) as Qry
		ON ED.Alpha_Emp_Code = Qry.EmployeeeCode and ED.SUB_BRANCH_CODE = Qry.SUB_BRANCH_CODE 
	 Left Outer JOIN(
					Select COUNT(distinct CLIENT_ID) as Traded ,SUM(TOTAL_TURNOVER) as Total_Turnover, SUM(TOTAL_BROKERAGE) AS Total_Brokrage , 
						   SUM(TOTAL_NET_BROKERAGE) AS Net_Brokrage,
						   EmployeeeCode,SUB_BRANCH_CODE
					From [OT_SalesMIS].dbo.SalesMIS_Revenue
					WHERE TrxDt = @Today_Date and Segment = 'Curr' and RevenueType = Isnull(@Type,RevenueType)
					GROUP By EmployeeeCode,SUB_BRANCH_CODE
				) as Qry_1
		ON ED.Alpha_Emp_Code = Qry_1.EmployeeeCode and ED.SUB_BRANCH_CODE = Qry_1.SUB_BRANCH_CODE 
	--Where ED.R_Level = 1
	-- For Currency Calculation End	
	
	-- For Equtity Calculation Start 
	Update ED
		SET 
			Eq_Traded_Curr = ISNULL(Qry_1.Traded,0),
		    --Eq_Eq_To_Curr = ISNULL(Qry_1.Eq_To,0),
		    Eq_Fo_To_Curr = ISNULL(Qry_1.Total_Turnover,0),
		    Eq_Total_To_Curr = ISNULL(Qry_1.Total_To,0),
		    Eq_Gb_Curr = ISNULL(Qry_1.Total_Brokrage,0),
		    Eq_Nb_Curr = ISNULL(Qry_1.Net_Brokrage,0),
		    
		    Eq_Traded_Prev = ISNULL(Qry.Traded,0),
			--Eq_Eq_To_Prev = ISNULL(Qry.Eq_To,0),
			Eq_Fo_To_Prev = ISNULL(Qry.Total_Turnover,0),
			Eq_Total_To_Prev = ISNULL(Qry.Total_To,0),
			Eq_Gb_Prev = ISNULL(Qry.Total_Brokrage,0),
			Eq_Nb_Prev = ISNULL(Qry.Net_Brokrage,0)
		 From #Emp_Downline ED
		 Left Outer JOIN(
						Select COUNT(distinct CLIENT_ID) as Traded,
							   --(Case WHEN Segment = 'FnO' Then SUM(TOTAL_TURNOVER) ELSE 0 END) as Total_Turnover, 
							   --(Case WHEN Segment = 'Cash' Then SUM(TOTAL_TURNOVER) ELSE 0 END) as Eq_To, 
							   SUM(TOTAL_TURNOVER) as Total_Turnover,
							   SUM(TOTAL_TURNOVER) AS Total_To, 
							   SUM(TOTAL_BROKERAGE) AS Total_Brokrage, 
							   SUM(TOTAL_NET_BROKERAGE) AS Net_Brokrage,
							   EmployeeeCode,SUB_BRANCH_CODE
						From [OT_SalesMIS].dbo.SalesMIS_Revenue
						WHERE TrxDt >= @From_Date and TrxDt <= @To_Date and Segment = 'FnO' and RevenueType = Isnull(@Type,RevenueType) -- and Segment IN('Cash','FnO')
						GROUP By EmployeeeCode,SUB_BRANCH_CODE
					) as Qry
		 ON ED.Alpha_Emp_Code = Qry.EmployeeeCode and ED.SUB_BRANCH_CODE = Qry.SUB_BRANCH_CODE
		 Left Outer JOIN(
						Select COUNT(distinct CLIENT_ID) as Traded ,
							   SUM(TOTAL_TURNOVER) as Total_Turnover,
							   SUM(TOTAL_TURNOVER) AS Total_To, 
							   SUM(TOTAL_BROKERAGE) AS Total_Brokrage, 
							   SUM(TOTAL_NET_BROKERAGE) AS Net_Brokrage,
							   EmployeeeCode,SUB_BRANCH_CODE
						From [OT_SalesMIS].dbo.SalesMIS_Revenue
						WHERE TrxDt = @Today_Date and Segment = 'FnO'  and RevenueType = Isnull(@Type,RevenueType)
						GROUP By EmployeeeCode,SUB_BRANCH_CODE
					) as Qry_1
		 ON ED.Alpha_Emp_Code = Qry_1.EmployeeeCode and ED.SUB_BRANCH_CODE = Qry_1.SUB_BRANCH_CODE

	Update ED
		SET 
			Eq_Traded_Curr = Eq_Traded_Curr + ISNULL(Qry_1.Traded,0),
		    --Eq_Eq_To_Curr = ISNULL(Qry_1.Eq_To,0),
		    Eq_Eq_To_Curr = Eq_Eq_To_Curr + ISNULL(Qry_1.Eq_To,0),
		    Eq_Total_To_Curr = Eq_Total_To_Curr + ISNULL(Qry_1.Total_To,0),
		    Eq_Gb_Curr = Eq_Gb_Curr + ISNULL(Qry_1.Total_Brokrage,0),
		    Eq_Nb_Curr = Eq_Nb_Curr + ISNULL(Qry_1.Net_Brokrage,0),
		    
		    Eq_Traded_Prev = Eq_Traded_Prev + ISNULL(Qry.Traded,0),
			--Eq_Eq_To_Prev = ISNULL(Qry.Eq_To,0),
			Eq_Eq_To_Prev = Eq_Eq_To_Prev + ISNULL(Qry.Eq_To,0),
			Eq_Total_To_Prev = Eq_Total_To_Prev + ISNULL(Qry.Total_To,0),
			Eq_Gb_Prev = Eq_Gb_Prev + ISNULL(Qry.Total_Brokrage,0),
			Eq_Nb_Prev = Eq_Nb_Prev + ISNULL(Qry.Net_Brokrage,0)
		 From #Emp_Downline ED
		 Left Outer JOIN(
						Select COUNT(distinct CLIENT_ID) as Traded ,
							   SUM(TOTAL_TURNOVER) as Eq_To,
							   SUM(TOTAL_TURNOVER) AS Total_To, 
							   SUM(TOTAL_BROKERAGE) AS Total_Brokrage, 
							   SUM(TOTAL_NET_BROKERAGE) AS Net_Brokrage,
							   EmployeeeCode,SUB_BRANCH_CODE
						From [OT_SalesMIS].dbo.SalesMIS_Revenue
						WHERE TrxDt >= @From_Date and TrxDt <= @To_Date and Segment = 'Cash' and RevenueType = Isnull(@Type,RevenueType) -- and Segment IN('Cash','FnO')
						GROUP By EmployeeeCode,SUB_BRANCH_CODE
					) as Qry
		 ON ED.Alpha_Emp_Code = Qry.EmployeeeCode and ED.SUB_BRANCH_CODE = Qry.SUB_BRANCH_CODE
		 Left Outer JOIN(
						Select COUNT(distinct CLIENT_ID) as Traded ,
							   --(Case WHEN Segment = 'FnO' Then SUM(TOTAL_TURNOVER) ELSE 0 END) as Total_Turnover, 
							   --(Case WHEN Segment = 'Cash' Then SUM(TOTAL_TURNOVER) ELSE 0 END) as Eq_To, 
							   SUM(TOTAL_TURNOVER) as Eq_To,
							   SUM(TOTAL_TURNOVER) AS Total_To, 
							   SUM(TOTAL_BROKERAGE) AS Total_Brokrage, 
							   SUM(TOTAL_NET_BROKERAGE) AS Net_Brokrage,
							   EmployeeeCode,SUB_BRANCH_CODE
						From [OT_SalesMIS].dbo.SalesMIS_Revenue
						WHERE TrxDt = @Today_Date and Segment = 'Cash' and RevenueType = Isnull(@Type,RevenueType) -- and Segment IN('Cash','FnO')
						GROUP By EmployeeeCode,SUB_BRANCH_CODE
					) as Qry_1
		 ON ED.Alpha_Emp_Code = Qry_1.EmployeeeCode and ED.SUB_BRANCH_CODE = Qry_1.SUB_BRANCH_CODE
	--Where ED.R_Level = 1
	-- For Equtity Calculation End 	
	
	-- For KYC Count 	
	Update ED
		SET Com_Kyc = Case When Qry.BusinessLine = 'Com' Then Qry.Kyc_Count ELSE 0  END,
			Cash_Kyc  = Case When Qry_1.BusinessLine = 'Curr' Then Qry_1.Kyc_Count ELSE 0  END,
			Eq_Key = Isnull(Eq_Key,0) + (Case When Qry_2.BusinessLine = 'Cash' Then  Qry_2.Kyc_Count ELSE 0 END) + (Case WHEN Qry_3.BusinessLine = 'FnO' THEN Qry_3.Kyc_Count ELSE 0  END)
	From #Emp_Downline ED
	 Left outer JOIN(
					Select COUNT(1) as Kyc_Count,EmployeeCode,BusinessLine,SUB_BRANCH_CODE
					From [OT_SalesMIS].dbo.salesMIS_KYC
					WHERE REGISTRATION_DATE >= Replace(CONVERT(varchar(11),@From_Date,102),'.','')   AND REGISTRATION_DATE <=Replace(CONVERT(varchar(11),@To_Date,102),'.','') 
					and BusinessLine = 'Com' AND Typee = Isnull(@Type,Typee) 
					GROUP By EmployeeCode,BusinessLine,SUB_BRANCH_CODE
				) as Qry
	 ON ED.Alpha_Emp_Code = Qry.EmployeeCode and ED.SUB_BRANCH_CODE = Qry.SUB_BRANCH_CODE
	 Left outer JOIN(
					Select COUNT(1) as Kyc_Count,EmployeeCode,BusinessLine,SUB_BRANCH_CODE
					From [OT_SalesMIS].dbo.salesMIS_KYC
					WHERE REGISTRATION_DATE >= Replace(CONVERT(varchar(11),@From_Date,102),'.','')  AND REGISTRATION_DATE <=Replace(CONVERT(varchar(11),@To_Date,102),'.','') 
					and BusinessLine = 'Curr' AND Typee = Isnull(@Type,Typee) 
					GROUP By EmployeeCode,BusinessLine,SUB_BRANCH_CODE
				) as Qry_1
	 ON ED.Alpha_Emp_Code = Qry_1.EmployeeCode and ED.SUB_BRANCH_CODE = Qry_1.SUB_BRANCH_CODE
	 Left outer JOIN(
					Select COUNT(1) as Kyc_Count,EmployeeCode,BusinessLine,SUB_BRANCH_CODE
					From [OT_SalesMIS].dbo.salesMIS_KYC
					WHERE REGISTRATION_DATE >= Replace(CONVERT(varchar(11),@From_Date,102),'.','')  AND REGISTRATION_DATE <=Replace(CONVERT(varchar(11),@To_Date,102),'.','') 
					and BusinessLine = 'Cash' AND Typee = Isnull(@Type,Typee) 
					GROUP By EmployeeCode,BusinessLine,SUB_BRANCH_CODE
				) as Qry_2
	ON ED.Alpha_Emp_Code = Qry_2.EmployeeCode and ED.SUB_BRANCH_CODE = Qry_2.SUB_BRANCH_CODE
	 Left outer JOIN(
					Select COUNT(1) as Kyc_Count,EmployeeCode,BusinessLine,SUB_BRANCH_CODE
					From [OT_SalesMIS].dbo.salesMIS_KYC
					WHERE REGISTRATION_DATE >=Replace(CONVERT(varchar(11),@From_Date,102),'.','')  AND REGISTRATION_DATE <=Replace(CONVERT(varchar(11),@To_Date,102),'.','') 
					and BusinessLine = 'FnO' AND Typee = Isnull(@Type,Typee) 
					GROUP By EmployeeCode,BusinessLine,SUB_BRANCH_CODE
				) as Qry_3
	 ON ED.Alpha_Emp_Code = Qry_3.EmployeeCode and ED.SUB_BRANCH_CODE = Qry_3.SUB_BRANCH_CODE
	-- Where ED.R_Level = 1
	-- For KYC Count
	
	--For Current Date All Segment wise Details
	Update ED
		SET 
			Curr_Traded  = Isnull(Qry.Traded,0),
			Curr_Eq_To = ISNULL(Qry.Eq_To,0),
			Curr_Fo_To = Isnull(Qry.Total_Turnover,0),
			Curr_Total_To = Isnull(Qry.Total_To,0),
			Curr_Gb = Isnull(Qry.Total_Brokrage,0),
			Curr_Nb = Isnull(Qry.Net_Brokrage,0)
	From #Emp_Downline ED
	 Left Outer JOIN(
					Select COUNT(distinct CLIENT_ID) as Traded ,
							   SUM((Case WHEN Segment <> 'Cash' Then TOTAL_TURNOVER ELSE 0 END)) as Total_Turnover, 
							 SUM((Case WHEN Segment = 'Cash' Then TOTAL_TURNOVER ELSE 0 END)) as Eq_To, 
							   SUM(TOTAL_TURNOVER) AS Total_To, 
							   SUM(TOTAL_BROKERAGE) AS Total_Brokrage, 
							   SUM(TOTAL_NET_BROKERAGE) AS Net_Brokrage,
							   EmployeeeCode,SUB_BRANCH_CODE
					From [OT_SalesMIS].dbo.SalesMIS_Revenue
					WHERE TrxDt = @Today_Date and RevenueType = Isnull(@Type,RevenueType)
					GROUP By EmployeeeCode,SUB_BRANCH_CODE
				) as Qry
		ON ED.Alpha_Emp_Code = Qry.EmployeeeCode and ED.SUB_BRANCH_CODE = Qry.SUB_BRANCH_CODE
	--Where ED.R_Level = 1
	--For Current Date All Segment wise Details
	
	--For From and To Date Wise All Segment wise Details
	Update ED
		SET 
			Prev_Traded  = Isnull(Qry.Traded,0),
			Prev_Eq_To = ISNULL(Qry.Eq_To,0),
			Prev_Fo_To = Isnull(Qry.Total_Turnover,0),
			Prev_Total_To = Isnull(Qry.Total_To,0),
			Prev_Gb = Isnull(Qry.Total_Brokrage,0),
			Prev_Nb = Isnull(Qry.Net_Brokrage,0)
	From #Emp_Downline ED
	 Left Outer JOIN(
					Select COUNT(distinct CLIENT_ID) as Traded ,
							   SUM((Case WHEN Segment <> 'Cash' Then TOTAL_TURNOVER ELSE 0 END)) as Total_Turnover, 
							   SUM((Case WHEN Segment = 'Cash' Then TOTAL_TURNOVER ELSE 0 END)) as Eq_To, 
							   SUM(TOTAL_TURNOVER) AS Total_To, 
							   SUM(TOTAL_BROKERAGE) AS Total_Brokrage, 
							   SUM(TOTAL_NET_BROKERAGE) AS Net_Brokrage,
							   EmployeeeCode,SUB_BRANCH_CODE
					From [OT_SalesMIS].dbo.SalesMIS_Revenue
					WHERE TrxDt >= @From_Date and TrxDt <= @To_Date and RevenueType = Isnull(@Type,RevenueType)
					GROUP By EmployeeeCode,SUB_BRANCH_CODE
				) as Qry
		ON ED.Alpha_Emp_Code = Qry.EmployeeeCode and ED.SUB_BRANCH_CODE = Qry.SUB_BRANCH_CODE
	--Where ED.R_Level = 1
	--For From and To Date Wise All Segment wise Details
	 
	--For Key Wise Details 
	Update ED
		SET 
			Prev_KYC = Isnull(Qry.Kyc_Count,0)
	From #Emp_Downline ED
	 Inner JOIN(
					Select COUNT(1) as Kyc_Count,EmployeeCode,SUB_BRANCH_CODE
					From [OT_SalesMIS].dbo.salesMIS_KYC
					WHERE REGISTRATION_DATE >= Replace(CONVERT(varchar(11),@From_Date,102),'.','')  AND REGISTRATION_DATE <= Replace(CONVERT(varchar(11),@To_Date,102),'.','') AND Typee = Isnull(@Type,Typee)  
					GROUP By EmployeeCode,SUB_BRANCH_CODE
				) as Qry
	 ON ED.Alpha_Emp_Code = Qry.EmployeeCode and ED.SUB_BRANCH_CODE = Qry.SUB_BRANCH_CODE and ED.Alpha_Emp_Code IS NOT NULL
	-- Where ED.R_Level = 1
	--For Key Wise Details 
	
	
	
	--For Net Brokrage Last Compare Month
	Update ED
		SET Comp_Nb = Isnull(Qry.Net_Brokrage,0)
	From #Emp_Downline ED
	 Left Outer JOIN(
					Select SUM(TOTAL_NET_BROKERAGE) AS Net_Brokrage,
							   EmployeeeCode,SUB_BRANCH_CODE
					From [OT_SalesMIS].dbo.SalesMIS_Revenue
					WHERE TrxDt >= @Comp_From_Date and TrxDt <= @Comp_To_Date and RevenueType = Isnull(@Type,RevenueType)
					GROUP By EmployeeeCode,SUB_BRANCH_CODE
				) as Qry
		ON ED.Alpha_Emp_Code = Qry.EmployeeeCode and ED.SUB_BRANCH_CODE = Qry.SUB_BRANCH_CODE
	--Where ED.R_Level = 1
	--For Net Brokrage Last Compare Month
	
	
	
	-- For Branch Wise Sum
	Update ED
			Set	
				Com_Traded_Curr = Qry.Com_Traded_Curr,
				Com_Fo_To_Curr = Qry.Com_Fo_To_Curr,
				Com_Gb_Curr = Qry.Com_Gb_Curr,
				Com_Nb_Curr = Qry.Com_Nb_Curr,
				Com_Traded_Prev = Qry.Com_Traded_Prev,
				Com_Fo_To_Prev = Qry.Com_Fo_To_Prev,
				Com_Gb_Prev = Qry.Com_Gb_Prev,
				Com_Nb_Prev = Qry.Com_Nb_Prev,
				Com_Kyc = Qry.Com_Kyc,
				Cash_Traded_Curr = Qry.Cash_Traded_Curr,
				Cash_Fo_To_Curr = Qry.Cash_Fo_To_Curr,
				Cash_Gb_Curr = Qry.Cash_Gb_Curr,
				Cash_Nb_Curr = Qry.Cash_Nb_Curr,
				Cash_Traded_Prev = Qry.Cash_Traded_Prev,
				Cash_Fo_To_Prev = Qry.Cash_Fo_To_Prev,
				Cash_Gb_Prev = Qry.Cash_Gb_Prev,
				Cash_Nb_Prev = Qry.Cash_Nb_Prev,
				Cash_Kyc = Qry.Cash_Kyc,
				Eq_Traded_Curr = Qry.Eq_Traded_Curr,
				Eq_Eq_To_Curr = Qry.Eq_Eq_To_Curr,
				Eq_Fo_To_Curr = Qry.Eq_Fo_To_Curr,
				Eq_Total_To_Curr = Qry.Eq_Total_To_Curr,
				Eq_Gb_Curr = Qry.Eq_Gb_Curr,
				Eq_Nb_Curr = Qry.Eq_Nb_Curr,
				Eq_Traded_Prev = Qry.Eq_Traded_Prev,
				Eq_Eq_To_Prev = Qry.Eq_Eq_To_Prev,
				Eq_Fo_To_Prev = Qry.Eq_Fo_To_Prev,
				Eq_Total_To_Prev = Qry.Eq_Total_To_Prev,
				Eq_Gb_Prev = Qry.Eq_Gb_Prev,
				Eq_Nb_Prev = Qry.Eq_Nb_Prev,
				Eq_Key = Qry.Eq_Key,
				Curr_Traded = Qry.Curr_Traded,
				Curr_Eq_To = Qry.Curr_Eq_To,
				Curr_Fo_To = Qry.Curr_Fo_To,
				Curr_Total_To = Qry.Curr_Total_To,
				Curr_Gb = Qry.Curr_Gb,
				Curr_Nb = Qry.Curr_Nb,
				Prev_Traded = Qry.Prev_Traded,
				Prev_Eq_To = Qry.Prev_Eq_To,
				Prev_Fo_To = Qry.Prev_Fo_To,
				Prev_Total_To = Qry.Prev_Total_To,
				Prev_Gb = Qry.Prev_Gb,
				Prev_Nb = Qry.Prev_Nb,
				Prev_KYC = Qry.Prev_KYC,
				Comp_Nb = Qry.Comp_Nb
		From #Emp_Downline ED
			Inner JOIN(
						Select  SUB_BRANCH_CODE,
								Emp_Group_ID,
								SUM(Com_Traded_Curr) As Com_Traded_Curr,
								SUM(Com_Fo_To_Curr) As Com_Fo_To_Curr,
								SUM(Com_Gb_Curr) As Com_Gb_Curr,
								SUM(Com_Nb_Curr) As Com_Nb_Curr,
								SUM(Com_Traded_Prev) As Com_Traded_Prev,
								SUM(Com_Fo_To_Prev) As Com_Fo_To_Prev,
								SUM(Com_Gb_Prev) As Com_Gb_Prev,
								SUM(Com_Nb_Prev) As Com_Nb_Prev,
								SUM(Com_Kyc) As Com_Kyc,		
								SUM(Cash_Traded_Curr) As Cash_Traded_Curr,
								SUM(Cash_Fo_To_Curr) As Cash_Fo_To_Curr,
								SUM(Cash_Gb_Curr) As Cash_Gb_Curr,
								SUM(Cash_Nb_Curr) As Cash_Nb_Curr,
								SUM(Cash_Traded_Prev) As Cash_Traded_Prev,
								SUM(Cash_Fo_To_Prev) As Cash_Fo_To_Prev,
								SUM(Cash_Gb_Prev) As Cash_Gb_Prev,
								SUM(Cash_Nb_Prev) As Cash_Nb_Prev,
								SUM(Cash_Kyc) As Cash_Kyc,
								SUM(Eq_Traded_Curr) As Eq_Traded_Curr,
								SUM(Eq_Eq_To_Curr) As Eq_Eq_To_Curr,
								SUM(Eq_Fo_To_Curr) As Eq_Fo_To_Curr,
								SUM(Eq_Total_To_Curr) As Eq_Total_To_Curr,
								SUM(Eq_Gb_Curr) As Eq_Gb_Curr,
								SUM(Eq_Nb_Curr) As Eq_Nb_Curr,
								SUM(Eq_Traded_Prev) As Eq_Traded_Prev,
								SUM(Eq_Eq_To_Prev) As Eq_Eq_To_Prev,
								SUM(Eq_Fo_To_Prev) As Eq_Fo_To_Prev,
								SUM(Eq_Total_To_Prev) As Eq_Total_To_Prev,
								SUM(Eq_Gb_Prev) As Eq_Gb_Prev,
								SUM(Eq_Nb_Prev) As Eq_Nb_Prev,
								SUM(Eq_Key) As Eq_Key,
								SUM(Curr_Traded) As Curr_Traded,
								SUM(Curr_Eq_To) As Curr_Eq_To,
								SUM(Curr_Fo_To) As Curr_Fo_To,
								SUM(Curr_Total_To) As Curr_Total_To,
								SUM(Curr_Gb) As Curr_Gb,
								SUM(Curr_Nb) As Curr_Nb,
								SUM(Prev_Traded) As Prev_Traded,
								SUM(Prev_Eq_To) As Prev_Eq_To,
								SUM(Prev_Fo_To) As Prev_Fo_To,
								SUM(Prev_Total_To) As Prev_Total_To,
								SUM(Prev_Gb) As Prev_Gb,
								SUM(Prev_Nb) As Prev_Nb,
								SUM(Prev_KYC) As Prev_KYC,
								SUM(Comp_Nb) As Comp_Nb
								,0 as R_Level
								, 0 as R_Emp_ID
						From #Emp_Downline 
						Where (Emp_ID <> 0 or P_ID <> 0) and SUB_BRANCH_CODE <> ''
						GROUP By SUB_BRANCH_CODE,Emp_Group_ID
					) as Qry ON ED.SUB_BRANCH_CODE = Qry.SUB_BRANCH_CODE and ED.Emp_ID = 0 and Qry.Emp_Group_ID = ED.Emp_Group_ID
					--Where ED.Emp_Group_ID = @Emp_ID
	-- For Branch Wise Sum				
	
	-- Head Wise Sum
	Update ED
			Set	
				Com_Traded_Curr = Qry.Com_Traded_Curr,
				Com_Fo_To_Curr = Qry.Com_Fo_To_Curr,
				Com_Gb_Curr = Qry.Com_Gb_Curr,
				Com_Nb_Curr = Qry.Com_Nb_Curr,
				Com_Traded_Prev = Qry.Com_Traded_Prev,
				Com_Fo_To_Prev = Qry.Com_Fo_To_Prev,
				Com_Gb_Prev = Qry.Com_Gb_Prev,
				Com_Nb_Prev = Qry.Com_Nb_Prev,
				Com_Kyc = Qry.Com_Kyc,
				Cash_Traded_Curr = Qry.Cash_Traded_Curr,
				Cash_Fo_To_Curr = Qry.Cash_Fo_To_Curr,
				Cash_Gb_Curr = Qry.Cash_Gb_Curr,
				Cash_Nb_Curr = Qry.Cash_Nb_Curr,
				Cash_Traded_Prev = Qry.Cash_Traded_Prev,
				Cash_Fo_To_Prev = Qry.Cash_Fo_To_Prev,
				Cash_Gb_Prev = Qry.Cash_Gb_Prev,
				Cash_Nb_Prev = Qry.Cash_Nb_Prev,
				Cash_Kyc = Qry.Cash_Kyc,
				Eq_Traded_Curr = Qry.Eq_Traded_Curr,
				Eq_Eq_To_Curr = Qry.Eq_Eq_To_Curr,
				Eq_Fo_To_Curr = Qry.Eq_Fo_To_Curr,
				Eq_Total_To_Curr = Qry.Eq_Total_To_Curr,
				Eq_Gb_Curr = Qry.Eq_Gb_Curr,
				Eq_Nb_Curr = Qry.Eq_Nb_Curr,
				Eq_Traded_Prev = Qry.Eq_Traded_Prev,
				Eq_Eq_To_Prev = Qry.Eq_Eq_To_Prev,
				Eq_Fo_To_Prev = Qry.Eq_Fo_To_Prev,
				Eq_Total_To_Prev = Qry.Eq_Total_To_Prev,
				Eq_Gb_Prev = Qry.Eq_Gb_Prev,
				Eq_Nb_Prev = Qry.Eq_Nb_Prev,
				Eq_Key = Qry.Eq_Key,
				Curr_Traded = Qry.Curr_Traded,
				Curr_Eq_To = Qry.Curr_Eq_To,
				Curr_Fo_To = Qry.Curr_Fo_To,
				Curr_Total_To = Qry.Curr_Total_To,
				Curr_Gb = Qry.Curr_Gb,
				Curr_Nb = Qry.Curr_Nb,
				Prev_Traded = Qry.Prev_Traded,
				Prev_Eq_To = Qry.Prev_Eq_To,
				Prev_Fo_To = Qry.Prev_Fo_To,
				Prev_Total_To = Qry.Prev_Total_To,
				Prev_Gb = Qry.Prev_Gb,
				Prev_Nb = Qry.Prev_Nb,
				Prev_KYC = Qry.Prev_KYC,
				Comp_Nb = Qry.Comp_Nb
		From #Emp_Downline ED
			Inner JOIN(
						Select  
								Emp_Group_ID,
								SUM(Com_Traded_Curr) As Com_Traded_Curr,
								SUM(Com_Fo_To_Curr) As Com_Fo_To_Curr,
								SUM(Com_Gb_Curr) As Com_Gb_Curr,
								SUM(Com_Nb_Curr) As Com_Nb_Curr,
								SUM(Com_Traded_Prev) As Com_Traded_Prev,
								SUM(Com_Fo_To_Prev) As Com_Fo_To_Prev,
								SUM(Com_Gb_Prev) As Com_Gb_Prev,
								SUM(Com_Nb_Prev) As Com_Nb_Prev,
								SUM(Com_Kyc) As Com_Kyc,		
								SUM(Cash_Traded_Curr) As Cash_Traded_Curr,
								SUM(Cash_Fo_To_Curr) As Cash_Fo_To_Curr,
								SUM(Cash_Gb_Curr) As Cash_Gb_Curr,
								SUM(Cash_Nb_Curr) As Cash_Nb_Curr,
								SUM(Cash_Traded_Prev) As Cash_Traded_Prev,
								SUM(Cash_Fo_To_Prev) As Cash_Fo_To_Prev,
								SUM(Cash_Gb_Prev) As Cash_Gb_Prev,
								SUM(Cash_Nb_Prev) As Cash_Nb_Prev,
								SUM(Cash_Kyc) As Cash_Kyc,
								SUM(Eq_Traded_Curr) As Eq_Traded_Curr,
								SUM(Eq_Eq_To_Curr) As Eq_Eq_To_Curr,
								SUM(Eq_Fo_To_Curr) As Eq_Fo_To_Curr,
								SUM(Eq_Total_To_Curr) As Eq_Total_To_Curr,
								SUM(Eq_Gb_Curr) As Eq_Gb_Curr,
								SUM(Eq_Nb_Curr) As Eq_Nb_Curr,
								SUM(Eq_Traded_Prev) As Eq_Traded_Prev,
								SUM(Eq_Eq_To_Prev) As Eq_Eq_To_Prev,
								SUM(Eq_Fo_To_Prev) As Eq_Fo_To_Prev,
								SUM(Eq_Total_To_Prev) As Eq_Total_To_Prev,
								SUM(Eq_Gb_Prev) As Eq_Gb_Prev,
								SUM(Eq_Nb_Prev) As Eq_Nb_Prev,
								SUM(Eq_Key) As Eq_Key,
								SUM(Curr_Traded) As Curr_Traded,
								SUM(Curr_Eq_To) As Curr_Eq_To,
								SUM(Curr_Fo_To) As Curr_Fo_To,
								SUM(Curr_Total_To) As Curr_Total_To,
								SUM(Curr_Gb) As Curr_Gb,
								SUM(Curr_Nb) As Curr_Nb,
								SUM(Prev_Traded) As Prev_Traded,
								SUM(Prev_Eq_To) As Prev_Eq_To,
								SUM(Prev_Fo_To) As Prev_Fo_To,
								SUM(Prev_Total_To) As Prev_Total_To,
								SUM(Prev_Gb) As Prev_Gb,
								SUM(Prev_Nb) As Prev_Nb,
								SUM(Prev_KYC) As Prev_KYC,
								SUM(Comp_Nb) As Comp_Nb
								,0 as R_Level
								, 0 as P_ID
						From #Emp_Downline 
						Where Emp_ID = 0 
						GROUP by Emp_Group_ID
					) as Qry 
				ON ED.P_ID = Qry.P_ID and Qry.Emp_Group_ID = ED.Emp_Group_ID --Where @Bussiness_Level <> 6
	-- Head Wise Sum
	
	if @ChkRM = 1
		Begin
			Declare @Max_Level Numeric
			Set @Max_Level = 0
			Select @Max_Level = Max(R_Level) From #Emp_Downline
			if @Max_Level > 0
				Begin
					Update #Emp_Downline Set Display_ID = 1 Where R_Level = @Max_Level
				End
		End
	
	Select Caption,
			Com_Traded_Curr,
			Round(Com_Fo_To_Curr,0) as Com_Fo_To_Curr ,
			Round(Com_Gb_Curr,0) as Com_Gb_Curr,
			Round(Com_Nb_Curr,0) as Com_Nb_Curr,

			Com_Traded_Prev,
			Round(Com_Fo_To_Prev,0) as Com_Fo_To_Prev ,
			Round(Com_Gb_Prev,0) as Com_Gb_Prev,
			Round(Com_Nb_Prev,0) as Com_Nb_Prev,
			Com_Kyc,
			
			Cash_Traded_Curr,
		    Round(Cash_Fo_To_Curr,0) as Cash_Fo_To_Curr,
		    Round(Cash_Gb_Curr,0) as Cash_Gb_Curr,
			Round(Cash_Nb_Curr,0) as Cash_Nb_Curr,

			Cash_Traded_Prev,
			Round(Cash_Fo_To_Prev,0) as Cash_Fo_To_Prev,
			Round(Cash_Gb_Prev,0) as Cash_Gb_Prev,
			Round(Cash_Nb_Prev,0) as Cash_Nb_Prev,
			Cash_Kyc,
			
			Eq_Traded_Curr,
			Round(Eq_Eq_To_Curr,0) as Eq_Eq_To_Curr,
		    Round(Eq_Fo_To_Curr,0) as Eq_Fo_To_Curr,
		    Round(Eq_Total_To_Curr,0) as Eq_Total_To_Curr,
		    Round(Eq_Gb_Curr,0) as Eq_Gb_Curr,
		    Round(Eq_Nb_Curr,0) as Eq_Nb_Curr,
		  
		    Eq_Traded_Prev,
		    Round(Eq_Eq_To_Prev,0) as Eq_Eq_To_Prev,
		    Round(Eq_Fo_To_Prev,0) as Eq_Fo_To_Prev,
		    Round(Eq_Total_To_Prev,0) as Eq_Total_To_Prev,
		    Round(Eq_Gb_Prev,0) as Eq_Gb_Prev,
		    Round(Eq_Nb_Prev,0) as Eq_Nb_Prev,
		    Eq_Key,
		    
		    Curr_Traded,
			Round(Curr_Eq_To,0) as Curr_Eq_To,
			Round(Curr_Fo_To,0) as Curr_Fo_To,
			Round(Curr_Total_To,0) as Curr_Total_To,
			Round(Curr_Gb,0) as Curr_Gb,
			Round(Curr_Nb,0) as Curr_Nb,
			  
			Prev_Traded,

			Round(Prev_Eq_To,0) as Prev_Eq_To,
			Round(Prev_Fo_To,0) as Prev_Fo_To,
			Round(Prev_Total_To,0) as Prev_Total_To,
			Round(Prev_Gb,0) as Prev_Gb,
			Round(Prev_Nb,0) as Prev_Nb,
			Prev_KYC,
			
			Round(Comp_Nb,0) as Comp_Nb,
			Round(Isnull(Prev_Nb,0) - Isnull(Comp_Nb,0),0) as Diff_Amt,
			
			CASE WHEN Isnull(Comp_Nb,0) <> 0 THEN
				Cast(ROUND(((Isnull(Prev_Nb,0) * 100 /Isnull(Comp_Nb,0)) - 100),0) AS numeric(18,0))
			ELSE 0 END as Per_Amt,
			
			@From_Date as FromDt,@To_Date as ToDt,@Today_Date as TodayDt,@Comp_From_Date As CompFdt,@Comp_To_Date as CompTdt,R_Level,P_ID
			,R_Level * 15  as padding_Count
	From #Emp_Downline 
	Where Isnull(Display_ID,0) = 0
	--Where (Isnull(Prev_Nb,0) - Isnull(Comp_Nb,0)) <> 0
	--order by R_Level
	

END

