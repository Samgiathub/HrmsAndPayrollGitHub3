
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0100_IT_DECLARATION]
	@IT_TRAN_ID		NUMERIC output, 
	@CMP_ID			NUMERIC, 
	@IT_ID			NUMERIC, 
	@EMP_ID			NUMERIC, 
	@FOR_DATE		DATETIME, 
	@AMOUNT			NUMERIC(18,2), --Chnage by Jaina 29-03-2017
	@DOC_NAME		VARCHAR(200), 
	@LOGIN_ID		NUMERIC,
	@REPEAT_YEARLY  TINYINT,
	@TRAN_TYPE		CHAR(1),
	@AMOUNT_ESS		NUMERIC(18,2),
	@IT_Flag		TINYINT,
	@FINANCIAL_YEAR VARCHAR(20),
	@Is_Lock as bit = 0 ,			-- Added By Ali 22012014  
	@User_ID numeric(18,0) = 0,			-- Added for audit trail By Ali 31122013
	@IP_Address varchar(30)= '',		-- Added for audit trail By Ali 31122013
	@Is_Metro_NonMetro varchar(30) = '',		-- Added by Nimesh 21-Jul-2015 (For City Category)
	@IsCompare_Flag varchar(50) = '' --Added by Jaina 1-09-2020
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	IF @LOGIN_ID=  0
		SET @LOGIN_ID = NULL
		
									-- Added for audit trail By Ali 31122013 -- Start						
										Declare @Old_IT_ID AS NUMERIC
										Declare @Old_IT_Name AS varchar(100)
										Declare @New_IT_Name AS varchar(100)
										Declare @Old_EMP_ID	AS NUMERIC
										Declare @Old_EMP_Name AS varchar(100)
										Declare @New_EMP_Name AS varchar(100)
										Declare @Old_FOR_DATE AS DATETIME
										Declare @Old_AMOUNT	AS NUMERIC(18,2)
										Declare @Old_FINANCIAL_YEAR AS VARCHAR(20)
										Declare @OldValue varchar(max)
										Declare @HRA_DEF_ID INT
										

										Set @Old_IT_ID = 0
										Set @Old_IT_Name = ''
										Set @New_IT_Name = ''
										Set @Old_EMP_ID	= 0
										Set @Old_EMP_Name = ''
										Set @New_EMP_Name = ''
										Set @Old_FOR_DATE = null
										Set @Old_AMOUNT	= 0
										Set @Old_FINANCIAL_YEAR = ''
										Set @OldValue = ''
									-- Added for audit trail By Ali 31122013 -- End
	
	
	IF ISNULL(@Is_Metro_NonMetro, '') = ''
	BEGIN
		IF EXISTS (SELECT Is_Metro_City FROM V0080_Employee_Master WHERE Emp_ID=@EMP_ID AND Cmp_ID=@Cmp_ID AND Is_Metro_City = 1)
			SET @Is_Metro_NonMetro = 'Metro'
		Else
			SET @Is_Metro_NonMetro = 'Non-Metro'
	END
	
	IF @TRAN_TYPE ='I'
		BEGIN

				SELECT @IT_TRAN_ID = ISNULL(MAX(IT_TRAN_ID),0) + 1 from T0100_IT_DECLARATION WITH (NOLOCK)
				--IF NOT EXISTS (SELECT 1 FROM T0100_IT_DECLARATION WHERE IT_ID = @IT_ID AND CMP_ID = @CMP_ID AND EMP_ID = @EMP_ID AND FINANCIAL_YEAR = @FINANCIAL_YEAR)
				BEGIN
					INSERT INTO T0100_IT_DECLARATION
										  (IT_TRAN_ID, CMP_ID, IT_ID, EMP_ID, FOR_DATE, AMOUNT, DOC_NAME, LOGIN_ID, SYSTEM_DATE,REPEAT_YEARLY, AMOUNT_ESS, IT_Flag, FINANCIAL_YEAR,Is_Lock  -- Added By Ali 22012014  
											,Is_Metro_NonMetro,IsCompare_Flag) --Added by Nimesh 21-Jul-2015 
					VALUES     (@IT_TRAN_ID, @CMP_ID, @IT_ID, @EMP_ID, @FOR_DATE, @AMOUNT, @DOC_NAME, @LOGIN_ID, GETDATE(),@REPEAT_YEARLY, @AMOUNT_ESS, @IT_Flag, @FINANCIAL_YEAR,@Is_Lock
											,@Is_Metro_NonMetro,@IsCompare_Flag)--Added by Nimesh 21-Jul-2015 
				END
				
				if @IsCompare_Flag = 'Compare'
				Begin
					--IF NOT EXISTS (SELECT 1 FROM T0100_IT_DECLARATION_COMPARE WHERE IT_ID = @IT_ID AND CMP_ID = @CMP_ID AND EMP_ID = @EMP_ID AND FINANCIAL_YEAR = @FINANCIAL_YEAR)
					BEGIN
						INSERT INTO T0100_IT_DECLARATION_COMPARE
											  (IT_TRAN_ID, CMP_ID, IT_ID, EMP_ID, FOR_DATE, AMOUNT, DOC_NAME, LOGIN_ID, SYSTEM_DATE,REPEAT_YEARLY, AMOUNT_ESS, IT_Flag, FINANCIAL_YEAR,Is_Lock  -- Added By Ali 22012014  
												,Is_Metro_NonMetro,IsCompare_Flag) --Added by Nimesh 21-Jul-2015 
						VALUES     (@IT_TRAN_ID, @CMP_ID, @IT_ID, @EMP_ID, @FOR_DATE, @AMOUNT, @DOC_NAME, @LOGIN_ID, GETDATE(),@REPEAT_YEARLY, @AMOUNT_ESS, @IT_Flag, @FINANCIAL_YEAR,@Is_Lock
											,@Is_Metro_NonMetro,@IsCompare_Flag)--Added by Nimesh 21-Jul-2015
					END

					--Delete T0100_IT_DECLARATION where IT_TRAN_ID = @IT_TRAN_ID 
				End
				
									-- Added for audit trail By Ali 31122013 -- Start
											Set @Old_IT_Name = (Select IT_Name from T0070_IT_MASTER WITH (NOLOCK) where IT_ID = @IT_ID)
											Set @Old_EMP_Name = (Select Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_Id = @EMP_ID)
											set @OldValue = 'New Value' 
												+ '#' + 'IT Name : ' + ISNULL(@Old_IT_Name,'')
												+ '#' + 'Employee Name : ' + ISNULL(@Old_EMP_Name,'')
												+ '#' + 'For Date : ' + cast(ISNULL(@FOR_DATE,'') as nvarchar(11)) 
												+ '#' + 'Amount : ' + CONVERT(nvarchar(200),ISNULL(@AMOUNT,0))
												+ '#' + 'Financial Year : ' + ISNULL(@FINANCIAL_YEAR,'')
											exec P9999_Audit_Trail @Cmp_ID,@tran_type,'IT Declaration',@OldValue,@Emp_ID,@User_Id,@IP_Address,1
									-- Added for audit trail By Ali 31122013 -- End
		END
	ELSE IF @TRAN_TYPE ='U'
		BEGIN
		
									-- Added for audit trail By Ali 31122013 -- Start
											Select 
											@Old_IT_ID = IT_ID
											,@Old_EMP_ID = EMP_ID
											,@Old_FOR_DATE = FOR_DATE
											,@Old_AMOUNT = AMOUNT
											,@Old_FINANCIAL_YEAR = FINANCIAL_YEAR
											From T0100_IT_DECLARATION WITH (NOLOCK)
											Where IT_TRAN_ID = @IT_TRAN_ID
											
											Set @Old_IT_Name = (Select IT_Name from T0070_IT_MASTER WITH (NOLOCK) where IT_ID = @Old_IT_ID)
											Set @Old_EMP_Name = (Select Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_Id = @Old_EMP_ID)
											
											Set @New_IT_Name = (Select IT_Name from T0070_IT_MASTER WITH (NOLOCK) where IT_ID = @IT_ID)
											Set @New_EMP_Name = (Select Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_Id = @EMP_ID)
											
											set @OldValue = 
												'old Value' 
												+ '#' + 'IT Name : ' + ISNULL(@Old_IT_Name,'')
												+ '#' + 'Employee Name : ' + ISNULL(@Old_EMP_Name,'')
												+ '#' + 'For Date : ' + cast(ISNULL(@Old_FOR_DATE,'') as nvarchar(11)) 
												+ '#' + 'Amount : ' + CONVERT(nvarchar(200),ISNULL(@Old_AMOUNT,0))
												+ '#' + 'Financial Year : ' + ISNULL(@Old_FINANCIAL_YEAR,'')
												+ '#' + 
												+ 'New Value' +
												+ '#' + 'IT Name : ' + ISNULL(@New_IT_Name,'')
												+ '#' + 'Employee Name : ' + ISNULL(@New_EMP_Name,'')
												+ '#' + 'For Date : ' + cast(ISNULL(@FOR_DATE,'') as nvarchar(11)) 
												+ '#' + 'Amount : ' + CONVERT(nvarchar(200),ISNULL(@AMOUNT,0))
												+ '#' + 'Financial Year : ' + ISNULL(@FINANCIAL_YEAR,'')
											exec P9999_Audit_Trail @Cmp_ID,@tran_type,'IT Declaration',@OldValue,@Emp_ID,@User_Id,@IP_Address,1
									 -- Added for audit trail By Ali 31122013 -- End
										
				SELECT @HRA_DEF_ID = IT_DEF_ID FROM T0070_IT_MASTER WITH (NOLOCK) WHERE IT_ID = @IT_ID --Added By Jimit 19032019
				
				IF 	@HRA_DEF_ID = 1
					BEGIN			
						UPDATE    T0100_IT_DECLARATION
						SET        IT_ID = @IT_ID, EMP_ID = @EMP_ID, FOR_DATE = CASE WHEN IT_TRAN_ID = @IT_TRAN_ID THEN @FOR_DATE ELSE FOR_DATE END, 
									AMOUNT = CASE WHEN IT_TRAN_ID = @IT_TRAN_ID THEN @AMOUNT ELSE AMOUNT END, 
								   DOC_NAME = CASE WHEN IT_TRAN_ID = @IT_TRAN_ID THEN @DOC_NAME ELSE DOC_NAME END,
								    LOGIN_ID = @LOGIN_ID, SYSTEM_DATE = GETDATE()
								   ,REPEAT_YEARLY=@REPEAT_YEARLY, AMOUNT_ESS = @AMOUNT_ESS, IT_Flag = @IT_Flag
								   , FINANCIAL_YEAR = @FINANCIAL_YEAR  
								   ,Is_Lock = @Is_Lock -- Added By Ali 22012014 
								   ,Is_Metro_NonMetro=@Is_Metro_NonMetro --Added By Nimesh 21-Jul-2015
								   ,IsCompare_Flag=@IsCompare_Flag  --Added by Jaina 1-09-2020
						WHERE		It_ID = @Old_IT_ID AND EMP_ID = @Old_EMP_ID and FINANCIAL_YEAR = @Old_FINANCIAL_YEAR 
									--FOR_DATE = @Old_FOR_DATE
															
					END
				ELSE
					BEGIN
							UPDATE    T0100_IT_DECLARATION
						SET        IT_ID = @IT_ID, EMP_ID = @EMP_ID, FOR_DATE = @FOR_DATE, AMOUNT = @AMOUNT, 
								   DOC_NAME = @DOC_NAME, LOGIN_ID = @LOGIN_ID, SYSTEM_DATE = GETDATE()
								   ,REPEAT_YEARLY=@REPEAT_YEARLY, AMOUNT_ESS = @AMOUNT_ESS, IT_Flag = @IT_Flag
								   , FINANCIAL_YEAR = @FINANCIAL_YEAR  
								   ,Is_Lock = @Is_Lock -- Added By Ali 22012014 
								   ,Is_Metro_NonMetro=@Is_Metro_NonMetro --Added By Nimesh 21-Jul-2015
								   ,IsCompare_Flag = @IsCompare_Flag  --Added by Jaina 1-09-2020
						WHERE	   IT_TRAN_ID = @IT_TRAN_ID	
					END

		END
	ELSE IF @TRAN_TYPE ='D'
		BEGIN
			 DELETE FROM T0100_IT_DECLARATION WHERE IT_TRAN_ID = @IT_TRAN_ID
		END
	RETURN




