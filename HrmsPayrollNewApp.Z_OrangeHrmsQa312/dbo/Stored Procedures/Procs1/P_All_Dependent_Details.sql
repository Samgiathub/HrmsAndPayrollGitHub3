

CREATE PROCEDURE [dbo].[P_All_Dependent_Details]
@Cmp_ID NUMERIC
,@Emp_ID varchar(500) = ''

AS 
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET ARITHABORT ON;

	
declare @ins_cap as varchar(500) = ''
declare @emp_row as varchar(max) = ''
declare @emp_dependentid as varchar(max) = ''
declare @dependentid numeric

CREATE TABLE #EmpDetail (
EMP_DEP_IT NUMERIC
)

Create Table #Alldetails(
 Emp_id numeric
,Row_id numeric
,Cmp_id numeric
,Name Varchar(100)
,Gender Char(1)
,Date_Of_Birth datetime
,C_Age numeric
,Relationship varchar(50)
,Is_Resi numeric
,Is_Dependant tinyint
,Image_Path varchar(100)
,Pan_Card_No varchar(20)
,Adhar_Card_No varchar(20)
,Height varchar(10)
,Weight varchar(10)
,Policy varchar(100)
)

Create table #forEmp (
	Emp_id numeric
)

Create table #InsDetail(
	Ins_Name Varchar(100)
	,Emp_id numeric
	,Row_id Varchar(100)
	
)


	if @Emp_ID <> ''
	Begin
		
		Insert into #forEmp
		select  cast(data  as numeric) from dbo.Split (@Emp_ID,',')
		
		Insert into #InsDetail
		select Ins_Cmp_name,Emp_Id,Replace(Emp_Dependent_ID,'#',',' ) + '0'
		from T0090_EMP_INSURANCE_DETAIL 
		where Cmp_ID = @cmp_id and Emp_ID in (Select Emp_id from #forEmp)

		
		select @emp_dependentid = Row_id from #InsDetail

		Insert into #EmpDetail
		select  cast(data  as numeric) from dbo.Split (@emp_dependentid,',') 
	
		Insert into #Alldetails
		Select distinct cd.Emp_id,cd.Row_Id,cd.Cmp_ID,Name,Gender,Date_Of_Birth,C_Age,Relationship,
		Is_Resi,Is_Dependant,Image_Path,Pan_Card_No,Adhar_Card_No,Height,Weight,Ins_Cmp_name
		from T0090_EMP_CHILDRAN_DETAIL CD inner join T0090_EMP_INSURANCE_DETAIL ID on cd.Emp_ID = id.Emp_Id
		inner join #InsDetail IDL on IDL.Emp_id = Id.Emp_Id
		where cd.Cmp_ID = @cmp_id and cd.Emp_Id in (select Emp_id from #forEmp)
		and Cast(cd.Row_ID as numeric) in 
		(
			Select EMP_DEP_IT from #EmpDetail
		)
		and Ins_Cmp_name = IDl.Ins_Name
	
	
		select distinct Emp_id,Row_Id,Cmp_ID,Name,Gender,Date_Of_Birth,C_Age,Relationship,
		Is_Resi,Is_Dependant,Image_Path,Pan_Card_No,Adhar_Card_No,Height,Weight,'' as Policy
		from T0090_EMP_CHILDRAN_DETAIL where Emp_ID in (select Emp_id from #forEmp) and Cmp_ID = @Cmp_ID and Row_ID not in (Select EMP_DEP_IT from #EmpDetail)
		Union all
		select Emp_id,Row_Id,Cmp_ID,Name,Gender,Date_Of_Birth,C_Age,Relationship,
		Is_Resi,Is_Dependant,Image_Path,Pan_Card_No,Adhar_Card_No,Height,Weight,Policy
		from #Alldetails order by Emp_ID

	End

	drop table #EmpDetail 
	drop table #Alldetails
	drop table #forEmp
	drop table #InsDetail
END

