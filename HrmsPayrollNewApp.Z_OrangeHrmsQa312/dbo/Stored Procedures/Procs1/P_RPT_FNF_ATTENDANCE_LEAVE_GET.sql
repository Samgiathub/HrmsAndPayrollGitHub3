
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_RPT_FNF_ATTENDANCE_LEAVE_GET]
	 @Cmp_ID 		numeric
	,@From_Date 	datetime
	,@To_Date 		datetime
	,@Branch_ID 	numeric
	,@Cat_ID 		numeric 
	,@Grd_ID 		numeric
	,@Type_ID 		numeric
	,@Dept_ID 		numeric
	,@Desig_ID 		numeric
	,@Emp_ID 		numeric
	,@constraint 	varchar(MAX)
	,@PBranch_ID varchar(MAX) = '0'	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	
	CREATE TABLE #EMP_CONS	  
	 (      
	   EMP_ID NUMERIC ,     
	   BRANCH_ID NUMERIC,
	   INCREMENT_ID NUMERIC    
	 )   
	 
	 EXEC SP_RPT_FILL_EMP_CONS  @CMP_ID,@FROM_DATE,@TO_DATE,@BRANCH_ID,@CAT_ID,@GRD_ID,@TYPE_ID,@DEPT_ID,@DESIG_ID ,@EMP_ID ,@CONSTRAINT ,0 ,0 ,0 ,0 ,0 ,0 
	
	
	CREATE TABLE #Leave_Detail
	(		
		Emp_Id				numeric,
		cmp_Id				numeric,
		Leave_Id			numeric,
		Leave_Name			VARCHAR(50)	COLLATE SQL_Latin1_General_CP1_CI_AS,
		Leave_Closing			NUMERIC(18,2)
	)
	CREATE TABLE #Attendance_Details
	(
		Emp_Id				numeric,
		cmp_Id				numeric,
		Present_days		NUMERIC(18,2),
		Absent_days			NUMERIC(18,2),
		Holidays			NUMERIC(18,2),
		WeekOff_days		NUMERIC(18,2),
		Leave_Days			NUMERIC(18,2),
		Working_Days		NUMERIC(18,2)
	)
	CREATE TABLE #Leave_Encash	
	(
		emp_Id					NUMERIC,
		cmp_Id					NUMERIC,
		Leave_Encash			NUMERIC(18,2),
		Leave_Name				VARCHAR(50) COLLATE SQL_LATIN1_GENERAL_CP1_CI_AS,
		Leave_Encashment_Amount	NUMERIC(18,2),
		Left_date				DATETIME	
	)
	
	
	
	Declare @Leave_ID As Numeric
	Declare @Emp_ID_Cur As Numeric
	Declare @Leave_Code As varchar(15)
	Declare @Leave_Name as Varchar(25)
	Declare @From_Date_Temp as datetime
	Declare @To_Date_Temp as datetime
	
	DECLARE @Emp_Left_Date	as DATETIME
	
	DECLARE @Qry	as VARCHAR(500)
	SET @Qry = ''
	
	Set @From_Date_Temp = @From_Date
	Set @To_Date_Temp = @To_Date
	
	Declare cur_emp cursor for 
		Select Emp_ID From #Emp_Cons 
	open cur_emp
	fetch next from Cur_Emp into @Emp_ID_Cur 
	while @@fetch_Status = 0
		begin 
			Declare cur_Leave cursor for 
				Select Top 4 Leave_ID,Leave_Code,Leave_Name from T0040_LEAVE_MASTER WITH (NOLOCK) Where Leave_Sorting_No in (0,1,2,3,4) 
							 and Cmp_ID = @CMP_ID order by Leave_sorting_no
			open cur_Leave
			fetch next from cur_Leave into @Leave_ID,@Leave_Code,@Leave_Name
			while @@fetch_Status = 0
				begin 				
									
					Insert Into #Leave_Detail (Emp_Id,Leave_Id,Cmp_ID,Leave_Name)
					
					Select @Emp_ID_Cur, @Leave_ID, @Cmp_ID, @Leave_Code		
					
					fetch next from cur_Leave into @Leave_ID,@Leave_Code,@Leave_Name
				end 
			close cur_Leave
			Deallocate cur_Leave	
			
			Select @Emp_Left_Date = Emp_Left_Date from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_ID_Cur
				
			INSERT INTO #Attendance_Details
			SELECT @Emp_ID_Cur,@Cmp_Id,Present_Days,Absent_Days,Holiday_Days,Weekoff_Days,Paid_Leave_Days,Working_Days from T0200_MONTHLY_SALARY WITH (NOLOCK)
			where	month(Month_End_Date) = month(@Emp_Left_Date) and year(Month_End_Date) = year(@Emp_Left_Date)	
					and Emp_ID = @Emp_ID_Cur
			
			
			INSERT INTO	#Leave_Encash
			SELECT	emp_Id,@Cmp_Id,sum(LEA.Lv_Encash_Apr_Days)as Leave_encash,LM.Leave_Name,
					sum(LEA.Leave_Encash_Amount)as Leave_Encash_Amount
					,@Emp_Left_Date
			from	T0120_LEAVE_ENCASH_APPROVAL LEA WITH (NOLOCK)
					LEFT JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON Lm.Leave_ID = LEA.Leave_ID and Lm.Cmp_ID = LEA.Cmp_ID
			where	Lea.Cmp_ID = @Cmp_Id and Emp_ID = @Emp_ID_Cur and LEA.Is_FNF=1
			GROUP BY LEA.Emp_ID,Leave_Name
			
			--UPDATE 	CQ
			--SET CQ.Leave_Closing = Q2.LEAVE_CLOSING
			--FROM #Leave_Detail CQ INNER JOIN 
			--(
			--	SELECT LEAVE_CLOSING,L1.EMP_ID,L1.LEAVE_ID
			--			FROM T0140_LEAVE_TRANSACTION L1 INNER JOIN
			--				 ( SELECT MAX(FOR_DATE)AS FOR_DATE,EMP_ID,LEAVE_ID
			--				   FROM T0140_LEAVE_TRANSACTION  
			--				   WHERE	CMP_ID = @Cmp_ID AND FOR_DATE <= @Emp_Left_Date AND LEAVE_ID = @LEAVE_ID
			--							and Emp_ID = @Emp_ID_Cur 
			--				   GROUP BY	EMP_ID,LEAVE_ID
			--				  )Q ON Q.EMP_ID = L1.EMP_ID AND Q.LEAVE_ID = L1.LEAVE_ID	AND L1.FOR_DATE = Q.FOR_DATE		
			--)Q2 ON Q2.EMP_ID = CQ.EMP_ID and q2.Leave_ID = CQ.Leave_Id
			
			
			fetch next from Cur_Emp into @Emp_ID_Cur 
		end 
	close cur_Emp
	Deallocate cur_Emp
	
	
		Declare cur_emp cursor for 
		Select Emp_ID From #Emp_Cons 
	open cur_emp
	fetch next from Cur_Emp into @Emp_ID_Cur 
	while @@fetch_Status = 0
		begin 
		
		Select @Emp_Left_Date = Emp_Left_Date from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_ID_Cur
						   
		UPDATE 	CQ
		SET CQ.Leave_Closing = Q2.LEAVE_CLOSING
		FROM #Leave_Detail CQ INNER JOIN 
		(
			SELECT LEAVE_CLOSING,L1.EMP_ID,L1.LEAVE_ID
					FROM T0140_LEAVE_TRANSACTION L1 WITH (NOLOCK) INNER JOIN
						 ( SELECT MAX(FOR_DATE)AS FOR_DATE,LT.EMP_ID,LT.LEAVE_ID
						   FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) INNER JOIN
								#EMP_CONS EC ON EC.EMP_ID = LT.EMP_ID
						   WHERE	CMP_ID = @Cmp_ID AND FOR_DATE <  @Emp_Left_Date --AND LEAVE_ID = @LEAVE_ID 
						   GROUP BY	LT.EMP_ID,LT.LEAVE_ID
						  )Q ON Q.EMP_ID = L1.EMP_ID AND Q.LEAVE_ID = L1.LEAVE_ID	AND L1.FOR_DATE = Q.FOR_DATE		
		)Q2 ON Q2.EMP_ID = CQ.EMP_ID and q2.Leave_ID = CQ.Leave_Id
	
			fetch next from Cur_Emp into @Emp_ID_Cur 
		end 
	close cur_Emp
	Deallocate cur_Emp
	
	
	SELECT * from #Leave_Detail										           
	SELECT * FROM #Attendance_Details	
	SELECT * FROM #Leave_Encash	
	
	drop TABLE #Leave_Detail						           
	drop TABLE #Attendance_Details
	DROP table #Leave_Encash
