



---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_EMP_HISTORY_GET]
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		numeric   = 0
	,@Cat_ID		numeric  = 0
	,@Grd_ID		numeric = 0
	,@Type_ID		numeric  = 0
	,@Dept_ID		numeric  = 0
	,@Desig_ID		numeric = 0
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(MAX) = ''
	,@New_Join_emp	numeric = 0 
	,@Left_Emp		Numeric = 0
	,@Detail_Type   varchar(100)    
	,@PBranch_ID	varchar(max)= '' --Added By Jaina 08-10-2015
	,@PVertical_ID	varchar(max)= '' --Added By Jaina 08-10-2015
	,@PSubVertical_ID	varchar(max)= '' --Added By Jaina 08-10-2015
	,@PDept_ID varchar(max)=''  --Added By Jaina 08-10-2015       
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	

	if @Branch_ID = 0
		set @Branch_ID = null
	if @Cat_ID = 0
		set @Cat_ID = null
		 
	if @Type_ID = 0
		set @Type_ID = null
	if @Dept_ID = 0
		set @Dept_ID = null
	if @Grd_ID = 0
		set @Grd_ID = null
	if @Emp_ID = 0
		set @Emp_ID = null
		
	If @Desig_ID = 0
		set @Desig_ID = null
	IF @PBranch_ID = '0' or @PBranch_ID='' --Added By Jaina 08-10-2015
		set @PBranch_ID = null   	
		
	if @PVertical_ID ='0' or @PVertical_ID = ''		--Added By Jaina 08-10-2015
		set @PVertical_ID = null

	if @PsubVertical_ID ='0' or @PsubVertical_ID = ''	--Added By Jaina 08-10-2015
		set @PsubVertical_ID = null
		
	IF @PDept_ID = '0' or @PDept_Id=''  --Added By Jaina 08-10-2015
		set @PDept_ID = NULL	 
		
	--Added By Jaina 8-10-2015 Start		
	if @PBranch_ID is null
	Begin	
		select   @PBranch_ID = COALESCE(@PBranch_ID + ',', '') + cast(Branch_ID as nvarchar(5))  from T0030_BRANCH_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		set @PBranch_ID = @PBranch_ID + ',0'
	End
	
	if @PVertical_ID is null
	Begin	
		select   @PVertical_ID = COALESCE(@PVertical_ID + ',', '') + cast(Vertical_ID as nvarchar(5))  from T0040_Vertical_Segment WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		If @PVertical_ID IS NULL
			set @PVertical_ID = '0';
		else
			set @PVertical_ID = @PVertical_ID + ',0'		
	End
	if @PsubVertical_ID is null
	Begin	
		select   @PsubVertical_ID = COALESCE(@PsubVertical_ID + ',', '') + cast(subVertical_ID as nvarchar(5))  from T0050_SubVertical WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		If @PsubVertical_ID IS NULL
			set @PsubVertical_ID = '0';
		else
			set @PsubVertical_ID = @PsubVertical_ID + ',0'
	End
	IF @PDept_ID is null
	Begin
		select   @PDept_ID = COALESCE(@PDept_ID + ',', '') + cast(Dept_ID as nvarchar(5))  from T0040_DEPARTMENT_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 		
		if @PDept_ID is null
			set @PDept_ID = '0';
		else
			set @PDept_ID = @PDept_ID + ',0'
	End
	--Added By Jaina 8-10-2015 End
	
	CREATE TABLE #Emp_Cons	-- Ankit 10092014 for Same Date Increment
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )  
	 	
	 EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0,0,0,0,0 ,0,@New_Join_emp,@Left_Emp
	
	--Added By Jaina 8-10-2015 Start
	DELETE FROM #Emp_Cons
	WHERE NOT EXISTS (
					select	 E.Emp_ID 
					from	#Emp_Cons as  E Inner JOIN T0095_INCREMENT as i WITH (NOLOCK) ON i.Increment_ID = E.Increment_ID
					where	EXISTS (select Data from dbo.Split(@PBranch_ID, ',') PB Where cast(PB.data as numeric)=Isnull(I.Branch_ID,0))
					  and EXISTS (select Data from dbo.Split(@PVertical_ID, ',') V Where cast(v.data as numeric)=Isnull(I.Vertical_ID,0))
					  and EXISTS (select Data from dbo.Split(@PsubVertical_ID, ',') S Where cast(S.data as numeric)=Isnull(I.SubVertical_ID,0))
					  and EXISTS (select Data from dbo.Split(@PDept_ID, ',') D Where cast(D.data as numeric)=Isnull(I.Dept_ID,0))  
							AND #Emp_Cons.Increment_ID = E.Increment_ID
				)
	--Added By Jaina 8-10-2015 End
	
	--Declare @Emp_Cons Table
	--	(
	--		Emp_ID	numeric
	--	)
	
	--if @Constraint <> ''
	--	begin
	--		Insert Into @Emp_Cons
	--		select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
	--	end
	--else if @New_Join_emp = 1 
	--	begin
	--		Insert Into @Emp_Cons

	--		select I.Emp_Id from T0095_Increment I inner join T0080_Emp_Master e on i.Emp_ID = E.Emp_ID inner join 
	--				( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment
	--				where Increment_Effective_date <= @To_Date
	--				and Cmp_ID = @Cmp_ID
	--				group by emp_ID  ) Qry on
	--				I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date
	--		Where I.Cmp_ID = @Cmp_ID 
	--		and Isnull(I.Cat_ID,0) = Isnull(@Cat_ID ,Isnull(I.Cat_ID,0))
	--		and I.Branch_ID = isnull(@Branch_ID ,I.Branch_ID)
	--		and I.Grd_ID = isnull(@Grd_ID ,I.Grd_ID)
	--		and isnull(I.Dept_ID,0) = isnull(@Dept_ID ,isnull(I.Dept_ID,0))
	--		and Isnull(I.Type_ID,0) = isnull(@Type_ID ,Isnull(I.Type_ID,0))
	--		and Isnull(I.Desig_ID,0) = isnull(@Desig_ID ,Isnull(I.Desig_ID,0))
	--		and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
	--		and Date_of_Join >=@From_Date and Date_OF_Join <=@to_Date
			
	--	end
	--else if @Left_Emp = 1 
	--	begin
	--		Insert Into @Emp_Cons

	--		select I.Emp_Id from T0095_Increment I inner join T0100_lefT_emp Le on i.emp_Id = le.emp_ID inner join 
	--				( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment
	--				where Increment_Effective_date <= @To_Date
	--				and Cmp_ID = @Cmp_ID
	--				group by emp_ID  ) Qry on
	--				I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date
	--		Where I.Cmp_ID = @Cmp_ID 
	--		and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
	--		and Branch_ID = isnull(@Branch_ID ,Branch_ID)
	--		and Grd_ID = isnull(@Grd_ID ,Grd_ID)
	--		and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
	--		and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
	--		and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
	--		and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
	--		and Left_date >=@From_Date and Left_Date <=@to_Date
	--	end		
	--else 
	--	begin
	--		Insert Into @Emp_Cons

	--		select I.Emp_Id from T0095_Increment I inner join 
	--				( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment
	--				where Increment_Effective_date <= @To_Date
	--				and Cmp_ID = @Cmp_ID
	--				group by emp_ID  ) Qry on
	--				I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date
	--		Where Cmp_ID = @Cmp_ID 
	--		and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
	--		and Branch_ID = isnull(@Branch_ID ,Branch_ID)
	--		and Grd_ID = isnull(@Grd_ID ,Grd_ID)
	--		and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
	--		and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
	--		and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
	--		and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
	--		and I.Emp_ID in 
	--			( select Emp_Id from
	--			(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
	--			where cmp_ID = @Cmp_ID   and  
	--			(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
	--			or ( @To_Date  >= join_Date  and @To_Date <= left_date )
	--			or Left_date is null and @To_Date >= Join_Date)
	--			or @To_Date >= left_date and  @From_Date <= left_date ) 
			
	--	end
		
--If 	@Detail_Type='All'
--	Begin
		
		
--	End

If @Detail_Type='Basic'
	Begin		
		select EM.Initial 'Initial',EM.Emp_First_Name as 'First Name',EM.Emp_Second_Name as 'Middle Name',
		EM.Emp_Last_Name as 'Last Name',EM.Alpha_Emp_Code as 'Employee Code',BM.Branch_Name as 'Branch',
		GM.Grd_Name as 'Grade',EM.Date_Of_Join as 'Date Of Joining',SM.Shift_Name as 'Shift',
		DM.Desig_Name as 'Designation',Dept.Dept_Name as 'Department',EM.Basic_Salary as 'Basic Salary',
		EM.Enroll_No as 'Enroll No',Type.Type_Name as 'Type',
		CM.Cat_Name as 'Category',Case When EM.Is_On_Probation=1 then 'Yes' else 'No' End as 'On Probation?',
		Case When EM.Is_LWF=1 then 'Yes' else 'No' End as 'LWF?', 
		Case When EM.Gender='M' Then 'Male' Else 'Female' End as 'Gender',
		EM.Worker_Adult_No as 'Adult Number',
		EM.Father_name as 'Father Name/Mother Name',EM.Date_Of_Birth as 'Date of Birth',EM.Dr_Lic_No as 'Driving License',
		EM.Dr_Lic_Ex_Date as 'Expiry Date of Driving License',EM.Emp_UIDNo as 'UID No',
		EM.Pan_No as 'PAN No',EM.Religion as 'Religion',EM.Emp_Category as 'Employee Category',EM.Emp_Cast as 'Cast',
		EM.Height as 'Height',EM.Emp_Mark_Of_Identification as 'Mark Identification',EM.Insurance_No as 'Insurance No',
		EM.Emp_Confirm_Date as 'Confirm Date',EM.Emp_Annivarsary_Date as 'Marriage Date',EM.Probation as 'Probation',
		EM.Blood_Group as 'Blood Group',EM.Other_Email as 'Personal Email ID',EM.Despencery as 'Dispensary',
		Replace(EM.DespenceryAddress,',',' ') as 'Dispensary Address',EM.Doctor_Name as 'Doctor Name',
		Replace(EM.Street_1,',',' ') as 'Permanent Address',EM.City as 'City',EM.State,EM.Zip_code as 'Pin code',
		LM.Loc_name as 'Country',Replace(EM.Home_Tel_no,',',' ') as 'Tel No',Replace(EM.Work_Tel_No,',',' ') as 'Office No',
		EM.Mobile_No as 'Mobile No',EM.Nationality as 'Nationality',Replace(EM.Present_Street,',',' ') as 'Present/Working Address',
		EM.Present_City as 'City(Working)',EM.Present_State as 'State(Working)',EM.Present_Post_Box as 'Pin code(Working)',
		EM.Work_Email as 'Official E-Mail',Bank.Bank_Name as 'Bank',Curr.Curr_Name as 'Currency',
		Case When EM.Is_Gr_App =1 then 'Yes' Else 'No' End as 'Gratuity App.',
		Case When EM.Is_Yearly_Bonus =1 then 'Yes' Else 'No' End as 'Bonus Yearly',
		EM.Yearly_Leave_Days as 'Year Leave Days' ,EM.Yearly_Leave_Amount as 'Yearly Leave Amount',
		EM.Yearly_Bonus_Per as 'Year Bonus Per',EM.Yearly_Bonus_Amount  as 'Yearly Bonus Amount',
		EM.Emp_PF_Opening as 'PF Opening Amount',EM.Bank_BSR as 'Bank BSR No',EM.DBRD_Code as 'DBRD Code',
		EM.Ifsc_Code as 'IFSC Code',EM.Dealer_Code as 'Dealer Code',
		EM.CCenter_Remark as 'Remark',EM.Extra_AB_Deduction as 'Extra AB Deduction (Days)',		
		EM.System_Date as 'Changed Date',IsNull(EM1.Emp_Full_Name,'Admin') as 'Changed By'
		from T0080_EMP_MASTER_Clone  EM WITH (NOLOCK)
		inner join T0011_LOGIN LO WITH (NOLOCK) on em.Login_ID = lo.Login_ID And EM.Cmp_ID = Lo.Cmp_ID 
		left outer join T0080_EMP_MASTER EM1 WITH (NOLOCK) on lo.Emp_ID = EM1.Emp_ID And Lo.Cmp_ID = EM1.Cmp_ID 
		Left Outer Join T0030_BRANCH_MASTER BM WITH (NOLOCK) On EM.Branch_ID=BM.Branch_ID And EM.Cmp_ID=BM.Cmp_ID 
		Left Outer Join T0030_CATEGORY_MASTER CM WITH (NOLOCK) On EM.Cat_ID=CM.Cat_ID ANd EM.Cmp_ID=CM.cmp_ID   
		Left Outer Join T0040_GRADE_MASTER GM WITH (NOLOCK) On EM.Grd_ID=GM.Grd_ID And EM.Cmp_ID=GM.Cmp_ID
		Left Outer Join T0040_SHIFT_MASTER SM WITH (NOLOCK) On EM.Shift_ID =SM.Shift_ID And EM.Cmp_ID=SM.Cmp_ID  
		Left Outer Join T0040_DESIGNATION_MASTER DM WITH (NOLOCK) On EM.Desig_Id=DM.Desig_ID And EM.Cmp_ID=DM.Cmp_ID 
		Left Outer Join T0040_DEPARTMENT_MASTER Dept WITH (NOLOCK) On EM.Dept_ID =Dept.Dept_Id And EM.Cmp_ID=Dept.Cmp_Id 
		Left Outer Join T0040_TYPE_MASTER Type WITH (NOLOCK) On EM.Type_ID=Type.Type_ID And EM.Cmp_ID=Type.Cmp_ID 
		Left Outer Join T0001_LOCATION_MASTER LM WITH (NOLOCK) On EM.Loc_ID=LM.Loc_ID
		Left Outer Join T0040_BANK_MASTER Bank WITH (NOLOCK) On EM.Bank_ID=Bank.Bank_ID And EM.Cmp_ID=Bank.Cmp_Id 
		Left Outer Join T0040_CURRENCY_MASTER Curr WITH (NOLOCK) On EM.Curr_ID =Curr.Curr_ID And EM.Cmp_ID=Curr.Cmp_ID  
		WHERE EM.Cmp_ID = @Cmp_Id And EM.Emp_ID in (select Emp_ID From #Emp_Cons)		
	End	
		
If @Detail_Type='Emergency'
	Begin	
		Select EM1.Alpha_Emp_Code as 'Employee Code',EM1.Emp_Full_Name as 'Employee Name',
		ECDC.Name as 'Emergency Contact Name',ECDC.RelationShip,ECDC.Home_Tel_No as 'Home Tel No',ECDC.Home_Mobile_No as 'Home Mobile No',
		ECDC.Work_Tel_No as 'Work Tel No',ECDC.System_Date as 'Changed Date',IsNull(EM.Emp_Full_Name,'Admin') as 'Changed By'
		from T0090_EMP_EMERGENCY_CONTACT_DETAIL_Clone ECDC WITH (NOLOCK)
		Inner Join T0011_LOGIN LO WITH (NOLOCK) On ECDC.Login_Id=LO.Login_ID And ECDC.Cmp_ID = Lo.Cmp_ID 
		Left Outer Join T0080_EMP_MASTER EM WITH (NOLOCK) On LO.Emp_ID =EM.Emp_ID And Lo.Cmp_ID = EM.Cmp_ID 
		Left Outer Join T0080_EMP_MASTER EM1 WITH (NOLOCK) On ECDC.Emp_ID=EM1.Emp_ID And ECDC.Cmp_ID=EM1.Cmp_ID 	
		WHERE ECDC.Cmp_ID = @Cmp_Id	-- ADDED BY RAJPUT ON 08022019 MANTIS-BAG-ID(0007523)	
	End	
	
If @Detail_Type='Nominee'
	Begin	
		Select EM1.Alpha_Emp_Code as 'Employee Code',EM1.Emp_Full_Name as 'Employee Name',EDDC.Name as 'Nominee Name',
		EDDC.RelationShip as 'RelationShip',EDDC.BirthDate as 'Birth Date',EDDC.D_Age as 'Age', Replace(EDDC.Address,',',' ') as 'Address',
		Case when EDDC.Is_Resi=1 then 'Yes' else 'No' End as 'Residing?',		
		EDDC.Share as 'Share',EDDC.System_Date as 'Changed Date',IsNull(EM.Emp_Full_Name,'Admin') as 'Changed By' 
		from T0090_EMP_DEPENDANT_DETAIL_Clone EDDC WITH (NOLOCK)
		Inner Join T0011_LOGIN LO WITH (NOLOCK) On EDDC.Login_Id=LO.Login_ID  And EDDC.Cmp_ID = Lo.Cmp_ID 
		Left Outer Join T0080_EMP_MASTER EM WITH (NOLOCK) On LO.Emp_ID =EM.Emp_ID And LO.Cmp_ID=EM.Cmp_ID 
		Left Outer Join T0080_EMP_MASTER EM1 WITH (NOLOCK) On EDDC.Emp_ID=EM1.Emp_ID And EDDC.Cmp_ID=EM1.Cmp_ID 
		WHERE EDDC.Cmp_ID = @Cmp_Id And EDDC.Emp_ID in (select Emp_ID From #Emp_Cons)		
	End	

If @Detail_Type='Family Members'
	Begin	
		Select EM1.Alpha_Emp_Code as 'Employee Code',EM1.Emp_Full_Name as 'Employee Name',ECDC.Name as 'Family Member Name',
		case when ECDC.Gender='M'then 'Male' else 'Female' End  as 'Gender',ECDC.Date_Of_Birth as 'Birth Date',
		ECDC.C_Age as 'Age',ECDC.Relationship as 'Relationship',case when ECDC.Is_Resi=1 then 'Yes' else 'No' End as 'Residing?',
		case when ECDC.Is_Dependant =1 then 'Yes' else 'No' End as 'Dependent?',ECDC.System_Date as 'Changed Date',
		IsNull(EM.Emp_Full_Name,'Admin') as 'Changed By' 
		from T0090_EMP_CHILDRAN_DETAIL_Clone ECDC WITH (NOLOCK)
		Inner Join T0011_LOGIN LO WITH (NOLOCK) On ECDC.Login_Id=LO.Login_ID  And ECDC.Cmp_ID = Lo.Cmp_ID 
		Left Outer Join T0080_EMP_MASTER EM WITH (NOLOCK) On LO.Emp_ID =EM.Emp_ID And LO.Cmp_ID=EM.Cmp_ID 
		Left Outer Join T0080_EMP_MASTER EM1 WITH (NOLOCK) On ECDC.Emp_ID=EM1.Emp_ID And ECDC.Cmp_ID=EM1.Cmp_ID 
		WHERE ECDC.Cmp_ID = @Cmp_Id And ECDC.Emp_ID in (select Emp_ID From #Emp_Cons)
	End	
	
If @Detail_Type='Immigration'
	Begin	
		Select EM1.Alpha_Emp_Code as 'Employee Code',EM1.Emp_Full_Name as 'Employee Name',EIDC.Imm_Type as 'Type',
		EIDC.Imm_No as 'Number',EIDC.Imm_Issue_Date as 'Issue Date',EIDC.Imm_Issue_Status as 'Issue Status',
		EIDC.Imm_Date_of_Expiry as 'Expiry Date',EIDC.Imm_Review_Date as 'Review Date',Replace(EIDC.Imm_Comments,',',' ') as 'Comment',
		EIDC.System_Date as 'Changed Date',
		IsNull(EM.Emp_Full_Name,'Admin') as 'Changed By'
		from T0090_EMP_IMMIGRATION_DETAIL_Clone EIDC WITH (NOLOCK)
		Inner Join T0011_LOGIN LO WITH (NOLOCK) On EIDC.Login_Id=LO.Login_ID  And EIDC.Cmp_ID = Lo.Cmp_ID 
		Left Outer Join T0080_EMP_MASTER EM WITH (NOLOCK) On LO.Emp_ID =EM.Emp_ID And LO.Cmp_ID=EM.Cmp_ID 
		Left Outer Join T0080_EMP_MASTER EM1 WITH (NOLOCK) On EIDC.Emp_ID=EM1.Emp_ID And EIDC.Cmp_ID=EM1.Cmp_ID 
		WHERE EIDC.Cmp_ID = @Cmp_Id And EIDC.Emp_ID in (select Emp_ID From #Emp_Cons)		
	End			
	
If @Detail_Type='Asset'
	Begin	
		Select EM1.Alpha_Emp_Code as 'Employee Code',EM1.Emp_Full_Name as 'Employee Name',EADC.Model_No as 'Model Number',
		EADC.Issue_Date as 'Issue Date' ,EADC.Return_Date as 'Return Date',EADC.Asset_Comment as 'Comment',
		EADC.System_Date as 'Changed Date',IsNull(EM.Emp_Full_Name,'Admin') as 'Changed By'
		from T0090_EMP_ASSET_DETAIL_Clone EADC WITH (NOLOCK)
		Inner Join T0011_LOGIN LO WITH (NOLOCK) On EADC.Login_Id=LO.Login_ID  And EADC.Cmp_ID = Lo.Cmp_ID 
		Left Outer Join T0080_EMP_MASTER EM WITH (NOLOCK) On LO.Emp_ID =EM.Emp_ID And LO.Cmp_ID=EM.Cmp_ID 
		Left Outer Join T0080_EMP_MASTER EM1 WITH (NOLOCK) On EADC.Emp_ID=EM1.Emp_ID And EADC.Cmp_ID=EM1.Cmp_ID 
		WHERE EADC.Cmp_ID = @Cmp_Id And EADC.Emp_ID in (select Emp_ID From #Emp_Cons)		
	End			
	
If @Detail_Type='Reporting'
	Begin	
		Select EM1.Alpha_Emp_Code as 'Employee Code',EM1.Emp_Full_Name as 'Employee Name',EM.Emp_Full_Name as 'Reporting Manager',
		ERDC.Reporting_To as 'Reporting To',ERDC.Reporting_Method as 'Reporting Method',
		ERDC.System_Date as 'Changed Date',IsNull(EM.Emp_Full_Name,'Admin') as 'Changed By'
		from T0090_EMP_REPORTING_DETAIL_Clone ERDC WITH (NOLOCK)
		Inner Join T0011_LOGIN LO WITH (NOLOCK) On ERDC.Login_Id=LO.Login_ID And ERDC.Cmp_ID=LO.Cmp_ID 
		Left Outer Join T0080_EMP_MASTER EM WITH (NOLOCK) On LO.Emp_ID =EM.Emp_ID And LO.Cmp_ID =EM.Cmp_ID 
		Left Outer Join T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) On EM.Emp_ID=ERD.R_Emp_ID  And EM.Cmp_ID=ERD.Cmp_ID 
		Left Outer Join T0080_EMP_MASTER EM1 WITH (NOLOCK) On ERDC.Emp_ID=EM1.Emp_ID And ERDC.Cmp_ID=EM1.Cmp_ID 
		WHERE ERDC.Cmp_ID = @Cmp_Id And ERDC.Emp_ID in (select Emp_ID From #Emp_Cons)		
	End	
	
If @Detail_Type='Contract'
	Begin	
		Select EM1.Alpha_Emp_Code as 'Employee Code',EM1.Emp_Full_Name as 'Employee Name',PM.Prj_name as  'Project Name',
		ECDC.Start_Date as 'Start Date',ECDC.End_Date as 'End Date',
		Case when ECDC.Is_Renew=1 then 'Yes' else 'No' End as 'Renew?',
		Case when ECDC.Is_Reminder=1 then 'Yes' else 'No' End as 'Reminder?',ECDC.Comments as 'Comment', 
		ECDC.System_Date as 'Changed Date',IsNull(EM.Emp_Full_Name,'Admin') as Changed_by 
		from T0090_EMP_CONTRACT_DETAIL_Clone ECDC WITH (NOLOCK)
		Inner Join T0011_LOGIN LO WITH (NOLOCK) On ECDC.Login_Id=LO.Login_ID  And ECDC.Cmp_ID = Lo.Cmp_ID 
		Left Outer Join T0080_EMP_MASTER EM WITH (NOLOCK) On LO.Emp_ID =EM.Emp_ID And LO.Cmp_ID=EM.Cmp_ID 
		Left Outer Join T0080_EMP_MASTER EM1 WITH (NOLOCK) On ECDC.Emp_ID=EM1.Emp_ID And ECDC.Cmp_ID=EM1.Cmp_ID
		Left Outer Join T0040_PROJECT_MASTER as PM WITH (NOLOCK) On ECDC.Prj_ID=PM.Prj_ID and ECDC.Cmp_ID=PM.Cmp_ID 
		WHERE ECDC.Cmp_ID = @Cmp_Id And ECDC.Emp_ID in (select Emp_ID From #Emp_Cons)		
	End		
	
If @Detail_Type='Experience'
	Begin	
		Select EM1.Alpha_Emp_Code as 'Employee Code',EM1.Emp_Full_Name as 'Employee Name',EEDC.Employer_Name as 'Employer Name',
		EEDC.Desig_Name as 'Designation',EEDC.St_Date as 'Start Date',EEDC.End_Date as 'End Date',
		EEDC.System_Date as 'Changed Date',IsNull(EM.Emp_Full_Name,'Admin') as 'Changed By' 
		from T0090_EMP_EXPERIENCE_DETAIL_Clone EEDC WITH (NOLOCK)
		Inner Join T0011_LOGIN LO WITH (NOLOCK) On EEDC.Login_Id=LO.Login_ID  And EEDC.Cmp_ID = Lo.Cmp_ID 
		Left Outer Join T0080_EMP_MASTER EM WITH (NOLOCK) On LO.Emp_ID =EM.Emp_ID And LO.Cmp_ID=EM.Cmp_ID 
		Left Outer Join T0080_EMP_MASTER EM1 WITH (NOLOCK) On EEDC.Emp_ID=EM1.Emp_ID And EEDC.Cmp_ID=EM1.Cmp_ID
		WHERE EEDC.Cmp_ID = @Cmp_Id And EEDC.Emp_ID in (select Emp_ID From #Emp_Cons)		
	End	
	
If @Detail_Type='Qualification'
	Begin	
		Select EM1.Alpha_Emp_Code as 'Employee Code',EM1.Emp_Full_Name as 'Employee Name',QM.Qual_Name as 'Qualification', 
		EQDC.Specialization as 'Specialization',EQDC.Year as 'Year',EQDC.Score as 'Socre',
		EQDC.St_Date as 'Start Date',EQDC.End_Date as 'End Date',Replace(EQDC.Comments ,',',' ') as 'Comment',
		EQDC.System_Date as 'Changed Date',IsNull(EM.Emp_Full_Name,'Admin') as 'Changed By'
		from T0090_EMP_QUALIFICATION_DETAIL_Clone EQDC WITH (NOLOCK)
		Inner Join T0011_LOGIN LO WITH (NOLOCK) On EQDC.Login_Id=LO.Login_ID  And EQDC.Cmp_ID = Lo.Cmp_ID 
		Left Outer Join T0080_EMP_MASTER EM WITH (NOLOCK) On LO.Emp_ID =EM.Emp_ID And LO.Cmp_ID=EM.Cmp_ID
		Left Outer Join T0080_EMP_MASTER EM1 WITH (NOLOCK) On EQDC.Emp_ID=EM1.Emp_ID And EQDC.Cmp_ID=EM1.Cmp_ID
		Left Outer Join T0040_QUALIFICATION_MASTER QM WITH (NOLOCK) On EQDC.Qual_ID=QM.Qual_ID And EQDC.Cmp_ID=QM.Cmp_ID  
		WHERE EQDC.Cmp_ID = @Cmp_Id And EQDC.Emp_ID in (select Emp_ID From #Emp_Cons)		
	End		
	
If @Detail_Type='Skills'
	Begin	
		Select EM1.Alpha_Emp_Code as 'Employee Code',EM1.Emp_Full_Name as 'Employee Name',SM.Skill_Name as 'Skill',
		ESDC.Skill_Comments as 'Comment',ESDC.Skill_Experience as 'Experience',
		ESDC.System_Date as 'Changed Date',IsNull(EM.Emp_Full_Name,'Admin') as 'Changed By'
		from T0090_EMP_SKILL_DETAIL_Clone ESDC WITH (NOLOCK)
		Inner Join T0011_LOGIN LO WITH (NOLOCK) On ESDC.Login_Id=LO.Login_ID  And ESDC.Cmp_ID = Lo.Cmp_ID 
		Left Outer Join T0080_EMP_MASTER EM WITH (NOLOCK) On LO.Emp_ID =EM.Emp_ID And LO.Cmp_ID=EM.Cmp_ID 
		Left Outer Join T0080_EMP_MASTER EM1 WITH (NOLOCK) On ESDC.Emp_ID=EM1.Emp_ID And ESDC.Cmp_ID=EM1.Cmp_ID
		Left Outer Join T0040_SKILL_MASTER SM WITH (NOLOCK) On ESDC.Skill_ID=SM.Skill_ID And ESDC.Cmp_ID=SM.Cmp_ID  
		WHERE ESDC.Cmp_ID = @Cmp_Id And ESDC.Emp_ID in (select Emp_ID From #Emp_Cons)
	End			
				
If @Detail_Type='Insurance'
	Begin	
		Select EM1.Alpha_Emp_Code as 'Employee Code',EM1.Emp_Full_Name as 'Employee Name',IM.Ins_Name as 'Name',
		EIDC.Ins_Cmp_name as 'Company Name',EIDC.Ins_Policy_No as 'Policy Number',EIDC.Ins_Taken_Date as 'Registration Date',
		EIDC.Ins_Due_Date as 'Due Date' ,EIDC.Ins_Exp_Date as 'Expiry Date',EIDC.Ins_Amount as 'Aomunt',EIDC.Ins_Anual_Amt as 'Annual Amount',  
		EIDC.System_Date as 'Changed Date',IsNull(EM.Emp_Full_Name,'Admin') as 'Changed By'
		from T0090_EMP_INSURANCE_DETAIL_Clone EIDC WITH (NOLOCK)
		Inner Join T0011_LOGIN LO WITH (NOLOCK) On EIDC.Login_Id=LO.Login_ID  And EIDC.Cmp_ID = Lo.Cmp_ID 
		Left Outer Join T0080_EMP_MASTER EM WITH (NOLOCK) On LO.Emp_ID =EM.Emp_ID And LO.Cmp_ID=EM.Cmp_ID 
		Left Outer Join T0080_EMP_MASTER EM1 WITH (NOLOCK) On EIDC.Emp_ID=EM1.Emp_ID And EIDC.Cmp_ID=EM1.Cmp_ID
		Left Outer Join T0040_INSURANCE_MASTER IM WITH (NOLOCK) On EIDC.Ins_Tran_ID =IM.Ins_Tran_ID And EIDC.Cmp_ID=IM.Cmp_ID   
		WHERE EIDC.Cmp_ID = @Cmp_Id And EIDC.Emp_ID in (select Emp_ID From #Emp_Cons) 		
	End	

RETURN


