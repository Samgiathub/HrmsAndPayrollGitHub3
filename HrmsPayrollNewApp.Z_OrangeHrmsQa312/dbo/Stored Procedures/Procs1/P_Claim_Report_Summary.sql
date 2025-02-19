CREATE PROCEDURE [dbo].[P_Claim_Report_Summary]
	 @Cmp_Id		NUMERIC  
	,@From_Date		DATETIME
	,@To_Date 		DATETIME
	,@Branch_ID		VARCHAR(MAX) = ''	
	,@Cat_ID		varchar(Max)
	,@Grd_ID		varchar(Max) ,@Type_ID		varchar(Max) 
	,@Dept_ID		varchar(Max) 
	,@Desig_ID		varchar(Max) 
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(max) = ''
	,@New_Join_emp	numeric = 0 
	,@Left_Emp		Numeric = 0
	,@Salary_Cycle_id numeric = NULL
	,@Segment_Id  varchar(Max) = ''	
	,@Vertical_Id varchar(Max) = ''	 
	,@SubVertical_Id varchar(Max) = ''	
	,@SubBranch_Id varchar(Max) = ''
	,@Status INT	
AS
BEGIN
	
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET ARITHABORT ON;

	DECLARE @columns VARCHAR(MAX)
	DECLARE @query nVARCHAR(MAX)

	
	CREATE TABLE #Emp_Cons 
	 (      
	   Emp_ID		NUMERIC 
	 )
	 
	 CREATE TABLE #Emp_Comment 
	 (      
	   Claim_App_Id Numeric,
	   Claim_Comment NVarchar(MAX) 
	 )

	 --Insert into #Emp_Comment 
	 --Select Max(Claim_App_ID),MAx(Claim_Apr_Comments) from T0115_CLAIM_LEVEL_APPROVAL where Emp_ID in ( 25565 , 25530)

	If @Constraint <> ''
		Begin
			Insert into #Emp_Cons
			Select Cast(data as numeric) from dbo.Split (@Constraint,'#')
		End
	
	declare @emp numeric = 0,@count numeric,@empcount numeric = 0
	SET @count = 0

	select @empcount = Count(emp_id) from #Emp_Cons
	
	While @count <= @empcount
	begin
			select @emp = Emp_ID   from 
			(select ROW_NUMBER() OVER (ORDER BY Emp_ID ASC) AS rownumber, Emp_ID from #Emp_Cons) as bl
			where rownumber = @count

			Insert into #Emp_Comment
			Select isnull(Max(Claim_App_ID),0) as Claim_App_ID,isnull(Max(Claim_Apr_Comments),'') as Claim_Apr_Comments from T0115_CLAIM_LEVEL_APPROVAL where Emp_ID = @emp
			Set @count = @count + 1
	end
	
	--EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,@Salary_Cycle_id,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_Id,@New_Join_emp,@Left_Emp,0,'',0,0    
	
	
	Select ( '="' + Em.Alpha_Emp_Code + '"') as Alpha_Emp_Code, EM.Emp_Full_Name as Officer_Name,Cm.Claim_Name,Cad.Application_Amount as Application_Amount,Capr.Claim_Apr_Amount as Approval_Amount,
	( '="' + Im.Inc_Bank_AC_No + '"') as Inc_Bank_Ac_No,Em.Ifsc_Code,Im.Bank_Branch_Name,Claim_Date_Label,Case when CAPR.Payment_Process_ID is not Null then 'Yes' else 'No' end as Payment_Process_Status
	,Replace(Replace(Replace(Replace(isnull(Ec.Claim_Comment,''),'<br>',''),'<strong>',''),'</strong>',''),'</br>','') as Claim_Comment
	from T0100_CLAIM_APPLICATION CA 
	inner join T0110_CLAIM_APPLICATION_DETAIL CAD on Cad.Claim_App_Id = Ca.Claim_App_Id
	inner join T0040_CLAIM_MASTER CM on CM.Claim_id = CA.Claim_id
	inner join T0080_EMP_MASTER Em on EM.Emp_id = Ca.Emp_id
	inner join T0095_INCREMENT Im on Im.Increment_id = Em.Increment_ID
	inner join T0130_CLAIM_APPROVAL_DETAIL CAPR on CAPR.Claim_App_ID = CA.Claim_App_ID
	inner join T0120_CLAIM_APPROVAL CAPP on Capp.Claim_App_ID = Ca.Claim_App_ID
	left outer join #Emp_Comment Ec on Ec.Claim_App_Id = Ca.Claim_App_Id
	inner join #Emp_Cons CEMP on CEMP.Emp_id = Ca.Emp_id

	where CAPP.Claim_Apr_Status = 'A' and CAPP.Cmp_ID = @Cmp_Id and CAPP.Claim_Apr_Date between @From_Date and @To_Date



	Drop table #Emp_Cons
	Drop table #Emp_Comment 
	
End