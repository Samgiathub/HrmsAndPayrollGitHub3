



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0052_BSC_AlertSetting]
	   @BSC_Alert_Id	numeric(18,0) OUTPUT
      ,@Cmp_Id			numeric(18,0)
      ,@BSC_AlertType	int
      ,@BSC_AlertDay	numeric(18,0)
      ,@BSC_Month		int
      ,@BSC_AlertNodays numeric(18,0)
      ,@BSC_Date		datetime
      ,@BSC_ReviewType	int
      ,@tran_type		varchar(1) 
      ,@User_Id			numeric(18,0) = 0
	  ,@IP_Address		varchar(30)= '' 

AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If UPPER(@tran_type) ='I'
		BEGIN
			select @BSC_Alert_Id = isnull(max(BSC_Alert_Id),0) + 1 from T0052_BSC_AlertSetting WITH (NOLOCK)
			Insert Into T0052_BSC_AlertSetting
			(
				   BSC_Alert_Id
				  ,Cmp_Id
				  ,BSC_AlertType
				  ,BSC_AlertDay
				  ,BSC_Month
				  ,BSC_AlertNodays
				  ,BSC_Date
				  ,BSC_ReviewType
			)
			VALUES(
				  @BSC_Alert_Id
				  ,@Cmp_Id
				  ,@BSC_AlertType
				  ,@BSC_AlertDay
				  ,@BSC_Month
				  ,@BSC_AlertNodays
				  ,@BSC_Date
				  ,@BSC_ReviewType
			)
		END
	Else If  Upper(@tran_type) ='U' 
		BEGIN
			UPDATE    T0052_BSC_AlertSetting
			SET		  BSC_AlertType		=	@BSC_AlertType
					  ,BSC_AlertDay		=	@BSC_AlertDay
					  ,BSC_Month		=   @BSC_Month
					  ,BSC_AlertNodays	=	@BSC_AlertNodays
					  ,BSC_Date			=	@BSC_Date
					  ,BSC_ReviewType   =	@BSC_ReviewType
			WHERE	 BSC_Alert_Id=@BSC_Alert_Id and cmp_Id=@Cmp_ID
		END
	Else If  Upper(@tran_type) ='D'
		BEGIN
			DELETE FROM T0052_BSC_AlertSetting WHERE BSC_Alert_Id = @BSC_Alert_Id and  cmp_Id=@Cmp_ID and BSC_AlertType=@BSC_AlertType
		END
END


