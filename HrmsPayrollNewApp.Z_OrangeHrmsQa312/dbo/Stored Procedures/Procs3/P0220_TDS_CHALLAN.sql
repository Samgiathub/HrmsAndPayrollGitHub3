


---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[P0220_TDS_CHALLAN]
@Challan_Id	numeric(18, 0) output
,@cmp_id	numeric(18, 0)	
,@Month	numeric(18, 0)	
,@Year	numeric(18, 0)	
,@Payment_Date	datetime	
,@Bank_ID	numeric(18, 0)	
,@Bank_Name	varchar(100)
,@Bank_BSR_Code	varchar(50)
,@Paid_By	varchar(50)	
,@Cheque_No	varchar(50)	
,@CIN_No	varchar(50)	
,@Cheque_Date	datetime	
,@Tax_Amount	numeric(18, 2)
,@ED_Cess	numeric(18, 2)	
,@Interest_Amount	numeric(18, 2)
,@Penalty_Amount	numeric(18, 2)	
,@Other_Amount	numeric(18, 2)	
,@Total_Amount	numeric(18, 2)
,@Tran_Type varchar(1) = 'I'
,@User_Id numeric(18,0) = 0		-- Added for audit trail By Ali 21102013
,@IP_Address varchar(30)= ''	-- Added for audit trail By Ali 21102013
,@Challan_Type int = 0 --Added by Jaina 15-02-2019


AS



								-- Added for audit trail By Ali 21102013 -- Start
									Declare @OldValue as varchar(max)
									Declare @Old_Month as numeric(18, 0)	
									Declare @Old_Year as numeric(18, 0)	
									Declare @Old_Payment_Date as datetime	
									Declare @Old_Bank_ID as numeric(18, 0)	
									Declare @Old_Bank_Name as varchar(100)
									Declare @Old_Bank_BSR_Code as varchar(50)
									Declare @Old_Paid_By as varchar(50)	
									Declare @Old_Cheque_No as varchar(50)	
									Declare @Old_CIN_No as varchar(50)	
									Declare @Old_Cheque_Date as datetime	
									Declare @Old_Tax_Amount as numeric(18, 2)
									Declare @Old_ED_Cess as numeric(18, 2)	
									Declare @Old_Interest_Amount as numeric(18, 2)
									Declare @Old_Penalty_Amount as numeric(18, 2)	
									Declare @Old_Other_Amount as numeric(18, 2)	
									Declare @Old_Total_Amount as numeric(18, 2)
									Declare @Old_Challan_type as int
									
									
									Set @OldValue = ''
									Set @Old_Month = 0
									Set @Old_Year = 0
									Set @Old_Payment_Date = null
									Set @Old_Bank_ID = 0	
									Set @Old_Bank_Name = ''
									Set @Old_Bank_BSR_Code = ''
									Set @Old_Paid_By = ''
									Set @Old_Cheque_No = ''
									Set @Old_CIN_No = ''
									Set @Old_Cheque_Date = null	
									Set @Old_Tax_Amount = 0
									Set @Old_ED_Cess = 0
									Set @Old_Interest_Amount = 0
									Set @Old_Penalty_Amount = 0	
									Set @Old_Other_Amount = 0	
									Set @Old_Total_Amount = 0
									set @Old_Challan_type = 0
									
									
								-- Added for audit trail By Ali 21102013 -- End
								
			SET NOCOUNT ON 
			SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			SET ARITHABORT ON					
	
	 
	IF @TRAN_TYPE = 'I'
		BEGIN
		
			SELECT @CHALLAN_ID = isnull(MAX(CHALLAN_ID),0) + 1 FROM T0220_TDS_CHALLAN WITH (NOLOCK)
			
			INSERT INTO T0220_TDS_CHALLAN
					(Challan_Id, cmp_id, Month, Year, Payment_Date, Bank_ID, Bank_Name, Bank_BSR_Code, Paid_By, Cheque_No, CIN_No, Cheque_Date, Tax_Amount, ED_Cess, 
							  Interest_Amount, Penalty_Amount, Other_Amount, Total_Amount,Challan_type)
			VALUES  (@Challan_Id,@cmp_id,@Month,@Year,@Payment_Date,@Bank_ID,@Bank_Name,@Bank_BSR_Code,@Paid_By,@Cheque_No,@CIN_No,@Cheque_Date,@Tax_Amount,@ED_Cess,@Interest_Amount,@Penalty_Amount,@Other_Amount,@Total_Amount,@Challan_type)
			
								-- Added for audit trail By Ali 19102013 -- Start
									set @OldValue = 'New Value' 
										+ '#' + 'Due for the Month : ' + CONVERT(nvarchar(100),ISNULL(@Month,0))
										+ '#' + 'Due for the Year : ' + CONVERT(nvarchar(100),ISNULL(@Year,0))										
										+ '#' + 'Name of the Bank : ' + ISNULL(@Bank_Name,'')
										+ '#' + 'Paid By : ' + ISNULL(@Paid_By,'')
										+ '#' + 'Date Of Payment : ' + cast(ISNULL(@Payment_Date,'') as nvarchar(11))
										+ '#' + 'Cheque No : ' + ISNULL(@Cheque_No,'')
										+ '#' + 'Cheque Date : ' + cast(ISNULL(@Cheque_Date,'') as nvarchar(11))
										+ '#' + 'Bank BSR Codey : ' + ISNULL(@Bank_BSR_Code,'')
										+ '#' + 'Challan Sr. No 	 : ' + ISNULL(@CIN_No,'')
										+ '#' + 'Income Tax Amount : ' + CONVERT(nvarchar(100),ISNULL(@Tax_Amount,0))
										+ '#' + 'ED Cess Amount 	 : ' + CONVERT(nvarchar(100),ISNULL(@ED_Cess,0))
										+ '#' + 'Interest Amount : ' + CONVERT(nvarchar(100),ISNULL(@Interest_Amount,0))
										+ '#' + 'Penalty Amount : ' + CONVERT(nvarchar(100),ISNULL(@Penalty_Amount,0))
										+ '#' + 'Other Amount : ' + CONVERT(nvarchar(100),ISNULL(@Other_Amount,0))
										+ '#' + 'Total Amount : ' + CONVERT(nvarchar(100),ISNULL(@Total_Amount,0))										
										+ '#' + 'Challan Type : ' + CASE WHEN @Challan_type = 1 THEN 'Multiple' ELSE 'Single' END
																																												
									exec P9999_Audit_Trail @Cmp_ID,@tran_type,'TDS Challan',@OldValue,@Challan_Id,@User_Id,@IP_Address
								-- Added for audit trail By Ali 19102013 -- End
			
		END
	ELSE IF @TRAN_TYPE = 'U'
		BEGIN
				
								-- Added for audit trail By Ali 19102013 -- Start
									Select 
									@Old_Month = [Month]
									,@Old_Year = [Year]
									,@Old_Bank_Name = Bank_Name
									,@Old_Paid_By = Paid_By
									,@Old_Payment_Date = Payment_Date
									,@Old_Cheque_No = Cheque_No
									,@Old_Cheque_Date = Cheque_Date
									,@Old_Bank_BSR_Code = Bank_BSR_Code
									,@Old_CIN_No = CIN_No
									,@Old_Tax_Amount = Tax_Amount
									,@Old_ED_Cess = ED_Cess
									,@Old_Interest_Amount = Interest_Amount
									,@Old_Penalty_Amount = Penalty_Amount
									,@Old_Other_Amount = Other_Amount
									,@Old_Total_Amount = Total_Amount
									,@Old_Challan_type = Challan_type									
									FROM T0220_TDS_CHALLAN  WITH (NOLOCK)
									WHERE CHALLAN_ID = @CHALLAN_ID
									
									set @OldValue = 'old Value' 
										+ '#' + 'Due for the Month : ' + CONVERT(nvarchar(100),ISNULL(@Old_Month,0))
										+ '#' + 'Due for the Year : ' + CONVERT(nvarchar(100),ISNULL(@Old_Year,0))										
										+ '#' + 'Name of the Bank : ' + ISNULL(@Old_Bank_Name,'')
										+ '#' + 'Paid By : ' + ISNULL(@Old_Paid_By,'')
										+ '#' + 'Date Of Payment : ' + cast(ISNULL(@Old_Payment_Date,'') as nvarchar(11))
										+ '#' + 'Cheque No : ' + ISNULL(@Old_Cheque_No,'')
										+ '#' + 'Cheque Date : ' + cast(ISNULL(@Old_Cheque_Date,'') as nvarchar(11))
										+ '#' + 'Bank BSR Codey : ' + ISNULL(@Old_Bank_BSR_Code,'')
										+ '#' + 'Challan Sr. No 	 : ' + ISNULL(@Old_CIN_No,'')
										+ '#' + 'Income Tax Amount : ' + CONVERT(nvarchar(100),ISNULL(@Old_Tax_Amount,0))
										+ '#' + 'ED Cess Amount 	 : ' + CONVERT(nvarchar(100),ISNULL(@Old_ED_Cess,0))
										+ '#' + 'Interest Amount : ' + CONVERT(nvarchar(100),ISNULL(@Old_Interest_Amount,0))
										+ '#' + 'Penalty Amount : ' + CONVERT(nvarchar(100),ISNULL(@Old_Penalty_Amount,0))
										+ '#' + 'Other Amount : ' + CONVERT(nvarchar(100),ISNULL(@Old_Other_Amount,0))
										+ '#' + 'Total Amount : ' + CONVERT(nvarchar(100),ISNULL(@Old_Total_Amount,0))										
										+ '#' + 'Challan Type : ' + CASE WHEN @Old_Challan_type = 1 THEN 'Multiple' ELSE 'Single' END										
										+ '#' +
										+ 'New Value' +
										+ '#' + 'Due for the Month : ' + CONVERT(nvarchar(100),ISNULL(@Month,0))
										+ '#' + 'Due for the Year : ' + CONVERT(nvarchar(100),ISNULL(@Year,0))										
										+ '#' + 'Name of the Bank : ' + ISNULL(@Bank_Name,'')
										+ '#' + 'Paid By : ' + ISNULL(@Paid_By,'')
										+ '#' + 'Date Of Payment : ' + cast(ISNULL(@Payment_Date,'') as nvarchar(11))
										+ '#' + 'Cheque No : ' + ISNULL(@Cheque_No,'')
										+ '#' + 'Cheque Date : ' + cast(ISNULL(@Cheque_Date,'') as nvarchar(11))
										+ '#' + 'Bank BSR Codey : ' + ISNULL(@Bank_BSR_Code,'')
										+ '#' + 'Challan Sr. No 	 : ' + ISNULL(@CIN_No,'')
										+ '#' + 'Income Tax Amount : ' + CONVERT(nvarchar(100),ISNULL(@Tax_Amount,0))
										+ '#' + 'ED Cess Amount 	 : ' + CONVERT(nvarchar(100),ISNULL(@ED_Cess,0))
										+ '#' + 'Interest Amount : ' + CONVERT(nvarchar(100),ISNULL(@Interest_Amount,0))
										+ '#' + 'Penalty Amount : ' + CONVERT(nvarchar(100),ISNULL(@Penalty_Amount,0))
										+ '#' + 'Other Amount : ' + CONVERT(nvarchar(100),ISNULL(@Other_Amount,0))
										+ '#' + 'Total Amount : ' + CONVERT(nvarchar(100),ISNULL(@Total_Amount,0))			
										+ '#' + 'Challan Type : ' + CASE WHEN @Challan_type = 1 THEN 'Multiple' ELSE 'Single' END
										
																																												
									exec P9999_Audit_Trail @Cmp_ID,@tran_type,'TDS Challan',@OldValue,@Challan_Id,@User_Id,@IP_Address
								-- Added for audit trail By Ali 19102013 -- End
					
					
					
			UPDATE    T0220_TDS_CHALLAN
				SET		PAYMENT_DATE = @PAYMENT_DATE, BANK_ID = @BANK_ID, 
						BANK_NAME = @BANK_NAME, BANK_BSR_CODE = @BANK_BSR_CODE, PAID_BY = @PAID_BY, CHEQUE_NO = @CHEQUE_NO, CIN_NO = @CIN_NO, 
						CHEQUE_DATE = @CHEQUE_DATE, TAX_AMOUNT = @TAX_AMOUNT, ED_CESS = @ED_CESS, INTEREST_AMOUNT = @INTEREST_AMOUNT, PENALTY_AMOUNT = @PENALTY_AMOUNT, 
						OTHER_AMOUNT = @OTHER_AMOUNT, TOTAL_AMOUNT = @TOTAL_AMOUNT	
						,Challan_type = @Challan_type
			 WHERE    CHALLAN_ID = @CHALLAN_ID
	         
		END
	ELSE IF @TRAN_TYPE = 'D'
		BEGIN
								-- Added for audit trail By Ali 19102013 -- Start
									Select 
									@Old_Month = [Month]
									,@Old_Year = [Year]
									,@Old_Bank_Name = Bank_Name
									,@Old_Paid_By = Paid_By
									,@Old_Payment_Date = Payment_Date
									,@Old_Cheque_No = Cheque_No
									,@Old_Cheque_Date = Cheque_Date
									,@Old_Bank_BSR_Code = Bank_BSR_Code
									,@Old_CIN_No = CIN_No
									,@Old_Tax_Amount = Tax_Amount
									,@Old_ED_Cess = ED_Cess
									,@Old_Interest_Amount = Interest_Amount
									,@Old_Penalty_Amount = Penalty_Amount
									,@Old_Other_Amount = Other_Amount
									,@Old_Total_Amount = Total_Amount
									,@Old_Challan_type = Challan_type									
									FROM T0220_TDS_CHALLAN WITH (NOLOCK)
									WHERE CHALLAN_ID = @CHALLAN_ID
									
									set @OldValue = 'old Value' 
										+ '#' + 'Due for the Month : ' + CONVERT(nvarchar(100),ISNULL(@Old_Month,0))
										+ '#' + 'Due for the Year : ' + CONVERT(nvarchar(100),ISNULL(@Old_Year,0))										
										+ '#' + 'Name of the Bank : ' + ISNULL(@Old_Bank_Name,'')
										+ '#' + 'Paid By : ' + ISNULL(@Old_Paid_By,'')
										+ '#' + 'Date Of Payment : ' + cast(ISNULL(@Old_Payment_Date,'') as nvarchar(11))
										+ '#' + 'Cheque No : ' + ISNULL(@Old_Cheque_No,'')
										+ '#' + 'Cheque Date : ' + cast(ISNULL(@Old_Cheque_Date,'') as nvarchar(11))
										+ '#' + 'Bank BSR Codey : ' + ISNULL(@Old_Bank_BSR_Code,'')
										+ '#' + 'Challan Sr. No 	 : ' + ISNULL(@Old_CIN_No,'')
										+ '#' + 'Income Tax Amount : ' + CONVERT(nvarchar(100),ISNULL(@Old_Tax_Amount,0))
										+ '#' + 'ED Cess Amount 	 : ' + CONVERT(nvarchar(100),ISNULL(@Old_ED_Cess,0))
										+ '#' + 'Interest Amount : ' + CONVERT(nvarchar(100),ISNULL(@Old_Interest_Amount,0))
										+ '#' + 'Penalty Amount : ' + CONVERT(nvarchar(100),ISNULL(@Old_Penalty_Amount,0))
										+ '#' + 'Other Amount : ' + CONVERT(nvarchar(100),ISNULL(@Old_Other_Amount,0))
										+ '#' + 'Total Amount : ' + CONVERT(nvarchar(100),ISNULL(@Old_Total_Amount,0))										
										+ '#' + 'Challan Type : ' + CASE WHEN @Old_Challan_type = 1 THEN 'Multiple' ELSE 'Single' END
										
																																												
									exec P9999_Audit_Trail @Cmp_ID,@tran_type,'TDS Challan',@OldValue,@Challan_Id,@User_Id,@IP_Address
								-- Added for audit trail By Ali 19102013 -- End
								
								
			DELETE from T0230_TDS_CHALLAN_DETAIL where Challan_Id = @Challan_Id
			DELETE FROM T0220_TDS_CHALLAN WHERE CHALLAN_ID = @CHALLAN_ID
				
		END
	
RETURN




