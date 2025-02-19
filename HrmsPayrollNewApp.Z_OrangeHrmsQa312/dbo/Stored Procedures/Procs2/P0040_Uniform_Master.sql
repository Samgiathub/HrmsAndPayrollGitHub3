
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_Uniform_Master]  
    --@Uniform_ID  numeric(9) output  
    @Tran_ID numeric(9) output  
   ,@Cmp_ID   numeric(9)  
   ,@Uni_Name varchar(300)
   ,@Uni_Eff_Date Datetime
   ,@Uni_Rate numeric(10,2)  
   ,@Uni_Ded_Installment numeric(10,0)  
   ,@Uni_Refund_Installment numeric(10,0)
   ,@Modify_by Varchar(200)
   ,@Ip_Address Varchar(200)
   ,@tran_type  varchar(1)
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

    
  Declare @Uni_ID Numeric(18,0)
  Set @Uni_ID = 0 
		   
   
 IF @TRAN_TYPE  = 'I'  
  BEGIN  		
	  IF EXISTS (SELECT Uni_ID FROM dbo.T0040_Uniform_Master WITH (NOLOCK) WHERE Upper(Uni_Name) = Upper(@Uni_Name) and Cmp_Id = @Cmp_ID)   
		BEGIN  
			  SELECT @Uni_ID = Uni_ID from dbo.T0040_Uniform_Master WITH (NOLOCK) Where Upper(Uni_Name) = Upper(@Uni_Name) and Cmp_Id = @Cmp_ID
		END
	  ELSE
		BEGIN
			SELECT @Uni_ID = Isnull(max(Uni_ID),0) + 1  FROM dbo.T0040_Uniform_Master WITH (NOLOCK)
			INSERT INTO dbo.T0040_Uniform_Master
				(Uni_ID,Cmp_ID,Uni_Name)  
			VALUES
				(@Uni_ID,@Cmp_ID,@Uni_Name)
		End
	
		IF EXISTS (SELECT Uni_ID FROM dbo.T0050_Uniform_Master_Detail WITH (NOLOCK) WHERE Uni_ID = @Uni_ID and Uni_Effective_Date =@Uni_Eff_Date)   
			BEGIN
				SET @Tran_ID = 0
				RETURN
			END
		
		SELECT @Tran_ID = Isnull(max(Tran_ID),0) + 1  FROM dbo.T0050_Uniform_Master_Detail WITH (NOLOCK)
		
		INSERT INTO T0050_Uniform_Master_Detail
			(Tran_ID,Cmp_ID,Uni_ID,Uni_Effective_Date,Uni_Rate,Uni_Deduct_Installment,Uni_Refund_Installment,Modify_By,Modify_Date,Ip_Address)
		VALUES
			(@Tran_ID,@Cmp_ID,@Uni_ID,@Uni_Eff_Date,@Uni_Rate,@Uni_Ded_Installment,@Uni_Refund_Installment,@Modify_by,SYSDATETIME(),@Ip_Address)	
  END  
 ELSE IF @Tran_Type = 'U'  
  BEGIN  
	   SELECT @Uni_ID = Uni_ID from dbo.T0040_Uniform_Master WITH (NOLOCK) Where Upper(Uni_Name) = Upper(@Uni_Name) and Cmp_Id = @Cmp_ID
	   
	   IF EXISTS(SELECT Tran_ID From dbo.T0050_Uniform_Master_Detail WITH (NOLOCK) Where Uni_ID = @Uni_ID AND Uni_Effective_Date =  @Uni_Eff_Date) 
			BEGIN
				UPDATE dbo.T0050_Uniform_Master_Detail  
				SET 
					Uni_Rate = @Uni_Rate,
					Uni_Deduct_Installment = @Uni_Ded_Installment,
					Uni_Refund_Installment = @Uni_Refund_Installment,
					Modify_By = @Modify_by,
					Modify_Date = SYSDATETIME(),
					Ip_Address = @Ip_Address
				WHERE Tran_ID = @Tran_ID
			END
	   ELSE
			BEGIN
				SELECT @Tran_ID = Isnull(max(Tran_ID),0) + 1  FROM dbo.T0050_Uniform_Master_Detail WITH (NOLOCK)
				
				INSERT INTO T0050_Uniform_Master_Detail
					(Tran_ID,Cmp_ID,Uni_ID,Uni_Effective_Date,Uni_Rate,Uni_Deduct_Installment,Uni_Refund_Installment,Modify_By,Modify_Date,Ip_Address)
				VALUES
					(@Tran_ID,@Cmp_ID,@Uni_ID,@Uni_Eff_Date,@Uni_Rate,@Uni_Ded_Installment,@Uni_Refund_Installment,@Modify_by,SYSDATETIME(),@Ip_Address)
			END
  END  
 ELSE IF @Tran_Type = 'D'  
  BEGIN  		
		SELECT @Uni_ID=Uni_ID from T0050_Uniform_Master_Detail WITH (NOLOCK) WHERE Tran_ID = @Tran_ID
		
		IF EXISTS(select Uni_ID from T0140_Uniform_Stock_Transaction WITH (NOLOCK) Where Uni_ID = @Uni_ID and For_Date >=@Uni_Eff_Date)
			BEGIN 
				SET @Tran_ID = 0
				RETURN
			END
		DELETE FROM dbo.T0050_Uniform_Master_Detail Where Tran_ID = @Tran_ID
		DELETE FROM dbo.T0040_Uniform_Master WHERE Uni_ID = @Uni_ID AND Cmp_Id = @Cmp_ID
  END  
 RETURN
