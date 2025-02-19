


CREATE VIEW [dbo].[V0090_EMP_DEPENDANT_DETAIL]
AS
SELECT   '="' + Em.Alpha_Emp_Code + '"' as Emp_Code,EM.Emp_Full_Name as Employee_Name,
BM.Branch_Name,GM.Grd_Name as Grade, DM.Desig_Name as Designation,
Convert (varchar(11),EM.Date_Of_Join,103) AS Date_Of_Join, 
Inc_Qry.Basic_Salary, Inc_Qry.Gross_Salary,EM.Father_Name as Father_Name,
REPLACE(CONVERT(VARCHAR,edt.BirthDate,106),' ','-') as Date_Of_Birth,
Case EM.Marital_Status When 0 Then 'Single' When 1 Then 'Married' When 2 Then 'Divorced' When 3 THEN 'Separated' When 4 Then 'Widowed' End As Marrital_Status,
EDT.Name as Name_OF_Nominee,
         EDT.RelationShip as Relation,EDT.Address as Nominee_Address,EDT.D_Age AS Nominee_Age,
			(case when (EDT.Is_Resi = 0) then 'No'
			when (EDT.Is_Resi =1) then 'Yes' End)as Is_Resident_With_Nominee,
			EDT.Share as Nominee_Share,
			(Case 
			When (EDT.NomineeFor=0) then 'All'
			when (EDT.NomineeFor=1)  then 'PF'
			when (EDT.NomineeFor=2) then 'Gratuity'
			when  (EDT.NomineeFor=3) then 'ESIC'
			when  (EDT.NomineeFor=4) then 'GPA'
			when  (EDT.NomineeFor=5) then 'Super Annuation'
			End) As Nominee_For,
			--Inc_Qry.Basic_Salary as Present_Salary,
			BM.Branch_ID,EM.Emp_ID,EM.Cmp_Id						
FROM       dbo.T0090_EMP_DEPENDANT_DETAIL  EDT WITH (NOLOCK) inner join
			dbo.T0080_EMP_MASTER EM WITH (NOLOCK)  on EDT.Emp_ID = EM.Emp_ID inner join
			dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK)  on BM.Branch_ID = EM.Branch_ID INNER JOIN 
			(SELECT I.Emp_Id,Basic_Salary,I.Gross_Salary,I.Branch_ID,I.Grd_ID,I.Desig_Id FROM dbo.T0095_INCREMENT I WITH (NOLOCK)  inner join
				(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK)  inner join
						(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK) 
							Where Increment_effective_Date <= GETDATE() Group by emp_ID
						) new_inc on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
						Where TI.Increment_effective_Date <= GETDATE() group by ti.emp_id
				) Qry on I.Increment_Id = Qry.Increment_Id
			) Inc_Qry ON eM.Emp_ID = Inc_Qry.Emp_ID INNER JOIN			
			 dbo.T0040_GRADE_MASTER GM WITH (NOLOCK)  On Inc_Qry.Grd_ID = GM.Grd_ID INNER JOIN
			 dbo.T0040_DESIGNATION_MASTER DM WITH (NOLOCK)  On Inc_Qry.Desig_Id = DM.Desig_ID			
			--dbo.T0095_INCREMENT I on I.Emp_ID = EM.emp_id where MAX(I.Increment_Date) <= GETDATE()
			 



