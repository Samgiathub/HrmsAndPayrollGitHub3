

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0055_Training_Faculty_Fill]
	 @cmp_Id			numeric(18,0)
	,@Training_pro_Id   numeric(18,0)  
	,@Training_Id		numeric(18,0)=0
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
	DECLARE @provider_type INT
	SELECT @provider_type = Provider_TypeId
	FROM T0050_HRMS_Training_Provider_master WITH (NOLOCK) WHERE Training_Pro_ID = @Training_pro_Id
	
	IF ISNULL(@provider_type,0) = 0
		BEGIN		
			SELECT Training_FacultyId as FacultyId,F.Faculty_Name
			FROM T0050_HRMS_Training_Provider_master WITH (NOLOCK) LEFT	 JOIN
				 T0055_Training_Faculty F WITH (NOLOCK) on f.Training_InstituteId = Training_InstituteId
			WHERE T0050_HRMS_Training_Provider_master.cmp_id = @cmp_Id AND Training_Pro_ID =@Training_pro_Id
			 AND f.Training_FacultyId in (select Data from dbo.split(Provider_FacultyId,'#'))
		END
	ELSE
		BEGIN		
			SELECT K.Data as FacultyId,(Alpha_Emp_Code + '- ' + E.Emp_Full_Name)	Faculty_Name		
			FROM v0050_HRMS_Training_Provider_master
			CROSS APPLY (SELECT data from dbo.Split(Provider_Emp_Id,'#')) K 
			INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) on E.Emp_ID = K.Data			
			WHERE v0050_HRMS_Training_Provider_master.cmp_id = @cmp_Id and Training_Pro_ID = @Training_pro_Id
			--AND e.Emp_ID in (select Data from dbo.split(Provider_Emp_Id,'#'))            
		END
END

