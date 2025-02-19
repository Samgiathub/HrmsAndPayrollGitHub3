

-- =============================================
-- Author:		Nimesh Parmar
-- Create date: 08-Jul-2015
-- Description:	Get record to populate report filter dropdown
-- =============================================
CREATE PROCEDURE [dbo].[RPT_CANTEEN_DEDUCTION_FILTER] 
	@Cmp_ID Numeric(18,2)
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN

	SELECT Cast(0 As Varchar(30)) As IP_ADDRESS,'ALL' As DEVICE_IP
	UNION ALL
    SELECT IP_ADDRESS, (IP_ADDRESS + ' - ' + Device_Name) AS DEVICE_IP FROM T0040_IP_MASTER WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID AND DEVICE_NO > 199
    
    SELECT Cast(0 As Numeric(18,0)) As Cnt_ID,'ALL' As Cnt_Name
	UNION ALL
    SELECT Cnt_ID, Cnt_Name FROM T0050_CANTEEN_MASTER WITH (NOLOCK) WHERE Cmp_ID=@Cmp_ID
END

