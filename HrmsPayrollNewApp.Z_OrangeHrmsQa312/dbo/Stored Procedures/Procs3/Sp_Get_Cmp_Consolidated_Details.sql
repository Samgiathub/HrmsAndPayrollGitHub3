

CREATE PROCEDURE [DBO].[Sp_Get_Cmp_Consolidated_Details]
	 @Cmp_ID 		 numeric
	,@Branch_ID 	 numeric		
	,@SubBranch_ID 	 numeric		
	,@Dept_ID 		 numeric
	,@Bus_Segment_Id numeric
	,@Sal_Cyc_Id	 numeric
	,@Desig_ID 		 numeric
	,@Vertical_Id 	 numeric
	,@SubVertical_Id numeric
	,@constraint 	 varchar(Max) = ''
	,@Month			 numeric 
	,@Year			 numeric
	,@Report_For     varchar(250) = ''
	,@IsCmpWise		 tinyint = 0
AS
BEGIN
	declare @CmpID as numeric
	declare @BranchID as numeric
	declare @SubBranchID as numeric
	declare @DeptID as numeric
	declare @BusSegmentId as numeric
	declare @SalCycId as numeric
	declare @DesigID as numeric
	declare @VerticalId as numeric
	declare @SubVerticalId as numeric
	
	set @CmpID = @Cmp_ID
	set @BranchID = @Branch_ID
	set @SubBranchID = @SubBranch_ID
	set @DeptID = @Dept_ID
	set @BusSegmentId = @Bus_Segment_Id
	set @SalCycId = @Sal_Cyc_Id
	set @DesigID = @Desig_ID
	set @VerticalId = @Vertical_Id
	set @SubVerticalId = @SubVertical_Id
	declare @chkConstraint as varchar(max)
	Set @chkConstraint = ''
	
	Declare @query as nvarchar(Max)
	Set @query = ''
	
	if @CmpID <> 0
		begin
			set @chkConstraint = @chkConstraint + ' and Cmp_ID in ('+ cast(@CmpID as varchar(30)) + ')'
		end
	 
	if @BranchID <> 0
		begin
			set @chkConstraint = @chkConstraint + ' and Branch_ID in (' + cast(@BranchID as varchar(30)) + ')'
		end
	 
	if @SubBranchID <> 0
		begin
			set @chkConstraint = @chkConstraint + ' and subBranch_ID in (' + cast(@SubBranchID as varchar(30)) + ')'
		end
	
	if @DesigID <> 0
		begin
			set @chkConstraint =  @chkConstraint + ' and Desig_Id in (' + cast(@DesigID as varchar(30)) + ')'
		end
	 
	if @DeptID <> 0
		begin
			set @chkConstraint = @chkConstraint +  ' and Dept_ID in (' + cast(@DeptID as varchar(30)) + ')'
		end
	 
	if @BusSegmentId <> 0
		begin
			set @chkConstraint = @chkConstraint + ' and Segment_ID in (' + cast(@BusSegmentId as varchar(30)) + ')'
		end
	 
	if @VerticalId <> 0
		begin
			set @chkConstraint = @chkConstraint + ' and Vertical_ID in (' + cast(@VerticalId as varchar(30)) + ')'
		end
	 
	if @SubVerticalId <> 0
		begin
			set @chkConstraint = @chkConstraint + ' and SubVertical_ID in (' + cast(@SubVerticalId as varchar(30)) + ')'
		end
	
	if @SalCycId <> 0
		begin
			set @chkConstraint = @chkConstraint + ' and SalDate_id in (' + cast(@SalCycId as varchar(30)) + ')'
		end
	 
	-- Current Month Date
	Declare @St_Date as datetime
	Set @St_Date = DATEADD(month,@Month-1,DATEADD(year,@Year-1900,0))
	Declare @End_Date as datetime
	Set @End_Date = DATEADD(day,-1,DATEADD(month,@Month,DATEADD(year,@Year-1900,0)))
	
	-- Last Month Date
	Declare @Last_St_Date as datetime
	Set @Last_St_Date = DATEADD(month,@Month-2,DATEADD(year,@Year-1900,0))
	Declare @Last_End_Date as datetime
	Set @Last_End_Date = DATEADD(day,-1,DATEADD(month,@Month-1,DATEADD(year,@Year-1900,0)))
	
	-- Current Month Date
	Declare @Cur_St_Date as datetime
	Set @Cur_St_Date = REPLACE(CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(GETDATE())-1),GETDATE()),106),' ','-')
	Declare @Cur_End_Date as datetime
	Set @Cur_End_Date = REPLACE(CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,GETDATE()))),DATEADD(mm,1,GETDATE())),106),' ','-') 
	
	Declare @Current_Date as datetime
	Set @Current_Date = Replace(Convert(varchar(30),GETDATE(),106),' ','-')
	
	Declare @Yesterday_Date as datetime
	Set @Yesterday_Date = Replace(Convert(varchar(30),DATEADD(DAY,-1,GETDATE()),106),' ','-')
	
	Declare @Date as varchar(30)
	Set @Date = '1-Jan-' +  CAST (YEAR(GETDATE()) as varchar(10))
	Declare @Date1 as varchar(30)
	Set @Date1 = '31-Dec-' + CAST (YEAR(GETDATE()) as varchar(10))
		
    -- Financial Year date
	Declare @YearSt as numeric
	Declare @YearEnd as numeric
	Set @YearSt = @Year
	Set @YearEnd = @Year
	
	IF @Month > 3
		BEGIN
			 Set @YearSt = YEAR(GETDATE())
             Set @YearEnd = YEAR(GETDATE()) + 1
		END
	ELSE
		BEGIN
			Set @YearSt = YEAR(GETDATE()) - 1
            Set @YearEnd = YEAR(GETDATE())
		END
	
	
	
	Declare @Fin_St_Date as varchar(30)
	Set @Fin_St_Date = '1-Apr-' +  CAST (@YearSt as varchar(10))
	Declare @Fin_End_Date as varchar(30)
	Set @Fin_End_Date = '31-Mar-' + CAST (@YearEnd as varchar(10))
	

	
	Declare @CmpWise table
	(
		Cmp_id numeric
		,Cmp_Name varchar(350)
		,Net_Amount numeric(18,2)
		,Actually_Gross_Salary numeric(18,2)
		,Gross_Salary numeric(18,2)	
		,Dedu_Amount	numeric(18,2)
		,EmpCnt	numeric(18,2)
		,Work_Days numeric
		,Total_Net_Amount numeric(18,2)
		,Total_Actually_Gross_Salary numeric(18,2)
		,Total_Gross_Salary numeric(18,2)	
		,Total_Dedu_Amount	numeric(18,2)
		,Total_EmpCnt	numeric(18,2)
	)
	
	Declare @OtherCount table
	(
		DoneCount  numeric  default 0,
		HoldCount  numeric default 0
	)	
	
	-- For Salary Details -------------------------------------------------------------------------------------------
	IF @Report_For = 'SAL'
	BEGIN
		IF @Cmp_ID = 0
			BEGIN
				IF @IsCmpWise = 0
					BEGIN
							Select 
							PARSENAME(Convert(varchar,Convert(Numeric(18,2),ISNULL(SUM(Net_Amount),0)),1),2) as Net_Amount
							,PARSENAME(Convert(varchar,Convert(Numeric(18,2),ISNULL(SUM(Actually_Gross_Salary),0)),1),2) as Actually_Gross_Salary 
							,PARSENAME(Convert(varchar,Convert(Numeric(18,2),ISNULL(SUM(Gross_Salary),0)),1),2) as Gross_Salary
							,PARSENAME(Convert(varchar,Convert(Numeric(18,2),ISNULL(SUM(Total_Dedu_Amount),0)),1),2) as Total_Dedu_Amount
							,COUNT(Sal_Tran_ID) as TotalEmp
							,PARSENAME(Convert(varchar,Convert(Numeric(18,2),ISNULL(MAX(Sal_Cal_Days),0)),1),2) as Work_Days
							 from T0200_MONTHLY_SALARY  WITH(NOLOCK) 
							 where Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1)  
							 And (Month_End_Date between @St_Date and @End_Date)
							 
							 Delete from @OtherCount
							 insert into @OtherCount Values (0,0)
							 Update @OtherCount Set
							 DoneCount = (select COUNT(Sal_Tran_ID) as 'Done' from T0200_MONTHLY_SALARY  WITH(NOLOCK) where UPPER(Salary_Status) = 'DONE' And (Month_End_Date between @St_Date and @End_Date) And Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1))
							 ,HoldCount = (select COUNT(Sal_Tran_ID) as 'Hold' from T0200_MONTHLY_SALARY  WITH(NOLOCK) where UPPER(Salary_Status) <> 'DONE' And (Month_End_Date between @St_Date and @End_Date) And Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1))
							 Select * from @OtherCount
					END
				ELSE
					BEGIN
							Insert into @CmpWise (Cmp_id,Cmp_Name,Net_Amount,Actually_Gross_Salary,Gross_Salary,Dedu_Amount,EmpCnt,Work_Days)
							Select MS.Cmp_ID,CM.Cmp_Name
							,ISNULL(SUM(Net_Amount),0) as Net_Amount
							,ISNULL(SUM(Actually_Gross_Salary),0) as Actually_Gross_Salary 
							,ISNULL(SUM(Gross_Salary),0) as Gross_Salary
							,ISNULL(SUM(Total_Dedu_Amount),0) as Total_Dedu_Amount
							,COUNT(Sal_Tran_ID) as TotalEmp
							,ISNULL(MAX(Sal_Cal_Days),0)as Work_Days
							 from T0200_MONTHLY_SALARY MS WITH(NOLOCK) inner join 
							 T0010_COMPANY_MASTER CM ON MS.Cmp_ID = CM.Cmp_Id   
							 where MS.Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1)  
							 And (Month_End_Date between @St_Date and @End_Date)
							 group by MS.Cmp_ID,Cmp_Name
							 
							 Update @CmpWise Set 
							 Total_Net_Amount = (Select SUM(Net_Amount)from @CmpWise),
							 Total_Actually_Gross_Salary = (Select SUM(Actually_Gross_Salary)from @CmpWise),
							 Total_Gross_Salary = (Select SUM(Gross_Salary)from @CmpWise),
							 Total_Dedu_Amount = (Select SUM(Dedu_Amount)from @CmpWise),
							 Total_EmpCnt = (Select SUM(EmpCnt)from @CmpWise)
				 
							select Cmp_id,Cmp_Name
							 ,CAST(Net_Amount as numeric) as Net_Amount
							 ,CAST(Actually_Gross_Salary as numeric) as Actually_Gross_Salary
							 ,CAST(Gross_Salary as numeric) as Gross_Salary
							 ,CAST(Dedu_Amount as numeric) as Dedu_Amount
							 ,CAST(EmpCnt as numeric) as EmpCnt
							 ,CAST(Work_Days as numeric) as Work_Days
							 ,CAST(Total_Net_Amount as numeric) as Total_Net_Amount
							 ,CAST(Total_Actually_Gross_Salary as numeric) as Total_Actually_Gross_Salary
							 ,CAST(Total_Gross_Salary as numeric) as Total_Gross_Salary
							 ,CAST(Total_Dedu_Amount as numeric) as Total_Dedu_Amount
							 ,CAST(Total_EmpCnt as numeric) as Total_EmpCnt 
							 from @CmpWise order by Cmp_Name
							
				 
					END
			END
		ELSE
			BEGIN
				IF @IsCmpWise = 0
					BEGIN			
						Set @query = N'Select PARSENAME(Convert(varchar,Convert(Numeric(18,2),ISNULL(SUM(Net_Amount),0)),1),2) as Net_Amount
						,PARSENAME(Convert(varchar,Convert(Numeric(18,2),ISNULL(SUM(Actually_Gross_Salary),0)),1),2) as Actually_Gross_Salary 
						,PARSENAME(Convert(varchar,Convert(Numeric(18,2),ISNULL(SUM(Gross_Salary),0)),1),2) as Gross_Salary
						,PARSENAME(Convert(varchar,Convert(Numeric(18,2),ISNULL(SUM(Total_Dedu_Amount),0)),1),2) as Total_Dedu_Amount
						,COUNT(Sal_Tran_ID) as TotalEmp
						,PARSENAME(Convert(varchar,Convert(Numeric(18,2),ISNULL(MAX(Sal_Cal_Days),0)),1),2) as Work_Days
						 from V_Emp_Salary_Details where (Month_End_Date between '''+ REPLACE(Convert(varchar(30),@St_Date,106),' ','-') +''' and '''+ REPLACE(Convert(varchar(30),@End_Date,106),' ','-') +''') '+ @chkConstraint+ ''
						exec (@query)
						Set @query = '' 
						
						Delete from @OtherCount
						insert @OtherCount Values (0,0)
						
						Set @query = N'
						Declare @OtherCount table
						(
							DoneCount  numeric  default 0,
							HoldCount  numeric default 0
						)
						Delete from @OtherCount
						insert @OtherCount Values (0,0)
						Update @OtherCount Set
						DoneCount = (select COUNT(Sal_Tran_ID) as ''Done'' from V_Emp_Salary_Details  WITH(NOLOCK) where UPPER(Salary_Status) = ''DONE'' And (Month_End_Date between '''+ REPLACE(Convert(varchar(30),@St_Date,106),' ','-') +''' and '''+ REPLACE(Convert(varchar(30),@End_Date,106),' ','-') +''') '+ @chkConstraint+ ' )
						,HoldCount = (select COUNT(Sal_Tran_ID) as ''Hold'' from V_Emp_Salary_Details  WITH(NOLOCK) where UPPER(Salary_Status) <> ''DONE'' And (Month_End_Date between '''+ REPLACE(Convert(varchar(30),@St_Date,106),' ','-') +''' and '''+ REPLACE(Convert(varchar(30),@End_Date,106),' ','-') +''') '+ @chkConstraint+ ' )
						Select * from @OtherCount'
						
						--select @query		 
						exec (@query)			
						Set @query = '' 
					End
				ELSE
					BEGIN	
					
						Set @chkConstraint = ''
						if @CmpID <> 0
							begin
								set @chkConstraint = @chkConstraint + ' and MS.Cmp_ID in ('+ cast(@CmpID as varchar(30)) + ')'
							end
		 
						if @BranchID <> 0
							begin
								set @chkConstraint = @chkConstraint + ' and Branch_ID in (' + cast(@BranchID as varchar(30)) + ')'
							end
						 
						if @SubBranchID <> 0
							begin
								set @chkConstraint = @chkConstraint + ' and subBranch_ID in (' + cast(@SubBranchID as varchar(30)) + ')'
							end
						
						if @DesigID <> 0
							begin
								set @chkConstraint =  @chkConstraint + ' and Desig_Id in (' + cast(@DesigID as varchar(30)) + ')'
							end
						 
						if @DeptID <> 0
							begin
								set @chkConstraint = @chkConstraint +  ' and Dept_ID in (' + cast(@DeptID as varchar(30)) + ')'
							end
						 
						if @BusSegmentId <> 0
							begin
								set @chkConstraint = @chkConstraint + ' and Segment_ID in (' + cast(@BusSegmentId as varchar(30)) + ')'
							end
						 
						if @VerticalId <> 0
							begin
								set @chkConstraint = @chkConstraint + ' and Vertical_ID in (' + cast(@VerticalId as varchar(30)) + ')'
							end
						 
						if @SubVerticalId <> 0
							begin
								set @chkConstraint = @chkConstraint + ' and SubVertical_ID in (' + cast(@SubVerticalId as varchar(30)) + ')'
							end
						
						if @SalCycId <> 0
							begin
								set @chkConstraint = @chkConstraint + ' and SalDate_id in (' + cast(@SalCycId as varchar(30)) + ')'
							end
			
			
						Set @query = N'Declare @CmpWise table
							( Cmp_id numeric,Cmp_Name varchar(350),Net_Amount numeric(18,2),Actually_Gross_Salary numeric(18,2),Gross_Salary numeric(18,2),Dedu_Amount	numeric(18,2),EmpCnt	numeric(18,2),Work_Days numeric,Total_Net_Amount numeric(18,2),Total_Actually_Gross_Salary numeric(18,2),Total_Gross_Salary numeric(18,2)	,Total_Dedu_Amount	numeric(18,2),Total_EmpCnt	numeric(18,2) )
							
							Insert into @CmpWise (Cmp_id,Cmp_Name,Net_Amount,Actually_Gross_Salary,Gross_Salary,Dedu_Amount,EmpCnt,Work_Days)
							Select MS.Cmp_ID,CM.Cmp_Name
							,ISNULL(SUM(Net_Amount),0) as Net_Amount,ISNULL(SUM(Actually_Gross_Salary),0) as Actually_Gross_Salary ,ISNULL(SUM(Gross_Salary),0) as Gross_Salary
							,ISNULL(SUM(Total_Dedu_Amount),0) as Total_Dedu_Amount,COUNT(Sal_Tran_ID) as TotalEmp,ISNULL(MAX(Sal_Cal_Days),0)as Work_Days
							 from V_Emp_Salary_Details MS WITH(NOLOCK) inner join T0010_COMPANY_MASTER CM ON MS.Cmp_ID = CM.Cmp_Id   
							 where (Month_End_Date between '''+ REPLACE(Convert(varchar(30),@St_Date,106),' ','-') +''' and '''+ REPLACE(Convert(varchar(30),@End_Date,106),' ','-') +''')
							 '+ @chkConstraint +' group by MS.Cmp_ID,Cmp_Name
							 
							 Update @CmpWise Set Total_Net_Amount = (Select SUM(Net_Amount)from @CmpWise),
							 Total_Actually_Gross_Salary = (Select SUM(Actually_Gross_Salary)from @CmpWise),
							 Total_Gross_Salary = (Select SUM(Gross_Salary)from @CmpWise),
							 Total_Dedu_Amount = (Select SUM(Dedu_Amount)from @CmpWise),
							 Total_EmpCnt = (Select SUM(EmpCnt)from @CmpWise)
				 
							 select Cmp_id,Cmp_Name
							 ,CAST(Net_Amount as numeric) as Net_Amount,CAST(Actually_Gross_Salary as numeric) as Actually_Gross_Salary
							 ,CAST(Gross_Salary as numeric) as Gross_Salary,CAST(Dedu_Amount as numeric) as Dedu_Amount
							 ,CAST(EmpCnt as numeric) as EmpCnt,CAST(Work_Days as numeric) as Work_Days
							 ,CAST(Total_Net_Amount as numeric) as Total_Net_Amount,CAST(Total_Actually_Gross_Salary as numeric) as Total_Actually_Gross_Salary
							 ,CAST(Total_Gross_Salary as numeric) as Total_Gross_Salary,CAST(Total_Dedu_Amount as numeric) as Total_Dedu_Amount
							 ,CAST(Total_EmpCnt as numeric) as Total_EmpCnt from @CmpWise'
							 
							--select @query		 
							exec (@query)			
							Set @query = '' 
					END	
			END
	END	
	
	-- For Employee Details -----------------------------------------------------------------------------------------
	IF @Report_For = 'EMP'
		BEGIN
			IF @CmpID = 0
				BEGIN
						-- New Joining
						select Emp_Full_Name + ' - ' + Alpha_Emp_Code as 'Emp_Name'
						,CASE WHEN DATEDIFF(MONTH,Date_Of_Join , GETDATE()) = 0 THEN 'This Month' ELSE CAST(DATEDIFF(MONTH,Date_Of_Join , GETDATE()) as varchar(20)) + ' Month ago' END as  Data
						,Date_Of_Join from T0080_EMP_MASTER where (Date_Of_Join between @St_Date And @End_Date )
						And Emp_Left = 'N' And Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1) order by Emp_Full_Name

						-- Resigned 
						select Emp_Full_Name + ' - ' + Alpha_Emp_Code as 'Emp_Name'
						,CASE WHEN DATEDIFF(MONTH,Emp_Left_Date , GETDATE()) = 0 THEN 'This Month' ELSE CAST(DATEDIFF(MONTH,Emp_Left_Date , GETDATE()) as varchar(20)) + ' Month ago' END as Data
						,Emp_Left_Date from T0080_EMP_MASTER  where (Emp_Left_Date between @St_Date And @End_Date )
						And Emp_Left <> 'N' And Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1) order by Emp_Full_Name

						-- Upcoming Birthday
						select Emp_Full_Name + ' - ' + Alpha_Emp_Code as 'Emp_Name' 
						,REPLACE((cast(Day(Date_Of_Birth) as varchar(3)) + '-' + Left(dbo.F_GET_MONTH_NAME(Month(Date_Of_Birth)),3)),'-',' ') As Data
						,Date_Of_Birth from T0080_EMP_MASTER  where MONTH(Date_Of_Birth) = MONTH(@End_Date) And Emp_Left = 'N'
						And Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1) 
						And DAY(@End_Date) >= DAY(@End_Date) order by Emp_Full_Name 

						-- Upcoming Joining Anniversary
						select Emp_Full_Name + ' - ' + Alpha_Emp_Code as 'Emp_Name' 						
						,REPLACE((cast(Day(Date_Of_Join) as varchar(3)) + '-' + Left(dbo.F_GET_MONTH_NAME(Month(Date_Of_Join)),3)),'-',' ') + ' ( ' +  CAST(DATEDIFF(YEAR,Date_Of_Join,GETDATE()) as varchar(10))  + ' Year )'   As Data
						,Date_Of_Join from T0080_EMP_MASTER  where MONTH(Date_Of_Join) = MONTH(@St_Date)
						And Emp_Left = 'N' AND YEAR(Date_Of_Join) < YEAR(@End_Date)
						And Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1) 
						And DAY(Date_Of_Join) >= DAY(@End_Date) order by Emp_Full_Name
				END
				
		END
	
	-- For Attendace Details ----------------------------------------------------------------------------------------
	IF @Report_For = 'ATTN'
		BEGIN
			Declare @EmpAttendace table
			(
				Emp_ID numeric,
				Emp_full_Name varchar(350),
				Alpha_Emp_Code varchar(200),
				Total_Work_sec numeric(18,2),
				Total_Work_Hours numeric(18,2),
				Required_Hrs_Till_date	numeric(18,2),
				Total_Required_Hours_Till_Date	numeric(18,2),
				Achieved_Sec numeric(18,2),	
				Achieved_Hours	numeric(18,2),
				Short_Sec	numeric(18,2),
				Short_Hours	numeric(18,2),
				Total_More_Work_sec	numeric(18,2),
				Total_More_Work_Hours	numeric(18,2),
				P_From_date	 datetime,
				P_To_Date datetime
			)
			
			DECLARE @TempCmpId numeric
			DECLARE L_Master CURSOR FOR  Select Cmp_Id from T0010_COMPANY_MASTER where is_GroupOFCmp = 1 
			OPEN L_Master
			FETCH NEXT FROM L_Master INTO @TempCmpId
			WHILE @@FETCH_STATUS = 0
			BEGIN
					
					insert into @EmpAttendace
					exec P_InOut_Record_IN_CMP_Consol @Cmp_ID=@TempCmpId,@From_Date=@St_Date,@To_Date=@End_Date
					,@Branch_ID=@Branch_ID ,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=@Dept_ID
					,@Desig_ID=@Desig_ID,@Emp_ID =0,@Constraint='',@Report_call='SUMMARY_Attendance'
					
			   FETCH NEXT FROM L_Master INTO @TempCmpId 
			END
			CLOSE L_Master
			DEALLOCATE L_Master
			
			
			IF @IsCmpWise = 0
				BEGIN
					select COUNT(Emp_id) as EmpCnt
					,PARSENAME(Convert(varchar,Convert(Numeric(18,2),ISNULL(SUM(Total_Work_Hours),0)),1),2)   as Sum_Total_Work_Hours 
					,PARSENAME(Convert(varchar,Convert(Numeric(18,2),ISNULL(SUM(Required_Hrs_Till_date),0)),1),2)   as Sum_Required_Hrs_Till_date
					,PARSENAME(Convert(varchar,Convert(Numeric(18,2),ISNULL(SUM(Total_Required_Hours_Till_Date),0)),1),2)   as Total_Required_Hours_Till_Date
					,PARSENAME(Convert(varchar,Convert(Numeric(18,2),ISNULL(SUM(Achieved_Hours),0)),1),2) as   Sum_Achieved_Hours
					,PARSENAME(Convert(varchar,Convert(Numeric(18,2),ISNULL(SUM(Short_Hours),0)),1),2) as  Sum_Short_Hours
					,PARSENAME(Convert(varchar,Convert(Numeric(18,2),ISNULL(SUM(Total_More_Work_Hours),0)),1),2) as   Total_More_Work_Hours			
					from @EmpAttendace
		
				END
			ELSE
				BEGIN					
					
					Declare @EmpAttendaceTemp table
					(
						Emp_ID numeric,
						Emp_full_Name varchar(350),
						Alpha_Emp_Code varchar(200),
						Total_Work_sec numeric(18,2),
						Total_Work_Hours numeric(18,2),
						Required_Hrs_Till_date	numeric(18,2),
						Total_Required_Hours_Till_Date	numeric(18,2),
						Achieved_Sec numeric(18,2),	
						Achieved_Hours	numeric(18,2),
						Short_Sec	numeric(18,2),
						Short_Hours	numeric(18,2),
						Total_More_Work_sec	numeric(18,2),
						Total_More_Work_Hours	numeric(18,2),
						P_From_date	 datetime,
						P_To_Date datetime,
						Cmp_Id numeric						
					)
										
					INSERT INTO @EmpAttendaceTemp 
						Select A.*,E.Cmp_ID
						from @EmpAttendace A inner join
						T0080_EMP_MASTER E ON E.Emp_ID = A.Emp_ID
						
						
					DECLARE @CmpWiseAttendace Table
					(
						Cmp_Id numeric,	
						EmpCnt Numeric,
						Total_Work_Hours numeric(18,2),
						Required_Hrs_Till_date numeric(18,2),
						Achieved_Hours	numeric(18,2),
						Cmp_Name varchar(350),
						Cmp_Wise_Total_Work_Hours numeric(18,2),
						Cmp_Wise_Required_Hrs_Till_date numeric(18,2),
						Cmp_Wise_Achieved_Hours numeric(18,2),
						Total_EmpCnt numeric						
					)
	
					INSERT INTO @CmpWiseAttendace
					Select *,(Select Cmp_Name from T0010_COMPANY_MASTER where Cmp_Id=temp.Cmp_Id) as Cmp_Name 
					,0,0,0,0  from (		
					Select Cmp_Id,COUNT(Emp_ID) EmpCnt 
					,ISNULL(SUM(Total_Work_Hours),0) as Total_Work_Hours
					,ISNULL(SUM(Required_Hrs_Till_date),0) as Required_Hrs_Till_date					
					,ISNULL(SUM(Achieved_Hours),0) as Achieved_Hours
					--,PARSENAME(Convert(varchar,Convert(Numeric(18,2),ISNULL(SUM(Short_Hours),0)),1),2) as  Sum_Short_Hours
					--,PARSENAME(Convert(varchar,Convert(Numeric(18,2),ISNULL(SUM(Total_More_Work_Hours),0)),1),2) as   Total_More_Work_Hours
					 from @EmpAttendaceTemp group by Cmp_Id ) as temp
					 
					 
					 Update @CmpWiseAttendace 
					 Set Cmp_Wise_Total_Work_Hours = (Select SUM(Total_Work_Hours) from @CmpWiseAttendace)
					 ,Cmp_Wise_Required_Hrs_Till_date = (Select SUM(Required_Hrs_Till_date) from @CmpWiseAttendace)
					 ,Cmp_Wise_Achieved_Hours = (Select SUM(Achieved_Hours) from @CmpWiseAttendace)
					 ,Total_EmpCnt = (Select SUM(EmpCnt) from @CmpWiseAttendace)
					 
					Select Cmp_Id,Cmp_Name,EmpCnt
					,CAST(Total_Work_Hours as numeric) as Total_Work_Hours
					,CAST(Required_Hrs_Till_date as numeric) as Required_Hrs_Till_date
					,CAST(Achieved_Hours as numeric) as Achieved_Hours
					,CAST(Cmp_Wise_Total_Work_Hours as numeric) as Cmp_Wise_Total_Work_Hours
					,CAST(Cmp_Wise_Required_Hrs_Till_date as numeric) as Cmp_Wise_Required_Hrs_Till_date 
					,CAST(Cmp_Wise_Achieved_Hours as numeric) as Cmp_Wise_Achieved_Hours
					,CAST(Total_EmpCnt as numeric) as Total_EmpCnt
					from @CmpWiseAttendace order by Cmp_Name
				
					 
					 
				END
			
		END
		
	IF @Report_For = 'LEAV'
		BEGIN
			IF @IsCmpWise = 0
				BEGIN
						Declare @Leave_Application as numeric
						Select @Leave_Application = COUNT(*) from (
						Select Cmp_ID,Leave_ID,Leave_Period,Leave_Assign_As,Emp_id,Leave_Name,Emp_Full_Name 
						from V0110_Leave_Application_Detail where (To_Date <= @End_Date AND From_Date >= @St_Date) 
						and Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1)
						UNION ALL
						select La.Cmp_ID,LAD.Leave_ID,Leave_Period,Leave_Assign_As,La.Emp_ID,Leave_Name,Emp_Full_Name   
						from T0120_Leave_Approval LA inner join 
						T0130_Leave_Approval_Detail LAD on LA.leave_approval_id=LAD.leave_approval_id  
						Left outer join T0080_EMP_MASTER E on La.Emp_ID =e.Emp_ID
						left outer join T0040_LEAVE_MASTER LM on LM.Leave_ID = LAD.Leave_ID
						where LAD.Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1) 
						AND (To_Date <= @End_Date AND From_Date >= @St_Date) AND ISNULL(LA.Leave_Application_ID,0)= 0 ) as temp

						Declare @Leave_Approval as numeric
						Select @Leave_Approval = COUNT(*) from (
						Select La.Cmp_ID,LAD.Leave_ID,Leave_Period,Leave_Assign_As,La.Emp_ID,Leave_Name,Emp_Full_Name  
						from T0120_Leave_Approval LA inner join T0130_Leave_Approval_Detail LAD on LA.leave_approval_id=LAD.leave_approval_id  
						Left outer join T0080_EMP_MASTER E on La.Emp_ID =e.Emp_ID
						left outer join T0040_LEAVE_MASTER LM on LM.Leave_ID = LAD.Leave_ID
						where LAD.Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1) 
						AND (To_Date <= @End_Date AND From_Date >= @St_Date) And LA.Approval_Status = 'A') as temp

						Declare @Leave_Reject as numeric
						Select @Leave_Reject = COUNT(*) from (
						select La.Cmp_ID,LAD.Leave_ID,Leave_Period,Leave_Assign_As,La.Emp_ID,Leave_Name,Emp_Full_Name  
						from T0120_Leave_Approval LA inner join T0130_Leave_Approval_Detail LAD on LA.leave_approval_id=LAD.leave_approval_id  
						Left outer join T0080_EMP_MASTER E on La.Emp_ID =e.Emp_ID
						left outer join T0040_LEAVE_MASTER LM on LM.Leave_ID = LAD.Leave_ID
						where LAD.Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1) AND (To_Date <= @End_Date AND From_Date >= @St_Date)
						And LA.Approval_Status = 'R') as temp

						Declare @Leave_Pending as numeric
						Select @Leave_Pending = COUNT(*) from (
						Select La.Cmp_ID,LAD.Leave_ID,Leave_Period,Leave_Assign_As,La.Emp_ID,Leave_Name,Emp_Full_Name 
						from T0110_LEAVE_APPLICATION_DETAIL LAD INNER JOIN 
						T0100_LEAVE_APPLICATION LA ON La.Leave_Application_ID = LAD.Leave_Application_ID
						Left outer join T0080_EMP_MASTER E on La.Emp_ID =e.Emp_ID
						left outer join T0040_LEAVE_MASTER LM on LM.Leave_ID = LAD.Leave_ID
						where LAD.Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1) 
						AND (To_Date <= @End_Date AND From_Date >= @St_Date) and La.Application_Status = 'P') as temp
									
						Declare @AmtOfPaidLeave as numeric
						Select @AmtOfPaidLeave =  PARSENAME(Convert(varchar,Convert(Numeric(18,2),ISNULL(SUM(Leave_Salary_Amount),0)),1),2)
						from T0200_MONTHLY_SALARY  WITH(NOLOCK)
						where Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1) And (Month_End_Date between @Last_St_Date and @Last_End_Date)
									

						select @Leave_Application as 'Leave_Application'
							,@Leave_Approval as 'Leave_Approval'
							,@Leave_Reject as 'Leave_Reject'
							,@Leave_Pending as 'Leave_Pending'
							,@AmtOfPaidLeave as 'AmtOfPaidLeave'

				END
			ELSE
				BEGIN
						Declare @LeaveTable table
						(Cmp_ID	numeric,Leave_ID numeric,Leave_Period numeric(18,2),Leave_Assign_As varchar(150),Emp_id numeric,Leave_Name varchar(200),Emp_Full_Name varchar(350),Type varchar(100))

						insert into @LeaveTable
							Select * from (						
							Select Cmp_ID,Leave_ID,Leave_Period,Leave_Assign_As,Emp_id,Leave_Name,Emp_Full_Name,'AP' as Type 
							from V0110_Leave_Application_Detail where (To_Date <= @End_Date AND From_Date >= @St_Date) 
							and Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1)
							UNION ALL
							select La.Cmp_ID,LAD.Leave_ID,Leave_Period,Leave_Assign_As,La.Emp_ID,Leave_Name,Emp_Full_Name,'AP' as Type    
							from T0120_Leave_Approval LA inner join 
							T0130_Leave_Approval_Detail LAD on LA.leave_approval_id=LAD.leave_approval_id  
							Left outer join T0080_EMP_MASTER E on La.Emp_ID =e.Emp_ID
							left outer join T0040_LEAVE_MASTER LM on LM.Leave_ID = LAD.Leave_ID
							where LAD.Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1) 
							AND (To_Date <= @End_Date AND From_Date >= @St_Date) AND ISNULL(LA.Leave_Application_ID,0)= 0 
								
							UNION ALL
								
							Select La.Cmp_ID,LAD.Leave_ID,Leave_Period,Leave_Assign_As,La.Emp_ID,Leave_Name,Emp_Full_Name,'A'  as Type
							from T0120_Leave_Approval LA inner join T0130_Leave_Approval_Detail LAD on LA.leave_approval_id=LAD.leave_approval_id  
							Left outer join T0080_EMP_MASTER E on La.Emp_ID =e.Emp_ID
							left outer join T0040_LEAVE_MASTER LM on LM.Leave_ID = LAD.Leave_ID
							where LAD.Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1) 
							AND (To_Date <= @End_Date AND From_Date >= @St_Date) And LA.Approval_Status = 'A'

							UNION ALL
								
							select La.Cmp_ID,LAD.Leave_ID,Leave_Period,Leave_Assign_As,La.Emp_ID,Leave_Name,Emp_Full_Name,'R' as Type  
							from T0120_Leave_Approval LA inner join T0130_Leave_Approval_Detail LAD on LA.leave_approval_id=LAD.leave_approval_id  
							Left outer join T0080_EMP_MASTER E on La.Emp_ID =e.Emp_ID
							left outer join T0040_LEAVE_MASTER LM on LM.Leave_ID = LAD.Leave_ID
							where LAD.Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1) AND (To_Date <= @End_Date AND From_Date >= @St_Date)
							And LA.Approval_Status = 'R'

							UNION ALL
								
							Select La.Cmp_ID,LAD.Leave_ID,Leave_Period,Leave_Assign_As,La.Emp_ID,Leave_Name,Emp_Full_Name,'P' as Type
							from T0110_LEAVE_APPLICATION_DETAIL LAD INNER JOIN 
							T0100_LEAVE_APPLICATION LA ON La.Leave_Application_ID = LAD.Leave_Application_ID
							Left outer join T0080_EMP_MASTER E on La.Emp_ID =e.Emp_ID
							left outer join T0040_LEAVE_MASTER LM on LM.Leave_ID = LAD.Leave_ID
							where LAD.Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1) 
							AND (To_Date <= @End_Date AND From_Date >= @St_Date) and La.Application_Status = 'P' 
						) as temp			
		
						Declare @LeaveCmpWise table
						(Cmp_id numeric,Cmp_Name varchar(350),ApplicationCnt numeric default 0,ApprovalCnt numeric default 0,RejectCnt numeric default 0,PendingCnt numeric default 0,Total_ApplicationCnt numeric default 0,Total_ApprovalCnt numeric default 0,Total_RejectCnt numeric default 0,Total_PendingCnt numeric default 0)
				
						Insert into @LeaveCmpWise (Cmp_id)
						Select Cmp_ID from  @LeaveTable
						group by Cmp_ID

						Declare @ApplicationTable Table( Cmp_Id numeric,Cnt numeric )
						Insert into @ApplicationTable
						Select Cmp_ID,COUNT(Type)  Cnt from @LeaveTable where type = 'AP' group by Cmp_ID 
						Declare @ApprovalTable Table( Cmp_Id numeric,Cnt numeric )
						Insert into @ApprovalTable
						Select Cmp_ID,COUNT(Type)  Cnt from @LeaveTable where type = 'A' group by Cmp_ID 
						Declare @PendingTable Table( Cmp_Id numeric,Cnt numeric )
						Insert into @PendingTable
						Select Cmp_ID,COUNT(Type)  Cnt from @LeaveTable where type = 'P' group by Cmp_ID 
						Declare @RejectTable Table( Cmp_Id numeric,Cnt numeric )
						Insert into @RejectTable
						Select Cmp_ID,COUNT(Type)  Cnt from @LeaveTable where type = 'R' group by Cmp_ID 
				

						Update @LeaveCmpWise Set Cmp_Name = 
							A.Cmp_Name from T0010_COMPANY_MASTER A
								inner join @LeaveCmpWise L on L.Cmp_id = A.Cmp_Id
								
						Update @LeaveCmpWise Set ApplicationCnt = 
							Cnt from @ApplicationTable A
								inner join @LeaveCmpWise L on L.Cmp_id = A.Cmp_Id
								
						Update @LeaveCmpWise Set ApprovalCnt = 
							Cnt from @ApprovalTable A
								inner join @LeaveCmpWise L on L.Cmp_id = A.Cmp_Id				
						
						Update @LeaveCmpWise Set PendingCnt = 
							Cnt from @PendingTable A
								inner join @LeaveCmpWise L on L.Cmp_id = A.Cmp_Id
								
						Update @LeaveCmpWise Set RejectCnt = 
							Cnt from @RejectTable A
								inner join @LeaveCmpWise L on L.Cmp_id = A.Cmp_Id
						
						
						Update @LeaveCmpWise 
						Set Total_ApplicationCnt = (Select SUM(ApplicationCnt) FROM @LeaveCmpWise)
						,Total_ApprovalCnt = (Select SUM(ApprovalCnt) FROM @LeaveCmpWise)
						,Total_RejectCnt = (Select SUM(RejectCnt) FROM @LeaveCmpWise)
						,Total_PendingCnt = (Select SUM(PendingCnt) FROM @LeaveCmpWise)
						 
						select * from @LeaveCmpWise
				END	
		END
		
	IF @Report_For = 'EALT'
		BEGIN
			
					DECLARE @EarlyLateCout TABLE  
					(  
						   Emp_id				numeric ,      
						   Emp_full_Name		varchar(350),
						   Total_Work_sec		numeric  null,      
						   Shift_Sec			numeric null,      
						   Late_In_Sec			numeric null, 
						   Early_Out_sec		numeric null, 
						   Total_More_Work_Sec	numeric Null, 
						   Late_In_count		numeric null,      
						   Early_Out_Count		numeric null,      
						   Total_Work_Hours		varchar(20),
						   Late_in_Hours		varchar(20),
						   Early_Out_Hours		 varchar(20),
						   Total_More_Work_Hours varchar(20),
						   Total_Less_Work_Hours varchar(20),
						   Cmp_Id				numeric default 0
					) 
						
					Declare @TempCmp_Id as numeric
					Set @TempCmp_Id = 0
					DECLARE db_cursor CURSOR FOR  
						Select Cmp_Id from T0010_COMPANY_MASTER where is_GroupOFCmp = 1
					OPEN db_cursor   
					FETCH NEXT FROM db_cursor INTO @TempCmp_Id  
					WHILE @@FETCH_STATUS = 0  
					BEGIN  
					
							INSERT INTO @EarlyLateCout (Emp_id,Emp_full_Name,Total_Work_sec,Shift_Sec,Late_In_Sec,Early_Out_sec,Total_More_Work_Sec,Late_In_count,Early_Out_Count,Total_Work_Hours,Late_in_Hours,Early_Out_Hours,Total_More_Work_Hours,Total_Less_Work_Hours)
							exec P_InOut_Record_IN_CMP_Consol @Cmp_ID = @TempCmp_Id
							,@From_Date = @St_Date ,@To_Date = @End_Date
							,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0
							,@Constraint='',@Report_Call='SUMMARY',@PBranch_ID='0'
							,@SubBranch_Id = 0,@BusSegement_Id = 0 
							,@SalCyc_Id = 0,@Vertical_Id = 0,@SubVertical_Id =0
					
					
						   FETCH NEXT FROM db_cursor INTO @TempCmp_Id  
					END  
					CLOSE db_cursor  
					DEALLOCATE db_cursor
					
					Update @EarlyLateCout 
						Set Cmp_Id = EM.Cmp_ID from @EarlyLateCout E
											Inner join T0080_EMP_MASTER EM on 
											EM.Emp_ID = E.Emp_id
			IF @IsCmpWise = 0
				BEGIN
						Declare @EmpCnt numeric
						Declare @Late_In_Cnt  numeric
						Declare @Early_Out_Cnt  numeric
						Declare @Late_In_Hrs numeric
						Declare @Early_Out_Hrs numeric
						
						Select @EmpCnt = COUNT(Emp_id) from @EarlyLateCout where (Late_In_count > 0 or Early_Out_Count > 0)
						Select @Late_In_Cnt = SUM(Late_In_count) from @EarlyLateCout
						Select @Early_Out_Cnt = SUM(Early_Out_Count) from @EarlyLateCout
						Select @Late_In_Hrs = SUM(Late_In_Sec) from @EarlyLateCout
						Select @Early_Out_Hrs = SUM(Early_Out_sec) from @EarlyLateCout
																		
						Select @EmpCnt as 'EmpCnt'
							   ,@Late_In_Cnt as  'Late_In_Cnt'
							   ,@Early_Out_Cnt as 'Early_Out_Cnt'
							   ,dbo.F_Return_Hours(@Late_In_Hrs) as 'Late_In_Hrs'
							   ,dbo.F_Return_Hours(@Early_Out_Hrs) as 'Early_Out_Hrs'
											
				END	
			ELSE
				BEGIN
						Declare @EarlyLateCmpWise Table
						( Cmp_Id numeric, Cmp_Name varchar(350), Late_In_Cnt numeric default 0 , Early_Out_Cnt numeric default 0,Emp_Cnt numeric default 0, Total_Late_In_Cnt numeric default 0, Total_Early_Out_Cnt numeric default 0,Total_Emp_Cnt numeric default 0)
						
						Insert into @EarlyLateCmpWise (Cmp_Id)
							Select Cmp_id from @EarlyLateCout group by Cmp_ID
						
						Update @EarlyLateCmpWise 
							Set Cmp_Name = CM.Cmp_Name from @EarlyLateCmpWise A
							Inner join T0010_COMPANY_MASTER CM ON A.Cmp_Id = CM.Cmp_Id
							
						
						Declare @LateTable table ( Cmp_Id numeric, Cnt numeric)
						insert into @LateTable
						Select Cmp_Id,SUM(Late_In_count) Cnt from @EarlyLateCout where Late_In_count > 0
						group by Cmp_Id
						
						Declare @EarlyTable table ( Cmp_Id numeric, Cnt numeric)
						insert into @EarlyTable
						Select Cmp_Id,SUM(Early_Out_Count) Cnt from @EarlyLateCout where Early_Out_Count > 0
						group by Cmp_Id
						
						Declare @EmpCount table ( Cmp_Id numeric, Cnt numeric)
						insert into @EmpCount
						Select Cmp_Id,COUNT(Emp_id) Cnt from @EarlyLateCout where (Early_Out_Count > 0 or Late_In_count > 0)
						group by Cmp_Id
						
							
						Update @EarlyLateCmpWise Set Late_In_Cnt = 
							Cnt from @LateTable A
								inner join @EarlyLateCmpWise L on L.Cmp_id = A.Cmp_Id
								
						Update @EarlyLateCmpWise Set Early_Out_Cnt = 
							Cnt from @EarlyTable A
								inner join @EarlyLateCmpWise L on L.Cmp_id = A.Cmp_Id
								
						Update @EarlyLateCmpWise Set Emp_Cnt = 
							Cnt from @EmpCount A
								inner join @EarlyLateCmpWise L on L.Cmp_id = A.Cmp_Id
								
						Update @EarlyLateCmpWise 
							Set Total_Late_In_Cnt = (Select SUM(Late_In_Cnt) from @EarlyLateCmpWise)
							,Total_Early_Out_Cnt = (Select SUM(Early_Out_Cnt) from @EarlyLateCmpWise)
							,Total_Emp_Cnt = (Select SUM(Emp_Cnt) from @EarlyLateCmpWise)
						
						Select * from @EarlyLateCmpWise where (Late_In_Cnt > 0 or Early_Out_Cnt > 0)
				END
				
		END
		
	IF @Report_For = 'LON'
		BEGIN
			IF @IsCmpWise = 0
				BEGIN
						Declare @CntEmp as numeric
						Declare @NxtMonthLoan as numeric
						Declare @LoanFinished as numeric
						Declare @TotalEMI as numeric
						Set @CntEmp = 0
						Set @NxtMonthLoan = 0
						Set @LoanFinished = 0
						Set @TotalEMI = 0
						
						
				Set @CntEmp = (Select SUM(Cnt) as Cnt from (
					select COUNT(LPR.Emp_ID) as Cnt from T0100_LOAN_APPLICATION LA inner join 
					T0120_LOAN_APPROVAL LPR On LA.Loan_App_ID = LPR.Loan_App_ID 
					where LA.Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1)
					and Loan_Apr_Status = 'A' And (Loan_Apr_Date between @Fin_St_Date and @Fin_End_Date)
						UNION ALL
					select COUNT(Emp_ID) as Cnt from T0120_LOAN_APPROVAL 
					where Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1)
					and (Loan_Apr_Date between @Fin_St_Date and @Fin_End_Date)
					And ISNULL(Loan_App_ID,0)  = 0 ) as temp )
					
				Set @NxtMonthLoan =  (select COUNT(Emp_ID) as Cnt from (
					select CASE WHEN Deduction_Type = 'Monthly' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
					WHEN Deduction_Type = 'Quaterly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
					WHEN Deduction_Type = 'Half Yearly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
					ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END as Finish_date
					,Loan_Apr_Date,Loan_Apr_No_of_Installment,Deduction_Type,Emp_ID,Cmp_ID from T0120_LOAN_APPROVAL 
					where Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1)
					and (Loan_Apr_Date between @Fin_St_Date and @Fin_End_Date)
					And ISNULL(Loan_App_ID,0)  = 0
						UNION ALL
					select CASE WHEN Deduction_Type = 'Monthly' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
					WHEN Deduction_Type = 'Quaterly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
					WHEN Deduction_Type = 'Half Yearly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
					ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END as Finish_date
					,Loan_Apr_Date,Loan_Apr_No_of_Installment,Deduction_Type,LA.Emp_ID,La.Cmp_ID from T0100_LOAN_APPLICATION LA inner join 
					T0120_LOAN_APPROVAL LPR On LA.Loan_App_ID = LPR.Loan_App_ID 
					where LA.Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1)
					and Loan_Apr_Status = 'A' And (Loan_Apr_Date between @Fin_St_Date and @Fin_End_Date)
					) as temp where MONTH(Finish_date) = @Month + 1 AND YEAR(Finish_date) = @Year
					And (Finish_date between @Fin_St_Date and @Fin_End_Date))
				Set @LoanFinished =  (select COUNT(Emp_ID) as Cnt from (
					select CASE WHEN Deduction_Type = 'Monthly' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
					WHEN Deduction_Type = 'Quaterly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
					WHEN Deduction_Type = 'Half Yearly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
					ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END as Finish_date
					,Loan_Apr_Date,Loan_Apr_No_of_Installment,Deduction_Type,Emp_ID,Cmp_ID from T0120_LOAN_APPROVAL 
					where Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1)
					and (Loan_Apr_Date between @Fin_St_Date and @Fin_End_Date)
					And ISNULL(Loan_App_ID,0)  = 0
						UNION ALL
					select CASE WHEN Deduction_Type = 'Monthly' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
					WHEN Deduction_Type = 'Quaterly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
					WHEN Deduction_Type = 'Half Yearly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
					ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END as Finish_date
					,Loan_Apr_Date,Loan_Apr_No_of_Installment,Deduction_Type,LA.Emp_ID,La.Cmp_ID from T0100_LOAN_APPLICATION LA inner join 
					T0120_LOAN_APPROVAL LPR On LA.Loan_App_ID = LPR.Loan_App_ID 
					where LA.Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1)
					and Loan_Apr_Status = 'A' And (Loan_Apr_Date between @Fin_St_Date and @Fin_End_Date)
					) as temp where MONTH(Finish_date) = @Month AND YEAR(Finish_date) = @Year
					And (Finish_date between @Fin_St_Date and @Fin_End_Date))
				Set @TotalEMI = (Select CAST(ISNULL(SUM(Loan_Apr_Installment_Amount),0) as numeric) as Cnt from (
					select CASE WHEN Deduction_Type = 'Monthly' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
					WHEN Deduction_Type = 'Quaterly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
					WHEN Deduction_Type = 'Half Yearly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
					ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END as Finish_date
					,Loan_Apr_Date,Loan_Apr_No_of_Installment,Deduction_Type,Loan_Apr_Installment_Amount,Emp_ID,Cmp_ID  from T0120_LOAN_APPROVAL 
					where Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1)
					and (Loan_Apr_Date between @Fin_St_Date and @Fin_End_Date)
					And ISNULL(Loan_App_ID,0)  = 0
						UNION ALL
					select CASE WHEN Deduction_Type = 'Monthly' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
					WHEN Deduction_Type = 'Quaterly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
					WHEN Deduction_Type = 'Half Yearly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
					ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END as Finish_date
					,Loan_Apr_Date,Loan_Apr_No_of_Installment,Deduction_Type,Loan_App_Installment_Amount,LA.Emp_ID,La.Cmp_ID from T0100_LOAN_APPLICATION LA inner join 
					T0120_LOAN_APPROVAL LPR On LA.Loan_App_ID = LPR.Loan_App_ID 
					where LA.Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1)
					and Loan_Apr_Status = 'A' And (Loan_Apr_Date between @Fin_St_Date and @Fin_End_Date)
					) as temp where MONTH(Finish_date) = @Month AND Year(Finish_date) = @Year
					And (Finish_date between @Fin_St_Date and @Fin_End_Date))

					Select @CntEmp as 'Total_Emp'
					,@NxtMonthLoan as 'Con_In_Next_Mon'
					,@LoanFinished as 'Finished_In_This_Month'
					,PARSENAME(Convert(varchar,Convert(Numeric(18,2),ISNULL(@TotalEMI,0)),1),2) as 'Total_EMI'
				
				
				END
			ELSE
				BEGIN
						Declare @Loandetails table
						(
							Cmp_Id numeric
							,Cmp_Name varchar(350)
							,EmpCnt numeric Default 0
							,Loan_Con_Nex_Month numeric Default 0
							,Loan_Fini_Month numeric Default 0
							,Total_EMI numeric Default 0
							,Sum_EmpCnt numeric Default 0
							,Sum_Loan_Con_Nex_Month numeric Default 0
							,Sum_Loan_Fini_Month numeric Default 0
							,Sum_Total_EMI numeric Default 0
						)
						
						INSERT INTO @Loandetails (Cmp_Id,EmpCnt) 
							Select Cmp_Id,COUNT(Emp_Id) from (
							select lA.Emp_ID,lA.Cmp_ID,Loan_Apr_Date,Deduction_Type from T0100_LOAN_APPLICATION LA inner join 
							T0120_LOAN_APPROVAL LPR On LA.Loan_App_ID = LPR.Loan_App_ID 
							where LA.Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1)
							and Loan_Apr_Status = 'A' And (Loan_Apr_Date between @Fin_St_Date and @Fin_End_Date)
								UNION ALL
							select Emp_ID,Cmp_ID,Loan_Apr_Date,Deduction_Type from T0120_LOAN_APPROVAL 
							where Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1)
							and (Loan_Apr_Date between @Fin_St_Date and @Fin_End_Date)
							And ISNULL(Loan_App_ID,0)  = 0 ) as temp group by Cmp_ID
						
						Declare @LoanContNextMonth table (Cmp_Id numeric, Cnt numeric)
						insert into @LoanContNextMonth
							select Cmp_Id,COUNT(Emp_ID) as Cnt from (
							select CASE WHEN Deduction_Type = 'Monthly' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
							WHEN Deduction_Type = 'Quaterly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
							WHEN Deduction_Type = 'Half Yearly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
							ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END as Finish_date
							,Loan_Apr_Date,Loan_Apr_No_of_Installment,Deduction_Type,Emp_ID,Cmp_ID from T0120_LOAN_APPROVAL 
							where Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1)
							and (Loan_Apr_Date between @Fin_St_Date and @Fin_End_Date)
							And ISNULL(Loan_App_ID,0)  = 0
								UNION ALL
							select CASE WHEN Deduction_Type = 'Monthly' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
							WHEN Deduction_Type = 'Quaterly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
							WHEN Deduction_Type = 'Half Yearly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
							ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END as Finish_date
							,Loan_Apr_Date,Loan_Apr_No_of_Installment,Deduction_Type,LA.Emp_ID,La.Cmp_ID from T0100_LOAN_APPLICATION LA inner join 
							T0120_LOAN_APPROVAL LPR On LA.Loan_App_ID = LPR.Loan_App_ID 
							where LA.Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1)
							and Loan_Apr_Status = 'A' And (Loan_Apr_Date between @Fin_St_Date and @Fin_End_Date)
							) as temp where MONTH(Finish_date) = @Month + 1 AND YEAR(Finish_date) = @Year
							And (Finish_date between @Fin_St_Date and @Fin_End_Date)
							Group By Cmp_ID
							
							
						Declare @LoanFinishedInThisMonth table (Cmp_Id numeric, Cnt numeric)
						insert into @LoanFinishedInThisMonth
							select Cmp_Id,COUNT(Emp_ID) as Cnt from (
							select CASE WHEN Deduction_Type = 'Monthly' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
							WHEN Deduction_Type = 'Quaterly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
							WHEN Deduction_Type = 'Half Yearly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
							ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END as Finish_date
							,Loan_Apr_Date,Loan_Apr_No_of_Installment,Deduction_Type,Emp_ID,Cmp_ID from T0120_LOAN_APPROVAL 
							where Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1)
							and (Loan_Apr_Date between @Fin_St_Date and @Fin_End_Date)
							And ISNULL(Loan_App_ID,0)  = 0
								UNION ALL
							select CASE WHEN Deduction_Type = 'Monthly' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
							WHEN Deduction_Type = 'Quaterly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
							WHEN Deduction_Type = 'Half Yearly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
							ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END as Finish_date
							,Loan_Apr_Date,Loan_Apr_No_of_Installment,Deduction_Type,LA.Emp_ID,La.Cmp_ID from T0100_LOAN_APPLICATION LA inner join 
							T0120_LOAN_APPROVAL LPR On LA.Loan_App_ID = LPR.Loan_App_ID 
							where LA.Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1)
							and Loan_Apr_Status = 'A' And (Loan_Apr_Date between @Fin_St_Date and @Fin_End_Date)
							) as temp where MONTH(Finish_date) = @Month AND YEAR(Finish_date) = @Year
							And (Finish_date between @Fin_St_Date and @Fin_End_Date)
							Group By Cmp_ID
						
						Declare @Total_EMI_Cmp table (Cmp_Id numeric, Cnt numeric)
						insert into @Total_EMI_Cmp	
							Select Cmp_ID, CAST(ISNULL(SUM(Loan_Apr_Installment_Amount),0) as numeric) as Cnt from (
							select CASE WHEN Deduction_Type = 'Monthly' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
							WHEN Deduction_Type = 'Quaterly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
							WHEN Deduction_Type = 'Half Yearly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
							ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END as Finish_date
							,Loan_Apr_Date,Loan_Apr_No_of_Installment,Deduction_Type,Loan_Apr_Installment_Amount,Emp_ID,Cmp_ID  from T0120_LOAN_APPROVAL 
							where Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1)
							and (Loan_Apr_Date between @Fin_St_Date and @Fin_End_Date)
							And ISNULL(Loan_App_ID,0)  = 0
								UNION ALL
							select CASE WHEN Deduction_Type = 'Monthly' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
							WHEN Deduction_Type = 'Quaterly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
							WHEN Deduction_Type = 'Half Yearly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
							ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END as Finish_date
							,Loan_Apr_Date,Loan_Apr_No_of_Installment,Deduction_Type,Loan_App_Installment_Amount,LA.Emp_ID,La.Cmp_ID from T0100_LOAN_APPLICATION LA inner join 
							T0120_LOAN_APPROVAL LPR On LA.Loan_App_ID = LPR.Loan_App_ID 
							where LA.Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1)
							and Loan_Apr_Status = 'A' And (Loan_Apr_Date between @Fin_St_Date and @Fin_End_Date)
							) as temp where MONTH(Finish_date) = @Month AND Year(Finish_date) = @Year
							Group By Cmp_ID
					
						Update @Loandetails
							Set Cmp_Name = CM.Cmp_Name from @Loandetails A
							Inner join T0010_COMPANY_MASTER CM ON A.Cmp_Id = CM.Cmp_Id
							
						Update @Loandetails
							Set Loan_Con_Nex_Month = CM.Cnt from @Loandetails A
							Inner join @LoanContNextMonth CM ON A.Cmp_Id = CM.Cmp_Id
							
						Update @Loandetails
							Set Loan_Fini_Month = CM.Cnt from @Loandetails A
							Inner join @LoanFinishedInThisMonth CM ON A.Cmp_Id = CM.Cmp_Id
							
						Update @Loandetails
							Set Total_EMI = CM.Cnt from @Loandetails A
							Inner join @Total_EMI_Cmp CM ON A.Cmp_Id = CM.Cmp_Id
						
						Update @Loandetails 
							Set Sum_EmpCnt = (Select SUM(EmpCnt) from @Loandetails)
							,Sum_Loan_Con_Nex_Month = (Select SUM(Loan_Con_Nex_Month) from @Loandetails)
							,Sum_Loan_Fini_Month = (Select SUM(Loan_Fini_Month) from @Loandetails)
							,Sum_Total_EMI = (Select SUM(Total_EMI) from @Loandetails)
						
						select * from @Loandetails	
				END	
		END
	
	IF @Report_For = 'TAX'	
		BEGIN
			IF @IsCmpWise = 0
				BEGIN
						Declare @TaxEmp as numeric
						Declare @TotalTax as numeric(18,2)
						Set @TaxEmp = 0 
						Set @TotalTax = 0 
						
						
						Set @TaxEmp = (Select COUNT(Distinct Emp_ID) Cnt from T0210_MONTHLY_AD_DETAIL MAD where 
						(To_date between @St_Date And @End_Date) 
						AND Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER CM where is_GroupOFCmp = 1)
						AND M_AD_Amount > 0
						AND AD_ID in (Select AD_ID from T0050_AD_MASTER AM where AD_DEF_ID = 1 AND 
						Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1)))
						
						Set @TotalTax = (Select SUM(ISNULL(M_AD_Amount,0)) as Cnt from T0210_MONTHLY_AD_DETAIL where 
						(To_date between @St_Date And @End_Date) 
						AND Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1)
						AND M_AD_Amount > 0
						AND AD_ID in (Select AD_ID from T0050_AD_MASTER where AD_DEF_ID = 1 AND
						Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1)))
						
						Select @TaxEmp as 'Emp_Cnt',PARSENAME(Convert(varchar,Convert(Numeric(18,2),ISNULL(SUM(@TotalTax),0)),1),2) as 'Total_tax'
				END
			ELSE
				BEGIN
				
						Declare @TaxDetails table
						(
							Cmp_Id numeric
							,Cmp_Name varchar(350)
							,TotalTDS numeric Default 0
							,TotalEmp numeric Default 0
							,SumTotalTDS numeric Default 0
							,SumTotalEmp numeric Default 0
						)

						
						
						Declare @TotalTDS table ( Cmp_Id numeric, Cnt numeric)
						insert into @TotalTDS
						Select Cmp_ID, CAST(SUM(ISNULL(M_AD_Amount,0)) as numeric) as Cnt from T0210_MONTHLY_AD_DETAIL where 
						(To_date between @St_Date And @End_Date) 
						AND Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1)
						AND M_AD_Amount > 0
						AND AD_ID in (Select AD_ID from T0050_AD_MASTER 
						where AD_DEF_ID = 1 AND  Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1))
						Group BY Cmp_ID
						
						Declare @TotalTexEmp table ( Cmp_Id numeric, Cnt numeric)
						insert into @TotalTexEmp
						Select Cmp_ID,COUNT(distinct Emp_ID) as Cnt from T0210_MONTHLY_AD_DETAIL where 
						(To_date between @St_Date And @End_Date) 
						AND Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1)
						AND M_AD_Amount > 0
						AND AD_ID in (Select AD_ID from T0050_AD_MASTER where AD_DEF_ID = 1 AND
						Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER where is_GroupOFCmp = 1))
						Group BY Cmp_ID
						
						INSERT INTO @TaxDetails (Cmp_Id,TotalTDS)
							Select * from @TotalTDS
						
						Update @TaxDetails 
							Set Cmp_Name = CM.Cmp_Name from @TaxDetails A
							Inner join T0010_COMPANY_MASTER CM ON A.Cmp_Id = CM.Cmp_Id
						
						Update @TaxDetails 
							Set TotalEmp = CM.Cnt from @TaxDetails A
							Inner join @TotalTexEmp CM ON A.Cmp_Id = CM.Cmp_Id
						
						Update @TaxDetails 
							Set SumTotalTDS = (Select SUM(TotalTDS) from @TaxDetails)
							,SumTotalEmp = (Select SUM(TotalEmp) from @TaxDetails)
							
						Select * from  @TaxDetails 
							
				END	
		END
		
	
		
END




