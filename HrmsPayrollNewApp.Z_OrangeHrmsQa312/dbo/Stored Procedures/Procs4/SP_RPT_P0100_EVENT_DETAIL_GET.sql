



---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_P0100_EVENT_DETAIL_GET]
	 @Cmp_ID numeric
	,@Emp_ID numeric
    ,@From_date datetime
    ,@to_Date datetime,
	 @Constraint	varchar(5000) = ''
AS 
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	
	Select MLD.*,Emp_full_Name,Cmp_name,Cmp_Address,Emp_code
		 From T0040_Event_Master  MLD WITH (NOLOCK) Inner join 	 
		T0080_EMP_MASTER E WITH (NOLOCK) on MLD.emp_ID = E.emp_ID INNER  JOIN		
		T0010_company_master CM WITH (NOLOCK) ON CM.Cmp_ID = @Cmp_ID 		
		WHERE E.Cmp_ID = @Cmp_Id	 and Event_Date >=@From_Date and Event_Date <=@To_Date
	
					
	RETURN 




