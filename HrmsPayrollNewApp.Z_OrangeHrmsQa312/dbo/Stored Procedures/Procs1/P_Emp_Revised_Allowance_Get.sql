

---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P_Emp_Revised_Allowance_Get]    
  @Cmp_ID numeric,    
  @To_Date Datetime = '',  
  @Constraint varchar(max) = '',  
  @GRD_ID   NUMERIC   = 0,  
  @Grade_BasicSalary NUMERIC(18 ,0) = 0  
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
if @To_Date = ''  
 set @To_Date = Getdate()  
  
 DECLARE @Increment_ID  NUMERIC(18, 0)  
 DECLARE @DA_E_ad_Amount  NUMERIC(18, 4)  
 DECLARE @DA_Amount_0433  NUMERIC(18, 4)  
 DECLARE @DA_Amount_0144  NUMERIC(18, 4)  
 DECLARE @DA_M_ad_Amount  NUMERIC(18, 4)  
 DECLARE @AD_ID    numeric  
   
 SET @DA_E_ad_Amount  = 0  
 SET @DA_Amount_0433  = 0  
 SET @DA_Amount_0144  = 0  
 SET @DA_M_ad_Amount  = 0  
 SET @Increment_ID  = 0  
 set @AD_ID    = 0  
   
  
 IF OBJECT_ID('tempdb..#Emp_Cons_Allo') IS NULL  
  BEGIN  
   CREATE TABLE #Emp_Cons_Allo   
   (        
    Emp_ID numeric ,       
    Branch_ID numeric,  
    Increment_ID numeric      
   );  
   CREATE NONCLUSTERED INDEX IX_Emp_Cons_EmpID ON #Emp_Cons_Allo (Emp_ID);  
  End  
    
   IF @Constraint <> ''          
    BEGIN  
     
     INSERT INTO #Emp_Cons_Allo(Emp_ID)          
    SELECT  CAST(data  AS NUMERIC) FROM dbo.Split (@Constraint,'#')  
	        
     

     UPDATE #Emp_Cons_Allo   
     SET  Branch_ID=I1.Branch_ID,  
       Increment_ID =I1.Increment_ID  
     FROM #Emp_Cons_Allo EC   
       INNER JOIN T0095_INCREMENT I1 ON EC.Emp_ID=I1.Emp_ID  
       INNER JOIN (  
           SELECT MAX(I2.Increment_ID) AS Increment_ID,I2.Emp_ID   
           FROM T0095_Increment I2 WITH (NOLOCK)  
             INNER JOIN #Emp_Cons_Allo E ON I2.Emp_ID=E.Emp_ID   
             INNER JOIN (  
                 SELECT MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID  
                 FROM T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN #Emp_Cons_Allo E3 ON I3.Emp_ID=E3.Emp_ID   
                 WHERE I3.Increment_effective_Date <= @to_date AND I3.Cmp_ID =@Cmp_ID  
                 GROUP BY I3.EMP_ID    
                ) I3 ON I2.Increment_Effective_Date=I3.Increment_Effective_Date AND I2.EMP_ID=I3.Emp_ID                                     
           GROUP BY I2.Emp_ID  
          ) I ON I1.Emp_ID = I.Emp_ID AND I1.Increment_ID=I.Increment_ID  
    end  
   else  
    begin  
     
	   
    INSERT INTO #Emp_Cons_Allo        
     SELECT DISTINCT cast(emp_id as numeric)as emp_id,branch_id,Increment_ID   
     FROM dbo.V_Emp_Cons   
     WHERE Cmp_ID=@Cmp_ID   
       AND Increment_Effective_Date <= @To_Date   
     ORDER BY Emp_ID  
    
  
	
     DELETE E FROM #Emp_Cons_Allo E  
     WHERE NOT EXISTS (  
          SELECT TOP 1 1  
          FROM t0095_increment TI WITH (NOLOCK)  
            INNER JOIN (  
               SELECT MAX(T0095_Increment.Increment_ID) AS Increment_ID,T0095_Increment.Emp_ID   
               FROM T0095_Increment WITH (NOLOCK) INNER JOIN #Emp_Cons_Allo E ON T0095_INCREMENT.Emp_ID=E.Emp_ID -- Ankit 12092014 for Same Date Increment  
               WHERE Increment_effective_Date <= @to_date AND Cmp_ID =@Cmp_Id   
               GROUP BY T0095_Increment.emp_ID  
               ) new_inc ON TI.Emp_ID = new_inc.Emp_ID AND Ti.Increment_ID=new_inc.Increment_ID  
          WHERE Increment_effective_Date <= @to_date AND E.Increment_ID = TI.Increment_ID  
         )  

      
    END   
   

IF (@Grade_BasicSalary = 0)--This is a Common Condition and Else Condition is of Mafatlal Client (Gradewise Salary)  
 BEGIN  


  IF OBJECT_ID ('tempdb..#Tbl_Yearly_Salary_Register') IS NULL  
   BEGIN  
		print 'abc'
    SELECT * 
	FROM   
    (  
     SELECT EED.EMP_ID ,EED.AD_ID,  
      --Case When Qry1.E_AD_PERCENTAGE IS null Then eed.E_AD_PERCENTAGE Else Qry1.E_Ad_Percentage End As E_AD_Percentage,  
      --Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End As E_AD_Amount  
      
	  Case When Qry1.Increment_ID >= EED.INCREMENT_ID /*Qry1.FOR_DATE > EED.FOR_DATE*/ Then  
       Case When Qry1.FOR_DATE IS null Then eed.FOR_DATE Else Qry1.FOR_DATE End   
       Else  
       eed.FOR_DATE End As FOR_DATE,  

      Case When Qry1.Increment_ID >= EED.INCREMENT_ID /*Qry1.FOR_DATE > EED.FOR_DATE*/ Then  
       Case When Qry1.E_AD_PERCENTAGE IS null Then eed.E_AD_PERCENTAGE Else Qry1.E_AD_PERCENTAGE End   
       Else  
       eed.E_AD_PERCENTAGE End As E_AD_PERCENTAGE,
	   
       CASE WHEN Qry1.Increment_ID >= EED.INCREMENT_ID THEN  
        --CASE WHEN Qry1.E_Ad_Amount IS NULL THEN dbo.F_Show_Decimal(eed.E_AD_Amount,eed.cmp_id) ELSE dbo.F_Show_Decimal(Qry1.E_Ad_Amount,E.Cmp_ID) END   
        Case When Qry1.E_Ad_Amount IS null Then   
         Case When Isnull(eed.Is_Calculate_Zero,0)=0 Then Isnull(dbo.F_Show_Decimal(eed.E_AD_Amount,eed.cmp_id),0) Else dbo.F_Show_Decimal(-1,eed.cmp_id) End   
        Else   
         Case When Isnull(Qry1.Is_Calculate_Zero,0)=0 THEN Isnull(dbo.F_Show_Decimal(Qry1.E_Ad_Amount,EED.Cmp_ID),0) Else dbo.F_Show_Decimal(-1,eed.cmp_id) End   
        End  
         
       ELSE  
       Case When Isnull(eed.Is_Calculate_Zero,0)=0 Then Isnull(dbo.F_Show_Decimal(eed.E_AD_Amount,eed.cmp_id),0) Else dbo.F_Show_Decimal(-1,eed.cmp_id) End   
       END 
	   AS E_Ad_Amount 
	  

     FROM dbo.T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK)  
       inner join dbo.T0050_AD_MASTER ADM WITH (NOLOCK) ON EEd.AD_ID = ADM.AD_ID     
       --Comment by nilesh patel on 06102016   
       ---Uncommented by Hardik 14/02/2017 as below condition is correct  
       INNER JOIN                      
       (select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join  
       (Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)  
       Where Increment_effective_Date <= @to_date and increment_type <> 'transfer' Group by emp_ID) new_inc  
       on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date  
       Where TI.Increment_effective_Date <= @to_date and increment_type <> 'transfer' group by ti.emp_id  
        
       ) Qry_temp ON Qry_temp.Increment_Id = EED.INCREMENT_ID --and Qry_temp.Emp_ID = EED.EMP_ID   
         LEFT OUTER JOIN  
       ( Select EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE ,EEDR.Increment_ID,Is_Calculate_Zero  
        From T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN  
        ( Select Max(For_Date) For_Date, Ad_Id ,Emp_id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK)   
         Where For_date <= @to_date  
         Group by Ad_Id,Emp_id )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id and Eedr.EMP_ID = Qry.emp_id  
       ) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID and Qry1.FOR_DATE >= EED.FOR_DATE and Qry1.Increment_Id = Qry_temp.Increment_Id  --Increment condition added by Jaina 21-09-2017  --added By Jimit 04072017 as it is changed at WCL       
           
       inner join #Emp_Cons_Allo EC on  EED.EMP_ID = EC.emp_id --AND EED.Increment_ID = EC.Increment_ID -- Added by nilesh patel on 06102016 --Commented by Hardik 14/02/2017 as transfer case is getting wrong  
      WHERE  Adm.AD_ACTIVE = 1 and EED.cmp_id = @Cmp_ID   
      And Case When Qry1.ENTRY_TYPE IS null Then '' Else Qry1.ENTRY_TYPE End <> 'D'  
       
     UNION ALL  
      
     SELECT DISTINCT  
     EED.emp_id,EED.AD_ID,EED.FOR_DATE,  
     E_AD_Percentage,  
     
	 Case When Isnull(eed.Is_Calculate_Zero,0)=0 Then dbo.F_Show_Decimal(eed.E_AD_Amount,eed.cmp_id) Else dbo.F_Show_Decimal(-1,eed.cmp_id) End  AS E_AD_AMOUNT  
     
	 FROM dbo.T0110_EMP_EARN_DEDUCTION_REVISED EED WITH (NOLOCK) INNER JOIN    
      ( Select Max(For_Date) For_Date, Ad_Id,Emp_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK)  
       Where  For_date <= @to_date   
       Group by Ad_Id,Emp_id )Qry on EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id and EED.EMP_ID = Qry.EMP_ID                     
        INNER JOIN dbo.T0050_AD_MASTER ADM WITH (NOLOCK) ON EEd.AD_ID = ADM.AD_ID                       
        inner join #Emp_Cons_Allo EC on  EED.EMP_ID = EC.emp_id --AND EED.Increment_ID = EC.Increment_ID --Commented by Hardik 14/02/2017 as transfer case is getting wrong  
        inner join (  --Added by Jaina 21-09-2017 (After discuss with Nimeshbhai)  
          select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID   
          from t0095_increment TI WITH (NOLOCK) inner join  
            (   
             Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID   
             from T0095_Increment WITH (NOLOCK)  
             Where Increment_effective_Date <= @to_date and increment_type <> 'transfer' Group by emp_ID  
            ) new_inc  
            on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date  
          Where TI.Increment_effective_Date <= @to_date and increment_type <> 'transfer' group by ti.emp_id  
         )QRY_INC on QRY_INC.Increment_Id = EED.Increment_ID --and QRY_INC.Emp_ID = EED.Emp_ID  
        
     WHERE  Adm.AD_ACTIVE = 1 and EED.cmp_id = @Cmp_ID   
       And EEd.ENTRY_TYPE = 'A'  
      
    ) Qry_Final  
     
    order by EMP_ID,AD_ID asc
	
	 
   END  
  Else  
   BEGIN  
  
    INSERT INTO #Tbl_Yearly_Salary_Register  
    SELECT * FROM   
    (  
     SELECT EED.EMP_ID ,EED.AD_ID,  
      --Case When Qry1.E_AD_PERCENTAGE IS null Then eed.E_AD_PERCENTAGE Else Qry1.E_Ad_Percentage End As E_AD_Percentage,  
      --Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End As E_AD_Amount  
      Case When Qry1.Increment_ID >= EED.INCREMENT_ID /*Qry1.FOR_DATE > EED.FOR_DATE*/ Then  
       Case When Qry1.FOR_DATE IS null Then eed.FOR_DATE Else Qry1.FOR_DATE End   
       Else  
       eed.FOR_DATE End As FOR_DATE,  
      Case When Qry1.Increment_ID >= EED.INCREMENT_ID /*Qry1.FOR_DATE > EED.FOR_DATE*/ Then  
       Case When Qry1.E_AD_PERCENTAGE IS null Then eed.E_AD_PERCENTAGE Else Qry1.E_AD_PERCENTAGE End   
       Else  
       eed.E_AD_PERCENTAGE End As E_AD_PERCENTAGE,  
       CASE WHEN Qry1.Increment_ID >= EED.INCREMENT_ID THEN  
        --CASE WHEN Qry1.E_Ad_Amount IS NULL THEN dbo.F_Show_Decimal(eed.E_AD_Amount,eed.cmp_id) ELSE dbo.F_Show_Decimal(Qry1.E_Ad_Amount,E.Cmp_ID) END   
        Case When Qry1.E_Ad_Amount IS null Then   
         Case When Isnull(eed.Is_Calculate_Zero,0)=0 Then Isnull(dbo.F_Show_Decimal(eed.E_AD_Amount,eed.cmp_id),0) Else dbo.F_Show_Decimal(-1,eed.cmp_id) End   
        Else   
         Case When Isnull(Qry1.Is_Calculate_Zero,0)=0 THEN Isnull(dbo.F_Show_Decimal(Qry1.E_Ad_Amount,EED.Cmp_ID),0) Else dbo.F_Show_Decimal(-1,eed.cmp_id) End   
        End  
         
       ELSE  
       Case When Isnull(eed.Is_Calculate_Zero,0)=0 Then Isnull(dbo.F_Show_Decimal(eed.E_AD_Amount,eed.cmp_id),0) Else dbo.F_Show_Decimal(-1,eed.cmp_id) End   
       END AS E_Ad_Amount  
     FROM dbo.T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK)  
       inner join dbo.T0050_AD_MASTER ADM WITH (NOLOCK) ON EEd.AD_ID = ADM.AD_ID     
       --Comment by nilesh patel on 06102016   
       ---Uncommented by Hardik 14/02/2017 as below condition is correct  
       INNER JOIN                      
       (select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join  
       (Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)  
       Where Increment_effective_Date <= @to_date and increment_type <> 'transfer' Group by emp_ID) new_inc  
       on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date  
       Where TI.Increment_effective_Date <= @to_date and increment_type <> 'transfer' group by ti.emp_id  
        
       ) Qry_temp ON Qry_temp.Increment_Id = EED.INCREMENT_ID --and Qry_temp.Emp_ID = EED.EMP_ID   
         LEFT OUTER JOIN  
       ( Select EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE ,EEDR.Increment_ID,Is_Calculate_Zero  
        From T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN  
        ( Select Max(For_Date) For_Date, Ad_Id ,Emp_id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK)  
         Where For_date <= @to_date  
         Group by Ad_Id,Emp_id )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id and Eedr.EMP_ID = Qry.emp_id  
       ) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID and Qry1.FOR_DATE >= EED.FOR_DATE and Qry1.Increment_Id = Qry_temp.Increment_Id  --Increment condition added by Jaina 21-09-2017  --added By Jimit 04072017 as it is changed at WCL       
           
       inner join #Emp_Cons_Allo EC on  EED.EMP_ID = EC.emp_id --AND EED.Increment_ID = EC.Increment_ID -- Added by nilesh patel on 06102016 --Commented by Hardik 14/02/2017 as transfer case is getting wrong  
      WHERE  Adm.AD_ACTIVE = 1 and EED.cmp_id = @Cmp_ID   
      And Case When Qry1.ENTRY_TYPE IS null Then '' Else Qry1.ENTRY_TYPE End <> 'D'  
       
     UNION ALL  
      
     SELECT DISTINCT  
     EED.emp_id,EED.AD_ID,EED.FOR_DATE,  
     E_AD_Percentage,  
     Case When Isnull(eed.Is_Calculate_Zero,0)=0 Then dbo.F_Show_Decimal(eed.E_AD_Amount,eed.cmp_id) Else dbo.F_Show_Decimal(-1,eed.cmp_id) End  AS E_AD_AMOUNT  
     FROM dbo.T0110_EMP_EARN_DEDUCTION_REVISED EED WITH (NOLOCK) INNER JOIN    
      ( Select Max(For_Date) For_Date, Ad_Id,Emp_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK)  
       Where  For_date <= @to_date   
       Group by Ad_Id,Emp_id )Qry on EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id and EED.EMP_ID = Qry.EMP_ID                     
        INNER JOIN dbo.T0050_AD_MASTER ADM WITH (NOLOCK) ON EEd.AD_ID = ADM.AD_ID                       
        inner join #Emp_Cons_Allo EC on  EED.EMP_ID = EC.emp_id --AND EED.Increment_ID = EC.Increment_ID --Commented by Hardik 14/02/2017 as transfer case is getting wrong  
        inner join (  --Added by Jaina 21-09-2017 (After discuss with Nimeshbhai)  
          select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID   
          from t0095_increment TI WITH (NOLOCK) inner join  
            (   
             Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID   
             from T0095_Increment WITH (NOLOCK)  
             Where Increment_effective_Date <= @to_date and increment_type <> 'transfer' Group by emp_ID  
            ) new_inc  
            on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date  
          Where TI.Increment_effective_Date <= @to_date and increment_type <> 'transfer' group by ti.emp_id  
         )QRY_INC on QRY_INC.Increment_Id = EED.Increment_ID --and QRY_INC.Emp_ID = EED.Emp_ID  
        
     WHERE  Adm.AD_ACTIVE = 1 and EED.cmp_id = @Cmp_ID   
       And EEd.ENTRY_TYPE = 'A'  
      
    ) Qry_Final  
     
    order by EMP_ID,AD_ID asc  
   END  

   

 END    
ELSE  --This Condition is Added by Ramiz for Mafatlal Client (Gradewise Salary)  
   
  BEGIN  
    

	
   IF OBJECT_ID('tempdb..#Rev_Encash_Allowance') IS NULL  
   BEGIN  
     CREATE TABLE #Rev_Encash_Allowance  
      (   
       EMP_ID   NUMERIC(18, 0),  
       INCREMENT_ID NUMERIC(18, 0),  
       GRD_ID   NUMERIC(18, 0),  
       AD_ID   NUMERIC(18, 0),  
       Basic_Salary NUMERIC(18, 4) DEFAULT 0,  
       Allow_Amount NUMERIC(18, 4) DEFAULT 0 ,  
      )   
   END   
   DECLARE @EMP_ID NUMERIC  
  
   SELECT TOP 1 @EMP_ID = CAST(DATA AS NUMERIC) FROM dbo.Split(@CONSTRAINT, '#') t where data <> ''  
    
   SELECT @INCREMENT_ID = INCREMENT_ID FROM #Emp_Cons_Allo WHERE EMP_ID = @EMP_ID  
     
   --Code For Getting Amount of DA--  
   SELECT @DA_E_ad_Amount =  
     (  
      Select   
      Case When Qry1.FOR_DATE >= EED.FOR_DATE Then  
      Case When Qry1.E_Ad_Amount IS null Then eed.E_AD_Amount Else Qry1.E_Ad_Amount End   
      Else  
      eed.e_ad_Amount End As E_Ad_Amount  
    FROM dbo.T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN                      
        dbo.T0050_AD_MASTER ADM WITH (NOLOCK) ON EEd.AD_ID = ADM.AD_ID   LEFT OUTER JOIN  
      ( Select EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE   
       From T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN  
       ( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK)  
        Where Emp_Id = @EMP_ID  
        And For_date <= @To_Date  
        Group by Ad_Id )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id   
      ) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID    
    WHERE EED.EMP_ID = @EMP_ID AND increment_id = @Increment_Id And Adm.AD_ACTIVE = 1 and Adm.AD_DEF_ID = 11  
      And Case When Qry1.ENTRY_TYPE IS null Then '' Else Qry1.ENTRY_TYPE End <> 'D'  
    UNION   
      
    SELECT E_AD_Amount  
    FROM dbo.T0110_EMP_EARN_DEDUCTION_REVISED EED WITH (NOLOCK) INNER JOIN    
     ( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK)  
      Where Emp_Id  = @EMP_ID And For_date <= @To_Date   
      Group by Ad_Id )Qry on EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id                     
       INNER JOIN dbo.T0050_AD_MASTER ADM WITH (NOLOCK) ON EEd.AD_ID = ADM.AD_ID                       
    WHERE emp_id = @EMP_ID and Adm.AD_DEF_ID = 11  
      And Adm.AD_ACTIVE = 1  
      And EEd.ENTRY_TYPE = 'A')  
     
    SET @DA_Amount_0433 = @DA_E_ad_Amount * 0.433  
    SET @DA_Amount_0144 = @DA_E_ad_Amount * 0.144  
      
    SELECT @AD_ID=AD_ID FROM T0050_AD_MASTER WITH (NOLOCK) WHERE AD_DEF_ID=11  
      
    INSERT INTO #Rev_Encash_Allowance --Insert Master Grade ID  
      (EMP_ID , INCREMENT_ID, Grd_Id ,AD_ID, Basic_Salary , Allow_Amount)  
    SELECT @EMP_ID ,@INCREMENT_ID, @GRD_ID ,@AD_ID, @Grade_BasicSalary , 0  
      
                     
    UPDATE #Rev_Encash_Allowance --Calcualte DA Allowance on Day  
    SET Basic_Salary = GM.Fix_Basic_Salary,  
     Allow_Amount =   
      CASE WHEN GM.Fix_Basic_Salary >= 400 THEN  
       ((400 * @DA_Amount_0433) / 100 + (( GM.Fix_Basic_Salary - 400 ) * @DA_Amount_0144) / 100)  
      ELSE  
       ((GM.Fix_Basic_Salary * @DA_Amount_0433) / 100 )  
      END   
    FROM #Rev_Encash_Allowance DA INNER JOIN  
     T0040_GRADE_MASTER GM ON DA.Grd_Id = GM.Grd_ID  
       
       
    INSERT INTO #Rev_Encash_Allowance --Insert All Allowance which effect on Leave ( Excluding DA )  
     (EMP_ID , INCREMENT_ID, Grd_Id ,AD_ID, Basic_Salary , Allow_Amount)  
    Select @EMP_ID , @INCREMENT_ID, @GRD_ID, EED.AD_ID, @Grade_BasicSalary, 0  
    from T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK)  
      INNER JOIN #Rev_Encash_Allowance DA ON EED.INCREMENT_ID=DA.INCREMENT_ID AND DA.AD_ID=@AD_ID  
      Left Join T0050_AD_MASTER AM WITH (NOLOCK) on EEd.AD_ID = AM.AD_ID       
    where EED.INCREMENT_ID = @INCREMENT_ID and AM.AD_EFFECT_ON_LEAVE = 1 and AM.AD_DEF_ID <> 11  
      
      
     
    UPDATE D --Update the Amount of All Allowance  
    SET  Allow_Amount=ISNULL((T.AllowanceAmt * ISNULL(EED.E_AD_PERCENTAGE,0)) /100,0)  
    FROM #Rev_Encash_Allowance D   
      INNER JOIN T0100_EMP_EARN_DEDUCTION EED ON D.INCREMENT_ID=EED.INCREMENT_ID AND D.AD_ID=eed.AD_ID  
      INNER JOIN (SELECT AD.AD_NAME, (SUM(D1.Allow_Amount) + @Grade_BasicSalary) AS AllowanceAmt, EFF.EFFECT_AD_ID  
         FROM T0050_AD_MASTER AD WITH (NOLOCK)  
           INNER JOIN T0060_EFFECT_AD_MASTER EFF WITH (NOLOCK) ON EFF.AD_ID=AD.AD_ID   
           INNER JOIN #Rev_Encash_Allowance D1 ON EFF.AD_ID=D1.AD_ID  
         GROUP BY EFF.EFFECT_AD_ID,AD.AD_NAME) T ON D.AD_ID=T.EFFECT_AD_ID  
      
      
     SELECT EMP_ID , AD_ID , @TO_DATE AS FOR_DATE , 0 AS E_AD_PERCENTAGE , ALLOW_AMOUNT FROM #REV_ENCASH_ALLOWANCE --This Select Query is to Fill the Table "#Tbl_Get_AD"  
      
  
    --Create table #Tbl_Get_AD  
    --(  
    -- Emp_ID numeric(18,0),  
    -- Ad_ID numeric(18,0),  
    -- for_date datetime,  
    -- E_Ad_Percentage numeric(18,5),  
    -- E_Ad_Amount numeric(18,2)  
    --)  
  
    --INSERT INTO #Tbl_Get_AD  
    --SELECT EMP_ID , AD_ID , @TO_DATE AS FOR_DATE , 0 AS E_AD_PERCENTAGE , ALLOW_AMOUNT FROM #REV_ENCASH_ALLOWANCE  
  
    --SELECT * FROM #Tbl_Get_AD  
  END  
  
RETURN  
  
  
  
  
