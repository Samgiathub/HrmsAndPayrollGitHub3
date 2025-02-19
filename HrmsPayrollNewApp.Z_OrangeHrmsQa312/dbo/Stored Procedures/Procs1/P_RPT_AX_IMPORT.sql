

-- =============================================
-- Author:		<Jaina>
-- Create date: <31-03-2018>
-- Description:	<Description,,>
	
		--exec P_RPT_AX_IMPORT @Cmp_id=119,@From_Date='2018-03-01',@To_Date='2018-03-31',@Branch_Id='0',@Cat_ID='0',@Grd_Id='0',@Type_Id='0',@Dept_Id='0',@Desig_ID='0',@Emp_Id=13978,@Constraint='',@Segment_Id='0',@Vertical_Id='0',@SubVertical_ID='0',@SubBranch_Id='0',@Report_For='AB'
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P_RPT_AX_IMPORT] 
	 @Cmp_ID			numeric          
	,@From_Date		datetime          
	,@To_Date			datetime          	
	,@Flag       varchar(max) = ''  
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
		
	
	--CREATE table #Emp_Cons 
	--(      
	--	Emp_ID NUMERIC ,     
	--	Branch_ID NUMERIC,
	--	Increment_ID NUMERIC
	--)	
	
	--exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'',@Vertical_Id,@SubVertical_Id,'',0,0,0,'0',0,0   
	--select * from #emp_cons
	--#Emp_Cons detail get from AX_ERP_REPORT_Customized SP.
	if @Flag In ('AB','COMP','HL','PR','AR','HR')
	begin
			Create table #Month_Dates
			(
				For_Date datetime
			)
			
			declare @Temp_Date datetime
			set @Temp_Date = @From_Date
			
			While @Temp_Date <= @To_Date
			Begin
				Insert INTO #Month_Dates VALUES (@Temp_Date)
				set @Temp_Date = DATEADD(dd,1,@Temp_Date)
			End
			
			CREATE table #Data         
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
			   IO_Tran_Id	   numeric default 0, -- io_tran_id is used for is_cmp_purpose (t0150_emp_inout)
			   OUT_Time datetime,
			   Shift_End_Time datetime,			--Ankit 16112013
			   OT_End_Time numeric default 0,	--Ankit 16112013
			   Working_Hrs_St_Time tinyint default 0, --Hardik 14/02/2014
			   Working_Hrs_End_Time tinyint default 0, --Hardik 14/02/2014
			   GatePass_Deduct_Days numeric(18,2) default 0 -- Add by Gadriwala Muslim 05012014
		   )    
			
		   exec SP_CALCULATE_PRESENT_DAYS @Cmp_ID=@Cmp_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0,@constraint='',@Return_Record_set=4,@PBranch_ID='0',@PVertical_ID='0',@PSubVertical_ID='0',@PDept_ID='0'	
		   
			
			
			/*************************************************************************
			Added by Nimesh: 17/Nov/2015 
			(To get holiday/weekoff data for all employees in seperate table)
			*************************************************************************/
			IF OBJECT_ID('tempdb..#EMP_HOLIDAY') IS NULL
				BEGIN
					CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));
					CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);
				END

			IF OBJECT_ID('tempdb..#Emp_WeekOff') IS NULL
				BEGIN
					CREATE TABLE #EMP_WEEKOFF
					(
						Row_ID			NUMERIC,
						Emp_ID			NUMERIC,
						For_Date		DATETIME,
						Weekoff_day		VARCHAR(10),
						W_Day			numeric(4,1),
						Is_Cancel		BIT
					)
					CREATE CLUSTERED INDEX IX_Emp_WeekOff_EmpID_ForDate ON #EMP_WEEKOFF(Emp_ID, For_Date)		
				END
		  	
			EXEC SP_GET_HW_ALL @CONSTRAINT='',@CMP_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@TO_DATE, @All_Weekoff = 0, @Exec_Mode=0		

			
			
			Create table #Leave_Detail
			(
				Emp_Id numeric(18,0),
				For_Date datetime,
				P_days numeric(18,2) default 0,
				HW_Days numeric(18,2) default 0,
				Leave_Days numeric(18,2) default 0,
				A_Days numeric(18,2) default 0,
				Type varchar(50),
				Leave_Code varchar(50),
				Leave_Type varchar(50)
				
			)
			
			Insert INTO #Leave_Detail (Emp_Id,For_Date)
			SELECT E.Emp_ID,M.For_Date from #Emp_Cons E cross JOIN #Month_Dates M
			
			--select * from #Emp_Cons
			update L set P_days = isnull(D.P_days,0)
			from #Leave_Detail L inner JOIN 
				 #Emp_Cons E ON E.Emp_ID = L.Emp_Id inner JOIN
				 #Data D ON L.For_Date = D.For_date and E.Emp_ID = D.Emp_Id
			
			
			update L set HW_Days = W.W_Day
			from #Leave_Detail L inner JOIN 
				 #Emp_Cons E ON E.Emp_ID = L.Emp_Id inner JOIN
				 #EMP_WEEKOFF W ON W.For_Date =L.For_Date and W.Emp_ID = L.Emp_Id
				 
			update L set HW_Days = H.H_DAY
			from #Leave_Detail L inner JOIN 
				 #Emp_Cons E ON E.Emp_ID = L.Emp_Id inner JOIN
				 #EMP_HOLIDAY H ON H.For_Date =L.For_Date and H.EMP_ID = L.Emp_Id
			
			
			
			update L set Leave_Days = CASE WHEN T.Leave_Used > 0 THEN T.Leave_Used ELSE T.CompOff_Used END,
						 L.Type = LM.Leave_Type,L.Leave_Code = case when lm.Default_Short_Name = '' then lm.Leave_Code else lm.default_Short_name end,   --Change by Jaina 28-05-2018
						 L.Leave_Type = LAD.Leave_Assign_As
			from #Leave_Detail L inner JOIN 
				 #Emp_Cons E ON E.Emp_ID = L.Emp_Id inner JOIN
				 T0140_LEAVE_TRANSACTION T ON T.Emp_ID = L.Emp_Id and T.For_Date = L.For_Date inner JOIN
				 T0040_LEAVE_MASTER LM on LM.Leave_ID = T.Leave_ID inner JOIN
				 T0120_LEAVE_APPROVAL LA ON LA.Emp_ID = L.Emp_Id inner JOIN
				 T0130_LEAVE_APPROVAL_DETAIL LAD ON LAD.Leave_Approval_ID = LA.Leave_Approval_ID and L.For_Date between LAD.From_Date AND LAD.To_Date
			
			update L set A_Days =ABS(1 - (L.P_days + L.Leave_Days+L.HW_Days))
			from #Leave_Detail L inner JOIN 
				 #Emp_Cons E ON E.Emp_ID = L.Emp_Id 
				
			--delete from #Leave_Detail where P_days = 1 --or (P_days + Leave_Days > 0)
		
			
			
			DECLARE @T_DATE DATETIME
			DECLARE @ST_DATE DATETIME
			DECLARE @END_DATE DATETIME
			DECLARE @A_DAYS NUMERIC(18,2) = 0
			DECLARE @CNT_ABSENT NUMERIC(18,2) = 0	
			DECLARE @A_EMP_ID NUMERIC(18,0)
			DECLARE @HW_DAY NUMERIC(18,2) = 0
			declare @L_Type varchar(50) = ''
			declare @L_Code varchar(50) = '' 
			
			
			if @Flag = 'AB'
				Begin	
			
					DELETE L FROM #Leave_Detail L 
							LEFT OUTER JOIN #Leave_Detail L1 ON L.Emp_Id=L1.Emp_Id AND L.For_Date=DATEADD(D, -1, L1.For_Date) AND L1.A_Days > 0
							LEFT OUTER JOIN #Leave_Detail L2 ON L.Emp_Id=L2.Emp_Id AND L.For_Date=DATEADD(D, 1, L2.For_Date) AND L2.A_Days > 0
					WHERE	L.HW_Days > 0 AND (L1.Emp_Id IS NULL OR L2.Emp_Id IS NULL)

					
					DELETE	FROM #Leave_Detail WHERE A_Days < 1 AND HW_Days = 0  --and A_Days= 0.5
					
					
					
				end
			else if @Flag = 'COMP'
				Begin
					delete FROM #Leave_Detail where  isnull(Leave_Code,'') NOt IN ('COMP','LWP')
				End
			else if @Flag = 'HL'
				begin
						delete FROM #Leave_Detail where Leave_Days <> 0.5
				end
			else if @Flag = 'HR'
				BEGIN
						delete FROM #Leave_Detail where A_Days <> 0.5
				end
			
			alter table #Leave_Detail add Row_ID INT  Identity(1,1)
				
				
				
			SELECT	Row_ID, Cast(ROW_NUMBER() OVER(PARTITION BY LD.Emp_Id Order By For_Date) As INT) As R_Index,EMP_ID, FOR_DATE
			INTO	#TMP_DETAIL
			FROM	#Leave_Detail LD
			Where	NOT EXISTS(select 1 from #Leave_Detail LD1 
								Where	LD.For_Date=DATEADD(D,1, LD1.For_Date) 
										AND LD.Emp_Id=LD1.Emp_ID)		
			
			
			--DELETE T from #TMP  T inner JOIN  #Leave_Detail LD  ON T.Emp_ID=LD.Emp_ID AND T.For_Date=LD.For_Date
			--Where LD.HW_Days=1
			
				
			SELECT	T.Emp_Id, T.For_Date AS FROM_DATE, T1.For_Date, LD.For_Date AS TO_DATE, Cast(0 As Numeric(18,4)) As D_Period,LD.Leave_Type,LD.Leave_Code
			INTO	#ABSENT
			FROM	#TMP_DETAIL T
					LEFT OUTER JOIN #TMP_DETAIL T1 ON T.Emp_Id=T1.Emp_Id AND T.R_Index = T1.R_Index-1
					LEFT OUTER JOIN #Leave_Detail LD ON LD.Emp_Id=T.Emp_Id AND LD.For_Date BETWEEN T.For_Date AND IsNull(DATEADD(D,-1,T1.For_Date) , LD.For_Date)
			
			
			
			--select * from #Leave_Detail ld where ld.Emp_Id=13983

			if @Flag = 'AB' --Absent Report
				BEGIN
					DELETE	F
					--SELECT	F.*, F1.Emp_Id,F1.FROM_DATE
					FROM	#ABSENT F
							LEFT OUTER JOIN (SELECT EMP_ID,FROM_DATE, MAX(TO_DATE) AS TO_DATE
										FROM	#ABSENT F1
										GROUP BY Emp_Id,FROM_DATE) F1 ON F.TO_DATE=F1.TO_DATE AND F.Emp_Id=F1.Emp_Id
					WHERE	F1.Emp_Id IS NULL

				
			
					Update	F
					SET		D_Period = LD.A_Days
					FROM	#ABSENT F
							INNER JOIN (SELECT	F1.EMP_ID, F1.FROM_DATE, SUM(LD.A_Days + LD.HW_Days) AS A_Days
										FROM	#Leave_Detail LD 
												INNER JOIN #ABSENT F1 ON LD.Emp_Id=F1.Emp_Id AND LD.For_Date BETWEEN F1.FROM_DATE AND F1.TO_DATE
										GROUP BY F1.Emp_Id, F1.FROM_DATE) LD ON F.Emp_Id=LD.Emp_Id AND F.FROM_DATE=LD.FROM_DATE 

					SELECT	ROW_NUMBER() OVER(ORDER BY A.EMP_ID, A.FROM_DATE) AS [Sr. No], Alpha_Emp_Code AS [E-CODE], 
							 E.Emp_First_Name + ' ' + E.Emp_Last_Name AS [Name of Emp],--Emp_Full_Name AS [Name of Emp],
							 BM.Branch_Name AS [Division], D.Dept_Name As [Department],
							'="' + convert(varchar(10),A.FROM_DATE,105) + '"' As [From date], 
							'="' + convert(varchar(10),A.TO_DATE,105) + '"' As [To date], Cast(D_Period As Numeric(18,2)) As [Nos of days]
					FROM	#ABSENT A
							INNER JOIN #EMP_CONS EC ON A.Emp_Id=EC.Emp_ID
							INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON EC.Increment_ID=I.Increment_ID
							INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON A.Emp_Id=E.Emp_ID
							INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON EC.Branch_ID=BM.Branch_ID
							LEFT OUTER JOIN T0040_DEPARTMENT_MASTER D WITH (NOLOCK) ON I.Dept_ID=D.Dept_Id
							
					
					RETURN
				END
			if @Flag = 'COMP'  --Comp & LWP Leave
			BEGIN
					--Added by Jaina 28-05-2018 Start
					DELETE	F					
					FROM	#ABSENT F
							LEFT OUTER JOIN (SELECT EMP_ID,FROM_DATE, MAX(TO_DATE) AS TO_DATE
										FROM	#ABSENT F1
										GROUP BY Emp_Id,FROM_DATE) F1 ON F.TO_DATE=F1.TO_DATE AND F.Emp_Id=F1.Emp_Id
					WHERE	F1.Emp_Id IS NULL

				
			
					Update	F
					SET		D_Period = LD.A_Days
					FROM	#ABSENT F
							INNER JOIN (SELECT	F1.EMP_ID, F1.FROM_DATE, SUM(LD.A_Days + LD.HW_Days) AS A_Days
										FROM	#Leave_Detail LD 
												INNER JOIN #ABSENT F1 ON LD.Emp_Id=F1.Emp_Id AND LD.For_Date BETWEEN F1.FROM_DATE AND F1.TO_DATE
										GROUP BY F1.Emp_Id, F1.FROM_DATE) LD ON F.Emp_Id=LD.Emp_Id AND F.FROM_DATE=LD.FROM_DATE 
										
					--Added by Jaina 28-05-2018 End
					
					SELECT	 Alpha_Emp_Code AS [E-CODE], 					
							'="' + convert(varchar(10),A.FROM_DATE,105) + '"' As [From date], 
							'="' + convert(varchar(10),A.TO_DATE,105) + '"' As [To date],A.Leave_Code As [Leave Code]
					FROM	#ABSENT A
							INNER JOIN #EMP_CONS EC ON A.Emp_Id=EC.Emp_ID
							INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON EC.Increment_ID=I.Increment_ID
							INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON A.Emp_Id=E.Emp_ID
			END
			if @Flag = 'HL'  --Half Day Leave
			BEGIN
					
					SELECT	 Alpha_Emp_Code AS [E-CODE], 					
							'="' + convert(varchar(10),A.FROM_DATE,105) + '"' As [From date], 
							'="' + convert(varchar(10),A.TO_DATE,105) + '"' As [To date],A.Leave_Code As [Leave Code],A.Leave_Type As [Type]
					FROM	#ABSENT A
							INNER JOIN #EMP_CONS EC ON A.Emp_Id=EC.Emp_ID
							INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON EC.Increment_ID=I.Increment_ID
							INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON A.Emp_Id=E.Emp_ID
				
				
			END
			if @Flag = 'PR'  --Pending Attendance Regularization
			BEGIN
				
					select Alpha_Emp_Code AS [E-CODE], 					
					'="' + convert(varchar(10),ER.For_Date,105) + '"' As [FROM], 
					'="' + convert(varchar(10),ER.For_Date,105) + '"' As [To]
					,'' AS [Leave Code],ER.Half_Full_day as [Remarks]
					from T0150_EMP_INOUT_RECORD ER WITH (NOLOCK)
						 left OUTER JOIN #DATA D ON D.EMP_ID = ER.EMP_ID AND D.FOR_DATE = ER.FOR_DATE
						 INNER JOIN #EMP_CONS EC  ON EC.EMP_ID = ER.EMP_ID
						 INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON EC.Increment_ID=I.Increment_ID
						 INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON EC.Emp_Id=E.Emp_ID
					where ER.Chk_By_Superior = 0 and ER.Reason <> '' and ER.For_Date between @From_date AND @To_Date
					
			END
			IF @Flag = 'AR'--Approved Attendance Regularization
			begin
					
					select Alpha_Emp_Code AS [E-CODE], 					
					'="' + convert(varchar(10),ER.For_Date,105) + '"' As [FROM], 
					'="' + convert(varchar(10),ER.For_Date,105) + '"' As [To]
					,'' AS [Leave Code],ER.Half_Full_day as [Remarks]
					from T0150_EMP_INOUT_RECORD ER WITH (NOLOCK)
						 left OUTER JOIN #DATA D ON D.EMP_ID = ER.EMP_ID AND D.FOR_DATE = ER.FOR_DATE
						 INNER JOIN #EMP_CONS EC  ON EC.EMP_ID = ER.EMP_ID
						 INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON EC.Increment_ID=I.Increment_ID
						 INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON EC.Emp_Id=E.Emp_ID
					where ER.Chk_By_Superior = 1 and ER.Reason <> '' and ER.For_Date between @From_date AND @To_Date
			end
			IF @FLAG = 'HR' -- Half Day Report
			BEGIN
				
				--alter table #Leave_Detail add HD_Shift_St_Time datetime
				--alter table #Leave_Detail add HD_Shift_End_Time datetime 
				
				
				--select * from #Leave_Detail
				--update L SET L.HD_Shift_St_Time = 
				----select L.Emp_Id,L.For_Date,L.Leave_Type,dateadd(hh, DATEDIFF(hh, S.Shift_St_Time+ L.For_Date, s.Shift_End_Time+l.for_date) / 2,S.Shift_St_Time + L.For_Date ),S.Shift_St_Time + L.For_Date As M_sT_time, S.Shift_End_Time + L.For_Date As M_End_time
				--	case --when L.Leave_Type = 'First Half' THEN dateadd(hh, DATEDIFF(hh, S.Shift_St_Time+ L.For_Date, s.Shift_End_Time+l.for_date) / 2,S.Shift_St_Time + L.For_Date )
				--		  when L.Leave_Type = 'Second Half' THEN S.Shift_St_Time + L.For_Date 
				--	 else S.Shift_St_Time+ l.For_Date END ,
				--	l.HD_Shift_End_Time = CASE WHEN L.Leave_Type = 'First Half' THEN S.Shift_End_Time+ L.For_Date 
				--		  --when L.Leave_Type = 'Second Half' THEN dateadd(hh, DATEDIFF(hh, s.Shift_St_Time+ L.For_Date, s.Shift_End_Time+l.for_date) / 2,s.Shift_St_Time + L.For_Date ) 
				--	else s.Shift_End_Time + L.For_Date end 
				-- from #Leave_Detail L inner JOIN T0040_SHIFT_MASTER S ON S.Shift_ID = (select SHIFT_ID FROM DBO.F_GET_CURR_SHIFT(L.Emp_Id,L.For_date))
				-- where l.LEave_type is not null
				
				--select * from #Leave_Detail
				select ROW_NUMBER() OVER(ORDER BY L.EMP_ID) AS [Sr. No],E.Alpha_Emp_Code as [E-CODE],
					E.Emp_First_Name + ' ' + E.Emp_Last_Name as [Name of Emp],BM.Branch_Name as [Division],DM.Dept_Name as [Department],
					'="'+Convert(varchar(10),L.For_Date,105) + '"' as [From Date], 
					'="'+CONVERT(varchar(10),L.For_Date,105) + '"' as [To Date],					
					case when dateadd(hh, DATEDIFF(hh, d.Shift_Start_Time,d.Shift_End_Time) / 2,d.Shift_Start_Time ) < d.OUT_Time THEN 'First Half' 
						when (d.In_time is null and l.Leave_Type = 'First Half') then 'Second Half'
						WHEN (d.In_time is null and L.Leave_Type = 'Second Half') THEN 'First Half'
						else 'Second Half' END  As [Type]										
				from #Emp_Cons EC 
					inner JOIN #Leave_Detail L ON L.Emp_Id = EC.Emp_id 
					left OUTER JOIN #Data d ON L.For_Date =d.For_date and d.Emp_Id = L.Emp_Id
					left OUTER join T0040_SHIFT_MASTER S WITH (NOLOCK) ON S.Shift_ID  = (select SHIFT_ID FROM DBO.F_GET_CURR_SHIFT(L.Emp_Id,L.For_date))
					INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON EC.Increment_ID=I.Increment_ID
					INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON L.Emp_Id=E.Emp_ID
					INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON EC.Branch_ID=BM.Branch_ID
					LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I.Dept_ID=DM.Dept_Id
					

				
			END
	END
	
	if @Flag = 'PL'  -- Leave Applied Pending For Approval
	begin
					
			select ROW_NUMBER() OVER(ORDER BY LA.EMP_ID, LA.Application_Date) AS [Sr. No],E.Alpha_Emp_Code as [E-CODE],
				E.Emp_First_Name + ' ' + E.Emp_Last_Name as [Name of Emp],BM.Branch_Name As [Division],
				D.Dept_Name as [Department],
				'="' + CONVERT(varchar(10),LA.Application_Date,105) + '"' as [Leave applied date],
				'="' + convert(varchar(10),LAD.From_Date,105) + '"' as [From Date],
				'="' + convert(varchar(10),LAD.To_Date,105) + '"' as [To Date],LAD.Leave_Period as [Nos of Days] 
			from T0100_LEAVE_APPLICATION LA WITH (NOLOCK)
		 		 INNER JOIN T0110_LEAVE_APPLICATION_DETAIL LAD WITH (NOLOCK) ON la.Leave_Application_ID = LAD.Leave_Application_ID
		 		 INNER JOIN #EMP_CONS EC ON LA.Emp_Id=EC.Emp_ID
		 		 INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON EC.Increment_ID=I.Increment_ID
				 INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON LA.Emp_Id=E.Emp_ID
				 INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON EC.Branch_ID=BM.Branch_ID
				 LEFT OUTER JOIN T0040_DEPARTMENT_MASTER D WITH (NOLOCK) ON I.Dept_ID=D.Dept_Id
		 	where LA.Application_Status = 'P' and LAD.From_Date between @From_Date and @To_date
		 			and LAD.To_Date between @From_Date AND @To_Date
		 			and NOT EXISTS(SELECT 1 FROM T0120_LEAVE_APPROVAL LA1 WITH (NOLOCK) WHERE LA.LEAVE_APPLICATION_ID=LA1.LEAVE_APPLICATION_ID)
		 			
	end
	
		return 	
			
	--;WITH CTE(Row_ID, R_Index, EMP_ID, For_Date, To_Date, Flag)AS
	--(
	--	SELECT	Row_ID, Cast(ROW_NUMBER() OVER(Order By For_Date) As INT) As R_Index,EMP_ID, FOR_DATE, CAST(NULL AS DateTime), CAST('M' AS varchar(1)) As Flag
	--	FROM	#Leave_Detail LD
	--	Where	NOT EXISTS(select 1 from #Leave_Detail LD1 Where LD.For_Date=DATEADD(D,1, LD1.For_Date) AND LD.Emp_Id=LD1.Emp_ID)		
	--	--UNION ALL
	--	--SELECT	LD.Row_ID, Cast(ROW_NUMBER() OVER(Order By LD.For_Date) As INT) As R_Index,LD.EMP_ID, CTE.For_Date, LD.FOR_DATE, CAST('C' AS varchar(1)) As Flag
	--	--FROM	#Leave_Detail LD
	--	--		--INNER JOIN CTE ON LD.ROW_ID > CTE.ROW_ID AND LD.Emp_Id=CTE.EMP_ID
	--	--Where	NOT EXISTS(SELECT 1 FROM CTE C Where C.For_Date=LD.For_Date AND C.EMP_ID=LD.For_Date)
	--)
	--SELECT * FROM CTE
	--ORDER BY FOR_DATE
	-- OPTION(MAXRECURSION 0)
	
	
	RETURN 

		
		
END


