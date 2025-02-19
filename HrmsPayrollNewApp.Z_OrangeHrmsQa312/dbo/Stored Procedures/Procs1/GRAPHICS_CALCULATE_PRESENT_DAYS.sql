CREATE PROCEDURE [dbo].[GRAPHICS_CALCULATE_PRESENT_DAYS]       
  @Cmp_ID				numeric        
 ,@From_Date			datetime        
 ,@To_Date				datetime         
 ,@Branch_ID			numeric        
 ,@Cat_ID				numeric         
 ,@Grd_ID				numeric        
 ,@Type_ID				numeric        
 ,@Dept_ID				numeric        
 ,@Desig_ID				numeric        
 ,@Emp_ID				numeric        
 ,@constraint			varchar(max)        
 ,@Return_Record_set	numeric =1        
 ,@Branch_Constraint	varchar(max) = ''
 ,@Department_Constraint varchar(max) = ''  --Added By Jaina 09-08-2016
 ,@Vertical_Constraint varchar(max) = ''    --Added By Jaina 09-08-2016
 ,@SubVertical_Contraint varchar(max) = ''   --Added By Jaina 09-08-2016
 ,@Segment_Id			numeric =null
AS        
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON 

           
Declare @Count   numeric         
Declare @Tmp_Date datetime         
        
set @Tmp_Date = @From_Date        

--Added By Jaina 09-08-2016 Start	
	IF 	@Branch_Constraint = ''
		set @Branch_Constraint = NULL
	
	IF @Vertical_Constraint = ''
		set @Vertical_Constraint = NULL
		
	IF @SubVertical_Contraint = ''
		set @SubVertical_Contraint = NULL
	
	IF @Department_Constraint = ''
		set @Department_Constraint = NULL
		
	if @Branch_Constraint is null
	Begin	
		select   @Branch_Constraint = COALESCE(@Branch_Constraint + '#', '') + cast(Branch_ID as nvarchar(5))  from T0030_BRANCH_MASTER where Cmp_ID=@Cmp_ID 
		set @Branch_Constraint = @Branch_Constraint + '#0'
	End
	
	if @Vertical_Constraint is null
	Begin	
		select   @Vertical_Constraint = COALESCE(@Vertical_Constraint + '#', '') + cast(Vertical_ID as nvarchar(5))  from T0040_Vertical_Segment where Cmp_ID=@Cmp_ID 
		
		If @Vertical_Constraint IS NULL
			set @Vertical_Constraint = '0';
		else
			set @Vertical_Constraint = @Vertical_Constraint + '#0'		
	End
	if @SubVertical_Contraint is null
	Begin	
		select   @SubVertical_Contraint = COALESCE(@SubVertical_Contraint + '#', '') + cast(subVertical_ID as nvarchar(5))  from T0050_SubVertical where Cmp_ID=@Cmp_ID 
		
		If @SubVertical_Contraint IS NULL
			set @SubVertical_Contraint = '0';
		else
			set @SubVertical_Contraint = @SubVertical_Contraint + '#0'
	End
	IF @Department_Constraint is null
	Begin
		select   @Department_Constraint = COALESCE(@Department_Constraint + '#', '') + cast(Dept_ID as nvarchar(5))  from T0040_DEPARTMENT_MASTER where Cmp_ID=@Cmp_ID 		
		
		if @Department_Constraint is null
			set @Department_Constraint = '0';
		else
			set @Department_Constraint = @Department_Constraint + '#0'
	End
	--Added By Jaina 09-08-2016 End
	        
IF @Return_Record_set = 1 or @Return_Record_set = 2 or @Return_Record_set =3         
	Begin        
		CREATE table #Data         
		(         
			Emp_Id				numeric ,         
			For_date			datetime,        
			Duration_in_sec		numeric,        
			Shift_ID			numeric ,        
			Shift_Type			numeric ,        
			Emp_OT				numeric ,        
			Emp_OT_min_Limit	numeric,        
			Emp_OT_max_Limit	numeric,        
			P_days				numeric(12,1) default 0,        
			OT_Sec				numeric default 0
		)        
	END        
        
IF @Branch_ID = 0          
  SET @Branch_ID = null        
          
IF @Cat_ID = 0          
  SET @Cat_ID = null        
        
IF @Grd_ID = 0          
  SET @Grd_ID = null        
        
IF @Type_ID = 0          
  set @Type_ID = null        
        
IF @Dept_ID = 0          
  set @Dept_ID = null        
        
IF @Desig_ID = 0          
  set @Desig_ID = null        
        
IF @Emp_ID = 0          
  set @Emp_ID = null        

 IF @Segment_Id = 0 
	SET @Segment_Id = NULL
          
CREATE TABLE #Emp_Cons 
	 (      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric
	 )             
         
--IF @Constraint <> ''        
--	BEGIN        
--		INSERT	INTO #Emp_Cons(Emp_ID)        
--		SELECT CAST(DATA  AS NUMERIC) 
--		FROM	dbo.Split (@Constraint,'#')         
--	END
--ELSE        
--	BEGIN  
		EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0 ,0 ,@Segment_Id,0,0,0,0,0,0,0,0,0
		DECLARE @Constraint_EMP_ID VARCHAR(MAX)

		SELECT @Constraint_EMP_ID = COALESCE(@Constraint_EMP_ID + '#', '')  + CAST(Emp_ID AS VARCHAR(100)) 
		FROM #Emp_Cons


		 CREATE TABLE #Emp_Table
		 (        		
			 id       int identity,
			 Present Numeric,
			 Absent  Numeric                 
		 )

		--- Added by Hardik 17/08/2020 for Gartech client as Emp Present days showing different from Attendance Register, So take this code from Below side to above and put ruture for Records_Set = 3
		CREATE TABLE #Emp_Table_Detail
		 (        		
			 id       int identity,
			 Emp_Id	Numeric,
			 Present Numeric,
			 Absent  Numeric                 
		 )		
		 
		 --- Added by Hardik 17/08/2020 for Gartech client as Emp Present days showing different from Attendance Register, So take this code from Below side to above and put ruture for Records_Set = 3
		IF @Return_Record_set='3'	
			BEGIN
					CREATE table #Att_Muster_Excel 
					  (	
							Emp_Id		numeric , 
							Cmp_ID		numeric,
							For_Date	datetime,
							Status		varchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS,
							Leave_Count	numeric(5,2),
							WO_HO		varchar(3) COLLATE SQL_Latin1_General_CP1_CI_AS,
							Status_2	varchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
							Row_ID		numeric ,
							WO_HO_Day	numeric(3,2) default 0,
							P_days		numeric(5,2) default 0,
							A_days		numeric(5,2) default 0 ,
							Join_Date	Datetime default null,
							Left_Date	Datetime default null,
							Gate_Pass_Days numeric(18,2) default 0, 
							Late_Deduct_Days numeric(18,2) default 0, 
							Early_Deduct_Days numeric(18,2) default 0, 
							Emp_code    varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
							Emp_Full_Name  varchar(300) COLLATE SQL_Latin1_General_CP1_CI_AS,
							Branch_Address varchar(300) COLLATE SQL_Latin1_General_CP1_CI_AS,
							comp_name varchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS,
							Branch_Name varchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS,
							Dept_Name  varchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS,
							Grd_Name varchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS,
							Desig_Name varchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS,
							P_From_date  datetime,
							P_To_Date datetime,
							BRANCH_ID numeric(18,0),
							Desig_Dis_No numeric(18,2) default 0 ,
							SUBBRANCH_NAME VARCHAR(200) DEFAULT '' COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS      
					  )
	  
	  	  
				CREATE NONCLUSTERED INDEX IX_Data ON dbo.#Att_Muster_Excel
							(	Emp_Id,Emp_code,Row_ID ) 
					
					
				--SELECT  @Constraint_EMP_ID  
				exec SP_RPT_EMP_ATTENDANCE_MUSTER_GET @Cmp_Id,@From_Date,@To_Date,@Branch_ID,
															  @Cat_ID,@Grd_Id,@Type_ID,@Dept_ID,@Desig_ID,
															  @Emp_ID,@Constraint_EMP_ID,'','EXCEL'
						
						--select * from #Att_Muster_Excel

						 insert into #Emp_Table(Present,Absent)		 
						 select  --Sum(CASt(Status as Numeric(18,4))),0
						 CASE WHEN P_days>0 THEN COUNT(P_days) else 0 END,0
						 From	 #Att_Muster_Excel 
						 where   Row_Id = 32 
						 Group By P_days--,Emp_Id
	     
						insert into #Emp_Table_Detail(Emp_Id,Present,Absent)		 
						 select  Emp_Id,--Sum(CASt(Status as Numeric(18,4))),0,
						 CASE WHEN P_days>0 THEN COUNT(P_days) else 0 END,0
						 From	 #Att_Muster_Excel 
						 where   Row_Id = 32 
						 Group By P_days,Emp_Id							
						
						update	ET
						SET		Absent = Q.A_Days
						from	#Emp_Table ET
								Inner JOin 
										( 
												select  Sum(CASt(Status as Numeric(18,4))) A_Days
												FROM	#Att_Muster_Excel
												where	Row_Id = 33 
												group By A_Days
										)Q on 1=1
						update	ET
						SET		Present = Q.P_Days
						from	#Emp_Table ET
								Inner JOin 
										( 
												select  Sum(CASt(Status as Numeric(18,4))) P_Days
												FROM	#Att_Muster_Excel
												where	Row_Id = 33 
												group By P_Days
										)Q on 1=1

						update	ET
						SET		Absent = Q.A_Days
						from	#Emp_Table_Detail ET
								Inner JOin 
										( 
												select  Emp_Id, Sum(CASt(Status as Numeric(18,4))) A_Days
												FROM	#Att_Muster_Excel
												where	Row_Id = 33 
												group By A_Days,Emp_Id
										)Q on Q.Emp_Id = ET.Emp_Id

						update	ET
						SET		Present = Q.P_Days
						from	#Emp_Table_Detail ET
								Inner JOin 
										( 
												select  Emp_Id, Sum(CASt(Status as Numeric(18,4))) P_Days
												FROM	#Att_Muster_Excel
												where	Row_Id = 33 
												group By P_Days,Emp_Id
										)Q on Q.Emp_Id = ET.Emp_Id
						

				  
				Select * from (
				select OA1.Emp_ID,@From_Date as For_Date,E1.Emp_Full_Name,Present as P_days ,Absent as A_Days,31 as Total ,E1.Alpha_Emp_Code ,BM.Branch_Name, Alpha_Code,Emp_code
				From #Emp_Table_Detail  OA1 inner join T0080_emp_master E1 WITH (NOLOCK) on OA1.Emp_ID = E1.Emp_ID   
						LEFT JOIN  T0030_BRANCH_MASTER BM WITH (NOLOCK) ON E1.Branch_ID = BM.Branch_ID        --add emp code and branch by chetan 15-12-16
				Group by OA1.emp_ID,E1.Emp_Full_Name , Present,Absent,E1.Alpha_Emp_Code  ,BM.Branch_Name, Alpha_Code,Emp_code
				) Qry 
				Order by Alpha_Code,Emp_code

				select * from #Emp_Table

				return		
			END


	INSERT INTO #Data (Emp_ID,For_Date,Duration_In_sec,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit)        
	SELECT	eir.Emp_ID ,for_Date,sum(isnull(datediff(s,in_time,out_time),0)) ,isnull(Emp_OT,0),dbo.F_Return_Sec(Emp_OT_min_Limit),dbo.F_Return_Sec(Emp_OT_max_Limit)        
	FROM	T0150_emp_inout_Record  EIR WITH (NOLOCK) Inner join #Emp_Cons Ec on EIR.Emp_Id = ec.Emp_ID 
			INNER JOIN (
						SELECT	I.Emp_ID,Emp_OT,isnull(Emp_OT_min_Limit,'00:00')Emp_OT_min_Limit,isnull(Emp_OT_max_Limit,'00:00')Emp_OT_max_Limit, I.Branch_ID 
								,I.Dept_ID,I.Vertical_ID,I.SubVertical_ID  --Added By Jaina 09-08-2016 
						FROM	T0095_Increment  I WITH (NOLOCK) INNER JOIN (
									SELECT	MAX(Increment_Id)Increment_Id ,Emp_ID 
									FROM	T0095_Increment WITH (NOLOCK)         
									WHERE	increment_effective_Date <=@To_Date AND Cmp_ID =@Cmp_ID 
									GROUP BY Emp_ID
								)q ON I.emp_ID =q.Emp_ID AND I.Increment_Id = q.Increment_Id
						) IQ ON eir.Emp_ID =iq.emp_ID        
	WHERE	cmp_Id= @Cmp_ID and for_Date >=@From_Date and For_Date <=@To_Date        			
		--Added By Jaina 09-08-2016 Start
		and EXISTS (select Data from dbo.Split(@Branch_Constraint, '#') B Where cast(B.data as numeric)=Isnull(IQ.Branch_ID,0))
		and EXISTS (select Data from dbo.Split(@Vertical_Constraint, '#') VE Where cast(VE.data as numeric)=Isnull(IQ.Vertical_ID,0))
		and EXISTS (select Data from dbo.Split(@SubVertical_Contraint, '#') S Where cast(S.data as numeric)=Isnull(IQ.SubVertical_ID,0))
		and EXISTS (select Data from dbo.Split(@Department_Constraint, '#') D Where cast(D.data as numeric)=Isnull(IQ.Dept_ID,0))    		          			
		--Added By Jaina 09-08-2016 End
	GROUP BY eir.Emp_ID  ,eir.For_Date,Emp_OT,Emp_OT_min_Limit,Emp_OT_max_Limit  
   
   	--Add by Nimesh 25 May, 2015
	--This sp retrieves the Shift Rotation as per given employee id and effective date.
	--it will fetch all employee's shift rotation detail if employee id is not specified.
	IF (OBJECT_ID('tempdb..#Rotation') IS NULL)
		Create Table #Rotation (R_EmpID numeric(18,0), R_DayName varchar(25), R_ShiftID numeric(18,0), R_Effective_Date DateTime);
	--The #Rotation table gets re-created in dbo.P0050_UNPIVOT_EMP_ROTATION stored procedure
	Exec dbo.P0050_UNPIVOT_EMP_ROTATION @Cmp_ID, NULL, @To_Date, @constraint

           
    set @Tmp_Date =@From_Date        
	while @Tmp_Date <=@To_Date        
		begin  
			--Updating Default Shift ID from the latest employee shift detail      
			UPDATE	#Data        
			SET		Shift_ID   = Q1.Shift_ID,          
					Shift_Type = q1.Shift_type       
			FROM	#Data d 
					INNER JOIN (
								SELECT	sd.shift_ID ,sd.Emp_ID,shift_type,sd.For_Date 
								FROM	T0100_Emp_Shift_Detail  sd WITH (NOLOCK)
										INNER JOIN (
													SELECT	MAX(for_Date) for_Date ,Emp_Id,Shift_ID   
													FROM	T0100_Emp_Shift_Detail   WITH (NOLOCK)      
													WHERE	Cmp_Id =@Cmp_ID and shift_Type = 0 
															AND for_Date <=@Tmp_Date 
													GROUP BY Emp_ID ,Shift_Id
													)q on sd.Emp_ID =q.Emp_ID 
										AND sd.For_Date =q.For_Date
								)Q1 ON d.emp_ID = q1.emp_ID         
			WHERE	D.For_Date = @tmp_Date         
           
           /*Commented by Nimesh 25-May-2015
			  Update #Data        
				set Shift_ID   = Q1.Shift_ID,          
			  Shift_Type = q1.Shift_type        
			  from #Data d inner Join        
				(select sd.shift_ID ,sd.Emp_ID,shift_type,sd.For_Date from T0100_Emp_Shift_Detail   sd inner join        
				(select MaX(for_Date) for_Date ,Emp_Id,Shift_ID   from T0100_Emp_Shift_Detail        
				where Cmp_Id =@Cmp_ID and shift_Type = 1 and for_Date =@Tmp_Date group by Emp_ID ,Shift_Id)q on sd.Emp_ID =q.Emp_ID and sd.For_Date =q.For_Date)q1  on d.emp_ID = q1.emp_ID         
			   Where D.For_Date = @tmp_Date         
			*/
        
			
			--Added by Nimesh 22 April, 2015
			--Updating Shift ID From Rotation
			UPDATE	#Data 
			SET		SHIFT_ID=SM.SHIFT_ID,Shift_Type=0
			FROM	#Rotation R INNER JOIN T0040_SHIFT_MASTER SM ON R.R_ShiftID=SM.Shift_ID					
			WHERE	SM.Cmp_ID=@Cmp_ID AND R.R_DayName = 'Day' + CAST(DATEPART(d, @Tmp_Date) As Varchar) AND
					Emp_Id=R.R_EmpID AND R.R_Effective_Date=(SELECT MAX(R_Effective_Date)
						FROM #Rotation R1 WHERE R1.R_EmpID=Emp_Id AND 
							 R_Effective_Date<=@Tmp_Date) AND 
					For_date=@Tmp_Date

			--Updating Shift ID from Employee Shift Detail where ForDate=@TempDate ANd Shift_Type=1 
			--And Rotation should be assigned to that particular employee
			UPDATE	#Data 
			SET		SHIFT_ID=ESD.SHIFT_ID,Shift_Type=ESD.Shift_Type
			FROM	#Data D INNER JOIN (SELECT esd.Shift_ID, esd.Emp_ID, esd.Shift_Type,esd.For_Date
					FROM T0100_EMP_SHIFT_DETAIL ESD WHERE Cmp_ID = ISNULL(@Cmp_ID,Cmp_ID) AND For_Date = @Tmp_Date) ESD ON
					D.Emp_Id=ESD.Emp_ID AND D.For_date=ESD.For_Date				
			WHERE	ESD.Emp_ID IN (Select R.R_EmpID FROM #Rotation R
						WHERE R_DayName = 'Day' + CAST(DATEPART(d, @Tmp_Date) As Varchar) AND R_Effective_Date<=@Tmp_Date
						GROUP BY R.R_EmpID) AND D.For_date=@Tmp_Date

			--Updating Shift ID from Employee Shift Detail where ForDate=@TempDate ANd Shift_Type=1 
			--And Rotation should not be assigned to that particular employee
			UPDATE	#Data 
			SET		SHIFT_ID=ESD.SHIFT_ID,Shift_Type=ESD.Shift_Type
			FROM	#Data D INNER JOIN (SELECT esd.Shift_ID, esd.Emp_ID, esd.Shift_Type,esd.For_Date
					FROM T0100_EMP_SHIFT_DETAIL esd WHERE Cmp_ID = ISNULL(@Cmp_ID,Cmp_ID) AND For_Date = @Tmp_Date) ESD ON
					D.Emp_Id=ESD.Emp_ID AND D.For_date=ESD.For_Date				
			WHERE	IsNull(ESD.Shift_Type,0)=1 AND ESD.Emp_ID NOT IN (Select R.R_EmpID FROM #Rotation R
						WHERE R_DayName = 'Day' + CAST(DATEPART(d, @Tmp_Date) As Varchar) AND R_Effective_Date<=@Tmp_Date
						GROUP BY R.R_EmpID) AND D.For_date=@Tmp_Date
			--End Nimesh
        
			SET @Tmp_Date = DATEADD(d,1,@tmp_date)        
		END
  Update #Data        
  set Shift_ID   = Q1.Shift_ID,          
   Shift_Type = q1.Shift_type        
  from #Data d inner Join        
  (select sd.shift_ID ,sd.Emp_ID,shift_type,sd.For_Date from T0100_Emp_Shift_Detail   sd         
  Where Cmp_ID =@Cmp_ID and Shift_Type =1 and For_Date >=@From_Date and For_Date <=@To_Date )q1 on        
  D.emp_ID = q1.For_Date And d.For_Date =Q1.For_Date   
         
 Declare @Shift_ID  numeric         
 Declare @From_Hour  numeric(12,3)        
 Declare @To_Hour  numeric(12,3)        
 Declare @Minimum_hour numeric(12,3)        
 Declare @Calculate_days numeric(12,1)        
 Declare @OT_applicable numeric(1)        
 Declare @Fix_OT_Hours numeric(12,3)        
 Declare @Shift_Dur  varchar(10)        
 Declare @Shift_Dur_sec numeric         
 Declare @Fix_W_Hours  numeric(5,2)        
         
        
       
 Declare Cur_shift cursor for         
   select sd.Shift_ID ,From_Hour,To_Hour,Minimum_hour,Calculate_days,OT_applicable,Fix_OT_Hours         
  ,Shift_Dur ,isnull(Fix_W_Hours,0) as  Fix_W_Hours        
   from T0050_shift_detail sd WITH (NOLOCK) 
   inner join T0040_shift_master sm WITH (NOLOCK) on sd.shift_ID= sm.Shift_ID 
   inner join (select distinct Shift_ID from #Data ) q on sm.shift_Id=  q.shift_ID        
   order by sd.shift_Id,From_Hour        
  open cur_shift        
  fetch next from cur_Shift into @shift_ID,@From_hour,@To_Hour,@Minimum_Hour,@Calculate_Days,@OT_Applicable,@Fix_OT_Hours,@Shift_Dur,@Fix_W_Hours         
  While @@Fetch_Status=0        
   begin        
          
    select @Shift_Dur_sec = dbo.F_Return_Sec(@Shift_Dur)        
          
            
       
     if @Fix_W_Hours > 0         
     begin         
		    Update #Data        
			set P_Days = @Calculate_Days, Duration_in_sec = @Fix_W_Hours * 3600        
			Where Duration_in_sec >=( @From_hour * 3600) and Duration_in_sec <= ( @To_Hour * 3600 )        
			and Shift_ID= @shift_ID         
    end        
     else        
    begin        
		    Update #Data        
			set P_Days = @Calculate_Days        
			Where Duration_in_sec >= (@From_hour * 3600) and Duration_in_sec <= ( @To_Hour * 3600 )        
			and Shift_ID= @shift_ID         
    end        
    
   
             
   If @OT_Applicable =1         
    begin        
   if @Fix_OT_Hours > 0         
   begin        
    Update #Data        
     set P_Days = @Calculate_Days,        
      OT_Sec = @Fix_OT_Hours * 3600         
       Where Duration_in_sec >=@From_hour * 3600 and Duration_in_sec <=@To_Hour * 3600         
      and Emp_OT= 1 and Shift_ID= @shift_ID         
   end        
     else if @Minimum_Hour > 0         
   begin        
    Update #Data        
     set P_Days = @Calculate_Days,        
      OT_Sec = Duration_in_sec - @Minimum_Hour * 3600         
     Where Duration_in_sec >=@From_hour * 3600 and Duration_in_sec <=@To_Hour * 3600         
      and Emp_OT= 1 and Shift_ID= @shift_ID         
   end        
     else if @Minimum_Hour = 0         
   begin        
    Update #Data        
     set P_Days = @Calculate_Days,       
      OT_Sec = Duration_in_sec - @Shift_Dur_sec  ,        
      Duration_in_sec= @Shift_Dur_sec        
     Where Duration_in_sec >=@From_hour * 3600 and Duration_in_sec <=@To_Hour * 3600         
    and Emp_OT= 1 and Duration_in_sec > @Shift_Dur_sec        
    and Shift_ID= @shift_ID         
   end              
  end        
  fetch next from cur_Shift into @shift_ID,@From_hour,@To_Hour,@Minimum_Hour,@Calculate_Days,@OT_Applicable,@Fix_OT_Hours,@Shift_Dur,@Fix_W_Hours         
  end        
 close cur_Shift        
 Deallocate Cur_Shift         
         
         
    update #Data         
   set OT_Sec = isnull(Approved_OT_Sec,0)  * 3600        
    from #Data  d inner join T0160_OT_Approval OA on d.emp_ID = Oa.Emp_ID and d.For_Date = oa.For_Date         
           
           
  Update #Data        
   set OT_Sec = 0         
   where Emp_OT_Min_Limit >= OT_sec and OT_sec >0        
        
  Update #Data        
   set OT_Sec = Emp_OT_Max_Limit        
  where OT_sec  > Emp_OT_Max_Limit  and Emp_OT_Max_Limit > 0 and OT_sec >0        
         
 

  if @Return_Record_set =2         
   begin       
    CREATE table #Data_Temp         
      (         
       Emp_Id   numeric ,         
       For_date datetime,        
       Duration_in_sec numeric,        
       Shift_ID numeric ,        
       Shift_Type numeric ,        
       Emp_OT  numeric ,        
       Emp_OT_min_Limit numeric,        
       Emp_OT_max_Limit numeric,        
       P_days  numeric(12,1) default 0,        
       OT_Sec  numeric default 0        
       )    
       Declare @T_Emp_ID Numeric  
       Declare @T_For_Date datetime  
        delete from #Data_Temp  
        DECLARE OT_cursor CURSOR  
        FOR  
           SELECT Emp_ID,For_Date FROM #Data   
         OPEN OT_cursor  
          fetch next from OT_cursor into @T_Emp_ID,@T_For_Date 
          while @@fetch_status = 0  
         BEGIN  
            
          if Not Exists(select Tran_Id from t0160_Ot_Approval WITH (NOLOCK) where Emp_ID=@T_Emp_ID And For_Date=@T_For_Date)  
           Begin  
            insert into #Data_Temp   
            select  * from #Data where Emp_ID=@T_Emp_ID And For_Date=@T_For_Date  
           End  
          fetch next from OT_cursor into @T_Emp_ID,@T_For_Date  
         END  
        CLOSE OT_cursor  
        DEALLOCATE OT_cursor  
        
     
        
    select *,dbo.F_Return_Hours (Duration_in_Sec) as Working_Hour , dbo.F_Return_Hours (OT_SEc) as OT_Hour  from #Data_Temp   OA        
     inner join T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID  
    where OT_sec > 0   
    order by OA.For_Date        
   end        
          
  
  else if @Return_Record_set =3        
   begin        
       
    /*update #Data         
     set OT_Sec = 0        
    from #Data  d inner join T0160_OT_Approval OA on d.emp_ID = Oa.Emp_ID         
        
       update #Data         
     set OT_Sec = isnull(Approved_OT_Sec,0)  * 3600        
    from #Data  d inner join T0160_OT_Approval OA on d.emp_ID = Oa.Emp_ID and d.For_Date = oa.For_Date   
          
                    
      */  
    CREATE table #Data_Temp_31         
      (         
       Emp_Id   numeric ,         
       For_date datetime,        
       Duration_in_sec numeric,        
       Shift_ID numeric ,        
       Shift_Type numeric ,        
       Emp_OT  numeric ,        
       Emp_OT_min_Limit numeric,        
       Emp_OT_max_Limit numeric,        
       P_days  numeric(12,1) default 0,        
       OT_Sec  numeric default 0        
       )    
       Declare @T_Emp_ID_3 Numeric  
       Declare @T_For_Date_3 datetime  
        delete from #Data_Temp_31 
        DECLARE OT_cursor CURSOR  
        FOR  
           SELECT Emp_ID,For_Date FROM #Data   
         OPEN OT_cursor  
          fetch next from OT_cursor into @T_Emp_ID_3,@T_For_Date_3  
          while @@fetch_status = 0  
         BEGIN  
            
          if Not Exists(select Tran_Id from t0160_Ot_Approval WITH (NOLOCK) where Emp_ID=@T_Emp_ID_3 And For_Date=@T_For_Date_3)  
           Begin  
            insert into #Data_Temp_31   
            select  * from #Data where Emp_ID=@T_Emp_ID_3 And For_Date=@T_For_Date_3  
           End  
          fetch next from OT_cursor into @T_Emp_ID_3,@T_For_Date_3  
         END  
        CLOSE OT_cursor  
        DEALLOCATE OT_cursor  
        
        
  --      	select OA.Emp_ID,Max(For_Date)For_Date,E.Emp_Full_Name, count(P_days) as Present_Days,DATEDIFF(dd,@From_Date,@To_date)+ 1 - count(P_days) as A_Days, DATEDIFF(dd,@From_Date,@To_date)+ 1        
		--From #Data_Temp_3  OA inner join T0080_emp_master E on OA.Emp_ID = E.Emp_ID       
		--Group by OA.emp_ID,E.Emp_Full_Name,OA.P_days 
		
          
                Declare @Emp_Temp table  
                (  
                    Emp_ID numeric(18,0),  
                    For_Date dateTime,  
                    Emp_full_Name varchar(50),                     
                    P_Days numeric(18,2),
                    A_Days numeric(18,2),
                    Total   numeric(18,0)  
                )  
                
                  
		insert into @Emp_Temp(Emp_ID,For_Date,Emp_full_Name,P_Days,A_Days,Total)        
      
		select OA.Emp_ID,Max(For_Date)For_Date,E.Emp_Full_Name, count(P_days) as Present_Days,DATEDIFF(dd,@From_Date,@To_date)+ 1 - count(P_days) as A_Days, DATEDIFF(dd,@From_Date,@To_date)+ 1        
		From #Data_Temp_31  OA inner join T0080_emp_master E WITH (NOLOCK) on OA.Emp_ID = E.Emp_ID       
		Group by OA.emp_ID,E.Emp_Full_Name 
     
		select OA1.Emp_ID,Max(For_Date)For_Date,E1.Emp_Full_Name,P_days ,A_Days,Total ,E1.Alpha_Emp_Code ,BM.Branch_Name
		From @Emp_Temp  OA1 inner join T0080_emp_master E1 WITH (NOLOCK) on OA1.Emp_ID = E1.Emp_ID   
		LEFT JOIN  T0030_BRANCH_MASTER BM WITH (NOLOCK) ON E1.Branch_ID = BM.Branch_ID        --add emp code and branch by chetan 15-12-16
		Group by OA1.emp_ID,E1.Emp_Full_Name , P_days,Total,A_Days,E1.Alpha_Emp_Code  ,BM.Branch_Name

   end                      
 RETURN

