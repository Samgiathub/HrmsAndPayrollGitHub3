



-- Created by rohit For Caption report on 01-may-2013
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_RPT_Caption]
	 @Cmp_ID		Numeric
	,@From_Date		Datetime =null
	,@To_Date		Datetime =null
	,@Branch_ID		Numeric =0
	,@Cat_ID		Numeric =0
	,@Grd_ID		Numeric =0
	,@Type_ID		Numeric =0
	,@Dept_Id		Numeric =0
	,@Desig_Id		Numeric=0
	,@Emp_ID		Numeric =0
	,@Constraint	varchar(MAX) =''
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
		SELECT * FROM T0040_CAPTION_SETTING CS	WITH (NOLOCK)					   
		where  CS.Cmp_ID = @Cmp_ID  and SortingNo > 5
			 
		ORDER BY SortingNo
         
    	RETURN 




