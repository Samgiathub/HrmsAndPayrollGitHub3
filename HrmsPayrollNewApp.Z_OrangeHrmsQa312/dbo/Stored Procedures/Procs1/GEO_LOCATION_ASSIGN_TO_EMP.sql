CREATE PROCEDURE [dbo].[GEO_LOCATION_ASSIGN_TO_EMP]
@Emp_Geo_Location_Detail_ID NUMERIC(18,0)
,@Emp_Geo_Location_ID NUMERIC(18,0)
,@Cmp_Id numeric(18,0)
,@Alpha_Emp_Code varchar(100)
,@Geo_Location varchar(500)
,@Effective_Date Datetime
,@Meter numeric(18,0)
,@Login_ID numeric(18,0)
,@Trans_Type varchar(1) 

AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  

declare @emp_id numeric(18,0),@geo_location_id numeric(18,0)

	if @Trans_Type = 'I'
	Begin
		Select @emp_id = Emp_id from T0080_EMP_MASTER where Cmp_ID = @Cmp_Id and Alpha_Emp_Code = @Alpha_Emp_Code
		Select @geo_location_id = Geo_Location_ID  from T0040_GEO_LOCATION_MASTER where Cmp_ID = @Cmp_Id and Geo_Location = @Geo_Location

		exec P0095_EMP_GEO_LOCATION_ASSIGN @Emp_Geo_Location_Detail_ID,@Emp_Geo_Location_ID,@Cmp_Id,@emp_id,@geo_location_id,@Meter,@Effective_Date,@Login_ID,@Trans_Type
	End
	

		