

---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_GET_LEAVE_YEARLY_BKronak020824]
	 @Cmp_ID 		NUMERIC
	,@FROM_Date 	datetime
	,@To_Date 		datetime
	,@Branch_ID 	NUMERIC
	,@Cat_ID 		NUMERIC 
	,@Grd_ID 		NUMERIC
	,@Type_ID 		NUMERIC
	,@Dept_ID 		NUMERIC
	,@Desig_ID 		NUMERIC
	,@Emp_ID 		NUMERIC
	,@Constraint 	varchar(MAX)
	
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

	DECLARE @Join_Date as DATETIME --Mukti(17082017)
		
	CREATE TABLE #Emp_Cons 	
	(      
		Emp_ID			NUMERIC,     
		Branch_ID		NUMERIC,
		Increment_ID	NUMERIC    
	)	
	EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@FROM_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@Constraint ,0 ,0 ,0 ,0 ,0 ,0 
	

	CREATE TABLE #Yearly_Leave_Report
	(
		Row_ID			NUMERIC IDENTITY (1,1) not NULL,
		Cmp_ID			NUMERIC,
		Emp_Id			NUMERIC,
		Leave_ID		NUMERIC,
		Emp_Join_Date	DateTime,
		Emp_Left_Date	DateTime,
		Month_1_Dr		NUMERIC(12,2) default 0,
		Month_1_Cr		NUMERIC(12,2) default 0,
		Month_1_LE		NUMERIC(12,2) default 0,	--Ankit 10052013 for leave encash
		Month_1_Cl		NUMERIC(12,2) default 0,
		Month_1_LPS		NUMERIC(12,2) default 0,   --AR
		Month_2_Dr		NUMERIC(12,2) default 0,
		Month_2_Cr		NUMERIC(12,2) default 0,
		Month_2_LE		NUMERIC(12,2) default 0,
		Month_2_Cl		NUMERIC(12,2) default 0,
		Month_2_LPS		NUMERIC(12,2) default 0,   --AR
		Month_3_Dr		NUMERIC(12,2) default 0,
		Month_3_Cr		NUMERIC(12,2) default 0,
		Month_3_LE		NUMERIC(12,2) default 0,
		Month_3_Cl		NUMERIC(12,2) default 0,
		Month_3_LPS		NUMERIC(12,2) default 0,   --AR
		Month_4_Dr		NUMERIC(12,2) default 0,
		Month_4_Cr		NUMERIC(12,2) default 0,
		Month_4_LE		NUMERIC(12,2) default 0,
		Month_4_Cl		NUMERIC(12,2) default 0,
		Month_4_LPS		NUMERIC(12,2) default 0,   --AR
		Month_5_Dr		NUMERIC(12,2) default 0,
		Month_5_Cr		NUMERIC(12,2) default 0,
		Month_5_LE		NUMERIC(12,2) default 0,
		Month_5_Cl		NUMERIC(12,2) default 0,
		Month_5_LPS		NUMERIC(12,2) default 0,   --AR
		Month_6_Dr		NUMERIC(12,2) default 0,
		Month_6_Cr		NUMERIC(12,2) default 0,
		Month_6_LE		NUMERIC(12,2) default 0,
		Month_6_Cl		NUMERIC(12,2) default 0,
		Month_6_LPS		NUMERIC(12,2) default 0,   --AR
		Month_7_Dr		NUMERIC(12,2) default 0,
		Month_7_Cr		NUMERIC(12,2) default 0,
		Month_7_LE		NUMERIC(12,2) default 0,
		Month_7_Cl		NUMERIC(12,2) default 0,
		Month_7_LPS		NUMERIC(12,2) default 0,  --AR
		Month_8_Dr		NUMERIC(12,2) default 0,
		Month_8_Cr		NUMERIC(12,2) default 0,
		Month_8_LE		NUMERIC(12,2) default 0,
		Month_8_Cl		NUMERIC(12,2) default 0,
		Month_8_LPS		NUMERIC(12,2) default 0,   --AR
		Month_9_Dr		NUMERIC(12,2) default 0,
		Month_9_Cr		NUMERIC(12,2) default 0,
		Month_9_LE		NUMERIC(12,2) default 0,
		Month_9_Cl		NUMERIC(12,2) default 0,
		Month_9_LPS		NUMERIC(12,2) default 0,   --AR
		Month_10_Dr		NUMERIC(12,2) default 0,
		Month_10_Cr		NUMERIC(12,2) default 0,
		Month_10_LE		NUMERIC(12,2) default 0,
		Month_10_Cl		NUMERIC(12,2) default 0,
		Month_10_LPS	NUMERIC(12,2) default 0,   --AR
		Month_11_Dr		NUMERIC(12,2) default 0,
		Month_11_Cr		NUMERIC(12,2) default 0,
		Month_11_LE		NUMERIC(12,2) default 0,
		Month_11_Cl		NUMERIC(12,2) default 0,
		Month_11_LPS	NUMERIC(12,2) default 0,   --AR
		Month_12_Dr		NUMERIC(12,2) default 0,
		Month_12_Cr		NUMERIC(12,2) default 0,
		Month_12_LE		NUMERIC(12,2) default 0,
		Month_12_Cl		NUMERIC(12,2) default 0,
		Month_12_LPS	NUMERIC(12,2) default 0,   --AR
		Total_Dr		NUMERIC(12,2) default 0,
		Total_Cr		NUMERIC(12,2) default 0,
		Total_LE		NUMERIC(12,2) default 0,
		Total_Cl		NUMERIC(12,2) default 0,
		Total_LPS		NUMERIC(12,2) default 0,   --AR
	)
			
	CREATE TABLE #Emp_Leave_Bal 
	(  
		Cmp_ID				NUMERIC,  
		Emp_ID				NUMERIC,  
		For_Date			DATETIME,  
		Leave_Opening		NUMERIC(18,2),  
		Leave_Credit		NUMERIC(18,2),  
		Leave_Used			NUMERIC(18,2),  
		Leave_Encash_Days	NUMERIC(18,2),
		Leave_Closing		NUMERIC(18,2),  
		Leave_ID			NUMERIC  
	)
	
	INSERT	INTO #Yearly_Leave_Report(Cmp_ID,Emp_ID,Leave_ID,Emp_Join_Date, Emp_Left_Date)
	SELECT	@Cmp_ID,EC.Emp_ID,LM.Leave_ID,Date_Of_Join, IsNull(Emp_Left_Date, @To_Date+1) --To remove the unnecessary IsNull AND OR Condition if employee is not left
	FROM	#Emp_Cons EC 
			INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON EC.Emp_ID=E.Emp_ID
			INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON EC.Increment_ID=I.Increment_ID										
			INNER JOIN T0050_LEAVE_DETAIL LD WITH (NOLOCK) ON I.Grd_ID=LD.Grd_ID 
			INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LM.Leave_ID=LD.Leave_ID
	WHERE	LM.Cmp_ID = @Cmp_ID AND IsNull(LM.Default_Short_Name,'') NOT IN('COPH','COND') --Added by Sumit ON 14102016 -- Compoff removed from this query, as Ashiana needs Compoff Used Balance in report, Hardik 15/10/2018
			AND LM.Display_Leave_Balance = 1 AND LM.lEAVE_TYPE <> 'Company Purpose'					
			AND EXISTS(SELECT 1 FROM T0140_Leave_Transaction LT1 WITH (NOLOCK) WHERE EC.Emp_ID=LT1.Emp_ID AND LM.Leave_ID=LT1.Leave_ID AND LT1.For_Date < @To_Date)
	Group BY EC.Emp_ID,LM.Leave_ID,Date_Of_Join,Emp_Left_Date
	
	
   			
	DECLARE @For_Date DATETIME
	SET  @For_Date  = @FROM_Date
	
	DECLARE @Month_Index TINYINT
	DECLARE @sMonth_Field VARCHAR(32)
	
	SELECT	YS.Emp_ID,YS.Leave_ID,For_Month,For_Year,Leave_Credit,Leave_Encash_Days,CF_Laps_Days,Leave_Used
	INTO	#YL_Detail
	FROM	#Yearly_Leave_Report YS
			INNER JOIN (SELECT	T.EMP_ID,T.Leave_ID,Month(For_Date) As For_Month, Year(For_Date) As For_Year,
								SUM(case when CompOff_Used = 0 then Leave_Used Else CompOff_Used  END)+SUM(Back_Dated_Leave)+ Isnull(sum(Leave_Adj_L_Mark),0) as Leave_Used,
								SUM(case when CompOff_Credit = 0 then Leave_Credit Else CompOff_Credit  END) leave_Credit,
								SUM(Leave_Encash_Days) Leave_Encash_Days ,(Isnull(SUM(CF_Laps_Days),0) + Isnull(SUM(Leave_Posting),0))CF_Laps_Days  
						FROM	T0140_LEAVE_TRANSACTION T WITH (NOLOCK)
								INNER JOIN #Yearly_Leave_Report YS ON T.Emp_ID=YS.Emp_ID AND T.Leave_ID=YS.Leave_ID AND T.For_Date Between YS.Emp_Join_Date AND YS.Emp_Left_Date
						WHERE	T.CMP_ID = @Cmp_ID AND For_Date BETWEEN @From_Date AND @To_Date
						GROUP BY T.EMP_ID,T.Leave_ID,Month(For_Date),Year(For_Date))Q ON YS.emp_Id = Q.emp_ID AND YS.Leave_ID = Q.Leave_ID
	
	

	DECLARE @sFilter Varchar(MAX)
	DECLARE @sqlQuery Varchar(MAX)
	DECLARE @Month_End_Date DateTime
	SET @Month_Index = 0
	WHILE @For_Date <= @To_Date
		BEGIN
			SET @Month_Index = @Month_Index + 1
			SET @Month_End_Date = dbo.GET_MONTH_END_DATE(month(@For_Date),Year(@For_Date))
			
 			SET @sMonth_Field = 'Month_'+ CAST(@Month_Index as varchar(10))
			
			SET	@sFilter = 'For_Month = ' + Cast(Month(@For_Date) As Varchar(4)) + ' AND For_Year = ' + Cast(Year(@For_Date) As Varchar(4))
 			
 			
			SET @sqlQuery = 'UPDATE YS
							 Set	' + @sMonth_Field +'_Cr= Leave_Credit,
									' + @sMonth_Field + '_LE = Leave_Encash_Days,
									' + @sMonth_Field + '_LPS = CF_Laps_Days,
									' + @sMonth_Field + '_Dr = Leave_Used
							 FROM	#Yearly_Leave_Report YS  
									INNER JOIN #YL_Detail LD ON YS.Emp_ID=LD.Emp_ID AND YS.Leave_ID=LD.Leave_ID
							 WHERE	' + @sFilter
								
						
					
			EXEC(@sqlQuery)	
					
			SET @sqlQuery = 'UPDATE YS
							 SET	' + @sMonth_Field + '_CL = (Case when Emp_Left_Date <= '''+ cast(@For_Date AS varchar(20)) +''' THEN 0 Else leave_Closing End)
							 FROM	#Yearly_Leave_Report YS  
									INNER JOIN (SELECT	LT.Emp_ID,LT.Leave_ID,case when CompOff_Balance = 0 then LT.leave_Closing else CompOff_Balance end as leave_Closing  
												FROM	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
														INNER JOIN(SELECT	MAX(For_Date) For_Date,T.Emp_ID,T.Leave_ID 
																   FROM		T0140_LEAVE_TRANSACTION T WITH (NOLOCK)
																			INNER JOIN #Yearly_Leave_Report YS ON T.Emp_ID=YS.Emp_ID AND T.Leave_ID=YS.Leave_ID AND T.For_Date Between YS.Emp_Join_Date AND YS.Emp_Left_Date
																   WHERE	For_Date <= ''' + Cast(@Month_End_Date as varchar(20)) + ''' 																			
																   Group by T.Emp_ID,T.Leave_ID) Qry ON LT.Emp_ID = Qry.Emp_ID AND LT.For_Date = Qry.For_Date AND LT.Leave_ID=Qry.Leave_ID 
												) Q ON YS.Emp_ID = Q.Emp_ID AND YS.Leave_ID = Q.Leave_ID 
									Inner join T0040_Leave_Master LM WITH (NOLOCK) On YS.Leave_Id= LM.Leave_Id
								Where (Default_Short_Name <> ''COMP'' or Default_Short_Name is null)' --- Added condition by Hardik 14/10/2019 as DPL client has query closing of compoff is showing wrong
				
			Exec(@sqlQuery)	
			
			
			--- Added condition by Hardik 14/10/2019 as DPL client has query closing of compoff is showing wrong
			SET @sqlQuery = 'UPDATE YS
							 SET	' + @sMonth_Field + '_CL = (Case when Emp_Left_Date <= '''+ cast(@For_Date AS varchar(20)) +''' THEN 0 Else Isnull(leave_Closing,0) End)
							 FROM	#Yearly_Leave_Report YS  
									INNER JOIN (SELECT	LT.Emp_ID,LT.Leave_ID, Sum(CompOff_Balance) as leave_Closing  
												FROM	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
												WHERE	For_Date between ''' + Cast(@For_Date as varchar(20)) + ''' And ''' + Cast(@Month_End_Date as varchar(20)) + ''' 																			
												Group by LT.Emp_ID,LT.Leave_ID) Q ON YS.Emp_ID = Q.Emp_ID AND YS.Leave_ID = Q.Leave_ID
									Inner join T0040_Leave_Master LM WITH (NOLOCK) On YS.Leave_Id= LM.Leave_Id
								Where Default_Short_Name = ''COMP'''
			Exec(@sqlQuery)	
			
			
					
			INSERT	INTO #Emp_Leave_Bal
			SELECT	@Cmp_ID,Lt.Emp_Id,@Month_End_Date,0,0,0,0,0,LT.Leave_ID 
			FROM	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
					INNER JOIN #Yearly_Leave_Report YS ON LT.Emp_ID=YS.Emp_ID AND LT.Leave_ID=YS.Leave_ID AND LT.For_Date Between YS.Emp_Join_Date AND YS.Emp_Left_Date
					INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.Leave_ID = LM.Leave_ID --AND IsNull(LM.Default_Short_Name,'') <> 'COMP'
					INNER JOIN (SELECT	MAX(For_Date) For_Date,LT1.Leave_ID,LT1.Emp_ID 
								FROM	T0140_LEAVE_TRANSACTION LT1 WITH (NOLOCK)
										INNER JOIN #Yearly_Leave_Report YS1 ON LT1.Emp_ID=YS1.Emp_ID AND LT1.Leave_ID=YS1.Leave_ID AND LT1.For_Date Between YS1.Emp_Join_Date AND YS1.Emp_Left_Date
								WHERE	FOR_DATE <=@Month_End_Date
								GROUP BY LT1.EMP_ID,LT1.Leave_ID) Q ON LT.EMP_ID = Q.EMP_ID AND LT.Leave_ID = Q.Leave_ID AND LT.FOR_DATE = Q.FOR_DATE 			
			WHERE	LEAVE_TYPE <> 'Company Purpose'
			
			
			--Getting Leave Opening	
			--Last Closing Carry Forward As Opening		
			UPDATE	LB
			SET		Leave_Opening = Leave_Bal.Leave_Closing  
			From	#Emp_Leave_Bal LB 
					INNER JOIN (SELECT	LT.Leave_ID,LT.Emp_ID,(Leave_Opening + Leave_Credit) - (Leave_Used + Isnull(Leave_Adj_L_Mark,0)+ Isnull(Leave_Encash_Days,0) + Isnull(Back_Dated_Leave,0) + Isnull(Arrear_Used,0)+Isnull(CF_Laps_Days,0)) as Leave_Closing
								From	T0140_leave_Transaction LT WITH (NOLOCK)
										INNER JOIN (SELECT	MAX(For_Date) For_Date, T.Emp_ID ,Leave_ID 
													FROM	T0140_Leave_Transaction T WITH (NOLOCK)
															INNER JOIN #Emp_Cons EC ON T.Emp_ID=EC.Emp_ID
													WHERE	For_date <= @For_Date AND Cmp_ID = @Cmp_ID
													Group by T.Emp_ID ,Leave_ID) Q ON LT.Emp_Id = Q.Emp_ID AND LT.For_Date = Q.For_Date AND LT.Leave_ID = Q.Leave_ID  
								)Leave_Bal ON LB.Leave_ID = Leave_Bal.Leave_ID AND LB.Emp_ID = Leave_Bal.Emp_ID
			Where	For_Date = @Month_End_Date
			
			--Take if Opening is Given
			UPDATE	LB
			SET		Leave_Opening = Leave_Bal.Leave_Opening  
			From	#Emp_Leave_Bal LB 
					INNER JOIN (SELECT	LT.Leave_ID,LT.Emp_ID,LT.Leave_Opening 
								From	T0140_leave_Transaction LT WITH (NOLOCK)
										INNER JOIN (SELECT	MAX(For_Date) For_Date, T.Emp_ID ,Leave_ID 
													FROM	T0140_Leave_Transaction T WITH (NOLOCK)
															INNER JOIN #Emp_Cons EC ON T.Emp_ID=EC.Emp_ID
													WHERE	For_date = @For_Date AND Cmp_ID = @Cmp_ID 
													Group by T.Emp_ID ,Leave_ID) Q ON LT.Emp_Id = Q.Emp_ID AND LT.For_Date = Q.For_Date AND LT.Leave_ID = Q.Leave_ID  
								)Leave_Bal ON LB.Leave_ID = Leave_Bal.Leave_ID AND LB.Emp_ID = Leave_Bal.Emp_ID
			Where	For_Date = @Month_End_Date
			
			--Leave Credit & Leave Used
			UPDATE	LB
			SET		Leave_Credit = Q.Leave_Credit,
					Leave_Used = Q.Leave_Used
			From	#Emp_Leave_Bal LB 					
					INNER JOIN (SELECT	T.Emp_ID ,Leave_ID, Sum(Leave_Credit) As Leave_Credit, Sum(Leave_Used) As Leave_Used
								FROM	T0140_Leave_Transaction T WITH (NOLOCK)
										INNER JOIN #Emp_Cons EC ON T.Emp_ID=EC.Emp_ID
								WHERE	For_date BETWEEN @For_Date AND @Month_End_Date AND Cmp_ID = @Cmp_ID and  T.Leave_Posting is NULL
								Group by T.Emp_ID ,Leave_ID) Q ON LB.Emp_Id = Q.Emp_ID AND LB.Leave_ID = Q.Leave_ID  
			Where	For_Date = @Month_End_Date
								
			--Leave Encash Days & Leave Closing
			UPDATE	LB
			SET		Leave_Encash_Days = Leave_Bal.Leave_Encash_Days
					--Leave_Closing = Leave_Bal.Leave_Closing
			From	#Emp_Leave_Bal LB 
					INNER JOIN (SELECT	LT.Leave_ID,LT.Emp_ID,LT.Leave_Encash_Days,LT.Leave_Closing
								From	T0140_leave_Transaction LT WITH (NOLOCK)
										INNER JOIN (SELECT	MAX(For_Date) For_Date, T.Emp_ID ,Leave_ID 
													FROM	T0140_Leave_Transaction T WITH (NOLOCK)
															INNER JOIN #Emp_Cons EC ON T.Emp_ID=EC.Emp_ID
													WHERE	For_date <= @Month_End_Date AND Cmp_ID = @Cmp_ID
													Group by T.Emp_ID ,Leave_ID) Q ON LT.Emp_Id = Q.Emp_ID AND LT.For_Date = Q.For_Date AND LT.Leave_ID = Q.Leave_ID  
								WHERE	LT.Leave_Encash_Days > 0
								)Leave_Bal ON LB.Leave_ID = Leave_Bal.Leave_ID AND LB.Emp_ID = Leave_Bal.Emp_ID
			Where	For_Date = @Month_End_Date
						  
						 
			--added By Jimit as there is closing is not coming from above query case at WCl 06122018
			UPDATE	LB
			SET		
					Leave_Closing = Leave_Bal.Leave_Closing
			From	#Emp_Leave_Bal LB 
					INNER JOIN (SELECT	LT.Leave_ID,LT.Emp_ID,LT.Leave_Encash_Days,LT.Leave_Closing
								From	T0140_leave_Transaction LT WITH (NOLOCK)
										INNER JOIN (SELECT	MAX(For_Date) For_Date, T.Emp_ID ,Leave_ID 
													FROM	T0140_Leave_Transaction T WITH (NOLOCK)
															INNER JOIN #Emp_Cons EC ON T.Emp_ID=EC.Emp_ID
													WHERE	For_date <= @Month_End_Date AND Cmp_ID = @Cmp_ID
													Group by T.Emp_ID ,Leave_ID) Q ON LT.Emp_Id = Q.Emp_ID AND LT.For_Date = Q.For_Date AND LT.Leave_ID = Q.Leave_ID  
								--WHERE	LT.Leave_Encash_Days > 0
								)Leave_Bal ON LB.Leave_ID = Leave_Bal.Leave_ID AND LB.Emp_ID = Leave_Bal.Emp_ID
			Where	For_Date = @Month_End_Date and Lb.Leave_Id = Leave_Bal.Leave_Id
			--ended
 			SET @For_Date = DATEADD(M,1, @For_Date)
		END
		
	UPDATE  #Yearly_Leave_Report 
	SET		Total_Dr = Month_1_Dr + Month_2_Dr + Month_3_Dr + Month_4_Dr + Month_5_Dr +Month_6_Dr + Month_7_Dr + Month_8_Dr + Month_9_Dr + Month_10_Dr + Month_11_Dr + Month_12_Dr,
			Total_Cr = Month_1_Cr + Month_2_Cr + Month_3_Cr + Month_4_Cr + Month_5_Cr +Month_6_Cr + Month_7_Cr + Month_8_Cr + Month_9_Cr + Month_10_Cr + Month_11_Cr + Month_12_Cr,
			Total_LE = Month_1_LE + Month_2_LE + Month_3_LE + Month_4_LE + Month_5_LE +Month_6_LE + Month_7_LE + Month_8_LE + Month_9_LE + Month_10_LE + Month_11_LE + Month_12_LE,
			Total_Cl = Month_1_Cl + Month_2_Cl + Month_3_Cl + Month_4_Cl + Month_5_Cl +Month_6_Cl + Month_7_Cl + Month_8_Cl + Month_9_Cl + Month_10_Cl + Month_11_Cl + Month_12_Cl,
			Total_LPS = Month_1_LPS + Month_2_LPS + Month_3_LPS + Month_4_LPS + Month_5_LPS +Month_6_LPS + Month_7_LPS + Month_8_LPS + Month_9_LPS + Month_10_LPS + Month_11_LPS + Month_12_LPS	
	

	Declare @Leave_Closing as Numeric(18,2) = 0
	
	SELECT distinct	T.Emp_ID, T.For_Date,T.Leave_ID, T.Leave_Opening,T1.Leave_Encash_Days,@Leave_Closing AS Leave_Closing
	INTO	#E_BALANCE
	FROM	#Emp_Leave_Bal T
			INNER JOIN (SELECT MIN(FOR_DATE) AS FOR_DATE,sUM(Leave_Encash_Days) AS Leave_Encash_Days, EMP_ID,Leave_ID
						FROM #Emp_Leave_Bal Where Leave_Opening >0 GROUP BY EMP_ID,Leave_ID) T1 ON T.Emp_ID=T1.Emp_ID AND T.For_Date=T1.FOR_DATE and T.Leave_ID  = T1.Leave_ID			

	UPDATE	B
	SET		B.Leave_Closing=T.Leave_Closing
	FROM	#E_BALANCE B
			INNER JOIN #Emp_Leave_Bal T ON B.Emp_ID=T.Emp_ID AND B.Leave_ID=T.Leave_ID
			INNER JOIN (SELECT MAX(FOR_DATE) AS FOR_DATE,Leave_ID, EMP_ID FROM #Emp_Leave_Bal 
						--WHerE For_Date <= GETDATE()
						GROUP BY EMP_ID,Leave_ID) T1 ON T.Emp_ID=T1.Emp_ID AND T.For_Date=T1.FOR_DATE AND T.Leave_ID=T1.Leave_ID


	SELECT  YS.*,LM.lEave_Code,ELB.Leave_Opening,ELB.Leave_Encash_Days,ELB.Leave_Closing,Grd_NAme,Dept_Name,Comp_name,Branch_Address,Desig_Name,Branch_NAme,Type_Name,
			Cmp_NAme,Cmp_Address,Emp_Code,Alpha_Emp_Code,Emp_First_Name,cast(Alpha_Emp_Code as varchar) +' - '+ Emp_Full_Name as Emp_Full_Name ,LEAVE_NAME,Em.Date_of_join,Em.Emp_Confirm_Date,
			@From_Date as P_From_Date , @To_Date as P_To_Date,BM.Branch_ID
	FROM	#Yearly_Leave_Report YS 
			INNER JOIN #Emp_Cons EC ON YS.Emp_ID=EC.Emp_ID
			INNER JOIN T0095_Increment IQ WITH (NOLOCK) ON EC.Increment_ID=IQ.Increment_ID
			INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON YS.EMP_ID = EM.EMP_ID
			INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON IQ.Grd_ID = GM.Grd_ID
			INNER JOIN T0030_Branch_Master BM WITH (NOLOCK) ON IQ.Branch_ID = BM.Branch_ID
			INNER JOIN T0010_COMPANY_MASTER cm WITH (NOLOCK) ON YS.Cmp_ID = CM.Cmp_ID
			INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON YS.Leave_ID =LM.Leave_ID			
			LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON IQ.Type_ID = ETM.Type_ID
			LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON IQ.Desig_Id = DGM.Desig_Id
			LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON IQ.Dept_Id = DM.Dept_Id			
			LEFT OUTER JOIN #E_BALANCE ELB ON YS.Leave_ID=ELB.Leave_ID AND YS.Emp_ID=ELB.Emp_ID		
	WHERE	LM.Display_leave_balance = 1 AND LM.lEAVE_TYPE <> 'Company Purpose' 			
	ORDER BY LM.Leave_Sorting_No, RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500),Row_ID
	--YS.Leave_ID DESC	
	--RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500),Row_ID,
			
					
	RETURN 




