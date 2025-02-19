
CREATE PROCEDURE [dbo].[P_InOut_Record_IN_CMP_Consol]      
 @Cmp_ID   numeric,      
 @From_Date  datetime,      
 @To_Date  datetime ,      
 @Branch_ID  numeric   ,      
 @Cat_ID   numeric  ,      
 @Grd_ID   numeric ,      
 @Type_ID  numeric ,      
 @Dept_ID  numeric  ,      
 @Desig_ID  numeric ,      
 @Emp_ID   numeric  ,      
 @Constraint  varchar(5000) = '',      
 @Report_call varchar(20) = 'IN-OUT',      
 @Weekoff_Entry varchar(1) = 'Y',  @PBranch_ID varchar(200) = '0'
 ,@SubBranch_Id numeric  = 0
 ,@BusSegement_Id numeric =0 
 ,@SalCyc_Id numeric = 0 
 ,@Vertical_Id numeric = 0 
 ,@SubVertical_Id numeric = 0  
      
AS      
  	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON    
       
 if @Branch_ID = 0      
  set @Branch_ID = null      
 If @Cat_ID = 0      
  set @Cat_ID  = null      
        
 if @Type_ID = 0      
  set @Type_ID = null      
 if @Dept_ID = 0      
  set @Dept_ID = null      
 if @Grd_ID = 0      
  set @Grd_ID = null      
 if @Emp_ID = 0      
  set @Emp_ID = null      
 if @Desig_ID =0      
  set @Desig_ID = null      
  
  If @SubBranch_Id = 0
	Set @SubBranch_Id = null
  If @BusSegement_Id = 0
	Set @BusSegement_Id = null
  If @SalCyc_Id = 0
 	Set @SalCyc_Id = null
  If @Vertical_Id = 0
	Set @Vertical_Id = null
  If @SubVertical_Id = 0
	Set @SubVertical_Id = null    
            

	CREATE TABLE #Emp_Cons 
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )      

	if @Constraint <> ''
		begin
			Insert Into #Emp_Cons
			Select cast(data  as numeric),cast(data  as numeric),cast(data  as numeric) From dbo.Split(@Constraint,'#') 
		end
	else 
		begin
			if @PBranch_ID <> '0' and isnull(@Branch_ID,0) = 0
				Begin
					Insert Into #Emp_Cons      
					  select distinct emp_id,branch_id,Increment_ID from dbo.V_Emp_Cons where 
					  cmp_id=@Cmp_ID 
					   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
					and Branch_ID in (select cast(isnull(data,0) as numeric) from dbo.Split(@PBranch_ID,'#'))					   
				   --and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
				   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
				   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
				   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
				   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
				   and Isnull(subBranch_ID,0) = isnull(@SubBranch_Id ,Isnull(subBranch_ID,0))
				   and Isnull(Segment_ID,0) = isnull(@BusSegement_Id ,Isnull(Segment_ID,0))
				   and Isnull(SalDate_id,0) = isnull(@SalCyc_Id ,Isnull(SalDate_id,0))
				   and Isnull(Vertical_ID,0) = isnull(@Vertical_Id ,Isnull(Vertical_ID,0))
				   and Isnull(SubVertical_ID,0) = isnull(@SubVertical_Id ,Isnull(SubVertical_ID,0))
				   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
					  and Increment_Effective_Date <= @To_Date 
					  and 
							  ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
								or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
								or (Left_date is null and @To_Date >= Join_Date)      
								or (@To_Date >= left_date  and  @From_Date <= left_date )) 
								order by Emp_ID
								
						--Delete From #Emp_Cons Where Increment_ID Not In
						--(select TI.Increment_ID from t0095_increment TI inner join
						--(Select Max(Increment_Effective_Date) as Effective_Date,Emp_ID from T0095_Increment
						--Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
						--on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Effective_Date
						--Where Increment_effective_Date <= @to_date) 
						
						Delete E From #Emp_Cons E left Join (Select Max(Increment_ID)as inc from T0095_Increment WITH (NOLOCK)
						Where  Increment_effective_Date <= @to_date Group by emp_ID) as INC_d on E.increment_id = INC_d.inc where isnull(inc_d.inc,0)=0
				End	
			Else
				Begin
					Insert Into #Emp_Cons      
					  select distinct emp_id,branch_id,Increment_ID from dbo.V_Emp_Cons where 
					  cmp_id=@Cmp_ID 
					   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
				   and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
				   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
				   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
				   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
				   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
				   and Isnull(subBranch_ID,0) = isnull(@SubBranch_Id ,Isnull(subBranch_ID,0))
				   and Isnull(Segment_ID,0) = isnull(@BusSegement_Id ,Isnull(Segment_ID,0))
				   and Isnull(SalDate_id,0) = isnull(@SalCyc_Id ,Isnull(SalDate_id,0))
				   and Isnull(Vertical_ID,0) = isnull(@Vertical_Id ,Isnull(Vertical_ID,0))
				   and Isnull(SubVertical_ID,0) = isnull(@SubVertical_Id ,Isnull(SubVertical_ID,0))
				   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
					  and Increment_Effective_Date <= @To_Date 
					  and 
							  ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
								or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
								or (Left_date is null and @To_Date >= Join_Date)      
								or (@To_Date >= left_date  and  @From_Date <= left_date )) 
								order by Emp_ID
								
						--Delete From #Emp_Cons Where Increment_ID Not In
						--(select TI.Increment_ID from t0095_increment TI inner join
						--(Select Max(Increment_Effective_Date) as Effective_Date,Emp_ID from T0095_Increment
						--Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
						--on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Effective_Date
						--Where Increment_effective_Date <= @To_Date) 
						Delete E From #Emp_Cons E left Join (Select Max(Increment_ID)as inc from T0095_Increment WITH (NOLOCK)
						Where  Increment_effective_Date <= @to_date Group by emp_ID) as INC_d on E.increment_id = INC_d.inc where isnull(inc_d.inc,0)=0
				End	
		end

       
 If @Report_call = 'IN-OUT' or @Report_call = 'Inout_Page'
 begin      
  select E_IO.*,Emp_full_Name,Alpha_Emp_Code, Emp_Code,Grd_Name,Shift_name,dept_name ,Type_Name,Desig_Name,CMP_NAME,CMP_ADDRESS,      
   @From_Date as P_From_date ,@To_Date as P_To_Date  
   ,dbo.F_GET_AMPM (Shift_St_Datetime) as Shift_Start_Time,
   dbo.F_GET_AMPM (Shift_End_Time) as Shift_End_Time,
   
   dbo.F_GET_AMPM (case when  datepart(s,In_Time) > 30 then DATEADD(ss,30,In_Time) else In_Time end ) as  Actual_In_Time,  
   dbo.F_GET_AMPM (case when  datepart(s,Out_Time) > 30 then DATEADD(ss,30,Out_Time) else Out_Time end ) as  Actual_Out_Time,  
   
   convert(varchar(10),for_date,103)as On_Date  --CAST(for_Date as varchar(11)) as On_Date,
   ,'' as Leave_Footer,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs,Branch_Name
   From Emp_Inout_Temp as E_IO inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK) on E.emp_ID = E_IO.Emp_Id Left Outer join  
   dbo.T0040_SHIFT_MASTER WITH (NOLOCK) on       
   dbo.T0040_SHIFT_MASTER.Shift_ID = E_IO.Shift_ID inner join dbo.T0040_GRADE_MASTER WITH (NOLOCK) on      
   dbo.T0040_GRADE_MASTER.Grd_ID = E_IO.Grd_ID  left join dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK) on       
   dbo.T0040_DEPARTMENT_MASTER.Dept_id = E_IO.dept_id left outer join dbo.T0040_TYPE_MASTER Et WITH (NOLOCK) on       
   E_IO.Type_ID = Et.Type_ID left Outer Join dbo.T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on       
   E_IO.Desig_ID = DM.Desig_ID inner join dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.Cmp_ID = CM.CMP_ID Inner Join
   T0030_BRANCH_MASTER BM WITH (NOLOCK) on E_IO.Branch_Id = BM.Branch_ID
  Where cast(cast(For_Date as varchar(11)) as smalldatetime) >= cast(cast(@From_Date  as varchar(11)) as smalldatetime)  
  and cast(cast(For_Date as varchar(11)) as smalldatetime) <= cast(cast(@To_Date  as varchar(11)) as smalldatetime)   
  and ( In_Time is not null  or Out_Time is not null  or ab_leave is not null ) 
 
 -- Order by 
--e.Emp_code
     --RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) 
     Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End
 end      
else if @Report_call = 'SUMMARY'      
 begin      
 
   select * from       
   ( select E_IO.Emp_ID,Emp_Full_Name
   ,ISNULL(SUM(Total_Work_Sec) - SUM(ISNULL(Total_More_work_Sec,0)),0) as Total_Work_Sec
    ,ISNULL(SUM(Shift_Sec),0) as Shift_Sec
    ,ISNULL(sum(Late_in_sec),0) as Late_in_sec 
    ,ISNULL(sum(Early_Out_sec),0) as Early_Out_sec    
    ,ISNULL(sum(Total_More_Work_sec),0) as Total_More_Work_sec
    ,ISNULL(sum(Late_In_Count),0) as Late_In_Count
    ,ISNULL(sum(Early_Out_Count),0) as Early_Out_Count      
    , dbo.F_Return_Hours(sum(Total_Work_Sec)- SUM(ISNULL(Total_More_work_Sec,0))) as Total_Work_Hours       
    , dbo.F_Return_Hours(sum(late_in_sec)) as Late_in_Hours       
    , dbo.F_Return_Hours(sum(Early_Out_sec)) as Early_Out_Hours       
    , dbo.F_Return_Hours(sum(Total_More_work_Sec)) as Total_More_Work_Hours       
    , dbo.F_Return_Hours(sum(Total_Less_Work_sec)) as Total_Less_Work_Hours  
	
   from Emp_Inout_Temp as E_IO inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK) on E.emp_ID = E_IO.Emp_Id 
   
   inner join   
    dbo.T0040_SHIFT_MASTER WITH (NOLOCK) on       
    dbo.T0040_SHIFT_MASTER.Shift_ID = E_IO.Shift_ID inner join dbo.T0040_GRADE_MASTER WITH (NOLOCK) on      
    dbo.T0040_GRADE_MASTER.Grd_ID = E_IO.Grd_ID  left join dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK) on       
    dbo.T0040_DEPARTMENT_MASTER.Dept_id = E_IO.dept_id left outer  join dbo.T0040_TYPE_MASTER Et WITH (NOLOCK) on       
    E_IO.Type_ID = Et.Type_ID left Outer Join dbo.T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on       
    E_IO.Desig_ID = DM.Desig_ID  inner join dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.Cmp_ID = CM.CMP_ID  
	
    inner join #Emp_Cons EC on E_IO.emp_id =EC.Emp_ID
   Where cast(cast(For_Date as varchar(11)) as smalldatetime) >= cast(cast(@From_Date  as varchar(11)) as smalldatetime)      
    and cast(cast(For_Date as varchar(11)) as smalldatetime) <= cast(cast(@To_Date  as varchar(11)) as smalldatetime)       
   Group by E_IO.Emp_ID,Emp_full_Name,Emp_Code,Grd_Name,Shift_name,dept_name,Type_Name,Desig_Name      
    ,CMP_NAME,CMP_ADDRESS, E_IO.Sysdate,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs ,Late_Comm_sec,Alpha_Emp_Code     
	
   )Qry      
  --Where Qry.Late_In_Count > 0 or Qry.Early_Out_Count > 0 or Total_less_Work_sec > 0 or Total_More_Work_sec > 0 --or Qry.Working_afterShift_count > 0      
 end       
 else if @Report_call = 'SALARY'      
 begin      
 
  select * Into ##Salary from       
   ( select E_IO.Emp_ID,E_IO.SysDate,Emp_full_Name,Alpha_Emp_Code,Emp_Code,Grd_Name,Shift_name,dept_name,Type_Name,Desig_Name,
   SUM(Total_Work_Sec) as Total_Work_Sec, SUM(Shift_Sec) as Shift_Sec,
    sum(Late_in_sec) as Late_in_sec ,sum(Early_Out_sec) as Early_Out_sec, sum(Total_Less_Work_sec) as Total_Less_Work_sec,
    sum(Total_More_Work_sec) as Total_More_Work_sec,
    sum(Late_In_Count) as Late_In_Count,sum(Early_Out_Count) as Early_Out_Count      
    ,sum(Working_sec_afterShift) as Working_sec_afterShift,
    sum(Working_afterShift_count) as Working_afterShift_count     
    , dbo.F_Return_Hours(sum(Total_Work_Sec)) as Total_Work_Hours       
    , dbo.F_Return_Hours(sum(Shift_Sec)) as Shift_Hours       
    , dbo.F_Return_Hours(sum(late_in_sec)) as Late_in_Hours       
    , dbo.F_Return_Hours(sum(Early_Out_sec)) as Early_Out_Hours       
    , dbo.F_Return_Hours(sum(Total_More_work_Sec)) as Total_More_Work_Hours       
    , dbo.F_Return_Hours(sum(Total_Less_Work_sec)) as Total_Less_Work_Hours       
    , dbo.F_Return_Hours(sum(Working_Sec_AfterShift)) as Working_AfterShift_Hours
    ,COUNT(Case When Shift_Sec = 0 OR AB_LEAVE = 'WO' or AB_LEAVE = 'HO' OR AB_LEAVE = '-' Then Null Else 1 End) as Working_Days
    ,Late_Comm_sec, (Late_Comm_sec/3600) As Late_Grace_Hour
    ,Case When Monthly_Deficit_Adjust_OT_Hrs = 1 then 
		Case When Sum(Total_Less_work_Sec) > SUM(Total_More_work_Sec)  Then
			0
		Else 				
			Case When Is_OT_Applicable = 1 Then
				SUM(Total_More_work_Sec) - Sum(Total_Less_work_Sec)
			Else 0 End
		End
	Else 
		Case When Is_OT_Applicable = 1 Then SUM(Total_More_work_Sec) Else 0 End 
	End As Actual_OT_Sec

	,dbo.F_Return_Hours(Case When Monthly_Deficit_Adjust_OT_Hrs = 1 then 
		Case When Sum(Total_Less_work_Sec) > SUM(Total_More_work_Sec)  Then
			0
		Else 				
			Case When Is_OT_Applicable = 1 Then
				SUM(Total_More_work_Sec) - Sum(Total_Less_work_Sec)
			Else 0 End
		End
	Else 
		Case When Is_OT_Applicable = 1 Then SUM(Total_More_work_Sec) Else 0 End 
	End) As Actual_OT_Hour	

    ,Case When Monthly_Deficit_Adjust_OT_Hrs = 1 then 
		Case When Sum(Total_Less_work_Sec) > SUM(Total_More_work_Sec) Then
			Case When COUNT(Case When Shift_Sec = 0 OR AB_LEAVE = 'WO' or AB_LEAVE = 'HO' Then Null Else 1 End) * Isnull(Late_Comm_sec,0) > Sum(Total_Less_work_Sec) - SUM(Total_More_work_Sec) Then
					0
				Else (Sum(Total_Less_work_Sec) - SUM(Total_More_work_Sec)) - (COUNT(Case When Shift_Sec = 0 OR AB_LEAVE = 'WO' or AB_LEAVE = 'HO' Then Null Else 1 End) * Isnull(Late_Comm_sec,0))
			End
		Else 0 End
	Else 
		SUM(Total_Less_work_Sec)
	End As Actual_Deficit_Sec

	,dbo.F_Return_Hours(Case When Monthly_Deficit_Adjust_OT_Hrs = 1 then 
		Case When Sum(Total_Less_work_Sec) > COUNT(Case When Shift_Sec = 0 OR AB_LEAVE = 'WO' or AB_LEAVE = 'HO' Then Null Else 1 End) * Isnull(Late_Comm_sec,0) Then
			Case When SUM(Total_More_work_Sec) > Sum(Total_Less_work_Sec) - COUNT(Case When Shift_Sec = 0 OR AB_LEAVE = 'WO' or AB_LEAVE = 'HO' Then Null Else 1 End) * Isnull(Late_Comm_sec,0) Then
					0
				Else (Sum(Total_Less_work_Sec) - COUNT(Case When Shift_Sec = 0 OR AB_LEAVE = 'WO' or AB_LEAVE = 'HO' Then Null Else 1 End) * Isnull(Late_Comm_sec,0)) - SUM(Total_More_work_Sec)
			End
		Else 0 End
	Else 
		SUM(Total_More_work_Sec)
	End) As Actual_Deficit_Hour
		
    ,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs
    ,CMP_NAME,CMP_ADDRESS      
    ,@From_Date as P_From_date ,@To_Date as P_To_Date         
   from Emp_Inout_Temp as E_IO inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK) on E.emp_ID = E_IO.Emp_Id inner join   
    dbo.T0040_SHIFT_MASTER WITH (NOLOCK) on       
    dbo.T0040_SHIFT_MASTER.Shift_ID = E_IO.Shift_ID inner join dbo.T0040_GRADE_MASTER WITH (NOLOCK) on      
    dbo.T0040_GRADE_MASTER.Grd_ID = E_IO.Grd_ID  left join dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK) on       
    dbo.T0040_DEPARTMENT_MASTER.Dept_id = E_IO.dept_id left outer  join dbo.T0040_TYPE_MASTER Et WITH (NOLOCK) on       
    E_IO.Type_ID = Et.Type_ID left Outer Join dbo.T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on       
    E_IO.Desig_ID = DM.Desig_ID  inner join dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.Cmp_ID = CM.CMP_ID     
    inner join #Emp_Cons EC on E_IO.emp_id =EC.Emp_ID 
   Where cast(cast(For_Date as varchar(11)) as smalldatetime) >= cast(cast(@From_Date  as varchar(11)) as smalldatetime)      
    and cast(cast(For_Date as varchar(11)) as smalldatetime) <= cast(cast(@To_Date  as varchar(11)) as smalldatetime)       
   Group by E_IO.Emp_ID,Emp_full_Name,Emp_Code,Grd_Name,Shift_name,dept_name,Type_Name,Desig_Name      
    ,CMP_NAME,CMP_ADDRESS, E_IO.Sysdate,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs ,Late_Comm_sec,Alpha_Emp_Code     
   )Qry      
  Where Qry.Late_In_Count > 0 or Qry.Early_Out_Count > 0 or Total_less_Work_sec > 0 or Total_More_Work_sec > 0 --or Qry.Working_afterShift_count > 0      
 end       
 ELSE IF @Report_call = 'OFF SHIFT'      
 begin      
  select E_IO.*,Emp_full_Name,Emp_Code,Grd_Name,Shift_name,dept_name ,Type_Name,Desig_Name,CMP_NAME,CMP_ADDRESS      
   ,@From_Date as P_From_date ,@To_Date as P_To_Date         
  From Emp_Inout_Temp as E_IO inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK) on E.emp_ID = E_IO.Emp_Id  inner join      
   dbo.T0040_SHIFT_MASTER WITH (NOLOCK) on       
   dbo.T0040_SHIFT_MASTER.Shift_ID = E_IO.Shift_ID inner join dbo.T0040_GRADE_MASTER WITH (NOLOCK) on      
   dbo.T0040_GRADE_MASTER.Grd_ID = E_IO.Grd_ID  left join dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK) on       
   dbo.T0040_DEPARTMENT_MASTER.Dept_id = E_IO.dept_id Left outer join dbo.T0040_TYPE_MASTER Et WITH (NOLOCK) on       
   E_IO.Type_ID = Et.Type_ID left Outer Join dbo.T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on       
   E_IO.Desig_ID = DM.Desig_ID  inner join dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.Cmp_ID = CM.CMP_ID      
   inner join #Emp_Cons EC on E_IO.emp_id =EC.Emp_ID
  Where cast(cast(For_Date as varchar(11)) as smalldatetime) >= cast(cast(@From_Date  as varchar(11)) as smalldatetime)      
   and cast(cast(For_Date as varchar(11)) as smalldatetime) <= cast(cast(@To_Date  as varchar(11)) as smalldatetime)       
   and Working_afterShift_count > 0       
 end    
  else If @Report_call = 'Shift_End' 
 begin      
   
  Update Emp_Inout_Temp set Shift_St_Datetime = cast(CONVERT(VARCHAR(11), For_Date, 121)  + CONVERT(VARCHAR(12), Shift_St_Datetime, 114) as datetime)  from Emp_Inout_Temp
  Update Emp_Inout_Temp set Shift_en_Datetime   = cast(CONVERT(VARCHAR(11), For_Date, 121)  + CONVERT(VARCHAR(12), Shift_en_Datetime, 114) as datetime)  from Emp_Inout_Temp	
  
   
  select 
  --E_IO.*,
  E_IO.emp_id,E_IO.for_Date,E_IO.Dept_id,E_IO.Grd_ID,E_IO.Type_ID,E_IO.Desig_ID,E_IO.Shift_ID,
  E_IO.In_Time,case when E_IO.Out_Time >  Shift_en_Datetime  then Shift_en_Datetime else E_IO.Out_Time end as  Out_Time
  ,E_IO.Duration,
  E_IO.Duration_sec
  ,E_IO.Late_In,
  case when E_IO.Out_Time >  Shift_en_Datetime  then '' ELSE E_IO.Late_Out END AS Late_Out ,
  E_IO.Early_In,E_IO.Early_Out,
  E_IO.Leave,
  E_IO.Shift_Sec,
  E_IO.Shift_Dur,
  case when E_IO.Out_Time >  Shift_en_Datetime then DBO.F_Return_Hours(DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime)) else E_IO.Total_work end as Total_work ,
  --E_IO.Less_Work
  --,E_IO.More_Work
  case when E_IO.Out_Time >  Shift_en_Datetime then cast( DBO.F_Return_Hours(case when (( (E_IO.Shift_Sec) - DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime) ) ) < 0 then 0 else ((E_IO.Shift_Sec) - (DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime) ) ) end)  as varchar) else E_IO.Less_Work end as Less_Work
  , case when E_IO.Out_Time >  Shift_en_Datetime then cast( DBO.F_Return_Hours(case when ((DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime) )- (E_IO.Shift_Sec)) < 0 then 0 else ((DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime) )- (E_IO.Shift_Sec)) end)  as varchar) else E_IO.More_Work end as More_Work
  ,Reason,
  E_IO.AB_LEAVE,E_IO.Late_In_Sec,E_IO.Late_In_count,E_IO.Early_Out_sec,E_IO.Early_Out_Count,
  --E_IO.Total_Less_work_Sec,
  case when E_IO.Out_Time >  Shift_en_Datetime then (case when (( (E_IO.Shift_Sec) - DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime) ) ) < 0 then 0 else ((E_IO.Shift_Sec) - (DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime) ) ) end)   else E_IO.Total_Less_work_Sec end as Total_Less_work_Sec,
  
  E_IO.Shift_St_Datetime,E_IO.Shift_en_Datetime,
  E_IO.Working_Sec_AfterShift,E_IO.Working_AfterShift_Count,E_IO.Leave_Reason,E_IO.Inout_Reason,
  E_IO.SysDate,
  case when E_IO.Out_Time >  Shift_en_Datetime then DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime) else  E_IO.Total_Work_Sec end as Total_Work_Sec,
  0 as Late_Out_Sec,
  E_IO.Early_In_sec
 -- ,E_IO.Total_More_work_Sec,
  , case when E_IO.Out_Time >  Shift_en_Datetime then (case when ((DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime) )- (E_IO.Shift_Sec)) < 0 then 0 else ((DATEDIFF(S,E_IO.In_Time,Shift_en_Datetime) )- (E_IO.Shift_Sec)) end)  else E_IO.Total_More_work_Sec end as Total_More_work_Sec
  ,E_IO.Is_OT_Applicable,E_IO.Monthly_Deficit_Adjust_OT_Hrs,E_IO.Late_Comm_sec
 
  ,Emp_full_Name,Alpha_Emp_Code, Emp_Code,Grd_Name,Shift_name,dept_name ,Type_Name,Desig_Name,CMP_NAME,CMP_ADDRESS,      
   @From_Date as P_From_date ,@To_Date as P_To_Date  
   ,dbo.F_GET_AMPM (Shift_St_Datetime) as Shift_Start_Time,
   dbo.F_GET_AMPM (Shift_End_Time) as Shift_End_Time,
   
   --- Modify Jignesh 23-Oct-2012 ( add 1 min if Sec > 30 )
   --dbo.F_GET_AMPM (In_Time) as Actual_In_Time,
   dbo.F_GET_AMPM (case when  datepart(s,In_Time) > 30 then DATEADD(ss,30,In_Time) else In_Time end ) as  Actual_In_Time,  
   --dbo.F_GET_AMPM (Out_Time) as Actual_Out_Time , 
   dbo.F_GET_AMPM (case when  datepart(s,Out_Time) > 30 then DATEADD(ss,30,Out_Time) else Out_Time end ) as  Actual_Out_Time,  
   
   convert(varchar(10),for_date,103)as On_Date  --CAST(for_Date as varchar(11)) as On_Date,
   ,'' as Leave_Footer,Is_OT_Applicable,Monthly_Deficit_Adjust_OT_Hrs
   
   
   From Emp_Inout_Temp as E_IO inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK) on E.emp_ID = E_IO.Emp_Id Left Outer join  
   dbo.T0040_SHIFT_MASTER WITH (NOLOCK) on       
   dbo.T0040_SHIFT_MASTER.Shift_ID = E_IO.Shift_ID inner join dbo.T0040_GRADE_MASTER WITH (NOLOCK) on      
   dbo.T0040_GRADE_MASTER.Grd_ID = E_IO.Grd_ID  left join dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK) on       
   dbo.T0040_DEPARTMENT_MASTER.Dept_id = E_IO.dept_id left outer join dbo.T0040_TYPE_MASTER Et WITH (NOLOCK) on       
   E_IO.Type_ID = Et.Type_ID left Outer Join dbo.T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on       
   E_IO.Desig_ID = DM.Desig_ID inner join dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.Cmp_ID = CM.CMP_ID   
   inner join #Emp_Cons EC on E_IO.emp_id =EC.Emp_ID   
  Where cast(cast(For_Date as varchar(11)) as smalldatetime) >= cast(cast(@From_Date  as varchar(11)) as smalldatetime)  
  and cast(cast(For_Date as varchar(11)) as smalldatetime) <= cast(cast(@To_Date  as varchar(11)) as smalldatetime)   
  and ( In_Time is not null  or Out_Time is not null  or ab_leave is not null ) 
  Order by 
--e.Emp_code
     RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) 
 end   
 
  else if @Report_call = 'SUMMARY_Attendance'      
 begin      
  select * from       
   ( select E_IO.Emp_ID,Emp_full_Name,Alpha_Emp_Code,sum(Shift_Sec) as Total_Work_sec, 
   Cast(Replace(dbo.F_Return_Hours(Total_Work_Sec_new - Required_Hrs_Till_date),':','.') As numeric(18,2)) as Total_Work_Hours,
	Required_Hrs_Till_date, Cast(Replace(dbo.F_Return_Hours(Required_Hrs_Till_date),':','.') As numeric(18,2)) as Total_Required_Hours_Till_Date,
	Dur_Sec  As Achieved_Sec,Cast(Replace(dbo.F_Return_Hours(Dur_Sec ),':','.') As numeric(18,2)) as Achieved_Hours
	,Required_Hrs_Till_date - Dur_Sec as Short_Sec, 
	 Cast(Replace(dbo.F_Return_Hours(Required_Hrs_Till_date - Dur_Sec),':','.')As numeric(18,2)) as Short_Hours,
	Sum(Total_More_Work_sec) as Total_More_Work_sec
    , Cast(Replace(dbo.F_Return_Hours(sum(Total_More_work_Sec) ),':','.') As numeric(18,2)) as Total_More_Work_Hours
    ,@From_Date as P_From_date ,@To_Date as P_To_Date         
   from Emp_Inout_Temp as E_IO inner join dbo.T0080_EMP_MASTER E WITH (NOLOCK) on E.emp_ID = E_IO.Emp_Id inner join   
    dbo.T0040_SHIFT_MASTER WITH (NOLOCK) on       
    dbo.T0040_SHIFT_MASTER.Shift_ID = E_IO.Shift_ID inner join dbo.T0040_GRADE_MASTER WITH (NOLOCK) on      
    dbo.T0040_GRADE_MASTER.Grd_ID = E_IO.Grd_ID  left join dbo.T0040_DEPARTMENT_MASTER WITH (NOLOCK) on       
    dbo.T0040_DEPARTMENT_MASTER.Dept_id = E_IO.dept_id left outer  join dbo.T0040_TYPE_MASTER Et WITH (NOLOCK) on       
    E_IO.Type_ID = Et.Type_ID left Outer Join dbo.T0040_DESIGNATION_MASTER DM WITH (NOLOCK) on       
    E_IO.Desig_ID = DM.Desig_ID  inner join dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.Cmp_ID = CM.CMP_ID Left Outer Join
    (Select Emp_Id,Isnull(SUM(Shift_Sec),0) as Required_Hrs_Till_date From
    (select Distinct Emp_id, Isnull((Shift_Sec),0) as Shift_Sec, For_Date 
		From Emp_Inout_Temp 
		Where cast(cast(For_Date as varchar(11)) as smalldatetime) >= cast(cast(@From_Date as varchar(11)) as smalldatetime)      
		and cast(cast(For_Date as varchar(11)) as smalldatetime) <= cast(cast(GETDATE()  as varchar(11)) as smalldatetime)       
		And (AB_LEAVE <> 'WO' AND AB_LEAVE <> 'HO') OR AB_LEAVE Is null)As Qry1 Group by Emp_id) As Qry4 
	on E_IO.emp_id = Qry4.emp_id Left Outer Join
    (Select Emp_id, Isnull(SUM(Duration_sec),0) as Dur_Sec 
	    From Emp_Inout_Temp 
		Where (AB_LEAVE <> 'WO' AND AB_LEAVE <> 'HO') OR AB_LEAVE Is null Group by Emp_id) Qry2 on E_IO.emp_id = Qry2.emp_id
    Left Outer Join
    (select Emp_id, Isnull(SUM(Shift_Sec),0) as Total_Work_Sec_new
		From Emp_Inout_Temp 
		Where cast(cast(For_Date as varchar(11)) as smalldatetime) >= cast(cast(@From_Date as varchar(11)) as smalldatetime)      
		and cast(cast(For_Date as varchar(11)) as smalldatetime) <= cast(cast(@To_Date  as varchar(11)) as smalldatetime)       
		And (AB_LEAVE <> 'WO' AND AB_LEAVE <> 'HO') OR AB_LEAVE Is null Group by Emp_id) Qry3 
	on E_IO.emp_id = Qry3.emp_id 
		
		inner join #Emp_Cons EC on E_IO.emp_id =EC.Emp_ID
		
   Where cast(cast(For_Date as varchar(11)) as smalldatetime) >= cast(cast(@From_Date  as varchar(11)) as smalldatetime)      
    and cast(cast(For_Date as varchar(11)) as smalldatetime) <= cast(cast(@To_Date  as varchar(11)) as smalldatetime)       
   Group by E_IO.Emp_ID,Emp_full_Name,Alpha_Emp_Code,Required_Hrs_Till_date,Dur_Sec ,Total_Work_Sec_new            
   )Qry      
  
 end    
       
 RETURN      




