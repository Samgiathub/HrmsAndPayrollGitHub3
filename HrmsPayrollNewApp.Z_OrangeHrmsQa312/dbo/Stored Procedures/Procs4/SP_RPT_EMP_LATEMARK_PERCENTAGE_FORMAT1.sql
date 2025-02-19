

---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[SP_RPT_EMP_LATEMARK_PERCENTAGE_FORMAT1]  
  @Cmp_ID   numeric  
 ,@From_Date  datetime  
 ,@To_Date   datetime   
 ,@Branch_ID  numeric  
 ,@Cat_ID   numeric   
 ,@Grd_ID   numeric  
 ,@Type_ID   numeric  
 ,@Dept_ID   numeric  
 ,@Desig_ID   numeric  
 ,@Emp_ID   numeric  
 ,@constraint  varchar(MAX)  
 
   
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

CREATE table #Emp_Cons 
 (      
   Emp_ID numeric ,     
  Branch_ID numeric,
  Increment_ID numeric    
 )     
 
	  
	  INSERT INTO #Emp_Cons 
			SELECT  EMP_ID, 0,0
			FROM	(Select Cast(Data As Numeric) As Emp_ID FROM dbo.Split(@Constraint,'#') T Where T.Data <> '') E
			
			UPDATE  E 
			SET		Branch_ID = I.Branch_ID, Increment_ID=I.Increment_ID
			FROM	#Emp_Cons E						
					INNER JOIN (SELECT	I1.EMP_ID, I1.INCREMENT_ID, I1.BRANCH_ID
								FROM	T0095_INCREMENT I1 WITH (NOLOCK) INNER JOIN #Emp_Cons E1 ON I1.Emp_ID=E1.EMP_ID
										INNER JOIN (SELECT	MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
													FROM	T0095_INCREMENT I2 WITH (NOLOCK) INNER JOIN #Emp_Cons E2 ON I2.Emp_ID=E2.EMP_ID
															INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
																		FROM	T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN #Emp_Cons E3 ON I3.Emp_ID=E3.EMP_ID
																		WHERE	I3.Increment_Effective_Date <= @To_Date
																		GROUP BY I3.Emp_ID
																		) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
													WHERE	I2.Cmp_ID = IsNull(@Cmp_Id , I2.Cmp_ID)
													GROUP BY I2.Emp_ID
													) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_ID=I2.INCREMENT_ID	
								WHERE	I1.Cmp_ID=IsNull(@Cmp_Id , I1.Cmp_ID)											
							) I ON E.EMP_ID=I.Emp_ID


	SELECT MLD.Cmp_ID,MLD.EMP_ID,MLD.Late_Min,MLD.LATE_LUNCH_MIN,MLD.LATE_SEC,MLD.LATE_LUNCH_SEC, MLD.For_Date
	,MLD.NORMAL_RATE,MLD.LUNCH_RATE,MLD.LATE_AMOUNT, MLD.LUNCH_AMOUNT,MLD.LATE_LIMIT, MLD.Shift_Name,MLD.IN_Time
	,MLD.BREAK_OUT,MLD.BREAK_IN,GM.Grd_Name ,TM.Type_Name,DM.Dept_Name,DSM.Desig_Name,BM.Branch_Name,BM.Comp_Name
	,BM.Branch_Address, VS.Vertical_Name,SV.SubVertical_Name,EM.Alpha_Emp_Code,EM.Emp_code,EM.Emp_Full_Name,CM.Cmp_Name,CM.Cmp_Address  
	,ISNULL(MLD.LATE_AMOUNT,0)+ISNULL(MLD.LUNCH_AMOUNT,0) AS Total_Dedu_Amount
	 FROM T0140_MONTHLY_LATEMARK_DESIGNATION MLD  WITH (NOLOCK)
	INNER JOIN #Emp_Cons EC ON MLD.Emp_ID = EC.Emp_ID 
	INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON MLD.Emp_ID = EM.Emp_ID 
	INNER JOIN T0095_Increment I WITH (NOLOCK) ON EC.Increment_ID=I.Increment_ID AND EC.Emp_ID = I.Emp_ID   
	INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON EC.Branch_ID=BM.Branch_ID  
	INNER JOIN t0010_company_master CM WITH (NOLOCK) ON EM.Cmp_ID = CM.Cmp_Id    
	LEFT JOIN t0040_designation_master DSM WITH (NOLOCK) ON I.Desig_id = DSM.Desig_id    
	LEFT JOIN T0040_department_master DM WITH (NOLOCK) ON I.Dept_id = DM.Dept_id         
	LEFT JOIN T0040_TYPE_MASTER TM WITH (NOLOCK) ON I.Type_ID = TM.Type_ID      
	LEFT JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I.Grd_ID = GM.Grd_ID    
	LEFT JOIN T0040_Vertical_Segment VS WITH (NOLOCK) ON I.Vertical_ID = VS.Vertical_ID   
	LEFT JOIN T0050_SubVertical SV WITH (NOLOCK) ON I.SubVertical_ID = SV.SubVertical_ID 
	WHERE MLD.FOR_DATE >= @From_Date AND MLD.FOR_DATE <= @To_Date
	ORDER BY EC.Emp_ID, MLD.FOR_DATE
	
 RETURN  


