


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0040_EmpKPI_Master]
     @KpiAtt_Id			numeric(18,0) OUTPUT
	,@Cmp_Id			numeric(18,0)
	,@EmpKPI_Id			numeric(18,0)
	,@Emp_Id			numeric(18,0)
	,@KPI				varchar(500)
	,@Weightage			numeric(18,2)
	,@SubKPIId			numeric(18,0)
	,@tran_type			varchar(1) 
    ,@User_Id			numeric(18,0) = 0
	,@IP_Address		varchar(30)= '' 
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	 If Upper(@tran_type) ='I'
		Begin
			--IF Not exists(Select 1 from T0040_EmpKPI_Master where emp_id=@Emp_Id and Empkpi_FinYear = @Empkpi_FinYear)
			--	begin
					select @KpiAtt_Id	 = isnull(max(KpiAtt_Id	),0) + 1 from T0040_EmpKPI_Master WITH (NOLOCK)	
					Insert into T0040_EmpKPI_Master
					(
					   KpiAtt_Id	
					  ,EmpKPI_Id
					  ,Cmp_Id					 
					  ,Emp_Id
					  ,KPI
					  ,Weightage
					  ,SubKPIId
					)
					Values
					(
					   @KpiAtt_Id		
					  ,@EmpKPI_Id
					  ,@Cmp_Id					  
					  ,@Emp_Id
					  ,@KPI
					  ,@Weightage
					  ,@SubKPIId
					)
				End
		--End
	Else If Upper(@tran_type) ='U'
		Begin 	
			UPDATE    T0040_EmpKPI_Master
			Set		   KPI			= @KPI
					  ,Weightage	= @Weightage	
			Where	 KpiAtt_Id = @KpiAtt_Id
			
		End
	Else If Upper(@tran_type) ='D'
		Begin
				DELETE FROM T0040_EmpKPI_Master WHERE KpiAtt_Id = @KpiAtt_Id 	
		End
END


