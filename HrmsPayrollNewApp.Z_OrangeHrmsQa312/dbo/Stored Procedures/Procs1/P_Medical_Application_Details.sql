CREATE PROCEDURE [dbo].[P_Medical_Application_Details]
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
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET ARITHABORT ON;
		
	DECLARE @columns VARCHAR(MAX)
	DECLARE @query nVARCHAR(MAX)

	CREATE TABLE #Emp_Cons 
	 (      
	   Emp_ID		NUMERIC ,     
	   Branch_ID	NUMERIC,
	   Increment_ID NUMERIC    
	 )    
	
	CREATE TABLE #DEPENDENT_DETAILS
	(
		EMP_ID   NUMERIC(18,0),
		ROW_ID   NUMERIC(18,0),
		CMP_ID   NUMERIC(18,0),
		POLICY_NO NVARCHAR(200),
		Name_Of_Dependent VARCHAR(200),
		GENDER   VARCHAR(200),
		DATE_OF_BIRTH DATETIME,
		AGE NUMERIC(18,0),
		RELATIONSHIP  VARCHAR(200),
		DEPENDEND_FLAG TINYINT
		
	)

	Declare @Row_id varchar(8000) = ''
	Select @Row_id = Dependent_Details,@Emp_ID = Emp_id from T0500_Medical_Application where Cmp_Id = @Cmp_Id and App_Date between @From_Date and @To_Date

	EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,@Salary_Cycle_id,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_Id,@New_Join_emp,@Left_Emp,0,'',0,0    
	
	
	Insert into #DEPENDENT_DETAILS
	Exec SP_BIND_DEPENDENT_DETAILS @Cmp_id,@Emp_id,@Row_id

	Select EM.Alpha_Emp_Code,Ma.App_Id as ApplicationID,Ma.Cmp_Id,Ma.App_Date as Application_Date,Em.Emp_Full_Name,Ma.Hospital_Name,
	SM.State_Name,Ma.City,im.Incident_Name,Ma.Incident_Place,Ma.Hospital_Address,Ma.Date_of_Incident,
	Ma.Time_of_Incident,Ma.Contact_no,Ma.Desc_Details,Tm.Name_Of_Dependent,Ma.Other_Note,Tm.AGE,Tm.GENDER,TM.POLICY_NO,TM.RELATIONSHIP
	from 
	T0500_Medical_Application Ma 
	LEft Outer Join T0080_EMP_MASTER EM on EM.Emp_ID = Ma.Emp_id
	Left Outer Join T0020_STATE_MASTER Sm on SM.State_ID = Ma.State_Id
	Left Outer Join T0040_INCIDENT_MASTER IM on Im.Incident_Id = Ma.Incident_Id
	Left Outer Join #DEPENDENT_DETAILS TM on Tm.EMP_ID = Ma.Emp_id
	where Ma.Cmp_Id = @Cmp_Id and Ma.App_Date between @From_Date and @To_Date


	Drop table #Emp_Cons
	Drop table #DEPENDENT_DETAILS

End