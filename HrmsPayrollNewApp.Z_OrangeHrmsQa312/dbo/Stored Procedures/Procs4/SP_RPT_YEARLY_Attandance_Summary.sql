
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_YEARLY_Attandance_Summary]
	 @Cmp_ID 		NUMERIC
	,@From_Date 	DATETIME
	,@To_Date 		DATETIME
	,@Branch_ID 	NUMERIC
	,@Cat_ID 		NUMERIC 
	,@Grd_ID 		NUMERIC
	,@Type_ID 		NUMERIC
	,@Dept_ID 		NUMERIC
	,@Desig_ID 		NUMERIC
	,@Emp_ID 		NUMERIC
	,@constraint 	VARCHAR(MAX)
	,@Report_Call	VARCHAR(20)='Net Salary'
	,@Salary_Cycle_id NUMERIC = NULL
	,@Segment_Id	NUMERIC = 0		 -- Added By Gadriwala Muslim 21082013
	,@Vertical_Id	NUMERIC = 0		 -- Added By Gadriwala Muslim 21082013
	,@SubVertical_Id NUMERIC = 0	 -- Added By Gadriwala Muslim 21082013	
	,@SubBranch_Id	NUMERIC = 0		 -- Added By Gadriwala Muslim 21082013	
	,@Flag			NUMERIC = 0 --Added by nilesh patel ON 31032016 For Leave Application Form Report
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON	
 
	 
	IF @Branch_ID = 0  
		SET @Branch_ID = NULL
		
	IF @Cat_ID = 0  
		SET @Cat_ID = NULL

	IF @Grd_ID = 0  
		SET @Grd_ID = NULL

	IF @Type_ID = 0  
		SET @Type_ID = NULL

	IF @Dept_ID = 0  
		SET @Dept_ID = NULL

	IF @Desig_ID = 0  
		SET @Desig_ID = NULL

	IF @Emp_ID = 0  
		SET @Emp_ID = NULL
	
	IF @Salary_Cycle_id = 0	 -- Added By Gadriwala Muslim 21082013
		SET @Salary_Cycle_id = NULL	
	IF @Segment_Id = 0		 -- Added By Gadriwala Muslim 21082013
		SET @Segment_Id = NULL
	IF @Vertical_Id = 0		 -- Added By Gadriwala Muslim 21082013
		SET @Vertical_Id = NULL
	IF @SubVertical_Id = 0	 -- Added By Gadriwala Muslim 21082013
		SET @SubVertical_Id = NULL	
	IF @SubBranch_Id = 0	 -- Added By Gadriwala Muslim 21082013
		SET @SubBranch_Id = NULL	
	
	
	CREATE TABLE #Emp_Cons -- Ankit 06092014 for Same Date Increment
	(      
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC    
	)   
	 
	EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0 ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id 

	
	IF @Flag = 0
		BEGIN
			DECLARE @Month NUMERIC 
			DECLARE @Year NUMERIC  
			IF EXISTS (SELECT 1 FROM [tempdb].dbo.sysobjects WHERE NAME = '#Yearly_Salary' )		
				BEGIN
					DROP TABLE #Yearly_Salary 
				END			 
			
			CREATE TABLE #Yearly_Salary 
			(
				Row_ID			NUMERIC IDENTITY (1,1) not null,
				Cmp_ID			NUMERIC ,
				Emp_Id			NUMERIC ,
				Def_ID			NUMERIC ,
				Lable_Name		VARCHAR(100),
				Month_1			NUMERIC (18,2) default 0,
				Month_2			NUMERIC (18,2) default 0,
				Month_3			NUMERIC (18,2) default 0,
				Month_4			NUMERIC (18,2) default 0,
				Month_5			NUMERIC (18,2) default 0,
				Month_6			NUMERIC (18,2) default 0,
				Month_7			NUMERIC (18,2) default 0,
				Month_8			NUMERIC (18,2) default 0,
				Month_9			NUMERIC (18,2) default 0,
				Month_10		NUMERIC (18,2) default 0,
				Month_11		NUMERIC (18,2) default 0,
				Month_12		NUMERIC (18,2) default 0,
				Total			NUMERIC (18,2) default 0,
				Leave_ID			NUMERIC, 
				--LOAN_ID			NUMERIC,
				--CLAIM_ID		NUMERIC,
				Group_Def_ID	NUMERIC default 0
			)
	
		
			--IF @Report_Call <> 'Net Salary'
				BEGIN
						INSERT INTO #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
						SELECT @Cmp_ID,emp_ID,1,'Present' From #Emp_Cons 

						INSERT INTO #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
						SELECT @Cmp_ID,emp_ID,2,'WeekOff' From #Emp_Cons 
						
						INSERT INTO #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
						SELECT @Cmp_ID,emp_ID,3,'Holiday' From #Emp_Cons 
											
						INSERT INTO #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
						SELECT @Cmp_ID,emp_ID,4,'Absent' From #Emp_Cons 
						
											

						INSERT INTO #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,Leave_ID)
						SELECT	DISTINCT @Cmp_ID,EC.emp_ID,0,Leave_Name ,TLT.Leave_id 
						From	#Emp_Cons EC	INNER JOIN  
								T0140_LEAVE_TRANSACTION TLT WITH (NOLOCK) ON EC.EMP_ID = TLT.EMP_ID INNER JOIN 
								T0040_LEAVE_MASTER TM WITH (NOLOCK) ON TLT.Leave_ID = TM.Leave_ID
						WHERE	FOR_DATE >=@fROM_dATE AND FOR_dATE <=@TO_DATE 
						
						INSERT INTO #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
						SELECT @Cmp_ID,emp_ID,14,'Late/Early penalty' From #Emp_Cons 
						
						INSERT INTO #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
						SELECT @Cmp_ID,emp_ID,15,'Gate Pass Days' From #Emp_Cons 
						
				End
				

			INSERT INTO #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
			SELECT @Cmp_ID,emp_ID,18,'Total Days' From #Emp_Cons 

			--INSERT INTO #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
			--SELECT @Cmp_ID,emp_ID,20,'Leaves After CutOff' From #Emp_Cons 
			INSERT INTO #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name,Leave_ID)
			SELECT	DISTINCT @Cmp_ID,EC.emp_ID,20,Leave_Name ,TLT.Leave_id + 9000
			From	#Emp_Cons EC	INNER JOIN  
					T0140_LEAVE_TRANSACTION TLT WITH (NOLOCK) ON EC.EMP_ID = TLT.EMP_ID INNER JOIN 
					T0040_LEAVE_MASTER TM WITH (NOLOCK) ON TLT.Leave_ID = TM.Leave_ID
			WHERE	FOR_DATE >=@fROM_dATE AND FOR_dATE <=@TO_DATE 
			
			INSERT INTO #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
			SELECT @Cmp_ID,emp_ID,21,'CutOff Arrear Days' From #Emp_Cons 

			INSERT INTO #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
			SELECT @Cmp_ID,emp_ID,22,'Total Leave Days' From #Emp_Cons
			
			INSERT INTO #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
			SELECT @Cmp_ID,emp_ID,23,'Late Days' From #Emp_Cons
			
			DECLARE @Temp_Date DATETIME
			DECLARE @count NUMERIC 
			DECLARE @str_query as VARCHAR(max)
			DECLARE @str_month as VARCHAR(500)

			SET @Temp_Date = @From_Date 
			SET @count = 1 
			SET @str_query=''			
			SET @str_month = ''
			
			

			WHILE @Temp_Date <=@To_Date 
				BEGIN
					SET @Month = MONTH(@Temp_date)
					SET @Year = YEAR(@Temp_Date)
					
				
					SET @str_month	 = 'Month_' + cast(@count AS varchar)
					
					
					SET @str_query = 'UPDATE #Yearly_Salary 
						SET		'+ @str_month + ' = Present_Days 
						FROM	#Yearly_Salary YS 
								INNER JOIN T0200_Monthly_Salary MS ON YS.EMP_ID = MS.EMP_ID 
						WHERE	Month(Month_End_Date) = ' + cast(@Month as VARCHAR(4)) + ' AND Year(Month_End_Date) = ' + cast(@Year as VARCHAR(10)) +' AND Def_ID = 1'	
					EXEC(@str_query)
							
					SET @str_query = 'UPDATE #Yearly_Salary 
						SET		'+ @str_month + ' = Arear_Day_Previous_Month 
						FROM	#Yearly_Salary YS 
								INNER JOIN T0200_Monthly_Salary MS ON YS.EMP_ID = MS.EMP_ID 
						WHERE	Month(Month_End_Date) = ' + cast(@Month as VARCHAR(4)) + ' AND Year(Month_End_Date) = ' + cast(@Year as VARCHAR(10)) +' AND Def_ID = 21'	
					EXEC(@str_query)
						
					SET @str_query = 'UPDATE #Yearly_Salary 
						SET ' + @str_month +' = Weekoff_Days
						FROM	#Yearly_Salary YS 
								INNER JOIN T0200_Monthly_Salary MS ON YS.EMP_ID = MS.EMP_ID 
						Where Month(Month_End_Date) = '+ cast(@Month as VARCHAR(4)) +'and Year(Month_End_Date) = ' + cast(@Year as VARCHAR(10))+'
							and Def_ID = 2'
					EXEC(@str_query)

					SET @str_query =' UPDATE #Yearly_Salary 
						SET ' + @str_month +'= Holiday_Days
						FROM	#Yearly_Salary YS 
								INNER JOIN T0200_Monthly_Salary MS ON YS.EMP_ID = MS.EMP_ID 
						WHERE	Month(Month_End_Date) = ' + cast(@Month as VARCHAR(4)) +' AND Year(Month_End_Date) = '+ cast(@Year as VARCHAR(10)) +' AND Def_ID = 3'
					EXEC(@str_query)

					SET @str_query =' UPDATE #Yearly_Salary 
						SET ' + @str_month +'= Holiday_Days
						FROM	#Yearly_Salary YS 
								INNER JOIN T0200_Monthly_Salary MS ON YS.EMP_ID = MS.EMP_ID 
						WHERE	Month(Month_End_Date) = ' + cast(@Month as VARCHAR(4)) +' AND Year(Month_End_Date) = '+ cast(@Year as VARCHAR(10)) +' AND Def_ID = 3'
					EXEC(@str_query)
						
					/*Between Month_Start_Date and Cutoff_Date if given otherwise it will consider Month_End_Date*/
					SET @str_query = 'UPDATE #Yearly_Salary 
						SET		' + @str_month + '= leave_Sum
						FROM	#Yearly_Salary YS
								INNER JOIN (SELECT (
													SUM(CASE WHEN Lm.Apply_Hourly=1 AND LM.Default_Short_Name <>''COMP'' THEN 
																CASE WHEN isnull(LEAVE_USED,0) > 8 THEN 
																	8 
																ELSE 
																	isnull(LEAVE_USED,0) 
																end /8  
															when LM.Default_Short_Name <>''COMP'' THEN 
																isnull(LEAVE_USED,0) 
															ELSE 
																isnull(LEAVE_USED,0) --0 changed By Jimit 30052018 as Leave Count is not coming in Yearly Attendance and Also Absent is coming Wrong (WCL --21072(Left employee))
														end) 
														+ 
													SUM(CASE WHEN Lm.Apply_Hourly=1 AND LM.Default_Short_Name =''COMP''  THEN 
															(isnull(CompOff_Used,0) - isnull(Leave_Encash_Days,0) ) /8  
														WHEN  LM.Default_Short_Name =''COMP''  THEN 
															isnull(CompOff_Used,0) - isnull(Leave_Encash_Days,0) 
														ELSE  
															0 
														END)
													) AS leave_Sum,Lt.Leave_ID,LT.emp_id 
											FROM	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
													INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.Leave_ID = Lm.Leave_id
													INNER JOIN T0200_MONTHLY_SALARY MS1 WITH (NOLOCK) ON LT.FOR_DATE BETWEEN MS1.Month_St_Date AND IsNull(MS1.Cutoff_Date, MS1.Month_End_Date) AND LT.Emp_ID=MS1.Emp_ID
											WHERE	Month(Month_End_Date) = ' + cast(@Month as VARCHAR(4)) + ' AND Year(Month_End_Date) = ' + cast(@Year as VARCHAR(10)) +'
											GROUP BY Lt.Leave_ID,LT.emp_id) TLT ON YS.Leave_ID = TLT.Leave_ID AND YS.emp_ID = TLT.emp_ID 
								INNER JOIN	T0200_Monthly_Salary MS WITH (NOLOCK) ON YS.emp_ID = ms.emp_ID
						WHERE	Month(Month_End_Date) = ' + cast(@Month as VARCHAR(4)) + 'and Year(Month_End_Date) = '+ cast(@Year as VARCHAR(10)) + ''
					EXEC(@str_query)

					/*Leave Days after CutOff Date*/
					SET @str_query = 'UPDATE #Yearly_Salary 
						SET		' + @str_month + '= leave_Sum
						FROM	#Yearly_Salary YS
								INNER JOIN (SELECT (
													SUM(CASE WHEN Lm.Apply_Hourly=1 AND LM.Default_Short_Name <>''COMP'' THEN 
																CASE WHEN isnull(LEAVE_USED,0) > 8 THEN 
																	8 
																ELSE 
																	isnull(LEAVE_USED,0) 
																end /8  
															when LM.Default_Short_Name <>''COMP'' THEN 
																isnull(LEAVE_USED,0) 
															ELSE 
																0 
														end) 
														+ 
													SUM(CASE WHEN Lm.Apply_Hourly=1 AND LM.Default_Short_Name =''COMP''  THEN 
															(isnull(CompOff_Used,0) - isnull(Leave_Encash_Days,0) ) /8  
														WHEN  LM.Default_Short_Name =''COMP''  THEN 
															isnull(CompOff_Used,0) - isnull(Leave_Encash_Days,0) 
														ELSE  
															0 
														END)
													) AS leave_Sum,LT.emp_id, (lT.Leave_ID + 9000) As Leave_ID
											FROM	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
													INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.Leave_ID = Lm.Leave_id
													INNER JOIN T0200_MONTHLY_SALARY MS1 WITH (NOLOCK) ON LT.FOR_DATE BETWEEN (IsNull(MS1.Cutoff_Date, MS1.Month_End_Date) + 1) AND MS1.Month_End_Date AND LT.Emp_ID=MS1.Emp_ID
											WHERE	Month(Month_End_Date) = ' + cast(@Month as VARCHAR(4)) + ' AND Year(Month_End_Date) = ' + cast(@Year as VARCHAR(10)) +'
											GROUP BY LT.emp_id, (lT.Leave_ID + 9000)) TLT ON YS.emp_ID = TLT.emp_ID AND YS.Leave_ID=TLT.Leave_ID
								INNER JOIN	T0200_Monthly_Salary MS WITH (NOLOCK) ON YS.emp_ID = ms.emp_ID
						WHERE	Month(Month_End_Date) = ' + cast(@Month as VARCHAR(4)) + 'and Year(Month_End_Date) = '+ cast(@Year as VARCHAR(10)) + ' 
								AND Day(IsNull(CutOff_Date, ''1900-01-01'')) BETWEEN 2 AND DAY(Month_End_Date)  AND Def_ID = 20'
					EXEC(@str_query)


					--WHERE	For_Date >= ''' + CONVERT(char(10), @Temp_Date,126) + ''' AND For_Date < ''' + CONVERT(char(10), dateadd(m,1,@Temp_Date),126) + ''' 
					
					SET @str_query = 'UPDATE #Yearly_Salary 
						SET		' + @str_month + '= leave_Sum
						FROM	#Yearly_Salary YS 
								INNER JOIN (SELECT (SUM(isnull(leave_adj_L_mark,0))) as leave_Sum,emp_id 
											FROM	T0140_LEAVE_TRANSACTION WITH (NOLOCK)
											WHERE	For_Date >= ''' + CONVERT(char(10), @Temp_Date,126) +'''and For_Date < '''+ CONVERT(char(10), dateadd(m,1,@Temp_Date),126) + '''
											GROUP BY emp_id) TLT ON YS.emp_ID = TLT.emp_ID 
								INNER JOIN T0200_Monthly_Salary MS WITH (NOLOCK) ON YS.emp_ID = ms.emp_ID
						WHERE	Month(Month_End_Date) = ' + cast(@Month as VARCHAR(4))  + 'and Year(Month_End_Date) = ' + cast(@Year as VARCHAR(10)) + 'and Def_ID = 14'
					EXEC(@str_query)
						
					SET @str_query = 'UPDATE #Yearly_Salary 
						SET		'+ @str_month + ' = ISNULL(ms.GatePass_Deduct_Days,0)
						FROM	#Yearly_Salary YS   inner join T0200_Monthly_Salary MS ON YS.EMP_ID = MS.EMP_ID 
						WHERE	Month(Month_End_Date) = ' + cast(@Month as VARCHAR(4)) + 'and Year(Month_End_Date) =  ' + cast(@Year as VARCHAR(10)) +' and Def_ID = 15'
					EXEC(@str_query)
					    
					-- Added by rohit ON 20012017
					SET @str_query = 'UPDATE #Yearly_Salary  
						SET		'+ @str_month + ' = ISNULL(ms.Present_on_Holiday,0)
						FROM	#Yearly_Salary YS
								INNER JOIN T0200_Monthly_Salary MS ON YS.EMP_ID = MS.EMP_ID 
						WHERE	Month(Month_End_Date) = ' + cast(@Month as VARCHAR(4)) + 'and Year(Month_End_Date) =  ' + cast(@Year as VARCHAR(10)) +' AND Def_ID = 16'
					EXEC(@str_query)
					    
					    		
					SET @str_query =  'UPDATE #Yearly_Salary 
						SET		' + @str_month + ' = Outof_Days
						FROM	#Yearly_Salary YS 
								INNER JOIN T0200_Monthly_Salary MS ON YS.EMP_ID = MS.EMP_ID 
						WHERE	Month(Month_End_Date) = ' + cast(@Month as VARCHAR(4)) + 'and Year(Month_End_Date) =  ' + cast(@Year as VARCHAR(10)) +' and Def_ID = 18'
					EXEC(@str_query)
						
					SET @str_query =  'UPDATE #Yearly_Salary 
						SET		' + @str_month + ' = CASE WHEN (TOTAL.Total_Days - TLT.Ab_Days + IsNull(MS.Arear_Day_Previous_Month,0) ) < 0 THEN 0 ELSE (TOTAL.Total_Days - TLT.Ab_Days + IsNull(MS.Arear_Day_Previous_Month,0)) end
						FROM	#Yearly_Salary YS
								INNER JOIN (SELECT	SUM(' + @str_month + ') AS Ab_Days, Emp_ID 
											FROM	#Yearly_Salary 
											WHERE	Def_ID <> 18 group by emp_id) TLT ON YS.emp_ID = TLT.emp_ID
								INNER JOIN (SELECT	SUM(' + @str_month + ') AS Total_Days, Emp_ID
											FROM	#Yearly_Salary 
											WHERE	Def_ID = 18 group by emp_id ) TOTAL ON YS.emp_ID = TOTAL.emp_ID 
								INNER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON YS.EMP_ID=MS.EMP_ID AND Month(Month_End_Date) = ' + cast(@Month as VARCHAR(4)) + 'and Year(Month_End_Date) =  ' + cast(@Year as VARCHAR(10)) +' WHERE	Def_ID = 4 '
					EXEC(@str_query)			
							
				--------------Added By Deepali on 19nov2021 for Absent Count- Start 

						SET @str_query =  'UPDATE #Yearly_Salary 
						SET		' + @str_month + '= MS.Absent_Days
						FROM	#Yearly_Salary YS
								INNER JOIN (SELECT	SUM(' + @str_month + ') AS Ab_Days, Emp_ID 
											FROM	#Yearly_Salary 
											WHERE	Def_ID <> 18 group by emp_id) TLT ON YS.emp_ID = TLT.emp_ID
								INNER JOIN (SELECT	SUM(' + @str_month + ') AS Total_Days, Emp_ID
											FROM	#Yearly_Salary 
											WHERE	Def_ID = 18 group by emp_id ) TOTAL ON YS.emp_ID = TOTAL.emp_ID 
								INNER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON YS.EMP_ID=MS.EMP_ID 
								AND Month(Month_End_Date) = ' + cast(@Month as VARCHAR(4)) + 'and 
								Year(Month_End_Date) =  ' + cast(@Year as VARCHAR(10)) +' 
								
						WHERE	Def_ID = 4 '
					EXEC(@str_query)		
					------------------Added By Deepali on 19nov2021 for Absent Count- end 

					------------------Added By Deepali on 19nov2021 for Total Count- start 

					SET @str_query =  'UPDATE #Yearly_Salary 
						SET		' + @str_month + ' = Sal_Cal_Days
						FROM	#Yearly_Salary YS 
								INNER JOIN T0200_Monthly_Salary MS ON YS.EMP_ID = MS.EMP_ID 
						WHERE	Month(Month_End_Date) = ' + cast(@Month as VARCHAR(4)) + 'and Year(Month_End_Date) =  ' + cast(@Year as VARCHAR(10)) +' and Def_ID = 18'
					EXEC(@str_query)
					------------------Added By Deepali on 19nov2021 for Total Count- end 

	
					
							
							SET @str_query =' UPDATE #Yearly_Salary 
						SET ' + @str_month +'= ms.Total_Leave_Days
						FROM	#Yearly_Salary YS 
								INNER JOIN T0200_Monthly_Salary MS ON YS.EMP_ID = MS.EMP_ID 
						WHERE	Month(Month_End_Date) = ' + cast(@Month as VARCHAR(4)) +' AND Year(Month_End_Date) = '+ cast(@Year as VARCHAR(10)) +' AND Def_ID = 22'
					EXEC(@str_query)
					
					SET @str_query =' UPDATE #Yearly_Salary 
						SET ' + @str_month +'= ms.Late_Days
						FROM	#Yearly_Salary YS 
								INNER JOIN T0200_Monthly_Salary MS ON YS.EMP_ID = MS.EMP_ID 
						WHERE	Month(Month_End_Date) = ' + cast(@Month as VARCHAR(4)) +' AND Year(Month_End_Date) = '+ cast(@Year as VARCHAR(10)) +' AND Def_ID = 23'
					EXEC(@str_query)


					SET @Temp_Date = dateadd(m,1,@Temp_date)
					SET @count = @count + 1  
				END
		
			UPDATE	#Yearly_Salary
			SET		TOTAL = MONTH_1 + MONTH_2 + MONTH_3 + MONTH_4 + MONTH_5 +MONTH_6 + MONTH_7 + MONTH_8 + MONTH_9	
					+ MONTH_10 + MONTH_11 + MONTH_12 
		
			DELETE	YS
			FROM	#Yearly_Salary YS
			WHERE	Def_ID in (17,20)
					AND (ABS(MONTH_1) + ABS(MONTH_2) + ABS(MONTH_3) + ABS(MONTH_4) + ABS(MONTH_5) + ABS(MONTH_6) + ABS(MONTH_7) + ABS(MONTH_8) + ABS(MONTH_9) + ABS(MONTH_10) + ABS(MONTH_11) + ABS(MONTH_12)) = 0

			Update	Y
			SET		group_Def_ID = New_ID
			FROM	#Yearly_Salary Y 
					INNER JOIN (SELECT	MIN(row_ID) AS New_ID,Lable_NAme 
								FROM	#Yearly_Salary 
								GROUP BY lable_name) Q ON Y.Lable_NAme = Q.lable_Name

				--select 333,* from #Yearly_Salary 		
			-- Changed By Ali 22112013 EmpName_Alias
			IF @Report_Call IN ('', 'All')
				BEGIN
					SELECT	YS.*,Grd_NAme,Dept_Name,Desig_Name,Branch_NAme,Type_NAme,Branch_Address,Comp_name,Cmp_NAme,Cmp_Address,Emp_Code,Alpha_Emp_Code,Emp_First_Name,
							ISNULL(EmpName_Alias_Salary,Emp_Full_Name) as Emp_full_Name,@From_Date P_From_Date , @To_Date P_To_Date, BM.Branch_ID
					FROM	#Yearly_Salary YS 
							INNER JOIN #Emp_Cons EC ON YS.Emp_Id=EC.Emp_ID
							INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON EC.Increment_ID=I.Increment_ID AND EC.Emp_ID=I.Emp_ID
							INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON YS.EMP_ID = EM.EMP_ID
							INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I.Grd_ID = GM.Grd_ID 
							LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I.Type_ID = ETM.Type_ID 
							LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I.Desig_Id = DGM.Desig_Id 
							LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I.Dept_Id = DM.Dept_Id 
							INNER JOIN T0030_Branch_Master BM WITH (NOLOCK) ON I.Branch_ID = BM.Branch_ID 
							INNER JOIN T0010_COMPANY_MASTER cm WITH (NOLOCK) ON YS.cmp_Id = cm.cmp_Id
					ORDER BY RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500),Row_ID	
				END
			ELSE IF @Report_Call = 'All1'
				BEGIN				
					select	YS.row_id,YS.cmp_id,YS.emp_id,YS.def_id,YS.lable_name,YS.month_1,YS.month_2,YS.month_3,YS.month_4,YS.month_5,YS.month_6,YS.month_7,YS.month_8,YS.month_9,
							YS.month_10,YS.month_11,YS.month_12,YS.Total,0 as ad_id ,0 as loan_id, 0 as claim_id,YS.group_def_id,0 as ad_level,Grd_NAme,Dept_Name,Desig_Name,
							Branch_NAme,Type_NAme,Branch_Address,Comp_name,Cmp_NAme,Cmp_Address,Emp_Code,Alpha_Emp_Code,Emp_First_Name,ISNULL(EmpName_Alias_Salary,Emp_Full_Name) as Emp_Full_Name,
							@From_Date P_From_Date , @To_Date P_To_Date, BM.Branch_ID,EM.Pan_No,EM.Date_Of_Join ,EM.Date_Of_Birth,EM.Emp_Left_Date,VS.Vertical_Name,YS.Leave_ID
					FROM	#Yearly_Salary YS 
							INNER JOIN #Emp_Cons EC ON YS.Emp_Id=EC.Emp_ID
							INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON EC.Increment_ID=I.Increment_ID AND EC.Emp_ID=I.Emp_ID
							INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON YS.EMP_ID = EM.EMP_ID
							INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I.Grd_ID = GM.Grd_ID
							LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I.Type_ID = ETM.Type_ID
							LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I.Desig_Id = DGM.Desig_Id
							LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I.Dept_Id = DM.Dept_Id
							INNER JOIN T0030_Branch_Master BM WITH (NOLOCK) ON I.Branch_ID = BM.Branch_ID
							INNER JOIN T0010_COMPANY_MASTER cm WITH (NOLOCK) ON YS.cmp_Id = cm.cmp_Id
							LEFT JOIN T0040_Vertical_Segment VS WITH (NOLOCK) ON I.Vertical_ID = vs.Vertical_ID
					WHERE	Lable_Name <> 'Strenght' 
								And (
										Month_1 <> 0 or Month_2 <> 0 or Month_3 <> 0 or Month_4 <> 0 or Month_5 <> 0 or Month_6 <> 0 or Month_7 <> 0 or Month_8 <> 0 or Month_9 <> 0
										or Month_10 <> 0 or Month_11 <> 0 or Month_12 <> 0 
									)
					ORDER BY RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500),Row_ID,YS.Def_ID									
				End
			ELSE
				BEGIN
					select  YS.*,Grd_NAme,Dept_Name,Desig_Name,Branch_NAme,Type_NAme,Branch_Address,Comp_name,Cmp_NAme,Cmp_Address,Emp_Code,Alpha_Emp_Code,Emp_First_Name,
							ISNULL(EmpName_Alias_Salary,Emp_Full_Name) as Emp_full_Name,@From_Date P_From_Date , @To_Date P_To_Date, BM.Branch_ID
					FROM	#Yearly_Salary YS 
							INNER JOIN #Emp_Cons EC ON YS.Emp_Id=EC.Emp_ID
							INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON EC.Increment_ID=I.Increment_ID AND EC.Emp_ID=I.Emp_ID
							INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON YS.EMP_ID = EM.EMP_ID
							INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I.Grd_ID = GM.Grd_ID 
							LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I.Type_ID = ETM.Type_ID 
							LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I.Desig_Id = DGM.Desig_Id 
							LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I.Dept_Id = DM.Dept_Id 
							INNER JOIN T0030_Branch_Master BM WITH (NOLOCK) ON I.Branch_ID = BM.Branch_ID 
							INNER JOIN T0010_COMPANY_MASTER cm WITH (NOLOCK) ON YS.cmp_Id = cm.cmp_Id
					Where	Lable_Name = @Report_Call
						 					
					ORDER BY RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500),Row_ID	
				END
					
		END	
	ELSE
		BEGIN		
			SET @From_Date = DATEADD(m,-6,@From_Date)
			SET @To_Date = DATEADD(m,-1,@To_Date)
					
			IF OBJECT_ID('tempdb..#Yearly_Salary_1') IS NOT NULL
				DROP TABLE #Yearly_Salary_1
						
			CREATE TABLE #Yearly_Salary_1 
			(
				Row_ID			NUMERIC IDENTITY (1,1) not null,
				Cmp_ID			NUMERIC ,
				Emp_Id			NUMERIC ,
				Def_ID			NUMERIC ,
				Lable_Name		VARCHAR(100),
				Leave_ID		NUMERIC, 
				Total			NUMERIC (18,2) default 0,
				Group_Def_ID	NUMERIC default 0
			)
			
			INSERT INTO #Yearly_Salary_1 (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
			SELECT @Cmp_ID,emp_ID,1,'Present' From #Emp_Cons 

			INSERT INTO #Yearly_Salary_1 (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
			SELECT @Cmp_ID,emp_ID,2,'WeekOff' From #Emp_Cons 
						
			INSERT INTO #Yearly_Salary_1 (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
			SELECT @Cmp_ID,emp_ID,3,'Holiday' From #Emp_Cons 
											
			INSERT INTO #Yearly_Salary_1 (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
			SELECT @Cmp_ID,emp_ID,4,'Absent' From #Emp_Cons 
													
			INSERT INTO #Yearly_Salary_1 (Cmp_ID,Emp_ID,Def_ID,Lable_Name,Leave_ID)
			SELECT DISTINCT @Cmp_ID,EC.emp_ID,0,TM.Leave_Code ,TLT.Leave_id 
			From	#Emp_Cons EC
					INNER JOIN T0140_LEAVE_TRANSACTION TLT WITH (NOLOCK) ON EC.EMP_ID = TLT.EMP_ID 
					INNER JOIN T0040_LEAVE_MASTER TM WITH (NOLOCK) ON TLT.Leave_ID = TM.Leave_ID
			WHERE	FOR_DATE >=@fROM_dATE AND FOR_dATE <=@TO_DATE 
						
			INSERT INTO #Yearly_Salary_1 (Cmp_ID,Emp_ID,Def_ID,Lable_Name)
			SELECT @Cmp_ID,emp_ID,18,'Total Days' From #Emp_Cons 
						
			DECLARE @Month_Leave NUMERIC(18,0)
			DECLARE @Year_Leave NUMERIC(18,0)
						
			DECLARE @Temp_Date_Leave DATETIME
			DECLARE @count_Leave  NUMERIC 
						
			DECLARE @SQL VARCHAR(Max)
			DECLARE @SQL_Present VARCHAR(Max)
						
			SET @Temp_Date_Leave = @From_Date 
			SET @count_Leave = 1 

			WHILE @Temp_Date_Leave <=@To_Date 
				BEGIN
					SET @SQL = ''
					SET @SQL_Present = ''
								
					SET @Month_Leave =month(@Temp_Date_Leave)
					SET @Year_Leave = year(@Temp_Date_Leave)
					
					SET @SQL = 'Alter Table #Yearly_Salary_1 ADD Month_'+Cast(@count_Leave AS varchar) +' NUMERIC(18,2) NOT NULL default(0)'
					Execute(@SQL)
							
					SET @SQL_Present = 'UPDATE #Yearly_Salary_1 
						SET		Month_'+Cast(@count_Leave AS varchar) +' = Present_Days 
						FROM	#Yearly_Salary_1  Ys  inner join T0200_Monthly_Salary MS ON YS.EMP_ID = MS.EMP_ID 
						WHERE	Month(Month_End_Date) = '+ Cast(@Month_Leave AS VARCHAR(10)) +' AND Year(Month_End_Date) = '+ Cast(@Year_Leave AS VARCHAR(10)) +' AND Def_ID = 1'
					Execute(@SQL_Present)
								
					SET @SQL_Present = 'UPDATE #Yearly_Salary_1 
						SET		Month_'+Cast(@count_Leave AS varchar) +' = Weekoff_Days
						FROM	#Yearly_Salary_1  Ys  inner join T0200_Monthly_Salary MS ON YS.EMP_ID = MS.EMP_ID 
						WHERE	Month(Month_End_Date) = '+ Cast(@Month_Leave AS VARCHAR(10)) +' AND Year(Month_End_Date) = '+ Cast(@Year_Leave AS VARCHAR(10)) +' AND Def_ID = 2'
					Execute(@SQL_Present)
								
					SET @SQL_Present = 'UPDATE #Yearly_Salary_1 
						SET		Month_'+Cast(@count_Leave AS varchar) +' = Holiday_Days
						FROM	#Yearly_Salary_1  Ys  inner join T0200_Monthly_Salary MS ON YS.EMP_ID = MS.EMP_ID 
						WHERE	Month(Month_End_Date) = '+ Cast(@Month_Leave AS VARCHAR(10)) +' AND Year(Month_End_Date) = '+ Cast(@Year_Leave AS VARCHAR(10)) +' AND Def_ID = 3'
					Execute(@SQL_Present)
								
								
					SET @SQL_Present = 'UPDATE #Yearly_Salary_1 
						SET		Month_'+Cast(@count_Leave AS varchar) +' = Absent_Days - isnull(leave_Sum,0)
						From	#Yearly_Salary_1  Ys  
								LEFT OUTER JOIN (SELECT (SUM(CASE WHEN Lm.Apply_Hourly=1 THEN isnull(LEAVE_USED,0)/8 ELSE isnull(LEAVE_USED,0) end)) as leave_Sum,Lt.emp_id 
												FROM	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
														INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LM.Leave_ID = LT.Leave_ID
														INNER JOIN #EMP_CONS EC  ON Ec.Emp_id = LT.Emp_id
												WHERE	For_Date >= '''+ cast(@Temp_Date_Leave as VARCHAR(20))+''' AND  LM.Leave_Paid_Unpaid = ''U'' 
														AND For_Date < dateadd(m,1,'''+ cast(@Temp_Date_Leave as VARCHAR(20))+''') 
												GROUP BY LT.emp_id 
												)TLT ON YS.emp_ID = TLT.emp_ID 
								INNER JOIN T0200_Monthly_Salary MS ON YS.emp_ID = MS.emp_ID
						WHERE	Month(Month_End_Date) = '+ Cast(@Month_Leave AS VARCHAR(10)) +' AND Year(Month_End_Date) = '+ Cast(@Year_Leave AS VARCHAR(10)) +' AND Def_ID = 4' 
					Execute(@SQL_Present)
								
								
					SET @SQL_Present = 'UPDATE #Yearly_Salary_1 
						SET		Month_'+Cast(@count_Leave AS varchar) +' = leave_Sum
						FROM	#Yearly_Salary_1  Ys  
								INNER JOIN (SELECT (
													SUM(CASE WHEN Lm.Apply_Hourly=1 THEN isnull(LEAVE_USED,0)/8 ELSE isnull(LEAVE_USED,0) end) 
														+ 
													Sum(CASE WHEN Lm.Apply_Hourly=1 THEN isnull(CompOff_Used,0)/8 ELSE isnull(CompOff_Used,0) end)
													) as leave_Sum,Lt.Leave_ID,emp_id 
											FROM	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
													INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.Leave_ID = Lm.Leave_id
											WHERE	For_Date >= '''+ cast(@Temp_Date_Leave as VARCHAR(20))+''' AND For_Date < dateadd(m,1,'''+ cast(@Temp_Date_Leave as VARCHAR(20))+''')
											GROUP BY Lt.Leave_ID,emp_id
											)TLT ON YS.Leave_ID = TLT.Leave_ID AND YS.emp_ID = TLT.emp_ID 
								INNER JOIN T0200_Monthly_Salary MS WITH (NOLOCK) ON YS.emp_ID = ms.emp_ID
						WHERE	Month(Month_End_Date) = '+ Cast(@Month_Leave AS VARCHAR(10)) +' AND Year(Month_End_Date) = '+ Cast(@Year_Leave AS VARCHAR(10)) +''
					Execute(@SQL_Present)
								
					SET @SQL_Present = 'UPDATE #Yearly_Salary_1 
						SET		Month_'+Cast(@count_Leave AS varchar) +' = total_days
						FROM	#Yearly_Salary_1  Ys  
								INNER JOIN (SELECT	SUM(Month_'+Cast(@count_Leave AS varchar) +') AS Total_Days,Emp_ID
											FROM	#Yearly_Salary_1 group by emp_id ) TLT ON YS.Emp_ID = TLT.Emp_ID 
						WHERE	Def_ID = 18'
								
					EXEC(@SQL_Present)
								
					SET @Temp_Date_Leave = DateAdd(m,1,@Temp_Date_Leave)
					SET @count_Leave = @count_Leave + 1 								
				End	
			
			UPDATE	#Yearly_Salary_1
			SET		TOTAL = MONTH_1 + MONTH_2 + MONTH_3 + MONTH_4 + MONTH_5 +MONTH_6
					
			SELECT	@From_Date as From_Date, * 
			From	#Yearly_Salary_1 
			ORDER BY Emp_Id,Row_ID		
						
		END 		
	RETURN 




