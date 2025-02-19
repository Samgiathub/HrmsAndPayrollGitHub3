

---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Sp_Get_Cmp_Consolidated_Graph]
	 @Report_For varchar(350) = 'SAL',
	 @Calander_Year Tinyint = 0
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
	Declare @YearSt as numeric
	Declare @YearEnd as numeric
	
	Set @YearSt = YEAR(GETDATE())
	Set @YearEnd = YEAR(GETDATE())
	
	IF MONTH(GETDATE()) > 3
		BEGIN
			 Set @YearSt = YEAR(GETDATE())
             Set @YearEnd = YEAR(GETDATE()) + 1
		END
	ELSE
		BEGIN
			Set @YearSt = YEAR(GETDATE()) - 1
            Set @YearEnd = YEAR(GETDATE())
		END
	
	
	
	Declare @Date as varchar(30)
	Set @Date = '1-Apr-' +  CAST (@YearSt as varchar(10))
	Declare @Date1 as varchar(30)
	Set @Date1 = '31-Mar-' + CAST (@YearEnd as varchar(10))
	
	Declare @Date_Calander as varchar(30)
	Set @Date_Calander = '1-jan-' +  CAST (@YearSt as varchar(10))
	Declare @Date_End_Calander as varchar(30)
	Set @Date_End_Calander = '31-Dec-' + CAST (@YearSt as varchar(10))
	
	
	IF @Report_For = 'SAL'
		BEGIN 
			If @Calander_Year= 0 
			begin
				Select 
				CASE WHEN MONTH = 1 THEN 'Jan ' + CAST(Year AS varchar(5))
				WHEN MONTH = 2 THEN 'Feb ' + CAST(Year AS varchar(5))
				WHEN MONTH = 3 THEN 'Mar ' + CAST(Year AS varchar(5))
				WHEN MONTH = 4 THEN 'Apr ' + CAST(Year AS varchar(5))
				WHEN MONTH = 5 THEN 'May ' + CAST(Year AS varchar(5))
				WHEN MONTH = 6 THEN 'Jun ' + CAST(Year AS varchar(5))
				WHEN MONTH = 7 THEN 'Jul ' + CAST(Year AS varchar(5))
				WHEN MONTH = 8 THEN 'Aug ' + CAST(Year AS varchar(5))
				WHEN MONTH = 9 THEN 'Sep ' + CAST(Year AS varchar(5))
				WHEN MONTH = 10 THEN 'Oct ' + CAST(Year AS varchar(5))
				WHEN MONTH = 11 THEN 'Nov ' + CAST(Year AS varchar(5))
				ELSE 'Dec ' + CAST(Year AS varchar(5)) END as MonthYear,
				SUM(Net_Amount) as 'Sum'
				--,SUM(Net_Amount) - 2500 as 'Sum1'
				--,SUM(Net_Amount) - 2542 as 'Sum2' 
				from (
				select Year(Month_End_Date) as [Year],MONTH(Month_End_Date) as [Month],Net_Amount
				from V_Emp_Salary_Details where (Month_End_Date between @Date and @Date1)
				and Cmp_id in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1)) as temp 
				group by YEAR,MONTH 
				order by MONTH
			End
			Else
			Begin
				Select 
				CASE WHEN MONTH = 1 THEN 'Jan ' + CAST(Year AS varchar(5))
				WHEN MONTH = 2 THEN 'Feb ' + CAST(Year AS varchar(5))
				WHEN MONTH = 3 THEN 'Mar ' + CAST(Year AS varchar(5))
				WHEN MONTH = 4 THEN 'Apr ' + CAST(Year AS varchar(5))
				WHEN MONTH = 5 THEN 'May ' + CAST(Year AS varchar(5))
				WHEN MONTH = 6 THEN 'Jun ' + CAST(Year AS varchar(5))
				WHEN MONTH = 7 THEN 'Jul ' + CAST(Year AS varchar(5))
				WHEN MONTH = 8 THEN 'Aug ' + CAST(Year AS varchar(5))
				WHEN MONTH = 9 THEN 'Sep ' + CAST(Year AS varchar(5))
				WHEN MONTH = 10 THEN 'Oct ' + CAST(Year AS varchar(5))
				WHEN MONTH = 11 THEN 'Nov ' + CAST(Year AS varchar(5))
				ELSE 'Dec ' + CAST(Year AS varchar(5)) END as MonthYear,
				SUM(Net_Amount) as 'Sum'
				--,SUM(Net_Amount) - 2500 as 'Sum1'
				--,SUM(Net_Amount) - 2542 as 'Sum2' 
				from (
				select Year(Month_End_Date) as [Year],MONTH(Month_End_Date) as [Month],Net_Amount
				from V_Emp_Salary_Details where (Month_End_Date between @Date_Calander and @Date_End_Calander)
				and Cmp_id in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1)) as temp 
				group by YEAR,MONTH 
				order by MONTH
			End	
	END	
	
	IF @Report_For = 'EMP'
		BEGIN
				Declare @EmpCntMonthWise table
				(
					Month_Name varchar(10),
					For_Date datetime,
					Emp_Count numeric
				)
		
				Declare @EmpCnt_Before as numeric Declare @EmpCnt_After as numeric Declare @NewJoining as numeric
				
			
				
				Declare @Apr as numeric Declare @May as numeric Declare @Jun as numeric Declare @Jul as numeric
				Declare @Aug as numeric Declare @Sep as numeric Declare @Oct as numeric Declare @Nov as numeric Declare @Dec as numeric
				Declare @Jan as numeric Declare @Feb as numeric Declare @Mar as numeric
				
				If @Calander_Year= 0 
				begin
				
					Set @EmpCnt_Before = (Select COUNT(Emp_id)  from T0080_EMP_MASTER WITH (NOLOCK) where Emp_Left <> 'Y'
					AND Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1))
				
					Set @NewJoining = (Select COUNT(Emp_ID) from T0080_EMP_MASTER WITH (NOLOCK) where (Date_Of_Join between @Date and @Date1)		
					AND Emp_Left = 'N' AND Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1))
							
					Set @EmpCnt_After = @EmpCnt_Before - @NewJoining
				
					Select @Apr = COUNT(MONTH) from (Select MONTH(Date_Of_Join) as [Month],YEAR(Date_Of_Join) as [Year],Date_Of_Join from T0080_EMP_MASTER WITH (NOLOCK) where (Date_Of_Join between @Date and @Date1) AND Emp_Left <> 'Y' AND Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1) ) as temp where MONTH = 4
					Select @May = COUNT(MONTH) from (Select MONTH(Date_Of_Join) as [Month],YEAR(Date_Of_Join) as [Year],Date_Of_Join from T0080_EMP_MASTER WITH (NOLOCK) where (Date_Of_Join between @Date and @Date1) AND Emp_Left <> 'Y' AND Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1) ) as temp where MONTH = 5
					Select @Jun = COUNT(MONTH) from (Select MONTH(Date_Of_Join) as [Month],YEAR(Date_Of_Join) as [Year],Date_Of_Join from T0080_EMP_MASTER WITH (NOLOCK) where (Date_Of_Join between @Date and @Date1) AND Emp_Left <> 'Y' AND Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1) ) as temp where MONTH = 6
					Select @Jul = COUNT(MONTH) from (Select MONTH(Date_Of_Join) as [Month],YEAR(Date_Of_Join) as [Year],Date_Of_Join from T0080_EMP_MASTER WITH (NOLOCK) where (Date_Of_Join between @Date and @Date1) AND Emp_Left <> 'Y' AND Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1) ) as temp where MONTH = 7
					Select @Aug = COUNT(MONTH) from (Select MONTH(Date_Of_Join) as [Month],YEAR(Date_Of_Join) as [Year],Date_Of_Join from T0080_EMP_MASTER WITH (NOLOCK) where (Date_Of_Join between @Date and @Date1) AND Emp_Left <> 'Y' AND Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1) ) as temp where MONTH = 8
					Select @Sep = COUNT(MONTH) from (Select MONTH(Date_Of_Join) as [Month],YEAR(Date_Of_Join) as [Year],Date_Of_Join from T0080_EMP_MASTER WITH (NOLOCK) where (Date_Of_Join between @Date and @Date1) AND Emp_Left <> 'Y' AND Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1) ) as temp where MONTH = 9
					Select @Oct = COUNT(MONTH) from (Select MONTH(Date_Of_Join) as [Month],YEAR(Date_Of_Join) as [Year],Date_Of_Join from T0080_EMP_MASTER WITH (NOLOCK) where (Date_Of_Join between @Date and @Date1) AND Emp_Left <> 'Y' AND Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1) ) as temp where MONTH = 10
					Select @Nov = COUNT(MONTH) from (Select MONTH(Date_Of_Join) as [Month],YEAR(Date_Of_Join) as [Year],Date_Of_Join from T0080_EMP_MASTER WITH (NOLOCK) where (Date_Of_Join between @Date and @Date1) AND Emp_Left <> 'Y' AND Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1) ) as temp where MONTH = 11
					Select @Dec = COUNT(MONTH) from (Select MONTH(Date_Of_Join) as [Month],YEAR(Date_Of_Join) as [Year],Date_Of_Join from T0080_EMP_MASTER WITH (NOLOCK) where (Date_Of_Join between @Date and @Date1) AND Emp_Left <> 'Y' AND Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1) ) as temp where MONTH = 12
					Select @Jan = COUNT(MONTH) from (Select MONTH(Date_Of_Join) as [Month],YEAR(Date_Of_Join) as [Year],Date_Of_Join from T0080_EMP_MASTER WITH (NOLOCK) where (Date_Of_Join between @Date and @Date1) AND Emp_Left <> 'Y' AND Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1) ) as temp where MONTH = 1
					Select @Feb = COUNT(MONTH) from (Select MONTH(Date_Of_Join) as [Month],YEAR(Date_Of_Join) as [Year],Date_Of_Join from T0080_EMP_MASTER WITH (NOLOCK) where (Date_Of_Join between @Date and @Date1) AND Emp_Left <> 'Y' AND Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1) ) as temp where MONTH = 2
					Select @Mar = COUNT(MONTH) from (Select MONTH(Date_Of_Join) as [Month],YEAR(Date_Of_Join) as [Year],Date_Of_Join from T0080_EMP_MASTER WITH (NOLOCK) where (Date_Of_Join between @Date and @Date1) AND Emp_Left <> 'Y' AND Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1) ) as temp where MONTH = 3
					
					
					Insert into @EmpCntMonthWise 
					Select 'Apr',DATEADD(month,4-1,DATEADD(year,@YearSt-1900,0)),Sum(@EmpCnt_After + @Apr)
					
					Insert into @EmpCntMonthWise 
					Select 'May',DATEADD(month,5-1,DATEADD(year,@YearSt-1900,0)),Sum(@EmpCnt_After + @Apr + @May)
					
					Insert into @EmpCntMonthWise 
					Select 'Jun',DATEADD(month,6-1,DATEADD(year,@YearSt-1900,0)),Sum(@EmpCnt_After + @Apr + @May + @Jun)
					
					Insert into @EmpCntMonthWise 
					Select 'Jul',DATEADD(month,7-1,DATEADD(year,@YearSt-1900,0)),Sum(@EmpCnt_After + @Apr + @May + @Jun + @Jul)
					
					Insert into @EmpCntMonthWise 
					Select 'Aug',DATEADD(month,8-1,DATEADD(year,@YearSt-1900,0)),Sum(@EmpCnt_After + @Apr + @May + @Jun + @Jul + @Aug)
					
					Insert into @EmpCntMonthWise 
					Select 'Sep',DATEADD(month,9-1,DATEADD(year,@YearSt-1900,0)),Sum(@EmpCnt_After + @Apr + @May + @Jun + @Jul + @Aug + @Sep)
					
					Insert into @EmpCntMonthWise 
					Select 'Oct',DATEADD(month,10-1,DATEADD(year,@YearSt-1900,0)),Sum(@EmpCnt_After + @Apr + @May + @Jun + @Jul + @Aug + @Sep + @Oct)
					
					Insert into @EmpCntMonthWise 
					Select 'Nov',DATEADD(month,11-1,DATEADD(year,@YearSt-1900,0)),Sum(@EmpCnt_After + @Apr + @May + @Jun + @Jul + @Aug + @Sep + @Oct + @Nov)
					
					Insert into @EmpCntMonthWise 
					Select 'Dec',DATEADD(month,12-1,DATEADD(year,@YearSt-1900,0)),Sum(@EmpCnt_After + @Apr + @May + @Jun + @Jul + @Aug + @Sep + @Oct + @Nov + @Dec)
					
					Insert into @EmpCntMonthWise 
					Select 'Jan',DATEADD(month,1-1,DATEADD(year,@YearEnd-1900,0)),Sum(@EmpCnt_After + @Apr + @May + @Jun + @Jul + @Aug + @Sep + @Oct + @Nov + @Dec + @Jan)
					
					Insert into @EmpCntMonthWise 
					Select 'Feb',DATEADD(month,2-1,DATEADD(year,@YearEnd-1900,0)),Sum(@EmpCnt_After + @Apr + @May + @Jun + @Jul + @Aug + @Sep + @Oct + @Nov + @Dec + @Jan + @Feb)
					
					Insert into @EmpCntMonthWise 
					Select 'Mar',DATEADD(month,3-1,DATEADD(year,@YearEnd-1900,0)),Sum(@EmpCnt_After + @Apr + @May + @Jun + @Jul + @Aug + @Sep + @Oct + @Nov + @Dec + @Jan + @Feb + @Mar)
				end
				else
				Begin
				
					Set @EmpCnt_Before = (Select COUNT(Emp_id)  from T0080_EMP_MASTER WITH (NOLOCK) where Emp_Left <> 'Y'
					AND Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1))
				
					Set @NewJoining = (Select COUNT(Emp_ID) from T0080_EMP_MASTER WITH (NOLOCK) where (Date_Of_Join between @Date_Calander and @Date_End_Calander)		
					AND Emp_Left = 'N' AND Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1))
							
					Set @EmpCnt_After = @EmpCnt_Before - @NewJoining
				
					Select @Jan = COUNT(MONTH) from (Select MONTH(Date_Of_Join) as [Month],YEAR(Date_Of_Join) as [Year],Date_Of_Join from T0080_EMP_MASTER WITH (NOLOCK) where (Date_Of_Join between @Date_Calander and @Date_End_Calander) AND Emp_Left <> 'Y' AND Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1) ) as temp where MONTH = 1
					Select @Feb = COUNT(MONTH) from (Select MONTH(Date_Of_Join) as [Month],YEAR(Date_Of_Join) as [Year],Date_Of_Join from T0080_EMP_MASTER WITH (NOLOCK) where (Date_Of_Join between @Date_Calander and @Date_End_Calander) AND Emp_Left <> 'Y' AND Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1) ) as temp where MONTH = 2
					Select @Mar = COUNT(MONTH) from (Select MONTH(Date_Of_Join) as [Month],YEAR(Date_Of_Join) as [Year],Date_Of_Join from T0080_EMP_MASTER WITH (NOLOCK) where (Date_Of_Join between @Date_Calander and @Date_End_Calander) AND Emp_Left <> 'Y' AND Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1) ) as temp where MONTH = 3
					Select @Apr = COUNT(MONTH) from (Select MONTH(Date_Of_Join) as [Month],YEAR(Date_Of_Join) as [Year],Date_Of_Join from T0080_EMP_MASTER WITH (NOLOCK) where (Date_Of_Join between @Date_Calander and @Date_End_Calander) AND Emp_Left <> 'Y' AND Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1) ) as temp where MONTH = 4
					Select @May = COUNT(MONTH) from (Select MONTH(Date_Of_Join) as [Month],YEAR(Date_Of_Join) as [Year],Date_Of_Join from T0080_EMP_MASTER WITH (NOLOCK) where (Date_Of_Join between @Date_Calander and @Date_End_Calander) AND Emp_Left <> 'Y' AND Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1) ) as temp where MONTH = 5
					Select @Jun = COUNT(MONTH) from (Select MONTH(Date_Of_Join) as [Month],YEAR(Date_Of_Join) as [Year],Date_Of_Join from T0080_EMP_MASTER WITH (NOLOCK) where (Date_Of_Join between @Date_Calander and @Date_End_Calander) AND Emp_Left <> 'Y' AND Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1) ) as temp where MONTH = 6
					Select @Jul = COUNT(MONTH) from (Select MONTH(Date_Of_Join) as [Month],YEAR(Date_Of_Join) as [Year],Date_Of_Join from T0080_EMP_MASTER WITH (NOLOCK) where (Date_Of_Join between @Date_Calander and @Date_End_Calander) AND Emp_Left <> 'Y' AND Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1) ) as temp where MONTH = 7
					Select @Sep = COUNT(MONTH) from (Select MONTH(Date_Of_Join) as [Month],YEAR(Date_Of_Join) as [Year],Date_Of_Join from T0080_EMP_MASTER WITH (NOLOCK) where (Date_Of_Join between @Date_Calander and @Date_End_Calander) AND Emp_Left <> 'Y' AND Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1) ) as temp where MONTH = 9
					Select @Oct = COUNT(MONTH) from (Select MONTH(Date_Of_Join) as [Month],YEAR(Date_Of_Join) as [Year],Date_Of_Join from T0080_EMP_MASTER WITH (NOLOCK) where (Date_Of_Join between @Date_Calander and @Date_End_Calander) AND Emp_Left <> 'Y' AND Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1) ) as temp where MONTH = 10
					Select @Nov = COUNT(MONTH) from (Select MONTH(Date_Of_Join) as [Month],YEAR(Date_Of_Join) as [Year],Date_Of_Join from T0080_EMP_MASTER WITH (NOLOCK) where (Date_Of_Join between @Date_Calander and @Date_End_Calander) AND Emp_Left <> 'Y' AND Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1) ) as temp where MONTH = 11
					Select @Dec = COUNT(MONTH) from (Select MONTH(Date_Of_Join) as [Month],YEAR(Date_Of_Join) as [Year],Date_Of_Join from T0080_EMP_MASTER WITH (NOLOCK) where (Date_Of_Join between @Date_Calander and @Date_End_Calander) AND Emp_Left <> 'Y' AND Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1) ) as temp where MONTH = 12
				
					
					Insert into @EmpCntMonthWise 
					Select 'Jan',DATEADD(month,1-1,DATEADD(year,@YearSt-1900,0)),Sum(@EmpCnt_After + @jan)
					
					Insert into @EmpCntMonthWise 
					Select 'Feb',DATEADD(month,2-1,DATEADD(year,@YearSt-1900,0)),Sum(@EmpCnt_After + @jan + @Feb)
					
					Insert into @EmpCntMonthWise 
					Select 'Mar',DATEADD(month,3-1,DATEADD(year,@YearSt-1900,0)),Sum(@EmpCnt_After + @jan + @Feb + @Mar)
					
					Insert into @EmpCntMonthWise 
					Select 'Apr',DATEADD(month,4-1,DATEADD(year,@YearSt-1900,0)),Sum(@EmpCnt_After + @jan + @Feb + @Mar + @Apr)
					
					Insert into @EmpCntMonthWise 
					Select 'May',DATEADD(month,5-1,DATEADD(year,@YearSt-1900,0)),Sum(@EmpCnt_After + @jan + @Feb + @Mar + @Apr + @May)
					
					Insert into @EmpCntMonthWise 
					Select 'Jun',DATEADD(month,6-1,DATEADD(year,@YearSt-1900,0)),Sum(@EmpCnt_After + @jan + @Feb + @Mar + @Apr + @May + @Jun)
					
					Insert into @EmpCntMonthWise 
					Select 'Jul',DATEADD(month,7-1,DATEADD(year,@YearSt-1900,0)),Sum(@EmpCnt_After + @jan + @Feb + @Mar + @Apr + @May + @Jun + @Jul)
					
					Insert into @EmpCntMonthWise 
					Select 'Aug',DATEADD(month,8-1,DATEADD(year,@YearSt-1900,0)),Sum(@EmpCnt_After + @jan + @Feb + @Mar + @Apr + @May + @Jun + @Jul + @Aug)
					
					Insert into @EmpCntMonthWise 
					Select 'Sep',DATEADD(month,9-1,DATEADD(year,@YearSt-1900,0)),Sum(@EmpCnt_After + @jan + @Feb + @Mar + @Apr + @May + @Jun + @Jul + @Aug + @Sep)
					
					Insert into @EmpCntMonthWise 
					Select 'Oct',DATEADD(month,10-1,DATEADD(year,@YearEnd-1900,0)),Sum(@EmpCnt_After + @jan + @Feb + @Mar + @Apr + @May + @Jun + @Jul + @Aug + @Sep + @Oct)
					
					Insert into @EmpCntMonthWise 
					Select 'Nov',DATEADD(month,11-1,DATEADD(year,@YearEnd-1900,0)),Sum(@EmpCnt_After + @jan + @Feb + @Mar + @Apr + @May + @Jun + @Jul + @Aug + @Sep + @Oct + @Nov)
					
					Insert into @EmpCntMonthWise 
					Select 'Dec',DATEADD(month,12-1,DATEADD(year,@YearEnd-1900,0)),Sum(@EmpCnt_After + @jan + @Feb + @Mar + @Apr + @May + @Jun + @Jul + @Aug + @Sep + @oct + @nov + @dec)
				
				end	
				select Month_Name,Emp_Count from @EmpCntMonthWise 
				where For_Date <= GETDATE()	
		END
		
	IF @Report_For = 'LEAV'
		BEGIN
		If @Calander_Year= 0 
			begin
				select Leave_Name,COUNT(Leave_ID) as LeaveCout from V0120_LEAVE_APPROVAL 
				where (To_Date <= @Date1 AND From_Date >= @Date
				and Cmp_id in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1))
				and Approval_Status = 'A' Group by Leave_Name
				order by Leave_Name
			end
			Else
			Begin
				select Leave_Name,COUNT(Leave_ID) as LeaveCout from V0120_LEAVE_APPROVAL 
				where (To_Date <= @Date_End_Calander AND From_Date >= @Date_Calander
				and Cmp_id in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1))
				and Approval_Status = 'A' Group by Leave_Name
				order by Leave_Name
			End
				
		END
		
	IF @Report_For = 'LEAVMONTH'
		BEGIN
		
			If @Calander_Year= 0 
			begin
			
				Select	CASE WHEN MONTH = 1 THEN 'Jan'
						WHEN MONTH = 2 THEN 'Feb'
						WHEN MONTH = 3 THEN 'Mar'
						WHEN MONTH = 4 THEN 'Apr'
						WHEN MONTH = 5 THEN 'May'
						WHEN MONTH = 6 THEN 'Jun'
						WHEN MONTH = 7 THEN 'Jul'
						WHEN MONTH = 8 THEN 'Aug'
						WHEN MONTH = 9 THEN 'Sep'
						WHEN MONTH = 10 THEN 'Oct'
						WHEN MONTH = 11 THEN 'Nov'
						ELSE 'Dec' END as MonthYear,COUNT(Emp_ID) as EmpCnt from (
				select Year(Approval_Date) as [Year],MONTH(Approval_Date) as [Month],Emp_ID from V0120_LEAVE_APPROVAL 
				where (Approval_Date <= @Date1 AND Approval_Date >= @Date) and Approval_Status = 'A' 
				and Cmp_id in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1)) As temp
				group by YEAR,MONTH 
				order by MONTH
			end
			else
			begin
				Select	CASE WHEN MONTH = 1 THEN 'Jan'
						WHEN MONTH = 2 THEN 'Feb'
						WHEN MONTH = 3 THEN 'Mar'
						WHEN MONTH = 4 THEN 'Apr'
						WHEN MONTH = 5 THEN 'May'
						WHEN MONTH = 6 THEN 'Jun'
						WHEN MONTH = 7 THEN 'Jul'
						WHEN MONTH = 8 THEN 'Aug'
						WHEN MONTH = 9 THEN 'Sep'
						WHEN MONTH = 10 THEN 'Oct'
						WHEN MONTH = 11 THEN 'Nov'
						ELSE 'Dec' END as MonthYear,COUNT(Emp_ID) as EmpCnt from (
				select Year(Approval_Date) as [Year],MONTH(Approval_Date) as [Month],Emp_ID from V0120_LEAVE_APPROVAL 
				where (Approval_Date <= @Date_End_Calander AND Approval_Date >= @Date_Calander) and Approval_Status = 'A' 
				and Cmp_id in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1)) As temp
				group by YEAR,MONTH 
				order by MONTH
			end
				
		END
		
	IF @Report_For = 'LON'	
		BEGIN
		
		If @Calander_Year= 0 
			begin
					Select Cmp_Name,COUNT(Emp_Id) AS EmpCnt from (
						select lA.Emp_ID,lA.Cmp_ID,Loan_Apr_Date,Deduction_Type from T0100_LOAN_APPLICATION LA WITH (NOLOCK) inner join 
						T0120_LOAN_APPROVAL LPR WITH (NOLOCK) On LA.Loan_App_ID = LPR.Loan_App_ID 
						where LA.Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1)
						and Loan_Apr_Status = 'A' And (Loan_Apr_Date between @Date and @Date1)
							UNION ALL
						select Emp_ID,Cmp_ID,Loan_Apr_Date,Deduction_Type from T0120_LOAN_APPROVAL WITH (NOLOCK)
						where Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1)
						and (Loan_Apr_Date between @Date and @Date1)
						And ISNULL(Loan_App_ID,0)  = 0 ) as temp
						inner join T0010_COMPANY_MASTER WITH (NOLOCK) ON Temp.Cmp_ID = T0010_COMPANY_MASTER.Cmp_Id
						group by Temp.Cmp_ID,Cmp_Name
			end
			Else
			Begin
						Select Cmp_Name,COUNT(Emp_Id) AS EmpCnt from (
						select lA.Emp_ID,lA.Cmp_ID,Loan_Apr_Date,Deduction_Type from T0100_LOAN_APPLICATION LA WITH (NOLOCK) inner join 
						T0120_LOAN_APPROVAL LPR WITH (NOLOCK) On LA.Loan_App_ID = LPR.Loan_App_ID 
						where LA.Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1)
						and Loan_Apr_Status = 'A' And (Loan_Apr_Date between @Date_Calander and @Date_End_Calander)
							UNION ALL
						select Emp_ID,Cmp_ID,Loan_Apr_Date,Deduction_Type from T0120_LOAN_APPROVAL WITH (NOLOCK)
						where Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1)
						and (Loan_Apr_Date between @Date_Calander and @Date_End_Calander)
						And ISNULL(Loan_App_ID,0)  = 0 ) as temp
						inner join T0010_COMPANY_MASTER WITH (NOLOCK) ON Temp.Cmp_ID = T0010_COMPANY_MASTER.Cmp_Id
						group by Temp.Cmp_ID,Cmp_Name
			End
		END
		
	IF @Report_For = 'LONMONTH'	
		BEGIN
		
		If @Calander_Year= 0 
			begin
				 Select CASE WHEN Finish_Month = 1 THEN 'Jan'
						WHEN Finish_Month = 2 THEN 'Feb'
						WHEN Finish_Month = 3 THEN 'Mar'
						WHEN Finish_Month = 4 THEN 'Apr'
						WHEN Finish_Month = 5 THEN 'May'
						WHEN Finish_Month = 6 THEN 'Jun'
						WHEN Finish_Month = 7 THEN 'Jul'
						WHEN Finish_Month = 8 THEN 'Aug'
						WHEN Finish_Month = 9 THEN 'Sep'
						WHEN Finish_Month = 10 THEN 'Oct'
						WHEN Finish_Month = 11 THEN 'Nov'
						ELSE 'Dec' END as MonthYear,COUNT(Emp_ID) as Cnt from (
					select lA.Emp_ID,lA.Cmp_ID,Loan_Apr_Date,Deduction_Type,Loan_Apr_Installment_Amount,Loan_Apr_Payment_Date 
					,CASE WHEN Deduction_Type = 'Monthly' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
							WHEN Deduction_Type = 'Quaterly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
							WHEN Deduction_Type = 'Half Yearly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
							ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END as Finish_Date
					,MONTH(CASE WHEN Deduction_Type = 'Monthly' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
							WHEN Deduction_Type = 'Quaterly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
							WHEN Deduction_Type = 'Half Yearly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
							ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END) as Finish_Month
					,Year(CASE WHEN Deduction_Type = 'Monthly' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
							WHEN Deduction_Type = 'Quaterly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
							WHEN Deduction_Type = 'Half Yearly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
							ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END) as Finish_Year
					from T0100_LOAN_APPLICATION LA WITH (NOLOCK) inner join 
					T0120_LOAN_APPROVAL LPR WITH (NOLOCK) On LA.Loan_App_ID = LPR.Loan_App_ID 
					where LA.Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1)
					and Loan_Apr_Status = 'A' And (Loan_Apr_Date between @Date and @Date1)
						UNION ALL
					select Emp_ID,Cmp_ID,Loan_Apr_Date,Deduction_Type,Loan_Apr_Installment_Amount,Loan_Apr_Payment_Date 
					,CASE WHEN Deduction_Type = 'Monthly' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
							WHEN Deduction_Type = 'Quaterly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
							WHEN Deduction_Type = 'Half Yearly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
							ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END as Finish_Date
					,MONTH(CASE WHEN Deduction_Type = 'Monthly' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
							WHEN Deduction_Type = 'Quaterly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
							WHEN Deduction_Type = 'Half Yearly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
							ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END) as Finish_Month
					,Year(CASE WHEN Deduction_Type = 'Monthly' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
							WHEN Deduction_Type = 'Quaterly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
							WHEN Deduction_Type = 'Half Yearly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
							ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END) as Finish_Year
					from T0120_LOAN_APPROVAL WITH (NOLOCK) 
					where Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1)
					and (Loan_Apr_Date between @Date and @Date1) And ISNULL(Loan_App_ID,0)  = 0 
					) as temp 
					Where (Finish_Date between @Date and @Date1)
					group by Finish_Month,Finish_Year Order by Finish_Month
			End	
			Else
			Begin
				 Select CASE WHEN Finish_Month = 1 THEN 'Jan'
						WHEN Finish_Month = 2 THEN 'Feb'
						WHEN Finish_Month = 3 THEN 'Mar'
						WHEN Finish_Month = 4 THEN 'Apr'
						WHEN Finish_Month = 5 THEN 'May'
						WHEN Finish_Month = 6 THEN 'Jun'
						WHEN Finish_Month = 7 THEN 'Jul'
						WHEN Finish_Month = 8 THEN 'Aug'
						WHEN Finish_Month = 9 THEN 'Sep'
						WHEN Finish_Month = 10 THEN 'Oct'
						WHEN Finish_Month = 11 THEN 'Nov'
						ELSE 'Dec' END as MonthYear,COUNT(Emp_ID) as Cnt from (
					select lA.Emp_ID,lA.Cmp_ID,Loan_Apr_Date,Deduction_Type,Loan_Apr_Installment_Amount,Loan_Apr_Payment_Date 
					,CASE WHEN Deduction_Type = 'Monthly' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
							WHEN Deduction_Type = 'Quaterly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
							WHEN Deduction_Type = 'Half Yearly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
							ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END as Finish_Date
					,MONTH(CASE WHEN Deduction_Type = 'Monthly' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
							WHEN Deduction_Type = 'Quaterly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
							WHEN Deduction_Type = 'Half Yearly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
							ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END) as Finish_Month
					,Year(CASE WHEN Deduction_Type = 'Monthly' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
							WHEN Deduction_Type = 'Quaterly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
							WHEN Deduction_Type = 'Half Yearly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
							ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END) as Finish_Year
					from T0100_LOAN_APPLICATION LA WITH (NOLOCK) inner join 
					T0120_LOAN_APPROVAL LPR WITH (NOLOCK) On LA.Loan_App_ID = LPR.Loan_App_ID 
					where LA.Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1)
					and Loan_Apr_Status = 'A' And (Loan_Apr_Date between @Date_Calander and @Date_End_Calander)
						UNION ALL
					select Emp_ID,Cmp_ID,Loan_Apr_Date,Deduction_Type,Loan_Apr_Installment_Amount,Loan_Apr_Payment_Date 
					,CASE WHEN Deduction_Type = 'Monthly' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
							WHEN Deduction_Type = 'Quaterly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
							WHEN Deduction_Type = 'Half Yearly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
							ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END as Finish_Date
					,MONTH(CASE WHEN Deduction_Type = 'Monthly' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
							WHEN Deduction_Type = 'Quaterly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
							WHEN Deduction_Type = 'Half Yearly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
							ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END) as Finish_Month
					,Year(CASE WHEN Deduction_Type = 'Monthly' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
							WHEN Deduction_Type = 'Quaterly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
							WHEN Deduction_Type = 'Half Yearly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
							ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END) as Finish_Year
					from T0120_LOAN_APPROVAL WITH (NOLOCK) 
					where Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1)
					and (Loan_Apr_Date between @Date_Calander and @Date_End_Calander) And ISNULL(Loan_App_ID,0)  = 0 
					) as temp 
					Where (Finish_Date between @Date_Calander and @Date_End_Calander)
					group by Finish_Month,Finish_Year Order by Finish_Month
			End
		END
	
	IF  @Report_For = 'TAX'	
		BEGIN
		If @Calander_Year= 0 
			begin
						Select 
						CASE WHEN MONTH(For_Date) = 1 THEN 'Jan'
						WHEN MONTH(For_Date) = 2 THEN 'Feb'
						WHEN MONTH(For_Date) = 3 THEN 'Mar'
						WHEN MONTH(For_Date) = 4 THEN 'Apr'
						WHEN MONTH(For_Date) = 5 THEN 'May'
						WHEN MONTH(For_Date) = 6 THEN 'Jun'
						WHEN MONTH(For_Date) = 7 THEN 'Jul'
						WHEN MONTH(For_Date) = 8 THEN 'Aug'
						WHEN MONTH(For_Date) = 9 THEN 'Sep'
						WHEN MONTH(For_Date) = 10 THEN 'Oct'
						WHEN MONTH(For_Date) = 11 THEN 'Nov'
						ELSE 'Dec' END as MonthYear
						,CAST(SUM(ISNULL(M_AD_Amount,0)) as numeric) as cnt from (
						Select * from T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) where 
						(To_date between @Date and @Date1)
						AND Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1)
						AND AD_ID in (Select AD_ID from T0050_AD_MASTER WITH (NOLOCK) where AD_DEF_ID = 1 AND
						Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1))) as temp
						where M_AD_Amount > 0
						group by MONTH(For_Date)
			end
			Else
			Begin
					Select 
						CASE WHEN MONTH(For_Date) = 1 THEN 'Jan'
						WHEN MONTH(For_Date) = 2 THEN 'Feb'
						WHEN MONTH(For_Date) = 3 THEN 'Mar'
						WHEN MONTH(For_Date) = 4 THEN 'Apr'
						WHEN MONTH(For_Date) = 5 THEN 'May'
						WHEN MONTH(For_Date) = 6 THEN 'Jun'
						WHEN MONTH(For_Date) = 7 THEN 'Jul'
						WHEN MONTH(For_Date) = 8 THEN 'Aug'
						WHEN MONTH(For_Date) = 9 THEN 'Sep'
						WHEN MONTH(For_Date) = 10 THEN 'Oct'
						WHEN MONTH(For_Date) = 11 THEN 'Nov'
						ELSE 'Dec' END as MonthYear
						,CAST(SUM(ISNULL(M_AD_Amount,0)) as numeric) as cnt from (
						Select * from T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) where 
						(To_date between @Date_Calander and @Date_End_Calander)
						AND Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1)
						AND AD_ID in (Select AD_ID from T0050_AD_MASTER WITH (NOLOCK) where AD_DEF_ID = 1 AND
						Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1))) as temp
						where M_AD_Amount > 0
						group by MONTH(For_Date)
			End
						
		END
		
	IF @Report_For = 'TAXMONTH'	
		BEGIN
		
		If @Calander_Year= 0 
			begin
						Select (Select Cmp_Name from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_ID = temp.Cmp_ID) as Cmp_Name,COUNT(Distinct Emp_ID) as cnt from (
						Select * from T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) where 
						(To_date between @Date and @Date1)
						AND Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1)
						AND AD_ID in (Select AD_ID from T0050_AD_MASTER WITH (NOLOCK) where AD_DEF_ID = 1 AND
						Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1))) as temp
						where M_AD_Amount > 0
						group by Cmp_ID
			End
			Else
			Begin
						Select (Select Cmp_Name from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_ID = temp.Cmp_ID) as Cmp_Name,COUNT(Distinct Emp_ID) as cnt from (
						Select * from T0210_MONTHLY_AD_DETAIL WITH (NOLOCK) where 
						(To_date between @Date_Calander and @Date_End_Calander)
						AND Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1)
						AND AD_ID in (Select AD_ID from T0050_AD_MASTER WITH (NOLOCK) where AD_DEF_ID = 1 AND
						Cmp_ID in (Select Cmp_ID from T0010_COMPANY_MASTER WITH (NOLOCK) where is_GroupOFCmp = 1))) as temp
						where M_AD_Amount > 0
						group by Cmp_ID
			End			
		END
		
		
END



