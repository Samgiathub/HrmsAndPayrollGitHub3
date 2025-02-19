    
CREATE PROCEDURE [dbo].[Get_Project_Allocation_Details]  
@Cmp_ID Numeric(18,0),
@Fromdate Datetime,
@Todate Datetime,
@Branch_ID numeric(18,0),
@Cat_ID numeric(18,0),
@Grd_ID	numeric(18,0),
@Type_ID numeric(18,0),
@Dept_ID numeric(18,0),
@Desig_ID numeric(18,0),
@Emp_ID varchar(MAX),
@Project_ID varchar(MAX)
    
AS  
  
  SET NOCOUNT ON   
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
  SET ARITHABORT ON 
  
CREATE TABLE #Emp_Temp 
(      
	Emp_ID numeric(18,0)
) 

CREATE TABLE #Pro_Temp 
(      
	Project_ID numeric(18,0)
) 

	If @Project_ID <> ''
	begin 
			INSERT INTO #Pro_Temp SELECT CAST(Data AS numeric) FROM dbo.Split(@Project_ID,'#')       
			IF @Emp_ID <> ''
			BEGIN
				INSERT INTO #Emp_Temp SELECT CAST(Data AS numeric) FROM dbo.Split(@Emp_ID,'#')       
			END

			SELECT Distinct Client_Name as 'Client',TPM.Project_Name as 'Project Name',TPM.Project_Code as 'Project Code',
			isnull(L.Emp_Full_Name,LOGI.Login_Name) as 'PMO Name',L1.Alpha_Emp_Code + ' - ' + L1.Emp_Full_Name as 'Project Update' 
			,EM.Alpha_Emp_Code as 'Employee Code',EM.Emp_Full_Name as 'Employee Name',Dept_Name as 'Department Name',
			Desig_Name as 'Designation Name',Branch_Name as 'Branch Name'
			FROM T0040_TS_Project_Master TPM WITH (NOLOCK)    
			INNER JOIN T0050_TS_Project_Detail TPD WITH (NOLOCK) ON TPM.Project_ID = TPD.Project_ID  
			left outer join T0040_Client_Master Cm on Cm.Client_ID = TPM.Client_ID 
			left outer join T0080_EMP_MASTER Em on em.Emp_ID = TPD.Assign_To
			left outer join V0080_EMP_MASTER_GET I on I.Emp_ID = Em.Emp_ID
			left outer join T0040_DEPARTMENT_MASTER DM on DM.Dept_Id= I.Dept_ID
			left outer join T0040_DESIGNATION_MASTER DEM on DEM.Desig_ID= I.Desig_Id
			left outer join T0030_BRANCH_MASTER BM on BM.Branch_ID= I.Branch_ID
			left outer join V0080_EMP_MASTER_GET L on L.Login_ID = TPM.Created_By
			left outer join V0080_EMP_MASTER_GET L1 on L1.Login_ID = TPD.Modify_By
			left outer join T0011_LOGIN LOGI on LOGI.Login_ID = TPM.Created_By
			where TPM.Cmp_ID = @Cmp_ID and Assign_To in (select Emp_ID from #Emp_Temp) 
			and TPD.Project_ID in (Select Project_ID from #Pro_Temp)
	end
	else 
	begin

			IF @Emp_ID <> ''
			BEGIN
				INSERT INTO #Emp_Temp SELECT CAST(Data AS numeric) FROM dbo.Split(@Emp_ID,'#')       
			END

			SELECT Distinct Client_Name as 'Client',TPM.Project_Name as 'Project Name',TPM.Project_Code as 'Project Code',
			isnull(L.Emp_Full_Name,LOGI.Login_Name) as 'PMO Name',L1.Alpha_Emp_Code + ' - ' + L1.Emp_Full_Name as 'Project Update' 
			,EM.Alpha_Emp_Code as 'Employee Code',EM.Emp_Full_Name as 'Employee Name',Dept_Name as 'Department Name',
			Desig_Name as 'Designation Name',Branch_Name as 'Branch Name'
			FROM T0040_TS_Project_Master TPM WITH (NOLOCK)    
			INNER JOIN T0050_TS_Project_Detail TPD WITH (NOLOCK) ON TPM.Project_ID = TPD.Project_ID  
			left outer join T0040_Client_Master Cm on Cm.Client_ID = TPM.Client_ID 
			left outer join T0080_EMP_MASTER Em on em.Emp_ID = TPD.Assign_To
			left outer join V0080_EMP_MASTER_GET I on I.Emp_ID = Em.Emp_ID
			left outer join T0040_DEPARTMENT_MASTER DM on DM.Dept_Id= I.Dept_ID
			left outer join T0040_DESIGNATION_MASTER DEM on DEM.Desig_ID= I.Desig_Id
			left outer join T0030_BRANCH_MASTER BM on BM.Branch_ID= I.Branch_ID
			left outer join V0080_EMP_MASTER_GET L on L.Login_ID = TPM.Created_By
			left outer join V0080_EMP_MASTER_GET L1 on L1.Login_ID = TPD.Modify_By
			left outer join T0011_LOGIN LOGI on LOGI.Login_ID = TPM.Created_By
			where TPM.Cmp_ID = @Cmp_ID and Assign_To in (select Emp_ID from #Emp_Temp)

	end
  drop table #Emp_Temp
  drop table #Pro_Temp
  
  