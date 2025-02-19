

---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0020_STATE_MASTER_DEFAULT]
	@CMP_ID AS NUMERIC 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	DELETE FROM T0020_STATE_MASTER WHERE CMP_ID = @CMP_ID

    Declare @Loc_ID as numeric(18,2) 
	SET @Loc_ID = 1 -- Default 1 for India
	
	EXEC P0020_STATE_MASTER 0 ,@CMP_ID,'Andaman and Nicobar Islands','I',0,'','Monthly',Null,Null,@Loc_ID
	EXEC P0020_STATE_MASTER 0 ,@CMP_ID,'Andhra Pradesh','I',0,'','Monthly',Null,Null,@Loc_ID
	EXEC P0020_STATE_MASTER 0 ,@CMP_ID,'Arunachal Pradesh','I',0,'','Monthly',Null,Null,@Loc_ID
	EXEC P0020_STATE_MASTER 0 ,@CMP_ID,'Assam','I',0,'','Monthly',Null,Null,@Loc_ID
	EXEC P0020_STATE_MASTER 0 ,@CMP_ID,'Bihar','I',0,'','Monthly',Null,Null,@Loc_ID
	EXEC P0020_STATE_MASTER 0 ,@CMP_ID,'Chandigarh','I',0,'','Monthly',Null,Null,@Loc_ID
	EXEC P0020_STATE_MASTER 0 ,@CMP_ID,'Chhattisgarh','I',0,'','Monthly',Null,Null,@Loc_ID
	EXEC P0020_STATE_MASTER 0 ,@CMP_ID,'Dadra and Nagar Haveli','I',0,'','Monthly',Null,Null,@Loc_ID
	EXEC P0020_STATE_MASTER 0 ,@CMP_ID,'Daman and Diu','I',0,'','Monthly',Null,Null,@Loc_ID
	EXEC P0020_STATE_MASTER 0 ,@CMP_ID,'Delhi','I',0,'','Monthly',Null,Null,@Loc_ID		
	EXEC P0020_STATE_MASTER 0 ,@CMP_ID,'Goa','I',0,'','Monthly',Null,Null,@Loc_ID		
	EXEC P0020_STATE_MASTER 0 ,@CMP_ID,'Gujarat','I',0,'','Monthly',Null,Null,@Loc_ID		
	EXEC P0020_STATE_MASTER 0 ,@CMP_ID,'Haryana','I',0,'','Monthly',Null,Null,@Loc_ID		
	EXEC P0020_STATE_MASTER 0 ,@CMP_ID,'Himachal Pradesh','I',0,'','Monthly',Null,Null,@Loc_ID		
	EXEC P0020_STATE_MASTER 0 ,@CMP_ID,'Jammu and Kashmir','I',0,'','Monthly',Null,Null,@Loc_ID		
	EXEC P0020_STATE_MASTER 0 ,@CMP_ID,'Jharkhand','I',0,'','Monthly',Null,Null,@Loc_ID		
	EXEC P0020_STATE_MASTER 0 ,@CMP_ID,'Karnataka','I',0,'','Monthly',Null,Null,@Loc_ID		
	EXEC P0020_STATE_MASTER 0 ,@CMP_ID,'Kerala','I',0,'','Monthly',Null,Null,@Loc_ID		
	EXEC P0020_STATE_MASTER 0 ,@CMP_ID,'Lakshadweep','I',0,'','Monthly',Null,Null,@Loc_ID		
	EXEC P0020_STATE_MASTER 0 ,@CMP_ID,'Madhya Pradesh','I',0,'','Monthly',Null,Null,@Loc_ID		
	EXEC P0020_STATE_MASTER 0 ,@CMP_ID,'Maharashtra','I',0,'','Monthly',Null,Null,@Loc_ID		
	EXEC P0020_STATE_MASTER 0 ,@CMP_ID,'Manipur','I',0,'','Monthly',Null,Null,@Loc_ID		
	EXEC P0020_STATE_MASTER 0 ,@CMP_ID,'Meghalaya','I',0,'','Monthly',Null,Null,@Loc_ID		
	EXEC P0020_STATE_MASTER 0 ,@CMP_ID,'Mizoram','I',0,'','Monthly',Null,Null,@Loc_ID		
	EXEC P0020_STATE_MASTER 0 ,@CMP_ID,'Nagaland','I',0,'','Monthly',Null,Null,@Loc_ID		
	EXEC P0020_STATE_MASTER 0 ,@CMP_ID,'Orissa','I',0,'','Monthly',Null,Null,@Loc_ID		
	EXEC P0020_STATE_MASTER 0 ,@CMP_ID,'Puducherry','I',0,'','Monthly',Null,Null,@Loc_ID		
	EXEC P0020_STATE_MASTER 0 ,@CMP_ID,'Punjab','I',0,'','Monthly',Null,Null,@Loc_ID		
	EXEC P0020_STATE_MASTER 0 ,@CMP_ID,'Rajasthan','I',0,'','Monthly',Null,Null,@Loc_ID		
	EXEC P0020_STATE_MASTER 0 ,@CMP_ID,'Sikkim','I',0,'','Monthly',Null,Null,@Loc_ID		
	EXEC P0020_STATE_MASTER 0 ,@CMP_ID,'Tamil Nadu','I',0,'','Monthly',Null,Null,@Loc_ID	
	EXEC P0020_STATE_MASTER 0 ,@CMP_ID,'Telangana','I',0,'','Monthly',Null,Null,@Loc_ID
	EXEC P0020_STATE_MASTER 0 ,@CMP_ID,'Tripura','I',0,'','Monthly',Null,Null,@Loc_ID		
	EXEC P0020_STATE_MASTER 0 ,@CMP_ID,'Uttarakhand','I',0,'','Monthly',Null,Null,@Loc_ID		
	EXEC P0020_STATE_MASTER 0 ,@CMP_ID,'Uttar Pradesh','I',0,'','Monthly',Null,Null,@Loc_ID		
	EXEC P0020_STATE_MASTER 0 ,@CMP_ID,'West Bengal','I',0,'','Monthly',Null,Null,@Loc_ID		

	RETURN




