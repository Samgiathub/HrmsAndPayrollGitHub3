--select * from T0051_Rate_Details
--Truncate table T0051_Rate_Details
--exec P0040_Rate_Master 0,13961,119,1,2,'2020-01-01',1,'I'
CREATE PROCEDURE [dbo].[P0040_Rate_Details] 
	@Rate_ID_Details numeric(9)  Output
   ,@Rate_ID numeric(9) 
   ,@Rate   numeric(9)  
   ,@From_Limit   numeric(9)  
   ,@To_Limit   numeric(9)  
   --,@Eff_Date Datetime
   --,@Login_Id numeric(9) 
   ,@Tran_Type  varchar(1)
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

 IF @TRAN_TYPE  = 'I'  
  BEGIN  		
		--IF EXISTS (SELECT Rate_Id FROM dbo.T0051_Rate_Details WITH (NOLOCK) WHERE Emp_ID = @Emp_ID and Cmp_Id = @Cmp_ID and Product_ID = @Product_ID and SubProduct_ID = @SubProduct_ID)   
		--BEGIN
		--	SET @Rate_ID = 0
		--	--print @Tran_ID
		--	RETURN
		--END
		
		INSERT INTO T0051_Rate_Details
			(Rate_ID,Rate,From_Limit,To_Limit)
		VALUES
			(@Rate_ID,@Rate,@From_Limit,@To_Limit)	
		
		--set @Rate_ID = Scope_Identity() 
		--select @Rate_ID as Rate_ID
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
 --ELSE IF @Tran_Type = 'D'  
 -- BEGIN  		
	--	SELECT @Uni_ID=Uni_ID from T0050_Uniform_Master_Detail WITH (NOLOCK) WHERE Tran_ID = @Tran_ID
		
	--	IF EXISTS(select Uni_ID from T0140_Uniform_Stock_Transaction WITH (NOLOCK) Where Uni_ID = @Uni_ID and For_Date >=@Uni_Eff_Date)
	--		BEGIN 
	--			SET @Tran_ID = 0
	--			RETURN
	--		END
	--	DELETE FROM dbo.T0050_Uniform_Master_Detail Where Tran_ID = @Tran_ID
	--	DELETE FROM dbo.T0040_Uniform_Master WHERE Uni_ID = @Uni_ID AND Cmp_Id = @Cmp_ID
 -- END  
 RETURN
