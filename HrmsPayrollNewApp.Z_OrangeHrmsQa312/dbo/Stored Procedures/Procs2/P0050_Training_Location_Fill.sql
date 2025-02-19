

---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0050_Training_Location_Fill]
	 @cmp_Id			numeric(18,0)
	,@Training_pro_Id   numeric(18,0)  
	,@Training_Id		numeric(18,0)=0
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	DECLARE @provider_type INT
	SELECT @provider_type = Provider_TypeId
	FROM T0050_HRMS_Training_Provider_master WITH (NOLOCK) WHERE Training_Pro_ID = @Training_pro_Id
	
	IF ISNULL(@provider_type,0) = 0
		BEGIN
			SELECT f.Training_Institute_LocId AS Training_Institute_LocId,F.Institute_LocationCode
			FROM T0050_HRMS_Training_Provider_master WITH (NOLOCK) LEFT	 JOIN
				 T0050_Training_Location_Master F WITH (NOLOCK) ON F.Training_InstituteId = Training_InstituteId
			WHERE T0050_HRMS_Training_Provider_master.cmp_id = @cmp_Id AND Training_Pro_ID =@Training_pro_Id
			 AND f.Training_Institute_LocId = T0050_HRMS_Training_Provider_master.Training_Institute_LocId
			
		END
	ELSE
		BEGIN
			SELECT Training_Institute_LocId ,Institute_LocationCode 
			FROM v0050_HRMS_Training_Provider_master
			WHERE cmp_id = @cmp_Id and Training_Pro_ID = @Training_pro_Id
		END
END

