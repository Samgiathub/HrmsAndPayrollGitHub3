
CREATE PROCEDURE [dbo].[Sp_Get_Cmp_Consolidated_Information]
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
	,@Filter Nvarchar(Max)=''
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
		
	if @Filter <>''
	begin
		set @chkConstraint = @chkConstraint + cast(@Filter as Nvarchar(Max)) 
	end
	
	

	-- Last Month Date
	Declare @St_Date as datetime
	Set @St_Date = REPLACE(CONVERT(VARCHAR(25),DATEADD(m,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE()), 0)),106),' ','-')
	Declare @End_Date as datetime
	Set @End_Date = REPLACE(CONVERT(VARCHAR(25),DATEADD(d,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE()),0)),106),' ','-') 
	
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
		
		
CREATE table #Emp
 (      
   Emp_ID numeric ,     
  Branch_ID numeric,
  Increment_ID numeric    
 )  

--if @chkConstraint <> ''
--begin

--set @chkConstraint = 'where ' + @chkConstraint
--end
	
Declare @Str_set as  nvarchar(max)
set @Str_set = ''
set @Str_set = @Str_set + 'INSERT INTO #Emp SELECT DISTINCT emp_id,branch_id,Increment_ID  FROM V_Emp_Cons where 1 = 1 ' + @chkConstraint +''
	
exec (@Str_set)
				
			--DELETE FROM #Emp WHERE Increment_ID Not In
			--	(SELECT TI.Increment_ID FROM t0095_increment TI inner join
			--		(SELECT Max(Increment_ID) AS Increment_ID,Emp_ID FROM T0095_Increment
			--			WHERE Increment_effective_Date <= @Cur_End_Date and Cmp_id=@Cmp_ID GROUP BY emp_ID) new_inc
			--	ON TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_ID=new_inc.Increment_ID
			--	WHERE Increment_effective_Date <= @Cur_End_Date)
	
	Delete E From #Emp E left Join (Select Max(Increment_ID)as inc from T0095_Increment
				Where  Increment_effective_Date <= @Cur_End_Date Group by emp_ID) as INC_d on E.increment_id = INC_d.inc where isnull(inc_d.inc,0)=0
		
	-- For Employee Details -----------------------------------------------------------------------------------------
	--IF @chkConstraint = ''
	--	BEGIN
	--		select '1) New Joining (Last 2 month)' as Data, COUNT(Emp_ID) as Cnt from T0080_EMP_MASTER Em left join T0010_Company_Master CM on Em.Cmp_ID = CM.Cmp_Id and CM.is_GroupOFCmp=1   WHERE isnull(Cm.Cmp_ID,0)<>0  And Date_Of_Join Between DATEADD(DAY,-60,GETDATE()) and GETDATE()
	--		UNION
	--		select '2) Left Employee (Last 2 month)' as Data, COUNT(Emp_ID) as Cnt from T0080_EMP_MASTER EM left join T0010_Company_Master CM on Em.Cmp_ID = CM.Cmp_Id and CM.is_GroupOFCmp=1     WHERE isnull(Cm.Cmp_ID,0)<>0  And Emp_Left = 'Y' AND Emp_Left_Date Between DATEADD(DAY,-60,GETDATE()) and GETDATE()
	--	END
	--ELSE
	--	BEGIN
	--		--Set @query = N'
	--		--select ''1) New Joining (Last 2 month)'' as Data, COUNT(Emp_ID) as Cnt from T0080_EMP_MASTER  WHERE Date_Of_Join Between DATEADD(DAY,-60,GETDATE()) and GETDATE() '+ @chkConstraint +'
	--		--UNION
	--		--select ''2) Left Employee (Last 2 month)'' as Data, COUNT(Emp_ID) as Cnt from T0080_EMP_MASTER  WHERE Emp_Left = ''Y'' AND Emp_Left_Date Between DATEADD(DAY,-60,GETDATE()) and GETDATE() '+ @chkConstraint+ ''
			
	--		Set @query = N'
	--		select ''1) New Joining (Last 2 month)'' as Data, COUNT(T0080_EMP_MASTER.Emp_ID) as Cnt from T0080_EMP_MASTER inner join #Emp on T0080_EMP_MASTER.emp_id = #Emp.emp_id WHERE Date_Of_Join Between DATEADD(DAY,-60,GETDATE()) and GETDATE() '+ @chkConstraint +'
	--		UNION
	--		select ''2) Left Employee (Last 2 month)'' as Data, COUNT(T0080_EMP_MASTER.Emp_ID) as Cnt from T0080_EMP_MASTER inner join #Emp on T0080_EMP_MASTER.emp_id = #Emp.emp_id  WHERE Emp_Left = ''Y'' AND Emp_Left_Date Between DATEADD(DAY,-60,GETDATE()) and GETDATE() '+ @chkConstraint+ ''
			
	--		--select @query
	--		exec (@query)
	--		Set @query = '' 
	--	END
		
		-- For Employee Details -----------------------------------------------------------------------------------------
		
			select '1) New Joining (Last 2 month)' as Data, COUNT(Em.Emp_ID) as Cnt from T0080_EMP_MASTER Em inner join #Emp on Em.emp_id = #Emp.emp_id left join T0010_Company_Master CM on Em.Cmp_ID = CM.Cmp_Id and CM.is_GroupOFCmp=1   WHERE isnull(Cm.Cmp_ID,0)<>0  And Date_Of_Join Between DATEADD(DAY,-60,GETDATE()) and GETDATE()
			UNION
			select '2) Left Employee (Last 2 month)' as Data, COUNT(Em.Emp_ID) as Cnt from T0080_EMP_MASTER EM inner join #Emp on Em.emp_id = #Emp.emp_id  left join T0010_Company_Master CM on Em.Cmp_ID = CM.Cmp_Id and CM.is_GroupOFCmp=1     WHERE isnull(Cm.Cmp_ID,0)<>0  And Emp_Left = 'Y' AND Emp_Left_Date Between DATEADD(DAY,-60,GETDATE()) and GETDATE()
		
	-----------------------------------------------------------------------------------------------------------------
	
	-- For Salary Details -------------------------------------------------------------------------------------------
	--IF @chkConstraint = ''
	--	BEGIN
	--		select '1) Salary Amount' as Data
	--		,PARSENAME(Convert(varchar,Convert(money,ISNULL(SUM(Net_Amount),0)),1),2) as 'Sum'
	--		,COUNT(Sal_Tran_ID) as Cnt from T0200_MONTHLY_SALARY MS left join T0010_Company_Master CM on MS.Cmp_ID = CM.Cmp_Id and CM.is_GroupOFCmp=1  where isnull(Cm.Cmp_ID,0)<> 0  And UPPER(Salary_Status) = 'DONE' And (Month_End_Date between @St_Date and @End_Date)
	--		UNION
	--		select '2) Salary On Hold' as Data
	--		,PARSENAME(Convert(varchar,Convert(money,ISNULL(SUM(Net_Amount),0)),1),2) as 'Sum'
	--		,COUNT(Sal_Tran_ID) as Cnt from T0200_MONTHLY_SALARY MS left join T0010_Company_Master CM on MS.Cmp_ID = CM.Cmp_Id and CM.is_GroupOFCmp=1  where isnull(Cm.Cmp_ID,0)<> 0   And UPPER(Salary_Status) = 'HOLD' And (Month_End_Date between @St_Date and @End_Date)
	--	END
	--ELSE
	--	BEGIN
	--		Set @query = N'
	--		select ''1) Salary Amount'' as Data,PARSENAME(Convert(varchar,Convert(money,ISNULL(SUM(Net_Amount),0)),1),2) as ''Sum'',COUNT(Sal_Tran_ID) as Cnt from T0200_MONTHLY_SALARY where UPPER(Salary_Status) = ''DONE'' And (Month_End_Date between '''+ REPLACE(Convert(varchar(30),@St_Date,106),' ','-') +''' and '''+ REPLACE(Convert(varchar(30),@End_Date,106),' ','-') +''') '+ @chkConstraint +'
	--		UNION
	--		select ''2) Salary On Hold'' as Data,PARSENAME(Convert(varchar,Convert(money,ISNULL(SUM(Net_Amount),0)),1),2) as ''Sum'',COUNT(Sal_Tran_ID) as Cnt from T0200_MONTHLY_SALARY where UPPER(Salary_Status) = ''HOLD'' And (Month_End_Date between '''+ REPLACE(Convert(varchar(30),@St_Date,106),' ','-') +''' and '''+ REPLACE(Convert(varchar(30),@End_Date,106),' ','-') +''') '+ @chkConstraint+ ''
	--		--select @query
	--		exec (@query)
	--		Set @query = '' 
	--	END
	-- For Salary Details -------------------------------------------------------------------------------------------
	
	
			select '1) Salary Amount' as Data
			,PARSENAME(Convert(varchar,Convert(money,ISNULL(SUM(Net_Amount),0)),1),2) as 'Sum'
			,COUNT(Sal_Tran_ID) as Cnt from T0200_MONTHLY_SALARY MS inner join #Emp on MS.emp_id = #Emp.emp_id  left join T0010_Company_Master CM on MS.Cmp_ID = CM.Cmp_Id and CM.is_GroupOFCmp=1  where isnull(Cm.Cmp_ID,0)<> 0  And UPPER(Salary_Status) = 'DONE' And (Month_End_Date between @St_Date and @End_Date)
			UNION
			select '2) Salary On Hold' as Data
			,PARSENAME(Convert(varchar,Convert(money,ISNULL(SUM(Net_Amount),0)),1),2) as 'Sum'
			,COUNT(Sal_Tran_ID) as Cnt from T0200_MONTHLY_SALARY MS inner join #Emp on MS.emp_id = #Emp.emp_id  left join T0010_Company_Master CM on MS.Cmp_ID = CM.Cmp_Id and CM.is_GroupOFCmp=1  where isnull(Cm.Cmp_ID,0)<> 0   And UPPER(Salary_Status) = 'HOLD' And (Month_End_Date between @St_Date and @End_Date)
	
	-----------------------------------------------------------------------------------------------------------------

	-- For Leave Details --------------------------------------------------------------------------------------------
	--IF @chkConstraint =''
	--	BEGIN
	--		Select '1) Total Leave Application' as Data, SUM(Cnt) as Cnt from (	
	--		Select COUNT(LA.Leave_Application_ID) as Cnt from T0110_LEAVE_APPLICATION_DETAIL LAD INNER JOIN 
	--		T0100_LEAVE_APPLICATION LA ON La.Leave_Application_ID = LAD.Leave_Application_ID
	--		left join T0010_Company_Master CM on LA.Cmp_ID = CM.Cmp_Id and CM.is_GroupOFCmp=1  
	--		where isnull(Cm.Cmp_ID,0)<> 0 
	--		AND (LAD.To_Date <= @Cur_End_Date AND LAD.From_Date >= @Cur_St_Date)
	--		Union
	--		select COUNT(LA.Leave_Approval_ID) as Cnt  from T0120_Leave_Approval LA inner join T0130_Leave_Approval_Detail LAD on LA.leave_approval_id=LAD.leave_approval_id  
	--		left join T0010_Company_Master CM on LA.Cmp_ID = CM.Cmp_Id and CM.is_GroupOFCmp=1 
	--		where isnull(Cm.Cmp_ID,0)<> 0  AND (LAD.To_Date <= @Cur_End_Date AND LAD.From_Date >= @Cur_St_Date) AND ISNULL(LA.Leave_Application_ID,0)= 0
	--		) as temp
	--		UNION		
	--		select '2) Leave Approve' as Data, COUNT(La.Leave_Approval_ID) as Cnt from T0120_Leave_Approval LA inner join T0130_Leave_Approval_Detail LAD on LA.leave_approval_id=LAD.leave_approval_id  
	--		left join T0010_Company_Master CM on LA.Cmp_ID = CM.Cmp_Id and CM.is_GroupOFCmp=1 
	--		where isnull(Cm.Cmp_ID,0)<> 0  AND (LAD.To_Date <= @Cur_End_Date AND LAD.From_Date >= @Cur_St_Date)
	--		And LA.Approval_Status = 'A'
	--		UNION
	--		select '3) Leave Reject' as Data, COUNT(La.Leave_Approval_ID) as Cnt from T0120_Leave_Approval LA inner join T0130_Leave_Approval_Detail LAD on LA.leave_approval_id=LAD.leave_approval_id  
	--		left join T0010_Company_Master CM on LA.Cmp_ID = CM.Cmp_Id and CM.is_GroupOFCmp=1 
	--		where isnull(Cm.Cmp_ID,0)<> 0   AND (LAD.To_Date <= @Cur_End_Date AND LAD.From_Date >= @Cur_St_Date)
	--		And LA.Approval_Status = 'R'
	--		UNION
	--		Select '4) Leave Pending' as Data, COUNT(LA.Leave_Application_ID) as Cnt from T0110_LEAVE_APPLICATION_DETAIL LAD INNER JOIN 
	--		T0100_LEAVE_APPLICATION LA ON La.Leave_Application_ID = LAD.Leave_Application_ID
	--		left join T0010_Company_Master CM on LA.Cmp_ID = CM.Cmp_Id and CM.is_GroupOFCmp=1 
	--		where isnull(Cm.Cmp_ID,0)<> 0   
	--		AND (Lad.To_Date <= @Cur_End_Date AND Lad.From_Date >= @Cur_St_Date) and La.Application_Status = 'P'
	--		UNION
	--		select '5) Amount Of Paid Leave' as Data
	--		,PARSENAME(Convert(varchar,Convert(money,ISNULL(SUM(Leave_Salary_Amount),0)),1),2) as Cnt
	--		from T0200_MONTHLY_SALARY MS
	--		left join T0010_Company_Master CM on MS.Cmp_ID = CM.Cmp_Id and CM.is_GroupOFCmp=1 
	--		where isnull(Cm.Cmp_ID,0)<> 0  And (Month_End_Date between @St_Date and @End_Date)
	--	END
	--ELSE	
	--	BEGIN
			
		
	--		if @CmpID <> 0
	--		begin
	--			set @chkConstraint = @chkConstraint + ' and LAD.Cmp_ID in ('+ cast(@CmpID as varchar(30)) + ')'
	--		end
			
	--		if @BranchID <> 0
	--		begin
	--			set @chkConstraint = @chkConstraint + ' and Branch_ID in (' + cast(@BranchID as varchar(30)) + ')'
	--		end
	 
	--		if @SubBranchID <> 0
	--			begin
	--				set @chkConstraint = @chkConstraint + ' and subBranch_ID in (' + cast(@SubBranchID as varchar(30)) + ')'
	--			end
			
	--		if @DesigID <> 0
	--			begin
	--				set @chkConstraint =  @chkConstraint + ' and Desig_Id in (' + cast(@DesigID as varchar(30)) + ')'
	--			end
			 
	--		if @DeptID <> 0
	--			begin
	--				set @chkConstraint = @chkConstraint +  ' and Dept_ID in (' + cast(@DeptID as varchar(30)) + ')'
	--			end
			 
	--		if @BusSegmentId <> 0
	--			begin
	--				set @chkConstraint = @chkConstraint + ' and Segment_ID in (' + cast(@BusSegmentId as varchar(30)) + ')'
	--			end
			 
	--		if @VerticalId <> 0
	--			begin
	--				set @chkConstraint = @chkConstraint + ' and Vertical_ID in (' + cast(@VerticalId as varchar(30)) + ')'
	--			end
			 
	--		if @SubVerticalId <> 0
	--			begin
	--				set @chkConstraint = @chkConstraint + ' and SubVertical_ID in (' + cast(@SubVerticalId as varchar(30)) + ')'
	--			end
			
	--		if @SalCycId <> 0
	--			begin
	--				set @chkConstraint = @chkConstraint + ' and SalDate_id in (' + cast(@SalCycId as varchar(30)) + ')'
	--			end
		
	--		Set @query = N'Select ''1) Total Leave Application'' as Data, SUM(Cnt) as Cnt from (	
	--			Select COUNT(LA.Leave_Application_ID) as Cnt from T0110_LEAVE_APPLICATION_DETAIL LAD INNER JOIN 
	--			T0100_LEAVE_APPLICATION LA ON La.Leave_Application_ID = LAD.Leave_Application_ID
	--			INNER JOIN (Select Emp_ID,Branch_ID,subBranch_ID,Dept_ID,Segment_ID,SalDate_id,Vertical_ID,SubVertical_ID,Desig_Id from T0095_INCREMENT as I where	(Increment_Effective_Date =
	--															 (SELECT        MAX(Increment_Effective_Date) AS For_Date
	--															   FROM            dbo.T0095_INCREMENT AS ssInc
	--															   WHERE        (Emp_ID = I.Emp_ID)
	--															   GROUP BY Emp_ID))) AS Qry ON LA.Emp_ID = Qry.Emp_ID
	--			where (To_Date <= '''+ REPLACE(Convert(varchar(30),@Cur_End_Date,106),' ','-') +''' AND From_Date >= '''+ REPLACE(Convert(varchar(30),@Cur_St_Date,106),' ','-') +''')
	--			'+ @chkConstraint +'
	--		Union
	--			select COUNT(LA.Leave_Approval_ID) as Cnt  from T0120_Leave_Approval LA inner join T0130_Leave_Approval_Detail LAD on LA.leave_approval_id=LAD.leave_approval_id  
	--			INNER JOIN (Select Emp_ID,Branch_ID,subBranch_ID,Dept_ID,Segment_ID,SalDate_id,Vertical_ID,SubVertical_ID,Desig_Id from T0095_INCREMENT as I where	(Increment_Effective_Date =
	--															 (SELECT        MAX(Increment_Effective_Date) AS For_Date
	--															   FROM            dbo.T0095_INCREMENT AS ssInc
	--															   WHERE        (Emp_ID = I.Emp_ID)
	--															   GROUP BY Emp_ID))) AS Qry ON LA.Emp_ID = Qry.Emp_ID
	--			where (To_Date <= '''+ REPLACE(Convert(varchar(30),@Cur_End_Date,106),' ','-') +''' AND From_Date >= '''+ REPLACE(Convert(varchar(30),@Cur_St_Date,106),' ','-') +''') AND ISNULL(LA.Leave_Application_ID,0)= 0
	--			'+ @chkConstraint +'
	--		) as temp
			
	--		UNION		
	--			select ''2) Leave Approve'' as Data, COUNT(La.Leave_Approval_ID) as Cnt from T0120_Leave_Approval LA inner join T0130_Leave_Approval_Detail LAD on LA.leave_approval_id=LAD.leave_approval_id  
	--			INNER JOIN (Select Emp_ID,Branch_ID,subBranch_ID,Dept_ID,Segment_ID,SalDate_id,Vertical_ID,SubVertical_ID,Desig_Id from T0095_INCREMENT as I where	(Increment_Effective_Date =
	--															 (SELECT        MAX(Increment_Effective_Date) AS For_Date
	--															   FROM            dbo.T0095_INCREMENT AS ssInc
	--															   WHERE        (Emp_ID = I.Emp_ID)
	--															   GROUP BY Emp_ID))) AS Qry ON LA.Emp_ID = Qry.Emp_ID
	--			where (To_Date <= '''+ REPLACE(Convert(varchar(30),@Cur_End_Date,106),' ','-') +''' AND From_Date >= '''+ REPLACE(Convert(varchar(30),@Cur_St_Date,106),' ','-') +''') And LA.Approval_Status = ''A''
	--			'+ @chkConstraint +'
	--		UNION
	--			select ''3) Leave Reject'' as Data, COUNT(La.Leave_Approval_ID) as Cnt from T0120_Leave_Approval LA inner join T0130_Leave_Approval_Detail LAD on LA.leave_approval_id=LAD.leave_approval_id  
	--			INNER JOIN (Select Emp_ID,Branch_ID,subBranch_ID,Dept_ID,Segment_ID,SalDate_id,Vertical_ID,SubVertical_ID,Desig_Id from T0095_INCREMENT as I where	(Increment_Effective_Date =
	--															 (SELECT        MAX(Increment_Effective_Date) AS For_Date
	--															   FROM            dbo.T0095_INCREMENT AS ssInc
	--															   WHERE        (Emp_ID = I.Emp_ID)
	--															   GROUP BY Emp_ID))) AS Qry ON LA.Emp_ID = Qry.Emp_ID
	--			where (To_Date <= '''+ REPLACE(Convert(varchar(30),@Cur_End_Date,106),' ','-') +''' AND From_Date >= '''+ REPLACE(Convert(varchar(30),@Cur_St_Date,106),' ','-') +''') And LA.Approval_Status = ''R''
	--			'+ @chkConstraint +'
	--		UNION
	--			Select ''4) Leave Pending'' as Data, COUNT(LA.Leave_Application_ID) as Cnt from T0110_LEAVE_APPLICATION_DETAIL LAD INNER JOIN 
	--			T0100_LEAVE_APPLICATION LA ON La.Leave_Application_ID = LAD.Leave_Application_ID
	--			INNER JOIN (Select Emp_ID,Branch_ID,subBranch_ID,Dept_ID,Segment_ID,SalDate_id,Vertical_ID,SubVertical_ID,Desig_Id from T0095_INCREMENT as I where	(Increment_Effective_Date =
	--															 (SELECT        MAX(Increment_Effective_Date) AS For_Date
	--															   FROM            dbo.T0095_INCREMENT AS ssInc
	--															   WHERE        (Emp_ID = I.Emp_ID)
	--															   GROUP BY Emp_ID))) AS Qry ON LA.Emp_ID = Qry.Emp_ID
	--			where (To_Date <= '''+ REPLACE(Convert(varchar(30),@Cur_End_Date,106),' ','-') +''' AND From_Date >= '''+ REPLACE(Convert(varchar(30),@Cur_St_Date,106),' ','-') +''') and La.Application_Status = ''P''
	--			'+ @chkConstraint +'
	--		UNION
	--			select ''5) Amount Of Paid Leave'' as Data
	--			,PARSENAME(Convert(varchar,Convert(money,ISNULL(SUM(Leave_Salary_Amount),0)),1),2) as Cnt
	--			from T0200_MONTHLY_SALARY LAD WITH(NOLOCK) 
	--			INNER JOIN (Select Emp_ID,Branch_ID,subBranch_ID,Dept_ID,Segment_ID,SalDate_id,Vertical_ID,SubVertical_ID,Desig_Id from T0095_INCREMENT as I where	(Increment_Effective_Date =
	--															 (SELECT        MAX(Increment_Effective_Date) AS For_Date
	--															   FROM            dbo.T0095_INCREMENT AS ssInc
	--															   WHERE        (Emp_ID = I.Emp_ID)
	--															   GROUP BY Emp_ID))) AS Qry ON LAD.Emp_ID = Qry.Emp_ID
	--			where (Month_End_Date between '''+ REPLACE(Convert(varchar(30),@St_Date,106),' ','-') +''' and '''+ REPLACE(Convert(varchar(30),@End_Date,106),' ','-') +''')
	--			'+ @chkConstraint +''
				
	--			Select @query
	--			exec (@query)
	--			Set @query = '' 
	--	END
	
	-- For Leave Details --------------------------------------------------------------------------------------------
		Select '1) Total Leave Application' as Data, SUM(Cnt) as Cnt from (	
			Select COUNT(LA.Leave_Application_ID) as Cnt from T0110_LEAVE_APPLICATION_DETAIL LAD INNER JOIN 
			T0100_LEAVE_APPLICATION LA ON La.Leave_Application_ID = LAD.Leave_Application_ID inner join #Emp on La.emp_id = #Emp.emp_id 
			left join T0010_Company_Master CM on LA.Cmp_ID = CM.Cmp_Id and CM.is_GroupOFCmp=1  
			where isnull(Cm.Cmp_ID,0)<> 0 
			AND (LAD.To_Date <= @Cur_End_Date AND LAD.From_Date >= @Cur_St_Date)
			Union
			select COUNT(LA.Leave_Approval_ID) as Cnt  from T0120_Leave_Approval LA inner join T0130_Leave_Approval_Detail LAD on LA.leave_approval_id=LAD.leave_approval_id  inner join #Emp on La.emp_id = #Emp.emp_id 
			left join T0010_Company_Master CM on LA.Cmp_ID = CM.Cmp_Id and CM.is_GroupOFCmp=1 
			where isnull(Cm.Cmp_ID,0)<> 0  AND (LAD.To_Date <= @Cur_End_Date AND LAD.From_Date >= @Cur_St_Date) AND ISNULL(LA.Leave_Application_ID,0)= 0
			) as temp
			UNION		
			select '2) Leave Approve' as Data, COUNT(La.Leave_Approval_ID) as Cnt from T0120_Leave_Approval LA inner join T0130_Leave_Approval_Detail LAD on LA.leave_approval_id=LAD.leave_approval_id  inner join #Emp on La.emp_id = #Emp.emp_id 
			left join T0010_Company_Master CM on LA.Cmp_ID = CM.Cmp_Id and CM.is_GroupOFCmp=1 
			where isnull(Cm.Cmp_ID,0)<> 0  AND (LAD.To_Date <= @Cur_End_Date AND LAD.From_Date >= @Cur_St_Date)
			And LA.Approval_Status = 'A'
			UNION
			select '3) Leave Reject' as Data, COUNT(La.Leave_Approval_ID) as Cnt from T0120_Leave_Approval LA inner join T0130_Leave_Approval_Detail LAD on LA.leave_approval_id=LAD.leave_approval_id  inner join #Emp on La.emp_id = #Emp.emp_id 
			left join T0010_Company_Master CM on LA.Cmp_ID = CM.Cmp_Id and CM.is_GroupOFCmp=1 
			where isnull(Cm.Cmp_ID,0)<> 0   AND (LAD.To_Date <= @Cur_End_Date AND LAD.From_Date >= @Cur_St_Date)
			And LA.Approval_Status = 'R'
			UNION
			Select '4) Leave Pending' as Data, COUNT(LA.Leave_Application_ID) as Cnt from T0110_LEAVE_APPLICATION_DETAIL LAD INNER JOIN 
			T0100_LEAVE_APPLICATION LA ON La.Leave_Application_ID = LAD.Leave_Application_ID inner join #Emp on La.emp_id = #Emp.emp_id 
			left join T0010_Company_Master CM on LA.Cmp_ID = CM.Cmp_Id and CM.is_GroupOFCmp=1 
			where isnull(Cm.Cmp_ID,0)<> 0   
			AND (Lad.To_Date <= @Cur_End_Date AND Lad.From_Date >= @Cur_St_Date) and La.Application_Status = 'P'
			UNION
			select '5) Amount Of Paid Leave' as Data
			,PARSENAME(Convert(varchar,Convert(numeric(18,2),ISNULL(SUM(Leave_Salary_Amount),0)),1),2) as Cnt
			from T0200_MONTHLY_SALARY MS inner join #Emp on MS.emp_id = #Emp.emp_id 
			left join T0010_Company_Master CM on MS.Cmp_ID = CM.Cmp_Id and CM.is_GroupOFCmp=1 
			where isnull(Cm.Cmp_ID,0)<> 0  And (Month_End_Date between @St_Date and @End_Date)
	
	-----------------------------------------------------------------------------------------------------------------
	
	-- For Loan Details ---------------------------------------------------------------------------------------------
	--IF @chkConstraint = ''
	--	BEGIN
	--			Select '1) Employee' as Data, SUM(Cnt) as Cnt from (
	--			select COUNT(LPR.Emp_ID) as Cnt from T0100_LOAN_APPLICATION LA inner join 
	--			T0120_LOAN_APPROVAL LPR On LA.Loan_App_ID = LPR.Loan_App_ID
	--			left join  T0010_COMPANY_MASTER CM on LA.cmp_id = Cm.cmp_id and is_GroupOFCmp = 1
	--			where isnull(cm.cmp_id,0)<>0
	--			and Loan_Apr_Status = 'A' And (Loan_Apr_Date between @Date and @Date1)
	--				UNION
	--			select COUNT(Emp_ID) as Cnt from T0120_LOAN_APPROVAL LA
	--			left join  T0010_COMPANY_MASTER CM on LA.cmp_id = Cm.cmp_id and is_GroupOFCmp = 1
	--			where isnull(cm.cmp_id,0)<>0
	--			and (Loan_Apr_Date between @Date and @Date1)
	--			And ISNULL(Loan_App_ID,0)  = 0) as temp
	--				UNION
	--			select '2) Loan will continue for next month' as Data, COUNT(Emp_ID) as Cnt from (
	--			select CASE WHEN Deduction_Type = 'Monthly' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
	--			WHEN Deduction_Type = 'Quaterly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
	--			WHEN Deduction_Type = 'Half Yearly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
	--			ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END as Finish_date
	--			,Loan_Apr_Date,Loan_Apr_No_of_Installment,Deduction_Type,Emp_ID from T0120_LOAN_APPROVAL LA
	--			left join  T0010_COMPANY_MASTER CM on LA.cmp_id = Cm.cmp_id and is_GroupOFCmp = 1
	--			where isnull(cm.cmp_id,0)<>0
	--			and (Loan_Apr_Date between @Date and @Date1)
	--			And ISNULL(Loan_App_ID,0)  = 0
	--			UNION ALL
	--			select CASE WHEN Deduction_Type = 'Monthly' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
	--			WHEN Deduction_Type = 'Quaterly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
	--			WHEN Deduction_Type = 'Half Yearly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
	--			ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END as Finish_date
	--			,Loan_Apr_Date,Loan_Apr_No_of_Installment,Deduction_Type,LA.Emp_ID from T0100_LOAN_APPLICATION LA inner join 
	--			T0120_LOAN_APPROVAL LPR On LA.Loan_App_ID = LPR.Loan_App_ID 
	--			left join  T0010_COMPANY_MASTER CM on LA.cmp_id = Cm.cmp_id and is_GroupOFCmp = 1
	--			where isnull(cm.cmp_id,0)<>0
	--			and Loan_Apr_Status = 'A' And (Loan_Apr_Date between @Date and @Date1)
	--			) as temp where MONTH(Finish_date) >= MONTH(DATEADD(MONTH,1,GETDATE())) AND YEAR(Finish_date) = YEAR(GETDATE())
	--			And (Finish_date between @Date and @Date1)			
	--				UNION
	--			select '3) Loan will finish in this month' as Data, COUNT(Emp_ID) as Cnt from (
	--			select CASE WHEN Deduction_Type = 'Monthly' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
	--			WHEN Deduction_Type = 'Quaterly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
	--			WHEN Deduction_Type = 'Half Yearly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
	--			ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END as Finish_date
	--			,Loan_Apr_Date,Loan_Apr_No_of_Installment,Deduction_Type,Emp_ID from T0120_LOAN_APPROVAL LA
	--			left join  T0010_COMPANY_MASTER CM on LA.cmp_id = Cm.cmp_id and is_GroupOFCmp = 1
	--			where isnull(cm.cmp_id,0)<>0
	--			and (Loan_Apr_Date between @Date and @Date1)
	--			And ISNULL(Loan_App_ID,0)  = 0
	--			UNION ALL
	--			select CASE WHEN Deduction_Type = 'Monthly' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
	--			WHEN Deduction_Type = 'Quaterly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
	--			WHEN Deduction_Type = 'Half Yearly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
	--			ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END as Finish_date
	--			,Loan_Apr_Date,Loan_Apr_No_of_Installment,Deduction_Type,LA.Emp_ID from T0100_LOAN_APPLICATION LA inner join 
	--			T0120_LOAN_APPROVAL LPR On LA.Loan_App_ID = LPR.Loan_App_ID 
	--			left join  T0010_COMPANY_MASTER CM on LA.cmp_id = Cm.cmp_id and is_GroupOFCmp = 1
	--			where isnull(cm.cmp_id,0)<>0
	--			and Loan_Apr_Status = 'A' And (Loan_Apr_Date between @Date and @Date1)
	--			) as temp where MONTH(Finish_date) = MONTH(GETDATE()) AND Year(Finish_date) = YEAR(GETDATE())
	--			And (Finish_date between @Date and @Date1)
	--				UNION
	--			select '4) Total EMI Deduct' as Data
	--			,CAST(ISNULL(SUM(Loan_Apr_Installment_Amount),0) as numeric) as Cnt from (
	--			select CASE WHEN Deduction_Type = 'Monthly' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
	--			WHEN Deduction_Type = 'Quaterly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
	--			WHEN Deduction_Type = 'Half Yearly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
	--			ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END as Finish_date
	--			,Loan_Apr_Date,Loan_Apr_No_of_Installment,Deduction_Type,Loan_Apr_Installment_Amount,Emp_ID from T0120_LOAN_APPROVAL LA
	--			left join  T0010_COMPANY_MASTER CM on LA.cmp_id = Cm.cmp_id and is_GroupOFCmp = 1
	--			where isnull(cm.cmp_id,0)<>0
	--			and (Loan_Apr_Date between @Date and @Date1)
	--			And ISNULL(Loan_App_ID,0)  = 0
	--			UNION ALL
	--			select CASE WHEN Deduction_Type = 'Monthly' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
	--			WHEN Deduction_Type = 'Quaterly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
	--			WHEN Deduction_Type = 'Half Yearly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
	--			ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END as Finish_date
	--			,Loan_Apr_Date,Loan_Apr_No_of_Installment,Deduction_Type,Loan_App_Installment_Amount,LA.Emp_ID from T0100_LOAN_APPLICATION LA inner join 
	--			T0120_LOAN_APPROVAL LPR On LA.Loan_App_ID = LPR.Loan_App_ID 
	--			left join  T0010_COMPANY_MASTER CM on LA.cmp_id = Cm.cmp_id and is_GroupOFCmp = 1
	--			where isnull(cm.cmp_id,0)<>0
	--			and Loan_Apr_Status = 'A' And (Loan_Apr_Date between @Date and @Date1)
	--			) as temp where MONTH(Finish_date) = MONTH(GETDATE()) AND Year(Finish_date) = YEAR(GETDATE())
	--	END
	--ELSE
	--	BEGIN
		
				
			
	--		if @CmpID <> 0
	--		begin
	--			set @chkConstraint = @chkConstraint + ' and LA.Cmp_ID in ('+ cast(@CmpID as varchar(30)) + ')'
	--		end
			
	--		if @BranchID <> 0
	--		begin
	--			set @chkConstraint = @chkConstraint + ' and Branch_ID in (' + cast(@BranchID as varchar(30)) + ')'
	--		end
	 
	--		if @SubBranchID <> 0
	--			begin
	--				set @chkConstraint = @chkConstraint + ' and subBranch_ID in (' + cast(@SubBranchID as varchar(30)) + ')'
	--			end
			
	--		if @DesigID <> 0
	--			begin
	--				set @chkConstraint =  @chkConstraint + ' and Desig_Id in (' + cast(@DesigID as varchar(30)) + ')'
	--			end
			 
	--		if @DeptID <> 0
	--			begin
	--				set @chkConstraint = @chkConstraint +  ' and Dept_ID in (' + cast(@DeptID as varchar(30)) + ')'
	--			end
			 
	--		if @BusSegmentId <> 0
	--			begin
	--				set @chkConstraint = @chkConstraint + ' and Segment_ID in (' + cast(@BusSegmentId as varchar(30)) + ')'
	--			end
			 
	--		if @VerticalId <> 0
	--			begin
	--				set @chkConstraint = @chkConstraint + ' and Vertical_ID in (' + cast(@VerticalId as varchar(30)) + ')'
	--			end
			 
	--		if @SubVerticalId <> 0
	--			begin
	--				set @chkConstraint = @chkConstraint + ' and SubVertical_ID in (' + cast(@SubVerticalId as varchar(30)) + ')'
	--			end
			
	--		if @SalCycId <> 0
	--			begin
	--				set @chkConstraint = @chkConstraint + ' and SalDate_id in (' + cast(@SalCycId as varchar(30)) + ')'
	--			end
				
	--			Set @query = N'Select ''1) Employee'' as Data, SUM(Cnt) as Cnt from (
	--			select COUNT(LPR.Emp_ID) as Cnt from T0100_LOAN_APPLICATION LA inner join 
	--			T0120_LOAN_APPROVAL LPR On LA.Loan_App_ID = LPR.Loan_App_ID 
	--			INNER JOIN (Select Emp_ID,Branch_ID,subBranch_ID,Dept_ID,Segment_ID,SalDate_id,Vertical_ID,SubVertical_ID,Desig_Id from T0095_INCREMENT as I where	(Increment_Effective_Date =
	--															 (SELECT        MAX(Increment_Effective_Date) AS For_Date
	--															   FROM            dbo.T0095_INCREMENT AS ssInc
	--															   WHERE        (Emp_ID = I.Emp_ID)
	--															   GROUP BY Emp_ID))) AS Qry ON LA.Emp_ID = Qry.Emp_ID
	--			where Loan_Apr_Status = ''A'' And (Loan_Apr_Date between '''+@Date+''' and '''+@Date1+''')
	--			'+ @chkConstraint +'
	--				UNION
	--			select COUNT(LA.Emp_ID) as Cnt from T0120_LOAN_APPROVAL LA
	--			INNER JOIN (Select Emp_ID,Branch_ID,subBranch_ID,Dept_ID,Segment_ID,SalDate_id,Vertical_ID,SubVertical_ID,Desig_Id from T0095_INCREMENT as I where	(Increment_Effective_Date =
	--															 (SELECT        MAX(Increment_Effective_Date) AS For_Date
	--															   FROM            dbo.T0095_INCREMENT AS ssInc
	--															   WHERE        (Emp_ID = I.Emp_ID)
	--															   GROUP BY Emp_ID))) AS Qry ON LA.Emp_ID = Qry.Emp_ID
	--			where (Loan_Apr_Date between '''+@Date+''' and '''+@Date1+''')
	--			And ISNULL(Loan_App_ID,0)  = 0 '+ @chkConstraint +'
	--			) as temp
				
	--				UNION
					
	--			select ''2) Loan will continue for next month'' as Data, COUNT(Emp_ID) as Cnt from (
	--			select CASE WHEN Deduction_Type = ''Monthly'' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
	--			WHEN Deduction_Type = ''Quaterly'' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
	--			WHEN Deduction_Type = ''Half Yearly'' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
	--			ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END as Finish_date
	--			,Loan_Apr_Date,Loan_Apr_No_of_Installment,Deduction_Type,LA.Emp_ID from T0120_LOAN_APPROVAL LA
	--			INNER JOIN (Select Emp_ID,Branch_ID,subBranch_ID,Dept_ID,Segment_ID,SalDate_id,Vertical_ID,SubVertical_ID,Desig_Id from T0095_INCREMENT as I where	(Increment_Effective_Date =
	--															 (SELECT        MAX(Increment_Effective_Date) AS For_Date
	--															   FROM            dbo.T0095_INCREMENT AS ssInc
	--															   WHERE        (Emp_ID = I.Emp_ID)
	--															   GROUP BY Emp_ID))) AS Qry ON LA.Emp_ID = Qry.Emp_ID
	--			where (Loan_Apr_Date between '''+@Date+''' and '''+@Date1+''')
	--			And ISNULL(Loan_App_ID,0)  = 0 '+ @chkConstraint +'
				
	--			UNION ALL
				
	--			select CASE WHEN Deduction_Type = ''Monthly'' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
	--			WHEN Deduction_Type = ''Quaterly'' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
	--			WHEN Deduction_Type = ''Half Yearly'' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
	--			ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END as Finish_date
	--			,Loan_Apr_Date,Loan_Apr_No_of_Installment,Deduction_Type,LA.Emp_ID from T0100_LOAN_APPLICATION LA inner join 
	--			T0120_LOAN_APPROVAL LPR On LA.Loan_App_ID = LPR.Loan_App_ID 
	--			INNER JOIN (Select Emp_ID,Branch_ID,subBranch_ID,Dept_ID,Segment_ID,SalDate_id,Vertical_ID,SubVertical_ID,Desig_Id from T0095_INCREMENT as I where	(Increment_Effective_Date =
	--															 (SELECT        MAX(Increment_Effective_Date) AS For_Date
	--															   FROM            dbo.T0095_INCREMENT AS ssInc
	--															   WHERE        (Emp_ID = I.Emp_ID)
	--															   GROUP BY Emp_ID))) AS Qry ON LA.Emp_ID = Qry.Emp_ID			
	--			where Loan_Apr_Status = ''A'' And (Loan_Apr_Date between '''+@Date+''' and '''+@Date1+''')
	--			'+ @chkConstraint +'
	--			) as temp where MONTH(Finish_date) >= MONTH(DATEADD(MONTH,1,GETDATE())) AND YEAR(Finish_date) = YEAR(GETDATE())
				
	--				UNION
					
	--			select ''3) Loan will finish in this month'' as Data, COUNT(Emp_ID) as Cnt from (
	--			select CASE WHEN Deduction_Type = ''Monthly'' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
	--			WHEN Deduction_Type = ''Quaterly'' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
	--			WHEN Deduction_Type = ''Half Yearly'' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
	--			ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END as Finish_date
	--			,Loan_Apr_Date,Loan_Apr_No_of_Installment,Deduction_Type,La.Emp_ID from T0120_LOAN_APPROVAL  La
	--			INNER JOIN (Select Emp_ID,Branch_ID,subBranch_ID,Dept_ID,Segment_ID,SalDate_id,Vertical_ID,SubVertical_ID,Desig_Id from T0095_INCREMENT as I where	(Increment_Effective_Date =
	--															 (SELECT        MAX(Increment_Effective_Date) AS For_Date
	--															   FROM            dbo.T0095_INCREMENT AS ssInc
	--															   WHERE        (Emp_ID = I.Emp_ID)
	--															   GROUP BY Emp_ID))) AS Qry ON LA.Emp_ID = Qry.Emp_ID
	--			where (Loan_Apr_Date between '''+@Date+''' and '''+@Date1+''')
	--			And ISNULL(Loan_App_ID,0)  = 0 '+ @chkConstraint +'
	--			UNION ALL
	--			select CASE WHEN Deduction_Type = ''Monthly'' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
	--			WHEN Deduction_Type = ''Quaterly'' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
	--			WHEN Deduction_Type = ''Half Yearly'' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
	--			ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END as Finish_date
	--			,Loan_Apr_Date,Loan_Apr_No_of_Installment,Deduction_Type,LA.Emp_ID from T0100_LOAN_APPLICATION LA inner join 
	--			T0120_LOAN_APPROVAL LPR On LA.Loan_App_ID = LPR.Loan_App_ID 
	--			INNER JOIN (Select Emp_ID,Branch_ID,subBranch_ID,Dept_ID,Segment_ID,SalDate_id,Vertical_ID,SubVertical_ID,Desig_Id from T0095_INCREMENT as I where	(Increment_Effective_Date =
	--															 (SELECT        MAX(Increment_Effective_Date) AS For_Date
	--															   FROM            dbo.T0095_INCREMENT AS ssInc
	--															   WHERE        (Emp_ID = I.Emp_ID)
	--															   GROUP BY Emp_ID))) AS Qry ON LA.Emp_ID = Qry.Emp_ID
	--			where Loan_Apr_Status = ''A'' And (Loan_Apr_Date between '''+@Date+''' and '''+@Date1+''')
	--			'+ @chkConstraint +'
	--			) as temp where MONTH(Finish_date) = MONTH(GETDATE()) AND Year(Finish_date) = YEAR(GETDATE())
				
	--				UNION
	--			select ''4) Total EMI Deduct'' as Data, CAST(ISNULL(SUM(Loan_Apr_Installment_Amount),0) as numeric) as Cnt from (
	--			select CASE WHEN Deduction_Type = ''Monthly'' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
	--			WHEN Deduction_Type = ''Quaterly'' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
	--			WHEN Deduction_Type = ''Half Yearly'' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
	--			ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END as Finish_date
	--			,Loan_Apr_Date,Loan_Apr_No_of_Installment,Deduction_Type,Loan_Apr_Installment_Amount,La.Emp_ID from T0120_LOAN_APPROVAL La 
	--			INNER JOIN (Select Emp_ID,Branch_ID,subBranch_ID,Dept_ID,Segment_ID,SalDate_id,Vertical_ID,SubVertical_ID,Desig_Id from T0095_INCREMENT as I where	(Increment_Effective_Date =
	--															 (SELECT        MAX(Increment_Effective_Date) AS For_Date
	--															   FROM            dbo.T0095_INCREMENT AS ssInc
	--															   WHERE        (Emp_ID = I.Emp_ID)
	--															   GROUP BY Emp_ID))) AS Qry ON LA.Emp_ID = Qry.Emp_ID
	--			where (Loan_Apr_Date between '''+@Date+''' and '''+@Date1+''')
	--			And ISNULL(Loan_App_ID,0)  = 0 '+ @chkConstraint +'
	--			UNION ALL
	--			select CASE WHEN Deduction_Type = ''Monthly'' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
	--			WHEN Deduction_Type = ''Quaterly'' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
	--			WHEN Deduction_Type = ''Half Yearly'' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
	--			ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END as Finish_date
	--			,Loan_Apr_Date,Loan_Apr_No_of_Installment,Deduction_Type,Loan_App_Installment_Amount,LA.Emp_ID from T0100_LOAN_APPLICATION LA inner join 
	--			T0120_LOAN_APPROVAL LPR On LA.Loan_App_ID = LPR.Loan_App_ID 
	--			INNER JOIN (Select Emp_ID,Branch_ID,subBranch_ID,Dept_ID,Segment_ID,SalDate_id,Vertical_ID,SubVertical_ID,Desig_Id from T0095_INCREMENT as I where	(Increment_Effective_Date =
	--															 (SELECT        MAX(Increment_Effective_Date) AS For_Date
	--															   FROM            dbo.T0095_INCREMENT AS ssInc
	--															   WHERE        (Emp_ID = I.Emp_ID)
	--															   GROUP BY Emp_ID))) AS Qry ON LA.Emp_ID = Qry.Emp_ID
	--			where Loan_Apr_Status = ''A'' And (Loan_Apr_Date between '''+@Date+''' and '''+@Date1+''')
	--			'+ @chkConstraint +'
	--			) as temp where MONTH(Finish_date) = MONTH(GETDATE()) AND Year(Finish_date) = YEAR(GETDATE())'
				
	--			--Select @query
	--			exec (@query)
	--			Set @query = ''
				
	--	END
	
	-- For Loan Details ---------------------------------------------------------------------------------------------
	
	Select '1) Employee' as Data, SUM(Cnt) as Cnt from (
				select COUNT(LPR.Emp_ID) as Cnt from T0100_LOAN_APPLICATION LA inner join 
				T0120_LOAN_APPROVAL LPR On LA.Loan_App_ID = LPR.Loan_App_ID inner join #Emp on LA.emp_id = #Emp.emp_id 
				left join  T0010_COMPANY_MASTER CM on LA.cmp_id = Cm.cmp_id and is_GroupOFCmp = 1
				where isnull(cm.cmp_id,0)<>0
				and Loan_Apr_Status = 'A' And (Loan_Apr_Date between @Date and @Date1)
					UNION
				select COUNT(La.Emp_ID) as Cnt from T0120_LOAN_APPROVAL LA inner join #Emp on LA.emp_id = #Emp.emp_id 
				left join  T0010_COMPANY_MASTER CM on LA.cmp_id = Cm.cmp_id and is_GroupOFCmp = 1
				where isnull(cm.cmp_id,0)<>0
				and (Loan_Apr_Date between @Date and @Date1)
				And ISNULL(Loan_App_ID,0)  = 0) as temp
					UNION
				select '2) Loan will continue for next month' as Data, COUNT(Emp_ID) as Cnt from (
				select CASE WHEN Deduction_Type = 'Monthly' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
				WHEN Deduction_Type = 'Quaterly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
				WHEN Deduction_Type = 'Half Yearly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
				ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END as Finish_date
				,Loan_Apr_Date,Loan_Apr_No_of_Installment,Deduction_Type,LA.Emp_ID from T0120_LOAN_APPROVAL LA inner join #Emp on LA.emp_id = #Emp.emp_id 
				left join  T0010_COMPANY_MASTER CM on LA.cmp_id = Cm.cmp_id and is_GroupOFCmp = 1
				where isnull(cm.cmp_id,0)<>0
				and (Loan_Apr_Date between @Date and @Date1)
				And ISNULL(Loan_App_ID,0)  = 0
				UNION ALL
				select CASE WHEN Deduction_Type = 'Monthly' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
				WHEN Deduction_Type = 'Quaterly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
				WHEN Deduction_Type = 'Half Yearly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
				ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END as Finish_date
				,Loan_Apr_Date,Loan_Apr_No_of_Installment,Deduction_Type,LA.Emp_ID from T0100_LOAN_APPLICATION LA inner join 
				T0120_LOAN_APPROVAL LPR On LA.Loan_App_ID = LPR.Loan_App_ID  inner join #Emp on LA.emp_id = #Emp.emp_id 
				left join  T0010_COMPANY_MASTER CM on LA.cmp_id = Cm.cmp_id and is_GroupOFCmp = 1
				where isnull(cm.cmp_id,0)<>0
				and Loan_Apr_Status = 'A' And (Loan_Apr_Date between @Date and @Date1)
				) as temp where MONTH(Finish_date) >= MONTH(DATEADD(MONTH,1,GETDATE())) AND YEAR(Finish_date) = YEAR(GETDATE())
				And (Finish_date between @Date and @Date1)			
					UNION
				select '3) Loan will finish in this month' as Data, COUNT(Emp_ID) as Cnt from (
				select CASE WHEN Deduction_Type = 'Monthly' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
				WHEN Deduction_Type = 'Quaterly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
				WHEN Deduction_Type = 'Half Yearly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
				ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END as Finish_date
				,Loan_Apr_Date,Loan_Apr_No_of_Installment,Deduction_Type,LA.Emp_ID from T0120_LOAN_APPROVAL LA inner join #Emp on LA.emp_id = #Emp.emp_id 
				left join  T0010_COMPANY_MASTER CM on LA.cmp_id = Cm.cmp_id and is_GroupOFCmp = 1
				where isnull(cm.cmp_id,0)<>0
				and (Loan_Apr_Date between @Date and @Date1)
				And ISNULL(Loan_App_ID,0)  = 0
				UNION ALL
				select CASE WHEN Deduction_Type = 'Monthly' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
				WHEN Deduction_Type = 'Quaterly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
				WHEN Deduction_Type = 'Half Yearly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
				ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END as Finish_date
				,Loan_Apr_Date,Loan_Apr_No_of_Installment,Deduction_Type,LA.Emp_ID from T0100_LOAN_APPLICATION LA inner join 
				T0120_LOAN_APPROVAL LPR On LA.Loan_App_ID = LPR.Loan_App_ID inner join #Emp on LA.emp_id = #Emp.emp_id 
				left join  T0010_COMPANY_MASTER CM on LA.cmp_id = Cm.cmp_id and is_GroupOFCmp = 1
				where isnull(cm.cmp_id,0)<>0
				and Loan_Apr_Status = 'A' And (Loan_Apr_Date between @Date and @Date1)
				) as temp where MONTH(Finish_date) = MONTH(GETDATE()) AND Year(Finish_date) = YEAR(GETDATE())
				And (Finish_date between @Date and @Date1)
					UNION
				select '4) Total EMI Deduct' as Data
				,CAST(ISNULL(SUM(Loan_Apr_Installment_Amount),0) as numeric) as Cnt from (
				select CASE WHEN Deduction_Type = 'Monthly' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
				WHEN Deduction_Type = 'Quaterly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
				WHEN Deduction_Type = 'Half Yearly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
				ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END as Finish_date
				,Loan_Apr_Date,Loan_Apr_No_of_Installment,Deduction_Type,Loan_Apr_Installment_Amount,LA.Emp_ID from T0120_LOAN_APPROVAL LA inner join #Emp on LA.emp_id = #Emp.emp_id 
				left join  T0010_COMPANY_MASTER CM on LA.cmp_id = Cm.cmp_id and is_GroupOFCmp = 1
				where isnull(cm.cmp_id,0)<>0
				and (Loan_Apr_Date between @Date and @Date1)
				And ISNULL(Loan_App_ID,0)  = 0
				UNION ALL
				select CASE WHEN Deduction_Type = 'Monthly' THEN DATEADD (MONTH, Loan_Apr_No_of_Installment,Loan_Apr_Date)
				WHEN Deduction_Type = 'Quaterly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 3),Loan_Apr_Date)
				WHEN Deduction_Type = 'Half Yearly' THEN DATEADD (MONTH, (Loan_Apr_No_of_Installment * 6),Loan_Apr_Date)
				ELSE DATEADD (MONTH, (Loan_Apr_No_of_Installment  * 12), Loan_Apr_Date) END as Finish_date
				,Loan_Apr_Date,Loan_Apr_No_of_Installment,Deduction_Type,Loan_App_Installment_Amount,LA.Emp_ID from T0100_LOAN_APPLICATION LA inner join 
				T0120_LOAN_APPROVAL LPR On LA.Loan_App_ID = LPR.Loan_App_ID inner join #Emp on LA.emp_id = #Emp.emp_id 
				left join  T0010_COMPANY_MASTER CM on LA.cmp_id = Cm.cmp_id and is_GroupOFCmp = 1
				where isnull(cm.cmp_id,0)<>0
				and Loan_Apr_Status = 'A' And (Loan_Apr_Date between @Date and @Date1)
				) as temp where MONTH(Finish_date) = MONTH(GETDATE()) AND Year(Finish_date) = YEAR(GETDATE())
	
	-----------------------------------------------------------------------------------------------------------------

	-- For Attendace Details ----------------------------------------------------------------------------------------
		DECLARE @PRESENTTBL TABLE  
		(  
			Total_Present   numeric,  
			Total_Absent numeric,
			EmpCnt Numeric 
		) 
		
		Insert into @PRESENTTBL
		exec SP_RPT_DAILY_ATTENDANCE_GET_NEW @Cmp_ID=@CmpID,@From_Date=@Current_Date,@To_Date=@Current_Date
		,@Branch_ID=@BranchID,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=@DeptID,@Desig_ID=@DesigID,@Emp_ID=0
		,@Shift_ID=0,@Constraint='',@Format=0,@PBranch_ID='0'
		,@SubBranch_Id = @SubBranch_ID,@BusSegement_Id = @Bus_Segment_Id 
		,@SalCyc_Id = @Sal_Cyc_Id,@Vertical_Id = @Vertical_Id,@SubVertical_Id =@SubVertical_Id

		Select '1) Today''s Present Count' as Data, (Select Total_Present from @PRESENTTBL) as Cnt
		UNION
		Select '2) Today''s Absent Count' as Data, (Select Total_Absent from @PRESENTTBL) as Cnt
		UNION
		Select '3) Total Employee ' as Data, (Select EmpCnt from @PRESENTTBL) as Cnt
	
	-----------------------------------------------------------------------------------------------------------------	

	-- For Late/Early Details ---------------------------------------------------------------------------------------
	DECLARE @LateOrEarlyCountToday TABLE  
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
	   Total_Less_Work_Hours varchar(20)

	) 
	
	DECLARE @LateOrEarlyCountYesteday TABLE  
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
	   Total_Less_Work_Hours varchar(20)
	) 
	

	DECLARE @TempCmp_Id Numeric	
	IF @chkConstraint = ''
		BEGIN
				Set @TempCmp_Id = 0
				DECLARE db_cursor CURSOR FOR  
					Select Cmp_Id from T0010_COMPANY_MASTER where is_GroupOFCmp = 1 
				OPEN db_cursor   
				FETCH NEXT FROM db_cursor INTO @TempCmp_Id  
				WHILE @@FETCH_STATUS = 0  
				BEGIN  
						INSERT INTO @LateOrEarlyCountToday
						exec P_InOut_Record_IN_CMP_Consol @Cmp_ID = @TempCmp_Id
						,@From_Date = @Current_Date ,@To_Date = @Current_Date
						,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0
						,@Constraint='',@Report_Call='SUMMARY',@PBranch_ID='0'
						,@SubBranch_Id = 0,@BusSegement_Id = 0 
						,@SalCyc_Id = 0,@Vertical_Id = 0,@SubVertical_Id =0

					   FETCH NEXT FROM db_cursor INTO @TempCmp_Id  
				END  
				CLOSE db_cursor  
				DEALLOCATE db_cursor
				
				

				Set @TempCmp_Id = 0
				DECLARE db_cursor CURSOR FOR  
					Select Cmp_Id from T0010_COMPANY_MASTER where is_GroupOFCmp = 1
				OPEN db_cursor   
				FETCH NEXT FROM db_cursor INTO @TempCmp_Id  
				WHILE @@FETCH_STATUS = 0  
				BEGIN  
						INSERT INTO @LateOrEarlyCountYesteday
						exec P_InOut_Record_IN_CMP_Consol @Cmp_ID = @TempCmp_Id
						,@From_Date = @Yesterday_Date ,@To_Date = @Yesterday_Date
						,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0
						,@Constraint='',@Report_Call='SUMMARY',@PBranch_ID='0'
						,@SubBranch_Id = 0,@BusSegement_Id = 0 
						,@SalCyc_Id = 0,@Vertical_Id = 0,@SubVertical_Id =0
					   FETCH NEXT FROM db_cursor INTO @TempCmp_Id  
				END  
				CLOSE db_cursor  
				DEALLOCATE db_cursor
				
				Select '1) Today''s latecomer' as Data, (Select COUNT(Emp_id) from  @LateOrEarlyCountToday where Late_In_count = 1) as Cnt
				UNION
				Select '2) Today''s Early Day Off' as Data, (Select COUNT(Emp_id) from  @LateOrEarlyCountToday where Early_Out_Count = 1) as Cnt   -- Changed by Gadriwala Muslim 26062015
				UNION
				Select '3) Yesterday''s latecomer' as Data, (Select COUNT(Emp_id) from  @LateOrEarlyCountYesteday where Late_In_count = 1) as Cnt
				UNION
				Select '4) Yesterday''s Early Day Off' as Data, (Select COUNT(Emp_id) from  @LateOrEarlyCountYesteday where Early_Out_Count = 1) as Cnt -- Changed by Gadriwala Muslim 26062015
		END
	ELSE
		BEGIN
				
				INSERT INTO @LateOrEarlyCountToday
					exec P_InOut_Record_IN_CMP_Consol @Cmp_ID = @Cmp_ID
						,@From_Date = @Current_Date ,@To_Date = @Current_Date
						,@Branch_ID=@Branch_ID,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=@Dept_ID,@Desig_ID=@Desig_ID,@Emp_ID=0
						,@Constraint='',@Report_Call='SUMMARY',@PBranch_ID='0'
						,@SubBranch_Id = @SubBranch_ID,@BusSegement_Id=@Bus_Segment_Id 
						,@SalCyc_Id = @Sal_Cyc_Id,@Vertical_Id = @Vertical_Id,@SubVertical_Id=@SubVertical_Id
				
				
				INSERT INTO @LateOrEarlyCountYesteday
					exec P_InOut_Record_IN_CMP_Consol @Cmp_ID = @Cmp_ID
						,@From_Date = @Yesterday_Date ,@To_Date = @Yesterday_Date
						,@Branch_ID=@Branch_ID,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=@Dept_ID,@Desig_ID=@Desig_ID,@Emp_ID=0
						,@Constraint='',@Report_Call='SUMMARY',@PBranch_ID='0'
						,@SubBranch_Id = @SubBranch_ID,@BusSegement_Id=@Bus_Segment_Id 
						,@SalCyc_Id = @Sal_Cyc_Id,@Vertical_Id = @Vertical_Id,@SubVertical_Id=@SubVertical_Id
				
				Select '1) Today''s latecomer' as Data, (Select COUNT(Emp_id) from  @LateOrEarlyCountToday where Late_In_count = 1) as Cnt
				UNION
				Select '2) Today''s Early Day Off' as Data, (Select COUNT(Emp_id) from  @LateOrEarlyCountToday where Early_Out_Count = 1) as Cnt -- Changed by Gadriwala Muslim 26062015
				UNION
				Select '3) Yesterday''s latecomer' as Data, (Select COUNT(Emp_id) from  @LateOrEarlyCountYesteday where Late_In_count = 1) as Cnt
				UNION
				Select '4) Yesterday''s Early Day Off' as Data, (Select COUNT(Emp_id) from  @LateOrEarlyCountYesteday where Early_Out_Count = 1) as Cnt -- Changed by Gadriwala Muslim 26062015
		END
	
	-----------------------------------------------------------------------------------------------------------------	
		
	
	-- TAX Details --------------------------------------------------------------------------------------------------	
	
	--IF @chkConstraint = ''
	--	BEGIN	
				
	--			Select '1) Total Employee' as Data,COUNT(Distinct Emp_ID) Cnt from T0210_MONTHLY_AD_DETAIL MAD
	--			left Join T0010_company_master CM on MAD.cmp_id = Cm.cmp_id and  is_GroupOFCmp = 1
	--			 where 
	--			(MAD.To_date between @St_Date And @End_Date) 
	--			AND isnull(CM.cmp_id,0) <> 0
	--			AND M_AD_Amount > 0 
	--			AND AD_ID in (Select AD_ID from T0050_AD_MASTER AM Left join T0010_company_master CM on AM.cmp_id = Cm.cmp_id and  is_GroupOFCmp = 1 where AM.AD_DEF_ID = 1 AND 
	--			isnull(Cm.Cmp_id,0)<>0 )
	--			UNION
	--			Select '2) Total Tax Deduct At Source' as Data, CAST(SUM(ISNULL(M_AD_Amount,0)) as numeric) Cnt from T0210_MONTHLY_AD_DETAIL MAD
	--				left Join T0010_company_master CM on MAD.cmp_id = Cm.cmp_id and  is_GroupOFCmp = 1
	--			where 
	--			(MAD.To_date between @St_Date And @End_Date) 
	--			AND isnull(CM.cmp_id,0) <> 0
	--			AND M_AD_Amount > 0 
	--			AND AD_ID in (Select AD_ID from T0050_AD_MASTER AM Left join T0010_company_master CM on AM.cmp_id = Cm.cmp_id and  is_GroupOFCmp = 1 where AD_DEF_ID = 1 AND 
	--			isnull(Cm.Cmp_id,0)<>0 )

	--	END
		
	--ELSE
	--	BEGIN
	--			Select '1) Total Employee' as Data,COUNT(Distinct Emp_ID) Cnt from T0210_MONTHLY_AD_DETAIL where 
	--			(To_date between @St_Date And @End_Date) 
	--			AND Cmp_ID = @CmpID
	--			AND M_AD_Amount > 0 
	--			AND AD_ID in (Select AD_ID from T0050_AD_MASTER where AD_DEF_ID = 1 AND 
	--			Cmp_ID =@CmpID)
	--			UNION
	--			Select '2) Total Tax Deduct At Source' as Data, CAST(SUM(ISNULL(M_AD_Amount,0)) as numeric) Cnt from T0210_MONTHLY_AD_DETAIL where 
	--			(To_date between @St_Date And @End_Date) 
	--			AND Cmp_ID = @CmpID
	--			AND M_AD_Amount > 0 
	--			AND AD_ID in (Select AD_ID from T0050_AD_MASTER where AD_DEF_ID = 1 AND 
	--			Cmp_ID = @CmpID )
	--	END	
	
	-- TAX Details --------------------------------------------------------------------------------------------------	
	Select '1) Total Employee' as Data,COUNT(Distinct MAD.Emp_ID) Cnt from T0210_MONTHLY_AD_DETAIL MAD inner join #Emp on MAD.emp_id = #Emp.emp_id 
				left Join T0010_company_master CM on MAD.cmp_id = Cm.cmp_id and  is_GroupOFCmp = 1
				 where 
				(MAD.To_date between @St_Date And @End_Date) 
				AND isnull(CM.cmp_id,0) <> 0
				AND M_AD_Amount > 0 
				AND AD_ID in (Select AD_ID from T0050_AD_MASTER AM Left join T0010_company_master CM on AM.cmp_id = Cm.cmp_id and  is_GroupOFCmp = 1 where AM.AD_DEF_ID = 1 AND 
				isnull(Cm.Cmp_id,0)<>0 )
				UNION
				Select '2) Total Tax Deduct At Source' as Data, CAST(SUM(ISNULL(M_AD_Amount,0)) as numeric) Cnt from T0210_MONTHLY_AD_DETAIL MAD inner join #Emp on MAD.emp_id = #Emp.emp_id 
					left Join T0010_company_master CM on MAD.cmp_id = Cm.cmp_id and  is_GroupOFCmp = 1
				where 
				(MAD.To_date between @St_Date And @End_Date) 
				AND isnull(CM.cmp_id,0) <> 0
				AND M_AD_Amount > 0 
				AND AD_ID in (Select AD_ID from T0050_AD_MASTER AM Left join T0010_company_master CM on AM.cmp_id = Cm.cmp_id and  is_GroupOFCmp = 1 where AD_DEF_ID = 1 AND 
				isnull(Cm.Cmp_id,0)<>0 )
	-----------------------------------------------------------------------------------------------------------------	

		
	
END



