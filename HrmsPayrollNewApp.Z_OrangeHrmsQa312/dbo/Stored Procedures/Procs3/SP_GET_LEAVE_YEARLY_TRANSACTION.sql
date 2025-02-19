

/*-Added by Sumit on 18022017--------------------------------*/
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_GET_LEAVE_YEARLY_TRANSACTION]	
	@Company_id		Numeric  
	,@From_Date		Datetime
	,@To_Date 		Datetime
	,@Branch_ID		varchar(max)	
	,@Grade_ID 		varchar(max)
	,@Type_ID 		varchar(max)
	,@Dept_ID 		varchar(max)
	,@Desig_ID 		varchar(max)
	,@Emp_ID 		Numeric
	,@Constraint	Varchar(max)
	,@Cat_ID        varchar(max)		
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	

	IF @Branch_ID = 0  
		set @Branch_ID = null
		
	IF @Cat_ID = 0  
		set @Cat_ID = null

	IF @Grade_ID = 0  
		set @Grade_ID = null

	IF @Type_ID = 0  
		set @Type_ID = null

	IF @Dept_ID = 0  
		set @Dept_ID = null

	IF @Desig_ID = 0  
		set @Desig_ID = null

	IF @Emp_ID = 0  
		set @Emp_ID = null	


	CREATE table #Emp_Cons 
	(      
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC
	)	
	EXEC SP_RPT_FILL_EMP_CONS  @Company_id,@FROM_DATE,@TO_DATE,@BRANCH_ID,0,@Grade_ID,@TYPE_ID,@DEPT_ID,@DESIG_ID ,@EMP_ID ,@CONSTRAINT 
	
	
	IF OBJECT_ID('tempdb..#LEAVESUMMARY') is null
			Begin
				CREATE TABLE #LEAVESUMMARY
				(
					EMP_ID NUMERIC(18,0),
					CMP_ID NUMERIC(18,0),
					LEAVE_ID NUMERIC(18,0),
					LEAVE_NAME VARCHAR(50),
					LEAVE_VALUE NUMERIC(18,2),
					GROUP_NAME VARCHAR(50),
					StartDate datetime,
					Group_SORT_ID NUMERIC(18,0)
				)
			End
	IF OBJECT_ID('tempdb..#LEAVE') is null
			Begin
				CREATE TABLE #LEAVE
				(					
					LEAVE_ID NUMERIC(18,0),
					LEAVE_NAME VARCHAR(50),
					SORT_ID NUMERIC(18,0)
				)
			End	
			
			insert into #LEAVE
					select		top 5 Leave_ID,isnull(Leave_Code,Leave_Name),Leave_Sorting_No
					from		T0040_LEAVE_MASTER WITH (NOLOCK)
					where		Leave_Status=1 and Cmp_ID=@Company_id and Display_leave_balance=1
					order by	Leave_Sorting_No asc

	
	
			CREATE TABLE #DATES 
				(
					MonthStartDate DATETIME
				)
					;with cte as (
								  select convert(date,left(convert(varchar,@From_Date,112),6) + '01') startDate,
										 month(@From_Date) n
								  union all
								  select dateadd(month,n,convert(date,convert(varchar,year(@From_Date)) + '0101')) startDate,
										(n+1) n
								  from cte
								  where n < month(@From_Date) + datediff(month,@From_Date,@To_Date)
								)
			
			INSERT INTO #DATES
			SELECT startDate from cte option (maxrecursion 0);
			
			
			insert into #LEAVESUMMARY			
					select		E.Emp_ID,@Company_id,LM.Leave_ID,'OB_' + lm.Leave_Name ,0,
								'Opening Balance',
								GETDATE(),0
					from		#Emp_Cons E 								
								cross join 
								#LEAVE LM
					order by lm.SORT_ID asc
			
		
			insert into #LEAVESUMMARY			
					select		E.Emp_ID,@Company_id,LM.Leave_ID, ('Mnth_' + LEFT(dbo.F_GET_MONTH_NAME(MONTH(MonthStartDate)), 3) + '--' + cast(YEAR(MonthStartDate) as varchar(25)) + '$' + Lm.Leave_Name) ,0,
								 LEFT(dbo.F_GET_MONTH_NAME(MONTH(MonthStartDate)), 3) + '--' + cast(YEAR(MonthStartDate) as varchar(25)) as Months ,								 
								D.MonthStartDate,1
					from		#DATES D
								cross join #Emp_Cons E 
								cross join
								#LEAVE LM								
					order by D.MonthStartDate asc,lm.SORT_ID  asc
					
					
			insert into #LEAVESUMMARY			
					select		E.Emp_ID,@Company_id,LM.Leave_ID,'AV_' + lm.Leave_Name ,0,
								'Availed Balance',
								GETDATE(),2
					from		#Emp_Cons E 								
								cross join 
								#LEAVE LM								
					order by lm.SORT_ID asc
					
					
			insert into #LEAVESUMMARY			
					select		E.Emp_ID,@Company_id,LM.Leave_ID,'CL_' + lm.Leave_Name ,0,
								'Closing Balance',
								GETDATE(),3
					from		#Emp_Cons E 								
								cross join 
								#LEAVE LM								
					order by lm.SORT_ID asc
		
		--For Regular Employee
		--update L set L.LEAVE_VALUE=(LT.Leave_Opening + IsNull(LT.Leave_Credit,0) - IsNull(LT.Leave_Used,0) - IsNull(LT.Leave_Adj_L_Mark,0) - Isnull(Leave_Encash_Days,0))  --Changed By Jimit 30092019 as Leave Encashment value not deduct from balance so opening balance is coming wrong deepak nitrate case 
		--			from #LEAVESUMMARY L					
		--			inner join T0140_Leave_Transaction LT on LT.Leave_ID =L.LEAVE_ID and LT.Emp_ID=L.EMP_ID
		--			inner join 
		--				( select MAX(LT.For_Date) as ForDate,LT.Leave_ID,LT.Emp_ID from 
		--						T0140_LEAVE_TRANSACTION LT 							
		--							INNER JOIN (SELECT 	MAX(FOR_DATE) AS FOR_DATE,LT1.Leave_ID,LT1.Emp_ID
		--										FROM 	T0140_LEAVE_TRANSACTION LT1
		--										WHERE	--Leave_Posting IS NOT NULL AND
		--												For_Date<=@From_Date 
		--										group by LT1.Leave_ID,lt1.Emp_ID
		--										) LT1 ON LT.LEAVE_ID=LT1.LEAVE_ID AND LT.EMP_ID=LT1.EMP_ID AND LT.FOR_DATE >= LT1.FOR_DATE
		--						where LT.For_Date<=@From_Date 
		--						group by LT.Leave_ID,LT.Emp_ID
		--				)Qry ON Qry.Emp_ID=L.EMP_ID and QRy.Leave_ID=L.LEAVE_ID and LT.For_Date=Qry.ForDate
		--			where GROUP_NAME ='Opening Balance' --and LT.Leave_Opening <> 0
				
			---Changed By Jimit 30092019 as Leave Opening Balance is not coming correct	
			UPDATE	LB
			SET		LEAVE_VALUE = Leave_Bal.Leave_Closing  
			From	#LEAVESUMMARY LB 
					INNER JOIN (SELECT	LT.Leave_ID,LT.Emp_ID,(Leave_Opening + Leave_Credit) - (Leave_Used + Isnull(Leave_Adj_L_Mark,0)+ Isnull(Leave_Encash_Days,0) + Isnull(Back_Dated_Leave,0) + Isnull(Arrear_Used,0)+Isnull(CF_Laps_Days,0)) as Leave_Closing
								From	T0140_leave_Transaction LT WITH (NOLOCK)
										INNER JOIN (SELECT	MAX(For_Date) For_Date, T.Emp_ID ,Leave_ID 
													FROM	T0140_Leave_Transaction T WITH (NOLOCK)
															INNER JOIN #Emp_Cons EC ON T.Emp_ID=EC.Emp_ID
													WHERE	For_date <= @From_Date  AND Cmp_ID = @Company_id
													Group by T.Emp_ID ,Leave_ID) Q ON LT.Emp_Id = Q.Emp_ID AND LT.For_Date = Q.For_Date AND LT.Leave_ID = Q.Leave_ID  
								)Leave_Bal ON LB.Leave_ID = Leave_Bal.Leave_ID AND LB.Emp_ID = Leave_Bal.Emp_ID
			Where	GROUP_NAME ='Opening Balance' 
			
			--Take if Opening is Given
			UPDATE	LB
			SET		LEAVE_VALUE = Leave_Bal.Leave_Opening  
			From	#LEAVESUMMARY LB 
					INNER JOIN (SELECT	LT.Leave_ID,LT.Emp_ID,LT.Leave_Opening 
								From	T0140_leave_Transaction LT WITH (NOLOCK)
										INNER JOIN (SELECT	MAX(For_Date) For_Date, T.Emp_ID ,Leave_ID 
													FROM	T0140_Leave_Transaction T WITH (NOLOCK)
															INNER JOIN #Emp_Cons EC ON T.Emp_ID=EC.Emp_ID
													WHERE	For_date = @From_Date  AND Cmp_ID = @Company_id
													Group by T.Emp_ID ,Leave_ID) Q ON LT.Emp_Id = Q.Emp_ID AND LT.For_Date = Q.For_Date AND LT.Leave_ID = Q.Leave_ID  
								)Leave_Bal ON LB.Leave_ID = Leave_Bal.Leave_ID AND LB.Emp_ID = Leave_Bal.Emp_ID
			Where	GROUP_NAME ='Opening Balance' 			
		--Ended


		--For Mid Year Join Employee
		update L set L.LEAVE_VALUE=LT.Leave_Opening
					from #LEAVESUMMARY L					
					inner join T0140_Leave_Transaction LT on LT.Leave_ID =L.LEAVE_ID and LT.Emp_ID=L.EMP_ID
					inner join 
						( select MIN(For_Date) as ForDate,LT.Leave_ID,Emp_ID from 
								T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)							
								where For_Date BETWEEN @FROM_DATE AND @TO_DATE
										AND lt.Leave_Opening > 0
								group by LT.Leave_ID,Emp_ID
						)Qry ON Qry.Emp_ID=L.EMP_ID and QRy.Leave_ID=L.LEAVE_ID and LT.For_Date=Qry.ForDate
					where GROUP_NAME ='Opening Balance' AND L.LEAVE_VALUE = 0 --and LT.Leave_Opening <> 0
							AND NOT EXISTS(SELECT 1 FROM T0140_Leave_Transaction LT2 WITH (NOLOCK)
											WHERE LT2.EMP_ID=LT.EMP_ID AND LT2.LEAVE_ID=LT.LEAVE_ID 
													AND LT2.FOR_DATE < LT.FOR_DATE AND LT2.FOR_DATE >= @FROM_DATE
													AND (ISNULL(LT2.LEAVE_USED,0) + ISNULL(LT2.LEAVE_CREDIT,0) + ISNULL(LT2.Leave_Adj_L_Mark,0)) > 0)
							
					
					
		update L set L.LEAVE_VALUE=Qry.LeaveUsed
					from #LEAVESUMMARY L
					Inner JOIN 
						( select sum(Lt.Leave_Used) as LeaveUsed,LT.Leave_ID,Emp_ID
							,MONTH(For_Date) as Mnth, YEAR(For_Date) as Yr from 
							T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
							group by LT.Leave_ID,Emp_ID,MONTH(For_Date),YEAR(For_Date)						
						)Qry ON Qry.Emp_ID=L.EMP_ID and QRy.Leave_ID=L.LEAVE_ID 
						and MONTH(L.StartDate)=Qry.Mnth and YEAR(L.StartDate)=Qry.Yr
						where GROUP_NAME <> 'Opening Balance' and GROUP_NAME <> 'Availed Balance' 
							and GROUP_NAME <> 'Closing Balance'
						
		
		
		update L set L.LEAVE_VALUE=Qry.LeaveUsed
					from #LEAVESUMMARY L
					Inner JOIN 
					( select sum(Lt.Leave_Used) as LeaveUsed,LT.Leave_ID,Emp_ID from 
							T0140_LEAVE_TRANSACTION LT 	WITH (NOLOCK)						
							where For_Date >= @From_Date and For_Date <= @To_Date
							group by LT.Leave_ID,Emp_ID							
					)Qry ON Qry.Emp_ID=L.EMP_ID and QRy.Leave_ID=L.LEAVE_ID
					where GROUP_NAME = 'Availed Balance'
					
		update L set L.LEAVE_VALUE= LT.Leave_Closing
					from #LEAVESUMMARY L
					inner join T0140_Leave_Transaction LT WITH (NOLOCK) on LT.Leave_ID =L.LEAVE_ID and LT.Emp_ID=L.EMP_ID
					inner join
							( select Max(For_Date) as ForDate,LT.Leave_ID,Emp_ID from 
									T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)							
									where For_Date <= @To_Date
									group by LT.Leave_ID,Emp_ID
							)Qry ON Qry.Emp_ID=L.EMP_ID and QRy.Leave_ID=L.LEAVE_ID and LT.For_Date=Qry.ForDate
					where GROUP_NAME = 'Closing Balance'
			
		

			DECLARE @DynamicQuery AS NVARCHAR(MAX)
			DECLARE @ColumnName AS NVARCHAR(MAX)
			
			IF OBJECT_ID('tempdb..##TMPDATALEAVE') IS NOT NULL 
				Begin
					DROP TABLE ##TMPDATALEAVE
				End
						
			SET @ColumnName = NULL;
			DECLARE @Display_Cols Varchar(max);
			
			SELECT	@ColumnName = COALESCE(@ColumnName + ',','') + '[' + LEAVE_NAME + ']',
					@Display_Cols = COALESCE(@Display_Cols + ',','') + '[' + LEAVE_NAME + '] AS [' + LEAVE_NAME + ']'
			FROM	(
						SELECT		Distinct Group_SORT_ID,StartDate,LS.LEAVE_NAME,L.SORT_ID 
						FROM #LEAVESUMMARY LS inner join #LEAVE L on LS.LEAVE_ID=L.LEAVE_ID
					) T
			ORDER BY Group_SORT_ID,StartDate,SORT_ID
			
			
			
        	SET @DynamicQuery = N'SELECT Emp_ID, ' + @Display_Cols + ' into  ##TMPDATALEAVE
				FROM (
						SELECT L.EMP_ID, L.LEAVE_VALUE,Leave_Name
						FROM #LEAVESUMMARY L
					 ) AS PVT
				PIVOT(
						SUM(LEAVE_VALUE) 
						FOR Leave_Name IN (' + @ColumnName + ')
				)  AS PvtLeave '							
						
			exec (@DynamicQuery);
	
	/*-If you Add any column in Select statment then you have to change some code in report customize form as reducing column number inside code------------------------*/
	
		if object_ID('tempdb..##TMPDATALEAVE') is not null
			Begin 
					SELECT '="' + EM.Alpha_Emp_Code + '"' as [Employee Code],EM.Emp_Full_Name as [Employee Name],convert(varchar(12),EM.Date_Of_Join,103) as [Date of Join],isnull(DM.Dept_Name,'') as [Department]
					,isnull(VS.Vertical_Name,'') as [Vertical Name],isnull(DSM.Desig_Name,'') as [Designation Name],isnull(bs.Segment_Name,'') as [Segment Name]
					,TD.* FROM ##TMPDATALEAVE TD 
					inner join #Emp_Cons E on TD.Emp_ID=E.Emp_ID
					inner join T0080_EMP_MASTER EM WITH (NOLOCK) on EM.Emp_ID=E.Emp_ID
					inner join T0095_INCREMENT I WITH (NOLOCK) on I.Increment_ID=E.Increment_ID and I.Emp_ID=E.Emp_ID
					left join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on DM.Dept_Id=I.Dept_ID
					left join T0030_BRANCH_MASTER BM WITH (NOLOCK) on BM.Branch_ID=I.Branch_ID
					left join T0040_DESIGNATION_MASTER DSM WITH (NOLOCK) on DSM.Desig_ID=I.Desig_Id
					left join T0040_Business_Segment BS WITH (NOLOCK)on BS.Segment_ID=I.Segment_ID
					left join T0040_Vertical_Segment VS WITH (NOLOCK) on VS.Vertical_ID=I.Vertical_ID
					left join T0050_SubBranch SB WITH (NOLOCK) on SB.SubBranch_ID=I.subBranch_ID
					left join T0050_SubVertical SV WITH (NOLOCK) on SV.SubVertical_ID =I.SubVertical_ID					
					where I.Cmp_ID=@Company_id
					order by EM.Alpha_Emp_Code asc
					
				DROP TABLE ##TMPDATALEAVE		
			End		
		
		DROP TABLE #LEAVESUMMARY
		DROP TABLE #DATES
		
		
	
	RETURN 


