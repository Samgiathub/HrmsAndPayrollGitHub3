

-- =============================================
-- Author:		Divyaraj Kiri
-- Create date: 10/04/2023
-- Description:	Get Canteen Application
-- exec P0050_CANTEEN_Report_4 120,'2023-04-01','2023-04-15','','','','','','',0,'',1
-- =============================================
CREATE PROCEDURE [dbo].[P0050_CANTEEN_Report_4] 
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
		
		DECLARE @columns nVARCHAR(MAX)
		DECLARE @query nVARCHAR(MAX)		

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
			order by C.DOS asc

			update t set
			 t.Amount = CD.Amount,t.Subsidy_Amount = CD.Subsidy_Amount
			 from #tmp1 t with (NOLOCK)
			 LEFT OUTER JOIN T0050_CANTEEN_DETAIL CD with (NOLOCK) on CD.Effective_Date = t.max_effective_date
			 and CD.Cmp_Id=t.CMP_ID and CD.Cnt_Id=t.CNT_ID AND CD.grd_id = t.Grd_ID

		--select * from #tmp1 where Emp_Id = 14560
		--return

			--DECLARE @SelfCount INT, @GuestCount INT, @SelfAmount DECIMAL(18,2), @GuestAmount DECIMAL(18,2),@SelfSubAmount decimal(18,2),@GuestSubAmount decimal(18,2)
			--Declare @Employee_Final_Total Decimal(18,2),@Guest_Final_Total Decimal(18,2)

			--SELECT 
			--@SelfCount = SUM(CASE WHEN T.App_Type = 'Self' THEN T.Guest_Count ELSE 0 END), 
			--@GuestCount = SUM(CASE WHEN T.App_Type = 'Guest' THEN T.Guest_Count ELSE 0 END),
			--@SelfAmount = SUM((CASE WHEN T.App_Type = 'Self' THEN T.Guest_Count ELSE 0 END) * ISNULL(T.Amount, 0)),
			--@SelfSubAmount = SUM((CASE WHEN T.App_Type = 'Self' THEN T.Guest_Count ELSE 0 END) * ISNULL(T.Subsidy_Amount, 0)),
			--@Employee_Final_Total = SUM((ISNULL(T.Amount, 0) * CASE WHEN T.App_Type = 'Self' THEN T.Guest_Count ELSE 0 END))
			--				+ SUM((ISNULL(T.Subsidy_Amount, 0) * CASE WHEN T.App_Type = 'Self' THEN T.Guest_Count ELSE 0 END)),
			--@Guest_Final_Total = SUM((CASE WHEN T.App_Type = 'Guest' THEN T.Guest_Count ELSE 0 END) * ISNULL(T.Amount, 0))
			
			----@GuestAmount = SUM((CASE WHEN T.App_Type = 'Guest' THEN T.Guest_Count ELSE 0 END) * ISNULL(T.Amount, 0)),
			----@GuestSubAmount = SUM((CASE WHEN T.App_Type = 'Guest' THEN T.Guest_Count ELSE 0 END) * ISNULL(T.Subsidy_Amount, 0))
			--FROM #EMPDETAILS E 
			--INNER JOIN #TMP1 T ON E.EMP_ID = T.EMP_ID	
			--Group by E.EMP_ID, E.ALPHA_EMP_CODE, E.EMP_FULL_NAME, E.BRANCH_NAME, E.DEPARTMENT, E.DESIGNATION, T.Grd_Name,
			--				T.App_Type,T.Canteen_Name

			--Select @SelfCount,@GuestCount,@SelfAmount,@SelfSubAmount,@Employee_Final_Total,@Guest_Final_Total


		if @flag = 0
		begin

			--SELECT @columns = STUFF((SELECT ',' + COALESCE(@columns + ',', '') + '[' + CAST(REPLACE(REPLACE(Canteen_Name, '[', ''), ']', '') AS NVARCHAR(MAX)) + ']'
			--	FROM (
			--		SELECT DISTINCT Canteen_Name -- Use DISTINCT within a subquery
			--		FROM #tmp1
			--		WHERE Canteen_Name <> ''
			--		--AND Emp_Id=14560
			--	) AS subquery
			--	GROUP BY Canteen_Name
			--	ORDER BY Canteen_Name -- Perform ORDER BY within the subquery
			--	FOR XML PATH(''), TYPE
			--).value('.', 'NVARCHAR(MAX)'), 1, 1, '')
			
			--SET @columns = REPLACE(@columns, ' ', '_')

			--SET @query = 'SELECT EMP_ID, ALPHA_EMP_CODE, EMP_FULL_NAME, BRANCH_NAME, DEPARTMENT, DESIGNATION, Grade, App_Type,Self_Count,Guest_Count, ' + @columns + ',
			--			Employee_Deduction, Employee_Subsidy, Employee_Final_Total, Guest_Final_Total
			--		FROM (
			--			SELECT E.EMP_ID, E.ALPHA_EMP_CODE, E.EMP_FULL_NAME, E.BRANCH_NAME, E.DEPARTMENT, E.DESIGNATION, T.Grd_Name AS Grade,
			--				T.App_Type as App_Type,
			--				SUM(CASE WHEN T.App_Type = ''Self'' THEN T.Guest_Count ELSE 0 END) AS Self_Count,				
			--				SUM(CASE WHEN T.App_Type = ''Guest'' THEN T.Guest_Count ELSE 0 END) AS Guest_Count,
			--				T.Canteen_Name,
			--				SUM(ISNULL(T.Amount, 0) * CASE WHEN T.App_Type = ''Self'' THEN T.Guest_Count ELSE 0 END) as Employee_Deduction,
			--				SUM(ISNULL(T.Subsidy_Amount, 0) * CASE WHEN T.App_Type = ''Self'' THEN T.Guest_Count ELSE 0 END) as Employee_Subsidy,
			--				SUM(ISNULL(T.Amount, 0) * CASE WHEN T.App_Type = ''Self'' THEN T.Guest_Count ELSE 0 END)
			--				+ SUM(ISNULL(T.Subsidy_Amount, 0) * CASE WHEN T.App_Type = ''Self'' THEN T.Guest_Count ELSE 0 END) as Employee_Final_Total,
			--				SUM(CASE WHEN T.App_Type = ''Guest'' THEN T.Guest_Count ELSE 0 END) * ISNULL(T.Amount, 0) as Guest_Final_Total
			--			FROM 
			--				#EMPDETAILS E 
			--			INNER JOIN 
			--				#TMP1 T ON E.EMP_ID = T.EMP_ID
			--			GROUP BY  
			--				E.EMP_ID, E.ALPHA_EMP_CODE, E.EMP_FULL_NAME, E.BRANCH_NAME, E.DEPARTMENT, E.DESIGNATION, T.Grd_Name,
			--				T.App_Type, T.Amount, T.Subsidy_Amount,T.Canteen_Name
			--		) AS PivotData
			--		PIVOT
			--		(
			--			SUM(ISNULL(Employee_Deduction, 0))
			--			FOR [Canteen_Name] IN (' + @columns + ')
			--		) AS PivotResult'	


			--PRINT 'Columns: ' + @columns
			--PRINT 'Pivot Query: ' + @query
			----PRINT @query			
			--EXEC(@query)

			--SELECT E.EMP_ID, E.ALPHA_EMP_CODE, E.EMP_FULL_NAME,E.BRANCH_NAME,E.DEPARTMENT,E.DESIGNATION,T.Grd_Name AS Grade,
			--	T.App_Type as App_Type,
			--	ISNULL(SC.Self_Count, 0) AS Self_Count,
			--	ISNULL(GC.Guest_Count, 0) AS Guest_Count,
			--	ISNULL(SC.Self_Count, 0) * ISNULL(T.Amount, 0) as Employee_Deduction,
			--	ISNULL(SC.Self_Count, 0) * ISNULL(T.Subsidy_Amount, 0) as Employee_Subsidy,
			--	((ISNULL(T.Amount, 0) + ISNULL(T.Subsidy_Amount, 0)) * ISNULL(SC.Self_Count, 0)) as Employee_Final_Total,
			--	ISNULL(GC.Guest_Count, 0) * ISNULL(T.Amount, 0) as Guest_Final_Total
			--	--,
			--	--T.Device_Name AS Canteen_Name,
			--	--T.Canteen_Name AS Food_Type,T.Amount,
			--	--T.Subsidy_Amount,				
			--	--E.MOBILE_NO,
			--	--ISNULL(SC.Self_Count, 0) * ISNULL(T.Total_Amount, 0) AS Self_Amount,
			--	--ISNULL(GC.Guest_Count, 0) * ISNULL(T.Total_Amount, 0) AS Guest_Amount,
			--	--(ISNULL(SC.Self_Count, 0) + ISNULL(GC.Guest_Count, 0)) * ISNULL(T.Total_Amount, 0) AS Total
			--FROM 
			--	#EMPDETAILS E 
			--INNER JOIN 
			--	#TMP1 T ON E.EMP_ID = T.EMP_ID
			--LEFT JOIN
			--	(SELECT EMP_ID, Device_Name, Canteen_Name, SUM(CASE WHEN App_Type = 'Self' THEN Guest_Count ELSE 0 END) AS Self_Count
			--	 FROM #TMP1				 
			--	 GROUP BY EMP_ID, Device_Name, Canteen_Name) SC ON E.EMP_ID = SC.EMP_ID AND T.Device_Name = SC.Device_Name AND T.Canteen_Name = SC.Canteen_Name
			--LEFT JOIN
			--	(SELECT EMP_ID, Device_Name, Canteen_Name, SUM(CASE WHEN App_Type = 'Guest' THEN Guest_Count ELSE 0 END) AS Guest_Count
			--	 FROM #TMP1
			--	 GROUP BY EMP_ID, Device_Name, Canteen_Name) GC ON E.EMP_ID = GC.EMP_ID AND T.Device_Name = GC.Device_Name AND T.Canteen_Name = GC.Canteen_Name
			--GROUP BY E.EMP_ID,E.ALPHA_EMP_CODE,E.EMP_FULL_NAME,E.BRANCH_NAME,E.DEPARTMENT,E.DESIGNATION,
			--T.Grd_Name,T.App_Type,SC.Self_Count,GC.Guest_Count,T.Amount,T.Subsidy_Amount
			--,T.Device_Name,T.Canteen_Name
			----,
			--	--T.Amount,T.Subsidy_Amount,T.Total_Amount,E.MOBILE_NO	

			-------------------------------------------------------------------------------------------------------------------------------

			WITH SelfSum AS (
				SELECT distinct EMP_ID,--,App_Type,Canteen_Name,
					   SUM(CASE WHEN App_Type = 'Self' THEN Guest_Count ELSE 0 END) AS Self_Count,
					   SUM(CASE WHEN App_Type = 'Self' THEN Amount ELSE 0 END) AS Self_Amount,
					   SUM(CASE WHEN App_Type = 'Self' THEN Subsidy_Amount ELSE 0 END) AS Self_Subsidy,
					   SUM(CASE WHEN App_Type = 'Guest' THEN Guest_Count ELSE 0 END) AS Guest_Count,
					   SUM(CASE WHEN App_Type = 'Guest' THEN Guest_Count * Amount ELSE 0 END) AS Guest_Final_Total
				FROM #TMP1
				GROUP BY EMP_ID--,App_Type,Canteen_Name
			)

			SELECT distinct E.EMP_ID,
				   E.ALPHA_EMP_CODE,
				   E.EMP_FULL_NAME,
				   E.BRANCH_NAME,
				   E.DEPARTMENT,
				   E.DESIGNATION,
				   T.Grd_Name AS Grade,
				   --T.App_Type AS App_Type,
				   --T.Canteen_Name,
				   COALESCE(SS.Self_Count, 0) AS Self_Count,
				   COALESCE(SS.Guest_Count, 0) AS Guest_Count,
				   COALESCE(SS.Self_Amount, 0) AS Employee_Deduction,
				   COALESCE(SS.Self_Subsidy, 0) AS Employee_Subsidy,
				   COALESCE(SS.Self_Amount, 0) + COALESCE(SS.Self_Subsidy, 0) AS Employee_Final_Total,
				   COALESCE(SS.Guest_Final_Total, 0) as Guest_Final_Total,
				   E.Mobile_No
			FROM #EMPDETAILS E
			INNER JOIN #TMP1 T ON E.EMP_ID = T.EMP_ID
			LEFT OUTER JOIN SelfSum SS ON E.EMP_ID = SS.EMP_ID --AND  T.App_Type = SS.App_Type AND T.Canteen_Name = SS.Canteen_Name
			GROUP BY E.EMP_ID, E.ALPHA_EMP_CODE, E.EMP_FULL_NAME, E.BRANCH_NAME, E.DEPARTMENT, E.DESIGNATION, 
			T.Grd_Name, T.App_Type, T.Canteen_Name, SS.Self_Count,SS.Guest_Count, SS.Self_Amount, SS.Self_Subsidy, 
			SS.Guest_Final_Total,E.Mobile_No

			--SELECT distinct E.EMP_ID, E.ALPHA_EMP_CODE, E.EMP_FULL_NAME, E.BRANCH_NAME, E.DEPARTMENT, E.DESIGNATION, T.Grd_Name AS Grade,
			--				T.App_Type as App_Type,T.Canteen_Name,
			--				SUM(CASE WHEN T.App_Type = 'Self' THEN T.Guest_Count ELSE 0 END) AS Self_Count,				
			--				SUM(CASE WHEN T.App_Type = 'Guest' THEN T.Guest_Count ELSE 0 END) AS Guest_Count,														
			--				SUM(ISNULL(T.Amount, 0) * CASE WHEN T.App_Type = 'Self' THEN T.Guest_Count ELSE 0 END) as Employee_Deduction,
			--				SUM(ISNULL(T.Subsidy_Amount, 0) * CASE WHEN T.App_Type = 'Self' THEN T.Guest_Count ELSE 0 END) as Employee_Subsidy,
			--				SUM(ISNULL(T.Amount, 0) * CASE WHEN T.App_Type = 'Self' THEN T.Guest_Count ELSE 0 END)
			--				+ SUM(ISNULL(T.Subsidy_Amount, 0) * CASE WHEN T.App_Type = 'Self' THEN T.Guest_Count ELSE 0 END) as Employee_Final_Total,
			--				SUM(CASE WHEN T.App_Type = 'Guest' THEN T.Guest_Count ELSE 0 END) * ISNULL(T.Amount, 0) as Guest_Final_Total,E.Mobile_No
			--			FROM 
			--				#EMPDETAILS E 
			--			INNER JOIN 
			--				#TMP1 T ON E.EMP_ID = T.EMP_ID						
			--			GROUP BY  
			--				E.EMP_ID, E.ALPHA_EMP_CODE, E.EMP_FULL_NAME, E.BRANCH_NAME, E.DEPARTMENT, E.DESIGNATION, T.Grd_Name,
			--				T.App_Type,T.Canteen_Name,T.Amount, T.Subsidy_Amount,E.Mobile_No--, T.Subsidy_Amount

			--return
		end
		else if @flag = 1
		begin

			WITH SelfSum AS (
				SELECT distinct EMP_ID,--,App_Type,Canteen_Name,
					   SUM(CASE WHEN App_Type = 'Self' THEN Guest_Count ELSE 0 END) AS Self_Count,
					   SUM(CASE WHEN App_Type = 'Self' THEN Amount ELSE 0 END) AS Self_Amount,
					   SUM(CASE WHEN App_Type = 'Self' THEN Subsidy_Amount ELSE 0 END) AS Self_Subsidy,
					   SUM(CASE WHEN App_Type = 'Guest' THEN Guest_Count ELSE 0 END) AS Guest_Count,
					   SUM(CASE WHEN App_Type = 'Guest' THEN Guest_Count * Amount ELSE 0 END) AS Guest_Final_Total
				FROM #TMP1
				GROUP BY EMP_ID--,App_Type,Canteen_Name
			)

			SELECT distinct E.EMP_ID,
				   E.ALPHA_EMP_CODE,
				   E.EMP_FULL_NAME,
				   E.BRANCH_NAME,
				   E.DEPARTMENT,
				   E.DESIGNATION,
				   T.Grd_Name AS Grade,
				   --T.App_Type AS App_Type,
				   --T.Canteen_Name,
				   COALESCE(SS.Self_Count, 0) AS Self_Count,
				   COALESCE(SS.Guest_Count, 0) AS Guest_Count,
				   COALESCE(SS.Self_Amount, 0) AS Employee_Deduction,
				   COALESCE(SS.Self_Subsidy, 0) AS Employee_Subsidy,
				   COALESCE(SS.Self_Amount, 0) + COALESCE(SS.Self_Subsidy, 0) AS Employee_Final_Total,
				   COALESCE(SS.Guest_Final_Total, 0) as Guest_Final_Total,
				   E.Mobile_No
			FROM #EMPDETAILS E
			INNER JOIN #TMP1 T ON E.EMP_ID = T.EMP_ID
			LEFT OUTER JOIN SelfSum SS ON E.EMP_ID = SS.EMP_ID-- AND  T.App_Type = SS.App_Type AND T.Canteen_Name = SS.Canteen_Name
			GROUP BY E.EMP_ID, E.ALPHA_EMP_CODE, E.EMP_FULL_NAME, E.BRANCH_NAME, E.DEPARTMENT, E.DESIGNATION, 
			T.Grd_Name, T.App_Type, T.Canteen_Name, SS.Self_Count,SS.Guest_Count, SS.Self_Amount, SS.Self_Subsidy, 
			SS.Guest_Final_Total,E.Mobile_No

			UNION ALL

			SELECT 
				NULL AS EMP_ID,                
				'Total' AS ALPHA_EMP_CODE,
				'' AS EMP_FULL_NAME,
				'' AS BRANCH_NAME,
				'' AS DEPARTMENT,
				'' AS DESIGNATION,
				'' AS Grade,
				--'' as App_Type,
				--'' AS Canteen_Name,
				SUM(CASE WHEN T.App_Type = 'Self' THEN T.Guest_Count ELSE 0 END) AS Self_Count,                
				SUM(CASE WHEN T.App_Type = 'Guest' THEN T.Guest_Count ELSE 0 END) AS Guest_Count,				
				SUM((ISNULL(T.Amount, 0) * CASE WHEN T.App_Type = 'Self' THEN T.Guest_Count ELSE 0 END)) as Employee_Deduction,
				SUM((ISNULL(T.Subsidy_Amount, 0) * CASE WHEN T.App_Type = 'Self' THEN T.Guest_Count ELSE 0 END)) as Employee_Subsidy,
				SUM((ISNULL(T.Amount, 0) * CASE WHEN T.App_Type = 'Self' THEN T.Guest_Count ELSE 0 END))
				+ SUM((ISNULL(T.Subsidy_Amount, 0) * CASE WHEN T.App_Type = 'Self' THEN T.Guest_Count ELSE 0 END)) as Employee_Final_Total,
				SUM((CASE WHEN T.App_Type = 'Guest' THEN T.Guest_Count ELSE 0 END) * ISNULL(T.Amount, 0)) as Guest_Final_Total,
				'' as Mobile_No
			FROM 
				#EMPDETAILS E 
			INNER JOIN 
				#TMP1 T ON E.EMP_ID = T.EMP_ID
			--Group by T.Amount,T.Subsidy_Amount

			--DECLARE @SelfCount INT, @GuestCount INT, @SelfAmount DECIMAL(18,2), @GuestAmount DECIMAL(18,2),@SelfSubAmount decimal(18,2),@GuestSubAmount decimal(18,2)
			--Declare @Employee_Final_Total Decimal(18,2),@Guest_Final_Total Decimal(18,2)

			--SELECT 
			--@SelfCount = SUM(CASE WHEN T.App_Type = 'Self' THEN T.Guest_Count ELSE 0 END), 
			--@GuestCount = SUM(CASE WHEN T.App_Type = 'Guest' THEN T.Guest_Count ELSE 0 END),
			--@SelfAmount = SUM((CASE WHEN T.App_Type = 'Self' THEN T.Guest_Count ELSE 0 END) * ISNULL(T.Amount, 0)),
			--@SelfSubAmount = SUM((CASE WHEN T.App_Type = 'Self' THEN T.Guest_Count ELSE 0 END) * ISNULL(T.Subsidy_Amount, 0)),
			--@Employee_Final_Total = SUM((ISNULL(T.Amount, 0) * CASE WHEN T.App_Type = 'Self' THEN T.Guest_Count ELSE 0 END))
			--				+ SUM((ISNULL(T.Subsidy_Amount, 0) * CASE WHEN T.App_Type = 'Self' THEN T.Guest_Count ELSE 0 END)),
			--@Guest_Final_Total = SUM((CASE WHEN T.App_Type = 'Guest' THEN T.Guest_Count ELSE 0 END) * ISNULL(T.Amount, 0))
			
			----@GuestAmount = SUM((CASE WHEN T.App_Type = 'Guest' THEN T.Guest_Count ELSE 0 END) * ISNULL(T.Amount, 0)),
			----@GuestSubAmount = SUM((CASE WHEN T.App_Type = 'Guest' THEN T.Guest_Count ELSE 0 END) * ISNULL(T.Subsidy_Amount, 0))
			--FROM #EMPDETAILS E 
			--INNER JOIN #TMP1 T ON E.EMP_ID = T.EMP_ID	
			--Group by T.Amount,T.Subsidy_Amount,T.App_Type,T.Guest_Count

			----Select @SelfCount,@GuestCount,@SelfAmount,@SelfSubAmount,@Employee_Final_Total,@Guest_Final_Total
			
			--SELECT E.EMP_ID, E.ALPHA_EMP_CODE, E.EMP_FULL_NAME, E.BRANCH_NAME, E.DEPARTMENT, E.DESIGNATION, T.Grd_Name AS Grade,
			--				T.App_Type as App_Type,
			--				SUM(CASE WHEN T.App_Type = 'Self' THEN T.Guest_Count ELSE 0 END) AS Self_Count,				
			--				SUM(CASE WHEN T.App_Type = 'Guest' THEN T.Guest_Count ELSE 0 END) AS Guest_Count,
			--				T.Canteen_Name,
			--				SUM(ISNULL(T.Amount, 0) * CASE WHEN T.App_Type = 'Self' THEN T.Guest_Count ELSE 0 END) as Employee_Deduction,
			--				SUM(ISNULL(T.Subsidy_Amount, 0) * CASE WHEN T.App_Type = 'Self' THEN T.Guest_Count ELSE 0 END) as Employee_Subsidy,
			--				SUM(ISNULL(T.Amount, 0) * CASE WHEN T.App_Type = 'Self' THEN T.Guest_Count ELSE 0 END)
			--				+ SUM(ISNULL(T.Subsidy_Amount, 0) * CASE WHEN T.App_Type = 'Self' THEN T.Guest_Count ELSE 0 END) as Employee_Final_Total,
			--				SUM(CASE WHEN T.App_Type = 'Guest' THEN T.Guest_Count ELSE 0 END) * ISNULL(T.Amount, 0) as Guest_Final_Total
			--			FROM 
			--				#EMPDETAILS E 
			--			INNER JOIN 
			--				#TMP1 T ON E.EMP_ID = T.EMP_ID
			--			GROUP BY  
			--				E.EMP_ID, E.ALPHA_EMP_CODE, E.EMP_FULL_NAME, E.BRANCH_NAME, E.DEPARTMENT, E.DESIGNATION, T.Grd_Name,
			--				T.App_Type,T.Amount,T.Subsidy_Amount,T.Canteen_Name
			--UNION ALL
			--SELECT 
			--				0 AS EMP_ID,				
			--				'Total' AS ALPHA_EMP_CODE,
			--				'' AS EMP_FULL_NAME,
			--				'' AS BRANCH_NAME,
			--				'' AS DEPARTMENT,
			--				'' AS DESIGNATION,
			--				'' AS Grade,
			--				'' as App_Type,
			--				@SelfCount AS Self_Count,
			--				@GuestCount AS Guest_Count,
			--				'' AS Canteen_Name,
			--				@SelfAmount AS Employee_Deduction,
			--				@SelfSubAmount AS Employee_Subsidy,
			--				@Employee_Final_Total AS Employee_Final_Total,
			--				@Guest_Final_Total AS Guest_Final_Total
			--	--Group by T.Amount
			--				--,(@SelfAmount + @SelfSubAmount + @Employee_Final_Total + @Guest_Final_Total) AS Total
			--return
		--	;WITH IndividualRecords AS (
		--	SELECT E.EMP_ID, E.ALPHA_EMP_CODE, E.EMP_FULL_NAME, E.BRANCH_NAME, E.DEPARTMENT, E.DESIGNATION, T.Grd_Name AS Grade,
		--					T.App_Type as App_Type,
		--					SUM(CASE WHEN T.App_Type = 'Self' THEN T.Guest_Count ELSE 0 END) AS Self_Count,				
		--					SUM(CASE WHEN T.App_Type = 'Guest' THEN T.Guest_Count ELSE 0 END) AS Guest_Count,
		--					T.Canteen_Name,
		--					SUM(ISNULL(T.Amount, 0) * CASE WHEN T.App_Type = 'Self' THEN T.Guest_Count ELSE 0 END) as Employee_Deduction,
		--					SUM(ISNULL(T.Subsidy_Amount, 0) * CASE WHEN T.App_Type = 'Self' THEN T.Guest_Count ELSE 0 END) as Employee_Subsidy,
		--					SUM(ISNULL(T.Amount, 0) * CASE WHEN T.App_Type = 'Self' THEN T.Guest_Count ELSE 0 END)
		--					+ SUM(ISNULL(T.Subsidy_Amount, 0) * CASE WHEN T.App_Type = 'Self' THEN T.Guest_Count ELSE 0 END) as Employee_Final_Total,
		--					SUM(CASE WHEN T.App_Type = 'Guest' THEN T.Guest_Count ELSE 0 END) * ISNULL(T.Amount, 0) as Guest_Final_Total
		--				FROM 
		--					#EMPDETAILS E 
		--				INNER JOIN 
		--					#TMP1 T ON E.EMP_ID = T.EMP_ID
		--				GROUP BY  
		--					E.EMP_ID, E.ALPHA_EMP_CODE, E.EMP_FULL_NAME, E.BRANCH_NAME, E.DEPARTMENT, E.DESIGNATION, T.Grd_Name,
		--					T.App_Type, T.Amount, T.Subsidy_Amount,T.Canteen_Name
		--),
		--TotalCount AS (
		--	SELECT 
		--		0 AS EMP_ID,				
		--		'Total Count' AS ALPHA_EMP_CODE,
		--		'' AS EMP_FULL_NAME,
		--		'' AS BRANCH_NAME,
		--		'' AS DEPARTMENT,
		--		'' AS DESIGNATION,
		--		'' AS Grade,
		--		'' as App_Type,
		--		@SelfCount AS Self_Count,
		--		@GuestCount AS Guest_Count,
		--		'' AS Canteen_Name,
		--		@SelfAmount AS Employee_Deduction,
		--		@SelfSubAmount AS Employee_Subsidy,
		--		@Employee_Final_Total AS Employee_Final_Total,
		--		@Guest_Final_Total AS Guest_Final_Total,
		--		(@SelfAmount + @SelfSubAmount + @Employee_Final_Total + @Guest_Final_Total) AS Total
		--)
		--SELECT * FROM (
		--	SELECT * FROM IndividualRecords
		--	UNION ALL
		--	SELECT * FROM TotalCount
		--) AS CombinedData
		--ORDER BY CASE WHEN EMP_ID = 0 THEN 1 ELSE 0 END
		--, [Date] ASC-- Push rows with EMP_ID = 0 to the bottom
		
			
			--DECLARE @SelfCount INT, @GuestCount INT, @SelfAmount DECIMAL(18,2), @GuestAmount DECIMAL(18,2)

			---- Calculate Self_Count, Guest_Count, Self_Amount, and Guest_Amount
			--SELECT 
			--	@SelfCount = SUM(ISNULL(SC.Self_Count, 0)),
			--	@GuestCount = SUM(ISNULL(GC.Guest_Count, 0)),
			--	@SelfAmount = SUM(ISNULL(SC.Self_Amount, 0)),
			--	@GuestAmount = SUM(ISNULL(GC.Guest_Amount, 0))
			--FROM 
			--	(SELECT DISTINCT EMP_ID FROM #EMPDETAILS) E
			--LEFT JOIN (
			--	SELECT 
			--		EMP_ID, 
			--		SUM(CASE WHEN App_Type = 'Self' THEN Guest_Count ELSE 0 END) AS Self_Count,
			--		SUM(CASE WHEN App_Type = 'Self' THEN Guest_Count * T.Total_Amount ELSE 0 END) AS Self_Amount
			--	FROM 
			--		#TMP1 T
			--	WHERE 
			--		Cmp_Id = @Cmp_ID AND
			--		(CONVERT(varchar, From_Date, 112) BETWEEN CONVERT(varchar, @From_Date, 112) AND CONVERT(varchar, @To_Date, 112))
			--		OR (CONVERT(varchar, @From_Date, 112) BETWEEN CONVERT(varchar, From_Date, 112) AND CONVERT(varchar, To_Date, 112))
			--	GROUP BY 
			--		EMP_ID
			--) SC ON E.EMP_ID = SC.EMP_ID
			--LEFT JOIN (
			--	SELECT 
			--		EMP_ID, 
			--		SUM(CASE WHEN App_Type = 'Guest' THEN Guest_Count ELSE 0 END) AS Guest_Count,
			--		SUM(CASE WHEN App_Type = 'Guest' THEN Guest_Count * T.Total_Amount ELSE 0 END) AS Guest_Amount
			--	FROM 
			--		#TMP1 T
			--	WHERE 
			--		Cmp_Id = @Cmp_ID AND
			--		(CONVERT(varchar, From_Date, 112) BETWEEN CONVERT(varchar, @From_Date, 112) AND CONVERT(varchar, @To_Date, 112))
			--		OR (CONVERT(varchar, @From_Date, 112) BETWEEN CONVERT(varchar, From_Date, 112) AND CONVERT(varchar, To_Date, 112))
			--	GROUP BY 
			--		EMP_ID
			--) GC ON E.EMP_ID = GC.EMP_ID

			---- Main Query
			--SELECT Distinct
			--	E.EMP_ID, E.ALPHA_EMP_CODE, E.EMP_FULL_NAME, E.BRANCH_NAME, E.DEPARTMENT, E.DESIGNATION,
			--	T.Device_Name AS Canteen_Name, T.Cnt_Name AS Food_Type, T.Grd_Name AS Grade_Name, T.Amount,
			--	T.Subsidy_Amount,T.Total_Amount,
			--	ISNULL(SC.Self_Count, 0) AS Self_Count,
			--	ISNULL(GC.Guest_Count, 0) AS Guest_Count,
			--	E.MOBILE_NO,
			--	ISNULL(SC.Self_Amount, 0) AS Self_Amount,
			--	ISNULL(GC.Guest_Amount, 0) AS Guest_Amount,
			--	(ISNULL(SC.Self_Amount, 0) + ISNULL(GC.Guest_Amount, 0)) AS Total
			--FROM 
			--	#EMPDETAILS E 
			--INNER JOIN 
			--	#TMP1 T ON E.EMP_ID = T.EMP_ID
			--LEFT JOIN (
			--	SELECT 
			--		EMP_ID,Device_Name, Cnt_Name, 
			--		SUM(CASE WHEN App_Type = 'Self' THEN Guest_Count ELSE 0 END) AS Self_Count,
			--		SUM(CASE WHEN App_Type = 'Self' THEN Guest_Count * T.Total_Amount ELSE 0 END) AS Self_Amount
			--	FROM 
			--		#TMP1 T
			--	WHERE 
			--		Cmp_Id = @Cmp_ID AND
			--		(CONVERT(varchar, From_Date, 112) BETWEEN CONVERT(varchar, @From_Date, 112) AND CONVERT(varchar, @To_Date, 112))
			--		OR (CONVERT(varchar, @From_Date, 112) BETWEEN CONVERT(varchar, From_Date, 112) AND CONVERT(varchar, To_Date, 112))
			--	GROUP BY 
			--		EMP_ID, Device_Name, Cnt_Name
			--) SC ON E.EMP_ID = SC.EMP_ID AND T.Device_Name = SC.Device_Name AND T.Cnt_Name = SC.Cnt_Name
			--LEFT JOIN (
			--	SELECT 
			--		EMP_ID,Device_Name, Cnt_Name,
			--		SUM(CASE WHEN App_Type = 'Guest' THEN Guest_Count ELSE 0 END) AS Guest_Count,
			--		SUM(CASE WHEN App_Type = 'Guest' THEN Guest_Count * T.Total_Amount ELSE 0 END) AS Guest_Amount
			--	FROM 
			--		#TMP1 T
			--	WHERE 
			--		Cmp_Id = @Cmp_ID AND
			--		(CONVERT(varchar, From_Date, 112) BETWEEN CONVERT(varchar, @From_Date, 112) AND CONVERT(varchar, @To_Date, 112))
			--		OR (CONVERT(varchar, @From_Date, 112) BETWEEN CONVERT(varchar, From_Date, 112) AND CONVERT(varchar, To_Date, 112))
			--	GROUP BY 
			--		EMP_ID, Device_Name, Cnt_Name
			--) GC ON E.EMP_ID = GC.EMP_ID AND T.Device_Name = GC.Device_Name AND T.Cnt_Name = GC.Cnt_Name

			--UNION ALL

			---- Total row
			--SELECT 
			--	0 as EMP_ID, 
			--	'Total Count' as ALPHA_EMP_CODE,
			--	'' as EMP_FULL_NAME,
			--	'' as BRANCH_NAME,
			--	'' as DEPARTMENT,
			--	'' as DESIGNATION,
			--	'' as Canteen_Name,
			--	'' as Food_Type,
			--	'' as Grade_Name,
			--	NULL as Amount,
			--	NUll as Subsidy_Amount,
			--	NUll as Total_Amount,
			--	@SelfCount as Self_Count, 
			--	@GuestCount as Guest_Count,
			--	'' as MOBILE_NO,
			--	@SelfAmount as Self_Amount,
			--	@GuestAmount as Guest_Amount,
			--	(@SelfAmount + @GuestAmount) as Total			

		end

		

		DROP TABLE #EMPDETAILS
		DROP TABLE #TMP1
		DROP TABLE #tmpSCCC

END
