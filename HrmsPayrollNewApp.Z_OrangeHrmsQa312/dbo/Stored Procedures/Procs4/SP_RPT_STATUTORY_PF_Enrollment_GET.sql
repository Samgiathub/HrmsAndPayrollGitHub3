
CREATE PROCEDURE [dbo].[SP_RPT_STATUTORY_PF_Enrollment_GET]
 @Cmp_ID 	numeric
,@From_Date 	datetime
,@To_Date 	datetime
,@Branch_ID 	numeric
,@Cat_ID 	numeric 
,@Grd_ID 	numeric
,@Type_ID 	numeric
,@Dept_ID 	numeric
,@Desig_ID 	numeric
,@Emp_ID 	numeric
,@constraint 	varchar(MAX)

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
--Created by ronakk 03022022	
	Declare @PF_DEF_ID		numeric 
	set @PF_DEF_ID =2
		
	
	
	IF @Branch_ID = 0  
		set @Branch_ID = null
		
	IF @Cat_ID = 0  
		set @Cat_ID = null

	IF @Grd_ID = 0  
		set @Grd_ID = null

	IF @Type_ID = 0  
		set @Type_ID = null

	IF @Dept_ID = 0  
		set @Dept_ID = null

	IF @Desig_ID = 0  
		set @Desig_ID = null

	IF @Emp_ID = 0  
		set @Emp_ID = null

	Declare @Emp_Cons Table
	(
		Emp_ID	numeric
	)
	
	if @Constraint <> ''
		begin
			Insert Into @Emp_Cons
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
		end
	else
		begin
			
			
					Insert Into @Emp_Cons
					select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join T0080_Emp_master e WITH (NOLOCK) on I.Emp_ID = E.Emp_ID inner join 
							( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = @Cmp_ID
							group by emp_ID  ) Qry on
							I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	
									
					Where I.Cmp_ID = @Cmp_ID 
					and Isnull(I.Cat_ID,0) = Isnull(@Cat_ID ,Isnull(I.Cat_ID,0))
					and I.Branch_ID = isnull(@Branch_ID ,I.Branch_ID)
					and I.Grd_ID = isnull(@Grd_ID ,I.Grd_ID)
					and isnull(I.Dept_ID,0) = isnull(@Dept_ID ,isnull(I.Dept_ID,0))
					and Isnull(I.Type_ID,0) = isnull(@Type_ID ,Isnull(I.Type_ID,0))
					and Isnull(I.Desig_ID,0) = isnull(@Desig_ID ,Isnull(I.Desig_ID,0))
					and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
					and Date_of_Join >=@From_Date and Date_of_Join <=@To_Date

		end
		
		declare @count as numeric
		
		Select @count = COUNT(*) From T0080_Emp_Master e WITH (NOLOCK)
		left outer join @Emp_Cons ec on e.emp_ID = ec.emp_ID 
		left outer join T0090_Emp_Experience_Detail EED WITH (NOLOCK) on e.Emp_ID=EED.Emp_ID
		left outer join	 (select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Inc_Bank_Ac_no from T0095_Increment I WITH (NOLOCK)
							inner join ( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)	-- Ankit 09092014 for Same Date Increment
										where Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID group by emp_ID  )
										Qry on I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 )
										I_Q  on E.Emp_ID = I_Q.Emp_ID
		inner join T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID
		LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
		LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id
		LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
		INNER JOIN  T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  
		Inner join T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID 
		Inner join (Select min(for_date) as for_date,emp_id from t0050_ad_master AM WITH (NOLOCK)
					inner join T0100_EMP_EARN_DEDUCTION eed WITH (NOLOCK) on am.ad_id = eed.ad_id
					where ad_def_id = 2 group by emp_id) Qry on E.Emp_Id = Qry.Emp_Id
		Where Date_of_Join >= @From_Date and Date_of_Join <= @To_Date and e.Cmp_Id =@Cmp_ID and e.emp_ID = ec.emp_ID and
		(EED.End_Date in (select Max(End_Date) from T0090_Emp_Experience_Detail WITH (NOLOCK) group by Emp_ID) OR EED.End_Date is null)
		
		
		if @count > 0
			begin
					
					------------For exeter media----------Hasmukh
				--	Select	Emp_First_Name + ' ' + Emp_Last_Name as Emp_Full_Name,EED.ROw_ID,Emp_Code,Date_of_Join,Emp_Left_Date, father_Name as Emp_Second_Name ,DBO.F_GET_AGE (Date_of_Birth,getdate(),'Y','N')as Age  
					---------------------------------------------
					Select ISNULL(EmpName_Alias_PF,Emp_Full_Name) as Emp_Full_Name,EED.ROw_ID,Emp_Code,format(Date_of_Join,'dd/MM/yyyy') as Date_of_Join,
					Emp_Left_Date, Emp_Second_Name,Father_Name ,DBO.F_GET_AGE (Date_of_Birth,getdate(),'Y','N')as Age  				
							,case when (Marital_Status=1)then 'Married' else 'Unmarried' end as Marital_Status ,format(Date_OF_Birth,'dd/MM/yyyy') as Date_OF_Birth,
							e.Emp_ID ,case when (Gender='M') then 'MALE' when (Gender='F') then 'FEMALE' else '' end as Gender,SSN_No as PF_No,cm.PF_NO as Cmp_PF_No
							,Cmp_NAme,Cmp_Address,I_Q.Inc_Bank_Ac_no
							,@From_Date P_From_Date ,@To_Date P_To_Date,EED.Employer_Name,EED.Desig_Name
							,BM.Comp_Name ,BM.Branch_Address,e.Nationality,e.Mobile_No,e.Other_Email
							,E.Alpha_Emp_Code,E.Emp_First_Name,TYPE_NAME,Grd_Name,Dept_Name,
							'Aadhar' as Proof,e.Aadhar_Card_No,ISNULL(EmpName_Alias_PF,Emp_Full_Name) as Proof_Name,'FATHER' as Relation
					From T0080_Emp_Master e WITH (NOLOCK) left outer join @Emp_Cons ec on e.emp_ID = ec.emp_ID 
					  left outer join T0090_Emp_Experience_Detail EED WITH (NOLOCK) on e.Emp_ID=EED.Emp_ID left outer join		
						( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Inc_Bank_Ac_no from T0095_Increment I WITH (NOLOCK) inner join 
								( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)	-- Ankit 09092014 for Same Date Increment
								where Increment_Effective_date <= @To_Date
								and Cmp_ID = @Cmp_ID
								group by emp_ID  ) Qry on
								I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
							on E.Emp_ID = I_Q.Emp_ID  inner join
								T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
								T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
								T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
								T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
								T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  Inner join 
								T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID Inner join
								(Select min(for_date) as for_date,emp_id from t0050_ad_master AM  WITH (NOLOCK)
									inner join T0100_EMP_EARN_DEDUCTION eed WITH (NOLOCK) on am.ad_id = eed.ad_id where ad_def_id = 2 
								group by emp_id) Qry on E.Emp_Id = Qry.Emp_Id
					Where Date_of_Join >= @From_Date and Date_of_Join <= @To_Date	
							and e.Cmp_Id =@Cmp_ID and e.emp_ID = ec.emp_ID and
							(EED.End_Date in (select Max(End_Date) from T0090_Emp_Experience_Detail WITH (NOLOCK)  group by Emp_ID) OR EED.End_Date is null)
			end
		else
			begin
					Select 'Nil' as Emp_Full_Name,'' as ROw_ID,'' as Emp_Code,GETDATE() as Date_of_Join,'' as Emp_Left_Date, '' as Emp_Second_Name,'' as Father_Name ,'' as Age  				
								,'' as Marital_Status ,'' as Date_OF_Birth,'' as Emp_ID ,'' as Gender ,'' as  PF_No, cm.PF_No as  Cmp_PF_No
								,Cmp_NAme,Cmp_Address,'' as Inc_Bank_Ac_no
								,@From_Date P_From_Date ,@To_Date P_To_Date,'' as Employer_Name,'' as Desig_Name
								,'' as Comp_Name ,'' as Branch_Address 
								,'' as Alpha_Emp_Code,'' As Emp_First_Name, '' As [TYPE_NAME], '' As Grd_Name, '' As Dept_Name ,
								'' as Relation,'' as Mobile_No,'' as Other_Email,'' as Nationality, '' as Proof,
								''as adhar_Card_No,'' as Proof_Name
						From  T0010_COMPANY_MASTER CM WITH (NOLOCK)
						Where cm.Cmp_Id =@Cmp_ID 
							
			end	
RETURN




