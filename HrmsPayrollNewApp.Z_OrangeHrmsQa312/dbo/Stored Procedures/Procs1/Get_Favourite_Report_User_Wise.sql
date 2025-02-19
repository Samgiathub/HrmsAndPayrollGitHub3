


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Get_Favourite_Report_User_Wise]
	@User_ID Numeric,
	@Flag Numeric = 0,
	@Privilege_ID Numeric = 0,
	@Ess_Report bit = 0  -- Add flag for add ESS side user favourite Report By Mayur Modi on 16/05/2019
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
    
	IF @Flag = 0 
		Begin
			Select Report_Name,Login_ID
			From T0030_FAVOURITE_REPORT_USER_WISE FR WITH (NOLOCK)
				INNER JOIN T0000_DEFAULT_FORM DF WITH (NOLOCK)
			ON FR.Report_Name = Replace(Replace(Replace(Replace(Replace(DF.Form_Name, ' ', ''),')',''),'(',''),'-',''),'/','')
			Where Login_ID = @User_ID AND Ess_Report = @Ess_Report
		End
	Else If @Flag = 1
		Begin
			if @Privilege_ID = 0
				Set @Privilege_ID = NULL
			Select Distinct FR.Report_Title,FR.Report_Url,FR.Report_Group
			From T0030_FAVOURITE_REPORT_USER_WISE FR WITH (NOLOCK)
				INNER JOIN T0000_DEFAULT_FORM DF WITH (NOLOCK) ON FR.Report_Name = Replace(Replace(Replace(Replace(Replace(DF.Form_Name, ' ', ''),')',''),'(',''),'-',''),'/','')
				INNER JOIN T0050_PRIVILEGE_DETAILS PD WITH (NOLOCK) ON DF.Form_ID = PD.Form_Id 
			Where Login_ID = @User_ID and PD.Privilage_ID = Isnull(@Privilege_ID,PD.Privilage_ID) and (PD.Is_Delete + PD.Is_Edit + PD.Is_Print + PD.Is_Save + PD.Is_View) > 0
			AND Ess_Report = @Ess_Report
		End
END

