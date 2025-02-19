CREATE PROCEDURE [dbo].[MANUAL_INACTIVE_USER_HISTORY_MOBILE]
	@Emp_ID numeric(18,0) OUTPUT,
	@Cmp_ID numeric(18,0),
	@IsActive int,
	@Login_ID numeric(18,0)
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON
  Declare @Setting_Value int
  Set @Setting_Value = 0
  Select @Setting_Value = Isnull(Setting_Value,0) 
  from T0040_SETTING where setting_name = 'Mobile In Out Camera & Geofence Enable While Mobile Activation' and Cmp_Id = @Cmp_Id
  
  If @IsActive = 0
	  BEGIN 
	  UPDATE T0080_EMP_MASTER SET is_for_mobile_Access = @IsActive ,Is_Camera_enable =  @IsActive, Is_Geofence_Enable = @IsActive
	  WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID
	END


  If @Setting_Value = 0
		BEGIN
			UPDATE T0080_EMP_MASTER SET is_for_mobile_Access = @IsActive 
			WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID
		END
	ELSE

If @Setting_Value = 1
	BEGIN
			UPDATE T0080_EMP_MASTER SET is_for_mobile_Access = @IsActive , Is_Camera_enable = @IsActive
			WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID
	END
	ELSE

If @Setting_Value = 2
	BEGIN
			UPDATE T0080_EMP_MASTER SET is_for_mobile_Access = @IsActive , Is_Geofence_Enable = @IsActive
			WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID
	END
	ELSE

If @Setting_Value = 3
	BEGIN
			UPDATE T0080_EMP_MASTER SET is_for_mobile_Access = @IsActive ,Is_Camera_enable =  @IsActive, Is_Geofence_Enable = @IsActive
			WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID
	END	


