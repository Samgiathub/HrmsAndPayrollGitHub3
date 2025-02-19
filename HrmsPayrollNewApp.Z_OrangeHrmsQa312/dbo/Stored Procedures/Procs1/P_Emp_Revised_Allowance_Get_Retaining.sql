---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE  PROCEDURE [dbo].[P_Emp_Revised_Allowance_Get_Retaining]    
  @Cmp_ID numeric,    
  @To_Date Datetime = '',  
  @curemp_id NUMERIC(18 ,0)=0,
  @Constraint varchar(max) = '',  
  @GRD_ID   NUMERIC   = 0,  
  @Grade_BasicSalary NUMERIC(18 ,0) = 0  
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
if @To_Date = ''  
 --set @To_Date = Getdate()  
  
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
  --IF OBJECT_ID ('tempdb..#Tbl_Yearly_Salary_Register') IS NULL  
  -- BEGIN  
   
   IF ((select count(1) from Temp_other_Allowance)> 0)
   Begin 
		truncate table Temp_other_Allowance
		--select * from Temp_other_Allowance
   END
  
   insert into Temp_other_Allowance
   SELECT * FROM   
   (  
	 SELECT EED.EMP_ID ,EED.AD_ID,
      Case When Qry1.Increment_ID >= EED.INCREMENT_ID /*Qry1.FOR_DATE > EED.FOR_DATE*/ Then  
       Case When Qry1.FOR_DATE IS null Then eed.FOR_DATE Else Qry1.FOR_DATE End   
       Else  
       eed.FOR_DATE End As FOR_DATE,  
      Case When Qry1.Increment_ID >= EED.INCREMENT_ID /*Qry1.FOR_DATE > EED.FOR_DATE*/ Then  
       Case When Qry1.E_AD_PERCENTAGE IS null Then eed.E_AD_PERCENTAGE Else Qry1.E_AD_PERCENTAGE End   
       Else  
       eed.E_AD_PERCENTAGE End As E_AD_PERCENTAGE,  
       CASE WHEN Qry1.Increment_ID >= EED.INCREMENT_ID THEN  
        Case When Qry1.E_Ad_Amount IS null Then   
         Case When Isnull(eed.Is_Calculate_Zero,0)=0 Then Isnull(dbo.F_Show_Decimal(eed.E_AD_Amount,eed.cmp_id),0) Else dbo.F_Show_Decimal(-1,eed.cmp_id) End   
        Else   
         Case When Isnull(Qry1.Is_Calculate_Zero,0)=0 THEN Isnull(dbo.F_Show_Decimal(Qry1.E_Ad_Amount,EED.Cmp_ID),0) Else dbo.F_Show_Decimal(-1,eed.cmp_id) End   
        End  
         
       ELSE  
       Case When Isnull(eed.Is_Calculate_Zero,0)=0 Then Isnull(dbo.F_Show_Decimal(eed.E_AD_Amount,eed.cmp_id),0) Else dbo.F_Show_Decimal(-1,eed.cmp_id) End   
       END AS E_Ad_Amount  
	   ,Qry_temp.Basic_salary
     FROM dbo.T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK)  
       inner join dbo.T0050_AD_MASTER ADM WITH (NOLOCK) ON EEd.AD_ID = ADM.AD_ID     
       INNER JOIN                      
       (
		select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID,Basic_Salary from t0095_increment TI WITH (NOLOCK) inner join  
		(
			Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)  
			Where Increment_effective_Date <= @to_date and increment_type <> 'transfer' Group by emp_ID) new_inc  
			on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date  
				Where TI.Increment_effective_Date <= @to_date and increment_type <> 'transfer' group by ti.emp_id,Basic_Salary 
       ) Qry_temp ON Qry_temp.Increment_Id = EED.INCREMENT_ID --and Qry_temp.Emp_ID = EED.EMP_ID   
		
		LEFT OUTER JOIN  
       (
		Select EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE ,EEDR.Increment_ID,Is_Calculate_Zero  
        From T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN  
        ( Select Max(For_Date) For_Date, Ad_Id ,Emp_id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK)   
         Where For_date <= @to_date  
         Group by Ad_Id,Emp_id 
		 )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id and Eedr.EMP_ID = Qry.emp_id  
       ) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID and Qry1.FOR_DATE >= EED.FOR_DATE and Qry1.Increment_Id = Qry_temp.Increment_Id  --Increment condition added by Jaina 21-09-2017  --added By Jimit 04072017 as it is changed at WCL       
       inner join #Emp_Cons_Allo EC on  EED.EMP_ID = EC.emp_id 
      WHERE  Adm.AD_ACTIVE = 1 and EED.cmp_id = @Cmp_ID   
      And Case When Qry1.ENTRY_TYPE IS null Then '' Else Qry1.ENTRY_TYPE End <> 'D' 
	  and EED.Emp_ID = @curemp_id

	  ) Qry_Final  
     
    order by EMP_ID,AD_ID asc  

 
  
 END  
  
RETURN  
  
  
  
  