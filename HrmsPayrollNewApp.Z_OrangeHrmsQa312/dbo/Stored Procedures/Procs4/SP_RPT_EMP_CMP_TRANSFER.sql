




-- =============================================
-- Author:		<ANKIT>
-- Create date: <25032014>
-- Description:	<Description,,>
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_EMP_CMP_TRANSFER]
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
	,@Constraint	varchar(max) = ''
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	If @Branch_ID = 0
		Set @Branch_ID = null
	If @Cat_ID = 0
		Set @Cat_ID = null
	If @Type_ID = 0
		Set @Type_ID = null
	If @Dept_ID = 0
		Set @Dept_ID = null
	If @Grd_ID = 0
		Set @Grd_ID = null
	If @Emp_ID = 0
		Set @Emp_ID = null
	If @Desig_ID = 0
		Set @Desig_ID = null
		
	
	Create Table #Emp_Cons 
		 (      
		   Emp_ID numeric ,     
		   Branch_ID numeric,
		   Increment_ID numeric    
		 )      
 

	if @Constraint <> ''
		begin
			Insert Into #Emp_Cons
			Select cast(data  as numeric),cast(data  as numeric),cast(data  as numeric) From dbo.Split(@Constraint,'#') 
		end
	else 
		begin
			Insert Into #Emp_Cons      
		      select distinct emp_id,branch_id,Increment_ID from V_Emp_Cons where 
		      cmp_id=@Cmp_ID 
		       and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
		   and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
		   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
		   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
		   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
		   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
		   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
		      and Increment_Effective_Date <= @To_Date 
		      and 
                      ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
						or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
						or (Left_date is null and @To_Date >= Join_Date)      
						or (@To_Date >= left_date  and  @From_Date <= left_date )) 
						order by Emp_ID
						
			delete  from #emp_cons where Increment_ID not in (select max(Increment_ID) from T0095_Increment WITH (NOLOCK)
				where  Increment_effective_Date <= @to_date
				group by emp_ID)
		end
	
		Select  OECL.Old_Emp_Id, CM.Cmp_Id as Old_Cmp_Id,CM.Cmp_Name as Old_Cmp_Name,Cm.Cmp_Address,CM.Cmp_City,Cm.Cmp_State_Name,Cm.Cmp_PinCode, 
				CM_1.Cmp_Id AS New_Cmp_Id ,CM_1.Cmp_Name AS New_cmp_name,	
				Effective_Date ,OEM.Alpha_Emp_Code ,OEM.Emp_Full_Name,OEM.Date_Of_Join,OEM.Gender,@From_Date as From_Date ,@To_Date as To_Date,
				ODM.Dept_Name as Old_Dept_Name,ODGM.Desig_Name as Old_Desig_Name,OETM.Type_Name as Old_Type_Name,OGM.Grd_Name as Old_Grd_Name,OBM.Branch_Name as Old_Branch_Name,OCTM.Cat_Name as Old_Cat_Name,
				(Select Alpha_Emp_Code + '-' + SUP.Emp_Full_Name from dbo.T0080_EMP_MASTER SUP WITH (NOLOCK) where SUP.Emp_ID = OEM.Emp_Superior) as Old_manager,OECL.Old_Emp_WeekOff_Day,PM.Privilege_Name as Old_Privilege_Name,SM.Shift_Name as Old_Shift_Name
				,BS.Segment_Name As Old_Business_Segment ,VS.Vertical_Name As Old_Vertical_Name,SV.SubVertical_Name As Old_SubVertical_Name,SB.SubBranch_Name As Old_SubBranch_Name,OECL.Old_Login_Alias,SCM.Name As OldSalCycle
				,SD.Old_Basic_Salary,sd.Old_Gross_Salary,SD.Old_CTC
			    
			    ,OECL.New_Emp_Id,OECL.New_Cmp_Id,NGM.Grd_Name as New_Grd_Name,NETM.Type_Name as New_Type_Name,NDGM.Desig_Name as New_Desig_Name,NDM.Dept_Name as New_Dept_Name,NBM.Branch_Name as New_Branch_Name,
				 NCTM.Cat_Name as New_Cat_Name,
				(Select Alpha_Emp_Code + '-' + SUP.Emp_Full_Name from dbo.T0080_EMP_MASTER SUP WITH (NOLOCK) where SUP.Emp_ID = OECL.New_Emp_mngr_Id) as New_manager
				,CASE WHEN OECL.New_Emp_WeekOff_Day = '--Select--' THEN '' ELSE OECL.New_Emp_WeekOff_Day END AS New_Emp_WeekOff_Day
 				,NPM.Privilege_Name as New_Privilege_Name,NSM.Shift_Name as New_Shift_Name
			    ,NBS.Segment_Name As New_Business_Segment ,NVS.Vertical_Name As New_Vertical_Name,NSV.SubVertical_Name As New_SubVertical_Name,NSB.SubBranch_Name As New_SubBranch_Name,OECL.New_Login_Alias,NSCM.Name As NewSalCycle
			    ,SD.New_Basic_Salary,SD.New_Gross_Salary,SD.New_CTC
			  	,OEM.Emp_First_Name  --added jimit 29052015
			  	,OECL.Old_Branch_Id
			  	,OEM.Emp_code  --add by chetan 030417
			  	,ERD_OLD.R_EMp_ID
			  	,ERD_New.R_EMp_ID
		From	dbo.T0095_EMP_COMPANY_TRANSFER OECL WITH (NOLOCK) Inner Join 
				dbo.T0080_EMP_MASTER OEM WITH (NOLOCK) ON OECL.Old_Emp_Id = OEM.Emp_ID Inner Join 
				dbo.T0040_GRADE_MASTER OGM WITH (NOLOCK) ON OECL.Old_Grd_Id = OGM.Grd_ID LEFT OUTER JOIN
				dbo.T0040_GRADE_MASTER NGM WITH (NOLOCK) ON OECL.New_Grd_Id = NGM.Grd_ID LEFT OUTER JOIN
				dbo.T0040_TYPE_MASTER OETM WITH (NOLOCK) ON OECL.Old_Type_ID = OETM.Type_ID LEFT OUTER JOIN
				dbo.T0040_TYPE_MASTER NETM WITH (NOLOCK) ON OECL.New_Type_ID = NETM.Type_ID LEFT OUTER JOIN
				dbo.T0040_DESIGNATION_MASTER ODGM WITH (NOLOCK) ON OECL.Old_Desig_Id = ODGM.Desig_Id LEFT OUTER JOIN
				dbo.T0040_DESIGNATION_MASTER NDGM WITH (NOLOCK) ON OECL.New_Desig_Id = NDGM.Desig_Id LEFT OUTER JOIN
				dbo.T0040_DEPARTMENT_MASTER ODM WITH (NOLOCK) ON OECL.Old_Dept_Id = ODM.Dept_Id LEFT OUTER JOIN
				dbo.T0040_DEPARTMENT_MASTER NDM WITH (NOLOCK) ON OECL.New_Dept_Id = NDM.Dept_Id LEFT OUTER JOIN
				dbo.T0030_BRANCH_MASTER OBM WITH (NOLOCK) ON OECL.Old_BRANCH_ID = OBM.BRANCH_ID  Inner join 
				dbo.T0030_BRANCH_MASTER NBM WITH (NOLOCK) ON OECL.New_BRANCH_ID = NBM.BRANCH_ID  Left Outer Join
				dbo.T0030_Category_Master OCTM WITH (NOLOCK) ON OECL.Old_Cat_Id = OCTM.Cat_ID LEFT OUTER JOIN 
				dbo.T0030_Category_Master NCTM WITH (NOLOCK) ON OECL.New_Cat_Id = NCTM.Cat_ID LEFT OUTER JOIN 
				dbo.T0010_COMPANY_MASTER CM WITH (NOLOCK) ON OECL.Old_Cmp_Id = CM.CMP_ID Inner Join
				dbo.T0010_COMPANY_MASTER CM_1 WITH (NOLOCK) ON OECL.New_Cmp_Id = CM_1.CMP_ID LEFT OUTER Join
				dbo.T0020_PRIVILEGE_MASTER PM WITH (NOLOCK) ON OECL.Old_Privilege_ID = PM.Privilege_ID LEFT OUTER JOIN
				dbo.T0020_PRIVILEGE_MASTER NPM WITH (NOLOCK) ON OECL.New_Privilege_ID = NPM.Privilege_ID LEFT OUTER JOIN
				dbo.T0040_SHIFT_MASTER SM WITH (NOLOCK) ON OECL.Old_Shift_Id = SM.Shift_ID LEFT OUTER JOIN
				dbo.T0040_SHIFT_MASTER NSM WITH (NOLOCK) ON OECL.New_Shift_Id = NSM.Shift_ID LEFT OUTER JOIN
				dbo.T0040_Business_Segment BS WITH (NOLOCK) ON OECL.Old_Segment_ID = BS.Segment_ID LEFT OUTER JOIN
				dbo.T0040_Business_Segment NBS WITH (NOLOCK) ON OECL.New_Segment_ID = NBS.Segment_ID LEFT OUTER JOIN
				dbo.T0040_Vertical_Segment VS WITH (NOLOCK) ON OECL.Old_Client_Id = VS.Vertical_ID LEFT OUTER JOIN
				dbo.T0040_Vertical_Segment NVS WITH (NOLOCK) ON OECL.New_Client_Id = NVS.Vertical_ID LEFT OUTER JOIN
				dbo.T0050_SubVertical SV WITH (NOLOCK) ON OECL.Old_SubVertical_ID = sv.SubVertical_ID LEFT OUTER JOIN
				dbo.T0050_SubVertical NSV WITH (NOLOCK) ON OECL.New_SubVertical_ID = NSV.SubVertical_ID LEFT OUTER JOIN
				dbo.T0050_SubBranch SB WITH (NOLOCK) ON OECL.Old_SubBranch_ID = SB.SubBranch_ID LEFT OUTER JOIN
				dbo.T0050_SubBranch NSB WITH (NOLOCK) ON OECL.New_SubBranch_ID = NSB.SubBranch_ID LEFT OUTER JOIN
				dbo.T0040_Salary_Cycle_Master SCM WITH (NOLOCK) ON OECL.Old_SalCycle_Id = SCM.Tran_Id LEFT OUTER JOIN
				dbo.T0040_Salary_Cycle_Master NSCM WITH (NOLOCK) ON OECL.New_SalCycle_ID = NSCM.Tran_Id LEFT OUTER JOIN
				
				dbo.T0100_EMP_COMPANY_TRANSFER_SALARY_DETAIL SD WITH (NOLOCK) on OECL.Old_Emp_Id = SD.Old_Emp_Id Inner Join
				#Emp_Cons EC on OECL.Old_Emp_Id = EC.Emp_ID left outer join 
				T0090_EMP_REPORTING_DETAIL ERD_OLD WITH (NOLOCK) on OECL.Old_Emp_Id = ERD_OLD.Emp_Id left outer join
				T0090_EMP_REPORTING_DETAIL ERD_New WITH (NOLOCK) on OECL.New_Emp_Id = ERD_New.Emp_id
				
		WHERE OECL.Old_Cmp_Id = @Cmp_Id	
		ORDER BY RIGHT(REPLICATE(N' ', 500) + OEM.ALPHA_EMP_CODE, 500) 
		
	RETURN




