

---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Rpt_Pre_OT_Approval_Summary]  
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
	DECLARE @OD_COMPOFF_AS_PRESENT NUMERIC
	Set @OD_Compoff_As_Present = 0

     SELECT @OD_COMPOFF_AS_PRESENT = ISNULL(SETTING_VALUE,0) FROM T0040_SETTING WITH (NOLOCK)  
	WHERE SETTING_NAME = 'OD and CompOff Leave Consider As Present' AND CMP_ID = @Company_Id

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
		Duration_Sec Numeric,
		P_day Numeric(18,3),
		WeekDay_OT_Sec Numeric,
		Weekoff_OT_Sec Numeric,
		Holiday_OT_Sec Numeric,
		Total_OT_Sec Numeric
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
				from T0040_GENERAL_SETTING  WITH (NOLOCK)
			where For_Date <=GETDATE() and Cmp_ID = @Company_Id
			Group By Branch_ID
	) as Qry On G.For_Date = Qry.For_Date and G.Branch_ID = Qry.Branch_ID
	Inner Join #Emp_Cons EC ON EC.Branch_ID = G.Branch_ID

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
	
	
	Insert into #Emp_OT_Data
	Select D.Emp_ID,SUM(D.Duration_in_sec),SUM(D.P_Days),
		SUM(CASE WHEN EGS.Auto_OT = 1 THEN Isnull(TA.Approved_OT_Sec,D.OT_Sec) WHEN EGS.Auto_OT = 0 THEN Isnull(TA.Approved_OT_Sec,0) END),
		SUM(CASE WHEN EGS.Auto_OT = 1 THEN Isnull(TA.Approved_WO_OT_Sec,D.Weekoff_OT_Sec) WHEN EGS.Auto_OT = 0 THEN Isnull(TA.Approved_WO_OT_Sec,0) END),
		SUM(CASE WHEN EGS.Auto_OT = 1 THEN Isnull(TA.Approved_HO_OT_Sec,D.Holiday_OT_Sec) WHEN EGS.Auto_OT = 0 THEN Isnull(TA.Approved_HO_OT_Sec,0) END),
		0
		--SUM(Isnull(TA.Approved_WO_OT_Sec,D.Weekoff_OT_Sec)),
		--SUM(Isnull(TA.Approved_HO_OT_Sec,D.Holiday_OT_Sec)) 
	From #Data D
		Left Outer Join T0160_OT_APPROVAL TA WITH (NOLOCK) ON D.For_date = TA.For_Date and D.Emp_Id = TA.Emp_ID and TA.Is_Approved = 1
		Inner Join #Emp_General_Setting EGS ON D.Emp_Id = EGS.Emp_ID
	Group By D.Emp_ID

	

	Update #Emp_OT_Data SET Total_OT_Sec = Isnull(WeekDay_OT_Sec,0) + Isnull(Weekoff_OT_Sec,0) + Isnull(Holiday_OT_Sec,0)

	Insert into #Emp_OT_Data
	Select 999999,0,0,0,0,0,0

	If @OD_Compoff_As_Present = 1
		Begin
			UPDATE #Emp_OT_Data
			SET P_day =cast(Round(Q.P_DAYS + Isnull(Q1.OD_Compoff,0),2) as numeric(18,2)) --Q.P_DAYS + ISNULL(Q1.OD_COMPOFF,0)
			-- --Changed by Sumit on 03022017 --Q.P_DAYS + ISNULL(Q1.OD_COMPOFF,0)
			FROM #Emp_OT_Data AM INNER JOIN 
			(SELECT EMP_ID ,SUM(ISNULL(P_DAYS,0))P_DAYS FROM #Data 
				
				WHERE FOR_DATE>=@FROM_DATE AND FOR_DATE <=@TO_DATE 
				
				GROUP BY EMP_ID)Q ON AM.EMP_ID = Q.EMP_ID	--NIKUNJ 27-04-2011							
			LEFT OUTER JOIN 
				(select	sum(((IsNull(LT.CompOff_Used,0) - IsNull(LT.Leave_Encash_Days,0)) + IsNull(LT.Leave_Used,0)) * CASE WHEN LM.Apply_Hourly = 1 THEN 0.125 ELSE 1 END)  AS OD_Compoff,lt.Emp_ID
				from	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)  
						INNER JOIN  T0040_LEAVE_MASTER LM WITH (NOLOCK)  ON LT.Leave_ID=LM.Leave_ID						
				where	(Leave_Type='Company Purpose' OR Leave_Code = 'COMP') and LT.Cmp_ID=@Company_Id
						AND LT.FOR_DATE BETWEEN @FROM_DATE AND @TO_dATE
				group by Emp_ID
				)Q1 on Am.Emp_ID = Q1.Emp_ID --Changed by Sumit on 30112016
			--where Row_ID = 32
			
			
			
		End

	Update D	
		SET D.Duration_Sec = Qry.Sum_Durattion,
			D.P_day = Qry.Sum_PDays,
			D.WeekDay_OT_Sec = Qry.Sum_WD,
			D.Weekoff_OT_Sec = Qry.Sum_WO,
			D.Holiday_OT_Sec = Qry.Sum_HO,
			D.Total_OT_Sec = Qry.Sum_WD + Qry.Sum_WO + Qry.Sum_HO
	From 
	#Emp_OT_Data D
	Inner Join(
				Select 999999 as ID, SUM(Duration_Sec) as Sum_Durattion,SUM(P_day) as Sum_PDays,SUM(WeekDay_OT_Sec)  as Sum_WD ,SUM(Weekoff_OT_Sec) as Sum_WO,
				SUM(Holiday_OT_Sec) as Sum_HO 
				From #Emp_OT_Data
			  ) As Qry
	ON D.Emp_ID =Qry.ID

	
	
	

	
	SELECT '="' + Alpha_Emp_Code + '"' AS Emp_code, 
			Emp_Full_Name, 
			--Replace(Cast(Replace(dbo.F_Return_Hours(Duration_Sec),':','.') as numeric(18,2)),'.',':') as Working_Hours,
			'="' + dbo.F_Return_Hours(Duration_Sec) + '"' as Working_Hours,
			P_day as Present_Day,
			'="' + dbo.F_Return_Hours(WeekDay_OT_Sec) + '"' as WeekDay_OT,
			'="' + dbo.F_Return_Hours(Weekoff_OT_Sec) + '"' as WeekOff_OT,
			'="' + dbo.F_Return_Hours(Holiday_OT_Sec) + '"' as Holiday_OT,
			'="' + dbo.F_Return_Hours(Total_OT_Sec) + '"' as Total_OT
			--Replace(Cast(Replace(dbo.F_Return_Hours(WeekDay_OT_Sec),':','.') as numeric(18,2)),'.',':') as WeekDay_OT,
			--Replace(Cast(Replace(dbo.F_Return_Hours(Weekoff_OT_Sec),':','.') as numeric(18,2)),'.',':') as WeekOff_OT,
			--Replace(Cast(Replace(dbo.F_Return_Hours(Holiday_OT_Sec),':','.') as numeric(18,2)),'.',':') as Holiday_OT
			--dbo.F_Return_Hours(Holiday_OT_Sec) as Holiday_OT
	FROM	dbo.T0080_EMP_MASTER E WITH (NOLOCK)
			INNER JOIN #Emp_OT_Data AA ON AA.Emp_ID = E.Emp_ID 
	WHERE E.Cmp_ID = @Company_Id And E.Emp_ID <> 999999

	Union 

	SELECT 'TOTAL' AS Emp_code, 
			'' as Emp_Full_Name, 
			'="' + dbo.F_Return_Hours(Duration_Sec) + '"' as Working_Hours,
			P_day as Present_Day,
			'="' + dbo.F_Return_Hours(WeekDay_OT_Sec) + '"' as WeekDay_OT,
			'="' + dbo.F_Return_Hours(Weekoff_OT_Sec) + '"' as WeekOff_OT,
			'="' + dbo.F_Return_Hours(Holiday_OT_Sec) + '"' as Holiday_OT,
			'="' + dbo.F_Return_Hours(Total_OT_Sec) + '"' as Total_OT
	FROM	#Emp_OT_Data AA 
	WHERE AA.Emp_ID = 999999
	--order by Emp_ID

 RETURN

