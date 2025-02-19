

CREATE VIEW [dbo].[V0100_Employee_ESOP_Detail]
AS
	 SELECT 
	 Esop_Id,Effective_date
	 ,B.Branch_Name
	 ,D.Dept_Name
	 ,DS.Desig_Name 
	 ,NoOfShare
	 ,PerquisiteValue,TaxablePerqValue
	 ,SystemDate,E.Emp_Id,E.Cmp_Id
	 ,E1.Emp_Full_Name,E1.Alpha_Emp_Code ,MarketPrice,Emp_Price
	 FROM T0040_EMP_ESOP_ALLOCATION E 
	 inner join T0020_ESOP_SharePrice_Master M on M.EmployeePrice = E.Emp_Price
	 inner join T0080_EMP_MASTER E1 on E.Emp_Id = E1.Emp_ID 
	 inner join T0095_INCREMENT I on I.emp_id = E1.Emp_ID
	 Inner join (
				Select Max(I2.Increment_ID) as IncId ,I2.Emp_ID,I2.Branch_ID,I2.Dept_ID,I2.Desig_Id
				From T0095_INCREMENT I2  
					  inner join (
									Select MAX(Increment_Effective_Date) as EffDate  , Emp_ID
									From T0095_INCREMENT I3
									WHERE	I3.Increment_effective_Date <= GETDATE() 
											and I3.increment_type <> 'Transfer'
									GROUP BY Emp_ID
								) a on I2.Increment_Effective_Date = a.EffDate and I2.Emp_ID = A.Emp_ID
				GROUP BY I2.Emp_ID,I2.Branch_ID,I2.Dept_ID,I2.Desig_Id
		) a1 on I.Increment_ID = A1.IncId and E1.Emp_ID = A1.Emp_ID
		inner join T0030_BRANCH_MASTER B on B.Branch_ID = A1.Branch_ID 
		inner join T0040_DEPARTMENT_MASTER D on d.Dept_Id = A1.Dept_ID
		inner join T0040_DESIGNATION_MASTER DS on DS.Desig_ID = A1.Desig_Id

