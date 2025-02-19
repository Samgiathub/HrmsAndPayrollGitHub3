CREATE PROCEDURE [dbo].[P0040_TAX_LIMIT]
	@IT_L_ID				Numeric output, 
	@Cmp_ID					Numeric, 
	@For_Date				Datetime, 
	@Gender					Char(1), 
	@From_Limit				Numeric, 
	@To_Limit				Numeric, 
	@Percentage				Numeric(7,2), 
	@Additional_Amount		Numeric, 
	@Login_ID				Numeric,
	@Tran_Type				Char(1),
	@User_Id numeric(18,0) = 0, -- Add By Mukti 20072016
	@IP_Address varchar(30)= '', -- Add By Mukti 20072016
	@Regime					varchar(15)=''		--added by krushna 18032020
AS
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON

	IF @Login_ID = 0	
		SET @Login_ID = null
		
 -- Add By Mukti 20072016(start)
		declare @OldValue as  varchar(max)
		Declare @String as varchar(max)
		set @String=''
		set @OldValue =''
 -- Add By Mukti 20072016(end)
	
	if @For_date < '2020-04-01'
		set @Regime = 'Tax Regime 1'

	-- Added by Hardik 11/05/2020 for Delete 0 slab
	IF @From_Limit = 0 AND @To_Limit = 0
		SET @Tran_Type = 'D'
	
	IF @Tran_Type = 'I'
		BEGIN		      
				IF EXISTS(SELECT CMP_ID FROM T0040_TAX_LIMIT WITH (NOLOCK) WHERE CMP_ID =@CMP_ID and Gender = @Gender and For_Date = @For_Date AND (@From_Limit between From_limit and To_limit or @To_Limit between From_limit and To_limit) and Regime = @Regime) 
					BEGIN
						---raiserror('@@Limit Exists@@',16,2)
						RETURN -1 
					END
				SELECT @IT_L_ID = ISNULL(MAX(IT_L_ID),0) + 1 FROM T0040_TAX_LIMIT WITH (NOLOCK)
				INSERT INTO T0040_TAX_LIMIT(IT_L_ID, Cmp_ID, For_Date, Gender, From_Limit, To_Limit, Percentage, Additional_Amount, Login_ID, System_Date,Regime)
				SELECT @IT_L_ID, @Cmp_ID, @For_Date, @Gender, @From_Limit, @To_Limit, @Percentage, @Additional_Amount, @Login_ID, getdate(),@Regime
				
		-- Add By Mukti 20072016(start)
					exec P9999_Audit_get @table = 'T0040_TAX_LIMIT' ,@key_column='IT_L_ID',@key_Values=@IT_L_ID,@String=@String output
					set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))	 
		-- Add By Mukti 20072016(end)	
		END
		
	ELSE IF @Tran_Type ='U'
		BEGIN
			-- Add By Mukti 20072016(start)
					exec P9999_Audit_get @table='T0040_TAX_LIMIT' ,@key_column='IT_L_ID',@key_Values=@IT_L_ID,@String=@String output
					set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
			-- Add By Mukti 20072016(end)
			
				UPDATE  T0040_TAX_LIMIT
				SET For_Date =@For_Date, Gender =@Gender, From_Limit =@From_Limit , To_Limit =@To_Limit, Percentage =@Percentage, Additional_Amount =@Additional_Amount, Login_ID =@Login_ID, System_Date = getdate(),Regime = @Regime
				WHERE IT_L_ID =@IT_L_ID 	
				
			 -- Add By Mukti 20072016(start)
					exec P9999_Audit_get @table = 'T0040_TAX_LIMIT' ,@key_column='IT_L_ID',@key_Values=@IT_L_ID,@String=@String output
					set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))	 
			 -- Add By Mukti 20072016(end)		
		END
		
	ELSE IF @Tran_Type = 'D'
		BEGIN
			-- Add By Mukti 20072016(start)
					exec P9999_Audit_get @table='T0040_TAX_LIMIT' ,@key_column='IT_L_ID',@key_Values=@IT_L_ID,@String=@String output
					set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))
			-- Add By Mukti 20072016(end)
			
			DELETE FROM T0040_TAX_LIMIT	WHERE IT_L_ID =@IT_L_ID
		END
	exec P9999_Audit_Trail @CMP_ID,@tran_type,'IT Tax Limit',@OldValue,@IT_L_ID,@User_Id,@IP_Address		
RETURN









