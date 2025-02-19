


-- =============================================
-- Author:		Nilesh Patel
-- Create date: 30-04-2019
-- Description:	User Details of Favourite Report 
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0030_FAVOURITE_REPORT_USER_WISE]
	@Report_Fav_ID  Numeric Output,
	@Cmp_ID Numeric,
	@Emp_ID Numeric,
	@Login_ID Numeric,
	@Report_NAME Varchar(200),
	@Report_Url Varchar(1000),
	@Report_Title Varchar(200),
	@Report_Group Varchar(200),
	@Tran_Type Char(1),
	@Ess_Report bit =0 -- Add flag for add ESS side user favourite Report By Mayur Modi on 16/05/2019
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	IF @Tran_Type = 'I'
		Begin
			Declare @Fav_Report_Limit tinyint = 15
			Declare @Fav_Report_Count tinyint = 0
			Select @Fav_Report_Count = Isnull(Count(1),0) From T0030_FAVOURITE_REPORT_USER_WISE WITH (NOLOCK) Where Login_ID = @Login_ID

			--Set Limit of Favourite Report
			if @Fav_Report_Count >= @Fav_Report_Limit 
				Begin
					Set @Report_Fav_ID = -1
					return @Report_Fav_ID
				End

			IF Exists(Select 1 From T0030_FAVOURITE_REPORT_USER_WISE WITH (NOLOCK) Where Login_ID = @Login_ID and Report_NAME = @Report_NAME)
				Begin
					return 0
				End
			Select @Report_Fav_ID = Isnull(Max(Report_Fav_ID),0) + 1 From T0030_FAVOURITE_REPORT_USER_WISE WITH (NOLOCK)

			Insert into 
				T0030_FAVOURITE_REPORT_USER_WISE(Report_Fav_ID,Cmp_ID,Emp_ID,Login_ID,Report_NAME,Report_Url,Report_Title,Report_Group,Ess_Report)
			Values(@Report_Fav_ID,@Cmp_ID,@Emp_ID,@Login_ID,@Report_NAME,@Report_Url,@Report_Title,@Report_Group,@Ess_Report)

		End
	Else IF @Tran_Type = 'D'
		Begin
			Delete From T0030_FAVOURITE_REPORT_USER_WISE  Where Report_NAME = @Report_NAME and Login_ID = @Login_ID 
		End
END

