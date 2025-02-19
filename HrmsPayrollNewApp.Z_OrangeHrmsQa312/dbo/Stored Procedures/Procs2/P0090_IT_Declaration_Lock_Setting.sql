


-- =============================================
-- Author:		<Author,,Zishanali Tailor>
-- Create date: <Create Date,,21012014>
-- Description:	<Description,,>
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0090_IT_Declaration_Lock_Setting]
	@Tran_Id as numeric(18,0) output
	,@Cmp_Id as numeric(18,0)
	,@Financial_Year varchar(50)
	,@From_Date datetime
	,@To_Date datetime
	,@Emp_Enable_Days numeric(18,0) = 0
	,@tran_type as char(1)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	IF @tran_type  = 'I'
	BEGIN

		select @Tran_Id = Isnull(max(Tran_Id),0) + 1  From dbo.T0090_IT_Declaration_Lock_Setting  WITH (NOLOCK)
		INSERT INTO T0090_IT_Declaration_Lock_Setting (Tran_Id,Cmp_Id,Financial_Year,From_Date,To_Date,Emp_Enable_Days)
		VALUES (@Tran_Id,@Cmp_Id,@Financial_Year,@From_Date,DATEADD(hour, 23, @To_Date),@Emp_Enable_Days)
	END
	ELSE IF @tran_type  = 'D'
	BEGIN
		Delete from T0090_IT_Declaration_Lock_Setting where Tran_Id = @Tran_Id AND Cmp_Id = @Cmp_Id
	END
	ELSE IF @tran_type  = 'U'
	BEGIN
		
		UPDATE T0090_IT_Declaration_Lock_Setting
		SET Financial_Year = @Financial_Year
		,From_Date = @From_Date
		,To_Date = @To_Date
		,Emp_Enable_Days = @Emp_Enable_Days
		WHERE Cmp_Id = @Cmp_Id AND Tran_Id = @Tran_Id
		
	END
	
	
END


