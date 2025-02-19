


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0100_EMpKPI_Master_Level]
     @Row_Id			numeric(18,0) OUTPUT
	,@Cmp_Id			numeric(18,0)
	,@Tran_Id			numeric(18,0)
	,@KPI				varchar(500)
	,@Weightage			numeric(18,2)
	,@SubKPIId			numeric(18,0)
	,@tran_type			varchar(1) 
  
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	 If Upper(@tran_type) ='I'
		Begin
			--IF Not exists(Select 1 from T0040_EmpKPI_Master where emp_id=@Emp_Id and Empkpi_FinYear = @Empkpi_FinYear)
			--	begin
					if @Tran_Id=0
					begin 
						select @Tran_Id = max(tran_id)  from T0090_EmpKPI_Approval WITH (NOLOCK)
					end
					select @Row_Id	 = isnull(max(Row_Id),0) + 1 from T0100_EMpKPI_Master_Level	WITH (NOLOCK)
					Insert into T0100_EMpKPI_Master_Level
					(
					   Row_Id	
					  ,Tran_Id
					  ,Cmp_Id
					  ,KPI
					  ,Weightage
					  ,SubKPIId
					)
					Values
					(
					   @Row_Id	
					  ,@Tran_Id
					  ,@Cmp_Id
					  ,@KPI
					  ,@Weightage
					  ,@SubKPIId
					)
				End
		--End
	Else If Upper(@tran_type) ='U'
		Begin
			UPDATE    T0100_EMpKPI_Master_Level
			Set		   KPI			= @KPI
					  ,Weightage	= @Weightage	
			Where	 Row_Id = @Row_Id
		End
	Else If Upper(@tran_type) ='D'
		Begin
				DELETE FROM T0100_EMpKPI_Master_Level WHERE  Row_Id = @Row_Id
		End
END


