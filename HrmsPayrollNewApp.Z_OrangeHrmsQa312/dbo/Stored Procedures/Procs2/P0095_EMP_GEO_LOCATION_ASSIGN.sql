

 
 ---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0095_EMP_GEO_LOCATION_ASSIGN]
	@Emp_Geo_Location_Detail_ID numeric(18,0) OUTPUT,
	@Emp_Geo_Location_ID numeric(18,0),
	@Cmp_ID numeric(18,0),
	@Emp_ID varchar(MAX),
	@Geo_Location_ID numeric(18,0),
	@Meter int,
	@Effective_Date datetime,
	@Login_ID numeric(18,0),
	@Trans_Type varchar(1)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

DECLARE @Employee_ID numeric(18,0)
--DECLARE @Emp_Geo_Location_Detail_ID numeric(18,0)

IF @Trans_Type  = 'I'
	BEGIN
		DECLARE GEOLOCATION_CURSOR  CURSOR FOR 
		SELECT Data FROM dbo.Split(@Emp_ID,'#') 
		OPEN GEOLOCATION_CURSOR  
		FETCH NEXT FROM GEOLOCATION_CURSOR INTO @Employee_ID
		WHILE @@FETCH_STATUS = 0  
			BEGIN  
				IF EXISTS (SELECT 1 FROM T0095_EMP_GEO_LOCATION_ASSIGN WITH (NOLOCK) where Emp_ID = @Employee_ID and Effective_Date = @Effective_Date)
					BEGIN
						SELECT @Emp_Geo_Location_ID = Emp_Geo_Location_ID FROM T0095_EMP_GEO_LOCATION_ASSIGN WITH (NOLOCK) where Emp_ID = @Employee_ID and Effective_Date = @Effective_Date
					END
				ELSE
					BEGIN
						SELECT @Emp_Geo_Location_ID =  ISNULL(MAX(Emp_Geo_Location_ID),0) + 1 FROM T0095_EMP_GEO_LOCATION_ASSIGN WITH (NOLOCK) 
						INSERT INTO T0095_EMP_GEO_LOCATION_ASSIGN(Emp_Geo_Location_ID,Emp_ID,Cmp_ID,Effective_Date,Login_ID,System_Date)
						VALUES(@Emp_Geo_Location_ID,@Employee_ID,@Cmp_ID,@Effective_Date,@Login_ID,GETDATE())
					END
				
				SELECT @Emp_Geo_Location_Detail_ID = ISNULL(MAX(Emp_Geo_Location_Detail_ID),0) + 1 FROM T0096_EMP_GEO_LOCATION_ASSIGN_DETAIL WITH (NOLOCK)
				
				INSERT INTO T0096_EMP_GEO_LOCATION_ASSIGN_DETAIL(Emp_Geo_Location_Detail_ID,Emp_Geo_Location_ID,Geo_Location_ID,Meter)
				VALUES(@Emp_Geo_Location_Detail_ID,@Emp_Geo_Location_ID,@Geo_Location_ID,@Meter)
				
				INSERT INTO T9999_AUDIT_TRAIL_EMP_GEO_LOCATION_ASSIGN(Emp_Geo_Location_ID,Emp_Geo_Location_Detail_ID,Emp_ID,Geo_Location_ID,
				Meter,Cmp_ID,Effective_Date,Login_ID,System_Date)
				VALUES(@Emp_Geo_Location_ID,@Emp_Geo_Location_Detail_ID,@Employee_ID,@Geo_Location_ID,@Meter,@Cmp_ID,@Effective_Date,@Login_ID,GETDATE())
				
				FETCH NEXT FROM GEOLOCATION_CURSOR INTO @Employee_ID
			END  
		CLOSE GEOLOCATION_CURSOR  
		DEALLOCATE GEOLOCATION_CURSOR 
		
	END
	
ELSE IF @Trans_Type  = 'U'
	BEGIN

		SET @Employee_ID = @Emp_ID                     --COMMENTED BY MEHUL 22-07-2022
		
		SELECT @Emp_Geo_Location_Detail_ID = ISNULL(MAX(Emp_Geo_Location_Detail_ID),0) + 1 FROM T0096_EMP_GEO_LOCATION_ASSIGN_DETAIL WITH (NOLOCK)
		
		
	INSERT INTO T0096_EMP_GEO_LOCATION_ASSIGN_DETAIL(Emp_Geo_Location_Detail_ID,Emp_Geo_Location_ID,Geo_Location_ID,Meter)
		VALUES(@Emp_Geo_Location_Detail_ID,@Emp_Geo_Location_ID,@Geo_Location_ID,@Meter)
		
		INSERT INTO T9999_AUDIT_TRAIL_EMP_GEO_LOCATION_ASSIGN(Emp_Geo_Location_ID,Emp_Geo_Location_Detail_ID,Emp_ID,Geo_Location_ID,
		Meter,Cmp_ID,Effective_Date,Login_ID,System_Date)
		VALUES(@Emp_Geo_Location_ID,@Emp_Geo_Location_Detail_ID,@Employee_ID,@Geo_Location_ID,@Meter,@Cmp_ID,@Effective_Date,@Login_ID,GETDATE())
				
				
		--IF EXISTS (SELECT 1 FROM T0096_EMP_GEO_LOCATION_ASSIGN_DETAIL WHERE Emp_Geo_Location_Detail_ID = @Emp_Geo_Location_Detail_ID AND Emp_Geo_Location_ID = @Emp_Geo_Location_ID AND Geo_Location_ID = @Geo_Location_ID)
		--BEGIN
		--	UPDATE T0096_EMP_GEO_LOCATION_ASSIGN_DETAIL 
		--		SET Geo_Location_ID = @Geo_Location_ID,Meter = @Meter
		--		WHERE Emp_Geo_Location_Detail_ID =  @Emp_Geo_Location_Detail_ID AND Emp_Geo_Location_ID = @Emp_Geo_Location_ID
		--	END
	--	ELSE
		--	BEGIN
				
		--	END

	--	declare @Emp_geo as numeric(18,0) = 0

	--Select @Emp_geo = Emp_Geo_Location_ID from T0095_EMP_GEO_LOCATION_ASSIGN where Effective_Date = @Effective_Date and Emp_ID = @emp_id and Cmp_ID = @cmp_id
	
	--	if exists (Select 1 from T0096_EMP_GEO_LOCATION_ASSIGN_DETAIL where Geo_Location_ID = @Geo_Location_ID and Emp_Geo_Location_ID = @Emp_geo)
	--	begin
	--		delete from T0096_EMP_GEO_LOCATION_ASSIGN_DETAIL where Geo_Location_ID = @Geo_Location_ID and Emp_Geo_Location_ID = @Emp_geo 
	--	end
			
	
	END
ELSE IF @Trans_Type  = 'D'
	BEGIN
		DELETE FROM T0096_EMP_GEO_LOCATION_ASSIGN_DETAIL WHERE Emp_Geo_Location_ID = @Emp_Geo_Location_ID
		DELETE FROM T0095_EMP_GEO_LOCATION_ASSIGN  WHERE Emp_Geo_Location_ID = @Emp_Geo_Location_ID
		
	
	END
	
--Emp_Geo_Location_ID, Emp_ID, Cmp_ID, Effective_Date, Login_ID, System_Date
--Emp_Geo_Location_Detail_ID, Emp_Geo_Location_ID, Geo_Location_ID, Meter
