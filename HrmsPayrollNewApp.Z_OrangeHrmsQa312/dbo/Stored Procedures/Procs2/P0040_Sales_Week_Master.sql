


-- =============================================
-- Author:		SHAIKH RAMIZ
-- Create date: 15-SEP-2016
-- Description:	This is a Week Master , Created for Sales Target 
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0040_Sales_Week_Master]  
    @Tran_ID			Numeric(9) output  
   ,@Cmp_ID				Numeric(9)  
   ,@Month				INT
   ,@Year				INT
   ,@Week_Order			Varchar(20)
   ,@Week_st_date		Datetime = null
   ,@Week_En_date		Datetime = null
   ,@Total_days_in_week TINYINT
   ,@Tran_type			Char(1)
   
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON     

DECLARE @SORTING_NO AS INTEGER
SET @SORTING_NO = CASE WHEN @WEEK_ORDER = 'MONTHLY' THEN 1 ELSE 0 END		-- FOR MONTHLY IT WILL BE "1" AND FOR WEEKS IT WILL BE "0"


If @Week_st_date = ''
	Set @Week_st_date = null
	
If @Week_En_date = ''
		Set @Week_En_date = null
	
 IF @TRAN_TYPE  = 'I'  
	  BEGIN 
	   
		 IF Exists (Select Week_Order  from dbo.T0040_Sales_Week_Master WITH (NOLOCK) Where Upper(Week_Order) = Upper(@Week_Order) and Cmp_ID = @CMP_ID and W_Month = ISNULL(@Month,0) and W_Year = ISNULL(@Year,0) AND WEEK_ORDER <> 'MONTHLY')  
			BEGIN  
				 SET @Tran_ID = 0
				 RAISERROR('@@ This Week is Already Added @@',16,2)  
				 Return  
			END 
		 ELSE IF Exists (Select 1 from T0040_Sales_Week_Master WITH (NOLOCK) where (@Week_st_date BETWEEN Week_st_date and Week_end_date) AND W_Month = ISNULL(@Month,0) and W_Year = ISNULL(@Year,0) AND @WEEK_ORDER = WEEK_ORDER)
		    BEGIN
		    	 SET @Tran_ID = 0
				 RAISERROR('@@ Week Start Date Already Added @@',16,2)  
				 Return
		    END
		 ELSE IF Exists (Select 1 from T0040_Sales_Week_Master WITH (NOLOCK) where (@Week_En_date BETWEEN Week_st_date and Week_end_date) AND W_Month = ISNULL(@Month,0) and W_Year = ISNULL(@Year,0) AND @WEEK_ORDER = WEEK_ORDER)
		    BEGIN
		    	 SET @Tran_ID = 0
				 RAISERROR('@@ Week End Date Already Added @@',16,2)  
				 Return
		    END
		 ELSE IF Exists (Select 1 from T0040_Sales_Week_Master WITH (NOLOCK) where Upper(Week_Order) = Upper(@Week_Order) and Cmp_ID = @CMP_ID and W_Month = ISNULL(@Month,0) and W_Year = ISNULL(@Year,0) AND WEEK_ORDER = 'MONTHLY')
		    BEGIN
		    	 SET @Tran_ID = 0
				 RAISERROR('@@ Monthly Record is Already Added @@',16,2)  
				 Return
		    END
		  ELSE
			BEGIN  
				INSERT INTO dbo.T0040_Sales_Week_Master(CMP_Id , W_Month , W_Year , Week_Order , Week_st_date , Week_end_date , Total_days_in_week,Sorting_No)
				VALUES (@CMP_ID , @Month , @Year , @Week_Order , @Week_st_date ,@Week_En_date ,@Total_days_in_week , @SORTING_NO)
				Select @Tran_Id = @@identity;
			END
	  END  
 ELSE IF @TRAN_TYPE = 'D'  
	  BEGIN  
		DELETE FROM dbo.T0040_Sales_Week_Master WHERE Week_Tran_ID = @Tran_ID  
	  END 
	   
 RETURN  
  


