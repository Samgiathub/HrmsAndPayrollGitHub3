

-- =============================================
-- Author:		Divyaraj Kiri
-- Create date: 10/04/2023
-- Description:	Get Canteen Application
-- exec P0050_CANTEEN_Report_4 120,'2023-04-01','2023-04-15','','','','','','',0,'',1
-- =============================================
CREATE PROCEDURE [dbo].[P0050_CANTEEN_Report_4_OLD_25012024] 
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		varchar(MAX) = ''   
	,@Grd_ID		varchar(MAX) = ''  
	,@Cat_ID		varchar(MAX) = ''  
	,@Dept_ID		varchar(MAX) = ''           
	,@Type_ID		varchar(MAX) = ''                
	,@Desig_ID		varchar(MAX) = ''     
	,@Emp_ID		varchar(MAX) = 0 
	,@Constraint	varchar(MAX) = ''
	,@flag int = 0
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
		
		if @Branch_ID = '' 
			set @Branch_ID = null
		if @Cat_ID = '' 
			set @Cat_ID = null
		if @Type_ID = '' 
			set @Type_ID = null
		if @Dept_ID = '' 
			set @Dept_ID = null
		if @Grd_ID = ''
			set @Grd_ID = null
		if @Emp_ID = 0
			set @Emp_ID = null
		If @Desig_ID = ''
			set @Desig_ID = null

		CREATE TABLE #EMP_CONS 
		(      
			EMP_ID		 NUMERIC ,     
			BRANCH_ID	 NUMERIC,
			INCREMENT_ID NUMERIC
		)      
	
		--EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date ,@To_Date ,@Branch_ID ,@Cat_ID ,@Grd_ID ,@Type_ID ,@Dept_ID ,@Desig_ID ,@Emp_ID ,@Constraint ,0 ,0 ,0,0,0,0,0,0,0,0,0,0	
		EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN  @Cmp_ID,@From_Date ,@To_Date ,@Branch_ID ,@Cat_ID ,@Grd_ID ,@Type_ID ,@Dept_ID ,@Desig_ID  ,@Emp_ID ,@Constraint ,0 ,0 ,0,0,0,0,0,0,0,0,0,0	
		--CREATE UNIQUE CLUSTERED INDEX IX_EMP_CONS_EMPID ON #EMP_CONS (EMP_ID);
		
		
						
		-----------------------------------------Get the Employee Details from Company ID--------------------------------------
		
		SELECT distinct Emp_id, [Sub-Contractor], [Cost center] as Cost_Center into #tmpSCCC
		FROM
		(	SELECT Emp_id,Column_Name,Value from [T0081_CUSTOMIZED_COLUMN] cc 
			inner join T0082_Emp_Column ec WITH (NOLOCK) on cc.Tran_Id = ec.mst_Tran_Id where 
			 Column_Name in ('Sub-Contractor','Cost center')
		) AS SourceTable
		PIVOT
		(
			MAX(Value) FOR Column_Name IN ([Sub-Contractor], [Cost center])
		) AS PivotTable;
		
		
		----select *
		--SELECT E.emp_id, E.Alpha_Emp_Code , E.emp_full_name,BS.Segment_Name as [Business_Unit],e.Mobile_No , desig_name as Designation, dept_name as Department
		--, branch_name as [BRANCH_NAME],grd_name as [Grade Name], TEC.[Sub-Contractor] ,TEC.[Cost_center],I.Grd_ID
		--from t0080_emp_master e
		--inner join #EMP_CONS ec on ec.EMP_ID=e.Emp_ID
	
		--inner join t0095_increment i  on i.Increment_ID=ec.INCREMENT_ID
		--	LEFT OUTER JOIN t0040_grade_master GM WITH (NOLOCK) ON I.grd_id = gm.grd_id  
		--LEFT OUTER JOIN t0030_branch_master BM WITH (NOLOCK)	ON I.branch_id = BM.branch_id 
		--LEFT OUTER JOIN t0040_department_master DM WITH (NOLOCK) ON I.dept_id = DM.dept_id 
		--LEFT OUTER JOIN t0040_designation_master DGM WITH (NOLOCK) ON I.desig_id = DGM.desig_id 
		--LEFT OUTER JOIN T0040_Business_Segment BS WITH (NOLOCK)	ON I.Segment_ID = BS.Segment_ID
		--LEFT OUTER JOIN #tmpSCCC TEC ON TEC.Emp_Id = e.Emp_ID
		
		SELECT E.emp_id, E.Alpha_Emp_Code , E.emp_full_name,BS.Segment_Name as [Business_Unit],e.Mobile_No , desig_name as Designation, dept_name as Department
		, branch_name as [BRANCH_NAME],grd_name as [Grade Name], TEC.[Sub-Contractor] ,TEC.[Cost_center],I.Grd_ID into #EmpDetails 
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
				LEFT OUTER JOIN T0040_Business_Segment BS WITH (NOLOCK)
						ON I.Segment_ID = BS.Segment_ID
				LEFT OUTER JOIN #tmpSCCC TEC ON TEC.Emp_Id = E.Emp_ID
		----select * from #EmpDetails

		--SELECT   EMP_ID ,CM.Cnt_Name,q2.Amount,CM.GST_Percentage,grd_id 
		--into #tmp1 
		--FROM T0150_EMP_CANTEEN_PUNCH ECP WITH (NOLOCK)
		--LEFT JOIN T0050_CANTEEN_MASTER CM WITH (NOLOCK) ON ECP.Canteen_ID = CM.Cnt_Id
		--LEFT JOIN(
		--	SELECT DISTINCT Amount,CD.Cnt_Id,cd.grd_id FROM  T0050_CANTEEN_DETAIL CD WITH (NOLOCK) inner join 
		--	(SELECT  Max(Effective_Date) AS For_Date ,Cnt_Id
		--		FROM   T0050_CANTEEN_DETAIL WITH (NOLOCK)
		--		WHERE  Effective_Date <= Getdate() AND 
		--		cmp_id = @Cmp_ID group by Cnt_Id) Q1 
		--		ON CD.Cnt_Id = Q1.Cnt_Id and CD.Effective_Date = Q1.For_Date
		--	) Q2 on CM.Cnt_Id = q2.Cnt_Id
		--	Where ECP.Canteen_Punch_Datetime between @From_Date and @To_Date 
		--	order by Emp_ID
		
		----select * from #TMP1
			
		--SELECT E.EMP_ID, E.ALPHA_EMP_CODE , E.EMP_FULL_NAME,E.MOBILE_NO,[Business_Unit],[DESIGNATION],[DEPARTMENT],[BRANCH_NAME] 
		--,E.[SUB-CONTRACTOR] ,E.[Cost_center],CNT_NAME AS [ITEM_NAME] ,
		--COUNT(CNT_NAME) AS [ITEM_QTY], 
		--AMOUNT, 
		--(COUNT(CNT_NAME) * AMOUNT) as [NET_AMOUNT]
		--FROM #EMPDETAILS E 
		--INNER JOIN #TMP1 T ON E.EMP_ID = T.EMP_ID AND E.GRD_ID = T.GRD_ID
		--GROUP BY E.Alpha_Emp_Code,E.emp_full_name,e.Mobile_No,[DESIGNATION],[DEPARTMENT],[BRANCH_NAME],E.EMP_ID,CNT_NAME,AMOUNT, E.[Sub-Contractor] ,E.[Cost_center],[Business_Unit],t.GST_Percentage
		--ORDER BY e.emp_id

		--DROP TABLE #EMPDETAILS
		--DROP TABLE #TMP1
		--DROP TABLE #tmpSCCC

		Select CA.App_Id,CA.Cmp_Id  ,CA.Receive_Date  ,CA.Emp_Id  ,CA.Emp_Name  ,CA.Designation  ,CA.Department  ,		
		CA.Duration  ,CA.From_Date  ,CA.To_Date  ,CA.Canteen_Name  ,CA.App_No,CA.User_ID,CM.Cnt_Name,isnull(CA.[Description],'') as [Description],
		CA.App_Type,isnull(RM.Reason_Name,'') as Guest_Type,isnull(CA.Guest_Name,'') as Guest_Name,
		isnull(CA.Guest_Count,0) as Guest_Count
		into #tmp1
		from 
		T0080_CANTEEN_APPLICATION CA WITH (NOLOCK)
		LEFT OUTER JOIN T0050_CANTEEN_MASTER CM with (NOLOCK) ON CM.Cnt_Id = CA.Cnt_Id
		LEFT OUTER JOIN T0040_Reason_Master RM with (NOLOCK) on RM.Res_Id = CA.Guest_Type_Id 
		--INNER JOIN T0100_LEAVE_APPLICATION LA with (NOLOCK) on LA.Emp_ID = CA.Emp_Id
		where CA.Cmp_Id = @Cmp_ID and 
		convert(varchar, CA.From_Date, 105) >= convert(varchar, @From_Date, 105) and
		convert(varchar, CA.To_Date, 105) <= convert(varchar, @To_Date, 105)		
		--and LA.Cmp_ID = @Cmp_ID  and LA.Application_Status = 'A'
		order by CA.Emp_Id

		
		Declare @TotalCount as varchar(50);
		Declare @TotalLunch as varchar(50);
		Declare @TotalDinner as varchar(50);
		Declare @TotalTeaBreak as varchar(50);

		Declare @Total as Integer
		Declare @TotLunch as Integer
		Declare @TotDinner as Integer
		Declare @TotTeaBreak as Integer
		
		set @Total = 0
		
		Select @Total = count(*) from #tmp1 where App_Type not in('Guest')
		select @TotLunch = count(*) from #tmp1 where Cnt_Name = 'Lunch'
		select @TotDinner = count(*) from #tmp1 where Cnt_Name = 'Dinner'
		select @TotTeaBreak = count(*) from #tmp1 where Cnt_Name = 'Tea Break'

		set @TotalCount = convert(varchar(50),@Total)
		set @TotalLunch  = convert(varchar(50),@TotLunch) 
		set @TotalDinner = convert(varchar(50),@TotDinner)
		set @TotalTeaBreak = convert(varchar(50),@TotTeaBreak) 

		-- For Self Total Start

		--Declare @TotalSCount as varchar(50);
		--Declare @TotalSLunch as varchar(50);
		--Declare @TotalSDinner as varchar(50);
		--Declare @TotalSTeaBreak as varchar(50);

		--Declare @TotalS as Integer
		--Declare @TotSLunch as Integer
		--Declare @TotSDinner as Integer
		--Declare @TotSTeaBreak as Integer
		
		--set @TotalS = 0
		
		--Select @TotalS = count(*) from #tmp1 where App_Type='Self'
		--select @TotSLunch = count(*) from #tmp1 where Cnt_Name = 'Lunch' and App_Type='Self'
		--select @TotSDinner = count(*) from #tmp1 where Cnt_Name = 'Dinner' and App_Type='Self'
		--select @TotSTeaBreak = count(*) from #tmp1 where Cnt_Name = 'Tea Break' and App_Type='Self'

		--set @TotalSCount = convert(varchar(50),@TotalS)
		--set @TotalSLunch  = convert(varchar(50),@TotSLunch) 
		--set @TotalSDinner = convert(varchar(50),@TotSDinner)
		--set @TotalSTeaBreak = convert(varchar(50),@TotSTeaBreak) 

		-- For Self Total End

		-- For Employee Total Start

		--Declare @TotalECount as varchar(50);
		--Declare @TotalELunch as varchar(50);
		--Declare @TotalEDinner as varchar(50);
		--Declare @TotalETeaBreak as varchar(50);

		--Declare @TotalE as Integer
		--Declare @TotELunch as Integer
		--Declare @TotEDinner as Integer
		--Declare @TotETeaBreak as Integer
		
		--set @TotalE = 0
		
		--Select @TotalE = count(*) from #tmp1 where App_Type='Employee'
		--select @TotELunch = count(*) from #tmp1 where Cnt_Name = 'Lunch' and App_Type='Employee'
		--select @TotEDinner = count(*) from #tmp1 where Cnt_Name = 'Dinner' and App_Type='Employee'
		--select @TotETeaBreak = count(*) from #tmp1 where Cnt_Name = 'Tea Break' and App_Type='Employee'

		--set @TotalECount = convert(varchar(50),@TotalE)
		--set @TotalELunch  = convert(varchar(50),@TotELunch) 
		--set @TotalEDinner = convert(varchar(50),@TotEDinner)
		--set @TotalETeaBreak = convert(varchar(50),@TotETeaBreak) 

		-- For Employee Total End
		
		-- For Guest Total Start

		Declare @TotalCCount as varchar(50);
		Declare @TotalCLunch as varchar(50);
		Declare @TotalCDinner as varchar(50);
		Declare @TotalCTeaBreak as varchar(50);

		Declare @TotalC as Integer
		Declare @TotCLunch as Integer
		Declare @TotCDinner as Integer
		Declare @TotCTeaBreak as Integer
		
		set @TotalC = 0
		
		Select @TotalC = SUM(Guest_Count) from #tmp1 where App_Type='Guest'
		select @TotCLunch = SUM(Guest_Count) from #tmp1 where Cnt_Name = 'Lunch' and App_Type='Guest'
		select @TotCDinner = SUM(Guest_Count) from #tmp1 where Cnt_Name = 'Dinner' and App_Type='Guest'
		select @TotCTeaBreak = SUM(Guest_Count) from #tmp1 where Cnt_Name = 'Tea Break' and App_Type='Guest'

		set @TotalCCount = convert(varchar(50),@TotalC)
		set @TotalCLunch  = convert(varchar(50),@TotCLunch) 
		set @TotalCDinner = convert(varchar(50),@TotCDinner)
		set @TotalCTeaBreak = convert(varchar(50),@TotCTeaBreak) 

		-- For Guest Total End

		if @flag = 0
		begin
			SELECT distinct T.App_No as App_No,E.EMP_ID as EMP_ID, E.ALPHA_EMP_CODE as ALPHA_EMP_CODE , E.EMP_FULL_NAME as EMP_FULL_NAME,
			E.MOBILE_NO as MOBILE_NO,E.Business_Unit as Business_Unit,E.DESIGNATION as DESIGNATION,E.DEPARTMENT as DEPARTMENT,E.BRANCH_NAME as BRANCH_NAME 
			,E.[SUB-CONTRACTOR] as SUBCONTRACTOR ,E.[Cost_center] as CostCenter,convert(varchar,T.From_Date,105) as From_Date,convert(varchar,T.To_Date,105) as To_Date,
			T.Cnt_Name as Cnt_Name,T.[Description] as Dscription,T.App_Type,T.Guest_Type,T.Guest_Name		
			FROM #EMPDETAILS E 
			INNER JOIN #TMP1 T ON E.EMP_ID = T.EMP_ID 	
		end
		else if @flag = 1
		begin
			SELECT T.App_No as App_No,E.EMP_ID as EMP_ID, E.ALPHA_EMP_CODE as ALPHA_EMP_CODE , E.EMP_FULL_NAME as EMP_FULL_NAME,
			E.MOBILE_NO as MOBILE_NO,E.Business_Unit as Business_Unit,E.DESIGNATION as DESIGNATION,E.DEPARTMENT as DEPARTMENT,E.BRANCH_NAME as BRANCH_NAME 
			,E.[SUB-CONTRACTOR] as SUBCONTRACTOR ,E.[Cost_center] as CostCenter,convert(varchar,T.From_Date,105) as From_Date,convert(varchar,T.To_Date,105) as To_Date,
			T.Cnt_Name as Cnt_Name,isnull(T.[Description],'') as Dscription,T.App_Type,isnull(T.Guest_Type,'') as Guest_Type,
			isnull(T.Guest_Name,'') as Guest_Name
			FROM #EMPDETAILS E 
			INNER JOIN #TMP1 T ON E.EMP_ID = T.EMP_ID 	
			--where T.From_Date >= @From_Date and T.To_Date <= @To_Date
			--ORDER BY e.emp_id
			union all

			SELECT distinct '' as App_No,0 as EMP_ID,'' as ALPHA_EMP_CODE,'' as EMP_FULL_NAME,'' as MOBILE_NO,
			'' as Business_Unit,'' as DESIGNATION,'' as DEPARTMENT,'' as BRANCH_NAME,'' as SUBCONTRACTOR,
			'' as CostCenter,NULL as From_Date,NULL as To_Date,'' as Cnt_Name,'' as Dscription,
			'' as App_Type,'' as Guest_Type,'' as Guest_Name

			union all

			SELECT distinct 'Total Canteen Application : ' as App_No,0 as EMP_ID,TRY_CAST((@TotalCount) as varchar(50)) as ALPHA_EMP_CODE,
			'Total Lunch Application :' as EMP_FULL_NAME,'' as MOBILE_NO,isnull(TRY_CAST((@TotalLunch) as varchar(50)),0) as Business_Unit,
			'Total Dinner Application :' as DESIGNATION,isnull(TRY_CAST((@TotalDinner) as varchar(50)),0) as DEPARTMENT,
			'Total TeaBreak Application :' as BRANCH_NAME,isnull(TRY_CAST((@TotalTeaBreak) as varchar(50)),0) as SUBCONTRACTOR,
			'' as CostCenter,NULL as From_Date,NULL as To_Date,'' as Cnt_Name,'' as Dscription,
			'' as App_Type,'' as Guest_Type,'' as Guest_Name
			
			union all

			SELECT distinct '' as App_No,0 as EMP_ID,'' as ALPHA_EMP_CODE,'' as EMP_FULL_NAME,'' as MOBILE_NO,
			'' as Business_Unit,'' as DESIGNATION,'' as DEPARTMENT,'' as BRANCH_NAME,'' as SUBCONTRACTOR,
			'' as CostCenter,NULL as From_Date,NULL as To_Date,'' as Cnt_Name,'' as Dscription,
			'' as App_Type,'' as Guest_Type,'' as Guest_Name
			
			union all 

			--SELECT distinct 'Total Canteen Application (Self) : ' as App_No,0 as EMP_ID,TRY_CAST((@TotalSCount) as varchar(50)) as ALPHA_EMP_CODE,
			--'Total Lunch Application :' as EMP_FULL_NAME,'' as MOBILE_NO,isnull(TRY_CAST((@TotalSLunch) as varchar(50)),0) as Business_Unit,
			--'Total Dinner Application :' as DESIGNATION,isnull(TRY_CAST((@TotalSDinner) as varchar(50)),0) as DEPARTMENT,
			--'Total TeaBreak Application :' as BRANCH_NAME,isnull(TRY_CAST((@TotalSTeaBreak) as varchar(50)),0) as SUBCONTRACTOR,
			--'' as CostCenter,NULL as From_Date,NULL as To_Date,'' as Cnt_Name,'' as Dscription,
			--'' as App_Type,'' as Guest_Type,'' as Guest_Name

			--union all

			--SELECT distinct '' as App_No,0 as EMP_ID,'' as ALPHA_EMP_CODE,'' as EMP_FULL_NAME,'' as MOBILE_NO,
			--'' as Business_Unit,'' as DESIGNATION,'' as DEPARTMENT,'' as BRANCH_NAME,'' as SUBCONTRACTOR,
			--'' as CostCenter,NULL as From_Date,NULL as To_Date,'' as Cnt_Name,'' as Dscription,
			--'' as App_Type,'' as Guest_Type,'' as Guest_Name
			
			--union all 

			--SELECT distinct 'Total Canteen Application (Employee) : ' as App_No,0 as EMP_ID,TRY_CAST((@TotalECount) as varchar(50)) as ALPHA_EMP_CODE,
			--'Total Lunch Application :' as EMP_FULL_NAME,'' as MOBILE_NO,isnull(TRY_CAST((@TotalELunch) as varchar(50)),0) as Business_Unit,
			--'Total Dinner Application :' as DESIGNATION,isnull(TRY_CAST((@TotalEDinner) as varchar(50)),0) as DEPARTMENT,
			--'Total TeaBreak Application :' as BRANCH_NAME,isnull(TRY_CAST((@TotalETeaBreak) as varchar(50)),0) as SUBCONTRACTOR,
			--'' as CostCenter,NULL as From_Date,NULL as To_Date,'' as Cnt_Name,'' as Dscription,
			--'' as App_Type,'' as Guest_Type,'' as Guest_Name

			--union all

			--SELECT distinct '' as App_No,0 as EMP_ID,'' as ALPHA_EMP_CODE,'' as EMP_FULL_NAME,'' as MOBILE_NO,
			--'' as Business_Unit,'' as DESIGNATION,'' as DEPARTMENT,'' as BRANCH_NAME,'' as SUBCONTRACTOR,
			--'' as CostCenter,NULL as From_Date,NULL as To_Date,'' as Cnt_Name,'' as Dscription,
			--'' as App_Type,'' as Guest_Type,'' as Guest_Name
			
			--union all 

			SELECT distinct 'Total Canteen Application (Guest) : ' as App_No,0 as EMP_ID,TRY_CAST((@TotalCCount) as varchar(50)) as ALPHA_EMP_CODE,
			'Total Lunch Application :' as EMP_FULL_NAME,'' as MOBILE_NO,isnull(TRY_CAST((@TotalCLunch) as varchar(50)),0) as Business_Unit,
			'Total Dinner Application :' as DESIGNATION,isnull(TRY_CAST((@TotalCDinner) as varchar(50)),0) as DEPARTMENT,
			'Total TeaBreak Application :' as BRANCH_NAME,isnull(TRY_CAST((@TotalCTeaBreak) as varchar(50)),0) as SUBCONTRACTOR,
			'' as CostCenter,NULL as From_Date,NULL as To_Date,'' as Cnt_Name,'' as Dscription,
			'' as App_Type,'' as Guest_Type,'' as Guest_Name

		end


		DROP TABLE #EMPDETAILS
		DROP TABLE #TMP1
		DROP TABLE #tmpSCCC

END
