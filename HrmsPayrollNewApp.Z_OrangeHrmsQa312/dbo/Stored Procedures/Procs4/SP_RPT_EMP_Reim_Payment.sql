

CREATE PROCEDURE [dbo].[SP_RPT_EMP_Reim_Payment]
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 	
	,@Branch_ID		varchar(Max)=''
	,@Cat_ID		varchar(Max)=''
	,@Grd_ID		varchar(Max)=''
	,@Type_ID		varchar(Max)=''
	,@Dept_ID		varchar(Max)=''
	,@Desig_ID		varchar(Max)=''
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(MAX) = ''	
	,@Emp_Reim      varchar(10)=''
	,@Order_By		varchar(30) = 'Code' --Added by Jimit 28/9/2015 (To sort by Code/Name/Enroll No)

AS
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON 
	
	CREATE table #Emp_Cons 
	(      
		Emp_ID NUMERIC ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC
	)	
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',0,0,0,'0',0,0
	
    Update T0210_Monthly_Reim_Detail set Taxable =0 where RC_apr_ID is null and Cmp_ID=@Cmp_id and Amount =0
    
	Create table #Reim_Payment
	(
		Row_ID        numeric(18,2),
		Emp_ID		  numeric(18,0),	
		Employee_code varchar(255),
		Employee_full_Name varchar(255),
		Branch_Name		  varchar(255),
		Grade_Name		  varchar(255),			
		Department		  varchar(255),
		Designation		  varchar(255),	
		AD_Name			  varchar(255),	
		For_Date          varchar(255),
		Taxable           numeric(18,2),
		Tax_Free		  numeric(18,2),
		ad_ID			  numeric(18,2),
		Branch_ID		  numeric(18,2),
		Desig_dis_No    numeric(18,0) DEFAULT 0  --added jimit 28/9/2015
	   ,Enroll_No       VARCHAR(50)	DEFAULT ''	--added jimit 28/9/2015	
	 )	
	 
	INSERT	INTO #Reim_Payment	
	SELECT	Rank() over (partition by Alpha_Emp_Code,am.ad_ID,for_Date Order by Alpha_Emp_Code,AM.AD_NAME) As row_ID,
			E.Emp_ID,E.Alpha_Emp_Code, E.Emp_Full_Name,BM.Branch_Name,GM.Grd_Name,DM.Dept_Name,DGM.Desig_Name,             
            AM.AD_NAME,CONVERT(varchar(10),for_Date,103) as FOR_DATE, Taxable, Tax_Free_amount,AM.AD_ID,I_Q.Branch_ID
			,DGM.Desig_Dis_No,E.Enroll_No  --added jimit 28/09/2015
	FROM	T0080_EMP_MASTER E WITH (NOLOCK) left outer join T0100_Left_Emp l WITH (NOLOCK) on E.Emp_ID =  l.Emp_ID 
			INNER JOIN ( 
						SELECT	I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID 
						FROM	T0095_Increment I WITH (NOLOCK)
								INNER JOIN ( 
											SELECT	MAX(Increment_ID) as Increment_ID , Emp_ID 
											FROM	T0095_Increment WITH (NOLOCK)	-- Ankit 08092014 for Same Date Increment
											WHERE	Increment_Effective_date <= @To_Date
													AND Cmp_ID = @Cmp_ID
											GROUP BY emp_ID  
											) Qry ON I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID
						) I_Q ON E.Emp_ID = I_Q.Emp_ID  
			INNER JOIN T0210_Monthly_Reim_Detail WITH (NOLOCK) ON I_Q.Emp_ID = T0210_Monthly_Reim_Detail.Emp_ID  
			INNER JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON T0210_Monthly_Reim_Detail.RC_ID =AM.AD_ID  
			INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
			LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
			LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
			LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
			INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  
			INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID 
			INNER JOIN T0050_AD_master WITH (NOLOCK) on T0210_Monthly_Reim_Detail.RC_ID = T0050_AD_master.AD_ID
	WHERE	E.Cmp_ID = @Cmp_Id	
			And E.emp_ID IN (
							SELECT	C.Emp_ID 
							FROM	T0210_Monthly_Reim_Detail R WITH (NOLOCK) INNER JOIN #Emp_Cons C ON R.Emp_ID=C.Emp_ID
							WHERE	for_Date >= @From_Date and for_Date <= @To_Date
							) 
							
			AND for_Date >= @From_Date and for_Date <= @To_Date and Amount>0
	ORDER BY AM.AD_NAME, (
							CASE WHEN IsNumeric(e.Alpha_Emp_Code) = 1 THEN 
									Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
								 WHEN IsNumeric(e.Alpha_Emp_Code) = 0 THEN 
									Left(e.Alpha_Emp_Code + Replicate('',21), 20)
								 ELSE e.Alpha_Emp_Code
							END
						),FOR_DATE ASC
					--ORDER BY RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) 
					
					
			
		SELECT	DISTINCT #Emp_Cons.Emp_ID,Emp_Full_Name,E.Alpha_Emp_Code,RP.Branch_ID
					,E.Vertical_ID,E.SubVertical_ID,   --Added By Jaina 7-10-2015
					E.Dept_ID			--added by jimit 19052017  as Employee reimbursement customize report not open
		FROM	#Emp_Cons  
				INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON #Emp_Cons.Emp_ID = E.Emp_ID
				INNER JOIN #Reim_Payment RP ON E.Emp_ID=RP.Emp_ID
							
				

		CREATE table #Total
		(
			--row_ID		  numeric(18,0),	
			Code          varchar(255),  
			Employee_Name varchar(50),
			Branch_Name   varchar(50), 
			Grade		  varchar(50), 				
			Department		  varchar(255),	
			Designation		  varchar(255),
			Ad_name		  varchar(50),	
			Total_Amount numeric(18,2),
			Total_Taxable numeric(18,2),
			Total_Tax_free numeric(18,2),
			Pending numeric(18,2),
			Emp_ID  numeric(18,2),
			AD_ID   numeric(18,2),
			Branch_ID numeric(18,0),
			Desig_dis_No    numeric(18,0) DEFAULT 0 --added jimit 28/9/2015
			,Enroll_No       VARCHAR(50)	DEFAULT ''	--added jimit 28/9/2015	
		)

--declare @total_month as numeric(18,0)

--set @total_month=year(CONVERT(datetime,'01--' + Convert(nvarchar,YEAR(GETDATE()) - 1)))--YEAR(cast('31-Apr-'+year(getdate())as datetime))

--select @total_month

		INSERT	INTO #Total
		SELECT	distinct   e.Alpha_Emp_Code, 
				RP.Employee_full_Name,
				RP.Branch_Name, 
				RP.Grade_Name,
				RP.Department,
				RP.Designation,
				AD_Name, 
				--I_Q.E_AD_AMOUNT * 12,
				--I_Q.E_AD_AMOUNT * 12-MONTH(e.date_of_join), 
				--I_Q.E_AD_AMOUNT * case when YEAR(e.Date_Of_Join)<=YEAR(@to_date) then 12 -Month(e.Date_Of_Join)+1 else 12 end,
				I_Q.E_AD_AMOUNT * case when DATEDIFF(MONTH, e.date_of_join, @To_Date) + 1 < 12 then DATEDIFF(MONTH, e.date_of_join, @To_Date) + 1 else 12 end,--Condition Chnaged by sumit 06032015
				Qry.Taxable,
				Qry.Tax_Free,
				 --((I_Q.E_AD_AMOUNT * 12) - isnull(Qry.Taxable,0)- isnull(Qry.Tax_Free,0)) ,
				 --((I_Q.E_AD_AMOUNT * case when YEAR(e.Date_Of_Join)<=YEAR(@to_date) then 12 -Month(e.Date_Of_Join)+1 else 12 end) - isnull(Qry.Taxable,0)- isnull(Qry.Tax_Free,0)) ,
				 ((I_Q.E_AD_AMOUNT * case when DATEDIFF(MONTH, e.date_of_join, @To_Date) + 1 < 12 then DATEDIFF(MONTH, e.date_of_join, @To_Date) + 1 else 12 end) - isnull(Qry.Taxable,0)- isnull(Qry.Tax_Free,0)),--Condition Chnaged by sumit 06032015
				
				RP.Emp_ID,
				RP.AD_ID,
				RP.Branch_ID,
				RP.Desig_dis_No,RP.Enroll_No  --added jimit 28/09/2015
		FROM	#Reim_Payment RP		
				INNER JOIN (
								SELECT  Emp_ID, AD_ID,SUM(Taxable) as Taxable, SUM(Tax_Free) as Tax_Free 
								FROM	#Reim_Payment 
								GROUP BY emp_ID,ad_ID
							) Qry on RP.Emp_ID =Qry.Emp_ID and RP.ad_ID =Qry.ad_ID
				INNER JOIN T0080_EMP_MASTER e WITH (NOLOCK) on Qry.Emp_ID = e.Emp_ID
				INNER JOIN ( 
								SELECT	I.Emp_Id,I.AD_ID,I.E_AD_AMOUNT 
								FROM	T0100_EMP_EARN_DEDUCTION I WITH (NOLOCK) 
										INNER JOIN ( 
													SELECT	MAX(Increment_ID) as Increment_ID,Emp_ID 
													FROM	T0095_Increment WITH (NOLOCK)	-- Ankit 08092014 for Same Date Increment
													WHERE	Increment_Effective_date <= @To_Date
															AND Cmp_ID = @cmp_ID
													GROUP BY emp_ID
													) Qry ON I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID
							) I_Q on Rp.Emp_ID = I_Q.Emp_ID and  I_Q.AD_ID =RP.ad_ID
					
	
		
		SELECT	CASE WHEN ROW_NUMBER() OVER(PARTITION BY q.Employee_Name ORDER BY q.Emp_ID,AD_ID) =1 THEN  q.Code ELSE '' END Alpha_Code,
				CASE WHEN ROW_NUMBER() OVER(PARTITION BY q.Employee_Name ORDER BY q.Emp_ID,AD_ID) =1 THEN  Employee_Name ELSE '' END Employee_Name, 
				CASE WHEN ROW_NUMBER() OVER(PARTITION BY q.Employee_Name ORDER BY q.Emp_ID,AD_ID) =1 THEN  Branch_Name ELSE '' END Branch_Name, 
				CASE WHEN ROW_NUMBER() OVER(PARTITION BY q.Employee_Name ORDER BY q.Emp_ID,AD_ID) =1 THEN  Grade ELSE '' END Grade, 
				CASE WHEN ROW_NUMBER() OVER(PARTITION BY q.Employee_Name ORDER BY q.Emp_ID,AD_ID) =1 THEN  q.Department ELSE '' END Department, 
				CASE WHEN ROW_NUMBER() OVER(PARTITION BY q.Employee_Name ORDER BY q.Emp_ID,AD_ID) =1 THEN  q.Designation ELSE '' END Designation, 
				Ad_name,
				Total_Amount,
				Total_Taxable,
				Total_Tax_free,
				Pending,
				Branch_ID
		FROM	(
					SELECT	DISTINCT Employee_Name,Code,Branch_ID,Branch_Name,Grade,Department,Designation,Ad_name,Total_Amount,Total_Taxable,Total_Tax_free,Pending,AD_ID,Emp_ID 
									,Desig_dis_No,Enroll_No
					FROM	#Total
				) q
		--ORDER BY Emp_ID,AD_ID
		---added jimit 28/09/2015
		ORDER BY CASE WHEN @Order_By='Enroll_No' THEN RIGHT(REPLICATE('0',21) + CAST(Enroll_No AS VARCHAR), 21)  --Added by Jaina 31 July 2015 start
							WHEN @Order_By='Name' THEN Employee_Name
							When @Order_By = 'Designation' then (CASE WHEN Desig_dis_No  = 0 THEN Designation ELSE RIGHT(REPLICATE('0',21) + CAST(Desig_dis_No AS VARCHAR), 21)   END)   
							--ELSE RIGHT(REPLICATE(N' ', 500) + Code, 500) 
						End,Case When IsNumeric(Replace(Replace(Code,'="',''),'"','')) = 1 then Right(Replicate('0',21) + Replace(Replace(Code,'="',''),'"',''), 20)
								 When IsNumeric(Replace(Replace(Code,'="',''),'"','')) = 0 then Left(Replace(Replace(Code,'="',''),'"','') + Replicate('',21), 20)
								 Else Replace(Replace(Code,'="',''),'"','') End 
						--RIGHT(REPLICATE(N' ', 500) + Code, 500)
	RETURN




