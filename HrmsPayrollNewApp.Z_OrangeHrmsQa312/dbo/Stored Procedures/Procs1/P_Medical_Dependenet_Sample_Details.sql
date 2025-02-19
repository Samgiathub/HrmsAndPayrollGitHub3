
CREATE PROCEDURE [dbo].[P_Medical_Dependenet_Sample_Details]
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
	   Emp_ID varchar(500)
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
	
	If @Constraint <> ''
	Begin
		Insert into #Emp_Cons
		Select Cast(data as numeric) from dbo.Split (@Constraint,'#')
	
	End

	Declare @Row_id varchar(8000) = ''
	Select @Row_id = Dependent_Details,@Emp_ID = Emp_id from T0500_Medical_Application where Cmp_Id = @Cmp_Id and App_Date between @From_Date and @To_Date

	--EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,0,0,@Salary_Cycle_id,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_Id,@New_Join_emp,@Left_Emp,0,'',0,0    

	If @Emp_ID = 0 
	begin
			DECLARE @COUNT NUMERIC = 0 , @eCOUNT NUMERIC = 0
			SELECT @eCOUNT = COUNT(Emp_ID) FROM #Emp_Cons

		WHILE @COUNT < @eCOUNT
		BEGIN 
			select @Emp_id = Emp_ID   from 
			(select ROW_NUMBER() OVER (ORDER BY Emp_ID ASC) AS rownumber, Emp_ID from #Emp_Cons) as bl
			where rownumber = @count

			Insert into #DEPENDENT_DETAILS
			Exec SP_BIND_DEPENDENT_DETAILS @Cmp_id,@Emp_id,@Row_id

			SET @COUNT = @COUNT + 1
		END
	end

	
	SELECT Emp.Alpha_Emp_Code,Emp.Emp_Full_Name
	,Im.Ins_Name as Insurance_Type
	,Id.Ins_Cmp_name as Insurance_Company_Name,Id.Ins_Policy_No as Insurance_Policy_Number,
	convert(varchar(50), cast(ID.Ins_Taken_Date as date), 105) as Registration_Date,
	convert(varchar(50), cast(ID.Ins_Due_Date as date), 105) as Insurance_Due_Date,
	convert(varchar(50), cast(ID.Ins_Exp_Date as date), 105) as Insurance_Expiry_Date,
	Id.Ins_Amount as Insurance_Amount,Id.Ins_Anual_Amt as Insurance_Annual_Amount,Id.Monthly_Premium,Id.Deduct_From_Salary,
	convert(varchar(50), cast(Id.Sal_Effective_Date as date), 105) as Salary_Effective_Date,
	Tm.GENDER,TM.RELATIONSHIP,Tm.Name_Of_Dependent
	FROM T0090_EMP_INSURANCE_DETAIL ID
	Left Outer Join #DEPENDENT_DETAILS TM on Tm.EMP_ID = ID.Emp_id
	left outer join #Emp_Cons EC on Ec.Emp_ID = Id.Emp_Id
	left outer join T0080_EMP_MASTER Emp on Emp.Emp_ID = Id.Emp_Id
	left outer join T0040_INSURANCE_MASTER IM on Im.Ins_Tran_ID = Id.Ins_Tran_ID
	where ID.Cmp_id = @cmp_id and Id.Emp_Id = Ec.Emp_ID
	--and Id.Ins_Cmp_name = 'Medical'

	Drop table #Emp_Cons
	Drop table #DEPENDENT_DETAILS

End