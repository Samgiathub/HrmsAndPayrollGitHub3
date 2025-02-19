



-- =============================================
-- Author:		Nilesh Patel
-- Create date: 07-08-2018
-- Description:	Insert into Quarterly Period Table
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0060_Reim_Quarter_Period]
	@Reim_Quar_ID Numeric(18,0) Output,
	@AD_ID Numeric(18,0),
	@Cmp_ID Numeric(18,0),
	@Fin_Year Varchar(20),
	@Quarter_Name varchar(30),
	@From_Date Datetime,
	@To_Date Datetime,
	@Claim_Upto_Date Datetime,
	@Tran_Type Char(1),
	@Modify_By Numeric,
	@Ip_Address Varchar(20),
	@Is_Taxable_Quarter Bit
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON	
-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
    If @Tran_Type = 'I'
		Begin
			IF Not Exists(Select 1 From T0060_Reim_Quarter_Period WITH (NOLOCK) Where AD_ID = @AD_ID and Cmp_ID = @Cmp_ID and Fin_Year = @Fin_Year and From_Date = @From_Date and To_Date = @To_Date)
				BEGIN
				
					Select @Reim_Quar_ID = Isnull(Max(Reim_Quar_ID),0) + 1 From T0060_Reim_Quarter_Period  WITH (NOLOCK)
					
					INSERT INTO T0060_Reim_Quarter_Period(Reim_Quar_ID ,AD_ID ,Cmp_ID ,Quarter_Name ,Fin_Year ,From_Date ,To_Date ,Claim_Upto_Date,Modify_Date,Modify_By ,Ip_Address,Is_Taxable_Quarter)
												   VALUES(@Reim_Quar_ID,@AD_ID,@Cmp_ID,@Quarter_Name,@Fin_Year,@From_Date,@To_Date,@Claim_Upto_Date,GETDATE()  ,@Modify_By,@Ip_Address,@Is_Taxable_Quarter)
												   
					INSERT INTO T0060_Reim_Quarter_Period_Clone
								Select 
									(Select Isnull(Max(Tran_ID),0) + 1 From T0060_Reim_Quarter_Period_Clone WITH (NOLOCK)),
									@Reim_Quar_ID,AD_ID ,Cmp_ID ,Quarter_Name ,Fin_Year ,From_Date ,To_Date ,Claim_Upto_Date ,Modify_Date,Modify_By ,Ip_Address,Is_Taxable_Quarter 
					FROM T0060_Reim_Quarter_Period WITH (NOLOCK) WHERE Reim_Quar_ID = @Reim_Quar_ID
					
				END
			Else
				Begin
				
					Update T0060_Reim_Quarter_Period
					SET Fin_Year = @Fin_Year,
						Claim_Upto_Date = @Claim_Upto_Date,
						Modify_Date = GETDATE(),
						Modify_By = @Modify_By,
						Ip_Address = @Ip_Address,
						Is_Taxable_Quarter = @Is_Taxable_Quarter
					Where AD_ID = @AD_ID and Fin_Year = @Fin_Year and From_Date = @From_Date and To_Date = @To_Date
					
					INSERT INTO T0060_Reim_Quarter_Period_Clone
								Select 
									(Select Isnull(Max(Tran_ID),0) + 1 From T0060_Reim_Quarter_Period_Clone WITH (NOLOCK)),
									@Reim_Quar_ID,AD_ID ,Cmp_ID ,Quarter_Name ,Fin_Year ,From_Date ,To_Date ,Claim_Upto_Date ,Modify_Date,Modify_By ,Ip_Address,Is_Taxable_Quarter 
					FROM T0060_Reim_Quarter_Period WITH (NOLOCK) WHERE AD_ID = @AD_ID and Fin_Year = @Fin_Year and From_Date = @From_Date and To_Date = @To_Date
				End
		End
	Else IF @Tran_Type = 'U'
		Begin
				--Select @Reim_Quar_ID = Reim_Quar_ID From T0060_Reim_Quarter_Period WHERE AD_ID = @AD_ID
				
				IF Exists(Select 1 From T0060_Reim_Quarter_Period WITH (NOLOCK) Where AD_ID = @AD_ID and Cmp_ID = @Cmp_ID and Fin_Year = @Fin_Year and From_Date = @From_Date and To_Date = @To_Date)
					BEGIN
						Update T0060_Reim_Quarter_Period
							SET Fin_Year = @Fin_Year,
								Claim_Upto_Date = @Claim_Upto_Date,
								Modify_Date = GETDATE(),
								Modify_By = @Modify_By,
								Ip_Address = @Ip_Address,
								Is_Taxable_Quarter = @Is_Taxable_Quarter
						Where AD_ID = @AD_ID and Fin_Year = @Fin_Year and Reim_Quar_ID = @Reim_Quar_ID
				
						INSERT INTO T0060_Reim_Quarter_Period_Clone
								Select 
									(Select Isnull(Max(Tran_ID),0) + 1 From T0060_Reim_Quarter_Period_Clone WITH (NOLOCK)),
									 @Reim_Quar_ID,AD_ID,Cmp_ID,Quarter_Name,Fin_Year,From_Date,To_Date,Claim_Upto_Date,Modify_Date,Modify_By,Ip_Address,Is_Taxable_Quarter 
						FROM T0060_Reim_Quarter_Period WITH (NOLOCK) WHERE Reim_Quar_ID = @Reim_Quar_ID and AD_ID = @AD_ID
					END
				ELSE
					BEGIN
						Select @Reim_Quar_ID = Isnull(Max(Reim_Quar_ID),0) + 1 From T0060_Reim_Quarter_Period WITH (NOLOCK)
					
						INSERT INTO T0060_Reim_Quarter_Period(Reim_Quar_ID ,AD_ID ,Cmp_ID ,Quarter_Name ,Fin_Year ,From_Date ,To_Date ,Claim_Upto_Date ,Modify_Date,Modify_By ,Ip_Address,Is_Taxable_Quarter)
													   VALUES(@Reim_Quar_ID,@AD_ID,@Cmp_ID,@Quarter_Name,@Fin_Year,@From_Date,@To_Date,@Claim_Upto_Date,GETDATE()  ,@Modify_By,@Ip_Address,@Is_Taxable_Quarter)
													   
						INSERT INTO T0060_Reim_Quarter_Period_Clone
									Select 
										(Select Isnull(Max(Tran_ID),0) + 1 From T0060_Reim_Quarter_Period_Clone WITH (NOLOCK)),
										@Reim_Quar_ID,AD_ID ,Cmp_ID ,Quarter_Name ,Fin_Year ,From_Date ,To_Date ,Claim_Upto_Date ,Modify_Date,Modify_By ,Ip_Address,Is_Taxable_Quarter 
						FROM T0060_Reim_Quarter_Period WITH (NOLOCK) WHERE Reim_Quar_ID = @Reim_Quar_ID
					END
		End
END

