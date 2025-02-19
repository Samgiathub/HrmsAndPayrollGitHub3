


-- =============================================
-- Author:		Nilesh Patel
-- Create date: 11-04-2018
-- Description:	Generate SP for Sales Revenu & Kyc Data Synchronization & Also check require validation before synchronization
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Sale_Data_Synchronization]
	@Flag Numeric
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if @Flag = 1
		Begin
			Exec [OT_SalesMIS].dbo.sp_SalesMIS_Synchronize 'LastSyncDt',NULL
		End
	Else if @Flag = 2
		Begin
			Exec [OT_SalesMIS].dbo.sp_SalesMIS_Synchronize 'Validation',NULL
			Exec [OT_SalesMIS].dbo.sp_SalesMIS_Synchronize 'KnowBillStatus',NULL
		End
	Else if @Flag = 3
		Begin
			Exec [OT_SalesMIS].dbo.sp_SalesMIS_Synchronize 'TO_Brk_Synchronize',NULL
		End
	Else if @Flag = 4
		Begin
			Exec [OT_SalesMIS].dbo.sp_SalesMIS_Synchronize 'KYC_Synchronize',NULL
		End
	
END
