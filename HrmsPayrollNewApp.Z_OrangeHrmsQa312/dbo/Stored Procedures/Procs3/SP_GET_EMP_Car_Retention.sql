

-- =============================================
-- Author:		Nilesh Patel 
-- Create date: 12012017
-- Description:	Create For Car Retention Allowance Details
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_GET_EMP_Car_Retention]  
	 @Cmp_ID	numeric,  
	 @Ad_ID		numeric,
	 @Emp_ID	numeric,
	 @Grd_ID	numeric,  
	 @BranchId	numeric = 0, 
	 @Branch_ID_Multi varchar(max)='',   
	 @Vertical_ID_Multi varchar(max)='', 
	 @Subvertical_ID_Multi varchar(max)='', 
	 @Dept_ID_Multi varchar(max)=''  
AS

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if @Emp_ID = 0
		Set @Emp_ID = NULL
	
	If @BranchId = 0
		set @BranchId = null
	
	IF @Branch_ID_Multi='0' or @Branch_ID_Multi='' 
		set @Branch_ID_Multi=null	

	IF @Vertical_ID_Multi='0' or @Vertical_ID_Multi='' 
		set @Vertical_ID_Multi=null	

	IF @Subvertical_ID_Multi='0' or @Subvertical_ID_Multi=''
		set @Subvertical_ID_Multi=null	
	
	IF @Dept_ID_Multi='0' or @Dept_ID_Multi='' 
		set @Dept_ID_Multi=null	 
		
	Declare @For_Date Datetime
	Set @For_Date = GETDATE()          
       
       	
	DECLARE @Final TABLE  
	(  
		For_Date datetime,  
		Increment_ID numeric(18,0),  
		Cmp_ID numeric(18,0),  
		Emp_Id numeric(18,0),  
		Grd_ID numeric(18,0),
		Branch_Id numeric(18,0),
		Vertical_ID numeric(18,0), 
		SubVertical_ID numeric(18,0),
		Dept_ID numeric(18,0)   
	)  
    
    IF @Grd_ID = 0  
		 BEGIN  
			   Insert into @Final  
			   Select I.Increment_Effective_Date,I.Increment_ID, Cmp_Id, I.Emp_ID, Grd_Id, I.Branch_ID ,I.Vertical_ID,I.SubVertical_ID,I.Dept_ID  -- Change By Jaina 23-09-2015
			   From T0095_INCREMENT I WITH (NOLOCK) INNER JOIN
				   (select max(Increment_Id) as Increment_Id,Emp_ID from T0095_Increment WITH (NOLOCK) 
					Where  Cmp_ID = @Cmp_ID And Branch_ID = Isnull(@BranchId,Branch_Id) and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation' and Increment_effective_Date < = @For_Date and Emp_ID = Isnull(@Emp_ID,Emp_ID)
					group by emp_ID) Qry  
					On I.Increment_Id = Qry.Increment_Id And I.Emp_ID = Qry.Emp_ID
			   Where Increment_effective_Date <= @For_Date and I.Emp_ID = Isnull(@Emp_ID,I.Emp_ID)
		 END  
    ELSE IF @Grd_ID <> 0   
		BEGIN  
			Insert into @Final  
			Select I.Increment_Effective_Date,I.Increment_ID, Cmp_Id, I.Emp_ID, Grd_Id, I.Branch_ID,I.Vertical_ID,I.SubVertical_ID,I.Dept_ID From T0095_INCREMENT I WITH (NOLOCK) Inner Join   --Change By Jaina 23-09-2015
			(select max(Increment_Id) as Increment_Id,Emp_ID from T0095_Increment  WITH (NOLOCK)
			Where  Cmp_ID = @Cmp_ID And Branch_ID = Isnull(@BranchId,Branch_Id) And Grd_ID=@Grd_ID and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation' and Emp_ID = Isnull(@Emp_ID,Emp_ID)
			group by emp_ID) Qry 
			On I.Increment_Id = Qry.Increment_Id And I.Emp_ID = Qry.Emp_ID and I.Emp_ID = Isnull(@Emp_ID,I.Emp_ID)
		END  
    
    
    
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
              E_Ad_Mode VARCHAR(10),
              No_of_Month Numeric(5,0)
            )    
    
			INSERT  INTO #tblAllow
				SELECT *
				FROM 
					(
						SELECT  
						        EED.EMP_ID ,
                                EED.INCREMENT_ID ,
                                EED.AD_ID ,
								--  Case When Qry1.E_AD_PERCENTAGE IS null Then eed.E_AD_PERCENTAGE Else Qry1.E_AD_PERCENTAGE End As E_AD_Percentage,
								--Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End As E_AD_Amount,
								Case When Qry1.Increment_ID >= EED.INCREMENT_ID Then
									Case When Qry1.E_AD_PERCENTAGE IS null Then dbo.F_Show_Decimal(eed.E_AD_PERCENTAGE,eed.cmp_id) Else dbo.F_Show_Decimal(Qry1.E_AD_PERCENTAGE,EED.cmp_id) End 
								Else
									isnull(dbo.F_Show_Decimal(eed.E_AD_PERCENTAGE,eed.cmp_id),0)
								End As E_AD_PERCENTAGE,
									
								Case When Qry1.Increment_ID >= EED.INCREMENT_ID Then
									Case When Qry1.E_Ad_Amount IS null Then dbo.F_Show_Decimal(eed.E_AD_Amount,eed.cmp_id) Else dbo.F_Show_Decimal(Qry1.E_Ad_Amount,EED.Cmp_ID) End 
								Else
									Isnull(dbo.F_Show_Decimal(eed.e_ad_Amount,eed.cmp_id),0)
								End As E_Ad_Amount,
								 
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
                                ISNULL(ADM.AD_NOT_EFFECT_ON_LWP, 0) As AD_NOT_EFFECT_ON_LWP ,
                                ISNULL(ADM.Allowance_Type, 'A') AS Allowance_Type ,
                                ISNULL(ADM.auto_paid, 0) AS AutoPaid,
                                AD_LEVEL,E_Ad_Mode,ADM.No_Of_Month
                        FROM    dbo.T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK)
                                INNER JOIN dbo.T0050_AD_MASTER ADM WITH (NOLOCK) ON EEd.AD_ID = ADM.AD_ID LEFT OUTER JOIN
								( Select EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE ,EEDR.Increment_ID
									From T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN
									( Select Max(For_Date) For_Date, Ad_Id,EMP_ID From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK)
										Where Emp_Id IN ( SELECT EMP_ID From @Final ) And For_date <= @For_Date 
									 Group by Ad_Id ,EMP_ID)Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id And EEDR.Emp_ID  = Qry.EMP_ID
								) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID
                        WHERE   EEd.emp_id IN (SELECT EMP_ID FROM  @Final )
                                AND Adm.AD_ACTIVE = 1
                                And Case When Qry1.ENTRY_TYPE IS null Then '' Else Qry1.ENTRY_TYPE End <> 'D'
                                And EED.INCREMENT_ID In (Select INCREMENT_ID From @Final)
								
                        Union ALL
                        
                        SELECT  
						        EED.EMP_ID ,
                                EM.INCREMENT_ID ,
                                EED.AD_ID ,
                                dbo.F_Show_Decimal(E_AD_Percentage,Eed.CMP_ID) as E_AD_Percentage ,
                                dbo.F_Show_Decimal(E_AD_Amount,eed.CMP_ID) as E_AD_Amount ,
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
                                ISNULL(ADM.AD_NOT_EFFECT_ON_LWP, 0) As AD_NOT_EFFECT_ON_LWP ,
                                ISNULL(ADM.Allowance_Type, 'A') AS Allowance_Type ,
                                ISNULL(ADM.auto_paid, 0) AS AutoPaid,
                                AD_LEVEL,E_Ad_Mode,ADM.No_Of_Month
                        FROM    dbo.T0110_EMP_EARN_DEDUCTION_REVISED EED WITH (NOLOCK)
								INNER JOIN ( Select Max(For_Date) For_Date, Ad_Id,EMP_ID From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK)
										Where Emp_Id IN ( SELECT EMP_ID FROM @Final ) And For_date <= @For_Date 
										Group by Ad_Id ,EMP_ID)Qry on EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id And EED.EMP_ID = Qry.EMP_ID
                                INNER JOIN dbo.T0050_AD_MASTER ADM WITH (NOLOCK) ON EEd.AD_ID = ADM.AD_ID
                                INNER JOIN dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON EED.Emp_ID = EM.Emp_ID
                        
                        WHERE   EED.EMP_ID IN (SELECT EMP_ID FROM @Final)
                                AND Adm.AD_ACTIVE = 1
                                And EEd.ENTRY_TYPE = 'A'
                                And eed.INCREMENT_ID In (Select INCREMENT_ID From @Final)
                    ) Qry
                    
                ORDER BY AD_LEVEL ,E_AD_FLAG DESC 
	
	

			IF @Grd_ID = 0  
			   Begin  
			 SELECT EED.Emp_id,
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
              EED.E_Ad_Mode
					,EM.Emp_Code , EM.Emp_Full_Name,EM.Alpha_Emp_Code , D.Branch_ID , EM.Dept_ID,EM.Desig_Id
					,No_of_Month
					,(Case When AD_DEF_ID = 23 then @For_Date Else D.For_Date END) As For_Date
					FROM #tblAllow EED 
						INNER JOIN dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON EED.Emp_ID = EM.Emp_ID 
						INNER JOIN @Final As D ON D.Emp_ID = EED.Emp_ID 
					WHERE 	EM.Emp_Left <>'Y'AND EEd.AD_ID  = @Ad_ID AND Isnull(d.Branch_ID,0) = isnull(@BranchId ,Isnull(d.Branch_ID,0))
     				
			   End  
			ELSE IF @Grd_ID <> 0   
			   BEGIN  
					
			SELECT EED.Emp_id,
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
              EED.E_Ad_Mode,D.For_Date,EM.Emp_Code , EM.Emp_Full_Name,EM.Alpha_Emp_Code , D.Branch_ID , EM.Dept_ID,EM.Desig_Id
					FROM #tblAllow EED 
						INNER JOIN dbo.T0080_EMP_MASTER AS EM WITH (NOLOCK) ON EED.Emp_ID = EM.Emp_ID 
						INNER JOIN @Final As D ON D.Emp_ID = EED.Emp_ID 
					WHERE 	EM.Emp_Left <>'Y'AND EEd.AD_ID  = @Ad_ID AND Isnull(d.Branch_ID,0) = isnull(@BranchId ,Isnull(d.Branch_ID,0))
						AND D.Grd_ID = @Grd_ID 
					
			   END  
   		
RETURN  
  

