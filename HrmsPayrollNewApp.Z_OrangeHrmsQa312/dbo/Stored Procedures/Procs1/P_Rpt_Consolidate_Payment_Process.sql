
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_Rpt_Consolidate_Payment_Process]  
  @CMP_ID		NUMERIC  
 ,@FROM_DATE	DATETIME  
 ,@TO_DATE		DATETIME  
 ,@BRANCH_ID	varchar(Max)   
 ,@CAT_ID		varchar(Max)   
 ,@GRD_ID		varchar(Max)  
 ,@TYPE_ID		varchar(Max)  
 ,@DEPT_ID		varchar(Max)  
 ,@DESIG_ID		varchar(Max)  
 ,@EMP_ID		NUMERIC  
 ,@CONSTRAINT	VARCHAR(MAX)
 --,@Report_Type		NUMERIC = 0
 ,@Payment_Process	VARCHAR(MAX)
 ,@Ad_Id			numeric = 0
 ,@Format			numeric	
 ,@Payment_type  varchar(50) = '' --Added by Jaina 16-09-2017						
 ,@Bank_ID  numeric = 0 --Added by Jaina 16-09-2017
 ,@Status varchar(50) ='' --Added by Jaina 16-09-2017 
 AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	  
	  IF @BRANCH_ID = '0' or @BRANCH_ID = ''
	  SET @BRANCH_ID = NULL  
    
	  IF @CAT_ID = '0' or @CAT_ID = ''    
	  SET @CAT_ID = NULL  
	  
	  IF @GRD_ID = '0' or @GRD_ID = ''    
	  SET @GRD_ID = NULL  
	  
	  IF @TYPE_ID = '0' or @TYPE_ID = ''    
	  SET @TYPE_ID = NULL  
	  
	  IF @DEPT_ID = '0' or @DEPT_ID = ''    
	  SET @DEPT_ID = NULL  
	  
	  IF @DESIG_ID = '0' or @DESIG_ID = ''    
	  SET @DESIG_ID = NULL  
	  
	  IF @EMP_ID = 0    
	  SET @EMP_ID = NULL  
	    
	IF @Status = ''
		set @Status = NULL;
  
	 CREATE TABLE #EMP_CONS 
	 (      
		EMP_ID NUMERIC ,     
		BRANCH_ID NUMERIC,
		INCREMENT_ID NUMERIC    
	 )    
   
	EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @CMP_ID,@FROM_DATE,@TO_DATE,@BRANCH_ID,@CAT_ID,@GRD_ID,@TYPE_ID,@DEPT_ID,
											@DESIG_ID,@EMP_ID,@CONSTRAINT,0,0,'','','','',0,0,0,'',0,0   


	--IF Object_ID('tempdb..#Consolidate_Payment_Process') is not null
	--drop TABLE #Consolidate_Payment_Process

	
			--CREATE TABLE #Consolidate_Payment_Process 
			--(
			--	Emp_Id				NUMERIC,
			--	Emp_Full_Name		VARCHAR(200),
			--	Emp_Code			VARCHAR(200),
			--	Position			VARCHAR(200),
			--	Revised_Position 	VARCHAR(200),
			--	Department			VARCHAR(200),
			--	Hub					VARCHAR(200),
			--	Employee_Status		VARCHAR(200),
			--	Date_Of_Leaving		VARCHAR(200),
			--	Tier				VARCHAR(200),
			--	Branch				VARCHAR(200),
			--	Account_Number		VARCHAR(200),
			--	Date_of_joining		VARCHAR(200),
			--	Net_Salary			NUMERIC(18,2),
			--	Incentive			NUMERIC(18,2),
			--	Deduction			NUMERIC(18,2),
			--	Total_Payable		NUMERIC(18,2),
			--	MOP					VARCHAR(200)
			--)  	
		
		
			--INSERT INTO #Consolidate_Payment_Process(Emp_Id,Emp_Full_Name,Emp_Code,Position,Revised_Position,Department,Hub,
			--										Employee_Status,Date_Of_Leaving,Tier,Branch,Account_Number,Date_of_joining,Net_Salary,
			--										Incentive,Deduction,Total_Payable,MOP)
			
			
	If @Format = 1 
		BEGIN	
		
			SELECT  EC.EMP_ID,EM.Emp_Full_Name,EM.Alpha_Emp_Code as Emp_Code,ISnull(dg1.Desig_Name,dg.Desig_Name) as Designation,dg.Desig_Name as Revised_Designation,
					Dm.Dept_Name as Department,Sv.SubVertical_Name as SubVertical_Name,(case  when EM.Emp_Left <> 'y' then 'Working' end) as employee_status,(case when EM.Emp_Left = 'y' then Convert(varchar(20),EM.Emp_Left_Date,103) else '' end) as Left_Date,
					CM1.Cat_Name as Tier,BM.Branch_Name as Branch,('="' + INC_QRY.Inc_Bank_AC_No + '"') as Account_Number,convert(varchar(20),EM.Date_Of_Join,103) as Date_of_joining,
					Ms.Gross_Salary as Net_Salary,Ep.Net_Amount as Process_Type,Ms.Total_Dedu_Amount as Deduction,
					((Isnull(Ms.Gross_Salary,0) + Isnull(Ep.Net_Amount,0))- IsNULL(Ms.Total_Dedu_Amount,0)) as Net_Payable,INC_QRY.Payment_Mode as MOP
					,@Payment_Process as Payment_Process,convert(varchar(20),@from_Date,103) as from_date,convert(varchar(20),@To_Date,103) as To_date,GM.Grd_Name,v.Vertical_Name,Tm.Type_Name,BM.Comp_Name,BM.Branch_Address,cm.Cmp_Name
					,cm.Cmp_Address
			FROM	T0080_EMP_MASTER EM WITH (NOLOCK) INNER JOIN
					( SELECT I.EMP_ID,I.INCREMENT_ID,I.Branch_ID,I.Desig_Id,I.Dept_ID,I.Type_ID,I.Grd_ID,I.SubVertical_ID,I.Cat_ID,I.Inc_Bank_AC_No
								,I.Payment_Mode,I.Vertical_ID FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN 
						( SELECT MAX(INCREMENT_ID) AS INCREMENT_ID , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) 
						WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
						AND CMP_ID = @CMP_ID
						GROUP BY EMP_ID  ) QRY ON
						I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID )INC_QRY ON 
					EM.EMP_ID = INC_QRY.EMP_ID INNER JOIN
					#EMP_CONS EC ON EC.EMP_ID = EM.EMP_ID LEFt OUTER JOIN
					T0030_BRANCH_MASTER BM WITH (NOLOCK) On bm.Branch_ID = INC_QRY.Branch_ID		LEFt OUTER JOIN
					T0040_DEPARTMENT_MASTER Dm WITH (NOLOCK) on Dm.Dept_Id = INC_QRY.Dept_ID		LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER dg	WITH (NOLOCK) On dg.Desig_ID = INC_QRY.Desig_Id	LEFT OUTER JOIN
					T0040_TYPE_MASTER Tm WITH (NOLOCK) On tm.Type_ID = INC_QRY.Type_ID			INNER JOIN
					T0010_COMPANY_MASTER cm WITH (NOLOCK) On cm.Cmp_Id = em.Cmp_ID				LEFT OUTER JOIN
					T0040_GRADE_MASTER	 GM	WITH (NOLOCK) On Gm.Grd_ID = INC_QRY.Grd_ID			LEFT OUTER JOIN
					(
						SELECT	max(e1.Increment_ID) as Increment_ID,e1.Emp_ID,e1.Desig_Id
						FROM	T0095_INCREMENT e1 WITH (NOLOCK)
						WHERE	Increment_ID < (SELECT max(Increment_ID)
												 FROM T0095_INCREMENT e2 WITH (NOLOCK)
												WHERE	e2.Emp_ID = e1.Emp_ID and month(e2.Increment_Date) = month(@To_date)
														 and year(e2.Increment_date) = year(@To_date))
						GROUP BY e1.Emp_ID,e1.Desig_Id 
					)q1 On Q1.Emp_ID = EC.Emp_ID									LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER dg1 WITH (NOLOCK) on dg1.Desig_ID = Q1.Desig_Id		LEFT OUTER JOIN
					T0040_Vertical_Segment v WITH (NOLOCK) On V.Vertical_ID = Inc_qry.Vertical_ID  LEFT OUTER JOIN					
					T0050_SubVertical Sv WITH (NOLOCK) on Sv.SubVertical_ID = INC_QRY.SubVertical_ID Left OUTER JOIN
					T0030_CATEGORY_MASTER CM1 WITH (NOLOCK) On cm1.Cat_ID = INC_QRY.Cat_ID		INNER JOIN
					T0200_MONTHLY_SALARY Ms WITH (NOLOCK) On Ms.Emp_ID = Ec.Emp_ID and month(Ms.Month_End_Date) = month(@To_date) 
												and Year(Ms.Month_End_Date) = Year(@To_Date) LEFT OUTER JOIN
					MONTHLY_EMP_BANK_PAYMENT EP WITH (NOLOCK) On Ep.Emp_ID = Ec.Emp_ID and month(EP.For_Date) = month(@To_date) 
													and year(EP.For_Date) = year(@To_date) LEFT OUTER JOIN
					T0301_Process_Type_Master PTM WITH (NOLOCK) On Ptm.Process_Type_Id = Ep.payment_process_id and PTM.Cmp_id = ep.Cmp_ID
												
		   WHERE	cm.Cmp_ID = @Cmp_Id and 
					month(ms.Month_End_Date) = month(@To_date) and 
					year(Ms.Month_End_Date) = Year(@To_date) AND
					--EP.Process_Type = @Payment_Process and 
					1 = (case when EP.Process_Type = @Payment_Process  then 1 when @ad_Id >0 then 1 else 0 end) and  --changed by Jimit 16112018.
					EP.Ad_Id = (Case when @Ad_ID <> 0 then @Ad_Id else EP.Ad_Id end)
					order by	EM.Alpha_Emp_Code	asc
					
					
					
		END
	ELSE If @Format = 2
		BEGIN
			SELECT  ROW_NUMBER() Over (order by EM.Alpha_Emp_Code) as Sr_No,('="' + EP.Emp_Bank_AC_No + '"') as Beneficiary_Account_Number,
					EM.Emp_Full_Name as Beneficiary_Name,((Isnull(Ms.Gross_Salary,0) + Isnull(Ep.Net_Amount,0))- IsNULL(Ms.Total_Dedu_Amount,0)) as Amount,
					'Sal' + ' - ' + DATENAME(MONTH,@TO_DATE) + ' - ' + convert(varchar(20),YEAR(Ms.Sal_Generate_Date)) as Narration,convert(varchar(20),@from_Date,103) as from_date,convert(varchar(20),@To_Date,103) as To_date,GM.Grd_Name,v.Vertical_Name,Tm.Type_Name,BM.Comp_Name,BM.Branch_Address,cm.Cmp_Name
					,cm.Cmp_Address,BM.Branch_Name,Sv.SubVertical_Name,EM.Alpha_Emp_Code,dg.Desig_Name,Dm.Dept_Name
			FROM	T0080_EMP_MASTER EM WITH (NOLOCK) INNER JOIN
					( SELECT I.EMP_ID,I.INCREMENT_ID,I.Branch_ID,I.Desig_Id,I.Dept_ID,I.Type_ID,I.Grd_ID,I.SubVertical_ID,I.Cat_ID,I.Inc_Bank_AC_No
								,I.Payment_Mode,I.Vertical_ID FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN 
						( SELECT MAX(INCREMENT_ID) AS INCREMENT_ID , EMP_ID FROM T0095_INCREMENT  WITH (NOLOCK)
						WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
						AND CMP_ID = @CMP_ID
						GROUP BY EMP_ID  ) QRY ON
						I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID )INC_QRY ON 
					EM.EMP_ID = INC_QRY.EMP_ID INNER JOIN
					#EMP_CONS EC ON EC.EMP_ID = EM.EMP_ID LEFt OUTER JOIN
					T0030_BRANCH_MASTER BM WITH (NOLOCK) On bm.Branch_ID = INC_QRY.Branch_ID		LEFt OUTER JOIN
					T0040_DEPARTMENT_MASTER Dm WITH (NOLOCK) on Dm.Dept_Id = INC_QRY.Dept_ID		LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER dg	WITH (NOLOCK) On dg.Desig_ID = INC_QRY.Desig_Id	LEFT OUTER JOIN
					T0040_TYPE_MASTER Tm WITH (NOLOCK) On tm.Type_ID = INC_QRY.Type_ID			INNER JOIN
					T0010_COMPANY_MASTER cm WITH (NOLOCK) On cm.Cmp_Id = em.Cmp_ID				LEFT OUTER JOIN
					T0040_GRADE_MASTER	 GM	WITH (NOLOCK) On Gm.Grd_ID = INC_QRY.Grd_ID			LEFT OUTER JOIN
					(
						SELECT TOP 1 Q.Emp_ID,Q.Desig_Id From
						(select Top 2 * from T0095_INCREMENT WITH (NOLOCK) ORDER BY Emp_ID DESC)Q                     
						ORDER BY Emp_ID
					)q1 On Q1.Emp_ID = INC_QRY.Emp_ID									LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER dg1 WITH (NOLOCK) on dg1.Desig_ID = Q1.Desig_Id		LEFT OUTER JOIN
					T0040_Vertical_Segment v WITH (NOLOCK) On V.Vertical_ID = Inc_qry.Vertical_ID  LEFT OUTER JOIN					
					T0050_SubVertical Sv WITH (NOLOCK) on Sv.SubVertical_ID = INC_QRY.SubVertical_ID Left OUTER JOIN
					T0030_CATEGORY_MASTER CM1 WITH (NOLOCK) On cm1.Cat_ID = INC_QRY.Cat_ID		INNER JOIN
					T0200_MONTHLY_SALARY Ms WITH (NOLOCK) On Ms.Emp_ID = Ec.Emp_ID and month(Ms.Month_End_Date) = month(@To_date) 
												and Year(Ms.Month_End_Date) = Year(@To_Date) LEFT OUTER JOIN
					MONTHLY_EMP_BANK_PAYMENT EP WITH (NOLOCK) On Ep.Emp_ID = Ec.Emp_ID and month(EP.For_Date) = month(@To_date) 
													and year(EP.For_Date) = year(@To_date) LEFT OUTER JOIN
					T0301_Process_Type_Master PTM WITH (NOLOCK) On Ptm.Process_Type_Id = Ep.payment_process_id and PTM.Cmp_id = ep.Cmp_ID
												
		   WHERE	cm.Cmp_ID = @Cmp_Id and 
					month(ms.Month_End_Date) = month(@To_date) and 
					year(Ms.Month_End_Date) = Year(@To_date) AND
					--EP.Process_Type = @Payment_Process AND 
					1 = (case when EP.Process_Type = @Payment_Process  then 1 when @ad_Id >0 then 1 else 0 end) and  --changed by Jimit 16112018.
					EP.Ad_Id = (Case when @Ad_ID <> 0 then @Ad_Id else EP.Ad_Id END)
				order by	EM.Alpha_Emp_Code asc
		END
	ELSE If @Format = 3
	begin
			if @Status = 'All'
				set @Status = NULL
				
			SELECT DISTINCT ROW_NUMBER() Over (order by Em.Alpha_Emp_Code) as Sr_No,EC.Emp_ID,EM.Alpha_Emp_Code,EM.Emp_Full_Name,ES.Calculate_on,ES.Hours,ES.Hour_Rate,
					CASE WHEN INC_QRY.MAX_RATE > INC_QRY.Emp_Holiday_OT_Rate THEN INC_QRY.MAX_RATE ELSE INC_QRY.Emp_Holiday_OT_Rate END AS OT_RATE,
					ES.Amount As OT_Amount,ES.Esic,ES.Net_Amount,
					BM.Branch_Name,Dm.Dept_Name,dg.Desig_Name,GM.Grd_Name,cm.Cmp_Name,cm.Cmp_Address,
					Tm.Type_Name,v.Vertical_Name,Sv.SubVertical_Name,BM.Comp_Name,BM.Branch_Address,month(EP.For_Date),MONTH(@To_date)
			FROM T0080_EMP_MASTER EM WITH (NOLOCK) INNER JOIN
					(
						SELECT I.EMP_ID,I.INCREMENT_ID,I.Branch_ID,I.Desig_Id,I.Dept_ID,I.Type_ID,I.Grd_ID,I.SubVertical_ID,I.Cat_ID,I.Inc_Bank_AC_No
						    ,I.Payment_Mode,I.Vertical_ID,I.Emp_Holiday_OT_Rate,
						    CASE WHEN EMP_WEEKDAY_OT_RATE > I.EMP_WEEKOFF_OT_RATE THEN 
							I.EMP_WEEKOFF_OT_RATE ELSE EMP_WEEKDAY_OT_RATE END MAX_RATE 
						FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN 
								( 
									SELECT MAX(INCREMENT_ID) AS INCREMENT_ID , EMP_ID 
									FROM T0095_INCREMENT  WITH (NOLOCK)
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
										  AND CMP_ID = @CMP_ID
									GROUP BY EMP_ID  
								) QRY ON
						I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID 
					)INC_QRY ON 
					EM.EMP_ID = INC_QRY.EMP_ID INNER JOIN
					#EMP_CONS EC ON EC.EMP_ID = EM.EMP_ID LEFt OUTER JOIN
					T0030_BRANCH_MASTER BM WITH (NOLOCK) On bm.Branch_ID = INC_QRY.Branch_ID		LEFt OUTER JOIN
					T0040_DEPARTMENT_MASTER Dm WITH (NOLOCK) on Dm.Dept_Id = INC_QRY.Dept_ID		LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER dg	WITH (NOLOCK) On dg.Desig_ID = INC_QRY.Desig_Id	LEFT OUTER JOIN
					T0040_TYPE_MASTER Tm WITH (NOLOCK) On tm.Type_ID = INC_QRY.Type_ID			INNER JOIN
					T0010_COMPANY_MASTER cm WITH (NOLOCK) On cm.Cmp_Id = em.Cmp_ID				LEFT OUTER JOIN
					T0040_GRADE_MASTER	 GM	WITH (NOLOCK) On Gm.Grd_ID = INC_QRY.Grd_ID			left OUTER join
					T0040_Vertical_Segment v WITH (NOLOCK) On V.Vertical_ID = Inc_qry.Vertical_ID  LEFT OUTER JOIN					
					T0050_SubVertical Sv WITH (NOLOCK) on Sv.SubVertical_ID = INC_QRY.SubVertical_ID Left OUTER JOIN
					T0030_CATEGORY_MASTER CM1 WITH (NOLOCK) On cm1.Cat_ID = INC_QRY.Cat_ID		INNER JOIN
					T0200_MONTHLY_SALARY Ms WITH (NOLOCK) On Ms.Emp_ID = Ec.Emp_ID and month(Ms.Month_End_Date) = month(@To_date) 
												and Year(Ms.Month_End_Date) = Year(@To_Date) left OUTER JOIN
					T0210_ESIC_On_Not_Effect_on_Salary ES WITH (NOLOCK) ON ES.Emp_Id=EM.Emp_ID and MONTH(ES.For_Date)= MONTH(@To_date)
											and year(ES.For_Date) = YEAR(@To_date)  left OUTER JOIN
					MONTHLY_EMP_BANK_PAYMENT EP WITH (NOLOCK) On Ep.Emp_ID = ES.Emp_ID and month(EP.For_Date) = month(@To_date) 
													and year(EP.For_Date) = year(@To_date)
													
					
			WHERE	cm.Cmp_ID = @Cmp_Id and
					month(EP.For_Date) = month(@To_date) and 
					year(EP.For_Date) = Year(@To_date) AND
					ES.Calculate_on > 0 and
					--EP.Process_Type = @Payment_Process AND 
					EP.Ad_Id = Case when @Ad_ID <> 0 then @Ad_Id else EP.Ad_Id END
					and ep.Payment_Mode = case when @Payment_type <> '' THEN @Payment_type ELSE EP.Payment_Mode END
					and isnull(EP.Emp_Bank_ID,0) = case when @Bank_ID <> 0 THEN @Bank_ID ELSE isnull(EP.Emp_Bank_ID,0) END
					and EP.Status = ISNULL(@Status,EP.Status)
				 	order by	EM.Alpha_Emp_Code asc
			
	end		
  
RETURN

