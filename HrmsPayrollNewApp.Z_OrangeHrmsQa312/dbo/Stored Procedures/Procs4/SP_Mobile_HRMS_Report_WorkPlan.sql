--select * from T0130_EMP_WORKPLAN
-- exec SP_Mobile_HRMS_Report_WorkPlan 119,'2020-01-02','2020-09-04',473,'','','','','',0,''
-- exec SP_Mobile_HRMS_Report_WorkPlan 119,'','',473,'','','','','',0,''
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_Report_WorkPlan]
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		varchar(Max) = ''
	,@Cat_ID		varchar(Max) = ''
	,@Grd_ID		varchar(Max) = ''
	,@Type_ID		varchar(Max) = ''
	,@Dept_ID		varchar(Max) = ''
	,@Desig_ID		varchar(Max) = ''
	,@Emp_ID		numeric  = 0
	,@Constraint	nvarchar(Max) = ''
AS
Set Nocount on 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
CREATE table #Emp_Cons 
(      
	Emp_ID numeric ,     
	Branch_ID numeric,
	Increment_ID numeric    
)      
 
EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,0,0,0,0,0,0,0,'0',0,0

		SELECT E.emp_id, E.Alpha_Emp_Code , E.emp_full_name,EM1.Emp_Full_Name As Manager_Name 
		, branch_name as [Branch_Name],grd_name as [Grade_Name], desig_name as Designation, dept_name as Department
		INTO #EmpDetails 
		FROM   t0080_emp_master E WITH (NOLOCK)
				INNER JOIN  #EMP_CONS EC
						ON E.emp_id = EC.emp_id 
				INNER JOIN t0095_increment I  WITH (NOLOCK)
						ON EC.Increment_ID = I.Increment_ID
				LEFT OUTER JOIN t0040_grade_master GM WITH (NOLOCK)
						ON I.grd_id = gm.grd_id  
				LEFT OUTER JOIN t0030_branch_master BM WITH (NOLOCK)
						ON I.branch_id = BM.branch_id 
				LEFT OUTER JOIN t0040_department_master DM WITH (NOLOCK)
				        ON I.dept_id = DM.dept_id 
				LEFT OUTER JOIN t0040_designation_master DGM WITH (NOLOCK)
					    ON I.desig_id = DGM.desig_id 
				LEFT OUTER JOIN dbo.fn_getReportingManager(@Cmp_Id,0,@To_Date) Manager On EC.Emp_ID = Manager.Emp_ID
				LEFT OUTER JOIN T0080_EMP_MASTER EM1 WITH (NOLOCK) ON Manager.R_Emp_ID = EM1.Emp_ID

				SELECT EC.Emp_ID,Alpha_Emp_Code , emp_full_name, Manager_Name 
					   ,Branch_Name,Grade_Name, Designation, Department
					   ,Work_InTime,Work_OutTime, Work_Plan, Visit_Plan, Work_Summary, Visit_Summary
				FROM #EmpDetails EC
					INNER JOIN T0130_EMP_WORKPLAN WP WITH (NOLOCK)
						ON EC.Emp_ID = WP.Emp_ID
				WHERE Cmp_ID = @Cmp_ID and (cast(For_Date as Date) between @From_Date and @To_Date)
RETURN			
	


