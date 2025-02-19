

--==================================================
--ALTER BY : NILAY 
--ALTER DATE : 17 FEB 2011
--IMPORT THE DECLARATION
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
--==================================================
CREATE PROCEDURE [dbo].[P0100_IT_DECLARATION_IMPORT]
	
	@CMP_ID			NUMERIC, 
	@IT_NAME		varchar(2000), 
	@EMP_CODE		varchar(100), 
	@FOR_DATE		DATETIME, 
	@AMOUNT			NUMERIC,
	@Flag			NUMERIC = 0, -- Added by Ali 07022014
	@LOGIN_ID		NUMERIC,
	@GUID			Varchar(2000) = '' --Added by Nilesh Patel on 14062016
	--@REPEAT_YEARLY  TINYINT,
	--@TRAN_TYPE		CHAR(1)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	IF @LOGIN_ID=  0
		SET @LOGIN_ID = NULL
	
	if @AMOUNT is null	
		Set @AMOUNT = 0
	
	DECLARE @EMP_ID AS NUMERIC(18,0)
	DECLARE @IT_ID  AS NUMERIC(18,0)
	DECLARE @REPEAT_YEARLY AS TINYINT
	DECLARE @IT_TRAN_ID AS NUMERIC
	DECLARE @TRAN_TYPE AS CHAR(1)
	Declare @FINANCIAL_YEAR as nvarchar(50)
	DECLARE @IT_IS_PERQUISITE AS TINYINT
	
	SET @REPEAT_YEARLY =0
	SET @IT_TRAN_ID =0
	set @FINANCIAL_YEAR = '' 
	Set @TRAN_TYPE = ''
	SET @IT_IS_PERQUISITE = 0
	
	
	IF month(@FOR_DATE) >=1 and month(@FOR_DATE) <= 3
		BEGIN
			set @FINANCIAL_YEAR =  cast((year(@FOR_DATE) - 1) AS VARCHAR(5)) +  '-' +  cast(year(@FOR_DATE) AS VARCHAR(5))
		END
	else if month(@FOR_DATE) >= 4 and month(@FOR_DATE) <= 12
		BEGIN
			set @FINANCIAL_YEAR = cast((year(@FOR_DATE)) AS VARCHAR(5)) +  '-' +  cast((year(@FOR_DATE) + 1) AS VARCHAR(5))
		END
	
	
	SELECT @EMP_ID=EMP_ID FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Alpha_Emp_Code=@EMP_CODE And Cmp_Id=@Cmp_Id
	SELECT @IT_ID = IT_ID , @IT_IS_PERQUISITE = ISNULL(IT_IS_PERQUISITE,0)  FROM T0070_IT_MASTER WITH (NOLOCK) WHERE IT_ALIAS=@IT_NAME And Cmp_Id=@Cmp_Id
	
	--CODE OF PERQUISITE , ADDED BY RAMIZ ON 03/04/2017
	IF @IT_IS_PERQUISITE = 1    --IF IMPORTED IT HEAD IS A PERQUISITE THEN IT SHOULD BE INSERTED IN PERQUSITE TABLE
	   BEGIN
	     IF @AMOUNT > 0    --IF AMOUNT IS GREATER THEN 0 , THEN WE WILL UPDATE IT AGAIN. . .
	       BEGIN
	          EXEC P0240_PERQUISITES_EMPLOYEE_DYNAMIC 0 , @CMP_ID , @EMP_ID , @IT_ID , @FINANCIAL_YEAR , @AMOUNT , 'I'
              RETURN
           END
         ELSE
            BEGIN    --BUT IF IT IS 0 THEN WE WILL DELETE THE UPLOADED VALUE ALSO
	          DELETE FROM T0240_PERQUISITES_EMPLOYEE_DYNAMIC WHERE EMP_ID = @EMP_ID AND IT_ID = @IT_ID AND FINANCIAL_YEAR = @FINANCIAL_YEAR AND CMP_ID = @CMP_ID
              RETURN
           END
	   END
	 --CODE ENDS
	 
	Declare @Cnt as numeric
	SET @Cnt = 0
	
	if @EMP_ID is null
		Begin
			Set @EMP_ID = 0
		End
	
	if @IT_ID is null -- Added by nilesh patel on 04082016
		Begin
			Set @IT_ID = 0
		End
		
	if @EMP_ID = 0
		Begin
			Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@EMP_ID,'Employee Doesn''t exists',@EMP_ID,'Employee Doesn''t exists',GetDate(),'IT Declaration',@GUID)
			return
		End
	
	if @IT_ID = 0
		Begin
			Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@EMP_ID,'IT Name Doesn''t exists',@EMP_ID,'IT Name Doesn''t exists',GetDate(),'IT Declaration',@GUID)
			return
		End
	
	If @FOR_DATE IS NULL
		Begin
			Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@EMP_ID,'For Date Doesn''t exists',@EMP_ID,'For Date Doesn''t exists',GetDate(),'IT Declaration',@GUID)
			return
		End
	
	--Added by Jaina 09-06-2017 
	Declare @Max_Limit Numeric(18,0)
	SELECT @Max_Limit = IT_Max_Limit FROM T0070_IT_MASTER WITH (NOLOCK) WHERE Cmp_ID=@CMP_ID AND IT_Name = @IT_NAME
	
	IF @Amount  > @Max_Limit And @Max_Limit > 0
	BEGIN
		
		Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@EMP_ID,'Amount exceed than Max Limit ('+ cast(@Max_Limit AS varchar)+').',@EMP_ID,'Amount exceed than Max Limit('+ cast(@Max_Limit AS varchar)+').',GetDate(),'IT Declaration',@GUID)
		return
	end
	
	IF @Flag = 0
	BEGIN	
		SET @Cnt = (Select COUNT(IT_TRAN_ID) from T0100_IT_DECLARATION WITH (NOLOCK) where CMP_ID = @CMP_ID AND EMP_ID = @EMP_ID AND IT_ID = @IT_ID and FINANCIAL_YEAR = @FINANCIAL_YEAR)
		IF @Cnt = 0
		BEGIN
			set @TRAN_TYPE ='I'
		END
		ELSE
		BEGIN
			set @TRAN_TYPE ='U'
			Set @IT_TRAN_ID =  (Select IT_TRAN_ID from T0100_IT_DECLARATION WITH (NOLOCK) where CMP_ID = @CMP_ID AND EMP_ID = @EMP_ID AND IT_ID = @IT_ID and FINANCIAL_YEAR = @FINANCIAL_YEAR)
		END			
	END
	ELSE
	BEGIN
		SET @Cnt = (Select COUNT(IT_TRAN_ID) from T0100_IT_DECLARATION WITH (NOLOCK) where CMP_ID = @CMP_ID AND EMP_ID = @EMP_ID AND IT_ID = @IT_ID and FINANCIAL_YEAR = @FINANCIAL_YEAR AND CONVERT(Varchar(20),FOR_DATE,103) = CONVERT(Varchar(20),@FOR_DATE,103))
		IF @Cnt = 0
		BEGIN
			set @TRAN_TYPE ='I'
		END
		ELSE
		BEGIN
			set @TRAN_TYPE ='U'
			Set @IT_TRAN_ID =  (Select IT_TRAN_ID from T0100_IT_DECLARATION WITH (NOLOCK) where CMP_ID = @CMP_ID AND EMP_ID = @EMP_ID AND IT_ID = @IT_ID and FINANCIAL_YEAR = @FINANCIAL_YEAR AND CONVERT(Varchar(20),FOR_DATE,103) = CONVERT(Varchar(20),@FOR_DATE,103))
		END	
	END
	-- Chnaged by Ali 27122013 -- End
	
	
	
	IF @TRAN_TYPE ='I'
		BEGIN
			SELECT @IT_TRAN_ID = ISNULL(MAX(IT_TRAN_ID),0) +1 FROM T0100_IT_DECLARATION WITH (NOLOCK)		
			INSERT INTO T0100_IT_DECLARATION
					   (IT_TRAN_ID, CMP_ID, IT_ID, EMP_ID, FOR_DATE, AMOUNT, DOC_NAME, LOGIN_ID, SYSTEM_DATE,REPEAT_YEARLY,FINANCIAL_YEAR)
			VALUES     (@IT_TRAN_ID, @CMP_ID, @IT_ID, @EMP_ID, @FOR_DATE, @AMOUNT, '', @LOGIN_ID, GETDATE(),@REPEAT_YEARLY,@FINANCIAL_YEAR)
					
		END
	ELSE
		BEGIN	-- Chnaged by Ali 27122013
			
			UPDATE T0100_IT_DECLARATION 
			SET FOR_DATE = @FOR_DATE, AMOUNT = @AMOUNT, SYSTEM_DATE = GetDate() 
			WHERE IT_TRAN_ID = @IT_TRAN_ID
		END
	
	RETURN




