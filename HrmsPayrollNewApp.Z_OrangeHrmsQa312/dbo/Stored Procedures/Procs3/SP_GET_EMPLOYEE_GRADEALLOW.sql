

CREATE PROCEDURE [dbo].[SP_GET_EMPLOYEE_GRADEALLOW]  
 @Cmp_ID numeric,  
 @Ad_ID numeric,  
 @Grd_ID numeric,  
 @Exists char(1), 
 @BranchId numeric = 0, --Add By Paras 02052013 
 @Branch_ID_Multi varchar(max)='',   --Added By Jaina 23-09-2015
 @Vertical_ID_Multi varchar(max)='', --Added By Jaina 23-09-2015
 @Subvertical_ID_Multi varchar(max)='', --Added By Jaina 23-09-2015
 @Dept_ID_Multi varchar(max)='',  --Added By Jaina 23-09-2015
 @Emp_Type char(1) = 'Y'  --Added By Mayur Modi 23-04-2019 to check emp active = Y or left = N
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON


	--Add By Paras 02052013
	If @BranchId = 0
		set @BranchId = null
	IF @Grd_ID = 0	--Added by Nimesh 23-Oct-2015
		SET @Grd_ID = NULL
		
	IF @Branch_ID_Multi='0' or @Branch_ID_Multi=''  --Added By Jaina 23-09-2015
		set @Branch_ID_Multi=null	

	IF @Vertical_ID_Multi='0' or @Vertical_ID_Multi='' --Added By Jaina 23-09-2015
		set @Vertical_ID_Multi=null	

	IF @Subvertical_ID_Multi='0' or @Subvertical_ID_Multi='' --Added By Jaina 23-09-2015
		set @Subvertical_ID_Multi=null	
		
	IF @Dept_ID_Multi='0' or @Dept_ID_Multi='' --Added By Jaina 23-09-2015
		set @Dept_ID_Multi=null	
		
	
		
	Create table #Final 
	(  
		For_Date datetime,  
		Increment_ID numeric(18,0),  
		Cmp_ID numeric(18,0),  
		Emp_Id numeric(18,0),  
		Grd_ID numeric(18,0),
		Branch_Id numeric(18,0),  --add By Paras 03052013    
		Vertical_ID	numeric(18,0),
		SubVertical_ID numeric(18,0),
		Dept_ID	numeric(18,0)

	)  

	--Modified by Nimesh 23-Oct-2015
	--Removed Grd_ID Condition (If Grd_ID has been changed in Employee Transfer or Deputation then it won't be filtered)
	INSERT	INTO #Final  
	SELECT	I.Increment_Effective_Date,I.Increment_ID, Cmp_Id, I.Emp_ID, Grd_Id, I.Branch_ID,I.Vertical_ID,I.SubVertical_ID,I.Dept_ID  
	From		T0095_INCREMENT I WITH (NOLOCK) INNER JOIN   --Change By Jaina 23-09-2015
				(
					SELECT	MAX(Increment_ID) AS Increment_ID, I1.Emp_ID 
					FROM	T0095_INCREMENT	I1 WITH (NOLOCK)
								INNER JOIN (
											SELECT	MAX(Increment_Effective_Date) AS Increment_Effective_Date, I2.Emp_ID
											FROM	T0095_INCREMENT I2 WITH (NOLOCK)
											WHERE Cmp_ID = @Cmp_ID AND Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation'
											GROUP By I2.Emp_ID
											) I2 ON I1.Increment_Effective_Date=I2.Increment_Effective_Date And I1.Emp_Id = I2.Emp_ID
					
					WHERE	Cmp_ID = @Cmp_ID 
							AND Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation'
					GROUP BY I1.Emp_ID
				) Qry On I.Increment_ID = Qry.Increment_ID And I.Emp_ID = Qry.Emp_ID
	
	--Updating Branch, Grade, Department, Vertical, SubVertical as per the lastest increment record
	UPDATE	#Final
	SET		Branch_Id=I.Branch_ID, Vertical_ID=I.Vertical_ID, SubVertical_ID=I.SubVertical_ID,Dept_ID=I.Dept_ID, Grd_ID=I.Grd_ID
	FROM	#Final T INNER JOIN T0095_INCREMENT I ON T.Emp_Id=I.Emp_ID 
			INNER JOIN (
					SELECT	MAX(Increment_ID) AS Increment_ID,Emp_ID 
					FROM	T0095_INCREMENT	WITH (NOLOCK)
					WHERE	Cmp_ID = @Cmp_ID 
					GROUP BY emp_ID
				) Qry On I.Increment_ID = Qry.Increment_ID And I.Emp_ID = Qry.Emp_ID

	/*Commented by Nimesh 
    if @Grd_ID = 0  
     Begin  

       INSERT	INTO #Final  
       SELECT	I.Increment_Effective_Date,I.Increment_ID, Cmp_Id, I.Emp_ID, Grd_Id, I.Branch_ID,I.Vertical_ID,I.SubVertical_ID,I.Dept_ID  
       From		T0095_INCREMENT I INNER JOIN   --Change By Jaina 23-09-2015
					(
						SELECT	MAX(Increment_ID) AS Increment_ID,Emp_ID 
						FROM	T0095_INCREMENT	
						WHERE	Cmp_ID = @Cmp_ID And Branch_ID = Isnull(@BranchId,Branch_Id) 
								AND Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation' 
						GROUP BY emp_ID
					) Qry On I.Increment_ID = Qry.Increment_ID And I.Emp_ID = Qry.Emp_ID
      
     End  
    else if @Grd_ID <> 0   
     BEgin  
		
		INSERT	INTO #Final  
		SELECT	I.Increment_Effective_Date,I.Increment_Id, Cmp_Id, I.Emp_ID, Grd_Id, I.Branch_ID, I.Vertical_ID,I.SubVertical_ID,I.Dept_ID 
		FROM	T0095_INCREMENT I INNER JOIN  --Change By Jaina 23-09-2015
					(
						SELECT	MAX(Increment_ID) AS Increment_ID,Emp_ID 
						FROM	T0095_Increment  
						WHERE	Cmp_ID = @Cmp_ID AND Branch_ID = Isnull(@BranchId,Branch_Id) 
								AND Grd_ID=@Grd_ID AND Increment_Type <> 'Transfer' AND Increment_Type <> 'Deputation' 
						GROUP BY emp_ID
					) Qry On I.Increment_ID = Qry.Increment_ID And I.Emp_ID = Qry.Emp_ID
r
     End  
     */
   
    IF (@BranchId Is Not NUll)
    BEGIN
		DELETE FROM #Final Where Branch_Id <> @BranchId
    END
    
    if (@Grd_ID Is Not NUll)
    BEGIN
		DELETE FROM #Final Where Grd_ID <> @Grd_ID
    END
    
	--Added By Jaina 23-09-2015 Start    
    if (@Branch_ID_Multi Is Not NUll)
    BEGIN
		DELETE FROM #Final Where Branch_Id NOT IN (SELECT CAST(DATA AS NUMERIC) FROM dbo.Split(@Branch_ID_Multi, '#')) OR Branch_Id IS NULL
    END
    
    if (@Vertical_ID_Multi Is Not NUll)
    BEGIN
		DELETE FROM #Final Where Vertical_ID NOT IN (SELECT CAST(DATA AS NUMERIC) FROM dbo.Split(@Vertical_ID_Multi, '#'))  OR Vertical_ID IS NULL
    END
    
    if (@Subvertical_ID_Multi Is Not NUll)
    BEGIN
		DELETE FROM #Final Where SubVertical_ID NOT IN (SELECT CAST(DATA AS NUMERIC) FROM dbo.Split(@Subvertical_ID_Multi, '#')) OR SubVertical_ID IS NULL
    END
     if (@Dept_ID_Multi Is Not NUll)
    BEGIN
		DELETE FROM #Final Where Dept_ID NOT IN (SELECT CAST(DATA AS NUMERIC) FROM dbo.Split(@Dept_ID_Multi, '#')) OR Dept_ID IS NULL
    END
    --Added By Jaina 23-09-2015 End
    
    --insert into #Final    
    --select D.*,Branch_Id from @Data_Temp DT inner join @Data D on DT.Emp_ID = D.Emp_ID where DT.For_Date=D.For_Date     

   SELECT Cmp_ID, Grd_ID,Ad_Mode,ad_Amount,Ad_Max_Limit,Ad_Percentage INTO #GA FROM T0120_GRADEWISE_ALLOWANCE WITH (NOLOCK) WHERE AD_ID=@AD_ID AND CMP_ID=@CMP_ID  

if @Exists ='E'  
 Begin  
	---------Ankit 12092014----------
	(
	SELECT DISTINCT AM.AD_NAME, EED.AD_TRAN_ID, EED.CMP_ID, EED.EMP_ID, EED.AD_ID, EED.INCREMENT_ID,
						  Case When Qry1.FOR_DATE IS null Then eed.FOR_DATE Else Qry1.FOR_DATE End As DATE,
						  Case when EED.E_AD_FLAG = 'E' then 'I' else EED.E_AD_FLAG End as E_AD_FLAG
						  , EED.E_AD_MODE, 
						  Case When Qry1.E_AD_PERCENTAGE IS null Then dbo.F_Show_Decimal(eed.E_AD_PERCENTAGE,eed.CMP_ID) Else dbo.F_Show_Decimal(Qry1.E_AD_PERCENTAGE,E.cmp_id) End As E_AD_PERCENTAGE,
						  --Case When Qry1.E_Ad_Amount IS null Then dbo.F_Show_Decimal(eed.E_AD_Amount,EED.CMP_ID) Else dbo.F_Show_Decimal(Qry1.E_Ad_Amount,E.Cmp_ID) End As E_Ad_Amount,
							Case When Qry1.E_Ad_Amount IS null Then 
								Case When Isnull(eed.Is_Calculate_Zero,0)=0 Then Isnull(dbo.F_Show_Decimal(eed.E_AD_Amount,eed.cmp_id),0) Else dbo.F_Show_Decimal(-1,eed.cmp_id) End 
							Else 
								Case When Isnull(Qry1.Is_Calculate_Zero,0)=0 THEN Isnull(dbo.F_Show_Decimal(Qry1.E_Ad_Amount,E.Cmp_ID),0) Else dbo.F_Show_Decimal(-1,eed.cmp_id) End 
							End As E_Ad_Amount, 

						  EED.E_AD_MAX_LIMIT, AM.AD_LEVEL, 
						  AM.AD_NOT_EFFECT_SALARY, AM.AD_PART_OF_CTC, AM.AD_ACTIVE, 
						  AM.AD_NOT_EFFECT_ON_PT, AM.FOR_FNF, AM.NOT_EFFECT_ON_MONTHLY_CTC, 
						  AM.Is_Yearly, AM.Not_Effect_on_Basic_Calculation, AM.AD_CALCULATE_ON, 
						  AM.Effect_Net_Salary, AM.AD_EFFECT_MONTH, 
						  CASE WHEN eed.E_AD_Flag = 'D' THEN '-' ELSE '+' END AS E_AD_Flag1, AM.Add_in_sal_amt, 
						  AM.AD_DEF_ID,
						  Case When Qry1.ENTRY_TYPE IS null Then '' Else Qry1.ENTRY_TYPE End As ENTRY_TYPE,
						  E.Alpha_Emp_Code,E.Emp_code,E.Emp_First_Name,E.Emp_Full_Name,E.Branch_ID,E.Grd_ID,Branch_Name,Grd_Name
	FROM		T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN 
						T0080_EMP_MASTER E WITH (NOLOCK) on EED.Emp_ID=E.Emp_ID  INNER JOIN 
						T0050_ad_master AM WITH (NOLOCK) on eed.ad_id = am.ad_id LEFT OUTER JOIN
						( Select EEDR.Emp_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE,Is_Calculate_Zero 
							From T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN
							( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK)
								Where Emp_Id In (Select EMP_ID From #Final) And For_date <= GETDATE() 
							 Group by Ad_Id )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
						) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID LEFT OUTER JOIN
						T0095_INCREMENT I WITH (NOLOCK) on I.Emp_ID=E.Emp_ID  LEFT OUTER JOIN
						T0030_BRANCH_MASTER BM WITH (NOLOCK) on BM.Branch_ID=I.Branch_ID  LEFT OUTER JOIN
						T0040_GRADE_MASTER GR WITH (NOLOCK) on GR.Grd_ID=I.Grd_ID  
	WHERE EED.INCREMENT_ID In (Select Increment_ID From #Final) And EEd.EMP_ID In (Select EMP_ID From #Final) 
		And Case When Qry1.ENTRY_TYPE IS null Then '' Else Qry1.ENTRY_TYPE End <> 'D' AND EED.AD_ID = @Ad_ID
		AND E.Emp_Left<>@Emp_Type
	
	UNION ALL
	
	SELECT DISTINCT    dbo.T0050_AD_MASTER.AD_NAME, EED.TRAN_ID, EED.CMP_ID, EED.EMP_ID, EED.AD_ID, EM.INCREMENT_ID, EED.FOR_DATE AS Date, 
						  '', EED.E_AD_MODE,
						   dbo.F_Show_Decimal(EED.E_AD_PERCENTAGE,Eed.CMP_ID) as E_AD_PERCENTAGE, 
						   Case When Isnull(eed.Is_Calculate_Zero,0)=0 Then dbo.F_Show_Decimal(eed.E_AD_Amount,eed.cmp_id) Else dbo.F_Show_Decimal(-1,eed.cmp_id) End  AS E_AD_AMOUNT,
						   EED.E_AD_MAX_LIMIT, dbo.T0050_AD_MASTER.AD_LEVEL, 
						  dbo.T0050_AD_MASTER.AD_NOT_EFFECT_SALARY, dbo.T0050_AD_MASTER.AD_PART_OF_CTC, dbo.T0050_AD_MASTER.AD_ACTIVE, 
						  dbo.T0050_AD_MASTER.AD_NOT_EFFECT_ON_PT, dbo.T0050_AD_MASTER.FOR_FNF, dbo.T0050_AD_MASTER.NOT_EFFECT_ON_MONTHLY_CTC, 
						  dbo.T0050_AD_MASTER.Is_Yearly, dbo.T0050_AD_MASTER.Not_Effect_on_Basic_Calculation, dbo.T0050_AD_MASTER.AD_CALCULATE_ON, 
						  dbo.T0050_AD_MASTER.Effect_Net_Salary, dbo.T0050_AD_MASTER.AD_EFFECT_MONTH, 
						  CASE WHEN eed.E_AD_Flag = 'D' THEN '-' ELSE '+' END AS E_AD_Flag1, dbo.T0050_AD_MASTER.Add_in_sal_amt, 
						  dbo.T0050_AD_MASTER.AD_DEF_ID,EED.ENTRY_TYPE,
						  EM.Alpha_Emp_Code,EM.Emp_code,EM.Emp_First_Name,EM.Emp_Full_Name,EM.Branch_ID,EM.Grd_ID,'',''
	FROM         dbo.T0110_EMP_EARN_DEDUCTION_REVISED AS EED WITH (NOLOCK) INNER JOIN
					( SELECT Max(For_Date) For_Date, Ad_Id FROM T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK) WHERE Emp_Id In (Select EMP_ID From #Final) And For_date <= GETDATE() GROUP BY Ad_Id )Qry 
						ON EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id INNER JOIN
					dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON EED.Emp_ID = EM.Emp_ID INNER JOIN
					dbo.T0050_AD_MASTER WITH (NOLOCK) ON EED.AD_ID = dbo.T0050_AD_MASTER.AD_ID AND EED.AD_ID = @Ad_ID
						  					  
	WHERE EED.EMP_ID In (Select EMP_ID From #Final) AND EEd.ENTRY_TYPE = 'A' AND EM.Emp_Left<>@Emp_Type
	
	) order by Emp_Code  
	---------------Ankit 12092014----------
	
  --if @Grd_ID = 0  
  -- Begin  
  --  select EED.*,D.For_Date as Date,D.Increment_ID,E.Emp_Code , E.Emp_Full_Name,E.Alpha_Emp_Code  , inc.Branch_ID 
  --  From #Final D  
		--inner join  t0100_emp_earn_deduction EED on D.Emp_ID = EED.Emp_ID   And D.Increment_ID = EED.INCREMENT_ID
		--inner join t0080_emp_master E on D.Emp_ID=E.Emp_ID  
		--inner join T0095_INCREMENT Inc on inc.Increment_ID = d.Increment_ID
  --  where EED.For_Date = D.For_Date and EED.Ad_Id = @Ad_ID and E.Emp_Left<>'Y' 
  --    and Isnull(d.Branch_ID,0) = isnull(@BranchId ,Isnull(d.Branch_ID,0)) --Add By  Paras 03052013
  --     order by E.Emp_Code   
  -- End  
  --else if @Grd_ID <> 0   
  -- BEgin  
		--select EED.*,D.For_Date as Date,D.Increment_ID,E.Emp_Code , E.Emp_Full_Name,E.Alpha_Emp_Code , inc.Branch_ID 
		--from #Final D  
		--	inner join  t0100_emp_earn_deduction EED on D.Emp_ID = EED.Emp_ID  And D.Increment_ID = EED.INCREMENT_ID --Increment_ID --''Ankit 03072014
		--	inner join t0080_emp_master E on D.Emp_ID=E.Emp_ID  
		--	inner join T0095_INCREMENT Inc on inc.Increment_ID = d.Increment_ID
		--where EED.For_Date = D.For_Date and EED.Ad_Id = @Ad_ID and D.Grd_ID=@Grd_ID and E.Emp_Left<>'Y'
		--and Isnull(d.Branch_ID,0) = isnull(@BranchId ,Isnull(d.Branch_ID,0)) --Add By  Paras 03052013
		-- order by E.Emp_Code   
  -- End  
    
  -- select EED.*,D.For_Date as Date,D.Increment_ID,E.Emp_Full_Name from t0100_emp_earn_deduction EED inner join #Final D on EED.Emp_ID = D.Emp_ID  inner join t0080_emp_master E on D.Emp_ID=E.Emp_ID  
  -- where EED.For_Date = D.For_Date and EED.Ad_Id = @Ad_ID and D.Grd_ID=@Grd_ID  
 End  
else if @Exists = 'N'  
 Begin  
  
  	--Code Commented and New Code Added by Ramiz on 09/05/2019--	
	--Delete Left Employees, when Active Employee are Searched
	IF @Emp_Type = 'Y'
		DELETE D 
		FROM	#Final D
		WHERE	EXISTS(SELECT 1 FROM T0080_EMP_MASTER E WITH (NOLOCK) WHERE D.EMP_ID=E.EMP_ID AND ISNULL(E.EMP_LEFT_DATE, GETDATE()+1) < GETDATE())
	
	--Allowance Allready Allocated
	DELETE	D 
	FROM	#Final D
	WHERE	EXISTS(SELECT 1 FROM T0100_EMP_EARN_DEDUCTION E WITH (NOLOCK) WHERE D.EMP_ID=E.EMP_ID AND D.Increment_ID=E.Increment_ID AND E.AD_ID=@AD_ID)


	IF ISNULL(@Grd_ID,0) > 0
		DELETE FROM #GA Where Grd_ID <> @Grd_ID
   
   SELECT DISTINCT grd.grd_id,grd.Ad_Mode as E_Ad_Mode,Am.Ad_id,
	  --case when Am.Ad_Flag = 'I' then 'Earning' Else 'Deduction' end as E_Ad_Flag
	  Am.Ad_Flag as E_Ad_Flag
   ,isnull(grd.Ad_Max_Limit,0) as E_Ad_Max_Limit,  --isnull  Ad_Max_Limit added by Jaina 08-01-2018
			  dbo.F_Show_Decimal(grd.Ad_Amount,grd.cmp_id) as E_Ad_Amount ,dbo.F_Show_Decimal(grd.Ad_Percentage,grd.cmp_id) as E_Ad_Percentage,0 as Ad_tran_id,  
			  D.Emp_ID,D.For_Date as Date,D.Increment_ID
			  ,E.Emp_Code ,E.Alpha_Emp_Code, E.Emp_Full_Name , D.Branch_Id,
			Case UPPER(Inc.Payment_Mode) When 'BANK TRANSFER' THEN INC.Inc_Bank_AC_No WHEN 'CASH' THEN 'CASH' WHEN 'CHEQUE' THEN 'CHEQUE' END AS Inc_Bank_AC_No,Branch_Name,Grd_Name
	FROM  #Final D 	
			INNER JOIN T0080_EMP_MASTER E	WITH (NOLOCK) ON D.Emp_ID=E.Emp_ID 	
			INNER JOIN T0095_INCREMENT Inc	WITH (NOLOCK) ON inc.Increment_ID = D.Increment_ID AND E.Emp_ID=INC.Emp_ID
			INNER JOIN #GA grd				 ON D.Grd_ID = grd.Grd_ID	
			INNER JOIN T0050_AD_MASTER AM	WITH (NOLOCK) ON GRD.cmp_id = AM.Cmp_ID AND AM.AD_ID = @AD_ID
			LEFT OUTER JOIN	T0030_BRANCH_MASTER BM WITH (NOLOCK) on BM.Branch_ID=Inc.Branch_ID  
			LEFT OUTER JOIN	T0040_GRADE_MASTER GR WITH (NOLOCK) on GR.Grd_ID=Inc.Grd_ID   
	WHERE	Isnull(D.Branch_ID,0) = isnull(@BranchId ,Isnull(D.Branch_Id,0)) 				
			and AM.ad_id=@Ad_ID 
			and E.Emp_Left <> @Emp_Type
			and NOT EXISTS ( SELECT 1 From T0110_EMP_EARN_DEDUCTION_REVISED ER WITH (NOLOCK)
								WHERE	ER.EMP_ID=D.Emp_Id
										and er.AD_ID=@ad_ID 
										AND  ER.For_Date <= GETDATE() AND ER.INCREMENT_ID=D.INCREMENT_ID)
	ORDER BY E.Emp_Code   
	
	DROP TABLE #Final   
	
 /*  
 if Isnull(@Grd_ID,0) = 0  --Change By Jaina 14-12-2015 (add isnull) 
   Begin  
        
	  SELECT Distinct grd.grd_id,grd.Ad_Mode as E_Ad_Mode,Am.Ad_id,Am.Ad_Flag as E_Ad_Flag,isnull(grd.Ad_Max_Limit,0) as E_Ad_Max_Limit,  --isnull  Ad_Max_Limit added by Jaina 08-01-2018
	  dbo.F_Show_Decimal(grd.Ad_Amount,grd.cmp_id) as E_Ad_Amount ,dbo.F_Show_Decimal(grd.Ad_Percentage,grd.cmp_id) as E_Ad_Percentage,0 as Ad_tran_id,  
		D.Emp_ID,D.For_Date as Date,D.Increment_ID,E.Emp_Code,E.Alpha_Emp_Code, E.Emp_Full_Name , inc.Branch_ID,
		  Case UPPER(Inc.Payment_Mode) When 'BANK TRANSFER' THEN INC.Inc_Bank_AC_No WHEN 'CASH' THEN 'CASH' WHEN 'CHEQUE' THEN 'CHEQUE' END AS Inc_Bank_AC_No
	  FROM  #Final D 
		inner join t0050_ad_master AM on D.Cmp_ID=AM.Cmp_ID	
		inner join T0095_INCREMENT Inc on inc.Increment_ID = D.Increment_ID
		inner JOIN T0120_GRADEWISE_ALLOWANCE grd ON AM.AD_ID = grd.Ad_ID   and Inc.Grd_ID = grd.Grd_ID
		inner join t0080_emp_master E  
		on D.Emp_ID=E.Emp_ID WHERE
		Isnull(d.Branch_ID,0) = isnull(@BranchId ,Isnull(d.Branch_Id,0)) and --Add By  Paras 03052013
		 D.Increment_ID  NOT IN     
		  (select Increment_ID from t0100_emp_earn_deduction where ad_id=@Ad_id) and AM.ad_id=@Ad_ID and E.Emp_Left<>@Emp_Type 
		 and D.Emp_Id not IN ( SELECT ER.emp_Id From T0110_EMP_EARN_DEDUCTION_REVISED ER INNER JOIN #Final DD ON ER.EMP_ID = DD.Emp_Id and ER.AD_ID = @ad_ID and ER.For_Date <= GETDATE() and ER.Increment_ID >= dd.Increment_ID  ) 
		  order by E.Emp_Code    
   End  
  else if Isnull(@Grd_ID,0) <> 0  --Change By Jaina 14-12-2015 (add isnull) 
   BEgin  
       
	  SELECT Distinct grd.grd_id,grd.Ad_Mode as E_Ad_Mode,Am.Ad_id,Am.Ad_Flag as E_Ad_Flag,isnull(grd.Ad_Max_Limit,0) as E_Ad_Max_Limit,  --isnull  Ad_Max_Limit added by Jaina 08-01-2018
	  dbo.F_Show_Decimal(grd.Ad_Amount,grd.cmp_id) as E_Ad_Amount ,dbo.F_Show_Decimal(grd.Ad_Percentage,grd.cmp_id) as E_Ad_Percentage,0 as Ad_tran_id,  
	  D.Emp_ID,D.For_Date as Date,D.Increment_ID
	  ,E.Emp_Code ,E.Alpha_Emp_Code, E.Emp_Full_Name , Inc.Branch_ID,
	  Case UPPER(Inc.Payment_Mode) When 'BANK TRANSFER' THEN INC.Inc_Bank_AC_No WHEN 'CASH' THEN 'CASH' WHEN 'CHEQUE' THEN 'CHEQUE' END AS Inc_Bank_AC_No
	  FROM  #Final D 
		  inner join t0050_ad_master AM on D.Cmp_ID=AM.Cmp_ID 	
		  inner join T0095_INCREMENT Inc on inc.Increment_ID = D.Increment_ID   
		  inner JOIN T0120_GRADEWISE_ALLOWANCE grd ON AM.AD_ID = grd.Ad_ID   and Inc.Grd_ID = grd.Grd_ID
		  inner join t0080_emp_master E  
		  on D.Emp_ID=E.Emp_ID WHERE
			Isnull(d.Branch_Id,0) = isnull(@BranchId ,Isnull(d.Branch_Id,0)) and --Add By  Paras 03052013
		   D.Increment_ID  NOT IN     
		  (select Increment_ID from t0100_emp_earn_deduction where ad_id=@Ad_id) and AM.ad_id=@Ad_ID  and D.Grd_ID=@Grd_ID and E.Emp_Left<>@Emp_Type
		  and D.Emp_Id not IN ( SELECT ER.emp_Id From T0110_EMP_EARN_DEDUCTION_REVISED ER INNER JOIN #Final DD ON ER.EMP_ID = DD.Emp_Id and ER.AD_ID = @ad_ID and ER.For_Date <= GETDATE() and ER.Increment_ID >= dd.Increment_ID ) 
		  order by E.Emp_Code   
	   End 
	 */ 
        
 End  


