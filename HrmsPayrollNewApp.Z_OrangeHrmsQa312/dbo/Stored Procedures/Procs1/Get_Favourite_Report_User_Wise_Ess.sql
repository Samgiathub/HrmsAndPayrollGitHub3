

/*
Date - 16/05/2019
Name - Mayur Modi
Desc - Get list of favourite Report Ess side
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
*/
CREATE PROCEDURE [dbo].[Get_Favourite_Report_User_Wise_Ess]
	@User_ID Numeric,
	@Ess_Report bit = 1,  -- Add flag for add ESS side user favourite Report By Mayur Modi on 16/05/2019
	@Privilege_Id Numeric	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
    
Select DISTINCT  DF.Form_ID, Report_Name,Login_ID,FR.Report_Url,Report_Title,DF.Under_Form_ID
			From T0030_FAVOURITE_REPORT_USER_WISE FR WITH (NOLOCK)
				INNER JOIN T0000_DEFAULT_FORM DF  WITH (NOLOCK) ON FR.Report_Name = DF.Form_Name
				Left JOIN T0050_PRIVILEGE_DETAILS PD WITH (NOLOCK) ON DF.Form_ID = PD.Form_Id 	
				Left JOIN T0020_PRIVILEGE_MASTER PM  WITH (NOLOCK) on PM.Privilege_ID = PD.Privilage_ID 			
			
			Where Login_ID = @User_ID AND Ess_Report = 1 and (Is_View= 1 or is_edit= 1 or is_save= 1 or is_delete = 1)  and PM.Privilege_ID= @Privilege_Id
END

