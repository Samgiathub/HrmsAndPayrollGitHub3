
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[GET_OT_APPROVED_REJECT_RECORDS]
  @Cmp_ID    numeric        
 ,@From_Date   datetime        
 ,@To_Date    datetime         
 ,@Branch_ID   numeric        
 ,@Cat_ID    numeric         
 ,@Grd_ID    numeric        
 ,@Type_ID    numeric        
 ,@Dept_ID    numeric        
 ,@Desig_ID    numeric        
 ,@Emp_ID    numeric        
 ,@constraint   varchar(max)    
 ,@Type     varchar(1)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

	IF @Grd_ID = 0          
		set @Grd_ID = null          
	
	IF @Dept_ID = 0          
		set @Dept_ID = null 
		
	--Create table #Emp_Shift
	--	(
	--		Emp_Id numeric(18,0),
	--		For_date datetime,
	--		Shift_ID numeric(18,0),
	--		Shift_St_Time varchar(10),
	--		Shift_End_Time varchar(10)
	--		--Is_Night_Shift tinyint
	--	)
	-- add by Deepal DT :- 23092024
		CREATE TABLE #EMP_SHIFT
			(
				EMP_ID		NUMERIC,
				FOR_DATE	DATETIME,
				SHIFT_ID	NUMERIC,
				Shift_St_Time	DateTime,
				Shift_End_Time	DateTime,
				Duration		Varchar(5),
				Shift_Type		TinyInt,
				Shift_Before	DateTime,
				Shift_After		DateTime,
				Add_Hrs_Shift_End_Time	Numeric
			)
	-- END by Deepal DT :- 23092024

		IF @constraint = '' 
			SET @constraint = NULL

	CREATE TABLE #Emp_Cons
	(
		EMP_ID			NUMERIC,
		INCREMENT_ID	NUMERIC,
		BRANCH_ID		NUMERIC		
	)

	if (@constraint IS NULL )
		Begin
			Insert Into #Emp_Cons(Emp_Id,INCREMENT_ID,BRANCH_ID)
			Select Emp_Id, Increment_Id, Branch_Id
							From (Select DISTINCT OLT.Emp_ID,Increment_Id,Branch_ID
						from T0115_OT_LEVEL_APPROVAL OLT WITH (NOLOCK)
			INNER join 
				(
									select I.Emp_ID, I.Increment_Id, Branch_ID
									From T0095_Increment I WITH (NOLOCK)
						inner join     
						(
							select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)   
							where Increment_Effective_date <= @From_Date 
							and isnull(Grd_ID,0) = isnull(NULL ,Grd_ID)      
							and isnull(Dept_ID,0) = isnull(NULL ,isnull(Dept_ID,0)) group by emp_ID
						) Qry on I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID 
							) as INC on INC.Emp_ID = OLT.Emp_ID
						where S_Emp_Id = @Emp_ID
						and OLT.For_Date  >= @From_Date and OLT.For_Date <= @To_Date) Qry 

			
				select @constraint=  COALESCE(@CONSTRAINT + '#', '') +  CAST(Emp_ID AS VARCHAR(MAX)) 
				From #Emp_Cons
			
		End	
		DECLARE @First_In_Last_Out_For_InOut_Calculation TINYINT 
		SELECT	TOP 1 @First_In_Last_Out_For_InOut_Calculation  = First_In_Last_Out_For_InOut_Calculation
			
			FROM	#EMP_CONS EC 
			INNER JOIN T0040_GENERAL_SETTING GS  ON EC.BRANCH_ID=GS.BRANCH_ID
			INNER JOIN (SELECT	GS1.BRANCH_ID, MAX(FOR_DATE) AS FOR_DATE
						FROM	T0040_GENERAL_SETTING GS1 
						WHERE	GS1.FOR_DATE < @TO_DATE
						GROUP BY GS1.BRANCH_ID
			) GS1 ON GS.BRANCH_ID=GS1.BRANCH_ID AND GS.FOR_DATE=GS1.FOR_DATE	
	
		
	Exec P_GET_EMP_SHIFT_DETAIL @Cmp_ID=@Cmp_ID,@from_Date=@From_Date,@To_Date=@To_Date,@Constraint=@constraint
	
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
		GatePass_Deduct_Days NUMERIC(18,2) DEFAULT 0, -- Add by Gadriwala Muslim 05012014		
    )    
	
	EXEC P_GET_EMP_INOUT @Cmp_ID,@From_Date,@To_Date, @First_In_Last_Out_For_InOut_Calculation

	
	--UPDATE ES SET SHIFT_ST_TIME=  CASE WHEN SM.Is_Half_Day=1 THEN 
	--								 CASE WHEN SM.Week_Day = dbo.udf_DayOfWeek(For_date) THEN SM.Half_St_Time 
	--									  Else sm.Shift_St_Time 
	--								 End
	--							  Else SM.SHIFT_ST_TIME End ,
	--			 SHIFT_END_TIME=  CASE WHEN SM.Is_Half_Day=1 THEN 
	--								 CASE WHEN SM.Week_Day= dbo.udf_DayOfWeek(For_date) THEN SM.Half_End_Time 
	--									  Else sm.Shift_End_Time 
	--								 End
	--							Else SM.Shift_End_Time
	--  --SHIFT_END_TIME=SM.SHIFT_END_TIME
	--FROM #EMP_SHIFT ES INNER JOIN T0040_SHIFT_MASTER SM ON ES.SHIFT_ID=SM.SHIFT_ID
	--WHERE SM.CMP_ID=@CMP_ID
	
	UPDATE ES SET SHIFT_ST_TIME=  CASE WHEN (SM.Is_Half_Day=1 and SM.Week_Day = DATENAME(WEEKDAY, For_date)) 
										THEN ISNULL(SM.Half_St_Time,sm.Shift_St_Time) 
										Else sm.Shift_St_Time
								  End,								   
				 SHIFT_END_TIME=  CASE WHEN (SM.Is_Half_Day=1 and SM.Week_Day= DATENAME(WEEKDAY, For_date))
									 THEN ISNULL(SM.Half_End_Time,sm.Shift_End_Time) 
									 Else sm.Shift_End_Time 
								  END
	FROM #EMP_SHIFT ES INNER JOIN T0040_SHIFT_MASTER SM ON ES.SHIFT_ID=SM.SHIFT_ID
	WHERE SM.CMP_ID=@CMP_ID
	
	
	--Exec Fill_Emp_Curr_Shift_As_OT @Cmp_ID=@Cmp_ID,@from_Date=@From_Date,@To_Date=@To_Date,@Constraint=@Constraint
		
	IF @Type = 'A'
		begin
			select DISTINCT OLT.Tran_ID,OLT.Cmp_ID,OLT.Emp_ID,Em.Alpha_Emp_Code,OLT.cmp_ID,OLT.For_Date,Replace(OLT.Working_Sec,'.',':') as Working_HOur, Replace(OLT.OT_Sec,'.',':') as OT_HOur, Dbo.F_Return_Hours(OLT.Approved_OT_Sec) as Approved_OT_Hour, 
			 Replace(OLT.Weekoff_OT_Sec,'.',':') as Weekoff_OT_HOur,Dbo.F_Return_Hours(OLT.Approved_WO_OT_Sec) as Approved_Weekoff_OT_Hour , Replace(OLT.Holiday_OT_Sec,'.',':')  as Holiday_OT_HOur,Dbo.F_Return_Hours(OLT.Approved_HO_OT_Sec) as Approved_HO_OT_Hour,OLT.Rpt_Level,OLT.P_Days_Count,
			 Final_Approver, Is_Fwd_OT_Rej, EM.Emp_Full_Name, Is_Approved as Is_Approved ,
			 case when( 
						Rpt_Level >= 
								 (
									Select	 max(rpt_level) From T0115_OT_LEVEL_APPROVAL SLA WITH (NOLOCK)
									Where	 SLA.Emp_ID = OLT.Emp_ID and SLA.For_Date = OLT.For_Date and SLA.Cmp_ID = OLT.cmp_ID 
									group by SLA.Emp_ID
								 ) or  OLT.Final_Approver = 1
						)
			 then 1  else 0 end as Editable_Records,Remark,
			 case when OLT.Final_Approver = 1 then (select Tran_ID from T0160_OT_APPROVAL WITH (NOLOCK) where Emp_ID = OLT.Emp_ID and For_Date  = OLT.For_Date)  else 0 end as Final_Tran_ID
			 ,ES.Shift_St_Time as Shift_Start_Time,ES.Shift_End_Time,EI.In_Time,EI.Out_Time
			 ,OLT.Comments as Comment,dbo.F_Get_OT_QUARTERLYHOURS(OLT.Emp_ID,OLT.For_DATE)AS TOT_Qtr_Hours --Added By Jimit 01102018
			 from T0115_OT_LEVEL_APPROVAL OLT WITH (NOLOCK)
			INNER join 
				(		select I.Emp_ID From T0095_Increment I WITH (NOLOCK) inner join     
							(
								select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment  WITH (NOLOCK)  
								where Increment_Effective_date <= @From_Date 
								and isnull(Grd_ID,0) = isnull(@Grd_ID ,Grd_ID)      
								and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0)) group by emp_ID
							) Qry on I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID 
				) as INC on INC.Emp_ID = OLT.Emp_ID 
			Inner join	T0080_EMP_MASter EM WITH (NOLOCK) on EM.Emp_ID = OLT.Emp_ID 
			--left join	T0150_Emp_Inout_record EI on EI.Emp_ID=OLT.Emp_ID and EI.For_Date = OLT.For_Date
			Left Outer Join #Data EI on EI.Emp_ID=OLT.Emp_ID and EI.For_Date = OLT.For_Date
			left join #Emp_Shift ES on ES.For_date=OLT.For_Date and ES.Emp_Id=OLT.Emp_ID
				--left join
				--	(
				--		select	 max(for_date) as For_Date,Emp_ID,Shift_ID from T0100_EMP_SHIFT_DETAIL
				--		where	 For_Date <= @To_Date--For_Date >=@From_Date and For_Date<=@To_Date --between @From_Date and @To_Date
				--		group by Emp_ID,Shift_ID
				--	) ES on ES.EMp_ID=OLT.Emp_ID
				--left join T0040_SHIFT_MASTER SM on SM.Shift_ID=isnull(ES.Shift_ID,EM.Shift_ID)  --Condition Added by Sumit to get shfit time and In and Out detail on 15/09/2016
				
				where S_Emp_Id = @Emp_ID and Is_Approved = 1
				and OLT.For_Date  >= @From_Date and OLT.For_Date <= @To_Date
				and not Exists ( select 1 from T0115_OT_LEVEL_APPROVAL OTA WITH (NOLOCK)
									WHERE OTA.Emp_ID = OLT.Emp_Id AND OTA.For_Date = OLT.For_Date AND OTA.Rpt_Level > OLT.Rpt_Level)
									order by OLT.For_Date
									
														 
		end
	else If @Type = 'R'
		begin
			select DISTINCT OLT.Tran_ID,OLT.Cmp_ID,OLT.Emp_ID,Em.Alpha_Emp_Code,OLT.cmp_ID,OLT.For_Date,Replace(OLT.Working_Sec,'.',':') as Working_HOur, Replace(OLT.OT_Sec,'.',':') as OT_HOur, Dbo.F_Return_Hours(OLT.Approved_OT_Sec) as Approved_OT_Hour, 
			 Replace(OLT.Weekoff_OT_Sec,'.',':') as Weekoff_OT_HOur,Dbo.F_Return_Hours(OLT.Approved_WO_OT_Sec) as Approved_Weekoff_OT_Hour , Replace(OLT.Holiday_OT_Sec,'.',':')  as Holiday_OT_HOur,
			 Dbo.F_Return_Hours(OLT.Approved_HO_OT_Sec) as Approved_HO_OT_Hour,OLT.Rpt_Level,OLT.P_Days_Count,
			 Final_Approver, Is_Fwd_OT_Rej, EM.Emp_Full_Name, Is_Approved as Is_Approved , 
			 case when( Rpt_Level >= 
			 (
									Select max(rpt_level) From T0115_OT_LEVEL_APPROVAL SLA WITH (NOLOCK)
									Where SLA.Emp_ID = OLT.Emp_ID 
									  and SLA.For_Date = OLT.For_Date 
									  and SLA.Cmp_ID = OLT.cmp_ID 
						
									  group by SLA.Emp_ID
			 ) 
			 or  OLT.Final_Approver = 1)
			 then 1  else 0 end as Editable_Records,Remark,
			 case when OLT.Final_Approver = 1 then 
				(select Tran_ID from T0160_OT_APPROVAL WITH (NOLOCK) where Emp_ID = OLT.Emp_ID and For_Date  = OLT.For_Date)  
			 else 
				0 
			 end as Final_Tran_ID
			 ,ES.Shift_St_Time as Shift_Start_Time,ES.Shift_End_Time,EI.In_Time,EI.Out_Time
			,OLT.Comments  as Comment,dbo.F_Get_OT_QUARTERLYHOURS(OLT.Emp_ID,OLT.For_DATE)AS TOT_Qtr_Hours --Added By Jimit 01102018
			 from T0115_OT_LEVEL_APPROVAL OLT WITH (NOLOCK)
			INNER join 
				(
						select I.Emp_ID From T0095_Increment I WITH (NOLOCK)
						inner join     
						(
							select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)   
							where Increment_Effective_date <= @From_Date 
							 and isnull(Grd_ID,0) = isnull(@Grd_ID ,Grd_ID)      
							and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0)) group by emp_ID
						) Qry on I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID 
				) as INC on INC.Emp_ID = OLT.Emp_ID Inner join
				T0080_EMP_MASter EM on EM.Emp_ID = OLT.Emp_ID
					--left join T0150_Emp_Inout_record EI on EI.Emp_ID=OLT.Emp_ID and EI.For_Date=OLT.For_Date
					Left Outer Join #Data EI on EI.Emp_ID=OLT.Emp_ID and EI.For_Date = OLT.For_Date
				left join #Emp_Shift ES on ES.For_date=OLT.For_Date and ES.Emp_Id=OLT.Emp_ID
				--left join
				--	(
				--		select	 max(for_date) as For_Date,Emp_ID,Shift_ID from T0100_EMP_SHIFT_DETAIL
				--		where	 For_Date <= @To_Date--For_Date >=@From_Date and For_Date<=@To_Date --between @From_Date and @To_Date
				--		group by Emp_ID,Shift_ID
				--	) ES on ES.EMp_ID=OLT.Emp_ID
				--left join T0040_SHIFT_MASTER SM on SM.Shift_ID=isnull(ES.Shift_ID,EM.Shift_ID) --Condition Added by Sumit to get shfit time and In and Out detail on 15/09/2016
				where S_Emp_Id = @Emp_ID  and Is_Approved = 0	
				and OLT.For_Date  >= @From_Date and OLT.For_Date <= @To_Date
				order by OLT.For_Date
											
		end
	
	
END

