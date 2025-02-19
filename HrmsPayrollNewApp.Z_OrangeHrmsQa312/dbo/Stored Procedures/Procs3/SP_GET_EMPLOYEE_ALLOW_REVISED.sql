
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[SP_GET_EMPLOYEE_ALLOW_REVISED]  
	 @Cmp_ID	numeric,  
	 @Ad_ID		numeric,  
	 @Grd_ID	numeric,  
	 @Exists	char(1), 
	 @BranchId	numeric = 0, 
	 @For_Date	Datetime = '',
	 @Branch_ID_Multi varchar(max)='',   --Added By Jaina 23-09-2015
	 @Vertical_ID_Multi varchar(max)='', --Added By Jaina 23-09-2015
	 @Subvertical_ID_Multi varchar(max)='', --Added By Jaina 23-09-2015
	 @Dept_ID_Multi varchar(max)='',  --Added By Jaina 23-09-2015
	 @EmpType_ID numeric=0,--added by chetan 20112017
	 @Category_ID numeric=0--added by chetan 20112017
AS

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If @BranchId = 0
		set @BranchId = NULL
	IF @For_Date = '' 
		Set @For_Date = GETDATE();
	IF @Grd_ID = 0
		SET @Grd_ID = NULL;
	
	IF @Branch_ID_Multi='0' or @Branch_ID_Multi=''  --Added By Jaina 23-09-2015
		set @Branch_ID_Multi=null	

	IF @Vertical_ID_Multi='0' or @Vertical_ID_Multi='' --Added By Jaina 23-09-2015
		set @Vertical_ID_Multi=null	

	IF @Subvertical_ID_Multi='0' or @Subvertical_ID_Multi='' --Added By Jaina 23-09-2015
		set @Subvertical_ID_Multi=null	
	
	IF @Dept_ID_Multi='0' or @Dept_ID_Multi='' --Added By Jaina 23-09-2015
		set @Dept_ID_Multi=null	    
		
	IF @EmpType_ID=0 --Added By chetan 20112017
		set @EmpType_ID=null	    
		       
    IF @Category_ID=0 --Added By chetan 20112017
		set @Category_ID=null
       	
	DECLARE @Final TABLE  
	(  
		For_Date datetime,  
		Increment_ID numeric(18,0),  
		Cmp_ID numeric(18,0),  
		Emp_Id numeric(18,0),  
		Grd_ID numeric(18,0),
		Branch_Id numeric(18,0),
		Vertical_ID numeric(18,0), --Added By Jaina 23-09-2015
		SubVertical_ID numeric(18,0), --Added By Jaina 23-09-2015
		Dept_ID numeric(18,0),   --Added By Jaina 23-09-2015 
		EmpType_ID numeric(18,0), --added by chetan 20112017
		Category_ID numeric(18,0) --added by chetan 20112017
	)  

	INSERT INTO @Final  
	SELECT	I.Increment_Effective_Date,I.Increment_ID, Cmp_Id, I.Emp_ID, Grd_Id, I.Branch_ID ,I.Vertical_ID,I.SubVertical_ID,I.Dept_ID,I.[Type_ID],I.Cat_ID  -- Change By Jaina 23-09-2015
	FROM	T0095_INCREMENT I WITH (NOLOCK)
			INNER JOIN (SELECT	I1.EMP_ID, MAX(I1.Increment_ID) As Increment_ID
						FROM	T0095_INCREMENT I1 WITH (NOLOCK)
								INNER JOIN (SELECT	I2.EMP_ID, MAX(I2.Increment_Effective_Date) Increment_Effective_Date
											FROM	T0095_INCREMENT I2 WITH (NOLOCK)
											WHERE	I2.Increment_Effective_Date <= @For_Date and I2.Cmp_ID=@Cmp_ID 
													AND I2.Increment_Type NOT IN ('Transfer', 'Deputation') 
											GROUP BY I2.Emp_ID) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_Effective_Date=I2.Increment_Effective_Date
						WHERE	I1.Cmp_ID=@Cmp_ID 
						GROUP BY I1.Emp_ID) I1 ON I.Increment_ID=I1.Increment_ID
	WHERE	I.Branch_ID = IsNull(@BranchId, I.Branch_ID) AND I.GRD_ID = ISNULL(@Grd_ID, I.GRD_ID) 
			AND I.Type_ID =ISNULL(@EmpType_ID,I.Type_ID) AND COALESCE(I.Cat_ID,0) = COALESCE(@Category_ID,I.Cat_ID,0) --added by chetan 20112017
										
    
	--IF @Grd_ID = 0  
	--	BEGIN  
	--		INSERT INTO @Final  
	--		SELECT	I.Increment_Effective_Date,I.Increment_ID, Cmp_Id, I.Emp_ID, Grd_Id, I.Branch_ID ,I.Vertical_ID,I.SubVertical_ID,I.Dept_ID  -- Change By Jaina 23-09-2015
	--		From	T0095_INCREMENT I 
	--			INNER JOIN (SELECT	I1.EMP_ID, MAX(I1.Increment_ID) As Increment_ID
	--						FROM	T0095_INCREMENT I1 
	--								INNER JOIN (SELECT	I2.EMP_ID, MAX(I2.Increment_Effective_Date) Increment_Effective_Date
	--											FROM	T0095_INCREMENT I2
	--											WHERE	I2.Increment_Effective_Date <= @For_Date and I2.Cmp_ID=@Cmp_ID 
	--													AND I2.Increment_Type NOT IN ('Transfer', 'Deputation') 
	--											GROUP BY I2.Emp_ID) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_Effective_Date=I2.Increment_Effective_Date
	--						WHERE	I1.Cmp_ID=@Cmp_ID 
	--						GROUP BY I1.Emp_ID) I1 ON I.Increment_ID=I1.Increment_ID
	--		WHERE	I.Branch_ID = IsNull(@BranchId, I.Branch_ID) AND I.GRD_ID = ISNULL(@Grd_ID, I.GRD_ID
										
								
	--			--  (select max(Increment_Id) as Increment_Id,Emp_ID from T0095_Increment  
	--			--Where  Cmp_ID = @Cmp_ID And Branch_ID = Isnull(@BranchId,Branch_Id) and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation' and Increment_effective_Date < = @For_Date
	--			--group by emp_ID) Qry  
	--			--On I.Increment_Id = Qry.Increment_Id And I.Emp_ID = Qry.Emp_ID
	--		-- Where Increment_effective_Date <= @For_Date 
	--	END  
 --   ELSE IF @Grd_ID <> 0   
	--	BEGIN  
	--		INSERT	INTO @Final  
	--		SELECT	I.Increment_Effective_Date,I.Increment_ID, Cmp_Id, I.Emp_ID, Grd_Id, I.Branch_ID,I.Vertical_ID,I.SubVertical_ID,I.Dept_ID 
	--		From	T0095_INCREMENT I 
	--				INNER JOIN (SELECT	I1.EMP_ID, MAX(I1.Increment_ID) As Increment_ID
	--								FROM	T0095_INCREMENT I1 
	--										INNER JOIN (SELECT	I2.EMP_ID, MAX(I2.Increment_Effective_Date) Increment_Effective_Date
	--													FROM	T0095_INCREMENT I2
	--													WHERE	I2.Increment_Effective_Date <= @For_Date and I2.Cmp_ID=@Cmp_ID 
	--															AND I2.Increment_Type NOT IN ('Transfer', 'Deputation') 
	--													GROUP BY I2.Emp_ID) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_Effective_Date=I2.Increment_Effective_Date
	--								WHERE	I1.Cmp_ID=@Cmp_ID 
	--								GROUP BY I1.Emp_ID) I1 ON I.Increment_ID=I1.Increment_ID
	--		WHERE	I.Branch_ID = IsNull(@Branch_ID, I.Branch_ID)
	--		--		Inner Join   --Change By Jaina 23-09-2015
	--		--(select max(Increment_Id) as Increment_Id,Emp_ID from T0095_Increment  
	--		--Where  Cmp_ID = @Cmp_ID And Branch_ID = Isnull(@BranchId,Branch_Id) And Grd_ID=@Grd_ID and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation' 
	--		--group by emp_ID) Qry 
	--		--On I.Increment_Id = Qry.Increment_Id And I.Emp_ID = Qry.Emp_ID
	--	END  
    
	
    
    --Added By Jaina 23-09-2015 Start    
    if (@Branch_ID_Multi Is Not NUll)
    BEGIN
		DELETE FROM @Final Where Branch_Id NOT IN (SELECT CAST(DATA AS NUMERIC) FROM dbo.Split(@Branch_ID_Multi, '#')) OR Branch_Id IS NULL
    END
    if (@Vertical_ID_Multi Is Not NUll)
    BEGIN
		DELETE FROM @Final Where Vertical_ID NOT IN (SELECT CAST(DATA AS NUMERIC) FROM dbo.Split(@Vertical_ID_Multi, '#'))  OR Vertical_ID IS NULL
    END
    if (@Subvertical_ID_Multi Is Not NUll)
    BEGIN
		DELETE FROM @Final Where SubVertical_ID NOT IN (SELECT CAST(DATA AS NUMERIC) FROM dbo.Split(@Subvertical_ID_Multi, '#')) OR SubVertical_ID IS NULL
    END
     if (@Dept_ID_Multi Is Not NUll)
    BEGIN
		DELETE FROM @Final Where Dept_ID NOT IN (SELECT CAST(DATA AS NUMERIC) FROM dbo.Split(@Dept_ID_Multi, '#')) OR Dept_ID IS NULL
    END
    --Added By Jaina 23-09-2015 End	
   
	
    CREATE TABLE #tblAllow
    (
        Emp_id NUMERIC(18) ,
        Increment_id NUMERIC(18) ,
        AD_ID NUMERIC(18) ,
        E_Ad_Percentage NUMERIC(12, 5) ,
        E_Ad_Amount NUMERIC(12, 5) ,
        E_Ad_Flag VARCHAR(1) ,
        E_Ad_Max_Limit NUMERIC(27, 5) ,
        varCalc_On VARCHAR(50) ,
        AD_DEF_ID INT ,
        M_AD_NOT_EFFECT_ON_PT NUMERIC(1, 0) ,
        M_AD_NOT_EFFECT_SALARY NUMERIC(1, 0) ,
        M_AD_EFFECT_ON_OT NUMERIC(1, 0) ,
        M_AD_EFFECT_ON_EXTRA_DAY NUMERIC(1, 0) ,
        AD_Name VARCHAR(50) ,
        M_AD_effect_on_Late INT ,
        AD_Effect_Month VARCHAR(50) ,
        AD_CAL_TYPE VARCHAR(20) ,
        AD_EFFECT_FROM VARCHAR(15) ,
        IS_NOT_EFFECT_ON_LWP NUMERIC(1, 0) ,
        Allowance_type VARCHAR(10) ,
        AutoPaid TINYINT ,
        AD_LEVEL NUMERIC(18, 0),
        E_Ad_Mode VARCHAR(10)
              
    )    
    
	INSERT  INTO #tblAllow
	SELECT	*
	FROM 
		(
			SELECT  
					EDR.EMP_ID ,
                    EM.INCREMENT_ID ,
                    EDR.AD_ID ,
                    dbo.F_Show_Decimal(E_AD_Percentage,EDR.CMP_ID) as E_AD_Percentage ,
                    dbo.F_Show_Decimal(E_AD_Amount,EDR.CMP_ID) as E_AD_Amount ,
                    E_AD_Flag ,
                    E_Ad_Max_Limit ,
                    AD_Calculate_On ,
                    AD_DEF_ID ,
                    ISNULL(AD_NOT_EFFECT_ON_PT, 0) As AD_NOT_EFFECT_ON_PT ,
                    ISNULL(AD_NOT_EFFECT_SALARY, 0) As AD_NOT_EFFECT_SALARY ,
                    ISNULL(AD_EFFECT_ON_OT, 0) As AD_EFFECT_ON_OT ,
                    ISNULL(AD_EFFECT_ON_EXTRA_DAY, 0) As AD_EFFECT_ON_EXTRA_DAY ,
                    AD_Name ,
                    ISNULL(AD_effect_on_Late, 0) As AD_effect_on_Late ,
                    ISNULL(AD_Effect_Month, '')  As AD_Effect_Month,
                    ISNULL(AD_CAL_TYPE, '') As AD_CAL_TYPE ,
                    ISNULL(AD_EFFECT_FROM, '') As AD_EFFECT_FROM ,
                    ISNULL(AD.AD_NOT_EFFECT_ON_LWP, 0) As AD_NOT_EFFECT_ON_LWP ,
                    ISNULL(AD.Allowance_Type, 'A') AS Allowance_Type ,
                    ISNULL(AD.auto_paid, 0) AS AutoPaid,
                    AD_LEVEL,E_Ad_Mode
			FROM	dbo.T0110_EMP_EARN_DEDUCTION_REVISED EDR WITH (NOLOCK)
					INNER JOIN (SELECT IER.TRAN_ID,IER.FOR_DATE --Join added by ronakk 11042023
					            FROM   T0110_EMP_EARN_DEDUCTION_REVISED IER
					            INNER JOIN (SELECT Max(FOR_DATE) AS For_Date, emp_id 
					                        FROM   T0110_EMP_EARN_DEDUCTION_REVISED 
					                        WHERE  FOR_DATE <= Getdate() AND cmp_id = @Cmp_ID 
					                        GROUP  BY emp_id) Qry  ON IER.emp_id = Qry.emp_id AND IER.FOR_DATE = Qry.for_date
					                       )Q_I  ON EDR.TRAN_ID = Q_I.TRAN_ID
                    INNER JOIN dbo.T0050_AD_MASTER AD WITH (NOLOCK) ON EDR.AD_ID = AD.AD_ID
                    INNER JOIN dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON EDR.Emp_ID = EM.Emp_ID                        
					INNER JOIN @Final F ON EM.EMP_ID=F.Emp_Id
					INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.INCREMENT_ID=F.Increment_ID AND EDR.FOR_DATE >= I.INCREMENT_EFFECTIVE_DATE
            WHERE   AD.AD_ACTIVE = 1 And ISNULL(EDR.ENTRY_TYPE,'') <> 'D'                                
			UNION
			SELECT  
					EED.EMP_ID ,
                    EED.INCREMENT_ID ,
                    EED.AD_ID ,
					isnull(dbo.F_Show_Decimal(eed.E_AD_PERCENTAGE,eed.cmp_id),0) AS E_AD_PERCENTAGE,
					Isnull(dbo.F_Show_Decimal(eed.e_ad_Amount,eed.cmp_id),0) AS E_Ad_Amount,			 
                    E_AD_Flag ,
                    E_Ad_Max_Limit ,
                    AD_Calculate_On ,
                    AD_DEF_ID ,
                    ISNULL(AD_NOT_EFFECT_ON_PT, 0) As AD_NOT_EFFECT_ON_PT ,
                    ISNULL(AD_NOT_EFFECT_SALARY, 0) As AD_NOT_EFFECT_SALARY ,
                    ISNULL(AD_EFFECT_ON_OT, 0) As AD_EFFECT_ON_OT ,
                    ISNULL(AD_EFFECT_ON_EXTRA_DAY, 0) As AD_EFFECT_ON_EXTRA_DAY ,
                    AD_Name ,
                    ISNULL(AD_effect_on_Late, 0) As AD_effect_on_Late ,
                    ISNULL(AD_Effect_Month, '')  As AD_Effect_Month,
                    ISNULL(AD_CAL_TYPE, '') As AD_CAL_TYPE ,
                    ISNULL(AD_EFFECT_FROM, '') As AD_EFFECT_FROM ,
                    ISNULL(AD.AD_NOT_EFFECT_ON_LWP, 0) As AD_NOT_EFFECT_ON_LWP ,
                    ISNULL(AD.Allowance_Type, 'A') AS Allowance_Type ,
                    ISNULL(AD.auto_paid, 0) AS AutoPaid,
                    AD_LEVEL,E_Ad_Mode
			FROM    @Final F
					INNER JOIN T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) ON F.Increment_ID=EED.Increment_ID
					INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON EED.AD_ID=AD.AD_ID
					INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON F.Increment_ID=I.INCREMENT_ID
			WHERE   AD.AD_ACTIVE = 1								
					AND NOT EXISTS(	SELECT	1 FROM T0110_EMP_EARN_DEDUCTION_REVISED EDR WITH (NOLOCK)
									WHERE	EDR.AD_ID=AD.AD_ID AND I.EMP_ID=EDR.EMP_ID AND EDR.FOR_DATE >= EED.FOR_DATE
											--AND IsNull(EDR.ENTRY_TYPE,'') = 'D' --Comment by ronakk 11042023
											) 
									) Qry
                    
    ORDER BY AD_LEVEL ,E_AD_FLAG DESC 


	IF @Exists ='E'  
		BEGIN  
			--IF @Grd_ID = 0  
			--   Begin  
			SELECT	EED.Emp_id,
					EED.Increment_id ,
					EED.AD_ID ,
					dbo.F_Show_Decimal(EED.E_Ad_Percentage,Em.Cmp_ID) as E_Ad_Percentage  ,
					dbo.F_Show_Decimal(EED.E_Ad_Amount,Em.Cmp_ID) as E_Ad_Amount  ,
					EED.E_Ad_Flag ,
					EED.E_Ad_Max_Limit ,
					EED.varCalc_On ,
					EED.AD_DEF_ID ,
					EED.M_AD_NOT_EFFECT_ON_PT ,
					EED.M_AD_NOT_EFFECT_SALARY,
					EED.M_AD_EFFECT_ON_OT ,
					EED.M_AD_EFFECT_ON_EXTRA_DAY ,
					EED.AD_Name,
					EED.M_AD_effect_on_Late ,
					EED.AD_Effect_Month ,
					EED.AD_CAL_TYPE ,
					EED.AD_EFFECT_FROM ,
					EED.IS_NOT_EFFECT_ON_LWP ,
					EED.Allowance_type ,
					EED.AutoPaid ,
					EED.AD_LEVEL ,
					EED.E_Ad_Mode,D.For_Date,EM.Emp_Code , EM.Emp_Full_Name,EM.Alpha_Emp_Code , D.Branch_ID , EM.Dept_ID,EM.Desig_Id,
					EM.Type_ID,EM.Cat_ID --added by chetan 20112017
					
			FROM	#tblAllow EED 
					INNER JOIN dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON EED.Emp_ID = EM.Emp_ID 
					INNER JOIN @Final As D ON D.Emp_ID = EED.Emp_ID 
			WHERE 	EM.Emp_Left <>'Y'AND EEd.AD_ID  = @Ad_ID --AND Isnull(d.Branch_ID,0) = isnull(@BranchId ,Isnull(d.Branch_ID,0))
     				
			--   End  
			--ELSE IF @Grd_ID <> 0   
			--   BEGIN  
					
			--SELECT EED.Emp_id,
   --           EED.Increment_id ,
   --           EED.AD_ID ,
   --           dbo.F_Show_Decimal(EED.E_Ad_Percentage,Em.Cmp_ID) as E_Ad_Percentage  ,
   --           dbo.F_Show_Decimal(EED.E_Ad_Amount,Em.Cmp_ID) as E_Ad_Amount  ,
   --           EED.E_Ad_Flag ,
   --           EED.E_Ad_Max_Limit ,
   --           EED.varCalc_On ,
   --           EED.AD_DEF_ID ,
   --           EED.M_AD_NOT_EFFECT_ON_PT ,
   --           EED.M_AD_NOT_EFFECT_SALARY,
   --           EED.M_AD_EFFECT_ON_OT ,
   --           EED.M_AD_EFFECT_ON_EXTRA_DAY ,
   --           EED.AD_Name,
   --           EED.M_AD_effect_on_Late ,
   --           EED.AD_Effect_Month ,
   --           EED.AD_CAL_TYPE ,
   --           EED.AD_EFFECT_FROM ,
   --           EED.IS_NOT_EFFECT_ON_LWP ,
   --           EED.Allowance_type ,
   --           EED.AutoPaid ,
   --           EED.AD_LEVEL ,
   --           EED.E_Ad_Mode,D.For_Date,EM.Emp_Code , EM.Emp_Full_Name,EM.Alpha_Emp_Code , D.Branch_ID , EM.Dept_ID,EM.Desig_Id
			--		FROM #tblAllow EED 
			--			INNER JOIN dbo.T0080_EMP_MASTER AS EM ON EED.Emp_ID = EM.Emp_ID 
			--			INNER JOIN @Final As D ON D.Emp_ID = EED.Emp_ID 
			--		WHERE 	EM.Emp_Left <>'Y'AND EEd.AD_ID  = @Ad_ID AND Isnull(d.Branch_ID,0) = isnull(@BranchId ,Isnull(d.Branch_ID,0))
			--			AND D.Grd_ID = @Grd_ID 
					
			--   END  
   		END  
	ELSE IF @Exists = 'N'  
		BEGIN  
	
  		--	IF @Grd_ID = 0  
				--BEGIN  					
					SELECT	Distinct grd.Ad_Mode as E_Ad_Mode,Am.Ad_id,Am.Ad_Flag as E_Ad_Flag,grd.Ad_Max_Limit as E_Ad_Max_Limit
							,dbo.F_Show_Decimal(grd.Ad_Amount,grd.cmp_id) as E_Ad_Amount 
							,dbo.F_Show_Decimal(grd.Ad_Percentage,grd.cmp_id) as E_Ad_Percentage,0 as Ad_tran_id,  
							D.Emp_ID,D.For_Date as Date,D.Increment_ID,E.Emp_Code,E.Alpha_Emp_Code, E.Emp_Full_Name , inc.Branch_ID, Inc.Dept_ID,Inc.Desig_Id,E.Date_OF_Join,
							Case UPPER(Inc.Payment_Mode) When 'BANK TRANSFER' THEN INC.Inc_Bank_AC_No WHEN 'CASH' THEN 'CASH' WHEN 'CHEQUE' THEN 'CHEQUE' END AS Inc_Bank_AC_No
							,Inc.Type_ID,Inc.Cat_ID --added by chetan 20112017
					FROM	@Final D 
							inner join t0050_ad_master AM WITH (NOLOCK) on D.Cmp_ID=AM.Cmp_ID	
							inner join T0095_INCREMENT Inc WITH (NOLOCK) on inc.Increment_ID = D.Increment_ID
							inner JOIN T0120_GRADEWISE_ALLOWANCE grd WITH (NOLOCK) ON AM.AD_ID = grd.Ad_ID   and Inc.Grd_ID = grd.Grd_ID
							inner join t0080_emp_master E  WITH (NOLOCK) on D.Emp_ID=E.Emp_ID 
							--INNER JOIN (SELECT DISTINCT Increment_ID FROM #tblAllow) AL ON D.Increment_ID=AL.Increment_id --AND AL.AD_ID=AM.AD_ID
					WHERE	--Isnull(d.Branch_ID,0) = isnull(@BranchId ,Isnull(d.Branch_Id,0)) --and 
							D.Increment_ID  NOT IN (
													SELECT	Increment_ID 
													FROM	#tblAllow 
													WHERE	ad_id = @Ad_id
													) and
							AM.ad_id=@Ad_ID and E.Emp_Left<>'Y' 
					ORDER BY E.Emp_Code    
			 --   END  
			 --ELSE IF @Grd_ID <> 0   
				--BEGIN  
				--	SELECT	Distinct grd.Ad_Mode as E_Ad_Mode,Am.Ad_id,Am.Ad_Flag as E_Ad_Flag,grd.Ad_Max_Limit as E_Ad_Max_Limit
				--			,dbo.F_Show_Decimal(grd.Ad_Amount,grd.cmp_id) as E_Ad_Amount 
				--			,dbo.F_Show_Decimal(grd.Ad_Percentage,grd.cmp_id) as E_Ad_Percentage,0 as Ad_tran_id,  
				--			D.Emp_ID,D.For_Date as Date,D.Increment_ID,E.Emp_Code,E.Alpha_Emp_Code, E.Emp_Full_Name , inc.Branch_ID, Inc.Dept_ID,Inc.Desig_Id,E.Date_OF_Join,
				--			Case UPPER(Inc.Payment_Mode) When 'BANK TRANSFER' THEN INC.Inc_Bank_AC_No WHEN 'CASH' THEN 'CASH' WHEN 'CHEQUE' THEN 'CHEQUE' END AS Inc_Bank_AC_No
				--	FROM	@Final D 
				--			inner join t0050_ad_master AM on D.Cmp_ID=AM.Cmp_ID	
				--			inner join T0095_INCREMENT Inc on inc.Increment_ID = D.Increment_ID
				--			inner JOIN T0120_GRADEWISE_ALLOWANCE grd ON AM.AD_ID = grd.Ad_ID   and Inc.Grd_ID = grd.Grd_ID
				--			inner join t0080_emp_master E  on D.Emp_ID=E.Emp_ID 							
				--	WHERE	--Isnull(d.Branch_ID,0) = isnull(@BranchId ,Isnull(d.Branch_Id,0)) --and 
				--			--D.Increment_ID  NOT IN (
				--			--						SELECT	Increment_ID 
				--			--						FROM	#tblAllow 
				--			--						WHERE	ad_id=@Ad_id
				--			--						) 
				--			AM.ad_id=@Ad_ID and E.Emp_Left<>'Y' 
				--	ORDER BY E.Emp_Code    
				----	  SELECT Distinct grd.Ad_Mode as E_Ad_Mode,Am.Ad_id,Am.Ad_Flag as E_Ad_Flag,grd.Ad_Max_Limit as E_Ad_Max_Limit
				----	  ,dbo.F_Show_Decimal(grd.Ad_Amount,grd.cmp_id ) as E_Ad_Amount 
				----	  ,dbo.F_Show_Decimal(grd.Ad_Percentage,grd.cmp_id) as E_Ad_Percentage,0 as Ad_tran_id,  
				----	  D.Emp_ID,D.For_Date as Date,D.Increment_ID
				----	  ,E.Emp_Code ,E.Alpha_Emp_Code, E.Emp_Full_Name , Inc.Branch_ID, Inc.Dept_ID,Inc.Desig_Id,
				----	  Case UPPER(Inc.Payment_Mode) When 'BANK TRANSFER' THEN INC.Inc_Bank_AC_No WHEN 'CASH' THEN 'CASH' WHEN 'CHEQUE' THEN 'CHEQUE' END AS Inc_Bank_AC_No
				----	  FROM  @Final D 
				----		  inner join t0050_ad_master AM on D.Cmp_ID=AM.Cmp_ID 	
				----		  inner join T0095_INCREMENT Inc on inc.Increment_ID = D.Increment_ID   
				----		  inner JOIN T0120_GRADEWISE_ALLOWANCE grd ON AM.AD_ID = grd.Ad_ID   and Inc.Grd_ID = grd.Grd_ID
				----		  inner join t0080_emp_master E  
				----		  on D.Emp_ID=E.Emp_ID WHERE
				----			Isnull(d.Branch_Id,0) = isnull(@BranchId ,Isnull(d.Branch_Id,0)) and
				----		   D.Increment_ID  NOT IN     
				----		  (select Increment_ID from #tblAllow where ad_id=@Ad_id) and AM.ad_id=@Ad_ID  and D.Grd_ID=@Grd_ID and E.Emp_Left<>'Y' order by E.Emp_Code   
				--END  
		            
		END  
   

       
RETURN
