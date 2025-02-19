-- =============================================
-- Author:		Divyaraj Kiri
-- Create date: 02/06/2023
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P0080_Template_FieldBank]
	   @TFB_ID	numeric(18,0) Output
      ,@Cmp_ID	numeric(18,0)
      ,@Field_Name nvarchar(100)
	  ,@Field_Type nvarchar(100)
	  ,@Options nvarchar(max)
      ,@tran_type	varchar(1)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If Upper(@tran_type) ='I'
		begin
			if Not exists (select 1 from T0080_Template_FieldBank WITH (NOLOCK) where cmp_id=@Cmp_Id and Field_Name=@Field_Name and Field_Type=@Field_Type)
				begin
					select @TFB_ID = isnull(max(TFB_ID),0) + 1 from T0080_Template_FieldBank WITH (NOLOCK)
					Insert Into T0080_Template_FieldBank
					(
						TFB_ID
						  ,Cmp_ID
						  ,Field_Name
						  ,Field_Type
						  ,Options
					)
					Values
					(
						@TFB_ID
						  ,@Cmp_ID
						  ,@Field_Name
						  ,@Field_Type
						  ,@Options
					)
				End
		End
	Else if Upper(@tran_type) ='D'
		begin
				Delete from  T0080_Template_FieldBank where TFB_ID = @TFB_ID
		End
END
