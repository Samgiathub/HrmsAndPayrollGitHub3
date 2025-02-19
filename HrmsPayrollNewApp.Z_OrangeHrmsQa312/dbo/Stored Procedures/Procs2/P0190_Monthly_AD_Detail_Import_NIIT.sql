




---ALTER By Nilay : Import the Allowace in dbo.T0050_AD_Master and dbo.T0100_Emp_Earn_Deduction
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0190_Monthly_AD_Detail_Import_NIIT]    
 @cmp_id			numeric,
 @Emp_Code			NUMERIC , 
 @AD_Sort_Name		VARCHAR(50),    
 @AD_Amount			NUMERIC ,  
 @Ad_Calculate_On	VARCHAR(50),  
 @Ad_Percentage		NUMERIC(18,5), -- Changed by Gadriwala Muslim 19032015
 @AD_flag			VARCHAR(100),
 @Increment_ID_DS	NUMERIC(18,0)=0
 --@Comments varchar(100) 
AS    
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON     
 
	 DECLARE @Emp_ID		  NUMERIC
		Set @Emp_Id=0
	 --DECLARE @Cmp_ID		  NUMERIC  
	 DECLARE @Increment_ID    NUMERIC
	 DECLARE @For_Date		  DATETIME     
	 DECLARE @AD_ID			  NUMERIC     
	 DECLARE @AD_Tran_ID	  NUMERIC    
	 DECLARE @Is_not_Exists   INT    
	 DECLARE @AD_AMT          NUMERIC
     DECLARE @Joining_Date    DATETIME
     DECLARE @AD_flage        VARCHAR(20)
     DECLARE @Ad_Mode		  VARCHAR(20)
     DECLARE @E_AD_Percentage NUMERIC(18,5) -- Changed by Gadriwala Muslim 19032015
     DECLARE @E_AD_Amount     NUMERIC(18,2)
     DECLARE @E_AD_Max_Limit  NUMERIC(18,2)
     DECLARE @E_Ad_Calculate  VARCHAR(50)
     DECLARE @Basic_Salary    NUMERIC(18,2)
     DECLARE @AD_Def_ID       NUMERIC(18,2)
     DECLARE @Emp_Full_PF     NUMERIC(18,2)
     Declare @Gross_Salary As Numeric(18,2)
     
     
     SET @AD_AMT =0    
	 SET @Is_not_Exists = 0    
	 --SET @Cmp_ID =26
	 --set @AD_Amount=

	  SELECT @Emp_ID = Emp_ID,@Joining_Date =Date_OF_Join 
	        FROM T0080_Emp_Master e WITH (NOLOCK)
	   WHERE Cmp_ID =@Cmp_ID  AND Emp_Code =@Emp_code	   
	--   Select @Joining_Date			
	If @Emp_Id=0
		Return
 

	  SELECT @AD_Def_ID =AD_Def_ID,@AD_ID = AD_ID,@E_Ad_Calculate=Ad_Calculate_On,@AD_flage=AD_Flag,@Ad_Mode=AD_MODE,@E_AD_Percentage=Ad_Percentage,@E_AD_Amount=Ad_Amount,@E_AD_Max_Limit=AD_Max_Limit 
			FROM T0050_AD_MAster WITH (NOLOCK)
	   WHERE cmp_ID =@Cmp_ID AND UPPER(AD_SORT_NAME) =UPPER(CAST(@AD_Sort_Name AS VARCHAR(4)))
 
	  SELECT @Increment_ID =I.Increment_ID,@Basic_Salary=Basic_Salary,@Emp_Full_PF=Emp_full_PF,@Gross_Salary=Gross_Salary
	        FROM T0095_Increment i WITH (NOLOCK) INNER JOIN      
	    (SELECT MAX(Increment_Id)Increment_Id ,Emp_ID FROM T0095_Increment WITH (NOLOCK)    --Changed by Hardik 10/09/2014 for Same Date Increment 
	     WHERE Emp_ID=@Emp_ID 
		    AND Increment_effective_Date <=@Joining_Date GROUP BY Emp_ID)q ON i.Emp_ID =Q.emp_ID     
			AND i.Increment_Id = q.Increment_Id    
	     WHERE I.Emp_ID =@Emp_ID   
	     
	    
   
	IF EXISTS(SELECT AD_ID,AD_Flag,AD_MODE,Ad_Percentage,Ad_Amount,AD_Max_Limit FROM T0050_AD_MAster WITH (NOLOCK) WHERE cmp_ID =@Cmp_ID AND UPPER(AD_SORT_NAME) =UPPER(CAST(@AD_Sort_Name AS VARCHAR(4))))
     BEGIN
     	IF NOT EXISTS(SELECT Emp_ID FROM T0100_Emp_Earn_Deduction WITH (NOLOCK) WHERE Increment_ID =@Increment_ID AND AD_ID =@AD_ID)    
					 BEGIN    
						SET @Is_not_Exists =1    
				     END	
				  BEGIN		
						
						IF @Ad_Calculate_On=Upper('Basic Salary')
						  BEGIN   						
							SET @AD_Amount = round(@Basic_Salary * @Ad_Percentage/100,0)	
						  END
						Else If @Ad_Calculate_On=Upper('Gross Salary')
						   Begin
							SET @AD_Amount = round(@Gross_Salary * @Ad_Percentage/100,0)	
						   End	
						ELSE IF @Ad_Calculate_On =Upper('FIX')
						  BEGIN						   
						   SET @AD_Amount = @AD_Amount
						  END 
							  
						SELECT @AD_Tran_ID =ISNULL(MAX(AD_Tran_ID),0) +1 FROM T0100_Emp_Earn_Deduction WITH (NOLOCK)       
						
						INSERT INTO T0100_EMP_EARN_DEDUCTION
											  (AD_TRAN_ID, CMP_ID, EMP_ID, AD_ID, INCREMENT_ID, FOR_DATE, E_AD_FLAG, E_AD_MODE, E_AD_PERCENTAGE, E_AD_AMOUNT, E_AD_MAX_LIMIT, 
											  E_AD_YEARLY_AMOUNT)
						VALUES     (@AD_Tran_ID,@Cmp_ID,@Emp_ID,@AD_ID,@Increment_ID,@Joining_Date,@AD_flag,@Ad_Mode,@Ad_Percentage,@AD_Amount, 0, 0)
				  END 
			END
 ELSE
   BEGIN
      
			 SELECT @AD_ID =ISNULL(MAX(AD_ID),0) +1 FROM T0050_AD_master WITH (NOLOCK)
			 
			 INSERT INTO T0050_AD_MASTER    
		          (AD_ID, CMP_ID, AD_NAME, AD_SORT_NAME, AD_LEVEL, AD_FLAG, AD_CALCULATE_ON, AD_MODE, AD_PERCENTAGE, AD_AMOUNT, AD_ACTIVE,     
                  AD_MAX_LIMIT, AD_DEF_ID,AD_NOT_EFFECT_ON_PT,AD_NOT_EFFECT_SALARY,AD_EFFECT_ON_OT,AD_EFFECT_ON_EXTRA_DAY,    
                  AD_RPT_DEF_ID,AD_IT_DEF_ID,AD_EFFECT_ON_CTC,AD_EFFECT_MONTH,LEAVE_TYPE,AD_CAL_TYPE,AD_EFFECT_FROM,Effect_Net_Salary,Ad_Effect_On_TDS)    
	      	 VALUES         
				  (@AD_ID, @CMP_ID, @AD_SORT_NAME, Cast(@AD_Sort_Name as varchar(4)), 0, @AD_flag, 'FIX', 'Rs.', 0, @AD_AMOUNT, 1,     
                  @AD_AMOUNT, 0,0,0,0,0,0,0,0,'',Null,null,null,0,0)    
                  		        
			IF NOT EXISTS(SELECT Emp_ID FROM T0100_Emp_Earn_Deduction WITH (NOLOCK) WHERE Increment_ID =@Increment_ID AND AD_ID =@AD_ID)    
				BEGIN    
						SET @Is_not_Exists =1    
				END
				BEGIN
						SELECT @AD_Tran_ID =ISNULL(MAX(AD_Tran_ID),0) +1 FROM T0100_Emp_Earn_Deduction WITH (NOLOCK)    
						
						--Gross Salary
						IF @Ad_Calculate_On=Upper('Basic Salary')
						  BEGIN
							SET @AD_Amount = round(@Basic_Salary * @Ad_Percentage/100,0)	
						  END
						Else If @Ad_Calculate_On=Upper('Gross Salary')
						   Begin
							SET @AD_Amount = round(@Gross_Salary * @Ad_Percentage/100,0)	
						   End	
						ELSE IF @Ad_Calculate_On =Upper('FIX')
						  BEGIN						   
							SET @AD_Amount = @AD_Amount
						  END 
						INSERT INTO T0100_EMP_EARN_DEDUCTION
							  (AD_TRAN_ID, CMP_ID, EMP_ID, AD_ID, INCREMENT_ID, FOR_DATE, E_AD_FLAG, E_AD_MODE, E_AD_PERCENTAGE, E_AD_AMOUNT, E_AD_MAX_LIMIT, 
							  E_AD_YEARLY_AMOUNT)
						VALUES     (@AD_Tran_ID,@Cmp_ID,@Emp_ID,@AD_ID,@Increment_ID,@Joining_Date,@AD_flag, 'Rs.',@Ad_Percentage,@AD_Amount, 0, 0)
     
				END 
		END
   
 RETURN    
    
  


