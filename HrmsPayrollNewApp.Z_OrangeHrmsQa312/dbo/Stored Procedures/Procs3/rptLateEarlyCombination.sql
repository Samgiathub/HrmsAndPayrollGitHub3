				   
CREATE PROCEDURE [dbo].[rptLateEarlyCombination]
 
 @Cmp_ID		numeric  
 ,@From_Date	datetime  
 ,@To_Date		datetime   
 ,@Branch_ID	numeric  
 ,@Cat_ID		numeric   
 ,@Grd_ID		numeric  
 ,@Type_ID		numeric  
 ,@Dept_ID		numeric  
 ,@Desig_ID		numeric  
 ,@Emp_ID		numeric  
 ,@constraint	varchar(MAX)  
 ,@Flag         tinyint = 0
AS
BEGIN
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

	-- Added by Hardik 27/11/2020 for Emerland Honda, As Holiday and Weekoff tables got clear when this SP call from Attendance Consolidated Report
	DECLARE @Required_Execution BIT;
	SET @Required_Execution = 0;
	
	
	--IF @Flag = 0
	--	Begin
	--		IF OBJECT_ID('tempdb..#Emp_Cons') IS Not NULL
	--			BEGIN 		
	--				Drop Table #Emp_Cons
	--			END

	--		CREATE TABLE #Emp_Cons 
	--		(      
	--			Emp_ID numeric,     
	--			Branch_ID numeric,
	--			Increment_ID numeric    
	--		)
	--	END

		
	IF Object_ID('tempdb..#Emp_Late_Early') Is not null
		Begin
			Drop Table #Emp_Late_Early
		End

	Create Table #Emp_Late_Early
	(
		Cmp_ID Numeric,
		Emp_ID Numeric,
		For_Date Datetime,  
		In_Time  Datetime,
		Out_Time Datetime,
		Shift_St_Time Datetime,
		Shift_End_Time Datetime,
		Late_Sec Numeric,
		Early_Sec Numeric,
		Late_Limit Varchar(20),
		Early_Limit Varchar(20),
		Late_Deduction Numeric(18,2),
		Early_Deduction Numeric(18,2),
		ExemptFlag Varchar(10)
	)

	IF OBJECT_ID('tempdb..#EMP_HOLIDAY') IS NULL
		BEGIN
			CREATE TABLE #EMP_HOLIDAY(EMP_ID NUMERIC, FOR_DATE DATETIME, IS_CANCEL BIT, Is_Half tinyint, Is_P_Comp tinyint, H_DAY numeric(4,1));
			CREATE UNIQUE CLUSTERED INDEX IX_EMP_HOLIDAY_EMPID_FORDATE ON #EMP_HOLIDAY(EMP_ID, FOR_DATE);
			SET @Required_Execution =1
		END

	IF OBJECT_ID('tempdb..#Emp_WeekOff') IS NULL
		BEGIN
			CREATE TABLE #EMP_WEEKOFF
			(
				Row_ID			NUMERIC,
				Emp_ID			NUMERIC,
				For_Date		DATETIME,
				Weekoff_day		VARCHAR(20),
				W_Day			numeric(18,1),
				Is_Cancel		BIT
			)
			CREATE CLUSTERED INDEX IX_Emp_WeekOff_EmpID_ForDate ON #EMP_WEEKOFF(Emp_ID, For_Date)		
			SET @Required_Execution =1
		END
	
	CREATE table #Data
	(         
		Emp_Id   numeric ,         
		For_date datetime,        
		Duration_in_sec numeric,        
		Shift_ID numeric ,        
		Shift_Type numeric ,        
		Emp_OT  numeric ,        
		Emp_OT_min_Limit numeric,        
		Emp_OT_max_Limit numeric,        
		P_days  numeric(18,3) default 0,        
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
		--,Working_sec_Between_Shift numeric(18) default 0
	)     
	IF @Required_Execution =1
		EXEC SP_GET_HW_ALL @CONSTRAINT=@constraint,@CMP_ID=@Cmp_ID, @FROM_DATE=@FROM_DATE, @TO_DATE=@TO_DATE, @All_Weekoff = 0, @Exec_Mode=0, @Delete_Cancel_HW =0
		
		
		
	
	Exec SP_CALCULATE_PRESENT_DAYS @Cmp_ID=@Cmp_ID,@FROM_DATE=@From_Date,@TO_DATE=@To_Date,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0,@CONSTRAINT=@constraint,@Return_Record_set=4
	
	
	

	DECLARE @ABSENT_DATE_STRING VARCHAR(MAX)
	SET @ABSENT_DATE_STRING = ''
	DECLARE @WEEKOFF_DATE_STRING VARCHAR(MAX)
	SET @WEEKOFF_DATE_STRING = ''
	DECLARE @HOLIDAY_DATE_STRING VARCHAR(MAX)
	SET @HOLIDAY_DATE_STRING = ''

	DECLARE @LATE_ABSENT_DAY NUMERIC(18,2)
	SET @LATE_ABSENT_DAY = 0

	Declare @Total_LMark NUMERIC(18,2)
	SET @Total_LMark = 0

	DECLARE @INCREMENT_ID NUMERIC
	SET @INCREMENT_ID = 0

	Declare @Total_Late_Sec Numeric
	Set @Total_Late_Sec = 0

	Declare Cur_Emp Cursor For
	Select Emp_ID,Increment_ID From #Emp_Cons
	Open Cur_Emp
	Fetch Next From Cur_Emp into @Emp_ID,@INCREMENT_ID
		While @@FETCH_STATUS = 0
			Begin
				SET @ABSENT_DATE_STRING = ''
				SET @WEEKOFF_DATE_STRING = ''
				SET @HOLIDAY_DATE_STRING = ''
				SELECT @ABSENT_DATE_STRING = COALESCE(@ABSENT_DATE_STRING + '#', '') + CAST(FOR_DATE AS VARCHAR(11)) 
					FROM #DATA 
				WHERE EMP_ID = @EMP_ID AND FOR_DATE >= @FROM_DATE AND FOR_DATE <= @TO_DATE AND P_DAYS = 0

				SELECT @WEEKOFF_DATE_STRING = COALESCE(@WEEKOFF_DATE_STRING + '', ';') + CAST(FOR_DATE AS VARCHAR(11)) 
					FROM #EMP_WEEKOFF
				WHERE EMP_ID = @EMP_ID

				SELECT @HOLIDAY_DATE_STRING = COALESCE(@HOLIDAY_DATE_STRING + '', ';') + CAST(FOR_DATE AS VARCHAR(11)) 
					FROM #EMP_HOLIDAY
				WHERE EMP_ID = @EMP_ID

				--exec SP_CALCULATE_LATE_EARLY_DEDUCTION_COMBINE @Emp_ID,@Cmp_ID,@From_Date,@To_Date,@Late_Absent_Day output,@Total_LMark output,@Total_Late_Sec output,@Increment_ID,@WEEKOFF_DATE_STRING,@HOLIDAY_DATE_STRING,0,'',0,@Absent_date_String,0,1
				exec SP_CALCULATE_LATE_EARLY_DEDUCTION_COMBINE_MULTIPLE_EXEMPT @Emp_ID,@Cmp_ID,@From_Date,@To_Date,@Late_Absent_Day output,@Total_LMark output,@Total_Late_Sec output,@Increment_ID,@WEEKOFF_DATE_STRING,@HOLIDAY_DATE_STRING,0,'',0,@Absent_date_String,0,1
				
			
				Fetch Next From Cur_Emp into @Emp_ID,@INCREMENT_ID
			End
	Close Cur_Emp
	Deallocate Cur_Emp
	
	--Deepal the deduction Flag 20052022
	--Select * from #Emp_Late_Early
	--return
	update #Emp_Late_Early set ExemptFlag = 'D'
	where isnull(ExemptFlag,'') <> 'Ex'and (Late_Deduction > 0 or Early_Deduction > 0)
	--Deepal the deduction Flag 20052022

	--Select * From #Emp_Late_Early
	--return

	if object_id('tempdb..#Late_Early_Deduction') is not null and @Flag = 1
		begin
		
			Insert into #Late_Early_Deduction
			select	
											 LE.Emp_ID,
											 LE.for_date,
											 Isnull(LE.Late_Deduction,0),
											 Isnull(LE.Early_Deduction,0)
										from #Emp_Late_Early LE
			return
		end 
		IF (EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_NAME = 'ExmptTable'))
		BEGIN
			drop table ExmptTable
		END
		
create table ExmptTable(
	Alpha_Emp_Code Varchar(500),
	Emp_Full_Name  Varchar(500),
	Branch_Name    Varchar(500),
	Grd_Name	   Varchar(500),	
	Desig_Name	   Varchar(500),
	Dept_Name	   Varchar(500),
	Emp_ID	       Numeric,
	Cmp_ID	       Numeric,
	Cmp_Name	   Varchar(500),
	Cmp_Address	   Varchar(500),
	In_Time		   DateTime,	
	Out_Time	   DateTime,
	Shift_St_Time	   DateTime,
	Shift_End_Time	   DateTime,
	Late_Hours			Varchar(500),
	Early_Hours			Varchar(500),
	Late_Limit			Varchar(500),
	Early_Limit			Varchar(500),
	Late_Deduction		Varchar(500),
	Early_Deduction		Varchar(500),
	For_Date			DateTime,
	Type_Name			Varchar(500),
	Vertical_Name		Varchar(500),
	SubVertical_Name	Varchar(500),
	Branch_Address		Varchar(500),
	Comp_Name			Varchar(500) ,
	Dept_Dis_no			Varchar(400),
	From_Date			DateTime,
	To_Date				DateTime,
	ExemptFlag			Varchar(10)
)

	insert into ExmptTable
	Select 
		Alpha_Emp_Code,Emp_Full_Name,Branch_Name,Grd_Name,Desig_Name,Dept_Name,EM.Emp_ID,CM.Cmp_Id,
		CM.Cmp_Name,CM.Cmp_Address,In_Time,Out_Time,Shift_St_Time,Shift_End_Time,
		dbo.F_Return_Hours(Late_Sec) as Late_Hours,dbo.F_Return_Hours(Early_Sec) as Early_Hours,
		Late_Limit,Early_Limit,le.Late_Deduction,Early_Deduction,LE.For_Date,
		TM.Type_Name,VS.Vertical_Name,SV.SubVertical_Name,BM.Branch_Address,BM.Comp_Name,DM.Dept_Dis_no,
		@From_Date As From_Date,@To_Date as To_Date,LE.ExemptFlag
	From #Emp_Late_Early LE
	Inner join T0080_EMP_MASTER EM WITH (NOLOCK) ON LE.EMP_ID = EM.EMP_ID
	Inner Join #Emp_Cons EC ON EC.Emp_ID = LE.Emp_ID
	INNER Join T0095_INCREMENT I WITH (NOLOCK)  ON I.Increment_ID = EC.Increment_ID
	INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK)  ON BM.Branch_ID = I.Branch_ID
	INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK)  ON GM.Grd_ID = I.Grd_ID
	Left Outer Join T0040_DESIGNATION_MASTER Desig WITH (NOLOCK)  ON Desig.Desig_ID = I.Desig_Id
	Left Outer Join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK)  ON DM.Dept_Id = I.Dept_ID
	Inner join T0010_COMPANY_MASTER CM WITH (NOLOCK)  ON CM.Cmp_Id = LE.Cmp_ID
	Left Outer join T0040_TYPE_MASTER TM WITH (NOLOCK)  ON TM.Type_ID = I.Type_ID
	Left Outer Join T0040_Vertical_Segment VS WITH (NOLOCK)  ON Vs.Vertical_ID = I.Vertical_ID
	Left Outer Join T0050_SubVertical SV WITH (NOLOCK)  ON SV.SubVertical_ID = I.SubVertical_ID
		
END
