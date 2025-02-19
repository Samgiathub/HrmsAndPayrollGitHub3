

---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Rpt_Salary_Settetment_DA_GPF_CPS]
	@Company_id	Numeric
	,@From_Date	Datetime
	,@To_Date Datetime
	,@Branch_ID	Numeric
	,@Grade_ID Numeric
	,@Type_ID Numeric
	,@Dept_ID Numeric
	,@Desig_ID Numeric
	,@Emp_ID Numeric
	,@Constraint	Varchar(max)
	,@Cat_ID Numeric = 0
	,@is_column	Numeric = 0
	,@CPS_Flag Numeric = 0
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	IF @Branch_ID = 0
		set @Branch_ID = null
	
	If @Grade_ID = 0
		set @Grade_ID = null
		
	If @Emp_ID = 0
		set @Emp_ID = null
		
	If @Desig_ID = 0
		set @Desig_ID = null
		
	If @Dept_ID = 0
		set @Dept_ID = null
		
	If @Cat_ID = 0
		set @Cat_ID = null
		
	If @Type_id = 0
		set @Type_id = null
		
	if Object_ID('tempdb..#Emp_Cons') is not null
		drop table #Emp_Cons
		Create Table #Emp_Cons
		(
			Emp_ID Numeric
		)
		
	if @Constraint <> ''
	Begin
		Insert Into #Emp_Cons
		Select data From dbo.Split(@Constraint,'#')
	End
	
	if Object_ID('tempdb..#Dynamic_Allowance') is not null
		Begin
			drop table #Dynamic_Allowance
		End
		
	Create Table #Dynamic_Allowance
	(
		Cmp_ID Numeric(18,0),
		Emp_ID Numeric(18,0),
		Basic_Amt Numeric(18,2),
		New_DA Numeric(18,2),
		Exist_DA Numeric(18,2),
		Diff_Amt Numeric(18,2),
		Total_Amt Numeric(18,2),
		Diff_Month Numeric(5,0),
		S_Eff_Date Datetime,
		Increment_ID Numeric(5,0),
		Increment_Period Varchar(50),
		EPS_Amount Numeric(18,2)
	)
	
	Insert into #Dynamic_Allowance
	Select DISTINCT MS.Cmp_ID,EC.Emp_ID,MAD.Basic_Salary,0,0,MS.S_Net_Amount,0,0,MS.S_Eff_Date,MS.Increment_ID,'',0
	From #Emp_Cons EC Inner join --MAD.AD_ID,AD.AD_NAME,AD.Allowance_Type,MAD.M_AD_Flag,AD_SORT_NAME
	T0201_MONTHLY_SALARY_SETT MS WITH (NOLOCK) ON EC.Emp_ID = MS.Emp_ID
	Inner Join T0200_MONTHLY_SALARY MAD WITH (NOLOCK) On MAD.Sal_Tran_ID = MS.Sal_Tran_ID
	Where S_Eff_Date Between @From_Date AND @To_Date
	
	
	Update DA1 Set Diff_Month = Qry.Increment_Period,Increment_Period = Month_Period
	From #Dynamic_Allowance DA1
		Inner Join
		(
			Select COUNT(MSS.Emp_ID) as Increment_Period,Cast(datename(month, Min(S_Month_End_Date)) as varchar(3)) + ' ' + cast(year(Min(S_Month_End_Date)) as varchar(4)) + ' - ' + Cast(datename(month, max(S_Month_End_Date)) as varchar(3)) + ' ' + cast(year(max(S_Month_End_Date)) as varchar(4)) as Month_Period,
			MSS.Emp_ID,MSS.Increment_ID
			From T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK)
			Inner Join #Dynamic_Allowance TS
			ON TS.Emp_ID = MSS.Emp_ID and TS.S_Eff_Date = Mss.S_Eff_Date and TS.Increment_ID = MSS.Increment_ID
			Group by MSS.Emp_ID,MSS.Increment_ID
		) as Qry
	On DA1.Emp_ID = Qry.Emp_ID and DA1.Increment_ID = Qry.Increment_ID
	
	
	
	Update DA
		SET DA.Exist_DA = Qry.AD_Amount
	From #Dynamic_Allowance DA
	Inner JOIN(
				Select DISTINCT M_AD_Amount as AD_Amount ,TS.Emp_ID,MS.Increment_ID
				From T0201_MONTHLY_SALARY_SETT MS WITH (NOLOCK) Inner Join T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
				On MS.Sal_Tran_ID = MAD.Sal_Tran_ID 
				Inner Join #Dynamic_Allowance TS On TS.Emp_ID = MS.Emp_ID and TS.Increment_ID = MS.Increment_ID
				Inner JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON AD.AD_ID = MAD.AD_ID
				Where AD.AD_DEF_ID = 11 and Isnull(MAD.S_Sal_Tran_ID,0) = 0
			   ) as Qry
	ON DA.Emp_ID = Qry.Emp_ID and DA.Increment_ID = Qry.Increment_ID
	
	Update DA
		SET DA.New_DA = DA.Exist_DA + Qry.AD_Amount , Total_Amt = DA.Diff_Amt * DA.Diff_Month
	From #Dynamic_Allowance DA
	Inner JOIN(
				Select DISTINCT M_AD_Amount as AD_Amount ,TS.Emp_ID,MS.Increment_ID
				From T0201_MONTHLY_SALARY_SETT MS WITH (NOLOCK) Inner Join T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
				On MS.Sal_Tran_ID = MAD.Sal_Tran_ID 
				Inner Join #Dynamic_Allowance TS On TS.Emp_ID = MS.Emp_ID and TS.Increment_ID = MS.Increment_ID
				Inner JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON AD.AD_ID = MAD.AD_ID
				Where AD.AD_DEF_ID = 11 and Isnull(MAD.S_Sal_Tran_ID,0) <> 0
			   ) as Qry
	ON DA.Emp_ID = Qry.Emp_ID and DA.Increment_ID = Qry.Increment_ID
	
	if @CPS_Flag = 1
		Begin
			Update #Dynamic_Allowance Set Diff_Amt = (New_DA - Exist_DA) ,Total_Amt = (New_DA - Exist_DA) * Diff_Month
			
			Update DA
				SET DA.EPS_Amount = (Qry.AD_Amount * DA.Diff_Month)
			From #Dynamic_Allowance DA
			Inner JOIN(
						Select DISTINCT M_AD_Amount as AD_Amount ,TS.Emp_ID,MS.Increment_ID
						From T0201_MONTHLY_SALARY_SETT MS WITH (NOLOCK) Inner Join T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
						On MS.Sal_Tran_ID = MAD.Sal_Tran_ID 
						Inner Join #Dynamic_Allowance TS On TS.Emp_ID = MS.Emp_ID and TS.Increment_ID = MS.Increment_ID
						Inner JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON AD.AD_ID = MAD.AD_ID
						Where AD.AD_DEF_ID = 16 and Isnull(MAD.S_Sal_Tran_ID,0) <> 0
					   ) as Qry
			ON DA.Emp_ID = Qry.Emp_ID and DA.Increment_ID = Qry.Increment_ID
		End
	
	if Object_ID('tempdb..#Dynamic_Allowance_Temp') is not null
		Begin
			drop table #Dynamic_Allowance_Temp
		End
	
	Create Table #Dynamic_Allowance_Temp
	(
		Row_ID Numeric(18,0),
		Alpha_Emp_Code Varchar(50),
		Emp_Full_Name Varchar(100),
		Increment_Period Varchar(50),
		Basic_Amt Numeric(18,2),
		New_DA Numeric(18,2),
		Exist_DA Numeric(18,2),
		Diff_Amt Numeric(5,0),
		Total_Amt Numeric(18,2),
		Diff_Month Varchar(50),
		Emp_ID Numeric(5,0),
		Increment_ID Numeric(5,0),
		EPS_Amount Numeric(18,2)
	)
	 
	Insert INTO #Dynamic_Allowance_Temp
	Select ROW_NUMBER()over(PARTITION BY DA.Increment_ID,DA.Emp_ID ORDER BY DA.Emp_ID) As Row_ID, 
	EM.Alpha_Emp_Code,EM.Emp_Full_Name,
	DA.Increment_Period,DA.Basic_Amt,DA.New_DA,DA.Exist_DA,DA.Diff_Amt,
	DA.Total_Amt,Cast(DA.Diff_Month as varchar(5)) + '  Months',DA.Emp_ID,DA.Increment_ID,DA.EPS_Amount
	From #Dynamic_Allowance DA Inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = DA.Emp_ID
	Union 
	Select 9999 As Row_ID,'Total' as Alpha_Emp_Code,'' as Emp_Full_Name,
	'' as Duration,
	NULL As Basic,NULL As 'New DA',NULL AS 'Existing DA',NULL As'Diff for one month',
	Sum(Total_Amt) AS 'Total','' as 'Diff Month',DA.Emp_ID,0 as Increment_ID,SUM(EPS_Amount) as EPS_Amount
	From #Dynamic_Allowance DA Inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = DA.Emp_ID
	group by DA.Emp_ID
	order by DA.Emp_ID,Row_ID,DA.Increment_ID
	
	if @CPS_Flag <> 1 
		Begin
			if @is_column = 1
				Begin
					Select Top 1 0 as flag, Alpha_Emp_Code,Emp_Full_Name,Increment_Period,Basic_Amt,New_DA,Exist_DA,Diff_Amt,Total_Amt,Diff_Month From #Dynamic_Allowance_Temp
				End
			Else
				Begin
					Select (CASE WHEN Row_ID = 9999 then 1 ELSE 0 END) as flag, Alpha_Emp_Code,Emp_Full_Name,Increment_Period,Basic_Amt,New_DA,Exist_DA,Diff_Amt,Total_Amt,Diff_Month From #Dynamic_Allowance_Temp
				End
		End
	Else
		Begin
			if @is_column = 1
				Begin
					Select TOP 1 (CASE WHEN Row_ID = 9999 then 1 ELSE 0 END) as flag, Alpha_Emp_Code,Emp_Full_Name,Increment_Period,Basic_Amt,New_DA,Exist_DA,Diff_Amt,
					(CASE WHEN Row_ID <> 9999 then Total_Amt ELSE NULL END) As Total_Amt,
					(CASE WHEN Row_ID <> 9999 then (Isnull(EPS_Amount,0)) ELSE NULL END) AS EPS,
					(CASE WHEN Isnull(Total_Amt,0) > 0 then
						Cast(Round((Total_Amt - Isnull(EPS_Amount,0)),0) AS numeric(18,2)) 
					 ELSE 
						0 
					 END) AS Cash,
					/*(CASE WHEN Row_ID <> 9999 then 
							CASE WHEN Isnull(Total_Amt,0) > 0 then
								Cast(Round((Total_Amt * 10 /100),0) AS numeric(18,2)) 
							ELSE 
								0 
							END
					 Else NULL 
					 END) AS HMDA_CPS,*/
					 (CASE WHEN Row_ID <> 9999 then (Isnull(EPS_Amount,0)) ELSE NULL END) AS HMDA_CPS,
					 /*(CASE WHEN Row_ID <> 9999 then 
							CASE WHEN Isnull(Total_Amt,0) > 0 then
								Cast(Round((Total_Amt * 10 /100),0) AS numeric(18,2)) * 2 
							ELSE 
								0 
							END
					 Else NULL 
					 END) AS Total_CPS,*/
					 (CASE WHEN Row_ID <> 9999 then (Isnull(EPS_Amount,0)) * 2 ELSE NULL END) AS Total_CPS,
					Diff_Month
					From #Dynamic_Allowance_Temp
				End
			Else
				Begin
					Select (CASE WHEN Row_ID = 9999 then 1 ELSE 0 END) as flag, Alpha_Emp_Code,Emp_Full_Name,Increment_Period,Basic_Amt,New_DA,Exist_DA,Diff_Amt,
					(CASE WHEN Row_ID <> 9999 then Total_Amt ELSE NULL END) As Total_Amt,
					(CASE WHEN Row_ID <> 9999 then (Isnull(EPS_Amount,0)) ELSE NULL END) AS EPS,
					
					(CASE WHEN Isnull(Total_Amt,0) > 0 then
						Cast(Round((Total_Amt - Isnull(EPS_Amount,0)),0) AS numeric(18,2))
					 ELSE 
						0 
					 END) AS Cash,
					 
					 (CASE WHEN Row_ID <> 9999 then (Isnull(EPS_Amount,0)) ELSE NULL END) AS HMDA_CPS,
					 (CASE WHEN Row_ID <> 9999 then (Isnull(EPS_Amount,0)) * 2 ELSE NULL END) AS Total_CPS,
					/*(CASE WHEN Row_ID <> 9999 then 
							CASE WHEN Isnull(Total_Amt,0) > 0 then
								Cast(Round((Total_Amt * 10 /100),0) AS numeric(18,2)) 
							ELSE 
								0 
							END
					 Else NULL 
					 END) AS EPS,
					(CASE WHEN Isnull(Total_Amt,0) > 0 then
						Cast(Round((Total_Amt - (Total_Amt * 10 /100)),0) AS numeric(18,2)) 
					 ELSE 
						0 
					 END) AS Cash,
					(CASE WHEN Row_ID <> 9999 then 
							CASE WHEN Isnull(Total_Amt,0) > 0 then
								Cast(Round((Total_Amt * 10 /100),0) AS numeric(18,2)) 
							ELSE 
								0 
							END
					 Else NULL 
					 END) AS HMDA_CPS,
					 (CASE WHEN Row_ID <> 9999 then 
							CASE WHEN Isnull(Total_Amt,0) > 0 then
								Cast(Round((Total_Amt * 10 /100),0) AS numeric(18,2)) * 2 
							ELSE 
								0 
							END
					 Else NULL 
					 END) AS Total_CPS,*/
					Diff_Month
					From #Dynamic_Allowance_Temp
				End
		End
END
