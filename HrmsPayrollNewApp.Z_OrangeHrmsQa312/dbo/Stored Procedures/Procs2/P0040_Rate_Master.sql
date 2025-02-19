--select * from T0050_Rate_Master
--Truncate table T0050_Rate_Master
--exec P0040_Rate_Master @Rate_ID='0',@Emp_ID=13960,@Cmp_ID=119,@Product_ID=82,@SubProduct_ID=0,@Eff_Date='2021-02-16 00:00:00',@Login_Id=7013,@Tran_Type='I'	
--exec P0040_Rate_Master 0,13961,119,1,2,'2020-01-01',1,'I'
--exec P0040_Rate_Master @Rate_ID='0',@Emp_ID=13960
--,@Cmp_ID=119,@Product_ID=0,@SubProduct_ID=18,@Eff_Date='2021-03-02 00:00:00'
--,@Login_Id=7013,@Tran_Type='I'	
--exec P0040_Rate_Master @Rate_ID='0',@RateDetail_ID=1,@Emp_ID=0,@Cmp_ID=119,@Product_ID=0,@SubProduct_ID=0,@Eff_Date='2021-03-03 15:32:13.857',@Login_Id=0,@Tran_Type='D'	
CREATE PROCEDURE [dbo].[P0040_Rate_Master]  
    @Rate_ID numeric(9) 
   ,@RateDetail_ID numeric(9) 
   ,@Emp_ID   numeric(9)  
   ,@Cmp_ID   numeric(9)  
   ,@Product_ID   numeric(9)  
   ,@SubProduct_ID   numeric(9)  
   ,@Eff_Date Datetime
   ,@Login_Id numeric(9) 
   ,@Tran_Type  varchar(1)
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

    
  Declare @Uni_ID Numeric(18,0)
  Set @Uni_ID = 0 
		   
   
 IF @TRAN_TYPE  = 'I'  
  BEGIN  		
		IF EXISTS (SELECT Rate_Id FROM dbo.T0050_Rate_Master WITH (NOLOCK) WHERE Emp_ID = @Emp_ID and Cmp_Id = @Cmp_ID and Product_ID = @Product_ID and SubProduct_ID = @SubProduct_ID and Effective_date = @Eff_Date)   
		BEGIN
			SET @Rate_ID = 0
			--print @Tran_ID
			select @Rate_ID as Rate_ID
			RETURN
		END
		
		INSERT INTO T0050_Rate_Master
			(Emp_ID,Cmp_ID,Product_ID,SubProduct_ID,Effective_date,Login_Id,System_Date)
		VALUES
			(@Emp_ID,@Cmp_ID,@Product_ID,@SubProduct_ID,@Eff_Date,@Login_Id,SYSDATETIME())	
		
		set @Rate_ID = Scope_Identity() 
		select @Rate_ID as Rate_ID
  END  
 --ELSE IF @Tran_Type = 'U'  
 -- BEGIN  
	--   SELECT @Uni_ID = Uni_ID from dbo.T0040_Uniform_Master WITH (NOLOCK) Where Upper(Uni_Name) = Upper(@Uni_Name) and Cmp_Id = @Cmp_ID
	   
	--   IF EXISTS(SELECT Tran_ID From dbo.T0050_Uniform_Master_Detail WITH (NOLOCK) Where Uni_ID = @Uni_ID AND Uni_Effective_Date =  @Uni_Eff_Date) 
	--		BEGIN
	--			UPDATE dbo.T0050_Uniform_Master_Detail  
	--			SET 
	--				Uni_Rate = @Uni_Rate,
	--				Uni_Deduct_Installment = @Uni_Ded_Installment,
	--				Uni_Refund_Installment = @Uni_Refund_Installment,
	--				Modify_By = @Modify_by,
	--				Modify_Date = SYSDATETIME(),
	--				Ip_Address = @Ip_Address
	--			WHERE Tran_ID = @Tran_ID
	--		END
	--   ELSE
	--		BEGIN
	--			SELECT @Tran_ID = Isnull(max(Tran_ID),0) + 1  FROM dbo.T0050_Uniform_Master_Detail WITH (NOLOCK)
				
	--			INSERT INTO T0050_Uniform_Master_Detail
	--				(Tran_ID,Cmp_ID,Uni_ID,Uni_Effective_Date,Uni_Rate,Uni_Deduct_Installment,Uni_Refund_Installment,Modify_By,Modify_Date,Ip_Address)
	--			VALUES
	--				(@Tran_ID,@Cmp_ID,@Uni_ID,@Uni_Eff_Date,@Uni_Rate,@Uni_Ded_Installment,@Uni_Refund_Installment,@Modify_by,SYSDATETIME(),@Ip_Address)
	--		END
 -- END  
 ELSE IF @Tran_Type = 'D'  
  BEGIN  		
	
		--DECLARE @RateID int = 0
		--Select @RateID = Rate_ID from T0051_Rate_Details WITH (NOLOCK) Where RateDetail_ID = 1
		--print @RateID
		--Select Count(1) from T0051_Rate_Details WITH (NOLOCK) Where Rate_ID = (Select Rate_ID from T0051_Rate_Details WITH (NOLOCK) Where RateDetail_ID = 1)
		IF ((Select Count(1) from T0051_Rate_Details WITH (NOLOCK) 
			Where Rate_ID = (Select Rate_ID from T0051_Rate_Details WITH (NOLOCK) 
							 Where RateDetail_ID = @RateDetail_ID)) = 1)
			BEGIN 

					DELETE FROM dbo.T0050_Rate_Master 
					Where Rate_ID = (Select Rate_ID from T0051_Rate_Details WITH (NOLOCK) 
					Where RateDetail_ID = @RateDetail_ID)

					DELETE FROM dbo.T0051_Rate_Details WHERE RateDetail_ID = @RateDetail_ID
					select 0 as Rate_ID
					RETURN
			END
			ELSE
			BEGIN 
					DELETE FROM dbo.T0051_Rate_Details WHERE RateDetail_ID = @RateDetail_ID
					select 0 as Rate_ID
					RETURN
			END
		
  END  
 RETURN
