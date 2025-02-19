

-- =============================================
-- Author:		<Jaian>
-- Create date: <09-02-2017>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P_Get_Scheme_detail]
	@Cmp_Id numeric
	--@Emp_Id numeric
AS
BEGIN
		Declare @Module_Name varchar(100)
		Declare @Module_Status numeric
		
		SELECT @Module_Name = MODULE_NAME,@Module_Status = MODULE_STATUS FROM T0011_MODULE_DETAIL WITH (NOLOCk) WHERE CMP_ID = @CMP_ID 
		
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
		FROM T0040_Scheme_Master  WITH (NOLOCk) where Cmp_Id=@Cmp_Id order BY Scheme_Type
		
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
		
		--select @Part1_Scheme,@Part2_Scheme
		
		select * from 
		(SELECT ROW_NUMBER() OVER(ORDER BY Scheme_Type asc) AS Row, 
			Scheme_Type, Scheme_Caption 
		FROM #Scheme_Type)d
		where d.Row between 1 and @Part1_Scheme


		select * from 
		(SELECT ROW_NUMBER() OVER(ORDER BY Scheme_Type asc) AS Row, 
			Scheme_Type, Scheme_Caption 
		FROM #Scheme_Type)d
		where d.Row between @Part1_Scheme+1 and @Total
		
		select Scheme_Id,Scheme_Name,Scheme_Type from T0040_Scheme_Master  WITH (NOLOCk) where Cmp_Id=@Cmp_id order BY Scheme_Name
END

