CREATE PROCEDURE [dbo].[SP_RPT_DAILY_ATTENDANCE_GET]
	@Cmp_ID 			numeric
	,@From_Date			datetime
	,@To_Date 			datetime 
	,@Branch_ID			numeric
	,@Cat_ID 			numeric 
	,@Grd_ID 			numeric
	,@Type_ID 			numeric
	,@Dept_ID 			numeric
	,@Desig_ID 			numeric
	,@Emp_ID 			numeric
	,@Shift_ID          numeric
	,@constraint 		varchar(MAX)
	,@Format            numeric
	,@PBranch_ID        varchar(200) = '0'
	,@Order_By			varchar(30) = 'Code' --Added by jimit 25092015 (To sort by Code/Name/Enroll No)      
	,@GroupBy			int = 0
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Set @To_Date = @From_Date
	
	IF @Branch_ID = 0  
		Set @Branch_ID = null		
	IF @Cat_ID = 0  
		Set @Cat_ID = null
	IF @Grd_ID = 0  
		Set @Grd_ID = null
	IF @Type_ID = 0  
		Set @Type_ID = null
	IF @Dept_ID = 0  
		Set @Dept_ID = null
	IF @Desig_ID = 0  
		Set @Desig_ID = null
	IF @Emp_ID = 0  
		Set @Emp_ID = null
	If @Shift_ID = 0
		set @Shift_ID = null
	If @Cmp_ID = 0
		Set @Cmp_ID = Null
	
	Declare @Group_BY as varchar(500)
	declare @Group_Name	as varchar(500)
		if @GroupBy = 0
			BEGIN
				set @Group_BY = 'Grade_Name'
				set @Group_Name = 'GRADE'
			END
		else if @GroupBy = 1
			BEGIN
				set @Group_BY = 'Employee_Type_Name'
				set @Group_Name = 'TYPE'
			END
		else if @GroupBy = 2
			BEGIN
				set @Group_BY = 'Dept_Name'
				set @Group_Name = 'DEPARTMENT'
			END
		else if @GroupBy = 3
			BEGIN
				set @Group_BY = 'Desig_Name'
				set @Group_Name = 'DESIGNATION'
			END
		else if @GroupBy = 4
			BEGIN
				set @Group_BY = 'Branch_Name'
				set @Group_Name = 'BRANCH'
			END
		else IF @GroupBy = 5
			begin
				set @Group_BY = 'Vertical_Name'
				set @Group_Name = 'VERTICAL'
			end
		else if @GroupBy = 6
			begin
				set @Group_BY = 'SubVertical_Name'
				set @Group_Name = 'SUBVERTICAL'
			end
		else if @GroupBy = 7
			begin
				set @Group_BY = 'SubBranch_Name'
				set @Group_Name = 'SUBBRANCH'
			END
		else
			BEGIN
				set @Group_BY = ''
				set @Group_Name = ''
			END
		
	CREATE TABLE #Emp_Cons -- Ankit 08092014 for Same Date Increment
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )   	
	 
	 EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0,0,0,0,0,0,0,0,2,@PBranch_ID 

  		
	CREATE TABLE #PRESENT 
	(  
		EMP_ID   NUMERIC,  
		EMP_CODE  varchar(100),  
		EMP_FULL_NAME VARCHAR(100),  
		IN_TIME   DATETIME,  
		STATUS   CHAR(2),
		STATUS_2   CHAR(2),	--Added by Rajput 19072017 For Employee Present ON Week-off
		type     varchar(50),
		Type_Name varchar(100)  ,
		branch_id numeric,
		shift_id numeric,
		dept_id numeric,
		Desig_Id Numeric,
		Vertical_ID Numeric,
		Grade_ID	NUMERIC,
		SubVertical_ID	numeric,
		SubBranch_id	NUMERIC,
		Employee_Type_ID		NUMERIC,
		
		Grade_Name		VARCHAR(500),
		Employee_Type_Name	VARCHAR(500),
		Dept_Name		VARCHAR(500),
		Desig_Name		VARCHAR(500),
		Branch_Name		VARCHAR(500),
		Vertical_Name	VARCHAR(500),
		SubVertical_Name	VARCHAR(500),
		SubBranch_Name	VARCHAR(500),
	)  


	/*Following Query Modified by Nimesh ON 21-Sep-2017 (No need to apply condition for GradeID, BranchID, DesigID, etc. #EmpCons has already filtered employee detail)*/
	if IsNull(@Cmp_ID,0) = 0
		begin
			-- For Appointed Employee, Added by Hardik 13/09/2012
			INSERT	INTO #PRESENT (EMP_ID,EMP_CODE,EMP_FULL_NAME)   
			SELECT	I.Emp_Id,Em.Alpha_Emp_Code,Em.Emp_Full_Name 
			FROM	dbo.T0095_Increment I WITH (NOLOCK)					
					INNER JOIN dbo.T0080_EMP_MASTER Em WITH (NOLOCK) ON I.Emp_ID = Em.Emp_ID
					INNER JOIN #Emp_Cons ec ON ec.Emp_ID = Em.Emp_ID AND I.Increment_ID=EC.Increment_ID
					INNER JOIN T0010_COMPANY_MASTER C WITH (NOLOCK) ON I.Cmp_ID=C.Cmp_Id --AND C.is_GroupOFCmp=1  -- Commeted By Sajid 28-12-2023 Because of Report showing blank		
		END
	ELSE
		BEGIN
			INSERT	INTO #PRESENT (EMP_ID,EMP_CODE,EMP_FULL_NAME)   
			SELECT	I.Emp_Id,Em.Alpha_Emp_Code,Em.Emp_Full_Name 
			FROM	dbo.T0095_Increment I WITH (NOLOCK)					
					INNER JOIN dbo.T0080_EMP_MASTER Em WITH (NOLOCK) ON I.Emp_ID = Em.Emp_ID
					INNER JOIN #Emp_Cons ec ON ec.Emp_ID = Em.Emp_ID AND I.Increment_ID=EC.Increment_ID
					INNER JOIN T0010_COMPANY_MASTER C WITH (NOLOCK) ON I.Cmp_ID=C.Cmp_Id --AND C.is_GroupOFCmp=1  -- Commeted By Sajid 28-12-2023 Because of Report showing blank
		END
	  
	UPDATE	P
	Set		IN_TIME = T.In_Time,
			STATUS = 'P' 
	From	#PRESENT P
			INNER JOIN T0150_EMP_INOUT_RECORD T ON P.EMP_ID = T.Emp_ID AND T.For_Date = @From_Date
	WHERE	MONTH(T.in_time)= MONTH(@From_Date) 
			AND YEAR(T.in_time) = YEAR(@From_Date) 
			AND DAY(T.in_time)  = DAY(@From_Date) 
  

  
	DELETE	#PRESENT 
	From	(SELECT	S.Emp_ID,IN_TIME,ROW_NUMBER() OVER(PARTITION BY S.Emp_Id ORDER BY S.Emp_Id) AS NR
			FROM	#PRESENT S) Q 
			INNER JOIN #PRESENT P ON Q.EMP_ID = P.EMP_ID AND Q.IN_TIME = P.IN_TIME  
	WHERE	Q.NR > 1 


	UPDATE	#PRESENT 
	SET		STATUS = 'L' 
	FROM	#PRESENT P 
			INNER JOIN dbo.T0120_LEAVE_APPROVAL LA ON P.EMP_ID = LA.Emp_ID 
			INNER JOIN dbo.T0130_LEAVE_APPROVAL_DETAIL LAD ON LA.Leave_Approval_ID = LAD.Leave_Approval_ID 
			INNER JOIN dbo.T0040_LEAVE_MASTER LM ON LAD.Leave_ID = LM.Leave_ID 
			LEFT OUTER JOIN dbo.T0150_LEAVE_CANCELLATION As LC ON lad.Leave_Approval_ID =Lc.Leave_Approval_ID 
			INNER JOIN dbo.T0140_LEAVE_TRANSACTION LT ON LT.For_Date = @From_Date AND LAD.Leave_ID = LT.Leave_ID AND LA.Emp_ID = LT.Emp_ID -- added by Gadriwala 28022014( with Approved Hardikbhai)
	WHERE	LAD.From_Date < = @From_Date AND LAD.To_Date >= @From_Date AND LA.Approval_Status='A' 
			AND Leave_Type <> 'Company Purpose' AND isnull(LC.Is_Approve,0)=0 AND STATUS Is null
			AND (Leave_Used > 0 or CompOff_Used > 0 ) -- Changed By Gadriwala Muslim 02102014



	UPDATE	P
	Set		STATUS = 'OD' 
	FROM	#PRESENT P 
			INNER JOIN dbo.T0120_LEAVE_APPROVAL LA ON P.EMP_ID = LA.Emp_ID 
			INNER JOIN dbo.T0130_LEAVE_APPROVAL_DETAIL LAD ON LA.Leave_Approval_ID = LAD.Leave_Approval_ID 
			INNER JOIN dbo.T0040_LEAVE_MASTER LM ON LAD.Leave_ID = LM.Leave_ID 
			LEFT OUTER JOIN dbo.T0150_LEAVE_CANCELLATION As LC ON lad.Leave_Approval_ID =Lc.Leave_Approval_ID
	WHERE	LAD.From_Date < = @From_Date AND LAD.To_Date >= @From_Date AND LA.Approval_Status='A' 
			AND Leave_Type = 'Company Purpose' AND isnull(Is_Approve,0)=0 AND STATUS Is null



	UPDATE	#PRESENT 
	SET		STATUS = 'A' 
	FROM	#PRESENT P
	WHERE	STATUS Is Null AND P.IN_TIME Is null


	/*************************************************************************
	Added by Nimesh: 17/Nov/2015 
	(To get holiday/weekoff data for all employees in seperate table)
	*************************************************************************/
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
				
				EXEC SP_GET_HW_ALL @CONSTRAINT=@CONSTRAINT,@CMP_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@FROM_Date, @All_Weekoff = 0, @Exec_Mode=1	
			END

	UPDATE	P
	Set		STATUS='WO',
			type='<font color="Green">WO</font>'
	FROM	#PRESENT P 
			INNER JOIN #EMP_WEEKOFF W ON P.EMP_ID=W.Emp_ID AND W.For_Date=@FROM_Date
	WHERE	P.EMP_ID = ISNULL(@Emp_ID,P.EMP_ID) AND STATUS = 'A'

	UPDATE	P
	Set		STATUS_2='WO',
			type='<font color="Green">WO</font>'
	FROM	#PRESENT P 
			INNER JOIN #EMP_WEEKOFF W ON P.EMP_ID=W.Emp_ID AND W.For_Date=@FROM_Date
	WHERE	P.EMP_ID = ISNULL(@Emp_ID,P.EMP_ID) AND STATUS = 'P'
  
	UPDATE	P 
	SET		branch_id = I.Branch_ID , dept_id = I.Dept_ID, Desig_Id = I.Desig_Id , Vertical_ID = I.Vertical_ID
	FROM	#PRESENT  P 
			INNER JOIN T0095_INCREMENT I ON P.EMP_ID=I.Emp_ID
			INNER JOIN #Emp_Cons EC ON I.Increment_ID=EC.Increment_ID
			--INNER JOIN (select Branch_ID	, i.Emp_ID , I.Dept_ID,I.Desig_Id , I.Vertical_ID			
			--	FROM T0095_Increment I INNER JOIN     
			--	 ( select max(Increment_ID) as Increment_ID , Emp_ID FROM T0095_Increment		-- Ankit 08092014 for Same Date Increment			
			--	 WHERE Increment_Effective_date <= @To_Date
			--	 AND Cmp_ID = Isnull(@Cmp_ID,Cmp_ID)
			--	 group by emp_ID) Qry ON    
			--	 I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID) Inc ON Inc.Emp_ID = p.EMP_ID
				 	
	--Updating Default Shift ID FROM Employee Shift Change Detail Table.
	UPDATE	P 
	SET		shift_id = Shf.Shift_ID
	FROM	#PRESENT  P 
			INNER JOIN (SELECT	ESD.Shift_ID,ESD.Emp_ID 
						FROM	T0100_EMP_SHIFT_DETAIL esd WITH (NOLOCK)
								INNER JOIN (SELECT	MAX(For_Date) AS For_Date,Emp_ID 
											FROM	T0100_EMP_SHIFT_DETAIL WITH (NOLOCK)
											WHERE	Cmp_ID = Isnull(@Cmp_ID,Cmp_ID) AND For_Date <= @To_Date 
											GROUP BY Emp_ID
											) S ON ESD.Emp_ID = S.Emp_ID AND ESD.For_Date=S.For_Date
						) Shf ON Shf.Emp_ID = P.EMP_ID 
					

	
	--Add by Nimesh 21 April, 2015
	--This sp retrieves the Shift Rotation as per given employee id AND effective date.
	--it will fetch all employee's shift rotation detail if employee id is not specified.
	IF (OBJECT_ID('tempdb..#Rotation') IS NULL)
		Create Table #Rotation (R_EmpID numeric(18,0), R_DayName varchar(25), R_ShiftID numeric(18,0), R_Effective_Date DateTime);
	--The #Rotation table gets re-created in dbo.P0050_UNPIVOT_EMP_ROTATION stored procedure
	Exec dbo.P0050_UNPIVOT_EMP_ROTATION @Cmp_ID, NULL, @To_Date, @constraint
	
	--Updating #PRESENT table for Shift_ID
	UPDATE	#PRESENT SET SHIFT_ID=R_ShiftID
	FROM	#Rotation R 
	WHERE	R.R_EmpID=EMP_ID AND R.R_DayName = 'Day' + CAST(DATEPART(d, @To_Date) As Varchar)
			AND R.R_Effective_Date=(
										SELECT	MAX(R_Effective_Date) FROM #Rotation 
										WHERE	R_Effective_Date <=@To_Date
									)
			
			
	
	--Update Shift ID as per the assigned shift in shift detail 
	--Retrieve the shift id FROM employee shift changed detail table
	UPDATE	#PRESENT SET SHIFT_ID = Shf.Shift_ID
	FROM	#PRESENT  p 
			INNER JOIN (
						SELECT	ESD.Shift_ID, ESD.Emp_ID 
						FROM	T0100_EMP_SHIFT_DETAIL ESD WITH (NOLOCK)
						WHERE	ESD.Emp_ID IN (
									Select	R.R_EmpID FROM #Rotation R
									WHERE	R_DayName = 'Day' + CAST(DATEPART(d, @To_Date) As Varchar) 													
									GROUP BY R.R_EmpID
								)
								AND ESD.For_Date=@To_Date AND ESD.Cmp_ID=@Cmp_ID
						) Shf ON Shf.Emp_ID = p.EMP_ID
				
	--if the rotation is not assigned the only those shift should be assigned which shift_type is 1
	UPDATE	#PRESENT SET SHIFT_ID = Shf.Shift_ID
	FROM	#PRESENT  p 
			INNER JOIN (
						SELECT	ESD.Shift_ID, ESD.Emp_ID 
						FROM	T0100_EMP_SHIFT_DETAIL ESD WITH (NOLOCK)
						WHERE	ESD.Emp_ID NOT IN (
									Select	R.R_EmpID FROM #Rotation R
									WHERE	R_DayName = 'Day' + CAST(DATEPART(d, @To_Date) As Varchar) 													
									GROUP BY R.R_EmpID
								)
								AND ESD.For_Date=@To_Date AND ESD.Cmp_ID=@Cmp_ID AND IsNull(ESD.Shift_Type,0)=1 
						) Shf ON Shf.Emp_ID = p.EMP_ID
	--End Nimesh
					
	--- Added by Hardik 11/04/2014 for Auto Shift				
	Declare @Emp_Id_T Numeric
	Declare @In_Time Datetime
	Declare @New_Shift_Id Numeric
	DECLARE @AUTO_SHIFT_GRPID AS TINYINT   --Added By Jimit 03022018


	Declare curautoshift cursor Fast_forward for	                  
		Select EMP_ID,IN_TIME,P.shift_id FROM #PRESENT P INNER JOIN T0040_SHIFT_MASTER S WITH (NOLOCK) ON P.Shift_id = S.Shift_Id
			WHERE s.Inc_Auto_Shift = 1 AND STATUS = 'P'
	Open curautoshift                      
	  Fetch next FROM curautoshift into @Emp_ID_T,@In_Time,@New_Shift_Id
		While @@fetch_status = 0                    
			Begin     
						SELECT @AUTO_SHIFT_GRPID = ISNULL(Auto_Shift_Group,0) 
						FROM T0040_SHIFT_MASTER WITH (NOLOCK) WHERE SHIFT_ID = @New_Shift_ID

						If Exists(Select 1 FROM T0040_SHIFT_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND 
									DateAdd(ss,-14400,Cast(CAST(@In_Time as varchar(11)) + ' ' + Shift_St_Time as datetime)) <= @In_Time And
									DateAdd(ss,14400,Cast(CAST(@In_Time as varchar(11)) + ' ' + Shift_St_Time as datetime)) >= @In_Time AND Inc_Auto_Shift = 1 AND Auto_Shift_Group = @AUTO_SHIFT_GRPID )
							Begin
								Select @New_Shift_Id = Shift_ID FROM T0040_SHIFT_MASTER WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND 
									DateAdd(ss,-14400,Cast(CAST(@In_Time as varchar(11)) + ' ' + Shift_St_Time as datetime)) <= @In_Time And
									DateAdd(ss,14400,Cast(CAST(@In_Time as varchar(11)) + ' ' + Shift_St_Time as datetime)) >= @In_Time AND Inc_Auto_Shift = 1 AND Auto_Shift_Group = @AUTO_SHIFT_GRPID 
								ORDER BY ABS( DATEDIFF(ss,@In_Time,cast(@In_Time as varchar(11)) + ' ' + Shift_St_Time)) desc 
									
								
								Update #PRESENT Set shift_id = @New_Shift_Id WHERE EMP_ID = @Emp_Id_T AND In_Time = @In_Time
							End

				Fetch next FROM curautoshift into @Emp_ID_T,@In_Time,@New_Shift_Id
			End
			
	Close curautoshift
	Deallocate curautoshift

	--- Added by Hardik 09/12/2019 For Westrock Client as they want Branch Address on Report for Format = 0
	Declare @Branch_Address Varchar(Max)
	Declare @Branch_Cmp_Name Varchar(200)
	Declare @Branch_Count int 
	Set @Branch_Address = ''
	Set @Branch_Cmp_Name = ''

	SELECT @Branch_Address = Isnull(Branch_Address,''), @Branch_Cmp_Name = Isnull(BM.Comp_Name,'')
	FROM #Emp_Cons EC INNER JOIN 
		T0030_BRANCH_MASTER BM WITH (NOLOCK) On EC.Branch_ID = BM.Branch_ID
	GROUP BY Branch_Address, Comp_Name

	Select @Branch_Count = Count(Branch_Address) 
	From (
			SELECT DISTINCT BRANCH_ADDRESS
			FROM #Emp_Cons EC INNER JOIN 
				T0030_BRANCH_MASTER BM WITH (NOLOCK) On EC.Branch_ID = BM.Branch_ID) Qry



	If @Format = 0 
		Begin
			
			Update	P
			SET		P.Grade_ID = isnull(G.Grd_ID,0)
					,P.Grade_Name = isnull(G.Grd_Name,'')
					,P.Employee_Type_ID = isnull(T.Type_ID,0)
					,P.Employee_Type_Name = isnull(T.Type_Name,'')
					,P.dept_id = isnull(D.Dept_Id,0)
					,P.Dept_name = isnull(D.Dept_Name,'')
					,P.Desig_Id = isnull(DE.Desig_ID,0)
					,P.Desig_name = isnull(DE.Desig_Name,'')
					,P.branch_id = isnull(B.Branch_ID,0)
					,P.Branch_name = isnull(B.Branch_Name,'')
					,P.Vertical_ID = isnull(V.Vertical_ID,0)
					,P.Vertical_Name = isnull(V.Vertical_Name,'')
					,P.SubVertical_Id = isnull(VV.SubVertical_ID,0)
					,P.SubVertical_Name = isnull(VV.SubVertical_Name,'')
					,P.SubBranch_id = isnull(SB.SubBranch_ID,0)
					,P.SubBranch_Name = isnull(SB.SubBranch_Name,'')
			from	#PRESENT P
					inner join T0095_INCREMENT I On P.EMP_ID = I.Emp_ID
					INNER JOIN (	
									SELECT	MAX(I.INCREMENT_ID) AS INCREMENT_ID, I.EMP_ID 
									FROM	T0095_INCREMENT I WITH (NOLOCK)
											INNER JOIN (
															SELECT MAX(i3.INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
															FROM T0095_INCREMENT I3 WITH (NOLOCK)
															WHERE I3.Increment_effective_Date <= @From_Date
															GROUP BY I3.EMP_ID  
														) I3 ON I.Increment_Effective_Date=I3.Increment_Effective_Date AND I.EMP_ID=I3.Emp_ID	
									where I.INCREMENT_EFFECTIVE_DATE <= @From_Date and I.Cmp_ID = @Cmp_ID 
									group by I.emp_ID  
								) Qry on	I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID 
					LEFT OUTER JOIN	T0040_GRADE_MASTER G WITH (NOLOCK) on I.Grd_ID = G.Grd_ID
					LEFT OUTER join T0040_TYPE_MASTER T WITH (NOLOCK) on i.Type_ID = T.Type_ID
					LEFT OUTER JOIN	T0040_DEPARTMENT_MASTER D WITH (NOLOCK) on i.Dept_ID = D.Dept_Id
					LEFT OUTER JOIN T0040_DESIGNATION_MASTER DE WITH (NOLOCK) on i.Desig_Id = DE.Desig_ID
					LEFT OUTER join	T0030_BRANCH_MASTER B WITH (NOLOCK) on I.Branch_id = B.Branch_ID
					LEFT OUTER JOIN T0040_Vertical_Segment V WITH (NOLOCK) on I.Vertical_ID = V.Vertical_ID
					left OUTER JOIN T0050_SubVertical VV WITH (NOLOCK) on i.SubVertical_ID = VV.SubVertical_ID
					LEFT OUTER JOIN T0050_SubBranch SB WITH (NOLOCK) on i.subBranch_ID = SB.SubBranch_ID
			
			if @GroupBy BETWEEN 0 and 7
				BEGIN
					declare @qry as NVARCHAR(max)
					set @qry = 'SELECT	DISTINCT		
										sm.Shift_ID 
										,SM.Shift_Name
										,@Group_Name as GroupName
										,p.'+@Group_BY+' as GroupBy
										,Case When @Branch_Count = 1 And @Branch_Address <> '''' Then @Branch_Cmp_Name Else Cm.Cmp_Name End As Comp_Name
										,Case When @Branch_Count = 1 And @Branch_Address <> '''' Then @Branch_Address Else Cm.Cmp_Address End As Comp_Address
										,Cm.Cmp_Name
										,Cm.Cmp_Address
										,@From_Date as From_Date
										,Total.T as Total
										,Total_Present.P as Total_Present
										,Total_Leave.L as Total_Leave
										,Total_OD.O as Total_OD
										,Total_Absent.A as Total_Absent
										,Total_Weekoff.W as Total_Weekoff
								FROM	#PRESENT P
										INNER JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK) on SM.Shift_ID = P.shift_id 
										INNER JOIN T0010_COMPANY_MASTER Cm WITH (NOLOCK) ON isNull(Cm.Cmp_Id,0) = isnull(@Cmp_ID,ISNULL(Cm.Cmp_Id,0)) 
										left outer JOIN(select count(1)as T ,p1.'+@Group_BY+',p1.shift_id FROM #PRESENT p1 Group by p1.'+@Group_BY+',p1.shift_id) as Total on P.'+@Group_BY+' = Total.'+@Group_BY+' and P.shift_id = Total.shift_id
										left outer JOIN(select COUNT(1)as P ,p2.'+@Group_BY+',p2.shift_id FROM #PRESENT p2 WHERE p2.STATUS = ''P'' Group by p2.'+@Group_BY+',p2.shift_id) as Total_Present on P.'+@Group_BY+' = Total_Present.'+@Group_BY+' and P.shift_id = Total_Present.shift_id
										left outer JOIN(select COUNT(1)as L ,p3.'+@Group_BY+',p3.shift_id FROM #PRESENT p3 WHERE p3.STATUS = ''L'' Group by p3.'+@Group_BY+',p3.shift_id) as Total_Leave on P.'+@Group_BY+' = Total_Leave.'+@Group_BY+' and P.shift_id = Total_Leave.shift_id
										left outer JOIN(select COUNT(1)as O ,p4.'+@Group_BY+',p4.shift_id FROM #PRESENT p4 WHERE p4.STATUS = ''OD'' Group by p4.'+@Group_BY+',P4.shift_id) as Total_OD on P.'+@Group_BY+' = Total_OD.'+@Group_BY+' and P.shift_id = Total_OD.shift_id
										left outer JOIN(select COUNT(1)as A ,p5.'+@Group_BY+',p5.shift_id FROM #PRESENT p5 WHERE p5.STATUS = ''A'' Group by p5.'+@Group_BY+',p5.shift_id) as Total_Absent on P.'+@Group_BY+' = Total_Absent.'+@Group_BY+' and P.shift_id = Total_Absent.shift_id
										left outer JOIN(select COUNT(1)as W ,p6.'+@Group_BY+',p6.shift_id FROM #PRESENT p6 WHERE p6.STATUS = ''WO'' Group by p6.'+@Group_BY+',p6.shift_id) as Total_Weekoff on P.'+@Group_BY+' = Total_Weekoff.'+@Group_BY+' and P.shift_id = Total_Weekoff.shift_id
								WHERE	isnull(P.shift_id,0)  = isNull(@Shift_ID,ISNULL(P.Shift_Id,0))' 
				
					print @qry
					EXEC sp_executesql @qry
						, N'@Group_Name varchar(500),@Branch_Count int,@Branch_Address varchar(max),@Branch_Cmp_Name varchar(max),@From_Date datetime,@Cmp_ID int,@Shift_id numeric'
						, @Group_Name = @Group_Name,@Branch_Count = @Branch_Count,@Branch_Address = @Branch_Address,@Branch_Cmp_Name = @Branch_Cmp_Name,@From_Date = @From_Date,@Cmp_ID = @Cmp_ID,@Shift_id = @Shift_id
				END
			else
				begin
					select distinct  sm.Shift_ID ,SM.Shift_Name
						,@Group_Name as GroupName
						,@Group_BY as GroupBy
						,Case When @Branch_Count = 1 And @Branch_Address <> '' Then @Branch_Cmp_Name Else Cm.Cmp_Name End As Comp_Name,
						Case When @Branch_Count = 1 And @Branch_Address <> '' Then @Branch_Address Else Cm.Cmp_Address End As Comp_Address, 
						Cm.Cmp_Name,Cm.Cmp_Address, 
						@From_Date as From_Date,
					( select COUNT(*) FROM #PRESENT p1 WHERE p1.shift_id = SM.Shift_ID )  as Total, 
					( select COUNT(*) FROM #PRESENT p2 WHERE p2.shift_id = SM.Shift_ID AND p2.STATUS = 'P' ) as Total_Present , 
					( select COUNT(*) FROM #PRESENT p3 WHERE p3.shift_id = SM.Shift_ID AND p3.STATUS = 'L' ) as Total_Leave , 
					( select COUNT(*) FROM #PRESENT p4 WHERE p4.shift_id = SM.Shift_ID AND p4.STATUS = 'OD' ) as Total_OD ,
					( select COUNT(*) FROM #PRESENT p5 WHERE p5.shift_id = SM.Shift_ID AND p5.STATUS = 'A' ) as Total_Absent,
					( select COUNT(*) FROM #PRESENT p6 WHERE p6.shift_id = SM.Shift_ID AND p6.STATUS = 'WO' ) as Total_Weekoff,
					-- Added by Divyaraj Kiri on 25/12/2023
					( Select Count(*) from #PRESENT p7 
					INNER JOIN T0080_EMP_MASTER em1 with (NOLOCK) on em1.Emp_ID = p7.EMP_ID 
					AND em1.Gender = 'M' AND p7.shift_id = SM.Shift_ID)  as Total_Male,
					( Select Count(*) from #PRESENT p8 
					INNER JOIN T0080_EMP_MASTER em1 with (NOLOCK) on em1.Emp_ID = p8.EMP_ID 
					AND em1.Gender = 'F' AND p8.shift_id = SM.Shift_ID) as Total_Female
					-- Ended by Divyaraj Kiri on 25/12/2023
					FROM #PRESENT P	INNER JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK) on SM.Shift_ID = P.shift_id 
					INNER JOIN T0010_COMPANY_MASTER Cm WITH (NOLOCK) ON isNull(Cm.Cmp_Id,0) = isnull(@Cmp_ID,ISNULL(Cm.Cmp_Id,0)) 
					WHERE isnull(P.shift_id,0)  = isNull(@Shift_ID,ISNULL(P.Shift_Id,0))
				end
			
		Return
	End

	

	If @Format = 1 or @Format = 5  Or @Format = 3	--@Format = 3(Only Department Wise)	Ankit 25072015
		begin
		 --print 123--mansi
			declare @deptTable table
			(
			dt_Dept_id  numeric,
			dt_Shift_id  numeric,
			dt_Total  numeric,
			dt_Total_Present  numeric,
			dt_Total_Present_On_Weekoff  numeric, --Added by Rajput 190712017
			dt_Total_Leave  numeric,
			dt_total_OD  numeric,
			dt_total_Absent  numeric,
			dt_Total_Weekoff Numeric,
			dt_Selected_Format TinyInt	--Added By Ramiz for Caption Name Dynamic in Crystal Report
			
			)
			
			IF @Format = 3
				BEGIN
				 --   --commented by mansi 28-01-22 start
					--insert into @deptTable (dt_Dept_id,dt_Total,dt_Selected_Format)
					--select distinct P.Dept_Id ,count(p.Emp_id) as Total , @Format FROM #PRESENT P group by P.dept_id
					-- --commented by mansi 28-01-22 end
					 --added by mansi 28-01-22 start
					insert into @deptTable (dt_Dept_id,dt_Total,dt_Selected_Format)
					select distinct P.Dept_Id ,count(p.Emp_id) as Total , @Format FROM #PRESENT P group by P.dept_id
					 --added by mansi 28-01-22 end
					--select distinct P.Dept_Id ,count(p.Emp_id) as Total , @Format,shift_id FROM #PRESENT P group by P.dept_id,p.shift_id--mansi
					--select * from @deptTable--mansi
					
					update @deptTable set 
					dt_Total_Present =P_day
					FROM @deptTable P INNER JOIN 
						(
							Select COUNT(p.emp_id)P_day,dept_id FROM #PRESENT P
							WHERE P.STATUS = 'P' AND ISNULL(P.STATUS_2 , '') = ''
							group by dept_id
						) qry ON P.dt_Dept_id = qry.dept_id 
					WHERE dept_id = qry.dept_id 
					
					update @deptTable set 
					dt_Total_Leave = L_day
					FROM @deptTable P INNER JOIN 
					(Select COUNT(p.emp_id)L_day,dept_id FROM #PRESENT P
					WHERE P.STATUS = 'L' group by dept_id) qry ON P.dt_Dept_id = qry.dept_id 
					WHERE dept_id = qry.dept_id 
					
					update @deptTable set 
					dt_total_OD = OD_day
					FROM @deptTable P INNER JOIN 
					(Select COUNT(p.emp_id)OD_day,dept_id FROM #PRESENT P
					WHERE P.STATUS = 'OD' group by dept_id) qry ON P.dt_Dept_id = qry.dept_id 
					WHERE dept_id = qry.dept_id 
					
					update @deptTable set 
					dt_total_Absent = A_day
					FROM @deptTable P INNER JOIN 
					(Select COUNT(p.emp_id)A_day,dept_id FROM #PRESENT P
					WHERE P.STATUS = 'A' group by dept_id) qry ON P.dt_Dept_id = qry.dept_id 
					WHERE dept_id = qry.dept_id 

					update @deptTable set 
					dt_Total_Weekoff = W_day
					FROM @deptTable P INNER JOIN 
					(Select COUNT(p.emp_id)W_day,dept_id FROM #PRESENT P
					WHERE P.STATUS = 'WO' group by dept_id) qry ON P.dt_Dept_id = qry.dept_id 
					WHERE dept_id = qry.dept_id 
					
					
					update @deptTable set  -- Added by Rajput 19072017
					dt_Total_Present_On_Weekoff =P_day
					FROM @deptTable P INNER JOIN 
					(
						Select COUNT(p.emp_id)P_day,dept_id FROM #PRESENT P
						WHERE P.STATUS = 'P' AND P.STATUS_2 ='WO'  
						group by dept_id
					) qry ON P.dt_Dept_id = qry.dept_id 
					WHERE dept_id = qry.dept_id 
				END
			ELSE
				BEGIN
				--print 111--mansi
				   
					insert into @deptTable (dt_Dept_id,dt_Shift_id,dt_Total,dt_Selected_Format)
					select distinct P.Dept_Id ,P.shift_id,count(p.Emp_id) as Total , @Format FROM #PRESENT P group by P.dept_id,P.shift_id
					
					update @deptTable set 
					dt_Total_Present =P_day
					FROM @deptTable P INNER JOIN 
					(Select COUNT(p.emp_id)P_day,dept_id,shift_id FROM #PRESENT P
					WHERE P.STATUS = 'P' group by dept_id,shift_id) qry ON P.dt_Dept_id = qry.dept_id AND P.dt_Shift_id = qry.shift_id
					WHERE dept_id = qry.dept_id AND shift_id = qry.shift_id
					
					update @deptTable set 
					dt_Total_Leave = L_day
					FROM @deptTable P INNER JOIN 
					(Select COUNT(p.emp_id)L_day,dept_id,shift_id FROM #PRESENT P
					WHERE P.STATUS = 'L' group by dept_id,shift_id) qry ON P.dt_Dept_id = qry.dept_id AND P.dt_Shift_id = qry.shift_id
					WHERE dept_id = qry.dept_id AND shift_id = qry.shift_id
					
					update @deptTable set 
					dt_total_OD = OD_day
					FROM @deptTable P INNER JOIN 
					(Select COUNT(p.emp_id)OD_day,dept_id,shift_id FROM #PRESENT P
					WHERE P.STATUS = 'OD' group by dept_id,shift_id) qry ON P.dt_Dept_id = qry.dept_id AND P.dt_Shift_id = qry.shift_id
					WHERE dept_id = qry.dept_id AND shift_id = qry.shift_id
					
					update @deptTable set 
					dt_total_Absent = A_day
					FROM @deptTable P INNER JOIN 
					(Select COUNT(p.emp_id)A_day,dept_id,shift_id FROM #PRESENT P
					WHERE P.STATUS = 'A' group by dept_id,shift_id) qry ON P.dt_Dept_id = qry.dept_id AND P.dt_Shift_id = qry.shift_id
					WHERE dept_id = qry.dept_id AND shift_id = qry.shift_id

					update @deptTable set 
					dt_Total_Weekoff = W_day
					FROM @deptTable P INNER JOIN 
					(Select COUNT(p.emp_id)W_day,dept_id,shift_id FROM #PRESENT P
					WHERE P.STATUS = 'WO' group by dept_id,shift_id) qry ON P.dt_Dept_id = qry.dept_id AND P.dt_Shift_id = qry.shift_id
					WHERE dept_id = qry.dept_id AND shift_id = qry.shift_id
				END
				
		--End   --Commented by Ramiz as Daily Attendance Report was not generating
		
		If @Format = 5
			Begin
				If exists(select 1 FROM sys.sysobjects WHERE xtype = 'U' AND name like 'dt1')
					drop table dt1
				
				If exists(select 1 FROM sys.sysobjects WHERE xtype = 'U' AND name like 'dt2')
					drop table dt2
				


				select distinct dt.dt_Dept_id,dt.dt_Shift_id,isnull(dt.dt_Total,0) as Total,
					isnull(dt.dt_Total_Present,0) as Total_Present,isnull(dt.dt_Total_Leave,0)as Total_Leave,
					isnull(dt.dt_total_OD,0)as Total_OD ,isnull(dt.dt_total_Absent,0)as Total_Absent,
					isnull(dt.dt_Total_Weekoff,0) as Total_Weekoff
				, dm.Dept_Name ,Cm.Cmp_Name,Cm.Cmp_Address,@From_Date as From_Date,SH.Shift_Name 
				into dt1
				FROM @deptTable dt 
				INNER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON isnull(dm.Dept_id,0) = isnull(dt.dt_Dept_id ,ISNULL(dm.Dept_id,0))
				INNER JOIN T0040_shift_master SH WITH (NOLOCK) ON isnull(SH.Shift_id,0) = isnull(dt.dt_Shift_id,isnull(SH.Shift_id,0))
				INNER JOIN T0010_COMPANY_MASTER Cm WITH (NOLOCK) ON isNull(Cm.Cmp_Id,0) = isnull(@Cmp_ID,ISNULL(Cm.Cmp_Id,0))			
				WHERE  not dt.dt_Dept_id is null AND not dt.dt_Shift_id is  null 
				AND isnull(dt.dt_Dept_id,0) = isnull(@Dept_ID,ISNULL(dt.dt_Dept_id,0)) 
				AND isnull(dt.dt_Shift_id,0) = ISNULL(@Shift_ID,ISNULL(dt.dt_Shift_id,0))
				ORDER BY dt.dt_Shift_id  



			DECLARE @colsPivot AS NVARCHAR(MAX)
			DECLARE	@colsPivot1 AS NVARCHAR(MAX)
			DECLARE	@colsPivot2 AS NVARCHAR(MAX)
			DECLARE	@qry1 as nvarchar(max)

			select @colsPivot = STUFF((SELECT ',' + QUOTENAME(cast(Shift_Name as varchar(max))) 
									FROM dt1 as a
									cross apply ( select 'shift_name' col, 1 so ) c 
									group by col,a.Shift_Name,so 
									ORDER BY so 
							FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')
		
		
			select @colsPivot1 = STUFF((SELECT '' + QUOTENAME(cast(Shift_Name as varchar(max))) + ',0)'+QUOTENAME(cast(Shift_Name as varchar(max)))+',isnull(' 
									FROM dt1 as a
									cross apply ( select 'shift_name' col, 1 so ) c 
									group by col,a.Shift_Name,so 
									ORDER BY so 
							FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')


			set @colsPivot1 =  'isnull([' + @colsPivot1

			set @colsPivot1 = LEFT(@colsPivot1,LEN(@colspivot1)-8) 


			select @colsPivot2 = STUFF((SELECT '' + QUOTENAME(cast(Shift_Name as varchar(max))) + ')'+QUOTENAME(cast(Shift_Name as varchar(max)))+',SUM(' 
									FROM dt1 as a
									cross apply ( select 'shift_name' col, 1 so ) c 
									group by col,a.Shift_Name,so 
									ORDER BY so 
							FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'')

			set @colsPivot2 =  'SUM([' + @colsPivot2

			set @colsPivot2 = LEFT(@colsPivot2,LEN(@colsPivot2)-5) 



			set @qry1 = 'select Dept_Name,dt_dept_id, '+@colsPivot1+' into dt2 
				FROM (select Dept_Name,dt_dept_id,shift_name,Total_Present FROM dt1) 
				as data pivot 
				( sum(Total_Present) 
				for shift_name in ('+ @colspivot +') ) p' 

			exec (@qry1)
			set @qry1 = ''

		
			declare @id_1 as varchar(max) 
			declare @qry2 as varchar(max) 
			declare @id_2 as varchar(max) 
			
			SET @id_1  = ''
			SET @qry2  = ''
			SET @id_2  = ''
			
			declare id_Ren cursor for
			select distinct shift_name FROM dt1
			open id_Ren
			fetch next FROM id_Ren into @id_1
			while @@fetch_status = 0
			begin
			
				set @qry2 = 'dt2.' + @id_1 
				set @id_2 = REPLACE(@id_1,' ','_')


				If @id_1 <> @id_2
				EXEC sp_rename 
					@objname = @qry2, 
					@newname = @id_2, 
					@objtype = 'COLUMN'
				
				fetch next FROM id_Ren into @id_1
			end
			close id_Ren
			deallocate id_Ren


		---added jimit 25092015-----
		
			If (@Order_By = 'Code') 
				SET @Order_By = 'Alpha_Emp_Code'
			ELSE IF (@Order_By = 'Name') 
				SET @Order_By = 'Emp_Full_Name'
			ELSE IF (@Order_By = 'Designation')
				SET @Order_By = 'Desig_Dis_No'
			--ELSE IF (@Order_By = '') 
			--	SET @Order_By = 'F.Emp_ID'

          select * FROM dt2
          
          
			set @qry1 = '
			
			select '' '' +  dept_name as Department,dt1.Total as Actual_Strenght, ' + Replace(@colsPivot,' ','_') + ',Total_Leave as On_Leave, Total_OD as On_OD,Total_Weekoff as On_Weekoff, Total_Absent as Absent
			 FROM dt2 INNER JOIN 
			(select dt_Dept_id,SUM(Total) as Total,sum(Total_Leave) as Total_Leave,sum(Total_OD) as Total_OD,
				sum(total_Weekoff) as Total_Weekoff,sum(total_Absent) as total_Absent FROM dt1 group by dt_Dept_id) as dt1 ON dt1.dt_dept_id = dt2.dt_dept_id
				union
				select ''Total--->'' as Dept_Name,sum(dt1.Total) Total, ' + Replace(@colsPivot2,' ','_') + ',sum(Total_Leave)Total_Leave, sum(Total_OD) Total_OD,sum(Total_Weekoff) Total_Weekoff, sum(Total_Absent) Total_Absent FROM dt2 INNER JOIN 
			(select dt_Dept_id,SUM(Total) as Total,sum(Total_Leave) as Total_Leave,sum(Total_OD) as Total_OD,
				sum(total_Weekoff) as Total_Weekoff,sum(total_Absent) as total_Absent FROM dt1 group by dt_Dept_id) as dt1 ON dt1.dt_dept_id = dt2.dt_dept_id'
			--	INNER JOIN 
			--(select Row_Number() OVER(ORDER BY ' + @Order_By + ') As Row_No, T.emp_id as empid FROM 
			--	(Select Emp_ID,Desig_ID FROM  #PRESENT Group By Emp_ID,Desig_ID) T INNER JOIN T0080_EMP_MASTER E ON T.Emp_ID=E.Emp_ID LEFT OUTER JOIN T0040_Designation_Master DD ON DD.Desig_Id = T.Desig_ID) RID ON RID.empid=Q.Emp_ID
			--ORDER BY RID.Row_No'

			--print @qry1	
			
			
			exec (@qry1)
		End
	Else
		Begin
		
			If @Format = 3	-- Get Record only Department Ankit 25072015
				begin
					select distinct dt.dt_Dept_id,dt.dt_Shift_id,isnull(dt.dt_Total,0) as Total,
						isnull(dt.dt_Total_Present,0) as Total_Present,isnull(dt.dt_Total_Present_On_Weekoff,0) as Total_Present_On_Weekoff,isnull(dt.dt_Total_Leave,0)as Total_Leave,
						isnull(dt.dt_total_OD,0)as Total_OD ,isnull(dt.dt_total_Absent,0)as Total_Absent,
						isnull(dt.dt_Total_Weekoff,0) as Total_Weekoff
						, dm.Dept_Name ,Cm.Cmp_Name,Cm.Cmp_Address,@From_Date as From_Date , 
						Cmp_Name As Shift_Name,--commneted by mansi
						--Shift_Name As Shift_Name,--added by mansi
						dt.dt_Selected_Format as Format 
					FROM @deptTable dt 
					INNER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON isnull(dm.Dept_id,0) = isnull(dt.dt_Dept_id ,ISNULL(dm.Dept_id,0))
					LEFT OUTER JOIN T0040_shift_master SH ON isnull(SH.Shift_id,0) = isnull(dt.dt_Shift_id,isnull(SH.Shift_id,0))--added by mansi
					INNER JOIN T0010_COMPANY_MASTER Cm WITH (NOLOCK) ON isNull(Cm.Cmp_Id,0) = isnull(@Cmp_ID,ISNULL(Cm.Cmp_Id,0)) 	
					WHERE  not dt.dt_Dept_id is null --AND not dt.dt_Shift_id is  null 
					AND isnull(dt.dt_Dept_id,0) = isnull(@Dept_ID,ISNULL(dt.dt_Dept_id,0)) 
					AND isnull(dt.dt_Shift_id,0) = ISNULL(@Shift_ID,ISNULL(dt.dt_Shift_id,0))
					ORDER BY dm.Dept_Name
				end
				
			Else If @Format <> 2
				BEGIN
					select distinct dt.dt_Dept_id,dt.dt_Shift_id,isnull(dt.dt_Total,0) as Total,
						isnull(dt.dt_Total_Present,0) as Total_Present,isnull(dt.dt_Total_Leave,0)as Total_Leave,
						isnull(dt.dt_total_OD,0)as Total_OD ,isnull(dt.dt_total_Absent,0)as Total_Absent,
						isnull(dt.dt_Total_Weekoff,0) as Total_Weekoff
					, dm.Dept_Name ,Cm.Cmp_Name,Cm.Cmp_Address,@From_Date as From_Date,SH.Shift_Name 
					FROM @deptTable dt 
					INNER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON isnull(dm.Dept_id,0) = isnull(dt.dt_Dept_id ,ISNULL(dm.Dept_id,0))
					INNER JOIN T0040_shift_master SH WITH (NOLOCK) ON isnull(SH.Shift_id,0) = isnull(dt.dt_Shift_id,isnull(SH.Shift_id,0))
					INNER JOIN T0010_COMPANY_MASTER Cm WITH (NOLOCK) ON isNull(Cm.Cmp_Id,0) = isnull(@Cmp_ID,ISNULL(Cm.Cmp_Id,0)) 	
					WHERE  not dt.dt_Dept_id is null AND not dt.dt_Shift_id is  null 
					AND isnull(dt.dt_Dept_id,0) = isnull(@Dept_ID,ISNULL(dt.dt_Dept_id,0)) 
					AND isnull(dt.dt_Shift_id,0) = ISNULL(@Shift_ID,ISNULL(dt.dt_Shift_id,0))
					ORDER BY dt.dt_Shift_id 
				END	 
		End

		--RETURN 
		
		End   ---Added by Ramiz for daily Attendance report not generating Departmentwise
If @Format = 2 
		begin
		
			declare @CrossDEPTDesig table
			(
			dt_Dept_id  numeric,
			dt_Desig_Id Numeric,
			dt_Shift_id  numeric,
			dt_Total  numeric,
			dt_Total_Present  numeric
			--dt_Total_Leave  numeric,
			--dt_total_OD  numeric,
			--dt_total_Absent  numeric,
			--dt_Total_Weekoff Numeric
			)
			
			
			insert into @CrossDEPTDesig (dt_Dept_id,dt_Desig_Id,dt_Shift_id,dt_Total)
			select distinct P.Dept_Id ,p.Desig_Id,P.shift_id,count(p.Emp_id) as Total FROM #PRESENT P group by P.dept_id,P.Desig_Id,P.shift_id
			
			update @CrossDEPTDesig set 
			dt_Total_Present =P_day
			FROM @CrossDEPTDesig P INNER JOIN 
			(Select COUNT(p.emp_id)P_day,dept_id,Desig_Id,shift_id FROM #PRESENT P
			WHERE P.STATUS = 'P' group by dept_id,Desig_Id,shift_id) qry ON P.dt_Dept_id = qry.dept_id AND p.dt_Desig_Id =qry.Desig_Id AND  P.dt_Shift_id = qry.shift_id
			WHERE dept_id = qry.dept_id AND shift_id = qry.shift_id AND Desig_Id = qry.Desig_Id
			
			--update @CrossDEPTDesig set 
			--dt_Total_Leave = L_day
			--FROM @deptTable P INNER JOIN 
			--(Select COUNT(p.emp_id)L_day,dept_id,shift_id FROM #PRESENT P
			--WHERE P.STATUS = 'L' group by dept_id,shift_id) qry ON P.dt_Dept_id = qry.dept_id AND P.dt_Shift_id = qry.shift_id
			--WHERE dept_id = qry.dept_id AND shift_id = qry.shift_id
			
			--update @CrossDEPTDesig set 
			--dt_total_OD = OD_day
			--FROM @deptTable P INNER JOIN 
			--(Select COUNT(p.emp_id)OD_day,dept_id,shift_id FROM #PRESENT P
			--WHERE P.STATUS = 'OD' group by dept_id,shift_id) qry ON P.dt_Dept_id = qry.dept_id AND P.dt_Shift_id = qry.shift_id
			--WHERE dept_id = qry.dept_id AND shift_id = qry.shift_id
			
			--update @CrossDEPTDesig set 
			--dt_total_Absent = A_day
			--FROM @deptTable P INNER JOIN 
			--(Select COUNT(p.emp_id)A_day,dept_id,shift_id FROM #PRESENT P
			--WHERE P.STATUS = 'A' group by dept_id,shift_id) qry ON P.dt_Dept_id = qry.dept_id AND P.dt_Shift_id = qry.shift_id
			--WHERE dept_id = qry.dept_id AND shift_id = qry.shift_id
			
			--update @CrossDEPTDesig set 
			--dt_total_Absent = W_day
			--FROM @deptTable P INNER JOIN 
			--(Select COUNT(p.emp_id)W_day,dept_id,shift_id FROM #PRESENT P
			--WHERE P.STATUS = 'WO' group by dept_id,shift_id) qry ON P.dt_Dept_id = qry.dept_id AND P.dt_Shift_id = qry.shift_id
			--WHERE dept_id = qry.dept_id AND shift_id = qry.shift_id
			
			--RANK ( ) OVER ( [ partition_by_clause ] order_by_clause )
			
			select distinct 
			DENSE_RANK () OVER  ( PARTITION BY dt.dt_Shift_id ORDER BY dt.dt_Dept_id) as Rank_id,
			dt.dt_Dept_id,dt.dt_Desig_Id,dt.dt_Shift_id,isnull(dt.dt_Total,0) as 'Appointed',
				isnull(dt.dt_Total_Present,0) as 'Presented' --,isnull(dt.dt_Total_Leave,0)as Total_Leave,
				--isnull(dt.dt_total_OD,0)as Total_OD ,isnull(dt.dt_total_Absent,0)as Total_Absent,
				--isnull(dt.dt_Total_Weekoff,0) as Total_Weekoff
			--, dm.Dept_Name ,Cm.Cmp_Name,Cm.Cmp_Address,@From_Date as From_Date,SH.Shift_Name,DSM.Desig_Name 
			, dm.Dept_Name ,Cm.Cmp_Name,Cm.Cmp_Address,@From_Date as From_Date,SH.Shift_Name + ' FROM ' + Sh.Shift_St_Time + ' To ' + sh.Shift_End_Time as Shift_Name  ,DSM.Desig_Name,DSM.Desig_dis_No,DM.Dept_dis_no 
			FROM @CrossDEPTDesig dt 
			INNER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON isnull(dm.Dept_id,0) = isnull(dt.dt_Dept_id ,ISNULL(dm.Dept_id,0))
			INNER JOIN T0040_shift_master SH WITH (NOLOCK) ON isnull(SH.Shift_id,0) = isnull(dt.dt_Shift_id,isnull(SH.Shift_id,0))
			INNER JOIN T0010_COMPANY_MASTER Cm WITH (NOLOCK) ON isNull(Cm.Cmp_Id,0) = isnull(@Cmp_ID,ISNULL(Cm.Cmp_Id,0)) 	
			INNER JOIN T0040_DESIGNATION_MASTER DSM WITH (NOLOCK) ON  isnull(DSM.Desig_ID,0) = isnull(dt.dt_Desig_Id,isnull(DSM.Desig_ID,0))
			WHERE  not dt.dt_Dept_id is null AND not dt.dt_Shift_id is  null 
			AND not dt.dt_Desig_Id is  null 
			AND isnull(dt.dt_Dept_id,0) = isnull(@Dept_ID,ISNULL(dt.dt_Dept_id,0)) 
			AND isnull(dt.dt_Shift_id,0) = ISNULL(@Shift_ID,ISNULL(dt.dt_Shift_id,0))
			AND isnull(dt.dt_Desig_Id,0) = ISNULL(@Desig_ID,ISNULL(dt.dt_Desig_Id,0))
			ORDER BY dt.dt_Shift_id,dt_Dept_id,dt_Desig_Id  

		RETURN 
		
	End

IF @Format = 4  --New Format of Vertical wise Daily Attendance is Added By Ramiz ON 28/08/2016
	BEGIN
		Declare @Vertical_ID_Table table
			(
			dt_Vertical_id  numeric,
			dt_Shift_id  numeric,
			dt_Total  numeric,
			dt_Total_Present  numeric,
			dt_Total_Leave  numeric,
			dt_total_OD  numeric,
			dt_total_Absent  numeric,
			dt_Total_Weekoff Numeric,
			dt_Selected_Format TinyInt
			)

			----commented by mansi start
			--insert into @Vertical_ID_Table (dt_Vertical_id,dt_Total,dt_Selected_Format)
			--select distinct P.Vertical_ID ,count(p.Emp_id) as Total,@Format FROM #PRESENT P group by P.Vertical_ID
			----commented by mansi end
			--added by mansi start
			insert into @Vertical_ID_Table (dt_Vertical_id,dt_Total,dt_Selected_Format,dt_Shift_id)
			select distinct P.Vertical_ID ,count(p.Emp_id) as Total,@Format,shift_id FROM #PRESENT P group by P.Vertical_ID,p.shift_id
				--added by mansi end
			update @Vertical_ID_Table 
			set dt_Total_Present = P_day
			FROM @Vertical_ID_Table V INNER JOIN 
			(
				Select COUNT(p.emp_id)P_day,P.Vertical_ID FROM #PRESENT P
				WHERE P.STATUS = 'P' group by P.Vertical_ID
			) qry ON V.dt_Vertical_id = qry.Vertical_ID
			WHERE qry.Vertical_ID = qry.Vertical_ID 
			
			update @Vertical_ID_Table 
			set dt_Total_Leave = L_day
			FROM @Vertical_ID_Table V INNER JOIN 
			(
				Select COUNT(p.emp_id)L_day,P.Vertical_ID FROM #PRESENT P
				WHERE P.STATUS = 'L' group by P.Vertical_ID
			) qry ON V.dt_Vertical_id = qry.Vertical_ID 
			WHERE qry.Vertical_ID = qry.Vertical_ID 
			
			update @Vertical_ID_Table 
			set dt_total_OD = OD_day
			FROM @Vertical_ID_Table V INNER JOIN 
			(
				Select COUNT(p.emp_id)OD_day,P.Vertical_ID FROM #PRESENT P
				WHERE P.STATUS = 'OD' group by P.Vertical_ID
			) qry ON V.dt_Vertical_id = qry.Vertical_ID 
			WHERE qry.Vertical_ID = qry.Vertical_ID 
			
			update @Vertical_ID_Table 
			set dt_total_Absent = A_day
			FROM @Vertical_ID_Table V INNER JOIN 
			(
				Select COUNT(p.emp_id)A_day,P.Vertical_ID FROM #PRESENT P
				WHERE P.STATUS = 'A' group by P.Vertical_ID
			) qry ON V.dt_Vertical_id = qry.Vertical_ID
			WHERE qry.Vertical_ID = qry.Vertical_ID 

			update @Vertical_ID_Table 
			set dt_Total_Weekoff = W_day
			FROM @Vertical_ID_Table V INNER JOIN 
			(
				Select COUNT(p.emp_id)W_day,P.Vertical_ID FROM #PRESENT P
				WHERE P.STATUS = 'WO' group by P.Vertical_ID
			) qry ON V.dt_Vertical_id = qry.Vertical_ID 
			WHERE qry.Vertical_ID = qry.Vertical_ID 
		
			select distinct dt.dt_Vertical_id as dt_dept_ID,VS.Vertical_Name as Dept_Name , --(Here Vertical ID AND Vertical Name are Provided an Alias of Department , as I have used the Same Report of Department Daily Attendance , Plz dont Change this)
			dt.dt_Shift_id,isnull(dt.dt_Total,0) as Total,isnull(dt.dt_Total_Present,0) as Total_Present,
			isnull(dt.dt_Total_Leave,0)as Total_Leave,isnull(dt.dt_total_OD,0)as Total_OD ,
			isnull(dt.dt_total_Absent,0)as Total_Absent,isnull(dt.dt_Total_Weekoff,0) as Total_Weekoff,
			Cm.Cmp_Name,Cm.Cmp_Address,@From_Date as From_Date , 
			--Cmp_Name As Shift_Name , --commented by mansi
			sh.Shift_Name as Shift_Name,--added by mansi
			dt.dt_Selected_Format as  Format
			FROM @Vertical_ID_Table dt 
			INNER JOIN T0040_Vertical_Segment VS WITH (NOLOCK) ON isnull(vs.Vertical_ID,0) = isnull(dt.dt_Vertical_id,isnull(vs.Vertical_ID,0))
			INNER JOIN T0010_COMPANY_MASTER Cm WITH (NOLOCK) ON isNull(Cm.Cmp_Id,0) = isnull(@Cmp_ID,ISNULL(Cm.Cmp_Id,0)) 
			LEFT OUTER JOIN T0040_shift_master SH ON isnull(SH.Shift_id,0) = isnull(dt.dt_Shift_id,isnull(SH.Shift_id,0))--added by mansi
			WHERE  not dt.dt_Vertical_id is null 
			AND isnull(dt.dt_Shift_id,0) = ISNULL(@Shift_ID,ISNULL(dt.dt_Shift_id,0))
			ORDER BY vs.Vertical_Name
	END

	If @Format = 22		--(Changed FROM 4 to 22 , as it is Conflicting with other Report)
		Begin
			declare @deptTable1 table
			(
			dt_Dept_id  numeric,
			dt_Total  numeric,
			dt_Total_Present  numeric,
			dt_Total_Leave  numeric,
			dt_total_OD  numeric,
			dt_total_Absent  numeric,
			dt_Total_Weekoff numeric,
			dt_Selected_Format TinyInt
			)
			
			insert into @deptTable1 (dt_Dept_id,dt_Total)
			select distinct P.Dept_Id ,count(p.Emp_id) as Total FROM #PRESENT P group by P.dept_id


			--- Added By Hardik ON 28/08/2012 for Delete Main Company Data AND Blank Department Records
			--If @Cmp_ID Is Null
			--	Begin 
			--		Delete @deptTable1 WHERE dt_Dept_id In (
			--		Select dt_Dept_id FROM @deptTable1 dt LEFT OUTER JOIN 
			--			T0040_DEPARTMENT_MASTER dm ON dt.dt_Dept_id = dm.Dept_Id INNER JOIN
			--			T0010_COMPANY_MASTER cm ON dm.Cmp_Id = cm.Cmp_Id WHERE is_Main = 1 or is_GroupOFCmp = 0)
					
			--		Delete @deptTable1 WHERE dt_Dept_id is null
			--	End


			update @deptTable1 set 
			dt_Total_Present =P_day
			FROM @deptTable1 P INNER JOIN 
			(Select COUNT(p.emp_id)P_day,dept_id FROM #PRESENT P
			WHERE P.STATUS = 'P' group by dept_id) qry ON P.dt_Dept_id = qry.dept_id 

			update @deptTable1 set 
			dt_Total_Leave = L_day
			FROM @deptTable1 P INNER JOIN 
			(Select COUNT(p.emp_id)L_day,dept_id FROM #PRESENT P
			WHERE P.STATUS = 'L' group by dept_id) qry ON P.dt_Dept_id = qry.dept_id
			--WHERE dept_id = qry.dept_id 
			
			update @deptTable1 set 
			dt_total_OD = OD_day
			FROM @deptTable1 P INNER JOIN 
			(Select COUNT(p.emp_id)OD_day,dept_id FROM #PRESENT P
			WHERE P.STATUS = 'OD' group by dept_id) qry ON P.dt_Dept_id = qry.dept_id
			--WHERE dept_id = qry.dept_id 
			
			update @deptTable1 set 
			dt_total_Absent = A_day
			FROM @deptTable1 P INNER JOIN 
			(Select COUNT(p.emp_id)A_day,dept_id FROM #PRESENT P
			WHERE P.STATUS = 'A' group by dept_id) qry ON Isnull(P.dt_Dept_id,0) = Isnull(qry.dept_id,0)
			--WHERE dept_id = qry.dept_id 
			
			
			
			update @deptTable1 set 
			dt_Total_Weekoff = W_day
			FROM @deptTable1 P INNER JOIN 
			(Select COUNT(p.emp_id)W_day,dept_id FROM #PRESENT P
			WHERE P.STATUS = 'WO' group by dept_id) qry ON P.dt_Dept_id = qry.dept_id 
			--WHERE dept_id = qry.dept_id


				
			Select dm.Dept_Name,  sum(isnull(dt.dt_Total,0)) as Total
				, Sum(isnull(dt.dt_Total_Present,0)) as Total_Present,
				Sum(isnull(dt.dt_Total_Leave,0))as Total_Leave, Sum(isnull(dt.dt_total_OD,0))as Total_OD,
				Sum(isnull(dt.dt_total_Absent,0))as Total_Absent,Sum(isnull(dt.dt_Total_Weekoff,0))as Total_Weekoff
			,@From_Date as From_Date 
			FROM @deptTable1 dt 
				LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON dt.dt_Dept_id = dm.Dept_id
			--WHERE  isnull(dt.dt_Dept_id,0) = isnull(@Dept_ID,ISNULL(dt.dt_Dept_id,0)) 
			Group by dm.Dept_Name
			ORDER BY Dept_Name
		
		Return
	End
	
	If @Format = 33
		Begin
		
			select distinct 
			p.EMP_ID ,
			P.EMP_FULL_NAME, DM.Dept_Name, SM.Shift_Name ,Cm.Cmp_Name,Cm.Cmp_Address,
				@From_Date as From_Date, Status,DDM.Desig_Name
			FROM #PRESENT P	INNER JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK)
				on SM.Shift_ID = P.Shift_id 
				INNER JOIN T0040_Department_Master DM WITH (NOLOCK) ON P.Dept_Id = DM.Dept_Id
				INNER JOIN T0080_Emp_Master EM WITH (NOLOCK) ON P.EMP_ID = EM.Emp_Id
				INNER JOIN T0010_COMPANY_MASTER Cm WITH (NOLOCK) ON Cm.Cmp_Id  = Em.Cmp_Id
				INNER JOIN T0040_Designation_Master DDm WITH (NOLOCK) ON P.Desig_Id = DDm.Desig_Id
			WHERE STATUS='P'
			ORDER BY DM.Dept_Name,Cm.Cmp_Name
		
		Return
		end
