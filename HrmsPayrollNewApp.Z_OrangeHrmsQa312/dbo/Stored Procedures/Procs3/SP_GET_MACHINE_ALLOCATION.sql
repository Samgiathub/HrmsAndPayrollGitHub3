

-- =============================================
-- Author:		Shaikh Ramiz
-- Create date: 29-Jan-2018
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_GET_MACHINE_ALLOCATION]
	 @Cmp_ID			numeric
	,@From_Date			datetime
	,@To_Date			datetime 
	,@Branch_ID			VARCHAR(MAX) = ''
	,@Cat_ID			VARCHAR(MAX) = ''
	,@Grd_ID			VARCHAR(MAX) = ''
	,@Type_ID			numeric  = 0
	,@Dept_ID			VARCHAR(MAX) = ''
	,@Desig_ID			VARCHAR(MAX) = ''
	,@Emp_ID			numeric  = 0
	,@Vertical_ID		VARCHAR(MAX) = ''
	,@SubVertical_ID	VARCHAR(MAX) = ''	
	,@Shift_Id			numeric  = 0
	,@Constraint		varchar(max) = ''
	,@SubBranch_ID	VARCHAR(MAX) = ''	
	,@Segment_ID	VARCHAR(MAX) = ''
	,@Record_Type	VARCHAR(MAX) = ''
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	SET @From_Date = @To_Date;
	
	if @Shift_Id = 0
		SET @Shift_Id = null
	
	CREATE table #Emp_Cons 
	(      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric    
	)            
      
	CREATE TABLE #EMP_SHIFT
	(
		Emp_Id numeric(18,0),
		For_date datetime,
		Shift_ID numeric(18,0),
		Shift_St_Time varchar(10),
		Shift_End_Time varchar(10)
	)
	
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
		   IO_Tran_Id	   numeric default 0, -- io_tran_id is used for is_cmp_purpose (t0150_emp_inout)
		   OUT_Time datetime,
		   Shift_End_Time datetime,			--Ankit 16112013
		   OT_End_Time numeric default 0,	--Ankit 16112013
		   Working_Hrs_St_Time tinyint default 0, --Hardik 14/02/2014
		   Working_Hrs_End_Time tinyint default 0, --Hardik 14/02/2014
		   GatePass_Deduct_Days numeric(18,2) default 0 -- Add by Gadriwala Muslim 05012014
	   )    
	   	 
    EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,@Segment_ID,@Vertical_Id,@SubVertical_Id,@SubBranch_ID,0,0,0,'0',0,0               
	

	--Working
	--SELECT * FROM T0040_MACHINE_ALLOCATION_MASTER order by Emp_ID

--	SELECT	EC.Emp_ID, Alpha_Emp_Code , EM.Alpha_Emp_Code + ' - ' + EM.Emp_Full_Name as Emp_Full_Name , 
--			EM.Shift_ID , I.Branch_ID , I.Dept_ID , I.Vertical_ID , I.SubVertical_ID,I.Segment_ID
--			--,T1.Machine_ID 
--	FROM	#EMP_CONS EC
--		INNER JOIN T0080_EMP_MASTER EM ON EC.Emp_ID = EM.Emp_ID
--		INNER JOIN T0095_INCREMENT I ON EC.Increment_ID = I.Increment_ID
--		LEFT OUTER JOIN 
--				(	
--					SELECT MAM.Emp_ID , MAM.Machine_ID  , MAM.Shift_ID
--					FROM T0040_MACHINE_ALLOCATION_MASTER MAM
--					INNER JOIN
--							(	SELECT Machine_ID , Shift_ID, Emp_ID,  MAX(Effective_Date) AS Effective_Date
--								FROM T0040_Machine_Allocation_Master
--								WHERE Effective_Date <= @To_Date
--								GROUP BY Machine_ID , Shift_ID,Emp_ID
--							)T ON T.Machine_ID = MAM.Machine_ID AND T.Effective_Date = MAM.Effective_Date and T.Emp_ID = MAM.Emp_ID					
--				)T1 ON T1.Emp_ID = EC.Emp_ID 
--Order by EC.Emp_ID
--return
--	--Working

		CREATE TABLE #NEW_ALLOCATION
		(
			EMP_ID			NUMERIC,
			Alpha_Emp_Code	VARCHAR(50),
			Emp_Full_Name	VARCHAR(100),
			Shift_ID		NUMERIC,
			Branch_ID		NUMERIC,
			Dept_ID			NUMERIC,
			Vertical_ID		NUMERIC,
			SubVertical_ID	NUMERIC,
			Segment_ID		NUMERIC,
			MachineEmpType	VARCHAR(2),
			Machine_ID		VARCHAR(50),
			To_date			DATETIME,
			Shift_Name		VARCHAR(50),
			Machine_Name	VARCHAR(5000),
			EFFICIENCY_ID	NUMERIC,
			EFFICIENCY		NUMERIC(18,2),
			Alternate_EmpID	NUMERIC
		)
	
	--INSERT INTO #NEW_ALLOCATION
	--	( EMP_ID, Alpha_Emp_Code, Emp_Full_Name,	Shift_ID, Branch_ID, Dept_ID, Vertical_ID, SubVertical_ID, Segment_ID,	Machine_ID,	To_date, Machine_Name )
	--SELECT	EC.Emp_ID, Alpha_Emp_Code , EM.Alpha_Emp_Code + ' - ' + EM.Emp_Full_Name as Emp_Full_Name , 
	--		EM.Shift_ID , I.Branch_ID , I.Dept_ID , I.Vertical_ID , I.SubVertical_ID,I.Segment_ID ,
	--		T1.Machine_ID , @To_Date AS To_date , TY.Machine_Name
	--FROM	#EMP_CONS EC
	--	INNER JOIN T0080_EMP_MASTER EM ON EC.Emp_ID = EM.Emp_ID
	--	INNER JOIN T0095_INCREMENT I ON EC.Increment_ID = I.Increment_ID
	--	LEFT OUTER JOIN 
	--			(	
	--				SELECT MAM.Emp_ID , MAM.Machine_ID  , MAM.Shift_ID
	--				FROM T0040_MACHINE_ALLOCATION_MASTER MAM
	--				INNER JOIN
	--						(	SELECT Machine_ID , Shift_ID, Emp_ID, MAX(Effective_Date) AS Effective_Date
	--							FROM T0040_Machine_Allocation_Master
	--							WHERE Effective_Date <= @To_Date
	--							GROUP BY Emp_ID ,Machine_ID , Shift_ID
	--						)T ON T.Machine_ID = MAM.Machine_ID AND T.Effective_Date = MAM.Effective_Date --and T.Shift_ID = MAM.Shift_ID					
	--			)T1 ON T1.Emp_ID = EC.Emp_ID
	--	CROSS APPLY (SELECT STUFF((SELECT	',' + MM.Machine_Name
	--							   FROM		T0040_Machine_Master MM
	--							   WHERE	CHARINDEX('#' + CAST(MM.Machine_ID AS VARCHAR(10)) + '#', '#' + T1.Machine_ID + '#') > 0
	--										FOR XML PATH('')), 1,1,'') AS Machine_Name) TY

	INSERT INTO #NEW_ALLOCATION
		( EMP_ID, Alpha_Emp_Code, Emp_Full_Name,	Shift_ID, Branch_ID, Dept_ID, Vertical_ID, SubVertical_ID, Segment_ID,	Machine_ID,	To_date, Machine_Name )
	SELECT	EC.Emp_ID, Alpha_Emp_Code , EM.Alpha_Emp_Code + ' - ' + EM.Emp_Full_Name as Emp_Full_Name , 
			EM.Shift_ID , I.Branch_ID , I.Dept_ID , I.Vertical_ID , I.SubVertical_ID,I.Segment_ID ,
			T1.Machine_ID , @To_Date AS To_date , TY.Machine_Name
	FROM	#EMP_CONS EC
		INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EC.Emp_ID = EM.Emp_ID
		INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON EC.Increment_ID = I.Increment_ID
		LEFT OUTER JOIN 
				(	
					SELECT MAM.Emp_ID , MAM.Machine_ID  , MAM.Shift_ID
					FROM T0040_MACHINE_ALLOCATION_MASTER MAM WITH (NOLOCK)
					INNER JOIN
							(	SELECT Machine_ID , Shift_ID, Emp_ID, MAX(Effective_Date) AS Effective_Date
								FROM T0040_Machine_Allocation_Master WITH (NOLOCK)
								WHERE Effective_Date <= @To_Date
								GROUP BY Emp_ID ,Machine_ID , Shift_ID
							)T ON T.Machine_ID = MAM.Machine_ID AND T.Effective_Date = MAM.Effective_Date and T.Emp_ID = MAM.Emp_ID					
				)T1 ON T1.Emp_ID = EC.Emp_ID
		CROSS APPLY (SELECT STUFF((SELECT	',' + MM.Machine_Name
								   FROM		T0040_Machine_Master MM WITH (NOLOCK)
								   WHERE	CHARINDEX('#' + CAST(MM.Machine_ID AS VARCHAR(10)) + '#', '#' + T1.Machine_ID + '#') > 0
											FOR XML PATH('')), 1,1,'') AS Machine_Name) TY

		IF @CONSTRAINT = '' 
			SET @CONSTRAINT = NULL
		
		IF (@constraint IS NULL )
			BEGIN
				SELECT @CONSTRAINT = COALESCE(@CONSTRAINT + '#', '') +  CAST(EC.Emp_ID AS VARCHAR(MAX)) 
				FROM #Emp_Cons EC
			END	
	
	--UPDATING SHIFT ID IN TEMP TABLE OF #NEW ALLOCATION
	EXEC P_GET_EMP_SHIFT_DETAIL @Cmp_ID = @Cmp_ID,@FROM_DATE = @From_Date,@To_Date = @To_Date,@Constraint = @constraint

	UPDATE #NEW_ALLOCATION
	SET Shift_ID = ES.Shift_ID , Shift_Name = SM.Shift_Name , 
		EFFICIENCY = MD.Efficiency , EFFICIENCY_ID = ISNULL(MD.Efficiency_ID,0) , 
		MachineEmpType = BS.MachineEmpType , Alternate_EmpID = ISNULL(MD.Alternate_Emp_ID,ES.EMP_ID)
	FROM #EMP_SHIFT ES
	INNER JOIN		#NEW_ALLOCATION NA ON ES.Emp_Id = NA.Emp_ID
	INNER JOIN		T0040_SHIFT_MASTER SM ON SM.Shift_ID = ES.Shift_ID
	INNER JOIN		T0040_BUSINESS_SEGMENT BS ON BS.Segment_ID = NA.Segment_ID
	LEFT OUTER JOIN T0100_MACHINE_DAILY_EFFICIENCY MD ON MD.Machine_ID = NA.Machine_ID AND MD.For_Date = NA.To_date AND MD.Shift_ID = NA.Shift_ID and md.Assigned_Emp_ID = NA.EMP_ID
	
		

	IF @Record_Type = ''
		BEGIN
			SELECT	* 
			FROM	#NEW_ALLOCATION
			WHERE	ISNULL(SHIFT_ID,0) = ISNULL(@shift_id , Isnull(Shift_id , 0))			
		END
	ELSE IF @Record_Type = 'All Records'
		BEGIN			
			SELECT	*
			FROM	#NEW_ALLOCATION
			WHERE	ISNULL(SHIFT_ID,0) = ISNULL(@shift_id , Isnull(Shift_id , 0)) AND Machine_ID IS NOT NULL
			ORDER BY Machine_Name 		
		END
	ELSE IF @Record_Type = 'Attendance'
		BEGIN
			EXEC P_GET_EMP_INOUT @Cmp_ID, @TO_DATE, @TO_DATE

			
			UPDATE N
			SET Alternate_EmpID = ISNULL(D.Emp_Id,0)
			FROM #NEW_ALLOCATION N
			LEFT OUTER JOIN #DATA D ON N.EMP_ID = D.EMP_ID AND N.TO_DATE = D.FOR_DATE
			
			
			SELECT	*
			FROM	#NEW_ALLOCATION N
			WHERE	ISNULL(N.SHIFT_ID,0) = ISNULL(@shift_id , Isnull(N.Shift_id , 0)) AND Machine_ID IS NOT NULL 
			ORDER BY Machine_Name 	
		END
		
RETURN



