
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0150_EMP_CANTEEN_PUNCH] 
	 @Tran_ID		NUMERIC(18,0)		OUTPUT
	,@Cmp_ID		NUMERIC
	,@Emp_ID		NUMERIC
	,@Canteen_Punch_Datetime	DATETIME
	,@Flag			varchar(100)		--A:New Add,D:Delete
	,@Device_IP		VARCHAR(100)
	,@Reason		VARCHAR(MAX) =''
	,@User_ID		NUMERIC
	,@IO_Tran_ID	NUMERIC	= 0 --Table -T9999_DEVICE_INOUT_DETAIL	--IO_Tran_ID
	,@Tran_Type		CHAR(1)
	,@Diet			VARCHAR(200) =NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON

	DECLARE @Enroll_NO	VARCHAR(15)
	DECLARE @For_Date	DATETIME
	
	SET @Enroll_NO = ''
	SET @For_Date = CONVERT(DATETIME,CONVERT(VARCHAR(20), @Canteen_Punch_Datetime,111))
	
	IF ISNULL(@Reason,'') = ''
		SET @Reason = NULL
	
	
	IF  EXISTS(SELECT 1 FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE Month_St_Date <= @For_Date AND ISNULL(cutoff_date,Month_End_Date) >= @For_Date AND Emp_ID = @Emp_ID AND Cmp_ID=@Cmp_Id)
       BEGIN
			SET @Tran_ID = 0
			RAISERROR('Salary Exist',16,2)
			RETURN  
	   END
	
	DECLARE @DEVICE_MODEL AS VARCHAR(25)
	DECLARE @DEVICE_TYPE AS VARCHAR(25)
	SET @DEVICE_MODEL = ''
	SET @DEVICE_TYPE = ''
	
	SELECT @DEVICE_MODEL = DEVICE_MODEL,@DEVICE_TYPE = DEVICE_TYPE 
	FROM T0040_IP_MASTER WITH (NOLOCK)
	WHERE IP_ADDRESS = @Device_IP AND CMP_ID = @CMP_ID

IF	@Tran_Type = 'I' --- Added by Hardik 13/07/2020 for cera.. Punch not deleting
		BEGIN	
			IF(@DEVICE_MODEL = 'OTHER' AND  @DEVICE_TYPE = 'Others')
																																																																																		BEGIN
			DECLARE @CANTEEN_ID AS NUMERIC(18,0)
			DECLARE @IP_ID AS NUMERIC(18,0)
			DECLARE @NFC_TRANID AS NUMERIC(18,0)
			DECLARE @EMP_NFC_CARDNO AS VARCHAR(50)
			
			SET @CANTEEN_ID = 0
			SET @IP_ID = 0
			SET @NFC_TRANID = 0
			SET @EMP_NFC_CARDNO = ''
			set @Flag = 'Manually(Mobile)'
			
			
			
			--- GET IPID BY IP_ADDRESS
			SELECT @IP_ID = IP_ID 
			FROM T0040_IP_MASTER WITH (NOLOCK)
			WHERE CMP_ID = @CMP_ID AND IP_ADDRESS = @Device_IP
			
			--- GET CANTEEN_ID BY IP_ID
			if @Flag = 'Manually(Mobile)'
			BEGIN
				SELECT @CANTEEN_ID = CNT_ID 
				FROM T0050_CANTEEN_MASTER WITH (NOLOCK)
				WHERE CMP_ID = @CMP_ID AND Cnt_Name = @Diet
			END
			ELSE
			BEGIN
				SELECT @CANTEEN_ID = CNT_ID 
				FROM T0050_CANTEEN_MASTER WITH (NOLOCK)
				WHERE CMP_ID = @CMP_ID AND IP_ID = ISNULL(@IP_ID,0) 
				set @Reason = 'Manually(Mobile)'
			END
			
			--- GET EMPLOYEE NFC CARD NO
			SELECT @NFC_TRANID = ISNULL(TRAN_ID,0)
			FROM T0081_CUSTOMIZED_COLUMN WITH (NOLOCK)
			WHERE CMP_ID = @CMP_ID and column_name='Canteen_Card_No'
			
			SELECT @EMP_NFC_CARDNO = VALUE
			FROM T0082_Emp_Column WITH (NOLOCK)
			WHERE CMP_ID = @CMP_ID AND EMP_ID = @EMP_ID AND MST_TRAN_ID = @NFC_TRANID
			
			
			SELECT @Tran_ID = ISNULL(MAX(Tran_ID),0) + 1 FROM T0150_EMP_CANTEEN_PUNCH WITH (NOLOCK)
			
			INSERT INTO T0150_EMP_CANTEEN_PUNCH
				(Tran_ID,Cmp_ID,Emp_ID,Canteen_Punch_Datetime,Flag,Device_IP,Reason,USER_ID,System_Date,CANTEEN_ID,CARD_NO,QUANTITY)
			VALUES
				(@Tran_ID,@Cmp_ID,@Emp_ID,@Canteen_Punch_Datetime,@Flag,@Device_IP,@Reason,@User_ID,GETDATE(),@CANTEEN_ID,@EMP_NFC_CARDNO,1)

		END
			ELSE
				BEGIN
	
					SELECT @Tran_ID = ISNULL(MAX(Tran_ID),0) + 1 FROM T0150_EMP_CANTEEN_PUNCH WITH (NOLOCK)
					INSERT INTO T0150_EMP_CANTEEN_PUNCH
						( Tran_ID,Cmp_ID,Emp_ID,Canteen_Punch_Datetime,Flag,Device_IP,Reason,USER_ID,System_Date)
					VALUES
						( @Tran_ID,@Cmp_ID,@Emp_ID,@Canteen_Punch_Datetime,@Flag,@Device_IP,@Reason,@User_ID,GETDATE())
			
				END
		END
			
	IF	@Tran_Type = 'I'
		BEGIN
		
			IF(@DEVICE_MODEL <> 'OTHER' AND  @DEVICE_TYPE <> 'Others')
			BEGIN
				--SELECT @Enroll_NO = ISNULL(Enroll_No,'') FROM T0080_EMP_MASTER WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID
				SELECT @Enroll_NO = case when isnull(T0080_EMP_MASTER.Old_Ref_No,'') = '' then isnull(T0080_EMP_MASTER.Enroll_No,0) else  ISNULL(T0080_EMP_MASTER.Old_Ref_No,0) end FROM T0080_EMP_MASTER WITH (NOLOCK)  WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID
				IF ISNULL(@Enroll_NO,'') = ''
					RETURN
					
				SELECT @Tran_ID = MAX(IO_Tran_ID) + 1 FROM T9999_DEVICE_INOUT_DETAIL WITH (NOLOCK)
				
				
				INSERT INTO T9999_DEVICE_INOUT_DETAIL
					( IO_Tran_ID,Cmp_ID,Enroll_No,IO_DateTime,IP_Address,In_Out_flag)
				VALUES
					( @Tran_ID,@Cmp_ID,@Enroll_NO,@Canteen_Punch_Datetime,@Device_IP,10)	
				
			END
				
		END
		
		
	ELSE IF @Tran_Type ='D' AND @IO_Tran_ID > 0
		BEGIN

			DELETE FROM T9999_DEVICE_INOUT_DETAIL WHERE IO_Tran_ID = @IO_Tran_ID
			DELETE FROM T0150_EMP_CANTEEN_PUNCH WHERE Tran_Id = @IO_Tran_ID --- Added by Hardik 13/07/2020 for cera.. Punch not deleting
			Set @Tran_ID=0 --- Added by Hardik 13/07/2020 for cera.. Punch not deleting
		END	
    
END

RETURN