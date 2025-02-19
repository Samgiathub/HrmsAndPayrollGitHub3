
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0220_PT_CHALLAN]
 @Challan_Id	NUMERIC(18, 0) OUTPUT
,@Cmp_ID	NUMERIC(18, 0)	
--,@Branch_ID NUMERIC(18,0)
,@Branch_ID	varchar(Max) --  Added By Jaina 17-09-2015
,@Month	NUMERIC(18, 0)	
,@Year	NUMERIC(18, 0)	
,@Payment_Date	DATETIME	
,@Bank_ID	NUMERIC(18, 0)	
,@Bank_Name	VARCHAR(100)
,@Tax_Amount	NUMERIC(18, 2)
,@Tax_Return_Amount NUMERIC(18,2)
,@Interest_Amount	NUMERIC(18, 2)
,@Penalty_Amount	NUMERIC(18, 2)	
,@Other_Amount	NUMERIC(18, 2)	
,@Total_Amount	NUMERIC(18, 2)
,@Emp_Count NUMERIC(18, 0)
,@Tran_Type VARCHAR(1) = 'I'
,@User_Id numeric(18,0) = 0		-- Added for audit trail By Ali 19102013
,@IP_Address varchar(30)= ''	-- Added for audit trail By Ali 19102013
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

									-- Added for audit trail By Ali 19102013 -- Start
									Declare @OldValue as varchar(max)
									Declare @Old_Branch_Name as varchar(150)
									Declare @Old_Bank_Name as varchar(150)
									Declare @New_Branch_Name as varchar(max)
									Declare @New_Bank_Name as varchar(150)
									--Declare @Old_Branch_ID NUMERIC(18,0)
									Declare @Old_Branch_ID Varchar(max)
									Declare @Old_Month	NUMERIC(18, 0)	
									Declare @Old_Year	NUMERIC(18, 0)	
									Declare @Old_Payment_Date	DATETIME	
									Declare @Old_Bank_ID	NUMERIC(18, 0)	
									Declare @Old_S_Bank_Name	VARCHAR(100)
									Declare @Old_Tax_Amount	NUMERIC(18, 2)
									Declare @Old_Tax_Return_Amount NUMERIC(18,2)
									Declare @Old_Interest_Amount	NUMERIC(18, 2)
									Declare @Old_Penalty_Amount	NUMERIC(18, 2)	
									Declare @Old_Other_Amount	NUMERIC(18, 2)	
									Declare @Old_Total_Amount	NUMERIC(18, 2)
									Declare @Old_Emp_Count NUMERIC(18, 0)
									DECLARE @Old_Branch_ID_Multi as varchar(MAX)  --Added By Jaina 17-09-2015
									
									Set @OldValue = ''
									Set @Old_Branch_Name = ''
									Set @Old_Bank_Name = ''
									Set @New_Branch_Name = ''
									Set @New_Bank_Name = ''
									Set @Old_Branch_ID = ''
									Set @Old_Month = 0
									Set @Old_Year = 0
									Set @Old_Payment_Date = null
									Set @Old_Bank_ID = 0
									Set @Old_S_Bank_Name = ''
									Set @Old_Tax_Amount = 0
									Set @Old_Tax_Return_Amount = 0
									Set @Old_Interest_Amount = 0
									Set @Old_Penalty_Amount = 0
									Set @Old_Other_Amount = 0
									Set @Old_Total_Amount = 0
									Set @Old_Emp_Count = 0
									set @Old_Branch_ID_Multi = ''  --Added By Jaina 17-09-2015
								-- Added for audit trail By Ali 19102013 -- End
								
	 
	 if @Branch_ID = '' or @Branch_ID = '0'--0  --Added By Jaina 17-09-2015
		set	@Branch_ID = NULL
		
	IF @TRAN_TYPE = 'I'
		BEGIN

			--Added By Jaina 19-07-2015 Start
			If Exists(select Challan_Id From dbo.T0220_PT_CHALLAN WITH (NOLOCK) Where Cmp_ID = @Cmp_ID  and Month = @Month AND Year=@Year 
			     		and Branch_ID_Multi IN ( SELECT CAST(data as NUMERIC) as data FROM dbo.Split(@Branch_ID,'#' ) )) 
			begin
				set @Challan_Id = 0
				return
			end
			--Added By Jaina 19-07-2015 End 
							
			SELECT @CHALLAN_ID = ISNULL(MAX(CHALLAN_ID),0) + 1 FROM T0220_PT_CHALLAN WITH (NOLOCK)
			
			INSERT INTO T0220_PT_CHALLAN
					(Challan_Id, Cmp_ID, Branch_ID, Month, Year, Payment_Date, Bank_ID, Bank_Name, Tax_Amount, Tax_Return_Amount, Interest_Amount, Penalty_Amount, Other_Amount, Total_Amount, Emp_Count,Branch_ID_Multi)
			VALUES  (@Challan_Id, @Cmp_ID , NULL, @Month, @Year, @Payment_Date, @Bank_ID, @Bank_Name, @Tax_Amount, @Tax_Return_Amount, @Interest_Amount, @Penalty_Amount, @Other_Amount, @Total_Amount, @Emp_Count,@Branch_Id)  --Added By Jaina 17-09-2015
			
								-- Added for audit trail By Ali 19102013 -- Start
									--Set @Old_Branch_Name = (Select Branch_Name from T0030_BRANCH_MASTER where Cmp_ID = @Cmp_ID and Branch_ID = @Branch_ID)
									
 								    Select @Old_Branch_Name = COALESCE(@Old_Branch_Name + ',', '') +  (convert(nvarchar,Branch_Name)) from T0030_BRANCH_MASTER WITH (NOLOCK)  --Added By Jaina 17-09-2015
										  where Cmp_ID = @Cmp_ID and Branch_ID in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@branch_Id,ISNULL(Cast(Branch_ID As Varchar(Max)),0)),'#') )
									
									Set @Old_Bank_Name = (Select Bank_Name from T0040_BANK_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_ID And Bank_ID = @Bank_ID)
											
									set @OldValue = 'New Value' 
										+ '#' + 'Due for the Month : ' + CONVERT(nvarchar(100),ISNULL(@Month,0))
										+ '#' + 'Due for the Year : ' + CONVERT(nvarchar(100),ISNULL(@Year,0))
										+ '#' + 'Branch abc : ' + ISNULL(@Old_Branch_Name,'')																						
										+ '#' + 'Name of the Bank : ' + ISNULL(@Old_Bank_Name,'')
										+ '#' + 'Date Of Payment : ' + cast(ISNULL(@Payment_Date,'') as nvarchar(11))
										+ '#' + 'Tax Assessed : ' + CONVERT(nvarchar(100),ISNULL(@Tax_Amount,0))
										+ '#' + 'Tax According to Returns : ' + CONVERT(nvarchar(100),ISNULL(@Tax_Return_Amount,0))
										+ '#' + 'Interest Amount : ' + CONVERT(nvarchar(100),ISNULL(@Interest_Amount,0))
										+ '#' + 'Penalty Amount : ' + CONVERT(nvarchar(100),ISNULL(@Penalty_Amount,0))
										+ '#' + 'Other Amount : ' + CONVERT(nvarchar(100),ISNULL(@Other_Amount,0))
										+ '#' + 'Total Amount : ' + CONVERT(nvarchar(100),ISNULL(@Total_Amount,0))
										+ '#' + 'Employee Count : ' + CONVERT(nvarchar(100),ISNULL(@Emp_Count,0))
																																												
										exec P9999_Audit_Trail @Cmp_ID,@tran_type,'PT Challan',@OldValue,@Challan_Id,@User_Id,@IP_Address
								-- Added for audit trail By Ali 19102013 -- End
			
		END
	ELSE IF @TRAN_TYPE = 'U'
		BEGIN
			
								-- Added for audit trail By Ali 19102013 -- Start
									Select
									--@Old_Branch_ID = Branch_ID
									@Old_Branch_ID = IsNull(Branch_ID_Multi,Cast(Branch_ID As Varchar(Max)))  --Added By Jaina 17-09-2015
									,@Old_Bank_ID = Bank_ID
									,@Old_Month  = [Month]
									,@Old_Year = [Year]
									,@Old_Payment_Date = Payment_Date
									,@Old_Tax_Amount = Tax_Amount
									,@Old_Tax_Return_Amount = Tax_Return_Amount
									,@Old_Interest_Amount = Interest_Amount
									,@Old_Penalty_Amount = Penalty_Amount
									,@Old_Other_Amount = Other_Amount
									,@Old_Total_Amount = Total_Amount
									,@Old_Emp_Count = Emp_Count
									FROM T0220_PT_CHALLAN WITH (NOLOCK)
									WHERE CHALLAN_ID = @CHALLAN_ID			
									
									--Set @Old_Branch_Name = (Select Branch_Name from T0030_BRANCH_MASTER where Cmp_ID = @Cmp_ID and Branch_ID = @Old_Branch_ID)
									Select @Old_Branch_Name = COALESCE(@Old_Branch_Name + ',', '') +  (convert(nvarchar,Branch_Name)) from T0030_BRANCH_MASTER  WITH (NOLOCK)
																			where Cmp_ID = @Cmp_ID and Branch_ID in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Old_Branch_ID,ISNULL(Branch_ID,0)),'#') )
																			
									Set @Old_Bank_Name = (Select Bank_Name from T0040_BANK_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_ID And Bank_ID = @Old_Bank_ID)
																		
									Set @New_Bank_Name = (Select Bank_Name from T0040_BANK_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_ID And Bank_ID = @Bank_ID)
											
									set @OldValue = 'old Value' 
										+ '#' + 'Due for the Month : ' + CONVERT(nvarchar(100),ISNULL(@Old_Month,0))
										+ '#' + 'Due for the Year : ' + CONVERT(nvarchar(100),ISNULL(@Old_Year,0))
										+ '#' + 'Branch abc : ' + ISNULL(@Old_Branch_Name,'')																						
										+ '#' + 'Name of the Bank : ' + ISNULL(@Old_Bank_Name,'')
										+ '#' + 'Date Of Payment : ' + cast(ISNULL(@Old_Payment_Date,'') as nvarchar(11))
										+ '#' + 'Tax Assessed : ' + CONVERT(nvarchar(100),ISNULL(@Old_Tax_Amount,0))
										+ '#' + 'Tax According to Returns : ' + CONVERT(nvarchar(100),ISNULL(@Old_Tax_Return_Amount,0))
										+ '#' + 'Interest Amount : ' + CONVERT(nvarchar(100),ISNULL(@Old_Interest_Amount,0))
										+ '#' + 'Penalty Amount : ' + CONVERT(nvarchar(100),ISNULL(@Old_Penalty_Amount,0))
										+ '#' + 'Other Amount : ' + CONVERT(nvarchar(100),ISNULL(@Old_Other_Amount,0))
										+ '#' + 'Total Amount : ' + CONVERT(nvarchar(100),ISNULL(@Old_Total_Amount,0))
										+ '#' + 'Employee Count : ' + CONVERT(nvarchar(100),ISNULL(@Old_Emp_Count,0))
										+ '#' +
										+ 'New Value' +
										+ '#' + 'Due for the Month : ' + CONVERT(nvarchar(100),ISNULL(@Month,0))
										+ '#' + 'Due for the Year : ' + CONVERT(nvarchar(100),ISNULL(@Year,0))
										+ '#' + 'Branch abc : ' + ISNULL(@New_Branch_Name,'')																						
										+ '#' + 'Name of the Bank : ' + ISNULL(@New_Bank_Name,'')
										+ '#' + 'Date Of Payment : ' + cast(ISNULL(@Payment_Date,'') as nvarchar(11))
										+ '#' + 'Tax Assessed : ' + CONVERT(nvarchar(100),ISNULL(@Tax_Amount,0))
										+ '#' + 'Tax According to Returns : ' + CONVERT(nvarchar(100),ISNULL(@Tax_Return_Amount,0))
										+ '#' + 'Interest Amount : ' + CONVERT(nvarchar(100),ISNULL(@Interest_Amount,0))
										+ '#' + 'Penalty Amount : ' + CONVERT(nvarchar(100),ISNULL(@Penalty_Amount,0))
										+ '#' + 'Other Amount : ' + CONVERT(nvarchar(100),ISNULL(@Other_Amount,0))
										+ '#' + 'Total Amount : ' + CONVERT(nvarchar(100),ISNULL(@Total_Amount,0))
										+ '#' + 'Employee Count : ' + CONVERT(nvarchar(100),ISNULL(@Emp_Count,0))
												
																																												
										exec P9999_Audit_Trail @Cmp_ID,@tran_type,'PT Challan',@OldValue,@Challan_Id,@User_Id,@IP_Address
								-- Added for audit trail By Ali 19102013 -- End
								
			UPDATE    T0220_PT_CHALLAN
				SET		PAYMENT_DATE = @PAYMENT_DATE, BANK_ID = @BANK_ID, BANK_NAME = @BANK_NAME, TAX_AMOUNT = @TAX_AMOUNT, Tax_Return_Amount = @Tax_Return_Amount
				      , INTEREST_AMOUNT = @INTEREST_AMOUNT, PENALTY_AMOUNT = @PENALTY_AMOUNT, OTHER_AMOUNT = @OTHER_AMOUNT, TOTAL_AMOUNT = @TOTAL_AMOUNT, Emp_Count = @Emp_Count
				      , Branch_ID_Multi = @Branch_Id 	--Added By Jaina 17-09-2015
			 WHERE    CHALLAN_ID = @CHALLAN_ID AND Cmp_ID = @Cmp_ID 
	         
		END
	ELSE IF @TRAN_TYPE = 'D'
		BEGIN			
								-- Added for audit trail By Ali 19102013 -- Start
									Select
									@Old_Branch_ID = Branch_ID
									,@Old_Bank_ID = Bank_ID
									,@Old_Month  = [Month]
									,@Old_Year = [Year]
									,@Old_Payment_Date = Payment_Date
									,@Old_Tax_Amount = Tax_Amount
									,@Old_Tax_Return_Amount = Tax_Return_Amount
									,@Old_Interest_Amount = Interest_Amount
									,@Old_Penalty_Amount = Penalty_Amount
									,@Old_Other_Amount = Other_Amount
									,@Old_Total_Amount = Total_Amount
									,@Old_Emp_Count = Emp_Count
									,@Old_Branch_ID_Multi = Branch_ID_Multi
									FROM T0220_PT_CHALLAN WITH (NOLOCK)
									WHERE CHALLAN_ID = @CHALLAN_ID			
									
									
									--Set @Old_Branch_Name = (Select Branch_Name from T0030_BRANCH_MASTER where Cmp_ID = @Cmp_ID and Branch_ID = @Old_Branch_ID)
									Select @Old_Branch_Name = COALESCE(@Old_Branch_Name + ',', '') +  (convert(nvarchar,Branch_Name)) from T0030_BRANCH_MASTER  WITH (NOLOCK) --Added Bt Jaina 17-09-2015
									where Cmp_ID = @Cmp_ID 
									and Branch_ID in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Old_Branch_ID_Multi,ISNULL(Branch_ID,0)),'#') )
									
									Set @Old_Bank_Name = (Select Bank_Name from T0040_BANK_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_ID And Bank_ID = @Old_Bank_ID)
											
									set @OldValue = 'old Value' 
										+ '#' + 'Due for the Month : ' + CONVERT(nvarchar(100),ISNULL(@Old_Month,0))
										+ '#' + 'Due for the Year : ' + CONVERT(nvarchar(100),ISNULL(@Old_Year,0))
										+ '#' + 'Branch abc : ' + ISNULL(@Old_Branch_Name,'')																						
										+ '#' + 'Name of the Bank : ' + ISNULL(@Old_Bank_Name,'')
										+ '#' + 'Date Of Payment : ' + cast(ISNULL(@Old_Payment_Date,'') as nvarchar(11))
										+ '#' + 'Tax Assessed : ' + CONVERT(nvarchar(100),ISNULL(@Old_Tax_Amount,0))
										+ '#' + 'Tax According to Returns : ' + CONVERT(nvarchar(100),ISNULL(@Old_Tax_Return_Amount,0))
										+ '#' + 'Interest Amount : ' + CONVERT(nvarchar(100),ISNULL(@Old_Interest_Amount,0))
										+ '#' + 'Penalty Amount : ' + CONVERT(nvarchar(100),ISNULL(@Old_Penalty_Amount,0))
										+ '#' + 'Other Amount : ' + CONVERT(nvarchar(100),ISNULL(@Old_Other_Amount,0))
										+ '#' + 'Total Amount : ' + CONVERT(nvarchar(100),ISNULL(@Old_Total_Amount,0))
										+ '#' + 'Employee Count : ' + CONVERT(nvarchar(100),ISNULL(@Old_Emp_Count,0))
																																												
										exec P9999_Audit_Trail @Cmp_ID,@tran_type,'PT Challan',@OldValue,@Challan_Id,@User_Id,@IP_Address
								-- Added for audit trail By Ali 19102013 -- End
								
			DELETE FROM T0220_PT_CHALLAN WHERE CHALLAN_ID = @CHALLAN_ID				
		END
	
RETURN




