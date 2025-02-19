



CREATE PROCEDURE [dbo].[Employee_Data_Services_Synoverge] 
	@Date	Datetime,
	@Cmp_ID numeric,
	@is_timestamp tinyint = 1,
	@Type numeric(18) = 0
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON


BEGIN
	
	
	if @type = 0	
		begin				
				if @is_timestamp = 1 
					begin						
					--	Select EM.Initial, EM.Emp_Full_Name, EM.Alpha_Emp_Code, ISNULL(EM1.Alpha_Emp_Code, '-') AS Reporting_Manager,
					--			isnull(Branch_Name,'') as Branch_Name, IsNull(Qry.CTC,0) As CTC, 'Join' As Emp_Type, DM.Desig_Name, 
					--			Case EM.Work_Email When '' Then '-' When Null Then '-' Else EM.Work_Email End As Work_Email,
					--			EM.Date_Of_Join, GM.Grd_Name, Isnull(DeptM.Dept_Name,'-') As Dept_Name, 
					--			Isnull(TM.Type_Name,'-') As Type_Name,EM.Pan_No,EM.Bank_BSR,EM.Father_name,
					--			CASE WHEN EM.Marital_Status = 0 THEN 'Single' WHEN EM.Marital_Status = 1 THEN 'Married' WHEN EM.Marital_Status = 2 THEN 'Divorced' WHEN EM.Marital_Status = 3 THEN 'Saperated' END AS Marital_Status,
					--			CTM.Cat_Name as place_of_posting,
					--			case when EM.Gender='M' then 'Male' else 'Female' end,EM.Date_Of_Birth,
					--			Em.Present_Street,VTS.Vertical_Name,SubVT.SubVertical_Name,
					--			EM.SSN_No as PF_No,EM.SIN_No as ESIC_No,EM.Dr_Lic_No,EM.Nationality,EM.Street_1 as Permanent_Address,EM.City,EM.State,EM.Zip_code,EM.Home_Tel_no,EM.Mobile_No,EM.Work_Tel_No,EM.Work_Email,EM.Other_Email,EM.Image_Name,BN.Bank_Name,Qry.Inc_Bank_AC_No,EM.Emp_Left,EM.Emp_Left_Date,EM.Present_Street [Working_Address],EM.Present_City,EM.Present_State,EM.Present_Post_Box,EM.Enroll_No,Qry.Emp_Full_PF,Qry.Emp_PT,Qry.Emp_Fix_Salary,Qry.Emp_Part_Time,Qry.Late_Dedu_Type,EM.Blood_Group,EM.Religion,EM.Height,EM.Emp_Mark_Of_Identification,EM.Insurance_No,EM.Emp_Confirm_Date,DATEDIFF(MM,EM.Date_Of_Join,getdate()) AS Work_Exp_Month,Qry.wages_type,EM.Basic_Salary,Qry.Gross_Salary,EM.Old_Ref_No,EM.Dealer_Code,CCM.Center_Name,EM.Branch_ID,
					--			(Case ISNULL(EM.Date_Of_Birth,'') when '' then '' else dbo.F_GET_AGE(EM.Date_Of_Birth,getdate(),'Y','N') END ) as Age,
					--			EM.Emp_Superior as Manager_Code,SCM.Name as Salary_Cycle,Bs.Segment_Name,EM.GroupJoiningDate
					--		From T0080_EMP_MASTER EM
					--			Left Join T0080_EMP_MASTER EM1 On EM.Emp_Superior = EM1.Emp_ID			
					--			Left Join (Select CTC,Emp_ID,Branch_Id,Payment_Mode,Inc_Bank_AC_No,Emp_Full_PF,Emp_PT,Emp_Fix_Salary,Emp_Part_Time,Late_Dedu_Type,wages_type,Center_ID,Gross_Salary,SalDate_id,Segment_ID From T0095_Increment Where Increment_Type = 'Joining') Qry 
					--				On EM.Emp_ID = Qry.Emp_ID
					--			Left Join T0030_BRANCH_MASTER BM On Qry.Branch_ID = BM.Branch_ID
					--			Left Join T0040_DESIGNATION_MASTER DM On EM.Desig_Id = DM.Desig_Id
					--			Left Join T0040_GRADE_MASTER GM On EM.Grd_ID = GM.Grd_ID	
					--			Left Outer Join T0040_DEPARTMENT_MASTER DeptM On EM.Dept_ID = DeptM.Dept_Id
					--			Left Outer Join T0040_Type_Master TM On EM.Type_ID = TM.Type_ID	
					--			Left Outer Join T0030_CATEGORY_MASTER CTM on EM.Cat_ID=CTM.Cat_ID
					--			Left Outer Join T0040_Vertical_Segment VTS on VTS.Vertical_ID=EM.Vertical_ID
					--			Left Outer Join T0050_SubVertical SubVT on SubVT.SubVertical_ID=EM.SubVertical_ID
					--			Left Outer Join T0040_BANK_MASTER BN on Bn.Bank_ID=EM.Bank_ID
					--			Left Outer Join T0040_COST_CENTER_MASTER CCM on CCM.Center_ID=Qry.Center_ID
					--			Left Outer Join T0040_Salary_Cycle_Master SCM on SCm.Tran_Id=Qry.SalDate_id
					--			Left Outer Join T0040_Business_Segment BS on BS.Segment_ID=Qry.Segment_ID
					--		Where EM.Date_Of_Join = @Date
					--	Union
					--	Select EM.Initial, EM.Emp_Full_Name, EM.Alpha_Emp_Code, ISNULL(EM1.Alpha_Emp_Code, '-') AS Reporting_Manager,
					--			Branch_Name, Isnull(Qry1.CTC,0) As CTC, 'Left' As Emp_Type, DM.Desig_Name, 
					--			Case EM.Work_Email When '' Then '-' When Null Then '-' Else EM.Work_Email End As Work_Email,
					--			EM.Date_Of_Join, GM.Grd_Name, Isnull(DeptM.Dept_Name,'-') As Dept_Name,
					--			Isnull(TM.Type_Name,'-') As Type_Name,EM.Pan_No,EM.Bank_BSR,EM.Father_name,
					--			CASE WHEN EM.Marital_Status = 0 THEN 'Single' WHEN EM.Marital_Status = 1 THEN 'Married' WHEN EM.Marital_Status = 2 THEN 'Divorced' WHEN EM.Marital_Status = 3 THEN 'Saperated' END AS Marital_Status,
					--			CTM.Cat_Name as place_of_posting,case when EM.Gender='M' then 'Male' else 'Female' end,
					--			EM.Date_Of_Birth,Em.Present_Street,VTS.Vertical_Name,SubVT.SubVertical_Name,
					--			EM.SSN_No as PF_No,EM.SIN_No as ESIC_No,EM.Dr_Lic_No,EM.Nationality,EM.Street_1 as Permanent_Address,EM.City,EM.State,EM.Zip_code,EM.Home_Tel_no,EM.Mobile_No,EM.Work_Tel_No,EM.Work_Email,EM.Other_Email,EM.Image_Name,BN.Bank_Name,Qry1.Inc_Bank_AC_No,EM.Emp_Left,EM.Emp_Left_Date,EM.Present_Street [Working_Address],EM.Present_City,EM.Present_State,EM.Present_Post_Box,EM.Enroll_No,Qry1.Emp_Full_PF,Qry1.Emp_PT,Qry1.Emp_Fix_Salary,Qry1.Emp_Part_Time,Qry1.Late_Dedu_Type,EM.Blood_Group,EM.Religion,EM.Height,EM.Emp_Mark_Of_Identification,EM.Insurance_No,EM.Emp_Confirm_Date,DATEDIFF(MM,EM.Date_Of_Join,getdate()) AS Work_Exp_Month,Qry1.wages_type,EM.Basic_Salary,Qry1.Gross_Salary,EM.Old_Ref_No,EM.Dealer_Code,CCM.Center_Name,EM.Branch_ID,
					--			(Case ISNULL(EM.Date_Of_Birth,'') when '' then '' else dbo.F_GET_AGE(EM.Date_Of_Birth,getdate(),'Y','N') END ) as Age,
					--			EM.Emp_Superior as Manager_Code,SCM.Name as Salary_Cycle,Bs.Segment_Name,EM.GroupJoiningDate
					--		From T0080_EMP_MASTER EM
					--			Left Join T0080_EMP_MASTER EM1 On EM.Emp_Superior = EM1.Emp_ID			
					--			Left Join (select CTC, I.Emp_ID, I.Branch_Id,I.Payment_Mode,I.Inc_Bank_AC_No,I.Emp_Full_PF,I.Emp_PT,I.Emp_Fix_Salary,I.Emp_Part_Time,I.Late_Dedu_Type,I.wages_type,I.Center_ID,I.Gross_Salary,I.SalDate_id,I.Segment_ID From T0095_Increment I 
					--						inner join 										
					--						(Select max(Increment_effective_Date) as For_Date, Emp_ID 
					--										From T0095_Increment    
					--										--Where Increment_Effective_date <= Getdate() 
					--										Group By Emp_ID) Qry 
					--								On I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date) Qry1
					--					On EM.Emp_ID = Qry1.Emp_ID
					--			Left Join T0030_BRANCH_MASTER BM On Qry1.Branch_ID = BM.Branch_ID	
					--			Left Join T0040_DESIGNATION_MASTER DM On EM.Desig_Id = DM.Desig_Id	
					--			Left Join T0040_GRADE_MASTER GM On EM.Grd_ID = GM.Grd_ID
					--			Left Outer Join T0040_DEPARTMENT_MASTER DeptM On EM.Dept_ID = DeptM.Dept_Id
					--			Left Outer Join T0040_Type_Master TM On EM.Type_ID = TM.Type_ID
					--			Left Outer Join T0030_CATEGORY_MASTER CTM on EM.Cat_ID=CTM.Cat_ID
					--			Left Outer Join T0040_Vertical_Segment VTS on VTS.Vertical_ID=EM.Vertical_ID
					--			Left Outer Join T0050_SubVertical SubVT on SubVT.SubVertical_ID=EM.SubVertical_ID
					--			Left Outer Join T0040_BANK_MASTER BN on Bn.Bank_ID=EM.Bank_ID
					--			Left Outer Join T0040_COST_CENTER_MASTER CCM on CCM.Center_ID=Qry1.Center_ID
					--			Left Outer Join T0040_Salary_Cycle_Master SCM on SCm.Tran_Id=Qry1.SalDate_id
					--			Left Outer Join T0040_Business_Segment BS on BS.Segment_ID=Qry1.Segment_ID
					--		Where EM.Emp_Left_Date = @Date
					--		Union
					--		Select EM.Initial, EM.Emp_Full_Name, EM.Alpha_Emp_Code, ISNULL(EM1.Alpha_Emp_Code, '-') AS Reporting_Manager,
					--			Branch_Name, IsNull(Qry.CTC,0) As CTC, Increment_Type As Emp_Type, DM.Desig_Name, 
					--			Case EM.Work_Email When '' Then '-' When Null Then '-' Else EM.Work_Email End As Work_Email,
					--			EM.Date_Of_Join, GM.Grd_Name, Isnull(DeptM.Dept_Name,'-') As Dept_Name, 
					--			Isnull(TM.Type_Name,'-') As Type_Name,EM.Pan_No,EM.Bank_BSR,EM.Father_name,EM.Marital_Status,CTM.Cat_Name as place_of_posting,case when EM.Gender='M' then 'Male' else 'Female' end,EM.Date_Of_Birth,Em.Present_Street,VTS.Vertical_Name,SubVT.SubVertical_Name
								
					--		From T0080_EMP_MASTER EM
					--			Left Join T0080_EMP_MASTER EM1 On EM.Emp_Superior = EM1.Emp_ID			
					--			Left Join (Select CTC,Emp_ID,Branch_Id,Increment_Type,Increment_Effective_Date From T0095_Increment  Where Increment_Type <> 'Joining' ) Qry 
					--				On EM.Emp_ID = Qry.Emp_ID
					--			Left Join T0030_BRANCH_MASTER BM On Qry.Branch_ID = BM.Branch_ID
					--			Left Join T0040_DESIGNATION_MASTER DM On EM.Desig_Id = DM.Desig_Id
					--			Left Join T0040_GRADE_MASTER GM On EM.Grd_ID = GM.Grd_ID	
					--			Left Outer Join T0040_DEPARTMENT_MASTER DeptM On EM.Dept_ID = DeptM.Dept_Id
					--			Left Outer Join T0040_Type_Master TM On EM.Type_ID = TM.Type_ID	
					--			Left Outer Join T0030_CATEGORY_MASTER CTM on EM.Cat_ID=CTM.Cat_ID
					--			Left Outer Join T0040_Vertical_Segment VTS on VTS.Vertical_ID=EM.Vertical_ID
					--			Left Outer Join T0050_SubVertical SubVT on SubVT.SubVertical_ID=EM.SubVertical_ID
								
					--			--Left Outer Join T0040_BANK_MASTER BN on Bn.Bank_ID=EM.Bank_ID
					--			--Left Outer Join T0040_COST_CENTER_MASTER CCM on CCM.Center_ID=Qry1.Center_ID
					--			--Left Outer Join T0040_Salary_Cycle_Master SCM on SCm.Tran_Id=Qry1.SalDate_id
					--			--Left Outer Join T0040_Business_Segment BS on BS.Segment_ID=Qry1.Segment_ID
					--		Where Qry.Increment_Effective_Date = @Date
					--		Order By Emp_Type
					--end
				--else
				--	begin
				--		select * from 
				--			(
							
				--				Select  EM.Emp_Full_Name, isnull(EM.Alpha_Emp_Code,'-') as Alpha_Emp_Code, ISNULL(EM1.Alpha_Emp_Code, '-') AS Reporting_Manager,
				--					isnull(Branch_Name,'') as Branch_Name, IsNull(Qry.CTC,0) As CTC,  qry.Increment_Type As Emp_Type, isnull(DM.Desig_Name,'') as Desig_Name, 
				--					Case EM.Work_Email When '' Then '-' When Null Then '-' Else EM.Work_Email End As Work_Email,
				--					EM.Date_Of_Join, isnull(GM.Grd_Name,'') as Grd_Name , Isnull(DeptM.Dept_Name,'-') As Dept_Name, 
				--					Isnull(TM.Type_Name,'-') As Type_Name, Qry.eTimeStamp,ISNULL(SBM.SubBranch_Name,'-') as Sub_Branch -- Added By Ali 06032014,
				--					--EM.Pan_No,EM.Bank_BSR,EM.Father_name,EM.Marital_Status,CTM.Cat_Name,case when EM.Gender='M' then 'Male' else 'Female' end,EM.Date_Of_Birth,Em.Present_Street,VTS.Vertical_Name,SubVT.SubVertical_Name
				--				From T0080_EMP_MASTER EM
				--					Left Join T0080_EMP_MASTER EM1 On EM.Emp_Superior = EM1.Emp_ID			
				--					Left Join (Select CTC,i.Emp_ID,Branch_Id,System_Date as eTimeStamp,Increment_Type,subBranch_ID From T0095_Increment i
				--								inner JOIN (SELECT max(Increment_Effective_Date) as Increment_Effective_Date , emp_id from T0095_INCREMENT where System_Date >= @Date GROUP by Emp_id) as Inc
				--								on Inc.Emp_ID = i.Emp_ID AND inc.Increment_Effective_Date = i.Increment_Effective_Date
				--								where System_Date >= @Date) Qry 
				--						On EM.Emp_ID = Qry.Emp_ID
				--					Left Join T0030_BRANCH_MASTER BM On Qry.Branch_ID = BM.Branch_ID
				--					Left Join T0050_SubBranch SBM on  Qry.SubBranch_ID = SBM.subBranch_ID -- Added By Ali 06032014
				--					Left Join T0040_DESIGNATION_MASTER DM On EM.Desig_Id = DM.Desig_Id
				--					Left Join T0040_GRADE_MASTER GM On EM.Grd_ID = GM.Grd_ID	
				--					Left Outer Join T0040_DEPARTMENT_MASTER DeptM On EM.Dept_ID = DeptM.Dept_Id
				--					Left Outer Join T0040_Type_Master TM On EM.Type_ID = TM.Type_ID	
				--					--Left Outer Join T0030_CATEGORY_MASTER CTM on EM.Cat_ID=CTM.Cat_ID
				--					--Left Outer Join T0040_Vertical_Segment VTS on VTS.Vertical_ID=EM.Vertical_ID
				--					--Left Outer Join T0050_SubVertical SubVT on SubVT.SubVertical_ID=EM.SubVertical_ID
				--				Where Qry.eTimeStamp >= @Date AND (EM.Emp_Left <> 'Y' OR EM.Emp_Left <> 'y')
								
				--				union
								
				--				Select EM.Emp_Full_Name, isnull(EM.Alpha_Emp_Code,'-') as Alpha_Emp_Code, ISNULL(EM1.Alpha_Emp_Code, '-') AS Reporting_Manager,
				--					isnull(Branch_Name,'') as Branch_Name, IsNull(Qry.CTC,0) As CTC,  'Left' As Emp_Type, isnull(DM.Desig_Name,'') as Desig_Name, 
				--					Case EM.Work_Email When '' Then '-' When Null Then '-' Else EM.Work_Email End As Work_Email,
				--					EM.Emp_Left_Date, isnull(GM.Grd_Name,'') as Grd_Name, Isnull(DeptM.Dept_Name,'-') As Dept_Name, 
				--					Isnull(TM.Type_Name,'-') As Type_Name, EM.Emp_Left_Date as eTimeStamp,ISNULL(SBM.SubBranch_Name,'-') as Sub_Branch -- Added By Ali 06032014
				--					--EM.Pan_No,EM.Bank_BSR,EM.Father_name,EM.Marital_Status,CTM.Cat_Name,case when EM.Gender='M' then 'Male' else 'Female' end,EM.Date_Of_Birth,Em.Present_Street,VTS.Vertical_Name,SubVT.SubVertical_Name
				--				From T0080_EMP_MASTER EM
				--					Left Join T0080_EMP_MASTER EM1 On EM.Emp_Superior = EM1.Emp_ID			
				--					Left Join (Select i.CTC,i.Emp_ID,i.Branch_Id,i.System_Date as eTimeStamp,i.Increment_Type,i.increment_id,subBranch_ID From T0095_Increment  i 
				--								inner join (select max(increment_effective_date) as increment_effective_date , emp_id from t0095_increment group by emp_id) as incq
				--								on i.increment_effective_date = incq.increment_effective_date and i.emp_id = incq.emp_id ) Qry
				--					On EM.Emp_ID = Qry.Emp_ID AND EM.Increment_ID = Qry.Increment_ID
				--					Left Join T0030_BRANCH_MASTER BM On Qry.Branch_ID = BM.Branch_ID
				--					Left Join T0050_SubBranch SBM on Qry.SubBranch_ID = SBM.subBranch_ID -- Added By Ali 06032014
				--					Left Join T0040_DESIGNATION_MASTER DM On EM.Desig_Id = DM.Desig_Id
				--					Left Join T0040_GRADE_MASTER GM On EM.Grd_ID = GM.Grd_ID	
				--					Left Outer Join T0040_DEPARTMENT_MASTER DeptM On EM.Dept_ID = DeptM.Dept_Id
				--					Left Outer Join T0040_Type_Master TM On EM.Type_ID = TM.Type_ID	
				--					--Left Outer Join T0030_CATEGORY_MASTER CTM on EM.Cat_ID=CTM.Cat_ID
				--					--Left Outer Join T0040_Vertical_Segment VTS on VTS.Vertical_ID=EM.Vertical_ID
				--					--Left Outer Join T0050_SubVertical SubVT on SubVT.SubVertical_ID=EM.SubVertical_ID
				--				Where EM.Emp_Left_Date >= @Date
								
				--		 ) as tbl1 
							 
							
						 
				--	end
		--end
	--else
	--	begin
		-------------------Above are commented by sumit 21112014----------------------------------
		-------------------------Already Commented--------------------------------------------------------------
		
				--Select EM.Emp_Full_Name, EM.Alpha_Emp_Code,  DM.Desig_Name, '' as skills
				--			From T0080_EMP_MASTER EM
				--				Left Join T0080_EMP_MASTER EM1 On EM.Emp_Superior = EM1.Emp_ID			
				--				Left Join (Select CTC,Emp_ID,Branch_Id From T0095_Increment Where Increment_Type = 'Joining') Qry 
				--					On EM.Emp_ID = Qry.Emp_ID
				--				Left Join T0030_BRANCH_MASTER BM On Qry.Branch_ID = BM.Branch_ID
				--				Left Join T0040_DESIGNATION_MASTER DM On EM.Desig_Id = DM.Desig_Id
				--				Left Join T0040_GRADE_MASTER GM On EM.Grd_ID = GM.Grd_ID	
				--				Left Outer Join T0040_DEPARTMENT_MASTER DeptM On EM.Dept_ID = DeptM.Dept_Id
				--				Left Outer Join T0040_Type_Master TM On EM.Type_ID = TM.Type_ID	
				--			Where EM.Date_Of_Join  = @Date
				--		Union
				--		Select EM.Emp_Full_Name, EM.Alpha_Emp_Code,  DM.Desig_Name, '' as skills
				--			From T0080_EMP_MASTER EM
				--				Left Join T0080_EMP_MASTER EM1 On EM.Emp_Superior = EM1.Emp_ID			
				--				Left Join (select CTC, I.Emp_ID, I.Branch_Id From T0095_Increment I 
				--							inner join (Select max(Increment_effective_Date) as For_Date, Emp_ID 
				--											From T0095_Increment    
				--											--Where Increment_Effective_date <= Getdate() 
				--											Group By Emp_ID) Qry 
				--									On I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date <= Qry.For_Date) Qry1
				--						On EM.Emp_ID = Qry1.Emp_ID
				--				Left Join T0030_BRANCH_MASTER BM On Qry1.Branch_ID = BM.Branch_ID	
				--				Left Join T0040_DESIGNATION_MASTER DM On EM.Desig_Id = DM.Desig_Id	
				--				Left Join T0040_GRADE_MASTER GM On EM.Grd_ID = GM.Grd_ID
				--				Left Outer Join T0040_DEPARTMENT_MASTER DeptM On EM.Dept_ID = DeptM.Dept_Id
				--				Left Outer Join T0040_Type_Master TM On EM.Type_ID = TM.Type_ID
				--			Where EM.Emp_Left_Date  = @Date
				--			Union
				
						Select  isnull(EM.Alpha_Emp_Code,'') as Alpha_Emp_Code,
						 EM.Emp_Full_Name as Emp_full_Name,
						 isnull(DM.Desig_Name,'') as Desig_Name,
						 	EM.Work_Email,
						EM.Date_OF_Join,
							DATEDIFF(MM,EM.Date_Of_Join,getdate()) AS Work_Exp_Month,
						 EM1.Emp_Full_Name AS Reporting_Manager,
						
						
						EM.Date_of_Birth,
						
					
						
						CASE WHEN EM.Marital_Status = '0' THEN 'Single' WHEN EM.Marital_Status = '1' THEN 'Married' WHEN EM.Marital_Status = '2' THEN 'Divorced' WHEN EM.Marital_Status = '3' THEN 'Saperated' END AS Marital_Status,
						(Case ISNULL(EM.Date_Of_Birth,'') when '' then '' else dbo.F_GET_AGE(EM.Date_Of_Birth,getdate(),'Y','N') END ) as Age,
						EM.Emp_Superior as Manager_Code
							From T0080_EMP_MASTER EM WITH (NOLOCK)			-- Added By Gadriwala Muslim 18042014 (Added New Field)
								Left Join T0080_EMP_MASTER EM1 WITH (NOLOCK) On EM.Emp_Superior = EM1.Emp_ID			
								Left Join (Select i.Cmp_ID, i.CTC,i.Emp_ID,i.Desig_Id,I.subBranch_ID,i.Increment_Type,i.Increment_Effective_Date,I.Payment_Mode,I.Inc_Bank_AC_No,I.Emp_Full_PF,I.Emp_PT,I.Emp_Fix_Salary,I.Emp_Part_Time,I.Late_Dedu_Type,I.wages_type,I.Center_ID,I.Gross_Salary,I.SalDate_id,I.Segment_ID From T0095_Increment i WITH (NOLOCK)
											inner JOIN (select max(Increment_effective_Date) as Increment_effective_Date, Emp_ID from T0095_Increment WITH (NOLOCK)   
														where Increment_Effective_date <= @Date group by emp_ID) as inc ON inc.Emp_ID = i.Emp_ID AND inc.Increment_effective_Date = i.Increment_Effective_Date) Qry 
									On EM.Emp_ID = Qry.Emp_ID
								Left Join T0040_DESIGNATION_MASTER DM WITH (NOLOCK) On Qry.Desig_Id = DM.Desig_Id
								Left Join T0040_GRADE_MASTER GM WITH (NOLOCK) On EM.Grd_ID = GM.Grd_ID	
								Left Outer Join T0040_DEPARTMENT_MASTER DeptM WITH (NOLOCK) On EM.Dept_ID = DeptM.Dept_Id
								Left Outer Join T0040_Type_Master TM WITH (NOLOCK) On EM.Type_ID = TM.Type_ID	
								INNER JOIN dbo.T0011_LOGIN Ln WITH (NOLOCK) ON em.Emp_ID = Ln.Emp_ID				 -- Added By Gadriwala Muslim 18042014
								INNER JOIN dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON em.Branch_ID = BM.Branch_ID -- Added By Gadriwala Muslim 18042014
							--Left Outer Join T0040_Type_Master TM On EM.Type_ID = TM.Type_ID	
							Left Outer Join T0030_CATEGORY_MASTER CTM WITH (NOLOCK) on EM.Cat_ID=CTM.Cat_ID
							Left Outer Join T0040_Vertical_Segment VTS WITH (NOLOCK) on VTS.Vertical_ID=EM.Vertical_ID
							Left Outer Join T0050_SubVertical SubVT WITH (NOLOCK) on SubVT.SubVertical_ID=EM.SubVertical_ID
							Left Outer Join T0040_BANK_MASTER BN WITH (NOLOCK) on Bn.Bank_ID=EM.Bank_ID
							Left Outer Join T0040_COST_CENTER_MASTER CCM WITH (NOLOCK) on CCM.Center_ID=Qry.Center_ID
							Left Outer Join T0040_Salary_Cycle_Master SCM WITH (NOLOCK) on SCm.Tran_Id=Qry.SalDate_id
							Left Outer Join T0040_Business_Segment BS WITH (NOLOCK) on BS.Segment_ID=Qry.Segment_ID
							Left Join T0050_SubBranch SBM WITH (NOLOCK) on  Qry.SubBranch_ID = SBM.subBranch_ID
							Left Outer Join T0100_LEFT_EMP LEM WITH (NOLOCK) on LEM.Emp_ID=EM.Emp_ID 
							left OUTER join T0010_COMPANY_MASTER CM WITH (NOLOCK) on Qry.Cmp_ID = CM.Cmp_Id
							
							
							--Where EM.Emp_Left <> 'Y' --and EM.Emp_Left <> 'y'
							--and EM.Emp_Left_Date=@Date
							---Order By Alpha_Emp_Code
							Where Em.date_of_join <=@Date and Em.cmp_ID=@Cmp_ID and EM.Emp_Left <> 'y' 
							--and EM.Emp_Left_Date=@Date
							 Order by Case When IsNumeric(EM.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + EM.Alpha_Emp_Code, 20)
				When IsNumeric(EM.Alpha_Emp_Code) = 0 then Left(EM.Alpha_Emp_Code + Replicate('',21), 20)
					Else EM.Alpha_Emp_Code
					end
					
			
	end
End
END

