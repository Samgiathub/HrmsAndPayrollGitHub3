-- ============================================= 
-- Author:		Hardik Barot
-- Create date: 23/03/2020
-- Description:	For Adjust Leave against Absent --- requirement by Kataria
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P_GET_AUTO_LEAVE_ADJUST_AGAINST_ABSENT]
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		varchar(Max)
	,@Cat_ID		varchar(Max)
	,@Grd_ID		varchar(Max)
	,@Type_ID		varchar(Max) 
	,@Dept_ID		varchar(Max)
	,@Desig_ID		varchar(Max)
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(max) = ''
	,@Segment_Id  varchar(Max) = ''	
	,@Vertical_Id varchar(Max) = ''	 
	,@SubVertical_Id varchar(Max) = ''	
	,@SubBranch_Id varchar(Max) = ''
	,@Report_Type varchar(50) = ''

AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	 CREATE table #Emp_Cons 
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )
	 CREATE CLUSTERED INDEX IX_EMP_CONS_EMPID ON #Emp_Cons (EMP_ID);

	EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_Id,0,0,0,'',0,0    

	CREATE TABLE #Att_Muster_with_shift1
	(
		Emp_Id		numeric , 
		Cmp_ID		numeric,
		For_Date	datetime,
		Status		varchar(10),
		Leave_Count	numeric(12,3),
		WO_HO		varchar(2),
		Status_2	varchar(10),
		Row_ID		numeric ,
		WO_HO_Day	numeric(4,1) default 0,
		P_days		numeric(12,3) default 0, 
		A_days		numeric(5,2) default 0,
		Join_Date	Datetime default null,
		Left_Date	Datetime default null,
		GatePass_Days numeric(18,2) default 0, 
		Late_deduct_Days numeric(18,2) default 0,  
		Early_deduct_Days numeric(18,2) default 0,  
		Shift_id	numeric,
		Leave_Id	varchar(10),
		Leave_Period Varchar(20)
	)

	Insert Into #Att_Muster_with_shift1
	EXEC SP_RPT_EMP_ATTENDANCE_MUSTER_GET @Cmp_ID=@Cmp_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Branch_ID=@Branch_Id,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,
			@Desig_ID=0,@Emp_ID=@Emp_ID,@Constraint=@Constraint,@Export_Type='999',@Report_For='Complete_Absent',@Con_Absent_Days=0,
			@P_Branch = @Branch_ID,@P_Department =@Dept_ID,@P_Vertical =@Vertical_Id,@P_SubVertical=@SubVertical_Id  
	
	
	
	SELECT * INTO #Emp_Cons_Actual FROM #Emp_Cons
	DELETE EC FROM #Emp_Cons EC WHERE EXISTS(SELECT 1 FROM #Att_Muster_with_shift1 LED WHERE LED.Emp_ID=EC.Emp_ID)



	SELECT	ROW_NUMBER() OVER(PARTITION BY Emp_ID ORDER BY Emp_ID,Leave_Sorting_No) As Row_ID,
			Emp_ID,LM.Leave_ID,Cast(0.0000 As Numeric(9,4)) As LeaveBalance,LM.Leave_Sorting_No, LM.Leave_Negative_Allow, 
			LM.leave_negative_max_limit, Cast(0.0000 As Numeric(9,4)) As LateAdjustDays, Cast(0.0000 As Numeric(9,4)) As EarlyAdjustDays,
			LM.Can_Apply_Fraction,LM.Leave_Min
	INTO	#EmpLeaveBalance
	FROM	#Emp_Cons_Actual EC 			
			CROSS JOIN (SELECT	Leave_ID,Leave_Negative_Allow,leave_negative_max_limit,
								Case When Default_Short_Name = 'LWP' Then 999 Else Leave_Sorting_No End Leave_Sorting_No,LM.Can_Apply_Fraction,LM.Leave_Min
						FROM	T0040_LEAVE_MASTER LM WITH (NOLOCK)
						WHERE	Cmp_Id = @Cmp_ID And (LM.Is_Auto_Leave_From_Salary = 1 OR Default_Short_Name = 'LWP')
						UNION ALL	
						SELECT	-1, -1,-999,9999,1,0) LM
	ORDER BY EC.Emp_ID,LM.Leave_Sorting_No
	

	UPDATE	ELB
	SET		LeaveBalance = LT.Leave_Closing
	FROM	#EmpLeaveBalance ELB
			INNER JOIN (SELECT	LT.EMP_ID, LT.Leave_ID, LT.Leave_Closing + Isnull(LT.Leave_Adj_L_Mark,0) As Leave_Closing
						FROM	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
								INNER JOIN #EmpLeaveBalance ELB1 ON LT.Emp_ID=ELB1.Emp_ID AND LT.Leave_ID=ELB1.Leave_ID
								INNER JOIN (SELECT	LT1.Emp_ID, LT1.Leave_ID, Max(For_Date) As For_Date
											FROM	T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK)
													INNER JOIN #EmpLeaveBalance ELB1 ON LT1.Emp_ID=ELB1.Emp_ID AND LT1.Leave_ID=ELB1.Leave_ID
											WHERE	LT1.For_Date <= @To_Date
											GROUP BY LT1.Emp_ID, LT1.Leave_ID) LT1 ON LT.Emp_ID=LT1.Emp_ID AND LT.Leave_ID=LT1.Leave_ID AND LT.For_Date=LT1.For_Date
						) LT ON ELB.Emp_ID=LT.Emp_ID AND ELB.Leave_ID=LT.Leave_ID
						
						

	DELETE ELB FROM	#EmpLeaveBalance ELB
	WHERE (LeaveBalance <= 0 AND Leave_ID > 0 AND Leave_Negative_Allow = 0)
		
		
	--DELETE THOSE LEAVES WHICH ARE NOT ASSIGNED TO EMPLOYEE'S GRADE
	DELETE ELB FROM #EmpLeaveBalance ELB
		LEFT OUTER JOIN (SELECT EC.Emp_Id,Leave_ID FROM #Emp_Cons_Actual EC Inner join 
								T0095_INCREMENT I WITH (NOLOCK) On EC.Increment_ID = I.Increment_ID and EC.Emp_ID=I.Emp_Id INNER JOIN
								V0040_LEAVE_DETAILS LD On I.Grd_ID=LD.Grd_ID
							WHERE ISNULL(InActive_Effective_Date,@TO_DATE)>=@To_Date) qry On Elb.Emp_ID = qry.Emp_ID and elb.Leave_ID = qry.Leave_ID 
	WHERE QRY.Leave_ID IS NULL and qry.Leave_ID = ELB.Leave_ID AND ELB.LEAVE_ID <> -1 AND Leave_Sorting_No<>999
	
	
	Update EL Set Row_ID = Qry.Row_ID
	From #EmpLeaveBalance EL Inner Join 
		(Select ROW_NUMBER() OVER(PARTITION BY Emp_ID ORDER BY Emp_ID,Leave_Sorting_No) As Row_ID, Emp_Id,Leave_ID
		From #EmpLeaveBalance) Qry On EL.Emp_id =Qry.Emp_Id And EL.Leave_Id = Qry.Leave_Id
 
	Declare @Emp_ID_C Numeric
	Declare @For_Date Datetime
	Declare @A_Days Numeric(5,4)
	Declare @Leave_Id int
	Declare @Count int
	Declare @Total_Count int
	Declare @Leave_Balance numeric(12,4)
	DECLARE @LEAVE_NEGATIVE_MAX_LIMIT NUMERIC(5,2)
	DECLARE @LEAVE_NEGATIVE_ALLOW NUMERIC
	

	DECLARE curLeaveAdjust CURSOR FAST_FORWARD FOR	                  
		Select Emp_Id, For_Date, A_Days from #Att_Muster_with_shift1 Order by For_Date	
	OPEN	curLeaveAdjust                      
	FETCH NEXT FROM curLeaveAdjust INTO @Emp_ID_C, @For_Date, @A_Days
	WHILE @@FETCH_STATUS = 0                    
		BEGIN   
			Set @Count =1
			Select @Total_Count = Count(1) 
			From #EmpLeaveBalance where Emp_Id = @Emp_ID_C
			
			While @Total_Count >= @Count
				Begin
					Select @Leave_Id=Leave_Id, @Leave_Balance = LeaveBalance, @LEAVE_NEGATIVE_MAX_LIMIT = leave_negative_max_limit,
							@LEAVE_NEGATIVE_ALLOW = Leave_Negative_Allow
					From #EmpLeaveBalance 
					Where Emp_Id = @Emp_ID_C And Row_Id = @Count
					
					If (@Leave_Balance >= @A_Days And @Leave_Balance > 0) OR (@LEAVE_NEGATIVE_ALLOW = 1 AND ABS(@Leave_Balance) <= @LEAVE_NEGATIVE_MAX_LIMIT AND (@LEAVE_NEGATIVE_MAX_LIMIT - ABS(@Leave_Balance)) >= @A_Days)
						Begin
						
							If exists(Select 1 From #Att_Muster_with_shift1 Where Emp_Id = @Emp_ID_C And For_Date =@For_Date And Leave_Id <> 0 )
								Begin
									Insert Into #Att_Muster_with_shift1
									Select Emp_Id, Cmp_ID, For_Date, Status,Leave_Count	,WO_HO,Status_2,Row_ID,WO_HO_Day,P_days,A_days,Join_Date,Left_Date,GatePass_Days,Late_deduct_Days,Early_deduct_Days,Shift_id ,@Leave_Id,@A_Days
									From #Att_Muster_with_shift1 Where Emp_Id = @Emp_ID_C And For_Date =@For_Date And Leave_Id <> 0 
								End
							Else
								Begin
									Update #Att_Muster_with_shift1 Set Leave_Id= @Leave_Id, Leave_Period = @A_Days Where Emp_Id = @Emp_ID_C And For_Date =@For_Date
								End
							Update #EmpLeaveBalance Set LeaveBalance = LeaveBalance - @A_Days Where Emp_Id=@Emp_ID_C And Leave_Id = @Leave_Id
							Break;
						End
					Else if @Leave_Balance < @A_Days And @Leave_Balance >0
						Begin
						
							Update #EmpLeaveBalance Set LeaveBalance = 0 Where Emp_Id=@Emp_ID_C And Leave_Id = @Leave_Id
							Update #Att_Muster_with_shift1 Set Leave_Id=@Leave_Id, Leave_Period = @Leave_Balance, A_days=A_Days - @Leave_Balance 
							Where Emp_Id = @Emp_ID_C And For_Date =@For_Date
							Set @A_Days = @A_Days -  @Leave_Balance
						End


					Set @Count = @Count + 1
				End
			

			FETCH NEXT FROM curLeaveAdjust INTO @Emp_ID_C, @For_Date, @A_Days
		END
	CLOSE curLeaveAdjust
	DEALLOCATE curLeaveAdjust

	

	Select	AM.*, LM.Leave_Code, LM.Leave_Name 
	,E.Emp_code,E.Alpha_Emp_Code,E.Emp_Full_Name,B.Branch_Name,D.Dept_Name,
	       isnull(E.Alpha_Emp_Code,'') + ' - '  + E.Emp_Full_Name as Emp_Name,Qry_ERD.R_Emp_ID
			,0 as pM_Cancel_WO_HO 
			,case when am.Leave_Period = '0.5000' then 
				'First Half' 
				when Am.Leave_Period = '1.0000' then 
				'Full Day' 
			end as pLeave_Assign_As
	from	#Att_Muster_with_shift1 AM 
			INNER Join T0040_LEAVE_MASTER LM WITH (NOLOCK) On AM.Leave_Id = LM.Leave_ID 
			inner join #Emp_Cons_Actual EC on AM.Emp_Id = EC.Emp_ID
			inner join T0080_EMP_MASTER E WITH (NOLOCK) on EC.Emp_ID = E.Emp_ID
			INNER join T0095_INCREMENT I WITH (NOLOCK) on EC.Increment_ID = I.Increment_ID
			INNER join T0030_BRANCH_MASTER B WITH (NOLOCK) on i.Branch_ID = B.Branch_ID
			left join T0040_DEPARTMENT_MASTER D WITH (NOLOCK) on I.Dept_ID = D.Dept_Id
			left OUTER join ( 
								Select	ERD.* 
								from	T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK)
										inner join (
														Select	max(Effect_Date) as For_Date,Emp_ID
														From	T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
														where	Effect_Date <= @To_Date
														GROUP by Emp_ID
													)Qry on ERD.Emp_id = Qry.Emp_ID and ERD.Effect_Date = Qry.For_Date
							) Qry_ERD on AM.Emp_Id = Qry_ERD.Emp_ID
							Where ISNULL( AM.Left_Date,'')=''
	Order by Emp_Id, For_Date
  

	--;WITH T(Emp_ID,For_Date, A_Days, L_Days, Leave_Id,Leave_Sorting_No)
	--AS(
	--	Select	Att.Emp_Id, For_Date,  A_days, (Case When A_days > LeaveBalance Then LeaveBalance Else A_days END) As L_Days, ELB.Leave_ID,Leave_Sorting_No
	--	FROM	#Att_Muster_with_shift1 ATT
	--			INNER JOIN (SELECT * FROM #EmpLeaveBalance WHERE LeaveBalance > 0) ELB ON ATT.Emp_Id=ELB.Emp_ID
	--	WHERE	Leave_Sorting_No = (select top 1 Leave_Sorting_No From #EmpLeaveBalance E1 Where E1.LeaveBalance > 0 AND E1.Emp_ID=ATT.Emp_Id)
	--	UNION ALL
	--	Select	Att.Emp_Id, For_Date,  A_days, (Case When A_days > LeaveBalance Then LeaveBalance Else A_days END) As L_Days, ELB.Leave_ID,ELB.Leave_Sorting_No
	--	FROM	T ATT
	--			INNER JOIN (SELECT * FROM #EmpLeaveBalance WHERE LeaveBalance > 0) ELB ON ATT.Emp_Id=ELB.Emp_ID
	--	WHERE	ELB.Leave_Sorting_No >= ATT.Leave_Sorting_No AND (ATT.A_Days - ATT.L_Days) > 0
	--)
	--UPDATE ELB
	--SET		LeaveBalance= LeaveBalance - T.L_Days
	--FROM	#EmpLeaveBalance ELB
	--		INNER JOIN T ON ELB.Emp_ID=T.Emp_ID AND ELB.Leave_ID = T.Leave_ID
	--option(MAXRECURSION 0)

END
