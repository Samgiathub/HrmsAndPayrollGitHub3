

 ---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_PickupStation_Fare_Master]

	@Fare_ID numeric(18,0) OUTPUT,
	@Pickup_ID numeric(18,0),
	@Fare numeric(18,2),
	@Discount numeric(18,2),
	@NetFare numeric(18,2),
	@Effective_Date datetime,
	@Cmp_ID numeric(18,0),
	@Login_ID numeric(18,0),
	@Trans_Type char(1)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

IF @Trans_Type  = 'I'
	BEGIN
		IF EXISTS(SELECT Fare_ID FROM T0040_PickupStation_Fare_Master WITH (NOLOCK) WHERE Pickup_ID = @Pickup_ID AND Effective_Date = @Effective_Date )
			BEGIN  
				SET @Fare_ID = 0  
				RETURN                                                                                                                                                                        
			END
		SELECT @Fare_ID = ISNULL(MAX(Fare_ID),0)+1 FROM T0040_PickupStation_Fare_Master WITH (NOLOCK)
		
		INSERT INTO T0040_PickupStation_Fare_Master(Fare_ID,Pickup_ID,Fare,Discount,NetFare,Effective_Date,Cmp_ID,Created_By,Created_Date)
		VALUES(@Fare_ID,@Pickup_ID,@Fare,@Discount,@NetFare,@Effective_Date,@Cmp_ID,@Login_ID,GETDATE())
	END
ELSE IF @Trans_Type  = 'U'
	BEGIN
		IF EXISTS(SELECT Fare_ID FROM T0040_PickupStation_Fare_Master WITH (NOLOCK) WHERE Fare_ID <> @Fare_ID AND Pickup_ID = @Pickup_ID AND Effective_Date = @Effective_Date) 
			BEGIN  
				SET @Fare_ID = 0  
				RETURN  
			END
		UPDATE T0040_PickupStation_Fare_Master SET Pickup_ID = @Pickup_ID,Fare = @Fare,Discount = @Discount,
		NetFare = @NetFare,Effective_Date = @Effective_Date,Cmp_ID = @Cmp_ID,Modified_By = @Login_ID ,Modified_Date = GETDATE()
		WHERE Fare_ID = @Fare_ID
	END
ELSE IF @Trans_Type  = 'D'
	BEGIN
		DELETE FROM T0040_PickupStation_Fare_Master WHERE Fare_ID = @Fare_ID 
	END
