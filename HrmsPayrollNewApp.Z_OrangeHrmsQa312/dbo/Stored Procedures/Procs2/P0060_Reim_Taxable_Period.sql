

-- =============================================
-- Author:		Nilesh Patel
-- Create date: 07-08-2018
-- Description:	Insert into Tax Period Table
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0060_Reim_Taxable_Period]
	@Reim_Tax_ID Numeric(18,0) Output,
	@AD_ID Numeric(18,0),
	@Cmp_ID Numeric(18,0),
	@Fin_Year Varchar(20),
	@From_Date Datetime,
	@To_Date Datetime,
	@Tran_Type Char(1),
	@Modify_By Numeric,
	@Ip_Address Varchar(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

    If @Tran_Type = 'I'
		Begin
			IF Not Exists(Select 1 From T0060_Reim_Taxable_Period WITH (NOLOCK) Where AD_ID = @AD_ID and Cmp_ID = @Cmp_ID and Fin_Year = @Fin_Year)
				BEGIN
					Select @Reim_Tax_ID = Isnull(Max(Reim_Tax_ID),0) + 1 From T0060_Reim_Taxable_Period WITH (NOLOCK)
					
					INSERT INTO T0060_Reim_Taxable_Period(Reim_Tax_ID,AD_ID,Cmp_ID,Fin_Year,From_Date,To_Date,Modify_Date,Modify_By,Ip_Address)
												   VALUES(@Reim_Tax_ID,@AD_ID,@Cmp_ID,@Fin_Year,@From_Date,@To_Date,GETDATE(),@Modify_By,@Ip_Address)
					
					INSERT INTO T0060_Reim_Taxable_Period_Clone
								Select 
									(Select Isnull(Max(Tran_ID),0)  + 1 From T0060_Reim_Taxable_Period_Clone WITH (NOLOCK)),
									@Reim_Tax_ID,AD_ID,Cmp_ID,Fin_Year,From_Date,To_Date,Modify_Date,Modify_By,Ip_Address 
					FROM T0060_Reim_Taxable_Period WHERE Reim_Tax_ID = @Reim_Tax_ID
				END
			Else
				BEGIN
					Update T0060_Reim_Taxable_Period
					SET Fin_Year = @Fin_Year,
						From_Date = @From_Date,
						To_Date = @To_Date,
						Modify_Date = GETDATE(),
						Modify_By = @Modify_By,
						Ip_Address = @Ip_Address
					Where AD_ID = @AD_ID and Fin_Year = @Fin_Year
					
					INSERT INTO T0060_Reim_Taxable_Period_Clone
					Select 
						(Select Isnull(Max(Tran_ID),0)  + 1 From T0060_Reim_Taxable_Period_Clone WITH (NOLOCK)),
						@Reim_Tax_ID,AD_ID,Cmp_ID,Fin_Year,From_Date,To_Date,Modify_Date,Modify_By,Ip_Address 
						FROM T0060_Reim_Taxable_Period WITH (NOLOCK)
					Where AD_ID = @AD_ID and Fin_Year = @Fin_Year
				END
		End
	Else IF @Tran_Type = 'U'
		Begin
				IF Exists(Select 1 From T0060_Reim_Taxable_Period WITH (NOLOCK) Where AD_ID = @AD_ID and Cmp_ID = @Cmp_ID and Fin_Year = @Fin_Year)
					BEGIN
						SELECT @Reim_Tax_ID = Reim_Tax_ID FROM T0060_Reim_Taxable_Period WITH (NOLOCK) WHERE AD_ID = @AD_ID AND Cmp_ID = @CMP_ID
				
						Update T0060_Reim_Taxable_Period
							SET Fin_Year = @Fin_Year,
								From_Date = @From_Date,
								To_Date = @To_Date,
								Modify_Date = GETDATE(),
								Modify_By = @Modify_By,
								Ip_Address = @Ip_Address
						Where AD_ID = @AD_ID and Fin_Year = @Fin_Year and Reim_Tax_ID = @Reim_Tax_ID
						
						INSERT INTO T0060_Reim_Taxable_Period_Clone
								Select 
									(Select Isnull(Max(Tran_ID),0)  + 1 From T0060_Reim_Taxable_Period_Clone WITH (NOLOCK)),
									 @Reim_Tax_ID,AD_ID,Cmp_ID,Fin_Year,From_Date,To_Date,Modify_Date,Modify_By,Ip_Address 
						FROM T0060_Reim_Taxable_Period WHERE Reim_Tax_ID = @Reim_Tax_ID
					END
				ELSE
					BEGIN
						Select @Reim_Tax_ID = Isnull(Max(Reim_Tax_ID),0) + 1 From T0060_Reim_Taxable_Period WITH (NOLOCK)
					
						INSERT INTO T0060_Reim_Taxable_Period(Reim_Tax_ID,AD_ID,Cmp_ID,Fin_Year,From_Date,To_Date,Modify_Date,Modify_By,Ip_Address)
													   VALUES(@Reim_Tax_ID,@AD_ID,@Cmp_ID,@Fin_Year,@From_Date,@To_Date,GETDATE(),@Modify_By,@Ip_Address)
						
						INSERT INTO T0060_Reim_Taxable_Period_Clone
									Select 
										(Select Isnull(Max(Tran_ID),0)  + 1 From T0060_Reim_Taxable_Period_Clone WITH (NOLOCK)),
										@Reim_Tax_ID,AD_ID,Cmp_ID,Fin_Year,From_Date,To_Date,Modify_Date,Modify_By,Ip_Address 
						FROM T0060_Reim_Taxable_Period WHERE Reim_Tax_ID = @Reim_Tax_ID
					END
				
		End
END

