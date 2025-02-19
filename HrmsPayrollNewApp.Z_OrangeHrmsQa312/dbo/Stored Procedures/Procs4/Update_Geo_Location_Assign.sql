CREATE procedure [dbo].[Update_Geo_Location_Assign]
@cmp_id numeric(18,0)
,@emp_id numeric(18,0)
,@Effective_Date datetime
,@Emp_Geo_Location_ID numeric(18,0)
,@Geo_Location_ID numeric(18,0)

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

declare @Emp_geo as numeric(18,0) = 0

	Select @Emp_geo = Emp_Geo_Location_ID from T0095_EMP_GEO_LOCATION_ASSIGN where Effective_Date = @Effective_Date and Emp_ID = @emp_id and Cmp_ID = @cmp_id

	--if @Emp_geo <> 0
	--begin
		if exists (Select 1 from T0096_EMP_GEO_LOCATION_ASSIGN_DETAIL where Geo_Location_ID = @Geo_Location_ID and Emp_Geo_Location_ID = @Emp_geo)
		begin
			--delete from T0095_EMP_GEO_LOCATION_ASSIGN where Effective_Date = @Effective_Date and Emp_ID = @emp_id and Cmp_ID = @cmp_id 
			delete from T0096_EMP_GEO_LOCATION_ASSIGN_DETAIL where Geo_Location_ID = @Geo_Location_ID and Emp_Geo_Location_ID = @Emp_geo
		end
	--end