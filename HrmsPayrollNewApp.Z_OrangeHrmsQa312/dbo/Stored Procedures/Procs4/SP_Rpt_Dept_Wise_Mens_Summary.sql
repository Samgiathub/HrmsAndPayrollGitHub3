
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Rpt_Dept_Wise_Mens_Summary]  
	 @Company_Id	NUMERIC  
	,@From_Date		DATETIME
	,@To_Date 		DATETIME
	,@Branch_ID		Varchar(Max) = ''
	,@Grade_ID 		Varchar(Max) = ''
	,@Type_ID 		Varchar(Max) = ''
	,@Dept_ID 		Varchar(Max) = ''
	,@Desig_ID 		Varchar(Max) = ''
	,@Emp_ID 		NUMERIC
	,@Constraint	VARCHAR(MAX)
	,@Cat_ID        Varchar(Max) = ''
	,@Filter_Flag	tinyint = 0
	,@summary	    int = 0
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
  
	DECLARE @Year_End_Date AS DATETIME  
	DECLARE @User_type VARCHAR(30)  
	DECLARE @Month_Days int
	
	Set @To_Date = @From_Date

	Set @Month_Days = DATEDIFF(DD,DBO.GET_MONTH_ST_DATE(MONTH(@From_Date),YEAR(@From_Date)),DBO.GET_MONTH_END_DATE(MONTH(@From_Date),YEAR(@From_Date)))+1     

	 CREATE table #Emp_Cons 
	 (      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric    
	 )            
   
	EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Company_Id,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grade_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',0,0,0,'0',0,0               
	

	if Object_ID('tempdb..#Emp_OT_Data') is not null
		Drop Table #Emp_OT_Data

	Create Table #Emp_OT_Data
	(
		Emp_ID Numeric,
		P_day Numeric(18,3),
		WeekDay_OT_Sec Numeric,
		Weekoff_OT_Sec Numeric,
		Holiday_OT_Sec Numeric,
		Total_OT_Sec Numeric,
		Dept_ID Numeric,
		Daily_Amount Numeric(18,2)
	)

	if OBJECT_ID('tempdb..#Emp_General_Setting') is not null
		Begin
			Drop Table #Emp_General_Setting
		End

	Create Table #Emp_General_Setting
	(
		Emp_ID Numeric,
		Gen_ID Numeric,
		Branch_ID Numeric,
		Auto_OT tinyint
	)

	Insert into #Emp_General_Setting
	Select EC.Emp_ID,G.Gen_ID,G.Branch_ID,G.Is_OT_Auto_Calc 
	From T0040_GENERAL_SETTING G WITH (NOLOCK)
	Inner Join(
			select max(For_Date) as For_Date,Branch_ID 
				from T0040_GENERAL_SETTING WITH (NOLOCK)
			where For_Date <=GETDATE() and Cmp_ID = @Company_Id
			Group By Branch_ID
	) as Qry On G.For_Date = Qry.For_Date and G.Branch_ID = Qry.Branch_ID
	Inner Join #Emp_Cons EC ON EC.Branch_ID = G.Branch_ID

	
	Insert into #Emp_OT_Data
	Select Emp_ID,0,0,0,0,0,0,0  From #Emp_Cons

	Update EO
		SET EO.Dept_ID = I.Dept_ID
	From #Emp_OT_Data EO 
		 Inner Join #Emp_Cons EC ON EO.Emp_ID = EC.Emp_ID
		 Inner Join T0095_Increment I ON EC.Increment_ID = I.Increment_ID


	DELETE FROM #Emp_OT_Data WHERE Dept_ID IS NULL

	If OBJECT_ID('tempdb..#Data') is not null
		Drop table #Data

	CREATE TABLE #Data         
		(         
		   Emp_Id   numeric ,         
		   For_date datetime,        
		   Duration_in_sec numeric,        
		   Shift_ID numeric ,        
		   Shift_Type numeric ,        
		   Emp_OT  numeric ,        
		   Emp_OT_min_Limit numeric,        
		   Emp_OT_max_Limit numeric,        
		   P_days  numeric(12,3) default 0,        
		   OT_Sec  numeric default 0  ,
		   In_Time datetime,
		   Shift_Start_Time datetime,
		   OT_Start_Time numeric default 0,
		   Shift_Change tinyint default 0,
		   Flag int default 0,
		   Weekoff_OT_Sec  numeric default 0,
		   Holiday_OT_Sec  numeric default 0,
		   Chk_By_Superior numeric default 0,
		   IO_Tran_Id	   numeric default 0, 
		   OUT_Time datetime,
		   Shift_End_Time datetime,
		   OT_End_Time numeric default 0,
		   Working_Hrs_St_Time tinyint default 0,
		   Working_Hrs_End_Time tinyint default 0,
		   GatePass_Deduct_Days numeric(18,2) default 0
	   )  

	exec SP_CALCULATE_PRESENT_DAYS @Cmp_ID=@Company_Id,@From_Date=@From_Date,@To_date=@To_Date,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0,@constraint=@constraint,@Return_Record_set=4

	

	Update ED
		SET ED.P_day = Qry.P_Days,
			ED.WeekDay_OT_Sec = Qry.OT_Sec,
			ED.Weekoff_OT_Sec = Qry.WO_OT_Sec,
			ED.Holiday_OT_Sec = Qry.HO_OT_Sec,
			ED.Daily_Amount = Basic_Salary * Qry.P_Days 
	From #Emp_OT_Data ED
	Inner Join(
				Select EC.Emp_ID,SUM(D.P_Days) as P_Days,
					SUM(CASE WHEN EGS.Auto_OT = 1 THEN Isnull(TA.Approved_OT_Sec,D.OT_Sec) WHEN EGS.Auto_OT = 0 THEN Isnull(TA.Approved_OT_Sec,0) END) as OT_Sec,
					SUM(CASE WHEN EGS.Auto_OT = 1 THEN Isnull(TA.Approved_WO_OT_Sec,D.Weekoff_OT_Sec) WHEN EGS.Auto_OT = 0 THEN Isnull(TA.Approved_WO_OT_Sec,0) END) as WO_OT_Sec,
					SUM(CASE WHEN EGS.Auto_OT = 1 THEN Isnull(TA.Approved_HO_OT_Sec,D.Holiday_OT_Sec) WHEN EGS.Auto_OT = 0 THEN Isnull(TA.Approved_HO_OT_Sec,0) END) as HO_OT_Sec
				From #Emp_OT_Data EC 
					Inner Join #Data D ON EC.Emp_ID = D.Emp_Id
					Left Outer Join T0160_OT_APPROVAL TA WITH (NOLOCK) ON D.For_date = TA.For_Date and D.Emp_Id = TA.Emp_ID and TA.Is_Approved = 1
					Inner Join #Emp_General_Setting EGS ON D.Emp_Id = EGS.Emp_ID
				Group By EC.Emp_ID
			  ) as Qry
		ON ED.Emp_ID = Qry.Emp_ID
	INNER JOIN
		(
			SELECT I.EMP_ID, CASE WHEN Wages_Type = 'Monthly' THEN Round(Basic_Salary/@Month_Days,0) ELSE Basic_Salary END As Basic_Salary
			FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN 
				#Emp_Cons EC ON I.EMP_ID = EC.Emp_ID AND I.Increment_ID = EC.Increment_ID
		) QRY1 ON ED.EMP_ID = QRY1.EMP_ID

	
	
	Update #Emp_OT_Data SET Total_OT_Sec = Isnull(WeekDay_OT_Sec,0) + Isnull(Weekoff_OT_Sec,0) + Isnull(Holiday_OT_Sec,0)

	IF OBJECT_ID('tempdb..#DeptData') is not null
	   Begin
			Drop Table #DeptData
	   End

	Create Table #DeptData
	(
		Dept_ID Numeric,
		Emp_Count Numeric,
		Present_Day Numeric,
		OT_Sec Numeric(18,0),
		OT_Day Numeric(18,2),
		Total_Mendays Numeric(18,2),
		Total_Amount Numeric(18,2) 
	)

	

	Insert into #DeptData
	Select Dept_ID, Count(Emp_ID),SUM(P_day),SUM(Total_OT_Sec),Cast(Replace(dbo.F_Return_Hours(SUM(Total_OT_Sec)),':','.') as Numeric(18,2))/8,0 as OT_Days, Sum(Daily_Amount)  ---Cast((SUM(Total_OT_Sec)/3600)/8 as Numeric(18,2)) as OT_Days
	From #Emp_OT_Data
	Group By Dept_ID

	
	Insert into #DeptData
	Select 999999,0,0,0,0,0,0


	Update D	
		SET 
			D.Emp_Count = Qry.Sum_Emp,
			D.Present_Day = Qry.P_Days,
			D.Total_Mendays = Qry.Total_Mendays,
			D.OT_Day = Qry.OT_Day,
			D.Total_Amount = Qry.Total_Amount
	From 
	#DeptData D
	Inner Join(
				Select 999999 as ID,SUM(Emp_Count) as Sum_Emp,SUM(Present_Day) as P_Days,SUM(Present_Day + OT_Day) as Total_Mendays,SUM(OT_Day) as OT_Day, SUM(Total_Amount) As Total_Amount
				From #DeptData 
			  ) As Qry
	ON D.Dept_ID =Qry.ID
	

	Select ROW_NUMBER() Over(order by DD.Dept_ID) as Sr_NO, Case When DD.Dept_ID = 999999 Then 'TOTAL' ELSE DM.Dept_NAME END as Department,DD.Emp_Count as Actual,Present_Day as Present,'="' + dbo.F_Return_Hours(DD.OT_Sec) + '"' as OT_hours, Cast(Present_Day + OT_Day as Numeric(18,2)) as Total_Mandays, Total_Amount
		From #DeptData DD
	LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON DD.Dept_ID = DM.Dept_ID --And DD.Dept_ID <> 999999
	where DD.Dept_ID Is not null
	--UNION
	--Select 999999 as Sr_NO, 'TOTAL' as Department,DD.Emp_Count as Actual,Present_Day as Present,'' as OT_hours, Total_Mendays
		--From #DeptData DD WHERE DD.Dept_ID = 999999
 RETURN


