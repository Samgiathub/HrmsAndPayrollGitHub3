

---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0050_Training_Location_Master]
	   @Training_Institute_LocId	numeric(18,0)
      ,@Cmp_Id						numeric(18,0)
      ,@Training_InstituteId		numeric(18,0)
      ,@Institute_LocationCode		varchar(50)
      ,@Institute_LocationDesc		varchar(200)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	IF @Training_Institute_LocId = 0
		BEGIN
			SELECT @Training_Institute_LocId = ISNULL(MAX(Training_Institute_LocId),0) + 1 FROM T0050_Training_Location_Master WITH (NOLOCK)
			INSERT INTO T0050_Training_Location_Master
			(
				Training_Institute_LocId
				,Cmp_Id
				,Training_InstituteId
				,Institute_LocationCode
				,Institute_LocationDesc
			)
			VALUES
			(
				@Training_Institute_LocId
				,@Cmp_Id
				,@Training_InstituteId
				,@Institute_LocationCode
				,@Institute_LocationDesc
			)
		END
	ELSE
		BEGIN
			UPDATE T0050_Training_Location_Master
			SET  Institute_LocationCode		=   @Institute_LocationCode
			    ,Institute_LocationDesc		=	@Institute_LocationDesc
			    ,Training_InstituteId		=	@Training_InstituteId
			WHERE Training_Institute_LocId	=  @Training_Institute_LocId
		END
END

