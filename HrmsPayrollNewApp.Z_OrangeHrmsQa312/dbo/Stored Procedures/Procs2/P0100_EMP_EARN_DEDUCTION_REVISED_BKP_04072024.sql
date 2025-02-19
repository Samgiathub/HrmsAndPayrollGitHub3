
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
Create PROCEDURE [dbo].[P0100_EMP_EARN_DEDUCTION_REVISED_BKP_04072024]
	@Emp_ID Numeric,
	@Cmp_ID Numeric,
	@For_Date Datetime = '',
	@Increment_ID Numeric = 0,
	@Flag bit = 0, -- Added by nilesh patel on 18112016
	@Show_Hidden_Allowance bit=0   --Added by Jaina 19-12-2016
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	If @For_Date Is Null or @For_Date = ''
		Set @For_Date =  GETDATE()
		
	--Declare @Increment_ID Numeric
	--Select @Increment_ID = Increment_Id From T0080_EMP_MASTER Where Emp_ID = @Emp_ID And Cmp_ID = @Cmp_ID 
	If @Increment_ID  = 0 
		BEGIN
		
			Select	@Increment_ID = I.Increment_Id 
			From	T0095_INCREMENT I WITH (NOLOCK)
					INNER JOIN ( 
								Select	MAX(Increment_ID) As Increment_ID
								From	T0095_INCREMENT I1 WITH (NOLOCK)
										INNER JOIN (
													Select	MAX(Increment_Effective_Date) As Increment_Effective_Date
													From	T0095_INCREMENT I2 WITH (NOLOCK)
													WHERE Emp_ID = @Emp_ID And Increment_Effective_Date <= @For_Date and Increment_Type <> 'Transfer' 
													) I2 ON I1.Increment_Effective_Date=I2.Increment_Effective_Date
								WHERE	Emp_ID = @Emp_ID And Increment_Type <> 'Transfer' 
								) I3 ON I.Increment_ID=I3.Increment_ID And Increment_Type <> 'Transfer' 
			WHERE	Emp_ID = @Emp_ID And Cmp_ID = @Cmp_ID 
			
		END
	--print @Increment_ID
	----Start-- Get Previous Allownace Amount--Ankit 20042016
	IF OBJECT_ID('tempdb..#Old_AdAmount') IS NULL
		BEGIN
			CREATE TABLE #Old_AdAmount
			(
				 Emp_ID			NUMERIC
				,Ad_ID			NUMERIC
				,Pre_For_Date		DATETIME 
				,Pre_AD_PERCENTAGE	NUMERIC(18,2)
				,Pre_AD_AMOUNT		NUMERIC(18,2)
				
			)
		END
	
	
	DECLARE @Increment_ID_Pre	NUMERIC
	DECLARE @For_Date_Pre		DATETIME
	
	SELECT	@Increment_ID_Pre = I.Increment_Id ,@For_Date_Pre = I.Increment_Effective_Date
	FROM	T0095_INCREMENT I  WITH (NOLOCK)
			INNER JOIN ( 
						SELECT	MAX(Increment_ID) AS Increment_ID
						FROM	T0095_INCREMENT I1 WITH (NOLOCK)
								INNER JOIN (
											SELECT	MAX(Increment_Effective_Date) AS Increment_Effective_Date
											FROM	T0095_INCREMENT I2 WITH (NOLOCK)
											WHERE Emp_ID = @Emp_ID AND Increment_Effective_Date <= @For_Date AND Increment_Type <> 'Transfer' AND Increment_ID <> @Increment_ID
											) I2 ON I1.Increment_Effective_Date=I2.Increment_Effective_Date
						WHERE	Emp_ID = @Emp_ID AND Increment_Type <> 'Transfer'  AND Increment_ID <> @Increment_ID
						) I1 ON I.Increment_ID=I1.Increment_ID AND Increment_Type <> 'Transfer' 
	WHERE	Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID AND I.Increment_ID <> @Increment_ID
	
	
	
	INSERT INTO #Old_AdAmount
	SELECT DISTINCT EED.EMP_ID, EED.AD_ID, 
					 CASE WHEN Qry1.Increment_ID >= EED.INCREMENT_ID THEN
						CASE WHEN Qry1.FOR_DATE IS NULL THEN eed.FOR_DATE ELSE Qry1.FOR_DATE END 
					 ELSE
						eed.FOR_DATE END AS FOR_DATE,
					 CASE WHEN Qry1.Increment_ID >= EED.INCREMENT_ID THEN
						CASE WHEN Qry1.E_AD_PERCENTAGE IS NULL THEN dbo.F_Show_Decimal(eed.E_AD_PERCENTAGE,eed.cmp_id) ELSE dbo.F_Show_Decimal(Qry1.E_AD_PERCENTAGE,E.cmp_id) END 
					 ELSE
						ISNULL(dbo.F_Show_Decimal(eed.E_AD_PERCENTAGE,eed.cmp_id),0)
					 END AS E_AD_PERCENTAGE,
					 CASE WHEN Qry1.Increment_ID >= EED.INCREMENT_ID THEN
							--CASE WHEN Qry1.E_Ad_Amount IS NULL THEN dbo.F_Show_Decimal(eed.E_AD_Amount,eed.cmp_id) ELSE dbo.F_Show_Decimal(Qry1.E_Ad_Amount,E.Cmp_ID) END 
							Case When Qry1.E_Ad_Amount IS null Then 
								Case When Isnull(eed.Is_Calculate_Zero,0)=0 Then Isnull(dbo.F_Show_Decimal(eed.E_AD_Amount,eed.cmp_id),0) Else dbo.F_Show_Decimal(-1,eed.cmp_id) End 
							Else 
								Case When Isnull(Qry1.Is_Calculate_Zero,0)=0 THEN Isnull(dbo.F_Show_Decimal(Qry1.E_Ad_Amount,E.Cmp_ID),0) Else dbo.F_Show_Decimal(-1,eed.cmp_id) End 
							End
							
					 ELSE
						Case When Isnull(eed.Is_Calculate_Zero,0)=0 Then Isnull(dbo.F_Show_Decimal(eed.E_AD_Amount,eed.cmp_id),0) Else dbo.F_Show_Decimal(-1,eed.cmp_id) End 
					 END AS E_Ad_Amount
					 
		FROM		T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN 
					T0080_EMP_MASTER E WITH (NOLOCK) ON EED.Emp_ID=E.Emp_ID  INNER JOIN 
					T0050_ad_master AM WITH (NOLOCK) ON eed.ad_id = am.ad_id LEFT OUTER JOIN
					( SELECT EEDR.Emp_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE,EEDR.Increment_ID,EEDR.Is_Calculate_Zero 
						FROM T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN
						( SELECT MAX(For_Date) For_Date, Ad_Id FROM T0110_EMP_Earn_Deduction_Revised  WITH (NOLOCK)
							WHERE Emp_Id = @Emp_ID AND For_date <= @For_Date GROUP BY Ad_Id 
						) Qry ON Eedr.For_Date = Qry.For_Date AND Eedr.Ad_Id = Qry.Ad_Id 
					) Qry1 ON eed.AD_ID = qry1.ad_Id AND EEd.EMP_ID = Qry1.EMP_ID AND Qry1.FOR_DATE >= EED.FOR_DATE
		WHERE EED.INCREMENT_ID = @Increment_ID_Pre AND EEd.EMP_ID = @Emp_ID AND CASE WHEN Qry1.ENTRY_TYPE IS NULL THEN '' ELSE Qry1.ENTRY_TYPE END <> 'D'
	
		UNION ALL
	
		SELECT DISTINCT   EED.EMP_ID, EED.AD_ID, EED.FOR_DATE, dbo.F_Show_Decimal(EED.E_AD_PERCENTAGE,eed.CMP_ID) AS E_AD_PERCENTAGE, 
						Case When Isnull(eed.Is_Calculate_Zero,0)=0 Then dbo.F_Show_Decimal(eed.E_AD_Amount,eed.cmp_id) Else dbo.F_Show_Decimal(-1,eed.cmp_id) End  AS E_AD_AMOUNT
						
		FROM        dbo.T0110_EMP_EARN_DEDUCTION_REVISED AS EED WITH (NOLOCK) INNER JOIN
					( SELECT MAX(For_Date) For_Date, Ad_Id FROM T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK) WHERE Emp_Id = @Emp_ID AND For_date <= @For_Date GROUP BY Ad_Id 
					 )Qry  ON EED.For_Date = Qry.For_Date AND EED.Ad_Id = Qry.Ad_Id INNER JOIN
					dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON EED.Emp_ID = EM.Emp_ID INNER JOIN
					dbo.T0050_AD_MASTER WITH (NOLOCK) ON EED.AD_ID = dbo.T0050_AD_MASTER.AD_ID 
		WHERE EED.EMP_ID = @Emp_ID AND EEd.ENTRY_TYPE = 'A' AND EED.Increment_ID = @Increment_ID_Pre
				
	
	----End -- Get Old Allownace Amount--Ankit 20042016
	

			SELECT Q_Main.* ,Pre_For_Date,ISNULL(Pre_AD_PERCENTAGE,0) as Pre_AD_PERCENTAGE	,ISNULL(Pre_AD_AMOUNT,0) as Pre_AD_AMOUNT FROM --Changed By Ramiz 19/10/2016 as It was Throwing Null Error
			(
				SELECT DISTINCT AM.AD_NAME, EED.AD_TRAN_ID, EED.CMP_ID, EED.EMP_ID, EED.AD_ID, EED.INCREMENT_ID,
								  --Case When Qry1.FOR_DATE IS null Then eed.FOR_DATE Else Qry1.FOR_DATE End As FOR_DATE,
								  Case When Qry1.Increment_ID >= EED.INCREMENT_ID /* Qry1.FOR_DATE > EED.FOR_DATE*/ Then
									Case When Qry1.FOR_DATE IS null Then eed.FOR_DATE Else Qry1.FOR_DATE End 
								 Else
									eed.FOR_DATE End As FOR_DATE,
								  EED.E_AD_FLAG, EED.E_AD_MODE, 
								  
									--Case When Qry1.E_AD_PERCENTAGE IS null Then dbo.F_Remove_Zero_Decimal(eed.E_AD_PERCENTAGE) Else dbo.F_Remove_Zero_Decimal(Qry1.E_AD_PERCENTAGE) End As E_AD_PERCENTAGE,
									--Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End 
								 
								 Case When Qry1.Increment_ID >= EED.INCREMENT_ID /*Qry1.FOR_DATE > EED.FOR_DATE*/ Then
										Case When Qry1.E_AD_PERCENTAGE IS null Then dbo.F_Show_Decimal(eed.E_AD_PERCENTAGE,eed.cmp_id) Else dbo.F_Show_Decimal(Qry1.E_AD_PERCENTAGE,E.cmp_id) End 
								 Else
									isnull(dbo.F_Show_Decimal(eed.E_AD_PERCENTAGE,eed.cmp_id),0)
								 End As E_AD_PERCENTAGE,
									
								 Case When Qry1.Increment_ID >= EED.INCREMENT_ID /*Qry1.FOR_DATE > EED.FOR_DATE*/ Then
										Case When Qry1.E_Ad_Amount IS null Then 
											Case When Isnull(eed.Is_Calculate_Zero,0)=0 Then dbo.F_Show_Decimal(eed.E_AD_Amount,eed.cmp_id) Else dbo.F_Show_Decimal(-1,eed.cmp_id) End 
										Else 
											Case When Isnull(Qry1.Is_Calculate_Zero,0)=0 THEN dbo.F_Show_Decimal(Qry1.E_Ad_Amount,E.Cmp_ID) Else dbo.F_Show_Decimal(-1,eed.cmp_id) End 
										End
								 Else
									Case When Isnull(eed.Is_Calculate_Zero,0)=0 Then dbo.F_Show_Decimal(eed.E_AD_Amount,eed.cmp_id) Else dbo.F_Show_Decimal(-1,eed.cmp_id) End 
								 End As E_Ad_Amount,
								  
								  EED.E_AD_MAX_LIMIT, AM.AD_LEVEL, 
								  AM.AD_NOT_EFFECT_SALARY, AM.AD_PART_OF_CTC, AM.AD_ACTIVE, 
								  AM.AD_NOT_EFFECT_ON_PT, AM.FOR_FNF, AM.NOT_EFFECT_ON_MONTHLY_CTC, 
								  AM.Is_Yearly, AM.Not_Effect_on_Basic_Calculation, AM.AD_CALCULATE_ON, 
								  AM.Effect_Net_Salary, AM.AD_EFFECT_MONTH, 
								  CASE WHEN eed.E_AD_Flag = 'D' THEN '-' ELSE '+' END AS E_AD_Flag1, AM.Add_in_sal_amt, 
								  AM.AD_DEF_ID,
								  Case When Qry1.ENTRY_TYPE IS null Then '' Else Qry1.ENTRY_TYPE End As ENTRY_TYPE,
								  E.Alpha_Emp_Code,E.Emp_code,E.Emp_First_Name,E.Emp_Full_Name,E.Branch_ID,E.Grd_ID
								  ,AM.AD_EFFECT_ON_CTC 
								  ,AM.Hide_In_Reports  --Added by Jaina 23-12-2016
				FROM		T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN 
									T0080_EMP_MASTER E WITH (NOLOCK) on EED.Emp_ID=E.Emp_ID  INNER JOIN 
									T0050_ad_master AM WITH (NOLOCK) on eed.ad_id = am.ad_id LEFT OUTER JOIN
									( Select EEDR.Emp_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE,EEDR.Increment_ID ,EEDR.Is_Calculate_Zero
										From T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN
										( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised  WITH (NOLOCK)
											Where Emp_Id = @Emp_ID And For_date <= @For_Date 
										 Group by Ad_Id )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
									) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID AND Qry1.FOR_DATE >= EED.FOR_DATE And Qry1.Increment_ID >= EED.INCREMENT_ID  --as it is changed at WCL On 03072017 (added condition by Jimit 04072017)
				WHERE EED.INCREMENT_ID = @Increment_ID And EEd.EMP_ID = @Emp_ID And Case When Qry1.ENTRY_TYPE IS null Then '' Else Qry1.ENTRY_TYPE End <> 'D'
			
			
			
			UNION ALL
			
				SELECT DISTINCT    dbo.T0050_AD_MASTER.AD_NAME, EED.TRAN_ID, EED.CMP_ID, EED.EMP_ID, EED.AD_ID, EM.INCREMENT_ID, EED.FOR_DATE, 
									  EED.E_AD_FLAG, EED.E_AD_MODE, 
									  dbo.F_Show_Decimal(EED.E_AD_PERCENTAGE,eed.CMP_ID) as E_AD_PERCENTAGE, 
									  Case When Isnull(eed.Is_Calculate_Zero,0)=0 Then dbo.F_Show_Decimal(eed.E_AD_Amount,eed.cmp_id) Else dbo.F_Show_Decimal(-1,eed.cmp_id) End  as E_AD_AMOUNT , 
									  EED.E_AD_MAX_LIMIT, dbo.T0050_AD_MASTER.AD_LEVEL, 
									  dbo.T0050_AD_MASTER.AD_NOT_EFFECT_SALARY, dbo.T0050_AD_MASTER.AD_PART_OF_CTC, dbo.T0050_AD_MASTER.AD_ACTIVE, 
									  dbo.T0050_AD_MASTER.AD_NOT_EFFECT_ON_PT, dbo.T0050_AD_MASTER.FOR_FNF, dbo.T0050_AD_MASTER.NOT_EFFECT_ON_MONTHLY_CTC, 
									  dbo.T0050_AD_MASTER.Is_Yearly, dbo.T0050_AD_MASTER.Not_Effect_on_Basic_Calculation, dbo.T0050_AD_MASTER.AD_CALCULATE_ON, 
									  dbo.T0050_AD_MASTER.Effect_Net_Salary, dbo.T0050_AD_MASTER.AD_EFFECT_MONTH, 
									  CASE WHEN eed.E_AD_Flag = 'D' THEN '-' ELSE '+' END AS E_AD_Flag1, dbo.T0050_AD_MASTER.Add_in_sal_amt, 
									  dbo.T0050_AD_MASTER.AD_DEF_ID,EED.ENTRY_TYPE,
									  EM.Alpha_Emp_Code,EM.Emp_code,EM.Emp_First_Name,EM.Emp_Full_Name,EM.Branch_ID,EM.Grd_ID
									  ,dbo.T0050_AD_MASTER.AD_EFFECT_ON_CTC 
									  ,Hide_In_Reports   --Added by Jaina 23-12-2016
				FROM         dbo.T0110_EMP_EARN_DEDUCTION_REVISED AS EED WITH (NOLOCK) INNER JOIN
								( SELECT Max(For_Date) For_Date, Ad_Id FROM T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK) WHERE Emp_Id = @Emp_ID And For_date <= @For_Date GROUP BY Ad_Id )Qry 
									ON EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id INNER JOIN
								dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON EED.Emp_ID = EM.Emp_ID INNER JOIN
								dbo.T0050_AD_MASTER WITH (NOLOCK) ON EED.AD_ID = dbo.T0050_AD_MASTER.AD_ID 
									  					  
				WHERE EED.EMP_ID = @Emp_ID AND EEd.ENTRY_TYPE = 'A' AND EED.Increment_ID = @Increment_ID
			) Q_Main 
				LEFT OUTER JOIN #Old_AdAmount OA ON OA.Emp_ID = Q_Main.EMP_ID AND OA.Ad_ID = Q_Main.AD_ID
			where  (CASE WHEN @Show_Hidden_Allowance = 0  and  Q_Main.AD_NOT_EFFECT_SALARY=1 and Q_Main.Hide_In_Reports=1 THEN 0 else 1 END )=1  --Change By Jaina 23-12-2016
			ORDER BY E_AD_FLAG DESC, AD_LEVEL ASC
	
	if @Flag = 1
		Begin
			Insert into #Temp_AD_Details(Cmp_ID,Emp_ID,AD_ID,For_Date)
			SELECT Q_Main.CMP_ID,Q_Main.EMP_ID,Q_Main.AD_ID,Q_Main.FOR_DATE
			FROM 
			(
				SELECT DISTINCT AM.AD_NAME, EED.AD_TRAN_ID, EED.CMP_ID, EED.EMP_ID, EED.AD_ID, EED.INCREMENT_ID,
								  --Case When Qry1.FOR_DATE IS null Then eed.FOR_DATE Else Qry1.FOR_DATE End As FOR_DATE,
								  Case When Qry1.Increment_ID >= EED.INCREMENT_ID /* Qry1.FOR_DATE > EED.FOR_DATE*/ Then
									Case When Qry1.FOR_DATE IS null Then eed.FOR_DATE Else Qry1.FOR_DATE End 
								 Else
									eed.FOR_DATE End As FOR_DATE,
								  EED.E_AD_FLAG, EED.E_AD_MODE, 
								  
									--Case When Qry1.E_AD_PERCENTAGE IS null Then dbo.F_Remove_Zero_Decimal(eed.E_AD_PERCENTAGE) Else dbo.F_Remove_Zero_Decimal(Qry1.E_AD_PERCENTAGE) End As E_AD_PERCENTAGE,
									--Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End 
								 
								 Case When Qry1.Increment_ID >= EED.INCREMENT_ID /*Qry1.FOR_DATE > EED.FOR_DATE*/ Then
										Case When Qry1.E_AD_PERCENTAGE IS null Then dbo.F_Show_Decimal(eed.E_AD_PERCENTAGE,eed.cmp_id) Else dbo.F_Show_Decimal(Qry1.E_AD_PERCENTAGE,E.cmp_id) End 
								 Else
									isnull(dbo.F_Show_Decimal(eed.E_AD_PERCENTAGE,eed.cmp_id),0)
								 End As E_AD_PERCENTAGE,
									
								 Case When Qry1.Increment_ID >= EED.INCREMENT_ID /*Qry1.FOR_DATE > EED.FOR_DATE*/ Then
										--Case When Qry1.E_Ad_Amount IS null Then dbo.F_Show_Decimal(eed.E_AD_Amount,eed.cmp_id) Else dbo.F_Show_Decimal(Qry1.E_Ad_Amount,E.Cmp_ID) End 
										Case When Qry1.E_Ad_Amount IS null Then 
											Case When Isnull(eed.Is_Calculate_Zero,0)=0 Then Isnull(dbo.F_Show_Decimal(eed.E_AD_Amount,eed.cmp_id),0) Else dbo.F_Show_Decimal(-1,eed.cmp_id) End 
										Else 
											Case When Isnull(Qry1.Is_Calculate_Zero,0)=0 THEN Isnull(dbo.F_Show_Decimal(Qry1.E_Ad_Amount,E.Cmp_ID),0) Else dbo.F_Show_Decimal(-1,eed.cmp_id) End 
										End
								 Else
									Case When Isnull(eed.Is_Calculate_Zero,0)=0 Then Isnull(dbo.F_Show_Decimal(eed.E_AD_Amount,eed.cmp_id),0) Else dbo.F_Show_Decimal(-1,eed.cmp_id) End 
								 End As E_Ad_Amount,
								  
								  EED.E_AD_MAX_LIMIT, AM.AD_LEVEL, 
								  AM.AD_NOT_EFFECT_SALARY, AM.AD_PART_OF_CTC, AM.AD_ACTIVE, 
								  AM.AD_NOT_EFFECT_ON_PT, AM.FOR_FNF, AM.NOT_EFFECT_ON_MONTHLY_CTC, 
								  AM.Is_Yearly, AM.Not_Effect_on_Basic_Calculation, AM.AD_CALCULATE_ON, 
								  AM.Effect_Net_Salary, AM.AD_EFFECT_MONTH, 
								  CASE WHEN eed.E_AD_Flag = 'D' THEN '-' ELSE '+' END AS E_AD_Flag1, AM.Add_in_sal_amt, 
								  AM.AD_DEF_ID,
								  Case When Qry1.ENTRY_TYPE IS null Then '' Else Qry1.ENTRY_TYPE End As ENTRY_TYPE,
								  E.Alpha_Emp_Code,E.Emp_code,E.Emp_First_Name,E.Emp_Full_Name,E.Branch_ID,E.Grd_ID
								  ,AM.AD_EFFECT_ON_CTC 
				FROM		T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN 
									T0080_EMP_MASTER E WITH (NOLOCK) on EED.Emp_ID=E.Emp_ID  INNER JOIN 
									T0050_ad_master AM  WITH (NOLOCK) on eed.ad_id = am.ad_id LEFT OUTER JOIN
									( Select EEDR.Emp_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE,EEDR.Increment_ID,EEDR.Is_Calculate_Zero 
										From T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN
										( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK)
											Where Emp_Id = @Emp_ID And For_date <= @For_Date 
										 Group by Ad_Id )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id 
									) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID AND Qry1.FOR_DATE >= EED.FOR_DATE
				WHERE EED.INCREMENT_ID = @Increment_ID And EEd.EMP_ID = @Emp_ID And Case When Qry1.ENTRY_TYPE IS null Then '' Else Qry1.ENTRY_TYPE End <> 'D'
			
			
			
			UNION ALL
			
				SELECT DISTINCT    dbo.T0050_AD_MASTER.AD_NAME, EED.TRAN_ID, EED.CMP_ID, EED.EMP_ID, EED.AD_ID, EM.INCREMENT_ID, EED.FOR_DATE, 
									  EED.E_AD_FLAG, EED.E_AD_MODE, 
									  dbo.F_Show_Decimal(EED.E_AD_PERCENTAGE,eed.CMP_ID) as E_AD_PERCENTAGE, dbo.F_Show_Decimal(EED.E_AD_AMOUNT,eed.CMP_ID) as E_AD_AMOUNT , EED.E_AD_MAX_LIMIT, dbo.T0050_AD_MASTER.AD_LEVEL, 
									  dbo.T0050_AD_MASTER.AD_NOT_EFFECT_SALARY, dbo.T0050_AD_MASTER.AD_PART_OF_CTC, dbo.T0050_AD_MASTER.AD_ACTIVE, 
									  dbo.T0050_AD_MASTER.AD_NOT_EFFECT_ON_PT, dbo.T0050_AD_MASTER.FOR_FNF, dbo.T0050_AD_MASTER.NOT_EFFECT_ON_MONTHLY_CTC, 
									  dbo.T0050_AD_MASTER.Is_Yearly, dbo.T0050_AD_MASTER.Not_Effect_on_Basic_Calculation, dbo.T0050_AD_MASTER.AD_CALCULATE_ON, 
									  dbo.T0050_AD_MASTER.Effect_Net_Salary, dbo.T0050_AD_MASTER.AD_EFFECT_MONTH, 
									  CASE WHEN eed.E_AD_Flag = 'D' THEN '-' ELSE '+' END AS E_AD_Flag1, dbo.T0050_AD_MASTER.Add_in_sal_amt, 
									  dbo.T0050_AD_MASTER.AD_DEF_ID,EED.ENTRY_TYPE,
									  EM.Alpha_Emp_Code,EM.Emp_code,EM.Emp_First_Name,EM.Emp_Full_Name,EM.Branch_ID,EM.Grd_ID
									  ,dbo.T0050_AD_MASTER.AD_EFFECT_ON_CTC 
				FROM         dbo.T0110_EMP_EARN_DEDUCTION_REVISED AS EED WITH (NOLOCK) INNER JOIN
								( SELECT Max(For_Date) For_Date, Ad_Id FROM T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK) WHERE Emp_Id = @Emp_ID And For_date <= @For_Date GROUP BY Ad_Id )Qry 
									ON EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id INNER JOIN
								dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON EED.Emp_ID = EM.Emp_ID INNER JOIN
								dbo.T0050_AD_MASTER WITH (NOLOCK) ON EED.AD_ID = dbo.T0050_AD_MASTER.AD_ID 
									  					  
				WHERE EED.EMP_ID = @Emp_ID AND EEd.ENTRY_TYPE = 'A' AND EED.Increment_ID = @Increment_ID
			) Q_Main 
				LEFT OUTER JOIN #Old_AdAmount OA ON OA.Emp_ID = Q_Main.EMP_ID AND OA.Ad_ID = Q_Main.AD_ID
			ORDER BY E_AD_FLAG DESC, AD_LEVEL ASC
		End

END



