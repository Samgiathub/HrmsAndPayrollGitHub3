

-- =============================================
-- Author:		Nilesh patel
-- Create date: 23082018
-- Description:	For Bind Quaeterly Reimbursement 
-- =============================================
CREATE PROCEDURE [dbo].[P0060_Quarterly_Reim_Bind] 
	@Cmp_ID as Numeric,
	@AD_ID as Numeric,
	@Fin_Year as Varchar(20) = NULL
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	
	/*Select From_Date,To_Date,Fin_Year 
	From T0060_Reim_Taxable_Period QP 
	INNER JOIN(
				  Select Max(Cast(REPLACE(Fin_Year,'-','') AS numeric)) FinYear,AD_ID 
					From T0060_Reim_Taxable_Period 
				  GROUP BY AD_ID
			  ) as Qry ON Cast(REPLACE(QP.Fin_Year,'-','') AS numeric) = Qry.FinYear and Qry.AD_ID = QP.AD_ID
	Where QP.Cmp_ID = @CMP_ID and QP.AD_ID = @AD_ID */
	
    Select Is_Taxable_Quarter, Reim_Quar_ID,Quarter_Name as Q_Name,From_Date as Q_From_Date,To_Date as Q_To_Date,Claim_Upto_Date,Cast(TP.Fin_Year AS varchar(4)) as Fin_Year
	From T0060_Reim_Quarter_Period TP WITH (NOLOCK)
	INNER JOIN(
				  Select Max(Cast(REPLACE(Fin_Year,'-','') AS numeric)) FinYear,AD_ID 
				   From T0060_Reim_Quarter_Period WITH (NOLOCK)
				   Where Fin_Year = Isnull(@Fin_Year,Fin_Year)
				  GROUP BY AD_ID 
			  ) as Qry ON Cast(REPLACE(TP.Fin_Year,'-','') AS numeric) = Qry.FinYear and TP.AD_ID = Qry.AD_ID
	Where TP.Cmp_ID = @CMP_ID and TP.AD_ID = @AD_ID	
	
END

