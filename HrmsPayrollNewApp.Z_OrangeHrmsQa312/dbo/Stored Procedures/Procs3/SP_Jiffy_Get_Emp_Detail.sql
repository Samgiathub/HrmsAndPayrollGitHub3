CREATE PROCEDURE [dbo].[SP_Jiffy_Get_Emp_Detail]
(  
  @Alpha_Emp_Code varchar(100) = '',
  @Cmp_ID int = 0
)
AS
BEGIN
  SET NOCOUNT ON;
	Declare @Emp_ID numeric = 0
    Select @Emp_ID = Emp_ID from T0080_EMP_MASTER WHERE Alpha_Emp_Code = @Alpha_Emp_Code AND Cmp_ID = @Cmp_ID
	--Select @Emp_ID


	Select
		EMP.Emp_ID as employeeId,
		ISNULL(Emp_First_Name, '') as firstName,
		ISNULL(Emp_Last_Name, '') as lastName,
		ISNULL(Mobile_No, '') as personalPhone,
		ISNULL(Other_Email, '') as personalEmail,
		ISNULL(Date_Of_Birth, '') as dateOfBirth,
		ISNULL(Gender, '') as gender,
		
		ISNULL(Present_Street + Present_City + Present_State +Present_Post_Box, '') as currentAddress,
		ISNULL(Street_1 + City + State + Zip_code, '') as permanentAddress,
		ISNULL(Ifsc_Code, '') as bankDetailsIfscCode,
		ISNULL(E_INC.Inc_Bank_AC_No, '') as bankDetailsAccountNumber,
		ISNULL(Pan_No, '') as panNumber,
		ISNULL(Aadhar_Card_No, '') as aadharNumber,
		
		ISNULL(Work_Tel_No, '') as workPhone,
		ISNULL(Work_Email, '') as workEmail,
		ISNULL(Date_Of_Join, '') as dateOfJoining,
		ISNULL(Type_Name, '') as employmentType,
		ISNULL(Grd_Name, '') as paygrade,
		ISNULL(Desig_Name, '') as employeeDesignation,
		ISNULL(Dept_Name, '') as employeeDepartment,
		ISNULL(Emp_Left_Date, '') as lastWorkingDay,
		ISNULL(Gross_Salary, 0) as netMonthlySalary

		from T0080_EMP_MASTER EMP
		left outer join T0095_INCREMENT E_INC
		on EMP.Emp_ID = E_INC.Emp_ID
		left outer join T0040_TYPE_MASTER E_Type
		on E_Type.Type_ID = EMP.Type_ID and E_Type.Cmp_ID = EMP.Cmp_ID
		left outer join T0040_GRADE_MASTER GRD
		on GRD.Grd_ID = EMP.Grd_ID and GRD.Cmp_ID = EMP.Cmp_ID
		left outer join T0040_DESIGNATION_MASTER DESIG
		on DESIG.Desig_ID = EMP.Desig_ID and DESIG.Cmp_ID = EMP.Cmp_ID
		left outer join T0040_DEPARTMENT_MASTER DEPT
		on DEPT.Dept_Id = EMP.Dept_Id and DEPT.Cmp_ID = EMP.Cmp_ID

		Where (@Cmp_ID = 0 or EMP.Cmp_ID = @Cmp_ID)
		and (@Emp_ID = 0 or EMP.EMP_ID = @Emp_ID)
		AND EMP.Alpha_Emp_Code = @Alpha_Emp_Code
    
	Insert into API_Hit_Log
	(API_Name, [TimeStamp], Hit_Count_Today, Hit_Count_Total)
	SELECT N'GET​/Api​/Home​/Employee_Details' as API_Name,
	GETDATE() as TimeStamp,
	(Select COUNT(ISNULL(Hit_Count_Today, 1)) + 1 as Hit_Count_Today
	from API_Hit_Log
	where CAST([TimeStamp] as Date) = CAST(GETDATE() as Date)),
	(Select COUNT(ISNULL(Hit_Count_Total, 1)) + 1 as Hit_Count_Total from API_Hit_Log)

END