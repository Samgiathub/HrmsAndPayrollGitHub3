
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Mobile_TravelDetails]
	@Travel_Application_ID numeric(18,0),
	@Cmp_ID numeric(18,0),
	@Emp_ID numeric(18,0)
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	SELECT * FROM T0100_TRAVEL_APPLICATION WITH (NOLOCK) WHERE Travel_Application_ID = @Travel_Application_ID
	
	SELECT Travel_App_Detail_ID,TAD.Cmp_ID,Travel_App_ID,Place_Of_Visit,Travel_Purpose,Instruct_Emp_ID,Travel_Mode_ID, 
	CONVERT(varchar(11),From_Date ,103) As 'From_Date', Period,CONVERT(varchar(11),To_Date,103) AS 'To_Date',TAD.Remarks, 
	TAD.State_ID,TAD.City_ID,SM.State_Name,CM.City_Name 
	FROM T0110_TRAVEL_APPLICATION_DETAIL TAD WITH (NOLOCK)
	LEFT JOIN T0020_STATE_MASTER SM WITH (NOLOCK) ON TAD.State_ID = SM.State_ID
	LEFT JOIN T0030_CITY_MASTER CM WITH (NOLOCK) ON TAD.City_ID = CM.City_ID
	WHERE TAD.Travel_App_ID = @Travel_Application_ID
	
	SELECT Travel_App_Other_Detail_Id,TTD.Cmp_ID,Travel_App_ID,TTD.Travel_Mode_Id,TTM.Travel_Mode_Name,
	CONVERT(varchar(11),For_date,103) as 'For_date',CONVERT(varchar(5),TTD.For_date,108) AS 'Time',Description, 
	Amount, (CASE WHEN TTD.Self_Pay = 0 THEN 'No' ELSE 'YES' END) AS 'Self_Pay'
	FROM T0110_Travel_Application_Other_Detail TTD WITH (NOLOCK)
	INNER JOIN T0030_TRAVEL_MODE_MASTER TTM	WITH (NOLOCK) ON TTD.Travel_Mode_Id = TTM.Travel_Mode_ID
	WHERE TTD.Travel_App_ID = @Travel_Application_ID
	
	SELECT * FROM T0110_TRAVEL_ADVANCE_DETAIL WITH (NOLOCK) WHERE Travel_App_ID = @Travel_Application_ID
	
	EXEC SP_Get_Travel_Application_Records @Cmp_ID,@Emp_ID,0,N'(Application_Status = ''P'' )'


END

