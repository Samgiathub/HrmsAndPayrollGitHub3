CREATE PROCEDURE [dbo].[SP_BIND_DEPENDENT_DETAILS]
@CMP_ID NUMERIC(18,0),
@EMP_ID NUMERIC(18,0),
@ROW_ID Varchar(max) = ''

AS
BEGIN

CREATE TABLE #TEMP_DEPENDENT(Row_Id numeric)

CREATE TABLE #TEMP(Emp_Id numeric(18,0),
Row_Id numeric,Cmp_id Numeric (18,0),Is_Policy varchar(50),Name_Of_Person Varchar(100),
Gender varchar(20),Date_of_Birth Datetime,Age numeric(18,0),Relationship varchar(50),Is_Dependent tinyint)

			

If @ROW_ID <> ''
Begin
	Insert into #TEMP_DEPENDENT
	Select Cast(data as numeric) from dbo.Split (@ROW_ID,'#')

End
	
	
	Insert into #TEMP
	SELECT Em.Emp_ID,0 As Row_ID,Em.Cmp_ID,Ed.Ins_Policy_No,Emp_Full_Name As Name,CASE WHEN Gender = 'F' Then 'Female' ELSE 'Male' End As Gender,Date_Of_Birth,dbo.F_GET_AGE(Date_Of_Birth,GETDATE(),'N','N') As C_Age,'Self' as RelationShip,1 As Is_Dependant 
	FROM T0080_EMP_MASTER EM
	inner join T0090_EMP_INSURANCE_DETAIL ED on Ed.Emp_Id = Em.Emp_ID
	inner join T0040_INSURANCE_MASTER IM on IM.Ins_Tran_ID = Ed.Ins_Tran_ID
	WHERE Em.Emp_Id = @EMP_ID and Em.Cmp_ID = @CMP_ID and Im.Insurance_Type = 1
	UNION
	SELECT ed.Emp_ID,Ed.Row_ID,ed.Cmp_ID,Eid.Ins_Policy_No,Name,CASE WHEN Gender = 'F' Then 'Female' ELSE 'Male' End As Gender,Date_Of_Birth,C_Age,isnull(RelationShip,'') as RelationShip,Is_Dependant 
	FROM T0090_EMP_CHILDRAN_DETAIL ED 
	inner join #TEMP_DEPENDENT TD on ED.Row_ID = TD.Row_Id 
	inner join T0090_EMP_INSURANCE_DETAIL EID on EID.Emp_ID = Ed.Emp_ID
	inner join T0040_INSURANCE_MASTER IM on IM.Ins_Tran_ID = Eid.Ins_Tran_ID
	--WHERE Emp_Id = @EMP_ID or Ed.Row_ID in (Cast(Replace(@ROW_ID,'#',',') as numeric)) and Cmp_id = @CMP_ID 
	WHERE ed.Cmp_id = @CMP_ID and Im.Insurance_Type = 1
	ORDER BY Row_ID

	--Select * from #TEMP
	IF not Exists(Select 1 from #TEMP_DEPENDENT where Row_Id in (@EMP_ID))
	Begin
		Delete T from #TEMP T inner join #TEMP_DEPENDENT TD on T.Row_Id <> TD.Row_Id 
	END

	Select * from #TEMP
	--Select T.Date_of_Birth,T.Age,T.Gender from #TEMP T inner join #TEMP_DEPENDENT TD on TD.Row_Id = T.Row_Id


Drop Table #TEMP_DEPENDENT
Drop Table #temp

	
END

