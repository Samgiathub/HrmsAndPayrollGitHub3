---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_EMP_STRENGTH_GET]   
  @Cmp_ID  NUMERIC  
 ,@From_Date  DATETIME  
 ,@To_Date  DATETIME  
 ,@Branch_ID  NUMERIC   
 ,@Cat_ID  NUMERIC  
 ,@Grd_ID  NUMERIC  
 ,@Type_ID  NUMERIC   
 ,@Dept_Id  NUMERIC  
 ,@Desig_Id  NUMERIC  
 ,@Emp_ID  NUMERIC  
 ,@Constraint VARCHAR(MAX)   
 ,@Report_Type VARCHAR(30)= ''  
 ,@Variance_Filter_From	NUMERIC(18,0) = 0	--Ankit 30102015
 ,@Variance_Filter_To	NUMERIC(18,0) = 0	--Ankit 30102015
 ,@Flag tinyint = 0
 ,@Drildown_Flag tinyint = 0
 
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
SET ANSI_WARNINGS OFF;
 
IF @Flag = 0
	BEGIN
		IF @Report_Type = 'SELECT STRENGH'  
			BEGIN
				SET @Report_Type = 'select'
			END

		IF @VARIANCE_FILTER_FROM = 0 AND @VARIANCE_FILTER_TO = 0
			BEGIN
				SET @VARIANCE_FILTER_FROM = -999999999999
				SET @VARIANCE_FILTER_TO = 999999999999
			END	

		DECLARE @Pre_From_Date AS DATETIME
		DECLARE @Pre_To_Date AS DATETIME

		SELECT	TOP 1 @From_Date=Month_St_Date, @To_Date=Month_End_Date 
		From	T0200_Monthly_Salary WITH (NOLOCK)
		Where	Month(Month_End_Date)=Month(@To_Date) AND Year(Month_End_Date)=Year(@To_Date)
				AND Cmp_ID=@Cmp_ID
		
		SET @Pre_To_Date = DateAdd(dd,-1, @From_Date)
		
		SELECT	TOP 1 @Pre_From_Date=Month_St_Date, @Pre_To_Date=Month_End_Date 
		From	T0200_Monthly_Salary WITH (NOLOCK)
		Where	Month(Month_End_Date)=Month(@Pre_To_Date) AND Year(Month_End_Date)=Year(@Pre_To_Date)
				AND Cmp_ID=@Cmp_ID

	
		 IF @Branch_ID = 0  
		  SET @Branch_ID = NULL  
		 IF @Cat_ID = 0  
		  SET @Cat_ID  = NULL  
		 IF @Type_ID = 0  
		  SET @Type_ID = NULL  
		 IF @Dept_ID = 0  
		  SET @Dept_ID = NULL  
		 IF @Grd_ID = 0  
		  SET @Grd_ID = NULL  
		 IF @Desig_ID = 0  
		  SET @Desig_ID = NULL  
		 IF @Emp_ID = 0  
		  SET @Emp_ID = NULL  
    
		 DECLARE @Emp_Cons TABLE  
		  (  
		   Emp_ID NUMERIC  
		  )  
   
		 IF @Constraint <> ''  
			  BEGIN  
				   INSERT INTO @Emp_Cons  
				   SELECT  CAST(DATA  AS NUMERIC) FROM dbo.Split (@Constraint,'#')   
			  END  
		 ELSE  
			  BEGIN  
					INSERT INTO @Emp_Cons  
				   SELECT I.Emp_Id FROM T0095_Increment I WITH (NOLOCK) INNER JOIN   
					 ( SELECT MAX(Increment_ID) AS Increment_ID , Emp_ID FROM T0095_Increment WITH (NOLOCK)	-- Ankit 10092014 for Same Date Increment
					 WHERE Increment_Effective_date <= @To_Date  
					 AND Cmp_ID = @Cmp_ID  
					 GROUP BY emp_ID  ) Qry ON  
					 I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID   
				   WHERE Cmp_ID = @Cmp_ID   
					   AND ISNULL(Cat_ID,0) = ISNULL(@Cat_ID ,ISNULL(Cat_ID,0))  
					   AND Branch_ID = ISNULL(@Branch_ID ,Branch_ID)  
					   AND Grd_ID = ISNULL(@Grd_ID ,Grd_ID)  
					   AND ISNULL(Dept_ID,0) = ISNULL(@Dept_ID ,ISNULL(Dept_ID,0))  
					   AND ISNULL(TYPE_ID,0) = ISNULL(@Type_ID ,ISNULL(TYPE_ID,0))  
					   AND ISNULL(Desig_ID,0) = ISNULL(@Desig_ID ,ISNULL(Desig_ID,0))  
					   AND I.Emp_ID = ISNULL(@Emp_ID ,I.Emp_ID)   
					   AND I.Emp_ID IN   
						( SELECT Emp_Id FROM  
							(SELECT emp_id, cmp_ID, join_Date, ISNULL(left_Date, @To_date) AS left_Date FROM T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)
						) qry  
					WHERE cmp_ID = @Cmp_ID   AND    
					(( @From_Date  >= join_Date  AND  @From_Date <= left_date )   
					OR ( @To_Date  >= join_Date  AND @To_Date <= left_date )  
					OR Left_date IS NULL AND @To_Date >= Join_Date)  
					OR @To_Date >= left_date  AND  @From_Date <= left_date )   
			  END  

		 IF @Report_Type = 'select' OR @Report_Type ='Strenth(Male-Female)'  
			   BEGIN  
					SELECT I_Q.* ,E.Emp_Full_Name , E.Emp_Code,BM.Comp_Name,BM.Branch_Address  
					   ,Dept_Name,Desig_Name,TYPE_NAME,Grd_Name,Branch_Name,Date_of_Join,Gender  
					   ,Cmp_Name,Cmp_Address,@From_Date P_From_Date,@To_date P_To_Date  
					   ,@Report_Type Report_Type  
					FROM T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN @Emp_Cons ec ON e.emp_ID =ec.emp_ID INNER JOIN  
					 ( SELECT I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,TYPE_ID FROM T0095_Increment I WITH (NOLOCK) INNER JOIN   
					   ( SELECT MAX(Increment_ID) AS Increment_ID , Emp_ID FROM T0095_Increment WITH (NOLOCK)  -- Ankit 10092014 for Same Date Increment
					   WHERE Increment_Effective_date <= @To_Date  
					   AND Cmp_ID = @Cmp_ID  
					   GROUP BY emp_ID  ) Qry ON  
					   I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID  ) I_Q   
					  ON E.Emp_ID = I_Q.Emp_ID  INNER JOIN  
					   T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN  
					   T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN  
					   T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN  
					   T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN   
					   T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  INNER JOIN   
					   T0010_COMPANY_MASTER CM WITH (NOLOCK)ON E.CMP_ID = CM.CMP_ID  
					WHERE E.Cmp_ID = @Cmp_Id   
			   END  
		 ELSE IF @Report_Type ='Salary' OR @Report_Type ='Salary(Male-Female)'  
			   BEGIN  
					IF @constraint = ''
						BEGIN
							SELECT    a.Emp_ID, a.Grd_ID, a.Branch_ID, a.Cat_ID, a.Desig_Id, a.Dept_ID, a.Type_ID, em.Emp_Full_Name, em.Emp_code, bm.Comp_Name, em.Alpha_Emp_Code,
								  bm.Branch_Address, DM.Dept_Name, DGM.Desig_Name, ETM.Type_Name, GM.Grd_Name, bm.Branch_Name, em.Date_Of_Join, em.Gender, cm.Cmp_Name, 
								  cm.Cmp_Address, a.Curr_sal AS Net_Amount, @From_Date AS P_From_Date, @To_date AS P_To_Date, @Report_Type AS Report_Type, 
								  a.Prev_Sal AS Pre_Net_Amount, @Pre_From_Date AS Pre_From_Date, @Pre_To_Date AS Pre_To_Date
								  , CASE WHEN a.Prev_Sal > 0 THEN (((a.Curr_sal * 100) / a.Prev_Sal ) - 100 ) ELSE 100 END AS Diff_Per_Amount
								  , (a.Curr_sal - a.Prev_Sal) AS Diff_Amount
								  ,case when a.Prev_Sal = 0 then null when a.Prev_Sal > 0 then a.Pre_Emp_ID end Pre_Emp_ID
								  ,case when a.Curr_sal = 0 then null when a.Curr_sal > 0 then a.Cur_Emp_ID end Cur_Emp_ID
						FROM         (SELECT     ISNULL(t1_1.Emp_ID, ISNULL(t2.Emp_ID, t1_1.Emp_ID)) AS Emp_ID, ISNULL(t1_1.Net_Amount, 0) AS Prev_Sal, ISNULL(t2.Net_Amount, 0) AS Curr_sal, 
																	  ISNULL(t1_1.Grd_ID, ISNULL(t2.Grd_ID, t1_1.Grd_ID)) AS Grd_ID, ISNULL(t1_1.Branch_ID, ISNULL(t2.Branch_ID, t1_1.Branch_ID)) AS Branch_ID, 
																	  ISNULL(t1_1.Cat_ID, ISNULL(t2.Emp_ID, t1_1.Cat_ID)) AS Cat_ID, ISNULL(t1_1.Desig_Id, ISNULL(t2.Desig_Id, t1_1.Desig_Id)) AS Desig_Id, 
																	  ISNULL(t1_1.Dept_ID, ISNULL(t2.Dept_ID, t1_1.Dept_ID)) AS Dept_ID, ISNULL(t1_1.Type_ID, ISNULL(t2.Type_ID, t1_1.Type_ID)) AS TYPE_ID
												,t1_1.Emp_ID AS Pre_Emp_ID
												,t2.Emp_ID As Cur_Emp_ID
											   FROM          (SELECT     t1.Emp_ID, t1.Cmp_ID, t1.Net_Amount, inc.Grd_ID, inc.Branch_ID, inc.Cat_ID, inc.Desig_Id, inc.Dept_ID, inc.Type_ID
																	   FROM          T0200_MONTHLY_SALARY AS t1 WITH (NOLOCK) INNER JOIN
																								  (SELECT     I.Emp_ID, I.Grd_ID, I.Branch_ID, I.Cat_ID, I.Desig_Id, I.Dept_ID, I.Type_ID
																									FROM          T0095_INCREMENT AS I WITH (NOLOCK) INNER JOIN 
																															   (SELECT     MAX(Increment_ID) AS Increment_ID, Emp_ID	-- Ankit 10092014 for Same Date Increment
																																 FROM          (SELECT     Emp_ID, Increment_Effective_Date,Increment_ID
																																						 FROM          T0095_INCREMENT AS T0095_INCREMENT_2 WITH (NOLOCK)
																																						 WHERE      (Increment_Effective_Date <= @Pre_To_Date)) AS T0095_Increment 
																																 GROUP BY Emp_ID) AS Qry ON I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID) AS inc ON 
																							  t1.Emp_ID = inc.Emp_ID
																	   WHERE      (t1.Month_St_Date = @Pre_From_Date) AND (t1.Is_FNF <> 1) AND (inc.Grd_ID = ISNULL(@Grd_ID, inc.Grd_ID)) AND 
																							  (inc.Branch_id = ISNULL(@Branch_ID, inc.Branch_id)) AND (inc.Cat_ID = ISNULL(@Cat_ID, inc.Cat_ID)) AND 
																							  (inc.Type_id = ISNULL(@Type_ID, inc.Type_ID)) AND (inc.Dept_ID = ISNULL(@Dept_ID, inc.Dept_ID)) AND 
																							  (inc.Desig_ID = ISNULL(@Desig_ID, inc.Desig_ID)) AND (inc.Emp_ID = ISNULL(@Emp_ID, inc.Emp_ID))) AS t1_1 FULL OUTER JOIN
																		  (SELECT     t.Emp_ID, t.Net_Amount, inc_1.Grd_ID, inc_1.Branch_ID, inc_1.Cat_ID, inc_1.Desig_Id, inc_1.Dept_ID, inc_1.Type_ID
																			FROM          T0200_MONTHLY_SALARY AS t WITH (NOLOCK) INNER JOIN
																									   (SELECT     I.Emp_ID, I.Grd_ID, I.Branch_ID, I.Cat_ID, I.Desig_Id, I.Dept_ID, I.Type_ID
																										 FROM          T0095_INCREMENT AS I WITH (NOLOCK) INNER JOIN	
																																	(SELECT     MAX(Increment_ID) AS Increment_ID, Emp_ID	-- Ankit 10092014 for Same Date Increment
																																	  FROM          (SELECT     Emp_ID, Increment_Effective_Date,Increment_ID
																																							  FROM          T0095_INCREMENT AS T0095_INCREMENT_1 WITH (NOLOCK)
																																							  WHERE      (Increment_Effective_Date <= @To_Date)) AS T0095_Increment_3
																																	  GROUP BY Emp_ID) AS Qry_1 ON I.Emp_ID = Qry_1.Emp_ID AND I.Increment_ID = Qry_1.Increment_ID) AS inc_1 ON 
																								   t.Emp_ID = inc_1.Emp_ID
																			WHERE      (t.Month_St_Date = @From_Date) AND (t.Is_FNF <> 1) AND (inc_1.Grd_ID = ISNULL(@Grd_ID, inc_1.Grd_ID)) AND 
																								   (inc_1.Branch_ID = ISNULL(@Branch_ID, inc_1.Branch_ID)) AND (inc_1.Cat_ID = ISNULL(@Cat_ID, inc_1.Cat_ID)) AND 
																								   (inc_1.Type_ID = ISNULL(@Type_ID, inc_1.Type_ID)) AND (inc_1.Dept_ID = ISNULL(@Dept_ID, inc_1.Dept_ID)) AND 
																								   (inc_1.Desig_Id = ISNULL(@Desig_ID, inc_1.Desig_Id)) AND (inc_1.Emp_ID = ISNULL(@Emp_ID, inc_1.Emp_ID))) AS t2 ON 
																	  t1_1.Emp_ID = t2.Emp_ID) AS a INNER JOIN
											  T0080_EMP_MASTER AS em WITH (NOLOCK) ON em.Emp_ID = a.Emp_ID INNER JOIN
											  T0010_COMPANY_MASTER AS cm WITH (NOLOCK) ON @Cmp_ID = cm.Cmp_Id INNER JOIN
											  T0030_BRANCH_MASTER AS bm WITH (NOLOCK) ON bm.Branch_ID = a.Branch_ID INNER JOIN
											  T0040_GRADE_MASTER AS GM WITH (NOLOCK) ON a.Grd_ID = GM.Grd_ID LEFT OUTER JOIN--INNER JOIN
											  T0040_TYPE_MASTER AS ETM WITH (NOLOCK) ON a.Type_ID = ETM.Type_ID INNER JOIN
											  T0040_DESIGNATION_MASTER AS DGM WITH (NOLOCK) ON a.Desig_Id = DGM.Desig_ID LEFT OUTER JOIN --INNER JOIN
											  T0040_DEPARTMENT_MASTER AS DM WITH (NOLOCK) ON a.Dept_ID = DM.Dept_Id
						END
					ELSE
						BEGIN
							SELECT    a.Emp_ID, a.Grd_ID, a.Branch_ID, a.Cat_ID, a.Desig_Id, a.Dept_ID, a.Type_ID, em.Emp_Full_Name, em.Emp_code, bm.Comp_Name, em.Alpha_Emp_Code,em.Emp_First_Name,
									  bm.Branch_Address, DM.Dept_Name, DGM.Desig_Name, ETM.Type_Name, GM.Grd_Name, bm.Branch_Name, em.Date_Of_Join, em.Gender, cm.Cmp_Name, 
									  cm.Cmp_Address, a.Curr_sal AS Net_Amount, @From_Date AS P_From_Date, @To_date AS P_To_Date, @Report_Type AS Report_Type, 
									  a.Prev_Sal AS Pre_Net_Amount, @Pre_From_Date AS Pre_From_Date, @Pre_To_Date AS Pre_To_Date
									  , CASE WHEN a.Prev_Sal > 0 THEN (((a.Curr_sal * 100) / a.Prev_Sal ) - 100 ) ELSE 100 END AS Diff_Per_Amount
									  , (a.Curr_sal - a.Prev_Sal) AS Diff_Amount
									  ,VT.Vertical_Name,SVT.SubVertical_Name
									  ,CASE WHEN em.Date_Of_Join BETWEEN @From_Date AND @To_Date THEN 'New Joining'
											WHEN em.Emp_Left_Date BETWEEN @From_Date AND @To_Date THEN 'Left'
											WHEN a.Curr_Inc_Date BETWEEN  @From_Date AND @To_Date THEN 'Increment'
											WHEN a.Settelement_Amount > 0 THEN 'Settlement'
											WHEN a.Arear_Gross > 0 THEN 'Arear Days'
											WHEN a.OT_Amount > 0 THEN 'Over Time'
											WHEN a.Late_Days > 0 THEN 'Late Penalty'
											WHEN a.Early_Days > 0 THEN 'Early Penalty'
											ELSE ' ' END AS Remarks
									 --Actual Structure	
									 ,a.Prev_GrossAmount , a.Curr_GrossAmount
									 ,a.Prev_Gross_Actual , a.Curr_Gross_Actual
									 ,CASE WHEN a.Prev_Gross_Actual > 0 THEN (((a.Prev_GrossAmount * 100) / a.Prev_Gross_Actual ) - 100 ) ELSE 100 END AS PreMonth_Gross_Diff_Per_Amount
									 ,CASE WHEN a.Curr_Gross_Actual > 0 THEN (((a.Curr_GrossAmount * 100) / a.Curr_Gross_Actual ) - 100 ) ELSE 100 END AS Curr_Gross_Diff_Per_Amount
									 ,CASE WHEN a.Prev_GrossAmount > 0 THEN (((a.Curr_GrossAmount * 100) / a.Prev_GrossAmount ) - 100 ) ELSE 100 END AS Diff_Gross_Amount
									 ,a.Pre_Absent_Days,a.Curr_Absent_Days
									 --, (((a.Curr_sal * 100) / a.Prev_Sal ) - 100 ) AS test
									 --,a.Pre_Emp_ID
									 --,a.Cur_Emp_ID
									 ,case when a.Prev_Sal = 0 then null when a.Prev_Sal > 0 then a.Pre_Emp_ID end Pre_Emp_ID
									,case when a.Curr_sal = 0 then null when a.Curr_sal > 0 then a.Cur_Emp_ID end Cur_Emp_ID
							FROM         (SELECT  ISNULL(t1_1.Emp_ID, ISNULL(t2.Emp_ID, t1_1.Emp_ID)) AS Emp_ID, ISNULL(t1_1.Net_Amount, 0) AS Prev_Sal, ISNULL(t2.Net_Amount, 0) AS Curr_sal, 
												  ISNULL(t1_1.Grd_ID, ISNULL(t2.Grd_ID, t1_1.Grd_ID)) AS Grd_ID, ISNULL(t1_1.Branch_ID, ISNULL(t2.Branch_ID, t1_1.Branch_ID)) AS Branch_ID, 
												  ISNULL(t1_1.Cat_ID, ISNULL(t2.Emp_ID, t1_1.Cat_ID)) AS Cat_ID, ISNULL(t1_1.Desig_Id, ISNULL(t2.Desig_Id, t1_1.Desig_Id)) AS Desig_Id, 
												  ISNULL(t1_1.Dept_ID, ISNULL(t2.Dept_ID, t1_1.Dept_ID)) AS Dept_ID, ISNULL(t1_1.Type_ID, ISNULL(t2.Type_ID, t1_1.Type_ID)) AS TYPE_ID
												  ,ISNULL(t1_1.Vertical_ID, ISNULL(t2.Vertical_ID, t1_1.Vertical_ID)) AS Vertical_id
												  ,ISNULL(t1_1.SubVertical_id, ISNULL(t2.SubVertical_id, t1_1.SubVertical_id)) AS SubVertical_id
												  
												  ---Actual Structure
												  ,ISNULL(t1_1.Gross_Salary,0) AS Prev_GrossAmount , ISNULL(t2.Gross_Salary,0) AS Curr_GrossAmount
												  ,ISNULL(t1_1.Actual_Gross,0) AS Prev_Gross_Actual , ISNULL(t2.Actual_Gross_curr,0) AS Curr_Gross_Actual
												  ,ISNULL(t1_1.Pre_Absent_Days,0) AS Pre_Absent_Days , ISNULL(t2.Curr_Absent_Days,0) AS Curr_Absent_Days
												  ,t2.Curr_Inc_Date,t1_1.Pre_Inc_Date
												  ,t2.Settelement_Amount,t2.Arear_Gross,t2.OT_Amount,t2.Late_Days,t2.Early_Days
												  ,t1_1.Emp_ID AS Pre_Emp_ID
												  ,t2.Emp_ID As Cur_Emp_ID
											   FROM          (SELECT     t1.Emp_ID, t1.Cmp_ID, t1.Net_Amount, inc.Grd_ID, inc.Branch_ID, inc.Cat_ID, inc.Desig_Id, inc.Dept_ID, inc.Type_ID,inc.Vertical_ID,inc.SubVertical_ID,t1.Gross_Salary,Inc.Gross_Salary AS Actual_Gross,t1.Absent_Days AS Pre_Absent_Days,Inc.Increment_Effective_Date AS Pre_Inc_Date
																	   FROM          T0200_MONTHLY_SALARY AS t1 WITH (NOLOCK) INNER JOIN
																								  (SELECT     I.Emp_ID, I.Grd_ID, I.Branch_ID, I.Cat_ID, I.Desig_Id, I.Dept_ID, I.Type_ID,I.Vertical_ID,I.SubVertical_ID,I.Gross_Salary,i.Increment_Effective_Date
																									FROM          T0095_INCREMENT AS I WITH (NOLOCK) INNER JOIN --(SELECT DISTINCT DATA FROM dbo.split(@constraint,'#')) AS DATA ON i.emp_id = data.data INNER JOIN
																															   (SELECT     MAX(Increment_ID) AS Increment_ID, Emp_ID	-- Ankit 10092014 for Same Date Increment
																																 FROM          (SELECT     Emp_ID, Increment_Effective_Date,Increment_ID	
																																				 FROM          T0095_INCREMENT AS T0095_INCREMENT_2 WITH (NOLOCK)
																																				 WHERE      (Increment_Effective_Date <= @Pre_To_Date AND Cmp_ID = @Cmp_ID) ) AS T0095_Increment
																																 GROUP BY Emp_ID) AS Qry ON I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID) AS inc ON 
																							  t1.Emp_ID = inc.Emp_ID
																	   WHERE      (t1.Month_St_Date = @Pre_From_Date) AND (t1.Is_FNF <> 1) AND (inc.Grd_ID = ISNULL(@Grd_ID, inc.Grd_ID)) AND 
																							  (inc.Branch_id = ISNULL(@Branch_ID, inc.Branch_id)) AND ( ISNULL(inc.Cat_ID,0) = ISNULL(@Cat_ID, ISNULL(inc.Cat_ID,0))) AND 
																							  (ISNULL(inc.Type_id,0) = ISNULL(@Type_ID, ISNULL(inc.Type_ID,0))) AND (ISNULL(inc.Dept_ID,0) = ISNULL(@Dept_ID, ISNULL(inc.Dept_ID,0))) AND 
																							  (inc.Desig_ID = ISNULL(@Desig_ID, inc.Desig_ID)) AND (ISNULL(inc.Emp_ID,0) = ISNULL(@Emp_ID, ISNULL(inc.Emp_ID,0)))) AS t1_1 FULL OUTER JOIN
																		  (SELECT     t.Emp_ID, t.Net_Amount, inc_1.Grd_ID, inc_1.Branch_ID, inc_1.Cat_ID, inc_1.Desig_Id, inc_1.Dept_ID, inc_1.Type_ID,inc_1.Vertical_ID,inc_1.SubVertical_ID,t.Gross_Salary,inc_1.Gross_Salary AS Actual_Gross_curr,
																						t.Absent_Days AS Curr_Absent_Days,inc_1.Increment_Effective_Date AS Curr_Inc_Date,t.Settelement_Amount,t.Arear_Gross ,t.Late_Days,t.Early_Days,(ISNULL(t.OT_Amount,0) + ISNULL(t.M_HO_OT_Amount,0) + ISNULL(t.M_WO_OT_Amount,0) ) AS OT_Amount
																			FROM          T0200_MONTHLY_SALARY AS t WITH (NOLOCK) INNER JOIN
																									   (SELECT     I.Emp_ID, I.Grd_ID, I.Branch_ID, I.Cat_ID, I.Desig_Id, I.Dept_ID, I.Type_ID,I.Vertical_ID,I.SubVertical_ID,I.Gross_Salary,I.Increment_Effective_Date
																										 FROM          T0095_INCREMENT AS I WITH (NOLOCK) INNER JOIN (SELECT DISTINCT DATA FROM dbo.split(@constraint,'#')) AS DATA ON i.emp_id = data.data INNER JOIN
																																	(SELECT     MAX(Increment_ID) AS Increment_ID, Emp_ID	-- Ankit 10092014 for Same Date Increment
																																	  FROM          (SELECT     Emp_ID, Increment_Effective_Date,Increment_ID
																																							  FROM          T0095_INCREMENT AS T0095_INCREMENT_1 WITH (NOLOCK)
																																							  WHERE      (Increment_Effective_Date <= @To_Date AND Cmp_ID = @Cmp_ID)) AS T0095_Increment_3
																																	  GROUP BY Emp_ID) AS Qry_1 ON I.Emp_ID = Qry_1.Emp_ID AND I.Increment_ID = Qry_1.Increment_ID) AS inc_1 ON 
																								   t.Emp_ID = inc_1.Emp_ID
																			WHERE      (t.Month_St_Date = @From_Date) AND (t.Is_FNF <> 1) AND (inc_1.Grd_ID = ISNULL(@Grd_ID, inc_1.Grd_ID)) AND 
																								   (inc_1.Branch_ID = ISNULL(@Branch_ID, inc_1.Branch_ID)) AND (ISNULL(inc_1.Cat_ID,0) = ISNULL(@Cat_ID, ISNULL(inc_1.Cat_ID,0))) AND 
																								   (ISNULL(inc_1.Type_ID,0) = ISNULL(@Type_ID, ISNULL(inc_1.Type_ID,0))) AND ( ISNULL(inc_1.Dept_ID,0) = ISNULL(@Dept_ID, ISNULL(inc_1.Dept_ID,0))) AND 
																								   (inc_1.Desig_Id = ISNULL(@Desig_ID, inc_1.Desig_Id)) AND (ISNULL(inc_1.Emp_ID,0) = ISNULL(@Emp_ID, ISNULL(inc_1.Emp_ID,0)))) AS t2 ON 
																	  t1_1.Emp_ID = t2.Emp_ID) AS a INNER JOIN
											  T0080_EMP_MASTER AS em WITH (NOLOCK) ON em.Emp_ID = a.Emp_ID INNER JOIN
											  T0010_COMPANY_MASTER AS cm WITH (NOLOCK) ON @Cmp_ID = cm.Cmp_Id INNER JOIN
											  T0030_BRANCH_MASTER AS bm WITH (NOLOCK) ON bm.Branch_ID = a.Branch_ID INNER JOIN
											  T0040_GRADE_MASTER AS GM WITH (NOLOCK) ON a.Grd_ID = GM.Grd_ID LEFT OUTER JOIN	--INNER JOIN
											  T0040_TYPE_MASTER AS ETM WITH (NOLOCK) ON a.Type_ID = ETM.Type_ID INNER JOIN
											  T0040_DESIGNATION_MASTER AS DGM WITH (NOLOCK) ON a.Desig_Id = DGM.Desig_ID LEFT OUTER JOIN	--INNER JOIN
											  T0040_DEPARTMENT_MASTER AS DM WITH (NOLOCK) ON a.Dept_ID = DM.Dept_Id
											  LEFT OUTER JOIN T0040_Vertical_Segment AS VT  WITH (NOLOCK) ON VT.Vertical_id = a.Vertical_id
											  LEFT OUTER JOIN T0050_SubVertical AS SVT  WITH (NOLOCK) ON SVT.SubVertical_id = a.SubVertical_id
											  
						
							WHERE 
								CASE WHEN a.Prev_Sal > 0 THEN ROUND((((a.Curr_sal * 100) / a.Prev_Sal ) - 100 ),0) ELSE 100 END BETWEEN @Variance_Filter_From AND @Variance_Filter_To
							ORDER BY 
								CASE WHEN ISNUMERIC(em.Alpha_Emp_Code) = 0 THEN LEFT(em.Alpha_Emp_Code + REPLICATE('',21), 20)
								ELSE em.Alpha_Emp_Code
							END
						END
			   END
		 
	END
ELSE
	BEGIN
		IF @DRILDOWN_FLAG = 0 -- For Monthly Salary Summary of Variation
			BEGIN
				IF OBJECT_ID('TEMPDB..#EMP_CONS') IS NOT NULL
					BEGIN
						DROP TABLE #EMP_CONS
					END
					
				CREATE TABLE #EMP_CONS
				(
					EMP_ID NUMERIC(18,0)
				)
			
				IF @CONSTRAINT <> ''
					BEGIN
						INSERT INTO #EMP_CONS	
						SELECT CAST(DATA AS NUMERIC(18,0)) 
						FROM DBO.SPLIT(@CONSTRAINT,'#') 
						WHERE DATA <> ''
					END
				
				IF OBJECT_ID('TEMPDB..#EMP_SALARY') IS NOT NULL
					BEGIN
						DROP TABLE #EMP_SALARY
					END
					
				CREATE TABLE #EMP_SALARY
				(
					EMP_ID NUMERIC(18,0),
					CMP_ID NUMERIC(18,0),
					SAL_ST_DATE DATETIME,
					SAL_END_DATE DATETIME,
					PREV_MONTH_GROSS NUMERIC(18,2),
					CURR_MONTH_GROSS NUMERIC(18,2),
					GROSS_VARIATION NUMERIC(18,2),
					PREV_MONTH_NET NUMERIC(18,2),
					CURR_MONTH_NET NUMERIC(18,2),
					NET_VARIATION NUMERIC(18,2),
					--EARNING_REASON VARCHAR(1000),
					--DEDUCTION_REASON VARCHAR(1000)
				 )
				 
				 INSERT INTO #EMP_SALARY
				 SELECT EC.EMP_ID,CMP_ID,Month_St_Date,Month_End_Date,0,0,0,0,0,0
				 FROM T0200_MONTHLY_SALARY MS WITH (NOLOCK)
				 INNER JOIN #EMP_CONS EC ON MS.EMP_ID = EC.EMP_ID
				 WHERE Month_End_Date BETWEEN @FROM_DATE AND @TO_DATE AND ISNULL(IS_FNF,0) = 0  
				 
				 UPDATE ES
					SET ES.CURR_MONTH_GROSS = MS.Gross_Salary,
						ES.CURR_MONTH_NET = MS.Net_Amount
				 FROM #EMP_SALARY ES INNER JOIN T0200_MONTHLY_SALARY MS
				 ON MONTH(MS.Month_End_Date) = MONTH(ES.SAL_END_DATE) AND YEAR(MS.Month_End_Date) = YEAR(ES.SAL_END_DATE) AND ES.EMP_ID = MS.EMP_ID
				 
				 UPDATE ES
					SET ES.PREV_MONTH_GROSS = MS.Gross_Salary,
						ES.PREV_MONTH_NET = MS.Net_Amount
				 FROM #EMP_SALARY ES INNER JOIN T0200_MONTHLY_SALARY MS
				 ON MONTH(MS.Month_End_Date) = MONTH(Dateadd(MM,-1,ES.SAL_END_DATE)) AND YEAR(MS.Month_End_Date) = YEAR(Dateadd(MM,-1,ES.SAL_END_DATE)) AND ES.EMP_ID = MS.EMP_ID
				 
				 Update ES
					SET GROSS_VARIATION = ((CASE WHEN ES.PREV_MONTH_GROSS > 0 THEN ES.CURR_MONTH_GROSS * 100/ES.PREV_MONTH_GROSS ELSE 0 END) - 100),
						NET_VARIATION = ((CASE WHEN ES.PREV_MONTH_NET > 0 THEN ES.CURR_MONTH_NET * 100/ES.PREV_MONTH_NET ELSE 0 END) - 100)
				 FROM #EMP_SALARY ES
				 
				 SELECT EM.ALPHA_EMP_CODE,EM.EMP_FULL_NAME,ES.PREV_MONTH_GROSS,ES.CURR_MONTH_GROSS,ES.GROSS_VARIATION,
						ES.PREV_MONTH_NET,ES.CURR_MONTH_NET,ES.NET_VARIATION,
						EM.Emp_ID
				 FROM #EMP_SALARY ES INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK)
				 ON EM.EMP_ID = ES.EMP_ID
		 
		 END
		Else IF @DRILDOWN_FLAG = 1 -- For Monthly Salary Varition in Details(Head wise) 
			BEGIN
				IF OBJECT_ID('TEMPDB..#EMP_VARIATION_REASON') IS NOT NULL
					BEGIN
						DROP TABLE #EMP_VARIATION_REASON
					END
					
					CREATE TABLE #EMP_VARIATION_REASON
					(
						SR_NO NUMERIC(18,0),
						CMP_ID NUMERIC(18,0),
						EMP_ID NUMERIC(18,0),
						AD_ID NUMERIC(18,0),
						AD_DESCRIPTION VARCHAR(1000),
						AD_FLAG VARCHAR(2),
						PREV_END_DATE DATETIME,
						PREV_AMOUNT VARCHAR(20),
						CURR_END_DATE DATETIME,
						CURR_AMOUNT VARCHAR(20),
						DIFF_AMOUNT VARCHAR(20)
					)
					
					DECLARE @SORT_INDEX NUMERIC
					SET @SORT_INDEX = 1
					
					DECLARE @MONTH_END_DATE DATETIME
					SET @MONTH_END_DATE = @TO_DATE
					
					DECLARE @MONTH_START_DATE DATETIME
					SET @MONTH_START_DATE = DATEADD(MM,-1,@MONTH_END_DATE)
					
					INSERT INTO #EMP_VARIATION_REASON
					SELECT (SELECT Isnull(MAX(SR_NO),0) FROM #EMP_VARIATION_REASON) + 1,@CMP_ID,@EMP_ID,1,'INCREMENT IN SALARY',0,@MONTH_START_DATE,0,@MONTH_END_DATE,0,0
					
					INSERT INTO #EMP_VARIATION_REASON
					SELECT (SELECT Isnull(MAX(SR_NO),0) FROM #EMP_VARIATION_REASON) + 1,@CMP_ID,@EMP_ID,2,'PRESENT DAYS',0,@MONTH_START_DATE,0,@MONTH_END_DATE,0,0
					
					INSERT INTO #EMP_VARIATION_REASON
					SELECT (SELECT MAX(SR_NO) FROM #EMP_VARIATION_REASON) + 1,@CMP_ID,@EMP_ID,3,'ABSENT DAYS',0,@MONTH_START_DATE,0,@MONTH_END_DATE,0,0
					
					INSERT INTO #EMP_VARIATION_REASON
					SELECT (SELECT MAX(SR_NO) FROM #EMP_VARIATION_REASON) + 1,@CMP_ID,@EMP_ID,4,'SALARY SETTELMENT',0,@MONTH_START_DATE,0,@MONTH_END_DATE,0,0
					
					INSERT INTO #EMP_VARIATION_REASON
					SELECT (SELECT MAX(SR_NO) FROM #EMP_VARIATION_REASON) + 1,@CMP_ID,@EMP_ID,5,'LATE DAYS',0,@MONTH_START_DATE,0,@MONTH_END_DATE,0,0
					
					INSERT INTO #EMP_VARIATION_REASON
					SELECT (SELECT MAX(SR_NO) FROM #EMP_VARIATION_REASON) + 1,@CMP_ID,@EMP_ID,6,'EARLY DAYS',0,@MONTH_START_DATE,0,@MONTH_END_DATE,0,0
					
					INSERT INTO #EMP_VARIATION_REASON
					SELECT (SELECT MAX(SR_NO) FROM #EMP_VARIATION_REASON) + 1,@CMP_ID,@EMP_ID,7,'UNPAID LEAVE',0,@MONTH_START_DATE,0,@MONTH_END_DATE,0,0
					
					INSERT INTO #EMP_VARIATION_REASON
					SELECT (SELECT MAX(SR_NO) FROM #EMP_VARIATION_REASON) + 1,@CMP_ID,@EMP_ID,8,'ARREAR DAY',0,@MONTH_START_DATE,0,@MONTH_END_DATE,0,0
					
					INSERT INTO #EMP_VARIATION_REASON
					SELECT (SELECT MAX(SR_NO) FROM #EMP_VARIATION_REASON) + 1,@CMP_ID,@EMP_ID,9,'BASIC SALARY',0,@MONTH_START_DATE,0,@MONTH_END_DATE,0,0
					
					
					
					INSERT INTO #EMP_VARIATION_REASON
					SELECT DISTINCT * FROM (
									SELECT ROW_NUMBER() OVER(ORDER BY AD.AD_ID) + (SELECT MAX(SR_NO) FROM #EMP_VARIATION_REASON) AS SR_NO,
										   @CMP_ID AS CMP_ID,@EMP_ID AS EMP_ID,AD.AD_ID AS AD_ID,UPPER(AD.AD_NAME) AS AD_NAME,
										   (CASE WHEN AD.AD_FLAG = 'I' THEN 1 ELSE 2 END) AS AD_FLAG,
										   @MONTH_START_DATE AS STAR_DATE,0 AS PREV_AMOUNT,@MONTH_END_DATE AS END_DATE,0 AS CURR_AMOUNT,0 AS DIFF_AMOUNT
									FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
										INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON MAD.AD_ID = AD.AD_ID
									WHERE EMP_ID = @EMP_ID  
										--AND TO_DATE BETWEEN @MONTH_START_DATE AND @MONTH_END_DATE 
										AND TO_DATE BETWEEN @FROM_DATE AND @TO_DATE 
										AND M_AD_NOT_EFFECT_SALARY = 0 AND MAD.S_Sal_Tran_ID IS NULL
									
									UNION ALL
									
									SELECT ROW_NUMBER() OVER(ORDER BY AD.AD_ID) + (SELECT MAX(SR_NO) FROM #EMP_VARIATION_REASON) AS SR_NO,
										   @CMP_ID AS CMP_ID,@EMP_ID AS EMP_ID,AD.AD_ID AS AD_ID,UPPER(AD.AD_NAME) AS AD_NAME,
										   (CASE WHEN AD.AD_FLAG = 'I' THEN 1 ELSE 2 END) AS AD_FLAG,
										   @MONTH_START_DATE AS STAR_DATE,0 AS PREV_AMOUNT,@MONTH_END_DATE AS END_DATE,0 AS CURR_AMOUNT,0 AS DIFF_AMOUNT
									FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
										 INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON MAD.AD_ID = AD.AD_ID
									WHERE EMP_ID = @EMP_ID 
										 --AND TO_DATE BETWEEN DATEADD(MM,-1,@MONTH_START_DATE) AND DATEADD(MM,-1,@MONTH_END_DATE) 
										 AND TO_DATE BETWEEN DATEADD(MM,-1,@FROM_DATE) AND DATEADD(MM,-1,@TO_DATE) 
										 AND M_AD_NOT_EFFECT_SALARY = 0  AND MAD.S_Sal_Tran_ID IS NULL
							) T
							
					
					
					INSERT INTO #EMP_VARIATION_REASON
					SELECT (SELECT MAX(SR_NO) FROM #EMP_VARIATION_REASON) + 1 ,@CMP_ID,@EMP_ID,10,'PT AMOUNT',0,@MONTH_START_DATE,0,@MONTH_END_DATE,0,0
							
					INSERT INTO #EMP_VARIATION_REASON
					SELECT (SELECT MAX(SR_NO) FROM #EMP_VARIATION_REASON) + 1 ,@CMP_ID,@EMP_ID,11,'LOAN AMOUNT',3,@MONTH_START_DATE,0,@MONTH_END_DATE,0,0
					
					INSERT INTO #EMP_VARIATION_REASON
					SELECT (SELECT MAX(SR_NO) FROM #EMP_VARIATION_REASON) + 1 ,@CMP_ID,@EMP_ID,12,'LOAN INTEREST AMOUNT',3,@MONTH_START_DATE,0,@MONTH_END_DATE,0,0
					
					
					UPDATE EV
						SET
						  EV.PREV_AMOUNT = CASE WHEN EV.AD_DESCRIPTION = 'PRESENT DAYS' THEN ISNULL(P_MS.PRESENT_DAYS,0)
												WHEN EV.AD_DESCRIPTION = 'ABSENT DAYS' THEN ISNULL(P_MS.ABSENT_DAYS,0)
												WHEN EV.AD_DESCRIPTION = 'SALARY SETTELMENT' THEN ISNULL(P_MS.SETTELEMENT_AMOUNT,0)
												WHEN EV.AD_DESCRIPTION = 'LATE DAYS' THEN ISNULL(P_MS.LATE_DAYS,0)
												WHEN EV.AD_DESCRIPTION = 'EARLY DAYS' THEN ISNULL(P_MS.EARLY_DAYS,0)
												WHEN EV.AD_DESCRIPTION = 'UNPAID LEAVE' THEN (ISNULL(P_MS.TOTAL_LEAVE_DAYS,0) - ISNULL(P_MS.PAID_LEAVE_DAYS,0))
												WHEN EV.AD_DESCRIPTION = 'PT AMOUNT' THEN ISNULL(P_MS.PT_AMOUNT,0)
												WHEN EV.AD_DESCRIPTION = 'BASIC SALARY' THEN ISNULL(P_MS.SALARY_AMOUNT,0)
												WHEN EV.AD_DESCRIPTION = 'ARREAR DAY' THEN ISNULL(P_MS.AREAR_DAY,0)
												WHEN EV.AD_DESCRIPTION = 'INCREMENT IN SALARY' 
																		  THEN (CASE WHEN I.Increment_Effective_Date BETWEEN DATEADD(MM,-1,EV.PREV_END_DATE) AND EV.PREV_END_DATE THEN 1 ELSE 0 END)
												ELSE 0
											END,
						 EV.CURR_AMOUNT = CASE WHEN EV.AD_DESCRIPTION = 'PRESENT DAYS' THEN ISNULL(MS.PRESENT_DAYS,0)
												WHEN EV.AD_DESCRIPTION = 'ABSENT DAYS' THEN ISNULL(MS.ABSENT_DAYS,0)
												WHEN EV.AD_DESCRIPTION = 'SALARY_SETTELMENT' THEN ISNULL(MS.SETTELEMENT_AMOUNT,0)
												WHEN EV.AD_DESCRIPTION = 'LATE_DAYS' THEN ISNULL(MS.LATE_DAYS,0)
												WHEN EV.AD_DESCRIPTION = 'EARLY_DAYS' THEN ISNULL(MS.EARLY_DAYS,0)
												WHEN EV.AD_DESCRIPTION = 'UNPAID LEAVE' THEN (ISNULL(MS.TOTAL_LEAVE_DAYS,0) - ISNULL(MS.PAID_LEAVE_DAYS,0))
												WHEN EV.AD_DESCRIPTION = 'PT AMOUNT' THEN ISNULL(P_MS.PT_AMOUNT,0)
												WHEN EV.AD_DESCRIPTION = 'BASIC SALARY' THEN ISNULL(MS.SALARY_AMOUNT,0)
												WHEN EV.AD_DESCRIPTION = 'ARREAR DAY' THEN ISNULL(MS.AREAR_DAY,0)
												WHEN EV.AD_DESCRIPTION = 'INCREMENT IN SALARY' 
																		  THEN (CASE WHEN I.Increment_Effective_Date BETWEEN DATEADD(MM,-1,EV.CURR_END_DATE) AND EV.CURR_END_DATE THEN 1 ELSE 0 END)
												ELSE 0
											END
					FROM #EMP_VARIATION_REASON EV
					INNER JOIN T0095_INCREMENT I 
								INNER JOIN(
											SELECT MAX(IQ.INCREMENT_ID) AS INCREMENTID,IQ.EMP_ID FROM T0095_INCREMENT IQ WITH (NOLOCK)
													INNER JOIN(
																SELECT EMP_ID,MAX(INCREMENT_EFFECTIVE_DATE) AS EFFECTIVE_DATE
																FROM T0095_INCREMENT WITH (NOLOCK) 
																WHERE CMP_ID = @CMP_ID AND INCREMENT_EFFECTIVE_DATE <= @TO_DATE
																GROUP BY EMP_ID							             
															  ) AS QRY ON IQ.EMP_ID = QRY.EMP_ID AND IQ.INCREMENT_EFFECTIVE_DATE = QRY.EFFECTIVE_DATE
											GROUP BY IQ.EMP_ID
										  ) AS QRY_1 ON I.INCREMENT_ID = QRY_1.INCREMENTID AND QRY_1.EMP_ID = I.EMP_ID
					 ON I.EMP_ID = EV.EMP_ID
					 LEFT OUTER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK)
					 ON MONTH(MS.MONTH_END_DATE) = MONTH(EV.CURR_END_DATE) AND YEAR(MS.MONTH_END_DATE) = YEAR(EV.CURR_END_DATE) AND EV.EMP_ID = MS.EMP_ID
					 LEFT OUTER JOIN T0200_MONTHLY_SALARY P_MS WITH (NOLOCK)
					 ON MONTH(P_MS.MONTH_END_DATE) = MONTH(EV.PREV_END_DATE) AND YEAR(P_MS.MONTH_END_DATE) = YEAR(EV.PREV_END_DATE) AND EV.EMP_ID = P_MS.EMP_ID 
					 WHERE AD_FLAG = 0
					 
					 
					 
					UPDATE #EMP_VARIATION_REASON 
							SET PREV_AMOUNT = (CASE WHEN CAST(PREV_AMOUNT AS NUMERIC) = 1 THEN 'YES' ELSE 'NO' END),
								CURR_AMOUNT = (CASE WHEN CAST(CURR_AMOUNT AS NUMERIC) = 1 THEN 'YES' ELSE 'NO' END)
					 WHERE AD_DESCRIPTION = 'INCREMENT IN SALARY'
					 
					 
					UPDATE EV
						SET
						  EV.PREV_AMOUNT = CASE WHEN EV.AD_DESCRIPTION = 'LOAN AMOUNT' THEN ISNULL(P_MLP.LOAN_PAY_AMOUNT,0)
												WHEN EV.AD_DESCRIPTION = 'LOAN INTEREST AMOUNT' THEN ISNULL(P_MLP.INTEREST_AMOUNT,0)
												ELSE 0
											END,
						  EV.CURR_AMOUNT = CASE WHEN EV.AD_DESCRIPTION = 'LOAN AMOUNT' THEN ISNULL(MLP.LOAN_PAY_AMOUNT,0)
												WHEN EV.AD_DESCRIPTION = 'LOAN INTEREST AMOUNT' THEN ISNULL(MLP.INTEREST_AMOUNT,0)
												ELSE 0
											END
					FROM #EMP_VARIATION_REASON EV 
					INNER JOIN T0120_LOAN_APPROVAL LA ON EV.EMP_ID = LA.EMP_ID 
					INNER JOIN T0210_MONTHLY_LOAN_PAYMENT MLP ON MLP.LOAN_APR_ID = LA.LOAN_APR_ID AND MLP.SAL_TRAN_ID IS NOT NULL AND MONTH(MLP.LOAN_PAYMENT_DATE) = MONTH(EV.CURR_END_DATE) AND YEAR(MLP.LOAN_PAYMENT_DATE) = YEAR(EV.CURR_END_DATE)
					LEFT OUTER JOIN T0210_MONTHLY_LOAN_PAYMENT P_MLP ON P_MLP.LOAN_APR_ID = LA.LOAN_APR_ID AND P_MLP.SAL_TRAN_ID IS NOT NULL AND MONTH(P_MLP.LOAN_PAYMENT_DATE) = MONTH(EV.CURR_END_DATE) AND YEAR(P_MLP.LOAN_PAYMENT_DATE) = YEAR(EV.CURR_END_DATE)
					WHERE EV.AD_FLAG = 3
					
					UPDATE EV
						SET EV.CURR_AMOUNT = (CASE WHEN AD.ALLOWANCE_TYPE = 'R' THEN MAD.REIMAMOUNT ELSE ISNULL(MAD.M_AD_AMOUNT,0) END)
					FROM #EMP_VARIATION_REASON EV
						 INNER JOIN T0210_MONTHLY_AD_DETAIL MAD ON EV.EMP_ID = MAD.EMP_ID AND EV.AD_ID = MAD.AD_ID
						 INNER JOIN T0050_AD_MASTER AD ON MAD.AD_ID = AD.AD_ID
					WHERE	--TO_DATE BETWEEN DATEADD(MM,-1,EV.CURR_END_DATE) AND EV.CURR_END_DATE 
							TO_DATE BETWEEN dbo.GET_MONTH_ST_DATE(MONTH(EV.CURR_END_DATE ),YEAR(EV.CURR_END_DATE )) AND
							dbo.GET_MONTH_END_DATE(MONTH(EV.CURR_END_DATE),YEAR(EV.CURR_END_DATE))
						  AND M_AD_NOT_EFFECT_SALARY = 0 and EV.AD_FLAG <> 0
						  
					UPDATE EV
						SET EV.PREV_AMOUNT = (CASE WHEN AD.ALLOWANCE_TYPE = 'R' THEN MAD.REIMAMOUNT ELSE ISNULL(MAD.M_AD_AMOUNT,0) END)
					FROM #EMP_VARIATION_REASON EV
						 INNER JOIN T0210_MONTHLY_AD_DETAIL MAD ON EV.EMP_ID = MAD.EMP_ID AND EV.AD_ID = MAD.AD_ID
						 INNER JOIN T0050_AD_MASTER AD ON MAD.AD_ID = AD.AD_ID
					WHERE	--TO_DATE BETWEEN DATEADD(MM,-1,EV.PREV_END_DATE) AND EV.PREV_END_DATE 
							TO_DATE BETWEEN dbo.GET_MONTH_ST_DATE(MONTH(EV.PREV_END_DATE),YEAR(EV.PREV_END_DATE)) AND 
							dbo.GET_MONTH_END_DATE(MONTH(EV.PREV_END_DATE),YEAR(EV.PREV_END_DATE))
						  AND M_AD_NOT_EFFECT_SALARY = 0 and EV.AD_FLAG <> 0
					 
					SELECT ROW_NUMBER() OVER(ORDER BY AD_FLAG,AD_ID) AS Sr_NO, AD_DESCRIPTION,
					PREV_AMOUNT,CURR_AMOUNT,
					(CASE WHEN ISNUMERIC(CURR_AMOUNT) = 1
							THEN CAST((CAST(CURR_AMOUNT AS numeric(18,2)) - CAST(PREV_AMOUNT AS numeric(18,2))) AS varchar(20))
						  ELSE '-' END) AS DIFF_AMOUNT
					FROM #EMP_VARIATION_REASON
					WHERE (1 = CASE WHEN ISNUMERIC(CURR_AMOUNT) = 1 THEN 
								   (CASE WHEN (CAST(CURR_AMOUNT AS numeric(18,2)) <> CAST(PREV_AMOUNT AS numeric(18,2))) THEN 1 ELSE 0 END)
							  ELSE 0 END OR AD_DESCRIPTION = 'INCREMENT IN SALARY')
				
			END
		Else IF @DRILDOWN_FLAG = 2 -- Report of Mothnly Salary Variation report Customize
			BEGIN
				IF OBJECT_ID('TEMPDB..#EMP_CONS_REPORT') IS NOT NULL
					BEGIN
						DROP TABLE #EMP_CONS_REPORT
					END
					
				CREATE TABLE #EMP_CONS_REPORT
				(
					EMP_ID NUMERIC(18,0),
					BRANCH_ID NUMERIC(18,0),
					INCREMENT_ID NUMERIC(18,0)
				)
			
				IF @CONSTRAINT <> ''
					BEGIN
						INSERT INTO #EMP_CONS_REPORT	
						SELECT CAST(DATA AS NUMERIC(18,0)),0,0
						FROM DBO.SPLIT(@CONSTRAINT,'#') 
						WHERE DATA <> ''
					END
					
				UPDATE  E 
				SET		BRANCH_ID = I.BRANCH_ID, INCREMENT_ID=I.INCREMENT_ID
				FROM	#EMP_CONS_REPORT E						
						INNER JOIN (SELECT	I1.EMP_ID, I1.INCREMENT_ID, I1.BRANCH_ID
									FROM	T0095_INCREMENT I1 WITH (NOLOCK) INNER JOIN #EMP_CONS_REPORT E1 ON I1.EMP_ID=E1.EMP_ID
											INNER JOIN (SELECT	MAX(I2.INCREMENT_ID) AS INCREMENT_ID, I2.EMP_ID
														FROM	T0095_INCREMENT I2 WITH (NOLOCK) INNER JOIN #EMP_CONS_REPORT E2 ON I2.EMP_ID=E2.EMP_ID
																INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
																			FROM	T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN #EMP_CONS_REPORT E3 ON I3.EMP_ID=E3.EMP_ID
																			WHERE	I3.INCREMENT_EFFECTIVE_DATE <= @TO_DATE
																			GROUP BY I3.EMP_ID
																			) I3 ON I2.INCREMENT_EFFECTIVE_DATE=I3.INCREMENT_EFFECTIVE_DATE AND I2.EMP_ID=I3.EMP_ID																		
														WHERE	I2.CMP_ID = @CMP_ID 
														GROUP BY I2.EMP_ID
														) I2 ON I1.EMP_ID=I2.EMP_ID AND I1.INCREMENT_ID=I2.INCREMENT_ID	
									WHERE	I1.CMP_ID=@CMP_ID											
								) I ON E.EMP_ID=I.EMP_ID
				
				IF OBJECT_ID('TEMPDB..#EMP_SALARY') IS NOT NULL
					BEGIN
						DROP TABLE #EMP_SALARY
					END
					
				CREATE TABLE #EMP_SALARY_REPORT
				(
					EMP_ID NUMERIC(18,0),
					CMP_ID NUMERIC(18,0),
					SAL_ST_DATE DATETIME,
					SAL_END_DATE DATETIME,
					PREV_MONTH_GROSS NUMERIC(18,2),
					CURR_MONTH_GROSS NUMERIC(18,2),
					GROSS_VARIATION NUMERIC(18,2),
					PREV_MONTH_NET NUMERIC(18,2),
					CURR_MONTH_NET NUMERIC(18,2),
					NET_VARIATION NUMERIC(18,2),
					BRANCH_ID NUMERIC,
					INCREMENT_ID NUMERIC,
				 )
				 
				 INSERT INTO #EMP_SALARY_REPORT
				 SELECT EC.EMP_ID,CMP_ID,Month_St_Date,Month_End_Date,0,0,0,0,0,0,EC.BRANCH_ID,EC.INCREMENT_ID
				 FROM T0200_MONTHLY_SALARY MS WITH (NOLOCK)
				 INNER JOIN #EMP_CONS_REPORT EC ON MS.EMP_ID = EC.EMP_ID
				 WHERE Month_End_Date BETWEEN @FROM_DATE AND @TO_DATE AND ISNULL(IS_FNF,0) = 0  
				 
				 UPDATE ES
					SET ES.CURR_MONTH_GROSS = MS.Gross_Salary,
						ES.CURR_MONTH_NET = MS.Net_Amount
				 FROM #EMP_SALARY_REPORT ES INNER JOIN T0200_MONTHLY_SALARY MS
				 ON MONTH(MS.Month_End_Date) = MONTH(ES.SAL_END_DATE) AND YEAR(MS.Month_End_Date) = YEAR(ES.SAL_END_DATE) AND ES.EMP_ID = MS.EMP_ID
				 
				 UPDATE ES
					SET ES.PREV_MONTH_GROSS = MS.Gross_Salary,
						ES.PREV_MONTH_NET = MS.Net_Amount
				 FROM #EMP_SALARY_REPORT ES INNER JOIN T0200_MONTHLY_SALARY MS
				 ON MONTH(MS.Month_End_Date) = MONTH(Dateadd(MM,-1,ES.SAL_END_DATE)) AND YEAR(MS.Month_End_Date) = YEAR(Dateadd(MM,-1,ES.SAL_END_DATE)) AND ES.EMP_ID = MS.EMP_ID
				 
				 Update ES
					SET GROSS_VARIATION = ((CASE WHEN ES.PREV_MONTH_GROSS > 0 THEN ES.CURR_MONTH_GROSS * 100/ES.PREV_MONTH_GROSS ELSE 0 END) - 100),
						NET_VARIATION = ((CASE WHEN ES.PREV_MONTH_NET > 0 THEN ES.CURR_MONTH_NET * 100/ES.PREV_MONTH_NET ELSE 0 END) - 100)
				 FROM #EMP_SALARY_REPORT ES
				 
				 
				 IF OBJECT_ID('TEMPDB..#EMP_VARIATION_REPORT') IS NOT NULL
					BEGIN
						DROP TABLE #EMP_VARIATION_REPORT
					END
					
					CREATE TABLE #EMP_VARIATION_REPORT
					(
						SR_NO NUMERIC(18,0),
						CMP_ID NUMERIC(18,0),
						EMP_ID NUMERIC(18,0),
						AD_ID NUMERIC(18,0),
						AD_DESCRIPTION VARCHAR(1000),
						AD_FLAG VARCHAR(2),
						PREV_END_DATE DATETIME,
						PREV_AMOUNT VARCHAR(20),
						CURR_END_DATE DATETIME,
						CURR_AMOUNT VARCHAR(20),
						DIFF_AMOUNT VARCHAR(20)
					)
				 
				 DECLARE @SORT_INDEX_REPORT NUMERIC
				 SET @SORT_INDEX_REPORT = 1
					
				 DECLARE @MONTH_END_DATE_REPORT DATETIME
				 SET @MONTH_END_DATE_REPORT = @TO_DATE
					
				 DECLARE @MONTH_START_DATE_REPORT DATETIME
				 SET @MONTH_START_DATE_REPORT = DATEADD(MM,-1,@MONTH_END_DATE_REPORT)
				 
				 DECLARE CUR_EMP CURSOR 
				 FOR SELECT CMP_ID,EMP_ID FROM #EMP_SALARY_REPORT
				 OPEN CUR_EMP
				 FETCH NEXT FROM CUR_EMP INTO @CMP_ID,@EMP_ID
					WHILE @@FETCH_STATUS = 0
						BEGIN
							
							 INSERT INTO #EMP_VARIATION_REPORT
							 SELECT (SELECT Isnull(MAX(SR_NO),0) FROM #EMP_VARIATION_REPORT) + 1,@CMP_ID,@EMP_ID,1,'INCREMENT IN SALARY',0,@MONTH_START_DATE_REPORT,0,@MONTH_END_DATE_REPORT,0,0
								
							 INSERT INTO #EMP_VARIATION_REPORT
							 SELECT (SELECT Isnull(MAX(SR_NO),0) FROM #EMP_VARIATION_REPORT) + 1,@CMP_ID,@EMP_ID,2,'PRESENT DAYS',0,@MONTH_START_DATE_REPORT,0,@MONTH_END_DATE_REPORT,0,0
								
							 INSERT INTO #EMP_VARIATION_REPORT
							 SELECT (SELECT MAX(SR_NO) FROM #EMP_VARIATION_REPORT) + 1,@CMP_ID,@EMP_ID,3,'ABSENT DAYS',0,@MONTH_START_DATE_REPORT,0,@MONTH_END_DATE_REPORT,0,0
								
							 INSERT INTO #EMP_VARIATION_REPORT
							 SELECT (SELECT MAX(SR_NO) FROM #EMP_VARIATION_REPORT) + 1,@CMP_ID,@EMP_ID,4,'SALARY SETTELMENT',0,@MONTH_START_DATE_REPORT,0,@MONTH_END_DATE_REPORT,0,0
								
							 INSERT INTO #EMP_VARIATION_REPORT
							 SELECT (SELECT MAX(SR_NO) FROM #EMP_VARIATION_REPORT) + 1,@CMP_ID,@EMP_ID,5,'LATE DAYS',0,@MONTH_START_DATE_REPORT,0,@MONTH_END_DATE_REPORT,0,0
								
							 INSERT INTO #EMP_VARIATION_REPORT
							 SELECT (SELECT MAX(SR_NO) FROM #EMP_VARIATION_REPORT) + 1,@CMP_ID,@EMP_ID,6,'EARLY DAYS',0,@MONTH_START_DATE_REPORT,0,@MONTH_END_DATE_REPORT,0,0
								
							 INSERT INTO #EMP_VARIATION_REPORT
							 SELECT (SELECT MAX(SR_NO) FROM #EMP_VARIATION_REPORT) + 1,@CMP_ID,@EMP_ID,7,'UNPAID LEAVE',0,@MONTH_START_DATE_REPORT,0,@MONTH_END_DATE_REPORT,0,0
								
							 INSERT INTO #EMP_VARIATION_REPORT
							 SELECT (SELECT MAX(SR_NO) FROM #EMP_VARIATION_REPORT) + 1,@CMP_ID,@EMP_ID,8,'ARREAR DAY',0,@MONTH_START_DATE_REPORT,0,@MONTH_END_DATE_REPORT,0,0
								
							 INSERT INTO #EMP_VARIATION_REPORT
							 SELECT (SELECT MAX(SR_NO) FROM #EMP_VARIATION_REPORT) + 1,@CMP_ID,@EMP_ID,9,'BASIC SALARY',0,@MONTH_START_DATE_REPORT,0,@MONTH_END_DATE_REPORT,0,0
							
							 INSERT INTO #EMP_VARIATION_REPORT
								SELECT DISTINCT * FROM (
												SELECT ROW_NUMBER() OVER(ORDER BY AD.AD_ID) + (SELECT MAX(SR_NO) FROM #EMP_VARIATION_REPORT) AS SR_NO,
													   @CMP_ID AS CMP_ID,@EMP_ID AS EMP_ID,AD.AD_ID AS AD_ID,UPPER(AD.AD_NAME) AS AD_NAME,
													   (CASE WHEN AD.AD_FLAG = 'I' THEN 1 ELSE 2 END) AS AD_FLAG,
													   @MONTH_START_DATE_REPORT AS STAR_DATE,0 AS PREV_AMOUNT,@MONTH_END_DATE_REPORT AS END_DATE,0 AS CURR_AMOUNT,0 AS DIFF_AMOUNT
												FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
													INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON MAD.AD_ID = AD.AD_ID
												WHERE EMP_ID = @EMP_ID  
													AND TO_DATE BETWEEN @MONTH_START_DATE_REPORT AND @MONTH_END_DATE_REPORT 
													AND M_AD_NOT_EFFECT_SALARY = 0
												
												UNION ALL
												
												SELECT ROW_NUMBER() OVER(ORDER BY AD.AD_ID) + (SELECT MAX(SR_NO) FROM #EMP_VARIATION_REPORT) AS SR_NO,
													   @CMP_ID AS CMP_ID,@EMP_ID AS EMP_ID,AD.AD_ID AS AD_ID,UPPER(AD.AD_NAME) AS AD_NAME,
													   (CASE WHEN AD.AD_FLAG = 'I' THEN 1 ELSE 2 END) AS AD_FLAG,
													   @MONTH_START_DATE_REPORT AS STAR_DATE,0 AS PREV_AMOUNT,@MONTH_END_DATE_REPORT AS END_DATE,0 AS CURR_AMOUNT,0 AS DIFF_AMOUNT
												FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
													 INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON MAD.AD_ID = AD.AD_ID
												WHERE EMP_ID = @EMP_ID 
													 AND TO_DATE BETWEEN DATEADD(MM,-1,@MONTH_START_DATE_REPORT) AND DATEADD(MM,-1,@MONTH_END_DATE_REPORT) 
													 AND M_AD_NOT_EFFECT_SALARY = 0
										) T
								
							 INSERT INTO #EMP_VARIATION_REPORT
							 SELECT (SELECT MAX(SR_NO) FROM #EMP_VARIATION_REPORT) + 1 ,@CMP_ID,@EMP_ID,10,'PT AMOUNT',0,@MONTH_START_DATE_REPORT,0,@MONTH_END_DATE_REPORT,0,0
									
							 INSERT INTO #EMP_VARIATION_REPORT
							 SELECT (SELECT MAX(SR_NO) FROM #EMP_VARIATION_REPORT) + 1 ,@CMP_ID,@EMP_ID,11,'LOAN AMOUNT',3,@MONTH_START_DATE_REPORT,0,@MONTH_END_DATE_REPORT,0,0
							
							 INSERT INTO #EMP_VARIATION_REPORT
							 SELECT (SELECT MAX(SR_NO) FROM #EMP_VARIATION_REPORT) + 1 ,@CMP_ID,@EMP_ID,12,'LOAN INTEREST AMOUNT',3,@MONTH_START_DATE_REPORT,0,@MONTH_END_DATE_REPORT,0,0
							
							
							FETCH NEXT FROM CUR_EMP INTO @CMP_ID,@EMP_ID
						END
				 CLOSE CUR_EMP
				 DEALLOCATE CUR_EMP
				
				 UPDATE EV
					SET
					  EV.PREV_AMOUNT = CASE WHEN EV.AD_DESCRIPTION = 'PRESENT DAYS' THEN ISNULL(P_MS.PRESENT_DAYS,0)
											WHEN EV.AD_DESCRIPTION = 'ABSENT DAYS' THEN ISNULL(P_MS.ABSENT_DAYS,0)
											WHEN EV.AD_DESCRIPTION = 'SALARY SETTELMENT' THEN ISNULL(P_MS.SETTELEMENT_AMOUNT,0)
											WHEN EV.AD_DESCRIPTION = 'LATE DAYS' THEN ISNULL(P_MS.LATE_DAYS,0)
											WHEN EV.AD_DESCRIPTION = 'EARLY DAYS' THEN ISNULL(P_MS.EARLY_DAYS,0)
											WHEN EV.AD_DESCRIPTION = 'UNPAID LEAVE' THEN (ISNULL(P_MS.TOTAL_LEAVE_DAYS,0) - ISNULL(P_MS.PAID_LEAVE_DAYS,0))
											WHEN EV.AD_DESCRIPTION = 'PT AMOUNT' THEN ISNULL(P_MS.PT_AMOUNT,0)
											WHEN EV.AD_DESCRIPTION = 'BASIC SALARY' THEN ISNULL(P_MS.SALARY_AMOUNT,0)
											WHEN EV.AD_DESCRIPTION = 'ARREAR DAY' THEN ISNULL(P_MS.AREAR_DAY,0)
											WHEN EV.AD_DESCRIPTION = 'INCREMENT IN SALARY' 
																	  THEN (CASE WHEN I.Increment_Effective_Date BETWEEN DATEADD(MM,-1,EV.PREV_END_DATE) AND EV.PREV_END_DATE THEN 1 ELSE 0 END)
											ELSE 0
										END,
					 EV.CURR_AMOUNT = CASE WHEN EV.AD_DESCRIPTION = 'PRESENT DAYS' THEN ISNULL(MS.PRESENT_DAYS,0)
											WHEN EV.AD_DESCRIPTION = 'ABSENT DAYS' THEN ISNULL(MS.ABSENT_DAYS,0)
											WHEN EV.AD_DESCRIPTION = 'SALARY_SETTELMENT' THEN ISNULL(MS.SETTELEMENT_AMOUNT,0)
											WHEN EV.AD_DESCRIPTION = 'LATE_DAYS' THEN ISNULL(MS.LATE_DAYS,0)
											WHEN EV.AD_DESCRIPTION = 'EARLY_DAYS' THEN ISNULL(MS.EARLY_DAYS,0)
											WHEN EV.AD_DESCRIPTION = 'UNPAID LEAVE' THEN (ISNULL(MS.TOTAL_LEAVE_DAYS,0) - ISNULL(MS.PAID_LEAVE_DAYS,0))
											WHEN EV.AD_DESCRIPTION = 'PT AMOUNT' THEN ISNULL(P_MS.PT_AMOUNT,0)
											WHEN EV.AD_DESCRIPTION = 'BASIC SALARY' THEN ISNULL(MS.SALARY_AMOUNT,0)
											WHEN EV.AD_DESCRIPTION = 'ARREAR DAY' THEN ISNULL(MS.AREAR_DAY,0)
											WHEN EV.AD_DESCRIPTION = 'INCREMENT IN SALARY' 
																	  THEN (CASE WHEN I.Increment_Effective_Date BETWEEN DATEADD(MM,-1,EV.CURR_END_DATE) AND EV.CURR_END_DATE THEN 1 ELSE 0 END)
											ELSE 0
										END
				FROM #EMP_VARIATION_REPORT EV
				INNER JOIN T0095_INCREMENT I
							INNER JOIN(
										SELECT MAX(IQ.INCREMENT_ID) AS INCREMENTID,IQ.EMP_ID FROM T0095_INCREMENT IQ WITH (NOLOCK)
												INNER JOIN(
															SELECT EMP_ID,MAX(INCREMENT_EFFECTIVE_DATE) AS EFFECTIVE_DATE
															FROM T0095_INCREMENT WITH (NOLOCK) 
															WHERE CMP_ID = @CMP_ID AND INCREMENT_EFFECTIVE_DATE <= @MONTH_END_DATE_REPORT
															GROUP BY EMP_ID							             
														  ) AS QRY ON IQ.EMP_ID = QRY.EMP_ID AND IQ.INCREMENT_EFFECTIVE_DATE = QRY.EFFECTIVE_DATE
										GROUP BY IQ.EMP_ID
									  ) AS QRY_1 ON I.INCREMENT_ID = QRY_1.INCREMENTID AND QRY_1.EMP_ID = I.EMP_ID
				 ON I.EMP_ID = EV.EMP_ID
				 INNER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK)
				 ON MONTH(MS.MONTH_END_DATE) = MONTH(EV.CURR_END_DATE) AND YEAR(MS.MONTH_END_DATE) = YEAR(EV.CURR_END_DATE) AND EV.EMP_ID = MS.EMP_ID
				 LEFT OUTER JOIN T0200_MONTHLY_SALARY P_MS WITH (NOLOCK)
				 ON MONTH(P_MS.MONTH_END_DATE) = MONTH(EV.PREV_END_DATE) AND YEAR(P_MS.MONTH_END_DATE) = YEAR(EV.PREV_END_DATE) AND EV.EMP_ID = P_MS.EMP_ID 
				 WHERE AD_FLAG = 0
					 
				 UPDATE #EMP_VARIATION_REPORT 
						SET PREV_AMOUNT = (CASE WHEN CAST(PREV_AMOUNT AS NUMERIC) = 1 THEN 'YES' ELSE 'NO' END),
							CURR_AMOUNT = (CASE WHEN CAST(CURR_AMOUNT AS NUMERIC) = 1 THEN 'YES' ELSE 'NO' END)
				 WHERE AD_DESCRIPTION = 'INCREMENT IN SALARY'
					 
					 
				UPDATE EV
					SET
					  EV.PREV_AMOUNT = CASE WHEN EV.AD_DESCRIPTION = 'LOAN AMOUNT' THEN ISNULL(P_MLP.LOAN_PAY_AMOUNT,0)
											WHEN EV.AD_DESCRIPTION = 'LOAN INTEREST AMOUNT' THEN ISNULL(P_MLP.INTEREST_AMOUNT,0)
											ELSE 0
										END,
					  EV.CURR_AMOUNT = CASE WHEN EV.AD_DESCRIPTION = 'LOAN AMOUNT' THEN ISNULL(MLP.LOAN_PAY_AMOUNT,0)
											WHEN EV.AD_DESCRIPTION = 'LOAN INTEREST AMOUNT' THEN ISNULL(MLP.INTEREST_AMOUNT,0)
											ELSE 0
										END
				FROM #EMP_VARIATION_REPORT EV 
				INNER JOIN T0120_LOAN_APPROVAL LA ON EV.EMP_ID = LA.EMP_ID 
				INNER JOIN T0210_MONTHLY_LOAN_PAYMENT MLP ON MLP.LOAN_APR_ID = LA.LOAN_APR_ID AND MLP.SAL_TRAN_ID IS NOT NULL AND MONTH(MLP.LOAN_PAYMENT_DATE) = MONTH(EV.CURR_END_DATE) AND YEAR(MLP.LOAN_PAYMENT_DATE) = YEAR(EV.CURR_END_DATE)
				LEFT OUTER JOIN T0210_MONTHLY_LOAN_PAYMENT P_MLP ON P_MLP.LOAN_APR_ID = LA.LOAN_APR_ID AND P_MLP.SAL_TRAN_ID IS NOT NULL AND MONTH(P_MLP.LOAN_PAYMENT_DATE) = MONTH(EV.CURR_END_DATE) AND YEAR(P_MLP.LOAN_PAYMENT_DATE) = YEAR(EV.CURR_END_DATE)
				WHERE EV.AD_FLAG = 3
				
				UPDATE EV
					SET EV.CURR_AMOUNT = (CASE WHEN AD.ALLOWANCE_TYPE = 'R' THEN MAD.REIMAMOUNT ELSE ISNULL(MAD.M_AD_AMOUNT,0) END)
				FROM #EMP_VARIATION_REPORT EV
					 INNER JOIN T0210_MONTHLY_AD_DETAIL MAD ON EV.EMP_ID = MAD.EMP_ID AND EV.AD_ID = MAD.AD_ID
					 INNER JOIN T0050_AD_MASTER AD ON MAD.AD_ID = AD.AD_ID
				WHERE TO_DATE BETWEEN DATEADD(MM,-1,EV.CURR_END_DATE) AND EV.CURR_END_DATE 
					  AND M_AD_NOT_EFFECT_SALARY = 0
						  
				UPDATE EV
					SET EV.PREV_AMOUNT = (CASE WHEN AD.ALLOWANCE_TYPE = 'R' THEN MAD.REIMAMOUNT ELSE ISNULL(MAD.M_AD_AMOUNT,0) END)
				FROM #EMP_VARIATION_REPORT EV
					 INNER JOIN T0210_MONTHLY_AD_DETAIL MAD ON EV.EMP_ID = MAD.EMP_ID AND EV.AD_ID = MAD.AD_ID
					 INNER JOIN T0050_AD_MASTER AD ON MAD.AD_ID = AD.AD_ID
				WHERE TO_DATE BETWEEN DATEADD(MM,-1,EV.PREV_END_DATE) AND EV.PREV_END_DATE 
					  AND M_AD_NOT_EFFECT_SALARY = 0
					  
				SELECT 
					ROW_NUMBER()Over(PARTITION BY EM.EMP_ID ORDER BY EM.EMP_ID) AS FLAG,
					EM.Alpha_Emp_Code,
					EM.Emp_Full_Name,
					BM.BRANCH_NAME,
					DGM.DESIG_NAME,
					ESR.PREV_MONTH_GROSS,
					ESR.CURR_MONTH_GROSS,
					ESR.GROSS_VARIATION,
					ESR.PREV_MONTH_NET,
					ESR.CURR_MONTH_NET,
					ESR.NET_VARIATION,
					EVR.AD_DESCRIPTION,
					EVR.PREV_AMOUNT,
					EVR.CURR_AMOUNT
					INTO #SALARY_VARIATION
				FROM #EMP_SALARY_REPORT ESR INNER JOIN #EMP_VARIATION_REPORT EVR ON ESR.EMP_ID = EVR.EMP_ID
					 INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.EMP_ID = ESR.EMP_ID
					 INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.Increment_ID = ESR.INCREMENT_ID
					 LEFT OUTER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON BM.BRANCH_ID = I.BRANCH_ID
					 LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON DGM.DESIG_ID = I.DESIG_ID
					 
				SELECT 
					FLAG,
					CASE WHEN FLAG = 1 THEN Alpha_Emp_Code ELSE '' END As ALPHA_EMP_CODE,
					CASE WHEN FLAG = 1 THEN Emp_Full_Name ELSE '' END As EMP_FULL_NAME,
					CASE WHEN FLAG = 1 THEN BRANCH_NAME ELSE '' END As BRANCH_NAME,
					CASE WHEN FLAG = 1 THEN DESIG_NAME ELSE '' END As DESIGNATION,
					CASE WHEN FLAG = 1 THEN PREV_MONTH_GROSS ELSE NULL END As PREV_GROSS,
					CASE WHEN FLAG = 1 THEN CURR_MONTH_GROSS ELSE NULL END As CURR_GROSS,
					CASE WHEN FLAG = 1 THEN GROSS_VARIATION ELSE NULL END As GROSS_VARIATION,
					CASE WHEN FLAG = 1 THEN PREV_MONTH_NET ELSE NULL END As PREV_NET,
					CASE WHEN FLAG = 1 THEN CURR_MONTH_NET ELSE NULL END As CURR_NET,
					CASE WHEN FLAG = 1 THEN NET_VARIATION ELSE NULL END As NET_VARIATION,
					AD_DESCRIPTION AS DESCRIPTION,
					PREV_AMOUNT,
					CURR_AMOUNT,
					(CASE WHEN ISNUMERIC(CURR_AMOUNT) = 1
							THEN CAST((CAST(CURR_AMOUNT AS numeric(18,2)) - CAST(PREV_AMOUNT AS numeric(18,2))) AS varchar(20))
						  ELSE '-' END) AS DIFF_AMOUNT
				FROM #SALARY_VARIATION
				WHERE (1 = CASE WHEN ISNUMERIC(CURR_AMOUNT) = 1 THEN 
								   (CASE WHEN (CAST(CURR_AMOUNT AS numeric(18,2)) <> CAST(PREV_AMOUNT AS numeric(18,2))) THEN 1 ELSE 0 END)
							  ELSE 0 END OR AD_DESCRIPTION = 'INCREMENT IN SALARY')
				 
			END
	END
 
	
  

