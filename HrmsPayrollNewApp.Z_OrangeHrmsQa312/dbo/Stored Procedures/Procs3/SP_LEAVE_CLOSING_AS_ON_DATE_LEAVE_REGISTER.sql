
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[SP_LEAVE_CLOSING_AS_ON_DATE_LEAVE_REGISTER]
	 @Cmp_ID 		numeric
	,@From_Date 	datetime
	,@To_Date 		datetime
	,@Branch_ID		Numeric 
	,@Cat_ID		Numeric	
	,@Grd_ID		Numeric
	,@Type_ID		Numeric 
	,@Dept_Id		Numeric
	,@Desig_Id		Numeric
	,@Emp_ID		Numeric
	,@Constraint	varchar(MAX)
	,@PBranch_ID varchar(200) = '0'
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
			
	Declare @Leave_ID As Numeric
	Declare @Emp_ID_Cur As Numeric
	Declare @Leave_Code As varchar(15)
	Declare @Leave_Name as Varchar(25)
	Declare @From_Date_Temp as datetime
	Declare @To_Date_Temp as datetime
	
	Set @From_Date_Temp = @From_Date
	Set @To_Date_Temp = @To_Date
	
	
	
	CREATE TABLE #EMP_CONS	  
	 (      
	   EMP_ID NUMERIC ,     
	   BRANCH_ID NUMERIC,
	   INCREMENT_ID NUMERIC    
	 )   
	 
	 EXEC SP_RPT_FILL_EMP_CONS  @CMP_ID,@FROM_DATE,@TO_DATE,@BRANCH_ID,@CAT_ID,@GRD_ID,@TYPE_ID,@DEPT_ID,@DESIG_ID ,@EMP_ID ,@CONSTRAINT ,0 ,0 ,0 ,0 ,0 ,0 
	
	

	CREATE TABLE #Leave_Used 
	  (
			Emp_Id		numeric , 
			Leave_Id	Numeric,
			Cmp_ID		numeric,
			Leave_Code	varchar(15),
			Leave_Name	varchar(25),
			Month		Numeric,
			Year		Numeric,
			Leave_Used	numeric(5,1),
			Leave_Dates nvarchar(max),
			Leave_Opening  NUMERIC(5,1)  DEFAULT 0, --added jimit 20012016
			Leave_closing	  NUMERIC(5,1)  DEFAULT 0	--added jimit 20012016
			
	  )

	Declare @Branch_ID_Temp numeric
	Declare @Sal_St_Date datetime
	DECLARE @Sal_End_Date datetime
	DECLARE @manual_salary_period tinyint
	DECLARE @From_Date_Cur datetime
	DECLARE @To_Date_Cur datetime

	Declare cur_emp cursor for 
		Select Emp_ID From #Emp_Cons 
	open cur_emp
	fetch next from Cur_Emp into @Emp_ID_Cur 
	while @@fetch_Status = 0
		begin 

			Declare cur_Leave cursor for 
				Select Leave_ID,Leave_Code,Leave_Name from T0040_LEAVE_MASTER WITH (NOLOCK) Where Leave_Sorting_No in (1,2,3) and Cmp_ID = @CMP_ID order by Leave_sorting_no
			open cur_Leave
			fetch next from cur_Leave into @Leave_ID,@Leave_Code,@Leave_Name
			while @@fetch_Status = 0
				begin 

					While @From_Date <= @To_Date
						Begin
							If EXISTS (Select 1 From T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID = @Emp_ID_Cur And Month(Month_End_Date)=Month(@From_Date) And Year(Month_End_Date)=Year(@From_Date))
								BEGIN
									Select @From_Date_Cur = Month_St_Date,@To_Date_Cur=Month_End_Date  From T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID = @Emp_ID_Cur And Month(Month_End_Date)=Month(@From_Date) And Year(Month_End_Date)=Year(@From_Date)
								
									--Set @From_Date_Cur = dbo.GET_MONTH_ST_DATE(Month(@From_Date),Year(@From_Date))
									--Set @To_Date_Cur = dbo.GET_MONTH_END_DATE(Month(@From_Date),Year(@From_Date))
									
									--SELECT	@Branch_ID_Temp = Branch_ID
									--FROM	T0095_Increment I inner join     
									--		(
									--			select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI inner join
									--				(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment
									--				Where Increment_effective_Date <= @To_Date_Cur Group by emp_ID) new_inc
									--				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
									--				Where TI.Increment_effective_Date <= @To_Date_Cur group by ti.emp_id) Qry On I.Increment_ID = Qry.Increment_Id
									--WHERE I.Emp_ID = @Emp_ID_Cur 
								
									--SELECT	@Sal_St_Date =Sal_st_Date ,@manual_salary_period=isnull(Manual_Salary_Period ,0) 
									--FROM	T0040_GENERAL_SETTING 
									--WHERE	cmp_ID = @cmp_ID and Branch_ID = @Branch_ID_Temp 
									--		and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING where For_Date <=@To_Date_Cur and Branch_ID = @Branch_ID_Temp and Cmp_ID = @Cmp_ID)    
									

									--set @manual_salary_period = isnull(@manual_salary_period,0) -- added by mitesh on 18072013
									--if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
									--	begin    
									--		if @manual_salary_period = 0 
									--			begin
									--				set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
									--				set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
													
									--				Set @From_Date_Cur = @Sal_St_Date 
									--				Set @To_Date_Cur = @Sal_End_Date
									--			end 
									--		else
									--			begin
									--				select @Sal_St_Date=from_date,@Sal_End_Date=end_date from salary_period where month= month(@From_Date) and YEAR=year(@From_Date)
													
									--				Set @From_Date_Cur = @Sal_St_Date 
									--				Set @To_Date_Cur = @Sal_End_Date 
									--			end   
									--	  end							
					
														
									If exists (Select 1
												From T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
												Where LT.Cmp_ID = @CMP_ID 
													And LT.Leave_ID = @Leave_ID And Emp_ID = @Emp_ID_Cur
													--And Month(For_Date) = Month(@From_Date) And Year(For_Date) = YEAR(@From_Date)
													And LT.For_Date Between @From_Date_Cur And @To_Date_Cur )				
										Begin
											Insert Into #Leave_Used (Emp_Id,Leave_Id,Cmp_ID,Leave_Code,Leave_Name,Month,Year,Leave_Used,Leave_Dates,Leave_Opening,Leave_closing)
											Select LT.EMP_ID,LT.Leave_Id,LT.CMP_ID, @Leave_Code,@Leave_Name, Month(@From_Date) As [Month],Year(@From_Date) As [Year],LT.Leave_Used,
												@Leave_Code + '-' + STUFF(
													(SELECT ', ' + CONVERT(VARCHAR(5), FOR_DATE, 103) + (CASE WHEN Leave_Used % 1 <> 0 THEN ' (HF)' ELSE '' END)
													FROM	T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK)
													WHERE	LT1.Cmp_ID=LT.CMP_ID AND LT1.EMP_ID=LT.EMP_ID AND LT1.LEAVE_ID=LT.LEAVE_ID AND (Leave_Used > 0 or LT1.Back_Dated_Leave >0)
														--And Month(For_Date) = Month(@From_Date) And Year(For_Date) = YEAR(@From_Date)
														And For_Date Between @From_Date_Cur And @To_Date_Cur
													FOR XML PATH('')), 1, 1, ''
												) + Case When Penalty_Leave >0 THEN ', Penalty:' + Cast(Penalty_Leave as varchar(10)) Else '' End AS LEAVE_DATE,0,0
											From (
												Select LT.CMP_ID, LT.EMP_ID, LT.Leave_Id,isnull(SUM(Leave_used),0)+ isnull(SUM(Back_Dated_Leave),0) + Isnull( Sum(LT.Leave_Adj_L_Mark) ,0)as Leave_Used, 
													Isnull(Sum(LT.Leave_Adj_L_Mark),0) as Penalty_Leave
												FROM	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
												Where LT.Leave_ID = @Leave_ID And Emp_ID = @Emp_ID_Cur
													--And Month(For_Date) = Month(@From_Date) And Year(For_Date) = YEAR(@From_Date)
													And For_Date Between @From_Date_Cur And @To_Date_Cur
													--AND (Leave_Used > 0 or LT.Back_Dated_Leave >0)
												Group by LT.CMP_ID, LT.Emp_Id, LT.Leave_ID
												--HAVING 	SUM(Leave_used)+ SUM(Back_Dated_Leave) > 1
											) LT									
											
											---------added jimit 20012016-------------
											Update 	EL
											SET El.Leave_Opening = Q.Leave_Opening
											FROM #Leave_Used EL inner JOIN 
											(
												select top 1 Leave_Opening,Emp_ID,Leave_ID, For_Date
												from    t0140_leave_transaction WITH (NOLOCK)
												Where   cmp_Id =@Cmp_ID 
														--and Month(FOR_DATE) = month(@From_Date) and Year(FOR_DATE) = Year(@From_Date) 
														And For_Date Between @From_Date_Cur And @To_Date_Cur
														and Emp_ID = @Emp_ID_Cur	and 
														Leave_ID = @Leave_Id
												ORDER by for_date ASC			
											)Q On Q.Emp_ID = El.Emp_Id and Q.Leave_ID = El.Leave_Id
											where (EL.Month) = Month(@From_Date) and (El.Year) = Year(@From_Date)-- EL.Leave_Id = @Leave_Id and EL.Emp_Id = @Emp_ID_Cur and 
											
											Update 	EL
											SET El.Leave_closing = Q.Leave_Closing
											FROM #Leave_Used EL inner JOIN 
											(
												select top 1 Leave_Closing,Emp_ID,Leave_ID, For_Date
												from    t0140_leave_transaction WITH (NOLOCK)
												Where   cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@From_Date) and 
														Year(FOR_DATE) = Year(@From_Date) and Emp_ID = @Emp_ID_Cur	and 
														Leave_ID = @Leave_Id
												ORDER by for_date DESC				
											)Q On Q.Emp_ID = El.Emp_Id and Q.Leave_ID = El.Leave_Id
											where (EL.Month) = Month(@From_Date) and (El.Year) = Year(@From_Date) --EL.Leave_Id = @Leave_Id and EL.Emp_Id = @Emp_ID_Cur and (EL.Month) = Month(@From_Date) and (El.Year) = Year(@From_Date)
											
											---------ended jimit 20012016-------------
											
											--Select LT.Emp_Id, LT.Leave_Id, @Cmp_ID, @Leave_Code,@Leave_Name, Month(For_Date) As [Month],Year(For_Date) As [Year],
											--	SUM(Leave_used)+ SUM(Back_Dated_Leave) as Leave_Used 
											--From T0140_LEAVE_TRANSACTION LT
											--Where LT.Cmp_ID = @CMP_ID 
											--	And LT.Leave_ID = @Leave_ID And Emp_ID = @Emp_ID_Cur
											--	And Month(For_Date) = Month(@From_Date) And Year(For_Date) = YEAR(@From_Date)
											--Group by LT.Emp_Id, LT.Leave_ID,Month(For_Date),Year(For_Date)
											--Order by LT.Emp_Id, LT.Leave_ID,Month(For_Date),Year(For_Date)


										End
									Else
										Begin
											Insert Into #Leave_Used (Emp_Id,Leave_Id,Cmp_ID,Leave_Code,Leave_Name,Month,Year,Leave_Used,Leave_Opening,Leave_closing)
											
											Select @Emp_ID_Cur, @Leave_ID, @Cmp_ID, @Leave_Code,@Leave_Name, Month(@From_Date) As [Month],Year(@From_Date) As [Year],0,0,0
											
										End
								END
							
							Set @From_Date = DATEADD(mm,1,@From_Date)
						End					
						
						Set @From_Date = @From_Date_Temp 
					fetch next from cur_Leave into @Leave_ID,@Leave_Code,@Leave_Name
				end 
			close cur_Leave
			Deallocate cur_Leave

			Set @From_Date = @From_Date_Temp 
			
			fetch next from Cur_Emp into @Emp_ID_Cur 
		end 
	close cur_Emp
	Deallocate cur_Emp
	
	
Select * from #Leave_Used  ORDER BY Leave_Id	

/*	
--------------------- Modify Jignesh Patel 11-Oct-2021----------------
---Select * from #Leave_Used  ORDER BY Leave_Id
----partition by El.Emp_id, El.Leave_id

DECLARE @empId int 
Declare @cmpid int
Declare @Row_No int
Declare @Leave_closing decimal(18,2)
Declare @Leave_Used decimal(18,2)


Declare @CurForDate datetime
Declare @curLeavid int

Create Table #tblYear
(
ForDate Datetime
)


DECLARE @ForDate datetime 

SET @ForDate=@From_Date

WHILE ( @ForDate <= @To_Date)
BEGIN
    ---PRINT 'The counter value is = ' + CONVERT(VARCHAR,@ForDate)
	Insert into #tblYear(ForDate) select @ForDate
    SET @ForDate  = Dateadd(month,1,@ForDate)
END


Select EL.*,Ty.Emp_ID as EmpId ,Ty.ForDate,Ty.Cmp_ID as CmpId,Ty.Leave_Id as LeaveID, ROW_NUMBER() Over ( partition by ty.Emp_id, ty.Leave_id order by EL.Emp_ID,El.Leave_id) as SrNo
Into #tblLeaveData
	from #Leave_Used as EL 
	Right Outer Join (Select Distinct cmp_id ,Emp_ID,ForDate,Leave_Id from #Leave_Used
						Cross join #tblYear) TY
	On EL.Emp_ID = Ty.Emp_ID And month(TY.ForDate) = EL.Month  And year(TY.ForDate) = EL.Year And Ty.Leave_Id = EL.Leave_Id 

----Select * from #Leave_Used  ORDER BY Leave_Id

DECLARE emp_cursor CURSOR FOR
SELECT SrNo,Empid,CmpId,ForDate,LeaveID from #tblLeaveData
Order by Emp_id, Leave_id,SrNo 

OPEN emp_cursor

FETCH NEXT FROM emp_cursor INTO @Row_No,@empId,@cmpid,@CurForDate,@curLeavid


WHILE @@FETCH_STATUS = 0
BEGIN
    
	Select @Leave_closing =Isnull(Leave_closing,0),@Leave_Used =Isnull(Leave_Used,0)  from  #tblLeaveData 
	where empid= @empId And SrNo=@Row_No-1


	Update #tblLeaveData SEt Cmp_ID = @cmpid, Emp_id = @empid, 
	Leave_Id = @curLeavid,
	Leave_closing = isnull(@Leave_closing,0) ,
	Leave_Used  = isnull(@Leave_Used,0) ,
	--,Month_St_Date = @CurForDate,Month_End_Date = dateadd(day,-1,dateadd(month,1,@CurForDate))  ,
	[month]= month(@CurForDate),[year]= year(@CurForDate)
	where empid= @empId And SrNo=@Row_No and isnull(Leave_closing,0) =0
	and LeaveId =@curLeavid
	
    FETCH NEXT FROM emp_cursor INTO  @Row_No,@empId,@cmpid,@CurForDate,@curLeavid

END
CLOSE emp_cursor;
DEALLOCATE emp_cursor;

select * from #tblLeaveData
order by Emp_id,month,year,Leave_Id ,srno

----------------------- End --------------------------
*/

	
	Select DISTINCT Leave_Code,Leave_Id from #Leave_Used ORDER BY Leave_Id--Group by Leave_Code
	
	Select Emp_Id,Month,Year,COALESCE(Leave_Dates,',' ,'' ) as Leave_Dates from #Leave_Used Where not Leave_Dates is null  Group by Emp_Id,Month,Year,Leave_Dates

-- added by rohit for total leave used on 30122016
	Select Emp_Id,Leave_Id,Cmp_ID,Leave_Code,Leave_Name,SUM(Leave_Used) as Leave_used  from #Leave_Used  group by Emp_Id,Leave_Id,Cmp_ID,Leave_Code,Leave_Name ORDER BY Leave_Id
	

	--Select Emp_Id, LT.Leave_Id, LM.Leave_Code,LM.Leave_Name, Month(For_Date) As [Month],Year(For_Date) As [Year],SUM(Leave_used) Leave_Used 
	--From T0140_LEAVE_TRANSACTION LT Inner Join T0040_LEAVE_MASTER LM On LT.Leave_ID = LM.Leave_ID
	--Where LT.Cmp_ID = @CMP_ID 
	--And LT.Leave_ID In
	--	(Select Leave_ID from T0040_LEAVE_MASTER Where Leave_Sorting_No in (1,2,3) and Cmp_ID = @CMP_ID)
	--And For_Date >= @From_Date And For_Date <= @To_Date
	--Group by Emp_Id, LT.Leave_ID,	Month(For_Date),Year(For_Date),LM.Leave_Code,LM.Leave_Name
	--Order by Emp_Id, LT.Leave_ID,	Month(For_Date),Year(For_Date)
	
		
	RETURN




