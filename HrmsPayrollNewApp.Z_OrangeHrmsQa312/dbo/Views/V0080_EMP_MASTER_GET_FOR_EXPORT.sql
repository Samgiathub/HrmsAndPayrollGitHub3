



--\\** Created By Shaikh Ramiz , Specially for Samarth , Plz dont Change Alias **\\--

CREATE VIEW [dbo].[V0080_EMP_MASTER_GET_FOR_EXPORT]
AS
		SELECT	* 
		FROM (
				SELECT	ROW_NUMBER() OVER (Partition By Emp_Code ORDER BY Emp_Code,Emp_Left ) AS ROW_ID, * 
				FROM	(
						SELECT	em.Emp_ID ,em.Emp_code, em.enroll_no as Emp_Punch_Card_No ,em.Emp_Full_Name as Emp_Name,em.Emp_First_Name, em.Emp_Second_Name, em.Emp_Last_Name,
								(
									SELECT	Name 
									FROM	T0090_EMP_CHILDRAN_DETAIL WITH (NOLOCK)
									where	Relationship like '%Grandfather%'
								) as GFather,CAST(em.Date_Of_Birth AS varchar(11)) AS Emp_BDate ,em.Date_Of_Join as Emp_JDate, em.Emp_Confirm_Date as ConfirmDate,isnull(DM.Desig_Name,'') as Emp_JobDesc,
								EM.Blood_Group as Emp_Blood_Group,EM.Street_1 as Emp_Add1 , em.City as Emp_City, Em.Tehsil as Emp_Taluka ,em.District as Emp_Dist ,em.Zip_code as Emp_PinCode , 
								em.Home_Tel_no as Emp_Phone , em.Mobile_No as Emp_Mobile ,EM.Present_Street as Emp_CAdd1 ,em.Present_City as Emp_CCity , em.Tehsil_Wok as Emp_CTaluka, 
								em.District_Wok as Emp_CDist , em.Present_Post_Box as Emp_CPinCode , em.Work_Tel_No as Emp_CPhone ,em.Mobile_No as Emp_CMobile ,  EM.Emp_Superior as Mgr_Code ,
								R.Emp_Ref_Code,r.Emp_Ref_Name, --,R.Source_Names,R.Source_Type_Names ,
					
								isnull(DeptM.Dept_code,'') as Dept_code,case when EM.Emp_Left='N' then 'Current' else 'Left' end as Emp_Left ,qry.is_physical as PH , em.Vehicle_NO as VehicleNo,
								em.Gender as Gender , em.Marital_Status as MaritalStatus,em.Work_Tel_No as SamExtNo , EM.Emp_Left_Date as Emp_Leave_Date , LEM.Left_Reason as Emp_Leave_Reason,
								Bm.Branch_Name as Unit ,em.CCenter_Remark as ManagementNote , case when lem.Is_Terminate ='1' then 'DoNotAllow' else 'Allow' end as DoNotAllow ,
								em.SIN_No as ESICNo ,em.SSN_No as EPFNo , DM.Desig_Code as DesigCode , qry.Payment_Mode as SalaryInBank , BN.Bank_Code ,BN.Bank_Name , qry.Inc_Bank_AC_No , 
								em.Pan_No as PAN , em.Other_Email as MailId , Em.Work_Email as CompanyMailId ,
								 --skm.Skill_Name as AdditionalSkill , 
								 em.UAN_No as EPFUniversalId , em.Ration_Card_Type as RationCardType ,
								em.Ration_Card_No as RationCardNo , em.EmpName_Alias_PF as NameInBankForEPF  ,em.IS_Emp_FNF , case when qry.Emp_Fix_Salary = 0 then 'P' else 'F' End as WageCalculationType
								
							
						From	T0080_EMP_MASTER EM WITH (NOLOCK)
								Left Join T0080_EMP_MASTER EM1 WITH (NOLOCK) On EM.Emp_Superior = EM1.Emp_ID			
								
								Left Join (Select i.CTC,i.Emp_ID,i.Desig_Id,I.subBranch_ID,i.Increment_Type,i.Increment_Effective_Date,I.Payment_Mode,I.Inc_Bank_AC_No,
								I.Emp_Full_PF,I.Emp_PT,I.Emp_Fix_Salary,I.Emp_Part_Time,I.Late_Dedu_Type,I.wages_type,I.Center_ID,I.Gross_Salary,I.SalDate_id,I.Segment_ID , 
								i.Basic_Salary , I.Branch_ID , I.Dept_ID , I.Type_ID , I.Grd_ID , I.Cat_ID , i.Bank_ID , i.Vertical_ID , i.SubVertical_ID , i.is_physical
								From T0095_Increment i WITH (NOLOCK) inner JOIN (select max(Increment_ID) as Increment_ID, Emp_ID from T0095_Increment WITH (NOLOCK)   
								where Increment_Effective_date <= GETDATE() group by emp_ID) as inc ON inc.Emp_ID = i.Emp_ID AND inc.Increment_ID = i.Increment_ID) Qry 
								
								On EM.Emp_ID = Qry.Emp_ID	
								Left Join T0040_DESIGNATION_MASTER DM WITH (NOLOCK) On Qry.Desig_Id = DM.Desig_Id
								Left Join T0040_GRADE_MASTER GM WITH (NOLOCK) On Qry.Grd_ID = GM.Grd_ID
								Left Outer Join T0040_DEPARTMENT_MASTER DeptM WITH (NOLOCK) On Qry.Dept_ID = DeptM.Dept_Id
								Left Outer Join T0040_Type_Master TM WITH (NOLOCK) On Qry.Type_ID = TM.Type_ID
								INNER JOIN dbo.T0011_LOGIN Ln WITH (NOLOCK) ON em.Emp_ID = Ln.Emp_ID
								Left JOIN dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Qry.Branch_ID = BM.Branch_ID
								Left Outer Join T0030_CATEGORY_MASTER CTM WITH (NOLOCK) on Qry.Cat_ID=CTM.Cat_ID
								Left Outer Join T0040_Vertical_Segment VTS WITH (NOLOCK) on VTS.Vertical_ID=Qry.Vertical_ID
								Left Outer Join T0050_SubVertical SubVT WITH (NOLOCK) on SubVT.SubVertical_ID=Qry.SubVertical_ID
								Left Outer Join T0040_BANK_MASTER BN WITH (NOLOCK) on Bn.Bank_ID=Qry.Bank_ID
								Left Outer Join T0040_COST_CENTER_MASTER CCM WITH (NOLOCK) on CCM.Center_ID=Qry.Center_ID
								Left Outer Join T0040_Salary_Cycle_Master SCM WITH (NOLOCK) on SCm.Tran_Id=Qry.SalDate_id
								Left Outer Join T0040_Business_Segment BS WITH (NOLOCK) on BS.Segment_ID=Qry.Segment_ID
								Left Join T0050_SubBranch SBM WITH (NOLOCK) on  Qry.SubBranch_ID = SBM.subBranch_ID
								Left Outer Join T0100_LEFT_EMP LEM WITH (NOLOCK) on LEM.Emp_ID=EM.Emp_ID
								LEFT OUTER JOIN (
													
													SELECT	STUFF((SELECT	',' + Alpha_Emp_Code
																	FROM	T0080_EMP_MASTER A  WITH (NOLOCK)
																			right outer join T0090_EMP_REFERENCE_DETAIL B WITH (NOLOCK) ON A.Emp_ID = B.R_Emp_ID  AND A.Cmp_ID=B.Cmp_ID
																			left join T0040_Source_Master SM WITH (NOLOCK) on SM.Source_Id=B.Source_Name --and SM.Cmp_ID=A.Cmp_ID
																			
																			WHERE B.Emp_ID=R.Emp_ID AND B.Cmp_ID=R.Cmp_ID
																			for xml path('')) , 1,1,''
																) As Emp_Ref_Code, R.Emp_ID, R.Cmp_ID,
															STUFF((SELECT	',' + Emp_Full_Name 
																	FROM	T0080_EMP_MASTER A  WITH (NOLOCK)
																			right outer join T0090_EMP_REFERENCE_DETAIL B WITH (NOLOCK) ON A.Emp_ID = B.R_Emp_ID  AND A.Cmp_ID=B.Cmp_ID
																			WHERE B.Emp_ID=R.Emp_ID AND B.Cmp_ID=R.Cmp_ID
																			for xml path('')) , 1,1,''
																) As Emp_Ref_Name
														
													FROM	T0090_EMP_REFERENCE_DETAIL R  WITH (NOLOCK)
												) R ON R.Cmp_ID=EM.Cmp_ID AND R.Emp_ID=EM.Emp_ID
							--left join T0090_EMP_REFERENCE_DETAIL ERD on ERD.Emp_ID = em.Emp_ID
							--left Join T0090_EMP_SKILL_DETAIL Eskil on Eskil.Emp_ID = em.Emp_ID 
							--left join T0040_SKILL_MASTER skm on skm.Skill_ID = Eskil.Skill_ID
								
						) T
			 ) T1
			 Where ROW_ID=1




