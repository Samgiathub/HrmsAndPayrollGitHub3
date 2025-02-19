



/***************************************************************
-- =============================================
-- Author:		Mihir R Adeshara
-- ALTER date: 25/08/2011 Thursday
-- Description:	This SP is Created for Store 
				Daily basis Allowance Deduction 
				Amount Paid / Deduct in Salary of
				Particular Employee
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
****************************************************************/

CREATE PROCEDURE [dbo].[P0190_Daily_AD_Detail_Import]    
 @Cmp_ID			NUMERIC ,    
 @Emp_Code			NUMERIC ,    
 @AD_Sort_Name		VARCHAR(50),  
 @For_Date			Datetime,
 @AD_Amount			NUMERIC ,    
 @Comments			VARCHAR(100)
 
 
AS    
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
 
 DECLARE @E_AD_FLAG			 VARCHAR(20)
 DECLARE @E_AD_PERCENTAGE    NUMERIC(18,5) -- Changed by Gadriwala Muslim 19032015
 DECLARE @E_AD_CALCULATE	 VARCHAR(20)
 DECLARE @E_AD_AMOUNT		 VARCHAR(20)
 DECLARE @E_AD_MAX_LIMIT	 NUMERIC(18,2)

 DECLARE @Emp_ID		NUMERIC     
 DECLARE @Increment_ID  NUMERIC
 DECLARE @Import_Date		DATETIME     
 DECLARE @AD_ID			NUMERIC
 DECLARE @Tran_ID		NUMERIC
 DECLARE @Is_not_Exists INT    
 DECLARE @AD_AMT		NUMERIC
 
 SET @AD_AMT =0    
 SET @Is_not_Exists = 0    
 
 IF @Emp_Code = 0 OR @For_Date =0 
  RETURN
     

 SELECT @Emp_ID = Emp_ID FROM T0080_Emp_Master e WITH (NOLOCK) WHERE Cmp_ID =@Cmp_ID  and Emp_Code =@Emp_Code    
 
 If @Emp_ID= null
	Set @Emp_ID = 0
  
 SELECT @Import_Date = getdate()
 SELECT @AD_ID = AD_ID,@E_AD_FLAG =AD_FLAG FROM T0050_AD_MAster WITH (NOLOCK) WHERE cmp_ID =@Cmp_ID AND UPPER(AD_SORT_NAME) =UPPER(@AD_Sort_Name)    
     
 IF @Emp_ID = 0 OR @AD_ID = 0     
  RETURN
   
	--SELECT @Increment_ID =Increment_ID FROM T0095_Increment i INNER JOIN
	--	(SELECT MAX(Increment_effective_Date)Increment_effective_Date ,Emp_ID from T0095_Increment    
	--		WHERE Emp_ID=@Emp_ID AND Increment_effective_Date <=@Import_Date GROUP BY Emp_ID )q ON i.Emp_ID =Q.emp_ID     
	--		AND i.Increment_effective_Date = q.Increment_effective_Date    
	--WHERE I.Emp_ID =@Emp_ID      
     
 /*
 IF NOT EXISTS(SELECT Emp_ID FROM T0100_Emp_Earn_Deduction WHERE Increment_ID =@Increment_ID AND AD_ID =@AD_ID)    
  BEGIN    
	--============CHANGE BY NILAY 05/JAN/2010 ==============================================================================
     EXEC P0100_EMP_EARN_DEDUCTION 0,@Emp_ID,@Cmp_ID,@AD_ID,@Increment_ID,@Import_Date,@E_AD_FLAG,'Rs.',0,@AD_Amount,0,'I'
    --===========CHANGE BY NILAY 05/JAN/2010 ==============================================================================
  END  
 */   
 IF NOT EXISTS(SELECT Emp_ID FROM T0190_DAILY_AD_DETAIL_IMPORT WITH (NOLOCK) WHERE  AD_ID =@AD_ID and FOR_DATE = @For_Date and Emp_ID = @Emp_ID)    
 		begin
 		SELECT @Tran_ID =ISNULL(MAX(tran_ID),0) +1 FROM T0190_DAILY_AD_DETAIL_IMPORT  WITH (NOLOCK)   
	    INSERT INTO T0190_DAILY_AD_DETAIL_IMPORT    
                          (Tran_ID, Emp_ID, Cmp_ID, AD_ID, Import_Date, For_Date, Amount, Comment)    
		VALUES     (@Tran_ID, @Emp_ID, @Cmp_ID, @AD_ID, @Import_Date,@for_Date, @AD_Amount, @Comments)     
		end
  --Else
		--BEGIN
		--UPDATE T0190_DAILY_AD_DETAIL_IMPORT SET Amount = @AD_Amount WHERE Emp_ID = @Emp_ID AND AD_ID = AD_ID AND Cmp_ID = @Cmp_ID
		--END
 RETURN    



