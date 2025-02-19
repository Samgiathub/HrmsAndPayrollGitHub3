-- =============================================
-- Author:		Divyaraj Kiri
-- Create date: 05/02/2024
-- Description:	For Get the Canteen Application Details Report
-- =============================================
CREATE PROCEDURE [dbo].[P0050_CANTEEN_Report_5] 
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

		--;WITH MaxEffectiveDates AS (
		--	SELECT CDI.Cnt_Id, MAX(CDI.Effective_Date) AS MaxEffectiveDate
		--	FROM T0050_CANTEEN_DETAIL CDI
		--	INNER JOIN T0080_CANTEEN_APPLICATION CAI with (NOLOCK) on 
		--	CAI.Cnt_Id = CDI.Cnt_Id AND CAI.Cmp_Id = CDI.Cmp_Id
		--	where Convert(varchar,CDI.Effective_Date,112) <= Convert(varchar,CAI.From_Date,112) 
		--	AND Convert(varchar,CDI.Effective_Date,112) <= Convert(varchar,CAI.To_Date,112)
		--	GROUP BY CDI.Cnt_Id
		--)
		--Select CA.App_Id,CA.Cmp_Id  ,convert(varchar,CA.Receive_Date,103) as App_Date  ,CA.Emp_Id  ,CA.Emp_Name  ,CA.Designation  ,CA.Department  ,		
		--CA.Duration  ,convert(varchar,CA.From_Date,103) as From_Date  ,convert(varchar,CA.To_Date,103) as To_Date,CM.Cnt_Name  ,CA.App_No,
		--CA.User_ID,IM.Device_Name,
		--GM.Grd_Name , CD.Amount,isnull(CD.Subsidy_Amount,0) as Subsidy_Amount,
		--isnull(CA.[Description],'') as [Description],
		--CA.App_Type,isnull(RM.Reason_Name,'') as Guest_Type,isnull(CA.Guest_Name,'') as Guest_Name,
		----isnull(CA.Guest_Count,0) * (DATEDIFF(DAY,Convert(varchar,@From_Date,112),Convert(varchar,@To_Date,112)) + 1)
		--isnull(CA.Guest_Count,0) * (DATEDIFF(DAY, 
		--	--CASE WHEN CA.From_Date < @To_Date THEN @To_Date ELSE CA.From_Date END, 
		--	--CASE WHEN CA.To_Date > @From_Date THEN @From_Date ELSE CA.To_Date END) + 1)
  --          CASE WHEN CA.From_Date < @From_Date THEN @From_Date ELSE CA.From_Date END, 
  --          CASE WHEN CA.To_Date > @To_Date THEN @To_Date ELSE CA.To_Date END) + 1)
		--as Guest_Count		
		--into #tmp1
		--from 
		--T0080_CANTEEN_APPLICATION CA WITH (NOLOCK)
		--LEFT OUTER JOIN T0080_EMP_MASTER EM with (NOLOCK) on EM.Emp_ID = CA.Emp_Id
		--INNER JOIN (
		--				SELECT	I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,IsNull(I.Emp_Late_mark,0) Emp_Late_mark,IsNull(I.Emp_Early_mark,0) Emp_Early_mark ,I.Type_ID,I.Vertical_ID,I.SubVertical_ID
		--				FROM	T0095_Increment I 
		--						inner join (
		--										select	Max(TI.Increment_ID) Increment_Id,ti.Emp_ID 
		--										FROM	t0095_increment TI 
		--												inner join (
		--																Select	Max(Increment_Effective_Date) as Increment_Effective_Date,I.Emp_ID 
		--																FROM	T0095_Increment I 
		--																		Inner Join #Emp_Cons EC On I.Emp_ID= EC.Emp_ID
		--																Where	Increment_effective_Date <= @to_date Group by I.emp_ID
		--															) new_inc on TI.Emp_ID = new_inc.Emp_ID AND Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
		--										Where TI.Increment_effective_Date <= @to_date group by ti.emp_id
		--									) Qry on I.Increment_Id = Qry.Increment_Id
		--			)Q_I ON EM.EMP_ID = Q_I.EMP_ID
		--LEFT OUTER JOIN T0040_GRADE_MASTER GM with (NOLOCK) on Q_I.Grd_ID = GM.Grd_ID
		--LEFT OUTER JOIN T0050_CANTEEN_MASTER CM with (NOLOCK) ON CM.Cnt_Id = CA.Cnt_Id
		--LEFT OUTER JOIN T0040_IP_MASTER IM with (NOLOCK) on IM.IP_ID = CM.Ip_Id
		--LEFT OUTER JOIN T0040_Reason_Master RM with (NOLOCK) on RM.Res_Id = CA.Guest_Type_Id
		--LEFT OUTER JOIN T0050_CANTEEN_DETAIL CD with (NoLock) on CD.Cnt_Id = CM.Cnt_Id and GM.grd_id = CD.grd_id
		--INNER JOIN MaxEffectiveDates MED ON CA.Cnt_Id = MED.Cnt_Id AND MED.MaxEffectiveDate = CD.Effective_Date		
		--where CA.Cmp_Id = @Cmp_ID and 
		--(		
		--	(Convert(varchar,CA.From_Date,112) <= Convert(varchar,@To_Date,112) AND Convert(varchar,CA.To_Date,112) >= Convert(varchar,@From_Date,112)) OR
		--	(Convert(varchar,CA.From_Date,112) BETWEEN Convert(varchar,@From_Date,112) AND Convert(varchar,@To_Date,112)) OR
		--	(Convert(varchar,CA.To_Date,112) BETWEEN Convert(varchar,@From_Date,112) AND Convert(varchar,@To_Date,112))
		--)		
		--order by CA.App_No,CA.Receive_Date asc

		--Select * from T0080_CANTEEN_APPLICATION where Cmp_Id = @Cmp_ID
		--and From_Date >= @From_Date and To_Date <= @To_Date

		;with cte as (
				select CA.App_Id, CA.Cmp_Id as CMP_ID , CA.Receive_Date,CA.Emp_Id, CA.Emp_Name, CA.Designation, CA.Department, CA.Duration,
					CA.From_Date,CA.To_Date,CM.Cnt_Name as Canteen_Name, CA.App_No, CA.User_ID, IM.Device_Name as Device_Name,GM.Grd_Name as Grd_Name,
					0 as Amount,0 as Subsidy_Amount,CA.[Description] as Description, CA.App_Type, RM.Reason_Name as Guest_Type, CA.Guest_Name, CA.Guest_Count,			  
					CA.From_Date as DOS,CA.Cnt_Id as CNT_ID,GM.Grd_ID
				  from T0080_CANTEEN_APPLICATION CA WITH (NOLOCK) -- where emp_id =14560
				  LEFT OUTER JOIN T0080_EMP_MASTER EM with (NOLOCK) on EM.Emp_ID = CA.Emp_Id
					INNER JOIN (
									SELECT	I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_ID,I.Emp_ID,IsNull(I.Emp_Late_mark,0) Emp_Late_mark,IsNull(I.Emp_Early_mark,0) Emp_Early_mark ,I.Type_ID,I.Vertical_ID,I.SubVertical_ID
									FROM	T0095_Increment I 
											inner join (
															select	Max(TI.Increment_ID) Increment_Id,ti.Emp_ID 
															FROM	t0095_increment TI 
																	inner join (
																					Select	Max(Increment_Effective_Date) as Increment_Effective_Date,I.Emp_ID 
																					FROM	T0095_Increment I 
																							Inner Join #Emp_Cons EC On I.Emp_ID= EC.Emp_ID
																					Where	Increment_effective_Date <= @to_date Group by I.emp_ID
																				) new_inc on TI.Emp_ID = new_inc.Emp_ID AND Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
															Where TI.Increment_effective_Date <= @to_date group by ti.emp_id
														) Qry on I.Increment_Id = Qry.Increment_Id
								)Q_I ON EM.EMP_ID = Q_I.EMP_ID
					LEFT OUTER JOIN T0040_GRADE_MASTER GM with (NOLOCK) on Q_I.Grd_ID = GM.Grd_ID
					LEFT OUTER JOIN T0050_CANTEEN_MASTER CM with (NOLOCK) ON CM.Cnt_Id = CA.Cnt_Id
					LEFT OUTER JOIN T0040_IP_MASTER IM with (NOLOCK) on IM.IP_ID = CM.Ip_Id
					LEFT OUTER JOIN T0040_Reason_Master RM with (NOLOCK) on RM.Res_Id = CA.Guest_Type_Id
				  where CA.Cmp_Id = @Cmp_ID
				  --order by App_Id asc
				  union all
				  select App_Id, CMP_ID , Receive_Date,Emp_Id, Emp_Name, Designation, Department, Duration,
					From_Date,To_Date,Canteen_Name, App_No, User_ID, Device_Name,Grd_Name,0 as Amount,
					0 as Subsidy_Amount,Description, App_Type, Guest_Type, Guest_Name, Guest_Count,			  					  				  
					dateadd(day, 1, dos) as DOS,CNT_ID,Grd_ID
				  from cte
				  where dos < To_Date
				  AND From_Date >= @From_Date and To_Date <= @To_Date				  
				  AND Cmp_Id = @Cmp_ID
				  --order by App_Id asc
			 )
			 Select *,
			 (
				SELECT  MAX(cd.Effective_Date)
				FROM T0050_CANTEEN_DETAIL CD
				WHERE CD.Effective_Date <= C.DOS and CD.Cmp_Id=C.CMP_ID and CD.Cnt_Id=C.CNT_ID AND CD.grd_id = C.Grd_ID
	         ) AS max_effective_date			 
			 INTO #tmp1
			 from cte C
			 where C.CMP_ID = @Cmp_ID AND
			 (		
				(Convert(varchar,C.DOS,112) <= Convert(varchar,@To_Date,112) AND Convert(varchar,C.DOS,112) >= Convert(varchar,@From_Date,112)) OR
				(Convert(varchar,C.DOS,112) BETWEEN Convert(varchar,@From_Date,112) AND Convert(varchar,@To_Date,112)) OR
				(Convert(varchar,C.DOS,112) BETWEEN Convert(varchar,@From_Date,112) AND Convert(varchar,@To_Date,112))
			)
			--order by C.DOS asc

			--SELECT COLUMN_NAME, COLLATION_NAME
			--FROM INFORMATION_SCHEMA.COLUMNS
			--WHERE TABLE_NAME = '#tmp1' AND COLUMN_NAME = 'DOS'
			--return
			--Select * from #tmp1 ORDER BY DOS ASC
			--return
			 
			 update t set
			 t.Amount = CD.Amount,t.Subsidy_Amount = CD.Subsidy_Amount
			 from #tmp1 t with (NOLOCK)
			 LEFT OUTER JOIN T0050_CANTEEN_DETAIL CD with (NOLOCK) on CD.Effective_Date = t.max_effective_date
			 and CD.Cmp_Id=t.CMP_ID and CD.Cnt_Id=t.CNT_ID AND CD.grd_id = t.Grd_ID

			-- Select * from #tmp1 where Emp_Id = 14560
			--return

		if @flag = 0
		begin
			SELECT E.Emp_ID,
			E.Alpha_Emp_Code , E.Emp_Full_Name,E.BRANCH_NAME,E.Department,E.Designation, 
			T.Grd_Name AS Grade_Name,T.App_No,CONVERT(VARCHAR, T.Receive_Date, 103)  as App_Date,CONVERT(VARCHAR, T.DOS, 103) as [Date],
			T.Device_Name,T.Canteen_Name as Food_Type,T.Amount as Employee_Rate,
			T.Subsidy_Amount as Subsidy_Rate,
			CASE WHEN App_Type = 'Self' THEN Guest_Count ELSE 0 END as 'Self_Count', 
			CASE WHEN App_Type = 'Guest' THEN Guest_Count ELSE 0 END as 'Guest_Count',E.Mobile_No,
			(CASE WHEN App_Type = 'Self' THEN Guest_Count ELSE 0 END) * ISNULL(T.Amount, 0) AS Self_Amount,
			(CASE WHEN App_Type = 'Self' THEN Guest_Count ELSE 0 END) * ISNULL(T.Subsidy_Amount, 0) AS Self_Subsidy_Amount,
			(CASE WHEN App_Type = 'Guest' THEN Guest_Count ELSE 0 END) * ISNULL(T.Amount, 0) AS Guest_Amount,
			(CASE WHEN App_Type = 'Guest' THEN Guest_Count ELSE 0 END) * ISNULL(T.Subsidy_Amount, 0) AS Guest_Subsidy_Amount,
			((CASE WHEN App_Type = 'Self' THEN Guest_Count ELSE 0 END) + (CASE WHEN App_Type = 'Guest' THEN Guest_Count ELSE 0 END)) 
			* ISNULL(T.Amount, 0) + 
			((CASE WHEN App_Type = 'Self' THEN Guest_Count ELSE 0 END) + (CASE WHEN App_Type = 'Guest' THEN Guest_Count ELSE 0 END)) 
			* ISNULL(T.Subsidy_Amount, 0)
			AS Total
			FROM #EMPDETAILS E 
			INNER JOIN #TMP1 T ON E.EMP_ID = T.EMP_ID
			order by t.DOS asc
		end
		else if @flag = 1
		begin

			DECLARE @SelfCount INT, @GuestCount INT, @SelfAmount DECIMAL(18,2), @GuestAmount DECIMAL(18,2),@SelfSubAmount decimal(18,2),@GuestSubAmount decimal(18,2)

			SELECT Distinct
			@SelfCount = SUM(CASE WHEN T.App_Type = 'Self' THEN T.Guest_Count ELSE 0 END), 
			@GuestCount = SUM(CASE WHEN T.App_Type = 'Guest' THEN T.Guest_Count ELSE 0 END),
			@SelfAmount = SUM((CASE WHEN T.App_Type = 'Self' THEN T.Guest_Count ELSE 0 END) * ISNULL(T.Amount, 0)),
			@SelfSubAmount = SUM((CASE WHEN T.App_Type = 'Self' THEN T.Guest_Count ELSE 0 END) * ISNULL(T.Subsidy_Amount, 0)),
			@GuestAmount = SUM((CASE WHEN T.App_Type = 'Guest' THEN T.Guest_Count ELSE 0 END) * ISNULL(T.Amount, 0)),
			@GuestSubAmount = SUM((CASE WHEN T.App_Type = 'Guest' THEN T.Guest_Count ELSE 0 END) * ISNULL(T.Subsidy_Amount, 0))
			FROM #EMPDETAILS E 
			INNER JOIN #TMP1 T ON E.EMP_ID = T.EMP_ID			

			;WITH IndividualRecords AS (
			SELECT TOP 100 PERCENT
				E.Emp_ID,
				E.Alpha_Emp_Code,
				E.Emp_Full_Name,
				E.BRANCH_NAME,
				E.Department,
				E.Designation, 
				T.Grd_Name AS Grade_Name,
				T.App_No,
				CONVERT(VARCHAR, T.Receive_Date, 103) AS App_Date,
				CONVERT(VARCHAR, T.DOS, 103) AS [Date],
				T.Device_Name,
				T.Canteen_Name AS Food_Type,
				T.Amount AS Employee_Rate,
				T.Subsidy_Amount AS Subsidy_Rate,
				CASE WHEN App_Type = 'Self' THEN Guest_Count ELSE 0 END AS Self_Count, 
				CASE WHEN App_Type = 'Guest' THEN Guest_Count ELSE 0 END AS Guest_Count,
				E.Mobile_No,
				(CASE WHEN App_Type = 'Self' THEN Guest_Count ELSE 0 END) * ISNULL(T.Amount, 0) AS Self_Amount,
				(CASE WHEN App_Type = 'Self' THEN Guest_Count ELSE 0 END) * ISNULL(T.Subsidy_Amount, 0) AS Self_Subsidy_Amount,
				(CASE WHEN App_Type = 'Guest' THEN Guest_Count ELSE 0 END) * ISNULL(T.Amount, 0) AS Guest_Amount,
				(CASE WHEN App_Type = 'Guest' THEN Guest_Count ELSE 0 END) * ISNULL(T.Subsidy_Amount, 0) AS Guest_Subsidy_Amount,
				((CASE WHEN App_Type = 'Self' THEN Guest_Count ELSE 0 END) + (CASE WHEN App_Type = 'Guest' THEN Guest_Count ELSE 0 END)) 
				* ISNULL(T.Amount, 0) +
				((CASE WHEN App_Type = 'Self' THEN Guest_Count ELSE 0 END) + (CASE WHEN App_Type = 'Guest' THEN Guest_Count ELSE 0 END)) 
				* ISNULL(T.Subsidy_Amount, 0) AS Total
			FROM #EMPDETAILS E WITH (NOLOCK)
			INNER JOIN #TMP1 T WITH (NOLOCK) ON E.EMP_ID = T.EMP_ID 	
			ORDER BY T.DOS ASC
		),
		TotalCount AS (
			SELECT 
				0 AS EMP_ID,				
				'Total Count' AS ALPHA_EMP_CODE,
				'' AS EMP_FULL_NAME,
				'' AS BRANCH_NAME,
				'' AS DEPARTMENT,
				'' AS DESIGNATION,
				'' AS Grade_Name,
				'' AS AppNo,
				NULL AS App_Date,
				NULL AS [Date],
				'' AS Device_Name,
				'' AS Food_Type,
				NULL AS Employee_Rate,
				NULL AS Subsidy_Rate,
				@SelfCount AS Self_Count,
				@GuestCount AS Guest_Count,
				'' AS MOBILE_NO,
				@SelfAmount AS Self_Amount,
				@SelfSubAmount AS Self_Subsidy_Amount,
				@GuestAmount AS Guest_Amount,
				@GuestSubAmount AS Guest_Subsidy_Amount,
				(@SelfAmount + @GuestAmount + @SelfSubAmount + @GuestSubAmount) AS Total
		)
		SELECT * FROM (
			SELECT * FROM IndividualRecords
			UNION ALL
			SELECT * FROM TotalCount
		) AS CombinedData
		ORDER BY CASE WHEN EMP_ID = 0 THEN 1 ELSE 0 END, -- Push rows with EMP_ID = 0 to the bottom
		[Date] ASC
			--Select * From
			--(
			--	SELECT TOP 100 PERCENT E.Emp_ID,
			--	E.Alpha_Emp_Code , E.Emp_Full_Name,E.BRANCH_NAME,E.Department,E.Designation, 
			--	T.Grd_Name AS Grade_Name,T.App_No,CONVERT(VARCHAR, T.Receive_Date, 103)  as App_Date,CONVERT(VARCHAR, T.DOS, 103) as [Date],
			--	T.Device_Name,T.Canteen_Name as Food_Type,T.Amount as Employee_Rate,
			--	T.Subsidy_Amount as Subsidy_Rate,
			--	CASE WHEN App_Type = 'Self' THEN Guest_Count ELSE 0 END as Self_Count, 
			--	CASE WHEN App_Type = 'Guest' THEN Guest_Count ELSE 0 END as Guest_Count,E.Mobile_No,
			--	(CASE WHEN App_Type = 'Self' THEN Guest_Count ELSE 0 END) * ISNULL(T.Amount, 0) AS Self_Amount,
			--	(CASE WHEN App_Type = 'Self' THEN Guest_Count ELSE 0 END) * ISNULL(T.Subsidy_Amount, 0) AS Self_Subsidy_Amount,
			--	(CASE WHEN App_Type = 'Guest' THEN Guest_Count ELSE 0 END) * ISNULL(T.Amount, 0) AS Guest_Amount,
			--	(CASE WHEN App_Type = 'Guest' THEN Guest_Count ELSE 0 END) * ISNULL(T.Subsidy_Amount, 0) AS Guest_Subsidy_Amount,
			--	((CASE WHEN App_Type = 'Self' THEN Guest_Count ELSE 0 END) + (CASE WHEN App_Type = 'Guest' THEN Guest_Count ELSE 0 END)) 
			--	* ISNULL(T.Amount, 0) +
			--	((CASE WHEN App_Type = 'Self' THEN Guest_Count ELSE 0 END) + (CASE WHEN App_Type = 'Guest' THEN Guest_Count ELSE 0 END)) 
			--	* ISNULL(T.Subsidy_Amount, 0) 			
			--	AS Total
			--	FROM #EMPDETAILS E 
			--	INNER JOIN #TMP1 T ON E.EMP_ID = T.EMP_ID 	
			--	ORDER BY [Date] ASC
			--) as SubQuery

			--union all

			--SELECT 0 as EMP_ID,				
			--	'Total Count' as ALPHA_EMP_CODE,'' as EMP_FULL_NAME,'' as BRANCH_NAME,'' as DEPARTMENT,'' as DESIGNATION,
			--	'' as Grade_Name,'' as AppNo,null App_Date,null as [Date],
			--	'' as Device_Name,'' as Food_Type,NULL as Employee_Rate,
			--	NULL as Subsidy_Rate,@SelfCount as Self_Count, @GuestCount as Guest_Count,
			--	'' as MOBILE_NO,@SelfAmount as Self_Amount,@SelfSubAmount as Self_Subsidy_Amount,
			--	@GuestAmount as Guest_Amount,@GuestSubAmount as Guest_Subsidy_Amount,
			--	(@SelfAmount + @GuestAmount + @SelfSubAmount + @GuestSubAmount) as Total						
			
		end
		
		DROP TABLE #EMPDETAILS
		DROP TABLE #TMP1
		DROP TABLE #tmpSCCC
END
