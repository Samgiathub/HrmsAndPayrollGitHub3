
CREATE PROCEDURE [dbo].[RPT_EMP_IN_OUT_ODD_SHIFT]
	 @Cmp_ID 		numeric
	,@From_Date		datetime
	,@To_Date 		datetime
	,@Branch_ID		numeric
	,@Cat_ID 		numeric 
	,@Grd_ID 		numeric
	,@Type_ID 		numeric
	,@Dept_ID 		numeric
	,@Desig_ID 		numeric
	,@Emp_ID 		numeric
	,@constraint 	varchar(max)	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	IF @Branch_ID = 0  
		SET @Branch_ID = null
		
	IF @Cat_ID = 0  
		SET @Cat_ID = null

	IF @Grd_ID = 0  
		SET @Grd_ID = null

	IF @Type_ID = 0  
		SET @Type_ID = null

	IF @Dept_ID = 0  
		SET @Dept_ID = null

	IF @Desig_ID = 0  
		SET @Desig_ID = null

	IF @Emp_ID = 0  
		SET @Emp_ID = null
		
	CREATE TABLE #Emp_Cons
	(
		EMP_ID			NUMERIC,
		INCREMENT_ID	NUMERIC,
		BRANCH_ID		NUMERIC		
	)
	
	IF @Constraint <> ''
		BEGIN
			INSERT INTO #Emp_Cons(Emp_ID,INCREMENT_ID,BRANCH_ID)
			SELECT  I.EMP_ID, I.INCREMENT_ID,I.BRANCH_ID
			FROM	dbo.Split (@Constraint,'#') T 
					INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON CAST(T.DATA AS NUMERIC)=I.EMP_ID
					INNER JOIN (SELECT	MAX(INCREMENT_ID) AS INCREMENT_ID, I1.EMP_ID
								FROM	T0095_INCREMENT I1 WITH (NOLOCK)
										INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I2.EMP_ID
													FROM	T0095_INCREMENT I2 WITH (NOLOCK)
													WHERE	I2.INCREMENT_EFFECTIVE_DATE <= @TO_DATE
													GROUP BY I2.EMP_ID) I2 ON I1.EMP_ID=I2.EMP_ID AND I1.INCREMENT_EFFECTIVE_DATE=I2.INCREMENT_EFFECTIVE_DATE
								GROUP BY I1.EMP_ID) I1 ON I.INCREMENT_ID=I1.INCREMENT_ID
			
		END
	ELSE
		BEGIN
			INSERT INTO #Emp_Cons(Emp_ID,INCREMENT_ID,BRANCH_ID)

			SELECT	I.Emp_Id,I.INCREMENT_ID,I.BRANCH_ID 
			FROM	T0095_Increment I WITH (NOLOCK)
					INNER JOIN (SELECT	MAX(INCREMENT_ID) AS INCREMENT_ID, I1.EMP_ID
								FROM	T0095_INCREMENT I1 WITH (NOLOCK)
										INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I2.EMP_ID
													FROM	T0095_INCREMENT I2 WITH (NOLOCK)
													WHERE	I2.INCREMENT_EFFECTIVE_DATE <= @TO_DATE
													GROUP BY I2.EMP_ID) I2 ON I1.EMP_ID=I2.EMP_ID AND I1.INCREMENT_EFFECTIVE_DATE=I2.INCREMENT_EFFECTIVE_DATE
								GROUP BY I1.EMP_ID) I1 ON I.INCREMENT_ID=I1.INCREMENT_ID
					INNER JOIN (SELECT	DISTINCT EMP_ID 
								FROM	(SELECT emp_id, Cmp_ID, join_Date,ISNULL(left_Date, @To_Date) AS left_Date 
										 FROM	T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) QRY
								WHERE	Cmp_ID = @Cmp_ID AND 
										(
											(@From_Date >= join_Date AND @From_Date <= left_date) 
											OR (@From_Date <= join_Date AND @To_Date >= left_date)	
											OR (@To_Date >= join_Date and @To_Date <= left_date)
											OR left_date IS NULL AND  @To_Date >= Join_Date
										)
						) T ON I.EMP_ID=T.EMP_ID
			WHERE	Cmp_ID = @Cmp_ID 
					AND Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
					AND Branch_ID = isnull(@Branch_ID ,Branch_ID)
					AND Grd_ID = isnull(@Grd_ID ,Grd_ID)
					AND isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
					AND Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
					AND Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
					AND I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 					
		END
	
	
	
	DECLARE  @For_Date datetime 
	DECLARE  @Date_Diff numeric 
	DECLARE  @New_To_Date datetime 
	DECLARE  @Row_ID	numeric 
	
	SET @Date_Diff = datediff(d,@From_Date,@to_DAte) + 1 
	SET @Date_Diff = 35 - ( @Date_Diff)
	SET @New_To_Date = @To_Date --dateadd(d,@date_diff,@To_Date)
	
	CREATE TABLE #Data         
	(         
		Emp_Id				NUMERIC ,         
		For_date			DATETIME,        
		Duration_in_sec		NUMERIC,        
		Shift_ID			NUMERIC,        
		Shift_Type			NUMERIC,        
		Emp_OT				NUMERIC,        
		Emp_OT_min_Limit	NUMERIC,        
		Emp_OT_max_Limit	NUMERIC,        
		P_days				NUMERIC(12,3) DEFAULT 0,        
		OT_Sec				NUMERIC DEFAULT 0,
		In_Time				DATETIME,
		Shift_Start_Time	DATETIME,
		OT_Start_Time		NUMERIC DEFAULT 0,
		Shift_Change		TINYINT DEFAULT 0,
		Flag				INT DEFAULT 0,
		Weekoff_OT_Sec		NUMERIC DEFAULT 0,
		Holiday_OT_Sec		NUMERIC DEFAULT 0,
		Chk_By_Superior		NUMERIC DEFAULT 0,
		IO_Tran_Id			NUMERIC DEFAULT 0, -- io_tran_id is used for is_cmp_purpose (t0150_emp_inout)
		OUT_Time			DATETIME,
		Shift_End_Time		DATETIME,			--Ankit 16112013
		OT_End_Time			NUMERIC DEFAULT 0,	--Ankit 16112013
		Working_Hrs_St_Time TINYINT DEFAULT 0, --Hardik 14/02/2014
		Working_Hrs_End_Time TINYINT DEFAULT 0, --Hardik 14/02/2014
		GatePass_Deduct_Days NUMERIC(18,2) DEFAULT 0 -- Add by Gadriwala Muslim 05012014
    )    
	
	EXEC P_GET_EMP_INOUT @Cmp_ID,@From_Date,@To_Date
	
	CREATE TABLE #Att_Period
	(
		For_Date	DATETIME,
		Row_ID		NUMERIC
	)
	SET @For_Date = @From_Date
	SET @Row_ID = 1
	WHILE @For_Date <= @New_To_Date
		BEGIN
			INSERT INTO #Att_Period 
			SELECT @For_Date ,@Row_ID
			SET @Row_ID =@Row_ID + 1
			SET @for_Date = dateadd(d,1,@for_date)
		END
	
	
	CREATE TABLE #Att_Muster
	(
		Emp_Id		numeric , 
		Cmp_ID		numeric,
		For_Date	datetime,
		Row_ID		numeric ,
		In_Date		datetime,
		Out_Date	Datetime,
		Shift_id	numeric,	
		In_Shift	datetime,
		Hours_Diff  varchar(10),
		N_Shift_Id   numeric,
		N_Shift_name varchar(100),
		N_Shift_In_time varchar(5)
	)
	  

	INSERT	INTO #Att_Muster (Emp_ID,Cmp_ID,For_Date,row_ID)
	SELECT 	Emp_ID ,@Cmp_ID ,For_Date,row_ID 
	FROM	#Att_Period CROSS JOIN #Emp_Cons
	
	
	/*
	Update #Att_Muster
	SET In_Date =In_time
	From #Att_Muster AM inner join 
	( select min(In_Time) In_Time ,Emp_Id,For_Date from T0150_EMP_INOUT_RECORD
		Where Cmp_ID = @cmp_ID and For_Date>=@From_Date and For_Date <=@To_Date
		group by Emp_ID ,for_date 
	)q on Am.Emp_ID =q.emp_ID  and am.for_Date = Q.for_Date

	Update #Att_Muster
	SET Out_Date = OUT_Time
	From #Att_Muster AM inner join 
	( select Max(Out_Time) OUT_Time ,Emp_Id,For_Date from T0150_EMP_INOUT_RECORD
		Where Cmp_ID = @cmp_ID and For_Date>=@From_Date and For_Date <=@To_Date
		group by Emp_ID ,for_date 
	)q on Am.Emp_ID =q.emp_ID  and am.for_Date = Q.for_Date
	*/
	
	UPDATE	A
	SET		In_Date = D.In_Time,
			Out_Date = D.Out_Time
	FROM	#Att_Muster A LEFT OUTER JOIN #DATA D ON A.EMP_ID=D.EMP_ID AND A.FOR_DATE=D.FOR_DATE
	
	--Add by Nimesh 21 April, 2015
	--This sp retrieves the Shift Rotation as per given employee id and effective date.
	--it will fetch all employee's shift rotation detail if employee id is not specified.
	IF (OBJECT_ID('tempdb..#Rotation') IS NULL)
		Create Table #Rotation (R_EmpID numeric(18,0), R_DayName varchar(25), R_ShiftID numeric(18,0), R_Effective_Date DateTime);
	--The #Rotation table gets re-created in dbo.P0050_UNPIVOT_EMP_ROTATION stored procedure
	Exec dbo.P0050_UNPIVOT_EMP_ROTATION @Cmp_ID, NULL, @To_Date, @constraint
	
	
	DECLARE  @Tmp_Date  datetime
	SET @Tmp_Date =@From_Date  

	--Added by ronakk 25042022
	WHILE @Tmp_Date <= @TO_DATE
		BEGIN
			--TAKING DEFAULT SHIFT ID
			UPDATE	#Att_Muster
			SET		Shift_ID=ESD.Shift_ID
			FROM	#Att_Muster ES INNER JOIN T0100_EMP_SHIFT_DETAIL ESD ON ES.EMP_ID=ESD.EMP_ID
					INNER JOIN (SELECT	MAX(FOR_DATE) AS FOR_DATE, EMP_ID 
								FROM	T0100_EMP_SHIFT_DETAIL ESD1 WITH (NOLOCK)
								WHERE	ESD1.For_Date <= @Tmp_Date AND Cmp_ID=@Cmp_ID
								AND ESD1.Shift_Type = 0	--Added By Ramiz on 20/01/2018 as Temporary shift was continuing on next day also.
								GROUP BY EMP_ID
								) ESD1 ON ESD.Emp_ID=ESD1.Emp_ID AND ESD.For_Date=ESD1.FOR_DATE
			WHERE	ES.For_date=@Tmp_Date
			
			--UPDATING SHIFT ID ACCORDING TO GIVEN SHIFT ROTATION
			--IF (@HAS_ROTATION = 1)
				UPDATE	#Att_Muster 
				SET		SHIFT_ID=R_ShiftID
				FROM	#Rotation R 
				WHERE	R.R_EmpID=#Att_Muster.EMP_ID AND R.R_DayName = 'Day' + CAST(DATEPART(d, @Tmp_Date) As Varchar)
						AND R.R_Effective_Date=(
													SELECT	MAX(R_Effective_Date) FROM #Rotation 
													WHERE	R_Effective_Date <=@Tmp_Date
												)
						AND #Att_Muster.For_date = @Tmp_Date
			
			--IF USER HAS ASSIGNED SHIFT ON THAT PARTICULAR DAY THEN IT SHOULD BE TAKEN FIRST
			UPDATE	#Att_Muster SET SHIFT_ID = Shf.Shift_ID
			FROM	#Att_Muster  p 
					INNER JOIN (
								SELECT	ESD.Shift_ID, ESD.Emp_ID 
								FROM	T0100_EMP_SHIFT_DETAIL ESD WITH (NOLOCK)
								WHERE	EXISTS (
											Select	R.R_EmpID FROM #Rotation R
											WHERE	R_DayName = 'Day' + CAST(DATEPART(d, @Tmp_Date) As Varchar) 													
													AND R.R_EmpID=ESD.Emp_ID
											GROUP BY R.R_EmpID
										)
										AND ESD.For_Date=@Tmp_Date
								) Shf ON Shf.Emp_ID = p.EMP_ID
			WHERE	P.FOR_DATE = @Tmp_Date
						
			--if the rotation is not assigned the only those shift should be assigned which shift_type is 1
			UPDATE	#Att_Muster SET SHIFT_ID = Shf.Shift_ID
			FROM	#Att_Muster  p 
					INNER JOIN (
								SELECT	ESD.Shift_ID, ESD.Emp_ID 
								FROM	T0100_EMP_SHIFT_DETAIL ESD WITH (NOLOCK) 
								WHERE	NOT EXISTS (
											Select	R.R_EmpID FROM #Rotation R
											WHERE	R_DayName = 'Day' + CAST(DATEPART(d, @Tmp_Date) As Varchar) 													
													AND R.R_EmpID=ESD.Emp_ID
											GROUP BY R.R_EmpID
										)
										AND ESD.For_Date=@Tmp_Date AND IsNull(ESD.Shift_Type,0)=1
								) Shf ON Shf.Emp_ID = p.EMP_ID
			WHERE	P.FOR_DATE = @Tmp_Date
			
			SET @Tmp_Date = DATEADD(d, 1, @Tmp_Date)
		END
--End by ronakk 25042022




	
--Comment By ronakk 25042022

--while @Tmp_Date <=@To_Date        
--	begin  

--		--Updating Default Shift ID
--		Update #Att_Muster        
--		SET Shift_ID   = Q1.Shift_ID  			
--		from #Att_Muster d inner Join        
--		(select q.Shift_ID ,q.Emp_ID,shift_type,q.For_Date from T0100_Emp_Shift_Detail sd WITH (NOLOCK) inner join        
--		(select for_Date ,Emp_Id,Shift_ID   from T0100_Emp_Shift_Detail    as esdsub WITH (NOLOCK)       
--		where Cmp_Id =@Cmp_ID and shift_Type = 0 and for_Date = (select max(for_Date) from T0100_Emp_Shift_Detail WITH (NOLOCK) where emp_id = esdsub.emp_id and Cmp_Id =@Cmp_ID and shift_Type = 0 and For_Date <= @Tmp_Date ) )q on sd.Emp_ID =q.Emp_ID and sd.For_Date =q.For_Date)q1  on d.emp_ID = q1.emp_ID         
--		Where D.For_Date = @tmp_Date     


--		/*Commented by Nimesh 21 May, 2015
--		Update #Att_Muster        
--		SET Shift_ID   = Q1.Shift_ID
--		from #Att_Muster d inner Join        
--		(select q.Shift_ID ,q.Emp_ID,shift_type,q.For_Date from T0100_Emp_Shift_Detail   sd inner join        
--		(select for_Date ,Emp_Id,Shift_ID   from T0100_Emp_Shift_Detail          as esdsub   
--		where Cmp_Id =@Cmp_ID and shift_Type = 1 and for_Date = (select max(for_Date) from T0100_Emp_Shift_Detail where  emp_id = esdsub.emp_id and Cmp_Id =@Cmp_ID and  shift_Type = 1 and For_Date <= @Tmp_Date ) )q on sd.Emp_ID =q.Emp_ID and sd.For_Date =q.For_Date)q1  on d.emp_ID = q1.emp_ID         
--		Where D.For_Date = @tmp_Date 
--		*/

		

		
--		--Modified by Nimesh 20 May 2015
--		--Updating default shift info From Shift Detail
--		UPDATE	#Att_Muster SET SHIFT_ID = Shf.Shift_ID
--		FROM	#Att_Muster D INNER JOIN (SELECT esd.Shift_ID, esd.Emp_ID, esd.Shift_Type
--		FROM	T0100_EMP_SHIFT_DETAIL esd INNER JOIN  
--				(SELECT MAX(For_Date) AS For_Date,Emp_ID FROM T0100_EMP_SHIFT_DETAIL WITH (NOLOCK)
--					WHERE Cmp_ID = ISNULL(@Cmp_ID,Cmp_ID) AND For_Date <= @Tmp_Date GROUP BY Emp_ID) S ON 
--					esd.Emp_ID = S.Emp_ID AND esd.For_Date=s.For_Date) Shf ON 
--				Shf.Emp_ID = D.EMP_ID 
--		WHERE	D.For_Date=@Tmp_Date
	    

--		--Updating Shift ID From Rotation
--	 UPDATE	#Att_Muster 
--	 SET		SHIFT_ID=SM.SHIFT_ID
--	 FROM	#Rotation R INNER JOIN T0040_SHIFT_MASTER SM ON R.R_ShiftID=SM.Shift_ID					
--	 WHERE	SM.Cmp_ID=@Cmp_ID AND R.R_DayName = 'Day' + CAST(DATEPART(d, @Tmp_Date) As Varchar) AND
--	 		Emp_Id=R.R_EmpID AND R.R_Effective_Date=(SELECT MAX(R_Effective_Date)
--	 			FROM #Rotation R1 WHERE R1.R_EmpID=Emp_Id AND 
--	 				 R_Effective_Date<=@Tmp_Date) 
--	 		AND For_Date=@Tmp_Date
				
		
--		--Updating Shift ID from Employee Shift Detail where ForDate=@TempDate ANd Shift_Type=0 
--		--And Rotation should be assigned to that particular employee
--		UPDATE	#Att_Muster 
--		SET		SHIFT_ID=ESD.SHIFT_ID
--		FROM	#Att_Muster D INNER JOIN (SELECT esd.Shift_ID, esd.Emp_ID, esd.Shift_Type,esd.For_Date
--				FROM T0100_EMP_SHIFT_DETAIL esd WITH (NOLOCK) WHERE Cmp_ID = ISNULL(@Cmp_ID,Cmp_ID) AND For_Date = @Tmp_Date) ESD ON
--				D.Emp_Id=ESD.Emp_ID AND D.For_date=ESD.For_Date				
--		WHERE	ESD.Emp_ID IN (Select R.R_EmpID FROM #Rotation R
--					WHERE R_DayName = 'Day' + CAST(DATEPART(d, @Tmp_Date) As Varchar) AND R_Effective_Date<=@Tmp_Date
--					GROUP BY R.R_EmpID) 
--				AND D.For_date=@Tmp_Date

--		--Updating Shift ID from Employee Shift Detail where ForDate=@TempDate ANd Shift_Type=1 
--		--And Rotation should not be assigned to that particular employee
--		UPDATE	#Att_Muster 
--		SET		SHIFT_ID=ESD.SHIFT_ID
--		FROM	#Att_Muster D INNER JOIN (SELECT esd.Shift_ID, esd.Emp_ID, esd.Shift_Type,esd.For_Date
--				FROM T0100_EMP_SHIFT_DETAIL esd WITH (NOLOCK) WHERE Cmp_ID = ISNULL(@Cmp_ID,Cmp_ID) AND For_Date = @Tmp_Date) ESD ON
--				D.Emp_Id=ESD.Emp_ID AND D.For_date=ESD.For_Date				
--		WHERE	IsNull(ESD.Shift_Type,0)=1 AND ESD.Emp_ID NOT IN (Select R.R_EmpID FROM #Rotation R
--					WHERE R_DayName = 'Day' + CAST(DATEPART(d, @Tmp_Date) As Varchar) AND R_Effective_Date<=@Tmp_Date
--					GROUP BY R.R_EmpID) 
--				AND D.For_date=@Tmp_Date
--		--End Nimesh
		
--		SET @Tmp_Date = dateadd(d,1,@tmp_date)            
--	end 


--End by ronakk 25042022



	   





		
	Update #Att_Muster        
	SET In_Shift = Case when DATEPART(hour,sm.Shift_St_Time)=0 THEN
			cast( dateadd(dd,1,convert( varchar(11),d.For_Date,106)) + ' ' + sm.Shift_St_Time as datetime)
		ELSE
			cast( convert( varchar(11),d.For_Date,106) + ' ' + sm.Shift_St_Time as datetime)
		End
		
	from #Att_Muster d inner Join        
	T0040_SHIFT_MASTER SM on sm.Shift_ID = d.Shift_id 

	--Update #Att_Muster        
	--SET Hours_Diff = dbo.F_Return_Hours(datediff(SECOND,In_Shift,In_Date))
	--from #Att_Muster d inner Join        
	--T0040_SHIFT_MASTER SM on sm.Shift_ID = d.Shift_id 

	Update #Att_Muster        
	SET Hours_Diff = dbo.F_Return_Hours(ABS(datediff(SECOND,In_Shift,In_Date))) --Change by ronakk 24022023 Added ABS function
	from #Att_Muster d inner Join        
	T0040_SHIFT_MASTER SM on sm.Shift_ID = d.Shift_id 


	
	DECLARE  @cur_row_id numeric
	DECLARE  @cur_in_date datetime
	
	DECLARE  @cur_s_id numeric
	DECLARE  @cur_s_name varchar(100)
	DECLARE  @cur_s_in_time varchar(5)
	
	DECLARE  @cur_s_id_min numeric
	DECLARE  @cur_s_name_min varchar(100)
	DECLARE  @cur_s_in_time_min varchar(5)
		
	DECLARE  @cur_s_count numeric
	
	SET @cur_row_id = 0
	SET @cur_s_id = 0
	SET @cur_s_id_min = 0
	
	
	
	DECLARE  curautoshift cursor for	                  
		select row_id,in_date from #Att_Muster where isnull(In_Date,0) <> 0 and dbo.F_Return_Sec(hours_diff) >= 10800
	Open curautoshift                      
		Fetch next from curautoshift into @cur_row_id,@cur_in_date
		While @@fetch_status = 0                    
			Begin     	
				
				DECLARE  @time_in varchar(5)
				SET @time_in = cast(cast(datepart(HOUR,@cur_in_date) as varchar) + ':' + right('00' + cast( datepart(MI,@cur_in_date) as varchar),2) as varchar(5) )
					
				SET @cur_s_count = 0
				---------------------------------------------------	
				DECLARE  curautoshiftinner cursor for	                  
						select shift_id,shift_Name,shift_st_time from T0040_SHIFT_MASTER WITH (NOLOCK) where dbo.F_Return_Sec(Shift_St_Time) >= dbo.F_Return_Sec(@time_in) - 1800 and dbo.F_Return_Sec(Shift_St_Time) <= dbo.F_Return_Sec(@time_in) + 1800 and cmp_id = @Cmp_ID	
				Open curautoshiftinner   
				Fetch next from curautoshiftinner into @cur_s_id,@cur_s_name,@cur_s_in_time
					While @@fetch_status = 0  and @cur_s_count < 5            
						Begin  							   						   
							    if @cur_s_id_min = 0
									Begin
										SET @cur_s_id_min = @cur_s_id
										SET @cur_s_name_min = @cur_s_name
										SET @cur_s_in_time_min = @cur_s_in_time
									End
								Else
									Begin	
										DECLARE  @diff1 numeric 
										DECLARE  @diff2 numeric 
										
										SET @diff1 = abs(dbo.F_Return_Sec(@cur_s_in_time) - dbo.F_Return_Sec(@time_in))
										SET @diff2 = abs(dbo.F_Return_Sec(@cur_s_in_time_min) - dbo.F_Return_Sec(@time_in))
										
										if @diff1 < @diff2
											begin
												SET @cur_s_id_min = @cur_s_id
												SET @cur_s_name_min = @cur_s_name
												SET @cur_s_in_time_min = @cur_s_in_time	
											end
										
									End	
							   
						fetch next from curautoshiftinner into @cur_s_id,@cur_s_name,@cur_s_in_time
					End
				close curautoshiftinner                    
				deallocate curautoshiftinner
				---------------------------------------------------	
				SET @cur_s_count = 	@cur_s_count + 1
				
				update #Att_Muster
				SET N_Shift_Id = @cur_s_id_min , N_Shift_name = @cur_s_name , N_Shift_In_time = @cur_s_in_time where Row_ID = @cur_row_id
				
				fetch next from curautoshift into @cur_row_id,@cur_in_date
			End
	close curautoshift                    
	deallocate curautoshift    
   
		
	Select AM.* , E.Alpha_Emp_Code as Emp_Code,E.Emp_full_Name
		, Branch_Name , Dept_Name ,Grd_Name , Desig_Name,cm.Cmp_Address,cm.Cmp_Name,Q_i.Branch_ID , sm.Shift_Name , @From_Date from_date , @To_Date to_date
	,DGM.Desig_Dis_No  --added jimit 28082015
	,ETM.Type_Name		--added jimit 24092015
	From #Att_Muster  AM Inner join T0080_EMP_MASTER E WITH (NOLOCK) ON AM.EMP_ID = E.EMP_ID
	INNER JOIN ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,I.Type_ID FROM T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_Id) as Increment_Id , Emp_ID From T0095_Increment  WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id	)Q_I ON
		E.EMP_ID = Q_I.EMP_ID INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
		T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
		T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
		T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID  inner join
		T0010_COMPANY_MASTER Cm WITH (NOLOCK) on cm.Cmp_Id = e.Cmp_ID  inner join
		T0040_SHIFT_MASTER SM WITH (NOLOCK) on sm.Shift_ID = AM.Shift_id LEFT OUTER JOIN
		T0040_TYPE_MASTER ETM WITH (NOLOCK) ON Q_I.Type_ID = ETM.Type_ID          
		
		where isnull(In_Date,0) <> 0 and dbo.F_Return_Sec(hours_diff) >= 10800
	Order by Emp_Code,Am.For_Date
	RETURN

