---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
Create PROCEDURE [dbo].[SP_RPT_T0210_MONTHLY_LEAVE_DETAIL_Format4_GET_Baqckupbyronakk20082022]
 @Cmp_ID 		numeric
,@From_Date 	datetime
,@To_Date 		datetime
,@Branch_ID 	numeric
,@Cat_ID 		numeric 
,@Grd_ID 		numeric
,@Type_ID 		numeric
,@Dept_ID 		numeric
,@Desig_ID 		numeric
,@Emp_ID 		numeric
,@constraint 	varchar(max)
,@Sal_Type		numeric = 0
,@Salary_Cycle_id numeric = 0 
,@Segment_Id  numeric = 0		 -- Added By Gadriwala Muslim 26072013
,@Vertical_Id numeric = 0		 -- Added By Gadriwala Muslim 26072013
,@SubVertical_Id numeric = 0	 -- Added By Gadriwala Muslim 26072013
,@SubBranch_Id numeric = 0		 -- Added By Gadriwala Muslim 01082013	 	
,@Status varchar(20) = ''		 -- Added by Nimesh 19 May 2015 (To Filter Salary by Status)
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

	--Added By Gadriwala on 26072013--------------
	if @Segment_Id = 0 
		set @Segment_Id = null
	IF @Vertical_Id= 0 
		set @Vertical_Id = null
	if @SubVertical_Id = 0 
	set @SubVertical_Id= Null
	-----------------------------------------------
	If @SubBranch_Id = 0	 -- Added By Gadriwala Muslim 01082013
		set @SubBranch_Id = null	

	/*Temporary Code Need to be revised*/
	/*Added by Nimesh & Ramiz if From_Date & To_Date are same (Wonder Client)*/
	IF @From_Date = @To_Date
		BEGIN
			IF Day(@TO_DATE) > 22 AND Day(@TO_DATE) < 28
				SET @TO_DATE = DATEADD(D, -1, DATEADD(M, 1, @TO_DATE))
			ELSE IF Day(@TO_DATE) > 27
				SET @FROM_DATE = DATEADD(D, 1, DATEADD(M, -1, @TO_DATE))
			ELSE
				SET @TO_DATE = DATEADD(D, -1, DATEADD(M, 1, @TO_DATE))
		END

	CREATE TABLE #Emp_Cons 
	(      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric    
	)      
	EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,@Sal_Type ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id 
	

	--Added by Nimesh 19 May 2015
	--Filtering Employee Record according to Salary Status
	IF (@Status = 'Hold' OR @Status = 'Done') BEGIN
		DELETE	FROM #Emp_Cons 
		WHERE	Emp_ID NOT IN ( 
								SELECT Emp_ID FROM T0200_MONTHLY_SALARY S WITH (NOLOCK)
								WHERE	Month(S.Month_End_Date)=Month(@To_Date) 
										AND Year(S.Month_End_Date)=Year(@To_Date) 
										AND S.Cmp_ID=@Cmp_ID 
										AND S.Salary_Status=@Status
							   )
	END    
	
	/*Commented by Nimesh on 29-Jan-2016 (Branch_ID AND Increment_ID is already taking from SP_RPT_FILL_EMP_CONS SP) 
	  	--------------added jimit 31082015---------	  	
        UPDATE  #Emp_Cons
	  	SET		Branch_ID = I.Branch_ID
	  	FROM	#Emp_Cons E INNER JOIN 
	  				(
	  					SELECT	Branch_ID, Emp_ID
	  					FROM	T0095_INCREMENT I
	  					WHERE	Increment_ID=(SELECT	TOP 1 Increment_ID
	  										  FROM		T0095_INCREMENT I1
	  										  WHERE		I1.Cmp_ID=I.Cmp_ID AND I1.Emp_ID=I.Emp_ID
	  													AND I1.Increment_Effective_Date <= @To_Date
	  										  ORDER BY	I1.Increment_Effective_Date DESC, I1.INCREMENT_ID DESC
	  										  )
	  							AND CMP_ID = @Cmp_Id
	  				) I ON E.Emp_ID=I.Emp_ID
	  	----------------------------------------
	*/


	Declare @Sal_St_Date   Datetime    
	Declare @Sal_end_Date   Datetime  		  
	declare @manual_salary_Period as numeric(18,0) -- Comment and added By rohit on 11022013 

	SELECT	TOP 1 @Sal_St_Date  = Sal_st_Date ,@manual_salary_Period= isnull(manual_salary_Period ,0)
	FROM	T0040_GENERAL_SETTING G WITH (NOLOCK) INNER JOIN #Emp_Cons E ON G.Branch_ID=E.Branch_ID
				INNER JOIN (
								SELECT	MAX(For_Date) AS For_Date, G.Branch_ID
								FROM	T0040_GENERAL_SETTING  G WITH (NOLOCK) INNER JOIN #Emp_Cons E ON G.Branch_ID=E.Branch_ID
								WHERE	Cmp_ID = @Cmp_ID AND For_Date <=@TO_DATE 
								GROUP BY  G.Branch_ID
							)  G1 ON G.For_Date=G1.For_Date AND G.Branch_ID=G1.Branch_ID
	WHERE	Cmp_ID = @Cmp_ID	
	
			     
	IF ISNULL(@Sal_St_Date,'') = ''    
		BEGIN    
		   SET @From_Date  = @From_Date     
		   SET @To_Date = @To_Date    
		END     
	ELSE IF DAY(@Sal_St_Date) =1 --and month(@Sal_St_Date)=1    
		BEGIN    
		   SET @From_Date  = @From_Date     
		   SET @To_Date = @To_Date    
		END     
	ELSE  IF @Sal_St_Date <> ''  AND day(@Sal_St_Date) > 1   
		BEGIN    
			if @manual_salary_Period =0 
				BEGIN
				   SET @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
				   SET @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))
				   SET @From_Date = @Sal_St_Date
				   SET @To_Date = @Sal_end_Date   
				END
			ELSE
				BEGIN
					select @Sal_St_Date=from_date,@Sal_End_Date=end_date from salary_period where month= month(@From_Date) and YEAR=year(@From_Date)							   
					Set @From_Date = @Sal_St_Date
					Set @To_Date = @Sal_End_Date    
				END
		
		END

	
	
	/* added by Falak on 17-DEC-2010 for NIIT salary Slip */
	-----Start
	Declare @L_Emp_ID as numeric(18,0)
	Declare @L_Leave_ID as numeric(18,0)
	
	CREATE TABLE #Temp
	(
		Emp_Id numeric(18,0),
		Leave_T_Id numeric(18,0),
		Leave_Opening numeric(18,2),
		Leave_Credit Numeric(18,2),
		Leave_Used  numeric(18,2),
		Leave_Adj_L_Mark numeric(18,2),
		LEAVE_CLOSING  numeric(18,2),
		Back_dated_leave numeric(18,2),
		Leave_Encash  numeric(18,2)		--Ankit 24012015			
	)
	
	INSERT	INTO #Temp 
	SELECT	EC.Emp_id,LM.Leave_Id,0,0,0,0,0,0,0 
	FROM	#Emp_Cons Ec 
			INNER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK)  ON EC.Emp_Id = MS.Emp_ID 		 			
			INNER JOIN T0040_LEAVE_MASTER LM  WITH (NOLOCK) ON MS.Cmp_ID=LM.Cmp_ID 
			INNER JOIN (SELECT	Leave_ID, E.Emp_ID
						FROM	T0050_LEAVE_DETAIL LD WITH (NOLOCK) INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON LD.GRD_ID=I.Grd_ID AND LD.Cmp_ID=I.Cmp_ID
								INNER JOIN #Emp_Cons E ON I.Increment_ID=E.Increment_ID
						WHERE	I.Cmp_ID=@CMP_ID 
						) LD ON LD.Leave_ID=LM.Leave_ID AND EC.Emp_ID=LD.Emp_ID
	WHERE	LM.Leave_Paid_Unpaid = 'P' AND isnull(LM.Default_Short_Name,'') <> 'COMP'  --- AND LM.Leave_Type <> 'Company Purpose'   --- Commented by Hardik 17/03/2020 for WCL they are showing Accident leave in Payslip
			AND MS.Month_St_Date >= @From_Date  AND MS.Month_End_Date <= @To_Date AND isnull(MS.is_FNF,0)=0
			AND MS.Cmp_ID=@Cmp_ID
			--AND Leave_ID in (select Leave_ID from T0050_LEAVE_DETAIL where Grd_id 
			--					= (select Grd_ID from T0095_INCREMENT where Increment_ID = (select Max(Increment_ID) from T0095_INCREMENT where Emp_ID = EC.Emp_id)))   --Added By Ramiz on 27/05/2015 
	--where for_date >= @From_Date AND For_Date <= @To_Date 

	/*MODIFIED BY NIMESH ON 29-JAN-2016*/
	
	--To get defalt Opening (<= From_Date)
	UPDATE	#Temp
	SET		Leave_Opening = isnull(Q1.Leave_Closing,0)
	FROM	#Temp T INNER JOIN (
								SELECT	LT1.Emp_id,LT1.Leave_ID,isnull(LT1.Leave_Closing ,0)Leave_Closing 
								FROM	T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) INNER JOIN #Temp T1 ON LT1.Emp_ID=T1.Emp_Id AND LT1.Leave_ID=T1.LEAVE_T_ID
										INNER JOIN (SELECT	MAX(FOR_dATE) FOR_DATE,LT2.Emp_ID,LT2.Leave_ID 
													FROM	T0140_LEAVE_TRANSACTION  LT2 WITH (NOLOCK) INNER JOIN #Temp T2 ON LT2.Emp_ID=T2.Emp_Id AND LT2.Leave_ID=T2.LEAVE_T_ID										
													WHERE	FOR_DATE <=@From_Date 
															--AND Emp_ID = @L_Emp_ID  AND LEave_ID = @L_LEave_ID
													GROUP BY LT2.Emp_ID,LT2.Leave_ID 
													) LT2 ON LT1.For_Date=LT2.FOR_DATE AND LT1.Emp_ID=LT2.Emp_ID AND LT1.Leave_ID=LT2.Leave_ID
								) Q1 ON T.EMP_ID = Q1.EMP_ID AND T.LEAVE_T_ID = Q1.LEAVE_ID
	--WHERE	T.Emp_Id = @L_Emp_ID AND T.Leave_T_Id = @L_Leave_ID
	
	
	--To get Opening ( Between From_Date & To_Date)
	UPDATE	#Temp
	SET		Leave_Opening = isnull(Q1.Leave_opening,0)
	FROM	#Temp T INNER JOIN (
								SELECT	LT1.Emp_id,LT1.Leave_ID,isnull(LT1.Leave_Opening,0)Leave_Opening 
								FROM	T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) INNER JOIN #Temp T1 ON LT1.Emp_ID=T1.Emp_Id AND LT1.Leave_ID=T1.LEAVE_T_ID
										INNER JOIN (SELECT MIN(FOR_dATE) FOR_DATE,LT2.Emp_ID,LT2.Leave_ID 
													FROM	T0140_LEAVE_TRANSACTION LT2 WITH (NOLOCK) INNER JOIN #Temp T2 ON LT2.Emp_ID=T2.Emp_Id AND LT2.Leave_ID=T2.LEAVE_T_ID										
													WHERE	FOR_DATE >=@From_Date AND FOR_DATE <=@To_Date	--added by jimit 09012106
															--AND Emp_ID = @L_Emp_ID  AND LEave_ID = @L_LEave_ID
													GROUP BY LT2.Emp_ID,LT2.Leave_ID
													) LT2 ON LT1.For_Date=LT2.FOR_DATE AND LT1.Emp_ID=LT2.Emp_ID AND LT1.Leave_ID=LT2.Leave_ID

								) Q1 ON T.EMP_ID = Q1.EMP_ID AND T.LEAVE_T_ID = Q1.LEAVE_ID	
	--WHERE	T.Emp_Id = @L_Emp_ID AND T.Leave_T_Id = @L_Leave_ID
	
	
	UPDATE	#Temp 
	--SET		Leave_Opening  = (Leave_Opening + isnull(Q2.Leave_Credit,0)) -- Commeted By Sajid 27-12-2021 Due to Leave Credit balance wrong show view.
	SET		Leave_Opening  = (Leave_Opening) -- Added By Sajid 27-12-2021 Due to Leave Credit balance wrong show view.
	FROM	#Temp T LEFT OUTER JOIN (SELECT LT1.Emp_Id,LT1.Leave_ID,isnull(sum(LT1.Leave_Credit),0) Leave_Credit 
									 FROM	T0140_LEave_Transaction LT1  WITH (NOLOCK) INNER JOIN #Temp T1 ON LT1.Emp_ID=T1.Emp_Id AND LT1.Leave_ID=T1.LEAVE_T_ID
									 WHERE	(For_Date >= @From_Date AND For_Date < @To_Date)												
									 GROUP BY LT1.Emp_ID ,LT1.Leave_ID ) Q2 ON T.Emp_Id = Q2.Emp_ID AND T.Leave_T_Id = Q2.Leave_ID
	--WHERE	T.Emp_Id = @L_Emp_ID AND T.Leave_T_Id = @L_Leave_ID  
	--Select * From #Temp
	
	UPDATE	#Temp 
	SET		Leave_Credit  = ISNULL(Q2.Leave_Credit,0)
	FROM	#Temp T 
			LEFT OUTER JOIN(SELECT	LT1.Emp_Id,LT1.Leave_ID,ISNULL(SUM(LT1.Leave_Credit),0) Leave_Credit 
							FROM	T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) INNER JOIN #Temp T1 ON LT1.Emp_ID=T1.Emp_Id AND LT1.Leave_ID=T1.LEAVE_T_ID
							--WHERE	(for_Date >= @From_Date AND For_Date <@To_Date)  -- Commeted By Sajid 27-12-2021 Due to Postpaid Leave Credit Not view.
							WHERE	(for_Date >= @From_Date AND For_Date <=@To_Date) -- Added By Sajid 27-12-2021 Due to Postpaid Leave Credit Not view.
									--AND Emp_ID = @L_Emp_ID  AND LEave_ID = @L_LEave_ID
							GROUP BY LT1.Emp_ID ,LT1.Leave_ID ) Q2 ON T.EMP_ID = Q2.EMP_ID AND T.LEAVE_T_ID = Q2.LEAVE_ID
	---WHERE	T.Emp_Id = @L_Emp_ID --and T.Leave_T_Id = @L_Leave_ID 
				
				
	UPDATE	#Temp 
	SET		Leave_Used  = ISNULL(Q2.Leave_Used,0)
	FROM	#Temp T 
			LEFT OUTER JOIN(SELECT	LT1.Emp_Id,LT1.Leave_ID,ISNULL(SUM(LT1.Leave_Used),0) Leave_Used 
							FROM	T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) INNER JOIN #Temp T1 ON LT1.Emp_ID=T1.Emp_Id AND LT1.Leave_ID=T1.LEAVE_T_ID
							WHERE	(for_Date between @From_Date AND @To_Date )
									--AND Emp_ID = @L_Emp_ID AND LEave_ID = @L_LEave_ID
							GROUP BY LT1.Emp_ID ,LT1.Leave_ID ) Q2 ON T.EMP_ID = Q2.EMP_ID AND T.LEAVE_T_ID = Q2.LEAVE_ID
	--WHERE	T.Emp_Id = @L_Emp_ID --and T.Leave_T_Id = @L_Leave_ID 


	UPDATE	#Temp 
	SET		Leave_Adj_L_Mark  = isnull(Q2.Leave_Adj_L_Mark,0)
	FROM	#Temp T LEFT OUTER JOIN	(SELECT LT1.Emp_Id,LT1.Leave_ID,ISNULL(SUM(LT1.Leave_Adj_L_Mark),0) Leave_Adj_L_Mark
									FROM	T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) INNER JOIN #Temp T1 ON LT1.Emp_ID=T1.Emp_Id AND LT1.Leave_ID=T1.LEAVE_T_ID
									WHERE	(for_Date BETWEEN @From_Date AND @To_Date)
											--AND Emp_ID = @L_Emp_ID  AND LEave_ID = @L_LEave_ID
									GROUP BY LT1.Emp_ID ,Leave_ID ) Q2 ON T.EMP_ID = Q2.EMP_ID AND T.LEAVE_T_ID = Q2.LEAVE_ID
	--WHERE	T.Emp_Id = @L_Emp_ID --and T.Leave_T_Id = @L_Leave_ID 

	
	UPDATE	#Temp 
	SET		LEAVE_CLOSING = ISNULL(Q2.Leave_Closing,0)
	FROM	#Temp T 
			LEFT OUTER JOIN (SELECT LT1.Emp_Id,LT1.Leave_ID,ISNULL(LT1.LEave_Closing,0)LEave_Closing 
							FROM	T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) INNER JOIN #Temp T1 ON LT1.Emp_ID=T1.Emp_Id AND LT1.Leave_ID=T1.LEAVE_T_ID
									INNER JOIN (SELECT	MAX(FOR_dATE) FOR_DATE,LT2.Emp_ID,LT2.Leave_ID 
												FROM	T0140_LEAVE_TRANSACTION  LT2 WITH (NOLOCK) INNER JOIN #Temp T2 ON LT2.Emp_ID=T2.Emp_Id AND LT2.Leave_ID=T2.LEAVE_T_ID
												WHERE	FOR_DATE <=@To_Date --AND Emp_ID = @L_Emp_ID AND LEave_ID = @L_LEave_ID
												GROUP BY LT2.Emp_ID,LT2.Leave_ID) T2 ON LT1.FOR_DATE=T2.FOR_DATE AND LT1.Emp_ID=T2.Emp_ID AND LT1.Leave_ID=T2.Leave_ID
							--WHERE	Emp_ID = @L_Emp_ID AND Leave_ID = @L_LEave_ID
							) Q2 ON T.EMP_ID = Q2.EMP_ID AND T.LEAVE_T_ID = Q2.LEAVE_ID
	--WHERE	T.Emp_Id = @L_Emp_ID AND T.Leave_T_Id = @L_Leave_ID
	
	--------------added By Hasmukh 02092014----------
	UPDATE	#Temp 
	SET		Back_Dated_Leave  = ISNULL(Q2.Back_Dated_Leave,0)
	FROM	#Temp T 
			LEFT OUTER JOIN (SELECT LT1.Emp_Id,LT1.Leave_ID,ISNULL(SUM(LT1.Back_Dated_Leave),0) Back_Dated_Leave 
							FROM	T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) INNER JOIN #Temp T1 ON LT1.Emp_ID=T1.Emp_Id AND LT1.Leave_ID=T1.LEAVE_T_ID
							WHERE	(for_Date BETWEEN @From_Date AND @To_Date)
									--AND Emp_ID = @L_Emp_ID  AND LEave_ID = @L_LEave_ID
							GROUP BY LT1.Emp_ID,LT1.Leave_ID ) Q2 ON T.Emp_Id = Q2.Emp_ID AND T.Leave_T_Id = Q2.Leave_ID
	--WHERE	T.Emp_Id = @L_Emp_ID --and T.Leave_T_Id = @L_Leave_ID
	-------------End 02092014------------------------
		 
	
	UPDATE	#Temp 
	SET		Leave_Encash = isnull(Q2.Leave_Encash_Days,0)
	FROM	#Temp T 
			LEFT OUTER JOIN(SELECT LT1.Emp_Id,LT1.Leave_ID,ISNULL(SUM(LT1.Leave_Encash_Days),0)Leave_Encash_Days 
							FROM	T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK) INNER JOIN #Temp T1 ON LT1.Emp_ID=T1.Emp_Id AND LT1.Leave_ID=T1.LEAVE_T_ID
							WHERE	(For_Date BETWEEN @From_Date AND @To_Date) 
									--AND Emp_ID = @L_Emp_ID  AND LEave_ID = @L_LEave_ID 
							GROUP BY LT1.Emp_ID,LT1.Leave_ID) Q2 ON T.Emp_Id = Q2.Emp_ID AND T.Leave_T_Id = Q2.Leave_ID
	--WHERE	T.Emp_Id = @L_Emp_ID AND T.Leave_T_Id = @L_Leave_ID 
			
		/*Commented Loop By Nimesh on 29-Jan-2016 (Written a global sql statement for all employees and leave ids)
		DECLARE Leave_Cur CURSOR FOR
		SELECT Emp_id,LEave_T_ID FROM #Temp
		
		OPEN Leave_Cur 
		FETCH NEXT FROM Leave_Cur INTO @L_Emp_ID,@L_Leave_Id
		WHILE @@FETCH_STATUS = 0
			BEGIN
				
				IF EXISTS(SELECT For_Date FROM T0140_LEAVE_TRANSACTION 
						  WHERE FOR_DATE >=@From_Date AND For_Date <= @To_Date  AND Emp_ID = @L_Emp_ID  AND LEave_ID = @L_LEave_ID )
					BEGIN
						UPDATE	#Temp
						SET		Leave_Opening = isnull(Q1.Leave_opening,0)
						FROM	#Temp T INNER JOIN (
													SELECT	Emp_id,Leave_ID,isnull(Leave_Opening,0)Leave_Opening 
													FROM	T0140_LEave_Transaction LT1 
															INNER JOIN (SELECT MIN(FOR_dATE) FOR_DATE FROM T0140_LEAVE_TRANSACTION 															
																		WHERE FOR_DATE >=@From_Date AND Emp_ID = @L_Emp_ID  AND LEave_ID = @L_LEave_ID) LT2 ON LT1.For_Date=LT2.FOR_DATE
				
													) Q1 ON T.EMP_ID = Q1.EMP_ID AND T.LEAVE_T_ID = Q1.LEAVE_ID	
						WHERE	T.Emp_Id = @L_Emp_ID AND T.Leave_T_Id = @L_Leave_ID
				
					END
				ELSE
					BEGIN
						UPDATE	#Temp
						SET		Leave_Opening = isnull(Q1.Leave_Closing,0)
						FROM	#Temp T INNER JOIN (
													SELECT	Emp_id,Leave_ID,isnull(Leave_Closing ,0)Leave_Closing 
													FROM	T0140_LEave_Transaction LT1 
															INNER JOIN (SELECT MAX(FOR_dATE) FOR_DATE FROM T0140_LEAVE_TRANSACTION 
																		WHERE FOR_DATE <=@From_Date AND Emp_ID = @L_Emp_ID  AND LEave_ID = @L_LEave_ID) LT2 ON LT1.For_Date=LT2.FOR_DATE																		
													) Q1 ON T.EMP_ID = Q1.EMP_ID AND T.LEAVE_T_ID = Q1.LEAVE_ID
						WHERE	T.Emp_Id = @L_Emp_ID AND T.Leave_T_Id = @L_Leave_ID
					END
				
				--below leave credit is added by mitesh on 25/01/2012 
				
				UPDATE	#Temp 
				SET		Leave_Opening  = (Leave_Opening + isnull(Q2.LEave_credit,0))
				FROM	#Temp T LEFT OUTER JOIN (SELECT Emp_Id,LEave_ID,isnull(sum(LEave_credit),0) LEave_credit 
												 FROM	T0140_LEave_Transaction 
												 WHERE	(for_Date BETWEEN @From_Date AND @To_Date)
														AND Emp_ID = @L_Emp_ID  AND LEave_ID = @L_LEave_ID
												 GROUP BY Emp_ID ,Leave_ID ) Q2 ON T.EMP_ID = Q2.EMP_ID AND T.LEAVE_T_ID = Q2.LEAVE_ID
				WHERE	T.Emp_Id = @L_Emp_ID AND T.Leave_T_Id = @L_Leave_ID  
				
							
				--Update #Temp
				--set Leave_Used = Q1.LEave_Used
				--from #Temp T inner join	
				--(Select Emp_ID,Leave_Id,isnull(sum(Leave_Days),0) as LEave_Used from T0210_Monthly_LEave_Detail where cmp_id = @cmp_id AND for_Date >= @From_Date and
				--for_date <= @To_Date AND Emp_ID = @L_Emp_ID GROUP BY EMP_ID,LEAVE_ID ) Q1  
				--on T.Emp_id = Q1.Emp_ID AND T.Leave_T_ID = Q1.Leave_Id
				--where T.Emp_Id = @L_Emp_ID AND T.Leave_T_Id = @L_Leave_ID

				UPDATE	#Temp 
				SET		Leave_Credit  = ISNULL(Q2.Leave_Credit,0)
				FROM	#Temp T 
						LEFT OUTER JOIN(SELECT	Emp_Id,LEave_ID,ISNULL(SUM(Leave_Credit),0) Leave_Credit 
										FROM	T0140_LEave_Transaction 
										WHERE	(for_Date BETWEEN @From_Date AND @To_Date)
												AND Emp_ID = @L_Emp_ID  AND LEave_ID = @L_LEave_ID
										GROUP BY Emp_ID ,Leave_ID ) Q2 ON T.EMP_ID = Q2.EMP_ID AND T.LEAVE_T_ID = Q2.LEAVE_ID
				WHERE	T.Emp_Id = @L_Emp_ID --and T.Leave_T_Id = @L_Leave_ID 
							
							
				UPDATE	#Temp 
				SET		Leave_Used  = ISNULL(Q2.Leave_Used,0)
				FROM	#Temp T 
						LEFT OUTER JOIN(SELECT	Emp_Id,LEave_ID,ISNULL(SUM(LEave_Used),0) Leave_Used 
										FROM	T0140_LEave_Transaction 
										WHERE	(for_Date between @From_Date AND @To_Date )
												AND Emp_ID = @L_Emp_ID AND LEave_ID = @L_LEave_ID
										GROUP BY Emp_ID ,Leave_ID ) Q2 ON T.EMP_ID = Q2.EMP_ID AND T.LEAVE_T_ID = Q2.LEAVE_ID
				WHERE	T.Emp_Id = @L_Emp_ID --and T.Leave_T_Id = @L_Leave_ID 


				UPDATE	#Temp 
				SET		Leave_Adj_L_Mark  = isnull(Q2.Leave_Adj_L_Mark,0)
				FROM	#Temp T LEFT OUTER JOIN	(SELECT Emp_Id,LEave_ID,ISNULL(SUM(Leave_Adj_L_Mark),0) Leave_Adj_L_Mark
												FROM	T0140_LEave_Transaction 
												WHERE	(for_Date BETWEEN @From_Date AND @To_Date)
														AND Emp_ID = @L_Emp_ID  AND LEave_ID = @L_LEave_ID
												GROUP BY Emp_ID ,Leave_ID ) Q2 ON T.EMP_ID = Q2.EMP_ID AND T.LEAVE_T_ID = Q2.LEAVE_ID
				WHERE	T.Emp_Id = @L_Emp_ID --and T.Leave_T_Id = @L_Leave_ID 

				--Update #Temp 
				--	set Leave_Opening = isnull(Q2.LEave_Used ,0)
				--	from #Temp T,
				--	(SELECT LT.Emp_ID,LT.LEAVE_ID,isnull(sum(LEave_Used),0) Leave_Used FROM T0140_LEAVE_TRANSACTION LT INNER JOIN  
				--	(SELECT LEAVE_ID,EMP_ID FROM T0140_LEAVE_TRANSACTION 
				--	 WHERE EMP_ID = @L_EMP_ID AND FOR_DATE >=@From_DATE AND For_Date <= @To_Date 
				--	GROUP BY EMP_ID,LEAVE_ID
				--	) Q ON LT.EMP_ID = Q.EMP_ID AND LT.LEAVE_ID = Q.LEAVE_ID --AND LT.FOR_DATE = Q.FOR_DATE 
				--INNER JOIN T0040_LEAVE_MASTER LM ON LT.LEAVE_ID = LM.LEAVE_ID ) Q2
				--where T.Emp_Id = Q2.Emp_ID AND T.Leave_T_ID = Q2.Leave_ID
				
				UPDATE	#Temp 
				SET		LEAVE_CLOSING = ISNULL(Q2.Leave_Closing,0)
				FROM	#Temp T 
						LEFT OUTER JOIN (SELECT Emp_Id,LEave_ID,ISNULL(LEave_Closing,0)LEave_Closing 
										FROM	T0140_LEave_Transaction T1
												INNER JOIN (SELECT	MAX(FOR_dATE) FOR_DATE FROM T0140_LEAVE_TRANSACTION 
															WHERE	FOR_DATE <=@To_Date AND Emp_ID = @L_Emp_ID AND LEave_ID = @L_LEave_ID) T2 ON T1.FOR_DATE=T2.FOR_DATE
										WHERE	Emp_ID = @L_Emp_ID AND Leave_ID = @L_LEave_ID
										) Q2 ON T.EMP_ID = Q2.EMP_ID AND T.LEAVE_T_ID = Q2.LEAVE_ID
				WHERE	T.Emp_Id = @L_Emp_ID AND T.Leave_T_Id = @L_Leave_ID

				--------------added By Hasmukh 02092014----------
				UPDATE	#Temp 
				SET		Back_Dated_Leave  = ISNULL(Q2.Back_Dated_Leave,0)
				FROM	#Temp T 
						LEFT OUTER JOIN (SELECT Emp_Id,LEave_ID,ISNULL(SUM(Back_Dated_Leave),0) Back_Dated_Leave 
										FROM	T0140_LEave_Transaction 
										WHERE	(for_Date BETWEEN @From_Date AND @To_Date)
												AND Emp_ID = @L_Emp_ID  AND LEave_ID = @L_LEave_ID
										GROUP BY Emp_ID ,Leave_ID ) Q2 ON T.EMP_ID = Q2.EMP_ID AND T.LEAVE_T_ID = Q2.LEAVE_ID
				WHERE	T.Emp_Id = @L_Emp_ID --and T.Leave_T_Id = @L_Leave_ID
				-------------End 02092014------------------------
					 
				
				UPDATE	#Temp 
				SET		Leave_Encash = isnull(Q2.Leave_Encash_Days,0)
				FROM	#Temp T 
						LEFT OUTER JOIN(SELECT Emp_Id,Leave_ID,ISNULL(SUM(Leave_Encash_Days),0)Leave_Encash_Days 
										FROM	T0140_LEAVE_TRANSACTION 
										WHERE	(for_Date BETWEEN @From_Date AND @To_Date) AND Emp_ID = @L_Emp_ID  AND LEave_ID = @L_LEave_ID 
										GROUP BY Emp_ID ,Leave_ID) Q2 ON T.EMP_ID = Q2.EMP_ID AND T.LEAVE_T_ID = Q2.LEAVE_ID
				WHERE	T.Emp_Id = @L_Emp_ID AND T.Leave_T_Id = @L_Leave_ID 
				
				FETCH NEXT FROM Leave_Cur INTO @L_Emp_Id,@L_Leave_Id
			END
		CLOSE Leave_Cur
		DEALLOCATE Leave_Cur
		*/
		SELECT	T.*,LM.Leave_Code,MS.Sal_Tran_ID,EC.Branch_ID 
		,isnull(lm.Gujarati_Alias,'') as Gujarati_Alias
		FROM	#Temp T INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) on T.Leave_T_Id = LM.Leave_ID
				INNER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK) on T.Emp_Id = MS.Emp_ID 
				INNER JOIN #Emp_Cons EC on EC.Emp_Id = T.Emp_Id
		WHERE	MS.Month_St_Date >= @From_Date  AND MS.Month_End_Date <= @To_Date AND isnull(MS.is_FNF,0)=0 AND lm.Display_leave_balance = 1
				--AND lm.Is_Late_Adj = 1  --added by jimit 15122016 ---Commented by Hardik 16/09/2017
		ORDER BY Emp_Id,Lm.Leave_Sorting_No,LM.Leave_Name   --added jimit 02082016  for getting the Leave detail according to Leave sorting no as per requirement for golcha group.
	
					
	RETURN 
