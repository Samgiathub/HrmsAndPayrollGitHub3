

---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_LEAVE_APPROVAL_DETAILS_GET_REIM]
	 @Cmp_ID		Numeric
	,@From_Date		Datetime
	,@To_Date		Datetime
	,@Branch_ID		Numeric 
	,@Cat_ID		Numeric
	,@Grd_ID		Numeric
	,@Type_ID		Numeric 
	,@Dept_Id		Numeric
	,@Desig_Id		Numeric
	,@Emp_ID		Numeric
	,@Leave_Status  varchar(1)
	,@Constraint	varchar(5000)
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

	
	IF @Leave_Status = 'S' or 	@Leave_Status =''
		set @Leave_Status = null
		
Declare @Total_Leave_Day as numeric(18,2) --Ripal 05July2014
set @Total_Leave_Day = 0.0  

	Declare @Emp_Cons Table
		(
			Emp_ID	numeric
		)
	
	if @Constraint <> ''
		begin
			Insert Into @Emp_Cons
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
		end
	else
		begin
			Insert Into @Emp_Cons

			select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
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
			and I.Emp_ID in 
				( select Emp_Id from
				(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
				where cmp_ID = @Cmp_ID   and  
				(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
				or ( @To_Date  >= join_Date  and @To_Date <= left_date )
				or Left_date is null and @To_Date >= Join_Date)
				or @To_Date >= left_date  and  @From_Date <= left_date ) 
		end
		
		
	----Ankit 29072016 ----
	DECLARE @Required_Execution BIT;
	SET @Required_Execution = 0;
	
	DECLARE @Pre_Date_WeekOff		DATETIME 
	DECLARE @Next_Date_WeekOff		DATETIME 
	DECLARE @StrWeekoff_Date		VARCHAR(500)
	DECLARE @Pre_Date_Weekoff_tmp	DATETIME
	DECLARE @Actual_WO_Days			NUMERIC
	Declare @Next_Date_WeekOff_Fnl	Datetime
	Declare @Pre_Date_WeekOff_Fnl	Datetime
	
	IF OBJECT_ID('tempdb..#EMP_HW_CONS') IS NULL
		BEGIN	
			--Holiday & Weekoff - In colon(;) seperated string (With Cancel) : Used in SP_CALCULATE_PRESENT_DAYS
			CREATE TABLE #EMP_HW_CONS
			(
				Emp_ID				NUMERIC,
				WeekOffDate			Varchar(Max),
				WeekOffCount		NUMERIC(3,1),
				CancelWeekOff		Varchar(Max),
				CancelWeekOffCount	NUMERIC(3,1),
				HolidayDate			Varchar(MAX),
				HolidayCount		NUMERIC(3,1),
				HalfHolidayDate		Varchar(MAX),
				HalfHolidayCount	NUMERIC(3,1),
				CancelHoliday		Varchar(Max),
				CancelHolidayCount	NUMERIC(3,1)
			);
			
			CREATE UNIQUE CLUSTERED INDEX IX_EMP_HW_CONS_EmpID ON #EMP_HW_CONS(Emp_ID)
			
			SET @Required_Execution  =1;		
		END
	
	IF @Required_Execution = 1
		BEGIN
			DECLARE @All_Weekoff BIT
			SET @All_Weekoff = 0;
			
			EXEC dbo.SP_RETURN_PRE_NEXT_DATE_OF_WEEKOFF @From_Date,'',@Pre_Date_Weekoff_tmp OUTPUT,@Next_Date_WeekOff OUTPUT
			EXEC dbo.SP_RETURN_PRE_NEXT_DATE_OF_WEEKOFF @To_Date,'',@Pre_Date_WeekOff OUTPUT,@Next_Date_WeekOff OUTPUT								
		
			SET @Pre_Date_WeekOff_Fnl = @Pre_Date_Weekoff_tmp
			SET @Next_Date_WeekOff_Fnl = @Next_Date_WeekOff
			
			SET @Pre_Date_Weekoff_tmp = DATEADD(DAY,-1,@Pre_Date_Weekoff_tmp)
			SET @Next_Date_WeekOff = DATEADD(DAY,1,@Next_Date_WeekOff)
				
			EXEC SP_GET_HW_ALL @CONSTRAINT=@Emp_ID,@CMP_ID=@Cmp_ID, @FROM_DATE=@Pre_Date_Weekoff_tmp, @TO_DATE=@Next_Date_WeekOff, @All_Weekoff = @All_Weekoff, @Exec_Mode=0		
			
		END 
	
	SELECT @StrWeekoff_Date = ISNULL(WeekOffDate,'') + ISNULL(HolidayDate, '') FROM #EMP_HW_CONS	
	
	IF OBJECT_ID('tempdb..#Emp_RC_WH') IS NULL
		BEGIN	
			CREATE TABLE #Emp_RC_WH (Emp_ID	NUMERIC, WeekOffDate	DATETIME)
		END
	
	IF EXISTS ( SELECT 1 FROM #EMP_HW_CONS WHERE  ISNULL(WeekOffDate,'') <> '' )	
		BEGIN
			INSERT INTO #Emp_RC_WH
			SELECT @Emp_ID , CAST(DATA AS DATETIME ) FROM  dbo.Split(@StrWeekoff_Date,';') WHERE DATA <> ''
			
			IF NOT EXISTS( SELECT 1 FROM #Emp_RC_WH WHERE WeekOffDate = @Next_Date_WeekOff_Fnl)
				BEGIN
					DELETE FROM #Emp_RC_WH WHERE WeekOffDate > @Next_Date_WeekOff_Fnl
				END
			
			IF NOT EXISTS( SELECT 1 FROM #Emp_RC_WH WHERE WeekOffDate = @Pre_Date_WeekOff_Fnl)
				BEGIN
					DELETE FROM #Emp_RC_WH WHERE WeekOffDate < @Pre_Date_WeekOff_Fnl
				END	
			
			SELECT @Actual_WO_Days = Count(*) FROM #Emp_RC_WH WHERE Emp_ID  = @Emp_ID
			
			--SELECT * FROM #Emp_RC_WH
					
		END
	
	-----------------------	
		
	IF EXISTS(SELECT 1 FROM T0120_LEAVE_APPROVAL LA  WITH (NOLOCK) inner join @Emp_cons ec on la.emp_ID = ec.emp_ID   INNER JOIN T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) ON LA.Leave_Approval_ID = LAD.Leave_Approval_ID
				AND LA.Cmp_ID= LAD.Cmp_ID AND LA.Approval_Status='A' AND LAD.From_Date=@From_Date AND LAD.To_Date=@To_Date)
		BEGIN
		
		--Ripal 05July2014 Start
		Select @Total_Leave_Day = Sum(lad.Leave_Period)
         from T0120_Leave_Approval la WITH (NOLOCK) inner join 
				@Emp_cons ec on la.emp_ID = ec.emp_ID  Inner join
				T0130_Leave_Approval_Detail Lad WITH (NOLOCK) on la.Leave_Approval_ID = lad.Leave_Approval_ID
		 where  la.cmp_ID=@Cmp_ID  and Approval_Status=isnull(@Leave_Status,Approval_Status)
			and lad.From_Date >=@From_Date and 
			 lad.to_Date <=@To_Date 
			 and LA.Leave_Approval_ID  not In (select Leave_Approval_ID from dbo.T0150_LEAVE_CANCELLATION LC WITH (NOLOCK) where  LC.cmp_id=@Cmp_ID and LC.For_Date >= @From_Date and LC.For_Date <= @To_Date  and LC.Is_Approve=1)
		 group by la.emp_ID
		 ORDER BY la.emp_ID
		--Ripal 05July2014 End
		
		
		SET @Total_Leave_Day = @Total_Leave_Day + ISNULL(@Actual_WO_Days,0)
				
	    Select la.*,e.Emp_Full_name,e.Emp_Code,e.Alpha_Emp_Code,e.Emp_First_Name,GM.Grd_Name,Branch_Name,
				Lad.From_Date,Lad.To_Date
	            ,Dept_Name,Desig_Name,type_Name,Leave_Name,lad.Leave_Period,Cmp_Name,
	            Cmp_Address ,comp_name,Branch_address,@From_Date as From_Date,@To_Date as To_Date,
	            BM.Branch_ID,Lad.Leave_ID --Lad.Leave_ID Added by Ripal 17jan2014
	            ,isnull(@Total_Leave_Day,0) as Total_Leave_Day	                      
         from T0120_Leave_Approval la WITH (NOLOCK)
         inner join @Emp_cons ec on la.emp_ID = ec.emp_ID 
         Inner join  T0130_Leave_Approval_Detail Lad WITH (NOLOCK) on la.Leave_Approval_ID = lad.Leave_Approval_ID 
         inner join T0080_Emp_Master e WITH (NOLOCK) on la.emp_ID= e.emp_ID 
         inner join T0010_Company_Master CM WITH (NOLOCK) on la.CMP_ID= CM.CMP_ID
         inner join T0040_Leave_Master LM WITH (NOLOCK) on LM.Leave_ID = Lad.Leave_ID
		
         inner join
					( select I.Emp_Id , Cmp_ID,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date from T0095_Increment I WITH (NOLOCK) inner join 
							( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = @Cmp_ID
							group by emp_ID  ) Qry on
							I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date	 ) I_Q 
						on E.Emp_ID = I_Q.Emp_ID  inner join
							T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
							T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
							T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
							T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join 
							T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  
							
										   
		where  la.cmp_ID=@Cmp_ID  and Approval_Status=isnull(@Leave_Status,Approval_Status)
			and lad.From_Date >=@From_Date and 
			 lad.to_Date <=@To_Date 
			 and LA.Leave_Approval_ID  not In (select Leave_Approval_ID from dbo.T0150_LEAVE_CANCELLATION LC WITH (NOLOCK) where  LC.cmp_id=@Cmp_ID and LC.For_Date >= @From_Date and LC.For_Date <= @To_Date  and LC.Is_Approve=1)
		Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End
		--ORDER BY RIGHT(REPLICATE(N' ', 500) + e.ALPHA_EMP_CODE, 500) 
         
       END
     ELSE
     BEGIN
		
		--Ripal 05July2014 Start
		Select @Total_Leave_Day = Sum(lad.Leave_Period)
         from T0120_Leave_Approval la WITH (NOLOCK) inner join 
				@Emp_cons ec on la.emp_ID = ec.emp_ID  Inner join
				T0130_Leave_Approval_Detail Lad WITH (NOLOCK) on la.Leave_Approval_ID = lad.Leave_Approval_ID 
		 where  la.cmp_ID=@Cmp_ID  and Approval_Status=isnull(@Leave_Status,Approval_Status)
			and  ( lad.From_Date between @From_Date and @To_Date
				   OR Lad.To_Date between @From_Date and @To_Date 
				   OR @From_Date between lad.From_Date and Lad.To_Date
				   OR @To_Date between lad.From_Date and Lad.To_Date )
			 and LA.Leave_Approval_ID  not In (select Leave_Approval_ID from dbo.T0150_LEAVE_CANCELLATION LC WITH (NOLOCK) where  LC.cmp_id=@Cmp_ID and LC.For_Date >= @From_Date and LC.For_Date <= @To_Date  and LC.Is_Approve=1)
		 group by la.emp_ID
		 ORDER BY la.emp_ID
		--Ripal 05July2014 End
		--(@From_Date between lad.From_Date and Lad.To_Date
		-- OR  @To_Date between lad.From_Date and Lad.To_Date)
		
		
		 
		SET @Total_Leave_Day = @Total_Leave_Day + isnull(@Actual_WO_Days,0) --Ankit 29072016
		
		
		Select   la.*,e.Emp_Full_name,e.Emp_Code,e.Alpha_Emp_Code,e.Emp_First_Name,GM.Grd_Name,Branch_Name,Lad.From_Date,Lad.To_Date
	                      ,Dept_Name,Desig_Name,type_Name,Leave_Name,lad.Leave_Period,Cmp_Name,Cmp_Address ,comp_name,Branch_address,
	                      @From_Date as From_Date1,@To_Date as To_Date1,
	                      BM.Branch_ID,Lad.Leave_ID --Lad.Leave_ID Added by Ripal 17jan2014
	                      ,isnull(@Total_Leave_Day,0) as Total_Leave_Day
         from T0120_Leave_Approval la WITH (NOLOCK)
         inner join @Emp_cons ec on la.emp_ID = ec.emp_ID 
         Inner join  T0130_Leave_Approval_Detail Lad WITH (NOLOCK) on la.Leave_Approval_ID = lad.Leave_Approval_ID 
         inner join T0080_Emp_Master e WITH (NOLOCK) on la.emp_ID= e.emp_ID 
         inner join T0010_Company_Master CM WITH (NOLOCK) on la.CMP_ID= CM.CMP_ID
         inner join T0040_Leave_Master LM WITH (NOLOCK) on LM.Leave_ID = Lad.Leave_ID
         inner join
					( select I.Emp_Id , Cmp_ID,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date from T0095_Increment I WITH (NOLOCK) inner join 
							( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = @Cmp_ID
							group by emp_ID  ) Qry on
							I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date	 ) I_Q 
						on E.Emp_ID = I_Q.Emp_ID  inner join
							T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
							T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
							T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
							T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join 
							T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  
							
										   
		where  la.cmp_ID=@Cmp_ID  and Approval_Status=isnull(@Leave_Status,Approval_Status)
			and  ( lad.From_Date between @From_Date and @To_Date
				   OR Lad.To_Date between @From_Date and @To_Date
				   OR @From_Date between lad.From_Date and Lad.To_Date
				   OR @To_Date between lad.From_Date and Lad.To_Date )
			 and LA.Leave_Approval_ID  not In (select Leave_Approval_ID from dbo.T0150_LEAVE_CANCELLATION LC WITH (NOLOCK) where  LC.cmp_id=@Cmp_ID and LC.For_Date >= @From_Date and LC.For_Date <= @To_Date  and LC.Is_Approve=1)
		Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End
		--ORDER BY RIGHT(REPLICATE(N' ', 500) + e.ALPHA_EMP_CODE, 500) 
  
  --@From_Date between lad.From_Date and Lad.To_Date
		--			OR  @To_Date between lad.From_Date and Lad.To_Date
     
  --    Select   la.*,e.Emp_Full_name,e.Emp_Code,e.Alpha_Emp_Code,e.Emp_First_Name,GM.Grd_Name,Branch_Name,Lad.From_Date,Lad.To_Date
	 --                     ,Dept_Name,Desig_Name,type_Name,Leave_Name,lad.Leave_Period,Cmp_Name,Cmp_Address ,comp_name,Branch_address,@From_Date as From_Date1,@To_Date as To_Date1, BM.Branch_ID,Lad.Leave_ID --Lad.Leave_ID Added by Ripal 17jan2014
	                                            
  --       from T0120_Leave_Approval la 
  --       inner join @Emp_cons ec on la.emp_ID = ec.emp_ID 
  --       Inner join  T0130_Leave_Approval_Detail Lad on la.Leave_Approval_ID = lad.Leave_Approval_ID 
  --       inner join T0080_Emp_Master e on la.emp_ID= e.emp_ID 
  --       inner join T0010_Company_Master CM on la.CMP_ID= CM.CMP_ID
  --       inner join T0040_Leave_Master LM on LM.Leave_ID = Lad.Leave_ID
		
  --       inner join
		--			( select I.Emp_Id , Cmp_ID,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date from T0095_Increment I inner join 
		--					( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment
		--					where Increment_Effective_date <= @To_Date
		--					and Cmp_ID = @Cmp_ID
		--					group by emp_ID  ) Qry on
		--					I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date	 ) I_Q 
		--				on E.Emp_ID = I_Q.Emp_ID  inner join
		--					T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
		--					T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
		--					T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
		--					T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id Inner join 
		--					T0030_Branch_Master BM on I_Q.Branch_ID = BM.Branch_ID  
							
										   
		--where  la.cmp_ID=@Cmp_ID  and Approval_Status=isnull(@Leave_Status,Approval_Status)
		--	and lad.From_Date =@From_Date 
		--	 and LA.Leave_Approval_ID  not In (select Leave_Approval_ID from dbo.T0150_LEAVE_CANCELLATION LC where  LC.cmp_id=@Cmp_ID and LC.For_Date >= @From_Date and LC.For_Date <= @To_Date  and LC.Is_Approve=1)
		--ORDER BY RIGHT(REPLICATE(N' ', 500) + e.ALPHA_EMP_CODE, 500) 
     
     END   
                 
 RETURN 
