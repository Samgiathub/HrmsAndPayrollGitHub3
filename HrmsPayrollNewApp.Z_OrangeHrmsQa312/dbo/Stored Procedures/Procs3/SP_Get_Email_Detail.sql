



---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Get_Email_Detail] 
 @Cmp_ID numeric
,@Emp_ID numeric
,@Branch_ID numeric
,@Type char(1)
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

--SET NOCOUNT ON 
Declare @IS_HR tinyint
Declare @IS_Accou tinyint
Declare @Email_ID varchar(60)
Declare @Email_ID_Accou varchar(60)

	if @Type = 'L'
		Begin
			select @IS_HR=isnull(IS_HR,0),@Email_ID=isnull(Email_ID,'') from t0011_login WITH (NOLOCK) where Branch_ID=@Branch_ID And Cmp_ID=@Cmp_ID
				if @IS_HR = 1 
					Begin
						select @Email_ID as Email_ID
					End
				else
					Begin
						select @IS_HR=isnull(IS_HR,0),@Email_ID=isnull(Email_ID,'') from t0011_login WITH (NOLOCK) where isnull(IS_HR,0)=1 And Cmp_ID=@Cmp_ID
							Begin
								select @Email_ID as Email_ID
							End
					End	
			End
		else if @Type = 'S'
			Begin
				Print 'Account'
			End
			
RETURN




