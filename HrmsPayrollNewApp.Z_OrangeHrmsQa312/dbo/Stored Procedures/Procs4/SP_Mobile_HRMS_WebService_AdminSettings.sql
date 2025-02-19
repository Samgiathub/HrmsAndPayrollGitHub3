
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_AdminSettings]
	@Cmp_Id int
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	---------------------------------- Admin Settings for Travel Approvval ---------------------------------

	select isnull(setting_value,0) as Setting_Value,Setting_Name from T0040_SETTING 
	where Cmp_ID=@Cmp_Id and Setting_Name in 
	('Enable Check out Date Option in Travel Application',
	'Enable Instruct By Employee Column in Travel Application','Enable Project in Travel',
	'Eanable Advance in Travel','Leave Selection [On Duty] Mandatory for Travel','Purpose Column Mandatory in Travel Application',
	'Enable International Travel','Enable Advance in Travel','Enable Travel Tracking in Travel Module')	

END


