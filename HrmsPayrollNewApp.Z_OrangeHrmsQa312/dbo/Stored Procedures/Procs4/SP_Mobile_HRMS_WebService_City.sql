create PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_City]
	
	@Cmp_ID numeric(18,0),
	
	@Result VARCHAR(MAX) OUTPUT
AS
begin
		select City_Name from T0030_CITY_MASTER where Cmp_ID=@Cmp_ID
		end
