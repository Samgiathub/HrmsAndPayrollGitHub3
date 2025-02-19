
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_ImportResume_Qualification]
	 @cmp_id			numeric(18,0)
	,@Resume_Code		varchar(100)
	,@Qualifcation 		varchar(100)
	,@Specialization	varchar(100)
	,@Year				numeric(18,0)
	,@Score				numeric(18,0)
	,@St_Date			datetime
	,@End_Date			datetime
	,@Comments			varchar(250)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

declare @Qual_id numeric(18,0)
declare @Resume_ID numeric(18,0)

	if @Resume_Code <>''
		begin
			if exists(select 1 from T0055_Resume_Master WITH (NOLOCK) where Resume_Code= @Resume_Code)
				begin
					select @Resume_ID=Resume_Id from T0055_Resume_Master WITH (NOLOCK) where Resume_Code=@Resume_Code
					If @Qualifcation<>''
						begin
							if exists(select 1 from T0040_QUALIFICATION_MASTER WITH (NOLOCK) where upper(Qual_Name)=UPPER(@Qualifcation) and Cmp_ID=@cmp_id)
								Begin
									select @Qual_id = Qual_ID from T0040_QUALIFICATION_MASTER WITH (NOLOCK) where upper(Qual_Name)=UPPER(@Qualifcation) and Cmp_ID=@cmp_id
									exec P0090_HRMS_RESUME_QUALIFICATION 0,@cmp_id,@Resume_ID,@Qual_id,@Specialization,@Year,@Score,@St_Date,@End_Date,@Comments,'','','','I'
								End
							Else
								Begin
									
									declare @p1 int
									set @p1=0
									exec P0040_Qualification_Master @Qual_ID=@p1 output,@Cmp_ID=@cmp_id,@Qual_Name=@Qualifcation,@tran_type='Inse',@User_Id=0,@IP_Address='127.0.0.1',@Qual_Type='Graduate'
									select @p1
									select @Qual_id = Qual_ID from T0040_QUALIFICATION_MASTER WITH (NOLOCK) where Qual_Name=@Qualifcation and Cmp_ID=@cmp_id
									exec P0090_HRMS_RESUME_QUALIFICATION 0,@cmp_id,@Resume_ID,@Qual_id,@Specialization,@Year,@Score,@St_Date,@End_Date,@Comments,'','','','I'
								End
						End
					Else
						Begin
							Raiserror('Enter Qualification',16,2)
						End
				End
			Else
				begin
					Raiserror('This resume donot exists,Please enter resume details first.',16,2)
				End
		End
	Else
		Begin
			Raiserror('Enter Resume Code',16,2)
		End
END

