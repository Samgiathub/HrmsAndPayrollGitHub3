

-- =============================================
-- Author:		<Jaian>
-- Create date: <09-02-2017>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Scheme_Deafult_Detail_App]
	@Cmp_Id numeric(18,0),
	@Emp_ID numeric(18,0)=0,
	@Effective_Date datetime =null
	
AS
BEGIN
		Declare @Module_Name varchar(100)
		Declare @Module_Status numeric
		
		SELECT @Module_Name = MODULE_NAME,@Module_Status = MODULE_STATUS FROM T0011_MODULE_DETAIL WITH (NOLOCk) WHERE CMP_ID = @Cmp_Id 
		
		IF OBJECT_ID('tempdb..#Scheme_Type') IS NULL		
		CREATE table #Scheme_Type 
		(
			Scheme_Type  varchar(250),
			Scheme_Caption varchar(250)
		);
		Insert INTO #Scheme_Type (Scheme_Type,Scheme_Caption)
		SELECT DISTINCT Scheme_Type,
		   case when Scheme_Type = 'Attendance Regularization' THEN
					'Attendance Regularization'
			when Scheme_Type = 'Candidate Approval' then
   					'Candidate Approval' 
   			WHEN Scheme_Type = 'Change Request' THEN
   					'Change Request'
   			WHEN Scheme_Type = 'Claim' THEN
   					'Claim Application'
   			WHEN Scheme_Type = 'Exit' THEN
   					'Exit Application'
   			WHEN Scheme_Type = 'GatePass' THEN
   					'GatePass Application'
   			WHEN Scheme_Type = 'Increment' THEN
   					'Increment Application'
   			WHEN Scheme_Type = 'Leave' THEN
   					'Leave Application'
   			WHEN Scheme_Type = 'Loan' THEN
   					'Loan Application'
   			WHEN Scheme_Type = 'Over Time' THEN
   					'Over Time'	
   			WHEN Scheme_Type = 'Pre-CompOff' THEN
   					'Pre-CompOff Application'	
   			WHEN Scheme_Type = 'Probation' THEN
   					'Probation'		
   			WHEN Scheme_Type = 'Recruitment Request' THEN
   					'Recruitment Request Application'	
			WHEN Scheme_Type = 'Reimbursement' THEN
   					'Reimbursement Application'	
   			WHEN Scheme_Type = 'Trainee' THEN
   					'Trainee'	
   			WHEN Scheme_Type = 'Travel' THEN
   					'Travel Application'	
   			WHEN Scheme_Type = 'Travel Settlement' THEN
   					'Travel Settlement'	
   			WHEN Scheme_Type = 'Appraisal Review' THEN --added on 07/06/2017 sneha
   					'Appraisal Review'	
   			WHEN Scheme_Type = 'KPI Objectives' THEN--added on 07/06/2017 sneha
   					'KPI Objectives'	
			ELSE
				Scheme_Type 
   			END AS Scheme_Caption 
		FROM T0040_Scheme_Master  WITH (NOLOCk) where Cmp_Id=@Cmp_Id  and Default_Scheme=1 order BY Scheme_Type
		
		if @Module_Name = 'HRMS' and @Module_Status = 0
		Begin
			Delete FROM #Scheme_Type where Scheme_Type In ('Candidate Approval','Recruitment Request')
		ENd
		
		if @Module_Name = 'Appraisal3' and @Module_Status = 0 --added on 07/06/2017 sneha
		Begin
			Delete FROM #Scheme_Type where Scheme_Type In ('KPI Objectives','Appraisal Review')
		ENd
		
		Declare @Part1_Scheme as numeric
		Declare @Part2_Scheme as numeric
		Declare @Total As numeric
		select @Total = COUNT(*) from #Scheme_Type
		
		set  @Part1_Scheme =@Total/2
		set  @Part2_Scheme = @Total - @Part1_Scheme
		
		IF OBJECT_ID('tempdb..#Default_Scheme') IS NULL		
		CREATE table #Default_Scheme 
		(
			Scheme_Id  Numeric(18,0),
			Scheme_Name varchar(250),
			Default_Scheme bit,
			Scheme_Type  varchar(250)
		);
		INSERT INTO #Default_Scheme
		SELECT DISTINCT Scheme_Id,Scheme_Name,default_Scheme,d.Scheme_Type FROM 
		(SELECT ROW_NUMBER() OVER(ORDER BY Scheme_Type asc) AS Row, 
			Scheme_Type, Scheme_Caption 
		FROM #Scheme_Type With(NoLock))d
		Inner Join T0040_Scheme_Master SM With(NoLock) on SM.Scheme_Type=D.Scheme_Type
		where d.Row between 1 and @Part1_Scheme  and SM.Default_Scheme = 1 and Cmp_Id = @Cmp_Id
		
		INSERT INTO #Default_Scheme
		SELECT DISTINCT Scheme_Id,Scheme_Name,default_Scheme,d.Scheme_Type FROM 
		(SELECT ROW_NUMBER() OVER(ORDER BY Scheme_Type asc) AS Row, 
			Scheme_Type, Scheme_Caption 
		FROM #Scheme_Type With(NoLock))d 
		Inner Join T0040_Scheme_Master SM With(NoLock) on SM.Scheme_Type=D.Scheme_Type
		where d.Row between @Part1_Scheme+1 and @Total and SM.Default_Scheme = 1 and Cmp_Id = @Cmp_Id
		
		
		Declare @Scheme_ID numeric(18,0) 
		Declare @Scheme_Type varchar(250)
		Declare @Scheme_Name varchar(250)
		Declare @Default_Scheme varchar(250)
		declare cur1 cursor for 
			Select Scheme_Id,Scheme_Name,Scheme_Type,Default_Scheme from  #Default_Scheme
			open cur1
				fetch next from cur1 into @Scheme_ID,@Scheme_Name,@Scheme_Type,@Default_Scheme
					while @@fetch_status = 0
					begin
						exec P0095_EMP_SCHEME @Tran_ID=0,@Cmp_ID=@Cmp_Id,@Emp_ID=@Emp_ID,@Scheme_ID=@Scheme_ID,@Type=@Scheme_Type,@Effective_Date=@Effective_Date,@Tran_Type='I'
						fetch next from cur1 into @Scheme_ID,@Scheme_Name,@Scheme_Type,@Default_Scheme
					end					
			close cur1
		deallocate cur1
END

