

CREATE PROCEDURE [dbo].[P_All_Dependent_Details_WORKING_01062022_MEHUL]
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

	if @Emp_ID <> ''
	Begin
		select @ins_cap=Ins_Cmp_name,@emp_row = Emp_Dependent_ID
		from T0090_EMP_INSURANCE_DETAIL where Cmp_ID = @cmp_id and Emp_ID = Cast(@emp_id as numeric)
		set @emp_dependentid = REPLACE(@emp_row,'#',',') + '0'
		
		if @emp_dependentid <> ''
		Begin
			Insert into #EmpDetail
			select  cast(data  as numeric) from dbo.Split (@emp_dependentid,',') 
		End
	
		Insert into #Alldetails
		Select distinct cd.Emp_id,Row_Id,cd.Cmp_ID,Name,Gender,Date_Of_Birth,C_Age,Relationship,
		Is_Resi,Is_Dependant,Image_Path,Pan_Card_No,Adhar_Card_No,Height,Weight,Ins_Cmp_name
		from T0090_EMP_CHILDRAN_DETAIL CD inner join T0090_EMP_INSURANCE_DETAIL ID on cd.Emp_ID = id.Emp_Id
		where cd.Cmp_ID = @cmp_id and cd.Emp_Id = Cast(@emp_id as numeric)
		and Cast(Row_ID as numeric) in 
		(
			Select EMP_DEP_IT from #EmpDetail
		)
		and Ins_Cmp_name = @ins_cap
	
		
		select distinct Emp_id,Row_Id,Cmp_ID,Name,Gender,Date_Of_Birth,C_Age,Relationship,
		Is_Resi,Is_Dependant,Image_Path,Pan_Card_No,Adhar_Card_No,Height,Weight,'' as Policy
		from T0090_EMP_CHILDRAN_DETAIL where Emp_ID in (Cast(@emp_id as numeric)) and Cmp_ID = @Cmp_ID and Row_ID not in (Select EMP_DEP_IT from #EmpDetail)
		Union all
		select Emp_id,Row_Id,Cmp_ID,Name,Gender,Date_Of_Birth,C_Age,Relationship,
		Is_Resi,Is_Dependant,Image_Path,Pan_Card_No,Adhar_Card_No,Height,Weight,Policy
		from #Alldetails
	End
	drop table #EmpDetail 
	drop table #Alldetails
END

