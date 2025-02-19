

-- =============================================
-- Author:	Sneha 
-- Create date: 26 Dec 2013
-- Description:	
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0090_ImportResume_Immigration]
	 @cmp_id				numeric(18,0)
	,@Resume_Code			varchar(100)
	,@Loc_Name				varchar(100)
	,@Imm_Type				varchar(20)
	,@Imm_No				varchar(20)
	,@Imm_Issue_Date		datetime
	,@Imm_Issue_Status		varchar(50)
	,@Imm_Date_of_Expiry	datetime
	,@Imm_Review_Date		datetime
	,@Imm_Comments			varchar(250)			
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	declare @Resume_ID numeric(18,0)
	declare @Loc_ID numeric(18,0)
	
	If @Resume_Code <>''
		Begin
			if exists(select 1 from T0055_Resume_Master WITH (NOLOCK) where Resume_Code= @Resume_Code)
				Begin
					select @Resume_ID=Resume_Id from T0055_Resume_Master WITH (NOLOCK) where Resume_Code=@Resume_Code
					If @Loc_Name<>''
						begin
							if exists(select 1 from T0001_LOCATION_MASTER WITH (NOLOCK) where Loc_name=@Loc_Name)
								Begin
									select @Loc_ID= Loc_ID from T0001_LOCATION_MASTER WITH (NOLOCK) where Loc_name=@Loc_Name
									exec P0090_HRMS_RESUME_IMMIGRATION 0,@cmp_id,@Resume_ID,@Loc_ID,@Imm_Type,@Imm_No,@Imm_Issue_Date,@Imm_Issue_Status,@Imm_Date_of_Expiry,@Imm_Review_Date,@Imm_Comments,'I'
								End
							Else
								Begin
									Raiserror('This location donot exists',16,2)
								End
						end
					Else
						begin
							Raiserror('Enter location',16,2)
						End
				End
			Else
				Begin
					Raiserror('This resume donot exists,Please enter resume details first.',16,2)
				End
		End
	Else
		Begin
			Raiserror('Enter Resume Code',16,2)
		End
END

