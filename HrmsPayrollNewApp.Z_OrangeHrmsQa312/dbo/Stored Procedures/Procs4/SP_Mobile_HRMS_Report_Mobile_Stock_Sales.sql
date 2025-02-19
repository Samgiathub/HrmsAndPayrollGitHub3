-- exec SP_Mobile_HRMS_Report_Mobile_Stock_Sales 119,'2020-09-28','2020-09-28','','','','','','',0,''
--exec SP_Mobile_HRMS_Report_Mobile_Stock_Sales @Cmp_ID=119,@From_Date='2020-09-01 00:00:00',@To_Date='2020-09-30 00:00:00',@Branch_ID='',@Cat_ID='',@Grd_ID='',@Type_ID='',@Dept_ID='',@Desig_ID='',@Emp_ID=0,@Constraint='24065'	
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_Report_Mobile_Stock_Sales]
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
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
CREATE table #Emp_Cons 
(      
	Emp_ID numeric,     
	Branch_ID numeric,
	Increment_ID numeric 
)      

DECLARE  @vertCap   VARCHAR(80) = ''
DECLARE @subVertCap  VARCHAR(80) = ''
 
		EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,0,0,0,0,0,0,0,'0',0,0

		SELECT E.emp_id, E.Alpha_Emp_Code , E.emp_full_name, desig_name as Designation
				into #EmpDetails 
				FROM   t0080_emp_master E WITH (NOLOCK)
					INNER JOIN  #EMP_CONS EC
							ON E.emp_id = EC.emp_id 
					INNER JOIN t0095_increment I  WITH (NOLOCK)
							ON EC.Increment_ID = I.Increment_ID
					LEFT OUTER JOIN t0040_designation_master DGM WITH (NOLOCK)
						    ON I.desig_id = DGM.desig_id 
						
	 
		SELECT S.Emp_ID,S.Store_ID,EM1.Emp_Full_Name As Manager_Name ,t.Mobile_Cat_Name AS CompanyName 
		,C.Mobile_Cat_Name 
		,Mobile_Cat_Sale ,Mobile_Cat_Stock ,R.Remark_Name,For_Date 
		INTO #EmpMobileStockDetails
		FROM T0130_EMP_MOBILE_STOCK_SALES S  WITH (NOLOCK)
			Left  JOIN T0040_MOBILE_CATEGORY C WITH (NOLOCK) ON S.Mobile_Cat_ID =C.Mobile_Cat_ID
			Left JOIN (
								SELECT 	Mobile_Cat_ID , Mobile_Cat_Name 
								FROM  T0040_MOBILE_CATEGORY  WITH (NOLOCK)
								WHERE ParentCategory_ID = 0
						) t ON s.ParentID = t.Mobile_Cat_ID 
			LEFT JOIN T0040_MOBILE_STOCK_SALES_REMARK R WITH (NOLOCK) ON S.Mobile_Remark_ID = R.Mobile_Remark_ID
			Left JOIN T0040_EMP_MOBILE_STORE_ASSIGN_NEW N With (Nolock) ON S.Store_ID = N.Store_ID and N.Emp_ID =S.Emp_ID
			LEFT OUTER JOIN dbo.fn_getReportingManager(@Cmp_Id,0,@To_Date) Manager On N.Emp_ID = Manager.Emp_ID
			LEFT OUTER JOIN T0080_EMP_MASTER EM1 WITH (NOLOCK) ON Manager.R_Emp_ID = EM1.Emp_ID
			where S.Cmp_ID = @Cmp_ID and (cast(For_Date as Date) between @From_Date and @To_Date)
--ls

		SELECT ED.emp_id, Alpha_Emp_Code , emp_full_name,Manager_Name, Designation,Current_Outlet_Mapping,Store_Code
		,Dealer_Code,KRO_Type
		,RDS_Name,ASM_Name,ZSM_Name,For_Date,CompanyName  as [Mobile_Company_Name]
		, Mobile_Cat_Name as [Mobile_Category_Name],Mobile_Cat_Sale as [Mobile_Category_Sale]
		,Mobile_Cat_Stock as [Mobile_Category_Stock],Remark_Name 
		FROM #EmpDetails ED 
		INNER JOIN #EmpMobileStockDetails EM ON ED.Emp_ID = EM.Emp_ID
		INNER join T0040_MOBILE_STORE_MASTER_New m on  m.Store_ID = EM.Store_ID
	
	Drop Table #EmpDetails
	Drop Table #EmpMobileStockDetails
RETURN			
