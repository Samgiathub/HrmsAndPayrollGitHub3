



--Mitesh 04/08/2011 ALTER for chnages of view on home page employee attendance
CREATE PROCEDURE [dbo].[SP_RPT_EMP_IN_OUT_MUSTER_HOME_GET_MULTIPLE_ENTRY]
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
	,@constraint 	varchar(5000)
	,@Report_For	varchar(50) = 'EMP RECORD'
AS
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON 
	
	IF @Branch_ID = 0  
		set @Branch_ID = null
		
	IF @Cat_ID = 0  
		set @Cat_ID = null

	IF @Grd_ID = 0  
		set @Grd_ID = null

	IF @Type_ID = 0  
		set @Type_ID = null

	IF @Dept_ID = 0  
		set @Dept_ID = null

	IF @Desig_ID = 0  
		set @Desig_ID = null

	IF @Emp_ID = 0  
		set @Emp_ID = null
		
	Declare @Emp_Cons Table
	(
		Emp_ID	numeric
	)
	
	if @Emp_ID <> null
		begin
			Insert Into @Emp_Cons(Emp_ID)values(@Emp_ID)
			--select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
		end
	else
		begin
			Insert Into @Emp_Cons(Emp_ID)

			select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	
							
			Where Cmp_ID = @Cmp_ID 
			and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
			and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			AND I.Emp_ID in (select emp_Id from
					(select emp_id, Cmp_ID, join_Date, isnull(left_Date, @To_Date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK) ) qry
					where Cmp_ID = @Cmp_ID   and  
					(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
					or ( @From_Date <= join_Date  and @To_Date >= left_date )	
					or ( @To_Date  >= join_Date  and @To_Date <= left_date )
					or left_date is null and  @To_Date >= Join_Date)) 
		end
	
	IF @Report_For = 'EMP RECORD'
		BEGIN
			Select E.Emp_ID ,E.Emp_code,E.Emp_full_Name,Comp_Name,Branch_Address 
			, Branch_Name , Dept_Name ,Grd_Name , Desig_Name,cmp_Name,Cmp_Address
			From @Emp_Cons EC INNER JOIN  T0080_EMP_MASTER E WITH (NOLOCK) ON EC.EMP_ID =E.EMP_ID  INNER JOIN ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID FROM T0095_Increment I WITH (NOLOCK) inner join 
						( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment WITH (NOLOCK)
						where Increment_Effective_date <= @To_Date
						and Cmp_ID = @Cmp_ID
						group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	)Q_I ON
			E.EMP_ID = Q_I.EMP_ID INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
			T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
			T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
			T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID LEFT OUTER JOIN
			T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID
			
			return 
		END
	
	declare @For_Date datetime 
	Declare @Date_Diff numeric 
	Declare @New_To_Date datetime 
	Declare @Row_ID	numeric 
	
	set @Date_Diff = datediff(d,@From_Date,@to_DAte) + 1 
	set @Date_Diff = 35 - ( @Date_Diff)
	set @New_To_Date = @To_Date --dateadd(d,@date_diff,@To_Date)
	
	
	Declare @Att_Period  table
	  (
		For_Date	datetime,
		Row_ID		numeric,
		IO_Tran_id numeric
	  )
	  
	 -------
	 
	 --insert into @Att_Period 
	 --select For_Date,row_number() over (order by IO_Tran_Id ) as Row_id,IO_Tran_id from T0150_EMP_INOUT_RECORD where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and (For_Date between @From_Date and @To_Date) order by IO_Tran_Id
	 
	 --select @For_Date=MAX(For_Date),@Row_ID=MAX(Row_ID) from @Att_Period
	 
	 ----
	 
	 
	 
	  set @For_Date = dateadd(d,1,@for_date)
	  set @Row_ID = @Row_ID + 1
	  
	set @For_Date = @From_Date
	set @Row_ID = 1
	
	While @For_Date <= @New_To_Date
		begin
			
			If Not Exists(select For_Date from T0150_EMP_INOUT_RECORD WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and For_Date = @for_date)
				Begin
					insert into @Att_Period 
					select @For_Date,@Row_ID,0
					
					set @Row_ID =@Row_ID + 1
					
				End
			Else
				Begin
					
					insert into @Att_Period 
					select For_Date,(row_number() over (order by IO_Tran_Id )) + @Row_ID - 1  as Row_id,IO_Tran_id from T0150_EMP_INOUT_RECORD WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID and For_Date = @for_date order by IO_Tran_Id
					
					select @Row_ID=MAX(Row_id) + 1 from @Att_Period
	 
				End
				
			set @for_Date = dateadd(d,1,@for_date)
		
		end
	
	
	
	 Declare @Att_Muster table
	  (
			Emp_Id		numeric , 
			Cmp_ID		numeric,
			branch_ID		numeric,
			For_Date	datetime,
			Status		varchar(10),
			Leave_code		varchar(10) default '-',
			Leave_Count	numeric(5,1),
			OD			varchar(10) default '-',
			OD_Count	numeric(5,1),
			WO_HO		varchar(2),
			Status_2	varchar(10),
			Row_ID		numeric ,
			In_Date		datetime,
			Out_Date	Datetime
			,shift_name  varchar(50),
			sh_in_time varchar(10),
			sh_out_time varchar(10),
			holiday varchar(50),
			late_limit varchar(10),
			Reason varchar(1000),
			Half_Full_Day Varchar(20),
			Chk_By_Superior varchar(15),
			Sup_Comment varchar(1000),
			Is_Cancel_Late_In tinyint,  -- Alpesh 02-Aug-2011 For Attendance Regularization
			Is_Cancel_Early_Out tinyint, -- Alpesh 02-Aug-2011 For Attendance Regularization
			IO_Tran_id numeric
	  )
	  
	 --Add by Nimesh 27 May, 2015
	--This sp retrieves the Shift Rotation as per given employee id and effective date.
	--it will fetch all employee's shift rotation detail if employee id is not specified.
	IF (OBJECT_ID('tempdb..#Rotation') IS NULL)
		Create Table #Rotation (R_EmpID numeric(18,0), R_DayName varchar(25), R_ShiftID numeric(18,0), R_Effective_Date DateTime);
	--The #Rotation table gets re-created in dbo.P0050_UNPIVOT_EMP_ROTATION stored procedure
	Exec dbo.P0050_UNPIVOT_EMP_ROTATION @Cmp_ID, NULL, @To_Date, @constraint
	
	
	declare @get_date as datetime
	set @get_date=cast(getdate() as varchar(11))
	
	insert into @Att_Muster (Emp_ID,Cmp_ID,branch_ID,For_Date,row_ID,io_tran_id)
	select 	Emp_ID ,@Cmp_ID ,@branch_ID,For_Date,row_ID,io_tran_id from @Att_Period cross join @Emp_Cons
	
	if @get_date<@To_Date
		set @To_Date=@get_date

	
	
	set @For_Date = @From_Date
	declare @Att_date as datetime
	select @Att_date= max(for_date) from @Att_Muster
	While @for_Date <= @Att_date
		begin
			
			/*Commented by Nimesh 20 May 2015
			update @Att_Muster
			set  shift_name=QW.shift_name
				,sh_in_time =QW.shift_st_time
				,sh_out_time=QW.shift_end_time
			--select QW.shift_st_time,QW.shift_end_time,QW.shift_name,QW.emp_id,QW.for_date,@for_Date, QW.shift_id
			 From @Att_Muster   AM inner join 
			-- (SELECT sm.Shift_ID, sm.Shift_Name,sm.Shift_St_Time, sm.Shift_End_Time,sd.Emp_ID,sd.For_Date 
			--FROM dbo.T0040_SHIFT_MASTER sm LEFT OUTER JOIN T0100_EMP_SHIFT_DETAIL sd ON sm.Shift_ID=sd.Shift_ID AND sm.Cmp_ID=sd.Cmp_ID 
			--WHERE sd.Emp_ID=@Emp_ID AND sm.Cmp_ID=@Cmp_ID) QW
			 (select SM.shift_st_time,SM.shift_end_time,SM.shift_name,Q_W.* from t0040_shift_master SM right outer join
			  (select Q.emp_id,Q1.for_date, Q1.shift_id from t0100_emp_shift_detail Q1 inner join
					 (select max(For_Date)as For_Date,Emp_ID from t0100_emp_shift_detail where For_Date <= @For_Date and Cmp_Id = @Cmp_ID group by emp_ID )Q 
			   on Q1.emp_ID =Q.Emp_ID and Q1.For_DAte = Q.For_Date)Q_W
			 on SM.shift_id=Q_w.shift_id)QW
			ON AM.EMP_ID = QW.EMP_ID 
			where AM.FOR_DATE = @for_Date
			*/
			
			--Modified by Nimesh 
			--Updating default shift info From Shift Detail
			UPDATE	@Att_Muster 
			SET		SHIFT_NAME=Shf.SHIFT_NAME,
					SH_IN_TIME =Shf.SHIFT_ST_TIME,
					SH_OUT_TIME=Shf.SHIFT_END_TIME
			FROM	@Att_Muster AM INNER JOIN (SELECT esd.Shift_ID, esd.Emp_ID,SM.SHIFT_NAME,SM.Shift_St_Time,SM.Shift_End_Time
					FROM	T0100_EMP_SHIFT_DETAIL ESD WITH (NOLOCK) INNER JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK) ON
					ESD.Cmp_ID=SM.Cmp_ID AND ESD.Shift_ID=SM.Shift_ID INNER JOIN  
					(SELECT MAX(For_Date) AS For_Date,Emp_ID FROM T0100_EMP_SHIFT_DETAIL WITH (NOLOCK)
						WHERE Cmp_ID = ISNULL(@Cmp_ID,Cmp_ID) AND For_Date <= @For_Date GROUP BY Emp_ID) S ON 
						esd.Emp_ID = S.Emp_ID AND esd.For_Date=s.For_Date) Shf ON 
					Shf.Emp_ID = AM.EMP_ID 
			WHERE	AM.For_Date=@For_Date
			
			
			--Updating Shift info From Rotation
			UPDATE	@Att_Muster 
			SET		SHIFT_NAME=SM.SHIFT_NAME,
					SH_IN_TIME =SM.SHIFT_ST_TIME,
					SH_OUT_TIME=SM.SHIFT_END_TIME
			FROM	#Rotation R INNER JOIN T0040_SHIFT_MASTER SM ON R.R_ShiftID=SM.Shift_ID					
			WHERE	SM.Cmp_ID=@Cmp_ID AND R.R_DayName = 'Day' + CAST(DATEPART(d, @for_Date) As Varchar) AND
					Emp_Id=R.R_EmpID AND R.R_Effective_Date=(SELECT MAX(R_Effective_Date)
						FROM #Rotation R1 WHERE R1.R_EmpID=Emp_Id AND 
							 R_Effective_Date<=@for_Date) 
					AND For_Date=@For_Date
					
							 			
			--Updating Shift Info For Shift_Type=0 And Existing in Rotation
			UPDATE	@Att_Muster 
			SET		SHIFT_NAME=Shf.SHIFT_NAME,
					SH_IN_TIME =Shf.SHIFT_ST_TIME,
					SH_OUT_TIME=Shf.SHIFT_END_TIME
			FROM	@Att_Muster p INNER JOIN 
					(
						SELECT	esd.Cmp_ID,esd.Shift_ID, esd.Shift_Type,esd.Emp_ID,SM.SHIFT_NAME,SM.Shift_St_Time,SM.Shift_End_Time
						FROM	T0100_EMP_SHIFT_DETAIL ESD WITH (NOLOCK) INNER JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK) ON
								ESD.Cmp_ID=SM.Cmp_ID AND ESD.Shift_ID=SM.Shift_ID
					) Shf ON p.Cmp_ID=Shf.Cmp_ID AND p.Emp_Id=Shf.Emp_ID
			WHERE	For_Date = @To_Date 
					AND Shf.Emp_ID IN (
										SELECT	DISTINCT R.R_EmpID 
										FROM	#Rotation R
										WHERE	R_DayName = 'Day' + CAST(DATEPART(d, @To_Date) As Varchar) 
									   )
					AND p.For_Date = @For_Date


			--Updating Shift Info For Shift_Type=1 And Not existing in Rotation
			UPDATE	@Att_Muster 
			SET		SHIFT_NAME=Shf.SHIFT_NAME,
					SH_IN_TIME =Shf.SHIFT_ST_TIME,
					SH_OUT_TIME=Shf.SHIFT_END_TIME
			FROM	@Att_Muster p INNER JOIN 
					(
						SELECT	esd.Cmp_ID,esd.Shift_ID, esd.Shift_Type,esd.Emp_ID,SM.SHIFT_NAME,SM.Shift_St_Time,SM.Shift_End_Time
						FROM	T0100_EMP_SHIFT_DETAIL ESD WITH (NOLOCK) INNER JOIN T0040_SHIFT_MASTER SM WITH (NOLOCK) ON
								ESD.Cmp_ID=SM.Cmp_ID AND ESD.Shift_ID=SM.Shift_ID
					) Shf ON p.Cmp_ID=Shf.Cmp_ID AND p.Emp_Id=Shf.Emp_ID
			WHERE	For_Date = @To_Date AND IsNull(Shf.Shift_Type,0)=1 
					AND Shf.Emp_ID NOT IN (
											SELECT	DISTINCT R.R_EmpID 
											FROM	#Rotation R
											WHERE	R_DayName = 'Day' + CAST(DATEPART(d, @To_Date) As Varchar) 
										   )
					AND p.For_Date = @For_Date
											
			--End Nimesh
			
			update @Att_Muster
			set  Late_limit=QW.late_limit
			From @Att_Muster   AM inner join 
			(select Q_w.for_date,EM.*,Q_W.late_limit from v0080_employee_master EM left outer join 
			 (select Q.branch_id,Q1.for_date,Q1.late_limit from T0040_GENERAL_SETTING Q1 WITH (NOLOCK) inner join
					 (select max(For_Date)as For_Date,branch_id from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <= @For_Date and Cmp_Id = @Cmp_ID group by branch_id )Q 
			   on Q1.branch_id =Q.branch_id and Q1.For_DAte = Q.For_Date)Q_W
			 on EM.branch_id=Q_W.Branch_id)QW
			ON AM.EMP_ID = QW.EMP_ID 
			where AM.FOR_DATE = @for_Date
			
			set @for_Date = dateadd(d,1,@for_date)
		end
			
		
	update @Att_Muster
	set Status = 'P'
	from @Att_Muster AM inner join T0150_EMP_INOUT_RECORD EIR ON AM.EMP_ID = EIR.EMP_ID
	AND AM.FOR_DATE = EIR.FOR_DATE 
	where NOT EIR.IN_TIME IS NULL
	and Am.For_Date >=@From_Date and Am.For_Date <=@To_Date
			
	update @Att_Muster
	set Leave_Count = LT.Leave_Used
		,status='L'
		,Leave_code= LT.Leave_code
	from @Att_Muster AM inner join (select LT1.*,EA.Leave_code,EA.Leave_type from T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) left outer join t0040_leave_master EA WITH (NOLOCK) on LT1.leave_id=EA.Leave_id where EA.Leave_code<>'OD' and EA.Leave_type<>'Company Purpose')LT
	ON AM.EMP_ID = LT.EMP_ID
	AND AM.FOR_DATE = LT.FOR_DATE 
	where LT.Leave_Used  >0
	and Am.For_Date >=@From_Date and Am.For_Date <=@To_Date


	update @Att_Muster
	set OD_count = LT.Leave_Used
		,status='OD'
		,OD= LT.Leave_code
	from @Att_Muster AM inner join (select LT1.*,EA.Leave_code,EA.Leave_type from T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) left outer join t0040_leave_master EA WITH (NOLOCK) on LT1.leave_id=EA.Leave_id where EA.Leave_code='OD' and EA.Leave_type='Company Purpose')LT
	ON AM.EMP_ID = LT.EMP_ID
	AND AM.FOR_DATE = LT.FOR_DATE 
	where LT.Leave_Used  >0
	and Am.For_Date >=@From_Date and Am.For_Date <=@To_Date

	Update @Att_Muster 
	set WO_HO = 'W'
	From @Att_Muster   AM inner join 
	( select ESD.* from T0100_WEEKOFF_ADJ ESD WITH (NOLOCK) inner join 
		( select max(For_Date)as For_Date ,Emp_ID from T0100_WEEKOFF_ADJ WITH (NOLOCK)
		where For_Date <= @For_Date and Cmp_Id = @Cmp_ID
		group by emp_ID )Q on ESD.emp_ID =Q.Emp_ID and ESD.For_DAte = Q.For_Date)Q_W 
		on AM.Emp_ID = Q_W.Emp_Id
	where charindex(datename(dw,AM.For_Date),Q_W.weekoff_day,0) >0
	and Am.For_Date >=@From_Date and Am.For_Date <=@To_Date
	
	Update @Att_Muster 
	set WO_HO = 'HO'
	,holiday=Hday_Name
	From @Att_Muster AM inner join 
	(select cmp_Id,Hday_Name,h_from_date,h_to_date from T0040_HOLIDAY_MASTER WITH (NOLOCK) where Cmp_ID = @Cmp_ID  )Q_W
	 on AM.cmp_ID = Q_W.cmp_Id
	 where isnull(Branch_ID,0) = isnull(@Branch_ID,0) and
							( (AM.for_date >= Q_W.h_from_date and AM.for_date <= Q_W.h_to_date) or 
							(AM.for_date >= Q_W.h_from_date and 	AM.for_date <= Q_W.h_to_date) or 
							(Q_W.h_from_date >= AM.for_date and Q_W.h_from_date <= AM.for_date) or
							(Q_W.h_to_date >= AM.for_date and Q_W.h_to_date <= AM.for_date))
	 
			
									
	Update @Att_Muster
	set Status_2 ='CO'
	Where Status = 'P' and 	( WO_HO = 'W' or WO_HO = 'HO' )
	and For_Date >=@From_Date and For_Date <=@To_Date
	
	Update @Att_Muster
	set Status = WO_HO
	Where isnull(Status,'') <> '' and ( WO_HO = 'HO' or WO_HO = 'W')
	and For_Date >=@From_Date and For_Date <=@To_Date
	
	Update @Att_Muster
	set Status ='A'
	Where Status is null
	and For_Date >=@From_Date and For_Date <=@To_Date


	Update @Att_Muster
	Set In_Date =In_time
	From @Att_Muster AM inner join 
	( select In_Time In_Time ,Emp_Id,For_Date,IO_Tran_Id from T0150_EMP_INOUT_RECORD WITH (NOLOCK)
		Where Cmp_ID = @cmp_ID and For_Date>=@From_Date and For_Date <=@To_Date
		--group by Emp_ID ,for_date 
	)q on Am.Emp_ID =q.emp_ID  and am.for_Date = Q.for_Date and am.IO_Tran_id =	q.IO_Tran_Id

	Update @Att_Muster
	Set Out_Date = OUT_Time
	From @Att_Muster AM inner join 
	( select Out_Time OUT_Time ,Emp_Id,For_Date,IO_Tran_Id from T0150_EMP_INOUT_RECORD WITH (NOLOCK)
		Where Cmp_ID = @cmp_ID and For_Date>=@From_Date and For_Date <=@To_Date
		--group by Emp_ID ,for_date 
	)q on Am.Emp_ID =q.emp_ID  and am.for_Date = Q.for_Date and am.IO_Tran_id =	q.IO_Tran_Id
	
	Update @Att_Muster
	Set Reason = isnull(Q.Reason,'')
	From @Att_Muster AM inner join 
	( select reason,for_date,emp_ID,IO_Tran_Id from T0150_EMP_INOUT_RECORD WITH (NOLOCK)
		Where Cmp_ID = @cmp_ID and For_Date>=@From_Date and For_Date <=@To_Date --and Reason is not null And Reason <> ''
	 )q on Am.Emp_ID =q.emp_ID  and am.for_date = Q.for_date  and am.IO_Tran_id =	q.IO_Tran_Id
	
	----Nikunj 08-June-2011---------
	Update @Att_Muster
	Set Half_Full_Day = isnull(Q.Half_Full_Day,'')
	From @Att_Muster AM inner join 
	(Select Half_Full_Day,for_date,emp_ID,IO_Tran_Id From T0150_EMP_INOUT_RECORD WITH (NOLOCK)
		Where Cmp_ID = @cmp_ID and For_Date>=@From_Date and For_Date <=@To_Date --and Half_Full_Day is not null And Half_Full_Day <> ''
	 )q on Am.Emp_ID =q.emp_ID  and am.for_date = Q.for_date and am.IO_Tran_id =	q.IO_Tran_Id
	
	----Nikunj 08-June-2011---------
	
	Update @Att_Muster
	set Status =  dbo.F_Return_HHMM(cast(datepart(hh,In_Date) as varchar(2))+ ':'+ cast(datepart(mi,In_Date) as varchar(2)))
	where Status = 'P'
	
	Update @Att_Muster
	set Status_2 =  dbo.F_Return_HHMM(cast(datepart(hh,OUT_Date) as varchar(2))+ ':'+ cast(datepart(mi,OUT_Date) as varchar(2)))
	where not OUT_Date is null


	Update @Att_Muster
	set Status = WO_HO
	where In_Date is null and ( WO_HO = 'W' or WO_HO = 'HO' )
	
	Update @Att_Muster
	set Status = '-'
	where isnull(Status,'')=''
	
	----------Alpesh 28-Jun-2011----------
	Update @Att_Muster
	Set Chk_By_Superior = isnull(Q.Chk_By_Superior,'')
	From @Att_Muster AM inner join 
	(Select Chk_By_Superior = case Chk_By_Superior when 2 then 'Rejected' when 1 then 'Approved' else '' end ,for_date,emp_ID,IO_Tran_Id From T0150_EMP_INOUT_RECORD WITH (NOLOCK)
		Where Cmp_ID = @cmp_ID and For_Date>=@From_Date and For_Date <=@To_Date --and Chk_By_Superior is not null
	 )q on Am.Emp_ID =q.emp_ID  and am.for_date = Q.for_date  and am.IO_Tran_id =	q.IO_Tran_Id
	 
	 Update @Att_Muster
	Set Sup_Comment = isnull(Q.Sup_Comment,'')
	From @Att_Muster AM inner join 
	(Select Sup_Comment,for_date,emp_ID,IO_Tran_Id From T0150_EMP_INOUT_RECORD WITH (NOLOCK)
		Where Cmp_ID = @cmp_ID and For_Date>=@From_Date and For_Date <=@To_Date --and Sup_Comment is not null
	 )q on Am.Emp_ID =q.emp_ID  and am.for_date = Q.for_date  and am.IO_Tran_id =	q.IO_Tran_Id
	---------------end-----------------
	----------Alpesh 02-Aug-2011----------
	 Update @Att_Muster
	Set Is_Cancel_Late_In = isnull(Q.Is_Cancel_Late_In,0)
	From @Att_Muster AM inner join 
	(Select Is_Cancel_Late_In,for_date,emp_ID,IO_Tran_Id From T0150_EMP_INOUT_RECORD WITH (NOLOCK)
		Where Cmp_ID = @cmp_ID and For_Date>=@From_Date and For_Date <=@To_Date
	 )q on Am.Emp_ID =q.emp_ID  and am.for_date = Q.for_date and am.IO_Tran_id =	q.IO_Tran_Id
	 
	 Update @Att_Muster
	Set Is_Cancel_Early_Out = isnull(Q.Is_Cancel_Early_Out,0)
	From @Att_Muster AM left outer join 
	(Select Is_Cancel_Early_Out,for_date,emp_ID,IO_Tran_Id From T0150_EMP_INOUT_RECORD WITH (NOLOCK)
		Where Cmp_ID = @cmp_ID and For_Date>=@From_Date and For_Date <=@To_Date --and Is_Cancel_Early_Out = 1
	 )q on Am.Emp_ID =q.emp_ID  and am.for_date = Q.for_date and am.IO_Tran_id =	q.IO_Tran_Id
	---------------end-----------------
	
	
	if @constraint =''
	 begin
		
		Select AM.*,datediff(mi,AM.for_date,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.late_limit as datetime))late_time ,
		--case when datediff(mi,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.sh_in_time as datetime),In_Date)<0 then 0 else datediff(mi,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.sh_in_time as datetime),In_Date) end late_minutes
		--,case when datediff(mi,Out_Date,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.sh_out_time as datetime))<0 then 0 else datediff(mi,Out_Date,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.sh_out_time as datetime)) end early_out
		'-' as late_minutes,'-' as early_out
		, E.Emp_code,E.Emp_full_Name, Branch_Name , Dept_Name ,Grd_Name , Desig_Name,Branch_Address,Comp_Name
		From @Att_Muster  AM Inner join T0080_EMP_MASTER E WITH (NOLOCK) ON AM.EMP_ID = E.EMP_ID
		INNER JOIN ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID FROM T0095_Increment I WITH (NOLOCK) inner join 
						( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment WITH (NOLOCK)
						where Increment_Effective_date <= @To_Date
						and Cmp_ID = @Cmp_ID
						group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	)Q_I ON
			E.EMP_ID = Q_I.EMP_ID INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
			T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
			T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
			T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID 
		Order by Emp_Code,Am.For_Date
	 end
	else if @constraint ='R'
	 begin
		Select AM.*,datediff(mi,AM.for_date,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.late_limit as datetime))late_time ,case when datediff(mi,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.sh_in_time as datetime),In_Date)<0 then 0 else datediff(mi,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.sh_in_time as datetime),In_Date) end late_minutes, E.Emp_code,E.Emp_full_Name
			, Branch_Name , Dept_Name ,Grd_Name , Desig_Name,Branch_Address,Comp_Name
		From @Att_Muster  AM Inner join T0080_EMP_MASTER E WITH (NOLOCK) ON AM.EMP_ID = E.EMP_ID
		INNER JOIN ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID FROM T0095_Increment I WITH (NOLOCK) inner join 
						( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment WITH (NOLOCK)
						where Increment_Effective_date <= @To_Date
						and Cmp_ID = @Cmp_ID
						group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	)Q_I ON
			E.EMP_ID = Q_I.EMP_ID INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
			T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
			T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
			T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID 
		where len(AM.Status)>2	
		Order by Emp_Code,Am.For_Date
	 end
	 else 
	 begin
		Select AM.*,datediff(mi,AM.for_date,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.late_limit as datetime))late_time ,case when datediff(mi,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.sh_in_time as datetime),In_Date)<0 then 0 else datediff(mi,cast(cast(AM.for_date as varchar(11)) + ' ' + AM.sh_in_time as datetime),In_Date) end late_minutes, E.Emp_code,E.Emp_full_Name
			, Branch_Name , Dept_Name ,Grd_Name , Desig_Name,Branch_Address,Comp_Name
		From @Att_Muster  AM Inner join T0080_EMP_MASTER E WITH (NOLOCK) ON AM.EMP_ID = E.EMP_ID
		INNER JOIN ( SELECT I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID FROM T0095_Increment I WITH (NOLOCK) inner join 
						( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment WITH (NOLOCK)
						where Increment_Effective_date <= @To_Date
						and Cmp_ID = @Cmp_ID
						group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	)Q_I ON
			E.EMP_ID = Q_I.EMP_ID INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
			T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
			T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
			T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID 
		where AM.Status=@constraint
		Order by Emp_Code,Am.For_Date
	 end
	select getdate() as get_date
	
	set @Report_For	= 'IN-OUT'
	set @constraint=''
	
	if exists(select name from sysobjects where xtype='U' and name='#P_Day')
		drop table #P_Day
	CREATE table #P_Day
	(
       		   emp_id numeric(18,1),
       		   Present numeric(18,1),
	           WO numeric(18,1),
	           HO numeric(18,1),
	           OD numeric(18,1),
	           Absent  numeric(18,1),
	           Leave  numeric(18,1),
	           Total  numeric(18,1),
 	)
 	
 
 	--insert into #P_Day(Total,emp_id)
 	--select isnull(count(isnull(status,'')),0),emp_id from @Att_Muster where status <> '-' AND for_date<=GETDATE()  group by emp_id
 	--											--Alpesh 08-Jul-2011 Added for_date condition for proper total upto today's date
 	
 	
 	insert into #P_Day(Total,emp_id)
 	 select count(*),emp_id from
	(select isnull(count(isnull(status,'')),0) as cntDay,emp_id from @Att_Muster where status <> '-' AND for_date<=GETDATE() group by emp_id,for_date) as a group by Emp_Id
 	
 	
	Update #P_Day
 	  set Present = AM.status
 	From #P_Day PD inner join 
 	(
 	select count(*) as status,emp_id from
	(select isnull(count(isnull(status,'')),0) as cntDay,emp_id from @Att_Muster where len(status)>2 group by emp_id,for_date) as a group by Emp_Id
	) as AM
 	on PD.emp_ID=AM.EMP_ID
 	
	Update #P_Day
 	  set WO = AM.status
 	From #P_Day PD inner join 
 	(
 	select count(*) as status,emp_id from
	(select isnull(count(isnull(status,'')),0) as cntDay,emp_id from @Att_Muster where status='W' group by emp_id,for_date) as a group by Emp_Id
	) as AM
 	on PD.emp_ID=AM.EMP_ID
 	
 	Update #P_Day
 	  set OD = AM.status
 	From #P_Day PD inner join 
 	(
 	select count(*) as status,emp_id from
	(select isnull(count(isnull(status,'')),0) as cntDay,emp_id from @Att_Muster where status='OD' group by emp_id,for_date) as a group by Emp_Id
	) as AM
 	on PD.emp_ID=AM.EMP_ID
 	
 	Update #P_Day
 	  set Absent = AM.status
 	From #P_Day PD inner join 
 	(
 	select count(*) as status,emp_id from
	(select isnull(count(isnull(status,'')),0) as cntDay,emp_id from @Att_Muster where status='A' group by emp_id,for_date) as a group by Emp_Id
	) as AM
 	on PD.emp_ID=AM.EMP_ID
 	
 	Update #P_Day
 	  set Leave = AM.status
 	From #P_Day PD inner join 
 	(
 	select count(*) as status,emp_id from
	(select isnull(count(isnull(status,'')),0) as cntDay,emp_id from @Att_Muster where status='L' group by emp_id,for_date) as a group by Emp_Id
	) as AM
 	on PD.emp_ID=AM.EMP_ID
 	
 	Update #P_Day
 	  set HO = AM.status
 	From #P_Day PD inner join 
 	(
 	select count(*) as status,emp_id from
	(select isnull(count(isnull(status,'')),0) as cntDay,emp_id from @Att_Muster where status='HO' AND for_date<=GETDATE()  group by emp_id,for_date) as a group by Emp_Id
	) as AM
 	on PD.emp_ID=AM.EMP_ID       --Alpesh 08-Jul-2011 Added for_date condition for proper total upto today's date
 	
 	
 	Select * from #P_Day
 	
	--exec SP_GRP_EMP_INOUT_RECORD_GET @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,@Report_For
		
Drop Table #P_Day
		
RETURN




