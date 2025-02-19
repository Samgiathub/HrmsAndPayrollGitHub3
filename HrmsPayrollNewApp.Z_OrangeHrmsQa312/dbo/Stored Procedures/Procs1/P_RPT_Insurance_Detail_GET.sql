


-- Created by rohit For Insurance report on 01-may-2013
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_RPT_Insurance_Detail_GET]
	 @Cmp_ID		Numeric
	,@From_Date		Datetime
	,@To_Date		Datetime
	,@Branch_ID		Numeric 
	,@Cat_ID		Numeric
	,@Grd_ID		Numeric
	,@Type_ID		Numeric 
	,@Dept_Id		Numeric
	,@Desig_Id		Numeric
	,@Emp_ID		Numeric
	,@Constraint	varchar(max)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

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

			select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment  WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id	
							
			Where Cmp_ID = @Cmp_ID 
			and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
			and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			and I.Emp_ID in 
				( select Emp_Id from
				(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
				where cmp_ID = @Cmp_ID   and  
				(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
				or ( @To_Date  >= join_Date  and @To_Date <= left_date )
				or Left_date is null and @To_Date >= Join_Date)
				or @To_Date >= left_date  and  @From_Date <= left_date ) 
		end
		
	     Select EID.*
	     ,IM.Ins_Name,im.Ins_Desc
	     ,e.Emp_Full_name,e.Emp_Code,e.Alpha_Emp_Code,e.Emp_First_Name,GM.Grd_Name,Branch_Name
		 ,Dept_Name,Desig_Name,type_Name,Cmp_Name,Cmp_Address ,comp_name,Branch_address,@From_Date as From_Date,@To_Date as To_Date, BM.Branch_ID
		 ,CS.Alias as Report_name
		 ,ISNULL(CASE WHEN LEFT(EID.Emp_Dependent_ID,1) = '0' THEN 'Self' END + ',','') +
	         ( SELECT STUFF((SELECT		', ' + char(10) + B.Name +'-'+ Relationship 
								FROM		T0090_EMP_CHILDRAN_DETAIL B WITH (NOLOCK) INNER JOIN 
								( SELECT	CAST(DATA AS NUMERIC(18,0)) AS Row_ID FROM	dbo.Split(left(EID.Emp_dependent_Id,len(EID.Emp_dependent_Id) - 1), '#') --Where	IsNull(data, '0') <> '0'
								) MB ON B.Row_ID= MB.Row_ID 
								WHERE		B.Cmp_ID=EID.Cmp_ID AND Emp_Dependent_ID is NOT NULL 
								FOR XML PATH('')
							),1,1,'') 
			  ) As Emp_Dependent_Name_Detail --Ankit 07102015
		FROM T0090_EMP_INSURANCE_DETAIL EID WITH (NOLOCK)
         INNER JOIN T0040_INSURANCE_MASTER IM WITH (NOLOCK) ON EID.Cmp_ID=IM.Cmp_ID AND EID.Ins_Tran_ID =IM.Ins_Tran_ID
         
         inner join @Emp_cons ec on EID.Emp_ID = ec.emp_ID 
         inner join T0080_Emp_Master e WITH (NOLOCK) on EID.Emp_ID = e.emp_ID 
         inner join T0010_Company_Master CM WITH (NOLOCK) on EID.Cmp_ID= CM.CMP_ID
         inner join
					( select I.Emp_Id , Cmp_ID,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date from T0095_Increment I WITH (NOLOCK) inner join 
							( select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK)  --Changed by Hardik 10/09/2014 for Same Date Increment
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = @Cmp_ID
							group by emp_ID  ) Qry on
							I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id	 ) I_Q 
						on E.Emp_ID = I_Q.Emp_ID  inner join
							T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
							T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
							T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
							T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join 
							T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  Left Join 
							T0040_CAPTION_SETTING CS WITH (NOLOCK) on I_Q.Cmp_ID = CS.cmp_id and cs.Sortingno = 5
							
										   
		where  EID.Cmp_ID = @Cmp_ID  
			--and EID.Ins_Taken_Date >=@From_Date and 
			-- EID.Ins_Taken_Date <=@To_Date
			 Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End
		--ORDER BY RIGHT(REPLICATE(N' ', 500) + e.ALPHA_EMP_CODE, 500) 
         
         
    	RETURN 




