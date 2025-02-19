



CREATE VIEW [dbo].[POV_Details_Trident] AS
SELECT EMP.Emp_ID E_ID,CM.[Cmp_ID],CM.Cmp_Name COMP_CD,CM.Cmp_Address COMP_CD_DESC, EMP.[Emp_code] EMPID,[Alpha_Emp_Code] EMP_CD,[Initial] PREFIX,[Emp_Full_Name] EMP_NM,
[Emp_First_Name] FNAME,
[Emp_Second_Name] MNAME,[Emp_Last_Name] LNAME,[Date_Of_Join] DT_JOIN,[Date_Of_Birth] DT_BIRTH,Case when Convert(varchar,[Marital_Status]) = '0' then 'Single' when Convert(varchar,[Marital_Status]) = '1' then 'Married' when Convert(varchar,[Marital_Status]) = '2' then 'Divorced' when Convert(varchar,[Marital_Status]) = '3' then 'Saperated' else Marital_Status end MAR_ST,
Case when [Gender] = 'M' Then 'Male' when [Gender] = 'F' then 'Female' else '' end SEX,
Desig.Desig_Name DESIG_CD_DESC,Dept.Dept_Name [Business Unit],Cat.Cat_Name [Section],
SUBSTRING(Dept.Dept_Name,0,CHARINDEX('-', Dept.Dept_Name )) Location,
SUBSTRING(Dept.Dept_Name,CHARINDEX('-', Dept.Dept_Name )+1,Len(Dept.Dept_Name)-CHARINDEX('-', Dept.Dept_Name )) NewDivision,
I.Increment_Date INCR_DT,Grade.Grd_Name GRADE,I1.Basic_Salary,I1.Gross_Salary GROSS,I1.CTC,
[SSN_No],[SIN_No],[Dr_Lic_No],[Pan_No] PAN_NO,[Work_Email] EMAIL,EMP.Blood_Group BLDGRP,EMP.Aadhar_Card_No AADHAAR_NO,EC.Name E_NAME,EC.Emergency_Contact,
Mother.Name M_NAME,[Father_name] FATH_NM,Father.Name FATH_NM1
,BR.Branch_Name Contractor_Name,BR.Branch_Address Contractor_Address,SubBranch_Name Sub_Contractor,ContM.Vendor_Code,BR.Branch_City Contractor_City,State.State_Name Contractor_State,BR.Comp_Name Contractor_Company_Name,
BusSeg.Segment_Name [Sub Department],Type.Type_Name [Employee Type],CC.Cost_Center,VS.Vertical_Name [Division],SV.SubVertical_Name [Main Department],
I1.Increment_Effective_Date [Latest Increment Date],LE.Left_Date,LE.Reg_Date [Resign Date],LE.Left_Reason,EMP.SSN_No [PF NO],EMP.SIN_NO [ESIC NO],
[Street_1] PMNT_Street,
[City] PMNT_CITY,District PMNT_District,[State] PMNT_State ,
[Zip_code] PMNT_PINCode,TH.ThanaName PMNT_ThanaName,EMP.[Home_Tel_no] HOMENO,[Mobile_No] CURRENTCELL,Emp.[Work_Tel_No],[Other_Email],
[Present_Street] PRSNT_Street,
[Present_City] PRSNT_CITY,District_Wok PRSNT_District,[Present_State] PRSNT_State,
[Present_Post_Box] PRSNT_PINCode,THW.ThanaName PRSNT_ThanaName,Case when EMP.Emp_Left = 'Y' then 'InActive' else 'Active' end Employee_Staus,
Case when SUBSTRING(Dept.Dept_Name,0,CHARINDEX('-', Dept.Dept_Name )) <> '' then CM.Cmp_Name+' - '+SUBSTRING(Dept.Dept_Name,0,CHARINDEX('-', Dept.Dept_Name )) Else CM.Cmp_Name End  New_Business_Unit
FROM [T0080_EMP_MASTER] EMP WITH (NOLOCK)
	inner join T0095_INCREMENT I1 WITH (NOLOCK) ON I1.Emp_ID=EMP.EMP_ID
	INNER JOIN (SELECT	MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
				FROM	T0095_INCREMENT I2  WITH (NOLOCK) 
						INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
									FROM	T0095_INCREMENT I3  WITH (NOLOCK) 
									WHERE	I3.Increment_Effective_Date <= getdate()
									GROUP BY I3.Emp_ID
									) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
				GROUP BY I2.Emp_ID
				) I_Q ON I1.Emp_ID=I_Q.Emp_ID AND I1.Increment_ID=I_Q.INCREMENT_ID	
				INNER JOIN T0010_COMPANY_MASTER CM  WITH (NOLOCK) ON CM.Cmp_Id = I1.Cmp_ID
				left join T0030_BRANCH_MASTER BR WITH (NOLOCK) On BR.Branch_ID = I1.Branch_ID and BR.Cmp_ID = I1.Cmp_ID
				left join T0020_STATE_MASTER State WITH (NOLOCK) ON State.State_ID = BR.State_ID and State.Cmp_ID = BR.Cmp_ID 
				left join T0035_CONTRACTOR_DETAIL_MASTER ContM WITH (NOLOCK) On ContM.Branch_ID = BR.Branch_ID and ContM.Date_Of_Termination = (select Max(CDM.Date_Of_Termination) from T0035_CONTRACTOR_DETAIL_MASTER CDM WITH (NOLOCK) Inner join T0030_BRANCH_MASTER BM on BM.Branch_ID = CDM.Branch_ID)
				left Join T0050_SubBranch SubBR WITH (NOLOCK) ON SubBR.SubBranch_ID = I1.subBranch_ID and SubBR.Branch_ID = BR.Branch_ID
left join T0040_Business_Segment BusSeg  WITH (NOLOCK) on BusSeg.Segment_ID = I1.Segment_ID
left join T0040_TYPE_MASTER Type  WITH (NOLOCK) on Type.Type_ID = I1.Type_ID
left join T0040_Cost_Center CC  WITH (NOLOCK) on CC.Tally_Center_ID = I1.Center_ID 
left join T0040_Vertical_Segment VS  WITH (NOLOCK) on VS.Vertical_ID = I1.Vertical_ID 
left join T0050_SubVertical SV  WITH (NOLOCK) on SV.SubVertical_ID = I1.SubVertical_ID and VS.Vertical_ID = SV.Vertical_ID 
left join T0040_DESIGNATION_MASTER Desig WITH (NOLOCK) ON Desig.Desig_ID = I1.Desig_Id
left join T0040_DEPARTMENT_MASTER Dept WITH (NOLOCK) On Dept.Dept_Id = I1.Dept_ID
left join T0030_CATEGORY_MASTER Cat  WITH (NOLOCK) on Cat.Cat_ID = I1.Cat_ID
left join T0095_INCREMENT I  WITH (NOLOCK) on I.Increment_ID = I_Q.Increment_ID and I.Emp_ID = I_Q.Emp_ID 
left join T0040_GRADE_MASTER Grade  WITH (NOLOCK) On Grade.Grd_ID = I1.Grd_ID
left join T0100_LEFT_EMP LE  WITH (NOLOCK) on LE.Emp_ID = I_Q.Emp_ID 
left join (select top 1 EC.Emp_ID,EC.Cmp_ID,Name,Case when Home_Mobile_No = '' then Case when EC.Home_Tel_No = '' then EC.Work_Tel_No else EC.Home_Tel_No end else Home_Mobile_No end Emergency_Contact  from T0090_EMP_EMERGENCY_CONTACT_DETAIL EC  WITH (NOLOCK) inner join T0080_EMP_MASTER EMP WITH (NOLOCK) on EMP.Emp_id = EC.Emp_Id and EMP.Cmp_id = EC.Cmp_Id) EC on EC.Emp_ID = I_Q.Emp_ID
left Join (Select top 1 CD.Emp_Id,CD.Cmp_Id,Name from T0090_EMP_CHILDRAN_DETAIL CD  WITH (NOLOCK) inner join T0080_EMP_MASTER EMP  WITH (NOLOCK) on EMP.Emp_id = CD.Emp_Id and EMP.Cmp_id = CD.Cmp_Id and RelationShip = 'Mother') Mother On Mother.Emp_Id = I_Q.Emp_ID
left Join (Select top 1 CD.Emp_Id,CD.Cmp_Id,Name from T0090_EMP_CHILDRAN_DETAIL CD  WITH (NOLOCK) inner join T0080_EMP_MASTER EMP  WITH (NOLOCK) on EMP.Emp_id = CD.Emp_Id and EMP.Cmp_id = CD.Cmp_Id and RelationShip = 'Father') Father On Mother.Emp_Id = I_Q.Emp_ID
left join T0030_Thana_Master TH  WITH (NOLOCK) on TH.Thana_Id = EMP.Thana_Id
left join T0030_Thana_Master THW  WITH (NOLOCK) on THW.Thana_Id = EMP.Thana_Id_Wok

--SELECT EMP.Emp_ID E_ID,CM.[Cmp_ID],CM.Cmp_Name COMP_CD,CM.Cmp_Address COMP_CD_DESC, EMP.[Emp_code] EMPID,[Alpha_Emp_Code] EMP_CD,[Initial] PREFIX,[Emp_Full_Name] EMP_NM,
--[Emp_First_Name] FNAME,
--[Emp_Second_Name] MNAME,[Emp_Last_Name] LNAME,[Date_Of_Join] DT_JOIN,[Date_Of_Birth] DT_BIRTH,Case when Convert(varchar,[Marital_Status]) = '0' then 'Single' when Convert(varchar,[Marital_Status]) = '1' then 'Married' when Convert(varchar,[Marital_Status]) = '2' then 'Divorced' when Convert(varchar,[Marital_Status]) = '3' then 'Saperated' else Marital_Status end MAR_ST,
--Case when [Gender] = 'M' Then 'Male' when [Gender] = 'F' then 'Female' else '' end SEX,
--Desig.Desig_Name DESIG_CD_DESC,Dept.Dept_Name [Business Unit],Cat.Cat_Name [Section],
--I.Increment_Date INCR_DT,Grade.Grd_Name GRADE,I1.Basic_Salary,I1.Gross_Salary GROSS,I1.CTC,
--[SSN_No],[SIN_No],[Dr_Lic_No],[Pan_No] PAN_NO,[Work_Email] EMAIL,EMP.Blood_Group BLDGRP,EMP.Aadhar_Card_No AADHAAR_NO,EC.Name E_NAME,
--Mother.Name M_NAME,[Father_name] FATH_NM,Father.Name FATH_NM1
--,BR.Branch_Name Contractor_Name,BR.Branch_Address Contractor_Address,SubBranch_Name Sub_Contractor,
--BusSeg.Segment_Name [Sub Department],Type.Type_Name [Employee Type],CC.Cost_Center,VS.Vertical_Name [Division],SV.SubVertical_Name [Main Department],
--I1.Increment_Effective_Date [Latest Increment Date],LE.Left_Date,LE.Reg_Date [Resign Date],LE.Left_Reason,EMP.SSN_No [PF NO],EMP.SIN_NO [ESIC NO],
--[Street_1] PMNT_Street,
--[City] PMNT_CITY,[State] PMNT_State ,
--[Zip_code] PMNT_PINCode,TH.ThanaName PMNT_ThanaName,EMP.[Home_Tel_no] HOMENO,[Mobile_No] CURRENTCELL,Emp.[Work_Tel_No],[Other_Email],--,[Basic_Salary],EMP.[Image_Name],
--[Present_Street] PRSNT_Street,
--[Present_City] PRSNT_CITY,[Present_State] PRSNT_State,
--[Present_Post_Box] PRSNT_PINCode,THW.ThanaName PRSNT_ThanaName
--FROM [T0080_EMP_MASTER] EMP WITH (NOLOCK)
--	inner join T0095_INCREMENT I1 WITH (NOLOCK) ON I1.Emp_ID=EMP.EMP_ID--I1.Emp_ID=EMP.EMP_ID
--	INNER JOIN (SELECT	MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
--				FROM	T0095_INCREMENT I2  WITH (NOLOCK) 
--						INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
--									FROM	T0095_INCREMENT I3  WITH (NOLOCK) 
--									WHERE	I3.Increment_Effective_Date <= getdate()
--									GROUP BY I3.Emp_ID
--									) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
--				GROUP BY I2.Emp_ID
--				) I_Q ON I1.Emp_ID=I_Q.Emp_ID AND I1.Increment_ID=I_Q.INCREMENT_ID	 
--INNER JOIN T0010_COMPANY_MASTER CM  WITH (NOLOCK) ON CM.Cmp_Id = I1.Cmp_ID
--left join T0030_BRANCH_MASTER BR WITH (NOLOCK) On BR.Branch_ID = I1.Branch_ID and BR.Cmp_ID = I1.Cmp_ID
--left Join T0050_SubBranch SubBR WITH (NOLOCK) ON SubBR.SubBranch_ID = I1.subBranch_ID and SubBR.Branch_ID = BR.Branch_ID
--left join T0040_Business_Segment BusSeg on BusSeg.Segment_ID = I1.Segment_ID
--left join T0040_TYPE_MASTER Type on Type.Type_ID = I1.Type_ID 
--left join T0040_Cost_Center CC on CC.Tally_Center_ID = I1.Center_ID 
--left join T0040_Vertical_Segment VS on VS.Vertical_ID = I1.Vertical_ID 
--left join T0050_SubVertical SV on SV.SubVertical_ID = I1.SubVertical_ID and VS.Vertical_ID = SV.Vertical_ID 
--left join T0040_DESIGNATION_MASTER Desig WITH (NOLOCK) ON Desig.Desig_ID = I1.Desig_Id
--left join T0040_DEPARTMENT_MASTER Dept WITH (NOLOCK) On Dept.Dept_Id = I1.Dept_ID
--left join T0030_CATEGORY_MASTER Cat on Cat.Cat_ID = I1.Cat_ID
--left join T0095_INCREMENT I on I.Increment_ID = I_Q.Increment_ID and I.Emp_ID = I_Q.Emp_ID 
--left join T0040_GRADE_MASTER Grade On Grade.Grd_ID = I1.Grd_ID
--left join T0100_LEFT_EMP LE on LE.Emp_ID = I_Q.Emp_ID 
--left join T0090_EMP_EMERGENCY_CONTACT_DETAIL EC on EC.Emp_ID = I_Q.Emp_ID and EC.Cmp_ID = I1.Cmp_ID
--left Join (Select top 1 CD.Emp_Id,CD.Cmp_Id,Name from T0090_EMP_CHILDRAN_DETAIL CD inner join T0080_EMP_MASTER EMP on EMP.Emp_id = CD.Emp_Id and EMP.Cmp_id = CD.Cmp_Id and RelationShip = 'Mother') Mother On Mother.Emp_Id = I_Q.Emp_ID
--left Join (Select top 1 CD.Emp_Id,CD.Cmp_Id,Name from T0090_EMP_CHILDRAN_DETAIL CD inner join T0080_EMP_MASTER EMP on EMP.Emp_id = CD.Emp_Id and EMP.Cmp_id = CD.Cmp_Id and RelationShip = 'Father') Father On Mother.Emp_Id = I_Q.Emp_ID
--left join T0030_Thana_Master TH on TH.Thana_Id = EMP.Thana_Id
--left join T0030_Thana_Master THW on THW.Thana_Id = EMP.Thana_Id_Wok
--order by Emp.Date_Of_Join,CM.Cmp_Name,BR.Branch_Name



