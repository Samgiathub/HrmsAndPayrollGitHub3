

-- =============================================
-- Author:		<Jaina>
-- Create date: <26-07-2017>
-- Description:	<Canteen In Out Deduction detail>
---12/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P_Get_InOut_Canteen_Deduction]
 @Company_Id   NUMERIC,      
 @FROM_DATE  DATETIME,      
 @TO_DATE  DATETIME ,      
 @BRANCH_ID  NUMERIC ,      
 @CAT_ID   NUMERIC  ,      
 @Grade_ID   NUMERIC ,      
 @TYPE_ID  NUMERIC ,      
 @DEPT_ID  NUMERIC  ,      
 @DESIG_ID  NUMERIC ,      
 @EMP_ID   NUMERIC  ,      
 @CONSTRAINT  VARCHAR(MAX) = '' 
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

	CREATE TABLE #EMP_CONS 
    (      
	   EMP_ID NUMERIC ,     
	   BRANCH_ID NUMERIC,
	   INCREMENT_ID NUMERIC    
	)    
	
    EXEC SP_RPT_FILL_EMP_CONS @Company_Id,@FROM_DATE,@TO_DATE,@BRANCH_ID,@CAT_ID,@Grade_ID,@TYPE_ID,@DEPT_ID,@DESIG_ID,@EMP_ID,@CONSTRAINT,0,0,0,0,0,0,0,0,0,0,0,0   
    
    
    DECLARE @SHIFT_ID			NUMERIC(18,0)
    DECLARE @Shift_St_Time		DATETIME
	DECLARE @Shift_End_Time		DATETIME
	DECLARE @TEMP_DATE			DATETIME
	
   
	
	CREATE TABLE #EMP_Shift
	(
		Emp_Id numeric(18,0),
		Shift_Id numeric(18,0),
		Shift_Name nvarchar(500),
		Shift_time varchar(20),
		For_Date datetime,
		In_time varchar(20),
		Out_time varchar(20),
		Duration varchar(20),
		Shift_In_Time datetime,  --Added by Jaina 28-10-2017
		Shift_Out_Time datetime  --Added by Jaina 28-10-2017
	)
	
	CREATE TABLE #CANTEEN_IO
	(
		ROW_ID numeric,
		Emp_ID numeric,
		For_Date datetime,
		In_time datetime,
		Out_time datetime
	)
	
	CREATE TABLE #Data         
	(         
		Emp_Id   numeric ,         
		For_date DATETIME,        
		Duration_in_sec numeric,        
		Shift_ID numeric ,        
		Shift_Type numeric ,        
		Emp_OT  numeric ,        
		Emp_OT_min_Limit numeric,        
		Emp_OT_max_Limit numeric,        
		P_days  numeric(12,3) default 0,        
		OT_Sec  numeric default 0  ,
		In_Time DATETIME,
		Shift_Start_Time DATETIME,
		OT_Start_Time numeric default 0,
		Shift_Change TINYINT default 0,
		Flag int default 0,
		Weekoff_OT_Sec  numeric default 0,
		Holiday_OT_Sec  numeric default 0,
		Chk_By_Superior numeric default 0,
		IO_Tran_Id	   numeric default 0, -- io_tran_id is used for is_cmp_purpose (t0150_emp_inout)
		OUT_Time DATETIME,
		Shift_END_Time DATETIME,			--Ankit 16112013
		OT_END_Time numeric default 0,	--Ankit 16112013
		Working_Hrs_St_Time TINYINT default 0, --Hardik 14/02/2014
		Working_Hrs_END_Time TINYINT default 0, --Hardik 14/02/2014
		GatePass_Deduct_Days numeric(18,2) default 0 -- Add by Gadriwala Muslim 05012014
	)    
	EXEC P_GET_EMP_INOUT @Company_Id, @FROM_DATE, @TO_DATE
	
	
	DECLARE @First_In_Last_Out_For_InOut_Calculation TINYINT
	
	SET @First_In_Last_Out_For_InOut_Calculation = 0 
	Declare @Is_Column tinyint 
	set @Is_Column = 0
													
	DECLARE Cur_Shift cursor for
		select EMP_ID,BRANCH_ID from #EMP_CONS		
				
	open Cur_Shift
	fetch next from Cur_Shift  into @EMP_ID,@Branch_Id 
	while @@fetch_status = 0
		begin
				--SELECT @First_In_Last_Out_For_InOut_Calculation= ISNULL(First_In_Last_Out_For_InOut_Calculation,0)
				--FROM dbo.T0040_GENERAL_SETTING 
				--WHERE Cmp_ID = @Company_Id and Branch_ID = @Branch_Id 
				--and For_Date = ( SELECT max(For_Date) FROM dbo.T0040_GENERAL_SETTING WHERE For_Date <=@To_Date and Branch_ID = @Branch_Id and Cmp_ID = @Company_Id)
				
				
				
				--IF @First_In_Last_Out_For_InOut_Calculation = 1
				--	insert INTO #EMP_Shift(Emp_Id,Shift_Id,Shift_Name,Shift_time,For_Date,In_time,Out_time,Duration,Shift_In_Time,Shift_Out_Time)						 
				--	SELECT	D.Emp_Id,SM.Shift_ID,SM.Shift_Name,dbo.F_GET_AMPM(sm.Shift_St_Time)+' - ' + dbo.F_GET_AMPM(sm.Shift_End_Time)as Shift_time,
				--		D.For_date,dbo.F_GET_AMPM(D.In_Time),dbo.F_GET_AMPM(D.OUT_Time),
				--		DATEDIFF(Second,d.In_Time,d.Out_Time)as Duration,D.In_Time,D.OUT_Time
				--		--(select sum(Duration_in_sec) from #DATA where Emp_Id=@EMP_ID group BY For_date) AS Duration
				--	FROM	#DATA D 
				--	cross apply (select * from T0040_SHIFT_MASTER sm where sm.Shift_ID=dbo.fn_get_Shift_From_Monthly_Rotation(@Company_Id,D.Emp_ID, D.For_Date)) SM	 						
				--	WHERE	D.EMP_ID=@EMP_ID AND D.FOR_DATE between @From_date AND @To_date 
					
				--ELSE
					
					insert INTO #EMP_Shift(Emp_Id,Shift_Id,Shift_Name,Shift_time,For_Date,In_time,Out_time,Duration,Shift_In_Time,Shift_Out_Time)
					select  eio.Emp_ID,SM.Shift_ID,SM.Shift_Name,dbo.F_GET_AMPM(sm.Shift_St_Time)+' - ' + dbo.F_GET_AMPM(sm.Shift_End_Time)as Shift_time,
						convert(varchar(10),eio.For_Date,110),dbo.F_GET_AMPM(Min(eio.In_Time)) as In_Time,dbo.F_GET_AMPM(max(eio.Out_Time)) as Out_Time,
						0 as Duration,eio.For_Date + SM.Shift_St_Time,
						--eio.For_Date + SM.Shift_End_Time As OutTime
						--case when dbo.F_GET_AMPM(Min(eio.In_Time)) < dbo.F_GET_AMPM(max(eio.Out_Time)) THEN  (eio.For_Date+1)+ SM.Shift_End_Time ELSE eio.For_Date+ SM.Shift_End_Time END as Out_Time
					case when SM.Shift_St_Time > SM.Shift_End_Time THEN  (eio.For_Date+1)+ SM.Shift_End_Time ELSE eio.For_Date+ SM.Shift_End_Time END as Out_Time
					 
					FROM	T0150_EMP_INOUT_RECORD eio WITH (NOLOCK)
					cross apply (select * from T0040_SHIFT_MASTER sm WITH (NOLOCK) where sm.Shift_ID=dbo.fn_get_Shift_From_Monthly_Rotation(eio.Cmp_ID,eio.Emp_ID, eio.For_Date)) SM	 						
					
					WHERE	eio.EMP_ID=@EMP_ID AND eio.FOR_DATE between @From_date AND @To_date 
					group BY  eio.Emp_ID,SM.Shift_ID,SM.Shift_Name,sm.Shift_St_Time,sm.Shift_End_Time
						,eio.For_Date--,eio.In_Time,eio.Out_Time
					
					
					
				--insert INTO #EMP_Shift(Emp_Id,Cmp_Id,Shift_Id,Shift_Name,Shift_time,For_Date,In_time,Out_time,Duration)
				--select  eio.Emp_ID,eio.Cmp_ID,SM.Shift_ID,SM.Shift_Name,dbo.F_GET_AMPM(sm.Shift_St_Time)+' - ' + dbo.F_GET_AMPM(sm.Shift_End_Time)as Shift_time,
				--		convert(varchar(10),eio.For_Date,110),dbo.F_GET_AMPM(eio.In_Time) as In_Time,dbo.F_GET_AMPM(eio.Out_Time) as Out_Time,
				--		DATEDIFF(Second,eio.In_Time,eio.Out_Time)as Duration
				--from T0150_EMP_INOUT_RECORD eio
				--cross apply (select * from T0040_SHIFT_MASTER sm where sm.Shift_ID=dbo.fn_get_Shift_From_Monthly_Rotation(eio.Cmp_ID,eio.Emp_ID, eio.For_Date)) SM
				--where Emp_ID=@EMP_ID and eio.For_Date between @From_date and @To_date
				
			fetch next from Cur_Shift  into @EMP_ID,@Branch_Id
		end
	close Cur_Shift
	deallocate Cur_Shift

	
				  
	UPDATE E SET Duration = isnull(E1.Duration,0)
					from #EMP_Shift E inner JOIN
						#EMP_CONS e2 ON e2.EMP_ID = E.Emp_Id inner JOIN
						( SELECT sum(DATEDIFF(Second,In_Time,Out_Time)) as Duration	,ES.For_Date,es.EMP_ID 
						  FROM T0150_EMP_INOUT_RECORD ES WITH (NOLOCK) inner JOIN
							   #EMP_CONS e2 ON e2.EMP_ID = ES.Emp_Id
						  GROUP BY ES.For_Date,ES.Emp_Id
						) E1 ON e1.For_Date = E.For_Date and E.Emp_Id=e1.Emp_Id

		 
		 				 
	insert INTO #CANTEEN_IO (ROW_ID,Emp_ID,For_Date,In_Time,Out_Time)
	SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY E.Emp_ID,T.IO_DateTime) AS ROW_ID, 
			   E.Emp_ID,CONVERT(datetime,CONVERT(char(10), ES.For_Date, 103), 103) as For_Date ,
			   T.IO_DateTime As In_Time, 
			   CASE WHEN DATEDIFF(N,T.IO_DateTime,T3.IO_DateTime) < 120 THEN T3.IO_DateTime ELSE NULL END AS Out_Time
	FROM T9999_DEVICE_INOUT_DETAIL t WITH (NOLOCK) INNER JOIN
		 T0080_EMP_MASTER E WITH (NOLOCK) ON t.Enroll_No = E.Enroll_No  INNER JOIN
		 #EMP_CONS EC ON EC.EMP_ID = E.Emp_ID inner JOIN
		 #EMP_Shift ES ON t.IO_DateTime between ES.Shift_In_Time AND ES.Shift_Out_Time and ES.Emp_Id=EC.EMP_ID  --Added by Jaina 28-10-2017 (for Night Shift Case)
		 CROSS APPLY(SELECT  Min(t2.IO_DateTime) As IO_DateTime ,E1.Emp_ID
					 FROM    T9999_DEVICE_INOUT_DETAIL T2  WITH (NOLOCK) INNER JOIN
							 T0080_EMP_MASTER E1 WITH (NOLOCK) ON T2.Enroll_No = E1.Enroll_No INNER JOIN
							 #EMP_CONS EC1 ON EC1.EMP_ID = E1.Emp_ID 	
					 WHERE   In_Out_flag='1'  AND T2.IO_DateTime >= t.IO_DateTime AND t.Enroll_No = t2.Enroll_No
							 AND E1.Emp_ID <> 0
							 --AND EC1.EMP_ID = @EMP_ID
					 GROUP BY E1.EMP_ID
					) T3
	WHERE t.In_Out_flag='0' --and T2.Emp_ID=@EMP_ID				
	
	
	
	--declare @Out_time datetime
	--declare @Row_id numeric
	--declare @Canteen_Cnt numeric
	--DECLARE @R_ID NUMERIC
	--DECLARE Cur_Misspunch cursor for
	--	select  Out_time,max(ROW_ID)as Row_ID,Emp_ID from #CANTEEN_IO 
	--	group BY Out_time,Emp_ID
				
	--open Cur_Misspunch
	--fetch next from Cur_Misspunch  into @Out_time,@Row_id,@EMP_ID 
	--while @@fetch_status = 0
	--	begin
	--			select @Canteen_Cnt = COUNT(1) from #CANTEEN_IO 
	--			where Emp_ID =@EMP_ID and Out_time =  @Out_time
	--			group BY Out_time
				
	--			if @Canteen_Cnt > 1
	--			begin		
									
	--					update #CANTEEN_IO SET Out_time = NULL
	--					where Emp_ID =@EMP_ID and ROW_ID = (select  ROW_ID from #CANTEEN_IO 
	--					where Emp_ID =@EMP_ID and Out_time = @Out_time and ROW_ID <> @Row_id)
	--			end				
	--			fetch next from Cur_Misspunch  into @Out_time,@Row_id,@EMP_ID 
	--	end
	--close Cur_Misspunch
	--deallocate Cur_Misspunch
	
		
		
	DECLARE @In_Punch_Cols AS NVARCHAR(MAX)
	DECLARE @Out_Punch_Cols AS NVARCHAR(MAX)
	DECLARE	@query  AS NVARCHAR(MAX)
    declare @C_For_Date as datetime               
	Declare @Cnt_punch numeric(18,0)
	declare @Cnt as numeric = 0
	declare @Column_In varchar(100)
	declare @Column_Out varchar(100)
	declare @Column_Diff varchar(100)
	declare @New_query varchar(max)
	declare @C_diff varchar(max)
	declare @Diff_sum numeric(18,0) = 0
	declare @C_cnt numeric = 0
	declare @Column_cnt numeric
	
	
		
	select distinct @Column_cnt = MAX(total)
	from (
			--select COUNT(1)as total,c.Emp_ID from #CANTEEN_IO c inner JOIN 
			--#EMP_Shift E ON e.Emp_Id=c.Emp_ID and E.For_Date = c.For_Date
			--group BY c.For_Date,c.Emp_ID
			select COUNT(c.For_Date)as total,c.Emp_ID
			from #CANTEEN_IO c LEFT OUTER JOIN 
				 #EMP_Shift E ON e.Emp_Id=c.Emp_ID 
								and c.In_time between E.Shift_In_Time AND E.Shift_Out_Time
								and c.Out_time between E.Shift_In_Time AND E.Shift_Out_Time
			group BY c.For_Date,c.Emp_ID
		  )t
	group BY t.Emp_ID
	
	--select @Column_cnt
	WHILE @CNT < @Column_cnt
	begin
			set @Cnt = @Cnt+1
			set @Column_In = 'Canteen_In_' + cast(@Cnt as varchar) +' '
			set @Column_Out = 'Canteen_Out_' + cast(@Cnt as varchar) +' '
			set @Column_Diff = 'Duration_' + cast(@Cnt as varchar) +' '
			set @query= 'Alter table #EMP_Shift add ' + @Column_In +' varchar(100),'+ @Column_Out + ' varchar(100),'+ @Column_Diff + ' varchar(100)';
			exec (@query)
			
	end		
	alter table #EMP_Shift add Canteen_Total_Duration varchar(20),Actual_Working_Hour varchar(20)
	 
	
	declare Cur_Canteen cursor for
		--select DISTINCT E.Emp_Id,E.For_Date 
		--from T9999_DEVICE_INOUT_DETAIL ID inner JOIN
		-- 	 T0080_EMP_MASTER EM ON EM.Enroll_No = ID.Enroll_No inner JOIN
		--	 #EMP_Shift E ON E.Emp_Id = EM.Emp_ID and For_Date between @From_Date AND @To_date
		
		--select c.Emp_ID,c.For_Date from #CANTEEN_IO c inner JOIN 
		--	#EMP_Shift E ON e.Emp_Id=c.Emp_ID and E.For_Date = c.For_Date
		--	group BY c.For_Date,c.Emp_ID
			select c.Emp_ID,c.For_Date 
			from #CANTEEN_IO c inner JOIN 
				 #EMP_Shift E ON e.Emp_Id=c.Emp_ID 
								and c.In_time between E.Shift_In_Time AND E.Shift_Out_Time
								and (c.Out_time between E.Shift_In_Time AND E.Shift_Out_Time OR c.Out_time IS NULL)
			group BY c.For_Date ,c.Emp_ID
			 
	open Cur_Canteen
	fetch next from Cur_Canteen  into @EMP_ID ,@C_For_Date
	while @@fetch_status = 0
		begin
			set @Cnt_punch = 0
			set @Cnt =0
			set @Diff_sum = 0
			set @C_diff = 0
			
			select @Cnt_punch = MIN(Row_id) from #CANTEEN_IO where For_Date = @C_For_Date and Emp_ID = @EMP_ID
			group BY Emp_ID
			
			select @C_cnt = count(1) from #CANTEEN_IO where For_Date = @C_For_Date and Emp_ID = @EMP_ID
			group BY Emp_ID
			
			--select @C_cnt,@Cnt
			
			--group BY Emp_ID
				
			while @Cnt < @C_cnt
			begin
				set @Cnt = @Cnt+1
				set @Column_In = 'Canteen_In_' + cast(@Cnt as varchar) +' '
				set @Column_Out = 'Canteen_Out_' + cast(@Cnt as varchar) +' '
				set @Column_Diff = 'Duration_' + cast(@Cnt as varchar) +' '
					
	
				declare @tmpQuery varchar(max)
				set @tmpQuery = @Column_In + '=(select dbo.F_GET_AMPM(In_Time)
										from #Canteen_IO 
										where row_id = '+ cast(@Cnt_punch AS varchar) +' and For_Date ='''+ cast(@C_For_Date AS varchar(11)) +''' and Emp_Id = ' + cast(@EMP_ID as varchar) + ' ),'
										+ @Column_Out + '=(select dbo.F_GET_AMPM(Out_Time)
										from #Canteen_IO 
										where row_id = '+ cast(@Cnt_punch AS varchar) +' and For_Date ='''+ cast(@C_For_Date AS varchar(11)) +''' and Emp_Id = ' + cast(@EMP_ID as varchar) + ' ),'
										+ @Column_Diff + '=(select dbo.F_Return_Hours(DATEDIFF(Second,In_Time,Out_Time))
										from #Canteen_IO 
										where row_id = '+ cast(@Cnt_punch AS varchar) +' and For_Date ='''+ cast(@C_For_Date AS varchar(11)) +''' and Emp_Id = ' + cast(@EMP_ID as varchar) + ' )'
										
					
									
					--select @tmpQuery
					
					SET @tmpQuery = 'UPDATE #EMP_Shift 
								SET		' + @tmpQuery + '  
								WHERE	EMP_ID=' + CAST(@EMP_ID AS VARCHAR(10)) + ' 
										AND FOR_DATE=''' + CAST(@C_For_Date AS VARCHAR(11)) + ''''
					EXEC(@tmpQuery)
					
					select @C_diff = DATEDIFF(Second,In_Time,Out_Time)
 					from #Canteen_IO 
					where row_id = cast(@Cnt_punch AS varchar) and For_Date = cast(@C_For_Date AS varchar(11)) and Emp_Id = @EMP_ID 
					
					
					set @Diff_sum = @Diff_sum + isnull(@C_diff,0)
					--select @Diff_sum,@EMP_ID
					set @Cnt_punch = @Cnt_punch + 1
				ENd
				
				--select @EMP_ID,@C_For_Date
				
				update #EMP_Shift SET Canteen_Total_Duration = dbo.F_Return_Hours(@Diff_sum), Actual_Working_Hour = dbo.F_Return_Hours(Duration -  @Diff_sum ),Duration = dbo.F_Return_Hours(Duration)
				where Emp_Id = @EMP_ID and For_Date =  @C_For_Date
								
			fetch next from Cur_Canteen  into @EMP_ID ,@C_For_Date
		end
	close Cur_Canteen
	deallocate Cur_Canteen

	
	ALTER TABLE #EMP_Shift DROP COLUMN Shift_In_Time ,Shift_Out_Time   
	
	--select * from #CANTEEN_IO
	
	select  EM.Alpha_Emp_Code as E_Employee_Code,EM.Emp_Full_Name as E_Employee_Name,B.Branch_Name As E_Branch,D.Dept_Name As E_Department,DS.Desig_Name As E_Designation,G.Grd_Name As E_Grade, 
	ES.*
	into #Canteen_Detail
	from #EMP_Shift ES inner JOIN 
	T0080_EMP_MASTER EM WITH (NOLOCK) on EM.Emp_ID = ES.Emp_Id inner JOIN
	T0095_INCREMENT INC WITH (NOLOCK) on INC.EMP_ID = EM.EMP_ID AND INC.CMP_ID = EM.CMP_ID
		INNER JOIN (
						SELECT	MAX(I2.Increment_ID) AS Increment_ID,I2.Emp_ID,I2.Branch_ID,I2.Dept_ID,I2.Desig_Id,I2.Grd_ID
						FROM	T0095_Increment I2 WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I2.Emp_ID=E.Emp_ID
								INNER JOIN (
												SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
												FROM T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E3 WITH (NOLOCK) ON I3.Emp_ID=E3.Emp_ID	
												WHERE I3.Increment_effective_Date <= @To_Date
												GROUP BY I3.EMP_ID  
											) I3 ON I2.Increment_Effective_Date=I3.Increment_Effective_Date AND I2.EMP_ID=I3.Emp_ID																																			
						GROUP BY I2.Emp_ID,I2.Branch_ID,I2.Dept_ID,I2.Desig_Id,I2.Grd_ID
					) I ON INC.Emp_ID = I.Emp_ID AND INC.Increment_ID = I.Increment_ID inner JOIN
	T0030_BRANCH_MASTER B WITH (NOLOCK) on B.Branch_ID = i.Branch_ID left OUTER JOIN 
	T0040_DEPARTMENT_MASTER D WITH (NOLOCK) ON D.Dept_Id = i.Dept_ID inner JOIN
	T0040_DESIGNATION_MASTER DS WITH (NOLOCK) ON DS.Desig_ID = i.Desig_Id inner JOIN
	T0040_GRADE_MASTER G WITH (NOLOCK) on G.Grd_ID = i.Grd_ID 
	where Es.Actual_Working_Hour is NOT NULL
	order BY  Case When IsNumeric(EM.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + EM.Alpha_Emp_Code, 20)
                        When IsNumeric(EM.Alpha_Emp_Code) = 0 then Left(EM.Alpha_Emp_Code + Replicate('',21), 20)
                        Else EM.Alpha_Emp_Code
                     End,ES.For_Date
	 
	--if not exists (select 1 from #Canteen_Detail)
	--BEGIN
	--	 set @Is_Column = 1
	--END
	
	--IF @Is_Column = 1
	--begin
	--	select E.Alpha_Emp_Code,E.Emp_Full_Name from #EMP_CONS EC inner JOIN
	--	T0080_EMP_MASTER E ON EC.EMP_ID = E.Emp_ID
	--	where E.Cmp_ID=@Company_Id
	--end
	--else
	begin
		;With CTE AS(
		SELECT ROW_NUMBER() OVER(PARTITION BY E_Employee_Name ORDER BY E_Employee_Name) As RowID,
		*
		FROM #Canteen_Detail
		)
		
		SELECT case when RowID =1 then E_Employee_Code else '' end as Employee_Code,
			   case when RowID =1 then E_Employee_Name else '' end as Employee_Name,
			   case when RowID =1 then E_Branch else '' end as Branch,
			   case when RowID =1 then E_Department else '' end as Department,
			   case when RowID =1 then E_DESIGNATION else '' end as DESIGNATION,
			   case when RowID =1 then E_GRADE else '' end as GRADE,
			   CONVERT(varchar(10), For_Date,103) as Date,*
		FROM CTE
		ORDER BY Case When IsNumeric(E_Employee_Code) = 1 then Right(Replicate('0',21) + E_Employee_Code, 20)
							When IsNumeric(E_Employee_Code) = 0 then Left(E_Employee_Code + Replicate('',21), 20)
							Else E_Employee_Code
						 End
	                     
    END

END


