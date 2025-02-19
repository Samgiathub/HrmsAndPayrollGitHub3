

-- =============================================
-- Author:		Jaina
-- Create date: 30-10-2017
-- Description:	Travel GST List
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_Travel_GST]
	 @Cmp_ID		Numeric
	,@From_Date		Datetime
	,@To_Date		Datetime
	,@Branch_ID		varchar(max) =''
	,@Cat_ID		varchar(max) =''
	,@Grd_ID		varchar(max) =''
	,@Type_ID		varchar(max) ='' 
	,@Dept_Id		varchar(max) =''
	,@Desig_Id		varchar(max) =''
	,@Emp_ID		Numeric=0
	,@Constraint	varchar(MAX)=''
	,@Vertical_Id   varchar(maX)=''
	,@SubVertical_Id varchar(max)=''
	,@SubBranch_Id varchar(max)=''
	
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

   CREATE TABLE #Emp_Cons 
	(      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric    
	) 

	--IF @Constraint = '' AND @EMP_ID > 0
	--	SET @Constraint = CAST(@EMP_ID AS VARCHAR(10))
	
	EXEC dbo.SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@Constraint,0,0,0,@Vertical_Id,@SubVertical_Id,@SubBranch_Id,0,0,0,'0',0,0    
	
	Create Table #Travel_GST
	(
		Cmp_Id numeric(18,0),
		Emp_Id numeric(18,0),
		Travel_ID numeric(18,0),
		Approval_Date datetime,
		T_Description varchar(max),
		Application_Code numeric,
		Amount numeric(18,2),
		SGST numeric(18,2),
		CGST numeric(18,2),
		IGST numeric(18,2),
		Type varchar(250),
		Main_GST_No varchar(25),
		GST_No varchar(25),
		GST_Company_Name varchar(250)
		
	)
	Insert INTO #Travel_GST (Cmp_Id,Emp_Id,Travel_ID,Approval_Date,T_Description,Application_Code,Amount,SGST,CGST,IGST,Type,Main_GST_No,GST_No,GST_Company_Name)
	select A.Cmp_ID,A.Emp_ID,A.Travel_Application_ID,TA.Approval_Date,
		M.Travel_Mode_Name As Description,isnull(a.Application_Code,ta.travel_approval_id)As Approval_Code,
		TAO.Amount,TAO.SGST,TAO.CGST,TAO.IGST,'Application' As Type,
		C.GST_No As Main_GST_No,TAO.GST_No,TAO.GST_Company_Name
	FROM T0100_TRAVEL_APPLICATION A WITH (NOLOCK)
	inner JOIN #Emp_Cons ES ON ES.Emp_ID = A.Emp_ID
	INNER JOIN T0120_TRAVEL_APPROVAL TA WITH (NOLOCK) ON A.Travel_Application_ID = TA.Travel_Application_ID
	INNER JOIN T0110_Travel_Application_Other_Detail TAO WITH (NOLOCK) ON TAO.Travel_App_ID = TA.Travel_Application_ID
	INNER JOIN T0030_TRAVEL_MODE_MASTER M WITH (NOLOCK) ON M.Travel_Mode_ID = TAO.Travel_Mode_Id
	inner JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON E.Emp_ID=ES.Emp_ID
	inner JOIN T0010_COMPANY_MASTER C WITH (NOLOCK) ON C.Cmp_Id = A.Cmp_ID
	WHERE TA.Approval_Status='A' AND M.GST_Applicable = 1 and a.Application_Date between @from_date AND @to_date
	
	UNION ALL
	SELECT TS.cmp_id,TS.emp_id,sE.Travel_Set_Application_id,TSA.Approval_date,
	ET.Expense_Type_name AS Description,SE.Travel_Set_Application_id As Approval_Code,
	SE.Amount,SE.SGST,SE.CGST,SE.IGST,'Settlement' as  Type,
	c.GST_No As Main_GST_NO, SE.GST_No,se.GST_Company_Name
	FROM T0140_Travel_Settlement_Application TS WITH (NOLOCK)
	inner JOIN #Emp_Cons ES ON ES.Emp_ID = TS.Emp_ID
	inner join T0150_Travel_Settlement_Approval TSA WITH (NOLOCK) ON TS.Travel_Set_Application_id = TSA.Travel_Set_Application_id
	INNER JOIN T0140_Travel_Settlement_Expense SE WITH (NOLOCK) ON SE.Travel_Set_Application_id = TS.Travel_Set_Application_id
	INNER JOIN T0040_Expense_Type_Master ET WITH (NOLOCK) ON ET.Expense_Type_ID = sE.Expense_Type_id
	inner JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON E.Emp_ID=ES.Emp_ID
	inner JOIN T0010_COMPANY_MASTER C WITH (NOLOCK) ON C.Cmp_Id = TS.Cmp_ID
	WHERE  TS.Status = 'A' AND ET.GST_Applicable = 1 and TS.For_date between @From_date AND @To_date
	order BY Approval_date
	
	select ROW_NUMBER() Over (order by E.EMP_ID) as Sr_No, E.Alpha_Emp_Code + ' - ' + E.Emp_Full_Name As Emp_Full_Name,G.*,c.Cmp_Name,c.Cmp_Address,
		   B.Branch_Name,GM.Grd_Name,D.Dept_Name,DS.Desig_Name,
		   T.Type_Name,V.Vertical_Name,SV.SubVertical_Name
	from #Travel_GST G 
	inner JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON E.Emp_ID = G.Emp_Id
	INNER JOIN(	select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID , Inc_Bank_AC_No , I.Emp_OT_Max_Limit,I.Vertical_ID,I.SubVertical_ID from T0095_Increment I WITH (NOLOCK) INNER JOIN 
				( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  
				) Qry 
				on I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 
			) I_Q 
		on E.Emp_ID = I_Q.Emp_ID  
	inner JOIN T0010_COMPANY_MASTER c WITH (NOLOCK) ON c.Cmp_Id = g.Cmp_Id
	inner JOIN T0030_BRANCH_MASTER B WITH (NOLOCK) ON B.Branch_ID = I_Q.Branch_ID
	inner JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON GM.Grd_ID = I_Q.Grd_ID
	left OUTER JOIN T0040_DEPARTMENT_MASTER D WITH (NOLOCK) ON D.Dept_Id = i_q.Dept_ID
	left OUTER JOIN T0040_DESIGNATION_MASTER DS WITH (NOLOCK) ON DS.Desig_ID = I_Q.Desig_Id
	left OUTER JOIN T0040_TYPE_MASTER T WITH (NOLOCK) ON T.Type_ID = I_Q.Type_ID
	left OUTER JOIN T0040_Vertical_Segment V WITH (NOLOCK) ON V.Vertical_ID = I_Q.Vertical_ID
	left OUTER JOIN T0050_SubVertical SV WITH (NOLOCK) ON SV.SubVertical_ID = I_Q.SubVertical_ID
	
	
END

