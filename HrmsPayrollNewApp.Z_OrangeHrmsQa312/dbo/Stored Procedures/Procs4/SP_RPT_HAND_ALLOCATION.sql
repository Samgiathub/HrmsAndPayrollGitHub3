

---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_HAND_ALLOCATION]			---\\** CREATED BY RAMIZ **\\---
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
	,@Shift_ID          varchar(100)
	,@constraint 		varchar(MAX)
	,@Report_Type		varchar(20) = 'Default'
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	SET @To_Date = @From_Date;

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
	If @Shift_ID = ''
		set @Shift_ID = null
	If @Cmp_ID = 0
		Set @Cmp_ID = Null
	
	IF @Report_Type = '' OR @Report_Type IS NULL
		SET @Report_Type = 'Default'
		
	CREATE TABLE #Emp_Cons 
	(      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric    
	)   	
	 
	EXEC dbo.SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint
  	
  	
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
	
	CREATE NONCLUSTERED INDEX IX_DATA_EMPID_FORDATE_HA ON #Data (EMP_ID,FOR_DATE) INCLUDE (SHIFT_ID);

	/********************************************************************
	Added by Nimesh : Using new employee weekoff/holiday stored procedure
	*********************************************************************/
	IF OBJECT_ID('tempdb..#Emp_WeekOff') IS NULL
	BEGIN
		
		--WeekOff - by Date : Used in SP_RPT_EMP_ATTENDANCE_MUSTER_GET_ALL
		CREATE TABLE #Emp_WeekOff
		(
			Row_ID			NUMERIC,
			Emp_ID			NUMERIC,
			For_Date		DATETIME,
			Weekoff_day		VARCHAR(10),
			W_Day			numeric(3,1),
			Is_Cancel		BIT
		)
		CREATE CLUSTERED INDEX IX_Emp_WeekOff_EMPID_FORDATE ON #Emp_WeekOff(Emp_ID,For_Date);
		
	END
	/********************************************************************
	Added by Nimesh : End of Declaration
	*********************************************************************/
   
	--Optimized by Nimesh on 18-Jan-2016 [We use #Table (Temp Table) format in place of @Table (Table declaration)]
	CREATE TABLE #PRESENT
	(  
		EMP_ID			NUMERIC,  
		EMP_CODE		varchar(100),  
		EMP_FULL_NAME	VARCHAR(100),  
		IN_TIME			DATETIME,
		OUT_TIME		DATETIME,
		OT_SEC			NUMERIC,  
		STATUS			CHAR(2),
		SHIFT_ID		numeric,
		SHIFT_NAME		VARCHAR(50),
		BRANCH_ID		numeric,
		Branch_Name		varchar(50),
		DEPT_ID			numeric,
		DESIG_ID		Numeric,
		GRD_ID			Numeric,
		TYPE_ID			Numeric,
		Vertical_id		Numeric,
		Subvertical_id	Numeric,
		From_date		Datetime,
		EMP_FIRST_NAME  varchar(100),    --added jimit 20052015		
	)  
	
	CREATE NONCLUSTERED INDEX IX_PRESENT_EMPID_INTIME ON #PRESENT (EMP_ID,IN_TIME) INCLUDE (SHIFT_ID);

	if isnull(@Cmp_ID,0) = 0
		BEGIN
			
			INSERT INTO #PRESENT (EMP_ID,EMP_CODE,EMP_FULL_NAME,BRANCH_ID,Branch_Name,EMP_FIRST_NAME)   
			select	I.Emp_Id,Em.Alpha_Emp_Code,Em.Emp_Full_Name,I.Branch_ID,isnull(j.Branch_Name,''),Em.Emp_First_Name 
			from	dbo.T0095_Increment I WITH (NOLOCK) 
					inner join (
									select	max(i2.Increment_ID) as Increment_ID , i2.Emp_ID 
									from	dbo.T0095_Increment i2 WITH (NOLOCK) inner join #Emp_Cons e on i2.Emp_ID=e.Emp_ID
									where	i2.Increment_Effective_date <= @To_Date and i2.Cmp_ID = Isnull(@Cmp_ID,i2.Cmp_ID)
									group by i2.emp_ID  
								) Qry on  I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID 
					INNER JOIN dbo.T0080_EMP_MASTER Em WITH (NOLOCK) on I.Emp_ID = Em.Emp_ID
					inner join #Emp_Cons ec on ec.Emp_ID = Em.Emp_ID
					inner join T0030_BRANCH_MASTER j WITH (NOLOCK) on i.Branch_ID = j.Branch_ID
					 
			where 
			isNull(I.Type_ID,0) = ISNULL(@Type_ID,ISNULL(I.Type_ID,0)) 
			and isNull(I.Dept_ID,0) = isnull(@Dept_ID ,isnull(I.Dept_ID,0))   
			and isNull(I.Desig_Id,0) = ISNULL(@Desig_ID,ISNULL(I.Desig_Id,0))  
			and isNull(I.Grd_ID,0) = ISNULL(@Grd_ID,ISNULL(I.Grd_ID,0))  
			and isNull(I.Cat_ID,0) = ISNULL(@Cat_ID,ISNULL(I.Cat_ID,0)) 
			and isNull(I.Branch_ID,0) =ISNULL(@Branch_ID,ISNULL(I.Branch_ID,0)) 
			and (em.Emp_Left_Date is null or em.Emp_Left_Date > @From_Date)
			and (em.Date_Of_Join <= @From_Date)
			And i.Cmp_ID in (select Cmp_Id from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1 and is_Main <> 1)
		END
	ELSE
		BEGIN

			INSERT INTO #PRESENT (EMP_ID,EMP_CODE,EMP_FULL_NAME,BRANCH_ID,Branch_Name,EMP_FIRST_NAME)   
			select I.Emp_Id,Em.Alpha_Emp_Code,Em.Emp_Full_Name,I.Branch_ID,isnull(j.Branch_Name,''),Em.Emp_First_Name from dbo.T0095_Increment I WITH (NOLOCK) inner join   
			( select max(i2.Increment_ID) as Increment_ID , i2.Emp_ID from dbo.T0095_Increment i2 WITH (NOLOCK) inner join #Emp_Cons e on i2.Emp_ID=e.Emp_ID
			 where i2.Increment_Effective_date <= @To_Date and i2.Cmp_ID = Isnull(@Cmp_ID,i2.Cmp_ID)
			 group by i2.emp_ID  ) Qry on  
			 I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID INNER JOIN
			dbo.T0080_EMP_MASTER Em WITH (NOLOCK) on I.Emp_ID = Em.Emp_ID
			 inner join #Emp_Cons ec on ec.Emp_ID = Em.Emp_ID
			 inner join T0030_BRANCH_MASTER j WITH (NOLOCK) on i.Branch_ID = j.Branch_ID
			where 
			isNull(I.Type_ID,0) = ISNULL(@Type_ID,ISNULL(I.Type_ID,0)) 
			and isNull(I.Dept_ID,0) = isnull(@Dept_ID ,isnull(I.Dept_ID,0))   
			and isNull(I.Desig_Id,0) = ISNULL(@Desig_ID,ISNULL(I.Desig_Id,0))  
			and isNull(I.Grd_ID,0) = ISNULL(@Grd_ID,ISNULL(I.Grd_ID,0))  
			and isNull(I.Cat_ID,0) = ISNULL(@Cat_ID,ISNULL(I.Cat_ID,0)) 
			and isNull(I.Branch_ID,0) =ISNULL(@Branch_ID,ISNULL(I.Branch_ID,0)) 
			and (em.Emp_Left_Date is null or em.Emp_Left_Date > @From_Date)
			and (em.Date_Of_Join <= @From_Date)
		END
		
	
		DELETE E FROM #Emp_Cons E
		WHERE NOT EXISTS(SELECT 1 FROM #PRESENT P WHERE P.EMP_ID = E.Emp_ID)
		
		EXEC dbo.SP_CALCULATE_PRESENT_DAYS @Cmp_ID=@Cmp_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID=@Branch_ID,@Cat_ID=@Cat_ID,@Grd_ID=@Grd_ID,@Type_ID=@Type_ID,@Dept_ID=@Dept_ID,@Desig_ID=@Desig_ID,@Emp_ID=@Emp_ID,@constraint=@constraint,@Return_Record_set=4

	---------- Modify By Jignesh 10-Dec-2019------------
	/*	
		Update #PRESENT Set IN_TIME = T.In_Time,OUT_TIME = T.Out_Time , STATUS = 'P' From #PRESENT P Inner Join
		T0150_EMP_INOUT_RECORD T on P.EMP_ID = T.Emp_ID And T.For_Date = @From_Date
		Where month(T.in_time)= month(@From_Date)
		and Year(T.in_time) = year(@From_Date) 
		and day(T.in_time)  = day(@From_Date) 
	*/
	
		Update #PRESENT Set IN_TIME = T.In_Time,OUT_TIME = T.Out_Time , STATUS = 'P' From #PRESENT P Inner Join
		#Data T on P.EMP_ID = T.Emp_ID 
		Where T.For_date= @From_Date
	------------- End 10-Dec-2019--------------------

	-------------------------- Get Employees Week Off & Leave Start By Ramiz------------------------------
	
	
		--CREATE TABLE #Emp_Weekoff
		--(
		--	Emp_ID Numeric(18,0)  
		--	,Cmp_ID  Numeric(18,0)  
		--	,For_Date Datetime
		--	,W_Day  Numeric(18,0)  
		--)
			
			CREATE TABLE #Emp_Leave
		(
			Emp_ID Numeric(18,0)  
			,Cmp_ID  Numeric(18,0)  
			,For_Date Datetime
			,L_Day  Numeric(18,0)  
		)
		/*
		Declare @Emp_ID1 numeric

		Declare curweekoff_Leave cursor Fast_forward for	                  
			select Emp_ID from #PRESENT where In_time is not NULL or OUT_time is not NULL
		Open curweekoff_Leave                      
		Fetch next from curweekoff_Leave into @Emp_ID1     
		While @@fetch_status = 0                    
			Begin     
				---- Update Week-off ----
				Exec dbo.SP_EMP_WEEKOFF_DATE_GET @Emp_ID1,@Cmp_Id,@from_date,@to_date,null,null,0,'','',0 ,0 ,1,0,0,''
				
				/*Commented by Nimesh on 18-Nov-2015 (No need to execute query for individual employee id
				---- Update Leave ----
				Insert into #Emp_Leave 
				select l.Emp_ID , l.Cmp_ID , l.For_Date , l.Leave_Used from T0140_LEAVE_TRANSACTION L 
				where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID1 and For_Date = @From_Date and L.Leave_Used = 1		--If Leave taken is 0.5 days then Name should not come in Report
			   */
				fetch next from curweekoff_Leave into @Emp_ID1          
			end                    
		close curweekoff_Leave                    
		deallocate curweekoff_Leave    
		 */

		 
		 --Added by Nimesh on 18-Nov-2015 
		Insert into #Emp_Leave 
		select l.Emp_ID , l.Cmp_ID , l.For_Date , l.Leave_Used from T0140_LEAVE_TRANSACTION L  WITH (NOLOCK)
		where Cmp_ID = @Cmp_ID and For_Date = @From_Date and L.Leave_Used = 1		--If Leave taken is 0.5 days then Name should not come in Report

------------------------ Get Employees Week Off & Leave End By Ramiz -------------------------------
			Update #PRESENT Set STATUS = 'W' From #PRESENT P 
			Inner Join #Emp_Weekoff T on P.EMP_ID = T.Emp_ID AND T.For_Date = @From_Date
			Inner JOIN #Data D ON D.Emp_Id = P.EMP_ID
			
			
			Update #PRESENT Set STATUS = 'L' From #PRESENT P 
			Inner Join #Emp_Leave L on P.EMP_ID = L.Emp_ID AND L.For_Date = @From_Date
			Inner JOIN #Data D ON D.Emp_Id = P.EMP_ID

			Delete #PRESENT From (
			SELECT s.Emp_ID, IN_TIME,
			  row_number() OVER ( PARTITION BY s.Emp_Id order by s.Emp_Id) AS nr
			FROM #PRESENT S) Q Inner Join #PRESENT P on Q.EMP_ID = P.EMP_ID And Q.IN_TIME = P.IN_TIME  
			where q.nr >1 

			Update #PRESENT Set STATUS = 'A' From #PRESENT P
			Where STATUS Is Null And P.IN_TIME Is null

			update #PRESENT set branch_id = inc.Branch_ID , dept_id = Inc.Dept_ID, Desig_Id = Inc.Desig_Id,
			GRD_Id = Inc.Grd_ID , TYPE_ID = Inc.Type_ID , Vertical_id = Inc.Vertical_ID , Subvertical_id = Inc.SubVertical_ID 
			from #PRESENT  p inner join (select Branch_ID	, i.Emp_ID , I.Dept_ID,I.Desig_Id , I.Grd_id , I.TYPE_ID , I.Vertical_id , I.SubVertical_ID			
			From T0095_Increment I WITH (NOLOCK) inner join     
			(select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment	WITH (NOLOCK)	-- Ankit 08092014 for Same Date Increment			
			where Increment_Effective_date <= @To_Date
			and Cmp_ID = Isnull(@Cmp_ID,Cmp_ID)
			group by emp_ID) Qry on
			I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID) Inc on Inc.Emp_ID = p.EMP_ID						
			
			
	
			--Updating Shift ID as per latest shift assigned in shift detail (DEFAULT SHIFT)
			UPDATE	#PRESENT SET SHIFT_ID = Shf.Shift_ID
			FROM	#PRESENT  p INNER JOIN (SELECT esd.Shift_ID, esd.Emp_ID 
					FROM T0100_EMP_SHIFT_DETAIL esd WITH (NOLOCK) INNER JOIN  
						(
							SELECT MAX(For_Date) AS For_Date,Emp_ID FROM T0100_EMP_SHIFT_DETAIL SD WITH (NOLOCK)
							inner join T0040_SHIFT_MASTER SM WITH (NOLOCK) on SD.Shift_ID = SM.Shift_ID and SM.Is_InActive = 0 -- Deepal Added the inner join  18-2-2025
							WHERE SD.Cmp_ID = ISNULL(@Cmp_ID,Sd.Cmp_ID) AND For_Date <= @To_Date GROUP BY Emp_ID
						) S ON 
						esd.Emp_ID = S.Emp_ID AND esd.For_Date=s.For_Date
					) Shf ON Shf.Emp_ID = p.EMP_ID

			--Add by Nimesh 21 April, 2015
			--This sp retrieves the Shift Rotation as per given employee id and effective date.
			--it will fetch all employee's shift rotation detail if employee id is not specified.
			IF (OBJECT_ID('tempdb..#Rotation') IS NULL)
				CREATE TABLE #Rotation (R_EmpID numeric(18,0), R_DayName varchar(25), R_ShiftID numeric(18,0), R_Effective_Date DateTime);
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
			--Retrieve the shift id from employee shift changed detail table
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
										AND ESD.For_Date=@To_Date
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
										AND ESD.For_Date=@To_Date AND IsNull(ESD.Shift_Type,0)=1
								) Shf ON Shf.Emp_ID = p.EMP_ID
		
		--End Nimesh
		
---------New Code of Auto Shift Kept By Ramiz Start on 13042015 ----------------
		
Declare @Emp_ID_AutoShift numeric
Declare @In_Time_Autoshift datetime
Declare @New_Shift_ID numeric
 Declare curautoshift cursor Fast_forward for	                  
	select Emp_ID,In_Time,d.Shift_ID from #PRESENT d inner join T0040_SHIFT_MASTER s WITH (NOLOCK) on d.Shift_ID = s.Shift_ID 
	where Isnull(s.Inc_Auto_Shift,0) = 1 order by In_time,Emp_ID
Open curautoshift                      
	  Fetch next from curautoshift into @Emp_ID_AutoShift,@In_Time_Autoshift,@New_Shift_ID
               
		While @@fetch_status = 0                    
			Begin     
				Declare @Shift_ID_Autoshift numeric
				Declare @Shift_start_time_Autoshift varchar(12)
			
				select top 1 @Shift_ID_Autoshift =  Shift_ID 
				from T0040_SHIFT_MASTER WITH (NOLOCK)
				order by ABS(datediff(s,@In_Time_Autoshift,cast(CONVERT(VARCHAR(11), @In_Time_Autoshift, 121)  + CONVERT(VARCHAR(12), Shift_St_Time, 114) as datetime)))

				 if isnull(@Shift_ID_Autoshift,0) > 0
				 Begin
					update #PRESENT set SHIFT_ID = @Shift_ID_Autoshift from #PRESENT  where Emp_ID=@Emp_ID_AutoShift and In_time=@In_Time_Autoshift 
				 End
			
		fetch next from curautoshift into @Emp_ID_AutoShift,@In_Time_Autoshift,@New_Shift_ID
   end                    
 close curautoshift                    
 deallocate curautoshift    
 ---------New Code of Auto Shift Kept By Ramiz End on 13042015 ----------------  

	 		
--------Commented Code is for Getting the Allocated Shift Name  --------------------------

			--update #PRESENT set SHIFT_ID = Shf.Shift_ID
			--from #PRESENT  p inner join (select esd.Shift_ID, esd.Emp_ID 
			--from T0100_EMP_SHIFT_DETAIL esd inner join  
			--(select MAX(For_Date) as For_Date,Emp_ID from T0100_EMP_SHIFT_DETAIL 
			--where Cmp_ID = Isnull(@Cmp_ID,Cmp_ID) and For_Date <= @To_Date group by Emp_ID) S on 
			--esd.Emp_ID = S.Emp_ID and esd.For_Date=s.For_Date) Shf on 
			--Shf.Emp_ID = p.EMP_ID
			
-------Commented Code is for Getting the Allocated Shift Name  --------------------------
			

		Update #PRESENT set SHIFT_NAME = SM.Shift_name , Branch_Name = BM.Branch_Name , OT_SEC = (D.OT_Sec + D.Weekoff_OT_Sec + D.Holiday_OT_Sec) , From_date = @From_Date from #PRESENT p 
		inner join T0040_SHIFT_MASTER SM on p.SHIFT_ID = SM.Shift_ID
		inner join T0030_BRANCH_MASTER BM on p.BRANCH_ID = BM.Branch_ID
		Inner JOin #data D on P.EMP_ID = D.Emp_ID and P.IN_TIME	= D.In_time

		
		/*
			1) "Default" will Return All In-Out , even with Single Punch
			2) "Present on Leave" will Return only those Employee , who are present on Leave
			3) "Only Overtime" will return only those employee whose OT hours are present
		*/
		
		IF @Report_Type = 'Default' 
			Begin
				If  isnull(@Shift_ID,'') = ''			---For All Shift
							Begin
							select P.*, isnull(DM.Dept_Name,'') as Dept_Name ,isnull(GM.Grd_Name,'') as Grd_Name,isnull(TM.Type_Name,'') as Type_Name,isnull(VS.Vertical_Name,'') as Vertical_Name,isnull(SV.SubVertical_Name,'') as SubVertical_Name,isnull(DGM.Desig_Name,'') as Desig_Name, CM.Cmp_Name , CM.Cmp_Address
							,DGM.Desig_Dis_No,P.EMP_CODE As Alpha_Emp_Code ,p.EMP_FULL_NAME As Emp_Full_Name_Only ,  isnull(dbo.F_Return_Hours(P.OT_Sec),'') as OT_HOURS       --added jimit 2408205 --OT Hours Added By Ramiz on 29/10/2015
							  ,BM.Branch_Address,BM.Comp_Name
							  from #PRESENT as P
								Left Join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on DM.Dept_Id = p.DEPT_ID 
								left Join T0040_GRADE_MASTER GM WITH (NOLOCK) on GM.Grd_ID = p.GRD_ID
								Left Join T0040_TYPE_MASTER TM WITH (NOLOCK) on TM.Type_ID = p.TYPE_ID
								left Join T0040_Vertical_Segment VS WITH (NOLOCK) on VS.Vertical_ID = p.Vertical_id
								left join T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) on DGM.Desig_ID = p.DESIG_ID
								left join T0050_SubVertical SV WITH (NOLOCK) on SV.SubVertical_ID = p.Subvertical_id
								Left Join T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.cmp_id = @cmp_id
								Left Join T0030_BRANCH_MASTER BM WITH (NOLOCK) on BM.Branch_ID = p.Branch_ID
								where STATUS = 'P' or STATUS = 'W' or STATUS = 'L' 
							End
						Else
							Begin							---When Shift is Selected
								select P.* , isnull(DM.Dept_Name,'') as Dept_Name ,isnull(GM.Grd_Name,'') as Grd_Name,isnull(TM.Type_Name,'') as Type_Name,isnull(VS.Vertical_Name,'') as Vertical_Name,isnull(SV.SubVertical_Name,'') as SubVertical_Name,isnull(DGM.Desig_Name,'') as Desig_Name, CM.Cmp_Name , CM.Cmp_Address
								,DGM.Desig_Dis_No , dbo.F_Return_Hours(P.OT_Sec) as OT_HOURS       --added jimit 2408205 --OT Hours Added By Ramiz on 29/10/2015
								,BM.Branch_Address,BM.Comp_Name
								from #PRESENT as P
								Left Join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on DM.Dept_Id = p.DEPT_ID 
								left Join T0040_GRADE_MASTER GM WITH (NOLOCK) on GM.Grd_ID = p.GRD_ID
								Left Join T0040_TYPE_MASTER TM WITH (NOLOCK) on TM.Type_ID = p.TYPE_ID
								left Join T0040_Vertical_Segment VS WITH (NOLOCK) on VS.Vertical_ID = p.Vertical_id
								left join T0050_SubVertical SV WITH (NOLOCK) on SV.SubVertical_ID = p.Subvertical_id
								left join T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) on DGM.Desig_ID = p.DESIG_ID
								Left Join T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.cmp_id = @cmp_id
								Left Join T0030_BRANCH_MASTER BM WITH (NOLOCK) on BM.Branch_ID = p.Branch_ID
								where  --SHIFT_ID = isnull(@Shift_ID,0) 
								EXISTS (SELECT Cast(data As Numeric) FROM dbo.Split(@Shift_ID,'#') T WHERE T.Data <> '' AND P.SHIFT_ID = Cast(T.Data As Numeric))		--Changed By Ramiz on 29/12/2015
								 AND (STATUS = 'P' or STATUS = 'W' or STATUS = 'L')
							End
			End
		Else If @Report_Type = 'Present on Leave'			
			Begin
				If  isnull(@Shift_ID,'') = ''			---For All Shift
					Begin
					select P.* , isnull(DM.Dept_Name,'') as Dept_Name ,isnull(GM.Grd_Name,'') as Grd_Name,isnull(TM.Type_Name,'') as Type_Name,isnull(VS.Vertical_Name,'') as Vertical_Name,isnull(SV.SubVertical_Name,'') as SubVertical_Name,isnull(DGM.Desig_Name,'') as Desig_Name, CM.Cmp_Name , CM.Cmp_Address
					,DGM.Desig_Dis_No , dbo.F_Return_Hours(P.OT_Sec) as OT_HOURS         --added jimit 2408205 --OT Hours Added By Ramiz on 29/10/2015
					 ,BM.Branch_Address,BM.Comp_Name
					 from #PRESENT as P
						Left Join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on DM.Dept_Id = p.DEPT_ID 
						left Join T0040_GRADE_MASTER GM WITH (NOLOCK) on GM.Grd_ID = p.GRD_ID
						Left Join T0040_TYPE_MASTER TM WITH (NOLOCK) on TM.Type_ID = p.TYPE_ID
						left Join T0040_Vertical_Segment VS WITH (NOLOCK) on VS.Vertical_ID = p.Vertical_id
						left join T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) on DGM.Desig_ID = p.DESIG_ID
						left join T0050_SubVertical SV WITH (NOLOCK) on SV.SubVertical_ID = p.Subvertical_id
						Left Join T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.cmp_id = @cmp_id
						Left Join T0030_BRANCH_MASTER BM WITH (NOLOCK) on BM.Branch_ID = p.Branch_ID
						where STATUS = 'L' --or STATUS = 'W' or STATUS = 'P' 
					End
				Else
					Begin							---When Shift is Selected
						select P.* , isnull(DM.Dept_Name,'') as Dept_Name ,isnull(GM.Grd_Name,'') as Grd_Name,isnull(TM.Type_Name,'') as Type_Name,isnull(VS.Vertical_Name,'') as Vertical_Name,isnull(SV.SubVertical_Name,'') as SubVertical_Name,isnull(DGM.Desig_Name,'') as Desig_Name, CM.Cmp_Name , CM.Cmp_Address
						,DGM.Desig_Dis_No , dbo.F_Return_Hours(P.OT_Sec) as OT_HOURS         --added jimit 2408205 --OT Hours Added By Ramiz on 29/10/2015
						 ,BM.Branch_Address,BM.Comp_Name
						 from #PRESENT as P
						Left Join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on DM.Dept_Id = p.DEPT_ID 
						left Join T0040_GRADE_MASTER GM WITH (NOLOCK) on GM.Grd_ID = p.GRD_ID
						Left Join T0040_TYPE_MASTER TM WITH (NOLOCK) on TM.Type_ID = p.TYPE_ID
						left Join T0040_Vertical_Segment VS WITH (NOLOCK) on VS.Vertical_ID = p.Vertical_id
						left join T0050_SubVertical SV WITH (NOLOCK) on SV.SubVertical_ID = p.Subvertical_id
						left join T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) on DGM.Desig_ID = p.DESIG_ID
						Left Join T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.cmp_id = @cmp_id
						Left Join T0030_BRANCH_MASTER BM WITH (NOLOCK) on BM.Branch_ID = p.Branch_ID
						where --SHIFT_ID = isnull(@Shift_ID,0) and 
						EXISTS (SELECT Cast(data As Numeric) FROM dbo.Split(@Shift_ID,'#') T WHERE T.Data <> '' AND P.SHIFT_ID = Cast(T.Data As Numeric)) 	--Changed By Ramiz on 29/12/2015
						AND (STATUS = 'L')
					End
			End
		Else IF @Report_Type = 'Only Overtime' 
			Begin
				If  isnull(@Shift_ID,'') = ''			---For All Shift
							Begin
							select P.*, isnull(DM.Dept_Name,'') as Dept_Name ,isnull(GM.Grd_Name,'') as Grd_Name,isnull(TM.Type_Name,'') as Type_Name,isnull(VS.Vertical_Name,'') as Vertical_Name,isnull(SV.SubVertical_Name,'') as SubVertical_Name,isnull(DGM.Desig_Name,'') as Desig_Name, CM.Cmp_Name , CM.Cmp_Address
							,DGM.Desig_Dis_No,P.EMP_CODE As Alpha_Emp_Code ,p.EMP_FULL_NAME As Emp_Full_Name_Only ,  isnull(dbo.F_Return_Hours(P.OT_Sec),'') as OT_HOURS       --added jimit 2408205 --OT Hours Added By Ramiz on 29/10/2015
							  ,BM.Branch_Address,BM.Comp_Name
							  from #PRESENT as P
								Left Join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on DM.Dept_Id = p.DEPT_ID 
								left Join T0040_GRADE_MASTER GM WITH (NOLOCK) on GM.Grd_ID = p.GRD_ID
								Left Join T0040_TYPE_MASTER TM WITH (NOLOCK) on TM.Type_ID = p.TYPE_ID
								left Join T0040_Vertical_Segment VS WITH (NOLOCK) on VS.Vertical_ID = p.Vertical_id
								left join T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) on DGM.Desig_ID = p.DESIG_ID
								left join T0050_SubVertical SV WITH (NOLOCK) on SV.SubVertical_ID = p.Subvertical_id
								Left Join T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.cmp_id = @cmp_id
								Left Join T0030_BRANCH_MASTER BM WITH (NOLOCK) on BM.Branch_ID = p.Branch_ID
								where (STATUS = 'P' or STATUS = 'W' or STATUS = 'L') And P.OT_SEC > 0
							End
						Else
							Begin							---When Shift is Selected
								select P.* , isnull(DM.Dept_Name,'') as Dept_Name ,isnull(GM.Grd_Name,'') as Grd_Name,isnull(TM.Type_Name,'') as Type_Name,isnull(VS.Vertical_Name,'') as Vertical_Name,isnull(SV.SubVertical_Name,'') as SubVertical_Name,isnull(DGM.Desig_Name,'') as Desig_Name, CM.Cmp_Name , CM.Cmp_Address
								,DGM.Desig_Dis_No , dbo.F_Return_Hours(P.OT_Sec) as OT_HOURS       --added jimit 2408205 --OT Hours Added By Ramiz on 29/10/2015
								 ,BM.Branch_Address,BM.Comp_Name
								from #PRESENT as P
								Left Join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on DM.Dept_Id = p.DEPT_ID 
								left Join T0040_GRADE_MASTER GM WITH (NOLOCK) on GM.Grd_ID = p.GRD_ID
								Left Join T0040_TYPE_MASTER TM WITH (NOLOCK) on TM.Type_ID = p.TYPE_ID
								left Join T0040_Vertical_Segment VS WITH (NOLOCK) on VS.Vertical_ID = p.Vertical_id
								left join T0050_SubVertical SV WITH (NOLOCK) on SV.SubVertical_ID = p.Subvertical_id
								left join T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) on DGM.Desig_ID = p.DESIG_ID
								Left Join T0010_COMPANY_MASTER CM WITH (NOLOCK) on CM.cmp_id = @cmp_id
								Left Join T0030_BRANCH_MASTER BM WITH (NOLOCK) on BM.Branch_ID = p.Branch_ID
								where  --SHIFT_ID = isnull(@Shift_ID,0) 
								EXISTS (SELECT Cast(data As Numeric) FROM dbo.Split(@Shift_ID,'#') T WHERE T.Data <> '' AND P.SHIFT_ID = Cast(T.Data As Numeric))		--Changed By Ramiz on 29/12/2015
								 AND (STATUS = 'P' or STATUS = 'W' or STATUS = 'L')  And P.OT_SEC > 0
							End
			End
		


